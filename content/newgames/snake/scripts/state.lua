local M = {}

M.STATUS = { TITLE = "title", PLAYING = "playing", DEAD = "dead" }

local function occupied(game, x, y)
    for _, seg in ipairs(game.snake) do
        if seg.x == x and seg.y == y then return true end
    end
    for _, food in ipairs(game.food) do
        if food.x == x and food.y == y then return true end
    end
    return false
end

local function spawn_food(game)
    local attempts = 0
    while #game.food < game.config.rules.food_count and attempts < 1000 do
        local x = math.random(0, game.config.grid.cols - 1)
        local y = math.random(0, game.config.grid.rows - 1)
        if not occupied(game, x, y) then game.food[#game.food + 1] = { x = x, y = y } end
        attempts = attempts + 1
    end
end

function M.new(config)
    return {
        config = config,
        status = M.STATUS.TITLE,
        snake = {},
        food = {},
        dir = { x = 1, y = 0 },
        next_dir = { x = 1, y = 0 },
        score = 0,
        high_score = 0,
        speed = config.rules.base_speed,
        timer = 0,
    }
end

function M.start(game)
    local mx = math.floor(game.config.grid.cols / 2)
    local my = math.floor(game.config.grid.rows / 2)
    game.snake = {}
    for i = 4, 1, -1 do
        game.snake[#game.snake + 1] = { x = mx - i + 1, y = my }
    end
    game.food = {}
    game.dir = { x = 1, y = 0 }
    game.next_dir = { x = 1, y = 0 }
    game.score = 0
    game.speed = game.config.rules.base_speed
    game.timer = 0
    game.status = M.STATUS.PLAYING
    spawn_food(game)
end

function M.set_dir(game, x, y)
    if game.status ~= M.STATUS.PLAYING then return end
    if game.dir.x + x == 0 and game.dir.y + y == 0 then return end
    game.next_dir = { x = x, y = y }
end

function M.update(game, dt, effects, audio)
    if game.status ~= M.STATUS.PLAYING then return end
    game.timer = game.timer + dt
    if game.timer < 1 / game.speed then return end
    game.timer = game.timer - 1 / game.speed
    game.dir = { x = game.next_dir.x, y = game.next_dir.y }

    local head = game.snake[#game.snake]
    local nx = (head.x + game.dir.x) % game.config.grid.cols
    local ny = (head.y + game.dir.y) % game.config.grid.rows

    for i = 1, #game.snake - 1 do
        if game.snake[i].x == nx and game.snake[i].y == ny then
            game.status = M.STATUS.DEAD
            game.high_score = math.max(game.high_score, game.score)
            audio.play("death")
            return
        end
    end

    game.snake[#game.snake + 1] = { x = nx, y = ny }
    local ate = false
    for i, food in ipairs(game.food) do
        if food.x == nx and food.y == ny then
            table.remove(game.food, i)
            game.score = game.score + 1
            game.speed = game.config.rules.base_speed + math.floor(game.score / game.config.rules.speed_every) * game.config.rules.speed_step
            effects.eat(nx, ny)
            audio.play("eat")
            spawn_food(game)
            ate = true
            break
        end
    end
    if not ate then table.remove(game.snake, 1) end
end

return M
