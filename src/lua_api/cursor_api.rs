//! Registers the `lurek.cursor` Lua API and owns runtime cursor refresh glue for hover, overlay, trail, bursts, and zoom.

use super::globe_api::LuaGlobe;
use super::render_api::{shader_key_from_userdata, LuaImage};
use super::SharedState;
use crate::app::lua_callbacks::call_function_with_optional_timeout;
use crate::cursor::{
    AnimatedCursor, ContextRule, CursorContext, CursorEffectSpec, CursorHit, CursorInputFrame,
    CursorManager, CursorRule, CursorRuleEvent, CursorRuleTarget, CursorSource, CursorState,
    CursorStateSpec, CursorTrail, CursorZoom, CustomCursor, PulseConfig, SystemCursor, TrailMode,
};
use crate::globe::picking::{ObjectHitKind, ObjectPickOptions, ObjectPickOrder};
use crate::image::Texture;
use crate::raycaster::{RaycasterPickWorld, RaycasterScene};
use crate::render::renderer::{
    BlendMode, DrawMode, ParticleInstance, ParticleRenderShape, PostFxPass, RenderCommand,
};
use crate::runtime::resource_keys::TextureKey;
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashMap;
use std::f32::consts::TAU;
use std::rc::Rc;

const CURSOR_LENS_STACK_ID: u64 = 0xC0A7_0001;

/// Lua userdata that controls the shared runtime cursor.
struct LuaCursorManager {
    state: Rc<RefCell<SharedState>>,
}

#[derive(Clone)]
struct LuaCustomCursor {
    inner: Rc<RefCell<CustomCursor>>,
}

#[derive(Clone)]
struct LuaAnimatedCursor {
    inner: Rc<RefCell<AnimatedCursor>>,
}

fn parse_system_cursor_name(name: &str) -> LuaResult<SystemCursor> {
    SystemCursor::from_name(name)
        .ok_or_else(|| LuaError::runtime(format!("unknown system cursor: {name}")))
}

fn table_color(tbl: &LuaTable, default: [f32; 4]) -> LuaResult<[f32; 4]> {
    if let Some(color_tbl) = tbl.get::<_, Option<LuaTable>>("color")? {
        return Ok([
            color_tbl.get::<_, Option<f32>>(1)?.unwrap_or(default[0]),
            color_tbl.get::<_, Option<f32>>(2)?.unwrap_or(default[1]),
            color_tbl.get::<_, Option<f32>>(3)?.unwrap_or(default[2]),
            color_tbl.get::<_, Option<f32>>(4)?.unwrap_or(default[3]),
        ]);
    }
    Ok([
        tbl.get::<_, Option<f32>>("r")?.unwrap_or(default[0]),
        tbl.get::<_, Option<f32>>("g")?.unwrap_or(default[1]),
        tbl.get::<_, Option<f32>>("b")?.unwrap_or(default[2]),
        tbl.get::<_, Option<f32>>("a")?.unwrap_or(default[3]),
    ])
}

fn parse_texture_key(value: LuaValue, api_name: &str) -> LuaResult<Option<TextureKey>> {
    match value {
        LuaValue::Nil => Ok(None),
        LuaValue::Integer(value) if value >= 0 => Ok(Some(TextureKey::from(
            slotmap::KeyData::from_ffi(value as u64),
        ))),
        LuaValue::Number(value)
            if value.is_finite() && value >= 0.0 && value.fract().abs() < f64::EPSILON =>
        {
            Ok(Some(TextureKey::from(slotmap::KeyData::from_ffi(
                value as u64,
            ))))
        }
        LuaValue::UserData(ud) => {
            let image = ud.borrow::<LuaImage>().map_err(|_| {
                LuaError::RuntimeError(format!(
                    "{api_name}: texture must be nil, integer id, or LImage userdata"
                ))
            })?;
            Ok(Some(image.key))
        }
        _ => Err(LuaError::RuntimeError(format!(
            "{api_name}: texture must be nil, integer id, or LImage userdata"
        ))),
    }
}

fn parse_optional_shader_key(
    value: LuaValue,
    api_name: &str,
) -> LuaResult<Option<crate::runtime::resource_keys::ShaderKey>> {
    match value {
        LuaValue::Nil => Ok(None),
        LuaValue::UserData(ud) => Ok(Some(shader_key_from_userdata(&ud)?)),
        _ => Err(LuaError::RuntimeError(format!(
            "{api_name}: shader must be nil or LShader userdata"
        ))),
    }
}

fn parse_blend_mode(value: Option<String>) -> LuaResult<BlendMode> {
    match value
        .unwrap_or_else(|| "alpha".to_string())
        .to_ascii_lowercase()
        .as_str()
    {
        "alpha" | "normal" => Ok(BlendMode::Alpha),
        "add" | "additive" => Ok(BlendMode::Add),
        "multiply" => Ok(BlendMode::Multiply),
        "replace" => Ok(BlendMode::Replace),
        "screen" => Ok(BlendMode::Screen),
        other => Err(LuaError::RuntimeError(format!(
            "unknown blend mode '{other}'"
        ))),
    }
}

fn parse_particle_shape(value: Option<String>) -> LuaResult<ParticleRenderShape> {
    Ok(
        match value
            .unwrap_or_else(|| "spark".to_string())
            .to_ascii_lowercase()
            .as_str()
        {
            "square" => ParticleRenderShape::Square,
            "circle" => ParticleRenderShape::Circle,
            "triangle" => ParticleRenderShape::Triangle,
            "diamond" => ParticleRenderShape::Diamond,
            "puff" => ParticleRenderShape::Puff,
            "capsule" => ParticleRenderShape::Capsule,
            "ring" => ParticleRenderShape::Ring { thickness: 0.25 },
            _ => ParticleRenderShape::Spark,
        },
    )
}

fn parse_trail_mode(value: Option<String>) -> TrailMode {
    match value
        .unwrap_or_else(|| "points".to_string())
        .to_ascii_lowercase()
        .as_str()
    {
        "fade_points" | "fade" => TrailMode::FadePoints,
        "line" => TrailMode::Line,
        "ribbon" => TrailMode::Ribbon,
        "stamp" => TrailMode::Stamp,
        _ => TrailMode::Points,
    }
}

fn parse_hit_target(tbl: LuaTable) -> LuaResult<CursorRuleTarget> {
    let mut target = CursorRuleTarget {
        module_name: tbl.get::<_, Option<String>>("module")?,
        kind: tbl.get::<_, Option<String>>("kind")?,
        surface: tbl.get::<_, Option<String>>("surface")?,
        id: tbl.get::<_, Option<String>>("id")?,
        attrs: HashMap::new(),
    };
    if let Some(attrs_tbl) = tbl.get::<_, Option<LuaTable>>("attrs")? {
        for pair in attrs_tbl.pairs::<String, String>() {
            let (key, value) = pair?;
            target.attrs.insert(key, value);
        }
    }
    Ok(target)
}

