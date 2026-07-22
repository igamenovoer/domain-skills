# Domain Skills

Domain Skills is a public collection of domain-specific agentic skills: reusable instructions, workflows, and operational patterns that help AI agents work effectively inside specialized fields.

## Purpose

This repository collects skills that encode practical domain knowledge, such as:

- research and analysis workflows
- software engineering practices
- data and infrastructure operations
- product, design, and documentation routines
- agent skill handling and project automation
- other specialized agentic procedures

Each skill should be concrete enough for an agent to follow, scoped to a clear domain, and easy to reuse across projects.

## Repository Structure

Skills are organized by domain under `domain/`:

```text
domain/
  imsight-skills/      # Imsight project and agent skills
    imsight-paper-search/
    imsight-project-mgr/
    ...
  cuda/                # CUDA kernel optimization skills
    krnopt-cuda-coding/
    ...
```

## Domains

- `domain/imsight-skills/` — Skills for Imsight-style agent operations, including project management, documentation, information gathering, and direct API usage (for example, Semantic Scholar).
- `domain/cuda/` — Skills for CUDA kernel optimization and profiling.

## License

Licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.
