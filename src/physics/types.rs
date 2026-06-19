//! This file owns `BodyId`, the stable typed identifier used to reference bodies across the physics subsystem.
//! It wraps raw slot indices with conversions, display formatting, and Lua bridging so body handles stay explicit.
//! Open this file when body-handle representation changes; world storage and body descriptors live in sibling owners.
//! This is the right owner for changing Rust or Lua identity semantics without touching simulation behavior directly.

use super::error::PhysicsError;

/// Unique identifier for a physics body.
/// # Fields
/// - `0`: raw stable slot id.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct BodyId(pub usize);

impl BodyId {
    /// Creates a new BodyId from a raw usize.
    pub fn new(id: usize) -> Self {
        Self(id)
    }
    /// Returns the raw usize underlying value.
    pub fn raw(self) -> usize {
        self.0
    }
}

impl std::fmt::Display for BodyId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<usize> for BodyId {
    fn from(v: usize) -> Self {
        Self(v)
    }
}

impl From<BodyId> for usize {
    fn from(id: BodyId) -> Self {
        id.0
    }
}

impl mlua::IntoLua<'_> for BodyId {
    fn into_lua(self, lua: &mlua::Lua) -> mlua::Result<mlua::Value<'_>> {
        lua.pack(self.0 as i64)
    }
}

impl mlua::FromLua<'_> for BodyId {
    fn from_lua(val: mlua::Value, lua: &mlua::Lua) -> mlua::Result<Self> {
        let n = i64::from_lua(val, lua)?;
        let raw = usize::try_from(n).map_err(|_| {
            mlua::Error::RuntimeError(PhysicsError::InvalidBodyIdValue { value: n }.to_string())
        })?;
        Ok(BodyId(raw))
    }
}
