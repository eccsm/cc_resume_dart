# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please send an
email to the address listed on the resume site. All security vulnerabilities
will be promptly addressed.

## Git History

On 2026-07-04 the repository history was rewritten with
[git filter-repo](https://github.com/newren/git-filter-repo) to remove
previously committed sensitive content (Firebase configuration files,
`google-services.json`, `.env`, and personal contact details). A full-history
scan for common credential patterns comes back clean.

Notes:

- Anyone holding an old clone or fork should re-clone; old clones contain the
  pre-rewrite history.
- The Firebase **web** API key that appeared in old history is a client-side
  identifier (shipped to every visitor by design), but it is restricted to the
  project's authorized domains as a precaution.

## Current Practices

- No secrets live in this repository. The only private value, the phone
  number shown in the generated PDF, is injected at build time via
  `--dart-define=RESUME_PHONE=...` from a GitHub Actions secret and is simply
  omitted when unset.
- The deployed site ships a strict `Content-Security-Policy` (no `eval`, no
  inline scripts), `X-Content-Type-Options: nosniff`, and
  `Referrer-Policy: strict-origin-when-cross-origin` — see `firebase.json`.
- `flutter analyze` and `flutter test` gate every deploy in CI.
- Sensitive file patterns (`.env`, key stores, service accounts) are covered
  by `.gitignore`.
