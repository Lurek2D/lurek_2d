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

print("light_01.lua")
