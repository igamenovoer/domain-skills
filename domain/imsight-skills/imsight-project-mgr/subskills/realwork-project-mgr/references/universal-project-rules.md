# Shared Project Rules

## Placement

Classify files by purpose. Product implementation, functional operations, experiments, tests, examples, and public usage contracts belong in the selected realwork. Development tooling, its tests, design/planning material, agent skills, environment policy and OpenSpec belong in meta. Metaproj uses `meta_src/` and `meta_scripts/`, never a publishable root `src/`. Prefer existing purpose-specific homes; do not add uncategorized root code.

Product code must not load implementation from meta tools, tests, ignored scratch, or inspection-only references. Feature tests are verification and executable documentation; their owner is the feature rather than the wheel boundary. Disposable output uses the explicit development temporary root and must not become a durable input without a retention contract.

## Writing and Engineering

Keep Markdown paragraphs on logical lines. Use precise Python types and public API docstrings; run the project's adopted checker. Use Doxygen-style public C++ documentation where applicable. Preserve the project's actual compatibility policy; breaking changes are permitted only where that policy says so. Repair affected callers and verification with a contract change.

## Development

Name the selected checkout, branch, environment, resources, and task. Keep default outputs isolated by complete checkout key and run. Share compatible environments without switching editable source; incompatible dependency work uses a separate meta environment. Coordinate changes to shared meta files. Preserve unrelated work, local settings, credentials, data, and service ownership.

## Blockers

Keep pursuing the authorized task using the least surprising correct resolution. Record consequential decisions and incomplete checks in the task's existing meta plan or decision log. Make a local checkpoint commit only when commits are authorized; never sweep unrelated changes into it. Seek missing input when no authorized resolution remains. Do not weaken acceptance criteria, invent evidence, or treat difficulty as task completion.
