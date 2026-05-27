//! `lurek.cursor` - Cursor appearance, system cursors, custom image cursors, animated cursors, and context-sensitive switching.
use super::SharedState;
use crate::cursor::{
    AnimatedCursor, CursorContext, CursorManager, CursorTrail, CursorZoom,
    CustomCursor, PulseConfig, SystemCursor, TrailMode,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

// ---------------------------------------------------------------------------
// Wrapper: LuaCursorManager
// ---------------------------------------------------------------------------

/// Lua userdata that controls cursor appearance and system cursor selection.
struct LuaCursorManager {
    inner: Rc<RefCell<CursorManager>>,
}

impl LuaUserData for LuaCursorManager {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Set the active cursor to a system cursor by name.
        /// @param | name | string | System cursor name (arrow, hand, crosshair, ibeam, wait, no, etc.).
        methods.add_method("setSystem", |_, this, name: String| {
            let cursor = SystemCursor::from_name(&name)
                .ok_or_else(|| LuaError::runtime(format!("unknown system cursor: {name}")))?;
            this.inner.borrow_mut().set_system(cursor);
            Ok(())
        });

        /// Set the active cursor to a custom image cursor.
        /// @param | cursor | LuaCustomCursor | Custom cursor object.
        methods.add_method("setCustom", |_, this, cursor: LuaAnyUserData| {
            let cursor = cursor.borrow::<LuaCustomCursor>()?.clone();
            this.inner.borrow_mut().set_custom(cursor.inner.borrow().clone());
            Ok(())
        });

        /// Set the active cursor to an animated cursor.
        /// @param | cursor | LuaAnimatedCursor | Animated cursor object.
        methods.add_method("setAnimated", |_, this, cursor: LuaAnyUserData| {
            let cursor = cursor.borrow::<LuaAnimatedCursor>()?.clone();
            this.inner.borrow_mut().set_animated(cursor.inner.borrow().clone());
            Ok(())
        });

        /// Set the current context for context-sensitive switching.
        /// @param | ctx | string | Context name (default, raycaster, globe, tilemap, ui_button, etc.).
        methods.add_method("setContext", |_, this, ctx: String| {
            this.inner.borrow_mut().set_context(CursorContext::from_name(&ctx));
            Ok(())
        });

        /// Add a context rule that maps a context to a system cursor.
        /// @param | ctx | string | Context name.
        /// @param | cursor_name | string | System cursor name.
        methods.add_method("addRule", |_, this, (ctx, cursor_name): (String, String)| {
            let cursor = SystemCursor::from_name(&cursor_name)
                .ok_or_else(|| LuaError::runtime(format!("unknown system cursor: {cursor_name}")))?;
            use crate::cursor::context::{ContextRule, CursorState};
            this.inner.borrow_mut().add_rule(ContextRule {
                context: CursorContext::from_name(&ctx),
                cursor: CursorState::System(cursor),
            });
            Ok(())
        });

        /// Remove a context rule for this object.
        /// @param | ctx | string | Context name to remove.
        methods.add_method("removeRule", |_, this, ctx: String| {
            this.inner.borrow_mut().remove_rule(&CursorContext::from_name(&ctx));
            Ok(())
        });

        /// Update cursor state (call each frame).
        /// @param | x | number | Cursor X position.
        /// @param | y | number | Cursor Y position.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method("update", |_, this, (x, y, dt): (f32, f32, f32)| {
            this.inner.borrow_mut().update(x, y, dt);
            Ok(())
        });

        /// Set cursor visibility for this object.
        /// @param | visible | boolean | Whether the cursor is visible.
        methods.add_method("setVisible", |_, this, visible: bool| {
            this.inner.borrow_mut().set_visible(visible);
            Ok(())
        });

        /// Get cursor visibility for this object.
        /// @return | boolean | Whether the cursor is visible.
        methods.add_method("isVisible", |_, this, ()| {
            Ok(this.inner.borrow().is_visible())
        });

        /// Lock the cursor position using the system grab mode.
        /// @param | locked | boolean | Whether the cursor is locked.
        methods.add_method("setLocked", |_, this, locked: bool| {
            this.inner.borrow_mut().set_locked(locked);
            Ok(())
        });

        /// Get cursor lock state for this object.
        /// @return | boolean | Whether the cursor is locked.
        methods.add_method("isLocked", |_, this, ()| {
            Ok(this.inner.borrow().is_locked())
        });

        /// Get cursor position for this object.
        /// @return | number | X position.
        /// @return | number | Y position.
        methods.add_method("getPosition", |_, this, ()| {
            let (x, y) = this.inner.borrow().position();
            Ok((x, y))
        });

        /// Get current context name for this object.
        /// @return | string | Active context name.
        methods.add_method("getContext", |_, this, ()| {
            Ok(this.inner.borrow().context().as_str().to_string())
        });

        /// Enable cursor trail with fade points mode.
        /// @param | r | number | Red (0-1).
        /// @param | g | number | Green (0-1).
        /// @param | b | number | Blue (0-1).
        /// @param | lifetime | number | Seconds before trail fades.
        methods.add_method("enableTrail", |_, this, (r, g, b, lifetime): (f32, f32, f32, f32)| {
            let trail = CursorTrail::new(TrailMode::FadePoints {
                color: [r, g, b, 1.0],
                lifetime,
            });
            this.inner.borrow_mut().set_trail(Some(trail));
            Ok(())
        });

        /// Enable cursor trail with line mode.
        /// @param | r | number | Red (0-1).
        /// @param | g | number | Green (0-1).
        /// @param | b | number | Blue (0-1).
        /// @param | width | number | Line width in pixels.
        methods.add_method("enableLineTrail", |_, this, (r, g, b, width): (f32, f32, f32, f32)| {
            let trail = CursorTrail::new(TrailMode::Line {
                color: [r, g, b, 1.0],
                width,
                fade: true,
            });
            this.inner.borrow_mut().set_trail(Some(trail));
            Ok(())
        });

        /// Disable cursor trail for this object.
        methods.add_method("disableTrail", |_, this, ()| {
            this.inner.borrow_mut().set_trail(None);
            Ok(())
        });

        /// Enable zoom/magnifier at cursor position.
        /// @param | magnification | number | Zoom factor (1-10).
        /// @param | radius | number | Lens radius in pixels.
        methods.add_method("enableZoom", |_, this, (mag, radius): (f32, f32)| {
            this.inner.borrow_mut().set_zoom(Some(CursorZoom::new(mag, radius)));
            Ok(())
        });

        /// Disable cursor zoom for this object.
        methods.add_method("disableZoom", |_, this, ()| {
            this.inner.borrow_mut().set_zoom(None);
            Ok(())
        });
    }
}

