# Design System DoD Remediation — 2026-08-04

Addresses **REJECT** findings in `design-system-dod-review.md`. Ready for Reviewer re-run.

## Remediations completed

### 1. LexivoButton web hover (High) — DONE
- `MouseRegion` tracks `_hovered` separately from InkWell `_pressed`.
- Primary uses `brandPrimaryHover`; secondary/ghost use brandPrimary alpha tints; destructive uses token-derived lighten via `Color.alphaBlend`.
- Pressed takes precedence over hover.
- Widget tests: hover color, pressed-over-hover, disabled ignores hover, secondary hover.

### 2. Token discipline (Medium) — DONE
- `document_card.dart`: `BorderRadius.circular(LexivoRadius.sm)`.
- `badge.dart`: `LexivoTypography.labelCompact` (named 12px token; no hard-coded `fontSize: 12`).
- `nav_bar.dart`: `LexivoTypography.captionCompact`, `LexivoSpacing.micro`, `LexivoIconSize.md`.
- New/extended tokens: `LexivoSpacing.micro`, `LexivoIconSize`, `labelCompact` / `captionCompact`, documented in `BRAND.md`.

### 3. LexivoBottomSheet barrier (Medium) — DONE
- Added `LexivoColors.overlayScrim` (`0x8A000000`, always-dark modal scrim).
- `LexivoBottomSheet.show` uses `colors.overlayScrim` instead of `Colors.black54`.
- Widget test asserts barrier color.

## Not claimed
DoD **PASS** is for the Reviewer Agent on re-review — this note only confirms remediations 1–3 landed.
