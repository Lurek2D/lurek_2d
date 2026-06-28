<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/light.md or source docstrings instead. -->

# light

## TL;DR

- Manages point, spot, and directional lights with custom decay falloffs and groups.
- Coordinates convex polygon occluders, shadow masks, flicker, and transitions.

## General Info

- Module group: `Platform Services`
- Source path: `src/light`
- Binding: `src/lua_api/light_api.rs`
- Namespace: `lurek.light`
- Lua API surface: `22` functions, `4` types, `81` methods
- User-facing: `true`
- Plugin tier: `core_keep`

## Summary

- The `light` module is the engine's shared 2D lighting-data surface for users who need lights, occluders, shadows, and illumination behavior to remain structured before rendering.
- It lets scripts reason about lighting as scene data instead of raw draw commands by grouping light types, falloff, attenuation, blend modes, occlusion, and shadow-related state in one model.
- This matters because atmosphere, visibility, stealth cues, alarms, and scene readability often depend on several changing lights at once.
- Flicker, ramps, fades, and other transitions are part of the contract because lighting is usually dynamic rather than fixed at load time.
- Light-world organization matters too, since several systems may contribute lights and occluders to the same scene and still need one inspectable runtime authority.
- Blend and attenuation semantics are especially important because they control not only whether a light exists, but how strongly it influences surrounding space and how several lights combine visually.
- Occluder-aware behavior is equally important because lights only become useful for scene reasoning when blocking and shadow semantics are modeled alongside them.
- This lets the same subsystem support both atmosphere and gameplay readability, since visibility cues often depend on how light is shaped by world geometry rather than on color alone.
- It also gives tools a stable light-world model to inspect.
- That shared data layer matters whenever gameplay, art direction, and debugging all need to read the same light setup.
- `render` draws the final result, but `light` owns how 2D light entities, falloff, and occlusion semantics are represented together.
- Read `light` as the owner of light definitions and light-world state inside the engine.

This module primarily collaborates with `color`, `image`, `math`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/light`
- Owning tier: `Platform Services`
- Plugin tier: `core_keep`
- Lua binding owner: `src/lua_api/light_api.rs`
- Referenced engine modules: `color`, `image`, `math`, `runtime`

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Foundations`.
- `image`: Imports or references `src/image/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `math`: Imports or references `src/math/`. Cross-group dependency from `Platform Services` into `Foundations`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Platform Services` into `Core Runtime`.

## Source Files

### attenuation.rs

- This file owns `Attenuation`, the quadratic distance-decay model used by lights to scale brightness over range.
- It stores constant, linear, and quadratic coefficients, then evaluates a stable inverse denominator factor.
- A debug image helper also plots multiple attenuation curves so designers can inspect and tune falloff behavior.
- Open this file when distance-decay semantics change; full light objects and world ownership live in siblings.

### blend_mode.rs

- This file owns `LightBlendMode`, the enum that describes how one light contributes to the accumulated buffer.
- It defines additive, subtractive, and mix-style compositing so light accumulation policy stays explicit in data.
- Open this file when light compositing semantics change; per-light state and world processing live in siblings.

### falloff.rs

- This file owns `FalloffMode`, the enum that shapes radial brightness inside a light's effective radius.
- It distinguishes linear, smooth, and constant profiles so lights can vary edge softness without new code paths.
- Open this file when radial falloff semantics change; attenuation math and full light state live in sibling files.

### flicker.rs

- This file owns `FlickerConfig`, the sine-based animation state that modulates light intensity over time.
- It stores enabled state, speed, strength, and phase, then advances deterministically for frame-driven updates.
- Multiplier and advance helpers keep temporal variation local so worlds can animate many lights consistently.
- Open this file when flicker behavior changes; full light ownership and batch stepping live in sibling modules.

### light2d.rs

- This file owns `Light2D` and its patch structs, the complete per-light data model used by the lighting system.
- It stores transform, radius, color, energy, attenuation, masks, shadows, type, flicker, grouping, and normal-map data.
- Constructor defaults create a ready point light, while many getters and setters expose stable field-level control.
- `Light2DOptionsPatch` and `Light2DAttenuationPatch` let callers update selected options without rebuilding a light.
- Spot angles, shadow settings, volumetrics, blend mode, falloff, and attenuation all live in this one ownership unit.
- Debug rendering for falloff comparisons also lives here because it depends on the same light-specific option semantics.
- This file is the boundary for one light's authored and runtime state, not for scene collection orchestration.
- Open it when per-light option semantics change; world storage and occluder ownership live in sibling files.

