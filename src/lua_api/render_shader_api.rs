//! Registers shader construction and active-shader state for `lurek.render`.

use super::{
    ensure_shader_target, parse_shader_target_opts, LuaShader, RenderCommand, Shader, ShaderTarget,
    SharedState,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Register all public shader lifecycle and binding operations.
pub(super) fn register_shader_api(
    lua: &Lua,
    graphics: &LuaTable,
    state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    let s = state.clone();
    // -- newShader --
    /// Compiles a target-aware WGSL fragment shader through the render module and returns a shader handle.
    /// @param | code | string | WGSL fragment shader source.
    /// @param | opts | table? | Options table with optional `target` string: draw, postfx, image, overlay, particle, light, sprite, tilemap, mapviz, text, ui, or debugviz. Defaults to draw.
    /// @return | LShader | The compiled shader handle.
    graphics.set(
        "newShader",
        lua.create_function(move |_, (code, opts): (String, Option<LuaTable>)| {
            if s.borrow().active_mod_id.is_some() {
                return Err(LuaError::RuntimeError(
                    "lurek.render.newShader: untrusted mod/runtime shader text is not supported"
                        .into(),
                ));
            }
            let target = parse_shader_target_opts(opts)?;
            let shader = match Shader::new_for_target(code, target) {
                Ok(shader) => shader,
                Err(err) => {
                    let msg = format!("lurek.render.newShader: {err}");
                    s.borrow_mut().last_shader_compile_error = Some(msg.clone());
                    return Err(LuaError::RuntimeError(msg));
                }
            };
            let key = {
                let mut st = s.borrow_mut();
                st.last_shader_compile_error = None;
                st.shaders.insert(shader)
            };
            Ok(LuaShader {
                state: s.clone(),
                key,
            })
        })?,
    )?;
    let s = state.clone();
    // -- setShader --
    /// Activates a draw-target shader for subsequent draw calls, or restores the default with nil.
    /// @param | shader | LShader? | Draw-target shader handle or nil.
    graphics.set(
        "setShader",
        lua.create_function(move |_, ud: Option<LuaAnyUserData>| {
            let mut st = s.borrow_mut();
            match ud {
                Some(ud) => {
                    let shader = ud.borrow::<LuaShader>()?;
                    let key = shader.key;
                    drop(shader);
                    if !st.shaders.contains_key(key) {
                        return Err(LuaError::RuntimeError(
                            "lurek.render.setShader: shader handle is not valid".into(),
                        ));
                    }
                    ensure_shader_target(&st, key, ShaderTarget::Draw, "lurek.render.setShader")?;
                    st.active_shader = Some(key);
                    st.render_commands.push(RenderCommand::SetShader(Some(key)));
                }
                None => {
                    st.active_shader = None;
                    st.render_commands.push(RenderCommand::SetShader(None));
                }
            }
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getShader --
    /// Returns the currently active draw shader, or nil for the default.
    /// @return | LShader | The active shader handle.
    graphics.set(
        "getShader",
        lua.create_function(move |_, ()| {
            Ok(s.borrow().active_shader.map(|key| LuaShader {
                state: s.clone(),
                key,
            }))
        })?,
    )?;
    let s = state.clone();
    // -- setTextShader --
    /// Activates a text-target shader for font-atlas text, or restores default text rendering with nil.
    /// @param | shader | LShader? | Text-target shader handle or nil.
    graphics.set(
        "setTextShader",
        lua.create_function(move |_, ud: Option<LuaAnyUserData>| {
            let mut st = s.borrow_mut();
            match ud {
                Some(ud) => {
                    let shader = ud.borrow::<LuaShader>()?;
                    let key = shader.key;
                    drop(shader);
                    if !st.shaders.contains_key(key) {
                        return Err(LuaError::RuntimeError(
                            "lurek.render.setTextShader: shader handle is not valid".into(),
                        ));
                    }
                    ensure_shader_target(
                        &st,
                        key,
                        ShaderTarget::Text,
                        "lurek.render.setTextShader",
                    )?;
                    st.active_text_shader = Some(key);
                    st.render_commands
                        .push(RenderCommand::SetTextShader(Some(key)));
                }
                None => {
                    st.active_text_shader = None;
                    st.render_commands.push(RenderCommand::SetTextShader(None));
                }
            }
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getTextShader --
    /// Returns the active text shader, or nil when the default/fallback path is active.
    /// @return | LShader | The active text shader handle.
    graphics.set(
        "getTextShader",
        lua.create_function(move |_, ()| {
            Ok(s.borrow().active_text_shader.map(|key| LuaShader {
                state: s.clone(),
                key,
            }))
        })?,
    )?;
    let s = state.clone();
    // -- setDebugShader --
    /// Activates a debugviz-target shader, or restores the normal draw shader with nil.
    /// @param | shader | LShader? | Debug-target shader handle or nil.
    graphics.set(
        "setDebugShader",
        lua.create_function(move |_, ud: Option<LuaAnyUserData>| {
            let mut st = s.borrow_mut();
            match ud {
                Some(ud) => {
                    let shader = ud.borrow::<LuaShader>()?;
                    let key = shader.key;
                    drop(shader);
                    if !st.shaders.contains_key(key) {
                        return Err(LuaError::RuntimeError(
                            "lurek.render.setDebugShader: shader handle is not valid".into(),
                        ));
                    }
                    ensure_shader_target(
                        &st,
                        key,
                        ShaderTarget::DebugViz,
                        "lurek.render.setDebugShader",
                    )?;
                    st.active_debug_shader = Some(key);
                    st.render_commands.push(RenderCommand::SetShader(Some(key)));
                }
                None => {
                    st.active_debug_shader = None;
                    let restore_shader = st.active_shader;
                    st.render_commands
                        .push(RenderCommand::SetShader(restore_shader));
                }
            }
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getDebugShader --
    /// Returns the active debug shader, or nil when debug draws use the normal/default path.
    /// @return | LShader | The active debug shader handle.
    graphics.set(
        "getDebugShader",
        lua.create_function(move |_, ()| {
            Ok(s.borrow().active_debug_shader.map(|key| LuaShader {
                state: s.clone(),
                key,
            }))
        })?,
    )?;
    Ok(())
}
