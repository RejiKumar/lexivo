# Lexivo branching strategy

**SoT for:** branch roles, merge flow, hotfixes, and how versioning tags relate to releases.

**Cross-links:** [ci-cd.md](ci-cd.md) · [app-versioning.md](app-versioning.md) · [deployment-guide.md](deployment-guide.md) · [environment-strategy.md](environment-strategy.md)

---

## Principles

- Solo founder: keep the graph simple; protect `main`.
- Integration branch is **`dev`**. Long-lived production tip is **`main`**.
- Environment differences are secrets/vars only — not branch-named code forks.
- **Staging branch:** documented for later; not required now.

---

## Branch roles

| Branch pattern | Lifetime | Role | Typical CI |
|---|---|---|---|
| `main` | Permanent | Production-ready code; protected | Checks + **production** deploy (when ready) |
| `dev` | Permanent | Integration / day-to-day tip | Full CI (lint, test, build); optional non-prod deploy |
| `feature/<short-name>` | Short | New work from `dev` | PR checks |
| `bugfix/<short-name>` | Short | Non-urgent fixes from `dev` | PR checks |
| `hotfix/<short-name>` | Short | Urgent prod fix from `main` | PR checks → fast path to `main` + back-merge `dev` |
| `release/<x.y.z>` | Short | Release hardening / freeze from `dev` | Checks; merge to `main`; tag |
| `staging` | Later | Optional pre-prod tip | Deploy to staging Environment |

Naming: lowercase kebab-case after the prefix (`feature/doc-export-ui`).

---

## Merge strategy

### Day-to-day

```text
feature/* or bugfix/*
        │
        ▼  PR (required checks)
       dev
        │
        ▼  release/* (optional) or PR
       main   ──► production (protected Environment)
```

1. Branch from **`dev`** for features and bugfixes.
2. Open PR **into `dev`**. Require green PR workflow (see [ci-cd.md](ci-cd.md)).
3. When ready to ship: cut `release/x.y.z` from `dev` **or** PR `dev` → `main` after smoke.
4. Merge to **`main`** only via PR (or controlled release merge). Trigger production deploy from `main` / tag `v*` / `workflow_dispatch` with Environment approval.
5. After release, ensure `dev` contains everything on `main` (merge `main` → `dev` if needed).

### Why PR into `dev` first

- Keeps `main` quiet and releasable.
- Allows unfinished work on `dev` without blocking hotfixes on `main`.

---

## Hotfix

1. Branch `hotfix/<name>` from **`main`**.
2. PR into **`main`** (tight review; same required checks as feasible).
3. Tag SemVer patch (`vX.Y.Z+1`) per [app-versioning.md](app-versioning.md).
4. Deploy production.
5. **Back-merge** `main` → `dev` immediately so the fix is not lost.

Do not hotfix only on `dev` and hope it reaches prod later.

---

## Release branches

Use `release/x.y.z` when you need a freeze window (store assets, version bumps, last bugfixes) without blocking new features on `dev`.

- Only version bumps, changelog, critical fixes on the release branch.
- Merge release → `main`, tag, deploy.
- Merge release (or `main`) back → `dev`.

---

## Staging branch (later)

When a true staging Environment exists ([environment-strategy.md](environment-strategy.md)):

- Option A: deploy `dev` (or `release/*`) to GitHub Environment `staging`.
- Option B: long-lived `staging` branch that tracks near-`main` candidates.

Prefer **Environment-based** deploys over inventing divergent code. Branch `staging` is optional sugar.

---

## Protection rules (manual, GitHub)

**`main`**

- Require PR; dismiss stale reviews on new commits.
- Required status checks: Flutter/Python lint & test, OpenAPI snapshot, workflow-contract, backend image build (as available).
- Restrict who can push (solo: only you; still use PRs for history).
- No force-push; no direct deploy from forks.

**`dev`**

- Prefer PR + same checks; allow slightly looser if solo speed requires — still keep checks green before merge when possible.

---

## Tags and SemVer

- Annotated tags `vMAJOR.MINOR.PATCH` on `main` commits that ship.
- Production workflow already listens to `v*` tags; keep that contract.
- Client store versions and force/soft update policy: **[app-versioning.md](app-versioning.md)** (single SoT).

---

## Interim note (current vs target)

Today `main.yml` still targets a **staging** GitHub Environment for deploy jobs. Target state:

- **`dev`** → CI (+ optional non-prod deploy)
- **`main`** → **production** (protected)

Migration path: [ci-cd.md](ci-cd.md#migration-path-interim-staging-on-main).
