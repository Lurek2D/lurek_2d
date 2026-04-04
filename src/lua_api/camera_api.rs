//! Registers the `luna.camera` namespace.
//!
//! Provides Lua-level camera management: smooth follow, dead zone,
//! screen-shake, bounds clamping, and coordinate conversion via [`Camera2D`].
//!
//! This module is part of Luna2D's `lua_api` subsystem.
//! Key types exported: `LuaCamera2D`.
//! Primary functions: `register()`.

use std::cell::RefCell;
use std::rc::Rc;

use mlua::prelude::*;

use crate::camera::Camera2D;
use crate::lua_api::lua_types::{add_type_methods, LunaType};

// ── UserData wrapper ──────────────────────────────────────────────────────────

/// Lua UserData wrapper for a [`Camera2D`] instance.
///
/// # Fields
/// - `inner` — `Rc<RefCell<Camera2D>>`. Shared camera state.
#[derive(Clone)]
pub struct LuaCamera2D {
    /// Shared camera state.
    pub(crate) inner: Rc<RefCell<Camera2D>>,
}

impl LunaType for LuaCamera2D {
    const TYPE_NAME: &'static str = "Camera2D";
    const TYPE_HIERARCHY: &'static [&'static str] = &["Camera2D", "Object"];
}

impl LuaUserData for LuaCamera2D {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        add_type_methods::<Self>(methods);

        // ── Position / zoom / rotation ────────────────────────────────────

        /// Sets the camera's world-space position.
        /// @param x number
        /// @param y number
        methods.add_method("setPosition", |_, this, (x, y): (f32, f32)| {
            this.inner.borrow_mut().set_position(x, y);
            Ok(())
        });

        /// Returns the camera's world-space position as `x, y`.
        /// @return number, number
        methods.add_method("getPosition", |_, this, ()| {
            let (x, y) = this.inner.borrow().get_position();
            Ok((x, y))
        });

        /// Sets the uniform zoom factor (`1.0` = natural size).
        /// @param zoom number
        methods.add_method("setZoom", |_, this, zoom: f32| {
            this.inner.borrow_mut().set_zoom(zoom);
            Ok(())
        });

        /// Returns the current zoom factor.
        /// @return number
        methods.add_method("getZoom", |_, this, ()| {
            Ok(this.inner.borrow().get_zoom())
        });

        /// Sets the rotation in radians.
        /// @param r number
        methods.add_method("setRotation", |_, this, r: f32| {
            this.inner.borrow_mut().set_rotation(r);
            Ok(())
        });

        /// Returns the rotation in radians.
        /// @return number
        methods.add_method("getRotation", |_, this, ()| {
            Ok(this.inner.borrow().get_rotation())
        });

        // ── Viewport ──────────────────────────────────────────────────────

        /// Sets the viewport rectangle `(x, y, width, height)` in screen pixels.
        /// @param x number
        /// @param y number
        /// @param w number
        /// @param h number
        methods.add_method("setViewport", |_, this, (x, y, w, h): (f32, f32, f32, f32)| {
            this.inner.borrow_mut().set_viewport(x, y, w, h);
            Ok(())
        });

        /// Returns the current viewport as `x, y, w, h`.
        /// @return number, number, number, number
        methods.add_method("getViewport", |_, this, ()| {
            let (x, y, w, h) = this.inner.borrow().get_viewport();
            Ok((x, y, w, h))
        });

        // ── Bounds ────────────────────────────────────────────────────────

        /// Sets world-space bounds for camera clamping.
        /// @param x number
        /// @param y number
        /// @param w number
        /// @param h number
        methods.add_method("setBounds", |_, this, (x, y, w, h): (f32, f32, f32, f32)| {
            this.inner.borrow_mut().set_bounds(x, y, w, h);
            Ok(())
        });

        /// Removes previously set world-space bounds.
        methods.add_method("removeBounds", |_, this, ()| {
            this.inner.borrow_mut().remove_bounds();
            Ok(())
        });

        // ── Follow ────────────────────────────────────────────────────────

        /// Sets the follow target position.
        /// @param x number
        /// @param y number
        methods.add_method("setTarget", |_, this, (x, y): (f32, f32)| {
            this.inner.borrow_mut().set_target(x, y);
            Ok(())
        });

