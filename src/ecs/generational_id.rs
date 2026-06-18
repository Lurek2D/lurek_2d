//! This file owns stateless packing of entity slot and generation into one compact handle used across ECS.
//! `GenerationalId` encodes a 24-bit slot plus 8-bit generation and exposes direct unpack helpers for both parts.
//! Open it when entity-id layout changes; typed wrappers, world storage, and queries live in sibling ECS files.

/// Stateless namespace for encoding and decoding packed entity identifiers.
///
/// # Fields
/// This helper owns no runtime fields; it is a zero-sized namespace type.
pub struct GenerationalId;

/// Encoding and decoding helpers for packed generational entity ids.
impl GenerationalId {
    /// Packs a 24-bit slot and 8-bit generation into a single entity id.
    pub fn pack(slot: u32, generation: u8) -> u32 {
        ((generation as u32) << 24) | (slot & 0x00FF_FFFF)
    }
    /// Extracts the slot index from a packed entity id.
    pub fn unpack_slot(id: u32) -> u32 {
        id & 0x00FF_FFFF
    }
    /// Extracts the generation byte from a packed entity id.
    pub fn unpack_gen(id: u32) -> u8 {
        (id >> 24) as u8
    }
}