fn parse_rule_event(name: &str) -> CursorRuleEvent {
    match name.to_ascii_lowercase().as_str() {
        "hover" => CursorRuleEvent::Hover,
        "leave" => CursorRuleEvent::Leave,
        "click" => CursorRuleEvent::Click,
        "release" => CursorRuleEvent::Release,
        "wheel" => CursorRuleEvent::Wheel,
        _ => CursorRuleEvent::Context,
    }
}

fn parse_state_spec(tbl: LuaTable) -> LuaResult<CursorStateSpec> {
    let state = if let Some(name) = tbl.get::<_, Option<String>>("system")? {
        CursorState::System(parse_system_cursor_name(&name)?)
    } else if let Some(ud) = tbl.get::<_, Option<LuaAnyUserData>>("custom")? {
        let cursor = ud.borrow::<LuaCustomCursor>()?.clone();
        let state = CursorState::Custom(cursor.inner.borrow().clone());
        state
    } else if let Some(ud) = tbl.get::<_, Option<LuaAnyUserData>>("animated")? {
        let cursor = ud.borrow::<LuaAnimatedCursor>()?.clone();
        let state = CursorState::Animated(cursor.inner.borrow().clone());
        state
    } else {
        return Err(LuaError::RuntimeError(
            "defineState: expected one of spec.system/spec.custom/spec.animated".into(),
        ));
    };

    let mut spec = CursorStateSpec::from_state(state);
    spec.scale = tbl.get::<_, Option<f32>>("scale")?.unwrap_or(1.0);
    spec.offset_x = tbl.get::<_, Option<f32>>("offset_x")?.unwrap_or(0.0);
    spec.offset_y = tbl.get::<_, Option<f32>>("offset_y")?.unwrap_or(0.0);
    spec.native_preferred = tbl
        .get::<_, Option<bool>>("native_preferred")?
        .unwrap_or(true);

    if let Some(trail_tbl) = tbl.get::<_, Option<LuaTable>>("trail")? {
        let mut trail = CursorTrail::new(parse_trail_mode(
            trail_tbl.get::<_, Option<String>>("mode")?,
        ));
        trail.set_color(table_color(&trail_tbl, [1.0, 1.0, 1.0, 0.85])?);
        trail.set_lifetime(
            trail_tbl
                .get::<_, Option<f32>>("lifetime")?
                .unwrap_or(trail.lifetime()),
        );
        trail.set_spacing(
            trail_tbl
                .get::<_, Option<f32>>("spacing")?
                .unwrap_or(trail.spacing()),
        );
        trail.set_width(
            trail_tbl
                .get::<_, Option<f32>>("width")?
                .unwrap_or(trail.width()),
        );
        trail.set_max_points(
            trail_tbl
                .get::<_, Option<usize>>("max_points")?
                .unwrap_or(trail.max_points()),
        );
        trail.set_texture_key(parse_texture_key(
            trail_tbl
                .get::<_, LuaValue>("texture")
                .unwrap_or(LuaValue::Nil),
            "defineState(trail.texture)",
        )?);
        trail.set_shader_key(parse_optional_shader_key(
            trail_tbl
                .get::<_, LuaValue>("shader")
                .unwrap_or(LuaValue::Nil),
            "defineState(trail.shader)",
        )?);
        trail.set_blend(parse_blend_mode(
            trail_tbl.get::<_, Option<String>>("blend")?,
        )?);
        spec.trail = Some(trail);
    }

    if let Some(zoom_tbl) = tbl.get::<_, Option<LuaTable>>("zoom")? {
        let magnification = zoom_tbl
            .get::<_, Option<f32>>("magnification")?
            .unwrap_or(2.0);
        let radius = zoom_tbl.get::<_, Option<f32>>("radius")?.unwrap_or(64.0);
        let mut zoom = CursorZoom::new(magnification, radius);
        zoom.border_color = table_color(&zoom_tbl, zoom.border_color)?;
        zoom.border_width = zoom_tbl
            .get::<_, Option<f32>>("border_width")?
            .unwrap_or(zoom.border_width);
        zoom.softness = zoom_tbl
            .get::<_, Option<f32>>("softness")?
            .unwrap_or(zoom.softness);
        zoom.shader_key = parse_optional_shader_key(
            zoom_tbl
                .get::<_, LuaValue>("shader")
                .unwrap_or(LuaValue::Nil),
            "defineState(zoom.shader)",
        )?;
        spec.zoom = Some(zoom);
    }

    Ok(spec)
}

fn parse_effect_spec(tbl: LuaTable) -> LuaResult<CursorEffectSpec> {
    Ok(CursorEffectSpec {
        shape: parse_particle_shape(tbl.get::<_, Option<String>>("shape")?)?,
        color: table_color(&tbl, [1.0, 1.0, 1.0, 1.0])?,
        texture_key: parse_texture_key(
            tbl.get::<_, LuaValue>("texture").unwrap_or(LuaValue::Nil),
            "defineEffect(texture)",
        )?,
        shader_key: parse_optional_shader_key(
            tbl.get::<_, LuaValue>("shader").unwrap_or(LuaValue::Nil),
            "defineEffect(shader)",
        )?,
        count: tbl.get::<_, Option<u32>>("count")?.unwrap_or(12),
        spread: tbl.get::<_, Option<f32>>("spread")?.unwrap_or(TAU),
        lifetime: tbl.get::<_, Option<f32>>("lifetime")?.unwrap_or(0.28),
        speed: tbl.get::<_, Option<f32>>("speed")?.unwrap_or(96.0),
        size: tbl.get::<_, Option<f32>>("size")?.unwrap_or(5.0),
        blend: parse_blend_mode(tbl.get::<_, Option<String>>("blend")?)?,
        button_filter: tbl.get::<_, Option<usize>>("button")?,
    })
}

fn rule_to_struct(tbl: LuaTable) -> LuaResult<CursorRule> {
    Ok(CursorRule {
        id: 0,
        priority: tbl.get::<_, Option<i32>>("priority")?.unwrap_or(0),
        event: parse_rule_event(
            &tbl.get::<_, Option<String>>("event")?
                .unwrap_or_else(|| "context".to_string()),
        ),
        context: tbl
            .get::<_, Option<String>>("context")?
            .map(|value| CursorContext::from_name(&value)),
        target: match tbl.get::<_, Option<LuaTable>>("target")? {
            Some(target) => Some(parse_hit_target(target)?),
            None => None,
        },
        state: tbl.get::<_, Option<String>>("state")?,
        effect: tbl.get::<_, Option<String>>("effect")?,
        duration_ms: tbl.get::<_, Option<u32>>("duration_ms")?.unwrap_or(0),
        inline_state: None,
    })
}

