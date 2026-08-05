## ADDED Requirements

### Requirement: App version check endpoint
The backend SHALL expose `GET /api/v1/app/version` (authentication optional) returning latest and minimum supported SemVer values, optional soft/force messages, and platform-specific blocks for android, ios, and web including store URLs where applicable. Values SHALL be driven by Settings/environment configuration (for example `MIN_SUPPORTED_APP_VERSION`, `LATEST_APP_VERSION`, store URL settings) and MUST NOT be hardcoded only in client binaries.

#### Scenario: Version policy response shape
- **WHEN** a client calls `GET /api/v1/app/version`
- **THEN** the response includes `latest_version`, `min_supported_version`, and platform blocks consistent with the app-versioning contract

#### Scenario: Settings-driven MSV and latest
- **WHEN** operators change minimum supported or latest app version in Settings/env
- **THEN** subsequent version-check responses reflect the new policy without a client app release

#### Scenario: OpenAPI includes version route
- **WHEN** the version-check endpoint is added
- **THEN** the OpenAPI snapshot is updated in the same change set so the typed client can include the route (no full codegen rewrite required)
