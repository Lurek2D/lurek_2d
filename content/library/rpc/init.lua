--- @module library.rpc
--- @description Pure-Lua Remote Procedure Call library built on lurek.network.
--- Enables calling functions on remote peers over ENet with automatic
--- MessagePack serialization. Supports request/response, fire-and-forget,
--- and broadcast patterns.
local M = {}

---------------------------------------------------------------------------
-- RPC Manager
---------------------------------------------------------------------------

local RPC = {}
RPC.__index = RPC

--- Create a new RPC manager attached to a NetworkHost.
--- @tparam userdata host  A `lurek.network.newHost/newServer/newClient` host.
--- @tparam[opt=0] number channel  The ENet channel used for RPC traffic.
--- @treturn RPC
function M.new(host, channel)
    local self = setmetatable({}, RPC)
    self._host      = host
    self._channel   = channel or 0
    self._handlers  = {}
    self._pending   = {}
    self._next_id   = 1
    self._on_error  = nil
    return self
end

--- Register a function callable from remote peers.
--- @tparam string name   Unique RPC function name.
--- @tparam function fn   Handler: `fn(peer_id, arg1, arg2, ...)` → returns results.
function RPC:register(name, fn)
    self._handlers[name] = fn
end

--- Unregister a previously registered function.
--- @tparam string name
function RPC:unregister(name)
    self._handlers[name] = nil
end

--- Set a global error handler for RPC processing errors.
--- @tparam function fn  `fn(error_string)`
function RPC:onError(fn)
    self._on_error = fn
end

--- Call a function on a specific remote peer (request/response pattern).
--- @tparam number peer_id  Target peer.
--- @tparam string name     Function name registered on the remote side.
--- @param ...               Arguments (must be MessagePack-serializable).
--- @treturn number          Request ID for matching the response.
function RPC:call(peer_id, name, ...)
    local id = self._next_id
    self._next_id = self._next_id + 1
    local msg = lurek.network.pack({
        type = "rpc_call",
        id   = id,
        name = name,
        args = { ... },
    })
    self._host:send(peer_id, self._channel, msg, true)
    return id
end

--- Fire-and-forget call: no response expected.
--- @tparam number peer_id
--- @tparam string name
--- @param ...
function RPC:notify(peer_id, name, ...)
    local msg = lurek.network.pack({
        type = "rpc_notify",
        name = name,
        args = { ... },
    })
    self._host:send(peer_id, self._channel, msg, true)
end

--- Broadcast an RPC call to all connected peers (fire-and-forget).
--- @tparam string name
--- @param ...
function RPC:broadcast(name, ...)
    local msg = lurek.network.pack({
        type = "rpc_notify",
        name = name,
        args = { ... },
    })
    self._host:broadcast(self._channel, msg, true)
end

--- Process incoming RPC messages. Call once per frame in `lurek.process(dt)`.
--- Dispatches received RPC calls to registered handlers and collects responses.
--- @treturn table  Array of `{id, result, error}` response tables (may be empty).
function RPC:poll()
    local responses = {}
    local ev = self._host:service()
    while ev do
        if ev.type == "receive" then
            local ok, data = pcall(lurek.network.unpack, ev.data)
            if ok and type(data) == "table" then
                self:_dispatch(ev.peer, data, responses)
            elseif self._on_error then
                self._on_error("RPC: failed to unpack message")
            end
        end
        ev = self._host:service()
    end
    return responses
end

--- Internal: dispatch a decoded RPC message.
function RPC:_dispatch(peer_id, data, responses)
    if data.type == "rpc_call" and data.name then
        local handler = self._handlers[data.name]
        if handler then
            local result = { pcall(handler, peer_id, unpack(data.args or {})) }
            local success = table.remove(result, 1)
            if data.id and data.id > 0 then
                local resp = lurek.network.pack({
                    type    = "rpc_response",
                    id      = data.id,
                    success = success,
                    result  = result,
                })
                self._host:send(peer_id, self._channel, resp, true)
            end
        elseif self._on_error then
            self._on_error("RPC: no handler for '" .. tostring(data.name) .. "'")
        end
    elseif data.type == "rpc_notify" and data.name then
        local handler = self._handlers[data.name]
        if handler then
            local ok, err = pcall(handler, peer_id, unpack(data.args or {}))
            if not ok and self._on_error then
                self._on_error("RPC notify error: " .. tostring(err))
            end
        end
    elseif data.type == "rpc_response" then
        table.insert(responses, {
            id      = data.id,
            success = data.success,
            result  = data.result,
        })
    end
end

--- Get the number of registered RPC handlers.
--- @treturn number
function RPC:getHandlerCount()
    local n = 0
    for _ in pairs(self._handlers) do n = n + 1 end
    return n
end

return M