// ---------------------------------------------------------------------------
// Wrapper: LuaCustomCursor
// ---------------------------------------------------------------------------

/// Lua userdata representing a custom-drawn cursor image with a configurable hot-spot.
#[derive(Clone)]
struct LuaCustomCursor {
    inner: Rc<RefCell<CustomCursor>>,
}

impl LuaUserData for LuaCustomCursor {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Set a pixel color — Lua userdata object exposed by the engine.
        /// @param | x | integer | X coordinate.
        /// @param | y | integer | Y coordinate.
        /// @param | r | integer | Red (0-255).
        /// @param | g | integer | Green (0-255).
        /// @param | b | integer | Blue (0-255).
        /// @param | a | integer | Alpha (0-255).
        methods.add_method("setPixel", |_, this, (x, y, r, g, b, a): (u32, u32, u8, u8, u8, u8)| {
            this.inner.borrow_mut().set_pixel(x, y, r, g, b, a);
            Ok(())
        });

        /// Get the pixel color at the specified cursor image position.
        /// @param | x | integer | X coordinate.
        /// @param | y | integer | Y coordinate.
        /// @return | integer | Red.
        /// @return | integer | Green.
        /// @return | integer | Blue.
        /// @return | integer | Alpha.
        methods.add_method("getPixel", |_, this, (x, y): (u32, u32)| {
            match this.inner.borrow().get_pixel(x, y) {
                Some((r, g, b, a)) => Ok((r, g, b, a)),
                None => Err(LuaError::runtime("pixel out of bounds")),
            }
        });

        /// Get the pixel width and height of the cursor image.
        /// @return | integer | Width.
        /// @return | integer | Height.
        methods.add_method("getSize", |_, this, ()| {
            let (w, h) = this.inner.borrow().size();
            Ok((w, h))
        });

        /// Get hotspot position for this object.
        /// @return | integer | Hotspot X.
        /// @return | integer | Hotspot Y.
        methods.add_method("getHotspot", |_, this, ()| {
            let c = this.inner.borrow();
            Ok((c.hotspot_x, c.hotspot_y))
        });
    }
}

// ---------------------------------------------------------------------------
// Wrapper: LuaAnimatedCursor
// ---------------------------------------------------------------------------

/// Lua userdata representing an animated cursor that cycles through image frames.
#[derive(Clone)]
struct LuaAnimatedCursor {
    inner: Rc<RefCell<AnimatedCursor>>,
}

impl LuaUserData for LuaAnimatedCursor {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Add a frame from a custom cursor image.
        /// @param | cursor | LuaCustomCursor | Frame image.
        /// @param | duration_ms | integer | Frame duration in milliseconds.
        methods.add_method("addFrame", |_, this, (cursor, dur): (LuaAnyUserData, u32)| {
            let cursor = cursor.borrow::<LuaCustomCursor>()?.clone();
            let img = cursor.inner.borrow().clone();
            this.inner.borrow_mut().add_frame(img, dur);
            Ok(())
        });

