//! Implements guarded invocation of named `lurek.*` callbacks from engine-side runtime flow.
//! Provides checked and logging variants so callers choose explicit error propagation behavior.
//! Supports optional timeout enforcement via instruction hooks to stop runaway callback execution.
//! Serves as the callback safety boundary between frame orchestration and Lua script handlers.
//!
//! @engine-callback | init | function lurek.init() | Called once when the engine initialises.
//! @engine-callback | ready | function lurek.ready() | Called once after init, when runtime state is ready.
//! @engine-callback | process_physics | function lurek.process_physics(dt) | Called on the fixed physics step.
//! @engine-param | process_physics | dt | number | false | Fixed-step delta time in seconds.
//! @engine-callback | fixedUpdate | function lurek.fixedUpdate(dt) | Deprecated alias for `process_physics`.
//! @engine-param | fixedUpdate | dt | number | false | Fixed-step delta time in seconds.
//! @engine-callback | process | function lurek.process(dt) | Called every frame for variable-step gameplay logic.
//! @engine-param | process | dt | number | false | Delta time in seconds.
//! @engine-callback | process_late | function lurek.process_late(dt) | Called every frame after `process`.
//! @engine-param | process_late | dt | number | false | Delta time in seconds.
//! @engine-callback | draw | function lurek.draw() | Called every frame for world rendering.
//! @engine-callback | draw_ui | function lurek.draw_ui() | Called every frame after `draw` for UI rendering.
//! @engine-callback | keypressed | function lurek.keypressed(key, scancode, isrepeat) | Called when a keyboard key is pressed.
//! @engine-param | keypressed | key | string | false | Key name.
//! @engine-param | keypressed | scancode | string | false | Platform scancode.
//! @engine-param | keypressed | isrepeat | boolean | false | True when key repeat generated the event.
//! @engine-callback | keyreleased | function lurek.keyreleased(key, scancode) | Called when a keyboard key is released.
//! @engine-param | keyreleased | key | string | false | Key name.
//! @engine-param | keyreleased | scancode | string | false | Platform scancode.
//! @engine-callback | textinput | function lurek.textinput(text) | Called when text input is received.
//! @engine-param | textinput | text | string | false | Input text fragment.
//! @engine-callback | textedited | function lurek.textedited(text, start, length) | Called when IME composition text changes.
//! @engine-param | textedited | text | string | false | Composition text.
//! @engine-param | textedited | start | number | false | Cursor start offset.
//! @engine-param | textedited | length | number | false | Selection length.
//! @engine-callback | mousepressed | function lurek.mousepressed(x, y, button) | Called when a mouse button is pressed.
//! @engine-param | mousepressed | x | number | false | Mouse x coordinate.
//! @engine-param | mousepressed | y | number | false | Mouse y coordinate.
//! @engine-param | mousepressed | button | number | false | Button index.
//! @engine-callback | mousereleased | function lurek.mousereleased(x, y, button) | Called when a mouse button is released.
//! @engine-param | mousereleased | x | number | false | Mouse x coordinate.
//! @engine-param | mousereleased | y | number | false | Mouse y coordinate.
//! @engine-param | mousereleased | button | number | false | Button index.
//! @engine-callback | mousemoved | function lurek.mousemoved(x, y, dx, dy) | Called when the mouse cursor moves.
//! @engine-param | mousemoved | x | number | false | Mouse x coordinate.
//! @engine-param | mousemoved | y | number | false | Mouse y coordinate.
//! @engine-param | mousemoved | dx | number | false | Horizontal delta.
//! @engine-param | mousemoved | dy | number | false | Vertical delta.
//! @engine-callback | wheelmoved | function lurek.wheelmoved(x, y) | Called when the mouse wheel moves.
//! @engine-param | wheelmoved | x | number | false | Horizontal wheel delta.
//! @engine-param | wheelmoved | y | number | false | Vertical wheel delta.
//! @engine-callback | gamepadpressed | function lurek.gamepadpressed(id, button) | Called when a gamepad button is pressed.
//! @engine-param | gamepadpressed | id | number | false | Gamepad id.
//! @engine-param | gamepadpressed | button | string | false | Button name.
//! @engine-callback | gamepadreleased | function lurek.gamepadreleased(id, button) | Called when a gamepad button is released.
//! @engine-param | gamepadreleased | id | number | false | Gamepad id.
//! @engine-param | gamepadreleased | button | string | false | Button name.
//! @engine-callback | gamepadaxis | function lurek.gamepadaxis(id, axis, value) | Called when a gamepad axis value changes.
//! @engine-param | gamepadaxis | id | number | false | Gamepad id.
//! @engine-param | gamepadaxis | axis | string | false | Axis name.
//! @engine-param | gamepadaxis | value | number | false | Axis value in range -1..1.
//! @engine-callback | joystickadded | function lurek.joystickadded(id) | Called when a gamepad is connected.
//! @engine-param | joystickadded | id | number | false | Gamepad id.
//! @engine-callback | joystickremoved | function lurek.joystickremoved(id) | Called when a gamepad is disconnected.
//! @engine-param | joystickremoved | id | number | false | Gamepad id.
//! @engine-callback | touchpressed | function lurek.touchpressed(id, x, y, dx, dy, pressure) | Called when a touch begins.
//! @engine-param | touchpressed | id | number | false | Touch id.
//! @engine-param | touchpressed | x | number | false | Touch x coordinate.
//! @engine-param | touchpressed | y | number | false | Touch y coordinate.
//! @engine-param | touchpressed | dx | number | false | Horizontal delta.
//! @engine-param | touchpressed | dy | number | false | Vertical delta.
//! @engine-param | touchpressed | pressure | number | false | Touch pressure.
//! @engine-callback | touchmoved | function lurek.touchmoved(id, x, y, dx, dy, pressure) | Called when a touch point moves.
//! @engine-param | touchmoved | id | number | false | Touch id.
//! @engine-param | touchmoved | x | number | false | Touch x coordinate.
//! @engine-param | touchmoved | y | number | false | Touch y coordinate.
//! @engine-param | touchmoved | dx | number | false | Horizontal delta.
//! @engine-param | touchmoved | dy | number | false | Vertical delta.
//! @engine-param | touchmoved | pressure | number | false | Touch pressure.
//! @engine-callback | touchreleased | function lurek.touchreleased(id, x, y, dx, dy, pressure) | Called when a touch ends.
//! @engine-param | touchreleased | id | number | false | Touch id.
//! @engine-param | touchreleased | x | number | false | Touch x coordinate.
//! @engine-param | touchreleased | y | number | false | Touch y coordinate.
//! @engine-param | touchreleased | dx | number | false | Horizontal delta.
//! @engine-param | touchreleased | dy | number | false | Vertical delta.
//! @engine-param | touchreleased | pressure | number | false | Touch pressure.
//! @engine-callback | focus | function lurek.focus(has_focus) | Called when window focus changes.
//! @engine-param | focus | has_focus | boolean | false | True when focused.
//! @engine-callback | visible | function lurek.visible(is_visible) | Called when window visibility changes.
//! @engine-param | visible | is_visible | boolean | false | True when visible.
//! @engine-callback | resize | function lurek.resize(w, h) | Called when window size changes.
//! @engine-param | resize | w | number | false | New window width.
//! @engine-param | resize | h | number | false | New window height.
//! @engine-callback | quit | function lurek.quit() | Called before shutdown; return true to cancel quit.
//! @engine-callback | exit | function lurek.exit() | Called when the engine is shutting down.
//! @engine-callback | errorhandler | function lurek.errorhandler(msg) | Called for unhandled Lua errors.
//! @engine-param | errorhandler | msg | string | false | Error message text.

