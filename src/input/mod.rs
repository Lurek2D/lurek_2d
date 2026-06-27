//! This module re-exports the input subsystem for keyboard, mouse, gamepad, touch, combos, events, and recording.
//! It is the navigation map for device state owners, name translation helpers, and reusable input-facing type exports.
//! `keyboard.rs`, `mouse.rs`, and `gamepad.rs` own the live per-device polling state used during runtime frames.
//! `touch.rs`, `combo.rs`, and `recorder.rs` cover multitouch state, sequence detection, and replay persistence flows.
//! `action_def.rs` stores action-map data, while `events.rs` centralizes the canonical Lua-facing event name constants.
//! Change this file when public input exports move; change sibling files when device semantics or polling behavior changes.

/// Extended action definition with category metadata for the binding system.
pub mod action_def;
/// Combo gesture detection and multi-step input sequences.
pub mod combo;
/// Gamepad device state, axis/button mapping, and vibration requests.
pub mod gamepad;
/// Keyboard scan-code state and winit key translation.
pub mod keyboard;
/// Mouse position, button state, cursor kind, and cursor handle management.
pub mod mouse;
/// Input event recorder for replays and automated testing.
pub mod recorder;
/// Touch-point state tracking for multi-touch surfaces.
pub mod touch;

pub use action_def::{ActionDef, ActionMap};
pub use combo::{ComboDetector, ComboProgress, ComboStep};
pub use gamepad::virtual_dpad;
pub use gamepad::GamepadMappings;
pub use gamepad::GamepadState;
pub use gamepad::GamepadVibrationRequest;
pub use keyboard::winit_scancode_to_string;
pub use keyboard::KeyboardState;
pub use mouse::MouseState;
pub use mouse::SystemCursor;
pub use mouse::{is_cursor_supported, CursorHandle, CursorKind};
pub use touch::{TouchPoint, TouchState};

/// Input event name constants for Lua callbacks.
pub mod events;
pub use events::*;
