//! Seedable pseudo-random number generator wrapping `fastrand` with save/restore support.
//!
//! - Data type: `RandomGenerator`.
//! - Implementation: `RandomGenerator`.

use fastrand::Rng;

/// Seedable RNG wrapping `fastrand::Rng` with stored seed for serialisation.
pub struct RandomGenerator {
    /// The underlying fast RNG state.
    rng: Rng,
    /// Seed value recorded at construction or last `set_seed` call.
    seed: u64,
}
impl RandomGenerator {
    /// Construct a generator with an arbitrary unseeded initial state (seed stored as 0).
    pub fn new() -> Self {
        let rng = Rng::new();
        Self { seed: 0, rng }
    }
    /// Construct a generator from an explicit `seed`.
    pub fn with_seed(seed: u64) -> Self {
        let rng = Rng::with_seed(seed);
        Self { seed, rng }
    }
    /// Return a uniform random `f64` in `[0.0, 1.0)`.
    pub fn random(&mut self) -> f64 {
        self.rng.f64()
    }
    /// Return a uniform random integer in the closed range `[min, max]`; returns `min` when `min >= max`.
    pub fn random_int(&mut self, min: i64, max: i64) -> i64 {
        if min >= max {
            return min;
        }
        let range = (max - min + 1) as u64;
        min + (self.rng.u64(0..range)) as i64
    }
    /// Return a uniform random `f64` in `[min, max)`.
    pub fn random_float(&mut self, min: f64, max: f64) -> f64 {
        min + self.rng.f64() * (max - min)
    }
    /// Return a Gaussian-distributed `f64` with `mean` and `stddev` using Box-Muller transform.
    pub fn random_normal(&mut self, stddev: f64, mean: f64) -> f64 {
        let u1 = self.rng.f64().max(f64::MIN_POSITIVE);
        let u2 = self.rng.f64();
        let z = (-2.0 * u1.ln()).sqrt() * (2.0 * std::f64::consts::PI * u2).cos();
        mean + z * stddev
    }
    /// Re-seed the generator, resetting both the stored seed and the RNG state.
    pub fn set_seed(&mut self, seed: u64) {
        self.seed = seed;
        self.rng = Rng::with_seed(seed);
    }
    /// Return the seed last set via `with_seed` or `set_seed`.
    pub fn get_seed(&self) -> u64 {
        self.seed
    }
    /// Serialise the current seed to a string for save-file persistence.
    pub fn get_state(&self) -> String {
        format!("{}", self.seed)
    }
    /// Restore the seed from a previously serialised state string; returns error on parse failure.
    pub fn set_state(&mut self, state: &str) -> Result<(), String> {
        let seed: u64 = state
            .parse()
            .map_err(|_| format!("Invalid state string: {}", state))?;
        self.set_seed(seed);
        Ok(())
    }
    /// Roll one N-sided die (1 to sides inclusive). Returns 1 when sides < 1.
    pub fn roll(&mut self, sides: u32) -> i64 {
        if sides < 1 {
            return 1;
        }
        self.random_int(1, sides as i64)
    }
    /// Roll count N-sided dice. Returns vec of individual results.
    /// count and sides are clamped to [1, 1000].
    pub fn roll_n(&mut self, count: u32, sides: u32) -> Vec<i64> {
        let count = count.clamp(1, 1000);
        let sides = sides.max(1);
        (0..count).map(|_| self.roll(sides)).collect()
    }
    /// Roll count N-sided dice and return their sum.
    pub fn roll_sum(&mut self, count: u32, sides: u32) -> i64 {
        self.roll_n(count, sides).iter().sum()
    }
    /// Roll count N-sided dice and sum the highest `keep` results.
    /// keep is clamped to [1, count].
    pub fn roll_keep_highest(&mut self, count: u32, sides: u32, keep: u32) -> i64 {
        let mut results = self.roll_n(count, sides);
        results.sort_unstable_by(|a, b| b.cmp(a));
        let keep = (keep as usize).min(results.len()).max(1);
        results[..keep].iter().sum()
    }
    /// Roll count N-sided dice and sum the lowest `keep` results.
    /// keep is clamped to [1, count].
    pub fn roll_keep_lowest(&mut self, count: u32, sides: u32, keep: u32) -> i64 {
        let mut results = self.roll_n(count, sides);
        results.sort_unstable();
        let keep = (keep as usize).min(results.len()).max(1);
        results[..keep].iter().sum()
    }
    /// Roll two N-sided dice and return the higher value (advantage).
    pub fn roll_advantage(&mut self, sides: u32) -> i64 {
        let a = self.roll(sides);
        let b = self.roll(sides);
        a.max(b)
    }
    /// Roll two N-sided dice and return the lower value (disadvantage).
    pub fn roll_disadvantage(&mut self, sides: u32) -> i64 {
        let a = self.roll(sides);
        let b = self.roll(sides);
        a.min(b)
    }
    /// Roll count N-sided exploding dice: when a die shows maximum, roll again and add.
    /// Total reroll cap is 1000 to prevent infinite loops.
    pub fn roll_exploding(&mut self, count: u32, sides: u32) -> i64 {
        let count = count.clamp(1, 1000);
        let sides = sides.max(1);
        let max_val = sides as i64;
        let mut total: i64 = 0;
        let mut rerolls_remaining: u32 = 1000;
        for _ in 0..count {
            let mut val = self.roll(sides);
            total += val;
            while val == max_val && rerolls_remaining > 0 {
                rerolls_remaining -= 1;
                val = self.roll(sides);
                total += val;
            }
        }
        total
    }
    /// Roll count N-sided dice and count how many results are >= target.
    pub fn count_successes(&mut self, count: u32, sides: u32, target: i64) -> u32 {
        self.roll_n(count, sides)
            .iter()
            .filter(|&&v| v >= target)
            .count() as u32
    }
    /// Return true with the given probability (0.0 = never, 1.0 = always).
    /// probability is clamped to [0.0, 1.0].
    pub fn chance(&mut self, probability: f64) -> bool {
        let p = probability.clamp(0.0, 1.0);
        self.random() < p
    }
}
/// Clone by constructing a new generator with the same stored seed.
impl Clone for RandomGenerator {
    fn clone(&self) -> Self {
        Self::with_seed(self.seed)
    }
}
/// Provide a default unseeded generator via `new()`.
impl Default for RandomGenerator {
    fn default() -> Self {
        Self::new()
    }
}
