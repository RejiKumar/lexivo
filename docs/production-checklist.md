# Lexivo production checklist

**SoT for:** pre-launch readiness. Single checklist — no separate `PRE_LAUNCH` file.

**Cross-links:** [deployment-guide.md](deployment-guide.md) · [environment-strategy.md](environment-strategy.md) · [ci-cd.md](ci-cd.md) · [security.md](security.md) · [app-versioning.md](app-versioning.md) · [testing-strategy.md](testing-strategy.md)

Mark each item before first public production traffic. Solo founder: complete in any order within a section; do not skip Security or Legal.

---

## Accounts & keys

- [ ] Google Cloud project (Cloud Run) + billing alerts
- [ ] Cloudflare account (Pages + R2 + DNS)
- [ ] Neon production database + PITR
- [ ] GHCR package permissions for Actions
- [ ] Supabase **production** project
- [ ] Gemini API key (prod) + budget alert
- [ ] Mistral API key (prod) + budget alert
- [ ] Sentry projects (Flutter + backend) or shared with clear env tags
- [ ] PostHog project (prod)
- [ ] GitHub Environment **`production`** with required reviewers
- [ ] Workload Identity Federation (or temporary `GCP_SA_KEY` with rotation plan)

---

## Auth & OAuth

- [ ] Supabase URL + anon key wired as Flutter dart-defines (prod)
- [ ] `SUPABASE_JWT_SECRET` (or JWKS validation) on Cloud Run only
- [ ] Email magic link / OAuth providers enabled as product requires
- [ ] Redirect URLs: HTTPS web, Android App Links, iOS Universal Links / custom scheme
- [ ] **Sign in with Apple** configured if required by Apple policy
- [ ] Separate dev vs prod Supabase projects (no prod users on dev)

---

## App identity

- [ ] Android `applicationId` = `com.lexivo.lexivo` (prod)
- [ ] iOS bundle ID = `com.lexivo.lexivo` (prod)
- [ ] App display name (`APP_NAME=Lexivo`)
- [ ] Launcher icons (all densities / App Store)
- [ ] Splash / launch screen final brand
- [ ] Adaptive icon / monochrome as required by stores

---

## Deep links & domains

- [ ] Production domains chosen (web + `api.`)
- [ ] DNS on Cloudflare; SSL valid
- [ ] `API_BASE_URL` points at prod API
- [ ] `assetlinks.json` (Android) verified
- [ ] `apple-app-site-association` (iOS) verified
- [ ] Supabase redirect allowlist matches

---

## Build configs (Flutter)

- [ ] `ENV=production`
- [ ] `ENABLE_LOGGING=false`
- [ ] `ENABLE_ANALYTICS=true` (when PostHog ready)
- [ ] `ENABLE_CRASH_REPORTING=true` (when Sentry ready)
- [ ] `ENABLE_ADS` = intended launch value
- [ ] `AI_PROVIDER=gemini` / `OCR_PROVIDER=mistral`
- [ ] `SUBSCRIPTION_PAYWALL_ENABLED=false` (until paid launch)
- [ ] `LEXIVO_SHOWCASE=false`
- [ ] Sentry DSN / PostHog key+host set at **build** time
- [ ] Release signing (Android keystore in CI; iOS certs on Mac runner)

---

## Backend & data

- [ ] Cloud Run API + worker deployed from GHCR sha
- [ ] Neon `DATABASE_URL` prod; migrations applied
- [ ] Redis / Celery broker prod URLs
- [ ] R2 prod bucket private; credentials on Cloud Run only
- [ ] Free-tier quotas: **20** docs/month, **100** chat/day, **500** OCR pages/month
- [ ] Health check green: `GET /api/v1/health`
- [ ] OpenAPI snapshot matches deployed API

---

## AI / OCR

- [ ] Gemini key restricted (HTTP referrer / IP / API restrictions as applicable)
- [ ] Mistral key restricted
- [ ] Failure paths tested (provider down → user-safe error)
- [ ] No provider keys in Flutter

---

## Analytics & crash

- [ ] Sentry receiving release builds (source maps/symbols if applicable)
- [ ] PostHog events firing only when enabled
- [ ] PII scrubbing verified ([security.md](security.md))
- [ ] Alert on new crash spike

---

## Ads (AdMob)

- [ ] AdMob apps + ad units for Android/iOS (and web if used)
- [ ] Production ad unit IDs (not test) only in prod builds
- [ ] UMP / GDPR consent flow verified in EEA
- [ ] ATT string / prompt on iOS if required
- [ ] `ENABLE_ADS` aligned with store disclosure

---

## Updates

- [ ] Soft / force update UX implemented or explicitly deferred with date
- [ ] `min_supported_version` / `latest_version` configured when API exists ([app-versioning.md](app-versioning.md))
- [ ] Store listing URLs correct
- [ ] Web cache policy allows force refresh

---

## Legal & support

- [ ] Privacy policy URL live
- [ ] Terms of service URL live
- [ ] Contact / support email or form
- [ ] Store data-safety / privacy nutrition labels match actual SDK set
- [ ] Account deletion / data export path as required by policy

---

## Store assets

### Play

- [ ] AAB uploaded; Play App Signing on
- [ ] Feature graphic, screenshots, description, short description
- [ ] Content rating questionnaire
- [ ] Target API / policy compliance
- [ ] Staged rollout plan

### App Store

- [ ] Screenshots per required device sizes
- [ ] Description, keywords, support URL, marketing URL
- [ ] Review notes (test account if auth-walled)
- [ ] Export compliance / encryption answers

### Web

- [ ] Favicon / PWA icons
- [ ] `robots.txt` / `sitemap.xml` as needed
- [ ] Custom domain on Pages

---

## Feature flags & known offs

- [ ] Subscription paywall **off**
- [ ] Showcase **off**
- [ ] Email template i18n **not** required for launch (future)
- [ ] Staging Environment **optional** (later) — prod path does not depend on it
- [ ] License doc **skipped**

---

## CI / branch readiness

- [ ] `main` protected; production Environment approval on
- [ ] Migration path understood: prefer **dev CI**, **main → production** ([ci-cd.md](ci-cd.md))
- [ ] Rollback owner knows GHCR sha + Pages rollback ([deployment-guide.md](deployment-guide.md))
- [ ] Smoke checklist executed post-deploy

---

## Final smoke (prod)

- [ ] Health OK
- [ ] Web loads over HTTPS
- [ ] Sign-in works
- [ ] Upload → OCR status path works (one real doc)
- [ ] Chat or summary smoke (cost-aware)
- [ ] No secrets in client logs
- [ ] Sentry/PostHog show the release

When all critical boxes are checked, cut the production tag and ship.
