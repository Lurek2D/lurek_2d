//! This module delivers the high-level fog, discovery, and line-of-sight system for region maps.
//! It stays geometry-agnostic so tile, province, and custom topologies can share the same model.
//! It unifies state storage, ownership sharing, reveal costs, events, and fog presentation paths.

/// Adjacency provider trait defining region neighbor relationships.
pub mod adjacency;
/// Per-region discovery cost and adjacency requirements for reveal logic.
pub mod cost;
/// Events emitted when region visibility state transitions occur.
pub mod events;
/// Per-region bitfield flags: terrain, units, buildings, and custom bits.
pub mod flags;
/// Fog-of-war rendering configuration: intensity, color, and render hints.
pub mod fog_render;
/// Visibility grid: per-region state storage for multiple simultaneous players.
pub mod grid;
/// Player and group ownership of shared visibility and discovery state.
pub mod owner;
/// Tile-grid recursive shadowcasting FOV for roguelike and stealth games.
pub mod shadowcast;
/// Visibility state enum: Hidden, Discovered, Visible, and custom levels.
pub mod state;

pub use adjacency::AdjacencyProvider;
pub use cost::DiscoveryCost;
pub use events::VisibilityEvent;
pub use flags::VisibilityFlags;
pub use fog_render::FogConfig;
pub use grid::VisibilityGrid;
pub use owner::PlayerOwnership;
pub use shadowcast::TileFov;
pub use state::VisibilityState;
