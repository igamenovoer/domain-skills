# External Code and Payload Layout

Functional code depends only on declared, obtainable inputs. `extern/tracked/` can contain pinned dependency submodules or deliberately vendored sources with provenance. Their working files are independent in each realwork. Share download/object caches only when doing so does not share mutable source files or couple Git administration.

Meta `extern/orphan/` holds ignored inspection-only checkouts and snapshots. Meta `data/` holds shared model/dataset/asset payloads; functional acquisition controls normally remain in realwork `models/` or `datasets/`. Each active external root has a short index identifying entries, owners, tracking policy, version, setup and removal.

Do not create `extern/trees/`. Independent realworks are already registered under meta `realworks/`. During migration, inspect old links and worktrees before retiring them; do not treat an unknown symlink as disposable.

Keep ignore rules narrow. Product dependency gitlinks and small controls stay tracked; ignored payloads, caches, credentials, and local resource links stay local. README files make useful control directories trackable without additional `.gitkeep` files.
