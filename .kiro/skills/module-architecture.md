---
inclusion: manual
---

# module-architecture

## Mission
Own module boundaries, dependency direction, and visibility rules.

## When To Use
- Planning a new module.
- Reviewing module boundaries or dependency direction.
- Checking crate or folder layout.

## When To Skip
- Implementation work, API naming.

## Rules

### Tier Dependency Graph
Five tiers — imports must only flow downward:
1. **Foundations** — math, data, serial
2. **Core Runtime** — runtime, app, event
3. **Platform Services** — render, audio, input, window, filesystem
4. **Feature Systems** — physics, animation, ai, particle, tilemap, etc.
5. **Edge / Integration** — lua_api, network, mods, devtools

Any import from a lower tier to a higher tier is a binding constraint violation (T-01). Cycles between any two modules are a binding constraint violation (T-02).

To audit: run `python tools/audit/dep_graph.py` or `cargo tree --edges all | grep -E "->.*src/"`.

### mod.rs as Manifest
Every `src/<module>/mod.rs` contains only: `pub mod`, `pub use`, `#[allow(...)]` at file level, and doc comments. No `fn`, `struct`, `impl`, or `const` definitions.

Check with: `python tools/audit/thin_modrs_audit.py`. Fix violations by moving definitions to a sibling file.

### Placing a New Module
1. Identify the tier based on what it imports.
2. Check if an existing module can absorb it as a submodule without expanding scope.
3. Create `src/<module>/mod.rs` as a manifest; implement in sibling files; export only the public API; register in `src/lib.rs`.
4. Add `docs/specs/<module>.md` and update `docs/specs/README.md`.

### lua_api Boundary Rule
No `src/<module>/` should import from `src/lua_api/`. If domain code needs a type that lives in a binding file, move that type to `src/<module>/` first. Binding files import from domain modules — never the reverse.

### Dependency Inversion
When a module wants data from a higher tier: define a trait in the lower-tier module, implement it in the higher-tier module, and inject the implementation via the composition root in `src/app/` or `src/runtime/`. Do not use `pub use` workarounds.

### Cross-Module Communication
- Within a tier: function calls and struct arguments.
- Across tiers: prefer passing data through the composition root.
- Sanctioned cross-tier paths: event system (`src/event/`) and shared state (`src/runtime/shared_state.rs`).

## References
- `docs/specs/`
- `src/lib.rs`
- `tools/validate/validate_module_coverage.py`
- `tools/audit/thin_modrs_audit.py`
