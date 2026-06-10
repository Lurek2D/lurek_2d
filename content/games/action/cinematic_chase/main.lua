local app = {
    title = "Cinematic Chase",
    genre = "game / cinematic side-scrolling chase",
    modules = { "cinematic", "camera", "tween", "audio", "parallax" },
    notes = {
        "Chase sequence driven by timeline tracks instead of one-off scripts.",
        "This skeleton wires timeline, camera, tweened motion, beat clock, and parallax set.",
        "Next step: add rails, obstacles, and short authored set pieces.",
    },
    report = {},
    t = 0,
    car = { x = 0 },
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
    lurek.render.setBackgroundColor(0.02, 0.04, 0.06)
    record("timeline", function() app.timeline = lurek.cinematic.newTimeline(); return "ready" end)
    record("camera", function() app.camera = lurek.camera.newCamera(0, 0, 1); return "ready" end)
    record("tween state", function() lurek.tween.to(app.car, { x = 180 }, 2.0, "outQuad"); return "ready" end)
    record("beat clock", function() app.clock = lurek.audio.newBeatClock(140, 4); return "ready" end)
    record("parallax set", function() app.parallax = lurek.parallax.newSet(); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    pcall(lurek.tween.update, dt)
    if lurek.input.keyboard.isDown("escape") then lurek.event.quit() end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.02, 0.04, 0.06, 1)
    for i = 1, 6 do
        lurek.render.setColor(0.06 + i * 0.03, 0.14 + i * 0.02, 0.22 + i * 0.02, 1)
        lurek.render.rectangle("fill", 30 + i * 126, 86 + math.sin(app.t * 1.1 + i) * 12, 82, h - 166)
    end
    lurek.render.setColor(0.95, 0.96, 0.98, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.60, 0.84, 0.96, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.84, 0.88, 0.92)
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
