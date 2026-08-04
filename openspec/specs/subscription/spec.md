## Purpose

Enforces configurable usage limits and a paid tier that is fully built but feature-flagged off at launch so enabling paywall later is a flag flip.

## Requirements

### Requirement: Feature-flagged subscription
The system SHALL implement subscription/paywall flows behind a feature flag that is off at launch, hiding paid upgrade UI while still enforcing configurable free-tier caps in the backend.

#### Scenario: Flag off hides paywall UI
- **WHEN** the subscription feature flag is disabled
- **THEN** upgrade/paywall screens are not shown to end users

#### Scenario: Flag on reveals paywall
- **WHEN** the subscription feature flag is enabled
- **THEN** users at limit can see upgrade paths for the paid tier

### Requirement: Configurable free-tier caps
The system SHALL enforce free-tier limits as configuration (not hardcoded constants): 20 documents per month, 100 chat messages per day, and 500 OCR pages per month by default.

#### Scenario: Document monthly cap
- **WHEN** a free-tier user exceeds 20 documents in the current month
- **THEN** further document creates are rejected with a quota error

#### Scenario: Chat daily cap
- **WHEN** a free-tier user exceeds 100 chat messages in the current day
- **THEN** further messages are rejected with a quota error

#### Scenario: OCR pages monthly cap
- **WHEN** a free-tier user exceeds 500 OCR pages in the current month
- **THEN** further OCR processing is rejected with a quota error

### Requirement: Quota middleware reuse
Rate limiting and quota enforcement SHALL be applied via shared API middleware/gateway logic, not reinvented per endpoint.

#### Scenario: Consistent quota response
- **WHEN** any capped action exceeds its limit
- **THEN** the API returns a consistent quota-exceeded error shape
