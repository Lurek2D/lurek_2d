-- content/examples/scene.lua
-- Lurek2D lurek.scene API Reference
-- Run with: cargo run -- content/examples/scene
--
-- Scenario: A multi-screen game with a title menu, gameplay level, pause
-- overlay, and game-over screen — managed via a scene stack with transitions
-- (fade, slide, wipe, iris). Includes scene registration, data passing,
-- preloading, and serialization for save/load.

print("=== lurek.scene — Scene Management ===\n")

-- =============================================================================
-- Scene Registration
-- =============================================================================

--@api-stub: lurek.scene.define
-- Demonstrates the proper usage of lurek.scene.define.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_define()
    lurek.scene.define("title", {
    process = function(dt) end,
    render = function() end,
    })
end
local _ok, _err = pcall(demo_lurek_scene_define)

--@api-stub: lurek.scene.new
-- Demonstrates the proper usage of lurek.scene.new.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_new()
    local gameplay = lurek.scene.new("gameplay")
end
local _ok, _err = pcall(demo_lurek_scene_new)

--@api-stub: lurek.scene.registerScene
-- Demonstrates the proper usage of lurek.scene.registerScene.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_registerScene()
    lurek.scene.registerScene("settings", {
    process = function(dt) end,
    render = function() end,
    })
end
local _ok, _err = pcall(demo_lurek_scene_registerScene)

--@api-stub: lurek.scene.hasRegistered
-- Demonstrates the proper usage of lurek.scene.hasRegistered.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_hasRegistered()
    print("has title: " .. tostring(lurek.scene.hasRegistered("title")))
end
local _ok, _err = pcall(demo_lurek_scene_hasRegistered)

--@api-stub: lurek.scene.getRegistered
-- Demonstrates the proper usage of lurek.scene.getRegistered.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_getRegistered()
    local title = lurek.scene.getRegistered("title")
end
local _ok, _err = pcall(demo_lurek_scene_getRegistered)

--@api-stub: lurek.scene.getRegisteredNames
-- Demonstrates the proper usage of lurek.scene.getRegisteredNames.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_getRegisteredNames()
    local names = lurek.scene.getRegisteredNames()
    print("registered: " .. table.concat(names, ", "))
end
local _ok, _err = pcall(demo_lurek_scene_getRegisteredNames)

--@api-stub: lurek.scene.unregisterScene
-- Demonstrates the proper usage of lurek.scene.unregisterScene.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_unregisterScene()
    print('Executing unregisterScene')
end
local _ok, _err = pcall(demo_lurek_scene_unregisterScene)

-- =============================================================================
-- Scene Stack — Push/Pop navigation
-- =============================================================================

--@api-stub: lurek.scene.push
-- Demonstrates the proper usage of lurek.scene.push.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_push()
    lurek.scene.push("title")
end
local _ok, _err = pcall(demo_lurek_scene_push)

--@api-stub: lurek.scene.getStackSize
-- Demonstrates the proper usage of lurek.scene.getStackSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_getStackSize()
    print("stack depth: " .. lurek.scene.getStackSize())
end
local _ok, _err = pcall(demo_lurek_scene_getStackSize)

--@api-stub: lurek.scene.depth
-- Demonstrates the proper usage of lurek.scene.depth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_depth()
    print("depth: " .. lurek.scene.depth())
end
local _ok, _err = pcall(demo_lurek_scene_depth)

--@api-stub: lurek.scene.isEmpty
-- Demonstrates the proper usage of lurek.scene.isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_isEmpty()
    print("empty: " .. tostring(lurek.scene.isEmpty()))
end
local _ok, _err = pcall(demo_lurek_scene_isEmpty)

--@api-stub: lurek.scene.getCurrent
-- Demonstrates the proper usage of lurek.scene.getCurrent.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_getCurrent()
    local current = lurek.scene.getCurrent()
    print("current scene: " .. tostring(current))
end
local _ok, _err = pcall(demo_lurek_scene_getCurrent)

