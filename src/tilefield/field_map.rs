//! This file owns field map behavior inside the tilefield subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate field map state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for field map work.
//! Serialization, indexing, and boundary checks stay here when they depend on field map internals.

use crate::tilefield::field::TileField;
use crate::tilefield::limits::TileFieldLimits;
use crate::tilefield::topology::TileTopology;
use std::cell::RefCell;
use std::rc::Rc;

/// Shared handle type for a `TileField` stored inside a `TileFieldMap`.
///
/// The reference-counted cell map permits replacement while existing Lua/Rust handles continue to observe the same field object.
pub type SharedTileField = Rc<RefCell<TileField>>;

/// A 2D or layered map of tilefields.
///
/// # Fields
///
/// Map dimensions and child-field dimensions define the address space; `fields` stores one shared child per map slot and `limits` bounds aggregate storage.
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
    limits: TileFieldLimits,
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
        Self::new_with_limits(
            width,
            height,
            layers,
            field_width,
            field_height,
            field_levels,
            topology,
            TileFieldLimits::default(),
        )
    }

    /// Create a field map after checking child count and aggregate dense storage.
    #[allow(clippy::too_many_arguments)]
    pub fn new_with_limits(
        width: u32,
        height: u32,
        layers: u32,
        field_width: u32,
        field_height: u32,
        field_levels: u32,
        topology: TileTopology,
        limits: TileFieldLimits,
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
        let (len, _) = limits.checked_field_map_storage(
            width,
            height,
            layers,
            field_width,
            field_height,
            field_levels,
        )?;
        let mut fields = Vec::with_capacity(len);
        for _ in 0..len {
            fields.push(Rc::new(RefCell::new(TileField::new_with_limits(
                field_width,
                field_height,
                field_levels,
                topology,
                limits,
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
            limits,
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

    /// Return the active allocation and collection ceilings.
    pub fn limits(&self) -> TileFieldLimits {
        self.limits
    }

    /// Return true when a zero-based field-map coordinate is in bounds.
    pub fn in_bounds(&self, x: u32, y: u32, layer: u32) -> bool {
        x < self.width && y < self.height && layer < self.layers
    }

    fn index(&self, x: u32, y: u32, layer: u32) -> Option<usize> {
        if !self.in_bounds(x, y, layer) {
            return None;
        }
        let row_width = u64::from(self.width).checked_mul(u64::from(self.height))?;
        let offset = u64::from(y)
            .checked_mul(u64::from(self.width))?
            .checked_add(u64::from(x))?;
        u64::from(layer)
            .checked_mul(row_width)
            .and_then(|base| base.checked_add(offset))
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
