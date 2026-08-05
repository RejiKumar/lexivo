# Lexivo deployment guide

**SoT for:** shipping Android, iOS, Web, and backend to production — accounts, signing, DNS, Cloud Run, release/rollback/DR, monitoring.

**Cross-links:** [environment-strategy.md](environment-strategy.md) · [ci-cd.md](ci-cd.md) · [security.md](security.md) · [production-checklist.md](production-checklist.md) · [app-versioning.md](app-versioning.md) · [branching-strategy.md](branching-strategy.md)

---

## Hosting map (locked)

| Surface | Platform |
|---|---|
| API + Celery worker | **Google Cloud Run** (same GHCR image; worker command override) |
| Web | **Cloudflare Pages** |
| Database | **Neon** Postgres (+ pgvector as used by app) |
| Objects | **Cloudflare R2** (private + signed URLs) |
| Images | **GHCR** (`ghcr.io/<owner>/lexivo-backend`) |
| Auth | **Supabase** |
| OCR / LLM | **Mistral** / **Gemini** |

Environments: **Development + Production** now; Staging later with minimal change — [environment-strategy.md](environment-strategy.md).

---

## Android (Google Play)

### Tracks

| Track | Use |
|---|---|
| Internal testing | Smoke with trusted testers |
| Closed testing | Wider QA |
| Open testing | Optional public beta |
| Production | Staged rollout (e.g. 10% → 100%) |

Promote AAB upward; do not upload debug APKs to production.

### Keystore & signing

1. Create upload keystore (`keytool`); store password + key in password manager.
2. Keep **upload** key for Play App Signing; Google holds app signing key.
3. CI: decode keystore from GitHub secret (`ANDROID_KEYSTORE_BASE64`), use `key.properties` / Gradle env — **never commit** keystore or passwords.
4. Backup keystore offline; loss without Play App Signing recovery = cannot update app.

### SHA certificates

Register SHA-1 / SHA-256 for **debug** and **release/upload** in:

- Supabase Auth (Google provider if used)
- Google Cloud (if Maps/APIs)
- Android App Links Digital Asset Links

### Application ID

Production: `com.lexivo.lexivo`. Dev variant target: `com.lexivo.lexivo.dev` — [environment-strategy.md](environment-strategy.md).

### App Links

1. Host `/.well-known/assetlinks.json` on the verified HTTPS domain (Pages or API domain as chosen).
2. Declare intent filters in AndroidManifest (`autoVerify=true`).
3. Verify with Google’s statement list tester.

### Build artifacts

CI composites produce APK (sideload/QA) and **AAB** (Play). Versioning: [app-versioning.md](app-versioning.md).

### Ads

AdMob app ID + ad unit IDs via dart-define / platform manifests; `ENABLE_ADS`; consent — [security.md](security.md).

---

## iOS (Apple)

### Account

- Apple Developer Program (Organization or Individual).
- App Store Connect app record; bundle ID `com.lexivo.lexivo` (prod).

### Certificates & profiles

| Asset | Purpose |
|---|---|
| Distribution certificate | App Store / TestFlight |
| Development certificate | Device debug |
| Provisioning profiles | Match App ID + devices / distribution |
| Push (APNs) key | Notifications (`.p8` preferred over legacy certs) |

Prefer **App Store Connect API key** for CI notarization/upload. Store `.p8`, Key ID, Issuer ID in GitHub Environment secrets.

### Sign in with Apple

Required if other third-party logins are offered. Enable on App ID; configure Services ID + return URLs for web; wire Supabase Apple provider.

### Push

APNs key → backend PushProvider (when implemented). Separate keys/apps per environment if using `.dev` bundle ID.

### TestFlight → App Store

1. Archive / `flutter build ipa` on **macOS** runner ([ci-cd.md](ci-cd.md)).
2. Upload to App Store Connect; process build.
3. Internal → external TestFlight; then submit for review.
4. Privacy nutrition labels, export compliance, ATT if ads.

### Force / soft update

Store URLs in version-check payload — [app-versioning.md](app-versioning.md).

---

## Web (Cloudflare Pages)

### DNS & SSL

1. Domain on Cloudflare DNS.
2. Pages custom domain → automatic SSL (Full / Full strict to origin as applicable).
3. API: map `api.<domain>` to Cloud Run (Cloudflare proxy optional; if proxied, configure timeouts for long requests).

### CDN / caching

- `index.html`: short TTL / bypass so force updates apply.
- Hashed Flutter assets: long cache immutable.
- Invalidate/replace via new Pages deployment (prefer over manual purge).

### PWA

- Ensure `manifest.json`, icons, theme color for installability if shipping PWA.
- Service worker: prefer Flutter/web defaults; plan update UX for force reload ([app-versioning.md](app-versioning.md)).

### SEO / robots / sitemap

