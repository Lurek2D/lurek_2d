local M = {
    id = "tilemap",
    title = "Tilemap Editor",
    summary = "Map painter",
    workspace = "grid",
    actions = {
        { id = "brush", label = "Brush", w = 80 },
        { id = "fill", label = "Fill", w = 64 },
        { id = "autotile", label = "Autotile", w = 96 },
        { id = "export-map", label = "Export Map", w = 112 },
    },
}

local function model(ctx)
    local state = ctx.editor_state.tilemap
    if not state then
        state = {
            width = 16,
            height = 10,
            tile_size = 32,
            layer = "terrain",
            orientation = "isometric-ready",
            cells = {},
        }
        for y = 1, state.height do
            for x = 1, state.width do
                local edge = x == 1 or y == 1 or x == state.width or y == state.height
                state.cells[(y - 1) * state.width + x] = edge and 2 or ((x + y) % 7 == 0 and 3 or 1)
            end
        end
        ctx.editor_state.tilemap = state
    end
    return state
end

local palette = {
    [1] = { 0.18, 0.38, 0.28, 1 },
    [2] = { 0.31, 0.28, 0.24, 1 },
    [3] = { 0.18, 0.32, 0.52, 1 },
}

function M.update(_ctx, _dt)
end

function M.draw(ctx, r, ui)
    local s = model(ctx)
    ui.text("Tilemap Editor", r.x + 24, r.y + 20, ui.color.text)
    ui.text("Paint layers, collision refs, and autotile hints. Output target: maps/*.ltm or Lua/TOML.", r.x + 24, r.y + 46, ui.color.muted)

    local grid_w = s.width * s.tile_size
    local grid_h = s.height * s.tile_size
    local ox = r.x + math.max(24, (r.w - grid_w) * 0.5)
    local oy = r.y + 90
    ui.rect(ox - 16, oy - 16, grid_w + 32, grid_h + 32, { 0.026, 0.031, 0.038, 1 })
    ui.rect_line(ox - 16, oy - 16, grid_w + 32, grid_h + 32, ui.color.line)

    for y = 1, s.height do
        for x = 1, s.width do
            local id = s.cells[(y - 1) * s.width + x]
            local tx, ty = ox + (x - 1) * s.tile_size, oy + (y - 1) * s.tile_size
            ui.rect(tx, ty, s.tile_size - 1, s.tile_size - 1, palette[id] or palette[1])
            if id == 3 then
                lurek.render.setColor(0.55, 0.78, 1.0, 0.35)
                lurek.render.circle("fill", tx + 16, ty + 16, 9)
            end
        end
    end
    ui.text("Layer: terrain | Brush: grass | View: topdown grid", ox, oy + grid_h + 18, ui.color.muted)
end

function M.inspect(ctx)
    local s = model(ctx)
    return {
        { label = "Native API", value = "lurek.tilemap" },
        { label = "Size", value = s.width .. "x" .. s.height },
        { label = "Tile", value = tostring(s.tile_size) .. " px" },
        { label = "Layer", value = s.layer },
        { label = "Orientation", value = s.orientation },
        { label = "Export", value = "maps/test_level.ltm" },
    }
end

function M.export(ctx)
    local s = model(ctx)
    return string.format([[local map = lurek.tilemap.newTileMap(%d, %d)
local terrain = map:addLayer("terrain", %d, %d)
map:fill(terrain, 1)
-- Workbench will write painted cells and collision refs here.
return map]], s.width, s.height, s.width, s.height)
end

return M

