# Debugbridge

- The `debugbridge` module provides a powerful TCP-based communication layer that enables external tools—such as the VS Code extension, remote inspectors, and diagnostic dashboards—to connect directly to a running Lurek2D instance.

Situated within the Edge/Integration tier, the bridge operates primarily over a lightweight JSON-RPC protocol. It accepts requests for real-time engine interactions, including breakpoint management, variable inspection, expression evaluation, screenshot capture, and print history retrieval. By design, the module is disabled by default in release builds for security and performance reasons, activating only when explicitly started from Lua via `lurek.debugbridge.start()`.

At the architectural core of the module is `BridgeShared`, a synchronized state container wrapped in an `Arc<Mutex<>>`. This structure safely brokers data between the main game thread and the dedicated background TCP I/O thread. It holds pending request and response queues, frame-time performance metrics with bounded sampling windows, and a broadcast queue for event delivery to all connected clients. One of its key features is print capture: it intercepts `lurek.log` and standard Lua `print` output, storing it in a bounded ring buffer so that external editors can natively display runtime textual output without needing to scrape the system's stdout.

The server loop manages non-blocking TCP connections, executing protocol handshakes, nonce authentication, and version negotiations to ensure secure tooling connections. It handles background-safe JSON-RPC messages immediately, while queuing game-state-dependent operations as `PendingRequest` records for the main thread to poll via `lurek.debugbridge.poll()`. The Lua API fully exposes these capabilities, allowing script developers to programmatically trigger broadcasts, request screenshots, track connected client counts, and consume hot-reload requests dynamically.

## Functions

### `lurek.debugbridge.broadcast`

Queues a JSON string payload broadcast for debug bridge clients.

```lua
-- signature
lurek.debugbridge.broadcast(event, json_data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event` | `string` | Event name sent to clients. |
| `json_data` | `string` | Payload string wrapped as JSON for clients. |

**Example**

```lua
do
  lurek.debugbridge.broadcast("game_event", '{"score":100}')
  print("broadcast sent")
end
```

---

### `lurek.debugbridge.capturePrint`

Captures a print message and broadcasts it to debug bridge clients.

