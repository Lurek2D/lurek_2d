-- Evidence tests: effect module
-- Output-only evidence from direct lurek.effect APIs.


local function write_text(path, text)
    local f = io and io.open and io.open(path, "w") or nil
    if f then
        f:write(text)
        f:close()
    end
end

-- @describe evidence: effect
describe("evidence: effect", function()
    before_each(function()
        ensure_evidence_dir("effect")
    end)

    -- @evidence file
    it("exports overlay flash/fade/lightning state timeline", function()
        local dir = evidence_output_dir("effect")
        local path = dir .. "overlay_timeline.json"

        local ov = lurek.effect.newOverlay(256, 128)
        ov:triggerFlash(1.0, 0.2, 0.0, 0.9, 0.5)
        ov:triggerFade(0.0, 0.0, 0.0, 0.7, 0.8)
        ov:triggerLightning()

        local dt = 1 / 30
        local out = {}
        for i = 1, 24 do
            local fa = ov:getFlashAlpha()
            local la = ov:getLightningAlpha()
            ov:update(dt)
            out[i] = string.format('{"frame":%d,"flash":%.5f,"lightning":%.5f}', i, tonumber(fa) or 0, tonumber(la) or 0)
        end
        write_text(path, "[" .. table.concat(out, ",") .. "]")
    end)

    -- @evidence file
    it("exports overlay drawToImage metadata", function()
        local dir = evidence_output_dir("effect")
        local path = dir .. "overlay_draw_to_image.json"

        local ov = lurek.effect.newOverlay(256, 128)
        ov:triggerFlash(0.3, 0.7, 1.0, 0.8, 0.6)
        ov:update(0.1)
        local img = ov:drawToImage(256, 128)
        local json = string.format('{"lua_type":"%s","engine_type":"%s"}', type(img), tostring(img and img:type() or "nil"))
        write_text(path, json)
    end)

    -- @evidence file
    it("exports image postfx strip PNG", function()
        local dir = evidence_output_dir("effect")
        local path = dir .. "image_postfx_strip.png"

        local base = lurek.image.newImageData(64, 64)
        for y = 0, 63 do
            for x = 0, 63 do
                base:setPixel(x, y, x * 4, y * 4, ((x + y) % 64) * 4, 255)
            end
        end

        local strip = lurek.image.newImageData(64 * 4, 64)
        local variants = {
            function(i) end,
            function(i) i:grayscale() end,
            function(i) i:sepia() end,
            function(i) i:invert() end,
        }

        for idx, fn in ipairs(variants) do
            local img = lurek.image.newImageData(64, 64)
            for y = 0, 63 do
                for x = 0, 63 do
                    local r, g, b, a = base:getPixel(x, y)
                    img:setPixel(x, y, r, g, b, a)
                end
            end
            fn(img)
            for y = 0, 63 do
                for x = 0, 63 do
                    local r, g, b, a = img:getPixel(x, y)
                    strip:setPixel((idx - 1) * 64 + x, y, r, g, b, a)
                end
            end
        end

        lurek.image.savePNG(strip, path)
    end)
end)

test_summary()
