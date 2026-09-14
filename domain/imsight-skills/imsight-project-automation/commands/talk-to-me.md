# Talk to Me

Keep the conversation available while authorized, time-consuming work runs in the background. Use the host's internal background monitoring facility, then end the foreground turn so the user can continue chatting.

## Workflow

1. **Resolve the work** from the request or current task. Reuse an existing owned job when possible; see **Task Scope**.
2. **Check host support** for execution that survives the end of the turn and for native background monitoring. Use **Background Support**; distinguish process lifetime from notification delivery.
3. **Start or retain the background job** through the supported execution facility. Capture its job handle and output location, checking only the immediate launch result. If it already finished or failed, report that result and end the turn.
4. **Register or reuse native monitoring** for the exact job. Use **Monitoring and Follow-Up**; registration must return without waiting for the job to finish.
5. **Return chat control immediately** with the actual job state and monitoring status under **Return Contract**. Send a final response and end the turn; a commentary update alone does not release the conversation.

If the task does not map cleanly to these steps, use the native planning tool only for a short plan within the existing task and available background facilities. Report missing capabilities and return control instead of building a blocking workaround.

## Task Scope

`$imsight-project-automation use talk-to-me` applies to the current authorized long-running work. The request may instead identify a specific command or existing job. Without either, acknowledge the preference for the next authorized long-running process in this conversation; do not invent work to launch.

Keep this interaction preference in the current conversation unless the user changes it. The command does not install hooks, alter project instructions, or promise persistence across lost context. Brief checks may run normally; the preference concerns operations whose completion would otherwise hold the conversation open.

Preserve the original command, workdir, inputs, validation requirements, resource ownership, and approval boundaries. Background execution changes how the work is supervised, not what actions are authorized. A process must be safe to run unattended and must not require an unresolved interactive prompt.

If a job is already running, attach monitoring to its existing identity. Move foreground work into the background only when the host supports doing so safely; never kill and restart it merely to obtain a background handle.

## Background Support

Use the tools and capabilities actually exposed by the current host. Prefer its background-task execution and internal monitoring or completion-notification facilities. Read the available tool contracts rather than guessing tool names or inventing a scheduler API.

| Available Capability | Behavior |
| --- | --- |
| Persistent background execution and native monitoring | Start or reuse the job, register monitoring, and end the turn. |
| Persistent background execution without native monitoring | Keep a safe job running and return its handle and output location. Explicitly state that automatic updates are unavailable; check only on a later user request. |
| No execution facility that survives the turn | Leave new work unstarted and explain the limitation. Report any existing job's actual state without pretending it was detached. |

A returned session ID, shell background operator, or short yield alone does not establish cross-turn persistence or automatic monitoring. An unawaited tool promise may be discarded when its orchestration scope ends. Obtain the supported background handle before returning; do not abandon a foreground tool call and describe it as a background job.

If monitor registration fails after launch, keep the job identity and report the monitoring failure. Leave only work that is safe without automatic oversight running; disclose any safety-driven stop of the owned job. Do not launch a replacement or switch to a foreground wait loop.

## Monitoring and Follow-Up

Register the smallest native watcher needed to observe the job's output, meaningful stage changes, failure, or completion. Retain the job and watcher handles in the host's task record or available conversation context. Repeated invocation reuses the existing watcher rather than creating duplicates.

Prefer native completion events. When the host supplies recurring background checks, use its supported scheduling mechanism and bounded checks; the foreground conversation must not become the polling worker. The watcher observes the existing job and does not rerun the command or start fixes automatically.

Notify on meaningful progress, a blocker, failure, or completion, using the host's actual delivery mechanism. Report logged stages or counts when available; do not invent progress percentages or treat process exit alone as proof that the requested result is correct. Stop the owned watcher after terminal status and report the exit result, evidence location, and any verification still needed.

Answer new user messages while the job runs. An ordinary new message does not cancel the job; a stop request targets only the identified owned job and its watcher. Avoid concurrent edits to the same active inputs or outputs unless they are safely isolated. A status request permits one bounded current-state check, followed by another final response rather than a wait for completion.

## Return Contract

The immediate final response states what was launched or retained, its job handle, where output is available, and whether native monitoring was actually registered. Say that the user can continue chatting. Promise a later notification only when the host supports delivery and registration succeeded.

If no job started, or only partial background support exists, state that plainly. The initial return marks a handoff to background execution, not completion of the user's underlying task.

### Example

The following user/AI exchange is illustrative. Learn its intent and response shape rather than hardcoding its identifiers or assuming the shown capabilities exist.

User: "$imsight-project-automation use talk-to-me for the test run already in progress."

AI final response, after successful native registration: "The test run is continuing as job `job-42`; its output is in the existing run log. Native monitoring is active for failure or completion updates. You can keep chatting while it runs."

If monitoring is unavailable: "The test run is continuing as job `job-42`, with output in the existing run log. This host has no automatic background notifications; I can check it when you ask. You can keep chatting."

## Guardrails

- DO NOT wait, sleep, join, follow logs, or repeatedly poll in the foreground to await background completion.
- DO NOT claim chat control has returned while keeping the foreground turn occupied with monitoring calls.
- DO NOT claim persistent execution, registered monitoring, or future notifications without host support and successful setup.
- DO NOT create custom polling daemons, monitoring agents, or external schedulers to replace a missing internal facility.
- DO NOT duplicate, restart, or cancel work merely because the user asks to keep chatting.
- DO NOT expand the job's authority, retry policy, or validation scope when moving it to the background.
