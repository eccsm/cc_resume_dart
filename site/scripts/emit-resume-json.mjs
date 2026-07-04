// Emits public/data/resume.json from src/data/resume.ts so non-TS consumers
// (the Flutter island) read the same single source of truth. Runs as part of
// `prebuild`; the output is git-ignored generated data.
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const project = join(dirname(fileURLToPath(import.meta.url)), '..');

const { transform } = await import('esbuild');
const source = await readFile(join(project, 'src/data/resume.ts'), 'utf8');
const { code } = await transform(source, { loader: 'ts', format: 'esm' });
const dataUrl = 'data:text/javascript;base64,' + Buffer.from(code).toString('base64');
const data = await import(dataUrl);

const resume = {
  // Bump when the shape changes so the Flutter parser can detect drift.
  schemaVersion: 1,
  profile: data.profile,
  experiences: data.experiences,
  caseStudies: data.caseStudies,
  skills: data.skills,
  skillLevels: data.skillLevels,
  education: data.education,
  certifications: data.certifications,
  languages: data.languages,
  contact: data.contact,
  knowsAbout: data.knowsAbout,
};

await mkdir(join(project, 'public/data'), { recursive: true });
await writeFile(
  join(project, 'public/data/resume.json'),
  JSON.stringify(resume, null, 2) + '\n'
);
console.log('resume.json emitted');
