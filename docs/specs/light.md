# light

## TL;DR

- The `light` module is a comprehensive Platform Services tier component that provides a robust 2D lighting data model for Lurek2D.

## General Info

- Module group: `Platform Services`
- Source path: `src/light/`
- Lua API path(s): `src/lua_api/light_api.rs`
- Primary Lua namespace: `lurek.light`
- Rust test path(s): tests/rust/unit/light_tests.rs
- Lua test path(s): tests/lua/unit/test_light.lua, tests/lua/stress/test_light_stress.lua, tests/lua/integration/test_light_render.lua, tests/lua/evidence/test_evidence_light.lua

## Summary

It is responsible for managing point, spot, and area lights, alongside shadow-casting occluders, to create dynamic and atmospheric scene illumination. At its core, the `Light2D` struct encapsulates the properties of an individual light source, including its position, color, radius, intensity, cone angles for spot behavior, falloff curves, and procedural flicker configurations. The module is intentionally designed as a pure data management layer—it handles the logical state, grouping, and animation of lights, while the actual GPU rasterization and shader execution are deferred entirely to the `render` module.

The central orchestration of these lighting primitives is handled by the `LightWorld`. This scene-level container holds pools of active lights and `Occluder` shapes (convex polygons that block light propagation to generate shadows). It provides an efficient slotmap-backed architecture for adding, removing, and querying these entities, as well as applying batch operations like intensity or color changes across named light groups. The lighting model supports sophisticated attenuation, allowing for quadratic, linear, and inverse-square falloff models, alongside custom coefficient tuples to precisely control how light decays over distance. Blend modes (additive, subtractive, alpha-mix) dictate how each light composited into the final accumulation buffer.

Beyond static illumination, the module excels in dynamic effects. It features a robust `FlickerConfig` system that drives procedural, noise-based intensity variation over time—ideal for simulating torches, candles, or unstable neon signs. To ensure optimal performance, the flicker system utilizes a lazy-indexed advance loop that only evaluates lights with active flicker states. The module also supports time-based linear transitions for smoothly animating light color, intensity, and radius. Additionally, it offers advanced shadow filtering presets (from hard shadows to various PCF soft-shadow kernels) and normal-map integration for surface shading. The entire feature set is extensively exposed to the scripting environment via the `lurek.light.*` API.

## Files

### attenuation.rs

- Distance-based light intensity falloff using quadratic attenuation coefficients.
- Computes attenuation factor from constant, linear, and quadratic terms.
- Debug visualization of attenuation curves rendered to an image buffer.

### blend_mode.rs

- Define blend modes controlling how each light merges into the accumulation buffer.
- Support additive, subtractive, and alpha-mix compositing strategies.
- Variants: `Add` (classic glow), `Subtract` (shadow zones), `Mix` (alpha compositing).

### falloff.rs

- Radial intensity falloff shapes applied on top of distance attenuation.
- Variants control how brightness decreases from a light's center to its radius edge.
- Modes: `Linear` (default), `Smooth` (smooth-step), and `Constant` (no radial decay).

### flicker.rs

- Sine-based flicker configuration that modulates light intensity over time.
- Phase accumulates each frame and wraps at TAU for continuous oscillation.
- Strength controls peak deviation from base intensity; speed sets radians per second.
- Disabled by default; enable to animate torches, candles, or neon lights.

### light2d.rs

- Complete `Light2D` struct holding position, color, radius, type, shadow, masks, flicker, and attenuation.
- Constructor defaults to a white point light with full-layer masks and no shadows.
- Getter/setter API for every field: position, color, intensity, energy, blend mode, falloff, masks.
- Spot-light parameters: direction, inner/outer cone angles.
- Shadow controls: enable, tint color, filter preset, smooth, and softness.
- Normal-map attachment with optional path and contribution strength.
- Volumetric scattering toggle and group-id batching support.
- Debug visualization helper rendering falloff-mode comparison panels to `ImageData`.

### light_type.rs

- Define the geometric illumination models available for 2D lights.
- Discriminate between point, directional, and spot light behavior.
- Drive intensity falloff and ray direction logic in the lighting pipeline.

### light_world.rs

- Scene-level container (`LightWorld`) managing all `Light2D` instances and `Occluder` shapes via slotmaps.
- Add, remove, query, and bulk-update lights and occluders by stable keys.
- Group operations: enable/disable, intensity, and color changes on a named group ID.
- Flicker system: lazy-indexed advance loop that only touches lights with active flicker state.
- Renderer hints: ambient color array, directional light tuples, and normal-map snapshot extraction.
- Debug visualization: rasterize an approximate light-map preview into an `ImageData` bitmap.

