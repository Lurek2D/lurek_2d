//! Implements lightweight xorshift64 random generation used by dataframe-local sampling utilities. `dataframe/rng` delivers the rng implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Produces deterministic integer, float, and index outputs from a compact 64-bit state. The file owns or coordinates data contracts including `Xorshift64`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Remaps zero seed values to prevent degenerate all-zero generator behavior. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `next_u64`, `next_f64`, `next_usize` stays attached to the local data model and invariants.

/// Hold xorshift64 state used by dataframe-local random helpers.
pub(crate) struct Xorshift64 {
    /// Store current PRNG state word.
    state: u64,
}
impl Xorshift64 {
    /// Create generator from seed and remap zero seed to one.
    pub(crate) fn new(seed: u64) -> Self {
        Self {
            state: if seed == 0 { 1 } else { seed },
        }
    }
    /// Advance generator and return next 64-bit pseudo-random value.
    pub(crate) fn next_u64(&mut self) -> u64 {
        let mut x = self.state;
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        self.state = x;
        x
    }
    /// Return pseudo-random float in the half-open range [0, 1).
    pub(crate) fn next_f64(&mut self) -> f64 {
        (self.next_u64() & 0x001F_FFFF_FFFF_FFFF) as f64 / (1u64 << 53) as f64
    }
    /// Return pseudo-random index in the half-open range [0, max).
    pub(crate) fn next_usize(&mut self, max: usize) -> usize {
        (self.next_u64() % max as u64) as usize
    }
}
