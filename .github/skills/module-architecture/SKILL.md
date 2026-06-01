---
name: module-architecture
description: "Load this skill when planning module boundaries, dependency direction, or crate layout. Skip it for implementation or API naming."
---
# module-architecture

## Mission
- Own module boundaries, dependency direction, and visibility rules.

## When To Load
- Plan a new module.
- Review module boundaries.
- Fix bad dependency direction.
- Check crate or folder layout.

## When To Skip
- Implementation work.
- API naming.

## Domain Knowledge
- The five tier dependency graph is: Foundations → Core Runtime → Platform Services → Feature Systems → Edge/Integration. Any import that goes upward from a lower tier to a higher tier is a binding constraint violation.
- How to audit the current dependency graph: run `python tools/audit/dep_graph.py` or use `cargo tree --edges all | grep -E "->.*src/"`. Compare the result against the tier table.
- `mod.rs` as a manifest: every `src/<module>/mod.rs` must contain only `pub mod`, `pub use`, attributes]` at file level only), and doc comments. No `fn`, `struct`, `impl`, or `const` definitions belong in `mod.rs`.
- How to place a new module: identify the tier it belongs to based on what it depends on — if it needs `render`, it is Feature or Edge, never Foundations; check if an existing module can absorb it as a submodule without growing beyond one clear responsibility; create `src/<module>/mod.rs` as a manifest, implement in sibling files, export only the public API in `mod.rs`, then register in `src/lib.rs`; add `docs/specs/<module>.md` and update `docs/specs/README.md`.
- `src/lua_api/` is a boundary layer: no `src/<module>/` should import from `src/lua_api/`. If domain code needs a type that currently lives in a binding file, move that type to `src/<module>/` first.
- When a module wants data from a higher tier: the solution is dependency inversion, not a `pub use` workaround. Define a trait in a lower-tier module, implement it in the higher-tier module, and inject the implementation via the composition root in `src/app/` or `src/runtime/`.
- Cross-module communication rule: within a tier, modules communicate via function calls and struct arguments. Across tiers, prefer passing data through the composition root rather than direct imports.
## Companion File Index
- None.

## References
- docs/specs/
- src/lib.rs
- tools/validate/validate_module_coverage.py
- tools/audit/thin_modrs_audit.py