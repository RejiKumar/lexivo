# Lexivo testing strategy

**SoT for:** test types, tools, coverage expectations, adaptive layout, l10n, and how tests map to CI.

**Cross-links:** [ci-cd.md](ci-cd.md) · [security.md](security.md) · [app-versioning.md](app-versioning.md) · [deployment-guide.md](deployment-guide.md)

---

## Principles

- Test behavior at the lowest layer that catches the bug; prefer unit over full E2E when possible.
- Features talk to typed API client / gateways — mock those boundaries; never hit live Gemini/Mistral/R2 in unit CI.
- Business-logic coverage target: **≥ 80%** (domain, use cases, quota, authz helpers, reducers). UI chrome may sit lower.
- Flaky tests are failures: quarantine or fix; do not ignore in `main`.

---

## Test pyramid

| Layer | Scope | Tools | CI |
|---|---|---|---|
| **Unit** | Domain, mappers, validators, QuotaService, Riverpod notifiers (logic) | `flutter_test`, `pytest`, `mocktail` / `mockito`, `respx` / `httpx` ASGI | Required |
| **Widget** | Screens/components with fakes | `flutter_test`, golden optional | Required |
| **Integration** | Multi-feature flows with fake API or testcontainers | `integration_test`, pytest + TestClient | Required subset; full suite nightly/manual OK |
| **Golden** | Design-system & critical widgets | `matchesGoldenFile` | Required for DS; update deliberately |
| **a11y** | Semantics, contrast, tap targets | `flutter_test` semantics / `AccessibilityGuideline` | Sampled required |
| **Perf** | Scroll jank, build times, API latency budgets | DevTools, timeline, backend timers | Manual / periodic |
| **API** | OpenAPI contract, authz, quotas, error shapes | pytest + snapshot script | Required |
| **AI prompt** | Prompt templates, grounding rules, refusal paths | pytest with recorded fixtures / fake LLM | Required for Master/agent pure logic |
| **OCR** | Parsing, page counts, failure mapping | pytest + fixture images (small) | Required unit; live Mistral = manual/staging |
| **RAG** | Retrieval + citation assembly | pytest with fake embeddings/store | Required |
| **Security** | IDOR, JWT reject, signed URL expiry, secret scan | pytest, `gitleaks`/Actions | Required subset |
| **Load** | Health + hot paths under concurrency | `k6` / `locust` (choose one) | Manual / pre-launch |
| **Smoke** | Post-deploy health + login shell | curl + short checklist | After deploy |

---

## Flutter

### Unit & widget

```bash
flutter test
flutter test --coverage
# optional: lcov filter to lib/features + lib/core (exclude generated)
```

- Prefer fakes for `ApiClient`, auth gateway, repositories.
- Test `AppConfig` / dart-define readers without network.
- Subscription: default paywall **off**; quota **429** mapping → `QuotaFailure`.

### Golden

- Stable theme/locale/text scaler; run on consistent CI OS or commit platform-specific goldens with care.
- Showcase catalog behind `LEXIVO_SHOWCASE` — not required in release tests.

### Integration

```bash
flutter test integration_test/
```

Cover: sign-in happy path (mocked Supabase or test project), document upload→status poll, chat send, export signed URL open (mock).

### Adaptive layout

- Assert breakpoints / `LayoutBuilder` branches for phone / tablet / wide web.
- Widget tests with controlled `tester.view.physicalSize` + `devicePixelRatio`; reset in `tearDown`.
- Critical flows must not overflow (`overflow` exceptions fail CI).

### l10n

- Generate localizations in CI before tests if needed.
- Unit-test ARB keys exist for required locales; smoke one screen per locale (or golden per locale for DS).
- **Email template i18n:** future only — out of scope for app l10n tests now.
- RTL: at least one smoke with `TextDirection.rtl` if shipping RTL locales.

### a11y

- `meetsGuideline(textContrastGuideline)` / tap target guidelines on primary CTAs.
- Semantics labels on icon-only buttons.

### Ads / updates

- When `ENABLE_ADS`: unit-test consent gate does not load ads before consent.
- Soft/force update UI: widget tests for each mode ([app-versioning.md](app-versioning.md)).

---

## Backend (Python)

```bash
cd backend
pytest
pytest --cov=app --cov-fail-under=80   # tune omit generated/migrations
```

| Area | Expectations |
|---|---|
| API | Auth required where declared; 401/403/404/409/422/429 shapes stable |
| Quotas | 20 / 100 / 500 defaults; paid skips; flag off still caps |
| OCR / LLM | Provider Protocol fakes; no real keys in CI |
| RAG | Citation integrity; ungrounded “cannot answer” still 200 |
| Security | Cross-user document access denied; export URL not enumerable |
| OpenAPI | Snapshot check in CI ([ci-cd.md](ci-cd.md)) |
| Celery | Eager mode in unit tests; one worker smoke in Compose manually |

---

## AI / OCR / RAG specifics

| Type | Do | Don't |
|---|---|---|
| Prompt unit | Assert system instructions, tool schemas, safety rails with fixtures | Call live Gemini on every PR |
| OCR | Fixture bytes → expected page count / error mapping | Upload huge PDFs in CI |
| RAG | Fake vector hits → citations present on assistant message | Depend on prod Neon vectors |

Live provider checks: manual or staging smoke with budget caps.

---

## Security tests (subset)

- JWT missing/invalid → 401
- User A cannot read User B document/chat/export/notification
- Quota enforcement under concurrent requests (basic)
- Secrets: fail CI if `.env` committed (gitignore + optional scanner)
- See [security.md](security.md)

---

## Load & smoke

**Load (pre-launch):** `GET /api/v1/health`, authenticated document list, one OCR enqueue path — define SLO (e.g. p95 health < 300ms at N VUs). Run from operator machine against staging/prod-shaped env, not PR.

**Smoke (after deploy):**

- [ ] `GET /api/v1/health` → ok
- [ ] Web shell loads
- [ ] Auth redirect configured
- [ ] One document upload (staging/dev) or dry-run in prod with care

---

## Coverage policy

| Target | Threshold |
|---|---|
| Business logic (domain, services, quota, authz) | **≥ 80%** line (or branch where practical) |
| Widgets / pages | Best effort; critical paths covered |
| Generated / DI boilerplate | Exclude from gate |

Enforce via planned **coverage** composite ([ci-cd.md](ci-cd.md)); until then, track locally and raise in review.

---

## Mapping to CI jobs

| Test type | Job |
|---|---|
| analyze / format / lint | lint (+ format planned) |
| unit / widget / golden / a11y sample | test-flutter |
| API / AI / OCR / RAG / security unit | test-python |
| OpenAPI | openapi-snapshot |
| integration_test | optional job or nightly |
| iOS UI | macos runner later |
| load | manual |
| smoke | post-deploy / notify checklist |
