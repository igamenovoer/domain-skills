# GitHub Release

Prepare and publish a project release through GitHub CLI. Treat the changelog entry, release notes, tag target, validation evidence, and GitHub release page as one consistent release record.

## Workflow

When this command is invoked, execute the following steps in order.

1. **Resolve the repository and release policy**. Follow **Repository and Tool Preconditions** and load all applicable project instructions.
2. **Resolve the release identity**. Determine the exact version, defaulting to a bugfix or patch bump when the user did not specify one, then resolve the tag, target branch or commit, previous release, release type, and required assets using **Release Identity**.
3. **Collect release evidence**. Build the candidate change list from the exact previous-release-to-target range using **Change Evidence**.
4. **Update the project changelog**. Follow **Changelog Contract**; create `CHANGELOG.md` when the project has no changelog.
5. **Prepare release notes**. Follow **Release Notes Contract** and ensure the release page will list the changes.
6. **Apply project-specific release updates**. Update every required authoritative or mirrored version definition, lockfile, generated file, packaged component version, or release asset using the repository's supported procedures.
7. **Validate the release candidate**. Run the repository's required release checks and inspect the complete diff, tag target, changelog entry, notes, and assets.
8. **Commit and push release preparation**. Commit the approved release files, push the target branch, and verify that the remote target matches the validated commit.
9. **Publish with `gh`**. Create the release using **Publication Contract** only after the preparation commit and remote target are verified.
10. **Verify and report**. Read the published release back through `gh` and report the result using **Output Contract**.

If the task does not map cleanly to these steps, use your native planning tool to build a step-by-step plan from the repository policy, changelog, validation, GitHub CLI, and release-publication constraints in this command, then execute the plan.

## Repository and Tool Preconditions

- Resolve the exact Git repository root and read its applicable `AGENTS.md`, contribution guide, release guide, version policy, and build instructions before editing.
- Require a GitHub remote for the intended repository and resolve its canonical identity with `gh repo view --json nameWithOwner,defaultBranchRef,url`.
- Require `gh` to be installed and authenticated with sufficient repository access. Verify with `gh --version` and `gh auth status`.
- Fetch the target branch and tags before planning. Require a clean understanding of every worktree change; preserve unrelated user changes and exclude them from release commits.
- Check open release blockers, required checks, branch protection, and repository-specific approval rules. Do not interpret this command as authority to bypass them.
- Treat the project language and build system as unknown until repository evidence identifies them. Do not assume a Python project or privilege Python-specific files.

## Release Identity

Resolve and record:

- the exact release version and tag,
- the authoritative and mirrored version-definition files,
- the target branch and immutable target commit,
- the previous published release tag, when one exists,
- whether the release is final, prerelease, or draft,
- the release title,
- required build artifacts, signatures, checksums, or attestations.

Use an explicit user-provided version when present. Otherwise, default to incrementing the current bugfix or patch version according to the project's established version scheme.

Discover the current version and its update contract from repository evidence. Search project manifests, package and module metadata, build files, release configuration, source constants, deployment manifests, generated metadata, and dedicated version files. Examples include `package.json`, `Cargo.toml`, Maven or Gradle files, `.csproj` files, `CMakeLists.txt`, Helm `Chart.yaml`, `VERSION`, language-specific manifests, and version declarations in source code or configuration. Treat these as examples rather than a required or exhaustive list.

Identify which occurrence is authoritative and which occurrences are mirrors or generated outputs by reading repository instructions, build configuration, release automation, and consistency checks. Update every required occurrence through the repository's supported procedure. Do not edit a generated version file directly when the project provides a generator.

For a semantic-version-like scheme, increment the patch component while preserving the major and minor components. Follow repository policy for prerelease and build metadata. For another scheme, increment its documented bugfix component. If the repository exposes no unambiguous current version, uses conflicting version definitions, or has no deterministic bugfix increment, stop and ask the user for the exact version instead of guessing.

Follow the repository's tag convention instead of assuming a `v` prefix. Verify that the resolved tag corresponds to the updated project version.

Inspect existing releases and tags with `gh release list`, `gh release view`, `gh api`, and Git as needed. An existing release, conflicting tag, target mismatch, or version that is not greater under the repository's policy blocks publication until resolved.

## Change Evidence

Derive the change list from concrete repository evidence rather than memory:

