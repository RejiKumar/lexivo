## ADDED Requirements

### Requirement: Premium ads-suppress signal
The subscription capability SHALL expose a clear premium (or equivalent ads-suppressed) signal consumable by the shared ads adapter so premium users never see ads, without requiring the paywall UI to be enabled.

#### Scenario: Premium suppresses ads while paywall flag off
- **WHEN** a user is premium (or marked ads-suppressed) and the subscription paywall feature flag is off
- **THEN** the ads adapter still receives a suppress signal and MUST NOT show ads

#### Scenario: Free tier does not suppress
- **WHEN** a user is free-tier and not otherwise ads-suppressed
- **THEN** the suppress signal is false and ads eligibility is left to the ads flag and consent gates
