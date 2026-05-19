-- content/examples/light.lua
-- Auto-generated from content/examples2/light_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/light.lua

--- Light Module Part 1: module functions and LLight class

--@api-stub: lurek.light.newLight
-- Creates a point light with position, radius, and optional settings.
do
    local light = lurek.light.newLight(400, 300, 200)
    print("light type = " .. light:getLightType())
    print("radius = " .. light:getRadius())
end

-- Creates a light with full options table.
--@api-stub: lurek.light.newLight
do
    local light = lurek.light.newLight(100, 100, 150, {
        color = {1, 0.8, 0.5, 1},
        intensity = 2.0,
        falloff = "smooth",
    })
    local r, g, b, a = light:getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    print("intensity = " .. light:getIntensity())
end

--@api-stub: lurek.light.setEnabled
-- Enables or disables the light world.
do
    lurek.light.setEnabled(true)
    print("light world enabled = " .. tostring(lurek.light.isEnabled()))
end

--@api-stub: lurek.light.setAmbient
-- Sets and queries global ambient color.
do
    lurek.light.setAmbient(0.1, 0.1, 0.15, 1)
    local r, g, b, a = lurek.light.getAmbient()
    print("ambient = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.light.getLightCount
-- Returns number of live lights.
do
    lurek.light.clear()
    lurek.light.newLight(0, 0, 100)
    lurek.light.newLight(50, 50, 80)
    print("lights = " .. lurek.light.getLightCount())
end

--@api-stub: lurek.light.getMaxLights
-- Configures max light slots.
do
    lurek.light.setMaxLights(128)
    print("max lights = " .. lurek.light.getMaxLights())
end

--@api-stub: lurek.light.clear
-- Removes all lights and occluders.
do
    lurek.light.newLight(0, 0, 50)
    lurek.light.clear()
    print("after clear: lights = " .. lurek.light.getLightCount())
end

--@api-stub: lurek.light.advanceFlickers
-- Updates flicker animation.
do
    local light = lurek.light.newLight(200, 200, 100)
    light:addFlicker(0.5, 1.0, 4.0)
    light:setFlickerEnabled(true)
    lurek.light.advanceFlickers(0.016)
    print("flickers advanced")
end

--@api-stub: lurek.light.getGroupCount
-- Returns lights in a group.
do
    local a = lurek.light.newLight(0, 0, 50)
    local b = lurek.light.newLight(10, 10, 50)
    a:setGroupId(1)
    b:setGroupId(1)
    print("group 1 count = " .. lurek.light.getGroupCount(1))
end

--@api-stub: lurek.light.setGroupColor
-- Sets color for all lights in a group.
do
    lurek.light.setGroupColor(1, 1, 0, 0, 1)
    print("group 1 set to red")
end

--@api-stub: lurek.light.setGroupIntensity
-- Sets intensity for all lights in a group.
do
    lurek.light.setGroupIntensity(1, 3.0)
    print("group 1 intensity = 3")
end

--@api-stub: lurek.light.setGroupEnabled
-- Enables or disables a group.
do
    lurek.light.setGroupEnabled(1, false)
    print("group 1 disabled")
end

--@api-stub: lurek.light.getGodRayHints
-- Returns directional light hints.
do
    local hints = lurek.light.getGodRayHints()
    print("god ray hints = " .. #hints)
end

--@api-stub: lurek.light.getNormalMapHints
-- Returns normal map light hints.
do
    local hints = lurek.light.getNormalMapHints()
    print("normal map hints = " .. #hints)
end

--@api-stub: lurek.light.syncAmbient
-- Returns ambient color hint.
do
    local r, g, b, a = lurek.light.syncAmbient()
    print("sync ambient = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:setPosition
--@api-stub: LLight:getPosition
-- Sets and gets light position.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    print("pos = " .. x .. "," .. y)
end

--@api-stub: LLight:setRadius
--@api-stub: LLight:getRadius
-- Sets and gets light radius.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setRadius(250)
    print("radius = " .. light:getRadius())
end

--@api-stub: LLight:setColor
--@api-stub: LLight:getColor
-- Sets and gets light RGBA color.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:setIntensity
--@api-stub: LLight:getIntensity
-- Sets and gets intensity.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setIntensity(5)
    print("intensity = " .. light:getIntensity())
end

--@api-stub: LLight:setEnergy
--@api-stub: LLight:getEnergy
-- Sets and gets energy.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnergy(2.5)
    print("energy = " .. light:getEnergy())
end

--@api-stub: LLight:setLightType
--@api-stub: LLight:getLightType
-- Sets and gets light type.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    print("type = " .. light:getLightType())
end

--@api-stub: LLight:setDirection
--@api-stub: LLight:getDirection
-- Sets and gets direction angle.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("directional")
    light:setDirection(1.57)
    print("direction = " .. light:getDirection())
end

--@api-stub: LLight:setFalloff
--@api-stub: LLight:getFalloff
-- Sets and gets falloff mode.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFalloff("smooth")
    print("falloff = " .. light:getFalloff())
end

--@api-stub: LLight:setBlendMode
--@api-stub: LLight:getBlendMode
-- Sets and gets blend mode.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setBlendMode("add")
    print("blend = " .. light:getBlendMode())
end

--@api-stub: LLight:setAttenuation
--@api-stub: LLight:getAttenuation
-- Sets and gets attenuation.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    print("attenuation c=" .. c .. " l=" .. l .. " q=" .. q)
end

--@api-stub: LLight:setInnerAngle
--@api-stub: LLight:getInnerAngle
--@api-stub: LLight:setOuterAngle
--@api-stub: LLight:getOuterAngle
-- Spot light cone angles.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api-stub: LLight:setEnabled
--@api-stub: LLight:isEnabled
-- Enables or disables a light.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnabled(false)
    print("enabled = " .. tostring(light:isEnabled()))
end

--@api-stub: LLight:setGroupId
--@api-stub: LLight:getGroupId
-- Sets and gets group ID.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setGroupId(5)
    print("group = " .. light:getGroupId())
end

--@api-stub: LLight:setLightMask
--@api-stub: LLight:getLightMask
-- Sets and gets inclusion mask.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightMask(3)
    print("mask = " .. light:getLightMask())
end

--@api-stub: LLight:isValid
-- Checks if handle is still alive.
do
    local light = lurek.light.newLight(0, 0, 100)
    print("valid = " .. tostring(light:isValid()))
    light:remove()
    print("valid after remove = " .. tostring(light:isValid()))
end

--@api-stub: LLight:type
--@api-stub: LLight:typeOf
-- Type identity checks.
do
    local light = lurek.light.newLight(0, 0, 100)
    print("type = " .. light:type())
    print("is Light = " .. tostring(light:typeOf("Light")))
end

--- Light Module Part 2: shadows, flicker, transitions, cookies, normals, LOccluder

--@api-stub: LLight:setShadowEnabled
--@api-stub: LLight:isShadowEnabled
-- Enables or disables shadow casting.
do
    local light = lurek.light.newLight(200, 200, 150)
    light:setShadowEnabled(true)
    print("shadows = " .. tostring(light:isShadowEnabled()))
end

--@api-stub: LLight:setShadowColor
--@api-stub: LLight:getShadowColor
-- Sets and gets shadow color.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    print("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:setShadowFilter
--@api-stub: LLight:getShadowFilter
-- Sets and gets shadow filter mode.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    print("shadow filter = " .. light:getShadowFilter())
end

--@api-stub: LLight:setShadowSmooth
--@api-stub: LLight:getShadowSmooth
-- Sets and gets shadow smoothing.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    print("shadow smooth = " .. light:getShadowSmooth())
end

--@api-stub: LLight:setShadowSoftness
--@api-stub: LLight:getShadowSoftness
-- Sets and gets shadow softness.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    print("shadow softness = " .. light:getShadowSoftness())
end

--@api-stub: LLight:setShadowMask
--@api-stub: LLight:getShadowMask
-- Sets and gets shadow receiver mask.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowMask(7)
    print("shadow mask = " .. light:getShadowMask())
end

--@api-stub: LLight:addFlicker
-- Adds flicker from min/max intensity range and frequency.
do
    local light = lurek.light.newLight(100, 100, 80)
    light:addFlicker(0.5, 1.0, 8.0)
    print("flicker added")
end

--@api-stub: LLight:setFlicker
--@api-stub: LLight:getFlicker
-- Sets and gets flicker speed and strength.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    print("flicker speed=" .. speed .. " strength=" .. strength)
end

--@api-stub: LLight:setFlickerEnabled
--@api-stub: LLight:isFlickerEnabled
-- Enables or disables flicker.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    print("flicker on = " .. tostring(light:isFlickerEnabled()))
end

--@api-stub: LLight:setCookie
--@api-stub: LLight:getCookie
--@api-stub: LLight:clearCookie
-- Sets, gets, and clears cookie texture path.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setCookie("assets/textures/cookie_star.png")
    local path = light:getCookie()
    print("cookie = " .. path)
    light:clearCookie()
    print("cookie cleared")
end

--@api-stub: LLight:setNormalMap
--@api-stub: LLight:getNormalMap
--@api-stub: LLight:clearNormalMap
-- Sets, gets, and clears normal map path.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalMap("assets/textures/stone_normal.png")
    local nm = light:getNormalMap()
    print("normal map = " .. nm)
    light:clearNormalMap()
    print("normal map cleared")
end

--@api-stub: LLight:setNormalStrength
--@api-stub: LLight:getNormalStrength
-- Sets and gets normal map strength.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalStrength(1.5)
    print("normal strength = " .. light:getNormalStrength())
end

--@api-stub: LLight:setVolumetric
--@api-stub: LLight:isVolumetric
-- Enables volumetric mode.
do
    local light = lurek.light.newLight(0, 0, 200)
    light:setVolumetric(true)
    print("volumetric = " .. tostring(light:isVolumetric()))
end

--@api-stub: LLight:transitionTo
--@api-stub: LLight:updateTransition
--@api-stub: LLight:transitionProgress
--@api-stub: LLight:stopTransition
-- Animates a light toward target values.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1, 0, 0, 1)
    light:setIntensity(1.0)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    local applied = light:updateTransition(0.5)
    print("applied = " .. tostring(applied))
    print("progress = " .. light:transitionProgress())
    light:stopTransition()
    print("stopped, progress = " .. light:transitionProgress())
end

--@api-stub: lurek.light.newOccluder
-- Creates an occluder from flat vertex list.
do
    local verts = {0, 0, 100, 0, 100, 50, 0, 50}
    local occ = lurek.light.newOccluder(verts)
    print("occluder valid = " .. tostring(occ:isValid()))
end

-- Creates an occluder with options.
--@api-stub: lurek.light.newOccluder
do
    local verts = {0, 0, 50, 0, 50, 80, 0, 80}
    local occ = lurek.light.newOccluder(verts, {opacity = 0.8})
    print("opacity = " .. occ:getOpacity())
end

--@api-stub: LOccluder:setPosition
--@api-stub: LOccluder:getPosition
-- Sets and gets occluder position.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    print("occ pos = " .. x .. "," .. y)
end

--@api-stub: LOccluder:setVertices
--@api-stub: LOccluder:getVertices
-- Sets and gets vertex list.
do
    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    print("vertex count = " .. #v / 2)
end

--@api-stub: LOccluder:setOpacity
--@api-stub: LOccluder:getOpacity
-- Sets and gets occluder opacity.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setOpacity(0.6)
    print("opacity = " .. occ:getOpacity())
end

--@api-stub: LOccluder:setEnabled
--@api-stub: LOccluder:isEnabled
-- Enables or disables occluder.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setEnabled(false)
    print("enabled = " .. tostring(occ:isEnabled()))
end

--@api-stub: LOccluder:setLightMask
--@api-stub: LOccluder:getLightMask
-- Sets and gets occluder light mask.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setLightMask(5)
    print("occ mask = " .. occ:getLightMask())
end

--@api-stub: LOccluder:isValid
-- Checks if occluder handle is alive.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    print("valid = " .. tostring(occ:isValid()))
    occ:remove()
    print("valid after remove = " .. tostring(occ:isValid()))
end

--@api-stub: LOccluder:type
--@api-stub: LOccluder:typeOf
-- Type identity.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    print("type = " .. occ:type())
    print("is Occluder = " .. tostring(occ:typeOf("Occluder")))
end

--@api-stub: lurek.light.getOccluderCount
-- Returns number of live occluders.
do
    lurek.light.clear()
    lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    lurek.light.newOccluder({20, 20, 30, 20, 30, 30, 20, 30})
    print("occluders = " .. lurek.light.getOccluderCount())
end

--- Light Module: LLight:remove, LOccluder:remove, lurek.light functions

--@api-stub: LLight:remove
-- Remove a dynamic light from the scene.
do
    local lt = lurek.light.newLight(200, 300, 150)
    local r, g, b, a = lurek.light.getAmbient()
    print("ambient", r, g, b, a)
    local count = lurek.light.getLightCount()
    print("lights = " .. count)
    lt:remove()
    local count2 = lurek.light.getLightCount()
    print("after remove = " .. count2)
end

--@api-stub: LOccluder:remove
-- Remove an occluder from the scene.
do
    local vtbl = { 0, 0, 100, 0, 100, 100, 0, 100 }
    local occ = lurek.light.newOccluder(vtbl)
    local n = lurek.light.getOccluderCount()
    print("occluders = " .. n)
    occ:remove()
    local n2 = lurek.light.getOccluderCount()
    print("after remove = " .. n2)
end

--@api-stub: lurek.light.getAmbient
--@api-stub: lurek.light.isEnabled
--@api-stub: lurek.light.setMaxLights
-- Ambient color, max lights cap, and enabled state queries.
do
    local r, g, b, a = lurek.light.getAmbient()
    print("ambient", r, g, b, a)
    local mx = lurek.light.getMaxLights()
    print("max lights = " .. mx)
    local enabled = lurek.light.isEnabled()
    print("enabled = " .. tostring(enabled))
    lurek.light.setMaxLights(64)
    lurek.light.setEnabled(true)
    local r2, g2, b2, a2 = lurek.light.getAmbient()
    print("ambient2", r2, g2, b2, a2)
end

print("content/examples/light.lua")
