// Chat + TTS backend for casim.net. Routes:
//   POST /ask    — streams a Claude answer about the resume (SSE passthrough)
//   POST /tts    — ElevenLabs speech for an answer, cached in R2 by text hash
//   GET  /health — uptime probe
import { SYSTEM_PROMPT } from './prompt';

export interface Env {
  KV: KVNamespace;
  TTS_AUDIO: R2Bucket;
  ANTHROPIC_API_KEY: string;
  ELEVENLABS_API_KEY: string;
  ELEVENLABS_VOICE_ID: string;
  ANTHROPIC_MODEL: string;
  DAILY_CAP: string;
  TTS_DAILY_CAP: string;
  ALLOWED_ORIGINS: string;
  IP_HASH_SALT: string;
}

const MAX_QUESTION_CHARS = 500;
const MAX_TTS_CHARS = 600;
const IP_LIMIT_PER_HOUR = 10;
const CACHE_TTL_SECONDS = 7 * 86400;
const LOG_TTL_SECONDS = 30 * 86400;

// ---------- helpers ----------

async function sha256(text: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

function corsHeaders(request: Request, env: Env): Record<string, string> {
  const origin = request.headers.get('Origin') ?? '';
  const allowed = env.ALLOWED_ORIGINS.split(',').map((o) => o.trim());
  return {
    'Access-Control-Allow-Origin': allowed.includes(origin) ? origin : allowed[0],
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Max-Age': '86400',
    Vary: 'Origin',
  };
}

function json(status: number, body: unknown, cors: Record<string, string>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', ...cors },
  });
}

function utcDay(): string {
  return new Date().toISOString().slice(0, 10);
}

/**
 * KV counter with a fixed expiry window. KV writes are last-write-wins, not
 * atomic — a burst can slightly overshoot the limit, which is acceptable for
 * cost control at this traffic level.
 */
async function bumpCounter(
  kv: KVNamespace,
  key: string,
  windowSeconds: number
): Promise<number> {
  const raw = await kv.get(key);
  const count = raw ? parseInt(raw, 10) + 1 : 1;
  await kv.put(key, String(count), { expirationTtl: windowSeconds });
  return count;
}

function normalizeQuestion(q: string): string {
  return q.toLowerCase().trim().replace(/\s+/g, ' ').replace(/[?!.,;:'"]+$/g, '');
}

// ---------- /ask ----------

async function handleAsk(
  request: Request,
  env: Env,
  ctx: ExecutionContext,
  cors: Record<string, string>
): Promise<Response> {
  let question: string;
  try {
    const body = (await request.json()) as { question?: unknown };
    question = String(body.question ?? '').trim();
  } catch {
    return json(400, { error: 'bad_request' }, cors);
  }
  if (!question || question.length > MAX_QUESTION_CHARS) {
    return json(400, { error: 'bad_request' }, cors);
  }

  // Per-IP rate limit: 10 messages/hour. Only a salted hash is stored, and it
  // expires with the window — no raw IPs are retained.
  const ip = request.headers.get('CF-Connecting-IP') ?? 'unknown';
  const ipHash = await sha256(env.IP_HASH_SALT + ip);
  const ipCount = await bumpCounter(env.KV, `rl:${ipHash}`, 3600);
  if (ipCount > IP_LIMIT_PER_HOUR) {
    return json(429, { error: 'rate_limited' }, cors);
  }

  // Log question text only (no IP, no fingerprint) for later review.
  const day = utcDay();
  ctx.waitUntil(
    env.KV.put(
      `qlog:${day}:${Date.now()}-${crypto.randomUUID().slice(0, 8)}`,
      JSON.stringify({ q: question, ts: new Date().toISOString() }),
      { expirationTtl: LOG_TTL_SECONDS }
    )
  );

  // Cache: identical (normalized) questions are served without an API call.
  const cacheKey = `cache:${await sha256(normalizeQuestion(question))}`;
  const cached = await env.KV.get(cacheKey);
  if (cached) {
    return json(200, { answer: cached, cached: true }, cors);
  }

  // Daily global cap — checked after the cache so cached traffic stays free
  // and keeps working when the assistant is "resting".
  const dayCount = await bumpCounter(env.KV, `day:${day}`, 2 * 86400);
  if (dayCount > parseInt(env.DAILY_CAP, 10)) {
    return json(429, { error: 'daily_cap' }, cors);
  }

  const upstream = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': env.ANTHROPIC_API_KEY,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      model: env.ANTHROPIC_MODEL,
      max_tokens: 400,
      stream: true,
      system: SYSTEM_PROMPT,
      messages: [{ role: 'user', content: question }],
    }),
  });

  if (!upstream.ok || !upstream.body) {
    return json(502, { error: 'upstream', status: upstream.status }, cors);
  }

  // Pipe the SSE stream through unchanged while accumulating the text deltas,
  // so the finished answer can be cached after the stream closes.
  const decoder = new TextDecoder();
  let buffer = '';
  let answer = '';
  let resolveDone!: () => void;
  const done = new Promise<void>((resolve) => (resolveDone = resolve));

  const tee = new TransformStream<Uint8Array, Uint8Array>({
    transform(chunk, controller) {
      controller.enqueue(chunk);
      buffer += decoder.decode(chunk, { stream: true });
      let nl;
      while ((nl = buffer.indexOf('\n')) !== -1) {
        const line = buffer.slice(0, nl).trim();
        buffer = buffer.slice(nl + 1);
        if (!line.startsWith('data:')) continue;
        try {
          const event = JSON.parse(line.slice(5));
          if (event.type === 'content_block_delta' && event.delta?.type === 'text_delta') {
            answer += event.delta.text;
          }
        } catch {
          // partial or non-JSON data line — ignore
        }
      }
    },
    flush() {
      resolveDone();
    },
  });

  ctx.waitUntil(
    done.then(async () => {
      if (!answer) return;
      await env.KV.put(cacheKey, answer, { expirationTtl: CACHE_TTL_SECONDS });
      // Marker so /tts only synthesizes text this assistant actually produced.
      await env.KV.put(`ansok:${await sha256(answer)}`, '1', {
        expirationTtl: CACHE_TTL_SECONDS,
      });
    })
  );

  return new Response(upstream.body.pipeThrough(tee), {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-store',
      ...cors,
    },
  });
}

