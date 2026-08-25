# Connect Hermes to Local Hindsight

Configure Hermes' Hindsight plugin to use the running local API.

## Workflow

1. Require a healthy Hindsight API from the deployment command.
2. Run the supported Hermes memory setup path so the client dependency is installed.
3. Merge the maintained `local_external` configuration without replacing unrelated keys.
4. Activate the provider and restart or install the gateway service.
5. Verify provider availability and the resolved bank configuration.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the Hermes memory-plugin contract, local Hindsight endpoint, bank-isolation rules, and user request, then execute the plan.

## Preconditions

Refuse to continue until:

```bash
curl -fsS http://127.0.0.1:18888/health
hermes memory --help
```

The Hindsight health response must report a connected database.

## Install the Plugin Dependency

Use Hermes' supported setup workflow:

```bash
hermes memory setup hindsight
```

Select:

- mode: `local_external`
- API URL: `http://127.0.0.1:18888`
- API key: empty for the loopback-only local instance

The wizard installs or upgrades the compatible `hindsight-client` through Hermes' active Python environment.

## Merge the Maintained Plugin Config

Resolve `<hermes-mgr-subskill-dir>` to the parent subskill directory, then run:

```bash
<hermes-mgr-subskill-dir>/scripts/configure-local-hindsight.py
```

The script updates `~/.hermes/hindsight/config.json` atomically, preserves unrelated keys, and refreshes `config.json.bak` before changing an existing valid file.

The resulting maintained fields are:

```json
{
  "mode": "local_external",
  "api_url": "http://127.0.0.1:18888",
  "bank_id": "hermes",
  "bank_id_template": "hermes-{profile}-{platform}-{user}",
  "memory_mode": "hybrid",
  "auto_retain": true,
  "auto_recall": true,
  "retain_async": true,
  "retain_every_n_turns": 1,
  "recall_budget": "mid",
  "recall_types": "observation"
}
```

`observation` recall favors Hindsight's consolidated knowledge layer. Broaden it to `observation,world,experience` only when the user explicitly wants raw supporting facts injected as well.

## Activate and Restart

```bash
hermes config set memory.provider hindsight
hermes gateway restart
```

When no gateway service is installed yet:

```bash
hermes gateway install --start-now --start-on-login
```

## Verification

```bash
hermes memory status
hermes gateway status
python3 -m json.tool "$HOME/.hermes/hindsight/config.json"
```

Expected status: Hindsight is installed, active, and available. The gateway service should be enabled and active for login persistence.

## Guardrails

- DO NOT use `local_embedded` when the maintained deployment is a separately managed Docker service.
- DO NOT put the Kimi API key into Hermes' Hindsight plugin JSON.
- DO NOT disable the built-in Hermes memory files while enabling Hindsight.
