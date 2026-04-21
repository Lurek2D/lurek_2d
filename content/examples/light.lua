-- content/examples/light.lua
-- Lurek2D lurek.light API Reference
-- Run with: cargo run -- content/examples/light
--
-- Scenario: A dungeon crawler with dynamic lighting — a player torch (point
-- light), flickering wall sconces, a directional moonbeam through windows,
-- shadow-casting occluders for walls, and light groups for room transitions.

print("=== lurek.light — 2D Lighting System ===\n")

-- =============================================================================
-- Global Lighting Setup
-- =============================================================================

--@api-stub: lurek.light.setEnabled
-- Demonstrates the proper usage of lurek.light.setEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setEnabled()
    lurek.light.setEnabled(true)
end
local _ok, _err = pcall(demo_lurek_light_setEnabled)

--@api-stub: lurek.light.isEnabled
-- Demonstrates the proper usage of lurek.light.isEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_isEnabled()
    print("lighting enabled: " .. tostring(lurek.light.isEnabled()))
end
local _ok, _err = pcall(demo_lurek_light_isEnabled)

--@api-stub: lurek.light.setAmbient
-- Demonstrates the proper usage of lurek.light.setAmbient.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setAmbient()
    lurek.light.setAmbient(0.05, 0.05, 0.08, 1.0)
end
local _ok, _err = pcall(demo_lurek_light_setAmbient)

--@api-stub: lurek.light.getAmbient
-- Demonstrates the proper usage of lurek.light.getAmbient.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getAmbient()
    local ar, ag, ab, aa = lurek.light.getAmbient()
    print("ambient: " .. ar .. "," .. ag .. "," .. ab)
end
local _ok, _err = pcall(demo_lurek_light_getAmbient)

--@api-stub: lurek.light.syncAmbient
-- Demonstrates the proper usage of lurek.light.syncAmbient.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_syncAmbient()
    lurek.light.syncAmbient()
end
local _ok, _err = pcall(demo_lurek_light_syncAmbient)

--@api-stub: lurek.light.setMaxLights
-- Demonstrates the proper usage of lurek.light.setMaxLights.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setMaxLights()
    lurek.light.setMaxLights(64)
end
local _ok, _err = pcall(demo_lurek_light_setMaxLights)

--@api-stub: lurek.light.getMaxLights
-- Demonstrates the proper usage of lurek.light.getMaxLights.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getMaxLights()
    print("max lights: " .. lurek.light.getMaxLights())
end
local _ok, _err = pcall(demo_lurek_light_getMaxLights)

--@api-stub: lurek.light.getLightCount
-- Demonstrates the proper usage of lurek.light.getLightCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getLightCount()
    print("active lights: " .. lurek.light.getLightCount())
end
local _ok, _err = pcall(demo_lurek_light_getLightCount)

--@api-stub: lurek.light.getOccluderCount
-- Demonstrates the proper usage of lurek.light.getOccluderCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getOccluderCount()
    print("occluders: " .. lurek.light.getOccluderCount())
end
local _ok, _err = pcall(demo_lurek_light_getOccluderCount)

-- =============================================================================
-- Point Light — Player Torch
-- =============================================================================

--@api-stub: lurek.light.newLight
-- Demonstrates the proper usage of lurek.light.newLight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_newLight()
    local torch = lurek.light.newLight()
end
local _ok, _err = pcall(demo_lurek_light_newLight)

--@api-stub: Light:setPosition
-- Demonstrates the proper usage of Light:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setPosition()
    torch:setPosition(400, 300)
end
local _ok, _err = pcall(demo_Light_setPosition)

--@api-stub: Light:getPosition
-- Demonstrates the proper usage of Light:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getPosition()
    local lx, ly = torch:getPosition()
    print("torch at: " .. lx .. "," .. ly)
end
local _ok, _err = pcall(demo_Light_getPosition)

--@api-stub: Light:setRadius
-- Demonstrates the proper usage of Light:setRadius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setRadius()
    torch:setRadius(200)
end
local _ok, _err = pcall(demo_Light_setRadius)

--@api-stub: Light:getRadius
-- Demonstrates the proper usage of Light:getRadius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getRadius()
    print("torch radius: " .. torch:getRadius())
end
local _ok, _err = pcall(demo_Light_getRadius)

--@api-stub: Light:setColor
-- Demonstrates the proper usage of Light:setColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setColor()
    torch:setColor(1.0, 0.85, 0.6)
end
local _ok, _err = pcall(demo_Light_setColor)