use mlua::prelude::*;
use mlua::HookTriggers;
use std::time::{Duration, Instant};
/// Call `lurek.<name>(...)` and log failures to `error!` without returning them.
pub fn call_lua_callback<'a, A: IntoLuaMulti<'a>>(lua: &'a Lua, name: &str, args: A) {
    if let Err(e) = call_lua_callback_checked(lua, name, args) {
        log::error!("lurek.{}(): {}", name, e);
    }
}
/// Call `lurek.<name>(...)` and return any Lua error to the caller.
pub fn call_lua_callback_checked<'a, A: IntoLuaMulti<'a>>(
    lua: &'a Lua,
    name: &str,
    args: A,
) -> Result<(), mlua::Error> {
    call_lua_callback_checked_with_timeout(lua, name, args, None)
}

/// Return true when `lurek.<name>` exists and is callable in the active Lua VM.
pub fn has_lua_callback(lua: &Lua, name: &str) -> bool {
    if let Ok(lurek) = lua.globals().get::<_, LuaTable>("lurek") {
        return lurek.get::<_, LuaFunction>(name).is_ok();
    }
    false
}
/// Call `lurek.<name>(...)` with optional timeout and log failures.
pub fn call_lua_callback_with_timeout<'a, A: IntoLuaMulti<'a>>(
    lua: &'a Lua,
    name: &str,
    args: A,
    timeout_ms: Option<f32>,
) {
    if let Err(e) = call_lua_callback_checked_with_timeout(lua, name, args, timeout_ms) {
        log::error!("lurek.{}(): {}", name, e);
    }
}
/// Call `lurek.<name>(...)` and optionally abort execution when callback exceeds `timeout_ms`.
pub fn call_lua_callback_checked_with_timeout<'a, A: IntoLuaMulti<'a>>(
    lua: &'a Lua,
    name: &str,
    args: A,
    timeout_ms: Option<f32>,
) -> Result<(), mlua::Error> {
    if let Ok(lurek) = lua.globals().get::<_, LuaTable>("lurek") {
        if let Ok(func) = lurek.get::<_, LuaFunction>(name) {
            if let Some(ms) = timeout_ms.filter(|ms| *ms > 0.0) {
                return call_with_timeout(lua, name, func, args, ms);
            }
            func.call::<_, ()>(args)?;
        }
    }
    Ok(())
}
/// Execute one Lua callback with instruction-hook timeout guard.
fn call_with_timeout<'a, A: IntoLuaMulti<'a>>(
    lua: &'a Lua,
    name: &str,
    func: LuaFunction<'a>,
    args: A,
    timeout_ms: f32,
) -> Result<(), mlua::Error> {
    let timeout = Duration::from_secs_f64((timeout_ms as f64 / 1000.0).max(0.000_001));
    let deadline = Instant::now() + timeout;
    let callback_name = name.to_string();
    lua.set_hook(
        HookTriggers {
            on_calls: false,
            on_returns: false,
            every_line: false,
            every_nth_instruction: Some(20_000),
        },
        move |_, _| {
            if Instant::now() >= deadline {
                return Err(mlua::Error::RuntimeError(format!(
                    "lurek.{}() exceeded callback timeout ({:.2} ms)",
                    callback_name, timeout_ms
                )));
            }
            Ok(())
        },
    );
    let result = func.call::<_, ()>(args);
    lua.remove_hook();
    result
}
