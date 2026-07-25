# Architecture Contract

## Mission & Scope
- Own durable system boundaries, dependency direction, state authority, lifecycle, and accepted trade-offs.
- Keep proposals separate from descriptions of the running system.

## Files
- `philosophy.md`, `engine-core.md`, `render-pipeline.md`, `scripting-bridge.md`: core constraints and runtime design.
- `module-scope-boundaries.md`, `runtime-tooling-boundaries.md`, `effects-particles-overlay-plan.md`: cross-module ownership.
- `docs-system.md`, `quality-assurance.md`, `cag-system.md`, `developer-ecosystem.md`: documentation, proof, and developer tooling.
- `proposals/`: active RFCs with explicit status, owner, acceptance gates, and retirement rule.

## Rules
- Every dependency claim names a concrete call, message, shared state, registry, generated-data, or filesystem edge.
- Every lifecycle claim includes creation, normal use, shutdown, and a failure or restore path.
- Keep per-function and per-file catalogs in generated specs/API docs.
- Source behavior and accepted specs outrank stale prose.
- Do not mix historical audit snapshots, onboarding, marketing, or release playbooks into architecture.

## Workflow
- Query RAG before broad reads and verify claims against source owners and Lua registration.
- Run strict docs/CAG link checks after structural changes.
