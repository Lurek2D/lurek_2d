# Changelog

## Unreleased

 - perf(render): compute point-light 1-D shadow atlas rows on the GPU instead of raycasting every sample on the CPU.
 - perf(render): reuse PostFx ping-pong textures and internal bind groups across frames when dimensions and format are unchanged.
 - feat(render): add `lurek.render.drawBatch` as an explicit SpriteBatch alias for `lurek.render.draw(batch)`.
 - refactor(audio,dsp): extract logic-heavy Lua registration closures into private helpers and return boolean success values for DSP offline file operations.
 - fix(config): gate `lurek.dsp` registration with `modules.dsp` and keep `dsp` disabled when `audio` is disabled.
 - test(dsp): move Rust-only DSP internals into `tests/rust/unit/dsp_tests.rs` and register the `dsp_tests` Cargo target.
 - docs(audio,dsp): sync audio/DSP specs and add audit entry pages for `Audio-API` and `Dsp-API`.
 - fix(examples): keep `thread.lua` promise chaining bounded and use supported offline DSP effect types in `audio.lua`.
 - test(examples): allow `examples_load_test` to run a focused file subset with `LUREK_EXAMPLE_FILTER`.
 - content(examples): delete orphan `handles.lua`, `system.lua`, and `ecs_complete.lua`; remove cross-module duplicate ownership blocks from `ai.lua`, `effect.lua`, `math.lua`, `tilemap.lua`, and `ui.lua` so examples stay aligned to their owning modules.
 - fix(thread): replace `add_type_methods` on `LuaThreadHandle` with explicit `type`/`typeOf`/`__tostring` methods; correct `newThread` `@return` annotation from `LThreadHandle` to `LThread`; rename 4 `LThreadHandle:` stub markers in `content/examples/thread.lua` to `LThread:` and add `LThread:type`/`LThread:typeOf` stubs.
 - fix(examples): add `lurek.scene.depth` and `lurek.scene.update` coverage stubs to `content/examples/scene.lua`.
 - fix(settings): add `read_file` and `write_file` to `Lua.diagnostics.globals` in `.vscode/settings.json` to suppress false `undefined-global` warnings in test evidence files.
 - fix(test): `tests/lua/unit/test_event_core_unit.lua` — access `dialog.newSequencer` via `rawget` guard to suppress `undefined-field` LuaLS warning for optional API.
 - content(examples): remove same-file duplicate `--@api-stub:` markers from `math.lua`, `patterns.lua`, `pipeline.lua`, `scene.lua`, and `ui.lua`; fix `runtime.lua` header drift; rerun Lua API and example coverage refresh.
 - refactor(audio): extract `src/dsp/` module from `src/audio/` — effects, offline processing, and visualizer now in dedicated module with `lurek.dsp` Lua API.
 - refactor(audio): extract `src/midi/` module from `src/audio/` — MIDI player and SoundFont state now in dedicated module with `lurek.midi` Lua API.
 - feat(dsp): add `src/lua_api/dsp_api.rs` providing `lurek.dsp` namespace (newEffectParams, processOffline, normalize, waveformToPng, spectrogramToPng).
 - feat(midi): add `src/lua_api/midi_api.rs` providing `lurek.midi` namespace (newPlayer, loadSoundFont, hasSoundFont, clearSoundFont).
 - docs(specs): add `docs/specs/dsp.md` and `docs/specs/midi.md`.
 - test(dsp): add `tests/lua/unit/test_dsp_core_unit.lua`.
 - test(midi): add `tests/lua/unit/test_midi_core_unit.lua`.
 - feat(visibility): add `src/visibility/` module — universal fog-of-war system with per-player states, alliance groups, flags, costs, and events.
 - docs(api): extend Lua API doc coverage from 91.3% to 100% — add 14 missing `///` doc comments in `globe_api.rs`, `grep_api.rs`, `layout_api.rs`, `math_api.rs`, `validator_api.rs`, `visibility_api.rs`.
 - docs(rust): extend 148 short Rust `///` summaries to meet 25 visible-char minimum across `src/charts/`, `src/color/`, `src/cursor/`, `src/dialog/`, `src/font/`, `src/globe/`, `src/grep/`, `src/layout/`, `src/mapblock/`, `src/mods/`, `src/physics/`, `src/province/`, `src/raycaster/`, `src/render/`, `src/validator/`, `src/visibility/`.
 - test(validator): add `LValidationEngine:run` and `LMapBlockConfig:removeSlot` Lua test cases; remove orphaned `@covers` markers in `tests/lua/unit/`.
 - docs(specs): update `docs/specs/globe.md` — add `lurek.globe.MAX_REGIONS` and `lurek.globe.MAX_PROVINCES` module constants to Lua API Reference.
 - feat(visibility): add `lurek.visibility` Lua API with VisibilityGrid userdata.
 - docs(specs): add `docs/specs/visibility.md`.
 - test(visibility): add `tests/lua/unit/test_visibility_core_unit.lua` (13 tests).
 - refactor(effect): extract weather, atmosphere, screen effects, and transitions into `src/overlay/` module.
 - feat(overlay): add `lurek.overlay` Lua API with Overlay controller and ScreenTransition userdata.
 - docs(specs): add `docs/specs/overlay.md`.
 - test(overlay): add `tests/lua/unit/test_overlay_core_unit.lua` (14 tests).
 - refactor(ai): extract dialog/conversation system into `src/dialog/` module; `src/ai/dialogue.rs` deleted.
 - feat(dialog): add `src/dialog/` module — dialog tree, conditions, state machine, speaker registry, events.
 - feat(dialog): add `lurek.dialog` Lua API (newAI, newState, newSpeakerRegistry).
 - docs(specs): add `docs/specs/dialog.md`.
 - test(dialog): add `tests/lua/unit/test_dialog_core_unit.lua` (17 tests).
 - feat(layout): add `src/layout/` module (Foundations tier) — Reingold-Tilford tree, Sugiyama DAG, Fruchterman-Reingold force-directed, grid snap.
 - feat(layout): add `lurek.layout` Lua API (tree, dag, force, snapToGrid, centerInArea).
 - docs(specs): add `docs/specs/layout.md`.
 - test(layout): add `tests/lua/unit/test_layout_core_unit.lua` (8 tests).
 - feat(province): add generic ProvinceProperties system (setProperty, getProperty, setAttr, getAttr, setFlag, hasFlag, clearProperties).
 - refactor(province): remove hardcoded economy.rs from engine; economy logic moved to `library/province_economy/`.
 - feat(library): add `library/province_economy/` — pure-Lua province economic simulation using generic properties.
 - refactor(procgen): consolidate all noise generation into `src/procgen/noise.rs`; remove duplicate `src/math/noise_generator.rs` and `src/math/noise_functions.rs`.
 - refactor(procgen): move `LuaNoiseGenerator` from `math_api.rs` to `procgen_api.rs`; Lua API now `lurek.procgen.newNoiseGenerator()`.
 - refactor(math): remove noise from math module — noise is generation, not processing.
 - refactor(easing): make `math/easing.rs` the single source of truth for easing curves; camera and scene modules now delegate.
 - refactor(scene): delete `src/scene/easing.rs` (bounce_out now in math/easing.rs).
 - refactor(tween): move `src/math/tween.rs` to `src/tween/interpolator.rs`; Tween/TweenValue now in tween module.
 - refactor(ai): unify Blackboard — `patterns/blackboard.rs` is canonical (parent chain + revision tracking); `ai/blackboard.rs` re-exports.
 - test(province): add `tests/lua/unit/test_province_properties_unit.lua` (10 tests).
 - test(procgen): add `tests/lua/unit/test_procgen_noise_unit.lua` (12 tests).
 - docs(quality): comprehensive quality sweep — expanded 422 short Lua API `///` docstrings to ≥30 visible characters (whitespace-stripped threshold); added struct-level `///` class descriptions for `LuaCursorManager`, `LuaCustomCursor`, `LuaAnimatedCursor`, `LuaGrepEngine`, `LuaFileFilter`, `LuaValidationEngine`.
 - docs(quality): added 183→14 missing Rust `///` docstrings across cursor, ecs, flownet, globe, grep, mods, province, raycaster, validator, visibility modules (14 missing, below ≤20 threshold).
 - docs(quality): created `logs/docs_overlay.json` (24 entries) providing function descriptions for cursor/font/grep/validator APIs that are unreachable by the doc scanner due to `{` block structure; extended `_apply_overlay` in `tools/docs/gen_lua_api_data.py` to also set `return_description` and `typed_params` from overlay.
 - fix(tools): `tools/docs/gen_lib_docs.py` — library stub generator now always uses `library.{module}` prefix for function declarations (fixing `province_economy` stubs that were missing the prefix); normalises hyphens to underscores in module names (fixing `scene-objects`).
 - fix(tools): `tools/validate/validate_generated_lua_stubs.py` — `_extract_library_expectations` now uses canonical `library.{normalised_name}` prefix matching `render_luacats` output.
 - fix(tools): `tools/audit/example_coverage.py` — duplicate `--@api-stub:` markers (when a class is registered in two Rust API files) now produce a WARN instead of a hard exit-1.
 - fix(tools): `tools/validate/validate_module_coverage.py` — added `SPEC_ALLOWLIST = {"vscode-extension"}` to skip false positive.
 - fix(tools): `tools/docs/gen_lib_docs.py` — encoding fix (`errors="replace"`) for non-ASCII bytes in library files.
 - test(lua): added 27 missing Lua API test files across ai, layout, camera, charts, color, cursor, font, glob, mapblock, overlay, parallax, procgen, spine, tilemap, timer modules.
 - fix(api): `src/lua_api/effect_api.rs` — expanded 9 `LPostFxEffect` setter docstrings to ≥30 visible characters.
 - fix(examples): added `--@api-stub:` coverage stubs to `content/examples/mapblock.lua` (14 stubs for LMapBlock/LMapGroup/LMapScript) and `content/examples/ui.lua` (3 stubs for LBarChart/LLineChart/LScatterPlot addSeries).
 - test(learning): add `tests/lua/stress/test_learning_stress.lua` (5 stress tests).
 - test(province): add `tests/lua/integration/test_province_integration.lua` (4 integration tests).
 - feat(learning): extract `src/learning/` module from `src/ai/` — neural_net, neuroevolution, genetic, qlearner, bandit now live in dedicated module with `lurek.learning` Lua API.
 - feat(learning): add `src/lua_api/learning_api.rs` providing `lurek.learning` namespace (newQLearner, newNeuralNet, newGeneticAlgorithm, newBandit, newNeuroevolution).
 - refactor(ai): re-export learning types from `crate::ai` for backward compatibility; `lurek.ai.newNeuralNet` etc. continue to work.
 - docs(specs): add `docs/specs/learning.md` module spec; update `docs/specs/ai.md` with cross-reference.
 - test(learning): add `tests/lua/unit/test_learning_core_unit.lua` with 10 constructor tests.

 - feat(extension): add 4 new MCP tools — `getModuleInfo`, `inspectLuaFile`, `getTestCoverage`, `getProjectStructure` in `extensions/vscode/src/mcp/tools.ts`.
 - feat(extension): add `checkMissingLoadCallback` diagnostic rule — warns when main.lua uses lurek.* without lurek.load().
 - feat(extension): enhance `checkPerFrameAllocation` and `checkEntityNilAccess` diagnostic patterns.
 - test(extension): add unit tests for diagnostics, completion, hover, apiData, and MCP tools (5 new test files, 60+ test cases).
 - docs(specs): add `docs/specs/vscode-extension.md` — module spec for the VS Code extension (Edge/Integration tier).
 - docs(wiki): add `docs/wiki/extension-features.md` — comprehensive feature reference for the extension.
 - docs(extension): add Lurek API Surface sections to 6 game-dev CAG agents.

 - feat(library): add `library/input_action_map` — action mapping with multi-key binding, pressed/held/released queries, and axis helpers.
 - feat(library): add `library/audio_manager` — high-level audio manager with music crossfade, SFX pooling, volume groups, and mute/pause control.
 - feat(library): add `library/camera_follow` — configurable camera follow with smoothing, deadzone, lookahead, bounds clamping, shake, and cutscene override.
 - feat(library): add `library/tween_chain` — chainable tween sequences with parallel groups, easing functions, looping, and progress tracking.

 - refactor(graph): rename `src/graph/` to `src/flownet/`; Lua namespace `lurek.graph` → `lurek.flownet` (backward-compat alias preserved).
 - refactor(data): rename `src/data/` to `src/binary/`; Lua namespace `lurek.data` → `lurek.binary` (backward-compat alias preserved).
 - refactor(serial): rename `src/serial/` to `src/serialize/`; Lua namespace `lurek.serial` → `lurek.serialize` (backward-compat alias preserved).
 - refactor(math): move `sphere.rs` from `src/math/` to `src/globe/` (closer to its consumers).

 - fix(test): `tests/lua/unit/test_dsp_core_unit.lua` — use `expect_near` for `p.p2 ≈ 0.7` (f32 round-trip gives `0.69999998807907`).
 - fix(test): `tests/lua/unit/test_ui_core_unit.lua` — allow ≤5 pixels in right-margin check for cartesian legend (line endpoint sub-pixel bleed); fix chart data types: series values must be numbers not strings.
 - fix(test): `tests/lua/integration/test_tilemap_physics.lua` — align dynamic ball spawn at x=16 (directly over tile 1 centre) to avoid falling through 16 px gaps between adjacent default-sized static bodies.
 - fix(ui): `src/ui/containers.rs` — layout container `align` default `"center"` → `"stretch"`, `justify` default `"center"` → `"start"` (CSS flexbox defaults).
 - fix(api): `src/lua_api/thread_api.rs` — `newThread` `@return` type corrected from `LThread` to `LThreadHandle` (matches generated docs class name from struct `LuaThreadHandle`).
 - docs(examples): `content/examples/dsp.lua` — add 11 missing `--@api-stub:` markers (`addEffectToBus`, `removeEffectFromBus`, `setEffectParam`, `analyzeFft`, `analyzePeak`, `analyzeRms`, `applyBandpass`, `applyGain`, `applyHighpass`, `applyLowpass`, `newSynthWave` added to audio.lua).
 - docs(examples): `content/examples/thread.lua` — add 4 missing `--@api-stub:` markers (`LThreadHandle:start/wait/isRunning/getError`).
 - docs(examples): `content/examples/learning.lua` — add `LQLearner:getEpisodeCount` stub.
 - test(lua): all 248 Lua tests pass (0 failures); all 1534 Rust unit tests pass.
 - quality: clippy clean (0 errors, 0 warnings); debug and release builds pass; example coverage 5178/5178 (100%); CAG validate 0 errors.
 - refactor(math): move `rect_packing.rs` from `src/math/` to `src/image/` (texture atlas context).
 - refactor(image): move `province_grid.rs` from `src/image/` to `src/province/` (domain context).
 - refactor(math): rename Lua function `lurek.math.voronoi` to `lurek.math.geometricVoronoi` (disambiguate from `lurek.procgen.voronoi`; old name preserved as alias).

 - refactor(province): replace hardcoded `BorderClass` enum with generic `BorderType` (u8); border types now registered from Lua via `lurek.province.registerBorderType`.
 - refactor(province): replace hardcoded `ProvinceMapMode` enum with generic config-driven `MapModeConfig`; modes registered from Lua via `lurek.province.registerMapMode`/`setMapMode`.
 - refactor(globe): rename internal Province→Region, ProvinceGraph→RegionGraph to decouple globe from province semantics (backward-compat aliases preserved).

 - refactor(province,globe,physics,flownet,ecs): convert raw ID type aliases to newtype structs (ProvinceId, RegionId, BodyId, NodeId, EdgeId, ItemId, EntityId) for type safety.
 - fix(flownet): add `add_edge_unchecked` for hot-path batch graph construction (skip endpoint validation).
 - fix(physics): `Body::new` now requires explicit (x, y, w, h) dimensions; removed magic 32×32 default.
 - fix(tween): log warning on unknown easing function name before falling back to linear.
 - feat(dataframe): add parallel `parFilter` and `parGroupAgg` methods (rayon, auto-threshold at 10k rows).
 - feat(flownet): add batch Lua API — `batchAddNodes`, `batchAddEdges`, `batchStep` for efficient bulk network construction.
 - chore(render): feature-gate `obj-loader` module (default: enabled); add docs clarifying 2D projection purpose.
 - docs(devtools,debugbridge): add scope-boundary sections clarifying local vs remote ownership.

 - feat(library): add `library/particle_presets` — 12 pre-configured particle presets (fire, smoke, explosion, etc.) with override and custom registration.
 - feat(library): add `library/window_config` — fluent window configuration builder with presets, serialization, and scaling mode helpers.
 - feat(library): upgrade `library/sprite` — add `init.lua` with `AnimController` state machine re-exporting existing `SpriteAnimator`.
 - test(library): add test files for all 7 new/upgraded library modules; register in `harness.rs`.
 - test(font): add `lurek.font.loadBitmap` coverage tests (4 assertions) to `test_font_core_unit.lua`.
 - test(physics): add 8 describe-based coverage blocks to `test_physics_core_unit.lua`.
 - test(dataframe): add 8 describe-based coverage blocks to `test_dataframe_core_unit.lua`.
 - test(graph): add 8 describe-based coverage blocks to `test_graph_core_unit.lua`.
 - refactor(lua_api): make `patterns_api` always-on (remove incorrect `pipeline` gate; Foundations tier must not depend on Feature tier gate).
 - refactor(lua_api): gate `province_api` by dedicated `modules.province` (was incorrectly gated by `modules.image`).
 - refactor(config): remove vestigial `data` field from `ModulesConfig` (module is always-on, field was never checked).
 - refactor(config): add `province: bool` field to `ModulesConfig` (default: true).
 - docs(specs): add Registration sections to `data.md`, `dataframe.md`, `patterns.md`, `province.md`.
 - docs(specs): add Architecture Boundary sections to `raycaster.md`, `minimap.md`, `graph.md`, `image.md`.

 - refactor(minimap): migrate `minimap_overlay.rs` from `src/raycaster/` to `src/minimap/raycaster_overlay.rs`; raycaster re-exports symbols for backward compatibility; update specs and imports.

 - refactor(lua_api): introduce `LuaModule` trait and `ModuleEntry` registry in `src/lua_api/lua_module.rs`; refactor `register.rs` to use static `MODULES` slice with `always!`/`gated!` macros instead of 50+ explicit function calls.
 - docs(architecture): add `docs/architecture/lua-rust-boundary.md` — Lua-Rust boundary architecture covering module registration, state management, handle pattern, security sandbox, and testing strategy.
 - test(lua_api): add `tests/lua/unit/test_lua_module_registration.lua` — unit tests for always-on modules, config-gated modules, namespace types, and security sandbox.
 - feat(examples): add `content/examples/handles.lua` — demonstrates handle-based resource management pattern across sprite, physics, and camera modules.
 - docs(specs): update `docs/specs/lua_api.md` with Module Registration Architecture subsection.

 - feat(color): add standalone `src/color/` module (Foundations tier) with `lurek.color.*` Lua API — Color struct, named constants, HSL/HSV/hex conversions, blending modes (lerp, multiply, screen, overlay, additive, alpha), CSS named palettes, retro palettes (PICO-8, Game Boy, NES), and gamma/linear transforms.
 - feat(font): add standalone `src/font/` module (Platform Services tier) with `lurek.font.*` Lua API — bitmap font atlas, glyph metrics, text measurement, word/character wrapping, text shaping with alignment, and font registry with named handles.
 - feat(charts): add standalone `src/charts/` module (Feature Systems tier) with `lurek.charts.*` Lua API — five software-rasterized chart types (line, bar, scatter, pie, area) rendering to RGBA8 pixel buffers; configurable colors, margins, grid, legends; default 8-color palette.
 - docs(specs): add `docs/specs/color.md`, `docs/specs/font.md`, `docs/specs/charts.md`; update README.md index (51 → 54 modules).
 - test(color): add `tests/lua/unit/test_color_core_unit.lua` — 12 describe blocks covering constants, constructors, conversions, blending, utilities, palettes.
 - test(font): add `tests/lua/unit/test_font_core_unit.lua` — 11 describe blocks covering constants, loading, measurement, wrapping, shaping, font methods.
 - test(charts): add `tests/lua/unit/test_charts_core_unit.lua` — 9 describe blocks covering constructors, palette, and all chart type methods.
 - refactor(color): delete `src/math/color.rs`; all 15 import sites migrated to `crate::color::Color`. Remove color functions from `lurek.math` API (hslToRgb, colorFromHex, colorToHsl, gammaToLinear, linearToGamma) — now in `lurek.color`.
 - refactor(charts): delete `src/ui/chart.rs` and `src/ui/data_graph_renderer.rs`; all 20 `crate::ui::chart::*` paths in ui_api.rs migrated to `crate::charts::*`. Remove chart/graph types from `src/ui/mod.rs`.
 - refactor(font): `src/font/` module owns CPU-side data layer; `src/render/font.rs` retains GPU font rendering and re-exports shared types from `crate::font`.
 - docs(specs): update `math.md` (remove color), `ui.md` (remove charts), `font.md` (clarify architecture).

 - feat(animation): add `LAnimation:setImage(image)` and `LAnimStateMachine:setImage(image)`; make `:draw` polymorphic — `draw(x, y, opts?)` works when an image is pre-stored via `setImage`, `draw(image, x, y, opts?)` remains backward-compatible; raises a clear error when draw is called without a stored image; docs, examples, and tests updated.
 - feat(library): add `library/scene-objects` module — runtime-agnostic game-object container with `add`, `remove`, `clear`, `update` (insertion-order), `draw` (layer-sorted), `count`, `has`, `getByLayer`; 22 unit tests in `tests/lua/library/test_library_scene_objects.lua`; harness registration and library docs generated.
 - feat(examples): add `content/examples/ecs_complete.lua` — full end-to-end headless ECS simulation covering `defineBlueprint`, `extendBlueprint`, `spawnBlueprint`, `addTag`, `addSystem`, `update`, `query`, `kill` across 10 simulation ticks.
 - docs(filesystem): add Core Function Reference subsection with full signatures, param tables, return types, and examples for `read`, `write`, `exists`, `getDirectoryItems`, `mkdir`, and `remove`
 - docs(render): add LShader detail entries for `send(name, value)` and `hasUniform(name)` with param tables, type matrix, and usage example
 - docs(math): add Vec2 and Vec3 Construction and Usage subsection covering constructors, field access, method signature tables for all `LVec2` and `LVec3` methods, and example snippets

 - feat(ui): add two-phase layout pass with minimum-size negotiation for auto-sizing widgets
 - feat(ui): add spatial focus navigation for gamepad/keyboard directional input
 - feat(ui): add visible-range virtualization for ListBox and GUITable performance
 - feat(ui): add resolution-independent scaling with base_resolution and scale_factor
 - feat(ui): add scissor stack for proper nested scroll panel clipping
 - feat(ui): add EasingFunction enum (10 curves) and Scale/Rotation/Color tween types
 - feat(ui): expose focusDirection, updateResolution, setBaseResolution, getScaleFactor, visibleRange, animateScale, animateRotation, animateColor Lua API

 - docs(architecture): added an advanced feature surface classification note that keeps AI, compute, dataframe/SQL, globe, province, raycaster, UI, and HTML as intentional current surfaces while defining future gates for optionalization, extraction, or documentation de-emphasis.

 - feat(animation): added `LAnimation:draw(image, x?, y?, opts?)` and `LAnimStateMachine:draw(image, x?, y?, opts?)` helpers that queue the current frame as an atlas draw command without advancing playback, including Lua coverage for active frames, inactive frames, stale images, non-image arguments, and invalid option tables.

 - fix(app): `ErrorScreen::from_error` now uses first non-empty line as title, avoiding blank titles when error text starts with blank lines.

 - feat(vscode): upgraded all 41 visual editor panels from guide-backed metadata to shared interactive webview editors with typed feature actions, clickable feature cards, workspace-specific state mutations for grids, graphs, tables, timelines, previews, and documents, live inspector/log/export previews, per-editor behavior profiles, and generated exports that include feature actions, action history, and serialized editor state.

 - fix(data): `DataWriter` append-at-end writes now use `extend_from_slice` without zero-fill overwrite (seek past end still zero-fills gaps); `get_packed_size` correctly counts mixed format values in token order.
 - fix(dataframe): `rolling_mean` and `rolling_sum` now use O(N) sliding-window algorithms with numeric-count tracking; both operations ignore nil cells and return Nil when the current window has no numeric cells.
 - fix(runtime): `ErrorSnapshot::to_json` now uses serde_json serialization with correct control character escaping; recovery hint field serialized as `hint`.

 - feat(vscode): rebuilt the visual editor panel system from scratch around concrete active `extensions/vscode/src/editors/*Editor.ts` local specs plus a shared webview platform with 41 sidebar-launched panels; each concrete editor file now owns its guide-derived reference, use case, vision, eight feature bullets, toolbar, tools, inspector, bottom panel, and export settings while `catalog.ts` only aggregates local `*EditorSpec` constants; added the missing NavMesh, Skeleton Rigging, Visual Shader, Lighting Environment, GUI Theme, Network Topology, Global Autoload, Asset Manifest, Performance Profiler, and Project Export panels, synchronized command registration/sidebar/package manifest wiring, and added local-spec/manifest/sidebar/webview security tests plus updated extension panel documentation.


 - feat(vscode): standardized UX across all webview editors by upgrading shared editor shell styles (`extensions/vscode/src/editors/shared.ts`) with keyboard-focus visibility, responsive toolbar/status behavior, and consistent help styling; added global shortcut-help modal (`?`, `Shift+/`, `F1`) with automatic shortcut discovery from registered handlers and toolbar titles, injected a common help button in every editor toolbar, added a cross-editor Action Palette (`Ctrl+K`, `Ctrl+.`) that discovers runnable toolbar/tool/panel actions, improved keyboard routing to avoid triggering editor shortcuts while typing in form fields, normalized key parsing (`Space`, arrows, `Esc`), enabled automatic dirty-state marking for form edits (`input`/`select`/`textarea`), and added accessible icon buttons (`type="button"`, `aria-label`) for better screen-reader support and safer interactions; stage 3 panel upgrades added brush-size workflows and zoom/status telemetry in pixel/tile editors, quick tile/layer keyboard navigation in Tile Map, and Tileset slicing presets with arrow-key tile traversal plus editable auto-rule target tiles; stage 4 upgrades added node-focused graph workflows across Graph/Scene/Dialog/Quest editors (`Ctrl+D` duplicate, arrow-key nudging, selected-node status) and timeline productivity controls (fixed toolbar icon wiring, keyframe navigation with `J/L`, time stepping with `,/.`, and `K/Delete` keyframe edit shortcuts); plus global voxel-style visual pass with a high-contrast top configuration bar and automatic left action-rail fallback so every editor panel conforms to the same top-config + left-tools layout target; implemented Globe Editor as a unified geoscape workspace with in-panel 3D globe rendering and flat 2D map editing modes, shared tactical tool palette, layer list management, and Lua setup export.


 - fix(vscode): unified snippets into one standard VS Code experience by routing `lurek.library.insertSnippet` to the built-in `editor.action.insertSnippet` picker and removing the extension-only custom snippet quick-pick flow; also updated `extensions/vscode` build/watch scripts to always regenerate `data/snippets.json` from `content/snippets/*.lua` so extension snippets stay in sync with the single source of truth.


 - feat(snippets): replaced mass-generated snippet source with handcrafted starter snippets for early workflows (`engine`/runtime, `input`, `render`, `ui`, `math`, `data`) under `content/snippets/`, each with explicit usage rationale and multi-API composition; retained deterministic VS Code JSON generation (`tools/snippets/gen_vscode_snippets.py` → `extensions/vscode/data/snippets.json`), marker validation (`tools/validate/validate_snippets.py`), and module-level snippet coverage reporting (`tools/audit/snippet_coverage.py` → `logs/reports/snippet_coverage.md`), updated snippet tasks in `.vscode/tasks.json`, and synced prompt/docs guidance.


 - feat(province): added `src/province/economy.rs` with a local-only province economy model (`population`/`food_stockpile`/`gold_stockpile`), monthly economy resolution helpers (food need, tax, growth, migration pressure), and daily physical shipment flow (upstream gold/downstream food) with in-transit delivery and origin-cargo launch validation; added focused coverage in `tests/rust/unit/province_economy_tests.rs`.


 - feat(province): added per-pair border style overrides (`setBorderPairStyle`/`getBorderPairStyle`) with optional color, thickness, and semantic flags; extended province render options with strategic/tactical zoom mode controls and tactical road rendering between visible adjacent capitals.
 - feat(province): added province precompute modules `distance_field` (BFS distance-to-border map) and `border_index` (stable u16 border-pair index with optional thickness dilation), with rust unit coverage for border/inner distance and pair-id expansion behavior.
 - feat(province): added `gpu_upload` helpers for province map texture creation and upload (`R32Uint` id map, `R16Uint` border index, `R8Unorm` distance field), including tested little-endian packers for integer texture payloads.
 - feat(province): extended `gpu_bridge` with border-style storage-buffer records aligned to border-index pair ids, so per-pair style flags/thickness/color can be uploaded directly for province shader passes.
 - feat(render): added `province_map_pipeline` + `assets/shaders/province_map.wgsl` scaffold for fullscreen province shader rendering with bind groups for id/border-distance textures and storage buffers, plus uniform mapping for viewport and strategic/tactical mode.

 - feat(province): completed visibility-driven province rendering contract: `visibility_state=0` now skips fill/border/capital/label, `visibility_state=1` renders gray discovered fill only, and borders render only when both adjacent provinces are fully visible (`>=2`).

 - fix(quality): removed redundant duplicate `typeOf` comparisons across Lua API userdata bindings and replaced one manual increment pattern with `+=` so `cargo clippy -- -D warnings` passes cleanly.

 - feat(runtime): upgraded built-in CLI mode with true runtime hard reset (`:reset` now routes to `lurek.event.restart()` and app loop VM rebuild), multiline command continuation with readable continuation prompt, and automatic startup load of explicit `game_dir/main.lua` via REPL `:load` (including surfaced load errors in terminal output).

 - fix(quality): closed Lua/docs/example coverage gaps by documenting missing Rust functions (`translate_gender`, `translate_plural`, `get_processor_count`), adding UI example coverage for `lurek.ui.loadLayoutGameFile`, covering remaining UI unit-test APIs (`focusNeighbor`, `getStyleToken`, `loadLayoutGameFile`, and `LUiWidget` text/focus/accessibility setters), and tightening `lurek.ui.getStyleToken` docs from `@return any` to typed overloads.

 - fix(lua): dropped `RefCell` callback-store borrows before invoking Lua in `LDepthSorter:flush`, `LSignal:emit`, and `lurek.timer.tickRealTimers`, preventing `L060` panics when callbacks mutate the same dispatcher during execution.

 - fix(vscode): Explorer `Run Game` now always launches repo-local Lurek through the workspace Cargo pipeline in Cargo workspaces, and no longer honors installed/system `lurek` paths there. Non-Cargo workspaces still use explicit `lurek.lurekPath` or `lurek.enginePath`.

 - fix(games): improved readability in `apps/household_finance_lab` by switching to native non-scaled UI font defaults (`app/config.toml`: `font_size=20`, `title_font_size=24`; `conf.toml`: `default_font_size=20`, `default_font_bold=true`), wiring renderer font setup to config values instead of hardcoded 10px, removing custom widget style-class overrides, keeping `Widgets/API` native-only, and moving chart placement to TOML-defined slot widgets (`getRect()`-driven render anchors).
 - fix(vscode): `Run Game` now disables PATH binary fallback and resolves the workspace root from the selected game path before launch, so menu runs use workspace-local engine binaries (`build/`/`target/`) or local cargo run path in Cargo workspaces.

 - refactor(games): removed dynamic widget dispatch fallback from `apps/household_finance_lab/app/ui_controls_toml.lua` (`try_widget_method`, `widget[method_name]`, and `lurek.ui["..."]` access) and switched to explicit `L*` widget methods so Lua IntelliSense resolves calls directly from generated API stubs.
 - refactor(games): tightened `apps/household_finance_lab` error handling by removing non-essential `pcall` wrappers around stable UI/window setup paths (`windowConfig`, `setActiveTab`, layout load via `loadLayoutGameFile`, render/ui font setup), leaving `pcall` only on true boundary operations (save restore, optional telemetry, file/JSON cache restore).

 - fix(scene): prevented `lurek.scene` lifecycle callback panics caused by calling Lua while `SceneState` `RefCell` borrows were still active; scene callback dispatch now gathers tables/ids first, drops borrow scopes, then invokes Lua (`push/pop/switchTo/popTo/update/process/processPhysics/processLate/draw/render/renderUi/pushOverlay/pushPreloaded`). This removes `RefCell already borrowed` crashes that surfaced as `L060` with "panic in a function that cannot unwind".

 - fix(games): hardened `apps/household_finance_lab` layout boot by guarding missing UI APIs on older runtimes (`lurek.ui.clear`, TabBar methods), pinned all app fonts to default size 10, disabled per-frame render scaling for this app, locked its window size to 1200x800, added app-level `conf.toml` render defaults (`default_font_size = 10`, `default_font_bold = false`), and aligned the app pipeline with built-in dataframe APIs.
 - fix(vscode): changed `Run Game` binary resolution so Cargo workspaces use only workspace-local engine outputs (`build/`/`target/`) or local `cargo run`; PATH-installed binaries are no longer used for repo runs.
 - refactor(games): reduced custom Lua in `apps/household_finance_lab` by moving all refresh-time SQL into external `sql/*.sql` query files and using built-in `LDatabase:queryParams`/`LDatabase:save` directly (removed inline SQL string building and compatibility query fallback logic).

 - feat(ui): added `lurek.ui.loadLayoutGameFile(path)` for GameFS-resolved TOML UI loading, and updated `LUiWidget:findById` to return typed widget handles with widget-specific Lua methods (for event binding and value updates after TOML layout load).
 - refactor(games): migrated `apps/household_finance_lab` control shell from manual Lua widget construction to runtime TOML layout loading (`layouts/household_finance_lab_ui.toml`) with ID-based event/data binding.
 - feat(games): added engine-driven TOML layout renderer game at `content/games/tools/layout_toml_renderer` and removed the legacy Python preview renderer (`tools/ui/render_layout.py`), so layout PNG generation now runs through the Lurek2D runtime.

