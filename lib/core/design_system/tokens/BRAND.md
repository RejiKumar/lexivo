# Lexivo Brand Tokens

Canonical brand choices for the design system. Hex values here are the **authoritative** source for `LexivoColors` factories; consumers must never hard-code these hexes — only resolve via `Theme.of(context).extension<LexivoColors>()`.

## Mood

**Calm, confident, fast** — restrained professional UI inspired by principles from Notion / Linear / Perplexity / Arc (clarity, minimal chrome, generous whitespace), not pixel copies.

Avoided AI-generic looks: no purple-on-white or purple→indigo gradients; no warm cream + terracotta + display-serif cliché.

## Color palette

### Brand (teal)

| Role | Light | Dark | Notes |
|------|-------|------|-------|
| `brand.primary` | `#0F766E` | `#2DD4BF` | Deep teal — calm authority without purple |
| `brand.primaryHover` | `#0D9488` | `#5EEAD4` | Slightly lighter for hover affordance |
| `brand.primaryPressed` | `#115E59` | `#14B8A6` | Darker / deeper for press |

### Backgrounds & content (cool slate neutrals)

| Token | Light | Dark |
|-------|-------|------|
| `background.default` | `#F8FAFC` | `#0B1220` |
| `background.surface` | `#FFFFFF` | `#111827` |
| `background.surfaceElevated` | `#FFFFFF` | `#1E293B` |
| `background.inverse` | `#0F172A` | `#F8FAFC` |
| `content.primary` | `#0F172A` | `#F1F5F9` |
| `content.secondary` | `#475569` | `#94A3B8` |
| `content.disabled` | `#94A3B8` | `#64748B` |
| `content.onInverse` | `#F8FAFC` | `#0F172A` |
| `border.default` | `#E2E8F0` | `#334155` |
| `border.focus` | `#0F766E` | `#2DD4BF` |

### Feedback

| Token | Light | Dark |
|-------|-------|------|
| `feedback.success` | `#15803D` | `#4ADE80` |
| `feedback.warning` | `#B45309` | `#FBBF24` |
| `feedback.danger` | `#DC2626` | `#F87171` |
| `feedback.info` | `#0369A1` | `#38BDF8` |

### Overlay

| Token | Light / Dark | Notes |
|-------|--------------|-------|
| `overlay.scrim` | `#000000` @ 54% (`0x8A000000`) | Modal / bottom-sheet barrier — always dark for dimming |

### Contrast (WCAG AA targets)

- Light: `content.primary` on `background.default` / `surface` ≫ 4.5:1; white / near-white text on `brand.primary` for primary buttons.
- Dark: `content.primary` on `background.default` / `surface` ≫ 4.5:1; near-black text (`#0F172A`) on `brand.primary` (`#2DD4BF`) for primary buttons on dark.

Full automated contrast checks: `test/core/design_system/tokens/contrast_test.dart` (§16.1).

## Responsiveness (breakpoints)

Shared breakpoint stubs live in `tokens/breakpoints.dart` (`LexivoBreakpoint` / `LexivoBreakpoints`):

| Breakpoint | Width |
|------------|-------|
| `mobile` | ≤ 599 |
| `tablet` | 600–1023 |
| `desktop` | ≥ 1024 |

These match ui_design_system.md §5 / Responsive Framework roles. Features scale spacing via `LexivoBreakpoints.pagePadding` (and the same typography tokens) — not separate mobile/web component sets. Wire `responsive_framework` (or equivalent) in the app shell when it lands; until then resolve from `MediaQuery.sizeOf(context).width`.

## Typography

| Role | Family | Source | Usage |
|------|--------|--------|-------|
| **Primary UI** | **Plus Jakarta Sans** | [Google Fonts](https://fonts.google.com/specimen/Plus+Jakarta+Sans) via `google_fonts` | All UI text: body, titles, labels, buttons |
| **Display (optional)** | **Sora** | [Google Fonts](https://fonts.google.com/specimen/Sora) via `google_fonts` | Rare marketing / empty-state `type.display` moments only |

Rationale: Plus Jakarta Sans is geometric enough to feel fast and modern, but soft enough to stay calm on long reading (chat, docs). Sora is reserved for display so the product stays one type family in daily UI.

Type scale sizes/weights follow `ui_design_system.md` §2.5 (display 32/40 w700 … label 13/18 w600 ls 0.2).

Dense UI roles (not in §2.5 core scale; named tokens for components):

| Role | Size | Usage |
|------|------|-------|
| `labelCompact` | 12/16 w600 ls 0.2 | Badges / chips |
| `captionCompact` | 11 @ height 1.2 w400 | Compact nav labels |

Icon sizes: `LexivoIconSize` (`sm` 16 / `md` 22 / `lg` 24). Spacing hairline: `LexivoSpacing.micro` (2).

## Motion & spacing

Spacing, radius, elevation, and motion presets are product-standard (8pt scale, 120/200/300ms) — see `ui_design_system.md` §2.2–§2.6. They are not brand-differentiated beyond using the same calm easing (easeOut / easeInOut / easeInOutCubic).
