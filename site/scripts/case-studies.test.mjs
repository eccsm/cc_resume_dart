import assert from 'node:assert/strict';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { readFile } from 'node:fs/promises';

import { loadResumeModuleFromFile } from './resume-data.mjs';

const project = join(dirname(fileURLToPath(import.meta.url)), '..');
const {
  caseStudies,
  caseStudyRouteChanges,
  getCaseStudyCanonicalUrl,
  getLegacyCaseStudyCanonicalUrl,
  getCaseStudyPath,
  homepageCaseStudiesHref,
  validateCaseStudyRouteChanges,
  validateCaseStudies,
} = await loadResumeModuleFromFile();

const expectedRoutes = [
  '/case-studies/allianz-core-transformation/',
  '/case-studies/insurance-ddd-kafka/',
  '/case-studies/genai-hr-chatbot/',
  '/case-studies/harmoni-modernization/',
];

test('every case study has a unique non-empty slug and required content', () => {
  assert.equal(caseStudies.length, expectedRoutes.length);
  validateCaseStudies(caseStudies);

  for (const caseStudy of caseStudies) {
    assert.ok(caseStudy.slug.length > 0);
    assert.ok(caseStudy.summary.length > 0);
    assert.ok(caseStudy.challenge.length > 0);
    assert.ok(caseStudy.approach.length > 0);
    assert.ok(caseStudy.outcome.length > 0);
    assert.ok(caseStudy.stack.length > 0);
  }
});

test('duplicate case study slugs fail validation', () => {
  assert.throws(
    () =>
      validateCaseStudies([
        caseStudies[0],
        { ...caseStudies[1], slug: caseStudies[0].slug },
      ]),
    /Duplicate case study slug/
  );
});

test('each case study produces the expected static route and canonical URL', () => {
  const routes = caseStudies.map((caseStudy) => getCaseStudyPath(caseStudy));
  assert.deepEqual(routes, expectedRoutes);

  const canonicals = caseStudies.map((caseStudy) => getCaseStudyCanonicalUrl(caseStudy));
  assert.deepEqual(
    canonicals,
    expectedRoutes.map((route) => `https://ekincan.casim.net${route}`)
  );
});

test('homepage case study anchor and route set exclude unknown slugs', () => {
  assert.equal(homepageCaseStudiesHref, '/#case-studies');
  const routes = new Set(caseStudies.map((caseStudy) => getCaseStudyPath(caseStudy)));
  assert.equal(routes.has('/case-studies/unknown-slug/'), false);
});

test('legacy case study route changes remain valid and collision-free', () => {
  validateCaseStudyRouteChanges(caseStudies, caseStudyRouteChanges);

  for (const routeChange of caseStudyRouteChanges) {
    assert.ok(routeChange.fromSlug.length > 0);
    assert.equal(
      getLegacyCaseStudyCanonicalUrl(routeChange),
      `https://ekincan.casim.net/case-studies/${routeChange.fromSlug}/`
    );
  }
});

test('firebase redirects are present for any legacy case study replacements', async () => {
  const firebase = JSON.parse(await readFile(join(project, '..', 'firebase.json'), 'utf8'));
  const redirects = Array.isArray(firebase.hosting?.redirects) ? firebase.hosting.redirects : [];

  for (const routeChange of caseStudyRouteChanges.filter((change) => change.toSlug !== null)) {
    const expectedSource = `/case-studies/${routeChange.fromSlug}`;
    const expectedDestination = `/case-studies/${routeChange.toSlug}/`;
    const match = redirects.find(
      (redirect) =>
        redirect.source === expectedSource &&
        redirect.destination === expectedDestination &&
        redirect.type === 301
    );

    assert.ok(match, `Missing Firebase 301 redirect for ${expectedSource}`);
  }
});