### light_type.rs

- This file owns `LightType`, the geometric light-kind enum used to distinguish point, directional, and spot lights.
- It keeps illumination shape explicit inside `Light2D` so worlds and renderers branch on one stable discriminant.
- Open this file when supported light geometries change; shadow, falloff, and world behavior live in siblings.

### light_world.rs

- Owns the light world owner for the light subsystem and keeps its rules local to this file.
- Keeps light data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how light world data is validated, transformed, or stored before neighboring systems use it.
- Owns light behavior with explicit state, validation, and crate-local integration boundaries.
- Keeps public crate helpers focused on light world behavior while Lua registration stays elsewhere.
- Documents where light callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
- Use this file when changing light world defaults, lifecycle handling, validation, or data ownership.
- Keeps failure paths and edge cases near the light state that can explain them while keeping call sites explicit.

### mod.rs

- This module re-exports the lighting subsystem surface for light types, falloff, shadows, occluders, and world state.
- It serves as the navigation map for per-light data, attenuation rules, group control, and renderer-facing hints.
- `light2d.rs` owns the full light object, while `light_world.rs` manages scene collections and batch operations.
- `attenuation.rs`, `falloff.rs`, `flicker.rs`, and `transition.rs` describe how light output changes over time or space.
- `occluder.rs`, `shadow.rs`, `blend_mode.rs`, and `light_type.rs` define masking, filtering, and compositing choices.
- Change this file when the public light symbol map moves; change siblings when runtime lighting behavior changes.

### occluder.rs

- This file owns `Occluder`, the convex polygon shadow caster used by `LightWorld` to block and mask lighting.
- It stores local vertices, world offset, opacity, layer mask, and enabled state for runtime shadow participation.
- Construction helpers validate vertex counts and support both typed point lists and flat coordinate arrays.
- Tracks geometry generations so render caches can reuse transformed edge data until shadow geometry changes.
- Open this file when shadow-geometry semantics change; light collection logic and filter presets live in siblings.

### shadow.rs

- This file owns `ShadowFilter`, the preset enum that selects soft-shadow kernel quality for light rendering paths.
- It distinguishes no filtering, five-tap PCF, and thirteen-tap PCF so shadow softness cost stays explicit in data.
- Open this file when shadow-filter semantics change; per-light state and occluder ownership live in sibling files.

### transition.rs

- This file owns `LightTransition`, the linear tween state used to animate light color, intensity, and radius.
- It stores from and to values plus elapsed time and duration, then computes clamped per-frame interpolated output.
- Update and progress helpers keep transition timing deterministic and local to light-animation orchestration code.
- Open this file when light tween semantics change; flicker behavior and scene ownership live in sibling modules.



## Lua API Ref

### Functions

