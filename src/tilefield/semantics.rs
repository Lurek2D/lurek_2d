//! Owns read-only semantic queries over a `TileField`.
//! Consumers use this view instead of duplicating blocker, cost, transmission, and footprint logic.

use crate::tilefield::{CellCoord, TileField, TileLightSource};

/// Read-only semantic facade for one tilefield.
pub struct TileSemanticsView<'a> {
    field: &'a TileField,
}

impl<'a> TileSemanticsView<'a> {
    /// Create a semantic view over a tilefield.
    pub fn new(field: &'a TileField) -> Self {
        Self { field }
    }

    /// Return whether the cell blocks the named category.
    pub fn blocks(&self, coord: CellCoord, category: &str) -> bool {
        self.field.blocks_category(coord, category)
    }

    /// Return the effective category cost.
    pub fn cost(&self, coord: CellCoord, category: &str) -> f32 {
        self.field.category_cost(coord, category)
    }

    /// Return the effective category transmission.
    pub fn transmission(&self, coord: CellCoord, category: &str) -> f32 {
        self.field.category_transmission(coord, category)
    }

    /// Return the effective RGB category filter.
    pub fn filter(&self, coord: CellCoord, category: &str) -> [f32; 3] {
        self.field.category_filter(coord, category)
    }

    /// Return tile light sources contributed by base cells and active modifiers.
    pub fn light_sources(&self) -> Vec<TileLightSource> {
        self.field.tile_light_sources()
    }

    /// Return true when a rectangular footprint can occupy `anchor`.
    pub fn footprint_passable(
        &self,
        anchor: CellCoord,
        width: u32,
        height: u32,
        category: &str,
    ) -> bool {
        self.field
            .footprint_passable(anchor, width, height, category)
    }
}
