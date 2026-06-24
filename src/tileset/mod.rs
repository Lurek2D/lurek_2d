//! This module index owns the public shape of the tileset subsystem and its source navigation map.
//! It declares which sibling files participate in tileset behavior and which names are reexported outward.
//! Reexports here are intentionally narrow so callers do not depend on private implementation modules.
//! Agents should start here to understand subsystem boundaries before opening deeper implementation files.
//! New submodules belong here only when they add durable behavior rather than temporary test scaffolding.
//! Keep this index synchronized with specs, examples, and Lua bindings whenever public ownership changes.

#![allow(clippy::module_inception)]

/// Animation frame records for tileset-local tile animations.
pub mod animation;
/// Engine-facing object archetypes and light defaults.
pub mod archetype;
/// Tileset-level autotile matching policy.
pub mod autotile;
/// Many-tileset catalog lookup for typed tilefield refs.
pub mod catalog;
/// Core tileset atlas, archetype registry, per-tile mappings, and autotile rule storage.
pub mod tileset;
/// Sprite/atlas/image visual references used by tilemap render ordering.
pub mod visual;

pub use animation::TileAnimFrame;
pub use archetype::{TileObjectArchetype, TileObjectLight};
pub use autotile::AutoTileMode;
pub use catalog::TileCatalog;
pub use tileset::TileSet;
pub use visual::TileVisual;