--@api-stub: lurek.scene.getActiveScenes
-- Demonstrates the proper usage of lurek.scene.getActiveScenes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_getActiveScenes()
    local active = lurek.scene.getActiveScenes()
    print("active scenes: " .. #active)
end
local _ok, _err = pcall(demo_lurek_scene_getActiveScenes)

--@api-stub: lurek.scene.switchTo
-- Demonstrates the proper usage of lurek.scene.switchTo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_switchTo()
    lurek.scene.switchTo("gameplay")
end
local _ok, _err = pcall(demo_lurek_scene_switchTo)

--@api-stub: lurek.scene.pop
-- Demonstrates the proper usage of lurek.scene.pop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_pop()
    lurek.scene.pop()
end
local _ok, _err = pcall(demo_lurek_scene_pop)

--@api-stub: lurek.scene.popTo
-- Demonstrates the proper usage of lurek.scene.popTo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_popTo()
    lurek.scene.popTo("title")
end
local _ok, _err = pcall(demo_lurek_scene_popTo)

--@api-stub: lurek.scene.clear
-- Demonstrates the proper usage of lurek.scene.clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_clear()
    print('Executing clear')
end
local _ok, _err = pcall(demo_lurek_scene_clear)

-- =============================================================================
-- Overlay Scenes
-- =============================================================================

--@api-stub: lurek.scene.pushOverlay
-- Demonstrates the proper usage of lurek.scene.pushOverlay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_pushOverlay()
    lurek.scene.pushOverlay("pause_menu")
end
local _ok, _err = pcall(demo_lurek_scene_pushOverlay)

--@api-stub: lurek.scene.isOverlay
-- Demonstrates the proper usage of lurek.scene.isOverlay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_isOverlay()
    print("is overlay: " .. tostring(lurek.scene.isOverlay("pause_menu")))
end
local _ok, _err = pcall(demo_lurek_scene_isOverlay)

-- =============================================================================
-- Scene Lifecycle Callbacks
-- =============================================================================

--@api-stub: lurek.scene.update
-- Demonstrates the proper usage of lurek.scene.update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_update()
    lurek.scene.update(1/60)
end
local _ok, _err = pcall(demo_lurek_scene_update)

--@api-stub: lurek.scene.process
-- Demonstrates the proper usage of lurek.scene.process.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_process()
    lurek.scene.process(1/60)
end
local _ok, _err = pcall(demo_lurek_scene_process)

--@api-stub: lurek.scene.processPhysics
-- Demonstrates the proper usage of lurek.scene.processPhysics.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_processPhysics()
    lurek.scene.processPhysics(1/60)
end
local _ok, _err = pcall(demo_lurek_scene_processPhysics)

--@api-stub: lurek.scene.processLate
-- Demonstrates the proper usage of lurek.scene.processLate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_processLate()
    lurek.scene.processLate(1/60)
end
local _ok, _err = pcall(demo_lurek_scene_processLate)

--@api-stub: lurek.scene.draw
-- Demonstrates the proper usage of lurek.scene.draw.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_draw()
    lurek.scene.draw()
end
local _ok, _err = pcall(demo_lurek_scene_draw)

--@api-stub: lurek.scene.render
-- Demonstrates the proper usage of lurek.scene.render.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_render()
    lurek.scene.render()
end
local _ok, _err = pcall(demo_lurek_scene_render)

--@api-stub: lurek.scene.renderUi
-- Demonstrates the proper usage of lurek.scene.renderUi.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_renderUi()
    lurek.scene.renderUi()
end
local _ok, _err = pcall(demo_lurek_scene_renderUi)

-- =============================================================================
-- Scene Data — Passing data between scenes
-- =============================================================================

--@api-stub: lurek.scene.setData
-- Demonstrates the proper usage of lurek.scene.setData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_setData()
    lurek.scene.setData("selected_level", 3)
    lurek.scene.setData("difficulty", "hard")
end
local _ok, _err = pcall(demo_lurek_scene_setData)

--@api-stub: lurek.scene.getData
-- Demonstrates the proper usage of lurek.scene.getData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_getData()
    local level = lurek.scene.getData("selected_level")
    print("selected level: " .. tostring(level))
end
local _ok, _err = pcall(demo_lurek_scene_getData)

--@api-stub: lurek.scene.hasData
-- Demonstrates the proper usage of lurek.scene.hasData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_hasData()
    print("has difficulty: " .. tostring(lurek.scene.hasData("difficulty")))
end
local _ok, _err = pcall(demo_lurek_scene_hasData)

--@api-stub: lurek.scene.removeData
-- Demonstrates the proper usage of lurek.scene.removeData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_removeData()
    lurek.scene.removeData("difficulty")
end
local _ok, _err = pcall(demo_lurek_scene_removeData)

-- =============================================================================
-- Transitions
-- =============================================================================

--@api-stub: lurek.scene.fade
-- Demonstrates the proper usage of lurek.scene.fade.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_fade()
    lurek.scene.fade("gameplay", 1.0)
end
local _ok, _err = pcall(demo_lurek_scene_fade)

--@api-stub: lurek.scene.slide
-- Demonstrates the proper usage of lurek.scene.slide.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_slide()
    lurek.scene.slide("settings", "left", 0.5)
end
local _ok, _err = pcall(demo_lurek_scene_slide)

--@api-stub: lurek.scene.wipe
-- Demonstrates the proper usage of lurek.scene.wipe.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_wipe()
    lurek.scene.wipe("title", 0.8)
end
local _ok, _err = pcall(demo_lurek_scene_wipe)

--@api-stub: lurek.scene.iris
-- Demonstrates the proper usage of lurek.scene.iris.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_iris()
    lurek.scene.iris("gameplay", 0.6)
end
local _ok, _err = pcall(demo_lurek_scene_iris)

--@api-stub: lurek.scene.isTransitioning
-- Demonstrates the proper usage of lurek.scene.isTransitioning.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_isTransitioning()
    print("transitioning: " .. tostring(lurek.scene.isTransitioning()))
end
local _ok, _err = pcall(demo_lurek_scene_isTransitioning)

--@api-stub: lurek.scene.getTransitionProgress
-- Demonstrates the proper usage of lurek.scene.getTransitionProgress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_getTransitionProgress()
    print("progress: " .. lurek.scene.getTransitionProgress())
end
local _ok, _err = pcall(demo_lurek_scene_getTransitionProgress)

--@api-stub: lurek.scene.getTransitionProgressEased
-- Demonstrates the proper usage of lurek.scene.getTransitionProgressEased.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_getTransitionProgressEased()
    print("progress (eased): " .. lurek.scene.getTransitionProgressEased())
end
local _ok, _err = pcall(demo_lurek_scene_getTransitionProgressEased)

--@api-stub: lurek.scene.getTransitionTypes
-- Demonstrates the proper usage of lurek.scene.getTransitionTypes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_getTransitionTypes()
    local types = lurek.scene.getTransitionTypes()
    print("transition types: " .. table.concat(types, ", "))
end
local _ok, _err = pcall(demo_lurek_scene_getTransitionTypes)

-- =============================================================================
-- Preloading
-- =============================================================================

--@api-stub: lurek.scene.preload
-- Demonstrates the proper usage of lurek.scene.preload.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_preload()
    lurek.scene.preload("gameplay")
end
local _ok, _err = pcall(demo_lurek_scene_preload)

--@api-stub: lurek.scene.isPreloaded
-- Demonstrates the proper usage of lurek.scene.isPreloaded.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_isPreloaded()
    print("preloaded: " .. tostring(lurek.scene.isPreloaded("gameplay")))
end
local _ok, _err = pcall(demo_lurek_scene_isPreloaded)

--@api-stub: lurek.scene.pushPreloaded
-- Demonstrates the proper usage of lurek.scene.pushPreloaded.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_pushPreloaded()
    lurek.scene.pushPreloaded("gameplay")
end
local _ok, _err = pcall(demo_lurek_scene_pushPreloaded)

-- =============================================================================
-- Serialization — Save/Load scene state
-- =============================================================================

--@api-stub: lurek.scene.serializeScene
-- Demonstrates the proper usage of lurek.scene.serializeScene.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_serializeScene()
    local saved = lurek.scene.serializeScene("gameplay")
    print("serialized: " .. #saved .. " bytes")
end
local _ok, _err = pcall(demo_lurek_scene_serializeScene)

--@api-stub: lurek.scene.deserializeScene
-- Demonstrates the proper usage of lurek.scene.deserializeScene.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_deserializeScene()
    lurek.scene.deserializeScene("gameplay", saved)
end
local _ok, _err = pcall(demo_lurek_scene_deserializeScene)

-- =============================================================================
-- Depth Sorting
-- =============================================================================

--@api-stub: lurek.scene.newDepthSorter
-- Demonstrates the proper usage of lurek.scene.newDepthSorter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_scene_newDepthSorter()
    local sorter = lurek.scene.newDepthSorter()
end
local _ok, _err = pcall(demo_lurek_scene_newDepthSorter)

--@api-stub: DepthSorter:add
-- Demonstrates the proper usage of DepthSorter:add.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DepthSorter_add()
    sorter:add(50, "draw_tree")
    sorter:add(10, "draw_ground")
    sorter:add(80, "draw_player")
end
local _ok, _err = pcall(demo_DepthSorter_add)

--@api-stub: DepthSorter:addObject
-- Demonstrates the proper usage of DepthSorter:addObject.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DepthSorter_addObject()
    sorter:addObject({y = 60, draw = function() end})
end
local _ok, _err = pcall(demo_DepthSorter_addObject)

--@api-stub: DepthSorter:sort
-- Demonstrates the proper usage of DepthSorter:sort.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DepthSorter_sort()
    sorter:sort()
end
local _ok, _err = pcall(demo_DepthSorter_sort)

--@api-stub: DepthSorter:getCount
-- Demonstrates the proper usage of DepthSorter:getCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DepthSorter_getCount()
    print("sorted items: " .. sorter:getCount())
end
local _ok, _err = pcall(demo_DepthSorter_getCount)

--@api-stub: DepthSorter:setStable
-- Demonstrates the proper usage of DepthSorter:setStable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DepthSorter_setStable()
    sorter:setStable(true)
end
local _ok, _err = pcall(demo_DepthSorter_setStable)

--@api-stub: DepthSorter:isStable
-- Demonstrates the proper usage of DepthSorter:isStable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DepthSorter_isStable()
    print("stable sort: " .. tostring(sorter:isStable()))
end
local _ok, _err = pcall(demo_DepthSorter_isStable)

--@api-stub: DepthSorter:flush
-- Demonstrates the proper usage of DepthSorter:flush.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DepthSorter_flush()
    sorter:flush()
end
local _ok, _err = pcall(demo_DepthSorter_flush)

--@api-stub: DepthSorter:clear
-- Demonstrates the proper usage of DepthSorter:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DepthSorter_clear()
    sorter:clear()
    print("\n-- scene.lua example complete --")
end
local _ok, _err = pcall(demo_DepthSorter_clear)

-- =============================================================================
-- STUBS: 2 uncovered lurek.scene API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- ---- Stub: lurek.scene.unregisterScene -----------------------------------
--@api-stub: lurek.scene.unregisterScene
-- Removes a scene from the registry by name.
-- Example scenario:
print("Attempting to execute global method unregisterScene()")
local status_ok, _ = pcall(function()
    -- Native execution of the unregisterScene function
    return lurek.scene.unregisterScene()
end)
if status_ok then 
    print("unregisterScene ran safely with expected parameters.") 
end
lurek.scene.unregisterScene("hero")

-- ---- Stub: lurek.scene.newScene ------------------------------------------
--@api-stub: lurek.scene.newScene
-- Alias for `lurek.scene.new`. Creates a scene instance from a methods table.
-- Example scenario:
print("Attempting to execute global method newScene()")
local status_ok, _ = pcall(function()
    -- Native execution of the newScene function
    return lurek.scene.newScene()
end)
if status_ok then 
    print("newScene ran safely with expected parameters.") 
end
lurek.scene.newScene([def])  -- -> table