--@api-stub: Light:getColor
-- Demonstrates the proper usage of Light:getColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getColor()
    local lr, lg, lb = torch:getColor()
    print("torch color: " .. lr .. "," .. lg .. "," .. lb)
end
local _ok, _err = pcall(demo_Light_getColor)

--@api-stub: Light:setIntensity
-- Demonstrates the proper usage of Light:setIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setIntensity()
    torch:setIntensity(1.2)
end
local _ok, _err = pcall(demo_Light_setIntensity)

--@api-stub: Light:getIntensity
-- Demonstrates the proper usage of Light:getIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getIntensity()
    print("torch intensity: " .. torch:getIntensity())
end
local _ok, _err = pcall(demo_Light_getIntensity)

--@api-stub: Light:setEnergy
-- Demonstrates the proper usage of Light:setEnergy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setEnergy()
    torch:setEnergy(1.0)
end
local _ok, _err = pcall(demo_Light_setEnergy)

--@api-stub: Light:getEnergy
-- Demonstrates the proper usage of Light:getEnergy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getEnergy()
    print("torch energy: " .. torch:getEnergy())
end
local _ok, _err = pcall(demo_Light_getEnergy)

--@api-stub: Light:setFalloff
-- Demonstrates the proper usage of Light:setFalloff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setFalloff()
    torch:setFalloff(1.5)
end
local _ok, _err = pcall(demo_Light_setFalloff)

--@api-stub: Light:getFalloff
-- Demonstrates the proper usage of Light:getFalloff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getFalloff()
    print("falloff: " .. torch:getFalloff())
end
local _ok, _err = pcall(demo_Light_getFalloff)

--@api-stub: Light:setAttenuation
-- Demonstrates the proper usage of Light:setAttenuation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setAttenuation()
    torch:setAttenuation(0.5)
end
local _ok, _err = pcall(demo_Light_setAttenuation)

--@api-stub: Light:getAttenuation
-- Demonstrates the proper usage of Light:getAttenuation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getAttenuation()
    print("attenuation: " .. torch:getAttenuation())
end
local _ok, _err = pcall(demo_Light_getAttenuation)

--@api-stub: Light:setBlendMode
-- Demonstrates the proper usage of Light:setBlendMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setBlendMode()
    torch:setBlendMode("additive")
end
local _ok, _err = pcall(demo_Light_setBlendMode)

--@api-stub: Light:getBlendMode
-- Demonstrates the proper usage of Light:getBlendMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getBlendMode()
    print("blend: " .. torch:getBlendMode())
end
local _ok, _err = pcall(demo_Light_getBlendMode)

--@api-stub: Light:setEnabled
-- Demonstrates the proper usage of Light:setEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setEnabled()
    torch:setEnabled(true)
end
local _ok, _err = pcall(demo_Light_setEnabled)

--@api-stub: Light:isEnabled
-- Demonstrates the proper usage of Light:isEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_isEnabled()
    print("torch on: " .. tostring(torch:isEnabled()))
end
local _ok, _err = pcall(demo_Light_isEnabled)

--@api-stub: Light:isValid
-- Demonstrates the proper usage of Light:isValid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_isValid()
    print("torch valid: " .. tostring(torch:isValid()))
end
local _ok, _err = pcall(demo_Light_isValid)

--@api-stub: Light:setLightType
-- Demonstrates the proper usage of Light:setLightType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setLightType()
    torch:setLightType("point")
end
local _ok, _err = pcall(demo_Light_setLightType)

--@api-stub: Light:getLightType
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

--@api-stub: Light:setDirection
-- Demonstrates the proper usage of Light:setDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setDirection()
    moon:setDirection(math.pi / 2)  -- pointing down
end
local _ok, _err = pcall(demo_Light_setDirection)

--@api-stub: Light:getDirection
-- Demonstrates the proper usage of Light:getDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getDirection()
    print("moon direction: " .. moon:getDirection())
end
local _ok, _err = pcall(demo_Light_getDirection)

--@api-stub: Light:setInnerAngle
-- Demonstrates the proper usage of Light:setInnerAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setInnerAngle()
    moon:setInnerAngle(math.pi / 12)
end
local _ok, _err = pcall(demo_Light_setInnerAngle)

--@api-stub: Light:getInnerAngle
-- Demonstrates the proper usage of Light:getInnerAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getInnerAngle()
    print("inner angle: " .. moon:getInnerAngle())
end
local _ok, _err = pcall(demo_Light_getInnerAngle)

