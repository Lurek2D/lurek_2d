-- content/examples/scene.lua
-- Auto-generated from content/examples2/scene_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/scene.lua

--- Scene Module Part 1: scene creation, stack management, registration, shared data, lifecycle





--@api: lurek.scene.new
do

    lurek.scene.clear()
    local enter_count = 0
    local menu_scene = lurek.scene.new({ name = "menu", enter = function(self, params) self.mode = params.mode; enter_count = enter_count + 1 end, draw = function() end })
    lurek.scene.push(menu_scene, nil, nil, nil, { mode = "story" })
    local current = lurek.scene.getCurrent()
    local depth = lurek.scene.getStackSize()
    lurek.log.info("new current=" .. tostring(current and current.name) .. " mode=" .. tostring(current and current.mode) .. " enters=" .. tostring(enter_count) .. " depth=" .. tostring(depth))
    lurek.scene.clear()
end

--@api: lurek.scene.define
do

local GameplayFactory = lurek.scene.define({
name = "gameplay",
level = 0,
enter = function(self, params)
self.level = params and (params.level or 1) or self.level
lurek.log.info("gameplay enter level " .. self.level)
end,
leave = function()
lurek.log.info("gameplay leave")
end,
update = function()
end,
draw = function()
end,
})
local instance1 = GameplayFactory()
end

--@api: lurek.scene.push
do

    lurek.scene.clear()
    local title_scene = lurek.scene.new({ name = "title", enter = function(self, params) self.selected_slot = params.slot end })
    lurek.scene.push(title_scene, nil, nil, nil, { slot = 2 })
    local current = lurek.scene.getCurrent()
    local depth = lurek.scene.getStackSize()
    local layer = lurek.scene.getCurrentLayer()
    lurek.log.info("push current=" .. tostring(current and current.name) .. " slot=" .. tostring(current and current.selected_slot) .. " depth=" .. tostring(depth) .. " layer=" .. tostring(layer))
    lurek.scene.clear()
end

--@api: lurek.scene.switchTo
do

local sceneA = lurek.scene.new({
name = "level1",
enter = function()
lurek.log.info("level1 enter")
end,
leave = function()
lurek.log.info("level1 leave")
end,
})
end

--@api: lurek.scene.registerScene
do

    lurek.scene.clear()
    local menu_scene = lurek.scene.new({ name = "mainMenu" })
    lurek.scene.registerScene("mainMenu", menu_scene)
    local stored = lurek.scene.getRegistered("mainMenu")
    local names = lurek.scene.getRegisteredNames()
    local has_menu = lurek.scene.hasRegistered("mainMenu")
    lurek.log.info("registerScene stored=" .. tostring(stored and stored.name) .. " has_menu=" .. tostring(has_menu) .. " name_count=" .. tostring(#names))
end

--@api: lurek.scene.setData
do

    lurek.scene.clear()
    lurek.scene.setData("selectedLevel", 5)
    lurek.scene.setData("entryScene", "hangar")
    local has_level = lurek.scene.hasData("selectedLevel")
    local level = lurek.scene.getData("selectedLevel")
    local entry = lurek.scene.getData("entryScene")
    lurek.log.info("setData has_level=" .. tostring(has_level) .. " level=" .. tostring(level) .. " entry=" .. tostring(entry))
end

--@api: lurek.scene.popTo
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
    lurek.log.info("popTo base = " .. tostring(found))
    lurek.log.info("popTo missing = " .. tostring(missing) .. " depth = " .. lurek.scene.depth())
    lurek.scene.clear()
end

--- Scene Module Part 2: transitions, overlays, preload, depth sorter, serialization

--@api: lurek.scene.transitions.fade
do

    local fade = lurek.scene.transitions.fade(0.5)
    local default_fade = lurek.scene.transitions.fade()
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "boot" }))
    lurek.scene.queueTransition(fade.type, fade.duration, "linear")
    local queued = lurek.scene.getQueuedTransitionCount()
    lurek.log.info("fade type=" .. fade.type .. " dur=" .. tostring(fade.duration) .. " default=" .. tostring(default_fade.duration) .. " queued=" .. tostring(queued))
    lurek.scene.clear()
end

--@api: lurek.scene.transitions.slide
do

    local slide = lurek.scene.transitions.slide("right", 0.4)
    local default_slide = lurek.scene.transitions.slide()
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "map" }))
    lurek.scene.queueTransition(slide.type, slide.duration, "ease_in")
    local queued = lurek.scene.getQueuedTransitionCount()
    lurek.log.info("slide type=" .. slide.type .. " dur=" .. tostring(slide.duration) .. " default=" .. default_slide.type .. " queued=" .. tostring(queued))
    lurek.scene.clear()
end

