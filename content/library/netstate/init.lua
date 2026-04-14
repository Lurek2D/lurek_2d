--- @module library.netstate
--- @description Pure-Lua network state synchronization and turn-based game support.
--- Built on lurek.network, provides automatic state replication between peers
--- with change callbacks, authority control, and turn management.
local M = {}

---------------------------------------------------------------------------
-- NetState Manager
---------------------------------------------------------------------------

local NetState = {}
NetState.__index = NetState

--- Create a new network state synchronization manager.
--- @tparam userdata host  A `lurek.network.newHost/newServer/newClient` host.
--- @tparam[opt] table opts  `{ channel, authority, turnBased }`.
--- @treturn NetState
function M.new(host, opts)
    local self  = setmetatable({}, NetState)
    self._host        = host
    self._channel     = (opts and opts.channel) or 0
    self._authority    = (opts and opts.authority) or host:isServer()
    self._state        = {}     -- { key = { value, version, owner } }
    self._callbacks    = {}     -- { key = { fn, ... } }
    self._version      = 0
    self._dirty        = {}     -- keys changed since last sync
    self._on_change    = nil    -- global change callback

    -- Turn-based support
    self._turn_based   = (opts and opts.turnBased) or false
    self._current_turn = 0
    self._turn_peer    = nil
    self._turn_order   = {}     -- { peer_id, peer_id, ... }
    self._turn_index   = 1
    self._on_turn      = nil

    return self
end

--- Set whether this instance is the authority (can write state).
--- @tparam boolean auth
function NetState:setAuthority(auth)
    self._authority = auth
end

--- Check if this instance is the authority.
--- @treturn boolean
function NetState:isAuthority()
    return self._authority
end

--- Set a global change callback fired for any key change.
--- @tparam function fn  `fn(key, value, old_value, peer_id)`
function NetState:onChange(fn)
    self._on_change = fn
end

-- -----------------------------------------------------------------------
-- State access
-- -----------------------------------------------------------------------

--- Set a synced value. Only the authority can set values.
--- @tparam string key
--- @param value  Any MessagePack-serializable value.
--- @treturn boolean success
function NetState:set(key, value)
    if not self._authority then
        return false
    end
    local entry = self._state[key]
    local old_value = entry and entry.value or nil
    self._version = self._version + 1
    self._state[key] = {
        value   = value,
        version = self._version,
        owner   = 0,  -- local authority
    }
    self._dirty[key] = true

    -- Fire callbacks
    self:_fireCallbacks(key, value, old_value, 0)
    return true
end

--- Get the current value of a synced key.
--- @tparam string key
--- @return any|nil  The value, or nil if not set.
function NetState:get(key)
    local entry = self._state[key]
    return entry and entry.value or nil
end

--- Get all synced state as a flat table.
--- @treturn table  `{ key = value, ... }`
function NetState:getAll()
    local t = {}
    for key, entry in pairs(self._state) do
        t[key] = entry.value
    end
    return t
end

--- Register a callback for changes to a specific key.
--- @tparam string key
--- @tparam function fn  `fn(value, old_value, peer_id)`
function NetState:onChanged(key, fn)
    if not self._callbacks[key] then
        self._callbacks[key] = {}
    end
    table.insert(self._callbacks[key], fn)
end

--- Remove all callbacks for a key.
--- @tparam string key
function NetState:clearCallbacks(key)
    self._callbacks[key] = nil
end

--- Get the version number of the state (increments with each set).
--- @treturn number
function NetState:getVersion()
    return self._version
end

--- Get the number of synced keys.
--- @treturn number
function NetState:getKeyCount()
    local n = 0
    for _ in pairs(self._state) do n = n + 1 end
    return n
end

-- -----------------------------------------------------------------------
-- Turn-based support
-- -----------------------------------------------------------------------

--- Set the turn order (array of peer IDs).
--- @tparam table order  `{ peer_id_1, peer_id_2, ... }`
function NetState:setTurnOrder(order)
    self._turn_order = order
    self._turn_index = 1
    self._current_turn = 0
end

--- Begin a new turn. Advances to the next player in the turn order.
--- Only the authority should call this.
--- @treturn number  The new turn number.
--- @treturn number|nil  The peer whose turn it is.
function NetState:beginTurn()
    if not self._authority then return self._current_turn, self._turn_peer end

    self._current_turn = self._current_turn + 1
    if #self._turn_order > 0 then
        self._turn_peer = self._turn_order[self._turn_index]
        self._turn_index = self._turn_index + 1
        if self._turn_index > #self._turn_order then
            self._turn_index = 1
        end
    end

    -- Broadcast turn change
    self:_broadcastTurn()

    if self._on_turn then
        self._on_turn(self._current_turn, self._turn_peer)
    end

    return self._current_turn, self._turn_peer
end

