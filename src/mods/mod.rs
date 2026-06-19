//! `src/mods/mod.rs` is the module index for mod schemas, registries, loading, sandboxing, and lifecycle management.
//! It declares the files that own API contracts, manifest parsing, runtime coordination, and Lua-facing safety boundaries.
//! This file reexports the main mod types so higher layers can use the subsystem without importing deep internal paths.
//! No manifest parsing or runtime mod state lives here; it only defines visibility and the public module surface.
//! Read this index first when tracing mod support, because it shows where schema, loader, manager, and sandbox logic split.
//! Changes here affect reachability and API shape, not dependency ordering, sandbox policy, or manifest interpretation.

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
/// Shared errors, policies, limits, and reports.
pub mod types;

pub use api_registry::{GameApiRegistry, TypeSchema};
pub use api_schema::{FieldDef, FieldType, MethodDef};
pub use mod_loader::{
    load_instances_from_toml, load_instances_from_toml_with_options, FieldValue,
    ModContentLoadOptions, ModInstance,
};
pub use mod_manager::*;
pub use mod_sandbox::{HookPoint, ModSandbox, SandboxListMode};
pub use types::*;
