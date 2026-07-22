# Mail Notifier Policy

Use this primitive only when a master is considering Houmao gateway mail-notifier appendix text.

## Workflow

1. Decide whether the instruction is one-off mail behavior or persistent notifier policy.
2. Put one-off behavior in the mail body as required by **Core Rule**.
3. Use appendix text only for intentional repeated policy under **When To Use Appendix Text**.
4. Before changing appendix text, apply every check in **Before Changing Appendix Text**.

If the task does not map cleanly to these steps, keep request-specific instructions in the mail body and leave persistent appendix text unchanged.

## Core Rule

For one-off mail delivery behavior, include the rendered native invocation command at the top of the mail body. The mail body is the right place for request-specific instructions, skill names, OpenSpec commands, target change IDs, and any behavior that should apply only to this single mail.

Houmao gateway mail-notifier appendix text is persistent runtime policy. It is appended to future mail notification prompts and can affect every master or sender that talks to the same slave. Do not use it for one-off calls or single-mail behavior.

## When To Use Appendix Text

Use notifier appendix text only when the master intentionally wants a repeated policy across future mail notifications, such as always routing autodev mail through the slave mega-skill.

Example repeated-policy appendix:

```text
When notifying this agent about mail from an autodev master, read the mail body in full.
If the mail body begins with a native skill invocation such as
$imsight-autodev-slave ... or /imsight-autodev-slave ..., invoke that named skill exactly.
Do not treat the mail as a generic request before following the named skill command.
```

## Before Changing Appendix Text

1. Inspect current notifier status.
2. Consider whether the slave is shared by multiple masters or senders.
3. Preserve or merge compatible existing appendix text.
4. Remember that non-empty appendix updates replace the stored runtime appendix.

If the policy is not meant to apply beyond the current mail, put it in the mail body instead.
