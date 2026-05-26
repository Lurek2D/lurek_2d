//! Input event types emitted by the winit event loop and queued for Lua consumption.
//!
//! - `InputEvent` enum covers keyboard, mouse button, mouse move, scroll, and gamepad.
//! - Events are buffered in a ring during the platform event loop and drained each tick.
//! - `KeyEvent` carries the logical `KeyCode`, physical scan code, and press/release state.
//! - Gamepad events include axis deltas and button states for up to 4 connected pads.

/// Lua event name emitted when a keyboard key transitions to pressed.
pub const EVENT_KEY_PRESSED: &str = "keypressed";
/// Lua event name emitted when a keyboard key transitions to released.
pub const EVENT_KEY_RELEASED: &str = "keyreleased";
/// Lua event name emitted on cursor position change.
pub const EVENT_MOUSE_MOVED: &str = "mousemoved";
/// Lua event name emitted when a mouse button transitions to pressed.
pub const EVENT_MOUSE_PRESSED: &str = "mousepressed";
/// Lua event name emitted when a mouse button transitions to released.
pub const EVENT_MOUSE_RELEASED: &str = "mousereleased";
/// Lua event name emitted on scroll-wheel movement.
pub const EVENT_WHEEL_MOVED: &str = "wheelmoved";
/// Lua event name emitted when the OS delivers a text-input character.
pub const EVENT_TEXT_INPUT: &str = "textinput";
