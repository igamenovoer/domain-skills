# Subagent Planning

Create a structured assignment plan that maximizes useful parallel work on a user-defined task. This command writes a plan; it does not launch agents or execute the task.

## Workflow

1. **Resolve the task and project directory** from the request and current context. Identify whether an OpenSpec change defines the task; see **Task and Output Resolution**.
2. **Read the task sources and constraints**. Capture requirements, current progress, relevant instructions, available agent capacity, and model-selection requirements; see **Source References**.
3. **Identify independent work and necessary handoffs**. Group bounded deliverables by ownership and actual dependencies, using **Parallel Decomposition**.
4. **Assign responsibilities and integration ownership**. Account for shared outputs, verification, and remaining work; see **Ownership and Handoffs**.
5. **Write or update the plan** at the required location using [the bundled template](../assets/templates/subagent-plan.md). Adapt rows and optional sections under **Document Contract**.
6. **Verify the plan** against **Validation**. Resolve omissions, conflicting ownership, unjustified barriers, and broken source references before reporting completion.
7. **Report the saved path** with a brief description of the allocation and any unresolved planning constraints. State that execution has not started through this command.

If the task does not map cleanly to these steps, use the native planning tool to organize a plan within the task scope, output locations, source-reference requirements, and planning-only boundary in this command, then write and verify that plan.

## Task and Output Resolution

Use the project directory explicitly supplied by the user. Otherwise, use the established task workspace or current working directory. Resolve a named OpenSpec change from its actual directory or the local OpenSpec CLI's reported change root; preserve any explicitly selected store. A passing mention of OpenSpec does not make an unrelated task an OpenSpec-defined task.

| Task definition | Required output |
| --- | --- |
| An identified OpenSpec change defines the work | `<openspec-change-dir>/team/agent-assignment.md` |
| Any other task | `<project-dir>/.imsight-arts/subagent-plans/<YYYY-MM-DD>-subagent-plan-<task-slug>.md` |

- Use the current date in the user's established timezone when known, otherwise the host's local date; format it as `YYYY-MM-DD`.
- Derive a short, descriptive kebab-case task slug without path separators.
- These paths override the parent's general auxiliary-output directory and its environment variable. Create only the needed parent directories.
- For OpenSpec work, inspect the change's existing proposal, design, specs, task list, and related documents as available. Record missing inputs honestly; do not create or modify lifecycle artifacts through this command.
- If several changes could define the task, ask which one rather than choosing arbitrarily or silently using the non-OpenSpec location.
- When the target file already describes the same task, update it in place while preserving valid references, user decisions, and recorded execution evidence. Keep planned assignments distinct from observed progress.
- If a non-OpenSpec filename belongs to an unrelated task, choose a more specific task slug. Do not overwrite an unrelated plan.

## Source References

Every plan MUST provide a durable way to trace its scope and decisions back to the inputs that produced it. Keep a **Source References** table with stable IDs such as `S1`, `S2`, and `S3`.

| Source kind | What to record |
| --- | --- |
| Local document or task list | Descriptive link relative to the saved plan when possible, relevant section/task IDs, and revision or inspection date when available |
| Issue, specification, or remote document | Resolvable URL or durable identifier, relevant section, and known revision/date |
| Current implementation or other working artifact | Concrete path and the interface, behavior, or ownership constraint it establishes |
| User instruction available only in conversation | Date, a concise faithful summary, and a message/permalink identifier if available; explicitly label it conversation-only when no durable link exists |

Read relevant sources before treating them as evidence. Associate each workstream and material dependency or constraint with its source IDs. Distinguish confirmed requirements from planning assumptions; do not invent citations, revisions, messages, or prior completion evidence. When the request is the only input, the conversation-only row must contain enough of the task and constraints for a later reader to understand the plan without this chat.

Generated plans reference their own task's inputs. The command and template must remain self-contained resources and must not depend on the project from which this planning pattern was developed.

## Parallel Decomposition

Optimize for simultaneous useful work, not equal checklist counts or a fixed number of agents.

