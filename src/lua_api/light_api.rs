//! Registers the `lurek.light` Lua API for light worlds, occluders, blends, and validated lighting options.

use super::render_api::{ensure_shader_target, shader_key_from_userdata, LuaShader};
use super::SharedState;
use crate::color::Color;
use crate::light::transition::LightTransition;
use crate::light::{
    Attenuation, FalloffMode, FlickerConfig, Light2D, Light2DOptionsPatch, LightBlendMode,
    LightType, Occluder, ShadowFilter,
};
use crate::math::Vec2;
use crate::render::ShaderTarget;
use crate::runtime::resource_keys::{LightKey, OccluderKey};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

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

fn positive_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    let value = finite_f32(api, arg_name, value)?;
    if value > 0.0 {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "{api}: {arg_name} must be > 0"
        )))
    }
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

fn unit_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    Ok(finite_f32(api, arg_name, value)?.clamp(0.0, 1.0))
}

fn optional_f32_field(opts: &LuaTable, field: &str) -> LuaResult<Option<f32>> {
    match opts.get::<_, LuaValue>(field)? {
        LuaValue::Nil => Ok(None),
        LuaValue::Number(value) => Ok(Some(value as f32)),
        LuaValue::Integer(value) => Ok(Some(value as f32)),
        value => Err(LuaError::RuntimeError(format!(
            "expected number for '{}', got {}",
            field,
            value.type_name()
        ))),
    }
}

fn optional_u16_field(opts: &LuaTable, field: &str) -> LuaResult<Option<u16>> {
    match opts.get::<_, LuaValue>(field)? {
        LuaValue::Nil => Ok(None),
        LuaValue::Integer(value) => u16::try_from(value).map(Some).map_err(|_| {
            LuaError::RuntimeError(format!("expected 0..65535 integer for '{}'", field))
        }),
        value => Err(LuaError::RuntimeError(format!(
            "expected integer for '{}', got {}",
            field,
            value.type_name()
        ))),
    }
}

fn optional_bool_field(opts: &LuaTable, field: &str) -> LuaResult<Option<bool>> {
    match opts.get::<_, LuaValue>(field)? {
        LuaValue::Nil => Ok(None),
        LuaValue::Boolean(value) => Ok(Some(value)),
        value => Err(LuaError::RuntimeError(format!(
            "expected boolean for '{}', got {}",
            field,
            value.type_name()
        ))),
    }
}

fn optional_string_field(opts: &LuaTable, field: &str) -> LuaResult<Option<String>> {
    match opts.get::<_, LuaValue>(field)? {
        LuaValue::Nil => Ok(None),
        LuaValue::String(value) => Ok(Some(value.to_str()?.to_string())),
        value => Err(LuaError::RuntimeError(format!(
            "expected string for '{}', got {}",
            field,
            value.type_name()
        ))),
    }
}

fn color_table_channel(tbl: &LuaTable, index: i32, field: &str) -> LuaResult<f32> {
    match tbl.get::<_, LuaValue>(index)? {
        LuaValue::Nil => Ok(1.0),
        LuaValue::Number(value) => unit_f32("lurek.light color table", field, value as f32),
        LuaValue::Integer(value) => unit_f32("lurek.light color table", field, value as f32),
        value => Err(LuaError::RuntimeError(format!(
            "expected numeric color channel for '{}[{}]', got {}",
            field,
            index,
            value.type_name()
        ))),
    }
}
/// Parses a Lua blend mode string into a light blend mode.
fn parse_blend_mode(s: &str) -> LuaResult<LightBlendMode> {
    match s {
        "add" => Ok(LightBlendMode::Add),
        "sub" => Ok(LightBlendMode::Sub),
        "mix" => Ok(LightBlendMode::Mix),
        _ => Err(LuaError::RuntimeError(format!(
            "invalid blend mode '{}', expected 'add', 'sub', or 'mix'",
            s
        ))),
    }
}
/// Converts a light blend mode to its Lua string name.
fn blend_mode_to_str(mode: LightBlendMode) -> &'static str {
    match mode {
        LightBlendMode::Add => "add",
        LightBlendMode::Sub => "sub",
        LightBlendMode::Mix => "mix",
    }
}
/// Parses a Lua falloff string into a light falloff mode.
fn parse_falloff(s: &str) -> LuaResult<FalloffMode> {
    match s {
        "linear" => Ok(FalloffMode::Linear),
        "smooth" => Ok(FalloffMode::Smooth),
        "constant" => Ok(FalloffMode::Constant),
        _ => Err(LuaError::RuntimeError(format!(
            "invalid falloff '{}', expected 'linear', 'smooth', or 'constant'",
            s
        ))),
    }
}
/// Converts a falloff mode to its Lua string name.
fn falloff_to_str(mode: FalloffMode) -> &'static str {
    match mode {
        FalloffMode::Linear => "linear",
        FalloffMode::Smooth => "smooth",
        FalloffMode::Constant => "constant",
    }
}
/// Parses a Lua shadow filter string into a shadow filter mode.
fn parse_shadow_filter(s: &str) -> LuaResult<ShadowFilter> {
    match s {
        "none" => Ok(ShadowFilter::None),
        "pcf5" => Ok(ShadowFilter::Pcf5),
        "pcf13" => Ok(ShadowFilter::Pcf13),
        _ => Err(LuaError::RuntimeError(format!(
            "invalid shadow filter '{}', expected 'none', 'pcf5', or 'pcf13'",
            s
        ))),
    }
}
/// Converts a shadow filter to its Lua string name.
fn shadow_filter_to_str(filter: ShadowFilter) -> &'static str {
    match filter {
        ShadowFilter::None => "none",
        ShadowFilter::Pcf5 => "pcf5",
        ShadowFilter::Pcf13 => "pcf13",
    }
}
/// Parses a Lua light type string into a light type.
fn parse_light_type(s: &str) -> LuaResult<LightType> {
    match s {
        "point" => Ok(LightType::Point),
        "directional" => Ok(LightType::Directional),
        "spot" => Ok(LightType::Spot),
        _ => Err(LuaError::RuntimeError(format!(
            "invalid light type '{}', expected 'point', 'directional', or 'spot'",
            s
        ))),
    }
}
/// Converts a light type to its Lua string name.
fn light_type_to_str(lt: LightType) -> &'static str {
    match lt {
        LightType::Point => "point",
        LightType::Directional => "directional",
        LightType::Spot => "spot",
    }
}
/// Builds a Lua error for an invalid or removed light handle.
fn invalid_light(method: &str) -> LuaError {
    LuaError::RuntimeError(format!(
        "{}: invalid or already-removed light handle",
        method
    ))
}
/// Builds a Lua error for an invalid or removed occluder handle.
fn invalid_occluder(method: &str) -> LuaError {
    LuaError::RuntimeError(format!(
        "{}: invalid or already-removed occluder handle",
        method
    ))
}
/// Reads an optional RGBA color table from an options table field.
fn parse_opt_color(opts: &LuaTable, field: &str) -> LuaResult<Option<Color>> {
    let val: LuaValue = opts.get(field)?;
    match val {
        LuaValue::Table(tbl) => {
            let r = color_table_channel(&tbl, 1, field)?;
            let g = color_table_channel(&tbl, 2, field)?;
            let b = color_table_channel(&tbl, 3, field)?;
            let a = color_table_channel(&tbl, 4, field)?;
            Ok(Some(Color::new(r, g, b, a)))
        }
        LuaValue::Nil => Ok(None),
        _ => Err(LuaError::RuntimeError(format!(
            "expected color table for '{}', got {}",
            field,
            val.type_name()
        ))),
    }
}
/// Applies Lua light option fields to a light instance.
fn apply_light_opts(light: &mut Light2D, opts: &LuaTable) -> LuaResult<()> {
    light.apply_options_patch(light_options_patch(opts)?);
    Ok(())
}