--@api: lurek.scene.transitions.iris
do

    local iris = lurek.scene.transitions.iris(0.6)
    local default_iris = lurek.scene.transitions.iris()
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "cutscene" }))
    lurek.scene.queueTransition(iris.type, iris.duration, "ease_out")
    local queued = lurek.scene.getQueuedTransitionCount()
    lurek.log.info("iris type=" .. iris.type .. " dur=" .. tostring(iris.duration) .. " default=" .. tostring(default_iris.duration) .. " queued=" .. tostring(queued))
    lurek.scene.clear()
end

--@api: lurek.scene.transitions.wipe
do

    local wipe = lurek.scene.transitions.wipe(0.5)
    local default_wipe = lurek.scene.transitions.wipe()
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "credits" }))
    lurek.scene.queueTransition(wipe.type, wipe.duration, "linear")
    local queued = lurek.scene.getQueuedTransitionCount()
    lurek.log.info("wipe type=" .. wipe.type .. " dur=" .. tostring(wipe.duration) .. " default=" .. tostring(default_wipe.duration) .. " queued=" .. tostring(queued))
    lurek.scene.clear()
end

--@api: lurek.scene.getTransitionTypes
do

    local types = lurek.scene.getTransitionTypes()
    local has_fade = false
    local has_zoom = false
    local has_crossfade = false
    for _, value in ipairs(types) do
        has_fade = has_fade or value == "fade"
        has_zoom = has_zoom or value == "zoom"
        has_crossfade = has_crossfade or value == "crossfade"
    end
    local first = types[1] or "none"
    lurek.log.info("getTransitionTypes count=" .. tostring(#types) .. " first=" .. tostring(first) .. " fade=" .. tostring(has_fade) .. " zoom=" .. tostring(has_zoom) .. " crossfade=" .. tostring(has_crossfade))
end

--@api: lurek.scene.queueTransition
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base" }))
    lurek.scene.queueTransition("fade", 0.2)
    lurek.scene.queueTransition("iris", 0.3)
    lurek.scene.queueTransition("wipe", 0.4, "ease_in")
    lurek.log.info("queued = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clearQueuedTransitions()
    lurek.log.info("after clear queued = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end

--@api: lurek.scene.pushOverlay
do

    lurek.scene.clear()
    local gameScene = lurek.scene.new({ name = "game" })
    local pauseOverlay = lurek.scene.new({ name = "pause" })
    lurek.scene.push(gameScene)
    lurek.log.info("overlay before push = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.pushOverlay(pauseOverlay, "fade", 0.2)
    lurek.log.info("overlay after push = " .. tostring(lurek.scene.isOverlay()) .. " stack depth = " .. lurek.scene.getStackSize())
    lurek.scene.pop()
    lurek.log.info("after pop overlay = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.clear()
end

--@api: lurek.scene.preload
do

    local loadCount = 0
    lurek.scene.clear()
    lurek.scene.preload("heavyLevel", function()
        loadCount = loadCount + 1
        lurek.scene.registerScene("heavyLevel", lurek.scene.new({ name = "heavyLevel" }))
    end)
    lurek.log.info("preloaded = " .. tostring(lurek.scene.isPreloaded("heavyLevel")))
    lurek.scene.push(lurek.scene.new({ name = "loader" }))
    lurek.scene.pushPreloaded("heavyLevel", "fade", 0.3)
    lurek.log.info("after push preloaded = " .. tostring(lurek.scene.isPreloaded("heavyLevel")) .. " load count = " .. loadCount)
    lurek.scene.clear()
end

--@api: lurek.scene.getActiveScenes
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base" }))
    lurek.scene.push(lurek.scene.new({ name = "mid" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "overlay" }))
    local active = lurek.scene.getActiveScenes()
    lurek.log.info("active scenes = " .. #active)
    lurek.log.info("top active = " .. tostring(active[#active] and active[#active].name))
    lurek.scene.clear()
end

--@api: lurek.scene.serializeScene
do

    lurek.scene.clear()
    local menu = lurek.scene.new({ name = "menu" })
    local game = lurek.scene.new({ name = "game" })
    lurek.scene.registerScene("menu", menu)
    lurek.scene.registerScene("game", game)
    lurek.scene.pushRegistered("menu")
    lurek.scene.pushRegistered("game")
    lurek.scene.setData("level", 7)
    lurek.scene.setData("checkpoint", "bridge")
    local snapshot = lurek.scene.serializeScene()
    lurek.log.info("stack = " .. #snapshot.stack)
    lurek.log.info("saved level = " .. tostring(snapshot.data.level) .. " checkpoint = " .. tostring(snapshot.data.checkpoint))
    lurek.scene.clear()
    lurek.scene.deserializeScene(snapshot)
    lurek.log.info("restored level = " .. tostring(lurek.scene.getData("level")))
    lurek.scene.clear()
end

--@api: lurek.scene.newDepthSorter
do

    local sorter = lurek.scene.newDepthSorter()
    lurek.log.info("type = " .. sorter:type() .. " is LDepthSorter = " .. tostring(sorter:typeOf("LDepthSorter")))
    sorter:add(function()
        lurek.log.info("draw back layer")
    end, 10)
    sorter:add(function()
        lurek.log.info("draw front layer")
    end, 15)
    lurek.log.info("count = " .. sorter:getCount())
    sorter:flush()
    lurek.log.info("after flush count = " .. sorter:getCount())
end

--@api: LDepthSorter:addObject
do

    local sorter = lurek.scene.newDepthSorter()
    local obj1 = { depth = 3, drawSorted = function(self) lurek.log.info("draw obj at depth " .. self.depth) end }
    local obj2 = { depth = 1, drawSorted = function(self) lurek.log.info("draw obj at depth " .. self.depth) end }
    sorter:addObject(obj1)
    sorter:addObject(obj2)
    lurek.log.info("count = " .. sorter:getCount())
    sorter:flush()
end

--@api: LDepthSorter:sort
do

    local sorter = lurek.scene.newDepthSorter()
    sorter:add(function()
        lurek.log.info("sorted callback")
    end, 2)
    sorter:add(function()
        lurek.log.info("sorted callback 2")
    end, 1)
    sorter:sort()
    lurek.log.info("sorted, count = " .. sorter:getCount())
    sorter:clear()
end

--@api: LDepthSorter:clear
do

    local sorter = lurek.scene.newDepthSorter()
    sorter:add(function()
        lurek.log.info("queued callback")
    end, 3)
    lurek.log.info("before clear count = " .. sorter:getCount())
    sorter:clear()
    lurek.log.info("cleared count = " .. sorter:getCount())
end

--@api: LDepthSorter:setStable
do

    local sorter = lurek.scene.newDepthSorter()
    sorter:setStable(true)
    lurek.log.info("stable = " .. tostring(sorter:isStable()))
    sorter:setStable(false)
    lurek.log.info("stable after disable = " .. tostring(sorter:isStable()))
end

--@api: LDepthSorter:isStable
do

    local sorter = lurek.scene.newDepthSorter()
    local before = sorter:isStable()
    sorter:setStable(true)
    local enabled = sorter:isStable()
    sorter:setStable(false)
    local disabled = sorter:isStable()
    sorter:add(function() end, 2)
    lurek.log.info("LDepthSorter:isStable before=" .. tostring(before) .. " enabled=" .. tostring(enabled) .. " disabled=" .. tostring(disabled) .. " count=" .. tostring(sorter:getCount()))
end

--@api: lurek.scene.processLate
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
    lurek.log.info("late = " .. lateCount .. " physics = " .. physCount)
    lurek.scene.clear()
end

--- Scene Part 2: full scene module API coverage
--@api: lurek.scene.clear
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.push(lurek.scene.new({ name = "pause_scene" }))
    local before = lurek.scene.getStackSize()
    lurek.scene.clear()
    local after = lurek.scene.getStackSize()
    local empty = lurek.scene.isEmpty()
    lurek.log.info("clear before=" .. tostring(before) .. " after=" .. tostring(after) .. " empty=" .. tostring(empty))
end

--@api: lurek.scene.clearQueuedTransitions
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.queueTransition("fade", 0.25, "linear")
    lurek.log.info("queued before = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clearQueuedTransitions()
    lurek.log.info("queued after = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end

--@api: lurek.scene.deserializeScene
do

    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    local snapshot = lurek.scene.serializeScene()
    lurek.scene.removeData("score")
    lurek.scene.deserializeScene(snapshot)
    lurek.log.info("restored score = " .. tostring(lurek.scene.getData("score")))
    lurek.log.info("stack size after load = " .. lurek.scene.getStackSize())
end

--@api: lurek.scene.restoreScene
do

lurek.scene.clear()
local menu = lurek.scene.new({ name = "menu" })
local game = lurek.scene.new({ name = "game" })
lurek.scene.registerScene("menu_restore", menu)
lurek.scene.registerScene("game_restore", game)
lurek.scene.pushRegistered("menu_restore")
lurek.scene.pushRegistered("game_restore")
lurek.scene.setData("chapter", "bridge")
local snapshot = lurek.scene.serializeScene()
lurek.scene.clear()
local restored = lurek.scene.restoreScene(snapshot, {
params = {
game_restore = { fromSave = true },
},
})
lurek.log.info("restored stack count = " .. tostring(restored))
end

--@api: lurek.scene.draw
do

    local draws = 0
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "draw_scene", draw = function() draws = draws + 1 end }))
    lurek.scene.draw()
    lurek.log.info("draw calls = " .. draws)
    lurek.scene.clear()
end

--@api: lurek.scene.getCurrent
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local current = lurek.scene.getCurrent()
    lurek.log.info("current name = " .. tostring(current and current.name))
    lurek.scene.clear()
end

--@api: lurek.scene.getCurrentLayer
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setCurrentLayer(12)
    lurek.log.info("current layer = " .. tostring(lurek.scene.getCurrentLayer()))
    lurek.scene.clear()
end

--@api: lurek.scene.getData
do

    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    lurek.scene.setData("checkpoint", "hangar")
    local score = lurek.scene.getData("score")
    local checkpoint = lurek.scene.getData("checkpoint")
    local has_score = lurek.scene.hasData("score")
    lurek.log.info("getData score=" .. tostring(score) .. " checkpoint=" .. tostring(checkpoint) .. " has_score=" .. tostring(has_score))
end

--@api: lurek.scene.getQueuedTransitionCount
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.queueTransition("fade", 0.25, "linear")
    lurek.log.info("queued transitions = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end

--@api: lurek.scene.getRegistered
do

    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    local scene = lurek.scene.getRegistered("main_scene")
    local names = lurek.scene.getRegisteredNames()
    local has_scene = lurek.scene.hasRegistered("main_scene")
    local first = names[1] or "none"
    lurek.log.info("getRegistered name=" .. tostring(scene and scene.name) .. " has_scene=" .. tostring(has_scene) .. " first=" .. tostring(first))
end

--@api: lurek.scene.getRegisteredNames
do

    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    lurek.scene.registerScene("pause_scene", lurek.scene.new({ name = "pause_scene" }))
    local names = lurek.scene.getRegisteredNames()
    lurek.log.info("registered names = " .. #names)
    lurek.log.info("first name = " .. tostring(names[1]))
end

--@api: lurek.scene.getStackSize
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "pause_overlay" }), "fade", 0.2)
    local depth = lurek.scene.getStackSize()
    local current = lurek.scene.getCurrent()
    local overlay = lurek.scene.isOverlay()
    lurek.log.info("getStackSize depth=" .. tostring(depth) .. " current=" .. tostring(current and current.name) .. " overlay=" .. tostring(overlay))
    lurek.scene.clear()
end

--@api: lurek.scene.getTransitionProgress
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    lurek.log.info("transition progress = " .. lurek.scene.getTransitionProgress())
    lurek.scene.clear()
end

--@api: lurek.scene.getTransitionProgressEased
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    lurek.log.info("eased progress = " .. lurek.scene.getTransitionProgressEased())
    lurek.scene.clear()
end

--@api: lurek.scene.hasData
do

    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    local has_score = lurek.scene.hasData("score")
    local has_hp = lurek.scene.hasData("hp")
    local score = lurek.scene.getData("score")
    lurek.log.info("hasData score=" .. tostring(has_score) .. " hp=" .. tostring(has_hp) .. " value=" .. tostring(score))
end

--@api: lurek.scene.hasRegistered
do

    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    local has_main = lurek.scene.hasRegistered("main_scene")
    local has_pause = lurek.scene.hasRegistered("pause_scene")
    local names = lurek.scene.getRegisteredNames()
    lurek.log.info("hasRegistered main=" .. tostring(has_main) .. " pause=" .. tostring(has_pause) .. " count=" .. tostring(#names))
end

--@api: lurek.scene.isEmpty
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.log.info("before clear = " .. tostring(lurek.scene.isEmpty()))
    lurek.scene.clear()
    lurek.log.info("after clear = " .. tostring(lurek.scene.isEmpty()))
end

--@api: lurek.scene.isOverlay
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "pause_overlay" }), "fade", 0.2)
    lurek.log.info("top scene is overlay = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.clear()
end

--@api: lurek.scene.isPreloaded
do

    lurek.scene.clear()
    lurek.scene.preload("main_scene", function()
        lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    end)
    lurek.log.info("preloaded = " .. tostring(lurek.scene.isPreloaded("main_scene")))
    lurek.scene.push(lurek.scene.new({ name = "loader" }))
    lurek.scene.pushPreloaded("main_scene")
    lurek.log.info("after push = " .. tostring(lurek.scene.isPreloaded("main_scene")))
    lurek.scene.clear()
end

--@api: lurek.scene.isTransitioning
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    lurek.log.info("is transitioning = " .. tostring(lurek.scene.isTransitioning()))
    lurek.scene.clear()
end

--@api: lurek.scene.pop
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "first_scene" }))
    lurek.scene.push(lurek.scene.new({ name = "second_scene" }))
    lurek.scene.pop()
    lurek.log.info("stack size after pop = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end

--@api: lurek.scene.pushPreloaded
do

    lurek.scene.clear()
    lurek.scene.preload("main_scene", function()
        lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    end)
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.pushPreloaded("main_scene", "fade", 0.3)
    lurek.log.info("stack size after push = " .. lurek.scene.getStackSize())
    lurek.log.info("current = " .. tostring(lurek.scene.getCurrent() and lurek.scene.getCurrent().name))
    lurek.scene.clear()
end

--@api: LDepthSorter:add
do

    local ds = lurek.scene.newDepthSorter()
    ds:add(function()
        lurek.log.info("draw circle A")
    end, 5.0)
    ds:add(function()
        lurek.log.info("draw circle B")
    end, 2.0)
    local count = ds:getCount()
    ds:flush()
    lurek.log.info("depth sorter count = " .. count)
end

--@api: LDepthSorter:flush
do

    local ds = lurek.scene.newDepthSorter()
    ds:add(function()
        lurek.log.info("flush callback A")
    end, 5.0)
    ds:add(function()
        lurek.log.info("flush callback B")
    end, 2.0)
    local count = ds:getCount()
    ds:flush()
    lurek.log.info("depth sorter count = " .. count)
end

--@api: LDepthSorter:getCount
do

    local ds = lurek.scene.newDepthSorter()
    ds:add(function()
        lurek.log.info("count callback")
    end, 5.0)
    ds:add(function()
        lurek.log.info("count callback 2")
    end, 2.0)
    lurek.log.info("depth sorter count = " .. ds:getCount())
    ds:clear()
end

--@api: LDepthSorter:type
do

    local ds = lurek.scene.newDepthSorter()
    local type_name = ds:type()
    local is_sorter = ds:typeOf("LDepthSorter")
    local is_object = ds:typeOf("Object")
    ds:add(function() end, 1)
    lurek.log.info("LDepthSorter:type name=" .. type_name .. " sorter=" .. tostring(is_sorter) .. " object=" .. tostring(is_object) .. " count=" .. tostring(ds:getCount()))
end

--@api: LDepthSorter:typeOf
do

    local ds = lurek.scene.newDepthSorter()
    local is_sorter = ds:typeOf("LDepthSorter")
    local is_object = ds:typeOf("Object")
    local is_container = ds:typeOf("LSceneObjectContainer")
    ds:setStable(true)
    lurek.log.info("LDepthSorter:typeOf sorter=" .. tostring(is_sorter) .. " object=" .. tostring(is_object) .. " container=" .. tostring(is_container) .. " stable=" .. tostring(ds:isStable()))
end

--@api: lurek.scene.newScene
do

    lurek.scene.clear()
    local scene = lurek.scene.newScene({ name = "test_new", enter = function(self, params) self.spawn = params.spawn end })
    lurek.scene.push(scene, nil, nil, nil, { spawn = "dock" })
    local current = lurek.scene.getCurrent()
    local has_metatable = getmetatable(scene) ~= nil
    lurek.log.info("newScene name=" .. tostring(current and current.name) .. " spawn=" .. tostring(current and current.spawn) .. " metatable=" .. tostring(has_metatable))
    lurek.scene.clear()
end

--@api: lurek.scene.process
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
    lurek.log.info("process count = " .. processCount)
    lurek.log.info("last dt = " .. tostring(scene.last_dt))
    lurek.scene.clear()
end

--@api: lurek.scene.processPhysics
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
    lurek.log.info("physics count = " .. physicsCount)
    lurek.log.info("last physics dt = " .. tostring(scene.last_physics_dt))
    lurek.scene.clear()
end

--@api: lurek.scene.removeData
do

    lurek.scene.clear()
    lurek.scene.setData("_test_key", 42)
    lurek.log.info("before remove = " .. tostring(lurek.scene.hasData("_test_key")))
    lurek.scene.removeData("_test_key")
    lurek.log.info("after remove = " .. tostring(lurek.scene.hasData("_test_key")))
end

--@api: lurek.scene.render
do

    lurek.scene.clear()
    local renderCount = 0
    lurek.scene.push(lurek.scene.new({ render = function() renderCount = renderCount + 1 end }))
    lurek.scene.render()
    lurek.log.info("render count = " .. renderCount)
    lurek.scene.clear()
end

--@api: lurek.scene.renderUi
do

    lurek.scene.clear()
    local uiCount = 0
    lurek.scene.push(lurek.scene.new({ render_ui = function() uiCount = uiCount + 1 end }))
    lurek.scene.renderUi()
    lurek.log.info("render ui count = " .. uiCount)
    lurek.scene.clear()
end

--@api: lurek.scene.setCurrentLayer
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "layer_scene" }))
    local ok = lurek.scene.setCurrentLayer(8)
    lurek.log.info("set layer ok = " .. tostring(ok))
    lurek.log.info("current layer = " .. tostring(lurek.scene.getCurrentLayer()))
    lurek.scene.clear()
end

--@api: lurek.scene.unregisterScene
do

    lurek.scene.clear()
    lurek.scene.registerScene("_tmp_unreg", lurek.scene.new({ name = "_tmp_unreg" }))
    lurek.log.info("before unregister = " .. tostring(lurek.scene.hasRegistered("_tmp_unreg")))
    lurek.scene.unregisterScene("_tmp_unreg")
    lurek.log.info("after unregister = " .. tostring(lurek.scene.hasRegistered("_tmp_unreg")))
end

--@api: lurek.scene.getRenderActiveScenes
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "overlay" }))
    local active = lurek.scene.getRenderActiveScenes()
    lurek.log.info("getRenderActiveScenes count = " .. #active)
    lurek.log.info("top render-active = " .. tostring(active[1] and active[1].name))
    lurek.scene.clear()
end

--@api: lurek.scene.setProcessEnabled
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local disabled = lurek.scene.setProcessEnabled(nil, false)
    local enabled = lurek.scene.setProcessEnabled(nil, true)
    lurek.log.info("disabled ok = " .. tostring(disabled))
    lurek.log.info("setProcessEnabled = " .. tostring(lurek.scene.isProcessEnabled()))
    lurek.log.info("enabled ok = " .. tostring(enabled))
    lurek.scene.clear()
end

--@api: lurek.scene.setPhysicsEnabled
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setPhysicsEnabled(nil, false)
    lurek.log.info("setPhysicsEnabled = " .. tostring(lurek.scene.isPhysicsEnabled()))
    lurek.scene.setPhysicsEnabled(nil, true)
    lurek.log.info("after reset = " .. tostring(lurek.scene.isPhysicsEnabled()))
    lurek.scene.clear()
end

--@api: lurek.scene.setLateEnabled
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setLateEnabled(nil, false)
    lurek.log.info("setLateEnabled = " .. tostring(lurek.scene.isLateEnabled()))
    lurek.scene.setLateEnabled(nil, true)
    lurek.log.info("after reset = " .. tostring(lurek.scene.isLateEnabled()))
    lurek.scene.clear()
end

--@api: lurek.scene.setUpdateEnabled
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setUpdateEnabled(nil, false)
    lurek.log.info("setUpdateEnabled = " .. tostring(lurek.scene.isUpdateEnabled()))
    lurek.scene.setUpdateEnabled(nil, true)
    lurek.log.info("after reset = " .. tostring(lurek.scene.isUpdateEnabled()))
    lurek.scene.clear()
end

--@api: lurek.scene.isProcessEnabled
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local before = lurek.scene.isProcessEnabled()
    lurek.scene.setProcessEnabled(nil, false)
    local disabled = lurek.scene.isProcessEnabled()
    lurek.scene.setProcessEnabled(nil, true)
    local restored = lurek.scene.isProcessEnabled()
    lurek.log.info("isProcessEnabled before=" .. tostring(before) .. " disabled=" .. tostring(disabled) .. " restored=" .. tostring(restored))
    lurek.scene.clear()
end

--@api: lurek.scene.isPhysicsEnabled
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local before = lurek.scene.isPhysicsEnabled()
    lurek.scene.setPhysicsEnabled(nil, false)
    local disabled = lurek.scene.isPhysicsEnabled()
    lurek.scene.setPhysicsEnabled(nil, true)
    local restored = lurek.scene.isPhysicsEnabled()
    lurek.log.info("isPhysicsEnabled before=" .. tostring(before) .. " disabled=" .. tostring(disabled) .. " restored=" .. tostring(restored))
    lurek.scene.clear()
end

--@api: lurek.scene.isLateEnabled
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local before = lurek.scene.isLateEnabled()
    lurek.scene.setLateEnabled(nil, false)
    local disabled = lurek.scene.isLateEnabled()
    lurek.scene.setLateEnabled(nil, true)
    local restored = lurek.scene.isLateEnabled()
    lurek.log.info("isLateEnabled before=" .. tostring(before) .. " disabled=" .. tostring(disabled) .. " restored=" .. tostring(restored))
    lurek.scene.clear()
end

--@api: lurek.scene.isUpdateEnabled
do

    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local before = lurek.scene.isUpdateEnabled()
    lurek.scene.setUpdateEnabled(nil, false)
    local disabled = lurek.scene.isUpdateEnabled()
    lurek.scene.setUpdateEnabled(nil, true)
    local restored = lurek.scene.isUpdateEnabled()
    lurek.log.info("isUpdateEnabled before=" .. tostring(before) .. " disabled=" .. tostring(disabled) .. " restored=" .. tostring(restored))
    lurek.scene.clear()
end

--@api: lurek.scene.update
do

    -- update advances transitions and dispatches the update callback to the top scene
    lurek.scene.clear()
    local s = lurek.scene.new({ name = "update_test" })
    lurek.scene.push(s)
    lurek.scene.update(0.016)
    lurek.scene.clear()
    lurek.log.info("lurek.scene.update ok")
end

--@api: lurek.scene.depth
do

    lurek.scene.clear()
    local d0 = lurek.scene.depth()
    lurek.scene.push(lurek.scene.new({ name = "d1" }))
    local d1 = lurek.scene.depth()
    lurek.scene.clear()
    lurek.log.info("depth 0=" .. d0 .. " 1=" .. d1)
end

--@api: lurek.scene.newObjectContainer
do

local container = lurek.scene.newObjectContainer()

local player = {
layer = 1,
x = 10,
y = 20,
update = function(self, dt)
self.x = self.x + dt * 100
end,
draw = function(self)
lurek.log.info("Drawing player at x=" .. self.x .. ", y=" .. self.y)
end
}
end

--@api: LSceneObjectContainer:add
do

    local container = lurek.scene.newObjectContainer()
    local obj = { id = "player", layer = 2 }
    container:add(obj)
    local count = container:getCount()
    local has_obj = container:has(obj)
    local objects = container:getObjects()
    lurek.log.info("LSceneObjectContainer:add count=" .. tostring(count) .. " has_obj=" .. tostring(has_obj) .. " first=" .. tostring(objects[1] and objects[1].id))
end

--@api: LSceneObjectContainer:clear
do

    local container = lurek.scene.newObjectContainer()
    container:add({ id = "background", layer = 1 })
    container:add({ id = "player", layer = 2 })
    local before = container:getCount()
    container:clear()
    local after = container:getCount()
    local objects = container:getObjects()
    lurek.log.info("LSceneObjectContainer:clear before=" .. tostring(before) .. " after=" .. tostring(after) .. " remaining=" .. tostring(#objects))
end

--@api: LSceneObjectContainer:draw
do

    local container = lurek.scene.newObjectContainer()
    local draws = 0
    container:add({ id = "background", layer = 1, draw = function() draws = draws + 1 end })
    container:add({ id = "player", layer = 2, draw = function() draws = draws + 1 end })
    container:draw()
    local count = container:getCount()
    lurek.log.info("LSceneObjectContainer:draw count=" .. tostring(count) .. " draws=" .. tostring(draws))
end

--@api: LSceneObjectContainer:getByLayer
do

    local container = lurek.scene.newObjectContainer()
    container:add({ id = "background", layer = 1 })
    container:add({ id = "player", layer = 3 })
    container:add({ id = "cursor", layer = 3 })
    local objects = container:getByLayer(3)
    local first = objects[1] and objects[1].id or "none"
    local second = objects[2] and objects[2].id or "none"
    lurek.log.info("LSceneObjectContainer:getByLayer count=" .. tostring(#objects) .. " first=" .. first .. " second=" .. second)
end

--@api: LSceneObjectContainer:getCount
do

    local container = lurek.scene.newObjectContainer()
    container:add({ id = "background", layer = 1 })
    container:add({ id = "player", layer = 2 })
    local count = container:getCount()
    local objects = container:getObjects()
    local top = objects[#objects] and objects[#objects].id or "none"
    lurek.log.info("LSceneObjectContainer:getCount count=" .. tostring(count) .. " top=" .. top)
end

--@api: LSceneObjectContainer:getObjects
do

    local container = lurek.scene.newObjectContainer()
    container:add({ id = "player", layer = 2 })
    container:add({ id = "background", layer = 1 })
    local objects = container:getObjects()
    local first = objects[1] and objects[1].id or "none"
    local last = objects[#objects] and objects[#objects].id or "none"
    local count = container:getCount()
    lurek.log.info("LSceneObjectContainer:getObjects count=" .. tostring(count) .. " first=" .. first .. " last=" .. last)
end

--@api: LSceneObjectContainer:has
do

    local container = lurek.scene.newObjectContainer()
    local obj = { id = "player", layer = 1 }
    container:add(obj)
    local present = container:has(obj)
    local missing = container:has({ id = "ghost", layer = 1 })
    local count = container:getCount()
    lurek.log.info("LSceneObjectContainer:has present=" .. tostring(present) .. " missing=" .. tostring(missing) .. " count=" .. tostring(count))
end

--@api: LSceneObjectContainer:remove
do

    local container = lurek.scene.newObjectContainer()
    local obj = { layer = 1 }
    container:add(obj)
    container:remove(obj)
    lurek.log.info("count after remove = " .. container:getCount())
end

--@api: LSceneObjectContainer:type
do

    local container = lurek.scene.newObjectContainer()
    local type_name = container:type()
    local matches = container:typeOf("LSceneObjectContainer")
    local other = container:typeOf("LDepthSorter")
    local count = container:getCount()
    lurek.log.info("LSceneObjectContainer:type name=" .. type_name .. " matches=" .. tostring(matches) .. " other=" .. tostring(other) .. " count=" .. tostring(count))
end

--@api: LSceneObjectContainer:typeOf
do

    local container = lurek.scene.newObjectContainer()
    local matches = container:typeOf("LSceneObjectContainer")
    local sorter = container:typeOf("LDepthSorter")
    container:add({ id = "player", layer = 1 })
    local count = container:getCount()
    lurek.log.info("LSceneObjectContainer:typeOf container=" .. tostring(matches) .. " sorter=" .. tostring(sorter) .. " count=" .. tostring(count))
end

--@api: LSceneObjectContainer:update
do

    local container = lurek.scene.newObjectContainer()
    local ticks = 0
    container:add({
        layer = 1,
        update = function(_, dt)
            if dt > 0 then
                ticks = ticks + 1
            end
        end,
    })
    container:update(1 / 60)
    lurek.log.info("updates called = " .. tostring(ticks))
end

--@api: lurek.scene.pushRegistered
do

    lurek.scene.clear()
    local order = {}
    lurek.scene.registerScene("registered_flow_example", {
        create = function(self) order[#order + 1] = "create" end,
        before_enter = function(self) order[#order + 1] = "before_enter" end,
        enter = function(self, params) order[#order + 1] = "enter:" .. tostring(params.level) end,
        after_enter = function(self) order[#order + 1] = "after_enter" end,
    }, { persistence = "freeze" })
    lurek.scene.pushRegistered("registered_flow_example", nil, nil, nil, { level = 2 })
    lurek.log.info("pushRegistered order=" .. table.concat(order, ","))
    lurek.scene.unregisterScene("registered_flow_example")
    lurek.scene.clear()
end

--@api: lurek.scene.setSceneActive
do

    lurek.scene.clear()
    local updates = 0
    local scene = { update = function(self, dt) updates = updates + 1 end }
    lurek.scene.push(scene)
    lurek.scene.setSceneActive(nil, false)
    lurek.scene.update(1 / 60)
    lurek.log.info("setSceneActive updates=" .. tostring(updates) .. " active=" .. tostring(lurek.scene.isSceneActive()))
    lurek.scene.clear()
end

--@api: lurek.scene.isSceneActive
do

    lurek.scene.clear()
    lurek.scene.push({ name = "activity_probe" })
    local before = lurek.scene.isSceneActive()
    lurek.scene.setSceneActive(nil, false)
    local after = lurek.scene.isSceneActive()
    lurek.log.info("isSceneActive before=" .. tostring(before) .. " after=" .. tostring(after))
    lurek.scene.clear()
end

--@api: LSceneObjectContainer:defineGroup
do

    local container = lurek.scene.newObjectContainer()
    local physics_bit = container:defineGroup("physics")
    local ui_bit = container:defineGroup("ui")
    local same = physics_bit == container:defineGroup("physics")
    lurek.log.info("defineGroup physics=" .. tostring(physics_bit) .. " ui=" .. tostring(ui_bit) .. " stable=" .. tostring(same))
end

--@api: LSceneObjectContainer:getGroupBit
do

    local container = lurek.scene.newObjectContainer()
    container:defineGroup("projectiles")
    local bit = container:getGroupBit("projectiles")
    local missing = container:getGroupBit("missing")
    lurek.log.info("getGroupBit projectiles=" .. tostring(bit) .. " missing=" .. tostring(missing))
end

--@api: LSceneObjectContainer:setGroupEnabled
do

    local container = lurek.scene.newObjectContainer()
    container:defineGroup("background")
    local updates = 0
    container:add({ group = "background", update = function(self, dt) updates = updates + 1 end })
    container:setGroupEnabled("background", "update", false)
    container:update(1 / 60)
    container:setGroupEnabled("background", "update", true)
    container:update(1 / 60)
    lurek.log.info("setGroupEnabled updates=" .. tostring(updates))
end

--@api: LSceneObjectContainer:isGroupEnabled
do

    local container = lurek.scene.newObjectContainer()
    container:defineGroup("physics")
    local before = container:isGroupEnabled("physics", "physics")
    container:setGroupEnabled("physics", "physics", false)
    local after = container:isGroupEnabled("physics", "physics")
    lurek.log.info("isGroupEnabled before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LSceneObjectContainer:processPhysics
do

    local container = lurek.scene.newObjectContainer()
    container:defineGroup("physics")
    local ticks = 0
    container:add({ group = "physics", process_physics = function(self, dt) ticks = ticks + 1 end })
    container:setGroupEnabled("physics", "physics", false)
    container:processPhysics(1 / 60)
    container:setGroupEnabled("physics", "physics", true)
    container:processPhysics(1 / 60)
    lurek.log.info("processPhysics ticks=" .. tostring(ticks))
end
