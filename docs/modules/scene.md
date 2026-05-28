# Scene

- The `scene` module is a versatile Feature Systems tier component that manages the active game state hierarchy using a robust stack-based architecture.

It provides the structural backbone for Lurek2D games by coordinating transitions between distinct game states, such as main menus, gameplay levels, and pause screens. The core `SceneStack` maintains the active scene hierarchy. Pushing a new scene pauses the underlying scene, while popping it resumes the previous one. The module supports overlay scenes for logic flow, but rendering now follows a strict engine-level rule: **only the top scene is render-active**.

Visual polish is heavily emphasized through built-in transition effects. When switching scenes, developers can apply animated transitions (including fade, wipe, slide, dissolve, pixelate, and iris effects) with configurable durations and mathematical easing curves (like bounce or back-overshoot). To ensure correct visual layering, the module features a highly optimized `DepthSorter`. This component adaptively selects the most efficient sorting strategy (unstable, stable, radix, or even multi-threaded rayon parallel sorting for 10k+ entries) based on the number of draw calls, ensuring that sprites and UI elements are rendered strictly front-to-back according to their assigned depth values.

The `scene` module also acts as a central registry and shared data bus. Scenes can be registered by string names, allowing for direct navigation (e.g., `popTo` a specific scene) or deferred loading via `pushPreloaded`, which is ideal for breaking up heavy asset initialization. Furthermore, the stack provides shared data slots, enabling scenes to pass state variables (like selected level indices or player choices) between each other without relying on fragile global variables. Game logic is driven by a deterministic callback lifecycle (`enter`, `leave`, `pause`, `resume`, `update`, `process`, `processPhysics`, `processLate`), and each callback family can be frozen/unfrozen per scene via `set*Enabled` APIs. Rendering remains separated into world-space (`render`) and screen-space (`renderUi`) passes, but both passes render only the current top scene. Exposed via the `lurek.scene.*` API, this module offers a complete solution for structuring complex, multi-state game flows.

## Functions

### `lurek.scene.clear`

Remove all scenes from the stack. Each removed scene receives its `leave()` callback in stack order. After this call the stack is empty and `isEmpty()` returns true. Useful for returning to a title screen or tearing down the entire scene graph.

```lua
-- signature
lurek.scene.clear()
```

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.clear()
    print("is empty = " .. tostring(lurek.scene.isEmpty()))
end
```

---

### `lurek.scene.clearQueuedTransitions`

Discard all queued transitions without affecting the currently-playing transition (if any). Use this to cancel a planned transition sequence mid-way.

```lua
-- signature
lurek.scene.clearQueuedTransitions()
```

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.queueTransition("fade", 0.25, "linear")
    print("queued before = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clearQueuedTransitions()
    print("queued after = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end
```

---

### `lurek.scene.define`

Create a reusable scene constructor function from a prototype table. Each call to the returned factory produces a fresh instance that inherits methods from the prototype via metatables. Ideal for defining scene "classes" that can be instantiated multiple times.

```lua
-- signature
lurek.scene.define(def)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `def?` | `table` | A prototype table with scene lifecycle methods. |

**Returns**

| Type | Description |
|------|-------------|
| `function` | A zero-argument factory function that creates new instances inheriting from `def`. |

**Example**

```lua
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
```

---

### `lurek.scene.depth`

Alias for `getStackSize`. Returns the total number of scenes currently on the stack.

```lua
-- signature
lurek.scene.depth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The current stack depth (0 when empty). |

**Example**

```lua
do
    lurek.scene.clear()
    local d0 = lurek.scene.depth()
    lurek.scene.push(lurek.scene.new({ name = "d1" }))
    local d1 = lurek.scene.depth()
    lurek.scene.clear()
    print("depth 0=" .. d0 .. " 1=" .. d1)
end
```

---

### `lurek.scene.deserializeScene`

Restore shared scene data from a previously-serialized snapshot table. Only the `data` key-value map is restored; the scene stack itself must be rebuilt manually by pushing or registering scenes. Pair with `serializeScene` for save/load workflows.

```lua
-- signature
lurek.scene.deserializeScene(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | `table` | A snapshot table as returned by `serializeScene` (must contain a `data` field). |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    local snapshot = lurek.scene.serializeScene()
    lurek.scene.removeData("score")
    lurek.scene.deserializeScene(snapshot)
    print("restored score = " .. tostring(lurek.scene.getData("score")))
    print("stack size after load = " .. lurek.scene.getStackSize())
end
```

