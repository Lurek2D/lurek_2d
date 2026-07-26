//! Registers the `lurek.input` Lua API for key, mouse, and gamepad bindings, state queries, and axes.

use super::SharedState;
use crate::input::action_def::{canonicalize_action_bindings, InputBinding};
use crate::input::combo::{ComboDetector, ComboStep};
use crate::input::keyboard::{get_key_from_scancode, get_scancode_from_key};
use crate::input::mouse::{
    is_cursor_supported, validate_cursor_image, CursorImageLimits, CursorKind, SystemCursor,
};
use crate::input::virtual_dpad;
use crate::input::{
    ActionDef, AxisCurve, AxisSettings, PlayerAction, PlayerInputContext, PlayerInputRegistry,
};
use mlua::prelude::*;
use mlua::Variadic;
use serde::{Deserialize, Serialize};
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

/// Canonicalizes a binding used inside a player context.
fn canonicalize_player_binding(function_name: &str, raw: &str) -> LuaResult<String> {
    let lowered = raw.trim().to_ascii_lowercase();
    if lowered.is_empty() {
        return Err(LuaError::RuntimeError(format!(
            "lurek.input.{function_name}: binding must not be empty"
        )));
    }
    if let Some(button) = lowered.strip_prefix("gamepad:") {
        if button.contains(':') || crate::input::standard_button_code(button).is_none() {
            return Err(LuaError::RuntimeError(format!(
                "lurek.input.{function_name}: player gamepad bindings use `gamepad:<standard-button>`"
            )));
        }
        return Ok(format!("gamepad:{button}"));
    }
    let parsed = InputBinding::parse(&lowered)
        .map_err(|error| LuaError::RuntimeError(format!("lurek.input.{function_name}: {error}")))?;
    if !matches!(
        parsed,
        InputBinding::KeyboardKey(_) | InputBinding::Scancode(_) | InputBinding::MouseButton(_)
    ) {
        return Err(LuaError::RuntimeError(format!(
            "lurek.input.{function_name}: binding must target keyboard, mouse, or the context gamepad"
        )));
    }
    Ok(parsed.to_canonical_string())
}

/// Parses a string or sequence of strings into bounded player-context bindings.
fn parse_player_bindings(function_name: &str, value: Option<LuaValue>) -> LuaResult<Vec<String>> {
    let Some(value) = value else {
        return Ok(Vec::new());
    };
    let mut bindings = Vec::new();
    match value {
        LuaValue::String(value) => {
            bindings.push(canonicalize_player_binding(function_name, value.to_str()?)?);
        }
        LuaValue::Table(values) => {
            for value in values.sequence_values::<String>() {
                bindings.push(canonicalize_player_binding(function_name, &value?)?);
            }
        }
        _ => {
            return Err(LuaError::RuntimeError(format!(
                "lurek.input.{function_name}: bindings must be a string or array of strings"
            )))
        }
    }
    if bindings.len() > crate::input::player_context::MAX_PLAYER_ACTION_BINDINGS {
        return Err(LuaError::RuntimeError(format!(
            "lurek.input.{function_name}: too many bindings"
        )));
    }
    bindings.sort();
    bindings.dedup();
    Ok(bindings)
}

/// Parses shared analog settings from one Lua action definition.
fn parse_axis_settings(function_name: &str, options: &LuaTable) -> LuaResult<AxisSettings> {
    let curve = AxisCurve::parse(
        &options
            .get::<_, Option<String>>("curve")?
            .unwrap_or_else(|| "linear".to_string()),
    )
    .map_err(|error| LuaError::RuntimeError(format!("lurek.input.{function_name}: {error}")))?;
    AxisSettings {
        deadzone: options.get::<_, Option<f32>>("deadzone")?.unwrap_or(0.15),
        curve,
        sensitivity: options.get::<_, Option<f32>>("sensitivity")?.unwrap_or(1.0),
        activation_threshold: options
            .get::<_, Option<f32>>("activationThreshold")?
            .unwrap_or(0.5),
        hysteresis: options.get::<_, Option<f32>>("hysteresis")?.unwrap_or(0.1),
    }
    .validate()
    .map_err(|error| LuaError::RuntimeError(format!("lurek.input.{function_name}: {error}")))
}

fn player_binding_down(state: &SharedState, context: &PlayerInputContext, binding: &str) -> bool {
    if !context.enabled {
        return false;
    }
    if let Some(button) = binding.strip_prefix("gamepad:") {
        return crate::input::standard_button_code(button).is_some_and(|code| {
            context.gamepads.keys().any(|id| {
                state
                    .gamepads
                    .get(*id)
                    .is_some_and(|gamepad| gamepad.connected && gamepad.is_button_pressed(code))
            })
        });
    }
    if !context.keyboard_mouse {
        return false;
    }
    match InputBinding::parse(binding) {
        Ok(InputBinding::KeyboardKey(key)) => state.keyboard.is_down(&key),
        Ok(InputBinding::Scancode(scancode)) => state.keyboard.is_scancode_down(&scancode),
        Ok(InputBinding::MouseButton(button)) => state.mouse.is_down((button - 1) as usize),
        _ => false,
    }
}

fn player_binding_pressed(
    state: &SharedState,
    context: &PlayerInputContext,
    binding: &str,
) -> bool {
    if !context.enabled {
        return false;
    }
    if let Some(button) = binding.strip_prefix("gamepad:") {
        return crate::input::standard_button_code(button).is_some_and(|code| {
            context.gamepads.keys().any(|id| {
                state
                    .gamepads
                    .get(*id)
                    .is_some_and(|gamepad| gamepad.connected && gamepad.was_button_pressed(code))
            })
        });
    }
    if !context.keyboard_mouse {
        return false;
    }
    match InputBinding::parse(binding) {
        Ok(InputBinding::KeyboardKey(key)) => {
            state.keyboard.get_pressed().iter().any(|v| v == &key)
        }
        Ok(InputBinding::Scancode(scancode)) => state.keyboard.was_scancode_pressed(&scancode),
        Ok(InputBinding::MouseButton(button)) => state.mouse.was_pressed((button - 1) as usize),
        _ => false,
    }
}

fn player_binding_released(
    state: &SharedState,
    context: &PlayerInputContext,
    binding: &str,
) -> bool {
    if !context.enabled {
        return false;
    }
    if let Some(button) = binding.strip_prefix("gamepad:") {
        return crate::input::standard_button_code(button).is_some_and(|code| {
            context.gamepads.keys().any(|id| {
                state
                    .gamepads
                    .get(*id)
                    .is_some_and(|gamepad| gamepad.was_button_released(code))
            })
        });
    }
    if !context.keyboard_mouse {
        return false;
    }
    match InputBinding::parse(binding) {
        Ok(InputBinding::KeyboardKey(key)) => state
            .keyboard
            .get_released()
            .iter()
            .any(|value| value == &key),
        Ok(InputBinding::Scancode(scancode)) => state.keyboard.was_scancode_released(&scancode),
        Ok(InputBinding::MouseButton(button)) => state.mouse.was_released((button - 1) as usize),
        _ => false,
    }
}

fn player_gamepad_axis(state: &SharedState, context: &PlayerInputContext, axis: &str) -> f32 {
    let Some(code) = crate::input::standard_axis_code(axis) else {
        return 0.0;
    };
    context
        .gamepads
        .keys()
        .filter_map(|id| state.gamepads.get(*id))
        .filter(|gamepad| gamepad.connected)
        .map(|gamepad| gamepad.get_axis_value(code))
        .max_by(|left, right| {
            left.abs()
                .partial_cmp(&right.abs())
                .unwrap_or(std::cmp::Ordering::Equal)
        })
        .unwrap_or(0.0)
}

fn player_axis_1d(state: &SharedState, context: &PlayerInputContext, action: &PlayerAction) -> f32 {
    let PlayerAction::Axis1D {
        negative,
        positive,
        gamepad_axis,
        invert,
        settings,
    } = action
    else {
        return 0.0;
    };
    if !context.enabled {
        return 0.0;
    }
    let negative = negative
        .iter()
        .any(|binding| player_binding_down(state, context, binding));
    let positive = positive
        .iter()
        .any(|binding| player_binding_down(state, context, binding));
    let digital = match (negative, positive) {
        (true, false) => -1.0,
        (false, true) => 1.0,
        _ => 0.0,
    };
    let analog = gamepad_axis
        .as_deref()
        .map_or(0.0, |axis| player_gamepad_axis(state, context, axis));
    let mut value = if digital != 0.0 { digital } else { analog };
    if *invert {
        value = -value;
    }
    settings.shape_1d(value)
}

fn player_axis_2d(
    state: &SharedState,
    context: &PlayerInputContext,
    action: &PlayerAction,
) -> (f32, f32) {
    let PlayerAction::Axis2D {
        left,
        right,
        up,
        down,
        gamepad_x,
        gamepad_y,
        invert_x,
        invert_y,
        settings,
    } = action
    else {
        return (0.0, 0.0);
    };
    if !context.enabled {
        return (0.0, 0.0);
    }
    let digital_x = (right
        .iter()
        .any(|binding| player_binding_down(state, context, binding)) as i8
        - left
            .iter()
            .any(|binding| player_binding_down(state, context, binding)) as i8)
        as f32;
    let digital_y = (down
        .iter()
        .any(|binding| player_binding_down(state, context, binding)) as i8
        - up.iter()
            .any(|binding| player_binding_down(state, context, binding)) as i8)
        as f32;
    let mut x = if digital_x != 0.0 {
        digital_x
    } else {
        gamepad_x
            .as_deref()
            .map_or(0.0, |axis| player_gamepad_axis(state, context, axis))
    };
    let mut y = if digital_y != 0.0 {
        digital_y
    } else {
        gamepad_y
            .as_deref()
            .map_or(0.0, |axis| player_gamepad_axis(state, context, axis))
    };
    if *invert_x {
        x = -x;
    }
    if *invert_y {
        y = -y;
    }
    settings.shape_2d(x, y)
}

/// Lua handle for one isolated player input context.
struct LuaPlayerInputContext {
    context: PlayerInputContext,
    state: Rc<RefCell<SharedState>>,
    registry: Rc<RefCell<PlayerInputRegistry>>,
}

impl Drop for LuaPlayerInputContext {
    fn drop(&mut self) {
        self.registry
            .borrow_mut()
            .release_context(self.context.context_id);
    }
}

impl LuaPlayerInputContext {
    fn action_magnitude(&self, action: &PlayerAction) -> f32 {
        let state = self.state.borrow();
        match action {
            PlayerAction::Button { bindings } => bindings
                .iter()
                .any(|binding| player_binding_down(&state, &self.context, binding))
                as u8 as f32,
            PlayerAction::Axis1D { .. } => player_axis_1d(&state, &self.context, action).abs(),
            PlayerAction::Axis2D { .. } => {
                let (x, y) = player_axis_2d(&state, &self.context, action);
                x.hypot(y)
            }
        }
    }

    fn refresh_analog(&mut self, name: &str) {
        let Some(action) = self.context.actions.get(name).cloned() else {
            return;
        };
        if matches!(action, PlayerAction::Button { .. }) {
            return;
        }
        let magnitude = self.action_magnitude(&action);
        let frame = self.state.borrow().clock.frame_count();
        self.context
            .refresh_analog_transition(name, magnitude, frame);
    }
}

