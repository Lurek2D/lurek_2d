-- test_light_evidence.lua
-- Evidence test: lurek.light API + PNG visualisations

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
        local img = lurek.image.newImageData(W, H)

        local light = lurek.light.newLight(80, 80, 70)
        light:setColor(1.0, 0.78, 0.26, 1.0)
        light:setIntensity(1.15)

        local lx, ly = light:getPosition()
        local lr = light:getRadius()
        local cr, cg, cb = light:getColor()
        local intensity = light:getIntensity()

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local dx = x - lx
                local dy = y - ly
                local dist = math.sqrt(dx * dx + dy * dy)
                local att = math.max(0.0, 1.0 - dist / lr)
                local r = clamp255((0.08 + cr * att * intensity) * 255)
                local g = clamp255((0.08 + cg * att * intensity) * 255)
                local b = clamp255((0.10 + cb * att * intensity) * 255)
                img:setPixel(x, y, r, g, b, 255)
            end
        end

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
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 20, 22, 30, 255)

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
        local sync_r, sync_g, sync_b, sync_a = lurek.light.syncAmbient()
        local enabled = lurek.light.isEnabled()
        local max_lights = lurek.light.getMaxLights()
        local light_count = lurek.light.getLightCount()
        local occ_count = lurek.light.getOccluderCount()
        local group1_count = lurek.light.getGroupCount(1)
        local group2_count = lurek.light.getGroupCount(2)
        local god_hints = lurek.light.getGodRayHints()
        local normal_hints = lurek.light.getNormalMapHints()

        -- top bars summarize world state
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

        -- simple radial blend for active lights
        local lights = { l1, l2 }
        for y = 90, H - 1 do
            for x = 0, W - 1 do
                local tr = sync_r
                local tg = sync_g
                local tb = sync_b
                for _, l in ipairs(lights) do
                    local lx, ly = l:getPosition()
                    local lr = l:getRadius()
                    local cr, cg, cb = l:getColor()
                    local dx = x - lx
                    local dy = y - ly
                    local dist = math.sqrt(dx * dx + dy * dy)
                    local att = math.max(0.0, 1.0 - dist / lr)
                    tr = tr + cr * att
                    tg = tg + cg * att
                    tb = tb + cb * att
                end
                img:setPixel(x, y, clamp255(tr * 255), clamp255(tg * 255), clamp255(tb * 255), 255)
            end
        end

        -- draw an occluder polygon outline over the blend
        img:drawLine(95, 44, 128, 30, 0, 0, 0, 255)
        img:drawLine(128, 30, 150, 84, 0, 0, 0, 255)
        img:drawLine(150, 84, 112, 104, 0, 0, 0, 255)
        img:drawLine(112, 104, 95, 44, 0, 0, 0, 255)

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
        local img = lurek.image.newImageData(W, H)

        local a = lurek.light.newLight(56, 70, 62)
        local b = lurek.light.newLight(112, 70, 62)
        local c = lurek.light.newLight(168, 70, 62)
        a:setColor(1.0, 0.25, 0.25, 1.0)
        b:setColor(0.25, 1.0, 0.25, 1.0)
        c:setColor(0.25, 0.25, 1.0, 1.0)

        local lights = { a, b, c }
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local tr, tg, tb = 0.06, 0.06, 0.08
                for _, l in ipairs(lights) do
                    local lx, ly = l:getPosition()
                    local lr = l:getRadius()
                    local cr, cg, cb = l:getColor()
                    local dx = x - lx
                    local dy = y - ly
                    local dist = math.sqrt(dx * dx + dy * dy)
                    local att = math.max(0.0, 1.0 - dist / lr)
                    tr = tr + cr * att * 0.9
                    tg = tg + cg * att * 0.9
                    tb = tb + cb * att * 0.9
                end
                img:setPixel(x, y, clamp255(tr * 255), clamp255(tg * 255), clamp255(tb * 255), 255)
            end
        end

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
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 12, 14, 20, 255)

        local l1 = lurek.light.newLight(90, 95, 84, { intensity = 1.15 })
        local l2 = lurek.light.newLight(262, 95, 84, { intensity = 1.10 })
        l1:setGroupId(3)
        l2:setGroupId(3)
        lurek.light.setGroupColor(3, 0.95, 0.82, 0.40, 1.0)
        lurek.light.setGroupIntensity(3, 0.85)

        local occ_a = lurek.light.newOccluder({ 150, 34, 178, 34, 178, 162, 150, 162 })
        local occ_b = lurek.light.newOccluder({ 206, 34, 234, 34, 234, 162, 206, 162 })

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local tr, tg, tb = 0.05, 0.05, 0.07
                local lights = { l1, l2 }
                for _, l in ipairs(lights) do
                    local lx, ly = l:getPosition()
                    local lr = l:getRadius()
                    local cr, cg, cb = l:getColor()
                    local dx = x - lx
                    local dy = y - ly
                    local dist = math.sqrt(dx * dx + dy * dy)
                    local att = math.max(0.0, 1.0 - dist / lr)
                    tr = tr + cr * att
                    tg = tg + cg * att
                    tb = tb + cb * att
                end
                img:setPixel(x, y, clamp255(tr * 255), clamp255(tg * 255), clamp255(tb * 255), 255)
            end
        end

        img:drawRect(150, 34, 28, 128, 16, 16, 18, 255)
        img:drawRect(206, 34, 28, 128, 16, 16, 18, 255)
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
        img:drawRect(0, 0, W, H, 10, 12, 16, 255)

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
    -- 6. @evidence file
    it("PNG: colored overlapping lights", function()
        lurek.light.clear()
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)

        local r_light = lurek.light.newLight(80, 80, 70)
        r_light:setColor(1.0, 0.0, 0.0, 1.0)
        local g_light = lurek.light.newLight(120, 80, 70)
        g_light:setColor(0.0, 1.0, 0.0, 1.0)
        local b_light = lurek.light.newLight(100, 114, 70)
        b_light:setColor(0.0, 0.0, 1.0, 1.0)

        local lights = { r_light, g_light, b_light }

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local tr, tg, tb = 0, 0, 0
                for _, l in ipairs(lights) do
                    local lx, ly = l:getPosition()
                    local lr = l:getRadius()
                    local cr, cg, cb = l:getColor()
                    local dx = x - lx
                    local dy = y - ly
                    local dist = math.sqrt(dx * dx + dy * dy)
                    local att = math.max(0.0, 1.0 - dist / lr)
                    tr = tr + cr * att
                    tg = tg + cg * att
                    tb = tb + cb * att
                end
                img:setPixel(x, y, clamp255(tr * 255), clamp255(tg * 255), clamp255(tb * 255), 255)
            end
        end

        local path = OUT .. "light_colored_overlap.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        r_light:remove()
        g_light:remove()
        b_light:remove()
        lurek.light.clear()
    end)

    -- 7. @evidence file
    it("PNG: spotlights with directional cones", function()
        lurek.light.clear()
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 10, 15, 255)

        local function draw_spotlight(lx, ly, dir_x, dir_y, lr, angle_deg, cr, cg, cb)
            local angle_rad = math.rad(angle_deg / 2)
            local min_dot = math.cos(angle_rad)
            -- normalize dir
            local dlen = math.sqrt(dir_x*dir_x + dir_y*dir_y)
            dir_x, dir_y = dir_x / dlen, dir_y / dlen

            for y = 0, H - 1 do
                for x = 0, W - 1 do
                    local dx = x - lx
                    local dy = y - ly
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < lr and dist > 0 then
                        local ndx, ndy = dx / dist, dy / dist
                        local dot = ndx * dir_x + ndy * dir_y
                        if dot > min_dot then
                            local att = (1.0 - dist / lr) * ((dot - min_dot) / (1.0 - min_dot))
                            local pr, pg, pb = img:getPixel(x, y)
                            img:setPixel(x, y, 
                                clamp255(pr + cr * att * 255),
                                clamp255(pg + cg * att * 255),
                                clamp255(pb + cb * att * 255), 255)
                        end
                    end
                end
            end
        end

        draw_spotlight(100, 20, 0, 1, 150, 60, 1.0, 0.8, 0.6)
        draw_spotlight(20, 100, 1, 0, 120, 45, 0.5, 0.8, 1.0)
        draw_spotlight(180, 100, -1, 0, 120, 45, 1.0, 0.4, 0.4)

        local path = OUT .. "light_spotlights.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 8. @evidence file
    it("PNG: moving light source streaks", function()
        lurek.light.clear()
        local W, H = 200, 100
        local img = lurek.image.newImageData(W, H)
        img:fill(5, 5, 10, 255)

        -- render a light moving horizontally across 5 frames
        local y = 50
        local lr = 40
        for i = 1, 5 do
            local x = 30 + (i - 1) * 35
            for py = 0, H - 1 do
                for px = 0, W - 1 do
                    local dx = px - x
                    local dy = py - y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < lr then
                        local att = (1.0 - dist / lr) * 0.4 -- faint streak
                        local pr, pg, pb = img:getPixel(px, py)
                        img:setPixel(px, py, 
                            clamp255(pr + 1.0 * att * 255),
                            clamp255(pg + 0.6 * att * 255),
                            clamp255(pb + 0.2 * att * 255), 255)
                    end
                end
            end
        end

        local path = OUT .. "light_streaks.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 9. @evidence file
    it("PNG: hard shadows with occluders", function()
        lurek.light.clear()
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 25, 255)

        local lx, ly = 100, 100
        local lr = 90
        
        -- simple occluder rect
        local ox, oy, ow, oh = 120, 60, 20, 80
        img:drawRect(ox, oy, ow, oh, 10, 10, 10, 255)

        local function ray_intersects_rect(rx, ry, rdx, rdy)
            -- AABB intersection for ray
            local tmin = (ox - rx) / rdx
            local tmax = (ox + ow - rx) / rdx
            if tmin > tmax then tmin, tmax = tmax, tmin end

            local tymin = (oy - ry) / rdy
            local tymax = (oy + oh - ry) / rdy
            if tymin > tymax then tymin, tymax = tymax, tymin end

            if (tmin > tymax) or (tymin > tmax) then
                return false
            end
            
            local t = math.max(tmin, tymin)
            return t > 0 and t < 1
        end

        for py = 0, H - 1 do
            for px = 0, W - 1 do
                if not (px >= ox and px <= ox + ow and py >= oy and py <= oy + oh) then
                    local dx = px - lx
                    local dy = py - ly
                    local dist = math.sqrt(dx*dx + dy*dy)
                    if dist < lr then
                        -- Check occlusion
                        if not ray_intersects_rect(lx, ly, dx, dy) then
                            local att = 1.0 - dist / lr
                            local pr, pg, pb = img:getPixel(px, py)
                            img:setPixel(px, py, 
                                clamp255(pr + 1.0 * att * 200),
                                clamp255(pg + 0.9 * att * 200),
                                clamp255(pb + 0.8 * att * 200), 255)
                        end
                    end
                end
            end
        end

        local path = OUT .. "light_hard_shadows.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- 10. @evidence file
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

        local lx, ly, lr = 100, 100, 80
        
        img:mapPixel(function(x, y, r, g, b, a)
            local dx = x - lx
            local dy = y - ly
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist < lr then
                local att = 1.0 - (dist / lr)^2 -- quadratic falloff
                -- Apply light color and intensity
                return clamp255(r * att * 1.5), clamp255(g * att * 1.5), clamp255(b * att * 2.0), 255
            else
                -- Masked out completely (ambient only)
                return clamp255(r * 0.2), clamp255(g * 0.2), clamp255(b * 0.2), 255
            end
        end)

        local path = OUT .. "light_map_masking.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

end)

test_summary()
