//! This file owns the canonical string constants for keyboard, mouse, wheel, and text input event names.
//! It centralizes the Lua-facing event vocabulary so the platform loop and consumers use one stable naming surface.
//! Open this file when event-name contracts change; device state and dispatch behavior live in sibling files.

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
