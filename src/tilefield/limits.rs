//! Bounds tilefield allocation, imported data, and mutable support collections.
//!
//! The limits are intentionally owned by tilefield instead of tilemap so the
//! gameplay-semantic store can be used without importing renderer policy.

/// Safety ceilings for one tilefield and an aggregate field map.
///
/// # Fields
///
/// Dense-storage ceilings use `u64` so products are checked before conversion to addressable Rust storage; collection ceilings bound sparse and imported data.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TileFieldLimits {
    /// Maximum dense cells in one field.
    pub max_cells_per_field: u64,
    /// Maximum child fields in one field map.
    pub max_fields_per_map: u64,
    /// Maximum dense cells across all child fields in one field map.
    pub max_cells_per_field_map: u64,
    /// Maximum levels in one field.
    pub max_levels: u32,
    /// Maximum category records, including built-ins.
    pub max_categories: usize,
    /// Maximum modifier/profile records, including built-ins.
    pub max_modifiers: usize,
    /// Maximum declared reference slots.
    pub max_slots: usize,
    /// Maximum named regions.
    pub max_regions: usize,
    /// Maximum cells retained by one region.
    pub max_cells_per_region: usize,
    /// Maximum legacy or typed references retained by one cell.
    pub max_refs_per_cell: usize,
    /// Maximum pending dirty rectangles.
    pub max_dirty_rects: usize,
    /// Maximum exported/imported snapshot entries.
    pub max_snapshot_entries: usize,
    /// Maximum provider callback rows that may be materialized.
    pub max_provider_rows: u64,
    /// Maximum length of a user-provided string stored by tilefield.
    pub max_string_length: usize,
}

impl Default for TileFieldLimits {
    fn default() -> Self {
        Self {
            max_cells_per_field: 16_777_216,
            max_fields_per_map: 1_048_576,
            max_cells_per_field_map: 16_777_216,
            max_levels: 256,
            max_categories: 256,
            max_modifiers: 256,
            max_slots: 256,
            max_regions: 65_536,
            max_cells_per_region: 1_048_576,
            max_refs_per_cell: 64,
            max_dirty_rects: 65_536,
            max_snapshot_entries: 16_777_216,
            max_provider_rows: 16_777_216,
            max_string_length: 4096,
        }
    }
}

impl TileFieldLimits {
    /// Validate a limits record before it is used for allocation.
    pub fn validate(&self) -> Result<(), String> {
        if self.max_cells_per_field == 0
            || self.max_fields_per_map == 0
            || self.max_cells_per_field_map == 0
            || self.max_levels == 0
            || self.max_categories == 0
            || self.max_modifiers == 0
            || self.max_slots == 0
            || self.max_regions == 0
            || self.max_cells_per_region == 0
            || self.max_refs_per_cell == 0
            || self.max_dirty_rects == 0
            || self.max_snapshot_entries == 0
            || self.max_provider_rows == 0
            || self.max_string_length == 0
        {
            return Err("tilefield limits must all be greater than zero".to_string());
        }
        Ok(())
    }

    /// Check a field's dense cell product before converting it to `usize`.
    pub fn checked_field_cells(
        &self,
        width: u32,
        height: u32,
        levels: u32,
    ) -> Result<usize, String> {
        self.validate()?;
        if levels > self.max_levels {
            return Err(format!(
                "tilefield levels {levels} exceed limit {}",
                self.max_levels
            ));
        }
        let cells = u64::from(width)
            .checked_mul(u64::from(height))
            .and_then(|value| value.checked_mul(u64::from(levels)))
            .ok_or_else(|| "tilefield cell count overflow".to_string())?;
        if cells > self.max_cells_per_field {
            return Err(format!(
                "tilefield cell count {cells} exceeds limit {}",
                self.max_cells_per_field
            ));
        }
        usize::try_from(cells)
            .map_err(|_| "tilefield cell count does not fit addressable storage".to_string())
    }

    /// Check a field-map child count and aggregate dense cell product.
    pub fn checked_field_map_storage(
        &self,
        width: u32,
        height: u32,
        layers: u32,
        field_width: u32,
        field_height: u32,
        field_levels: u32,
    ) -> Result<(usize, usize), String> {
        self.validate()?;
        let child_fields = u64::from(width)
            .checked_mul(u64::from(height))
            .and_then(|value| value.checked_mul(u64::from(layers)))
            .ok_or_else(|| "tilefield map field count overflow".to_string())?;
        if child_fields > self.max_fields_per_map {
            return Err(format!(
                "tilefield map field count {child_fields} exceeds limit {}",
                self.max_fields_per_map
            ));
        }
        let cells_per_field = u64::from(field_width)
            .checked_mul(u64::from(field_height))
            .and_then(|value| value.checked_mul(u64::from(field_levels)))
            .ok_or_else(|| "tilefield map child cell count overflow".to_string())?;
        if cells_per_field > self.max_cells_per_field {
            return Err(format!(
                "tilefield map child cell count {cells_per_field} exceeds field limit {}",
                self.max_cells_per_field
            ));
        }
        let total_cells = child_fields
            .checked_mul(cells_per_field)
            .ok_or_else(|| "tilefield map aggregate cell count overflow".to_string())?;
        if total_cells > self.max_cells_per_field_map {
            return Err(format!(
                "tilefield map aggregate cell count {total_cells} exceeds limit {}",
                self.max_cells_per_field_map
            ));
        }
        let child_count = usize::try_from(child_fields).map_err(|_| {
            "tilefield map field count does not fit addressable storage".to_string()
        })?;
        let child_cells = usize::try_from(cells_per_field).map_err(|_| {
            "tilefield map child cell count does not fit addressable storage".to_string()
        })?;
        Ok((child_count, child_cells))
    }

    /// Check a string before it is copied into tilefield state.
    pub fn validate_string(&self, value: &str, label: &str) -> Result<(), String> {
        if value.len() > self.max_string_length {
            return Err(format!(
                "tilefield {label} length {} exceeds limit {}",
                value.len(),
                self.max_string_length
            ));
        }
        Ok(())
    }
}
