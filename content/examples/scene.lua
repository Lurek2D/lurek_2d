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
    local GameplayFactory = lurek.scene.define({ name = "gameplay", level = 0, enter = function(self, params) self.level = params and (params.level or 1) or self.level; print("gameplay enter level " .. self.level) end, leave = function() print("gameplay leave") end, update = function() end, draw = function() end })
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
    local sceneA = lurek.scene.new({ name = "level1", enter = function() print("level1 enter") end, leave = function() print("level1 leave") end }); local sceneB = lurek.scene.new({ name = "level2", enter = function(_, params) print("level2 enter, from=" .. (params and params.from or "none")) end, leave = function() print("level2 leave") end })
    lurek.scene.push(sceneA)
    print("before switch: depth=" .. lurek.scene.getStackSize()); lurek.scene.switchTo(sceneB, "none", 0, "linear", { from = "level1" }); print("after switch: depth=" .. lurek.scene.getStackSize())
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
    local updateCount, drawCount, processCount = 0, 0, 0
    local scene = lurek.scene.new({ update = function() updateCount = updateCount + 1 end, draw = function() drawCount = drawCount + 1 end, process = function() processCount = processCount + 1 end, render = function() end, render_ui = function() end })
    lurek.scene.push(scene)
    lurek.scene.update(1 / 60); lurek.scene.process(1 / 60); lurek.scene.draw(); print("updates = " .. updateCount .. " draws = " .. drawCount .. " processes = " .. processCount)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.popTo
do
    local base, mid, top = lurek.scene.new({ name = "base" }), lurek.scene.new({ name = "middle" }), lurek.scene.new({ name = "top" })
    lurek.scene.registerScene("base", base); lurek.scene.registerScene("middle", mid)
    lurek.scene.push(base); lurek.scene.push(mid); lurek.scene.push(top)
    local found, notFound = lurek.scene.popTo("base"), lurek.scene.popTo("nonexistent"); print("popTo base = " .. tostring(found) .. " popTo missing = " .. tostring(notFound) .. " depth = " .. lurek.scene.depth())
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
    print(table.concat(types, ", "))
end