```lua
-- signature
lurek.debugbridge.capturePrint(msg, source, line)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `msg` | `string` | Printed message text. |
| `source?` | `string` | Source label; defaults to `?`. |
| `line?` | `number` | Source line; defaults to zero. |

**Example**

```lua
do
  lurek.debugbridge.capturePrint("Hello from game", "main.lua", 42)
  local history = lurek.debugbridge.getPrintHistory(1)
  print("message captured = " .. tostring(#history == 1))
end
```

---

### `lurek.debugbridge.clearPrintHistory`

Clears all entries from the captured print history buffer.

```lua
-- signature
lurek.debugbridge.clearPrintHistory()
```

**Example**

```lua
do
  lurek.debugbridge.capturePrint("will be cleared", "x", 1)
  lurek.debugbridge.clearPrintHistory()
  local history = lurek.debugbridge.getPrintHistory()
  print("after clear = " .. tostring(#history))
end
```

---

### `lurek.debugbridge.consumeHotReloadRequest`

Returns and clears the pending hot reload request flag.

```lua
-- signature
lurek.debugbridge.consumeHotReloadRequest()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a hot reload request was pending. |

**Example**

```lua
do
  local had_request = lurek.debugbridge.consumeHotReloadRequest()
  print("hot reload pending = " .. tostring(had_request))
end
```

---

### `lurek.debugbridge.getClientCount`

Returns the number of connected debug bridge clients.

```lua
-- signature
lurek.debugbridge.getClientCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Connected client count. |

**Example**

```lua
do
  local clients = lurek.debugbridge.getClientCount()
  print("clients = " .. tostring(clients))
end
```

---

### `lurek.debugbridge.getPerformance`

Returns debug bridge performance metrics.

```lua
-- signature
lurek.debugbridge.getPerformance()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Table of numeric performance metrics. |

**Example**

```lua
do
  local perf = lurek.debugbridge.getPerformance()
  print("frame time avg = " .. tostring(perf.avg_dt or perf.avg_frame_ms or "n/a"))
  print("fps = " .. tostring(perf.fps or "n/a"))
end
```

---

### `lurek.debugbridge.getPort`

Returns the configured TCP port for the debug bridge.

```lua
-- signature
lurek.debugbridge.getPort()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Active or configured port, or zero when unavailable. |

**Example**

```lua
do
  local port = lurek.debugbridge.getPort()
  print("port = " .. tostring(port))
end
```

---

### `lurek.debugbridge.getPrintHistory`

Returns captured print history entries.

```lua
-- signature
lurek.debugbridge.getPrintHistory(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | `number` | Number of newest entries; nil or zero returns all entries. |

**Returns**

| Type | Description |
|------|-------------|
| `DebugbridgeGetPrintHistoryResult` | Array table of entries with `timestamp`, `message`, `source`, and `line` fields. |

**Example**

```lua
do
  lurek.debugbridge.capturePrint("test msg", "src", 1)
  local history = lurek.debugbridge.getPrintHistory(10)
  print("history entries = " .. tostring(#history))
  if #history > 0 then
    print("last message = " .. tostring(history[#history].message))
  end
end
```

---

### `lurek.debugbridge.getProtocolInfo`

Returns debug bridge protocol version, capabilities, and handshake nonce.

```lua
-- signature
lurek.debugbridge.getProtocolInfo()
```

**Returns**

| Type | Description |
|------|-------------|
| `DebugbridgeGetProtocolInfoResult` | Protocol info table with `version`, `capabilities`, and `nonce` fields. |

**Example**

```lua
do
  local info = lurek.debugbridge.getProtocolInfo()
  print("protocol version = " .. tostring(info.version))
  print("capability count = " .. tostring(#info.capabilities))
end
```

---

### `lurek.debugbridge.isRunning`

Returns whether the debug bridge server is currently running.

```lua
-- signature
lurek.debugbridge.isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the server thread is active. |

**Example**

```lua
do
  local running = lurek.debugbridge.isRunning()
  print("running = " .. tostring(running))
end
```

---

### `lurek.debugbridge.isScreenshotRequested`

Returns whether a screenshot request is pending.

```lua
-- signature
lurek.debugbridge.isScreenshotRequested()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a screenshot request is pending. |

**Example**

```lua
do
  lurek.debugbridge.requestScreenshot()
  local pending = lurek.debugbridge.isScreenshotRequested()
  print("pending = " .. tostring(pending))
end
```

---

### `lurek.debugbridge.poll`

Polls pending debugger requests, evaluates supported methods, and queues responses.

```lua
-- signature
lurek.debugbridge.poll()
```

**Returns**

| Type | Description |
|------|-------------|
| `nil` | No return value. |

**Example**

```lua
do
  lurek.debugbridge.poll()
  print("polled bridge requests")
end
```

---

### `lurek.debugbridge.requestScreenshot`

Requests a screenshot from the runtime.

```lua
-- signature
lurek.debugbridge.requestScreenshot(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale?` | `number` | Screenshot scale clamped from 1 to 8; defaults to 1. |

**Example**

```lua
do
  lurek.debugbridge.requestScreenshot(2)
  print("screenshot requested at 2x")
  print("pending = " .. tostring(lurek.debugbridge.isScreenshotRequested()))
end
```

---

### `lurek.debugbridge.setMaxPrintHistory`

Sets the maximum retained print history entry count.

```lua
-- signature
lurek.debugbridge.setMaxPrintHistory(max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max` | `number` | Maximum retained print entries. |

**Example**

```lua
do
  lurek.debugbridge.setMaxPrintHistory(100)
  lurek.debugbridge.capturePrint("history limit updated", "debugbridge.lua", 35)
  print("max print history set to 100")
end
```

---

### `lurek.debugbridge.start`

Starts the localhost debug bridge server on a port.

```lua
-- signature
lurek.debugbridge.start(port)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `port?` | `number` | TCP port to bind on `127.0.0.1`; defaults to 19740 and must be at least 1024. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the server was started, false when it was already running. |

**Example**

```lua
do
  local ok, started = pcall(function()
    return lurek.debugbridge.start(19740)
  end)
  print("start call ok = " .. tostring(ok))
  print("started = " .. tostring(ok and started))
end
```

---

### `lurek.debugbridge.stop`

Stops the debug bridge server and joins its server thread.

```lua
-- signature
lurek.debugbridge.stop()
```

**Example**

```lua
do
  local ok = pcall(function()
    lurek.debugbridge.stop()
  end)
  print("bridge stopped = " .. tostring(ok))
end
```

---
