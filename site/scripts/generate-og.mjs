// Generates public/og.png (1200x630) from resume data at build time.
// Runs as the `prebuild` script; satori renders a React-element-like tree
// to SVG, resvg rasterizes it to PNG.
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import satori from 'satori';
import { Resvg } from '@resvg/resvg-js';

const root = dirname(fileURLToPath(import.meta.url));
const project = join(root, '..');

// resume.ts is TypeScript; strip types the cheap way by importing values we
// need from a tiny inline copy would drift. Instead, transpile on the fly
// with Astro's bundled esbuild.
const { transform } = await import('esbuild');
const source = await readFile(join(project, 'src/data/resume.ts'), 'utf8');
const { code } = await transform(source, { loader: 'ts', format: 'esm' });
const dataUrl = 'data:text/javascript;base64,' + Buffer.from(code).toString('base64');
const { profile, contact, knowsAbout } = await import(dataUrl);

const interRegular = await readFile(join(project, 'assets/fonts/Inter-Regular.ttf'));
const interBold = await readFile(join(project, 'assets/fonts/Inter-Bold.ttf'));

const chips = knowsAbout.slice(0, 8);

const el = (type, style, children) => ({ type, props: { style, children } });

const svg = await satori(
  el(
    'div',
    {
      width: 1200,
      height: 630,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'space-between',
      padding: 72,
      backgroundColor: '#0f1115',
      backgroundImage: 'linear-gradient(135deg, #0f1115 60%, #241a08 100%)',
      color: '#e6e6e6',
      fontFamily: 'Inter',
    },
    [
      el('div', { display: 'flex', flexDirection: 'column' }, [
        el(
          'div',
          { fontSize: 28, color: '#e8a33d', letterSpacing: 2, textTransform: 'uppercase' },
          'casim.net'
        ),
        el('div', { fontSize: 76, fontWeight: 700, marginTop: 16 }, profile.name),
        el('div', { fontSize: 38, color: '#9aa0aa', marginTop: 12 }, profile.title),
      ]),
      el(
        'div',
        { display: 'flex', flexWrap: 'wrap', gap: 12 },
        chips.map((skill) =>
          el(
            'div',
            {
              display: 'flex',
              fontSize: 24,
              padding: '8px 22px',
              borderRadius: 6,
              backgroundColor: '#21252e',
              color: '#b8bdc7',
            },
            skill
          )
        )
      ),
      el(
        'div',
        { display: 'flex', justifyContent: 'space-between', fontSize: 26, color: '#9aa0aa' },
        [
          el('div', { display: 'flex' }, contact.email),
          el('div', { display: 'flex' }, 'github.com/eccsm · linkedin.com/in/eccsm'),
        ]
      ),
    ]
  ),
  {
    width: 1200,
    height: 630,
    fonts: [
      { name: 'Inter', data: interRegular, weight: 400, style: 'normal' },
      { name: 'Inter', data: interBold, weight: 700, style: 'normal' },
    ],
  }
);

const png = new Resvg(svg, { fitTo: { mode: 'width', value: 1200 } }).render().asPng();
await mkdir(join(project, 'public'), { recursive: true });
await writeFile(join(project, 'public/og.png'), png);
console.log(`og.png generated (${(png.length / 1024).toFixed(0)} KiB)`);
