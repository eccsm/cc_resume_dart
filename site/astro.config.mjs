// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://ekincan.casim.net',
  output: 'static',
  integrations: [sitemap()],
});
