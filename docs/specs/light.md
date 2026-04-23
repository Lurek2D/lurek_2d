# light

## General Info

- Module group: `Platform Services`
- Source path: `src/light/`
- Lua API path(s): `src/lua_api/light_api.rs`
- Primary Lua namespace: `lurek.light`
- Rust test path(s): tests/rust/unit/light_tests.rs
- Lua test path(s): tests/lua/unit/test_light.lua, tests/lua/stress/test_light_stress.lua, tests/lua/integration/test_light_render.lua, tests/lua/evidence/test_evidence_light.lua

## Summary

## Summary

The `light` module provides Lurek2D's 2D point-light data model — a Foundations tier module that is a pure data container with no GPU resources stored in it. The renderer receives light data via `RenderCommand` variants and performs all GPU work outside of this module. The design keeps light state Lua-scriptable and headlessly testable without a window.

**Light2D — the core light record.** `Light2D` describes one light source with: world-space position (x, y), `LightType` variant (Point, Spot, Directional), colour (RGBA), intensity scalar, effective radius (world units), enabled flag, inner/outer cone angles for spot lights, direction angle, `FalloffMode` (Linear, Quadratic, Constant), optional `FlickerConfig` for sinusoidal or noise-based intensity oscillation, optional polygon `Occluder` geometry for shadow casting, and mask bits controlling which layer objects receive this light. `Attenuation` provides custom per-coefficient (constant, linear, quadratic) falloff for callers who need finer control than the named `FalloffMode` presets.

**LightWorld — the resource pool.** `LightWorld` owns all active `Light2D` instances in a `SlotMap<LightKey, Light2D>` and all active `Occluder` instances in a companion slot map. Key operations: `add_light(light) → LightKey`, `remove_light(key)`, `get_light(key)`, `get_light_mut(key)`, `set_ambient(color)`, `get_ambient()`. Group operations: `enable_group(group_id)`, `disable_group(group_id)`, `set_group_intensity(group_id, factor)` — useful for day/night zone transitions affecting multiple lights at once. `build_render_commands()` converts the active pool to `RenderCommand::Light2D` entries each frame.

**LightBlendMode.** `LightBlendMode` controls how each light's colour contribution composites with the rendered scene: `Additive` (lamps pile up, brightens scene), `Multiply` (darkens scene, shadow-zone effect), `Screen` (soft additive with ceiling at white). Set per light, not globally.

**FlickerConfig.** `FlickerConfig` specifies time-varying intensity modulation: oscillation amplitude (fraction of base intensity), frequency Hz, phase offset for avoiding synchronisation between nearby torches, and a noise seed for irregular rather than sinusoidal flicker. The flicker is advanced externally by calling `advance_flicker(dt)` on `LightWorld`; the result is folded into the intensity at render-command build time.

**Occluder polygons.** `Occluder` is a polygon shadow-caster with a list of `Vec2` vertices, a world-space transform (position, scale, rotation angle), an opacity scalar (0 = transparent, 1 = fully opaque), layer mask, and an enabled flag. The renderer traces shadow lines from each light position against all active occluders for the same layer mask, building a shadow map that gates the light contribution.

**ShadowCaster — standalone geometry.** `shadow.rs` introduces `ShadowCaster` as a first-class type independent of any specific `Light2D`. Game objects (walls, characters, furniture) register their outline as a `ShadowCaster` once; all lights with matching layer masks automatically interact with it. `ShadowFilter` selects the shadow edge smoothing quality (Hard, Soft, SoftHigh).

**LightTransition — smooth interpolation.** `LightTransition` linearly interpolates a `Light2D`'s colour, intensity, and radius from their current values to target values over a fixed duration. `update(dt) → bool` advances and returns `true` on completion. Used for torch extinction, level-transition lighting, and scripted events.

**Lua surface.** `lurek.light.new(spec)` → `Light2D` userdata. `lurek.light.newWorld()` → `LightWorld` userdata. `LightWorld` methods: `add(light)`, `remove(key)`, `get(key)`, `setAmbient(r,g,b,a)`, `enableGroup(id)`, `disableGroup(id)`, `setGroupIntensity(id, factor)`, `advanceFlicker(dt)`. `Light2D` methods: `setPosition(x,y)`, `setColor(r,g,b,a)`, `setIntensity(v)`, `setRadius(v)`, `setFlicker(config)`, `setOccluder(vertices)`, `setBlendMode(mode)`. `lurek.light.newTransition(light, target, duration)`. `lurek.light.newShadowCaster(vertices)`.