fn source_from_table(
    lua: &Lua,
    tbl: LuaTable,
    state: &Rc<RefCell<SharedState>>,
) -> LuaResult<CursorSource> {
    let kind = tbl.get::<_, String>("kind")?.to_ascii_lowercase();
    let id = state.borrow_mut().cursor_runtime.next_source_id();
    match kind.as_str() {
        "globe" => {
            let globe_ud = tbl.get::<_, LuaAnyUserData>("globe")?;
            let globe = globe_ud.borrow::<LuaGlobe>()?;
            let (registry, name) = globe.cursor_binding();
            Ok(CursorSource::Globe {
                id,
                registry,
                name,
                marker_radius: tbl.get::<_, Option<f32>>("marker_radius")?.unwrap_or(12.0),
            })
        }
        "raycaster_last" => Ok(CursorSource::RaycasterLast { id }),
        "callback" => {
            let callback = tbl.get::<_, LuaFunction>("callback")?;
            Ok(CursorSource::Callback {
                id,
                callback: lua.create_registry_value(callback)?,
            })
        }
        _ => Err(LuaError::RuntimeError(format!(
            "addSource: unknown source kind '{kind}'"
        ))),
    }
}

fn cursor_hit_to_table<'lua>(lua: &'lua Lua, hit: &CursorHit) -> LuaResult<LuaTable<'lua>> {
    let hit_table = lua.create_table()?;
    hit_table.set("module", hit.module_name.as_str())?;
    hit_table.set("kind", hit.kind.as_str())?;
    hit_table.set("surface", hit.surface.as_str())?;
    if let Some(id) = &hit.id {
        hit_table.set("id", id.as_str())?;
    }
    if let Some(context) = &hit.context {
        hit_table.set("context", context.as_str())?;
    }
    let attrs = lua.create_table()?;
    for (key, value) in &hit.attrs {
        attrs.set(key.as_str(), value.as_str())?;
    }
    hit_table.set("attrs", attrs)?;
    Ok(hit_table)
}

fn active_state_to_table<'lua>(
    lua: &'lua Lua,
    manager: &CursorManager,
) -> LuaResult<LuaTable<'lua>> {
    let info = manager.get_active_state();
    let state_table = lua.create_table()?;
    if let Some(name) = info.name {
        state_table.set("name", name)?;
    }
    state_table.set("kind", info.kind)?;
    state_table.set("native_preferred", info.native_preferred)?;
    state_table.set("scale", info.scale)?;
    state_table.set("offset_x", info.offset_x)?;
    state_table.set("offset_y", info.offset_y)?;
    Ok(state_table)
}

fn globe_hit_to_cursor_hit(hit: crate::globe::picking::ObjectHit) -> CursorHit {
    let kind = match hit.kind {
        ObjectHitKind::Marker => "marker",
        ObjectHitKind::Orbit => "orbit",
        ObjectHitKind::Province => "province",
        ObjectHitKind::Region => "region",
        ObjectHitKind::Surface => "surface",
    };
    CursorHit {
        module_name: "globe".to_string(),
        kind: kind.to_string(),
        surface: if matches!(hit.kind, ObjectHitKind::Orbit | ObjectHitKind::Marker) {
            kind.to_string()
        } else {
            "surface".to_string()
        },
        id: hit
            .id
            .map(|id| id.to_string())
            .or_else(|| hit.orbit.clone()),
        attrs: hit.attrs,
        context: Some("globe".to_string()),
    }
}

fn raycaster_scene_hit_to_cursor_hit(scene: &RaycasterScene, x: f32, y: f32) -> Option<CursorHit> {
    let pick = scene.pick_entity(x, y)?;
    Some(CursorHit {
        module_name: "raycaster".to_string(),
        kind: pick.kind.as_str().to_string(),
        surface: pick.kind.as_str().to_string(),
        id: pick.entity_id.map(|id| id.to_string()),
        attrs: pick.attrs,
        context: Some("raycaster".to_string()),
    })
}

fn poll_callback_hit(
    lua: &Lua,
    callback: &LuaRegistryKey,
    x: f32,
    y: f32,
    timeout_ms: Option<f32>,
) -> LuaResult<Option<CursorHit>> {
    let func: LuaFunction = lua.registry_value(callback)?;
    let value: LuaValue = call_function_with_optional_timeout(
        lua,
        "lurek.cursor.sourceCallback",
        func,
        (x, y),
        timeout_ms,
    )?;
    let LuaValue::Table(tbl) = value else {
        return Ok(None);
    };
    let mut attrs = HashMap::new();
    if let Some(attrs_tbl) = tbl.get::<_, Option<LuaTable>>("attrs")? {
        for pair in attrs_tbl.pairs::<String, String>() {
            let (key, value) = pair?;
            attrs.insert(key, value);
        }
    }
    Ok(Some(CursorHit {
        module_name: tbl
            .get::<_, Option<String>>("module")?
            .unwrap_or_else(|| "callback".to_string()),
        kind: tbl
            .get::<_, Option<String>>("kind")?
            .unwrap_or_else(|| "hover".to_string()),
        surface: tbl
            .get::<_, Option<String>>("surface")?
            .unwrap_or_else(|| "surface".to_string()),
        id: tbl.get::<_, Option<String>>("id")?,
        attrs,
        context: tbl.get::<_, Option<String>>("context")?,
    }))
}

fn system_cursor_to_input(cursor: SystemCursor) -> crate::input::SystemCursor {
    match cursor {
        SystemCursor::Arrow => crate::input::SystemCursor::Arrow,
        SystemCursor::IBeam => crate::input::SystemCursor::IBeam,
        SystemCursor::Wait | SystemCursor::WaitArrow => crate::input::SystemCursor::Wait,
        SystemCursor::Crosshair => crate::input::SystemCursor::Crosshair,
        SystemCursor::SizeNWSE => crate::input::SystemCursor::SizeNWSE,
        SystemCursor::SizeNESW => crate::input::SystemCursor::SizeNESW,
        SystemCursor::SizeWE => crate::input::SystemCursor::SizeWE,
        SystemCursor::SizeNS => crate::input::SystemCursor::SizeNS,
        SystemCursor::SizeAll => crate::input::SystemCursor::SizeAll,
        SystemCursor::No => crate::input::SystemCursor::No,
        SystemCursor::Hand => crate::input::SystemCursor::Hand,
    }
}

fn cursor_image_signature(image: &CustomCursor) -> u64 {
    let mut hash = ((image.width as u64) << 32) ^ image.height as u64;
    hash ^= (image.hotspot_x as u64) << 16;
    hash ^= image.hotspot_y as u64;
    for chunk in image.pixels().chunks(4) {
        for byte in chunk {
            hash = hash.rotate_left(5) ^ (*byte as u64);
        }
    }
    hash
}

