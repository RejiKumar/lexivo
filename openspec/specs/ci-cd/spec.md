## Purpose

Provides reusable GitHub Actions composite workflows for lint, test, build, and deploy of Flutter (web/mobile artifacts) and FastAPI/Celery to Cloud Run with Cloudflare Pages for web.

## Requirements

### Requirement: Reusable composite workflows
CI/CD SHALL be implemented as reusable GitHub Actions composite workflows (lint, test, build, deploy) that environment-specific pipelines call, without copy-pasting job definitions per environment.

#### Scenario: PR pipeline
- **WHEN** a pull request is opened
- **THEN** lint and tests run for Flutter and Python before merge eligibility

### Requirement: Build and deploy targets
The pipeline SHALL support Flutter analyze/test, Flutter web build deployable to Cloudflare Pages, Android APK/AAB build artifacts, Python pytest, Docker backend image build, and deploy of API/workers to Cloud Run.

#### Scenario: Main branch deploy
- **WHEN** CI passes on main
- **THEN** web and backend can auto-deploy to the configured staging or production targets

### Requirement: Environment configuration
local, staging, and production environments SHALL be config-driven via environment variables (pydantic-settings on backend), with local Docker Compose for Postgres+pgvector, Redis, backend, and Celery worker.

#### Scenario: No hardcoded env branches
- **WHEN** deploying to staging vs production
- **THEN** behavior differences come from env config, not forked code paths

### Requirement: Observability hooks
Production deployments SHALL wire Sentry and analytics (PostHog) as part of the releasable pipeline Definition of Done for v1.

#### Scenario: Error reporting available
- **WHEN** the backend or Flutter client runs in production configuration
- **THEN** Sentry is configured to receive runtime errors
