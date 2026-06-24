//! Tilemap projection orientation shared by storage and render adapters.

/// Projection / rendering orientation for a tilemap.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
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
