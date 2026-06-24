//! Exports reusable tileset atlas data, object archetypes, visuals, animation frames, and autotile rules.
//! Keeps tileset definitions outside tilemap while still allowing tilemap to attach and render tileset-backed objects.

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
