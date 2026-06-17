//! Defines source-level audio metadata and spatial attributes used by mixer-side playback control. `audio/source` delivers the source implementation for the audio subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Encapsulates position, velocity, and orientation state for positional and motion-aware rendering. The file owns or coordinates data contracts including `SpatialState`, `AudioSource`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Stores identity and basic playback defaults that classify each loaded runtime source. Public callable behavior is centered on no named public items, while method-level behavior such as `new` stays attached to the local data model and invariants.

use crate::log_msg;
use crate::runtime::log_messages::AS01;
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
