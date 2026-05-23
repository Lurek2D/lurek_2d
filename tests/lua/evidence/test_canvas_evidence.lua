-- Evidence tests: canvas module
-- Output-only evidence from direct lurek.render canvas APIs.

local function write_text(path, text)
    local f = io and io.open and io.open(path, "w") or nil
    if f then
        f:write(text)
        f:close()
    end
end

describe("evidence: canvas", function()
    before_each(function()
        ensure_evidence_dir("canvas")
    end)

    -- @evidence file
    it("exports canvas API surface", function()
        local dir = evidence_output_dir("canvas")
        local path = dir .. "canvas_api_surface.json"
        local g = lurek.render or {}
        local json = string.format(
            '{"newCanvas":%s,"setCanvas":%s,"resetCanvas":%s}',
            type(g.newCanvas) == "function" and "true" or "false",
            type(g.setCanvas) == "function" and "true" or "false",
            type((rawget(g --[[@as table]], "resetCanvas"))) == "function" and "true" or "false"
        )
        write_text(path, json)
    end)

    -- @evidence file
    it("exports canvas dimensions", function()
        local dir = evidence_output_dir("canvas")
        local path = dir .. "canvas_dimensions.json"

        local json = '{"created":false,"reason":"canvas unavailable"}'
        local ok, c = pcall(function() return lurek.render.newCanvas(320, 240) end)
        if ok and c then
            local w = c:getWidth()
            local h = c:getHeight()
            local w2, h2 = c:getDimensions()
            c:release()
            json = string.format('{"created":true,"w":%d,"h":%d,"w2":%d,"h2":%d}', w or 0, h or 0, w2 or 0, h2 or 0)
        end
        write_text(path, json)
    end)

    -- @evidence file
    it("exports set/reset canvas call evidence", function()
        local dir = evidence_output_dir("canvas")
        local path = dir .. "canvas_set_reset.json"

        local ok, c = pcall(function() return lurek.render.newCanvas(128, 128) end)
        local reset_canvas = rawget(lurek.render --[[@as table]], "resetCanvas")
        local did_set, did_reset = false, false

        if ok and c then
            lurek.render.setCanvas(c)
            did_set = true
            if type(reset_canvas) == "function" then
                pcall(function() reset_canvas(c) end)
                did_reset = true
            end
            c:release()
        end

        local json = string.format('{"created":%s,"set":%s,"reset":%s}', ok and "true" or "false", did_set and "true" or "false", did_reset and "true" or "false")
        write_text(path, json)
    end)
end)

test_summary()
