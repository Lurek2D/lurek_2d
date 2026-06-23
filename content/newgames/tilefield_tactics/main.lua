local function load_system(name)
    local path = "systems/" .. name .. ".lua"
    local chunk = lurek.filesystem.load(path)
    assert(type(chunk) == "function", "cannot load " .. path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

local FieldSystem = load_system("field")
local VisibilitySystem = load_system("visibility")
local MovementSystem = load_system("movement")
local LightingSystem = load_system("lighting")
local RenderSystem = load_system("render")

local App = {
    selected = "p1",
    turn = 1,
    message = "Tilefield Tactics",
}

local function bind_inputs()
    lurek.input.bind("up", { "w", "up" })
    lurek.input.bind("down", { "s", "down" })
    lurek.input.bind("left", { "a", "left" })
    lurek.input.bind("right", { "d", "right" })
    lurek.input.bind("level_up", { "e" })
    lurek.input.bind("level_down", { "q" })
    lurek.input.bind("player", { "tab" })
    lurek.input.bind("door", { "space" })
    lurek.input.bind("restart", { "r" })
    lurek.input.bind("quit", { "escape" })
end

local function rebuild()
    App.model = FieldSystem.create()
    LightingSystem.compute(App.model)
    VisibilitySystem.compute(App.model)
    MovementSystem.compute(App.model)
    RenderSystem.prepare(App.model)
    App.selected = "p1"
    App.message = "Shared field drives all systems"
end

local function selected_unit()
    return App.model.units[App.selected]
end

local function try_move(dx, dy)
    local unit = selected_unit()
    local nx, ny = unit.x + dx, unit.y + dy
    if not App.model.field:inBounds(nx, ny, unit.z) then
        App.message = "Out of bounds"
        return
    end
    if App.model.field:blocks(nx, ny, unit.z, "move") then
        local profiles = App.model.field:exportProfileLayer(unit.z)
        App.message = "Movement blocked by " .. tostring(profiles[(ny - 1) * App.model.width + nx])
        return
    end
    unit.x, unit.y = nx, ny
    App.message = App.selected .. " moved to " .. nx .. "," .. ny .. "," .. unit.z
    LightingSystem.compute(App.model)
    VisibilitySystem.compute(App.model)
    MovementSystem.compute(App.model)
    RenderSystem.prepare(App.model)
end

local function change_level(delta)
    local unit = selected_unit()
    local nz = unit.z + delta
    if App.model.field:inBounds(unit.x, unit.y, nz) then
        unit.z = nz
        App.model.active_level = nz
        App.message = App.selected .. " changed level to " .. nz
        VisibilitySystem.compute(App.model)
        MovementSystem.compute(App.model)
        RenderSystem.prepare(App.model)
    end
end

function lurek.init()
    lurek.window.setTitle("Tilefield Tactics")
    lurek.render.setBackgroundColor(0.035, 0.04, 0.052)
    bind_inputs()
    rebuild()
end

function lurek.process(dt)
    App.turn = App.turn + dt
    if lurek.input.wasActionPressed("quit") then lurek.event.quit() return end
    if lurek.input.wasActionPressed("restart") then rebuild() return end
    if lurek.input.wasActionPressed("player") then
        App.selected = App.selected == "p1" and "p2" or "p1"
        App.message = "Selected " .. App.selected
    end
    if lurek.input.wasActionPressed("door") then
        FieldSystem.toggle_door(App.model)
        LightingSystem.compute(App.model)
        VisibilitySystem.compute(App.model)
        MovementSystem.compute(App.model)
        RenderSystem.prepare(App.model)
        App.message = "Door toggled: " .. App.model.door_profile
    end
    if lurek.input.wasActionPressed("level_up") then change_level(1) end
    if lurek.input.wasActionPressed("level_down") then change_level(-1) end
    if lurek.input.wasActionPressed("up") then try_move(0, -1) end
    if lurek.input.wasActionPressed("down") then try_move(0, 1) end
    if lurek.input.wasActionPressed("left") then try_move(-1, 0) end
    if lurek.input.wasActionPressed("right") then try_move(1, 0) end
end

function lurek.draw()
    RenderSystem.draw(App.model, App.selected, App.message)
end

function lurek.draw_ui()
    RenderSystem.draw_ui(App.model, App.selected)
end
