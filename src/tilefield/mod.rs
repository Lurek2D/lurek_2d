//! Indexes the tilefield gameplay-semantics subsystem and keeps its public Rust surface explicit.
//! Exports cell, field, light, line, profile, and topology owners used by Lua bindings and tests.
//! Re-exports compact data types so callers can build field inputs without depending on file layout.
//! Keeps tilefield independent from renderers, minimaps, raycasters, pathfinding, and visibility state.
//! Agents start here to trace which file owns blockers, costs, topology math, profiles, and lighting.
//! Neighbor modules may consume exported data, but they do not become owners of tilefield semantics.

/// Field cell storage and query behavior.
pub mod cell;
/// Tile field dimensions, profiles, channels, exports, and lighting state.
pub mod field;
/// Tile-light accumulation primitives.
pub mod light;
/// Tile line traversal helpers.
pub mod line;
/// Named object profiles applied to cells.
pub mod profile;
/// Supported grid topology parsing and distance helpers.
pub mod topology;

pub use cell::{TileCell, TileChannel};
pub use field::TileField;
pub use light::{GlobalLight, LightColor, PointLight, PointLightUpdate};
pub use line::CellCoord;
pub use profile::TileProfile;
pub use topology::TileTopology;
