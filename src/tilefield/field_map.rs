//! This file owns field map behavior inside the tilefield subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate field map state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for field map work.
//! Serialization, indexing, and boundary checks stay here when they depend on field map internals.

use crate::tilefield::field::TileField;
use crate::tilefield::topology::TileTopology;
use std::cell::RefCell;
use std::rc::Rc;

/// Shared handle type for a `TileField` stored inside a `TileFieldMap`.
pub type SharedTileField = Rc<RefCell<TileField>>;

/// A 2D or layered map of tilefields.
#[derive(Debug, Clone)]
pub struct TileFieldMap {
    width: u32,
    height: u32,
    layers: u32,
    field_width: u32,
    field_height: u32,
    field_levels: u32,
    topology: TileTopology,
    fields: Vec<SharedTileField>,
}

impl TileFieldMap {
    /// Create a field map with one `TileField` per map slot.
    pub fn new(
        width: u32,
        height: u32,
        layers: u32,
        field_width: u32,
        field_height: u32,
        field_levels: u32,
        topology: TileTopology,
    ) -> Result<Self, String> {
        if width == 0
            || height == 0
            || layers == 0
            || field_width == 0
            || field_height == 0
            || field_levels == 0
        {
            return Err(
                "tilefield map dimensions, layers, and field sizes must be > 0".to_string(),
            );
        }
        let len = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(layers))
            .and_then(|v| usize::try_from(v).ok())
            .ok_or_else(|| "tilefield map dimensions overflow addressable storage".to_string())?;
        let mut fields = Vec::with_capacity(len);
        for _ in 0..len {
            fields.push(Rc::new(RefCell::new(TileField::new(
                field_width,
                field_height,
                field_levels,
                topology,
            )?)));
        }
        Ok(Self {
            width,
            height,
            layers,
            field_width,
            field_height,
            field_levels,
            topology,
            fields,
        })
    }

    /// Return field-map dimensions as `(width, height, layers)`.
    pub fn map_size(&self) -> (u32, u32, u32) {
        (self.width, self.height, self.layers)
    }

    /// Return contained field dimensions as `(width, height, levels)`.
    pub fn field_size(&self) -> (u32, u32, u32) {
        (self.field_width, self.field_height, self.field_levels)
    }

    /// Return topology shared by every contained field.
    pub fn topology(&self) -> TileTopology {
        self.topology
    }

    /// Return true when a zero-based field-map coordinate is in bounds.
    pub fn in_bounds(&self, x: u32, y: u32, layer: u32) -> bool {
        x < self.width && y < self.height && layer < self.layers
    }

    fn index(&self, x: u32, y: u32, layer: u32) -> Option<usize> {
        if !self.in_bounds(x, y, layer) {
            return None;
        }
        layer
            .checked_mul(self.width * self.height)
            .and_then(|base| base.checked_add(y * self.width + x))
            .and_then(|idx| usize::try_from(idx).ok())
    }

    /// Return the shared field handle at a zero-based field-map coordinate.
    pub fn field(&self, x: u32, y: u32, layer: u32) -> Option<SharedTileField> {
        self.index(x, y, layer)
            .and_then(|idx| self.fields.get(idx))
            .cloned()
    }

    /// Replace one stored field handle after validating size and topology.
    pub fn set_field(
        &mut self,
        x: u32,
        y: u32,
        layer: u32,
        field: SharedTileField,
    ) -> Result<(), String> {
        let idx = self
            .index(x, y, layer)
            .ok_or_else(|| "tilefield map setField coordinate is out of bounds".to_string())?;
        {
            let field_ref = field.borrow();
            if field_ref.size() != self.field_size() {
                return Err("tilefield map setField field size does not match".to_string());
            }
            if field_ref.topology() != self.topology {
                return Err("tilefield map setField topology does not match".to_string());
            }
        }
        self.fields[idx] = field;
        Ok(())
    }
}
