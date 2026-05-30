# scene

## General Info

- Module group: `Feature Systems`
- Source path: `src/scene/`
- Binding: `src/lua_api/scene_api.rs`
- Namespace: `lurek.scene`
- Lua API surface: `59` functions, `9` types, `10` methods
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

It provides the structural backbone for Lurek2D games by coordinating transitions between distinct game states, such as main menus, gameplay levels, and pause screens. The core `SceneStack` maintains the active scene hierarchy. Pushing a new scene pauses the underlying scene, while popping it resumes the previous one. The module supports overlay scenes for logic flow, but rendering now follows a strict engine-level rule: **only the top scene is render-active**.

Visual polish is heavily emphasized through built-in transition effects. When switching scenes, developers can apply animated transitions (including fade, wipe, slide, dissolve, pixelate, and iris effects) with configurable durations and mathematical easing curves (like bounce or back-overshoot). To ensure correct visual layering, the module features a highly optimized `DepthSorter`. This component adaptively selects the most efficient sorting strategy (unstable, stable, radix, or even multi-threaded rayon parallel sorting for 10k+ entries) based on the number of draw calls, ensuring that sprites and UI elements are rendered strictly front-to-back according to their assigned depth values.

The `scene` module also acts as a central registry and shared data bus. Scenes can be registered by string names, allowing for direct navigation (e.g., `popTo` a specific scene) or deferred loading via `pushPreloaded`, which is ideal for breaking up heavy asset initialization. Furthermore, the stack provides shared data slots, enabling scenes to pass state variables (like selected level indices or player choices) between each other without relying on fragile global variables. Game logic is driven by a deterministic callback lifecycle (`enter`, `leave`, `pause`, `resume`, `update`, `process`, `processPhysics`, `processLate`), and each callback family can be frozen/unfrozen per scene via `set*Enabled` APIs. Rendering remains separated into world-space (`render`) and screen-space (`renderUi`) passes, but both passes render only the current top scene. Exposed via the `lurek.scene.*` API, this module offers a complete solution for structuring complex, multi-state game flows.

## Files

### [depth_sorter.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/scene/depth_sorter.rs)

- This file implements the scene module's depth-ordering utility for draw work that must respect painter-style layering.
- It chooses among multiple sorting strategies so small and large batches can both be handled without one rigid algorithm for every case.
- Entries carry enough information to sort callbacks and object-style drawables through the same pipeline.
- Stable ordering can be preserved where visual flicker matters, while faster paths remain available when the batch shape allows it.
- The file is the scene system's answer to getting layered draw order right without hardcoding one sorting cost profile.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/scene/mod.rs)

- This module provides scene-stack flow control, scene rendering helpers, transition behavior, and depth ordering support for multi-state games.
- It gives the engine a structured way to move between menus, gameplay, overlays, and other major runtime states.
- At the highest level this is the feature layer that organizes game flow over time rather than individual world entities.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/scene/render.rs)

- This file bridges the current scene stack state into renderer-facing output and scene snapshots.
- It focuses on whatever scene is presently render-active, turning stack state into concrete visual results or captures.
- The file is therefore the narrow handoff between scene orchestration and image or command generation.

### [stack.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/scene/stack.rs)

- This file implements the actual scene stack that decides which scenes are present, active, paused, resumed, or removed over time.
- It supports classic push and pop navigation as well as replacements, overlays, named lookup, and explicit clearing of flow state.
- Scene lifecycle callbacks are coordinated here so transitions between states follow one consistent pattern instead of ad hoc caller logic.
- Transition queuing is integrated into the stack because movement between scenes often has both control-flow and visual timing aspects.
- Shared scene data also lives at this layer, giving separate scenes a structured way to pass values without global sprawl.
- Layer and overlay handling let multiple scenes coexist when needed while still preserving a clear notion of current stack order.
- The file is therefore the operational controller for game-state progression across menus, levels, popups, and intermediate screens.
- It is the place where scene flow becomes a managed runtime system rather than a pile of manual table swaps.

### [transition.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/scene/transition.rs)

- This file defines the time-based visual language for moving from one scene state to another without abrupt swaps.
- It combines transition kinds, easing behavior, and active progress tracking so scene changes can carry controlled visual momentum.
- Parsing support is included here because scripts often describe transitions through compact names rather than direct Rust types.
- The file turns those names and durations into concrete animated progress over time.
- In practice it is the scene module's motion vocabulary for entering, leaving, and revealing states.
