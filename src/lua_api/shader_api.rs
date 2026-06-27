//! Registers the `lurek.shader` Lua API for target-aware WGSL shader handles.
//!
//! The shader namespace is a thin public constructor layer over the shared render
//! shader store. Rendering modules decide where validated shader targets may be
//! bound; this file only parses options, constructs shaders, and returns handles.

use super::render_api::LuaShader;
use super::SharedState;
use crate::render::{Shader, ShaderTarget};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;
use std::str::FromStr;

fn parse_shader_target(opts: Option<LuaTable>) -> LuaResult<ShaderTarget> {
    let Some(opts) = opts else {
        return Ok(ShaderTarget::Draw);
    };
    match opts.get::<_, Option<String>>("target")? {
        Some(target) => ShaderTarget::from_str(&target)
            .map_err(|err| LuaError::RuntimeError(format!("lurek.shader.new: {err}"))),
        None => Ok(ShaderTarget::Draw),
    }
}

/// Registers the `lurek.shader` constructor table.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let s = state.clone();
    // -- new --
    /// Compiles a target-aware WGSL fragment shader and returns a shader handle.
    /// @param | code | string | WGSL fragment shader source code.
    /// @param | opts | table? | Options table with optional `target` string.
    /// @return | LShader | Compiled shader handle.
    tbl.set(
        "new",
        lua.create_function(move |_, (code, opts): (String, Option<LuaTable>)| {
            let target = parse_shader_target(opts)?;
            let shader = match Shader::new_for_target(code, target) {
                Ok(shader) => shader,
                Err(err) => {
                    let msg = format!("lurek.shader.new: {}", err);
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
    lurek.set("shader", tbl)?;
    Ok(())
}
