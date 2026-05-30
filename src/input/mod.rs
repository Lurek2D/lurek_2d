//! High-level input module that groups keyboard, mouse, gamepad, touch, and recording components.
//! Re-exports action and state types so caller code can consume one coherent input surface.
//! Defines the composition boundary where platform events become gameplay-usable input state.

/// Extended action definition with category metadata for the binding system.
pub mod action_def;
/// Combo gesture detection and multi-step input sequences.
pub mod combo;
/// Gamepad device state, axis/button mapping, and vibration requests via gilrs.
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
pub(crate) use gamepad::gilrs_axis_to_string;
pub(crate) use gamepad::gilrs_button_to_string;
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
