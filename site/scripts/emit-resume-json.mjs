// Emits public/data/resume.json from src/data/resume.ts so non-TS consumers
// (the Flutter island) read the same single source of truth. Runs as part of
// `prebuild`; the output is git-ignored generated data.
import { writeFile, mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { loadResumeModuleFromFile, toResumeJson } from './resume-data.mjs';

const project = join(dirname(fileURLToPath(import.meta.url)), '..');
const data = await loadResumeModuleFromFile();
const resume = toResumeJson(data);

await mkdir(join(project, 'public/data'), { recursive: true });
await writeFile(
  join(project, 'public/data/resume.json'),
  JSON.stringify(resume, null, 2) + '\n'
);
console.log('resume.json emitted');
