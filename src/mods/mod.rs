
//! - Mod system entry point exposing lifecycle management for game mods.
//! - Handles discovery, enabling/disabling, and Lua script integration of mods.
//! - Re-exports all public items from the mod manager submodule.

/// Mod lifecycle management: discovery, enable/disable, and Lua integration.
pub mod mod_manager;
pub use mod_manager::*;
