-- content/examples/light.lua
-- love2d-style usage snippets for the lurek.light API (83 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/light.lua

-- ── lurek.light.* functions ──

--@api-stub: lurek.light.newLight
-- Creates a new light at (x, y) with the given radius and optional settings.
-- Build once at startup; reuse across frames.
local light = lurek.light.newLight(100, 100, radius, { x = 0, y = 0 })
print("created", light)
return light

--@api-stub: lurek.light.newOccluder
-- Creates a new shadow occluder from a vertex table and optional settings.
-- Build once at startup; reuse across frames.
local occluder = lurek.light.newOccluder(vtbl, { x = 0, y = 0 })
print("created", occluder)
return occluder

--@api-stub: lurek.light.setAmbient
-- Sets the global ambient light color.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.light.setAmbient(1, 0.5, 0, 1)
print("setAmbient applied")
print("ok")

--@api-stub: lurek.light.getAmbient
-- Returns the global ambient light color as (r, g, b, a).
-- Cheap to call; safe inside callbacks.
local value = lurek.light.getAmbient()
print("getAmbient:", value)
return value

--@api-stub: lurek.light.setEnabled
-- Sets whether the lighting system is active.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.light.setEnabled(enabled)
print("setEnabled applied")
print("ok")

--@api-stub: lurek.light.isEnabled
-- Returns whether the lighting system is active.
-- Use as a guard inside lurek.update or event handlers.
if lurek.light.isEnabled() then
  print("isEnabled -> true")
end

--@api-stub: lurek.light.getLightCount
-- Returns the number of lights in the world.
-- Cheap to call; safe inside callbacks.
local value = lurek.light.getLightCount()
print("getLightCount:", value)
return value

--@api-stub: lurek.light.getOccluderCount
-- Returns the number of occluders in the world.
-- Cheap to call; safe inside callbacks.
local value = lurek.light.getOccluderCount()
print("getOccluderCount:", value)
return value

--@api-stub: lurek.light.getMaxLights
-- Returns the maximum number of lights processed per frame.
-- Cheap to call; safe inside callbacks.
local value = lurek.light.getMaxLights()
print("getMaxLights:", value)
return value

--@api-stub: lurek.light.setMaxLights
-- Sets the maximum number of lights processed per frame (clamped 1â€“256).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.light.setMaxLights(10)
print("setMaxLights applied")
print("ok")

--@api-stub: lurek.light.clear
-- Removes all lights and occluders, resets ambient to default.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.light.clear()
print("clear done")
print("ok")

--@api-stub: lurek.light.setGroupEnabled
-- Sets the enabled state for all lights in the given group.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.light.setGroupEnabled(1, enabled)
print("setGroupEnabled applied")
print("ok")

--@api-stub: lurek.light.setGroupIntensity
-- Sets the intensity for all lights in the given group.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.light.setGroupIntensity(1, intensity)
print("setGroupIntensity applied")
print("ok")

--@api-stub: lurek.light.setGroupColor
-- Sets the color for all lights in the given group.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.light.setGroupColor(1, 1, 0.5, 0, 1)
print("setGroupColor applied")
print("ok")

--@api-stub: lurek.light.getGroupCount
-- Returns the number of lights in the given group.
-- Cheap to call; safe inside callbacks.
local value = lurek.light.getGroupCount(1)
print("getGroupCount:", value)
return value

--@api-stub: lurek.light.advanceFlickers
-- Advances flicker phase for all lights with flicker enabled.
-- See the module spec for detailed semantics.
local result = lurek.light.advanceFlickers(dt)
print("advanceFlickers:", result)
return result

--@api-stub: lurek.light.syncAmbient
-- Returns the current ambient light colour as (r, g, b, a).
-- See the module spec for detailed semantics.
local result = lurek.light.syncAmbient()
print("syncAmbient:", result)
return result

--@api-stub: lurek.light.getGodRayHints
-- Returns a list of directional light hints for god-ray rendering.
-- Cheap to call; safe inside callbacks.
local value = lurek.light.getGodRayHints()
print("getGodRayHints:", value)
return value

-- ── Light methods ──

--@api-stub: Light:setPosition
-- Sets the light's world-space position.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setPosition(100, 100)
print("Light:setPosition applied")

--@api-stub: Light:getPosition
-- Returns the light's world-space position.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getPosition()
print("Light:getPosition ->", value)

--@api-stub: Light:setRadius
-- Sets the light's influence radius.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setRadius(1)
print("Light:setRadius applied")

--@api-stub: Light:getRadius
-- Returns the light's influence radius.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getRadius()
print("Light:getRadius ->", value)

--@api-stub: Light:getColor
-- Returns the light's tint color as (r, g, b, a).
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getColor()
print("Light:getColor ->", value)

--@api-stub: Light:setIntensity
-- Sets the brightness multiplier.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setIntensity(i)
print("Light:setIntensity applied")

--@api-stub: Light:getIntensity
-- Returns the brightness multiplier.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getIntensity()
print("Light:getIntensity ->", value)

--@api-stub: Light:setEnergy
-- Sets the energy scaling factor.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setEnergy(e)
print("Light:setEnergy applied")

--@api-stub: Light:getEnergy
-- Returns the energy scaling factor.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getEnergy()
print("Light:getEnergy ->", value)

--@api-stub: Light:setBlendMode
-- Sets the blend mode ('add', 'sub', or 'mix').
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setBlendMode(mode)
print("Light:setBlendMode applied")

--@api-stub: Light:getBlendMode
-- Returns the blend mode as a string.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getBlendMode()
print("Light:getBlendMode ->", value)

--@api-stub: Light:setFalloff
-- Sets the falloff mode ('linear', 'smooth', or 'constant').
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setFalloff(mode)
print("Light:setFalloff applied")

--@api-stub: Light:getFalloff
-- Returns the falloff mode as a string.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getFalloff()
print("Light:getFalloff ->", value)

--@api-stub: Light:setShadowEnabled
-- Sets whether this light casts shadows.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setShadowEnabled(0)
print("Light:setShadowEnabled applied")

--@api-stub: Light:isShadowEnabled
-- Returns whether this light casts shadows.
-- Use as a guard inside lurek.update or event handlers.
local light = lurek.light.newLight()
if light:isShadowEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Light:getShadowColor
-- Returns the shadow region color as (r, g, b, a).
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getShadowColor()
print("Light:getShadowColor ->", value)

--@api-stub: Light:setShadowFilter
-- Sets the shadow edge filter ('none', 'pcf5', or 'pcf13').
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setShadowFilter(filter)
print("Light:setShadowFilter applied")

--@api-stub: Light:getShadowFilter
-- Returns the shadow edge filter as a string.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getShadowFilter()
print("Light:getShadowFilter ->", value)

--@api-stub: Light:setShadowSmooth
-- Sets the shadow edge smoothing factor.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setShadowSmooth(s)
print("Light:setShadowSmooth applied")

--@api-stub: Light:getShadowSmooth
-- Returns the shadow edge smoothing factor.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getShadowSmooth()
print("Light:getShadowSmooth ->", value)

--@api-stub: Light:setLightMask
-- Sets the light interaction bitmask.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setLightMask(mask)
print("Light:setLightMask applied")

--@api-stub: Light:getLightMask
-- Returns the light interaction bitmask.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getLightMask()
print("Light:getLightMask ->", value)

--@api-stub: Light:setShadowMask
-- Sets the shadow casting bitmask.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setShadowMask(mask)
print("Light:setShadowMask applied")

--@api-stub: Light:getShadowMask
-- Returns the shadow casting bitmask.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getShadowMask()
print("Light:getShadowMask ->", value)

--@api-stub: Light:setEnabled
-- Sets whether this light is active.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setEnabled(0)
print("Light:setEnabled applied")

--@api-stub: Light:isEnabled
-- Returns whether this light is active.
-- Use as a guard inside lurek.update or event handlers.
local light = lurek.light.newLight()
if light:isEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Light:setLightType
-- Sets the geometric light type ('point', 'directional', or 'spot').
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setLightType(t)
print("Light:setLightType applied")

--@api-stub: Light:getLightType
-- Returns the geometric light type as a string.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getLightType()
print("Light:getLightType ->", value)

--@api-stub: Light:setDirection
-- Sets the direction angle in radians.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setDirection("data/file.txt")
print("Light:setDirection applied")

--@api-stub: Light:getDirection
-- Returns the direction angle in radians.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getDirection()
print("Light:getDirection ->", value)

--@api-stub: Light:setInnerAngle
-- Sets the inner cone angle in radians for spot lights.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setInnerAngle(1)
print("Light:setInnerAngle applied")

--@api-stub: Light:getInnerAngle
-- Returns the inner cone angle in radians.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getInnerAngle()
print("Light:getInnerAngle ->", value)

--@api-stub: Light:setOuterAngle
-- Sets the outer cone angle in radians for spot lights.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setOuterAngle(1)
print("Light:setOuterAngle applied")

--@api-stub: Light:getOuterAngle
-- Returns the outer cone angle in radians.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getOuterAngle()
print("Light:getOuterAngle ->", value)

--@api-stub: Light:setAttenuation
-- Sets the custom attenuation coefficients (constant, linear, quadratic).
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setAttenuation(c, l, q)
print("Light:setAttenuation applied")

--@api-stub: Light:getAttenuation
-- Returns the custom attenuation coefficients as (constant, linear, quadratic).
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getAttenuation()
print("Light:getAttenuation ->", value)

--@api-stub: Light:setFlicker
-- Sets the flicker effect speed and strength (enables flicker).
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setFlicker(speed, "hello")
print("Light:setFlicker applied")

--@api-stub: Light:getFlicker
-- Returns the flicker effect speed and strength.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getFlicker()
print("Light:getFlicker ->", value)

--@api-stub: Light:setFlickerEnabled
-- Sets whether the flicker effect is active.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setFlickerEnabled(0)
print("Light:setFlickerEnabled applied")

--@api-stub: Light:isFlickerEnabled
-- Returns whether the flicker effect is active.
-- Use as a guard inside lurek.update or event handlers.
local light = lurek.light.newLight()
if light:isFlickerEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Light:setGroupId
-- Sets the group identifier for batch operations.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setGroupId(1)
print("Light:setGroupId applied")

--@api-stub: Light:getGroupId
-- Returns the group identifier.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getGroupId()
print("Light:getGroupId ->", value)

--@api-stub: Light:setVolumetric
-- Sets whether this light hints at volumetric scattering.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setVolumetric(0)
print("Light:setVolumetric applied")

--@api-stub: Light:isVolumetric
-- Returns whether this light hints at volumetric scattering.
-- Use as a guard inside lurek.update or event handlers.
local light = lurek.light.newLight()
if light:isVolumetric() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Light:remove
-- Removes this light from the world.
-- Pair with the matching constructor to free resources.
local light = lurek.light.newLight()
light:remove()
-- light is now released
print("ok")

--@api-stub: Light:isValid
-- Returns whether this light handle is still valid.
-- Use as a guard inside lurek.update or event handlers.
local light = lurek.light.newLight()
if light:isValid() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Light:addFlicker
-- Convenience method to set a flicker effect using amplitude range and.
-- Side-effecting; safe to call any time after init.
local light = lurek.light.newLight()
light:addFlicker(0, 100, hz)
print("Light:addFlicker done")

--@api-stub: Light:updateTransition
-- Advances the active transition by `dt` seconds and applies the.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:updateTransition(dt)
print("Light:updateTransition applied")

--@api-stub: Light:stopTransition
-- Cancels the active light transition.
-- Trigger from input, timers, or game events.
local light = lurek.light.newLight()
light:stopTransition()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Light:transitionProgress
-- Returns the fractional progress `[0, 1]` of the active transition,.
-- See the module spec for detailed semantics.
local light = lurek.light.newLight()
light:transitionProgress()
print("Light:transitionProgress done")

--@api-stub: Light:setCookie
-- Sets the texture path used as a light cookie (mask) for projection.
-- Apply at startup or in response to user input.
local light = lurek.light.newLight()
light:setCookie("data/file.txt")
print("Light:setCookie applied")

--@api-stub: Light:getCookie
-- Returns the current cookie texture path, or `nil` if unset.
-- Cheap to call; safe inside callbacks.
local light = lurek.light.newLight()  -- or your existing handle
local value = light:getCookie()
print("Light:getCookie ->", value)

--@api-stub: Light:clearCookie
-- Removes the cookie texture assignment.
-- Pair with the matching constructor to free resources.
local light = lurek.light.newLight()
light:clearCookie()
-- light is now released
print("ok")

-- ── Occluder methods ──

--@api-stub: Occluder:setVertices
-- Replaces the polygon vertices from a flat table {x1,y1,x2,y2,...}.
-- Apply at startup or in response to user input.
local occluder = lurek.light.newOccluder()
occluder:setVertices(tbl)
print("Occluder:setVertices applied")

--@api-stub: Occluder:getVertices
-- Returns the polygon vertices as a flat table {x1,y1,x2,y2,...}.
-- Cheap to call; safe inside callbacks.
local occluder = lurek.light.newOccluder()  -- or your existing handle
local value = occluder:getVertices()
print("Occluder:getVertices ->", value)

--@api-stub: Occluder:setPosition
-- Sets the translation offset applied to all vertices.
-- Apply at startup or in response to user input.
local occluder = lurek.light.newOccluder()
occluder:setPosition(100, 100)
print("Occluder:setPosition applied")

--@api-stub: Occluder:getPosition
-- Returns the translation offset as (x, y).
-- Cheap to call; safe inside callbacks.
local occluder = lurek.light.newOccluder()  -- or your existing handle
local value = occluder:getPosition()
print("Occluder:getPosition ->", value)

--@api-stub: Occluder:setOpacity
-- Sets the shadow opacity (0.0â€“1.0).
-- Apply at startup or in response to user input.
local occluder = lurek.light.newOccluder()
occluder:setOpacity(o)
print("Occluder:setOpacity applied")

--@api-stub: Occluder:getOpacity
-- Returns the shadow opacity.
-- Cheap to call; safe inside callbacks.
local occluder = lurek.light.newOccluder()  -- or your existing handle
local value = occluder:getOpacity()
print("Occluder:getOpacity ->", value)

--@api-stub: Occluder:setLightMask
-- Sets the light interaction bitmask.
-- Apply at startup or in response to user input.
local occluder = lurek.light.newOccluder()
occluder:setLightMask(mask)
print("Occluder:setLightMask applied")

--@api-stub: Occluder:getLightMask
-- Returns the light interaction bitmask.
-- Cheap to call; safe inside callbacks.
local occluder = lurek.light.newOccluder()  -- or your existing handle
local value = occluder:getLightMask()
print("Occluder:getLightMask ->", value)

--@api-stub: Occluder:setEnabled
-- Sets whether this occluder is active.
-- Apply at startup or in response to user input.
local occluder = lurek.light.newOccluder()
occluder:setEnabled(0)
print("Occluder:setEnabled applied")

--@api-stub: Occluder:isEnabled
-- Returns whether this occluder is active.
-- Use as a guard inside lurek.update or event handlers.
local occluder = lurek.light.newOccluder()
if occluder:isEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Occluder:remove
-- Removes this occluder from the world.
-- Pair with the matching constructor to free resources.
local occluder = lurek.light.newOccluder()
occluder:remove()
-- occluder is now released
print("ok")

--@api-stub: Occluder:isValid
-- Returns whether this occluder handle is still valid.
-- Use as a guard inside lurek.update or event handlers.
local occluder = lurek.light.newOccluder()
if occluder:isValid() then print("yes") end
-- swap the constructor for your real handle
print("ok")

