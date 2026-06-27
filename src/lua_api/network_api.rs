//! Registers the `lurek.network` Lua API for net values, rooms, stats, snapshots, and network event bridging.

use super::SharedState;
use crate::network::constants::{DEFAULT_CHANNELS, DEFAULT_PEERS, MAX_CHANNELS, MAX_PEERS};
use crate::network::host::{HostRole, NetworkEvent, NetworkHost, PeerStats};
use crate::network::message::NetValue;
use crate::network::netstate::LNetworkState;
use crate::network::rpc::LNetworkRpc;
use mlua::prelude::*;
use rusty_enet::PeerID;
use std::cell::RefCell;
use std::net::SocketAddr;
use std::rc::Rc;

fn guard_mod_network(state: &Rc<RefCell<SharedState>>) -> LuaResult<()> {
    state
        .borrow()
        .ensure_mod_api_allowed("network")
        .map_err(LuaError::external)
}

fn wrap_top_level_functions(
    lua: &Lua,
    table: &LuaTable,
    state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    let mut function_keys = Vec::new();
    for pair in table.clone().pairs::<LuaValue, LuaValue>() {
        let (key, value) = pair?;
        if matches!(value, LuaValue::Function(_)) {
            function_keys.push(key);
        }
    }
    for key in function_keys {
        let function = table.get::<_, LuaFunction>(key.clone())?;
        let function_key = lua.create_registry_value(function)?;
        let state = state.clone();
        let wrapper = lua.create_function(move |lua, args: LuaMultiValue| {
            guard_mod_network(&state)?;
            let function = lua.registry_value::<LuaFunction>(&function_key)?;
            function.call::<_, LuaMultiValue>(args)
        })?;
        table.set(key, wrapper)?;
    }
    Ok(())
}
/// Converts a network event into a Lua table with `type` and event fields.
fn event_to_table(lua: &Lua, ev: NetworkEvent) -> LuaResult<LuaTable<'_>> {
    let t = lua.create_table()?;
    match ev {
        NetworkEvent::Connect { peer_id, data } => {
            /// Performs the 'type' operation.
            t.set("type", "connect")?;
            /// Performs the 'peer_id' operation.
            t.set("peer_id", peer_id.0)?;
            /// Performs the 'data' operation.
            t.set("data", data)?;
        }
        NetworkEvent::Disconnect { peer_id, data } => {
            /// Performs the 'type' operation.
            t.set("type", "disconnect")?;
            /// Performs the 'peer_id' operation.
            t.set("peer_id", peer_id.0)?;
            /// Performs the 'data' operation.
            t.set("data", data)?;
        }
        NetworkEvent::Receive {
            peer_id,
            channel_id,
            data,
        } => {
            /// Performs the 'type' operation.
            t.set("type", "receive")?;
            /// Performs the 'peer_id' operation.
            t.set("peer_id", peer_id.0)?;
            /// Performs the 'channel_id' operation.
            t.set("channel_id", channel_id)?;
            /// Performs the 'data' operation.
            t.set("data", lua.create_string(&data)?)?;
        }
    }
    Ok(t)
}
/// Parses a socket address string for network host bindings.
fn parse_addr(s: &str) -> LuaResult<SocketAddr> {
    s.parse()
        .map_err(|_| LuaError::RuntimeError(format!("invalid address: {s}")))
}
/// Converts peer statistics into a Lua table.
fn stats_to_table(lua: &Lua, stats: PeerStats) -> LuaResult<LuaTable<'_>> {
    let t = lua.create_table()?;
    /// Performs the 'round_trip_time' operation.
    t.set("round_trip_time", stats.round_trip_time)?;
    /// Performs the 'round_trip_time_variance' operation.
    t.set("round_trip_time_variance", stats.round_trip_time_variance)?;
    /// Performs the 'packets_sent' operation.
    t.set("packets_sent", stats.packets_sent)?;
    /// Performs the 'packets_lost' operation.
    t.set("packets_lost", stats.packets_lost)?;
    /// Performs the 'packet_loss' operation.
    t.set("packet_loss", stats.packet_loss)?;
    /// Performs the 'incoming_bandwidth' operation.
    t.set("incoming_bandwidth", stats.incoming_bandwidth)?;
    /// Performs the 'outgoing_bandwidth' operation.
    t.set("outgoing_bandwidth", stats.outgoing_bandwidth)?;
    /// Performs the 'incoming_data_total' operation.
    t.set("incoming_data_total", stats.incoming_data_total)?;
    /// Performs the 'outgoing_data_total' operation.
    t.set("outgoing_data_total", stats.outgoing_data_total)?;
    Ok(t)
}
/// Converts lobby room metadata into a Lua table.
fn room_to_table<'lua>(
    lua: &'lua Lua,
    room: &crate::network::lobby::RoomInfo,
) -> LuaResult<LuaTable<'lua>> {
    let t = lua.create_table()?;
    /// The 'id' field value exposed to Lua scripts.
    t.set("id", room.id.clone())?;
    /// Performs the 'name' operation.
    t.set("name", room.name.clone())?;
    /// Performs the 'host' operation.
    t.set("host", room.host.clone())?;
    /// Performs the 'player_count' operation.
    t.set("player_count", room.player_count)?;
    /// Performs the 'max_players' operation.
    t.set("max_players", room.max_players)?;
    Ok(t)
}
/// Converts a Lua table into a network message value.
fn lua_table_to_netvalue(t: &LuaTable) -> LuaResult<NetValue> {
    if t.raw_get::<_, LuaValue>(1i64).is_ok()
        && !matches!(t.raw_get::<_, LuaValue>(1i64)?, LuaValue::Nil)
    {
        let mut arr = Vec::new();
        for pair in t.clone().sequence_values::<LuaValue>() {
            arr.push(lua_to_netvalue(&pair?)?);
        }
        Ok(NetValue::Array(arr))
    } else {
        let mut map = Vec::new();
        for pair in t.clone().pairs::<LuaValue, LuaValue>() {
            let (k, v) = pair?;
            let key_str = match &k {
                LuaValue::String(s) => s.to_str()?.to_string(),
                LuaValue::Integer(i) => i.to_string(),
                LuaValue::Number(n) => n.to_string(),
                _ => {
                    return Err(LuaError::RuntimeError(
                        "pack: map keys must be strings or numbers".into(),
                    ))
                }
            };
            map.push((key_str, lua_to_netvalue(&v)?));
        }
        Ok(NetValue::Map(map))
    }
}
/// Converts a supported Lua value into a network message value.
fn lua_to_netvalue(val: &LuaValue) -> LuaResult<NetValue> {
    match val {
        LuaValue::Nil => Ok(NetValue::Nil),
        LuaValue::Boolean(b) => Ok(NetValue::Bool(*b)),
        LuaValue::Integer(i) => Ok(NetValue::Integer(*i)),
        LuaValue::Number(n) => Ok(NetValue::Float(*n)),
        LuaValue::String(s) => Ok(NetValue::String(s.to_str()?.to_string())),
        LuaValue::Table(t) => lua_table_to_netvalue(t),
        _ => Err(LuaError::RuntimeError(format!(
            "pack: unsupported type: {}",
            val.type_name()
        ))),
    }
}
/// Converts a network message value back into a Lua value.
fn netvalue_to_lua<'lua>(lua: &'lua Lua, val: &NetValue) -> LuaResult<LuaValue<'lua>> {
    match val {
        NetValue::Nil => Ok(LuaValue::Nil),
        NetValue::Bool(b) => Ok(LuaValue::Boolean(*b)),
        NetValue::Integer(i) => Ok(LuaValue::Integer(*i)),
        NetValue::Float(f) => Ok(LuaValue::Number(*f)),
        NetValue::String(s) => Ok(LuaValue::String(lua.create_string(s)?)),
        NetValue::Array(arr) => {
            let t = lua.create_table()?;
            for (i, v) in arr.iter().enumerate() {
                t.set(i + 1, netvalue_to_lua(lua, v)?)?;
            }
            Ok(LuaValue::Table(t))
        }
        NetValue::Map(map) => {
            let t = lua.create_table()?;
            for (k, v) in map {
                t.set(k.as_str(), netvalue_to_lua(lua, v)?)?;
            }
            Ok(LuaValue::Table(t))
        }
    }
}
/// Converts a Lua table to an EntitySnapshot.
fn lua_to_entity_snapshot(t: &LuaTable) -> LuaResult<crate::network::net_sync::EntitySnapshot> {
    Ok(crate::network::net_sync::EntitySnapshot {
        id: t.get("id")?,
        tick: t.get("tick")?,
        x: t.get("x")?,
        y: t.get("y")?,
        vx: t.get("vx")?,
        vy: t.get("vy")?,
    })
}
/// Converts an EntitySnapshot to a Lua table.
fn entity_snapshot_to_lua<'lua>(
    lua: &'lua Lua,
    es: &crate::network::net_sync::EntitySnapshot,
) -> LuaResult<LuaTable<'lua>> {
    let t = lua.create_table()?;
    t.set("id", es.id)?;
    t.set("tick", es.tick)?;
    t.set("x", es.x as f64)?;
    t.set("y", es.y as f64)?;
    t.set("vx", es.vx as f64)?;
    t.set("vy", es.vy as f64)?;
    Ok(t)
}
/// Converts a Lua table to a SyncSnapshot.
fn lua_to_sync_snapshot(t: &LuaTable) -> LuaResult<crate::network::net_sync::SyncSnapshot> {
    let type_str: String = t.get("type")?;
    match type_str.as_str() {
        "full" => lua_to_full_sync_snapshot(t),
        "delta" => lua_to_delta_sync_snapshot(t),
        "corrective" => lua_to_corrective_sync_snapshot(t),
        _ => Err(LuaError::RuntimeError(format!(
            "unknown snapshot type: {type_str}"
        ))),
    }
}

