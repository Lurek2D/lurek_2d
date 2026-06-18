# effect

## TL;DR

- Manages visual post-processing stacks, shader parameters, and presets.
- Coordinates capture boundaries, image effect chains, and diagnostics.

## General Info

- Module group: `Platform Services`
- Source path: `src/effect/`
- Binding: `src/lua_api/effect_api.rs`
- Namespace: `lurek.effect`
- Lua API surface: `10` functions, `3` types, `62` methods
- Rust test path(s): tests/rust/unit/effect_tests.rs
- Lua test path(s): tests/lua/unit/test_effect_unit.lua, tests/lua/integration/test_effect_camera_integration.lua, tests/lua/integration/test_effect_light_integration.lua, tests/lua/evidence/test_effect_evidence.lua

## Summary

- The `effect` module is the post-processing surface for users who want final-frame styling to be configurable at runtime instead of buried in renderer internals.
- Effect stacks, presets, and parameter control let a project combine blur, bloom, grading, distortion, and custom passes as a reusable look pipeline rather than as isolated toggles.
- The same module supports both full-frame and image-scoped workflows, which makes it useful for global scene mood, local asset treatment, and diagnostic capture flows.
- Runtime enabling, disabling, and reordering matter because visual iteration often depends on trying combinations quickly while the game is running.
- Preset-oriented workflow is a major user-facing advantage because art direction often depends on named looks that can be switched, blended, or tuned per scene rather than reassembled from scratch each time.
- The module also improves experimentation: users can compare treatments, capture reference outputs, and stage layered effect combinations without rewriting renderer-facing pass code.
- This makes `effect` a useful art-direction layer for both shipped visuals and tooling-time look development, especially when several passes must be coordinated as one style decision.
- Read this module as the owner of effect composition and art-direction control. The renderer executes passes, but `effect` defines how those passes are organized and tuned from the user side.
- `effect` owns composition policy, while `render` performs the underlying passes.


## Imports