fn light_options_patch(opts: &LuaTable) -> LuaResult<Light2DOptionsPatch> {
    let mut patch = Light2DOptionsPatch::default();
    parse_light_basic_opts(&mut patch, opts)?;
    parse_light_shadow_opts(&mut patch, opts)?;
    parse_light_shape_opts(&mut patch, opts)?;
    parse_light_effect_opts(&mut patch, opts)?;
    parse_light_attenuation_opts(&mut patch, opts)?;
    Ok(patch)
}

fn parse_light_basic_opts(patch: &mut Light2DOptionsPatch, opts: &LuaTable) -> LuaResult<()> {
    if let Some(c) = parse_opt_color(opts, "color")? {
        patch.color = Some(c);
    }
    if let Some(v) = optional_f32_field(opts, "intensity")? {
        patch.intensity = Some(non_negative_f32(
            "lurek.light.newLight",
            "opts.intensity",
            v,
        )?);
    }
    if let Some(v) = optional_f32_field(opts, "energy")? {
        patch.energy = Some(non_negative_f32("lurek.light.newLight", "opts.energy", v)?);
    }
    if let Some(s) = optional_string_field(opts, "blend")? {
        patch.blend_mode = Some(parse_blend_mode(&s)?);
    }
    if let Some(s) = optional_string_field(opts, "falloff")? {
        patch.falloff = Some(parse_falloff(&s)?);
    }
    if let Some(v) = optional_bool_field(opts, "enabled")? {
        patch.enabled = Some(v);
    }
    Ok(())
}

fn parse_light_shadow_opts(patch: &mut Light2DOptionsPatch, opts: &LuaTable) -> LuaResult<()> {
    if let Some(v) = optional_bool_field(opts, "shadowEnabled")? {
        patch.shadow_enabled = Some(v);
    }
    if let Some(c) = parse_opt_color(opts, "shadowColor")? {
        patch.shadow_color = Some(c);
    }
    if let Some(s) = optional_string_field(opts, "shadowFilter")? {
        patch.shadow_filter = Some(parse_shadow_filter(&s)?);
    }
    if let Some(v) = optional_f32_field(opts, "shadowSmooth")? {
        patch.shadow_smooth = Some(non_negative_f32(
            "lurek.light.newLight",
            "opts.shadowSmooth",
            v,
        )?);
    }
    if let Some(v) = optional_f32_field(opts, "shadowSoftness")? {
        patch.shadow_softness = Some(non_negative_f32(
            "lurek.light.newLight",
            "opts.shadowSoftness",
            v,
        )?);
    }
    if let Some(v) = optional_u16_field(opts, "lightMask")? {
        patch.light_mask = Some(v);
    }
    if let Some(v) = optional_u16_field(opts, "shadowMask")? {
        patch.shadow_mask = Some(v);
    }
    Ok(())
}

fn parse_light_shape_opts(patch: &mut Light2DOptionsPatch, opts: &LuaTable) -> LuaResult<()> {
    if let Some(s) = optional_string_field(opts, "type")? {
        patch.light_type = Some(parse_light_type(&s)?);
    }
    if let Some(v) = optional_f32_field(opts, "direction")? {
        patch.direction = Some(finite_f32("lurek.light.newLight", "opts.direction", v)?);
    }
    if let Some(v) = optional_f32_field(opts, "innerAngle")? {
        patch.inner_angle = Some(non_negative_f32(
            "lurek.light.newLight",
            "opts.innerAngle",
            v,
        )?);
    }
    if let Some(v) = optional_f32_field(opts, "outerAngle")? {
        patch.outer_angle = Some(non_negative_f32(
            "lurek.light.newLight",
            "opts.outerAngle",
            v,
        )?);
    }
    if let Some(v) = optional_u16_field(opts, "groupId")? {
        patch.group_id = Some(v);
    }
    if let Some(v) = optional_bool_field(opts, "volumetric")? {
        patch.volumetric = Some(v);
    }
    Ok(())
}

fn parse_light_effect_opts(patch: &mut Light2DOptionsPatch, opts: &LuaTable) -> LuaResult<()> {
    if let Some(v) = optional_f32_field(opts, "flickerSpeed")? {
        patch.flicker_speed = Some(non_negative_f32(
            "lurek.light.newLight",
            "opts.flickerSpeed",
            v,
        )?);
    }
    if let Some(v) = optional_f32_field(opts, "flickerStrength")? {
        patch.flicker_strength = Some(non_negative_f32(
            "lurek.light.newLight",
            "opts.flickerStrength",
            v,
        )?);
    }
    if let Some(path) = optional_string_field(opts, "normalMap")? {
        patch.normal_map_path = Some(path);
    }
    if let Some(v) = optional_f32_field(opts, "normalStrength")? {
        patch.normal_strength = Some(unit_f32("lurek.light.newLight", "opts.normalStrength", v)?);
    }
    Ok(())
}

fn parse_light_attenuation_opts(patch: &mut Light2DOptionsPatch, opts: &LuaTable) -> LuaResult<()> {
    if let Some(v) = optional_f32_field(opts, "attConstant")? {
        patch.attenuation.constant = Some(non_negative_f32(
            "lurek.light.newLight",
            "opts.attConstant",
            v,
        )?);
    }
    if let Some(v) = optional_f32_field(opts, "attLinear")? {
        patch.attenuation.linear = Some(non_negative_f32(
            "lurek.light.newLight",
            "opts.attLinear",
            v,
        )?);
    }
    if let Some(v) = optional_f32_field(opts, "attQuadratic")? {
        patch.attenuation.quadratic = Some(non_negative_f32(
            "lurek.light.newLight",
            "opts.attQuadratic",
            v,
        )?);
    }
    Ok(())
}
/// Applies Lua occluder option fields to an occluder instance.
fn apply_occluder_opts(occ: &mut Occluder, opts: &LuaTable) -> LuaResult<()> {
    if let Ok(v) = opts.get::<_, f32>("opacity") {
        occ.set_opacity(v);
    }
    if let Ok(v) = opts.get::<_, u16>("lightMask") {
        occ.set_light_mask(v);
    }
    if let Ok(v) = opts.get::<_, bool>("enabled") {
        occ.set_enabled(v);
    }
    Ok(())
}
#[derive(Clone)]
/// Lua-side handle for a light stored in the shared light world.
pub struct LuaLight {
    /// Shared runtime state containing the light world.
    state: Rc<RefCell<SharedState>>,
    /// Slot-map key identifying the light inside the light world.
    key: LightKey,
    /// Optional active transition for color, intensity, and radius.
    transition: RefCell<Option<LightTransition>>,
    /// Optional cookie texture path associated with this light.
    cookie_path: RefCell<Option<String>>,
}

