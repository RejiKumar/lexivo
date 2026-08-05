# Lexivo API client

## Approach (STEP 3.7)

**Decision:** interim typed Dio façade in `lib/core/network/api_client.dart`, DTOs aligned to `openapi/lexivo.openapi.json` (auth/users/documents schemas from the FastAPI backend).

Supports `createDocument` multipart (`file` + optional `title`) matching backend `POST /api/v1/documents` (`create_with_upload`). Feature code must call this method only — never storage SDKs.

**OCR result text:** `GET /api/v1/documents/{id}` returns nullable `extracted_text` (DTO/domain: `extractedText`). Status polling stays on `GET /api/v1/documents/{id}/status` (`processing` | `ready` | `failed`). The OCR feature calls only `getDocument` / `getDocumentStatus` — never storage or OCR vendor SDKs.

**Summarization:** `GET /api/v1/documents/{id}` also returns nullable `short_summary` / `detailed_summary` and `summary_status` (`idle` | `processing` | `ready` | `failed`, separate from OCR `status`). Trigger with `POST /api/v1/documents/{id}/summary` (202 when enqueued; **409** when OCR incomplete / empty `extracted_text`). Poll `GET /api/v1/documents/{id}/summary/status` → `{ id, summary_status }`. The summarization feature uses only `requestSummary` / `getSummaryStatus` / `getDocument` on the typed client — never LLM vendor SDKs.

**Translation:** `GET /api/v1/documents/{id}` also returns nullable `translated_text` / `source_lang` / `target_lang` and `translation_status` (`idle` | `processing` | `ready` | `failed`, separate from OCR `status` and `summary_status`). Trigger with `POST /api/v1/documents/{id}/translation` body `{ source_lang, target_lang }` (202 when enqueued; **409** when OCR incomplete; **422** for unsupported / invalid pair). Supported v1 pairs: EN↔ES,FR,DE,HI,PT. Poll `GET /api/v1/documents/{id}/translation/status` → `{ id, translation_status, source_lang?, target_lang? }`. The translation feature uses only `requestTranslation` / `getTranslationStatus` / `getDocument` on the typed client — never LLM vendor SDKs.

**Chat / RAG:** Prefer Master intent `ask` (alias `rag_chat`). `POST /api/v1/chats/{doc_id}` get-or-create chat (idempotent). `GET /api/v1/chats/{doc_id}/messages` returns ordered messages with optional `citations` on assistant rows. `POST /api/v1/chats/{doc_id}/messages` body `{ content }` runs synchronous ask (Search→Citation via Master), persists user + assistant messages, returns assistant message with citations (**409** OCR not ready / not ingested; **422** empty content; ungrounded cannot-answer is still **200**). Typed client: `createChat` / `listChatMessages` / `postChatMessage`. The rag_chat feature uses only these methods — never LLM / vector vendor SDKs.

**PDF export:** `POST /api/v1/documents/{id}/export` body `{ include_summary, include_translation, include_chat }` enqueues Master intent `export` (202 when accepted; **422** if no toggles; **409** if a selected section is not ready / empty). Poll `GET /api/v1/documents/{id}/export/status` (latest for doc) or `GET /api/v1/exports/{export_id}` → `{ id, document_id, include_*, export_status, signed_url?, storage_key?, error_message? }` (`idle` | `processing` | `ready` | `failed`). On `ready`, client opens the time-limited `signed_url` — never public buckets or storage SDKs. Typed client: `requestExport` / `getExportStatus` / `getExport`. The pdf_export feature uses only these methods.

**Notifications:** `GET /api/v1/notifications` (auth; optional `?unread_only=`) returns newest-first `{ items: [{ id, type, title, body, payload, read_at, created_at }], total }`. `POST /api/v1/notifications/{id}/read` marks read (idempotent; **404** missing/wrong owner). Job-complete emit is server-side only via Master intent `notification` (Notification Agent → NotificationStore + PushProvider Protocol stub) — no email in v1. Typed client: `listNotifications` / `markNotificationRead`. The notifications feature uses only these methods — never push vendor SDKs.

**Subscription / quotas (STEP 3.7):** Free-tier caps are Settings-driven (defaults: **20** docs/UTC month, **100** user chat messages/UTC day, **500** OCR pages/UTC month) via `FREE_TIER_*` / `SUBSCRIPTION_PAYWALL_ENABLED` (default **false**). Caps always enforce via shared `QuotaService` whether the paywall flag is on or off; paid tier skips caps. Over-cap actions return HTTP **429** with nested detail `{ code: "quota_exceeded", resource, limit, period, message }` (`resource`: `documents` | `chat_messages` | `ocr_pages`; `period`: `month` | `day`). `GET /api/v1/subscriptions/me` (auth) → `{ tier, paywall_enabled, usage: { documents|chat_messages|ocr_pages: { used, limit, period } } }` — always available. `POST /api/v1/subscriptions/upgrade` stub sets `tier=paid` only when paywall flag is on; when flag off → **403** feature-disabled without changing tier. Typed client: `getSubscriptionMe` / `upgradeSubscription`. Flutter paywall/upgrade UI is behind compile-time `SUBSCRIPTION_PAYWALL_ENABLED` (default false). Map 429 + `quota_exceeded` → `QuotaFailure`. No real payment SDK in v1.

OpenAPI codegen (`openapi-generator` dart-dio / `swagger_dart_code_generator`) is deferred — tracked as `TODO(openapi-codegen)`. When regenerating, ensure `DocumentResponse` summary + translation fields, summary/translation/export paths, chat paths (`ChatResponse`, `ChatMessageResponse`, citations), `ExportRequest` / `ExportResponse`, and `NotificationResponse` / `NotificationListResponse` (+ list/mark-read paths) are present in the snapshot. Regen steps:

1. Start backend; run `./tool/generate_api_client.sh` to refresh `openapi/lexivo.openapi.json` **or** `python backend/scripts/check_openapi_snapshot.py --update` (in-process dump, preferred for CI parity).
2. Generate Dart Dio client into `lib/core/network/generated/` (never hand-edit generated files).
3. Thin-wrap generated client from `api_client.dart`.

**CI enforcement:** PRs run `./tool/check_openapi_snapshot.sh` — checked-in snapshot must match `create_app().openapi()`. Full dart-dio codegen is **optional** and does not fail the PR unless `enforce_codegen` is enabled later. Soft job skips when `lib/core/network/generated/` is absent.

## Env

See `.env.example`: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `API_BASE_URL`, plus optional `SENTRY_DSN` / `POSTHOG_*`. Env/secrets matrix: [environment-strategy.md](environment-strategy.md). Deploy: [deployment-guide.md](deployment-guide.md).

## Riverpod note

Plan prefers Riverpod 3; current stack uses `flutter_riverpod` ^2.6.1 because Riverpod 3 + Freezed 4 + `supabase_flutter` conflict with `flutter_test` SDK pins. Upgrade when pins allow.
