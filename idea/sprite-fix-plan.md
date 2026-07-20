# Sprite module audit and fix plan

## Goal

Harden `sprite` as the runtime textured-2D model for sprite instances, grid sheets, named atlas regions, lightweight clip playback, nine-slice descriptors, and sprite-specific atlas metadata. Fix indexing and non-finite timing defects, bound parsers/packing/animation work, and keep raw pixels in `image`, general animation graphs in `animation`, GPU/batch execution in `render`, autotile policy in `tilemap`, and generic UI layout in `ui`.

## Current evidence

- Canonical code is `src/sprite/*.rs`; the public binding is `src/lua_api/sprite_api.rs` (1,196 lines). There is no `src/sprite/AGENTS.md`.
- Focused audits report 79/79 generated Lua APIs in specs and 79/79 exact Lua unit owners, structurally clean examples, and all 12 namespace functions represented in `content/examples/sprite.lua`.
- `cargo test --test sprite_tests` passes 28/28. The module audit reports the best private-seam ratio of the four modules (28 tests for roughly 69 public methods) but still misses the defects below.
- Sprite has evidence/golden artifacts, but no `tests/lua/stress/test_sprite_stress.lua` and no `tests/lua/security/test_sprite_security.lua`.
- `audit_module.py sprite` flags missing structured docs for at least 16 types, missing binding separators, and large closures near `sprite_api.rs:895`, `939`, `1036`, and `1105`.
- Thin-wrapper and docstring audits are clean; Lua spec/unit/example ownership is 100%. These structural passes do not prove index conventions, parser budgets, image/atlas compatibility, deterministic ordering, or animation catch-up limits.
- The global perf gate passes, but there is no sprite-specific baseline for sheet construction, atlas parsing/packing, animator catch-up, region export, or batched submission.

## Required ownership boundary

| Concern | Canonical owner | Sprite rule |
|---|---|---|
| Sprite transform/tint/material reference, sheets, atlas regions, clip playback, nine-slice metadata | `sprite` | Keep runtime textured-instance semantics here. |
| Raw RGBA buffers, codecs, resampling, generic rectangle packing | `image` | Sprite consumes dimensions/images and composes the canonical packer. |
| General clips/state machines/blending/sync/Aseprite timing/tags | `animation` | Sprite animator stays intentionally lightweight and frame-grid based. |
| Shader validation, texture resources, sprite batches, draw submission | `render` | Sprite stores semantic/resource keys; render owns `lurek.render.newSpriteBatch` and GPU execution. |
| Autotile layout/matching | `tilemap` / `tileset` | Sprite may expose a compatibility descriptor only; do not own tile rules. |
| UI widgets/layout | `ui` | Nine-slice descriptor is reusable texture geometry; widget policy remains UI. |
| Spine attachments | `spine` | Spine may consume `SpriteAtlas`; sprite does not own skeleton playback. |

The manual statement that sprite “supports batching” must clarify that the data type lives under `src/sprite`, while the public Lua constructor/draw lifecycle is canonically `lurek.render.newSpriteBatch` / `drawBatch`.

## Findings and work order

### P0 - Fix indexing and timing correctness

1. Establish one Lua indexing contract and implement it exactly.
   - `LSpriteSheet:getFrame` is documented as one-based but passes the Lua index directly to zero-based `SpriteSheet::get_frame`, so index 1 returns the second frame.
   - `nameGroup` documents a one-based start but stores it without conversion.
   - `LSpriteAtlas:getByIndex` uses `saturating_sub(1)`, so invalid index 0 aliases the first entry instead of returning nil/error.
   - Autotile methods use the same `saturating_sub(1)` pattern for tile ID 0.
   - Add shared checked one-based conversion, reject zero, and audit every row/column/frame/tile/group method. If rows/columns intentionally remain zero-based, document that exception prominently or migrate them consistently.
2. Eliminate animator infinite-loop/non-finite behavior.
   - `SpriteClip::normalized` checks only `fps <= 0`; NaN survives and infinity produces `frame_time = 0`, making `while elapsed >= frame_time` non-terminating.
   - Reject non-finite `fps` and `dt`; define a maximum FPS and maximum frames/events advanced per update.
   - Replace unbounded per-frame catch-up with arithmetic advancement plus a bounded event policy. Report dropped/coalesced events when `dt` crosses too many frames.
