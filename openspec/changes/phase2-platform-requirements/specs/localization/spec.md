## Purpose

Provides Flutter intl/ARB localization with English as the default locale so every user-facing string is resource-backed and new locales can be added without rewriting screens.

## ADDED Requirements

### Requirement: Default English ARB localization
The system SHALL use Flutter intl/ARB as the sole localization mechanism with default locale `en`, and SHALL expose generated localizations to the app widget tree so screens and design-system callers can resolve strings by key.

#### Scenario: App starts in English
- **WHEN** the app launches with no alternate locale selected
- **THEN** all localized UI strings resolve from the English ARB resources

#### Scenario: Adding a locale is resources-only
- **WHEN** a new supported locale is added
- **THEN** only ARB/resource files and locale registration change — feature and design-system widgets MUST NOT fork per language

### Requirement: Zero hardcoded user-facing strings
Feature and design-system UI MUST NOT embed hardcoded user-facing copy; callers SHALL pass strings from localizations (or string props sourced from localizations). Non-user-facing technical identifiers (route names, analytics event keys, log tags) MAY remain hardcoded.

#### Scenario: New UI copy goes through ARB
- **WHEN** a developer adds or changes user-visible label, button, error, empty-state, or dialog text
- **THEN** the string is defined in ARB and referenced via localizations — not as a string literal in the widget

#### Scenario: Progressive migration of existing screens
- **WHEN** existing screens still contain hardcoded user-facing strings at the start of this change
- **THEN** the system provides a documented migration pattern and Wave work migrates strings incrementally without blocking shell/foundation landing

### Requirement: Localization lives in shared core
Localization tooling, generated localizations, and shared string helpers SHALL live under shared core localization (not inside individual features), and features SHALL depend only on that shared surface.

#### Scenario: Feature imports shared localizations
- **WHEN** a feature needs a user-facing string
- **THEN** it obtains it from the shared core localization API and MUST NOT define a private per-feature string table for UI copy
