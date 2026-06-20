local app = {
    title = "Physics Arena",
    genre = "game / physics sports arena",
    modules = { "physics", "audio", "particle", "camera" },
    notes = {
        "One larger sports demo for mini-golf, pinball, and power-shot trials.",
        "This skeleton already builds a Rapier world, ball, ground, audio clock, and particles.",
        "Next step: add arena modes, scoring, and tuned collision materials.",
    },
    report = {},
    t = 0,
}

local function record(label, fn)
    local ok, value = pcall(fn)
    app.report[#app.report + 1] = {
        label = label,
        ok = ok,
        text = ok and tostring(value or "ok") or tostring(value),
    }
end

local function draw_text(lines, x, y, r, g, b)
    lurek.render.setColor(r, g, b, 1)
    for i = 1, #lines do
        lurek.render.print(lines[i], x, y + (i - 1) * 18)
    end
end

function lurek.init()
    lurek.window.setTitle(app.title .. " - Lurek2D")
    lurek.window.windowConfig({ width = 960, height = 540, scaleMode = "none", vsync = 1 })
    lurek.render.setBackgroundColor(0.03, 0.04, 0.06)

    record("physics world", function()
        app.world = lurek.physics.newWorld(0, 520)
        app.ground = lurek.physics.newBody(app.world, 480, 484, "static")
        lurek.physics.attachShape(app.ground, lurek.physics.newRectangleShape(820, 20))
        app.ball = lurek.physics.newBody(app.world, 180, 110, "dynamic")
        lurek.physics.attachShape(app.ball, lurek.physics.newCircleShape(14))
        return "ready"
    end)
    record("audio beat clock", function() app.clock = lurek.audio.newBeatClock(122, 4); return "ready" end)
    record("particle system", function() app.particles = lurek.particle.newSystem({ max = 96 }); return "ready" end)
    record("camera", function() app.camera = lurek.camera.newCamera(0, 0, 1); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    if app.world then
        pcall(lurek.physics.step, app.world, dt)
    end
    if lurek.input.keyboard.isDown("escape") then
        lurek.event.quit()
    end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.03, 0.04, 0.06, 1)

    for i = 1, 6 do
        lurek.render.setColor(0.08 + i * 0.03, 0.16 + i * 0.02, 0.24 + i * 0.02, 1)
        lurek.render.rectangle("fill", 24 + i * 120, 86 + math.sin(app.t + i) * 16, 84, h - 160)
    end

    lurek.render.setColor(0.92, 0.94, 0.96, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.60, 0.74, 0.88, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.82, 0.88, 0.84)
    draw_text(app.modules, 42, h - 88, 0.90, 0.82, 0.42)

    for i = 1, #app.report do
        local item = app.report[i]
        local c = item.ok and { 0.38, 0.90, 0.55 } or { 0.95, 0.42, 0.38 }
        lurek.render.setColor(c[1], c[2], c[3], 1)
        lurek.render.print((item.ok and "OK " or "ERR ") .. item.label, w - 280, 118 + (i - 1) * 18)
    end
end

function lurek.draw_ui()
end
