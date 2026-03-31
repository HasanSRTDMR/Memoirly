# Design System: Editorial Serenity

## 1. Overview & Creative North Star: "The Private Archive"
This design system is not a utility; it is a sanctuary. To move beyond the "standard app" feel, we embrace a **High-End Editorial** aesthetic. Our Creative North Star is **The Private Archive**—the digital equivalent of a high-quality linen notebook kept in a sun-drenched study.

We break the "template" look by rejecting rigid, boxy grids in favor of **Intentional Asymmetry** and **Tonal Depth**. By utilizing wide margins (using the `8` to `12` spacing tokens) and a sophisticated mix of Serif and Sans-Serif typography, we create an environment where thoughts feel significant. The interface should feel "whispered," never shouted.

---

## 2. Color & Surface Philosophy
The palette is rooted in organic, breathable neutrals. We avoid the clinical coldness of pure white and the harshness of pitch black.

### The "No-Line" Rule
**Explicit Instruction:** Do not use 1px solid borders to section content. Boundaries must be defined solely through background color shifts.
*   **Example:** A daily entry card (`surface-container-low`) sits on the main app background (`surface`). The distinction is felt through value change, not a drawn line.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers, like stacked sheets of premium vellum.
*   **Level 0 (Base):** `surface` (#f9f9f7) – The foundation.
*   **Level 1 (In-Page Sections):** `surface-container-low` (#f2f4f2) – Subtle grouping.
*   **Level 2 (Floating/Interactive):** `surface-container-lowest` (#ffffff) – High-focus elements like active text editors or modals.

### The "Glass & Gradient" Rule
To add "soul," use subtle, long-form gradients for primary actions. Instead of a flat `primary` block, use a transition from `primary` (#5f5e5e) to `primary-dim` (#535252). For floating navigation bars, use **Glassmorphism**: apply `surface` at 80% opacity with a `backdrop-filter: blur(20px)` to allow the editorial content to softly bleed through.

---

### 3. Typography: The Editorial Voice
We use a high-contrast typographic scale to differentiate between "System" and "Soul."

*   **The System (Navigation/Utility):** Uses **Manrope**. It is functional, modern, and invisible. 
    *   *Display-LG:* Use for mood summaries or "Year in Review" milestones.
    *   *Label-MD:* Use for metadata (e.g., "Saved at 10:30 PM") using `on-surface-variant`.
*   **The Soul (Content/Writing):** Uses **Newsreader**. This serif typeface adds the "Editorial" weight.
    *   *Title-LG:* For journal entry headers.
    *   *Body-LG:* The primary writing experience. Ensure a line-height of 1.6x for maximum breathability.

---

## 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are too aggressive for a "Calm" experience. We use **Ambient Light** principles.

*   **The Layering Principle:** Achieve depth by stacking tokens. Place a `surface-container-highest` button on a `surface` background. The delta in color provides all the "lift" needed.
*   **Ambient Shadows:** For "Floating Action Buttons" (FAB) or critical modals, use a shadow with a blur of `24px` at `4%` opacity, using a tint of `on-surface` (#2d3432) rather than black.
*   **The "Ghost Border":** If accessibility requires a stroke (e.g., in a high-glare setting), use `outline-variant` at 15% opacity. If you can see the line clearly, it is too heavy.

---

## 5. Components & Primitives

### Buttons (The Tactile Interaction)
*   **Primary:** Rounded `xl` (1.5rem). Background: `primary` gradient. Text: `on-primary`. No shadow.
*   **Secondary/Tertiary:** No background. Use `label-md` in `primary` color. Interaction is signaled by a subtle shift to `surface-container-high` on tap.

### Input Fields (The Writing Canvas)
*   **Journal Area:** Remove all "box" metaphors. No borders, no background fills. The cursor sits on the `surface`. Use `body-lg` (Newsreader).
*   **Search/Metadata:** Use `md` (0.75rem) corners with `surface-container-low` fill.

### Cards & Lists (The Timeline)
*   **Anti-Divider Rule:** Forbid the use of horizontal rules (`<hr>`). Separate entries using `spacing-6` or `spacing-8`. 
*   **Visual Grouping:** Use a `surface-variant` vertical pill (2px wide) to the left of a quote or a specific "memory" to provide a soft anchor without closing the element in a box.

### Signature Component: The "Mood Cloud"
A horizontal scrolling set of Chips using `secondary-container` (muted green) and `tertiary-container` (warm beige). These should have `full` roundedness and use `on-secondary-container` for the text.

---

## 6. Do's and Don'ts

### Do:
*   **Embrace Negative Space:** If a screen feels "empty," you are likely doing it right. Use `spacing-12` for top margins.
*   **Soft Transitions:** All state changes (hover, active, focus) must use a minimum `200ms` cubic-bezier transition.
*   **Use Intentional Asymmetry:** Align the date to the far right while the title stays left to create an editorial, magazine-like feel.

### Don't:
*   **Don't use 100% Black:** It breaks the "softness." Always use `on-surface` or `primary`.
*   **Don't use aggressive "Success" Greens:** Use the `secondary` token (#5b6150) for a muted, mossy green that feels natural, not digital.
*   **Don't over-shadow:** If you have more than two shadowed elements on a screen, the hierarchy is lost. Use tonal shifts instead.