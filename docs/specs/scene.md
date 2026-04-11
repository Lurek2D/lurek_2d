# scene

## General Info

- Module group: `Feature Systems.`
- Source path: `src/scene/`
- Lua API path(s): `src/lua_api/scene_api.rs`
- Primary Lua namespace: `lurek.scene`
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

The scene module owns the Rust-side state model for scene flow. It exists so games can push, pop, replace, and query scenes through one consistent stack abstraction while leaving the actual scene tables and lifecycle callback execution in the Lua API layer.

Its boundary is intentionally narrow: `SceneStack` tracks IDs, registry entries, shared data keys, and active transition timing, while `DepthSorter` provides a per-frame helper for ordering scene-related draw callbacks. It does not own scene content, entity storage, or renderer-specific transition visuals; those stay in Lua or in the systems the scenes call into.

**Scope boundary**: This module currently depends on `image`, `render`, `runtime`. It stays within the Feature Systems responsibility boundary defined in the architecture docs.

## Files

- `depth_sorter.rs`: Per-frame depth-ordered callback batcher used by the Lua scene layer.
- `mod.rs`: Module root and re-export surface for the stack, transition, and depth-sorting types.
- `render.rs`: Empty render-command and simple CPU-image helpers so `SceneStack` fits shared engine interfaces.
- `stack.rs`: Scene stack, registry, shared-data bookkeeping, and transition state ownership.
- `transition.rs`: Transition-type enum plus active transition progress and timer logic.

## Types

- `DepthEntry` (`struct`, `depth_sorter.rs`): Individual depth-sorted entry stored inside `DepthSorter`.
- `DepthSorter` (`struct`, `depth_sorter.rs`): Per-frame sorter for scene draw callbacks or scene objects.
- `SceneId` (`type`, `stack.rs`): Stable integer identifier used by the Rust stack while Lua owns the actual scene tables.
- `SceneStack` (`struct`, `stack.rs`): Main scene-flow owner for stack order, registry lookups, stored data keys, and active transition state.
- `TransitionType` (`enum`, `transition.rs`): Enum for no transition, fade, and slide directions.
- `ActiveTransition` (`struct`, `transition.rs`): Timer and progress record for one transition in flight.

## Functions

- `DepthSorter::new` (`depth_sorter.rs`): Create a new empty depth sorter.
- `DepthSorter::add` (`depth_sorter.rs`): Add a callback at the given depth.
- `DepthSorter::add_object` (`depth_sorter.rs`): Add an object with a `:drawSorted()` method at the given depth.
- `DepthSorter::sort` (`depth_sorter.rs`): Sort entries by depth ascending (lower depth = drawn first).
- `DepthSorter::sorted_entries` (`depth_sorter.rs`): Get the sorted entries for external processing (sort + return refs).
- `DepthSorter::clear` (`depth_sorter.rs`): Clear all entries without calling them.
- `DepthSorter::get_count` (`depth_sorter.rs`): Number of queued entries.
- `SceneStack::generate_render_commands` (`render.rs`): Generate GPU render commands for the active scene.
- `SceneStack::draw_to_image` (`render.rs`): Render the scene stack state to a CPU image for headless testing.
- `SceneStack::new` (`stack.rs`): Create a new empty scene stack.
- `SceneStack::next_scene_id` (`stack.rs`): Allocate a new unique scene ID.
- `SceneStack::push` (`stack.rs`): Push a scene ID onto the stack and start a transition.
- `SceneStack::pop` (`stack.rs`): Pop the top scene from the stack.
- `SceneStack::switch_to` (`stack.rs`): Replace the top scene with a new one.
- `SceneStack::clear` (`stack.rs`): Remove all scenes from the stack.
- `SceneStack::pop_to` (`stack.rs`): Look up a registered scene ID by name.
- `SceneStack::pop_until` (`stack.rs`): Pop scenes until `target_id` is on top of the stack.
- `SceneStack::get_stack_size` (`stack.rs`): Number of scenes on the stack.
- `SceneStack::is_empty` (`stack.rs`): Whether the stack is empty.
- `SceneStack::get_current` (`stack.rs`): Get the top scene ID, or `None` if empty.
- `SceneStack::get_all` (`stack.rs`): Get all scene IDs in the stack, bottom-to-top.
- `SceneStack::is_transitioning` (`stack.rs`): Whether a transition is currently active.
- `SceneStack::get_transition_progress` (`stack.rs`): Get transition progress [0, 1], or 0 if no transition.
- `SceneStack::update_transition` (`stack.rs`): Update the active transition timer.
- `SceneStack::register_scene` (`stack.rs`): Register a scene by name.
- `SceneStack::get_registered` (`stack.rs`): Get a registered scene ID by name.
- `SceneStack::has_registered` (`stack.rs`): Check if a name is registered.
- `SceneStack::unregister_scene` (`stack.rs`): Unregister a scene by name.
- `SceneStack::get_registered_names` (`stack.rs`): Get all registered scene names.
- `SceneStack::set_data` (`stack.rs`): Store a data value reference by key.
- `SceneStack::get_data` (`stack.rs`): Get a stored data value reference by key.
- `SceneStack::has_data` (`stack.rs`): Check if a data key exists.
- `SceneStack::remove_data` (`stack.rs`): Remove a data value by key.
- `TransitionType::from_lua_str` (`transition.rs`): Parse a transition type from a Lua string.
- `ActiveTransition::new` (`transition.rs`): Create a new active transition.
- `ActiveTransition::progress` (`transition.rs`): Normalized progress of the transition, clamped to [0, 1].
- `ActiveTransition::is_complete` (`transition.rs`): Whether the transition has completed.
- `ActiveTransition::update` (`transition.rs`): Advance the transition timer by `dt` seconds.

