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

## Source Documentation

### `attenuation.rs`
- Distance-based light intensity falloff using quadratic attenuation coefficients.
- Computes attenuation factor from constant, linear, and quadratic terms.
- Debug visualization of attenuation curves rendered to an image buffer.

### `blend_mode.rs`
- Define blend modes controlling how each light merges into the accumulation buffer.
- Support additive, subtractive, and alpha-mix compositing strategies.
- Variants: `Add` (classic glow), `Subtract` (shadow zones), `Mix` (alpha compositing).

### `falloff.rs`
- Radial intensity falloff shapes applied on top of distance attenuation.
- Variants control how brightness decreases from a light's center to its radius edge.
- Modes: `Linear` (default), `Smooth` (smooth-step), and `Constant` (no radial decay).

### `flicker.rs`
- Sine-based flicker configuration that modulates light intensity over time.
- Phase accumulates each frame and wraps at TAU for continuous oscillation.
- Strength controls peak deviation from base intensity; speed sets radians per second.
- Disabled by default; enable to animate torches, candles, or neon lights.

### `light2d.rs`
- Complete `Light2D` struct holding position, color, radius, type, shadow, masks, flicker, and attenuation.
- Constructor defaults to a white point light with full-layer masks and no shadows.
- Getter/setter API for every field: position, color, intensity, energy, blend mode, falloff, masks.
- Spot-light parameters: direction, inner/outer cone angles.
- Shadow controls: enable, tint color, filter preset, smooth, and softness.
- Normal-map attachment with optional path and contribution strength.
- Volumetric scattering toggle and group-id batching support.
- Debug visualization helper rendering falloff-mode comparison panels to `ImageData`.

### `light_type.rs`
- Define the geometric illumination models available for 2D lights.
- Discriminate between point, directional, and spot light behavior.
- Drive intensity falloff and ray direction logic in the lighting pipeline.

### `light_world.rs`
- Scene-level container (`LightWorld`) managing all `Light2D` instances and `Occluder` shapes via slotmaps.
- Add, remove, query, and bulk-update lights and occluders by stable keys.
- Group operations: enable/disable, intensity, and color changes on a named group ID.
- Flicker system: lazy-indexed advance loop that only touches lights with active flicker state.
- Renderer hints: ambient color array, directional light tuples, and normal-map snapshot extraction.
- Debug visualization: rasterize an approximate light-map preview into an `ImageData` bitmap.

### `mod.rs`
- 2D lighting system with point, spot, and area light types supporting color, falloff, and flicker.
- Shadow casting via occluder shapes with configurable filter quality.
- Light world accumulator that processes all active lights and emits composited render commands.
- Blend modes and attenuation curves for flexible intensity decay and compositing.

### `occluder.rs`
- Convex polygon shape that blocks light and casts shadows in the 2D lighting system.
- Vertex management: construction from Vec2 list or flat coordinate arrays, runtime replacement.
- Per-occluder properties: world position offset, shadow opacity, light-layer bitmask, enabled toggle.

### `shadow.rs`
- Shadow filtering quality presets for soft-shadow rendering.
- Defines PCF sample kernels at varying tap counts.
- Default is hard shadows (no filtering) for maximum performance.

### `transition.rs`
- Time-based linear interpolation of light color, intensity, and radius.
- Clamps duration to a safe minimum and tracks elapsed progress.
- Returns interpolated values each frame until the transition completes.

## Types