| File | Guidance |
|---|---|
| `robots.txt` | Allow marketing pages; disallow private app routes if needed |
| `sitemap.xml` | Public marketing URLs only |
| Meta | Title/description per index; Open Graph as needed |

App shell behind auth is not a SEO target; marketing landing may be separate later.

### Deploy

`.github/actions/deploy-cloudflare-pages` with Environment secrets: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_PAGES_PROJECT`. Build-time dart-defines from Environment — [environment-strategy.md](environment-strategy.md).

---

## Backend (Cloud Run + Neon + R2)

### Services

| Service | Image | Command |
|---|---|---|
| API | GHCR sha tag | default `uvicorn … --port 8000` |
| Worker | Same image | `celery -A app.tasks.celery_app worker --loglevel=info` |

Health: `GET /api/v1/health`.

### Scaling

- Set min instances (0 for cost, ≥1 for fewer cold starts on API if budget allows).
- Max instances + concurrency caps for cost/safety.
- Worker: scale on queue depth / CPU; separate service from API.
- Memory/CPU sized for OCR/LLM orchestration (I/O bound); raise if OOM.

### Secrets & env

Inject from GitHub Environment → deploy composite. Prefer **Workload Identity Federation**. Never bake secrets into the image. Backend files `.env.development` / `.env.production` are local references only — [environment-strategy.md](environment-strategy.md).

Critical secrets: `DATABASE_URL`, `REDIS_URL`, `CELERY_BROKER_URL`, `SUPABASE_*`, `R2_*`, `GEMINI_API_KEY`, `MISTRAL_API_KEY`, `SENTRY_DSN`, `POSTHOG_*`.

### Database (Neon)

- Separate databases per environment.
- Run migrations as a controlled job/release step (document exact command in backend README; do not auto-downgrade).
- Enable PITR / backups on production branch.
- Connection pooling (Neon pooler) for Cloud Run concurrency.

### R2

- Private buckets per env; API issues signed URLs after authz ([security.md](security.md)).
- CORS only if browser uploads direct (prefer API multipart if that is the design).

### Logging

- Cloud Run → Cloud Logging; correlate with `request_id` / user id (non-PII).
- Sentry when `SENTRY_DSN` set; redact tokens ([security.md](security.md)).

---

## Release checklist (ops)

Use together with [production-checklist.md](production-checklist.md) and [app-versioning.md](app-versioning.md).

1. Green CI on release commit; OpenAPI snapshot clean.
2. Version bumped; tag `vX.Y.Z` on `main` when shipping.
3. Migrations applied to target DB.
4. Deploy API → worker → web (or parallel web if API compatible).
5. Smoke: health, web shell, auth callback, one non-destructive API call.
6. Play / TestFlight / App Store submit as needed.
7. Notify (when notify composite exists).
8. Watch Sentry/PostHog/error rates for 30–60 minutes.

---

## Rollback

| Layer | Action |
|---|---|
| Cloud Run | Redeploy previous GHCR digest to API + worker (`:sha` or known-good) |
| Pages | Rollback deployment in Cloudflare or redeploy prior artifact |
| Mobile | Halt staged rollout; promote prior release track if available; use force update only if broken binary must be abandoned |
| DB | Prefer forward fix; restore Neon PITR if migration corrupted data — **manual** |

CI support: planned rollback composite — [ci-cd.md](ci-cd.md).

---

## Disaster recovery (DR)

| Asset | RPO / practice |
|---|---|
| Neon | PITR enabled; test restore annually (or before launch) |
| R2 | Versioning/replication if critical; know bucket region |
| Secrets | Password manager + GitHub; rotate after incident |
| GHCR | Immutable sha tags retain prior images |
| Runbooks | This doc + [security.md](security.md) incident notes |

Define RTO informally for solo founder (e.g. restore API within hours). Document status page/contact later if needed.

---

## Monitoring & analytics

| Signal | Tool |
|---|---|
| Crashes | Sentry (Flutter + backend); `ENABLE_CRASH_REPORTING` / DSN |
| Product analytics | PostHog; `ENABLE_ANALYTICS` |
| Infra | Cloud Run metrics (latency, 5xx, instance count), Neon metrics |
| Uptime | External ping on `/api/v1/health` (optional UptimeRobot/Better Stack) |
| Quotas / AI cost | Provider dashboards + budget alerts |

Not Firebase Analytics. Empty keys = no-op locally/CI.

---

## Interim CI note

`main.yml` may still deploy to Environment name **`staging`**. Target: **`dev` CI**, **`main` → production**. Follow [ci-cd.md](ci-cd.md#migration-path-interim-staging-on-main).

---

## Local backend reminder

```bash
cd backend
cp .env.example .env.development
docker compose up --build
curl http://127.0.0.1:8000/api/v1/health
```

Same image contract as Cloud Run.