---

### `lurek.scene.draw`

Call `draw(self)` on render-active scenes ordered by layer (lowest first).

```lua
-- signature
lurek.scene.draw()
```

**Example**

```lua
do
    local draws = 0
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "draw_scene", draw = function() draws = draws + 1 end }))
    lurek.scene.draw()
    print("draw calls = " .. draws)
    lurek.scene.clear()
end
```

---

### `lurek.scene.getActiveScenes`

Returns a Lua array of all process-active scene tables ordered by their layer value (lowest layer first). Includes regular scenes and overlays.

```lua
-- signature
lurek.scene.getActiveScenes()
```

**Returns**

| Type | Description |
|------|-------------|
| `SceneGetActiveScenesResult` | Lua array of active scene tables sorted by layer. |

**Example**

```lua
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
```

---

### `lurek.scene.getCurrent`

Returns the scene table currently on top of the stack, or nil if the stack is empty. Use this to inspect or call methods on the active scene directly.

```lua
-- signature
lurek.scene.getCurrent()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | nil | The active top scene table, or nil if no scene is on the stack. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    local current = lurek.scene.getCurrent()
    print("current name = " .. tostring(current and current.name))
    lurek.scene.clear()
end
```

---

### `lurek.scene.getCurrentLayer`

Get the rendering layer of the current top scene. Returns 0 if the stack is empty or if no layer was explicitly set.

```lua
-- signature
lurek.scene.getCurrentLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The integer layer value of the top scene, or 0 if empty. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setCurrentLayer(12)
    print("current layer = " .. tostring(lurek.scene.getCurrentLayer()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.getData`

Retrieve a value from the shared data map by key, or nil if the key has not been set. Commonly used in a scene's `enter` callback to read parameters set by the previous scene.

```lua
-- signature
lurek.scene.getData(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | The data key to look up. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | The stored value, or nil if the key does not exist. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    print("score = " .. tostring(lurek.scene.getData("score")))
end
```

---

### `lurek.scene.getQueuedTransitionCount`

Returns the number of transitions waiting in the queue behind the currently-playing transition.

```lua
-- signature
lurek.scene.getQueuedTransitionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of queued (not yet started) transitions. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.queueTransition("fade", 0.25, "linear")
    print("queued transitions = " .. lurek.scene.getQueuedTransitionCount())
    lurek.scene.clear()
end
```

---

### `lurek.scene.getRegistered`

Retrieve a previously registered scene table by its name, or nil if no scene is registered under that name. Does not affect the stack.

```lua
-- signature
lurek.scene.getRegistered(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The registered scene name to look up. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | nil | The scene table, or nil if not found. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    local scene = lurek.scene.getRegistered("main_scene")
    print("registered scene = " .. tostring(scene and scene.name))
end
```

---

### `lurek.scene.getRegisteredNames`

Returns an array of all currently registered scene name strings. Useful for debugging or building dynamic scene-selection UIs.

```lua
-- signature
lurek.scene.getRegisteredNames()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Lua array of registered name strings. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    lurek.scene.registerScene("pause_scene", lurek.scene.new({ name = "pause_scene" }))
    local names = lurek.scene.getRegisteredNames()
    print("registered names = " .. #names)
    print("first name = " .. tostring(names[1]))
end
```

---

### `lurek.scene.getRenderActiveScenes`

Returns the scene table(s) that are render-active this frame.

```lua
-- signature
lurek.scene.getRenderActiveScenes()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Lua array of render-active scene tables. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "overlay" }))
    local active = lurek.scene.getRenderActiveScenes()
    print("getRenderActiveScenes count = " .. #active)
    print("top render-active = " .. tostring(active[1] and active[1].name))
    lurek.scene.clear()
end
```

---

### `lurek.scene.getStackSize`

Returns the total number of scenes currently on the stack, including overlays. Useful for asserting expected navigation depth or debugging scene flow.

```lua
-- signature
lurek.scene.getStackSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | The current stack depth (0 when empty). |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("stack size = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end
```

---

### `lurek.scene.getTransitionProgress`

Returns the raw linear progress (0.0 to 1.0) of the current transition animation, ignoring easing. Returns 0 when no transition is active. Use `getTransitionProgressEased` for the eased value.

```lua
-- signature
lurek.scene.getTransitionProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Linear progress from 0 (start) to 1 (complete). |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    print("transition progress = " .. lurek.scene.getTransitionProgress())
    lurek.scene.clear()
end
```

