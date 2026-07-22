# Docker Service Setup

Use this reference when an Imsight project needs a project-local Docker service setup.

## Workflow

1. Resolve the project root and normalized service name under **Discovery**.
2. Inspect existing Docker patterns and local images before online lookup.
3. Create the service-local files under the exact **File Layout**.
4. Apply **Compose Guidance** without fake ports, volumes, or credentials.
5. Run **Verification** and enforce **Safety Rules**.

If the task does not map cleanly to these steps, use your native planning tool with the existing discovery, layout, Compose, verification, and safety rules; ask for missing secrets or ports before startup.

## Goal

For a requested Docker service, create all Docker-related files under:

```text
<project-dir>/dockers/<service-name>/
```

Prefer Docker Compose unless the user prohibits it or the service is genuinely better as a single `docker run` script.

## Discovery

1. Identify `<project-dir>` from the user request or current project root.
2. Normalize `<service-name>` to a lowercase, hyphenated directory name unless the project already has a naming convention.
3. Inspect existing project Docker patterns before adding files:

```bash
find <project-dir> -maxdepth 3 \( -name 'compose*.yml' -o -name 'compose*.yaml' -o -name 'Dockerfile' -o -path '*/dockers/*' \) -print
```

4. Inspect locally installed Docker images first:

```bash
docker image ls
docker image ls --format '{{.Repository}}:{{.Tag}} {{.ID}} {{.CreatedSince}} {{.Size}}'
```

5. If a usable local image exists, prefer it and document that choice in the generated Compose file comments or setup notes.
6. If no usable local image exists, look up current online image information. Prefer official image documentation, Docker Hub image pages, upstream project docs, or vendor-maintained registry docs. Use the selected image/tag based on that source.

## File Layout

Default to this layout:

```text
<project-dir>/dockers/<service-name>/
├── compose.yaml
├── .env.example
├── .gitignore         # when .data/ is used
└── .data/
    └── <service-name>/ # only when persistent local data is useful
```

Do not create project-root Docker files unless the user asks. Keep service-specific ports, volumes, env vars, and healthchecks inside the service folder.

When a service needs persistent local data mounted into the container, default that host path to `<docker-compose-dir>/.data/<service-name>`, where `<docker-compose-dir>` is the directory containing `compose.yaml`. In Compose, write it as `./.data/<service-name>:<container-path>`. Use a per-service subdirectory because one Compose file may contain multiple services. Add a `.gitignore` beside `compose.yaml` that ignores `/.data/`.

## Compose Guidance

Use `compose.yaml` by default:

```yaml
services:
  <service-name>:
    image: <selected-image>:<selected-tag>
    container_name: <project-name>-<service-name>
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - "${<SERVICE>_PORT:-<default-port>}:<container-port>"
    volumes:
      - ./.data/<service-name>:/data
```

Adjust the template to the service's actual paths, required environment variables, command, and healthcheck. Do not add fake ports, volumes, or credentials.

Use `.env.example` for configurable values and tell the user when `.env` must be created from it. Avoid committing secrets.

If `.data` is used, create this service-local `.gitignore`:

```gitignore
/.data/
```

## Verification

Run the least invasive checks available:

```bash
docker compose -f <project-dir>/dockers/<service-name>/compose.yaml config
```

If the user wants the service started now:

```bash
docker compose -f <project-dir>/dockers/<service-name>/compose.yaml up -d
docker compose -f <project-dir>/dockers/<service-name>/compose.yaml ps
```

If the image must be pulled, make clear that network access is required. If startup needs secrets, credentials, or a port choice, stop and ask for those missing values.

## Safety Rules

- Do not overwrite existing Docker files without reading them first.
- Do not expose ports on `0.0.0.0` intentionally beyond normal Docker port publishing unless the user requests LAN exposure.
- Do not embed credentials, API keys, private tokens, or private registry passwords in generated files.
- Prefer named service directories and relative paths so the setup stays project-local and portable.
- Keep generated files scoped to `<project-dir>/dockers/<service-name>/...` unless the user explicitly requests integration with root-level Compose files, CI, or deployment tooling.