- `Attenuation` (`struct`, `attenuation.rs`): Coefficient-based custom falloff model.
- `LightBlendMode` (`enum`, `blend_mode.rs`): Enum controlling additive, subtractive, or mixed scene contribution.
- `FalloffMode` (`enum`, `falloff.rs`): Enum describing how intensity decays from center to edge.
- `FlickerConfig` (`struct`, `flicker.rs`): Time-varying intensity modulation for torches, unstable lights, and similar effects.
- `Light2D` (`struct`, `light2d.rs`): Main per-light data container used by Lua and the renderer-facing lighting world.
- `LightType` (`enum`, `light_type.rs`): Enum distinguishing point, directional, and spot light behavior.
- `LightWorld` (`struct`, `light_world.rs`): Owner of the light and occluder pools, ambient settings, limits, and group operations.
- `NormalMapLightHint` (`struct`, `light_world.rs`): Snapshot of a single light's normal-map binding used by the renderer for surface shading.
- `Occluder` (`struct`, `occluder.rs`): Polygon shadow caster with vertices, transform, opacity, mask, and enabled state.
- `ShadowFilter` (`enum`, `shadow.rs`): Enum selecting the shadow edge filtering quality.
- `LightTransition` (`struct`, `transition.rs`): Linearly interpolates a [`super::Light2D`]'s color, intensity, and radius from their current values to target values over a fixed duration.

## Functions

