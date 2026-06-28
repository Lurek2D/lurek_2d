<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/effect.md or source docstrings instead. -->

# effect

## TL;DR

- Manages visual post-processing stacks, shader parameters, and presets.
- Coordinates capture boundaries, image effect chains, and diagnostics.

## General Info

- Module group: `Platform Services`
- Source path: `src/effect`
- Binding: `src/lua_api/effect_api.rs`
- Namespace: `lurek.effect`
- Lua API surface: `10` functions, `3` types, `62` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- The `effect` module is the post-processing surface for users who want final-frame styling to be configurable at runtime instead of buried in renderer internals.
- Effect stacks, presets, and parameter control let projects combine blur, bloom, grading, distortion, and custom passes as a reusable look pipeline rather than as isolated toggles.
- The same module supports both full-frame and image-scoped workflows, which makes it useful for global scene mood, local asset treatment, and diagnostic capture flows.
- Runtime enabling, disabling, and reordering matter because visual iteration often depends on trying combinations quickly while the game is running.
- Preset-oriented workflow is a major user-facing advantage because art direction usually depends on named looks that can be switched, blended, or tuned per scene instead of rebuilt from scratch each time.
- That makes the module valuable for shipped presentation, look development, and visual comparison.
- It is especially useful when several passes need to be staged and tuned together as one style decision.
- It also keeps composition policy above the renderer, so projects can adjust how global and local treatments are assembled without rewriting low-level pass code.
- Read `effect` as the owner of effect composition and art-direction control. The renderer executes passes, but `effect` defines how those passes are organized and tuned from the user side.

This module primarily collaborates with `image`, `overlay`, `render`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/effect`
- Owning tier: `Platform Services`
- Plugin tier: `core_keep`
- Lua binding owner: `src/lua_api/effect_api.rs`
- Referenced engine modules: `image`, `overlay`, `render`, `runtime`

## Imports

- `image`: Imports or references `src/image/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `overlay`: Imports or references `src/overlay/`. Cross-group dependency from `Platform Services` into `Feature Systems`.
- `render`: Imports or references `src/render/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Platform Services` into `Core Runtime`.

## Source Files

### contract.rs

- Owns the contract surface for the effect subsystem and keeps its rules local to this file.
- Keeps effect data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how contract data is validated, transformed, or stored before neighboring systems use it.
- Owns effect behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on contract behavior while Lua registration stays elsewhere.
- Documents the boundary where effect code accepts inputs, reports errors, or updates state.
- Use this file when changing contract defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the effect state that can explain them while keeping call sites explicit.

### draw.rs

- This file owns the lightweight `PostFxStack` preview renderer that turns stack activity into a diagnostic image.
- It fills a simple image differently when any effect is enabled, giving tools a cheap visual state indicator.
- Open this file when effect-stack preview semantics change; stack storage and render commands live in siblings.

### effect.rs

- Owns the effect owner for the effect subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around PostFxEffect, new, new_custom, with helpers kept close to their invariants.
- Defines how effect data is validated, transformed, or stored before neighboring systems use it.
- Owns effect behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on effect behavior while Lua registration stays elsewhere.
- Documents the boundary where effect code accepts inputs, reports errors, or updates state.

### effect_type.rs

- This file owns `PostFxEffectType`, the canonical catalog of built-in and custom post-processing identities.
- It maps stable lowercase names to enum variants so scripts and engine code resolve the same effect repertoire.
- Debug labels and built-in-name helpers centralize human-readable identifiers without duplicating lookup tables.
- Default-parameter builders also live here, giving each effect type a consistent scalar starting configuration.
- The enum separates built-in effects from custom shaders while preserving one shared naming and parsing surface.
- Open this file when supported effect kinds change; per-instance state and preset recipes live in sibling files.

### image_effect.rs

- Owns the image effect owner for the effect subsystem and keeps its rules local to this file.
- Centers the implementation around ImageEffect, new, add_effect, with helpers kept close to their invariants.
- Defines how image effect data is validated, transformed, or stored before neighboring systems use it.
- Owns effect behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on image effect behavior while Lua registration stays elsewhere.

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

