local World = require("content.games.puzzle.mapblock_labyrinth.modules.world")

local app = {
    title = "Mapblock Labyrinth",
    seed = 41,
    world = nil,
    player = nil,
    steps = 0,
    won = false,
    status = "",
    macro_cell = 52,
    detail_tile = 10,
    padding = 22,
    panel_gap = 20,
}

local function grid_dimensions()
    local bounds = app.world.bounds
    return bounds[3] - bounds[1] + 1, bounds[4] - bounds[2] + 1
end

local function reset_player()
    app.player = { x = app.world.start.x, y = app.world.start.y }
    app.steps = 0
    app.won = false
    app.status = "Macro blocks build the province. Tile layers show the full detailed map."
end

local function regenerate(seed)
    app.seed = seed
    app.world = World.build(seed)
    reset_player()
end

local function try_move(dx, dy)
    if app.won then
        return
    end
    local nx = app.player.x + dx
    local ny = app.player.y + dy
    if not World.can_move(app.world, nx, ny) then
        return
    end
    app.player.x = nx
    app.player.y = ny
    app.steps = app.steps + 1

    if nx == app.world.goal.x and ny == app.world.goal.y then
        app.won = true
        app.status = string.format("Goal reached in %d moves. Optimal route: %d.", app.steps, app.world.optimal_steps)
    else
        app.status = string.format("Macro move %d/%d. Detailed levels stay aligned with the same block placements.", app.steps, app.world.optimal_steps)
    end
end

local function draw_panel(x, y, width, height, title, subtitle)
    lurek.render.setColor(0.10, 0.12, 0.16, 1)
    lurek.render.rectangle("fill", x, y, width, height)
    lurek.render.setColor(0.22, 0.25, 0.31, 1)
    lurek.render.rectangle("line", x, y, width, height)
    lurek.render.setColor(0.94, 0.95, 0.98, 1)
    lurek.render.print(title, x + 12, y + 10)
    if subtitle and subtitle ~= "" then
        lurek.render.setColor(0.72, 0.78, 0.84, 1)
        lurek.render.print(subtitle, x + 12, y + 28)
    end
end

local function macro_panel_rect()
    local grid_w, grid_h = grid_dimensions()
    local board_w = grid_w * app.macro_cell
    local board_h = grid_h * app.macro_cell
    return app.padding, 106, board_w + 26, board_h + 50
end

local function detail_panel_rect(index)
    local detail = app.world.detail
    local macro_x, macro_y, macro_w = macro_panel_rect()
    local panel_w = detail.tile_width * app.detail_tile + 26
    local panel_h = detail.tile_height * app.detail_tile + 50
    local x = macro_x + macro_w + app.panel_gap + (index - 1) * (panel_w + app.panel_gap)
    return x, macro_y, panel_w, panel_h
end

local function macro_cell_position(cell_x, cell_y)
    local bounds = app.world.bounds
    local panel_x, panel_y = macro_panel_rect()
    local board_x = panel_x + 12
    local board_y = panel_y + 36
    return board_x + (cell_x - bounds[1]) * app.macro_cell, board_y + (cell_y - bounds[2]) * app.macro_cell
end

local function detail_cell_position(origin_x, origin_y, cell_x, cell_y)
    local bounds = app.world.bounds
    local cell_size = app.detail_tile * app.world.detail.segment_tiles
    return origin_x + (cell_x - bounds[1]) * cell_size, origin_y + (cell_y - bounds[2]) * cell_size
end

local function draw_macro_view()
    local panel_x, panel_y, panel_w, panel_h = macro_panel_rect()
    draw_panel(
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        "Stage 1: macro map blocks",
        "Irregular province grid filled by edge fill, fixed anchors, and shape solving"
    )

    for i = 1, #app.world.cells_list do
        local cx = app.world.cells_list[i][1]
        local cy = app.world.cells_list[i][2]
        local cell = app.world.cells[cx .. ":" .. cy]
        local px, py = macro_cell_position(cx, cy)
        local color = cell.color

        lurek.render.setColor(color[1] / 255, color[2] / 255, color[3] / 255, 1)
        lurek.render.rectangle("fill", px, py, app.macro_cell - 3, app.macro_cell - 3)
        lurek.render.setColor(0.08, 0.10, 0.12, 1)
        lurek.render.rectangle("line", px, py, app.macro_cell - 3, app.macro_cell - 3)
    end

    local goal_x, goal_y = macro_cell_position(app.world.goal.x, app.world.goal.y)
    lurek.render.setColor(0.97, 0.89, 0.46, 1)
    lurek.render.rectangle("line", goal_x + 7, goal_y + 7, app.macro_cell - 17, app.macro_cell - 17)

    local player_x, player_y = macro_cell_position(app.player.x, app.player.y)
    lurek.render.setColor(0.96, 0.97, 1.0, 0.95)
    lurek.render.rectangle("fill", player_x + 14, player_y + 14, app.macro_cell - 31, app.macro_cell - 31)
