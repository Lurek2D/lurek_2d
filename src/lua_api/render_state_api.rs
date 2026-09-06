//! Registers transform-stack state operations for the canonical `lurek.render` table.

use super::{Rect, RenderCommand, SharedState};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Register transform-stack state transitions. Other state families extend this module.
pub(super) fn register_state_api(
    lua: &Lua,
    graphics: &LuaTable,
    state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    let s = state.clone();
    // -- push --
    /// Pushes the current transformation matrix onto the transform stack.
    graphics.set(
        "push",
        lua.create_function(move |_, ()| {
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::PushTransform);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- pop --
    /// Pops the top transformation matrix from the transform stack, restoring the previous one.
    graphics.set(
        "pop",
        lua.create_function(move |_, ()| {
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::PopTransform);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- translate --
    /// Applies a translation to the current transformation matrix.
    /// @param | x | number | Horizontal translation in pixels.
    /// @param | y | number | Vertical translation in pixels.
    graphics.set(
        "translate",
        lua.create_function(move |_, (x, y): (f32, f32)| {
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::Translate { x, y });
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- rotate --
    /// Applies a rotation to the current transformation matrix.
    /// @param | angle | number | Rotation angle in radians.
    graphics.set(
        "rotate",
        lua.create_function(move |_, angle: f32| {
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::Rotate { angle });
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- scale --
    /// Applies scaling to the current transformation matrix.
    /// @param | sx | number | Horizontal scale factor.
    /// @param | sy | number? | Vertical scale factor (defaults to sx for uniform scaling).
    graphics.set(
        "scale",
        lua.create_function(move |_, (sx, sy): (f32, Option<f32>)| {
            s.borrow_mut().render_commands.push(RenderCommand::Scale {
                sx,
                sy: sy.unwrap_or(sx),
            });
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- shear --
    /// Applies a shear (skew) to the current transformation matrix.
    /// @param | kx | number | Horizontal shear factor.
    /// @param | ky | number | Vertical shear factor.
    graphics.set(
        "shear",
        lua.create_function(move |_, (kx, ky): (f32, f32)| {
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::Shear { kx, ky });
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- origin --
    /// Resets the current transformation matrix to the identity (no transform).
    graphics.set(
        "origin",
        lua.create_function(move |_, ()| {
            s.borrow_mut().render_commands.push(RenderCommand::Origin);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- applyTransform --
    /// Multiplies the current transformation matrix by a 3x3 matrix (9 values in row-major order).
    /// @param | mat | table | Flat table of 9 numbers representing a 3x3 transform matrix.
    graphics.set(
        "applyTransform",
        lua.create_function(move |_, mat: LuaTable| {
            let mut matrix = [0.0f32; 9];
            for (index, value) in matrix.iter_mut().enumerate() {
                *value = mat.get::<_, f32>(index + 1).unwrap_or(
                    if index == 0 || index == 4 || index == 8 {
                        1.0
                    } else {
                        0.0
                    },
                );
            }
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::ApplyTransform { matrix });
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- setScissor --
    /// Sets or clears the scissor rectangle. Only pixels inside this region are drawn. Call with no args to clear.
    /// @param | x | number? | Left edge of the scissor rectangle.
    /// @param | y | number? | Top edge.
    /// @param | w | number? | Width.
    /// @param | h | number? | Height.
    graphics.set(
        "setScissor",
        lua.create_function(move |_, args: LuaMultiValue| {
            let mut state = s.borrow_mut();
            if args.len() >= 4 {
                let to_f32 = |value: &LuaValue| match value {
                    LuaValue::Number(value) => *value as f32,
                    LuaValue::Integer(value) => *value as f32,
                    _ => 0.0,
                };
                let rect = (
                    to_f32(&args[0]),
                    to_f32(&args[1]),
                    to_f32(&args[2]),
                    to_f32(&args[3]),
                );
                state.scissor = Some(rect);
                state
                    .render_commands
                    .push(RenderCommand::SetScissor(Some(rect)));
            } else {
                state.scissor = None;
                state.render_commands.push(RenderCommand::SetScissor(None));
            }
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getScissor --
    /// Returns the current scissor rectangle, or nothing if no scissor is set.
    /// @return | number, number, number, number | x, y, w, h of the scissor rect (empty if none).
    graphics.set(
        "getScissor",
        lua.create_function(move |_, ()| {
            Ok(match s.borrow().scissor {
                Some((x, y, width, height)) => LuaMultiValue::from_vec(vec![
                    LuaValue::Number(x as f64),
                    LuaValue::Number(y as f64),
                    LuaValue::Number(width as f64),
                    LuaValue::Number(height as f64),
                ]),
                None => LuaMultiValue::new(),
            })
        })?,
    )?;
    let s = state.clone();
    // -- intersectScissor --
    /// Intersects the given rectangle with the current scissor, narrowing the drawable region.
    /// @param | x | number | Left edge.
    /// @param | y | number | Top edge.
    /// @param | w | number | Width.
    /// @param | h | number | Height.
    graphics.set(
        "intersectScissor",
        lua.create_function(move |_, (x, y, width, height): (f32, f32, f32, f32)| {
            let mut state = s.borrow_mut();
            let incoming = Rect::new(x, y, width, height);
            let scissor = state
                .scissor
                .map(|(x, y, width, height)| Rect::new(x, y, width, height).intersect(&incoming))
                .map(|rect| (rect.x, rect.y, rect.width, rect.height))
                .or(Some((x, y, width, height)));
            state.scissor = scissor;
            state
                .render_commands
                .push(RenderCommand::SetScissor(scissor));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- setColorMask --
    /// Sets which color channels are written during draw calls. Call with no args to enable all.
    /// @param | args | any... | Up to four booleans for red, green, blue, and alpha.
    graphics.set(
        "setColorMask",
        lua.create_function(move |_, args: LuaMultiValue| {
            let mut state = s.borrow_mut();
            let mask = if args.len() >= 4 {
                let enabled = |value: &LuaValue| matches!(value, LuaValue::Boolean(true));
                (
                    enabled(&args[0]),
                    enabled(&args[1]),
                    enabled(&args[2]),
                    enabled(&args[3]),
                )
            } else {
                (true, true, true, true)
            };
            state.color_mask = mask;
            state
                .render_commands
                .push(RenderCommand::SetColorMask(mask.0, mask.1, mask.2, mask.3));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getColorMask --
    /// Returns the current color write mask.
    /// @return | boolean, boolean, boolean, boolean | Red, green, blue, alpha channel write states.
    graphics.set(
        "getColorMask",
        lua.create_function(move |_, ()| Ok(s.borrow().color_mask))?,
    )?;
    let s = state.clone();
    // -- setWireframe --
    /// Enables or disables wireframe rendering mode.
    /// @param | enabled | boolean | True for wireframe, false for solid.
    graphics.set(
        "setWireframe",
        lua.create_function(move |_, enabled: bool| {
            let mut state = s.borrow_mut();
            state.wireframe = enabled;
            state
                .render_commands
                .push(RenderCommand::SetWireframe(enabled));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- isWireframe --
    /// Returns whether wireframe rendering is currently active.
    /// @return | boolean | True if wireframe mode is on.
    graphics.set(
        "isWireframe",
        lua.create_function(move |_, ()| Ok(s.borrow().wireframe))?,
    )?;
    Ok(())
}
