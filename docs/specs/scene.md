# scene

## TL;DR

- The `scene` module controls game flow with a stack model: move between states, run transitions, keep shared context, and keep scene lifecycle behavior predictable.

## General Info

- Module group: `Feature Systems`
- Source path: `src/scene/`
- Binding: `src/lua_api/scene_api.rs`
- Namespace: `lurek.scene`
- Lua API surface: `59` functions, `9` types, `10` methods
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

The `scene` module is the flow controller for game states. It gives one consistent way to move between menu, gameplay, pause, and result screens, while preserving clear state transitions over time. Instead of manual table swaps in many scripts, teams can rely on one stack model that defines what is active now, what was suspended, and what should resume next.

Functionally, this module keeps scene lifecycle behavior stable. Enter, leave, pause, resume, and frame callbacks follow one predictable sequence, which reduces hidden edge cases when projects grow. The same control surface also lets teams freeze selected callback families per scene, so they can pause parts of logic intentionally without tearing scene state apart.

Transition handling is built into the same runtime path, so state changes can be presented as controlled motion rather than abrupt jumps. Fade, slide, wipe, iris, and other effects are not separate custom systems; they are part of the scene contract. This makes cinematic flow and UX polish easier to maintain, because navigation and transition timing live in one place.

The module also supports practical orchestration patterns needed in larger games. Scenes can be registered by name, preloaded lazily, pushed as overlays, replaced in place, or popped back to a known target. Shared scene data keys provide a direct handoff channel between states, so scripts can pass values like selected mode, checkpoint id, or UI intent without depending on broad global state.

Rendering policy is explicit and consistent with stack control: scene logic can involve overlays and layered activity, while render-active output remains deterministic. Depth sorting utilities are available for ordered drawing inside scene rendering flows, helping teams keep visual layering stable across dense sprite and UI compositions.

In practice, `lurek.scene` is the module that turns "screen flow" into a disciplined runtime system. It combines navigation, lifecycle, transition sequencing, shared context, and draw-order support so both small games and complex multi-screen projects can evolve without scene-management chaos.

## Imports

- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `src/math/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### depth_sorter.rs

- This file implements the scene module's depth-ordering utility for draw work that must respect painter-style layering.
- It chooses among multiple sorting strategies so small and large batches can both be handled without one rigid algorithm for every case.
- Entries carry enough information to sort callbacks and object-style drawables through the same pipeline.
- Stable ordering can be preserved where visual flicker matters, while faster paths remain available when the batch shape allows it.
- The file is the scene system's answer to getting layered draw order right without hardcoding one sorting cost profile.

### mod.rs

- This module provides scene-stack flow control, scene rendering helpers, transition behavior, and depth ordering support for multi-state games.
- It gives the engine a structured way to move between menus, gameplay, overlays, and other major runtime states.
- At the highest level this is the feature layer that organizes game flow over time rather than individual world entities.

### render.rs

- This file bridges the current scene stack state into renderer-facing output and scene snapshots.
- It focuses on whatever scene is presently render-active, turning stack state into concrete visual results or captures.
- The file is therefore the narrow handoff between scene orchestration and image or command generation.

### stack.rs

- This file implements the actual scene stack that decides which scenes are present, active, paused, resumed, or removed over time.
- It supports classic push and pop navigation as well as replacements, overlays, named lookup, and explicit clearing of flow state.
- Scene lifecycle callbacks are coordinated here so transitions between states follow one consistent pattern instead of ad hoc caller logic.
- Transition queuing is integrated into the stack because movement between scenes often has both control-flow and visual timing aspects.
- Shared scene data also lives at this layer, giving separate scenes a structured way to pass values without global sprawl.
- Layer and overlay handling let multiple scenes coexist when needed while still preserving a clear notion of current stack order.
- The file is therefore the operational controller for game-state progression across menus, levels, popups, and intermediate screens.
- It is the place where scene flow becomes a managed runtime system rather than a pile of manual table swaps.

### transition.rs

- This file defines the time-based visual language for moving from one scene state to another without abrupt swaps.
- It combines transition kinds, easing behavior, and active progress tracking so scene changes can carry controlled visual momentum.
- Parsing support is included here because scripts often describe transitions through compact names rather than direct Rust types.
- The file turns those names and durations into concrete animated progress over time.
- In practice it is the scene module's motion vocabulary for entering, leaving, and revealing states.

## Lua API Ref

### Functions

- `lurek.scene.clear`: Remove all scenes from the stack. Each removed scene receives its `leave()` callback in stack order. After this call the stack is empty and `isEmpty()` returns true. Useful for returning to a title screen or tearing down the entire scene graph.
- `lurek.scene.clearQueuedTransitions`: Discard all queued transitions without affecting the currently-playing transition (if any). Use this to cancel a planned transition sequence mid-way.
- `lurek.scene.define`: Create a reusable scene constructor function from a prototype table. Each call to the returned factory produces a fresh instance that inherits methods from the prototype via metatables. Ideal for defining scene "classes" that can be instantiated multiple times.
- `lurek.scene.depth`: Alias for `getStackSize`. Returns the total number of scenes currently on the stack.
- `lurek.scene.deserializeScene`: Restore shared scene data from a previously-serialized snapshot table. Only the `data` key-value map is restored; the scene stack itself must be rebuilt manually by pushing or registering scenes. Pair with `serializeScene` for save/load workflows.
- `lurek.scene.draw`: Call `draw(self)` on render-active scenes ordered by layer (lowest first).
- `lurek.scene.getActiveScenes`: Returns a Lua array of all process-active scene tables ordered by their layer value (lowest layer first). Includes regular scenes and overlays.
- `lurek.scene.getCurrent`: Returns the scene table currently on top of the stack, or nil if the stack is empty. Use this to inspect or call methods on the active scene directly.
- `lurek.scene.getCurrentLayer`: Get the rendering layer of the current top scene. Returns 0 if the stack is empty or if no layer was explicitly set.
- `lurek.scene.getData`: Retrieve a value from the shared data map by key, or nil if the key has not been set. Commonly used in a scene's `enter` callback to read parameters set by the previous scene.
- `lurek.scene.getQueuedTransitionCount`: Returns the number of transitions waiting in the queue behind the currently-playing transition.
- `lurek.scene.getRegistered`: Retrieve a previously registered scene table by its name, or nil if no scene is registered under that name. Does not affect the stack.
- `lurek.scene.getRegisteredNames`: Returns an array of all currently registered scene name strings. Useful for debugging or building dynamic scene-selection UIs.
- `lurek.scene.getRenderActiveScenes`: Returns the scene table(s) that are render-active this frame.
- `lurek.scene.getStackSize`: Returns the total number of scenes currently on the stack, including overlays. Useful for asserting expected navigation depth or debugging scene flow.
- `lurek.scene.getTransitionProgress`: Returns the raw linear progress (0.0 to 1.0) of the current transition animation, ignoring easing. Returns 0 when no transition is active. Use `getTransitionProgressEased` for the eased value.
- `lurek.scene.getTransitionProgressEased`: Returns the eased progress (0.0 to 1.0) of the current transition, with the selected easing curve applied. Returns 0 when no transition is active. Use this instead of `getTransitionProgress` when you want smooth, non-linear animation values.
- `lurek.scene.getTransitionTypes`: Returns a Lua array of all supported transition type name strings. Use this to discover available transitions at runtime or build a transition picker UI.
- `lurek.scene.hasData`: Check whether a key exists in the shared scene data map without retrieving its value.
- `lurek.scene.hasRegistered`: Check whether a scene is registered under the given name.
- `lurek.scene.isEmpty`: Returns true if the scene stack contains no scenes at all. Useful for guarding against calling `pop` on an empty stack or for detecting when the game should quit.
- `lurek.scene.isLateEnabled`: Returns whether `process_late` is enabled for a selected scene.
- `lurek.scene.isOverlay`: Returns true if the current top scene was pushed via `pushOverlay`. Overlay scenes do not pause the scene beneath them, allowing both scenes to remain process-active unless explicitly frozen.
- `lurek.scene.isPhysicsEnabled`: Returns whether `process_physics` is enabled for a selected scene.
- `lurek.scene.isPreloaded`: Returns true if the named preload loader has already been executed at least once. Once a loader runs, subsequent `pushPreloaded` calls skip the loader and push the already-registered scene directly.
- `lurek.scene.isProcessEnabled`: Returns whether `process` is enabled for a selected scene.
- `lurek.scene.isTransitioning`: Returns true if a scene transition animation is currently playing. Use this to block input or skip certain logic during transitions.
- `lurek.scene.isUpdateEnabled`: Returns whether `update` is enabled for a selected scene.
- `lurek.scene.new`: Create a new scene instance from an optional prototype table. Sets up metatables so the instance inherits methods from the prototype. Use this for one-off scene creation; use `define` when you need a reusable scene constructor.
- `lurek.scene.newDepthSorter`: Create a new `LDepthSorter` instance for collecting drawable items and flushing them in depth-sorted (painter's algorithm) order.
- `lurek.scene.newScene`: Alias for `lurek.scene.new`. Creates a new scene instance from an optional prototype table while preserving the older API name still used by tests, examples, and existing game scripts.
- `lurek.scene.pop`: Pop the top scene off the stack and return to the previous one. The popped scene receives `leave()` and the revealed scene receives `resume()` (unless the popped scene was an overlay, in which case the underlying scene was never paused). Use this for "back" navigation, closing menus, or exiting sub-screens.
- `lurek.scene.popTo`: Pop scenes off the stack until the named registered scene is on top. Every popped scene receives `leave()` and the target scene receives `resume()`. The target scene must have been previously added via `registerScene`. Returns false if no scene with that name exists on the stack.
- `lurek.scene.preload`: Register a deferred-loading function for a scene. The loader function is NOT called immediately â€” it runs the first time `pushPreloaded` is called with this name. Use this to spread scene initialization (asset loading, table setup) across loading screens or lazy-load heavy scenes on demand.
- `lurek.scene.process`: Call `ready(self)` once on newly-pushed scenes, then call `process(self, dt)` on every process-active scene ordered by layer (lowest first).
- `lurek.scene.processLate`: Call `process_late(self, dt)` on every process-active scene after all other processing.
- `lurek.scene.processPhysics`: Call `process_physics(self, dt)` on every process-active scene ordered by layer.
- `lurek.scene.push`: Push a new scene onto the stack, making it the active scene. The previously-active scene receives its `pause()` lifecycle callback and the new scene receives `enter(self, params)`. An optional visual transition (fade, slide, iris, etc.) animates between the two scenes over the specified duration.
- `lurek.scene.pushOverlay`: Push a scene as an overlay on top of the current scene. Unlike `push`, the underlying scene is NOT paused â€” it can continue to receive `process` callbacks unless frozen. Rendering remains single-scene (top scene only) at engine level.
- `lurek.scene.pushPreloaded`: Push a preloaded scene onto the stack by name. If the loader registered via `preload` has not yet run, it executes first to create and register the scene. Then the registered scene is pushed with the specified transition. Combines deferred loading with stack navigation in a single call.
- `lurek.scene.queueTransition`: Queue a transition to play automatically after the current one finishes. Multiple queued transitions execute in FIFO order, enabling multi-step cinematic sequences (e.g. fade-out then slide-in).
- `lurek.scene.registerScene`: Register a scene table under a unique name for later retrieval via `getRegistered`, navigation via `popTo`, or deferred push via `pushPreloaded`. Registering does not push the scene onto the stack.
- `lurek.scene.removeData`: Remove a key and its associated value from the shared scene data map. No-op if the key does not exist.
- `lurek.scene.render`: Call `render(self)` on render-active scenes ordered by layer (lowest first).
- `lurek.scene.renderUi`: Call `render_ui(self)` on render-active scenes ordered by layer (lowest first).
- `lurek.scene.serializeScene`: Capture the current scene stack state as a serializable snapshot table. The snapshot contains a `stack` array of registered scene names (in stack order) and a `data` map of shared data key-value pairs. Use this for save/load systems to persist the player's navigation state.
- `lurek.scene.setCurrentLayer`: Set the rendering layer of the current top scene. Scenes with higher layer values are processed and drawn after lower-layer scenes. Use layers to control draw order when multiple scenes are active (e.g. game world at layer 0, HUD overlay at layer 10).
- `lurek.scene.setData`: Store an arbitrary Lua value in the scene module's shared data map, keyed by a string name. Scenes can use this to pass information between each other without direct references â€” for example, passing a selected level index from a menu scene to a gameplay scene.
- `lurek.scene.setLateEnabled`: Enable or disable `process_late(self, dt)` execution for a selected scene.
- `lurek.scene.setPhysicsEnabled`: Enable or disable `process_physics(self, dt)` execution for a selected scene.
- `lurek.scene.setProcessEnabled`: Enable or disable `process(self, dt)` execution for a selected scene.
- `lurek.scene.setUpdateEnabled`: Enable or disable `update(self, dt)` execution for a selected scene.
- `lurek.scene.switchTo`: Replace the current top scene with a different one without changing stack depth. The old scene receives `leave()` and the new scene receives `enter(self, params)`. Unlike `push`, no scene is added to the stack â€” the old scene is removed and the new one takes its slot. Ideal for transitioning between peer-level game states (e.g. level 1 â†’ level 2).
- `lurek.scene.transitions.fade`: Helper sub-table `lurek.scene.transitions` with convenience factory functions that build transition descriptor tables for use with transition-aware APIs.
- `lurek.scene.transitions.iris`: Create an iris (circle) transition descriptor table. A circular aperture opens or closes to reveal the new scene, similar to classic cartoon transitions.
- `lurek.scene.transitions.slide`: Create a directional slide transition descriptor table. The new scene slides in from the specified direction, pushing the old scene out.
- `lurek.scene.transitions.wipe`: Create a horizontal wipe transition descriptor table. A wipe bar sweeps across the screen to reveal the new scene.
- `lurek.scene.unregisterScene`: Remove a scene registration by name. Does not pop the scene if it is currently active on the stack â€” it only removes the name mapping.
- `lurek.scene.update`: Advance any active transition animation and call `update(self, dt)` on the current top scene.

### Callbacks

- `LDepthSorter:add` param `callback` (`function`): A zero-argument draw function invoked during flush.
- `lurek.scene.preload` param `loader` (`function`): A zero-argument function that creates and registers the scene via `registerScene` when called.

### Enums

- No documented module-level enums/constants.

### Types

#### LDepthSorter Type

- Depth sorter exposed to Lua as `LDepthSorter`. Collects draw callbacks or drawable objects with numeric depth values and flushes them in back-to-front order for correct painter's-algorithm rendering. Ideal for sorting sprites, particles, and layered game objects within a single scene.

##### Fields

- No documented fields.

##### Methods

- `LDepthSorter:add`: Register a draw callback at a given depth value. When `flush` is called, all registered callbacks execute in back-to-front order (lowest depth drawn first, highest depth drawn last / on top). Use this for simple draw calls like sprite rendering where each entity has a depth/z-layer.
- `LDepthSorter:addObject`: Register a game object table for depth-sorted rendering. The object must expose a numeric `depth` field and a `drawSorted(self)` method. During `flush`, each object's `drawSorted` is called in depth order, making this ideal for entity-based architectures where objects manage their own drawing.
- `LDepthSorter:clear`: Discard all pending entries without executing any draw callbacks. Use this when a scene is interrupted, reset, or destroyed before its normal `flush` call.
- `LDepthSorter:flush`: Sort all entries by depth, execute every callback or object's `drawSorted` method in back-to-front order, then clear the sorter for the next frame. This is the standard one-call render path â€” call it once per frame inside your scene's `draw` or `render` callback.
- `LDepthSorter:getCount`: Returns the number of draw entries currently queued for the next `flush` call. Useful for debugging or deciding whether to skip an empty render pass.
- `LDepthSorter:isStable`: Returns whether the sorter uses stable sorting.
- `LDepthSorter:setStable`: Enable or disable stable sorting. When stable, items sharing the same depth value retain their insertion order, which prevents visual flickering between overlapping sprites at the same layer. Unstable sort is slightly faster but may swap equal-depth items between frames.
- `LDepthSorter:sort`: Sort all registered entries by depth without executing any callbacks. Call this only if you need to inspect the sorted order before drawing; `flush` already sorts automatically.
- `LDepthSorter:type`: Returns the type name string `"LDepthSorter"`.
- `LDepthSorter:typeOf`: Check whether this object matches a given type name. Accepts `"LDepthSorter"` or `"Object"`.

#### LSceneGetActiveScenesResult Type

- Generated result shape from @field tags.

##### Fields

- `__index` (`table`): Prototype table (the scene definition used to create this instance).

##### Methods

- No documented methods.

#### LSceneNewResult Type

- Generated result shape from @field tags.

##### Fields

- `__index` (`table`): Prototype table (the def parameter).

##### Methods

- No documented methods.

#### LSceneNewSceneResult Type

- Generated result shape from @field tags.

##### Fields

- `__index` (`table`): Prototype table (the def parameter).

##### Methods

- No documented methods.

#### LSceneSerializeSceneResult Type

- Generated result shape from @field tags.

##### Fields

- `data` (`table`): Key-value map of shared scene data.
- `stack` (`string[]`): Scene stack as ordered array of registered name strings.

##### Methods

- No documented methods.

#### LTransitionsFadeResult Type

- Generated result shape from @field tags.

##### Fields

- `duration` (`number`): Duration in seconds.
- `type` (`string`): Transition type name.

##### Methods

- No documented methods.

#### LTransitionsIrisResult Type

- Generated result shape from @field tags.

##### Fields

- `duration` (`number`): Duration in seconds.
- `type` (`string`): Transition type name.

##### Methods

- No documented methods.

#### LTransitionsSlideResult Type

- Generated result shape from @field tags.

##### Fields

- `duration` (`number`): Duration in seconds.
- `type` (`string`): Transition type name.

##### Methods

- No documented methods.

#### LTransitionsWipeResult Type

- Generated result shape from @field tags.

##### Fields

- `duration` (`number`): Duration in seconds.
- `type` (`string`): Transition type name.

##### Methods

- No documented methods.
