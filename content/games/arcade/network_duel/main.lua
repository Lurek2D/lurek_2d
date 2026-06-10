local app = {
    title = "Network Duel",
    genre = "game / loopback multiplayer arcade",
    modules = { "network", "serial", "scene", "automation" },
    notes = {
        "Deterministic duel for packet state, snapshots, replay, and reconciliation.",
        "This skeleton stays offline-first and smoke-safe.",
        "Next step: add two local players and predicted versus corrected state.",
    },
    report = {},
    t = 0,
}

local function record(label, fn)
    local ok, value = pcall(fn)
    app.report[#app.report + 1] = { label = label, ok = ok, text = ok and tostring(value or "ok") or tostring(value) }
end

local function draw_text(lines, x, y, r, g, b)
    lurek.render.setColor(r, g, b, 1)
    for i = 1, #lines do lurek.render.print(lines[i], x, y + (i - 1) * 18) end
end

function lurek.init()
    lurek.window.setTitle(app.title .. " - Lurek2D")
    lurek.window.windowConfig({ width = 960, height = 540, scaleMode = "none", vsync = 1 })
    lurek.render.setBackgroundColor(0.03, 0.03, 0.05)
    record("network state", function() app.net = lurek.network.newNetState(); return "ready" end)
    record("serial snapshot", function() app.snapshot = lurek.serial.toJson({ x = 10, y = 20, hp = 3 }); return app.snapshot end)
    record("scene stack", function() app.scene = lurek.scene.new({ name = "duel" }); lurek.scene.clear(); lurek.scene.push(app.scene); return "ready" end)
    record("automation speed", function() lurek.automation.setPlaybackSpeed(1.0); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    if lurek.input.keyboard.isDown("escape") then lurek.event.quit() end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.03, 0.03, 0.05, 1)
    for i = 1, 6 do
        lurek.render.setColor(0.10 + i * 0.03, 0.12 + i * 0.02, 0.24 + i * 0.03, 1)
        lurek.render.rectangle("fill", 32 + i * 126, 90 + math.sin(app.t * 1.1 + i) * 12, 82, h - 168)
    end
    lurek.render.setColor(0.94, 0.95, 0.96, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.66, 0.76, 0.96, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.84, 0.86, 0.90)
    draw_text(app.modules, 42, h - 88, 0.92, 0.82, 0.42)
    for i = 1, #app.report do
        local item = app.report[i]
        local c = item.ok and { 0.38, 0.90, 0.55 } or { 0.95, 0.42, 0.38 }
        lurek.render.setColor(c[1], c[2], c[3], 1)
        lurek.render.print((item.ok and "OK " or "ERR ") .. item.label, w - 280, 118 + (i - 1) * 18)
    end
end

function lurek.draw_ui()
end
