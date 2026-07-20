---
name: review-architecture
description: "Load this skill when auditing and fixing architecture docs against specs, source, and current API boundaries. Skip it for low-level code review without durable architecture impact."
---

# review-architecture

## Mission
- Audit and fix architecture documentation drift against current specs and engine code.

## Domain Knowledge
- `docs/architecture/` owns durable system boundaries, dependency direction, lifecycle, and trade-offs; per-module callable facts belong in generated specs, not architecture prose.
- Architectural truth is triangulated from runtime composition in `src/app`/`src/runtime`, module dependencies/owned state in `src/`, public boundaries in `src/lua_api`, and manual spec intent. A single stale diagram is not a source of truth.
- Drift becomes actionable when it changes where contributors place state, which layer may call another, how a lifecycle transition occurs, or what fallback/rollback path exists.
- Cross-cutting concerns—GPU/resource ownership, callback registries, threading, serialization, asset/filesystem policy, and error propagation—deserve architecture treatment only when they span multiple module owners.
- Generated specs may evidence current implementation but should not be copied upward as low-level catalog prose; architecture should explain why the boundary exists and what must remain invariant.
- State-authority diagrams should distinguish primary mutable state, derived caches, renderer snapshots, serialized representations, and external/imported data. Treating all boxes as peers hides invalidation and compatibility obligations.
- Dependency review includes compile-time imports, runtime callbacks, shared registries, metadata/generator coupling, and filesystem conventions; absence of a Rust module import does not mean two subsystems are architecturally independent.
- Architecture docs should identify operational ceilings and failure isolation when they shape multiple modules, but leave exact per-method ranges to specs and binding docs.
- Rollback paths matter for migrations in serialization, public namespaces, renderer resources, and build/distribution flows because compatibility shims can otherwise become undocumented permanent architecture.

## Workflow
- Select one architectural claim or subsystem and map its documented components, dependency arrows, state owners, lifecycle events, and failure/fallback paths to concrete source modules plus manual specs; run strict links first to remove broken-reference noise.
- Walk representative runtime paths through code and public boundaries, looking for reversed dependencies, duplicate authoritative state, callback/resource lifetime leaks, undocumented cross-module coupling, or an implementation change that invalidates a recorded trade-off.
- Report drift as claim, documentary location, code/spec evidence, architectural consequence, and canonical owner to change; separate a stale description from a genuine boundary defect that requires implementation/design work.
- When editable, update manual spec intent or architecture prose at its true owner, include options/risks/rollback for changed constraints, and rerun links plus targeted source/spec checks; otherwise hand off that evidence to `architect` without prescribing low-level edits as architecture.
- Validate every diagram or component list against actual module paths and runtime registration, and every dependency arrow against at least one concrete call, shared state, message, or generated-data edge.
- Check neighboring architecture documents for conflicting ownership or terminology after an edit; consolidate the canonical statement and use links rather than maintaining parallel explanations of the same boundary.

## References
- `contracts: AGENTS.md, docs/AGENTS.md, docs/architecture/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "architecture docs specs engine boundaries" --profile engine --limit 10, tools/python.cmd tools/audit/cag_link_check.py --strict`
- `agent: architect`
- RAG: Use when locating architecture sources of truth; `architecture docs specs engine boundaries`; `system design module api boundary`; `docs architecture runtime pipeline`; `docs/architecture/`; `src/`; root and nested `AGENTS.md`; specs tied to touched subsystems
