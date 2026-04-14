--- @module library.lobby
--- @description Pure-Lua lobby and room management built on lurek.network.
--- Provides room creation, joining, player tracking, and ready-check
--- coordination for multiplayer pre-game lobbies.
local M = {}

---------------------------------------------------------------------------
-- Room (internal)
---------------------------------------------------------------------------

local Room = {}
Room.__index = Room

function Room._new(name, opts)
    local self = setmetatable({}, Room)
    self.name       = name
    self.max_players = (opts and opts.maxPlayers) or 8
    self.password    = (opts and opts.password) or nil
    self.data        = (opts and opts.data) or {}
    self.players     = {}   -- { peer_id = { name, ready, data } }
    self.host_peer   = nil  -- peer_id of the room host
    return self
end

function Room:addPlayer(peer_id, name, data)
    if self:getPlayerCount() >= self.max_players then
        return false, "room full"
    end
    self.players[peer_id] = {
        name  = name or ("Player" .. peer_id),
        ready = false,
        data  = data or {},
    }
    if not self.host_peer then
        self.host_peer = peer_id
    end
    return true
end

function Room:removePlayer(peer_id)
    self.players[peer_id] = nil
    if self.host_peer == peer_id then
        self.host_peer = next(self.players)
    end
end

function Room:getPlayerCount()
    local n = 0
    for _ in pairs(self.players) do n = n + 1 end
    return n
end

function Room:isAllReady()
    local count = 0
    for _, p in pairs(self.players) do
        if not p.ready then return false end
        count = count + 1
    end
    return count >= 2  -- at least 2 players required
end

---------------------------------------------------------------------------
-- Lobby Manager
---------------------------------------------------------------------------

local Lobby = {}
Lobby.__index = Lobby

--- Create a new lobby manager attached to a NetworkHost.
--- @tparam userdata host  A `lurek.network.newHost/newServer` host.
--- @tparam[opt=0] number channel  ENet channel for lobby traffic.
--- @treturn Lobby
function M.new(host, channel)
    local self = setmetatable({}, Lobby)
    self._host       = host
    self._channel    = channel or 0
    self._rooms      = {}   -- { name = Room }
    self._my_room    = nil  -- current room name (client-side)
    self._my_name    = "Player"
    self._on_event   = nil
    return self
end

--- Set the local player name used when joining rooms.
--- @tparam string name
function Lobby:setPlayerName(name)
    self._my_name = name
end

--- Register a callback for lobby events.
--- @tparam function fn  `fn(event_type, data)` where event_type is a string.
function Lobby:onEvent(fn)
    self._on_event = fn
end

--- Create a new room (server-side).
--- @tparam string name       Room name (unique).
--- @tparam[opt] table opts   `{ maxPlayers, password, data }`.
--- @treturn boolean success
--- @treturn string|nil error
function Lobby:createRoom(name, opts)
    if self._rooms[name] then
        return false, "room already exists"
    end
    self._rooms[name] = Room._new(name, opts)
    if self._on_event then
        self._on_event("room_created", { name = name })
    end
    return true
end

--- Remove a room (server-side).
--- @tparam string name
function Lobby:removeRoom(name)
    self._rooms[name] = nil
    if self._on_event then
        self._on_event("room_removed", { name = name })
    end
end

--- Join a room by name (local or via network message).
--- @tparam string name  Room name.
--- @tparam[opt] number peer_id  Peer joining (server-side). Nil for local join request.
--- @tparam[opt] string player_name
--- @treturn boolean success
--- @treturn string|nil error
function Lobby:joinRoom(name, peer_id, player_name)
    local room = self._rooms[name]
    if not room then
        return false, "room not found"
    end
    local pid = peer_id or 0
    local pname = player_name or self._my_name
    local ok, err = room:addPlayer(pid, pname)
    if not ok then return false, err end

    if not peer_id then
        self._my_room = name
    end
    if self._on_event then
        self._on_event("player_joined", { room = name, peer_id = pid, name = pname })
    end
    return true
end

