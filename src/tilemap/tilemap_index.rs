//! Reverse-index mapping from Global Tile ID (GID) to list of (x, y) grid coordinates for fast spatial tile lookups in tilemaps.
//! Supports efficient batch updates and removal when tiles change, automatically pruning empty GID entries to maintain compact memory footprint.
//! Enables "find all tiles of type X" queries in O(1) lookup time, critical for finding spawn zones, triggers, and obstacle regions.

use std::collections::HashMap;

/// Remove position `(x, y)` from the GID entry in `layer_index`; removes the key entirely when the list becomes empty.
pub(crate) fn remove_pos_from_gid(
    layer_index: &mut HashMap<u32, Vec<(u32, u32)>>,
    gid: u32,
    x: u32,
    y: u32,
) {
    if let Some(list) = layer_index.get_mut(&gid) {
        if let Some(pos_idx) = list.iter().position(|&(px, py)| px == x && py == y) {
            list.swap_remove(pos_idx);
        }
        if list.is_empty() {
            layer_index.remove(&gid);
        }
    }
}
