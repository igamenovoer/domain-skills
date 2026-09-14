# Ponytail Constructive Principles

This catalog describes available principles, not activation state. Project or agent selections determine which principles apply. Every selected principle operates within the resolved task and edit boundary; all simplifications must preserve the required contract and sensible edge-case defenses.

## Principle Index

| ID | Canonical name | First intensity | Reminder |
| --- | --- | --- | --- |
| p1 | reuse-existing | safe | Reuse suitable project helpers and conventions after checking their behavior. |
| p2 | prefer-proven-primitives | safe | Prefer suitable standard-library and native facilities with the required semantics. |
| p3 | avoid-unneeded-dependencies | safe | Avoid a new dependency when a reliable existing solution suffices. |
| p4 | fix-owning-boundary | safe | Trace affected callers and fix the root cause at the correct boundary. |
| p5 | remove-proven-redundancy | safe | Remove demonstrably dead or redundant work whose purpose is already satisfied. |
| p6 | verify-changed-risks | safe | Reuse existing evidence; add checks only for material changed risks it does not cover. |
| p7 | document-real-limits | safe | Make deliberate constraints, ceilings, and revisit triggers explicit. |
| p8 | collapse-structure | normal | Consider collapsing structures whose present value does not justify their cost. |
| p9 | compact-implementation | normal | Consolidate implementation when it reduces maintenance effort without obscuring behavior. |
| p10 | remove-unused-flexibility | extreme | Consider removing variation points without an established requirement or consumer. |
| p11 | replace-existing-dependencies | extreme | Consider replacing an existing dependency after checking contracts and migration costs. |
| p12 | challenge-speculative-work | extreme | Question machinery for hypothetical needs while delivering the complete requested outcome. |

Safe contains p1–p7. Normal adds p8 and p9. Extreme adds p10–p12. Presets select increasingly broad simplification opportunities; they do not weaken the validity requirements below or imply permission to revise existing infrastructure. Edit scope is independent: new-code-only preserves established infrastructure; destructive permits only minimal revisions of infrastructure related to the assigned task. Broad codebase refactoring requires that explicit assignment.

The **Representative Do / Don't comparisons** below follow the Brooks catalog style: a named rule, a linked source, contrasting code, and a judgment note. They adapt official Ponytail examples at the pinned revision; added teaching cases are identified explicitly. Read each comparison with its stated contract. Snippets show the relevant change, not a complete application; the examples and their assumptions are included here so applying or deploying the catalog requires no upstream checkout.

## Safe Rules

### p1 — reuse-existing

Search the relevant codebase for a helper, type, or convention before writing another implementation. Check its input, error, normalization, and side-effect contract; similarity in name is not proof of suitability.

**Representative Do / Don't comparison** ([Ponytail — reuse-money benchmark](sources/benchmark-cases.md#reuse-money)). Adapted from the upstream good/bad implementations with type annotations. The existing `money.format_money` helper returns the project's currency format, including thousands separators.

**Don't:** Reimplement the display format in a new invoice caller and lose the established grouping behavior.

```python
def line_item(name: str, cents: int, qty: int) -> str:
    return f"{name} x{qty} - ${cents * qty / 100:.2f}"
# line_item("Pallet", 61728, 2) -> "Pallet x2 - $1234.56"
```

**Do:** Call the existing helper through its supported interface.

```python
from money import format_money

def line_item(name: str, cents: int, qty: int) -> str:
    return f"{name} x{qty} - {format_money(cents * qty)}"
# line_item("Pallet", 61728, 2) -> "Pallet x2 - $1,234.56"
```

**Judgment:** Reuse must not force callers into the wrong bounded context or require restructuring an unrelated module. Under new-code-only, call the existing helper as supported; do not rewrite it merely to make the new caller shorter.

### p2 — prefer-proven-primitives

Prefer a standard-library or native platform facility when its actual semantics, supported versions, and accessibility meet the task. Compare behavior before accepting a smaller implementation.

