-- Evidence tests: camera module
-- Output-only evidence from direct lurek.camera API calls.

local function write_text(path, text)
    local f = io and io.open and io.open(path, "w") or nil
    if f then
        f:write(text)
        f:close()
    end
end

describe("evidence: camera", function()
    before_each(function()
        ensure_evidence_dir("camera")
    end)

    -- @evidence file
    it("exports zoom/rotation transform samples", function()
        local dir = evidence_output_dir("camera")
        local path = dir .. "transforms.json"

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

    -- @evidence file
    it("exports follow smoothing trace", function()
        local dir = evidence_output_dir("camera")
        local path = dir .. "follow_trace.json"

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

    -- @evidence file
    it("exports shake response trace", function()
        local dir = evidence_output_dir("camera")
        local path = dir .. "shake_trace.json"

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
end)

test_summary()
