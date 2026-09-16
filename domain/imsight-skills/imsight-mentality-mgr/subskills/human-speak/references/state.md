# Human Speak Flavor Selection and Scope Binding

## Workflow

1. Require a named flavor through the [chooser](../SKILL-MAIN.md#flavor-selection).
2. Bind its identity below and validate selectors before effects.
3. Execute [shared actions](../../../references/actions.md), or apply already selected flavor rules under [runtime precedence](../../../references/runtime-injection.md#effective-selection).
4. Report qualified IDs and retain meanings without copying state across flavors or agents.

For other requests, use the native planning tool; a pending choice authorizes no mutation.

## Flavor Bindings

| Flavor | State identity | Storage key | Canonical catalog | Command |
| --- | --- | --- | --- | --- |
| `mark-life-style` | `human-speak/mark-life-style` | `human-speak-mark-life-style` | [h1–h8](mark-life-style-principles.md#principle-index) | [Detail](../commands/mark-life-style.md) |
| `han-style` | `human-speak/han-style` | `human-speak-han-style` | [h1–h5](han-style-principles.md#principle-index) | [Detail](../commands/han-style.md) |
| `ste-style` | `human-speak/ste-style` | `human-speak-ste-style` | [h1–h5](ste-style-principles.md#principle-index) | [Detail](../commands/ste-style.md) |

Use only declared bindings. Catalog path: `.imsight-arts/mentality/<storage-key>-principles.md`; catalog marker key: `imsight-skill:imsight-mentality-mgr/<storage-key>-principles`. Memory uses the state identity. Each flavor has its own entry in the [unified section](../../../references/runtime-injection.md#unified-mentality-section), labeled with Human Speak and the flavor.

Qualify cross-family IDs, for example `human-speak/han-style:h1`; local `h1` is sufficient inside its identified entry. Flavors remain flat commands owned by this child.

## Rule Selection

Accept the named flavor's IDs, canonical names, and `all`, case-insensitively; deduplicate in catalog order. Reject invalid, ambiguous, foreign-flavor, or unknown selectors as a whole request. Shared defaults apply: memory if scope omitted, all current rules if memory selectors omitted, explicit selectors for project actions. Neither `all` nor prior state supplies a missing flavor.

Each flavor has independent `P`, `M+`, `M-`, and scoped [family priority](../../../references/priorities.md). Enabling one never replaces another or selects future flavors. There are no child settings or family-wide activation flags. Last-project-rule disable leaves a reference-only entry without family priority; last-memory-enable removal preserves negative overrides and the memory counter. Scope/priority precedence is shared, never flavor inventory order.

## Recall and Retention

Management recall still needs a flavor; ordinary application of existing flavor-qualified rules does not. Report scoped selections/priorities, effective IDs, meanings, applicability, and retention under the shared contract. Keep deployed definitions by project path/ID or retain operative content inline. Handoffs preserve flavor identity and negative overrides, never a remembered default-flavor flag. Reports and pending chooser state supply no activation.

## Guardrails

- DO NOT infer missing flavors or apply `all` across them.
- DO NOT combine flavors into an undifferentiated entry or memory namespace.
- DO NOT silently replace another flavor or write pending choices into project files.