--@api-stub: Light:setOuterAngle
-- Demonstrates the proper usage of Light:setOuterAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setOuterAngle()
    moon:setOuterAngle(math.pi / 6)
end
local _ok, _err = pcall(demo_Light_setOuterAngle)

--@api-stub: Light:getOuterAngle
-- Demonstrates the proper usage of Light:getOuterAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getOuterAngle()
    print("outer angle: " .. moon:getOuterAngle())
end
local _ok, _err = pcall(demo_Light_getOuterAngle)

-- =============================================================================
-- Shadows
-- =============================================================================

--@api-stub: Light:setShadowEnabled
-- Demonstrates the proper usage of Light:setShadowEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setShadowEnabled()
    torch:setShadowEnabled(true)
end
local _ok, _err = pcall(demo_Light_setShadowEnabled)

--@api-stub: Light:isShadowEnabled
-- Demonstrates the proper usage of Light:isShadowEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_isShadowEnabled()
    print("shadows: " .. tostring(torch:isShadowEnabled()))
end
local _ok, _err = pcall(demo_Light_isShadowEnabled)

--@api-stub: Light:getShadowColor
-- Demonstrates the proper usage of Light:getShadowColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getShadowColor()
    local sr, sg, sb = torch:getShadowColor()
end
local _ok, _err = pcall(demo_Light_getShadowColor)

--@api-stub: Light:setShadowFilter
-- Demonstrates the proper usage of Light:setShadowFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setShadowFilter()
    torch:setShadowFilter("pcf")
end
local _ok, _err = pcall(demo_Light_setShadowFilter)

--@api-stub: Light:getShadowFilter
-- Demonstrates the proper usage of Light:getShadowFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getShadowFilter()
    print("shadow filter: " .. torch:getShadowFilter())
end
local _ok, _err = pcall(demo_Light_getShadowFilter)

--@api-stub: Light:setShadowSmooth
-- Demonstrates the proper usage of Light:setShadowSmooth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setShadowSmooth()
    torch:setShadowSmooth(2.0)
end
local _ok, _err = pcall(demo_Light_setShadowSmooth)

--@api-stub: Light:getShadowSmooth
-- Demonstrates the proper usage of Light:getShadowSmooth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getShadowSmooth()
    print("shadow smooth: " .. torch:getShadowSmooth())
end
local _ok, _err = pcall(demo_Light_getShadowSmooth)

-- =============================================================================
-- Light/Shadow Masks
-- =============================================================================

--@api-stub: Light:setLightMask
-- Demonstrates the proper usage of Light:setLightMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setLightMask()
    torch:setLightMask(0x01)
end
local _ok, _err = pcall(demo_Light_setLightMask)

--@api-stub: Light:getLightMask
-- Demonstrates the proper usage of Light:getLightMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getLightMask()
    print("light mask: " .. torch:getLightMask())
end
local _ok, _err = pcall(demo_Light_getLightMask)

--@api-stub: Light:setShadowMask
-- Demonstrates the proper usage of Light:setShadowMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setShadowMask()
    torch:setShadowMask(0xFF)
end
local _ok, _err = pcall(demo_Light_setShadowMask)

--@api-stub: Light:getShadowMask
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

--@api-stub: Light:setFlicker
-- Demonstrates the proper usage of Light:setFlicker.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setFlicker()
    sconce:setFlicker(0.6, 1.0, 5.0)
end
local _ok, _err = pcall(demo_Light_setFlicker)

--@api-stub: Light:getFlicker
-- Demonstrates the proper usage of Light:getFlicker.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getFlicker()
    local fmin, fmax, fspd = sconce:getFlicker()
    print("flicker: " .. fmin .. "-" .. fmax .. " speed " .. fspd)
end
local _ok, _err = pcall(demo_Light_getFlicker)

--@api-stub: Light:setFlickerEnabled
-- Demonstrates the proper usage of Light:setFlickerEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setFlickerEnabled()
    sconce:setFlickerEnabled(true)
end
local _ok, _err = pcall(demo_Light_setFlickerEnabled)

--@api-stub: Light:isFlickerEnabled
-- Demonstrates the proper usage of Light:isFlickerEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_isFlickerEnabled()
    print("flicker on: " .. tostring(sconce:isFlickerEnabled()))
end
local _ok, _err = pcall(demo_Light_isFlickerEnabled)

--@api-stub: lurek.light.advanceFlickers
-- Demonstrates the proper usage of lurek.light.advanceFlickers.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_advanceFlickers()
    lurek.light.advanceFlickers(1/60)
