//! Linear congruential generator for deterministic procgen.
//!
//! Internal helper used by cellular automata, Voronoi, and Poisson disk modules.

/// Simple LCG (Linear Congruential Generator) for deterministic random numbers.
pub(crate) struct Lcg {
    state: u64,
}

impl Lcg {
    /// Creates a new LCG seeded with the given value.
    ///
    /// # Parameters
    /// - `seed` — `u64`. Initial state seed.
    ///
    /// # Returns
    /// `Self`.
    pub(crate) fn new(seed: u64) -> Self {
        Self {
            state: seed.wrapping_add(1),
        }
    }

    /// Returns the next pseudo-random `u64`.
    ///
    /// # Returns
    /// `u64`.
    pub(crate) fn next(&mut self) -> u64 {
        self.state = self
            .state
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        self.state
    }

    /// Returns the next pseudo-random `f32` in [0, 1).
    ///
    /// # Returns
    /// `f32`.
    pub(crate) fn next_f32(&mut self) -> f32 {
        (self.next() >> 33) as f32 / (1u64 << 31) as f32
    }
}

// NOTE: Tests private internals — stays inline
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn deterministic_same_seed() {
        let mut a = Lcg::new(42);
        let mut b = Lcg::new(42);
        for _ in 0..10 {
            assert_eq!(a.next(), b.next());
        }
    }

    #[test]
    fn different_seeds_diverge() {
        let mut a = Lcg::new(1);
        let mut b = Lcg::new(2);
        assert_ne!(a.next(), b.next());
    }

    #[test]
    fn next_f32_in_unit_range() {
        let mut rng = Lcg::new(0);
        for _ in 0..100 {
            let v = rng.next_f32();
            assert!(v >= 0.0 && v < 1.0, "value out of [0,1): {v}");
        }
    }
}