## Lua API Reference

- Binding path(s): `src/lua_api/scene_api.rs`
- Namespace: `lurek.scene`

### Module Functions
- `lurek.scene.push`: Pushes a scene table onto the stack with an optional transition.
- `lurek.scene.pop`: Pops the top scene from the stack with an optional transition.
- `lurek.scene.switchTo`: Replaces the top scene with a new one, calling leave and enter callbacks.
- `lurek.scene.clear`: Clears all scenes from the stack, calling leave on each.
- `lurek.scene.popTo`: Pops scenes until the named scene is on top, calling leave on each removed.
- `lurek.scene.update`: Updates the top scene and any active transition (legacy name; prefer `process`).
- `lurek.scene.process`: Calls `scene:ready(self)` on the top scene if not yet fired, then `scene:process(dt)`.
- `lurek.scene.processPhysics`: Calls `scene:process_physics(dt)` on the topmost scene (fixed timestep).
- `lurek.scene.processLate`: Calls `scene:process_late(dt)` on the topmost scene (after process, before render).
- `lurek.scene.draw`: Draws all scenes in the stack from bottom to top (legacy name; prefer `render`).
- `lurek.scene.render`: Draws all scenes in the stack from bottom to top.
- `lurek.scene.renderUi`: Draws UI overlay for all scenes in the stack from bottom to top.
- `lurek.scene.getStackSize`: Returns the number of scenes on the stack.
- `lurek.scene.isEmpty`: Returns true if the scene stack is empty.
- `lurek.scene.getCurrent`: Returns the current top scene table, or nil if the stack is empty.
- `lurek.scene.isTransitioning`: Returns true if a scene transition is currently active.
- `lurek.scene.getTransitionProgress`: Returns the transition progress from 0.0 to 1.0.
- `lurek.scene.registerScene`: Registers a scene table by name for later retrieval.
- `lurek.scene.getRegistered`: Returns a registered scene table by name, or nil if not found.
- `lurek.scene.hasRegistered`: Returns true if a scene is registered under the given name.
- `lurek.scene.unregisterScene`: Removes a scene from the registry by name.
- `lurek.scene.getRegisteredNames`: Returns a list of all registered scene names.
- `lurek.scene.setData`: Stores a value in the inter-scene data store under the given key.
- `lurek.scene.getData`: Returns a value from the inter-scene data store, or nil if not found.
- `lurek.scene.hasData`: Returns true if the given key exists in the data store.
- `lurek.scene.removeData`: Removes a value from the inter-scene data store by key.
- `lurek.scene.newDepthSorter`: Creates a new DepthSorter for z-ordered draw batching.
- `lurek.scene.new`: Creates a scene instance directly from a methods table.
- `lurek.scene.define`: Creates a reusable scene class — returns a zero-argument constructor function.

### `DepthSorter` Methods
- `DepthSorter:add`: Registers a draw callback at the given depth layer.
- `DepthSorter:addObject`: Registers a table object with a draw method at the given depth.
- `DepthSorter:sort`: Sorts all registered callbacks by depth ascending.
- `DepthSorter:flush`: Calls all draw callbacks in sorted depth order, then clears.
- `DepthSorter:clear`: Removes all registered callbacks without calling them.
- `DepthSorter:getCount`: Returns the number of registered draw entries.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/scene/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
