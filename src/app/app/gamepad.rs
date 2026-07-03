//! Owns the app app gamepad implementation for the app subsystem and keeps related runtime rules local here.
//! Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
//! Defines how app app gamepad data is validated, transformed, or stored before neighboring systems consume it.
//! Separates app app gamepad behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where app code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing app app gamepad defaults, lifecycle handling, validation, or data ownership rules.

use super::*;

impl LurekApp {
    /// Poll gamepad backend events and dispatch Lua callbacks.
    pub(super) fn poll_gamepads(&mut self) {
        self.poll_xinput_gamepads();
        self.process_pending_gamepad_vibration();
    }
    /// Poll standard Windows XInput controllers without the gilrs dependency.
    #[cfg(windows)]
    pub(super) fn poll_xinput_gamepads(&mut self) {
        use windows_sys::Win32::UI::Input::XboxController::{
            XInputGetState, XINPUT_GAMEPAD_A, XINPUT_GAMEPAD_B, XINPUT_GAMEPAD_BACK,
            XINPUT_GAMEPAD_DPAD_DOWN, XINPUT_GAMEPAD_DPAD_LEFT, XINPUT_GAMEPAD_DPAD_RIGHT,
            XINPUT_GAMEPAD_DPAD_UP, XINPUT_GAMEPAD_LEFT_SHOULDER, XINPUT_GAMEPAD_LEFT_THUMB,
            XINPUT_GAMEPAD_RIGHT_SHOULDER, XINPUT_GAMEPAD_RIGHT_THUMB, XINPUT_GAMEPAD_START,
            XINPUT_GAMEPAD_X, XINPUT_GAMEPAD_Y, XINPUT_STATE,
        };
        let Some(state_rc) = &self.state else { return };
        let callback_timeout_ms = self.callback_timeout_ms();
        let mut callbacks: Vec<(&'static str, u32, Option<String>, Option<f32>)> = Vec::new();
        for id in 0..4usize {
            let mut xstate = XINPUT_STATE::default();
            // SAFETY: XInput controller indices are bounded to 0..=3 here and `xstate` is a valid
            // writable out-parameter for the duration of the native call.
            let connected = unsafe { XInputGetState(id as u32, &mut xstate) == 0 };
            let was_connected = state_rc
                .borrow()
                .gamepads
                .get(id)
                .map(|gamepad| gamepad.connected)
                .unwrap_or(false);
            if !connected {
                if was_connected {
                    let mut st = state_rc.borrow_mut();
                    let gamepad = ensure_gamepad_slot(&mut st.gamepads, id);
                    gamepad.set_connected(false);
                    callbacks.push(("joystickremoved", id as u32, None, None));
                    callbacks.push(("gamepaddisconnected", id as u32, None, None));
                }
                continue;
            }

            if !was_connected {
                callbacks.push(("joystickadded", id as u32, None, None));
                callbacks.push(("gamepadconnected", id as u32, None, None));
            }

            let buttons = [
                (0, "a", XINPUT_GAMEPAD_A),
                (1, "b", XINPUT_GAMEPAD_B),
                (2, "x", XINPUT_GAMEPAD_X),
                (3, "y", XINPUT_GAMEPAD_Y),
                (4, "leftshoulder", XINPUT_GAMEPAD_LEFT_SHOULDER),
                (5, "rightshoulder", XINPUT_GAMEPAD_RIGHT_SHOULDER),
                (6, "back", XINPUT_GAMEPAD_BACK),
                (7, "start", XINPUT_GAMEPAD_START),
                (8, "leftstick", XINPUT_GAMEPAD_LEFT_THUMB),
                (9, "rightstick", XINPUT_GAMEPAD_RIGHT_THUMB),
                (10, "dpup", XINPUT_GAMEPAD_DPAD_UP),
                (11, "dpdown", XINPUT_GAMEPAD_DPAD_DOWN),
                (12, "dpleft", XINPUT_GAMEPAD_DPAD_LEFT),
                (13, "dpright", XINPUT_GAMEPAD_DPAD_RIGHT),
            ];
            let axes = [
                (
                    0,
                    "leftx",
                    normalize_xinput_thumb(xstate.Gamepad.sThumbLX, 7849),
                ),
                (
                    1,
                    "lefty",
                    -normalize_xinput_thumb(xstate.Gamepad.sThumbLY, 7849),
                ),
                (
                    2,
                    "rightx",
                    normalize_xinput_thumb(xstate.Gamepad.sThumbRX, 8689),
                ),
                (
                    3,
                    "righty",
                    -normalize_xinput_thumb(xstate.Gamepad.sThumbRY, 8689),
                ),
                (4, "triggerleft", xstate.Gamepad.bLeftTrigger as f32 / 255.0),
                (
                    5,
                    "triggerright",
                    xstate.Gamepad.bRightTrigger as f32 / 255.0,
                ),
            ];
            {
                let mut st = state_rc.borrow_mut();
                let gamepad = ensure_gamepad_slot(&mut st.gamepads, id);
                gamepad.set_connected(true);
                gamepad.set_vibration_supported(true);
                gamepad.name = format!("XInput Controller {}", id + 1);
                gamepad.set_guid(format!("xinput{:02}", id));
                for (button, name, mask) in buttons {
                    let pressed = xstate.Gamepad.wButtons & mask != 0;
                    let was_pressed = gamepad.is_button_pressed(button);
                    gamepad.update_button(button, pressed);
                    if pressed && !was_pressed {
                        callbacks.push(("gamepadpressed", id as u32, Some(name.to_string()), None));
                    } else if !pressed && was_pressed {
                        callbacks.push((
                            "gamepadreleased",
                            id as u32,
                            Some(name.to_string()),
                            None,
                        ));
                    }
                }
                for (axis, name, value) in axes {
                    let previous = gamepad.get_axis_value(axis);
                    gamepad.update_axis(axis, value);
                    if (previous - value).abs() > 0.01 {
                        callbacks.push((
                            "gamepadaxis",
                            id as u32,
                            Some(name.to_string()),
                            Some(value),
                        ));
                    }
                }
            }
        }
        if !self.has_game {
            return;
        }
        let Some(lua) = &self.lua else { return };
        for (callback, id, name, value) in callbacks {
            match (name, value) {
                (Some(name), Some(value)) => call_lua_callback_with_timeout(
                    lua,
                    callback,
                    (id, name, value),
                    callback_timeout_ms,
                ),
                (Some(name), None) => {
                    call_lua_callback_with_timeout(lua, callback, (id, name), callback_timeout_ms)
                }
                (None, None) => {
                    call_lua_callback_with_timeout(lua, callback, (id,), callback_timeout_ms)
                }
                (None, Some(_)) => {}
            }
        }
    }
    #[cfg(not(windows))]
    /// No-op XInput polling stub used on builds without native Windows controller support.
    pub(super) fn poll_xinput_gamepads(&mut self) {}
    /// Drain queued vibration requests when no native gamepad backend is built in.
    pub(super) fn process_pending_gamepad_vibration(&mut self) {
        let Some(state) = &self.state else { return };
        let requests = std::mem::take(&mut state.borrow_mut().gamepad_vibration_requests);
        process_gamepad_vibration_requests(requests);
    }
}
#[cfg(windows)]
fn normalize_xinput_thumb(value: i16, deadzone: i16) -> f32 {
    let value = value as f32;
    let deadzone = deadzone as f32;
    if value.abs() <= deadzone {
        0.0
    } else if value > 0.0 {
        ((value - deadzone) / (32767.0 - deadzone)).clamp(0.0, 1.0)
    } else {
        ((value + deadzone) / (32768.0 - deadzone)).clamp(-1.0, 0.0)
    }
}
#[cfg(windows)]
fn process_gamepad_vibration_requests(requests: Vec<crate::input::GamepadVibrationRequest>) {
    use std::thread;
    use std::time::Duration;
    use windows_sys::Win32::UI::Input::XboxController::{XInputSetState, XINPUT_VIBRATION};
    for request in requests {
        if request.id >= 4 {
            continue;
        }
        let vibration = XINPUT_VIBRATION {
            wLeftMotorSpeed: (request.low_freq.clamp(0.0, 1.0) * u16::MAX as f32) as u16,
            wRightMotorSpeed: (request.high_freq.clamp(0.0, 1.0) * u16::MAX as f32) as u16,
        };
        // SAFETY: request ids outside the supported 0..=3 range are filtered above, and the
        // vibration struct is initialized stack storage valid for this immediate FFI call.
        unsafe {
            let _ = XInputSetState(request.id as u32, &vibration);
        }
        let id = request.id as u32;
        let duration_ms = request.duration_ms;
        thread::spawn(move || {
            thread::sleep(Duration::from_millis(duration_ms as u64));
            let stop = XINPUT_VIBRATION::default();
            // SAFETY: `id` was range-checked before the thread was spawned, and `stop` is valid
            // stack storage for the duration of this shutdown XInput call.
            unsafe {
                let _ = XInputSetState(id, &stop);
            }
        });
    }
}
#[cfg(not(windows))]
fn process_gamepad_vibration_requests(_requests: Vec<crate::input::GamepadVibrationRequest>) {}
/// Grow gamepad state vector and return mutable slot for `id_usize`.
fn ensure_gamepad_slot(
    gamepads: &mut Vec<crate::input::GamepadState>,
    id_usize: usize,
) -> &mut crate::input::GamepadState {
    while gamepads.len() <= id_usize {
        let new_id = gamepads.len() as u32;
        gamepads.push(crate::input::GamepadState::new(new_id));
    }
    &mut gamepads[id_usize]
}
