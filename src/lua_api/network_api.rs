//! Registers the `luna.network` namespace.
//!
//! Provides Lua-level UDP networking via ENet: host creation, peer
//! management, packet sending and receiving. Wraps [`NetworkHost`].
//!
//! This module is part of Luna2D's `lua_api` subsystem.
//! Key types exported: `LuaNetworkHost`.
//! Primary functions: `register()`.

use std::cell::RefCell;
use std::net::SocketAddr;
use std::rc::Rc;

use mlua::prelude::*;
use rusty_enet::{Packet, PacketKind};

use crate::lua_api::lua_types::{add_type_methods, LunaType};
use crate::network::host::{NetworkEvent, NetworkHost};

// ── UserData wrapper ──────────────────────────────────────────────────────────

/// Lua UserData wrapper for a [`NetworkHost`].
///
/// # Fields
/// - `inner` — `Rc<RefCell<NetworkHost>>`. Shared host state.
#[derive(Clone)]
pub struct LuaNetworkHost {
    /// Shared network host state.
    pub(crate) inner: Rc<RefCell<NetworkHost>>,
}

impl LunaType for LuaNetworkHost {
    const TYPE_NAME: &'static str = "NetworkHost";
    const TYPE_HIERARCHY: &'static [&'static str] = &["NetworkHost", "Object"];
}

/// Converts a `NetworkEvent` to a Lua table `{type, peer_id, channel_id?, data?}`.
fn event_to_table(lua: &Lua, ev: NetworkEvent) -> LuaResult<LuaTable<'_>> {
    let tbl = lua.create_table()?;
    match ev {
        NetworkEvent::Connect { peer_id, data } => {
            tbl.set("type", "connect")?;
            tbl.set("peer_id", peer_id.0)?;
            tbl.set("data", data)?;
        }
        NetworkEvent::Disconnect { peer_id, data } => {
            tbl.set("type", "disconnect")?;
            tbl.set("peer_id", peer_id.0)?;
            tbl.set("data", data)?;
        }
        NetworkEvent::Receive {
            peer_id,
            channel_id,
            data,
        } => {
            tbl.set("type", "receive")?;
            tbl.set("peer_id", peer_id.0)?;
            tbl.set("channel_id", channel_id)?;
            // Convert bytes to a Lua string (binary-safe).
            let payload = lua.create_string(&data)?;
            tbl.set("data", payload)?;
        }
    }
    Ok(tbl)
}

/// Parses `"host:port"` or `"host port"` strings into a `SocketAddr`.
fn parse_addr(s: &str) -> LuaResult<SocketAddr> {
    let addr: SocketAddr = s
        .parse()
        .map_err(|_| LuaError::RuntimeError(format!("invalid address: {s}")))?;
    Ok(addr)
}

impl LuaUserData for LuaNetworkHost {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        add_type_methods::<Self>(methods);

        /// Polls the network for one event. Returns an event table or `nil`.
        ///
        /// Event table: `{type, peer_id [, channel_id] [, data]}`.
        /// `type` is `"connect"`, `"disconnect"`, or `"receive"`.
        /// @return table|nil
        methods.add_method("service", |lua, this, ()| {
            let result = this.inner.borrow_mut().service();
            match result {
                Ok(Some(ev)) => {
                    let tbl = event_to_table(lua, ev)?;
                    Ok(LuaValue::Table(tbl))
                }
                Ok(None) => Ok(LuaValue::Nil),
                Err(e) => Err(LuaError::RuntimeError(format!("network service error: {e}"))),
            }
        });

        /// Initiates a connection to a remote host. Returns the peer ID on success.
        /// @param addr     string   `"host:port"` of the remote endpoint.
        /// @param channels number   Number of channels to allocate (default 1).
        /// @param data     number   User data carried in the connect packet (default 0).
        /// @return number   Peer ID.
        methods.add_method(
            "connect",
            |_, this, (addr_str, channels, data): (String, Option<usize>, Option<u32>)| {
                let addr = parse_addr(&addr_str)?;
                let channels = channels.unwrap_or(1);
                let data = data.unwrap_or(0);
                let peer_id = this
                    .inner
                    .borrow_mut()
                    .connect(addr, channels, data)
                    .map_err(|e| LuaError::RuntimeError(format!("connect failed: {e}")))?;
                Ok(peer_id.0)
            },
        );