**Representative Do / Don't comparison** ([Ponytail — Group By](sources/group-by.md)). The target runtime supports `Object.groupBy`; callers need groups indexed by status strings, including names such as `constructor`.

**Don't:** Maintain a plain-object accumulator that mistakes inherited property names for existing groups.

```javascript
const byStatus = orders.reduce((acc, order) => {
  (acc[order.status] ??= []).push(order);
  return acc;
}, {});
```

**Do:** Use the native grouping operation and account for its null-prototype result in consumers.

```javascript
const byStatus = Object.groupBy(orders, order => order.status);
const hasPending = Object.hasOwn(byStatus, "pending");
```

**Judgment:** Standard availability is not universal equivalence. A native primitive that lacks required timezone, validation, or platform behavior does not satisfy the task. If new-code-only scope requires a caller to use an established infrastructure abstraction, reuse that abstraction rather than bypassing it to reach a primitive directly.

### p3 — avoid-unneeded-dependencies

Before adding a package, compare suitable installed dependencies, native facilities, and a small maintainable implementation. Consider ongoing updates and integration costs, not just the number of package entries.

**Representative Do / Don't comparison** ([Ponytail — Deep Clone](sources/deep-clone.md)). The task copies structured-cloneable data, including dates and cycles, on a supported runtime; it does not require functions or custom class behavior to survive cloning.

**Don't:** Add Lodash solely for this new copy operation when the built-in meets that contract.

```javascript
import { cloneDeep } from "lodash"; // Newly added dependency.

const copy = cloneDeep(original);
```

**Do:** Use the built-in clone operation.

```javascript
const copy = structuredClone(original);
```

Do not substitute a JSON stringify/parse round trip: it changes supported types and fails on cycles. `structuredClone` is also not a universal replacement for every `cloneDeep` use; inspect the actual values and required semantics.

**Judgment:** This rule concerns avoiding unnecessary additions. It does not by itself call for removing an existing dependency; that is p11 and still subject to edit scope. Adding a small feature must not become a dependency migration project.

### p4 — fix-owning-boundary

Read the affected flow and relevant callers before choosing a fix location. Prefer one correct change at the decision's owner over repeated symptom patches, when that location is permitted by the task and edit scope.

**Representative Do / Don't comparison** ([Ponytail — trace-transfer benchmark](sources/benchmark-cases.md#trace-transfer)). These excerpts assume positive integer cents have already been validated and the enclosing operation supplies the required transaction/serialization boundary. A task-authorized shared repair or destructive scope permits this fix.

**Don't:** Guard only the transfer named in the report while withdrawals still reach the unguarded debit.

```python
def _debit(acct: str, cents: int) -> None:
    balances[acct] = balances.get(acct, 0) - cents

def transfer(src: str, dst: str, cents: int) -> None:
    if balances.get(src, 0) < cents:
        raise ValueError("insufficient funds")
    _debit(src, cents)
    deposit(dst, cents)

def withdraw(acct: str, cents: int) -> int:
    _debit(acct, cents)
    return cents
```

**Do:** Protect the shared debit; both existing callers keep using it.

```python
def _debit(acct: str, cents: int) -> None:
    balance = balances.get(acct, 0)
    if balance < cents:
        raise ValueError("insufficient funds")
    balances[acct] = balance - cents
```

**Judgment:** New-code-only cannot silently widen into a shared-infrastructure repair. If the valid fix requires that change, use a precise existing task authorization or surface the boundary conflict; do not create a misleading caller-only workaround. In destructive scope, update only the affected boundary and necessary callers, not surrounding services that happen to be nearby.

### p5 — remove-proven-redundancy

Remove dead code, duplicated calculations, or repeated checks only after establishing that no supported behavior depends on them. Examine actual callers, entry points, and invariants; a text search with no hits may miss reflective or external uses.

**Representative Do / Don't comparison** ([Ponytail — Debounce](sources/debounce.md)). The redundant-guard variant is added here to explain upstream's unconditional `clearTimeout`. This browser-local variable contains only `undefined` or a timer identifier; canceling an absent or expired timer has no effect.