- `Attenuation::new` (`attenuation.rs`): Create a new attenuation with explicit constant, linear, and quadratic coefficients.
- `Attenuation::factor` (`attenuation.rs`): Return attenuation factor at `distance`; returns 1.0 when denominator is <= 0.
- `Attenuation::draw_attenuation_curves_to_image` (`attenuation.rs`): Render labeled attenuation curve plots for each config into an `ImageData` for debug output.
- `FlickerConfig::new` (`flicker.rs`): Create an enabled flicker with given speed and strength; phase starts at 0.
- `FlickerConfig::multiplier` (`flicker.rs`): Return the current intensity multiplier; returns 1.0 when disabled.
- `FlickerConfig::advance` (`flicker.rs`): Advance the flicker phase by `dt` seconds, wrapping at TAU.
- `Light2D::new` (`light2d.rs`): Create a point light at `(x, y)` with `radius`; all other fields default.
- `Light2D::set_position` (`light2d.rs`): Set world-space position and log at trace level.
- `Light2D::get_position` (`light2d.rs`): Return world-space `(x, y)` position.
- `Light2D::set_radius` (`light2d.rs`): Set the light radius and log at trace level.
- `Light2D::get_radius` (`light2d.rs`): Return the current light radius.
- `Light2D::set_color` (`light2d.rs`): Set the RGBA tint color.
- `Light2D::get_color` (`light2d.rs`): Return the RGBA tint color.
- `Light2D::set_intensity` (`light2d.rs`): Set the intensity multiplier.
- `Light2D::get_intensity` (`light2d.rs`): Return the intensity multiplier.
- `Light2D::set_enabled` (`light2d.rs`): Enable or disable this light.
- `Light2D::is_enabled` (`light2d.rs`): Return whether the light is enabled.
- `Light2D::set_energy` (`light2d.rs`): Set the energy scale.
- `Light2D::get_energy` (`light2d.rs`): Return the energy scale.
- `Light2D::set_blend_mode` (`light2d.rs`): Set the accumulation blend mode.
- `Light2D::get_blend_mode` (`light2d.rs`): Return the accumulation blend mode.
- `Light2D::set_falloff` (`light2d.rs`): Set the radial falloff curve.
- `Light2D::get_falloff` (`light2d.rs`): Return the radial falloff curve.
- `Light2D::set_shadow_enabled` (`light2d.rs`): Enable or disable shadow casting.
- `Light2D::is_shadow_enabled` (`light2d.rs`): Return whether shadow casting is enabled.
- `Light2D::set_shadow_color` (`light2d.rs`): Set the shadow tint color.
- `Light2D::get_shadow_color` (`light2d.rs`): Return the shadow tint color.
- `Light2D::set_shadow_filter` (`light2d.rs`): Set the shadow filter quality preset.
- `Light2D::get_shadow_filter` (`light2d.rs`): Return the shadow filter quality preset.
- `Light2D::set_shadow_smooth` (`light2d.rs`): Set the shadow edge smooth factor.
- `Light2D::get_shadow_smooth` (`light2d.rs`): Return the shadow edge smooth factor.
- `Light2D::set_shadow_softness` (`light2d.rs`): Set the overall shadow softness scale.
- `Light2D::get_shadow_softness` (`light2d.rs`): Return the overall shadow softness scale.
- `Light2D::set_light_mask` (`light2d.rs`): Set the layer bitmask for which geometry this light illuminates.
- `Light2D::get_light_mask` (`light2d.rs`): Return the illumination layer bitmask.
- `Light2D::set_shadow_mask` (`light2d.rs`): Set the layer bitmask for which geometry casts shadows.
- `Light2D::get_shadow_mask` (`light2d.rs`): Return the shadow caster layer bitmask.
- `Light2D::set_light_type` (`light2d.rs`): Set the light type discriminant.
- `Light2D::get_light_type` (`light2d.rs`): Return the light type discriminant.
- `Light2D::set_direction` (`light2d.rs`): Set the spot-light direction angle in radians.
- `Light2D::get_direction` (`light2d.rs`): Return the spot-light direction angle in radians.
- `Light2D::set_inner_angle` (`light2d.rs`): Set the inner cone half-angle in radians for spot lights.
- `Light2D::get_inner_angle` (`light2d.rs`): Return the inner cone half-angle in radians.
- `Light2D::set_outer_angle` (`light2d.rs`): Set the outer cone half-angle in radians for spot lights.
- `Light2D::get_outer_angle` (`light2d.rs`): Return the outer cone half-angle in radians.
- `Light2D::set_attenuation` (`light2d.rs`): Set the quadratic attenuation coefficients.
- `Light2D::get_attenuation` (`light2d.rs`): Return the quadratic attenuation coefficients.
- `Light2D::flicker_mut` (`light2d.rs`): Return a mutable reference to the flicker config.
- `Light2D::flicker` (`light2d.rs`): Return a shared reference to the flicker config.
- `Light2D::set_group_id` (`light2d.rs`): Set the group id for light batching.
- `Light2D::get_group_id` (`light2d.rs`): Return the group id.
- `Light2D::set_volumetric` (`light2d.rs`): Enable or disable volumetric scattering.
- `Light2D::is_volumetric` (`light2d.rs`): Return whether volumetric scattering is enabled.
- `Light2D::set_normal_map_path` (`light2d.rs`): Set the normal map texture path, replacing any previous value.
- `Light2D::clear_normal_map_path` (`light2d.rs`): Clear the normal map texture path.
- `Light2D::get_normal_map_path` (`light2d.rs`): Return the normal map texture path if set.
- `Light2D::set_normal_strength` (`light2d.rs`): Set the normal map contribution strength; range [0.0, 1.0].
- `Light2D::get_normal_strength` (`light2d.rs`): Return the normal map contribution strength.
- `Light2D::draw_falloff_comparison_to_image` (`light2d.rs`): Render falloff comparison panels for each mode into an `ImageData` debug image.
- `LightWorld::new` (`light_world.rs`): Create an empty world with ambient=0.1, disabled, and max_lights=64.
- `LightWorld::add_light` (`light_world.rs`): Insert a light, enable the world if it was disabled, and return its key.
- `LightWorld::add_occluder` (`light_world.rs`): Insert an occluder and return its key.
- `LightWorld::remove_light` (`light_world.rs`): Remove a light by key and evict it from the flicker index; returns the removed light or `None`.
- `LightWorld::remove_occluder` (`light_world.rs`): Remove an occluder by key; returns the removed occluder or `None`.
- `LightWorld::get_light` (`light_world.rs`): Return a shared reference to the light at `key`, or `None` if not present.
- `LightWorld::get_light_mut` (`light_world.rs`): Return a mutable reference to the light at `key`, or `None` if not present.
- `LightWorld::get_occluder` (`light_world.rs`): Return a shared reference to the occluder at `key`, or `None` if not present.
- `LightWorld::get_occluder_mut` (`light_world.rs`): Return a mutable reference to the occluder at `key`, or `None` if not present.
- `LightWorld::light_count` (`light_world.rs`): Return the number of registered lights.
- `LightWorld::occluder_count` (`light_world.rs`): Return the number of registered occluders.
- `LightWorld::clear` (`light_world.rs`): Remove all lights and occluders and reset ambient to 0.1 gray.
- `LightWorld::has_active_lights` (`light_world.rs`): Return `true` if any registered light has `enabled = true`.
- `LightWorld::set_group_enabled` (`light_world.rs`): Set `enabled` on all lights in `group_id`.
- `LightWorld::set_group_intensity` (`light_world.rs`): Set `intensity` on all lights in `group_id`.
- `LightWorld::set_group_color` (`light_world.rs`): Set `color` on all lights in `group_id`.
- `LightWorld::group_count` (`light_world.rs`): Return the count of lights in `group_id`.
- `LightWorld::advance_flickers` (`light_world.rs`): Advance all flickering lights by `dt` seconds; rebuilds the flicker index if stale.
- `LightWorld::reindex_flickers` (`light_world.rs`): Rebuild the flicker key index from all lights that have flicker enabled.
- `LightWorld::draw_to_image` (`light_world.rs`): Render an approximate light-map preview of this world into an `ImageData` debug image.
- `LightWorld::ambient_color_hint` (`light_world.rs`): Return ambient color as an RGBA `[f32; 4]` array for shader upload.
- `LightWorld::directional_light_hints` (`light_world.rs`): Return `(x, y, direction)` tuples for all enabled directional lights.
- `LightWorld::normal_map_light_hints` (`light_world.rs`): Return `NormalMapLightHint` snapshots for all enabled lights that have a normal map path.
- `Occluder::new` (`occluder.rs`): Create an occluder from vertices; panics if count is outside 3..=512.
- `Occluder::set_vertices` (`occluder.rs`): Replace vertices; panics if new count is outside 3..=512.
- `Occluder::from_flat_coords` (`occluder.rs`): Build an occluder from a flat `[x, y, x, y, ...]` coordinate slice; returns error on invalid length.
- `Occluder::get_vertices` (`occluder.rs`): Return the vertex slice.
- `Occluder::set_position` (`occluder.rs`): Set the world-space position offset.
- `Occluder::get_position` (`occluder.rs`): Return the world-space position offset.
- `Occluder::set_opacity` (`occluder.rs`): Set shadow opacity; expected range [0.0, 1.0].
- `Occluder::get_opacity` (`occluder.rs`): Return shadow opacity.
- `Occluder::set_light_mask` (`occluder.rs`): Set the light-layer bitmask.
- `Occluder::get_light_mask` (`occluder.rs`): Return the light-layer bitmask.
- `Occluder::set_enabled` (`occluder.rs`): Enable or disable this occluder.
- `Occluder::is_enabled` (`occluder.rs`): Return whether this occluder is enabled.
- `LightTransition::new` (`transition.rs`): Create a new active transition between the given from/to values over `duration` seconds.
- `LightTransition::update` (`transition.rs`): Advance by `dt` seconds and return `Some((color, intensity, radius))`; returns `None` if inactive.
- `LightTransition::progress` (`transition.rs`): Return the normalised progress in [0.0, 1.0]; returns 1.0 when duration is zero.

