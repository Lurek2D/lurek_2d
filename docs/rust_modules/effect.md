# effect

## General Info

- Module group: `Platform Services`
- Source path: `src/effect/`
- Binding: `src/lua_api/effect_api.rs`
- Namespace: `lurek.effect`
- Lua API surface: `10` functions, `3` types, `62` methods
- Rust test path(s): tests/rust/unit/effect_tests.rs
- Lua test path(s): tests/lua/unit/test_effect_core_unit.lua, tests/lua/integration/test_effect_camera.lua, tests/lua/integration/test_effect_light.lua, tests/lua/evidence/test_effect_evidence.lua

## Summary

This module represents the visual post-processing pipeline, enabling developers to apply full-screen shader effects to render outputs. It manages effect instances coupling specific shader algorithms with customizable parameters. These apply dynamically using either built-in effect types or custom shaders, giving developers control over the final visual presentation of their games.

The post-processing stack coordinates the order and execution of multiple visual passes. The stack manages active capture boundaries, directing the renderer to intercept draw commands and route them through the active shader sequence. Effects can be enabled or reordered dynamically, automatically falling back to no-op modes when inactive to preserve processing performance.

To streamline styling, a preset system bundles curated configurations into ready-to-use stacks. These presets allow developers to apply complex visual moods with a single operation. Viewport-aware initializations ensure that newly spawned stacks automatically scale to match the window dimensions, maintaining sharp scaling and alignment across different display sizes.

Additionally, the module supports image-specific processing chains operating independently from main game capture. These custom chains apply shader filters directly to separate graphical assets. Introspection features offer diagnostic stack indicators and shader error displays to make debugging and tuning visual effects straightforward.

## Files

### [draw.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/effect/draw.rs)

- Provides lightweight stack-preview rendering that converts effect activity into a quick diagnostic image.
- Distinguishes active and inactive stack states through deterministic color selection.
- Delivers a minimal visual probe for tooling and debug-side effect inspection.

### [effect.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/effect/effect.rs)

- Provides runtime post-effect instances that couple effect kind with mutable parameter state.
- Supports built-in and custom shader-backed variants under one unified runtime shape.
- Exposes parameter and enable controls for live effect tuning without pipeline rebuilds.
- Delivers the per-effect state object consumed by stack management and rendering stages.

### [effect_type.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/effect/effect_type.rs)

- Provides the canonical post-effect type catalog that defines all built-in processing identities.
- Maps stable Lua-facing names to typed variants for predictable script and engine interoperability.
- Supplies debug labels and parsing helpers that normalize user input into supported effect forms.
- Defines default parameter sets so each effect starts from consistent baseline behavior.
- Separates built-in variants from custom-shader paths while preserving one shared lookup model.
- Delivers the naming and typing backbone used by effect instances, stacks, and presets.

### [image_effect.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/effect/image_effect.rs)

- Provides image-scoped post-effect pipelines that group shared and owned effects into ordered pass chains.
- Supports add, remove, and lookup workflows so runtime code can manage effect sets incrementally.
- Converts active effects into renderer-facing pass descriptors for downstream execution.
- Delivers the per-target composition layer for reusable shader effect application.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/effect/mod.rs)

- Provides the high-level visual effects module boundary for post-processing composition and runtime control.
- Connects effect instances, stacks, presets, and renderer integration into one coherent pipeline surface.
- Delivers a data-driven effect orchestration layer that scripts and systems can configure predictably.

### [presets.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/effect/presets.rs)

- Provides built-in post-effect presets that package curated visual moods into ready-to-use chains.
- Builds effect sets with viewport-aware stack initialization for immediate runtime application.
- Exposes canonical preset names so scripts can select consistent looks with stable identifiers.
- Encapsulates preset assembly logic to keep stylistic recipes centralized and reusable.
- Delivers one-call factories that return enabled stacks configured for direct deployment.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/effect/render.rs)

- Provides render-command generation for post-effect capture and application flows.
- Emits deterministic begin, end, and apply command sequences consumed by the renderer.
- Delivers no-op behavior when stacks have no active effects to process.

### [stack.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/effect/stack.rs)

- Provides ordered post-effect stack management with per-entry enable state and target dimensions.
- Stores effect references in application order while preserving synchronized activation flags.
- Supports insertion, removal, reordering, and dedup operations for dynamic runtime composition.
- Exposes query helpers that report active subsets and positional stack metadata.
- Includes stack-introspection render helpers for debugging and visual tooling overlays.
- Applies defensive index handling so invalid operations fail safely at runtime boundaries.
- Delivers the sequencing core that determines how effect chains are executed frame to frame.
