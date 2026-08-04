## Purpose

Defines Nexora’s shared Flutter design tokens and reusable UI components so every feature screen composes from one library with no one-off visual widgets.

## ADDED Requirements

### Requirement: Semantic design tokens
The system SHALL expose semantic color, spacing, radius, elevation, typography, and motion tokens as the sole styling source for UI, with light and dark values for every color token, and SHALL forbid raw hex or ad-hoc TextStyle values in feature code.

#### Scenario: Theme-switchable tokens
- **WHEN** the app theme switches between light and dark
- **THEN** all color tokens resolve to the matching light or dark values via the theme extension

#### Scenario: Spacing and motion scales
- **WHEN** a component applies layout spacing or animation timing
- **THEN** it MUST use the defined scales (4/8/12/16/24/32/48 spacing; 120ms/200ms/300ms motion presets)

### Requirement: Core component library
The system SHALL provide exactly these reusable components with the listed variants: Button (primary, secondary, ghost, destructive; sm/md/lg; loading), Card (flat, elevated, interactive), TextField (text, multiline, search), BottomSheet (generic, actionList, scrollable), Dialog (confirmation, alert, custom), BottomNav and NavRail (shared NavItem model), ChatBubble (user, assistant, assistantStreaming), DocumentCard (thumbnail, name, status badge, timestamp), EmptyState, ErrorBanner, Skeleton (line, card, avatar), Badge (neutral, success, warning, danger), and Snackbar (info, success, error via one global helper).

#### Scenario: Feature composes existing components
- **WHEN** a feature screen needs a button, card, input, dialog, or similar atom
- **THEN** it MUST compose the design-system component and MUST NOT introduce a new one-off visual widget

### Requirement: Design-system Definition of Done gate
The system SHALL treat the design system as incomplete until all tokens and components are implemented, golden tests pass for every component variant, a design_system_showcase catalog exists (dev-flag-gated or removable before production), and no component depends on feature-specific models.

#### Scenario: Gate before feature UI
- **WHEN** feature presentation work is requested
- **THEN** it MUST NOT proceed until the design-system Definition of Done is satisfied

### Requirement: Accessibility and responsiveness
The system SHALL meet WCAG AA contrast for light and dark token sets, enforce a minimum 44×44 touch target on interactive components, and adapt layout via shared breakpoints using the same tokens (not separate mobile/web component sets).

#### Scenario: Touch target minimum
- **WHEN** an interactive design-system control is rendered
- **THEN** its hit area MUST be at least 44×44 logical pixels
