# event

## General Info

- Module group: `Core Runtime`
- Source path: `src/event/`
- Lua API path(s): `src/lua_api/event_api.rs`
- Primary Lua namespace: `lurek.event`
- Rust test path(s): tests/rust/unit/event_tests.rs, plus inline unit coverage in src/event/event_queue.rs and src/event/signal.rs
- Lua test path(s): tests/lua/unit/test_event.lua, tests/lua/integration/test_audio_event.lua

## Summary

The `event` module is Lurek2D's centralised event queue — the single channel through which OS input, window state changes, custom Lua events, and automation-injected synthetic input flow before being dispatched to Lua callbacks. It is a Core Runtime tier module with no upstream engine dependencies. All modules that raise or consume events route through this module rather than coupling directly to each other.

**EventQueue — the core FIFO.** `EventQueue` is a FIFO ring of `Event` values backed by `VecDeque`. `App` pushes events during the winit event handler; at the start of each logical-update tick the queue is drained and dispatched to registered Lua listeners. `push(event)`, `push_event(name, args)`, `poll()`, `clear()`, `is_empty()`, `len()`. The `wait(timeout_ms)` variant blocks until an event arrives or the timeout elapses, used in CI screenshot mode.

**Event enum.** `Event` is a flat tagged struct carrying a name string and a `Vec<EventArg>` payload. The engine internally dispatches OS events as named events with typed arguments: `"keydown"` (keycode, scancode, modifiers, repeat), `"keyup"`, `"mousemove"` (x, y), `"mousedown"` / `"mouseup"` (button, x, y), `"mousewheel"` (dx, dy), `"gamepadaxis"` (device_id, axis, value), `"gamepadbutton"` (device_id, button, pressed), `"textinput"` (Unicode string), `"resize"` (w, h), `"focus"` / `"blur"`, `"filedrop"` (path), `"touch"` (id, phase, x, y). `UserEvent` is the variant emitted by `lurek.event.emit(name, data)` for pub-sub between Lua scripts.

**Deferred dispatch.** The `EventBus` supports deferred batching: `push_deferred(event)` enqueues into a pending buffer; `flush()` atomically merges the buffer into the main queue; `drain()` discards the pending buffer without dispatching. This enables patterns where multiple events are committed as a group or discarded atomically — useful for undo/redo stacks and transaction-like game-state updates. Lua: `lurek.event.pushDeferred(name, data)`, `lurek.event.flush()`.

**Signal — handle-based pub-sub.** `Signal` is a separate pub-sub dispatcher providing handle-based subscriptions with exact-name and glob-wildcard matching. `subscribe(event_name, handler) → handle_id`, `remove(handle_id)`, `clear(event_name)`, `clear_all()`. Glob subscriptions (`"enemy.*"`) match any event whose name begins with the prefix. The Signal is Lua-accessible via `lurek.event.newSignal()`, providing scoped pub-sub within a module without routing through the global queue.

**Automation integration.** The `automation` module injects synthetic events through the same `push()` path as real hardware events, making playback transparent to downstream callbacks — a key property for deterministic test replay.

**Threading note.** `EventQueue` is shared via `Rc<RefCell<EventQueue>>` inside `SharedState` and is only safe on the main thread. Background threads communicate via `lurek.thread.Channel` instead.

**Lua surface.** `lurek.event.emit(name, data)` — emit a custom event. `lurek.event.on(name, callback) → handle` — subscribe. `lurek.event.off(handle)` — unsubscribe. `lurek.event.once(name, callback)` — subscribe for one delivery. `lurek.event.pushDeferred(name, data)`, `flush()`. `lurek.event.newSignal()` → `Signal` userdata: `subscribe(name, fn)`, `remove(handle)`, `clear(name)`, `clearAll()`, `fire(name, ...)`.

**Scope boundary.** Core Runtime tier. No upstream engine dependencies. Lua bridge in `src/lua_api/event_api.rs`; OS event dispatch via `app` module.

## Files

- `event_queue.rs`: Event types and FIFO event queue.
- `mod.rs`: Event queue for polling system and custom events.
- `signal.rs`: Handle-based pub-sub signal system with exact-name and glob-wildcard subscriptions.

## Types

- `EventArg` (`enum`, `event_queue.rs`): Argument values that can be attached to events.
- `Event` (`struct`, `event_queue.rs`): A single event in the event queue.
- `EventQueue` (`struct`, `event_queue.rs`): FIFO event queue for system and custom events.
- `Subscription` (`struct`, `signal.rs`): A single subscription entry in a [`Signal`].
- `Signal` (`struct`, `signal.rs`): Handle-based pub-sub signal dispatcher.

