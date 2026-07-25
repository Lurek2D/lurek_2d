# UI Module Contract

## Mission & Scope
- Own widgets, UI trees, layout, styles, input routing, callbacks, and UI render commands.
- Do not own GPU replay, filesystem policy, or image encoding.

## Files
- `context.rs`, `context/`: UI lifecycle, tree state, and caches.
- `widget.rs`, `controls.rs`, `extras.rs`, `containers.rs`: Widget data.
- `layout_loader.rs`, `theme.rs`, `icons.rs`: Layouts, themes, and icons.
- `render.rs`, `diagnostics.rs`, `limits.rs`: Render commands, checks, and limits.

## Rules
- Reject stale, foreign, or wrong-kind widget handles before mutation.
- Destroy and `clear` must release callbacks, events, focus, tree links, and caches.
- Apply `UiLimits`, finite-number checks, safe allocation, and bounded tree walks to Lua and TOML input.
- Layout loading validates first and commits once. Public paths use GameFS.
- Keep render command order stable and bounded.

## Workflow
- Run `cargo test --test ui_tests`.
- Run `cargo test --release --test ui_perf_tests -- --nocapture` for hot-path changes.
- Run `tools/python.cmd tools/audit/ui_boundary_check.py`.
