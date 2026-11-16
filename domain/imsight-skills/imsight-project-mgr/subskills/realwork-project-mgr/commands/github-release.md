# Publish a Functional Project Release

## Workflow

1. **Resolve the product revision.** Name the realwork, branch/commit, canonical remote, release policy, and required tools. A metaproj HEAD is not a product release target. Inspect dirty state and preserve unrelated changes.
2. **Resolve version and prior release.** Discover authoritative version fields, mirrors, tag convention, previous published release and assets. Honor the requested version; otherwise use the project's documented patch increment. Ask only when no unambiguous policy exists.
3. **Collect the actual change range.** Compare the previous release with the exact target commit, inspect commits/PRs, and identify user-visible changes, breaking contracts and migrations. Do not invent changes or rely on commit subjects alone.
4. **Prepare consistent artifacts.** Update the functional changelog, all required version fields/generated mirrors, notes and assets through project procedures. Engineering build/release tools may run from meta against this target.
5. **Validate the candidate.** Run required release checks, inspect generated artifacts and sensitive-file exclusions, and ensure version, notes, tags and assets agree. Report baseline failures and respect project release gates.
6. **Publish within release authorization.** Commit only release changes, push the product branch and verify its remote commit. Create the tag/release using available GitHub tools, after checking for conflicting existing versions. Use exact notes via a file/structured argument and the exact target commit.
7. **Read back and report.** Verify the published tag, commit, release body and assets. Update a meta gitlink only if included in the requested coordinated publication; never tag meta as the product by mistake.

If the project uses a different hosting or release mechanism, plan the equivalent exact-revision workflow and state unsupported capabilities rather than fabricating publication.

## Evidence and Boundaries

An explicit release-publication request includes necessary release preparation commits and pushes, subject to repository policy. Preparation-only requests stop before publication. Use the available service connector where sufficient; otherwise use an authenticated CLI such as `gh`. Check the target repository, previous releases and permissions without exposing credentials.

For an initial release, explain that there is no prior tag and derive notes from current features and history. Follow the repository changelog format; if absent, create a concise version/date section with meaningful categories. Include supported compare/PR links, but do not publish private inputs or unsupported claims.

Existing tags or releases are inspected for identity and resume state, not overwritten. A conflicting tag, unknown version authority, missing mandatory check, or inaccessible remote is a concrete blocker. Completion requires read-back verification, not merely a successful CLI exit.
