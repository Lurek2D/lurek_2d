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

    -- Creates a light with full options table.
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
-- Sets and gets light position. Focus: setPosition.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    print("pos = " .. x .. "," .. y)
end

--@api-stub: LLight:getPosition
-- Sets and gets light position. Focus: getPosition.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    print("pos = " .. x .. "," .. y)
end

--@api-stub: LLight:setRadius
-- Sets and gets light radius. Focus: setRadius.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setRadius(250)
    print("radius = " .. light:getRadius())
end

--@api-stub: LLight:getRadius
-- Sets and gets light radius. Focus: getRadius.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setRadius(250)
    print("radius = " .. light:getRadius())
end

--@api-stub: LLight:setColor
-- Sets and gets light RGBA color. Focus: setColor.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:getColor
-- Sets and gets light RGBA color. Focus: getColor.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:setIntensity
-- Sets and gets intensity. Focus: setIntensity.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setIntensity(5)
    print("intensity = " .. light:getIntensity())
end

--@api-stub: LLight:getIntensity
-- Sets and gets intensity. Focus: getIntensity.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setIntensity(5)
    print("intensity = " .. light:getIntensity())
end

--@api-stub: LLight:setEnergy
-- Sets and gets energy. Focus: setEnergy.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnergy(2.5)
    print("energy = " .. light:getEnergy())
end

--@api-stub: LLight:getEnergy
-- Sets and gets energy. Focus: getEnergy.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnergy(2.5)
    print("energy = " .. light:getEnergy())
end

--@api-stub: LLight:setLightType
-- Sets and gets light type. Focus: setLightType.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    print("type = " .. light:getLightType())
end

--@api-stub: LLight:getLightType
-- Sets and gets light type. Focus: getLightType.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    print("type = " .. light:getLightType())
end

--@api-stub: LLight:setDirection
-- Sets and gets direction angle. Focus: setDirection.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("directional")
    light:setDirection(1.57)
    print("direction = " .. light:getDirection())
end

--@api-stub: LLight:getDirection
-- Sets and gets direction angle. Focus: getDirection.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("directional")
    light:setDirection(1.57)
    print("direction = " .. light:getDirection())
end

--@api-stub: LLight:setFalloff
-- Sets and gets falloff mode. Focus: setFalloff.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFalloff("smooth")
    print("falloff = " .. light:getFalloff())
end

--@api-stub: LLight:getFalloff
-- Sets and gets falloff mode. Focus: getFalloff.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFalloff("smooth")
    print("falloff = " .. light:getFalloff())
end

--@api-stub: LLight:setBlendMode
-- Sets and gets blend mode. Focus: setBlendMode.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setBlendMode("add")
    print("blend = " .. light:getBlendMode())
end

--@api-stub: LLight:getBlendMode
-- Sets and gets blend mode. Focus: getBlendMode.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setBlendMode("add")
    print("blend = " .. light:getBlendMode())
end

--@api-stub: LLight:setAttenuation
-- Sets and gets attenuation. Focus: setAttenuation.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    print("attenuation c=" .. c .. " l=" .. l .. " q=" .. q)
end

--@api-stub: LLight:getAttenuation
-- Sets and gets attenuation. Focus: getAttenuation.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    print("attenuation c=" .. c .. " l=" .. l .. " q=" .. q)
end

--@api-stub: LLight:setInnerAngle
-- Spot light cone angles. Focus: setInnerAngle.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api-stub: LLight:getInnerAngle
-- Spot light cone angles. Focus: getInnerAngle.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api-stub: LLight:setOuterAngle
-- Spot light cone angles. Focus: setOuterAngle.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api-stub: LLight:getOuterAngle
-- Spot light cone angles. Focus: getOuterAngle.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api-stub: LLight:setEnabled
-- Enables or disables a light. Focus: setEnabled.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnabled(false)
    print("enabled = " .. tostring(light:isEnabled()))
end

--@api-stub: LLight:isEnabled
-- Enables or disables a light. Focus: isEnabled.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnabled(false)
    print("enabled = " .. tostring(light:isEnabled()))
end

--@api-stub: LLight:setGroupId
-- Sets and gets group ID. Focus: setGroupId.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setGroupId(5)
    print("group = " .. light:getGroupId())
end

--@api-stub: LLight:getGroupId
-- Sets and gets group ID. Focus: getGroupId.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setGroupId(5)
    print("group = " .. light:getGroupId())
end

--@api-stub: LLight:setLightMask
-- Sets and gets inclusion mask. Focus: setLightMask.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightMask(3)
    print("mask = " .. light:getLightMask())
end

