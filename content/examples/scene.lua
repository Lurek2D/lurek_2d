-- content/examples/scene.lua
-- love2d-style usage snippets for the lurek.scene API (53 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/scene.lua

-- ── lurek.scene.* functions ──

--@api-stub: lurek.scene.push
-- Pushes a scene table onto the stack with an optional transition and easing.
-- Side-effecting; safe to call any time after init.
lurek.scene.push()
-- mutator; side effect applied
print("push done")
print("ok")

--@api-stub: lurek.scene.pop
-- Pops the top scene from the stack with an optional transition and easing.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.scene.pop(transition, 1.0, easing)
print("pop done")
print("ok")

--@api-stub: lurek.scene.switchTo
-- Replaces the top scene with a new one, calling leave and enter callbacks.
-- See the module spec for detailed semantics.
local result = lurek.scene.switchTo()
print("switchTo:", result)
return result

--@api-stub: lurek.scene.clear
-- Clears all scenes from the stack, calling leave on each.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.scene.clear()
print("clear done")
print("ok")

--@api-stub: lurek.scene.popTo
-- Pops scenes until the named scene is on top, calling leave on each removed.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.scene.popTo("main")
print("popTo done")
print("ok")

--@api-stub: lurek.scene.update
-- Updates the top scene and any active transition (legacy name; prefer `process`).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.scene.update(dt)
print("update applied")
print("ok")

--@api-stub: lurek.scene.process
-- Calls `scene:ready(self)` once per scene on the first tick after enter,.
-- See the module spec for detailed semantics.
local result = lurek.scene.process(dt)
print("process:", result)
return result

--@api-stub: lurek.scene.processPhysics
-- Calls `scene:process_physics(dt)` on all active scenes (fixed timestep).
-- See the module spec for detailed semantics.
local result = lurek.scene.processPhysics(dt)
print("processPhysics:", result)
return result

--@api-stub: lurek.scene.processLate
-- Calls `scene:process_late(dt)` on all active scenes (after process, before render).
-- See the module spec for detailed semantics.
local result = lurek.scene.processLate(dt)
print("processLate:", result)
return result

--@api-stub: lurek.scene.draw
-- Draws all scenes in the stack from bottom to top (legacy name; prefer `render`).
-- See the module spec for detailed semantics.
local result = lurek.scene.draw()
print("draw:", result)
return result

--@api-stub: lurek.scene.render
-- Draws all scenes in the stack from bottom to top.
-- See the module spec for detailed semantics.
local result = lurek.scene.render()
print("render:", result)
return result

--@api-stub: lurek.scene.renderUi
-- Draws UI overlay for all scenes in the stack from bottom to top.
-- See the module spec for detailed semantics.
local result = lurek.scene.renderUi()
print("renderUi:", result)
return result

--@api-stub: lurek.scene.getStackSize
-- Returns the number of scenes on the stack.
-- Cheap to call; safe inside callbacks.
local value = lurek.scene.getStackSize()
print("getStackSize:", value)
return value

--@api-stub: lurek.scene.depth
-- Returns the number of scenes on the stack.
-- See the module spec for detailed semantics.
local result = lurek.scene.depth()
print("depth:", result)
return result

--@api-stub: lurek.scene.isEmpty
-- Returns true if the scene stack is empty.
-- Use as a guard inside lurek.update or event handlers.
if lurek.scene.isEmpty() then
  print("isEmpty -> true")
end

--@api-stub: lurek.scene.getCurrent
-- Returns the current top scene table, or nil if the stack is empty.
-- Cheap to call; safe inside callbacks.
local value = lurek.scene.getCurrent()
print("getCurrent:", value)
return value

--@api-stub: lurek.scene.isTransitioning
-- Returns true if a scene transition is currently active.
-- Use as a guard inside lurek.update or event handlers.
if lurek.scene.isTransitioning() then
  print("isTransitioning -> true")
end

--@api-stub: lurek.scene.getTransitionProgress
-- Returns the transition progress from 0.0 to 1.0.
-- Cheap to call; safe inside callbacks.
local value = lurek.scene.getTransitionProgress()
print("getTransitionProgress:", value)
return value

--@api-stub: lurek.scene.registerScene
-- Registers a scene table by name for later retrieval.
-- Side-effecting; safe to call any time after init.
lurek.scene.registerScene("main", scene)
-- mutator; side effect applied
print("registerScene done")
print("ok")

--@api-stub: lurek.scene.getRegistered
-- Returns a registered scene table by name, or nil if not found.
-- Cheap to call; safe inside callbacks.
local value = lurek.scene.getRegistered("main")
print("getRegistered:", value)
return value

--@api-stub: lurek.scene.hasRegistered
-- Returns true if a scene is registered under the given name.
-- Use as a guard inside lurek.update or event handlers.
if lurek.scene.hasRegistered("main") then
  print("hasRegistered -> true")
end

--@api-stub: lurek.scene.unregisterScene
-- Removes a scene from the registry by name.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.scene.unregisterScene("main")
print("unregisterScene done")
print("ok")

--@api-stub: lurek.scene.getRegisteredNames
-- Returns a list of all registered scene names.
-- Cheap to call; safe inside callbacks.
local value = lurek.scene.getRegisteredNames()
print("getRegisteredNames:", value)
return value

--@api-stub: lurek.scene.setData
-- Stores a value in the inter-scene data store under the given key.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.scene.setData("space", value)
print("setData applied")
print("ok")

--@api-stub: lurek.scene.getData
-- Returns a value from the inter-scene data store, or nil if not found.
-- Cheap to call; safe inside callbacks.
local value = lurek.scene.getData("space")
print("getData:", value)
return value

--@api-stub: lurek.scene.hasData
-- Returns true if the given key exists in the data store.
-- Use as a guard inside lurek.update or event handlers.
if lurek.scene.hasData("space") then
  print("hasData -> true")
end

--@api-stub: lurek.scene.removeData
-- Removes a value from the inter-scene data store by key.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.scene.removeData("space")
print("removeData done")
print("ok")

--@api-stub: lurek.scene.newDepthSorter
-- Creates a new DepthSorter for z-ordered draw batching.
-- Build once at startup; reuse across frames.
local depthsorter = lurek.scene.newDepthSorter()
print("created", depthsorter)
return depthsorter

--@api-stub: lurek.scene.new
-- Creates a scene instance directly from a methods table.
-- Build once at startup; reuse across frames.
local obj = lurek.scene.new(def)
print("created", obj)
return obj

--@api-stub: lurek.scene.newScene
-- Alias for `lurek.scene.new`.
-- Build once at startup; reuse across frames.
local scene = lurek.scene.newScene(def)
print("created", scene)
return scene

--@api-stub: lurek.scene.define
-- Creates a reusable scene class â€” returns a zero-argument constructor function.
-- See the module spec for detailed semantics.
local result = lurek.scene.define(def)
print("define:", result)
return result

--@api-stub: lurek.scene.getTransitionProgressEased
-- Returns the easing-adjusted transition progress from 0.0 to 1.0.
-- Cheap to call; safe inside callbacks.
local value = lurek.scene.getTransitionProgressEased()
print("getTransitionProgressEased:", value)
return value

--@api-stub: lurek.scene.pushOverlay
-- Pushes a scene as a non-pausing overlay over the current top scene.
-- Side-effecting; safe to call any time after init.
lurek.scene.pushOverlay()
-- mutator; side effect applied
print("pushOverlay done")
print("ok")

--@api-stub: lurek.scene.isOverlay
-- Returns true if the current top scene was pushed as an overlay.
-- Use as a guard inside lurek.update or event handlers.
if lurek.scene.isOverlay() then
  print("isOverlay -> true")
end

--@api-stub: lurek.scene.getActiveScenes
-- Returns a table array of all active scene tables.
-- Cheap to call; safe inside callbacks.
local value = lurek.scene.getActiveScenes()
print("getActiveScenes:", value)
return value

--@api-stub: lurek.scene.preload
-- Registers a loader function for a named scene.
-- See the module spec for detailed semantics.
local result = lurek.scene.preload("main", loader)
print("preload:", result)
return result

--@api-stub: lurek.scene.isPreloaded
-- Returns true if the named scene has been preloaded.
-- Use as a guard inside lurek.update or event handlers.
if lurek.scene.isPreloaded("main") then
  print("isPreloaded -> true")
end

--@api-stub: lurek.scene.pushPreloaded
-- Pushes a registered scene by name, running its loader if not yet preloaded.
-- Side-effecting; safe to call any time after init.
lurek.scene.pushPreloaded()
-- mutator; side effect applied
print("pushPreloaded done")
print("ok")

--@api-stub: lurek.scene.getTransitionTypes
-- Returns a table listing all supported transition type strings.
-- Cheap to call; safe inside callbacks.
local value = lurek.scene.getTransitionTypes()
print("getTransitionTypes:", value)
return value

--@api-stub: lurek.scene.serializeScene
-- Returns a snapshot of the scene stack as a Lua table: { stack=[name...], data={key=val} }.
-- May block — call from a worker thread for large payloads.
local result = lurek.scene.serializeScene()
-- may block; consider lurek.thread for large payloads
print("serializeScene:", result)
print("ok")

--@api-stub: lurek.scene.deserializeScene
-- Restores scene data_refs from a snapshot produced by serializeScene().
-- May block — call from a worker thread for large payloads.
local result = lurek.scene.deserializeScene(snapshot)
-- may block; consider lurek.thread for large payloads
print("deserializeScene:", result)
print("ok")

--@api-stub: lurek.scene.fade
-- Returns a fade cross-dissolve transition config table.
-- See the module spec for detailed semantics.
local result = lurek.scene.fade(1.0)
print("fade:", result)
return result

--@api-stub: lurek.scene.slide
-- Returns a directional slide transition config table.
-- See the module spec for detailed semantics.
local result = lurek.scene.slide("data/file.txt", 1.0)
print("slide:", result)
return result

--@api-stub: lurek.scene.wipe
-- Returns a wipe/curtain transition config table.
-- See the module spec for detailed semantics.
local result = lurek.scene.wipe(1.0)
print("wipe:", result)
return result

--@api-stub: lurek.scene.iris
-- Returns an iris in/out (circular reveal) transition config table.
-- See the module spec for detailed semantics.
local result = lurek.scene.iris(1.0)
print("iris:", result)
return result

-- ── DepthSorter methods ──

--@api-stub: DepthSorter:add
-- Registers a draw callback at the given depth layer.
-- Side-effecting; safe to call any time after init.
local depthSorter = lurek.scene.newDepthSorter()
depthSorter:add(function() print("add fired") end, depth)
print("DepthSorter:add done")

--@api-stub: DepthSorter:addObject
-- Registers a table object with a draw method at the given depth.
-- Side-effecting; safe to call any time after init.
local depthSorter = lurek.scene.newDepthSorter()
depthSorter:addObject(obj)
print("DepthSorter:addObject done")

--@api-stub: DepthSorter:sort
-- Sorts all registered callbacks by depth ascending.
-- See the module spec for detailed semantics.
local depthSorter = lurek.scene.newDepthSorter()
depthSorter:sort()
print("DepthSorter:sort done")

--@api-stub: DepthSorter:flush
-- Calls all draw callbacks in sorted depth order, then clears.
-- See the module spec for detailed semantics.
local depthSorter = lurek.scene.newDepthSorter()
depthSorter:flush()
print("DepthSorter:flush done")

--@api-stub: DepthSorter:setStable
-- Sets whether equal-depth entries preserve insertion order.
-- Apply at startup or in response to user input.
local depthSorter = lurek.scene.newDepthSorter()
depthSorter:setStable({ x = 0, y = 0 })
print("DepthSorter:setStable applied")

--@api-stub: DepthSorter:isStable
-- Returns true if stable sort mode is enabled.
-- Use as a guard inside lurek.update or event handlers.
local depthSorter = lurek.scene.newDepthSorter()
if depthSorter:isStable() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: DepthSorter:clear
-- Removes all registered callbacks without calling them.
-- Pair with the matching constructor to free resources.
local depthSorter = lurek.scene.newDepthSorter()
depthSorter:clear()
-- depthSorter is now released
print("ok")

--@api-stub: DepthSorter:getCount
-- Returns the number of registered draw entries.
-- Cheap to call; safe inside callbacks.
local depthSorter = lurek.scene.newDepthSorter()  -- or your existing handle
local value = depthSorter:getCount()
print("DepthSorter:getCount ->", value)

