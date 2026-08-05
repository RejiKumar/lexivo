## ADDED Requirements

### Requirement: Adaptive document library layouts
The document library entry screen SHALL provide purpose-built mobile, tablet, and desktop layout variants selected by breakpoint, sharing the same document list providers and design-system DocumentCard composition.

#### Scenario: Mobile library single-column
- **WHEN** the document library opens on a mobile breakpoint
- **THEN** it uses a single-column library layout with mobile-appropriate overlays

#### Scenario: Desktop library multi-pane
- **WHEN** the document library opens on a desktop/web breakpoint
- **THEN** it supports a multi-pane list-and-detail composition rather than phone-stretched-only layout

#### Scenario: Same providers across library layouts
- **WHEN** library layout variants render documents
- **THEN** they read the same Riverpod/document providers and MUST NOT fork domain logic by breakpoint
