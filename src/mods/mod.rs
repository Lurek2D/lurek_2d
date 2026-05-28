//! Mod system entry point exposing lifecycle management for game mods.

/// Mod lifecycle management: discovery, enable/disable, and Lua integration.
pub mod mod_manager;
/// Game API type registry and instance validation.
pub mod api_registry;
/// API schema types: fields, methods, asset requirements.
pub mod api_schema;
/// TOML-based mod instance loading.
pub mod mod_loader;
/// Sandbox environment restricting mod Lua API access and capabilities.
pub mod mod_sandbox;

pub use mod_manager::*;
pub use api_registry::{GameApiRegistry, TypeSchema};
pub use api_schema::{FieldDef, FieldType, MethodDef};
pub use mod_loader::{FieldValue, ModInstance};
pub use mod_sandbox::{HookPoint, ModSandbox};
