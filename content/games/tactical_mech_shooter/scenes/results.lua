local M = {}

function M.process(state)
    if state.modules.Movement.pressed(state, "confirm") then state.phase = "hangar" end
end

function M.draw(state)
    lurek.render.setBackgroundColor(0.03, 0.04, 0.07)
    local battle = state.last_battle or {}
    state.modules.Render.center_text(battle.win and "MISSION COMPLETE" or "MISSION FAILED", 160, 36)
    lurek.render.setColor(0.72, 0.82, 0.94, 1)
    lurek.render.print("SCORE " .. tostring(battle.score or 0), 520, 270)
    lurek.render.print("LEVEL " .. tostring(state.campaign.level) .. "   STARS " .. tostring(state.campaign.stars), 520, 305)
    lurek.render.print("ENTER return to hangar", 520, 420)
    lurek.render.setColor(1, 1, 1, 1)
end

return M
