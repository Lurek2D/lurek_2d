//! Engine module for network statistics.
//! Provides runtime metrics such as bytes sent/received and latency.
//! This is a generic, genre‑agnostic API.

use crate::runtime::SharedState;
use mlua::prelude::*;
use std::rc::Rc;
use std::cell::RefCell;

#[derive(Debug, Default, Clone)]
pub struct NetStat {
    pub bytes_sent: u64,
    pub bytes_recv: u64,
    pub latency_ms: f32,
}

impl NetStat {
    pub fn new() -> Self {
        Self::default()
    }

    // In a real engine these would be updated by the networking layer.
    pub fn update(&mut self, sent: u64, recv: u64, latency: f32) {
        self.bytes_sent += sent;
        self.bytes_recv += recv;
        self.latency_ms = latency;
    }

    pub fn snapshot(&self) -> NetStat {
        self.clone()
    }
}

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
