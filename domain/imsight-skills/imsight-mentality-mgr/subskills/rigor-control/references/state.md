# Rigor Control Flavor Selection and Scope Binding

## Workflow

1. Require a named flavor through the [chooser](../SKILL-MAIN.md#flavor-selection).
2. Bind its identity below and validate selectors before effects.
3. Execute [shared actions](../../../references/actions.md), or apply already selected flavor rules under [runtime precedence](../../../references/runtime-injection.md#effective-selection).
4. Report qualified IDs and retain meanings without copying state across flavors or agents.

For other requests, use the native planning tool; a pending choice authorizes no mutation.

## Flavor Bindings

| Flavor | State identity | Storage key | Canonical catalog | Command |
| --- | --- | --- | --- | --- |
| `product-showcase` | `rigor-control/product-showcase` | `rigor-control-product-showcase` | [`rc1`–`rc5`](product-showcase-principles.md#principle-index) | [Detail](../commands/product-showcase.md) |

Use only declared bindings. Catalog path: `.imsight-arts/mentality/<storage-key>-principles.md`; catalog marker key: `imsight-skill:imsight-mentality-mgr/<storage-key>-principles`. Memory uses the state identity. Each flavor has its own entry in the [unified section](../../../references/runtime-injection.md#unified-mentality-section), labeled with Rigor Control and the flavor.

Qualify cross-family IDs, for example `rigor-control/product-showcase:rc1`; local `rc1` is sufficient inside its identified entry. Flavors remain flat commands owned by this child.

## Rule Selection

Accept the named flavor's IDs, canonical names, and `all`, case-insensitively; deduplicate in catalog order. Reject invalid, ambiguous, foreign-flavor, or unknown selectors as a whole request. Shared defaults apply: memory if scope is omitted, all current rules if memory selectors are omitted, and explicit selectors for project actions. Neither `all` nor prior state supplies a missing flavor.

Each flavor has independent `P`, `M+`, `M-`, and scoped [family priority](../../../references/priorities.md). Enabling one never replaces another or selects future flavors. There are no child settings or family-wide activation flags. Disabling the last project rule leaves a reference-only entry without family priority; removing the last memory enable preserves negative overrides and the memory counter. Scope and priority precedence are shared, never flavor inventory order.

## Recall and Retention

Management recall still needs a flavor; ordinary application of existing flavor-qualified rules does not. Report scoped selections and priorities, effective IDs, meanings, applicability, and retention under the shared contract. Keep deployed definitions by project path and ID or retain operative content inline. Handoffs preserve flavor identity and negative overrides, never a remembered default-flavor flag. Reports and pending chooser state supply no activation.

## Guardrails

- DO NOT infer missing flavors or apply `all` across them.
- DO NOT combine flavors into an undifferentiated entry or memory namespace.
- DO NOT silently replace another flavor or write pending choices into project files.
