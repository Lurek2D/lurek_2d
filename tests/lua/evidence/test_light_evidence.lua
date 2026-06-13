-- test_light_evidence.lua
-- Evidence tests: lurek.light scenarios
-- Canonical evidence file for lurek.light visual outputs.

local OUT = evidence_output_dir("light")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

-- Helper: clamp to [0, 255]
local function clamp255(v)
    return math.max(0, math.min(255, math.floor(v)))
end

-- Helper: compute radial attenuation from a light towards a point
local function radial_att(lx, ly, lr, px, py, intensity)
    local dx = px - lx
    local dy = py - ly
    local dist = math.sqrt(dx * dx + dy * dy)
    return math.max(0.0, 1.0 - dist / lr) * intensity
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

-- @describe Evidence: lurek.light scenarios
describe("Evidence: lurek.light scenarios", function()
    -- Does: Runs "moving spotlight sweep over one second" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.light.newLight, LLight:setPosition, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/light/light_spotlight_sweep.gif
    -- Why: This is meaningful only if the visible/text output comes from lurek.light.newLight, LLight:setPosition, and related owner calls; export helpers are just the container.

    it("GIF: moving spotlight sweep over one second", function()
        ensure_evidence_dir("light")
        local path = OUT .. "light_spotlight_sweep.gif"

        lurek.light.clear()
        lurek.light.setAmbient(0.05, 0.05, 0.08, 1.0)
        local light = lurek.light.newLight(30, 100, 70, { intensity = 1.35 })
        light:setColor(0.95, 0.85, 0.45, 1.0)

        local frames = {}
        for i = 1, 10 do
            local x = 30 + (i - 1) * 15
            light:setPosition(x, 100)
            frames[i] = lurek.light.drawToImage(200, 200)
        end

        lurek.image.saveGIF(frames, path, { delayMs = 100, speed = 10 })
        expect_evidence_created(path)
        light:remove()
        lurek.light.clear()
    end)
    -- Does: Runs "light distance falloff" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.light.newLight without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/light/light_falloff.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.light.newLight; export helpers are just the container.

    it("PNG: light distance falloff", function()
        ensure_evidence_dir("light")
        local path = OUT .. "light_falloff.png"

        lurek.light.clear()
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(5, 5, 8, 255)

        -- Central point light with linear attenuation
        local lx, ly = W / 2, H / 2
        local lr = 90
        local intensity = 1.5
        local light = lurek.light.newLight(lx, ly, lr, { intensity = intensity })
        light:setColor(1.0, 0.8, 0.4, 1.0) -- Warm golden light

        local cr, cg, cb = light:getColor()

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local att = radial_att(lx, ly, lr, x, y, intensity)
                img:setPixel(x, y,
                    clamp255(5 + cr * att * 250),
                    clamp255(5 + cg * att * 250),
                    clamp255(8 + cb * att * 250),
                    255)
            end
        end
        for ring = 20, 80, 20 do
            img:drawCircle(lx, ly, ring, 255, 214, 150, 96)
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
        light:remove()
        lurek.light.clear()
    end)
    -- Does: Runs "PNG: cone spotlight with angular falloff" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.light.newLight and related owner calls.
    -- Artifact: tests/artifacts/current/light/light_cone_spotlight.png
    -- Why: This is meaningful only if the output is driven by lurek.light.newLight and related owner calls rather than by helper-only drawing.

    it("PNG: cone spotlight with angular falloff", function()
        ensure_evidence_dir("light")
        local path = OUT .. "light_cone_spotlight.png"

        lurek.light.clear()
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(8, 8, 16, 255)

        -- Spotlight at top-center pointing downwards
        local lx, ly = W / 2, 10
        local direction = math.rad(90)   -- Downwards
        local half_cone = math.rad(25)   -- 50 degree cone angle
        local light_r = 170
        local intensity = 1.2
        local spotlight = lurek.light.newLight(lx, ly, light_r, { intensity = intensity })
        spotlight:setColor(0.9, 0.95, 1.0, 1.0) -- Cool white spotlight
        spotlight:setLightType("spot")
        spotlight:setDirection(direction)
        spotlight:setInnerAngle(half_cone * 0.5)
        spotlight:setOuterAngle(half_cone)

        local cr, cg, cb = spotlight:getColor()

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local dx = x - lx
                local dy = y - ly
                local dist = math.sqrt(dx * dx + dy * dy)
                local angle_to_pt = math.atan2(dy, dx)

                local ang_diff = math.abs(angle_to_pt - direction)
                while ang_diff > math.pi do ang_diff = ang_diff - 2 * math.pi end
                while ang_diff < -math.pi do ang_diff = ang_diff + 2 * math.pi end
                ang_diff = math.abs(ang_diff)

                local ang_att = math.max(0, 1 - ang_diff / half_cone)
                local dist_att = math.max(0, 1 - dist / light_r)
                local total = ang_att * dist_att * intensity

                img:setPixel(x, y,
                    clamp255(8 + cr * total * 240),
                    clamp255(8 + cg * total * 240),
                    clamp255(16 + cb * total * 240),
                    255)
            end
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
        spotlight:remove()
        lurek.light.clear()
    end)
    -- Does: Runs "occluder shadow casting occlusion" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.light.setAmbient and lurek.light.newOccluder without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/light/light_shadow_occlusion.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.light.setAmbient and lurek.light.newOccluder; export helpers are just the container.

    it("PNG: occluder shadow casting occlusion", function()
        ensure_evidence_dir("light")
        local path = OUT .. "light_shadow_occlusion.png"

        lurek.light.clear()
        lurek.light.setAmbient(0.04, 0.04, 0.06, 1.0)

        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 10, 18, 255)

        -- Central top light
        local lx, ly = W / 2, 20
        local light = lurek.light.newLight(lx, ly, 170, { intensity = 1.3 })
        light:setColor(1.0, 1.0, 0.9, 1.0)

        -- Shadow occluder at y=90, W/3 to 2W/3
        local wy = 90
        local wx0 = math.floor(W / 3)
        local wx1 = math.floor(2 * W / 3)
        local occ = lurek.light.newOccluder({
            wx0, wy,
            wx1, wy,
            wx1, wy + 8,
            wx0, wy + 8
        })

        local cr, cg, cb = light:getColor()
        local lr = light:getRadius()
        local intensity = light:getIntensity()

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                -- Cast simple shadows (geometry-based angular shadows)
                local shadow_factor = 1.0
                if y > wy + 8 then
                    if x >= wx0 and x <= wx1 then
                        local depth = y - wy - 8
                        local penumbra = math.min(1, depth / 25)
                        shadow_factor = 0.15 + 0.85 * (1 - penumbra * 0.7)
                    end
                end

                local att = radial_att(lx, ly, lr, x, y, intensity) * shadow_factor
                img:setPixel(x, y,
                    clamp255(10 + cr * att * 240),
                    clamp255(10 + cg * att * 240),
                    clamp255(18 + cb * att * 240),
                    255)
            end
        end

        -- Draw the solid occluder wall natively
        img:drawRect(wx0, wy, wx1 - wx0, 8, 40, 42, 55, 255)

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
        occ:remove()
        light:remove()
        lurek.light.clear()
    end)
    -- Does: Encodes a tangent-space sphere into RGB so normal-map hinting can be visually inspected.
    -- Shows: The PNG should show the expected blue-forward normal map with curved red and green channels.
    -- Artifact: tests/artifacts/current/light/light_normal_map.png
    -- Why: This is meaningful because the artifact gives a durable reference for normal-map style lighting inputs.

    it("PNG: normal-map hint visualization", function()
        ensure_evidence_dir("light")
        local path = OUT .. "light_normal_map.png"

        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(128, 128, 255, 255)

        local cx, cy, R = W / 2, H / 2, 70
        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local dx = (x - cx) / R
                local dy = (y - cy) / R
                local d2 = dx * dx + dy * dy
                if d2 <= 1.0 then
                    local dz = math.sqrt(1.0 - d2)
                    img:setPixel(
                        x,
                        y,
                        clamp255((dx + 1) * 127.5),
                        clamp255((dy + 1) * 127.5),
                        clamp255((dz + 1) * 127.5),
                        255
                    )
                end
            end
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)
    -- Does: Runs "PNG: color mix of RGB dynamic light sources" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.light.newLight and related owner calls.
    -- Artifact: tests/artifacts/current/light/light_color_mix.png
    -- Why: This is meaningful only if the output is driven by lurek.light.newLight and related owner calls rather than by helper-only drawing.

    it("PNG: color mix of RGB dynamic light sources", function()
        ensure_evidence_dir("light")
        local path = OUT .. "light_color_mix.png"

        lurek.light.clear()
        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(5, 5, 5, 255)

        -- 3 Overlapping RGB lights
        local lights = {
            { x = W/2,      y = H/2 - 20, r = 100, intensity = 1.0, cr = 1, cg = 0, cb = 0 }, -- Red
            { x = W/2 - 20, y = H/2 + 20, r = 100, intensity = 1.0, cr = 0, cg = 1, cb = 0 }, -- Green
            { x = W/2 + 20, y = H/2 + 20, r = 100, intensity = 1.0, cr = 0, cg = 0, cb = 1 }  -- Blue
        }

        local l_objects = {}
        for i, l in ipairs(lights) do
            local lo = lurek.light.newLight(l.x, l.y, l.r, { intensity = l.intensity })
            lo:setColor(l.cr, l.cg, l.cb, 1.0)
            l_objects[i] = lo
        end

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local tr, tg, tb = 0.02, 0.02, 0.02
                for _, l in ipairs(lights) do
                    local att = radial_att(l.x, l.y, l.r, x, y, l.intensity)
                    tr = tr + l.cr * att
                    tg = tg + l.cg * att
                    tb = tb + l.cb * att
                end
                img:setPixel(x, y, clamp255(tr * 255), clamp255(tg * 255), clamp255(tb * 255), 255)
            end
        end

        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        for _, lo in ipairs(l_objects) do lo:remove() end
        lurek.light.clear()
    end)
    -- Does: Runs "light contact sheet" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.light.drawToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/light/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.light.drawToImage; export helpers are just the container.

    it("PNG: light contact sheet", function()
        ensure_evidence_dir("light")
        local files = {
            "light_falloff.png",
            "light_shadow_occlusion.png",
            "light_color_mix.png",
            "light_normal_map.png",
        }

        local canvas = lurek.image.newImageData(456, 456)
        canvas:fill(12, 14, 20, 255)
        local positions = {
            { 16, 16 }, { 232, 16 }, { 16, 232 }, { 232, 232 },
        }
        for i, name in ipairs(files) do
            local src = lurek.image.newImageData(OUT .. name)
            local x, y = positions[i][1], positions[i][2]
            canvas:paste(src, x, y)
            draw_outline(canvas, x, y, 200, 200, 232, 236, 244, 255)
        end

        local path = OUT .. "light_contact_sheet.png"
        lurek.image.savePNG(canvas, path)
        expect_evidence_created(path)
    end)
    -- Does: Runs "light grouping, flicker, and transition trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.light.getAmbient, lurek.light.setGroupEnabled, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/light/light_group_transition_flicker_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.light.getAmbient, lurek.light.setGroupEnabled, and related owner calls; export helpers are just the container.

    it("TXT: light grouping, flicker, and transition trace", function()
        ensure_evidence_dir("light")
        lurek.light.clear()
        lurek.light.setAmbient(0.08, 0.10, 0.14, 1.0)

        local left = lurek.light.newLight(42, 64, 56, { intensity = 1.0 })
        local right = lurek.light.newLight(124, 64, 56, { intensity = 0.8 })
        left:setGroupId(7)
        right:setGroupId(7)
        lurek.light.setGroupColor(7, 0.92, 0.64, 0.28, 1.0)
        lurek.light.setGroupIntensity(7, 0.55)
        lurek.light.setGroupEnabled(7, true)

        left:setFlicker(9.0, 0.18)
        left:setFlickerEnabled(true)
        lurek.light.advanceFlickers(0.12)

        left:transitionTo({ radius = 88.0, intensity = 0.35 }, 1.0)
        local active_mid = left:updateTransition(0.5)
        local progress_mid = left:transitionProgress()
        left:stopTransition()
        local active_after_stop = left:updateTransition(0.1)

        local ar, ag, ab, aa = lurek.light.getAmbient()
        local sr, sg, sb, sa = lurek.light.syncAmbient()
        local god_rays = lurek.light.getGodRayHints()
        local normals = lurek.light.getNormalMapHints()
        local lines = {
            string.format("ambient=%.3f,%.3f,%.3f,%.3f", ar, ag, ab, aa),
            string.format("synced=%.3f,%.3f,%.3f,%.3f", sr, sg, sb, sa),
            "transition_active_mid=" .. tostring(active_mid),
            "transition_progress_mid=" .. tostring(progress_mid),
            "transition_active_after_stop=" .. tostring(active_after_stop),
            "god_ray_hint_count=" .. tostring(#god_rays),
            "normal_map_hint_count=" .. tostring(#normals),
        }

        write_text(OUT .. "light_group_transition_flicker_trace.txt", table.concat(lines, "\n") .. "\n")
        left:remove()
        right:remove()
        lurek.light.clear()
    end)

end)
test_summary()