/// Create a Lua light handle by inserting a prepared light into the shared light world.
pub(crate) fn lua_light_from_light(state: Rc<RefCell<SharedState>>, light: Light2D) -> LuaLight {
    let mut st = state.borrow_mut();
    let key = st.light_world.add_light(light);
    st.light_world.reindex_flickers();
    drop(st);
    LuaLight {
        state,
        key,
        transition: RefCell::new(None),
        cookie_path: RefCell::new(None),
    }
}

/// Provides Lua methods for editing, animating, and inspecting one light.
impl LuaUserData for LuaLight {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setPosition --
        /// Sets this light position. This method is available to Lua scripts.
        /// @param | x | number | Light x coordinate.
        /// @param | y | number | Light y coordinate.
        methods.add_method("setPosition", |_, this, (x, y): (f32, f32)| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setPosition"))?;
            light.set_position(x, y);
            Ok(())
        });
        // -- getPosition --
        /// Returns this light position. This method is available to Lua scripts.
        /// @return | number | Light x coordinate.
        /// @return | number | Light y coordinate.
        methods.add_method("getPosition", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getPosition"))?;
            Ok(light.get_position())
        });
        // -- setRadius --
        /// Sets this light radius. This method is available to Lua scripts.
        /// @param | r | number | Radius value.
        methods.add_method("setRadius", |_, this, r: f32| {
            let r = positive_f32("Light:setRadius", "r", r)?;
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setRadius"))?;
            light.set_radius(r);
            Ok(())
        });
        // -- getRadius --
        /// Returns this light radius. This method is available to Lua scripts.
        /// @return | number | Radius value.
        methods.add_method("getRadius", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getRadius"))?;
            Ok(light.get_radius())
        });
        // -- setColor --
        /// Sets this light RGBA color. This method is available to Lua scripts.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        methods.add_method(
            "setColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                let r = unit_f32("Light:setColor", "r", r)?;
                let g = unit_f32("Light:setColor", "g", g)?;
                let b = unit_f32("Light:setColor", "b", b)?;
                let a = unit_f32("Light:setColor", "a", a.unwrap_or(1.0))?;
                let mut st = this.state.borrow_mut();
                let light = st
                    .light_world
                    .get_light_mut(this.key)
                    .ok_or_else(|| invalid_light("Light:setColor"))?;
                light.set_color(Color::new(r, g, b, a));
                Ok(())
            },
        );
        // -- getColor --
        /// Returns this light RGBA color. This method is available to Lua scripts.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getColor", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getColor"))?;
            let c = light.get_color();
            Ok((c.r, c.g, c.b, c.a))
        });
        // -- setIntensity --
        /// Sets this light intensity. This method is available to Lua scripts.
        /// @param | i | number | Intensity value.
        methods.add_method("setIntensity", |_, this, i: f32| {
            let i = non_negative_f32("Light:setIntensity", "i", i)?;
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setIntensity"))?;
            light.set_intensity(i);
            Ok(())
        });
        // -- getIntensity --
        /// Returns this light intensity. This method is available to Lua scripts.
        /// @return | number | Intensity value.
        methods.add_method("getIntensity", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getIntensity"))?;
            Ok(light.get_intensity())
        });
        // -- setEnergy --
        /// Sets this light energy value. This method is available to Lua scripts.
        /// @param | e | number | Energy value.
        methods.add_method("setEnergy", |_, this, e: f32| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setEnergy"))?;
            light.set_energy(e);
            Ok(())
        });
        // -- getEnergy --
        /// Returns this light energy value. This method is available to Lua scripts.
        /// @return | number | Energy value.
        methods.add_method("getEnergy", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getEnergy"))?;
            Ok(light.get_energy())
        });
        // -- setBlendMode --
        /// Sets this light blend mode. This method is available to Lua scripts.
        /// @param | mode | string | Blend mode `add`, `sub`, or `mix`.
        methods.add_method("setBlendMode", |_, this, mode: String| {
            let bm = parse_blend_mode(&mode)?;
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setBlendMode"))?;
            light.set_blend_mode(bm);
            Ok(())
        });
        // -- getBlendMode --
        /// Returns this light blend mode string.
        /// @return | string | Blend mode `add`, `sub`, or `mix`.
        methods.add_method("getBlendMode", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getBlendMode"))?;
            Ok(blend_mode_to_str(light.get_blend_mode()).to_string())
        });
        // -- setFalloff --
        /// Sets this light falloff mode. This method is available to Lua scripts.
        /// @param | mode | string | Falloff mode `linear`, `smooth`, or `constant`.
        methods.add_method("setFalloff", |_, this, mode: String| {
            let fm = parse_falloff(&mode)?;
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setFalloff"))?;
            light.set_falloff(fm);
            Ok(())
        });
        // -- getFalloff --
        /// Returns this light falloff mode string.
        /// @return | string | Falloff mode `linear`, `smooth`, or `constant`.
        methods.add_method("getFalloff", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getFalloff"))?;
            Ok(falloff_to_str(light.get_falloff()).to_string())
        });
        // -- setShadowEnabled --
        /// Enables or disables shadow casting for this light.
        /// @param | b | boolean | New shadow enabled flag.
        methods.add_method("setShadowEnabled", |_, this, b: bool| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setShadowEnabled"))?;
            light.set_shadow_enabled(b);
            Ok(())
        });
        // -- isShadowEnabled --
        /// Returns whether this light casts shadows.
        /// @return | boolean | True when shadows are enabled.
        methods.add_method("isShadowEnabled", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:isShadowEnabled"))?;
            Ok(light.is_shadow_enabled())
        });
        // -- setShadowColor --
        /// Sets this light shadow RGBA color. This method is available to Lua scripts.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        methods.add_method(
            "setShadowColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                let mut st = this.state.borrow_mut();
                let light = st
                    .light_world
                    .get_light_mut(this.key)
                    .ok_or_else(|| invalid_light("Light:setShadowColor"))?;
                light.set_shadow_color(Color::new(r, g, b, a.unwrap_or(1.0)));
                Ok(())
            },
        );
        // -- getShadowColor --
        /// Returns this light shadow RGBA color.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getShadowColor", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getShadowColor"))?;
            let c = light.get_shadow_color();
            Ok((c.r, c.g, c.b, c.a))
        });
        // -- setShadowFilter --
        /// Sets this light shadow filter. This method is available to Lua scripts.
        /// @param | filter | string | Shadow filter `none`, `pcf5`, or `pcf13`.
        methods.add_method("setShadowFilter", |_, this, filter: String| {
            let sf = parse_shadow_filter(&filter)?;
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setShadowFilter"))?;
            light.set_shadow_filter(sf);
            Ok(())
        });
        // -- getShadowFilter --
        /// Returns this light shadow filter string.
        /// @return | string | Shadow filter `none`, `pcf5`, or `pcf13`.
        methods.add_method("getShadowFilter", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getShadowFilter"))?;
            Ok(shadow_filter_to_str(light.get_shadow_filter()).to_string())
        });
        // -- setShadowSmooth --
        /// Sets this light shadow smoothing value.
        /// @param | s | number | Shadow smoothing value.
        methods.add_method("setShadowSmooth", |_, this, s: f32| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setShadowSmooth"))?;
            light.set_shadow_smooth(s);
            Ok(())
        });
        // -- getShadowSmooth --
        /// Returns this light shadow smoothing value.
        /// @return | number | Shadow smoothing value.
        methods.add_method("getShadowSmooth", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getShadowSmooth"))?;
            Ok(light.get_shadow_smooth())
        });
        // -- setShadowSoftness --
        /// Sets this light shadow softness value.
        /// @param | softness | number | Shadow softness value.
        methods.add_method("setShadowSoftness", |_, this, softness: f32| {
            let softness = non_negative_f32("Light:setShadowSoftness", "softness", softness)?;
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setShadowSoftness"))?;
            light.set_shadow_softness(softness);
            Ok(())
        });
        // -- getShadowSoftness --
        /// Returns this light shadow softness value.
        /// @return | number | Shadow softness value.
        methods.add_method("getShadowSoftness", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getShadowSoftness"))?;
            Ok(light.get_shadow_softness())
        });
        // -- setLightMask --
        /// Sets this light's inclusion mask. This method is available to Lua scripts.
        /// @param | mask | integer | Light mask bits.
        methods.add_method("setLightMask", |_, this, mask: u16| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setLightMask"))?;
            light.set_light_mask(mask);
            Ok(())
        });
        // -- getLightMask --
        /// Returns this light's inclusion mask.
        /// @return | integer | Light mask bits.
        methods.add_method("getLightMask", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getLightMask"))?;
            Ok(light.get_light_mask())
        });
        // -- setShadowMask --
        /// Sets this light's shadow receiver mask.
        /// @param | mask | integer | Shadow mask bits.
        methods.add_method("setShadowMask", |_, this, mask: u16| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setShadowMask"))?;
            light.set_shadow_mask(mask);
            Ok(())
        });
        // -- getShadowMask --
        /// Returns this light's shadow receiver mask.
        /// @return | integer | Shadow mask bits.
        methods.add_method("getShadowMask", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getShadowMask"))?;
            Ok(light.get_shadow_mask())
        });
        // -- setEnabled --
        /// Enables or disables this light. This method is available to Lua scripts.
        /// @param | b | boolean | New enabled flag.
        methods.add_method("setEnabled", |_, this, b: bool| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setEnabled"))?;
            light.set_enabled(b);
            Ok(())
        });
        // -- isEnabled --
        /// Returns whether this light is enabled.
        /// @return | boolean | True when the light is enabled.
        methods.add_method("isEnabled", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:isEnabled"))?;
            Ok(light.is_enabled())
        });
        // -- setLightType --
        /// Sets this light type. This method is available to Lua scripts.
        /// @param | t | string | Light type `point`, `directional`, or `spot`.
        methods.add_method("setLightType", |_, this, t: String| {
            let lt = parse_light_type(&t)?;
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setLightType"))?;
            light.set_light_type(lt);
            Ok(())
        });
        // -- getLightType --
        /// Returns this light type string. This method is available to Lua scripts.
        /// @return | string | Light type `point`, `directional`, or `spot`.
        methods.add_method("getLightType", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getLightType"))?;
            Ok(light_type_to_str(light.get_light_type()).to_string())
        });
        // -- setDirection --
        /// Sets this light direction angle. This method is available to Lua scripts.
        /// @param | dir | number | Direction angle in radians or engine units.
        methods.add_method("setDirection", |_, this, dir: f32| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setDirection"))?;
            light.set_direction(dir);
            Ok(())
        });
        // -- getDirection --
        /// Returns this light direction angle.
        /// @return | number | Direction angle.
        methods.add_method("getDirection", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getDirection"))?;
            Ok(light.get_direction())
        });
        // -- setInnerAngle --
        /// Sets this spot light inner cone angle.
        /// @param | a | number | Inner angle.
        methods.add_method("setInnerAngle", |_, this, a: f32| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setInnerAngle"))?;
            light.set_inner_angle(a);
            Ok(())
        });
        // -- getInnerAngle --
        /// Returns this spot light inner cone angle.
        /// @return | number | Inner angle.
        methods.add_method("getInnerAngle", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getInnerAngle"))?;
            Ok(light.get_inner_angle())
        });
        // -- setOuterAngle --
        /// Sets this spot light outer cone angle.
        /// @param | a | number | Outer angle.
        methods.add_method("setOuterAngle", |_, this, a: f32| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setOuterAngle"))?;
            light.set_outer_angle(a);
            Ok(())
        });
        // -- getOuterAngle --
        /// Returns this spot light outer cone angle.
        /// @return | number | Outer angle.
        methods.add_method("getOuterAngle", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getOuterAngle"))?;
            Ok(light.get_outer_angle())
        });
        // -- setAttenuation --
        /// Sets this light attenuation coefficients.
        /// @param | c | number | Constant coefficient.
        /// @param | l | number | Linear coefficient.
        /// @param | q | number | Quadratic coefficient.
        methods.add_method("setAttenuation", |_, this, (c, l, q): (f32, f32, f32)| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setAttenuation"))?;
            light.set_attenuation(Attenuation::new(c, l, q));
            Ok(())
        });
        // -- getAttenuation --
        /// Returns this light attenuation coefficients.
        /// @return | number | Constant coefficient.
        /// @return | number | Linear coefficient.
        /// @return | number | Quadratic coefficient.
        methods.add_method("getAttenuation", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getAttenuation"))?;
            let a = light.get_attenuation();
            Ok((a.constant, a.linear, a.quadratic))
        });
        // -- setFlicker --
        /// Configures flicker speed and strength for this light.
        /// @param | speed | number | Flicker speed.
        /// @param | strength | number | Flicker strength.
        methods.add_method("setFlicker", |_, this, (speed, strength): (f32, f32)| {
            let speed = non_negative_f32("Light:setFlicker", "speed", speed)?;
            let strength = non_negative_f32("Light:setFlicker", "strength", strength)?;
            let mut st = this.state.borrow_mut();
            {
                let light = st
                    .light_world
                    .get_light_mut(this.key)
                    .ok_or_else(|| invalid_light("Light:setFlicker"))?;
                *light.flicker_mut() = FlickerConfig::new(speed, strength);
            }
            st.light_world.reindex_flickers();
            Ok(())
        });
        // -- getFlicker --
        /// Returns this light flicker speed and strength.
        /// @return | number | Flicker speed.
        /// @return | number | Flicker strength.
        methods.add_method("getFlicker", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getFlicker"))?;
            let f = light.flicker();
            Ok((f.speed, f.strength))
        });
        // -- setFlickerEnabled --
        /// Enables or disables this light flicker state.
        /// @param | b | boolean | New flicker enabled flag.
        methods.add_method("setFlickerEnabled", |_, this, b: bool| {
            let mut st = this.state.borrow_mut();
            {
                let light = st
                    .light_world
                    .get_light_mut(this.key)
                    .ok_or_else(|| invalid_light("Light:setFlickerEnabled"))?;
                light.flicker_mut().enabled = b;
            }
            st.light_world.reindex_flickers();
            Ok(())
        });
        // -- isFlickerEnabled --
        /// Returns whether this light flicker is enabled.
        /// @return | boolean | True when flicker is enabled.
        methods.add_method("isFlickerEnabled", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:isFlickerEnabled"))?;
            Ok(light.flicker().enabled)
        });
        // -- setGroupId --
        /// Sets this light group id. This method is available to Lua scripts.
        /// @param | id | integer | Group id.
        methods.add_method("setGroupId", |_, this, id: u16| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setGroupId"))?;
            light.set_group_id(id);
            Ok(())
        });
        // -- getGroupId --
        /// Returns this light group id. This method is available to Lua scripts.
        /// @return | integer | Group id.
        methods.add_method("getGroupId", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getGroupId"))?;
            Ok(light.get_group_id())
        });
        // -- setVolumetric --
        /// Enables or disables volumetric behavior for this light.
        /// @param | b | boolean | New volumetric flag.
        methods.add_method("setVolumetric", |_, this, b: bool| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setVolumetric"))?;
            light.set_volumetric(b);
            Ok(())
        });
        // -- isVolumetric --
        /// Returns whether this light is volumetric.
        /// @return | boolean | True when volumetric behavior is enabled.
        methods.add_method("isVolumetric", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:isVolumetric"))?;
            Ok(light.is_volumetric())
        });
        // -- remove --
        /// Removes this light from the shared light world.
        methods.add_method("remove", |_, this, ()| {
            this.state.borrow_mut().light_world.remove_light(this.key);
            Ok(())
        });
        // -- isValid --
        /// Returns whether this light handle still points to a live light.
        /// @return | boolean | True when the light still exists.
        methods.add_method("isValid", |_, this, ()| {
            Ok(this
                .state
                .borrow()
                .light_world
                .lights
                .contains_key(this.key))
        });
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            let st = this.state.borrow();
            match st.light_world.get_light(this.key) {
                Some(l) => Ok(format!("Light({}, {}, r={})", l.x, l.y, l.radius)),
                None => Ok("Light(invalid)".to_string()),
            }
        });
        // -- addFlicker --
        /// Adds flicker from min/max intensity range and frequency.
        /// @param | min | number | Minimum flicker range value.
        /// @param | max | number | Maximum flicker range value.
        /// @param | hz | number | Flicker frequency in hertz.
        methods.add_method("addFlicker", |_, this, (min, max, hz): (f32, f32, f32)| {
            let min = finite_f32("Light:addFlicker", "min", min)?;
            let max = finite_f32("Light:addFlicker", "max", max)?;
            let hz = non_negative_f32("Light:addFlicker", "hz", hz)?;
            let strength = ((max - min) / 2.0).abs();
            let speed = hz * std::f32::consts::TAU;
            let mut st = this.state.borrow_mut();
            {
                let light = st
                    .light_world
                    .get_light_mut(this.key)
                    .ok_or_else(|| invalid_light("Light:addFlicker"))?;
                *light.flicker_mut() = FlickerConfig::new(speed, strength);
            }
            st.light_world.reindex_flickers();
            Ok(())
        });
        // -- transitionTo --
        /// Starts a transition toward target color, intensity, and radius values.
        /// @param | target | table | Target table with optional `color`, `intensity`, and `radius` fields.
        /// @param | duration | number | Transition duration in seconds.
        methods.add_method(
            "transitionTo",
            |_, this, (target, duration): (LuaTable, f32)| {
                let duration = positive_f32("Light:transitionTo", "duration", duration)?;
                let st = this.state.borrow();
                let light = st
                    .light_world
                    .get_light(this.key)
                    .ok_or_else(|| invalid_light("Light:transitionTo"))?;
                let from_color = [light.color.r, light.color.g, light.color.b, light.color.a];
                let from_intensity = light.intensity;
                let from_radius = light.radius;
                drop(st);
                let to_color: [f32; 4] = match target.get::<_, LuaValue>("color")? {
                    LuaValue::Nil => from_color,
                    LuaValue::Table(ct) => {
                        let channel_or = |index: i32, default: f32| -> LuaResult<f32> {
                            match ct.get::<_, LuaValue>(index)? {
                                LuaValue::Nil => Ok(default),
                                LuaValue::Number(value) => {
                                    unit_f32("Light:transitionTo", "target.color", value as f32)
                                }
                                LuaValue::Integer(value) => {
                                    unit_f32("Light:transitionTo", "target.color", value as f32)
                                }
                                value => Err(LuaError::RuntimeError(format!(
                                    "Light:transitionTo: target.color[{}] must be numeric, got {}",
                                    index,
                                    value.type_name()
                                ))),
                            }
                        };
                        [
                            channel_or(1, from_color[0])?,
                            channel_or(2, from_color[1])?,
                            channel_or(3, from_color[2])?,
                            channel_or(4, from_color[3])?,
                        ]
                    }
                    value => {
                        return Err(LuaError::RuntimeError(format!(
                            "Light:transitionTo: target.color must be a table, got {}",
                            value.type_name()
                        )))
                    }
                };
                let to_intensity = match target.get::<_, LuaValue>("intensity")? {
                    LuaValue::Nil => from_intensity,
                    LuaValue::Number(value) => {
                        non_negative_f32("Light:transitionTo", "target.intensity", value as f32)?
                    }
                    LuaValue::Integer(value) => {
                        non_negative_f32("Light:transitionTo", "target.intensity", value as f32)?
                    }
                    value => {
                        return Err(LuaError::RuntimeError(format!(
                            "Light:transitionTo: target.intensity must be numeric, got {}",
                            value.type_name()
                        )))
                    }
                };
                let to_radius = match target.get::<_, LuaValue>("radius")? {
                    LuaValue::Nil => from_radius,
                    LuaValue::Number(value) => {
                        positive_f32("Light:transitionTo", "target.radius", value as f32)?
                    }
                    LuaValue::Integer(value) => {
                        positive_f32("Light:transitionTo", "target.radius", value as f32)?
                    }
                    value => {
                        return Err(LuaError::RuntimeError(format!(
                            "Light:transitionTo: target.radius must be numeric, got {}",
                            value.type_name()
                        )))
                    }
                };
                *this.transition.borrow_mut() = Some(LightTransition::new(
                    from_color,
                    to_color,
                    from_intensity,
                    to_intensity,
                    from_radius,
                    to_radius,
                    duration,
                ));
                Ok(())
            },
        );
        // -- updateTransition --
        /// Advances this light's active transition and applies interpolated values.
        /// @param | dt | number | Delta time in seconds.
        /// @return | boolean | True when a transition value was applied.
        methods.add_method("updateTransition", |_, this, dt: f32| {
            let result = this
                .transition
                .borrow_mut()
                .as_mut()
                .and_then(|t| t.update(dt));
            if let Some((color, intensity, radius)) = result {
                let mut st = this.state.borrow_mut();
                if let Some(light) = st.light_world.get_light_mut(this.key) {
                    light.color.r = color[0];
                    light.color.g = color[1];
                    light.color.b = color[2];
                    light.color.a = color[3];
                    light.intensity = intensity;
                    light.set_radius(radius);
                }
                Ok(true)
            } else {
                Ok(false)
            }
        });
        // -- stopTransition --
        /// Stops and clears this light's active transition.
        methods.add_method("stopTransition", |_, this, ()| {
            this.transition.borrow_mut().take();
            Ok(())
        });
        // -- transitionProgress --
        /// Returns active transition progress or 1.0 when no transition is active.
        /// @return | number | Transition progress.
        methods.add_method("transitionProgress", |_, this, ()| {
            Ok(this
                .transition
                .borrow()
                .as_ref()
                .map(|t| t.progress())
                .unwrap_or(1.0))
        });
        // -- setCookie --
        /// Stores a cookie texture path on this Lua light handle.
        /// @param | path | string | Cookie texture path.
        methods.add_method("setCookie", |_, this, path: String| {
            *this.cookie_path.borrow_mut() = Some(path);
            Ok(())
        });
        // -- getCookie --
        /// Returns the cookie texture path stored on this Lua light handle.
        /// @return | string | Cookie texture path, or nil when absent.
        methods.add_method("getCookie", |_, this, ()| {
            Ok(this.cookie_path.borrow().clone())
        });
        // -- clearCookie --
        /// Clears the cookie texture path stored on this Lua light handle.
        methods.add_method("clearCookie", |_, this, ()| {
            this.cookie_path.borrow_mut().take();
            Ok(())
        });
        // -- setNormalMap --
        /// Sets the normal map path used by this light.
        /// @param | path | string | Normal map path.
        methods.add_method("setNormalMap", |_, this, path: String| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setNormalMap"))?;
            light.set_normal_map_path(path);
            Ok(())
        });
        // -- getNormalMap --
        /// Returns the normal map path used by this light.
        /// @return | string | Normal map path, or nil when absent.
        methods.add_method("getNormalMap", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getNormalMap"))?;
            Ok(light.get_normal_map_path().map(str::to_string))
        });
        // -- clearNormalMap --
        /// Clears the normal map path used by this light.
        methods.add_method("clearNormalMap", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:clearNormalMap"))?;
            light.clear_normal_map_path();
            Ok(())
        });
        // -- setNormalStrength --
        /// Sets this light's normal map strength.
        /// @param | strength | number | Normal map strength.
        methods.add_method("setNormalStrength", |_, this, strength: f32| {
            let strength = unit_f32("Light:setNormalStrength", "strength", strength)?;
            let mut st = this.state.borrow_mut();
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setNormalStrength"))?;
            light.set_normal_strength(strength);
            Ok(())
        });
        // -- getNormalStrength --
        /// Returns this light's normal map strength.
        /// @return | number | Normal map strength.
        methods.add_method("getNormalStrength", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getNormalStrength"))?;
            Ok(light.get_normal_strength())
        });
        // -- setShader --
        /// Sets or clears the custom light-contribution shader for this light.
        /// @param | shader | LShader? | Light-target shader or nil to clear.
        methods.add_method("setShader", |_, this, shader: Option<LuaAnyUserData>| {
            let mut st = this.state.borrow_mut();
            let key = match shader {
                Some(ud) => {
                    let key = shader_key_from_userdata(&ud)?;
                    ensure_shader_target(&st, key, ShaderTarget::Light, "Light:setShader")?;
                    Some(key)
                }
                None => None,
            };
            let light = st
                .light_world
                .get_light_mut(this.key)
                .ok_or_else(|| invalid_light("Light:setShader"))?;
            light.shader = key;
            Ok(())
        });
        // -- getShader --
        /// Returns the custom light shader bound to this light, if any.
        /// @return | LShader | Bound shader or nil.
        methods.add_method("getShader", |_, this, ()| {
            let st = this.state.borrow();
            let light = st
                .light_world
                .get_light(this.key)
                .ok_or_else(|| invalid_light("Light:getShader"))?;
            Ok(light.shader.map(|key| LuaShader {
                state: this.state.clone(),
                key,
            }))
        });
        // -- type --
        /// Returns the Lua-visible type name for this light handle.
        /// @return | string | The string `LLight`.
        methods.add_method("type", |_, _, ()| Ok("LLight"));
        // -- typeOf --
        /// Returns whether this light handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LLight` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LLight" || name == "LObject")
        });
    }
}
#[derive(Clone)]
/// Lua-side handle for an occluder stored in the shared light world.
pub struct LuaOccluder {
    /// Shared runtime state containing the light world.
    state: Rc<RefCell<SharedState>>,
    /// Slot-map key identifying the occluder inside the light world.
    key: OccluderKey,
}

