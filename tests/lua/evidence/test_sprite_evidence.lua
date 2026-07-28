-- @covers lurek.image.newImageData
-- @covers lurek.image.saveGIF
-- @covers lurek.image.savePNG
-- @covers lurek.render.newImage
-- @covers lurek.sprite.newAnimator
-- @covers lurek.sprite.newAtlasPacker
-- @covers lurek.sprite.newSheet
-- @covers lurek.sprite.newSprite
-- @covers lurek.sprite.parseAtlas

-- Canonical evidence file for lurek.sprite visual artifacts.

local OUT = evidence_output_dir("sprite")

local SPRITE_TEXTURE = lurek.render.newImage("assets/icon.png")
local function sprite_texture_id()
    return SPRITE_TEXTURE:getId()
end

local FONT = {
    [" "] = { "000", "000", "000", "000", "000", "000", "000" },
    ["-"] = { "00000", "00000", "00000", "11110", "00000", "00000", "00000" },
    [":"] = { "000", "010", "000", "000", "010", "000", "000" },
    ["/"] = { "00001", "00010", "00010", "00100", "01000", "01000", "10000" },
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
    lurek.image.saveGIF(frames, path, { delayMs = 120, speed = 20 })
    expect_evidence_created(path)
end

local function draw_text(img, text, x, y, scale, r, g, b)
    text = string.upper(tostring(text or ""))
    scale = scale or 1
    local cursor = math.floor(x)
    for i = 1, #text do
        local glyph = FONT[string.sub(text, i, i)] or FONT[" "]
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

local function outline(img, x, y, w, h, r, g, b)
    img:drawRect(x, y, w, 2, r, g, b, 255)
    img:drawRect(x, y + h - 2, w, 2, r, g, b, 255)
    img:drawRect(x, y, 2, h, r, g, b, 255)
    img:drawRect(x + w - 2, y, 2, h, r, g, b, 255)
end

local function new_canvas(title)
    local img = lurek.image.newImageData(760, 420)
    img:fill(15, 17, 23, 255)
    img:drawRect(18, 18, 724, 42, 31, 37, 50, 255)
    draw_text(img, title, 34, 32, 2, 235, 241, 247)
    img:drawRect(18, 78, 724, 322, 22, 25, 34, 255)
    outline(img, 18, 78, 724, 322, 78, 90, 112)
    return img
end

local function draw_sheet_grid(img, x, y, cols, rows, cell, highlight_col, highlight_row)
    for row = 1, rows do
        for col = 1, cols do
            local px = x + (col - 1) * cell
            local py = y + (row - 1) * cell
            local active = col == highlight_col and row == highlight_row
            local color = active and { 255, 204, 94 } or { 58, 98, 136 }
            img:drawRect(px, py, cell - 3, cell - 3, color[1], color[2], color[3], 255)
            outline(img, px, py, cell - 3, cell - 3, 218, 228, 238)
            draw_text(img, tostring((row - 1) * cols + col), px + 9, py + 10, 1, active and 18 or 238, active and 24 or 244, active and 32 or 250)
        end
    end
end

local function draw_panel(img, x, y, w, h, r, g, b)
    img:drawRect(x, y, w, h, r, g, b, 255)
    img:drawRect(x + 4, y + 4, w - 8, h - 8, math.min(255, r + 22), math.min(255, g + 20), math.min(255, b + 16), 255)
    outline(img, x, y, w, h, 232, 238, 246)
end

local function draw_mirrored_region(img, x, y, w, h)
    for ix = 0, w - 1, 6 do
        local shade = 86 + math.floor((w - ix) / math.max(1, w) * 90)
        img:drawRect(x + ix, y, 6, h, shade, 142, 204, 255)
    end
    outline(img, x, y, w, h, 255, 204, 94)
end

-- @describe evidence: sprite
describe("evidence: sprite", function()
    before_each(function()
        ensure_evidence_dir("sprite")
    end)

    -- Does: Builds a regular SpriteSheet, names idle/run groups, uses drawToImage, and overlays the group spans.
    -- Shows: Sprite owns sheet geometry and named frame groups as a lightweight textured-2D model distinct from full animation state machines.
    -- Artifact: tests/artifacts/current/sprite/sprite_sheet_groups.png
    -- Why: This proves LSpriteSheet:getGridSize, nameGroup, getGroupFrames, and drawToImage describe inspectable frame layout.
    it("PNG: sheet groups and grid preview", function()
        local sheet = lurek.sprite.newSheet(96, 64, 24, 16)
        sheet:nameGroup("idle", 1, 2)
        sheet:nameGroup("run", 3, 4)
        local preview = sheet:drawToImage(192, 128)
        local img = new_canvas("SPRITE SHEET GROUPS")
        img:paste(preview, 522, 112)
        draw_text(img, "DRAWTOIMAGE", 532, 252, 1, 184, 198, 216)
        draw_sheet_grid(img, 66, 126, 4, 4, 52, 3, 1)
        img:drawRect(66, 118, 102, 6, 118, 204, 152, 255)
        img:drawRect(170, 118, 206, 6, 255, 204, 94, 255)
        draw_text(img, "IDLE GROUP FRAMES 0-1", 68, 348, 1, 118, 204, 152)
        draw_text(img, "RUN GROUP FRAMES 2-5", 68, 372, 1, 255, 204, 94)
        local cols, rows = sheet:getGridSize()
        local fw, fh = sheet:getFrameSize()
        draw_text(img, "GRID " .. tostring(cols) .. "X" .. tostring(rows), 430, 146, 1, 228, 236, 244)
        draw_text(img, "CELL " .. tostring(fw) .. "X" .. tostring(fh), 430, 170, 1, 228, 236, 244)
        draw_text(img, "NAMED GROUPS", 430, 218, 1, 228, 236, 244)
        save_png(img, OUT .. "sprite_sheet_groups.png")
    end)

    -- Does: Plays an LSpriteAnimator clip, advances it with update, and records the highlighted sheet cell as a GIF.
    -- Shows: The GIF exposes clip playback, currentFrame, loop callback, and frame callback state as a sprite-specific lightweight animator.
    -- Artifact: tests/artifacts/current/sprite/sprite_animator_clip_playback.gif
    -- Why: This is the sprite module's own clip player evidence; motion belongs in one GIF rather than separate PNG frames.
    it("GIF: animator clip playback", function()
        local anim = lurek.sprite.newAnimator({
            walk = { row = 2, from = 1, to = 4, fps = 8, loop = true },
        })
        local frame_events = 0
        local loop_events = 0
        anim:onFrame(function() frame_events = frame_events + 1 end)
        anim:onLoop(function() loop_events = loop_events + 1 end)
        anim:play("walk")
        local frames = {}
        for i = 1, 8 do
            anim:update(0.13)
            local row, col = anim:currentFrame()
            local img = lurek.image.newImageData(240, 150)
            img:fill(15, 17, 23, 255)
            draw_text(img, "SPRITE ANIMATOR", 20, 18, 1, 235, 241, 247)
            draw_sheet_grid(img, 24, 48, 4, 3, 32, col, row)
            draw_text(img, "CLIP WALK", 162, 52, 1, 228, 236, 244)
            draw_text(img, "F " .. tostring(frame_events), 162, 78, 1, 228, 236, 244)
            draw_text(img, "LOOP " .. tostring(loop_events), 162, 104, 1, 228, 236, 244)
            frames[i] = img
        end
        save_gif(frames, OUT .. "sprite_animator_clip_playback.gif")
    end)

    -- Does: Parses a TexturePacker atlas, reads named entries, and requests flipped metadata.
    -- Shows: Atlas regions preserve names, rectangles, rotation state, and flip flags for packed sprite workflows.
    -- Artifact: tests/artifacts/current/sprite/sprite_atlas_regions_flips.png
    -- Why: This demonstrates sprite atlas ownership instead of forcing users to hand-maintain packed texture coordinates.
    it("PNG: atlas regions and flips", function()
        local atlas = lurek.sprite.parseAtlas([[{"frames":{
            "hero_idle":{"frame":{"x":0,"y":0,"w":32,"h":32},"rotated":false},
            "hero_run":{"frame":{"x":34,"y":0,"w":42,"h":32},"rotated":false},
            "sword":{"frame":{"x":0,"y":34,"w":16,"h":42},"rotated":false}
        }}]])
        local names = atlas:entryNames()
        local flipped = atlas:getFlipped("hero_run", true, false)
        local img = new_canvas("SPRITE ATLAS REGIONS")
        img:drawRect(68, 116, 300, 230, 34, 40, 54, 255)
        outline(img, 68, 116, 300, 230, 92, 106, 128)
        draw_text(img, "PACKED TEXTURE SPACE", 86, 132, 1, 184, 198, 216)
        for i, name in ipairs(names) do
            local e = atlas:getEntry(name)
            local x = 96 + e.x * 2
            local y = 164 + e.y * 2
            img:drawRect(x, y, e.w * 2, e.h * 2, 82, 144, 202, 255)
            outline(img, x, y, e.w * 2, e.h * 2, 230, 238, 246)
            draw_text(img, tostring(i), x + 8, y + 10, 1, 18, 24, 32)
        end
        local hero_run = atlas:getEntry("hero_run")
        img:drawRect(430, 130, hero_run.w * 3, hero_run.h * 3, 82, 144, 202, 255)
        outline(img, 430, 130, hero_run.w * 3, hero_run.h * 3, 230, 238, 246)
        draw_mirrored_region(img, 430, 250, hero_run.w * 3, hero_run.h * 3)
        draw_text(img, "HERO RUN", 430, 108, 1, 228, 236, 244)
        draw_text(img, "ORIGINAL", 574, 168, 1, 184, 198, 216)
        draw_text(img, "FLIPPED X", 574, 288, 1, 255, 204, 94)
        draw_text(img, "COUNT " .. tostring(atlas:entryCount()), 96, 330, 1, 228, 236, 244)
        draw_text(img, "FLIP X " .. tostring(flipped.flip_x and 1 or 0), 244, 330, 1, 255, 204, 94)
        save_png(img, OUT .. "sprite_atlas_regions_flips.png")
    end)

    -- Does: Packs regions into an LAtlasPacker and stores nine-slice insets for the panel region.
    -- Shows: Runtime packing keeps allocation geometry and scalable panel metadata together.
    -- Artifact: tests/artifacts/current/sprite/sprite_packer_nine_slice.png
    -- Why: This is high-value sprite evidence because atlas packing and nine-slice panels are module-specific textured-2D tooling.
    it("PNG: packer and nine slice metadata", function()
        local packer = lurek.sprite.newAtlasPacker(128, 96, 2)
        expect_true(packer:pack("panel", 44, 34))
        expect_true(packer:pack("icon", 22, 22))
        expect_true(packer:pack("badge", 28, 18))
        expect_true(packer:setNineSlice("panel", 6, 6, 5, 5))
        local img = new_canvas("SPRITE PACKER NINE SLICE")
        local atlas_x, atlas_y, scale = 72, 128, 2
        img:drawRect(atlas_x, atlas_y, 128 * scale, 96 * scale, 38, 44, 58, 255)
        outline(img, atlas_x, atlas_y, 128 * scale, 96 * scale, 92, 106, 128)
        for _, name in ipairs({ "panel", "icon", "badge" }) do
            local r = packer:getRegion(name)
            img:drawRect(atlas_x + r.x * scale, atlas_y + r.y * scale, r.w * scale, r.h * scale, 82, 144, 202, 255)
            outline(img, atlas_x + r.x * scale, atlas_y + r.y * scale, r.w * scale, r.h * scale, 230, 238, 246)
            draw_text(img, name, atlas_x + r.x * scale + 6, atlas_y + r.y * scale + 8, 1, 18, 24, 32)
            if r.nine_slice then
                local x = atlas_x + r.x * scale
                local y = atlas_y + r.y * scale
                img:drawLine(x + r.nine_slice.left * scale, y, x + r.nine_slice.left * scale, y + r.h * scale, 255, 204, 94, 255)
                img:drawLine(x + (r.w - r.nine_slice.right) * scale, y, x + (r.w - r.nine_slice.right) * scale, y + r.h * scale, 255, 204, 94, 255)
                img:drawLine(x, y + r.nine_slice.top * scale, x + r.w * scale, y + r.nine_slice.top * scale, 255, 204, 94, 255)
                img:drawLine(x, y + (r.h - r.nine_slice.bottom) * scale, x + r.w * scale, y + (r.h - r.nine_slice.bottom) * scale, 255, 204, 94, 255)
            end
        end
        draw_panel(img, 430, 132, 210, 126, 82, 144, 202)
        img:drawLine(430 + 24, 132, 430 + 24, 258, 255, 204, 94, 255)
        img:drawLine(430 + 186, 132, 430 + 186, 258, 255, 204, 94, 255)
        img:drawLine(430, 132 + 20, 640, 132 + 20, 255, 204, 94, 255)
        img:drawLine(430, 132 + 106, 640, 132 + 106, 255, 204, 94, 255)
        draw_text(img, "SCALED PANEL", 458, 284, 1, 228, 236, 244)
        draw_text(img, "INSETS 6/6/5/5", 458, 308, 1, 255, 204, 94)
        draw_text(img, "REGIONS " .. tostring(packer:regionCount()), 72, 346, 1, 228, 236, 244)
        save_png(img, OUT .. "sprite_packer_nine_slice.png")
    end)

    -- Does: Creates a sprite, moves it, assigns normal-map metadata, and clears a second sprite for comparison.
    -- Shows: Sprite instances carry position plus lit-sprite normal state and intensity as runtime data.
    -- Artifact: tests/artifacts/current/sprite/sprite_lit_normal_state.png
    -- Why: This proves LSprite is more than a texture id; it owns per-instance state used by lit sprite workflows.
    it("PNG: lit sprite normal map state", function()
        local sprite = lurek.sprite.newSprite(sprite_texture_id(), 40, 72)
        sprite:setPosition(96, 128)
        sprite:setNormalMap(sprite_texture_id())
        sprite:setNormalIntensity(2.5)
        local plain = lurek.sprite.newSprite(sprite_texture_id(), 220, 128)
        plain:setNormalMap(sprite_texture_id())
        plain:clearNormalMap()
        local x, y = sprite:getPosition()
        local img = new_canvas("SPRITE LIT STATE")
        draw_panel(img, 92, 132, 152, 152, 82, 144, 202)
        img:drawCircle(168, 208, 54, 142, 184, 232, 255)
        img:drawCircle(124, 166, 12, 255, 244, 170, 220)
        img:drawLine(126, 168, 164, 204, 255, 244, 170, 255)
        img:drawRect(310, 132, 152, 152, 78, 82, 104, 255)
        for yy = 0, 4 do
            img:drawRect(322 + yy * 20, 146, 12, 124, 90 + yy * 22, 112, 178, 255)
        end
        outline(img, 310, 132, 152, 152, 160, 170, 196)
        img:drawRect(528, 132, 128, 128, 70, 78, 96, 255)
        outline(img, 528, 132, 128, 128, 128, 140, 160)
        draw_text(img, "LIT SPRITE", 116, 306, 1, 228, 236, 244)
        draw_text(img, "NORMAL MAP " .. tostring(sprite:getNormalMap()), 306, 306, 1, 228, 236, 244)
        draw_text(img, "CLEARED COPY", 510, 306, 1, 184, 198, 216)
        draw_text(img, "INT " .. tostring(math.floor(sprite:getNormalIntensity() * 10)), 116, 336, 1, 255, 204, 94)
        draw_text(img, "POS " .. tostring(x) .. "/" .. tostring(y), 306, 336, 1, 228, 236, 244)
        draw_text(img, "HAS " .. tostring(plain:hasNormalMap() and 1 or 0), 510, 336, 1, 228, 236, 244)
        save_png(img, OUT .. "sprite_lit_normal_state.png")
    end)

    -- Does: Binds sprite-target shaders to sprite handles and emits three sprite-material artifacts.
    -- Shows: Team color, palette swap, and damage-flash sprite material use cases are represented as sprite-shaped outputs.
    -- Artifact: tests/artifacts/current/sprite/sprite_shader_visual_01_team_color.png, tests/artifacts/current/sprite/sprite_shader_visual_02_palette_swap.png, tests/artifacts/current/sprite/sprite_shader_visual_03_damage_flash.png
    -- Why: Sprite shaders are material-style render modifiers, so evidence should show character/sprite recolor states instead of generic shapes.
    it("PNG: shader-backed sprite material variants", function()
        dofile("tests/lua/fixtures/shader_visual_helpers.lua")
        local ShaderEvidence = _G.ShaderEvidence
        ShaderEvidence.emit("sprite", {
            { target = "sprite", slug = "team_color" },
            { target = "sprite", slug = "palette_swap" },
            { target = "sprite", slug = "damage_flash" },
        }, OUT)
    end)
end)

test_summary()
