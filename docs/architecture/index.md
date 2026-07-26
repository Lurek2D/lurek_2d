# Lurek2D Architecture

Architecture documents describe the current engine: ownership, dependency direction, state lifetime, and durable constraints. They do not replace generated module specs or public API reference.

| Document | Owns |
|---|---|
| [Engine Core](engine-core.md) | Runtime composition, lifecycle, core state, and system boundaries. |
| [Render Pipeline](render-pipeline.md) | Render-command flow, GPU ownership, resource lifetime, and frame submission. |
| [Lua--Rust Boundary](scripting-bridge.md) | VM creation, API registration, sandboxing, handles, callbacks, and boundary tests. |
| [Module Scope Boundaries](module-scope-boundaries.md) | Cross-module ownership rules and prohibited overlaps. |
| [Runtime Tooling Boundaries](runtime-tooling-boundaries.md) | Shared schema, reflection, validation, filesystem, logging, and developer tooling. |
| [Philosophy and Constraints](philosophy.md) | Active architectural constraints that changes must preserve. |
| [Documentation System](docs-system.md) | Documentation sources, generated outputs, and publication topology. |

Use `docs/specs/` for module-level contracts and `docs/contributing/` for build, quality, CAG, and authoring workflows.