## Lua API Reference

- Binding path(s): `src/lua_api/light_api.rs`
- Namespace: `lurek.light`

### Module Functions
- `lurek.light.newLight`: Creates a light and applies optional light settings.
- `lurek.light.newOccluder`: Creates an occluder from a flat vertex coordinate table and optional settings.
- `lurek.light.setAmbient`: Sets global ambient light color. This function is exposed to Lua scripts.
- `lurek.light.getAmbient`: Returns global ambient light color.
- `lurek.light.setEnabled`: Enables or disables the shared light world.
- `lurek.light.isEnabled`: Returns whether the shared light world is enabled.
- `lurek.light.getLightCount`: Returns the number of live lights. This function is exposed to Lua scripts.
- `lurek.light.getOccluderCount`: Returns the number of live occluders.
- `lurek.light.getMaxLights`: Returns the maximum configured light count.
- `lurek.light.setMaxLights`: Sets the maximum configured light count, clamped to 1 through 256.
- `lurek.light.clear`: Removes all lights and occluders from the light world.
- `lurek.light.setGroupEnabled`: Enables or disables all lights in a group.
- `lurek.light.setGroupIntensity`: Sets intensity for all lights in a group.
- `lurek.light.setGroupColor`: Sets color for all lights in a group.
- `lurek.light.getGroupCount`: Returns the number of lights in a group.
- `lurek.light.advanceFlickers`: Advances flicker animation for all indexed flickering lights.
- `lurek.light.syncAmbient`: Returns the light world's ambient color hint.
- `lurek.light.getGodRayHints`: Returns directional light hints for god-ray style effects.
- `lurek.light.getNormalMapHints`: Returns light hints that reference normal maps.
- `lurek.light.drawToImage`: Renders an approximate light-map preview of this world into an ImageData.