**Scope boundary.** Foundations tier. Depends only on `math`. Lua bridge in `src/lua_api/light_api.rs`.

## Files

- `attenuation.rs`: Defines coefficient-based attenuation for custom distance decay.
- `blend_mode.rs`: Defines how light mixes with the scene.
- `falloff.rs`: Defines the high-level radial falloff enum.
- `flicker.rs`: Defines flicker configuration and phase advancement helpers.
- `light2d.rs`: Defines Light2D, the main per-light data record with position, radius, color, intensity, masks, shadows, geometry, attenuation, flicker, and grouping.
- `light_type.rs`: Defines the geometric light-type enum for point, directional, and spot lights.
- `light_world.rs`: Defines LightWorld, the keyed container for active lights, occluders, ambient color, limits, and group operations.
- `mod.rs`: Declares the lighting submodules and re-exports the public light types.
- `occluder.rs`: Defines Occluder, a polygon shadow caster with transform, opacity, mask, and enabled state.
- `shadow.rs`: Defines the shadow edge-filter enum.
- `transition.rs`: Smooth linear transition for light color, intensity, and radius.

## Types

- `Attenuation` (`struct`, `attenuation.rs`): Coefficient-based custom falloff model.
- `LightBlendMode` (`enum`, `blend_mode.rs`): Enum controlling additive, subtractive, or mixed scene contribution.
- `FalloffMode` (`enum`, `falloff.rs`): Enum describing how intensity decays from center to edge.
- `FlickerConfig` (`struct`, `flicker.rs`): Time-varying intensity modulation for torches, unstable lights, and similar effects.
- `Light2D` (`struct`, `light2d.rs`): Main per-light data container used by Lua and the renderer-facing lighting world.
- `LightType` (`enum`, `light_type.rs`): Enum distinguishing point, directional, and spot light behavior.
- `LightWorld` (`struct`, `light_world.rs`): Owner of the light and occluder pools, ambient settings, limits, and group operations.
- `Occluder` (`struct`, `occluder.rs`): Polygon shadow caster with vertices, transform, opacity, mask, and enabled state.
- `ShadowFilter` (`enum`, `shadow.rs`): Enum selecting the shadow edge filtering quality.
- `LightTransition` (`struct`, `transition.rs`): Linearly interpolates a [`super::Light2D`]'s color, intensity, and radius from their current values to target values over a fixed duration.

## Functions

