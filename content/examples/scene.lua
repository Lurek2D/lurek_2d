-- content/examples/scene.lua
-- Auto-generated from content/examples2/scene_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/scene.lua

--- Scene Module Part 1: scene creation, stack management, registration, shared data, lifecycle

--@api-stub: lurek.scene.new
do
    local myScene = lurek.scene.new({ name = "menu", enter = function() print("entering menu scene") end, leave = function() print("leaving menu scene") end, update = function() end, draw = function() end })
    print("scene created")
end

--@api-stub: lurek.scene.define
do
    local GameplayFactory = lurek.scene.define({
        name = "gameplay",
        level = 0,
        enter = function(self, params)
            self.level = params and (params.level or 1) or self.level
            print("gameplay enter level " .. self.level)
        end,
        leave = function()
            print("gameplay leave")
        end,
        update = function()
        end,
        draw = function()
        end,
    })
    local instance1 = GameplayFactory()
    local instance2 = GameplayFactory()
    print("two instances: " .. tostring(instance1 ~= instance2))
end

--@api-stub: lurek.scene.push
do
    local scene1 = lurek.scene.new({ name = "title", enter = function() print("title enter") end, leave = function() print("title leave") end })
    lurek.scene.push(scene1)
    print("after push depth = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.switchTo
do
    local sceneA = lurek.scene.new({
        name = "level1",
        enter = function()
            print("level1 enter")
        end,
        leave = function()
            print("level1 leave")
        end,
    })
    local sceneB = lurek.scene.new({
        name = "level2",
        enter = function(_, params)
            print("level2 enter, from=" .. (params and params.from or "none"))
        end,
        leave = function()
            print("level2 leave")
        end,
    })
    lurek.scene.push(sceneA)
    print("before switch: depth=" .. lurek.scene.getStackSize())
    lurek.scene.switchTo(sceneB, "none", 0, "linear", { from = "level1" })
    print("after switch: depth=" .. lurek.scene.getStackSize())
    print("current = " .. lurek.scene.getCurrent().name)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.registerScene
do
    local menuScene = lurek.scene.new({ name = "mainMenu" })
    lurek.scene.registerScene("mainMenu", menuScene)
    print("has mainMenu = " .. tostring(lurek.scene.hasRegistered("mainMenu")))
end

--@api-stub: lurek.scene.setData
do
    lurek.scene.setData("selectedLevel", 5)
    print("has selectedLevel = " .. tostring(lurek.scene.hasData("selectedLevel")))
    print("selectedLevel = " .. lurek.scene.getData("selectedLevel"))
end

--@api-stub: lurek.scene.depth
do
    local scene = lurek.scene.new({ name = "layered" })
    lurek.scene.push(scene)
    print("depth = " .. lurek.scene.depth())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.update
do
    local updateCount = 0
    local drawCount = 0
    local processCount = 0
    local scene = lurek.scene.new({
        update = function(self, dt)
            self.last_dt = dt
            updateCount = updateCount + 1
        end,
        draw = function()
            drawCount = drawCount + 1
        end,
        process = function()
            processCount = processCount + 1
        end,
    })
    lurek.scene.push(scene)
    lurek.scene.update(1 / 60)
    lurek.scene.process(1 / 60)
    lurek.scene.draw()
    print("updates = " .. updateCount)
    print("draws = " .. drawCount .. " processes = " .. processCount)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.popTo
do
    local base = lurek.scene.new({ name = "base" })
    local mid = lurek.scene.new({ name = "middle" })
    local top = lurek.scene.new({ name = "top" })
    lurek.scene.registerScene("base", base)
    lurek.scene.registerScene("middle", mid)
    lurek.scene.push(base)
    lurek.scene.push(mid)
    lurek.scene.push(top)
    local found = lurek.scene.popTo("base")
    local missing = lurek.scene.popTo("nonexistent")
    print("popTo base = " .. tostring(found))
    print("popTo missing = " .. tostring(missing) .. " depth = " .. lurek.scene.depth())
    lurek.scene.clear()
end

--- Scene Module Part 2: transitions, overlays, preload, depth sorter, serialization

--@api-stub: lurek.scene.transitions.fade
do
    local fade = lurek.scene.transitions.fade(0.5)
    print("fade type = " .. fade.type .. " dur = " .. fade.duration)
end

--@api-stub: lurek.scene.transitions.slide
do
    local slide = lurek.scene.transitions.slide("left", 0.4)
    print("slide type = " .. slide.type .. " dur = " .. slide.duration)
end

--@api-stub: lurek.scene.transitions.iris
do
    local iris = lurek.scene.transitions.iris(0.6)
    print("iris type = " .. iris.type .. " dur = " .. iris.duration)
end

--@api-stub: lurek.scene.transitions.wipe
do
    local wipe = lurek.scene.transitions.wipe(0.5)
    print("wipe type = " .. wipe.type .. " dur = " .. wipe.duration)
end

--@api-stub: lurek.scene.getTransitionTypes
do
    local types = lurek.scene.getTransitionTypes()
    print("transition types = " .. #types)
    print("first type = " .. tostring(types[1]))
end

--@api-stub: lurek.scene.queueTransition
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base" }))
    lurek.scene.queueTransition("fade", 0.2)
    lurek.scene.queueTransition("iris", 0.3)
    lurek.scene.queueTransition("wipe", 0.4, "ease_in")
    print("queued = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clearQueuedTransitions()
    print("after clear queued = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.pushOverlay
do
    lurek.scene.clear()
    local gameScene = lurek.scene.new({ name = "game" })
    local pauseOverlay = lurek.scene.new({ name = "pause" })
    lurek.scene.push(gameScene)
    print("overlay before push = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.pushOverlay(pauseOverlay, "fade", 0.2)
    print("overlay after push = " .. tostring(lurek.scene.isOverlay()) .. " stack depth = " .. lurek.scene.getStackSize())
    lurek.scene.pop()
    print("after pop overlay = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.preload
do
    local loadCount = 0
    lurek.scene.clear()
    lurek.scene.preload("heavyLevel", function()
        loadCount = loadCount + 1
        lurek.scene.registerScene("heavyLevel", lurek.scene.new({ name = "heavyLevel" }))
    end)
    print("preloaded = " .. tostring(lurek.scene.isPreloaded("heavyLevel")))
    lurek.scene.push(lurek.scene.new({ name = "loader" }))
    lurek.scene.pushPreloaded("heavyLevel", "fade", 0.3)
    print("after push preloaded = " .. tostring(lurek.scene.isPreloaded("heavyLevel")) .. " load count = " .. loadCount)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getActiveScenes
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base" }))
    lurek.scene.push(lurek.scene.new({ name = "mid" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "overlay" }))
    local active = lurek.scene.getActiveScenes()
    print("active scenes = " .. #active)
    print("top active = " .. tostring(active[#active] and active[#active].name))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.serializeScene
do
    lurek.scene.clear()
    local menu = lurek.scene.new({ name = "menu" })
    local game = lurek.scene.new({ name = "game" })
    lurek.scene.registerScene("menu", menu)
    lurek.scene.registerScene("game", game)
    lurek.scene.push(menu)
    lurek.scene.push(game)
    lurek.scene.setData("level", 7)
    lurek.scene.setData("checkpoint", "bridge")
    local snapshot = lurek.scene.serializeScene()
    print("stack = " .. #snapshot.stack)
    print("saved level = " .. tostring(snapshot.data.level) .. " checkpoint = " .. tostring(snapshot.data.checkpoint))
    lurek.scene.clear()
    lurek.scene.deserializeScene(snapshot)
    print("restored level = " .. tostring(lurek.scene.getData("level")))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.newDepthSorter
do
    local sorter = lurek.scene.newDepthSorter()
    print("type = " .. sorter:type() .. " is LDepthSorter = " .. tostring(sorter:typeOf("LDepthSorter")))
    sorter:add(function()
        print("draw back layer")
    end, 10)
    sorter:add(function()
        print("draw front layer")
    end, 15)
    print("count = " .. sorter:getCount())
    sorter:flush()
    print("after flush count = " .. sorter:getCount())
end

--@api-stub: LDepthSorter:addObject
do
    local sorter = lurek.scene.newDepthSorter()
    local obj1 = { depth = 3, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }
    local obj2 = { depth = 1, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }
    sorter:addObject(obj1)
    sorter:addObject(obj2)
    print("count = " .. sorter:getCount())
    sorter:flush()
end

--@api-stub: LDepthSorter:sort
do
    local sorter = lurek.scene.newDepthSorter()
    sorter:add(function()
        print("sorted callback")
    end, 2)
    sorter:add(function()
        print("sorted callback 2")
    end, 1)
    sorter:sort()
    print("sorted, count = " .. sorter:getCount())
    sorter:clear()
end

--@api-stub: LDepthSorter:clear
do
    local sorter = lurek.scene.newDepthSorter()
    sorter:add(function()
        print("queued callback")
    end, 3)
    print("before clear count = " .. sorter:getCount())
    sorter:clear()
    print("cleared count = " .. sorter:getCount())
end

--@api-stub: LDepthSorter:setStable
do
    local sorter = lurek.scene.newDepthSorter()
    sorter:setStable(true)
    print("stable = " .. tostring(sorter:isStable()))
    sorter:setStable(false)
    print("stable after disable = " .. tostring(sorter:isStable()))
end

--@api-stub: LDepthSorter:isStable
do
    local sorter = lurek.scene.newDepthSorter()
    print("stable default = " .. tostring(sorter:isStable()))
    sorter:setStable(true)
    print("stable after enable = " .. tostring(sorter:isStable()))
end

--@api-stub: lurek.scene.processLate
do
    local lateCount = 0
    local physCount = 0
    local scene = lurek.scene.new({
        process_late = function()
            lateCount = lateCount + 1
        end,
        process_physics = function()
            physCount = physCount + 1
        end,
    })
    lurek.scene.push(scene)
    lurek.scene.processLate(1 / 60)
    lurek.scene.processPhysics(1 / 60)
    print("late = " .. lateCount .. " physics = " .. physCount)
    lurek.scene.clear()
end

--- Scene Part 2: full scene module API coverage
--@api-stub: lurek.scene.clear
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.clear()
    print("is empty = " .. tostring(lurek.scene.isEmpty()))
end

--@api-stub: lurek.scene.clearQueuedTransitions
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.queueTransition("fade", 0.25, "linear")
    print("queued before = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clearQueuedTransitions()
    print("queued after = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.deserializeScene
do
    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    local snapshot = lurek.scene.serializeScene()
    lurek.scene.removeData("score")
    lurek.scene.deserializeScene(snapshot)
    print("restored score = " .. tostring(lurek.scene.getData("score")))
    print("stack size after load = " .. lurek.scene.getStackSize())
end

--@api-stub: lurek.scene.draw
do
    local draws = 0
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "draw_scene", draw = function() draws = draws + 1 end }))
    lurek.scene.draw()
    print("draw calls = " .. draws)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getCurrent
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local current = lurek.scene.getCurrent()
    print("current name = " .. tostring(current and current.name))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getCurrentLayer
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setCurrentLayer(12)
    print("current layer = " .. tostring(lurek.scene.getCurrentLayer()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getData
do
    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    print("score = " .. tostring(lurek.scene.getData("score")))
end

--@api-stub: lurek.scene.getQueuedTransitionCount
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.queueTransition("fade", 0.25, "linear")
    print("queued transitions = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getRegistered
do
    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    local scene = lurek.scene.getRegistered("main_scene")
    print("registered scene = " .. tostring(scene and scene.name))
end

--@api-stub: lurek.scene.getRegisteredNames
do
    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    lurek.scene.registerScene("pause_scene", lurek.scene.new({ name = "pause_scene" }))
    local names = lurek.scene.getRegisteredNames()
    print("registered names = " .. #names)
    print("first name = " .. tostring(names[1]))
end

--@api-stub: lurek.scene.getStackSize
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("stack size = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getTransitionProgress
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    print("transition progress = " .. lurek.scene.getTransitionProgress())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getTransitionProgressEased
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    print("eased progress = " .. lurek.scene.getTransitionProgressEased())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.hasData
do
    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    print("has score = " .. tostring(lurek.scene.hasData("score")))
end

--@api-stub: lurek.scene.hasRegistered
do
    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    print("has main_scene = " .. tostring(lurek.scene.hasRegistered("main_scene")))
end

--@api-stub: lurek.scene.isEmpty
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("before clear = " .. tostring(lurek.scene.isEmpty()))
    lurek.scene.clear()
    print("after clear = " .. tostring(lurek.scene.isEmpty()))
end

--@api-stub: lurek.scene.isOverlay
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "pause_overlay" }), "fade", 0.2)
    print("top scene is overlay = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.isPreloaded
do
    lurek.scene.clear()
    lurek.scene.preload("main_scene", function()
        lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    end)
    print("preloaded = " .. tostring(lurek.scene.isPreloaded("main_scene")))
    lurek.scene.push(lurek.scene.new({ name = "loader" }))
    lurek.scene.pushPreloaded("main_scene")
    print("after push = " .. tostring(lurek.scene.isPreloaded("main_scene")))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.isTransitioning
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    print("is transitioning = " .. tostring(lurek.scene.isTransitioning()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.pop
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "first_scene" }))
    lurek.scene.push(lurek.scene.new({ name = "second_scene" }))
    lurek.scene.pop()
    print("stack size after pop = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.pushPreloaded
do
    lurek.scene.clear()
    lurek.scene.preload("main_scene", function()
        lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    end)
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.pushPreloaded("main_scene", "fade", 0.3)
    print("stack size after push = " .. lurek.scene.getStackSize())
    print("current = " .. tostring(lurek.scene.getCurrent() and lurek.scene.getCurrent().name))
    lurek.scene.clear()
end

--@api-stub: LDepthSorter:add
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function()
        print("draw circle A")
    end, 5.0)
    ds:add(function()
        print("draw circle B")
    end, 2.0)
    local count = ds:getCount()
    ds:flush()
    print("depth sorter count = " .. count)
end

--@api-stub: LDepthSorter:flush
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function()
        print("flush callback A")
    end, 5.0)
    ds:add(function()
        print("flush callback B")
    end, 2.0)
    local count = ds:getCount()
    ds:flush()
    print("depth sorter count = " .. count)
end

--@api-stub: LDepthSorter:getCount
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function()
        print("count callback")
    end, 5.0)
    ds:add(function()
        print("count callback 2")
    end, 2.0)
    print("depth sorter count = " .. ds:getCount())
    ds:clear()
end

--@api-stub: LDepthSorter:type
do
    local ds = lurek.scene.newDepthSorter()
    print("type = " .. ds:type())
end

--@api-stub: LDepthSorter:typeOf
do
    local ds = lurek.scene.newDepthSorter()
    print("is depth sorter = " .. tostring(ds:typeOf("LDepthSorter")))
    print("is object = " .. tostring(ds:typeOf("Object")))
end

--@api-stub: lurek.scene.newScene
do
    local scene = lurek.scene.newScene({ name = "test_new" })
    print("scene name = " .. tostring(scene.name))
    print("has metatable = " .. tostring(getmetatable(scene) ~= nil))
end

--@api-stub: lurek.scene.process
do
    lurek.scene.clear()
    local processCount = 0
    local scene = lurek.scene.new({
        process = function(self, dt)
            self.last_dt = dt
            processCount = processCount + 1
        end,
    })
    lurek.scene.push(scene)
    lurek.scene.process(0.016)
    print("process count = " .. processCount)
    print("last dt = " .. tostring(scene.last_dt))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.processPhysics
do
    lurek.scene.clear()
    local physicsCount = 0
    local scene = lurek.scene.new({
        process_physics = function(self, dt)
            self.last_physics_dt = dt
            physicsCount = physicsCount + 1
        end,
    })
    lurek.scene.push(scene)
    lurek.scene.processPhysics(0.016)
    print("physics count = " .. physicsCount)
    print("last physics dt = " .. tostring(scene.last_physics_dt))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.removeData
do
    lurek.scene.clear()
    lurek.scene.setData("_test_key", 42)
    print("before remove = " .. tostring(lurek.scene.hasData("_test_key")))
    lurek.scene.removeData("_test_key")
    print("after remove = " .. tostring(lurek.scene.hasData("_test_key")))
end

--@api-stub: lurek.scene.render
do
    lurek.scene.clear()
    local renderCount = 0
    lurek.scene.push(lurek.scene.new({ render = function() renderCount = renderCount + 1 end }))
    lurek.scene.render()
    print("render count = " .. renderCount)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.renderUi
do
    lurek.scene.clear()
    local uiCount = 0
    lurek.scene.push(lurek.scene.new({ render_ui = function() uiCount = uiCount + 1 end }))
    lurek.scene.renderUi()
    print("render ui count = " .. uiCount)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.setCurrentLayer
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "layer_scene" }))
    local ok = lurek.scene.setCurrentLayer(8)
    print("set layer ok = " .. tostring(ok))
    print("current layer = " .. tostring(lurek.scene.getCurrentLayer()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.unregisterScene
do
    lurek.scene.clear()
    lurek.scene.registerScene("_tmp_unreg", lurek.scene.new({ name = "_tmp_unreg" }))
    print("before unregister = " .. tostring(lurek.scene.hasRegistered("_tmp_unreg")))
    lurek.scene.unregisterScene("_tmp_unreg")
    print("after unregister = " .. tostring(lurek.scene.hasRegistered("_tmp_unreg")))
end

--@api-stub: lurek.scene.getRenderActiveScenes
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "overlay" }))
    local active = lurek.scene.getRenderActiveScenes()
    print("getRenderActiveScenes count = " .. #active)
    print("top render-active = " .. tostring(active[1] and active[1].name))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.setProcessEnabled
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local disabled = lurek.scene.setProcessEnabled(nil, false)
    local enabled = lurek.scene.setProcessEnabled(nil, true)
    print("disabled ok = " .. tostring(disabled))
    print("setProcessEnabled = " .. tostring(lurek.scene.isProcessEnabled()))
    print("enabled ok = " .. tostring(enabled))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.setPhysicsEnabled
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setPhysicsEnabled(nil, false)
    print("setPhysicsEnabled = " .. tostring(lurek.scene.isPhysicsEnabled()))
    lurek.scene.setPhysicsEnabled(nil, true)
    print("after reset = " .. tostring(lurek.scene.isPhysicsEnabled()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.setLateEnabled
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setLateEnabled(nil, false)
    print("setLateEnabled = " .. tostring(lurek.scene.isLateEnabled()))
    lurek.scene.setLateEnabled(nil, true)
    print("after reset = " .. tostring(lurek.scene.isLateEnabled()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.setUpdateEnabled
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setUpdateEnabled(nil, false)
    print("setUpdateEnabled = " .. tostring(lurek.scene.isUpdateEnabled()))
    lurek.scene.setUpdateEnabled(nil, true)
    print("after reset = " .. tostring(lurek.scene.isUpdateEnabled()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.isProcessEnabled
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("isProcessEnabled = " .. tostring(lurek.scene.isProcessEnabled()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.isPhysicsEnabled
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("isPhysicsEnabled = " .. tostring(lurek.scene.isPhysicsEnabled()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.isLateEnabled
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("isLateEnabled = " .. tostring(lurek.scene.isLateEnabled()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.isUpdateEnabled
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("isUpdateEnabled = " .. tostring(lurek.scene.isUpdateEnabled()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.transitions.fade
do
    local transition = lurek.scene.transitions.fade(0.5)
    print("helper type = " .. transition.type)
    print("helper duration = " .. transition.duration)
end

--@api-stub: lurek.scene.transitions.slide
do
    local transition = lurek.scene.transitions.slide("right", 0.4)
    print("helper type = " .. transition.type)
    print("helper duration = " .. transition.duration)
end

--@api-stub: lurek.scene.transitions.wipe
do
    local transition = lurek.scene.transitions.wipe(0.6)
    print("helper type = " .. transition.type)
    print("helper duration = " .. transition.duration)
end

--@api-stub: lurek.scene.transitions.iris
do
    local transition = lurek.scene.transitions.iris(0.8)
    print("helper type = " .. transition.type)
    print("helper duration = " .. transition.duration)
end
