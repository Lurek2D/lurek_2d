//! Registers the `lurek.overlay` Lua API for overlay controllers, transitions, telemetry, and validated options.

use super::render_api::{
    ensure_shader_target, shader_key_from_userdata, LuaImage, LuaShader,
};
use super::SharedState;
use crate::effect::PostFxEffectType;
use crate::image::{ImageData, Texture, TextureColorSpace};
use crate::overlay::{
    Overlay, OverlayAccessibilityPolicy, ScreenTransition, StatusCompositeMode,
    StatusLayerTarget, StatusOverlayLayer, TransitionKind, WeatherType, STATUS_INTENSITY_MAX,
};
use crate::render::renderer::{PostFxPass, RenderCommand};
use crate::render::ShaderTarget;
use crate::runtime::resource_keys::{ShaderKey, TextureKey};
use mlua::prelude::*;
use slotmap::Key;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

const OVERLAY_SHADER_STACK_ID: u64 = 0x4f56_4c59_0000_0001;

fn shader_id_from_key(key: ShaderKey) -> usize {
    key.data().as_ffi() as usize
}

fn overlay_shader_pass(effect_name: String, key: ShaderKey) -> PostFxPass {
    PostFxPass {
        effect_name,
        params: HashMap::new(),
        shader_id: Some(shader_id_from_key(key)),
        auto_uniforms: true,
    }
}

fn finite_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "{api}: {arg_name} must be finite"
        )))
    }
}

fn non_negative_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    let value = finite_f32(api, arg_name, value)?;
    if value >= 0.0 {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "{api}: {arg_name} must be >= 0"
        )))
    }
}

fn unit_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    Ok(finite_f32(api, arg_name, value)?.clamp(0.0, 1.0))
}

fn positive_u32(api: &str, arg_name: &str, value: u32) -> LuaResult<u32> {
    if value > 0 {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "{api}: {arg_name} must be > 0"
        )))
    }
}

fn table_to_color(api: &str, field: &str, table: &LuaTable) -> LuaResult<[f32; 4]> {
    Ok([
        unit_f32(api, &format!("{field}.r"), table.get::<_, Option<f32>>(1)?.unwrap_or(0.0))?,
        unit_f32(api, &format!("{field}.g"), table.get::<_, Option<f32>>(2)?.unwrap_or(0.0))?,
        unit_f32(api, &format!("{field}.b"), table.get::<_, Option<f32>>(3)?.unwrap_or(0.0))?,
        unit_f32(api, &format!("{field}.a"), table.get::<_, Option<f32>>(4)?.unwrap_or(1.0))?,
    ])
}

fn parse_status_target(value: Option<String>) -> LuaResult<StatusLayerTarget> {
    match value
        .unwrap_or_else(|| "hudFront".to_string())
        .trim()
        .to_ascii_lowercase()
        .as_str()
    {
        "sceneonly" | "scene_only" => Ok(StatusLayerTarget::SceneOnly),
        "hudback" | "hud_back" => Ok(StatusLayerTarget::HudBack),
        "hudfront" | "hud_front" => Ok(StatusLayerTarget::HudFront),
        "fullscreentop" | "full_screen_top" => Ok(StatusLayerTarget::FullScreenTop),
        other => Err(LuaError::RuntimeError(format!(
            "status target must be one of sceneOnly, hudBack, hudFront, fullScreenTop; got '{}'",
            other
        ))),
    }
}

fn parse_status_composite(value: Option<String>) -> LuaResult<StatusCompositeMode> {
    match value
        .unwrap_or_else(|| "alphaBlend".to_string())
        .trim()
        .to_ascii_lowercase()
        .as_str()
    {
        "alphablend" | "alpha_blend" => Ok(StatusCompositeMode::AlphaBlend),
        "additive" => Ok(StatusCompositeMode::Additive),
        "additiveclamp" | "additive_clamp" => Ok(StatusCompositeMode::AdditiveClamp),
        other => Err(LuaError::RuntimeError(format!(
            "status composite must be one of alphaBlend, additive, additiveClamp; got '{}'",
            other
        ))),
    }
}

fn texture_from_lua_value(
    state: &Rc<RefCell<SharedState>>,
    api_name: &str,
    value: LuaValue,
) -> LuaResult<Option<(TextureKey, (u32, u32))>> {
    match value {
        LuaValue::Nil => Ok(None),
        LuaValue::String(path_str) => {
            let path = path_str.to_str().map_err(|err| {
                LuaError::RuntimeError(format!("{api_name}: invalid texture path: {err}"))
            })?;
            let mut st = state.borrow_mut();
            let full_path = st.game_dir.join(path.to_string());
            let texture = Texture::load_with_color_space(
                &full_path,
                &mut st.textures,
                TextureColorSpace::Srgb,
            )
            .map_err(|err| LuaError::RuntimeError(format!("{api_name}: {err}")))?;
            st.clear_released_texture_handle(texture.key.data().as_ffi());
            Ok(Some((texture.key, (texture.width, texture.height))))
        }
        LuaValue::UserData(ud) => {
            if let Ok(image) = ud.borrow::<LuaImage>() {
                let st = state.borrow();
                let texture = st.textures.get(image.key).ok_or_else(|| {
                    LuaError::RuntimeError(format!(
                        "{api_name}: image handle is not valid or was released"
                    ))
                })?;
                return Ok(Some((image.key, (texture.width, texture.height))));
            }
            if let Ok(image_data) = ud.borrow::<ImageData>() {
                let pixels = image_data.as_bytes().to_vec();
                let (width, height) = image_data.dimensions();
                let mut st = state.borrow_mut();
                let texture = Texture::from_rgba_with_color_space(
                    width,
                    height,
                    pixels,
                    &mut st.textures,
                    TextureColorSpace::Srgb,
                )
                .map_err(|err| LuaError::RuntimeError(format!("{api_name}: {err}")))?;
                st.clear_released_texture_handle(texture.key.data().as_ffi());
                return Ok(Some((texture.key, (texture.width, texture.height))));
            }
            Err(LuaError::RuntimeError(format!(
                "{api_name}: texture must be a path string, LImage, or LImageData"
            )))
        }
        other => Err(LuaError::RuntimeError(format!(
            "{api_name}: texture must be a path string, LImage, or LImageData, got {}",
            other.type_name()
        ))),
    }
}

fn apply_status_preset(layer: &mut StatusOverlayLayer) {
    match layer.kind.as_str() {
        "frozen" => {
            layer.visual.color = Some([0.72, 0.88, 1.0, 0.18]);
            layer.visual.shader_effect = Some("grayscale".to_string());
            layer.visual.shader_strength = 0.9;
            layer.visual.texture_opacity = 0.95;
        }
        "poison" => {
            layer.visual.color = Some([0.25, 0.82, 0.28, 0.16]);
            layer.visual.shader_effect = Some("chromatic".to_string());
            layer.visual.shader_strength = 2.0;
        }
        "burning" => {
            layer.visual.color = Some([0.95, 0.38, 0.12, 0.16]);
            layer.visual.shader_effect = Some("noise".to_string());
            layer.visual.shader_strength = 0.4;
        }
        "lowhealth" | "low_health" => {
            layer.visual.color = Some([0.92, 0.1, 0.12, 0.2]);
            layer.visual.shader_effect = Some("vignette".to_string());
            layer.visual.shader_strength = 0.85;
        }
        "radiation" => {
            layer.visual.color = Some([0.4, 0.9, 0.28, 0.14]);
            layer.visual.shader_effect = Some("scanlines".to_string());
            layer.visual.shader_strength = 0.45;
        }
        "blind" => {
            layer.visual.color = Some([0.0, 0.0, 0.0, 0.35]);
            layer.visual.shader_effect = Some("vignette".to_string());
            layer.visual.shader_strength = 1.0;
        }
        _ => {}
    }
}

