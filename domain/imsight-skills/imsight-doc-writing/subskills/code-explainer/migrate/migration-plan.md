---
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

# Code Explainer Migration Plan

## Scope

- **Source skill:** `domain/imsight-skills/imsight-code-explainer/`
- **Target parent:** `domain/imsight-skills/imsight-doc-writing/`
- **Target subskill:** `domain/imsight-skills/imsight-doc-writing/subskills/code-explainer/`
- **Migration mode:** Source-to-target migration.
- **Runtime route:** `imsight-doc-writing->code-explainer`.

The standalone capability becomes a parent-scoped documentation subskill because its presentation contract and HTML template form a private resource tree that should travel together.

## Source Behavior to Preserve

- Trigger on requests for annotated source-code webpages, literate-programming views, or labml-style prose, equation, shape, and exact-line alignment.
- Reject ordinary review, prose-only documentation, repository-wide architecture tours, and tasks without a webpage deliverable.
- Resolve one source file, output location, integration stack, audience, and source snapshot identity.
- Read the complete implementation and the minimum supporting code, tests, types, callers, or authoritative references needed for accuracy.
- Build an ordered annotation map over contiguous source ranges with stable anchors, one teaching idea per row, and explicit elisions.
- Prefer the existing project stack; use a small semantic static page when no web stack is in scope.
- Keep explanations and code structurally paired at wide and narrow widths.
- Preserve the presentation contract and dependency-free HTML example as runtime resources.
- Verify semantic claims, line coverage, build or smoke checks, desktop and narrow rendering, overflow, anchors, accessibility, optional-resource behavior, and console errors.
- Keep the input source unchanged unless the user separately asks for source edits.

## Target Runtime Shape

| Target File or Area | Runtime Role | Migration Action |
| --- | --- | --- |
| Parent `SKILL.md` | Host-discoverable router | Add a direct subskill route and update routing language to distinguish subskills from subcommands. |
| Parent `agents/openai.yaml` | Host UI metadata | Replace the Mermaid-specific default prompt with a generic parent-routing prompt that covers subskills and subcommands. |
| `SKILL-MAIN.md` | Parent-scoped entrypoint | Rewrite the standalone entrypoint with `name: code-explainer`, parent-scoped triggers, and the bare subskill invocation contract. |
| `references/presentation-contract.md` | Private reference | Preserve as executable presentation guidance owned by the subskill. |
| `assets/annotated-code-example.html` | Private output asset | Preserve as the standalone implementation example owned by the subskill. |
| `org/src/` | Immutable provenance | Preserve every source file, renaming only the source entrypoint to `SKILL-SOURCE.md`. |
| `org/analysis/` | Migration evidence | Store the self-contained deep inspection of the source process. |
| `migrate/migration-plan.md` | Migration contract | Record source-to-target mappings and intentional changes. |
| Source `agents/openai.yaml` | Standalone-only runtime metadata | Keep only in provenance because the parent skill owns host discovery and invocation policy. |
| Standalone source folder | Obsolete runtime root | Remove after target validation so exact-name scanners cannot register both standalone and nested entrypoints. |

## Term Adaptations

| Source Term | Target Term | Reason |
| --- | --- | --- |
| `imsight-code-explainer` | `code-explainer` | A nested name avoids repeating the parent namespace. |
| Standalone skill | Parent-scoped subskill | The capability now belongs to the documentation-writing resource hierarchy. |
| Direct standalone invocation | `imsight-doc-writing->code-explainer` | The parent explicitly loads the selected `SKILL-MAIN.md`. |
| Skill-owned agent metadata | Parent-owned discovery metadata | Nested runtime discovery is routed through `imsight-doc-writing`. |

No domain terminology, source semantics, annotation fields, output artifacts, or validation gates require adaptation.

## Tool and Harness Adaptations

- Preserve project-native build, lint, typecheck, syntax-highlighting, math-rendering, and preview tools when available.
- Preserve the dependency-free semantic HTML fallback and browser inspection requirement.
- Do not add a new framework, service, network dependency, or external skill route.
- Remove the standalone subskill agent config from runtime because the parent already owns UI discovery and explicit invocation policy.

## Artifact and Storage Adaptations

| Source Artifact | Target Binding |
| --- | --- |
| Generated explainer page | Unchanged user or repository output location. |
| `references/presentation-contract.md` | Same relative path inside the subskill resource root. |
| `assets/annotated-code-example.html` | Same relative path inside the subskill resource root. |
| Source snapshot identity | Unchanged path plus revision or content hash when available. |
| Migration evidence | Subskill-owned `org/` and `migrate/` directories. |

## External Skill Route Adaptations

The source skill invokes no external skills. The only new route is parent-owned selection of `imsight-doc-writing->code-explainer`; once loaded, the subskill executes its workflow locally and returns its page artifacts and validation evidence to the parent for the final handoff.

## Step Support Mapping

| Source Workflow Step | Target Runtime Support |
| --- | --- |
| Resolve input and output | `SKILL-MAIN.md` **Input and Output Resolution**. |
| Understand the implementation | `SKILL-MAIN.md` **Implementation Understanding**. |
| Build the annotation map | `SKILL-MAIN.md` **Annotation Model**. |
| Choose page integration | Main workflow and **Input and Output Resolution**. |
| Implement the page | `references/presentation-contract.md` and `assets/annotated-code-example.html`. |
| Verify meaning and rendering | `SKILL-MAIN.md` **Verification** plus the reference validation checklist. |
| Deliver the result | `SKILL-MAIN.md` **Output Contract** and parent final handoff. |

## Semantic Match Checks

- The target must retain all source trigger boundaries, workflow stages, output requirements, verification gates, and guardrails.
- The target must retain the reference and example asset as private resources of the subskill.
- The target must use `SKILL-MAIN.md` and must not contain a sibling `SKILL.md`.
- The parent must list the subskill with one context-specific routing sentence and load only its `SKILL-MAIN.md` and required local resources.
- The standalone source folder must be absent after validation.
- The intentionally changed behaviors are limited to the name, parent-owned route, role-canonical entrypoint filename, resource path, and omission of standalone agent metadata from runtime.

## Placeholders

No unresolved terms, artifacts, routes, tools, storage bindings, environment assumptions, or handoffs remain. A placeholder registry is therefore not required.