--@api-stub: LLight:getLightMask
-- Sets and gets inclusion mask. Focus: getLightMask.
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
-- Type identity checks. Focus: type.
do
    local light = lurek.light.newLight(0, 0, 100)
    print("type = " .. light:type())
    print("is Light = " .. tostring(light:typeOf("Light")))
end

--@api-stub: LLight:typeOf
-- Type identity checks. Focus: typeOf.
do
    local light = lurek.light.newLight(0, 0, 100)
    print("type = " .. light:type())
    print("is Light = " .. tostring(light:typeOf("Light")))
end

--- Light Module Part 2: shadows, flicker, transitions, cookies, normals, LOccluder


--@api-stub: LLight:setShadowEnabled
-- Enables or disables shadow casting. Focus: setShadowEnabled.
do
    local light = lurek.light.newLight(200, 200, 150)
    light:setShadowEnabled(true)
    print("shadows = " .. tostring(light:isShadowEnabled()))
end

--@api-stub: LLight:isShadowEnabled
-- Enables or disables shadow casting. Focus: isShadowEnabled.
do
    local light = lurek.light.newLight(200, 200, 150)
    light:setShadowEnabled(true)
    print("shadows = " .. tostring(light:isShadowEnabled()))
end

--@api-stub: LLight:setShadowColor
-- Sets and gets shadow color. Focus: setShadowColor.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    print("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:getShadowColor
-- Sets and gets shadow color. Focus: getShadowColor.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    print("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:setShadowFilter
-- Sets and gets shadow filter mode. Focus: setShadowFilter.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    print("shadow filter = " .. light:getShadowFilter())
end

--@api-stub: LLight:getShadowFilter
-- Sets and gets shadow filter mode. Focus: getShadowFilter.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    print("shadow filter = " .. light:getShadowFilter())
end

--@api-stub: LLight:setShadowSmooth
-- Sets and gets shadow smoothing. Focus: setShadowSmooth.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    print("shadow smooth = " .. light:getShadowSmooth())
end

--@api-stub: LLight:getShadowSmooth
-- Sets and gets shadow smoothing. Focus: getShadowSmooth.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    print("shadow smooth = " .. light:getShadowSmooth())
end

--@api-stub: LLight:setShadowSoftness
-- Sets and gets shadow softness. Focus: setShadowSoftness.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    print("shadow softness = " .. light:getShadowSoftness())
end

--@api-stub: LLight:getShadowSoftness
-- Sets and gets shadow softness. Focus: getShadowSoftness.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    print("shadow softness = " .. light:getShadowSoftness())
end

--@api-stub: LLight:setShadowMask
-- Sets and gets shadow receiver mask. Focus: setShadowMask.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowMask(7)
    print("shadow mask = " .. light:getShadowMask())
end

--@api-stub: LLight:getShadowMask
-- Sets and gets shadow receiver mask. Focus: getShadowMask.
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
-- Sets and gets flicker speed and strength. Focus: setFlicker.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    print("flicker speed=" .. speed .. " strength=" .. strength)
end

--@api-stub: LLight:getFlicker
-- Sets and gets flicker speed and strength. Focus: getFlicker.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    print("flicker speed=" .. speed .. " strength=" .. strength)
end

--@api-stub: LLight:setFlickerEnabled
-- Enables or disables flicker. Focus: setFlickerEnabled.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    print("flicker on = " .. tostring(light:isFlickerEnabled()))
end

--@api-stub: LLight:isFlickerEnabled
-- Enables or disables flicker. Focus: isFlickerEnabled.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    print("flicker on = " .. tostring(light:isFlickerEnabled()))
end

--@api-stub: LLight:setCookie
-- Sets, gets, and clears cookie texture path. Focus: setCookie.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setCookie("assets/textures/cookie_star.png")
    local path = light:getCookie()
    print("cookie = " .. path)
    light:clearCookie()
    print("cookie cleared")
end

--@api-stub: LLight:getCookie
-- Sets, gets, and clears cookie texture path. Focus: getCookie.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setCookie("assets/textures/cookie_star.png")
    local path = light:getCookie()
    print("cookie = " .. path)
    light:clearCookie()
    print("cookie cleared")
end

--@api-stub: LLight:clearCookie
-- Sets, gets, and clears cookie texture path. Focus: clearCookie.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setCookie("assets/textures/cookie_star.png")
    local path = light:getCookie()
    print("cookie = " .. path)
    light:clearCookie()
    print("cookie cleared")
end

--@api-stub: LLight:setNormalMap
-- Sets, gets, and clears normal map path. Focus: setNormalMap.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalMap("assets/textures/stone_normal.png")
    local nm = light:getNormalMap()
    print("normal map = " .. nm)
    light:clearNormalMap()
    print("normal map cleared")
end

--@api-stub: LLight:getNormalMap
-- Sets, gets, and clears normal map path. Focus: getNormalMap.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalMap("assets/textures/stone_normal.png")
    local nm = light:getNormalMap()
    print("normal map = " .. nm)
    light:clearNormalMap()
    print("normal map cleared")
end

--@api-stub: LLight:clearNormalMap
-- Sets, gets, and clears normal map path. Focus: clearNormalMap.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalMap("assets/textures/stone_normal.png")
    local nm = light:getNormalMap()
    print("normal map = " .. nm)
    light:clearNormalMap()
    print("normal map cleared")
end

--@api-stub: LLight:setNormalStrength
-- Sets and gets normal map strength. Focus: setNormalStrength.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalStrength(1.5)
    print("normal strength = " .. light:getNormalStrength())
end

--@api-stub: LLight:getNormalStrength
-- Sets and gets normal map strength. Focus: getNormalStrength.
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalStrength(1.5)
    print("normal strength = " .. light:getNormalStrength())
end

--@api-stub: LLight:setVolumetric
-- Enables volumetric mode. Focus: setVolumetric.
do
    local light = lurek.light.newLight(0, 0, 200)
    light:setVolumetric(true)
    print("volumetric = " .. tostring(light:isVolumetric()))
end

--@api-stub: LLight:isVolumetric
-- Enables volumetric mode. Focus: isVolumetric.
do
    local light = lurek.light.newLight(0, 0, 200)
    light:setVolumetric(true)
    print("volumetric = " .. tostring(light:isVolumetric()))
end

--@api-stub: LLight:transitionTo
-- Animates a light toward target values. Focus: transitionTo.
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

--@api-stub: LLight:updateTransition
-- Animates a light toward target values. Focus: updateTransition.
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

--@api-stub: LLight:transitionProgress
-- Animates a light toward target values. Focus: transitionProgress.
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

--@api-stub: LLight:stopTransition
-- Animates a light toward target values. Focus: stopTransition.
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

    -- Creates an occluder with options.
    local verts = {0, 0, 50, 0, 50, 80, 0, 80}
    local occ = lurek.light.newOccluder(verts, {opacity = 0.8})
    print("opacity = " .. occ:getOpacity())
end

--@api-stub: LOccluder:setPosition
-- Sets and gets occluder position. Focus: setPosition.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    print("occ pos = " .. x .. "," .. y)
end

--@api-stub: LOccluder:getPosition
-- Sets and gets occluder position. Focus: getPosition.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    print("occ pos = " .. x .. "," .. y)
end

--@api-stub: LOccluder:setVertices
-- Sets and gets vertex list. Focus: setVertices.
do
    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    print("vertex count = " .. #v / 2)
end

--@api-stub: LOccluder:getVertices
-- Sets and gets vertex list. Focus: getVertices.
do
    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    print("vertex count = " .. #v / 2)
end

--@api-stub: LOccluder:setOpacity
-- Sets and gets occluder opacity. Focus: setOpacity.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setOpacity(0.6)
    print("opacity = " .. occ:getOpacity())
end

--@api-stub: LOccluder:getOpacity
-- Sets and gets occluder opacity. Focus: getOpacity.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setOpacity(0.6)
    print("opacity = " .. occ:getOpacity())
end

--@api-stub: LOccluder:setEnabled
-- Enables or disables occluder. Focus: setEnabled.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setEnabled(false)
    print("enabled = " .. tostring(occ:isEnabled()))
end

--@api-stub: LOccluder:isEnabled
-- Enables or disables occluder. Focus: isEnabled.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setEnabled(false)
    print("enabled = " .. tostring(occ:isEnabled()))
end

--@api-stub: LOccluder:setLightMask
-- Sets and gets occluder light mask. Focus: setLightMask.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setLightMask(5)
    print("occ mask = " .. occ:getLightMask())
end

--@api-stub: LOccluder:getLightMask
-- Sets and gets occluder light mask. Focus: getLightMask.
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
-- Type identity. Focus: type.
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    print("type = " .. occ:type())
    print("is Occluder = " .. tostring(occ:typeOf("Occluder")))
end

--@api-stub: LOccluder:typeOf
-- Type identity. Focus: typeOf.
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
-- Ambient color, max lights cap, and enabled state queries. Focus: getAmbient.
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

--@api-stub: lurek.light.isEnabled
-- Ambient color, max lights cap, and enabled state queries. Focus: isEnabled.
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

--@api-stub: lurek.light.setMaxLights
-- Ambient color, max lights cap, and enabled state queries. Focus: setMaxLights.
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
