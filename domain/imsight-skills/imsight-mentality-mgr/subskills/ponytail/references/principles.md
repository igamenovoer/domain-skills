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

The **Representative Do / Don't comparisons** are original illustrative scenarios. Their stated contracts explain the intended design move; snippets are teaching fragments, not complete applications or evidence about this repository. Preserve those contracts and use the judgment notes when adapting the ideas.

## Safe Rules

### p1 — reuse-existing

Search the relevant codebase for a helper, type, or convention before writing another implementation. Check its input, error, normalization, and side-effect contract; similarity in name is not proof of suitability.

**Representative Do / Don't comparison.** A project already owns title normalization, reserved names, and collision handling in `project_slugs.for_title`.

**Don't:** Create a second naming policy in the new document caller.

```python
slug = title.lower().replace(" ", "-")
document_store.create(slug, content)
```

**Do:** Use the established naming operation.

```python
slug = project_slugs.for_title(title)
document_store.create(slug, content)
```

The caller still handles the store's documented failure cases. Reuse does not permit bypassing validation or changing the existing helper.

**Judgment:** Reuse must not force callers into the wrong bounded context or require restructuring an unrelated module. Under new-code-only, call the existing helper as supported; do not rewrite it merely to make the new caller shorter.

### p2 — prefer-proven-primitives

Prefer a standard-library or native platform facility when its actual semantics, supported versions, and accessibility meet the task. Compare behavior before accepting a smaller implementation.

**Representative Do / Don't comparison.** A command receives a list of hashable option names and must remove duplicates while preserving their first occurrence, including for empty input.

**Don't:** Maintain a separate scan when a supported language primitive supplies that behavior.

```python
unique_names = []
for name in names:
    if name not in unique_names:
        unique_names.append(name)
```

**Do:** Use insertion-ordered dictionary keys on the project's supported Python runtime.

```python
unique_names = list(dict.fromkeys(names))
```

This choice requires hashable values and ordinary equality semantics. Unhashable records or domain-specific equality need a different implementation.

**Judgment:** Standard availability is not universal equivalence. A native primitive that lacks required timezone, validation, or platform behavior does not satisfy the task. If new-code-only scope requires a caller to use an established infrastructure abstraction, reuse that abstraction rather than bypassing it to reach a primitive directly.

### p3 — avoid-unneeded-dependencies

Before adding a package, compare suitable installed dependencies, native facilities, and a small maintainable implementation. Consider ongoing updates and integration costs, not just the number of package entries.

**Representative Do / Don't comparison.** A new report only needs the sum of at most 10,000 nonnegative integer counts, each at most one million. No array computation or array return type is required.

**Don't:** Add an array package solely to calculate this scalar total.

```python
import numpy as np  # New dependency for this report alone.

total = int(np.asarray(counts, dtype=np.int64).sum())
```

**Do:** Use integer arithmetic already supplied by the language.

```python
total = sum(counts)
```

The result is an integer and empty input gives zero. This example does not suggest replacing a package already needed for vectorized calculations elsewhere.

**Judgment:** This rule concerns avoiding unnecessary additions. It does not by itself call for removing an existing dependency; that is p11 and still subject to edit scope. Adding a small feature must not become a dependency migration project.

### p4 — fix-owning-boundary

Read the affected flow and relevant callers before choosing a fix location. Prefer one correct change at the decision's owner over repeated symptom patches, when that location is permitted by the task and edit scope.

**Representative Do / Don't comparison.** Both a command-line tool and an HTTP endpoint rename documents through `set_label`. The assigned fix permits changing that shared operation, and blank labels violate its contract.

**Don't:** Reject blank labels in only the HTTP caller while leaving other callers able to store them.

```python
def rename_http(document, label):
    if not label.strip():
        raise InvalidLabel()
    set_label(document, label)

def set_label(document, label):
    document.label = label
```

**Do:** Protect the invariant in the shared operation that both callers use.

