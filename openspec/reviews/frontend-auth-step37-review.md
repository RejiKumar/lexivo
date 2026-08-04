# Frontend Auth STEP 3.7 Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | auth (Flutter) + architecture §2.1–§2.3 core network/routing/widgets |
| **Reviewer** | Reviewer Agent (independent) |
| **Date** | 2026-08-04 |
| **Sources** | `openspec/specs/auth/spec.md`, `spec/architecture.md` §2.1–§2.3, `spec/ui_design_system.md` (compose Lexivo*), `spec/nexora_spec.md` §13, `openspec/plans/frontend-auth-tasks.md` §15 |
| **Claimed** | Core Result/dio/api_client/job_poller/AsyncValueView/GoRouter; `features/auth`; ~201 flutter tests; §15 open |
| **Verdict** | **PASS** |

---

## Verdict

**PASS** — STEP 3.7 auth + core frontend slice Definition of Done is met. Plan gates 15.1–15.9 all pass (Riverpod 2.6 and interim Dio client accepted as documented, non-blocking deviations). Independent `flutter test` matches the claim: **201 passed**.

**Is STEP 3.7 DoD met?** **Yes.**

**May `document_scan` (next frontend feature) proceed?** **Yes.**

---

## Gate-by-gate results

| # | Gate | Result |
|---|---|---|
| 15.1 | Core prereq — Result, error_mapper, dio_provider, api_client, job_poller, AsyncValueView, GoRouter + auth guard present and tested | **PASS** |
| 15.2 | OpenAPI / client — `/api/v1` auth\|users\|documents covered; no ad-hoc Dio in features; interim TODO + regen docs | **PASS** (interim, non-blocking follow-up) |
| 15.3 | Clean architecture — auth tree §2.1; barrel-only outside; no cross-feature data imports; Dio token injection does not import auth data | **PASS** |
| 15.4 | Supabase session — sign-up, sign-in, invalid credentials, persistence (mocked), sign-out covered by tests | **PASS** |
| 15.5 | Account settings — view/update via `/users/me`; reflected after save/reload in tests | **PASS** |
| 15.6 | UI composition — auth screens Lexivo* + layout; password via design-system; no feature-local atomic widgets | **PASS** |
| 15.7 | Scope — no `document_scan` (or later) feature UI/logic beyond api_client stubs; no CI/CD scope creep | **PASS** |
| 15.8 | TDD / stack — Freezed models; `flutter test` green; Riverpod **2.6** (not 3) with documented conflict | **PASS** (deviation, non-blocking follow-up) |
| 15.9 | Final vs OpenSpec auth + architecture §2.1–§2.3 + design-system composition | **PASS** |
| — | Product §13 reusability checklist | **PASS** (see notes) |
| — | `flutter test` green | **PASS** (201 passed) |

---

## Evidence

### 15.1 Core prereq gate

Present under `lib/core/` with matching suites under `test/core/`:

| Artifact | Path | Tests |
|---|---|---|
| `Result` + Failures | `utils/result.dart` | `result_test.dart` |
| `error_mapper` | `network/error_mapper.dart` | `error_mapper_test.dart` |
| `dio_provider` | `network/dio_provider.dart` | `dio_provider_test.dart` (base URL, bearer, retry) |
| `api_client` | `network/api_client.dart` (+ Freezed DTOs) | `api_client_test.dart` |
| `job_poller` | `utils/job_poller.dart` | `job_poller_test.dart` |
| `AsyncValueView` | `widgets/async_value_view.dart` | `async_value_view_test.dart` |
| GoRouter + auth guard | `routing/app_router.dart`, `route_guards.dart` | `app_router_test.dart`, `route_guards_test.dart` |

### 15.2 OpenAPI / client gate

- Interim typed Dio façade implements `getAuthMe`, `getUserMe` / `patchUserMe`, `listDocuments` / `getDocument` / `getDocumentStatus` under `/api/v1`.
- `TODO(openapi-codegen)` on `api_client.dart`; approach + regen steps in `docs/api_client.md` and `tool/generate_api_client.sh`; snapshot at `openapi/lexivo.openapi.json`.
- Auth feature HTTP for profile goes through `ApiClient` only (`AuthRemoteDatasource`). No `package:dio` / `Dio(` usage inside `lib/features/auth/` for listed endpoints.
- Plan explicitly allows interim façade when codegen is blocked — **does not break contract**.

### 15.3 Clean architecture gate

- Tree: `data/` (datasources, repositories), `domain/` (entities Freezed, repository contract, usecases), `presentation/` (screens, providers), barrel `auth.dart`.
- `lib/main.dart` imports `package:lexivo/features/auth/auth.dart` only (barrel).
- No other `lib/features/*` exists — no cross-feature imports possible yet.
- Core `accessTokenReaderProvider` / `authGuardStateProvider` are overridden from auth via `authCoreOverrides()`; `dio_provider` does not import `features/auth/data`.
- Barrel exports domain entities, public providers/screens; does not export data-layer types.

### 15.4 Supabase session gate

OpenSpec scenarios covered (mocked gateway / fake repository):

