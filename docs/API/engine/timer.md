# luna2d::timer

_Source: `src/timer/`_


Mod implementation for the `timer` subsystem. This module is part of Luna2D's `timer` subsystem and provides the implementation details for mod-related operations and data management. All public items are documented. See the parent module for architectural context and the `luna.*` Lua API for the scripting interface.


## Types

### `Clock`

Tracks per-frame delta time, accumulated total time, and a rolling FPS measurement.


**Fields**

| Name | Type / Description |
|---|---|
| `start_time` | `Instant` |
| `last_frame` | `Instant` |
| `delta` | `f64` |
| `total` | `f64` |
| `frame_count` | `u64` |
| `fps` | `f64` |
| `fps_timer` | `f64` |
| `fps_frame_count` | `u64` |
| `delta_buffer` | `[f64; AVERAGE_DELTA_WINDOW]` |
| `delta_buffer_index` | `usize` |
| `delta_buffer_filled` | `bool` |

#### Methods

##### `pub fn new() -> Self`

Creates a new `Clock`, recording the current instant as the start time.


**Returns** `A new `Clock` with delta = 0, FPS = 0, and frame count = 0.`


##### `pub fn tick(&mut self) -> f64`

Advances the clock by one frame, updating delta time, total time, and rolling FPS. Call once per frame at the top of the game loop. The rolling FPS is updated every second using a frame-accumulation window.


**Returns** `f64` — The elapsed time since the last `tick` call, in seconds.`


##### `pub fn delta(&self) -> f64`

Returns the delta time for the most recently completed frame in seconds.


**Returns** `f64` — Frame delta time in seconds.`


##### `pub fn total(&self) -> f64`

Returns the total elapsed time since the clock was created, in seconds.


**Returns** `f64` — Total engine uptime in seconds.`


##### `pub fn fps(&self) -> f64`

Returns the rolling frames-per-second measurement. Updated once per second. Returns `0.0` during the first second of execution.


**Returns** `f64` — Current FPS estimate.`


##### `pub fn frame_count(&self) -> u64`

Returns the total number of frames that have elapsed since the clock was created.


**Returns** `u64` — Cumulative frame count.`


##### `pub fn elapsed(&self) -> f64`

Returns a live high-resolution elapsed time since the clock was created, in seconds. Unlike [`Clock::total`], which caches its value on each [`Clock::tick`] call, this method queries the system clock directly, giving sub-microsecond precision at the moment of the call.


**Returns** `f64` — Elapsed time since clock creation in seconds.`


##### `pub fn average_delta(&self) -> f64`

Returns the average delta time over the last N frames (up to 60). Returns `0.0` if no frames have been ticked yet. Once the buffer is full, averages over the entire 60-frame window.


**Returns** `f64` — Rolling average delta in seconds.`


---

### `ScheduledEvent`

A single scheduled event with optional name and pause state.


**Fields**

| Name | Type / Description |
|---|---|
| `id` | `u32` |
| `name` | `Option<String>` |
| `remaining` | `f64` |
| `interval` | `f64` |
| `count` | `i32` |
| `one_shot` | `bool` |
| `paused` | `bool` |
---

### `Scheduler`

Manages a collection of timed events (one-shot and repeating). Each event has an integer ID (returned on creation) that can be used for cancellation, pause/resume, and property reads. Named events can also be cancelled by their string name. The global `time_scale` multiplier compresses or stretches all timers. A scale of `0.5` makes everything run at half speed; `2.0` doubles speed. Individual events can be paused with [`Scheduler::pause`].


#### Methods

##### `pub fn new() -> Self`

Create a new empty Scheduler with time-scale 1.0.


**Returns** `Self`.`


##### `pub fn after(&mut self, delay: f64) -> u32`

Schedule a one-shot callback after `delay` seconds. Returns an event ID usable for cancellation, pause, and queries.


**Parameters**

| Name | Type / Description |
|---|---|
| `delay` | `f64` |

**Returns** `u32`.`


##### `pub fn after_named(&mut self, name: impl Into<String>, delay: f64) -> u32`

Schedule a one-shot callback with a `name` for cancel-by-name support. If an event with the same name already exists it is replaced. Returns the new event ID.


**Parameters**

| Name | Type / Description |
|---|---|
| `name` | `impl Into<String>` |
| `delay` | `f64` |

**Returns** `u32`.`


##### `pub fn every(&mut self, interval: f64, count: i32) -> u32`

