local state = require("state")

local M = { refs = {} }

local function empty_node()
    return { visible = false, text = "", color = { 1, 1, 1, 1 }, setOnClick = function() end }
end

local function find(root, id)
    if root and root.findById then
        local ok, node = pcall(function() return root:findById(id) end)
        if ok and node then return node end
    end
    return empty_node()
end

function M.load(config, game, start_game)
    pcall(lurek.ui.loadLayoutFile, config.ui)
    local root = lurek.ui.getRoot and lurek.ui.getRoot() or nil
    M.refs.title = find(root, "title_screen")
    M.refs.hud = find(root, "hud")
    M.refs.game_over = find(root, "game_over_screen")
    M.refs.score = find(root, "score_label")
    M.refs.level = find(root, "level_label")
    M.refs.lines = find(root, "lines_label")
    M.refs.hold_empty = find(root, "hold_empty_label")
    M.refs.fps = find(root, "fps_label")
    M.refs.final_score = find(root, "final_score")
    M.refs.final_level = find(root, "final_level")
    M.refs.final_lines = find(root, "final_lines")
    M.refs.press_start = find(root, "press_start")
    M.refs.press_restart = find(root, "press_restart")
    M.refs.press_start:setOnClick(start_game)
    M.refs.press_restart:setOnClick(start_game)
    M.sync(game)
end

function M.sync(game)
    local refs = M.refs
    refs.title.visible = game.status == state.STATUS.TITLE
    refs.hud.visible = game.status ~= state.STATUS.TITLE
    refs.game_over.visible = game.status == state.STATUS.GAME_OVER
    refs.score.text = tostring(game.score)
    refs.level.text = tostring(game.level)
    refs.lines.text = tostring(game.lines)
    refs.hold_empty.visible = not game.hold
    refs.fps.text = "FPS: " .. tostring(math.floor(lurek.timer.getFPS()))
    if game.status == state.STATUS.GAME_OVER then
        refs.final_score.text = "Score: " .. tostring(game.score)
        refs.final_level.text = "Level: " .. tostring(game.level)
        refs.final_lines.text = "Lines: " .. tostring(game.lines)
    end
end

return M
