--- Scene Module Part 1: scene creation, stack management, registration, shared data, lifecycle

--@api-stub: lurek.scene.new
--@api-stub: lurek.newScene
-- Creating scene instances.
do
    local myScene = lurek.scene.new({
        name = "menu",
        enter = function(self, params)
            print("entering menu scene")
        end,
        leave = function(self)
            print("leaving menu scene")
        end,
        update = function(self, dt)
        end,
        draw = function(self)
        end,
    })
    print("scene created")
    local emptyScene = lurek.scene.newScene()
    print("empty scene = " .. tostring(emptyScene))
end

--@api-stub: lurek.scene.define
-- Defining reusable scene constructors.
do
    local GameplayFactory = lurek.scene.define({
        name = "gameplay",
        level = 0,
        enter = function(self, params)
            if params then
                self.level = params.level or 1
            end
            print("gameplay enter level " .. self.level)
        end,
        leave = function(self)
            print("gameplay leave")
        end,
        update = function(self, dt)
            -- game logic
        end,
        draw = function(self)
            -- draw world
        end,
    })
    local instance1 = GameplayFactory()
    local instance2 = GameplayFactory()
    print("two instances: " .. tostring(instance1 ~= instance2))
end

--@api-stub: lurek.scene.push
--@api-stub: lurek.getCurrent
--@api-stub: lurek.getStackSize
--@api-stub: lurek.isEmpty
-- Stack operations.
do
    print("empty = " .. tostring(lurek.scene.isEmpty()))
    print("depth = " .. lurek.scene.getStackSize())
    local scene1 = lurek.scene.new({
        name = "title",
        enter = function(self) print("title enter") end,
        leave = function(self) print("title leave") end,
        pause = function(self) print("title pause") end,
        resume = function(self) print("title resume") end,
    })
    lurek.scene.push(scene1)
    print("after push depth = " .. lurek.scene.getStackSize())
    print("empty = " .. tostring(lurek.scene.isEmpty()))
    local current = lurek.scene.getCurrent()
    print("current = " .. current.name)
    local scene2 = lurek.scene.new({
        name = "options",
        enter = function(self) print("options enter") end,
        leave = function(self) print("options leave") end,
    })
    lurek.scene.push(scene2)
    print("depth = " .. lurek.scene.getStackSize())
    current = lurek.scene.getCurrent()
    print("current = " .. current.name)
    lurek.scene.pop()
    print("after pop depth = " .. lurek.scene.getStackSize())
    current = lurek.scene.getCurrent()
    print("current = " .. current.name)
    lurek.scene.clear()
    print("after clear depth = " .. lurek.scene.getStackSize())
end

--@api-stub: lurek.scene.switchTo
-- Replacing the top scene.
do
    local sceneA = lurek.scene.new({
        name = "level1",
        enter = function(self) print("level1 enter") end,
        leave = function(self) print("level1 leave") end,
    })
    local sceneB = lurek.scene.new({
        name = "level2",
        enter = function(self, params)
            print("level2 enter, from=" .. (params and params.from or "none"))
        end,
        leave = function(self) print("level2 leave") end,
    })
    lurek.scene.push(sceneA)
    print("before switch: depth=" .. lurek.scene.getStackSize())
    lurek.scene.switchTo(sceneB, "none", 0, "linear", { from = "level1" })
    print("after switch: depth=" .. lurek.scene.getStackSize())
    local current = lurek.scene.getCurrent()
    print("current = " .. current.name)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.registerScene