impl LuaUserData for LuaPlayerInputContext {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- assignKeyboardMouse --
        /// Assigns keyboard and mouse to this context.
        /// @param | opts | table? | Options with `shared`; all owners must opt into sharing.
        methods.add_method_mut("assignKeyboardMouse", |_, this, opts: Option<LuaTable>| {
            let shared = opts
                .as_ref()
                .map(|table| table.get::<_, Option<bool>>("shared"))
                .transpose()?
                .flatten()
                .unwrap_or(false);
            this.registry
                .borrow_mut()
                .assign_keyboard(this.context.context_id, shared)
                .map_err(|error| {
                    LuaError::RuntimeError(format!(
                        "lurek.input.LPlayerInputContext.assignKeyboardMouse: {error}"
                    ))
                })?;
            this.context.keyboard_mouse = true;
            Ok(())
        });
        // -- unassignKeyboardMouse --
        /// Releases keyboard and mouse ownership.
        methods.add_method_mut("unassignKeyboardMouse", |_, this, ()| {
            this.registry
                .borrow_mut()
                .unassign_keyboard(this.context.context_id);
            this.context.keyboard_mouse = false;
            Ok(())
        });
        // -- assignGamepad --
        /// Assigns a persistent gamepad slot to this context.
        /// @param | id | integer | Non-negative gamepad slot.
        /// @param | opts | table? | Options with `shared`; all owners must opt into sharing.
        methods.add_method_mut(
            "assignGamepad",
            |_, this, (id, opts): (usize, Option<LuaTable>)| {
                let shared = opts
                    .as_ref()
                    .map(|table| table.get::<_, Option<bool>>("shared"))
                    .transpose()?
                    .flatten()
                    .unwrap_or(false);
                this.registry
                    .borrow_mut()
                    .assign_gamepad(this.context.context_id, id, shared)
                    .map_err(|error| {
                        LuaError::RuntimeError(format!(
                            "lurek.input.LPlayerInputContext.assignGamepad: {error}"
                        ))
                    })?;
                this.context.gamepads.insert(id, shared);
                Ok(())
            },
        );
        // -- unassignGamepad --
        /// Releases one gamepad slot, or every assigned slot when id is nil.
        /// @param | id | integer? | Optional gamepad slot.
        methods.add_method_mut("unassignGamepad", |_, this, id: Option<usize>| {
            let ids: Vec<usize> = id.map_or_else(
                || this.context.gamepads.keys().copied().collect(),
                |id| vec![id],
            );
            for id in ids {
                this.registry
                    .borrow_mut()
                    .unassign_gamepad(this.context.context_id, id);
                this.context.gamepads.remove(&id);
            }
            Ok(())
        });
        // -- getAssignedDevices --
        /// Returns keyboard/mouse ownership and deterministic gamepad slot records.
        /// @return | table | Device assignment snapshot.
        methods.add_method("getAssignedDevices", |lua, this, ()| {
            let out = lua.create_table()?;
            out.set("keyboardMouse", this.context.keyboard_mouse)?;
            let gamepads = lua.create_table()?;
            let state = this.state.borrow();
            for (index, (id, shared)) in this.context.gamepads.iter().enumerate() {
                let entry = lua.create_table()?;
                entry.set("id", *id)?;
                entry.set("shared", *shared)?;
                entry.set(
                    "connected",
                    state
                        .gamepads
                        .get(*id)
                        .is_some_and(|gamepad| gamepad.connected),
                )?;
                gamepads.set(index + 1, entry)?;
            }
            out.set("gamepads", gamepads)?;
            Ok(out)
        });
        // -- defineButton --
        /// Defines or replaces a player-local digital action.
        /// @param | name | string | Local action name.
        /// @param | opts | table | Definition with a `bindings` array.
        methods.add_method_mut(
            "defineButton",
            |_, this, (name, opts): (String, LuaTable)| {
                let bindings = parse_player_bindings(
                    "LPlayerInputContext.defineButton",
                    opts.get("bindings")?,
                )?;
                if bindings.is_empty() {
                    return Err(LuaError::RuntimeError(
                        "lurek.input.LPlayerInputContext.defineButton: bindings must not be empty"
                            .to_string(),
                    ));
                }
                this.context
                    .define_action(name, PlayerAction::Button { bindings })
                    .map_err(|error| {
                        LuaError::RuntimeError(format!(
                            "lurek.input.LPlayerInputContext.defineButton: {error}"
                        ))
                    })
            },
        );
        // -- defineAxis1D --
        /// Defines or replaces a continuous one-dimensional action.
        /// @param | name | string | Local action name.
        /// @param | opts | table | Digital, gamepad-axis, deadzone, curve, and sensitivity options.
        methods.add_method_mut(
            "defineAxis1D",
            |_, this, (name, opts): (String, LuaTable)| {
                let keyboard = opts.get::<_, Option<LuaTable>>("keyboard")?;
                let negative = parse_player_bindings(
                    "LPlayerInputContext.defineAxis1D",
                    keyboard
                        .as_ref()
                        .and_then(|table| table.get::<_, Option<LuaValue>>("negative").ok().flatten())
                        .or(opts.get::<_, Option<LuaValue>>("negative")?),
                )?;
                let positive = parse_player_bindings(
                    "LPlayerInputContext.defineAxis1D",
                    keyboard
                        .as_ref()
                        .and_then(|table| table.get::<_, Option<LuaValue>>("positive").ok().flatten())
                        .or(opts.get::<_, Option<LuaValue>>("positive")?),
                )?;
                let gamepad = opts.get::<_, Option<LuaTable>>("gamepad")?;
                let gamepad_axis = gamepad
                    .as_ref()
                    .map(|table| table.get::<_, Option<String>>("axis"))
                    .transpose()?
                    .flatten()
                    .or(opts.get::<_, Option<String>>("axis")?);
                if let Some(axis) = &gamepad_axis {
                    if crate::input::standard_axis_code(axis).is_none() {
                        return Err(LuaError::RuntimeError(
                            "lurek.input.LPlayerInputContext.defineAxis1D: unknown standard gamepad axis"
                                .to_string(),
                        ));
                    }
                }
                let action = PlayerAction::Axis1D {
                    negative,
                    positive,
                    gamepad_axis: gamepad_axis.map(|axis| axis.to_ascii_lowercase()),
                    invert: opts.get::<_, Option<bool>>("invert")?.unwrap_or(false),
                    settings: parse_axis_settings("LPlayerInputContext.defineAxis1D", &opts)?,
                };
                this.context.define_action(name, action).map_err(|error| {
                    LuaError::RuntimeError(format!(
                        "lurek.input.LPlayerInputContext.defineAxis1D: {error}"
                    ))
                })
            },
        );
        // -- defineAxis2D --
        /// Defines or replaces a continuous radial two-dimensional action.
        /// @param | name | string | Local action name.
        /// @param | opts | table | Keyboard directions, gamepad axes, and analog processing options.
        methods.add_method_mut(
            "defineAxis2D",
            |_, this, (name, opts): (String, LuaTable)| {
                let keyboard = opts.get::<_, Option<LuaTable>>("keyboard")?;
                let direction = |key: &str| -> LuaResult<Vec<String>> {
                    parse_player_bindings(
                        "LPlayerInputContext.defineAxis2D",
                        keyboard
                            .as_ref()
                            .map(|table| table.get::<_, Option<LuaValue>>(key))
                            .transpose()?
                            .flatten(),
                    )
                };
                let gamepad = opts.get::<_, Option<LuaTable>>("gamepad")?;
                let gamepad_x = gamepad
                    .as_ref()
                    .map(|table| table.get::<_, Option<String>>("x"))
                    .transpose()?
                    .flatten();
                let gamepad_y = gamepad
                    .as_ref()
                    .map(|table| table.get::<_, Option<String>>("y"))
                    .transpose()?
                    .flatten();
                for axis in [&gamepad_x, &gamepad_y].into_iter().flatten() {
                    if crate::input::standard_axis_code(axis).is_none() {
                        return Err(LuaError::RuntimeError(
                            "lurek.input.LPlayerInputContext.defineAxis2D: unknown standard gamepad axis"
                                .to_string(),
                        ));
                    }
                }
                let action = PlayerAction::Axis2D {
                    left: direction("left")?,
                    right: direction("right")?,
                    up: direction("up")?,
                    down: direction("down")?,
                    gamepad_x: gamepad_x.map(|axis| axis.to_ascii_lowercase()),
                    gamepad_y: gamepad_y.map(|axis| axis.to_ascii_lowercase()),
                    invert_x: opts.get::<_, Option<bool>>("invertX")?.unwrap_or(false),
                    invert_y: opts.get::<_, Option<bool>>("invertY")?.unwrap_or(false),
                    settings: parse_axis_settings("LPlayerInputContext.defineAxis2D", &opts)?,
                };
                this.context.define_action(name, action).map_err(|error| {
                    LuaError::RuntimeError(format!(
                        "lurek.input.LPlayerInputContext.defineAxis2D: {error}"
                    ))
                })
            },
        );
        // -- removeAction --
        /// Removes one local action.
        /// @param | name | string | Local action name.
        /// @return | boolean | True when an action was removed.
        methods.add_method_mut("removeAction", |_, this, name: String| {
            Ok(this.context.remove_action(&name))
        });
        // -- clearActions --
        /// Removes every local action.
        methods.add_method_mut("clearActions", |_, this, ()| {
            this.context.clear_actions();
            Ok(())
        });
        // -- isDown --
        /// Returns whether a button or thresholded analog action is currently active.
        /// @param | name | string | Local action name.
        /// @return | boolean | Current action state.
        methods.add_method_mut("isDown", |_, this, name: String| {
            let Some(action) = this.context.actions.get(&name).cloned() else {
                return Ok(false);
            };
            match action {
                PlayerAction::Button { bindings } => {
                    let state = this.state.borrow();
                    Ok(bindings
                        .iter()
                        .any(|binding| player_binding_down(&state, &this.context, binding)))
                }
                _ => {
                    this.refresh_analog(&name);
                    Ok(this
                        .context
                        .analog_active
                        .get(&name)
                        .copied()
                        .unwrap_or(false))
                }
            }
        });
        // -- wasPressed --
        /// Returns the current-frame press transition, including analog hysteresis transitions.
        /// @param | name | string | Local action name.
        /// @return | boolean | True on the press frame.
        methods.add_method_mut("wasPressed", |_, this, name: String| {
            let Some(action) = this.context.actions.get(&name).cloned() else {
                return Ok(false);
            };
            if let PlayerAction::Button { bindings } = action {
                let state = this.state.borrow();
                return Ok(bindings
                    .iter()
                    .any(|binding| player_binding_pressed(&state, &this.context, binding)));
            }
            this.refresh_analog(&name);
            let frame = this.state.borrow().clock.frame_count();
            Ok(this.context.analog_pressed_frames.get(&name) == Some(&frame))
        });
        // -- wasReleased --
        /// Returns the current-frame release transition, including analog hysteresis transitions.
        /// @param | name | string | Local action name.
        /// @return | boolean | True on the release frame.
        methods.add_method_mut("wasReleased", |_, this, name: String| {
            let Some(action) = this.context.actions.get(&name).cloned() else {
                return Ok(false);
            };
            if let PlayerAction::Button { bindings } = action {
                let state = this.state.borrow();
                return Ok(bindings
                    .iter()
                    .any(|binding| player_binding_released(&state, &this.context, binding)));
            }
            this.refresh_analog(&name);
            let frame = this.state.borrow().clock.frame_count();
            Ok(this.context.analog_released_frames.get(&name) == Some(&frame))
        });
        // -- getAxis1D --
        /// Returns a shaped continuous one-dimensional value.
        /// @param | name | string | Local axis action name.
        /// @return | number | Value in [-1, 1].
        methods.add_method("getAxis1D", |_, this, name: String| {
            let Some(action) = this.context.actions.get(&name) else {
                return Ok(0.0);
            };
            Ok(player_axis_1d(&this.state.borrow(), &this.context, action))
        });
        // -- getAxis2D --
        /// Returns a shaped continuous vector with length no greater than one.
        /// @param | name | string | Local axis action name.
        /// @return | number | X component.
        /// @return | number | Y component.
        methods.add_method("getAxis2D", |_, this, name: String| {
            let Some(action) = this.context.actions.get(&name) else {
                return Ok((0.0, 0.0));
            };
            Ok(player_axis_2d(&this.state.borrow(), &this.context, action))
        });
        // -- setEnabled --
        /// Enables or disables all queries for this context.
        /// @param | enabled | boolean | New enabled state.
        methods.add_method_mut("setEnabled", |_, this, enabled: bool| {
            this.context.enabled = enabled;
            Ok(())
        });
        // -- isEnabled --
        /// Returns whether this context is enabled.
        /// @return | boolean | Current enabled state.
        methods.add_method("isEnabled", |_, this, ()| Ok(this.context.enabled));
        // -- getConflicts --
        /// Returns local binding conflicts in deterministic order.
        /// @return | table | Map from binding string to action-name arrays.
        methods.add_method("getConflicts", |lua, this, ()| {
            let out = lua.create_table()?;
            for (binding, names) in this.context.conflicts() {
                let values = lua.create_table()?;
                for (index, name) in names.into_iter().enumerate() {
                    values.set(index + 1, name)?;
                }
                out.set(binding, values)?;
            }
            Ok(out)
        });
        // -- serializeBindings --
        /// Serializes local definitions and enabled state as versioned JSON.
        /// @return | string | Deterministic binding snapshot.
        methods.add_method("serializeBindings", |_, this, ()| {
            this.context.serialize_bindings().map_err(|error| {
                LuaError::RuntimeError(format!(
                    "lurek.input.LPlayerInputContext.serializeBindings: {error}"
                ))
            })
        });
        // -- restoreBindings --
        /// Atomically restores definitions and enabled state from JSON.
        /// @param | json | string | Snapshot produced by `serializeBindings`.
        methods.add_method_mut("restoreBindings", |_, this, json: String| {
            this.context.restore_bindings(&json).map_err(|error| {
                LuaError::RuntimeError(format!(
                    "lurek.input.LPlayerInputContext.restoreBindings: {error}"
                ))
            })
        });
        // -- vibrate --
        /// Queues vibration for every assigned connected gamepad that supports it.
        /// @param | low | number | Low-frequency strength in [0, 1].
        /// @param | high | number | High-frequency strength in [0, 1].
        /// @param | duration_ms | number | Non-negative duration in milliseconds.
        /// @return | integer | Number of queued gamepad requests.
        methods.add_method(
            "vibrate",
            |_, this, (low, high, duration_ms): (f32, f32, f32)| {
                if !low.is_finite()
                    || !high.is_finite()
                    || !duration_ms.is_finite()
                    || !(0.0..=1.0).contains(&low)
                    || !(0.0..=1.0).contains(&high)
                    || !(0.0..=60_000.0).contains(&duration_ms)
                {
                    return Err(LuaError::RuntimeError(
                        "lurek.input.LPlayerInputContext.vibrate: strengths must be in [0, 1] and durationMs in [0, 60000]"
                            .to_string(),
                    ));
                }
                let mut state = this.state.borrow_mut();
                let supported: Vec<usize> = this
                    .context
                    .gamepads
                    .keys()
                    .copied()
                    .filter(|id| {
                        state.gamepads.get(*id).is_some_and(|gamepad| {
                            gamepad.connected && gamepad.is_vibration_supported()
                        })
                    })
                    .collect();
                for id in &supported {
                    state.gamepad_vibration_requests.push(
                        crate::input::GamepadVibrationRequest {
                            id: *id,
                            low_freq: low,
                            high_freq: high,
                            duration_ms: duration_ms.round() as u32,
                        },
                    );
                }
                Ok(supported.len())
            },
        );
        // -- type --
        /// Returns the Lua-visible handle type.
        /// @return | string | `LPlayerInputContext`.
        methods.add_method("type", |_, _, ()| Ok("LPlayerInputContext"));
        // -- typeOf --
        /// Checks this handle against `LPlayerInputContext` or `LObject`.
        /// @param | name | string | Type name.
        /// @return | boolean | Whether the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LPlayerInputContext" || name == "LObject")
        });
    }
}

/// Versioned wire format for persisted action maps.  Version 1 was the bare map and remains
/// accepted by `deserializeBindings` for compatibility.
#[derive(Serialize, Deserialize)]
struct BindingMapEnvelope {
    schema_version: u32,
    actions: HashMap<String, ActionDef>,
}

fn decode_binding_map(json: &str) -> Result<HashMap<String, ActionDef>, String> {
    if let Ok(envelope) = serde_json::from_str::<BindingMapEnvelope>(json) {
        if envelope.schema_version != 2 {
            return Err(format!(
                "unsupported binding schema_version {}",
                envelope.schema_version
            ));
        }
        return Ok(envelope.actions);
    }
    serde_json::from_str(json).map_err(|error| error.to_string())
}

fn parse_binding_list(function_name: &str, value: LuaValue) -> LuaResult<Vec<String>> {
    let mut raw = Vec::new();
    match value {
        LuaValue::String(value) => {
            raw.push(
                value
                    .to_str()
                    .map_err(|e| LuaError::RuntimeError(e.to_string()))?
                    .to_string(),
            );
        }
        LuaValue::Table(values) => {
            for item in values.sequence_values::<LuaValue>() {
                match item? {
                    LuaValue::String(item) => raw.push(
                        item.to_str()
                            .map_err(|e| LuaError::RuntimeError(e.to_string()))?
                            .to_string(),
                    ),
                    LuaValue::Table(expr) => {
                        if let Some(all) = expr.get::<_, Option<LuaTable>>("all")? {
                            let mut keys = Vec::new();
                            for key in all.sequence_values::<String>() {
                                keys.push(key?);
                            }
                            let keys = canonicalize_action_bindings(keys).map_err(|e| {
                                LuaError::RuntimeError(format!("input.{function_name}: {e}"))
                            })?;
                            if keys.len() < 2 {
                                return Err(LuaError::RuntimeError(format!(
                                    "input.{function_name}: chord requires at least two bindings"
                                )));
                            }
                            let within = expr.get::<_, Option<u64>>("within_ms")?.unwrap_or(60);
                            raw.push(format!("chord|{within}|{}", keys.join("|")));
                        } else if let Some(axis) = expr.get::<_, Option<String>>("axis")? {
                            let threshold = expr.get::<_, Option<f32>>("threshold")?.unwrap_or(0.5);
                            let direction = expr
                                .get::<_, Option<String>>("direction")?
                                .unwrap_or_else(|| "positive".to_string());
                            if !threshold.is_finite()
                                || !(0.0..=1.0).contains(&threshold)
                                || !matches!(direction.as_str(), "positive" | "negative")
                            {
                                return Err(LuaError::RuntimeError(format!(
                                    "input.{function_name}: axis binding has invalid threshold or direction"
                                )));
                            }
                            raw.push(format!("axis|{axis}|{threshold}|{direction}"));
                        } else {
                            return Err(LuaError::RuntimeError(format!(
                                "input.{function_name}: binding tables require `all` or `axis`"
                            )));
                        }
                    }
                    _ => {
                        return Err(LuaError::RuntimeError(format!(
                        "input.{function_name}: bindings must contain strings or expression tables"
                    )))
                    }
                }
            }
        }
        _ => {
            return Err(LuaError::RuntimeError(format!(
                "input.{function_name}: bindings must be a string or array of strings"
            )))
        }
    }
    canonicalize_action_bindings(raw)
        .map_err(|e| LuaError::RuntimeError(format!("input.{function_name}: {e}")))
}

/// Decodes a serialized chord expression into its components.
fn chord_parts(binding: &str) -> Option<(u64, Vec<&str>)> {
    let mut parts = binding.split('|');
    (parts.next()? == "chord").then_some(())?;
    let within_ms = parts.next()?.parse::<u64>().ok()?;
    let keys: Vec<_> = parts.collect();
    (keys.len() >= 2).then_some((within_ms, keys))
}

