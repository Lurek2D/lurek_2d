//! This file owns recursive Lua table cloning used when ECS snapshots and blueprints must not share nested state.
//! `deep_copy_table` preserves keys and non-table values while recursively duplicating child tables by value.
//! Open it when Lua-owned ECS copy semantics change; entity storage and queries live in sibling ECS files.

use mlua::{Lua, Result as LuaResult, Table, Value as LuaValue};

/// Recursively clone a Lua table, preserving nested table structure by value.
pub fn deep_copy_table<'lua>(lua: &'lua Lua, t: &Table<'lua>) -> LuaResult<Table<'lua>> {
    let copy = lua.create_table()?;
    for pair in t.clone().pairs::<LuaValue, LuaValue>() {
        let (k, v) = pair?;
        let v_copy = match v {
            LuaValue::Table(ref inner) => LuaValue::Table(deep_copy_table(lua, inner)?),
            other => other,
        };
        copy.set(k, v_copy)?;
    }
    Ok(copy)
}
