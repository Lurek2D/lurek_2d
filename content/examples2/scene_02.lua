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

print("scene_02.lua")
