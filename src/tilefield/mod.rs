//! Indexes the tilefield gameplay-semantics subsystem and keeps its public Rust surface explicit.
//! Exports cell, field, field-map, line, modifier, and topology owners used by Lua bindings and tests.
//! Re-exports compact data types so callers can build field inputs without depending on file layout.
//! Keeps tilefield independent from renderers, minimaps, raycasters, pathfinding, awareness, and tilelight state.
//! Agents start here to trace which file owns blockers, costs, topology math, slots, and modifiers.
//! Neighbor modules may consume exported data, but they do not become owners of tilefield semantics.

/// Catalog trait for resolving typed refs without depending on tileset.
pub mod catalog;
/// User-defined category metadata for field semantics.
pub mod category;
/// Field cell storage and query behavior.
pub mod cell;
/// Tile light emitter data stored by fields and consumed by tilelight.
pub mod emitter;
/// Tile field dimensions, channels, slots, modifiers, regions, and exports.
pub mod field;
/// Field-map storage for 2D and layered grids of tilefields.
pub mod field_map;
/// Allocation and hostile-input ceilings for fields and field maps.
pub mod limits;
/// Tile line traversal helpers.
pub mod line;
/// Runtime tile modifiers applied on top of cell/object defaults.
pub mod modifier;
/// Typed tile/object refs stored in author-defined field slots.
pub mod reference;
/// Shared read-only semantic query facade over tilefield data.
pub mod semantics;
/// Supported grid topology parsing and distance helpers.
pub mod topology;

pub use catalog::TileObjectCatalog;
pub use category::{TileCategory, TileCategoryKind};
pub use cell::{TileCell, TileChannel};
pub use emitter::{TileLightEmitter, TileLightSource};
pub use field::{TileField, TileRegion};
pub use field_map::{SharedTileField, TileFieldMap};
pub use limits::TileFieldLimits;
pub use line::CellCoord;
pub use modifier::TileModifier;
pub use reference::TileRef;
pub use semantics::TileSemanticsView;
pub use topology::TileTopology;
