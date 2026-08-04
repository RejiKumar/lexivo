# Design System — Task Plan
Capability: design-system
Architecture: architecture.md §2.2
UI Spec: ui_design_system.md §2–§7
OpenSpec: openspec/specs/design-system/spec.md
Product: Lexivo
Execution order: STEP 3.2 / archived tasks §2 (gate before any feature UI)

**Conventions**
- Prefixes: `Lexivo*` only (`LexivoButton`, `LexivoColors`, …) — never `Nexora*`.
- Loop per chunk: failing test → implement → widget/golden test → review (ui_design_system + OpenSpec design-system + reusability checklist) → fix → commit.
- No component may depend on feature-specific models; shared presentation models (e.g. `NavItem`, document-card display props) live under `core/design_system`.
- Brand mood: calm, confident, fast. Concrete palette/typefaces are chosen in token work and documented in the same PR/commit notes.

---

## 0. Flutter scaffold

- [x] 0.1 Create Flutter app project named `lexivo` (display name **Lexivo**) at repo root (or agreed `apps/lexivo` if monorepo layout is preferred); confirm `pubspec.yaml` name is `lexivo`
- [x] 0.2 Scaffold empty `lib/core/` tree per architecture.md §2.2: `design_system/{tokens,components,theme}/`, `network/`, `routing/`, `theming/`, `utils/`, `widgets/` — stub files only, no feature packages yet
- [x] 0.3 Add test deps and harness: `flutter_test`, golden helpers (e.g. `alchemist` or project-standard golden setup), `test/flutter_test_config.dart` / golden directory conventions for design-system goldens
- [x] 0.4 Wire minimal `MaterialApp` + placeholder home so `flutter test` / `flutter run` succeed on empty scaffold
- [x] 0.5 Review scaffold vs architecture.md §2.2 and product name Lexivo; fix gaps; commit scaffold

---

## 1. Tokens

### 1.A Brand documentation (before locking values)

- [x] 1.1 Document chosen brand tokens in `core/design_system/tokens/BRAND.md` (or equivalent notes committed with tokens): primary palette hex (light/dark), secondary/neutral ramps, feedback colors, primary + optional display typeface names/sources, rationale vs “calm, confident, fast”
- [x] 1.2 Review brand doc against ui_design_system.md §1–§2 mood/principles; revise; commit brand doc

### 1.B Color tokens (§2.1)

- [x] 1.3 Write failing unit tests for all semantic color tokens (light + dark values for every key in §2.1) and `ThemeExtension<LexivoColors>` resolution
- [x] 1.4 Implement `LexivoColors` in `tokens/color.dart` with light/dark factories; expose via theme extension only (no raw hex in consumers)
- [x] 1.5 Review colors vs §2.1 + WCAG AA contrast notes; fix; commit

### 1.C Spacing + radius (§2.2–§2.3)

- [x] 1.6 Write failing unit tests for spacing scale (xxs…xxl) and radius scale (sm, md, lg, pill)
- [x] 1.7 Implement `LexivoSpacing` / `LexivoRadius` in `tokens/spacing.dart` and `tokens/radius.dart`
- [x] 1.8 Review vs §2.2–§2.3; fix; commit

### 1.D Elevation (§2.4)

- [x] 1.9 Write failing unit tests for elevation.0–elevation.3 as named `BoxShadow` presets (no ad-hoc shadows)
- [x] 1.10 Implement `LexivoElevation` in `tokens/elevation.dart`
- [x] 1.11 Review vs §2.4; fix; commit

### 1.E Typography (§2.5)

- [x] 1.12 Write failing unit tests for type scale: display, headline, title, body, bodyStrong, caption, label (sizes/weights/letter-spacing per §2.5)
- [x] 1.13 Implement `LexivoTypography` / `TextTheme` mapping in `tokens/typography.dart` using documented typefaces
- [x] 1.14 Review vs §2.5 + brand doc; fix; commit

### 1.F Motion (§2.6)

- [x] 1.15 Write failing unit tests for motion.fast / standard / slow (durations + curves per §2.6)
- [x] 1.16 Implement `LexivoMotion` in `tokens/motion.dart`
- [x] 1.17 Review vs §2.6; fix; commit

### 1.G Theme assembly

- [x] 1.18 Write failing unit/widget tests that light and dark `ThemeData` switch and resolve `LexivoColors` + typography from tokens
- [x] 1.19 Implement `design_system/theme/` + `core/theming/app_theme.dart` assembling ThemeData from tokens (light/dark)
- [x] 1.20 Review theme switchability vs OpenSpec “Theme-switchable tokens”; fix; commit

---

## 2. LexivoButton (§3.1)