        /// Update animation (call each frame).
        /// @param | dt | number | Delta time in seconds.
        methods.add_method("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });

        /// Get current frame index for this object.
        /// @return | integer | Zero-based frame index.
        methods.add_method("currentIndex", |_, this, ()| {
            Ok(this.inner.borrow().current_index())
        });

        /// Get total frame count for this object.
        /// @return | integer | Number of frames.
        methods.add_method("frameCount", |_, this, ()| {
            Ok(this.inner.borrow().frame_count())
        });

        /// Get current scale from pulse animation.
        /// @return | number | Current scale factor.
        methods.add_method("currentScale", |_, this, ()| {
            Ok(this.inner.borrow().current_scale())
        });

        /// Set the pulse animation speed and scale factor parameters.
        /// @param | min_scale | number | Minimum scale.
        /// @param | max_scale | number | Maximum scale.
        /// @param | speed | number | Pulse speed.
        methods.add_method("setPulse", |_, this, (min_s, max_s, speed): (f32, f32, f32)| {
            this.inner.borrow_mut().set_pulse(Some(PulseConfig {
                min_scale: min_s,
                max_scale: max_s,
                speed,
            }));
            Ok(())
        });

        /// Disable pulse animation for this object.
        methods.add_method("clearPulse", |_, this, ()| {
            this.inner.borrow_mut().set_pulse(None);
            Ok(())
        });

        /// Reset the cursor animation playback to the first frame.
        methods.add_method("reset", |_, this, ()| {
            this.inner.borrow_mut().reset();
            Ok(())
        });
    }
}

// ---------------------------------------------------------------------------
// Register
// ---------------------------------------------------------------------------

/// Register the `lurek.cursor` module.
///
/// ## Functions (see lurek Lua API reference for details).
///
/// ### newManager (see lurek Lua API reference for details).
/// Create a new cursor manager exposed by the lurek engine.
/// @return | LuaCursorManager | Cursor manager instance.
///
/// ### newCustom (see lurek Lua API reference for details).
/// Create a blank custom cursor image.
/// @param | width | integer | Image width in pixels.
/// @param | height | integer | Image height in pixels.
/// @param | hotspot_x | integer | Hotspot X offset.
/// @param | hotspot_y | integer | Hotspot Y offset.
/// @return | LuaCustomCursor | Custom cursor instance.
///
/// ### newAnimated (see lurek Lua API reference for details).
/// Create a new animated cursor exposed by the lurek engine.
/// @param | looping | boolean | Whether the animation loops.
/// @return | LuaAnimatedCursor | Animated cursor instance.
///
/// ### systemCursors (see lurek Lua API reference for details).
/// Get list of available system cursor names.
/// @return | table | Array of cursor name strings.
pub fn register<'lua>(lua: &'lua Lua, _state: &SharedState) -> LuaResult<LuaTable<'lua>> {
    let module = lua.create_table()?;

    /// Creates a new cursor manager for handling cursor state and visibility.
    ///
    /// @return | LCursorManager | A new cursor manager instance.
    module.set(
        "newManager",
        lua.create_function(|_, ()| {
            Ok(LuaCursorManager {
                inner: Rc::new(RefCell::new(CursorManager::new())),
            })
        })?,
    )?;

    /// Creates a new custom cursor with specified dimensions and hotspot position.
    ///
    /// @param | w | integer | Width of the cursor image in pixels.
    /// @param | h | integer | Height of the cursor image in pixels.
    /// @param | hx | integer | Hotspot X offset from cursor origin.
    /// @param | hy | integer | Hotspot Y offset from cursor origin.
    /// @return | LCustomCursor | A new custom cursor instance.
    module.set(
        "newCustom",
        lua.create_function(|_, (w, h, hx, hy): (u32, u32, u32, u32)| {
            Ok(LuaCustomCursor {
                inner: Rc::new(RefCell::new(CustomCursor::new(w, h, hx, hy))),
            })
        })?,
    )?;

    /// Creates a new animated cursor that can cycle through frames.
    ///
    /// @param | looping | boolean | Whether the animation loops continuously.
    /// @return | LAnimatedCursor | A new animated cursor instance.
    module.set(
        "newAnimated",
        lua.create_function(|_, looping: bool| {
            Ok(LuaAnimatedCursor {
                inner: Rc::new(RefCell::new(AnimatedCursor::new(looping))),
            })
        })?,
    )?;

    /// Returns a list of all available system cursor names as a string array.
    ///
    /// @return | table | Array of system cursor name strings.
    module.set(
        "systemCursors",
        lua.create_function(|lua, ()| {
            let names = vec![
                "arrow", "ibeam", "wait", "crosshair", "wait_arrow",
                "size_nwse", "size_nesw", "size_we", "size_ns", "size_all",
                "no", "hand",
            ];
            let tbl = lua.create_table()?;
            for (i, name) in names.iter().enumerate() {
                tbl.set(i + 1, *name)?;
            }
            Ok(tbl)
        })?,
    )?;

    Ok(module)
}