/// Returns an axis value for a named `gamepad:*:*` control.
fn named_gamepad_axis(st: &SharedState, binding: &str) -> Option<f32> {
    let rest = binding.strip_prefix("gamepad:")?;
    let (target, axis) = rest.split_once(':')?;
    let axis_code = crate::input::standard_axis_code(axis)?;
    if target == "any" {
        return st
            .gamepads
            .iter()
            .enumerate()
            .map(|(id, _)| normalized_gamepad_axis(st, id, axis_code, axis))
            .max_by(|a, b| {
                a.abs()
                    .partial_cmp(&b.abs())
                    .unwrap_or(std::cmp::Ordering::Equal)
            });
    }
    if let Some(player) = target
        .strip_prefix('p')
        .and_then(|player| player.parse::<u32>().ok())
    {
        return st
            .gamepad_players
            .get(&player)
            .map(|id| normalized_gamepad_axis(st, *id, axis_code, axis));
    }
    target
        .parse::<usize>()
        .ok()
        .filter(|id| st.gamepads.get(*id).is_some())
        .map(|id| normalized_gamepad_axis(st, id, axis_code, axis))
}

/// Apply the same per-device deadzone normalization used by public gamepad polling.
fn normalized_gamepad_axis(st: &SharedState, id: usize, axis_code: u32, axis_name: &str) -> f32 {
    let value = st
        .gamepads
        .get(id)
        .map_or(0.0, |gamepad| gamepad.get_axis_value(axis_code));
    let group = match axis_name.to_ascii_lowercase().as_str() {
        "leftx" | "lefty" | "left_x" | "left_y" => "leftstick",
        "rightx" | "righty" | "right_x" | "right_y" => "rightstick",
        "lefttrigger" | "left_trigger" => "lefttrigger",
        "righttrigger" | "right_trigger" => "righttrigger",
        _ => return value,
    };
    let deadzone = st
        .gamepad_deadzones
        .get(&(id, group.to_string()))
        .copied()
        .unwrap_or(0.0);
    if value.abs() <= deadzone {
        0.0
    } else if value.is_sign_positive() {
        ((value - deadzone) / (1.0 - deadzone).max(f32::EPSILON)).clamp(0.0, 1.0)
    } else {
        ((value + deadzone) / (1.0 - deadzone).max(f32::EPSILON)).clamp(-1.0, 0.0)
    }
}

/// Evaluates an encoded analog threshold expression.
fn axis_threshold_is_down(st: &SharedState, binding: &str) -> Option<bool> {
    let mut parts = binding.split('|');
    (parts.next()? == "axis").then_some(())?;
    let axis = parts.next()?;
    let threshold = parts.next()?.parse::<f32>().ok()?;
    let direction = parts.next()?;
    (parts.next().is_none()).then_some(())?;
    let value = named_gamepad_axis(st, axis)?;
    Some(if direction == "negative" {
        value <= -threshold
    } else {
        value >= threshold
    })
}

/// Returns whether a keyboard, mouse, or gamepad binding is currently down.
fn binding_is_down(st: &SharedState, binding: &str) -> bool {
    if let Some((_, keys)) = chord_parts(binding) {
        return keys.iter().all(|key| binding_is_down(st, key));
    }
    if let Some(value) = axis_threshold_is_down(st, binding) {
        return value;
    }
    match InputBinding::parse(binding) {
        Ok(InputBinding::KeyboardKey(key)) => st.keyboard.is_down(&key),
        Ok(InputBinding::Scancode(scancode)) => st.keyboard.is_scancode_down(&scancode),
        Ok(InputBinding::MouseButton(button)) => st.mouse.is_down((button - 1) as usize),
        Ok(InputBinding::GamepadButton { gamepad_id, button }) => st
            .gamepads
            .get(gamepad_id)
            .is_some_and(|gp| gp.is_button_pressed(button)),
        Ok(InputBinding::GamepadNamed {
            gamepad_id,
            player,
            button,
        }) => st.gamepads.iter().enumerate().any(|(id, gamepad)| {
            (gamepad_id.is_none_or(|expected| expected == id)
                && player.is_none_or(|expected| st.gamepad_players.get(&expected) == Some(&id)))
                && gamepad.is_standard_button_pressed(&button)
        }),
        Ok(InputBinding::GamepadAxis { .. } | InputBinding::TouchGesture(_)) | Err(_) => false,
    }
}
/// Returns whether a keyboard, mouse, or gamepad binding was pressed this frame.
fn binding_was_pressed(st: &SharedState, binding: &str) -> bool {
    if let Some((_, keys)) = chord_parts(binding) {
        return keys.iter().all(|key| binding_is_down(st, key))
            && keys.iter().any(|key| binding_was_pressed(st, key));
    }
    if axis_threshold_is_down(st, binding).unwrap_or(false) {
        return true;
    }
    match InputBinding::parse(binding) {
        Ok(InputBinding::KeyboardKey(key)) => st.keyboard.get_pressed().iter().any(|k| k == &key),
        Ok(InputBinding::Scancode(scancode)) => st.keyboard.was_scancode_pressed(&scancode),
        Ok(InputBinding::MouseButton(button)) => st.mouse.was_pressed((button - 1) as usize),
        Ok(InputBinding::GamepadButton { gamepad_id, button }) => st
            .gamepads
            .get(gamepad_id)
            .is_some_and(|gp| gp.was_button_pressed(button)),
        Ok(InputBinding::GamepadNamed {
            gamepad_id,
            player,
            button,
        }) => crate::input::standard_button_code(&button).is_some_and(|button_code| {
            st.gamepads.iter().enumerate().any(|(id, gamepad)| {
                (gamepad_id.is_none_or(|expected| expected == id)
                    && player.is_none_or(|expected| st.gamepad_players.get(&expected) == Some(&id)))
                    && gamepad.was_button_pressed(button_code)
            })
        }),
        Ok(InputBinding::GamepadAxis { .. } | InputBinding::TouchGesture(_)) | Err(_) => false,
    }
}
/// Returns whether a keyboard, mouse, or gamepad binding was released this frame.
fn binding_was_released(st: &SharedState, binding: &str) -> bool {
    if let Some((_, keys)) = chord_parts(binding) {
        return keys.iter().any(|key| binding_was_released(st, key));
    }
    match InputBinding::parse(binding) {
        Ok(InputBinding::KeyboardKey(key)) => st.keyboard.get_released().iter().any(|k| k == &key),
        Ok(InputBinding::Scancode(scancode)) => st.keyboard.was_scancode_released(&scancode),
        Ok(InputBinding::MouseButton(button)) => st.mouse.was_released((button - 1) as usize),
        Ok(InputBinding::GamepadButton { gamepad_id, button }) => st
            .gamepads
            .get(gamepad_id)
            .is_some_and(|gp| gp.was_button_released(button)),
        Ok(InputBinding::GamepadNamed {
            gamepad_id,
            player,
            button,
        }) => crate::input::standard_button_code(&button).is_some_and(|button_code| {
            st.gamepads.iter().enumerate().any(|(id, gamepad)| {
                (gamepad_id.is_none_or(|expected| expected == id)
                    && player.is_none_or(|expected| st.gamepad_players.get(&expected) == Some(&id)))
                    && gamepad.was_button_released(button_code)
            })
        }),
        Ok(InputBinding::GamepadAxis { .. } | InputBinding::TouchGesture(_)) | Err(_) => false,
    }
}
/// Computes a -1/0/+1 axis value from an action's first two bindings; first binding is positive, second is negative.
fn compute_axis(
    map: &HashMap<String, ActionDef>,
    contexts: &HashMap<String, bool>,
    st: &SharedState,
    action: &str,
) -> f32 {
    let Some(def) = map.get(action) else {
        return 0.0;
    };
    if !action_context_enabled(contexts, def) {
        return 0.0;
    }
    let pos = def.bindings.first().is_some_and(|k| binding_is_down(st, k));
    let neg = def.bindings.get(1).is_some_and(|k| binding_is_down(st, k));
    match (pos, neg) {
        (true, false) => 1.0,
        (false, true) => -1.0,
        _ => 0.0,
    }
}

/// Returns whether an action's input context is currently enabled.
fn action_context_enabled(contexts: &HashMap<String, bool>, def: &ActionDef) -> bool {
    contexts.get(&def.context).copied().unwrap_or(true)
}

/// Returns whether a normalized history event is a press matching one simple action binding.
fn history_press_matches_binding(
    st: &SharedState,
    event: &crate::input::InputHistoryEvent,
    binding: &str,
) -> bool {
    if event.kind != crate::input::InputEventKind::Press {
        return false;
    }
    match InputBinding::parse(binding) {
        Ok(InputBinding::KeyboardKey(key) | InputBinding::Scancode(key)) => event.control == key,
        Ok(InputBinding::MouseButton(button)) => event.control == format!("mouse{button}"),
        Ok(InputBinding::GamepadButton { gamepad_id, button }) => {
            event.device == crate::input::InputDevice::Gamepad(gamepad_id)
                && (event.control == button.to_string()
                    || crate::input::standard_button_code(&event.control) == Some(button))
        }
        Ok(InputBinding::GamepadNamed {
            gamepad_id,
            player,
            button,
        }) => {
            let device_matches = match event.device {
                crate::input::InputDevice::Gamepad(id) => {
                    gamepad_id.is_none_or(|expected| expected == id)
                        && player
                            .is_none_or(|expected| st.gamepad_players.get(&expected) == Some(&id))
                }
                _ => false,
            };
            device_matches
                && crate::input::standard_button_code(&event.control)
                    == crate::input::standard_button_code(&button)
        }
        _ => false,
    }
}

/// Evaluates action press history without relying on a previous polling query.
fn action_was_pressed_within_history(st: &SharedState, def: &ActionDef, frames: u64) -> bool {
    let current_frame = st.clock.frame_count();
    let events = st.input_history.snapshot();
    def.bindings.iter().any(|binding| {
        if let Some((within_ms, keys)) = chord_parts(binding) {
            let mut newest = 0_u64;
            let mut oldest = u64::MAX;
            for key in keys {
                let Some(event) = events.iter().rev().find(|event| {
                    current_frame.saturating_sub(event.frame) <= frames
                        && history_press_matches_binding(st, event, key)
                }) else {
                    return false;
                };
                newest = newest.max(event.time_ms);
                oldest = oldest.min(event.time_ms);
            }
            newest.saturating_sub(oldest) <= within_ms
        } else {
            st.input_history
                .newest_within_frames(current_frame, frames, |event| {
                    history_press_matches_binding(st, event, binding)
                })
        }
    })
}
/// Lua-side cursor handle for system and custom cursor requests.
pub struct LuaCursor {
    /// Cursor kind and custom image metadata.
    kind: CursorKind,
}
/// Provides Lua methods for cursor handles.
impl LuaUserData for LuaCursor {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- release --
        /// Releases cursor resources; currently a no-op for managed cursor handles.
        methods.add_method("release", |_, _this, ()| Ok(()));
        // -- getType --
        /// Returns whether this cursor is a system cursor or custom cursor.
        /// @return | string | `system` or `custom`.
        methods.add_method("getType", |_, this, ()| {
            Ok(match &this.kind {
                CursorKind::System(_) => "system",
                CursorKind::Custom { .. } => "custom",
            })
        });
        // -- type --
        /// Returns the Lua-visible type name for this cursor handle.
        /// @return | string | The string `LCursor`.
        methods.add_method("type", |_, _, ()| Ok("LCursor"));
        // -- typeOf --
        /// Returns whether this cursor handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LCursor` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LCursor" || name == "LObject")
        });
    }
}
/// Lua-side combo detector handle tracking ordered key sequences.
struct LuaCombo {
    /// Combo detector with steps and gap timing.
    detector: ComboDetector,
    /// Total elapsed time since the last feed or reset.
    total_elapsed_ms: u64,
    /// Shared runtime state used to consume normalized input history in automatic mode.
    state: Rc<RefCell<SharedState>>,
    /// True when the caller exclusively drives the detector through `feed` and `tick`.
    manual: bool,
    /// Number of retained history events already inspected by this detector.
    history_seen: usize,
    /// Timestamp used to calculate elapsed time between automatic input steps.
    last_input_time_ms: u64,
    /// Timestamp of the last completed automatic or manual match.
    completed_at_ms: Option<u64>,
    /// Whether the latest completion was consumed by game code.
    consumed: bool,
    /// Rich automatic steps used by the fighting-game combo API.
    auto_steps: Vec<AutoComboStep>,
    /// Index of the next automatic step.
    auto_progress: usize,
    /// Timestamp of the first matched automatic step.
    auto_started_at_ms: Option<u64>,
    /// Timestamp of the last matched automatic step.
    auto_last_step_at_ms: Option<u64>,
    /// Held controls and their original press timestamps.
    held_since: HashMap<String, u64>,
    /// Recent press timestamps, used to resolve chord windows.
    recent_presses: HashMap<String, u64>,
    /// Current digital directions for direction/neutral steps.
    directions: std::collections::HashSet<String>,
    /// Most recent left-stick axes used to quantize eight-way directions.
    direction_axes: (f32, f32),
    /// Optional player slot limiting automatic events to one assigned gamepad.
    source_player: Option<u32>,
    /// Completion retention window used as the fighting-game input buffer.
    input_buffer_ms: u64,
}

/// A normalized fighting-game combo step.  It deliberately lives beside the Lua conversion
/// layer while legacy `ComboStep` continues to power the original feed/tick API.
#[derive(Clone, Debug)]
enum AutoComboStep {
    Press(String, u64),
    Release(String, u64),
    Chord(Vec<String>, u64, u64),
    Direction(String, u64),
    Hold(String, u64, u64),
    Neutral(u64),
}

impl AutoComboStep {
    fn gap_ms(&self) -> u64 {
        match self {
            Self::Press(_, gap)
            | Self::Release(_, gap)
            | Self::Direction(_, gap)
            | Self::Neutral(gap) => *gap,
            Self::Chord(_, _, gap) | Self::Hold(_, _, gap) => *gap,
        }
    }
}

impl LuaCombo {
    fn normalized_direction(&self) -> String {
        let mut x = self.direction_axes.0;
        let mut y = self.direction_axes.1;
        if self.directions.contains("left") {
            x = -1.0;
        }
        if self.directions.contains("right") {
            x = 1.0;
        }
        if self.directions.contains("up") {
            y = -1.0;
        }
        if self.directions.contains("down") {
            y = 1.0;
        }
        let horizontal = if x <= -0.5 {
            "left"
        } else if x >= 0.5 {
            "right"
        } else {
            ""
        };
        let vertical = if y <= -0.5 {
            "up"
        } else if y >= 0.5 {
            "down"
        } else {
            ""
        };
        match (vertical, horizontal) {
            ("", "") => "neutral".to_string(),
            ("", h) => h.to_string(),
            (v, "") => v.to_string(),
            ("down", "right") => "down_right".to_string(),
            ("down", "left") => "down_left".to_string(),
            ("up", "right") => "up_right".to_string(),
            ("up", "left") => "up_left".to_string(),
            _ => "neutral".to_string(),
        }
    }

    fn update_direction(&mut self, event: &crate::input::InputHistoryEvent) {
        let control = match event.control.as_str() {
            "dpad_up" | "dpup" => "up",
            "dpad_down" | "dpdown" => "down",
            "dpad_left" | "dpleft" => "left",
            "dpad_right" | "dpright" => "right",
            other => other,
        };
        if matches!(control, "up" | "down" | "left" | "right") {
            match event.kind {
                crate::input::InputEventKind::Press => {
                    self.directions.insert(control.to_string());
                }
                crate::input::InputEventKind::Release => {
                    self.directions.remove(control);
                }
                _ => {}
            }
        }
        if event.kind == crate::input::InputEventKind::Axis {
            match event.control.as_str() {
                "leftx" => self.direction_axes.0 = event.value.unwrap_or(0.0),
                "lefty" => self.direction_axes.1 = event.value.unwrap_or(0.0),
                _ => {}
            }
        }
    }

