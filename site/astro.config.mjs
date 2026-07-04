// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://casim.net',
  output: 'static',
  integrations: [sitemap()],
});