- `Attenuation::new` (`attenuation.rs`): Creates a new `Attenuation` with all three coefficients.
- `Attenuation::factor` (`attenuation.rs`): Computes the attenuation factor at a given distance.
- `Attenuation::draw_attenuation_curves_to_image` (`attenuation.rs`): Draw multiple attenuation curves side-by-side.
- `FlickerConfig::new` (`flicker.rs`): Creates a new enabled `FlickerConfig` with the given speed and strength.
- `FlickerConfig::multiplier` (`flicker.rs`): Computes the intensity multiplier for the current phase.
- `FlickerConfig::advance` (`flicker.rs`): Advances the phase by `dt` seconds.
- `Light2D::new` (`light2d.rs`): Creates a new white light at `(x, y)` with the given radius.
- `Light2D::set_position` (`light2d.rs`): Sets the light's world-space position.
- `Light2D::get_position` (`light2d.rs`): Returns the light's world-space position as `(x, y)`.
- `Light2D::set_radius` (`light2d.rs`): Sets the light's influence radius.
- `Light2D::get_radius` (`light2d.rs`): Returns the light's influence radius.
- `Light2D::set_color` (`light2d.rs`): Sets the light's tint color.
- `Light2D::get_color` (`light2d.rs`): Returns the light's tint color.
- `Light2D::set_intensity` (`light2d.rs`): Sets the light's brightness multiplier.
- `Light2D::get_intensity` (`light2d.rs`): Returns the light's brightness multiplier.
- `Light2D::set_enabled` (`light2d.rs`): Sets whether the light is active.
- `Light2D::is_enabled` (`light2d.rs`): Returns whether the light is active.
- `Light2D::set_energy` (`light2d.rs`): Sets the energy scaling factor (scales radius and intensity together).
- `Light2D::get_energy` (`light2d.rs`): Returns the energy scaling factor.
- `Light2D::set_blend_mode` (`light2d.rs`): Sets the light blend mode.
- `Light2D::get_blend_mode` (`light2d.rs`): Returns the light blend mode.
- `Light2D::set_falloff` (`light2d.rs`): Sets the falloff mode controlling intensity decay.
- `Light2D::get_falloff` (`light2d.rs`): Returns the falloff mode.
- `Light2D::set_shadow_enabled` (`light2d.rs`): Sets whether this light casts shadows.
- `Light2D::is_shadow_enabled` (`light2d.rs`): Returns whether this light casts shadows.
- `Light2D::set_shadow_color` (`light2d.rs`): Sets the shadow region color.
- `Light2D::get_shadow_color` (`light2d.rs`): Returns the shadow region color.
- `Light2D::set_shadow_filter` (`light2d.rs`): Sets the shadow edge filter quality.
- `Light2D::get_shadow_filter` (`light2d.rs`): Returns the shadow edge filter quality.
- `Light2D::set_shadow_smooth` (`light2d.rs`): Sets the shadow edge smoothing factor.
- `Light2D::get_shadow_smooth` (`light2d.rs`): Returns the shadow edge smoothing factor.
- `Light2D::set_light_mask` (`light2d.rs`): Sets the light interaction bitmask.
- `Light2D::get_light_mask` (`light2d.rs`): Returns the light interaction bitmask.
- `Light2D::set_shadow_mask` (`light2d.rs`): Sets the shadow casting bitmask.
- `Light2D::get_shadow_mask` (`light2d.rs`): Returns the shadow casting bitmask.
- `Light2D::set_light_type` (`light2d.rs`): Sets the geometric light type.
- `Light2D::get_light_type` (`light2d.rs`): Returns the geometric light type.
- `Light2D::set_direction` (`light2d.rs`): Sets the direction angle in radians (for Directional and Spot lights).
- `Light2D::get_direction` (`light2d.rs`): Returns the direction angle in radians.
- `Light2D::set_inner_angle` (`light2d.rs`): Sets the inner cone angle in radians for Spot lights.
- `Light2D::get_inner_angle` (`light2d.rs`): Returns the inner cone angle in radians.
- `Light2D::set_outer_angle` (`light2d.rs`): Sets the outer cone angle in radians for Spot lights.
- `Light2D::get_outer_angle` (`light2d.rs`): Returns the outer cone angle in radians.
- `Light2D::set_attenuation` (`light2d.rs`): Sets the custom attenuation coefficients.
- `Light2D::get_attenuation` (`light2d.rs`): Returns the custom attenuation coefficients.
- `Light2D::flicker_mut` (`light2d.rs`): Returns a mutable reference to the flicker configuration.
- `Light2D::flicker` (`light2d.rs`): Returns a shared reference to the flicker configuration.
- `Light2D::set_group_id` (`light2d.rs`): Sets the group identifier for batch operations.
- `Light2D::get_group_id` (`light2d.rs`): Returns the group identifier.
- `Light2D::set_volumetric` (`light2d.rs`): Sets whether this light hints at volumetric scattering.
- `Light2D::is_volumetric` (`light2d.rs`): Returns whether this light hints at volumetric scattering.
- `Light2D::apply_lua_opts` (`light2d.rs`): Applies configuration fields from a Lua options table to this `Light2D`.
- `Light2D::draw_falloff_comparison_to_image` (`light2d.rs`): Draw a side-by-side comparison of falloff modes as radial gradients.
- `LightWorld::new` (`light_world.rs`): Creates a new empty `LightWorld` with default settings.
- `LightWorld::add_light` (`light_world.rs`): Inserts a light and returns its key.
- `LightWorld::add_occluder` (`light_world.rs`): Inserts an occluder and returns its key.
- `LightWorld::remove_light` (`light_world.rs`): Removes a light by key, returning it if found.
- `LightWorld::remove_occluder` (`light_world.rs`): Removes an occluder by key, returning it if found.
- `LightWorld::get_light` (`light_world.rs`): Returns a shared reference to a light by key.
- `LightWorld::get_light_mut` (`light_world.rs`): Returns a mutable reference to a light by key.
- `LightWorld::get_occluder` (`light_world.rs`): Returns a shared reference to an occluder by key.
- `LightWorld::get_occluder_mut` (`light_world.rs`): Returns a mutable reference to an occluder by key.
- `LightWorld::light_count` (`light_world.rs`): Returns the number of lights in the world.
- `LightWorld::occluder_count` (`light_world.rs`): Returns the number of occluders in the world.
- `LightWorld::clear` (`light_world.rs`): Removes all lights and occluders, resets ambient to default.
- `LightWorld::has_active_lights` (`light_world.rs`): Returns `true` if any light in the world is enabled.
- `LightWorld::set_group_enabled` (`light_world.rs`): Sets the enabled state for all lights in the given group.
- `LightWorld::set_group_intensity` (`light_world.rs`): Sets the intensity for all lights in the given group.
- `LightWorld::set_group_color` (`light_world.rs`): Sets the color for all lights in the given group.
- `LightWorld::group_count` (`light_world.rs`): Returns the number of lights in the given group.
- `LightWorld::advance_flickers` (`light_world.rs`): Advances flicker phase for all lights with flicker enabled.
- `LightWorld::draw_to_image` (`light_world.rs`): Render the accumulated lightmap to an image.
- `LightWorld::ambient_color_hint` (`light_world.rs`): Returns the current ambient colour as an RGBA tuple in `[0.0, 1.0]`.
- `LightWorld::directional_light_hints` (`light_world.rs`): Returns a list of position and direction hints for all enabled directional lights.
- `Occluder::new` (`occluder.rs`): Creates a new occluder from the given polygon vertices.
- `Occluder::set_vertices` (`occluder.rs`): Sets the polygon vertices.
- `Occluder::from_flat_coords` (`occluder.rs`): Creates an `Occluder` from a flat `{x1, y1, x2, y2, ...}` coordinate sequence.
- `Occluder::get_vertices` (`occluder.rs`): Returns a reference to the polygon vertices.
- `Occluder::set_position` (`occluder.rs`): Sets the translation offset.
- `Occluder::get_position` (`occluder.rs`): Returns the translation offset.
- `Occluder::set_opacity` (`occluder.rs`): Sets the shadow opacity (0.0–1.0).
- `Occluder::get_opacity` (`occluder.rs`): Returns the shadow opacity.
- `Occluder::set_light_mask` (`occluder.rs`): Sets the light interaction bitmask.
- `Occluder::get_light_mask` (`occluder.rs`): Returns the light interaction bitmask.
- `Occluder::set_enabled` (`occluder.rs`): Sets whether this occluder is active.
- `Occluder::is_enabled` (`occluder.rs`): Returns whether this occluder is active.
- `LightTransition::new` (`transition.rs`): Creates a new `LightTransition` starting from the given snapshot of the light's current state.
- `LightTransition::update` (`transition.rs`): Advances the transition by `dt` seconds and returns the current `(color, intensity, radius)` snapshot, or `None` when the transition has completed.
- `LightTransition::progress` (`transition.rs`): Returns the fractional progress `[0, 1]` of the transition.

