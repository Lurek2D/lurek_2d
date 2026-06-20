local M = {}
function M.bind(config)
    lurek.input.bind("up", {"up", "w"})
    lurek.input.bind("down", {"down", "s"})
    lurek.input.bind("left", {"left", "a"})
    lurek.input.bind("right", {"right", "d"})
    lurek.input.bind("confirm", {"space", "return"})
    lurek.input.bind("clear", {"c"})
    lurek.input.bind("quit", {"escape"})
end
function M.update(app, dt)
    if lurek.input.wasActionPressed("quit") then lurek.event.quit(); return end
    if app.display then
        if lurek.input.wasActionPressed("clear") then app.press_key = "c" end
        if app.press_key and app.press then app.press(app, app.press_key); app.press_key = nil end
    end
    if app.filter_min and lurek.input.wasActionPressed("up") then app.filter_min = app.filter_min + 500 end
    if app.filter_min and lurek.input.wasActionPressed("down") then app.filter_min = math.max(0, app.filter_min - 500) end
    if app.bpm and lurek.input.wasActionPressed("left") then app.bpm = math.max(60, app.bpm - 5) end
    if app.bpm and lurek.input.wasActionPressed("right") then app.bpm = math.min(180, app.bpm + 5) end
    if app.rate and lurek.input.wasActionPressed("left") then app.rate = math.max(0, app.rate - 10); app.particles:setEmissionRate(app.rate) end
    if app.rate and lurek.input.wasActionPressed("right") then app.rate = math.min(240, app.rate + 10); app.particles:setEmissionRate(app.rate) end
    if app.playing ~= nil and lurek.input.wasActionPressed("confirm") then app.playing = not app.playing end
end
function M.keypressed(app, key)
    if app.display and app.press then
        if key == "return" then key = "=" end
        if key == "backspace" or key == "delete" then key = "c" end
        if key:match("^[0-9%+%-%*/=c]$") then app.press(app, key) end
    elseif app.notes and tonumber(key) then
        local step = math.max(1, math.min(16, math.floor(app.cursor) + 1))
        local pitch = math.max(1, math.min(10, tonumber(key)))
        if app.toggle_note then app.toggle_note(app, step, pitch) end
    end
end
return M
