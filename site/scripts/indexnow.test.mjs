import assert from 'node:assert/strict';
import test from 'node:test';

import {
  MAX_URLS_PER_BATCH,
  chunkUrls,
  diffRemovedCaseStudyUrls,
  deriveRoutesFromChangedFiles,
  getCaseStudyUrlsFromResume,
  getIndexNowKeyLocation,
  getLegacyCaseStudyUrlsFromResume,
  loadSitemapUrls,
  normalizeIndexNowUrl,
  normalizeIndexableUrls,
  parseSitemap,
  shouldFallbackToSitemap,
  validateIndexNowKey,
} from './indexnow-lib.mjs';

test('validateIndexNowKey accepts safe keys and rejects invalid ones', () => {
  assert.equal(validateIndexNowKey('abc12345-KEY'), 'abc12345-KEY');
  assert.throws(() => validateIndexNowKey('short'), /INDEXNOW_KEY/);
  assert.throws(() => validateIndexNowKey('bad key value'), /INDEXNOW_KEY/);
});

test('normalizeIndexNowUrl forces https, strips fragments, and rejects non-canonical hosts', () => {
  const url = normalizeIndexNowUrl('/#experience');
  assert.equal(url.toString(), 'https://casim.net/');

  const absolute = normalizeIndexNowUrl('http://casim.net/projects?x=1#top');
  assert.equal(absolute.toString(), 'https://casim.net/projects?x=1');

  assert.throws(() => normalizeIndexNowUrl('https://ekincan.casim.net/'), /casim\.net/);
  assert.throws(() => normalizeIndexNowUrl('https://localhost:4321/'), /casim\.net/);
});

test('normalizeIndexableUrls deduplicates URLs and filters assets and verification files', () => {
  const urls = normalizeIndexableUrls([
    '/',
    'https://casim.net/#case-studies',
    'https://casim.net/assets/flutter/hash/index.html',
    'https://casim.net/robots.txt',
    'https://casim.net/about/',
    'https://casim.net/about/',
  ]);

  assert.deepEqual(urls, ['https://casim.net/', 'https://casim.net/about/']);
});

test('chunkUrls batches well below the IndexNow limit', () => {
  const urls = Array.from({ length: MAX_URLS_PER_BATCH * 2 + 1 }, (_, index) =>
    `https://casim.net/page-${index}/`
  );
  const batches = chunkUrls(urls);

  assert.equal(batches.length, 3);
  assert.equal(batches[0].length, MAX_URLS_PER_BATCH);
  assert.equal(batches[1].length, MAX_URLS_PER_BATCH);
  assert.equal(batches[2].length, 1);
});

test('parseSitemap and loadSitemapUrls support sitemap indexes and urlsets', async () => {
  const indexXml =
    '<?xml version="1.0"?><sitemapindex><sitemap><loc>https://casim.net/sitemap-0.xml</loc></sitemap></sitemapindex>';
  const pageXml =
    '<?xml version="1.0"?><urlset><url><loc>https://casim.net/</loc></url><url><loc>https://casim.net/about/</loc></url></urlset>';

  assert.deepEqual(parseSitemap(pageXml), {
    type: 'urlset',
    locs: ['https://casim.net/', 'https://casim.net/about/'],
  });

  const loadText = async (source) => {
    if (source === 'https://casim.net/sitemap-index.xml') return indexXml;
    if (source === 'https://casim.net/sitemap-0.xml') return pageXml;
    throw new Error(`Unexpected sitemap source: ${source}`);
  };

  const urls = await loadSitemapUrls('https://casim.net/sitemap-index.xml', { loadText });
  assert.deepEqual(urls, ['https://casim.net/', 'https://casim.net/about/']);
});