fn ensure_overlay_texture(st: &mut SharedState, image: &CustomCursor) -> LuaResult<TextureKey> {
    let signature = cursor_image_signature(image);
    if let Some(key) = st.cursor_overlay_texture {
        if st.cursor_overlay_signature != signature {
            if let Some(texture) = st.textures.get_mut(key) {
                texture.width = image.width;
                texture.height = image.height;
                texture.pixels = image.pixels().to_vec();
                texture.mark_dirty();
                st.cursor_overlay_signature = signature;
                return Ok(key);
            }
        } else {
            return Ok(key);
        }
    }
    let texture = Texture::from_rgba(
        image.width,
        image.height,
        image.pixels().to_vec(),
        &mut st.textures,
    )
    .map_err(|err| LuaError::RuntimeError(err.to_string()))?;
    st.cursor_overlay_texture = Some(texture.key);
    st.cursor_overlay_signature = signature;
    Ok(texture.key)
}

fn render_cursor_trail(st: &mut SharedState) {
    let Some(trail) = st.cursor_runtime.trail().cloned() else {
        return;
    };
    let color = trail.color();
    st.render_commands
        .push(RenderCommand::SetBlendMode(trail.blend()));
    st.render_commands.push(RenderCommand::SetColor(
        color[0], color[1], color[2], color[3],
    ));
    match trail.mode() {
        TrailMode::FadePoints | TrailMode::Points => {
            let points: Vec<(f32, f32)> = trail
                .get_points()
                .iter()
                .map(|point| (point.x, point.y))
                .collect();
            if !points.is_empty() {
                st.render_commands
                    .push(RenderCommand::SetPointSize(trail.width()));
                st.render_commands.push(RenderCommand::Points { points });
            }
        }
        TrailMode::Line | TrailMode::Ribbon => {
            let mut points = Vec::new();
            for point in trail.get_points() {
                points.push(point.x);
                points.push(point.y);
            }
            if points.len() >= 4 {
                st.render_commands
                    .push(RenderCommand::SetLineWidth(match trail.mode() {
                        TrailMode::Ribbon => trail.width().max(2.0),
                        _ => trail.width(),
                    }));
                st.render_commands.push(RenderCommand::Polyline { points });
            }
        }
        TrailMode::Stamp => {
            for point in trail.get_points() {
                if let Some(texture_key) = trail.texture_key() {
                    let Some(texture) = st.textures.get(texture_key) else {
                        continue;
                    };
                    let sx = trail.width() / texture.width.max(1) as f32;
                    let sy = trail.width() / texture.height.max(1) as f32;
                    st.render_commands.push(RenderCommand::DrawImageEx {
                        texture_key,
                        x: point.x,
                        y: point.y,
                        rotation: 0.0,
                        sx,
                        sy,
                        ox: texture.width as f32 * 0.5,
                        oy: texture.height as f32 * 0.5,
                        effect: None,
                    });
                } else {
                    st.render_commands.push(RenderCommand::Circle {
                        mode: DrawMode::Fill,
                        x: point.x,
                        y: point.y,
                        r: trail.width() * 0.5,
                    });
                }
            }
        }
    }
}

fn render_cursor_bursts(st: &mut SharedState) {
    let bursts = st.cursor_runtime.bursts().to_vec();
    for burst in &bursts {
        let mut particles = Vec::new();
        let count = burst.effect.count.max(1);
        let t = (burst.age / burst.effect.lifetime.max(0.001)).clamp(0.0, 1.0);
        for index in 0..count {
            let fraction = index as f32 / count as f32;
            let angle = fraction * burst.effect.spread + (burst.seed as f32 * 0.173);
            let radius = burst.effect.speed * burst.age * (0.35 + fraction * 0.65);
            particles.push(ParticleInstance {
                x: burst.x + angle.cos() * radius,
                y: burst.y + angle.sin() * radius,
                r: burst.effect.color[0],
                g: burst.effect.color[1],
                b: burst.effect.color[2],
                a: burst.effect.color[3] * (1.0 - t),
                rotation: angle,
                size: burst.effect.size * (1.0 - t * 0.4),
                shape: burst.effect.shape.clone(),
                texture_key: burst.effect.texture_key,
                quad: None,
                quad_tex_dims: None,
                local_x: 0.0,
                local_y: 0.0,
                velocity_x: angle.cos() * burst.effect.speed,
                velocity_y: angle.sin() * burst.effect.speed,
                normalized_age: t,
                lifetime: burst.effect.lifetime,
                seed: burst.seed.wrapping_add(index),
            });
        }
        st.render_commands
            .push(RenderCommand::SetBlendMode(burst.effect.blend));
        st.render_commands.push(RenderCommand::DrawParticleSystem {
            particles,
            shader: burst.effect.shader_key,
        });
    }
}

fn render_zoom_lens(st: &mut SharedState) {
    let Some(zoom) = st.cursor_runtime.zoom().cloned() else {
        return;
    };
    if !zoom.enabled {
        return;
    }
    let screen_x = st.cursor_runtime.position().0 * st.window_state.viewport_scale_x
        + st.window_state.viewport_offset_x;
    let screen_y = st.cursor_runtime.position().1 * st.window_state.viewport_scale_y
        + st.window_state.viewport_offset_y;
    let mut params = HashMap::new();
    params.insert(
        "focus_x".to_string(),
        screen_x / st.window_width.max(1) as f32,
    );
    params.insert(
        "focus_y".to_string(),
        screen_y / st.window_height.max(1) as f32,
    );
    params.insert("intensity".to_string(), zoom.magnification);
    params.insert("radius".to_string(), zoom.radius);
    params.insert("thickness".to_string(), zoom.border_width);
    params.insert("color_r".to_string(), zoom.border_color[0]);
    params.insert("color_g".to_string(), zoom.border_color[1]);
    params.insert("color_b".to_string(), zoom.border_color[2]);
    params.insert("strength".to_string(), zoom.border_color[3]);
    params.insert("density".to_string(), zoom.softness);
    st.render_commands.push(RenderCommand::BeginPostFx {
        stack_id: CURSOR_LENS_STACK_ID,
    });
    st.render_commands.push(RenderCommand::EndPostFx {
        stack_id: CURSOR_LENS_STACK_ID,
    });
    st.render_commands.push(RenderCommand::ApplyPostFx {
        stack_id: CURSOR_LENS_STACK_ID,
        passes: vec![PostFxPass {
            effect_name: "cursor_lens".to_string(),
            params,
            shader_id: None,
            auto_uniforms: true,
        }],
        width: st.window_width,
        height: st.window_height,
    });
}

