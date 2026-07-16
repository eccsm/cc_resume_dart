import { readFile } from 'node:fs/promises';
import { extname, resolve } from 'node:path';

export const INDEXNOW_HOST = 'casim.net';
export const CANONICAL_ORIGIN = new URL(`https://${INDEXNOW_HOST}/`);
export const INDEXNOW_ENDPOINT = 'https://api.indexnow.org/indexnow';
export const MAX_URLS_PER_BATCH = 1000;

const KEY_PATTERN = /^[A-Za-z0-9-]{8,128}$/;
const NON_INDEXABLE_PREFIXES = ['/assets/flutter/', '/_astro/', '/fonts/', '/data/'];
const NON_INDEXABLE_PATHS = new Set([
  '/BingSiteAuth.xml',
  '/robots.txt',
  '/sitemap.xml',
  '/sitemap-index.xml',
  '/404.html',
  '/500.html',
]);
const NON_INDEXABLE_EXTENSIONS = new Set([
  '.css',
  '.gif',
  '.ico',
  '.jpeg',
  '.jpg',
  '.js',
  '.json',
  '.map',
  '.otf',
  '.png',
  '.svg',
  '.txt',
  '.wasm',
  '.webp',
  '.woff',
  '.woff2',
  '.xml',
]);
const PAGE_FILE_PATTERN = /\.(astro|html|md|mdx)$/;
const PAGE_EXTENSIONS = new Set(['.astro', '.html', '.md', '.mdx']);
const SITE_WIDE_CHANGE_PREFIXES = [
  'site/src/components/',
  'site/src/data/',
  'site/src/layouts/',
  'site/public/',
  'site/scripts/',
];
const SITE_WIDE_CHANGE_FILES = new Set([
  'firebase.json',
  'scripts/build.mjs',
  'site/astro.config.mjs',
  'site/package.json',
]);

export function validateIndexNowKey(rawKey) {
  const key = String(rawKey ?? '').trim();
  if (!key) {
    throw new Error('INDEXNOW_KEY is required.');
  }
  if (!KEY_PATTERN.test(key)) {
    throw new Error(
      'INDEXNOW_KEY must be 8-128 characters using only letters, numbers, or hyphens.'
    );
  }
  return key;
}

export function getIndexNowKeyFilename(key) {
  return `${validateIndexNowKey(key)}.txt`;
}

export function getIndexNowKeyLocation(key) {
  return new URL(`/${getIndexNowKeyFilename(key)}`, CANONICAL_ORIGIN).toString();
}

export function normalizeIndexNowUrl(input, { base = CANONICAL_ORIGIN } = {}) {
  const value = String(input ?? '').trim();
  if (!value) {
    throw new Error('IndexNow URL cannot be empty.');
  }

  const url = new URL(value, base);
  if (!['http:', 'https:'].includes(url.protocol)) {
    throw new Error(`IndexNow URL must use http or https: ${value}`);
  }
  if (url.hostname !== INDEXNOW_HOST) {
    throw new Error(`IndexNow URL hostname must be exactly ${INDEXNOW_HOST}: ${value}`);
  }

  url.protocol = 'https:';
  url.username = '';
  url.password = '';
  url.hash = '';
  url.port = '';
  return url;
}

export function isIndexableCanonicalUrl(input) {
  const url = input instanceof URL ? input : normalizeIndexNowUrl(input);
  const pathname = url.pathname || '/';

  if (NON_INDEXABLE_PATHS.has(pathname)) {
    return false;
  }
  if (pathname.toLowerCase().startsWith('/sitemap')) {
    return false;
  }
  if (NON_INDEXABLE_PREFIXES.some((prefix) => pathname.startsWith(prefix))) {
    return false;
  }

  const extension = extname(pathname).toLowerCase();
  if (extension === '.html') {
    const leaf = pathname.split('/').filter(Boolean).at(-1)?.toLowerCase() ?? '';
    return leaf !== '404.html' && leaf !== '500.html';
  }

  return !NON_INDEXABLE_EXTENSIONS.has(extension);
}