fn status_layer_to_table<'lua>(
    lua: &'lua Lua,
    layer: &StatusOverlayLayer,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("id", layer.id.clone())?;
    table.set("kind", layer.kind.clone())?;
    table.set("enabled", layer.enabled)?;
    table.set("intensity", layer.intensity_01 * STATUS_INTENSITY_MAX)?;
    table.set("intensity01", layer.intensity_01)?;
    table.set("targetIntensity", layer.target_intensity_01 * STATUS_INTENSITY_MAX)?;
    table.set("targetIntensity01", layer.target_intensity_01)?;
    table.set("fadeIn", layer.fade_in)?;
    table.set("fadeOut", layer.fade_out)?;
    table.set("duration", layer.duration)?;
    table.set("elapsed", layer.elapsed)?;
    table.set("priority", layer.priority)?;
    table.set(
        "target",
        match layer.target {
            StatusLayerTarget::SceneOnly => "sceneOnly",
            StatusLayerTarget::HudBack => "hudBack",
            StatusLayerTarget::HudFront => "hudFront",
            StatusLayerTarget::FullScreenTop => "fullScreenTop",
        },
    )?;
    table.set(
        "composite",
        match layer.composite {
            StatusCompositeMode::AlphaBlend => "alphaBlend",
            StatusCompositeMode::Additive => "additive",
            StatusCompositeMode::AdditiveClamp => "additiveClamp",
        },
    )?;
    if let Some(color) = layer.visual.color {
        let color_tbl = lua.create_table()?;
        for (index, value) in color.into_iter().enumerate() {
            color_tbl.set(index + 1, value)?;
        }
        table.set("color", color_tbl)?;
    }
    table.set("hasTexture", layer.visual.texture_key.is_some())?;
    table.set("textureOpacity", layer.visual.texture_opacity)?;
    table.set("shader", layer.visual.shader_effect.clone())?;
    table.set("shaderStrength", layer.visual.shader_strength)?;
    Ok(table)
}

