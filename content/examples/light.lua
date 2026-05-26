-- content/examples/light.lua
-- Auto-generated from content/examples2/light_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/light.lua

--- Light Module Part 1: module functions and LLight class

--@api-stub: lurek.light.newLight
do
    local light = lurek.light.newLight(400, 300, 200)
    print("radius = " .. light:getRadius())
end

--@api-stub: lurek.light.setEnabled
do
    lurek.light.setEnabled(true)
    print("light world enabled = " .. tostring(lurek.light.isEnabled()))
end

--@api-stub: lurek.light.setAmbient
do
    lurek.light.setAmbient(0.1, 0.1, 0.15, 1)
    local r, g, b, a = lurek.light.getAmbient()
    print("ambient = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.light.getLightCount
do
    lurek.light.clear()
    lurek.light.newLight(0, 0, 100)
    lurek.light.newLight(50, 50, 80)
    print("lights = " .. lurek.light.getLightCount())
end

--@api-stub: lurek.light.getMaxLights
do
    lurek.light.setMaxLights(128)
    print("max lights = " .. lurek.light.getMaxLights())
end

--@api-stub: lurek.light.clear
do
    lurek.light.newLight(0, 0, 50)
    lurek.light.clear()
    print("after clear: lights = " .. lurek.light.getLightCount())
end

--@api-stub: lurek.light.advanceFlickers
do
    local light = lurek.light.newLight(200, 200, 100)
    light:addFlicker(0.5, 1.0, 4.0)
    light:setFlickerEnabled(true)
    lurek.light.advanceFlickers(0.016)
    print("flickers advanced")
end

--@api-stub: lurek.light.getGroupCount
do
    local a = lurek.light.newLight(0, 0, 50)
    local b = lurek.light.newLight(10, 10, 50)
    a:setGroupId(1)
    b:setGroupId(1)
    print("group 1 count = " .. lurek.light.getGroupCount(1))
end

--@api-stub: lurek.light.setGroupColor
do
    lurek.light.clear()
    local first = lurek.light.newLight(10, 10, 60)
    local second = lurek.light.newLight(30, 20, 60)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupColor(1, 1, 0, 0, 1)
    local r, g, b, a = first:getColor()
    print("group 1 count = " .. lurek.light.getGroupCount(1))
    print("group 1 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.light.setGroupIntensity
do
    lurek.light.clear()
    local first = lurek.light.newLight(20, 20, 70)
    local second = lurek.light.newLight(40, 40, 70)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupIntensity(1, 3.0)
    print("group 1 count = " .. lurek.light.getGroupCount(1))
    print("group 1 intensity = " .. first:getIntensity())
end

--@api-stub: lurek.light.setGroupEnabled
do
    lurek.light.clear()
    local first = lurek.light.newLight(20, 20, 70)
    local second = lurek.light.newLight(40, 40, 70)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupEnabled(1, false)
    print("group 1 count = " .. lurek.light.getGroupCount(1))
    print("group 1 enabled = " .. tostring(first:isEnabled()))
end

--@api-stub: lurek.light.getGodRayHints
do
    lurek.light.clear()
    local light = lurek.light.newLight(120, 90, 160)
    light:setLightType("directional")
    light:setDirection(0.75)
    local hints = lurek.light.getGodRayHints()
    print("god ray hints = " .. #hints)
    print("first hint angle = " .. hints[1].angle)
end

--@api-stub: lurek.light.getNormalMapHints
do
    lurek.light.clear()
    local light = lurek.light.newLight(80, 60, 120)
    light:setNormalMap("assets/textures/sample_normal.png")
    light:setNormalStrength(0.8)
    local hints = lurek.light.getNormalMapHints()
    print("normal map hints = " .. #hints)
    print("first hint strength = " .. hints[1].strength)
end

--@api-stub: lurek.light.syncAmbient
do
    lurek.light.setAmbient(0.2, 0.25, 0.3, 1.0)
    local r, g, b, a = lurek.light.syncAmbient()
    print("sync ambient = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:setPosition
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    print("pos = " .. x .. "," .. y)
end

--@api-stub: LLight:getPosition
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    print("pos = " .. x .. "," .. y)
end

--@api-stub: LLight:setRadius
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setRadius(250)
    print("radius = " .. light:getRadius())
end

--@api-stub: LLight:getRadius
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setRadius(250)
    print("radius = " .. light:getRadius())
end

--@api-stub: LLight:setColor
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:getColor
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    print("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:setIntensity
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setIntensity(5)
    print("intensity = " .. light:getIntensity())
end

--@api-stub: LLight:getIntensity
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setIntensity(5)
    print("intensity = " .. light:getIntensity())
end

--@api-stub: LLight:setEnergy
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnergy(2.5)
    print("energy = " .. light:getEnergy())
end

--@api-stub: LLight:getEnergy
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnergy(2.5)
    print("energy = " .. light:getEnergy())
end

--@api-stub: LLight:setLightType
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    print("type = " .. light:getLightType())
end

--@api-stub: LLight:getLightType
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    print("type = " .. light:getLightType())
end

--@api-stub: LLight:setDirection
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("directional")
    light:setDirection(1.57)
    print("direction = " .. light:getDirection())
end

--@api-stub: LLight:getDirection
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("directional")
    light:setDirection(1.57)
    print("direction = " .. light:getDirection())
end

--@api-stub: LLight:setFalloff
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFalloff("smooth")
    print("falloff = " .. light:getFalloff())
end

--@api-stub: LLight:getFalloff
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFalloff("smooth")
    print("falloff = " .. light:getFalloff())
end

--@api-stub: LLight:setBlendMode
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setBlendMode("add")
    print("blend = " .. light:getBlendMode())
end

--@api-stub: LLight:getBlendMode
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setBlendMode("add")
    print("blend = " .. light:getBlendMode())
end

--@api-stub: LLight:setAttenuation
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    print("attenuation c=" .. c .. " l=" .. l .. " q=" .. q)
end

--@api-stub: LLight:getAttenuation
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    print("attenuation c=" .. c .. " l=" .. l .. " q=" .. q)
end

--@api-stub: LLight:setInnerAngle
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api-stub: LLight:getInnerAngle
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api-stub: LLight:setOuterAngle
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api-stub: LLight:getOuterAngle
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    print("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api-stub: LLight:setEnabled
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnabled(false)
    print("enabled = " .. tostring(light:isEnabled()))
end

--@api-stub: LLight:isEnabled
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setEnabled(false)
    print("enabled = " .. tostring(light:isEnabled()))
end

--@api-stub: LLight:setGroupId
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setGroupId(5)
    print("group = " .. light:getGroupId())
end

--@api-stub: LLight:getGroupId
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setGroupId(5)
    print("group = " .. light:getGroupId())
end

--@api-stub: LLight:setLightMask
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightMask(3)
    print("mask = " .. light:getLightMask())
end

--@api-stub: LLight:getLightMask
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setLightMask(3)
    print("mask = " .. light:getLightMask())
end

--@api-stub: LLight:isValid
do
    local light = lurek.light.newLight(0, 0, 100)
    print("valid = " .. tostring(light:isValid()))
    light:remove()
    print("valid after remove = " .. tostring(light:isValid()))
end

--@api-stub: LLight:type
do
    local light = lurek.light.newLight(0, 0, 100)
    print("type = " .. light:type())
    print("is LLight = " .. tostring(light:typeOf("LLight")))
end

--@api-stub: LLight:typeOf
do
    local light = lurek.light.newLight(0, 0, 100)
    print("type = " .. light:type())
    print("is LLight = " .. tostring(light:typeOf("LLight")))
    print("is Object = " .. tostring(light:typeOf("LObject")))
end

--- Light Module Part 2: shadows, flicker, transitions, cookies, normals, LOccluder

--@api-stub: LLight:setShadowEnabled
do
    local light = lurek.light.newLight(200, 200, 150)
    light:setShadowEnabled(true)
    print("shadows = " .. tostring(light:isShadowEnabled()))
end

--@api-stub: LLight:isShadowEnabled
do
    local light = lurek.light.newLight(200, 200, 150)
    light:setShadowEnabled(true)
    print("shadows = " .. tostring(light:isShadowEnabled()))
end

--@api-stub: LLight:setShadowColor
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    print("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:getShadowColor
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    print("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LLight:setShadowFilter
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    print("shadow filter = " .. light:getShadowFilter())
end

--@api-stub: LLight:getShadowFilter
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    print("shadow filter = " .. light:getShadowFilter())
end

--@api-stub: LLight:setShadowSmooth
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    print("shadow smooth = " .. light:getShadowSmooth())
end

--@api-stub: LLight:getShadowSmooth
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    print("shadow smooth = " .. light:getShadowSmooth())
end

--@api-stub: LLight:setShadowSoftness
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    print("shadow softness = " .. light:getShadowSoftness())
end

--@api-stub: LLight:getShadowSoftness
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    print("shadow softness = " .. light:getShadowSoftness())
end

--@api-stub: LLight:setShadowMask
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowMask(7)
    print("shadow mask = " .. light:getShadowMask())
end

--@api-stub: LLight:getShadowMask
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setShadowMask(7)
    print("shadow mask = " .. light:getShadowMask())
end

--@api-stub: LLight:addFlicker
do
    local light = lurek.light.newLight(100, 100, 80)
    light:addFlicker(0.5, 1.0, 8.0)
    local speed, strength = light:getFlicker()
    print("flicker speed = " .. speed)
    print("flicker strength = " .. strength)
end

--@api-stub: LLight:setFlicker
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    print("flicker speed=" .. speed .. " strength=" .. strength)
end

--@api-stub: LLight:getFlicker
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    print("flicker speed=" .. speed .. " strength=" .. strength)
end

--@api-stub: LLight:setFlickerEnabled
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    print("flicker on = " .. tostring(light:isFlickerEnabled()))
end

--@api-stub: LLight:isFlickerEnabled
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    print("flicker on = " .. tostring(light:isFlickerEnabled()))
end

--@api-stub: LLight:setCookie
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setCookie("content/examples/assets/images/sample_texture.png")
    print("cookie = " .. light:getCookie())
end

--@api-stub: LLight:getCookie
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setCookie("content/examples/assets/images/sample_texture.png")
    print("cookie = " .. light:getCookie())
end

--@api-stub: LLight:clearCookie
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setCookie("content/examples/assets/images/sample_texture.png")
    light:clearCookie()
    print("cookie = " .. tostring(light:getCookie()))
end

--@api-stub: LLight:setNormalMap
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    print("normal map = " .. light:getNormalMap())
end

--@api-stub: LLight:getNormalMap
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    print("normal map = " .. light:getNormalMap())
end

--@api-stub: LLight:clearNormalMap
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    light:clearNormalMap()
    print("normal map = " .. tostring(light:getNormalMap()))
end

--@api-stub: LLight:setNormalStrength
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalStrength(1.5)
    print("normal strength = " .. light:getNormalStrength())
end

--@api-stub: LLight:getNormalStrength
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setNormalStrength(1.5)
    print("normal strength = " .. light:getNormalStrength())
end

--@api-stub: LLight:setVolumetric
do
    local light = lurek.light.newLight(0, 0, 200)
    light:setVolumetric(true)
    print("volumetric = " .. tostring(light:isVolumetric()))
end

--@api-stub: LLight:isVolumetric
do
    local light = lurek.light.newLight(0, 0, 200)
    light:setVolumetric(true)
    print("volumetric = " .. tostring(light:isVolumetric()))
end

--@api-stub: LLight:transitionTo
do
    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1, 0, 0, 1)
    light:setIntensity(1.0)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    print("progress = " .. light:transitionProgress())
end

--@api-stub: LLight:updateTransition
do
    local light = lurek.light.newLight(0, 0, 100)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    local applied = light:updateTransition(0.5)
    print("applied = " .. tostring(applied))
end

--@api-stub: LLight:transitionProgress
do
    local light = lurek.light.newLight(0, 0, 100)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    light:updateTransition(0.5)
    print("progress = " .. light:transitionProgress())
end

--@api-stub: LLight:stopTransition
do
    local light = lurek.light.newLight(0, 0, 100)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    light:stopTransition()
    print("stopped, progress = " .. light:transitionProgress())
end

--@api-stub: lurek.light.newOccluder
do
    local verts = {0, 0, 100, 0, 100, 50, 0, 50}
    local occ = lurek.light.newOccluder(verts)
    print("occluder valid = " .. tostring(occ:isValid()))
end

--@api-stub: LOccluder:setPosition
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    print("occ pos = " .. x .. "," .. y)
end

--@api-stub: LOccluder:getPosition
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    print("occ pos = " .. x .. "," .. y)
end

--@api-stub: LOccluder:setVertices
do
    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    print("vertex count = " .. #v / 2)
end

--@api-stub: LOccluder:getVertices
do
    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    print("vertex count = " .. #v / 2)
end

--@api-stub: LOccluder:setOpacity
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setOpacity(0.6)
    print("opacity = " .. occ:getOpacity())
end

--@api-stub: LOccluder:getOpacity
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setOpacity(0.6)
    print("opacity = " .. occ:getOpacity())
end

--@api-stub: LOccluder:setEnabled
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setEnabled(false)
    print("enabled = " .. tostring(occ:isEnabled()))
end

--@api-stub: LOccluder:isEnabled
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setEnabled(false)
    print("enabled = " .. tostring(occ:isEnabled()))
end

--@api-stub: LOccluder:setLightMask
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setLightMask(5)
    print("occ mask = " .. occ:getLightMask())
end

--@api-stub: LOccluder:getLightMask
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setLightMask(5)
    print("occ mask = " .. occ:getLightMask())
end

--@api-stub: LOccluder:isValid
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    print("valid = " .. tostring(occ:isValid()))
    occ:remove()
    print("valid after remove = " .. tostring(occ:isValid()))
end

--@api-stub: LOccluder:type
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    print("type = " .. occ:type())
    print("is LOccluder = " .. tostring(occ:typeOf("LOccluder")))
end

--@api-stub: LOccluder:typeOf
do
    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    print("type = " .. occ:type())
    print("is LOccluder = " .. tostring(occ:typeOf("LOccluder")))
    print("is Object = " .. tostring(occ:typeOf("LObject")))
end

--@api-stub: lurek.light.getOccluderCount
do
    lurek.light.clear()
    lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    lurek.light.newOccluder({20, 20, 30, 20, 30, 30, 20, 30})
    print("occluders = " .. lurek.light.getOccluderCount())
end

--- Light Module: LLight:remove, LOccluder:remove, lurek.light functions

--@api-stub: LLight:remove
do
    local lt = lurek.light.newLight(200, 300, 150)
    print("lights = " .. lurek.light.getLightCount())
    lt:remove()
    print("after remove = " .. lurek.light.getLightCount())
end

--@api-stub: LOccluder:remove
do
    local vtbl = { 0, 0, 100, 0, 100, 100, 0, 100 }
    local occ = lurek.light.newOccluder(vtbl)
    print("occluders = " .. lurek.light.getOccluderCount())
    occ:remove()
    print("after remove = " .. lurek.light.getOccluderCount())
end

--@api-stub: lurek.light.getAmbient
do
    local r, g, b, a = lurek.light.getAmbient()
    print("ambient", r, g, b, a)
end

--@api-stub: lurek.light.isEnabled
do
    local enabled = lurek.light.isEnabled()
    print("enabled = " .. tostring(enabled))
end

--@api-stub: lurek.light.setMaxLights
do
    lurek.light.setMaxLights(64)
    print("max lights = " .. lurek.light.getMaxLights())
end

--@api-stub: lurek.light.drawToImage
do
    lurek.light.clear()
    local light = lurek.light.newLight(200, 150, 120)
    light:setColor(1.0, 0.9, 0.6, 1.0)
    local img = lurek.light.drawToImage(400, 300)
    print("lurek.light.drawToImage type=" .. type(img))
    print("lurek.light.drawToImage hasLight = " .. tostring(light:isValid()))
end