        /// Sends data to a specific peer.
        /// @param peer_id    number
        /// @param channel_id number
        /// @param data       string   Payload (may contain binary data).
        /// @param reliable   boolean  (default true) Whether to use reliable delivery.
        methods.add_method(
            "send",
            |_,
             this,
             (peer_id_raw, channel_id, data_str, reliable): (
                usize,
                u8,
                LuaString,
                Option<bool>,
            )| {
                use rusty_enet::PeerID;
                let reliable = reliable.unwrap_or(true);
                let kind = if reliable {
                    PacketKind::Reliable
                } else {
                    PacketKind::Unreliable { sequenced: true }
                };
                let packet = Packet::new(data_str.as_bytes(), kind);
                this.inner
                    .borrow_mut()
                    .send(PeerID(peer_id_raw), channel_id, packet)
                    .map_err(|e| LuaError::RuntimeError(format!("send failed: {e}")))
            },
        );

        /// Broadcasts data to all connected peers on the given channel.
        /// @param channel_id number
        /// @param data       string
        /// @param reliable   boolean  (default true)
        methods.add_method(
            "broadcast",
            |_, this, (channel_id, data_str, reliable): (u8, LuaString, Option<bool>)| {
                let reliable = reliable.unwrap_or(true);
                let kind = if reliable {
                    PacketKind::Reliable
                } else {
                    PacketKind::Unreliable { sequenced: true }
                };
                let packet = Packet::new(data_str.as_bytes(), kind);
                this.inner
                    .borrow_mut()
                    .broadcast(channel_id, &packet)
                    .map_err(|e| LuaError::RuntimeError(format!("broadcast failed: {e}")))
            },
        );

        /// Flushes pending sends immediately.
        methods.add_method("flush", |_, this, ()| {
            this.inner
                .borrow_mut()
                .flush()
                .map_err(|e| LuaError::RuntimeError(format!("flush failed: {e}")))
        });

        /// Gracefully disconnects a peer. The disconnect event arrives on the next `service()`.
        /// @param peer_id number
        /// @param data    number  (default 0) User data for the disconnect packet.
        methods.add_method("disconnect", |_, this, (peer_id_raw, data): (usize, Option<u32>)| {
            use rusty_enet::PeerID;
            this.inner
                .borrow_mut()
                .disconnect(PeerID(peer_id_raw), data.unwrap_or(0))
                .map_err(|e| LuaError::RuntimeError(format!("disconnect failed: {e}")))
        });

        /// Returns the local address of this host as `"ip:port"`.
        /// @return string
        methods.add_method("getAddress", |_, this, ()| {
            Ok(this.inner.borrow().local_address().to_string())
        });
    }
}

// ── Registration ──────────────────────────────────────────────────────────────

/// Registers the `luna.network` namespace into the given `luna` table.
///
/// # Parameters
/// - `lua` — `&Lua`.
/// - `luna` — `&LuaTable`.
///
/// # Returns
/// `LuaResult<()>`.
pub fn register(lua: &Lua, luna: &LuaTable) -> LuaResult<()> {
    let network_tbl = lua.create_table()?;

    /// Creates a new [`NetworkHost`] bound to the given address.
    ///
    /// `opts` fields:
    /// - `addr`     — `string`  Bind address `"host:port"`. Use `"0.0.0.0:0"` for a client-only host.
    /// - `peers`    — `number`  Maximum number of peers (default 32).
    /// - `channels` — `number`  Channel count (default 2).
    /// @param opts table
    /// @return NetworkHost
    network_tbl.set(
        "newHost",
        lua.create_function(|_, opts: LuaTable| {
            let addr_str: String = opts
                .get::<_, String>("addr")
                .unwrap_or_else(|_| "0.0.0.0:0".to_string());
            let peers: Option<usize> = opts.get("peers").ok();
            let channels: Option<usize> = opts.get("channels").ok();
            let addr: SocketAddr = addr_str
                .parse()
                .map_err(|_| LuaError::RuntimeError(format!("invalid address: {addr_str}")))?;
            let host = NetworkHost::new(addr, peers, channels, None, None)
                .map_err(|e| LuaError::RuntimeError(format!("network host error: {e}")))?;
            Ok(LuaNetworkHost {
                inner: Rc::new(RefCell::new(host)),
            })
        })?,
    )?;

    luna.set("network", network_tbl)?;
    Ok(())
}
