# Lurek2D — Advanced Feature Surface Classification

## TL;DR

- This note classifies broad and genre-specialized modules as intentional advanced surfaces for now, not removal candidates.
- It is a governance note only. It does not change code, Cargo features, runtime registration, Lua APIs, tests, or generated docs.
- Future optionalization, extraction, or de-emphasis requires a product decision plus the gates below.

Companion documents: [philosophy.md](philosophy.md) · [engine-architecture.md](engine-architecture.md) · [plugins.md](plugins.md)

---

## Purpose

The API gap review raised a valid product-shape concern: Lurek2D exposes unusually broad systems for a compact 2D runtime, including AI, numerical compute, tabular data and SQL-style queries, globe/province strategy maps, and raycasting.

This document turns that concern into an architecture decision framework:

- These modules are **intentional advanced feature surfaces** in the current repository.
- They are not removed, renamed, or extracted by this note.
- They must remain consistent with the binding constraints in [philosophy.md](philosophy.md), especially runtime-only scope (A-01), 2D-only graphics (A-03), 60 FPS target (B-03), `lurek.*` namespace discipline (C-01), no cycles (T-03), and thin Lua bindings (TST-03).
- Any future optional-module or plugin decision must be based on measured pressure, not on the mere presence of advanced APIs.

---

## Classification Model

| Classification | Meaning | Default handling |
|---|---|---|
| **Core surface** | Required for most games and beginner examples. | Keep in the main learning path and default docs. |
| **Advanced feature surface** | Broad capability useful to simulations, tools, data-rich games, or advanced scripts, but not required for a first game. | Keep supported; contain docs and examples so beginners can ignore it. |
| **Genre-specialized feature surface** | Built for a specific game family while still obeying Lurek2D constraints. | Keep supported; present as optional learning path, not as core identity. |
| **Optionalization candidate** | A surface with measured size, dependency, performance, maintenance, or product-fit pressure. | Do not optionalize until the future gates in this note pass. |
| **De-emphasis candidate** | A surface that remains supported but should move out of quick-start and beginner-first docs. | Keep API stable; change docs/navigation only after a product decision. |

---

## Current Classification Table

| Surface | Current module group | Classification now | Why it is intentional now | Containment rule | Future decision pressure |
|---|---|---|---|---|---|
| `lurek.compute` / `src/compute/` | Foundations | Advanced feature surface | Provides CPU-only numerical arrays, signal processing, linear algebra, and spatial helpers for simulations, image/data processing, and advanced scripts. | Must remain GPU-free, engine-state-free, and lower-tier. It must not become the normal way to represent lightweight `Vec2` or `Vec3` gameplay values. | Binary size, compile cost, API-doc footprint, or confusion with simple math vectors. |
| `lurek.dataframe` / `src/dataframe/` | Foundations | Advanced feature surface | Provides in-memory tabular data, analytics, serialization, async tasks, and data-rich workflow support. Useful for strategy games, dashboards, procedural content, and tooling-like screens. | Must stay storage-agnostic at the domain layer. GameFS and Lua concerns stay at the boundary. Long-running work must use Rust workers rather than blocking the main Lua VM. | Binary size, dependency weight, beginner-doc noise, or a product decision that tabular analytics should be delivered as an add-on. |
| `LDatabase` and SQL-style queries inside `lurek.dataframe` | Foundations, under `dataframe` | Advanced feature surface | The SQL surface is an in-memory query catalog for local `DataFrame` tables, not an external database platform. It supports data-heavy game logic without adding a server or platform SDK. | Must not become a platform database integration. It must not introduce external DB processes, blocking Lua I/O, or non-GameFS storage assumptions. | Query-engine maintenance cost, API complexity, or a measured need to split query support from basic dataframes. |
| `lurek.ai` / `src/ai/` | Feature Systems | Advanced feature surface | Game AI is a valid 2D engine feature for NPCs, simulations, agents, and modder-authored behavior. The current contract is CPU-oriented and headless-testable. | Must stay game-behavior focused. Domain code must not import `lua_api`; debug rendering must remain a projection/output path, not the core owner of AI logic. | Learning-surface size, maintenance burden of ML/planning subareas, or product choice to expose only a smaller AI starter kit by default. |
| `lurek.globe` / `src/globe/` | Feature Systems | Genre-specialized feature surface | Supports geoscape and grand-strategy style maps while preserving the A-03 rule: output is 2D draw commands projected from spherical data, not a 3D scene graph. | Must not add a 3D renderer, perspective scene pipeline, or platform SDK dependency. Projection remains data-to-2D-render-command transformation. | Product decision that grand-strategy support should be a plugin or advanced package, or measured size/performance pressure. |
| `lurek.province` / `src/province/` | Edge/Integration, per current spec | Genre-specialized feature surface | Provides province-map runtime, topology, import, rendering commands, visibility state, and strategy-map economy helpers for map-painting games. | Must keep imports one-way and acyclic. PNG/CSV/TOML import is acceptable; editor or platform integration does not move into the core binary. | Product decision to move grand-strategy map tooling outside the default runtime, or measured binary/API maintenance pressure. |
| `lurek.raycaster` / `src/raycaster/` | Feature Systems | Genre-specialized feature surface | Provides pseudo-3D 2.5D raycasting for retro first-person games while staying within A-03: grid raycasts emit 2D/textured quads and software debug images. | Must not become a general 3D engine, 3D scene graph, or alternate renderer backend. It remains a 2D grid/ray projection system. | Product concern that raycasting weakens the 2D identity, or measured rendering/API maintenance pressure. |
| `lurek.ui` / `src/ui/` | Feature Systems | Advanced but core-adjacent UI surface | Native retained widgets, themes, focus, layouts, charts, and tables are useful for menus, HUDs, tools, and data-rich games. Existing specs already define its boundary against `lurek.html`. | Keep native widget and TOML-layout concerns here. Do not duplicate DOM/CSS semantics from `html`. | Only docs de-emphasis is plausible now; extraction would need strong product and compatibility evidence. |
| `lurek.html` / `src/html/` | Edge/Integration | Advanced but core-adjacent UI surface | HTML/CSS document screens are a separate authoring model for markup-driven UI, not a replacement for native widgets. Existing specs already define the `ui` vs `html` boundary. | Keep DOM/CSS/document concerns here. Do not make it an embedded browser, web platform, or editor runtime. | Optionalization only if measured size/complexity pressure appears and a compatibility path exists. |

