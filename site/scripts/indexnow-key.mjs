import { mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { getIndexNowKeyFilename, validateIndexNowKey } from './indexnow-lib.mjs';

const project = join(dirname(fileURLToPath(import.meta.url)), '..');
const publicDir = join(project, 'public');
const markerPath = join(project, 'src', 'generated', 'indexnow-key.json');

const action = process.argv[2] ?? 'prepare';

if (!['prepare', 'cleanup'].includes(action)) {
  throw new Error('Usage: node scripts/indexnow-key.mjs <prepare|cleanup>');
}

if (action === 'prepare') {
  await cleanupGeneratedKey();

  if (!process.env.INDEXNOW_KEY) {
    console.log('INDEXNOW_KEY not set; skipping IndexNow key file generation.');
    process.exit(0);
  }

  const key = validateIndexNowKey(process.env.INDEXNOW_KEY);
  const filename = getIndexNowKeyFilename(key);

  await mkdir(dirname(markerPath), { recursive: true });
  await writeFile(join(publicDir, filename), `${key}\n`);
  await writeFile(markerPath, JSON.stringify({ filename }, null, 2) + '\n');

  console.log('IndexNow key file prepared for build.');
  process.exit(0);
}

await cleanupGeneratedKey();
console.log('IndexNow key file cleanup complete.');

async function cleanupGeneratedKey() {
  const marker = await readMarker();
  if (!marker?.filename) {
    await rm(markerPath, { force: true });
    return;
  }

  await rm(join(publicDir, marker.filename), { force: true });
  await rm(markerPath, { force: true });
}

async function readMarker() {
  try {
    return JSON.parse(await readFile(markerPath, 'utf8'));
  } catch {
    return null;
  }
}