**Don't:** Add a separate presence branch that supplies no additional guarantee.

```javascript
if (debounceTimer !== undefined) {
  clearTimeout(debounceTimer);
}
debounceTimer = setTimeout(() => runSearch(query), 300);
```

**Do:** Rely on the timer API's defined cancellation behavior.

```javascript
clearTimeout(debounceTimer);
debounceTimer = setTimeout(() => runSearch(query), 300);
```

The existing `runSearch` still owns input policy, request failures, and stale-result handling. Removing this redundant branch gives no reason to remove those distinct safeguards.

**Judgment:** A rare condition is not an impossible one. Preserve checks that defend different boundaries, prevent data loss, or express distinct domain constraints. Under new-code-only, cleanup is limited to new task code; established infrastructure is context, not a cleanup target.

### p6 — verify-changed-risks

Match verification effort to the plausible regression and its consequence. First inspect the changed behavior, relevant contracts, and existing coverage. Reuse suitable tests and required repository checks; add or extend a test only when a material risk remains uncovered. An edit alone does not require a new test, and adequate existing evidence can mean no new tests at all.

Test the observable product contract at a suitable existing boundary. Avoid suites for every private helper, assertions about internal call order, duplicated coverage at multiple levels without a distinct risk, and exhaustive checks of trusted runtime features unrelated to the product's inputs. After required checks pass and the material changed risks have sufficient evidence, stop; broaden verification when a failure, further change, or specific unresolved risk warrants it.

**Representative Do / Don't comparison** ([Ponytail — Deep Clone](sources/deep-clone.md)). This added teaching case applies the upstream replacement inside `openSettingsDraft`, the editor's existing public operation for making an independent draft. This path accepts validated plain settings data, with no dates, cycles, maps, or functions. An existing regression already checks that draft edits leave the saved settings unchanged.

**Don't:** Add a runtime conformance suite for unrelated value types just because the implementation now calls `structuredClone`.

```javascript
import assert from "node:assert/strict";

assert.deepEqual(structuredClone(new Date(0)), new Date(0));
assert.deepEqual(structuredClone(new Map([["x", 1]])), new Map([["x", 1]]));
const cyclic = {};
cyclic.self = cyclic;
const copy = structuredClone(cyclic);
assert.equal(copy.self, copy);
assert.throws(() => structuredClone({ callback() {} }), { name: "DataCloneError" });
```

**Do:** Reuse the existing product regression shown below. Add or adapt it only if this behavior lacks adequate coverage.

```javascript
import assert from "node:assert/strict";

const saved = { appearance: { theme: "light" } };
const draft = openSettingsDraft(saved);
draft.appearance.theme = "dark";

assert.equal(saved.appearance.theme, "light");
```

**Judgment:** One focused regression can be sufficient; test count and coverage percentages are not completion targets. A low-impact change with clear semantics may need only inspection or an existing check. Money, security, persistence, or a changed boundary can justify more evidence when concrete failure consequences warrant it; that still does not imply every case at every test level. Preserve required edge-case defenses without inventing a new test for each unchanged safeguard. Frameworks and fixtures are acceptable when they help test the actual behavior. In read-only review, identify a specific material evidence gap before recommending more tests, and do not execute or write them automatically.

### p7 — document-real-limits

Record a deliberate simplification's actual ceiling and the condition that would justify changing it when those facts matter to future maintainers. Preserve necessary tuning, calibration, and operational controls.

**Representative Do / Don't comparison** ([Ponytail — Rules](sources/ponytail-rules.md#rules)). The upstream global-lock comment is expanded into a teaching fragment; the validated transfer and lock are existing infrastructure. Current throughput requirements permit serialization.

**Don't:** Present a global lock as a solution without a concurrency ceiling.

```python
# Concurrency solved.
with global_lock:
    move_cents(src, dst, cents)
```

**Do:** Name the actual limit and the evidence that would justify revisiting it.

