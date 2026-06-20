local app = {
    title = "Localization Dialog Studio",
    genre = "app / narrative localization tool",
    modules = { "i18n", "dialog", "grep", "html", "save" },
    notes = {
        "Author translated branching dialog and inspect key coverage.",
        "This skeleton covers i18n table, dialog state, grep engine, HTML preview, and save manager.",
        "Next step: add translation grid, dialog tree preview, and key search.",
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
    lurek.render.setBackgroundColor(0.04, 0.03, 0.03)
    record("i18n table", function() lurek.i18n.loadTable("en", { hello = "Hello" }); return lurek.i18n.t("hello") end)
    record("dialog", function() app.dialog = lurek.dialog.newState(); return "ready" end)
    record("grep", function() app.grep = lurek.grep.newEngine(); return "ready" end)
    record("html", function() app.doc = lurek.html.newDocument("<body><p>Dialog</p></body>", { width = 320, height = 160 }); return "ready" end)
    record("save", function() app.save = lurek.save.newSaveManager(); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    if lurek.input.keyboard.isDown("escape") then lurek.event.quit() end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.04, 0.03, 0.03, 1)
    for i = 1, 6 do
        lurek.render.setColor(0.14 + i * 0.02, 0.10 + i * 0.01, 0.10 + i * 0.01, 1)
        lurek.render.rectangle("fill", 30 + i * 126, 88 + math.sin(app.t + i) * 10, 82, h - 166)
    end
    lurek.render.setColor(0.96, 0.94, 0.94, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.94, 0.72, 0.72, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.90, 0.86, 0.86)
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