end

local function draw_detail_view(level, title, index)
    local panel_x, panel_y, panel_w, panel_h = detail_panel_rect(index)
    local board_x = panel_x + 12
    local board_y = panel_y + 36
    local subtitle = string.format("%dx%d tiles, %d layers", app.world.detail.tile_width, app.world.detail.tile_height, app.world.detail.layer_count)
    draw_panel(panel_x, panel_y, panel_w, panel_h, title, subtitle)

    for y = 0, app.world.detail.tile_height - 1 do
        for x = 0, app.world.detail.tile_width - 1 do
            local gid = World.resolve_level_gid(app.world, level, x, y)
            local color = World.tile_color(level, gid)
            if gid == 0 then
                color = { 34, 38, 48 }
            end
            lurek.render.setColor(color[1] / 255, color[2] / 255, color[3] / 255, 1)
            lurek.render.rectangle("fill", board_x + x * app.detail_tile, board_y + y * app.detail_tile, app.detail_tile - 1, app.detail_tile - 1)
        end
    end

    local macro_cell_px = app.detail_tile * app.world.detail.segment_tiles
    lurek.render.setColor(0.92, 0.94, 0.98, 0.22)
    for i = 1, #app.world.cells_list do
        local cx = app.world.cells_list[i][1]
        local cy = app.world.cells_list[i][2]
        local px, py = detail_cell_position(board_x, board_y, cx, cy)
        lurek.render.rectangle("line", px, py, macro_cell_px, macro_cell_px)
    end

    local goal_x, goal_y = detail_cell_position(board_x, board_y, app.world.goal.x, app.world.goal.y)
    lurek.render.setColor(0.97, 0.89, 0.46, 1)
    lurek.render.rectangle("line", goal_x + 2, goal_y + 2, macro_cell_px - 4, macro_cell_px - 4)

    local player_x, player_y = detail_cell_position(board_x, board_y, app.player.x, app.player.y)
    lurek.render.setColor(0.95, 0.97, 1.0, 0.16)
    lurek.render.rectangle("fill", player_x + 1, player_y + 1, macro_cell_px - 2, macro_cell_px - 2)
    lurek.render.setColor(0.97, 0.98, 1.0, 1)
    lurek.render.rectangle("line", player_x + 2, player_y + 2, macro_cell_px - 4, macro_cell_px - 4)
end

local function draw_header()
    local sizes = table.concat(app.world.detail.size_labels, ", ")
    local header_lines = {
        app.title,
        string.format("seed %d | macro cells %d | placements %d | transformed %d", app.seed, app.world.cell_count, #app.world.macro.placements, app.world.transformed_count),
        string.format("detail blocks %s | level1 placements %d | move %d/%d", sizes, app.world.detail.upper_count, app.steps, app.world.optimal_steps),
        app.status,
    }

    local y = 18
    for i = 1, #header_lines do
        if i == 1 then
            lurek.render.setColor(0.95, 0.96, 0.99, 1)
        elseif i == 4 then
            lurek.render.setColor(0.82, 0.86, 0.92, 1)
        else
            lurek.render.setColor(0.74, 0.79, 0.86, 1)
        end
        lurek.render.print(header_lines[i], app.padding, y + (i - 1) * 20)
    end
end

local function draw_footer()
    local lines = World.block_summary(app.world)
    local x = app.padding
    local y = 504
    lurek.render.setColor(0.70, 0.75, 0.82, 1)
    lurek.render.print("Block mix:", x, y)
    for i = 1, #lines do
        lurek.render.print(lines[i], x + 12, y + i * 18)
    end
    lurek.render.print("Controls: WASD/arrows move, R rerolls, Space resets, Esc quits", x, y + (#lines + 2) * 18)
end

function lurek.init()
    lurek.window.setTitle(app.title .. " - Lurek2D")
    lurek.window.windowConfig({ width = 1680, height = 860, scaleMode = "none", vsync = 1 })
    lurek.render.setBackgroundColor(0.05, 0.06, 0.08)
    regenerate(app.seed)
end

function lurek.keypressed(key)
    if key == "escape" then
        lurek.event.quit()
    elseif key == "r" then
        regenerate(app.seed + 1)
    elseif key == "space" then
        reset_player()
    elseif key == "up" or key == "w" then
        try_move(0, -1)
    elseif key == "down" or key == "s" then
        try_move(0, 1)
    elseif key == "left" or key == "a" then
        try_move(-1, 0)
    elseif key == "right" or key == "d" then
        try_move(1, 0)
    end
end

function lurek.draw()
    lurek.render.clear(0.05, 0.06, 0.08, 1)
    draw_header()
    draw_macro_view()
    draw_detail_view(0, "Stage 2A: detailed tiles level 0", 1)
    draw_detail_view(1, "Stage 2B: detailed tiles level 1", 2)
    draw_footer()
end