---

## WONT Now

This note explicitly does **not** do any of the following:

- Remove, rename, or de-register `ai`, `compute`, `dataframe`, `globe`, `province`, `raycaster`, `ui`, or `html`.
- Split SQL query support out of `lurek.dataframe`.
- Create parallel namespaces, aliases, or replacement APIs for the classified modules.
- Add Cargo features, plugin manifests, package changes, build-profile changes, or runtime module toggles.
- Reclassify raycasting as a permitted 3D pipeline. It remains allowed only as 2D draw/projection work under A-03.
- Hand-edit generated API references.
- Claim that code, tests, runtime behavior, build output, or installed artifacts have changed.

---

## Future Gates for Optionalization, Extraction, or De-emphasis

Any future proposal to optionalize, extract, or de-emphasize one of these surfaces must pass all applicable gates.

| Gate | Required evidence |
|---|---|
| **Product decision gate** | A maintainer-level decision states the desired outcome: keep in core, de-emphasize in docs, feature-flag, plugin, external crate, or pure-Lua library. Architecture must not infer this from criticism alone. |
| **Constraint gate** | The proposal remains consistent with A-01, A-03, B-03, C-01, T-01 through T-08, and TST-01 through TST-06. Plugin work must align with [plugins.md](plugins.md); A-05 is still Proposed until accepted and measured. |
| **Measurement gate** | The proposal includes measured pressure such as stripped binary size, compile time, startup cost, frame-time impact, dependency weight, documentation/API footprint, or maintenance burden. No measurement means no extraction. |
| **Dependency gate** | The module graph remains acyclic. Domain modules do not import `lua_api`. Lower groups do not import higher groups. Extraction must not leave wrong-way imports or hidden coupling. |
| **API compatibility gate** | Public `lurek.*` behavior has a compatibility plan: keep stable, deprecate with migration docs, or provide a versioned plugin/package path. No silent removal. |
| **Documentation gate** | Architecture docs, affected `docs/specs/*.md`, examples, tutorials, and generated API outputs are updated from source as required. Generated files are not edited by hand. |
| **Testing gate** | Lua-reachable behavior has Lua tests; Rust-only domain behavior has appropriate Rust tests. De-emphasis without code changes still needs docs/link validation. |
| **Performance gate** | The default runtime still targets 60 FPS at 1080p on integrated GPUs. Heavy work remains CPU worker/thread based or explicitly bounded so the main Lua VM is not blocked. |

### Outcome Guidance

| Outcome | Use when | Avoid when |
|---|---|---|
| **Keep in core and contain** | The surface is useful, dependency cost is acceptable, and beginners can ignore it through docs/navigation. | It keeps creating measurable size, compile, performance, or maintenance problems. |
| **De-emphasize in docs** | The code is acceptable but the learning path looks too broad. | Users need the feature to understand first-run examples or basic engine identity. |
| **Feature-flag or optional module** | There is measured binary/dependency pressure and the surface can be cleanly isolated without API breakage. | The feature shares state that would create cycles or brittle runtime branches. |
| **Extract to plugin or external package** | The plugin system is accepted, packaging is defined, and the surface has a clear owner and compatibility path. | The extraction would require hidden imports back into the core or would break existing `lurek.*` contracts without migration. |
| **Move to pure Lua library** | The behavior can be expressed using public `lurek.*` APIs and does not need Rust performance or engine-owned resources. | The feature depends on Rust-only performance, resource pools, or rendering internals. |

---

## Validation Notes

- This is a documentation-only architecture note based on static review of the API feedback file, existing architecture documents, and current module specs.
- It records current intent and future decision gates only. It does not assert that module code, tests, runtime registration, Cargo features, generated docs, or package artifacts changed.
- Valid follow-up validation for this note is limited to Markdown/link/source-document checks unless a future proposal changes code or generated API surfaces.
- Cargo builds, Cargo tests, Clippy, installation, and packaging are intentionally out of scope for this note.
