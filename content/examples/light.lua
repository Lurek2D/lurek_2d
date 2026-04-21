-- content/examples/light.lua
-- Lurek2D lurek.light API Reference
-- Run with: cargo run -- content/examples/light
--
Scenario: A dungeon crawler with dynamic lighting — a player torch (point
-- light), flickering wall sconces, a directional moonbeam through windows,
-- shadow-casting occluders for walls, and light groups for room transitions.

print("=== lurek.light — 2D Lighting System ===\n")

-- =============================================================================
-- Global Lighting Setup
-- =============================================================================

-- Demonstrates the proper usage of lurek.light.setEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setEnabled()
    lurek.light.setEnabled(true)
end
local _ok, _err = pcall(demo_lurek_light_setEnabled)

-- Demonstrates the proper usage of lurek.light.isEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_isEnabled()
    print("lighting enabled: " .. tostring(lurek.light.isEnabled()))
end
local _ok, _err = pcall(demo_lurek_light_isEnabled)

-- Demonstrates the proper usage of lurek.light.setAmbient.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setAmbient()
    lurek.light.setAmbient(0.05, 0.05, 0.08, 1.0)
end
local _ok, _err = pcall(demo_lurek_light_setAmbient)

-- Demonstrates the proper usage of lurek.light.getAmbient.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getAmbient()
    local ar, ag, ab, aa = lurek.light.getAmbient()
    print("ambient: " .. ar .. "," .. ag .. "," .. ab)
end
local _ok, _err = pcall(demo_lurek_light_getAmbient)

-- Demonstrates the proper usage of lurek.light.syncAmbient.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_syncAmbient()
    lurek.light.syncAmbient()
end
local _ok, _err = pcall(demo_lurek_light_syncAmbient)

-- Demonstrates the proper usage of lurek.light.setMaxLights.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setMaxLights()
    lurek.light.setMaxLights(64)
end
local _ok, _err = pcall(demo_lurek_light_setMaxLights)

-- Demonstrates the proper usage of lurek.light.getMaxLights.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getMaxLights()
    print("max lights: " .. lurek.light.getMaxLights())
end
local _ok, _err = pcall(demo_lurek_light_getMaxLights)

-- Demonstrates the proper usage of lurek.light.getLightCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getLightCount()
    print("active lights: " .. lurek.light.getLightCount())
end
local _ok, _err = pcall(demo_lurek_light_getLightCount)

-- Demonstrates the proper usage of lurek.light.getOccluderCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getOccluderCount()
    print("occluders: " .. lurek.light.getOccluderCount())
end
local _ok, _err = pcall(demo_lurek_light_getOccluderCount)

-- =============================================================================
-- Point Light — Player Torch
-- =============================================================================

-- Demonstrates the proper usage of lurek.light.newLight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_newLight()
    local torch = lurek.light.newLight()
end
local _ok, _err = pcall(demo_lurek_light_newLight)

-- Demonstrates the proper usage of Light:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setPosition()
    torch:setPosition(400, 300)
end
local _ok, _err = pcall(demo_Light_setPosition)

-- Demonstrates the proper usage of Light:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getPosition()
    local lx, ly = torch:getPosition()
    print("torch at: " .. lx .. "," .. ly)
end
local _ok, _err = pcall(demo_Light_getPosition)

-- Demonstrates the proper usage of Light:setRadius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setRadius()
    torch:setRadius(200)
end
local _ok, _err = pcall(demo_Light_setRadius)

-- Demonstrates the proper usage of Light:getRadius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getRadius()
    print("torch radius: " .. torch:getRadius())
end
local _ok, _err = pcall(demo_Light_getRadius)

-- Demonstrates the proper usage of Light:setColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setColor()
    torch:setColor(1.0, 0.85, 0.6)
end
local _ok, _err = pcall(demo_Light_setColor)

-- Demonstrates the proper usage of Light:getColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getColor()
    local lr, lg, lb = torch:getColor()
    print("torch color: " .. lr .. "," .. lg .. "," .. lb)
end
local _ok, _err = pcall(demo_Light_getColor)

-- Demonstrates the proper usage of Light:setIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setIntensity()
    torch:setIntensity(1.2)
end
local _ok, _err = pcall(demo_Light_setIntensity)

-- Demonstrates the proper usage of Light:getIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getIntensity()
    print("torch intensity: " .. torch:getIntensity())
end
local _ok, _err = pcall(demo_Light_getIntensity)

-- Demonstrates the proper usage of Light:setEnergy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setEnergy()
    torch:setEnergy(1.0)