--@api-stub: lurek.scene.queueTransition
do
    lurek.scene.push(lurek.scene.new({}))
    lurek.scene.push(lurek.scene.new({}), "fade", 0.2); lurek.scene.queueTransition("iris", 0.3); lurek.scene.queueTransition("wipe", 0.4, "ease_in")
    print("queued = " .. lurek.scene.getQueuedTransitionCount()); lurek.scene.clearQueuedTransitions(); print("after clear queued = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.pushOverlay
do
    local gameScene = lurek.scene.new({ name = "game", update = function() end, draw = function() lurek.render.setColor(1, 1, 1, 1) end }); local pauseOverlay = lurek.scene.new({ name = "pause", enter = function() print("pause overlay enter") end, draw = function() lurek.render.print("PAUSED", 350, 280) end })
    lurek.scene.push(gameScene); print("overlay before push = " .. tostring(lurek.scene.isOverlay())); lurek.scene.pushOverlay(pauseOverlay, "fade", 0.2)
    print("overlay after push = " .. tostring(lurek.scene.isOverlay()) .. " stack depth = " .. lurek.scene.getStackSize())
    lurek.scene.pop(); print("after pop overlay = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.preload
do
    local loadCount = 0
    lurek.scene.preload("heavyLevel", function() loadCount = loadCount + 1; print("loader executed (count=" .. loadCount .. ")"); lurek.scene.registerScene("heavyLevel", lurek.scene.new({ enter = function() print("heavy level enter") end })) end)
    print("preloaded = " .. tostring(lurek.scene.isPreloaded("heavyLevel")))
    lurek.scene.push(lurek.scene.new({})); lurek.scene.pushPreloaded("heavyLevel", "fade", 0.3); print("after push preloaded = " .. tostring(lurek.scene.isPreloaded("heavyLevel")) .. " load count = " .. loadCount)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getActiveScenes
do
    lurek.scene.push(lurek.scene.new({})); lurek.scene.push(lurek.scene.new({}))
    lurek.scene.pushOverlay(lurek.scene.new({}))
    local active = lurek.scene.getActiveScenes()
    print("active scenes = " .. #active)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.serializeScene
do
    local menu, game = lurek.scene.new({}), lurek.scene.new({})
    lurek.scene.registerScene("menu", menu); lurek.scene.registerScene("game", game); lurek.scene.push(menu); lurek.scene.push(game); lurek.scene.setData("level", 7); lurek.scene.setData("checkpoint", "bridge")
    local snapshot = lurek.scene.serializeScene(); print("stack = " .. #snapshot.stack .. " scenes data.level = " .. tostring(snapshot.data.level) .. " checkpoint = " .. tostring(snapshot.data.checkpoint))
    lurek.scene.clear(); lurek.scene.deserializeScene(snapshot); print("restored level = " .. lurek.scene.getData("level"))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.newDepthSorter
do
    local sorter = lurek.scene.newDepthSorter()
    print("type = " .. sorter:type() .. " is LDepthSorter = " .. tostring(sorter:typeOf("LDepthSorter")))
    sorter:add(function() lurek.render.setColor(1, 0, 0, 1); lurek.render.rectangle("fill", 10, 10, 30, 30) end, 10); sorter:add(function() lurek.render.setColor(0, 0, 1, 1); lurek.render.rectangle("fill", 20, 20, 30, 30) end, 5); sorter:add(function() lurek.render.setColor(0, 1, 0, 1); lurek.render.rectangle("fill", 30, 30, 30, 30) end, 15)
    print("count = " .. sorter:getCount()); sorter:flush(); print("after flush count = " .. sorter:getCount())
    lurek.render.setColor(1, 1, 1, 1)
end

--@api-stub: LDepthSorter:addObject
do
    local sorter = lurek.scene.newDepthSorter()
    local obj1, obj2, obj3 = { depth = 3, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }, { depth = 1, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }, { depth = 7, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }
    sorter:addObject(obj1); sorter:addObject(obj2); sorter:addObject(obj3); print("stable = " .. tostring(sorter:isStable()))
    sorter:setStable(true); print("stable = " .. tostring(sorter:isStable())); sorter:sort(); print("sorted, count = " .. sorter:getCount())
    sorter:clear(); print("cleared count = " .. sorter:getCount())
end

--@api-stub: LDepthSorter:sort
do
    local sorter = lurek.scene.newDepthSorter()
    local obj1, obj2, obj3 = { depth = 3, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }, { depth = 1, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }, { depth = 7, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }
    sorter:addObject(obj1); sorter:addObject(obj2); sorter:addObject(obj3); print("stable = " .. tostring(sorter:isStable()))
    sorter:setStable(true); print("stable = " .. tostring(sorter:isStable())); sorter:sort(); print("sorted, count = " .. sorter:getCount())
    sorter:clear(); print("cleared count = " .. sorter:getCount())
end

--@api-stub: LDepthSorter:clear
do
    local sorter = lurek.scene.newDepthSorter()
    local obj1, obj2, obj3 = { depth = 3, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }, { depth = 1, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }, { depth = 7, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }
    sorter:addObject(obj1); sorter:addObject(obj2); sorter:addObject(obj3); print("stable = " .. tostring(sorter:isStable()))
    sorter:setStable(true); print("stable = " .. tostring(sorter:isStable())); sorter:sort(); print("sorted, count = " .. sorter:getCount())
    sorter:clear(); print("cleared count = " .. sorter:getCount())
end

--@api-stub: LDepthSorter:setStable
do
    local sorter = lurek.scene.newDepthSorter()
    local obj1, obj2, obj3 = { depth = 3, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }, { depth = 1, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }, { depth = 7, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }
    sorter:addObject(obj1); sorter:addObject(obj2); sorter:addObject(obj3); print("stable = " .. tostring(sorter:isStable()))
    sorter:setStable(true); print("stable = " .. tostring(sorter:isStable())); sorter:sort(); print("sorted, count = " .. sorter:getCount())
    sorter:clear(); print("cleared count = " .. sorter:getCount())
end

--@api-stub: LDepthSorter:isStable
do
    local sorter = lurek.scene.newDepthSorter()
    local obj1, obj2, obj3 = { depth = 3, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }, { depth = 1, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }, { depth = 7, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }
    sorter:addObject(obj1); sorter:addObject(obj2); sorter:addObject(obj3); print("stable = " .. tostring(sorter:isStable()))
    sorter:setStable(true); print("stable = " .. tostring(sorter:isStable())); sorter:sort(); print("sorted, count = " .. sorter:getCount())
    sorter:clear(); print("cleared count = " .. sorter:getCount())
end

--@api-stub: lurek.scene.processLate
do
    local lateCount, physCount = 0, 0
    local scene = lurek.scene.new({ process_late = function() lateCount = lateCount + 1 end, process_physics = function() physCount = physCount + 1 end })
    lurek.scene.push(scene)
    lurek.scene.processLate(1 / 60); lurek.scene.processPhysics(1 / 60); print("late = " .. lateCount .. " physics = " .. physCount)
    lurek.scene.clear()
end

--- Scene Part 2: full scene module API coverage
--@api-stub: lurek.scene.clear
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end }))
    lurek.scene.clear()
    print("is empty = " .. tostring(lurek.scene.isEmpty()))
end

--@api-stub: lurek.scene.clearQueuedTransitions
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end })); lurek.scene.queueTransition("fade", 0.25, "linear")
    print("queued before = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clearQueuedTransitions()
    print("queued after = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.deserializeScene
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end }))
    local snapshot = lurek.scene.serializeScene()
    lurek.scene.clear(); lurek.scene.deserializeScene(snapshot)
    print("stack size after load = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.draw
do
    local draws = 0
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "draw_scene", update = function() end, draw = function() draws = draws + 1 end, enter = function() print("enter_draw_scene") end, leave = function() print("leave_draw_scene") end }))
    lurek.scene.draw()
    print("draw calls = " .. draws)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getCurrent
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end }))
    local current = lurek.scene.getCurrent()
    print("current name = " .. tostring(current and current.name))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getCurrentLayer
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end })); lurek.scene.pushOverlay(lurek.scene.new({ name = "pause_overlay", update = function() end, draw = function() end, enter = function() print("enter_pause_overlay") end, leave = function() print("leave_pause_overlay") end }), "fade", 0.2)
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
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end })); lurek.scene.queueTransition("fade", 0.25, "linear")
    print("queued transitions = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getRegistered
do
    lurek.scene.clear(); lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end }))
    local scene = lurek.scene.getRegistered("main_scene")
    print("registered scene = " .. tostring(scene and scene.name))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getRegisteredNames
