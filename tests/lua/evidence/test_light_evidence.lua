-- test_light_evidence.lua
-- Evidence tests: lurek.light scenarios
-- Canonical evidence file for lurek.light visual outputs.
-- This file intentionally avoids file-level @covers markers; evidence ownership is described per artifact block.


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

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function compose_light_layer(base, layer)
    base:paste(layer, 0, 0)
    return base
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
        lurek.light.setAmbient(0.02, 0.02, 0.03, 1.0)
        local W, H = 200, 200
        local lx, ly = W / 2, H / 2
        local light = lurek.light.newLight(lx, ly, 90, {
            intensity = 0.85,
            falloff = "linear",
            attConstant = 1.0,
            attLinear = 0.0,
            attQuadratic = 0.0,
        })
        light:setColor(1.0, 0.8, 0.4, 1.0)
        local img = lurek.light.drawToImage(W, H)

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
        local lx, ly = W / 2, 10
        local spotlight = lurek.light.newLight(lx, ly, 170, {
            intensity = 1.6,
            falloff = "smooth",
        })
        spotlight:setColor(0.9, 0.95, 1.0, 1.0)
        spotlight:setLightType("spot")
        spotlight:setDirection(math.rad(90))
        spotlight:setInnerAngle(math.rad(12))
        spotlight:setOuterAngle(math.rad(28))

        local img = lurek.light.drawToImage(W, H)
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
        lurek.light.setEnabled(true)
        lurek.light.setAmbient(0.04, 0.04, 0.06, 1.0)

        local W, H = 200, 200
        local lx, ly = W / 2, 20
        local light = lurek.light.newLight(lx, ly, 170, {
            intensity = 1.7,
            falloff = "smooth",
            shadowEnabled = true,
            shadowFilter = "pcf5",
            shadowSmooth = 2.0,
            shadowSoftness = 1.3,
        })
        light:setColor(1.0, 1.0, 0.9, 1.0)

        local wy = 90
        local wx0 = math.floor(W / 3)
        local wx1 = math.floor(2 * W / 3)
        local occ = lurek.light.newOccluder({
            wx0, wy,
            wx1, wy,
            wx1, wy + 8,
            wx0, wy + 8
        })

        local img = lurek.light.drawToImage(W, H)
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

        local img = lurek.light.drawToImage(W, H)
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)

        for _, lo in ipairs(l_objects) do lo:remove() end
        lurek.light.clear()
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

    -- Does: Rebuilds the old single-occluder light showcase as two standalone captures with the light on opposite sides of the same wall.
    -- Shows: The PNG pair should let a reviewer inspect each occluder state without merging both evidences into one file.
    -- Artifact: tests/artifacts/current/light/light_occluder_left.png, tests/artifacts/current/light/light_occluder_right.png
    -- Why: This is meaningful because it preserves the useful proof from the old showcase while keeping each state as its own artifact.
    it("PNG: occluder side captures", function()
        ensure_evidence_dir("light")
        local panel_w, panel_h = 360, 220
        local wall = { x = 170, y = 40, w = 20, h = 140 }
        local positions = {
            { "left", 110, 110 },
            { "right", 250, 110 },
        }

        for _, pos in ipairs(positions) do
            lurek.light.clear()
            lurek.light.setEnabled(true)
            lurek.light.setAmbient(0.06, 0.06, 0.08, 1.0)

            local light = lurek.light.newLight(pos[2], pos[3], 180, {
                intensity = 1.6,
                blend = "add",
                falloff = "smooth",
                shadowEnabled = true,
            })
            light:setColor(1.0, 0.85, 0.5, 1.0)
            light:setAttenuation(1.0, 0.02, 0.003)
            local occ = lurek.light.newOccluder({
                wall.x, wall.y,
                wall.x + wall.w, wall.y,
                wall.x + wall.w, wall.y + wall.h,
                wall.x, wall.y + wall.h,
            })
            local layer = lurek.light.drawToImage(panel_w, panel_h)
            local panel = lurek.image.newImageData(panel_w, panel_h)
            panel:fill(70, 65, 58, 255)
            compose_light_layer(panel, layer)
            panel:drawRect(wall.x, wall.y, wall.w, wall.h, 120, 100, 70, 255)
            panel:drawCircle(pos[2], pos[3], 5, 255, 245, 180, 255)
            local path = OUT .. "light_occluder_" .. pos[1] .. ".png"
            lurek.image.savePNG(panel, path)
            expect_evidence_created(path)
            layer = nil
            panel = nil
            collectgarbage("collect")

            occ:remove()
            light:remove()
            lurek.light.clear()
        end
    end)

    -- Does: Rebuilds the vending-machine lighting scene as one deterministic capture with four colored lights and matching occluders.
    -- Shows: The PNG should let a reviewer inspect colored falloff, local flicker, and machine-body shadow blocking in one artifact.
    -- Artifact: tests/artifacts/current/light/light_vending_machine_occlusion.png
    -- Why: This is meaningful because the artifact preserves the useful scene from the old showcase while moving ownership to the light evidence layer.
    it("PNG: vending machine occlusion scene", function()
        ensure_evidence_dir("light")
        lurek.light.clear()
        lurek.light.setEnabled(true)
        lurek.light.setAmbient(0.02, 0.025, 0.04, 1.0)

        local W, H = 840, 480
        local machines = {
            { x = 120, y = 160, w = 70, h = 140, color = { 0.2, 1.0, 0.9, 1.0 }, radius = 180, intensity = 1.3, screen = { 0.3, 1.0, 0.9 } },
            { x = 280, y = 175, w = 65, h = 130, color = { 0.3, 0.4, 1.0, 1.0 }, radius = 160, intensity = 1.2, screen = { 0.4, 0.5, 1.0 } },
            { x = 440, y = 155, w = 60, h = 145, color = { 0.8, 0.95, 0.1, 1.0 }, radius = 170, intensity = 1.25, screen = { 0.9, 0.95, 0.2 } },
            { x = 620, y = 185, w = 55, h = 110, color = { 0.2, 0.3, 0.9, 1.0 }, radius = 130, intensity = 1.1, screen = { 0.3, 0.4, 1.0 } },
        }

        local lights = {}
        local occluders = {}
        for i, m in ipairs(machines) do
            lights[i] = lurek.light.newLight(m.x + m.w * 0.5, m.y + m.h - 10, m.radius, {
                color = m.color,
                intensity = m.intensity,
                blend = "add",
                falloff = "smooth",
                shadowEnabled = true,
                shadowFilter = "pcf5",
                shadowSmooth = 1.2,
            })
            lights[i]:setAttenuation(1.0, 0.04, 0.008)
            occluders[i] = lurek.light.newOccluder({
                m.x, m.y,
                m.x + m.w, m.y,
                m.x + m.w, m.y + m.h,
                m.x, m.y + m.h,
            }, { opacity = 0.92 })
        end

        lights[1]:setFlicker(3.0, 0.08)
        lights[3]:setFlicker(6.0, 0.12)
        lurek.light.advanceFlickers(0.16)

        local layer = lurek.light.drawToImage(W, H)
        local canvas = lurek.image.newImageData(W, H)
        canvas:fill(8, 10, 14, 255)
        compose_light_layer(canvas, layer)

        for _, m in ipairs(machines) do
            canvas:drawRect(m.x, m.y, m.w, m.h, 16, 18, 26, 255)
            canvas:drawRect(m.x + 6, m.y + 12, m.w - 12, math.floor(m.h * 0.45), m.screen[1] * 102, m.screen[2] * 102, m.screen[3] * 102, 220)
            draw_outline(canvas, m.x, m.y, m.w, m.h, 48, 58, 72, 255)
        end

        lurek.image.savePNG(canvas, OUT .. "light_vending_machine_occlusion.png")
        expect_evidence_created(OUT .. "light_vending_machine_occlusion.png")

        for _, occ in ipairs(occluders) do
            occ:remove()
        end
        for _, light in ipairs(lights) do
            light:remove()
        end
        lurek.light.clear()
    end)

    -- Does: Binds light-target shaders through both world and instance light APIs and emits three light-specific visual artifacts.
    -- Shows: World light contribution, instance cone/ray contribution, and rim/falloff contribution are represented as distinct light scenes.
    -- Artifact: tests/artifacts/current/light/light_shader_visual_01_world_light.png, tests/artifacts/current/light/light_shader_visual_02_instance_light.png, tests/artifacts/current/light/light_shader_visual_03_rim_falloff.png
    -- Why: Light shaders modify light contribution while shadow geometry stays engine-owned, so evidence should show falloff and contribution shapes.
    it("PNG: shader-backed light contribution variants", function()
        dofile("tests/lua/fixtures/shader_visual_helpers.lua")
        local ShaderEvidence = _G.ShaderEvidence
        ShaderEvidence.emit("light", {
            { target = "light", slug = "world_light" },
            { target = "light", slug = "instance_light" },
            { target = "light", slug = "rim_falloff" },
        }, OUT)
    end)

end)
test_summary()
