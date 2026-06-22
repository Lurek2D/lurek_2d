# Scene

## Purpose

Manages stack-based scenes, overlays, and metatable factories.

## When To Use

- Scene stacks, shared scene data, lifecycle callbacks, transitions, depth sorting, object containers, and render bridges matter because changing what is active usually affects simulation, UI, rendering, and progression at the same time.
- Push, pop, replace, and overlay semantics are central to the module's value. They let projects layer pause menus over gameplay, cutscenes over maps, or modal flows over existing screens without destroying the context underneath.
- Lifecycle hooks make scenes more than labels: entry, exit, pause, resume, preload, and ready-style behavior let logic and resources react cleanly when control moves between states.

## Minimal Example

From the `lurek.scene.new` example block:

```lua
do
    lurek.scene.clear()
    local enter_count = 0
    local menu_scene = lurek.scene.new({ name = "menu", enter = function(self, params) self.mode = params.mode; enter_count = enter_count + 1 end, draw = function() end })
    lurek.scene.push(menu_scene, nil, nil, nil, { mode = "story" })
    local current = lurek.scene.getCurrent()
    local depth = lurek.scene.getStackSize()
    scene_log("new current=" .. tostring(current and current.name) .. " mode=" .. tostring(current and current.mode) .. " enters=" .. tostring(enter_count) .. " depth=" .. tostring(depth))
    lurek.scene.clear()
end
```

## Common Patterns

- Start with `lurek.scene.clear` when exploring this module.
- Start with `lurek.scene.clearQueuedTransitions` when exploring this module.
- Start with `lurek.scene.define` when exploring this module.
- Start with `lurek.scene.depth` when exploring this module.
- Start with `lurek.scene.deserializeScene` when exploring this module.

## API Reference

- This page is the generated API reference for this module.
- Runnable example owner: `content/examples/scene.lua`

## Summary

- The `scene` module is the high-level flow coordinator for users who want menus, gameplay states, overlays, pause layers, and transitions to behave like one ordered stack instead of a collection of unrelated toggles.
- Scene stacks, shared scene data, lifecycle callbacks, transitions, depth sorting, object containers, and render bridges matter because changing what is active usually affects simulation, UI, rendering, and progression at the same time.
- Push, pop, replace, and overlay semantics are central to the module's value. They let projects layer pause menus over gameplay, cutscenes over maps, or modal flows over existing screens without destroying the context underneath.
- Lifecycle hooks make scenes more than labels: entry, exit, pause, resume, preload, and ready-style behavior let logic and resources react cleanly when control moves between states.
- Shared data, symbolic registration, and transition support extend the feature from visual navigation into game-flow management, so scenes can exchange parameters, re-enter deterministically, and present state changes as unified runtime transitions.
- Stack semantics are one of the hardest recurring problems in game architecture, and this module gives a durable answer to what is active, what is suspended underneath, and how control returns cleanly after an overlay or interruption.
- That matters for pause flows, inventory layers, tutorials, map screens, cutscenes, modal dialogs, failure states, and tool-driven previews that should temporarily change the foreground without tearing down the underlying gameplay context.
- Transition support keeps pacing and presentation tied to the same model as logical scene changes. Fades, wipes, slides, or other handoff effects become part of one scene-change contract instead of ad hoc renderer tricks detached from lifecycle state.
- Shared scene data also broadens the module beyond navigation. Scenes can hand parameters, preserved runtime state, or restore information to one another in a way that stays explicit enough for tooling, replay, or save-oriented workflows.
- That stack model keeps layered game flow understandable once several temporary states coexist.
- Read `scene` as the owner of game-flow structure. Other systems perform the content work inside a scene, but this module decides how scenes are organized, layered, transitioned, and handed off over time.

This module primarily collaborates with `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.scene.clear`

Remove all scenes from the stack. Each removed scene receives its `leave()` callback in stack order. After this call the stack is empty and `isEmpty()` returns true. Useful for returning to a title screen or tearing down the entire scene graph.

```lua
lurek.scene.clear()
```

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.push(lurek.scene.new({ name = "pause_scene" }))
    local before = lurek.scene.getStackSize()
    lurek.scene.clear()
    local after = lurek.scene.getStackSize()
    local empty = lurek.scene.isEmpty()
    scene_log("clear before=" .. tostring(before) .. " after=" .. tostring(after) .. " empty=" .. tostring(empty))
end
```

---

### `lurek.scene.clearQueuedTransitions`

Discard all queued transitions without affecting the currently-playing transition (if any). Use this to cancel a planned transition sequence mid-way.

```lua
lurek.scene.clearQueuedTransitions()
```

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.queueTransition("fade", 0.25, "linear")
    example_print_log("queued before = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clearQueuedTransitions()
    example_print_log("queued after = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end
```

---

### `lurek.scene.define`

Create a reusable scene constructor function from a prototype table. Each call to the returned factory produces a fresh instance that inherits methods from the prototype via metatables. Ideal for defining scene "classes" that can be instantiated multiple times.

```lua
lurek.scene.define(def)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `def?` | table | A prototype table with scene lifecycle methods. |

**Returns**

| Type | Description |
|------|-------------|
| function | A zero-argument factory function that creates new instances inheriting from `def`. |

**Example**

```lua
do
    local GameplayFactory = lurek.scene.define({
        name = "gameplay",
        level = 0,
        enter = function(self, params)
            self.level = params and (params.level or 1) or self.level
            example_print_log("gameplay enter level " .. self.level)
        end,
        leave = function()
            example_print_log("gameplay leave")
        end,
        update = function()
        end,
        draw = function()
        end,
    })
    local instance1 = GameplayFactory()
    local instance2 = GameplayFactory()
    example_print_log("two instances: " .. tostring(instance1 ~= instance2))
end
```

---

### `lurek.scene.depth`

Alias for `getStackSize`. Returns the total number of scenes currently on the stack.

```lua
lurek.scene.depth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The current stack depth (0 when empty). |

**Example**

```lua
do
    lurek.scene.clear()
    local d0 = lurek.scene.depth()
    lurek.scene.push(lurek.scene.new({ name = "d1" }))
    local d1 = lurek.scene.depth()
    lurek.scene.clear()
    example_print_log("depth 0=" .. d0 .. " 1=" .. d1)
end
```

---

### `lurek.scene.deserializeScene`

Restore shared scene data from a previously-serialized snapshot table. Only the `data` key-value map is restored; the scene stack itself must be rebuilt manually by pushing or registering scenes. Pair with `serializeScene` for save/load workflows.

```lua
lurek.scene.deserializeScene(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | table | A snapshot table as returned by `serializeScene` (must contain a `data` field). |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    local snapshot = lurek.scene.serializeScene()
    lurek.scene.removeData("score")
    lurek.scene.deserializeScene(snapshot)
    example_print_log("restored score = " .. tostring(lurek.scene.getData("score")))
    example_print_log("stack size after load = " .. lurek.scene.getStackSize())
end
```