```python
def set_label(document, label):
    if not label.strip():
        raise InvalidLabel()
    document.label = label
```

Keep each caller's required error translation. Normalization, authorization, and persistence retain their existing owners.

**Judgment:** New-code-only cannot silently widen into a shared-infrastructure repair. If the valid fix requires that change, use a precise existing task authorization or surface the boundary conflict; do not create a misleading caller-only workaround. In destructive scope, update only the affected boundary and necessary callers, not surrounding services that happen to be nearby.

### p5 — remove-proven-redundancy

Remove dead code, duplicated calculations, or repeated checks only after establishing that no supported behavior depends on them. Examine actual callers, entry points, and invariants; a text search with no hits may miss reflective or external uses.

**Representative Do / Don't comparison.** The task iterates a local dictionary while no code mutates it. Each key obtained from that iteration is already present in the same dictionary.

**Don't:** Recheck membership before reading each value.

```python
for key in limits:
    if key in limits:
        render_limit(key, limits[key])
```

**Do:** Iterate the known key/value pairs directly.

```python
for key, value in limits.items():
    render_limit(key, value)
```

This reasoning does not remove validation of externally supplied keys or protections against concurrent mutation.

**Judgment:** A rare condition is not an impossible one. Preserve checks that defend different boundaries, prevent data loss, or express distinct domain constraints. Under new-code-only, cleanup is limited to new task code; established infrastructure is context, not a cleanup target.

### p6 — verify-changed-risks

Match verification effort to the plausible regression and its consequence. First inspect the changed behavior, relevant contracts, and existing coverage. Reuse suitable tests and required repository checks; add or extend a test only when a material risk remains uncovered. An edit alone does not require a new test, and adequate existing evidence can mean no new tests at all.

Test the observable product contract at a suitable existing boundary. Avoid suites for every private helper, assertions about internal call order, duplicated coverage at multiple levels without a distinct risk, and exhaustive checks of trusted runtime features unrelated to the product's inputs. After required checks pass and the material changed risks have sufficient evidence, stop; broaden verification when a failure, further change, or specific unresolved risk warrants it.

**Representative Do / Don't comparison.** A report loader now uses the standard UTF-8 text-reading operation. Its existing product regression covers a non-ASCII heading, and the required missing-file behavior has not changed.

**Don't:** Add a separate conformance suite for the standard library's unrelated encodings and argument combinations merely because the call changed.

```python
for encoding in ("utf-8", "utf-16", "utf-32"):
    path.write_text("sample", encoding=encoding)
    assert path.read_text(encoding=encoding) == "sample"
```

**Do:** Reuse the existing product regression; add or adapt it only if the relevant behavior lacks adequate coverage.

```python
path.write_text("Résumé\n", encoding="utf-8")
report = load_report(path)
assert report.heading == "Résumé"
```

A change to missing-file handling or error translation would introduce a separate product risk. That risk needs suitable evidence, not an exhaustive file-library suite.

**Judgment:** One focused regression can be sufficient; test count and coverage percentages are not completion targets. A low-impact change with clear semantics may need only inspection or an existing check. Money, security, persistence, or a changed boundary can justify more evidence when concrete failure consequences warrant it; that still does not imply every case at every test level. Preserve required edge-case defenses without inventing a new test for each unchanged safeguard. Frameworks and fixtures are acceptable when they help test the actual behavior. In read-only review, identify a specific material evidence gap before recommending more tests, and do not execute or write them automatically.

### p7 — document-real-limits

Record a deliberate simplification's actual ceiling and the condition that would justify changing it when those facts matter to future maintainers. Preserve necessary tuning, calibration, and operational controls.

**Representative Do / Don't comparison.** An interactive tool deliberately retains only the most recent 250 diagnostics. Its current requirements do not include a durable audit history.

**Don't:** Present a bounded in-memory buffer as permanent storage.

```python
# Preserve the complete diagnostic history.
recent_diagnostics = deque(maxlen=250)
```

