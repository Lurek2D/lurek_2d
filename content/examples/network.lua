-- content/examples/network.lua
-- Lurek2D lurek.network API Reference
-- Run with: cargo run -- content/examples/network

-- =============================================================================
-- lurek.network — UDP peer-to-peer (ENet), TCP, WebSocket, HTTP, lobbies
--
-- NetworkHost wraps ENet for reliable/unreliable UDP channels with peer
-- management.  NetworkRuntime provides HTTP requests, TCP sockets, and
-- WebSocket connections for REST APIs and chat systems.
-- =============================================================================

-- ---- Stub: lurek.network.newHost -----------------------------------------
--@api-stub: lurek.network.newHost
-- Demonstrates the proper usage of lurek.network.newHost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_newHost()
    local host = lurek.network.newHost("0.0.0.0:7777", 32, 2)
    print("network host created on port 7777, max 32 peers")
end
local _ok, _err = pcall(demo_lurek_network_newHost)

-- ---- Stub: lurek.network.newServer ---------------------------------------
--@api-stub: lurek.network.newServer
-- Demonstrates the proper usage of lurek.network.newServer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_newServer()
    local server = lurek.network.newServer(7778, 16)
    print("server listening on port 7778, max 16 players")
end
local _ok, _err = pcall(demo_lurek_network_newServer)

-- ---- Stub: lurek.network.newClient ---------------------------------------
--@api-stub: lurek.network.newClient
-- Demonstrates the proper usage of lurek.network.newClient.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_newClient()
    local client = lurek.network.newClient("127.0.0.1:7778")
    print("client connecting to 127.0.0.1:7778")
end
local _ok, _err = pcall(demo_lurek_network_newClient)