        /// Clears the follow target (camera stops tracking).
        methods.add_method("clearTarget", |_, this, ()| {
            this.inner.borrow_mut().target = None;
            Ok(())
        });

        /// Sets the follow smooth interpolation speed (`0.0` = instant snap).
        /// @param speed number
        methods.add_method("setFollowSmooth", |_, this, speed: f32| {
            this.inner.borrow_mut().set_follow_smooth(speed);
            Ok(())
        });

        /// Sets the dead zone half-extents `(w, h)`. The camera does not move
        /// while the target stays within this rectangle.
        /// @param w number
        /// @param h number
        methods.add_method("setDeadZone", |_, this, (w, h): (f32, f32)| {
            this.inner.borrow_mut().set_dead_zone(w, h);
            Ok(())
        });

        /// Sets the look-ahead multiplier.
        /// @param mul number
        methods.add_method("setLookAhead", |_, this, mul: f32| {
            this.inner.borrow_mut().set_look_ahead(mul);
            Ok(())
        });

        // ── Shake ─────────────────────────────────────────────────────────

        /// Starts a screen-shake effect.
        /// @param intensity number  Maximum pixel displacement.
        /// @param duration  number  Duration in seconds.
        methods.add_method("shake", |_, this, (intensity, duration): (f32, f32)| {
            this.inner.borrow_mut().shake(intensity, duration);
            Ok(())
        });

        // ── Update ────────────────────────────────────────────────────────

        /// Advances the camera simulation by `dt` seconds.
        ///
        /// Processes smooth follow, shake, and bounds clamping.
        /// @param dt number
        methods.add_method("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });

        // ── Coordinate conversion ─────────────────────────────────────────

        /// Converts screen coordinates to world coordinates.
        /// @param sx number
        /// @param sy number
        /// @return number, number
        methods.add_method("toWorld", |_, this, (sx, sy): (f32, f32)| {
            let (wx, wy) = this.inner.borrow().to_world_coords(sx, sy);
            Ok((wx, wy))
        });

        /// Converts world coordinates to screen coordinates.
        /// @param wx number
        /// @param wy number
        /// @return number, number
        methods.add_method("toScreen", |_, this, (wx, wy): (f32, f32)| {
            let (sx, sy) = this.inner.borrow().to_screen_coords(wx, wy);
            Ok((sx, sy))
        });

        /// Returns the visible world area as `x, y, w, h`.
        /// @return number, number, number, number
        methods.add_method("getVisibleArea", |_, this, ()| {
            let (x, y, w, h) = this.inner.borrow().get_visible_area();
            Ok((x, y, w, h))
        });

        /// Instantly moves the camera to look at `(x, y)`.
        /// @param x number
        /// @param y number
        methods.add_method("lookAt", |_, this, (x, y): (f32, f32)| {
            this.inner.borrow_mut().look_at(x, y);
            Ok(())
        });

        /// Translates the camera by `(dx, dy)` in world space.
        /// @param dx number
        /// @param dy number
        methods.add_method("move", |_, this, (dx, dy): (f32, f32)| {
            this.inner.borrow_mut().move_by(dx, dy);
            Ok(())
        });
    }
}

// ── Registration ──────────────────────────────────────────────────────────────

/// Registers the `luna.camera` namespace into the given `luna` table.
///
/// # Parameters
/// - `lua` — `&Lua`.
/// - `luna` — `&LuaTable`.
///
/// # Returns
/// `LuaResult<()>`.
pub fn register(lua: &Lua, luna: &LuaTable) -> LuaResult<()> {
    let camera_tbl = lua.create_table()?;

    /// Creates a new [`Camera2D`] with the given viewport dimensions.
    /// @param viewport_w number
    /// @param viewport_h number
    /// @return Camera2D
    camera_tbl.set(
        "new",
        lua.create_function(|_, (vw, vh): (f32, f32)| {
            Ok(LuaCamera2D {
                inner: Rc::new(RefCell::new(Camera2D::new(vw, vh))),
            })
        })?,
    )?;

    luna.set("camera", camera_tbl)?;
    Ok(())
}