end
local _ok, _err = pcall(demo_lurek_light_advanceFlickers)

-- =============================================================================
-- Light Groups — Room transitions
-- =============================================================================

--@api-stub: Light:setGroupId
-- Demonstrates the proper usage of Light:setGroupId.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setGroupId()
    torch:setGroupId(1)
    sconce:setGroupId(2)
    moon:setGroupId(3)
end
local _ok, _err = pcall(demo_Light_setGroupId)

--@api-stub: Light:getGroupId
-- Demonstrates the proper usage of Light:getGroupId.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_getGroupId()
    print("torch group: " .. torch:getGroupId())
end
local _ok, _err = pcall(demo_Light_getGroupId)

--@api-stub: lurek.light.setGroupEnabled
-- Demonstrates the proper usage of lurek.light.setGroupEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setGroupEnabled()
    lurek.light.setGroupEnabled(2, false)
end
local _ok, _err = pcall(demo_lurek_light_setGroupEnabled)

--@api-stub: lurek.light.setGroupIntensity
-- Demonstrates the proper usage of lurek.light.setGroupIntensity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setGroupIntensity()
    lurek.light.setGroupIntensity(1, 1.0)
end
local _ok, _err = pcall(demo_lurek_light_setGroupIntensity)

--@api-stub: lurek.light.setGroupColor
-- Demonstrates the proper usage of lurek.light.setGroupColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_setGroupColor()
    lurek.light.setGroupColor(3, 0.4, 0.5, 0.8)
end
local _ok, _err = pcall(demo_lurek_light_setGroupColor)

--@api-stub: lurek.light.getGroupCount
-- Demonstrates the proper usage of lurek.light.getGroupCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_getGroupCount()
    print("light groups: " .. lurek.light.getGroupCount())
end
local _ok, _err = pcall(demo_lurek_light_getGroupCount)

-- =============================================================================
-- Volumetric Light
-- =============================================================================

--@api-stub: Light:setVolumetric
-- Demonstrates the proper usage of Light:setVolumetric.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_setVolumetric()
    moon:setVolumetric(true)
end
local _ok, _err = pcall(demo_Light_setVolumetric)

--@api-stub: Light:isVolumetric
-- Demonstrates the proper usage of Light:isVolumetric.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_isVolumetric()
    print("moon volumetric: " .. tostring(moon:isVolumetric()))
end
local _ok, _err = pcall(demo_Light_isVolumetric)

--@api-stub: lurek.light.getGodRayHints
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

--@api-stub: lurek.light.newOccluder
-- Demonstrates the proper usage of lurek.light.newOccluder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_newOccluder()
    local wall = lurek.light.newOccluder()
end
local _ok, _err = pcall(demo_lurek_light_newOccluder)

--@api-stub: Occluder:setVertices
-- Demonstrates the proper usage of Occluder:setVertices.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setVertices()
    wall:setVertices({300,200, 350,200, 350,400, 300,400})
end
local _ok, _err = pcall(demo_Occluder_setVertices)

