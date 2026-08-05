# Lexivo security

**SoT for:** auth, signed URLs, PII, rate limits/quotas, secrets, ads consent, logging redaction, OWASP notes.

**Cross-links:** [environment-strategy.md](environment-strategy.md) · [deployment-guide.md](deployment-guide.md) · [ci-cd.md](ci-cd.md) · [production-checklist.md](production-checklist.md) · [testing-strategy.md](testing-strategy.md)

---

## Auth (Supabase)

| Rule | Detail |
|---|---|
| Provider | `AUTH_PROVIDER=supabase` |
| Client | Flutter uses `SUPABASE_URL` + **anon** key only (`--dart-define`) |
| API | Validates Supabase JWT (`SUPABASE_JWT_SECRET` / JWKS as implemented); never trusts client-only claims for authorization |
| Secrets | Service role / JWT secret **server-only**; never in Flutter, never in git |
| Projects | Separate Supabase projects for development vs production ([environment-strategy.md](environment-strategy.md)) |
| OAuth | Configure redirect URLs per env (localhost, App Links, Universal Links, HTTPS web) |
| Sign in with Apple | Required for iOS if other social logins offered; prod bundle ID + Services ID |

Session: short-lived access tokens; refresh via Supabase SDK. Backend endpoints that mutate user data require valid JWT and ownership checks (document/chat/export scoped to user).

---

## Object storage & signed URLs

| Rule | Detail |
|---|---|
| Provider | Cloudflare R2 (`STORAGE_PROVIDER=r2`) |
| Buckets | Private; **no** public-read for user documents |
| Access | Time-limited **signed URLs** issued by API after authz |
| Client | Opens `signed_url` from export/document APIs only — never embeds R2 keys or uses storage SDKs in features |
| Separation | Distinct buckets per environment |

TTL: keep short (minutes). Do not log full signed URLs (they are credentials).

---

## PII & data handling

| Data | Handling |
|---|---|
| Email, name, auth IDs | Supabase + app DB; minimize copies |
| Document images / OCR text | R2 + DB; user-owned; delete paths must cover both |
| Chat / summaries / translations | User-owned; same retention/deletion story |
| Analytics (PostHog) | Prefer pseudonymous IDs; respect `ENABLE_ANALYTICS` |
| Crash (Sentry) | Scrub PII in before-send hooks |
| Ads (AdMob) | Advertising ID / ATT per platform policy |

Do not put raw document text in analytics events. Support account/data deletion for store compliance (implement before launch if required by policy).

---

## Rate limits & quotas

Free-tier caps **always enforce** (paywall flag independent):

| Resource | Default | Period |
|---|---|---|
| Documents | **20** | UTC month |
| Chat messages | **100** | UTC day |
| OCR pages | **500** | UTC month |

Env: `FREE_TIER_DOCS_PER_MONTH`, `FREE_TIER_CHAT_MESSAGES_PER_DAY`, `FREE_TIER_OCR_PAGES_PER_MONTH`.

Over quota → HTTP **429** with `quota_exceeded` detail (see [api_client.md](api_client.md)).

Additional hardening (recommended):

- Per-IP / per-user rate limits on auth-adjacent and expensive AI/OCR routes
- Cloud Run max instances + concurrency caps
- Provider key budgets (Gemini / Mistral) with alerts

`SUBSCRIPTION_PAYWALL_ENABLED` default **false** — caps still apply.

---

## Secrets management

| Do | Don't |
|---|---|
| GitHub Environments (`production` protected) | Commit `.env.*` with secrets |
| WIF for GCP where possible | Long-lived SA JSON in repo |
| Rotate keys on leak suspicion | Share prod keys into Flutter defines beyond anon/public |
| Separate keys per environment | Reuse prod Gemini/Mistral/R2 in dev casually |

Flutter may ship: Supabase **anon**, PostHog key, Sentry DSN, AdMob **app IDs** (public). Flutter must never ship: JWT secret, R2 secret, Gemini/Mistral keys, DB URLs, Cloudflare API tokens.

Full matrix: [environment-strategy.md](environment-strategy.md).

---

## Ads, consent, GDPR

| Topic | Requirement |
|---|---|
| Ads | Google **AdMob** in scope; gated by `ENABLE_ADS` |
| Consent | UMP / GDPR consent flow before personalized ads in EEA/UK as required |
| ATT (iOS) | App Tracking Transparency when using advertising identifier |
| Children | If under-13 audience possible, follow Play/App Store families policies; default Lexivo = general productivity — document audience in store listing |
| Privacy policy | Live URL before ads + analytics in production ([production-checklist.md](production-checklist.md)) |

Test ads in development; production IDs only in prod builds.

---

## Logging & redaction

| Layer | Practice |
|---|---|
| Backend | Structured logs; `APP_ENV` for telemetry only — no business-logic forks |
| Never log | Passwords, tokens, JWT, full signed URLs, raw card data (N/A), full document bodies at info level |
| Prefer | User id hash, document id, request id, status codes, latency |
| Flutter | `ENABLE_LOGGING=true` only in development; no secrets in print/debug |
| Sentry | beforeSend scrubbers for headers Authorization, cookies, email |

---

## OWASP-oriented notes (API + mobile)

| Area | Lexivo practice |
|---|---|
| Broken auth | Supabase JWT validation; no “trust anon key as admin” |
| BOLA / IDOR | Every document/chat/export/notification lookup checks ownership |
| Injection | Parameterized SQL (ORM); sanitize prompts; treat OCR/LLM output as untrusted for XSS on web |
| XSS (web) | Flutter web escape defaults; avoid `innerHTML` of model output |
| SSRF | Do not fetch arbitrary user URLs server-side without allowlists |
| Security misconfig | Private R2; TLS everywhere in prod; disable debug banners in release |
| Sensitive data exposure | HTTPS; no PII in URLs/query for docs |
| Supply chain | Pin Actions SHAs when practical; Dependabot; no untrusted PR deploy secrets |
| Insufficient logging | Health + error rates in Sentry/Cloud Logging; alert on 5xx spike |

Security test types: [testing-strategy.md](testing-strategy.md).

---

## Providers (lock)

| Concern | Choice |
|---|---|
| Auth | Supabase |
| OCR | Mistral |
| LLM | Gemini |
| Storage | R2 |
| Crash | Sentry |
| Analytics | PostHog (not Firebase Analytics) |

Email template i18n: **future only**. License docs: **skip**.
