---
name: create-shader
description: "Load this skill when creating or modifying WGSL shaders or renderer shader-loader integration. Skip it for non-shader rendering logic, UI layouts, or visual asset edits only."
---
# create-shader

## Mission
- Create or modify WGSL shader code and integrate it with the existing renderer pipeline.

## When To Load
- Creating or modifying WGSL shaders or renderer shader-loader integration.

## When To Skip
- Non-shader rendering logic, UI layouts, or visual asset edits only.

## Domain Knowledge
- Read root `AGENTS.md`, then every listed contract nearest to the target path.
- Run the listed RAG query before broad file reads and start from top hits.
- Prefer MCP server `lurek_tools` and repo CLI/audit tools before ad hoc scripts.
- Check whether the target artifact already exists; modify existing content unless a new owner is clearly required.
- Read the nearest source, spec, test, doc, or config before editing.
- Treat create skills as create-or-modify workflows; existing artifacts are the default owner when present.

## Workflow
- Read `src/AGENTS.md`, inspect `assets/shaders/`, and inspect relevant `src/render/` loader/pipeline files.
- Modify an existing shader when it owns the effect; create a new `.wgsl` file only for a new effect.
- Keep shader names, bind groups, uniforms, and renderer loader wiring aligned.
- Run `cargo check` for WGSL/rust validation and `cargo test` for render pipeline coverage.
- Verify a demo or evidence path that exercises the shader.
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
- Contracts: `src/AGENTS.md`
- Primary tools: `tools/python.cmd tools/rag/query.py "WGSL shader src render pipeline" --profile engine --limit 10`, `cargo check`, `cargo test`
- Owner profile: `developer`

## Common RAG Queries
- Use when locating current renderer and WGSL ownership:
  - `WGSL shader src render pipeline`
  - `wgsl vertex fragment uniform texture`
  - `renderer shader loader pipeline layout`
- Common areas to inspect after top hits:
  - `src/renderer/`
  - shader asset folders
  - pipeline setup in `src/`
  - related specs in `docs/`

## References
- `contracts: src/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "WGSL shader src render pipeline" --profile engine --limit 10, cargo check, cargo test`
- `agent: developer`
