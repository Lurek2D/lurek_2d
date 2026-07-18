local M = {}

function M.process(state)
    if state.modules.Movement.pressed(state, "pause") or state.modules.Movement.pressed(state, "confirm") then state.phase = "battle" end
    if state.modules.Movement.pressed(state, "restart") then state.modules.Battle.start(state, state.battle.preset_id) end
end

function M.draw(state)
    state.modules.Render.world(state)
    state.modules.Render.hud(state)
    lurek.render.setColor(0.03, 0.04, 0.08, 0.78)
    lurek.render.rectangle("fill", 360, 190, 560, 300)
    state.modules.Render.center_text("PAUSED", 235, 34)
    lurek.render.setColor(0.8, 0.88, 1, 1)
    lurek.render.print("P / ENTER resume     R restart", 475, 390)
    lurek.render.setColor(1, 1, 1, 1)
end

return M
