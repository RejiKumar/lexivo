## Purpose

Provides one parameterized RAG pipeline—chunking, embedding, hybrid retrieval, and context building—usable by chat and any future document search without per-document-type code branches.

## Requirements

### Requirement: Parameterized ingest and query
The RagPipeline SHALL expose `ingest(document, config)` and `query(document_id, question)` parameterized by RagConfig (chunk size/overlap/strategy per document type) without branching pipeline code per document type.

#### Scenario: Different configs same pipeline
- **WHEN** a contract and a receipt are ingested with different RagConfig values
- **THEN** both pass through the same chunker/embedder/retriever modules with config differences only

### Requirement: Hybrid retrieval
The system SHALL retrieve context using HybridRetriever combining pgvector similarity and BM25 keyword search in PostgreSQL, without introducing a separate vector DB product.

#### Scenario: Hybrid query
- **WHEN** a question is queried against an ingested document
- **THEN** HybridRetriever merges dense and keyword results into a ranked context set

### Requirement: Embeddings storage
Document chunks SHALL be stored with embeddings in PostgreSQL pgvector and remain queryable for RAG chat and reusable search.

#### Scenario: Ingest writes chunks
- **WHEN** ingest completes successfully
- **THEN** document_chunks rows exist with embeddings for the document

### Requirement: Reusable by features
Any feature needing document search SHALL use the RagPipeline/HybridRetriever rather than duplicating retrieval logic.

#### Scenario: Chat uses shared pipeline
- **WHEN** ChatService answers a question
- **THEN** it calls RagPipeline.query rather than embedding ad-hoc vector queries in the service
