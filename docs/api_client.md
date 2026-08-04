# Lexivo API client

## Approach (STEP 3.7)

**Decision:** interim typed Dio façade in `lib/core/network/api_client.dart`, DTOs aligned to `openapi/lexivo.openapi.json` (auth/users/documents schemas from the FastAPI backend).

Supports `createDocument` multipart (`file` + optional `title`) matching backend `POST /api/v1/documents` (`create_with_upload`). Feature code must call this method only — never storage SDKs.

**OCR result text:** `GET /api/v1/documents/{id}` returns nullable `extracted_text` (DTO/domain: `extractedText`). Status polling stays on `GET /api/v1/documents/{id}/status` (`processing` | `ready` | `failed`). The OCR feature calls only `getDocument` / `getDocumentStatus` — never storage or OCR vendor SDKs.

**Summarization:** `GET /api/v1/documents/{id}` also returns nullable `short_summary` / `detailed_summary` and `summary_status` (`idle` | `processing` | `ready` | `failed`, separate from OCR `status`). Trigger with `POST /api/v1/documents/{id}/summary` (202 when enqueued; **409** when OCR incomplete / empty `extracted_text`). Poll `GET /api/v1/documents/{id}/summary/status` → `{ id, summary_status }`. The summarization feature uses only `requestSummary` / `getSummaryStatus` / `getDocument` on the typed client — never LLM vendor SDKs.

OpenAPI codegen (`openapi-generator` dart-dio / `swagger_dart_code_generator`) is deferred — tracked as `TODO(openapi-codegen)`. When regenerating, ensure `DocumentResponse` summary fields and summary paths are present in the snapshot. Regen steps:

1. Start backend; run `./tool/generate_api_client.sh` to refresh `openapi/lexivo.openapi.json`.
2. Generate Dart Dio client into `lib/core/network/generated/` (never hand-edit generated files).
3. Thin-wrap generated client from `api_client.dart`.

## Env

See `.env.example`: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `API_BASE_URL`.

## Riverpod note

Plan prefers Riverpod 3; current stack uses `flutter_riverpod` ^2.6.1 because Riverpod 3 + Freezed 4 + `supabase_flutter` conflict with `flutter_test` SDK pins. Upgrade when pins allow.
