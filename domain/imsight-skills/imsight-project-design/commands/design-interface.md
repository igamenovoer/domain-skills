# Design Interface

## Workflow

When this subcommand is invoked, execute these steps in order.

1. **Resolve the feature design directory** and read `feature-requirement.md`, all relevant `usecases/uc-*.md` files, and existing docs under `design/`.
2. **Derive interface needs** from the use cases: commands, routes, request and response models, file formats, artifact identifiers, storage contracts, client APIs, service events, admin operations, and compatibility boundaries.
3. **Choose the design target**. Default to `design/public-interfaces.md`; update module-specific files only when they already exist, the interface surface clearly belongs in separate modules, or the user asks for module files.
4. **Write or update the interface design**. Include public surface, required and optional fields, validation rules, lifecycle or state behavior, errors, persistence behavior, compatibility notes, and open questions.
5. **Update `design/README.md`** with links and a short map of interface or module responsibilities.
6. **Report interface coverage**. Name the use cases covered, gaps still not represented, and any open user decisions.

If the task does not map cleanly to these steps, create a partial interface design with explicit assumptions and ask which use case or boundary should drive the next revision.

## Interface Style

Use the clearest format for the feature: type definitions for data models, YAML examples for request documents that need comments, route tables for HTTP APIs, command examples for CLI surfaces, lifecycle tables for async jobs or retained artifacts, event tables for messaging systems, and file-layout examples for filesystem contracts.
