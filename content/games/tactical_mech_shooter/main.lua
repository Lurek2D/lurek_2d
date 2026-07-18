local App = {state = nil}

local function has_screenshot_arg()
    if not (lurek.system and lurek.system.getArgs) then return false end
    local ok, args = pcall(lurek.system.getArgs)
    if not ok or type(args) ~= "table" then return false end
    for _, value in pairs(args) do
        if type(value) == "string" and value:find("^%-%-screenshot") then return true end
    end
    return false
end

-- Evidence runs can request a scene before the first rendered frame.  The
-- command-line eval hook is backend-dependent, so also accept a short-lived
-- marker file placed next to the game during capture.  Normal gameplay has no
-- marker and always starts on the title scene.
local function requested_screen()
    local mode = rawget(_G, "TACTICAL_SCREEN")
    if mode == "hangar" or mode == "battle" then return mode end
    for _, path in ipairs({
        "screenshot_mode.txt",
        "work/tactical-mech-shooter/screenshot_mode.txt",
        "../../../work/tactical-mech-shooter/screenshot_mode.txt",
    }) do
        local ok, marker = pcall(lurek.filesystem.read, path)
        if ok and type(marker) == "string" then
            marker = marker:gsub("%s+", "")
            if marker == "hangar" or marker == "battle" then return marker end
        end
    end
    if has_screenshot_arg() then return "battle" end
    return nil
end

local function apply_requested_screen(state)
    if App.screen_started then return end
    local mode = requested_screen()
    if mode == "hangar" then
        state.phase = "hangar"
    elseif mode == "battle" then
        state.modules.Battle.start(state, "f1")
    else
        return
    end
    App.screen_started = true
end

function lurek.init()
    lurek.window.setTitle("Tactical Mech Shooter // Lurek2D")
    lurek.render.setBackgroundColor(0.025, 0.035, 0.07)
    -- The game uses the engine's bundled bitmap atlas at exactly 10 px for
    -- both world text and retained UI. This avoids backend-dependent font
    -- fallback and keeps the retro HUD grid stable.
    local bitmap_font = lurek.render.setDefaultFont(10)
    local BootstrapChunk = lurek.filesystem.load("app/bootstrap.lua")
    assert(type(BootstrapChunk) == "function", "bootstrap loader missing")
    local bootstrap = BootstrapChunk()
    assert(type(bootstrap) == "table" and type(bootstrap.load) == "function", "bootstrap module missing")
    App.state = bootstrap.load()
    App.state.modules.Movement.bind()
    App.state.modules.UI.create(App.state)
    pcall(lurek.ui.setFont, bitmap_font)
    apply_requested_screen(App.state)
    if rawget(_G, "TACTICAL_SMOKE") then
        App.state.modules.Battle.start(App.state, "f1")
        App.smoke_started = true
    end
end

function lurek.process(dt)
    local state = App.state
    if not state then return end
    -- The eval flag may be installed after init by the GUI smoke runner; pick
    -- it up on the first process tick as well so battle rendering is tested.
    if rawget(_G, "TACTICAL_SMOKE") and not App.smoke_started then
        state.modules.Battle.start(state, "f1")
        App.smoke_started = true
    end
    -- Screenshot/evidence mode can request a real in-game surface instead of
    -- the title card. The flag is picked up after init as well as before it.
    apply_requested_screen(state)
    if state.phase == "title" then
        state.modules.Title.process(state)
    elseif state.phase == "hangar" then
        state.modules.Hangar.process(state)
    elseif state.phase == "battle" then
        state.modules.Battle.process(state, dt)
    elseif state.phase == "pause" then
        state.modules.Pause.process(state)
    elseif state.phase == "results" then
        state.modules.Results.process(state)
    end
    if lurek.tween and lurek.tween.update then pcall(lurek.tween.update, dt) end
end

function lurek.process_physics(dt)
    local state = App.state
    if state and state.phase == "battle" then state.modules.Battle.process_physics(state, dt) end
end

function lurek.draw()
    local state = App.state
    if not state then return end
    if state.phase == "title" then
        state.modules.Title.draw(state)
    elseif state.phase == "hangar" then
        state.modules.Hangar.draw(state)
    elseif state.phase == "battle" then
        state.modules.Battle.draw(state)
    elseif state.phase == "pause" then
        state.modules.Pause.draw(state)
    elseif state.phase == "results" then
        state.modules.Results.draw(state)
    end
end

function lurek.draw_ui()
    local state = App.state
    if not state then return end
    if state.phase == "battle" or state.phase == "pause" then
        state.modules.Battle.draw_ui(state)
    end
end

function lurek.resize(width, height)
    local state = App.state
    local model = state and state.battle and state.battle.model
    if model and model.camera then
        -- Resize callbacks may provide physical pixels while Lua rendering
        -- and HUD coordinates stay in the logical game viewport.
        local logical_w, logical_h = lurek.window.getWidth(), lurek.window.getHeight()
        pcall(model.camera.setViewport, model.camera, 0, 0, logical_w, logical_h)
    end
end

return App
