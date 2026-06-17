//! This file provides bitflag storage for per-region visibility-related feature markers. `visibility/flags` delivers the flags implementation for the visibility subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! It encodes what information layers are present or unlocked for each map region. The file owns or coordinates data contracts including `VisibilityFlags`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! It supports gated reveal logic by combining flag checks with discovery progression rules. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `set`, `has`, `union`, `intersect`, `count` stays attached to the local data model and invariants.

/// Bitfield flags controlling what is visible per region.
/// Games define their own flag semantics (e.g., bit 0 = terrain, bit 1 = units).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub struct VisibilityFlags(pub u64);

impl VisibilityFlags {
    /// No flags set — tile is fully hidden.
    pub const NONE: Self = Self(0);
    /// All flags set — fully visible.
    pub const ALL: Self = Self(u64::MAX);

    /// Create a new `VisibilityFlags` with no flags set.
    pub fn new() -> Self {
        Self(0)
    }

    /// Set or clear the flag at bit position `bit` (0–63).
    pub fn set(&mut self, bit: u8, value: bool) {
        let mask = 1u64 << (bit.min(63) as u64);
        if value {
            self.0 |= mask;
        } else {
            self.0 &= !mask;
        }
    }

    /// Return `true` if the flag at bit position `bit` is set.
    pub fn has(&self, bit: u8) -> bool {
        self.0 & (1u64 << (bit.min(63) as u64)) != 0
    }

    /// Return the bitwise OR of two flag sets.
    pub fn union(self, other: Self) -> Self {
        Self(self.0 | other.0)
    }

    /// Return the bitwise AND of two flag sets.
    pub fn intersect(self, other: Self) -> Self {
        Self(self.0 & other.0)
    }

    /// Return the number of flags currently set (popcount).
    pub fn count(&self) -> u32 {
        self.0.count_ones()
    }
}
