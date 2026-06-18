//! This file owns the reverse-index maintenance helper that maps tile GIDs back to their grid positions.
//! The function removes one coordinate from a GID bucket and deletes empty buckets to keep index state compact.
//! Open this file when tile lookup bookkeeping changes; map storage and generation logic belong to siblings.

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
