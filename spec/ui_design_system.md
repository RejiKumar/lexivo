# ui_design_system.md — Lexivo Design System

> Expands `spec.md` §5. This document must be fully implemented in `core/design_system` **before any feature screen is built** (see execution order in the Cursor orchestrator prompt). Every visual element in the app is required to trace back to a component defined here. No feature PR may introduce a new visual widget that isn't either (a) an existing component variant or (b) a new component added to this system first.

---

## 1. Visual Direction

**Mood:** calm, confident, fast. Inspired by Notion, Linear, Perplexity, Arc Browser, ChatGPT, Apple Notes — studied for principles, not copied for pixels.

**Principles:**
- Minimal chrome, generous whitespace (8pt spacing scale, no arbitrary padding values)
- Glass/blur used sparingly — only on overlays (bottom sheets, command palettes), never as decoration on static content
- 60/120 FPS target on all transitions; no animation over 300ms for micro-interactions
- One primary type family for UI, optionally a second for display/marketing moments only
- Micro-interactions are subtle: button press scale (0.98), success checkmark morph, skeleton shimmer — never bouncy/playful in a way that reads as unprofessional

---

## 2. Design Tokens (single source of truth — `core/design_system/tokens/`)

### 2.1 Color tokens (semantic, never raw hex in feature code)
```
color.background.default
color.background.surface
color.background.surfaceElevated
color.background.inverse
color.content.primary
color.content.secondary
color.content.disabled
color.content.onInverse
color.border.default
color.border.focus
color.brand.primary
color.brand.primaryHover
color.brand.primaryPressed
color.feedback.success
color.feedback.warning
color.feedback.danger
color.feedback.info
```
Each token has a light and dark value. Implemented as a `LexivoColors` class exposed via `Theme.of(context).extension<LexivoColors>()`.

### 2.2 Spacing scale
```
space.xxs = 4
space.xs  = 8
space.sm  = 12
space.md  = 16
space.lg  = 24
space.xl  = 32
space.xxl = 48
```

### 2.3 Radius scale
```
radius.sm = 8
radius.md = 12
radius.lg = 16
radius.pill = 999
```

### 2.4 Elevation scale
```
elevation.0 (flat)
elevation.1 (card resting)
elevation.2 (card hover/pressed, dropdown)
elevation.3 (modal, bottom sheet)
```
Implemented as consistent `BoxShadow` presets, never inline shadow values.

### 2.5 Typography scale
```
type.display      (32/40, weight 700) — rare, marketing/empty-state headlines
type.headline      (24/32, weight 700) — screen titles
type.title          (18/24, weight 600) — section headers, card titles
type.body            (16/24, weight 400) — default reading text
type.bodyStrong      (16/24, weight 600)
type.caption          (13/18, weight 400) — metadata, timestamps
type.label             (13/18, weight 600, letter-spacing 0.2) — buttons, tags
```

### 2.6 Motion presets
```
motion.fast    = 120ms, curve: easeOut       (button press, toggle)
motion.standard = 200ms, curve: easeInOut     (page transition, expand/collapse)
motion.slow     = 300ms, curve: easeInOutCubic (modal/bottom sheet enter/exit)
```

---

## 3. Component Library (`core/design_system/components/`)

Each component below is defined **once**, with variants/props — never re-implemented per screen.

### 3.1 Button (`LexivoButton`)
- Variants: `primary`, `secondary`, `ghost`, `destructive`
- States: default, hover (web), pressed, disabled, loading (inline spinner replaces label)
- Sizes: `sm`, `md`, `lg`
- Props: `leadingIcon`, `trailingIcon`, `fullWidth`

### 3.2 Card (`LexivoCard`)
- Variants: `flat`, `elevated`, `interactive` (pressable, shows pressed-state elevation change)
- Used as the base for `DocumentCard` and any future list-item card

### 3.3 Input (`LexivoTextField`)
- Variants: `text`, `multiline`, `search` (with leading search icon + clear button)
- States: default, focused, error (with helper text slot), disabled
- Reused for: auth forms, chat input (extended, not rebuilt), search bars

### 3.4 BottomSheet (`LexivoBottomSheet`)
- Variants: `generic` (custom content), `actionList` (list of tappable actions with icons), `scrollable` (for long content, e.g. document details)

### 3.5 Dialog (`LexivoDialog`)
- Variants: `confirmation` (title, body, 2 actions), `alert` (single action), `custom` (arbitrary content slot)

### 3.6 Navigation
- `LexivoBottomNav` — mobile, up to 5 items
- `LexivoNavRail` — web/tablet, collapsible
- Both driven by the same `NavItem` model and the same `app_router.dart` route table — no duplicated nav-item lists

