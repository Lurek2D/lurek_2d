local board = require("board")
local pieces = require("pieces")

local M = {}

M.STATUS = { TITLE = "title", PLAYING = "playing", GAME_OVER = "game_over" }
local LINE_SCORES = { 100, 300, 500, 800 }

local function spawn(game)
    game.current = pieces.copy(game.next or pieces.random())
    game.next = pieces.random()
    game.x = math.floor(game.board.cols / 2) - 1
    game.y = -1
    game.drop_timer = 0
    game.lock_timer = 0
    if board.collides(game.board, game.current, game.x, game.y) then
        game.status = M.STATUS.GAME_OVER
    end
end

function M.new(config)
    return {
        config = config,
        status = M.STATUS.TITLE,
        board = board.new(config),
        score = 0,
        level = 1,
        lines = 0,
        drop_interval = config.timing.start_drop,
        drop_timer = 0,
        lock_timer = 0,
        hold = nil,
        hold_used = false,
        current = nil,
        next = pieces.random(),
    }
end

function M.start(game)
    game.board = board.new(game.config)
    game.score = 0
    game.level = 1
    game.lines = 0
    game.drop_interval = game.config.timing.start_drop
    game.drop_timer = 0
    game.lock_timer = 0
    game.hold = nil
    game.hold_used = false
    game.next = pieces.random()
    game.status = M.STATUS.PLAYING
    spawn(game)
end

function M.move(game, dx, audio)
    if game.status ~= M.STATUS.PLAYING then return end
    if not board.collides(game.board, game.current, game.x + dx, game.y) then
        game.x = game.x + dx
        audio.play("move")
    end
end

function M.rotate(game, audio)
    if game.status ~= M.STATUS.PLAYING then return end
    local rotated = pieces.rotate(game.current)
    local kicks = { 0, 1, -1, 2, -2 }
    for _, kick in ipairs(kicks) do
        if not board.collides(game.board, rotated, game.x + kick, game.y) then
            game.current = rotated
            game.x = game.x + kick
            audio.play("rotate")
            return
        end
    end
end

local function lock_current(game, effects, audio)
    if not board.lock(game.board, game.current, game.x, game.y) then
        game.status = M.STATUS.GAME_OVER
        return
    end
    local cleared = board.clear_lines(game.board)
    if #cleared > 0 then
        game.score = game.score + (LINE_SCORES[#cleared] or 800) * game.level
        game.lines = game.lines + #cleared
        game.level = math.floor(game.lines / 10) + 1
        game.drop_interval = math.max(game.config.timing.min_drop, game.config.timing.start_drop - (game.level - 1) * 0.045)
        effects.line_clear(cleared)
        audio.play("clear")
    else
        audio.play("lock")
    end
    game.hold_used = false
    spawn(game)
end

function M.hard_drop(game, effects, audio)
    if game.status ~= M.STATUS.PLAYING then return end
    game.y = board.ghost_y(game.board, game.current, game.x, game.y)
    lock_current(game, effects, audio)
end

function M.hold(game)
    if game.status ~= M.STATUS.PLAYING or game.hold_used then return end
    game.hold_used = true
    if game.hold then
        local held = game.hold
        game.hold = pieces.copy(game.current)
        game.current = held
        game.x = math.floor(game.board.cols / 2) - 1
        game.y = -1
        game.drop_timer = 0
        game.lock_timer = 0
    else
        game.hold = pieces.copy(game.current)
        spawn(game)
    end
end

function M.update(game, dt, effects, audio)
    if game.status ~= M.STATUS.PLAYING then return end
    local scale = lurek.input.isActionDown("soft_drop") and game.config.timing.soft_drop_scale or 1
    game.drop_timer = game.drop_timer + dt * scale
    if game.drop_timer < game.drop_interval then return end
    game.drop_timer = 0
    if not board.collides(game.board, game.current, game.x, game.y + 1) then
        game.y = game.y + 1
        game.lock_timer = 0
    else
        game.lock_timer = game.lock_timer + game.drop_interval
        if game.lock_timer >= game.config.timing.lock_delay then
            lock_current(game, effects, audio)
        end
    end
end

function M.ghost_y(game)
    return board.ghost_y(game.board, game.current, game.x, game.y)
end

return M
