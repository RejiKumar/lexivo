# Lexivo

**Lexivo AI Document Assistant** — scan, understand, translate, and interrogate any document through an agent-powered RAG pipeline on mobile and web.

[![CI status](https://github.com/OWNER/lexivo/actions/workflows/pr.yml/badge.svg)](https://github.com/OWNER/lexivo/actions/workflows/pr.yml)

*(Replace `OWNER` with the GitHub org or user after the repository is published.)*

---

## Product Vision

Lexivo turns paperwork into answers. Students, professionals, and small businesses capture documents once, then summarize, translate, and ask grounded questions without reading every page. The product is scoped to a strong document vertical, built from reusable UI, agent, and service components so a broader productivity hub can assemble later from the same pieces.

Full product and technical scope: [spec/spec.md](spec/spec.md). Architecture: [spec/architecture.md](spec/architecture.md). UI system: [spec/ui_design_system.md](spec/ui_design_system.md).

## About

Lexivo is a cross-platform Flutter client backed by a FastAPI + LangGraph service layer. Documents flow through OCR, embeddings (pgvector), and specialized agents for summary, translation, RAG chat, and PDF export. Auth is Supabase; object storage is Cloudflare R2; web ships on Cloudflare Pages; API and workers run on Cloud Run.

## Problems Solved

| Pain | Lexivo response |
|---|---|
| Paper and PDF overload | Camera scan + OCR into clean, searchable text |
| Slow comprehension | AI short and detailed summaries |
| Language barriers | Translation of extracted content |
| Finding facts in long docs | Grounded RAG chat over the document |
| Sharing outcomes | PDF export of summaries, translations, and annotated results |
| Device lock-in | Cloud sync and account-based access across platforms |

## Features

| Capability | Notes |
|---|---|
| Document scan | Camera capture with crop / edge-aware input |
| OCR | Structured text extraction (Mistral OCR) |
| Summarization | Short and detailed AI summaries |
| Translation | Target-language translation of extracted text |
| RAG chat | Conversational Q&A grounded in the document |
| PDF export | Clean export of processed content |
| Cloud sync | Documents, chats, and summaries across devices |
| Auth & account | Sign up, sign in, session management (Supabase Auth) |
| Notifications | Processing-complete and reminder alerts |
| Subscription | Usage limits / paid tier — **feature-flagged** |
| Ads | Supported on the free tier |
| Adaptive web | Distinct mobile / tablet / desktop layouts (not stretched mobile) |
| Localization | English (`en`) in v1 |

Input strategy: [docs/document_input_source.md](docs/document_input_source.md). Typed API client: [docs/api_client.md](docs/api_client.md).

## AI Capabilities

- **Agent orchestrator** (LangGraph) routes OCR, summary, translation, RAG, and export as composable units
- **LLM:** Google Gemini (provider-swappable via adapters)
- **OCR:** Mistral OCR
- **Retrieval:** Hybrid search over PostgreSQL + pgvector embeddings
- **Background work:** Celery for OCR, embedding, translation, PDF, and notifications

## Tech Stack

| Layer | Technology |
|---|---|
| Client | Flutter 3.x, Riverpod, GoRouter |
| API | FastAPI |
| Agents | LangGraph |
| Data | PostgreSQL + pgvector |
| Jobs | Celery (+ Redis broker) |
| Auth | Supabase Auth |
| AI / OCR | Gemini, Mistral OCR |
| Storage | Cloudflare R2 |
| Hosting | Cloud Run (API + worker), Cloudflare Pages (web) |

## Folder Structure

**Target layout** (post-migration):

```text
lexivo/
  frontend/     # Flutter app (mobile + web)
  backend/      # FastAPI, Celery, agents
  docs/         # Ops, env, CI/CD, security, testing guides
  spec/         # Product & architecture specs
  prompts/      # Shared agent prompts
  scripts/      # Tooling and automation
  .github/      # Actions workflows and composites
  design/       # Design references
  assets/       # Shared static assets
```

> **Current state:** the Flutter app still lives at the repository root (`lib/`, `pubspec.yaml`, platform folders). Treat `frontend/` as the target home until migration completes. Backend already lives under `backend/`.

## Dev Setup

**Prerequisites:** Flutter 3.x SDK, Dart, Docker (for the local backend stack), Python 3.11+ (optional host runs).

```bash
# Flutter dependencies (repo root until frontend/ migration)
flutter pub get

# Backend local stack
cd backend
cp .env.example .env   # or: copy .env.example .env
docker compose up --build
```

API health: `GET http://127.0.0.1:8000/api/v1/health`  
Backend notes: [backend/README.md](backend/README.md).

### Platform permissions (scan)

- **Android:** camera and media/storage permissions as required by `image_picker` / `file_picker` (`AndroidManifest.xml`)
- **iOS:** `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` (`Info.plist`)

## Env Setup

Do not commit secrets. Environment matrices, secrets, and `--dart-define` / Compose variables are documented in **[docs/environment-strategy.md](docs/environment-strategy.md)**.

Related: [docs/deployment-guide.md](docs/deployment-guide.md), [docs/production-checklist.md](docs/production-checklist.md).

## Running the App

```bash
# Mobile / desktop device
flutter run

# Web
flutter run -d chrome

# Design-system showcase
flutter run --dart-define=LEXIVO_SHOWCASE=true
```

Point the client at a running API via `API_BASE_URL` (see env strategy). Typical local API: `http://localhost:8000`.

## Build Commands

```bash
# Analyze & unit/widget tests
flutter analyze
flutter test

# Web release
flutter build web --release

# Android
flutter build apk --release
flutter build appbundle --release

# OpenAPI client (from snapshot)
./tool/generate_api_client.sh
./tool/check_openapi_snapshot.sh
```

Backend tests: `cd backend && python -m pytest` (see [backend/README.md](backend/README.md)).

## CI/CD

PR checks, main-branch staging deploys, and production releases are defined as thin workflows over reusable composites under `.github/`.

**Details:** [docs/ci-cd.md](docs/ci-cd.md) · branching: [docs/branching-strategy.md](docs/branching-strategy.md) · versions: [docs/app-versioning.md](docs/app-versioning.md).

## Deployment Overview

Staging and production host the Flutter web app on **Cloudflare Pages** and the API/Celery workers on **Google Cloud Run**. Local development uses Docker Compose only.

**Details:** [docs/deployment-guide.md](docs/deployment-guide.md) · go-live gate: [docs/production-checklist.md](docs/production-checklist.md).

## Security

Auth, storage URL signing, PII handling, and rate limits are specified separately — do not invent ad-hoc auth or inline secrets.

**Details:** [docs/security.md](docs/security.md).

## Testing

Unit, widget, integration, golden, and backend pytest expectations live in the testing strategy. Prefer shared fixtures and generated clients over one-off mocks.

**Details:** [docs/testing-strategy.md](docs/testing-strategy.md).

## Roadmap

| Phase | Focus |
|---|---|
| **v1 (current)** | Scan → OCR → summary → translation → RAG chat → PDF export; auth, sync, notifications; adaptive web; `en` l10n; subscription flagged; free-tier ads |
| **Near-term** | Harden CI/CD and production checklist; complete `frontend/` migration; broaden language coverage |
| **Later** | Desktop (Windows); team collaboration; handwriting-tuned OCR; deeper offline generation |

Definition of Done for launch: [spec/spec.md](spec/spec.md) §12.

## Contribution Guide

1. Read [spec/spec.md](spec/spec.md), [spec/architecture.md](spec/architecture.md), and [docs/branching-strategy.md](docs/branching-strategy.md).
2. Work in small, feature-scoped PRs; follow the reusable-component checklist in the product spec.
3. Keep UI in the design system ([spec/ui_design_system.md](spec/ui_design_system.md)); keep prompts under `prompts/`.
4. Use the generated API client ([docs/api_client.md](docs/api_client.md)); do not hand-roll endpoints.
5. Run `flutter analyze` / `flutter test` and backend `pytest` before opening a PR; CI must stay green.
6. Never commit `.env` files or production secrets.