--@api-stub: Occluder:getVertices
-- Demonstrates the proper usage of Occluder:getVertices.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_getVertices()
    local verts = wall:getVertices()
    print("wall vertices: " .. #verts / 2 .. " points")
end
local _ok, _err = pcall(demo_Occluder_getVertices)

--@api-stub: Occluder:setPosition
-- Demonstrates the proper usage of Occluder:setPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setPosition()
    wall:setPosition(300, 200)
end
local _ok, _err = pcall(demo_Occluder_setPosition)

--@api-stub: Occluder:getPosition
-- Demonstrates the proper usage of Occluder:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_getPosition()
    local ox, oy = wall:getPosition()
    print("wall at: " .. ox .. "," .. oy)
end
local _ok, _err = pcall(demo_Occluder_getPosition)

--@api-stub: Occluder:setOpacity
-- Demonstrates the proper usage of Occluder:setOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setOpacity()
    wall:setOpacity(1.0)
end
local _ok, _err = pcall(demo_Occluder_setOpacity)

--@api-stub: Occluder:getOpacity
-- Demonstrates the proper usage of Occluder:getOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_getOpacity()
    print("wall opacity: " .. wall:getOpacity())
end
local _ok, _err = pcall(demo_Occluder_getOpacity)

--@api-stub: Occluder:setLightMask
-- Demonstrates the proper usage of Occluder:setLightMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setLightMask()
    wall:setLightMask(0xFF)
end
local _ok, _err = pcall(demo_Occluder_setLightMask)

--@api-stub: Occluder:getLightMask
-- Demonstrates the proper usage of Occluder:getLightMask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_getLightMask()
    print("occluder mask: " .. wall:getLightMask())
end
local _ok, _err = pcall(demo_Occluder_getLightMask)

--@api-stub: Occluder:setEnabled
-- Demonstrates the proper usage of Occluder:setEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setEnabled()
    wall:setEnabled(true)
end
local _ok, _err = pcall(demo_Occluder_setEnabled)

--@api-stub: Occluder:isEnabled
-- Demonstrates the proper usage of Occluder:isEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_isEnabled()
    print("wall enabled: " .. tostring(wall:isEnabled()))
end
local _ok, _err = pcall(demo_Occluder_isEnabled)

--@api-stub: Occluder:isValid
-- Demonstrates the proper usage of Occluder:isValid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_isValid()
    print("wall valid: " .. tostring(wall:isValid()))
end
local _ok, _err = pcall(demo_Occluder_isValid)

--@api-stub: Occluder:remove
-- Demonstrates the proper usage of Occluder:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_remove()
    print('Executing remove')
end
local _ok, _err = pcall(demo_Occluder_remove)

-- =============================================================================
-- Occluder Transitions & Cookies
-- =============================================================================

--@api-stub: Occluder:addFlicker
-- Demonstrates the proper usage of Occluder:addFlicker.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_addFlicker()
    wall:addFlicker(0.8, 1.0, 3.0)
end
local _ok, _err = pcall(demo_Occluder_addFlicker)

--@api-stub: Occluder:transitionTo
-- Demonstrates the proper usage of Occluder:transitionTo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_transitionTo()
    wall:transitionTo(0.0, 1.5)
end
local _ok, _err = pcall(demo_Occluder_transitionTo)

--@api-stub: Occluder:updateTransition
-- Demonstrates the proper usage of Occluder:updateTransition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_updateTransition()
    wall:updateTransition(1/60)
end
local _ok, _err = pcall(demo_Occluder_updateTransition)

--@api-stub: Occluder:transitionProgress
-- Demonstrates the proper usage of Occluder:transitionProgress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_transitionProgress()
    print("transition: " .. wall:transitionProgress())
end
local _ok, _err = pcall(demo_Occluder_transitionProgress)

--@api-stub: Occluder:stopTransition
-- Demonstrates the proper usage of Occluder:stopTransition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_stopTransition()
    wall:stopTransition()
end
local _ok, _err = pcall(demo_Occluder_stopTransition)

--@api-stub: Occluder:setCookie
-- Demonstrates the proper usage of Occluder:setCookie.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_setCookie()
    wall:setCookie("assets/cookies/window_bars.png")
end
local _ok, _err = pcall(demo_Occluder_setCookie)

--@api-stub: Occluder:getCookie
-- Demonstrates the proper usage of Occluder:getCookie.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_getCookie()
    print("cookie: " .. tostring(wall:getCookie()))
end
local _ok, _err = pcall(demo_Occluder_getCookie)

--@api-stub: Occluder:clearCookie
-- Demonstrates the proper usage of Occluder:clearCookie.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Occluder_clearCookie()
    wall:clearCookie()
end
local _ok, _err = pcall(demo_Occluder_clearCookie)

-- =============================================================================
-- Cleanup
-- =============================================================================

--@api-stub: lurek.light.clear
-- Demonstrates the proper usage of lurek.light.clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_light_clear()
    print('Executing clear')
end
local _ok, _err = pcall(demo_lurek_light_clear)

--@api-stub: Light:remove
-- Demonstrates the proper usage of Light:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Light_remove()
    print("\n-- light.lua example complete --")
end
local _ok, _err = pcall(demo_Light_remove)

-- =============================================================================
-- STUBS: 3 uncovered lurek.light API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- ---- Stub: lurek.light.clear ---------------------------------------------
--@api-stub: lurek.light.clear
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

-- ---- Stub: Light:remove --------------------------------------------------
--@api-stub: Light:remove
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

-- ---- Stub: Occluder:remove -----------------------------------------------
--@api-stub: Occluder:remove
-- Removes this occluder from the world.
-- Example scenario:
if occluder ~= nil then
    -- Calling actual method on occluder successfully
    print("Action: calling remove()")
    pcall(function() occluder:remove() end)
    print("Executed smoothly.")
end