do
    lurek.scene.clear(); lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end }))
    local names = lurek.scene.getRegisteredNames()
    print("registered names = " .. #names)
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getStackSize
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end }))
    print("stack size = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getTransitionProgress
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "base_scene", update = function() end, draw = function() end, enter = function() print("enter_base_scene") end, leave = function() print("leave_base_scene") end })); lurek.scene.switchTo(lurek.scene.new({ name = "next_scene", update = function() end, draw = function() end, enter = function() print("enter_next_scene") end, leave = function() print("leave_next_scene") end }), "fade", 0.25, "linear")
    print("transition progress = " .. lurek.scene.getTransitionProgress())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.getTransitionProgressEased
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "base_scene", update = function() end, draw = function() end, enter = function() print("enter_base_scene") end, leave = function() print("leave_base_scene") end })); lurek.scene.switchTo(lurek.scene.new({ name = "next_scene", update = function() end, draw = function() end, enter = function() print("enter_next_scene") end, leave = function() print("leave_next_scene") end }), "fade", 0.25, "linear")
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
    lurek.scene.clear(); lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end }))
    print("has main_scene = " .. tostring(lurek.scene.hasRegistered("main_scene")))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.isEmpty
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end }))
    print("before clear = " .. tostring(lurek.scene.isEmpty()))
    lurek.scene.clear()
    print("after clear = " .. tostring(lurek.scene.isEmpty()))
end

--@api-stub: lurek.scene.isOverlay
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end })); lurek.scene.pushOverlay(lurek.scene.new({ name = "pause_overlay", update = function() end, draw = function() end, enter = function() print("enter_pause_overlay") end, leave = function() print("leave_pause_overlay") end }), "fade", 0.2)
    print("top scene is overlay = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.isPreloaded
do
    lurek.scene.clear(); lurek.scene.preload("main_scene", function() lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end })) end)
    print("preloaded = " .. tostring(lurek.scene.isPreloaded("main_scene")))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.isTransitioning
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "base_scene", update = function() end, draw = function() end, enter = function() print("enter_base_scene") end, leave = function() print("leave_base_scene") end })); lurek.scene.switchTo(lurek.scene.new({ name = "next_scene", update = function() end, draw = function() end, enter = function() print("enter_next_scene") end, leave = function() print("leave_next_scene") end }), "fade", 0.25, "linear")
    print("is transitioning = " .. tostring(lurek.scene.isTransitioning()))
    lurek.scene.clear()
end

