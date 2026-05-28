//! Raycaster level renderer: wall, floor, ceiling, and sprite column rendering.
//!
//! - Data types: `TileHighlight`, `LevelRenderConfig`.
//! - Function: `compute_hole_visibility`.

/// Wireframe highlight configuration for a tile.
#[derive(Debug, Clone, Copy)]
pub struct TileHighlight {
    /// Grid x.
    pub grid_x: usize,
    /// Grid y.
    pub grid_y: usize,
    /// RGBA color value.
    pub color: [f32; 4],
    /// Thickness.
    pub thickness: f32,
}

impl TileHighlight {
    /// Create a tile highlight at the given grid coordinates with default yellow color.
    pub fn new(grid_x: usize, grid_y: usize) -> Self {
        Self {
            grid_x,
            grid_y,
            color: [1.0, 1.0, 0.0, 0.8],
            thickness: 2.0,
        }
    }

    /// Set the wireframe border color as an RGBA array.
    pub fn with_color(mut self, color: [f32; 4]) -> Self {
        self.color = color;
        self
    }

    /// Set the wireframe border line thickness in pixels.
    pub fn with_thickness(mut self, thickness: f32) -> Self {
        self.thickness = thickness;
        self
    }
}

/// Configuration for rendering adjacent levels through holes.
#[derive(Debug, Clone)]
pub struct LevelRenderConfig {
    /// Whether to render the level below through floor holes.
    pub show_below: bool,
    /// Whether to render the level above through ceiling holes.
    pub show_above: bool,
    /// Opacity for below-level rendering (0.0 - 1.0).
    pub below_opacity: f32,
    /// Opacity for above-level rendering (0.0 - 1.0).
    pub above_opacity: f32,
    /// Darkness multiplier for the level below.
    pub below_darkness: f32,
}

impl Default for LevelRenderConfig {
    fn default() -> Self {
        Self {
            show_below: true,
            show_above: true,
            below_opacity: 0.6,
            above_opacity: 0.4,
            below_darkness: 0.5,
        }
    }
}

/// Determines which cells are visible through holes from the current level.
pub fn compute_hole_visibility(
    floor_holes: &[bool],
    width: usize,
    height: usize,
    camera_x: f32,
    camera_y: f32,
    tile_size: f32,
    max_view_distance: f32,
) -> Vec<bool> {
    let mut visible = vec![false; width * height];
    let max_dist_sq = max_view_distance * max_view_distance;

    for y in 0..height {
        for x in 0..width {
            let idx = y * width + x;
            if !floor_holes[idx] {
                continue;
            }
            // Check if within view distance
            let cx = (x as f32 + 0.5) * tile_size;
            let cy = (y as f32 + 0.5) * tile_size;
            let dx = cx - camera_x;
            let dy = cy - camera_y;
            if dx * dx + dy * dy <= max_dist_sq {
                visible[idx] = true;
            }
        }
    }

    visible
}
