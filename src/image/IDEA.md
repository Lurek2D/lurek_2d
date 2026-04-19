# IDEA — `src/image/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.

---

## 1. Header

- **Module**: `image`
- **Owner module path**: `src/image/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `CORE-KEEP`
- **LOC (rust only)**: ~4800 · **Public Lua surface**: `lurek.image` — ~50 fns / 5 userdata (ImageData, CompressedImageData, PaletteLUT, LayeredImage, ProvinceGrid)
- **Inbound non-`lua_api` callers**: `src/animation/`, `src/camera/`, `src/effect/`, `src/render/`, `src/sprite/`, `src/tilemap/`, visualization consumers across all tiers
- **Heavy dependencies**: `image` (PNG/JPEG decode), `ddsfile` (DDS parse), `flate2` (zlib for LIMG serial), `rayon` (parallel pixel ops)

## 2. Mission Summary

The `image` module provides Lurek2D's CPU-side pixel buffer (`ImageData`) and all operations on it — loading, encoding, drawing primitives, colour/tone effects, geometric transforms, convolution, and compositing layers. It serves **EngDev** (internal visualization, golden-image tests), **GameDev** (runtime image manipulation, province maps, sprite atlases), and **Modder** (palette swapping, procedural textures). It is deliberately NOT a GPU renderer — pixel data is uploaded to the GPU via the `render` module.

## 3. Existing Strengths

- **Comprehensive CPU effects suite**: 20+ effects (brightness, contrast, saturation, gamma, tint, grayscale, sepia, invert, threshold, posterize, blur, sharpen, noise, blit, convolve) — matches or exceeds LÖVE's `ImageData` surface.
- **Parallel pixel transforms**: `map_pixel_par` via Rayon for images > 65K pixels; serial fallback for small images — zero-config performance scaling.
- **Layered compositing**: Porter-Duff "over" with per-layer opacity/visibility — covers paint-program-style workflows without external dependencies.
- **ProvinceGrid**: Specialised O(1) spatial index for strategy games with single-pass adjacency detection — uncommon in 2D engines.
- **Binary serial format (LIMG)**: zlib-compressed flat and layered images with clean header/payload split — fast save/load for editor pipelines.
- **Visualization helpers**: 40+ standalone rendering functions for animation, camera, noise, geometry, and HUD — enables headless golden-image testing without GPU.

## 4. Gap List

1. **[P0][GAP]** `Screen pixel readback` — no `lurek.image.fromScreen()` or GPU→CPU readback path. Prevents screenshot, visual testing, and Lua post-processing pipelines.
   - Why: GameDev cannot capture in-game screenshots; EngTest cannot do pixel-level GPU regression tests.
2. **[P1][GAP]** `Bilinear resize only` — no Lanczos or bicubic downscale. Bilinear produces aliased mipmap chains.
   - Why: GameDev scaling UI assets or generating thumbnails loses quality.
3. **[P2][GAP]** `No GPU texture format negotiation` — `Texture::load` always produces RGBA8 premultiplied; no sRGB / linear toggle.
   - Why: EngDev must manually handle gamma when compositing in linear space.
4. **[P2][GAP]** `No nine-slice / border-repeat` — atlas regions cannot declare stretchable insets.
   - Why: GameDev building scalable UI panels must implement nine-slice in Lua.

## 5. Feature Ideas

1. **[P0][FEAT]** `fromScreen()` GPU readback — Async read-back: submit copy on frame N, poll result on frame N+1. Return `ImageData` to Lua.
   - Rationale: Unlocks screenshots, pixel-level visual testing, and Lua post-processing chains.
   - Effort: M · Risk: med (GPU sync design).
   - Competitor inspiration: `[LÖVE: love.graphics.captureScreenshot — https://love2d.org/wiki/love.graphics.captureScreenshot]`, `[Godot: Viewport.get_texture().get_image() — https://docs.godotengine.org/en/stable/classes/class_viewport.html]`.

2. **[P1][FEAT]** `Lanczos3 resize` — High-quality downscale filter using windowed sinc kernel. Expose via `lurek.image.resize(img, w, h, "lanczos3")`.
   - Rationale: Better mipmap/thumbnail quality than bilinear.
   - Effort: S · Risk: low.
   - Competitor inspiration: `[Solar2D: graphics.newTexture with filtering — https://docs.coronalabs.com/api/library/graphics/newTexture.html]`.

3. **[P2][FEAT]** `Nine-slice atlas regions` — Extend `TextureAtlas` with an optional `NineSlice { left, right, top, bottom }` inset descriptor per region.
   - Rationale: Standard requirement for scalable UI backgrounds (buttons, panels, dialogs).
   - Effort: S · Risk: low.

## 6. Performance / Reliability / Quality Ideas

- **[P1][PERF]** `Palette LUT apply O(pixels × entries)` — linear scan per pixel. For large palettes (>16 entries), build a `HashMap<u32, usize>` lookup at apply-time.
  - Hot path: `palette_lut.rs:apply()`.
  - Verification: bench with 256-entry palette on 1024×1024 image.
- **[P1][PERF]** `Blit per-pixel branch` — `blit()` checks `sa <= 0.0` per pixel; for fully opaque sources this can memcpy rows.
  - Hot path: `effects.rs:blit()`.
  - Verification: bench opaque blit vs current.
- **[P2][QUAL]** `draw_circle duplicate` — both `draw_circle` and `draw_circle_safe` exist with identical logic (signed vs unsigned radius). Unify to one method.
  - File: `image_data.rs`.
  - Reason: API surface confusion for GameDev.
- **[P2][QUAL]** `visualization.rs is 3000+ lines` — single file contains 40+ standalone functions. Split into `visualization/` submodule with per-domain files (animation, camera, noise, geometry, ui).
  - File: `visualization.rs`.
  - Reason: Navigability, test isolation, compile-time cost.

## 7. Test Coverage Gaps

- **[P0][TEST-RUST]** Add Rust tests for `serial.rs` layered round-trip (encode_layered → decode_layered with multi-layer stack). Currently only flat round-trip is tested.
- **[P1][TEST-LUA]** Add Lua BDD tests for `lurek.image.newCompressedData` (DDS load path).
- **[P1][TEST-LUA]** Add Lua BDD tests for `lurek.image.newProvinceGrid` adjacency queries.
- **[P2][TEST-RUST]** Add Rust tests for `texture_atlas.rs` shelf overflow and padding edge cases.
- **[P2][TEST-FUZZ]** Fuzz target candidate: `CompressedImageData::from_dds` (arbitrary byte input).
- **[P2][TEST-FUZZ]** Fuzz target candidate: `serial::load_image` / `serial::load_layered` (malformed LIMG files).

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): effect::image_effect — both image/effects.rs and effect/image_effect.rs apply pixel transforms; clarify which owns CPU-only effects vs shader-driven post-processing
TODO(dedup): sprite::SpriteSheet — sprite module builds its own frame atlas from TextureAtlas; shared atlas packing could live in image/texture_atlas.rs
TODO(dedup): render::TextureData — Texture::load duplicates premultiply-alpha logic that renderer also applies on upload; single source of truth needed
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): image_utils — palette cycling / animated palette swap wrapper — repeated pattern in content/library/ and content/demos/ game scripts
TODO(helper): nine_slice — Lua-side nine-slice draw helper using atlas region insets — needed until engine-level nine-slice lands (§5.3)
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): CORE-KEEP — ImageData is foundational to rendering, testing, effects, animation, and visualization; extracted by nearly every module in Platform Services and above
```

- **Extraction blockers**: `ImageData` is used by `render`, `effect`, `animation`, `camera`, `sprite`, `tilemap`, and all visualization consumers. Extracting would require a trait abstraction or a shared pixel-buffer crate.
- **Heavy dep impact if extracted**: `image` crate (~1.2 MB), `ddsfile` (~0.1 MB), `flate2` (~0.2 MB) — moderate.
- **Lua surface stability**: stable (core API unchanged since v0.3).
- **Migration step**: n/a (CORE-KEEP).

## 11. References

- Module spec: [docs/specs/image.md](../../../docs/specs/image.md)
- Lua API reference: [docs/API/lua-api.md#image](../../../docs/API/lua-api.md)
- Philosophy constraints touched: `A-03` (2D only), `B-02` (wgpu for GPU path), `B-03` (60 FPS target — CPU effects must not block)
- Competitor links cited above: LÖVE love.graphics.captureScreenshot, Godot Viewport.get_texture, Solar2D graphics.newTexture
- Session plan: [PLAN.md](../../work/src-module-review-20260418/reports/PLAN.md)
