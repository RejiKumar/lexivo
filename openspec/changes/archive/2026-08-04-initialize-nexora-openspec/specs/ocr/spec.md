## Purpose

Converts uploaded or scanned document images/PDFs into clean structured text via the OCR Agent and OCRProvider adapter (default: Mistral OCR).

## ADDED Requirements

### Requirement: OCR extraction through adapter
The system SHALL extract text only through the OCRProvider protocol (`extract_text`), with Mistral OCR as the launch default and Google Document AI as an alternate adapter.

#### Scenario: Successful extraction
- **WHEN** a document processing job runs OCR on a supported image or PDF
- **THEN** the system stores structured OCR text and marks OCR complete

#### Scenario: OCR failure
- **WHEN** the OCR provider fails or returns unusable output
- **THEN** the job is marked failed with an error surfaced to the user and retry is available where configured

### Requirement: OCR Agent contract
OCR processing SHALL run as an OCR Agent subclass of BaseAgent invoked only via the Master Agent graph, returning AgentResult, never via direct agent-to-agent calls.

#### Scenario: Orchestrated OCR run
- **WHEN** the Master Agent schedules OCR for a document
- **THEN** the OCR Agent `run` executes and returns success or error in AgentResult shape

### Requirement: Async job polling reuse
Long-running OCR jobs SHALL be observed on the client via the shared job poller utility, not a feature-local polling implementation.

#### Scenario: Client waits for OCR
- **WHEN** the OCR result view waits for completion
- **THEN** it uses the shared job poller and renders loading/error/data through shared async UI patterns