--- End the current turn. Alias for `beginTurn()` — advances to next.
--- @treturn number turn_number
--- @treturn number|nil turn_peer
function NetState:endTurn()
    return self:beginTurn()
end

--- Get the current turn number.
--- @treturn number
function NetState:getCurrentTurn()
    return self._current_turn
end

--- Get the peer ID whose turn it currently is.
--- @treturn number|nil
function NetState:getTurnPeer()
    return self._turn_peer
end

--- Register a callback for turn changes.
--- @tparam function fn  `fn(turn_number, peer_id)`
function NetState:onTurn(fn)
    self._on_turn = fn
end

--- Check if it is a specific peer's turn.
--- @tparam number peer_id
--- @treturn boolean
function NetState:isTurn(peer_id)
    return self._turn_peer == peer_id
end

-- -----------------------------------------------------------------------
-- Sync: call once per frame
-- -----------------------------------------------------------------------

--- Broadcast all dirty state to connected peers.
--- Call once per frame after all `set()` calls (e.g. at end of `lurek.process(dt)`).
function NetState:sync()
    if not self._authority then return end

    local dirty_count = 0
    for _ in pairs(self._dirty) do dirty_count = dirty_count + 1 end
    if dirty_count == 0 then return end

    -- Build delta update
    local delta = {}
    for key in pairs(self._dirty) do
        local entry = self._state[key]
        delta[key] = { value = entry.value, version = entry.version }
    end

    local msg = lurek.network.pack({
        type  = "netstate",
        action = "delta",
        delta = delta,
    })
    self._host:broadcast(self._channel, msg, true)

    self._dirty = {}
end

--- Process incoming state updates from the network. Call once per frame.
--- @treturn table  Array of `{ key, value, old_value, peer_id }` change events.
function NetState:poll()
    local changes = {}
    local ev = self._host:service()
    while ev do
        if ev.type == "receive" then
            local ok, data = pcall(lurek.network.unpack, ev.data)
            if ok and type(data) == "table" and data.type == "netstate" then
                self:_handle(ev.peer, data, changes)
            end
        end
        ev = self._host:service()
    end
    return changes
end

-- -----------------------------------------------------------------------
-- Internals
-- -----------------------------------------------------------------------

function NetState:_handle(peer_id, data, changes)
    if data.action == "delta" and not self._authority then
        -- Apply delta from authority
        for key, entry in pairs(data.delta or {}) do
            local old = self._state[key]
            local old_value = old and old.value or nil
            local old_version = old and old.version or 0
            if entry.version > old_version then
                self._state[key] = {
                    value   = entry.value,
                    version = entry.version,
                    owner   = peer_id,
                }
                self:_fireCallbacks(key, entry.value, old_value, peer_id)
                table.insert(changes, {
                    key       = key,
                    value     = entry.value,
                    old_value = old_value,
                    peer_id   = peer_id,
                })
            end
        end
    elseif data.action == "full_request" and self._authority then
        -- Peer requested full state snapshot
        self:_sendFullState(peer_id)
    elseif data.action == "full" and not self._authority then
        -- Received full state snapshot
        for key, entry in pairs(data.state or {}) do
            local old = self._state[key]
            local old_value = old and old.value or nil
            self._state[key] = {
                value   = entry.value,
                version = entry.version,
                owner   = peer_id,
            }
            self:_fireCallbacks(key, entry.value, old_value, peer_id)
        end
        self._version = data.version or 0
    elseif data.action == "turn" then
        self._current_turn = data.turn or 0
        self._turn_peer    = data.peer
        if self._on_turn then
            self._on_turn(self._current_turn, self._turn_peer)
        end
    end
end

function NetState:_sendFullState(peer_id)
    local state = {}
    for key, entry in pairs(self._state) do
        state[key] = { value = entry.value, version = entry.version }
    end
    local msg = lurek.network.pack({
        type    = "netstate",
        action  = "full",
        state   = state,
        version = self._version,
    })
    self._host:send(peer_id, self._channel, msg, true)
end

function NetState:_broadcastTurn()
    local msg = lurek.network.pack({
        type   = "netstate",
        action = "turn",
        turn   = self._current_turn,
        peer   = self._turn_peer,
    })
    self._host:broadcast(self._channel, msg, true)
end

function NetState:_fireCallbacks(key, value, old_value, peer_id)
    -- Key-specific callbacks
    local cbs = self._callbacks[key]
    if cbs then
        for _, fn in ipairs(cbs) do
            fn(value, old_value, peer_id)
        end
    end
    -- Global callback
    if self._on_change then
        self._on_change(key, value, old_value, peer_id)
    end
end

--- Request a full state snapshot from the authority.
--- Useful when a client joins mid-game.
function NetState:requestFullState()
    if self._authority then return end
    local msg = lurek.network.pack({
        type   = "netstate",
        action = "full_request",
    })
    self._host:broadcast(self._channel, msg, true)
end

return M