- `lurek.light.advanceFlickers(dt) -> nil`: Advances flicker animation for all indexed flickering lights.
- `lurek.light.clear() -> nil`: Removes all lights and occluders from the light world.
- `lurek.light.drawToImage(width, height) -> LImageData`: Renders an approximate light-map preview of this world into an ImageData.
- `lurek.light.getAmbient() -> number`: Returns global ambient light color.
- `lurek.light.getGodRayHints() -> table`: Returns directional light hints for god-ray style effects.
- `lurek.light.getGroupCount(group_id) -> integer`: Returns the number of lights in a group.
- `lurek.light.getLightCount() -> integer`: Returns the number of live lights. This function is exposed to Lua scripts.
- `lurek.light.getMaxLights() -> integer`: Returns the maximum configured light count.
- `lurek.light.getNormalMapHints() -> table`: Returns light hints that reference normal maps.
- `lurek.light.getOccluderCount() -> integer`: Returns the number of live occluders.
- `lurek.light.getShader() -> LShader?`: Returns the default custom light shader for the light world.
- `lurek.light.isEnabled() -> boolean`: Returns whether the shared light world is enabled.
- `lurek.light.newLight(x, y, radius, opts?) -> LLight`: Creates a light and applies optional light settings.
- `lurek.light.newOccluder(vtbl, opts?) -> LOccluder`: Creates an occluder from a flat vertex coordinate table and optional settings.
- `lurek.light.setAmbient(r, g, b, a?) -> nil`: Sets global ambient light color. This function is exposed to Lua scripts.
- `lurek.light.setEnabled(enabled) -> nil`: Enables or disables the shared light world.
- `lurek.light.setGroupColor(group_id, r, g, b, a?) -> nil`: Sets color for all lights in a group.
- `lurek.light.setGroupEnabled(group_id, enabled) -> nil`: Enables or disables all lights in a group.
- `lurek.light.setGroupIntensity(group_id, intensity) -> nil`: Sets intensity for all lights in a group.
- `lurek.light.setMaxLights(n) -> nil`: Sets the maximum configured light count, clamped to 1 through 256.
- `lurek.light.setShader(shader?) -> nil`: Sets or clears the default custom light shader for the light world.
- `lurek.light.syncAmbient() -> number`: Returns the light world's ambient color hint.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LLight Type

- Lua-side handle for a light stored in the shared light world.

##### Fields

- No documented fields.

##### Methods

