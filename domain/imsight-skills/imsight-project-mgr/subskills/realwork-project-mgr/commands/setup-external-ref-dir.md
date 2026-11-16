# Set Up Functional External Resources

## Workflow

1. **Resolve the resource owner.** Product-required model, dataset, or source acquisition controls stay in the realwork. Development-only references and shared physical payload storage belong to meta; route that setup to the meta manager.
2. **Inspect current control files and local data.** Record source, revision/checksum, required files, access/license constraints that affect tooling, and consumers. Preserve untracked data and established acquisition commands.
3. **Create minimal reproducible controls.** Follow **Resource Contract** and [external-layout.md](../references/external-layout.md). Add a fan-out bootstrap only when several resources need it.
4. **Materialize only within the request.** Use an explicit root variable, pinned clone/download, or narrow local link. A controls-only request does not authorize downloading models or accepting licenses.
5. **Verify and report.** Check bootstrap syntax, required-file validation, ignore rules, documentation links, and rerun behavior when execution is in scope. State separately whether controls and payloads are ready.

For unusual resources, plan the smallest explicit acquisition/binding contract that preserves the current consumer interfaces.

## Resource Contract

Each managed resource may contain a README, bootstrap entrypoint, small stable metadata, and ignored `source-data`/`derived` paths. Track source identity, version or checksum, required files, initialization command, binding variable, and cleanup semantics. Do not store secrets or machine-specific paths in committed defaults.

Prefer explicit path configuration over linking entire directories. If an existing interface needs a symlink, verify its exact target; replacing it removes only the link, never the external source. Existing real directories require a deliberate disposition before replacement. Bootstrap `--clean` may clean owned generated outputs or local links, not the source dataset/model. A `--yes` option is not authority to delete unrelated data.

Physical payloads may be shared from meta while the acquisition and usage contract stays functional and usable in a standalone clone. Ignore payloads narrowly so README, bootstrap, version pins, and metadata remain trackable. No resource may silently turn an inspection-only orphan checkout into a product dependency.
