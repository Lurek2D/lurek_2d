# IDEA — `src/sprite/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.

---

## 1. Header

- **Module**: `sprite`
- **Owner module path**: `src/sprite/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `CORE-KEEP`
- **LOC (rust only)**: ~1414 · **Public Lua surface**: `lurek.sprite` — ~15 fns / 5 userdata
- **Inbound non-`lua_api` callers**: `src/animation/controller.rs` (via SpriteSheet/Atlas for frame quads)
- **Heavy dependencies**: `serde_json` (atlas parsing)

## 2. Mission Summary

The sprite module provides higher-level game-graphics abstractions above the raw `RenderCommand` queue: individual sprites, instanced batches, sprite sheets, nine-patch panels, and TexturePacker/Aseprite atlas imports. It serves GameDev and Modder personas by making textured quad management ergonomic through `lurek.sprite.*`. It deliberately does NOT own animation playback (that belongs to `animation`) or GPU-level texture management (that belongs to `render`).

## 3. Existing Strengths

- Clean separation of concerns: each file owns exactly one concept (Sprite, SpriteBatch, SpriteSheet, NineSlice, SpriteAtlas).
- TexturePacker and Aseprite JSON formats both supported with well-tested parsers in `atlas.rs`.
- `SpriteSheet` supports directional layouts (4/8-dir), named groups, RPGMaker presets, and atlas-sourced frames — covers the most common sprite-sheet workflows.
- `NineSlice` computes all 9 patches in a single method call with no allocations.
- `SpriteBatch` enforces a max-entries cap and returns `Option<usize>` on add, preventing silent overflow.
- `SpriteSheet::draw_to_image` provides headless debug visualisation without GPU.

## 4. Gap List

1. **[P1][GAP]** `Runtime atlas packing` — No way to pack multiple loaded textures into a single GPU page at runtime, forcing one draw call per texture.
   - Why: Sprite-heavy games (bullet-hell, city builders) emit hundreds of draw calls; a runtime packer would reduce this to single digits.
2. **[P2][GAP]** `Normal/lit sprite support` — No normal map binding for 2D sprites under `lurek.light`.
   - Why: Games wanting dynamic 2D lighting must implement their own normal-map shader pipeline.
3. **[P3][GAP]** `Binary atlas format` — JSON parsing for large atlases (>5000 entries) adds measurable load time.
   - Why: Faster cold-start for asset-heavy games shipping packed atlases.

## 5. Feature Ideas

1. **[P1][FEAT]** `Runtime Atlas Packer` — Add `lurek.sprite.newAtlasPacker(w, h)` that takes multiple images and packs them onto a single GPU texture, returning a `SpriteAtlas` and the backing texture key.
   - Rationale: Enables single-draw-call rendering for sprite-heavy scenes (GameDev, Player: performance).
   - Effort: M · Risk: med (needs render-layer cooperation for texture creation).
   - Competitor inspiration: `[LÖVE2D: SpriteBatch with shared atlas — https://love2d.org/wiki/SpriteBatch]`, `[Godot: AtlasTexture runtime packing — https://docs.godotengine.org/en/stable/classes/class_atlastexture.html]`.
2. **[P2][FEAT]** `Sprite Normal Maps` — Allow a second texture key for a normal map channel; the render pipeline samples it during the lighting pass.
   - Rationale: Unlocks 2D dynamic lighting without custom shaders (GameDev).
   - Effort: M · Risk: med (requires render pipeline changes for a second sampler).
   - Competitor inspiration: `[Solar2D: Normal-map-based dynamic lighting via shader — https://docs.coronalabs.com/guide/graphics/effects.html]`.
3. **[P3][FEAT]** `Binary Atlas Format` — A flat binary format (header + UV table) for pre-packed atlases, loadable via `lurek.sprite.loadBinaryAtlas(path)`.
   - Rationale: Reduces load time for large atlas files (Player: startup speed).
   - Effort: S · Risk: low.

## 6. Performance / Reliability / Quality Ideas

- **[P2][PERF]** `Avoid per-frame Vec allocation in get_row/get_column` — `SpriteSheet::get_row` and `get_column` allocate a `Vec<Rect>` each call. Hot paths could use a pre-allocated scratch buffer or return iterators instead.
  - Hot path: `sprite_sheet.rs:get_row`, `sprite_sheet.rs:get_column`.
  - Verification: criterion bench with 8-dir sprite sheet queried 60 fps.
- **[P3][QUAL]** `Sprite Default impl` — Consider implementing `Default` for `Sprite` (texture_id = 0, position = origin) for consistency with other engine types.
  - File: `sprite.rs`.
  - Reason: Consistency with other engine types that implement `Default`.

## 7. Test Coverage Gaps

- **[P1][TEST-RUST]** Expand Rust tests for `parse_aseprite_json` in `atlas.rs` (hash format, error paths).
- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.sprite.newSheet` / `lurek.sprite.newBatch` under `tests/lua/sprite/`.
- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.sprite.loadAtlas` (TexturePacker JSON) and `lurek.sprite.loadAsepriteAtlas`.
- **[P3][TEST-FUZZ]** Fuzz target: `parse_texturepacker_json` with random JSON strings.

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): animation::controller::add_frames_from_grid — duplicates sprite_sheet grid-slicing logic; consider shared helper or SpriteSheet as input
TODO(dedup): animation::aseprite — overlaps with sprite::atlas::parse_aseprite_json; both parse Aseprite JSON but produce different output types
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): sprite_animator — Lua helper wrapping SpriteSheet + Animation for the common "sprite-sheet playback" pattern — citation: content/library/animator/init.lua
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): CORE-KEEP — sprites are the fundamental game rendering primitive; every 2D game uses them. No extraction benefit.
```

- **Extraction blockers**: Tightly coupled to `render::RenderCommand`, `runtime::resource_keys::TextureKey`, and `SharedState::textures` pool.
- **Heavy dep impact if extracted**: n/a.
- **Lua surface stability**: stable.
- **Migration step**: n/a.

## 11. References

- Module spec: [docs/specs/sprite.md](../../../docs/specs/sprite.md)
- Lua API reference: [docs/API/lua-api.md#sprite](../../../docs/API/lua-api.md)
- Philosophy constraints touched: `A-03` (2D only), `B-03` (60 FPS target)
- Plugin doc tier table: [plugins.md §5](../../../docs/architecture/plugins.md#5-candidate-modules)
- Competitor links cited above: LÖVE2D SpriteBatch, Godot AtlasTexture, Solar2D effects
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
- Session plan: [PLAN.md](../../work/src-module-review-20260418/reports/PLAN.md)
# IDEA.md — `sprite` module

> Migrated from `ideas/features/graphics.md` (sprite / atlas sections).
> Status checked against `src/sprite/` and `src/lua_api/sprite_api.rs`.
> Lua namespace: `lurek.sprite`.

---

## Features

### ❌ TODO — Runtime Atlas Packing (Batch Textures → Single GPU Page)
**Source**: features/graphics.md — Feature Gaps #1 / performance/02-gpu-rendering.md — Opportunity 2

No runtime atlas packer that takes multiple loaded textures and packs them into shared
GPU pages to reduce texture switching. This is the highest-ROI batching improvement —
reduces 200+ draw calls to 3–5 for a typical sprite-heavy game.

Suggested API:
```lua
local atlas = lurek.sprite.newAtlasPacker(2048, 2048)
atlas:add("player", player_img)
atlas:add("enemy", enemy_img)
local packed = atlas:pack()  -- returns SpriteAtlas + backing texture
```

---

### ❌ TODO — Normal Map / Lit Sprite Support
**Source**: general engine completeness

No normal map channel binding for lit 2D sprites (useful with `lurek.light` module).
Currently lighting and sprites are decoupled — a lit-sprite path would link them.

---

### ❌ TODO — Sprite Flip (flipX / flipY) as First-Class Atlas Feature
This item was moved above and marked DONE — see above.

---

### 🔇 LOW — Binary Atlas Format (Faster Load)
**Source**: general performance

JSON parsing at startup for large atlases adds measurable load time. A compiled binary
format (e.g. flat binary UV table) would load faster. Low priority unless atlas files
exceed ~5000 regions.