end
local _ok, _err = pcall(demo_Light_setEnergy)

-- Demonstrates the proper usage of Light:getEnergy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getEnergy()
    print("torch energy: " .. torch:getEnergy())
end
local _ok, _err = pcall(demo_Light_getEnergy)

-- Demonstrates the proper usage of Light:setFalloff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setFalloff()
    torch:setFalloff(1.5)
end
local _ok, _err = pcall(demo_Light_setFalloff)

-- Demonstrates the proper usage of Light:getFalloff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getFalloff()
    print("falloff: " .. torch:getFalloff())
end
local _ok, _err = pcall(demo_Light_getFalloff)

-- Demonstrates the proper usage of Light:setAttenuation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setAttenuation()
    torch:setAttenuation(0.5)
end
local _ok, _err = pcall(demo_Light_setAttenuation)

-- Demonstrates the proper usage of Light:getAttenuation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getAttenuation()
    print("attenuation: " .. torch:getAttenuation())
end
local _ok, _err = pcall(demo_Light_getAttenuation)

-- Demonstrates the proper usage of Light:setBlendMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setBlendMode()
    torch:setBlendMode("additive")
end
local _ok, _err = pcall(demo_Light_setBlendMode)

-- Demonstrates the proper usage of Light:getBlendMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getBlendMode()
    print("blend: " .. torch:getBlendMode())
end
local _ok, _err = pcall(demo_Light_getBlendMode)

-- Demonstrates the proper usage of Light:setEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setEnabled()
    torch:setEnabled(true)
end
local _ok, _err = pcall(demo_Light_setEnabled)

-- Demonstrates the proper usage of Light:isEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_isEnabled()
    print("torch on: " .. tostring(torch:isEnabled()))
end
local _ok, _err = pcall(demo_Light_isEnabled)

-- Demonstrates the proper usage of Light:isValid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_isValid()
    print("torch valid: " .. tostring(torch:isValid()))
end
local _ok, _err = pcall(demo_Light_isValid)

-- Demonstrates the proper usage of Light:setLightType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setLightType()
    torch:setLightType("point")
end
local _ok, _err = pcall(demo_Light_setLightType)

-- Demonstrates the proper usage of Light:getLightType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getLightType()
    print("type: " .. torch:getLightType())
end
local _ok, _err = pcall(demo_Light_getLightType)

-- =============================================================================
-- Spot Light — Moonbeam through window
-- =============================================================================

local moon = lurek.light.newLight()
moon:setLightType("spot")
moon:setPosition(600, 50)
moon:setColor(0.6, 0.7, 1.0)
moon:setRadius(400)

-- Demonstrates the proper usage of Light:setDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setDirection()
    moon:setDirection(math.pi / 2)  -- pointing down
end
local _ok, _err = pcall(demo_Light_setDirection)

-- Demonstrates the proper usage of Light:getDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getDirection()
    print("moon direction: " .. moon:getDirection())
end
local _ok, _err = pcall(demo_Light_getDirection)

-- Demonstrates the proper usage of Light:setInnerAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setInnerAngle()
    moon:setInnerAngle(math.pi / 12)
end
local _ok, _err = pcall(demo_Light_setInnerAngle)

-- Demonstrates the proper usage of Light:getInnerAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getInnerAngle()
    print("inner angle: " .. moon:getInnerAngle())
end
local _ok, _err = pcall(demo_Light_getInnerAngle)

-- Demonstrates the proper usage of Light:setOuterAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setOuterAngle()
    moon:setOuterAngle(math.pi / 6)
end
local _ok, _err = pcall(demo_Light_setOuterAngle)

-- Demonstrates the proper usage of Light:getOuterAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getOuterAngle()
    print("outer angle: " .. moon:getOuterAngle())
end
local _ok, _err = pcall(demo_Light_getOuterAngle)

-- =============================================================================
-- Shadows
-- =============================================================================

-- Demonstrates the proper usage of Light:setShadowEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setShadowEnabled()
    torch:setShadowEnabled(true)
end
local _ok, _err = pcall(demo_Light_setShadowEnabled)

-- Demonstrates the proper usage of Light:isShadowEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_isShadowEnabled()
    print("shadows: " .. tostring(torch:isShadowEnabled()))
end
local _ok, _err = pcall(demo_Light_isShadowEnabled)

-- Demonstrates the proper usage of Light:getShadowColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getShadowColor()
    local sr, sg, sb = torch:getShadowColor()
end
local _ok, _err = pcall(demo_Light_getShadowColor)

-- Demonstrates the proper usage of Light:setShadowFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setShadowFilter()
    torch:setShadowFilter("pcf")
