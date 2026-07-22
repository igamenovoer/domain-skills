# Find LibGen

Use this subskill when the user asks to search a LibGen-style mirror, resolve search results into direct download URLs, or produce `wget` commands for a found target.

## Bundled Script

Use the bundled stdlib-only script:

```bash
python scripts/libgen_stdlib_links.py '<QUERY>'
```

The script uses only Python's standard library. It searches a LibGen-style mirror, extracts result mirror pages, resolves `libgen.*` `ads.php?...` pages into direct `get.php?...` URLs, and prints wget-ready commands when requested.

Default values for optional mirror and proxy inputs live in `find-libgen.defaults.toml`. Read that file when the user omits either value or asks what default will be used.

Important options:

- `--mirror <LIBGEN_MIRROR_URL>`: Optional LibGen mirror override.
- `--proxy <HTTP_PROXY_URL>`: Optional HTTP/HTTPS proxy override.
- `--config <TOML_PATH>`: Optional defaults file override.
- `--no-proxy`: Ignore proxy environment variables.
- `--title`, `--author`, `--year`, `--extension`: Filter matched records using additional user-provided info.
- `--limit <n>`: Maximum matched books to inspect.
- `--max-mirrors <n>`: Mirror pages to inspect per book.
- `--json`: Emit machine-readable results.
- `--wget-bytes <n>`: Print `wget` commands with a `Range` header for partial download testing.

## Workflow

1. Treat the LibGen mirror URL and proxy server address as optional inputs. Use user-provided values when present; otherwise read `find-libgen.defaults.toml`.
2. Build the search query from the user's keywords, title, author, ISBN, or other identifying info.
3. Add filters when the user supplied them: `--title`, `--author`, `--year`, and `--extension`.
4. Use the configured proxy unless the user provides `--no-proxy` or explicitly asks not to use a proxy.
5. Run the script from the `imsight-info-gathering` skill directory or pass the script path explicitly:
   ```bash
   python scripts/libgen_stdlib_links.py '<QUERY>' \
     --mirror '<LIBGEN_MIRROR_URL>' \
     --proxy '<HTTP_PROXY_URL>' \
     --extension pdf \
     --limit 3 \
     --max-mirrors 1 \
     --wget-bytes 1024
   ```
6. When using defaults, omit `--mirror` and/or `--proxy` instead of restating configured values in the command.
7. If the user wants reusable output, save JSON under the output directory selected by the parent skill's Output Contract, normally `<project-dir>/.imsight-arts/info-gather/libgen/`.
8. For download feasibility or connectivity checks, use partial-byte tests:
   ```bash
   wget --header='Range: bytes=0-1023' -O sample.part '<direct-get-url>'
   ```
9. Report the query, mirror source (user input or defaults file), filters, direct URL count, selected URL(s), and the exact `wget` command(s). If a byte-range test was run, include HTTP status, downloaded byte count, and output path.

If the task does not map cleanly to these steps, plan only from the bundled script, defaults, filters, output contract, and guardrails; do not full-download or claim an unresolved URL is downloadable.

## Guardrails

- DO NOT full-download large files unless the user explicitly asks for a full download.
- DO NOT claim a URL is downloadable until the direct URL is resolved, or a partial `wget` test succeeds when requested.
