//! Registers the `lurek.automation` Lua API for automation data bridging, vector decoding, and runtime controls.

use super::SharedState;
use crate::app::lua_callbacks::{
    call_function_with_optional_timeout, call_lua_callback_checked_with_timeout,
};
use crate::automation::simulator::StepEventSink;
use crate::automation::{Action, Script, Simulator, Step};
use crate::event::{Event, EventArg};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

fn call_lua_ui_bool<'a, A: IntoLuaMulti<'a>>(
    lua: &'a Lua,
    method: &str,
    args: A,
    timeout_ms: Option<f32>,
) -> Result<bool, mlua::Error> {
    let Ok(lurek) = lua.globals().get::<_, LuaTable>("lurek") else {
        return Ok(false);
    };
    let Ok(ui) = lurek.get::<_, LuaTable>("ui") else {
        return Ok(false);
    };
    let Ok(func) = ui.get::<_, LuaFunction>(method) else {
        return Ok(false);
    };
    call_function_with_optional_timeout(lua, &format!("ui.{method}"), func, args, timeout_ms)
}

fn event_arg_string(args: &[EventArg], index: usize, default: &str) -> String {
    match args.get(index) {
        Some(EventArg::Str(value)) => value.clone(),
        _ => default.to_string(),
    }
}

fn event_arg_num(args: &[EventArg], index: usize, default: f64) -> f64 {
    match args.get(index) {
        Some(EventArg::Num(value)) => *value,
        _ => default,
    }
}

fn event_arg_bool(args: &[EventArg], index: usize, default: bool) -> bool {
    match args.get(index) {
        Some(EventArg::Bool(value)) => *value,
        _ => default,
    }
}

fn refresh_keyboard_modifiers(state: &mut SharedState) {
    let shift = state.keyboard.is_down("shift");
    let ctrl = state.keyboard.is_down("ctrl");
    let alt = state.keyboard.is_down("alt");
    let meta = state.keyboard.is_down("meta") || state.keyboard.is_down("super");
    state.keyboard.set_modifiers(shift, ctrl, alt, meta);
}

fn button_slot(button: u32) -> Option<usize> {
    match button {
        1..=5 => Some((button - 1) as usize),
        _ => None,
    }
}

struct AutomationLuaDispatcher;