--@api-stub: lurek.getRegistered
--@api-stub: lurek.hasRegistered
--@api-stub: lurek.getRegisteredNames
--@api-stub: lurek.unregisterScene
-- Scene registration.
do
    local menuScene = lurek.scene.new({ name = "mainMenu" })
    local gameScene = lurek.scene.new({ name = "game" })
    local creditsScene = lurek.scene.new({ name = "credits" })
    lurek.scene.registerScene("mainMenu", menuScene)
    lurek.scene.registerScene("game", gameScene)
    lurek.scene.registerScene("credits", creditsScene)
    print("has mainMenu = " .. tostring(lurek.scene.hasRegistered("mainMenu")))
    print("has unknown = " .. tostring(lurek.scene.hasRegistered("unknown")))
    local retrieved = lurek.scene.getRegistered("game")
    print("retrieved game = " .. retrieved.name)
    local names = lurek.scene.getRegisteredNames()
    print("registered count = " .. #names)
    for _, n in ipairs(names) do
        print("  " .. n)
    end
    lurek.scene.unregisterScene("credits")
    print("after unregister has credits = " .. tostring(lurek.scene.hasRegistered("credits")))
end

--@api-stub: lurek.scene.setData
--@api-stub: lurek.getData
--@api-stub: lurek.hasData
--@api-stub: lurek.removeData
-- Shared scene data map.
do
    lurek.scene.setData("selectedLevel", 5)
    lurek.scene.setData("playerName", "Hero")
    lurek.scene.setData("difficulty", "hard")
    print("has selectedLevel = " .. tostring(lurek.scene.hasData("selectedLevel")))
    print("selectedLevel = " .. lurek.scene.getData("selectedLevel"))
    print("playerName = " .. lurek.scene.getData("playerName"))
    lurek.scene.removeData("difficulty")
    print("has difficulty = " .. tostring(lurek.scene.hasData("difficulty")))
end

--@api-stub: lurek.scene.push with params
-- Passing parameters to scene enter.
do
    local battleScene = lurek.scene.new({
        name = "battle",
        enemyType = "none",
        enter = function(self, params)
            if params then
                self.enemyType = params.enemy or "slime"
            end
            print("battle start vs " .. self.enemyType)
        end,
        leave = function(self) end,
    })
    lurek.scene.push(battleScene, "none", 0, "linear", { enemy = "dragon" })
    print("battle scene pushed")
    lurek.scene.clear()
end

--@api-stub: lurek.scene.depth
--@api-stub: lurek.getCurrentLayer
--@api-stub: lurek.setCurrentLayer
-- Layer management.
do
    local scene = lurek.scene.new({ name = "layered" })
    lurek.scene.push(scene)
    print("depth = " .. lurek.scene.depth())
    local layer = lurek.scene.getCurrentLayer()
    print("layer = " .. layer)
    local ok = lurek.scene.setCurrentLayer(5)
    print("set layer ok = " .. tostring(ok))
    print("new layer = " .. lurek.scene.getCurrentLayer())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.update
--@api-stub: lurek.process
--@api-stub: lurek.render
--@api-stub: lurek.renderUi
-- Scene lifecycle callbacks.
do
    local updateCount = 0
    local drawCount = 0
    local processCount = 0
    local scene = lurek.scene.new({
        update = function(self, dt)
            updateCount = updateCount + 1
        end,
        draw = function(self)
            drawCount = drawCount + 1
        end,
        process = function(self, dt)
            processCount = processCount + 1
        end,
        render = function(self) end,
        render_ui = function(self) end,
    })
    lurek.scene.push(scene)
    for i = 1, 5 do
        lurek.scene.update(1 / 60)
        lurek.scene.process(1 / 60)
        lurek.scene.draw()
    end
    print("updates = " .. updateCount)
    print("draws = " .. drawCount)
    print("processes = " .. processCount)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.popTo
-- Unwinding the stack to a named scene.
do
    local base = lurek.scene.new({ name = "base" })
    local mid = lurek.scene.new({ name = "middle" })
    local top = lurek.scene.new({ name = "top" })
    lurek.scene.registerScene("base", base)
    lurek.scene.registerScene("middle", mid)
    lurek.scene.push(base)
    lurek.scene.push(mid)
    lurek.scene.push(top)
    print("depth before popTo = " .. lurek.scene.depth())
    local found = lurek.scene.popTo("base")
    print("popTo base = " .. tostring(found))
    print("depth after = " .. lurek.scene.depth())
    local notFound = lurek.scene.popTo("nonexistent")
    print("popTo missing = " .. tostring(notFound))
    lurek.scene.clear()
end

print("scene_00.lua")
