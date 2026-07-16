import { readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const project = join(dirname(fileURLToPath(import.meta.url)), '..');
const resumeSourcePath = join(project, 'src', 'data', 'resume.ts');
const generatedResumePath = join(project, 'public', 'data', 'resume.json');

export const RESUME_JSON_SCHEMA_VERSION = 3;

export async function loadResumeModuleFromFile(filePath = resumeSourcePath) {
  const source = await readFile(filePath, 'utf8');
  return await loadResumeModuleFromText(source);
}

export async function loadResumeModuleFromText(source) {
  const { transform } = await import('esbuild');
  const { code } = await transform(source, { loader: 'ts', format: 'esm' });
  const dataUrl = `data:text/javascript;base64,${Buffer.from(code).toString('base64')}`;
  return await import(dataUrl);
}

export async function loadGeneratedResumeJson(filePath = generatedResumePath) {
  return JSON.parse(await readFile(filePath, 'utf8'));
}

export function toResumeJson(data) {
  return {
    schemaVersion: RESUME_JSON_SCHEMA_VERSION,
    canonicalOrigin: data.canonicalOrigin,
    homepageCaseStudiesHref: data.homepageCaseStudiesHref,
    profile: data.profile,
    experiences: data.experiences,
    caseStudies: data.caseStudies,
    caseStudyRouteChanges: data.caseStudyRouteChanges ?? [],
    skills: data.skills,
    skillLevels: data.skillLevels,
    education: data.education,
    certifications: data.certifications,
    languages: data.languages,
    contact: data.contact,
    knowsAbout: data.knowsAbout,
  };
}