impl AutomationLuaDispatcher {
    fn dispatch_automation_event(
        lua: &Lua,
        state: &Rc<RefCell<SharedState>>,
        event: &Event,
    ) -> LuaResult<()> {
        let timeout_ms = state.borrow().lua_callback_timeout_ms;
        match event.name.as_str() {
            "keypressed" => {
                let key = event_arg_string(&event.args, 0, "unknown");
                let scancode = event_arg_string(&event.args, 1, "");
                let is_repeat = event_arg_bool(&event.args, 2, false);
                let repeat_enabled = state.borrow().keyboard.has_key_repeat();
                if !is_repeat || repeat_enabled {
                    {
                        let mut st = state.borrow_mut();
                        if !scancode.is_empty() {
                            st.keyboard.press_scancode(scancode.clone());
                        }
                        st.keys_down.insert(key.clone());
                        st.keyboard.set_key_down(&key);
                        refresh_keyboard_modifiers(&mut st);
                    }
                    let auto_ui_input = state.borrow().auto_ui_input;
                    let mut ui_consumed = false;
                    if auto_ui_input {
                        ui_consumed = call_lua_ui_bool(lua, "keypressed", key.clone(), timeout_ms)?;
                    }
                    if !ui_consumed {
                        call_lua_callback_checked_with_timeout(
                            lua,
                            "keypressed",
                            (key.clone(), scancode.clone(), is_repeat),
                            timeout_ms,
                        )?;
                    }
                }
            }
            "keyreleased" => {
                let key = event_arg_string(&event.args, 0, "unknown");
                let scancode = event_arg_string(&event.args, 1, "");
                {
                    let mut st = state.borrow_mut();
                    if !scancode.is_empty() {
                        st.keyboard.release_scancode(scancode.clone());
                    }
                    st.keys_down.remove(&key);
                    st.keyboard.set_key_up(&key);
                    refresh_keyboard_modifiers(&mut st);
                }
                call_lua_callback_checked_with_timeout(
                    lua,
                    "keyreleased",
                    (key.clone(), scancode.clone()),
                    timeout_ms,
                )?;
            }
            "mousemoved" => {
                let x = event_arg_num(&event.args, 0, 0.0) as f32;
                let y = event_arg_num(&event.args, 1, 0.0) as f32;
                let (dx, dy) = {
                    let mut st = state.borrow_mut();
                    let dx = x - st.mouse.x;
                    let dy = y - st.mouse.y;
                    st.mouse.update_position(x, y);
                    (dx, dy)
                };
                let auto_ui_input = state.borrow().auto_ui_input;
                let mut ui_consumed = false;
                if auto_ui_input {
                    ui_consumed = call_lua_ui_bool(lua, "mousemoved", (x, y), timeout_ms)?;
                }
                if !ui_consumed {
                    call_lua_callback_checked_with_timeout(
                        lua,
                        "mousemoved",
                        (x, y, dx, dy),
                        timeout_ms,
                    )?;
                }
            }
            "mousepressed" => {
                let x = event_arg_num(&event.args, 0, 0.0) as f32;
                let y = event_arg_num(&event.args, 1, 0.0) as f32;
                let button = event_arg_num(&event.args, 2, 1.0) as u32;
                if let Some(slot) = button_slot(button) {
                    let was_pressed = {
                        let mut st = state.borrow_mut();
                        let was_pressed = st.mouse.is_down(slot);
                        st.mouse.update_position(x, y);
                        st.mouse.set_button(slot, true);
                        was_pressed
                    };
                    if !was_pressed {
                        let auto_ui_input = state.borrow().auto_ui_input;
                        let mut ui_consumed = false;
                        if auto_ui_input {
                            ui_consumed =
                                call_lua_ui_bool(lua, "mousepressed", (x, y, button), timeout_ms)?;
                        }
                        if !ui_consumed {
                            call_lua_callback_checked_with_timeout(
                                lua,
                                "mousepressed",
                                (x, y, button),
                                timeout_ms,
                            )?;
                        }
                    }
                }
            }
            "mousereleased" => {
                let x = event_arg_num(&event.args, 0, 0.0) as f32;
                let y = event_arg_num(&event.args, 1, 0.0) as f32;
                let button = event_arg_num(&event.args, 2, 1.0) as u32;
                if let Some(slot) = button_slot(button) {
                    let was_pressed = {
                        let mut st = state.borrow_mut();
                        let was_pressed = st.mouse.is_down(slot);
                        st.mouse.update_position(x, y);
                        st.mouse.set_button(slot, false);
                        was_pressed
                    };
                    if was_pressed {
                        let auto_ui_input = state.borrow().auto_ui_input;
                        let mut ui_consumed = false;
                        if auto_ui_input {
                            ui_consumed =
                                call_lua_ui_bool(lua, "mousereleased", (x, y, button), timeout_ms)?;
                        }
                        if !ui_consumed {
                            call_lua_callback_checked_with_timeout(
                                lua,
                                "mousereleased",
                                (x, y, button),
                                timeout_ms,
                            )?;
                        }
                    }
                }
            }
            "wheelmoved" => {
                let dx = event_arg_num(&event.args, 0, 0.0);
                let dy = event_arg_num(&event.args, 1, 0.0);
                {
                    let mut st = state.borrow_mut();
                    st.mouse.accumulate_scroll(dx, dy);
                }
                let auto_ui_input = state.borrow().auto_ui_input;
                let mut ui_consumed = false;
                if auto_ui_input {
                    ui_consumed = call_lua_ui_bool(lua, "wheelmoved", (dx, dy), timeout_ms)?;
                }
                if !ui_consumed {
                    call_lua_callback_checked_with_timeout(
                        lua,
                        "wheelmoved",
                        (dx, dy),
                        timeout_ms,
                    )?;
                }
            }
            "textinput" => {
                let text = event_arg_string(&event.args, 0, "");
                let text_enabled = state.borrow().keyboard.has_text_input();
                if text_enabled {
                    {
                        let mut st = state.borrow_mut();
                        st.keyboard.push_text_input(text.clone());
                    }
                    let auto_ui_input = state.borrow().auto_ui_input;
                    let mut ui_consumed = false;
                    if auto_ui_input {
                        ui_consumed = call_lua_ui_bool(lua, "textinput", text.clone(), timeout_ms)?;
                    }
                    if !ui_consumed {
                        call_lua_callback_checked_with_timeout(
                            lua,
                            "textinput",
                            text.clone(),
                            timeout_ms,
                        )?;
                    }
                }
            }
            _ => {}
        }
        state.borrow_mut().event_queue.push(event.clone());
        Ok(())
    }
}