fn render_cursor_overlay(st: &mut SharedState) -> LuaResult<()> {
    let position = st.cursor_runtime.position();
    let visual = st.cursor_runtime.active_visual().clone();
    let active_state = st.cursor_runtime.active().clone();
    let mut restore_color = Some(st.current_color);
    match &active_state {
        CursorState::Custom(image) => {
            let texture_key = ensure_overlay_texture(st, image)?;
            st.render_commands
                .push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
            st.render_commands.push(RenderCommand::DrawImageEx {
                texture_key,
                x: position.0 + visual.offset_x,
                y: position.1 + visual.offset_y,
                rotation: 0.0,
                sx: visual.scale,
                sy: visual.scale,
                ox: image.hotspot_x as f32,
                oy: image.hotspot_y as f32,
                effect: None,
            });
        }
        CursorState::Animated(anim) => {
            if let Some(frame) = anim.current_frame() {
                let texture_key = ensure_overlay_texture(st, &frame.image)?;
                let scale = visual.scale * anim.current_scale();
                st.render_commands
                    .push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
                st.render_commands.push(RenderCommand::DrawImageEx {
                    texture_key,
                    x: position.0 + visual.offset_x,
                    y: position.1 + visual.offset_y,
                    rotation: 0.0,
                    sx: scale,
                    sy: scale,
                    ox: frame.image.hotspot_x as f32,
                    oy: frame.image.hotspot_y as f32,
                    effect: None,
                });
            }
        }
        CursorState::System(_) => {
            restore_color = None;
        }
    }
    if let Some(color) = restore_color {
        st.render_commands.push(RenderCommand::SetColor(
            color[0], color[1], color[2], color[3],
        ));
    }
    Ok(())
}

fn sync_runtime_mouse_state(st: &mut SharedState) {
    st.mouse.set_visible(st.cursor_runtime.is_visible());
    st.mouse.set_grabbed(st.cursor_runtime.is_locked());
    if st.cursor_runtime.wants_overlay() {
        st.mouse.set_visible(false);
        st.mouse.set_cursor(crate::input::SystemCursor::Arrow);
    } else if let CursorState::System(cursor) = st.cursor_runtime.active() {
        st.mouse.set_cursor(system_cursor_to_input(*cursor));
    }
}

fn poll_sources(
    lua: &Lua,
    sources: &[CursorSource],
    x: f32,
    y: f32,
    timeout_ms: Option<f32>,
    last_build: &Option<crate::raycaster::RaycasterLastBuildContext>,
) -> LuaResult<Option<CursorHit>> {
    for source in sources {
        let hit = match source {
            CursorSource::Globe {
                registry,
                name,
                marker_radius,
                ..
            } => {
                let guard = registry.lock().map_err(|err| {
                    LuaError::RuntimeError(format!("cursor globe source lock poisoned: {err}"))
                })?;
                let Some(globe) = guard.get(name) else {
                    continue;
                };
                globe
                    .pick_object(
                        x,
                        y,
                        ObjectPickOptions {
                            marker_radius: *marker_radius,
                            include_surface: true,
                            include_regions: true,
                            include_markers: true,
                            include_orbits: true,
                            order: ObjectPickOrder::MarkersFirst,
                        },
                    )
                    .map(globe_hit_to_cursor_hit)
            }
            CursorSource::RaycasterLast { .. } => {
                if let Some(context) = last_build {
                    if let Some(entity_hit) =
                        raycaster_scene_hit_to_cursor_hit(&context.scene, x, y)
                    {
                        Some(entity_hit)
                    } else {
                        let tile_pick = match &context.world {
                            RaycasterPickWorld::Single(world) => {
                                world.pick_screen(&context.params, x, y)
                            }
                            RaycasterPickWorld::Multi(world) => {
                                world.pick_screen(&context.params, x, y)
                            }
                        };
                        tile_pick.map(|pick| CursorHit {
                            module_name: "raycaster".to_string(),
                            kind: pick.kind,
                            surface: pick.surface.as_str().to_string(),
                            id: Some(format!(
                                "{}:{}:{}",
                                pick.grid_x,
                                pick.grid_y,
                                pick.surface.as_str()
                            )),
                            attrs: pick.attrs,
                            context: Some("raycaster".to_string()),
                        })
                    }
                } else {
                    None
                }
            }
            CursorSource::Callback { callback, .. } => {
                poll_callback_hit(lua, callback, x, y, timeout_ms)?
            }
        };
        if hit.is_some() {
            return Ok(hit);
        }
    }
    Ok(None)
}

/// Polls cursor sources, advances runtime cursor effects, and refreshes cursor overlay output.
pub(crate) fn refresh_cursor_runtime(
    lua: &Lua,
    state: Rc<RefCell<SharedState>>,
    timeout_ms: Option<f32>,
) -> LuaResult<()> {
    let (x, y, dt, input, mut sources, last_build) = {
        let mut st = state.borrow_mut();
        (
            st.mouse.x,
            st.mouse.y,
            st.delta_time as f32,
            CursorInputFrame {
                buttons: st.mouse.buttons,
                buttons_pressed: st.mouse.buttons_pressed,
                buttons_released: st.mouse.buttons_released,
                scroll_x: st.mouse.scroll_x as f32,
                scroll_y: st.mouse.scroll_y as f32,
            },
            st.cursor_runtime.take_sources(),
            st.raycaster_last_build.clone(),
        )
    };

    let hit = poll_sources(lua, &sources, x, y, timeout_ms, &last_build)?;

    let mut st = state.borrow_mut();
    st.cursor_runtime
        .replace_sources(std::mem::take(&mut sources));
    st.cursor_runtime.tick(x, y, dt, input, hit);
    sync_runtime_mouse_state(&mut st);
    render_zoom_lens(&mut st);
    render_cursor_trail(&mut st);
    render_cursor_bursts(&mut st);
    if st.cursor_runtime.wants_overlay() {
        render_cursor_overlay(&mut st)?;
    }
    Ok(())
}

