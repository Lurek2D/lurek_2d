# IDEA — `src/parallax/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.
>
> See [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md) for filling instructions, TODO syntaxes, and
> the competitor-citation rule.

---

## 1. Header

- **Module**: `parallax`
- **Owner module path**: `src/parallax/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy** (per [plugins.md §5](../../docs/architecture/plugins.md#5-candidate-modules)):
  `TIER-2-PLUGIN`
- **LOC (rust only)**: ~550 · **Public Lua surface**: `lurek.parallax` — ~30 fns / 2 userdata (`ParallaxLayer`, `ParallaxSet`)
- **Inbound non-`lua_api` callers**: none
- **Heavy dependencies**: none (pure Rust; depends on `crate::render` for BlendMode/RenderCommand and `crate::runtime` for TextureKey)

## 2. Mission Summary

The `parallax` module provides multi-layer scrolling backgrounds with camera-relative
scroll factors, autoscroll, tiling, blend modes, z-ordering, and clamp boxes for GameDev
and Modder personas. It produces tile-position batches consumed by the renderer without
owning GPU resources or camera logic directly. It is NOT a general sprite-layer system
and does NOT handle foreground HUD overlays.

## 3. Existing Strengths

- Clean separation: pure-Rust domain types in `layer.rs`, render-command conversion in `render.rs`, CPU fallback in `draw.rs` — no mlua imports anywhere.
- Correct float-overflow prevention: `autoscroll_accum` wraps via `rem_euclid` to scaled texture size on each `update()`.
- Full tiling coverage: 4-way `(repeat_x, repeat_y)` matrix with correct tile start calculation and screen fill.
- Good test coverage across all three sub-files (layer, render, draw) — 12 tests covering defaults, autoscroll wrapping, invisible layers, tile counts, scroll offsets, color math, and headless draw.
- `ParallaxDrawBatch` design cleanly decouples domain scroll math from GPU draw calls.
- `ParallaxSet` (in lua_api) provides convenient grouped update/draw for multi-layer scenes.

## 4. Gap List

1. **[P2][GAP]** No per-layer shader/post-processing — layers can only set blend mode and tint, no custom fragment shaders.
   - Why: heat shimmer, water ripple, and fog effects on background layers need per-layer shader passes.
2. **[P2][GAP]** No velocity-based motion blur or stretch for fast-autoscroll layers.
   - Why: speed-run sequences with very fast autoscroll look static without blur.
3. **[P3][GAP]** No frustum culling for off-screen tiles in extreme-zoom or high-resolution scenarios.
   - Why: at 4K with small tile sizes, many draw calls are wasted on tiles that are fully off-screen.
4. **[P3][GAP]** `tiling` flag does not actually override `repeat_x`/`repeat_y` in `build_draw_calls`.
   - Why: the field exists and has a setter/getter but the draw-call builder reads `repeat_x`/`repeat_y` directly.

## 5. Feature Ideas

1. **[P2][FEAT]** Per-layer custom shader support — allow attaching a WGSL effect to a parallax layer for water ripple, heat shimmer, or fog.
   - Rationale: transforms static backgrounds into living environments; high visual impact for GameDev.
   - Effort: M · Risk: med (needs integration with the effect/image_effect pipeline).
   - Competitor inspiration: `[Godot: ParallaxLayer + ShaderMaterial for per-layer effects — https://docs.godotengine.org/en/stable/classes/class_parallaxlayer.html]`.

2. **[P2][FEAT]** Vertical-only parallax mode — common in top-down RPGs where backgrounds scroll vertically with the camera.
   - Rationale: current defaults (`scroll_factor = [1.0, 0.0]`) favor side-scrollers; a named mode for top-down use would improve discoverability.
   - Effort: S · Risk: low.

3. **[P3][FEAT]** Animated tile support — allow a parallax layer to cycle between multiple texture frames for animated water/lava backgrounds.
   - Rationale: currently parallax layers are static textures; animated backgrounds need manual layer swapping.
   - Effort: S · Risk: low.
   - Competitor inspiration: `[LOVE2D: no built-in parallax; Anim8 library handles animated quads — https://github.com/kikito/anim8]`, `[Defold: ParticleFX + Tilesource supports animated tiles in layers — https://defold.com/manuals/tilemap/]`.

## 6. Performance / Reliability / Quality Ideas

- **[P3][PERF]** Stripe-band culling — skip render calls for tile strips that fall entirely outside the viewport at high zoom levels.
  - Hot path: `layer.rs:build_draw_calls()` tile generation loops.
  - Verification: count DrawImageEx commands before/after at 4K resolution with small tile sizes.
- **[P3][QUAL]** Wire `tiling` flag into `build_draw_calls` — currently the field is stored but not read during draw-call generation; `repeat_x`/`repeat_y` are used instead.
  - File: `layer.rs:build_draw_calls()`.
  - Reason: dead-code smell; the `tiling` field, setter, and getter exist but have no effect.
- **[P3][REL]** Guard against zero-size `tile_w`/`tile_h` override — `set_tile_size` allows `Some(0.01)` which would create millions of tiles.
  - File: `layer.rs:set_tile_size()`.
  - Suggested fix: clamp minimum tile size to e.g. 1.0 px.

## 7. Test Coverage Gaps

- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.parallax.newLayer` with autoscroll + clamp bounds interaction.
- **[P2][TEST-LUA]** Add Lua BDD test for `ParallaxSet:sortByZ` ordering verification.
- **[P3][TEST-RUST]** Add Rust unit test for `build_draw_calls` with `tile_w`/`tile_h` override values to verify custom tile sizing.
- **[P3][TEST-RUST]** Add Rust unit test for `build_draw_calls` with both `repeat_x = true` and `repeat_y = true` to verify 2D tiling tile count.

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): camera — parallax scroll math reads camera position from SharedState but duplicates no camera logic; no actual code overlap, just a data dependency
TODO(dedup): tilemap — both parallax and tilemap produce tiled draw calls; could share a common tile-grid iterator if tile sizing logic is extracted
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): parallax_presets — common parallax configs (distant mountains, mid-ground trees, close foreground) with standard scroll factors — could be a content/library/parallax_presets/ module
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): TIER-2-PLUGIN — parallax is a self-contained feature with no inbound non-lua_api callers and minimal dependencies; games without scrolling backgrounds gain nothing from it
```

- **Extraction blockers**: `crate::render::renderer::RenderCommand::DrawImageEx` is a shared renderer variant (not parallax-specific), so extraction is trivial — just feature-gate the module.
- **Heavy dep impact if extracted**: negligible (~550 LOC pure Rust, no external crates).
- **Lua surface stability**: stable (API has been unchanged since initial implementation).
- **Migration step**: M1 (feature-gate behind `parallax` Cargo feature; no renderer enum changes needed).

## 11. References

- Module spec: [docs/specs/parallax.md](../../docs/specs/parallax.md)
- Lua API reference: [docs/API/lua-api.md#parallax](../../docs/API/lua-api.md)
- Philosophy constraints touched: `B-03` (60 FPS target — tile count per layer affects draw call budget)
- Plugin doc tier table: [plugins.md §5](../../docs/architecture/plugins.md#5-candidate-modules)
- Competitor links cited above: Godot ParallaxLayer, LOVE2D (no built-in parallax), Defold Tilesource
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
- Session plan: [PLAN.md](../../work/src-module-review-20260418/reports/PLAN.md) · Session decisions: [DECISIONS.md](../../work/src-module-review-20260418/reports/DECISIONS.md)
