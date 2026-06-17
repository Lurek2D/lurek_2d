//! Lua API wrapper for the `cinematic` engine module. `src/lua_api/cinematic_api.rs` registers the `lurek.cinematic` Lua boundary for cinematic behavior, converts Lua values into engine types, validates arguments and error messages, and exposes userdata or callbacks while keeping implementation state in Rust modules.

use crate::cinematic::{Cinematic, CinematicClip, CinematicTimeline, ClipType};
use crate::runtime::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

/// Lua userdata handle wrapping a [`Cinematic`] timeline.
struct LuaCinematic {
    inner: RefCell<Cinematic>,
}

/// Lua userdata handle wrapping a [`CinematicTimeline`] for multi-track playback.
#[derive(Clone)]
pub(crate) struct LuaCinematicTimeline {
    /// Multi-track timeline with full playback control.
    pub inner: Rc<RefCell<CinematicTimeline>>,
}

impl LuaUserData for LuaCinematicTimeline {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addTrack --
        /// Adds a named track to this cinematic timeline.
        /// @param | name | string | Track name for identification.
        /// @return | nil | No value is returned.
        methods.add_method_mut("addTrack", |_, this, name: String| {
            this.inner.borrow_mut().add_track(name);
            Ok(())
        });

        // -- addClip --
        /// Adds a clip to a named track (creates track if missing).
        /// @param | track_name | string | Target track name.
        /// @param | at | number | Start time in seconds.
        /// @param | duration | number | Clip duration in seconds.
        /// @param | clip_table | table | Clip definition with type-specific data.
        methods.add_method_mut(
            "addClip",
            |_lua, this, (track_name, at, duration, clip_table): (String, f32, f32, LuaTable)| {
                let clip_type_str: String = clip_table.get("type")?;
                let clip_type = match clip_type_str.as_str() {
                    "tween" => {
                        let target = clip_table.get("target")?;
                        let props_tbl: LuaTable = clip_table
                            .get("properties")
                            .unwrap_or_else(|_| _lua.create_table().unwrap());
                        let mut props = HashMap::new();
                        for (k, v) in props_tbl.pairs::<String, f32>().flatten() {
                            props.insert(k, v);
                        }
                        let easing = clip_table.get("easing").ok();
                        ClipType::Tween {
                            target,
                            properties: props,
                            easing,
                        }
                    }
                    "camera" => {
                        let x = clip_table.get("x").unwrap_or(0.0);
                        let y = clip_table.get("y").unwrap_or(0.0);
                        let zoom = clip_table.get("zoom").unwrap_or(1.0);
                        let easing = clip_table.get("easing").ok();
                        ClipType::Camera { x, y, zoom, easing }
                    }
                    "audio" => {
                        let path = clip_table.get("path")?;
                        ClipType::Audio { path }
                    }
                    "signal" => {
                        let name = clip_table.get("name")?;
                        let data = clip_table.get("data").ok();
                        ClipType::Signal { name, data }
                    }
                    _ => {
                        return Err(LuaError::RuntimeError(format!(
                            "Unknown clip type: {}",
                            clip_type_str
                        )))
                    }
                };

                let clip = CinematicClip {
                    at,
                    duration,
                    clip_type,
                };
                this.inner.borrow_mut().add_clip_to_track(&track_name, clip);
                Ok(())
            },
        );

        // -- play --
        /// Starts playback from the current time.
        methods.add_method_mut("play", |_, this, ()| {
            this.inner.borrow_mut().play();
            Ok(())
        });

        // -- pause --
        /// Pauses playback without resetting time.
        methods.add_method_mut("pause", |_, this, ()| {
            this.inner.borrow_mut().pause();
            Ok(())
        });

        // -- stop --
        /// Stops playback and resets to time 0.
        methods.add_method_mut("stop", |_, this, ()| {
            this.inner.borrow_mut().stop();
            Ok(())
        });

        // -- seek --
        /// Jumps playback to a specific timeline time.
        /// @param | time | number | Time in seconds.
        methods.add_method_mut("seek", |_, this, time: f32| {
            this.inner.borrow_mut().seek(time);
            Ok(())
        });

        // -- update --
        /// Advances time by dt (only if playing).
        /// @param | dt | number | Delta time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });

        // -- skipToEnd --
        /// Instantly jumps to the end of the timeline.
        methods.add_method_mut("skipToEnd", |_, this, ()| {
            this.inner.borrow_mut().skip_to_end();
            Ok(())
        });

        // -- getTime --
        /// Returns the current playback time.
        /// @return | number | Current time in seconds.
        methods.add_method("getTime", |_, this, ()| Ok(this.inner.borrow().get_time()));

        // -- getDuration --
        /// Returns the total duration of the timeline.
        /// @return | number | Duration in seconds.
        methods.add_method("getDuration", |_, this, ()| {
            Ok(this.inner.borrow().get_duration())
        });

        // -- getState --
        /// Returns the playback state as a string.
        /// @return | string | One of "stopped", "playing", "paused".
        methods.add_method("getState", |_, this, ()| {
            Ok(this.inner.borrow().get_state_str())
        });

        // -- isPlaying --
        /// Checks if the timeline is currently playing.
        /// @return | boolean | True if playing.
        methods.add_method("isPlaying", |_, this, ()| {
            Ok(this.inner.borrow().is_playing())
        });

        // -- isComplete --
        /// Checks if playback has reached the end.
        /// @return | boolean | True if complete.
        methods.add_method("isComplete", |_, this, ()| {
            Ok(this.inner.borrow().is_complete())
        });

        // -- addLabel --
        /// Registers a named time position for branching.
        /// @param | name | string | Label name.
        /// @param | time | number | Time in seconds.
        methods.add_method_mut("addLabel", |_, this, (name, time): (String, f32)| {
            this.inner.borrow_mut().add_label(name, time);
            Ok(())
        });

        // -- branch --
        /// Jumps playback to a named label position.
        /// @param | label | string | Label name to jump to.
        /// @return | boolean | True if label was found and jumped to.
        methods.add_method_mut("branch", |_, this, label: String| {
            Ok(this.inner.borrow_mut().branch(&label))
        });

        // -- type --
        /// Returns the Lua-visible type name.
        /// @return | string | Always `"LCinematicTimeline"`.
        methods.add_method("type", |_, _, ()| Ok("LCinematicTimeline"));

        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True when the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LCinematicTimeline" || name == "Object")
        });
    }
}

impl LuaUserData for LuaCinematic {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addCut(time, description) --
        /// Appends a timed cut to the cinematic timeline.
        /// @param | time | number | Time in seconds when the cut fires.
        /// @param | description | string | Human-readable cut label.
        methods.add_method_mut("addCut", |_, this, (time, desc): (f32, String)| {
            this.inner.borrow_mut().add_cut(time, desc);
            Ok(())
        });

        // -- play() --
        /// Plays back the timeline by firing all cuts in order.
        methods.add_method("play", |_, this, ()| {
            this.inner.borrow().play();
            Ok(())
        });

        // -- clear() --
        /// Removes all cuts from the timeline.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            Ok(())
        });

        // -- cutCount() --
        /// Returns the number of cuts in the timeline.
        /// @return | integer | Cut count.
        methods.add_method("cutCount", |_, this, ()| {
            Ok(this.inner.borrow().cuts().len() as i64)
        });

        // -- type() --
        /// Returns the Lua-visible type name.
        /// @return | string | Always `"LCinematic"`.
        methods.add_method("type", |_, _, ()| Ok("LCinematic"));

        // -- typeOf(name) --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check (e.g. `"LCinematic"`, `"Object"`).
        /// @return | boolean | True when the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LCinematic" || name == "Object")
        });
    }
}

/// Registers `lurek.cinematic` in the Lua environment.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // -- new() --
    /// Creates a new empty cinematic timeline handle (legacy cut-based API).
    /// @return | LCinematic | New cinematic handle.
    tbl.set(
        "new",
        lua.create_function(|lua, ()| {
            lua.create_userdata(LuaCinematic {
                inner: RefCell::new(Cinematic::new()),
            })
        })?,
    )?;

    // -- newTimeline() --
    /// Creates a new multi-track timeline for modern cinematic support.
    /// @return | LCinematicTimeline | New timeline handle.
    tbl.set(
        "newTimeline",
        lua.create_function(|_, ()| {
            Ok(LuaCinematicTimeline {
                inner: Rc::new(RefCell::new(CinematicTimeline::new())),
            })
        })?,
    )?;

    lurek.set("cinematic", tbl)?;
    Ok(())
}