impl LuaUserData for LuaCursorManager {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setSystem --
        /// Switches the active runtime cursor to a named system cursor immediately.
        /// @param | name | string | System cursor name such as `"arrow"`, `"hand"`, or `"crosshair"`.
        methods.add_method("setSystem", |_, this, name: String| {
            this.state
                .borrow_mut()
                .cursor_runtime
                .set_system(parse_system_cursor_name(&name)?);
            Ok(())
        });
        // -- setCustom --
        /// Switches the active runtime cursor to a custom RGBA cursor immediately.
        /// @param | cursor | LCustomCursor | Custom cursor handle to display.
        methods.add_method("setCustom", |_, this, cursor: LuaAnyUserData| {
            let cursor = cursor.borrow::<LuaCustomCursor>()?.clone();
            this.state
                .borrow_mut()
                .cursor_runtime
                .set_custom(cursor.inner.borrow().clone());
            Ok(())
        });
        // -- setAnimated --
        /// Switches the active runtime cursor to an animated cursor immediately.
        /// @param | cursor | LAnimatedCursor | Animated cursor handle to display.
        methods.add_method("setAnimated", |_, this, cursor: LuaAnyUserData| {
            let cursor = cursor.borrow::<LuaAnimatedCursor>()?.clone();
            this.state
                .borrow_mut()
                .cursor_runtime
                .set_animated(cursor.inner.borrow().clone());
            Ok(())
        });
        // -- setContext --
        /// Sets the named cursor context used by legacy rules and context-sensitive state resolution.
        /// @param | ctx | string | Context name such as `"default"`, `"menu"`, or `"gameplay"`.
        methods.add_method("setContext", |_, this, ctx: String| {
            this.state
                .borrow_mut()
                .cursor_runtime
                .set_context(CursorContext::from_name(&ctx));
            Ok(())
        });
        // -- defineState --
        /// Defines a reusable named cursor state for rule-driven runtime selection.
        /// @param | name | string | Unique state name used by rules or hit attrs such as `cursor_state`.
        /// @param | spec | table | State table with one of `system`, `custom`, or `animated`, plus optional `scale`, `offset_x`, `offset_y`, `native_preferred`, `trail`, and `zoom`.
        /// @field | system | string | System cursor name when this state uses a native cursor.
        /// @field | custom | LCustomCursor | Custom cursor handle when this state uses a pixel cursor.
        /// @field | animated | LAnimatedCursor | Animated cursor handle when this state uses frame-based cursor playback.
        /// @field | scale | number | Overlay scale multiplier. Defaults to `1.0`.
        /// @field | offset_x | number | Horizontal draw offset in pixels. Defaults to `0`.
        /// @field | offset_y | number | Vertical draw offset in pixels. Defaults to `0`.
        /// @field | native_preferred | boolean | True to keep the OS cursor when possible. Defaults to `true`.
        /// @field | trail | table | Optional trail configuration with `mode`, `color`, `lifetime`, `spacing`, `width`, `max_points`, `texture`, `shader`, and `blend`.
        /// @field | zoom | table | Optional zoom-lens configuration with `magnification`, `radius`, `border_color`, `border_width`, `softness`, and `shader`.
        methods.add_method_mut(
            "defineState",
            |_, this, (name, spec): (String, LuaTable)| {
                let spec = parse_state_spec(spec)?;
                this.state
                    .borrow_mut()
                    .cursor_runtime
                    .define_state(name, spec);
                Ok(())
            },
        );
        // -- defineEffect --
        /// Defines a reusable cursor-local burst effect preset for hover or click rules.
        /// @param | name | string | Unique effect name used by rules or hit attrs such as `cursor_effect`.
        /// @param | spec | table | Effect table with `shape`, `color`, `texture`, `shader`, `count`, `spread`, `lifetime`, `speed`, `size`, `blend`, and optional `button`.
        /// @field | shape | string | Particle shape name such as `"spark"`, `"ring"`, or `"circle"`.
        /// @field | color | table | RGBA color as `{r, g, b, a}` or indexed array values.
        /// @field | texture | LImage|integer | Optional texture source for stamped particles.
        /// @field | shader | LShader | Optional shader used while drawing the effect.
        /// @field | count | integer | Number of particles spawned per burst. Defaults to `12`.
        /// @field | spread | number | Emission arc in radians. Defaults to a full circle.
        /// @field | lifetime | number | Particle lifetime in seconds. Defaults to `0.28`.
        /// @field | speed | number | Initial particle speed in pixels per second. Defaults to `96`.
        /// @field | size | number | Particle size in pixels. Defaults to `5`.
        /// @field | blend | string | Blend mode such as `"alpha"` or `"add"`.
        /// @field | button | integer | Optional mouse button filter for click/release triggers.
        methods.add_method_mut(
            "defineEffect",
            |_, this, (name, spec): (String, LuaTable)| {
                let spec = parse_effect_spec(spec)?;
                this.state
                    .borrow_mut()
                    .cursor_runtime
                    .define_effect(name, spec);
                Ok(())
            },
        );
        // -- addRule --
        /// Registers a legacy context rule or a v2 runtime rule table for hover, click, release, leave, wheel, or context state resolution.
        /// @param | context_or_rule | string|table | Legacy context name, or a v2 rule table with `priority`, `event`, `context`, `target`, `state`, `effect`, and `duration_ms`.
        /// @param | cursor_name? | string | System cursor name used by the legacy `(context, cursor_name)` shorthand.
        /// @return | integer | Rule id for v2 table calls, or `nil` for the legacy shorthand.
        methods.add_method_mut("addRule", |_lua, this, args: LuaMultiValue| {
            let mut iter = args.into_iter();
            match (iter.next(), iter.next(), iter.next()) {
                (Some(LuaValue::String(ctx)), Some(LuaValue::String(cursor_name)), None) => {
                    let ctx = CursorContext::from_name(ctx.to_str()?);
                    let cursor =
                        CursorState::System(parse_system_cursor_name(cursor_name.to_str()?)?);
                    this.state
                        .borrow_mut()
                        .cursor_runtime
                        .add_rule(ContextRule {
                            context: ctx,
                            cursor,
                        });
                    Ok(LuaValue::Nil)
                }
                (Some(LuaValue::Table(rule_tbl)), None, None) => {
                    let id = this
                        .state
                        .borrow_mut()
                        .cursor_runtime
                        .add_rule_v2(rule_to_struct(rule_tbl)?);
                    Ok(LuaValue::Integer(id as i64))
                }
                _ => Err(LuaError::RuntimeError(
                    "addRule expects either (context, cursor_name) or ({...rule...})".into(),
                )),
            }
        });
        // -- addSource --
        /// Registers a hover source that feeds semantic cursor hits into the shared runtime resolver.
        /// @param | source_tbl | table | Source table with `kind = "globe"`, `"raycaster_last"`, or `"callback"`, plus source-specific fields such as `globe`, `marker_radius`, or `callback`.
        /// @return | integer | Source id used with `removeSource`.
        methods.add_method_mut("addSource", |lua, this, source_tbl: LuaTable| {
            let source = source_from_table(lua, source_tbl, &this.state)?;
            let id = source.id();
            this.state.borrow_mut().cursor_runtime.add_source(source);
            Ok(id)
        });
        // -- removeSource --
        /// Removes a previously registered hover source.
        /// @param | id | integer | Source id returned by `addSource`.
        /// @return | boolean | True when a source with that id was removed.
        methods.add_method_mut("removeSource", |_, this, id: usize| {
            Ok(this.state.borrow_mut().cursor_runtime.remove_source(id))
        });
        // -- getLastHit --
        /// Returns the most recent semantic hover hit seen by the runtime cursor.
        /// @return | table | Last hover hit table, or `nil` when nothing is currently resolved.
        /// @field | module | string | Source module name such as `"globe"` or `"raycaster"`.
        /// @field | kind | string | Hit kind such as `"marker"`, `"wall"`, `"sprite"`, or a source-specific label.
        /// @field | surface | string | Surface label such as `"surface"`, `"wall"`, `"floor"`, or `"ceiling"`.
        /// @field | id | string | Optional object identifier.
        /// @field | context | string | Optional source-provided context name.
        /// @field | attrs | table | String map of semantic attributes used by rules and integrations.
        methods.add_method("getLastHit", |lua, this, ()| {
            match this.state.borrow().cursor_runtime.get_last_hit() {
                Some(hit) => Ok(LuaValue::Table(cursor_hit_to_table(lua, hit)?)),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- getActiveState --
        /// Returns the currently resolved cursor state after context, hover, and override rules have been applied.
        /// @return | table | Active state info table.
        /// @field | name | string | Optional named state key when the resolved state came from `defineState`.
        /// @field | kind | string | Active state kind such as `"system"`, `"custom"`, or `"animated"`.
        /// @field | native_preferred | boolean | Whether the runtime prefers leaving the OS cursor visible for this state.
        /// @field | scale | number | Overlay scale multiplier for the resolved state.
        /// @field | offset_x | number | Horizontal draw offset in pixels.
        /// @field | offset_y | number | Vertical draw offset in pixels.
        methods.add_method("getActiveState", |lua, this, ()| {
            Ok(LuaValue::Table(active_state_to_table(
                lua,
                &this.state.borrow().cursor_runtime,
            )?))
        });
        // -- removeRule --
        /// Removes a legacy context rule that was registered with the `(context, cursor_name)` shorthand.
        /// @param | ctx | string | Context name to remove.
        methods.add_method("removeRule", |_, this, ctx: String| {
            this.state
                .borrow_mut()
                .cursor_runtime
                .remove_rule(&CursorContext::from_name(&ctx));
            Ok(())
        });
        // -- update --
        /// Overrides the runtime cursor position and advances cursor-local effects for one frame.
        /// @param | x | number | Cursor X position in screen pixels.
        /// @param | y | number | Cursor Y position in screen pixels.
        /// @param | dt | number | Delta time in seconds for this manual update step.
        methods.add_method("update", |_, this, (x, y, dt): (f32, f32, f32)| {
            this.state.borrow_mut().cursor_runtime.update(x, y, dt);
            Ok(())
        });
        // -- setVisible --
        /// Shows or hides the runtime cursor for the active application window.
        /// @param | visible | boolean | True to show the cursor, or false to hide it.
        methods.add_method("setVisible", |_, this, visible: bool| {
            this.state.borrow_mut().cursor_runtime.set_visible(visible);
            Ok(())
        });
        // -- isVisible --
        /// Returns whether the runtime cursor is currently visible.
        /// @return | boolean | True when the cursor is visible.
        methods.add_method("isVisible", |_, this, ()| {
            Ok(this.state.borrow().cursor_runtime.is_visible())
        });
        // -- setLocked --
        /// Locks or unlocks the runtime cursor according to the active platform policy.
        /// @param | locked | boolean | True to request cursor lock, or false to release it.
        methods.add_method("setLocked", |_, this, locked: bool| {
            this.state.borrow_mut().cursor_runtime.set_locked(locked);
            Ok(())
        });
        // -- isLocked --
        /// Returns whether the runtime cursor is currently marked as locked.
        /// @return | boolean | True when the cursor is locked.
        methods.add_method("isLocked", |_, this, ()| {
            Ok(this.state.borrow().cursor_runtime.is_locked())
        });
        // -- getPosition --
        /// Returns the current runtime cursor position.
        /// @return | number | X coordinate.
        /// @return | number | Y coordinate.
        methods.add_method("getPosition", |_, this, ()| {
            let (x, y) = this.state.borrow().cursor_runtime.position();
            Ok((x, y))
        });
        // -- getContext --
        /// Returns the current named cursor context.
        /// @return | string | Active cursor context name.
        methods.add_method("getContext", |_, this, ()| {
            Ok(this
                .state
                .borrow()
                .cursor_runtime
                .context()
                .as_str()
                .to_string())
        });
        // -- enableTrail --
        /// Enables a simple fading point trail behind the cursor.
        /// @param | r | number | Red channel in the 0.0 through 1.0 range.
        /// @param | g | number | Green channel in the 0.0 through 1.0 range.
        /// @param | b | number | Blue channel in the 0.0 through 1.0 range.
        /// @param | lifetime | number | Trail point lifetime in seconds.
        methods.add_method(
            "enableTrail",
            |_, this, (r, g, b, lifetime): (f32, f32, f32, f32)| {
                let mut trail = CursorTrail::new(TrailMode::FadePoints);
                trail.set_color([r, g, b, 1.0]);
                trail.set_lifetime(lifetime);
                this.state
                    .borrow_mut()
                    .cursor_runtime
                    .set_trail(Some(trail));
                Ok(())
            },
        );
        // -- enableLineTrail --
        /// Enables a simple connected line trail behind the cursor.
        /// @param | r | number | Red channel in the 0.0 through 1.0 range.
        /// @param | g | number | Green channel in the 0.0 through 1.0 range.
        /// @param | b | number | Blue channel in the 0.0 through 1.0 range.
        /// @param | width | number | Trail line width in pixels.
        methods.add_method(
            "enableLineTrail",
            |_, this, (r, g, b, width): (f32, f32, f32, f32)| {
                let mut trail = CursorTrail::new(TrailMode::Line);
                trail.set_color([r, g, b, 1.0]);
                trail.set_width(width);
                this.state
                    .borrow_mut()
                    .cursor_runtime
                    .set_trail(Some(trail));
                Ok(())
            },
        );
        // -- disableTrail --
        /// Disables the current cursor trail.
        methods.add_method("disableTrail", |_, this, ()| {
            this.state.borrow_mut().cursor_runtime.set_trail(None);
            Ok(())
        });
        // -- enableZoom --
        /// Enables the live zoom lens centered on the runtime cursor.
        /// @param | mag | number | Lens magnification multiplier.
        /// @param | radius | number | Lens radius in screen pixels.
        methods.add_method("enableZoom", |_, this, (mag, radius): (f32, f32)| {
            this.state
                .borrow_mut()
                .cursor_runtime
                .set_zoom(Some(CursorZoom::new(mag, radius)));
            Ok(())
        });
        // -- disableZoom --
        /// Disables the live cursor zoom lens.
        methods.add_method("disableZoom", |_, this, ()| {
            this.state.borrow_mut().cursor_runtime.set_zoom(None);
            Ok(())
        });
        // -- type --
        /// Returns the Lua handle type name for this cursor manager userdata.
        /// @return | string | Lua userdata type tag.
        methods.add_method("type", |_, _, ()| Ok("LCursorManager"));
    }
}

impl LuaUserData for LuaCustomCursor {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setPixel --
        /// Writes one RGBA pixel into the custom cursor image.
        /// @param | x | integer | X coordinate.
        /// @param | y | integer | Y coordinate.
        /// @param | r | integer | Red channel in the 0 through 255 range.
        /// @param | g | integer | Green channel in the 0 through 255 range.
        /// @param | b | integer | Blue channel in the 0 through 255 range.
        /// @param | a | integer | Alpha channel in the 0 through 255 range.
        methods.add_method(
            "setPixel",
            |_, this, (x, y, r, g, b, a): (u32, u32, u8, u8, u8, u8)| {
                this.inner.borrow_mut().set_pixel(x, y, r, g, b, a);
                Ok(())
            },
        );
        // -- getPixel --
        /// Reads one RGBA pixel from the custom cursor image.
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
        // -- getSize --
        /// Returns the custom cursor image size.
        /// @return | integer | Width in pixels.
        /// @return | integer | Height in pixels.
        methods.add_method("getSize", |_, this, ()| Ok(this.inner.borrow().size()));
        // -- getHotspot --
        /// Returns the hotspot used when positioning this custom cursor.
        /// @return | integer | Hotspot X coordinate.
        /// @return | integer | Hotspot Y coordinate.
        methods.add_method("getHotspot", |_, this, ()| {
            let cursor = this.inner.borrow();
            Ok((cursor.hotspot_x, cursor.hotspot_y))
        });
    }
}

impl LuaUserData for LuaAnimatedCursor {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addFrame --
        /// Appends one frame to the animated cursor sequence.
        /// @param | cursor | LCustomCursor | Frame image to append.
        /// @param | duration_ms | integer | Frame duration in milliseconds.
        methods.add_method(
            "addFrame",
            |_, this, (cursor, duration_ms): (LuaAnyUserData, u32)| {
                let cursor = cursor.borrow::<LuaCustomCursor>()?.clone();
                this.inner
                    .borrow_mut()
                    .add_frame(cursor.inner.borrow().clone(), duration_ms);
                Ok(())
            },
        );
        // -- update --
        /// Advances animated cursor playback and pulse state.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });
        // -- currentIndex --
        /// Returns the currently active frame index.
        /// @return | integer | Zero-based frame index.
        methods.add_method("currentIndex", |_, this, ()| {
            Ok(this.inner.borrow().current_index())
        });
        // -- frameCount --
        /// Returns the number of frames stored in this animated cursor.
        /// @return | integer | Total frame count.
        methods.add_method("frameCount", |_, this, ()| {
            Ok(this.inner.borrow().frame_count())
        });
        // -- currentScale --
        /// Returns the current pulse scale multiplier.
        /// @return | number | Active scale multiplier.
        methods.add_method("currentScale", |_, this, ()| {
            Ok(this.inner.borrow().current_scale())
        });
        // -- setPulse --
        /// Enables pulse scaling for the animated cursor.
        /// @param | min_scale | number | Minimum scale multiplier.
        /// @param | max_scale | number | Maximum scale multiplier.
        /// @param | speed | number | Pulse speed in oscillations per second.
        methods.add_method(
            "setPulse",
            |_, this, (min_scale, max_scale, speed): (f32, f32, f32)| {
                this.inner.borrow_mut().set_pulse(Some(PulseConfig {
                    min_scale,
                    max_scale,
                    speed,
                }));
                Ok(())
            },
        );
        // -- clearPulse --
        /// Disables pulse scaling for the animated cursor.
        methods.add_method("clearPulse", |_, this, ()| {
            this.inner.borrow_mut().set_pulse(None);
            Ok(())
        });
        // -- reset --
        /// Resets playback to the first frame and clears accumulated animation time.
        methods.add_method("reset", |_, this, ()| {
            this.inner.borrow_mut().reset();
            Ok(())
        });
    }
}