/// Create a Lua occluder handle by inserting a prepared occluder into the shared light world.
pub(crate) fn lua_occluder_from_occluder(
    state: Rc<RefCell<SharedState>>,
    occluder: Occluder,
) -> LuaOccluder {
    let key = state.borrow_mut().light_world.add_occluder(occluder);
    LuaOccluder { state, key }
}

/// Provides Lua methods for editing and inspecting one light occluder.
impl LuaUserData for LuaOccluder {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setVertices --
        /// Replaces this occluder's flat vertex coordinate list.
        /// @param | tbl | table | Flat numeric array `[x1, y1, x2, y2, ...]`.
        methods.add_method("setVertices", |_, this, tbl: LuaTable| {
            let flat: Vec<f32> = tbl.sequence_values::<f32>().collect::<LuaResult<_>>()?;
            let tmp = Occluder::from_flat_coords(&flat).map_err(LuaError::RuntimeError)?;
            let mut st = this.state.borrow_mut();
            let occ = st
                .light_world
                .get_occluder_mut(this.key)
                .ok_or_else(|| invalid_occluder("Occluder:setVertices"))?;
            occ.set_vertices(tmp.vertices);
            Ok(())
        });
        // -- getVertices --
        /// Returns this occluder's flat vertex coordinate list.
        /// @return | number[] | Flat numeric array `[x1, y1, x2, y2, ...]`.
        methods.add_method("getVertices", |lua, this, ()| {
            let st = this.state.borrow();
            let occ = st
                .light_world
                .get_occluder(this.key)
                .ok_or_else(|| invalid_occluder("Occluder:getVertices"))?;
            let tbl = lua.create_table()?;
            for (i, v) in occ.get_vertices().iter().enumerate() {
                tbl.set(i * 2 + 1, v.x)?;
                tbl.set(i * 2 + 2, v.y)?;
            }
            Ok(tbl)
        });
        // -- setPosition --
        /// Sets this occluder position offset.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        methods.add_method("setPosition", |_, this, (x, y): (f32, f32)| {
            let mut st = this.state.borrow_mut();
            let occ = st
                .light_world
                .get_occluder_mut(this.key)
                .ok_or_else(|| invalid_occluder("Occluder:setPosition"))?;
            occ.set_position(Vec2::new(x, y));
            Ok(())
        });
        // -- getPosition --
        /// Returns this occluder position offset.
        /// @return | number | X coordinate.
        /// @return | number | Y coordinate.
        methods.add_method("getPosition", |_, this, ()| {
            let st = this.state.borrow();
            let occ = st
                .light_world
                .get_occluder(this.key)
                .ok_or_else(|| invalid_occluder("Occluder:getPosition"))?;
            let pos = occ.get_position();
            Ok((pos.x, pos.y))
        });
        // -- setOpacity --
        /// Sets this occluder opacity. This method is available to Lua scripts.
        /// @param | o | number | Opacity value.
        methods.add_method("setOpacity", |_, this, o: f32| {
            let mut st = this.state.borrow_mut();
            let occ = st
                .light_world
                .get_occluder_mut(this.key)
                .ok_or_else(|| invalid_occluder("Occluder:setOpacity"))?;
            occ.set_opacity(o);
            Ok(())
        });
        // -- getOpacity --
        /// Returns this occluder opacity. This method is available to Lua scripts.
        /// @return | number | Opacity value.
        methods.add_method("getOpacity", |_, this, ()| {
            let st = this.state.borrow();
            let occ = st
                .light_world
                .get_occluder(this.key)
                .ok_or_else(|| invalid_occluder("Occluder:getOpacity"))?;
            Ok(occ.get_opacity())
        });
        // -- setLightMask --
        /// Sets this occluder's light mask. This method is available to Lua scripts.
        /// @param | mask | integer | Light mask bits.
        methods.add_method("setLightMask", |_, this, mask: u16| {
            let mut st = this.state.borrow_mut();
            let occ = st
                .light_world
                .get_occluder_mut(this.key)
                .ok_or_else(|| invalid_occluder("Occluder:setLightMask"))?;
            occ.set_light_mask(mask);
            Ok(())
        });
        // -- getLightMask --
        /// Returns this occluder's light mask.
        /// @return | integer | Light mask bits.
        methods.add_method("getLightMask", |_, this, ()| {
            let st = this.state.borrow();
            let occ = st
                .light_world
                .get_occluder(this.key)
                .ok_or_else(|| invalid_occluder("Occluder:getLightMask"))?;
            Ok(occ.get_light_mask())
        });
        // -- setEnabled --
        /// Enables or disables this occluder.
        /// @param | b | boolean | New enabled flag.
        methods.add_method("setEnabled", |_, this, b: bool| {
            let mut st = this.state.borrow_mut();
            let occ = st
                .light_world
                .get_occluder_mut(this.key)
                .ok_or_else(|| invalid_occluder("Occluder:setEnabled"))?;
            occ.set_enabled(b);
            Ok(())
        });
        // -- isEnabled --
        /// Returns whether this occluder is enabled.
        /// @return | boolean | True when enabled.
        methods.add_method("isEnabled", |_, this, ()| {
            let st = this.state.borrow();
            let occ = st
                .light_world
                .get_occluder(this.key)
                .ok_or_else(|| invalid_occluder("Occluder:isEnabled"))?;
            Ok(occ.is_enabled())
        });
        // -- remove --
        /// Removes this occluder from the shared light world.
        methods.add_method("remove", |_, this, ()| {
            this.state
                .borrow_mut()
                .light_world
                .remove_occluder(this.key);
            Ok(())
        });
        // -- isValid --
        /// Returns whether this occluder handle still points to a live occluder.
        /// @return | boolean | True when the occluder still exists.
        methods.add_method("isValid", |_, this, ()| {
            Ok(this
                .state
                .borrow()
                .light_world
                .occluders
                .contains_key(this.key))
        });
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            let st = this.state.borrow();
            match st.light_world.get_occluder(this.key) {
                Some(o) => Ok(format!("Occluder({} verts)", o.get_vertices().len())),
                None => Ok("Occluder(invalid)".to_string()),
            }
        });
        // -- type --
        /// Returns the Lua-visible type name for this occluder handle.
        /// @return | string | The string `LOccluder`.
        methods.add_method("type", |_, _, ()| Ok("LOccluder"));
        // -- typeOf --
        /// Returns whether this occluder handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LOccluder` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LOccluder" || name == "LObject")
        });
    }
}
/// Registers `lurek.light` light-world constructors and global lighting controls.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let s = state.clone();
    // -- setShader --
    /// Sets or clears the default custom light shader for the light world.
    /// @param | shader | LShader? | Light-target shader or nil to clear.
    tbl.set(
        "setShader",
        lua.create_function(move |_, shader: Option<LuaAnyUserData>| {
            let mut st = s.borrow_mut();
            let key = match shader {
                Some(ud) => {
                    let key = shader_key_from_userdata(&ud)?;
                    ensure_shader_target(&st, key, ShaderTarget::Light, "lurek.light.setShader")?;
                    Some(key)
                }
                None => None,
            };
            st.light_world.shader = key;
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getShader --
    /// Returns the default custom light shader for the light world.
    /// @return | LShader | Bound shader or nil.
    tbl.set(
        "getShader",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            Ok(st.light_world.shader.map(|key| LuaShader {
                state: s.clone(),
                key,
            }))
        })?,
    )?;
    let s = state.clone();
    // -- newLight --
    /// Creates a light and applies optional light settings.
    /// @param | x | number | Light x coordinate.
    /// @param | y | number | Light y coordinate.
    /// @param | radius | number | Light radius.
    /// @param | opts | table? | Table of light settings.
    /// @return | LLight | New light handle.
    tbl.set(
        "newLight",
        lua.create_function(
            move |_, (x, y, radius, opts): (f32, f32, f32, Option<LuaTable>)| {
                let x = finite_f32("lurek.light.newLight", "x", x)?;
                let y = finite_f32("lurek.light.newLight", "y", y)?;
                let radius = positive_f32("lurek.light.newLight", "radius", radius)?;
                let mut light = Light2D::new(x, y, radius);
                if let Some(ref opts) = opts {
                    apply_light_opts(&mut light, opts)?;
                }
                let mut st = s.borrow_mut();
                let key = st.light_world.add_light(light);
                st.light_world.reindex_flickers();
                Ok(LuaLight {
                    state: s.clone(),
                    key,
                    transition: RefCell::new(None),
                    cookie_path: RefCell::new(None),
                })
            },
        )?,
    )?;
    let s = state.clone();
    // -- newOccluder --
    /// Creates an occluder from a flat vertex coordinate table and optional settings.
    /// @param | vtbl | table | Flat numeric array `[x1, y1, x2, y2, ...]`.
    /// @param | opts | table? | Table of occluder settings.
    /// @return | LOccluder | New occluder handle.
    tbl.set(
        "newOccluder",
        lua.create_function(move |_, (vtbl, opts): (LuaTable, Option<LuaTable>)| {
            let flat: Vec<f32> = vtbl.sequence_values::<f32>().collect::<LuaResult<_>>()?;
            let mut occ = Occluder::from_flat_coords(&flat).map_err(LuaError::RuntimeError)?;
            if let Some(ref opts) = opts {
                apply_occluder_opts(&mut occ, opts)?;
            }
            let key = s.borrow_mut().light_world.add_occluder(occ);
            Ok(LuaOccluder {
                state: s.clone(),
                key,
            })
        })?,
    )?;
    let s = state.clone();
    // -- setAmbient --
    /// Sets global ambient light color. This function is exposed to Lua scripts.
    /// @param | r | number | Red channel.
    /// @param | g | number | Green channel.
    /// @param | b | number | Blue channel.
    /// @param | a | number? | Alpha channel, defaulting to 1.0.
    tbl.set(
        "setAmbient",
        lua.create_function(move |_, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
            s.borrow_mut().light_world.ambient = Color::new(
                unit_f32("lurek.light.setAmbient", "r", r)?,
                unit_f32("lurek.light.setAmbient", "g", g)?,
                unit_f32("lurek.light.setAmbient", "b", b)?,
                unit_f32("lurek.light.setAmbient", "a", a.unwrap_or(1.0))?,
            );
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getAmbient --
    /// Returns global ambient light color.
    /// @return | number | Red channel.
    /// @return | number | Green channel.
    /// @return | number | Blue channel.
    /// @return | number | Alpha channel.
    tbl.set(
        "getAmbient",
        lua.create_function(move |_, ()| {
            let c = s.borrow().light_world.ambient;
            Ok((c.r, c.g, c.b, c.a))
        })?,
    )?;
    let s = state.clone();
    // -- setEnabled --
    /// Enables or disables the shared light world.
    /// @param | enabled | boolean | New enabled flag.
    tbl.set(
        "setEnabled",
        lua.create_function(move |_, enabled: bool| {
            s.borrow_mut().light_world.enabled = enabled;
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- isEnabled --
    /// Returns whether the shared light world is enabled.
    /// @return | boolean | True when lighting is enabled.
    tbl.set(
        "isEnabled",
        lua.create_function(move |_, ()| Ok(s.borrow().light_world.enabled))?,
    )?;
    let s = state.clone();
    // -- getLightCount --
    /// Returns the number of live lights. This function is exposed to Lua scripts.
    /// @return | integer | Light count.
    tbl.set(
        "getLightCount",
        lua.create_function(move |_, ()| Ok(s.borrow().light_world.light_count()))?,
    )?;
    let s = state.clone();
    // -- getOccluderCount --
    /// Returns the number of live occluders.
    /// @return | integer | Occluder count.
    tbl.set(
        "getOccluderCount",
        lua.create_function(move |_, ()| Ok(s.borrow().light_world.occluder_count()))?,
    )?;
    let s = state.clone();
    // -- getMaxLights --
    /// Returns the maximum configured light count.
    /// @return | integer | Maximum light count.
    tbl.set(
        "getMaxLights",
        lua.create_function(move |_, ()| Ok(s.borrow().light_world.max_lights))?,
    )?;
    let s = state.clone();
    // -- setMaxLights --
    /// Sets the maximum configured light count, clamped to 1 through 256.
    /// @param | n | integer | Requested maximum light count.
    tbl.set(
        "setMaxLights",
        lua.create_function(move |_, n: u16| {
            s.borrow_mut().light_world.max_lights = n.clamp(1, 256);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- clear --
    /// Removes all lights and occluders from the light world.
    tbl.set(
        "clear",
        lua.create_function(move |_, ()| {
            s.borrow_mut().light_world.clear();
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- setGroupEnabled --
    /// Enables or disables all lights in a group.
    /// @param | group_id | integer | Light group id.
    /// @param | enabled | boolean | New enabled flag for the group.
    tbl.set(
        "setGroupEnabled",
        lua.create_function(move |_, (group_id, enabled): (u16, bool)| {
            s.borrow_mut()
                .light_world
                .set_group_enabled(group_id, enabled);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- setGroupIntensity --
    /// Sets intensity for all lights in a group.
    /// @param | group_id | integer | Light group id.
    /// @param | intensity | number | New intensity value.
    tbl.set(
        "setGroupIntensity",
        lua.create_function(move |_, (group_id, intensity): (u16, f32)| {
            let intensity =
                non_negative_f32("lurek.light.setGroupIntensity", "intensity", intensity)?;
            s.borrow_mut()
                .light_world
                .set_group_intensity(group_id, intensity);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- setGroupColor --
    /// Sets color for all lights in a group.
    /// @param | group_id | integer | Light group id.
    /// @param | r | number | Red channel.
    /// @param | g | number | Green channel.
    /// @param | b | number | Blue channel.
    /// @param | a | number? | Alpha channel, defaulting to 1.0.
    tbl.set(
        "setGroupColor",
        lua.create_function(
            move |_, (group_id, r, g, b, a): (u16, f32, f32, f32, Option<f32>)| {
                s.borrow_mut().light_world.set_group_color(
                    group_id,
                    Color::new(
                        unit_f32("lurek.light.setGroupColor", "r", r)?,
                        unit_f32("lurek.light.setGroupColor", "g", g)?,
                        unit_f32("lurek.light.setGroupColor", "b", b)?,
                        unit_f32("lurek.light.setGroupColor", "a", a.unwrap_or(1.0))?,
                    ),
                );
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- getGroupCount --
    /// Returns the number of lights in a group.
    /// @param | group_id | integer | Light group id.
    /// @return | integer | Number of lights in the group.
    tbl.set(
        "getGroupCount",
        lua.create_function(move |_, group_id: u16| {
            Ok(s.borrow().light_world.group_count(group_id))
        })?,
    )?;
    let s = state.clone();
    // -- advanceFlickers --
    /// Advances flicker animation for all indexed flickering lights.
    /// @param | dt | number | Delta time in seconds.
    tbl.set(
        "advanceFlickers",
        lua.create_function(move |_, dt: f32| {
            let dt = non_negative_f32("lurek.light.advanceFlickers", "dt", dt)?;
            s.borrow_mut().light_world.advance_flickers(dt);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- syncAmbient --
    /// Returns the light world's ambient color hint.
    /// @return | number | Red channel.
    /// @return | number | Green channel.
    /// @return | number | Blue channel.
    /// @return | number | Alpha channel.
    tbl.set(
        "syncAmbient",
        lua.create_function(move |_, ()| {
            let hint = s.borrow().light_world.ambient_color_hint();
            Ok((hint[0], hint[1], hint[2], hint[3]))
        })?,
    )?;
    let s = state.clone();
    // -- getGodRayHints --
    /// Returns directional light hints for god-ray style effects.
    /// @return | table | Array table of hint records with `x`, `y`, and `angle` fields.
    /// @field | x | number | Hint x position.
    /// @field | y | number | Hint y position.
    /// @field | angle | number | Hint angle in radians.
    tbl.set(
        "getGodRayHints",
        lua.create_function(move |lua, ()| {
            let hints = s.borrow().light_world.directional_light_hints();
            let tbl = lua.create_table()?;
            for (i, (x, y, angle)) in hints.iter().enumerate() {
                let t = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                t.set("x", *x)?;
                /// The 'y' field value exposed to Lua scripts.
                t.set("y", *y)?;
                /// Performs the 'angle' operation.
                t.set("angle", *angle)?;
                tbl.set(i + 1, t)?;
            }
            Ok(tbl)
        })?,
    )?;
    let s = state.clone();
    // -- getNormalMapHints --
    /// Returns light hints that reference normal maps.
    /// @return | table | Array table of normal-map light hint records.
    /// @field | x | number | Hint x position.
    /// @field | y | number | Hint y position.
    /// @field | radius | number | Hint radius.
    /// @field | intensity | number | Hint intensity.
    /// @field | direction | number | Hint direction.
    /// @field | normalMap | string | Normal map asset path.
    /// @field | strength | number | Normal map strength.
    tbl.set(
        "getNormalMapHints",
        lua.create_function(move |lua, ()| {
            let hints = s.borrow().light_world.normal_map_light_hints();
            let tbl = lua.create_table()?;
            for (i, h) in hints.iter().enumerate() {
                let t = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                t.set("x", h.x)?;
                /// The 'y' field value exposed to Lua scripts.
                t.set("y", h.y)?;
                /// Performs the 'radius' operation.
                t.set("radius", h.radius)?;
                /// Performs the 'intensity' operation.
                t.set("intensity", h.intensity)?;
                /// Performs the 'direction' operation.
                t.set("direction", h.direction)?;
                /// Performs the 'normalMap' operation.
                t.set("normalMap", h.path.clone())?;
                /// Performs the 'strength' operation.
                t.set("strength", h.strength)?;
                tbl.set(i + 1, t)?;
            }
            Ok(tbl)
        })?,
    )?;
    let s = state.clone();
    // -- drawToImage --
    /// Renders an approximate light-map preview of this world into an ImageData.
    /// @param | width | integer | Image width.
    /// @param | height | integer | Image height.
    /// @return | LImageData | Rendered light map.
    tbl.set(
        "drawToImage",
        lua.create_function(move |lua, (width, height): (u32, u32)| {
            let width = positive_u32("lurek.light.drawToImage", "width", width)?;
            let height = positive_u32("lurek.light.drawToImage", "height", height)?;
            let img = s.borrow().light_world.draw_to_image(width, height);
            lua.create_userdata(img)
        })?,
    )?;
    /// Performs the 'light' operation.
    lurek.set("light", tbl)?;
    Ok(())
}