```python
# Serializes all transfers; consider ordered per-account locks
# if measured lock contention prevents meeting the throughput requirement.
with global_lock:
    move_cents(src, dst, cents)
```

A hardware calibration parameter remains necessary when physical tolerances require it, even if a fixed value would be shorter. A documented limit never substitutes for meeting the current requirement.

**Judgment:** Use the repository's established comment or decision-record convention; a `ponytail:` prefix is optional when compatible. Add a note only for a real limitation, not every simple implementation. A comment does not make a violated requirement acceptable, and an unknown ceiling should not be presented as measured. New-code-only scope does not authorize editing unrelated old comments.

## Normal Additions

### p8 — collapse-structure

Actively consider collapsing wrappers, factories, interfaces, or layers when they add coordination cost without hiding a useful decision, protecting a contract, or serving a current requirement.

**Representative Do / Don't comparison** ([Ponytail — Debounce](sources/debounce.md)). Adapted to call an established `runSearch` that owns validation, request errors, rendering, and stale-result policy. This is one new input lasting for the page lifetime, with no existing debounce helper or independent wrapper contract.

**Don't:** Introduce an otherwise unneeded general wrapper for this one local timer.

```javascript
function debounce(func, delay) {
  let timeoutId;
  return function (...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func(...args), delay);
  };
}

const debouncedSearch = debounce(runSearch, 300);
searchInput.addEventListener("input", event => {
  debouncedSearch(event.target.value);
});
```

**Do:** Keep the timer with its sole new caller and preserve the existing search operation.

```javascript
let debounceTimer;
searchInput.addEventListener("input", event => {
  const query = event.target.value;
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(() => runSearch(query), 300);
});
```

If the input can unmount, retain listener/timer cleanup. If an established helper already supplies required cancellation, receiver binding, or shared behavior, use it; a single caller alone is not grounds to bypass it.

**Judgment:** One implementation or caller alone is not enough evidence. Retain interfaces that isolate volatile dependencies, test seams that protect behavior, public contracts, and adapters with real translation responsibilities. A new-code-only task preserves those established structures even if a reviewer would design them differently today.

### p9 — compact-implementation

Consider consolidating functions, files, and control flow when it reduces the concepts and locations needed to maintain the task's behavior. Prefer explicit readable control flow over line-count targets.

**Representative Do / Don't comparison** ([Ponytail — CSV Sum](sources/csv-sum.md)). Adapted to retain explicit file lifetime and decimal arithmetic. Existing input validation has checked the required `amount` header, row structure, and finite decimal values; both variants preserve that validation and propagate unexpected conversion or I/O failures.

**Don't:** Keep unnecessary accumulator plumbing when the transformation is just a sum.

```python
import csv
from decimal import Decimal

total = Decimal("0")
with open("sales.csv", encoding="utf-8", newline="") as sales:
    for row in csv.DictReader(sales):
        total += Decimal(row["amount"])
print(total)
```

**Do:** Express the sum directly while retaining the resource boundary and empty-input result.

```python
import csv
from decimal import Decimal

with open("sales.csv", encoding="utf-8", newline="") as sales:
    total = sum(
        (Decimal(row["amount"]) for row in csv.DictReader(sales)),
        start=Decimal("0"),
    )
print(total)
```

The loop remains preferable if rows need distinct validation, error reporting, or multiple coordinated updates. Unlike upstream's shortest snippet, this comparison does not postpone file closing or required malformed-input handling.

**Judgment:** Fewer files is not universally better. Preserve repository placement conventions, clear ownership boundaries, and useful names. Under new-code-only, compact only the newly introduced implementation; moving existing infrastructure into a new file is still an existing-code change.

## Extreme Additions

### p10 — remove-unused-flexibility

Consider removing configuration, extension points, optional branches, and supported variations only when evidence establishes that they have no required consumer or operational role within the assigned task.

