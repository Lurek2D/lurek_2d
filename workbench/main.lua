local function load_module(path)
    local chunk = lurek.filesystem.load(path)
    assert(type(chunk) == "function", "cannot load " .. path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

local State = load_module("app/state.lua")
local Registry = load_module("app/editor_registry.lua")
local Shell = load_module("app/shell.lua")
local CommandBus = load_module("app/command_bus.lua")
local ProjectIndex = load_module("app/services/project_index.lua")
local DocumentService = load_module("app/services/document_service.lua")

local app = {
    ready = false,
    shell = nil,
}

local function apply_window_defaults()
    lurek.window.windowConfig({
        title = "Lurek Workbench",
        width = 1600,
        height = 900,
        fullscreen = false,
        vsync = 1,
        scaleMode = "none",
    })
    if lurek.window.maximize then lurek.window.maximize() end
    lurek.window.focus()
    lurek.render.setBackgroundColor(0.025, 0.028, 0.034)
end

function lurek.init()
    apply_window_defaults()
    local registry = Registry.create(load_module)
    local services = {
        commands = CommandBus.create(),
        projects = ProjectIndex.create(),
        documents = DocumentService.create(registry),
    }
    app.shell = Shell.create(State.create(registry, services))
    app.ready = true
    app.shell:log("info", "Lurek Workbench ready")
end

function lurek.process(dt)
    if not app.ready or not app.shell then return end
    app.shell:update(dt or 0)
end

function lurek.draw()
    if not app.ready or not app.shell then return end
    app.shell:draw()
end

function lurek.keypressed(key)
    if not app.ready or not app.shell then return false end
    return app.shell:keypressed(key)
end

function lurek.textinput(text)
    if not app.ready or not app.shell then return false end
    return app.shell:textinput(text)
end

function lurek.mousepressed(x, y, button)
    if not app.ready or not app.shell then return false end
    return app.shell:mousepressed(x, y, button or 1)
end

function lurek.mousereleased(x, y, button)
    if not app.ready or not app.shell then return false end
    return app.shell:mousereleased(x, y, button or 1)
end

function lurek.mousemoved(x, y)
    if not app.ready or not app.shell then return false end
    return app.shell:mousemoved(x, y)
end

function lurek.wheelmoved(x, y)
    if not app.ready or not app.shell then return false end
    return app.shell:wheelmoved(x, y)
end

function lurek.resize(width, height)
    if app.ready and app.shell then
        app.shell:resize(width, height)
    end
end
