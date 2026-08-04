## Purpose

Translates extracted document text between English and ES, FR, DE, HI, and PT through the Translation Agent and shared LLMProvider.

## ADDED Requirements

### Requirement: Supported language pairs
The system SHALL support translation between English and Spanish, French, German, Hindi, and Portuguese for v1, with language codes validated on the API.

#### Scenario: Translate to supported language
- **WHEN** a user requests translation of document text into a supported target language
- **THEN** the system returns translated text in that language

#### Scenario: Unsupported language
- **WHEN** a user requests an unsupported target language
- **THEN** the system rejects the request with a validation error

### Requirement: Translation Agent orchestration
Translation SHALL run via the Translation Agent under the Master Agent only, with versioned prompts from the shared prompts directory.

#### Scenario: Orchestrated translation
- **WHEN** the Master Agent schedules translation
- **THEN** the Translation Agent returns AgentResult with translated content and does not call other agents directly

### Requirement: Async translation jobs
Translation MAY run as a Celery-backed async job; clients SHALL poll via the shared job poller and present progress with design-system loading/error patterns.

#### Scenario: Job completion notification hook
- **WHEN** a translation job completes
- **THEN** the system can emit a processing-complete notification event for the notifications capability