--- Leave the current room.
--- @tparam[opt] number peer_id  Peer leaving (server-side). Nil for local.
function Lobby:leaveRoom(peer_id)
    local room_name = self._my_room
    if not room_name then return end
    local room = self._rooms[room_name]
    if room then
        local pid = peer_id or 0
        room:removePlayer(pid)
        if self._on_event then
            self._on_event("player_left", { room = room_name, peer_id = pid })
        end
        if room:getPlayerCount() == 0 then
            self._rooms[room_name] = nil
        end
    end
    if not peer_id then
        self._my_room = nil
    end
end

--- List all available rooms.
--- @treturn table  Array of `{ name, players, maxPlayers }` tables.
function Lobby:listRooms()
    local list = {}
    for name, room in pairs(self._rooms) do
        table.insert(list, {
            name       = name,
            players    = room:getPlayerCount(),
            maxPlayers = room.max_players,
            hasPassword = room.password ~= nil,
        })
    end
    return list
end

--- Get players in a specific room (or current room if name is nil).
--- @tparam[opt] string name
--- @treturn table  Array of `{ peer_id, name, ready }`.
function Lobby:getPlayers(name)
    local room = self._rooms[name or self._my_room]
    if not room then return {} end
    local list = {}
    for pid, p in pairs(room.players) do
        table.insert(list, {
            peer_id = pid,
            name    = p.name,
            ready   = p.ready,
        })
    end
    return list
end

--- Set ready state for a player in the current room.
--- @tparam boolean ready
--- @tparam[opt] number peer_id  Peer (server-side). Nil for local.
function Lobby:setReady(ready, peer_id)
    local room = self._rooms[self._my_room]
    if not room then return end
    local pid = peer_id or 0
    local player = room.players[pid]
    if player then
        player.ready = ready
        if self._on_event then
            self._on_event("player_ready", {
                room = self._my_room, peer_id = pid, ready = ready
            })
        end
    end
end

--- Check if all players in the current room are ready.
--- @treturn boolean
function Lobby:isAllReady()
    local room = self._rooms[self._my_room]
    if not room then return false end
    return room:isAllReady()
end

--- Get the current room name (client-side).
--- @treturn string|nil
function Lobby:getCurrentRoom()
    return self._my_room
end

--- Get the number of rooms.
--- @treturn number
function Lobby:getRoomCount()
    local n = 0
    for _ in pairs(self._rooms) do n = n + 1 end
    return n
end

--- Process incoming lobby network messages. Call once per frame.
--- @treturn table  Array of processed events.
function Lobby:poll()
    local events = {}
    local ev = self._host:service()
    while ev do
        if ev.type == "receive" then
            local ok, data = pcall(lurek.network.unpack, ev.data)
            if ok and type(data) == "table" and data.type == "lobby" then
                self:_handle(ev.peer, data, events)
            end
        elseif ev.type == "disconnect" then
            -- Remove disconnected peer from their room
            for _, room in pairs(self._rooms) do
                if room.players[ev.peer] then
                    room:removePlayer(ev.peer)
                    local e = { type = "player_disconnected", peer_id = ev.peer }
                    table.insert(events, e)
                    if self._on_event then self._on_event("player_disconnected", e) end
                end
            end
        end
        ev = self._host:service()
    end
    return events
end

--- Internal: handle a decoded lobby message from a peer.
function Lobby:_handle(peer_id, data, events)
    local action = data.action
    if action == "join" then
        local ok, err = self:joinRoom(data.room, peer_id, data.name)
        if ok then
            table.insert(events, { type = "join", peer_id = peer_id, room = data.room })
        end
    elseif action == "leave" then
        self:leaveRoom(peer_id)
        table.insert(events, { type = "leave", peer_id = peer_id })
    elseif action == "ready" then
        self:setReady(data.ready, peer_id)
        table.insert(events, { type = "ready", peer_id = peer_id, ready = data.ready })
    elseif action == "list" then
        local rooms = self:listRooms()
        local resp = lurek.network.pack({ type = "lobby", action = "list_response", rooms = rooms })
        self._host:send(peer_id, self._channel, resp, true)
    end
end

return M
