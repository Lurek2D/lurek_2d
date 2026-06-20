local M = {}
function M.new(config)
    return { bpm = 120, playing = true, cursor = 0, selected_pitch = 5, notes = { {step=2,pitch=5,len=2}, {step=6,pitch=8,len=1}, {step=10,pitch=3,len=3} } }
end
function M.toggle_note(app, step, pitch)
    for i, n in ipairs(app.notes) do
        if n.step == step and n.pitch == pitch then table.remove(app.notes, i); return end
    end
    app.notes[#app.notes + 1] = { step = step, pitch = pitch, len = 1 }
end
function M.update(app, dt)
    if app.playing then app.cursor = (app.cursor + dt * app.bpm / 15) % 16 end
end
return M
