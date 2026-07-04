# resume-chat Worker

Cloudflare Worker backing the "Ask my resume" chat and the listen (TTS)
buttons on casim.net.

| Route | What it does |
|---|---|
| `POST /ask` | Streams a Claude (`claude-haiku-4-5`) answer as SSE; identical questions are served from KV cache as JSON |
| `POST /tts` | Returns ElevenLabs MP3 audio for an assistant answer; cached forever in R2 by text hash |
| `GET /health` | Uptime probe, returns `{ok: true}` |

The system prompt is generated from [`../site/src/data/resume.ts`](../site/src/data/resume.ts)
at deploy time — **redeploy the worker after editing resume content.**

## First deploy

```sh
cd worker
npm install
npx wrangler login

# 1. Create the KV namespace and paste its id into wrangler.toml
npx wrangler kv namespace create resume-chat-kv

# 2. Create the R2 bucket (name already in wrangler.toml)
npx wrangler r2 bucket create resume-tts-audio

# 3. Secrets
npx wrangler secret put ANTHROPIC_API_KEY
npx wrangler secret put ELEVENLABS_API_KEY
npx wrangler secret put IP_HASH_SALT        # any long random string

# 4. Ship it
npm run deploy
```

Then point the site at it: set `PUBLIC_CHAT_ENDPOINT` in `site/.env`
(e.g. `https://resume-chat.<account>.workers.dev` or `https://ask.casim.net`
after attaching the custom domain in the dashboard).

## Rotating API keys

Rotation is zero-downtime — secrets apply to new requests immediately:

```sh
# 1. Create the new key in the provider console
#    (Anthropic: platform.claude.com → API keys; ElevenLabs: profile → API keys)
# 2. Swap it in:
npx wrangler secret put ANTHROPIC_API_KEY     # paste the NEW key
# 3. Verify a live request works, THEN revoke the old key in the console.
```

Same flow for `ELEVENLABS_API_KEY`. Rotate immediately if a key ever appears
in a log, commit, or error report. Rotating `IP_HASH_SALT` is also harmless —
it just resets in-flight hourly rate-limit windows.

## Adjusting caps

All caps are plain vars in [`wrangler.toml`](wrangler.toml) — edit and `npm run deploy`:

| Var | Default | Meaning |
|---|---|---|
| `DAILY_CAP` | 200 | Global `/ask` requests per UTC day; beyond it the widget shows "assistant is resting — email me instead". Cached answers keep working past the cap. |
| `TTS_DAILY_CAP` | 20 | Global ElevenLabs synthesis calls per UTC day. R2 cache hits don't count. |
| `ELEVENLABS_VOICE_ID` | Adam (premade) | Swap for your premium voice ID any time. Note: changing the voice does not invalidate R2-cached audio — clear `tts/` in the bucket if you want old answers re-synthesized. |

Hard-coded limits (change in `src/index.ts`): 10 messages/IP/hour,
500-char questions, 600-char TTS input, `max_tokens: 400` per answer.

Cost ceiling at defaults: 200 answers/day × (~2K input + 400 output tokens)
on Haiku 4.5 ($1/$5 per MTok) ≈ **$0.80/day worst case**, usually far less
because of the question cache.

## Reviewing what recruiters ask

Question text (no IPs, no fingerprints) is logged to KV for 30 days under
`qlog:<date>:<ts>`:

```sh
npx wrangler kv key list --binding KV --prefix "qlog:2026-07" | head
npx wrangler kv key get --binding KV "qlog:2026-07-04:1751600000000-ab12cd34"
```

Privacy notes: per-IP rate limiting stores only a salted SHA-256 hash that
expires with its 1-hour window; nothing else identifies visitors.

## Abuse guards baked in

- `/tts` refuses text that didn't come out of `/ask` (KV `ansok:` marker), so
  it can't be used as a free general-purpose TTS proxy.
- CORS restricted to `ALLOWED_ORIGINS`.
- The system prompt instructs the model to ignore instruction-injection in
  visitor messages and stay strictly on resume topics.
