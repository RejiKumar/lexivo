# Lexivo app versioning

**SoT for:** SemVer, soft vs force updates, minimum supported version, store/web detection, and optional API version-check contract.

**Cross-links:** [branching-strategy.md](branching-strategy.md) · [deployment-guide.md](deployment-guide.md) · [ci-cd.md](ci-cd.md) · [production-checklist.md](production-checklist.md)

---

## Semantic versioning

Lexivo uses **SemVer**: `MAJOR.MINOR.PATCH` (optional `+build`).

| Bump | When |
|---|---|
| **MAJOR** | Breaking UX/API expectations for clients; rare for consumer app |
| **MINOR** | New features, backward-compatible |
| **PATCH** | Bugfixes, hotfixes, store metadata-only if binary unchanged policy allows |

### Surfaces that must stay aligned

| Surface | Field | Notes |
|---|---|---|
| Flutter | `pubspec.yaml` `version: X.Y.Z+BUILD` | `BUILD` = monotonically increasing integer for stores |
| Android | `versionName` / `versionCode` | From Flutter version / flavor config |
| iOS | `CFBundleShortVersionString` / `CFBundleVersion` | From Flutter version |
| Web | Same Flutter version in build; optional meta tag | Cache-bust via Cloudflare |
| Git | Tag `vX.Y.Z` on ship commit | Triggers / records production release |
| Backend API | OpenAPI / route version ` /api/v1` | Independent of app SemVer; breaking API → new path or coordinated force update |

Never reuse a store `versionCode` / `CFBundleVersion`.

---

## Soft update vs force update

| Mode | User experience | When to use |
|---|---|---|
| **Soft** | Banner / dialog: “Update available” with Later + Update | Optional improvements, non-critical fixes |
| **Force** | Blocking screen; only Update (or store link); app unusable until updated | Security, broken auth, incompatible API, critical data bugs |

Both are **in scope** for Lexivo. Subscription paywall flag is unrelated — update gates apply to all tiers.

### Minimum supported version (MSV)

Server (or remote config) publishes:

- `min_supported_version` — below this → **force**
- `latest_version` — below this but ≥ MSV → **soft** (optional)
- `store_url_android` / `store_url_ios` / `web_reload_hint`

Compare using SemVer precedence (ignore build metadata for policy; use build only for store uniqueness).

---

## Platform detection

### Android (Play)

1. App reads own `versionName` / package info.
2. Calls version-check API (or Play in-app updates as enhancement).
3. Soft → Play Store listing / in-app update flexible; Force → immediate update / block UI.
4. Tracks: internal → closed → open → production (see [deployment-guide.md](deployment-guide.md)).

### iOS (App Store / TestFlight)

1. Same package-info + version-check API.
2. Soft → App Store URL; Force → block until update.
3. TestFlight builds may use higher build numbers; policy can exempt `ENV=development` or TestFlight via define/flag if needed — default: **same rules as prod** for release candidates.

### Web (Cloudflare Pages)

1. On startup / resume, fetch version-check (or `version.json` next to assets).
2. Soft → toast “Refresh for latest”; Force → full-page “Please reload” (service worker / cache clear guidance).
3. Prefer short cache TTLs on `index.html`; hashed assets immutable.

---

## API contract (version check)

Implement when force/soft UI ships. Suggested endpoint (auth optional):

```http
GET /api/v1/app/version
```

Example response:

```json
{
  "latest_version": "1.2.0",
  "min_supported_version": "1.0.0",
  "soft_update_message": "A new version of Lexivo is available.",
  "force_update_message": "Please update Lexivo to continue.",
  "android": {
    "latest_version": "1.2.0",
    "min_supported_version": "1.0.0",
    "store_url": "https://play.google.com/store/apps/details?id=com.lexivo.lexivo"
  },
  "ios": {
    "latest_version": "1.2.0",
    "min_supported_version": "1.0.0",
    "store_url": "https://apps.apple.com/app/idXXXXXXXX"
  },
  "web": {
    "latest_version": "1.2.0",
    "min_supported_version": "1.0.0"
  }
}
```

### Client algorithm

```text
current = package_info.version
platform = android | ios | web
policy = response[platform] ?? response root

if current < policy.min_supported_version → FORCE
else if current < policy.latest_version → SOFT
else → OK
```

Values live in backend Settings / env (e.g. `MIN_SUPPORTED_APP_VERSION`, `LATEST_APP_VERSION`) or a small admin table — **not** hardcoded in Flutter release binaries beyond a reasonable offline fallback (fail open to OK for soft; fail closed only if explicitly required for security incidents).

OpenAPI: add to snapshot when implemented; PR enforces snapshot ([ci-cd.md](ci-cd.md)).

---

## Release checklist (versioning slice)

- [ ] Bump `pubspec.yaml` version + build
- [ ] Confirm Android/iOS numbers
- [ ] Update server `latest_version` / MSV if policy changes
- [ ] Tag `vX.Y.Z` on `main`
- [ ] Ship stores / Pages; verify soft/force copy

Full launch gates: [production-checklist.md](production-checklist.md).
