# light

## TL;DR

- Manages point, spot, and directional lights with custom decay falloffs and groups.
- Coordinates convex polygon occluders, shadow masks, flicker, and transitions.

## General Info

- Module group: `Platform Services`
- Source path: `src/light/`
- Binding: `src/lua_api/light_api.rs`
- Namespace: `lurek.light`
- Lua API surface: `20` functions, `4` types, `79` methods
- Rust test path(s): tests/rust/unit/light_tests.rs
- Lua test path(s): tests/lua/unit/test_light_unit.lua, tests/lua/stress/test_light_stress.lua, tests/lua/evidence/test_light_evidence.lua

## Summary

- This module gives users dynamic 2D lighting and shadow control for mood, readability, and gameplay signaling.
- It supports point, spot, and directional light types with configurable intensity and color behavior.
- Attenuation and falloff controls let teams tune how light fades across distance.
- Blend modes support additive and subtractive composition for different visual styles.
- Ambient controls provide scene-wide baseline illumination.
- Group operations allow bulk edits to sets of lights during state transitions.
- Flicker and transition helpers support animated lighting effects without custom per-frame math.
- Shadow casting uses polygon occluders for geometry-driven blocking behavior.
- Shadow masks and receiver masks provide control over which objects interact with which lights.
- Filter settings support quality/performance trade-offs for hard and softened shadows.
- Normal-map hinting and volumetric-adjacent settings help integrate richer shading workflows.
- Light-world APIs centralize creation, mutation, and cleanup of runtime light entities.
- Preview-to-image utilities support debug and evidence workflows for visual validation.
- The module is useful for stealth, atmosphere, navigation cues, and dramatic scene transitions.
- For users, it turns lighting from static art into a controllable gameplay system.
- It reduces custom lighting glue code while keeping behavior script-driven.
- The practical result is faster lighting iteration and clearer visual feedback loops.
- It also improves testability by exposing deterministic controls and introspection-friendly outputs.
- Overall, users get a comprehensive 2D illumination toolkit integrated with runtime scripting.
- This helps teams balance style, performance, and legibility in one place.

This module primarily collaborates with `color`, `image`, `math`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### attenuation.rs

- Quadratic attenuation model encapsulating distance-based light intensity falloff using constant, linear, and quadratic coefficients.
- Computes attenuation factors (1.0 / denominator) at arbitrary distances enabling physically-plausible light contribution evaluation in shaders.
- Prevents division-by-zero at zero distance by clamping denominator to >= 1.0 ensuring stable light brightness at light source origin.
- Includes debug visualization rendering attenuation curves to image buffers for interactive tuning of falloff behavior during lighting design.

### blend_mode.rs

- Defines compositing modes that control how each light contribution merges into accumulated lighting. `light/blend_mode` delivers the blend mode implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### falloff.rs

- Defines radial falloff profiles that shape brightness between light center and radius boundary. `light/falloff` delivers the falloff implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### flicker.rs

- Defines sine-based flicker state that modulates light intensity across time. `light/flicker` delivers the flicker implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Tracks oscillation phase, speed, and strength for controllable temporal variation. The file owns or coordinates data contracts including `FlickerConfig`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports deterministic per-frame advancement with wrapped phase continuity. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `multiplier`, `advance` stays attached to the local data model and invariants.

### light2d.rs

