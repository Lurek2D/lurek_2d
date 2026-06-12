-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_light_core_unit.lua
do
-- Canonical unit coverage for lurek.light.

local function reset_light()
    lurek.light.clear()
    lurek.light.setEnabled(true)
end

local function make_light(opts)
    reset_light()
    return lurek.light.newLight(10, 20, 30, opts)
end

local function make_occluder(opts)
    reset_light()
    return lurek.light.newOccluder({ 0, 0, 100, 0, 50, 80 }, opts)
end

-- @describe lurek.light module
describe("lurek.light module", function()
    -- @covers lurek.light.clear
    it("clear removes lights and occluders", function()
        reset_light()
        lurek.light.newLight(0, 0, 10)
        lurek.light.newOccluder({ 0, 0, 10, 0, 5, 10 })
        lurek.light.clear()
        expect_equal(0, lurek.light.getLightCount())
        expect_equal(0, lurek.light.getOccluderCount())
    end)

    -- @covers lurek.light.newLight
    it("newLight returns a light userdata", function()
        expect_type("userdata", make_light())
    end)

    -- @covers lurek.light.newOccluder
    it("newOccluder returns an occluder userdata", function()
        expect_type("userdata", make_occluder())
    end)

    -- @covers lurek.light.getAmbient
    it("getAmbient returns rgba values", function()
        reset_light()
        local r, g, b, a = lurek.light.getAmbient()
        expect_type("number", r)
        expect_type("number", a)
    end)

    -- @covers lurek.light.setAmbient
    it("setAmbient updates ambient color", function()
        reset_light()
        lurek.light.setAmbient(0.2, 0.3, 0.4, 0.8)
        local r, g, b, a = lurek.light.getAmbient()
        expect_near(0.2, r, 0.001)
        expect_near(0.8, a, 0.001)
    end)

    -- @covers lurek.light.isEnabled
    it("isEnabled returns the module flag", function()
        reset_light()
        expect_type("boolean", lurek.light.isEnabled())
    end)

    -- @covers lurek.light.setEnabled
    it("setEnabled updates the module flag", function()
        reset_light()
        lurek.light.setEnabled(false)
        expect_false(lurek.light.isEnabled())
    end)

    -- @covers lurek.light.getLightCount
    it("getLightCount tracks active lights", function()
        reset_light()
        expect_equal(0, lurek.light.getLightCount())
        lurek.light.newLight(0, 0, 10)
        lurek.light.newLight(20, 20, 15)
        expect_equal(2, lurek.light.getLightCount())
    end)

    -- @covers lurek.light.getOccluderCount
    it("getOccluderCount tracks active occluders", function()
        reset_light()
        expect_equal(0, lurek.light.getOccluderCount())
        lurek.light.newOccluder({ 0, 0, 10, 0, 5, 10 })
        expect_equal(1, lurek.light.getOccluderCount())
    end)

    -- @covers lurek.light.getMaxLights
    it("getMaxLights returns a numeric limit", function()
        expect_type("number", lurek.light.getMaxLights())
    end)

    -- @covers lurek.light.setMaxLights
    it("setMaxLights clamps and stores the limit", function()
        lurek.light.setMaxLights(0)
        expect_equal(1, lurek.light.getMaxLights())
        lurek.light.setMaxLights(999)
        expect_equal(256, lurek.light.getMaxLights())
    end)

    -- @covers lurek.light.getGroupCount
    it("getGroupCount counts lights in a group", function()
        local left = make_light()
        local right = lurek.light.newLight(30, 40, 20)
        left:setGroupId(2)
        right:setGroupId(2)
        expect_equal(2, lurek.light.getGroupCount(2))
    end)

    -- @covers lurek.light.setGroupEnabled
    it("setGroupEnabled toggles all lights in a group", function()
        local left = make_light()
        local right = lurek.light.newLight(30, 40, 20)
        left:setGroupId(3)
        right:setGroupId(3)
        lurek.light.setGroupEnabled(3, false)
        expect_false(left:isEnabled())
        expect_false(right:isEnabled())
    end)

    -- @covers lurek.light.setGroupIntensity
    it("setGroupIntensity updates grouped light intensity", function()
        local light = make_light()
        light:setGroupId(4)
        lurek.light.setGroupIntensity(4, 0.5)
        expect_near(0.5, light:getIntensity(), 0.001)
    end)

    -- @covers lurek.light.setGroupColor
    it("setGroupColor updates grouped light color", function()
        local light = make_light()
        light:setGroupId(5)
        lurek.light.setGroupColor(5, 1.0, 0.0, 0.0, 1.0)
        local r, g, b, a = light:getColor()
        expect_near(1.0, r, 0.001)
        expect_near(0.0, g, 0.001)
        expect_near(1.0, a, 0.001)
    end)

    -- @covers lurek.light.advanceFlickers
    it("advanceFlickers is callable", function()
        local light = make_light()
        light:setFlicker(10.0, 0.15)
        expect_no_error(function()
            lurek.light.advanceFlickers(0.1)
        end)
    end)

    -- @covers lurek.light.syncAmbient
    it("syncAmbient returns rgba values", function()
        local r, g, b, a = lurek.light.syncAmbient()
        expect_type("number", r)
        expect_type("number", a)
    end)

    -- @covers lurek.light.getGodRayHints
    it("getGodRayHints returns a table", function()
        expect_type("table", lurek.light.getGodRayHints())
    end)

    -- @covers lurek.light.getNormalMapHints
    it("getNormalMapHints returns a table", function()
        expect_type("table", lurek.light.getNormalMapHints())
    end)

    -- @covers lurek.light.drawToImage
    it("drawToImage returns a software image preview", function()
        reset_light()
        lurek.light.newLight(100, 80, 40)
        local img = lurek.light.drawToImage(64, 48)
        expect_type("userdata", img)
        expect_equal(64, img:getWidth())
        expect_equal(48, img:getHeight())
    end)
end)

