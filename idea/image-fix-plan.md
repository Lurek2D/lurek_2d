# Image module audit and fix plan

## Goal

Harden `image` as the bounded CPU pixel-domain authority for RGBA buffers, image effects, layered composition, palette mapping, safe codecs, serialization, and generic atlas-preparation primitives. Remove feature-system visualization dependencies, make all decoding/export paths resource-safe and sandbox-consistent, and keep runtime sprite regions, province semantics, animation, camera/audio/UI diagnostics, and GPU execution with their canonical owners.

## Current evidence

- Canonical code is `src/image/*.rs` plus `src/image/visualization/*.rs`; the binding is `src/lua_api/image_api.rs` (1,818 lines). There is no `src/image/AGENTS.md`.
- Focused audits report 121/121 generated Lua APIs in specs and 121/121 exact Lua unit owners, structurally clean examples, and all 15 namespace functions represented in `content/examples/image.lua`.
- `cargo test --test image_tests` passes 29/29, including random-byte LIMG/DDS no-panic tests. The module audit still reports only 29 tests for roughly 110 public Rust methods and no image hostile-input security suite.
- `tests/lua/stress/test_image_stress.lua` has only three valid stress owners. Evidence/golden contracts pass; `tests/lua/security/test_image_security.lua` is absent.
- `audit_module.py image` reports a real dependency-direction error: Platform Services `image` imports Feature Systems `province`. It also reports missing structured docs for at least 15 types, missing binding separators, and large closures near `image_api.rs:817`, `856`, `991`, and `1036`.
- The dedicated docstring audit is clean and thin-wrapper audit is clean, but current structural coverage does not prove decoder budgets, filesystem policy, callback work, or transactional effects.
- The global perf gate passes, but there is no image-specific limit or baseline for pixels, decoded bytes, GIF frames, LIMG expansion, layers, kernel sizes, callbacks, or exports.

## Required ownership boundary

| Concern | Canonical owner | Image rule |
|---|---|---|
| CPU RGBA storage, pixel mutation, effects/resampling, palettes, layered composition | `image` | Keep here with checked dimensions and work ceilings. |
| Encoded image/LIMG/GIF parsing and export | `image` plus GameFS/asset path policy | Codecs live here; filesystem authority does not. |
| Generic rectangle packing used for atlas preparation | `image` | Keep one canonical algorithm; consumers compose it. |
| Runtime atlas regions, sprite sheets, sprite animation state | `sprite` | Consume image dimensions/data; do not duplicate runtime models. |
| GPU textures, shaders, readback, captures, pipelines | `render` | Image owns CPU inputs/results; render owns execution and resource keys. |
| Province IDs, topology, spans, borders, polygons | `province` | Image-origin compatibility APIs forward only and must be deprecated/migrated. |
| Aseprite timing/tags and general playback | `animation` | Image may decode pixels, not animation policy. |
| Camera/audio/easing/procgen/UI/graph diagnostics | their owning modules or test evidence | They may output `ImageData`; image must not import their domain state. |
| Font layout/glyph ownership | `font` | Image may blit a supplied atlas, not own font shaping/cache policy. |

The current `src/image/visualization` tree violates this boundary by importing animation, audio, camera, procgen, UI, and other domains. The backward `province` re-export in `src/image/mod.rs` creates the detected upward dependency.

## Findings and work order

### P0 - Introduce one enforceable image budget

1. Add `src/image/limits.rs` with `ImageLimits` shared by all strict constructors/codecs/effects.
   - Bound width, height, total pixels, RGBA bytes, encoded input bytes, decoded output bytes, GIF frames and total frame pixels/bytes, layered-image layer count/name bytes/total decoded bytes, palette entries, atlas rectangles, kernel elements, effect-chain length, callback pixels, and output bytes.
   - Use checked `u64` multiplication/addition before `usize` conversion or allocation.
   - Define separate trusted-tool overrides only if required; Lua always uses safe defaults.
2. Make `ImageData::try_new_with_limits` the canonical constructor. `ImageData::new` currently panics on overflow and can still request an impractically large allocation when arithmetic fits.
   - Remove public panic semantics or deprecate the infallible constructor.
   - Use `Vec::try_reserve_exact` and return an allocation error rather than aborting on capacity failure.
3. Route blank images, resize/crop/rotate, layer creation/merge, shader readback, captures, debug images from other modules, sprite-sheet previews, and all decoded formats through the same output budget.
4. Add a work-budget helper for pixel loops: `pixels * passes/kernel_area/frames/layers/callbacks`. Reject before starting work; do not partially mutate on budget failure.

