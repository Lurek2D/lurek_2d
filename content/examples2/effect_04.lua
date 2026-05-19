--- Effect Module: LOverlay extended methods

--@api-stub: LOverlay:drawToImage
--@api-stub: LOverlay:getAmbientColor
--@api-stub: LOverlay:setCustomShader
-- Overlay image export and ambient color.
do
    local ov = lurek.effect.newOverlay(800, 600)
    local r, g, b, a = ov:getAmbientColor()
    print("ambient", r, g, b, a)
    ov:setCustomShader("chromatic")
    local img = ov:drawToImage(800, 600)
    print("img type = " .. tostring(img))
end

--@api-stub: LOverlay:getTimeOfDay
--@api-stub: LOverlay:setTimeOfDay
-- Time-of-day lighting control on an overlay.
do
    local ov = lurek.effect.newOverlay(800, 600)
    local tod = ov:getTimeOfDay()
    print("time_of_day = " .. tostring(tod))
    ov:setTimeOfDay(0.5)
    ov:setTimeOfDay(0.0)
    ov:setTimeOfDay(1.0)
    print("time_of_day set")
end

--@api-stub: LOverlay:getWater
--@api-stub: LOverlay:setWater
--@api-stub: LOverlay:setWaterTint
-- Water configuration on overlay.
do
    local ov = lurek.effect.newOverlay(800, 600)
    local water = ov:getWater()
    print("water = " .. tostring(water))
    ov:setWater(0.5, 2.0, 1.0)
    ov:setWaterTint(0.1, 0.4, 0.8, 0.9)
    ov:setWaterTint(0.0, 0.0, 0.0, 0.5)
    print("water configured")
end

--@api-stub: LOverlay:pullAmbientFromLight
--@api-stub: LOverlay:pushAmbientToLight
--@api-stub: LOverlay:syncAmbientWithLight
-- Overlay-light ambient synchronization.
do
    local ov = lurek.effect.newOverlay(800, 600)
    ov:pullAmbientFromLight()
    ov:pushAmbientToLight()
    ov:syncAmbientWithLight("avg")
    ov:syncAmbientWithLight("light")
    print("ambient synced")
end

print("effect_04.lua")