## Lua API Reference

- Binding path(s): `src/lua_api/light_api.rs`
- Namespace: `lurek.light`

### Module Functions
- `lurek.light.newLight`: Creates a new light at (x, y) with the given radius and optional settings.
- `lurek.light.newOccluder`: Creates a new shadow occluder from a vertex table and optional settings.
- `lurek.light.setAmbient`: Sets the global ambient light color.
- `lurek.light.getAmbient`: Returns the global ambient light color as (r, g, b, a).
- `lurek.light.setEnabled`: Sets whether the lighting system is active.
- `lurek.light.isEnabled`: Returns whether the lighting system is active.
- `lurek.light.getLightCount`: Returns the number of lights in the world.
- `lurek.light.getOccluderCount`: Returns the number of occluders in the world.
- `lurek.light.getMaxLights`: Returns the maximum number of lights processed per frame.
- `lurek.light.setMaxLights`: Sets the maximum number of lights processed per frame (clamped 1â€“256).
- `lurek.light.clear`: Removes all lights and occluders, resets ambient to default.
- `lurek.light.setGroupEnabled`: Sets the enabled state for all lights in the given group.
- `lurek.light.setGroupIntensity`: Sets the intensity for all lights in the given group.
- `lurek.light.setGroupColor`: Sets the color for all lights in the given group.
- `lurek.light.getGroupCount`: Returns the number of lights in the given group.
- `lurek.light.advanceFlickers`: Advances flicker phase for all lights with flicker enabled.
- `lurek.light.syncAmbient`: Returns the current ambient light colour as (r, g, b, a).
- `lurek.light.getGodRayHints`: Returns a list of directional light hints for god-ray rendering.

