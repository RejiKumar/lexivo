## Purpose

Provides a client ads adapter so free-tier placements load through one AdMob-backed provider with consent gating, feature-flag control, and mandatory suppression for premium users.

## ADDED Requirements

### Requirement: AdsProvider adapter surface
Client ads SHALL go only through a shared AdsProvider adapter. Features and screens MUST NOT call the AdMob SDK (or equivalent) directly. Supported formats SHALL include app open, banner, native, rewarded, and interstitial.

#### Scenario: Feature requests banner via adapter
- **WHEN** a free-tier screen needs a banner placement
- **THEN** it composes the adapter’s banner API with a placement id and MUST NOT import the AdMob SDK in feature code

#### Scenario: Swap or disable implementation
- **WHEN** operators disable ads or change the concrete provider binding
- **THEN** feature call sites require no changes beyond the shared adapter configuration

### Requirement: ENABLE_ADS feature flag
Ads loading and display SHALL be gated by an `ENABLE_ADS` flag. When the flag is off, no ad inventory is requested or shown.

#### Scenario: Flag off suppresses all ads
- **WHEN** `ENABLE_ADS` is false
- **THEN** no ad formats initialize or render, regardless of free-tier status

### Requirement: GDPR and consent gate
The system SHALL complete the required consent flow (UMP/GDPR for EEA/UK as applicable, and ATT on iOS when using the advertising identifier) before loading personalized ads. Until consent allows personalized ads, the provider MUST NOT load personalized inventory.

#### Scenario: Consent required before personalized ads
- **WHEN** the user is in a region requiring consent and has not completed the consent flow
- **THEN** personalized ads are not loaded

#### Scenario: Consent obtained
- **WHEN** consent status allows personalized ads and `ENABLE_ADS` is true for a free-tier user
- **THEN** the provider may initialize and show eligible placements

### Requirement: Premium suppression
Ads MUST be suppressed for premium / subscribed users. The ads module SHALL honor a premium (or equivalent suppress) signal from subscription state without features deciding ad visibility ad hoc.

#### Scenario: Premium user sees no ads
- **WHEN** the user is marked premium (or ads-suppressed) even if `ENABLE_ADS` is true
- **THEN** no ad surfaces render

#### Scenario: Free user with ads enabled
- **WHEN** the user is free-tier, `ENABLE_ADS` is true, and consent allows ads
- **THEN** configured placements may render via the adapter

### Requirement: Child-safety restrictions
When the app is in a child-directed or family-safe context, the ads provider MUST NOT request personalized ads or sensitive categories and SHALL follow store and AdMob child-directed treatment requirements.

#### Scenario: Child-directed treatment
- **WHEN** child-directed / family-safe mode is active
- **THEN** personalized advertising is not requested