- [x] 2.1 Write failing widget tests for variants (`primary`, `secondary`, `ghost`, `destructive`), sizes (`sm`, `md`, `lg`), states (default, pressed, disabled, loading), props (`leadingIcon`, `trailingIcon`, `fullWidth`), and ≥44×44 touch target
- [x] 2.2 Implement `LexivoButton` in `components/button.dart` using tokens only
- [x] 2.3 Add golden tests for every variant × size × key state (incl. loading, disabled); capture baselines
- [x] 2.4 Review vs §3.1 + a11y; fix; commit

---

## 3. LexivoCard (§3.2)

- [x] 3.1 Write failing widget tests for variants `flat`, `elevated`, `interactive` (pressed elevation change)
- [x] 3.2 Implement `LexivoCard` in `components/card.dart`
- [x] 3.3 Golden tests for all three variants (default + pressed for interactive)
- [x] 3.4 Review vs §3.2; fix; commit

---

## 4. LexivoTextField (§3.3)

- [x] 4.1 Write failing widget tests for variants `text`, `multiline`, `search` (leading search icon + clear); states default, focused, error (+ helper text), disabled
- [x] 4.2 Implement `LexivoTextField` in `components/input.dart`
- [x] 4.3 Golden tests for all variants × key states
- [x] 4.4 Review vs §3.3; fix; commit

---

## 5. LexivoBadge (§3.12)

- [x] 5.1 Write failing widget tests for variants `neutral`, `success`, `warning`, `danger`
- [x] 5.2 Implement `LexivoBadge` in `components/badge.dart`
- [x] 5.3 Golden tests for all four variants
- [x] 5.4 Review vs §3.12; fix; commit

---

## 6. LexivoSkeleton (§3.11)

- [x] 6.1 Write failing widget tests for variants `line`, `card`, `avatar` (shimmer uses motion tokens)
- [x] 6.2 Implement `LexivoSkeleton` in `components/skeleton_loader.dart`
- [x] 6.3 Golden tests for all three variants (static frame acceptable if shimmer is deterministic in goldens)
- [x] 6.4 Review vs §3.11; fix; commit

---

## 7. LexivoErrorBanner (§3.10)

- [x] 7.1 Write failing widget tests for message + optional retry + optional dismiss
- [x] 7.2 Implement `LexivoErrorBanner` in `components/error_banner.dart`
- [x] 7.3 Golden tests: message-only, with retry, with dismiss, with both
- [x] 7.4 Review vs §3.10; fix; commit

---

## 8. LexivoEmptyState (§3.9)

- [x] 8.1 Write failing widget tests for illustration/icon slot, title, description, optional CTA (`LexivoButton`)
- [x] 8.2 Implement `LexivoEmptyState` in `components/empty_state.dart` composing design-system atoms only
- [x] 8.3 Golden tests: with/without CTA, with icon vs illustration slot
- [x] 8.4 Review vs §3.9; fix; commit

---

## 9. LexivoSnackbar (§3.13)

- [x] 9.1 Write failing widget/integration tests for `LexivoSnackbar.show(context, …)` variants `info`, `success`, `error` (assert no ad-hoc `ScaffoldMessenger` styling outside helper)
- [x] 9.2 Implement `LexivoSnackbar` in `components/snackbar.dart`
- [x] 9.3 Golden tests for all three variants
- [x] 9.4 Review vs §3.13; fix; commit

---

## 10. LexivoDialog (§3.5)

- [x] 10.1 Write failing widget tests for variants `confirmation` (title, body, 2 actions), `alert` (single action), `custom` (content slot)
- [x] 10.2 Implement `LexivoDialog` in `components/dialog.dart` (actions via `LexivoButton`)
- [x] 10.3 Golden tests for confirmation, alert, custom
- [x] 10.4 Review vs §3.5; fix; commit

---

## 11. LexivoBottomSheet (§3.4)

- [x] 11.1 Write failing widget tests for variants `generic`, `actionList`, `scrollable`
- [x] 11.2 Implement `LexivoBottomSheet` in `components/bottom_sheet.dart` (glass/blur only if used as overlay per §1)
- [x] 11.3 Golden tests for all three variants
- [x] 11.4 Review vs §3.4; fix; commit

---

## 12. Navigation — LexivoBottomNav + LexivoNavRail (§3.6)

- [x] 12.1 Write failing unit tests for shared `NavItem` model (design-system owned, not feature models) and widget tests that BottomNav (≤5 items) and NavRail (collapsible) consume the same item list
- [x] 12.2 Implement `NavItem`, `LexivoBottomNav`, `LexivoNavRail` in `components/nav_bar.dart` (or split files with barrel); stub route ids as strings for later `app_router` binding — no feature imports
- [x] 12.3 Golden tests: BottomNav (≤5 items, selected states); NavRail expanded + collapsed
- [x] 12.4 Review vs §3.6 + OpenSpec shared NavItem requirement; fix; commit