**Do:** Describe the actual retention boundary and its revisit trigger.

```python
# Keeps the latest 250 diagnostics for the current session.
# Add durable storage if an audit-history requirement is introduced.
recent_diagnostics = deque(maxlen=250)
```

The documented bound must satisfy the current task. It cannot excuse discarding records that users already require.

**Judgment:** Use the repository's established comment or decision-record convention; a `ponytail:` prefix is optional when compatible. Add a note only for a real limitation, not every simple implementation. A comment does not make a violated requirement acceptable, and an unknown ceiling should not be presented as measured. New-code-only scope does not authorize editing unrelated old comments.

## Normal Additions

### p8 — collapse-structure

Actively consider collapsing wrappers, factories, interfaces, or layers when they add coordination cost without hiding a useful decision, protecting a contract, or serving a current requirement.

**Representative Do / Don't comparison.** A new local operation loads one fixed settings file through an existing validated reader. The proposed factory hides no variation, lifecycle, or dependency boundary.

**Don't:** Add a factory and class solely to forward the call.

```python
class SettingsLoader:
    def load(self):
        return read_settings(SETTINGS_PATH)

def make_settings_loader():
    return SettingsLoader()

settings = make_settings_loader().load()
```

**Do:** Keep the existing reader's contract and call it directly.

```python
settings = read_settings(SETTINGS_PATH)
```

This comparison concerns proposed new scaffolding. An established loader with injection, lifecycle, or compatibility responsibilities remains infrastructure under new-code-only scope.

**Judgment:** One implementation or caller alone is not enough evidence. Retain interfaces that isolate volatile dependencies, test seams that protect behavior, public contracts, and adapters with real translation responsibilities. A new-code-only task preserves those established structures even if a reviewer would design them differently today.

### p9 — compact-implementation

Consider consolidating functions, files, and control flow when it reduces the concepts and locations needed to maintain the task's behavior. Prefer explicit readable control flow over line-count targets.

**Representative Do / Don't comparison.** The input is a list of already validated destination names. Each name is stripped, empty results are omitted, and duplicates remain in their original order.

**Don't:** Separate a single transformation into several temporary collections without improving clarity.

```python
stripped = [name.strip() for name in names]
present = [name for name in stripped if name]
destinations = []
for name in present:
    destinations.append(name)
```

**Do:** Keep the transformation together in readable control flow.

```python
destinations = []
for name in names:
    name = name.strip()
    if name:
        destinations.append(name)
```

The loop remains explicit so a later per-item error or additional transformation can be added at its natural location. No shorter expression is required.

**Judgment:** Fewer files is not universally better. Preserve repository placement conventions, clear ownership boundaries, and useful names. Under new-code-only, compact only the newly introduced implementation; moving existing infrastructure into a new file is still an existing-code change.

## Extreme Additions

### p10 — remove-unused-flexibility

Consider removing configuration, extension points, optional branches, and supported variations only when evidence establishes that they have no required consumer or operational role within the assigned task.

**Representative Do / Don't comparison.** A new private report exporter has one caller and one required delimiter: a tab. The proposed delimiter argument has no public or configuration contract.

**Don't:** Introduce unused format variation for hypothetical consumers.

```python
def export_report(rows, delimiter="\t"):
    writer = csv.writer(output, delimiter=delimiter)
    writer.writerows(rows)
```

**Do:** State the supported format and retain the CSV writer's quoting behavior.

```python
def export_report(rows):
    writer = csv.writer(output, delimiter="\t")
    writer.writerows(rows)
```

The surrounding operation still owns the output stream and its error handling. Removing an existing public parameter would require a task-authorized interface change and evidence about its consumers.

**Judgment:** No in-repository setter is not proof that an environment option is unused. Preserve external consumers, rollback controls, accessibility features, and calibration knobs required by the actual contract. Under destructive scope, investigate only relevant variation points; do not scan the codebase for unrelated flags to delete.

### p11 — replace-existing-dependencies