- feat(ui): added `lurek.ui.clear()` to reset retained UI state between layout loads while preserving the active theme, switched TOML layout screenshots to the engine's real `GuiContext::draw_to_image()` path instead of debug rectangles, and rewired GUI evidence rendering to sweep actual `content/layouts/*.toml` files through `loadLayoutFile` + `renderToImage`.

- feat(ui): added focus metadata and grouped traversal controls: `WidgetBase` now stores `focusable`, `tab_index`, `focus_group`, directional focus neighbors, and role/name accessibility metadata; Lua widget bindings gained `setFocusable`, `setTabIndex`, `setFocusGroup`, `setFocusNeighbor`, `setRole`, `setAriaName`; global `lurek.ui.focusNeighbor(direction)` now follows explicit directional links.
- refactor(ui): introduced fine-grained dirty flags in `GuiContext` (`layout_dirty`, `style_dirty`, `text_dirty`, `render_dirty`) and wired key mutators (`add_child`, `remove_child`, `set_default_theme`, `set_viewport`) plus `flush_cache()` reset semantics to support cheaper targeted invalidation.

- feat(ui): style tokens and extended widget state variants (Selected, Checked, Invalid, ReadOnly, Active, Expanded): added `ThemeToken` enum (`Color`/`Float`), `tokens` map on `Theme`, `Theme::get_token`, 9 default tokens in `default_dark()`, and `lurek.ui.getStyleToken(name)` Lua binding; added 6 new `WidgetState` variants with `parse_str`/`as_str` round-trip support.

