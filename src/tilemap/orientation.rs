//! This file owns orientation behavior inside the tilemap subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate orientation state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

/// Projection / rendering orientation for a tilemap.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
/// # Variants
pub enum MapOrientation {
    /// Standard top-down tile map.
    TopDown,
    /// Side-scrolling platform view.
    SideView,
    /// Isometric 2:1 diamond projection.
    Isometric,
    /// Hexagonal grid map.
    Hexagonal,
}
