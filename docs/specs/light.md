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
- Lua test path(s): tests/lua/unit/test_light.lua, tests/lua/stress/test_light_stress.lua, tests/lua/integration/test_light_render.lua, tests/lua/evidence/test_evidence_light.lua

## Summary

This module represents the dynamic 2D illumination and shadow-casting subsystem, offering developers control over visual lighting environments. It operates a centralized light world container that manages active lights and structural occluders keyed by stable handles. By processing coordinates, global ambient colors, and light groupings, the system produces coordinated illumination layers that shape visual depth and gameplay moods in real-time.

At the heart of the light simulation are geometric models distinguishing point, spot-cone, and directional light types. Individual lights carry parameters for color, energy, and quadratic attenuation formulas that dictate how intensity decays over distance. Radial falloff profiles define custom decay curves between light centers and outer radii. These properties blend using additive or subtractive modes to compose complex, overlapping lighting maps.

To animate lighting layouts dynamically, the module includes temporal flicker modules and smooth transition helpers. Flicker units animate lights using sine-based oscillations that simulate torches, candles, or flickering neon bulbs over time. Transition systems interpolate values linearly across frame boundaries, stepping colors, intensities, and sizes toward target goals smoothly to create environmental changes.

Shadow casting is supported by convex polygon occluders that block light dynamically. Occluders carry local coordinates, enabling developers to position collision shapes and modify their opacity in real-time. Inclusion and shadow receiver masks allow developers to control which lights interact with specific occluding objects. This system features hard-shadowing or soft-shadow PCF-based filters to control both visual styling and rendering costs.

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### attenuation.rs

- Defines quadratic attenuation math controlling how light intensity decays with distance.
- Encapsulates constant, linear, and quadratic coefficients in a compact reusable configuration.
- Computes attenuation factors used by runtime light contribution evaluation.
- Includes simple visualization support for tuning falloff curve behavior.

### blend_mode.rs

- Defines compositing modes that control how each light contribution merges into accumulated lighting.
- Encodes additive, subtractive, and mixed behaviors for different artistic lighting goals.
- Provides compact blend-mode discriminants shared across lighting evaluation and rendering paths.

### falloff.rs

- Defines radial falloff profiles that shape brightness between light center and radius boundary.
- Provides linear, smooth, and constant decay modes for distinct lighting aesthetics.
- Supplies simple mode flags combined with distance attenuation during light evaluation.

### flicker.rs

- Defines sine-based flicker state that modulates light intensity across time.
- Tracks oscillation phase, speed, and strength for controllable temporal variation.
- Supports deterministic per-frame advancement with wrapped phase continuity.
- Enables torch, candle, and neon style animation without custom update code.

### light2d.rs

- Defines the full per-light data model covering transform, color, energy, and shading behavior.
- Encapsulates light geometry, blend mode, falloff, attenuation, and layer-mask participation.
- Stores spot-cone, shadow, normal-map, and volumetric options in one configurable runtime object.
- Provides constructor defaults tuned for immediate point-light usage without extra setup.
- Exposes field access patterns used by world management and Lua-facing controls.
- Supports optional flicker and grouping metadata for batched animation and edits.
- Includes debug-oriented helpers that visualize key lighting parameter effects.

### light_type.rs

- Defines geometric light models used by the 2D lighting pipeline.
- Distinguishes point, directional, and spot semantics for illumination behavior.
- Supplies compact type discriminants used during shading and shadow evaluation.

### light_world.rs

- Implements scene-level light management for `Light2D` and occluder collections keyed by stable handles.
- Supports creation, removal, lookup, and bulk mutation of lighting entities across runtime updates.
- Applies group-based operations for coordinated enable, color, and intensity adjustments.
- Advances active flicker states efficiently to animate selected lights over time.
- Exposes renderer-oriented snapshots such as ambient terms and directional data aggregates.
- Provides debug preview rasterization to inspect approximate light-map outcomes.

### mod.rs

- High-level lighting module that groups light types, occluders, world state, and transition utilities.
- Re-exports core enums and structs used to configure 2D illumination behavior across the engine.
- Defines the module boundary for attenuation, blending, shadows, and runtime light orchestration.

### occluder.rs

- Defines convex polygon occluders that block light and contribute to shadow casting.
- Stores local vertices with world offset and opacity controls for flexible scene placement.
- Supports runtime vertex replacement from typed points or flat coordinate inputs.
- Applies layer-mask and enable flags to scope occluder influence across light groups.

### shadow.rs

- Defines shadow filtering quality presets used by soft-shadow evaluation paths.
- Encodes hard-shadow and PCF-based options with different sampling costs.
- Provides a compact quality enum consumed by light shadow configuration.

### transition.rs

- Implements time-based linear transitions for light color, intensity, and radius values.
- Tracks elapsed progress against duration to produce deterministic interpolated states.
- Clamps timing parameters to safe bounds for stable update behavior.
- Supports per-frame stepping until transitions reach their configured targets.

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
