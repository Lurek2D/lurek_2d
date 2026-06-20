local function load_module(path)
    local chunk = lurek.filesystem.load(path)
    assert(type(chunk) == "function", "cannot load " .. path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

local modules = {
    config = load_module("scripts/config.lua"),
    input = load_module("scripts/input.lua"),
    audio = load_module("scripts/audio.lua"),
    state = load_module("scripts/state.lua"),
    renderer = load_module("scripts/renderer.lua"),
    ui = load_module("scripts/ui.lua"),
}

local game = nil
local intent = nil

local function should_autostart_for_screenshot()
    if not lurek.runtime or not lurek.runtime.getArgs then
        return false
    end
    local args = lurek.runtime.getArgs()
    for _, arg in ipairs(args) do
        if string.find(tostring(arg), "--screenshot", 1, true) then
            return true
        end
    end
    return false
end

function lurek.init()
    lurek.window.setTitle(modules.config.TITLE)
    lurek.render.setBackgroundColor(0.03, 0.04, 0.06)

    modules.input.bind()
    local audio = modules.audio.new(modules.config)
    game = modules.state.new(modules.config, audio)
    intent = modules.input.new_intent()

    modules.renderer.load(modules.config)
    modules.ui.load(modules.config)

    if should_autostart_for_screenshot() then
        modules.state.start(game)
    end
end

function lurek.process(dt)
    if lurek.automation then
        lurek.automation.update(dt)
    end

    modules.input.update_intent(intent)
    if intent.quit then
        lurek.event.quit()
        return
    end

    modules.state.update(game, intent, dt)
    modules.ui.update(game)
end

function lurek.draw()
    modules.renderer.draw(game)
end

function lurek.draw_ui()
    modules.ui.draw_fallback(game)
end

function sector_runner_debug()
    return modules.state.debug_snapshot(game)
end
