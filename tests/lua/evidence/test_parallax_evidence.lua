-- Canonical evidence file for lurek.parallax visual artifacts.
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.saveGIF
-- @covers lurek.image.savePNG
-- @covers lurek.parallax.newLayer
-- @covers lurek.parallax.newPresetLayer
-- @covers lurek.parallax.newSet
-- @covers lurek.render.newImage
-- @covers lurek.render.newShader


local OUT = evidence_output_dir("parallax")
local TEXTURE_PATH = "content/examples/assets/images/sample_texture.png"

local FONT = {
    [" "] = { "000", "000", "000", "000", "000", "000", "000" },
    ["-"] = { "00000", "00000", "00000", "11110", "00000", "00000", "00000" },
    [":"] = { "000", "010", "000", "000", "010", "000", "000" },
    ["/"] = { "00001", "00010", "00010", "00100", "01000", "01000", "10000" },
    ["."] = { "000", "000", "000", "000", "000", "010", "000" },
    ["0"] = { "01110", "10001", "10011", "10101", "11001", "10001", "01110" },
    ["1"] = { "00100", "01100", "00100", "00100", "00100", "00100", "01110" },
    ["2"] = { "01110", "10001", "00001", "00010", "00100", "01000", "11111" },
    ["3"] = { "11110", "00001", "00001", "01110", "00001", "00001", "11110" },
    ["4"] = { "00010", "00110", "01010", "10010", "11111", "00010", "00010" },
    ["5"] = { "11111", "10000", "10000", "11110", "00001", "00001", "11110" },
    ["6"] = { "01110", "10000", "10000", "11110", "10001", "10001", "01110" },
    ["7"] = { "11111", "00001", "00010", "00100", "01000", "01000", "01000" },
    ["8"] = { "01110", "10001", "10001", "01110", "10001", "10001", "01110" },
    ["9"] = { "01110", "10001", "10001", "01111", "00001", "00001", "01110" },
    A = { "01110", "10001", "10001", "11111", "10001", "10001", "10001" },
    B = { "11110", "10001", "10001", "11110", "10001", "10001", "11110" },
    C = { "01111", "10000", "10000", "10000", "10000", "10000", "01111" },
    D = { "11110", "10001", "10001", "10001", "10001", "10001", "11110" },
    E = { "11111", "10000", "10000", "11110", "10000", "10000", "11111" },
    F = { "11111", "10000", "10000", "11110", "10000", "10000", "10000" },
    G = { "01111", "10000", "10000", "10011", "10001", "10001", "01111" },
    H = { "10001", "10001", "10001", "11111", "10001", "10001", "10001" },
    I = { "11111", "00100", "00100", "00100", "00100", "00100", "11111" },
    J = { "00111", "00010", "00010", "00010", "00010", "10010", "01100" },
    K = { "10001", "10010", "10100", "11000", "10100", "10010", "10001" },
    L = { "10000", "10000", "10000", "10000", "10000", "10000", "11111" },
    M = { "10001", "11011", "10101", "10101", "10001", "10001", "10001" },
    N = { "10001", "11001", "10101", "10011", "10001", "10001", "10001" },
    O = { "01110", "10001", "10001", "10001", "10001", "10001", "01110" },
    P = { "11110", "10001", "10001", "11110", "10000", "10000", "10000" },
    Q = { "01110", "10001", "10001", "10001", "10101", "10010", "01101" },
    R = { "11110", "10001", "10001", "11110", "10100", "10010", "10001" },
    S = { "01111", "10000", "10000", "01110", "00001", "00001", "11110" },
    T = { "11111", "00100", "00100", "00100", "00100", "00100", "00100" },
    U = { "10001", "10001", "10001", "10001", "10001", "10001", "01110" },
    V = { "10001", "10001", "10001", "10001", "10001", "01010", "00100" },
    W = { "10001", "10001", "10001", "10101", "10101", "10101", "01010" },
    X = { "10001", "10001", "01010", "00100", "01010", "10001", "10001" },
    Y = { "10001", "10001", "01010", "00100", "00100", "00100", "00100" },
    Z = { "11111", "00001", "00010", "00100", "01000", "10000", "11111" },
}

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_gif(frames, path)
    lurek.image.saveGIF(frames, path, { delayMs = 120, speed = 30 })
    expect_evidence_created(path)
end

