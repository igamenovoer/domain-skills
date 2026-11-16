# Structure a Functional Project

## Workflow

1. **Resolve the functional target.** Read the selected realwork's guidance, language/build metadata, public entrypoints, and existing tests. Identify a meta parent explicitly when present.
2. **Classify the content.** Apply the parent responsibility contract to individual files and consumers. Preserve current behavior and separate mixed development/functional content only when restructuring is authorized.
3. **Reconcile useful functional homes.** Follow **Functional Layout**, preserving language and established suite conventions.
4. **Reconcile runnable contracts.** Keep build metadata, runtime/optional dependencies, package assets, functional acquisition controls, and test discovery with the feature. Route engineering tools and shared task/environment definitions to meta.
5. **Write usage guidance.** Explain entrypoints, prerequisites, suite selection, external bindings, and manual attachment of development resources. Preserve local `.env`; document variables in tracked `env.example`.
6. **Verify the changed boundaries.** Use the selected environment to check imports/build, relevant feature tests, required source pins, and documentation links. Report missing optional environments honestly.

If language or packaging conventions differ, plan equivalent functional homes rather than imposing the example tree.

## Functional Layout

```text
realwork/
|-- AGENTS.md, README.md, env.example
|-- package/build manifest, license, .gitignore
|-- src/ or established product source layout
|-- tests/                   unit, integration, explicit acceptance/manual
|-- scripts/                 functional operations and usable experiments
|-- docs/                    usage, APIs, formats, requirements
|-- configs/                 functional configuration
|-- models/, datasets/       acquisition controls when needed
`-- extern/tracked/          required pinned source dependencies when needed
```

Feature verification is functionality even when it tests an experimental script, uses a manual harness, or builds an isolated wheel as a test fixture. Test runners may be optional verification dependencies. Production code must not depend on test-only implementations. Keep fast defaults separate from explicitly selected slow/system/manual tests. Preserve an established `tests/core` layout if useful, but do not create an auxiliary development-policy suite inside the realwork.

Do not generate empty directory hierarchies, a universal dependency bundle, or a replacement package name. Use actual requirements. `context/`, agent skills, all OpenSpec records, CI/lint/type policy, and shared development environments belong to meta; create them through meta setup or migration when requested.

## Completion

Report the functional files changed, preserved interfaces, selected environment, tests run, and any missing data/services. Ordinary structure work does not publish, install large payloads, start services, or commit changes implicitly.
