# Mentality Composition

## Workflow

1. Obtain registered children from the parent entrypoint and the task being performed.
2. Resolve each relevant child's effective selection through [runtime-injection.md](runtime-injection.md), preserving the project or agent-memory source of each rule. Human Speak ordinary application uses already selected flavor-qualified identities; a management invocation missing its flavor uses the child's chooser instead.
3. Ask each child which selected principles apply to the task and request only their guidance through [Definition Retention](runtime-injection.md#definition-retention), including settings, examples, judgment notes, and edit boundaries as needed. For Ponytail, resolve both axes and its [task boundary](../subskills/ponytail/references/state.md#edit-boundary) before proposing changes.
4. Resolve conflicts under **Conflict Resolution**, using each selected family's scope and stored [priority](priorities.md). Registration order has no precedence.
5. Apply the resulting guidance throughout planning, execution, and verification, or return it to the requesting host. For recall, explain the same resolution without changing selections or configured values.

If the task does not map cleanly to these steps, use the native planning tool to compose available, applicable child guidance while preserving scope and agent identity.

## Child Rendering Contract

Each child's rendering identifies:

- the mentality, any explicitly selected flavor, and canonical principle IDs and names;
- the effective selection, each rule's source (`project` or `agent-memory`), and its family's priority in that scope;
- applicability to the current task;
- resolved child settings and their source, where present, including Ponytail intensity and edit scope;
- each rule or setting's project-bound definition path and identifier, or retained operative inline content when its details are not deployed;
- actionable reminders grounded in the full definitions, examples, and judgment notes;
- any unresolved definition or state evidence that prevents confident application.

The parent uses this common contract without interpreting a child's selector vocabulary or rewriting its principle definitions. Children own their catalogs and applicability. The parent may add headings and remove exact duplicate guidance while retaining the selected family, rule ID, and scope provenance.

Do not load every example in every deployed catalog for ordinary work. Catalogs preserve complete explanations for shared discovery; application retrieves only the selected principles and the examples needed to interpret them.

## Conflict Resolution

1. Honor system, developer, explicit user, unrelated repository, safety, permission, and tool instructions.
2. For the same principle, apply an explicit agent-memory enable or disable over the project setting; absence of an override inherits project selection.
3. When different applicable principles conflict, prefer the agent-memory principle over the project-scope principle. This applies within one mentality and across different mentalities.
4. Within the same scope, the family with the higher stored nonnegative priority overrides conflicting guidance from a lower-priority family. Later explicit enables receive increasing priorities through [Priority Assignment](priorities.md#priority-assignment); gaps remain valid after deletion.
5. Within one family, use applicability and the principles' judgment notes. Report material unresolved tensions or unavailable priority evidence; never infer precedence from registration order or invent missing values.

A project rule explicitly enabled in agent memory has agent-memory provenance for conflict resolution. A merely inherited project rule remains project-scoped. Conflict resolution determines application to this task and never removes principles from the stored selections.

Resolve a child's edit boundary independently of rule priority. Another selected mentality must not silently widen Ponytail's permitted edit surface. If a valid solution needs a change outside that surface, honor an existing explicit task instruction authorizing that change or explain the remaining scope conflict; do not apply a symptom-only workaround. Destructive scope still permits only infrastructure changes necessary for the assigned task, with minimal impact.

Human Speak guides presentation of human-facing output within the requested substance, evidence, and format. It adds no testing or investigation requirement and cannot reduce authorized task work. On durable human-facing documents it may compose with Docs Writer. Future flavors remain independently selected; neither flavor order nor a previously used flavor supplies a missing choice for a new management request.

## Reporting

For ordinary tasks, mention the mentality only when it caused a material tradeoff or the user requested it. For recall, show family priorities and the full scope resolution, including project rules suppressed by memory overrides, selected rules excluded by applicability, and conflicts resolved by scope or priority. Identify both families, their scopes and numbers, and the winning guidance. Without a substantive task, report configured effective selection and priorities, and mark task applicability as not evaluated.

## Guardrails

- DO NOT deploy catalogs or change project selections, memory overrides, or configured values while composing guidance.
- DO NOT include catalog entries solely because they are deployed or discoverable.
- DO NOT let project-scope mentality guidance override an explicit agent-memory override.
- DO NOT present registration order as cross-mentality priority.
- DO NOT copy another agent's remembered selection into the current agent's state.
