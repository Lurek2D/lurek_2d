# Debugbridge

## Purpose

Connects the game runtime to external editor panels.

## When To Use

- It owns the bridge state, network protocol, queued requests and responses, print-history streaming, and guarded remote operations such as screenshots or hot reload requests.
- Read it as the integration boundary for external observability: gameplay systems do not need to know editor protocols, because debugbridge translates between runtime state and tool clients.

## Minimal Example

Example block: `lurek.debugbridge.start`

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    local port = start_bridge()
    local running = lurek.debugbridge.isRunning()
    local active_port = lurek.debugbridge.getPort()
    bridge_log("start running=" .. tostring(running) .. " requested_port=" .. tostring(port) .. " active_port=" .. tostring(active_port))
    stop_bridge_if_running()
end
```

## Common Patterns

- Start with `lurek.debugbridge.broadcast` when exploring this module.
- Start with `lurek.debugbridge.capturePrint` when exploring this module.
- Start with `lurek.debugbridge.clearPrintHistory` when exploring this module.
- Start with `lurek.debugbridge.consumeHotReloadRequest` when exploring this module.
- Start with `lurek.debugbridge.getClientCount` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `debugbridge` module is the remote inspection channel between a running game and external development tools such as the VS Code extension or MCP-style clients.
- It owns the bridge state, network protocol, queued requests and responses, print-history streaming, and guarded remote operations such as screenshots or hot reload requests.
- Read it as the integration boundary for external observability: gameplay systems do not need to know editor protocols, because `debugbridge` translates between runtime state and tool clients.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.debugbridge.broadcast`

Queues a JSON string payload broadcast for debug bridge clients.