- feat(ui): complete mouse filter Stop/Pass/Ignore routing and skip disabled/hidden widgets in hit-test: `hit_test` now returns only `MouseFilter::Stop` widgets as event targets, skipping `Pass` and `Ignore`; hidden (`!is_visible`) and disabled widgets are explicitly excluded; `mouse_moved` no longer sets hover state on `Ignore` widgets; `mouse_released` defensively clears any non-Stop widget that reaches `Pressed` state; updated `docs/specs/ui.md` with the full event routing contract.
- feat(ui): text/label pipeline — wrap, clip, ellipsis, vertical alignment: added `TextVAlign` enum, `text_wrap`/`text_ellipsis`/`text_v_align` fields to `WidgetBase`, `layout_text` helper in `render.rs`, scissor clipping around all text emits, and `setTextWrap`/`setTextEllipsis`/`setTextVAlign` Lua methods on `LUiWidget`.
- feat(ui): render widgets using `computed_rect` absolute screen coordinates and sort children by `z_order` ascending so render position and hit-test region are always consistent. **BREAKING:** child widgets must use container-relative coordinates, not absolute screen offsets.
- chore(ui): fix spec Files section, float assertions, and audit test naming
- fix(ui): clamped Cartesian chart X-axis tick labels to the available plot width and spaced the `apps/household_finance_lab` retained top controls/status bar to remove visual overlap in 800x600 screenshots.
- fix(vscode): fixed Windows run commands in the VS Code extension by making Explorer `Play Game` honor `lurek.lurekPath`, launching installed binaries directly instead of sending quoted exe paths through PowerShell, and invoking `Run: Debug/Release (no rebuild)` with the PowerShell call operator.
- fix(ui): returned status values from `LTheme:setStyle` and retained UI data-binding updates, and added the `LUiWidget:setBindKey` plus `lurek.ui.updateBindings` compatibility bindings.
- fix(ui): made retained UI widget setters return stable booleans, normalized missing style classes to `""`, accepted both `renderToImage` argument orders, defaulted layouts to stretch alignment, and enforced text-input max length on direct `setText`.
- fix(image): expanded `ImageData::draw_label` from a tiny 3x5 glyph set to a readable 5x7 ASCII UI font with common punctuation, improving `lurek.ui.drawToImage` labels, buttons, tables, and chart text.
- feat(render): changed the engine startup render font default to built-in `font_10`, added `conf.toml` support for `[render].default_font_size` and `[render].default_font_bold`, exposed `lurek.render.setDefaultFont(size, bold?)`, and aligned built-in font helpers with bundled font labels (`8/10/12/16/20/24/30`) instead of internal cell heights.
- feat(render): replaced the old embedded bitmap fonts with Courier New atlas files `assets/fonts/font_*` and `fontb_*` at 7 sizes (8/10/12/16/20/24/30 pt), full Latin-1 coverage, and terminal-symbol aliases for box-drawing/block/arrow glyphs; added stable built-in font names, runtime TTF/OTF loading through `lurek.render.newFont(path, size)`, per-call font draw helpers (`printWithFont`, `printfWithFont`, `printRotatedWithFont`, `printRichWithFont`), working `setFontLineHeight`, and bold/default-font selection helpers.
- feat(ui): added global UI font selection through `lurek.ui.setFont/getFont/clearFont`, per-widget subtree overrides through `LUiWidget:setFont/clearFont`, widget-font lookup via `lurek.ui.getWidgetFont`, and font-aware text measurement for retained UI alignment and text-input cursor placement.
- fix(games): added explicit `LLabel` controls, smaller bitmap font sizing, integer dashboard scaling, render/frame timing display, and debounced SQL/DataFrame refreshes to `apps/household_finance_lab` so the top widgets are labeled, less crowded, and more responsive.
- fix(ui): reserved chart legend space outside plotted data for line, bar, scatter, area, and pie charts, including compact dashboard-sized images where legends previously covered series, bars, or pie wedges.
- fix(render): fixed light composite pass producing no visible effect — `composite_pipeline` was created with `TexVertex` stride (48 bytes) while the vertex buffer holds `LightVertex` data (52 bytes), causing every composite vertex to be read from a wrong buffer offset; replaced the `create_render_pipeline(GeometryKind::Texture, …)` call with an inline pipeline descriptor using `LightVertex` layout so the multiply-blend fullscreen quad covers the screen correctly.
- content(games): updated `test/light_min` to use explicit `light:setIntensity / setColor / setBlendMode / setFalloff / setShadowEnabled` method calls instead of the opts table, and lowered ambient to 0.06 to make the lit/unlit contrast dramatic once the composite pass is working.
- fix(games): corrected `showcase/light_demo` tween arg order for all three `tween_api.to()` calls (fields and duration were swapped), and fixed particle colors format from flat arrays to nested tables in both torch and glow particle systems.
- fix(games): corrected `showcase/light_showcase` initial state from `STATE_SCREEN_1` to `STATE_TITLE` and fixed `STATE_TITLE` value from `"PLAYING"` to `"TITLE"` so the title screen is shown on launch and can navigate to each of the 8 technique screens.