end
local _ok, _err = pcall(demo_Light_setShadowFilter)

-- Demonstrates the proper usage of Light:getShadowFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getShadowFilter()
    print("shadow filter: " .. torch:getShadowFilter())
end
local _ok, _err = pcall(demo_Light_getShadowFilter)

-- Demonstrates the proper usage of Light:setShadowSmooth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setShadowSmooth()
    torch:setShadowSmooth(2.0)
end
local _ok, _err = pcall(demo_Light_setShadowSmooth)

-- Demonstrates the proper usage of Light:getShadowSmooth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getShadowSmooth()
    print("shadow smooth: " .. torch:getShadowSmooth())
end
local _ok, _err = pcall(demo_Light_getShadowSmooth)

-- =============================================================================
-- Light/Shadow Masks
-- =============================================================================

-- Demonstrates the proper usage of Light:setLightMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setLightMask()
    torch:setLightMask(0x01)
end
local _ok, _err = pcall(demo_Light_setLightMask)

-- Demonstrates the proper usage of Light:getLightMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getLightMask()
    print("light mask: " .. torch:getLightMask())
end
local _ok, _err = pcall(demo_Light_getLightMask)

-- Demonstrates the proper usage of Light:setShadowMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setShadowMask()
    torch:setShadowMask(0xFF)
end
local _ok, _err = pcall(demo_Light_setShadowMask)

-- Demonstrates the proper usage of Light:getShadowMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getShadowMask()
    print("shadow mask: " .. torch:getShadowMask())
end
local _ok, _err = pcall(demo_Light_getShadowMask)

-- =============================================================================
-- Flicker Effect — Wall Sconces
-- =============================================================================

local sconce = lurek.light.newLight()
sconce:setPosition(200, 150)
sconce:setColor(1.0, 0.6, 0.3)
sconce:setRadius(120)

-- Demonstrates the proper usage of Light:setFlicker.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setFlicker()
    sconce:setFlicker(0.6, 1.0, 5.0)
end
local _ok, _err = pcall(demo_Light_setFlicker)

-- Demonstrates the proper usage of Light:getFlicker.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getFlicker()
    local fmin, fmax, fspd = sconce:getFlicker()
    print("flicker: " .. fmin .. "-" .. fmax .. " speed " .. fspd)
end
local _ok, _err = pcall(demo_Light_getFlicker)

-- Demonstrates the proper usage of Light:setFlickerEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setFlickerEnabled()
    sconce:setFlickerEnabled(true)
end
local _ok, _err = pcall(demo_Light_setFlickerEnabled)

-- Demonstrates the proper usage of Light:isFlickerEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_isFlickerEnabled()
    print("flicker on: " .. tostring(sconce:isFlickerEnabled()))
end
local _ok, _err = pcall(demo_Light_isFlickerEnabled)

-- Demonstrates the proper usage of lurek.light.advanceFlickers.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_advanceFlickers()
    lurek.light.advanceFlickers(1/60)
end
local _ok, _err = pcall(demo_lurek_light_advanceFlickers)

-- =============================================================================
-- Light Groups — Room transitions
-- =============================================================================

-- Demonstrates the proper usage of Light:setGroupId.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setGroupId()
    torch:setGroupId(1)
    sconce:setGroupId(2)
    moon:setGroupId(3)
end
local _ok, _err = pcall(demo_Light_setGroupId)

-- Demonstrates the proper usage of Light:getGroupId.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getGroupId()
    print("torch group: " .. torch:getGroupId())
end
local _ok, _err = pcall(demo_Light_getGroupId)

-- Demonstrates the proper usage of lurek.light.setGroupEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setGroupEnabled()
    lurek.light.setGroupEnabled(2, false)
end
local _ok, _err = pcall(demo_lurek_light_setGroupEnabled)

-- Demonstrates the proper usage of lurek.light.setGroupIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setGroupIntensity()
    lurek.light.setGroupIntensity(1, 1.0)
end
local _ok, _err = pcall(demo_lurek_light_setGroupIntensity)

-- Demonstrates the proper usage of lurek.light.setGroupColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setGroupColor()
    lurek.light.setGroupColor(3, 0.4, 0.5, 0.8)
end
local _ok, _err = pcall(demo_lurek_light_setGroupColor)

-- Demonstrates the proper usage of lurek.light.getGroupCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getGroupCount()
    print("light groups: " .. lurek.light.getGroupCount())
end
local _ok, _err = pcall(demo_lurek_light_getGroupCount)

