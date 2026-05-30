# Debugbridge

## Summary

The `debugbridge` module provides runtime-to-tool communication primitives for debugging workflows, centered on shared bridge state and server-side JSON-RPC style message handling. Its purpose is integration: shuttle requests/responses and debug prints between engine runtime and external tooling while preserving thread-safe queue semantics.

`bridge.rs` owns shared data structures (`BridgeShared`, pending request/response buffers, print entries), and `server.rs` owns client message handling plus server-thread lifecycle. The module then re-exports these integration types/functions for runtime layers that start and drive the bridge.

This module should stay transport-focused. It is not a replacement for gameplay introspection logic; it is the conduit that carries those operations between processes.

Operationally, quality depends on predictable queue behavior, clear message contracts, and failure-safe networking boundaries so debug tooling cannot silently corrupt runtime state.

Implementation detail and boundary guarantees for debugbridge: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: bridge.rs: Define shared state and queue structures for the debug bridge protocol.; mod.rs: Expose the debug bridge subsystem for runtime-to-IDE communication.; server.rs: Run a non-blocking TCP server loop accepting debug bridge client connections.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

### bridge.rs

- Implements shared state and queue structures for runtime-to-client debug bridge communication.
- Stores pending requests and responses exchanged between network server and runtime logic.
- Tracks rolling performance metrics and bounded print history for debugger-side inspection.
- Maintains session configuration and capability metadata used across active bridge connections.
- Provides broadcast event queues for fan-out delivery to all connected debug clients.
- Serves as the core synchronization layer under the debug bridge protocol subsystem.

### mod.rs

- Defines the debugbridge module boundary for runtime-to-IDE transport and state exchange.
- Groups shared bridge state and TCP server functionality under one integration surface.
- Serves as the composition entry for engine-side debugbridge capabilities.

### server.rs

- Implements the non-blocking TCP server loop for debugbridge client connectivity and dispatch.
- Accepts client sessions and parses JSON-RPC messages into runtime and built-in command handlers.
- Delivers queued responses and broadcast events across connected debugger endpoints.
- Handles handshake, protocol version checks, and nonce-based authentication workflows.
- Supports eval, ping, performance, print-history, and screenshot-oriented protocol requests.
- Serves as the network transport execution layer for the debugbridge subsystem.
- Preserves deterministic request lifecycle behavior across concurrent debugger client sessions.

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
  lurek.debugbridge.broadcast("game_event", '{"score":100}')
  print("broadcast sent")
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
  lurek.debugbridge.capturePrint("Hello from game", "main.lua", 42)
  local history = lurek.debugbridge.getPrintHistory(1)
  print("message captured = " .. tostring(#history == 1))
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
lurek.debugbridge.consumeHotReloadRequest()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a hot reload request was pending. |

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
lurek.debugbridge.getClientCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Connected client count. |

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
lurek.debugbridge.getPerformance()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table of numeric performance metrics. |

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
lurek.debugbridge.getPort()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Active or configured port, or zero when unavailable. |

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
lurek.debugbridge.getProtocolInfo()
```

**Returns**

| Type | Description |
|------|-------------|
| LDebugbridgeGetProtocolInfoResult | Protocol info table with `version`, `capabilities`, and `nonce` fields. |

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
lurek.debugbridge.isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the server thread is active. |

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
lurek.debugbridge.isScreenshotRequested()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a screenshot request is pending. |

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
lurek.debugbridge.poll()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No return value. |

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
lurek.debugbridge.requestScreenshot(scale)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scale?` | number | Screenshot scale clamped from 1 to 8; defaults to 1. |

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
lurek.debugbridge.setMaxPrintHistory(max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max` | number | Maximum retained print entries. |

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

## Module Fields

*No module-level fields documented.*

## Types

*No Lua userdata types detected for this module.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*