- feat(dataframe): added SQL SELECT arithmetic expressions with `AS` aliases for columns, aggregate calls, and `LDatabase:queryParams` placeholders, letting `apps/household_finance_lab` compute metric ratios fully in SQL.
- test(games): added app-local mouse interaction coverage to `apps/household_finance_lab` for tabs, combo boxes, sliders, switches, and buttons.
- refactor(games): removed duplicate Lua-drawn transaction table rows from `apps/household_finance_lab` so the transactions tab uses the retained `LGuiTable:setDataFrame` output.
- refactor(games): updated `apps/household_finance_lab` to use DataFrame CSV file loading, JSON database save/load caching, parameterized SQL filters, bulk UI table setters, and DataFrame-backed chart helpers instead of custom Lua parsing/cache/chart glue.
- feat(dataframe): added Rust-threaded `LDataFrameTask` async APIs for CSV/JSON file loads, dataframe SQL queries, and snapshot-based database SQL queries.
- feat(ui): added DataFrame-backed table and chart helper APIs for bulk-loading rows, point series, bar categories, pie segments, and area layers from `LDataFrame` values.
- fix(ui): added retained UI P1 interactions for text focus/edit changes, focused keyboard activation and arrow navigation, radio groups, tree rows, spin-box zones, accordions, scroll bars, dialog/window close controls, toolbar toggles, and color-picker clicks.
- fix(ui): routed retained widget mouse and wheel input through computed rectangles, enabling slider drag, tab selection, combo open/select, table row selection and sorting, and hover-based scroll panel routing.
- feat(dataframe): added value counts, missing reports, duplicate-row extraction, ISO date part helpers, and Rust-side positional SQL parameters for database queries.
- refactor(dataframe): moved GameFS-backed CSV/JSON/LVDF dataframe and JSON database file persistence out of Lua bindings into dataframe module helpers with a narrow GameFS storage adapter.
- feat(dataframe): added GameFS-backed CSV/JSON dataframe file loaders, dataframe CSV/JSON/LVDF file writers, and JSON database save/load APIs so apps can persist tabular caches without Lua-side file glue.
- content(games): resized `apps/household_finance_lab` to a native 800x600 layout so smoke screenshots are readable without downscaling, and corrected its screenshot path documentation.
- content(games): repaired `showcase/globe_demo` so it no longer opens to a blank HUD-only screen by adding a visible Lua-side globe fallback renderer, keyboard/gamepad camera controls, center-focus gamepad selection, and README updates that match the actual runtime behavior.
- content(games): fixed controller support in 14 games by routing movement, jump, menu, lane, pick, and cast actions through `lurek.input` action bindings, adding `gamepad:0:*` mappings for d-pad and face buttons, and refreshing all 133 packaged `.lurek` archives in `content/zips`.
- refactor(games): reworked `apps/household_finance_lab` around public `lurek.*` APIs by moving constants to TOML, deleting custom SQL/analytics/chart/state modules, running SQL through `LDatabase:query`, using `LDataFrame` methods for analytics, rendering charts through `lurek.ui` chart widgets, and saving UI snapshots through `lurek.save`.
- feat(games): added the `apps/household_finance_lab` business/data-science demo with deterministic household finance CSV generation, dataframe/database analytics, binary cache output, UI charts/tables, logs, and anomaly detection.
- content(games): added `lurek.automation.update(...)` to all 132 game process callbacks, created packaged `automation_smoke.toml` replays for `cannon_fodder`, `settlers_rise`, `sensible_soccer`, `star_voyage`, `worms_artillery`, `boulder_dash`, `giana_sisters`, and `alchemy`, and refreshed `content/zips` so every `.lurek` archive includes the latest game-side automation assets.
- content(games): fixed dead input paths in `cannon_fodder`, `settlers_rise`, `sensible_soccer`, `star_voyage`, `worms_artillery`, `boulder_dash`, `giana_sisters`, and `alchemy` by restoring `lurek.process(dt)` adapters or proper action bindings, and documented that all 132 games still need a shared `lurek.automation.update(dt)` hook for mass replay validation.
- chore(examples): added a canonical sequential `lurek2d` sweep flow for `content/examples/*.lua` via `tools/demos/smoke_sweep.py`, exposed it as VS Code tasks, and documented the difference between real engine example runs and test harnesses.
- chore(build): restored the missing `crates/lurek_schema` path dependency so Cargo commands work again, moved the `cargo-nextest` config to `.cargo/nextest.toml`, and documented which Rust/build config files must remain in their fixed toolchain locations.
- content(examples): normalized every `--@api-stub` teaching comment to a single long-form usage line, added missing coverage for `lurek.physics.attachShape`, and reduced the most overgrown `scene`, `window`, and `physics` blocks to smaller one-API examples.
- docs(api): renamed Lureksome to Lureksome, moved generated library API outputs to `docs/api/lureksome.{md,lua}`, removed the legacy library-doc output directory, and updated docs/wiki/tooling references.
- chore(tools): removed one-off migration and single-batch cleanup scripts from `tools/`, kept the reusable long-term generators, validators, audits, and fixers, rewrote `tools/README.md` as the canonical single-file tool registry, and synced `tools/fix/README.md` with the retained fixer set.
