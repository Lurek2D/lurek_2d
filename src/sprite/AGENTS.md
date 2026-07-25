# Sprite Module Contract

## Mission & Scope
- Own sprite state, sheets, atlas regions, small clips, batches, and nine-slice data.
- Do not own image pixels, general animation graphs, or GPU submission.

## Files

- `sprite.rs`, `sprite_batch.rs`: Sprite and batch state.
- `sprite_sheet.rs`, `atlas.rs`, `texture_atlas.rs`: Sheets and atlas regions.
- `animator.rs`, `nine_slice.rs`, `limits.rs`: Small clips, nine-slice data, and limits.

## Rules
- Lua frame, group start, atlas index, and tile id inputs are one-based; reject zero rather than aliasing the first item.
- Grid row and column helpers are zero-based; Lua docs must say this.
- Validate finite transforms, timing, insets, and uniforms at the Lua edge before mutation.
- Apply `SpriteLimits` before parsing, storing, exporting, allocating, or sending events.
- Use checked math before allocation or coordinate work. Every atlas region must fit its image.
- Keep atlas and group export order stable.
- Animator updates must respect the event budget.
- Do not hold userdata mutable borrows while calling Lua callbacks.

## Workflow
- Run `cargo test --test sprite_tests` and the sprite Lua unit/security/stress tests.
