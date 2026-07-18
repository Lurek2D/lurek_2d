local M = {}

function M.create(state)
    state.ui = {root = nil}
    local layout_path = (state.game_root or "") .. "ui.toml"
    local ok, root = pcall(lurek.ui.loadLayoutGameFile, layout_path)
    if ok then state.ui.root = root end
    return state.ui
end

local function set_text(root, id, value)
    if not root or type(root.findById) ~= "function" then return end
    local ok, widget = pcall(root.findById, root, id)
    if ok and widget and widget.setText then pcall(widget.setText, widget, tostring(value)) end
end

function M.update(state)
    local root = state.ui and state.ui.root
    if not root then return end
    if state.battle then
        local player = state.battle.player
        if player then
            set_text(root, "hud-health", string.format("HP %d/%d", player.hp, player.build.max_health))
            set_text(root, "hud-energy", string.format("EN %d/%d", player.energy, player.build.max_energy))
            set_text(root, "hud-score", "SCORE " .. tostring(state.battle.score or 0))
        end
    end
end

function M.draw(state)
    if lurek.ui and lurek.ui.draw then pcall(lurek.ui.draw) end
end

return M
