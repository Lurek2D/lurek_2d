---
name: review-architecture
description: "Load this skill when auditing and fixing architecture docs against specs, source, and current API boundaries. Skip it for low-level code review without durable architecture impact."
---

# review-architecture

## Mission
- Audit and fix architecture documentation drift against current specs and engine code.

## Domain Knowledge
- Architecture sources live under `docs/architecture/`.
- Architecture docs own durable module boundaries, dependency direction, state ownership, lifecycle, and trade-offs.
- Per-function API catalogs belong in generated specs or API docs.
- `src/app` and `src/runtime` show runtime composition and lifecycle order.
- Modules under `src/` show state owners and compile-time dependencies.
- `src/lua_api/` shows public boundary ownership and registration.
- Manual specs show intended module contracts.
- Source behavior and accepted specs outrank a stale architecture diagram.
- A useful architecture rule changes where state lives or which layer may call another.
- GPU resources, callback registries, threading, serialization, assets, filesystem policy, and error flow are architecture topics when they cross module owners.
- Primary mutable state is different from a derived cache.
- Renderer snapshots and serialized data are copies, not automatic state authorities.
- Imported data is external input until validation creates owned state.
- Cache invalidation and serialization compatibility follow the primary state owner.
- Dependencies include Rust imports, runtime callbacks, shared registries, generated metadata, and filesystem conventions.
- A missing Rust import does not prove two systems are independent.
- Every dependency arrow needs a concrete call, message, shared state, registry, or generated-data edge.
- Every lifecycle claim needs a concrete creation, update, shutdown, restore, or failure path.
- Broken links are document defects but do not alone prove an architecture defect.
- A stale description and a broken system boundary are separate findings.
- Core architecture owners include `engine-core.md`, `render-pipeline.md`, and `scripting-bridge.md`.
- QA and release boundaries live in `quality-assurance.md` and `build-and-distribution.md`.
- Developer CAG and workflow boundaries live in `developer-ecosystem.md` and `developer-workflow.md`.
- Large refactors record options, trade-offs, risks, and rollback paths before implementation.
- Cyclic dependencies, leaked state authority, and missing public API fallbacks are explicit architecture defects.
- A changed durable constraint updates its canonical spec or architecture owner before downstream prose.

## Workflow
1. Read root, docs, architecture, and spec contracts.
2. Select one subsystem or one architecture claim.
3. Run the strict link audit.
4. List documented components, dependency arrows, state owners, and lifecycle events.
5. Map each component to real source modules.
6. Map public boundaries to registrations in `src/lua_api/`.
7. Map intended behavior to manual specs.
8. Walk one normal runtime path through creation, update, and shutdown.
9. Walk one failure, fallback, restore, or rollback path when it exists.
10. Identify primary state, caches, snapshots, serialized copies, and external input.
11. Check every dependency arrow against a concrete code or data edge.
12. Look for reversed dependencies, duplicate state authority, hidden coupling, and lifetime leaks.
13. Separate stale prose from a real boundary defect.
14. Record the claim, doc location, source evidence, spec evidence, consequence, and owner.
15. Update architecture prose only for durable system facts.
16. Update manual spec intent at its owning spec when that is the real defect.
17. Include trade-offs and rollback rules when a constraint changed.
18. Rerun strict links and targeted source or spec checks.
19. Validate every changed diagram label and path against current files.
20. Hand implementation defects to the code owner and architecture defects to `architect`.

## References
- `contracts: AGENTS.md, docs/AGENTS.md, docs/architecture/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "architecture docs specs engine boundaries" --profile engine --limit 10, tools/python.cmd tools/audit/cag_link_check.py --strict`
- `agent: architect`
- RAG: `architecture <subsystem> state ownership lifecycle boundary`; inspect the claim in `docs/architecture/`, runtime composition, module dependencies, bindings, and manual spec intent.