export function normalizeIndexableUrls(inputs, options) {
  const seen = new Set();
  const urls = [];

  for (const input of inputs) {
    const url = normalizeIndexNowUrl(input, options);
    if (!isIndexableCanonicalUrl(url)) {
      continue;
    }
    const href = url.toString();
    if (!seen.has(href)) {
      seen.add(href);
      urls.push(href);
    }
  }

  return urls;
}

export function chunkUrls(urls, size = MAX_URLS_PER_BATCH) {
  if (!Number.isInteger(size) || size <= 0) {
    throw new Error('IndexNow batch size must be a positive integer.');
  }

  const batches = [];
  for (let i = 0; i < urls.length; i += size) {
    batches.push(urls.slice(i, i + size));
  }
  return batches;
}

export function decodeXmlEntities(value) {
  return value
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'");
}

export function parseSitemap(xml) {
  const locs = [...xml.matchAll(/<loc>([\s\S]*?)<\/loc>/gi)].map((match) =>
    decodeXmlEntities(match[1].trim())
  );
  const type = /<sitemapindex\b/i.test(xml) ? 'index' : 'urlset';
  return { type, locs };
}

export async function loadSitemapUrls(source, { loadText = defaultLoadText, seen = new Set() } = {}) {
  const normalizedSource = normalizeSitemapSource(source);
  if (seen.has(normalizedSource)) {
    return [];
  }
  seen.add(normalizedSource);

  const xml = await loadText(normalizedSource);
  const { type, locs } = parseSitemap(xml);
  if (type !== 'index') {
    return locs;
  }

  const urls = [];
  for (const loc of locs) {
    urls.push(...(await loadSitemapUrls(loc, { loadText, seen })));
  }
  return urls;
}

export function routeFromPageFile(filePath) {
  const normalized = filePath.replaceAll('\\', '/');
  const prefix = 'site/src/pages/';
  if (!normalized.startsWith(prefix)) {
    return null;
  }

  const relativePath = normalized.slice(prefix.length);
  if (!PAGE_FILE_PATTERN.test(relativePath) || relativePath.includes('[')) {
    return null;
  }
  if (relativePath.startsWith('api/')) {
    return null;
  }

  const extension = extname(relativePath).toLowerCase();
  if (!PAGE_EXTENSIONS.has(extension)) {
    return null;
  }

  let route = relativePath.slice(0, -extension.length);
  if (route === 'index') {
    return '/';
  }
  if (route === '404' || route === '500') {
    return null;
  }
  if (route.endsWith('/index')) {
    route = route.slice(0, -'/index'.length);
  }
  return `/${route}/`.replace(/\/+/g, '/');
}

export function deriveRoutesFromChangedFiles(files) {
  const seen = new Set();
  const routes = [];

  for (const file of files) {
    const route = routeFromPageFile(file);
    if (route && !seen.has(route)) {
      seen.add(route);
      routes.push(route);
    }
  }

  return routes;
}

export function shouldFallbackToSitemap(files) {
  return files.some((file) => {
    const normalized = file.replaceAll('\\', '/');
    return (
      SITE_WIDE_CHANGE_FILES.has(normalized) ||
      SITE_WIDE_CHANGE_PREFIXES.some((prefix) => normalized.startsWith(prefix))
    );
  });
}

async function defaultLoadText(source) {
  if (/^https?:\/\//i.test(source)) {
    const response = await fetch(source);
    if (!response.ok) {
      throw new Error(`Failed to fetch sitemap (${response.status} ${response.statusText}).`);
    }
    return await response.text();
  }

  return await readFile(source, 'utf8');
}

function normalizeSitemapSource(source) {
  if (source instanceof URL) {
    return source.toString();
  }

  const value = String(source ?? '').trim();
  if (!value) {
    throw new Error('Sitemap source cannot be empty.');
  }
  if (/^https?:\/\//i.test(value)) {
    return value;
  }
  return resolve(value);
}