### `LLight` Methods
- `LLight:setPosition`: Sets this light position. This method is available to Lua scripts.
- `LLight:getPosition`: Returns this light position. This method is available to Lua scripts.
- `LLight:setRadius`: Sets this light radius. This method is available to Lua scripts.
- `LLight:getRadius`: Returns this light radius. This method is available to Lua scripts.
- `LLight:setColor`: Sets this light RGBA color. This method is available to Lua scripts.
- `LLight:getColor`: Returns this light RGBA color. This method is available to Lua scripts.
- `LLight:setIntensity`: Sets this light intensity. This method is available to Lua scripts.
- `LLight:getIntensity`: Returns this light intensity. This method is available to Lua scripts.
- `LLight:setEnergy`: Sets this light energy value. This method is available to Lua scripts.
- `LLight:getEnergy`: Returns this light energy value. This method is available to Lua scripts.
- `LLight:setBlendMode`: Sets this light blend mode. This method is available to Lua scripts.
- `LLight:getBlendMode`: Returns this light blend mode string.
- `LLight:setFalloff`: Sets this light falloff mode. This method is available to Lua scripts.
- `LLight:getFalloff`: Returns this light falloff mode string.
- `LLight:setShadowEnabled`: Enables or disables shadow casting for this light.
- `LLight:isShadowEnabled`: Returns whether this light casts shadows.
- `LLight:setShadowColor`: Sets this light shadow RGBA color. This method is available to Lua scripts.
- `LLight:getShadowColor`: Returns this light shadow RGBA color.
- `LLight:setShadowFilter`: Sets this light shadow filter. This method is available to Lua scripts.
- `LLight:getShadowFilter`: Returns this light shadow filter string.
- `LLight:setShadowSmooth`: Sets this light shadow smoothing value.
- `LLight:getShadowSmooth`: Returns this light shadow smoothing value.
- `LLight:setShadowSoftness`: Sets this light shadow softness value.
- `LLight:getShadowSoftness`: Returns this light shadow softness value.
- `LLight:setLightMask`: Sets this light's inclusion mask. This method is available to Lua scripts.
- `LLight:getLightMask`: Returns this light's inclusion mask.
- `LLight:setShadowMask`: Sets this light's shadow receiver mask.
- `LLight:getShadowMask`: Returns this light's shadow receiver mask.
- `LLight:setEnabled`: Enables or disables this light. This method is available to Lua scripts.
- `LLight:isEnabled`: Returns whether this light is enabled.
- `LLight:setLightType`: Sets this light type. This method is available to Lua scripts.
- `LLight:getLightType`: Returns this light type string. This method is available to Lua scripts.
- `LLight:setDirection`: Sets this light direction angle. This method is available to Lua scripts.
- `LLight:getDirection`: Returns this light direction angle.
- `LLight:setInnerAngle`: Sets this spot light inner cone angle.
- `LLight:getInnerAngle`: Returns this spot light inner cone angle.
- `LLight:setOuterAngle`: Sets this spot light outer cone angle.
- `LLight:getOuterAngle`: Returns this spot light outer cone angle.
- `LLight:setAttenuation`: Sets this light attenuation coefficients.
- `LLight:getAttenuation`: Returns this light attenuation coefficients.
- `LLight:setFlicker`: Configures flicker speed and strength for this light.
- `LLight:getFlicker`: Returns this light flicker speed and strength.
- `LLight:setFlickerEnabled`: Enables or disables this light flicker state.
- `LLight:isFlickerEnabled`: Returns whether this light flicker is enabled.
- `LLight:setGroupId`: Sets this light group id. This method is available to Lua scripts.
- `LLight:getGroupId`: Returns this light group id. This method is available to Lua scripts.
- `LLight:setVolumetric`: Enables or disables volumetric behavior for this light.
- `LLight:isVolumetric`: Returns whether this light is volumetric.
- `LLight:remove`: Removes this light from the shared light world.
- `LLight:isValid`: Returns whether this light handle still points to a live light.
- `LLight:addFlicker`: Adds flicker from min/max intensity range and frequency.
- `LLight:transitionTo`: Starts a transition toward target color, intensity, and radius values.
- `LLight:updateTransition`: Advances this light's active transition and applies interpolated values.
- `LLight:stopTransition`: Stops and clears this light's active transition.
- `LLight:transitionProgress`: Returns active transition progress or 1.0 when no transition is active.
- `LLight:setCookie`: Stores a cookie texture path on this Lua light handle.
- `LLight:getCookie`: Returns the cookie texture path stored on this Lua light handle.
- `LLight:clearCookie`: Clears the cookie texture path stored on this Lua light handle.
- `LLight:setNormalMap`: Sets the normal map path used by this light.
- `LLight:getNormalMap`: Returns the normal map path used by this light.
- `LLight:clearNormalMap`: Clears the normal map path used by this light.
- `LLight:setNormalStrength`: Sets this light's normal map strength.
- `LLight:getNormalStrength`: Returns this light's normal map strength.
- `LLight:type`: Returns the Lua-visible type name for this light handle.
- `LLight:typeOf`: Returns whether this light handle matches a supported type name.

