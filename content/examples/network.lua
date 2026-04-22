-- content/examples/network.lua
-- love2d-style usage snippets for the lurek.network API (38 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/network.lua

-- ── lurek.network.* functions ──

--@api-stub: lurek.network.newHost
-- Creates a new network host bound to the given address.
-- Build once at startup; reuse across frames.
local host = lurek.network.newHost({ x = 0, y = 0 })
print("created", host)
return host

--@api-stub: lurek.network.newServer
-- Creates a server host that binds to a port and accepts connections.
-- Build once at startup; reuse across frames.
local server = lurek.network.newServer({ x = 0, y = 0 })
print("created", server)
return server

--@api-stub: lurek.network.newClient
-- Creates a client host that connects to a remote server.
-- Build once at startup; reuse across frames.
local client = lurek.network.newClient({ x = 0, y = 0 })
print("created", client)
return client

--@api-stub: lurek.network.newRuntime
-- Creates a background network runtime for async HTTP, TCP, and WebSocket.
-- Build once at startup; reuse across frames.
local runtime = lurek.network.newRuntime()
print("created", runtime)
return runtime

--@api-stub: lurek.network.pack
-- Serializes a Lua value to a binary MessagePack string.
-- See the module spec for detailed semantics.
local result = lurek.network.pack(value)
print("pack:", result)
return result

--@api-stub: lurek.network.unpack
-- Deserializes a MessagePack binary string back to a Lua value.
-- See the module spec for detailed semantics.
local result = lurek.network.unpack({ x = 0, y = 0 })
print("unpack:", result)
return result

--@api-stub: lurek.network.createLobby
-- Creates a LobbyInfo record and broadcasts it once on the local network.
-- Build once at startup; reuse across frames.
local createlobby = lurek.network.createLobby("main", port, 10, max_players)
print("created", createlobby)
return createlobby

--@api-stub: lurek.network.discoverLobbies
-- Listens for LAN lobby announcements for `timeout_ms` milliseconds (default 500).
-- See the module spec for detailed semantics.
local result = lurek.network.discoverLobbies(timeout_ms)
print("discoverLobbies:", result)
return result

--@api-stub: lurek.network.syncEntity
-- Convenience helper: packs an entity snapshot and broadcasts it to all peers.
-- See the module spec for detailed semantics.
local result = lurek.network.syncEntity()
print("syncEntity:", result)
return result

-- ── NetworkHost methods ──

--@api-stub: NetworkHost:service
-- Polls the network for one event, returning an event table or nil.
-- See the module spec for detailed semantics.
local networkHost = lurek.network.newNetworkHost()
networkHost:service()
print("NetworkHost:service done")

--@api-stub: NetworkHost:flush
-- Flushes all pending sends immediately.
-- See the module spec for detailed semantics.
local networkHost = lurek.network.newNetworkHost()
networkHost:flush()
print("NetworkHost:flush done")

--@api-stub: NetworkHost:resetPeer
-- Resets a peer connection immediately without notifying the remote side.
-- Pair with the matching constructor to free resources.
local networkHost = lurek.network.newNetworkHost()
networkHost:resetPeer(1)
-- networkHost is now released
print("ok")

--@api-stub: NetworkHost:ping
-- Sends a ping to a peer to measure round-trip time.
-- See the module spec for detailed semantics.
local networkHost = lurek.network.newNetworkHost()
networkHost:ping(1)
print("NetworkHost:ping done")

--@api-stub: NetworkHost:getRoundTripTime
-- Returns the round-trip time estimate for a peer in milliseconds.
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getRoundTripTime(1)
print("NetworkHost:getRoundTripTime ->", value)

--@api-stub: NetworkHost:getPeerState
-- Returns the connection state of a peer as a string.
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getPeerState(1)
print("NetworkHost:getPeerState ->", value)

--@api-stub: NetworkHost:getPeerAddress
-- Returns the remote address of a peer, or nil if unavailable.
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getPeerAddress(1)
print("NetworkHost:getPeerAddress ->", value)

--@api-stub: NetworkHost:getAddress
-- Returns the local bind address as a string.
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getAddress()
print("NetworkHost:getAddress ->", value)

--@api-stub: NetworkHost:getPeerLimit
-- Returns the maximum number of peer slots.
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getPeerLimit()
print("NetworkHost:getPeerLimit ->", value)

--@api-stub: NetworkHost:getChannelLimit
-- Returns the maximum number of channels per connection.
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getChannelLimit()
print("NetworkHost:getChannelLimit ->", value)

--@api-stub: NetworkHost:setChannelLimit
-- Sets the channel limit for future connections.
-- Apply at startup or in response to user input.
local networkHost = lurek.network.newNetworkHost()
networkHost:setChannelLimit(limit)
print("NetworkHost:setChannelLimit applied")

--@api-stub: NetworkHost:getBandwidthLimit
-- Returns the bandwidth limits as a table with incoming and outgoing fields.
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getBandwidthLimit()
print("NetworkHost:getBandwidthLimit ->", value)

--@api-stub: NetworkHost:getConnectedPeerCount
-- Returns the number of currently connected peers.
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getConnectedPeerCount()
print("NetworkHost:getConnectedPeerCount ->", value)

--@api-stub: NetworkHost:getConnectedPeerIds
-- Returns a table of connected peer IDs.
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getConnectedPeerIds()
print("NetworkHost:getConnectedPeerIds ->", value)

--@api-stub: NetworkHost:getPeerStats
-- Returns a statistics table for a peer.
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getPeerStats(1)
print("NetworkHost:getPeerStats ->", value)

--@api-stub: NetworkHost:destroy
-- Destroys the host, closing the underlying socket.
-- Pair with the matching constructor to free resources.
local networkHost = lurek.network.newNetworkHost()
networkHost:destroy()
-- networkHost is now released
print("ok")

--@api-stub: NetworkHost:isDestroyed
-- Returns true if the host has been destroyed.
-- Use as a guard inside lurek.update or event handlers.
local networkHost = lurek.network.newNetworkHost()
if networkHost:isDestroyed() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: NetworkHost:getRole
-- Returns the multiplayer role of this host ("server", "client", or "host").
-- Cheap to call; safe inside callbacks.
local networkHost = lurek.network.newNetworkHost()  -- or your existing handle
local value = networkHost:getRole()
print("NetworkHost:getRole ->", value)

--@api-stub: NetworkHost:isServer
-- Returns true if this host was created as a server.
-- Use as a guard inside lurek.update or event handlers.
local networkHost = lurek.network.newNetworkHost()
if networkHost:isServer() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: NetworkHost:isClient
-- Returns true if this host was created as a client.
-- Use as a guard inside lurek.update or event handlers.
local networkHost = lurek.network.newNetworkHost()
if networkHost:isClient() then print("yes") end
-- swap the constructor for your real handle
print("ok")

-- ── NetworkRuntime methods ──

--@api-stub: NetworkRuntime:httpRequest
-- Sends an HTTP request asynchronously.
-- See the module spec for detailed semantics.
local networkRuntime = lurek.network.newNetworkRuntime()
networkRuntime:httpRequest({ x = 0, y = 0 })
print("NetworkRuntime:httpRequest done")

--@api-stub: NetworkRuntime:tcpConnect
-- Opens a TCP connection to a remote address.
-- See the module spec for detailed semantics.
local networkRuntime = lurek.network.newNetworkRuntime()
networkRuntime:tcpConnect(addr)
print("NetworkRuntime:tcpConnect done")

--@api-stub: NetworkRuntime:tcpSend
-- Sends data over a TCP connection.
-- See the module spec for detailed semantics.
local networkRuntime = lurek.network.newNetworkRuntime()
networkRuntime:tcpSend(1, { x = 0, y = 0 })
print("NetworkRuntime:tcpSend done")

--@api-stub: NetworkRuntime:tcpClose
-- Closes the TCP connection identified by the given connection handle.
-- See the module spec for detailed semantics.
local networkRuntime = lurek.network.newNetworkRuntime()
networkRuntime:tcpClose(1)
print("NetworkRuntime:tcpClose done")

--@api-stub: NetworkRuntime:wsConnect
-- Opens a WebSocket connection.
-- See the module spec for detailed semantics.
local networkRuntime = lurek.network.newNetworkRuntime()
networkRuntime:wsConnect("https://example.com")
print("NetworkRuntime:wsConnect done")

--@api-stub: NetworkRuntime:wsSend
-- Sends a text message over a WebSocket connection.
-- See the module spec for detailed semantics.
local networkRuntime = lurek.network.newNetworkRuntime()
networkRuntime:wsSend(1, { x = 0, y = 0 })
print("NetworkRuntime:wsSend done")

--@api-stub: NetworkRuntime:wsClose
-- Closes a WebSocket connection.
-- See the module spec for detailed semantics.
local networkRuntime = lurek.network.newNetworkRuntime()
networkRuntime:wsClose(1)
print("NetworkRuntime:wsClose done")

--@api-stub: NetworkRuntime:poll
-- Polls for completed async responses (HTTP, TCP events, WebSocket events).
-- See the module spec for detailed semantics.
local networkRuntime = lurek.network.newNetworkRuntime()
networkRuntime:poll()
print("NetworkRuntime:poll done")

--@api-stub: NetworkRuntime:shutdown
-- Shuts down the background network thread.
-- See the module spec for detailed semantics.
local networkRuntime = lurek.network.newNetworkRuntime()
networkRuntime:shutdown()
print("NetworkRuntime:shutdown done")

