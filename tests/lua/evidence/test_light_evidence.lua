-- test_light_evidence.lua
-- Evidence test: lurek.light API + PNG visualisations
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.light.advanceFlickers
-- @covers lurek.light.clear
-- @covers lurek.light.getAmbient
-- @covers lurek.light.getGodRayHints
-- @covers lurek.light.getGroupCount
-- @covers lurek.light.getLightCount
-- @covers lurek.light.getMaxLights
-- @covers lurek.light.getNormalMapHints
-- @covers lurek.light.getOccluderCount
-- @covers lurek.light.isEnabled
-- @covers lurek.light.newLight
-- @covers lurek.light.newOccluder
-- @covers lurek.light.setAmbient
-- @covers lurek.light.setEnabled
-- @covers lurek.light.setGroupColor
-- @covers lurek.light.setGroupEnabled
-- @covers lurek.light.setGroupIntensity
-- @covers lurek.light.setMaxLights
-- @covers lurek.light.syncAmbient
-- @covers lurek.light.drawToImage

local OUT = "tests/output/light/"

local function clamp255(v)
    if v < 0 then return 0 end
    if v > 255 then return 255 end
    return math.floor(v)
end

-- @describe Evidence: lurek.light API + PNG visualization
describe("Evidence: lurek.light API + PNG visualization", function()
    -- @evidence file
    it("PNG: single point light with radial falloff", function()
        lurek.light.clear()
        lurek.light.setAmbient(0.08, 0.08, 0.10, 1.0)

        local W, H = 160, 160
        local light = lurek.light.newLight(80, 80, 70)
        light:setColor(1.0, 0.78, 0.26, 1.0)
        light:setIntensity(1.15)

        local img = lurek.light.drawToImage(W, H)

        lurek.image.savePNG(img, OUT .. "light_single_falloff.png")
        expect_evidence_created(OUT .. "light_single_falloff.png")

        light:remove()
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: light world controls, groups, hints and counters", function()
        lurek.light.clear()
        lurek.light.setEnabled(true)
        lurek.light.setMaxLights(32)
        lurek.light.setAmbient(0.12, 0.10, 0.16, 0.95)

        local W, H = 320, 180

        local l1 = lurek.light.newLight(70, 70, 56, { intensity = 1.0 })
        local l2 = lurek.light.newLight(165, 72, 62, { intensity = 0.9 })
        local l3 = lurek.light.newLight(245, 66, 50, { intensity = 0.8 })

        l1:setGroupId(1)
        l2:setGroupId(1)
        l3:setGroupId(2)
        lurek.light.setGroupColor(1, 0.25, 0.75, 1.0, 1.0)
        lurek.light.setGroupIntensity(1, 0.7)
        lurek.light.setGroupEnabled(2, false)

        local occ = lurek.light.newOccluder({ 95, 44, 128, 30, 150, 84, 112, 104 })

        l1:setFlicker(5.0, 0.25)
        lurek.light.advanceFlickers(0.16)

        local ambient_r, ambient_g, ambient_b, ambient_a = lurek.light.getAmbient()
        local enabled = lurek.light.isEnabled()
        local max_lights = lurek.light.getMaxLights()
        local light_count = lurek.light.getLightCount()
        local occ_count = lurek.light.getOccluderCount()
        local group1_count = lurek.light.getGroupCount(1)
        local group2_count = lurek.light.getGroupCount(2)
        local god_hints = lurek.light.getGodRayHints()
        local normal_hints = lurek.light.getNormalMapHints()

        -- render native light world
        local img = lurek.light.drawToImage(W, H)

        -- top bars summarize world state (drawn on top of the native render)
        img:drawRect(10, 8, light_count * 18, 10, 80, 200, 255, 255)
        img:drawRect(10, 24, group1_count * 18, 10, 80, 140, 255, 255)
        img:drawRect(10, 40, group2_count * 18, 10, 255, 90, 90, 255)
        img:drawRect(10, 56, occ_count * 18, 10, 220, 220, 130, 255)

        -- ambient strip
        img:drawRect(
            10,
            74,
            math.max(1, math.floor(ambient_a * 140)),
            10,
            clamp255(ambient_r * 255),
            clamp255(ambient_g * 255),
            clamp255(ambient_b * 255),
            255
        )

        -- tiny diagnostics as bars (no text API required)
        img:drawRect(170, 8, enabled and 40 or 8, 6, 120, 220, 140, 255)
        img:drawRect(170, 22, math.max(1, math.floor(max_lights / 2)), 6, 120, 180, 240, 255)
        img:drawRect(170, 36, math.max(1, #god_hints * 6), 6, 240, 190, 120, 255)
        img:drawRect(170, 50, math.max(1, #normal_hints * 6), 6, 200, 130, 240, 255)

        lurek.image.savePNG(img, OUT .. "light_world_controls.png")
        expect_evidence_created(OUT .. "light_world_controls.png")

        occ:remove()
        l1:remove()
        l2:remove()
        l3:remove()
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: multi-light additive blend with disabled world state", function()
        lurek.light.clear()
        lurek.light.setEnabled(false)
        local W, H = 224, 160

        local a = lurek.light.newLight(56, 70, 62)
        local b = lurek.light.newLight(112, 70, 62)
        local c = lurek.light.newLight(168, 70, 62)
        a:setColor(1.0, 0.25, 0.25, 1.0)
        b:setColor(0.25, 1.0, 0.25, 1.0)
        c:setColor(0.25, 0.25, 1.0, 1.0)

        local img = lurek.light.drawToImage(W, H)

        img:drawRect(8, 8, lurek.light.isEnabled() and 32 or 10, 6, 220, 220, 230, 255)

        lurek.image.savePNG(img, OUT .. "light_multi_scene.png")
        expect_evidence_created(OUT .. "light_multi_scene.png")

        a:remove()
        b:remove()
        c:remove()
        lurek.light.setEnabled(true)
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: occluder_corridor.png -- corridor with two occluders and grouped lights", function()
        lurek.light.clear()
        lurek.light.setAmbient(0.05, 0.05, 0.07, 1.0)

        local W, H = 360, 190

        local l1 = lurek.light.newLight(90, 95, 84, { intensity = 1.15 })
        local l2 = lurek.light.newLight(262, 95, 84, { intensity = 1.10 })
        l1:setGroupId(3)
        l2:setGroupId(3)
        lurek.light.setGroupColor(3, 0.95, 0.82, 0.40, 1.0)
        lurek.light.setGroupIntensity(3, 0.85)

        local occ_a = lurek.light.newOccluder({ 150, 34, 178, 34, 178, 162, 150, 162 })
        local occ_b = lurek.light.newOccluder({ 206, 34, 234, 34, 234, 162, 206, 162 })

        local img = lurek.light.drawToImage(W, H)

        img:drawRect(12, 10, lurek.light.getOccluderCount() * 18, 8, 235, 190, 110, 255)

        local path = OUT .. "occluder_corridor.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        occ_a:remove()
        occ_b:remove()
        l1:remove()
        l2:remove()
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: light_flicker_timeline.png -- flicker progression strips", function()
        lurek.light.clear()
        lurek.light.setAmbient(0.03, 0.03, 0.04, 1.0)

        local W, H = 320, 120
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 12, 16, 255)

        local torch = lurek.light.newLight(48, 60, 46)
        torch:setColor(1.0, 0.78, 0.33, 1.0)
        torch:setIntensity(1.0)
        torch:setFlicker(7.0, 0.35)

        local wall = lurek.light.newOccluder({ 130, 30, 136, 30, 136, 92, 130, 92 })

        for i = 0, 59 do
            lurek.light.advanceFlickers(1 / 30)
            local intensity = torch:getIntensity()
            local h = math.max(2, math.floor(intensity * 28))
            local x = 16 + i * 5
            img:drawRect(x, 102 - h, 4, h, 255, 170, 85, 255)
        end

        img:drawRect(130, 30, 6, 62, 30, 30, 34, 255)
        img:drawRect(12, 12, lurek.light.getLightCount() * 20, 6, 120, 210, 255, 255)
        img:drawRect(12, 22, lurek.light.getOccluderCount() * 20, 6, 255, 200, 120, 255)

        local path = OUT .. "light_flicker_timeline.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        wall:remove()
        torch:remove()
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: colored overlapping lights", function()
        lurek.light.clear()
        local W, H = 200, 200

        local r_light = lurek.light.newLight(80, 80, 70)
        r_light:setColor(1.0, 0.0, 0.0, 1.0)
        local g_light = lurek.light.newLight(120, 80, 70)
        g_light:setColor(0.0, 1.0, 0.0, 1.0)
        local b_light = lurek.light.newLight(100, 114, 70)
        b_light:setColor(0.0, 0.0, 1.0, 1.0)

        local img = lurek.light.drawToImage(W, H)

        local path = OUT .. "light_colored_overlap.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        r_light:remove()
        g_light:remove()
        b_light:remove()
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: spotlights with directional cones", function()
        lurek.light.clear()
        local W, H = 200, 200

        local s1 = lurek.light.newLight(100, 20, 150)
        s1:setLightType("spot")
        s1:setDirection(math.pi / 2)
        s1:setColor(1.0, 0.8, 0.6, 1.0)

        local s2 = lurek.light.newLight(20, 100, 120)
        s2:setLightType("spot")
        s2:setDirection(0)
        s2:setColor(0.5, 0.8, 1.0, 1.0)

        local s3 = lurek.light.newLight(180, 100, 120)
        s3:setLightType("spot")
        s3:setDirection(math.pi)
        s3:setColor(1.0, 0.4, 0.4, 1.0)

        local img = lurek.light.drawToImage(W, H)

        local path = OUT .. "light_spotlights.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        s1:remove()
        s2:remove()
        s3:remove()
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: moving light source streaks", function()
        lurek.light.clear()
        local W, H = 200, 100

        local lights = {}
        for i = 1, 5 do
            local x = 30 + (i - 1) * 35
            local l = lurek.light.newLight(x, 50, 40)
            l:setColor(1.0, 0.6, 0.2, 1.0)
            l:setIntensity(0.4)
            table.insert(lights, l)
        end

        local img = lurek.light.drawToImage(W, H)

        local path = OUT .. "light_streaks.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        for _, l in ipairs(lights) do l:remove() end
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: hard shadows with occluders", function()
        lurek.light.clear()
        local W, H = 200, 200

        local light = lurek.light.newLight(100, 100, 90)
        light:setColor(1.0, 0.9, 0.8, 1.0)

        local occ = lurek.light.newOccluder({ 120, 60, 140, 60, 140, 140, 120, 140 })

        local img = lurek.light.drawToImage(W, H)

        local path = OUT .. "light_hard_shadows.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        occ:remove()
        light:remove()
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: light map masking", function()
        lurek.light.clear()
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)

        -- Checkerboard background
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                if (math.floor(x / 20) + math.floor(y / 20)) % 2 == 0 then
                    img:setPixel(x, y, 60, 60, 70, 255)
                else
                    img:setPixel(x, y, 40, 40, 50, 255)
                end
            end
        end

        local light = lurek.light.newLight(100, 100, 80)
        light:setColor(1.5, 1.5, 2.0, 1.0)

        local light_map = lurek.light.drawToImage(W, H)

        img:mapPixel(function(x, y, r, g, b, a)
            local lr, lg, lb = light_map:getPixel(x, y)
            -- Multiply blend with light map
            return clamp255(r * (lr / 255)), clamp255(g * (lg / 255)), clamp255(b * (lb / 255)), 255
        end)

        local path = OUT .. "light_map_masking.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        light:remove()
        lurek.light.clear()
    end)
end)

test_summary()