### `Light` Methods
- `Light:setPosition`: Sets the light's world-space position.
- `Light:getPosition`: Returns the light's world-space position.
- `Light:setRadius`: Sets the light's influence radius.
- `Light:getRadius`: Returns the light's influence radius.
- `Light:getColor`: Returns the light's tint color as (r, g, b, a).
- `Light:setIntensity`: Sets the brightness multiplier.
- `Light:getIntensity`: Returns the brightness multiplier.
- `Light:setEnergy`: Sets the energy scaling factor.
- `Light:getEnergy`: Returns the energy scaling factor.
- `Light:setBlendMode`: Sets the blend mode ('add', 'sub', or 'mix').
- `Light:getBlendMode`: Returns the blend mode as a string.
- `Light:setFalloff`: Sets the falloff mode ('linear', 'smooth', or 'constant').
- `Light:getFalloff`: Returns the falloff mode as a string.
- `Light:setShadowEnabled`: Sets whether this light casts shadows.
- `Light:isShadowEnabled`: Returns whether this light casts shadows.
- `Light:getShadowColor`: Returns the shadow region color as (r, g, b, a).
- `Light:setShadowFilter`: Sets the shadow edge filter ('none', 'pcf5', or 'pcf13').
- `Light:getShadowFilter`: Returns the shadow edge filter as a string.
- `Light:setShadowSmooth`: Sets the shadow edge smoothing factor.
- `Light:getShadowSmooth`: Returns the shadow edge smoothing factor.
- `Light:setLightMask`: Sets the light interaction bitmask.
- `Light:getLightMask`: Returns the light interaction bitmask.
- `Light:setShadowMask`: Sets the shadow casting bitmask.
- `Light:getShadowMask`: Returns the shadow casting bitmask.
- `Light:setEnabled`: Sets whether this light is active.
- `Light:isEnabled`: Returns whether this light is active.
- `Light:setLightType`: Sets the geometric light type ('point', 'directional', or 'spot').
- `Light:getLightType`: Returns the geometric light type as a string.
- `Light:setDirection`: Sets the direction angle in radians.
- `Light:getDirection`: Returns the direction angle in radians.
- `Light:setInnerAngle`: Sets the inner cone angle in radians for spot lights.
- `Light:getInnerAngle`: Returns the inner cone angle in radians.
- `Light:setOuterAngle`: Sets the outer cone angle in radians for spot lights.
- `Light:getOuterAngle`: Returns the outer cone angle in radians.
- `Light:setAttenuation`: Sets the custom attenuation coefficients (constant, linear, quadratic).
- `Light:getAttenuation`: Returns the custom attenuation coefficients as (constant, linear, quadratic).
- `Light:setFlicker`: Sets the flicker effect speed and strength (enables flicker).
- `Light:getFlicker`: Returns the flicker effect speed and strength.
- `Light:setFlickerEnabled`: Sets whether the flicker effect is active.
- `Light:isFlickerEnabled`: Returns whether the flicker effect is active.
- `Light:setGroupId`: Sets the group identifier for batch operations.
- `Light:getGroupId`: Returns the group identifier.
- `Light:setVolumetric`: Sets whether this light hints at volumetric scattering.
- `Light:isVolumetric`: Returns whether this light hints at volumetric scattering.
- `Light:remove`: Removes this light from the world.
- `Light:isValid`: Returns whether this light handle is still valid.
- `Light:addFlicker`: Convenience method to set a flicker effect using amplitude range and
- `Light:updateTransition`: Advances the active transition by `dt` seconds and applies the
- `Light:stopTransition`: Cancels the active light transition.
- `Light:transitionProgress`: Returns the fractional progress `[0, 1]` of the active transition,
- `Light:setCookie`: Sets the texture path used as a light cookie (mask) for projection.
- `Light:getCookie`: Returns the current cookie texture path, or `nil` if unset.
- `Light:clearCookie`: Removes the cookie texture assignment.

### `Occluder` Methods
- `Occluder:setVertices`: Replaces the polygon vertices from a flat table {x1,y1,x2,y2,...}.
- `Occluder:getVertices`: Returns the polygon vertices as a flat table {x1,y1,x2,y2,...}.
- `Occluder:setPosition`: Sets the translation offset applied to all vertices.
- `Occluder:getPosition`: Returns the translation offset as (x, y).
- `Occluder:setOpacity`: Sets the shadow opacity (0.0â€“1.0).
- `Occluder:getOpacity`: Returns the shadow opacity.
- `Occluder:setLightMask`: Sets the light interaction bitmask.
- `Occluder:getLightMask`: Returns the light interaction bitmask.
- `Occluder:setEnabled`: Sets whether this occluder is active.
- `Occluder:isEnabled`: Returns whether this occluder is active.
- `Occluder:remove`: Removes this occluder from the world.
- `Occluder:isValid`: Returns whether this occluder handle is still valid.

## References

- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/light/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
