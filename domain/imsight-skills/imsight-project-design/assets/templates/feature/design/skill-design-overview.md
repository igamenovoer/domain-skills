# <READABLE_SKILL_NAME> Design Overview

## Purpose

This note describes a proposed skill, `<PROPOSED_SKILL_ID>`, before it is created. It captures the intended user workflow, subcommands, process model, and user-facing contracts so a designer can review the skill's UX without reading generated skill files.

The key orchestration rule is: <ONE_SENTENCE_ROUTING_AND_OUTPUT_OWNERSHIP_RULE>.

## Concepts

This section defines the small vocabulary needed to read the skill workflow and examples. It favors user-facing terms that the skill should expose in plans, reports, and validation notes.

- **<CONCEPT_NAME>**: <ONE_SENTENCE_USER_FACING_DEFINITION>.
- **<CONCEPT_NAME>**: <ONE_SENTENCE_USER_FACING_DEFINITION>.

## Core Workflow

When this skill is invoked, execute the following steps in order.

1. **<STEP_NAME>.** <ONE_SENTENCE_ACTION>.
2. **<STEP_NAME>.** <ONE_SENTENCE_ACTION>.
3. **<STEP_NAME>.** <ONE_SENTENCE_ACTION>.

If the user's task does not map cleanly to these steps, <FREEFORM_FALLBACK_RULE>.

## Subcommands Design

This section lists the public workflows and low-level primitives the skill can route to. Procedural subcommands represent user-facing tasks; helper subcommands represent reusable authoring or inspection steps.

### Helper Subcommands

<HELPER_SUBCOMMAND_INTRO_OR_NO_HELPERS_SENTENCE>

| Subcommand | Use For | Load |
| --- | --- | --- |
| `<SUBCOMMAND>` | <PURPOSE> | `<DETAIL_PATH>` or this entrypoint |

### Procedural Subcommands

<PROCEDURAL_SUBCOMMAND_INTRO_OR_NO_PROCEDURAL_SUBCOMMANDS_SENTENCE>

| Subcommand | Use For | Load |
| --- | --- | --- |
| `<SUBCOMMAND>` | <PURPOSE> | `<DETAIL_PATH>` or this entrypoint |

### Misc Subcommands

<MISC_SUBCOMMAND_INTRO_OR_NO_MISC_SUBCOMMANDS_SENTENCE>

| Subcommand | Use For | Load |
| --- | --- | --- |
| `help` | Explain this skill and list public subcommands. | This entrypoint |

## Core Workflow Diagram

This diagram shows the normal handoff from user request to subcommand routing, helper composition, external validation or mutation, and final reporting. It emphasizes which component coordinates the work and which external service remains authoritative.

```mermaid
sequenceDiagram
    autonumber
    actor U as <USER_OR_SESSION>
    participant S as <PROPOSED_SKILL_ID>
    participant P as <PROCEDURAL_SUBCOMMAND_OR_STAGE>
    participant H as <HELPER_SUBCOMMAND_OR_STAGE>
    participant C as <EXTERNAL_SERVICE_OR_OUTPUT>

    U->>S: Ask to <NATURAL_LANGUAGE_REQUEST>.
    S->>P: Route to <WORKFLOW_OR_STAGE>.
    P->>H: Compose <HELPER_OR_INTERNAL_STEP>.
    H-->>P: Return <ARTIFACTS_OR_VALIDATION_NOTES>.
    P->>C: Call <EXTERNAL_VALIDATION_MUTATION_OR_INSPECTION>.
    C-->>P: Return <OUTPUTS_OR_DIAGNOSTICS>.
    P-->>S: Return <SUBCOMMAND_RESULT>.
    S-->>U: Return <FINAL_REPORT_OR_OUTPUT_PATH>.
```

## Calls To External Skills

This section identifies the project services or external skills the proposed skill depends on instead of reimplementing them. Include only true external dependencies, not internal helper subcommands.

```mermaid
flowchart TD
    classDef skill fill:#eef6ff,stroke:#2563eb,stroke-width:1.5px,color:#111827
    classDef route fill:#f8fafc,stroke:#94a3b8,stroke-width:1px,color:#334155

    Entry["<PROPOSED_SKILL_ID><br/>skill"]:::skill
    ExternalA["<EXTERNAL_SERVICE_OR_SKILL><br/>service"]:::skill

    R1["R1<br/><ROUTE_NAME>"]:::route

    Entry --> R1 --> ExternalA
```

| ID | Caller | Route | Callee | Calling condition |
| --- | --- | --- | --- | --- |
| R1 | `<CALLER>` | `<ROUTE>` | `<CALLEE>` | <NATURAL_LANGUAGE_CONDITION>. |

## Example Prompt And Expected AI Response

> **Warning:** The user/AI chat content below is for example purposes only. Implementations should learn its style, intent, and semantics rather than hardcoding the example content.

These examples show only the visible user prompt and the AI response content that should be returned to the user. Do not include hidden reasoning, chain-of-thought, scratchpad notes, private tool-selection deliberation, or thinking process in the AI response unless the user explicitly asks the skill to document that process.

### Event 001 - <SHORT_SCENARIO_TITLE>

> Time: `<EXAMPLE_TIME>` · Session: `<EXAMPLE_SESSION_OR_CONTEXT>`

User Prompt:

> <REALISTIC_USER_INVOCATION>

AI:

> <EXPECTED_VISIBLE_RESPONSE_SHAPE>

## Open Questions

- <ASSUMPTION_OR_UNRESOLVED_DECISION>.
