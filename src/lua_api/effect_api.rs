//! `lurek.effect` -- Visual effect bindings for post-processing passes, effect stacks, and image effect chains used by the renderer command queue.
//!
//! - Registers `lurek.effect.*` functions and types via `register()`.
//! - `LuaPostFxEffect`: userdata type exposed to Lua.
//! - `LuaPostFxStack`: userdata type exposed to Lua.
//! - `LuaImageEffect`: userdata type exposed to Lua.

use super::SharedState;
use crate::effect::{
    presets::{build_preset, preset_names}, ImageEffect, PostFxEffect, PostFxEffectType, PostFxStack,
};
use crate::render::renderer::{PostFxPass, RenderCommand};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;
use std::sync::atomic::{AtomicU64, Ordering};
static NEXT_STACK_ID: AtomicU64 = AtomicU64::new(1);
/// Lua-side handle for a single post-processing effect instance.
pub struct LuaPostFxEffect {
    /// Shared effect state so image effects and stacks can reference the same effect.
    inner: Rc<RefCell<PostFxEffect>>,
}
impl LuaPostFxEffect {
    /// Wraps an owned post-processing effect in shared Lua state.
    fn from_owned(e: PostFxEffect) -> Self {
        Self {
            inner: Rc::new(RefCell::new(e)),
        }
    }
    /// Wraps an existing shared post-processing effect handle.
    fn from_rc(rc: Rc<RefCell<PostFxEffect>>) -> Self {
        Self { inner: rc }
    }
}
/// Provides Lua methods for querying and editing post-processing effect parameters.
impl LuaUserData for LuaPostFxEffect {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getTypeName --
        /// Returns the built-in or custom effect type name.
        /// @return | string | Effect type name used by the renderer.
        methods.add_method("getTypeName", |_, this, ()| {
            Ok(this.inner.borrow().get_type_name().to_string())
        });
        // -- isBuiltIn --
        /// Returns whether this effect uses one of the engine built-in effect types.
        /// @return | boolean | True for built-in effects, false for custom shader effects.
        methods.add_method("isBuiltIn", |_, this, ()| {
            Ok(this.inner.borrow().is_built_in())
        });
        // -- isEnabled --
        /// Returns whether this effect is enabled on its owning effect object.
        /// @return | boolean | Current enabled flag stored on the effect.
        methods.add_method("isEnabled", |_, this, ()| Ok(this.inner.borrow().enabled));
        // -- setEnabled --
        /// Enables or disables this effect. This method is available to Lua scripts.
        /// @param | enabled | boolean | New enabled flag.
        methods.add_method_mut("setEnabled", |_, this, enabled: bool| {
            this.inner.borrow_mut().enabled = enabled;
            Ok(())
        });
        // -- setParameter --
        /// Sets a numeric shader parameter by name.
        /// @param | name | string | Parameter name expected by the effect shader.
        /// @param | value | number | Numeric parameter value.
        methods.add_method_mut("setParameter", |_, this, (name, value): (String, f32)| {
            this.inner.borrow_mut().set_parameter(name, value);
            Ok(())
        });
        // -- getParameter --
        /// Reads a numeric shader parameter and falls back to a default value when missing.
        /// @param | name | string | Parameter name to read.
        /// @param | default | number? | Default value returned when the parameter is absent.
        /// @return | number | Stored parameter value or the supplied default.
        methods.add_method(
            "getParameter",
            |_, this, (name, default): (String, Option<f32>)| {
                Ok(this
                    .inner
                    .borrow()
                    .get_parameter(&name, default.unwrap_or(0.0)))
            },
        );
        // -- hasParameter --
        /// Returns whether a shader parameter exists on this effect.
        /// @param | name | string | Parameter name to check.
        /// @return | boolean | True when the parameter is present.
        methods.add_method("hasParameter", |_, this, name: String| {
            Ok(this.inner.borrow().has_parameter(&name))
        });
        // -- getParameterNames --
        /// Returns the parameter names stored on this effect.
        /// @return | string[] | Parameter name strings.
        methods.add_method("getParameterNames", |_, this, ()| {
            Ok(this.inner.borrow().get_parameter_names())
        });
        // -- getEffectType --
        /// Returns the renderer effect type name.
        /// @return | string | Effect type name used by the renderer.
        methods.add_method("getEffectType", |_, this, ()| {
            Ok(this.inner.borrow().get_type_name())
        });
        // -- getType --
        /// Returns the renderer effect type name.
        /// @return | string | Effect type name used by the renderer.
        methods.add_method("getType", |_, this, ()| {
            Ok(this.inner.borrow().get_type_name())
        });
        // -- type --
        /// Returns the Lua-visible type name for this post-processing effect handle.
        /// @return | string | The string `LPostFxEffect`.
        methods.add_method("type", |_, _, ()| Ok("LPostFxEffect"));
        // -- typeOf --
        /// Returns whether this effect handle matches a supported type name.
        /// @param | name | string | Type name to compare against `PostFxEffect` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LPostFxEffect" || name == "LObject")
        });
        // -- setThreshold --
        /// Sets the threshold shader parameter on this effect.
        /// @param | v | number | Threshold value passed to the effect shader.
        methods.add_method_mut("setThreshold", |_, this, v: f32| {
            this.inner.borrow_mut().set_parameter("threshold", v);
            Ok(())
        });
        // -- setIntensity --
        /// Sets the intensity shader parameter on this effect.
        /// @param | v | number | Intensity value passed to the effect shader.
        methods.add_method_mut("setIntensity", |_, this, v: f32| {
            this.inner.borrow_mut().set_parameter("intensity", v);
            Ok(())
        });
        // -- setRadius --
        /// Sets the radius shader parameter on this effect.
        /// @param | v | number | Radius value passed to the effect shader.
        methods.add_method_mut("setRadius", |_, this, v: f32| {
            this.inner.borrow_mut().set_parameter("radius", v);
            Ok(())
        });
        // -- setStrength --
        /// Sets the strength shader parameter on this effect.
        /// @param | v | number | Strength value passed to the effect shader.
        methods.add_method_mut("setStrength", |_, this, v: f32| {
            this.inner.borrow_mut().set_parameter("strength", v);
            Ok(())
        });
        // -- setScanlineStrength --
        /// Sets the scanline strength shader parameter on this effect.
        /// @param | v | number | Scanline strength value passed to the effect shader.
        methods.add_method_mut("setScanlineStrength", |_, this, v: f32| {
            this.inner
                .borrow_mut()
                .set_parameter("scanline_strength", v);
            Ok(())
        });
        // -- setOffset --
        /// Sets the offset shader parameter on this effect.
        /// @param | v | number | Offset value passed to the effect shader.
        methods.add_method_mut("setOffset", |_, this, v: f32| {
            this.inner.borrow_mut().set_parameter("offset", v);
            Ok(())
        });
        // -- setBrightness --
        /// Sets the brightness shader parameter on this effect.
        /// @param | v | number | Brightness value passed to the effect shader.
        methods.add_method_mut("setBrightness", |_, this, v: f32| {
            this.inner.borrow_mut().set_parameter("brightness", v);
            Ok(())
        });
        // -- setContrast --
        /// Sets the contrast shader parameter on this effect.
        /// @param | v | number | Contrast value passed to the effect shader.
        methods.add_method_mut("setContrast", |_, this, v: f32| {
            this.inner.borrow_mut().set_parameter("contrast", v);
            Ok(())
        });
        // -- setSaturation --
        /// Sets the saturation shader parameter on this effect.
        /// @param | v | number | Saturation value passed to the effect shader.
        methods.add_method_mut("setSaturation", |_, this, v: f32| {
            this.inner.borrow_mut().set_parameter("saturation", v);
            Ok(())
        });
        // -- enableAutoUniforms --
        /// Enables automatic time and resolution uniforms for this effect.
        methods.add_method_mut("enableAutoUniforms", |_, this, ()| {
            this.inner.borrow_mut().auto_uniforms = true;
            Ok(())
        });
        // -- disableAutoUniforms --
        /// Disables automatic time and resolution uniforms for this effect.
        methods.add_method_mut("disableAutoUniforms", |_, this, ()| {
            this.inner.borrow_mut().auto_uniforms = false;
            Ok(())
        });
        // -- isAutoUniforms --
        /// Returns whether automatic uniforms are enabled for this effect.
        /// @return | boolean | True when automatic uniforms are enabled.
        methods.add_method("isAutoUniforms", |_, this, ()| {
            Ok(this.inner.borrow().auto_uniforms)
        });
    }
}
/// Lua-side handle for an ordered post-processing stack.
pub struct LuaPostFxStack {
    /// Core stack dimensions, enabled flags, and pass ordering.
    inner: PostFxStack,
    /// Shared Lua effect handles used by stack pass entries.
    effects: Vec<Rc<RefCell<PostFxEffect>>>,
    /// Unique stack id referenced by renderer commands.
    stack_id: u64,
    /// Shared runtime state that receives renderer post-effect commands.
    state: Rc<RefCell<SharedState>>,
    /// Feedback blend factor clamped to the range 0.0..=1.0.
    feedback_factor: f32,
}
/// Provides Lua methods for editing post-processing stack order, capture, and renderer submission.
impl LuaUserData for LuaPostFxStack {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- add --
        /// Appends an effect to the end of this stack.
        /// @param | effect_ud | LPostFxEffect | Effect handle to append.
        methods.add_method_mut("add", |_, this, effect_ud: LuaAnyUserData| {
            let effect = effect_ud.borrow::<LuaPostFxEffect>()?;
            this.effects.push(Rc::clone(&effect.inner));
            let idx = this.effects.len() - 1;
            this.inner.add(idx);
            Ok(())
        });
        // -- remove --
        /// Removes the first matching effect handle from this stack.
        /// @param | effect_ud | LPostFxEffect | Effect handle to remove.
        /// @return | boolean | True when the effect was found and removed.
        methods.add_method_mut("remove", |_, this, effect_ud: LuaAnyUserData| {
            let effect = effect_ud.borrow::<LuaPostFxEffect>()?;
            let ptr = Rc::as_ptr(&effect.inner);
            if let Some(pos) = this.effects.iter().position(|e| Rc::as_ptr(e) == ptr) {
                this.effects.remove(pos);
                if pos < this.inner.effects.len() {
                    this.inner.effects.remove(pos);
                    this.inner.enabled.remove(pos);
                }
                Ok(true)
            } else {
                Ok(false)
            }
        });
        // -- insert --
        /// Inserts an effect at a one-based stack position.
        /// @param | position | integer | One-based insertion position, clamped to the stack length.
        /// @param | effect_ud | LPostFxEffect | Effect handle to insert.
        methods.add_method_mut(
            "insert",
            |_, this, (position, effect_ud): (usize, LuaAnyUserData)| {
                let effect = effect_ud.borrow::<LuaPostFxEffect>()?;
                let idx = (position.saturating_sub(1)).min(this.effects.len());
                this.effects.insert(idx, Rc::clone(&effect.inner));
                this.inner.effects.insert(idx, idx);
                this.inner.enabled.insert(idx, true);
                Ok(())
            },
        );
        // -- setEnabled --
        /// Enables or disables the effect pass at a one-based stack position.
        /// @param | position | integer | One-based stack position.
        /// @param | enabled | boolean | New enabled flag for the pass.
        methods.add_method_mut(
            "setEnabled",
            |_, this, (position, enabled): (usize, bool)| {
                let idx = position.saturating_sub(1);
                if idx < this.inner.enabled.len() {
                    this.inner.enabled[idx] = enabled;
                }
                Ok(())
            },
        );
        // -- isEnabled --
        /// Returns whether the effect pass at a one-based position is enabled.
        /// @param | position | integer | One-based stack position.
        /// @return | boolean | True when the pass is enabled; false for out-of-range positions.
        methods.add_method("isEnabled", |_, this, position: usize| {
            let idx = position.saturating_sub(1);
            Ok(this.inner.enabled.get(idx).copied().unwrap_or(false))
        });
        // -- getEffectCount --
        /// Returns the number of effect handles in this stack.
        /// @return | integer | Effect count.
        methods.add_method("getEffectCount", |_, this, ()| Ok(this.effects.len()));
        // -- getEffect --
        /// Returns the effect handle at a one-based position.
        /// @param | index | integer | One-based stack position.
        /// @return | LuaValue | `LPostFxEffect` handle, or nil when the index is out of range.
        methods.add_method("getEffect", |lua, this, index: usize| {
            let idx = index.saturating_sub(1);
            match this.effects.get(idx) {
                Some(rc) => Ok(LuaValue::UserData(
                    lua.create_userdata(LuaPostFxEffect::from_rc(Rc::clone(rc)))?,
                )),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- getEnabledEffects --
        /// Returns effect handles whose stack passes are enabled.
        /// @return | LPostFxEffect[] | Enabled `LPostFxEffect` handles.
        methods.add_method("getEnabledEffects", |lua, this, ()| {
            let t = lua.create_table()?;
            let mut count = 1;
            for (i, rc) in this.effects.iter().enumerate() {
                if this.inner.enabled.get(i).copied().unwrap_or(true) {
                    t.set(
                        count,
                        lua.create_userdata(LuaPostFxEffect::from_rc(Rc::clone(rc)))?,
                    )?;
                    count += 1;
                }
            }
            Ok(t)
        });
        // -- getWidth --
        /// Returns the stack render width. This method is available to Lua scripts.
        /// @return | integer | Stack width in pixels.
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.get_width()));
        // -- getHeight --
        /// Returns the stack render height. This method is available to Lua scripts.
        /// @return | integer | Stack height in pixels.
        methods.add_method("getHeight", |_, this, ()| Ok(this.inner.get_height()));
        // -- getDimensions --
        /// Returns the stack render dimensions.
        /// @return | integer | Stack width in pixels.
        /// @return | integer | Stack height in pixels.
        methods.add_method("getDimensions", |_, this, ()| {
            Ok(this.inner.get_dimensions())
        });
        // -- resize --
        /// Resizes the post-processing stack render target dimensions.
        /// @param | w | integer | New width in pixels.
        /// @param | h | integer | New height in pixels.
        methods.add_method_mut("resize", |_, this, (w, h): (u32, u32)| {
            this.inner.resize(w, h);
            Ok(())
        });
        // -- len --
        /// Returns the number of effect handles in this stack.
        /// @return | integer | Effect count.
        methods.add_method("len", |_, this, ()| Ok(this.effects.len()));
        // -- isEmpty --
        /// Returns whether this stack has no effects.
        /// @return | boolean | True when the stack has zero effects.
        methods.add_method("isEmpty", |_, this, ()| Ok(this.effects.is_empty()));
        // -- clear --
        /// Removes all effects and pass state from this stack.
        methods.add_method_mut("clear", |_, this, ()| {
            this.effects.clear();
            this.inner.clear();
            Ok(())
        });
        // -- dedup --
        /// Removes duplicate effect handles while preserving first occurrences.
        /// @return | integer | Number of duplicate effects removed.
        methods.add_method_mut("dedup", |_, this, ()| {
            let mut seen_ptrs: Vec<*const ()> = Vec::new();
            let mut new_lua = Vec::with_capacity(this.effects.len());
            let mut new_inner_effects = Vec::with_capacity(this.effects.len());
            let mut new_inner_enabled = Vec::with_capacity(this.effects.len());
            for (i, rc) in this.effects.iter().enumerate() {
                let ptr = Rc::as_ptr(rc) as *const ();
                if !seen_ptrs.contains(&ptr) {
                    seen_ptrs.push(ptr);
                    new_lua.push(Rc::clone(rc));
                    new_inner_effects.push(new_lua.len() - 1);
                    new_inner_enabled.push(this.inner.enabled.get(i).copied().unwrap_or(true));
                }
            }
            let removed = this.effects.len() - new_lua.len();
            this.effects = new_lua;
            this.inner.effects = new_inner_effects;
            this.inner.enabled = new_inner_enabled;
            Ok(removed as i64)
        });
        // -- isCapturing --
        /// Returns whether this stack is currently capturing draw commands.
        /// @return | boolean | True when capture mode is active.
        methods.add_method("isCapturing", |_, this, ()| Ok(this.inner.capturing));
        // -- beginCapture --
        /// Starts post-effect capture and queues a renderer begin-capture command.
        methods.add_method_mut("beginCapture", |_, this, ()| {
            this.inner.capturing = true;
            this.state
                .borrow_mut()
                .render_commands
                .push(RenderCommand::BeginPostFx {
                    stack_id: this.stack_id,
                });
            Ok(())
        });
        // -- endCapture --
        /// Ends post-effect capture and queues a renderer end-capture command.
        methods.add_method_mut("endCapture", |_, this, ()| {
            this.inner.capturing = false;
            this.state
                .borrow_mut()
                .render_commands
                .push(RenderCommand::EndPostFx {
                    stack_id: this.stack_id,
                });
            Ok(())
        });
        // -- apply --
        /// Queues this stack's enabled post-effect passes for renderer application.
        methods.add_method("apply", |_, this, ()| {
            let passes: Vec<PostFxPass> = this
                .effects
                .iter()
                .zip(this.inner.enabled.iter())
                .filter(|(_, &enabled)| enabled)
                .map(|(effect_rc, _)| {
                    let e = effect_rc.borrow();
                    PostFxPass {
                        effect_name: e.get_type_name().to_string(),
                        params: e.params.clone(),
                        shader_id: e.shader_id,
                        auto_uniforms: e.auto_uniforms,
                    }
                })
                .collect();
            this.state
                .borrow_mut()
                .render_commands
                .push(RenderCommand::ApplyPostFx {
                    stack_id: this.stack_id,
                    passes,
                    width: this.inner.width,
                    height: this.inner.height,
                });
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this post-processing stack handle.
        /// @return | string | The string `LPostFxStack`.
        methods.add_method("type", |_, _, ()| Ok("LPostFxStack"));
        // -- typeOf --
        /// Returns whether this stack handle matches a supported type name.
        /// @param | name | string | Type name to compare against `PostFxStack` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LPostFxStack" || name == "LObject")
        });
        // -- setFeedback --
        /// Sets the stack feedback blend factor and clamps it to 0.0 through 1.0.
        /// @param | factor | number | Feedback blend factor.
        methods.add_method_mut("setFeedback", |_, this, factor: f32| {
            this.feedback_factor = factor.clamp(0.0, 1.0);
            Ok(())
        });
        // -- getFeedback --
        /// Returns the current stack feedback blend factor.
        /// @return | number | Feedback blend factor in the range 0.0 through 1.0.
        methods.add_method("getFeedback", |_, this, ()| Ok(this.feedback_factor));
        // -- clearFeedback --
        /// Resets the stack feedback blend factor to zero.
        methods.add_method_mut("clearFeedback", |_, this, ()| {
            this.feedback_factor = 0.0;
            Ok(())
        });
    }
}
/// Lua-side handle for an image effect chain detached from live post-effect capture.
pub struct LuaImageEffect {
    /// Image effect chain and its owned effect entries.
    inner: ImageEffect,
}
/// Provides Lua methods for editing image effect chains.
impl LuaUserData for LuaImageEffect {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addEffect --
        /// Appends a built-in post-effect by type name to this image effect chain.
        /// @param | name | string | Built-in effect type name.
        /// @return | LPostFxEffect | Handle for the effect added to the chain.
        methods.add_method_mut("addEffect", |lua, this, name: String| {
            let et = PostFxEffectType::from_name(&name)
                .ok_or_else(|| LuaError::RuntimeError(format!("unknown effect type: {name}")))?;
            let rc = Rc::new(RefCell::new(PostFxEffect::new(et)));
            this.inner.add_effect_rc(Rc::clone(&rc));
            lua.create_userdata(LuaPostFxEffect::from_rc(rc))
        });
        // -- getEffect --
        /// Looks up an image effect by one-based index or effect type name.
        /// @param | key | string | Effect name string or one-based integer index.
        /// @return | LuaValue | `LPostFxEffect` handle, or nil when no matching effect exists.
        methods.add_method("getEffect", |lua, this, key: LuaValue| {
            let rc_opt = match &key {
                LuaValue::Integer(i) => this
                    .inner
                    .get_effect_by_index((*i as usize).saturating_sub(1)),
                LuaValue::Number(n) => this
                    .inner
                    .get_effect_by_index((*n as usize).saturating_sub(1)),
                LuaValue::String(s) => this.inner.get_effect_by_name(s.to_str()?),
                _ => None,
            };
            match rc_opt {
                Some(rc) => Ok(LuaValue::UserData(
                    lua.create_userdata(LuaPostFxEffect::from_rc(rc))?,
                )),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- removeEffect --
        /// Removes an image effect by one-based index or effect type name.
        /// @param | key | string | Effect name string or one-based integer index.
        /// @return | boolean | True when an effect was removed.
        methods.add_method_mut("removeEffect", |_, this, key: LuaValue| match &key {
            LuaValue::Integer(i) => Ok(this.inner.remove_by_index((*i as usize).saturating_sub(1))),
            LuaValue::Number(n) => Ok(this.inner.remove_by_index((*n as usize).saturating_sub(1))),
            LuaValue::String(s) => Ok(this.inner.remove_by_name(s.to_str()?)),
            _ => Ok(false),
        });
        // -- clearEffects --
        /// Removes every effect from this image effect chain.
        methods.add_method_mut("clearEffects", |_, this, ()| {
            this.inner.clear();
            Ok(())
        });
        // -- clear --
        /// Removes every effect from this image effect chain.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.clear();
            Ok(())
        });
        // -- effectCount --
        /// Returns the number of effects in this image effect chain.
        /// @return | integer | Effect count.
        methods.add_method("effectCount", |_, this, ()| Ok(this.inner.effect_count()));
        // -- getEffectCount --
        /// Returns the number of effects in this image effect chain.
        /// @return | integer | Effect count.
        methods.add_method("getEffectCount", |_, this, ()| {
            Ok(this.inner.effect_count())
        });
        // -- clone --
        /// Creates a new image effect chain with cloned effect entries.
        /// @return | LImageEffect | New image effect handle with the same effect chain.
        methods.add_method("clone", |lua, this, ()| {
            let mut new_ie = ImageEffect::new("");
            for i in 0..this.inner.effect_count() {
                if let Some(rc) = this.inner.get_effect_by_index(i) {
                    new_ie.add_effect(rc.borrow().clone());
                }
            }
            lua.create_userdata(LuaImageEffect { inner: new_ie })
        });
        // -- save --
        /// Reports success for the current image effect save placeholder.
        /// @return | boolean | Always true.
        methods.add_method("save", |_, _, ()| Ok(true));
        // -- type --
        /// Returns the Lua-visible type name for this image effect handle.
        /// @return | string | The string `LImageEffect`.
        methods.add_method("type", |_, _, ()| Ok("LImageEffect"));
        // -- typeOf --
        /// Returns whether this image effect handle matches a supported type name.
        /// @param | name | string | Type name to compare against `ImageEffect` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LImageEffect" || name == "LObject")
        });
        // -- removeByIndex --
        /// Removes an image effect by zero-based internal index.
        /// @param | idx | integer | Zero-based effect index.
        /// @return | boolean | True when an effect was removed.
        methods.add_method_mut("removeByIndex", |_, this, idx: usize| {
            Ok(this.inner.remove_by_index(idx))
        });
        // -- removeByName --
        /// Removes the first image effect with a matching effect type name.
        /// @param | name | string | Effect type name to remove.
        /// @return | boolean | True when an effect was removed.
        methods.add_method_mut("removeByName", |_, this, name: String| {
            Ok(this.inner.remove_by_name(&name))
        });
    }
}
/// Registers `lurek.effect` constructors and effect state controls.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newEffect --
    /// Creates a built-in post-processing effect by type name.
    /// @param | type_name | string | Built-in effect type name such as `blur`, `bloom`, or `crt`.
    /// @return | LPostFxEffect | New post-processing effect handle.
    tbl.set(
        "newEffect",
        lua.create_function(|lua, type_name: String| {
            let effect_type = PostFxEffectType::from_name(&type_name).ok_or_else(|| {
                LuaError::RuntimeError(format!("unknown effect type: {type_name}"))
            })?;
            lua.create_userdata(LuaPostFxEffect::from_owned(PostFxEffect::new(effect_type)))
        })?,
    )?;
    // -- newCustomEffect --
    /// Creates a custom post-processing effect that references an existing shader id.
    /// @param | shader_id | integer | Renderer shader identifier used for the custom effect.
    /// @return | LPostFxEffect | New custom post-processing effect handle.
    tbl.set(
        "newCustomEffect",
        lua.create_function(|lua, shader_id: usize| {
            lua.create_userdata(LuaPostFxEffect::from_owned(PostFxEffect::new_custom(
                shader_id,
            )))
        })?,
    )?;
    let s = state.clone();
    // -- newStack --
    /// Creates a post-processing stack using optional dimensions or the current window size.
    /// @param | w | integer? | Stack width in pixels, defaulting to window width.
    /// @param | h | integer? | Stack height in pixels, defaulting to window height.
    /// @return | LPostFxStack | New post-processing stack handle.
    tbl.set(
        "newStack",
        lua.create_function(move |lua, (w, h): (Option<u32>, Option<u32>)| {
            let (default_w, default_h) = {
                let s = s.borrow();
                (s.window_width, s.window_height)
            };
            let w = w.unwrap_or(default_w);
            let h = h.unwrap_or(default_h);
            lua.create_userdata(LuaPostFxStack {
                inner: PostFxStack::new(w, h),
                effects: Vec::new(),
                stack_id: NEXT_STACK_ID.fetch_add(1, Ordering::Relaxed),
                state: Rc::clone(&s),
                feedback_factor: 0.0,
            })
        })?,
    )?;
    let s = state.clone();
    // -- newPresetStack --
    /// Creates a named preset post-processing stack with optional dimensions.
    /// @param | name | string | Preset stack name.
    /// @param | w | integer? | Stack width in pixels, defaulting to window width.
    /// @param | h | integer? | Stack height in pixels, defaulting to window height.
    /// @return | LPostFxStack | New preset post-processing stack handle.
    tbl.set(
        "newPresetStack",
        lua.create_function(
            move |lua, (name, w, h): (String, Option<u32>, Option<u32>)| {
                let (default_w, default_h) = {
                    let borrow = s.borrow();
                    (borrow.window_width, borrow.window_height)
                };
                let w = w.unwrap_or(default_w);
                let h = h.unwrap_or(default_h);
                let preset = build_preset(&name, w, h)
                    .ok_or_else(|| LuaError::RuntimeError(format!("unknown preset '{}'", name)))?;
                let effects: Vec<Rc<RefCell<PostFxEffect>>> = preset
                    .effects
                    .into_iter()
                    .map(|e| Rc::new(RefCell::new(e)))
                    .collect();
                lua.create_userdata(LuaPostFxStack {
                    inner: preset.stack,
                    effects,
                    stack_id: NEXT_STACK_ID.fetch_add(1, Ordering::Relaxed),
                    state: Rc::clone(&s),
                    feedback_factor: 0.0,
                })
            },
        )?,
    )?;
    // -- newPass --
    /// Creates a custom post-processing pass from an existing shader id.
    /// @param | shader_id | integer | Renderer shader identifier used for the pass.
    /// @return | LPostFxEffect | New custom post-processing effect handle.
    tbl.set(
        "newPass",
        lua.create_function(|lua, shader_id: usize| {
            lua.create_userdata(LuaPostFxEffect::from_owned(PostFxEffect::new_custom(
                shader_id,
            )))
        })?,
    )?;
    // -- getEffectTypes --
    /// Returns all built-in post-processing effect type names.
    /// @return | string[] | Built-in effect type strings.
    tbl.set(
        "getEffectTypes",
        lua.create_function(|_, ()| Ok(PostFxEffectType::built_in_names()))?,
    )?;
    // -- getPresetNames --
    /// Returns all built-in post-processing preset names.
    /// @return | string[] | Built-in preset name strings.
    tbl.set(
        "getPresetNames",
        lua.create_function(|_, ()| Ok(preset_names()))?,
    )?;
    // -- newImageEffect --
    /// Creates an image effect chain from no arguments, a type name and optional parameters, or a chain table.
    /// @param | spec | LuaValue? | Optional effect type string, or an array table of effect entries, or nil for an empty chain.
    /// @param | params | table? | Optional parameter table used when `spec` is an effect type string.
    /// @return | LImageEffect | New image effect chain handle.
    tbl.set(
        "newImageEffect",
        lua.create_function(|lua, args: LuaMultiValue| {
            let mut ie = ImageEffect::new("");
            match args.iter().next() {
                None => {}
                Some(LuaValue::String(s)) => {
                    let name = s.to_str().map_err(LuaError::external)?.to_string();
                    let et = PostFxEffectType::from_name(&name).ok_or_else(|| {
                        LuaError::RuntimeError(format!("unknown effect type: {name}"))
                    })?;
                    let mut eff = PostFxEffect::new(et);
                    if let Some(LuaValue::Table(params)) = args.iter().nth(1) {
                        for (k, v) in params.clone().pairs::<String, f32>().flatten() {
                            eff.set_parameter(&k, v);
                        }
                    }
                    ie.add_effect(eff);
                }
                Some(LuaValue::Table(chain)) => {
                    for entry in chain.clone().sequence_values::<LuaTable>() {
                        let entry = entry?;
                        let name: String = entry
                            .get("type")
                            .or_else(|_| entry.get(1))
                            .unwrap_or_default();
                        let et = PostFxEffectType::from_name(&name).ok_or_else(|| {
                            LuaError::RuntimeError(format!("unknown effect type: {name}"))
                        })?;
                        let mut eff = PostFxEffect::new(et);
                        for (k, v) in entry.pairs::<String, LuaValue>().flatten() {
                            if k != "type" {
                                if let LuaValue::Number(n) = v {
                                    eff.set_parameter(&k, n as f32);
                                } else if let LuaValue::Integer(i) = v {
                                    eff.set_parameter(&k, i as f32);
                                }
                            }
                        }
                        ie.add_effect(eff);
                    }
                }
                _ => {
                    return Err(LuaError::RuntimeError(
                        "newImageEffect: invalid arguments".to_string(),
                    ))
                }
            }
            lua.create_userdata(LuaImageEffect { inner: ie })
        })?,
    )?;
    let s = state.clone();
    // -- setShaderErrorDisplay --
    /// Enables or disables renderer shader error display overlays.
    /// @param | enabled | boolean | New shader error display flag.
    tbl.set(
        "setShaderErrorDisplay",
        lua.create_function(move |_, enabled: bool| {
            s.borrow_mut().shader_error_display_enabled = enabled;
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getShaderErrorDisplay --
    /// Returns whether renderer shader error display overlays are enabled.
    /// @return | boolean | True when shader error display is enabled.
    tbl.set(
        "getShaderErrorDisplay",
        lua.create_function(move |_, ()| Ok(s.borrow().shader_error_display_enabled))?,
    )?;
    /// Performs the 'effect' operation.
    lurek.set("effect", tbl)?;
    Ok(())
}
