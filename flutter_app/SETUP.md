# Setup Guide

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

That's it — the app has no required environment files or secrets. Resume
content lives in `lib/pdf/resume_constants.dart`.

### Optional: phone number in the PDF

The phone number is intentionally not committed. To include it in the
generated PDF, pass it at build/run time:

```bash
flutter run -d chrome --dart-define=RESUME_PHONE="+90 5XX XXX XXXX"
```

## WebLLM (on-device chat AI)

The chatbot can run a small LLM (Llama 3.2 1B by default) entirely in the
visitor's browser via [WebLLM](https://github.com/mlc-ai/web-llm).

- `web/assets/js/webllm.js` is a self-hosted, version-pinned bundle of
  `@mlc-ai/web-llm` (see `package.json`); a pinned jsDelivr URL is the only
  CDN fallback.
- WebLLM requires cross-origin isolation (`SharedArrayBuffer`). The COOP/COEP
  headers in `firebase.json` provide this in production. `flutter run` serves
  without those headers, so local runs use the keyword-fallback chat unless
  you serve the build output with the right headers.
- Model weights download from Hugging Face on first use and are cached by the
  browser.

## Deployment

Pushes to `master` deploy to Firebase Hosting via GitHub Actions
(`.github/workflows/`). The pipeline runs `flutter analyze` and
`flutter test` before building.

Repository secrets used by CI:

| Secret | Required | Purpose |
| --- | --- | --- |
| `FIREBASE_SERVICE_ACCOUNT_RESUME_63067` | yes | Firebase Hosting deploy |
| `RESUME_PHONE` | no | Phone number in the generated PDF |

`firebase.json` also sets the security headers (CSP, COOP/COEP) and cache
policy for the deployed site.

## Troubleshooting

- **Chat stays in "local" mode on the deployed site** — verify the response
  headers include `Cross-Origin-Opener-Policy: same-origin` and
  `Cross-Origin-Embedder-Policy: require-corp`, and hard-refresh
  (Ctrl+Shift+R) to drop any stale cached bundle.
- **CSP violation in the console** — the failing URL is logged; add its
  origin to the matching directive in `firebase.json` if it is legitimate.
- General weirdness after dependency changes: `flutter clean && flutter pub get`.
