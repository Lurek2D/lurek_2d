//! 64-bit linear congruential generator (LCG) for deterministic pseudo-random number output.
//!
//! - Provides seeded construction, raw `u64` stepping, and uniform `f32` sampling.
//! - Used as the shared RNG primitive across all `procgen` subsystems.

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

    /// Advance the LCG by one step and return the next raw `u64` output.
    #[allow(clippy::should_implement_trait)]
    pub fn next(&mut self) -> u64 {
        self.state = self
            .state
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        self.state
    }

    /// Advance and return a uniform float in 0.0–1.0 using the upper 31 bits.
    pub fn next_f32(&mut self) -> f32 {
        (self.next() >> 33) as f32 / (1u64 << 31) as f32
    }
}
