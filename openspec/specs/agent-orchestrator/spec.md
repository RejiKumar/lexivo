## Purpose

Defines the shared BaseAgent contract, Master Agent LangGraph orchestration, and all specialized agents so AI work is independent, testable, and never agent-to-agent coupled.

## Requirements

### Requirement: BaseAgent contract
Every specialized agent SHALL subclass BaseAgent with a name and async `run(input, context) -> AgentResult`, sharing default `on_error` retry/error shaping, logging/tracing hooks, and AgentResult fields (success, data, error, metadata).

#### Scenario: New agent implements only run
- **WHEN** a new specialized agent is added
- **THEN** it implements `run` against BaseAgent and does not copy another agent’s plumbing

### Requirement: Master Agent orchestration only
Agents SHALL never call other agent classes directly; the Master Agent LangGraph graph SHALL sequence OCR, Summary, Translation, Search/RAG, Citation, Export, Security, Notification, and Analytics agents via the node registry.

#### Scenario: Reject direct agent coupling
- **WHEN** a code change imports one specialized agent from another specialized agent to invoke it
- **THEN** that change violates this capability and MUST be rejected in review

### Requirement: Shared prompts and LLM access
Prompts SHALL live in a central versioned prompts directory loaded by a shared prompt loader; model calls SHALL go only through LLMProvider (Gemini default, OpenAI fallback adapter).

#### Scenario: No inlined prompts
- **WHEN** an agent needs a prompt template
- **THEN** it loads a versioned template from prompts/ rather than inlining prompt text in code

### Requirement: Specialized agent set
The system SHALL provide OCR, Summary, Translation, Search, Citation, Export, Security, Notification, and Analytics agents, each independently testable and replaceable.

#### Scenario: Swap translation model binding
- **WHEN** the Translation Agent’s model binding changes via LLMProvider config
- **THEN** other agents require no code changes
