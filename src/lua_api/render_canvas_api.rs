//! Registers canvas lifecycle constructors for the canonical render table.

use super::{
    ensure_shader_target, postfx_passes_from_userdata, shader_key_from_userdata, Canvas, LuaCanvas,
    PostFxPass, RenderCommand, ShaderTarget, SharedState,
};
use mlua::prelude::*;
use slotmap::Key;
use std::cell::RefCell;
use std::rc::Rc;

/// Register canvas lifecycle and post-processing operations.
pub(super) fn register_canvas_api(
    lua: &Lua,
    graphics: &LuaTable,
    state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    let s = state.clone();
    // -- newCanvas --
    /// Creates a new off-screen render target with the given dimensions.
    /// @param | width | integer | Canvas width in pixels (must be > 0).
    /// @param | height | integer | Canvas height in pixels (must be > 0).
    /// @return | LCanvas | The created canvas handle.
    graphics.set(
        "newCanvas",
        lua.create_function(move |_, (width, height): (u32, u32)| {
            if width == 0 || height == 0 {
                return Err(LuaError::RuntimeError(
                    "lurek.render.newCanvas: width and height must be greater than zero".into(),
                ));
            }
            let mut st = s.borrow_mut();
            let canvas_bytes = u64::from(width).saturating_mul(u64::from(height)).saturating_mul(4);
            if !st.can_allocate_public_resource(canvas_bytes) {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.render.newCanvas: canvas allocation of {canvas_bytes} bytes exceeds the configured resource budget"
                )));
            }
            let key = st.canvases.insert(Canvas::new(width, height));
            st.render_commands.push(RenderCommand::RegisterCanvas { canvas_key: key, width, height });
            Ok(LuaCanvas { state: s.clone(), key })
        })?,
    )?;
    let s = state.clone();
    // -- resetCanvas --
    /// Marks a canvas as needing a full clear before its next render pass.
    /// @param | canvas | LCanvas | Canvas to reset.
    /// @return | nil | No return value.
    graphics.set(
        "resetCanvas",
        lua.create_function(move |_, ud: LuaAnyUserData| {
            let canvas = ud.borrow::<LuaCanvas>()?;
            let key = canvas.key;
            drop(canvas);
            let mut st = s.borrow_mut();
            if !st.canvases.contains_key(key) {
                return Err(LuaError::RuntimeError(
                    "lurek.render.resetCanvas: canvas handle is not valid".into(),
                ));
            }
            st.render_commands.push(RenderCommand::ResetCanvas(key));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- setCanvas --
    /// Redirects subsequent drawing to a canvas, or nil for the screen.
    graphics.set(
        "setCanvas",
        lua.create_function(move |_, ud: Option<LuaAnyUserData>| {
            let mut st = s.borrow_mut();
            if let Some(ud) = ud {
                let canvas = ud.borrow::<LuaCanvas>()?;
                let key = canvas.key;
                drop(canvas);
                if !st.canvases.contains_key(key) {
                    return Err(LuaError::RuntimeError(
                        "lurek.render.setCanvas: canvas handle is not valid".into(),
                    ));
                }
                st.active_canvas = Some(key);
                st.render_commands.push(RenderCommand::SetCanvas(Some(key)));
            } else {
                st.active_canvas = None;
                st.render_commands.push(RenderCommand::SetCanvas(None));
            }
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getCanvas --
    /// Returns the active canvas, or nil when drawing to the screen.
    graphics.set(
        "getCanvas",
        lua.create_function(move |_, ()| {
            Ok(s.borrow().active_canvas.map(|key| LuaCanvas {
                state: s.clone(),
                key,
            }))
        })?,
    )?;
    let s = state.clone();
    // -- getCanvasSize --
    /// Returns the pixel dimensions of a canvas.
    graphics.set(
        "getCanvasSize",
        lua.create_function(move |_, ud: LuaAnyUserData| {
            let canvas = ud.borrow::<LuaCanvas>()?;
            let key = canvas.key;
            drop(canvas);
            let st = s.borrow();
            let canvas = st.canvases.get(key).ok_or_else(|| {
                LuaError::RuntimeError(
                    "lurek.render.getCanvasSize: canvas handle is not valid".into(),
                )
            })?;
            Ok((canvas.width, canvas.height))
        })?,
    )?;
    let s = state.clone();
    // -- applyShaderToCanvas --
    /// Queues a postfx shader pass that mutates a canvas after queued draws in the current frame.
    /// @param | canvas | LCanvas | Canvas render target to process.
    /// @param | shader | LShader | Shader created with the `postfx` target.
    /// @param | opts | table? | Reserved options table for future pass parameters.
    /// @return | LCanvas | The processed canvas handle.
    graphics.set(
        "applyShaderToCanvas",
        lua.create_function(
            move |_,
                  (canvas_ud, shader_ud, _opts): (
                LuaAnyUserData,
                LuaAnyUserData,
                Option<LuaTable>,
            )| {
                let canvas = canvas_ud.borrow::<LuaCanvas>()?;
                let canvas_key = canvas.key;
                drop(canvas);
                let shader_key = shader_key_from_userdata(&shader_ud)?;
                let mut st = s.borrow_mut();
                if !st.canvases.contains_key(canvas_key) {
                    return Err(LuaError::RuntimeError(
                        "lurek.render.applyShaderToCanvas: canvas handle is not valid".into(),
                    ));
                }
                ensure_shader_target(
                    &st,
                    shader_key,
                    ShaderTarget::PostFx,
                    "lurek.render.applyShaderToCanvas",
                )?;
                let shader_id = shader_key.data().as_ffi() as usize;
                st.render_commands.push(RenderCommand::ApplyShaderToCanvas {
                    canvas_key,
                    passes: vec![PostFxPass {
                        effect_name: format!("canvas_shader_{shader_id}"),
                        params: std::collections::HashMap::new(),
                        shader_id: Some(shader_id),
                        auto_uniforms: true,
                    }],
                });
                Ok(LuaCanvas {
                    state: s.clone(),
                    key: canvas_key,
                })
            },
        )?,
    )?;
    let s = state.clone();
    // -- applyEffectToCanvas --
    /// Applies a post-processing effect or stack from one canvas into another canvas.
    /// @param | sourceCanvas | LCanvas | Canvas used as the source texture.
    /// @param | targetCanvas | LCanvas | Canvas receiving the processed output.
    /// @param | effectOrStack | LPostFxEffect|LPostFxStack | Effect or stack created through `lurek.effect`.
    /// @return | LCanvas | The target canvas handle.
    graphics.set(
        "applyEffectToCanvas",
        lua.create_function(
            move |_,
                  (source_ud, target_ud, effect_ud): (
                LuaAnyUserData,
                LuaAnyUserData,
                LuaAnyUserData,
            )| {
                let source = source_ud.borrow::<LuaCanvas>()?;
                let source_canvas_key = source.key;
                drop(source);
                let target = target_ud.borrow::<LuaCanvas>()?;
                let target_canvas_key = target.key;
                drop(target);
                let passes = {
                    let st = s.borrow();
                    if !st.canvases.contains_key(source_canvas_key) {
                        return Err(LuaError::RuntimeError(
                            "lurek.render.applyEffectToCanvas: source canvas handle is not valid"
                                .into(),
                        ));
                    }
                    if !st.canvases.contains_key(target_canvas_key) {
                        return Err(LuaError::RuntimeError(
                            "lurek.render.applyEffectToCanvas: target canvas handle is not valid"
                                .into(),
                        ));
                    }
                    postfx_passes_from_userdata(&st, &effect_ud, "applyEffectToCanvas")?
                };
                if !passes.is_empty() {
                    s.borrow_mut()
                        .render_commands
                        .push(RenderCommand::ApplyEffectToCanvas {
                            source_canvas_key,
                            target_canvas_key,
                            passes,
                        });
                }
                Ok(LuaCanvas {
                    state: s.clone(),
                    key: target_canvas_key,
                })
            },
        )?,
    )?;
    Ok(())
}
