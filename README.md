# casim.net — portfolio monorepo

One repo, one deployment. The Astro site is the shell served at
[casim.net](https://casim.net); the Flutter app is embedded in it as a
lazy-loaded "interactive mode" overlay.

## Layout

| Path | What it is |
|---|---|
| [`site/`](site/README.md) | Astro static site — the deployed artifact (`site/dist`). Semantic HTML resume, design tokens, JSON-LD/OG/sitemap. |
| [`flutter_app/`](flutter_app/README.md) | Flutter Web app, built into `site/public/assets/flutter/` and booted on demand as a multi-view island. Hosts the WebLLM in-browser AI chat (no server, no API keys). |
| [`analytics/`](analytics/README.md) | Self-hosted Umami (docker-compose) for stats.casim.net. |
| `scripts/` | Root build pipeline (see below). |

## Single source of truth

All resume content lives in
[`site/src/data/resume.ts`](site/src/data/resume.ts):

- the Astro pages render it directly,
- `site/scripts/emit-resume-json.mjs` emits `site/public/data/resume.json`
  (build step), which the Flutter app fetches at runtime — the WebLLM chat
  grounds its answers in the same data.

Edit content there and nowhere else. No PII — this repo is public.

## Building

```sh
node scripts/build.mjs        # flutter build web → copy into site/public → astro build
```

Produces the deployable `site/dist/`. Requires Flutter and Node 20+.
For site-only iteration (no Flutter island): `cd site && npm run build`.
If `INDEXNOW_KEY` is present in the environment, the build also injects the
temporary root verification file into the deployable artifact without
committing it.

## CI

- `.github/workflows/firebase-hosting-merge.yml` — full pipeline + deploy on
  merge to master (Firebase Hosting, project `resume-63067`), then IndexNow
  submission using the `INDEXNOW_KEY` GitHub secret.
- `.github/workflows/firebase-hosting-pull-request.yml` — PR preview channel.
- `.github/workflows/lighthouse-ci.yml` — perf/SEO/a11y/JS budgets on the
  static shell (Flutter assets are behind a user gesture and don't count).
