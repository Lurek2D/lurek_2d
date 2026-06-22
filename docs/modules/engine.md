# Engine

## Purpose

Drives the main winit/wgpu frame loop and Lua VM execution.

## When To Use

- It owns startup, frame progression, host-window lifecycle, and guarded callback dispatch, so update, draw, input, and lifecycle hooks reach game code in a stable order instead of through scattered platform calls.
- Splash screens, error screens, and debug overlays belong here because they are part of the user-facing execution shell rather than any one gameplay feature.
- This central shell also makes recovery possible when startup, callback, or shutdown errors occur.

## Minimal Example

Example block: `lurek.engine.getVersion`

```lua
do
    local ver = lurek.engine.getVersion()
    local platform = lurek.engine.platform()
    local debug_build = lurek.engine.isDebug()
    local label = "Lurek " .. ver .. " on " .. platform
    lurek.log.info("engine build: " .. label)
    lurek.log.info("debug assertions enabled = " .. tostring(debug_build))
end
```

## Common Patterns

- Start with `lurek.engine.fps` when exploring this module.
- Start with `lurek.engine.frameCount` when exploring this module.
- Start with `lurek.engine.getConfigRevision` when exploring this module.
- Start with `lurek.engine.getFrameBudget` when exploring this module.
- Start with `lurek.engine.getFrameProfile` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `engine` module is the top-level runtime shell that turns the engine from a set of subsystems into one running desktop application.
- It owns startup, frame progression, host-window lifecycle, and guarded callback dispatch, so update, draw, input, and lifecycle hooks reach game code in a stable order instead of through scattered platform calls.
- Splash screens, error screens, and debug overlays belong here because they are part of the user-facing execution shell rather than any one gameplay feature.
- This central shell also makes recovery possible when startup, callback, or shutdown errors occur.
- It turns platform hosting into one stable application loop.
- Read this module as the final integration boundary where rendering, input, windowing, and Lua execution are coordinated into one recoverable runtime loop.

This module primarily collaborates with `event`, `filesystem`, `image`, `input`, `light`, `lua_api`, `math`, `parallax`, and adjacent engine modules. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.engine.fps`

Returns the latest frames-per-second value stored by the runtime.

```lua
lurek.engine.fps()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current FPS estimate. |

**Example**

```lua
do
    local f = lurek.engine.fps()
    local budget_ms = lurek.engine.getFrameBudget()
    local target_fps = 1000 / budget_ms
    local frame_time_ms = f > 0 and (1000 / f) or 0
    lurek.log.info("fps = " .. string.format("%.2f", f) .. " target=" .. string.format("%.2f", target_fps))
    lurek.log.info("estimated frame time = " .. string.format("%.2f", frame_time_ms) .. " ms")
end
```

---

### `lurek.engine.frameCount`

Returns the number of frames counted by the shared runtime clock.

```lua
lurek.engine.frameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total frame count. |

**Example**

```lua
do
    local n = lurek.engine.frameCount()
    local uptime = lurek.engine.uptime()
    local avg_fps = uptime > 0 and (n / uptime) or 0
    local sample_window = n > 120 and "warmed-up" or "startup"
    lurek.log.info("frame count = " .. n .. " (" .. sample_window .. ")")
    lurek.log.info("average fps since boot = " .. string.format("%.2f", avg_fps))
end
```

---

### `lurek.engine.getConfigRevision`

Returns the configuration reload revision counter.

```lua
lurek.engine.getConfigRevision()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Revision value incremented when runtime config reloads. |

**Example**

```lua
do
    local rev = lurek.engine.getConfigRevision()
    local version = lurek.engine.getVersion()
    local platform = lurek.engine.platform()
    local config_tag = version .. "#cfg" .. rev
    lurek.log.info("config revision = " .. rev)
    lurek.log.info("diagnostic tag = " .. config_tag .. "@" .. platform)
end
```

---

### `lurek.engine.getFrameBudget`

Returns the target frame budget for a 60 FPS update loop.

```lua
lurek.engine.getFrameBudget()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Frame budget in milliseconds. |

**Example**

```lua
do
    local budget = lurek.engine.getFrameBudget()
    local target_fps = 1000 / budget
    local current_fps = lurek.engine.fps()
    local slack_ms = budget - (current_fps > 0 and (1000 / current_fps) or 0)
    lurek.log.info("frame budget = " .. string.format("%.2f", budget) .. " ms")
    lurek.log.info("target fps = " .. string.format("%.2f", target_fps) .. ", slack = " .. string.format("%.2f", slack_ms) .. " ms")
end
```

---

### `lurek.engine.getFrameProfile`

Returns the latest frame timing profile split by engine phase.

```lua
lurek.engine.getFrameProfile()
```

**Returns**

| Type | Description |
|------|-------------|
| LEngineGetFrameProfileResult | Table of frame phase timings in milliseconds. |

**Example**

```lua
do
    local prof = lurek.engine.getFrameProfile()
    local script_ms = prof.process_ms + prof.process_late_ms + prof.callback_total_ms
    local render_ms = prof.draw_ms + prof.draw_ui_ms
    local core_ms = prof.app_tick_ms + prof.app_update_ms + prof.app_render_ms
    lurek.log.info("frame total = " .. string.format("%.3f", prof.app_frame_total_ms) .. " ms")
    lurek.log.info("core=" .. string.format("%.3f", core_ms) .. " script=" .. string.format("%.3f", script_ms) .. " render=" .. string.format("%.3f", render_ms))
