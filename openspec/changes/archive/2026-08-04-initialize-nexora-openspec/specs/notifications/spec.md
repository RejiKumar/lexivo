## Purpose

Delivers in-app and push notifications for processing-complete and reminder events in v1, without email delivery.

## ADDED Requirements

### Requirement: In-app notifications
The system SHALL store and display in-app notifications for the authenticated user, including job-completion events for OCR, translation, export, and similar async work.

#### Scenario: Processing complete appears in-app
- **WHEN** a tracked document job completes
- **THEN** an in-app notification is created and visible in the notifications feature UI

### Requirement: Push notifications
The system SHALL send push notifications for processing-complete (and configured reminders) on platforms that support push, without requiring email.

#### Scenario: Push on job complete
- **WHEN** a job completes and the user has push enabled
- **THEN** a push notification is delivered describing the completed work

#### Scenario: No email in v1
- **WHEN** a notification event is emitted in v1
- **THEN** the system MUST NOT send email as part of that event

### Requirement: Notification Agent coordination
Notification delivery SHALL be coordinated through the Notification Agent under the Master Agent (or graph node registry), not by embedding push/provider SDKs in unrelated feature services.

#### Scenario: Agent result shape
- **WHEN** the Notification Agent runs
- **THEN** it returns AgentResult indicating delivery outcome without calling other agents directly

### Requirement: Design-system presentation
Notification list empty/error states SHALL use EmptyState and ErrorBanner from the design system.

#### Scenario: Empty inbox
- **WHEN** the user has no notifications
- **THEN** the UI shows NexoraEmptyState with an appropriate message
