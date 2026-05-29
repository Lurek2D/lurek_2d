# Lurek2D - Architecture Index

## TL;DR

- Navigation for docs/architecture with the consolidated architecture set.

---

## Reading Order

1. [philosophy.md](philosophy.md)
2. [engine-core.md](engine-core.md)
3. [render-pipeline.md](render-pipeline.md)
4. [scripting-bridge.md](scripting-bridge.md)
5. [modularity-plugins.md](modularity-plugins.md)
6. [developer-ecosystem.md](developer-ecosystem.md)
7. [quality-assurance.md](quality-assurance.md)
8. [togaf.md](togaf.md)

---

## File Index

| File | Purpose | Status |
|---|---|---|
| [philosophy.md](philosophy.md) | Axioms, binding constraints, architectural invariants | ACTIVE |
| [engine-core.md](engine-core.md) | Process lifecycle from entry points through app/frame loop and state core | ACTIVE |
| [render-pipeline.md](render-pipeline.md) | Three-layer rendering model and GPU renderer contract | ACTIVE |
| [scripting-bridge.md](scripting-bridge.md) | Rust-Lua boundary, module registration, handle pattern, API file standards | ACTIVE |
| [modularity-plugins.md](modularity-plugins.md) | Feature-surface governance plus plugin migration architecture | PROPOSED |
| [developer-ecosystem.md](developer-ecosystem.md) | VS Code extension, CAG doctrine, MCP wiring, and local RAG system | ACTIVE |
| [quality-assurance.md](quality-assurance.md) | Rust + Lua quality model, evidence and CI quality gates | ACTIVE |
| [togaf.md](togaf.md) | TOGAF mapping and governance overlay across repository architecture | ACTIVE |

---

## When to Edit What

| You changed... | Update this document |
|---|---|
| Architectural constraints or hard rules | [philosophy.md](philosophy.md) |
| Process startup path, boot lifecycle, app orchestration | [engine-core.md](engine-core.md) |
| Render command flow, GPU passes, lighting/postfx pipeline | [render-pipeline.md](render-pipeline.md) |
| Lua-Rust bridge behavior or lua_api file standards | [scripting-bridge.md](scripting-bridge.md) |
| Feature classification, optionalization gates, plugin migration | [modularity-plugins.md](modularity-plugins.md) |
| VS Code extension architecture, CAG flow, MCP/RAG integration | [developer-ecosystem.md](developer-ecosystem.md) |
| Test strategy, quality gates, evidence and golden policy | [quality-assurance.md](quality-assurance.md) |
| Enterprise governance mapping and architecture board alignment | [togaf.md](togaf.md) |

Always add a bullet under the current version in [../CHANGELOG.md](../CHANGELOG.md).