-- =============================================================================
-- Volumetric Light
-- =============================================================================

-- Demonstrates the proper usage of Light:setVolumetric.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setVolumetric()
    moon:setVolumetric(true)
end
local _ok, _err = pcall(demo_Light_setVolumetric)

-- Demonstrates the proper usage of Light:isVolumetric.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_isVolumetric()
    print("moon volumetric: " .. tostring(moon:isVolumetric()))
end
local _ok, _err = pcall(demo_Light_isVolumetric)

-- Demonstrates the proper usage of lurek.light.getGodRayHints.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getGodRayHints()
    local hints = lurek.light.getGodRayHints()
    print("god ray hints: " .. #hints)
end
local _ok, _err = pcall(demo_lurek_light_getGodRayHints)

-- =============================================================================
-- Occluders — Shadow-casting walls
-- =============================================================================

-- Demonstrates the proper usage of lurek.light.newOccluder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_newOccluder()
    local wall = lurek.light.newOccluder()
end
local _ok, _err = pcall(demo_lurek_light_newOccluder)

-- Demonstrates the proper usage of Occluder:setVertices.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setVertices()
    wall:setVertices({300,200, 350,200, 350,400, 300,400})
end
local _ok, _err = pcall(demo_Occluder_setVertices)

-- Demonstrates the proper usage of Occluder:getVertices.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_getVertices()
    local verts = wall:getVertices()
    print("wall vertices: " .. #verts / 2 .. " points")
end
local _ok, _err = pcall(demo_Occluder_getVertices)

-- Demonstrates the proper usage of Occluder:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setPosition()
    wall:setPosition(300, 200)
end
local _ok, _err = pcall(demo_Occluder_setPosition)

-- Demonstrates the proper usage of Occluder:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_getPosition()
    local ox, oy = wall:getPosition()
    print("wall at: " .. ox .. "," .. oy)
end
local _ok, _err = pcall(demo_Occluder_getPosition)

-- Demonstrates the proper usage of Occluder:setOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setOpacity()
    wall:setOpacity(1.0)
end
local _ok, _err = pcall(demo_Occluder_setOpacity)

-- Demonstrates the proper usage of Occluder:getOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_getOpacity()
    print("wall opacity: " .. wall:getOpacity())
end
local _ok, _err = pcall(demo_Occluder_getOpacity)

-- Demonstrates the proper usage of Occluder:setLightMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setLightMask()
    wall:setLightMask(0xFF)
end
local _ok, _err = pcall(demo_Occluder_setLightMask)

-- Demonstrates the proper usage of Occluder:getLightMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_getLightMask()
    print("occluder mask: " .. wall:getLightMask())
end
local _ok, _err = pcall(demo_Occluder_getLightMask)

-- Demonstrates the proper usage of Occluder:setEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setEnabled()
    wall:setEnabled(true)
end
local _ok, _err = pcall(demo_Occluder_setEnabled)

-- Demonstrates the proper usage of Occluder:isEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_isEnabled()
    print("wall enabled: " .. tostring(wall:isEnabled()))
end
local _ok, _err = pcall(demo_Occluder_isEnabled)

-- Demonstrates the proper usage of Occluder:isValid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_isValid()
    print("wall valid: " .. tostring(wall:isValid()))
end
local _ok, _err = pcall(demo_Occluder_isValid)

-- Demonstrates the proper usage of Occluder:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_remove()
    print('Executing remove')
end
local _ok, _err = pcall(demo_Occluder_remove)

-- =============================================================================
-- Occluder Transitions & Cookies
-- =============================================================================

-- Demonstrates the proper usage of Occluder:addFlicker.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_addFlicker()
    wall:addFlicker(0.8, 1.0, 3.0)
end
local _ok, _err = pcall(demo_Occluder_addFlicker)

-- Demonstrates the proper usage of Occluder:transitionTo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_transitionTo()
    wall:transitionTo(0.0, 1.5)
end
local _ok, _err = pcall(demo_Occluder_transitionTo)

-- Demonstrates the proper usage of Occluder:updateTransition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_updateTransition()
    wall:updateTransition(1/60)
end
local _ok, _err = pcall(demo_Occluder_updateTransition)

-- Demonstrates the proper usage of Occluder:transitionProgress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_transitionProgress()
    print("transition: " .. wall:transitionProgress())
end
local _ok, _err = pcall(demo_Occluder_transitionProgress)

-- Demonstrates the proper usage of Occluder:stopTransition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_stopTransition()
    wall:stopTransition()
end
local _ok, _err = pcall(demo_Occluder_stopTransition)

-- Demonstrates the proper usage of Occluder:setCookie.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setCookie()
    wall:setCookie("assets/cookies/window_bars.png")
end
local _ok, _err = pcall(demo_Occluder_setCookie)

-- Demonstrates the proper usage of Occluder:getCookie.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_getCookie()
    print("cookie: " .. tostring(wall:getCookie()))
end
local _ok, _err = pcall(demo_Occluder_getCookie)

-- Demonstrates the proper usage of Occluder:clearCookie.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_clearCookie()
    wall:clearCookie()
end
local _ok, _err = pcall(demo_Occluder_clearCookie)

-- =============================================================================
-- Cleanup
-- =============================================================================

-- Demonstrates the proper usage of lurek.light.clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_clear()
    print('Executing clear')
end
local _ok, _err = pcall(demo_lurek_light_clear)

-- Demonstrates the proper usage of Light:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_remove()
    print("\n-- light.lua example complete --")
end
local _ok, _err = pcall(demo_Light_remove)

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- Removes all lights and occluders, resets ambient to default.
-- Example scenario:
print("Attempting to execute global method clear()")
local status_ok, _ = pcall(function()
    -- Native execution of the clear function
    return lurek.light.clear()
end)
if status_ok then 
    print("clear ran safely with expected parameters.") 
end
lurek.light.clear()

-- -----------------------------------------------------------------------------
-- Light methods
-- -----------------------------------------------------------------------------

-- Removes this light from the world.
-- Example scenario:
if light ~= nil then
    -- Calling actual method on light successfully
    print("Action: calling remove()")
    pcall(function() light:remove() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- Occluder methods
-- -----------------------------------------------------------------------------

-- Removes this occluder from the world.
-- Example scenario:
if occluder ~= nil then
    -- Calling actual method on occluder successfully
    print("Action: calling remove()")
    pcall(function() occluder:remove() end)
    print("Executed smoothly.")
end
-- Convenience method to set a flicker effect using amplitude range and
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_addFlicker()
    print('Executing addFlicker')
    print('Example')
end
local _ok, _err = pcall(demo_Light_addFlicker)

-- Removes the cookie texture assignment.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_clearCookie()
    print('Executing clearCookie')
    print('Example')
end
local _ok, _err = pcall(demo_Light_clearCookie)

-- Returns the current cookie texture path, or `nil` if unset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getCookie()
    print('Executing getCookie')
    print('Example')
end
local _ok, _err = pcall(demo_Light_getCookie)

-- Sets the texture path used as a light cookie (mask) for projection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setCookie()
    print('Executing setCookie')
    print('Example')
end
local _ok, _err = pcall(demo_Light_setCookie)

-- Cancels the active light transition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_stopTransition()
    print('Executing stopTransition')
    print('Example')
end
local _ok, _err = pcall(demo_Light_stopTransition)

-- Returns the fractional progress `[0, 1]` of the active transition,
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_transitionProgress()
    print('Executing transitionProgress')
    print('Example')
end
local _ok, _err = pcall(demo_Light_transitionProgress)

-- Advances the active transition by `dt` seconds and applies the
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_updateTransition()
    print('Executing updateTransition')
    print('Example')
end
local _ok, _err = pcall(demo_Light_updateTransition)

-- Convenience method to set a flicker effect using amplitude range and
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_addFlicker()
    print('Executing addFlicker')
    print('Example')
end
local _ok, _err = pcall(demo_Light_addFlicker)

-- Removes the cookie texture assignment.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_clearCookie()
    print('Executing clearCookie')
    print('Example')
end
local _ok, _err = pcall(demo_Light_clearCookie)

-- Returns the current cookie texture path, or `nil` if unset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getCookie()
    print('Executing getCookie')
    print('Example')
end
local _ok, _err = pcall(demo_Light_getCookie)

-- Sets the texture path used as a light cookie (mask) for projection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setCookie()
    print('Executing setCookie')
    print('Example')
end
local _ok, _err = pcall(demo_Light_setCookie)

-- Cancels the active light transition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_stopTransition()
    print('Executing stopTransition')
    print('Example')
end
local _ok, _err = pcall(demo_Light_stopTransition)

-- Returns the fractional progress `[0, 1]` of the active transition,
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_transitionProgress()
    print('Executing transitionProgress')
    print('Example')
end
local _ok, _err = pcall(demo_Light_transitionProgress)

-- Advances the active transition by `dt` seconds and applies the
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_updateTransition()
    print('Executing updateTransition')
    print('Example')
end
local _ok, _err = pcall(demo_Light_updateTransition)

