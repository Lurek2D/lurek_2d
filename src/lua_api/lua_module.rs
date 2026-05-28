//! Trait-based module registration for `lurek.*` Lua API modules.
//!
//! - Registers `lurek.lua_module.*` functions and types via `register()`.

use crate::runtime::config::ModulesConfig;
use crate::runtime::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Trait implemented by each `lurek.*` API module to enable declarative registration.
///
/// Modules can implement this trait to participate in future inventory-style
/// auto-registration. Currently the static [`ModuleEntry`] table in `register.rs`
/// wraps existing free-function `register` calls via the `always!` / `gated!` macros.
pub trait LuaModule {
    /// The `lurek.*` namespace name used for diagnostics and logging.
    const MODULE_NAME: &'static str;

    /// Returns `true` when this module should be registered given the current config.
    ///
    /// Modules that are always loaded (event, sprite, math, etc.) return `true` unconditionally.
    fn is_enabled(modules: &ModulesConfig) -> bool;

    /// Register this module's functions and types into the `lurek` table.
    fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()>;
}

/// Entry in the compile-time module registry used by `register_modules`.
///
/// Each entry stores function pointers matching the `LuaModule` trait surface,
/// allowing iteration without requiring object-safety (associated consts prevent
/// `dyn LuaModule`) exposed by the lurek engine.
pub struct ModuleEntry {
    /// Diagnostic name for this module (matches the `*_api` module ident).
    pub name: &'static str,
    /// Returns `true` when the module should be loaded for the given config.
    pub is_enabled: fn(&ModulesConfig) -> bool,
    /// Performs the actual Lua table registration.
    pub register: fn(&Lua, &LuaTable, Rc<RefCell<SharedState>>) -> LuaResult<()>,
}