### 3.7 ChatBubble (`LexivoChatBubble`)
- Variants: `user`, `assistant`, `assistantStreaming` (shows animated typing/streaming state)
- Supports optional citation chips slot (reused by `rag_chat`, and any future chat-like feature)

### 3.8 DocumentCard (`LexivoDocumentCard`)
- Thumbnail + name + status badge (`processing`, `ready`, `failed`) + timestamp
- Reused in: document library grid, scan results, chat attachment previews, search results

### 3.9 EmptyState (`LexivoEmptyState`)
- Props: illustration/icon slot, title, description, optional CTA button
- Reused for: empty document library, empty chat, no search results, no notifications

### 3.10 ErrorBanner (`LexivoErrorBanner`)
- Props: message, retry callback (optional), dismiss callback (optional)
- Reused wherever `AsyncValue.error` is rendered via `core/widgets/async_value_view.dart`

### 3.11 SkeletonLoader (`LexivoSkeleton`)
- Variants: `line`, `card`, `avatar` — composed to build any screen's loading state without bespoke shimmer widgets per screen

### 3.12 Badge (`LexivoBadge`)
- Variants: `neutral`, `success`, `warning`, `danger` — used for document status, subscription tier, job state

### 3.13 Snackbar/Toast (`LexivoSnackbar`)
- Variants: `info`, `success`, `error` — one global helper (`LexivoSnackbar.show(context, ...)`), never `ScaffoldMessenger` called ad hoc with inline styling

---

## 4. Composition Rule
Feature screens are built by composing the components in §3 with feature-specific data — screens themselves contain **no new atomic widgets**, only layout (`Column`, `Row`, `Padding`, etc.) and the components above. If a screen seems to need a new atomic widget, it must be added to this document and `core/design_system` first, then consumed.

**Adaptive composition:** every feature **entry** widget picks the layout variant (`_MobileLayout` / `_TabletLayout` / `_DesktopLayout`) from the current breakpoint. Layout variants share the same Riverpod providers and design-system components; they do not introduce one-off atoms. Do not invent new shell components beyond documenting adaptive shell behavior (`LexivoBottomNav`, `LexivoNavRail`, sheets, dialogs).

### 4.1 Localization rule for components
- Component props take **strings from callers** — labels, titles, helper text, empty-state copy, button text, error messages.
- Callers obtain strings via **`AppLocalizations`** (Flutter intl / ARB). Default locale: `en`.
- **No hardcoded English** inside design-system components except an unavoidable fallback (prefer localization keys / deferred resolution over literal English). Prefer failing the build on missing ARB keys over shipping English literals in components.

---

## 5. Accessibility & Adaptive Layout

### Accessibility
- All components meet WCAG AA contrast at both light/dark token sets
- All interactive components have a minimum 44×44 touch target
- Semantic labels and focus order must be provided by callers where components expose slots; components must not strip semantics from child content

### 5.1 Adaptive layout

Breakpoints (same tokens scaled by density — **not** separate mobile/web component libraries):

| Breakpoint | Chrome | Content structure | Overlays |
| ---------- | ------ | ----------------- | -------- |
| **Mobile** | `LexivoBottomNav` | Single-column | Full-screen / modal sheets (`LexivoBottomSheet`) |
| **Tablet** | `LexivoNavRail` | Two-pane | Prefer sheets or compact dialogs as appropriate; rail stays visible |
| **Desktop / Web** | `LexivoNavRail` | Multi-pane: nav rail + list + detail | Dialogs (`LexivoDialog`), not full-screen sheets |

**Shell rules:**
- `LexivoBottomNav` (mobile) and `LexivoNavRail` (tablet/desktop) share the same `NavItem` model and router table — one source of nav destinations.
- Feature entry widgets select `_MobileLayout` / `_TabletLayout` / `_DesktopLayout`; business logic never branches on breakpoint.
- **Desktop:** support hover states on interactive components and keyboard shortcuts for primary actions; density may tighten spacing within the token scale (e.g. prefer `space.sm`/`space.md` over mobile’s more generous gaps) without inventing new token values.
- **Density:** scale spacing/typography via breakpoint multipliers on existing tokens; do not fork component implementations per platform.

---

## 6. Golden Testing Requirement
Every component in §3 must have a golden test at the component level (all variants/states). Because features only compose these components, passing golden tests here provides baseline visual regression coverage for every screen that uses them — screens do not need their own golden tests for elements already covered at the component level.

---

## 7. Definition of Done for the Design System (gate before feature work begins)
- [x] All tokens in §2 implemented and theme-switchable (light/dark)
- [x] All components in §3 implemented with all listed variants/states
- [x] Golden tests passing for every component variant
- [x] A demo/catalog screen (`design_system_showcase`) exists in the app for visual QA of every component — removed or dev-flag-gated before production release
- [x] No component depends on any feature-specific model or logic