3. Validate clip ranges against the associated sheet when a sheet is available. The standalone animator can keep logical ranges, but drawing helpers must fail clearly rather than return unrelated/out-of-range frames.
4. Make unknown clip playback observable. `play` currently silently does nothing for an unknown name; Lua should return false or a named error.
5. Define callback behavior when an animator callback mutates playback, replaces clips, errors, or recursively calls `update`. Snapshot bounded events, then invoke callbacks without holding mutable domain borrows.

### P0 - Bound constructors, JSON parsers, and packing

1. Add `src/sprite/limits.rs` with `SpriteLimits`.
   - Bound sheet frames, clips, clip-name bytes, atlas JSON bytes/depth, entries, total name bytes, atlas dimensions/area, padding, packed regions, group count, exported table entries, animator events per update, shader uniform name/table size, and any sprite-owned batch metadata.
   - Use checked arithmetic before allocation/work.
2. Replace `SpriteSheet::new` with strict construction.
   - `columns * rows` currently multiplies in `u32`, can overflow, and precomputes a `Vec<Rect>` without a ceiling.
   - Validate frame dimensions do not exceed texture dimensions, define remainder policy for non-divisible sheets, checked frame-coordinate multiplication, and avoid precomputing rectangles if formula-based lookup is cheaper.
3. Harden TexturePacker/Aseprite JSON import.
   - Reject oversized input before `serde_json::from_str`.
   - Bound frames/names/nesting, reject duplicate names deterministically, validate nonzero sizes, checked `x + w` / `y + h`, and normalize supported rotation/trim metadata.
   - Reuse `animation::aseprite::load_aseprite_json` as the canonical Aseprite parser; do not fork its format policy.
4. Make `newAtlasFromImage` validate the atlas against the supplied image. It currently borrows the image into `_image` and discards it; out-of-bounds regions are accepted.
5. Harden runtime atlas packing.
   - `TextureAtlas` uses unchecked `w + padding`, `h + padding`, inset sums, shelf offsets, and dimensions.
   - Duplicate region names currently consume new shelf space and overwrite the map entry, leaking atlas capacity. Reject duplicates or implement true in-place replacement without new allocation.
   - Return typed failure reasons (`duplicate`, `invalid`, `full`, `overflow`) rather than a single boolean where Lua usability warrants it.
6. Consolidate packing with `image::RectPacker`. Sprite should compose one checked generic packer and add sprite region/nine-slice metadata, not maintain a second shelf algorithm.

Acceptance: invalid indices never alias valid entries; animation update has a hard event/work ceiling; JSON/sheet/atlas construction fails before large allocation and validates source-image bounds.

### P0 - Numeric, resource, and deterministic-state safety

1. Validate every sprite transform/material value as finite: position, scale, rotation, color, normal intensity, nine-slice insets/dimensions, animator values, and shader uniforms.
2. Fix shader uniform conversion.
   - Lua integer to `i32` currently uses `as i32`, silently truncating large values.
   - Lua number to `f32` must range-check before conversion.
   - Bound uniform names and table lengths; let render remain the canonical schema/type validator.
3. Harden `newNineSlice`.
   - NaN passes the current `< 0` checks.
   - An invalid/stale image handle falls back to texture dimensions `(0, 0)` instead of erroring.
   - Require finite non-negative insets, live texture, positive source dimensions, and inset sums within the source. Define small target behavior explicitly.
4. Make all externally visible ordering deterministic.
   - `TextureAtlas::get_regions` returns `HashMap` values in unspecified order.
   - Clip/group name exports must be sorted or preserve documented insertion order.
   - Atlas object-format input and duplicate handling must produce stable index order across builds.
5. Validate sprite/normal-map texture handles at assignment and again at draw snapshot time. Stale keys should produce a clear render diagnostic, not silently sample an unrelated/reused resource.
6. Define rotation/trim semantics for imported atlases. `rotated` is parsed, but source-size/trim/pivot metadata is mostly discarded; either support it through the draw contract or reject/clearly document unsupported metadata.

### P0 - Resolve module overlap without losing useful APIs

1. Keep sprite animator deliberately small: named grid ranges, FPS, loop/pause/resume, and frame events. Route state machines, blending, sync groups, curves, and authored Aseprite durations/tags to `animation`.
2. Keep `SpriteAtlas` as runtime named regions and `TextureAtlas` as sprite metadata over the generic image packer. Do not duplicate raw atlas image construction or generic rectangle packing.
3. Keep sprite batches public under `render`; sprite owns the CPU entry data structure only. Do not add a duplicate `lurek.sprite.newBatch`.
4. Decide the autotile compatibility surface.
   - `sprite_api.rs` directly imports `tilemap::{AutoTileLayout, AutoTileSheet}`.
   - Prefer canonical `tilemap`/`tileset` ownership with a thin sprite compatibility alias only if old content requires it. Record migration and error parity.