--@api-stub: lurek.scene.pop
do
    lurek.scene.clear(); lurek.scene.push(lurek.scene.new({ name = "first_scene", update = function() end, draw = function() end, enter = function() print("enter_first_scene") end, leave = function() print("leave_first_scene") end }))
    lurek.scene.push(lurek.scene.new({ name = "second_scene", update = function() end, draw = function() end, enter = function() print("enter_second_scene") end, leave = function() print("leave_second_scene") end }))
    lurek.scene.pop()
    print("stack size after pop = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end

--@api-stub: lurek.scene.pushPreloaded
do
    lurek.scene.clear(); lurek.scene.preload("main_scene", function() lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene", update = function() end, draw = function() end, enter = function() print("enter_main_scene") end, leave = function() print("leave_main_scene") end })) end)
    lurek.scene.push(lurek.scene.new({ name = "base_scene", update = function() end, draw = function() end, enter = function() print("enter_base_scene") end, leave = function() print("leave_base_scene") end }))
    lurek.scene.pushPreloaded("main_scene", "fade", 0.3)
    print("stack size after push = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end

--@api-stub: LDepthSorter:add
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function() lurek.render.circle("fill", 100, 100, 20) end, 5.0); ds:add(function() lurek.render.circle("fill", 200, 100, 20) end, 2.0)
    local count = ds:getCount(); ds:flush()
    print("depth sorter count:", count)
end

--@api-stub: LDepthSorter:flush
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function() lurek.render.circle("fill", 100, 100, 20) end, 5.0); ds:add(function() lurek.render.circle("fill", 200, 100, 20) end, 2.0)
    local count = ds:getCount(); ds:flush()
    print("depth sorter count:", count)
end

--@api-stub: LDepthSorter:getCount
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function() lurek.render.circle("fill", 100, 100, 20) end, 5.0); ds:add(function() lurek.render.circle("fill", 200, 100, 20) end, 2.0)
    local count = ds:getCount(); ds:flush()
    print("depth sorter count:", count)
end

--@api-stub: LDepthSorter:type
do
    local ds = lurek.scene.newDepthSorter()
    local t = ds:type()
    local ok = ds:typeOf("LDepthSorter")
    local sn = lurek.scene.newScene({name = "test_new", enter = function() end, draw = function() end})
    print("type:", t, "newScene ok")
end

--@api-stub: LDepthSorter:typeOf
do
    local ds = lurek.scene.newDepthSorter()
    local t = ds:type()
    local ok = ds:typeOf("LDepthSorter")
    local sn = lurek.scene.newScene({name = "test_new", enter = function() end, draw = function() end})
    print("type:", t, "newScene ok")
end

--@api-stub: lurek.scene.newScene
do
    local ds = lurek.scene.newDepthSorter()
    local t = ds:type()
    local ok = ds:typeOf("LDepthSorter")
    local sn = lurek.scene.newScene({name = "test_new", enter = function() end, draw = function() end})
    print("type:", t, "newScene ok")
end

--@api-stub: lurek.scene.process
do
    lurek.scene.process(0.016)
    lurek.scene.processPhysics(0.016)
    lurek.scene.setData("_test_key", 42)
    lurek.scene.removeData("_test_key")
    print("process, processPhysics, removeData ok")
end

--@api-stub: lurek.scene.processPhysics
do
    lurek.scene.process(0.016)
    lurek.scene.processPhysics(0.016)
    lurek.scene.setData("_test_key", 42)
    lurek.scene.removeData("_test_key")
    print("process, processPhysics, removeData ok")
end

--@api-stub: lurek.scene.removeData
do
    lurek.scene.process(0.016)
    lurek.scene.processPhysics(0.016)
    lurek.scene.setData("_test_key", 42)
    lurek.scene.removeData("_test_key")
    print("process, processPhysics, removeData ok")
end

--@api-stub: lurek.scene.render
do
    lurek.scene.setCurrentLayer(0)
    lurek.scene.render()
    lurek.scene.renderUi()
    local layer = lurek.scene.getCurrentLayer()
    print("render, renderUi, setCurrentLayer ok")
end

--@api-stub: lurek.scene.renderUi
do
    lurek.scene.setCurrentLayer(0)
    lurek.scene.render()
    lurek.scene.renderUi()
    local layer = lurek.scene.getCurrentLayer()
    print("render, renderUi, setCurrentLayer ok")
end

--@api-stub: lurek.scene.setCurrentLayer
do
    lurek.scene.setCurrentLayer(0)
    lurek.scene.render()
    lurek.scene.renderUi()
    local layer = lurek.scene.getCurrentLayer()
    print("render, renderUi, setCurrentLayer ok")
end

--@api-stub: lurek.scene.unregisterScene
do
    lurek.scene.define({name = "_tmp_unreg", enter = function() end, draw = function() end})
    lurek.scene.unregisterScene("_tmp_unreg")
    print("unregisterScene ok")
end

print("content/examples/scene.lua")