### mod.rs

- 2D lighting system with point, spot, and area light types supporting color, falloff, and flicker.
- Shadow casting via occluder shapes with configurable filter quality.
- Light world accumulator that processes all active lights and emits composited render commands.
- Blend modes and attenuation curves for flexible intensity decay and compositing.

### occluder.rs

- Convex polygon shape that blocks light and casts shadows in the 2D lighting system.
- Vertex management: construction from Vec2 list or flat coordinate arrays, runtime replacement.
- Per-occluder properties: world position offset, shadow opacity, light-layer bitmask, enabled toggle.

### shadow.rs

- Shadow filtering quality presets for soft-shadow rendering.
- Defines PCF sample kernels at varying tap counts.
- Default is hard shadows (no filtering) for maximum performance.

### transition.rs

- Time-based linear interpolation of light color, intensity, and radius.
- Clamps duration to a safe minimum and tracks elapsed progress.
- Returns interpolated values each frame until the transition completes.

## Lua API Ref

- Binding: `src/lua_api/light_api.rs`
- Namespace: `lurek.light`

### Functions

- `lurek.light.advanceFlickers`: Advances flicker animation for all indexed flickering lights.
- `lurek.light.clear`: Removes all lights and occluders from the light world.
- `lurek.light.drawToImage`: Renders an approximate light-map preview of this world into an ImageData.
- `lurek.light.getAmbient`: Returns global ambient light color.
- `lurek.light.getGodRayHints`: Returns directional light hints for god-ray style effects.
- `lurek.light.getGroupCount`: Returns the number of lights in a group.
- `lurek.light.getLightCount`: Returns the number of live lights. This function is exposed to Lua scripts.
- `lurek.light.getMaxLights`: Returns the maximum configured light count.
- `lurek.light.getNormalMapHints`: Returns light hints that reference normal maps.
- `lurek.light.getOccluderCount`: Returns the number of live occluders.
- `lurek.light.isEnabled`: Returns whether the shared light world is enabled.
- `lurek.light.newLight`: Creates a light and applies optional light settings.
- `lurek.light.newOccluder`: Creates an occluder from a flat vertex coordinate table and optional settings.
- `lurek.light.setAmbient`: Sets global ambient light color. This function is exposed to Lua scripts.
- `lurek.light.setEnabled`: Enables or disables the shared light world.
- `lurek.light.setGroupColor`: Sets color for all lights in a group.
- `lurek.light.setGroupEnabled`: Enables or disables all lights in a group.
- `lurek.light.setGroupIntensity`: Sets intensity for all lights in a group.
- `lurek.light.setMaxLights`: Sets the maximum configured light count, clamped to 1 through 256.
- `lurek.light.syncAmbient`: Returns the light world's ambient color hint.

### Enums

- No documented module-level enums/constants.

### Types


#### LLight Type


##### Fields

- No documented fields.

##### Methods