---

## 13. LexivoChatBubble (§3.7)

- [x] 13.1 Write failing widget tests for variants `user`, `assistant`, `assistantStreaming`; optional citation chips slot (generic chip widgets / slots — no rag feature models)
- [x] 13.2 Implement `LexivoChatBubble` in `components/chat_bubble.dart`
- [x] 13.3 Golden tests for user, assistant, assistantStreaming (+ citation slot occupied)
- [x] 13.4 Review vs §3.7; fix; commit

---

## 14. LexivoDocumentCard (§3.8)

- [x] 14.1 Write failing widget tests for thumbnail + name + status badge (`processing`, `ready`, `failed` via `LexivoBadge`) + timestamp; props are plain display data only
- [x] 14.2 Implement `LexivoDocumentCard` in `components/document_card.dart` composing `LexivoCard` + `LexivoBadge`
- [x] 14.3 Golden tests for all three status states (and missing-thumbnail fallback if defined)
- [x] 14.4 Review vs §3.8 + “no feature-specific models”; fix; commit

---

## 15. design_system_showcase (§7)

- [x] 15.1 Write failing smoke/widget test that showcase route renders when dev flag is on and is unavailable (or no-op) when flag is off
- [x] 15.2 Implement `design_system_showcase` catalog screen covering every §3 component and major variants; register behind a compile-time / env / `--dart-define` (or equivalent) **dev flag**
- [x] 15.3 Manual QA pass via showcase + fix visual gaps; commit showcase

---

## 16. Cross-cutting a11y & responsiveness (§5 / OpenSpec)

- [ ] 16.1 Add/extend tests asserting WCAG AA contrast for critical token pairs (content on background, brand primary on content) light + dark
- [ ] 16.2 Audit interactive components for ≥44×44 hit targets; fix any failures
- [ ] 16.3 Confirm breakpoint adaptation uses shared tokens (document Responsive Framework wiring or stub breakpoints in theme); review; commit

---

## Final. Definition of Done gate

- [ ] F.1 Checklist: all §2 tokens implemented and theme-switchable (light/dark)
- [ ] F.2 Checklist: all §3 components + listed variants/states implemented (`LexivoButton`, `LexivoCard`, `LexivoTextField`, `LexivoBottomSheet`, `LexivoDialog`, `LexivoBottomNav`, `LexivoNavRail`, `LexivoChatBubble`, `LexivoDocumentCard`, `LexivoEmptyState`, `LexivoErrorBanner`, `LexivoSkeleton`, `LexivoBadge`, `LexivoSnackbar`)
- [ ] F.3 Checklist: golden tests passing for every component variant
- [ ] F.4 Checklist: `design_system_showcase` exists and is dev-flag-gated
- [ ] F.5 Checklist: grep/architecture review — no design-system file imports `features/`; no feature-specific models in components
- [ ] F.6 Final review against ui_design_system.md §7 + openspec/specs/design-system/spec.md + nexora_spec.md reusability checklist; fix remaining gaps; commit “design-system DoD met” — **feature UI work may begin only after this**

---

## Coverage matrix (planner verification)

| §3 Component | Plan section | Variants covered in tasks |
|---|---|---|
| Button | §2 | primary, secondary, ghost, destructive; sm/md/lg; loading + states |
| Card | §3 | flat, elevated, interactive |
| TextField | §4 | text, multiline, search; error/disabled/focused |
| BottomSheet | §11 | generic, actionList, scrollable |
| Dialog | §10 | confirmation, alert, custom |
| BottomNav | §12 | ≤5 items, shared NavItem |
| NavRail | §12 | collapsible, shared NavItem |
| ChatBubble | §13 | user, assistant, assistantStreaming + citation slot |
| DocumentCard | §14 | processing, ready, failed status |
| EmptyState | §8 | icon/illustration, optional CTA |
| ErrorBanner | §7 | retry/dismiss optional |
| Skeleton | §6 | line, card, avatar |
| Badge | §5 | neutral, success, warning, danger |
| Snackbar | §9 | info, success, error global helper |

| §2 Tokens | Plan section |
|---|---|
| Color (light/dark) | 1.B |
| Spacing | 1.C |
| Radius | 1.C |
| Elevation | 1.D |
| Typography | 1.E |
| Motion | 1.F |
| Theme assembly | 1.G |
| Brand documentation | 1.A |

**Task count:** 89 checkbox tasks (0.1–0.5 = 5; 1.1–1.20 = 20; components §2–§14 = 4×13 = 52; 15.1–15.3 = 3; 16.1–16.3 = 3; F.1–F.6 = 6).
