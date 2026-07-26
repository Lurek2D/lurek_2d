-- Lurek2D scene policy example:
-- - Rendering: engine always renders ONLY the current top scene.
-- - Simulation: developer can freeze/unfreeze update/process/physics/late per scene.

local menu_scene
local game_scene

menu_scene = lurek.scene.new({
    name = "menu",
    process = function(self, dt)
        if lurek.input.wasActionPressed("start") then
            -- Keep menu scene on stack, but freeze its simulation callbacks.
            lurek.scene.setProcessEnabled("menu", false)
            lurek.scene.setPhysicsEnabled("menu", false)
            lurek.scene.setLateEnabled("menu", false)
            lurek.scene.setUpdateEnabled("menu", false)

            -- Switch to gameplay scene.
            lurek.scene.push(game_scene, "fade", 0.2, "linear")
        end
    end,
    render = function(self)
        -- Draw only while menu is top scene.
        lurek.render.print("MENU", 40, 40)
    end,
})

game_scene = lurek.scene.new({
    name = "game",
    process = function(self, dt)
        if lurek.input.wasActionPressed("quit") then
            -- Restore menu simulation before going back.
            lurek.scene.setProcessEnabled("menu", true)
            lurek.scene.setPhysicsEnabled("menu", true)
            lurek.scene.setLateEnabled("menu", true)
            lurek.scene.setUpdateEnabled("menu", true)
            lurek.scene.pop("fade", 0.2, "linear")
        end
    end,
    render = function(self)
        lurek.render.print("GAME", 40, 40)
    end,
})

function lurek.init()
    lurek.scene.clear()
    lurek.scene.registerScene("menu", menu_scene)
    lurek.scene.push(menu_scene)
end

function lurek.process(dt)
    lurek.scene.process(dt)
    lurek.scene.processPhysics(dt)
    lurek.scene.processLate(dt)
end

function lurek.draw()
    lurek.scene.render()
end
