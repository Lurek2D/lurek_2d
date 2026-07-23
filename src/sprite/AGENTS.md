# Sprite Module Contract

## Mission & Scope
- `sprite` owns textured-instance state, uniform sheets, named atlas regions, lightweight clips, and nine-slice descriptors.
- `image` owns pixels and generic packing; `animation` owns general graphs/Aseprite playback; `render` owns batches and GPU submission.

## Files

- `limits.rs` owns sprite input/work ceilings; sibling files own sheets, atlas records, animator state, and texture-atlas metadata.
- `src/lua_api/sprite_api.rs` owns conversion and public error context only.

## Rules
- Lua frame, group start, atlas index, and tile id inputs are one-based; reject zero rather than aliasing the first item.
- Grid row and column helpers remain zero-based and their Lua docs must say so.
- Validate finite transforms, timing, insets, and uniforms at the Lua edge before mutation.
- Sheets, clips, JSON, names, atlas entries, exports, and animation events have hard limits in `limits.rs`.
- Use checked arithmetic before allocation or coordinate construction; supplied atlas images must bound every region.
- Keep atlas/group exports deterministic (sorted names or documented insertion order).
- Lightweight animator updates advance arithmetically and emit at most the configured event budget.
- Do not hold userdata mutable borrows while calling Lua callbacks.

## Workflow
- Add Rust tests for core invariants and Lua unit/security/stress tests for public behavior.
- Run `cargo test --test sprite_tests`, sprite coverage audits, and `cargo clippy -- -D warnings` for behavior changes.
