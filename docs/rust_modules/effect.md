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

The `effect` module manages visual post-effect composition data and lifecycle, including stack ordering, effect instances, presets, and conversion into render-command level apply/capture passes. It focuses on effect state orchestration rather than direct GPU execution.

Core responsibilities are partitioned across submodules: `effect` and `effect_type` define instance/state and built-in identifiers, `stack` manages ordered effect collections, `presets` supplies reusable configurations, `image_effect` groups image-scoped effect sets, and `render`/`draw` adapt effect state into command-level outputs consumed by the renderer.

A key architectural property is data-driven configuration. Effects are represented as configurable descriptors and parameter maps, enabling Lua and tooling workflows to compose visual pipelines without hardcoding render paths per effect.

The module should continue to own effect lifecycle and stack policy (including expiry/removal timing), while the renderer remains responsible for executing the generated commands on GPU resources.

Implementation detail and boundary guarantees for effect: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: draw.rs: Render a preview image summarizing the current post-FX stack state.; effect.rs: Post-processing effect instance holding type, parameters, and enabled state.; effect_type.rs: Post-processing effect type enumeration and name registry.; image_effect.rs: Image-scoped post-processing effect pipeline that groups and orders shader passes.; mod.rs: Visual effect sub-system: particle effects, screen-space post-processing, and shakes.; presets.rs: Built-in post-processing effect presets (retro TV, horror, dream, neon, sepia).; render.rs: Render-command integration for the post-effects stack.; stack.rs: Ordered post-processing effect stack with per-entry enable flags.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

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
