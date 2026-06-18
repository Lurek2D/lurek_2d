//! This file owns a small network-statistics userdata that reports sent bytes, received bytes, and latency.
//! `NetStat` stores the counters, while `register` publishes Lua constructors and mutation helpers under `lurek`.
//! The file is a thin state carrier for scripting, not a transport implementation or runtime worker boundary.
//! Open it when scripting metrics change; host telemetry and socket polling live in other network owners.

use crate::runtime::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

#[derive(Debug, Default, Clone)]
/// Snapshot of network throughput and latency counters reported through `lurek.netstat`.
pub struct NetStat {
    /// Total bytes sent through the tracked network channel.
    pub bytes_sent: u64,
    /// Total bytes received through the tracked network channel.
    pub bytes_recv: u64,
    /// Last observed round-trip latency in milliseconds.
    pub latency_ms: f32,
}

impl NetStat {
    /// Creates a zeroed network statistics snapshot.
    pub fn new() -> Self {
        Self::default()
    }

    // In a real engine these would be updated by the networking layer.
    /// Accumulates sent and received byte counters and stores the latest latency.
    pub fn update(&mut self, sent: u64, recv: u64, latency: f32) {
        self.bytes_sent += sent;
        self.bytes_recv += recv;
        self.latency_ms = latency;
    }

    /// Returns a copy of the current statistics counters.
    pub fn snapshot(&self) -> NetStat {
        self.clone()
    }
}

/// Register the `lurek.netstat` Lua table with constructors and snapshot helpers.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let api = lua.create_table()?;
    api.set(
        "new",
        lua.create_function(|_, ()| Ok(NetStat::new()))?,
    )?;
    api.set(
        "update",
        lua.create_function(|_, (stat: LuaAnyUserData, sent: u64, recv: u64, latency: f32)| {
            let mut s: std::cell::RefMut<NetStat> = stat.borrow_mut();
            s.update(sent, recv, latency);
            Ok(())
        })?,
    )?;
    api.set(
        "snapshot",
        lua.create_function(|_, stat: LuaAnyUserData| {
            let s: std::cell::RefMut<NetStat> = stat.borrow_mut();
            let snap = s.snapshot();
            let tbl = lua.create_table()?;
            tbl.set("bytes_sent", snap.bytes_sent)?;
            tbl.set("bytes_recv", snap.bytes_recv)?;
            tbl.set("latency_ms", snap.latency_ms)?;
            Ok(tbl)
        })?,
    )?;
    lurek.set("netstat", api)?;
    Ok(())
}
