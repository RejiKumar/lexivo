## Purpose

Generates short and detailed AI summaries of OCR’d documents through the Summary Agent and shared LLMProvider (default: Gemini).

## ADDED Requirements

### Requirement: Short and detailed summaries
The system SHALL produce both a short summary and a detailed summary for a ready document, persisted and syncable across devices.

#### Scenario: Request summaries
- **WHEN** an authenticated user requests summarization for a document with completed OCR
- **THEN** the system returns short and detailed summaries grounded in the document text

#### Scenario: Document not ready
- **WHEN** summarization is requested before OCR is complete
- **THEN** the system rejects the request with a clear not-ready error

### Requirement: Summary Agent via orchestrator
Summarization SHALL execute only through the Summary Agent under the Master Agent graph, using shared prompts and LLMProvider—never a hardcoded provider SDK in the agent or route.

#### Scenario: Successful summary agent run
- **WHEN** the Master Agent invokes the Summary Agent
- **THEN** AgentResult contains summary payloads and metadata without direct calls to other agents

### Requirement: Feature module isolation
The Flutter summarization feature SHALL compose UI from design-system components and communicate with the backend only through the generated API client.

#### Scenario: No ad-hoc network calls
- **WHEN** the summarization feature loads or triggers summaries
- **THEN** it uses the generated typed client exclusively
