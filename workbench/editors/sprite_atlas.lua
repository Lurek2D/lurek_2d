local M = {
    id = "sprite_atlas",
    title = "Sprite Atlas",
    summary = "Sheet slicer",
    workspace = "atlas",
    actions = {
        { id = "slice-grid", label = "Slice Grid", w = 104 },
        { id = "name-frames", label = "Name Frames", w = 118 },
        { id = "preview-clip", label = "Preview Clip", w = 118 },
        { id = "export-quads", label = "Export Quads", w = 118 },
    },
}

local function model(ctx)
    local state = ctx.editor_state.sprite_atlas
    if not state then
        state = {
            columns = 8,
            rows = 5,
            frame_w = 48,
            frame_h = 48,
            clip = "idle",
            frame = 1,
            elapsed = 0,
        }
        ctx.editor_state.sprite_atlas = state
    end
    return state
end

function M.update(ctx, dt)
    local s = model(ctx)
    s.elapsed = s.elapsed + dt
    s.frame = (math.floor(s.elapsed * 8) % 8) + 1
end

function M.draw(ctx, r, ui)
    local s = model(ctx)
    ui.text("Sprite Atlas", r.x + 24, r.y + 20, ui.color.text)
    ui.text("Slice frames, name clips, and export quads for lurek.render.newQuad or animation bundles.", r.x + 24, r.y + 46, ui.color.muted)
    local atlas_w = s.columns * s.frame_w
    local atlas_h = s.rows * s.frame_h
    local ox = r.x + 42
    local oy = r.y + 94
    ui.rect(ox - 14, oy - 14, atlas_w + 28, atlas_h + 28, { 0.022, 0.026, 0.034, 1 })
    for y = 1, s.rows do
        for x = 1, s.columns do
            local tx, ty = ox + (x - 1) * s.frame_w, oy + (y - 1) * s.frame_h
            local tint = ((x + y) % 2 == 0) and 0.10 or 0.13
            ui.rect(tx, ty, s.frame_w - 1, s.frame_h - 1, { tint, tint + 0.03, tint + 0.06, 1 })
            ui.rect_line(tx, ty, s.frame_w, s.frame_h, (x == s.frame and y == 1) and ui.color.accent2 or ui.color.line)
        end
    end

    local px = ox + atlas_w + 64
    ui.text("Clip preview", px, oy, ui.color.text)
    ui.rect(px, oy + 36, 144, 144, { 0.030, 0.034, 0.043, 1 })
    ui.rect_line(px, oy + 36, 144, 144, ui.color.line)
    ui.rect(px + 48, oy + 76, 48, 56, ui.color.accent)
    lurek.render.setColor(1.0, 0.78, 0.35, 1)
    lurek.render.circle("fill", px + 72, oy + 66, 20)
    ui.text("clip=" .. s.clip .. " frame=" .. s.frame, px, oy + 202, ui.color.muted)
end

function M.inspect(ctx)
    local s = model(ctx)
    return {
        { label = "Native API", value = "lurek.render" },
        { label = "Columns", value = tostring(s.columns) },
        { label = "Rows", value = tostring(s.rows) },
        { label = "Frame", value = s.frame_w .. "x" .. s.frame_h },
        { label = "Clip", value = s.clip },
        { label = "Frame index", value = tostring(s.frame) },
    }
end

function M.export(ctx)
    local s = model(ctx)
    return string.format([[local atlas = lurek.render.newImage("assets/sprites/hero.png")
local frames = {}
for i = 0, %d do
  local x = (i %% %d) * %d
  local y = math.floor(i / %d) * %d
  frames[i + 1] = lurek.render.newQuad(x, y, %d, %d, %d, %d)
end]], s.columns * s.rows - 1, s.columns, s.frame_w, s.columns, s.frame_h, s.frame_w, s.frame_h, s.columns * s.frame_w, s.rows * s.frame_h)
end

return M

