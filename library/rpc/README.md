# rpc

A Remote Procedure Call layer over `lurek.network`. Registers named handlers, sends typed call/notify messages with optional timeouts, and polls for responses. Supports broadcast to all peers and request-response round-trips with error callbacks.

## Usage

```lua
local rpc = require("library/rpc")

local r = rpc.RPC.new({ peer_id = my_id })

-- Server side: register handler
r:register("attack", function(params, from_peer)
    apply_damage(params.target_id, params.damage)
    return { ok = true }
end)

-- Client side: call with callback
r:call("attack", { target_id = 5, damage = 30 }, peer_host,
    function(result) print("Hit landed:", result.ok) end,
    { timeout = 2.0 })

function lurek.update(dt)
    r:poll(dt)
end
```

## Dependencies

- `lurek.network` (optional), `lurek.serial.toJson/fromJson` (optional)