test('loadSitemapUrls resolves nested sitemap files locally during dry runs', async () => {
  const files = new Map([
    [
      'C:/site/dist/sitemap-index.xml',
      '<?xml version="1.0"?><sitemapindex><sitemap><loc>https://casim.net/sitemap-0.xml</loc></sitemap></sitemapindex>',
    ],
    [
      'C:/site/dist/sitemap-0.xml',
      '<?xml version="1.0"?><urlset><url><loc>https://casim.net/</loc></url><url><loc>https://casim.net/case-studies/allianz-core-transformation/</loc></url></urlset>',
    ],
  ]);

  const urls = await loadSitemapUrls('C:/site/dist/sitemap-index.xml', {
    loadText: async (source) => {
      const match = files.get(source.replaceAll('\\', '/'));
      if (!match) {
        throw new Error(`Unexpected sitemap source: ${source}`);
      }
      return match;
    },
  });

  assert.deepEqual(urls, [
    'https://casim.net/',
    'https://casim.net/case-studies/allianz-core-transformation/',
  ]);
});

test('current sitemap-style URL sets remain homepage plus canonical case-study pages only', () => {
  const resume = {
    caseStudies: [
      { slug: 'allianz-core-transformation' },
      { slug: 'insurance-ddd-kafka' },
      { slug: 'genai-hr-chatbot' },
      { slug: 'harmoni-modernization' },
    ],
  };

  assert.deepEqual(getCaseStudyUrlsFromResume(resume), [
    'https://casim.net/case-studies/allianz-core-transformation/',
    'https://casim.net/case-studies/insurance-ddd-kafka/',
    'https://casim.net/case-studies/genai-hr-chatbot/',
    'https://casim.net/case-studies/harmoni-modernization/',
  ]);

  assert.deepEqual(
    normalizeIndexableUrls([
      'https://casim.net/',
      'https://casim.net/#experience',
      'https://casim.net/#case-studies',
      'https://casim.net/assets/flutter/2b9f573/index.html',
      ...getCaseStudyUrlsFromResume(resume),
      'https://casim.net/BingSiteAuth.xml',
    ]),
    ['https://casim.net/', ...getCaseStudyUrlsFromResume(resume)]
  );
});

test('deriveRoutesFromChangedFiles maps static Astro pages and falls back for site-wide changes', () => {
  assert.deepEqual(
    deriveRoutesFromChangedFiles([
      'site/src/pages/index.astro',
      'site/src/pages/about.astro',
      'site/src/pages/blog/index.astro',
      'site/src/pages/[slug].astro',
      'site/src/pages/404.astro',
    ]),
    ['/', '/about/', '/blog/']
  );

  assert.equal(
    shouldFallbackToSitemap(['site/src/components/Hero.astro', 'README.md']),
    true
  );
  assert.equal(shouldFallbackToSitemap(['site/src/pages/case-studies/[slug].astro']), true);
  assert.equal(shouldFallbackToSitemap(['site/src/pages/about.astro']), true);
});

test('getIndexNowKeyLocation builds the canonical verification URL', () => {
  assert.equal(
    getIndexNowKeyLocation('abc12345-KEY'),
    'https://casim.net/abc12345-KEY.txt'
  );
});

test('legacy case-study URLs are preserved for notifications after slug changes', () => {
  const previousResume = {
    caseStudies: [
      { slug: 'legacy-allianz' },
      { slug: 'insurance-ddd-kafka' },
    ],
  };
  const currentResume = {
    caseStudies: [
      { slug: 'allianz-core-transformation' },
      { slug: 'insurance-ddd-kafka' },
    ],
    caseStudyRouteChanges: [{ fromSlug: 'legacy-allianz', toSlug: 'allianz-core-transformation' }],
  };

  assert.deepEqual(diffRemovedCaseStudyUrls(previousResume, currentResume), [
    'https://casim.net/case-studies/legacy-allianz/',
  ]);
  assert.deepEqual(getLegacyCaseStudyUrlsFromResume(currentResume), [
    'https://casim.net/case-studies/legacy-allianz/',
  ]);
});
