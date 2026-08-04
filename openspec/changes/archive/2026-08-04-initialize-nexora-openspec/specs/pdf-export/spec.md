## Purpose

Exports summary, translation, and chat-annotation content as a clean PDF with per-section toggles via the Export/PDF Agent path.

## ADDED Requirements

### Requirement: Multi-section PDF export
The system SHALL generate a PDF that can include summary, translation, and chat annotations in one export, controlled by per-section toggles on the export request.

#### Scenario: Export all sections
- **WHEN** the user enables summary, translation, and chat annotations and confirms export
- **THEN** the generated PDF includes all selected sections

#### Scenario: Export subset
- **WHEN** the user enables only summary
- **THEN** the PDF includes summary content and omits translation and chat annotations

### Requirement: Export Agent and storage
PDF generation SHALL run through the Export Agent under the Master Agent, store the artifact via StorageProvider, and return a signed URL for download.

#### Scenario: Signed download
- **WHEN** export completes successfully
- **THEN** the client receives a time-limited signed URL and does not require public bucket access

### Requirement: Async export jobs
Export SHALL be treatable as a long-running job polled with the shared job poller and completable with a processing-complete notification.

#### Scenario: Export failure
- **WHEN** PDF generation fails
- **THEN** the job is marked failed and the user can retry
