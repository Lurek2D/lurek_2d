//! Reinforcement learning environment abstractions following Gym-style conventions enabling training of generic agents on Lurek2D game tasks.
//! Defines SpaceSpec descriptors for action and observation spaces with shape, bounds, and discrete action counts supporting policy network design.
//! Implements FrameStack buffer accumulating historical observations into temporal context vectors required by recurrent and attention-based policies.
//! Standardizes reset() and step() interaction contracts matching OpenAI Gym patterns for seamless integration with popular RL frameworks.

/// Space descriptor shared by observation and action spaces.
#[derive(Debug, Clone)]
pub struct SpaceSpec {
    /// Shape as list of dimensions.
    pub shape: Vec<u32>,
    /// Lower bound per-dimension (broadcasts if len == 1).
    pub low: Vec<f32>,
    /// Upper bound per-dimension (broadcasts if len == 1).
    pub high: Vec<f32>,
    /// Number of discrete actions (for discrete action spaces; 0 = not discrete).
    pub n: u32,
}

/// Frame stacking ring buffer for history-based observations.
pub struct FrameStack {
    capacity: usize,
    obs_dim: usize,
    frames: Vec<Vec<f32>>,
}

impl FrameStack {
    /// Creates a new empty frame stack with the given capacity.
    pub fn new(n: usize) -> Self {
        Self {
            capacity: n.max(1),
            obs_dim: 0,
            frames: Vec::new(),
        }
    }

    /// Pushes an observation, discarding the oldest if at capacity.
    pub fn push(&mut self, obs: Vec<f32>) {
        if self.obs_dim == 0 {
            self.obs_dim = obs.len();
        }
        self.frames.push(obs);
        if self.frames.len() > self.capacity {
            self.frames.remove(0);
        }
    }

    /// Returns the flattened stack. Returns empty when no observation has been pushed yet.
    /// Pads with zeros if fewer than capacity frames are present.
    pub fn get(&self) -> Vec<f32> {
        if self.obs_dim == 0 {
            return Vec::new();
        }
        let mut out = Vec::with_capacity(self.capacity * self.obs_dim);
        for f in &self.frames {
            out.extend_from_slice(f);
        }
        let target = self.capacity * self.obs_dim;
        out.resize(target, 0.0);
        out
    }

    /// Clears all stored frames and resets the observed dimension.
    pub fn reset(&mut self) {
        self.frames.clear();
        self.obs_dim = 0;
    }

    /// Returns the maximum number of frames retained.
    pub fn capacity(&self) -> usize {
        self.capacity
    }
}
