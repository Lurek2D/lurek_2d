--- Light Module Part 1: module functions and LLight class

--@api-stub: lurek.light.newLight
-- Creates a point light with position, radius, and optional settings.
do
    local light = lurek.light.newLight(400, 300, 200)
    print("light type = " .. light:getLightType())
    print("radius = " .. light:getRadius())
end

--@api-stub: lurek.light.newLight (with opts)
-- Creates a light with full options table.
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
--@api-stub: lurek.isEnabled
-- Enables or disables the light world.
do
    lurek.light.setEnabled(true)
    print("light world enabled = " .. tostring(lurek.light.isEnabled()))
end

--@api-stub: lurek.light.setAmbient
--@api-stub: lurek.getAmbient
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
--@api-stub: lurek.setMaxLights
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

print("light_00.lua")
