# netstate

A network state replication layer with per-key versioning and authority control. Tracks which peer owns each state key, detects conflicts, and resolves them via a configurable authority policy. Designed for turn-based and slow-paced real-time games.

## Usage

```lua
local netstate = require("library/netstate")

local ns = netstate.NetState.new({ authority = "host", peer_id = my_id })

-- Set and sync local state
ns:set("player_pos", { x = 100, y = 200 })
ns:sync()   -- sends dirty keys over lurek.network

-- Process incoming messages
function lurek.update(dt)
    ns:poll(dt)
end

-- Read any peer's state
local pos = ns:get("player_pos", other_peer_id)
```

## Dependencies

- `lurek.network` (optional), `lurek.serial.toJson` (optional)