5. Keep nine-slice geometry reusable, but distinguish sprite descriptor, render draw handle, and UI widget policy in docs. Avoid three independently implemented slice algorithms.

### P1 - Code quality and performance

1. Split `sprite_api.rs` into private registration groups: sprite instance/material, sheet/groups, atlas/import, animator/callbacks, packer/nine-slice, and compatibility adapters.
2. Extract the large `newAnimator`, `newSheetFromImage`, atlas, and nine-slice closures reported by the audit. Core helpers own validation; bindings convert/register.
3. Consider formula-based `SpriteSheet` rect lookup instead of storing every uniform grid frame. Preserve atlas-backed irregular frames as an explicit representation variant.
4. Reuse buffers for frame/group exports and bounded animator events. Avoid cloning clip names for every frame event where an interned/shared identifier suffices.
5. Make atlas name lookup and ordered iteration share one source of truth; avoid `Vec`/`HashMap` divergence during replacement/removal.
6. Rewrite generic file docs and add structured sections for all reported types: clips/events/animator, atlas entries/maps, direction/group iterators, nine-slice patches/insets, sprite/batch entries, limits, and pack results.

### P1 - Tests and proof

1. Expand `tests/rust/unit/sprite_tests.rs` for:
   - exact one-based Lua conversion helpers and zero/out-of-range behavior;
   - sheet multiplication/coordinate overflow, dimension/remainder policy, frame ceilings;
   - animator NaN/inf/negative/huge dt/FPS, event cap, loop/end ordering, unknown clips, callback mutation policy;
   - JSON input/entry/name/depth limits, duplicates, overflow, out-of-image regions, rotations/unsupported trim data;
   - atlas packing overflow, duplicate-name capacity, deterministic order, typed full/invalid errors;
   - nine-slice finite/live-resource/inset validation and small target behavior;
   - shader uniform narrowing and stale texture/shader handles;
   - parity between canonical owners and compatibility aliases.
2. Add Lua regression tests that specifically prove `getFrame(1)` is the first frame, `nameGroup(..., 1, ...)` starts at the first frame, and index/tile ID zero never aliases one.
3. Add `tests/lua/security/test_sprite_security.lua`: oversized sheets/atlases/JSON/clips/names, non-finite timing/transforms/insets/uniforms, duplicate/malformed atlas records, stale/cross-type userdata, invalid shaders/textures, recursive/erroring callbacks, and extreme indices.
4. Add `tests/lua/stress/test_sprite_stress.lua`: bounded large sheets, many atlas entries/lookups/exports, packing to capacity, many animators with catch-up, callback event ceilings, shader uniforms, and repeated construct/clear cycles.
5. Keep evidence/golden focused on atlas flips/rotations, first/last frame correctness, animation event timing, nine-slice geometry, normal-map state, and shader visuals. Use assertions for data invariants.
6. Add integration coverage for image-to-atlas validation, animation parser reuse, render batch ownership, tilemap autotile compatibility, and spine atlas consumption.

### P1 - Docs, API, specs, examples, and file docs

1. Add parser-recognized separators and structured docs for every audit finding; regenerate from source.
2. Update `docs/specs/manual/sprite.md` with indexing conventions, limits, deterministic order, atlas source bounds/metadata support, animator catch-up/event policy, shader/resource ownership, and compatibility migrations.
3. Fix contradictory RPG Maker documentation. The core uses a 3-column by 4-row layout, while the Lua doc currently says 4 by 4.
4. Add an ownership table distinguishing lightweight sprite clips from general animation, sprite atlas metadata from image packing, render batches from sprite state, and sprite nine-slice descriptors from UI widget policy.
5. Review all 79 example blocks for meaningful standalone use. Add first/last frame examples that make indexing unambiguous and do not teach `0` where an API is one-based.
6. Document rotated/trimmed atlas behavior and failure modes, not merely parsed fields. Avoid promising metadata that render paths ignore.

### P2 - Useful non-duplicating feature gaps

Implement only after P0/P1 and owner approval:

1. Atlas validation/report API returning all bounded diagnostics (duplicate, out-of-bounds, unsupported trim/rotation) without constructing live state.
2. Optional frame-event coalescing summary for huge delta catch-up, preserving a bounded number of detailed events.
3. Immutable atlas/sheet snapshots with stable generation IDs for spine/render/tool consumers.
4. Trimmed-frame pivots/source-size offsets if render consumes them end-to-end; use the canonical Aseprite parser.
5. Batched sprite property updates only if profiling shows Lua crossing cost, while draw batching remains render-owned.

Reject: general animation state machines/blending, raw image codecs/effects, generic bin-packing duplication, GPU pipelines, UI layout, or tile matching policy.

## Performance plan

- Add release baselines for uniform and irregular sheet construction/lookup, group/range export, TexturePacker/Aseprite parse, name/index lookup, generic-pack composition, animator updates/catch-up/callback dispatch, and render-owned batch data submission.
- Record JSON bytes/depth, entries/names, frames, clips, events, packed area, allocations, and elapsed time.
- Compare precomputed vs formula-based uniform sheet frames before changing representation.
- Prove animator work is capped independently of `dt * fps` and parser/packing rejection happens before large allocation.
- Add sprite-specific scenarios to the perf gate; the global stress score does not cover these paths.

## CAG and contract updates to include with implementation

1. Update `review-all` minimally to require one-based/zero-based API consistency, finite animation timing, parser/JSON budgets, deterministic map export, compatibility-owner review, and validation that supplied resources are actually consumed.
2. Extend `review-performance` to check `dt * rate` catch-up loops, event/callback amplification, parser depth/count, and precomputed-table growth.
3. Extend `review-tests` to require security/stress presence and semantic indexing/resource tests in addition to exact markers.
4. Fix `tools/AGENTS.md` to document positional `audit_module.py sprite`.
5. Add compact `src/sprite/AGENTS.md` (target 18-26 lines): one Lua indexing policy, finite/bounded clips, checked sheets/atlases, deterministic ordering, image/animation/render/tilemap/UI boundaries, and security/stress gates.
6. Add reciprocal one-line boundaries to image/animation/render/tilemap only where canonical APIs change. Do not expand root `AGENTS.md`.

## Implementation owners and sequence

1. `architect`: approve indexing migration, lightweight-animation scope, packer/autotile/nine-slice ownership, and metadata support.
2. `developer`: limits, strict sheet/atlas/animator/packer/resource core and deterministic state.
3. `lua_designer`: checked indexing, binding split, callback safety, typed errors, and compatibility aliases.
4. `tester`: Rust regressions, new Lua security/stress, integrations, evidence/golden, and perf baselines.
5. `content`: revise examples after generated API changes.
6. `doc_writer`: source docs, manual spec, generated docs.
7. `cag_architect`: focused skill/contract updates.
8. `reviewer`: rerun audits and verify cross-module ownership/performance.

## Verification

```powershell
tools\python.cmd tools\audit\audit_module.py sprite --docs-quality
tools\python.cmd tools\audit\thin_wrapper_audit.py --scope sprite --format text
tools\python.cmd tools\audit\docstring_audit.py --file src\lua_api\sprite_api.rs --check
tools\python.cmd tools\audit\example_coverage.py --module sprite --report --no-stubs --no-partials --lint
tools\python.cmd tools\audit\unit_test_api_coverage.py --module sprite --threshold 100
tools\python.cmd tools\audit\lua_spec_coverage.py --module sprite --threshold 100
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\stress\test_sprite_stress.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\security\test_sprite_security.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_evidence_golden_contract_audit.py
cargo test --test sprite_tests
cargo test --test lua_tests
tools\python.cmd tools\audit\perf_regression_gate.py
cargo clippy -- -D warnings
tools\python.cmd tools\validate\cag_validate.py
tools\python.cmd tools\audit\cag_link_check.py --strict
```

## Done definition

- Lua indexing is consistent, documented, and regression-tested; invalid zero never aliases the first item.
- Animator timing/event work, sheets, parsers, atlases, names, uniforms, and exports are finite and bounded.
- Atlas records are checked against source images and deterministic; packing has one generic implementation.
- Sprite does not duplicate animation, image, render batch, UI, or tilemap ownership.
- Rust, Lua unit, security, stress, integration, examples, specs, docstrings, file docs, evidence/golden, and sprite-specific performance checks pass.
