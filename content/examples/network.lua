-- examples/network.lua
-- Full networking toolkit for multiplayer games
-- API: lurek.network
--
-- Layer 1: ENet reliable UDP transport (server/client/host)
-- Layer 2: HTTP, TCP, WebSocket via background NetworkRuntime
-- Layer 3: MessagePack serialization (pack/unpack)
-- Layer 4: Lunasome libraries (rpc, lobby, netstate) in content/library/
--
-- NOTE: lurek.network requires the network module enabled in conf.lua
function lurek.conf(t)
t.modules.network = true
end

--------------------------------------------------------------------------------
-- Creating a host
--------------------------------------------------------------------------------

-- Server: bind to a fixed port, accept up to 16 peers on 2 channels
local server = lurek.network.newHost({
    addr         = "0.0.0.0:27015",   -- bind address (host:port)
    peers        = 16,                 -- max simultaneous peers
    channels     = 2,                  -- channel count (default 1)
    inBandwidth  = 0,                  -- 0 = unlimited
    outBandwidth = 0,
})

-- Client: bind to any ephemeral port (no addr required)
local client = lurek.network.newHost({})
-- Or with a specific source address:
local client = lurek.network.newHost({ addr = "0.0.0.0:0" })

--------------------------------------------------------------------------------
-- Connecting (client side)
--------------------------------------------------------------------------------

-- connect(addr, channels?, data?) → peer_id
local peer_id = client:connect("127.0.0.1:27015", 2, 0)
-- peer_id is the local handle for this connection

--------------------------------------------------------------------------------
-- The event loop
--------------------------------------------------------------------------------

-- service() → event table or nil (non-blocking poll for ONE event)
-- Call per-frame inside lurek.process(dt)

lurek.process = function(dt)
    -- Server event pump
    local ev = server:service()
    while ev ~= nil do
        if ev.type == "connect" then
            print("peer connected:", ev.peer_id, "data:", ev.data)

        elseif ev.type == "disconnect" then
            print("peer disconnected:", ev.peer_id, "data:", ev.data)

        elseif ev.type == "receive" then
            -- ev.peer_id    — which peer sent it
            -- ev.channel_id — which channel (0-based)
            -- ev.data       — Lua string payload
            print("received from", ev.peer_id, "on ch", ev.channel_id, ":", ev.data)
        end

        ev = server:service()  -- poll next
    end

    -- Client event pump
    local cev = client:service()
    while cev ~= nil do
        if cev.type == "connect" then
            print("connected to server, peer_id =", cev.peer_id)
        elseif cev.type == "receive" then
            print("got from server:", cev.data)
        end
        cev = client:service()
    end
end

--------------------------------------------------------------------------------
-- Sending messages
--------------------------------------------------------------------------------

-- send(peer_id, channel_id, data_string, reliable?)
-- reliable defaults to true
server:send(peer_id, 0, "Hello, client!", true)
server:send(peer_id, 1, "Fast channel", false)   -- unreliable (channel 1)

-- broadcast(channel_id, data_string, reliable?) → sends to ALL connected peers
server:broadcast(0, "Hello everyone!", true)

-- Flush all pending sends immediately (normally automatic at frame end)
server:flush()

--------------------------------------------------------------------------------
-- Disconnecting
--------------------------------------------------------------------------------

-- Graceful: waits for pending packets to arrive, notifies remote side
server:disconnect(peer_id)              -- with 0 data
server:disconnect(peer_id, 42)          -- with data code

-- Immediate: no notification to remote
server:disconnectNow(peer_id, 0)

-- Deferred: notified after all queued outbound packets are sent
server:disconnectLater(peer_id, 0)

-- Reset: hard reset (no remote notification, no queued flush)
server:resetPeer(peer_id)

--------------------------------------------------------------------------------
-- Peer inspection
--------------------------------------------------------------------------------

-- Ping a peer to update RTT estimate
client:ping(peer_id)

local rtt = client:getRoundTripTime(peer_id)  -- milliseconds (number)
local state = server:getPeerState(peer_id)    -- "connected" | "disconnected" | ...
local addr  = server:getPeerAddress(peer_id)  -- "192.168.1.5:49152" or nil

-- Local bind address
local localAddr = server:getAddress()         -- "0.0.0.0:27015"

--------------------------------------------------------------------------------
-- Capacity and limits
--------------------------------------------------------------------------------

local peerLimit = server:getPeerLimit()       -- max peers
local chanLimit = server:getChannelLimit()    -- channels per peer
server:setChannelLimit(4)