Consider replacing a dependency with a suitable runtime facility or smaller maintained solution after accounting for semantic differences, affected consumers, and transition costs.

**Representative Do / Don't comparison.** A task-authorized migration replaces an existing slug package. All affected callers accept only lowercase ASCII words separated by spaces, and the required output joins those words with hyphens. Inspection has established that transliteration, punctuation removal, and collision handling are outside this boundary.

**Don't:** Keep the package solely because the existing implementation already imports it, after confirming that its other features have no relevant consumers.

```python
from slugify import slugify

slug = slugify(validated_label)
```

**Do:** Express this narrow, validated transformation directly.

```python
slug = "-".join(validated_label.split())
```

Retain the package if any affected consumer requires its broader text behavior. Remove the dependency declaration only after all authorized consumers are accounted for.

**Judgment:** Security, parser, internationalization, and platform edge behavior often justify a mature dependency. Do not hand-roll those contracts to reduce package count. Under new-code-only, a rule whose target is an existing dependency replacement is inapplicable; adding new code that avoids an unnecessary new dependency is instead covered by p3. Destructive scope still requires the replacement to serve the assigned task.

### p12 — challenge-speculative-work

Question mechanisms justified only by hypothetical future scale, consumers, or variation. Choose a smaller complete solution when it meets every assigned requirement; explain a meaningful deferred option and its trigger when useful.

**Representative Do / Don't comparison.** The requested new endpoint returns one in-process status value from an existing function. There is no current need for provider registration, remote polling, or persistent caching.

**Don't:** Build an extension system before delivering that endpoint.

```python
providers = StatusProviderRegistry()
providers.register("local", LocalStatusProvider())
status = providers.resolve("local").read()
```

**Do:** Return the required result through the existing operation.

```python
status = read_local_status()
```

Authentication, response schema, and failure handling remain part of the endpoint contract. A later requirement for remote providers would justify reconsidering the design; it does not authorize extra machinery now.

**Judgment:** Do not ship a reduced requirement and ask whether the user wanted the full version. Preserve requested features and explanations. Extreme intensity changes the opportunities considered, not the user's goal. Repository-wide deletion or restructuring requires that explicit assignment even in destructive scope.

## Validity Requirements

These determine whether a simplification is acceptable at any intensity; they are not optional selectable rules or automatic project activation. Preserve the required input and output contract, anticipated invalid-input handling, meaningful boundary conditions, security and accessibility requirements, and error behavior that prevents data loss. Keep necessary runtime compatibility, hardware calibration, and operational controls.

A shorter replacement must handle the cases relevant to the task, not merely its easiest example. An email validator cannot be replaced with an at-sign check without establishing that this meets the actual validation contract. An idempotent operation can still require retries for transient failures. A rare edge case remains relevant unless a validated invariant excludes it or it is demonstrably outside the supported contract.

Unknown equivalence is an evidence gap. Retain the behavior or identify the missing evidence instead of treating uncertainty as permission to remove it. Avoid speculative defensive scaffolding at every internal call, but do not discard an existing safeguard without understanding the guarantee it provides.

Preserve the assigned task boundary as well as behavior. In destructive scope, make the smallest coherent infrastructure change related to the task, including necessary caller updates. Do not use a nearby simplification opportunity to initiate unrelated cleanup or codebase-wide refactoring. In new-code-only scope, preserve existing infrastructure and apply selected rules to newly written callers and additions.

## Applicability

Apply selected rules to coding, design, fixes, and explicit simplification reviews within the resolved task and edit scope. Existing code may be read as context even when it cannot be revised. A selected rule without a permitted target is inapplicable; it does not grant a broader edit surface. Non-coding prose is outside this mentality, and requested explanations remain part of the task.

The ordered reuse preferences apply only when their rules are selected and alternatives satisfy the contract. Deployment lists all principles for discovery without enabling them. Review may use explicit criteria for one invocation while leaving project and agent selections unchanged.
