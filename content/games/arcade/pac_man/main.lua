-- Maze Chase - original maze-chase arcade demo for Lurek2D.

local TILE = 28
local SCREEN_W, SCREEN_H = 800, 600

local MAP = {
    "###################",
    "#........#........#",
    "#.###.##.#.##.###.#",
    "#o#.............#o#",
    "#.#.###.###.###.#.#",
    "#.................#",
    "###.##.#####.##.###",
    "#........#........#",
    "#.#####..#..#####.#",
    "#.................#",
    "#.###.##.#.##.###.#",
    "#o..#.........#..o#",
    "#.###.#######.###.#",
    "#.................#",
    "###################",
}

local ROWS = #MAP
local COLS = #MAP[1]
local OFFSET_X = math.floor((SCREEN_W - COLS * TILE) / 2)
local OFFSET_Y = 86

local DIRS = {
    up = { dx = 0, dy = -1 },
    down = { dx = 0, dy = 1 },
    left = { dx = -1, dy = 0 },
    right = { dx = 1, dy = 0 },
}
local DIR_ORDER = { "up", "left", "down", "right" }
local OPPOSITE = { up = "down", down = "up", left = "right", right = "left" }

local HUNTER_COLORS = {
    { 0.95, 0.18, 0.16, 1 },
    { 0.95, 0.42, 0.75, 1 },
    { 0.15, 0.9, 0.95, 1 },
}
local SCATTER_TARGETS = {
    { col = 18, row = 2 },
    { col = 2, row = 14 },
    { col = 18, row = 14 },
}

local App = {
    state = "title",
    grid = {},
    total_dots = 0,
    dots_left = 0,
    score = 0,
    level = 1,
    lives = 3,
    mode = "scatter",
    mode_timer = 0,
    frightened_timer = 0,
    combo = 0,
    pulse = 0,
    message = "",
    player = { col = 2, row = 2, dir = "right", queued = "right", step_timer = 0, step_time = 0.105 },
    hunters = {},
}

local sparkle = nil

local function clone_grid()
    App.grid = {}
    App.total_dots = 0
    App.dots_left = 0
    for row = 1, ROWS do
        App.grid[row] = {}
        local line = MAP[row]
        for col = 1, COLS do
            local cell = line:sub(col, col)
            App.grid[row][col] = cell
            if cell == "." or cell == "o" then
                App.total_dots = App.total_dots + 1
                App.dots_left = App.dots_left + 1
            end
        end
    end
end

local function wrap_col(col)
    if col < 1 then return COLS end
    if col > COLS then return 1 end
    return col
end

local function is_walkable(col, row)
    if row < 1 or row > ROWS then return false end
    col = wrap_col(col)
    return App.grid[row][col] ~= "#"
end

local function next_cell(col, row, dir)
    local d = DIRS[dir]
    return wrap_col(col + d.dx), row + d.dy
end

local function tile_center(col, row)
    return OFFSET_X + (col - 0.5) * TILE, OFFSET_Y + (row - 0.5) * TILE
end

local function dist_sq(a_col, a_row, b_col, b_row)
    local dx = a_col - b_col
    local dy = a_row - b_row
    return dx * dx + dy * dy
end

local function reset_positions()
    App.player.col = 2
    App.player.row = 2
    App.player.dir = "right"
    App.player.queued = "right"
    App.player.step_timer = 0

    App.hunters = {
        { col = 9, row = 8, dir = "left", step_timer = 0, step_time = 0.145, color = HUNTER_COLORS[1], personality = "direct" },
        { col = 11, row = 8, dir = "right", step_timer = 0, step_time = 0.155, color = HUNTER_COLORS[2], personality = "ambush" },
        { col = 9, row = 9, dir = "up", step_timer = 0, step_time = 0.165, color = HUNTER_COLORS[3], personality = "flank" },
    }
    App.mode = "scatter"
    App.mode_timer = 0
    App.frightened_timer = 0
    App.combo = 0
end

