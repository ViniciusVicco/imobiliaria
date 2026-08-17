---
name: Seletta_imobiliaaria_cores
colors:
  surface: '#121414'
  surfaceDim: '#121414'
  surfaceBright: '#37393a'
  surfaceContainerLowest: '#0c0f0f'
  surfaceContainerLow: '#1a1c1c'
  surfaceContainer: '#1e2020'
  surfaceContainerHigh: '#282a2b'
  surfaceContainerHighest: '#333535'
  brandLogoBackground: '#031020'
  onSurface: '#e2e2e2'
  onSurfaceVariant: '#d0c5af'
  inverseSurface: '#e2e2e2'
  inverseOnSurface: '#2f3131'
  outline: '#99907c'
  outlineVariant: '#4d4635'
  surfaceTint: '#e9c349'
  primary: '#f2ca50'
  onPrimary: '#3c2f00'
  primaryContainer: '#d4af37'
  onPrimaryContainer: '#554300'
  inversePrimary: '#735c00'
  secondary: '#bbc6e2'
  onSecondary: '#253046'
  secondaryContainer: '#3e4960'
  onSecondaryContainer: '#adb8d3'
  tertiary: '#c4ceeb'
  onTertiary: '#263046'
  tertiaryContainer: '#a8b3ce'
  onTertiaryContainer: '#3b455c'
  error: '#ffb4ab'
  onError: '#690005'
  errorContainer: '#93000a'
  onErrorContainer: '#ffdad6'
  primaryFixed: '#ffe088'
  primaryFixedDim: '#e9c349'
  onPrimaryFixed: '#241a00'
  onPrimaryFixedVariant: '#574500'
  secondaryFixed: '#d7e2ff'
  secondaryFixedDim: '#bbc6e2'
  onSecondaryFixed: '#101b30'
  onSecondaryFixedVariant: '#3c475d'
  tertiaryFixed: '#d8e2ff'
  tertiaryFixedDim: '#bcc6e2'
  onTertiaryFixed: '#101b30'
  onTertiaryFixedVariant: '#3c475e'
  background: '#121414'
  onBackground: '#e2e2e2'
  surfaceVariant: '#333535'
typography:
  display-xl:
    fontFamily: Noto Serif
    fontSize: 64px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  h1:
    fontFamily: Noto Serif
    fontSize: 48px
    fontWeight: '600'
    lineHeight: '1.2'
  h2:
    fontFamily: Noto Serif
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.3'
  h3:
    fontFamily: Noto Serif
    fontSize: 24px
    fontWeight: '500'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1.0'
    letterSpacing: 0.1em
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 48px
  xxl: 80px
  gutter: 24px
  container-max: 1440px
---

## Brand & Style
The design system is engineered for an elite luxury real estate boutique, targeting high-net-worth individuals and corporate entities. The aesthetic is "Enterprise-Grade Excellence"—a fusion of institutional stability and bespoke refinement. It leverages a flat, Microsoft-inspired structural logic that prioritizes clarity, hierarchy, and information density over decorative trends.

The emotional response is one of absolute confidence and understated prestige. By utilizing high-contrast visuals and a spacious layout, the system avoids the clutter of traditional real estate platforms, instead offering a gallery-like experience that treats property listings as high-value assets.

## Colors
This design system operates on a primary dark mode foundation to evoke exclusivity. The palette is intentionally restrictive to maintain a high-end corporate feel.

- **Primary Background (#030E22):** A deep, saturated Navy Blue that provides a "vault-like" foundation for the interface.
- **Logo Background (#031020):** Brand-specific navigation background sampled from `assets/logos/seleta_logo.png`, used when the logo must sit on a seamless dark field.
- **Primary Accent (#D4AF37):** A premium Gold used for high-level branding, primary typography, and critical interactive call-to-actions.
- **Secondary Surface (#111C31):** Used for card backgrounds and navigation bars to create subtle tonal separation without relying on shadows.
- **Typography & Details (#FFFFFF):** Pure white is reserved for high-readability body text and iconography.
- **Borders (#2D3748):** Low-contrast gray-blues used to define the "Enterprise-grade" grid structure.

## Typography
The typographic hierarchy relies on the tension between the editorial elegance of **Noto Serif** and the industrial precision of **Manrope**.

Headings use Noto Serif to signal heritage and luxury. They should be set with tight letter-spacing in larger formats. Body text utilizes Manrope to ensure maximum legibility for property specifications and legal disclosures. Use the "Label-Caps" style for categories, breadcrumbs, and small headers to reinforce the structured, professional layout.

## Layout & Spacing
The layout follows a **Fixed Grid** philosophy, centered within a 1440px container. This mimics the structured feel of high-end financial reports and enterprise dashboards.

A strict 4px baseline grid governs all spacing. Vertical rhythm is critical; use large `xxl` (80px) padding between major sections to allow the content to "breathe," signaling that the user's time and attention are valued. Gutters are kept at a consistent 24px to provide a rigorous, geometric alignment across all screens.

## Elevation & Depth
In alignment with the "Flat Design" and "Corporate Modern" styles, this design system rejects traditional shadows and blurs.

Depth is achieved through **Tonal Layering** and **Bold Borders**. 
- Surfaces at the base level use the Primary Navy (#030E22).
- Elevated elements (cards, modals) use the Secondary Surface (#111C31).
- Separation is strictly enforced by 1px solid borders (#2D3748). 
- Active or high-priority items may use a 1px Gold (#D4AF37) border to signify focus.

## Shapes
To maintain a serious, institutional aesthetic, all UI elements utilize **Sharp Corners (0px)**. This includes buttons, input fields, cards, and images. The sharp edges reinforce the "structured" and "clean" nature of the boutique's professional identity, moving away from the consumer-grade soft aesthetics found in mass-market apps.

## Components
- **Buttons:** Primary buttons are solid Gold (#D4AF37) with Navy (#030E22) Manrope Bold text. Secondary buttons are transparent with a 1px White or Gold border. All buttons must have 0px corner radius.
- **Input Fields:** Styled as "Underlined" or "Full Border" with a dark background. Use 1px borders. Focus state is indicated by the border color changing to Gold.
- **Cards:** No shadows. Cards use the #111C31 background and a 1px border. Property images within cards should be flush with the top and sides, maintaining the sharp-edged grid.
- **Chips/Tags:** Small, rectangular containers with 0px rounding. Used for "For Sale," "Penthouse," or "New Listing" labels. Use the "Label-Caps" typography.
- **Property Lists:** Tabular data should use alternating row colors (subtle Navy shifts) and 1px horizontal dividers to maintain the enterprise-grade data density.
- **Navigation:** A persistent top bar with high-contrast White text. The active page is indicated by a Gold 2px bottom border, reinforcing the architectural grid.