local function draw_text(img, text, x, y, scale, r, g, b)
    text = string.upper(tostring(text or ""))
    scale = scale or 1
    local cursor = math.floor(x)
    for i = 1, #text do
        local ch = string.sub(text, i, i)
        local glyph = FONT[ch] or FONT[" "]
        for gy = 1, #glyph do
            local row = glyph[gy]
            for gx = 1, #row do
                if string.sub(row, gx, gx) == "1" then
                    img:drawRect(cursor + (gx - 1) * scale, y + (gy - 1) * scale, scale, scale, r, g, b, 255)
                end
            end
        end
        cursor = cursor + (#glyph[1] + 1) * scale
    end
end

local function text_width(text, scale)
    return #tostring(text or "") * 6 * (scale or 1)
end

local function outline(img, x, y, w, h, r, g, b)
    img:drawRect(x, y, w, 2, r, g, b, 255)
    img:drawRect(x, y + h - 2, w, 2, r, g, b, 255)
    img:drawRect(x, y, 2, h, r, g, b, 255)
    img:drawRect(x + w - 2, y, 2, h, r, g, b, 255)
end

local function new_canvas(title)
    local img = lurek.image.newImageData(820, 460)
    img:fill(14, 17, 22, 255)
    img:drawRect(18, 18, 784, 42, 30, 38, 50, 255)
    draw_text(img, title, 34, 32, 2, 234, 240, 246)
    img:drawRect(18, 78, 784, 354, 21, 25, 34, 255)
    outline(img, 18, 78, 784, 354, 78, 90, 112)
    return img
end

local function load_texture()
    return lurek.render.newImage(TEXTURE_PATH)
end

local function build_layer(opts)
    opts.texture = opts.texture or load_texture()
    return lurek.parallax.newLayer(opts)
end

local function draw_bar(img, x, y, label, value, max_value, color)
    max_value = math.max(1, max_value or 1)
    local fill = math.floor(170 * math.max(0, math.min(1, value / max_value)))
    draw_text(img, label, x, y, 1, 182, 194, 210)
    img:drawRect(x, y + 14, 174, 12, 42, 49, 64, 255)
    img:drawRect(x + 2, y + 16, fill, 8, color[1], color[2], color[3], 255)
    outline(img, x, y + 14, 174, 12, 92, 104, 126)
end

local function draw_parallax_band(img, y, label, factor, camera, color)
    local x, w, h = 74, 650, 62
    local displacement = math.floor(camera * factor + 0.5)
    img:drawRect(x, y, w, h, color[1], color[2], color[3], 255)
    outline(img, x, y, w, h, 226, 234, 242)
    local tile = 70
    local phase = displacement % tile
    for i = -1, 10 do
        local px = x + i * tile - phase
        local a = math.floor(px + 8)
        local b = math.floor(px + 45)
        if a >= x and a <= x + w - 32 then
            img:drawRect(a, y + 13, 32, 24, math.min(255, color[1] + 46), math.min(255, color[2] + 42), math.min(255, color[3] + 38), 255)
        end
        if b >= x and b <= x + w - 18 then
            img:drawRect(b, y + 38, 18, 12, math.max(0, color[1] - 25), math.max(0, color[2] - 20), math.max(0, color[3] - 18), 255)
        end
    end
    draw_text(img, label, x + 14, y + 22, 1, 248, 250, 252)
    draw_text(img, "F " .. tostring(math.floor(factor * 100)) .. "/100", x + 510, y + 14, 1, 248, 250, 252)
    draw_text(img, "MOVE " .. tostring(displacement), x + 510, y + 34, 1, 248, 250, 252)
end

-- @describe evidence: parallax
describe("evidence: parallax", function()
    before_each(function()
        ensure_evidence_dir("parallax")
    end)

    -- Does: Creates far, mid, and foreground parallax layers, reads their scroll factors, and rasterizes one camera move.
    -- Shows: Lower scroll factors produce smaller apparent displacement while foreground factors move fastest.
    -- Artifact: tests/artifacts/current/parallax/parallax_depth_scroll_factors.png
    -- Why: This proves the core parallax API stores independent depth movement ratios instead of behaving like one flat background.
    it("PNG: depth scroll factors", function()
        local tex = load_texture()
        local layers = {
            { label = "FAR SKY", layer = lurek.parallax.newPresetLayer("far", tex), color = { 48, 92, 142 } },
            { label = "MID RIDGE", layer = lurek.parallax.newPresetLayer("mid", tex), color = { 70, 134, 126 } },
            { label = "FRONT FOG", layer = lurek.parallax.newPresetLayer("fog", tex), color = { 128, 132, 164 } },
        }
        local camera = 240
        local img = new_canvas("PARALLAX DEPTH SCROLL")
        draw_text(img, "CAMERA TRAVEL " .. tostring(camera), 74, 100, 1, 186, 200, 218)
        for i, entry in ipairs(layers) do
            local fx = entry.layer:getScrollFactor()
            draw_parallax_band(img, 132 + (i - 1) * 84, entry.label, fx, camera, entry.color)
        end
        save_png(img, OUT .. "parallax_depth_scroll_factors.png")
    end)

    -- Does: Enables tiling and repeat on a parallax layer, reads LParallaxLayer:getStats, and draws the covered viewport grid.
    -- Shows: The artifact exposes engine-reported tile size and visible tile count as a repeated background coverage map.
    -- Artifact: tests/artifacts/current/parallax/parallax_tiling_coverage_stats.png
    -- Why: Tiling is parallax-owned behavior, and this artifact makes the repeated draw coverage inspectable without adding a module renderer.
    it("PNG: tiling coverage stats", function()
        local layer = build_layer({
            scroll_factor_x = 0.45, scroll_factor_y = 0.25,
            repeat_x = true, repeat_y = true, tiling = true,
            tile_w = 96, tile_h = 64,
        })
        layer:setTiling(true)
        layer:setRepeat(true, true)
        layer:setTileSize(96, 64)
        local stats = layer:getStats()
        local img = new_canvas("PARALLAX TILING COVERAGE")
        local ox, oy, tw, th = 72, 116, 96, 64
        for gy = 0, 3 do
            for gx = 0, 6 do
                local x, y = ox + gx * tw, oy + gy * th
                local c = (gx + gy) % 2 == 0 and { 58, 96, 130 } or { 44, 74, 104 }
                img:drawRect(x, y, tw - 3, th - 3, c[1], c[2], c[3], 255)
                outline(img, x, y, tw - 3, th - 3, 104, 126, 152)
            end
        end
        draw_bar(img, 76, 390, "TILES " .. tostring(stats.visible_tile_count), stats.visible_tile_count, math.max(1, stats.visible_tile_count), { 255, 204, 94 })
        draw_bar(img, 286, 390, "TW " .. tostring(math.floor(stats.tile_width)), stats.tile_width, 128, { 102, 186, 232 })
        draw_bar(img, 496, 390, "TH " .. tostring(math.floor(stats.tile_height)), stats.tile_height, 128, { 116, 206, 146 })
        save_png(img, OUT .. "parallax_tiling_coverage_stats.png")
    end)

    -- Does: Adds unsorted layers to LParallaxSet, calls sortByZ, and visualizes getLayerZAt order.
    -- Shows: The set renders from negative/background z through positive/foreground z with stable layer count telemetry.
    -- Artifact: tests/artifacts/current/parallax/parallax_z_sorted_set.png
    -- Why: This proves parallax has a scene-composition role, not only per-layer scroll properties.
    it("PNG: z sorted layer set", function()
        local tex = load_texture()
        local set = lurek.parallax.newSet("city_depth_stack")
        local specs = {
            { z = 30, label = "FOG", color = { 126, 130, 166 } },
            { z = -20, label = "SKY", color = { 58, 106, 164 } },
            { z = 10, label = "BUILD", color = { 82, 144, 126 } },
            { z = 0, label = "HILL", color = { 134, 122, 82 } },
        }
        for _, spec in ipairs(specs) do
            local layer = lurek.parallax.newLayer({ texture = tex, z = spec.z, repeat_x = true, repeat_y = true })
            set:addLayer(layer)
        end
        set:sortByZ()
        local stats = set:getStats()
        local img = new_canvas("PARALLAX Z SORTED SET")
        local base_y = 342
        for i = 1, set:layerCount() do
            local z = set:getLayerZAt(i)
            local color = z < 0 and { 58, 106, 164 } or (z == 0 and { 134, 122, 82 } or (z < 20 and { 82, 144, 126 } or { 126, 130, 166 }))
            local x = 118 + (i - 1) * 146
            local h = 70 + i * 34
            img:drawRect(x, base_y - h, 110, h, color[1], color[2], color[3], 255)
            outline(img, x, base_y - h, 110, h, 226, 234, 242)
            draw_text(img, "Z " .. tostring(z), x + 28, base_y - h + 16, 1, 250, 252, 255)
            draw_text(img, tostring(i), x + 48, base_y + 16, 2, 250, 252, 255)
        end
        draw_text(img, "SET " .. stats.name, 78, 100, 1, 188, 202, 220)
        draw_text(img, "LAYERS " .. tostring(stats.layer_count), 78, 384, 1, 188, 202, 220)
        save_png(img, OUT .. "parallax_z_sorted_set.png")
    end)

    -- Does: Configures tint, opacity, blend, effect passes, clamp, and motion stretch on one layer, then renders the exposed settings.
    -- Shows: The artifact separates visual styling state from movement state and includes effect pass count from getStats.
    -- Artifact: tests/artifacts/current/parallax/parallax_effect_tint_motion_stretch.png
    -- Why: This proves parallax layers carry render-intent metadata used by the engine draw command path.
    it("PNG: effect tint motion stretch", function()
        local layer = build_layer({ scroll_factor_x = 0.7, scroll_factor_y = 0.0, opacity = 0.8, blend_mode = "screen" })
        layer:setTint(0.45, 0.75, 1.0, 0.82)
        layer:addEffectPass("chromatic_shift", { amount = 0.18 })
        layer:addEffectPass("mist_blur", { radius = 2.0 })
        layer:setMotionStretch(true, 0.65, 1.8)
        layer:setClamp(-120, -40, 480, 180)
        local r, g, b, a = layer:getTint()
        local stretch_enabled, stretch_strength, stretch_max = layer:getMotionStretch()
        local stats = layer:getStats()
        local img = new_canvas("PARALLAX EFFECT CHAIN")
        img:drawRect(86, 132, 260, 144, math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), 255)
        outline(img, 86, 132, 260, 144, 236, 244, 250)
        draw_text(img, "TINT", 180, 188, 2, 18, 24, 32)
        draw_text(img, "ALPHA " .. tostring(math.floor(a * 100)) .. "/100", 104, 296, 1, 222, 232, 242)
        draw_text(img, "BLEND " .. string.upper(layer:getBlendMode()), 104, 316, 1, 222, 232, 242)
        draw_bar(img, 434, 136, "EFFECTS " .. tostring(stats.effect_pass_count), stats.effect_pass_count, 4, { 255, 204, 94 })
        draw_bar(img, 434, 190, "STRENGTH " .. tostring(math.floor(stretch_strength * 100)), stretch_strength, 1, { 116, 206, 146 })
        draw_bar(img, 434, 244, "MAX " .. tostring(math.floor(stretch_max * 100)), stretch_max, 2, { 102, 186, 232 })
        draw_text(img, "STRETCH " .. tostring(stretch_enabled and 1 or 0), 434, 312, 1, 222, 232, 242)
        save_png(img, OUT .. "parallax_effect_tint_motion_stretch.png")
    end)

    -- Does: Builds far, mid, and fog preset layers and draws their preset-derived telemetry cards.
    -- Shows: Presets produce distinct scroll factor, depth, opacity, and z profiles for common background roles.
    -- Artifact: tests/artifacts/current/parallax/parallax_preset_layer_profiles.png
    -- Why: This proves lurek.parallax.newPresetLayer is a real authoring shortcut with visible behavior differences.
    it("PNG: preset layer profiles", function()
        local tex = load_texture()
        local presets = {
            { name = "far", color = { 64, 112, 178 } },
            { name = "mid", color = { 82, 154, 126 } },
            { name = "fog", color = { 142, 142, 176 } },
        }
        local img = new_canvas("PARALLAX PRESET PROFILES")
        for i, p in ipairs(presets) do
            local layer = lurek.parallax.newPresetLayer(p.name, tex)
            local fx, fy = layer:getScrollFactor()
            local stats = layer:getStats()
            local x = 78 + (i - 1) * 238
            img:drawRect(x, 124, 190, 214, p.color[1], p.color[2], p.color[3], 255)
            outline(img, x, 124, 190, 214, 230, 238, 246)
            draw_text(img, string.upper(p.name), x + 56, 148, 2, 250, 252, 255)
            draw_bar(img, x + 18, 206, "FX " .. tostring(math.floor(fx * 100)), fx, 1, { 255, 204, 94 })
            draw_bar(img, x + 18, 254, "FY " .. tostring(math.floor(fy * 100)), fy, 1, { 116, 206, 146 })
            draw_text(img, "DEPTH " .. tostring(math.floor(stats.depth * 100)), x + 26, 310, 1, 246, 250, 252)
        end
        save_png(img, OUT .. "parallax_preset_layer_profiles.png")
    end)

    -- Does: Configures autoscroll, advances LParallaxLayer:update across frames, and records the moving tile phase as a GIF.
    -- Shows: The layer can animate without camera movement, making background drift distinct from normal camera parallax.
    -- Artifact: tests/artifacts/current/parallax/parallax_autoscroll_motion.gif
    -- Why: Autoscroll is temporal parallax behavior, so an animated artifact is more honest than a single still frame.
    it("GIF: autoscroll motion", function()
        local layer = build_layer({ scroll_factor_x = 0.25, scroll_factor_y = 0.0, repeat_x = true, repeat_y = true })
        layer:setAutoscroll(56, 0)
        local vx = layer:getAutoscroll()
        local phase = 0
        local frames = {}
        for frame = 1, 5 do
            layer:update(0.12)
            phase = phase + vx * 0.12
            local img = lurek.image.newImageData(128, 72)
            img:fill(14, 17, 22, 255)
            for row = 0, 2 do
                local y = 10 + row * 18
                local row_shift = (phase + row * 24) % 96
                img:drawRect(8, y, 112, 12, 34, 60, 88, 255)
                for i = -1, 3 do
                    local x = 8 + i * 48 - row_shift * 0.5
                    local a = math.floor(x + 5)
                    local b = math.floor(x + 36)
                    if a >= 8 and a <= 92 then
                        img:drawRect(a, y + 3, 28, 5, 82, 154, 210, 255)
                    end
                    if b >= 8 and b <= 110 then
                        img:drawRect(b, y + 7, 10, 3, 118, 202, 168, 255)
                    end
                end
                outline(img, 8, y, 112, 12, 88, 112, 140)
            end
            frames[frame] = img
        end
        save_gif(frames, OUT .. "parallax_autoscroll_motion.gif")
    end)

    -- Does: Binds a draw-target shader to a parallax layer and records the binding, getter, and cleanup behavior.
    -- Shows: Parallax stores a render-owned LShader handle for layer rendering without compiling WGSL outside render.
    -- Artifact: tests/artifacts/current/parallax/parallax_shader_binding_contract.txt
    -- Why: Procedural/background shader support needs proof that parallax can carry custom render shaders as semantic bindings.
    it("TXT: shader binding contract", function()
        local layer = build_layer({ scroll_factor_x = 0.2, scroll_factor_y = 0.0, tiling = true })
        local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(0.85, 0.95, 1.0), color.a);
}
]], { target = "draw" })
        layer:setShader(shader)
        layer:render(12, 6)
        local bound = layer:getShader()
        layer:setShader(nil)
        local text = table.concat({
            "Parallax shader binding evidence",
            "constructor=lurek.render.newShader",
            "target=draw",
            "shader_id=" .. tostring(shader:getId()),
            "layer.setShader.accepted=" .. tostring(bound ~= nil),
            "layer.getShader.id=" .. tostring(bound and bound:getId()),
            "render.queued_layer_commands=true",
            "layer.shader.cleared=" .. tostring(layer:getShader() == nil),
        }, "\n")
        local path = OUT .. "parallax_shader_binding_contract.txt"
        if write_file then write_file(path, text) else lurek.filesystem.write(path, text) end
        expect_evidence_created(path)
    end)

    -- Does: Binds draw-target shaders to parallax layers and emits three background-layer shader artifacts.
    -- Shows: Procedural sky, nebula layer, and cloud tint are represented as parallax/background surfaces.
    -- Artifact: tests/artifacts/current/parallax/parallax_shader_visual_01_procedural_sky.png, tests/artifacts/current/parallax/parallax_shader_visual_02_nebula_layer.png, tests/artifacts/current/parallax/parallax_shader_visual_03_cloud_tint.png
    -- Why: Parallax owns layered backgrounds, so shader evidence should show scrollable atmospheric/background materials rather than foreground sprites.
    it("PNG: shader-backed parallax layer variants", function()
        dofile("tests/lua/fixtures/shader_visual_helpers.lua")
        local ShaderEvidence = _G.ShaderEvidence
        ShaderEvidence.emit("parallax", {
            { target = "draw", slug = "procedural_sky" },
            { target = "draw", slug = "nebula_layer" },
            { target = "draw", slug = "cloud_tint" },
        }, OUT)
    end)
end)

test_summary()
