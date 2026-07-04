# Umami analytics (self-hosted)

Privacy-friendly analytics for casim.net. ~256 MB RAM total for both
containers; any small VPS works.

## Setup

```sh
cp .env.example .env      # fill both secrets (openssl rand -hex 32)
docker compose up -d
```

1. Open `http://<host>:3000`, log in with `admin` / `umami`, **change the
   password immediately**.
2. Put a TLS reverse proxy in front (e.g. `stats.casim.net` → port 3000).
3. Settings → Websites → Add website (`casim.net`) → copy the **Website ID**.
4. In `site/.env` set:
   ```
   PUBLIC_UMAMI_SRC=https://stats.casim.net/script.js
   PUBLIC_UMAMI_WEBSITE_ID=<the id>
   ```
   and rebuild/redeploy the site. When these vars are unset, the site ships
   no analytics script at all.

## Cookieless — no consent banner needed

Umami is **cookieless by default**: `script.js` sets no cookies and writes
nothing to localStorage; visitors are counted via a salted hash computed
server-side and rotated daily, so no persistent identifier exists. The
site's tag additionally sets `data-do-not-track="true"` so browsers sending
DNT are excluded entirely. Verify after deploy: DevTools → Application →
Cookies on casim.net should list nothing from stats.casim.net.

## What is tracked

| Event | How |
|---|---|
| Page views | Automatic |
| Section visibility (`section-view`) | IntersectionObserver in `BaseLayout.astro`, fires once per section per visit when scrolled into view |
| Interactive mode launches (`interactive_mode_launched`) | Fired when the Flutter overlay opens |
| Outbound LinkedIn / GitHub / Hugging Face (`outbound-*`) | `data-umami-event` on hero + contact links |
| CV download (`cv-download`) | **Pending** — the Astro site has no CV file yet; when one is added, put `data-umami-event="cv-download"` on the link and it's tracked automatically |

## Required headers on stats.casim.net (COEP)

casim.net runs **cross-origin isolated** (`Cross-Origin-Embedder-Policy:
require-corp` — WebLLM in the Flutter island needs it). The tracking script
tag uses `crossorigin="anonymous"`, so the reverse proxy in front of Umami
must answer CORS/CORP or the browser refuses to load the script:

```
Access-Control-Allow-Origin: https://casim.net
Cross-Origin-Resource-Policy: cross-origin
```

(Caddy: `header Access-Control-Allow-Origin https://casim.net` etc.; nginx:
`add_header`.) Verify after deploy: the script shows no CORP/CORS error in
the console and page views appear in the dashboard.

The site's own CSP (`firebase.json` at the repo root) already allowlists
`https://stats.casim.net` in `script-src` and `connect-src`.
