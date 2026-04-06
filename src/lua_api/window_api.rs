//! `luna.window` Lua API bindings.
//!
//! Auto-generated skeleton from `src/window/` Rust docstrings.
//! Fill in the `todo!()` bodies with actual implementation.
//! Every `pub fn` has `@param`/`@return` tags for `gen_lua_api.py`.
//!
use std::cell::RefCell;
use std::rc::Rc;

use mlua::prelude::*;
use mlua::{UserData, UserDataMethods};

use crate::engine::SharedState;

// ── luna.window.* functions ──────────────────────────────────────────

/// Set the window title shown in the OS title bar.
///
///
/// @param title : string
/// @return nil
pub fn set_title(_lua: &Lua, _args: LuaMultiValue<'_>) -> LuaResult<()> {
    todo!()
}

/// Enter or exit fullscreen mode.
///
/// `mode` is `"desktop"` (borderless) or `"exclusive"`.  Pass `""` to use the
/// current mode setting.
///
///
/// @param flag : boolean
/// @param mode : string
/// @return nil
pub fn set_fullscreen(_lua: &Lua, _args: LuaMultiValue<'_>) -> LuaResult<()> {
    todo!()
}

/// Return whether the window is currently in fullscreen mode.
///
///
/// @return boolean
pub fn is_fullscreen(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Set the VSync presentation mode.
///
/// Values: `1` = Fifo (vsync on), `0` = Immediate (vsync off), `-1` = Mailbox
/// (adaptive vsync).
///
///
/// @param mode : integer
/// @return nil
pub fn set_vsync(_lua: &Lua, _args: LuaMultiValue<'_>) -> LuaResult<()> {
    todo!()
}

/// Return the current VSync mode integer.
///
///
/// @return integer
pub fn get_vsync(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Return the DPI scale factor of the display the window is on.
///
/// On standard displays this is `1.0`; on HiDPI / Retina displays it may be
/// `2.0` or higher.
///
///
/// @return number
pub fn get_dpi_scale(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Return the current window X and Y position in screen coordinates.
///
///
/// @return integer
pub fn get_position(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Move the window to the given screen coordinate position.
///
///
/// @param x : integer
/// @param y : integer
/// @return nil
pub fn set_position(_lua: &Lua, _args: LuaMultiValue<'_>) -> LuaResult<()> {
    todo!()
}

/// Minimise the window to the taskbar.
///
///
/// @return nil
pub fn minimize(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Maximise the window to fill the screen.
///
///
/// @return nil
pub fn maximize(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Restore the window from minimised or maximised state.
///
///
/// @return nil
pub fn restore(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Return whether the window is currently minimised.
///
///
/// @return boolean
pub fn is_minimized(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Return whether the window is currently maximised.
///
///
/// @return boolean
pub fn is_maximized(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Return whether the window has keyboard focus.
///
///
/// @return boolean
pub fn has_focus(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Flash the taskbar icon or bounce the dock icon to request user attention.
///
///
/// @return nil
pub fn request_attention(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Close the window and exit the game on the next frame.
///
///
/// @return nil
pub fn close(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Set the window icon from the given image file path.
///
///
/// @param path : string
/// @return nil
pub fn set_icon(_lua: &Lua, _args: LuaMultiValue<'_>) -> LuaResult<()> {
    todo!()
}

/// Resize the window to the given logical pixel dimensions.
///
///
/// @param w : integer
/// @param h : integer
/// @return nil
pub fn set_size(_lua: &Lua, _args: LuaMultiValue<'_>) -> LuaResult<()> {
    todo!()
}

/// Return the logical game width in virtual pixels.
///
///
/// @return number
pub fn get_width(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Return the logical game height in virtual pixels.
///
///
/// @return number
pub fn get_height(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Return the current viewport scale mode string.
///
/// One of `"none"`, `"letterbox"`, `"stretch"`, or `"pixel"`.
///
///
/// @return string
pub fn get_scale_mode(_lua: &Lua, _: ()) -> LuaResult<()> {
    todo!()
}

/// Set the viewport scale mode.
///
///
/// @param mode : string
/// @return nil
pub fn set_scale_mode(_lua: &Lua, _args: LuaMultiValue<'_>) -> LuaResult<()> {
    todo!()
}

/// Convert game-space coordinates to window pixel coordinates.
///
///
/// @param x : number
/// @param y : number
/// @return number
pub fn to_pixels(_lua: &Lua, _args: LuaMultiValue<'_>) -> LuaResult<()> {
    todo!()
}

/// Convert window pixel coordinates back to game-space coordinates.
///
///
/// @param x : number
/// @param y : number
/// @return number
pub fn from_pixels(_lua: &Lua, _args: LuaMultiValue<'_>) -> LuaResult<()> {
    todo!()
}

/// Registers the `luna.window` API table.
///
/// @param lua : &Lua
/// @param luna : &LuaTable
/// @param state : Rc<RefCell<SharedState>>
/// @return LuaResult<()>
pub fn register(
    lua: &Lua,
    luna: &mlua::Table,
    _state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    tbl.set("setTitle", lua.create_function(set_title)?)?;
    tbl.set("setFullscreen", lua.create_function(set_fullscreen)?)?;
    tbl.set("isFullscreen", lua.create_function(is_fullscreen)?)?;
    tbl.set("setVsync", lua.create_function(set_vsync)?)?;
    tbl.set("getVsync", lua.create_function(get_vsync)?)?;
    tbl.set("getDpiScale", lua.create_function(get_dpi_scale)?)?;
    tbl.set("getPosition", lua.create_function(get_position)?)?;
    tbl.set("setPosition", lua.create_function(set_position)?)?;
    tbl.set("minimize", lua.create_function(minimize)?)?;
    tbl.set("maximize", lua.create_function(maximize)?)?;
    tbl.set("restore", lua.create_function(restore)?)?;
    tbl.set("isMinimized", lua.create_function(is_minimized)?)?;
    tbl.set("isMaximized", lua.create_function(is_maximized)?)?;
    tbl.set("hasFocus", lua.create_function(has_focus)?)?;
    tbl.set("requestAttention", lua.create_function(request_attention)?)?;
    tbl.set("close", lua.create_function(close)?)?;
    tbl.set("setIcon", lua.create_function(set_icon)?)?;
    tbl.set("setSize", lua.create_function(set_size)?)?;
    tbl.set("getWidth", lua.create_function(get_width)?)?;
    tbl.set("getHeight", lua.create_function(get_height)?)?;
    tbl.set("getScaleMode", lua.create_function(get_scale_mode)?)?;
    tbl.set("setScaleMode", lua.create_function(set_scale_mode)?)?;
    tbl.set("toPixels", lua.create_function(to_pixels)?)?;
    tbl.set("fromPixels", lua.create_function(from_pixels)?)?;
    luna.set("window", tbl)?;
    Ok(())
}
