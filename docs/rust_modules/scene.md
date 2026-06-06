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

This module provides a robust game flow and state control subsystem built on a structured scene stack model. It organizes game progression across major runtime states, such as menus, levels, and popup screens, through standard push, pop, and switch operations. The stack supports overlay layouts that can run alongside underlying states, and utilizes prototype metatable factories to define and instantiate custom scene classes dynamically.

State navigation is governed by a predictable lifecycle callback pipeline. Pushed, popped, or transitioned scenes receive timely enter, leave, pause, resume, and ready callbacks in strict stack order, ensuring consistent state setups. To prevent startup stutters under heavy loads, developers can register deferred preload functions, lazy-loading heavy asset pools only when a scene is first pushed to the stack.

To bridge state changes smoothly, the module implements timed visual transition queues. Scene switches can trigger animated slides, fades, sweeps, or iris wipes with configurable easing curves. Easing parameters convert name descriptors into dynamic progress values, while a first-in-first-out transition queue schedules sequential animations automatically to support complex cinematic reveal loops.

Frictions during transition and save-state routing are resolved using shared contexts and serialization engines. The module maintains a shared key-value data register that lets adjacent scenes pass parameters cleanly without global namespace sprawl. Additionally, it compiles the active scene stack and its shared context into a serializable snapshot table, enabling quick save and reload workflows.

Finally, the system integrates a z-ordered painter-style depth sorter to handle visual overlays. The sorter collects raw draw callbacks or drawable game tables, sorting them in a back-to-front order before rendering. It supports both high-performance sorting and stable sorting configurations; enabling stable sorting prevents visual flickering for overlapping objects that share identical z-depths.

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
