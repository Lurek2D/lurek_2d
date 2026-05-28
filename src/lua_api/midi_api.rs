//! `lurek.midi` - MIDI playback and SoundFont management.
//!
//! - Registers `lurek.midi.*` functions and types via `register()`.

use super::SharedState;
use crate::lua_api::audio_api::LuaMidiPlayer;
use crate::midi::MidiPlayer;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;
/// Registers the `lurek.midi` Lua API table.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newPlayer --
    /// Creates a new MIDI player instance, optionally loading a file immediately.
    /// @param | path | string? | Optional relative path to a .mid file to load.
    /// @return | LMidiPlayer | A new MIDI player ready for playback.
    let s = state.clone();
    tbl.set(
        "newPlayer",
        lua.create_function(move |_, path: Option<String>| {
            let mp = MidiPlayer::new();
            let inner = Rc::new(RefCell::new(mp));
            let result = LuaMidiPlayer {
                inner: inner.clone(),
                state: s.clone(),
            };
            if let Some(p) = path {
                let st = s.borrow();
                let full_path = st.game_dir.join(&p);
                drop(st);
                inner.borrow_mut().load(&full_path);
            }
            Ok(result)
        })?,
    )?;
    // -- loadSoundFont --
    /// Loads a SoundFont (SF2) file into the global MIDI state for synthesis.
    /// @param | path | string | Relative path to the .sf2 file.
    /// @return | boolean | True if the SoundFont was loaded successfully.
    let s = state.clone();
    tbl.set(
        "loadSoundFont",
        lua.create_function(move |_, path: String| {
            if path.contains("..") {
                return Err(LuaError::external("path traversal not allowed"));
            }
            let st = s.borrow();
            let full_path = st.game_dir.join(&path);
            drop(st);
            let data = std::fs::read(&full_path)
                .map_err(|e| LuaError::external(format!("cannot read '{}': {}", path, e)))?;
            let mut st = s.borrow_mut();
            st.midi_state
                .set_soundfont(data, Some(path))
                .map_err(LuaError::external)?;
            Ok(true)
        })?,
    )?;
    // -- hasSoundFont --
    /// Returns whether a SoundFont is currently loaded and ready for synthesis.
    /// @return | boolean | True if a SoundFont is loaded.
    let s = state.clone();
    tbl.set(
        "hasSoundFont",
        lua.create_function(move |_, ()| Ok(s.borrow().midi_state.has_soundfont()))?,
    )?;
    // -- clearSoundFont --
    /// Unloads the current SoundFont and frees its memory.
    let s = state.clone();
    tbl.set(
        "clearSoundFont",
        lua.create_function(move |_, ()| {
            s.borrow_mut().midi_state.clear_soundfont();
            Ok(())
        })?,
    )?;
    lurek.set("midi", tbl)?;
    Ok(())
}
