//! This file owns grid result behavior inside the procgen subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate grid result state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for grid result work.

/// Typed 2D integer grid result produced by procedural map generators.
#[derive(Debug, Clone)]
pub struct ProcgenGrid {
    /// Generator kind label, for example `wfc` or `rooms_dungeon`.
    pub kind: String,
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// Flat row-major cell values.
    pub cells: Vec<u32>,
}

impl ProcgenGrid {
    /// Create a validated integer grid result.
    pub fn new(
        kind: impl Into<String>,
        width: u32,
        height: u32,
        cells: Vec<u32>,
    ) -> Result<Self, String> {
        validate_grid_len(width, height, cells.len())?;
        Ok(Self {
            kind: kind.into(),
            width,
            height,
            cells,
        })
    }

    /// Return a cell value using zero-based coordinates.
    pub fn get(&self, x: u32, y: u32) -> Option<u32> {
        if x >= self.width || y >= self.height {
            return None;
        }
        self.cells.get((y * self.width + x) as usize).copied()
    }
}

/// Typed 2D scalar grid result produced by procedural height/noise generators.
#[derive(Debug, Clone)]
pub struct ProcgenScalarGrid {
    /// Generator kind label, for example `heightmap` or `noise_map`.
    pub kind: String,
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// Flat row-major scalar values.
    pub cells: Vec<f32>,
}

impl ProcgenScalarGrid {
    /// Create a validated scalar grid result.
    pub fn new(
        kind: impl Into<String>,
        width: u32,
        height: u32,
        cells: Vec<f32>,
    ) -> Result<Self, String> {
        validate_grid_len(width, height, cells.len())?;
        Ok(Self {
            kind: kind.into(),
            width,
            height,
            cells,
        })
    }

    /// Return a scalar value using zero-based coordinates.
    pub fn get(&self, x: u32, y: u32) -> Option<f32> {
        if x >= self.width || y >= self.height {
            return None;
        }
        self.cells.get((y * self.width + x) as usize).copied()
    }
}

fn validate_grid_len(width: u32, height: u32, len: usize) -> Result<(), String> {
    if width == 0 || height == 0 {
        return Err("procgen grid dimensions must be > 0".to_string());
    }
    let expected = width
        .checked_mul(height)
        .and_then(|value| usize::try_from(value).ok())
        .ok_or_else(|| "procgen grid dimensions overflow addressable storage".to_string())?;
    if len != expected {
        return Err(format!("procgen grid expected {expected} cells, got {len}"));
    }
    Ok(())
}
