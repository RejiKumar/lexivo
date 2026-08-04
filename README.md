# Lexivo

Lexivo AI Document Assistant (Flutter + FastAPI).

[![CI status](https://github.com/OWNER/Nexora/actions/workflows/pr.yml/badge.svg)](https://github.com/OWNER/Nexora/actions/workflows/pr.yml)
*(Replace `OWNER` with the GitHub org/user after the repo is published.)*

## Flutter setup

```bash
flutter pub get
```

### Environment

Copy `.env.example` and supply (via `--dart-define` or your loader):

| Variable | Purpose |
|---|---|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anon key (public) |
| `API_BASE_URL` | FastAPI base URL (e.g. `http://localhost:8000`) |
| `SENTRY_DSN` | Sentry (empty = no-op) |
| `POSTHOG_API_KEY` / `POSTHOG_HOST` | PostHog (empty = no-op) |
| `SUBSCRIPTION_PAYWALL_ENABLED` | Paywall UI flag (default false) |

Never commit real secrets. Full matrix: [docs/deployment.md](docs/deployment.md).

### Platform permissions (document scan)

- **Android:** `CAMERA`, `READ_MEDIA_IMAGES` / storage as required by `image_picker` / `file_picker` (see `AndroidManifest.xml`).
- **iOS:** `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` in `Info.plist`.
- Input strategy: [docs/document_input_source.md](docs/document_input_source.md).

### API client

See [docs/api_client.md](docs/api_client.md). OpenAPI snapshot: `openapi/lexivo.openapi.json`. Regen: `./tool/generate_api_client.sh`. CI enforces snapshot drift via `./tool/check_openapi_snapshot.sh`.

### Design system showcase

```bash
flutter run --dart-define=LEXIVO_SHOWCASE=true
```

## CI / CD

Reusable GitHub Actions composites under `.github/actions/` (lint, test, build, deploy-cloud-run, deploy-cloudflare-pages). Callers:

| Workflow | Trigger | Role |
|---|---|---|
| `.github/workflows/pr.yml` | pull_request | analyze, test, OpenAPI check, Docker build (no push) |
| `.github/workflows/main.yml` | push to `main` | checks + artifacts + staging deploy |
| `.github/workflows/deploy-production.yml` | `workflow_dispatch` / tag `v*` | production (protected Environment) |

Details, secrets, and smoke checklist: **[docs/deployment.md](docs/deployment.md)**.

Local stack remains Docker Compose — see [backend/README.md](backend/README.md).

## Getting Started

This project is a starting point for a Flutter application. See the
[Flutter documentation](https://docs.flutter.dev/) for tooling help.