local bw = server:getBandwidthLimit()
-- bw.incoming, bw.outgoing (bytes/sec, 0=unlimited)
server:setBandwidthLimit(128000, 64000)           -- 128 KB/s in, 64 KB/s out
server:setBandwidthLimit()                         -- restore unlimited

-- Count of currently connected peers
local n = server:getConnectedPeerCount()
local ids = server:getConnectedPeerIds()          -- table of peer_id integers
for _, pid in ipairs(ids) do
    print("connected:", pid)
end

--------------------------------------------------------------------------------
-- Peer statistics
--------------------------------------------------------------------------------

local stats = server:getPeerStats(peer_id)
-- stats.round_trip_time          — average RTT in ms
-- stats.round_trip_time_variance — RTT variance
-- stats.packets_sent             — total packets sent
-- stats.packets_lost             — total packets lost
-- stats.packet_loss              — packet loss rate (0-65536 = 0.0-100%)
-- stats.incoming_bandwidth       — bytes/sec received
-- stats.outgoing_bandwidth       — bytes/sec sent
-- stats.incoming_data_total      — total bytes received
-- stats.outgoing_data_total      — total bytes sent

local loss_pct = stats.packet_loss / 65536 * 100
print(string.format("RTT: %.1f ms | Loss: %.1f%% | Sent: %d",
    stats.round_trip_time, loss_pct, stats.packets_sent))

--------------------------------------------------------------------------------
-- Host lifecycle
--------------------------------------------------------------------------------

-- Destroy the host (closes the underlying socket)
server:destroy()
local gone = server:isDestroyed()   -- true

-- Good practice in luna cleanup:
lurek.quit = function()
    if not client:isDestroyed() then
        client:disconnect(peer_id)
        client:flush()
        client:destroy()
    end
    if not server:isDestroyed() then
        server:destroy()
    end
end

--------------------------------------------------------------------------------
-- Typical game architecture
--------------------------------------------------------------------------------

-- Server-authoritative pattern
local HOST_PORT = 27015

local net_server = nil
local net_client = nil
local my_peer_id = nil

local function startServer()
    net_server = lurek.network.newHost({ addr = "0.0.0.0:" .. HOST_PORT, peers = 8, channels = 2 })
    print("Server listening on :" .. HOST_PORT)
end

local function startClient(host_ip)
    net_client = lurek.network.newHost({})
    my_peer_id = net_client:connect(host_ip .. ":" .. HOST_PORT, 2)
    print("Connecting to", host_ip)
end

local function pumpServer()
    if not net_server then return end
    local ev = net_server:service()
    while ev do
        if ev.type == "connect" then
            -- Send welcome message
            net_server:send(ev.peer_id, 0, "welcome:servertime=" .. lurek.time.getTime())
        elseif ev.type == "receive" then
            -- Echo back (simple test)
            net_server:broadcast(0, "echo:" .. ev.data)
        end
        ev = net_server:service()
    end
end

local function pumpClient()
    if not net_client then return end
    local ev = net_client:service()
    while ev do
        if ev.type == "connect" then
            print("Connected!")
        elseif ev.type == "receive" then
            print("Server says:", ev.data)
        elseif ev.type == "disconnect" then
            print("Disconnected from server")
        end
        ev = net_client:service()
    end
end

lurek.process = function(dt)
    pumpServer()
    pumpClient()
end

--------------------------------------------------------------------------------
-- NEW: Server / Client convenience constructors
--------------------------------------------------------------------------------

-- newServer: binds to a port, role = "server"
local game_server = lurek.network.newServer({ port = 27015, peers = 16, channels = 2 })
print("Server role:", game_server:getRole())   -- "server"
print("Is server?", game_server:isServer())    -- true

-- newClient: binds ephemeral port, connects to server, role = "client"
-- local game_client = lurek.network.newClient({ addr = "127.0.0.1:27015", channels = 2 })
-- print("Client role:", game_client:getRole()) -- "client"
-- print("Is client?", game_client:isClient())  -- true

game_server:destroy()

--------------------------------------------------------------------------------
-- NEW: MessagePack serialization (pack / unpack)
--------------------------------------------------------------------------------

-- lurek.network.pack(value) → binary string (MessagePack)
-- lurek.network.unpack(data) → Lua value

