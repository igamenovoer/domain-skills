---
name: slidev
description: Use when an Imsight documentation task concerns a Slidev presentation, slide layout, speaker notes, presenter navigation, or optional appendix slides opened through reveal links.
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

# Slidev Presentations

## Overview

Create and maintain Slidev presentations within the user's project. Preserve the deck's design and source organization, make navigation behavior explicit, and verify the browser experience. This subskill owns its Slidev command pages and portable implementation examples; it does not require any particular repository, model, dataset, theme, package manager, or deployment host.

## Workflow

1. **Resolve the deck and requested change**. Inspect repository instructions, the deck entrypoint, imported pages, components, configuration, and existing local edits.
2. **Select the narrowest capability** from **Subcommands**. Use **General Slidev Work** when the task has no dedicated command.
3. **Check the actual toolchain**. Resolve the installed Slidev version and existing build scripts; prefer the project's installation, then an already installed global command. Read matching documentation or installed source when behavior is uncertain.
4. **Execute the selected workflow**. Load its command page and only the bundled resources it requires.
5. **Validate the result in context**. Run the relevant build and inspect the affected slides and interactions in a browser using the project's available tooling.
6. **Return a concise handoff**. Identify changed artifacts, presentation controls, verification results, and material limitations.

If the user's task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from this subskill's commands, constraints, and the requested deliverable, then execute that plan.

## When to Use

- The user requests a Slidev deck, changes to existing slides, or presenter behavior.
- The user wants appendix or backup slides omitted from the usual presentation flow but reachable through links.
- Several source slides need to open the same detail slide and return to their own positions.

## Invocation Contract

- Invoke this subskill as `imsight-doc-writing->slidev`.
- With no actionable task, show the available capabilities.
- Invoke `imsight-doc-writing->slidev->add-hidden-slides()` for optional slides with reveal and return controls.

## Subcommands

| Subcommand | Use For | Load |
| --- | --- | --- |
| `help` | Explain the Slidev capability and list its public commands | This entrypoint |
| `add-hidden-slides` | Add or adapt optional slides, reveal links, and origin-aware return navigation | [commands/add-hidden-slides.md](commands/add-hidden-slides.md) |

## General Slidev Work

1. Establish the audience, purpose, target pages, and output format from the request and existing deck.
2. Match the deck's language, typography, colors, layout, numbering, notes, and asset conventions. Recompose crowded or sparse content instead of indiscriminately scaling everything.
3. Use stable aliases for navigational targets; keep content and supporting evidence distinct from navigation code.
4. Keep technical claims, labels, units, aggregation, and source notes consistent with the supplied evidence.
5. Reuse installed dependencies and existing project commands. Discover available browser tooling rather than assuming a particular global installation path.
6. Build and visually inspect affected pages. Check overflow, label collisions, contrast, keyboard interactions, and presenter behavior when changed.

## Resource Ownership

The command page owns the implementation and verification contract. [assets/optional-slides/](assets/optional-slides/) contains a minimal five-slide example, reusable Vue controls, a navigation module, and its root setup. Copy and adapt these resources into the target deck when appropriate; the resulting presentation must run without access to this skill directory.

## Guardrails

- DO NOT use Slidev's compile-time `hide` or `disabled` setting for a slide that must remain revealable in the built presentation.
- DO NOT replace a deck's existing navigation, setup, theme, or source structure with the example wholesale.
- DO NOT hardcode sample page numbers, titles, paths, or aliases into another project's implementation.
- DO NOT claim an interaction works from a successful build alone.