Acceptance: every public path checks dimensions, bytes, and multiplied work before allocation/iteration; allocation failure is an error, not a panic/abort.

### P0 - Secure codecs and serialization

1. Replace unrestricted `image::load_from_memory`/`open` conversion with a decoder path that reads dimensions first, checks limits, then decodes. Bound encoded input size and reject decompression bombs before RGBA allocation.
2. Harden animated GIF decode/encode.
   - Check canvas pixels before `ImageData::new`.
   - Cap frame count, total composited frame bytes, encoded output, duration metadata, and per-frame rectangles.
   - Avoid cloning a full canvas for unbounded frames. Keep required composited snapshots within the aggregate budget.
   - Validate frame rectangles with checked `left + width` / `top + height` and define disposal semantics explicitly.
3. Harden LIMG decompression.
   - `ZlibDecoder::read_to_end` currently expands without a ceiling and checks expected size afterward. Read through `take(expected + 1)` or stream into a pre-sized bounded buffer and reject excess immediately.
   - Validate dimensions and expected raw size before decompression.
   - Cap layer count, total layer bytes, name length/total name bytes, compressed chunk sizes, and aggregate output.
   - Reject duplicate/trailing/unknown records according to a versioned format policy.
4. Make all loads transactional and all in-memory effect chains prevalidated. A corrupt later layer/effect must not leave partially replaced live state.
5. Keep fuzz/no-panic tests, but add structured adversarial cases: tiny compressed/huge expanded payload, huge header dimensions, too many zero-size layers/frames, truncated lengths, integer wrap boundaries, invalid UTF-8, NaN opacity, and trailing bytes.
6. Resolve the inert compressed DDS surface.
   - `CompressedImageData::from_dds` always errors while a full userdata API is generated.
   - Either remove/deprecate unreachable constructors/types and retain only `isCompressed` diagnostics, or implement bounded DDS support in the asset/render pipeline. Do not leave a feature-shaped API that can never succeed.

### P0 - Filesystem and path policy

1. Route every Lua load/save through the repository's GameFS/filesystem policy.
   - `savePNG`, `saveGIF`, layered `save`, and serial helpers currently call `std::fs::write`/`create_dir_all` directly.
   - Resolve paths against the active game root, reject traversal/absolute escape according to filesystem rules, cap path length, and return method-qualified errors.
2. Separate byte encoding from file writing. Canonical image code returns bounded bytes; the filesystem owner authorizes and performs writes.
3. Make writes atomic: create a sibling temporary file under the approved destination, flush, then replace. A failed encode/write must not corrupt an existing asset.
4. Document whether save functions create parent directories and which extensions/formats are accepted. Validate mismatched extension/format deliberately.
5. Add security tests for `../`, absolute paths, device/reserved paths, long paths, symlink/junction escape where supported, read-only destinations, and oversized outputs.

### P0 - Arithmetic and callback correctness

1. Replace u32/i32 index arithmetic with checked/`usize`-based helpers after bounds validation.
   - `get_pixel`/`set_pixel` calculate `(y * width + x) * 4` in `u32`.
   - `draw_circle` calculates `radius * radius` before widening.
   - `draw_line` can overflow endpoint subtraction or take extreme proportional work.
   - Audit crop, paste/blit, convolution, resize, rotation, and visualization helpers similarly.
2. Validate all floats as finite before `clamp` or casts: brightness/contrast/saturation/gamma, layer opacity, transforms, kernel values/divisor/bias, shader uniforms, palette interpolation, and drawing coordinates.
3. Bound Lua pixel callbacks (`mapPixel`/`mapPixels`) and define reentrancy/error semantics.
   - Do not leave the image partially transformed if callback N fails.
   - Preferred implementation writes to a bounded scratch image then swaps on success.
   - Document callback count and disallow yield if mlua cannot safely support it.
4. Make multi-effect chains transactional. Parse and validate the entire chain, estimate output/work, apply to a copy or reversible pipeline, then commit.
5. Fix request semantics: `LImageShaderRequest:wait(timeout_ms)` currently ignores `_timeout_ms`. Implement a bounded render-owned wait/cancellation contract or rename/remove the misleading method.

### P0 - Remove dependency and namespace overlap

1. Remove `pub use crate::province::province_grid::*` from image core.
   - Keep `lurek.image.newProvinceGrid` only as a thin compatibility forwarder to `lurek.province` for one documented migration window.
   - Move the Lua province userdata/method ownership out of `image_api.rs`; ensure generated docs identify the canonical namespace and alias parity.
