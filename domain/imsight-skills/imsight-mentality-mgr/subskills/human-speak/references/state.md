# Human Speak Flavor Selection and Scope Binding

## Workflow

1. For a management request, require an explicitly named flavor using the entrypoint's [Flavor Selection](../SKILL-MAIN.md#flavor-selection). If missing, show the inventory and retain the pending request without mutation.
2. Resolve each named flavor through **Flavor Bindings**, then validate all selectors under **Rule Selection** before any action.
3. Pass the flavor's identity, storage key, catalog contract, and source directory to the manager's [shared actions](../../../references/actions.md).
4. For ordinary communication, resolve previously selected flavor-qualified rules through [runtime precedence](../../../references/runtime-injection.md#effective-selection), then apply only their relevant definitions.
5. Report or retain the flavor, rule IDs, scope, and definitions through **Recall and Retention**. Preserve independent state for every flavor and agent.

If the task does not map cleanly to these steps, use the native planning tool to preserve the explicit flavor choice and shared scope boundaries. Missing flavor is a pending selection, not an empty active rule set or permission to apply every flavor.

## Flavor Bindings

| Flavor | State Identity | Storage Key | Rule Catalog | Action Detail |
| --- | --- | --- | --- | --- |
| `mark-life-style` | `human-speak/mark-life-style` | `human-speak-mark-life-style` | [h1–h8](mark-life-style-principles.md#principle-index) | [Mark-Life Style](../commands/mark-life-style.md) |
| `han-style` | `human-speak/han-style` | `human-speak-han-style` | [h1–h5](han-style-principles.md#principle-index) | [Han Style](../commands/han-style.md) |
| `ste-style` | `human-speak/ste-style` | `human-speak-ste-style` | [h1–h5](ste-style-principles.md#principle-index) | [STE Style](../commands/ste-style.md) |

Human Speak owns all flavor commands and references. A flavor is a flat subcommand, not a separately installed skill or nested subskill. Bind identities and storage keys explicitly in this table; do not derive arbitrary filesystem paths from user input.

For Mark-Life Style:

- Catalog: `.imsight-arts/mentality/human-speak-mark-life-style-principles.md`.
- Catalog marker key: `imsight-skill:imsight-mentality-mgr/human-speak-mark-life-style-principles`.
- Discovery marker key: `imsight-skill:imsight-mentality-mgr/human-speak-mark-life-style-catalog`.
- Project marker key: `imsight-skill:imsight-mentality-mgr/human-speak-mark-life-style-project`.
- Agent-memory namespace: `human-speak/mark-life-style`, with separate enabled and disabled rule sets.
- Source bundle: `references/sources/mark-life-style/`, published under the storage key above.

For Han Style:

- Catalog: `.imsight-arts/mentality/human-speak-han-style-principles.md`.
- Catalog marker key: `imsight-skill:imsight-mentality-mgr/human-speak-han-style-principles`.
- Discovery marker key: `imsight-skill:imsight-mentality-mgr/human-speak-han-style-catalog`.
- Project marker key: `imsight-skill:imsight-mentality-mgr/human-speak-han-style-project`.
- Agent-memory namespace: `human-speak/han-style`, with separate enabled and disabled rule sets.
- Source bundle: `references/sources/han-style/`, published under the storage key above.

For STE Style:

- Catalog: `.imsight-arts/mentality/human-speak-ste-style-principles.md`.
- Catalog marker key: `imsight-skill:imsight-mentality-mgr/human-speak-ste-style-principles`.
- Discovery marker key: `imsight-skill:imsight-mentality-mgr/human-speak-ste-style-catalog`.
- Project marker key: `imsight-skill:imsight-mentality-mgr/human-speak-ste-style-project`.
- Agent-memory namespace: `human-speak/ste-style`, with separate enabled and disabled rule sets.
- Source bundle: `references/sources/ste-style/`, published under the storage key above.

Use the state identity for memory, composition, and user-facing provenance. Qualify cross-flavor or cross-mentality rules as `human-speak/mark-life-style:h1`, `human-speak/han-style:h1`, or `human-speak/ste-style:h1`; these are different rules despite sharing a local ID. Within a correctly identified flavor block, store canonical local IDs such as `h1` beside their names. Use the storage key in the manager's generic `<mentality>` path and marker templates. Visible headings identify both Human Speak and the selected flavor.

## Rule Selection

After the flavor is explicit, accept its canonical IDs, canonical hyphenated names, and `all`, normalizing case and deduplicating in catalog order. Mark-Life Style defines `h1` through `h8`; Han Style and STE Style each define their own `h1` through `h5`. Resolve short IDs only inside the explicitly selected flavor. Validate the complete request; an unknown flavor, another flavor's qualified identifier or canonical name, or an ambiguous rule cannot be silently ignored or mapped to a different flavor.

Unqualified enable/disable defaults to agent memory. Omitted memory selectors expand once to every current rule of the chosen flavor. Explicit project actions require selectors or `all`, automatically ensure the complete flavor deployment and discovery, and update `AGENTS.md`. Naming one flavor never selects other flavors, and `all` never supplies an omitted flavor. Family-level wildcard activation and a remembered default-flavor flag are not defined.

Keep `P`, `M+`, and `M-` independently for each flavor, using `E = (P union M+) minus M-`. Each flavor is a separate rule family under the shared [priority contract](../../../references/priorities.md); there is no Human Speak-wide priority. A fresh enable raises that flavor's scoped family priority and advances the shared counter without changing other flavors' stored selections or numbers. Adding a future flavor does not enable it or copy rules from an existing one. These actions do not silently replace another flavor; any intended combination or removal names the affected flavors explicitly. Resolve conflicts by agent-memory-over-project precedence, then higher family priority within the same scope, never inventory order.

No registered flavor has independent child settings. Disabling a flavor's last project rule removes its entire application block and family priority after required deployment preparation, preserving discovery, sources, the shared next-project-priority counter, and agent memory. A partial disable preserves the family priority. Disabling its last memory-enabled rule removes only that memory priority, retaining explicit negative overrides and the shared next-memory-priority counter; it writes no files.

## Recall and Retention

A direct Human Speak recall without a flavor opens the chooser, even if project or memory state already names one. A manager-wide recall can report other mentalities and list Human Speak flavors for the user's choice; it must not silently infer the missing flavor. Once named, recall reports that flavor's project rules and priority, remembered enables/disables and memory priority, effective IDs, practical meanings, applicability, and definition retention. No action or default is inferred from a saved report or catalog.

Ordinary communication may use already selected flavor-qualified rules without asking the user to choose again on every reply. This is application of existing state, not an unqualified management call. Unknown flavor state remains unresolved and must not be remapped to a known flavor.

Read definitions before retaining them. For each deployed, usable rule, retain the project root, catalog path, and rule ID; otherwise retain the operative definition, applicability, and judgment notes in chat context. Keep enabled and disabled overrides with their flavor identity, memory family priority, and shared memory counter across a supported same-agent handoff. Definition retention does not create a default flavor for later management requests. A pending chooser action is ordinary conversation context, not an activation record or a session file.

## Guardrails

- DO NOT fill an omitted flavor from project state, remembered use, or the sole available option.
- DO NOT apply `all` across flavors or accept unqualified rule IDs before the flavor is chosen.
- DO NOT share a project block, memory namespace, or source-bundle identity between different flavors.
- DO NOT write memory overrides or a pending chooser request into project files.
- DO NOT silently replace another flavor when enabling the requested one.
