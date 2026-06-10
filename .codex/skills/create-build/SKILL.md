---
name: create-build
description: "Load this skill when creating or modifying Cargo profiles, release/debug/dist settings, packaging scripts, or build automation. Skip it for runtime feature work, docs-only changes, or pure test authoring."
---
# create-build

## Mission
- Create or modify build, release, debug, dist, and packaging behavior while preserving local Windows-first tooling.

## When To Load
- Creating or modifying Cargo profiles, release/debug/dist settings, packaging scripts, or build automation.

## When To Skip
- Runtime feature work, docs-only changes, or pure test authoring.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Inspect existing `Cargo.toml` profiles and `tools/dist/` scripts before adding new knobs.
- Choose modify when a matching profile, script, or package path already exists; create only when there is no owner.
- Measure the baseline size or compile time before changing flags.
- Update the smallest build profile or packaging script that owns the requested behavior.
- Run the narrow build command first, then broader cargo/clippy checks when shared build behavior changed.
- Finish by reporting changed files and validation evidence.

## Success Criteria
- The target artifact was created or modified in the narrowest owning location.
- Existing content was preserved and updated when it already owned the behavior.
- Listed validation tools complete successfully, or any remaining failure is reported with exact output and next owner.

## Stop Conditions
- Required user intent, target module, or validation threshold is missing and cannot be inferred from repo context.
- A referenced owner path or tool is absent after checking the repository.
- Fixing a finding would require changing unrelated user work or widening scope beyond the requested surface.

## Companion File Index
- Contracts: `AGENTS.md`, `tools/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "build profiles Cargo.toml dist tools" --profile engine --limit 10`, `cargo build --profile <profile>`, `cargo clippy -- -D warnings`, `tools/python.cmd tools/validate/cag_validate.py`
- Owner profile: `builder`

## Common RAG Queries
- Use when finding current build owners before editing:
  - `build profiles Cargo.toml dist tools`
  - `release profile packaging cargo config`
  - `python.cmd build audit validate cargo`
- Common areas to inspect after top hits:
  - `Cargo.toml`
  - `tools/dist/`
  - `tools/build/`
  - `tools/validate/`

## References
- `contracts: AGENTS.md, tools/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "build profiles Cargo.toml dist tools" --profile engine --limit 10, cargo build --profile <profile>, cargo clippy -- -D warnings, tools/python.cmd tools/validate/cag_validate.py`
- `agent: builder`
