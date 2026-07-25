# Lurek2D Philosophy And Design Constraints

## Purpose

This document owns the durable principles used when engine boundaries compete. [Engine Core](engine-core.md) describes the runtime structure; module-specific behavior belongs in `docs/specs/`.

## Product Identity

- Lurek2D is one Rust desktop binary that runs Lua game scripts.
- The public authoring surface is Lua-first and lives under `lurek.*`.
- The engine targets games, simulations, visual tools, and interactive desktop applications.
- AI assistance and agent-friendly tooling support development; they are not the runtime's defining promise.
- Finished games and reusable Lua packages live in `lurek_2d_content/`, outside the Rust engine repository surface.

## The Zen of Lurek

These rules are the architectural test for a feature, API, or refactor. A
proposal that conflicts with one of them must make the trade-off explicit and
change this document or an RFC; it must not create an undocumented exception.

| # | Rule | Consequence |
|---|---|---|
| 1 | No cycles, ever. | The Rust module dependency graph is acyclic. |
| 2 | The composition root is one-way. | `app` and `lua_api` may compose lower layers; lower layers do not import them. |
| 3 | Depend on contracts, not backends. | Feature code uses public renderer and runtime seams, not backend GPU details. |
| 4 | Keep the runtime boring. | Runtime services own lifecycle, errors, configuration, IDs, and commands—not product features. |
| 5 | Registries are not god objects. | A registry exposes owned resources; domain rules stay in their domain module. |
| 6 | Stable acyclic peers may cooperate. | A same-responsibility import is acceptable when its direction and ownership are clear. |
| 7 | Split by reason to change. | Make a new module for a distinct responsibility, not an arbitrary file-size threshold. |
| 8 | Draw is a projection. | Rendering consumes state and produces commands; it does not become the state authority. |
| 9 | Pure logic stays pure. | Math, data transforms, generation, and graph work do not acquire window, GPU, audio, input, or Lua dependencies. |
| 10 | Separate durable state from runtime resources. | Serializable state does not require a GPU handle, OS window, or Lua VM reference. |
| 11 | Tooling lives at the edge. | Diagnostics, docs, automation, and development bridges observe or orchestrate; they do not own gameplay state. |
| 12 | Bindings are thin and one-directional. | Lua bindings translate public calls to domain owners; domain modules do not know the binding layer. |
| 13 | Tests follow responsibility. | Private algorithms are tested with their owner; public contracts and integrations are tested in their relevant test layer. |
| 14 | Merge weak modules early. | A module without a distinct, durable responsibility belongs with the owner it serves. |
| 15 | Optimise for human and AI readability. | Names, public APIs, docs, examples, and boundaries should make ownership and intent obvious. |

The practical rule behind the list is simple: prefer fewer concepts, explicit
names, sensible defaults, and one canonical owner for every rule and state
model.

## Active Constraints

### Runtime

- The application owns the window, device resources, event loop, audio services, and Lua VM lifetime.
- Lua owns game/application state unless a public API explicitly creates Rust-owned state.
- The main loop is single-process and ordered. Work may run on worker threads only behind an owner that defines synchronization and failure behavior.
- Desktop support is the active platform contract; mobile and browser targets require an explicit architecture decision.

### Public Boundary

- `src/lua_api/` owns registration, Lua-facing names, argument conversion, and public error translation.
- `mlua` is not exclusive to `src/lua_api/`: runtime and domain seams may store callbacks, tables, or values when Lua identity is part of their responsibility.
- Engine modules must not invent a second public namespace or register themselves independently.
- Public handles are validated at their Rust owner before use. Serialized identifiers and renderer snapshots are copies, not new state authorities.

### Ownership

- One subsystem owns each mutable state model; consumers receive handles, messages, queries, or snapshots.
- Caches are derived state and follow the invalidation rules of their primary owner.
- GPU resources and submission are renderer-owned.
- Filesystem input remains external until path policy and format validation accept it.
- Errors cross boundaries as structured results or Lua errors; expected absence uses documented fallback behavior.

### Documentation And Proof

- Source behavior outranks stale prose; accepted architecture and manual specs define durable intent.
- Public behavior changes keep source docs, generated API, examples, specs, and tests aligned.
- Generated output is reproducible and never the only source of durable prose.
- New architectural claims identify an owner, a concrete dependency edge, a lifecycle, and a failure or rollback path.

## Decision Heuristics

1. Put state where its invariants can be enforced.
2. Prefer a narrow data boundary over shared mutable access.
3. Keep Lua wrappers thin and move reusable computation to its Rust or pure-Lua owner.
4. Keep optional product ideas out of current architecture until an RFC is accepted.
5. Prefer deletion or consolidation when two documents claim the same authority.

The canonical definition of module layers, allowed dependencies, and the
composition-root exception is [Module Scope Boundaries](module-scope-boundaries.md).

## Proposed Constraints

Optional native/module packaging is not active architecture. Its trade-offs and acceptance gates live in [Modularity And Plugins](modularity-plugins.md) and [RFC: Optional Module Packaging](proposals/optional-module-packaging.md).

## Retired Language

Historic tier-number naming and legacy root-level sibling paths are not current repo contracts. Use the responsibility groups in metadata and the repositories `lurek_2d_content/`, `lurek_2d_extension/`, and `lurek_2d_pages/`.
