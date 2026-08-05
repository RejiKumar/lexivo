## Purpose

Enforces server-driven soft and force app upgrades so clients below the minimum supported version cannot continue, while older-but-supported clients can dismiss an optional update prompt.

## ADDED Requirements

### Requirement: Version policy evaluation
The system SHALL compare the client’s current SemVer (ignoring build metadata for policy) against remote policy fields `min_supported_version` and `latest_version` and classify the result as force upgrade, soft upgrade, or OK.

#### Scenario: Below minimum supported version forces upgrade
- **WHEN** the current app version is lower than `min_supported_version`
- **THEN** the client enters a blocking force-upgrade state and MUST NOT allow normal app use until updated

#### Scenario: Below latest but at or above MSV soft-prompts
- **WHEN** the current app version is at or above `min_supported_version` and below `latest_version`
- **THEN** the client shows a dismissible soft-update prompt and the user MAY continue using the app

#### Scenario: Current equals or exceeds latest
- **WHEN** the current app version is greater than or equal to `latest_version`
- **THEN** no upgrade prompt is shown

### Requirement: Version-check API consumption
The client SHALL obtain upgrade policy via `GET /api/v1/app/version` (auth optional) and apply platform-specific policy blocks (android / ios / web) when present, falling back to root policy fields when a platform block is absent.

#### Scenario: Platform-specific store URLs
- **WHEN** a soft or force upgrade is required on Android or iOS
- **THEN** the Update action uses the platform store URL from the version response

#### Scenario: Web refresh guidance
- **WHEN** a soft or force upgrade is required on web
- **THEN** soft offers a refresh/reload hint and force presents a blocking reload experience appropriate for web cache-bust

### Requirement: Shared upgrade module and design-system UI
Upgrade policy evaluation and platform checkers SHALL live in a shared app-upgrade module; soft and force UI SHALL compose design-system dialogs/sheets and MUST NOT be reimplemented inside individual features.

#### Scenario: Feature does not own upgrade logic
- **WHEN** any feature screen is shown
- **THEN** soft/force upgrade gating is handled by the shared upgrade module and shell — features MUST NOT embed their own version-check logic

### Requirement: Offline and failure behavior
When the version-check request fails, the client SHALL fail open to OK for soft-update purposes by default, and MUST NOT hard-block the user unless an explicit security fail-closed policy is configured for an incident.

#### Scenario: Network failure fails open
- **WHEN** `GET /api/v1/app/version` fails due to network or server error under default policy
- **THEN** the app continues without a soft-update prompt and does not force-block the user
