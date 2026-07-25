-- Canonical evidence file for lurek.color artifacts.
-- @covers lurek.color.additive
-- @covers lurek.color.alphaBlend
-- @covers lurek.color.brightness
-- @covers lurek.color.fromHex
-- @covers lurek.color.fromHsl
-- @covers lurek.color.fromHsv
-- @covers lurek.color.fromU8
-- @covers lurek.color.gammaToLinear
-- @covers lurek.color.invert
-- @covers lurek.color.linearToGamma
-- @covers lurek.color.multiply
-- @covers lurek.color.overlay
-- @covers lurek.color.screen
-- @covers lurek.color.toHex
-- @covers lurek.color.toHsl
-- @covers lurek.color.withAlpha
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG



local OUT = evidence_output_dir("color")

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

local function clamp255(v)
    if v < 0 then
        return 0
    end
    if v > 255 then
        return 255
    end
    return math.floor(v)
end

local function draw_swatch(img, x, y, w, h, rgba)
    img:drawRect(
        x,
        y,
        w,
        h,
        clamp255(rgba[1] * 255),
        clamp255(rgba[2] * 255),
        clamp255(rgba[3] * 255),
        clamp255((rgba[4] or 1.0) * 255)
    )
end

-- @describe Evidence: lurek.color conversions and blends
describe("Evidence: lurek.color conversions and blends", function()
    before_each(function()
        ensure_evidence_dir("color")
    end)

    -- Does: Samples the full HSL hue wheel and paints the returned RGB colors into one inspectable gradient band.
    -- Shows: The PNG should make hue progression continuous and easy to review without reading raw numeric tuples.
    -- Artifact: tests/artifacts/current/color/color_hsl_hue_band.png
    -- Why: This is meaningful because every visible pixel comes from lurek.color.fromHsl outputs.

    it("PNG: HSL hue band", function()
        local w, h = 360, 96
        local img = lurek.image.newImageData(w, h)
        for x = 0, w - 1 do
            local color = lurek.color.fromHsl(x, 0.78, 0.52)
            draw_swatch(img, x, 0, 1, h, color)
        end
        save_png(img, OUT .. "color_hsl_hue_band.png")
    end)

    -- Does: Builds standalone swatch artifacts from public blend helpers and pairs them with a numeric conversion trace.
    -- Shows: Each PNG should expose one blend-family result instead of collapsing several blend evidences into one matrix, while the TXT file records exact conversion and roundtrip values.
    -- Artifact: tests/artifacts/current/color/color_base_a.png, tests/artifacts/current/color/color_base_b.png, tests/artifacts/current/color/color_blend_additive.png, tests/artifacts/current/color/color_blend_alpha_blend.png, tests/artifacts/current/color/color_blend_invert_a.png, tests/artifacts/current/color/color_blend_multiply.png, tests/artifacts/current/color/color_blend_overlay.png, tests/artifacts/current/color/color_blend_screen.png, tests/artifacts/current/color/color_conversion_trace.txt
    -- Why: This is meaningful because all artifacts are computed from lurek.color math and conversion APIs instead of hard-coded expected colors.

    it("PNG+TXT: blend matrix and conversion trace", function()
        local a = { 0.92, 0.35, 0.30, 1.0 }
        local b = { 0.24, 0.62, 0.92, 0.8 }
        local variants = {
            { "multiply", lurek.color.multiply(a, b) },
            { "screen", lurek.color.screen(a, b) },
            { "overlay", lurek.color.overlay(a, b) },
            { "additive", lurek.color.additive(a, b) },
            { "alpha_blend", lurek.color.alphaBlend(a, b) },
            { "invert_a", lurek.color.invert(a[1], a[2], a[3], a[4]) },
        }

        local function swatch_image(name, rgba)
            local img = lurek.image.newImageData(120, 120)
            img:fill(18, 20, 28, 255)
            draw_swatch(img, 20, 20, 80, 80, rgba)
            save_png(img, OUT .. name)
        end

        swatch_image("color_base_a.png", a)
        swatch_image("color_base_b.png", b)
        for i, entry in ipairs(variants) do
            swatch_image("color_blend_" .. entry[1] .. ".png", entry[2])
        end

        local from_hex = lurek.color.fromHex("#3366CCFF")
        local from_hsv = lurek.color.fromHsv(210, 0.75, 0.80)
        local from_u8 = lurek.color.fromU8(12, 180, 220, 200)
        local h, s, l = lurek.color.toHsl(from_hex[1], from_hex[2], from_hex[3], from_hex[4])
        local hex = lurek.color.toHex(from_hsv[1], from_hsv[2], from_hsv[3], from_hsv[4] or 1.0)
        local boosted = lurek.color.withAlpha(a[1], a[2], a[3], a[4], 0.45)
        local lines = {
            string.format("from_hex=%.4f,%.4f,%.4f,%.4f", from_hex[1], from_hex[2], from_hex[3], from_hex[4] or 1.0),
            string.format("to_hsl=%.4f,%.4f,%.4f", h or 0.0, s or 0.0, l or 0.0),
            "to_hex=" .. tostring(hex),
            string.format("from_hsv=%.4f,%.4f,%.4f", from_hsv[1], from_hsv[2], from_hsv[3]),
            string.format("from_u8=%.4f,%.4f,%.4f,%.4f", from_u8[1], from_u8[2], from_u8[3], from_u8[4] or 1.0),
            string.format("with_alpha=%.4f", boosted[4] or 0.0),
            string.format("gamma_linear=%.6f", lurek.color.gammaToLinear(0.5)),
            string.format("linear_gamma=%.6f", lurek.color.linearToGamma(0.5)),
            string.format("brightness=%.6f", lurek.color.brightness(a[1], a[2], a[3])),
        }
        write_text(OUT .. "color_conversion_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)

test_summary()
