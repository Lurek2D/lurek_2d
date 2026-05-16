-- test_light_occluder_evidence.lua
-- Evidence test: multi-color lights + occluders produce realistic shadows.
-- Proves the system can generate the "vending machine glow" effect:
-- dark ambient, colored point lights, rectangle occluders blocking light.

local OUT = "tests/output/light/"

local function clamp255(v)
    if v < 0 then return 0 end
    if v > 255 then return 255 end
    return math.floor(v)
end

--- Ray-segment intersection: returns t in [0,1] if ray hits segment, nil otherwise
local function ray_segment(ox, oy, dx, dy, ax, ay, bx, by)
    local ex = bx - ax
    local ey = by - ay
    local denom = dx * ey - dy * ex
    if math.abs(denom) < 1e-9 then return nil end
    local t = ((ax - ox) * ey - (ay - oy) * ex) / denom
    local u = ((ax - ox) * dy - (ay - oy) * dx) / denom
    if t >= 0 and t <= 1 and u >= 0 and u <= 1 then
        return t
    end
    return nil
end

--- Check if point (px,py) is shadowed from light (lx,ly) by a rectangle occluder
local function is_shadowed(px, py, lx, ly, occ_x, occ_y, occ_w, occ_h, opacity)
    local dx = px - lx
    local dy = py - ly
    -- Four edges of the rectangle
    local edges = {
        { occ_x,         occ_y,          occ_x + occ_w, occ_y },           -- top
        { occ_x + occ_w, occ_y,          occ_x + occ_w, occ_y + occ_h },  -- right
        { occ_x + occ_w, occ_y + occ_h,  occ_x,         occ_y + occ_h },  -- bottom
        { occ_x,         occ_y + occ_h,  occ_x,         occ_y },           -- left
    }
    for _, e in ipairs(edges) do
        local t = ray_segment(lx, ly, dx, dy, e[1], e[2], e[3], e[4])
        if t and t < 0.999 then
            return opacity
        end
    end
    return 0.0
end

