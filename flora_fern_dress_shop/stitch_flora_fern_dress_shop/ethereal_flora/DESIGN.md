```markdown
# Design System Strategy: The Digital Atelier

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Digital Atelier."** 

We are moving away from the "commodity e-commerce" look—characterized by rigid grids and heavy borders—and toward a high-end editorial experience. This system treats the screen like a premium fashion magazine. By utilizing intentional asymmetry, expansive white space (breathing room), and a "layered paper" approach, we create an environment where the photography is the protagonist and the UI is its elegant, understated stage.

To achieve this "signature" look, we prioritize tonal depth over structural lines. Every interaction should feel like a soft transition through a physical boutique.

---

## 2. Colors & Surface Philosophy
The palette is rooted in organic, sophisticated tones that evoke luxury without being cold.

### The "No-Line" Rule
Standard UI relies on `1px` lines to separate content. In this design system, **solid borders for sectioning are strictly prohibited.** Boundaries must be defined through:
*   **Tonal Shifts:** Placing a `surface-container-low` section against a `background` or `surface` base.
*   **Generous Spacing:** Using the hierarchy of negative space to imply a break in content.

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked, high-quality materials.
*   **Base Layer (`surface` / `#faf9f6`):** The primary canvas.
*   **Content Containers:** Use `surface-container-lowest` (`#ffffff`) for elevated cards to create a "crisp paper" effect on top of the beige-tinted background.
*   **Sub-Navigation/Grouping:** Use `surface-container-high` (`#e9e8e5`) for background blocks behind specific product categories or filter sidebars to create a recessed, grounded feel.

### The "Glass & Gold" Rule
*   **Glassmorphism:** For floating elements like the Bottom Navigation Bar or "Quick Add" overlays, use a semi-transparent `surface` color with a `20px` backdrop-blur. This ensures the vibrant imagery of the dresses bleeds through, keeping the UI feeling light and integrated.
*   **Signature Textures:** Use the `tertiary` (`#775a19`) and `tertiary-container` (`#d1ab63`) for subtle gradients on high-value CTAs (like "Complete Purchase"). This creates a metallic, gold-foil sheen that feels more premium than a flat color.

---

## 3. Typography: The Editorial Voice
We use a high-contrast typographic scale to mimic fashion editorial layouts.

*   **The Display & Headline (Epilogue):** This is our "Modern Sans." It is stylish and structural. 
    *   *Usage:* Use `display-lg` and `headline-lg` for hero statements and category titles. Use "Optical Kerning" and slightly tighter letter-spacing (-2%) for large headlines to give them a high-fashion, "tight" look.
*   **The Utility (Manrope):** A clean, approachable sans-serif for reading and data.
    *   *Usage:* `body-lg` and `body-md` are for product descriptions. `label-md` and `label-sm` are for micro-copy (sizes, prices, materials).

**Intentional Asymmetry:** Don't center-align everything. Use left-aligned `headline-md` paired with right-aligned `body-sm` metadata to create a dynamic, editorial flow that leads the eye across the imagery.

---

## 4. Elevation & Depth
We eschew traditional "Drop Shadows" in favor of **Tonal Layering.**

*   **The Layering Principle:** Depth is achieved by "stacking." A product card (`surface-container-lowest`) sitting on a category background (`surface-container-low`) provides enough contrast to signify elevation without a single shadow.
*   **Ambient Shadows:** Where a floating effect is vital (e.g., a "Cart" modal), use an ultra-diffused shadow. 
    *   *Spec:* `Y: 12px, Blur: 40px, Opacity: 6%` using the `on-surface` color. This mimics natural light in a bright room rather than a digital glow.
*   **The "Ghost Border" Fallback:** If a boundary is required for accessibility, use the `outline-variant` (`#d4c2c2`) at **15% opacity**. This creates a "whisper" of a line that guides the eye without cluttering the aesthetic.

---

## 5. Components

### Buttons
*   **Primary:** High-contrast. Background: `primary` (`#7b5455`), Text: `on-primary` (`#ffffff`). Shape: `sm` (0.125rem) for a sharp, tailored fashion look.
*   **Secondary:** Background: `secondary-container` (`#f2e0cc`), Text: `on-secondary-container`. No border.
*   **Tertiary (The "Gold" CTA):** A subtle gradient from `tertiary` to `tertiary-container`. Reserved for the final "Pay" action.

### Input Fields
*   **Style:** Minimalist "Underline" style or a subtle tonal box using `surface-container-highest`.
*   **States:** On focus, the underline transitions from `outline-variant` to `primary`. Error states use `error` (`#ba1a1a`) but keep the typography at `label-sm` to remain elegant.

### Cards & Product Grids
*   **The Rule:** **Strictly no dividers.** 
*   Use `surface-container-lowest` for the card background. 
*   **Image Treatment:** Images should have a subtle `xl` (0.75rem) or `lg` (0.5rem) corner radius to soften the high-quality model photography.
*   **Spacing:** Use a 24px internal padding for product details to ensure the price and title "breathe."

### Chips (Filters/Sizes)
*   Unselected: `surface-container-high` with `on-surface-variant` text.
*   Selected: `primary` background with `on-primary` text.
*   Shape: `full` (pill-shaped) to provide a soft contrast to the sharp-edged buttons.

---

## 6. Do's and Don'ts

### Do:
*   **Do** use overlapping elements. Let a product image slightly overlap a background tonal block to create 3D depth.
*   **Do** use `primary-fixed-dim` for "Save for Later" icons to give a soft, romantic feel.
*   **Do** prioritize large-scale imagery. The UI should feel like it's "wrapped around" the dresses.

### Don't:
*   **Don't** use 100% black (`#000000`). Use `on-surface` (`#1a1c1a`) for text to keep the look soft and premium.
*   **Don't** use heavy "Standard" shadows. If you can clearly see the shadow's edge, it's too dark.
*   **Don't** crowd the screen. If in doubt, add 8px of extra padding. Luxury is defined by the space you *don't* fill.
*   **Don't** use dividers between list items. Use 16px–24px of vertical white space instead.

---

## 7. Signature Interaction: The "Atelier" Transition
When navigating between a product list and a product detail page, use a shared-element transition where the image expands smoothly and the typography fades in with a slight upward stagger. This reinforces the feeling of opening a luxury lookbook.