-- Canonical evidence file for lurek.camera data and visual outputs.

local OUT = evidence_output_dir("camera")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function draw_marker(img, x, y, r, g, b)
    for dy = -2, 2 do
        img:setPixel(x, y + dy, r, g, b, 255)
    end
    for dx = -2, 2 do
        img:setPixel(x + dx, y, r, g, b, 255)
    end
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

-- @describe evidence: camera
describe("evidence: camera", function()
    before_each(function()
        ensure_evidence_dir("camera")
    end)

    -- @evidence lurek.camera.newCamera
    it("exports zoom/rotation transform samples", function()
        local path = OUT .. "camera_transform_samples.json"

        local cam = lurek.camera.newCamera()
        cam:setViewport(0, 0, 320, 240)
        cam:setPosition(160, 120)
        cam:setZoom(1.75)
        cam:setRotation(math.pi / 6)

        local probes = { { 160, 120 }, { 200, 120 }, { 160, 160 }, { 64, 64 } }
        local out = {}
        for i, p in ipairs(probes) do
            local sx, sy = cam:toScreen(p[1], p[2])
            out[i] = string.format('{"wx":%.2f,"wy":%.2f,"sx":%.2f,"sy":%.2f}', p[1], p[2], tonumber(sx) or 0, tonumber(sy) or 0)
        end
        write_text(path, "[" .. table.concat(out, ",") .. "]")
    end)

    -- @evidence lurek.camera.newCamera
    it("exports follow smoothing trace", function()
        local path = OUT .. "camera_follow_smoothing_trace.json"

        local cam = lurek.camera.newCamera()
        cam:setViewport(0, 0, 320, 240)
        cam:setPosition(0, 0)
        cam:setFollowSmooth(5.0)

        local dt = 1 / 60
        local out = {}
        for i = 1, 90 do
            local tx = i * 2
            local ty = 100 + math.sin(i * 0.1) * 20
            cam:setTarget(tx, ty)
            cam:update(dt)
            local cx, cy = cam:getPosition()
            out[i] = string.format('{"frame":%d,"tx":%.3f,"ty":%.3f,"cx":%.3f,"cy":%.3f}', i, tx, ty, tonumber(cx) or 0, tonumber(cy) or 0)
        end
        write_text(path, "[" .. table.concat(out, ",") .. "]")
    end)

    -- @evidence lurek.camera.newCamera
    it("exports shake response trace", function()
        local path = OUT .. "camera_shake_response_trace.json"

        local cam = lurek.camera.newCamera()
        cam:setViewport(0, 0, 320, 240)
        cam:setPosition(160, 120)
        cam:shake(20, 0.5)

        local dt = 1 / 60
        local out = {}
        for i = 1, 60 do
            cam:update(dt)
            local x, y = cam:getPosition()
            out[i] = string.format('{"frame":%d,"x":%.3f,"y":%.3f}', i, tonumber(x) or 0, tonumber(y) or 0)
        end
        write_text(path, "[" .. table.concat(out, ",") .. "]")
    end)

    -- @evidence LCamera:toScreen
    -- @evidence LCamera:getVisibleArea
    -- @evidence lurek.image.savePNG
    it("PNG: camera transform grid and visible area", function()
        local cam = lurek.camera.newCamera()
        cam:setViewport(0, 0, 320, 240)
        cam:setPosition(160, 120)
        cam:setZoom(1.35)
        cam:setRotation(math.pi / 10)

        local img = lurek.image.newImageData(520, 280)
        img:fill(12, 14, 20, 255)
        img:drawRect(20, 20, 220, 220, 22, 26, 34, 255)
        img:drawRect(280, 20, 220, 220, 22, 26, 34, 255)
        draw_outline(img, 20, 20, 220, 220, 232, 236, 244, 255)
        draw_outline(img, 280, 20, 220, 220, 232, 236, 244, 255)

        for gx = 0, 10 do
            local x = 28 + gx * 20
            img:drawLine(x, 28, x, 232, 34, 40, 54, 255)
            img:drawLine(288 + gx * 20, 28, 288 + gx * 20, 232, 34, 40, 54, 255)
        end
        for gy = 0, 10 do
            local y = 28 + gy * 20
            img:drawLine(28, y, 232, y, 34, 40, 54, 255)
            img:drawLine(288, y, 492, y, 34, 40, 54, 255)
        end

        local function world_to_panel(wx, wy)
            return 28 + math.floor((wx / 320) * 204 + 0.5), 28 + math.floor((wy / 240) * 204 + 0.5)
        end

        local vx, vy, vw, vh = cam:getVisibleArea()
        local wvx, wvy = world_to_panel(vx, vy)
        local wbrx, wbry = world_to_panel(vx + vw, vy + vh)
        draw_outline(img, wvx, wvy, math.max(1, wbrx - wvx), math.max(1, wbry - wvy), 84, 170, 255, 255)

        for wy = 40, 200, 20 do
            for wx = 40, 280, 20 do
                local sx, sy = cam:toScreen(wx, wy)
                local px, py = world_to_panel(wx, wy)
                local spx = 288 + math.floor((sx / 320) * 204 + 0.5)
                local spy = 28 + math.floor((sy / 240) * 204 + 0.5)
                draw_marker(img, px, py, 110, 214, 154)
                draw_marker(img, spx, spy, 240, 220, 90)
            end
        end

        save_png(img, OUT .. "camera_visible_area_transform_grid.png")
    end)

    -- @evidence LCamera:followPath
    -- @evidence LCamera:updatePath
    -- @evidence LCamera:pathProgress
    -- @evidence lurek.image.savePNG
    it("PNG: camera path-follow trace", function()
        local cam = lurek.camera.newCamera()
        cam:setViewport(0, 0, 320, 240)
        cam:setPosition(40, 40)
        local route = {
            { 40, 40 },
            { 240, 40 },
            { 240, 180 },
            { 80, 180 },
        }
        cam:followPath(route, 2.4)

        local img = lurek.image.newImageData(360, 260)
        img:fill(14, 16, 20, 255)
        img:drawRect(30, 28, 250, 170, 34, 38, 48, 255)
        draw_outline(img, 30, 28, 250, 170, 232, 236, 244, 255)

        for i = 1, #route - 1 do
            local a = route[i]
            local b = route[i + 1]
            img:drawLine(30 + a[1], 28 + a[2], 30 + b[1], 28 + b[2], 70, 78, 92, 255)
        end

        local prev_x, prev_y = nil, nil
        for _ = 1, 60 do
            expect_true(cam:updatePath(2.4 / 60))
            local cx, cy = cam:getPosition()
            local px = 30 + math.floor(cx + 0.5)
            local py = 28 + math.floor(cy + 0.5)
            if prev_x then
                img:drawLine(prev_x, prev_y, px, py, 100, 240, 160, 255)
            end
            draw_marker(img, px, py, 255, 200, 90)
            prev_x, prev_y = px, py
        end

        expect_true(cam:pathProgress() > 0.9)
        save_png(img, OUT .. "camera_follow_path_trace.png")
    end)

    -- @evidence LCamera:toScreen
    -- @evidence LCamera:getVisibleArea
    -- @evidence LCamera:followPath
    -- @evidence LCamera:updatePath
    -- @evidence LCamera:pathProgress
    -- @evidence lurek.image.savePNG
    it("PNG: camera contact sheet", function()
        local grid = lurek.image.newImageData(OUT .. "camera_visible_area_transform_grid.png")
        local path_trace = lurek.image.newImageData(OUT .. "camera_follow_path_trace.png")
        local canvas = lurek.image.newImageData(540, 304)
        canvas:fill(12, 14, 20, 255)
        local positions = {
            { 16, 16, grid:resize(248, 134, "bilinear"), 248, 134 },
            { 276, 16, path_trace:resize(248, 178, "bilinear"), 248, 178 },
            { 16, 156, path_trace:resize(248, 132, "bilinear"), 248, 132 },
            { 276, 206, grid:resize(248, 82, "bilinear"), 248, 82 },
        }
        for _, item in ipairs(positions) do
            canvas:paste(item[3], item[1], item[2])
            draw_outline(canvas, item[1], item[2], item[4], item[5], 232, 236, 244, 255)
        end
        save_png(canvas, OUT .. "camera_contact_sheet.png")
    end)

    -- @evidence LCamera:setBounds
    -- @evidence LCamera:getBounds
    -- @evidence LCamera:hasBounds
    -- @evidence LCamera:setTarget
    -- @evidence LCamera:getTarget
    -- @evidence LCamera:clearTarget
    -- @evidence LCamera:setDeadZone
    -- @evidence LCamera:getDeadZone
    -- @evidence LCamera:setLookAhead
    -- @evidence LCamera:getLookAhead
    -- @evidence LCamera:zoomPulse
    -- @evidence LCamera:updateZoom
    -- @evidence LCamera:startSway
    -- @evidence LCamera:stopSway
    -- @evidence LCamera:isSway
    -- @evidence LCamera:startBreathing
    -- @evidence LCamera:stopBreathing
    -- @evidence LCamera:isBreathing
    -- @evidence LCamera:getEffectiveZoom
    -- @evidence LCamera:getEffectOffset
    it("TXT: camera follow effects and bounds trace", function()
        local cam = lurek.camera.newCamera()
        cam:setViewport(0, 0, 320, 240)
        cam:setBounds(10, 20, 420, 260)
        cam:setTarget(140, 88)
        cam:setDeadZone(52, 36)
        cam:setLookAhead(14, -6)

        local has_bounds, bx, by, bw, bh = cam:getBounds()
        local has_target, tx, ty = cam:getTarget()
        local has_deadzone, dw, dh = cam:getDeadZone()
        expect_true(has_bounds)
        expect_true(has_target)
        expect_true(has_deadzone)

        cam:zoomPulse(1.25, 0.8)
        local zoom_active = cam:updateZoom(0.4)
        cam:startSway(2.5, 0.5, 3.0, 0.0)
        cam:startBreathing(0.08, 0.4)
        cam:update(0.16)
        local eff_zoom = cam:getEffectiveZoom()
        local ox, oy = cam:getEffectOffset()
        cam:stopSway()
        cam:stopBreathing()
        cam:clearTarget()

        local lines = {
            string.format("bounds=%s,%.2f,%.2f,%.2f,%.2f", tostring(has_bounds), bx, by, bw, bh),
            string.format("target=%s,%.2f,%.2f", tostring(has_target), tx, ty),
            string.format("deadzone=%s,%.2f,%.2f", tostring(has_deadzone), dw, dh),
            string.format("look_ahead=%.2f", cam:getLookAhead()),
            "zoom_active_mid=" .. tostring(zoom_active),
            string.format("effective_zoom=%.4f", eff_zoom),
            string.format("effect_offset=%.4f,%.4f", ox, oy),
            "sway_active=" .. tostring(cam:isSway()),
            "breathing_active=" .. tostring(cam:isBreathing()),
            "target_cleared=" .. tostring(select(1, cam:getTarget()) == false),
        }
        write_text(OUT .. "camera_follow_effects_bounds_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
