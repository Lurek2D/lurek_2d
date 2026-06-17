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

- This module lets users shape final frame look through configurable post-processing passes.
- You can combine built-in and custom shader effects to build a visual style pipeline per scene.
- Stack ordering controls allow deliberate multi-pass composition instead of one-off filter toggles.
- Runtime enable/disable and reordering support fast visual iteration during gameplay testing.
- Preset stacks provide one-call mood changes for common cinematic or stylized looks.
- Capture-aware stack behavior integrates with render flow without forcing manual pass orchestration.
- Image-specific chains support applying effects to selected assets independently of full-screen capture.
- Parameter APIs make tuning brightness, saturation, threshold, and similar controls straightforward.
- Diagnostic helpers expose stack state and shader issues to speed up troubleshooting.
- Viewport-aware defaults help effects remain consistent across resolution changes.
- For users, this module turns post FX from engine internals into script-level art direction control.
- It reduces visual-pipeline glue code and encourages reusable look presets.
- The result is faster experimentation and more consistent presentation quality.
- Overall, it provides the practical runtime layer for stylized rendering workflows.

This module primarily collaborates with `image`, `overlay`, `render`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `overlay`: Imports or references `src/overlay/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### draw.rs

- Provides lightweight stack-preview rendering that converts effect activity into a quick diagnostic image. `effect/draw` delivers the draw implementation for the effect subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### effect.rs

- Provides runtime post-effect instances that couple effect kind with mutable parameter state. `effect/effect` delivers the effect implementation for the effect subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports built-in and custom shader-backed variants under one unified runtime shape. The file owns or coordinates data contracts including `PostFxEffect`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Exposes parameter and enable controls for live effect tuning without pipeline rebuilds. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `new_custom`, `set_parameter`, `get_parameter`, `has_parameter`, `get_parameter_names`, and 5 more stays attached to the local data model and invariants.
- Delivers the per-effect state object consumed by stack management and rendering stages. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### effect_type.rs

- Provides the canonical post-effect type catalog that defines all built-in processing identities. `effect/effect_type` delivers the effect type implementation for the effect subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maps stable Lua-facing names to typed variants for predictable script and engine interoperability. The file owns or coordinates data contracts including `PostFxEffectType`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supplies debug labels and parsing helpers that normalize user input into supported effect forms. Public callable behavior is centered on no named public items, while method-level behavior such as `from_name`, `built_in_names`, `name`, `debug_label`, `default_params` stays attached to the local data model and invariants.
- Defines default parameter sets so each effect starts from consistent baseline behavior. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Separates built-in variants from custom-shader paths while preserving one shared lookup model. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### image_effect.rs

- Provides image-scoped post-effect pipelines that group shared and owned effects into ordered pass chains. `effect/image_effect` delivers the image effect implementation for the effect subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports add, remove, and lookup workflows so runtime code can manage effect sets incrementally. The file owns or coordinates data contracts including `ImageEffect`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Converts active effects into renderer-facing pass descriptors for downstream execution. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_effect`, `add_effect_rc`, `get_effect_by_index`, `get_effect_by_name`, `remove_by_index`, and 4 more stays attached to the local data model and invariants.
- Delivers the per-target composition layer for reusable shader effect application. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- Provides the high-level visual effects module boundary for post-processing composition and runtime control. `effect/mod` is the effect module index, declaring `draw`, `effect`, `effect_type`, `image_effect`, `presets`, and 2 more so agents can identify which files own each feature slice before opening implementation code.
- Connects effect instances, stacks, presets, and renderer integration into one coherent pipeline surface. `src/effect/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `effect::PostFxEffect`, `effect_type::PostFxEffectType`, `image_effect::ImageEffect`, `presets::{build_preset, preset_names, EffectPreset}`, and 2 more centralized for the effect subsystem.
- Delivers a data-driven effect orchestration layer that scripts and systems can configure predictably. The file documents how effect submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- `effect/mod` is the effect module index, declaring `draw`, `effect`, `effect_type`, `image_effect`, `presets`, and 2 more so agents can identify which files own each feature slice before opening implementation code.
- `src/effect/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `effect::PostFxEffect`, `effect_type::PostFxEffectType`, `image_effect::ImageEffect`, `presets::{build_preset, preset_names, EffectPreset}`, and 2 more centralized for the effect subsystem.
- The file documents how effect submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

### presets.rs

- Provides built-in post-effect presets that package curated visual moods into ready-to-use chains. `effect/presets` delivers the presets implementation for the effect subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Builds effect sets with viewport-aware stack initialization for immediate runtime application. The file owns or coordinates data contracts including `EffectPreset`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Exposes canonical preset names so scripts can select consistent looks with stable identifiers. Public callable behavior is centered on `preset_names`, `build_preset`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Encapsulates preset assembly logic to keep stylistic recipes centralized and reusable. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### render.rs

- Provides render-command generation for post-effect capture and application flows. `effect/render` delivers the rendering adapter and draw-command integration for the effect subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Emits deterministic begin, end, and apply command sequences consumed by the renderer. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Delivers no-op behavior when stacks have no active effects to process. Public callable behavior is centered on no named public items, while method-level behavior such as `begin_capture_command`, `end_capture_command`, `apply_command`, `generate_render_commands` stays attached to the local data model and invariants.

### stack.rs

- Provides ordered post-effect stack management with per-entry enable state and target dimensions. `effect/stack` delivers the stack implementation for the effect subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores effect references in application order while preserving synchronized activation flags. The file owns or coordinates data contracts including `PostFxStack`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports insertion, removal, reordering, and dedup operations for dynamic runtime composition. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add`, `remove`, `insert`, `set_enabled`, `is_enabled`, and 17 more stays attached to the local data model and invariants.
- Exposes query helpers that report active subsets and positional stack metadata. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Includes stack-introspection render helpers for debugging and visual tooling overlays. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.



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
