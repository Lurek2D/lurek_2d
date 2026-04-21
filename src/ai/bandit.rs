//! Multi-armed bandit algorithms for AI exploration/exploitation decisions.
//!
//! Provides three classic bandit strategies for online decision-making where an
//! agent must choose among K arms (actions) with unknown reward distributions:
//! - **EpsilonGreedy** — explore randomly with probability ε, else exploit best.
//! - **UCB1** — Upper Confidence Bound balancing exploration via
//!   `μ + √(2 ln N / n)`.
//! - **ThompsonSampling** — Bayesian Beta-distribution sampling.
//!
//! Typical game uses: ability/item selection, dialogue topic choice,
//! procedural event weighting, A/B test routing.
//!
//! ## Architecture
//!
//! - [`BanditArm`] tracks pulls, total reward, and Beta distribution parameters
//!   for Thompson sampling.
//! - [`BanditStrategy`] selects which selection algorithm to run.
//! - [`Bandit`] owns the arm list, total pull count, and PRNG state.
//!
//! ## Typical Usage Sequence
//!
//! 1. Create `Bandit::new(arm_count, strategy, seed)`.
//! 2. Call `select()` to choose an arm index.
//! 3. Execute the chosen action and observe the reward (`0.0` or `1.0` for
//!    binary outcomes; any `[0, 1]` value for continuous).
//! 4. Call `update(arm_index, reward)` to record the outcome.
//! 5. Repeat forever; exploit with `best_arm()` when done exploring.

// ────────────────────────────────────────────────────────────────────────────
// BanditArm
// ────────────────────────────────────────────────────────────────────────────

/// One arm in a multi-armed bandit.
///
/// # Fields
/// - `pulls` — `u32`.
/// - `total_reward` — `f64`.
/// - `alpha` — `f64`.
/// - `beta` — `f64`.
/// - `label` — `Option<String>`.
#[derive(Clone)]
pub struct BanditArm {
    /// Number of times this arm has been pulled.
    pub pulls: u32,
    /// Cumulative reward received from this arm.
    pub total_reward: f64,
    /// Beta distribution alpha parameter (successes + 1 for Thompson sampling).
    pub alpha: f64,
    /// Beta distribution beta parameter (failures + 1 for Thompson sampling).
    pub beta: f64,
    /// Optional human-readable label for the action this arm represents.
    pub label: Option<String>,
}