local function reset_game()
    clone_grid()
    App.score = 0
    App.level = 1
    App.lives = 3
    App.message = "Clear the maze"
    reset_positions()
    App.state = "playing"
end

local function advance_level()
    App.level = App.level + 1
    App.score = App.score + 500
    App.message = "Next maze"
    clone_grid()
    reset_positions()
    for _, hunter in ipairs(App.hunters) do
        hunter.step_time = math.max(0.095, hunter.step_time - (App.level - 1) * 0.008)
    end
end

local function set_frightened()
    App.frightened_timer = 6.0
    App.combo = 0
    App.message = "Hunters vulnerable"
    for _, hunter in ipairs(App.hunters) do
        hunter.dir = OPPOSITE[hunter.dir] or hunter.dir
    end
end

local function eat_cell()
    local cell = App.grid[App.player.row][App.player.col]
    if cell ~= "." and cell ~= "o" then return end

    local px, py = tile_center(App.player.col, App.player.row)
    if sparkle then
        sparkle:moveTo(px, py)
        sparkle:emit(cell == "o" and 16 or 4)
    end

    App.grid[App.player.row][App.player.col] = " "
    App.dots_left = App.dots_left - 1
    if cell == "o" then
        App.score = App.score + 50
        set_frightened()
    else
        App.score = App.score + 10
    end

    if App.dots_left <= 0 then
        advance_level()
    end
end

local function update_player(dt)
    for _, dir in ipairs(DIR_ORDER) do
        if lurek.input.wasActionPressed(dir) or lurek.input.isActionDown(dir) then
            App.player.queued = dir
        end
    end

    App.player.step_timer = App.player.step_timer + dt
    while App.player.step_timer >= App.player.step_time do
        App.player.step_timer = App.player.step_timer - App.player.step_time

        local q_col, q_row = next_cell(App.player.col, App.player.row, App.player.queued)
        if is_walkable(q_col, q_row) then
            App.player.dir = App.player.queued
        end

        local n_col, n_row = next_cell(App.player.col, App.player.row, App.player.dir)
        if is_walkable(n_col, n_row) then
            App.player.col = n_col
            App.player.row = n_row
            eat_cell()
        end
    end
end

local function target_for(hunter, index)
    if App.mode == "scatter" then
        return SCATTER_TARGETS[index].col, SCATTER_TARGETS[index].row
    end

    if hunter.personality == "ambush" then
        local d = DIRS[App.player.dir]
        return wrap_col(App.player.col + d.dx * 3), App.player.row + d.dy * 3
    end
    if hunter.personality == "flank" then
        local d = DIRS[App.player.dir]
        return wrap_col(App.player.col - d.dy * 3), App.player.row + d.dx * 3
    end
    return App.player.col, App.player.row
end