    fn event_matches_step(
        &self,
        step: &AutoComboStep,
        event: &crate::input::InputHistoryEvent,
    ) -> bool {
        match step {
            AutoComboStep::Press(control, _) => {
                event.kind == crate::input::InputEventKind::Press && &event.control == control
            }
            AutoComboStep::Release(control, _) => {
                event.kind == crate::input::InputEventKind::Release && &event.control == control
            }
            AutoComboStep::Direction(direction, _) => {
                matches!(
                    event.kind,
                    crate::input::InputEventKind::Press | crate::input::InputEventKind::Axis
                ) && self.normalized_direction() == *direction
            }
            AutoComboStep::Neutral(_) => {
                event.kind == crate::input::InputEventKind::Release
                    && self.normalized_direction() == "neutral"
            }
            AutoComboStep::Hold(control, min_hold_ms, _) => {
                event.kind == crate::input::InputEventKind::Release
                    && &event.control == control
                    && self.held_since.get(control).is_some_and(|started| {
                        event.time_ms.saturating_sub(*started) >= *min_hold_ms
                    })
            }
            AutoComboStep::Chord(controls, within_ms, _) => {
                event.kind == crate::input::InputEventKind::Press
                    && controls.iter().all(|control| {
                        self.recent_presses
                            .get(control)
                            .is_some_and(|time| event.time_ms.saturating_sub(*time) <= *within_ms)
                    })
            }
        }
    }

    fn advance_auto(&mut self, event: &crate::input::InputHistoryEvent) {
        if self.auto_steps.is_empty() {
            return;
        }
        if let Some(last) = self.auto_last_step_at_ms {
            let gap = self.auto_steps[self.auto_progress].gap_ms();
            if event.time_ms.saturating_sub(last) > gap
                || self.auto_started_at_ms.is_some_and(|started| {
                    event.time_ms.saturating_sub(started) > self.detector.max_total_gap_ms
                })
            {
                self.auto_progress = 0;
                self.auto_started_at_ms = None;
            }
        }
        let matches = self.event_matches_step(&self.auto_steps[self.auto_progress], event);
        if matches {
            if self.auto_progress == 0 {
                self.auto_started_at_ms = Some(event.time_ms);
            }
            self.auto_last_step_at_ms = Some(event.time_ms);
            self.auto_progress += 1;
            if self.auto_progress == self.auto_steps.len() {
                self.completed_at_ms = Some(event.time_ms);
                self.consumed = false;
                self.auto_progress = 0;
                self.auto_started_at_ms = None;
            }
        } else if self.auto_progress > 0 {
            // Prefix recovery: the mismatching event may itself start the next attempt.
            self.auto_progress = 0;
            self.auto_started_at_ms = None;
            if self.event_matches_step(&self.auto_steps[0], event) {
                self.auto_progress = 1;
                self.auto_started_at_ms = Some(event.time_ms);
                self.auto_last_step_at_ms = Some(event.time_ms);
            }
        }
    }

    fn process_auto_event(&mut self, event: &crate::input::InputHistoryEvent) {
        self.update_direction(event);
        match event.kind {
            crate::input::InputEventKind::Press => {
                self.held_since.insert(event.control.clone(), event.time_ms);
                self.recent_presses
                    .insert(event.control.clone(), event.time_ms);
            }
            crate::input::InputEventKind::Release => {}
            _ => {}
        }
        self.advance_auto(event);
        if event.kind == crate::input::InputEventKind::Release {
            self.held_since.remove(&event.control);
        }
    }

