---
name: code-explainer
description: Use when an Imsight documentation task asks for a source-code explainer, annotated implementation webpage, literate-programming view, or labml-style page that aligns prose, equations, data shapes, and exact source lines from one code file. Do not use for ordinary code review or documentation without a webpage deliverable.
metadata:
  skill_invocation_notation: >
    Top-level skill entrypoints use SKILL.md. Parent-scoped subskill entrypoints use
    SKILL-MAIN.md and are loaded explicitly through their parent; nested SKILL.md is
    accepted only as legacy input when SKILL-MAIN.md is absent.
    Skill and subskill entrypoints use bare object paths: `X` invokes skill X and
    `X->Y->Z` invokes subskill Z. Subcommands use parenthesized components:
    `X->cmd()` invokes a direct subcommand, `X->Y->cmd()` invokes a subcommand of
    subskill Y, and `X->parent()->child()` invokes child subcommand child exposed
    by parent subcommand parent. Intermediate subcommands act as object generators.
    Forms such as `X()` and `X->Y()` are invalid for skill or subskill entrypoints.
---

# Code Explainer

## Overview

Create a literate-programming webpage in which the source file is the article's spine: each explanation, equation, or data-shape note is placed beside the exact code span it explains. Preserve source fidelity while turning implementation order into a clear teaching sequence.

## When to Use

Use this subskill when the user asks to:

- turn a code file into an annotated, browsable explanation,
- create a labml-inspired or side-by-side prose-and-code page,
- explain an algorithm by aligning concepts, equations, shapes, and source lines,
- publish an implementation walkthrough as a static page or project-native web route.

Do not use it for a conventional code review, API reference, prose-only tutorial, repository-wide architecture tour, or documentation task that does not require an explainer webpage.

## Workflow

When this subskill is invoked, execute the following steps in order.

1. **Resolve the input and output**. Identify the source file, target page location, requested technology, and intended reader. See **Input and Output Resolution**.
2. **Understand the implementation**. Read the complete source and the minimum supporting evidence needed to explain it accurately. See **Implementation Understanding**.
3. **Build the annotation map**. Partition the source into ordered, contiguous semantic units and assign each unit an explanation purpose. See **Annotation Model**.
4. **Choose the page integration**. Extend the user's existing web stack when one is in scope; otherwise create a small static page without an unnecessary framework. See **Input and Output Resolution**.
5. **Implement the page**. Read and apply [references/presentation-contract.md](references/presentation-contract.md), including its content, layout, responsive, source-fidelity, and accessibility rules. For a standalone page, inspect and adapt [assets/annotated-code-example.html](assets/annotated-code-example.html).
6. **Verify meaning and rendering**. Check every claim against the code, validate line-range coverage, run relevant project checks, and inspect the page at wide and narrow viewports. See **Verification**.
7. **Deliver the result**. Return the page entrypoint, supporting files, source snapshot, validation performed, and any intentionally omitted source ranges to the parent for its final handoff. See **Output Contract**.

If the user's task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from this skill's contracts and the requested deliverable, then execute the plan.

## Invocation Contract

- Invoke this subskill as `imsight-doc-writing->code-explainer`.
- A direct invocation runs the complete workflow; this subskill exposes no public subcommands.
- The parent loads only this `SKILL-MAIN.md` and the local reference or asset required by the request.

## Input and Output Resolution

- Use the source file and output location named by the user.
- When the source is named but the output is not, prefer the existing documentation or web application location implied by the repository. If none exists, create a sibling directory named `<source-stem>-explainer/` without modifying the source file.
- Infer the audience from the request and surrounding project. When it remains unspecified, write for a developer who knows the language but not this implementation.
- Reuse the project's framework, design tokens, syntax highlighter, math renderer, and build commands when they already exist. For a standalone result, prefer semantic HTML, CSS, and only the JavaScript needed for navigation or progressive enhancement.
- Treat the rendered code as a snapshot. Record the source path and, when available, its revision or content hash so readers can tell which implementation is being explained.

## Implementation Understanding

- Read the complete source file before segmenting it.
- Follow imported definitions, callers, tests, types, or upstream algorithm references only when they affect the explanation's correctness.
- Establish inputs, outputs, invariants, state changes, failure paths, side effects, equations, and data-shape transitions supported by evidence.
- Mark an uncertain claim for clarification or omission instead of filling the gap from intuition.

## Annotation Model

Create an ordered annotation map before building the UI. Each entry contains:

- a stable anchor,
- a heading or concise purpose statement,
- one contiguous source line range,
- an explanation focused on intent, invariants, data flow, or consequences,
- optional equations, tensor/data shapes, references, or cautions.

Use these rules:

1. Begin with a compact overview that states what the implementation does, its inputs and outputs, and the most useful upstream references.
2. Follow the source's execution and declaration order. Use class, function, and major phase boundaries as section headings.
3. Keep one teaching idea per row. Merge tiny lines that form one operation; split large blocks when their conceptual purpose changes.
4. Explain why the code exists and how values change. Do not merely translate syntax into English.
5. Place equations and shape transitions beside the operation they formalize. Define symbols before using them.
6. Cover the complete file or explicitly label every omitted range and the reason for omitting it. Never silently reorder or rewrite displayed source.

## Output Contract

The finished explainer must provide:

- an entry page that opens through the repository's normal preview or a simple local static server,
- a synchronized sequence of paired explanation and source-code cells,
- stable section anchors and faithful line numbers,
- a responsive narrow-screen presentation that keeps each explanation adjacent to its code,
- enough local styling and assets to render reliably in the intended environment,
- no modification to the input source unless the user separately requested it.

## Example Resource

`assets/annotated-code-example.html` is a self-contained, dependency-free example of the required paired-row structure, source treatment, dark visual hierarchy, and responsive stacking behavior.

- Copy and replace its sample content when a standalone HTML deliverable fits the request.
- Treat it as a structural reference when integrating into an existing framework; do not force its markup or palette over project conventions.
- Learn the example's style, intent, and semantics rather than hardcoding its sample attention function, annotations, labels, or colors.
- Generate displayed code from the user's actual source snapshot instead of manually editing the example's token spans.

## Resource Ownership

This subskill owns `references/presentation-contract.md` and `assets/annotated-code-example.html`. The `imsight-doc-writing` parent owns route selection and the final user-facing handoff; `org/` and `migrate/` preserve migration evidence and are not runtime instructions.

## Verification

Before delivery:

1. Compare the rendered code with the source byte-for-byte after HTML escaping, except for explicitly labeled elisions.
2. Check that annotation ranges are ordered, non-overlapping, and cover all intended lines exactly once.
3. Validate technical claims through definitions, callers, tests, or authoritative references; call out uncertainty instead of guessing.
4. Run the relevant build, typecheck, lint, or static-server smoke check for the chosen integration.
5. Inspect a desktop viewport and a narrow viewport. Confirm paired rows remain legible, code scrolls locally when necessary, anchors work, and the page has no unintended page-level horizontal overflow.
6. Check browser console errors and verify that the page remains understandable when optional JavaScript or remote resources are unavailable.

## Guardrails

- DO NOT modify the input source file unless the user explicitly asks for source changes.
- DO NOT alter, reorder, or silently omit source text in the displayed snapshot.
- DO NOT implement prose and code as two independent flowing columns that can drift out of alignment.
- DO NOT invent behavior, equations, types, or data shapes that the implementation does not support.
- DO NOT insert unescaped source text into HTML.
- DO NOT copy the reference site's branding, analytics, social widgets, or proprietary content.