local function bfs_direction(start_col, start_row, target_col, target_row, forbidden_dir)
    local queue = { { col = start_col, row = start_row, first = nil } }
    local seen = { [start_row .. ":" .. start_col] = true }
    local head = 1

    while queue[head] do
        local node = queue[head]
        head = head + 1
        if node.col == target_col and node.row == target_row then
            return node.first
        end

        for _, dir in ipairs(DIR_ORDER) do
            if dir ~= forbidden_dir or node.first ~= nil then
                local n_col, n_row = next_cell(node.col, node.row, dir)
                local key = n_row .. ":" .. n_col
                if not seen[key] and is_walkable(n_col, n_row) then
                    seen[key] = true
                    queue[#queue + 1] = { col = n_col, row = n_row, first = node.first or dir }
                end
            end
        end
    end

    return nil
end

local function frightened_direction(hunter)
    local best_dir = hunter.dir
    local best_score = -math.huge
    for _, dir in ipairs(DIR_ORDER) do
        local n_col, n_row = next_cell(hunter.col, hunter.row, dir)
        if is_walkable(n_col, n_row) then
            local score = dist_sq(n_col, n_row, App.player.col, App.player.row)
            if dir == OPPOSITE[hunter.dir] then score = score - 1 end
            if score > best_score then
                best_score = score
                best_dir = dir
            end
        end
    end
    return best_dir
end

local function update_hunters(dt)
    for index, hunter in ipairs(App.hunters) do
        hunter.step_timer = hunter.step_timer + dt
        while hunter.step_timer >= hunter.step_time do
            hunter.step_timer = hunter.step_timer - hunter.step_time
            local dir
            if App.frightened_timer > 0 then
                dir = frightened_direction(hunter)
            else
                local target_col, target_row = target_for(hunter, index)
                dir = bfs_direction(hunter.col, hunter.row, wrap_col(target_col), math.max(1, math.min(ROWS, target_row)), OPPOSITE[hunter.dir])
            end
            if dir then
                local n_col, n_row = next_cell(hunter.col, hunter.row, dir)
                if is_walkable(n_col, n_row) then
                    hunter.dir = dir
                    hunter.col = n_col
                    hunter.row = n_row
                end
            end
        end
    end
end

local function handle_collisions()
    for _, hunter in ipairs(App.hunters) do
        if hunter.col == App.player.col and hunter.row == App.player.row then
            if App.frightened_timer > 0 then
                App.combo = App.combo + 1
                App.score = App.score + 200 * App.combo
                App.message = "Hunter tagged"
                hunter.col = 10
                hunter.row = 8
                hunter.dir = "up"
                hunter.step_timer = 0
                local px, py = tile_center(hunter.col, hunter.row)
                if sparkle then
                    sparkle:moveTo(px, py)
                    sparkle:emit(24)
                end
            else
                App.lives = App.lives - 1
                if App.lives <= 0 then
                    App.state = "game_over"
                    App.message = "Maze over"
                else
                    App.message = "Caught"
                    reset_positions()
                end
            end
            return
        end
    end
end

function lurek.init()
    lurek.window.setTitle("Maze Chase - Lurek2D")
    lurek.render.setBackgroundColor(0.02, 0.02, 0.05)
    lurek.input.bind("up", { "w", "up" })
    lurek.input.bind("down", { "s", "down" })
    lurek.input.bind("left", { "a", "left" })
    lurek.input.bind("right", { "d", "right" })
    lurek.input.bind("confirm", { "return", "space" })
    lurek.input.bind("restart", { "r" })
    lurek.input.bind("quit", { "escape" })

    sparkle = lurek.particle.newSystem({
        maxParticles = 160,
        emissionRate = 0,
        lifetimeMin = 0.15,
        lifetimeMax = 0.45,
        speedMin = 30,
        speedMax = 120,
        direction = 0,
        spread = math.pi * 2,
        sizes = { 4, 2, 1 },
        colors = {
            { 1.0, 0.95, 0.3, 1 },
            { 0.2, 0.7, 1.0, 0 },
        },
    })

    clone_grid()
end

function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    if lurek.input.wasActionPressed("quit") then
        lurek.event.quit()
        return
    end

    App.pulse = App.pulse + dt
    if sparkle then sparkle:update(dt) end

    if App.state == "title" then
        if lurek.input.wasActionPressed("confirm") then
            reset_game()
        end
        return
    end

    if App.state == "game_over" then
        if lurek.input.wasActionPressed("restart") or lurek.input.wasActionPressed("confirm") then
            reset_game()
        end
        return
    end

    App.mode_timer = App.mode_timer + dt
    if App.mode_timer > 9 then
        App.mode_timer = 0
        App.mode = App.mode == "scatter" and "chase" or "scatter"
    end

    if App.frightened_timer > 0 then
        App.frightened_timer = math.max(0, App.frightened_timer - dt)
        if App.frightened_timer == 0 then
            App.combo = 0
        end
    end

    update_player(dt)
    update_hunters(dt)
    handle_collisions()
end

local function draw_cell(col, row, cell)
    local x = OFFSET_X + (col - 1) * TILE
    local y = OFFSET_Y + (row - 1) * TILE
    if cell == "#" then
        lurek.render.setColor(0.06, 0.16, 0.58, 1)
        lurek.render.rectangle("fill", x + 1, y + 1, TILE - 2, TILE - 2)
        lurek.render.setColor(0.16, 0.38, 1.0, 1)
        lurek.render.rectangle("line", x + 2, y + 2, TILE - 4, TILE - 4)
    elseif cell == "." then
        lurek.render.setColor(1.0, 0.83, 0.46, 1)
        lurek.render.circle("fill", x + TILE / 2, y + TILE / 2, 3)
    elseif cell == "o" then
        local r = 6 + math.sin(App.pulse * 6) * 1.5
        lurek.render.setColor(1.0, 0.92, 0.54, 1)
        lurek.render.circle("fill", x + TILE / 2, y + TILE / 2, r)
    end
end

local function draw_player()
    local x, y = tile_center(App.player.col, App.player.row)
    lurek.render.setColor(1.0, 0.88, 0.18, 1)
    lurek.render.circle("fill", x, y, 10)
    local eye_x = x + (DIRS[App.player.dir].dx * 3)
    local eye_y = y - 4 + (DIRS[App.player.dir].dy * 3)
    lurek.render.setColor(0.02, 0.02, 0.05, 1)
    lurek.render.circle("fill", eye_x, eye_y, 2)
end

local function draw_hunter(hunter)
    local x, y = tile_center(hunter.col, hunter.row)
    local color = hunter.color
    if App.frightened_timer > 0 then
        color = { 0.12, 0.28, 1.0, 1 }
    end
    lurek.render.setColor(color[1], color[2], color[3], 1)
    lurek.render.circle("fill", x, y - 2, 10)
    lurek.render.rectangle("fill", x - 10, y - 2, 20, 12)
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.circle("fill", x - 4, y - 4, 3)
    lurek.render.circle("fill", x + 4, y - 4, 3)
    lurek.render.setColor(0, 0, 0, 1)
    lurek.render.circle("fill", x - 4, y - 4, 1.5)
    lurek.render.circle("fill", x + 4, y - 4, 1.5)
end

function lurek.draw()
    for row = 1, ROWS do
        for col = 1, COLS do
            draw_cell(col, row, App.grid[row][col])
        end
    end

    if App.state == "playing" then
        draw_player()
        for _, hunter in ipairs(App.hunters) do
            draw_hunter(hunter)
        end
    end

    if App.state == "title" then
        lurek.render.setColor(0, 0, 0, 0.72)
        lurek.render.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)
        lurek.render.setColor(1.0, 0.88, 0.18, 1)
        lurek.render.print("MAZE CHASE", 304, 216)
        lurek.render.setColor(0.82, 0.9, 1.0, 1)
        lurek.render.print("Collect every dot. Turn hunters after power cells.", 210, 260)
        lurek.render.print("Press Enter or Space", 314, 306)
    elseif App.state == "game_over" then
        lurek.render.setColor(0, 0, 0, 0.72)
        lurek.render.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)
        lurek.render.setColor(1.0, 0.3, 0.3, 1)
        lurek.render.print("GAME OVER", 330, 250)
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.print("Press R to restart", 312, 292)
    end
end

function lurek.draw_ui()
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.print("Score: " .. tostring(App.score), 24, 22)
    lurek.render.print("Lives: " .. tostring(App.lives), 180, 22)
    lurek.render.print("Level: " .. tostring(App.level), 300, 22)
    lurek.render.print("Dots: " .. tostring(App.dots_left), 420, 22)
    lurek.render.print("Mode: " .. (App.frightened_timer > 0 and "power" or App.mode), 540, 22)
    lurek.render.setColor(0.55, 0.65, 0.8, 1)
    lurek.render.print(App.message, 24, 552)
    lurek.render.print("FPS: " .. tostring(math.floor(lurek.timer.getFPS())), 694, 552)
end
