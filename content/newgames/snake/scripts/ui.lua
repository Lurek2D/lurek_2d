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
    M.refs.hud = find(root, "hud")
    M.refs.title = find(root, "title_screen")
    M.refs.game_over = find(root, "game_over_screen")
    M.refs.score = find(root, "score_label")
    M.refs.best = find(root, "high_score_label")
    M.refs.fps = find(root, "fps_label")
    M.refs.final = find(root, "final_score")
    M.refs.new_best = find(root, "new_best")
    M.refs.start = find(root, "press_start")
    M.refs.restart = find(root, "press_restart")
    M.refs.start:setOnClick(start_game)
    M.refs.restart:setOnClick(start_game)
    M.sync(game)
end

function M.sync(game)
    M.refs.hud.visible = true
    M.refs.title.visible = game.status == state.STATUS.TITLE
    M.refs.game_over.visible = game.status == state.STATUS.DEAD
    M.refs.score.text = "Score: " .. tostring(game.score)
    M.refs.best.text = "Best: " .. tostring(game.high_score)
    M.refs.fps.text = "FPS: " .. tostring(math.floor(lurek.timer.getFPS()))
    M.refs.final.text = "Score: " .. tostring(game.score)
    M.refs.new_best.visible = game.status == state.STATUS.DEAD and game.score >= game.high_score and game.score > 0
end

return M
