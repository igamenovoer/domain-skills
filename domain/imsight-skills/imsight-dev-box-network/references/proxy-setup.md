# Proxy Setup

Use this reference as the subskill page for Imsight proxy setup tasks.

## Workflow

1. Select a second-level subcommand from **Second-Level Subcommands**.
2. Load its linked reference and follow the existing procedure.
3. For `proxy-scan`, obtain the port range, run the bundled scanner, and persist candidates only when requested.
4. For `via-ssh`, distinguish dynamic SOCKS5 from forwarding an existing proxy service.
5. For `install-proxy-scripts`, copy and configure the bundled scripts as documented.

If the task does not map cleanly to these steps, plan only from the listed second-level operations and safety constraints; ask for missing topology or ports.

## Second-Level Subcommands

Use these subcommands under `proxy-setup`, for example: `$imsight-dev-box-network use proxy-setup proxy-scan to scan ports 7890-7897`.

| Subcommand | Use For | Load |
| --- | --- | --- |
| `via-ssh` | Use an SSH host as a middle host for proxy access, including SOCKS5 dynamic forwarding and local forwarding of remote proxy ports | `references/proxy-via-ssh.md` |
| `install-proxy-scripts` | Install proxy environment scripts and populate grouped proxy candidates from local, remote, or tunneled proxy ports | `references/install-proxy-scripts.md` |
| `proxy-scan` | Discover candidate proxy ports, then optionally update the managed shell startup proxy candidate block | `references/install-proxy-scripts.md` and `scripts/scan-proxy-candidates.py` |
