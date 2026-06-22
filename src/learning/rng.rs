//! Owns learning behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps learning data ownership and helper behavior clear for future engine maintenance. for engine changes.
//! Defines how rng data is validated, transformed, or stored before neighboring systems use it.
//! Owns learning behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on rng behavior while Lua registration stays elsewhere.

use super::error::LearningError;

/// Current snapshot format version for the learning RNG contract.
pub const LEARNING_RNG_VERSION: u32 = 1;

/// Serializable RNG snapshot for reproducible learning replays.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct LearningRngSnapshot {
    /// Snapshot schema version.
    pub version: u32,
    /// Exact internal RNG state.
    pub state: u64,
}

/// Deterministic xorshift-based RNG shared by learning components.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct LearningRng {
    state: u64,
}

impl LearningRng {
    /// Create a deterministic RNG from a caller-provided seed.
    pub fn new(seed: u64) -> Self {
        Self {
            state: seed.wrapping_add(1),
        }
    }

    /// Restore a deterministic RNG from an exact saved snapshot.
    pub fn from_snapshot(snapshot: LearningRngSnapshot) -> Result<Self, LearningError> {
        if snapshot.version != LEARNING_RNG_VERSION {
            return Err(LearningError::UnsupportedVersion {
                context: "learning RNG snapshot",
                version: snapshot.version,
            });
        }
        Ok(Self {
            state: normalize_state(snapshot.state),
        })
    }

    /// Return the current exact replay snapshot.
    pub fn snapshot(&self) -> LearningRngSnapshot {
        LearningRngSnapshot {
            version: LEARNING_RNG_VERSION,
            state: self.state,
        }
    }

    /// Overwrite the internal state with an exact saved snapshot.
    pub fn restore(&mut self, snapshot: LearningRngSnapshot) -> Result<(), LearningError> {
        *self = Self::from_snapshot(snapshot)?;
        Ok(())
    }

    /// Advance the RNG and return the next raw 64-bit sample.
    pub fn next_u64(&mut self) -> u64 {
        self.state = xorshift64(normalize_state(self.state));
        self.state
    }

    /// Return a bounded integer in `[0, n)`.
    pub fn next_index(&mut self, n: usize) -> Result<usize, LearningError> {
        if n == 0 {
            return Err(LearningError::ZeroCount {
                field: "rng upper bound",
            });
        }
        Ok((self.next_u64() as usize) % n)
    }

    /// Return a uniform float in `[0, 1)`.
    pub fn next_f32(&mut self) -> f32 {
        (self.next_u64() >> 11) as f32 * (1.0 / (1u64 << 53) as f32)
    }

    /// Return a uniform double in `[0, 1)`.
    pub fn next_f64(&mut self) -> f64 {
        (self.next_u64() >> 11) as f64 * (1.0 / (1u64 << 53) as f64)
    }

    /// Return a standard-normal float using Box-Muller.
    pub fn normal_f32(&mut self) -> f32 {
        let u1 = self.next_f32().max(1e-7);
        let u2 = self.next_f32();
        (-2.0 * u1.ln()).sqrt() * (2.0 * std::f32::consts::PI * u2).cos()
    }

    /// Return a standard-normal double using Box-Muller.
    pub fn normal_f64(&mut self) -> f64 {
        let u1 = self.next_f64().max(1e-15);
        let u2 = self.next_f64();
        (-2.0 * u1.ln()).sqrt() * (2.0 * std::f64::consts::PI * u2).cos()
    }
}

fn normalize_state(state: u64) -> u64 {
    if state == 0 {
        1
    } else {
        state
    }
}

fn xorshift64(mut x: u64) -> u64 {
    x ^= x << 13;
    x ^= x >> 7;
    x ^= x << 17;
    x
}