```lua
lurek.debugbridge.broadcast(event, json_data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event` | string | Event name sent to clients. |
| `json_data` | string | Payload string wrapped as JSON for clients. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    stop_bridge_if_running()
    local port = start_bridge()
    lurek.debugbridge.broadcast("quest:update", '{"quest":"intro","state":"ready"}')
    local protocol = lurek.debugbridge.getProtocolInfo()
    bridge_log("broadcast port=" .. tostring(port) .. " capabilities=" .. #protocol.capabilities .. " clients=" .. lurek.debugbridge.getClientCount())
    stop_bridge_if_running()
end
```

---

### `lurek.debugbridge.capturePrint`

Captures a print message and broadcasts it to debug bridge clients.

```lua
lurek.debugbridge.capturePrint(msg, source, line)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `msg` | string | Printed message text. |
| `source?` | string | Source label; defaults to `?`. |
| `line?` | number | Source line; defaults to zero. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    reset_print_history()
    lurek.debugbridge.capturePrint("quest accepted", "quests.lua", 42)
    local history = lurek.debugbridge.getPrintHistory(1)
    local last = history[1]
    bridge_log("capturePrint size=" .. #history .. " msg=" .. tostring(last and last.message) .. " source=" .. tostring(last and last.source))
end
```

---

### `lurek.debugbridge.clearPrintHistory`

Clears all entries from the captured print history buffer.

```lua
lurek.debugbridge.clearPrintHistory()
```

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    reset_print_history()
    lurek.debugbridge.capturePrint("before clear", "main.lua", 10)
    local before = #lurek.debugbridge.getPrintHistory()
    lurek.debugbridge.clearPrintHistory()
    local after = #lurek.debugbridge.getPrintHistory()
    bridge_log("clearPrintHistory before=" .. before .. " after=" .. after)
end
```

---

### `lurek.debugbridge.consumeHotReloadRequest`

Returns and clears the pending hot reload request flag.

```lua
lurek.debugbridge.consumeHotReloadRequest()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a hot reload request was pending. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    local first = lurek.debugbridge.consumeHotReloadRequest()
    local second = lurek.debugbridge.consumeHotReloadRequest()
    local info = lurek.debugbridge.getProtocolInfo()
    local running = lurek.debugbridge.isRunning()
    bridge_log("consumeHotReloadRequest first=" .. tostring(first) .. " second=" .. tostring(second) .. " protocol=" .. tostring(info.version) .. " running=" .. tostring(running))
end
```

---

### `lurek.debugbridge.getClientCount`

Returns the number of connected debug bridge clients.

```lua
lurek.debugbridge.getClientCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Connected client count. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    stop_bridge_if_running()
    local before = lurek.debugbridge.getClientCount()
    local port = start_bridge()
    local after = lurek.debugbridge.getClientCount()
    bridge_log("getClientCount before=" .. tostring(before) .. " after_start=" .. tostring(after) .. " port=" .. tostring(port))
    stop_bridge_if_running()
end
```

---

### `lurek.debugbridge.getPerformance`

Returns debug bridge performance metrics.

```lua
lurek.debugbridge.getPerformance()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table of numeric performance metrics. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    lurek.debugbridge.poll()
    local perf = lurek.debugbridge.getPerformance()
    local fps = perf.fps or "n/a"
    local avg_dt = perf.avgDt or perf.avg_dt or perf.avg_frame_ms or "n/a"
    local frame_count = perf.frameCount or perf.frames or "n/a"
    bridge_log("getPerformance fps=" .. tostring(fps) .. " avg=" .. tostring(avg_dt) .. " frames=" .. tostring(frame_count))
end
```

---

### `lurek.debugbridge.getPort`

Returns the configured TCP port for the debug bridge.

```lua
lurek.debugbridge.getPort()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Active or configured port, or zero when unavailable. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    stop_bridge_if_running()
    local idle_port = lurek.debugbridge.getPort()
    local port = start_bridge()
    local active_port = lurek.debugbridge.getPort()
    bridge_log("getPort idle=" .. tostring(idle_port) .. " started=" .. tostring(port) .. " active=" .. tostring(active_port))
    stop_bridge_if_running()
end
```

---

### `lurek.debugbridge.getPrintHistory`

Returns captured print history entries.

```lua
lurek.debugbridge.getPrintHistory(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | number | Number of newest entries; nil or zero returns all entries. |

**Returns**

| Type | Description |
|------|-------------|
| LDebugbridgeGetPrintHistoryResult | Array table of entries with `timestamp`, `message`, `source`, and `line` fields. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    reset_print_history()
    for i = 1, 4 do
        lurek.debugbridge.capturePrint("frame " .. i, "hud.lua", i)
    end
    local last_two = lurek.debugbridge.getPrintHistory(2)
    local first = last_two[1]
    local second = last_two[2]
    bridge_log("getPrintHistory size=" .. #last_two .. " first=" .. tostring(first and first.message) .. " second=" .. tostring(second and second.message))
end
```

---

### `lurek.debugbridge.getProtocolInfo`

Returns debug bridge protocol version, capabilities, and handshake nonce.

```lua
lurek.debugbridge.getProtocolInfo()
```

**Returns**

| Type | Description |
|------|-------------|
| LDebugbridgeGetProtocolInfoResult | Protocol info table with `version`, `capabilities`, and `nonce` fields. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    local info = lurek.debugbridge.getProtocolInfo()
    local version = info.version
    local nonce = info.nonce
    local capabilities = info.capabilities
    bridge_log("getProtocolInfo version=" .. tostring(version) .. " nonce=" .. tostring(nonce) .. " capability_count=" .. #capabilities)
end
```

---

### `lurek.debugbridge.isRunning`

Returns whether the debug bridge server is currently running.

```lua
lurek.debugbridge.isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the server thread is active. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    stop_bridge_if_running()
    local before = lurek.debugbridge.isRunning()
    local port = start_bridge()
    local after = lurek.debugbridge.isRunning()
    bridge_log("isRunning before=" .. tostring(before) .. " after_start=" .. tostring(after) .. " port=" .. tostring(port))
    stop_bridge_if_running()
end
```

---

### `lurek.debugbridge.isScreenshotRequested`

Returns whether a screenshot request is pending.

```lua
lurek.debugbridge.isScreenshotRequested()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a screenshot request is pending. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    local before = lurek.debugbridge.isScreenshotRequested()
    lurek.debugbridge.requestScreenshot()
    local after = lurek.debugbridge.isScreenshotRequested()
    local clients = lurek.debugbridge.getClientCount()
    bridge_log("isScreenshotRequested before=" .. tostring(before) .. " after=" .. tostring(after) .. " clients=" .. tostring(clients))
end
```

---

### `lurek.debugbridge.poll`

Polls pending debugger requests, evaluates supported methods, and queues responses.

```lua
lurek.debugbridge.poll()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No return value. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    stop_bridge_if_running()
    lurek.debugbridge.poll()
    local port = start_bridge()
    lurek.debugbridge.poll()
    local running = lurek.debugbridge.isRunning()
    bridge_log("poll running=" .. tostring(running) .. " port=" .. tostring(port) .. " clients=" .. lurek.debugbridge.getClientCount())
    stop_bridge_if_running()
end
```

---

### `lurek.debugbridge.requestScreenshot`

Requests a screenshot from the runtime.

```lua
lurek.debugbridge.requestScreenshot(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale?` | number | Screenshot scale clamped from 1 to 8; defaults to 1. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    local before = lurek.debugbridge.isScreenshotRequested()
    lurek.debugbridge.requestScreenshot(2)
    local after = lurek.debugbridge.isScreenshotRequested()
    local protocol = lurek.debugbridge.getProtocolInfo()
    bridge_log("requestScreenshot before=" .. tostring(before) .. " after=" .. tostring(after) .. " protocol=" .. tostring(protocol.version))
end
```

---

### `lurek.debugbridge.setMaxPrintHistory`

Sets the maximum retained print history entry count.

```lua
lurek.debugbridge.setMaxPrintHistory(max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max` | number | Maximum retained print entries. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    reset_print_history()
    lurek.debugbridge.setMaxPrintHistory(3)
    for i = 1, 5 do
        lurek.debugbridge.capturePrint("msg " .. i, "debug.lua", i)
    end
    local history = lurek.debugbridge.getPrintHistory()
    bridge_log("setMaxPrintHistory kept=" .. #history .. " first=" .. tostring(history[1] and history[1].message))
    lurek.debugbridge.setMaxPrintHistory(2000)
end
```

---

### `lurek.debugbridge.start`

Starts the localhost debug bridge server on a port.

```lua
lurek.debugbridge.start(port)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `port?` | number | TCP port to bind on `127.0.0.1`; defaults to 19740 and must be at least 1024. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the server was started, false when it was already running. |

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    local port = start_bridge()
    local running = lurek.debugbridge.isRunning()
    local active_port = lurek.debugbridge.getPort()
    bridge_log("start running=" .. tostring(running) .. " requested_port=" .. tostring(port) .. " active_port=" .. tostring(active_port))
    stop_bridge_if_running()
end
```

---

### `lurek.debugbridge.stop`

Stops the debug bridge server and joins its server thread.

```lua
lurek.debugbridge.stop()
```

**Example**

```lua
do
    local function bridge_log(message)
        lurek.log.info("[debugbridge] " .. message)
    end
    local function stop_bridge_if_running()
        if lurek.debugbridge.isRunning() then
            lurek.debugbridge.stop()
        end
    end
    local function start_bridge()
        stop_bridge_if_running()
        for port = 49740, 49840 do
            if lurek.debugbridge.start(port) then
                return port
            end
        end
        return nil
    end
    local function reset_print_history()
        lurek.debugbridge.clearPrintHistory()
        lurek.debugbridge.setMaxPrintHistory(2000)
    end

    local port = start_bridge()
    local before = lurek.debugbridge.isRunning()
    lurek.debugbridge.stop()
    local after = lurek.debugbridge.isRunning()
    bridge_log("stop port=" .. tostring(port) .. " before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