## Functions

- `EventQueue::new` (`event_queue.rs`): Create a new empty event queue.
- `EventQueue::push` (`event_queue.rs`): Push an event onto the queue.
- `EventQueue::push_event` (`event_queue.rs`): Push an event by name and arguments.
- `EventQueue::poll` (`event_queue.rs`): Poll the next event from the queue.
- `EventQueue::clear` (`event_queue.rs`): Clear all events from the queue.
- `EventQueue::is_empty` (`event_queue.rs`): Check if the queue is empty.
- `EventQueue::len` (`event_queue.rs`): Get the number of events in the queue.
- `EventQueue::pump` (`event_queue.rs`): Drains pending OS-level events into the queue (no-op in Lurek2D; documents as a sync point).
- `EventQueue::wait` (`event_queue.rs`): Blocks until an event is available or `timeout_ms` milliseconds elapse.
- `EventArg::from_lua_val` (`event_queue.rs`): Converts a [`LuaValue`] to an [`EventArg`] for event queue storage.
- `event_to_lua_multi` (`event_queue.rs`): Converts an [`Event`] into a Lua multi-value (name followed by args).
- `Signal::new` (`signal.rs`): Creates a new empty signal dispatcher.
- `Signal::subscribe` (`signal.rs`): Registers a subscription for the given event name.
- `Signal::remove` (`signal.rs`): Removes a subscription by its handle ID.
- `Signal::clear` (`signal.rs`): Removes all subscriptions for the given event name.
- `Signal::clear_all` (`signal.rs`): Removes all subscriptions across all event names.
- `Signal::get_handles` (`signal.rs`): Returns the handles registered for the given event name (in registration order).
- `Signal::get_count` (`signal.rs`): Returns the number of subscriptions for the given event name.
- `Signal::get_total_count` (`signal.rs`): Returns the total number of subscriptions across all event names.
- `Signal::subscribe_wildcard` (`signal.rs`): Registers a wildcard pattern subscription.
- `Signal::get_wildcard_handles` (`signal.rs`): Returns all wildcard handles whose pattern matches the given event name.
- `Signal::is_wildcard` (`signal.rs`): Returns `true` if `pattern` contains glob metacharacters (`*` or `?`).

## Lua API Reference

- Binding path(s): `src/lua_api/event_api.rs`
- Namespace: `lurek.event`

### Module Functions
- `lurek.event.exit`: Pushes an exit event, requesting the engine to stop.
- `lurek.event.poll`: Returns an iterator function that pops events from the queue.
- `lurek.event.clear`: Discards all pending events in the queue.
- `lurek.event.newSignal`: Creates a new pub-sub Signal dispatcher.
- `lurek.event.pump`: Syncs OS-level events into the queue (no-op in Lurek2D push model).
- `lurek.event.wait`: Blocks until the next event arrives or the optional timeout elapses.
- `lurek.event.restart`: Requests that the engine restart at the beginning of the next frame.
- `lurek.event.quit`: Alias for `exit()` â€” requests the engine to stop at the end of the current frame.
- `lurek.event.pushDeferred`: Pushes a named event to the deferred buffer; it will not reach the main queue
- `lurek.event.flushDeferred`: Moves all buffered deferred events into the main event queue and clears the buffer.
- `lurek.event.enableHistory`: Enables event history recording, keeping the last `capacity` pushed events.
- `lurek.event.getHistory`: Returns an array of recent events as `{name, args}` tables.
- `lurek.event.clearHistory`: Clears all recorded event history.
- `lurek.event.push`: Adds an event item to the end of the event queue for processing.

### `Signal` Methods
- `Signal:emit`: Emits the named event, calling all registered callbacks with extra arguments.
- `Signal:remove`: Removes a subscription by handle ID.
- `Signal:clear`: Removes all callbacks for the named event.
- `Signal:clearAll`: Removes all callbacks across all events.
- `Signal:getCount`: Returns the callback count for the named event.
- `Signal:getTotalCount`: Returns the total callback count across all events.
- `Signal:type`: Returns the type name of this object.
- `Signal:typeOf`: Returns true if the given type name matches this object's type or any parent type.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/event/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- **Wildcard semantics**: `*` matches any sequence of characters (excluding `/`); `?` matches exactly one character. Wildcard patterns are stored separately in `wildcard_subs: Vec<(String, u64)>` and evaluated via `glob_match` on every `emit` call after the exact-name callbacks have fired.