fn lua_entity_snapshot_vec(
    t: LuaTable,
) -> LuaResult<Vec<crate::network::net_sync::EntitySnapshot>> {
    let mut entities = Vec::new();
    for ent in t.sequence_values::<LuaTable>() {
        entities.push(lua_to_entity_snapshot(&ent?)?);
    }
    Ok(entities)
}

fn lua_to_full_sync_snapshot(t: &LuaTable) -> LuaResult<crate::network::net_sync::SyncSnapshot> {
    Ok(crate::network::net_sync::SyncSnapshot::Full {
        tick: t.get("tick")?,
        entities: lua_entity_snapshot_vec(t.get("entities")?)?,
    })
}

fn lua_to_corrective_sync_snapshot(
    t: &LuaTable,
) -> LuaResult<crate::network::net_sync::SyncSnapshot> {
    Ok(crate::network::net_sync::SyncSnapshot::Corrective {
        tick: t.get("tick")?,
        entities: lua_entity_snapshot_vec(t.get("entities")?)?,
    })
}

fn lua_to_delta_sync_snapshot(t: &LuaTable) -> LuaResult<crate::network::net_sync::SyncSnapshot> {
    let removals_table: LuaTable = t.get("removals")?;
    let mut removals = Vec::new();
    for id in removals_table.sequence_values::<u32>() {
        removals.push(id?);
    }
    Ok(crate::network::net_sync::SyncSnapshot::Delta {
        tick: t.get("tick")?,
        base_tick: t.get("base_tick")?,
        updates: lua_entity_snapshot_vec(t.get("updates")?)?,
        removals,
    })
}
/// Converts a SyncSnapshot to a Lua table.
fn sync_snapshot_to_lua<'lua>(
    lua: &'lua Lua,
    snap: &crate::network::net_sync::SyncSnapshot,
) -> LuaResult<LuaTable<'lua>> {
    let t = lua.create_table()?;
    match snap {
        crate::network::net_sync::SyncSnapshot::Full { tick, entities } => {
            t.set("type", "full")?;
            t.set("tick", *tick)?;
            let ents_table = lua.create_table()?;
            for (i, ent) in entities.iter().enumerate() {
                ents_table.set(i + 1, entity_snapshot_to_lua(lua, ent)?)?;
            }
            t.set("entities", ents_table)?;
        }
        crate::network::net_sync::SyncSnapshot::Delta {
            tick,
            base_tick,
            updates,
            removals,
        } => {
            t.set("type", "delta")?;
            t.set("tick", *tick)?;
            t.set("base_tick", *base_tick)?;
            let ups_table = lua.create_table()?;
            for (i, ent) in updates.iter().enumerate() {
                ups_table.set(i + 1, entity_snapshot_to_lua(lua, ent)?)?;
            }
            t.set("updates", ups_table)?;
            let rems_table = lua.create_table()?;
            for (i, &id) in removals.iter().enumerate() {
                rems_table.set(i + 1, id)?;
            }
            t.set("removals", rems_table)?;
        }
        crate::network::net_sync::SyncSnapshot::Corrective { tick, entities } => {
            t.set("type", "corrective")?;
            t.set("tick", *tick)?;
            let ents_table = lua.create_table()?;
            for (i, ent) in entities.iter().enumerate() {
                ents_table.set(i + 1, entity_snapshot_to_lua(lua, ent)?)?;
            }
            t.set("entities", ents_table)?;
        }
    }
    Ok(t)
}
/// Returns the Lua string for a network host role.
fn role_to_string(role: HostRole) -> &'static str {
    match role {
        HostRole::Server => "server",
        HostRole::Client => "client",
        HostRole::Host => "host",
    }
}
/// Lua-side wrapper for a network host.
pub struct LuaNetworkHost {
    /// Wrapped host inside interior mutability for Lua method calls.
    inner: RefCell<NetworkHost>,
}
/// Provides Lua methods for host service, peer connections, sending, statistics, and lifecycle.
impl LuaUserData for LuaNetworkHost {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- service --
        /// Polls the host for one network event.
        /// @return | table | Event table, or nil when no event is available.
        /// @field | type | string | Event type (connect, disconnect, receive).
        /// @field | peer_id | integer | Peer id.
        /// @field | data | any | Connection data or receive payload.
        /// @field | channel_id | integer? | Channel index for receive events.
        methods.add_method("service", |lua, this, ()| {
            match this
                .inner
                .borrow_mut()
                .service()
                .map_err(LuaError::external)?
            {
                Some(ev) => Ok(LuaValue::Table(event_to_table(lua, ev)?)),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- connect --
        /// Connects to a remote address. This method is available to Lua scripts.
        /// @param | addr_str | string | Remote socket address.
        /// @param | channels | integer? | Optional channel count, defaulting to 1.
        /// @param | data | integer? | Optional connection data, defaulting to 0.
        /// @return | integer | Peer id.
        methods.add_method(
            "connect",
            |_, this, (addr_str, channels, data): (String, Option<usize>, Option<u32>)| {
                let addr = parse_addr(&addr_str)?;
                Ok(this
                    .inner
                    .borrow_mut()
                    .connect(addr, channels.unwrap_or(1), data.unwrap_or(0))
                    .map_err(LuaError::external)?
                    .0)
            },
        );
        // -- send --
        /// Sends bytes to a peer on a channel. This method is available to Lua scripts.
        /// @param | peer_id | integer | Peer id.
        /// @param | channel_id | integer | Channel id.
        /// @param | data | string | Binary payload string.
        /// @param | reliable | boolean? | Optional reliable flag, defaulting to true.
        methods.add_method("send", |_, this, (peer_id, channel_id, data, reliable): (usize, u8, LuaString, Option<bool>)| {
                this.inner
                    .borrow_mut()
                    .send_bytes(PeerID(peer_id), channel_id, data.as_bytes(), reliable.unwrap_or(true))
                    .map_err(LuaError::external)
            },
        );
        // -- broadcast --
        /// Broadcasts bytes to all connected peers on a channel.
        /// @param | channel_id | integer | Channel id.
        /// @param | data | string | Binary payload string.
        /// @param | reliable | boolean? | Optional reliable flag, defaulting to true.
        methods.add_method(
            "broadcast",
            |_, this, (channel_id, data, reliable): (u8, LuaString, Option<bool>)| {
                this.inner
                    .borrow_mut()
                    .broadcast_bytes(channel_id, data.as_bytes(), reliable.unwrap_or(true))
                    .map_err(LuaError::external)
            },
        );
        // -- flush --
        /// Flushes queued outgoing network packets.
        methods.add_method("flush", |_, this, ()| {
            this.inner.borrow_mut().flush().map_err(LuaError::external)
        });
        // -- disconnect --
        /// Requests a graceful peer disconnect.
        /// @param | peer_id | integer | Peer id.
        /// @param | data | integer? | Optional disconnect data.
        methods.add_method(
            "disconnect",
            |_, this, (peer_id, data): (usize, Option<u32>)| {
                this.inner
                    .borrow_mut()
                    .disconnect(PeerID(peer_id), data.unwrap_or(0))
                    .map_err(LuaError::external)
            },
        );
        // -- disconnectNow --
        /// Disconnects a peer immediately. This method is available to Lua scripts.
        /// @param | peer_id | integer | Peer id.
        /// @param | data | integer? | Optional disconnect data.
        methods.add_method(
            "disconnectNow",
            |_, this, (peer_id, data): (usize, Option<u32>)| {
                this.inner
                    .borrow_mut()
                    .disconnect_now(PeerID(peer_id), data.unwrap_or(0))
                    .map_err(LuaError::external)
            },
        );
        // -- disconnectLater --
        /// Schedules a peer disconnect after pending packets.
        /// @param | peer_id | integer | Peer id.
        /// @param | data | integer? | Optional disconnect data.
        methods.add_method(
            "disconnectLater",
            |_, this, (peer_id, data): (usize, Option<u32>)| {
                this.inner
                    .borrow_mut()
                    .disconnect_later(PeerID(peer_id), data.unwrap_or(0))
                    .map_err(LuaError::external)
            },
        );
        // -- resetPeer --
        /// Resets a peer connection. This method is available to Lua scripts.
        /// @param | peer_id | integer | Peer id.
        methods.add_method("resetPeer", |_, this, peer_id: usize| {
            this.inner
                .borrow_mut()
                .reset_peer(PeerID(peer_id))
                .map_err(LuaError::external)
        });
        // -- ping --
        /// Sends a ping to a peer. This method is available to Lua scripts.
        /// @param | peer_id | integer | Peer id.
        methods.add_method("ping", |_, this, peer_id: usize| {
            this.inner
                .borrow_mut()
                .ping(PeerID(peer_id))
                .map_err(LuaError::external)
        });
        // -- getRoundTripTime --
        /// Returns peer round trip time in milliseconds.
        /// @param | peer_id | integer | Peer id.
        /// @return | number | Round trip time in milliseconds.
        methods.add_method("getRoundTripTime", |_, this, peer_id: usize| {
            let rtt = this
                .inner
                .borrow()
                .round_trip_time(PeerID(peer_id))
                .map_err(LuaError::external)?;
            Ok(rtt.as_millis() as f64)
        });
        // -- getPeerState --
        /// Returns peer connection state. This method is available to Lua scripts.
        /// @param | peer_id | integer | Peer id.
        /// @return | string | Peer state string.
        methods.add_method("getPeerState", |_, this, peer_id: usize| {
            this.inner
                .borrow()
                .peer_state(PeerID(peer_id))
                .map_err(LuaError::external)
        });
        // -- getPeerAddress --
        /// Returns peer socket address when available.
        /// @param | peer_id | integer | Peer id.
        /// @return | string | Peer address, or nil when unavailable.
        methods.add_method("getPeerAddress", |_, this, peer_id: usize| {
            let addr = this
                .inner
                .borrow()
                .peer_address(PeerID(peer_id))
                .map_err(LuaError::external)?;
            Ok(addr.map(|a| a.to_string()))
        });
        // -- getAddress --
        /// Returns local host socket address.
        /// @return | string | Local socket address.
        methods.add_method("getAddress", |_, this, ()| {
            Ok(this.inner.borrow().local_address().to_string())
        });
        // -- getPeerLimit --
        /// Returns configured peer limit. This method is available to Lua scripts.
        /// @return | integer | Peer limit.
        methods.add_method("getPeerLimit", |_, this, ()| {
            this.inner.borrow().peer_limit().map_err(LuaError::external)
        });
        // -- getChannelLimit --
        /// Returns configured channel limit.
        /// @return | integer | Channel limit.
        methods.add_method("getChannelLimit", |_, this, ()| {
            this.inner
                .borrow()
                .channel_limit()
                .map_err(LuaError::external)
        });
        // -- setChannelLimit --
        /// Sets channel limit. This method is available to Lua scripts.
        /// @param | limit | integer | Channel limit.
        methods.add_method("setChannelLimit", |_, this, limit: usize| {
            this.inner
                .borrow_mut()
                .set_channel_limit(limit)
                .map_err(LuaError::external)
        });
        // -- getBandwidthLimit --
        /// Returns incoming and outgoing bandwidth limits.
        /// @return | table | Table with `incoming` and `outgoing` fields.
        /// @field | incoming | integer | Incoming bandwidth limit.
        /// @field | outgoing | integer | Outgoing bandwidth limit.
        methods.add_method("getBandwidthLimit", |lua, this, ()| {
            let (inc, out) = this
                .inner
                .borrow()
                .bandwidth_limit()
                .map_err(LuaError::external)?;
            let t = lua.create_table()?;
            /// Performs the 'incoming' operation.
            t.set("incoming", inc)?;
            /// Performs the 'outgoing' operation.
            t.set("outgoing", out)?;
            Ok(t)
        });
        // -- setBandwidthLimit --
        /// Sets incoming and outgoing bandwidth limits.
        /// @param | incoming | integer? | Optional incoming bandwidth limit.
        /// @param | outgoing | integer? | Optional outgoing bandwidth limit.
        methods.add_method(
            "setBandwidthLimit",
            |_, this, (incoming, outgoing): (Option<u32>, Option<u32>)| {
                this.inner
                    .borrow_mut()
                    .set_bandwidth_limit(incoming, outgoing)
                    .map_err(LuaError::external)
            },
        );
        // -- getConnectedPeerCount --
        /// Returns the number of currently connected peers.
        /// @return | integer | Connected peer count.
        methods.add_method("getConnectedPeerCount", |_, this, ()| {
            this.inner
                .borrow_mut()
                .connected_peer_count()
                .map_err(LuaError::external)
        });
        // -- getConnectedPeerIds --
        /// Returns an array of ids for all connected peers.
        /// @return | integer[] | Array table of peer ids.
        methods.add_method("getConnectedPeerIds", |_, this, ()| {
            let ids = this
                .inner
                .borrow_mut()
                .connected_peer_ids()
                .map_err(LuaError::external)?;
            let result: Vec<usize> = ids.into_iter().map(|id| id.0).collect();
            Ok(result)
        });
        // -- getPeerStats --
        /// Returns statistics for a peer. This method is available to Lua scripts.
        /// @param | peer_id | integer | Peer id.
        /// @return | table | Peer statistics table.
        /// @field | round_trip_time | number | Round-trip time in ms.
        /// @field | round_trip_time_variance | number | RTT variance.
        /// @field | packets_sent | integer | Packets sent.
        /// @field | packets_lost | integer | Packets lost.
        /// @field | packet_loss | number | Packet loss ratio.
        methods.add_method("getPeerStats", |lua, this, peer_id: usize| {
            let stats = this
                .inner
                .borrow()
                .peer_stats(PeerID(peer_id))
                .map_err(LuaError::external)?;
            stats_to_table(lua, stats)
        });
        // -- destroy --
        /// Destroys the network host and releases resources.
        methods.add_method("destroy", |_, this, ()| {
            this.inner.borrow_mut().destroy();
            Ok(())
        });
        // -- isDestroyed --
        /// Returns whether the network host is destroyed.
        /// @return | boolean | True when destroyed.
        methods.add_method("isDestroyed", |_, this, ()| {
            Ok(this.inner.borrow().is_destroyed())
        });
        // -- getRole --
        /// Returns host role string. This method is available to Lua scripts.
        /// @return | string | Role string.
        methods.add_method("getRole", |_, this, ()| {
            Ok(role_to_string(this.inner.borrow().role()))
        });
        // -- isServer --
        /// Returns whether this host has server role.
        /// @return | boolean | True when role is server.
        methods.add_method("isServer", |_, this, ()| {
            Ok(this.inner.borrow().role() == HostRole::Server)
        });
        // -- isClient --
        /// Returns whether this host has client role.
        /// @return | boolean | True when role is client.
        methods.add_method("isClient", |_, this, ()| {
            Ok(this.inner.borrow().role() == HostRole::Client)
        });
        // -- registerLease --
        /// Registers a reconnection lease for the given peer ID.
        /// @param | peer_id | integer | Peer ID.
        /// @param | timeout_secs | integer | Lease duration in seconds.
        /// @return | integer | Reconnection token.
        methods.add_method(
            "registerLease",
            |_, this, (peer_id, timeout_secs): (usize, u64)| {
                let token = this
                    .inner
                    .borrow_mut()
                    .register_lease(PeerID(peer_id), timeout_secs);
                Ok(token)
            },
        );
        // -- getLeasePeer --
        /// Retrieves the peer ID associated with a valid, non-expired lease token.
        /// @param | token | integer | Reconnection token.
        /// @return | integer | Original Peer ID, or nil if invalid or expired.
        methods.add_method("getLeasePeer", |_, this, token: u32| {
            Ok(this.inner.borrow().get_lease_peer(token).map(|p| p.0))
        });
        // -- renewLease --
        /// Renews an active lease token with a new duration.
        /// @param | token | integer | Reconnection token.
        /// @param | timeout_secs | integer | New lease duration in seconds.
        /// @return | boolean | True if successfully renewed, false otherwise.
        methods.add_method(
            "renewLease",
            |_, this, (token, timeout_secs): (u32, u64)| {
                Ok(this.inner.borrow_mut().renew_lease(token, timeout_secs))
            },
        );
        // -- clearLease --
        /// Removes a lease token immediately.
        /// @param | token | integer | Reconnection token.
        methods.add_method("clearLease", |_, this, token: u32| {
            this.inner.borrow_mut().clear_lease(token);
            Ok(())
        });
        // -- getMetrics --
        /// Returns global network host metrics.
        /// @return | table | Metrics table with connected_peers, average_rtt, average_packet_loss, total_packets_sent, total_packets_lost.
        methods.add_method("getMetrics", |lua, this, ()| {
            let (connected_peers, avg_rtt, avg_loss, total_sent, total_lost) = this
                .inner
                .borrow_mut()
                .get_global_metrics()
                .map_err(LuaError::external)?;
            let t = lua.create_table()?;
            t.set("connected_peers", connected_peers)?;
            t.set("average_rtt", avg_rtt)?;
            t.set("average_packet_loss", avg_loss)?;
            t.set("total_packets_sent", total_sent)?;
            t.set("total_packets_lost", total_lost)?;
            Ok(t)
        });
        /// Returns a string representation of the network host.
        /// @return | string | Debug string.
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            Ok(format!(
                "NetworkHost({})",
                this.inner.borrow().local_address()
            ))
        });
        // -- type --
        /// Returns the Lua-visible type name for this network host handle.
        /// @return | string | The string `LNetworkHost`.
        methods.add_method("type", |_, _, ()| Ok("LNetworkHost"));
        // -- typeOf --
        /// Returns whether this network host handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LNetworkHost` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LNetworkHost" || name == "LObject")
        });
    }
}
/// Registers the `lurek.network` module.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    /// Maximum allowed peers per host.
    tbl.set("MAX_PEERS", MAX_PEERS as u64)?;
    /// Default peer limit for new hosts.
    tbl.set("DEFAULT_PEERS", DEFAULT_PEERS as u64)?;
    /// Maximum allowed channels per host.
    tbl.set("MAX_CHANNELS", MAX_CHANNELS as u64)?;
    /// Default channel count for new hosts.
    tbl.set("DEFAULT_CHANNELS", DEFAULT_CHANNELS as u64)?;
    // -- newHost --
    /// Creates a network host from an options table.
    /// @param | opts | table | Options with `addr`, optional `maxPeers`/`peers`, `channels`, `inBandwidth`, and `outBandwidth`.
    /// @return | LNetworkHost | New network host handle.
    tbl.set(
        "newHost",
        lua.create_function(|_, opts: LuaTable| {
            let addr_str: String = opts
                .get::<_, String>("addr")
                .unwrap_or_else(|_| "0.0.0.0:0".to_string());
            let addr = parse_addr(&addr_str)?;
            let peers: Option<usize> = opts
                .get::<_, usize>("maxPeers")
                .ok()
                .or_else(|| opts.get("peers").ok());
            let host = NetworkHost::new(
                addr,
                peers,
                opts.get("channels").ok(),
                opts.get("inBandwidth").ok(),
                opts.get("outBandwidth").ok(),
            )
            .map_err(LuaError::external)?;
            Ok(LuaNetworkHost {
                inner: RefCell::new(host),
            })
        })?,
    )?;
    // -- newServer --
    /// Creates a server host from an options table.
    /// @param | opts | table | Options with required `port`, optional `maxPeers`/`peers`, and `channels`.
    /// @return | LNetworkHost | New server host handle.
    tbl.set(
        "newServer",
        lua.create_function(|_, opts: LuaTable| {
            let port: u16 = opts.get("port").map_err(|_| {
                LuaError::RuntimeError("newServer: 'port' field is required".into())
            })?;
            let peers: Option<usize> = opts
                .get::<_, usize>("maxPeers")
                .ok()
                .or_else(|| opts.get("peers").ok());
            let host = NetworkHost::create_server(port, peers, opts.get("channels").ok())
                .map_err(LuaError::external)?;
            Ok(LuaNetworkHost {
                inner: RefCell::new(host),
            })
        })?,
    )?;
    // -- newClient --
    /// Creates a client host and connects to an address.
    /// @param | opts | table | Options with required `addr`, optional `channels`, and `data`.
    /// @return | LNetworkHost | New client host handle.
    tbl.set(
        "newClient",
        lua.create_function(|_, opts: LuaTable| {
            let addr_str: String = opts.get("addr").map_err(|_| {
                LuaError::RuntimeError("newClient: 'addr' field is required".into())
            })?;
            let addr = parse_addr(&addr_str)?;
            let host =
                NetworkHost::create_client(addr, opts.get("channels").ok(), opts.get("data").ok())
                    .map_err(LuaError::external)?;
            Ok(LuaNetworkHost {
                inner: RefCell::new(host),
            })
        })?,
    )?;
    // -- pack --
    /// Packs a supported Lua value into a binary network message string.
    /// @param | value | any | Lua value to pack (table, number, string, or boolean).
    /// @return | string | Binary packed message.
    tbl.set(
        "pack",
        lua.create_function(|lua, value: LuaValue| {
            let net_val = lua_to_netvalue(&value)?;
            let bytes = crate::network::message::pack(&net_val).map_err(LuaError::external)?;
            lua.create_string(&bytes)
        })?,
    )?;
    // -- unpack --
    /// Unpacks a binary network message string into a Lua value.
    /// @param | data | string | Binary packed message.
    /// @return | table | Unpacked Lua value.
    /// @field | name | string | Lobby name.
    /// @field | host | string | Host address.
    /// @field | port | integer | Port number.
    /// @field | player_count | integer | Current player count.
    /// @field | max_players | integer | Maximum players allowed.
    tbl.set(
        "unpack",
        lua.create_function(|lua, data: LuaString| {
            let net_val =
                crate::network::message::unpack(data.as_bytes()).map_err(LuaError::external)?;
            netvalue_to_lua(lua, &net_val)
        })?,
    )?;
    // -- createLobby --
    /// Broadcasts lobby information and returns it as a table.
    /// @param | name | string | Lobby name.
    /// @param | port | integer | Lobby port.
    /// @param | player_count | integer? | Optional current player count, defaulting to 1.
    /// @param | max_players | integer? | Optional maximum players, defaulting to 8.
    /// @return | table | Lobby info table.
    /// @field | name | string | Lobby name.
    /// @field | host | string | Host address.
    /// @field | port | integer | Port number.
    /// @field | player_count | integer | Current player count.
    /// @field | max_players | integer | Maximum players allowed.
    tbl.set("createLobby", lua.create_function(
            |lua, (name, port, player_count, max_players): (String, u16, Option<u32>, Option<u32>)| {
                let info = crate::network::lobby::LobbyInfo {
                    name,
                    host: "0.0.0.0".to_string(),
                    port,
                    player_count: player_count.unwrap_or(1),
                    max_players: max_players.unwrap_or(8),
                };
                crate::network::lobby::broadcast_lobby(&info).map_err(LuaError::external)?;
                let t = lua.create_table()?;
                /// Performs the 'name' operation.
                t.set("name", info.name.clone())?;
                /// Performs the 'host' operation.
                t.set("host", info.host.clone())?;
                /// Performs the 'port' operation.
                t.set("port", info.port)?;
                /// Performs the 'player_count' operation.
                t.set("player_count", info.player_count)?;
                /// Performs the 'max_players' operation.
                t.set("max_players", info.max_players)?;
                Ok(t)
            },
        )?,
    )?;
    // -- discoverLobbies --
    /// Discovers broadcast lobbies. This function is exposed to Lua scripts.
    /// @param | timeout_ms | integer? | Optional timeout in milliseconds, defaulting to 500.
    /// @return | table | Array table of lobby info tables.
    /// @field | name | string | Lobby name.
    /// @field | host | string | Host address.
    /// @field | port | integer | Host port.
    /// @field | player_count | integer | Current player count.
    /// @field | max_players | integer | Maximum allowed players.
    tbl.set(
        "discoverLobbies",
        lua.create_function(|lua, timeout_ms: Option<u64>| {
            let lobbies = crate::network::lobby::discover_lobbies(timeout_ms.unwrap_or(500));
            let arr = lua.create_table()?;
            for (i, info) in lobbies.iter().enumerate() {
                let t = lua.create_table()?;
                /// Performs the 'name' operation.
                t.set("name", info.name.clone())?;
                /// Performs the 'host' operation.
                t.set("host", info.host.clone())?;
                /// Performs the 'port' operation.
                t.set("port", info.port)?;
                /// Performs the 'player_count' operation.
                t.set("player_count", info.player_count)?;
                /// Performs the 'max_players' operation.
                t.set("max_players", info.max_players)?;
                arr.set(i + 1, t)?;
            }
            Ok(arr)
        })?,
    )?;
    // -- createRoom --
    /// Creates a local room record. This function is exposed to Lua scripts.
    /// @param | name | string | Room name.
    /// @param | host | string | Host string.
    /// @param | max_players | integer? | Optional maximum players, defaulting to 8.
    /// @return | table | Room info table.
    /// @field | id | string | Room identifier.
    /// @field | name | string | Room name.
    /// @field | host | string | Host address.
    /// @field | player_count | integer | Current player count.
    /// @field | max_players | integer | Maximum allowed players.
    tbl.set(
        "createRoom",
        lua.create_function(
            |lua, (name, host, max_players): (String, String, Option<u32>)| {
                let room =
                    crate::network::lobby::create_room(&name, &host, max_players.unwrap_or(8));
                room_to_table(lua, &room)
            },
        )?,
    )?;
    // -- listRooms --
    /// Lists known local room records. This function is exposed to Lua scripts.
    /// @return | table | Array table of room info tables.
    /// @field | name | string | Room name.
    /// @field | host | string | Host address.
    /// @field | player_count | integer | Current player count.
    /// @field | max_players | integer | Maximum allowed players.
    tbl.set(
        "listRooms",
        lua.create_function(|lua, ()| {
            let rooms = crate::network::lobby::list_rooms();
            let out = lua.create_table()?;
            for (i, room) in rooms.iter().enumerate() {
                out.set(i + 1, room_to_table(lua, room)?)?;
            }
            Ok(out)
        })?,
    )?;
    // -- joinRoom --
    /// Joins a room by id when available. This function is exposed to Lua scripts.
    /// @param | id | string | Room id.
    /// @return | table | Room info table, or nil when missing.
    /// @field | id | string | Room id.
    /// @field | name | string | Room name.
    /// @field | host | string | Host address.
    /// @field | player_count | integer | Current player count.
    /// @field | max_players | integer | Maximum allowed players.
    tbl.set(
        "joinRoom",
        lua.create_function(
            |lua, id: String| match crate::network::lobby::join_room(&id) {
                Some(room) => Ok(LuaValue::Table(room_to_table(lua, &room)?)),
                None => Ok(LuaValue::Nil),
            },
        )?,
    )?;
    // -- leaveRoom --
    /// Leaves a room by id when available. This function is exposed to Lua scripts.
    /// @param | id | string | Room id.
    /// @return | table | Room info table, or nil when missing.
    /// @field | id | string | Room id.
    /// @field | name | string | Room name.
    /// @field | host | string | Host address.
    /// @field | player_count | integer | Current player count.
    /// @field | max_players | integer | Maximum allowed players.
    tbl.set(
        "leaveRoom",
        lua.create_function(
            |lua, id: String| match crate::network::lobby::leave_room(&id) {
                Some(room) => Ok(LuaValue::Table(room_to_table(lua, &room)?)),
                None => Ok(LuaValue::Nil),
            },
        )?,
    )?;
    // -- syncEntity --
    /// Broadcasts a packed entity sync payload through a network host.
    /// @param | host_ud | LNetworkHost | Network host handle.
    /// @param | entity_id | integer | Entity id.
    /// @param | data_tbl | table | Entity field table.
    /// @param | channel | integer? | Optional channel id, defaulting to 0.
    /// @param | reliable | boolean? | Optional reliable flag, defaulting to false.
    tbl.set(
        "syncEntity",
        lua.create_function(
            |_lua,
             (host_ud, entity_id, data_tbl, channel, reliable): (
                LuaAnyUserData,
                u32,
                LuaTable,
                Option<u8>,
                Option<bool>,
            )| {
                let host = host_ud.borrow_mut::<LuaNetworkHost>()?;
                let mut fields: Vec<(String, NetValue)> = Vec::new();
                for pair in data_tbl.pairs::<LuaValue, LuaValue>() {
                    let (k, v) = pair?;
                    let key = match &k {
                        LuaValue::String(s) => s.to_str()?.to_string(),
                        LuaValue::Integer(i) => i.to_string(),
                        _ => continue,
                    };
                    fields.push((key, lua_to_netvalue(&v)?));
                }
                let envelope = vec![
                    ("id".to_string(), NetValue::Integer(entity_id as i64)),
                    ("data".to_string(), NetValue::Map(fields)),
                ];
                let payload = crate::network::message::pack(&NetValue::Map(envelope))
                    .map_err(LuaError::external)?;
                host.inner
                    .borrow_mut()
                    .broadcast_bytes(channel.unwrap_or(0), &payload, reliable.unwrap_or(false))
                    .map_err(LuaError::external)?;
                Ok(())
            },
        )?,
    )?;
    // -- newRelayTicket --
    /// Creates an encoded relay ticket. This function is exposed to Lua scripts.
    /// @param | room_id | string | Room id.
    /// @param | peer_id | string | Peer id.
    /// @return | string | Encoded relay ticket.
    tbl.set(
        "newRelayTicket",
        lua.create_function(|_, (room_id, peer_id): (String, String)| {
            let ticket = crate::network::relay::RelayTicket { room_id, peer_id };
            Ok(crate::network::relay::encode_ticket(&ticket))
        })?,
    )?;
    // -- parseRelayTicket --
    /// Parses an encoded relay ticket. This function is exposed to Lua scripts.
    /// @param | token | string | Encoded relay ticket.
    /// @return | table | Ticket table, or nil when invalid.
    /// @field | room_id | string | Room identifier.
    /// @field | peer_id | string | Peer identifier.
    /// @field | id | integer | Id.
    /// @field | tick | integer | Tick number.
    /// @field | x | number | X.
    /// @field | y | number | Y.
    /// @field | vx | number | Velocity X.
    /// @field | vy | number | Velocity Y.
    tbl.set(
        "parseRelayTicket",
        lua.create_function(|lua, token: String| {
            match crate::network::relay::decode_ticket(&token) {
                Some(ticket) => {
                    let t = lua.create_table()?;
                    /// Performs the 'room_id' operation.
                    t.set("room_id", ticket.room_id)?;
                    /// Performs the 'peer_id' operation.
                    t.set("peer_id", ticket.peer_id)?;
                    Ok(LuaValue::Table(t))
                }
                None => Ok(LuaValue::Nil),
            }
        })?,
    )?;
    // -- makePunchProbe --
    /// Creates a relay punch probe payload for a peer id.
    /// @param | peer_id | string | Peer id.
    /// @return | string | Probe payload.
    tbl.set(
        "makePunchProbe",
        lua.create_function(|lua, peer_id: String| {
            lua.create_string(crate::network::relay::make_punch_probe(&peer_id))
        })?,
    )?;
    // -- parsePunchProbe --
    /// Parses a relay punch probe payload.
    /// @param | payload | string | Probe payload.
    /// @return | string | Parsed peer id, or nil when invalid.
    tbl.set(
        "parsePunchProbe",
        lua.create_function(|_, payload: LuaString| {
            Ok(crate::network::relay::parse_punch_probe(payload.as_bytes()))
        })?,
    )?;
    // -- predictLinear --
    /// Predicts an entity snapshot forward by linear velocity.
    /// @param | snapshot | table | Snapshot table with `id`, `tick`, `x`, `y`, `vx`, and `vy`.
    /// @param | dt | number | Prediction delta time.
    /// @return | table | Predicted snapshot table.
    /// @field | id | integer | Id.
    /// @field | tick | integer | Tick number.
    /// @field | x | number | X.
    /// @field | y | number | Y.
    /// @field | vx | number | Velocity X.
    /// @field | vy | number | Velocity Y.
    tbl.set(
        "predictLinear",
        lua.create_function(|lua, (snapshot, dt): (LuaTable, f32)| {
            let src = crate::network::net_sync::EntitySnapshot {
                id: snapshot.get("id")?,
                tick: snapshot.get("tick")?,
                x: snapshot.get("x")?,
                y: snapshot.get("y")?,
                vx: snapshot.get("vx")?,
                vy: snapshot.get("vy")?,
            };
            let out = crate::network::net_sync::predict_linear(&src, dt);
            let t = lua.create_table()?;
            /// The 'id' field value exposed to Lua scripts.
            t.set("id", out.id)?;
            /// Performs the 'tick' operation.
            t.set("tick", out.tick)?;
            /// The 'x' field value exposed to Lua scripts.
            t.set("x", out.x)?;
            /// The 'y' field value exposed to Lua scripts.
            t.set("y", out.y)?;
            /// The 'vx' field value exposed to Lua scripts.
            t.set("vx", out.vx)?;
            /// The 'vy' field value exposed to Lua scripts.
            t.set("vy", out.vy)?;
            Ok(t)
        })?,
    )?;
    // -- reconcileSnapshot --
    /// Reconciles a predicted snapshot toward an authoritative snapshot.
    /// @param | pred | table | Predicted snapshot table.
    /// @param | auth | table | Authoritative snapshot table.
    /// @param | alpha | number | Blend factor.
    /// @return | table | Reconciled snapshot table.
    /// @field | id | integer | Id.
    /// @field | tick | integer | Tick number.
    /// @field | x | number | X.
    /// @field | y | number | Y.
    /// @field | vx | number | Velocity X.
    /// @field | vy | number | Velocity Y.
    tbl.set(
        "reconcileSnapshot",
        lua.create_function(|lua, (pred, auth, alpha): (LuaTable, LuaTable, f32)| {
            let predicted = crate::network::net_sync::EntitySnapshot {
                id: pred.get("id")?,
                tick: pred.get("tick")?,
                x: pred.get("x")?,
                y: pred.get("y")?,
                vx: pred.get("vx")?,
                vy: pred.get("vy")?,
            };
            let authoritative = crate::network::net_sync::EntitySnapshot {
                id: auth.get("id")?,
                tick: auth.get("tick")?,
                x: auth.get("x")?,
                y: auth.get("y")?,
                vx: auth.get("vx")?,
                vy: auth.get("vy")?,
            };
            let out = crate::network::net_sync::reconcile(&predicted, &authoritative, alpha);
            let t = lua.create_table()?;
            /// The 'id' field value exposed to Lua scripts.
            t.set("id", out.id)?;
            /// Performs the 'tick' operation.
            t.set("tick", out.tick)?;
            /// The 'x' field value exposed to Lua scripts.
            t.set("x", out.x)?;
            /// The 'y' field value exposed to Lua scripts.
            t.set("y", out.y)?;
            /// The 'vx' field value exposed to Lua scripts.
            t.set("vx", out.vx)?;
            /// The 'vy' field value exposed to Lua scripts.
            t.set("vy", out.vy)?;
            Ok(t)
        })?,
    )?;
    // -- packSnapshot --
    /// Packs a sync snapshot table into a binary network message string.
    /// @param | snapshot | table | Sync snapshot table.
    /// @return | string | Binary packed snapshot.
    tbl.set(
        "packSnapshot",
        lua.create_function(|lua, snapshot: LuaTable| {
            let snap = lua_to_sync_snapshot(&snapshot)?;
            let net_val = snap.to_netvalue();
            let bytes = crate::network::message::pack(&net_val).map_err(LuaError::external)?;
            lua.create_string(&bytes)
        })?,
    )?;
    // -- unpackSnapshot --
    /// Unpacks a binary network message string into a sync snapshot table.
    /// @param | data | string | Binary packed snapshot.
    /// @return | table | Unpacked sync snapshot table.
    tbl.set(
        "unpackSnapshot",
        lua.create_function(|lua, data: LuaString| {
            let net_val =
                crate::network::message::unpack(data.as_bytes()).map_err(LuaError::external)?;
            let snap = crate::network::net_sync::SyncSnapshot::from_netvalue(&net_val)
                .ok_or_else(|| LuaError::RuntimeError("invalid snapshot payload".to_string()))?;
            sync_snapshot_to_lua(lua, &snap)
        })?,
    )?;
    // -- reconcileWithPolicy --
    /// Reconciles a predicted snapshot toward an authoritative snapshot using a distance-based policy.
    /// @param | pred | table | Predicted snapshot table.
    /// @param | auth | table | Authoritative snapshot table.
    /// @param | alpha | number | Blend factor.
    /// @param | soft_threshold | number | Distance threshold below which no correction is made.
    /// @param | hard_threshold | number | Distance threshold above which a hard snap occurs.
    /// @return | table | Reconciled snapshot table.
    tbl.set(
        "reconcileWithPolicy",
        lua.create_function(
            |lua,
             (pred, auth, alpha, soft_threshold, hard_threshold): (
                LuaTable,
                LuaTable,
                f32,
                f32,
                f32,
            )| {
                let predicted = lua_to_entity_snapshot(&pred)?;
                let authoritative = lua_to_entity_snapshot(&auth)?;
                let out = crate::network::net_sync::reconcile_with_policy(
                    &predicted,
                    &authoritative,
                    alpha,
                    soft_threshold,
                    hard_threshold,
                );
                entity_snapshot_to_lua(lua, &out)
            },
        )?,
    )?;
    // -- setReady --
    /// Marks a player as ready or not ready in a room.
    /// @param | room_name | string | Room name.
    /// @param | peer_id | integer | Peer identifier.
    /// @param | ready | boolean | True to mark as ready, false to unmark.
    tbl.set(
        "setReady",
        lua.create_function(|_, (room_name, peer_id, ready): (String, u32, bool)| {
            crate::network::lobby::set_player_ready(&room_name, peer_id, ready);
            Ok(())
        })?,
    )?;
    // -- isAllReady --
    /// Checks if all players in a room are ready. Requires at least 2 players.
    /// @param | room_name | string | Room name.
    /// @return | boolean | True if all players are ready and count >= 2.
    tbl.set(
        "isAllReady",
        lua.create_function(|_, room_name: String| {
            Ok(crate::network::lobby::is_all_ready(&room_name))
        })?,
    )?;
    // -- getRoom --
    /// Returns room metadata including host peer and player count.
    /// @param | room_name | string | Room name.
    /// @return | table | Room metadata table with fields: `name`, `host_peer`, `max_players`, `player_count`.
    tbl.set(
        "getRoom",
        lua.create_function(|lua, room_name: String| {
            if let Some(room) = crate::network::lobby::get_room_state(&room_name) {
                let t = lua.create_table()?;
                /// Performs the 'name' operation.
                t.set("name", room.name)?;
                /// Performs the 'host_peer' operation.
                t.set("host_peer", room.host_peer)?;
                /// Performs the 'max_players' operation.
                t.set("max_players", room.max_players)?;
                /// Performs the 'player_count' operation.
                t.set("player_count", room.players.len() as u32)?;
                Ok(t)
            } else {
                Ok(lua.create_table()?)
            }
        })?,
    )?;
    // -- getPlayerList --
    /// Returns list of peer IDs currently in a room.
    /// @param | room_name | string | Room name.
    /// @return | table | Array of peer ID integers.
    tbl.set(
        "getPlayerList",
        lua.create_function(|lua, room_name: String| {
            let peers = crate::network::lobby::get_player_list(&room_name);
            let arr = lua.create_table()?;
            for (i, peer_id) in peers.iter().enumerate() {
                arr.set(i + 1, *peer_id)?;
            }
            Ok(arr)
        })?,
    )?;
    // -- newNetState --
    /// Creates a network state synchronization manager.
    /// @param | host | LNetworkHost? | Network host for state transport, or nil for offline mode.
    /// @param | opts | table? | Configuration table with `channel`, `authority`, `turnBased`, `maxDirtyKeys`.
    /// @return | LNetworkState | New state manager handle.
    tbl.set(
        "newNetState",
        lua.create_function(|lua, (host, opts): (LuaValue, Option<LuaTable>)| {
            LNetworkState::new(lua, host, opts)
        })?,
    )?;
    // -- newRpc --
    /// Creates a network RPC manager attached to a host.
    /// @param | host | LNetworkHost | Network host for RPC transport.
    /// @param | channel | integer? | Optional ENet channel for RPC traffic, defaults to 0.
    /// @param | timeout_ms | number? | Optional timeout in milliseconds for pending calls, defaults to 30s.
    /// @return | LNetworkRpc | New RPC manager handle.
    tbl.set(
        "newRpc",
        lua.create_function(
            |lua, (host, channel, timeout_ms): (LuaValue, Option<u8>, Option<f64>)| {
                LNetworkRpc::new(lua, host, channel, timeout_ms)
            },
        )?,
    )?;
    /// Performs the 'network' operation.
    wrap_top_level_functions(lua, &tbl, state)?;
    lurek.set("network", tbl)?;
    Ok(())
}
