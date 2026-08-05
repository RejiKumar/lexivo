## ADDED Requirements

### Requirement: Adaptive navigation chrome composition
The design system SHALL expose BottomNav and NavRail that share one NavItem model so the app shell can switch chrome by breakpoint without inventing feature-local navigation atoms.

#### Scenario: Shared nav item model
- **WHEN** the app shell builds mobile bottom navigation or tablet/desktop nav rail
- **THEN** both consume the same NavItem definitions and MUST NOT require duplicate destination models

### Requirement: Localized string props on components
Design-system components that display user-facing text SHALL accept that text as string props (or slots) from callers; components MUST NOT hardcode user-facing copy inside the atom.

#### Scenario: Button and empty state copy from caller
- **WHEN** a feature renders a Button label or EmptyState title/body
- **THEN** the copy is supplied by the caller from localizations and is not baked into the component implementation