end
```

---

### `lurek.engine.getFrameProfileText`

Returns the latest frame timing profile formatted as one text line.

```lua
lurek.engine.getFrameProfileText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Human-readable frame profile summary. |

**Example**

```lua
do
    local txt = lurek.engine.getFrameProfileText()
    local profile = lurek.engine.getFrameProfile()
    local has_draw_data = profile.draw_ms >= 0 and profile.draw_ui_ms >= 0
    local line_count = select(2, txt:gsub("\n", "\n")) + 1
    lurek.log.info("profile summary: " .. txt)
    lurek.log.info("text lines = " .. line_count .. ", draw data present = " .. tostring(has_draw_data))
end
```

---

### `lurek.engine.getResourceStats`

Returns current resource memory usage and object counts by resource kind.

```lua
lurek.engine.getResourceStats()
```

**Returns**

| Type | Description |
|------|-------------|
| LEngineGetResourceStatsResult | Table with byte totals, budget, and texture/font/canvas/shader counts. |

**Example**

```lua
do
    local stats = lurek.engine.getResourceStats()
    local usage_pct = stats.budget_bytes > 0 and (stats.total_bytes / stats.budget_bytes) * 100 or 0
    local gpu_objects = stats.texture_count + stats.shader_count + stats.font_count + stats.canvas_count
    local texture_bytes = string.format("%.2f", stats.texture_bytes / 1024)
    lurek.log.info("resource usage = " .. string.format("%.1f", usage_pct) .. "% of budget")
    lurek.log.info("gpu objects = " .. gpu_objects .. ", texture KB = " .. texture_bytes)
end
```

---

### `lurek.engine.getVersion`

Returns the engine crate version string embedded at build time.

```lua
lurek.engine.getVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Engine version from Cargo package metadata. |

**Example**

```lua
do
    local ver = lurek.engine.getVersion()
    local platform = lurek.engine.platform()
    local debug_build = lurek.engine.isDebug()
    local label = "Lurek " .. ver .. " on " .. platform
    lurek.log.info("engine build: " .. label)
    lurek.log.info("debug assertions enabled = " .. tostring(debug_build))
end
```

---

### `lurek.engine.isDebug`

Returns whether the engine binary was built with debug assertions.

```lua
lurek.engine.isDebug()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for debug builds, false for release builds. |

**Example**

```lua
do
    local dbg = lurek.engine.isDebug()
    local version = lurek.engine.getVersion()
    local platform = lurek.engine.platform()
    local build_type = dbg and "debug" or "release"
    lurek.log.info("build channel = " .. build_type)
    lurek.log.info("binary " .. version .. " running on " .. platform)
end
```

---

### `lurek.engine.memoryUsage`

Returns Lua VM memory usage as bytes and rounded kilobytes.

```lua
lurek.engine.memoryUsage()
```

**Returns**

| Type | Description |
|------|-------------|
| LEngineMemoryUsageResult | Table with `lua_bytes` and `lua_kb` fields. |

**Example**

```lua
do
    local mem = lurek.engine.memoryUsage()
    local lua_mb = mem.lua_bytes / (1024 * 1024)
    local frame = lurek.engine.frameCount()
    local budget_note = mem.lua_kb > 1024 and "heavy scene" or "light scene"
    lurek.log.info("lua memory = " .. string.format("%.2f", lua_mb) .. " MB at frame " .. frame)
    lurek.log.info("memory note = " .. budget_note)
end
```

---

### `lurek.engine.platform`

Returns the current desktop operating system name.

```lua
lurek.engine.platform()
```

**Returns**

| Type | Description |
|------|-------------|
| string | `windows`, `linux`, `macos`, or `unknown`. |

**Example**

```lua
do
    local os_name = lurek.engine.platform()
    local version = lurek.engine.getVersion()
    local debug_build = lurek.engine.isDebug()
    local runtime_tag = os_name .. " / " .. version
    lurek.log.info("runtime target = " .. runtime_tag)
    lurek.log.info("debug build = " .. tostring(debug_build))
end
```

---

### `lurek.engine.setResourceBudget`

Sets the resource memory budget used by resource statistics reporting.

```lua
lurek.engine.setResourceBudget(budget_bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `budget_bytes` | number | Resource budget in bytes. |

**Example**

```lua
do
    local previous = lurek.engine.getResourceStats().budget_bytes
    local new_budget = 64 * 1024 * 1024
    lurek.engine.setResourceBudget(new_budget)
    local updated = lurek.engine.getResourceStats()
    lurek.engine.setResourceBudget(previous)
    lurek.log.info("resource budget changed to " .. updated.budget_bytes .. " bytes")
    lurek.log.info("restored previous budget = " .. previous)
end
```

---

### `lurek.engine.uptime`

Returns total engine runtime accumulated by the main loop.

```lua
lurek.engine.uptime()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Uptime in seconds. |

**Example**

```lua
do
    local t = lurek.engine.uptime()
    local frames = lurek.engine.frameCount()
    local per_frame = frames > 0 and (t / frames) or 0
    local started_recently = t < 5
    lurek.log.info("uptime = " .. string.format("%.3f", t) .. " s")
    lurek.log.info("seconds per frame = " .. string.format("%.5f", per_frame) .. ", startup=" .. tostring(started_recently))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