- `LLight:addFlicker`: Adds flicker from min/max intensity range and frequency.
- `LLight:clearCookie`: Clears the cookie texture path stored on this Lua light handle.
- `LLight:clearNormalMap`: Clears the normal map path used by this light.
- `LLight:getAttenuation`: Returns this light attenuation coefficients.
- `LLight:getBlendMode`: Returns this light blend mode string.
- `LLight:getColor`: Returns this light RGBA color. This method is available to Lua scripts.
- `LLight:getCookie`: Returns the cookie texture path stored on this Lua light handle.
- `LLight:getDirection`: Returns this light direction angle.
- `LLight:getEnergy`: Returns this light energy value. This method is available to Lua scripts.
- `LLight:getFalloff`: Returns this light falloff mode string.
- `LLight:getFlicker`: Returns this light flicker speed and strength.
- `LLight:getGroupId`: Returns this light group id. This method is available to Lua scripts.
- `LLight:getInnerAngle`: Returns this spot light inner cone angle.
- `LLight:getIntensity`: Returns this light intensity. This method is available to Lua scripts.
- `LLight:getLightMask`: Returns this light's inclusion mask.
- `LLight:getLightType`: Returns this light type string. This method is available to Lua scripts.
- `LLight:getNormalMap`: Returns the normal map path used by this light.
- `LLight:getNormalStrength`: Returns this light's normal map strength.
- `LLight:getOuterAngle`: Returns this spot light outer cone angle.
- `LLight:getPosition`: Returns this light position. This method is available to Lua scripts.
- `LLight:getRadius`: Returns this light radius. This method is available to Lua scripts.
- `LLight:getShadowColor`: Returns this light shadow RGBA color.
- `LLight:getShadowFilter`: Returns this light shadow filter string.
- `LLight:getShadowMask`: Returns this light's shadow receiver mask.
- `LLight:getShadowSmooth`: Returns this light shadow smoothing value.
- `LLight:getShadowSoftness`: Returns this light shadow softness value.
- `LLight:isEnabled`: Returns whether this light is enabled.
- `LLight:isFlickerEnabled`: Returns whether this light flicker is enabled.
- `LLight:isShadowEnabled`: Returns whether this light casts shadows.
- `LLight:isValid`: Returns whether this light handle still points to a live light.
- `LLight:isVolumetric`: Returns whether this light is volumetric.
- `LLight:remove`: Removes this light from the shared light world.
- `LLight:setAttenuation`: Sets this light attenuation coefficients.
- `LLight:setBlendMode`: Sets this light blend mode. This method is available to Lua scripts.
- `LLight:setColor`: Sets this light RGBA color. This method is available to Lua scripts.
- `LLight:setCookie`: Stores a cookie texture path on this Lua light handle.
- `LLight:setDirection`: Sets this light direction angle. This method is available to Lua scripts.
- `LLight:setEnabled`: Enables or disables this light. This method is available to Lua scripts.
- `LLight:setEnergy`: Sets this light energy value. This method is available to Lua scripts.
- `LLight:setFalloff`: Sets this light falloff mode. This method is available to Lua scripts.
- `LLight:setFlicker`: Configures flicker speed and strength for this light.
- `LLight:setFlickerEnabled`: Enables or disables this light flicker state.
- `LLight:setGroupId`: Sets this light group id. This method is available to Lua scripts.
- `LLight:setInnerAngle`: Sets this spot light inner cone angle.
- `LLight:setIntensity`: Sets this light intensity. This method is available to Lua scripts.
- `LLight:setLightMask`: Sets this light's inclusion mask. This method is available to Lua scripts.
- `LLight:setLightType`: Sets this light type. This method is available to Lua scripts.
- `LLight:setNormalMap`: Sets the normal map path used by this light.
- `LLight:setNormalStrength`: Sets this light's normal map strength.
- `LLight:setOuterAngle`: Sets this spot light outer cone angle.
- `LLight:setPosition`: Sets this light position. This method is available to Lua scripts.
- `LLight:setRadius`: Sets this light radius. This method is available to Lua scripts.
- `LLight:setShadowColor`: Sets this light shadow RGBA color. This method is available to Lua scripts.
- `LLight:setShadowEnabled`: Enables or disables shadow casting for this light.
- `LLight:setShadowFilter`: Sets this light shadow filter. This method is available to Lua scripts.
- `LLight:setShadowMask`: Sets this light's shadow receiver mask.
- `LLight:setShadowSmooth`: Sets this light shadow smoothing value.
- `LLight:setShadowSoftness`: Sets this light shadow softness value.
- `LLight:setVolumetric`: Enables or disables volumetric behavior for this light.
- `LLight:stopTransition`: Stops and clears this light's active transition.
- `LLight:transitionProgress`: Returns active transition progress or 1.0 when no transition is active.
- `LLight:transitionTo`: Starts a transition toward target color, intensity, and radius values.
- `LLight:type`: Returns the Lua-visible type name for this light handle.
- `LLight:typeOf`: Returns whether this light handle matches a supported type name.
- `LLight:updateTransition`: Advances this light's active transition and applies interpolated values.


#### LOccluder Type


##### Fields

- No documented fields.

##### Methods

- `LOccluder:getLightMask`: Returns this occluder's light mask.
- `LOccluder:getOpacity`: Returns this occluder opacity. This method is available to Lua scripts.
- `LOccluder:getPosition`: Returns this occluder position offset.
- `LOccluder:getVertices`: Returns this occluder's flat vertex coordinate list.
- `LOccluder:isEnabled`: Returns whether this occluder is enabled.
- `LOccluder:isValid`: Returns whether this occluder handle still points to a live occluder.
- `LOccluder:remove`: Removes this occluder from the shared light world.
- `LOccluder:setEnabled`: Enables or disables this occluder.
- `LOccluder:setLightMask`: Sets this occluder's light mask. This method is available to Lua scripts.
- `LOccluder:setOpacity`: Sets this occluder opacity. This method is available to Lua scripts.
- `LOccluder:setPosition`: Sets this occluder position offset.
- `LOccluder:setVertices`: Replaces this occluder's flat vertex coordinate list.
- `LOccluder:type`: Returns the Lua-visible type name for this occluder handle.
- `LOccluder:typeOf`: Returns whether this occluder handle matches a supported type name.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