-- Pack a table
local msg = {
    type = "move",
    x = 100.5,
    y = 200.5,
    id = 42,
    tags = { "player", "fast" },
}
local packed = lurek.network.pack(msg)
print("Packed size:", #packed, "bytes")   -- ~30 bytes (vs ~100 for JSON)

-- Unpack back to Lua
local unpacked = lurek.network.unpack(packed)
print("Type:", unpacked.type, "X:", unpacked.x, "ID:", unpacked.id)

-- Pack primitives
local p1 = lurek.network.pack(42)
local p2 = lurek.network.pack("hello")
local p3 = lurek.network.pack(true)
local p4 = lurek.network.pack(nil)

-- Combined with ENet:
-- server:send(peer_id, 0, lurek.network.pack(gamestate), true)
-- local state = lurek.network.unpack(ev.data)

--------------------------------------------------------------------------------
-- NEW: Background NetworkRuntime (HTTP, TCP, WebSocket)
--------------------------------------------------------------------------------

-- All async I/O runs on a dedicated background thread.
-- Main thread polls for completed responses each frame.

local rt = lurek.network.newRuntime()

-- HTTP GET (returns request ID)
local req1 = rt:httpGet("https://api.example.com/version")

-- HTTP POST
local req2 = rt:httpPost("https://api.example.com/score",
    lurek.network.pack({ player = "Alice", score = 9001 }),
    { ["Content-Type"] = "application/msgpack" }
)

-- Full HTTP request with options
local req3 = rt:httpRequest({
    method  = "PUT",
    url     = "https://api.example.com/state",
    headers = { ["Authorization"] = "Bearer token123" },
    body    = '{"active": true}',
    timeout = 10,
})

-- Poll for HTTP responses in process loop
lurek.process = function(dt)
    local events = rt:poll()
    for _, ev in ipairs(events) do
        if ev.type == "http" then
            print(string.format("HTTP %d → status=%d body=%s",
                ev.request_id, ev.status, ev.body))
            if ev.error then
                print("HTTP error:", ev.error)
            end
        end
    end
end

--------------------------------------------------------------------------------
-- NEW: TCP connections
--------------------------------------------------------------------------------

-- Connect to a TCP server
local tcp_id = rt:tcpConnect("game-server.example.com:9000")

-- Send data
rt:tcpSend(tcp_id, "HELLO\n")

-- Poll for TCP events
-- ev.type == "tcp"
-- ev.event: "connected", "data", "disconnected", "error"
-- ev.id: connection ID
-- ev.data: received bytes (for "data" events)

-- Close when done
rt:tcpClose(tcp_id)

--------------------------------------------------------------------------------
-- NEW: WebSocket connections
--------------------------------------------------------------------------------

-- Connect to a WebSocket server
local ws_id = rt:wsConnect("wss://game-server.example.com/ws")

-- Send a text message
rt:wsSend(ws_id, '{"action":"join","room":"lobby"}')

-- Poll for WebSocket events
-- ev.type == "websocket"
-- ev.event: "open", "text", "binary", "close", "error"
-- ev.id: connection ID
-- ev.data: message text/binary

-- Close
rt:wsClose(ws_id)

-- Shutdown the runtime (closes all connections)
rt:shutdown()

--------------------------------------------------------------------------------
-- NEW: Lunasome Libraries (content/library/)
--------------------------------------------------------------------------------

-- RPC Library
-- local RPC = require("library.rpc")
-- local rpc = RPC.new(host)
-- rpc:register("damage", function(peer_id, target, amount)
--     game:applyDamage(target, amount)
--     return true
-- end)
-- rpc:call(peer_id, "damage", "goblin_1", 25)
-- rpc:broadcast("chat", "Hello everyone!")
-- In process loop: rpc:poll()

-- Lobby Library
-- local Lobby = require("library.lobby")
-- local lobby = Lobby.new(server)
-- lobby:createRoom("Arena 1", { maxPlayers = 4 })
-- lobby:joinRoom("Arena 1")
-- lobby:setReady(true)
-- if lobby:isAllReady() then startGame() end
-- In process loop: lobby:poll()

-- NetState Library (state sync + turn-based)
-- local NetState = require("library.netstate")
-- local state = NetState.new(server, { turnBased = true })
-- state:set("score_p1", 100)
-- state:onChanged("score_p1", function(val, old, peer)
--     print("Score changed:", old, "→", val)
-- end)
-- state:setTurnOrder({ peer1, peer2 })
-- state:beginTurn()
-- In process loop: state:poll(); state:sync()

-- ─── maxPeers option ──────────────────────────────────────────────────────────
-- Preferred key is "maxPeers" ("peers" is the legacy alias).
local host = lurek.network.newHost({ port = 7777, maxPeers = 16 })
local server = lurek.network.newServer({ port = 9000, maxPeers = 32 })