Schedule a repeating callback at `interval` seconds. `count` limits repetitions (-1 = infinite). Returns event ID.


**Parameters**

| Name | Type / Description |
|---|---|
| `interval` | `f64` |
| `count` | `i32` |

**Returns** `u32`.`


##### `pub fn every_named(&mut self, name: impl Into<String>, interval: f64, count: i32) -> u32`

Schedule a named repeating callback. Replaces any existing event with the same name.


**Parameters**

| Name | Type / Description |
|---|---|
| `name` | `impl Into<String>` |
| `interval` | `f64` |
| `count` | `i32` |

**Returns** `u32`.`


##### `pub fn cancel(&mut self, id: u32) -> bool`

Cancel a scheduled event by its ID. Returns `true` if found and cancelled.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `u32` |

**Returns** `bool`.`


##### `pub fn cancel_named(&mut self, name: &str) -> Option<u32>`

Cancel a scheduled event by its name. Returns the ID of the cancelled event, or `None` if no match.


**Parameters**

| Name | Type / Description |
|---|---|
| `name` | `&str` |

**Returns** `Option<u32>`.`


##### `pub fn cancel_all(&mut self) -> u32`

Cancel all scheduled events. Returns the number cancelled.


**Returns** `u32`.`


##### `pub fn pause(&mut self, id: u32) -> bool`

Pause a single event by ID. Its remaining time is frozen until resumed. Returns `true` if found.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `u32` |

**Returns** `bool`.`


##### `pub fn resume(&mut self, id: u32) -> bool`

Resume a previously paused event by ID. Returns `true` if found.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `u32` |

**Returns** `bool`.`


##### `pub fn is_paused(&self, id: u32) -> bool`

Returns `true` if the event with `id` is currently paused.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `u32` |

**Returns** `bool`.`


##### `pub fn get_remaining(&self, id: u32) -> Option<f64>`

Returns the time remaining until the next fire for event `id`, or `None` if not found.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `u32` |

**Returns** `Option<f64>`.`


##### `pub fn get_interval(&self, id: u32) -> Option<f64>`

Returns the base interval for event `id`, or `None` if not found.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `u32` |

**Returns** `Option<f64>`.`


##### `pub fn get_repeat_count(&self, id: u32) -> Option<i32>`

Returns the repeat count remaining for event `id` (-1 = infinite), or `None` if not found.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `u32` |

**Returns** `Option<i32>`.`


##### `pub fn set_interval(&mut self, id: u32, new_interval: f64) -> bool`

Change the interval of a repeating event. Also resets `remaining` to the new interval. Returns `true` if found.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `u32` |
| `new_interval` | `f64` |

**Returns** `bool`.`


##### `pub fn reset_event(&mut self, id: u32) -> bool`

Reset an event's remaining time to its original interval. Useful to restart a repeating event without cancelling it. Returns `true` if found.


**Parameters**

| Name | Type / Description |
|---|---|
| `id` | `u32` |

**Returns** `bool`.`


##### `pub fn set_time_scale(&mut self, scale: f64)`

Set the global time-scale multiplier for this scheduler. A scale of `0.5` runs all timers at half speed; `2.0` doubles speed. The scale is clamped to `[0.0, 100.0]`.


**Parameters**

| Name | Type / Description |
|---|---|
| `scale` | `f64` |

##### `pub fn get_time_scale(&self) -> f64`

Returns the current global time-scale.


**Returns** `f64`.`


##### `pub fn update(&mut self, dt: f64) -> Vec<u32>`

Advance all non-paused timers by `dt * time_scale` seconds. Returns a vector of event IDs that fired this update. Expired one-shot and count-limited events are automatically removed.


**Parameters**

| Name | Type / Description |
|---|---|
| `dt` | `f64` |

**Returns** `Vec<u32>`.`


##### `pub fn count(&self) -> usize`

Get the number of active (non-expired) scheduled events.


**Returns** `usize`.`


##### `pub fn active_ids(&self) -> Vec<u32>`

Get the IDs of all active events.


**Returns** `Vec<u32>`.`


##### `pub fn is_empty(&self) -> bool`

Returns `true` if no events are scheduled.


**Returns** `bool`.`


---


## Functions

### `pub fn sleep(seconds: f64)`

Suspends the current thread for the given number of seconds. Values ≤ 0 are ignored. This is a simple convenience wrapper around [`std::thread::sleep`].


**Parameters**

| Name | Type / Description |
|---|---|
| `seconds` | `f64` |
---
