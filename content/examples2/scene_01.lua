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

print("scene_01.lua")