-- @describe light handle methods
describe("light handle methods", function()
    -- @covers LLight:getPosition
    it("getPosition returns the initial coordinates", function()
        local x, y = make_light():getPosition()
        expect_near(10, x, 0.001)
        expect_near(20, y, 0.001)
    end)

    -- @covers LLight:setPosition
    it("setPosition updates coordinates", function()
        local light = make_light()
        light:setPosition(50, 60)
        local x, y = light:getPosition()
        expect_near(50, x, 0.001)
        expect_near(60, y, 0.001)
    end)

    -- @covers LLight:getRadius
    it("getRadius returns the initial radius", function()
        expect_near(30, make_light():getRadius(), 0.001)
    end)

    -- @covers LLight:setRadius
    it("setRadius updates the radius", function()
        local light = make_light()
        light:setRadius(80)
        expect_near(80, light:getRadius(), 0.001)
    end)

    -- @covers LLight:getColor
    it("getColor returns rgba channels", function()
        local r, g, b, a = make_light():getColor()
        expect_type("number", r)
        expect_type("number", a)
    end)

    -- @covers LLight:setColor
    it("setColor updates rgba channels", function()
        local light = make_light()
        light:setColor(0.5, 0.6, 0.7, 0.8)
        local r, g, b, a = light:getColor()
        expect_near(0.5, r, 0.001)
        expect_near(0.8, a, 0.001)
    end)

    -- @covers LLight:getIntensity
    it("getIntensity returns the light intensity", function()
        expect_type("number", make_light():getIntensity())
    end)

    -- @covers LLight:setIntensity
    it("setIntensity updates the light intensity", function()
        local light = make_light()
        light:setIntensity(2.0)
        expect_near(2.0, light:getIntensity(), 0.001)
    end)

    -- @covers LLight:getEnergy
    it("getEnergy returns the light energy", function()
        expect_type("number", make_light():getEnergy())
    end)

    -- @covers LLight:setEnergy
    it("setEnergy updates the light energy", function()
        local light = make_light()
        light:setEnergy(3.0)
        expect_near(3.0, light:getEnergy(), 0.001)
    end)

    -- @covers LLight:getBlendMode
    it("getBlendMode returns the blend mode string", function()
        expect_type("string", make_light():getBlendMode())
    end)

    -- @covers LLight:setBlendMode
    it("setBlendMode updates the blend mode", function()
        local light = make_light()
        light:setBlendMode("sub")
        expect_equal("sub", light:getBlendMode())
    end)

    -- @covers LLight:getFalloff
    it("getFalloff returns the falloff mode", function()
        expect_type("string", make_light():getFalloff())
    end)

    -- @covers LLight:setFalloff
    it("setFalloff updates the falloff mode", function()
        local light = make_light()
        light:setFalloff("smooth")
        expect_equal("smooth", light:getFalloff())
    end)

    -- @covers LLight:isShadowEnabled
    it("isShadowEnabled returns the shadow flag", function()
        expect_type("boolean", make_light():isShadowEnabled())
    end)

    -- @covers LLight:setShadowEnabled
    it("setShadowEnabled updates the shadow flag", function()
        local light = make_light()
        light:setShadowEnabled(true)
        expect_true(light:isShadowEnabled())
    end)

    -- @covers LLight:getShadowColor
    it("getShadowColor returns rgba channels", function()
        local r, g, b, a = make_light():getShadowColor()
        expect_type("number", r)
        expect_type("number", a)
    end)

    -- @covers LLight:setShadowColor
    it("setShadowColor updates rgba channels", function()
        local light = make_light()
        light:setShadowColor(0.1, 0.2, 0.3, 0.9)
        local r, g, b, a = light:getShadowColor()
        expect_near(0.1, r, 0.001)
        expect_near(0.9, a, 0.001)
    end)

    -- @covers LLight:getShadowFilter
    it("getShadowFilter returns the shadow filter mode", function()
        expect_type("string", make_light():getShadowFilter())
    end)

    -- @covers LLight:setShadowFilter
    it("setShadowFilter updates the shadow filter mode", function()
        local light = make_light()
        light:setShadowFilter("pcf5")
        expect_equal("pcf5", light:getShadowFilter())
    end)

    -- @covers LLight:getShadowSmooth
    it("getShadowSmooth returns the shadow smoothing amount", function()
        expect_type("number", make_light():getShadowSmooth())
    end)

    -- @covers LLight:setShadowSmooth
    it("setShadowSmooth updates the shadow smoothing amount", function()
        local light = make_light()
        light:setShadowSmooth(2.5)
        expect_near(2.5, light:getShadowSmooth(), 0.001)
    end)

    -- @covers LLight:getLightMask
    it("getLightMask returns the light mask", function()
        expect_type("number", make_light():getLightMask())
    end)

    -- @covers LLight:setLightMask
    it("setLightMask updates the light mask", function()
        local light = make_light()
        light:setLightMask(127)
        expect_equal(127, light:getLightMask())
    end)

    -- @covers LLight:getShadowMask
    it("getShadowMask returns the shadow mask", function()
        expect_type("number", make_light():getShadowMask())
    end)

    -- @covers LLight:setShadowMask
    it("setShadowMask updates the shadow mask", function()
        local light = make_light()
        light:setShadowMask(63)
        expect_equal(63, light:getShadowMask())
    end)

    -- @covers LLight:isEnabled
    it("isEnabled returns the per-light enabled flag", function()
        expect_type("boolean", make_light():isEnabled())
    end)

    -- @covers LLight:setEnabled
    it("setEnabled updates the per-light enabled flag", function()
        local light = make_light()
        light:setEnabled(false)
        expect_false(light:isEnabled())
    end)

    -- @covers LLight:isValid
    it("isValid becomes false after remove", function()
        local light = make_light()
        expect_true(light:isValid())
        light:remove()
        expect_false(light:isValid())
    end)

    -- @covers LLight:remove
    it("remove reduces the light count", function()
        local light = make_light()
        expect_equal(1, lurek.light.getLightCount())
        light:remove()
        expect_equal(0, lurek.light.getLightCount())
    end)

    -- @covers LLight:getLightType
    it("getLightType defaults to point", function()
        expect_equal("point", make_light():getLightType())
    end)

    -- @covers LLight:setLightType
    it("setLightType switches between supported types", function()
        local light = make_light()
        light:setLightType("spot")
        expect_equal("spot", light:getLightType())
        light:setLightType("directional")
        expect_equal("directional", light:getLightType())
    end)

    -- @covers LLight:getDirection
    it("getDirection defaults to zero", function()
        expect_near(0, make_light():getDirection(), 0.001)
    end)

    -- @covers LLight:setDirection
    it("setDirection updates the direction angle", function()
        local light = make_light()
        light:setDirection(1.57)
        expect_near(1.57, light:getDirection(), 0.001)
    end)

    -- @covers LLight:getInnerAngle
    it("getInnerAngle returns the default spot angle", function()
        expect_near(math.pi / 6, make_light():getInnerAngle(), 0.001)
    end)

    -- @covers LLight:setInnerAngle
    it("setInnerAngle updates the inner cone angle", function()
        local light = make_light()
        light:setInnerAngle(0.3)
        expect_near(0.3, light:getInnerAngle(), 0.001)
    end)

    -- @covers LLight:getOuterAngle
    it("getOuterAngle returns the default outer cone angle", function()
        expect_near(math.pi / 4, make_light():getOuterAngle(), 0.001)
    end)

    -- @covers LLight:setOuterAngle
    it("setOuterAngle updates the outer cone angle", function()
        local light = make_light()
        light:setOuterAngle(0.6)
        expect_near(0.6, light:getOuterAngle(), 0.001)
    end)

    -- @covers LLight:getAttenuation
    it("getAttenuation returns constant linear quadratic factors", function()
        local c, lin, q = make_light():getAttenuation()
        expect_type("number", c)
        expect_type("number", q)
    end)

    -- @covers LLight:setAttenuation
    it("setAttenuation updates attenuation factors", function()
        local light = make_light()
        light:setAttenuation(1.0, 0.09, 0.032)
        local c, lin, q = light:getAttenuation()
        expect_near(0.09, lin, 0.001)
        expect_near(0.032, q, 0.001)
    end)

    -- @covers LLight:isFlickerEnabled
    it("isFlickerEnabled defaults to false", function()
        expect_false(make_light():isFlickerEnabled())
    end)

    -- @covers LLight:getFlicker
    it("getFlicker returns speed and strength", function()
        local light = make_light()
        light:setFlicker(10.0, 0.25)
        local speed, strength = light:getFlicker()
        expect_near(10.0, speed, 0.001)
        expect_near(0.25, strength, 0.001)
    end)

    -- @covers LLight:setFlicker
    it("setFlicker enables flicker and stores values", function()
        local light = make_light()
        light:setFlicker(10.0, 0.25)
        expect_true(light:isFlickerEnabled())
    end)

    -- @covers LLight:setFlickerEnabled
    it("setFlickerEnabled toggles flicker without changing values", function()
        local light = make_light()
        light:setFlicker(10.0, 0.25)
        light:setFlickerEnabled(false)
        expect_false(light:isFlickerEnabled())
    end)

    -- @covers LLight:addFlicker
    it("addFlicker derives flicker settings from a range", function()
        local light = make_light()
        light:addFlicker(0.8, 1.2, 2.0)
        local speed, strength = light:getFlicker()
        expect_true(speed > 0)
        expect_true(strength > 0)
    end)

    -- @covers LLight:getGroupId
    it("getGroupId defaults to zero", function()
        expect_equal(0, make_light():getGroupId())
    end)

    -- @covers LLight:setGroupId
    it("setGroupId updates the light group id", function()
        local light = make_light()
        light:setGroupId(7)
        expect_equal(7, light:getGroupId())
    end)

    -- @covers LLight:isVolumetric
    it("isVolumetric defaults to false", function()
        expect_false(make_light():isVolumetric())
    end)

    -- @covers LLight:setVolumetric
    it("setVolumetric updates the volumetric flag", function()
        local light = make_light()
        light:setVolumetric(true)
        expect_true(light:isVolumetric())
    end)

    -- @covers LLight:transitionProgress
    it("transitionProgress starts at zero", function()
        local light = make_light()
        light:transitionTo({ radius = 50.0 }, 2.0)
        expect_near(0.0, light:transitionProgress(), 0.001)
    end)

    -- @covers LLight:transitionTo
    it("transitionTo starts a light transition", function()
        local light = make_light()
        light:transitionTo({ intensity = 0.0, radius = 50.0 }, 2.0)
        expect_true(light:updateTransition(1.0))
    end)

    -- @covers LLight:updateTransition
    it("updateTransition advances transition progress", function()
        local light = make_light()
        light:transitionTo({ radius = 50.0 }, 2.0)
        light:updateTransition(1.0)
        expect_near(0.5, light:transitionProgress(), 0.001)
    end)

    -- @covers LLight:stopTransition
    it("stopTransition ends an active transition", function()
        local light = make_light()
        light:transitionTo({ radius = 10.0 }, 1.0)
        light:stopTransition()
        expect_false(light:updateTransition(0.1))
    end)

    -- @covers LLight:getCookie
    it("getCookie returns nil by default", function()
        expect_nil(make_light():getCookie())
    end)

    -- @covers LLight:setCookie
    it("setCookie stores the cookie path", function()
        local light = make_light()
        light:setCookie("assets/lights/cookie.png")
        expect_equal("assets/lights/cookie.png", light:getCookie())
    end)

    -- @covers LLight:clearCookie
    it("clearCookie resets the cookie path", function()
        local light = make_light()
        light:setCookie("assets/lights/cookie.png")
        light:clearCookie()
        expect_nil(light:getCookie())
    end)

    -- @covers LLight:getShadowSoftness
    it("getShadowSoftness returns a numeric softness", function()
        expect_type("number", make_light():getShadowSoftness())
    end)

    -- @covers LLight:setShadowSoftness
    it("setShadowSoftness updates the softness", function()
        local light = make_light()
        light:setShadowSoftness(1.75)
        expect_near(1.75, light:getShadowSoftness(), 0.001)
    end)

    -- @covers LLight:getNormalMap
    it("getNormalMap returns nil by default", function()
        expect_nil(make_light():getNormalMap())
    end)

    -- @covers LLight:setNormalMap
    it("setNormalMap stores the normal map path", function()
        local light = make_light()
        light:setNormalMap("assets/textures/normals/torch.png")
        expect_equal("assets/textures/normals/torch.png", light:getNormalMap())
    end)

    -- @covers LLight:getNormalStrength
    it("getNormalStrength returns a numeric strength", function()
        expect_type("number", make_light():getNormalStrength())
    end)

    -- @covers LLight:setNormalStrength
    it("setNormalStrength updates the normal strength", function()
        local light = make_light()
        light:setNormalStrength(0.65)
        expect_near(0.65, light:getNormalStrength(), 0.001)
    end)

    -- @covers LLight:clearNormalMap
    it("clearNormalMap resets the normal map path", function()
        local light = make_light()
        light:setNormalMap("assets/textures/normals/clear_me.png")
        light:clearNormalMap()
        expect_nil(light:getNormalMap())
    end)

    -- @covers LLight:type
    it("type returns LLight", function()
        expect_equal("LLight", make_light():type())
    end)

    -- @covers LLight:typeOf
    it("typeOf reports light inheritance", function()
        expect_true(make_light():typeOf("LLight"))
    end)
end)

