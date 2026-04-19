//! [`AnimEvent`] — events emitted during animation playback.

/// Events emitted by [`Animation::update`](crate::animation::Animation::update).
///
/// # Variants
/// - `Finished` — Finished variant.
/// - `FrameChanged` — FrameChanged variant.
/// - `Looped` — Looped variant.
///
/// Retrieve pending events with [`Animation::drain_events`](crate::animation::Animation::drain_events).
#[derive(Debug, Clone, PartialEq)]
pub enum AnimEvent {
    /// A non-looping clip reached its final frame and stopped.
    Finished,
    /// The active frame changed to `frame_index` (position within the clip's
    /// `frame_indices` list).
    FrameChanged {
        /// 0-based index within the clip's frame list.
        frame_index: usize,
    },
    /// A looping clip wrapped back to its first frame.
    Looped,
}

impl AnimEvent {
    /// Returns the event type as a Lua-friendly string.
    ///
    /// # Returns
    /// `&'static str`.
    pub fn type_name(&self) -> &'static str {
        match self {
            Self::Finished => "finished",
            Self::FrameChanged { .. } => "frameChanged",
            Self::Looped => "looped",
        }
    }

    /// Returns the frame index for `FrameChanged` events, or `None`.
    ///
    /// # Returns
    /// `Option<usize>`.
    pub fn frame_index(&self) -> Option<usize> {
        match self {
            Self::FrameChanged { frame_index } => Some(*frame_index),
            _ => None,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn type_name_finished() {
        assert_eq!(AnimEvent::Finished.type_name(), "finished");
    }

    #[test]
    fn type_name_looped() {
        assert_eq!(AnimEvent::Looped.type_name(), "looped");
    }

    #[test]
    fn type_name_frame_changed() {
        let ev = AnimEvent::FrameChanged { frame_index: 3 };
        assert_eq!(ev.type_name(), "frameChanged");
    }

    #[test]
    fn frame_index_returns_some_for_frame_changed() {
        let ev = AnimEvent::FrameChanged { frame_index: 7 };
        assert_eq!(ev.frame_index(), Some(7));
    }

    #[test]
    fn frame_index_returns_none_for_finished() {
        assert_eq!(AnimEvent::Finished.frame_index(), None);
    }

    #[test]
    fn frame_index_returns_none_for_looped() {
        assert_eq!(AnimEvent::Looped.frame_index(), None);
    }
}
