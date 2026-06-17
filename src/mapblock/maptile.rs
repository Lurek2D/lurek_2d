//! Atomic tile payload composed from configurable slot values and metadata. `mapblock/maptile` delivers the maptile implementation for the mapblock subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Encodes tile-slot identifiers that point at tileset entries for rendering and logic. The file owns or coordinates data contracts including `MapTile`, `TileSlot`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Distinguishes slot roles so ordered drawing stays consistent. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `is_empty`, `set_slot`, `get_slot`, `clear_slot` stays attached to the local data model and invariants.

/// A single tile in a map block layer. Contains multiple configurable slots.
#[derive(Debug, Clone, Default)]
pub struct MapTile {
    /// Slot values indexed by slot index from `MapBlockConfig`.
    /// Each entry is `(tileset_id, gid)`. `(0, 0)` means empty.
    pub slots: Vec<TileSlot>,
}

/// A single slot value within a map tile.
#[derive(Debug, Clone, Copy, Default)]
pub struct TileSlot {
    /// Tileset ID this tile belongs to.
    pub tileset_id: u32,
    /// Global tile ID within the tileset.
    pub gid: u32,
}

impl TileSlot {
    /// Create a new tile slot with given tileset and GID.
    pub fn new(tileset_id: u32, gid: u32) -> Self {
        Self { tileset_id, gid }
    }

    /// Check if this slot is empty (no tile assigned).
    pub fn is_empty(&self) -> bool {
        self.gid == 0
    }
}

impl MapTile {
    /// Create a new tile with `slot_count` empty slots.
    pub fn new(slot_count: usize) -> Self {
        Self {
            slots: vec![TileSlot::default(); slot_count],
        }
    }

    /// Set a tile slot value by slot index.
    pub fn set_slot(&mut self, slot_index: usize, tileset_id: u32, gid: u32) {
        if slot_index < self.slots.len() {
            self.slots[slot_index] = TileSlot::new(tileset_id, gid);
        }
    }

    /// Get a tile slot value by slot index.
    pub fn get_slot(&self, slot_index: usize) -> Option<&TileSlot> {
        self.slots.get(slot_index)
    }

    /// Clear a slot, resetting it to empty.
    pub fn clear_slot(&mut self, slot_index: usize) {
        if slot_index < self.slots.len() {
            self.slots[slot_index] = TileSlot::default();
        }
    }

    /// Check if all tile slots are empty.
    pub fn is_empty(&self) -> bool {
        self.slots.iter().all(|s| s.is_empty())
    }
}