fn dispatch_automation_event(
    lua: &Lua,
    state: &Rc<RefCell<SharedState>>,
    event: &Event,
) -> LuaResult<()> {
    AutomationLuaDispatcher::dispatch_automation_event(lua, state, event)
}

struct AutomationDispatchSink<'a> {
    lua: &'a Lua,
    state: Rc<RefCell<SharedState>>,
    first_error: Option<mlua::Error>,
}

impl<'a> AutomationDispatchSink<'a> {
    fn new(lua: &'a Lua, state: Rc<RefCell<SharedState>>) -> Self {
        Self {
            lua,
            state,
            first_error: None,
        }
    }
}

impl StepEventSink for AutomationDispatchSink<'_> {
    fn push_event(&mut self, event: Event) {
        if self.first_error.is_some() {
            return;
        }
        if let Err(err) = dispatch_automation_event(self.lua, &self.state, &event) {
            self.first_error = Some(err);
        }
    }
}

/// Registers the `lurek.automation` API table with the Lua VM.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let simulator = Rc::new(RefCell::new(Simulator::new()));
    let wait_state: Rc<RefCell<Option<(LuaRegistryKey, f32, f32)>>> = Rc::new(RefCell::new(None));
    // -- load --
    /// Loads an automation script from a Lua table of steps and optional metadata.
    /// @param | name | string | Script name used by `start`, macros, and lookup calls.
    /// @param | data | table | Script data table with a `steps` array and optional `meta.description` string.
    let sim = simulator.clone();
    tbl.set(
        "load",
        lua.create_function(move |_, (name, data): (String, LuaTable)| {
            let steps_table: LuaTable = data.get::<_, LuaTable>("steps").map_err(|_| {
                LuaError::external("simulator.load: data table must have a 'steps' array")
            })?;
            let steps = Step::vec_from_lua_table(&steps_table)?;
            let description: Option<String> = data
                .get::<_, Option<LuaTable>>("meta")?
                .and_then(|meta| meta.get::<_, Option<String>>("description").ok().flatten());
            let script = match description {
                Some(desc) => Script::with_description(name, desc, steps),
                None => Script::new(name, steps),
            };
            sim.borrow_mut().load(script);
            Ok(())
        })?,
    )?;
    // -- unload --
    /// Unloads a named automation script.
    /// @param | name | string | Script name to remove.
    /// @return | boolean | True when the script existed and was removed.
    let sim = simulator.clone();
    tbl.set(
        "unload",
        lua.create_function(move |_, name: String| Ok(sim.borrow_mut().unload(&name)))?,
    )?;
    // -- hasScript --
    /// Returns whether a script is loaded.
    /// @param | name | string | Script name to check.
    /// @return | boolean | True when the script is loaded.
    let sim = simulator.clone();
    tbl.set(
        "hasScript",
        lua.create_function(move |_, name: String| Ok(sim.borrow().has_script(&name)))?,
    )?;
    // -- getScripts --
    /// Returns the names of loaded automation scripts.
    /// @return | string[] | Script names.
    let sim = simulator.clone();
    tbl.set(
        "getScripts",
        lua.create_function(move |_, ()| Ok(sim.borrow().get_scripts()))?,
    )?;
    // -- start --
    /// Starts playback of a loaded automation script.
    /// @param | name | string | Loaded script name to start.
    let sim = simulator.clone();
    tbl.set(
        "start",
        lua.create_function(move |_, name: String| {
            sim.borrow_mut().start(&name).map_err(LuaError::external)
        })?,
    )?;
    // -- stop --
    /// Stops the current automation script.
    let sim = simulator.clone();
    tbl.set(
        "stop",
        lua.create_function(move |_, ()| {
            sim.borrow_mut().stop();
            Ok(())
        })?,
    )?;
    // -- pause --
    /// Pauses automation playback. This function is exposed to Lua scripts.
    let sim = simulator.clone();
    tbl.set(
        "pause",
        lua.create_function(move |_, ()| {
            sim.borrow_mut().pause();
            Ok(())
        })?,
    )?;
    // -- resume --
    /// Resumes automation playback. This function is exposed to Lua scripts.
    let sim = simulator.clone();
    tbl.set(
        "resume",
        lua.create_function(move |_, ()| {
            sim.borrow_mut().resume();
            Ok(())
        })?,
    )?;
    // -- update --
    /// Advances automation playback and dispatches generated input events.
    /// @param | dt | number | Elapsed time in seconds.
    let sim = simulator.clone();
    let s = state.clone();
    let ws = wait_state.clone();
    tbl.set(
        "update",
        lua.create_function(move |lua, dt: f32| {
            if ws.borrow().is_some() {
                let (resolved, timed_out) = {
                    let state_opt = ws.borrow();
                    if let Some((ref key, timeout, elapsed)) = *state_opt {
                        let new_elapsed = elapsed + dt;
                        let predicate: LuaFunction = lua.registry_value(key)?;
                        let done: bool = predicate.call(())?;
                        (done, new_elapsed >= timeout)
                    } else {
                        (false, false)
                    }
                };
                if resolved || timed_out {
                    *ws.borrow_mut() = None;
                } else {
                    if let Some(ref mut triple) = ws.borrow_mut().as_mut() {
                        triple.2 += dt;
                    }
                    return Ok(());
                }
            }
            let mut sink = AutomationDispatchSink::new(lua, s.clone());
            sim.borrow_mut().update_with_sink(dt, &mut sink);
            if let Some(err) = sink.first_error {
                return Err(err);
            }
            Ok(())
        })?,
    )?;
    // -- isRunning --
    /// Returns whether automation playback is running.
    /// @return | boolean | True when a script is running.
    let sim = simulator.clone();
    tbl.set(
        "isRunning",
        lua.create_function(move |_, ()| Ok(sim.borrow().is_running()))?,
    )?;
    // -- isPaused --
    /// Returns whether automation playback is paused.
    /// @return | boolean | True when playback is paused.
    let sim = simulator.clone();
    tbl.set(
        "isPaused",
        lua.create_function(move |_, ()| Ok(sim.borrow().is_paused()))?,
    )?;
    // -- isComplete --
    /// Returns whether the current automation script completed.
    /// @return | boolean | True when the current script has completed.
    let sim = simulator.clone();
    tbl.set(
        "isComplete",
        lua.create_function(move |_, ()| Ok(sim.borrow().is_complete()))?,
    )?;
    // -- isFailed --
    /// Returns whether the current automation script failed.
    /// @return | boolean | True when the current script has failed.
    let sim = simulator.clone();
    tbl.set(
        "isFailed",
        lua.create_function(move |_, ()| Ok(sim.borrow().is_failed()))?,
    )?;
    // -- getLastError --
    /// Returns the last automation error message when one exists.
    /// @return | string | Last error string, or nil when no error is stored.
    let sim = simulator.clone();
    tbl.set(
        "getLastError",
        lua.create_function(move |_, ()| Ok(sim.borrow().last_error().map(|s| s.to_string())))?,
    )?;
    // -- setCondition --
    /// Sets a named boolean condition used by automation steps.
    /// @param | name | string | Condition name.
    /// @param | value | boolean | Condition value.
    let sim = simulator.clone();
    tbl.set(
        "setCondition",
        lua.create_function(move |_, (name, value): (String, bool)| {
            sim.borrow_mut().set_condition(name, value);
            Ok(())
        })?,
    )?;
    // -- getCondition --
    /// Returns a named automation condition value.
    /// @param | name | string | Condition name.
    /// @return | boolean | Current condition value.
    let sim = simulator.clone();
    tbl.set(
        "getCondition",
        lua.create_function(move |_, name: String| Ok(sim.borrow().get_condition(&name)))?,
    )?;
    // -- getCurrentStep --
    /// Returns the current step index of the active script.
    /// @return | integer | Current step index.
    let sim = simulator.clone();
    tbl.set(
        "getCurrentStep",
        lua.create_function(move |_, ()| Ok(sim.borrow().current_step()))?,
    )?;
    // -- getStepCount --
    /// Returns the number of steps in the active script.
    /// @return | integer | Active script step count.
    let sim = simulator.clone();
    tbl.set(
        "getStepCount",
        lua.create_function(move |_, ()| Ok(sim.borrow().step_count()))?,
    )?;
    // -- getCurrentScript --
    /// Returns the current script name when a script is active.
    /// @return | string | Current script name, or nil when no script is active.
    let sim = simulator.clone();
    tbl.set(
        "getCurrentScript",
        lua.create_function(move |_, ()| Ok(sim.borrow().current_script().map(|s| s.to_string())))?,
    )?;
    // -- getElapsedTime --
    /// Returns elapsed playback time for the current script.
    /// @return | number | Elapsed time in seconds.
    let sim = simulator.clone();
    tbl.set(
        "getElapsedTime",
        lua.create_function(move |_, ()| Ok(sim.borrow().elapsed_time()))?,
    )?;
    // -- loadFromToml --
    /// Loads an automation script from TOML text.
    /// @param | name | string | Script name used by `start`, macros, and lookup calls.
    /// @param | toml_str | string | TOML automation script contents.
    let sim = simulator.clone();
    tbl.set(
        "loadFromToml",
        lua.create_function(move |_, (name, toml_str): (String, String)| {
            let script = Script::from_toml(&name, &toml_str)
                .map_err(|e| LuaError::external(format!("loadFromToml: {e}")))?;
            sim.borrow_mut().load(script);
            Ok(())
        })?,
    )?;
    // -- getStepLimit --
    /// Returns the configured step limit for a loaded script.
    /// @param | name | string | Script name to query.
    /// @return | integer | Step limit, or nil when no limit is set.
    let sim = simulator.clone();
    tbl.set(
        "getStepLimit",
        lua.create_function(move |_, name: String| {
            Ok(sim.borrow().get_script_step_limit(&name).map(|v| v as u64))
        })?,
    )?;
    // -- setStepLimit --
    /// Sets the maximum step count for a loaded script.
    /// @param | name | string | Script name to update.
    /// @param | n | integer | Maximum step count.
    /// @return | boolean | True when the script exists and the limit was set.
    let sim = simulator.clone();
    tbl.set(
        "setStepLimit",
        lua.create_function(move |_, (name, n): (String, u64)| {
            Ok(sim.borrow_mut().set_script_step_limit(&name, n as usize))
        })?,
    )?;
    // -- saveMacro --
    /// Saves a loaded script as a named macro.
    /// @param | macro_name | string | Macro name to save.
    /// @param | script_name | string | Loaded script name to copy into the macro store.
    let sim = simulator.clone();
    tbl.set(
        "saveMacro",
        lua.create_function(move |_, (macro_name, script_name): (String, String)| {
            let script = sim.borrow().get_script(&script_name).ok_or_else(|| {
                LuaError::external(format!("saveMacro: script '{}' not found", script_name))
            })?;
            sim.borrow_mut().save_macro(macro_name, script);
            Ok(())
        })?,
    )?;
    // -- playMacro --
    /// Starts playback of a saved macro. This function is exposed to Lua scripts.
    /// @param | name | string | Macro name to play.
    let sim = simulator.clone();
    tbl.set(
        "playMacro",
        lua.create_function(move |_, name: String| {
            sim.borrow_mut()
                .play_macro(&name)
                .map_err(LuaError::external)
        })?,
    )?;
    // -- hasMacro --
    /// Returns whether a macro is saved. This function is exposed to Lua scripts.
    /// @param | name | string | Macro name to check.
    /// @return | boolean | True when the macro exists.
    let sim = simulator.clone();
    tbl.set(
        "hasMacro",
        lua.create_function(move |_, name: String| Ok(sim.borrow().has_macro(&name)))?,
    )?;
    // -- listMacros --
    /// Returns the names of saved macros. This function is exposed to Lua scripts.
    /// @return | string[] | Macro names.
    let sim = simulator.clone();
    tbl.set(
        "listMacros",
        lua.create_function(move |_, ()| Ok(sim.borrow().list_macros()))?,
    )?;
    // -- setPlaybackSpeed --
    /// Sets automation playback speed multiplier.
    /// @param | factor | number | Playback speed multiplier.
    let sim = simulator.clone();
    tbl.set(
        "setPlaybackSpeed",
        lua.create_function(move |_, factor: f32| {
            sim.borrow_mut().set_playback_speed(factor);
            Ok(())
        })?,
    )?;
    // -- getPlaybackSpeed --
    /// Returns automation playback speed multiplier.
    /// @return | number | Current playback speed multiplier.
    let sim = simulator.clone();
    tbl.set(
        "getPlaybackSpeed",
        lua.create_function(move |_, ()| Ok(sim.borrow().get_playback_speed()))?,
    )?;
    // -- setHighlightMode --
    /// Enables or disables automation highlight mode.
    /// @param | enable | boolean | True to enable highlight mode.
    let sim = simulator.clone();
    tbl.set(
        "setHighlightMode",
        lua.create_function(move |_, enable: bool| {
            sim.borrow_mut().set_highlight_mode(enable);
            Ok(())
        })?,
    )?;
    // -- isHighlightMode --
    /// Returns whether automation highlight mode is enabled.
    /// @return | boolean | True when highlight mode is enabled.
    let sim = simulator.clone();
    tbl.set(
        "isHighlightMode",
        lua.create_function(move |_, ()| Ok(sim.borrow().is_highlight_mode()))?,
    )?;
    // -- waitUntil --
    /// Suspends automation updates until a predicate returns true or a timeout elapses.
    /// @param | predicate | function | Function called each update; true resolves the wait.
    /// @param | timeout | number | Maximum wait duration in seconds.
    let ws = wait_state.clone();
    tbl.set(
        "waitUntil",
        lua.create_function(move |lua, (predicate, timeout): (LuaFunction, f32)| {
            let key = lua.create_registry_value(predicate)?;
            *ws.borrow_mut() = Some((key, timeout.max(0.0), 0.0));
            Ok(())
        })?,
    )?;
    /// Performs the 'automation' operation.
    lurek.set("automation", tbl)?;
    Ok(())
}
impl Step {
    /// Converts a Lua array of step tables into automation steps.
    pub fn vec_from_lua_table(t: &LuaTable) -> LuaResult<Vec<Self>> {
        let len = t.len()? as usize;
        let mut steps = Vec::with_capacity(len);
        for i in 1..=len {
            let entry: LuaTable = t.get(i)?;
            let action_str: String = entry.get::<_, String>("action").map_err(|_| {
                LuaError::external("simulator.load: each step must have an 'action' field")
            })?;
            let action = Action::parse_action(&action_str).ok_or_else(|| {
                LuaError::external(format!(
                    "simulator.load: unknown action '{}' \u{2014} expected one of: keypress, keyrelease, mousemove, mousepress, mouserelease, mousewheel, textinput, wait, repeat, callmacro, assert, visualassert",
                    action_str
                ))
            })?;
            let time: f32 = entry.get::<_, Option<f32>>("time")?.unwrap_or(0.0);
            let mut step = Self::new(time, action);
            step.key = entry.get::<_, Option<String>>("key")?;
            step.scancode = entry.get::<_, Option<String>>("scancode")?;
            step.x = entry.get::<_, Option<f64>>("x")?;
            step.y = entry.get::<_, Option<f64>>("y")?;
            step.dx = entry.get::<_, Option<f64>>("dx")?;
            step.dy = entry.get::<_, Option<f64>>("dy")?;
            step.button = entry.get::<_, Option<u32>>("button")?;
            step.text = entry.get::<_, Option<String>>("text")?;
            step.is_repeat = entry.get::<_, Option<bool>>("isRepeat")?.unwrap_or(false);
            step.clicks = entry.get::<_, Option<u32>>("clicks")?;
            step.repeat = entry.get::<_, Option<u32>>("repeat")?;
            step.repeat_interval = entry.get::<_, Option<f32>>("repeatInterval")?;
            step.macro_name = entry.get::<_, Option<String>>("macro")?;
            step.when = entry.get::<_, Option<String>>("when")?;
            step.assert = entry.get::<_, Option<String>>("assert")?;
            step.baseline = entry.get::<_, Option<String>>("baseline")?;
            step.actual = entry.get::<_, Option<String>>("actual")?;
            step.max_diff = entry.get::<_, Option<u32>>("maxDiff")?;
            steps.push(step);
        }
        Ok(steps)
    }
}