- Owns effect behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps effect data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how render data is validated, transformed, or stored before neighboring systems use it.
- Owns effect behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on render behavior while Lua registration stays elsewhere.

### stack.rs

- Owns the stack owner for the effect subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around PostFxStack, new, try_new, with helpers kept close to their invariants.
- Defines how stack data is validated, transformed, or stored before neighboring systems use it.
- Owns effect behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on stack behavior while Lua registration stays elsewhere.
- Documents the boundary where effect code accepts inputs, reports errors, or updates state.
- Use this file when changing stack defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the effect state that can explain them while keeping call sites explicit.



## Lua API Ref

### Functions

- `lurek.effect.getEffectTypes() -> string[]`: Returns all built-in post-processing effect type names.
- `lurek.effect.getPresetNames() -> string[]`: Returns all built-in post-processing preset names.
- `lurek.effect.getShaderErrorDisplay() -> boolean`: Returns whether renderer shader error display overlays are enabled.
- `lurek.effect.newCustomEffect(shader) -> LPostFxEffect`: Creates a custom post-processing effect from a postfx-target shader.
- `lurek.effect.newEffect(type_name) -> LPostFxEffect`: Creates a built-in post-processing effect by type name.
- `lurek.effect.newImageEffect(spec?, params?) -> LImageEffect`: Creates an image effect chain from no arguments, a type name and optional parameters, or a chain table.
- `lurek.effect.newPass(shader) -> LPostFxEffect`: Creates a custom post-processing pass from a postfx-target shader.
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

## Examples

- `content/examples/effect.lua` (present)

## Architecture Links

- `docs/architecture/module-scope-boundaries.md`
- `docs/architecture/effects-particles-overlay-plan.md`

## Notes

- Ownership boundary:
  `effect` owns post-processing effect kinds, parameter schemas, stack ordering, presets, capture/apply orchestration, custom shader pass descriptors, and image-scoped post-fx chains. It must not own weather, flash, fade, shake, ambient, or other scene-wide presentation policy; those belong to `overlay`.
- Built-in post-fx parameters are schema-validated before they are accepted or emitted to render commands. Unknown built-in parameter names are rejected, non-finite values are rejected, and integer-like params such as `motionblur.samples`, `pixelate.block_size`, and `dither.palette_size` must stay whole-numbered and in range.
- Built-in game-style post-fx include CRT/scanlines, pixelate, sepia, chromatic aberration, bloom, blur, vignette, noise, grayscale, invert, hue shift, edge detect, god rays, water distortion, sharpen, dither, outline, depth of field, and motion blur. Presets such as `retro_tv` compose these into named looks; custom `target = "postfx"` WGSL passes are for project-specific effects beyond the built-ins, including screen transitions such as wipe, dissolve, and fade-mask passes over a canvas or captured scene.
- `PostFxStack` dimensions are part of the module contract. Rust callers can use `try_new` and `try_resize` for strict validation, while legacy constructors sanitize dimensions into the configured safe range instead of forwarding zero-sized targets.
- Stack planning now resolves explicit renderer `PostFxPass` descriptors from enabled effects. Stale stack indices, invalid custom shader ids, empty resolved pass lists, and duplicate indices are surfaced through `PostFxDiagnostics` instead of silently producing an empty `ApplyPostFx`.
- Duplicate stack entries are allowed by default but reported as warnings through the stack duplicate policy. Callers that want stricter behavior can switch the policy to disallow duplicates before validation or render planning.
- Custom post-fx auto uniforms use the documented contract snapshot `time`, `resolution`, `texel_size`, `frame_index`, and `stack_index`. The `auto_uniforms` flag only opts a pass into that fixed set; it does not imply arbitrary shader reflection.
- Debug image helpers now have explicit `try_draw_*` variants guarded by `PostFxDebugImageLimits` so tooling can reject oversized diagnostic images deterministically.
- Legacy overlay exports under `effect` are compatibility edges only. New Lua/API examples should use `lurek.overlay` for overlay state and `lurek.effect` for post-fx stacks or shader passes.
