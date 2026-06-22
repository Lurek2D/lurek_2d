//! Owns the lcg owner for the procgen subsystem and keeps its rules local to this file while keeping call sites explicit.
//! Centers the implementation around LCG_ALGORITHM_VERSION, Lcg, new, with helpers kept close to their invariants.
//! Defines how lcg data is validated, transformed, or stored before neighboring systems use it.
//! Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.

/// Stable identifier for the current procgen LCG stepping contract.
pub const LCG_ALGORITHM_VERSION: u32 = 1;

/// 64-bit LCG RNG seeded deterministically; used throughout `procgen` for reproducible results.
pub struct Lcg {
    /// Current generator state; mutated by each call to `next`.
    state: u64,
}

/// Core LCG construction and stepping methods.
impl Lcg {
    /// Create an LCG seeded with `seed` (internal state = seed + 1 to avoid zero-state).
    pub fn new(seed: u64) -> Self {
        Self {
            state: seed.wrapping_add(1),
        }
    }

    /// Create an LCG from an exact saved internal state snapshot.
    pub fn from_state(state: u64) -> Self {
        Self { state }
    }

    /// Return the stable algorithm version for serialization or deterministic docs.
    pub fn algorithm_version() -> u32 {
        LCG_ALGORITHM_VERSION
    }

    /// Advance the LCG by one step and return the next raw `u64` output.
    #[allow(clippy::should_implement_trait)]
    pub fn next(&mut self) -> u64 {
        self.next_u64()
    }

    /// Advance the LCG by one step and return the next raw `u64` output.
    pub fn next_u64(&mut self) -> u64 {
        self.state = self
            .state
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        self.state
    }

    /// Advance and return a uniform float in 0.0..1.0 using the upper 31 bits.
    pub fn next_f32(&mut self) -> f32 {
        (self.next_u64() >> 33) as f32 / (1u64 << 31) as f32
    }

    /// Advance and return a uniform float in 0.0..1.0 using the upper 53 bits.
    pub fn next_f64(&mut self) -> f64 {
        (self.next_u64() >> 11) as f64 / (1u64 << 53) as f64
    }

    /// Return the current exact internal state for deterministic restore.
    pub fn state(&self) -> u64 {
        self.state
    }

    /// Overwrite the internal state with an exact saved snapshot.
    pub fn set_state(&mut self, state: u64) {
        self.state = state;
    }

    /// Return a uniform integer in `[0, upper_exclusive)` using rejection sampling to avoid modulo bias.
    pub fn next_bounded_u32(&mut self, upper_exclusive: u32) -> u32 {
        if upper_exclusive <= 1 {
            return 0;
        }
        let upper = u64::from(upper_exclusive);
        let zone = u64::MAX - u64::MAX % upper;
        loop {
            let value = self.next_u64();
            if value < zone {
                return (value % upper) as u32;
            }
        }
    }

    /// Return a uniform index in `[0, len)`, or 0 when `len <= 1`.
    pub fn next_index(&mut self, len: usize) -> usize {
        if len <= 1 {
            return 0;
        }
        let len_u32 = u32::try_from(len).unwrap_or(u32::MAX);
        usize::try_from(self.next_bounded_u32(len_u32)).unwrap_or(0)
    }
}