- Defines the full per-light data model covering transform, color, energy, and shading behavior. `light/light2d` delivers the light2d implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Encapsulates light geometry, blend mode, falloff, attenuation, and layer-mask participation. The file owns or coordinates data contracts including `Light2DAttenuationPatch`, `Light2DOptionsPatch`, `Light2D`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Stores spot-cone, shadow, normal-map, and volumetric options in one configurable runtime object. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `set_position`, `get_position`, `set_radius`, `get_radius`, `set_color`, and 48 more stays attached to the local data model and invariants.
- Provides constructor defaults tuned for immediate point-light usage without extra setup. Runtime integration reaches sibling engine areas through crate modules `color`, `light`, `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Exposes field access patterns used by world management and Lua-facing controls. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Supports optional flicker and grouping metadata for batched animation and edits. The file boundary separates light implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### light_type.rs

- Defines geometric light models used by the 2D lighting pipeline. `light/light_type` delivers the light type implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### light_world.rs

- Implements scene-level light management for `Light2D` and occluder collections keyed by stable handles. `light/light_world` delivers the light world implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports creation, removal, lookup, and bulk mutation of lighting entities across runtime updates. The file owns or coordinates data contracts including `LightWorld`, `NormalMapLightHint`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Applies group-based operations for coordinated enable, color, and intensity adjustments. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_light`, `add_occluder`, `remove_light`, `remove_occluder`, `get_light`, and 17 more stays attached to the local data model and invariants.
- Advances active flicker states efficiently to animate selected lights over time. Runtime integration reaches sibling engine areas through crate modules `color`, `light`, `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Exposes renderer-oriented snapshots such as ambient terms and directional data aggregates. External integration uses `slotmap`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### mod.rs

- High-level lighting module that groups light types, occluders, world state, and transition utilities. `light/mod` is the light module index, declaring `attenuation`, `blend_mode`, `falloff`, `flicker`, `light2d`, and 5 more so agents can identify which files own each feature slice before opening implementation code.
- Re-exports core enums and structs used to configure 2D illumination behavior across the engine. `src/light/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `attenuation::Attenuation`, `blend_mode::LightBlendMode`, `falloff::FalloffMode`, `flicker::FlickerConfig`, and 5 more centralized for the light subsystem.
- Defines the module boundary for attenuation, blending, shadows, and runtime light orchestration. The file documents how light submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- `light/mod` is the light module index, declaring `attenuation`, `blend_mode`, `falloff`, `flicker`, `light2d`, and 5 more so agents can identify which files own each feature slice before opening implementation code.
- `src/light/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `attenuation::Attenuation`, `blend_mode::LightBlendMode`, `falloff::FalloffMode`, `flicker::FlickerConfig`, and 5 more centralized for the light subsystem.
- The file documents how light submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

### occluder.rs

- Defines convex polygon occluders that block light and contribute to shadow casting. `light/occluder` delivers the occluder implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores local vertices with world offset and opacity controls for flexible scene placement. The file owns or coordinates data contracts including `Occluder`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports runtime vertex replacement from typed points or flat coordinate inputs. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `set_vertices`, `from_flat_coords`, `get_vertices`, `set_position`, `get_position`, and 6 more stays attached to the local data model and invariants.
- Applies layer-mask and enable flags to scope occluder influence across light groups. Runtime integration reaches sibling engine areas through crate modules `math`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### shadow.rs

- Defines shadow filtering quality presets used by soft-shadow evaluation paths. `light/shadow` delivers the shadow implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### transition.rs

- Implements time-based linear transitions for light color, intensity, and radius values. `light/transition` delivers the transition implementation for the light subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Tracks elapsed progress against duration to produce deterministic interpolated states. The file owns or coordinates data contracts including `LightTransition`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Clamps timing parameters to safe bounds for stable update behavior. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `update`, `progress` stays attached to the local data model and invariants.
- Supports per-frame stepping until transitions reach their configured targets. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.



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
- `lurek.light.isEnabled() -> boolean`: Returns whether the shared light world is enabled.
- `lurek.light.newLight(x, y, radius, opts?) -> LLight`: Creates a light and applies optional light settings.
- `lurek.light.newOccluder(vtbl, opts?) -> LOccluder`: Creates an occluder from a flat vertex coordinate table and optional settings.
- `lurek.light.setAmbient(r, g, b, a?) -> nil`: Sets global ambient light color. This function is exposed to Lua scripts.
- `lurek.light.setEnabled(enabled) -> nil`: Enables or disables the shared light world.
- `lurek.light.setGroupColor(group_id, r, g, b, a?) -> nil`: Sets color for all lights in a group.
- `lurek.light.setGroupEnabled(group_id, enabled) -> nil`: Enables or disables all lights in a group.
- `lurek.light.setGroupIntensity(group_id, intensity) -> nil`: Sets intensity for all lights in a group.
- `lurek.light.setMaxLights(n) -> nil`: Sets the maximum configured light count, clamped to 1 through 256.
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

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
