## ADDED Requirements

### Requirement: Adaptive rag_chat layouts
The rag_chat feature entry SHALL provide purpose-built mobile, tablet, and desktop layout variants selected by breakpoint, sharing the same chat providers and design-system ChatBubble composition.

#### Scenario: Mobile chat single-column
- **WHEN** ask-the-document chat opens on a mobile breakpoint
- **THEN** it uses a single-column chat layout with sheet-style overlays where needed

#### Scenario: Desktop chat multi-pane
- **WHEN** ask-the-document chat opens on a desktop/web breakpoint
- **THEN** it supports multi-pane composition (for example document context + conversation) rather than phone-stretched-only layout

#### Scenario: Same providers across chat layouts
- **WHEN** chat layout variants send or display messages
- **THEN** they consume the same chat providers and MUST NOT branch business logic on breakpoint
