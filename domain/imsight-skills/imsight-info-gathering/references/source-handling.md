# Source Handling

## Workflow

1. Select source classes and run broad discovery before focused searches.
2. Choose tools under **Tool Preference**.
3. For downloads, apply the workspace network rules and **Download SOP**.
4. Maintain the source ledger and local corpus metadata required by this page.
5. Verify durable files and preserve source provenance.

If the task does not map cleanly to these steps, plan only from the existing source classes, tools, download rules, ledger fields, and output contract; do not lower the evidence bar.

## Search SOP

Start with source classes, not keywords:

- Primary: official docs, standards, laws/regulations, filings, press releases, source repos, papers, datasets.
- Operational: changelogs, issue trackers, release notes, API references, pricing pages, status pages.
- Secondary: reputable analysis, trade press, tutorials, interviews, reviews, community reports.

Run broad discovery first, then focused searches by source class, date, domain, and exact terminology. For current or unstable facts, verify dates and prefer sources published closest to the event or maintained by the responsible organization.

## Tool Preference

- Use Tavily search/dynamic-search for clean discovery results.
- Use Tavily extract for known URLs and article/doc pages.
- Use Tavily crawl for documentation trees or multi-page sites.
- Use Tavily research for deeper reports when breadth matters more than fast iteration.
- Use browser/web tools as fallback or when direct quotes, screenshots, or exact page context are needed.
- Use command-line tools for durable downloads, archives, PDFs, datasets, and files the user explicitly wants saved.

## Download SOP

Follow local workspace network rules before downloading. In the Imsight mega-workspace, non-git network downloads should use the local proxy on port `7990` when required by project instructions:

```bash
export http_proxy=http://127.0.0.1:7990
export https_proxy=http://127.0.0.1:7990
export HTTP_PROXY=http://127.0.0.1:7990
export HTTPS_PROXY=http://127.0.0.1:7990
export no_proxy=localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.local
export NO_PROXY=localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.local
```

Prefer:

```bash
curl --fail --location --retry 3 --retry-delay 2 --output <file> <url>
```

For downloads:

1. Save into the output directory selected by the skill Output Contract. Use the user-provided destination first; otherwise use `IMSIGHT_SKILL_OUTPUT_DIR` when set; otherwise use a task-specific directory under `<project-dir>/.imsight-arts/info-gather/`, such as `<project-dir>/.imsight-arts/info-gather/<topic>/`.
2. Name files with date, source, and slug: `2026-05-21-openai-api-responses-docs.html`.
3. Keep original file extensions when possible.
4. Save PDFs, datasets, and archives untouched; extract copies only when needed.
5. Verify checksums, signatures, or release provenance when available.
6. Do not execute downloaded scripts, binaries, installers, notebooks, or archives unless the user explicitly asks and the risk is understood.

## Source Ledger

Maintain a lightweight ledger in notes or the report draft:

| Field | Purpose |
| --- | --- |
| URL | Canonical source link |
| Title | Human-readable title |
| Publisher | Organization or author |
| Published/updated | Date on source, if visible |
| Accessed | Current date |
| Type | Primary, operational, secondary |
| Use | What claim or context it supports |
| Reliability note | Bias, staleness, conflict, or caveat |

## Evidence Rules

- Prefer primary sources for claims about APIs, specs, law, pricing, release behavior, policies, and organization-owned facts.
- Use secondary sources to explain interpretation, adoption, market context, and competing viewpoints.
- For contentious or high-impact claims, require at least two independent sources or name the uncertainty.
- Track contradictions rather than smoothing them away.
- Quote sparingly; paraphrase and cite unless exact wording matters.