---

### `lurek.scene.getTransitionProgressEased`

Returns the eased progress (0.0 to 1.0) of the current transition, with the selected easing curve applied. Returns 0 when no transition is active. Use this instead of `getTransitionProgress` when you want smooth, non-linear animation values.

```lua
-- signature
lurek.scene.getTransitionProgressEased()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Eased progress from 0 (start) to 1 (complete). |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    print("eased progress = " .. lurek.scene.getTransitionProgressEased())
    lurek.scene.clear()
end
```

---

### `lurek.scene.getTransitionTypes`

Returns a Lua array of all supported transition type name strings. Use this to discover available transitions at runtime or build a transition picker UI.

```lua
-- signature
lurek.scene.getTransitionTypes()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Lua array of strings: `"none"`, `"fade"`, `"slideleft"`, `"slideright"`, `"slideup"`, `"slidedown"`, `"wipe"`, `"iris"`, `"zoom"`, `"crossfade"`. |

**Example**

```lua
do
    local types = lurek.scene.getTransitionTypes()
    print("transition types = " .. #types)
    print("first type = " .. tostring(types[1]))
end
```

---

### `lurek.scene.hasData`

Check whether a key exists in the shared scene data map without retrieving its value.

```lua
-- signature
lurek.scene.hasData(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | The data key to check for. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a value is stored under this key. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.setData("score", 42)
    print("has score = " .. tostring(lurek.scene.hasData("score")))
end
```

---

### `lurek.scene.hasRegistered`

Check whether a scene is registered under the given name.

```lua
-- signature
lurek.scene.hasRegistered(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The scene name to look up. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a scene is registered with that name. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.registerScene("main_scene", lurek.scene.new({ name = "main_scene" }))
    print("has main_scene = " .. tostring(lurek.scene.hasRegistered("main_scene")))
end
```

---

### `lurek.scene.isEmpty`

Returns true if the scene stack contains no scenes at all. Useful for guarding against calling `pop` on an empty stack or for detecting when the game should quit.

```lua
-- signature
lurek.scene.isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the stack is empty (depth == 0). |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("before clear = " .. tostring(lurek.scene.isEmpty()))
    lurek.scene.clear()
    print("after clear = " .. tostring(lurek.scene.isEmpty()))
end
```

---

### `lurek.scene.isLateEnabled`

Returns whether `process_late` is enabled for a selected scene.

```lua
-- signature
lurek.scene.isLateEnabled(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | `any` | nil/current, registered scene name, or 1-based stack index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when enabled, false when frozen or target not found. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("isLateEnabled = " .. tostring(lurek.scene.isLateEnabled()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isOverlay`

Returns true if the current top scene was pushed via `pushOverlay`. Overlay scenes do not pause the scene beneath them, allowing both scenes to remain process-active unless explicitly frozen.

```lua
-- signature
lurek.scene.isOverlay()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the top scene is an overlay, false otherwise. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.pushOverlay(lurek.scene.new({ name = "pause_overlay" }), "fade", 0.2)
    print("top scene is overlay = " .. tostring(lurek.scene.isOverlay()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isPhysicsEnabled`

Returns whether `process_physics` is enabled for a selected scene.

```lua
-- signature
lurek.scene.isPhysicsEnabled(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | `any` | nil/current, registered scene name, or 1-based stack index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when enabled, false when frozen or target not found. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("isPhysicsEnabled = " .. tostring(lurek.scene.isPhysicsEnabled()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isPreloaded`

Returns true if the named preload loader has already been executed at least once. Once a loader runs, subsequent `pushPreloaded` calls skip the loader and push the already-registered scene directly.

```lua
-- signature
lurek.scene.isPreloaded(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The preload name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the loader has already executed. |

**Example**

```lua
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
```

---

### `lurek.scene.isProcessEnabled`

Returns whether `process` is enabled for a selected scene.

```lua
-- signature
lurek.scene.isProcessEnabled(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | `any` | nil/current, registered scene name, or 1-based stack index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when enabled, false when frozen or target not found. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("isProcessEnabled = " .. tostring(lurek.scene.isProcessEnabled()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isTransitioning`

Returns true if a scene transition animation is currently playing. Use this to block input or skip certain logic during transitions.

```lua
-- signature
lurek.scene.isTransitioning()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True while a transition animation is in progress. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "base_scene" }))
    lurek.scene.switchTo(lurek.scene.new({ name = "next_scene" }), "fade", 0.25, "linear")
    print("is transitioning = " .. tostring(lurek.scene.isTransitioning()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.isUpdateEnabled`

Returns whether `update` is enabled for a selected scene.

```lua
-- signature
lurek.scene.isUpdateEnabled(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | `any` | nil/current, registered scene name, or 1-based stack index. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when enabled, false when frozen or target not found. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    print("isUpdateEnabled = " .. tostring(lurek.scene.isUpdateEnabled()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.new`

Create a new scene instance from an optional prototype table. Sets up metatables so the instance inherits methods from the prototype. Use this for one-off scene creation; use `define` when you need a reusable scene constructor.

```lua
-- signature
lurek.scene.new(def)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `def?` | `table` | A prototype table containing scene lifecycle methods (`enter`, `leave`, `update`, `draw`, etc.). If omitted, an empty table is used. |

**Returns**

| Type | Description |
|------|-------------|
| `SceneNewResult` | A new instance table with `def` as its metatable `__index`. |

**Example**

```lua
do
    local myScene = lurek.scene.new({ name = "menu", enter = function() print("entering menu scene") end, leave = function() print("leaving menu scene") end, update = function() end, draw = function() end })
    print("scene created")
end
```

---

### `lurek.scene.newDepthSorter`

Create a new `LDepthSorter` instance for collecting drawable items and flushing them in depth-sorted (painter's algorithm) order.

```lua
-- signature
lurek.scene.newDepthSorter()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDepthSorter` | A fresh depth sorter with no queued entries. |

**Example**

```lua
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
```

---

### `lurek.scene.newScene`

Alias for `lurek.scene.new`. Creates a new scene instance from an optional prototype table while preserving the older API name still used by tests, examples, and existing game scripts.

```lua
-- signature
lurek.scene.newScene(def)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `def?` | `table` | A prototype table containing scene lifecycle methods (`enter`, `leave`, `update`, `draw`, etc.). If omitted, an empty table is used. |

**Returns**

| Type | Description |
|------|-------------|
| `SceneNewSceneResult` | A new instance table with `def` as its metatable `__index`. |

**Example**

```lua
do
    local scene = lurek.scene.newScene({ name = "test_new" })
    print("scene name = " .. tostring(scene.name))
    print("has metatable = " .. tostring(getmetatable(scene) ~= nil))
end
```

---

### `lurek.scene.pop`

Pop the top scene off the stack and return to the previous one. The popped scene receives `leave()` and the revealed scene receives `resume()` (unless the popped scene was an overlay, in which case the underlying scene was never paused). Use this for "back" navigation, closing menus, or exiting sub-screens.

```lua
-- signature
lurek.scene.pop(transition, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `transition?` | `string` | Transition type name. Defaults to `"none"` (instant). |
| `duration?` | `number` | Transition animation duration in seconds. Defaults to 0. |
| `easing?` | `string` | Easing curve name. Defaults to `"linear"`. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "first_scene" }))
    lurek.scene.push(lurek.scene.new({ name = "second_scene" }))
    lurek.scene.pop()
    print("stack size after pop = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end
```

---

### `lurek.scene.popTo`

Pop scenes off the stack until the named registered scene is on top. Every popped scene receives `leave()` and the target scene receives `resume()`. The target scene must have been previously added via `registerScene`. Returns false if no scene with that name exists on the stack.

```lua
-- signature
lurek.scene.popTo(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The registered name of the target scene to unwind to. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the named scene was found and is now the active top scene, false if the name was not found. |

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
    print("popTo base = " .. tostring(found))
    print("popTo missing = " .. tostring(missing) .. " depth = " .. lurek.scene.depth())
    lurek.scene.clear()
end
```

---

### `lurek.scene.preload`

Register a deferred-loading function for a scene. The loader function is NOT called immediately — it runs the first time `pushPreloaded` is called with this name. Use this to spread scene initialization (asset loading, table setup) across loading screens or lazy-load heavy scenes on demand.

```lua
-- signature
lurek.scene.preload(name, loader)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name to associate with the loader (must match the name used in `pushPreloaded`). |
| `loader` | `function` | A zero-argument function that creates and registers the scene via `registerScene` when called. |

**Example**

```lua
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
```

---

### `lurek.scene.process`

Call `ready(self)` once on newly-pushed scenes, then call `process(self, dt)` on every process-active scene ordered by layer (lowest first).

```lua
-- signature
lurek.scene.process(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Fixed time-step delta in seconds (e.g. 1/60 for 60-tick logic). |

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
    print("process count = " .. processCount)
    print("last dt = " .. tostring(scene.last_dt))
    lurek.scene.clear()
end
```

---

### `lurek.scene.processLate`

Call `process_late(self, dt)` on every process-active scene after all other processing.

```lua
-- signature
lurek.scene.processLate(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds (same value passed to `process`). |

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
    print("late = " .. lateCount .. " physics = " .. physCount)
    lurek.scene.clear()
end
```

---

### `lurek.scene.processPhysics`

Call `process_physics(self, dt)` on every process-active scene ordered by layer.

```lua
-- signature
lurek.scene.processPhysics(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Physics time-step delta in seconds. |

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
    print("physics count = " .. physicsCount)
    print("last physics dt = " .. tostring(scene.last_physics_dt))
    lurek.scene.clear()
end
```

---

### `lurek.scene.push`

Push a new scene onto the stack, making it the active scene. The previously-active scene receives its `pause()` lifecycle callback and the new scene receives `enter(self, params)`. An optional visual transition (fade, slide, iris, etc.) animates between the two scenes over the specified duration.

```lua
-- signature
lurek.scene.push(scene, transition, duration, easing, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scene` | `table` | A scene table with lifecycle methods (`enter`, `leave`, `pause`, `resume`, `update`, `draw`, etc.). |
| `transition?` | `string` | Transition type name: `"fade"`, `"slideleft"`, `"slideright"`, `"slideup"`, `"slidedown"`, `"wipe"`, `"iris"`, `"zoom"`, `"crossfade"`. Defaults to `"none"`. |
| `duration?` | `number` | Transition animation duration in seconds. Defaults to 0 (instant). |
| `easing?` | `string` | Easing curve name (e.g. `"linear"`, `"ease_in"`, `"ease_out"`, `"ease_in_out"`). Defaults to `"linear"`. |
| `params?` | `table` | Arbitrary data forwarded to the new scene's `enter(self, params)` callback for initialization. |

**Example**

```lua
do
    local scene1 = lurek.scene.new({ name = "title", enter = function() print("title enter") end, leave = function() print("title leave") end })
    lurek.scene.push(scene1)
    print("after push depth = " .. lurek.scene.getStackSize())
    lurek.scene.clear()
end
```

---

### `lurek.scene.pushOverlay`

Push a scene as an overlay on top of the current scene. Unlike `push`, the underlying scene is NOT paused — it can continue to receive `process` callbacks unless frozen. Rendering remains single-scene (top scene only) at engine level.

```lua
-- signature
lurek.scene.pushOverlay(scene, transition, duration, easing, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scene` | `table` | The overlay scene table. |
| `transition?` | `string` | Transition type name. Defaults to `"none"`. |
| `duration?` | `number` | Transition animation duration in seconds. Defaults to 0. |
| `easing?` | `string` | Easing curve name. Defaults to `"linear"`. |
| `params?` | `table` | Arbitrary data forwarded to the overlay's `enter(self, params)` callback. |

**Example**

```lua
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
```

---

### `lurek.scene.pushPreloaded`

Push a preloaded scene onto the stack by name. If the loader registered via `preload` has not yet run, it executes first to create and register the scene. Then the registered scene is pushed with the specified transition. Combines deferred loading with stack navigation in a single call.

```lua
-- signature
lurek.scene.pushPreloaded(name, transition, duration, easing, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The preload/registration name (must match a prior `preload` or `registerScene` call). |
| `transition?` | `string` | Transition type name. Defaults to `"none"`. |
| `duration?` | `number` | Transition animation duration in seconds. Defaults to 0. |
| `easing?` | `string` | Easing curve name. Defaults to `"linear"`. |
| `params?` | `table` | Arbitrary data forwarded to the scene's `enter(self, params)` callback. |

**Example**

```lua
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
```

---

### `lurek.scene.queueTransition`

Queue a transition to play automatically after the current one finishes. Multiple queued transitions execute in FIFO order, enabling multi-step cinematic sequences (e.g. fade-out then slide-in).

```lua
-- signature
lurek.scene.queueTransition(transition, duration, easing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `transition` | `string` | Transition type name (e.g. `"fade"`, `"iris"`, `"wipe"`). |
| `duration` | `number` | Duration in seconds. |
| `easing?` | `string` | Easing curve name. Defaults to `"linear"`. |

**Example**

```lua
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
```

---

### `lurek.scene.registerScene`

Register a scene table under a unique name for later retrieval via `getRegistered`, navigation via `popTo`, or deferred push via `pushPreloaded`. Registering does not push the scene onto the stack.

```lua
-- signature
lurek.scene.registerScene(name, scene)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique name to associate with this scene (e.g. `"mainMenu"`, `"gameplay"`). |
| `scene` | `table` | The scene table to register. |

**Example**

```lua
do
    local menuScene = lurek.scene.new({ name = "mainMenu" })
    lurek.scene.registerScene("mainMenu", menuScene)
    print("has mainMenu = " .. tostring(lurek.scene.hasRegistered("mainMenu")))
end
```

---

### `lurek.scene.removeData`

Remove a key and its associated value from the shared scene data map. No-op if the key does not exist.

```lua
-- signature
lurek.scene.removeData(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | The data key to remove. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.setData("_test_key", 42)
    print("before remove = " .. tostring(lurek.scene.hasData("_test_key")))
    lurek.scene.removeData("_test_key")
    print("after remove = " .. tostring(lurek.scene.hasData("_test_key")))
end
```

---

### `lurek.scene.render`

Call `render(self)` on render-active scenes ordered by layer (lowest first).

```lua
-- signature
lurek.scene.render()
```

**Example**

```lua
do
    lurek.scene.clear()
    local renderCount = 0
    lurek.scene.push(lurek.scene.new({ render = function() renderCount = renderCount + 1 end }))
    lurek.scene.render()
    print("render count = " .. renderCount)
    lurek.scene.clear()
end
```

---

### `lurek.scene.renderUi`

Call `render_ui(self)` on render-active scenes ordered by layer (lowest first).

```lua
-- signature
lurek.scene.renderUi()
```

**Example**

```lua
do
    lurek.scene.clear()
    local uiCount = 0
    lurek.scene.push(lurek.scene.new({ render_ui = function() uiCount = uiCount + 1 end }))
    lurek.scene.renderUi()
    print("render ui count = " .. uiCount)
    lurek.scene.clear()
end
```

---

### `lurek.scene.serializeScene`

Capture the current scene stack state as a serializable snapshot table. The snapshot contains a `stack` array of registered scene names (in stack order) and a `data` map of shared data key-value pairs. Use this for save/load systems to persist the player's navigation state.

```lua
-- signature
lurek.scene.serializeScene()
```

**Returns**

| Type | Description |
|------|-------------|
| `SceneSerializeSceneResult` | A snapshot table with `stack` (array of scene name strings) and `data` (key-value map) fields. |

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
    print("stack = " .. #snapshot.stack)
    print("saved level = " .. tostring(snapshot.data.level) .. " checkpoint = " .. tostring(snapshot.data.checkpoint))
    lurek.scene.clear()
    lurek.scene.deserializeScene(snapshot)
    print("restored level = " .. tostring(lurek.scene.getData("level")))
    lurek.scene.clear()
end
```

---

### `lurek.scene.setCurrentLayer`

Set the rendering layer of the current top scene. Scenes with higher layer values are processed and drawn after lower-layer scenes. Use layers to control draw order when multiple scenes are active (e.g. game world at layer 0, HUD overlay at layer 10).

```lua
-- signature
lurek.scene.setCurrentLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `number` | Integer layer value to assign (higher = drawn later / on top). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if a scene was on top and the layer was set, false if the stack is empty. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "layer_scene" }))
    local ok = lurek.scene.setCurrentLayer(8)
    print("set layer ok = " .. tostring(ok))
    print("current layer = " .. tostring(lurek.scene.getCurrentLayer()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.setData`

Store an arbitrary Lua value in the scene module's shared data map, keyed by a string name. Scenes can use this to pass information between each other without direct references — for example, passing a selected level index from a menu scene to a gameplay scene.

```lua
-- signature
lurek.scene.setData(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | The key to store data under (e.g. `"selectedLevel"`, `"playerName"`). |
| `value` | `any` | Value to store under the scene data key. |

**Example**

```lua
do
    lurek.scene.setData("selectedLevel", 5)
    print("has selectedLevel = " .. tostring(lurek.scene.hasData("selectedLevel")))
    print("selectedLevel = " .. lurek.scene.getData("selectedLevel"))
end
```

---

### `lurek.scene.setLateEnabled`

Enable or disable `process_late(self, dt)` execution for a selected scene.

```lua
-- signature
lurek.scene.setLateEnabled(target, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | `any` | nil/current, registered scene name, or 1-based stack index. |
| `enabled` | `boolean` | True to run late callback, false to freeze it. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when target scene was resolved and updated. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setLateEnabled(nil, false)
    print("setLateEnabled = " .. tostring(lurek.scene.isLateEnabled()))
    lurek.scene.setLateEnabled(nil, true)
    print("after reset = " .. tostring(lurek.scene.isLateEnabled()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.setPhysicsEnabled`

Enable or disable `process_physics(self, dt)` execution for a selected scene.

```lua
-- signature
lurek.scene.setPhysicsEnabled(target, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | `any` | nil/current, registered scene name, or 1-based stack index. |
| `enabled` | `boolean` | True to run physics callback, false to freeze it. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when target scene was resolved and updated. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setPhysicsEnabled(nil, false)
    print("setPhysicsEnabled = " .. tostring(lurek.scene.isPhysicsEnabled()))
    lurek.scene.setPhysicsEnabled(nil, true)
    print("after reset = " .. tostring(lurek.scene.isPhysicsEnabled()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.setProcessEnabled`

Enable or disable `process(self, dt)` execution for a selected scene.

```lua
-- signature
lurek.scene.setProcessEnabled(target, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | `any` | nil/current, registered scene name, or 1-based stack index. |
| `enabled` | `boolean` | True to run process, false to freeze it. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when target scene was resolved and updated. |

**Example**

```lua
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
```

---

### `lurek.scene.setUpdateEnabled`

Enable or disable `update(self, dt)` execution for a selected scene.

```lua
-- signature
lurek.scene.setUpdateEnabled(target, enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target?` | `any` | nil/current, registered scene name, or 1-based stack index. |
| `enabled` | `boolean` | True to run update callback, false to freeze it. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when target scene was resolved and updated. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.push(lurek.scene.new({ name = "main_scene" }))
    lurek.scene.setUpdateEnabled(nil, false)
    print("setUpdateEnabled = " .. tostring(lurek.scene.isUpdateEnabled()))
    lurek.scene.setUpdateEnabled(nil, true)
    print("after reset = " .. tostring(lurek.scene.isUpdateEnabled()))
    lurek.scene.clear()
end
```

---

### `lurek.scene.switchTo`

Replace the current top scene with a different one without changing stack depth. The old scene receives `leave()` and the new scene receives `enter(self, params)`. Unlike `push`, no scene is added to the stack — the old scene is removed and the new one takes its slot. Ideal for transitioning between peer-level game states (e.g. level 1 → level 2).

```lua
-- signature
lurek.scene.switchTo(scene, transition, duration, easing, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scene` | `table` | The replacement scene table. |
| `transition?` | `string` | Transition type name. Defaults to `"none"`. |
| `duration?` | `number` | Transition animation duration in seconds. Defaults to 0. |
| `easing?` | `string` | Easing curve name. Defaults to `"linear"`. |
| `params?` | `table` | Arbitrary data forwarded to the new scene's `enter(self, params)` callback. |

**Example**

```lua
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
```

---

### `lurek.scene.unregisterScene`

Remove a scene registration by name. Does not pop the scene if it is currently active on the stack — it only removes the name mapping.

```lua
-- signature
lurek.scene.unregisterScene(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The registered name to remove. |

**Example**

```lua
do
    lurek.scene.clear()
    lurek.scene.registerScene("_tmp_unreg", lurek.scene.new({ name = "_tmp_unreg" }))
    print("before unregister = " .. tostring(lurek.scene.hasRegistered("_tmp_unreg")))
    lurek.scene.unregisterScene("_tmp_unreg")
    print("after unregister = " .. tostring(lurek.scene.hasRegistered("_tmp_unreg")))
end
```

---

### `lurek.scene.update`

Advance any active transition animation and call `update(self, dt)` on the current top scene.

```lua
-- signature
lurek.scene.update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds since the last frame (e.g. from `lurek.timer.getDelta()`). |

**Example**

```lua
do
    -- update advances transitions and dispatches the update callback to the top scene
    lurek.scene.clear()
    local s = lurek.scene.new({ name = "update_test" })
    lurek.scene.push(s)
    lurek.scene.update(0.016)
    lurek.scene.clear()
    print("lurek.scene.update ok")
end
```

---

## LDepthSorter

### `LDepthSorter:add`

Register a draw callback at a given depth value. When `flush` is called, all registered callbacks execute in back-to-front order (lowest depth drawn first, highest depth drawn last / on top). Use this for simple draw calls like sprite rendering where each entity has a depth/z-layer.

```lua
-- signature
LDepthSorter:add(callback, depth)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | `function` | A zero-argument draw function invoked during flush. |
| `depth` | `number` | Numeric z-depth controlling draw order — lower values are drawn behind higher values. |

**Example**

```lua
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
```

---

### `LDepthSorter:addObject`

Register a game object table for depth-sorted rendering. The object must expose a numeric `depth` field and a `drawSorted(self)` method. During `flush`, each object's `drawSorted` is called in depth order, making this ideal for entity-based architectures where objects manage their own drawing.

```lua
-- signature
LDepthSorter:addObject(obj)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `obj` | `table` | A game object table with a numeric `depth` field and a `drawSorted(self)` method. |

**Example**

```lua
do
    local sorter = lurek.scene.newDepthSorter()
    local obj1 = { depth = 3, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }
    local obj2 = { depth = 1, drawSorted = function(self) print("draw obj at depth " .. self.depth) end }
    sorter:addObject(obj1)
    sorter:addObject(obj2)
    print("count = " .. sorter:getCount())
    sorter:flush()
end
```

---

### `LDepthSorter:clear`

Discard all pending entries without executing any draw callbacks. Use this when a scene is interrupted, reset, or destroyed before its normal `flush` call.

```lua
-- signature
LDepthSorter:clear()
```

**Example**

```lua
do
    local sorter = lurek.scene.newDepthSorter()
    sorter:add(function()
        print("queued callback")
    end, 3)
    print("before clear count = " .. sorter:getCount())
    sorter:clear()
    print("cleared count = " .. sorter:getCount())
end
```

---

### `LDepthSorter:flush`

Sort all entries by depth, execute every callback or object's `drawSorted` method in back-to-front order, then clear the sorter for the next frame. This is the standard one-call render path — call it once per frame inside your scene's `draw` or `render` callback.

```lua
-- signature
LDepthSorter:flush()
```

**Example**

```lua
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
```

---

### `LDepthSorter:getCount`

Returns the number of draw entries currently queued for the next `flush` call. Useful for debugging or deciding whether to skip an empty render pass.

```lua
-- signature
LDepthSorter:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of pending draw entries. |

**Example**

```lua
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
```

---

### `LDepthSorter:isStable`

Returns whether the sorter uses stable sorting.

```lua
-- signature
LDepthSorter:isStable()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if stable sort is enabled. |

**Example**

```lua
do
    local sorter = lurek.scene.newDepthSorter()
    print("stable default = " .. tostring(sorter:isStable()))
    sorter:setStable(true)
    print("stable after enable = " .. tostring(sorter:isStable()))
end
```

---

### `LDepthSorter:setStable`

Enable or disable stable sorting. When stable, items sharing the same depth value retain their insertion order, which prevents visual flickering between overlapping sprites at the same layer. Unstable sort is slightly faster but may swap equal-depth items between frames.

```lua
-- signature
LDepthSorter:setStable(stable)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `stable` | `boolean` | True for stable sort (deterministic order at equal depth), false for unstable (faster but may flicker). |

**Example**

```lua
do
    local sorter = lurek.scene.newDepthSorter()
    sorter:setStable(true)
    print("stable = " .. tostring(sorter:isStable()))
    sorter:setStable(false)
    print("stable after disable = " .. tostring(sorter:isStable()))
end
```

---

### `LDepthSorter:sort`

Sort all registered entries by depth without executing any callbacks. Call this only if you need to inspect the sorted order before drawing; `flush` already sorts automatically.

```lua
-- signature
LDepthSorter:sort()
```

**Example**

```lua
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
```

---

### `LDepthSorter:type`

Returns the type name string `"LDepthSorter"`.

```lua
-- signature
LDepthSorter:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The literal `"LDepthSorter"`. |

**Example**

```lua
do
    local ds = lurek.scene.newDepthSorter()
    print("type = " .. ds:type())
end
```

---

### `LDepthSorter:typeOf`

Check whether this object matches a given type name. Accepts `"LDepthSorter"` or `"Object"`.

```lua
-- signature
LDepthSorter:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The type name to test against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local ds = lurek.scene.newDepthSorter()
    print("is depth sorter = " .. tostring(ds:typeOf("LDepthSorter")))
    print("is object = " .. tostring(ds:typeOf("Object")))
end
```

---