/// Registers the `lurek.cursor` module table and cursor runtime userdata constructors.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let module = lua.create_table()?;

    let state_for_manager = state.clone();
    // --- Cursor factories and runtime accessors ---
    // -- cursor.newManager --
    /// Returns a handle to the shared runtime cursor controller.
    /// @return | LCursorManager | Cursor manager handle bound to the active shared runtime cursor.
    module.set(
        "newManager",
        lua.create_function(move |_, ()| {
            Ok(LuaCursorManager {
                state: state_for_manager.clone(),
            })
        })?,
    )?;

    // -- cursor.newCustom --
    /// Creates a custom RGBA cursor image with an explicit hotspot.
    /// @param | w | integer | Cursor width in pixels.
    /// @param | h | integer | Cursor height in pixels.
    /// @param | hx | integer | Hotspot X coordinate in pixels.
    /// @param | hy | integer | Hotspot Y coordinate in pixels.
    /// @return | LCustomCursor | Custom cursor handle.
    module.set(
        "newCustom",
        lua.create_function(|_, (w, h, hx, hy): (u32, u32, u32, u32)| {
            Ok(LuaCustomCursor {
                inner: Rc::new(RefCell::new(CustomCursor::new(w, h, hx, hy))),
            })
        })?,
    )?;

    // -- cursor.newAnimated --
    /// Creates an animated cursor that can cycle through custom cursor frames.
    /// @param | looping | boolean | True to loop after the last frame, or false to stop on the final frame.
    /// @return | LAnimatedCursor | Animated cursor handle.
    module.set(
        "newAnimated",
        lua.create_function(|_, looping: bool| {
            Ok(LuaAnimatedCursor {
                inner: Rc::new(RefCell::new(AnimatedCursor::new(looping))),
            })
        })?,
    )?;

    // -- cursor.systemCursors --
    /// Returns the list of system cursor names supported by the cursor module.
    /// @return | table | Array of system cursor name strings.
    module.set(
        "systemCursors",
        lua.create_function(|lua, ()| {
            let tbl = lua.create_table()?;
            for (index, name) in [
                "arrow",
                "ibeam",
                "wait",
                "crosshair",
                "wait_arrow",
                "size_nwse",
                "size_nesw",
                "size_we",
                "size_ns",
                "size_all",
                "no",
                "hand",
            ]
            .into_iter()
            .enumerate()
            {
                tbl.set(index + 1, name)?;
            }
            Ok(tbl)
        })?,
    )?;

    lurek.set("cursor", module)?;
    Ok(())
}