| Scenario | Evidence |
|---|---|
| Successful sign-in → session | `auth_providers_test`, domain usecase tests |
| Invalid credentials → Failure, no session | `auth_providers_test`, `auth_screens_test` (LexivoErrorBanner), datasource error mapping |
| Persistence across restart | `auth_session_flow_test` cold start with seeded session → home |
| Sign-out | providers + session flow (redirect to sign-in; token omitted) |
| Sign-up path | domain + `SignUpScreen` widget tests |

Supabase SDK is behind `SupabaseAuthGateway` (+ `UnconfiguredAuthGateway` when env unset) — adapter-shaped, not ad-hoc crypto.

### 15.5 Account settings gate

- `AccountSettingsScreen` loads via `accountProfileProvider` + `AsyncValueView`; saves through `updateAccount` → `patchUserMe`.
- Datasource test: get/patch `/users/me` with fixtures; screen test asserts save success snackbar and profile invalidate path.

### 15.6 UI composition gate

- Screens compose `LexivoTextField`, `LexivoButton`, `LexivoErrorBanner`, `LexivoSnackbar`, tokens (`LexivoSpacing`, `LexivoTypography`), plus layout (`Scaffold`, `SafeArea`, `Column`, `Padding`, `Text`).
- Passwords use `LexivoTextFieldVariant.password` (obscure + visibility toggle landed in design_system).
- No feature-local atomic widgets under `features/auth/presentation/widgets/`.
- Grep: no raw `ElevatedButton` / ad-hoc `TextField` / Material button chrome in auth screens.

**Soft note (non-blocking):** `AccountSettingsScreen` uses Material `AppBar` for title chrome. Design system has bottom/rail nav only (showcase also uses Material `AppBar`). Not a one-off interactive atom; migrate if/when a Lexivo top bar exists.

### 15.7 Scope gate

- Only Flutter feature is `auth`. `AuthHomeShell` is a brand placeholder with explicit “no document_scan UI”.
- Documents endpoints exist solely as shared `ApiClient` stubs/tests — correct prereq for later features.
- No CI/CD or backend scope expansion observed in this slice.

### 15.8 TDD / stack gate + known deviations

| Claim / plan default | Actual | Decision |
|---|---|---|
| Riverpod 3 | `flutter_riverpod: ^2.6.1` | **PASS with follow-up** — documented in `docs/api_client.md` (pin conflict with Freezed 4 / supabase_flutter / flutter_test). Providers, overrides, guards, and AsyncValueView still satisfy architecture contracts. |
| Freezed models | Auth entities + API DTOs Freezed | **PASS** |
| OpenAPI codegen client | Interim typed Dio façade | **PASS with follow-up** — allowed by plan §0.7; TODO + regen docs present; paths/schemas aligned. |
| `flutter test` | **201 passed** (independent run) | **PASS** |

Neither deviation breaks OpenSpec auth scenarios, architecture layering, or the typed-client-from-shared-network rule for features.

### 15.9 Final / OpenSpec + §13

| OpenSpec auth requirement | Status |
|---|---|
| Sign up / sign in via AuthProvider (Supabase) | Met (gateway + tests) |
| Invalid credentials | Met |
| Session persistence | Met (mocked) |
| Account settings view/update | Met |
| Frontend module boundary + barrel + design-system composition | Met |

**Product §13 checklist**

| Question | Answer for this slice |
|---|---|
| New UI widget not from design_system? | No interactive one-offs; layout + Lexivo* only (AppBar chrome soft note above) |
| Duplicate agent plumbing? | N/A |
| Call LLM/storage/auth SDK outside adapter? | No — Supabase via gateway; HTTP via ApiClient |
| Hand-write API instead of generated client? | Interim façade by plan gate — documented; not a merge blocker |
| Inlined prompts? | N/A |

Shared fixtures: `test/fixtures/` + `test/helpers/` (`FakeAuthRepository`, harness) present for reuse.

---

## Findings

### Blocking

None.

### Non-blocking follow-ups

1. **Upgrade to Riverpod 3** when dependency pins allow (`docs/api_client.md` already tracks this). Plan §15.8 / product stack still prefer 3.
2. **Replace interim Dio façade** with OpenAPI-generated dart-dio client under `TODO(openapi-codegen)`; keep `api_client.dart` as thin wrap.
3. **Barrel hygiene (optional):** `test/helpers/fake_auth_repository.dart` imports `features/auth/domain/...` directly because `AuthRepository` is not re-exported from `auth.dart`. Prefer exporting the domain repository interface on the barrel so outside-feature test helpers stay barrel-only.
4. **AppBar:** Prefer a future Lexivo top-bar atom over Material `AppBar` on account settings when design-system adds one.

---

## Proceed decision

| Question | Answer |
|---|---|
| STEP 3.7 auth + core DoD | **PASS** |
| `document_scan` may start | **Yes** — consume shared `ApiClient` document methods; compose Lexivo* only; no auth data-layer imports |
| Plan §15 checkboxes | Reviewer recommends marking 15.1–15.9 complete after this review lands |
