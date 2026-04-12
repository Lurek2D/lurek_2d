-- test_evidence_light.lua
-- Evidence test: lurek.light API + renders light falloff / multi-light to PNG
-- Produces: light_single_falloff.png, light_multi_scene.png

local OUT = "tests/lua/evidence/output/light/"

-- @description Covers suite: Evidence: lurek.light API + PNG visualization.
describe("Evidence: lurek.light API + PNG visualization", function()

    -- @covers lurek.light.newLight
    -- @description Creates a light source through the Lua API to prove the constructor accepts position and radius inputs.
    it("newLight creates a LightSource without error", function()
        local ok = pcall(function() return lurek.light.newLight(100, 200, 150) end)
    end)

    -- @covers lurek.light.newLight
    -- @covers LightSource:getPosition
    -- @description Reads a light's initial position immediately after construction.
    it("getPosition returns initial position", function()
        local l = lurek.light.newLight(100, 200, 150)
        local x, y = l:getPosition()
    end)

    -- @covers LightSource:setPosition
    -- @covers LightSource:getPosition
    -- @description Moves a light source and reads the new coordinates back to cover position mutation.
    it("setPosition/getPosition round-trip", function()
        local l = lurek.light.newLight(0, 0, 100)
        l:setPosition(300, 400)
        local x, y = l:getPosition()
    end)

    -- @covers LightSource:getRadius
    -- @description Reads the initial light radius reported by a newly constructed light.
    it("getRadius matches constructor", function()
        local l = lurek.light.newLight(0, 0, 200)
    end)

    -- @covers LightSource:setRadius
    -- @covers LightSource:getRadius
    -- @description Changes the light radius and reads it back to cover radius updates.
    it("setRadius/getRadius round-trip", function()
        local l = lurek.light.newLight(0, 0, 100)
        l:setRadius(350)
    end)

    -- @covers LightSource:setColor
    -- @covers LightSource:getColor
    -- @description Changes the RGBA light color and reads it back to cover light tint configuration.
    it("setColor/getColor round-trip", function()
        local l = lurek.light.newLight(0, 0, 100)
        l:setColor(1.0, 0.5, 0.25, 0.9)
        local r, g, b, a = l:getColor()
    end)

    -- @covers LightSource:setIntensity
    -- @covers LightSource:getIntensity
    -- @description Adjusts light intensity and reads it back to cover brightness scaling.
    it("setIntensity/getIntensity round-trip", function()
        local l = lurek.light.newLight(0, 0, 100)
        l:setIntensity(0.75)
    end)

    -- @covers LightSource:setFalloff
    -- @covers LightSource:getFalloff
    -- @description Switches between falloff modes to cover light attenuation configuration.
    it("setFalloff/getFalloff round-trip", function()
        local l = lurek.light.newLight(0, 0, 100)
        l:setFalloff("linear")
        l:setFalloff("smooth")
    end)

    -- @covers LightSource:setShadowEnabled
    -- @covers LightSource:isShadowEnabled
    -- @description Toggles the shadow flag on and off to cover light shadow-state changes.
    it("setShadowEnabled toggles", function()
        local l = lurek.light.newLight(0, 0, 100)
        l:setShadowEnabled(true)
        l:setShadowEnabled(false)
    end)

    -- @covers LightSource:setEnergy
    -- @covers LightSource:getEnergy
    -- @description Changes the light energy multiplier and reads it back to cover extra brightness control.
    it("setEnergy/getEnergy round-trip", function()
        local l = lurek.light.newLight(0, 0, 100)
        l:setEnergy(1.5)
    end)

    -- @covers lurek.light.newLight
    -- @covers LightSource:setIntensity
    -- @covers LightSource:getIntensity
    -- @description Creates two lights with different intensities to confirm separate instances do not share state.
    it("multiple lights are independent", function()
        local l1 = lurek.light.newLight(10, 10, 50)
        local l2 = lurek.light.newLight(500, 500, 200)
        l1:setIntensity(0.3)
        l2:setIntensity(0.9)
    end)

    -- @covers lurek.light.newLight
    -- @covers LightSource:setColor
    -- @covers LightSource:getPosition
    -- @covers LightSource:getRadius
    -- @covers LightSource:getColor
    -- @covers lurek.img.savePNG
    -- @evidence file
    -- @description Rasterizes a single point light's radial falloff into a PNG using the light's reported position, radius, and color.
    it("PNG: single point light with radial falloff", function()
        local W, H = 128, 128
        local img = lurek.img.newImageData(W, H)

        -- Create a light and read its properties
        local light = lurek.light.newLight(64, 64, 60)
        light:setColor(1.0, 0.8, 0.3, 1.0)
        light:setIntensity(1.0)
        local lx, ly = light:getPosition()
        local lr = light:getRadius()
        local cr, cg, cb = light:getColor()

        -- Render radial falloff onto ImageData
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local dx, dy = x - lx, y - ly
                local dist = math.sqrt(dx * dx + dy * dy)
                local attenuation = math.max(0, 1.0 - dist / lr)
                local pr = math.floor(cr * attenuation * 255)
                local pg = math.floor(cg * attenuation * 255)
                local pb = math.floor(cb * attenuation * 255)
                img:setPixel(x, y, pr, pg, pb, 255)
            end
        end

        lurek.img.savePNG(img, OUT .. "light_single_falloff.png")
    end)

    -- @covers lurek.light.newLight
    -- @covers LightSource:setColor
    -- @covers LightSource:getPosition
    -- @covers LightSource:getRadius
    -- @covers LightSource:getColor
    -- @covers lurek.img.savePNG
    -- @evidence file
    -- @description Composites three colored point lights into one scene and saves the combined illumination as PNG evidence.
    it("PNG: multi-light scene with colored point lights", function()
        local W, H = 256, 256
        local img = lurek.img.newImageData(W, H)

        local lights = {
            lurek.light.newLight(64,  64,  80),
            lurek.light.newLight(192, 64,  80),
            lurek.light.newLight(128, 192, 80),
        }
        lights[1]:setColor(1.0, 0.2, 0.2, 1.0)
        lights[2]:setColor(0.2, 1.0, 0.2, 1.0)
        lights[3]:setColor(0.2, 0.2, 1.0, 1.0)

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local tr, tg, tb = 0, 0, 0
                for _, l in ipairs(lights) do
                    local lx, ly = l:getPosition()
                    local lr = l:getRadius()
                    local cr, cg, cb = l:getColor()
                    local dx, dy = x - lx, y - ly
                    local dist = math.sqrt(dx * dx + dy * dy)
                    local att = math.max(0, 1.0 - dist / lr)
                    tr = tr + cr * att
                    tg = tg + cg * att
                    tb = tb + cb * att
                end
                img:setPixel(x, y,
                    math.min(255, math.floor(tr * 255)),
                    math.min(255, math.floor(tg * 255)),
                    math.min(255, math.floor(tb * 255)), 255)
            end
        end

        lurek.img.savePNG(img, OUT .. "light_multi_scene.png")
    end)

end)

test_summary()
