local M = {}

function M.create(state, model)
    local mm = lurek.minimap.newMinimap(model.width, model.height, 190, 190)
    mm:setTerrainColor(1, 0.16, 0.42, 0.14, 1)
    mm:setTerrainColor(2, 0.72, 0.58, 0.20, 1)
    mm:setTerrainColor(3, 0.10, 0.32, 0.72, 1)
    mm:setTerrainColor(4, 0.30, 0.32, 0.35, 1)
    mm:setTerrainColor(5, 0.65, 0.42, 0.16, 1)
    mm:setFogColor(0, 0, 0, 0.78)
    mm:setFogEnabled(true)
    mm:setFogData((function()
        local hidden = {}
        for i = 1, model.width * model.height do hidden[i] = 0 end
        return hidden
    end)())
    local terrain = {}
    for i, tile in ipairs(model.tiles) do
        terrain[i] = tile == "sand" and 2 or (tile == "water" and 3 or ((tile == "wall") and 4 or (tile == "door_closed" and 5 or 1)))
    end
    mm:setTerrainData(terrain)
    model.minimap = mm
    model.minimap_visible = {}
    return model
end

function M.update(state)
    local model = state.battle and state.battle.model
    if not model or not model.minimap then return end
    local player = state.battle.player
    if player then
        local cx, cy = model.world.cell(model, player.x, player.y)
        model.minimap:setCenter(cx, cy)
    end
    local team = player and player.team or "team1"
    for key in pairs(model.minimap_visible) do
        local x = ((key - 1) % model.width) + 1
        local y = math.floor((key - 1) / model.width) + 1
        model.minimap:setFogLevel(x, y, 1)
    end
    local visible = model.visible_cells[team] or {}
    for key in pairs(visible) do
        local x = ((key - 1) % model.width) + 1
        local y = math.floor((key - 1) / model.width) + 1
        model.minimap:setFogLevel(x, y, 2)
    end
    model.minimap_visible = visible
end

function M.draw(state)
    local model = state.battle and state.battle.model
    if not model or not model.minimap then return end
    model.minimap:render(lurek.window.getWidth() - 210, 48)
end

return M
