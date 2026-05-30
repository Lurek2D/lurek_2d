# effect

## TL;DR

- The `effect` module is a comprehensive Platform Services component responsible for the engine's post-processing and screen-space visual effects pipeline.
- **Note:** Weather, atmosphere, and screen overlay effects have been extracted to `src/overlay/` â€” see [`docs/specs/overlay.md`](overlay.md).

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

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `overlay`: Imports or references `src/overlay/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### draw.rs

- Provides lightweight stack-preview rendering that converts effect activity into a quick diagnostic image.
- Distinguishes active and inactive stack states through deterministic color selection.
- Delivers a minimal visual probe for tooling and debug-side effect inspection.

### effect.rs

- Provides runtime post-effect instances that couple effect kind with mutable parameter state.
- Supports built-in and custom shader-backed variants under one unified runtime shape.
- Exposes parameter and enable controls for live effect tuning without pipeline rebuilds.
- Delivers the per-effect state object consumed by stack management and rendering stages.

### effect_type.rs

- Provides the canonical post-effect type catalog that defines all built-in processing identities.
- Maps stable Lua-facing names to typed variants for predictable script and engine interoperability.
- Supplies debug labels and parsing helpers that normalize user input into supported effect forms.
- Defines default parameter sets so each effect starts from consistent baseline behavior.
- Separates built-in variants from custom-shader paths while preserving one shared lookup model.
- Delivers the naming and typing backbone used by effect instances, stacks, and presets.

### image_effect.rs

- Provides image-scoped post-effect pipelines that group shared and owned effects into ordered pass chains.
- Supports add, remove, and lookup workflows so runtime code can manage effect sets incrementally.
- Converts active effects into renderer-facing pass descriptors for downstream execution.
- Delivers the per-target composition layer for reusable shader effect application.

### mod.rs

- Provides the high-level visual effects module boundary for post-processing composition and runtime control.
- Connects effect instances, stacks, presets, and renderer integration into one coherent pipeline surface.
- Delivers a data-driven effect orchestration layer that scripts and systems can configure predictably.

### presets.rs

- Provides built-in post-effect presets that package curated visual moods into ready-to-use chains.
- Builds effect sets with viewport-aware stack initialization for immediate runtime application.
- Exposes canonical preset names so scripts can select consistent looks with stable identifiers.
- Encapsulates preset assembly logic to keep stylistic recipes centralized and reusable.
- Delivers one-call factories that return enabled stacks configured for direct deployment.

### render.rs

- Provides render-command generation for post-effect capture and application flows.
- Emits deterministic begin, end, and apply command sequences consumed by the renderer.
- Delivers no-op behavior when stacks have no active effects to process.

### stack.rs

- Provides ordered post-effect stack management with per-entry enable state and target dimensions.
- Stores effect references in application order while preserving synchronized activation flags.
- Supports insertion, removal, reordering, and dedup operations for dynamic runtime composition.
- Exposes query helpers that report active subsets and positional stack metadata.
- Includes stack-introspection render helpers for debugging and visual tooling overlays.
- Applies defensive index handling so invalid operations fail safely at runtime boundaries.
- Delivers the sequencing core that determines how effect chains are executed frame to frame.

## Lua API Ref

### Functions

- `lurek.effect.getEffectTypes`: Returns all built-in post-processing effect type names.
- `lurek.effect.getPresetNames`: Returns all built-in post-processing preset names.
- `lurek.effect.getShaderErrorDisplay`: Returns whether renderer shader error display overlays are enabled.
- `lurek.effect.newCustomEffect`: Creates a custom post-processing effect that references an existing shader id.
- `lurek.effect.newEffect`: Creates a built-in post-processing effect by type name.
- `lurek.effect.newImageEffect`: Creates an image effect chain from no arguments, a type name and optional parameters, or a chain table.
- `lurek.effect.newPass`: Creates a custom post-processing pass from an existing shader id.
- `lurek.effect.newPresetStack`: Creates a named preset post-processing stack with optional dimensions.
- `lurek.effect.newStack`: Creates a post-processing stack using optional dimensions or the current window size.
- `lurek.effect.setShaderErrorDisplay`: Enables or disables renderer shader error display overlays.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LImageEffect Type

- Lua-side handle for an image effect chain detached from live post-effect capture.

##### Fields

- No documented fields.

##### Methods

- `LImageEffect:addEffect`: Appends a built-in post-effect by type name to this image effect chain.
- `LImageEffect:clear`: Removes every effect from this image effect chain.
- `LImageEffect:clearEffects`: Removes every effect from this image effect chain.
- `LImageEffect:clone`: Creates a new image effect chain with cloned effect entries.
- `LImageEffect:effectCount`: Returns the number of effects in this image effect chain.
- `LImageEffect:getEffect`: Looks up an image effect by one-based index or effect type name.
- `LImageEffect:getEffectCount`: Returns the number of effects in this image effect chain.
- `LImageEffect:removeByIndex`: Removes an image effect by zero-based internal index.
- `LImageEffect:removeByName`: Removes the first image effect with a matching effect type name.
- `LImageEffect:removeEffect`: Removes an image effect by one-based index or effect type name.
- `LImageEffect:save`: Reports success for the current image effect save placeholder.
- `LImageEffect:type`: Returns the Lua-visible type name for this image effect handle.
- `LImageEffect:typeOf`: Returns whether this image effect handle matches a supported type name.

#### LPostFxEffect Type

- Lua-side handle for a single post-processing effect instance.

##### Fields

- No documented fields.

##### Methods

- `LPostFxEffect:disableAutoUniforms`: Disables automatic time and resolution uniforms for this effect.
- `LPostFxEffect:enableAutoUniforms`: Enables automatic time and resolution uniforms for this effect.
- `LPostFxEffect:getEffectType`: Returns the renderer effect type name.
- `LPostFxEffect:getParameter`: Reads a numeric shader parameter and falls back to a default value when missing.
- `LPostFxEffect:getParameterNames`: Returns the parameter names stored on this effect.
- `LPostFxEffect:getType`: Returns the renderer effect type name.
- `LPostFxEffect:getTypeName`: Returns the built-in or custom effect type name.
- `LPostFxEffect:hasParameter`: Returns whether a shader parameter exists on this effect.
- `LPostFxEffect:isAutoUniforms`: Returns whether automatic uniforms are enabled for this effect.
- `LPostFxEffect:isBuiltIn`: Returns whether this effect uses one of the engine built-in effect types.
- `LPostFxEffect:isEnabled`: Returns whether this effect is enabled on its owning effect object.
- `LPostFxEffect:setBrightness`: Sets the brightness shader parameter on this effect.
- `LPostFxEffect:setContrast`: Sets the contrast shader parameter on this effect.
- `LPostFxEffect:setEnabled`: Enables or disables this effect. This method is available to Lua scripts.
- `LPostFxEffect:setIntensity`: Sets the intensity shader parameter on this effect.
- `LPostFxEffect:setOffset`: Sets the offset shader parameter on this effect.
- `LPostFxEffect:setParameter`: Sets a numeric shader parameter by name.
- `LPostFxEffect:setRadius`: Sets the radius shader parameter on this effect.
- `LPostFxEffect:setSaturation`: Sets the saturation shader parameter on this effect.
- `LPostFxEffect:setScanlineStrength`: Sets the scanline strength shader parameter on this effect.
- `LPostFxEffect:setStrength`: Sets the strength shader parameter on this effect.
- `LPostFxEffect:setThreshold`: Sets the threshold shader parameter on this effect.
- `LPostFxEffect:type`: Returns the Lua-visible type name for this post-processing effect handle.
- `LPostFxEffect:typeOf`: Returns whether this effect handle matches a supported type name.

#### LPostFxStack Type

- Lua-side handle for an ordered post-processing stack.

##### Fields

- No documented fields.

##### Methods

- `LPostFxStack:add`: Appends an effect to the end of this stack.
- `LPostFxStack:apply`: Queues this stack's enabled post-effect passes for renderer application.
- `LPostFxStack:beginCapture`: Starts post-effect capture and queues a renderer begin-capture command.
- `LPostFxStack:clear`: Removes all effects and pass state from this stack.
- `LPostFxStack:clearFeedback`: Resets the stack feedback blend factor to zero.
- `LPostFxStack:dedup`: Removes duplicate effect handles while preserving first occurrences.
- `LPostFxStack:endCapture`: Ends post-effect capture and queues a renderer end-capture command.
- `LPostFxStack:getDimensions`: Returns the stack render dimensions.
- `LPostFxStack:getEffect`: Returns the effect handle at a one-based position.
- `LPostFxStack:getEffectCount`: Returns the number of effect handles in this stack.
- `LPostFxStack:getEnabledEffects`: Returns effect handles whose stack passes are enabled.
- `LPostFxStack:getFeedback`: Returns the current stack feedback blend factor.
- `LPostFxStack:getHeight`: Returns the stack render height. This method is available to Lua scripts.
- `LPostFxStack:getWidth`: Returns the stack render width. This method is available to Lua scripts.
- `LPostFxStack:insert`: Inserts an effect at a one-based stack position.
- `LPostFxStack:isCapturing`: Returns whether this stack is currently capturing draw commands.
- `LPostFxStack:isEmpty`: Returns whether this stack has no effects.
- `LPostFxStack:isEnabled`: Returns whether the effect pass at a one-based position is enabled.
- `LPostFxStack:len`: Returns the number of effect handles in this stack.
- `LPostFxStack:remove`: Removes the first matching effect handle from this stack.
- `LPostFxStack:resize`: Resizes the post-processing stack render target dimensions.
- `LPostFxStack:setEnabled`: Enables or disables the effect pass at a one-based stack position.
- `LPostFxStack:setFeedback`: Sets the stack feedback blend factor and clamps it to 0.0 through 1.0.
- `LPostFxStack:type`: Returns the Lua-visible type name for this post-processing stack handle.
- `LPostFxStack:typeOf`: Returns whether this stack handle matches a supported type name.
