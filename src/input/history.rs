//! Owns the bounded, device-neutral input event history used by actions, combos, recordings, and diagnostics.
//! It records normalized platform events once at the runtime boundary and retains only a short rolling window.

use std::collections::VecDeque;

/// Origin device for a normalized input event.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum InputDevice {
    /// Keyboard logical or physical input.
    Keyboard,
    /// Mouse buttons, motion, or wheel input.
    Mouse,
    /// A gamepad identified by its runtime slot.
    Gamepad(usize),
    /// A touch device contact.
    Touch,
}

/// Kind of normalized input transition stored in the input history.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum InputEventKind {
    /// A control transitioned to down.
    Press,
    /// A control transitioned to up.
    Release,
    /// An analog control changed value.
    Axis,
    /// Pointer motion was reported.
    Motion,
    /// Wheel motion was reported.
    Wheel,
    /// Text was committed by the input method.
    Text,
    /// A device connected.
    Connect,
    /// A device disconnected.
    Disconnect,
}

/// One normalized event in the rolling input history.
#[derive(Clone, Debug, PartialEq)]
pub struct InputHistoryEvent {
    /// Engine frame in which the event was accepted.
    pub frame: u64,
    /// Monotonic engine time in milliseconds.
    pub time_ms: u64,
    /// Device that emitted the event.
    pub device: InputDevice,
    /// Transition kind.
    pub kind: InputEventKind,
    /// Stable logical control or text payload.
    pub control: String,
    /// Optional analog value.
    pub value: Option<f32>,
    /// Optional game-space position or delta.
    pub position: Option<(f32, f32)>,
}

/// Bounded rolling history of normalized input events.
#[derive(Clone, Debug)]
pub struct InputHistory {
    events: VecDeque<InputHistoryEvent>,
    max_events: usize,
    max_age_ms: u64,
}

impl Default for InputHistory {
    fn default() -> Self {
        Self::new(4_096, 2_000)
    }
}

impl InputHistory {
    /// Creates a history retaining at most `max_events` and `max_age_ms` of input.
    pub fn new(max_events: usize, max_age_ms: u64) -> Self {
        Self {
            events: VecDeque::new(),
            max_events: max_events.max(1),
            max_age_ms,
        }
    }

    /// Records an event and removes entries outside the configured bounds.
    pub fn push(&mut self, event: InputHistoryEvent) {
        let now = event.time_ms;
        self.events.push_back(event);
        while self.events.len() > self.max_events {
            self.events.pop_front();
        }
        while self
            .events
            .front()
            .is_some_and(|oldest| now.saturating_sub(oldest.time_ms) > self.max_age_ms)
        {
            self.events.pop_front();
        }
    }

    /// Returns the newest event matching `predicate` within a frame window.
    pub fn newest_within_frames(
        &self,
        current_frame: u64,
        frames: u64,
        predicate: impl Fn(&InputHistoryEvent) -> bool,
    ) -> bool {
        self.events.iter().rev().any(|event| {
            current_frame.saturating_sub(event.frame) <= frames && predicate(event)
        })
    }

    /// Returns a stable snapshot for replay and diagnostic consumers.
    pub fn snapshot(&self) -> Vec<InputHistoryEvent> {
        self.events.iter().cloned().collect()
    }

    /// Removes every retained event.
    pub fn clear(&mut self) {
        self.events.clear();
    }
}