    /// Feeds newly received press events from the shared history into an automatic combo.
    fn poll_history(&mut self) {
        if self.manual {
            return;
        }
        let events = self.state.borrow().input_history.snapshot();
        if events.len() < self.history_seen {
            self.history_seen = 0;
        }
        for event in events.iter().skip(self.history_seen) {
            if let Some(player) = self.source_player {
                if let crate::input::InputDevice::Gamepad(id) = event.device {
                    if self.state.borrow().gamepad_players.get(&player) != Some(&id) {
                        continue;
                    }
                }
            }
            let elapsed_ms = event.time_ms.saturating_sub(self.last_input_time_ms);
            self.last_input_time_ms = event.time_ms;
            self.total_elapsed_ms = self.total_elapsed_ms.saturating_add(elapsed_ms);
            self.process_auto_event(event);
        }
        self.history_seen = events.len();
    }
}
/// Provides Lua methods for feeding and inspecting combo progress.
impl LuaUserData for LuaCombo {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- feed --
        /// Feeds one key into the combo detector and returns progress status.
        /// @param | key | string | Key name to feed into the combo sequence.
        /// @return | string | `completed`, `advanced`, `broken`, or `idle`.
        methods.add_method_mut("feed", |_, this, key: String| {
            if !this.manual {
                return Ok("idle");
            }
            let progress = this.detector.feed(&key, 0);
            this.total_elapsed_ms = 0;
            if progress == crate::input::combo::ComboProgress::Completed {
                this.completed_at_ms =
                    Some((this.state.borrow().clock.total() * 1000.0).max(0.0) as u64);
                this.consumed = false;
            }
            let result = match progress {
                crate::input::combo::ComboProgress::Completed => "completed",
                crate::input::combo::ComboProgress::Advanced { .. } => "advanced",
                crate::input::combo::ComboProgress::Broken => "broken",
                crate::input::combo::ComboProgress::Idle => "idle",
            };
            Ok(result)
        });
        // -- tick --
        /// Advances combo timeout state and returns progress status.
        /// @param | dt | number | Delta time in seconds.
        /// @return | string | `expired`, `in_progress`, or `idle`.
        methods.add_method_mut("tick", |_, this, dt: f64| {
            let elapsed_ms = (dt * 1000.0).round() as u64;
            this.total_elapsed_ms += elapsed_ms;
            let progress = this.detector.tick(elapsed_ms);
            let result = match progress {
                crate::input::combo::ComboProgress::Broken => "expired",
                crate::input::combo::ComboProgress::Advanced { .. } => "in_progress",
                _ => "idle",
            };
            Ok(result)
        });
        // -- reset --
        /// Resets combo progress and elapsed time.
        methods.add_method_mut("reset", |_, this, ()| {
            this.detector.reset();
            this.total_elapsed_ms = 0;
            this.auto_progress = 0;
            this.auto_started_at_ms = None;
            this.auto_last_step_at_ms = None;
            this.held_since.clear();
            this.recent_presses.clear();
            this.directions.clear();
            this.direction_axes = (0.0, 0.0);
            this.completed_at_ms = None;
            this.consumed = false;
            Ok(())
        });
        // -- update --
        /// Updates an automatic combo from normalized runtime input history.
        /// @return | boolean | True when the combo completed during this update.
        methods.add_method_mut("update", |_, this, ()| {
            let before = this.completed_at_ms;
            this.poll_history();
            Ok(this.completed_at_ms != before && !this.consumed)
        });
        // -- wasCompleted --
        /// Returns whether the combo completed and has not been consumed.
        /// @return | boolean | True when a completion is pending.
        methods.add_method_mut("wasCompleted", |_, this, ()| {
            this.poll_history();
            let now = (this.state.borrow().clock.total() * 1000.0).max(0.0) as u64;
            Ok(this.completed_at_ms.is_some_and(|time| {
                this.input_buffer_ms == 0 || now.saturating_sub(time) <= this.input_buffer_ms
            }) && !this.consumed)
        });
        // -- completedWithin --
        /// Returns whether the combo completed within a recent millisecond window.
        /// @param | ms | integer | Inclusive age limit in milliseconds.
        /// @return | boolean | True when an unconsumed completion is recent.
        methods.add_method_mut("completedWithin", |_, this, ms: u64| {
            this.poll_history();
            let now = (this.state.borrow().clock.total() * 1000.0).max(0.0) as u64;
            Ok(this
                .completed_at_ms
                .is_some_and(|time| now.saturating_sub(time) <= ms)
                && !this.consumed)
        });
        // -- consume --
        /// Marks the latest combo completion as consumed.
        methods.add_method_mut("consume", |_, this, ()| {
            let pending = this.completed_at_ms.is_some() && !this.consumed;
            this.consumed = true;
            Ok(pending)
        });
        // -- progress --
        /// Returns the current combo step index reached.
        /// @return | integer | Number of completed combo steps.
        methods.add_method("progress", |_, this, ()| {
            Ok(if this.manual {
                this.detector.progress() as i64
            } else {
                this.auto_progress as i64
            })
        });
        // -- totalSteps --
        /// Returns the number of steps in this combo sequence.
        /// @return | integer | Total combo step count.
        methods.add_method("totalSteps", |_, this, ()| Ok(this.detector.len() as i64));
        // -- isInProgress --
        /// Returns whether the combo sequence is partially matched.
        /// @return | boolean | True when the combo is in progress.
        methods.add_method("isInProgress", |_, this, ()| {
            Ok(if this.manual {
                this.detector.is_in_progress()
            } else {
                this.auto_progress > 0
            })
        });
        // -- getStep --
        /// Returns step data by one-based index.
        /// @param | index | integer | One-based combo step index.
        /// @return | table | Step table with `key` and `gap_ms`, or nil when out of range.
        /// @field | key | string | Key name.
        /// @field | gap_ms | number | Gap in milliseconds.
        methods.add_method("getStep", |lua, this, index: usize| {
            if index == 0 || index > this.detector.steps.len() {
                return Ok(LuaValue::Nil);
            }
            let step = &this.detector.steps[index - 1];
            let tbl = lua.create_table()?;
            /// The 'key' field value exposed to Lua scripts.
            tbl.set("key", step.key.clone())?;
            /// Performs the 'gap_ms' operation.
            tbl.set("gap_ms", step.max_gap_ms)?;
            Ok(LuaValue::Table(tbl))
        });
        // -- type --
        /// Returns the Lua-visible type name for this combo handle.
        /// @return | string | The string `LCombo`.
        methods.add_method("type", |_, _, ()| Ok("LCombo"));
        // -- typeOf --
        /// Returns whether this combo handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LCombo` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LCombo" || name == "LObject")
        });
    }
}
/// Lua-side handle for serialized input recording data.
struct LuaInputRecording {
    /// Recorded input frames and metadata.
    inner: crate::input::recorder::InputRecording,
}
/// Provides Lua methods for recording metadata and JSON export.
impl LuaUserData for LuaInputRecording {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- toJson --
        /// Serializes this input recording to JSON text.
        /// @return | string | Recording JSON.
        methods.add_method("toJson", |_, this, ()| {
            this.inner.to_json().map_err(LuaError::RuntimeError)
        });
        // -- totalFrames --
        /// Returns total frame count stored in this recording.
        /// @return | integer | Total recorded frames.
        methods.add_method("totalFrames", |_, this, ()| {
            Ok(this.inner.total_frames as i64)
        });
        // -- frameCount --
        /// Returns the number of event frames stored in this recording.
        /// @return | integer | Stored event frame count.
        methods.add_method("frameCount", |_, this, ()| {
            Ok(this.inner.frames.len() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this input recording handle.
        /// @return | string | The string `LInputRecording`.
        methods.add_method("type", |_, _, ()| Ok("LInputRecording"));
        // -- typeOf --
        /// Returns whether this input recording handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LInputRecording` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LInputRecording" || name == "LObject")
        });
    }
}
/// Registers `lurek.input` keyboard, mouse, gamepad, touch, action, combo, and recording helpers.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let input_tbl = lua.create_table()?;
    let player_registry = Rc::new(RefCell::new(PlayerInputRegistry::default()));
    let player_state = state.clone();
    let registry = player_registry.clone();
    // -- newPlayerContext --
    /// Creates an isolated player-scoped input context with local action names.
    /// @param | player_id | integer | Positive player identifier used for diagnostics.
    /// @return | LPlayerInputContext | New context with no assigned devices or actions.
    input_tbl.set(
        "newPlayerContext",
        lua.create_function(move |_, player_id: u32| {
            let context_id = registry
                .borrow_mut()
                .allocate_context_id()
                .map_err(|error| {
                    LuaError::RuntimeError(format!("lurek.input.newPlayerContext: {error}"))
                })?;
            let context = PlayerInputContext::new(context_id, player_id).map_err(|error| {
                LuaError::RuntimeError(format!("lurek.input.newPlayerContext: {error}"))
            })?;
            Ok(LuaPlayerInputContext {
                context,
                state: player_state.clone(),
                registry: registry.clone(),
            })
        })?,
    )?;
    let keyboard = lua.create_table()?;
    let s = state.clone();
    // -- keyboard.isDown --
    /// Returns whether any of the supplied key names are currently held down.
    /// @param | ... | string | One or more key name strings (e.g. `"space"`, `"w"`, `"up"`). At least one required.
    /// @return | boolean | `true` if any of the given keys is currently pressed.
    keyboard.set(
        "isDown",
        lua.create_function(move |_, args: Variadic<String>| {
            Ok(s.borrow().keyboard.is_any_down(&args))
        })?,
    )?;
    let s = state.clone();
    // -- keyboard.isScancodeDown --
    /// Returns whether a scancode is currently down.
    /// @param | scancode | string | Keyboard scancode name.
    /// @return | boolean | True when the scancode is down.
    keyboard.set(
        "isScancodeDown",
        lua.create_function(move |_, scancode: String| {
            Ok(s.borrow().keyboard.is_scancode_down(&scancode))
        })?,
    )?;
    let s = state.clone();
    // -- keyboard.wasPressed --
    /// Returns whether a logical key transitioned to pressed this frame.
    /// @param | key | string | Logical key name.
    /// @return | boolean | True when the key was pressed this frame.
    keyboard.set(
        "wasPressed",
        lua.create_function(move |_, key: String| {
            Ok(s.borrow()
                .keyboard
                .get_pressed()
                .iter()
                .any(|pressed| pressed == &key))
        })?,
    )?;
    let s = state.clone();
    // -- keyboard.wasReleased --
    /// Returns whether a logical key transitioned to released this frame.
    /// @param | key | string | Logical key name.
    /// @return | boolean | True when the key was released this frame.
    keyboard.set(
        "wasReleased",
        lua.create_function(move |_, key: String| {
            Ok(s.borrow()
                .keyboard
                .get_released()
                .iter()
                .any(|released| released == &key))
        })?,
    )?;
    let s = state.clone();
    // -- keyboard.wasScancodePressed --
    /// Returns whether a physical keyboard scancode transitioned to pressed this frame.
    /// @param | scancode | string | Physical scancode name.
    /// @return | boolean | True when the scancode was pressed this frame.
    keyboard.set(
        "wasScancodePressed",
        lua.create_function(move |_, scancode: String| {
            Ok(s.borrow().keyboard.was_scancode_pressed(&scancode))
        })?,
    )?;
    let s = state.clone();
    // -- keyboard.wasScancodeReleased --
    /// Returns whether a physical keyboard scancode transitioned to released this frame.
    /// @param | scancode | string | Physical scancode name.
    /// @return | boolean | True when the scancode was released this frame.
    keyboard.set(
        "wasScancodeReleased",
        lua.create_function(move |_, scancode: String| {
            Ok(s.borrow().keyboard.was_scancode_released(&scancode))
        })?,
    )?;
    let s = state.clone();
    // -- keyboard.setKeyRepeat --
    /// Enables or disables key repeat tracking.
    /// @param | enabled | boolean | New key repeat flag.
    keyboard.set(
        "setKeyRepeat",
        lua.create_function(move |_, enabled: bool| {
            s.borrow_mut().keyboard.set_key_repeat(enabled);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- keyboard.hasKeyRepeat --
    /// Returns whether key repeat tracking is enabled.
    /// @return | boolean | True when key repeat is enabled.
    keyboard.set(
        "hasKeyRepeat",
        lua.create_function(move |_, ()| Ok(s.borrow().keyboard.has_key_repeat()))?,
    )?;
    let s = state.clone();
    // -- keyboard.setTextInput --
    /// Enables or disables text input tracking.
    /// @param | enabled | boolean | New text input flag.
    keyboard.set(
        "setTextInput",
        lua.create_function(move |_, enabled: bool| {
            s.borrow_mut().keyboard.set_text_input(enabled);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- keyboard.hasTextInput --
    /// Returns whether text input tracking is enabled.
    /// @return | boolean | True when text input is enabled.
    keyboard.set(
        "hasTextInput",
        lua.create_function(move |_, ()| Ok(s.borrow().keyboard.has_text_input()))?,
    )?;
    let s = state.clone();
    // -- keyboard.getTextInput --
    /// Returns committed text segments received during the current frame.
    /// @return | string[] | Text segments in arrival order.
    keyboard.set(
        "getTextInput",
        lua.create_function(move |lua, ()| {
            let table = lua.create_table()?;
            for (index, text) in s.borrow().keyboard.get_text_input().iter().enumerate() {
                table.set(index + 1, text.clone())?;
            }
            Ok(table)
        })?,
    )?;
    // -- keyboard.getScancodeFromKey --
    /// Converts a key name to its scancode name when known.
    /// @param | key | string | Key name.
    /// @return | string | Scancode string, or nil when unknown.
    keyboard.set(
        "getScancodeFromKey",
        lua.create_function(move |_, key: String| Ok(get_scancode_from_key(&key)))?,
    )?;
    // -- keyboard.getKeyFromScancode --
    /// Converts a scancode name to its key name when known.
    /// @param | scancode | string | Scancode name.
    /// @return | string | Key string, or nil when unknown.
    keyboard.set(
        "getKeyFromScancode",
        lua.create_function(move |_, scancode: String| Ok(get_key_from_scancode(&scancode)))?,
    )?;
    let s = state.clone();
    // -- keyboard.isModifierActive --
    /// Returns whether a named keyboard modifier is active.
    /// @param | modifier | string | Modifier name such as shift, ctrl, alt, or gui.
    /// @return | boolean | True when the modifier is active.
    keyboard.set(
        "isModifierActive",
        lua.create_function(move |_, modifier: String| {
            Ok(s.borrow().keyboard.is_modifier_active(&modifier))
        })?,
    )?;
    /// Performs the 'keyboard' operation.
    input_tbl.set("keyboard", keyboard)?;
    let mouse = lua.create_table()?;
    let s = state.clone();
    // -- mouse.getPosition --
    /// Returns the current mouse position.
    /// @return | number | Mouse x coordinate.
    /// @return | number | Mouse y coordinate.
    mouse.set(
        "getPosition",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            Ok((st.mouse.x, st.mouse.y))
        })?,
    )?;
    let s = state.clone();
    // -- mouse.getX --
    /// Returns the current mouse x coordinate.
    /// @return | number | Mouse x coordinate.
    mouse.set(
        "getX",
        lua.create_function(move |_, ()| Ok(s.borrow().mouse.x))?,
    )?;
    let s = state.clone();
    // -- mouse.getY --
    /// Returns the current mouse y coordinate.
    /// @return | number | Mouse y coordinate.
    mouse.set(
        "getY",
        lua.create_function(move |_, ()| Ok(s.borrow().mouse.y))?,
    )?;
    let s = state.clone();
    // -- mouse.isDown --
    /// Returns whether a one-based mouse button index is down.
    /// @param | button | integer | One-based mouse button index.
    /// @return | boolean | True when the button is down.
    mouse.set(
        "isDown",
        lua.create_function(move |_, button: usize| {
            Ok(s.borrow().mouse.is_down(button.saturating_sub(1)))
        })?,
    )?;
    let s = state.clone();
    // -- mouse.wasPressed --
    /// Returns whether a one-based mouse button index transitioned to pressed this frame.
    /// @param | button | integer | One-based mouse button index.
    /// @return | boolean | True when the button was pressed this frame.
    mouse.set(
        "wasPressed",
        lua.create_function(move |_, button: usize| {
            Ok(s.borrow().mouse.was_pressed(button.saturating_sub(1)))
        })?,
    )?;
    let s = state.clone();
    // -- mouse.wasReleased --
    /// Returns whether a one-based mouse button index transitioned to released this frame.
    /// @param | button | integer | One-based mouse button index.
    /// @return | boolean | True when the button was released this frame.
    mouse.set(
        "wasReleased",
        lua.create_function(move |_, button: usize| {
            Ok(s.borrow().mouse.was_released(button.saturating_sub(1)))
        })?,
    )?;
    let s = state.clone();
    // -- mouse.getDelta --
    /// Returns raw pointer movement accumulated during the current frame.
    /// @return | number | Horizontal raw movement.
    /// @return | number | Vertical raw movement.
    mouse.set(
        "getDelta",
        lua.create_function(move |_, ()| Ok(s.borrow().mouse.get_delta()))?,
    )?;
    let s = state.clone();
    // -- mouse.setVisible --
    /// Sets the mouse cursor visibility state.
    /// @param | visible | boolean | New cursor visibility flag.
    mouse.set(
        "setVisible",
        lua.create_function(move |_, visible: bool| {
            s.borrow_mut().mouse.set_visible(visible);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- mouse.isVisible --
    /// Returns whether the mouse cursor is visible.
    /// @return | boolean | True when the cursor is visible.
    mouse.set(
        "isVisible",
        lua.create_function(move |_, ()| Ok(s.borrow().mouse.is_visible()))?,
    )?;
    let s = state.clone();
    // -- mouse.setGrabbed --
    /// Sets whether the mouse is grabbed by the window.
    /// @param | grabbed | boolean | New grabbed flag.
    mouse.set(
        "setGrabbed",
        lua.create_function(move |_, grabbed: bool| {
            s.borrow_mut().mouse.set_grabbed(grabbed);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- mouse.isGrabbed --
    /// Returns whether the mouse is grabbed by the window.
    /// @return | boolean | True when the mouse is grabbed.
    mouse.set(
        "isGrabbed",
        lua.create_function(move |_, ()| Ok(s.borrow().mouse.is_grabbed()))?,
    )?;
    let s = state.clone();
    // -- mouse.setRelativeMode --
    /// Sets the relative mouse input mode state.
    /// @param | relative | boolean | New relative mode flag.
    mouse.set(
        "setRelativeMode",
        lua.create_function(move |_, relative: bool| {
            s.borrow_mut().mouse.set_relative_mode(relative);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- mouse.getRelativeMode --
    /// Returns whether relative mouse mode is enabled.
    /// @return | boolean | True when relative mode is enabled.
    mouse.set(
        "getRelativeMode",
        lua.create_function(move |_, ()| Ok(s.borrow().mouse.get_relative_mode()))?,
    )?;
    let s = state.clone();
    // -- mouse.setPosition --
    /// Requests a mouse cursor position change.
    /// @param | x | number | Target x coordinate.
    /// @param | y | number | Target y coordinate.
    mouse.set(
        "setPosition",
        lua.create_function(move |_, (x, y): (f32, f32)| {
            s.borrow_mut().mouse.request_position(x, y);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- mouse.setCursor --
    /// Sets the active cursor from a cursor handle, system cursor name, or nil for arrow.
    /// @param | cursor | any | `LCursor`, system cursor string, or nil.
    mouse.set(
        "setCursor",
        lua.create_function(move |_, cursor_val: LuaValue| {
            let mut st = s.borrow_mut();
            match cursor_val {
                LuaValue::UserData(ud) => {
                    if let Ok(cursor) = ud.borrow::<LuaCursor>() {
                        match &cursor.kind {
                            CursorKind::System(sc) => st.mouse.set_cursor(*sc),
                            CursorKind::Custom { .. } => {
                                st.mouse.set_cursor(SystemCursor::Arrow);
                            }
                        }
                    }
                }
                LuaValue::String(name_str) => {
                    st.mouse.set_cursor(SystemCursor::from_name(
                        name_str.to_str().unwrap_or("arrow"),
                    ));
                }
                LuaValue::Nil => {
                    st.mouse.set_cursor(SystemCursor::Arrow);
                }
                _ => {}
            }
            Ok(())
        })?,
    )?;
    // -- mouse.newCursor --
    /// Creates a custom cursor handle from RGBA pixels and hotspot coordinates.
    /// @param | pixels | table | Cursor pixel bytes.
    /// @param | width | integer | Cursor width in pixels.
    /// @param | height | integer | Cursor height in pixels.
    /// @param | hotx | integer? | Optional hotspot x coordinate.
    /// @param | hoty | integer? | Optional hotspot y coordinate.
    /// @return | LCursor | New custom cursor handle.
    mouse.set(
        "newCursor",
        lua.create_function(
            move |_,
                  (pixels, width, height, hotx, hoty): (
                Vec<u8>,
                u32,
                u32,
                Option<u32>,
                Option<u32>,
            )| {
                let hotx = hotx.unwrap_or(0);
                let hoty = hoty.unwrap_or(0);
                validate_cursor_image(
                    width,
                    height,
                    pixels.len(),
                    hotx,
                    hoty,
                    CursorImageLimits::default(),
                )
                .map_err(|e| LuaError::RuntimeError(format!("input.mouse.newCursor: {e}")))?;
                Ok(LuaCursor {
                    kind: CursorKind::Custom {
                        pixels,
                        width,
                        height,
                        hotx,
                        hoty,
                    },
                })
            },
        )?,
    )?;
    // -- mouse.getSystemCursor --
    /// Creates a system cursor handle from a cursor name.
    /// @param | name | string | System cursor name.
    /// @return | LCursor | System cursor handle.
    mouse.set(
        "getSystemCursor",
        lua.create_function(move |_, name: String| {
            Ok(LuaCursor {
                kind: CursorKind::System(SystemCursor::from_name(&name)),
            })
        })?,
    )?;
    // -- mouse.isCursorSupported --
    /// Returns whether the current platform supports cursor changes.
    /// @return | boolean | True when cursor changes are supported.
    mouse.set(
        "isCursorSupported",
        lua.create_function(move |_, ()| Ok(is_cursor_supported()))?,
    )?;
    let s = state.clone();
    // -- mouse.getCursor --
    /// Returns the current system cursor name.
    /// @return | string | Current cursor name.
    mouse.set(
        "getCursor",
        lua.create_function(move |_, ()| Ok(s.borrow().mouse.get_cursor().as_str().to_string()))?,
    )?;
    let s = state.clone();
    // -- mouse.getWheelDelta --
    /// Returns the current mouse wheel delta.
    /// @return | number | Horizontal wheel delta.
    /// @return | number | Vertical wheel delta.
    mouse.set(
        "getWheelDelta",
        lua.create_function(move |_, ()| Ok(s.borrow().mouse.get_scroll()))?,
    )?;
    /// Performs the 'mouse' operation.
    input_tbl.set("mouse", mouse)?;
    let gamepad = lua.create_table()?;
    let s = state.clone();
    // -- gamepad.getCount --
    /// Returns the number of gamepad slots tracked by the runtime.
    /// @return | integer | Gamepad slot count.
    gamepad.set(
        "getCount",
        lua.create_function(move |_, ()| Ok(s.borrow().gamepads.len()))?,
    )?;
    let s = state.clone();
    // -- gamepad.getJoystickCount --
    /// Returns the number of joystick slots tracked by the runtime.
    /// @return | integer | Joystick slot count.
    gamepad.set(
        "getJoystickCount",
        lua.create_function(move |_, ()| Ok(s.borrow().gamepads.len()))?,
    )?;
    let s = state.clone();
    // -- gamepad.getJoysticks --
    /// Returns ids for currently connected gamepads.
    /// @return | integer[] | Array table of connected gamepad ids.
    gamepad.set(
        "getJoysticks",
        lua.create_function(move |lua, ()| {
            let st = s.borrow();
            let tbl = lua.create_table()?;
            for gp in &st.gamepads {
                if gp.connected {
                    tbl.push(gp.id as i64)?;
                }
            }
            Ok(tbl)
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.isConnected --
    /// Returns whether a gamepad id is currently connected.
    /// @param | id | integer | Gamepad id.
    /// @return | boolean | True when the gamepad is connected.
    gamepad.set(
        "isConnected",
        lua.create_function(move |_, id: usize| {
            Ok(s.borrow().gamepads.get(id).is_some_and(|gp| gp.connected))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getName --
    /// Returns a gamepad display name by its id.
    /// @param | id | integer | Gamepad id.
    /// @return | string | Gamepad name, or `Unknown` when missing.
    gamepad.set(
        "getName",
        lua.create_function(move |_, id: usize| {
            let st = s.borrow();
            Ok(st
                .gamepads
                .get(id)
                .map_or_else(|| "Unknown".to_string(), |gp| gp.name.clone()))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.isGamepad --
    /// Returns whether a connected gamepad exists at an id.
    /// @param | id | integer | Gamepad id.
    /// @return | boolean | True when the id is a connected gamepad.
    gamepad.set(
        "isGamepad",
        lua.create_function(move |_, id: usize| {
            Ok(s.borrow().gamepads.get(id).is_some_and(|gp| gp.connected))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getButtonCount --
    /// Returns the button count for a gamepad.
    /// @param | id | integer | Gamepad id.
    /// @return | integer | Button count, or zero when missing.
    gamepad.set(
        "getButtonCount",
        lua.create_function(move |_, id: usize| {
            Ok(s.borrow()
                .gamepads
                .get(id)
                .map_or(0, |gp| gp.get_button_count()))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getAxisCount --
    /// Returns the axis count for a gamepad.
    /// @param | id | integer | Gamepad id.
    /// @return | integer | Axis count, or zero when missing.
    gamepad.set(
        "getAxisCount",
        lua.create_function(move |_, id: usize| {
            Ok(s.borrow()
                .gamepads
                .get(id)
                .map_or(0, |gp| gp.get_axis_count()))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.isDown --
    /// Returns whether a gamepad button is currently down.
    /// @param | id | integer | Gamepad id.
    /// @param | button | integer | Button index.
    /// @return | boolean | True when the button is down.
    gamepad.set(
        "isDown",
        lua.create_function(move |_, (id, button): (usize, u32)| {
            Ok(s.borrow()
                .gamepads
                .get(id)
                .is_some_and(|gp| gp.is_button_pressed(button)))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getAxis --
    /// Returns a gamepad axis value by index.
    /// @param | id | integer | Gamepad id.
    /// @param | axis | integer | Axis index.
    /// @return | number | Axis value, or zero when missing.
    gamepad.set(
        "getAxis",
        lua.create_function(move |_, (id, axis): (usize, u32)| {
            Ok(s.borrow()
                .gamepads
                .get(id)
                .map_or(0.0, |gp| gp.get_axis_value(axis)))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getStandardButton --
    /// Returns whether a standard named Xbox button is currently down.
    /// @param | id | integer | Gamepad id.
    /// @param | name | string | Standard button name such as `a` or `dpad_up`.
    /// @return | boolean | True when the named button is down.
    gamepad.set(
        "getStandardButton",
        lua.create_function(move |_, (id, name): (usize, String)| {
            Ok(s.borrow()
                .gamepads
                .get(id)
                .is_some_and(|gamepad| gamepad.is_standard_button_pressed(&name)))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getStandardAxis --
    /// Returns a standard named Xbox axis value.
    /// @param | id | integer | Gamepad id.
    /// @param | name | string | Standard axis name such as `leftx`.
    /// @return | number | Axis value, or zero for missing input.
    gamepad.set(
        "getStandardAxis",
        lua.create_function(move |_, (id, name): (usize, String)| {
            let st = s.borrow();
            let value = st
                .gamepads
                .get(id)
                .map_or(0.0, |gamepad| gamepad.get_standard_axis_value(&name));
            let group = match name.to_ascii_lowercase().as_str() {
                "leftx" | "lefty" | "left_x" | "left_y" => "leftstick",
                "rightx" | "righty" | "right_x" | "right_y" => "rightstick",
                "lefttrigger" | "left_trigger" => "lefttrigger",
                "righttrigger" | "right_trigger" => "righttrigger",
                _ => return Ok(value),
            };
            let deadzone = st
                .gamepad_deadzones
                .get(&(id, group.to_string()))
                .copied()
                .unwrap_or(0.0);
            Ok(if value.abs() <= deadzone {
                0.0
            } else if value.is_sign_positive() {
                ((value - deadzone) / (1.0 - deadzone).max(f32::EPSILON)).clamp(0.0, 1.0)
            } else {
                ((value + deadzone) / (1.0 - deadzone).max(f32::EPSILON)).clamp(-1.0, 0.0)
            })
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.setDeadzone --
    /// Sets a per-gamepad deadzone for a named stick or axis group.
    /// @param | id | integer | Gamepad id.
    /// @param | stick | string | Stick or axis group name.
    /// @param | value | number | Deadzone clamped to the inclusive range 0.0..=1.0.
    gamepad.set(
        "setDeadzone",
        lua.create_function(move |_, (id, stick, value): (usize, String, f32)| {
            if !value.is_finite() {
                return Err(LuaError::RuntimeError(
                    "input.gamepad.setDeadzone: value must be finite".to_string(),
                ));
            }
            s.borrow_mut()
                .gamepad_deadzones
                .insert((id, stick.to_ascii_lowercase()), value.clamp(0.0, 1.0));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getDeadzone --
    /// Returns a configured per-gamepad deadzone, defaulting to 0.0.
    /// @param | id | integer | Gamepad id.
    /// @param | stick | string | Stick or axis group name.
    /// @return | number | Configured deadzone.
    gamepad.set(
        "getDeadzone",
        lua.create_function(move |_, (id, stick): (usize, String)| {
            Ok(s.borrow()
                .gamepad_deadzones
                .get(&(id, stick.to_ascii_lowercase()))
                .copied()
                .unwrap_or(0.0))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getAssignedPlayer --
    /// Returns the player assigned to a gamepad, or nil when unassigned.
    /// @param | id | integer | Gamepad id.
    /// @return | integer | Assigned player number, or nil.
    gamepad.set(
        "getAssignedPlayer",
        lua.create_function(move |_, id: usize| {
            Ok(s.borrow()
                .gamepad_players
                .iter()
                .find_map(|(player, gamepad)| (*gamepad == id).then_some(*player)))
        })?,
    )?;
    // -- gamepad.virtualDpad --
    /// Converts analog x and y values into virtual d-pad booleans and direction.
    /// @param | x | number | Horizontal analog value.
    /// @param | y | number | Vertical analog value.
    /// @param | deadzone | number? | Deadzone threshold, defaults to 0.3.
    /// @return | table | Table with `up`, `down`, `left`, `right`, and `direction` fields.
    /// @field | up | boolean | Up pressed.
    /// @field | down | boolean | Down pressed.
    /// @field | left | boolean | Left pressed.
    /// @field | right | boolean | Right pressed.
    /// @field | direction | string | Direction name.
    gamepad.set(
        "virtualDpad",
        lua.create_function(move |lua, (x, y, deadzone): (f32, f32, Option<f32>)| {
            let (up, down, left, right, direction) = virtual_dpad(x, y, deadzone.unwrap_or(0.3));
            let tbl = lua.create_table()?;
            /// The 'up' field value exposed to Lua scripts.
            tbl.set("up", up)?;
            /// Performs the 'down' operation.
            tbl.set("down", down)?;
            /// Performs the 'left' operation.
            tbl.set("left", left)?;
            /// Performs the 'right' operation.
            tbl.set("right", right)?;
            /// Performs the 'direction' operation.
            tbl.set("direction", direction)?;
            Ok(tbl)
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.isVibrationSupported --
    /// Returns whether a gamepad supports vibration requests.
    /// @param | id | integer | Gamepad id.
    /// @return | boolean | True when vibration is supported.
    gamepad.set(
        "isVibrationSupported",
        lua.create_function(move |_, id: usize| {
            Ok(s.borrow()
                .gamepads
                .get(id)
                .is_some_and(|gp| gp.is_vibration_supported()))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.vibrate --
    /// Requests gamepad vibration with low and high frequency motor strengths.
    /// @param | id | integer | Gamepad id.
    /// @param | low_freq | number | Low-frequency motor strength clamped to 0.0 through 1.0.
    /// @param | high_freq | number | High-frequency motor strength clamped to 0.0 through 1.0.
    /// @param | duration_ms | number | Duration in milliseconds.
    /// @return | boolean | True when the gamepad supports vibration and the request was queued.
    gamepad.set(
        "vibrate",
        lua.create_function(
            move |_, (id, low_freq, high_freq, duration_ms): (usize, f32, f32, f32)| {
                let mut st = s.borrow_mut();
                let low_freq = low_freq.clamp(0.0, 1.0);
                let high_freq = high_freq.clamp(0.0, 1.0);
                let duration_ms = duration_ms.max(0.0).round() as u32;
                let supported = st
                    .gamepads
                    .get(id)
                    .is_some_and(|gp| gp.is_vibration_supported());
                if supported {
                    st.gamepad_vibration_requests
                        .push(crate::input::GamepadVibrationRequest {
                            id,
                            low_freq,
                            high_freq,
                            duration_ms,
                        });
                }
                Ok(supported)
            },
        )?,
    )?;
    let s = state.clone();
    // -- gamepad.getGUID --
    /// Returns the GUID string for a gamepad.
    /// @param | id | integer | Gamepad id.
    /// @return | string | GUID string, or an empty string when missing.
    gamepad.set(
        "getGUID",
        lua.create_function(move |_, id: usize| {
            let st = s.borrow();
            Ok(st
                .gamepads
                .get(id)
                .map_or_else(String::new, |gp| gp.get_guid().to_string()))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getHat --
    /// Returns hat direction for a gamepad hat index.
    /// @param | id | integer | Gamepad id.
    /// @param | hat | integer | Hat index.
    /// @return | string | Hat direction string, or `c` when centered or missing.
    gamepad.set(
        "getHat",
        lua.create_function(move |_, (id, hat): (usize, u32)| {
            let st = s.borrow();
            Ok(st
                .gamepads
                .get(id)
                .map_or_else(|| "c".to_string(), |gp| gp.get_hat(hat).to_string()))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.setVibration --
    /// Requests gamepad vibration with low and high frequency motor strengths.
    /// @param | id | integer | Gamepad id.
    /// @param | low_freq | number | Low-frequency motor strength clamped to 0.0 through 1.0.
    /// @param | high_freq | number | High-frequency motor strength clamped to 0.0 through 1.0.
    /// @param | duration_ms | number | Duration in milliseconds.
    /// @return | boolean | True when the gamepad supports vibration and the request was queued.
    gamepad.set(
        "setVibration",
        lua.create_function(
            move |_, (id, low_freq, high_freq, duration_ms): (usize, f32, f32, f32)| {
                let mut st = s.borrow_mut();
                let low_freq = low_freq.clamp(0.0, 1.0);
                let high_freq = high_freq.clamp(0.0, 1.0);
                let duration_ms = duration_ms.max(0.0).round() as u32;
                let supported = st
                    .gamepads
                    .get(id)
                    .is_some_and(|gp| gp.is_vibration_supported());
                if supported {
                    st.gamepad_vibration_requests
                        .push(crate::input::GamepadVibrationRequest {
                            id,
                            low_freq,
                            high_freq,
                            duration_ms,
                        });
                }
                Ok(supported)
            },
        )?,
    )?;
    let s = state.clone();
    // -- gamepad.wasPressed --
    /// Returns whether a gamepad button was pressed this frame.
    /// @param | id | integer | Gamepad id.
    /// @param | button | integer | Button index.
    /// @return | boolean | True when the button was pressed.
    gamepad.set(
        "wasPressed",
        lua.create_function(move |_, (id, button): (usize, u32)| {
            Ok(s.borrow()
                .gamepads
                .get(id)
                .is_some_and(|gp| gp.was_button_pressed(button)))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.wasReleased --
    /// Returns whether a gamepad button was released this frame.
    /// @param | id | integer | Gamepad id.
    /// @param | button | integer | Button index.
    /// @return | boolean | True when the button was released.
    gamepad.set(
        "wasReleased",
        lua.create_function(move |_, (id, button): (usize, u32)| {
            Ok(s.borrow()
                .gamepads
                .get(id)
                .is_some_and(|gp| gp.was_button_released(button)))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.wasConnected --
    /// Returns whether a gamepad connected this frame.
    /// @param | id | integer | Gamepad id.
    /// @return | boolean | True when the gamepad connected this frame.
    gamepad.set(
        "wasConnected",
        lua.create_function(move |_, id: usize| {
            Ok(s.borrow()
                .gamepads
                .get(id)
                .is_some_and(|gp| gp.was_connected_this_frame()))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.wasDisconnected --
    /// Returns whether a gamepad disconnected this frame.
    /// @param | id | integer | Gamepad id.
    /// @return | boolean | True when the gamepad disconnected this frame.
    gamepad.set(
        "wasDisconnected",
        lua.create_function(move |_, id: usize| {
            Ok(s.borrow()
                .gamepads
                .get(id)
                .is_some_and(|gp| gp.was_disconnected_this_frame()))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.setBackgroundEvents --
    /// Enables or disables background gamepad event processing.
    /// @param | enable | boolean | New background event flag.
    gamepad.set(
        "setBackgroundEvents",
        lua.create_function(move |_, enable: bool| {
            s.borrow_mut().gamepad_background_events = enable;
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getBackgroundEvents --
    /// Returns whether background gamepad event processing is enabled.
    /// @return | boolean | True when background events are enabled.
    gamepad.set(
        "getBackgroundEvents",
        lua.create_function(move |_, ()| Ok(s.borrow().gamepad_background_events))?,
    )?;
    let s = state.clone();
    // -- gamepad.setGamepadMapping --
    /// Stores a controller mapping string for a gamepad GUID.
    /// @param | guid | string | Gamepad GUID.
    /// @param | mapping | string | Mapping string.
    gamepad.set(
        "setGamepadMapping",
        lua.create_function(move |_, (guid, mapping): (String, String)| {
            s.borrow_mut()
                .gamepad_mappings
                .set_mapping(&guid, &mapping)
                .map_err(|e| {
                    LuaError::RuntimeError(format!("input.gamepad.setGamepadMapping: {e}"))
                })?;
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.getGamepadMappingString --
    /// Returns a stored mapping string for a gamepad GUID.
    /// @param | guid | string | Gamepad GUID.
    /// @return | string | Mapping string, or nil when no mapping exists.
    gamepad.set(
        "getGamepadMappingString",
        lua.create_function(move |_, guid: String| {
            Ok(s.borrow()
                .gamepad_mappings
                .get_mapping_string(&guid)
                .map(|m| m.to_string()))
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.loadGamepadMappings --
    /// Loads gamepad mapping strings from a file.
    /// @param | path | string | Mapping file path.
    gamepad.set(
        "loadGamepadMappings",
        lua.create_function(move |_, path: String| {
            let fs = s.borrow().fs.clone();
            s.borrow_mut()
                .gamepad_mappings
                .load_from_game_fs(&fs, &path)
                .map_err(LuaError::external)
        })?,
    )?;
    let s = state.clone();
    // -- gamepad.saveGamepadMappings --
    /// Saves gamepad mapping strings to a file.
    /// @param | path | string | Mapping file path.
    gamepad.set(
        "saveGamepadMappings",
        lua.create_function(move |_, path: String| {
            let st = s.borrow();
            st.gamepad_mappings
                .save_to_game_fs(&st.fs, &path)
                .map_err(LuaError::external)?;
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- assignPlayer --
    /// Assigns a gamepad slot to a positive player number.
    /// @param | player | integer | One-based player number.
    /// @param | gamepad_id | integer | Gamepad slot id.
    input_tbl.set(
        "assignPlayer",
        lua.create_function(move |_, (player, gamepad_id): (u32, usize)| {
            if player == 0 {
                return Err(LuaError::RuntimeError(
                    "input.assignPlayer: player must be at least 1".to_string(),
                ));
            }
            let mut st = s.borrow_mut();
            st.gamepad_players.retain(|_, id| *id != gamepad_id);
            st.gamepad_players.insert(player, gamepad_id);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getPlayerGamepad --
    /// Returns the gamepad assigned to a player, or nil.
    /// @param | player | integer | One-based player number.
    /// @return | integer | Assigned gamepad slot, or nil.
    input_tbl.set(
        "getPlayerGamepad",
        lua.create_function(move |_, player: u32| {
            Ok(s.borrow().gamepad_players.get(&player).copied())
        })?,
    )?;
    /// Performs the 'gamepad' operation.
    input_tbl.set("gamepad", gamepad)?;
    let touch = lua.create_table()?;
    let s = state.clone();
    // -- touch.getTouches --
    /// Returns active touch points with id, position, and pressure.
    /// @return | table | Array table of touch records.
    /// @field | id | integer | Touch point id.
    /// @field | x | number | Touch x position.
    /// @field | y | number | Touch y position.
    /// @field | pressure | number | Touch pressure.
    touch.set(
        "getTouches",
        lua.create_function(move |lua, ()| {
            let st = s.borrow();
            let touches = st.touch.get_touches();
            let tbl = lua.create_table()?;
            for (i, tp) in touches.iter().enumerate() {
                let entry = lua.create_table()?;
                /// The 'id' field value exposed to Lua scripts.
                entry.set("id", tp.id)?;
                /// The 'x' field value exposed to Lua scripts.
                entry.set("x", tp.x)?;
                /// The 'y' field value exposed to Lua scripts.
                entry.set("y", tp.y)?;
                /// Performs the 'pressure' operation.
                entry.set("pressure", tp.pressure)?;
                tbl.set(i + 1, entry)?;
            }
            Ok(tbl)
        })?,
    )?;
    let s = state.clone();
    // -- touch.getPosition --
    /// Returns the position of a touch point by id.
    /// @param | id | integer | Touch id.
    /// @return | number | Touch x coordinate, or 0 when missing.
    /// @return | number | Touch y coordinate, or 0 when missing.
    touch.set(
        "getPosition",
        lua.create_function(move |_, id: u64| {
            let st = s.borrow();
            let (x, y) = st.touch.get_touch(id).map_or((0.0, 0.0), |tp| (tp.x, tp.y));
            Ok((x, y))
        })?,
    )?;
    let s = state.clone();
    // -- touch.getPressure --
    /// Returns pressure for a touch point by its id.
    /// @param | id | integer | Touch id.
    /// @return | number | Touch pressure, or 0 when missing.
    touch.set(
        "getPressure",
        lua.create_function(move |_, id: u64| {
            Ok(s.borrow().touch.get_touch(id).map_or(0.0, |tp| tp.pressure))
        })?,
    )?;
    let s = state.clone();
    // -- touch.getTouchCount --
    /// Returns the current active touch count.
    /// @return | integer | Active touch count.
    touch.set(
        "getTouchCount",
        lua.create_function(move |_, ()| Ok(s.borrow().touch.get_touch_count()))?,
    )?;
    let s = state.clone();
    // -- touch.wasPressed --
    /// Returns whether a touch id began this frame.
    /// @param | id | integer | Touch id.
    /// @return | boolean | True when the touch was pressed.
    touch.set(
        "wasPressed",
        lua.create_function(move |_, id: u64| Ok(s.borrow().touch.was_pressed(id)))?,
    )?;
    let s = state.clone();
    // -- touch.wasReleased --
    /// Returns whether a touch id ended this frame.
    /// @param | id | integer | Touch id.
    /// @return | boolean | True when the touch was released.
    touch.set(
        "wasReleased",
        lua.create_function(move |_, id: u64| Ok(s.borrow().touch.was_released(id)))?,
    )?;
    /// Performs the 'touch' operation.
    input_tbl.set("touch", touch)?;
    let action_map: Rc<RefCell<HashMap<String, ActionDef>>> = Rc::new(RefCell::new(HashMap::new()));
    let action_contexts: Rc<RefCell<HashMap<String, bool>>> = Rc::new(RefCell::new(
        [("gameplay".to_string(), true), ("global".to_string(), true)]
            .into_iter()
            .collect(),
    ));
    let rebind_callbacks: Rc<RefCell<Vec<LuaRegistryKey>>> = Rc::new(RefCell::new(Vec::new()));
    let last_pressed_frame: Rc<RefCell<HashMap<String, u64>>> =
        Rc::new(RefCell::new(HashMap::new()));
    let contexts = action_contexts.clone();
    // -- setContextEnabled --
    /// Enables or disables an action input context.
    /// @param | name | string | Context name.
    /// @param | enabled | boolean | Whether actions in the context can be queried.
    input_tbl.set(
        "setContextEnabled",
        lua.create_function(move |_, (name, enabled): (String, bool)| {
            contexts.borrow_mut().insert(name, enabled);
            Ok(())
        })?,
    )?;
    let contexts = action_contexts.clone();
    // -- isContextEnabled --
    /// Returns whether an action input context is enabled.
    /// @param | name | string | Context name.
    /// @return | boolean | True when the context is enabled or has no explicit override.
    input_tbl.set(
        "isContextEnabled",
        lua.create_function(move |_, name: String| {
            Ok(contexts.borrow().get(&name).copied().unwrap_or(true))
        })?,
    )?;
    let am = action_map.clone();
    let rbc = rebind_callbacks.clone();
    // -- bind --
    /// Adds one or more keyboard/gamepad bindings to an action.
    /// @param | action | string | Action name.
    /// @param | keys | any | Binding string or array table of binding strings.
    input_tbl.set(
        "bind",
        lua.create_function(move |lua, (action, keys): (String, LuaValue)| {
            let parsed = parse_binding_list("bind", keys)?;
            {
                let mut map = am.borrow_mut();
                let entry = map.entry(action.clone()).or_default();
                for binding in parsed {
                    if !entry.bindings.contains(&binding) {
                        entry.bindings.push(binding);
                    }
                }
            }
            let new_keys = am
                .borrow()
                .get(&action)
                .map(|d| d.bindings.clone())
                .unwrap_or_default();
            let n = rbc.borrow().len();
            for i in 0..n {
                let cb = {
                    let cbs = rbc.borrow();
                    cbs.get(i)
                        .and_then(|k| lua.registry_value::<LuaFunction>(k).ok())
                };
                if let Some(cb) = cb {
                    let kt = lua.create_table()?;
                    for (j, k) in new_keys.iter().enumerate() {
                        kt.set(j + 1, k.clone())?;
                    }
                    cb.call::<_, ()>((action.clone(), kt))?;
                }
            }
            Ok(())
        })?,
    )?;
    let am = action_map.clone();
    let s = state.clone();
    // -- newMapping --
    /// Creates an action mapping table with isDown, wasPressed, and wasReleased helper functions.
    /// @param | name | string | Action name.
    /// @param | keys | any | Binding string or array table of binding strings.
    /// @return | table | Mapping table with action query closures.
    /// @field | isDown | function | Returns true while the action is held.
    /// @field | wasPressed | function | Returns true on the frame the action was pressed.
    /// @field | wasReleased | function | Returns true on the frame the action was released.
    input_tbl.set(
        "newMapping",
        lua.create_function(move |lua, (name, keys): (String, LuaValue)| {
            let parsed = parse_binding_list("newMapping", keys)?;
            {
                let mut map = am.borrow_mut();
                let entry = map.entry(name.clone()).or_default();
                for binding in parsed {
                    if !entry.bindings.contains(&binding) {
                        entry.bindings.push(binding);
                    }
                }
            }
            let mapping = lua.create_table()?;
            /// Performs the 'name' operation.
            mapping.set("name", name.clone())?;
            let action = name.clone();
            /// Returns whether any bound key for this mapping is currently down.
            /// @return | boolean | True when any bound key is down.
            let am_is_down = am.clone();
            let s_is_down = s.clone();
            mapping.set(
                "isDown",
                lua.create_function(move |_, ()| {
                    let map = am_is_down.borrow();
                    if let Some(def) = map.get(&action) {
                        let st = s_is_down.borrow();
                        return Ok(def.bindings.iter().any(|k| binding_is_down(&st, k)));
                    }
                    Ok(false)
                })?,
            )?;
            let action = name.clone();
            /// Returns whether any bound key for this mapping was pressed this frame.
            /// @return | boolean | True when any bound key was pressed.
            let am_pressed = am.clone();
            let s_pressed = s.clone();
            mapping.set(
                "wasPressed",
                lua.create_function(move |_, ()| {
                    let map = am_pressed.borrow();
                    if let Some(def) = map.get(&action) {
                        let st = s_pressed.borrow();
                        return Ok(def.bindings.iter().any(|k| binding_was_pressed(&st, k)));
                    }
                    Ok(false)
                })?,
            )?;
            let action = name.clone();
            /// Returns whether any bound key for this mapping was released this frame.
            /// @return | boolean | True when any bound key was released.
            let am_released = am.clone();
            let s_released = s.clone();
            mapping.set(
                "wasReleased",
                lua.create_function(move |_, ()| {
                    let map = am_released.borrow();
                    if let Some(def) = map.get(&action) {
                        let st = s_released.borrow();
                        return Ok(def.bindings.iter().any(|k| binding_was_released(&st, k)));
                    }
                    Ok(false)
                })?,
            )?;
            Ok(mapping)
        })?,
    )?;
    let am = action_map.clone();
    let rbc = rebind_callbacks.clone();
    // -- unbind --
    /// Removes all bindings for an action.
    /// @param | action | string | Action name.
    /// @return | boolean | True when the action had bindings.
    input_tbl.set(
        "unbind",
        lua.create_function(move |lua, action: String| {
            let removed = am.borrow_mut().remove(&action).is_some();
            if removed {
                let n = rbc.borrow().len();
                for i in 0..n {
                    let cb = {
                        let cbs = rbc.borrow();
                        cbs.get(i)
                            .and_then(|k| lua.registry_value::<LuaFunction>(k).ok())
                    };
                    if let Some(cb) = cb {
                        let kt = lua.create_table()?;
                        cb.call::<_, ()>((action.clone(), kt))?;
                    }
                }
            }
            Ok(removed)
        })?,
    )?;
    let am = action_map.clone();
    // -- clearBindings --
    /// Removes all action bindings from the map.
    input_tbl.set(
        "clearBindings",
        lua.create_function(move |_, ()| {
            am.borrow_mut().clear();
            Ok(())
        })?,
    )?;
    let am = action_map.clone();
    // -- getBindings --
    /// Returns all registered action bindings.
    /// @return | string[] | Map table from action names to arrays of binding strings.
    input_tbl.set(
        "getBindings",
        lua.create_function(move |lua, ()| {
            let map = am.borrow();
            let out = lua.create_table()?;
            for (action, def) in map.iter() {
                let kt = lua.create_table()?;
                for (i, k) in def.bindings.iter().enumerate() {
                    kt.set(i + 1, k.clone())?;
                }
                out.set(action.clone(), kt)?;
            }
            Ok(out)
        })?,
    )?;
    let am = action_map.clone();
    let s = state.clone();
    let contexts = action_contexts.clone();
    // -- isActionDown --
    /// Returns whether any binding for an action is currently down.
    /// @param | action | string | Action name.
    /// @return | boolean | True when any binding is down.
    input_tbl.set(
        "isActionDown",
        lua.create_function(move |_, action: String| {
            let map = am.borrow();
            if let Some(def) = map.get(&action) {
                if !action_context_enabled(&contexts.borrow(), def) {
                    return Ok(false);
                }
                let st = s.borrow();
                return Ok(def.bindings.iter().any(|k| binding_is_down(&st, k)));
            }
            Ok(false)
        })?,
    )?;
    let am = action_map.clone();
    let lpf = last_pressed_frame.clone();
    let s = state.clone();
    let contexts = action_contexts.clone();
    // -- wasActionPressed --
    /// Returns whether any binding for an action was pressed this frame and records the frame.
    /// @param | action | string | Action name.
    /// @return | boolean | True when any binding was pressed this frame.
    input_tbl.set(
        "wasActionPressed",
        lua.create_function(move |_, action: String| {
            let map = am.borrow();
            if let Some(def) = map.get(&action) {
                if !action_context_enabled(&contexts.borrow(), def) {
                    return Ok(false);
                }
                let st = s.borrow();
                let was_pressed = def.bindings.iter().any(|k| binding_was_pressed(&st, k));
                if was_pressed {
                    let frame = st.clock.frame_count();
                    lpf.borrow_mut().insert(action, frame);
                    return Ok(true);
                }
            }
            Ok(false)
        })?,
    )?;
    let am = action_map.clone();
    let s = state.clone();
    let contexts = action_contexts.clone();
    // -- wasActionReleased --
    /// Returns whether any binding for an action was released this frame.
    /// @param | action | string | Action name.
    /// @return | boolean | True when any binding was released this frame.
    input_tbl.set(
        "wasActionReleased",
        lua.create_function(move |_, action: String| {
            let map = am.borrow();
            if let Some(def) = map.get(&action) {
                if !action_context_enabled(&contexts.borrow(), def) {
                    return Ok(false);
                }
                let st = s.borrow();
                return Ok(def.bindings.iter().any(|k| binding_was_released(&st, k)));
            }
            Ok(false)
        })?,
    )?;
    let _lpf = last_pressed_frame;
    let s = state.clone();
    let am = action_map.clone();
    let contexts = action_contexts.clone();
    // -- wasActionPressedWithin --
    /// Returns whether an action was pressed within a recent frame window.
    /// @param | action | string | Action name.
    /// @param | frames | integer | Number of frames allowed since the last press.
    /// @return | boolean | True when the action was pressed within the window.
    input_tbl.set(
        "wasActionPressedWithin",
        lua.create_function(move |_, (action, frames): (String, u64)| {
            let st = s.borrow();
            if let Some(def) = am.borrow().get(&action) {
                if !action_context_enabled(&contexts.borrow(), def) {
                    return Ok(false);
                }
                return Ok(action_was_pressed_within_history(&st, def, frames));
            }
            Ok(false)
        })?,
    )?;
    let am = action_map.clone();
    let rbc = rebind_callbacks.clone();
    // -- define --
    /// Defines an action with a full set of bindings and an optional category, replacing any prior definition.
    /// @param | name | string | Action name.
    /// @param | bindings | any | Binding string or array of binding strings.
    /// @param | category | string? | Category label for grouping (default empty string).
    input_tbl.set(
        "define",
        lua.create_function(
            move |lua,
                  (name, keys, cat, context): (
                String,
                LuaValue,
                Option<String>,
                Option<String>,
            )| {
                let category = cat.unwrap_or_default();
                let context = context.unwrap_or_else(|| "gameplay".to_string());
                let parsed = parse_binding_list("define", keys)?;
                {
                    let mut map = am.borrow_mut();
                    let def = ActionDef::new(parsed, category, context)
                        .map_err(|e| LuaError::RuntimeError(format!("input.define: {e}")))?;
                    map.insert(name.clone(), def);
                }
                let new_keys = am
                    .borrow()
                    .get(&name)
                    .map(|d| d.bindings.clone())
                    .unwrap_or_default();
                let n = rbc.borrow().len();
                for i in 0..n {
                    let cb = {
                        let cbs = rbc.borrow();
                        cbs.get(i)
                            .and_then(|k| lua.registry_value::<LuaFunction>(k).ok())
                    };
                    if let Some(cb) = cb {
                        let kt = lua.create_table()?;
                        for (j, k) in new_keys.iter().enumerate() {
                            kt.set(j + 1, k.clone())?;
                        }
                        cb.call::<_, ()>((name.clone(), kt))?;
                    }
                }
                Ok(())
            },
        )?,
    )?;
    let am = action_map.clone();
    let rbc = rebind_callbacks.clone();
    // -- defineActions --
    /// Defines multiple named actions at once, replacing prior definitions.
    /// @param | defs | table | Map of action name to binding array or { bindings = {...}, category? }.
    /// @param | defaultCategory? | string | Category used when an action definition omits `category`.
    /// @return | integer | Number of actions defined.
    input_tbl.set(
        "defineActions",
        lua.create_function(
            move |lua, (defs, default_category): (LuaTable, Option<String>)| {
                let default_category = default_category.unwrap_or_default();
                let mut updates: Vec<(String, Vec<String>, String, String)> = Vec::new();
                for pair in defs.pairs::<String, LuaValue>() {
                    let (name, value) = pair?;
                    let (bindings_value, category, context) = match value {
                        LuaValue::Table(tbl) => match tbl.get::<_, Option<LuaValue>>("bindings")? {
                            Some(bindings) => (
                                bindings,
                                tbl.get::<_, Option<String>>("category")?
                                    .unwrap_or_else(|| default_category.clone()),
                                tbl.get::<_, Option<String>>("context")?
                                    .unwrap_or_else(|| "gameplay".to_string()),
                            ),
                            None => (
                                LuaValue::Table(tbl),
                                default_category.clone(),
                                "gameplay".to_string(),
                            ),
                        },
                        other => (other, default_category.clone(), "gameplay".to_string()),
                    };
                    let parsed = parse_binding_list("defineActions", bindings_value)?;
                    updates.push((name, parsed, category, context));
                }
                let count = updates.len();
                {
                    let mut map = am.borrow_mut();
                    for (name, bindings, category, context) in &updates {
                        let def =
                            ActionDef::new(bindings.clone(), category.clone(), context.clone())
                                .map_err(|e| {
                                    LuaError::RuntimeError(format!("input.defineActions: {e}"))
                                })?;
                        map.insert(name.clone(), def);
                    }
                }
                for (name, _, _, _) in &updates {
                    let new_keys = am
                        .borrow()
                        .get(name)
                        .map(|d| d.bindings.clone())
                        .unwrap_or_default();
                    let n = rbc.borrow().len();
                    for i in 0..n {
                        let cb = {
                            let cbs = rbc.borrow();
                            cbs.get(i)
                                .and_then(|k| lua.registry_value::<LuaFunction>(k).ok())
                        };
                        if let Some(cb) = cb {
                            let kt = lua.create_table()?;
                            for (j, k) in new_keys.iter().enumerate() {
                                kt.set(j + 1, k.clone())?;
                            }
                            cb.call::<_, ()>((name.clone(), kt))?;
                        }
                    }
                }
                Ok(count)
            },
        )?,
    )?;
    let am = action_map.clone();
    let s = state.clone();
    let contexts = action_contexts.clone();
    // -- getAxis --
    /// Returns -1.0, 0.0, or +1.0 for a named action; first binding is positive, second is negative.
    /// @param | name | string | Action name.
    /// @return | number | Axis value: +1.0, -1.0, or 0.0.
    input_tbl.set(
        "getAxis",
        lua.create_function(move |_, name: String| {
            let map = am.borrow();
            let st = s.borrow();
            Ok(compute_axis(&map, &contexts.borrow(), &st, &name))
        })?,
    )?;
    let am = action_map.clone();
    let s = state.clone();
    let contexts = action_contexts.clone();
    // -- getVector --
    /// Returns a 2D axis vector from two named actions.
    /// @param | hname | string | Horizontal action name (positive = right).
    /// @param | vname | string | Vertical action name (positive = down).
    /// @return | number | Horizontal axis value.
    /// @return | number | Vertical axis value.
    input_tbl.set(
        "getVector",
        lua.create_function(move |_, (hname, vname): (String, String)| {
            let map = am.borrow();
            let st = s.borrow();
            let h = compute_axis(&map, &contexts.borrow(), &st, &hname);
            let v = compute_axis(&map, &contexts.borrow(), &st, &vname);
            Ok((h, v))
        })?,
    )?;
    let am = action_map.clone();
    // -- reset --
    /// Removes bindings for one action by name, or all actions when name is nil.
    /// @param | name | string? | Action name. When nil, all actions are removed.
    input_tbl.set(
        "reset",
        lua.create_function(move |_, name: Option<String>| {
            match name {
                Some(action) => {
                    am.borrow_mut().remove(&action);
                }
                None => {
                    am.borrow_mut().clear();
                }
            }
            Ok(())
        })?,
    )?;
    let am = action_map.clone();
    // -- getConflicts --
    /// Returns a table mapping each binding key to the action names that share it; only keys with two or more actions are included.
    /// @return | table | Map of binding string to array of conflicting action names.
    input_tbl.set(
        "getConflicts",
        lua.create_function(move |lua, ()| {
            let map = am.borrow();
            let mut key_to_actions: HashMap<String, Vec<String>> = HashMap::new();
            for (action, def) in map.iter() {
                for binding in &def.bindings {
                    key_to_actions
                        .entry(binding.clone())
                        .or_default()
                        .push(action.clone());
                }
            }
            let out = lua.create_table()?;
            for (binding, actions) in &key_to_actions {
                if actions.len() >= 2 {
                    let at = lua.create_table()?;
                    for (i, a) in actions.iter().enumerate() {
                        at.set(i + 1, a.clone())?;
                    }
                    out.set(binding.clone(), at)?;
                }
            }
            Ok(out)
        })?,
    )?;
    let am = action_map.clone();
    // -- serializeBindings --
    /// Serialises all action definitions to a JSON string.
    /// @return | string | JSON representation of all action definitions.
    input_tbl.set(
        "serializeBindings",
        lua.create_function(move |_, ()| {
            let map = am.borrow();
            serde_json::to_string(&BindingMapEnvelope {
                schema_version: 2,
                actions: map.clone(),
            })
            .map_err(|e| LuaError::RuntimeError(e.to_string()))
        })?,
    )?;
    let am = action_map.clone();
    let rbc = rebind_callbacks.clone();
    // -- deserializeBindings --
    /// Loads action definitions from a JSON string produced by serializeBindings, replacing all current definitions.
    /// @param | json | string | JSON string with action definitions.
    /// @return | boolean | True on success.
    input_tbl.set(
        "deserializeBindings",
        lua.create_function(move |lua, json: String| {
            let raw_map = decode_binding_map(&json)
                .map_err(|e| LuaError::RuntimeError(format!("input.deserializeBindings: {e}")))?;
            let mut new_map = HashMap::with_capacity(raw_map.len());
            for (action, def) in raw_map {
                let canonical = def.canonicalize().map_err(|e| {
                    LuaError::RuntimeError(format!(
                        "input.deserializeBindings: action '{action}': {e}"
                    ))
                })?;
                new_map.insert(action, canonical);
            }
            let actions: Vec<String> = new_map.keys().cloned().collect();
            {
                let mut map = am.borrow_mut();
                *map = new_map;
            }
            let n = rbc.borrow().len();
            for action in &actions {
                let new_keys = am
                    .borrow()
                    .get(action)
                    .map(|d| d.bindings.clone())
                    .unwrap_or_default();
                for i in 0..n {
                    let cb = {
                        let cbs = rbc.borrow();
                        cbs.get(i)
                            .and_then(|k| lua.registry_value::<LuaFunction>(k).ok())
                    };
                    if let Some(cb) = cb {
                        let kt = lua.create_table()?;
                        for (j, k) in new_keys.iter().enumerate() {
                            kt.set(j + 1, k.clone())?;
                        }
                        cb.call::<_, ()>((action.clone(), kt))?;
                    }
                }
            }
            Ok(true)
        })?,
    )?;
    let am = action_map.clone();
    // -- getByCategory --
    /// Returns action names belonging to the given category.
    /// @param | category | string | Category label.
    /// @return | string[] | Array of matching action names.
    input_tbl.set(
        "getByCategory",
        lua.create_function(move |lua, cat: String| {
            let map = am.borrow();
            let tbl = lua.create_table()?;
            let mut i = 1usize;
            for (name, def) in map.iter() {
                if def.category == cat {
                    tbl.set(i, name.clone())?;
                    i += 1;
                }
            }
            Ok(tbl)
        })?,
    )?;
    let rbc = rebind_callbacks.clone();
    // -- onRebind --
    /// Registers a callback invoked whenever bindings change via bind, unbind, define, or deserializeBindings.
    /// @param | callback | function | function(action_name, new_keys) called on any change.
    input_tbl.set(
        "onRebind",
        lua.create_function(move |lua, cb: LuaFunction| {
            let key = lua.create_registry_value(cb)?;
            rbc.borrow_mut().push(key);
            Ok(())
        })?,
    )?;
    // -- newCombo --
    /// Creates a combo detector from string steps or step tables with optional timing.
    /// @param | steps | table | Array table of key strings or `{key, gap}` step tables.
    /// @param | opts | table? | Options table with `total_gap` in milliseconds.
    /// @return | LCombo | New combo detector handle.
    let combo_state = state.clone();
    input_tbl.set(
        "newCombo",
        lua.create_function(move |_lua, (steps_val, opts): (LuaTable, Option<LuaTable>)| {
            let total_gap_ms: u64 = opts
                .as_ref()
                .and_then(|t| t.get::<_, Option<u64>>("total_ms").ok().flatten()
                    .or_else(|| t.get::<_, Option<u64>>("total_gap").ok().flatten()))
                .unwrap_or(2000);
            let mut steps: Vec<ComboStep> = Vec::new();
            let mut auto_steps: Vec<AutoComboStep> = Vec::new();
            let mut has_rich_steps = false;
            for pair in steps_val.sequence_values::<LuaValue>() {
                let val = pair?;
                match val {
                    LuaValue::String(s) => {
                        let key = s
                            .to_str()
                            .map_err(|e| LuaError::RuntimeError(e.to_string()))?
                            .to_string();
                        steps.push(ComboStep {
                            key: key.clone(),
                            max_gap_ms: 500,
                        });
                        auto_steps.push(AutoComboStep::Press(key, 500));
                    }
                    LuaValue::Table(t) => {
                        let gap: u64 = t.get::<_, Option<u64>>("leniency_ms")?
                            .or(t.get::<_, Option<u64>>("gap")?)
                            .unwrap_or(500);
                        let (key, auto_step) = if let Some(key) = t.get::<_, Option<String>>("press")? {
                            has_rich_steps = true;
                            (key.clone(), AutoComboStep::Press(key, gap))
                        } else if let Some(key) = t.get::<_, Option<String>>("release")? {
                            has_rich_steps = true;
                            (key.clone(), AutoComboStep::Release(key, gap))
                        } else if let Some(direction) = t.get::<_, Option<String>>("direction")? {
                            has_rich_steps = true;
                            (direction.clone(), AutoComboStep::Direction(direction, gap))
                        } else if let Some(hold) = t.get::<_, Option<String>>("hold")? {
                            has_rich_steps = true;
                            let min_hold_ms = t.get::<_, Option<u64>>("min_hold_ms")?.unwrap_or(1);
                            (hold.clone(), AutoComboStep::Hold(hold, min_hold_ms, gap))
                        } else if t.get::<_, Option<bool>>("neutral")?.unwrap_or(false) {
                            has_rich_steps = true;
                            ("neutral".to_string(), AutoComboStep::Neutral(gap))
                        } else if let Some(chord) = t.get::<_, Option<LuaTable>>("chord")? {
                            has_rich_steps = true;
                            let controls = chord.sequence_values::<String>().collect::<LuaResult<Vec<_>>>()?;
                            if controls.len() < 2 {
                                return Err(LuaError::RuntimeError("input.newCombo: chord requires at least two controls".into()));
                            }
                            let within = t.get::<_, Option<u64>>("within_ms")?.unwrap_or(50);
                            (controls.join("+"), AutoComboStep::Chord(controls, within, gap))
                        } else if let Some(key) = t.get::<_, Option<String>>("key")? {
                            (key.clone(), AutoComboStep::Press(key, gap))
                        } else {
                            return Err(LuaError::RuntimeError("input.newCombo: each step requires press, release, direction, hold, neutral, chord, or key".into()));
                        };
                        steps.push(ComboStep {
                            key,
                            max_gap_ms: gap,
                        });
                        auto_steps.push(auto_step);
                    }
                    _ => {
                        return Err(LuaError::RuntimeError(
                            "input.newCombo: steps must be strings or tables".into(),
                        ))
                    }
                }
            }
            if steps.is_empty() {
                return Err(LuaError::RuntimeError(
                    "input.newCombo: steps table must not be empty".into(),
                ));
            }
            Ok(LuaCombo {
                detector: ComboDetector::new(steps, total_gap_ms),
                total_elapsed_ms: 0,
                history_seen: combo_state.borrow().input_history.snapshot().len(),
                last_input_time_ms: combo_state
                    .borrow()
                    .input_history
                    .snapshot()
                    .last()
                    .map_or(0, |event| event.time_ms),
                state: combo_state.clone(),
                manual: opts
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<bool>>("manual").ok().flatten())
                    .unwrap_or(!has_rich_steps),
                completed_at_ms: None,
                consumed: false,
                auto_steps,
                auto_progress: 0,
                auto_started_at_ms: None,
                auto_last_step_at_ms: None,
                held_since: HashMap::new(),
                recent_presses: HashMap::new(),
                directions: std::collections::HashSet::new(),
                direction_axes: (0.0, 0.0),
                source_player: opts
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<String>>("source").ok().flatten())
                    .and_then(|source| source.strip_prefix("player").or_else(|| source.strip_prefix('p')).and_then(|n| n.parse().ok())),
                input_buffer_ms: opts
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<u64>>("input_buffer_ms").ok().flatten())
                    .unwrap_or(0),
            })
        })?,
    )?;
    let rec_state = state.clone();
    let rc = rec_state.clone();
    // -- startRecording --
    /// Starts recording input events into the module recorder.
    input_tbl.set(
        "startRecording",
        lua.create_function(move |_, ()| {
            rc.borrow_mut().input_recorder.start_recording();
            Ok(())
        })?,
    )?;
    let rc = rec_state.clone();
    // -- stopRecording --
    /// Stops input recording and returns the captured recording when one is active.
    /// @return | LInputRecording | Recording handle, or nil when recording was not active.
    input_tbl.set(
        "stopRecording",
        lua.create_function(move |lua, ()| {
            match rc.borrow_mut().input_recorder.stop_recording() {
                Some(rec) => Ok(LuaValue::UserData(
                    lua.create_userdata(LuaInputRecording { inner: rec })?,
                )),
                None => Ok(LuaValue::Nil),
            }
        })?,
    )?;
    let rc = rec_state.clone();
    // -- loadRecording --
    /// Loads recording JSON into the module recorder.
    /// @param | json | string | Recording JSON.
    input_tbl.set(
        "loadRecording",
        lua.create_function(move |_, json: String| {
            let rec = crate::input::recorder::InputRecording::from_json(&json)
                .map_err(LuaError::RuntimeError)?;
            rc.borrow_mut().input_recorder.load(rec);
            Ok(())
        })?,
    )?;
    let rc = rec_state.clone();
    // -- startPlayback --
    /// Starts playback of the loaded recording. `opts.mode` may be `frame`, `fixed`, or `realtime`.
    input_tbl.set(
        "startPlayback",
        lua.create_function(move |_, opts: Option<LuaTable>| {
            let mode = opts
                .as_ref()
                .and_then(|table| table.get::<_, Option<String>>("mode").ok().flatten())
                .unwrap_or_else(|| "frame".to_string());
            let mode = match mode.as_str() {
                "frame" => crate::input::recorder::PlaybackMode::Frame,
                "fixed" => crate::input::recorder::PlaybackMode::Fixed,
                "realtime" => crate::input::recorder::PlaybackMode::Realtime,
                _ => {
                    return Err(LuaError::RuntimeError(
                        "input.startPlayback: mode must be frame, fixed, or realtime".to_string(),
                    ))
                }
            };
            let fixed_step_ms = opts
                .as_ref()
                .and_then(|table| table.get::<_, Option<u64>>("fixed_step_ms").ok().flatten())
                .unwrap_or(16);
            let mut recorder = rc.borrow_mut();
            recorder.input_recorder.set_playback_mode(mode);
            recorder
                .input_recorder
                .set_playback_fixed_step_ms(fixed_step_ms);
            recorder.input_recorder.start_playback();
            Ok(())
        })?,
    )?;
    let rc = rec_state.clone();
    // -- stopPlayback --
    /// Stops playback of the loaded recording.
    input_tbl.set(
        "stopPlayback",
        lua.create_function(move |_, ()| {
            rc.borrow_mut().input_recorder.stop_playback();
            Ok(())
        })?,
    )?;
    let rc = rec_state.clone();
    // -- isRecording --
    /// Returns whether the module recorder is currently recording.
    /// @return | boolean | True when recording is active.
    input_tbl.set(
        "isRecording",
        lua.create_function(move |_, ()| Ok(rc.borrow().input_recorder.is_recording()))?,
    )?;
    let rc = rec_state.clone();
    // -- isPlayingBack --
    /// Returns whether the module recorder is currently playing back.
    /// @return | boolean | True when playback is active.
    input_tbl.set(
        "isPlayingBack",
        lua.create_function(move |_, ()| Ok(rc.borrow().input_recorder.is_playing_back()))?,
    )?;
    let rc = rec_state.clone();
    // -- getPlaybackFrame --
    /// Returns the current playback frame index.
    /// @return | integer | Playback frame index.
    input_tbl.set(
        "getPlaybackFrame",
        lua.create_function(move |_, ()| {
            Ok(rc.borrow().input_recorder.playback_frame_index() as i64)
        })?,
    )?;
    let rc = rec_state.clone();
    // -- advancePlayback --
    /// Advances playback by one frame and returns events for that frame.
    /// @return | table | Array of event records with `kind` and `name` fields.
    /// @field | kind | string | Event kind (press, release, hold).
    /// @field | name | string | Event name.
    /// @field | mouse_x | number? | Replayed mouse X coordinate for this frame when recorded.
    /// @field | mouse_y | number? | Replayed mouse Y coordinate for this frame when recorded.
    input_tbl.set(
        "advancePlayback",
        lua.create_function(move |lua, ()| {
            let frame = rc.borrow_mut().input_recorder.playback_frame();
            let tbl = lua.create_table()?;
            for (i, ev) in frame.key_events.iter().enumerate() {
                let etbl = lua.create_table()?;
                /// Performs the 'kind' operation.
                etbl.set("kind", ev.kind.clone())?;
                /// Performs the 'name' operation.
                etbl.set("name", ev.name.clone())?;
                tbl.set(i + 1, etbl)?;
            }
            /// Replayed mouse X coordinate for this frame when recorded.
            tbl.set("mouse_x", frame.mouse_x)?;
            /// Replayed mouse Y coordinate for this frame when recorded.
            tbl.set("mouse_y", frame.mouse_y)?;
            Ok(tbl)
        })?,
    )?;

    lurek.set("input", input_tbl)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::SharedState;
    use std::path::PathBuf;

    #[test]
    fn mouse_bindings_resolve_to_mouse_button_state() {
        let mut st = SharedState::new(800, 600, "test", PathBuf::new());
        st.mouse.set_button(0, true);
        st.mouse.set_button(1, true);

        assert!(binding_is_down(&st, "mouse1"));
        assert!(binding_is_down(&st, "mouse2"));
        assert!(!binding_is_down(&st, "mouse3"));
    }

    #[test]
    fn mouse_bindings_track_button_transitions() {
        let mut st = SharedState::new(800, 600, "test", PathBuf::new());
        st.mouse.set_button(0, true);
        assert!(binding_was_pressed(&st, "mouse1"));

        st.mouse.set_button(0, false);
        assert!(binding_was_released(&st, "mouse1"));
    }

    #[test]
    fn scancode_bindings_resolve_to_scancode_state() {
        let mut st = SharedState::new(800, 600, "test", PathBuf::new());
        st.keyboard.press_scancode("lshift".to_string());

        assert!(binding_is_down(&st, "lshift"));
        assert!(binding_was_pressed(&st, "lshift"));

        st.keyboard.release_scancode("lshift".to_string());
        assert!(binding_was_released(&st, "lshift"));
    }
}
