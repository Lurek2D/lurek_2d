local state = require("state")

local M = { refs = {} }

local function empty()
    return { visible = false, text = "", color = { 1, 1, 1, 1 }, setOnClick = function() end }
end

local function find(root, id)
    if root and root.findById then
        local ok, node = pcall(function() return root:findById(id) end)
        if ok and node then return node end
    end
    return empty()
end

function M.load(config, game, start_game)
    pcall(lurek.ui.loadLayoutFile, config.ui)
    local root = lurek.ui.getRoot and lurek.ui.getRoot() or nil
    M.refs.title = find(root, "title_screen")
    M.refs.hud = find(root, "hud")
    M.refs.game_over = find(root, "game_over_screen")
    M.refs.score = find(root, "score_label")
    M.refs.wave = find(root, "wave_label")
    M.refs.lives = find(root, "lives_label")
    M.refs.fps = find(root, "fps_label")
    M.refs.final_score = find(root, "final_score_label")
    M.refs.final_wave = find(root, "final_wave_label")
    M.refs.start = find(root, "press_enter_label")
    M.refs.start:setOnClick(start_game)
    M.sync(game)
end

function M.sync(game)
    M.refs.title.visible = game.status == state.STATUS.TITLE
    M.refs.hud.visible = game.status ~= state.STATUS.TITLE
    M.refs.game_over.visible = game.status == state.STATUS.GAME_OVER
    M.refs.score.text = "SCORE  " .. tostring(game.score)
    M.refs.wave.text = "WAVE " .. tostring(game.wave)
    M.refs.lives.text = "LIVES " .. tostring(game.lives)
    M.refs.fps.text = "FPS: " .. tostring(math.floor(lurek.timer.getFPS()))
    if game.status == state.STATUS.GAME_OVER then
        M.refs.final_score.text = "Final Score: " .. tostring(game.score)
        M.refs.final_wave.text = "Wave: " .. tostring(game.wave)
    end
end

return M
