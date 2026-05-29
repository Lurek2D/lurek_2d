//! Defines reusable animation clip metadata over frame spans, playback direction, and loop policy.
//! Carries baseline timing settings that playback systems use when frame durations are unspecified.
//! Serves as a compact contract shared by controller, state-machine, and blend-layer orchestration.

/// Supported clip playback modes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ClipPlaybackMode {
    /// Play frames forward.
    Forward,
    /// Play frames backward.
    Reverse,
    /// Bounce between ends.
    PingPong,
}
/// Named animation clip referencing frame indices.
#[derive(Debug, Clone)]
pub struct AnimClip {
    /// Clip name.
    pub name: String,
    /// Indices into the frame list.
    pub frame_indices: Vec<usize>,
    /// Frames per second used when frame durations are absent.
    pub fps: f32,
    /// Whether the clip loops.
    pub looping: bool,
    /// Playback mode.
    pub mode: ClipPlaybackMode,
}
