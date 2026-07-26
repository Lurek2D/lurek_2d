//! This file owns `SpatialState` and `AudioSource`, the basic source metadata used by the audio runtime.
//! It stores source identity, asset path, default volume, looping intent, plus 3D position, velocity, and orientation.
//! The file is purely data-oriented; active playback, sinks, buses, and listener state are owned by the mixer.
//! Listener and spatial-result records remain neutral values that let bindings expose mixer calculations safely.
//! Open it when per-source metadata semantics change; runtime routing and queueing live in sibling audio files.

use crate::log_msg;
use crate::runtime::log_messages::AS01;

/// One neutral spatial listener owned by the audio mixer.
#[derive(Debug, Clone, PartialEq)]
pub struct SpatialListener {
    /// Stable caller-provided listener identifier.
    pub id: String,
    /// Listener position as `[x, y, z]`.
    pub position: [f32; 3],
    /// Listener velocity as `[vx, vy, vz]`.
    pub velocity: [f32; 3],
    /// Positive contribution weight used by weighted policies.
    pub weight: f32,
}

/// Policy used to reduce one source against the configured listener set.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SpatialListenerPolicy {
    /// Use only the nearest allowed listener.
    Nearest,
    /// Blend every allowed listener without amplifying the source count.
    Weighted,
    /// Blend only listeners explicitly selected by the source mask.
    Manual,
}

impl SpatialListenerPolicy {
    /// Return the stable Lua-facing policy name.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Nearest => "nearest",
            Self::Weighted => "weighted",
            Self::Manual => "manual",
        }
    }
}

/// Deterministic effective spatial values for one source.
#[derive(Debug, Clone, PartialEq)]
pub struct SourceSpatialResult {
    /// Policy used for this calculation.
    pub policy: SpatialListenerPolicy,
    /// Whether the source has spatial state.
    pub spatial: bool,
    /// Bounded attenuation multiplier.
    pub gain: f32,
    /// Bounded spatial pan before authored pan is added.
    pub pan: f32,
    /// Selected or blended listener distance.
    pub distance: f32,
    /// Single selected listener for nearest policy.
    pub listener_id: Option<String>,
    /// Contributing listener IDs in configured order.
    pub listener_ids: Vec<String>,
}
#[derive(Debug, Clone, Copy)]
/// 3D spatial attributes used for panning/attenuation and doppler calculations.
///
/// # Fields
pub struct SpatialState {
    /// Source position as `[x, y, z]`.
    pub position: [f32; 3],
    /// Source velocity as `[vx, vy, vz]`.
    pub velocity: [f32; 3],
    /// Forward/up orientation vectors packed as `[fx, fy, fz, ux, uy, uz]`.
    pub orientation: [f32; 6],
}
/// `Default` impl: zero position/velocity, forward -Z, up +Y.
impl Default for SpatialState {
    /// Create default spatial state suitable for non-spatialised playback.
    fn default() -> Self {
        SpatialState {
            position: [0.0, 0.0, 0.0],
            velocity: [0.0, 0.0, 0.0],
            orientation: [0.0, 0.0, -1.0, 0.0, 1.0, 0.0],
        }
    }
}
/// Basic audio source metadata exposed to scripting and tools.
///
/// # Fields
pub struct AudioSource {
    /// Stable source identifier assigned by the caller.
    pub id: usize,
    /// Asset path to the source audio file.
    pub file_path: String,
    /// Per-source gain multiplier.
    pub volume: f32,
    /// Whether playback should loop when used directly.
    pub looping: bool,
}
impl AudioSource {
    /// Create a new source descriptor with volume=1.0 and looping disabled.
    pub fn new(id: usize, file_path: &str) -> Self {
        log_msg!(debug, AS01, "{}", file_path);
        AudioSource {
            id,
            file_path: file_path.to_string(),
            volume: 1.0,
            looping: false,
        }
    }
}
