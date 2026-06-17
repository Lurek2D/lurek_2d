//! Entry point for the mod system and its lifecycle management. `mods/mod` is the mods module index, declaring `api_registry`, `api_schema`, `mod_loader`, `mod_manager`, `mod_sandbox` so agents can identify which files own each feature slice before opening implementation code.
//! Groups discovery, enable/disable flow, sandboxing, and Lua integration. `src/mods/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `api_registry::{GameApiRegistry, TypeSchema}`, `api_schema::{FieldDef, FieldType, MethodDef}`, `mod_loader::{FieldValue, ModInstance}`, `mod_manager::*`, and 1 more centralized for the mods subsystem.

/// Game API type registry and instance validation.
pub mod api_registry;
/// API schema types: fields, methods, asset requirements.
pub mod api_schema;
/// TOML-based mod instance loading.
pub mod mod_loader;
/// Mod lifecycle management: discovery, enable/disable, and Lua integration.
pub mod mod_manager;
/// Sandbox environment restricting mod Lua API access and capabilities.
pub mod mod_sandbox;

pub use api_registry::{GameApiRegistry, TypeSchema};
pub use api_schema::{FieldDef, FieldType, MethodDef};
pub use mod_loader::{FieldValue, ModInstance};
pub use mod_manager::*;
pub use mod_sandbox::{HookPoint, ModSandbox};