- `image`: Imports or references `image` from `src/image/`.
- `overlay`: Imports or references `src/overlay/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### draw.rs

- This file owns the lightweight `PostFxStack` preview renderer that turns stack activity into a diagnostic image.
- It fills a simple image differently when any effect is enabled, giving tools a cheap visual state indicator.
- Open this file when effect-stack preview semantics change; stack storage and render commands live in siblings.

### effect.rs

- This file owns `PostFxEffect`, the runtime state object that couples one effect kind with mutable parameters.
- It stores the effect type, scalar parameter map, enable flag, optional shader id, and auto-uniform toggle.
- Construction helpers cover built-in and custom effects, while accessors expose parameter reads, writes, and names.
- Open this file when per-effect runtime semantics change; type catalogs, stacks, and image grouping live in siblings.

### effect_type.rs

- This file owns `PostFxEffectType`, the canonical catalog of built-in and custom post-processing identities.
- It maps stable lowercase names to enum variants so scripts and engine code resolve the same effect repertoire.
- Debug labels and built-in-name helpers centralize human-readable identifiers without duplicating lookup tables.
- Default-parameter builders also live here, giving each effect type a consistent scalar starting configuration.
- The enum separates built-in effects from custom shaders while preserving one shared naming and parsing surface.
- Open this file when supported effect kinds change; per-instance state and preset recipes live in sibling files.

### image_effect.rs

- This file owns `ImageEffect`, the image-scoped pipeline that groups shared `PostFxEffect` handles into pass chains.
- It stores owned or shared effect references, supports add and remove workflows, and resolves entries by index or name.
- The `to_passes` helper converts active effect state into `ShaderPassDescriptor` values for downstream execution.
- Open this file when image-level effect composition changes; effect instances, presets, and stacks live in siblings.

### mod.rs

- This module re-exports the post-effect subsystem surface for effect instances, stacks, presets, render, and draws.
- It is the navigation map for effect ownership, command generation, named presets, and stack-level debug tooling.
- `effect.rs` owns one runtime effect instance, while `stack.rs` manages ordering, enable flags, and target dimensions.
- `effect_type.rs` defines built-in identities and default parameters, and `image_effect.rs` groups shared pass chains.
- `render.rs`, `draw.rs`, and `presets.rs` cover renderer commands, debug previews, and ready-made visual recipes.
- It also forwards legacy overlay exports, so change this file when public effect symbols or compatibility edges move.

### presets.rs

- This file owns `EffectPreset` and the named recipe builders that assemble curated post-effect chains for callers.
- It exposes canonical preset names, constructs effect lists, and prepares `PostFxStack` ordering for target dimensions.
- Each builder encodes one visual recipe, such as retro TV, horror, dream, neon, or aged sepia composition.
- Preset assembly stays centralized here so scripts can request stable looks without duplicating parameter tuning.
- Open this file when built-in effect recipes change; effect types, instances, and stack behavior live in siblings.

### render.rs

- This file owns `PostFxStack` render-command generation for post-effect capture, end, and apply orchestration.
- It emits deterministic renderer commands only when the stack has effects and at least one entry is enabled.
- Open this file when post-effect command sequencing changes; stack storage and debug previews live in siblings.

### stack.rs

- This file owns `PostFxStack`, the ordered effect-index container that tracks enable flags, size, and capture state.
- It stores application order in parallel vectors, supports insertion and removal, and toggles entries efficiently.
- Query helpers report enabled subsets, one-based positions, dimensions, emptiness, and deduplicated index counts.
- Resize and clear operations keep render-target bookkeeping local so post-effect callers do not manage raw vectors.
- Dedup logic preserves first occurrence order while cleaning repeated effect references from dynamic compositions.
- Several debug image helpers also live here because they visualize stack entries, labels, params, and effect catalogs.
- Open this file when stack orchestration changes; effect instances, presets, and render commands live in siblings.



## Lua API Ref

### Functions

- `lurek.effect.getEffectTypes() -> string[]`: Returns all built-in post-processing effect type names.
- `lurek.effect.getPresetNames() -> string[]`: Returns all built-in post-processing preset names.
- `lurek.effect.getShaderErrorDisplay() -> boolean`: Returns whether renderer shader error display overlays are enabled.
- `lurek.effect.newCustomEffect(shader_id) -> LPostFxEffect`: Creates a custom post-processing effect that references an existing shader id.
- `lurek.effect.newEffect(type_name) -> LPostFxEffect`: Creates a built-in post-processing effect by type name.
- `lurek.effect.newImageEffect(spec?, params?) -> LImageEffect`: Creates an image effect chain from no arguments, a type name and optional parameters, or a chain table.
- `lurek.effect.newPass(shader_id) -> LPostFxEffect`: Creates a custom post-processing pass from an existing shader id.
- `lurek.effect.newPresetStack(name, w?, h?) -> LPostFxStack`: Creates a named preset post-processing stack with optional dimensions.
- `lurek.effect.newStack(w?, h?) -> LPostFxStack`: Creates a post-processing stack using optional dimensions or the current window size.
- `lurek.effect.setShaderErrorDisplay(enabled) -> nil`: Enables or disables renderer shader error display overlays.

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

- `LImageEffect:addEffect(name) -> LPostFxEffect`: Appends a built-in post-effect by type name to this image effect chain.
- `LImageEffect:clear() -> nil`: Removes every effect from this image effect chain.
- `LImageEffect:clearEffects() -> nil`: Removes every effect from this image effect chain.
- `LImageEffect:clone() -> LImageEffect`: Creates a new image effect chain with cloned effect entries.
- `LImageEffect:effectCount() -> integer`: Returns the number of effects in this image effect chain.
- `LImageEffect:getEffect(key) -> LuaValue`: Looks up an image effect by one-based index or effect type name.
- `LImageEffect:getEffectCount() -> integer`: Returns the number of effects in this image effect chain.
- `LImageEffect:removeByIndex(idx) -> boolean`: Removes an image effect by zero-based internal index.
- `LImageEffect:removeByName(name) -> boolean`: Removes the first image effect with a matching effect type name.
- `LImageEffect:removeEffect(key) -> boolean`: Removes an image effect by one-based index or effect type name.
- `LImageEffect:save() -> boolean`: Reports success for the current image effect save placeholder.
- `LImageEffect:type() -> string`: Returns the Lua-visible type name for this image effect handle.
- `LImageEffect:typeOf(name) -> boolean`: Returns whether this image effect handle matches a supported type name.

#### LPostFxEffect Type

- Lua-side handle for a single post-processing effect instance.

##### Fields

- No documented fields.

##### Methods

- `LPostFxEffect:disableAutoUniforms() -> nil`: Disables automatic time and resolution uniforms for this effect.
- `LPostFxEffect:enableAutoUniforms() -> nil`: Enables automatic time and resolution uniforms for this effect.
- `LPostFxEffect:getEffectType() -> string`: Returns the renderer effect type name.
- `LPostFxEffect:getParameter(name, default?) -> number`: Reads a numeric shader parameter and falls back to a default value when missing.
- `LPostFxEffect:getParameterNames() -> string[]`: Returns the parameter names stored on this effect.
- `LPostFxEffect:getType() -> string`: Returns the renderer effect type name.
- `LPostFxEffect:getTypeName() -> string`: Returns the built-in or custom effect type name.
- `LPostFxEffect:hasParameter(name) -> boolean`: Returns whether a shader parameter exists on this effect.
- `LPostFxEffect:isAutoUniforms() -> boolean`: Returns whether automatic uniforms are enabled for this effect.
- `LPostFxEffect:isBuiltIn() -> boolean`: Returns whether this effect uses one of the engine built-in effect types.
- `LPostFxEffect:isEnabled() -> boolean`: Returns whether this effect is enabled on its owning effect object.
- `LPostFxEffect:setBrightness(v) -> nil`: Sets the brightness shader parameter on this effect.
- `LPostFxEffect:setContrast(v) -> nil`: Sets the contrast shader parameter on this effect.
- `LPostFxEffect:setEnabled(enabled) -> nil`: Enables or disables this effect. This method is available to Lua scripts.
- `LPostFxEffect:setIntensity(v) -> nil`: Sets the intensity shader parameter on this effect.
- `LPostFxEffect:setOffset(v) -> nil`: Sets the offset shader parameter on this effect.
- `LPostFxEffect:setParameter(name, value) -> nil`: Sets a numeric shader parameter by name.
- `LPostFxEffect:setRadius(v) -> nil`: Sets the radius shader parameter on this effect.
- `LPostFxEffect:setSaturation(v) -> nil`: Sets the saturation shader parameter on this effect.
- `LPostFxEffect:setScanlineStrength(v) -> nil`: Sets the scanline strength shader parameter on this effect.
- `LPostFxEffect:setStrength(v) -> nil`: Sets the strength shader parameter on this effect.
- `LPostFxEffect:setThreshold(v) -> nil`: Sets the threshold shader parameter on this effect.
- `LPostFxEffect:type() -> string`: Returns the Lua-visible type name for this post-processing effect handle.
- `LPostFxEffect:typeOf(name) -> boolean`: Returns whether this effect handle matches a supported type name.

#### LPostFxStack Type

- Lua-side handle for an ordered post-processing stack.

##### Fields

- No documented fields.

##### Methods

- `LPostFxStack:add(effect_ud) -> nil`: Appends an effect to the end of this stack.
- `LPostFxStack:apply() -> nil`: Queues this stack's enabled post-effect passes for renderer application.
- `LPostFxStack:beginCapture() -> nil`: Starts post-effect capture and queues a renderer begin-capture command.
- `LPostFxStack:clear() -> nil`: Removes all effects and pass state from this stack.
- `LPostFxStack:clearFeedback() -> nil`: Resets the stack feedback blend factor to zero.
- `LPostFxStack:dedup() -> integer`: Removes duplicate effect handles while preserving first occurrences.
- `LPostFxStack:endCapture() -> nil`: Ends post-effect capture and queues a renderer end-capture command.
- `LPostFxStack:getDimensions() -> integer`: Returns the stack render dimensions.
- `LPostFxStack:getEffect(index) -> LuaValue`: Returns the effect handle at a one-based position.
- `LPostFxStack:getEffectCount() -> integer`: Returns the number of effect handles in this stack.
- `LPostFxStack:getEnabledEffects() -> LPostFxEffect[]`: Returns effect handles whose stack passes are enabled.
- `LPostFxStack:getFeedback() -> number`: Returns the current stack feedback blend factor.
- `LPostFxStack:getHeight() -> integer`: Returns the stack render height. This method is available to Lua scripts.
- `LPostFxStack:getWidth() -> integer`: Returns the stack render width. This method is available to Lua scripts.
- `LPostFxStack:insert(position, effect_ud) -> nil`: Inserts an effect at a one-based stack position.
- `LPostFxStack:isCapturing() -> boolean`: Returns whether this stack is currently capturing draw commands.
- `LPostFxStack:isEmpty() -> boolean`: Returns whether this stack has no effects.
- `LPostFxStack:isEnabled(position) -> boolean`: Returns whether the effect pass at a one-based position is enabled.
- `LPostFxStack:len() -> integer`: Returns the number of effect handles in this stack.
- `LPostFxStack:remove(effect_ud) -> boolean`: Removes the first matching effect handle from this stack.
- `LPostFxStack:resize(w, h) -> nil`: Resizes the post-processing stack render target dimensions.
- `LPostFxStack:setEnabled(position, enabled) -> nil`: Enables or disables the effect pass at a one-based stack position.
- `LPostFxStack:setFeedback(factor) -> nil`: Sets the stack feedback blend factor and clamps it to 0.0 through 1.0.
- `LPostFxStack:type() -> string`: Returns the Lua-visible type name for this post-processing stack handle.
- `LPostFxStack:typeOf(name) -> boolean`: Returns whether this stack handle matches a supported type name.

## References

- `image`: Imports or references `image` from `src/image/`.
- `overlay`: Imports or references `src/overlay/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
