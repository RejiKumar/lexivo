## Purpose

Enables conversational ask-the-document Q&A grounded in retrieved chunks with citations, using the RAG pipeline and Search/Citation agents.

## Requirements

### Requirement: Ask the document
The system SHALL accept a user question for a document, retrieve relevant context via the RAG pipeline, and return an answer grounded in that document.

#### Scenario: Successful Q&A
- **WHEN** an authenticated user sends a question about a ready, ingested document
- **THEN** the system returns an answer with citation references to source chunks

#### Scenario: Empty or ungrounded retrieval
- **WHEN** retrieval finds no sufficient context
- **THEN** the system responds that it cannot answer from the document rather than inventing unsupported claims

### Requirement: Chat persistence and sync
The system SHALL persist chats and messages per document and sync them across devices for the authenticated user.

#### Scenario: Resume chat
- **WHEN** the user reopens a document chat on another device
- **THEN** prior messages are available

### Requirement: Search and Citation agents
Ask flows SHALL be orchestrated by the Master Agent through Search/RAG Agent then Citation Agent, composing the final answer via LLMProvider without agent-to-agent class imports.

#### Scenario: Citation chips in UI
- **WHEN** the assistant answer includes citations
- **THEN** the Flutter rag_chat UI renders them via ChatBubble’s citation slot from the design system

### Requirement: Generated client and module boundaries
The rag_chat feature SHALL call `POST /v1/chats/{doc_id}/messages` (or equivalent OpenAPI path) only through the generated client and MUST NOT import other features’ internals.

#### Scenario: Cross-feature document id
- **WHEN** rag_chat needs document identity
- **THEN** it uses the shared core Document entity
