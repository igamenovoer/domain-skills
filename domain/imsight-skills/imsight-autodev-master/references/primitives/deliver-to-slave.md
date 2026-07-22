# Deliver To Slave

Use this primitive after a workflow or invocation page has selected and rendered the command to send to a Houmao-managed slave.

## Workflow

1. Select the first available lane from **Delivery Ladder** without guessing stale runtime data.
2. For mail, apply **Mail Body Rule** and the linked notifier policy.
3. Deliver the rendered command without mutating the slave workdir.
4. Apply **After Delivery**: stop after accepted delivery unless the user asks for follow-up inspection.
5. Report the last attempted lane when delivery fails.

If the task does not map cleanly to these steps, plan only from the supported delivery lanes and guardrails; report a blocker when no supported lane is available.

## Delivery Ladder

1. Prefer live gateway prompt delivery when the slave has a healthy gateway and the request is immediate:
   ```text
   houmao-mgr agents gateway prompt --agent-name <slave> --prompt "<rendered command>"
   ```
2. Use mailbox delivery when requested, when gateway prompt delivery is unavailable and mailbox is available, or when the master/slave workflow intentionally uses mail.
3. Use raw input or other Houmao messaging surfaces only when the user explicitly asks or the environment requires that lane.
4. If no supported delivery lane is available, report the blocker instead of guessing a runtime path.

## Mail Body Rule

For mail delivery, put the rendered native invocation command at the top of the mail body, then include request details below it. The mail body is the single-mail instruction surface.

## After Delivery

- Once the request is accepted or delivered, finish the turn by default.
- Do not inspect the slave's follow-up, gateway state, mailbox state, TUI output, or results unless the user explicitly asks.
- If the delivery command fails, report the failure and the last attempted delivery lane.

## Guardrails

- DO NOT mutate the slave workdir from the master as part of delivery.
- DO NOT infer stale gateway URLs or mailbox roots from memory.
- DO NOT use mail-notifier appendix text for one-off request behavior.
