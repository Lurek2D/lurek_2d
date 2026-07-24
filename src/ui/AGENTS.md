# UI Module Contract

## Mission & Scope
- Own retained widgets, tree/layout/style state, normalized-input routing, callbacks, and UI-to-`RenderCommand` lowering.
- `context.rs` and `context/*` own lifecycle/cache passes; `widget.rs`, `controls.rs`, `extras.rs`, and `theme.rs` own widget data; `layout_loader.rs` owns validated transactional layouts.
- `render.rs` lowers UI only. `render` owns GPU/software replay; `filesystem` owns GameFS/path policy and `image` owns encoding.

## Files
- `context.rs`, `widget.rs`, `controls.rs`, `extras.rs`, `theme.rs`, `layout_loader.rs`, and `render.rs` are the current UI owners.

## Rules
- Widget references are opaque generational handles; reject stale, foreign, or wrong-kind handles before mutation.
- Destruction and `clear` must release callbacks, events, focus/capture, tree links, and derived caches through the lifecycle path.
- Apply `UiLimits`, finite numeric checks, checked allocation, and bounded traversal to every Lua/TOML entry path.
- Layout loading is transactional; public layout reads use GameFS and capture output follows the filesystem policy.
- Keep dirty generations/cache work observable and preserve deterministic, bounded command lowering.

## Workflow
- `cargo test --test ui_tests`
- `cargo test --release --test ui_perf_tests -- --nocapture`
- `cargo test --test lua_tests lua_security_ui_security` and `cargo test --test lua_tests lua_stress_ui_stress`
- `tools/python.cmd tools/audit/ui_boundary_check.py`
