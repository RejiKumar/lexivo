# Lexivo API client

## Approach (STEP 3.7)

**Decision:** interim typed Dio façade in `lib/core/network/api_client.dart`, DTOs aligned to `openapi/lexivo.openapi.json` (auth/users/documents schemas from the FastAPI backend).

OpenAPI codegen (`openapi-generator` dart-dio / `swagger_dart_code_generator`) is deferred — tracked as `TODO(openapi-codegen)`. Regen steps:

1. Start backend; run `./tool/generate_api_client.sh` to refresh `openapi/lexivo.openapi.json`.
2. Generate Dart Dio client into `lib/core/network/generated/` (never hand-edit generated files).
3. Thin-wrap generated client from `api_client.dart`.

## Env

See `.env.example`: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `API_BASE_URL`.

## Riverpod note

Plan prefers Riverpod 3; current stack uses `flutter_riverpod` ^2.6.1 because Riverpod 3 + Freezed 4 + `supabase_flutter` conflict with `flutter_test` SDK pins. Upgrade when pins allow.
