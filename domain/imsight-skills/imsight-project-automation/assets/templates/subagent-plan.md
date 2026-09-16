# Subagent Plan: <Task Title>

## 1. Scope and Execution Contract

| Item | Plan |
| --- | --- |
| Status | Planned allocation; execution is not started by creating this document |
| Date | <YYYY-MM-DD> |
| Objective | <Requested outcome and scope, with source IDs> |
| Completion | <Evidence needed to establish the full outcome> |
| Team | <Orchestrator and useful worker count; known capacity or explicit assumption> |
| Model policy | <Inherit the orchestrator's model; record any explicit user requirement> |
| Parallelism | <Independent work that starts together and any justified serial portions> |

## 2. Source References

| ID | Source | Relevant scope or decision | Revision or date |
| --- | --- | --- | --- |
| S1 | <Descriptive document link or durable task reference> | <Requirement, section, or task IDs establishing the objective> | <Known revision/date or unavailable> |
| S2 | <Document link or explicitly labeled conversation-only instruction with a faithful summary> | <Constraint or decision used in this plan> | <Known revision/date or unavailable> |

## 3. Workstreams

| Owner | Scope and source IDs | Concrete outputs | Independent starting work | Early handoff | Verification |
| --- | --- | --- | --- | --- | --- |
| Orchestrator | <Shared decisions, integration, and bounded direct work> | <Combined result and owned outputs> | <Useful work while agents proceed> | <Small shared contract or decision> | <Combined acceptance evidence> |
| Agent A | <Task IDs or bounded outcome; source IDs> | <Deliverables> | <Work not blocked on another worker> | <First useful output and consumer> | <Required evidence> |
| Agent B | <Task IDs or bounded outcome; source IDs> | <Deliverables> | <Work not blocked on another worker> | <First useful output and consumer> | <Required evidence> |

<!-- Adjust worker rows to the task and available capacity. Remove this comment. -->

## 4. Dependencies and Scheduling

| Producer | Required handoff | Consumer and work unlocked | Acceptance condition | Source |
| --- | --- | --- | --- | --- |
| <Owner> | <Specific artifact, input, or decision> | <Owner and dependent work> | <How the consumer knows it can proceed> | <Source IDs or labeled planning assumption> |

- Start independent work together; wait only for the handoffs listed above.
- Integrate small increments and notify consumers when shared contracts change.
- Reassign available workers to <specific remaining packages> after an explicit ownership transfer.
- Keep <unresolved prerequisites or assumptions> visible without blocking unrelated work.

## 5. Artifact Ownership and Handoffs

| Artifact or decision boundary | Accountable owner | Other contributors | Update or transfer rule |
| --- | --- | --- | --- |
| <Shared file, document, interface, dataset, or other output> | <Single owner> | <Workers supplying changes or findings> | <How contributions arrive and ownership transfers> |

Each handoff includes:

- Task IDs or requested outputs and the artifacts changed.
- Delivered behavior or findings, and the contract needed by downstream work.
- Verification method, result, and evidence location.
- Remaining issues, assumptions, and ownership transfers.
- Active process or external-action ownership, only when applicable.

## 6. Progress and Completion

| Stage | Responsible owner | Evidence or action |
| --- | --- | --- |
| Workstream progress | <Worker> | <Existing checklist or status convention; task-plan references if required> |
| Handoff acceptance | <Consumer or integrator> | <Verify the promised artifact and acceptance condition> |
| Combined verification | <Integrator> | <Checks covering interactions and the complete requested outcome> |
| Completion update | <Checklist or task owner> | <Mark complete only after required evidence; retain unresolved items explicitly> |

## 7. Task-Specific Constraints

<!-- Optional: remove this entire section if no material additional constraints apply. -->

| Constraint and source | Affected work | Scheduling or handling rule | Stop or revisit condition |
| --- | --- | --- | --- |
| <Established constraint and source ID> | <Workstream or operation> | <Concrete handling based on this task's evidence> | <Observable condition requiring a change> |
