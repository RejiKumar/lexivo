## Purpose

Lets users capture or upload documents on mobile and web through one DocumentInputSource abstraction with edge detection/crop where camera capture is available.

## ADDED Requirements

### Requirement: Unified document input source
The system SHALL provide a single DocumentInputSource abstraction that supports camera capture when the platform exposes getUserMedia/camera APIs and falls back to file upload everywhere else, without forking UI per platform.

#### Scenario: Camera available
- **WHEN** the user starts a scan on a device/browser with camera access granted
- **THEN** the system presents camera capture with edge detection and crop

#### Scenario: Camera unavailable
- **WHEN** camera capture is unavailable or denied
- **THEN** the system offers file upload as the input path through the same abstraction

### Requirement: Document creation after capture
The system SHALL create a document record, upload the image/PDF via StorageProvider, and enqueue processing without feature code calling storage SDKs directly.

#### Scenario: Successful capture upload
- **WHEN** the user confirms a cropped capture or selected file
- **THEN** the document is stored, a job is queued, and the document appears with a processing status

### Requirement: Document library presentation
The system SHALL display documents using DocumentCard (thumbnail, name, status badge, timestamp) from the design system across library, scan results, and attachment previews.

#### Scenario: Status reflection
- **WHEN** a document job moves between processing, ready, and failed
- **THEN** the DocumentCard status badge updates to match

### Requirement: Shared Document entity
Shared document identity needed by other features (OCR, summarization, translation, rag-chat, export) SHALL live in core entities so features do not import document-scan internals.

#### Scenario: Cross-feature document reference
- **WHEN** rag-chat needs a document identity owned by scan/upload
- **THEN** it depends on the shared core entity, not on document-scan data or presentation layers