2. Dissolve `src/image/visualization` as a cross-domain dependency hub.
   - Generic image-only drawing primitives may remain under `image`.
   - Move camera/audio/animation/easing/procgen/UI/graph-specific render-to-image helpers to their owning module or `tests/lua/evidence` when they are diagnostic-only.
   - Do not create a new generic `visualization` engine module unless architecture review proves a stable cross-domain interface.
3. Consolidate rectangle packing.
   - `image::RectPacker` is also re-exported through `math`, while `sprite::TextureAtlas` implements a second shelf packer.
   - Keep one checked generic packer (prefer current image source if atlas preparation remains its contract), make sprite compose it for region metadata, and retain `lurek.math.newRectPacker` only as an explicit compatibility/public facade.
4. Clarify render bridges: image creates CPU buffers and render job requests/results; it must not own GPU shader validation, capture scheduling, or pipeline caches.

### P1 - Code quality and performance

1. Split `image_api.rs` by private concern: requests/captures, image data/effects, codecs/filesystem adapters, layers/GIF, palettes, and compatibility aliases. Registration remains flat.
2. Extract the large constructor/load/save/GIF closures reported by the audit into strict core/adaptor helpers.
3. Add zero-copy/borrowed internal operations where safe. Avoid full-buffer clones in `paste`, resize pipelines, GIF compositing, raw-byte exports, and shader readback; keep Lua string creation bounded.
4. Replace naive loops only after measurement. Blur already uses separable passes; add equivalent release baselines for convolution, resize filters, layers, diff, palette LUT, and text drawing.
5. Add deterministic parallelism policy. File docs claim large pixel mapping uses a parallel path; prove output order/equivalence and prevent Lua callbacks from entering worker threads.
6. Rewrite generic file docs, especially `compressed.rs` and cross-domain visualization files, to state concrete format/state/invariants. Add structured docs for all audit findings.

### P1 - Tests and proof

1. Expand `tests/rust/unit/image_tests.rs` for:
   - every `ImageLimits` dimension/byte/work ceiling and allocation error;
   - checked pixel/drawing arithmetic at integer extremes;
   - transactional callbacks/effect chains/layer loads;
   - PNG/GIF/LIMG bomb/truncation/version/trailing-byte cases;
   - GIF disposal/composition/duration/frame rectangle behavior;
   - layers with non-finite opacity, maximum count/names, merge ordering and alpha math;
   - atomic write and GameFS path resolution seams;
   - deterministic rectangle packing and compatibility alias parity;
   - shader request timeout/cancel/result lifecycle.
2. Add `tests/lua/security/test_image_security.lua`: huge dimensions/resizes/kernels/layers/frames, non-finite floats, malformed effect tables, callback failure/reentrancy, corrupt encoded strings, decompression bombs, path traversal/absolute paths, oversized raw strings, stale/cross-type userdata, and invalid shader targets.
3. Expand `tests/lua/stress/test_image_stress.lua` beyond three cases: bounded decode, multi-pass effects, resize filters, layer merge, GIF encode/decode, LIMG roundtrip, palette mapping, diff, callback overhead, packing, and capture/readback.
4. Move cross-domain visualizations to owner evidence files and keep image evidence focused on pixel-domain behavior. Golden comparisons must fail on unacceptable drift, not merely emit files.
5. Keep 121 exact unit owners after province migration by moving canonical markers to province and leaving only compatibility-alias tests under image for the deprecation window.

### P1 - Docs, API, specs, examples, and file docs

1. Add structured fields/variants for animated GIF, compressed format/data, filters/effect options, image/layer/palette/packer/texture types, requests, and limits.
2. Update `docs/specs/manual/image.md` with limits, decoder threat model, filesystem policy, transactional mutation, color-space/alpha assumptions, format support, and compatibility timelines.
3. Replace the current broad visualization claims. List only generic image-owned capabilities; link to owner modules/evidence for audio, camera, animation, procgen, UI, and province visuals.
4. Document raw vs premultiplied alpha, sRGB vs linear handling, resize boundary policy, kernel edge policy, layer order, and deterministic noise seed.
5. Review all 121 example owner blocks for meaningful bounded use. Teach byte-returning encode plus approved filesystem writes; do not teach direct host-path escape.
6. Regenerate specs/API docs after source and namespace changes; never edit generated outputs directly.

### P2 - Useful non-duplicating feature gaps

Implement only after security/ownership work:

1. Bounded streaming decode/encode APIs for large tool assets, using the same `ImageLimits` and GameFS policy.
2. Explicit color-space conversion and premultiplied-alpha operations owned by image, with render consuming tagged results.
3. Immutable image views/regions to reduce crop/blit copies without exposing mutable aliasing to Lua.
4. A versioned LIMG schema with optional metadata/checksum if it remains a supported durable format.
5. Multi-image atlas build output that composes the one canonical packer and returns pixels plus region metadata to `sprite`.

Reject: province topology, animation playback, camera/audio/UI domain visualization, runtime sprite state, shader compilation, or unrestricted host filesystem access.

## Performance plan

- Add release baselines for allocate/fill, crop/blit, resize filters, blur/sharpen/convolution, effect chains, palette LUT, layer merge, diff, PNG/GIF/LIMG encode/decode, packing, callbacks, and shader readback.
- Record dimensions, pixels, passes/kernel area, frames/layers, encoded/decoded bytes, allocations, peak temporary bytes, and elapsed time.
- Add bomb-resistance tests proving rejection occurs before output-sized allocation/work.
- Compare clone-heavy and transactional scratch strategies at realistic sizes; security/atomicity remains mandatory even if scratch work costs more.
- Add image-specific perf/stress scenarios; the global gate does not prove codec or pixel-loop behavior.

## CAG and contract updates to include with implementation

1. Update `review-all` minimally to require decoder/decompression budgets, direct-filesystem/path-policy review, compatibility-namespace ownership, finite pixel/effect values, and transactionality for callback/codec mutations.
2. Extend `review-performance` to require encoded-input/decoded-output/aggregate-frame/work-multiplier ceilings for codec modules.
3. Extend `review-tests` to require security suites for public parsers/codecs and to separate marker completeness from adversarial semantics.
4. Fix `tools/AGENTS.md` to use positional `audit_module.py image`, matching the parser.
5. Add a compact `src/image/AGENTS.md` (target 18-28 lines): CPU pixel ownership, `ImageLimits`, GameFS-only Lua paths, bounded codecs, transactional mutations, no upward feature imports, and security/stress gates.
6. Add reciprocal one-line rules to province/sprite/render/math only when compatibility/packer ownership changes. Do not copy this plan into root `AGENTS.md`.

## Implementation owners and sequence

1. `architect`: decide visualization/province migration, generic packer owner, filesystem boundary, and format support.
2. `developer`: limits, strict allocation/arithmetic, bounded codecs, transactional core, and dependency cleanup.
3. `lua_designer`: binding split, path adapters, compatibility aliases, callbacks/requests, and exact errors.
4. `tester`: adversarial Rust/Lua security, stress, integration/evidence/golden, and release baselines.
5. `content`: update image and migrated owner examples.
6. `doc_writer`: file docs, manual overlay, generated API/spec docs.
7. `cag_architect`: compact skill/contract updates.
8. `reviewer`: rerun dependency, security, quality, and performance audits.

## Verification

```powershell
tools\python.cmd tools\audit\audit_module.py image --docs-quality
tools\python.cmd tools\audit\thin_wrapper_audit.py --scope image --format text
tools\python.cmd tools\audit\docstring_audit.py --file src\lua_api\image_api.rs --check
tools\python.cmd tools\audit\example_coverage.py --module image --report --no-stubs --no-partials --lint
tools\python.cmd tools\audit\unit_test_api_coverage.py --module image --threshold 100
tools\python.cmd tools\audit\lua_spec_coverage.py --module image --threshold 100
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\stress\test_image_stress.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_nonunit_test_coverage.py --path tests\lua\security\test_image_security.lua --heuristic-body-check
tools\python.cmd tools\audit\lua_evidence_golden_contract_audit.py
cargo test --test image_tests
cargo test --test lua_tests
tools\python.cmd tools\audit\perf_regression_gate.py
cargo clippy -- -D warnings
tools\python.cmd tools\validate\cag_validate.py
tools\python.cmd tools\audit\cag_link_check.py --strict
```

## Done definition

- Every image allocation, decode, expansion, callback, layer/frame aggregate, and export is checked against one budget before work.
- Lua file access follows GameFS/filesystem policy and writes are atomic.
- Image no longer imports province or other feature domains; compatibility aliases are thin and time-bounded.
- Generic packing has one implementation, while sprite/render/province keep their own non-overlapping state.
- Rust, Lua unit, security, stress, integration, examples, specs, docstrings, file docs, golden evidence, and image-specific performance checks pass.
