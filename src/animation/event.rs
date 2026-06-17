//! Defines the event payload contract emitted by animation playback state transitions. `animation/event` delivers the event implementation for the animation subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Captures completion, loop, and frame-change signals as stable timeline reaction points. The file owns or coordinates data contracts including `AnimEvent`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Serves gameplay and scripting systems that listen to animation progression milestones. Public callable behavior is centered on no named public items, while method-level behavior such as `type_name`, `frame_index` stays attached to the local data model and invariants.

/// Event emitted by `Animation`.
#[derive(Debug, Clone, PartialEq)]
pub enum AnimEvent {
    /// Playback finished.
    Finished,
    /// Frame index changed.
    FrameChanged {
        /// New frame index.
        frame_index: usize,
    },
    /// Playback wrapped back to the start.
    Looped,
}
impl AnimEvent {
    /// Return the canonical event type name.
    pub fn type_name(&self) -> &'static str {
        match self {
            Self::Finished => "finished",
            Self::FrameChanged { .. } => "frameChanged",
            Self::Looped => "looped",
        }
    }
    /// Return the frame index for `FrameChanged`, or `None` for other events.
    pub fn frame_index(&self) -> Option<usize> {
        match self {
            Self::FrameChanged { frame_index } => Some(*frame_index),
            _ => None,
        }
    }
}