impl BanditArm {
    /// Returns the mean estimated reward (0.5 when unpulled).
    ///
    /// # Returns
    /// `f64`.
    pub fn mean_reward(&self) -> f64 {
        if self.pulls == 0 { 0.5 } else { self.total_reward / self.pulls as f64 }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// BanditStrategy
// ────────────────────────────────────────────────────────────────────────────

/// Arm selection algorithm for a [`Bandit`].
///
/// # Variants
/// - `EpsilonGreedy` — EpsilonGreedy variant.
/// - `UCB1` — UCB1 variant.
/// - `ThompsonSampling` — ThompsonSampling variant.
#[derive(Clone, Copy, Debug)]
pub enum BanditStrategy {
    /// Exploit best arm with probability `1-ε`, explore randomly with probability `ε`.
    EpsilonGreedy {
        /// Explore probability (0.0 = always exploit; 1.0 = always random).
        epsilon: f32,
    },
    /// Upper Confidence Bound 1: chooses arm with highest `μ + √(2 ln N / n)`.
    UCB1,
    /// Thompson Sampling: draws from each arm's Beta distribution, picks argmax.
    ThompsonSampling,
}

// ────────────────────────────────────────────────────────────────────────────
// Bandit
// ────────────────────────────────────────────────────────────────────────────

/// Multi-armed bandit with configurable exploration strategy.
///
/// # Fields
/// - `arms` — `Vec<BanditArm>`.
/// - `strategy` — `BanditStrategy`.
/// - `total_pulls` — `u64`.
pub struct Bandit {
    /// All arms in this bandit.
    pub arms: Vec<BanditArm>,
    /// Active selection strategy.
    pub strategy: BanditStrategy,
    /// Total number of `select` + `update` pairs completed.
    pub total_pulls: u64,
    rng: u64,
}

impl Bandit {
    /// Creates a new bandit with `arm_count` arms and the given strategy.
    ///
    /// # Parameters
    /// - `arm_count` — `usize`.
    /// - `strategy` — `BanditStrategy`.
    /// - `seed` — `u64`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(arm_count: usize, strategy: BanditStrategy, seed: u64) -> Self {
        let arms = (0..arm_count)
            .map(|_| BanditArm { pulls: 0, total_reward: 0.0, alpha: 1.0, beta: 1.0, label: None })
            .collect();
        Self { arms, strategy, total_pulls: 0, rng: seed }
    }

    /// Returns the number of arms.
    ///
    /// # Returns
    /// `usize`.
    pub fn arm_count(&self) -> usize { self.arms.len() }

    /// Selects an arm index using the configured strategy.
    ///
    /// # Returns
    /// `usize`.
    pub fn select(&mut self) -> usize {
        let n = self.arms.len();
        match self.strategy {
            BanditStrategy::EpsilonGreedy { epsilon } => {
                if self.rand_f32() < epsilon {
                    self.rand_usize(n)
                } else {
                    self.best_arm()
                }
            }
            BanditStrategy::UCB1 => {
                // Force any unpulled arm first
                if let Some(i) = self.arms.iter().position(|a| a.pulls == 0) {
                    return i;
                }
                let total = self.total_pulls as f64;
                (0..n).max_by(|&a, &b| {
                    let ucb = |arm: &BanditArm| arm.mean_reward() + (2.0 * total.ln() / arm.pulls as f64).sqrt();
                    ucb(&self.arms[a]).partial_cmp(&ucb(&self.arms[b])).unwrap()
                }).unwrap_or(0)
            }
            BanditStrategy::ThompsonSampling => {
                // Sample from each arm's Beta distribution and pick argmax
                let arm_data: Vec<(f64, f64)> = self.arms.iter().map(|a| (a.alpha, a.beta)).collect();
                let samples: Vec<f64> = arm_data.iter()
                    .map(|&(alpha, beta)| self.beta_sample(alpha, beta))
                    .collect();
                samples.iter().enumerate()
                    .max_by(|a, b| a.1.partial_cmp(b.1).unwrap())
                    .map(|(i, _)| i)
                    .unwrap_or(0)
            }
        }
    }

    /// Records the observed `reward` for arm `index` and updates arm statistics.
    ///
    /// `reward` should be in `[0.0, 1.0]`.
    ///
    /// # Parameters
    /// - `index` — `usize`.
    /// - `reward` — `f64`.
    pub fn update(&mut self, index: usize, reward: f64) {
        if index >= self.arms.len() { return; }
        let arm = &mut self.arms[index];
        arm.pulls += 1;
        arm.total_reward += reward;
        arm.alpha += reward;
        arm.beta += 1.0 - reward;
        self.total_pulls += 1;
    }

    /// Returns the index of the arm with the highest mean reward.
    ///
    /// # Returns
    /// `usize`.
    pub fn best_arm(&self) -> usize {
        (0..self.arms.len())
            .max_by(|&a, &b| self.arms[a].mean_reward().partial_cmp(&self.arms[b].mean_reward()).unwrap())
            .unwrap_or(0)
    }

    /// Resets all arm statistics while keeping arm count and strategy.
    pub fn reset(&mut self) {
        for arm in &mut self.arms {
            arm.pulls = 0;
            arm.total_reward = 0.0;
            arm.alpha = 1.0;
            arm.beta = 1.0;
        }
        self.total_pulls = 0;
    }

    // ── PRNG helpers ────────────────────────────────────────────────────────

    fn rand_usize(&mut self, n: usize) -> usize {
        self.rng = xorshift64(self.rng);
        (self.rng as usize) % n
    }

    fn rand_f32(&mut self) -> f32 {
        self.rng = xorshift64(self.rng);
        (self.rng >> 11) as f32 * (1.0 / (1u64 << 53) as f32)
    }

    /// Approximate Beta(α, β) sample via ratio-of-uniforms method.
    fn beta_sample(&mut self, alpha: f64, beta: f64) -> f64 {
        // Use Gamma approximation: Beta(a,b) = G(a) / (G(a)+G(b))
        let ga = self.gamma_sample(alpha);
        let gb = self.gamma_sample(beta);
        if ga + gb < 1e-15 { 0.5 } else { ga / (ga + gb) }
    }

    /// Marsaglia & Tsang Gamma(shape) sampler. Shape must be >= 1.
    fn gamma_sample(&mut self, shape: f64) -> f64 {
        if shape < 1.0 {
            return self.gamma_sample(1.0 + shape) * self.rand_f64().powf(1.0 / shape);
        }
        let d = shape - 1.0 / 3.0;
        let c = 1.0 / (9.0 * d).sqrt();
        loop {
            let z = self.normal_f64();
            let v_raw = 1.0 + c * z;
            if v_raw <= 0.0 { continue; }
            let v = v_raw * v_raw * v_raw;
            let u = self.rand_f64();
            if u < 1.0 - 0.0331 * z * z * z * z { return d * v; }
            if u.ln() < 0.5 * z * z + d * (1.0 - v + v.ln()) { return d * v; }
        }
    }

    fn rand_f64(&mut self) -> f64 {
        self.rng = xorshift64(self.rng);
        (self.rng >> 11) as f64 * (1.0 / (1u64 << 53) as f64)
    }

    fn normal_f64(&mut self) -> f64 {
        let u1 = self.rand_f64().max(1e-15);
        let u2 = self.rand_f64();
        (-2.0 * u1.ln()).sqrt() * (2.0 * std::f64::consts::PI * u2).cos()
    }
}

/// Xorshift64 PRNG step.
fn xorshift64(mut x: u64) -> u64 {
    x ^= x << 13;
    x ^= x >> 7;
    x ^= x << 17;
    x
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn new_bandit_defaults() {
        let b = Bandit::new(3, BanditStrategy::EpsilonGreedy { epsilon: 0.1 }, 42);
        assert_eq!(b.arm_count(), 3);
    }

    #[test]
    fn select_returns_valid_arm() {
        let mut b = Bandit::new(4, BanditStrategy::EpsilonGreedy { epsilon: 0.1 }, 42);
        let arm = b.select();
        assert!(arm < 4);
    }

    #[test]
    fn update_and_best_arm() {
        let mut b = Bandit::new(3, BanditStrategy::EpsilonGreedy { epsilon: 0.1 }, 42);
        b.update(0, 0.5);
        b.update(1, 2.0);
        b.update(2, 0.1);
        assert_eq!(b.best_arm(), 1);
    }

    #[test]
    fn reset_clears_state() {
        let mut b = Bandit::new(2, BanditStrategy::EpsilonGreedy { epsilon: 0.1 }, 42);
        b.update(0, 1.0);
        b.reset();
        assert_eq!(b.arm_count(), 2);
    }
}
