//! This module re-exports the visibility subsystem surface for grids, FOV, ownership, fog rules, and events.
//! It serves as the navigation map for region-state storage, adjacency contracts, reveal costs, and shadowcasting.
//! `grid.rs` owns shared per-player region state, while `shadowcast.rs` covers tile-based field-of-view computation.
//! `owner.rs`, `events.rs`, and `state.rs` define shared-vision groups, emitted transitions, and visibility levels.
//! `flags.rs`, `cost.rs`, `adjacency.rs`, and `fog_render.rs` describe reveal metadata and presentation inputs.
//! Change this file when the public visibility symbol map moves; change siblings when runtime behavior changes.

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
/// Per-player tile visibility and action masks backed by tilefield semantics.
pub mod tile_visibility;

pub use adjacency::AdjacencyProvider;
pub use cost::DiscoveryCost;
pub use events::VisibilityEvent;
pub use flags::VisibilityFlags;
pub use fog_render::FogConfig;
pub use grid::VisibilityGrid;
pub use owner::PlayerOwnership;
pub use shadowcast::TileFov;
pub use state::VisibilityState;
pub use tile_visibility::TileVisibility;
