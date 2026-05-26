# lobby

A multiplayer lobby with room creation, join, ready-state tracking, and host election. Works over `lurek.network` messages; provides a clean state machine so game code only reacts to lobby events.

## Usage

```lua
local lobby = require("library/lobby")

local lb = lobby.Lobby.new({ max_rooms = 10 })
local room = lb:createRoom({ name = "My Game", max_players = 4, host = my_peer_id })

room:join(peer_id)
room:setReady(peer_id, true)

lb:on("all_ready", function(r)
    startGame(r)
end)

function lurek.update(dt)
    lb:poll()  -- processes incoming network messages
end
```

## Dependencies

- `lurek.network` (optional), `lurek.patterns.newEventBus` (optional)
