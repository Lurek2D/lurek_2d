-- content/examples/scene.lua
-- Auto-generated from content/examples2/scene_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/scene.lua

--- Scene Module Part 1: scene creation, stack management, registration, shared data, lifecycle

--@api-stub: lurek.scene.new
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

-- Passing parameters to scene enter.
--@api-stub: lurek.scene.new
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

--- Scene Module Part 2: transitions, overlays, preload, depth sorter, serialization

--@api-stub: lurek.scene.transitions.fade
--@api-stub: lurek.scene.transitions.slide
--@api-stub: lurek.scene.transitions.iris
--@api-stub: lurek.scene.transitions.wipe
-- Transition descriptor factories.
do
    local fade = lurek.scene.transitions.fade(0.5)
    print("fade type = " .. fade.type .. " dur = " .. fade.duration)
    local slide = lurek.scene.transitions.slide("left", 0.4)
    print("slide type = " .. slide.type .. " dur = " .. slide.duration)
    local iris = lurek.scene.transitions.iris(0.6)
    print("iris type = " .. iris.type .. " dur = " .. iris.duration)
    local wipe = lurek.scene.transitions.wipe(0.5)
    print("wipe type = " .. wipe.type .. " dur = " .. wipe.duration)
end

--@api-stub: lurek.scene.getTransitionTypes
-- Listing available transition types.
do
    local types = lurek.scene.getTransitionTypes()
    print("transition types = " .. #types)
    for _, t in ipairs(types) do
        print("  " .. t)
    end
end

--@api-stub: lurek.scene.queueTransition
-- Queuing multiple transitions.
do
    local s1 = lurek.scene.new({})
    local s2 = lurek.scene.new({})
    lurek.scene.push(s1)
    lurek.scene.push(s2, "fade", 0.2)
    lurek.scene.queueTransition("iris", 0.3)
    lurek.scene.queueTransition("wipe", 0.4, "ease_in")
    print("queued = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clearQueuedTransitions()
    print("after clear queued = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.pushOverlay
-- Overlay scenes (non-pausing).
do
    local gameScene = lurek.scene.new({
        name = "game",
        update = function(self, dt)
            -- continues running under overlay
        end,
        draw = function(self)
            lurek.render.setColor(0.2, 0.3, 0.5, 1)
            lurek.render.rectangle("fill", 0, 0, 800, 600)
            lurek.render.setColor(1, 1, 1, 1)
        end,
    })
    local pauseOverlay = lurek.scene.new({
        name = "pause",
        enter = function(self) print("pause overlay enter") end,
        draw = function(self)
            lurek.render.setColor(0, 0, 0, 0.5)
            lurek.render.rectangle("fill", 0, 0, 800, 600)
            lurek.render.setColor(1, 1, 1, 1)
            lurek.render.print("PAUSED", 350, 280)
        end,
    })
    lurek.scene.push(gameScene)
    print("overlay before push = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.pushOverlay(pauseOverlay, "fade", 0.2)
    print("overlay after push = " .. tostring(lurek.scene.isOverlay()))
    print("stack depth = " .. lurek.scene.getStackSize())
    lurek.scene.pop()
    print("after pop overlay = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.preload
-- Deferred scene loading.
do
    local loadCount = 0
    lurek.scene.preload("heavyLevel", function()
        loadCount = loadCount + 1
        print("loader executed (count=" .. loadCount .. ")")
        local scene = lurek.scene.new({
            enter = function(self) print("heavy level enter") end,
        })
        lurek.scene.registerScene("heavyLevel", scene)
    end)
    print("preloaded = " .. tostring(lurek.scene.isPreloaded("heavyLevel")))
    local base = lurek.scene.new({})
    lurek.scene.push(base)
    lurek.scene.pushPreloaded("heavyLevel", "fade", 0.3)
    print("after push preloaded = " .. tostring(lurek.scene.isPreloaded("heavyLevel")))
    print("load count = " .. loadCount)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getActiveScenes
-- Inspecting active scene list.
do
    local s1 = lurek.scene.new({})
    local s2 = lurek.scene.new({})
    local s3 = lurek.scene.new({})
    lurek.scene.push(s1)
    lurek.scene.push(s2)
    lurek.scene.pushOverlay(s3)
    local active = lurek.scene.getActiveScenes()
    print("active scenes = " .. #active)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.serializeScene
-- Saving and restoring scene navigation state.
do
    local menu = lurek.scene.new({})
    local game = lurek.scene.new({})
    lurek.scene.registerScene("menu", menu)
    lurek.scene.registerScene("game", game)
    lurek.scene.push(menu)
    lurek.scene.push(game)
    lurek.scene.setData("level", 7)
    lurek.scene.setData("checkpoint", "bridge")
    local snapshot = lurek.scene.serializeScene()
    print("stack = " .. #snapshot.stack .. " scenes")
    for i, name in ipairs(snapshot.stack) do
        print("  " .. i .. ": " .. name)
    end
    print("data.level = " .. tostring(snapshot.data.level))
    print("data.checkpoint = " .. tostring(snapshot.data.checkpoint))
    lurek.scene.clear()
    lurek.scene.deserializeScene(snapshot)
    print("restored level = " .. lurek.scene.getData("level"))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.newDepthSorter
-- Depth-sorted rendering with callbacks.
do
    ---@type LDepthSorter
    local sorter = lurek.scene.newDepthSorter()
    print("type = " .. sorter:type())
    print("is LDepthSorter = " .. tostring(sorter:typeOf("LDepthSorter")))
    sorter:add(function()
        lurek.render.setColor(1, 0, 0, 1)
        lurek.render.rectangle("fill", 10, 10, 30, 30)
    end, 10)
    sorter:add(function()
        lurek.render.setColor(0, 0, 1, 1)
        lurek.render.rectangle("fill", 20, 20, 30, 30)
    end, 5)
    sorter:add(function()
        lurek.render.setColor(0, 1, 0, 1)
        lurek.render.rectangle("fill", 30, 30, 30, 30)
    end, 15)
    print("count = " .. sorter:getCount())
    sorter:flush()
    print("after flush count = " .. sorter:getCount())
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: LDepthSorter:addObject
--@api-stub: LDepthSorter:sort
--@api-stub: LDepthSorter:clear
--@api-stub: LDepthSorter:setStable
--@api-stub: LDepthSorter:isStable
-- Object-based depth sorting.
do
    ---@type LDepthSorter
    local sorter = lurek.scene.newDepthSorter()
    local obj1 = {
        depth = 3,
        drawSorted = function(self)
            print("draw obj at depth " .. self.depth)
        end,
    }
    local obj2 = {
        depth = 1,
        drawSorted = function(self)
            print("draw obj at depth " .. self.depth)
        end,
    }
    local obj3 = {
        depth = 7,
        drawSorted = function(self)
            print("draw obj at depth " .. self.depth)
        end,
    }
    sorter:addObject(obj1)
    sorter:addObject(obj2)
    sorter:addObject(obj3)
    print("stable = " .. tostring(sorter:isStable()))
    sorter:setStable(true)
    print("stable = " .. tostring(sorter:isStable()))
    sorter:sort()
    print("sorted, count = " .. sorter:getCount())
    sorter:clear()
    print("cleared count = " .. sorter:getCount())
end

--@api-stub: lurek.scene.processLate
-- Late processing and physics callbacks.
do
    local lateCount = 0
    local physCount = 0
    local scene = lurek.scene.new({
        process_late = function(self, dt)
            lateCount = lateCount + 1
        end,
        process_physics = function(self, dt)
            physCount = physCount + 1
        end,
    })
    lurek.scene.push(scene)
    for i = 1, 3 do
        lurek.scene.processLate(1 / 60)
        lurek.scene.processPhysics(1 / 60)
    end
    print("late = " .. lateCount)
    print("physics = " .. physCount)
    lurek.scene.clear()
end

--- Scene Part 2: full scene module API coverage

--@api-stub: lurek.scene.clear
--@api-stub: lurek.scene.clearQueuedTransitions
--@api-stub: lurek.scene.deserializeScene
--@api-stub: lurek.scene.draw
--@api-stub: lurek.scene.getCurrent
--@api-stub: lurek.scene.getCurrentLayer
--@api-stub: lurek.scene.getData
--@api-stub: lurek.scene.getQueuedTransitionCount
--@api-stub: lurek.scene.getRegistered
--@api-stub: lurek.scene.getRegisteredNames
--@api-stub: lurek.scene.getStackSize
--@api-stub: lurek.scene.getTransitionProgress
--@api-stub: lurek.scene.getTransitionProgressEased
--@api-stub: lurek.scene.hasData
--@api-stub: lurek.scene.hasRegistered
--@api-stub: lurek.scene.isEmpty
--@api-stub: lurek.scene.isOverlay
--@api-stub: lurek.scene.isPreloaded
--@api-stub: lurek.scene.isTransitioning
--@api-stub: lurek.scene.pop
--@api-stub: lurek.scene.pushPreloaded
-- Full lurek.scene module: define, push/pop, transitions, data, serialize, registry.
do
    lurek.scene.define({
        name = "main_scene",
        enter = function() print("enter_main") end,
        update = function(dt) end,
        draw = function() end,
        leave = function() print("leave_main") end
    })

    print("registered=" .. tostring(lurek.scene.hasRegistered("main_scene")))
    local reg = lurek.scene.getRegistered("main_scene")
    print("reg_def=" .. tostring(reg ~= nil))
    local names = lurek.scene.getRegisteredNames()
    print("reg_names=" .. #names)

    local scene_def = {
        enter = function() print("enter_main") end,
        update = function(dt) end,
        draw = function() end,
        leave = function() print("leave_main") end
    }

    lurek.scene.push(scene_def)
    print("stack_size=" .. lurek.scene.getStackSize())
    print("is_empty=" .. tostring(lurek.scene.isEmpty()))
    print("depth=" .. lurek.scene.depth())

    local current = lurek.scene.getCurrent()
    print("current=" .. tostring(current))
    local layer = lurek.scene.getCurrentLayer()
    print("layer=" .. tostring(layer))

    print("is_transitioning=" .. tostring(lurek.scene.isTransitioning()))
    print("is_overlay=" .. tostring(lurek.scene.isOverlay()))
    print("transition_progress=" .. lurek.scene.getTransitionProgress())
    print("transition_progress_eased=" .. lurek.scene.getTransitionProgressEased())

    lurek.scene.setData("score", 42)
    print("has_score=" .. tostring(lurek.scene.hasData("score")))
    local score = lurek.scene.getData("score")
    print("score=" .. tostring(score))

    local transition_types = lurek.scene.getTransitionTypes()
    print("transition_types=" .. #transition_types)

    lurek.scene.draw()

    local queued = lurek.scene.getQueuedTransitionCount()
    print("queued=" .. queued)
    lurek.scene.clearQueuedTransitions()

    lurek.scene.preload("main_scene", function() return {} end)
    print("is_preloaded=" .. tostring(lurek.scene.isPreloaded("main_scene")))

    local snap = lurek.scene.serializeScene()
    print("snapshot=" .. tostring(snap ~= nil))
    lurek.scene.deserializeScene(snap)

    lurek.scene.pop()
    lurek.scene.clear()
    print("cleared=" .. tostring(lurek.scene.isEmpty()))
end

--@api-stub: LDepthSorter:add
--@api-stub: LDepthSorter:flush
--@api-stub: LDepthSorter:getCount
-- LDepthSorter: queue items and flush in depth order.
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function() lurek.render.circle("fill", 100, 100, 20) end, 5.0)
    ds:add(function() lurek.render.circle("fill", 200, 100, 20) end, 2.0)
    local count = ds:getCount()
    ds:flush()
    print("depth sorter count:", count)
end

--@api-stub: LDepthSorter:type
--@api-stub: LDepthSorter:typeOf
--@api-stub: lurek.scene.newScene
-- LDepthSorter type checks and newScene.
do
    local ds = lurek.scene.newDepthSorter()
    local t = ds:type()
    local ok = ds:typeOf("LDepthSorter")
    local sn = lurek.scene.newScene({name = "test_new", enter = function() end, draw = function() end})
    print("type:", t, "newScene ok")
end

--@api-stub: lurek.scene.process
--@api-stub: lurek.scene.processPhysics
--@api-stub: lurek.scene.removeData
-- Scene process, processPhysics, and removeData.
do
    lurek.scene.process(0.016)
    lurek.scene.processPhysics(0.016)
    lurek.scene.setData("_test_key", 42)
    lurek.scene.removeData("_test_key")
    print("process, processPhysics, removeData ok")
end

--@api-stub: lurek.scene.render
--@api-stub: lurek.scene.renderUi
--@api-stub: lurek.scene.setCurrentLayer
-- Scene render, renderUi, and layer selection.
do
    lurek.scene.setCurrentLayer(0)
    lurek.scene.render()
    lurek.scene.renderUi()
    local layer = lurek.scene.getCurrentLayer()
    print("render, renderUi, setCurrentLayer ok")
end

--@api-stub: lurek.scene.unregisterScene
-- Scene unregister.
do
    lurek.scene.define({name = "_tmp_unreg", enter = function() end, draw = function() end})
    lurek.scene.unregisterScene("_tmp_unreg")
    print("unregisterScene ok")
end

print("content/examples/scene.lua")
