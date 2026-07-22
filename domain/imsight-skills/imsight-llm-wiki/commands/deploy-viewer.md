# Deploy the Web Viewer

Use this subcommand to deploy, install, launch, repair, or update the bundled LLM Wiki web viewer.

## Workflow

1. **Resolve inputs**:
   - Installation directory: ask if not provided.
   - Wiki root: must contain `wiki/index.md` and `audit/`; ask if not clear.
   - Port: default to `8080`.
   - Host: default to `127.0.0.1`.
   - Author: optional.
2. **Run the deploy helper**:
   ```bash
   python3 scripts/deploy_viewer.py \
     --install-dir "<install-dir>" \
     --wiki "<wiki-root>" \
     --port <port>
   ```
3. **Report the result**:
   - local URL, usually `http://127.0.0.1:8080`
   - installation directory
   - wiki root
   - exact launch command
   - PID, process-group stop command, and log path when launched in background

If the task does not map cleanly to these steps, use your native planning tool with the existing deployment helper, options, and constraints; ask for required paths rather than guessing.

## Constraints

- Do not bind to `0.0.0.0` unless the user explicitly asks and understands the viewer has no authentication.
- Stop with a clear message if `node`/`npm` is missing and `bun` is not available.

## Quality Gates

### Checks

- The wiki root passes validation (`README.md`, `wiki/`, `audit/`, `log/`, `raw/`, `outputs/`).
- The chosen port is available before launch.
- The viewer source is copied and dependencies install successfully.

## Guardrails

- DO NOT deploy into a non-empty directory without `--force`.
- DO NOT launch on a busy port without trying an alternative.
- DO NOT treat the viewer as a multi-user or authenticated service.

## Useful Variants

Prepare without launching:
```bash
python3 scripts/deploy_viewer.py --install-dir "<install-dir>" --wiki "<wiki-root>" --launch-mode no-launch
```

Force a package manager:
```bash
python3 scripts/deploy_viewer.py --install-dir "<install-dir>" --wiki "<wiki-root>" --package-manager npm
```

Run in the foreground:
```bash
python3 scripts/deploy_viewer.py --install-dir "<install-dir>" --wiki "<wiki-root>" --launch-mode foreground
```
