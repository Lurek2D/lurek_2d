//! Allocation and work ceilings for tilelight maps and runtime sources.
//!
//! These limits are checked before dense storage, source collections, influence
//! regions, and compute loops are created. They are deliberately owned by
//! tilelight because tilefield limits cannot predict the number or shape of
//! runtime lights attached to one field.

/// Practical ceilings for tilelight storage, source shapes, and computation.
///
/// # Fields
///
/// The `max_*` fields are inclusive ceilings. Dimensions and radii use tile
/// units; collection and work fields use Rust counts. A limit failure is
/// reported by the caller before allocation or nested propagation begins.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TileLightLimits {
    /// Maximum dense cells in one light volume.
    pub max_volume_cells: usize,
    /// Maximum active point sources.
    pub max_point_lights: usize,
    /// Maximum active line sources.
    pub max_line_lights: usize,
    /// Maximum active rectangular area sources.
    pub max_area_lights: usize,
    /// Maximum cells rasterized for one line source.
    pub max_line_cells: usize,
    /// Maximum finite radius in tile units.
    pub max_radius: u32,
    /// Maximum rectangular area width in tiles.
    pub max_area_width: u32,
    /// Maximum rectangular area height in tiles.
    pub max_area_height: u32,
    /// Maximum candidate cells affected by one source shape.
    pub max_affected_cells_per_source: usize,
    /// Maximum cells copied by one output export operation.
    pub max_output_cells: usize,
    /// Maximum estimated propagation work for one compute.
    pub max_compute_work: u64,
}

impl Default for TileLightLimits {
    fn default() -> Self {
        Self {
            max_volume_cells: 4_000_000,
            max_point_lights: 4_096,
            max_line_lights: 1_024,
            max_area_lights: 1_024,
            max_line_cells: 65_536,
            max_radius: 256,
            max_area_width: 1_024,
            max_area_height: 1_024,
            max_affected_cells_per_source: 1_000_000,
            max_output_cells: 4_000_000,
            max_compute_work: 250_000_000,
        }
    }
}

impl TileLightLimits {
    /// Validate a limit set before it is used for any allocation.
    pub fn validate(self) -> Result<(), String> {
        if self.max_volume_cells == 0
            || self.max_point_lights == 0
            || self.max_line_lights == 0
            || self.max_area_lights == 0
            || self.max_line_cells == 0
            || self.max_radius == 0
            || self.max_area_width == 0
            || self.max_area_height == 0
            || self.max_affected_cells_per_source == 0
            || self.max_output_cells == 0
            || self.max_compute_work == 0
        {
            return Err("tilelight limits must all be greater than zero".to_string());
        }
        Ok(())
    }

    /// Check a dense volume product before converting it to `usize`.
    pub fn checked_volume_cells(
        self,
        width: u32,
        height: u32,
        levels: u32,
    ) -> Result<usize, String> {
        self.validate()?;
        let cells = u64::from(width)
            .checked_mul(u64::from(height))
            .and_then(|value| value.checked_mul(u64::from(levels)))
            .ok_or_else(|| "tilelight volume dimensions overflow".to_string())?;
        let cells = usize::try_from(cells)
            .map_err(|_| "tilelight volume exceeds addressable storage".to_string())?;
        if cells > self.max_volume_cells {
            return Err(format!(
                "tilelight volume cell limit exceeded ({} > max {})",
                cells, self.max_volume_cells
            ));
        }
        Ok(cells)
    }

    /// Convert a validated radius to a bounded integer halo radius.
    pub fn radius_cells(self, radius: f32, api: &str) -> Result<u32, String> {
        if !radius.is_finite() || radius <= 0.0 {
            return Err(format!("tilelight {api} radius must be finite and > 0"));
        }
        let radius = radius.ceil();
        if radius > self.max_radius as f32 {
            return Err(format!(
                "tilelight {api} radius exceeds limit {}",
                self.max_radius
            ));
        }
        Ok(radius as u32)
    }

    /// Check a source footprint before its propagation loops are entered.
    pub fn check_affected_cells(self, cells: u64, api: &str) -> Result<(), String> {
        if cells > self.max_affected_cells_per_source as u64 {
            return Err(format!(
                "tilelight {api} affected-cell limit exceeded ({} > max {})",
                cells, self.max_affected_cells_per_source
            ));
        }
        Ok(())
    }

    /// Check an estimated compute workload before clearing or propagating output.
    pub fn check_compute_work(self, work: u64) -> Result<(), String> {
        if work > self.max_compute_work {
            return Err(format!(
                "tilelight compute work limit exceeded ({} > max {})",
                work, self.max_compute_work
            ));
        }
        Ok(())
    }
}