1. Identify independently deliverable outputs, shared contracts, prerequisites, and constrained shared resources.
2. Select a team size supported by the available concurrency and the task's independent work. Count the orchestrator against capacity where the host does. If capacity is unknown, label the proposed size as an assumption rather than claiming slots exist.
3. Let each workstream start useful independent work immediately. Synchronize only when a concrete input, decision, or artifact is needed.
4. Define small early handoffs that unblock consumers before the producer's entire workstream finishes. An agreed interface or outline can support parallel drafting or implementation, but does not prove the final deliverable correct.
5. Give the orchestrator concrete work and integration responsibility. Avoid assigning it so much shared editing or review that every other worker must wait.
6. Reassign a finished worker to a specific remaining package after an ownership handoff. If the task has little independent work, document a smaller team or serial segment instead of inventing parallel work.

Use the same model as the orchestrator by default. Carry forward explicit user model constraints, including a mandatory same-model rule when specified; do not introduce different-model assignments without user direction.

Document dependency edges rather than imposing milestone-wide barriers. A blocked prerequisite stops its consumers, while unrelated workstreams continue. Sequential work is appropriate when shared ownership, correctness, or an actual resource constraint requires it; state the concrete reason.

## Ownership and Handoffs

| Concern | Planning rule |
| --- | --- |
| Work coverage | Assign every required outcome to one accountable owner, including integration, documentation, and final verification |
| Shared outputs | Name one writer or decision owner for each shared file, document, interface, dataset, or other mutable artifact |
| Contributions | Other workers provide proposed edits or findings to the owner instead of making conflicting concurrent changes |
| Transfer | Require an explicit handoff before transferring ownership |
| Shared contracts | Publish the required shape and acceptance criteria early; notify consumers when they change |
| Verification | Each workstream supplies appropriate evidence; the integrator verifies combined outcomes without repeating unchanged checks unnecessarily |
| Tracking | Preserve existing task IDs and progress conventions; reference required task-specific plans when the task already mandates them |
| Completion | Keep planning status separate from execution status; a plan or partial handoff is not proof of task completion |

Each handoff names the task IDs or outputs, changed artifacts, delivered behavior or findings, downstream assumptions, verification evidence, and unresolved issues. Include active process or external-action ownership only when applicable.

## Document Contract

Use the bundled template as an artifact skeleton, not as a rigid number of agents or rows. It is a document template, not an executable subcommand page.

- Keep prose brief and task-specific. Use tables for assignments, source references, dependencies, and ownership; use lists for ordered actions and handoff contents.
- Include scope, team/model rules, source references, workstreams, dependency handoffs, ownership, and verification/completion criteria.
- Replace every placeholder. Add or remove worker rows according to useful concurrency and remove instructional comments from the generated document.
- Include only constraints supported by the task or inspected environment. For non-code tasks, use concrete documents, decisions, or other outputs instead of forcing file/module language.
- The optional execution-constraints section can cover relevant shared resources, access, deadlines, confidentiality, or external actions. Omit it when it adds no material constraint; do not transplant another task's restrictions.
- Do not create per-task implementation plans, change the source checklist's completion state, or execute assignments as a side effect of generating this document.

## Validation

Before reporting the plan saved, confirm:

- The output path matches the task's OpenSpec or non-OpenSpec classification.
- Source references resolve or are explicitly labeled conversation-only/unavailable; the scope and key decisions can be traced back to them.
- Every requested outcome has an owner and verification criterion; no requirement was dropped to make delegation easier.
- Workstreams have bounded outputs, meaningful concurrent starting work, and explicit prerequisite handoffs without dependency cycles.
- Shared artifacts have one writer, ownership transfers are explicit, and the proposed capacity/model policy is accurate or clearly marked as assumed.
- Verification covers both individual outputs and the combined result; unresolved prerequisites and evidence gaps remain visible.
- The plan contains no leftover placeholders, invented progress, unrelated restrictions, or accidental changes to existing task evidence.

## Guardrails

- DO NOT spawn agents or execute the underlying task through this planning command.
- DO NOT turn a real dependency into an unsupported promise of parallel execution.
- DO NOT assign concurrent writers to the same mutable artifact without an explicit owner and handoff.
- DO NOT omit source references or fabricate traceability for conversation-only inputs.
- DO NOT modify OpenSpec lifecycle artifacts or task completion states while generating the assignment plan.
- DO NOT embed unrelated project identities, absolute workspace paths, or task-specific assumptions in this reusable command or its template.
