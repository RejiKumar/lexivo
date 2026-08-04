# Design System DoD Review — Lexivo

| Field | Value |
|---|---|
| **Capability** | design-system |
| **Reviewer** | Reviewer Agent |
| **Date** | 2026-08-04 |
| **Sources** | `spec/ui_design_system.md` §3–§7, `spec/architecture.md` §2.2, `openspec/specs/design-system/spec.md`, product reusability §13, plan F.1–F.6 |
| **Verdict** | **REJECT** |

---

## Verdict

**REJECT** — DoD is not fully met. Feature UI work must wait until required fixes below land and a re-review passes.

**Feature UI / backend next step may proceed?** **No** for feature presentation UI. Backend / non-UI core work is out of scope for this gate and is not blocked by this review.

---

## Checklist results

| # | Check | Result |
|---|---|---|
| 1 | All Lexivo* §3 components exist with listed variants/states | **FAIL** — hover (web) missing on `LexivoButton` |
| 2 | No `design_system` file imports `features/` | **PASS** |
| 3 | No feature-specific domain models in components | **PASS** (`NavItem`, `LexivoDocumentStatus` are DS-owned display models) |
| 4 | Tokens used (no raw hex in components) | **FAIL** — non-token magic values in components (see findings) |
| 5 | Golden tests present for components | **PASS** (13 golden suites; all §3 components covered) |
| 6 | Showcase exists and is flag-gated | **PASS** (`LEXIVO_SHOWCASE` / `LexivoDesignSystemFlags`) |
| 7 | `flutter test` green | **PASS** (144 tests, exit 0) |
| 8 | Prefixes are `Lexivo*` not `Nexora*` | **PASS** (implementation); archived OpenSpec text still says Nexora — docs only |

---

## Findings

### High — required for PASS

- **`LexivoButton` missing hover (web) state (§3.1 / F.2)**  
  Spec lists states: default, hover (web), pressed, disabled, loading. Implementation only tracks pressed via `onHighlightChanged`. `LexivoColors.brandPrimaryHover` exists and is wired into `ThemeData.colorScheme.secondary` but is never applied by the button. No `MouseRegion` / hover tracking.

### Medium — required for PASS (token discipline)

- **`LexivoDocumentCard` uses raw radius `BorderRadius.circular(8)`** instead of `LexivoRadius.sm` (`document_card.dart`).
- **`LexivoBadge` ad-hoc `fontSize: 12`** overrides `LexivoTypography.label` (13) without a typography token (`badge.dart`).
- **`LexivoNavRail` compact label uses ad-hoc `fontSize: 11` / `SizedBox(height: 2)` / icon `size: 22`** instead of spacing/typography tokens (`nav_bar.dart`).
- **`LexivoBottomSheet.show` uses `barrierColor: Colors.black54`** — not a semantic token (`bottom_sheet.dart`). Prefer a tokenized scrim (e.g. content/inverse at fixed alpha) or document an approved exception in tokens.

### Low — advisory (not alone blocking)

- `Colors.transparent` used for Material scaffolding in several components — acceptable scaffolding, not hex.
- Archived OpenSpec under `openspec/changes/archive/...` still references `Nexora*` / NexoraEmptyState; live `openspec/specs/design-system/spec.md` correctly says Lexivo. No code prefix issue.
- Button goldens cover variants × sizes × disabled/loading but not pressed/hover frames (acceptable if hover is covered by widget tests once implemented).

---

## What already meets DoD

- All 14 §3 component surfaces present under `lib/core/design_system/components/` with correct `Lexivo*` names and listed **variants** (button sizes/variants, card, text field, sheets, dialogs, nav, chat, document card, empty, error, skeleton, badge, snackbar).
- §2 tokens + light/dark `LexivoTheme` / `AppTheme` assembly; brand doc in `tokens/BRAND.md`.
- Zero `features/` imports from design_system; no feature domain entities in components.
- Goldens for every §3 component; showcase catalog gated by `--dart-define=LEXIVO_SHOWCASE=true`.
- `flutter test`: **All tests passed!** (144).

---

## Remediation tasks (Design System Agent)

1. **Add web hover state to `LexivoButton`**
   - Track hover separately from pressed (e.g. `MouseRegion` / `WidgetState`).
   - Primary (and other variants as appropriate) must use `brandPrimaryHover` / analogous token-derived colors on hover.
   - Add widget tests asserting hover path; optionally a golden hover frame if feasible under Alchemist.

2. **Eliminate non-token sizing in components**
   - `document_card.dart`: `BorderRadius.circular(LexivoRadius.sm)`.
   - `badge.dart`: use `LexivoTypography.label` as-is, or add a named token (e.g. compact label) if 12px is intentional — do not hard-code `fontSize: 12`.
   - `nav_bar.dart`: replace `fontSize: 11`, `height: 2`, and raw icon sizes with spacing/typography tokens (extend tokens if needed).

3. **Tokenize bottom-sheet barrier**
   - Replace `Colors.black54` with a semantic/tokenized scrim color.

4. **Re-run** `flutter test` and request DoD re-review (this file or a follow-up review).

---

## Gate confirmation

| Next step | Allowed? |
|---|---|
| Feature UI (compose screens from design system) | **No** — blocked until remediations + re-review **PASS** |
| Backend / adapters / non-UI core | Not gated by this design-system DoD review |
| Further design-system-only fixes | Yes — required |

---

## Remediation status (Design System Agent — 2026-08-04)

All required High + Medium items addressed. See `openspec/reviews/design-system-dod-remediation.md`.

| # | Item | Status |
|---|---|---|
| 1 | LexivoButton hover (web) + tests | Done |
| 2 | Token discipline (document_card, badge, nav_bar) | Done |
| 3 | Bottom sheet scrim token | Done |

Awaiting Reviewer re-review — **do not treat as DoD PASS** until re-review verdict.
