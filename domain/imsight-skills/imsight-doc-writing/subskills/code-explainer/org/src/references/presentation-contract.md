# Annotated Code Page Presentation Contract

Use this contract while implementing and visually verifying a source-code explainer page. It captures the presentation grammar of the [labml annotated MHA page](https://nn.labml.ai/transformers/mha.html) without requiring the result to copy that site's branding or exact styling.

Inspect [the self-contained HTML example](../assets/annotated-code-example.html) when a concrete implementation reference is useful. Adapt its paired-row structure and responsive behavior, not its sample content.

## Core Composition

The page is a sequence of paired rows, not a prose article followed by code snippets and not two independently scrolling documents.

Each semantic row contains:

1. an explanation cell on the left,
2. the exact corresponding source range on the right,
3. one shared vertical extent and bottom divider,
4. a stable anchor attached to the conceptual unit.

The code column is the durable spine. Explanations may vary in length, but the next source range begins only when the current paired row ends.

A suitable semantic structure is:

```html
<main class="explainer">
  <section class="annotation-row" id="prepare-input">
    <div class="explanation">...</div>
    <pre class="source"><code>...</code></pre>
  </section>
</main>
```

The example is illustrative. Match an existing project's component and accessibility conventions when present.

## Information Hierarchy

Use a restrained hierarchy:

1. **Utility header** — breadcrumbs or project context, a source/repository link, and at most one primary action such as opening a notebook or runnable example.
2. **Page introduction** — title, a two- or three-sentence purpose statement, input/output contract, and authoritative references.
3. **Major sections** — classes, functions, algorithm phases, or other structural boundaries.
4. **Annotation rows** — short conceptual explanations aligned with exact source ranges.
5. **Minimal footer** — provenance or project link only when useful.

Do not add a hero illustration, marketing copy, feature cards, testimonials, decorative dashboards, or unrelated navigation. The implementation and its explanation are the product.

## Explanation Style

- Lead with the purpose or state change: “Split the projected vector into heads,” not “Here we call `view`.”
- Prefer one short paragraph per simple operation. Use a second paragraph only for an invariant, caveat, or consequence that materially aids understanding.
- Introduce functions and classes with their contract before annotating internals.
- Use inline code for identifiers and compact monospace chips for shapes, dimensions, flags, and literal values.
- Use displayed math only when it shortens or sharpens the explanation. Keep the equation in the same row as its implementation.
- Define mathematical symbols and shape names before relying on them.
- Link primary papers, specifications, framework documentation, and related runnable code inline rather than collecting an oversized references section.
- Avoid narrating imports, assignments, or syntax unless they encode a non-obvious dependency or invariant.

## Source Fidelity

Render from the actual source snapshot whenever practical. The source view must preserve:

- line order,
- line numbers from the original file,
- indentation and significant whitespace,
- tokens and string contents,
- blank lines when they communicate grouping.

Escape source before inserting it into HTML. Syntax highlighting must operate on escaped or text-node content and must never turn source strings into executable markup.

If the page excludes generated code, license headers, repetitive declarations, or another range, show an explicit elision row such as `Lines 1–18 omitted: license header and generated imports`. Do not renumber the remaining lines.

When source text is copied into generated data rather than loaded at runtime, record a revision or content hash near the source link. If the repository already has a build pipeline, prefer generating the rendered snapshot from the file so drift can be detected.

## Layout System

Use CSS Grid or an equivalent row-level layout so alignment is structural.

- At wide viewports, start near a `40% / 60%` explanation-to-code split. Adjust for the source language and existing site shell, but keep the code column wider.
- Give the explanation and code cells subtly different dark surfaces. A useful starting relationship is a near-black page, a slightly lighter prose panel, and a clearly but gently lighter code panel.
- Use one vertical divider between columns and a low-contrast horizontal divider between rows.
- Keep the content full-width enough for realistic code. Avoid a narrow centered blog column.
- Pad both cells consistently. Let major-section rows breathe more than single-operation rows.
- Keep code overflow inside the code cell with horizontal scrolling; do not let a long line widen the entire page.
- Avoid independent column scrolling, absolute positioning, masonry, or client-side height matching.

Example design-token relationships:

```css
:root {
  --page-bg: #171920;
  --prose-bg: #1c1f26;
  --code-bg: #262936;
  --rule: #343846;
  --text: #d8dae1;
  --muted: #8b91a1;
  --link: #a8ccce;
  --accent: #d79ac8;
}
```

These values are a starting palette, not a branding requirement. Reuse accessible project tokens when available.

## Typography and Code Treatment

- Use the project's readable sans-serif stack for prose and a true monospace stack for source.
- Keep body text around `15–17px` with approximately `1.5–1.65` line height.
- Make the page title strong but not oversized. Section headings should be noticeably quieter than a marketing landing-page headline.
- Place line numbers in a fixed-width muted gutter and prevent them from being selected when the user copies code, when the chosen rendering approach supports that behavior.
- Use restrained syntax colors with sufficient contrast. Highlight semantic token categories; do not color every punctuation mark aggressively.
- Keep code line height compact but readable, usually `1.45–1.6`.
- Render equations with the project's existing math tool. If no renderer exists, prefer readable Unicode or plain-text notation over adding a large dependency for one small formula.

## Responsive Behavior

Below the layout breakpoint, stack each paired row independently:

1. explanation,
2. its corresponding code range,
3. divider,
4. the next explanation and code range.

Never render all prose first and all code afterward on narrow screens. That destroys the explanatory mapping.

At narrow widths:

- retain original code line numbers,
- allow local horizontal code scrolling,
- reduce cell padding modestly,
- keep tap targets and anchors usable,
- avoid sticky panels that consume most of the viewport.

## Interaction and Progressive Enhancement

The page should be complete without elaborate interaction. Useful optional enhancements include:

- anchor links that appear on heading hover or focus,
- a compact table of contents for long files,
- “copy source range” controls,
- a current-section indicator,
- collapsible explicitly omitted ranges.

Do not add animation, synchronized scroll listeners, or client-side code execution unless the user asks for them or the implementation genuinely benefits. Respect `prefers-reduced-motion` for any motion that remains.

## Accessibility

- Use semantic landmarks, headings in order, and one addressable section per annotation row.
- Ensure text, muted line numbers, links, focus states, and syntax tokens meet accessible contrast against their actual surfaces.
- Keep reading order as explanation followed by its code range in the DOM, matching the narrow-screen presentation.
- Give icon-only controls accessible names.
- Do not encode meaning through color alone.
- Preserve keyboard access to anchors, copy controls, and horizontal code regions.

## Validation Checklist

- Every explanation row points to one exact, contiguous source range.
- Intended source ranges are ordered, non-overlapping, and complete; elisions are visible.
- Explanations focus on intent, invariants, data flow, equations, or consequences rather than syntax narration.
- Desktop rendering presents aligned paired cells with a wider code column.
- Narrow rendering stacks each explanation immediately before its code.
- Long source lines scroll inside their cells without page-level horizontal overflow.
- Code is escaped, line numbers are faithful, and copying does not introduce invented text.
- Anchors, links, focus styles, and optional controls work with a keyboard.
- The page produces no unexpected browser console errors.
- The result uses its own or the project's identity rather than copying labml branding.
