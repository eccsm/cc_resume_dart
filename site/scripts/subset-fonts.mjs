// One-off font subsetter: writes latin + Turkish subsets of the full fonts in
// assets/fonts/ to public/fonts/. Re-run after upgrading the font files:
//   node scripts/subset-fonts.mjs
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import subsetFont from 'subset-font';

const project = join(dirname(fileURLToPath(import.meta.url)), '..');

// Basic Latin + Latin-1 Supplement + Latin Extended-A (covers Turkish
// ğışçöü İĞŞÇÖÜ) + common typographic punctuation used on the site.
function charset() {
  let chars = '';
  for (let cp = 0x20; cp <= 0x7e; cp++) chars += String.fromCodePoint(cp);
  for (let cp = 0xa0; cp <= 0xff; cp++) chars += String.fromCodePoint(cp);
  for (let cp = 0x100; cp <= 0x17f; cp++) chars += String.fromCodePoint(cp);
  chars += '–—‘’“”…•·→−';
  return chars;
}

const jobs = [
  ['assets/fonts/InterVariable.woff2', 'public/fonts/InterVariable.woff2'],
  ['assets/fonts/JetBrainsMono-Regular.woff2', 'public/fonts/JetBrainsMono-Regular.woff2'],
];

await mkdir(join(project, 'public/fonts'), { recursive: true });
for (const [src, dest] of jobs) {
  const input = await readFile(join(project, src));
  const output = await subsetFont(input, charset(), { targetFormat: 'woff2' });
  await writeFile(join(project, dest), output);
  console.log(
    `${dest}: ${(input.length / 1024).toFixed(0)} KiB -> ${(output.length / 1024).toFixed(0)} KiB`
  );
}