1. Resolve the previous published release through `gh release list` and verify its tag and target.
2. Compare that tag with the proposed target commit.
3. Inspect commits and merged pull requests in the range.
4. Group user-visible changes under categories that fit the project, such as Added, Changed, Fixed, Deprecated, Removed, Security, Documentation, or Internal.
5. Include breaking changes, migrations, compatibility limits, and contributor or pull-request references when the evidence supports them.
6. Exclude changes outside the range, duplicate entries, secrets, internal-only details that the project does not publish, and claims unsupported by the diff or merged pull requests.

For an initial release, derive the list from the repository history and current project state and state that no previous published release exists.

GitHub-generated notes may provide a starting point. Preview them through `gh api --method POST repos/{owner}/{repo}/releases/generate-notes` with the proposed tag, target, and previous tag, then review and reconcile them against the exact range before use.

## Changelog Contract

Use the project's existing changelog and established format when one exists. Search for the canonical changelog before assuming it is absent.

When no project changelog exists, create `CHANGELOG.md` at the repository root with:

- a `# Changelog` heading,
- one release section containing the version or tag and release date,
- categorized bullet points from **Change Evidence**,
- comparison or pull-request links when the repository identity and tag range make them reliable.

For an existing changelog:

- preserve its headings, ordering, links, and unreleased-section conventions,
- move or copy only the entries included in this release according to the established format,
- add the release date and exact version,
- keep an empty `Unreleased` section only when the existing convention requires one.

The changelog and GitHub release notes must describe the same release range. They may differ in presentation, but they must not contradict each other or omit a known breaking change.

## Release Notes Contract

Write the final release notes to a temporary or skill-owned Markdown file before publication. The notes must contain:

1. the release title or a concise summary,
2. a visible `Changes` section with categorized bullets,
3. breaking-change or upgrade instructions when applicable,
4. validation, asset, checksum, or compatibility notes when relevant,
5. links to the comparison range, issues, or pull requests when verified.

Review the rendered Markdown content before passing it to `gh`. Do not rely on an empty body, an opaque generated summary, or a link to the changelog as a substitute for listing changes on the release page.

## Publication Contract

Before publication, verify that:

- the release-preparation commit is pushed,
- the remote target branch resolves to the validated commit,
- required checks and assets passed,
- the changelog entry and release notes name the same version and range,
- the tag and GitHub release do not conflict with existing state.

Publish through GitHub CLI with an explicit target and notes file:

```bash
gh release create TAG \
  --repo OWNER/REPO \
  --target TARGET_COMMIT \
  --title RELEASE_TITLE \
  --notes-file RELEASE_NOTES_FILE
```

Add `--prerelease` or `--draft` only when the resolved release type requires it. Attach required assets using exact paths and labels supported by `gh release create`; never use an unresolved broad glob.

If repository policy requires a signed or annotated tag, create and push that tag through the required Git procedure first, then add `--verify-tag` to `gh release create`. Otherwise let `gh release create` create the tag at the verified target commit.

After creation, verify the durable result with `gh release view TAG --repo OWNER/REPO --json url,tagName,name,isDraft,isPrerelease,targetCommitish,body,assets,publishedAt`. Confirm that the tag resolves to the intended commit and the body visibly lists the reviewed changes.

## Failure and Resume

- If preparation validation fails, fix only attributable release files and rerun the failed checks before publishing.
- If the preparation commit was pushed but release creation failed, preserve the commit and notes, inspect GitHub state, and resume from publication after correcting the cause.
- If the tag exists but the release does not, verify the tag target before creating a release with `--verify-tag`.
- If the release already exists, stop and report it. Edit, replace, or delete it only when the user explicitly requests that exact action.
- If publication partially uploads assets, inspect the release and reconcile exact missing assets; do not create a duplicate release.

## Output Contract

Report:

- repository and release URL,
- version, tag, release title, and final or prerelease state,
- target branch and commit,
- previous release and comparison range,
- changelog path and release section,
- categorized changes shown on the release page,
- validation commands and results,
- published assets and checksums when applicable,
- any skipped requirement, blocker, or follow-up.

## Guardrails

- DO NOT publish a release without authenticated `gh`.
- DO NOT publish before the changelog and visible release change list are complete and reviewed.
- DO NOT invent versions, changes, pull-request references, compatibility claims, or validation results.
- DO NOT assume the project is Python or select a version source from language-specific habit rather than repository evidence.
- DO NOT include unrelated worktree changes in the release-preparation commit.
- DO NOT move, overwrite, or retarget an existing tag or release without explicit authorization.
- DO NOT bypass repository release policy, required checks, signing rules, branch protection, or approval gates.
- DO NOT publish from a target commit that differs from the validated remote commit.
- DO NOT expose credentials, private issue content, embargoed changes, or sensitive build output in the changelog, notes, command output, or assets.