- `LLight:addFlicker(min, max, hz) -> nil`: Adds flicker from min/max intensity range and frequency.
- `LLight:clearCookie() -> nil`: Clears the cookie texture path stored on this Lua light handle.
- `LLight:clearNormalMap() -> nil`: Clears the normal map path used by this light.
- `LLight:getAttenuation() -> number`: Returns this light attenuation coefficients.
- `LLight:getBlendMode() -> string`: Returns this light blend mode string.
- `LLight:getColor() -> number`: Returns this light RGBA color. This method is available to Lua scripts.
- `LLight:getCookie() -> string`: Returns the cookie texture path stored on this Lua light handle.
- `LLight:getDirection() -> number`: Returns this light direction angle.
- `LLight:getEnergy() -> number`: Returns this light energy value. This method is available to Lua scripts.
- `LLight:getFalloff() -> string`: Returns this light falloff mode string.
- `LLight:getFlicker() -> number`: Returns this light flicker speed and strength.
- `LLight:getGroupId() -> integer`: Returns this light group id. This method is available to Lua scripts.
- `LLight:getInnerAngle() -> number`: Returns this spot light inner cone angle.
- `LLight:getIntensity() -> number`: Returns this light intensity. This method is available to Lua scripts.
- `LLight:getLightMask() -> integer`: Returns this light's inclusion mask.
- `LLight:getLightType() -> string`: Returns this light type string. This method is available to Lua scripts.
- `LLight:getNormalMap() -> string`: Returns the normal map path used by this light.
- `LLight:getNormalStrength() -> number`: Returns this light's normal map strength.
- `LLight:getOuterAngle() -> number`: Returns this spot light outer cone angle.
- `LLight:getPosition() -> number`: Returns this light position. This method is available to Lua scripts.
- `LLight:getRadius() -> number`: Returns this light radius. This method is available to Lua scripts.
- `LLight:getShader() -> LShader?`: Returns the custom light shader bound to this light, if any.
- `LLight:getShadowColor() -> number`: Returns this light shadow RGBA color.
- `LLight:getShadowFilter() -> string`: Returns this light shadow filter string.
- `LLight:getShadowMask() -> integer`: Returns this light's shadow receiver mask.
- `LLight:getShadowSmooth() -> number`: Returns this light shadow smoothing value.
- `LLight:getShadowSoftness() -> number`: Returns this light shadow softness value.
- `LLight:isEnabled() -> boolean`: Returns whether this light is enabled.
- `LLight:isFlickerEnabled() -> boolean`: Returns whether this light flicker is enabled.
- `LLight:isShadowEnabled() -> boolean`: Returns whether this light casts shadows.
- `LLight:isValid() -> boolean`: Returns whether this light handle still points to a live light.
- `LLight:isVolumetric() -> boolean`: Returns whether this light is volumetric.
- `LLight:remove() -> nil`: Removes this light from the shared light world.
- `LLight:setAttenuation(c, l, q) -> nil`: Sets this light attenuation coefficients.
- `LLight:setBlendMode(mode) -> nil`: Sets this light blend mode. This method is available to Lua scripts.
- `LLight:setColor(r, g, b, a?) -> nil`: Sets this light RGBA color. This method is available to Lua scripts.
- `LLight:setCookie(path) -> nil`: Stores a cookie texture path on this Lua light handle.
- `LLight:setDirection(dir) -> nil`: Sets this light direction angle. This method is available to Lua scripts.
- `LLight:setEnabled(b) -> nil`: Enables or disables this light. This method is available to Lua scripts.
- `LLight:setEnergy(e) -> nil`: Sets this light energy value. This method is available to Lua scripts.
- `LLight:setFalloff(mode) -> nil`: Sets this light falloff mode. This method is available to Lua scripts.
- `LLight:setFlicker(speed, strength) -> nil`: Configures flicker speed and strength for this light.
- `LLight:setFlickerEnabled(b) -> nil`: Enables or disables this light flicker state.
- `LLight:setGroupId(id) -> nil`: Sets this light group id. This method is available to Lua scripts.
- `LLight:setInnerAngle(a) -> nil`: Sets this spot light inner cone angle.
- `LLight:setIntensity(i) -> nil`: Sets this light intensity. This method is available to Lua scripts.
- `LLight:setLightMask(mask) -> nil`: Sets this light's inclusion mask. This method is available to Lua scripts.
- `LLight:setLightType(t) -> nil`: Sets this light type. This method is available to Lua scripts.
- `LLight:setNormalMap(path) -> nil`: Sets the normal map path used by this light.
- `LLight:setNormalStrength(strength) -> nil`: Sets this light's normal map strength.
- `LLight:setOuterAngle(a) -> nil`: Sets this spot light outer cone angle.
- `LLight:setPosition(x, y) -> nil`: Sets this light position. This method is available to Lua scripts.
- `LLight:setRadius(r) -> nil`: Sets this light radius. This method is available to Lua scripts.
- `LLight:setShader(shader?) -> nil`: Sets or clears the custom light-contribution shader for this light.
- `LLight:setShadowColor(r, g, b, a?) -> nil`: Sets this light shadow RGBA color. This method is available to Lua scripts.
- `LLight:setShadowEnabled(b) -> nil`: Enables or disables shadow casting for this light.
- `LLight:setShadowFilter(filter) -> nil`: Sets this light shadow filter. This method is available to Lua scripts.
- `LLight:setShadowMask(mask) -> nil`: Sets this light's shadow receiver mask.
- `LLight:setShadowSmooth(s) -> nil`: Sets this light shadow smoothing value.
- `LLight:setShadowSoftness(softness) -> nil`: Sets this light shadow softness value.
- `LLight:setVolumetric(b) -> nil`: Enables or disables volumetric behavior for this light.
- `LLight:stopTransition() -> nil`: Stops and clears this light's active transition.
- `LLight:transitionProgress() -> number`: Returns active transition progress or 1.0 when no transition is active.
- `LLight:transitionTo(target, duration) -> nil`: Starts a transition toward target color, intensity, and radius values.
- `LLight:type() -> string`: Returns the Lua-visible type name for this light handle.
- `LLight:typeOf(name) -> boolean`: Returns whether this light handle matches a supported type name.
- `LLight:updateTransition(dt) -> boolean`: Advances this light's active transition and applies interpolated values.

#### LLightGetGodRayHintsResult Type

- Generated result shape from @field tags.

##### Fields

- `angle` (`number`): Hint angle in radians.
- `x` (`number`): Hint x position.
- `y` (`number`): Hint y position.

##### Methods

- No documented methods.

#### LLightGetNormalMapHintsResult Type

- Generated result shape from @field tags.

##### Fields

- `direction` (`number`): Hint direction.
- `intensity` (`number`): Hint intensity.
- `normalMap` (`string`): Normal map asset path.
- `radius` (`number`): Hint radius.
- `strength` (`number`): Normal map strength.
- `x` (`number`): Hint x position.
- `y` (`number`): Hint y position.

##### Methods

- No documented methods.

#### LOccluder Type

- Lua-side handle for an occluder stored in the shared light world.