---

### `lurek.scene.draw`

Call `draw(self)` on render-active scenes ordered by layer (lowest first).

```lua
lurek.scene.draw()
```

**Example**

```lua
do
    local draws = 0
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "draw_scene", draw = function() draws = draws + 1 end }))
    lurek.scene.draw()
    example_print_log("draw calls = " .. draws)
    lurek.scene.clear()
end
```

---

### `lurek.scene.getActiveScenes`

Returns a Lua array of all process-active scene tables ordered by their layer value (lowest layer first). Includes regular scenes and overlays.

```lua
lurek.scene.getActiveScenes()
```

**Returns**

| Type | Description |
|------|-------------|
| LSceneGetActiveScenesResult | Lua array of active scene tables sorted by layer. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base" }))
    lurek.scene.push(lurek.scene.new({ name = "mid" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "overlay" }))
    local active = lurek.scene.getActiveScenes()
    example_print_log("active scenes = " .. #active)
    example_print_log("top active = " .. tostring(active[#active] and active[#active].name))
    lurek.scene.clear()
end
```

---

### `lurek.scene.getCurrent`

Returns the scene table currently on top of the stack, or nil if the stack is empty. Use this to inspect or call methods on the active scene directly.

```lua
lurek.scene.getCurrent()
```

**Returns**

| Type | Description |
|------|-------------|
| table | nil | The active top scene table, or nil if no scene is on the stack. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local current = lurek.scene.getCurrent()
    example_print_log("current name = " .. tostring(current and current.name))
    lurek.scene.clear()
end
```

---

### `lurek.scene.getCurrentLayer`

Get the rendering layer of the current top scene. Returns 0 if the stack is empty or if no layer was explicitly set.

```lua
lurek.scene.getCurrentLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The integer layer value of the top scene, or 0 if empty. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setCurrentLayer(12)
    example_print_log("current layer = " .. tostring(lurek.scene.getCurrentLayer()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.getData`

Retrieve a value from the shared data map by key, or nil if the key has not been set. Commonly used in a scene's `enter` callback to read parameters set by the previous scene.

```lua
lurek.scene.getData(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The data key to look up. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | The stored value, or nil if the key does not exist. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    lurek.scene.setData("checkpoint", "hangar")
    local score = lurek.scene.getData("score")
    local checkpoint = lurek.scene.getData("checkpoint")
    local has_score = lurek.scene.hasData("score")
    scene_log("getData score=" .. tostring(score) .. " checkpoint=" .. tostring(checkpoint) .. " has_score=" .. tostring(has_score))
end
```

---

### `lurek.scene.getQueuedTransitionCount`

Returns the number of transitions waiting in the queue behind the currently-playing transition.

```lua
lurek.scene.getQueuedTransitionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of queued (not yet started) transitions. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.queueTransition("fade", 0.25, "linear")
    example_print_log("queued transitions = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end
```

---

### `lurek.scene.getRegistered`

Retrieve a previously registered scene table by its name, or nil if no scene is registered under that name. Does not affect the stack.

```lua
lurek.scene.getRegistered(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The registered scene name to look up. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | The scene table, or nil if not found. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    local scene = lurek.scene.getRegistered("main_scene")
    local names = lurek.scene.getRegisteredNames()
    local has_scene = lurek.scene.hasRegistered("main_scene")
    local first = names[1] or "none"
    scene_log("getRegistered name=" .. tostring(scene and scene.name) .. " has_scene=" .. tostring(has_scene) .. " first=" .. tostring(first))
end
```

---

### `lurek.scene.getRegisteredNames`

Returns an array of all currently registered scene name strings. Useful for debugging or building dynamic scene-selection UIs.

```lua
lurek.scene.getRegisteredNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Lua array of registered name strings. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    lurek.scene.registerScene("pause_scene", lurek.scene.new({ name = "pause_scene" }))
    local names = lurek.scene.getRegisteredNames()
    example_print_log("registered names = " .. #names)
    example_print_log("first name = " .. tostring(names[1]))
end
```

---

### `lurek.scene.getRenderActiveScenes`

Returns the scene table(s) that are render-active this frame.

```lua
lurek.scene.getRenderActiveScenes()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Lua array of render-active scene tables. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "overlay" }))
    local active = lurek.scene.getRenderActiveScenes()
    example_print_log("getRenderActiveScenes count = " .. #active)
    example_print_log("top render-active = " .. tostring(active[1] and active[1].name))
    lurek.scene.clear()
end
```

---

### `lurek.scene.getStackSize`

Returns the total number of scenes currently on the stack, including overlays. Useful for asserting expected navigation depth or debugging scene flow.

```lua
lurek.scene.getStackSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The current stack depth (0 when empty). |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "pause_overlay" }), "fade", 0.2)
    local depth = lurek.scene.getStackSize()
    local current = lurek.scene.getCurrent()
    local overlay = lurek.scene.isOverlay()
    scene_log("getStackSize depth=" .. tostring(depth) .. " current=" .. tostring(current and current.name) .. " overlay=" .. tostring(overlay))
    lurek.scene.clear()
end
```

---

### `lurek.scene.getTransitionProgress`

Returns the raw linear progress (0.0 to 1.0) of the current transition animation, ignoring easing. Returns 0 when no transition is active. Use `getTransitionProgressEased` for the eased value.

```lua
lurek.scene.getTransitionProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Linear progress from 0 (start) to 1 (complete). |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    example_print_log("transition progress = " .. lurek.scene.getTransitionProgress())
    lurek.scene.clear()
end
```

---

### `lurek.scene.getTransitionProgressEased`

Returns the eased progress (0.0 to 1.0) of the current transition, with the selected easing curve applied. Returns 0 when no transition is active. Use this instead of `getTransitionProgress` when you want smooth, non-linear animation values.

```lua
lurek.scene.getTransitionProgressEased()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Eased progress from 0 (start) to 1 (complete). |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    example_print_log("eased progress = " .. lurek.scene.getTransitionProgressEased())
    lurek.scene.clear()
end
```

---

### `lurek.scene.getTransitionTypes`

Returns a Lua array of all supported transition type name strings. Use this to discover available transitions at runtime or build a transition picker UI.

```lua
lurek.scene.getTransitionTypes()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Lua array of strings: `"none"`, `"fade"`, `"slideleft"`, `"slideright"`, `"slideup"`, `"slidedown"`, `"wipe"`, `"iris"`, `"zoom"`, `"crossfade"`. |

**Example**

```lua
do
    local types = lurek.scene.getTransitionTypes()
    local has_fade = list_has(types, "fade")
    local has_zoom = list_has(types, "zoom")
    local has_crossfade = list_has(types, "crossfade")
    local first = types[1] or "none"
    scene_log("getTransitionTypes count=" .. tostring(#types) .. " first=" .. tostring(first) .. " fade=" .. tostring(has_fade) .. " zoom=" .. tostring(has_zoom) .. " crossfade=" .. tostring(has_crossfade))
end
```

---

### `lurek.scene.hasData`

Check whether a key exists in the shared scene data map without retrieving its value.

```lua
lurek.scene.hasData(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The data key to check for. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a value is stored under this key. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    local has_score = lurek.scene.hasData("score")
    local has_hp = lurek.scene.hasData("hp")
    local score = lurek.scene.getData("score")
    scene_log("hasData score=" .. tostring(has_score) .. " hp=" .. tostring(has_hp) .. " value=" .. tostring(score))
end
```

---

### `lurek.scene.hasRegistered`

Check whether a scene is registered under the given name.

```lua
lurek.scene.hasRegistered(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The scene name to look up. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a scene is registered with that name. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    local has_main = lurek.scene.hasRegistered("main_scene")
    local has_pause = lurek.scene.hasRegistered("pause_scene")
    local names = lurek.scene.getRegisteredNames()
    scene_log("hasRegistered main=" .. tostring(has_main) .. " pause=" .. tostring(has_pause) .. " count=" .. tostring(#names))
end
```

---

### `lurek.scene.isEmpty`

Returns true if the scene stack contains no scenes at all. Useful for guarding against calling `pop` on an empty stack or for detecting when the game should quit.

```lua
lurek.scene.isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the stack is empty (depth == 0). |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    example_print_log("before clear = " .. tostring(lurek.scene.isEmpty()))
    lurek.scene.clear()
    example_print_log("after clear = " .. tostring(lurek.scene.isEmpty()))
end
```

---

### `lurek.scene.isLateEnabled`

Returns whether `process_late` is enabled for a selected scene.

```lua
lurek.scene.isLateEnabled(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | any | nil/current, registered scene name, or 1-based stack index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled, false when frozen or target not found. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local before = lurek.scene.isLateEnabled()
    lurek.scene.setLateEnabled(nil, false)
    local disabled = lurek.scene.isLateEnabled()
    lurek.scene.setLateEnabled(nil, true)
    local restored = lurek.scene.isLateEnabled()
    scene_log("isLateEnabled before=" .. tostring(before) .. " disabled=" .. tostring(disabled) .. " restored=" .. tostring(restored))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isOverlay`

Returns true if the current top scene was pushed via `pushOverlay`. Overlay scenes do not pause the scene beneath them, allowing both scenes to remain process-active unless explicitly frozen.

```lua
lurek.scene.isOverlay()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the top scene is an overlay, false otherwise. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "pause_overlay" }), "fade", 0.2)
    example_print_log("top scene is overlay = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isPhysicsEnabled`

Returns whether `process_physics` is enabled for a selected scene.

```lua
lurek.scene.isPhysicsEnabled(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | any | nil/current, registered scene name, or 1-based stack index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled, false when frozen or target not found. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local before = lurek.scene.isPhysicsEnabled()
    lurek.scene.setPhysicsEnabled(nil, false)
    local disabled = lurek.scene.isPhysicsEnabled()
    lurek.scene.setPhysicsEnabled(nil, true)
    local restored = lurek.scene.isPhysicsEnabled()
    scene_log("isPhysicsEnabled before=" .. tostring(before) .. " disabled=" .. tostring(disabled) .. " restored=" .. tostring(restored))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isPreloaded`

Returns true if the named preload loader has already been executed at least once. Once a loader runs, subsequent `pushPreloaded` calls skip the loader and push the already-registered scene directly.

```lua
lurek.scene.isPreloaded(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The preload name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the loader has already executed. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.preload("main_scene", function()
        lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    end)
    example_print_log("preloaded = " .. tostring(lurek.scene.isPreloaded("main_scene")))
    lurek.scene.push(lurek.scene.new({ name = "loader" }))
    lurek.scene.pushPreloaded("main_scene")
    example_print_log("after push = " .. tostring(lurek.scene.isPreloaded("main_scene")))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isProcessEnabled`

Returns whether `process` is enabled for a selected scene.

```lua
lurek.scene.isProcessEnabled(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | any | nil/current, registered scene name, or 1-based stack index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled, false when frozen or target not found. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local before = lurek.scene.isProcessEnabled()
    lurek.scene.setProcessEnabled(nil, false)
    local disabled = lurek.scene.isProcessEnabled()
    lurek.scene.setProcessEnabled(nil, true)
    local restored = lurek.scene.isProcessEnabled()
    scene_log("isProcessEnabled before=" .. tostring(before) .. " disabled=" .. tostring(disabled) .. " restored=" .. tostring(restored))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isTransitioning`

Returns true if a scene transition animation is currently playing. Use this to block input or skip certain logic during transitions.

```lua
lurek.scene.isTransitioning()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True while a transition animation is in progress. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    example_print_log("is transitioning = " .. tostring(lurek.scene.isTransitioning()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isUpdateEnabled`

Returns whether `update` is enabled for a selected scene.

```lua
lurek.scene.isUpdateEnabled(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | any | nil/current, registered scene name, or 1-based stack index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled, false when frozen or target not found. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local before = lurek.scene.isUpdateEnabled()
    lurek.scene.setUpdateEnabled(nil, false)
    local disabled = lurek.scene.isUpdateEnabled()
    lurek.scene.setUpdateEnabled(nil, true)
    local restored = lurek.scene.isUpdateEnabled()
    scene_log("isUpdateEnabled before=" .. tostring(before) .. " disabled=" .. tostring(disabled) .. " restored=" .. tostring(restored))
    lurek.scene.clear()
end
```

---

### `lurek.scene.new`

Create a new scene instance from an optional prototype table. Sets up metatables so the instance inherits methods from the prototype. Use this for one-off scene creation; use `define` when you need a reusable scene constructor.

```lua
lurek.scene.new(def)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `def?` | table | A prototype table containing scene lifecycle methods (`enter`, `leave`, `update`, `draw`, etc.). If omitted, an empty table is used. |

**Returns**

| Type | Description |
|------|-------------|
| LSceneNewResult | A new instance table with `def` as its metatable `__index`. |

**Example**

```lua
do
    lurek.scene.clear()
    local enter_count = 0
    local menu_scene = lurek.scene.new({ name = "menu", enter = function(self, params) self.mode = params.mode; enter_count = enter_count + 1 end, draw = function() end })
    lurek.scene.push(menu_scene, nil, nil, nil, { mode = "story" })
    local current = lurek.scene.getCurrent()
    local depth = lurek.scene.getStackSize()
    scene_log("new current=" .. tostring(current and current.name) .. " mode=" .. tostring(current and current.mode) .. " enters=" .. tostring(enter_count) .. " depth=" .. tostring(depth))
    lurek.scene.clear()
end
```

---

### `lurek.scene.newDepthSorter`

Create a new `[LDepthSorter](#ldepthsorter)` instance for collecting drawable items and flushing them in depth-sorted (painter's algorithm) order.

```lua
lurek.scene.newDepthSorter()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDepthSorter](#ldepthsorter) | A fresh depth sorter with no queued entries. |

**Example**

```lua
do
    local sorter = lurek.scene.newDepthSorter()
    example_print_log("type = " .. sorter:type() .. " is LDepthSorter = " .. tostring(sorter:typeOf("LDepthSorter")))
    sorter:add(function()
        example_print_log("draw back layer")
    end, 10)
    sorter:add(function()
        example_print_log("draw front layer")
    end, 15)
    example_print_log("count = " .. sorter:getCount())
    sorter:flush()
    example_print_log("after flush count = " .. sorter:getCount())
end
```

---

### `lurek.scene.newObjectContainer`

Create a new scene object container for managing object lifecycle and draw ordering.

```lua
lurek.scene.newObjectContainer()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSceneObjectContainer](#lsceneobjectcontainer) | New container handle. |

**Example**

```lua
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
            example_print_log("Drawing player at x=" .. self.x .. ", y=" .. self.y)
        end
    }

    local background = {
        layer = 0,
        draw = function(self)
            example_print_log("Drawing background")
        end
    }

    container:add(background)
    container:add(player)

    example_print_log("object_count=" .. container:getCount())

    container:update(0.016)
    container:draw()

    container:remove(player)
    example_print_log("after_remove=" .. container:getCount())

    container:clear()
    example_print_log("after_clear=" .. container:getCount())
end
```

---

### `lurek.scene.newScene`

Alias for `lurek.scene.new`. Creates a new scene instance from an optional prototype table while preserving the older API name still used by tests, examples, and existing game scripts.

```lua
lurek.scene.newScene(def)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `def?` | table | A prototype table containing scene lifecycle methods (`enter`, `leave`, `update`, `draw`, etc.). If omitted, an empty table is used. |

**Returns**

| Type | Description |
|------|-------------|
| LSceneNewSceneResult | A new instance table with `def` as its metatable `__index`. |

**Example**

```lua
do
    lurek.scene.clear()
    local scene = lurek.scene.newScene({ name = "test_new", enter = function(self, params) self.spawn = params.spawn end })
    lurek.scene.push(scene, nil, nil, nil, { spawn = "dock" })
    local current = lurek.scene.getCurrent()
    local has_metatable = getmetatable(scene) ~= nil
    scene_log("newScene name=" .. tostring(current and current.name) .. " spawn=" .. tostring(current and current.spawn) .. " metatable=" .. tostring(has_metatable))
    lurek.scene.clear()
end
```

---

### `lurek.scene.pop`

Pop the top scene off the stack and return to the previous one. The popped scene receives `leave()` and the revealed scene receives `resume()` (unless the popped scene was an overlay, in which case the underlying scene was never paused). Use this for "back" navigation, closing menus, or exiting sub-screens.

```lua
lurek.scene.pop(transition, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `transition?` | string | Transition type name. Defaults to `"none"` (instant). |
| `duration?` | number | Transition animation duration in seconds. Defaults to 0. |
| `easing?` | string | Easing curve name. Defaults to `"linear"`. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "first_scene" }))
    lurek.scene.push(lurek.scene.new({ name = "second_scene" }))
    lurek.scene.pop()
    example_print_log("stack size after pop = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end
```

---

### `lurek.scene.popTo`

Pop scenes off the stack until the named registered scene is on top. Every popped scene receives `leave()` and the target scene receives `resume()`. The target scene must have been previously added via `registerScene`. Returns false if no scene with that name exists on the stack.

```lua
lurek.scene.popTo(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The registered name of the target scene to unwind to. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the named scene was found and is now the active top scene, false if the name was not found. |

**Example**

```lua
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
    example_print_log("popTo base = " .. tostring(found))
    example_print_log("popTo missing = " .. tostring(missing) .. " depth = " .. lurek.scene.depth())
    lurek.scene.clear()
end
```

---

### `lurek.scene.preload`

Register a deferred-loading function for a scene. The loader function is NOT called immediately â€” it runs the first time `pushPreloaded` is called with this name. Use this to spread scene initialization (asset loading, table setup) across loading screens or lazy-load heavy scenes on demand.

```lua
lurek.scene.preload(name, loader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name to associate with the loader (must match the name used in `pushPreloaded`). |
| `loader` | function | A zero-argument function that creates and registers the scene via `registerScene` when called. |

**Example**

```lua
do
    local loadCount = 0
    lurek.scene.clear()
    lurek.scene.preload("heavyLevel", function()
        loadCount = loadCount + 1
        lurek.scene.registerScene("heavyLevel", lurek.scene.new({ name = "heavyLevel" }))
    end)
    example_print_log("preloaded = " .. tostring(lurek.scene.isPreloaded("heavyLevel")))
    lurek.scene.push(lurek.scene.new({ name = "loader" }))
    lurek.scene.pushPreloaded("heavyLevel", "fade", 0.3)
    example_print_log("after push preloaded = " .. tostring(lurek.scene.isPreloaded("heavyLevel")) .. " load count = " .. loadCount)
    lurek.scene.clear()
end
```

---

### `lurek.scene.process`

Call `ready(self)` once on newly-pushed scenes, then call `process(self, dt)` on every process-active scene ordered by layer (lowest first).

```lua
lurek.scene.process(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Fixed time-step delta in seconds (e.g. 1/60 for 60-tick logic). |

**Example**

```lua
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
    example_print_log("process count = " .. processCount)
    example_print_log("last dt = " .. tostring(scene.last_dt))
    lurek.scene.clear()
end
```

---

### `lurek.scene.processLate`

Call `process_late(self, dt)` on every process-active scene after all other processing.

```lua
lurek.scene.processLate(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds (same value passed to `process`). |

**Example**

```lua
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
    example_print_log("late = " .. lateCount .. " physics = " .. physCount)
    lurek.scene.clear()
end
```

---

### `lurek.scene.processPhysics`

Call `process_physics(self, dt)` on every process-active scene ordered by layer.

```lua
lurek.scene.processPhysics(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Physics time-step delta in seconds. |

**Example**

```lua
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
    example_print_log("physics count = " .. physicsCount)
    example_print_log("last physics dt = " .. tostring(scene.last_physics_dt))
    lurek.scene.clear()
end
```

---

### `lurek.scene.push`

Push a new scene onto the stack, making it the active scene. The previously-active scene receives its `pause()` lifecycle callback and the new scene receives `enter(self, params)`. An optional visual transition (fade, slide, iris, etc.) animates between the two scenes over the specified duration.

```lua
lurek.scene.push(scene, transition, duration, easing, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scene` | table | A scene table with lifecycle methods (`enter`, `leave`, `pause`, `resume`, `update`, `draw`, etc.). |
| `transition?` | string | Transition type name: `"fade"`, `"slideleft"`, `"slideright"`, `"slideup"`, `"slidedown"`, `"wipe"`, `"iris"`, `"zoom"`, `"crossfade"`. Defaults to `"none"`. |
| `duration?` | number | Transition animation duration in seconds. Defaults to 0 (instant). |
| `easing?` | string | Easing curve name (e.g. `"linear"`, `"ease_in"`, `"ease_out"`, `"ease_in_out"`). Defaults to `"linear"`. |
| `params?` | table | Arbitrary data forwarded to the new scene's `enter(self, params)` callback for initialization. |

**Example**

```lua
do
    lurek.scene.clear()
    local title_scene = make_named_scene("title", { enter = function(self, params) self.selected_slot = params.slot end })
    lurek.scene.push(title_scene, nil, nil, nil, { slot = 2 })
    local current = lurek.scene.getCurrent()
    local depth = lurek.scene.getStackSize()
    local layer = lurek.scene.getCurrentLayer()
    scene_log("push current=" .. tostring(current and current.name) .. " slot=" .. tostring(current and current.selected_slot) .. " depth=" .. tostring(depth) .. " layer=" .. tostring(layer))
    lurek.scene.clear()
end
```

---

### `lurek.scene.pushOverlay`

Push a scene as an overlay on top of the current scene. Unlike `push`, the underlying scene is NOT paused â€” it can continue to receive `process` callbacks unless frozen. Rendering remains single-scene (top scene only) at engine level.

```lua
lurek.scene.pushOverlay(scene, transition, duration, easing, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scene` | table | The overlay scene table. |
| `transition?` | string | Transition type name. Defaults to `"none"`. |
| `duration?` | number | Transition animation duration in seconds. Defaults to 0. |
| `easing?` | string | Easing curve name. Defaults to `"linear"`. |
| `params?` | table | Arbitrary data forwarded to the overlay's `enter(self, params)` callback. |

**Example**

```lua
do
    lurek.scene.clear()
    local gameScene = lurek.scene.new({ name = "game" })
    local pauseOverlay = lurek.scene.new({ name = "pause" })
    lurek.scene.push(gameScene)
    example_print_log("overlay before push = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.pushOverlay(pauseOverlay, "fade", 0.2)
    example_print_log("overlay after push = " .. tostring(lurek.scene.isOverlay()) .. " stack depth = " .. lurek.scene.getStackSize())
    lurek.scene.pop()
    example_print_log("after pop overlay = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.pushPreloaded`

Push a preloaded scene onto the stack by name. If the loader registered via `preload` has not yet run, it executes first to create and register the scene. Then the registered scene is pushed with the specified transition. Combines deferred loading with stack navigation in a single call.

```lua
lurek.scene.pushPreloaded(name, transition, duration, easing, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The preload/registration name (must match a prior `preload` or `registerScene` call). |
| `transition?` | string | Transition type name. Defaults to `"none"`. |
| `duration?` | number | Transition animation duration in seconds. Defaults to 0. |
| `easing?` | string | Easing curve name. Defaults to `"linear"`. |
| `params?` | table | Arbitrary data forwarded to the scene's `enter(self, params)` callback. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.preload("main_scene", function()
        lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    end)
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.pushPreloaded("main_scene", "fade", 0.3)
    example_print_log("stack size after push = " .. lurek.scene.getStackSize())
    example_print_log("current = " .. tostring(lurek.scene.getCurrent() and lurek.scene.getCurrent().name))
    lurek.scene.clear()
end
```

---

### `lurek.scene.queueTransition`

Queue a transition to play automatically after the current one finishes. Multiple queued transitions execute in FIFO order, enabling multi-step cinematic sequences (e.g. fade-out then slide-in).

```lua
lurek.scene.queueTransition(transition, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `transition` | string | Transition type name (e.g. `"fade"`, `"iris"`, `"wipe"`). |
| `duration` | number | Duration in seconds. |
| `easing?` | string | Easing curve name. Defaults to `"linear"`. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base" }))
    lurek.scene.queueTransition("fade", 0.2)
    lurek.scene.queueTransition("iris", 0.3)
    lurek.scene.queueTransition("wipe", 0.4, "ease_in")
    example_print_log("queued = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clearQueuedTransitions()
    example_print_log("after clear queued = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end
```

---

### `lurek.scene.registerScene`

Register a scene table under a unique name for later retrieval via `getRegistered`, navigation via `popTo`, or deferred push via `pushPreloaded`. Registering does not push the scene onto the stack.

```lua
lurek.scene.registerScene(name, scene)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique name to associate with this scene (e.g. `"mainMenu"`, `"gameplay"`). |
| `scene` | table | The scene table to register. |

**Example**

```lua
do
    lurek.scene.clear()
    local menu_scene = make_named_scene("mainMenu")
    lurek.scene.registerScene("mainMenu", menu_scene)
    local stored = lurek.scene.getRegistered("mainMenu")
    local names = lurek.scene.getRegisteredNames()
    local has_menu = lurek.scene.hasRegistered("mainMenu")
    scene_log("registerScene stored=" .. tostring(stored and stored.name) .. " has_menu=" .. tostring(has_menu) .. " name_count=" .. tostring(#names))
end
```

---

### `lurek.scene.removeData`

Remove a key and its associated value from the shared scene data map. No-op if the key does not exist.

```lua
lurek.scene.removeData(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The data key to remove. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.setData("_test_key", 42)
    example_print_log("before remove = " .. tostring(lurek.scene.hasData("_test_key")))
    lurek.scene.removeData("_test_key")
    example_print_log("after remove = " .. tostring(lurek.scene.hasData("_test_key")))
end
```

---

### `lurek.scene.render`

Call `render(self)` on render-active scenes ordered by layer (lowest first).

```lua
lurek.scene.render()
```

**Example**

```lua
do
    lurek.scene.clear()
    local renderCount = 0
    lurek.scene.push(lurek.scene.new({ render = function() renderCount = renderCount + 1 end }))
    lurek.scene.render()
    example_print_log("render count = " .. renderCount)
    lurek.scene.clear()
end
```

---

### `lurek.scene.renderUi`

Call `render_ui(self)` on render-active scenes ordered by layer (lowest first).

```lua
lurek.scene.renderUi()
```

**Example**

```lua
do
    lurek.scene.clear()
    local uiCount = 0
    lurek.scene.push(lurek.scene.new({ render_ui = function() uiCount = uiCount + 1 end }))
    lurek.scene.renderUi()
    example_print_log("render ui count = " .. uiCount)
    lurek.scene.clear()
end
```

---

### `lurek.scene.serializeScene`

Capture the current scene stack state as a serializable snapshot table. The snapshot contains a `stack` array of registered scene names (in stack order) and a `data` map of shared data key-value pairs. Use this for save/load systems to persist the player's navigation state.

```lua
lurek.scene.serializeScene()
```

**Returns**

| Type | Description |
|------|-------------|
| LSceneSerializeSceneResult | A snapshot table with `stack` (array of scene name strings) and `data` (key-value map) fields. |

**Example**

```lua
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
    example_print_log("stack = " .. #snapshot.stack)
    example_print_log("saved level = " .. tostring(snapshot.data.level) .. " checkpoint = " .. tostring(snapshot.data.checkpoint))
    lurek.scene.clear()
    lurek.scene.deserializeScene(snapshot)
    example_print_log("restored level = " .. tostring(lurek.scene.getData("level")))
    lurek.scene.clear()
end
```

---

### `lurek.scene.setCurrentLayer`

Set the rendering layer of the current top scene. Scenes with higher layer values are processed and drawn after lower-layer scenes. Use layers to control draw order when multiple scenes are active (e.g. game world at layer 0, HUD overlay at layer 10).

```lua
lurek.scene.setCurrentLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Integer layer value to assign (higher = drawn later / on top). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a scene was on top and the layer was set, false if the stack is empty. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "layer_scene" }))
    local ok = lurek.scene.setCurrentLayer(8)
    example_print_log("set layer ok = " .. tostring(ok))
    example_print_log("current layer = " .. tostring(lurek.scene.getCurrentLayer()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.setData`

Store an arbitrary Lua value in the scene module's shared data map, keyed by a string name. Scenes can use this to pass information between each other without direct references â€” for example, passing a selected level index from a menu scene to a gameplay scene.

```lua
lurek.scene.setData(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key to store data under (e.g. `"selectedLevel"`, `"playerName"`). |
| `value` | any | Value to store under the scene data key. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.setData("selectedLevel", 5)
    lurek.scene.setData("entryScene", "hangar")
    local has_level = lurek.scene.hasData("selectedLevel")
    local level = lurek.scene.getData("selectedLevel")
    local entry = lurek.scene.getData("entryScene")
    scene_log("setData has_level=" .. tostring(has_level) .. " level=" .. tostring(level) .. " entry=" .. tostring(entry))
end
```

---

### `lurek.scene.setLateEnabled`

Enable or disable `process_late(self, dt)` execution for a selected scene.

```lua
lurek.scene.setLateEnabled(target, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | any | nil/current, registered scene name, or 1-based stack index. |
| `enabled` | boolean | True to run late callback, false to freeze it. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when target scene was resolved and updated. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setLateEnabled(nil, false)
    example_print_log("setLateEnabled = " .. tostring(lurek.scene.isLateEnabled()))
    lurek.scene.setLateEnabled(nil, true)
    example_print_log("after reset = " .. tostring(lurek.scene.isLateEnabled()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.setPhysicsEnabled`

Enable or disable `process_physics(self, dt)` execution for a selected scene.

```lua
lurek.scene.setPhysicsEnabled(target, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | any | nil/current, registered scene name, or 1-based stack index. |
| `enabled` | boolean | True to run physics callback, false to freeze it. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when target scene was resolved and updated. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setPhysicsEnabled(nil, false)
    example_print_log("setPhysicsEnabled = " .. tostring(lurek.scene.isPhysicsEnabled()))
    lurek.scene.setPhysicsEnabled(nil, true)
    example_print_log("after reset = " .. tostring(lurek.scene.isPhysicsEnabled()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.setProcessEnabled`

Enable or disable `process(self, dt)` execution for a selected scene.

```lua
lurek.scene.setProcessEnabled(target, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | any | nil/current, registered scene name, or 1-based stack index. |
| `enabled` | boolean | True to run process, false to freeze it. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when target scene was resolved and updated. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local disabled = lurek.scene.setProcessEnabled(nil, false)
    local enabled = lurek.scene.setProcessEnabled(nil, true)
    example_print_log("disabled ok = " .. tostring(disabled))
    example_print_log("setProcessEnabled = " .. tostring(lurek.scene.isProcessEnabled()))
    example_print_log("enabled ok = " .. tostring(enabled))
    lurek.scene.clear()
end
```

---

### `lurek.scene.setUpdateEnabled`

Enable or disable `update(self, dt)` execution for a selected scene.

```lua
lurek.scene.setUpdateEnabled(target, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | any | nil/current, registered scene name, or 1-based stack index. |
| `enabled` | boolean | True to run update callback, false to freeze it. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when target scene was resolved and updated. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setUpdateEnabled(nil, false)
    example_print_log("setUpdateEnabled = " .. tostring(lurek.scene.isUpdateEnabled()))
    lurek.scene.setUpdateEnabled(nil, true)
    example_print_log("after reset = " .. tostring(lurek.scene.isUpdateEnabled()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.switchTo`

Replace the current top scene with a different one without changing stack depth. The old scene receives `leave()` and the new scene receives `enter(self, params)`. Unlike `push`, no scene is added to the stack â€” the old scene is removed and the new one takes its slot. Ideal for transitioning between peer-level game states (e.g. level 1 â†’ level 2).

```lua
lurek.scene.switchTo(scene, transition, duration, easing, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scene` | table | The replacement scene table. |
| `transition?` | string | Transition type name. Defaults to `"none"`. |
| `duration?` | number | Transition animation duration in seconds. Defaults to 0. |
| `easing?` | string | Easing curve name. Defaults to `"linear"`. |
| `params?` | table | Arbitrary data forwarded to the new scene's `enter(self, params)` callback. |

**Example**

```lua
do
    local sceneA = lurek.scene.new({
        name = "level1",
        enter = function()
            example_print_log("level1 enter")
        end,
        leave = function()
            example_print_log("level1 leave")
        end,
    })
    local sceneB = lurek.scene.new({
        name = "level2",
        enter = function(_, params)
            example_print_log("level2 enter, from=" .. (params and params.from or "none"))
        end,
        leave = function()
            example_print_log("level2 leave")
        end,
    })
    lurek.scene.push(sceneA)
    example_print_log("before switch: depth=" .. lurek.scene.getStackSize())
    lurek.scene.switchTo(sceneB, "none", 0, "linear", { from = "level1" })
    example_print_log("after switch: depth=" .. lurek.scene.getStackSize())
    example_print_log("current = " .. lurek.scene.getCurrent().name)
    lurek.scene.clear()
end
```

---

### `lurek.scene.unregisterScene`

Remove a scene registration by name. Does not pop the scene if it is currently active on the stack â€” it only removes the name mapping.

```lua
lurek.scene.unregisterScene(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The registered name to remove. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.registerScene("_tmp_unreg", lurek.scene.new({ name = "_tmp_unreg" }))
    example_print_log("before unregister = " .. tostring(lurek.scene.hasRegistered("_tmp_unreg")))
    lurek.scene.unregisterScene("_tmp_unreg")
    example_print_log("after unregister = " .. tostring(lurek.scene.hasRegistered("_tmp_unreg")))
end
```

---

### `lurek.scene.update`

Advance any active transition animation and call `update(self, dt)` on the current top scene.

```lua
lurek.scene.update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds since the last frame (e.g. from `lurek.timer.getDelta()`). |

**Example**

```lua
do
    -- update advances transitions and dispatches the update callback to the top scene
    lurek.scene.clear()
    local s = lurek.scene.new({ name = "update_test" })
    lurek.scene.push(s)
    lurek.scene.update(0.016)
    lurek.scene.clear()
    example_print_log("lurek.scene.update ok")
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

- `lurek.scene.preload` param `loader` (`function`): A zero-argument function that creates and registers the scene via `registerScene` when called.

## Enums

*No module-specific enums documented.*

## Types

- [LDepthSorter](#ldepthsorter)
- [LSceneObjectContainer](#lsceneobjectcontainer)

## LDepthSorter

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDepthSorter:add`

Register a draw callback at a given depth value. When `flush` is called, all registered callbacks execute in back-to-front order (lowest depth drawn first, highest depth drawn last / on top). Use this for simple draw calls like sprite rendering where each entity has a depth/z-layer.

```lua
LDepthSorter:add(callback, depth)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | A zero-argument draw function invoked during flush. |
| `depth` | number | Numeric z-depth controlling draw order â€” lower values are drawn behind higher values. |

**Example**

```lua
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function()
        example_print_log("draw circle A")
    end, 5.0)
    ds:add(function()
        example_print_log("draw circle B")
    end, 2.0)
    local count = ds:getCount()
    ds:flush()
    example_print_log("depth sorter count = " .. count)
end
```

---

#### `LDepthSorter:addObject`

Register a game object table for depth-sorted rendering. The object must expose a numeric `depth` field and a `drawSorted(self)` method. During `flush`, each object's `drawSorted` is called in depth order, making this ideal for entity-based architectures where objects manage their own drawing.

```lua
LDepthSorter:addObject(obj)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `obj` | table | A game object table with a numeric `depth` field and a `drawSorted(self)` method. |

**Example**

```lua
do
    local sorter = lurek.scene.newDepthSorter()
    local obj1 = { depth = 3, drawSorted = function(self) example_print_log("draw obj at depth " .. self.depth) end }
    local obj2 = { depth = 1, drawSorted = function(self) example_print_log("draw obj at depth " .. self.depth) end }
    sorter:addObject(obj1)
    sorter:addObject(obj2)
    example_print_log("count = " .. sorter:getCount())
    sorter:flush()
end
```

---

#### `LDepthSorter:clear`

Discard all pending entries without executing any draw callbacks. Use this when a scene is interrupted, reset, or destroyed before its normal `flush` call.

```lua
LDepthSorter:clear()
```

**Example**

```lua
do
    local sorter = lurek.scene.newDepthSorter()
    sorter:add(function()
        example_print_log("queued callback")
    end, 3)
    example_print_log("before clear count = " .. sorter:getCount())
    sorter:clear()
    example_print_log("cleared count = " .. sorter:getCount())
end
```

---

#### `LDepthSorter:flush`

Sort all entries by depth, execute every callback or object's `drawSorted` method in back-to-front order, then clear the sorter for the next frame. This is the standard one-call render path â€” call it once per frame inside your scene's `draw` or `render` callback.

```lua
LDepthSorter:flush()
```

**Example**

```lua
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function()
        example_print_log("flush callback A")
    end, 5.0)
    ds:add(function()
        example_print_log("flush callback B")
    end, 2.0)
    local count = ds:getCount()
    ds:flush()
    example_print_log("depth sorter count = " .. count)
end
```

---

#### `LDepthSorter:getCount`

Returns the number of draw entries currently queued for the next `flush` call. Useful for debugging or deciding whether to skip an empty render pass.

```lua
LDepthSorter:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of pending draw entries. |

**Example**

```lua
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function()
        example_print_log("count callback")
    end, 5.0)
    ds:add(function()
        example_print_log("count callback 2")
    end, 2.0)
    example_print_log("depth sorter count = " .. ds:getCount())
    ds:clear()
end
```

---

#### `LDepthSorter:isStable`

Returns whether the sorter uses stable sorting.

```lua
LDepthSorter:isStable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if stable sort is enabled. |

**Example**

```lua
do
    local sorter = lurek.scene.newDepthSorter()
    local before = sorter:isStable()
    sorter:setStable(true)
    local enabled = sorter:isStable()
    sorter:setStable(false)
    local disabled = sorter:isStable()
    sorter:add(function() end, 2)
    scene_log("LDepthSorter:isStable before=" .. tostring(before) .. " enabled=" .. tostring(enabled) .. " disabled=" .. tostring(disabled) .. " count=" .. tostring(sorter:getCount()))
end
```

---

#### `LDepthSorter:setStable`

Enable or disable stable sorting. When stable, items sharing the same depth value retain their insertion order, which prevents visual flickering between overlapping sprites at the same layer. Unstable sort is slightly faster but may swap equal-depth items between frames.

```lua
LDepthSorter:setStable(stable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `stable` | boolean | True for stable sort (deterministic order at equal depth), false for unstable (faster but may flicker). |

**Example**

```lua
do
    local sorter = lurek.scene.newDepthSorter()
    sorter:setStable(true)
    example_print_log("stable = " .. tostring(sorter:isStable()))
    sorter:setStable(false)
    example_print_log("stable after disable = " .. tostring(sorter:isStable()))
end
```

---

#### `LDepthSorter:sort`

Sort all registered entries by depth without executing any callbacks. Call this only if you need to inspect the sorted order before drawing; `flush` already sorts automatically.

```lua
LDepthSorter:sort()
```

**Example**

```lua
do
    local sorter = lurek.scene.newDepthSorter()
    sorter:add(function()
        example_print_log("sorted callback")
    end, 2)
    sorter:add(function()
        example_print_log("sorted callback 2")
    end, 1)
    sorter:sort()
    example_print_log("sorted, count = " .. sorter:getCount())
    sorter:clear()
end
```

---

#### `LDepthSorter:type`

Returns the type name string `"[LDepthSorter](#ldepthsorter)"`.

```lua
LDepthSorter:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The literal `"[LDepthSorter](#ldepthsorter)"`. |

**Example**

```lua
do
    local ds = lurek.scene.newDepthSorter()
    local type_name = ds:type()
    local is_sorter = ds:typeOf("LDepthSorter")
    local is_object = ds:typeOf("Object")
    ds:add(function() end, 1)
    scene_log("LDepthSorter:type name=" .. type_name .. " sorter=" .. tostring(is_sorter) .. " object=" .. tostring(is_object) .. " count=" .. tostring(ds:getCount()))
end
```

---

#### `LDepthSorter:typeOf`

Check whether this object matches a given type name. Accepts `"[LDepthSorter](#ldepthsorter)"` or `"Object"`.

```lua
LDepthSorter:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

**Example**

```lua
do
    local ds = lurek.scene.newDepthSorter()
    local is_sorter = ds:typeOf("LDepthSorter")
    local is_object = ds:typeOf("Object")
    local is_container = ds:typeOf("LSceneObjectContainer")
    ds:setStable(true)
    scene_log("LDepthSorter:typeOf sorter=" .. tostring(is_sorter) .. " object=" .. tostring(is_object) .. " container=" .. tostring(is_container) .. " stable=" .. tostring(ds:isStable()))
end
```

---

## LSceneObjectContainer

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSceneObjectContainer:add`

Adds an object table to the scene container.

```lua
LSceneObjectContainer:add(obj)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `obj` | table | Object table to append to the scene container. |

**Example**

```lua
do
    local container = lurek.scene.newObjectContainer()
    local obj = { id = "player", layer = 2 }
    container:add(obj)
    local count = container:getCount()
    local has_obj = container:has(obj)
    local objects = container:getObjects()
    scene_log("LSceneObjectContainer:add count=" .. tostring(count) .. " has_obj=" .. tostring(has_obj) .. " first=" .. tostring(objects[1] and objects[1].id))
end
```

---

#### `LSceneObjectContainer:clear`

Remove all objects from the container.

```lua
LSceneObjectContainer:clear()
```

**Example**

```lua
do
    local container = lurek.scene.newObjectContainer()
    container:add({ id = "background", layer = 1 })
    container:add({ id = "player", layer = 2 })
    local before = container:getCount()
    container:clear()
    local after = container:getCount()
    local objects = container:getObjects()
    scene_log("LSceneObjectContainer:clear before=" .. tostring(before) .. " after=" .. tostring(after) .. " remaining=" .. tostring(#objects))
end
```

---

#### `LSceneObjectContainer:draw`

Call draw() on all objects that have a draw method, sorted by layer.

```lua
LSceneObjectContainer:draw()
```

**Example**

```lua
do
    local container = lurek.scene.newObjectContainer()
    local draws = 0
    container:add({ id = "background", layer = 1, draw = function() draws = draws + 1 end })
    container:add({ id = "player", layer = 2, draw = function() draws = draws + 1 end })
    container:draw()
    local count = container:getCount()
    scene_log("LSceneObjectContainer:draw count=" .. tostring(count) .. " draws=" .. tostring(draws))
end
```

---

#### `LSceneObjectContainer:getByLayer`

Get all objects whose layer equals `n`.

```lua
LSceneObjectContainer:getByLayer(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Target layer value. |

**Returns**

| Type | Description |
|------|-------------|
| table | Sequential table of objects on the given layer. |

**Example**

```lua
do
    local container = lurek.scene.newObjectContainer()
    container:add({ id = "background", layer = 1 })
    container:add({ id = "player", layer = 3 })
    container:add({ id = "cursor", layer = 3 })
    local objects = container:getByLayer(3)
    local first = objects[1] and objects[1].id or "none"
    local second = objects[2] and objects[2].id or "none"
    scene_log("LSceneObjectContainer:getByLayer count=" .. tostring(#objects) .. " first=" .. first .. " second=" .. second)
end
```

---

#### `LSceneObjectContainer:getCount`

Get the number of objects currently in the container.

```lua
LSceneObjectContainer:getCount()
```

**Example**

```lua
do
    local container = lurek.scene.newObjectContainer()
    container:add({ id = "background", layer = 1 })
    container:add({ id = "player", layer = 2 })
    local count = container:getCount()
    local objects = container:getObjects()
    local top = objects[#objects] and objects[#objects].id or "none"
    scene_log("LSceneObjectContainer:getCount count=" .. tostring(count) .. " top=" .. top)
end
```

---

#### `LSceneObjectContainer:getObjects`

Get all objects as an array (layer-sorted).

```lua
LSceneObjectContainer:getObjects()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Sequential table containing current objects. |

**Example**

```lua
do
    local container = lurek.scene.newObjectContainer()
    container:add({ id = "player", layer = 2 })
    container:add({ id = "background", layer = 1 })
    local objects = container:getObjects()
    local first = objects[1] and objects[1].id or "none"
    local last = objects[#objects] and objects[#objects].id or "none"
    local count = container:getCount()
    scene_log("LSceneObjectContainer:getObjects count=" .. tostring(count) .. " first=" .. first .. " last=" .. last)
end
```

---

#### `LSceneObjectContainer:has`

Check whether an object is present in the container.

```lua
LSceneObjectContainer:has(obj)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `obj` | table | Object table to test. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the exact object exists in the container. |

**Example**

```lua
do
    local container = lurek.scene.newObjectContainer()
    local obj = { id = "player", layer = 1 }
    container:add(obj)
    local present = container:has(obj)
    local missing = container:has({ id = "ghost", layer = 1 })
    local count = container:getCount()
    scene_log("LSceneObjectContainer:has present=" .. tostring(present) .. " missing=" .. tostring(missing) .. " count=" .. tostring(count))
end
```

---

#### `LSceneObjectContainer:remove`

Remove an object from the container (identity comparison).

```lua
LSceneObjectContainer:remove(obj)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `obj` | table | Object table reference to remove. |

**Example**

```lua
do
    local container = lurek.scene.newObjectContainer()
    local obj = { layer = 1 }
    container:add(obj)
    container:remove(obj)
    example_print_log("count after remove = " .. container:getCount())
end
```

---

#### `LSceneObjectContainer:type`

Gets the Lua-visible type name of this userdata.

```lua
LSceneObjectContainer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The literal `"[LSceneObjectContainer](#lsceneobjectcontainer)"`. |

**Example**

```lua
do
    local container = lurek.scene.newObjectContainer()
    local type_name = container:type()
    local matches = container:typeOf("LSceneObjectContainer")
    local other = container:typeOf("LDepthSorter")
    local count = container:getCount()
    scene_log("LSceneObjectContainer:type name=" .. type_name .. " matches=" .. tostring(matches) .. " other=" .. tostring(other) .. " count=" .. tostring(count))
end
```

---

#### `LSceneObjectContainer:typeOf`

Checks whether this container matches a type name.

```lua
LSceneObjectContainer:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when `name` matches `"[LSceneObjectContainer](#lsceneobjectcontainer)"`. |

**Example**

```lua
do
    local container = lurek.scene.newObjectContainer()
    local matches = container:typeOf("LSceneObjectContainer")
    local sorter = container:typeOf("LDepthSorter")
    container:add({ id = "player", layer = 1 })
    local count = container:getCount()
    scene_log("LSceneObjectContainer:typeOf container=" .. tostring(matches) .. " sorter=" .. tostring(sorter) .. " count=" .. tostring(count))
end
```

---

#### `LSceneObjectContainer:update`

Call update(dt) on all objects that have an update method.

```lua
LSceneObjectContainer:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds for this frame. |

**Example**

```lua
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
    example_print_log("updates called = " .. tostring(ticks))
end
```

---