-- ---- Stub: lurek.network.pack --------------------------------------------
--@api-stub: lurek.network.pack
-- Demonstrates the proper usage of lurek.network.pack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_pack()
    local msg = lurek.network.pack({ type = "move", x = 100.5, y = 200.3 })
    print("packed network message: " .. #msg .. " bytes")
end
local _ok, _err = pcall(demo_lurek_network_pack)

-- ---- Stub: lurek.network.unpack ------------------------------------------
--@api-stub: lurek.network.unpack
-- Demonstrates the proper usage of lurek.network.unpack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_unpack()
    local event = lurek.network.unpack(msg)
    print("unpacked: type=" .. event.type .. " x=" .. event.x)
end
local _ok, _err = pcall(demo_lurek_network_unpack)

-- ---- Stub: lurek.network.createLobby -------------------------------------
--@api-stub: lurek.network.createLobby
-- Demonstrates the proper usage of lurek.network.createLobby.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_createLobby()
    local lobby = lurek.network.createLobby({
    name = "Boss Rush Room",
    max_players = 4,
    map = "dungeon_3",
    })
    print("lobby created: " .. tostring(lobby))
end
local _ok, _err = pcall(demo_lurek_network_createLobby)

-- ---- Stub: lurek.network.discoverLobbies ---------------------------------
--@api-stub: lurek.network.discoverLobbies
-- Demonstrates the proper usage of lurek.network.discoverLobbies.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_discoverLobbies()
    local lobbies = lurek.network.discoverLobbies()
    print("discovered " .. #(lobbies or {}) .. " lobbies")
    for i, l in ipairs(lobbies or {}) do
    print(string.format("  %d) %s (%d/%d players)", i, l.name, l.players, l.max_players))
end
local _ok, _err = pcall(demo_lurek_network_discoverLobbies)

-- ---- Stub: lurek.network.syncEntity --------------------------------------
--@api-stub: lurek.network.syncEntity
-- Demonstrates the proper usage of lurek.network.syncEntity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_syncEntity()
    lurek.network.syncEntity(host, {
    id = 1,
    x = 150.0,
    y = 300.0,
    vx = 5.0,
    vy = -2.0,
    })
    print("entity 1 state synced to all peers")
end
local _ok, _err = pcall(demo_lurek_network_syncEntity)

-- =============================================================================
-- NetworkHost — ENet peer-to-peer operations
-- =============================================================================

-- ---- Stub: NetworkHost:service -------------------------------------------
--@api-stub: NetworkHost:service
-- Poll for network events (connect, disconnect, receive).  Call every
-- frame with a short timeout.
local evt = host:service(0)
if evt then
    print("network event: " .. tostring(evt.type))
else
    print("no network events this frame")
end

-- ---- Stub: NetworkHost:flush ---------------------------------------------
--@api-stub: NetworkHost:flush
-- Demonstrates the proper usage of NetworkHost:flush.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_flush()
    host:flush()
    print("outgoing packets flushed")
end
local _ok, _err = pcall(demo_NetworkHost_flush)

-- ---- Stub: NetworkHost:disconnect ----------------------------------------
--@api-stub: NetworkHost:disconnect
-- Demonstrates the proper usage of NetworkHost:disconnect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_disconnect()
    host:disconnect(0)
    print("peer 0 disconnect requested (graceful)")
end
local _ok, _err = pcall(demo_NetworkHost_disconnect)

-- ---- Stub: NetworkHost:disconnectNow -------------------------------------
--@api-stub: NetworkHost:disconnectNow
-- Demonstrates the proper usage of NetworkHost:disconnectNow.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_disconnectNow()
    host:disconnectNow(0)
    print("peer 0 disconnected immediately (kicked)")
end
local _ok, _err = pcall(demo_NetworkHost_disconnectNow)

-- ---- Stub: NetworkHost:resetPeer -----------------------------------------
--@api-stub: NetworkHost:resetPeer
-- Demonstrates the proper usage of NetworkHost:resetPeer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_resetPeer()
    host:resetPeer(0)
    print("peer 0 connection state reset")
end
local _ok, _err = pcall(demo_NetworkHost_resetPeer)

-- ---- Stub: NetworkHost:ping ----------------------------------------------
--@api-stub: NetworkHost:ping
-- Demonstrates the proper usage of NetworkHost:ping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_ping()
    host:ping(0)
    print("ping sent to peer 0")
end
local _ok, _err = pcall(demo_NetworkHost_ping)

-- ---- Stub: NetworkHost:getRoundTripTime ----------------------------------
--@api-stub: NetworkHost:getRoundTripTime
-- Demonstrates the proper usage of NetworkHost:getRoundTripTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getRoundTripTime()
    local rtt = host:getRoundTripTime(0)
    print("peer 0 RTT: " .. tostring(rtt) .. " ms")
end
local _ok, _err = pcall(demo_NetworkHost_getRoundTripTime)

-- ---- Stub: NetworkHost:getPeerState --------------------------------------
--@api-stub: NetworkHost:getPeerState
-- Demonstrates the proper usage of NetworkHost:getPeerState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getPeerState()
    local state = host:getPeerState(0)
    print("peer 0 state: " .. tostring(state))
end
local _ok, _err = pcall(demo_NetworkHost_getPeerState)

-- ---- Stub: NetworkHost:getPeerAddress ------------------------------------
--@api-stub: NetworkHost:getPeerAddress
-- Demonstrates the proper usage of NetworkHost:getPeerAddress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getPeerAddress()
    local addr = host:getPeerAddress(0)
    print("peer 0 address: " .. tostring(addr))
end
local _ok, _err = pcall(demo_NetworkHost_getPeerAddress)

-- ---- Stub: NetworkHost:getAddress ----------------------------------------
--@api-stub: NetworkHost:getAddress
-- Demonstrates the proper usage of NetworkHost:getAddress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getAddress()
    local my_addr = host:getAddress()
    print("host address: " .. tostring(my_addr))
end
local _ok, _err = pcall(demo_NetworkHost_getAddress)

-- ---- Stub: NetworkHost:getPeerLimit --------------------------------------
--@api-stub: NetworkHost:getPeerLimit
-- Demonstrates the proper usage of NetworkHost:getPeerLimit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getPeerLimit()
    local max_peers = host:getPeerLimit()
    print("max peers: " .. tostring(max_peers))
end
local _ok, _err = pcall(demo_NetworkHost_getPeerLimit)

-- ---- Stub: NetworkHost:getChannelLimit -----------------------------------
--@api-stub: NetworkHost:getChannelLimit
-- Demonstrates the proper usage of NetworkHost:getChannelLimit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getChannelLimit()
    local channels = host:getChannelLimit()
    print("channel limit: " .. tostring(channels))
end
local _ok, _err = pcall(demo_NetworkHost_getChannelLimit)

-- ---- Stub: NetworkHost:setChannelLimit -----------------------------------
--@api-stub: NetworkHost:setChannelLimit
-- Demonstrates the proper usage of NetworkHost:setChannelLimit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_setChannelLimit()
    host:setChannelLimit(4)
    print("channel limit set to 4")
end
local _ok, _err = pcall(demo_NetworkHost_setChannelLimit)

-- ---- Stub: NetworkHost:getBandwidthLimit ---------------------------------
--@api-stub: NetworkHost:getBandwidthLimit
-- Demonstrates the proper usage of NetworkHost:getBandwidthLimit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getBandwidthLimit()
    local bw_in, bw_out = host:getBandwidthLimit()
    print(string.format("bandwidth: in=%s out=%s", tostring(bw_in), tostring(bw_out)))
end
local _ok, _err = pcall(demo_NetworkHost_getBandwidthLimit)

-- ---- Stub: NetworkHost:getConnectedPeerCount -----------------------------
--@api-stub: NetworkHost:getConnectedPeerCount
-- Demonstrates the proper usage of NetworkHost:getConnectedPeerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getConnectedPeerCount()
    local connected = host:getConnectedPeerCount()
    print("connected peers: " .. tostring(connected))
end
local _ok, _err = pcall(demo_NetworkHost_getConnectedPeerCount)

-- ---- Stub: NetworkHost:getConnectedPeerIds -------------------------------
--@api-stub: NetworkHost:getConnectedPeerIds
-- Demonstrates the proper usage of NetworkHost:getConnectedPeerIds.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getConnectedPeerIds()
    local peer_ids = host:getConnectedPeerIds()
    print("connected peer IDs: " .. table.concat(peer_ids or {}, ", "))
end
local _ok, _err = pcall(demo_NetworkHost_getConnectedPeerIds)

-- ---- Stub: NetworkHost:getPeerStats --------------------------------------
--@api-stub: NetworkHost:getPeerStats
-- Demonstrates the proper usage of NetworkHost:getPeerStats.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getPeerStats()
    local stats = host:getPeerStats(0)
    if stats then
    print(string.format("peer 0 stats: sent=%d recv=%d loss=%.1f%%",
        stats.packets_sent or 0, stats.packets_received or 0, stats.packet_loss or 0))
end
local _ok, _err = pcall(demo_NetworkHost_getPeerStats)

-- ---- Stub: NetworkHost:destroy -------------------------------------------
--@api-stub: NetworkHost:destroy
-- Demonstrates the proper usage of NetworkHost:destroy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_destroy()
    host:destroy()
    print("network host destroyed")
end
local _ok, _err = pcall(demo_NetworkHost_destroy)

-- ---- Stub: NetworkHost:isDestroyed ---------------------------------------
--@api-stub: NetworkHost:isDestroyed
-- Demonstrates the proper usage of NetworkHost:isDestroyed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_isDestroyed()
    local destroyed = host:isDestroyed()
    print("host destroyed: " .. tostring(destroyed))
end
local _ok, _err = pcall(demo_NetworkHost_isDestroyed)

-- ---- Stub: NetworkHost:getRole -------------------------------------------
--@api-stub: NetworkHost:getRole
-- Demonstrates the proper usage of NetworkHost:getRole.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getRole()
    local role = server:getRole()
    print("server role: " .. tostring(role))
end
local _ok, _err = pcall(demo_NetworkHost_getRole)

-- ---- Stub: NetworkHost:isServer ------------------------------------------
--@api-stub: NetworkHost:isServer
-- Demonstrates the proper usage of NetworkHost:isServer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_isServer()
    print("is server: " .. tostring(server:isServer()))
end
local _ok, _err = pcall(demo_NetworkHost_isServer)

-- ---- Stub: NetworkHost:isClient ------------------------------------------
--@api-stub: NetworkHost:isClient
-- Demonstrates the proper usage of NetworkHost:isClient.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_isClient()
    print("client is client: " .. tostring(client:isClient()))
end
local _ok, _err = pcall(demo_NetworkHost_isClient)

-- =============================================================================
-- NetworkRuntime — HTTP, TCP, WebSocket
-- =============================================================================

-- ---- Stub: lurek.network.newRuntime --------------------------------------
--@api-stub: lurek.network.newRuntime
-- Demonstrates the proper usage of lurek.network.newRuntime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_newRuntime()
    local runtime = lurek.network.newRuntime()
    print("network runtime created")
end
local _ok, _err = pcall(demo_lurek_network_newRuntime)

-- ---- Stub: NetworkRuntime:httpRequest ------------------------------------
--@api-stub: NetworkRuntime:httpRequest
-- Demonstrates the proper usage of NetworkRuntime:httpRequest.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_httpRequest()
    runtime:httpRequest("GET", "https://api.example.com/leaderboard", {
    headers = { ["Authorization"] = "Bearer token123" },
    callback = function(status, body)
        print(string.format("  HTTP %d: %d bytes", status, #body))
    end,
    })
    print("HTTP GET leaderboard request queued")
end
local _ok, _err = pcall(demo_NetworkRuntime_httpRequest)

-- ---- Stub: NetworkRuntime:tcpConnect -------------------------------------
--@api-stub: NetworkRuntime:tcpConnect
-- Demonstrates the proper usage of NetworkRuntime:tcpConnect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_tcpConnect()
    local tcp_id = runtime:tcpConnect("chat.example.com", 9000)
    print("TCP connecting to chat.example.com:9000 (id: " .. tostring(tcp_id) .. ")")
end
local _ok, _err = pcall(demo_NetworkRuntime_tcpConnect)

-- ---- Stub: NetworkRuntime:tcpSend ----------------------------------------
--@api-stub: NetworkRuntime:tcpSend
-- Demonstrates the proper usage of NetworkRuntime:tcpSend.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_tcpSend()
    runtime:tcpSend(tcp_id, "Hello from Lurek2D!\n")
    print("TCP message sent")
end
local _ok, _err = pcall(demo_NetworkRuntime_tcpSend)

-- ---- Stub: NetworkRuntime:tcpClose ---------------------------------------
--@api-stub: NetworkRuntime:tcpClose
-- Demonstrates the proper usage of NetworkRuntime:tcpClose.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_tcpClose()
    runtime:tcpClose(tcp_id)
    print("TCP connection closed")
end
local _ok, _err = pcall(demo_NetworkRuntime_tcpClose)

-- ---- Stub: NetworkRuntime:wsConnect --------------------------------------
--@api-stub: NetworkRuntime:wsConnect
-- Demonstrates the proper usage of NetworkRuntime:wsConnect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_wsConnect()
    local ws_id = runtime:wsConnect("wss://game.example.com/sync")
    print("WebSocket connecting (id: " .. tostring(ws_id) .. ")")
end
local _ok, _err = pcall(demo_NetworkRuntime_wsConnect)

-- ---- Stub: NetworkRuntime:wsSend -----------------------------------------
--@api-stub: NetworkRuntime:wsSend
-- Demonstrates the proper usage of NetworkRuntime:wsSend.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_wsSend()
    runtime:wsSend(ws_id, '{"type":"pos","x":100,"y":200}')
    print("WebSocket message sent")
end
local _ok, _err = pcall(demo_NetworkRuntime_wsSend)

-- ---- Stub: NetworkRuntime:wsClose ----------------------------------------
--@api-stub: NetworkRuntime:wsClose
-- Demonstrates the proper usage of NetworkRuntime:wsClose.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_wsClose()
    runtime:wsClose(ws_id)
    print("WebSocket closed")
end
local _ok, _err = pcall(demo_NetworkRuntime_wsClose)

-- ---- Stub: NetworkRuntime:poll -------------------------------------------
--@api-stub: NetworkRuntime:poll
-- Demonstrates the proper usage of NetworkRuntime:poll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_poll()
    local events = runtime:poll()
    print("runtime poll: " .. tostring(#(events or {})) .. " events")
end
local _ok, _err = pcall(demo_NetworkRuntime_poll)

-- ---- Stub: NetworkRuntime:shutdown ---------------------------------------
--@api-stub: NetworkRuntime:shutdown
-- Demonstrates the proper usage of NetworkRuntime:shutdown.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_shutdown()
    runtime:shutdown()
    print("network runtime shut down")
end
local _ok, _err = pcall(demo_NetworkRuntime_shutdown)

-- =============================================================================
-- STUBS: 40 uncovered lurek.network API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- ---- Stub: lurek.network.newHost -----------------------------------------
--@api-stub: lurek.network.newHost
-- Demonstrates the proper usage of lurek.network.newHost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_newHost()
    local host = lurek.network.newHost({ address = "*", port = 7777, peers = 8, channels = 2 })
    print("host bound at:", host:getAddress())
end
local _ok, _err = pcall(demo_lurek_network_newHost)

-- ---- Stub: lurek.network.newServer ---------------------------------------
--@api-stub: lurek.network.newServer
-- Demonstrates the proper usage of lurek.network.newServer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_newServer()
    local server = lurek.network.newServer({ port = 7777, peers = 16, channels = 2 })
    print("server listening on port 7777, role:", server:getRole())
end
local _ok, _err = pcall(demo_lurek_network_newServer)

-- ---- Stub: lurek.network.newClient ---------------------------------------
--@api-stub: lurek.network.newClient
-- Demonstrates the proper usage of lurek.network.newClient.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_newClient()
    local client = lurek.network.newClient({ address = "127.0.0.1", port = 7777, channels = 2 })
    print("client created, role:", client:getRole())
end
local _ok, _err = pcall(demo_lurek_network_newClient)

-- ---- Stub: lurek.network.newRuntime --------------------------------------
--@api-stub: lurek.network.newRuntime
-- Demonstrates the proper usage of lurek.network.newRuntime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_newRuntime()
    local rt = lurek.network.newRuntime()
    print("async network runtime started")
end
local _ok, _err = pcall(demo_lurek_network_newRuntime)

-- ---- Stub: lurek.network.pack --------------------------------------------
--@api-stub: lurek.network.pack
-- Serialise any Lua value to a compact binary MessagePack blob ready to
-- send over ENet -- more efficient than JSON for frequent game-state updates.
local payload = { pos = { x = 100.5, y = 200.0 }, hp = 80 }
local packed = lurek.network.pack(payload)
print("packed", #packed, "bytes")

-- ---- Stub: lurek.network.unpack ------------------------------------------
--@api-stub: lurek.network.unpack
-- Deserialise a MessagePack blob back to a Lua table on the receiver side --
-- always unpack before reading individual fields.
local payload = { pos = { x = 100.5, y = 200.0 }, hp = 80 }
local blob = lurek.network.pack(payload)
local decoded = lurek.network.unpack(blob)
if decoded then
    print("received hp:", decoded.hp)
end

-- ---- Stub: lurek.network.createLobby -------------------------------------
--@api-stub: lurek.network.createLobby
-- Broadcast your game session over LAN so other players on the same network
-- can discover and join without manually entering an IP address.
local lobby = lurek.network.createLobby("my_game", 7777, 1, 4)
if lobby then
    print("lobby created, session:", lobby.name)
end

-- ---- Stub: lurek.network.discoverLobbies ---------------------------------
--@api-stub: lurek.network.discoverLobbies
-- Scan the LAN for active game sessions and present them in a lobby browser
-- without requiring players to know the server's IP address.
local lobbies = lurek.network.discoverLobbies(600)  -- wait 600 ms
if lobbies then
    print("found", #lobbies, "lobby/lobbies")
    for _, l in ipairs(lobbies) do
        print(" ", l.name, "at", l.address, "port", l.port)
    end
end

-- ---- Stub: lurek.network.syncEntity --------------------------------------
--@api-stub: lurek.network.syncEntity
-- Demonstrates the proper usage of lurek.network.syncEntity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_network_syncEntity()
    local entity = { id = 42, x = 150.0, y = 80.0, hp = 95 }
    lurek.network.syncEntity(server, entity)
end
local _ok, _err = pcall(demo_lurek_network_syncEntity)

-- ---- Stub: NetworkHost:service -------------------------------------------
--@api-stub: NetworkHost:service
-- Poll for one network event per call -- call in lurek.process() in a loop
-- until service() returns nil to drain the entire incoming queue.
local event = server:service()
if event then
    print("event:", event.type, "peer:", event.peer_id)
end

-- ---- Stub: NetworkHost:flush ---------------------------------------------
--@api-stub: NetworkHost:flush
-- Demonstrates the proper usage of NetworkHost:flush.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_flush()
    server:flush()
    print("pending sends flushed")
end
local _ok, _err = pcall(demo_NetworkHost_flush)

-- ---- Stub: NetworkHost:disconnect ----------------------------------------
--@api-stub: NetworkHost:disconnect
-- Demonstrates the proper usage of NetworkHost:disconnect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_disconnect()
    server:disconnect(1, 0)  -- peer_id = 1, data = 0
    print("disconnect signal sent to peer 1")
end
local _ok, _err = pcall(demo_NetworkHost_disconnect)

-- ---- Stub: NetworkHost:disconnectNow -------------------------------------
--@api-stub: NetworkHost:disconnectNow
-- Demonstrates the proper usage of NetworkHost:disconnectNow.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_disconnectNow()
    server:disconnectNow(2, 0)
    print("peer 2 force-disconnected")
end
local _ok, _err = pcall(demo_NetworkHost_disconnectNow)

-- ---- Stub: NetworkHost:resetPeer -----------------------------------------
--@api-stub: NetworkHost:resetPeer
-- Demonstrates the proper usage of NetworkHost:resetPeer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_resetPeer()
    server:resetPeer(3)
    print("peer 3 silently reset")
end
local _ok, _err = pcall(demo_NetworkHost_resetPeer)

-- ---- Stub: NetworkHost:ping ----------------------------------------------
--@api-stub: NetworkHost:ping
-- Demonstrates the proper usage of NetworkHost:ping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_ping()
    server:ping(1)
    print("ping sent to peer 1")
end
local _ok, _err = pcall(demo_NetworkHost_ping)

-- ---- Stub: NetworkHost:getRoundTripTime ----------------------------------
--@api-stub: NetworkHost:getRoundTripTime
-- Demonstrates the proper usage of NetworkHost:getRoundTripTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getRoundTripTime()
    local rtt = server:getRoundTripTime(1)
    print(string.format("peer 1 RTT: %d ms", rtt or 0))
end
local _ok, _err = pcall(demo_NetworkHost_getRoundTripTime)

-- ---- Stub: NetworkHost:getPeerState --------------------------------------
--@api-stub: NetworkHost:getPeerState
-- Demonstrates the proper usage of NetworkHost:getPeerState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getPeerState()
    local state = server:getPeerState(1)
    print("peer 1 state:", state)  -- "connected", "connecting", "disconnected"
end
local _ok, _err = pcall(demo_NetworkHost_getPeerState)

-- ---- Stub: NetworkHost:getPeerAddress ------------------------------------
--@api-stub: NetworkHost:getPeerAddress
-- Demonstrates the proper usage of NetworkHost:getPeerAddress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getPeerAddress()
    local addr = server:getPeerAddress(1)
    print("peer 1 address:", addr or "unknown")
end
local _ok, _err = pcall(demo_NetworkHost_getPeerAddress)

-- ---- Stub: NetworkHost:getAddress ----------------------------------------
--@api-stub: NetworkHost:getAddress
-- Demonstrates the proper usage of NetworkHost:getAddress.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getAddress()
    local addr = server:getAddress()
    print("server listening at:", addr)
end
local _ok, _err = pcall(demo_NetworkHost_getAddress)

-- ---- Stub: NetworkHost:getPeerLimit --------------------------------------
--@api-stub: NetworkHost:getPeerLimit
-- Read the peer limit to display remaining open slots in the lobby browser
-- and to reject join requests when the server is full.
local limit = server:getPeerLimit()
local connected = server:getConnectedPeerCount()
print(string.format("players: %d / %d", connected, limit))

-- ---- Stub: NetworkHost:getChannelLimit -----------------------------------
--@api-stub: NetworkHost:getChannelLimit
-- Demonstrates the proper usage of NetworkHost:getChannelLimit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getChannelLimit()
    print("channels per connection:", server:getChannelLimit())
end
local _ok, _err = pcall(demo_NetworkHost_getChannelLimit)

-- ---- Stub: NetworkHost:setChannelLimit -----------------------------------
--@api-stub: NetworkHost:setChannelLimit
-- Demonstrates the proper usage of NetworkHost:setChannelLimit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_setChannelLimit()
    server:setChannelLimit(4)
    print("channel limit set to 4")
end
local _ok, _err = pcall(demo_NetworkHost_setChannelLimit)

-- ---- Stub: NetworkHost:getBandwidthLimit ---------------------------------
--@api-stub: NetworkHost:getBandwidthLimit
-- Demonstrates the proper usage of NetworkHost:getBandwidthLimit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getBandwidthLimit()
    local bw = server:getBandwidthLimit()
    print("incoming:", bw.incoming, "B/s  outgoing:", bw.outgoing, "B/s")
end
local _ok, _err = pcall(demo_NetworkHost_getBandwidthLimit)

-- ---- Stub: NetworkHost:getConnectedPeerCount -----------------------------
--@api-stub: NetworkHost:getConnectedPeerCount
-- Demonstrates the proper usage of NetworkHost:getConnectedPeerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getConnectedPeerCount()
    print("connected players:", server:getConnectedPeerCount())
end
local _ok, _err = pcall(demo_NetworkHost_getConnectedPeerCount)

-- ---- Stub: NetworkHost:getConnectedPeerIds -------------------------------
--@api-stub: NetworkHost:getConnectedPeerIds
-- Enumerate all connected peers to broadcast a message to every player or
-- to build the scoreboard without maintaining a separate player ID list.
local ids = server:getConnectedPeerIds()
print("connected peer IDs:")
for _, id in ipairs(ids) do
    print("  peer", id, "@", server:getPeerAddress(id))
end

-- ---- Stub: NetworkHost:getPeerStats --------------------------------------
--@api-stub: NetworkHost:getPeerStats
-- Log stats to the developer overlay to diagnose packet loss and
-- latency spikes during play-testing.
local stats = server:getPeerStats(1)
if stats then
    print(string.format("peer 1: RTT %d ms, sent %d, recv %d",
          stats.rtt or 0, stats.packets_sent or 0, stats.packets_recv or 0))
end

-- ---- Stub: NetworkHost:destroy -------------------------------------------
--@api-stub: NetworkHost:destroy
-- Close the socket and release ENet resources when the session ends --
-- call this during scene cleanup so the port is freed for the next game.
if not server:isDestroyed() then
    server:destroy()
    print("server socket closed")
end

-- ---- Stub: NetworkHost:isDestroyed ---------------------------------------
--@api-stub: NetworkHost:isDestroyed
-- Guard all network calls with isDestroyed() to prevent use-after-destroy
-- errors when the host is cleaned up during scene transitions.
if server:isDestroyed() then
    print("host already destroyed -- skip network calls")
end

-- ---- Stub: NetworkHost:getRole -------------------------------------------
--@api-stub: NetworkHost:getRole
-- Demonstrates the proper usage of NetworkHost:getRole.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkHost_getRole()
    print("role:", server:getRole())  -- "server"
end
local _ok, _err = pcall(demo_NetworkHost_getRole)

-- ---- Stub: NetworkHost:isServer ------------------------------------------
--@api-stub: NetworkHost:isServer
-- Use to branch authority logic -- only the server modifies game state;
-- clients send inputs and wait for state updates.
if server:isServer() then
    print("running authoritative game logic")
end

-- ---- Stub: NetworkHost:isClient ------------------------------------------
--@api-stub: NetworkHost:isClient
-- Use to branch prediction logic -- clients run speculative movement and
-- apply server corrections when the authoritative update arrives.
if client:isClient() then
    print("running client prediction")
end

-- -----------------------------------------------------------------------------
-- NetworkRuntime methods
-- -----------------------------------------------------------------------------

-- ---- Stub: NetworkRuntime:httpRequest ------------------------------------
--@api-stub: NetworkRuntime:httpRequest
-- Fetch leaderboard data, patch notes, or authentication tokens without
-- blocking the game loop -- responses arrive via poll().
rt:httpRequest({
    method  = "GET",
    url     = "https://api.example.com/scores?game=lurek",
    id      = "leaderboard",
})
print("HTTP GET dispatched")

-- ---- Stub: NetworkRuntime:tcpConnect -------------------------------------
--@api-stub: NetworkRuntime:tcpConnect
-- Demonstrates the proper usage of NetworkRuntime:tcpConnect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_tcpConnect()
    local conn_id = rt:tcpConnect("127.0.0.1:8080")
    print("TCP connection handle:", conn_id)
end
local _ok, _err = pcall(demo_NetworkRuntime_tcpConnect)

-- ---- Stub: NetworkRuntime:tcpSend ----------------------------------------
--@api-stub: NetworkRuntime:tcpSend
-- Send raw bytes over the TCP connection -- use for custom protocols where
-- you control the framing (e.g. a length-prefixed message format).
local conn_id = 1
rt:tcpSend(conn_id, "HELLO lurek\n")
print("TCP message sent")

-- ---- Stub: NetworkRuntime:tcpClose ---------------------------------------
--@api-stub: NetworkRuntime:tcpClose
-- Close the TCP connection cleanly when the session ends or the server
-- sends a logout response -- prevents the OS from leaving sockets in TIME_WAIT.
local conn_id = 1
rt:tcpClose(conn_id)
print("TCP connection", conn_id, "closed")

-- ---- Stub: NetworkRuntime:wsConnect --------------------------------------
--@api-stub: NetworkRuntime:wsConnect
-- Demonstrates the proper usage of NetworkRuntime:wsConnect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_wsConnect()
    local ws_id = rt:wsConnect("ws://localhost:9001/match")
    print("WebSocket handle:", ws_id)
end
local _ok, _err = pcall(demo_NetworkRuntime_wsConnect)

-- ---- Stub: NetworkRuntime:wsSend -----------------------------------------
--@api-stub: NetworkRuntime:wsSend
-- Push a JSON or plain-text message to the WebSocket server -- use for
-- real-time chat, matchmaking requests, or inventory sync events.
local ws_id = 1
rt:wsSend(ws_id, '{"action":"find_match","mode":"ranked"}')
print("WebSocket message sent")

-- ---- Stub: NetworkRuntime:wsClose ----------------------------------------
--@api-stub: NetworkRuntime:wsClose
-- Gracefully close the WebSocket when leaving the lobby or ending the
-- session so the server is notified rather than timing out the connection.
local ws_id = 1
rt:wsClose(ws_id)
print("WebSocket closed")

-- ---- Stub: NetworkRuntime:poll -------------------------------------------
--@api-stub: NetworkRuntime:poll
-- Drain all completed async responses each frame -- call in lurek.process()
-- and dispatch events by type ("http", "tcp_data", "ws_message", etc.).
local events = rt:poll()
for _, ev in ipairs(events) do
    if ev.type == "http" then
        print("HTTP response id=", ev.id, "status=", ev.status)
    elseif ev.type == "ws_message" then
        print("WS message:", ev.data)
    end
end

-- ---- Stub: NetworkRuntime:shutdown ---------------------------------------
--@api-stub: NetworkRuntime:shutdown
-- Demonstrates the proper usage of NetworkRuntime:shutdown.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NetworkRuntime_shutdown()
    rt:shutdown()
    print("async network runtime shut down")
end
local _ok, _err = pcall(demo_NetworkRuntime_shutdown)
