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
    if x < 2 or y < 2 or x > 317 or y > 237 then
        return
    end
    for dy = -2, 2 do
        img:setPixel(x, y + dy, r, g, b, 255)
    end
    for dx = -2, 2 do
        img:setPixel(x + dx, y, r, g, b, 255)
    end
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

        local probes = {{160,120},{200,120},{160,160},{64,64}}
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

        local img = lurek.image.newImageData(320, 240)
        img:fill(12, 14, 18, 255)

        local vx, vy, vw, vh = cam:getVisibleArea()
        local tlx, tly = cam:toScreen(vx, vy)
        local brx, bry = cam:toScreen(vx + vw, vy + vh)
        img:drawRect(
            math.floor(math.min(tlx, brx)),
            math.floor(math.min(tly, bry)),
            math.floor(math.abs(brx - tlx)),
            math.floor(math.abs(bry - tly)),
            80,
            150,
            255,
            255
        )

        for wy = 40, 200, 20 do
            for wx = 40, 280, 20 do
                local sx, sy = cam:toScreen(wx, wy)
                draw_marker(img, math.floor(sx), math.floor(sy), 240, 220, 90)
            end
        end

        local path = OUT .. "camera_visible_area_transform_grid.png"
        save_png(img, path)
    end)

    -- @evidence LCamera:followPath
    -- @evidence LCamera:updatePath
    -- @evidence LCamera:pathProgress
    -- @evidence lurek.image.savePNG
    it("PNG: camera path-follow trace", function()
        local cam = lurek.camera.newCamera()
        cam:setViewport(0, 0, 320, 240)
        cam:setPosition(40, 40)
        cam:followPath({
            { 40, 40 },
            { 240, 40 },
            { 240, 180 },
            { 80, 180 },
        }, 2.4)

        local img = lurek.image.newImageData(320, 240)
        img:fill(14, 16, 20, 255)
        img:drawRect(38, 38, 204, 144, 80, 90, 110, 255)

        local prev_x, prev_y = nil, nil
        for i = 1, 60 do
            expect_true(cam:updatePath(2.4 / 60))
            local cx, cy = cam:getPosition()
            local px = math.floor(cx + 0.5)
            local py = math.floor(cy + 0.5)
            if prev_x then
                img:drawLine(prev_x, prev_y, px, py, 100, 240, 160, 255)
            end
            draw_marker(img, px, py, 255, 200, 90)
            prev_x, prev_y = px, py
        end

        expect_true(cam:pathProgress() > 0.9)
        local path = OUT .. "camera_follow_path_trace.png"
        save_png(img, path)
    end)
end)
test_summary()
