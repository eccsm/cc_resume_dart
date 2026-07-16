import { execFileSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  CANONICAL_ORIGIN,
  INDEXNOW_ENDPOINT,
  INDEXNOW_HOST,
  MAX_URLS_PER_BATCH,
  chunkUrls,
  diffRemovedCaseStudyUrls,
  deriveRoutesFromChangedFiles,
  getCaseStudyUrlsFromResume,
  getIndexNowKeyLocation,
  getLegacyCaseStudyUrlsFromResume,
  loadSitemapUrls,
  normalizeIndexableUrls,
  shouldFallbackToSitemap,
  validateIndexNowKey,
} from './indexnow-lib.mjs';
import {
  loadGeneratedResumeJson,
  loadResumeModuleFromText,
  toResumeJson,
} from './resume-data.mjs';

const project = join(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = join(project, '..');
const args = parseArgs(process.argv.slice(2));
const key = validateIndexNowKey(process.env.INDEXNOW_KEY);
const keyLocation = getIndexNowKeyLocation(key);
const currentResume = await loadCurrentResumeSnapshot();

const explicitInputs = [...args.urls, ...args.routes];
let strategy = 'explicit';
let candidateInputs = explicitInputs;

if (candidateInputs.length === 0 && args.changedFrom && args.changedTo) {
  const changedFiles = getChangedFiles(args.changedFrom, args.changedTo);
  const changedRoutes = deriveRoutesFromChangedFiles(changedFiles);
  const legacyNotificationInputs = await getLegacyNotificationInputs(
    changedFiles,
    args.changedFrom,
    currentResume
  );

  if (changedRoutes.length > 0 && !shouldFallbackToSitemap(changedFiles)) {
    strategy = 'changed-routes';
    candidateInputs = [...changedRoutes, ...legacyNotificationInputs];
  } else if (shouldFallbackToSitemap(changedFiles)) {
    strategy = 'sitemap-fallback';
    const sitemapSource = args.sitemap || defaultSitemapPath();
    candidateInputs = [...(await loadSitemapUrls(sitemapSource)), ...legacyNotificationInputs];
  } else if (changedFiles.length === 0) {
    strategy = 'sitemap-fallback';
    const sitemapSource = args.sitemap || defaultSitemapPath();
    candidateInputs = await loadSitemapUrls(sitemapSource);
  } else {
    console.log('No indexable canonical route changes detected; skipping IndexNow submission.');
    process.exit(0);
  }
}

if (candidateInputs.length === 0) {
  if (strategy === 'explicit') {
    strategy = 'sitemap';
  }
  const sitemapSource = args.sitemap || defaultSitemapPath();
  if (!sitemapSource) {
    throw new Error('No IndexNow URLs provided and no sitemap source available.');
  }
  candidateInputs = await loadSitemapUrls(sitemapSource);
}

const urls = normalizeIndexableUrls(candidateInputs);
if (urls.length === 0) {
  console.log('No indexable canonical URLs remained after normalization; skipping IndexNow submission.');
  process.exit(0);
}

const batches = chunkUrls(urls, MAX_URLS_PER_BATCH);
const mode = args.dryRun ? 'dry-run' : 'live';
console.log(
  `IndexNow ${mode}: ${urls.length} canonical URL(s) from ${strategy} in ${batches.length} batch(es).`
);

if (args.dryRun) {
  for (const url of urls) {
    console.log(url);
  }
  process.exit(0);
}

for (const batch of batches) {
  const response = await fetch(INDEXNOW_ENDPOINT, {
    method: 'POST',
    headers: { 'content-type': 'application/json; charset=utf-8' },
    body: JSON.stringify({
      host: INDEXNOW_HOST,
      key,
      keyLocation,
      urlList: batch,
    }),
  });

  if (!response.ok) {
    const body = (await response.text()).slice(0, 500).trim();
    throw new Error(
      `IndexNow submission failed (${response.status} ${response.statusText})${body ? `: ${body}` : '.'}`
    );
  }
}

console.log(`IndexNow submission succeeded for ${urls.length} canonical URL(s).`);

function parseArgs(argv) {
  const parsed = {
    changedFrom: '',
    changedTo: '',
    dryRun: false,
    routes: [],
    sitemap: '',
    urls: [],
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case '--route':
        parsed.routes.push(requireValue(argv, ++i, arg));
        break;
      case '--url':
        parsed.urls.push(requireValue(argv, ++i, arg));
        break;
      case '--sitemap':
        parsed.sitemap = requireValue(argv, ++i, arg);
        break;
      case '--changed-from':
        parsed.changedFrom = requireValue(argv, ++i, arg);
        break;
      case '--changed-to':
        parsed.changedTo = requireValue(argv, ++i, arg);
        break;
      case '--dry-run':
        parsed.dryRun = true;
        break;
      default:
        throw new Error(`Unknown argument: ${arg}`);
    }
  }

  return parsed;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

function getChangedFiles(from, to) {
  if (!from || !to || /^0+$/.test(from)) {
    return [];
  }

  const output = execFileSync('git', ['diff', '--name-status', from, to], {
    cwd: repoRoot,
    encoding: 'utf8',
  }).trim();

  if (!output) {
    return [];
  }

  return output
    .split(/\r?\n/)
    .flatMap((line) => {
      const parts = line.split('\t').filter(Boolean);
      if (parts.length < 2) {
        return [];
      }
      if (parts[0].startsWith('R') || parts[0].startsWith('C')) {
        return parts.slice(1);
      }
      return [parts[1]];
    });
}

function defaultSitemapPath() {
  const sitemap = join(project, 'dist', 'sitemap-index.xml');
  return existsSync(sitemap) ? sitemap : new URL('/sitemap-index.xml', CANONICAL_ORIGIN).toString();
}

async function loadCurrentResumeSnapshot() {
  const candidates = [
    join(project, 'public', 'data', 'resume.json'),
    join(project, 'dist', 'data', 'resume.json'),
  ];

  for (const candidate of candidates) {
    if (existsSync(candidate)) {
      return await loadGeneratedResumeJson(candidate);
    }
  }

  return null;
}

async function getLegacyNotificationInputs(changedFiles, fromRef, currentSnapshot) {
  const normalizedFiles = changedFiles.map((file) => file.replaceAll('\\', '/'));
  if (!normalizedFiles.includes('site/src/data/resume.ts')) {
    return [];
  }

  const previousSnapshot = await loadResumeSnapshotFromGit(fromRef);
  if (!previousSnapshot || !currentSnapshot) {
    return [];
  }

  const removedUrls = diffRemovedCaseStudyUrls(previousSnapshot, currentSnapshot);
  const configuredLegacyUrls = getLegacyCaseStudyUrlsFromResume(currentSnapshot);
  const currentCaseStudyUrls = new Set(getCaseStudyUrlsFromResume(currentSnapshot));

  return [...new Set([...configuredLegacyUrls, ...removedUrls])].filter(
    (url) => !currentCaseStudyUrls.has(url)
  );
}

async function loadResumeSnapshotFromGit(ref) {
  if (!ref || /^0+$/.test(ref)) {
    return null;
  }

  try {
    const source = execFileSync('git', ['show', `${ref}:site/src/data/resume.ts`], {
      cwd: repoRoot,
      encoding: 'utf8',
    });
    const moduleData = await loadResumeModuleFromText(source);
    return toResumeJson(moduleData);
  } catch {
    return null;
  }
}
