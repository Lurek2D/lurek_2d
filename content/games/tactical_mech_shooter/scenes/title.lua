local M = {}

function M.process(state)
    if state.modules.Movement.pressed(state, "confirm") then state.phase = "hangar" end
end

function M.draw(state)
    lurek.render.setBackgroundColor(0.025, 0.035, 0.07)
    state.modules.Render.center_text("TACTICAL MECH", 150, 46)
    state.modules.Render.center_text("STAR CONTROL // METAL FATIGUE // LUREK2D", 220, 16)
    lurek.render.setColor(0.24, 0.7, 1, 1)
    lurek.render.polygon("fill", 490, 320, 640, 260, 790, 320, 640, 430)
    lurek.render.setColor(0.05, 0.08, 0.16, 1)
    lurek.render.circle("fill", 640, 333, 34)
    state.modules.Render.center_text("PRESS ENTER / SPACE / CLICK // OPEN HANGAR", 540, 20)
    lurek.render.setColor(1, 1, 1, 1)
end

return M
