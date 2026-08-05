## Purpose

Defines breakpoint-driven adaptive UI so Lexivo ships purpose-built mobile, tablet, and desktop/web layouts — not phone layouts stretched to large screens.

## ADDED Requirements

### Requirement: Adaptive app shell chrome
The app shell SHALL present bottom navigation on mobile breakpoints and a navigation rail on tablet and desktop/web breakpoints, both driven by the same navigation item model and the same router destination table.

#### Scenario: Mobile uses bottom navigation
- **WHEN** the viewport is at the mobile breakpoint
- **THEN** primary chrome is the design-system bottom navigation and MUST NOT show the nav rail as primary chrome

#### Scenario: Tablet and desktop use nav rail
- **WHEN** the viewport is at tablet or desktop/web breakpoint
- **THEN** primary chrome is the design-system navigation rail driven by the same nav items and routes as mobile

### Requirement: Feature layout variants by breakpoint
Every feature screen entry SHALL select among purpose-built mobile, tablet, and desktop layout variants from the current breakpoint. Responsive scaling of a single phone layout alone is insufficient.

#### Scenario: Entry selects layout variant
- **WHEN** a feature screen entry builds
- **THEN** it renders the mobile, tablet, or desktop layout variant matching the breakpoint and MUST NOT use one phone layout stretched to larger sizes as the only adaptation

#### Scenario: Shared providers across layouts
- **WHEN** mobile, tablet, and desktop layout variants render the same feature
- **THEN** they consume the same state providers and business logic — providers and domain logic MUST NOT branch on breakpoint

### Requirement: Breakpoint-specific structure and overlays
Mobile layouts SHALL be single-column with overlays as full-screen or modal sheets. Tablet layouts SHALL support two-pane composition with the rail visible. Desktop/web layouts SHALL support multi-pane composition (nav rail + list + detail), hover affordances, and keyboard shortcuts where applicable, with overlays as dialogs rather than full-screen sheets.

#### Scenario: Mobile overlay uses sheet
- **WHEN** a confirmatory or secondary flow opens on mobile
- **THEN** it uses a sheet (or full-screen modal) pattern rather than a desktop-style centered dialog as the primary pattern

#### Scenario: Desktop overlay uses dialog
- **WHEN** a confirmatory or secondary flow opens on desktop/web
- **THEN** it uses a dialog pattern rather than a full-screen sheet as the primary pattern

#### Scenario: Desktop multi-pane
- **WHEN** a list-and-detail feature is shown on desktop/web
- **THEN** list and detail can appear together in a multi-pane layout rather than forcing navigation away for every detail view