**Representative Do / Don't comparison** ([Ponytail — Debounce, advanced options](sources/debounce.md#advanced-debounce-with-cancel--immediate-options)). The task needs a trailing-edge callback and cancellation on teardown; no consumer requires leading-edge execution. Both variants below retain cancellation and clear timer state when canceled.

**Don't:** Add an unused immediate mode and its argument/state machinery to this new helper.

```javascript
function debounce(func, delay, options = {}) {
  let timeoutId;
  let lastArgs;
  const debounced = (...args) => {
    lastArgs = args;
    clearTimeout(timeoutId);
    if (options.immediate && !timeoutId) func(...args);
    timeoutId = setTimeout(() => {
      if (!options.immediate) func(...lastArgs);
      timeoutId = undefined;
    }, delay);
  };
  debounced.cancel = () => {
    clearTimeout(timeoutId);
    timeoutId = undefined;
  };
  return debounced;
}
```

**Do:** Keep the required trailing-edge behavior and cancellation without the unused variation point.

```javascript
function debounce(func, delay) {
  let timeoutId;
  const debounced = (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func(...args), delay);
  };
  debounced.cancel = () => {
    clearTimeout(timeoutId);
    timeoutId = undefined;
  };
  return debounced;
}
```

**Judgment:** No in-repository setter is not proof that an environment option is unused. Preserve external consumers, rollback controls, accessibility features, and calibration knobs required by the actual contract. Under destructive scope, investigate only relevant variation points; do not scan the codebase for unrelated flags to delete.

### p11 — replace-existing-dependencies

Consider replacing a dependency with a suitable runtime facility or smaller maintained solution after accounting for semantic differences, affected consumers, and transition costs.

**Representative Do / Don't comparison** ([Ponytail — Number Formatting](sources/number-formatting.md)). This task explicitly concerns replacing an existing formatter in destructive scope. Its relevant consumers need US-dollar display with two decimals and percentages with one decimal; supported values and rounding behavior must be checked before accepting the migration.

**Don't:** Retain the package solely because these calls already use it, once the task's equivalence checks establish a suitable built-in replacement.

```javascript
import numeral from "numeral";

const price = numeral(1234567.89).format("$1,234.00");
const percentage = numeral(0.745).format("0.0%");
```

**Do:** Use explicit native formatting options for the required precision.

```javascript
const price = new Intl.NumberFormat("en-US", {
  style: "currency", currency: "USD",
  minimumFractionDigits: 2, maximumFractionDigits: 2,
}).format(1234567.89); // "$1,234,567.89"

const percentage = new Intl.NumberFormat("en-US", {
  style: "percent", minimumFractionDigits: 1, maximumFractionDigits: 1,
}).format(0.745); // "74.5%"
```

The explicit percent precision corrects the upstream example: default percent formatting does not preserve one fractional digit. Compact suffixes, rounding, signs, and locale behavior can also differ. Keep the dependency for consumers whose required behavior is not covered, and remove it from the manifest only after accounting for all uses within an authorized migration.

**Judgment:** Security, parser, internationalization, and platform edge behavior often justify a mature dependency. Do not hand-roll those contracts to reduce package count. Under new-code-only, a rule whose target is an existing dependency replacement is inapplicable; adding new code that avoids an unnecessary new dependency is instead covered by p3. Destructive scope still requires the replacement to serve the assigned task.

### p12 — challenge-speculative-work

Question mechanisms justified only by hypothetical future scale, consumers, or variation. Choose a smaller complete solution when it meets every assigned requirement; explain a meaningful deferred option and its trigger when useful.

**Representative Do / Don't comparison** ([Ponytail — Countdown Timer](sources/react-countdown.md)). The requested new component is a plain, automatically starting seconds display with a fixed initial value per mount. It tolerates timer scheduling drift and does not need pause/reset controls. The helper and controls in the first version are proposed new machinery, not an existing interface to remove.

**Don't:** Build an unrequested control surface and supporting hook before delivering that display.