### `LOccluder` Methods
- `LOccluder:setVertices`: Replaces this occluder's flat vertex coordinate list.
- `LOccluder:getVertices`: Returns this occluder's flat vertex coordinate list.
- `LOccluder:setPosition`: Sets this occluder position offset.
- `LOccluder:getPosition`: Returns this occluder position offset.
- `LOccluder:setOpacity`: Sets this occluder opacity. This method is available to Lua scripts.
- `LOccluder:getOpacity`: Returns this occluder opacity. This method is available to Lua scripts.
- `LOccluder:setLightMask`: Sets this occluder's light mask. This method is available to Lua scripts.
- `LOccluder:getLightMask`: Returns this occluder's light mask.
- `LOccluder:setEnabled`: Enables or disables this occluder.
- `LOccluder:isEnabled`: Returns whether this occluder is enabled.
- `LOccluder:remove`: Removes this occluder from the shared light world.
- `LOccluder:isValid`: Returns whether this occluder handle still points to a live occluder.
- `LOccluder:type`: Returns the Lua-visible type name for this occluder handle.
- `LOccluder:typeOf`: Returns whether this occluder handle matches a supported type name.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Platform Services` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- 2026-05-07 enhancements shipped in source:
	- Soft-shadow penumbra controls: `LLight:setShadowSoftness` / `LLight:getShadowSoftness` are now part of the Lua surface and are consumed by renderer shadow sampling.
	- Normal-map plugin hints: `LLight:setNormalMap`, `LLight:getNormalMap`, `LLight:clearNormalMap`, `LLight:setNormalStrength`, `LLight:getNormalStrength`, and module function `lurek.light.getNormalMapHints` expose data-only inputs for optional plugin passes.
	- Ambient bridge parity with `effect` overlay: `LOverlay:pullAmbientFromLight`, `LOverlay:pushAmbientToLight`, `LOverlay:syncAmbientWithLight(mode)` now resolve duplication between `LightWorld.ambient` and `Overlay.ambient.color` with explicit priority modes.
	- Flicker stepping now uses a secondary index of flicker-enabled lights (`LightWorld::reindex_flickers` + indexed `advance_flickers`) to reduce per-frame overhead in scenes with many static lights.
- Keep this module reference synchronized with `src/light/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