// ---------- /tts ----------

async function handleTts(
  request: Request,
  env: Env,
  cors: Record<string, string>
): Promise<Response> {
  let text: string;
  try {
    const body = (await request.json()) as { text?: unknown };
    text = String(body.text ?? '').trim();
  } catch {
    return json(400, { error: 'bad_request' }, cors);
  }
  if (!text) return json(400, { error: 'bad_request' }, cors);
  if (text.length > MAX_TTS_CHARS) return json(413, { error: 'too_long' }, cors);

  const hash = await sha256(text);
  const r2Key = `tts/${hash}.mp3`;

  // Repeated questions cost nothing: serve from R2 when we've synthesized
  // this exact text before.
  const existing = await env.TTS_AUDIO.get(r2Key);
  if (existing) {
    return new Response(existing.body, {
      headers: {
        'Content-Type': 'audio/mpeg',
        'Cache-Control': 'public, max-age=604800',
        'X-Tts-Cache': 'hit',
        ...cors,
      },
    });
  }

  // Only synthesize text that came out of /ask — blocks using this endpoint
  // as a free general-purpose TTS proxy.
  const isKnownAnswer = await env.KV.get(`ansok:${hash}`);
  if (!isKnownAnswer) {
    return json(403, { error: 'unknown_text' }, cors);
  }

  const ttsCount = await bumpCounter(env.KV, `tts:${utcDay()}`, 2 * 86400);
  if (ttsCount > parseInt(env.TTS_DAILY_CAP, 10)) {
    return json(429, { error: 'daily_cap' }, cors);
  }

  const upstream = await fetch(
    `https://api.elevenlabs.io/v1/text-to-speech/${env.ELEVENLABS_VOICE_ID}?output_format=mp3_44100_64`,
    {
      method: 'POST',
      headers: {
        'xi-api-key': env.ELEVENLABS_API_KEY,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        text,
        // Multilingual model so Turkish answers are pronounced correctly.
        model_id: 'eleven_multilingual_v2',
      }),
    }
  );

  if (!upstream.ok) {
    return json(502, { error: 'upstream', status: upstream.status }, cors);
  }

  const audio = await upstream.arrayBuffer();
  await env.TTS_AUDIO.put(r2Key, audio, {
    httpMetadata: { contentType: 'audio/mpeg' },
  });

  return new Response(audio, {
    headers: {
      'Content-Type': 'audio/mpeg',
      'Cache-Control': 'public, max-age=604800',
      'X-Tts-Cache': 'miss',
      ...cors,
    },
  });
}

// ---------- router ----------

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const cors = corsHeaders(request, env);
    const { pathname } = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: cors });
    }
    if (request.method === 'GET' && pathname === '/health') {
      return json(200, { ok: true, ts: new Date().toISOString() }, cors);
    }
    if (request.method === 'POST' && pathname === '/ask') {
      return handleAsk(request, env, ctx, cors);
    }
    if (request.method === 'POST' && pathname === '/tts') {
      return handleTts(request, env, cors);
    }
    return json(404, { error: 'not_found' }, cors);
  },
} satisfies ExportedHandler<Env>;