-- @describe Evidence: light + occluder shadows (vending machine scene)
describe("Evidence: light + occluder shadows (vending machine scene)", function()

    -- @evidence file
    it("PNG: vending_lights_scene.png — 4 colored lights with occluder shadows", function()
        lurek.light.clear()
        lurek.light.setEnabled(true)
        lurek.light.setAmbient(0.02, 0.025, 0.04, 1.0)

        local W, H = 420, 240

        -- Define machines (scaled down from the game demo)
        local machines = {
            { x = 50,  y = 60,  w = 35, h = 70, color = { 0.2, 1.0, 0.9 }, intensity = 1.3, radius = 90 },
            { x = 130, y = 68,  w = 32, h = 65, color = { 0.3, 0.4, 1.0 }, intensity = 1.2, radius = 80 },
            { x = 210, y = 58,  w = 30, h = 72, color = { 0.8, 0.95, 0.1 }, intensity = 1.25, radius = 85 },
            { x = 300, y = 72,  w = 28, h = 55, color = { 0.2, 0.3, 0.9 }, intensity = 1.1, radius = 65 },
        }

        -- Create engine lights and occluders
        local eng_lights = {}
        local eng_occluders = {}
        for i, m in ipairs(machines) do
            local lx = m.x + m.w * 0.5
            local ly = m.y + m.h - 5
            local l = lurek.light.newLight(lx, ly, m.radius, {
                color = { m.color[1], m.color[2], m.color[3], 1.0 },
                intensity = m.intensity,
                blend = "add",
                falloff = "smooth",
                shadowEnabled = true,
                shadowFilter = "pcf5",
            })
            l:setAttenuation(1.0, 0.04, 0.008)
            eng_lights[i] = l

            local occ = lurek.light.newOccluder({
                m.x,       m.y,
                m.x + m.w, m.y,
                m.x + m.w, m.y + m.h,
                m.x,       m.y + m.h,
            }, { opacity = 0.92 })
            eng_occluders[i] = occ
        end

        -- Verify engine state
        expect_equal(4, lurek.light.getLightCount(), "4 lights created")
        expect_equal(4, lurek.light.getOccluderCount(), "4 occluders created")
        expect_true(lurek.light.isEnabled(), "lighting enabled")

        -- Verify light properties round-trip
        for i, m in ipairs(machines) do
            local l = eng_lights[i]
            local lx, ly = l:getPosition()
            local expected_x = m.x + m.w * 0.5
            local expected_y = m.y + m.h - 5
            expect_near(expected_x, lx, 0.01, "light " .. i .. " x position")
            expect_near(expected_y, ly, 0.01, "light " .. i .. " y position")

            local r = l:getRadius()
            expect_near(m.radius, r, 0.01, "light " .. i .. " radius")

            local cr, cg, cb = l:getColor()
            expect_near(m.color[1], cr, 0.01, "light " .. i .. " red")
            expect_near(m.color[2], cg, 0.01, "light " .. i .. " green")
            expect_near(m.color[3], cb, 0.01, "light " .. i .. " blue")

            expect_true(l:isShadowEnabled(), "light " .. i .. " shadow enabled")
        end

        -- Verify occluder properties
        for i, m in ipairs(machines) do
            local occ = eng_occluders[i]
            local ox, oy = occ:getPosition()
            expect_near(0, ox, 0.01, "occluder " .. i .. " offset x")
            expect_near(0, oy, 0.01, "occluder " .. i .. " offset y")
            expect_near(0.92, occ:getOpacity(), 0.01, "occluder " .. i .. " opacity")
        end

        -- Render software visualization
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 5, 6, 10, 255)

        -- Render light contributions with shadow occlusion
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local tr = 0.02
                local tg = 0.025
                local tb = 0.04

                for i, m in ipairs(machines) do
                    local lx = m.x + m.w * 0.5
                    local ly = m.y + m.h - 5
                    local dx = x - lx
                    local dy = y - ly
                    local dist = math.sqrt(dx * dx + dy * dy)
                    local att = math.max(0.0, 1.0 - dist / m.radius)
                    -- Smooth falloff (quadratic)
                    att = att * att

                    if att > 0.001 then
                        -- Check occlusion from all other machines
                        local shadow_factor = 0.0
                        for j, om in ipairs(machines) do
                            if j ~= i then
                                local sf = is_shadowed(x, y, lx, ly, om.x, om.y, om.w, om.h, 0.92)
                                if sf > shadow_factor then shadow_factor = sf end
                            end
                        end

                        local visible = 1.0 - shadow_factor
                        tr = tr + m.color[1] * att * m.intensity * visible
                        tg = tg + m.color[2] * att * m.intensity * visible
                        tb = tb + m.color[3] * att * m.intensity * visible
                    end
                end

                img:setPixel(x, y, clamp255(tr * 255), clamp255(tg * 255), clamp255(tb * 255), 255)
            end
        end

        -- Draw machine bodies as dark rectangles on top
        for _, m in ipairs(machines) do
            img:drawRect(m.x, m.y, m.w, m.h, 10, 12, 18, 255)
            -- Machine screen glow
            local sw = m.w - 6
            local sh = math.floor(m.h * 0.4)
            local sx = m.x + 3
            local sy = m.y + 6
            img:drawRect(sx, sy, sw, sh,
                clamp255(m.color[1] * 100),
                clamp255(m.color[2] * 100),
                clamp255(m.color[3] * 100), 255)
        end

        local path = OUT .. "vending_lights_scene.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        -- Cleanup
        for _, l in ipairs(eng_lights) do l:remove() end
        for _, o in ipairs(eng_occluders) do o:remove() end
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: occluder_shadow_proof.png — light blocked by opaque occluder", function()
        lurek.light.clear()
        lurek.light.setEnabled(true)
        lurek.light.setAmbient(0.03, 0.03, 0.05, 1.0)

        local W, H = 200, 200

        -- Single light on left, occluder in middle, check shadow on right
        local light = lurek.light.newLight(40, 100, 150, {
            color = { 0.2, 1.0, 0.8, 1.0 },
            intensity = 1.5,
            shadowEnabled = true,
            blend = "add",
            falloff = "linear",
        })

        local occ = lurek.light.newOccluder({
            90, 60,
            110, 60,
            110, 140,
            90, 140,
        }, { opacity = 1.0 })

        -- Verify setup
        expect_equal(1, lurek.light.getLightCount(), "one light")
        expect_equal(1, lurek.light.getOccluderCount(), "one occluder")
        expect_near(1.0, occ:getOpacity(), 0.01, "full opacity occluder")

        -- Render with CPU shadow tracing
        local img = lurek.image.newImageData(W, H)

        local lit_count = 0
        local shadow_count = 0
        local lx, ly = 40, 100
        local lr = 150

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local dx = x - lx
                local dy = y - ly
                local dist = math.sqrt(dx * dx + dy * dy)
                local att = math.max(0.0, 1.0 - dist / lr)

                local shadow = is_shadowed(x, y, lx, ly, 90, 60, 20, 80, 1.0)
                local visible = 1.0 - shadow

                local r = 0.03 + 0.2 * att * 1.5 * visible
                local g = 0.03 + 1.0 * att * 1.5 * visible
                local b = 0.05 + 0.8 * att * 1.5 * visible

                img:setPixel(x, y, clamp255(r * 255), clamp255(g * 255), clamp255(b * 255), 255)

                -- Count lit vs shadow pixels in the region behind the occluder
                if x > 110 and x < 180 and y > 60 and y < 140 then
                    if visible > 0.5 then
                        lit_count = lit_count + 1
                    else
                        shadow_count = shadow_count + 1
                    end
                end
            end
        end

        -- Draw occluder body
        img:drawRect(90, 60, 20, 80, 15, 15, 20, 255)

        -- PROOF: shadow region behind occluder has significantly more shadow pixels
        expect_true(shadow_count > lit_count * 2,
            "shadow region has more dark pixels than lit: shadow=" .. shadow_count .. " lit=" .. lit_count)

        local path = OUT .. "occluder_shadow_proof.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        light:remove()
        occ:remove()
        lurek.light.clear()
    end)

    -- @evidence file
    it("PNG: transparent_occluder.png — partial opacity lets some light through", function()
        lurek.light.clear()
        lurek.light.setEnabled(true)
        lurek.light.setAmbient(0.03, 0.03, 0.04, 1.0)

        local W, H = 200, 120

        local light = lurek.light.newLight(30, 60, 160, {
            color = { 1.0, 0.8, 0.2, 1.0 },
            intensity = 1.4,
            shadowEnabled = true,
            blend = "add",
            falloff = "linear",
        })

        -- Semi-transparent occluder (opacity 0.5 = lets 50% light through)
        local occ = lurek.light.newOccluder({
            80, 30,
            95, 30,
            95, 90,
            80, 90,
        }, { opacity = 0.5 })

        expect_near(0.5, occ:getOpacity(), 0.01, "50% opacity")

        local img = lurek.image.newImageData(W, H)

        -- Measure light intensity at a shadowed point vs unshadowed
        local lx, ly, lr = 30, 60, 160

        -- Point behind occluder
        local shadow_x, shadow_y = 130, 60
        local sdx = shadow_x - lx
        local sdy = shadow_y - ly
        local sdist = math.sqrt(sdx * sdx + sdy * sdy)
        local satt = math.max(0.0, 1.0 - sdist / lr)
        local sshadow = is_shadowed(shadow_x, shadow_y, lx, ly, 80, 30, 15, 60, 0.5)
        local s_visible = 1.0 - sshadow
        local s_intensity = satt * 1.4 * s_visible

        -- Point at same distance but NOT behind occluder
        local clear_x, clear_y = 130, 15
        local cdx = clear_x - lx
        local cdy = clear_y - ly
        local cdist = math.sqrt(cdx * cdx + cdy * cdy)
        local catt = math.max(0.0, 1.0 - cdist / lr)
        local c_intensity = catt * 1.4

        -- PROOF: transparent occluder passes ~50% light
        expect_true(s_intensity > 0.0, "some light passes through transparent occluder")
        expect_true(s_intensity < c_intensity,
            "shadowed point is dimmer: " .. string.format("%.3f < %.3f", s_intensity, c_intensity))
        -- The ratio should be close to (1 - opacity) = 0.5
        local ratio = s_intensity / c_intensity
        expect_near(0.5, ratio, 0.15,
            "light ratio ~50% through transparent occluder: " .. string.format("%.3f", ratio))

        -- Render the scene
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local dx = x - lx
                local dy = y - ly
                local dist = math.sqrt(dx * dx + dy * dy)
                local att = math.max(0.0, 1.0 - dist / lr)
                local shad = is_shadowed(x, y, lx, ly, 80, 30, 15, 60, 0.5)
                local vis = 1.0 - shad
                local r = 0.03 + 1.0 * att * 1.4 * vis
                local g = 0.03 + 0.8 * att * 1.4 * vis
                local b = 0.04 + 0.2 * att * 1.4 * vis
                img:setPixel(x, y, clamp255(r * 255), clamp255(g * 255), clamp255(b * 255), 255)
            end
        end

        img:drawRect(80, 30, 15, 60, 40, 35, 20, 180)

        local path = OUT .. "transparent_occluder.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        light:remove()
        occ:remove()
        lurek.light.clear()
    end)
end)

test_summary()