```jsx
export function TimerWithHook() {
  const { seconds, isActive, start, pause, reset } = useCountdown(60);
  return (
    <div>
      <div>{seconds}s</div>
      <button onClick={isActive ? pause : start}>
        {isActive ? "Pause" : "Start"}
      </button>
      <button onClick={reset}>Reset</button>
    </div>
  );
}
```

**Do:** Implement the requested readout, retaining interval cleanup and the zero boundary.

```jsx
import { useEffect, useState } from "react";

export function CountdownTimer({ seconds }) {
  const [remaining, setRemaining] = useState(seconds);
  useEffect(() => {
    if (remaining <= 0) return;
    const timer = setInterval(() => {
      setRemaining(value => Math.max(0, value - 1));
    }, 1000);
    return () => clearInterval(timer);
  }, [remaining]);
  return <div>{remaining}s</div>;
}
```

The owner supplies a finite nonnegative integer duration; changing the initial duration starts a new mount. If the actual task requires prop-driven resets, pause/resume, completion callbacks, or elapsed-time accuracy, implement those requirements. A tick counter is not a deadline clock, and deleting a requested capability is not simplification.

**Judgment:** Do not ship a reduced requirement and ask whether the user wanted the full version. Preserve requested features and explanations. Extreme intensity changes the opportunities considered, not the user's goal. Repository-wide deletion or restructuring requires that explicit assignment even in destructive scope.

## Validity Requirements

These determine whether a simplification is acceptable at any intensity; they are not optional selectable rules or automatic project activation. Preserve the required input and output contract, anticipated invalid-input handling, meaningful boundary conditions, security and accessibility requirements, and error behavior that prevents data loss. Keep necessary runtime compatibility, hardware calibration, and operational controls.

A shorter replacement must handle the cases relevant to the task, not merely its easiest example. An email validator cannot be replaced with an at-sign check without establishing that this meets the actual validation contract. An idempotent operation can still require retries for transient failures. A rare edge case remains relevant unless a validated invariant excludes it or it is demonstrably outside the supported contract.

Unknown equivalence is an evidence gap. Retain the behavior or identify the missing evidence instead of treating uncertainty as permission to remove it. Avoid speculative defensive scaffolding at every internal call, but do not discard an existing safeguard without understanding the guarantee it provides.

Preserve the assigned task boundary as well as behavior. In destructive scope, make the smallest coherent infrastructure change related to the task, including necessary caller updates. Do not use a nearby simplification opportunity to initiate unrelated cleanup or codebase-wide refactoring. In new-code-only scope, preserve existing infrastructure and apply selected rules to newly written callers and additions.

## Applicability

Apply selected rules to coding, design, fixes, and explicit simplification reviews within the resolved task and edit scope. Existing code may be read as context even when it cannot be revised. A selected rule without a permitted target is inapplicable; it does not grant a broader edit surface. Non-coding prose is outside this mentality, and requested explanations remain part of the task.

The ordered reuse preferences apply only when their rules are selected and alternatives satisfy the contract. Deployment lists all principles for discovery without enabling them. Review may use explicit criteria for one invocation while leaving project and agent selections unchanged.

## Provenance

Adapted from [Ponytail by DietrichGebert](sources/index.md), revision `356918eba965ee1eac64bd3a7f0dd02108350de5`, under the MIT license. Each comparison links a bundled source file; origin URLs and revision details live in those files. Examples are shortened or adapted for the selected rule; p5's redundant branch, p6's behavioral checks, and p7's surrounding lock code are added teaching material. Conditions, type annotations, precision settings, file handling, and cleanup adaptations are not verbatim benchmark output. Source line-count and safety claims are not guarantees of this catalog.

This adaptation replaces persistent persona/intensity hooks and blanket shortest-code rules with scoped principle selection, three cumulative intensities, independent edit boundaries, and explicit behavior-preservation requirements. All comparison code and judgment needed for use appear in this catalog; the bundled source directory supplies offline originals and attribution, with no required web lookup. No upstream installation, mode file, or service is needed to use these definitions.

### Example License

MIT License

Copyright (c) 2026 DietrichGebert

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