##### Fields

- No documented fields.

##### Methods

- `LOccluder:getLightMask() -> integer`: Returns this occluder's light mask.
- `LOccluder:getOpacity() -> number`: Returns this occluder opacity. This method is available to Lua scripts.
- `LOccluder:getPosition() -> number`: Returns this occluder position offset.
- `LOccluder:getVertices() -> number[]`: Returns this occluder's flat vertex coordinate list.
- `LOccluder:isEnabled() -> boolean`: Returns whether this occluder is enabled.
- `LOccluder:isValid() -> boolean`: Returns whether this occluder handle still points to a live occluder.
- `LOccluder:remove() -> nil`: Removes this occluder from the shared light world.
- `LOccluder:setEnabled(b) -> nil`: Enables or disables this occluder.
- `LOccluder:setLightMask(mask) -> nil`: Sets this occluder's light mask. This method is available to Lua scripts.
- `LOccluder:setOpacity(o) -> nil`: Sets this occluder opacity. This method is available to Lua scripts.
- `LOccluder:setPosition(x, y) -> nil`: Sets this occluder position offset.
- `LOccluder:setVertices(tbl) -> nil`: Replaces this occluder's flat vertex coordinate list.
- `LOccluder:type() -> string`: Returns the Lua-visible type name for this occluder handle.
- `LOccluder:typeOf(name) -> boolean`: Returns whether this occluder handle matches a supported type name.

## Examples

- `content/examples/light.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_light_unit.lua` (present)
- Rust: `src/light/light_type.rs`
- Rust: `src/light/light_world.rs`
- Rust: `tests/rust/unit/light_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_light_evidence.lua` |
| Golden test | `tests/lua/golden/test_light_golden.lua` |
| Current artifact | `tests/artifacts/current/light/light_color_mix.png` |
| Current artifact | `tests/artifacts/current/light/light_cone_spotlight.png` |
| Current artifact | `tests/artifacts/current/light/light_falloff.png` |
| Current artifact | `tests/artifacts/current/light/light_group_transition_flicker_trace.txt` |
| Current artifact | `tests/artifacts/current/light/light_normal_map.png` |
| Current artifact | `tests/artifacts/current/light/light_occluder_left.png` |
| Current artifact | `tests/artifacts/current/light/light_occluder_right.png` |
| Current artifact | `tests/artifacts/current/light/light_shadow_occlusion.png` |
| Current artifact | `tests/artifacts/current/light/light_spotlight_sweep.gif` |
| Current artifact | `tests/artifacts/current/light/light_vending_machine_occlusion.png` |
| Baseline artifact | `tests/artifacts/baselines/light/light_color_mix.png` |
| Baseline artifact | `tests/artifacts/baselines/light/light_cone_spotlight.png` |
| Baseline artifact | `tests/artifacts/baselines/light/light_falloff.png` |
| Baseline artifact | `tests/artifacts/baselines/light/light_normal_map.png` |
| Baseline artifact | `tests/artifacts/baselines/light/light_shadow_occlusion.png` |
| Baseline artifact | `tests/artifacts/baselines/light/light_spotlight_sweep.gif` |

## Architecture Links

- Intentionally empty.

## Notes

- `lurek.light` is the 2D render-light and occluder module: point/spot/directional scene lights, render occluders, shadow masks, and visual light-world state.
- Custom light shaders are render-time contribution shaders. `LLight:setShader(shader)` and `lurek.light.setShader(shader)` accept only `target = "light"` WGSL and can modify falloff, rim/highlight, color grading, normal-map influence, ambient blending, and shadow response. Shadow casting geometry, occluder masks, and tile lighting remain engine-owned.
- Normal-map data reaches custom light shaders as a compact contribution hint derived from `setNormalMap`, `setNormalStrength`, and light direction. The hint is zero when no normal map is configured.
- `lurek.tilefield` owns the tile data consumed by tile lighting: per-tile `"light"` blockers, transmission costs, and multilevel sun occlusion.
- `lurek.tilelight` owns tile-based environment lighting: grid point lights, ambient light, global top light, and computed RGB/luma layers.
- Do not use `lurek.light` as the source of truth for tile movement, sight, action, or tile-light gameplay semantics.