/// Lua-side handle for screen overlay, ambient, weather, and transition visual state.
pub struct LuaOverlay {
    /// Overlay state that builds renderer commands for full-screen effects.
    inner: Overlay,
    /// Shared runtime state used for renderer commands and light ambient synchronization.
    state: Rc<RefCell<SharedState>>,
    /// Optional shader bound to the whole overlay.
    shader: Option<ShaderKey>,
    /// Optional per-layer shader bindings.
    shader_layers: HashMap<String, ShaderKey>,
}
/// Provides Lua methods for overlay animation, ambient, weather, fog, water, and render submission.
impl LuaUserData for LuaOverlay {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- update --
        /// Advances overlay timers and animated effect state.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            let dt = non_negative_f32("LOverlay:update", "dt", dt)?;
            this.inner.update(dt);
            Ok(())
        });
        // -- setShader --
        /// Sets or clears the shader used for custom overlay rendering.
        /// @param | shader | LShader? | Overlay-target shader or nil to clear.
        methods.add_method_mut("setShader", |_, this, shader: Option<LuaAnyUserData>| {
            let key = match shader {
                Some(ud) => {
                    let key = shader_key_from_userdata(&ud)?;
                    ensure_shader_target(
                        &this.state.borrow(),
                        key,
                        ShaderTarget::Overlay,
                        "LOverlay:setShader",
                    )?;
                    Some(key)
                }
                None => None,
            };
            this.shader = key;
            Ok(())
        });
        // -- getShader --
        /// Returns the shader bound to this overlay, if any.
        /// @return | LShader? | Bound shader or nil.
        methods.add_method("getShader", |_, this, ()| {
            Ok(this.shader.map(|key| LuaShader {
                state: this.state.clone(),
                key,
            }))
        });
        // -- setShaderLayer --
        /// Sets or clears an overlay-layer shader binding.
        /// @param | layer | string | Layer name such as `heat_haze`, `water`, or `fog`.
        /// @param | shader | LShader? | Overlay-target shader or nil to clear.
        methods.add_method_mut(
            "setShaderLayer",
            |_, this, (layer, shader): (String, Option<LuaAnyUserData>)| {
                let layer = layer.trim().to_string();
                if layer.is_empty() {
                    return Err(LuaError::RuntimeError(
                        "LOverlay:setShaderLayer: layer must not be empty".into(),
                    ));
                }
                match shader {
                    Some(ud) => {
                        let key = shader_key_from_userdata(&ud)?;
                        ensure_shader_target(
                            &this.state.borrow(),
                            key,
                            ShaderTarget::Overlay,
                            "LOverlay:setShaderLayer",
                        )?;
                        this.shader_layers.insert(layer, key);
                    }
                    None => {
                        this.shader_layers.remove(&layer);
                    }
                }
                Ok(())
            },
        );
        // -- getShaderLayer --
        /// Returns a shader bound to one overlay layer, if present.
        /// @param | layer | string | Layer name.
        /// @return | LShader? | Bound shader or nil.
        methods.add_method("getShaderLayer", |_, this, layer: String| {
            Ok(this.shader_layers.get(layer.trim()).map(|key| LuaShader {
                state: this.state.clone(),
                key: *key,
            }))
        });
        // -- triggerFlash --
        /// Starts a screen flash with explicit RGBA color and duration.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number | Alpha channel.
        /// @param | duration | number | Flash duration in seconds.
        methods.add_method_mut(
            "triggerFlash",
            |_, this, (r, g, b, a, duration): (f32, f32, f32, f32, f32)| {
                let r = unit_f32("LOverlay:triggerFlash", "r", r)?;
                let g = unit_f32("LOverlay:triggerFlash", "g", g)?;
                let b = unit_f32("LOverlay:triggerFlash", "b", b)?;
                let a = unit_f32("LOverlay:triggerFlash", "a", a)?;
                let duration = non_negative_f32("LOverlay:triggerFlash", "duration", duration)?;
                this.inner.trigger_flash(r, g, b, a, duration);
                Ok(())
            },
        );
        // -- triggerShake --
        /// Starts a screen shake effect. This method is available to Lua scripts.
        /// @param | intensity | number | Shake intensity.
        /// @param | duration | number | Shake duration in seconds.
        methods.add_method_mut(
            "triggerShake",
            |_, this, (intensity, duration): (f32, f32)| {
                let intensity = non_negative_f32("LOverlay:triggerShake", "intensity", intensity)?;
                let duration = non_negative_f32("LOverlay:triggerShake", "duration", duration)?;
                this.inner.trigger_shake(intensity, duration);
                Ok(())
            },
        );
        // -- triggerFade --
        /// Starts a fade overlay toward a target alpha.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | target_alpha | number | Target alpha value.
        /// @param | duration | number | Fade duration in seconds.
        methods.add_method_mut(
            "triggerFade",
            |_, this, (r, g, b, target_alpha, duration): (f32, f32, f32, f32, f32)| {
                let r = unit_f32("LOverlay:triggerFade", "r", r)?;
                let g = unit_f32("LOverlay:triggerFade", "g", g)?;
                let b = unit_f32("LOverlay:triggerFade", "b", b)?;
                let target_alpha = unit_f32("LOverlay:triggerFade", "target_alpha", target_alpha)?;
                let duration = non_negative_f32("LOverlay:triggerFade", "duration", duration)?;
                this.inner.trigger_fade(r, g, b, target_alpha, duration);
                Ok(())
            },
        );
        // -- triggerLightning --
        /// Starts a lightning flash using the overlay lightning state.
        methods.add_method_mut("triggerLightning", |_, this, ()| {
            this.inner.trigger_lightning();
            Ok(())
        });
        // -- getShakeOffset --
        /// Returns the current screen shake offset.
        /// @return | number | Current x offset.
        /// @return | number | Current y offset.
        methods.add_method("getShakeOffset", |_, this, ()| {
            Ok(this.inner.get_shake_offset())
        });
        // -- isActive --
        /// Returns whether any overlay effect is currently active.
        /// @return | boolean | True when overlay state should render.
        methods.add_method("isActive", |_, this, ()| Ok(this.inner.is_active()));
        // -- getStats --
        /// Returns a telemetry snapshot for dashboard and debug workflows.
        /// @return | table | Overlay telemetry fields.
        /// @field | width | integer | Overlay width in pixels.
        /// @field | height | integer | Overlay height in pixels.
        /// @field | active_effects | integer | Count of currently active overlay subsystems.
        /// @field | status_layers | integer | Count of authored status layers stored in the overlay stack.
        /// @field | active_status_layers | integer | Count of status layers currently contributing visible work.
        methods.add_method("getStats", |lua, this, ()| {
            let stats = this.inner.stats();
            let table = lua.create_table()?;
            table.set("width", stats.width)?;
            table.set("height", stats.height)?;
            table.set("weather_particle_count", stats.weather_particle_count)?;
            table.set("weather_particle_limit", stats.weather_particle_limit)?;
            table.set("weather_intensity", stats.weather_intensity)?;
            table.set("flash_alpha", stats.flash_alpha)?;
            table.set("lightning_alpha", stats.lightning_alpha)?;
            table.set("active_effects", stats.active_effects)?;
            table.set("weather_enabled", stats.weather_enabled)?;
            table.set("ambient_enabled", stats.ambient_enabled)?;
            table.set("fog_enabled", stats.fog_enabled)?;
            table.set("vignette_enabled", stats.vignette_enabled)?;
            table.set("weather_spawns_this_frame", stats.weather_spawns_this_frame)?;
            table.set("weather_dropped_spawns", stats.weather_dropped_spawns)?;
            table.set("weather_culled_particles", stats.weather_culled_particles)?;
            table.set("weather_dt_spike_clamps", stats.weather_dt_spike_clamps)?;
            table.set("reduced_motion", stats.reduced_motion)?;
            table.set("accessibility_adjustments", stats.accessibility_adjustments)?;
            table.set("sanitized_fields", stats.sanitized_fields)?;
            table.set("invalid_shader_rejections", stats.invalid_shader_rejections)?;
            table.set("debug_image_rejections", stats.debug_image_rejections)?;
            table.set("external_render_layers", stats.external_render_layers)?;
            table.set("status_layers", stats.status_layers)?;
            table.set("active_status_layers", stats.active_status_layers)?;
            Ok(table)
        });
        // -- getRenderPlan --
        /// Returns the current render responsibility plan for active overlay layers.
        /// @return | table | Table with `rendered`, `externally_handled`, and `shader` string arrays.
        /// `rendered` may include `status_color_wash` and `status_texture`; `externally_handled` may include `status_postfx`.
        methods.add_method("getRenderPlan", |lua, this, ()| {
            let plan = this.inner.render_plan();
            let table = lua.create_table()?;
            let rendered = lua.create_table()?;
            for (index, layer) in plan.rendered.iter().enumerate() {
                rendered.set(index + 1, layer.as_str())?;
            }
            let external = lua.create_table()?;
            for (index, layer) in plan.externally_handled.iter().enumerate() {
                external.set(index + 1, layer.as_str())?;
            }
            table.set("rendered", rendered)?;
            table.set("externally_handled", external)?;
            let shader_layers = lua.create_table()?;
            let mut shader_index = 1;
            if this.shader.is_some() {
                shader_layers.set(shader_index, "overlay")?;
                shader_index += 1;
            }
            let mut layers: Vec<_> = this.shader_layers.keys().cloned().collect();
            layers.sort();
            for layer in layers {
                shader_layers.set(shader_index, layer)?;
                shader_index += 1;
            }
            table.set("shader", shader_layers)?;
            Ok(table)
        });
        // -- setStatusEffect --
        /// Creates or updates one overlay-owned status layer such as `frozen`, `poison`, or `lowHealth`.
        /// @param | kind | string | Status kind name.
        /// @param | opts | table | Status options such as intensity, fade, texture, shader, and color.
        methods.add_method_mut("setStatusEffect", |_, this, (kind, opts): (String, LuaTable)| {
            let kind_name = kind.trim().to_ascii_lowercase();
            if kind_name.is_empty() {
                return Err(LuaError::RuntimeError(
                    "LOverlay:setStatusEffect: kind must not be empty".into(),
                ));
            }
            let layer_id = opts
                .get::<_, Option<String>>("id")?
                .unwrap_or_else(|| kind_name.clone());
            let mut layer = this
                .inner
                .status_stack
                .layer(&layer_id)
                .cloned()
                .unwrap_or_else(|| {
                    let mut layer = StatusOverlayLayer::new(layer_id.clone(), kind_name.clone());
                    apply_status_preset(&mut layer);
                    layer
                });
            layer.kind = kind_name;
            if let Some(value) = opts.get::<_, Option<f32>>("intensity")? {
                layer.set_intensity_public(value);
            } else if layer.target_intensity_01 <= 0.0 && layer.intensity_01 <= 0.0 {
                layer.set_intensity_public(STATUS_INTENSITY_MAX);
            }
            if let Some(value) = opts.get::<_, Option<f32>>("fadeIn")? {
                layer.fade_in = non_negative_f32("LOverlay:setStatusEffect", "fadeIn", value)?;
            }
            if let Some(value) = opts.get::<_, Option<f32>>("fadeOut")? {
                layer.fade_out = non_negative_f32("LOverlay:setStatusEffect", "fadeOut", value)?;
            }
            if let Some(value) = opts.get::<_, Option<f32>>("duration")? {
                layer.duration = Some(non_negative_f32("LOverlay:setStatusEffect", "duration", value)?);
            }
            if let Some(value) = opts.get::<_, Option<i32>>("priority")? {
                layer.priority = value;
            }
            if let Some(target) = opts.get::<_, Option<String>>("target")? {
                layer.target = parse_status_target(Some(target))?;
            }
            if let Some(composite) = opts.get::<_, Option<String>>("composite")? {
                layer.composite = parse_status_composite(Some(composite))?;
            }
            if let Some(color_table) = opts.get::<_, Option<LuaTable>>("color")? {
                layer.visual.color = Some(table_to_color(
                    "LOverlay:setStatusEffect",
                    "color",
                    &color_table,
                )?);
            }
            let texture_value = opts.raw_get::<_, LuaValue>("texture")?;
            if !matches!(texture_value, LuaValue::Nil) {
                let texture = texture_from_lua_value(
                    &this.state,
                    "LOverlay:setStatusEffect",
                    texture_value,
                )?;
                layer.visual.texture_key = texture.map(|(key, _)| key);
                layer.visual.texture_size = texture.map(|(_, size)| size);
            }
            if let Some(value) = opts.get::<_, Option<f32>>("textureOpacity")? {
                layer.visual.texture_opacity =
                    unit_f32("LOverlay:setStatusEffect", "textureOpacity", value)?;
            }
            if let Some(shader_name) = opts.get::<_, Option<String>>("shader")? {
                let shader_name = shader_name.trim().to_ascii_lowercase();
                let shader_valid = shader_name == "blur_h"
                    || shader_name == "blur_v"
                    || PostFxEffectType::from_name(&shader_name).is_some();
                if !shader_valid {
                    return Err(LuaError::RuntimeError(format!(
                        "LOverlay:setStatusEffect: unsupported built-in post-fx '{}'",
                        shader_name
                    )));
                }
                layer.visual.shader_effect = Some(shader_name);
            }
            if let Some(value) = opts.get::<_, Option<f32>>("shaderStrength")? {
                layer.visual.shader_strength =
                    non_negative_f32("LOverlay:setStatusEffect", "shaderStrength", value)?;
            }
            this.inner.status_stack.upsert(layer);
            Ok(())
        });
        // -- setStatusIntensity --
        /// Updates one existing status intensity or creates a preset-backed layer when it is missing.
        /// @param | kind | string | Status kind name.
        /// @param | intensity | number | Intensity in `0..1` or `1..10`.
        methods.add_method_mut("setStatusIntensity", |_, this, (kind, intensity): (String, f32)| {
            let kind_name = kind.trim().to_ascii_lowercase();
            if kind_name.is_empty() {
                return Err(LuaError::RuntimeError(
                    "LOverlay:setStatusIntensity: kind must not be empty".into(),
                ));
            }
            let mut layer = this
                .inner
                .status_stack
                .layer(&kind_name)
                .cloned()
                .unwrap_or_else(|| {
                    let mut layer = StatusOverlayLayer::new(kind_name.clone(), kind_name.clone());
                    apply_status_preset(&mut layer);
                    layer
                });
            layer.set_intensity_public(intensity);
            this.inner.status_stack.upsert(layer);
            Ok(())
        });
        // -- clearStatusEffect --
        /// Starts fading out one status layer.
        /// @param | kind | string | Status kind or layer id.
        /// @param | opts | table? | Optional fade-out override table.
        methods.add_method_mut(
            "clearStatusEffect",
            |_, this, (kind, opts): (String, Option<LuaTable>)| {
                let fade_out = match opts {
                    Some(table) => table.get::<_, Option<f32>>("fadeOut")?,
                    None => None,
                };
                this.inner.status_stack.clear_layer(&kind, fade_out);
                Ok(())
            },
        );
        // -- getStatusEffect --
        /// Returns one status layer table or nil.
        /// @param | kind | string | Status kind or layer id.
        /// @return | table? | Layer table when present.
        methods.add_method("getStatusEffect", |lua, this, kind: String| {
            match this.inner.status_stack.layer(&kind) {
                Some(layer) => Ok(Some(status_layer_to_table(lua, layer)?)),
                None => Ok(None),
            }
        });
        // -- getStatusEffects --
        /// Returns all current status layers sorted by priority.
        /// @return | table | Array of status layer tables.
        methods.add_method("getStatusEffects", |lua, this, ()| {
            let table = lua.create_table()?;
            for (index, layer) in this
                .inner
                .status_stack
                .active_layers_sorted()
                .into_iter()
                .enumerate()
            {
                table.set(index + 1, status_layer_to_table(lua, layer)?)?;
            }
            Ok(table)
        });
        // -- clear --
        /// Clears active overlay effects and resets transient state.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.clear();
            Ok(())
        });
        // -- resize --
        /// Resizes the overlay target dimensions.
        /// @param | w | integer | New width in pixels.
        /// @param | h | integer | New height in pixels.
        methods.add_method_mut("resize", |_, this, (w, h): (u32, u32)| {
            let w = positive_u32("LOverlay:resize", "w", w)?;
            let h = positive_u32("LOverlay:resize", "h", h)?;
            this.inner.resize(w, h);
            Ok(())
        });
        // -- getWidth --
        /// Returns the overlay width. This method is available to Lua scripts.
        /// @return | integer | Overlay width in pixels.
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.get_width()));
        // -- getHeight --
        /// Returns the overlay height. This method is available to Lua scripts.
        /// @return | integer | Overlay height in pixels.
        methods.add_method("getHeight", |_, this, ()| Ok(this.inner.get_height()));
        // -- getDimensions --
        /// Returns the overlay dimensions. This method is available to Lua scripts.
        /// @return | integer | Overlay width in pixels.
        /// @return | integer | Overlay height in pixels.
        methods.add_method("getDimensions", |_, this, ()| {
            Ok(this.inner.get_dimensions())
        });
        // -- getFlashAlpha --
        /// Returns the current flash alpha. This method is available to Lua scripts.
        /// @return | number | Flash alpha value.
        methods.add_method("getFlashAlpha", |_, this, ()| {
            Ok(this.inner.get_flash_alpha())
        });
        // -- getLightningAlpha --
        /// Returns the current lightning alpha.
        /// @return | number | Lightning alpha value.
        methods.add_method("getLightningAlpha", |_, this, ()| {
            Ok(this.inner.get_lightning_alpha())
        });
        // -- setAccessibilityPolicy --
        /// Replaces or partially updates the overlay accessibility policy.
        /// @param | policy | table? | Optional policy table; nil resets defaults.
        methods.add_method_mut(
            "setAccessibilityPolicy",
            |_, this, policy_tbl: Option<LuaTable>| {
                let mut policy = if policy_tbl.is_some() {
                    this.inner.accessibility_policy()
                } else {
                    OverlayAccessibilityPolicy::default()
                };
                if let Some(tbl) = policy_tbl {
                    if let Some(value) = tbl.get::<_, Option<bool>>("reduced_motion")? {
                        policy.reduced_motion = value;
                    }
                    if let Some(value) = tbl.get::<_, Option<f32>>("max_flash_alpha")? {
                        policy.max_flash_alpha =
                            unit_f32("LOverlay:setAccessibilityPolicy", "max_flash_alpha", value)?;
                    }
                    if let Some(value) = tbl.get::<_, Option<f32>>("max_flash_duration")? {
                        policy.max_flash_duration = non_negative_f32(
                            "LOverlay:setAccessibilityPolicy",
                            "max_flash_duration",
                            value,
                        )?;
                    }
                    if let Some(value) = tbl.get::<_, Option<f32>>("max_flash_per_second")? {
                        policy.max_flash_per_second = non_negative_f32(
                            "LOverlay:setAccessibilityPolicy",
                            "max_flash_per_second",
                            value,
                        )?;
                    }
                    if let Some(value) = tbl.get::<_, Option<f32>>("max_shake_intensity")? {
                        policy.max_shake_intensity = non_negative_f32(
                            "LOverlay:setAccessibilityPolicy",
                            "max_shake_intensity",
                            value,
                        )?;
                    }
                    if let Some(value) = tbl.get::<_, Option<bool>>("disable_lightning")? {
                        policy.disable_lightning = value;
                    }
                    if let Some(value) = tbl.get::<_, Option<bool>>("disable_film_grain")? {
                        policy.disable_film_grain = value;
                    }
                }
                this.inner.set_accessibility_policy(policy);
                Ok(())
            },
        );
        // -- getAccessibilityPolicy --
        /// Returns the current overlay accessibility policy.
        /// @return | table | Policy table with reduced motion, flash, shake, lightning, and grain controls.
        methods.add_method("getAccessibilityPolicy", |lua, this, ()| {
            let policy = this.inner.accessibility_policy();
            let table = lua.create_table()?;
            table.set("reduced_motion", policy.reduced_motion)?;
            table.set("max_flash_alpha", policy.max_flash_alpha)?;
            table.set("max_flash_duration", policy.max_flash_duration)?;
            table.set("max_flash_per_second", policy.max_flash_per_second)?;
            table.set("max_shake_intensity", policy.max_shake_intensity)?;
            table.set("disable_lightning", policy.disable_lightning)?;
            table.set("disable_film_grain", policy.disable_film_grain)?;
            Ok(table)
        });
        // -- setAmbientEnabled --
        /// Enables or disables overlay ambient color rendering.
        /// @param | v | boolean | New ambient enabled flag.
        methods.add_method_mut("setAmbientEnabled", |_, this, v: bool| {
            this.inner.ambient.enabled = v;
            Ok(())
        });
        // -- isAmbientEnabled --
        /// Returns whether overlay ambient color rendering is enabled.
        /// @return | boolean | True when ambient rendering is enabled.
        methods.add_method("isAmbientEnabled", |_, this, ()| {
            Ok(this.inner.ambient.enabled)
        });
        // -- setAmbientColor --
        /// Sets the overlay ambient color from RGBA channels.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        methods.add_method_mut(
            "setAmbientColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                this.inner.ambient.color = [
                    unit_f32("LOverlay:setAmbientColor", "r", r)?,
                    unit_f32("LOverlay:setAmbientColor", "g", g)?,
                    unit_f32("LOverlay:setAmbientColor", "b", b)?,
                    unit_f32("LOverlay:setAmbientColor", "a", a.unwrap_or(1.0))?,
                ];
                Ok(())
            },
        );
        // -- getAmbientColor --
        /// Returns overlay ambient RGBA color.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getAmbientColor", |_, this, ()| {
            let c = this.inner.ambient.color;
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- pullAmbientFromLight --
        /// Copies ambient color from the shared light world into this overlay.
        methods.add_method_mut("pullAmbientFromLight", |_, this, ()| {
            let st = this.state.borrow();
            this.inner.pull_ambient_from_light(&st.light_world.ambient);
            Ok(())
        });
        // -- pushAmbientToLight --
        /// Copies this overlay ambient color into the shared light world.
        methods.add_method_mut("pushAmbientToLight", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            this.inner
                .push_ambient_to_light(&mut st.light_world.ambient);
            Ok(())
        });
        // -- syncAmbientWithLight --
        /// Resolves overlay and light ambient colors using a named mode and writes both stores.
        /// @param | mode | string | One of `light`, `overlay`, `avg`, `max`, or `min`.
        methods.add_method_mut("syncAmbientWithLight", |_, this, mode: String| {
            let mut st = this.state.borrow_mut();
            this.inner
                .sync_ambient_with_light(&mut st.light_world.ambient, &mode)
                .map_err(LuaError::RuntimeError)
        });
        // -- setTimeOfDay --
        /// Sets the overlay time-of-day value used by ambient effects.
        /// @param | v | number | Time-of-day value stored on the overlay ambient state.
        methods.add_method_mut("setTimeOfDay", |_, this, v: f32| {
            let v = finite_f32("LOverlay:setTimeOfDay", "v", v)?;
            this.inner.ambient.time_of_day = v;
            Ok(())
        });
        // -- getTimeOfDay --
        /// Returns the overlay time-of-day value.
        /// @return | number | Current time-of-day value.
        methods.add_method("getTimeOfDay", |_, this, ()| {
            Ok(this.inner.ambient.time_of_day)
        });
        // -- setFogEnabled --
        /// Enables or disables overlay fog rendering.
        /// @param | v | boolean | New fog enabled flag.
        methods.add_method_mut("setFogEnabled", |_, this, v: bool| {
            this.inner.fog.enabled = v;
            Ok(())
        });
        // -- isFogEnabled --
        /// Returns whether overlay fog rendering is enabled.
        /// @return | boolean | True when fog rendering is enabled.
        methods.add_method("isFogEnabled", |_, this, ()| Ok(this.inner.fog.enabled));
        // -- setFogDensity --
        /// Sets overlay fog density. This method is available to Lua scripts.
        /// @param | v | number | Fog density value.
        methods.add_method_mut("setFogDensity", |_, this, v: f32| {
            this.inner.fog.density = non_negative_f32("LOverlay:setFogDensity", "v", v)?;
            Ok(())
        });
        // -- getFogDensity --
        /// Returns overlay fog density. This method is available to Lua scripts.
        /// @return | number | Current fog density.
        methods.add_method("getFogDensity", |_, this, ()| Ok(this.inner.fog.density));
        // -- setFogColor --
        /// Sets the overlay fog color from RGBA channels.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        methods.add_method_mut(
            "setFogColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                this.inner.fog.color = [
                    unit_f32("LOverlay:setFogColor", "r", r)?,
                    unit_f32("LOverlay:setFogColor", "g", g)?,
                    unit_f32("LOverlay:setFogColor", "b", b)?,
                    unit_f32("LOverlay:setFogColor", "a", a.unwrap_or(1.0))?,
                ];
                Ok(())
            },
        );
        // -- getFogColor --
        /// Returns overlay fog RGBA color. This method is available to Lua scripts.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getFogColor", |_, this, ()| {
            let c = this.inner.fog.color;
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- setHeatHazeEnabled --
        /// Enables or disables overlay heat haze rendering.
        /// @param | v | boolean | New heat haze enabled flag.
        methods.add_method_mut("setHeatHazeEnabled", |_, this, v: bool| {
            this.inner.heat_haze.enabled = v;
            Ok(())
        });
        // -- isHeatHazeEnabled --
        /// Returns whether overlay heat haze rendering is enabled.
        /// @return | boolean | True when heat haze rendering is enabled.
        methods.add_method("isHeatHazeEnabled", |_, this, ()| {
            Ok(this.inner.heat_haze.enabled)
        });
        // -- setHeatHazeIntensity --
        /// Sets overlay heat haze intensity. This method is available to Lua scripts.
        /// @param | v | number | Heat haze intensity value.
        methods.add_method_mut("setHeatHazeIntensity", |_, this, v: f32| {
            this.inner.heat_haze.intensity =
                non_negative_f32("LOverlay:setHeatHazeIntensity", "v", v)?;
            Ok(())
        });
        // -- getHeatHazeIntensity --
        /// Returns overlay heat haze intensity.
        /// @return | number | Current heat haze intensity.
        methods.add_method("getHeatHazeIntensity", |_, this, ()| {
            Ok(this.inner.heat_haze.intensity)
        });
        // -- setVignetteEnabled --
        /// Enables or disables overlay vignette rendering.
        /// @param | v | boolean | New vignette enabled flag.
        methods.add_method_mut("setVignetteEnabled", |_, this, v: bool| {
            this.inner.vignette.enabled = v;
            Ok(())
        });
        // -- isVignetteEnabled --
        /// Returns whether overlay vignette rendering is enabled.
        /// @return | boolean | True when vignette rendering is enabled.
        methods.add_method("isVignetteEnabled", |_, this, ()| {
            Ok(this.inner.vignette.enabled)
        });
        // -- setVignetteStrength --
        /// Sets overlay vignette strength. This method is available to Lua scripts.
        /// @param | v | number | Vignette strength value.
        methods.add_method_mut("setVignetteStrength", |_, this, v: f32| {
            this.inner.vignette.strength = unit_f32("LOverlay:setVignetteStrength", "v", v)?;
            Ok(())
        });
        // -- getVignetteStrength --
        /// Returns overlay vignette strength.
        /// @return | number | Current vignette strength.
        methods.add_method("getVignetteStrength", |_, this, ()| {
            Ok(this.inner.vignette.strength)
        });
        // -- setFilmGrainEnabled --
        /// Enables or disables overlay film grain rendering.
        /// @param | v | boolean | New film grain enabled flag.
        methods.add_method_mut("setFilmGrainEnabled", |_, this, v: bool| {
            this.inner.film_grain.enabled = v;
            Ok(())
        });
        // -- isFilmGrainEnabled --
        /// Returns whether overlay film grain rendering is enabled.
        /// @return | boolean | True when film grain rendering is enabled.
        methods.add_method("isFilmGrainEnabled", |_, this, ()| {
            Ok(this.inner.film_grain.enabled)
        });
        // -- setFilmGrainIntensity --
        /// Sets overlay film grain intensity.
        /// @param | v | number | Film grain intensity value.
        methods.add_method_mut("setFilmGrainIntensity", |_, this, v: f32| {
            this.inner.film_grain.intensity = unit_f32("LOverlay:setFilmGrainIntensity", "v", v)?;
            Ok(())
        });
        // -- getFilmGrainIntensity --
        /// Returns overlay film grain intensity.
        /// @return | number | Current film grain intensity.
        methods.add_method("getFilmGrainIntensity", |_, this, ()| {
            Ok(this.inner.film_grain.intensity)
        });
        // -- setCloudShadows --
        /// Enables or disables overlay cloud shadow rendering.
        /// @param | v | boolean | New cloud shadow enabled flag.
        methods.add_method_mut("setCloudShadows", |_, this, v: bool| {
            this.inner.clouds.enabled = v;
            Ok(())
        });
        // -- isCloudShadowsEnabled --
        /// Returns whether overlay cloud shadow rendering is enabled.
        /// @return | boolean | True when cloud shadow rendering is enabled.
        methods.add_method("isCloudShadowsEnabled", |_, this, ()| {
            Ok(this.inner.clouds.enabled)
        });
        // -- setCloudCount --
        /// Sets the overlay cloud shadow count.
        /// @param | v | integer | Cloud shadow count.
        methods.add_method_mut("setCloudCount", |_, this, v: u32| {
            this.inner.clouds.count = v;
            Ok(())
        });
        // -- getCloudCount --
        /// Returns the overlay cloud shadow count.
        /// @return | integer | Cloud shadow count.
        methods.add_method("getCloudCount", |_, this, ()| Ok(this.inner.clouds.count));
        // -- setCloudSpeed --
        /// Sets cloud shadow movement speed. This method is available to Lua scripts.
        /// @param | v | number | Cloud speed value.
        methods.add_method_mut("setCloudSpeed", |_, this, v: f32| {
            this.inner.clouds.speed = finite_f32("LOverlay:setCloudSpeed", "v", v)?;
            Ok(())
        });
        // -- getCloudSpeed --
        /// Returns cloud shadow movement speed.
        /// @return | number | Cloud speed value.
        methods.add_method("getCloudSpeed", |_, this, ()| Ok(this.inner.clouds.speed));
        // -- setCloudScale --
        /// Sets cloud shadow scale. This method is available to Lua scripts.
        /// @param | v | number | Cloud scale value.
        methods.add_method_mut("setCloudScale", |_, this, v: f32| {
            let v = non_negative_f32("LOverlay:setCloudScale", "v", v)?;
            if v == 0.0 {
                return Err(LuaError::RuntimeError(
                    "LOverlay:setCloudScale: v must be > 0".into(),
                ));
            }
            this.inner.clouds.scale = v;
            Ok(())
        });
        // -- getCloudScale --
        /// Returns cloud shadow scale. This method is available to Lua scripts.
        /// @return | number | Cloud scale value.
        methods.add_method("getCloudScale", |_, this, ()| Ok(this.inner.clouds.scale));
        // -- setCloudOpacity --
        /// Sets cloud shadow opacity. This method is available to Lua scripts.
        /// @param | v | number | Cloud opacity value.
        methods.add_method_mut("setCloudOpacity", |_, this, v: f32| {
            this.inner.clouds.opacity = unit_f32("LOverlay:setCloudOpacity", "v", v)?;
            Ok(())
        });
        // -- getCloudOpacity --
        /// Returns cloud shadow opacity. This method is available to Lua scripts.
        /// @return | number | Cloud opacity value.
        methods.add_method("getCloudOpacity", |_, this, ()| {
            Ok(this.inner.clouds.opacity)
        });
        // -- setWeatherEnabled --
        /// Enables or disables overlay weather rendering.
        /// @param | v | boolean | New weather enabled flag.
        methods.add_method_mut("setWeatherEnabled", |_, this, v: bool| {
            this.inner.weather.enabled = v;
            Ok(())
        });
        // -- isWeatherEnabled --
        /// Returns whether overlay weather rendering is enabled.
        /// @return | boolean | True when weather rendering is enabled.
        methods.add_method("isWeatherEnabled", |_, this, ()| {
            Ok(this.inner.weather.enabled)
        });
        // -- setWeather --
        /// Sets the overlay weather type by name.
        /// @param | name | string | Weather type name recognized by the engine.
        methods.add_method_mut("setWeather", |_, this, name: String| {
            this.inner.weather.weather_type = WeatherType::from_name(&name)
                .ok_or_else(|| LuaError::RuntimeError(format!("unknown weather type: {name}")))?;
            Ok(())
        });
        // -- getWeather --
        /// Returns the overlay weather type name.
        /// @return | string | Current weather type name.
        methods.add_method("getWeather", |_, this, ()| {
            Ok(this.inner.weather.weather_type.name().to_owned())
        });
        // -- setWeatherIntensity --
        /// Sets weather intensity for the current weather type.
        /// @param | v | number | Weather intensity value.
        methods.add_method_mut("setWeatherIntensity", |_, this, v: f32| {
            this.inner.weather.intensity =
                non_negative_f32("LOverlay:setWeatherIntensity", "v", v)?;
            Ok(())
        });
        // -- getWeatherIntensity --
        /// Returns weather intensity for the current weather type.
        /// @return | number | Weather intensity value.
        methods.add_method("getWeatherIntensity", |_, this, ()| {
            Ok(this.inner.weather.intensity)
        });
        // -- setWeatherSeed --
        /// Sets the deterministic overlay weather seed used for future particle sampling.
        /// @param | seed | integer | Non-zero preferred seed value; zero maps to the engine default seed.
        methods.add_method_mut("setWeatherSeed", |_, this, seed: u64| {
            this.inner.weather.set_seed(seed);
            Ok(())
        });
        // -- getWeatherRngState --
        /// Returns the current deterministic overlay weather RNG state.
        /// @return | integer | Current weather RNG state.
        methods.add_method("getWeatherRngState", |_, this, ()| {
            Ok(this.inner.weather.rng_state())
        });
        // -- setWeatherRngState --
        /// Replaces the current deterministic overlay weather RNG state.
        /// @param | state | integer | New weather RNG state; zero maps to the engine default seed.
        methods.add_method_mut("setWeatherRngState", |_, this, state: u64| {
            this.inner.weather.set_rng_state(state);
            Ok(())
        });
        // -- setWindDirection --
        /// Sets the overlay weather wind direction.
        /// @param | v | number | Wind direction value.
        methods.add_method_mut("setWindDirection", |_, this, v: f32| {
            this.inner.weather.wind_direction = finite_f32("LOverlay:setWindDirection", "v", v)?;
            Ok(())
        });
        // -- getWindDirection --
        /// Returns the overlay weather wind direction.
        /// @return | number | Wind direction value.
        methods.add_method("getWindDirection", |_, this, ()| {
            Ok(this.inner.weather.wind_direction)
        });
        // -- setWindSpeed --
        /// Sets the overlay weather wind speed.
        /// @param | v | number | Wind speed value.
        methods.add_method_mut("setWindSpeed", |_, this, v: f32| {
            this.inner.weather.wind_speed = non_negative_f32("LOverlay:setWindSpeed", "v", v)?;
            Ok(())
        });
        // -- getWindSpeed --
        /// Returns the overlay weather wind speed.
        /// @return | number | Wind speed value.
        methods.add_method("getWindSpeed", |_, this, ()| {
            Ok(this.inner.weather.wind_speed)
        });
        // -- setLightningColor --
        /// Sets overlay lightning RGBA color.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        methods.add_method_mut(
            "setLightningColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                this.inner.lightning.color = [
                    unit_f32("LOverlay:setLightningColor", "r", r)?,
                    unit_f32("LOverlay:setLightningColor", "g", g)?,
                    unit_f32("LOverlay:setLightningColor", "b", b)?,
                    unit_f32("LOverlay:setLightningColor", "a", a.unwrap_or(1.0))?,
                ];
                Ok(())
            },
        );
        // -- getLightningColor --
        /// Returns overlay lightning RGBA color.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getLightningColor", |_, this, ()| {
            let c = this.inner.lightning.color;
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- flash --
        /// Starts a short flash overlay with optional alpha and duration.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        /// @param | dur | number? | Duration in seconds, defaulting to 0.2.
        methods.add_method_mut(
            "flash",
            |_, this, (r, g, b, a, dur): (f32, f32, f32, Option<f32>, Option<f32>)| {
                let r = unit_f32("LOverlay:flash", "r", r)?;
                let g = unit_f32("LOverlay:flash", "g", g)?;
                let b = unit_f32("LOverlay:flash", "b", b)?;
                let a = unit_f32("LOverlay:flash", "a", a.unwrap_or(1.0))?;
                let dur = non_negative_f32("LOverlay:flash", "dur", dur.unwrap_or(0.2))?;
                this.inner.trigger_flash(r, g, b, a, dur);
                Ok(())
            },
        );
        // -- isFlashing --
        /// Returns whether the flash overlay is active.
        /// @return | boolean | True while the flash is active.
        methods.add_method("isFlashing", |_, this, ()| Ok(this.inner.flash.active));
        // -- shake --
        /// Starts a screen shake with optional duration.
        /// @param | intensity | number | Shake intensity.
        /// @param | dur | number? | Duration in seconds, defaulting to 0.5.
        methods.add_method_mut("shake", |_, this, (intensity, dur): (f32, Option<f32>)| {
            let intensity = non_negative_f32("LOverlay:shake", "intensity", intensity)?;
            let dur = non_negative_f32("LOverlay:shake", "dur", dur.unwrap_or(0.5))?;
            this.inner.trigger_shake(intensity, dur);
            Ok(())
        });
        // -- isShaking --
        /// Returns whether the screen shake effect is active.
        /// @return | boolean | True while screen shake is active.
        methods.add_method("isShaking", |_, this, ()| Ok(this.inner.shake.active));
        // -- fade --
        /// Starts a fade overlay with optional alpha and duration.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Target alpha, defaulting to 1.0.
        /// @param | dur | number? | Duration in seconds, defaulting to 1.0.
        methods.add_method_mut(
            "fade",
            |_, this, (r, g, b, a, dur): (f32, f32, f32, Option<f32>, Option<f32>)| {
                let r = unit_f32("LOverlay:fade", "r", r)?;
                let g = unit_f32("LOverlay:fade", "g", g)?;
                let b = unit_f32("LOverlay:fade", "b", b)?;
                let a = unit_f32("LOverlay:fade", "a", a.unwrap_or(1.0))?;
                let dur = non_negative_f32("LOverlay:fade", "dur", dur.unwrap_or(1.0))?;
                this.inner.trigger_fade(r, g, b, a, dur);
                Ok(())
            },
        );
        // -- isFading --
        /// Returns whether the fade overlay is active.
        /// @return | boolean | True while fade is active.
        methods.add_method("isFading", |_, this, ()| Ok(this.inner.fade.active));
        // -- render --
        /// Queues renderer commands for the overlay's current visual state.
        methods.add_method("render", |_, this, ()| {
            let mut cmds = this.inner.build_render_commands();
            let mut shader_passes = this.inner.build_postfx_passes();
            if let Some(key) = this.shader {
                shader_passes.push(overlay_shader_pass(
                    format!("overlay_shader_{}", shader_id_from_key(key)),
                    key,
                ));
            }
            let mut layers: Vec<_> = this.shader_layers.iter().collect();
            layers.sort_by(|(left, _), (right, _)| left.cmp(right));
            for (layer, key) in layers {
                shader_passes.push(overlay_shader_pass(
                    format!("overlay_layer_{}_{}", layer, shader_id_from_key(*key)),
                    *key,
                ));
            }
            if !shader_passes.is_empty() {
                cmds.push(RenderCommand::BeginPostFx {
                    stack_id: OVERLAY_SHADER_STACK_ID,
                });
                cmds.push(RenderCommand::EndPostFx {
                    stack_id: OVERLAY_SHADER_STACK_ID,
                });
                cmds.push(RenderCommand::ApplyPostFx {
                    stack_id: OVERLAY_SHADER_STACK_ID,
                    passes: shader_passes,
                    width: this.inner.get_width(),
                    height: this.inner.get_height(),
                });
            }
            this.state.borrow_mut().render_commands.extend(cmds);
            Ok(())
        });
        // -- drawToImage --
        /// Renders overlay state into an image object of the requested size.
        /// @param | w | integer | Target image width in pixels.
        /// @param | h | integer | Target image height in pixels.
        /// @return | Image | Image containing the overlay draw state.
        methods.add_method("drawToImage", |_, this, (w, h): (u32, u32)| {
            let w = positive_u32("LOverlay:drawToImage", "w", w)?;
            let h = positive_u32("LOverlay:drawToImage", "h", h)?;
            let img = this
                .inner
                .try_draw_state_to_image(w, h)
                .map_err(|err| LuaError::RuntimeError(err.to_string()))?;
            Ok(img)
        });
        // -- setWater --
        /// Enables water distortion and sets wave amplitude, frequency, and speed.
        /// @param | amplitude | number | Water wave amplitude.
        /// @param | frequency | number | Water wave frequency.
        /// @param | speed | number | Water animation speed.
        methods.add_method_mut(
            "setWater",
            |_, this, (amplitude, frequency, speed): (f32, f32, f32)| {
                this.inner.water.amplitude =
                    finite_f32("LOverlay:setWater", "amplitude", amplitude)?;
                this.inner.water.frequency =
                    finite_f32("LOverlay:setWater", "frequency", frequency)?;
                this.inner.water.speed = finite_f32("LOverlay:setWater", "speed", speed)?;
                this.inner.water.enabled = true;
                Ok(())
            },
        );
        // -- setWaterTint --
        /// Sets the water tint color and strength.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | strength | number | Tint strength.
        methods.add_method_mut(
            "setWaterTint",
            |_, this, (r, g, b, strength): (f32, f32, f32, f32)| {
                this.inner.water.tint_r = unit_f32("LOverlay:setWaterTint", "r", r)?;
                this.inner.water.tint_g = unit_f32("LOverlay:setWaterTint", "g", g)?;
                this.inner.water.tint_b = unit_f32("LOverlay:setWaterTint", "b", b)?;
                this.inner.water.tint_strength =
                    unit_f32("LOverlay:setWaterTint", "strength", strength)?;
                Ok(())
            },
        );
        // -- setCustomShader --
        /// Sets or clears the custom overlay shader name.
        /// @param | name | string? | Optional shader name; nil clears the custom shader.
        methods.add_method_mut("setCustomShader", |_, this, name: Option<String>| {
            this.inner
                .set_custom_shader(name)
                .map_err(|err| LuaError::RuntimeError(err.to_string()))
        });
        // -- getWater --
        /// Returns a table describing the current water effect settings.
        /// @return | table | Water state table with enabled, wave, tint, depth, and time fields.
        /// @field | enabled | boolean | Whether water effect is enabled.
        /// @field | amplitude | number | Wave amplitude.
        /// @field | frequency | number | Wave frequency.
        /// @field | speed | number | Wave speed.
        /// @field | tint_r | number | Tint red component.
        /// @field | tint_g | number | Tint green component.
        /// @field | tint_b | number | Tint blue component.
        /// @field | tint_strength | number | Tint strength.
        /// @field | depth_r | number | Depth red component.
        /// @field | depth_g | number | Depth green component.
        /// @field | depth_b | number | Depth blue component.
        /// @field | depth_strength | number | Depth strength.
        /// @field | time | number | Elapsed time.
        methods.add_method("getWater", |lua, this, ()| {
            let w = &this.inner.water;
            let t = lua.create_table()?;
            t.set("enabled", w.enabled)?;
            t.set("amplitude", w.amplitude)?;
            t.set("frequency", w.frequency)?;
            t.set("speed", w.speed)?;
            t.set("tint_r", w.tint_r)?;
            t.set("tint_g", w.tint_g)?;
            t.set("tint_b", w.tint_b)?;
            t.set("tint_strength", w.tint_strength)?;
            t.set("depth_r", w.depth_r)?;
            t.set("depth_g", w.depth_g)?;
            t.set("depth_b", w.depth_b)?;
            t.set("depth_strength", w.depth_strength)?;
            t.set("time", w.time)?;
            Ok(t)
        });
        // -- type --
        /// Returns the Lua-visible type name for this overlay handle.
        /// @return | string | The string `LOverlay`.
        methods.add_method("type", |_, _this, ()| Ok("LOverlay"));
        // -- typeOf --
        /// Returns whether this overlay handle matches a supported type name.
        /// @param | name | string | Type name to compare against `Overlay` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _this, name: String| {
            Ok(name == "LObject" || name == "LOverlay")
        });
    }
}
/// Lua-side handle for a timed screen transition effect.
pub struct LuaScreenTransition {
    /// Transition kind, timer, direction, and RGBA color.
    inner: ScreenTransition,
}
/// Provides Lua methods for playing and inspecting screen transitions.
impl mlua::UserData for LuaScreenTransition {
    fn add_methods<'lua, M: mlua::UserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- play --
        /// Starts this screen transition forward from its current state.
        methods.add_method_mut("play", |_, this, ()| {
            this.inner.play();
            Ok(())
        });
        // -- reverse --
        /// Starts this screen transition in reverse from its current state.
        methods.add_method_mut("reverse", |_, this, ()| {
            this.inner.reverse();
            Ok(())
        });
        // -- update --
        /// Advances this transition timer and returns whether it remains active.
        /// @param | dt | number | Delta time in seconds.
        /// @return | boolean | True when the transition is still active after the update.
        methods.add_method_mut("update", |_, this, dt: f32| {
            Ok(this
                .inner
                .update(non_negative_f32("LScreenTransition:update", "dt", dt)?))
        });
        // -- progress --
        /// Returns normalized transition progress.
        /// @return | number | Progress value between the transition start and end.
        methods.add_method("progress", |_, this, ()| Ok(this.inner.progress()));
        // -- isActive --
        /// Returns whether the transition is currently active.
        /// @return | boolean | True when the transition is active.
        methods.add_method("isActive", |_, this, ()| Ok(this.inner.is_active()));
        // -- isDone --
        /// Returns whether the transition has finished.
        /// @return | boolean | True when the transition is complete.
        methods.add_method("isDone", |_, this, ()| Ok(this.inner.is_done()));
        // -- kind --
        /// Returns the transition kind name. This method is available to Lua scripts.
        /// @return | string | Transition kind name.
        methods.add_method("kind", |_, this, ()| Ok(this.inner.kind.name()));
        // -- color --
        /// Returns the transition RGBA color.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("color", |_, this, ()| {
            let c = this.inner.color;
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- setColor --
        /// Sets the transition RGBA color from a numeric array table.
        /// @param | color | table | Numeric color table using indices 1 through 4.
        methods.add_method_mut("setColor", |_, this, ct: mlua::Table| {
            this.inner.color = [
                unit_f32(
                    "LScreenTransition:setColor",
                    "color[1]",
                    ct.get::<_, f32>(1).unwrap_or(0.0),
                )?,
                unit_f32(
                    "LScreenTransition:setColor",
                    "color[2]",
                    ct.get::<_, f32>(2).unwrap_or(0.0),
                )?,
                unit_f32(
                    "LScreenTransition:setColor",
                    "color[3]",
                    ct.get::<_, f32>(3).unwrap_or(0.0),
                )?,
                unit_f32(
                    "LScreenTransition:setColor",
                    "color[4]",
                    ct.get::<_, f32>(4).unwrap_or(1.0),
                )?,
            ];
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this transition handle.
        /// @return | string | The string `LScreenTransition`.
        methods.add_method("type", |_, _, ()| Ok("LScreenTransition"));
        // -- typeOf --
        /// Returns whether this transition handle matches a supported type name.
        /// @param | name | string | Type name to compare against `ScreenTransition` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LScreenTransition" || name == "LObject")
        });
    }
}
/// Registers `lurek.overlay` constructors for overlay and transition objects.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let s = state.clone();
    // -- new --
    /// Creates an overlay controller for screen effects using optional dimensions.
    /// @param | w | integer? | Overlay width in pixels, defaulting to 800.
    /// @param | h | integer? | Overlay height in pixels, defaulting to 600.
    /// @return | LOverlay | New overlay handle.
    tbl.set(
        "new",
        lua.create_function(move |lua, (w, h): (Option<u32>, Option<u32>)| {
            let width = positive_u32("lurek.overlay.new", "w", w.unwrap_or(800))?;
            let height = positive_u32("lurek.overlay.new", "h", h.unwrap_or(600))?;
            lua.create_userdata(LuaOverlay {
                inner: Overlay::new(width, height),
                state: s.clone(),
                shader: None,
                shader_layers: HashMap::new(),
            })
        })?,
    )?;
    // -- newTransition --
    /// Creates a timed screen transition with optional kind, duration, and color.
    /// @param | kind | string? | Transition kind name, defaulting to `fade`.
    /// @param | duration | number? | Duration in seconds, defaulting to 1.0.
    /// @param | color_tbl | table? | Numeric RGBA table using indices 1 through 4.
    /// @return | LScreenTransition | New screen transition handle.
    tbl.set(
        "newTransition",
        lua.create_function(
            move |lua, (kind, duration, color_tbl): (Option<String>, Option<f32>, Option<LuaTable>)| {
                let k = TransitionKind::from_str(kind.as_deref().unwrap_or("fade"));
                let dur = non_negative_f32(
                    "lurek.overlay.newTransition",
                    "duration",
                    duration.unwrap_or(1.0),
                )?;
                let color = if let Some(ct) = color_tbl {
                    [
                        unit_f32(
                            "lurek.overlay.newTransition",
                            "color_tbl[1]",
                            ct.get::<_, f32>(1).unwrap_or(0.0),
                        )?,
                        unit_f32(
                            "lurek.overlay.newTransition",
                            "color_tbl[2]",
                            ct.get::<_, f32>(2).unwrap_or(0.0),
                        )?,
                        unit_f32(
                            "lurek.overlay.newTransition",
                            "color_tbl[3]",
                            ct.get::<_, f32>(3).unwrap_or(0.0),
                        )?,
                        unit_f32(
                            "lurek.overlay.newTransition",
                            "color_tbl[4]",
                            ct.get::<_, f32>(4).unwrap_or(1.0),
                        )?,
                    ]
                } else {
                    [0.0, 0.0, 0.0, 1.0]
                };
                lua.create_userdata(LuaScreenTransition {
                    inner: ScreenTransition::new(k, dur, color),
                })
            },
        )?,
    )?;
    lurek.set("overlay", tbl)?;

    // Compatibility aliases: lurek.effect.newOverlay / lurek.effect.newTransition
    // overlay_api is registered after effect_api, so lurek.effect exists here.
    if let Ok(effect_tbl) = lurek.get::<_, mlua::Table>("effect") {
        let overlay_tbl: mlua::Table = lurek.get("overlay")?;
        effect_tbl.set("newOverlay", overlay_tbl.get::<_, mlua::Function>("new")?)?;
        effect_tbl.set(
            "newTransition",
            overlay_tbl.get::<_, mlua::Function>("newTransition")?,
        )?;
    }

    Ok(())
}