-- @describe occluder handle methods
describe("occluder handle methods", function()
    -- @covers LOccluder:getPosition
    it("getPosition returns the occluder position", function()
        local x, y = make_occluder():getPosition()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LOccluder:setPosition
    it("setPosition updates the occluder position", function()
        local occluder = make_occluder()
        occluder:setPosition(12, 34)
        local x, y = occluder:getPosition()
        expect_near(12, x, 0.001)
        expect_near(34, y, 0.001)
    end)

    -- @covers LOccluder:getOpacity
    it("getOpacity returns the current opacity", function()
        expect_type("number", make_occluder():getOpacity())
    end)

    -- @covers LOccluder:setOpacity
    it("setOpacity updates the opacity", function()
        local occluder = make_occluder()
        occluder:setOpacity(0.75)
        expect_near(0.75, occluder:getOpacity(), 0.001)
    end)

    -- @covers LOccluder:getLightMask
    it("getLightMask returns the current light mask", function()
        expect_type("number", make_occluder():getLightMask())
    end)

    -- @covers LOccluder:setLightMask
    it("setLightMask updates the light mask", function()
        local occluder = make_occluder()
        occluder:setLightMask(42)
        expect_equal(42, occluder:getLightMask())
    end)

    -- @covers LOccluder:isEnabled
    it("isEnabled returns the enabled flag", function()
        expect_type("boolean", make_occluder():isEnabled())
    end)

    -- @covers LOccluder:setEnabled
    it("setEnabled updates the enabled flag", function()
        local occluder = make_occluder()
        occluder:setEnabled(false)
        expect_false(occluder:isEnabled())
    end)

    -- @covers LOccluder:isValid
    it("isValid becomes false after remove", function()
        local occluder = make_occluder()
        expect_true(occluder:isValid())
        occluder:remove()
        expect_false(occluder:isValid())
    end)

    -- @covers LOccluder:getVertices
    it("getVertices returns polygon coordinates", function()
        local verts = make_occluder():getVertices()
        expect_type("table", verts)
        expect_true(#verts >= 6)
    end)

    -- @covers LOccluder:setVertices
    it("setVertices updates polygon coordinates", function()
        local occluder = make_occluder()
        occluder:setVertices({ 0, 0, 30, 0, 15, 25 })
        local verts = occluder:getVertices()
        expect_true(#verts >= 6)
    end)

    -- @covers LOccluder:remove
    it("remove reduces the occluder count", function()
        local occluder = make_occluder()
        expect_equal(1, lurek.light.getOccluderCount())
        occluder:remove()
        expect_equal(0, lurek.light.getOccluderCount())
    end)

    -- @covers LOccluder:type
    it("type returns LOccluder", function()
        expect_equal("LOccluder", make_occluder():type())
    end)

    -- @covers LOccluder:typeOf
    it("typeOf reports occluder inheritance", function()
        expect_true(make_occluder():typeOf("LOccluder"))
    end)
end)
end
-- END test_light_core_unit.lua

test_summary()
