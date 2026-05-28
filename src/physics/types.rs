//! Core type definitions for the physics subsystem.
//!
//! - `BodyId` newtype wrapper for type-safe body identification across Lua and Rust layers.
//! - Implements `Copy`, `Hash`, and `Display`; converts to/from `usize` without allocation.

/// Unique identifier for a physics body.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct BodyId(pub usize);

impl BodyId {
    /// Creates a new BodyId from a raw usize.
    pub fn new(id: usize) -> Self { Self(id) }
    /// Returns the raw usize underlying value.
    pub fn raw(self) -> usize { self.0 }
}

impl std::fmt::Display for BodyId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<usize> for BodyId {
    fn from(v: usize) -> Self { Self(v) }
}

impl From<BodyId> for usize {
    fn from(id: BodyId) -> Self { id.0 }
}

impl mlua::IntoLua<'_> for BodyId {
    fn into_lua(self, lua: &mlua::Lua) -> mlua::Result<mlua::Value<'_>> {
        lua.pack(self.0 as i64)
    }
}

impl mlua::FromLua<'_> for BodyId {
    fn from_lua(val: mlua::Value, lua: &mlua::Lua) -> mlua::Result<Self> {
        let n = i64::from_lua(val, lua)?;
        Ok(BodyId(n as usize))
    }
}
