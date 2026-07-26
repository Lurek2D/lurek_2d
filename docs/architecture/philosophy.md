# Lurek2D Philosophy and Active Constraints

## Purpose

These are the current constraints for architectural changes. A proposal that needs an exception must first update this document and the affected owning architecture document; it must not create a silent local workaround.

## Project model

Lurek2D is a Lua-first desktop 2D runtime. Lua owns game, simulation, tool, and application logic through `lurek.*`; Rust owns the runtime services and performance-sensitive systems behind that API.

The product is code-first. The extension and other developer tools support the runtime but are not part of the engine binary or a substitute for the Lua API.

## Dependency and ownership constraints

| ID | Constraint |
|---|---|
| A-01 | The Rust module graph is acyclic. A cycle is a design defect, not a reason for an exception. |
| A-02 | `app` composes the running application and `lua_api` exposes the public boundary. Lower-level domain modules do not import either layer. |
| A-03 | Domain modules own their state and behavior. Binding modules translate arguments, results, and errors; they do not become a second business-logic owner. |
| A-04 | `runtime` owns shared runtime state, configuration, errors, and cross-cutting coordination. It does not become a catch-all domain module. |
| A-05 | Renderer/GPU resources remain owned by rendering code. Domain modules provide data or commands, never backend objects. |
| A-06 | Serializable game data is independent of GPU handles, OS windows, and Lua VM references. Snapshots and caches never silently become the primary owner. |
| A-07 | Tooling (`docs`, `devtools`, `debugbridge`, `automation`) observes, validates, or coordinates; it does not take ownership of gameplay state. |
| A-08 | Public scripts use the `lurek.*` surface. Lureksome libraries consume that public surface rather than Rust internals. |

## Platform and runtime constraints

| ID | Constraint |
|---|---|
| P-01 | Supported runtime targets are desktop Windows, Linux, and macOS. Mobile and WebAssembly are outside the current architecture. |
| P-02 | The engine is a 2D renderer. Isometric and raycast-style views remain 2D projections rather than a general 3D scene graph. |
| P-03 | LuaJIT through `mlua` is the primary scripting runtime. Lua VMs remain single-threaded; concurrency belongs in Rust and crosses the boundary through explicit data/messages. |
| P-04 | `wgpu` is the renderer backend; the public API does not expose backend-specific ownership. |
| P-05 | TOML is the primary authored configuration format. Other formats are accepted only at explicit import/export boundaries. |

## API and quality constraints

| ID | Constraint |
|---|---|
| Q-01 | Public Lua names, signatures, defaults, units, and errors are documented from source and tested through the public boundary. |
| Q-02 | Every public behavior has one canonical example owner and one test owner; examples teach, tests prove. |
| Q-03 | Rust-only tests protect private seams; Lua tests protect user-visible contracts. |
| Q-04 | Architecture, specs, examples, and generated docs change together whenever a durable public contract changes. |
| Q-05 | New state authority, new cross-module dependency, or a lifecycle change requires an explicit owner and failure path. |

## Decision heuristics

- Prefer one clear owner over a shared mutable mirror.
- Prefer explicit adapters and data flow over hidden coupling.
- Split modules by responsibility and change pressure, not file length alone.
- Keep user-facing APIs Lua-native while preserving Rust-side validation and error context.
- Optimize for a reader to identify the owner, boundary, and proof path without scanning unrelated modules.

## Related documents

- [Engine Core](engine-core.md) defines runtime composition and lifecycle.
- [Render Pipeline](render-pipeline.md) defines render and GPU ownership.
- [Lua--Rust Boundary](scripting-bridge.md) defines the public scripting boundary.
- [Quality Assurance](../contributing/quality-assurance.md) defines test and evidence placement.
