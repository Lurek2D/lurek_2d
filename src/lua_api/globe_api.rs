//! Registers the `lurek.globe` Lua API for globe state, markers, regions, colors, and latitude-longitude validation.

use super::SharedState;
use crate::globe::export::export_regions_to_obj;
use crate::globe::loader;
use crate::globe::marker::MarkerPlacement;
use crate::globe::orbit::SURFACE_ORBIT_NAME;
use crate::globe::picking::{ObjectHit, ObjectPickOptions, ObjectPickOrder, ShellHit};
use crate::globe::projection::screen_delta_to_pan;
use crate::globe::registry::{Globe, GlobeRegistry};
use crate::globe::sphere::{
    great_circle_distance, great_circle_path, lat_lon_to_unit, ray_sphere_intersect,
};
use crate::globe::types::{
    FogState, GlobeOrbit, GlobeOrbitKind, GlobeSpec, HeatLayer, LabelStyle, Layer, LodTier, Marker,
    MarkerShape, MarkerStyle, Region, RegionId, RegionPart, MAX_REGIONS,
};
use crate::globe::validation::{validate_globe_spec, GlobeLoadOptions};
use crate::lua_api::render_api::{
    ensure_shader_target, shader_key_from_userdata, LuaImage, LuaShader,
};
use crate::pathfind::graph_path::GraphCostFn;
use crate::render::ShaderTarget;
use crate::runtime::resource_keys::TextureKey;
use mlua::prelude::*;
use slotmap::Key;
use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use std::rc::Rc;
use std::sync::{Arc, Mutex};
#[derive(Clone)]
/// Lua-side handle for a named globe stored inside a shared registry.
pub struct LuaGlobe {
    /// Shared globe registry containing all named globes.
    reg: Arc<Mutex<GlobeRegistry>>,
    /// Registry key for the globe represented by this Lua handle.
    name: String,
    #[allow(dead_code)]
    /// Shared runtime state retained for future renderer integration.
    state: Rc<RefCell<SharedState>>,
}
impl LuaGlobe {
    /// Reads the named globe from the registry and maps it to a Lua result.
    fn with<R>(&self, f: impl FnOnce(&Globe) -> R) -> LuaResult<R> {
        let guard = self
            .reg
            .lock()
            .map_err(|e| mlua::Error::RuntimeError(format!("globe registry lock poisoned: {e}")))?;
        guard
            .get(&self.name)
            .map(f)
            .ok_or_else(|| mlua::Error::RuntimeError(format!("globe '{}' not found", self.name)))
    }
    /// Mutates the named globe in the registry and maps it to a Lua result.
    fn with_mut<R>(&self, f: impl FnOnce(&mut Globe) -> R) -> LuaResult<R> {
        let mut guard = self
            .reg
            .lock()
            .map_err(|e| mlua::Error::RuntimeError(format!("globe registry lock poisoned: {e}")))?;
        guard
            .get_mut(&self.name)
            .map(f)
            .ok_or_else(|| mlua::Error::RuntimeError(format!("globe '{}' not found", self.name)))
    }

    /// Return the registry handle and globe name used by cursor hover sources.
    pub(crate) fn cursor_binding(&self) -> (Arc<Mutex<GlobeRegistry>>, String) {
        (self.reg.clone(), self.name.clone())
    }
}
fn finite_f32(value: f32, label: &str) -> LuaResult<f32> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "lurek.globe: {label} must be a finite number"
        )))
    }
}

fn finite_non_negative_f64(value: f64, label: &str) -> LuaResult<f64> {
    if !value.is_finite() {
        return Err(LuaError::RuntimeError(format!(
            "lurek.globe: {label} must be a finite number"
        )));
    }
    if value < 0.0 {
        return Err(LuaError::RuntimeError(format!(
            "lurek.globe: {label} must be >= 0"
        )));
    }
    Ok(value)
}

fn unit_interval_f32(value: f32, label: &str) -> LuaResult<f32> {
    let value = finite_f32(value, label)?;
    if !(0.0..=1.0).contains(&value) {
        return Err(LuaError::RuntimeError(format!(
            "lurek.globe: {label} must be in 0..1"
        )));
    }
    Ok(value)
}

fn texture_key_from_raw_id(raw_id: u64) -> (TextureKey, u64) {
    (TextureKey::from(slotmap::KeyData::from_ffi(raw_id)), raw_id)
}

fn parse_texture_integer(value: i64, api_name: &str) -> LuaResult<Option<(TextureKey, u64)>> {
    if value < 0 {
        return Err(LuaError::RuntimeError(format!(
            "{api_name}: texture id must be >= 0"
        )));
    }
    Ok(Some(texture_key_from_raw_id(value as u64)))
}

fn parse_texture_number(value: f64, api_name: &str) -> LuaResult<Option<(TextureKey, u64)>> {
    if !value.is_finite() {
        return Err(LuaError::RuntimeError(format!(
            "{api_name}: texture id must be a finite number"
        )));
    }
    if value.fract().abs() > f64::EPSILON {
        return Err(LuaError::RuntimeError(format!(
            "{api_name}: texture id must be an integer"
        )));
    }
    parse_texture_integer(value as i64, api_name)
}

fn parse_texture_userdata(
    userdata: &LuaAnyUserData,
    api_name: &str,
) -> LuaResult<Option<(TextureKey, u64)>> {
    let image = userdata.borrow::<LuaImage>().map_err(|_| {
        LuaError::RuntimeError(format!(
            "{api_name}: texture must be an integer id, LImage userdata, or nil"
        ))
    })?;
    Ok(Some((image.key, image.key.data().as_ffi())))
}

fn parse_texture_key_value(
    value: &LuaValue,
    api_name: &str,
) -> LuaResult<Option<(TextureKey, u64)>> {
    match value {
        LuaValue::Nil => Ok(None),
        LuaValue::Integer(value) => parse_texture_integer(*value, api_name),
        LuaValue::Number(value) => parse_texture_number(*value, api_name),
        LuaValue::UserData(userdata) => parse_texture_userdata(userdata, api_name),
        _ => Err(LuaError::RuntimeError(format!(
            "{api_name}: texture must be an integer id, LImage userdata, or nil"
        ))),
    }
}

fn validate_texture_key_live(
    state: &SharedState,
    api_name: &str,
    entry: Option<(TextureKey, u64)>,
) -> LuaResult<Option<(TextureKey, u64)>> {
    let Some((key, raw_id)) = entry else {
        return Ok(None);
    };
    if !state.textures.contains_key(key) {
        return Err(LuaError::RuntimeError(format!(
            "{api_name}: texture id {raw_id} does not exist in the current resource registry"
        )));
    }
    Ok(Some((key, raw_id)))
}

fn parse_texture_key_value_checked(
    value: &LuaValue,
    api_name: &str,
    state: &SharedState,
) -> LuaResult<Option<(TextureKey, u64)>> {
    validate_texture_key_live(state, api_name, parse_texture_key_value(value, api_name)?)
}

fn validate_lat_lon(lat: f32, lon: f32, label: &str) -> LuaResult<(f32, f32)> {
    let lat = finite_f32(lat, &format!("{label} latitude"))?;
    let lon = finite_f32(lon, &format!("{label} longitude"))?;
    if !(-90.0..=90.0).contains(&lat) {
        return Err(LuaError::RuntimeError(format!(
            "lurek.globe: {label} latitude must be in -90..90"
        )));
    }
    if !(-180.0..=180.0).contains(&lon) {
        return Err(LuaError::RuntimeError(format!(
            "lurek.globe: {label} longitude must be in -180..180"
        )));
    }
    Ok((lat, lon))
}

fn parse_color_table(
    tbl: Option<LuaTable>,
    fallback: [f32; 4],
    label: &str,
) -> LuaResult<[f32; 4]> {
    let Some(tbl) = tbl else {
        return Ok(fallback);
    };
    let mut out = fallback;
    for (index, slot) in out.iter_mut().enumerate() {
        if let Ok(value) = tbl.get::<_, f32>(index + 1) {
            let value = unit_interval_f32(value, &format!("{label}[{}]", index + 1))?;
            *slot = value;
        }
    }
    Ok(out)
}

fn parse_attrs_table(tbl: LuaTable, label: &str) -> LuaResult<HashMap<String, String>> {
    let mut attrs = HashMap::new();
    for pair in tbl.pairs::<String, String>() {
        let (key, val) = pair.map_err(|err| {
            LuaError::RuntimeError(format!(
                "lurek.globe: {label} attrs must be string keys and values: {err}"
            ))
        })?;
        attrs.insert(key, val);
    }
    Ok(attrs)
}

fn parse_member_ids(tbl: LuaTable, label: &str) -> LuaResult<Vec<RegionId>> {
    let mut members = Vec::new();
    for id in tbl.sequence_values::<u32>() {
        members.push(RegionId(id?));
    }
    if members.is_empty() {
        return Err(LuaError::RuntimeError(format!(
            "lurek.globe.{label}: members must not be empty"
        )));
    }
    Ok(members)
}

fn parse_lat_lon_loop(tbl: LuaTable, label: &str) -> LuaResult<Vec<(f32, f32)>> {
    let mut vertices = Vec::new();
    for (index, vt) in tbl.sequence_values::<LuaTable>().enumerate() {
        let vt = vt?;
        let (lat, lon) = validate_lat_lon(
            vt.get::<_, f32>(1)?,
            vt.get::<_, f32>(2)?,
            &format!("{label} vertex {}", index + 1),
        )?;
        vertices.push((lat, lon));
    }
    if vertices.len() < 3 {
        return Err(LuaError::RuntimeError(format!(
            "lurek.globe: {label} must have at least 3 vertices"
        )));
    }
    Ok(vertices)
}

fn parse_region_parts(tbl: LuaTable, kind: &str, id: u32) -> LuaResult<Vec<RegionPart>> {
    let mut parts = Vec::new();
    for (index, part_tbl) in tbl.sequence_values::<LuaTable>().enumerate() {
        let part_tbl = part_tbl?;
        let outer_tbl: LuaTable = part_tbl.get("outer").map_err(|_| {
            LuaError::RuntimeError(format!(
                "lurek.globe.{kind}: region {id} part {} requires 'outer'",
                index + 1
            ))
        })?;
        let outer = parse_lat_lon_loop(
            outer_tbl,
            &format!("{kind} region {id} part {} outer", index + 1),
        )?;
        let mut holes = Vec::new();
        if let Ok(holes_tbl) = part_tbl.get::<_, LuaTable>("holes") {
            for (hole_index, hole_tbl) in holes_tbl.sequence_values::<LuaTable>().enumerate() {
                let hole_tbl = hole_tbl?;
                holes.push(parse_lat_lon_loop(
                    hole_tbl,
                    &format!(
                        "{kind} region {id} part {} hole {}",
                        index + 1,
                        hole_index + 1
                    ),
                )?);
            }
        }
        parts.push(RegionPart { outer, holes });
    }
    if parts.is_empty() {
        return Err(LuaError::RuntimeError(format!(
            "lurek.globe.{kind}: region {id} parts must not be empty"
        )));
    }
    Ok(parts)
}

fn parse_region_table_with_options(
    p: LuaTable,
    kind: &str,
    fallback_color: [f32; 4],
    allow_member_only: bool,
    overlay_region: bool,
) -> LuaResult<Region> {
    let id: u32 = p.get("id")?;
    let members = p
        .get::<_, LuaTable>("members")
        .ok()
        .map(|tbl| parse_member_ids(tbl, kind))
        .transpose()?
        .unwrap_or_default();
    let parts = p
        .get::<_, LuaTable>("parts")
        .ok()
        .map(|tbl| parse_region_parts(tbl, kind, id))
        .transpose()?;
    let vertices = if let Some(parts) = &parts {
        parts
            .first()
            .map(|part| part.outer.clone())
            .unwrap_or_default()
    } else {
        match p.get::<_, LuaTable>("vertices") {
            Ok(verts_tbl) => parse_lat_lon_loop(verts_tbl, &format!("{kind} region {id}"))?,
            Err(_) if allow_member_only && !members.is_empty() => Vec::new(),
            Err(_) => {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.globe.{kind}: region {id} requires 'vertices' or 'parts'"
                )));
            }
        }
    };
    let neighbors: Vec<RegionId> = p
        .get::<_, LuaTable>("neighbors")
        .map(|t| {
            t.sequence_values::<u32>()
                .map(|r| r.map(RegionId))
                .collect::<LuaResult<Vec<_>>>()
        })
        .unwrap_or_else(|_| Ok(vec![]))?;
    let centroid = if let Ok(ct) = p.get::<_, LuaTable>("centroid") {
        validate_lat_lon(
            ct.get::<_, f32>(1)?,
            ct.get::<_, f32>(2)?,
            &format!("{kind} region {id} centroid"),
        )?
    } else if vertices.is_empty() && parts.is_none() {
        (0.0, 0.0)
    } else {
        if let Some(parts) = &parts {
            Region::from_parts(RegionId(id), parts.clone()).centroid
        } else {
            Region::new(RegionId(id), vertices.clone()).centroid
        }
    };
    let base_color = parse_color_table(
        p.get("base_color").ok(),
        fallback_color,
        &format!("{kind} region {id} base_color"),
    )?;
    let mut region = if let Some(parts) = parts {
        Region::with_parts_data(RegionId(id), centroid, parts, neighbors, base_color)
    } else {
        Region::with_data(RegionId(id), centroid, vertices, neighbors, base_color)
    };
    if let Ok(attrs_tbl) = p.get::<_, LuaTable>("attrs") {
        region.attrs = parse_attrs_table(attrs_tbl, &format!("{kind} region {id}"))?;
    }
    region.member_terrain_ids = members;
    if overlay_region {
        region.overlay_color = Some(base_color);
    }
    Ok(region)
}

fn parse_region_table(p: LuaTable, kind: &str) -> LuaResult<Region> {
    parse_region_table_with_options(p, kind, [0.5, 0.5, 0.5, 1.0], false, false)
}

fn parse_marker_shape(shape: &str) -> LuaResult<MarkerShape> {
    match shape {
        "circle" => Ok(MarkerShape::Circle),
        "square" => Ok(MarkerShape::Square),
        "diamond" => Ok(MarkerShape::Diamond),
        "triangle" => Ok(MarkerShape::Triangle),
        "cross" => Ok(MarkerShape::Cross),
        _ => Err(LuaError::RuntimeError(format!(
            "lurek.globe: unsupported marker shape '{}'",
            shape
        ))),
    }
}

fn marker_shape_name(shape: MarkerShape) -> &'static str {
    match shape {
        MarkerShape::Circle => "circle",
        MarkerShape::Square => "square",
        MarkerShape::Diamond => "diamond",
        MarkerShape::Triangle => "triangle",
        MarkerShape::Cross => "cross",
    }
}

fn parse_orbit_kind(kind: &str) -> LuaResult<GlobeOrbitKind> {
    match kind {
        "surface" => Ok(GlobeOrbitKind::Surface),
        "atmosphere" => Ok(GlobeOrbitKind::Atmosphere),
        "orbit" => Ok(GlobeOrbitKind::Orbit),
        "effect" => Ok(GlobeOrbitKind::Effect),
        other => Err(LuaError::RuntimeError(format!(
            "lurek.globe: unsupported orbit kind '{}'",
            other
        ))),
    }
}

fn orbit_kind_name(kind: GlobeOrbitKind) -> &'static str {
    match kind {
        GlobeOrbitKind::Surface => "surface",
        GlobeOrbitKind::Atmosphere => "atmosphere",
        GlobeOrbitKind::Orbit => "orbit",
        GlobeOrbitKind::Effect => "effect",
    }
}

fn orbit_defaults(name: &str, altitude_px: f32, kind: GlobeOrbitKind) -> GlobeOrbit {
    if name == SURFACE_ORBIT_NAME || kind == GlobeOrbitKind::Surface {
        return GlobeOrbit::surface();
    }
    let (color, width_px, draw_shell) = match kind {
        GlobeOrbitKind::Atmosphere => ([0.30, 0.55, 0.95, 0.25], 10.0, true),
        GlobeOrbitKind::Effect => ([0.80, 0.90, 1.00, 0.18], 3.0, true),
        GlobeOrbitKind::Orbit => ([0.30, 0.60, 1.00, 0.25], 2.0, true),
        GlobeOrbitKind::Surface => ([0.0, 0.0, 0.0, 0.0], 0.0, false),
    };
    GlobeOrbit {
        name: name.to_string(),
        altitude_px,
        visible: true,
        z_order: altitude_px.round() as i32,
        kind,
        accepts_markers: true,
        pickable: true,
        draw_shell,
        color,
        width_px,
        attrs: HashMap::new(),
        shader: None,
    }
}

fn parse_orbit_table(tbl: LuaTable, label: &str) -> LuaResult<GlobeOrbit> {
    let name: String = tbl.get("name").map_err(|_| {
        LuaError::RuntimeError(format!("lurek.globe.{label}: orbit table requires 'name'"))
    })?;
    let kind = if name == SURFACE_ORBIT_NAME {
        GlobeOrbitKind::Surface
    } else if let Ok(raw_kind) = tbl.get::<_, String>("kind") {
        parse_orbit_kind(raw_kind.as_str())?
    } else {
        GlobeOrbitKind::Orbit
    };
    let altitude_px = if name == SURFACE_ORBIT_NAME {
        0.0
    } else {
        let value = tbl.get::<_, Option<f32>>("altitude_px")?.unwrap_or(0.0);
        let value = finite_f32(value, &format!("{label} orbit altitude_px"))?;
        if value < 0.0 {
            return Err(LuaError::RuntimeError(format!(
                "lurek.globe.{label}: orbit altitude_px must be >= 0"
            )));
        }
        value
    };
    let mut orbit = orbit_defaults(&name, altitude_px, kind);
    if let Some(visible) = tbl.get::<_, Option<bool>>("visible")? {
        orbit.visible = visible;
    }
    if let Ok(z_order) = tbl.get::<_, i32>("z_order") {
        orbit.z_order = z_order;
    }
    if let Some(accepts_markers) = tbl.get::<_, Option<bool>>("accepts_markers")? {
        orbit.accepts_markers = accepts_markers;
    }
    if let Some(pickable) = tbl.get::<_, Option<bool>>("pickable")? {
        orbit.pickable = pickable;
    }
    if let Some(draw_shell) = tbl.get::<_, Option<bool>>("draw_shell")? {
        orbit.draw_shell = draw_shell;
    }
    if let Ok(width_px) = tbl.get::<_, f32>("width_px") {
        let width_px = finite_f32(width_px, &format!("{label} orbit width_px"))?;
        if width_px < 0.0 {
            return Err(LuaError::RuntimeError(format!(
                "lurek.globe.{label}: orbit width_px must be >= 0"
            )));
        }
        orbit.width_px = width_px;
    }
    orbit.color = parse_color_table(
        tbl.get("color").ok(),
        orbit.color,
        &format!("{label} orbit color"),
    )?;
    if let Ok(attrs_tbl) = tbl.get::<_, LuaTable>("attrs") {
        orbit.attrs = parse_attrs_table(attrs_tbl, &format!("{label} orbit"))?;
    }
    Ok(orbit)
}

#[derive(Clone)]
struct ParsedGlobeConfig {
    spec: GlobeSpec,
    orbits: Vec<GlobeOrbit>,
    load_options: GlobeLoadOptions,
}

#[derive(Clone)]
struct ParsedMarkerInput {
    marker_type: String,
    lat_deg: f32,
    lon_deg: f32,
    orbit: String,
    altitude_px: Option<f32>,
    label: Option<String>,
    visible: bool,
    style: MarkerStyle,
    attrs: HashMap<String, String>,
}

fn parse_marker_ex_table(tbl: LuaTable, state: &SharedState) -> LuaResult<ParsedMarkerInput> {
    let marker_type: String = tbl.get("type").map_err(|_| {
        LuaError::RuntimeError("lurek.globe.addMarkerEx: marker table requires 'type'".to_string())
    })?;
    let lat: f32 = tbl.get("lat").map_err(|_| {
        LuaError::RuntimeError("lurek.globe.addMarkerEx: marker table requires 'lat'".to_string())
    })?;
    let lon: f32 = tbl.get("lon").map_err(|_| {
        LuaError::RuntimeError("lurek.globe.addMarkerEx: marker table requires 'lon'".to_string())
    })?;
    let (lat_deg, lon_deg) = validate_lat_lon(lat, lon, "addMarkerEx")?;
    let orbit = tbl
        .get::<_, Option<String>>("orbit")?
        .unwrap_or_else(|| SURFACE_ORBIT_NAME.to_string());
    let altitude_px = match tbl.get::<_, Option<f32>>("altitude_px")? {
        Some(value) => {
            let value = finite_f32(value, "addMarkerEx altitude_px")?;
            if value < 0.0 {
                return Err(LuaError::RuntimeError(
                    "lurek.globe.addMarkerEx: altitude_px must be >= 0".to_string(),
                ));
            }
            Some(value)
        }
        None => None,
    };
    let mut style = MarkerStyle::default();
    if let Ok(size) = tbl.get::<_, f32>("size") {
        style.size = finite_f32(size, "addMarkerEx size")?;
        if style.size < 1.0 {
            return Err(LuaError::RuntimeError(
                "lurek.globe.addMarkerEx: size must be >= 1".to_string(),
            ));
        }
    }
    if let Ok(shape) = tbl.get::<_, String>("shape") {
        style.shape = parse_marker_shape(shape.as_str())?;
    }
    if let Ok(color_tbl) = tbl.get::<_, LuaTable>("color") {
        style.color = parse_color_table(Some(color_tbl), style.color, "addMarkerEx color")?;
    }
    let icon_value = tbl
        .get::<_, LuaValue>("icon")
        .or_else(|_| tbl.get::<_, LuaValue>("icon_texture"))
        .unwrap_or(LuaValue::Nil);
    if let Some((texture_key, _)) =
        parse_texture_key_value_checked(&icon_value, "lurek.globe.addMarkerEx", state)?
    {
        style.icon_texture_key = Some(texture_key);
    }
    if let Ok(pulse_hz) = tbl.get::<_, f32>("pulse_hz") {
        style.pulse_hz = finite_f32(pulse_hz, "addMarkerEx pulse_hz")?;
        if style.pulse_hz < 0.0 {
            return Err(LuaError::RuntimeError(
                "lurek.globe.addMarkerEx: pulse_hz must be >= 0".to_string(),
            ));
        }
    }
    if let Ok(pulse_amplitude) = tbl.get::<_, f32>("pulse_amplitude") {
        style.pulse_amplitude = unit_interval_f32(pulse_amplitude, "addMarkerEx pulse_amplitude")?;
    }
    if let Ok(rotation) = tbl.get::<_, f32>("rotation_deg_per_sec") {
        style.rotation_deg_per_sec = finite_f32(rotation, "addMarkerEx rotation_deg_per_sec")?;
    }
    let attrs = if let Ok(attrs_tbl) = tbl.get::<_, LuaTable>("attrs") {
        parse_attrs_table(attrs_tbl, "addMarkerEx marker")?
    } else {
        HashMap::new()
    };
    Ok(ParsedMarkerInput {
        marker_type,
        lat_deg,
        lon_deg,
        orbit,
        altitude_px,
        label: tbl.get::<_, Option<String>>("label")?,
        visible: tbl.get::<_, Option<bool>>("visible")?.unwrap_or(true),
        style,
        attrs,
    })
}

fn parse_object_pick_options(tbl: Option<LuaTable>, label: &str) -> LuaResult<ObjectPickOptions> {
    let mut opts = ObjectPickOptions::default();
    let Some(tbl) = tbl else {
        return Ok(opts);
    };
    if let Ok(radius) = tbl.get::<_, f32>("marker_radius") {
        opts.marker_radius = finite_f32(radius, &format!("{label} marker_radius"))?.max(0.0);
    }
    if let Some(include_surface) = tbl.get::<_, Option<bool>>("include_surface")? {
        opts.include_surface = include_surface;
    }
    if let Some(include_regions) = tbl.get::<_, Option<bool>>("include_regions")? {
        opts.include_regions = include_regions;
    }
    if let Some(include_markers) = tbl.get::<_, Option<bool>>("include_markers")? {
        opts.include_markers = include_markers;
    }
    if let Some(include_orbits) = tbl.get::<_, Option<bool>>("include_orbits")? {
        opts.include_orbits = include_orbits;
    }
    if let Ok(order) = tbl.get::<_, String>("order") {
        opts.order = match order.as_str() {
            "markers_first" => ObjectPickOrder::MarkersFirst,
            "front_to_back" => ObjectPickOrder::FrontToBack,
            other => {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.globe.{label}: unsupported pick order '{}'",
                    other
                )))
            }
        };
    }
    Ok(opts)
}

fn parse_globe_load_options(tbl: Option<&LuaTable>, label: &str) -> LuaResult<GlobeLoadOptions> {
    let mut options = GlobeLoadOptions::default();
    let Some(tbl) = tbl else {
        return Ok(options);
    };
    let load_options = tbl.get::<_, LuaTable>("load_options").ok();
    let Some(load_options) = load_options else {
        return Ok(options);
    };
    if let Some(root) = load_options.get::<_, Option<String>>("sandbox_root")? {
        options.sandbox_root = std::path::PathBuf::from(root);
    }
    if let Ok(max_toml_bytes) = load_options.get::<_, u64>("max_toml_bytes") {
        if max_toml_bytes == 0 {
            return Err(LuaError::RuntimeError(format!(
                "lurek.globe.{label}: load_options.max_toml_bytes must be > 0"
            )));
        }
        options.max_toml_bytes = max_toml_bytes;
    }
    if let Ok(max_png_bytes) = load_options.get::<_, u64>("max_png_bytes") {
        if max_png_bytes == 0 {
            return Err(LuaError::RuntimeError(format!(
                "lurek.globe.{label}: load_options.max_png_bytes must be > 0"
            )));
        }
        options.max_png_bytes = max_png_bytes;
    }
    if let Ok(max_png_pixels) = load_options.get::<_, u64>("max_png_pixels") {
        if max_png_pixels == 0 {
            return Err(LuaError::RuntimeError(format!(
                "lurek.globe.{label}: load_options.max_png_pixels must be > 0"
            )));
        }
        options.max_png_pixels = max_png_pixels;
    }
    Ok(options)
}

fn parse_globe_config(tbl: Option<LuaTable>, label: &str) -> LuaResult<ParsedGlobeConfig> {
    let spec = parse_globe_spec(tbl.clone(), label)?;
    let load_options = parse_globe_load_options(tbl.as_ref(), label)?;
    let mut orbits = Vec::new();
    if let Some(tbl) = tbl {
        if let Ok(orbits_tbl) = tbl.get::<_, LuaTable>("orbits") {
            for orbit_tbl in orbits_tbl.sequence_values::<LuaTable>() {
                orbits.push(parse_orbit_table(orbit_tbl?, label)?);
            }
        }
    }
    Ok(ParsedGlobeConfig {
        spec,
        orbits,
        load_options,
    })
}

fn apply_orbits_to_globe(globe: &mut Globe, orbits: &[GlobeOrbit], label: &str) -> LuaResult<()> {
    for orbit in orbits.iter().cloned() {
        globe
            .add_orbit(orbit)
            .map_err(|err| LuaError::RuntimeError(format!("lurek.globe.{label}: {err}")))?;
    }
    Ok(())
}

fn color_table(lua: &Lua, color: [f32; 4]) -> LuaResult<LuaTable<'_>> {
    let table = lua.create_table()?;
    for (index, value) in color.into_iter().enumerate() {
        table.set(index + 1, value)?;
    }
    Ok(table)
}

fn attrs_snapshot_table<'lua>(
    lua: &'lua Lua,
    attrs: &HashMap<String, String>,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    let mut keys: Vec<&String> = attrs.keys().collect();
    keys.sort();
    for key in keys {
        if let Some(value) = attrs.get(key) {
            table.set(key.as_str(), value.as_str())?;
        }
    }
    Ok(table)
}

fn marker_style_snapshot_table<'lua>(
    lua: &'lua Lua,
    style: &MarkerStyle,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("color", color_table(lua, style.color)?)?;
    table.set("size", style.size)?;
    table.set("shape", marker_shape_name(style.shape))?;
    table.set(
        "icon_texture",
        style.icon_texture_key.map(|key| key.data().as_ffi()),
    )?;
    table.set("pulse_hz", style.pulse_hz)?;
    table.set("pulse_amplitude", style.pulse_amplitude)?;
    table.set("rotation_deg_per_sec", style.rotation_deg_per_sec)?;
    Ok(table)
}

fn marker_info_table<'lua>(lua: &'lua Lua, marker: &Marker) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("id", marker.id)?;
    table.set("type", marker.marker_type.clone())?;
    table.set("lat", marker.lat_deg)?;
    table.set("lon", marker.lon_deg)?;
    table.set("orbit", marker.orbit.clone())?;
    table.set("altitude_px", marker.altitude_px)?;
    table.set("label", marker.label.clone())?;
    table.set("visible", marker.visible)?;
    table.set("style", marker_style_snapshot_table(lua, &marker.style)?)?;
    table.set("attrs", attrs_snapshot_table(lua, &marker.attrs)?)?;
    Ok(table)
}

fn orbit_snapshot_table<'lua>(
    lua: &'lua Lua,
    orbit: &GlobeOrbit,
    state: Rc<RefCell<SharedState>>,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("name", orbit.name.clone())?;
    table.set("altitude_px", orbit.altitude_px)?;
    table.set("visible", orbit.visible)?;
    table.set("z_order", orbit.z_order)?;
    table.set("kind", orbit_kind_name(orbit.kind))?;
    table.set("accepts_markers", orbit.accepts_markers)?;
    table.set("pickable", orbit.pickable)?;
    table.set("draw_shell", orbit.draw_shell)?;
    table.set("color", color_table(lua, orbit.color)?)?;
    table.set("width_px", orbit.width_px)?;
    table.set("attrs", attrs_snapshot_table(lua, &orbit.attrs)?)?;
    table.set(
        "shader",
        orbit.shader.map(|key| LuaShader {
            key,
            state: state.clone(),
        }),
    )?;
    Ok(table)
}

fn object_hit_kind_name(kind: crate::globe::picking::ObjectHitKind) -> &'static str {
    match kind {
        crate::globe::picking::ObjectHitKind::Marker => "marker",
        crate::globe::picking::ObjectHitKind::Orbit => "orbit",
        crate::globe::picking::ObjectHitKind::Province => "province",
        crate::globe::picking::ObjectHitKind::Region => "region",
        crate::globe::picking::ObjectHitKind::Surface => "surface",
    }
}

fn object_hit_table<'lua>(lua: &'lua Lua, hit: &ObjectHit) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("kind", object_hit_kind_name(hit.kind))?;
    table.set("id", hit.id)?;
    table.set("orbit", hit.orbit.clone())?;
    table.set("lat", hit.lat_deg)?;
    table.set("lon", hit.lon_deg)?;
    table.set("altitude_px", hit.altitude_px)?;
    table.set("screen_x", hit.screen_x)?;
    table.set("screen_y", hit.screen_y)?;
    table.set("depth", hit.depth)?;
    table.set("distance_px", hit.distance_px)?;
    table.set("attrs", attrs_snapshot_table(lua, &hit.attrs)?)?;
    Ok(table)
}

fn shell_hit_table<'lua>(
    lua: &'lua Lua,
    orbit_name: &str,
    hit: &ShellHit,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("orbit", orbit_name)?;
    table.set("lat", hit.lat_deg)?;
    table.set("lon", hit.lon_deg)?;
    table.set("altitude_px", hit.altitude_px)?;
    table.set("depth", hit.depth)?;
    table.set("x", hit.world_pos.x)?;
    table.set("y", hit.world_pos.y)?;
    table.set("z", hit.world_pos.z)?;
    Ok(table)
}

fn normalize_time_of_day(t: f32) -> LuaResult<f32> {
    Ok(finite_f32(t, "time_of_day")?.rem_euclid(24.0))
}

fn parse_cost_fn(opts: Option<LuaTable>, label: &str) -> LuaResult<GraphCostFn> {
    let mut cost_fn = GraphCostFn::new();
    let Some(opts) = opts else {
        return Ok(cost_fn);
    };
    if let Ok(default_cost) = opts.get::<_, f64>("default_cost") {
        cost_fn.default_cost =
            finite_non_negative_f64(default_cost, &format!("{label} default_cost"))?;
    }
    if let Ok(province_costs) = opts.get::<_, LuaTable>("province_costs") {
        for pair in province_costs.pairs::<u32, f64>() {
            let (id, cost) = pair?;
            cost_fn.province_costs.insert(
                id,
                finite_non_negative_f64(cost, &format!("{label} province_costs[{id}]"))?,
            );
        }
    }
    if let Ok(tag_costs) = opts.get::<_, LuaTable>("tag_costs") {
        for pair in tag_costs.pairs::<String, f64>() {
            let (tag, cost) = pair?;
            cost_fn.tag_costs.insert(
                tag.clone(),
                finite_non_negative_f64(cost, &format!("{label} tag_costs.{tag}"))?,
            );
        }
    }
    if let Ok(blocked_ids) = opts.get::<_, LuaTable>("blocked_ids") {
        for id in blocked_ids.sequence_values::<u32>() {
            cost_fn.blocked.insert(id?);
        }
    }
    Ok(cost_fn)
}
/// Provides Lua methods for editing and querying one named globe.
impl LuaUserData for LuaGlobe {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addProvince --
        /// Adds a province described by id, centroid, polygon vertices or multipart geometry, neighbors, and optional base color.
        /// @param | p | table | Province table with `id`, optional `centroid`, either `vertices` or `parts`, optional `neighbors`, and optional `base_color`.
        /// @return | boolean | True when the province was accepted by the globe.
        methods.add_method_mut("addProvince", |_, this, p: LuaTable| {
            let region = parse_region_table(p, "addProvince")?;
            this.with_mut(|g| {
                if g.get_province(region.id).is_some() {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.globe.addProvince: province {} already exists",
                        region.id
                    )));
                }
                g.add_province(region)
                    .map(|_| true)
                    .map_err(|e| LuaError::RuntimeError(format!("lurek.globe.addProvince: {e}")))
            })?
        });
        // -- removeProvince --
        /// Removes a region by id. This method is available to Lua scripts.
        /// @param | id | integer | Region id to remove.
        /// @return | boolean | True when a region was removed.
        methods.add_method_mut("removeProvince", |_, this, id: u32| {
            this.with_mut(|g| g.remove_province(RegionId(id)).is_some())
        });
        // -- addRegion -- (alias for addProvince)
        /// Adds a region described by id, centroid, polygon vertices or multipart geometry, neighbors, and optional base color.
        /// @param | p | table | Region table with `id`, optional `centroid`, `vertices` or `parts`, optional `members`, optional `neighbors`, optional `attrs`, and optional `base_color`.
        /// @return | boolean | True when the region was accepted by the globe.
        methods.add_method_mut("addRegion", |_, this, p: LuaTable| {
            let region = parse_region_table_with_options(
                p,
                "addRegion",
                [0.2, 0.55, 1.0, 0.22],
                true,
                true,
            )?;
            this.with_mut(|g| {
                if g.get_region(region.id).is_some() {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.globe.addRegion: region {} already exists",
                        region.id
                    )));
                }
                g.add_region(region)
                    .map(|_| true)
                    .map_err(|e| LuaError::RuntimeError(format!("lurek.globe.addRegion: {e}")))
            })?
        });
        // -- removeRegion -- (alias for removeProvince)
        /// Removes a region by id. This method is available to Lua scripts.
        /// @param | id | integer | Region id to remove.
        /// @return | boolean | True when a region was removed.
        methods.add_method_mut("removeRegion", |_, this, id: u32| {
            this.with_mut(|g| g.remove_region(RegionId(id)).is_some())
        });
        // -- addTerrainPatch --
        /// Adds a base terrain polygon patch described by id, centroid, polygon vertices or multipart geometry, optional attrs, and optional base color.
        /// @param | p | table | Terrain patch table with `id`, optional `centroid`, either `vertices` or `parts`, optional `attrs`, and optional `base_color`.
        /// @return | boolean | True when the terrain patch was accepted by the globe.
        methods.add_method_mut("addTerrainPatch", |_, this, p: LuaTable| {
            let patch = parse_region_table_with_options(
                p,
                "addTerrainPatch",
                [0.5, 0.5, 0.5, 1.0],
                false,
                false,
            )?;
            this.with_mut(|g| {
                if g.get_terrain_patch(patch.id).is_some() {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.globe.addTerrainPatch: terrain patch {} already exists",
                        patch.id
                    )));
                }
                g.add_terrain_patch(patch).map(|_| true).map_err(|e| {
                    LuaError::RuntimeError(format!("lurek.globe.addTerrainPatch: {e}"))
                })
            })?
        });
        // -- removeTerrainPatch --
        /// Removes a stored terrain patch by its numeric id.
        /// @param | id | integer | Terrain patch id to remove.
        /// @return | boolean | True when a terrain patch was removed.
        methods.add_method_mut("removeTerrainPatch", |_, this, id: u32| {
            this.with_mut(|g| g.remove_terrain_patch(RegionId(id)).is_some())
        });
        // -- terrainPatchCount --
        /// Returns the number of stored base terrain patches.
        /// @return | integer | Terrain patch count.
        methods.add_method("terrainPatchCount", |_, this, ()| {
            this.with(|g| g.terrain_patch_count())
        });
        // -- provinceCount --
        /// Returns the number of rendered provinces in this globe.
        /// @return | integer | Province count.
        methods.add_method("provinceCount", |_, this, ()| {
            this.with(|g| g.province_count())
        });
        // -- regionCount -- (alias)
        /// Returns the number of stored semantic regions in this globe.
        /// @return | integer | Semantic region count.
        methods.add_method("regionCount", |_, this, ()| this.with(|g| g.region_count()));
        // -- getNeighbors --
        /// Returns neighboring province ids for a province.
        /// @param | id | integer | Province id.
        /// @return | integer[] | Array table of neighboring province ids.
        methods.add_method("getNeighbors", |lua, this, id: u32| {
            let neighbors = this.with(|g| {
                g.get_province(RegionId(id))
                    .map(|p| p.neighbors.clone())
                    .unwrap_or_default()
            })?;
            let t = lua.create_table()?;
            for (i, n) in neighbors.iter().enumerate() {
                t.set(i + 1, n.0)?;
            }
            Ok(t)
        });
        // -- setEdgeTags --
        /// Replaces the tag set stored on an existing province edge.
        /// @param | a | integer | First province id.
        /// @param | b | integer | Second province id.
        /// @param | tags | string[] | Sequential table of edge tag strings.
        /// @return | boolean | True when the edge exists and the tags were stored.
        methods.add_method_mut(
            "setEdgeTags",
            |_, this, (a, b, tags): (u32, u32, LuaTable)| {
                let mut set = HashSet::new();
                for tag in tags.sequence_values::<String>() {
                    set.insert(tag?);
                }
                this.with_mut(|g| {
                    g.graph
                        .set_edge_tags(RegionId(a), RegionId(b), set)
                        .unwrap_or(false)
                })
            },
        );
        // -- getEdgeTags --
        /// Returns the sorted tag strings stored on a province edge.
        /// @param | a | integer | First province id.
        /// @param | b | integer | Second province id.
        /// @return | string[] | Sequential table of edge tag strings, empty when none are set.
        methods.add_method("getEdgeTags", |lua, this, (a, b): (u32, u32)| {
            let tags = this.with(|g| g.graph.edge_tags(RegionId(a), RegionId(b)))?;
            let out = lua.create_table()?;
            for (index, tag) in tags.iter().enumerate() {
                out.set(index + 1, tag.as_str())?;
            }
            Ok(out)
        });
        // -- setProvinceAttr --
        /// Sets a string attribute on a province.
        /// @param | id | integer | Province id.
        /// @param | key | string | Attribute key.
        /// @param | val | string | Attribute value.
        /// @return | boolean | True when the province exists.
        methods.add_method_mut(
            "setProvinceAttr",
            |_, this, (id, key, val): (u32, String, String)| {
                this.with_mut(|g| {
                    if let Some(mut p) = g.get_province_mut(RegionId(id)) {
                        p.attrs.insert(key, val);
                        true
                    } else {
                        false
                    }
                })
            },
        );
        // -- getProvinceAttr --
        /// Reads a string attribute from a province.
        /// @param | id | integer | Province id.
        /// @param | key | string | Attribute key.
        /// @return | string | Attribute string, or nil when the province or key is missing.
        methods.add_method("getProvinceAttr", |_, this, (id, key): (u32, String)| {
            this.with(|g| {
                g.get_province(RegionId(id))
                    .and_then(|p| p.attrs.get(&key).cloned())
            })
        });
        // -- setRegionAttr --
        /// Sets a string attribute on a semantic region.
        /// @param | id | integer | Region id.
        /// @param | key | string | Attribute key.
        /// @param | val | string | Attribute value.
        /// @return | boolean | True when the region exists.
        methods.add_method_mut(
            "setRegionAttr",
            |_, this, (id, key, val): (u32, String, String)| {
                this.with_mut(|g| {
                    if let Some(mut region) = g.get_region_mut(RegionId(id)) {
                        region.attrs.insert(key, val);
                        true
                    } else {
                        false
                    }
                })
            },
        );
        // -- getRegionAttr --
        /// Reads a string attribute from a semantic region.
        /// @param | id | integer | Region id.
        /// @param | key | string | Attribute key.
        /// @return | string | Attribute string, or nil when the region or key is missing.
        methods.add_method("getRegionAttr", |_, this, (id, key): (u32, String)| {
            this.with(|g| {
                g.get_region(RegionId(id))
                    .and_then(|region| region.attrs.get(&key).cloned())
            })
        });
        // -- setTerrainPatchAttr --
        /// Sets a string attribute on a terrain patch.
        /// @param | id | integer | Terrain patch id.
        /// @param | key | string | Attribute key.
        /// @param | val | string | Attribute value.
        /// @return | boolean | True when the terrain patch exists.
        methods.add_method_mut(
            "setTerrainPatchAttr",
            |_, this, (id, key, val): (u32, String, String)| {
                this.with_mut(|g| {
                    if let Some(mut patch) = g.get_terrain_patch_mut(RegionId(id)) {
                        patch.attrs.insert(key, val);
                        true
                    } else {
                        false
                    }
                })
            },
        );
        // -- getTerrainPatchAttr --
        /// Reads a string attribute from a terrain patch.
        /// @param | id | integer | Terrain patch id.
        /// @param | key | string | Attribute key.
        /// @return | string | Attribute string, or nil when the patch or key is missing.
        methods.add_method(
            "getTerrainPatchAttr",
            |_, this, (id, key): (u32, String)| {
                this.with(|g| {
                    g.get_terrain_patch(RegionId(id))
                        .and_then(|patch| patch.attrs.get(&key).cloned())
                })
            },
        );
        // -- setRegionColor --
        /// Sets the RGBA color used to render a semantic region overlay.
        /// @param | id | integer | Region id.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number | Alpha channel.
        /// @return | boolean | True when the semantic region exists.
        methods.add_method_mut(
            "setRegionColor",
            |_, this, (id, r, g, b, a): (u32, f32, f32, f32, f32)| {
                let color = [
                    unit_interval_f32(r, "region color red")?,
                    unit_interval_f32(g, "region color green")?,
                    unit_interval_f32(b, "region color blue")?,
                    unit_interval_f32(a, "region color alpha")?,
                ];
                this.with_mut(|g| {
                    if let Some(mut region) = g.get_region_mut(RegionId(id)) {
                        region.overlay_color = Some(color);
                        true
                    } else {
                        false
                    }
                })
            },
        );
        // -- setRegionVisible --
        /// Shows or hides a semantic region overlay and its picking participation.
        /// @param | id | integer | Region id.
        /// @param | visible | boolean | New visibility flag.
        /// @return | boolean | True when the semantic region exists.
        methods.add_method_mut("setRegionVisible", |_, this, (id, visible): (u32, bool)| {
            this.with_mut(|g| {
                if let Some(mut region) = g.get_region_mut(RegionId(id)) {
                    region.visible = visible;
                    true
                } else {
                    false
                }
            })
        });
        // -- setProvinceTexture --
        /// Assigns a live texture handle and UV rectangle to a province.
        /// @param | id | integer | Province id.
        /// @param | tex_raw | integer or LImage | Live texture identifier or image userdata.
        /// @param | u0 | number | Left UV coordinate.
        /// @param | v0 | number | Top UV coordinate.
        /// @param | u1 | number | Right UV coordinate.
        /// @param | v1 | number | Bottom UV coordinate.
        /// @return | boolean | True when the province exists.
        methods.add_method_mut(
            "setProvinceTexture",
            |_, this, (id, tex_value, u0, v0, u1, v1): (u32, LuaValue, f32, f32, f32, f32)| {
                let texture_key = {
                    let state = this.state.borrow();
                    parse_texture_key_value_checked(
                        &tex_value,
                        "lurek.globe.setProvinceTexture",
                        &state,
                    )?
                    .map(|(key, _)| key)
                }
                .ok_or_else(|| {
                    LuaError::RuntimeError(
                        "lurek.globe.setProvinceTexture: texture must not be nil".to_string(),
                    )
                })?;
                let rect = [
                    unit_interval_f32(u0, "province texture u0")?,
                    unit_interval_f32(v0, "province texture v0")?,
                    unit_interval_f32(u1, "province texture u1")?,
                    unit_interval_f32(v1, "province texture v1")?,
                ];
                if rect[2] < rect[0] || rect[3] < rect[1] {
                    return Err(LuaError::RuntimeError(
                        "lurek.globe.setProvinceTexture: expected u1 >= u0 and v1 >= v0"
                            .to_string(),
                    ));
                }
                this.with_mut(|g| {
                    if let Some(mut p) = g.get_province_mut(RegionId(id)) {
                        p.texture_key = Some(texture_key);
                        p.texture_uv_rect = Some(rect);
                        true
                    } else {
                        false
                    }
                })
            },
        );
        // -- clearProvinceTexture --
        /// Removes texture metadata from a province.
        /// @param | id | integer | Province id.
        /// @return | boolean | True when the province exists.
        methods.add_method_mut("clearProvinceTexture", |_, this, id: u32| {
            this.with_mut(|g| {
                if let Some(mut p) = g.get_province_mut(RegionId(id)) {
                    p.texture_key = None;
                    p.texture_uv_rect = None;
                    true
                } else {
                    false
                }
            })
        });
        // -- setTerrainPatchTexture --
        /// Assigns a live texture handle and UV rectangle to a terrain patch.
        /// @param | id | integer | Terrain patch id.
        /// @param | tex_raw | integer or LImage | Live texture identifier or image userdata.
        /// @param | u0 | number | Left UV coordinate.
        /// @param | v0 | number | Top UV coordinate.
        /// @param | u1 | number | Right UV coordinate.
        /// @param | v1 | number | Bottom UV coordinate.
        /// @return | boolean | True when the terrain patch exists.
        methods.add_method_mut(
            "setTerrainPatchTexture",
            |_, this, (id, tex_value, u0, v0, u1, v1): (u32, LuaValue, f32, f32, f32, f32)| {
                let texture_key = {
                    let state = this.state.borrow();
                    parse_texture_key_value_checked(
                        &tex_value,
                        "lurek.globe.setTerrainPatchTexture",
                        &state,
                    )?
                    .map(|(key, _)| key)
                }
                .ok_or_else(|| {
                    LuaError::RuntimeError(
                        "lurek.globe.setTerrainPatchTexture: texture must not be nil".to_string(),
                    )
                })?;
                let rect = [
                    unit_interval_f32(u0, "terrain texture u0")?,
                    unit_interval_f32(v0, "terrain texture v0")?,
                    unit_interval_f32(u1, "terrain texture u1")?,
                    unit_interval_f32(v1, "terrain texture v1")?,
                ];
                if rect[2] < rect[0] || rect[3] < rect[1] {
                    return Err(LuaError::RuntimeError(
                        "lurek.globe.setTerrainPatchTexture: expected u1 >= u0 and v1 >= v0"
                            .to_string(),
                    ));
                }
                this.with_mut(|g| {
                    if let Some(mut patch) = g.get_terrain_patch_mut(RegionId(id)) {
                        patch.texture_key = Some(texture_key);
                        patch.texture_uv_rect = Some(rect);
                        true
                    } else {
                        false
                    }
                })
            },
        );
        // -- clearTerrainPatchTexture --
        /// Removes texture metadata from a terrain patch.
        /// @param | id | integer | Terrain patch id.
        /// @return | boolean | True when the terrain patch exists.
        methods.add_method_mut("clearTerrainPatchTexture", |_, this, id: u32| {
            this.with_mut(|g| {
                if let Some(mut patch) = g.get_terrain_patch_mut(RegionId(id)) {
                    patch.texture_key = None;
                    patch.texture_uv_rect = None;
                    true
                } else {
                    false
                }
            })
        });
        // -- validateTerrainCoverage --
        /// Samples terrain coverage over equirectangular latitude-longitude space.
        /// @param | opts | table? | Optional `lat_step` and `lon_step` sample spacing in degrees.
        /// @return | table | Coverage report with `ok`, `samples`, `covered_samples`, and `gaps`.
        methods.add_method(
            "validateTerrainCoverage",
            |lua, this, opts: Option<LuaTable>| {
                let lat_step = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("lat_step").ok().flatten())
                    .unwrap_or(30.0);
                let lon_step = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("lon_step").ok().flatten())
                    .unwrap_or(30.0);
                let lat_step = finite_f32(lat_step, "terrain coverage lat_step")?.clamp(1.0, 180.0);
                let lon_step = finite_f32(lon_step, "terrain coverage lon_step")?.clamp(1.0, 360.0);
                let report = this.with(|g| g.validate_terrain_coverage(lat_step, lon_step))?;
                let out = lua.create_table()?;
                out.set("ok", report.ok)?;
                out.set("samples", report.samples)?;
                out.set("covered_samples", report.covered_samples)?;
                let gaps = lua.create_table()?;
                for (index, (lat, lon)) in report.gaps.iter().enumerate() {
                    let gap = lua.create_table()?;
                    gap.set("lat", *lat)?;
                    gap.set("lon", *lon)?;
                    gaps.set(index + 1, gap)?;
                }
                out.set("gaps", gaps)?;
                Ok(out)
            },
        );
        // -- setProvinceSector --
        /// Assigns a province to a named sector.
        /// @param | id | integer | Province id.
        /// @param | sector | string | Sector name.
        /// @return | boolean | True when the province sector was set.
        methods.add_method_mut(
            "setProvinceSector",
            |_, this, (id, sector): (u32, String)| {
                this.with_mut(|g| g.set_province_sector(RegionId(id), sector))
            },
        );
        // -- getProvinceSector --
        /// Returns the sector name assigned to a province.
        /// @param | id | integer | Province id.
        /// @return | string | Sector string, or nil when absent.
        methods.add_method("getProvinceSector", |_, this, id: u32| {
            this.with(|g| g.province_sector(RegionId(id)).map(|s| s.to_string()))
        });
        // -- getSectorProvinces --
        /// Returns province ids assigned to a sector.
        /// @param | sector | string | Sector name.
        /// @return | integer[] | Array table of province ids.
        methods.add_method("getSectorProvinces", |lua, this, sector: String| {
            let ids = this.with(|g| g.sector_provinces(&sector))?;
            let t = lua.create_table()?;
            for (i, id) in ids.iter().enumerate() {
                t.set(i + 1, id.0)?;
            }
            Ok(t)
        });
        // -- setHeatLayer --
        /// Creates or replaces a heat layer that maps province attributes into colors.
        /// @param | name | string | Heat layer name.
        /// @param | attr_key | string | Province attribute key read as a numeric value.
        /// @param | min | number | Attribute value mapped to cold color.
        /// @param | max | number | Attribute value mapped to hot color.
        /// @param | alpha | number | Layer alpha in the 0.0 through 1.0 range.
        methods.add_method_mut(
            "setHeatLayer",
            |_, this, (name, attr_key, min, max, alpha): (String, String, f32, f32, f32)| {
                let min = finite_f32(min, "setHeatLayer min")?;
                let max = finite_f32(max, "setHeatLayer max")?;
                let alpha = unit_interval_f32(alpha, "setHeatLayer alpha")?;
                this.with_mut(|g| {
                    g.set_heat_layer(HeatLayer {
                        name,
                        attr_key,
                        min_value: min,
                        max_value: max,
                        cold_color: [0.1, 0.2, 0.9, 1.0],
                        hot_color: [0.9, 0.2, 0.1, 1.0],
                        alpha,
                        visible: true,
                        z_order: 0,
                    })
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("lurek.globe.setHeatLayer: {err}"))
                    })
                })?
            },
        );
        // -- removeHeatLayer --
        /// Removes a heat layer by name. This method is available to Lua scripts.
        /// @param | name | string | Heat layer name.
        /// @return | boolean | True when a layer was removed.
        methods.add_method_mut("removeHeatLayer", |_, this, name: String| {
            this.with_mut(|g| g.remove_heat_layer(&name))
        });
        // -- pan --
        /// Pans the globe camera by latitude and longitude deltas.
        /// @param | dlat | number | Latitude delta in degrees.
        /// @param | dlon | number | Longitude delta in degrees.
        methods.add_method_mut("pan", |_, this, (dlat, dlon): (f32, f32)| {
            let dlat = finite_f32(dlat, "pan latitude delta")?;
            let dlon = finite_f32(dlon, "pan longitude delta")?;
            this.with_mut(|g| g.camera.pan(dlat, dlon))
        });
        // -- zoom --
        /// Multiplies the globe camera zoom by a factor.
        /// @param | factor | number | Zoom factor.
        methods.add_method_mut("zoom", |_, this, factor: f32| {
            let factor = finite_f32(factor, "zoom factor")?;
            if factor <= 0.0 {
                return Err(LuaError::RuntimeError(
                    "lurek.globe.zoom: factor must be > 0".to_string(),
                ));
            }
            this.with_mut(|g| g.camera.zoom_by(factor))
        });
        // -- setCamera --
        /// Sets camera latitude, longitude, and zoom.
        /// @param | lat | number | Camera latitude in degrees.
        /// @param | lon | number | Camera longitude in degrees.
        /// @param | z | number | Camera zoom, must be at least 0.1.
        methods.add_method_mut("setCamera", |_, this, (lat, lon, z): (f32, f32, f32)| {
            let (lat, lon) = validate_lat_lon(lat, lon, "setCamera")?;
            let z = finite_f32(z, "setCamera zoom")?;
            if z < 0.1 {
                return Err(LuaError::RuntimeError(
                    "lurek.globe.setCamera: zoom must be >= 0.1".to_string(),
                ));
            }
            this.with_mut(|g| {
                g.camera.lat_deg = lat;
                g.camera.lon_deg = lon;
                g.camera.zoom = z;
                g.camera.clamp();
            })
        });
        // -- getCamera --
        /// Returns camera latitude, longitude, and zoom.
        /// @return | number | Camera latitude in degrees.
        /// @return | number | Camera longitude in degrees.
        /// @return | number | Camera zoom.
        methods.add_method("getCamera", |_, this, ()| {
            this.with(|g| (g.camera.lat_deg, g.camera.lon_deg, g.camera.zoom))
        });
        // -- screenDeltaToPan --
        /// Converts a screen-space drag delta into latitude and longitude pan deltas.
        /// @param | dx | number | Screen-space x delta in pixels.
        /// @param | dy | number | Screen-space y delta in pixels.
        /// @return | number | Latitude delta in degrees.
        /// @return | number | Longitude delta in degrees.
        methods.add_method("screenDeltaToPan", |_, this, (dx, dy): (f32, f32)| {
            this.with(|g| screen_delta_to_pan(dx, dy, &g.spec, &g.camera))
        });
        // -- applyMouseDrag --
        /// Applies a pointer drag to the globe camera using screen-space deltas.
        /// @param | start_x | number | Drag start x.
        /// @param | start_y | number | Drag start y.
        /// @param | end_x | number | Drag end x.
        /// @param | end_y | number | Drag end y.
        methods.add_method_mut(
            "applyMouseDrag",
            |_, this, (start_x, start_y, end_x, end_y): (f32, f32, f32, f32)| {
                this.with_mut(|g| g.apply_mouse_drag(start_x, start_y, end_x, end_y))
            },
        );
        // -- applyWheelZoom --
        /// Applies a wheel delta using an exponential zoom scale.
        /// @param | delta | number | Wheel delta where positive zooms in and negative zooms out.
        methods.add_method_mut("applyWheelZoom", |_, this, delta: f32| {
            let delta = finite_f32(delta, "applyWheelZoom delta")?;
            this.with_mut(|g| {
                let factor = 1.1_f32.powf(delta);
                g.camera.zoom_by(factor);
            })
        });
        // -- getLod --
        /// Returns the camera-derived level-of-detail tier name.
        /// @return | string | One of `far`, `mid`, or `near`.
        methods.add_method("getLod", |_, this, ()| {
            this.with(|g| {
                match g.camera.lod() {
                    LodTier::Far => "far",
                    LodTier::Mid => "mid",
                    LodTier::Near => "near",
                }
                .to_string()
            })
        });
        // -- pick --
        /// Picks a province at screen coordinates.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @return | integer | Province id, or nil when nothing is hit.
        methods.add_method("pick", |_, this, (sx, sy): (f32, f32)| {
            this.with(|g| g.pick_screen(sx, sy).map(|r| r.region_id.0))
        });
        // -- screenToLatLon --
        /// Converts a visible screen position into globe latitude, longitude, and unit-sphere coordinates.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @return | number | Latitude in degrees, or nil when the point is off the globe.
        /// @return | number | Longitude in degrees, or nil when the point is off the globe.
        /// @return | number | Unit-sphere x coordinate, or nil when the point is off the globe.
        /// @return | number | Unit-sphere y coordinate, or nil when the point is off the globe.
        /// @return | number | Unit-sphere z coordinate, or nil when the point is off the globe.
        methods.add_method("screenToLatLon", |_, this, (sx, sy): (f32, f32)| {
            this.with(|g| match g.screen_to_surface(sx, sy) {
                Some(surface) => (
                    Some(surface.lat_deg as f64),
                    Some(surface.lon_deg as f64),
                    Some(surface.world_pos.x as f64),
                    Some(surface.world_pos.y as f64),
                    Some(surface.world_pos.z as f64),
                ),
                None => (None, None, None, None, None),
            })
        });
        // -- screenToOrbitLatLon --
        /// Converts a visible screen position into latitude and longitude on one named visible pickable orbit shell.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @param | orbit | string | Orbit shell name.
        /// @return | number | Latitude in degrees, or nil when the point is off that shell.
        /// @return | number | Longitude in degrees, or nil when the point is off that shell.
        methods.add_method(
            "screenToOrbitLatLon",
            |_, this, (sx, sy, orbit): (f32, f32, String)| {
                this.with(|g| match g.screen_to_orbit(sx, sy, &orbit) {
                    Some(hit) => (Some(hit.lat_deg as f64), Some(hit.lon_deg as f64)),
                    None => (None, None),
                })
            },
        );
        // -- screenToShells --
        /// Resolves shell hits for every visible pickable orbit at one screen-space position.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @return | table | Table keyed by orbit name with shell-hit snapshots.
        methods.add_method("screenToShells", |lua, this, (sx, sy): (f32, f32)| {
            let shells = this.with(|g| g.screen_to_shells(sx, sy))?;
            let table = lua.create_table()?;
            for (name, hit) in shells {
                table.set(name.clone(), shell_hit_table(lua, &name, &hit)?)?;
            }
            Ok(table)
        });
        // -- pickRaycast --
        /// Samples along the screen-space line from the globe center to the target and returns the first hit province.
        /// @param | sx | number | Target screen x coordinate.
        /// @param | sy | number | Target screen y coordinate.
        /// @param | steps | integer? | Number of screen-space samples along the line, defaulting to 24.
        /// @return | integer | Province id, or nil when no sample hits.
        methods.add_method(
            "pickRaycast",
            |_, this, (sx, sy, steps): (f32, f32, Option<u32>)| {
                let n = steps.unwrap_or(24).max(1);
                this.with(|g| {
                    let cx = g.camera.screen_cx;
                    let cy = g.camera.screen_cy;
                    let dx = sx - cx;
                    let dy = sy - cy;
                    for i in 1..=n {
                        let t = i as f32 / n as f32;
                        let px = cx + dx * t;
                        let py = cy + dy * t;
                        if let Some(hit) = g.pick_screen(px, py) {
                            return Some(hit.region_id.0);
                        }
                    }
                    None
                })
            },
        );
        // -- pickLatLon --
        /// Picks at screen coordinates and returns the hit surface latitude and longitude.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @return | number | Latitude in degrees, or nil when nothing is hit.
        /// @return | number | Longitude in degrees, or nil when nothing is hit.
        methods.add_method("pickLatLon", |_lua, this, (sx, sy): (f32, f32)| {
            this.with(|g| match g.screen_to_surface(sx, sy) {
                Some(surface) => (Some(surface.lat_deg as f64), Some(surface.lon_deg as f64)),
                None => (None, None),
            })
        });
        // -- pickRegions --
        /// Returns semantic region ids under a screen-space hit.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @return | integer[] | Array table of semantic region ids.
        methods.add_method("pickRegions", |lua, this, (sx, sy): (f32, f32)| {
            let ids = this.with(|g| g.pick_regions_at_screen(sx, sy))?;
            let t = lua.create_table()?;
            for (index, id) in ids.iter().enumerate() {
                t.set(index + 1, id.0)?;
            }
            Ok(t)
        });
        // -- regionsAtLatLon --
        /// Returns semantic region ids containing a latitude-longitude point.
        /// @param | lat | number | Latitude in degrees.
        /// @param | lon | number | Longitude in degrees.
        /// @return | integer[] | Array table of semantic region ids.
        methods.add_method("regionsAtLatLon", |lua, this, (lat, lon): (f32, f32)| {
            let (lat, lon) = validate_lat_lon(lat, lon, "regionsAtLatLon")?;
            let ids = this.with(|g| g.regions_at_lat_lon(lat, lon))?;
            let t = lua.create_table()?;
            for (index, id) in ids.iter().enumerate() {
                t.set(index + 1, id.0)?;
            }
            Ok(t)
        });
        // -- pickMarker --
        /// Returns the nearest visible marker at a screen position within an optional pixel radius.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @param | radius | number? | Maximum marker distance in pixels, default 12.
        /// @return | integer | Marker id, or nil when no visible marker is within range.
        methods.add_method(
            "pickMarker",
            |_, this, (sx, sy, radius): (f32, f32, Option<f32>)| {
                this.with(|g| g.pick_marker_screen(sx, sy, radius.unwrap_or(12.0)))
            },
        );
        // -- pickObject --
        /// Resolves the highest-priority shell-aware hit at one screen position.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @param | opts | table? | Optional pick settings with `marker_radius`, `include_surface`, `include_regions`, `include_markers`, `include_orbits`, and `order`.
        /// @return | table | Hit snapshot table, or nil when nothing matched.
        methods.add_method(
            "pickObject",
            |lua, this, (sx, sy, opts_tbl): (f32, f32, Option<LuaTable>)| {
                let opts = parse_object_pick_options(opts_tbl, "pickObject")?;
                let hit = this.with(|g| g.pick_object(sx, sy, opts))?;
                match hit {
                    Some(hit) => Ok(Some(object_hit_table(lua, &hit)?)),
                    None => Ok(None),
                }
            },
        );
        // -- pickAllObjects --
        /// Resolves all shell-aware hits at one screen position using the supplied ordering policy.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @param | opts | table? | Optional pick settings with `marker_radius`, `include_surface`, `include_regions`, `include_markers`, `include_orbits`, and `order`.
        /// @return | table[] | Array table of hit snapshots.
        methods.add_method(
            "pickAllObjects",
            |lua, this, (sx, sy, opts_tbl): (f32, f32, Option<LuaTable>)| {
                let opts = parse_object_pick_options(opts_tbl, "pickAllObjects")?;
                let hits = this.with(|g| g.pick_all_objects(sx, sy, opts))?;
                let table = lua.create_table()?;
                for (index, hit) in hits.iter().enumerate() {
                    table.set(index + 1, object_hit_table(lua, hit)?)?;
                }
                Ok(table)
            },
        );
        // -- pickSurface --
        /// Resolves a screen-space hit into globe surface data plus province, marker, and semantic-region hits.
        /// @param | sx | number | Screen x coordinate.
        /// @param | sy | number | Screen y coordinate.
        /// @param | marker_radius | number? | Maximum marker distance in pixels when testing marker hits.
        /// @return | table | Pick result table, or nil when the screen point is off the globe.
        methods.add_method(
            "pickSurface",
            |lua, this, (sx, sy, marker_radius): (f32, f32, Option<f32>)| {
                this.with(|g| {
                    let Some(surface) = g.screen_to_surface(sx, sy) else {
                        return Ok(None::<LuaTable>);
                    };
                    let province_id = g.pick_screen(sx, sy).map(|hit| hit.region_id.0);
                    let marker_id = g.pick_marker_screen(sx, sy, marker_radius.unwrap_or(12.0));
                    let region_ids = g.regions_at_lat_lon(surface.lat_deg, surface.lon_deg);
                    let out = lua.create_table()?;
                    out.set("lat", surface.lat_deg)?;
                    out.set("lon", surface.lon_deg)?;
                    out.set("x", surface.world_pos.x)?;
                    out.set("y", surface.world_pos.y)?;
                    out.set("z", surface.world_pos.z)?;
                    out.set("province_id", province_id)?;
                    out.set("marker_id", marker_id)?;
                    let regions = lua.create_table()?;
                    for (index, id) in region_ids.iter().enumerate() {
                        regions.set(index + 1, id.0)?;
                    }
                    out.set("region_ids", regions)?;
                    Ok(Some(out))
                })?
            },
        );
        // -- setActiveViewer --
        /// Sets the active fog-of-war viewer name or clears it.
        /// @param | viewer | string? | Viewer name.
        methods.add_method_mut("setActiveViewer", |_, this, viewer: Option<String>| {
            this.with_mut(|g| g.active_viewer = viewer)
        });
        // -- setFogState --
        /// Sets fog-of-war state for one viewer and province.
        /// @param | viewer | string | Viewer name.
        /// @param | id | integer | Province id.
        /// @param | state | string | `visible`, `explored`, or any other value for hidden.
        methods.add_method_mut(
            "setFogState",
            |_, this, (viewer, id, state): (String, u32, String)| {
                let st = match state.as_str() {
                    "visible" => FogState::Visible,
                    "explored" => FogState::Explored,
                    _ => FogState::Hidden,
                };
                this.with_mut(|g| g.fog.set_state(&viewer, RegionId(id), st))
            },
        );
        // -- getFogState --
        /// Returns fog-of-war state for one viewer and province.
        /// @param | viewer | string | Viewer name.
        /// @param | id | integer | Province id.
        /// @return | string | `visible`, `explored`, or `hidden`.
        methods.add_method("getFogState", |_, this, (viewer, id): (String, u32)| {
            this.with(|g| {
                match g.fog.state(&viewer, RegionId(id)) {
                    FogState::Visible => "visible",
                    FogState::Explored => "explored",
                    FogState::Hidden => "hidden",
                }
                .to_string()
            })
        });
        // -- encodeFogBase64 --
        /// Serializes one viewer's fog state to a base64 string.
        /// @param | viewer | string | Viewer name.
        /// @return | string | Base64-encoded fog state, or an empty string on encode failure.
        methods.add_method("encodeFogBase64", |_, this, viewer: String| {
            this.with(|g| g.fog.to_base64(&viewer).unwrap_or_default())
        });
        // -- decodeFogBase64 --
        /// Loads one viewer's fog state from a base64 string.
        /// @param | viewer | string | Viewer name.
        /// @param | payload | string | Base64-encoded fog state.
        /// @return | boolean | True when the payload was decoded.
        methods.add_method_mut(
            "decodeFogBase64",
            |_, this, (viewer, payload): (String, String)| {
                this.with_mut(|g| g.fog.load_base64(&viewer, &payload).is_ok())
            },
        );
        // -- revealProvince --
        /// Reveals a province for one fog-of-war viewer.
        /// @param | viewer | string | Viewer name.
        /// @param | id | integer | Province id.
        methods.add_method_mut("revealProvince", |_, this, (viewer, id): (String, u32)| {
            this.with_mut(|g| g.fog.reveal(&viewer, RegionId(id)))
        });
        // -- hideProvince --
        /// Hides a province for one fog-of-war viewer.
        /// @param | viewer | string | Viewer name.
        /// @param | id | integer | Province id.
        methods.add_method_mut("hideProvince", |_, this, (viewer, id): (String, u32)| {
            this.with_mut(|g| g.fog.hide(&viewer, RegionId(id)))
        });
        // -- isVisible --
        /// Returns whether a province is visible for one fog-of-war viewer.
        /// @param | viewer | string | Viewer name.
        /// @param | id | integer | Province id.
        /// @return | boolean | True when the province is visible.
        methods.add_method("isVisible", |_, this, (viewer, id): (String, u32)| {
            this.with(|g| g.fog.is_visible(&viewer, RegionId(id)))
        });
        // -- revealAll --
        /// Reveals every province for one fog-of-war viewer.
        /// @param | viewer | string | Viewer name.
        methods.add_method_mut("revealAll", |_, this, viewer: String| {
            this.with_mut(|g| {
                let ids: Vec<u32> = g.graph.iter().map(|p| p.id.0).collect();
                for id in ids {
                    g.fog.reveal(&viewer, RegionId(id));
                }
            })
        });
        // -- addOrbit --
        /// Adds or replaces one named orbit shell above the globe surface.
        /// @param | orbit_tbl | table | Orbit table with `name`, optional `altitude_px`, optional `kind`, and optional render or pick flags.
        /// @return | boolean | True when the orbit definition was accepted.
        methods.add_method_mut("addOrbit", |_, this, orbit_tbl: LuaTable| {
            let orbit = parse_orbit_table(orbit_tbl, "addOrbit")?;
            this.with_mut(|g| {
                g.add_orbit(orbit)
                    .map(|_| true)
                    .map_err(|err| LuaError::RuntimeError(format!("lurek.globe.addOrbit: {err}")))
            })?
        });
        // -- removeOrbit --
        /// Removes one named orbit shell and moves any markers on it back to `surface`.
        /// @param | name | string | Orbit shell name.
        /// @return | boolean | True when the orbit existed and was removed.
        methods.add_method_mut("removeOrbit", |_, this, name: String| {
            this.with_mut(|g| g.remove_orbit(&name))
        });
        // -- setOrbitVisible --
        /// Shows or hides one orbit shell and its markers.
        /// @param | name | string | Orbit shell name.
        /// @param | visible | boolean | New visibility flag.
        /// @return | boolean | True when the orbit exists.
        methods.add_method_mut(
            "setOrbitVisible",
            |_, this, (name, visible): (String, bool)| {
                this.with_mut(|g| g.orbits.set_visible(&name, visible))
            },
        );
        // -- setOrbitAttr --
        /// Sets one string attribute on an orbit shell.
        /// @param | name | string | Orbit shell name.
        /// @param | key | string | Attribute key.
        /// @param | value | string | Attribute value.
        /// @return | boolean | True when the orbit exists.
        methods.add_method_mut(
            "setOrbitAttr",
            |_, this, (name, key, value): (String, String, String)| {
                this.with_mut(|g| g.orbits.set_attr(&name, key, value))
            },
        );
        // -- getOrbitAttr --
        /// Reads one string attribute from an orbit shell.
        /// @param | name | string | Orbit shell name.
        /// @param | key | string | Attribute key.
        /// @return | string | Attribute value, or nil when missing.
        methods.add_method("getOrbitAttr", |_, this, (name, key): (String, String)| {
            this.with(|g| {
                g.orbits
                    .get_attr(&name, &key)
                    .map(|value| value.to_string())
            })
        });
        // -- getOrbitNames --
        /// Returns orbit shell names sorted by z-order and altitude.
        /// @return | string[] | Array table of orbit names.
        methods.add_method("getOrbitNames", |lua, this, ()| {
            let names = this.with(|g| g.orbits.names_sorted())?;
            let table = lua.create_table()?;
            for (index, name) in names.iter().enumerate() {
                table.set(index + 1, name.clone())?;
            }
            Ok(table)
        });
        // -- getOrbit --
        /// Returns a snapshot table for one orbit shell.
        /// @param | name | string | Orbit shell name.
        /// @return | table | Orbit snapshot table, or nil when missing.
        methods.add_method("getOrbit", |lua, this, name: String| {
            let orbit = this.with(|g| g.orbits.get(&name).cloned())?;
            match orbit {
                Some(orbit) => Ok(Some(orbit_snapshot_table(lua, &orbit, this.state.clone())?)),
                None => Ok(None),
            }
        });
        // -- addMarker --
        /// Adds a marker at latitude and longitude with an optional label.
        /// @param | mtype | string | Marker type name.
        /// @param | lat | number | Latitude in degrees.
        /// @param | lon | number | Longitude in degrees.
        /// @param | label | string? | Marker label.
        /// @return | integer | New marker id.
        methods.add_method_mut(
            "addMarker",
            |_, this, (mtype, lat, lon, label): (String, f32, f32, Option<String>)| {
                let (lat, lon) = validate_lat_lon(lat, lon, "marker")?;
                this.with_mut(|g| {
                    g.markers
                        .add(mtype, lat, lon, label, MarkerStyle::default())
                })
            },
        );
        // -- addMarkerEx --
        /// Adds a marker on one named orbit shell using a table-based configuration.
        /// @param | marker_tbl | table | Marker table with `type`, `lat`, `lon`, optional `orbit`, optional `altitude_px`, optional style fields, and optional `attrs`.
        /// @return | integer | New marker id.
        methods.add_method_mut("addMarkerEx", |_, this, marker_tbl: LuaTable| {
            let marker = {
                let state = this.state.borrow();
                parse_marker_ex_table(marker_tbl, &state)?
            };
            let ParsedMarkerInput {
                marker_type,
                lat_deg,
                lon_deg,
                orbit,
                altitude_px,
                label,
                visible,
                style,
                attrs,
            } = marker;
            this.with_mut(|g| {
                let id = g
                    .add_marker_placed(MarkerPlacement::orbit(
                        marker_type,
                        lat_deg,
                        lon_deg,
                        orbit,
                        altitude_px,
                        label,
                        style,
                    ))
                    .map_err(|err| {
                        LuaError::RuntimeError(format!("lurek.globe.addMarkerEx: {err}"))
                    })?;
                if let Some(stored) = g.markers.get_mut(id) {
                    stored.visible = visible;
                    stored.attrs = attrs;
                }
                Ok(id)
            })?
        });
        // -- removeMarker --
        /// Removes a marker by id. This method is available to Lua scripts.
        /// @param | id | integer | Marker id.
        /// @return | boolean | True when a marker was removed.
        methods.add_method_mut("removeMarker", |_, this, id: u32| {
            this.with_mut(|g| g.markers.remove(id).is_some())
        });
        // -- moveMarker --
        /// Moves a marker to latitude and longitude coordinates.
        /// @param | id | integer | Marker id.
        /// @param | lat | number | Latitude in degrees.
        /// @param | lon | number | Longitude in degrees.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut("moveMarker", |_, this, (id, lat, lon): (u32, f32, f32)| {
            let (lat, lon) = validate_lat_lon(lat, lon, "marker")?;
            this.with_mut(|g| g.markers.move_to(id, lat, lon))
        });
        // -- setMarkerVisible --
        /// Shows or hides a marker. This method is available to Lua scripts.
        /// @param | id | integer | Marker id.
        /// @param | vis | boolean | New visibility flag.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut("setMarkerVisible", |_, this, (id, vis): (u32, bool)| {
            this.with_mut(|g| g.markers.set_visible(id, vis))
        });
        // -- setMarkerPulse --
        /// Sets marker pulse frequency and amplitude.
        /// @param | id | integer | Marker id.
        /// @param | hz | number | Pulse frequency in hertz, must be >= 0.
        /// @param | amp | number | Pulse amplitude in the 0.0 through 1.0 range.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut(
            "setMarkerPulse",
            |_, this, (id, hz, amp): (u32, f32, f32)| {
                let hz = finite_f32(hz, "setMarkerPulse hz")?;
                if hz < 0.0 {
                    return Err(LuaError::RuntimeError(
                        "lurek.globe.setMarkerPulse: hz must be >= 0".to_string(),
                    ));
                }
                let amp = unit_interval_f32(amp, "setMarkerPulse amp")?;
                this.with_mut(|g| {
                    if let Some(m) = g.markers.get_mut(id) {
                        m.style.pulse_hz = hz;
                        m.style.pulse_amplitude = amp;
                        true
                    } else {
                        false
                    }
                })
            },
        );
        // -- setMarkerRotation --
        /// Sets marker rotation speed. This method is available to Lua scripts.
        /// @param | id | integer | Marker id.
        /// @param | dps | number | Rotation speed in degrees per second.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut("setMarkerRotation", |_, this, (id, dps): (u32, f32)| {
            let dps = finite_f32(dps, "setMarkerRotation dps")?;
            this.with_mut(|g| {
                if let Some(m) = g.markers.get_mut(id) {
                    m.style.rotation_deg_per_sec = dps;
                    true
                } else {
                    false
                }
            })
        });
        // -- setMarkerAttr --
        /// Sets a string attribute on a marker.
        /// @param | id | integer | Marker id.
        /// @param | key | string | Attribute key.
        /// @param | val | string | Attribute value.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut(
            "setMarkerAttr",
            |_, this, (id, key, val): (u32, String, String)| {
                this.with_mut(|g| g.markers.set_attr(id, key, val))
            },
        );
        // -- getMarkerAttr --
        /// Reads a string attribute from a marker.
        /// @param | id | integer | Marker id.
        /// @param | key | string | Attribute key.
        /// @return | string | Attribute string, or nil when missing.
        methods.add_method("getMarkerAttr", |_, this, (id, key): (u32, String)| {
            this.with(|g| g.markers.get_attr(id, &key).map(|s| s.to_owned()))
        });
        // -- setMarkerOrbit --
        /// Reassigns a marker to one named orbit shell.
        /// @param | id | integer | Marker id.
        /// @param | orbit | string | Orbit shell name.
        /// @return | boolean | True when the marker exists and the orbit accepts markers.
        methods.add_method_mut("setMarkerOrbit", |_, this, (id, orbit): (u32, String)| {
            this.with_mut(|g| g.set_marker_orbit(id, &orbit))
        });
        // -- setMarkerAltitude --
        /// Sets or clears a marker-specific shell offset above its assigned orbit.
        /// @param | id | integer | Marker id.
        /// @param | altitude_px | number? | Non-negative offset in render units, or nil to clear.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut(
            "setMarkerAltitude",
            |_, this, (id, altitude_px): (u32, Option<f32>)| {
                let altitude_px = match altitude_px {
                    Some(value) => {
                        let value = finite_f32(value, "setMarkerAltitude altitude_px")?;
                        if value < 0.0 {
                            return Err(LuaError::RuntimeError(
                                "lurek.globe.setMarkerAltitude: altitude_px must be >= 0"
                                    .to_string(),
                            ));
                        }
                        Some(value)
                    }
                    None => None,
                };
                this.with_mut(|g| g.set_marker_altitude(id, altitude_px))
            },
        );
        // -- getMarkerOrbit --
        /// Returns the named orbit shell assigned to one marker.
        /// @param | id | integer | Marker id.
        /// @return | string | Orbit shell name, or nil when the marker is missing.
        methods.add_method("getMarkerOrbit", |_, this, id: u32| {
            this.with(|g| g.markers.get(id).map(|marker| marker.orbit.clone()))
        });
        // -- getMarkerInfo --
        /// Returns a snapshot table describing one marker.
        /// @param | id | integer | Marker id.
        /// @return | table | Marker snapshot table, or nil when missing.
        methods.add_method("getMarkerInfo", |lua, this, id: u32| {
            let marker = this.with(|g| g.markers.get(id).cloned())?;
            match marker {
                Some(marker) => Ok(Some(marker_info_table(lua, &marker)?)),
                None => Ok(None),
            }
        });
        // -- setMarkerColor --
        /// Sets the RGBA tint color used to render a marker.
        /// @param | id | integer | Marker id.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut(
            "setMarkerColor",
            |_, this, (id, r, g, b, a): (u32, f32, f32, f32, Option<f32>)| {
                let color = [
                    unit_interval_f32(r, "marker color red")?,
                    unit_interval_f32(g, "marker color green")?,
                    unit_interval_f32(b, "marker color blue")?,
                    unit_interval_f32(a.unwrap_or(1.0), "marker color alpha")?,
                ];
                this.with_mut(|g| {
                    if let Some(marker) = g.markers.get_mut(id) {
                        marker.style.color = color;
                        true
                    } else {
                        false
                    }
                })
            },
        );
        // -- setMarkerSize --
        /// Sets the marker size in screen units for rendering.
        /// @param | id | integer | Marker id.
        /// @param | size | number | Marker size, must be at least 1.0.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut("setMarkerSize", |_, this, (id, size): (u32, f32)| {
            let size = finite_f32(size, "marker size")?;
            if size < 1.0 {
                return Err(LuaError::RuntimeError(
                    "lurek.globe.setMarkerSize: size must be >= 1".to_string(),
                ));
            }
            this.with_mut(|g| {
                if let Some(marker) = g.markers.get_mut(id) {
                    marker.style.size = size;
                    true
                } else {
                    false
                }
            })
        });
        // -- setMarkerShape --
        /// Sets the vector fallback shape used by a marker.
        /// @param | id | integer | Marker id.
        /// @param | shape | string | One of `circle`, `square`, `diamond`, `triangle`, or `cross`.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut("setMarkerShape", |_, this, (id, shape): (u32, String)| {
            let shape = parse_marker_shape(shape.as_str())?;
            this.with_mut(|g| {
                if let Some(marker) = g.markers.get_mut(id) {
                    marker.style.shape = shape;
                    true
                } else {
                    false
                }
            })
        });
        // -- setMarkerIconTexture --
        /// Assigns or clears a live texture handle for a marker icon.
        /// @param | id | integer | Marker id.
        /// @param | tex_raw | integer, LImage, or nil | Live texture handle, image userdata, or nil to clear the icon.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut(
            "setMarkerIconTexture",
            |_, this, (id, tex_value): (u32, LuaValue)| {
                let texture_key = {
                    let state = this.state.borrow();
                    parse_texture_key_value_checked(
                        &tex_value,
                        "lurek.globe.setMarkerIconTexture",
                        &state,
                    )?
                    .map(|(key, _)| key)
                };
                this.with_mut(|g| {
                    if let Some(marker) = g.markers.get_mut(id) {
                        marker.style.icon_texture = None;
                        marker.style.icon_texture_key = texture_key;
                        true
                    } else {
                        false
                    }
                })
            },
        );
        // -- distanceBetweenMarkers --
        /// Computes great-circle distance between two markers on the unit sphere.
        /// @param | a | integer | First marker id.
        /// @param | b | integer | Second marker id.
        /// @return | number | Great-circle distance, or nil when either marker is missing.
        methods.add_method("distanceBetweenMarkers", |_, this, (a, b): (u32, u32)| {
            this.with(|g| g.marker_distance(a, b))
        });
        // -- addLabel --
        /// Adds a text label at latitude and longitude.
        /// @param | ltype | string | Label type name.
        /// @param | lat | number | Latitude in degrees.
        /// @param | lon | number | Longitude in degrees.
        /// @param | text | string | Label text.
        /// @return | integer | New label id.
        methods.add_method_mut(
            "addLabel",
            |_, this, (ltype, lat, lon, text): (String, f32, f32, String)| {
                let (lat, lon) = validate_lat_lon(lat, lon, "label")?;
                this.with_mut(|g| {
                    g.labels
                        .add(ltype, lat, lon, text, LabelStyle::default(), 0)
                        .map_err(|err| {
                            LuaError::RuntimeError(format!("lurek.globe.addLabel: {err}"))
                        })
                })?
            },
        );
        // -- setLabelText --
        /// Changes text for an existing label.
        /// @param | id | integer | Label id.
        /// @param | text | string | New label text.
        /// @return | boolean | True when the label exists.
        methods.add_method_mut("setLabelText", |_, this, (id, text): (u32, String)| {
            this.with_mut(|g| g.labels.set_text(id, text))
        });
        // -- setLabelVisible --
        /// Shows or hides a label. This method is available to Lua scripts.
        /// @param | id | integer | Label id.
        /// @param | vis | boolean | New visibility flag.
        /// @return | boolean | True when the label exists.
        methods.add_method_mut("setLabelVisible", |_, this, (id, vis): (u32, bool)| {
            this.with_mut(|g| g.labels.set_visible(id, vis))
        });
        // -- removeLabel --
        /// Removes a label by id. This method is available to Lua scripts.
        /// @param | id | integer | Label id.
        /// @return | boolean | True when a label was removed.
        methods.add_method_mut("removeLabel", |_, this, id: u32| {
            this.with_mut(|g| g.labels.remove(id).is_some())
        });
        // -- addLayer --
        /// Adds a render layer with optional z-order.
        /// @param | name | string | Layer name.
        /// @param | z_order | integer? | Layer z-order, defaulting to zero.
        methods.add_method_mut(
            "addLayer",
            |_, this, (name, z_order): (String, Option<i32>)| {
                this.with_mut(|g| {
                    g.layers
                        .add(Layer {
                            name,
                            visible: true,
                            alpha: 1.0,
                            z_order: z_order.unwrap_or(0),
                            kind: String::new(),
                            region_colors: HashMap::new(),
                        })
                        .map_err(|err| {
                            LuaError::RuntimeError(format!("lurek.globe.addLayer: {err}"))
                        })
                })?
            },
        );
        // -- removeLayer --
        /// Removes a render layer by name. This method is available to Lua scripts.
        /// @param | name | string | Layer name.
        /// @return | boolean | True when a layer was removed.
        methods.add_method_mut("removeLayer", |_, this, name: String| {
            this.with_mut(|g| g.layers.remove(&name).is_some())
        });
        // -- setLayerColor --
        /// Sets a province color override inside a render layer.
        /// @param | layer | string | Layer name.
        /// @param | id | integer | Province id.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number | Alpha channel.
        /// @return | boolean | True when the layer exists.
        methods.add_method_mut(
            "setLayerColor",
            |_, this, (layer, id, r, g, b, a): (String, u32, f32, f32, f32, f32)| {
                this.with_mut(|globe| {
                    globe
                        .layers
                        .set_province_color(&layer, RegionId(id), [r, g, b, a])
                        .map_err(|err| {
                            LuaError::RuntimeError(format!("lurek.globe.setLayerColor: {err}"))
                        })
                })?
            },
        );
        // -- setLayerVisible --
        /// Shows or hides a render layer. This method is available to Lua scripts.
        /// @param | name | string | Layer name.
        /// @param | vis | boolean | New visibility flag.
        /// @return | boolean | True when the layer exists.
        methods.add_method_mut("setLayerVisible", |_, this, (name, vis): (String, bool)| {
            this.with_mut(|g| g.layers.set_visible(&name, vis))
        });
        // -- setLayerAlpha --
        /// Sets render layer alpha. This method is available to Lua scripts.
        /// @param | name | string | Layer name.
        /// @param | alpha | number | Layer alpha in the 0.0 through 1.0 range.
        /// @return | boolean | True when the layer exists.
        methods.add_method_mut("setLayerAlpha", |_, this, (name, alpha): (String, f32)| {
            this.with_mut(|g| {
                g.layers.set_alpha(&name, alpha).map_err(|err| {
                    LuaError::RuntimeError(format!("lurek.globe.setLayerAlpha: {err}"))
                })
            })?
        });
        // -- setTimeOfDay --
        /// Sets globe time of day modulo 24 hours.
        /// @param | t | number | Time of day in hours.
        methods.add_method_mut("setTimeOfDay", |_, this, t: f32| {
            let t = normalize_time_of_day(t)?;
            this.with_mut(|g| g.spec.time_of_day = t)
        });
        // -- getTimeOfDay --
        /// Returns globe time of day. This method is available to Lua scripts.
        /// @return | number | Time of day in hours.
        methods.add_method("getTimeOfDay", |_, this, ()| {
            this.with(|g| g.spec.time_of_day)
        });
        // -- setRotation --
        /// Sets globe rotation angle. This method is available to Lua scripts.
        /// @param | deg | number | Rotation in degrees.
        methods.add_method_mut("setRotation", |_, this, deg: f32| {
            let deg = finite_f32(deg, "rotation_deg")?.rem_euclid(360.0);
            this.with_mut(|g| g.spec.rotation_deg = deg)
        });
        // -- setAutoRotationSpeed --
        /// Sets automatic globe rotation speed.
        /// @param | dps | number | Rotation speed in degrees per second.
        methods.add_method_mut("setAutoRotationSpeed", |_, this, dps: f32| {
            let dps = finite_f32(dps, "auto_rotation_deg_per_sec")?;
            this.with_mut(|g| g.spec.auto_rotation_deg_per_sec = dps)
        });
        // -- update --
        /// Advances globe simulation timers and animated state.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| this.with_mut(|g| g.update(dt)));
        // -- setBorders --
        /// Enables or disables province border rendering.
        /// @param | show | boolean | New border visibility flag.
        methods.add_method_mut("setBorders", |_, this, show: bool| {
            this.with_mut(|g| g.spec.render_borders = show)
        });
        // -- setOrbitShader --
        /// Binds a `mapviz` shader to one orbit shell and restores the globe shader outside that shell scope.
        /// @param | orbit | string | Orbit shell name.
        /// @param | shader | LShader | Shader created with `lurek.render.newShader(code, { target = "mapviz" })`.
        /// @return | boolean | True when the orbit exists.
        methods.add_method_mut(
            "setOrbitShader",
            |_, this, (orbit, shader_ud): (String, LuaAnyUserData)| {
                let key = shader_key_from_userdata(&shader_ud)?;
                let st = this.state.borrow();
                ensure_shader_target(&st, key, ShaderTarget::MapViz, "LGlobe:setOrbitShader")?;
                drop(st);
                this.with_mut(|g| {
                    if let Some(orbit_def) = g.orbits.get_mut(&orbit) {
                        orbit_def.shader = Some(key);
                        true
                    } else {
                        false
                    }
                })
            },
        );
        // -- clearOrbitShader --
        /// Clears one orbit shell shader without affecting the globe-wide shader.
        /// @param | orbit | string | Orbit shell name.
        /// @return | boolean | True when the orbit exists.
        methods.add_method_mut("clearOrbitShader", |_, this, orbit: String| {
            this.with_mut(|g| {
                if let Some(orbit_def) = g.orbits.get_mut(&orbit) {
                    orbit_def.shader = None;
                    true
                } else {
                    false
                }
            })
        });
        // -- setShader --
        /// Binds a mapviz-target shader to this globe's generated render commands. Pass nil to clear.
        /// @param | shader | LShader? | Shader created with `lurek.render.newShader(code, { target = "mapviz" })`, or nil to clear.
        methods.add_method_mut("setShader", |_, this, shader: Option<LuaAnyUserData>| {
            let key = match shader {
                Some(shader_ud) => {
                    let key = shader_key_from_userdata(&shader_ud)?;
                    let st = this.state.borrow();
                    ensure_shader_target(&st, key, ShaderTarget::MapViz, "LGlobe:setShader")?;
                    Some(key)
                }
                None => None,
            };
            this.with_mut(|g| g.shader = key)
        });
        // -- getShader --
        /// Returns the mapviz-target shader bound to this globe, if any.
        /// @return | LShader | Bound shader handle, or nil.
        methods.add_method("getShader", |_, this, ()| {
            let key = this.with(|g| g.shader)?;
            Ok(key.map(|key| LuaShader {
                key,
                state: this.state.clone(),
            }))
        });
        // -- draw --
        /// Emits the globe's render commands into the shared renderer command queue.
        /// @param | opts | table? | Optional draw settings with `screen_cx` and `screen_cy`.
        methods.add_method_mut("draw", |_, this, opts: Option<LuaTable>| {
            let (screen_cx, screen_cy, default_font) = {
                let st = this.state.borrow();
                let cx = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("screen_cx").ok().flatten())
                    .unwrap_or(st.window_width as f32 * 0.5);
                let cy = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<f32>>("screen_cy").ok().flatten())
                    .unwrap_or(st.window_height as f32 * 0.5);
                (cx, cy, st.active_font.or(st.default_font))
            };
            let cmds = this.with_mut(|g| {
                g.camera.screen_cx = screen_cx;
                g.camera.screen_cy = screen_cy;
                g.emit_frame(default_font)
            })?;
            let mut st = this.state.borrow_mut();
            let previous_shader = st.active_shader;
            let changed_shader = cmds
                .iter()
                .any(|command| matches!(command, crate::render::RenderCommand::SetShader(_)));
            st.render_commands.extend(cmds);
            if changed_shader {
                if let Some(shader_key) = previous_shader {
                    st.render_commands
                        .push(crate::render::RenderCommand::SetShader(Some(shader_key)));
                }
            }
            Ok(())
        });
        // -- findPath --
        /// Finds a default-cost province path between two province ids.
        /// @param | from_id | integer | Start province id.
        /// @param | to_id | integer | Target province id.
        /// @return | integer[] | Province ids, or nil when no path exists.
        methods.add_method("findPath", |lua, this, (from_id, to_id): (u32, u32)| {
            let path_opt = this.with(|g| {
                g.graph
                    .find_path_default(RegionId(from_id), RegionId(to_id))
            })?;
            match path_opt {
                None => Ok(None),
                Some(path) => {
                    let t = lua.create_table()?;
                    for (i, id) in path.provinces.iter().enumerate() {
                        t.set(i + 1, *id)?;
                    }
                    Ok(Some(t))
                }
            }
        });
        // -- findPathWithCosts --
        /// Finds a province path using caller-supplied traversal costs, blocked ids, and edge-tag surcharges.
        /// @param | from_id | integer | Start province id.
        /// @param | to_id | integer | Target province id.
        /// @param | opts | table? | Optional cost table with `default_cost`, `province_costs`, `tag_costs`, and `blocked_ids`.
        /// @return | table | Result table with `ids` and `total_cost`, or nil when no path exists.
        methods.add_method(
            "findPathWithCosts",
            |lua, this, (from_id, to_id, opts): (u32, u32, Option<LuaTable>)| {
                let cost_fn = parse_cost_fn(opts, "findPathWithCosts")?;
                let path_opt = this.with(|g| {
                    g.graph
                        .find_path(RegionId(from_id), RegionId(to_id), &cost_fn)
                        .ok()
                })?;
                let Some(path) = path_opt else {
                    return Ok(None);
                };
                let ids = lua.create_table()?;
                for (index, id) in path.provinces.iter().enumerate() {
                    ids.set(index + 1, *id)?;
                }
                let out = lua.create_table()?;
                out.set("ids", ids)?;
                out.set("total_cost", path.total_cost)?;
                Ok(Some(out))
            },
        );
        // -- reachable --
        /// Returns provinces reachable from a start province within a cost budget.
        /// @param | start_id | integer | Start province id.
        /// @param | max_cost | number | Maximum traversal cost.
        /// @return | table | Map table from province id (integer key) to accumulated traversal cost (number).
        methods.add_method(
            "reachable",
            |lua, this, (start_id, max_cost): (u32, f64)| {
                let max_cost = finite_non_negative_f64(max_cost, "reachable max_cost")?;
                let reached =
                    this.with(|g| g.graph.reachable_default(RegionId(start_id), max_cost))?;
                let t = lua.create_table()?;
                for (id, cost) in reached {
                    t.set(id.0, cost)?;
                }
                Ok(t)
            },
        );
        // -- reachableWithCosts --
        /// Returns provinces reachable under caller-supplied traversal costs, blocked ids, and edge-tag surcharges.
        /// @param | start_id | integer | Start province id.
        /// @param | max_cost | number | Maximum traversal cost.
        /// @param | opts | table? | Optional cost table with `default_cost`, `province_costs`, `tag_costs`, and `blocked_ids`.
        /// @return | table | Map table from province id (integer key) to accumulated traversal cost (number).
        methods.add_method(
            "reachableWithCosts",
            |lua, this, (start_id, max_cost, opts): (u32, f64, Option<LuaTable>)| {
                let max_cost = finite_non_negative_f64(max_cost, "reachableWithCosts max_cost")?;
                let cost_fn = parse_cost_fn(opts, "reachableWithCosts")?;
                let reached =
                    this.with(|g| g.graph.reachable(RegionId(start_id), max_cost, &cost_fn))?;
                let t = lua.create_table()?;
                for (id, cost) in reached {
                    t.set(id.0, cost)?;
                }
                Ok(t)
            },
        );
        // -- cacheReachability --
        /// Caches default-cost reachability for a named faction.
        /// @param | faction | string | Faction cache key.
        /// @param | start_id | integer | Start province id.
        /// @param | max_cost | number | Maximum traversal cost.
        methods.add_method_mut(
            "cacheReachability",
            |_, this, (faction, start_id, max_cost): (String, u32, f64)| {
                let max_cost = finite_non_negative_f64(max_cost, "cacheReachability max_cost")?;
                this.with_mut(|g| {
                    g.cache_reachability_default(faction, RegionId(start_id), max_cost)
                })
            },
        );
        // -- getCachedReachability --
        /// Returns cached reachability costs for a faction.
        /// @param | faction | string | Faction cache key.
        /// @return | table | Map table from province id (integer key) to accumulated traversal cost (number), empty when missing.
        methods.add_method("getCachedReachability", |lua, this, faction: String| {
            let t = lua.create_table()?;
            let map = this.with(|g| g.cached_reachability(&faction).cloned())?;
            if let Some(map) = map {
                for (id, cost) in map {
                    t.set(id, cost)?;
                }
            }
            Ok(t)
        });
        // -- exportProvinceMeshOBJ --
        /// Exports province geometry as Wavefront OBJ text, preserving multipart boundaries and hole loops.
        /// @return | string | OBJ text for the current provinces, including grouped boundary loops and any available fill geometry.
        methods.add_method("exportProvinceMeshOBJ", |_, this, ()| {
            this.with(export_regions_to_obj)
        });
        // -- addArc --
        /// Adds a visible route arc between two latitude and longitude points.
        /// @param | lat1 | number | Start latitude in degrees.
        /// @param | lon1 | number | Start longitude in degrees.
        /// @param | lat2 | number | End latitude in degrees.
        /// @param | lon2 | number | End longitude in degrees.
        /// @param | steps | integer? | Point count for the arc, defaulting to 24.
        /// @return | integer | New arc id.
        methods.add_method_mut(
            "addArc",
            |_, this, (lat1, lon1, lat2, lon2, steps): (f32, f32, f32, f32, Option<u32>)| {
                let (lat1, lon1) = validate_lat_lon(lat1, lon1, "addArc from")?;
                let (lat2, lon2) = validate_lat_lon(lat2, lon2, "addArc to")?;
                let steps = steps.unwrap_or(24);
                if steps < 2 {
                    return Err(LuaError::RuntimeError(
                        "lurek.globe.addArc: steps must be >= 2".to_string(),
                    ));
                }
                this.with_mut(|g| {
                    let arc = crate::globe::types::Arc {
                        id: g.arc_next_id,
                        arc_type: "route".to_string(),
                        screen_points: Vec::new(),
                        color: [1.0, 1.0, 0.0, 1.0],
                        width: 1.5,
                        from: (lat1, lon1),
                        to: (lat2, lon2),
                        steps,
                        visible: true,
                    };
                    g.add_arc(arc)
                        .map_err(|err| LuaError::RuntimeError(format!("lurek.globe.addArc: {err}")))
                })?
            },
        );
        // -- removeArc --
        /// Removes an arc by id. This method is available to Lua scripts.
        /// @param | id | integer | Arc id.
        /// @return | boolean | True when an arc was removed.
        methods.add_method_mut("removeArc", |_, this, id: u32| {
            this.with_mut(|g| g.remove_arc(id))
        });
        // -- getName --
        /// Returns the registry name of this globe.
        /// @return | string | Globe registry name.
        methods.add_method("getName", |_, this, ()| Ok(this.name.clone()));
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            Ok(format!("Globe(\"{}\")", this.name))
        });
        // -- type --
        /// Returns the Lua-visible type name for this globe handle.
        /// @return | string | The string `LGlobe`.
        methods.add_method("type", |_, _, ()| Ok("LGlobe"));
        // -- typeOf --
        /// Returns whether this globe handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LGlobe` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGlobe" || name == "LObject")
        });
    }
}
#[derive(Clone)]
/// Lua-side handle for creating and locating named globes in one registry.
pub struct LuaGlobeRegistry {
    /// Shared registry containing named globe instances.
    reg: Arc<Mutex<GlobeRegistry>>,
    /// Shared runtime state propagated into globe handles.
    state: Rc<RefCell<SharedState>>,
}
/// Provides Lua methods for managing globe registry entries.
impl LuaUserData for LuaGlobeRegistry {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- new --
        /// Creates a named globe with optional specification fields.
        /// @param | name | string | Globe registry name.
        /// @param | spec_tbl | table? | Globe specification table.
        /// @return | LGlobe | New globe handle.
        methods.add_method_mut(
            "new",
            |_, this, (name, spec_tbl): (String, Option<LuaTable>)| {
                let config = parse_globe_config(spec_tbl, "new")?;
                {
                    let mut guard = this.reg.lock().map_err(|e| {
                        mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                    })?;
                    let globe = guard.create(name.clone(), config.spec);
                    apply_orbits_to_globe(globe, &config.orbits, "new")?;
                }
                Ok(LuaGlobe {
                    reg: this.reg.clone(),
                    name,
                    state: this.state.clone(),
                })
            },
        );
        // -- get --
        /// Returns a globe handle by registry name.
        /// @param | name | string | Globe registry name.
        /// @return | LGlobe | Globe handle, or nil when no globe exists with that name.
        methods.add_method("get", |_, this, name: String| {
            let exists = {
                let guard = this.reg.lock().map_err(|e| {
                    mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                })?;
                guard.get(&name).is_some()
            };
            if exists {
                Ok(Some(LuaGlobe {
                    reg: this.reg.clone(),
                    name,
                    state: this.state.clone(),
                }))
            } else {
                Ok(None)
            }
        });
        // -- remove --
        /// Removes a globe from the registry by name.
        /// @param | name | string | Globe registry name.
        /// @return | boolean | True when a globe was removed.
        methods.add_method_mut("remove", |_, this, name: String| {
            let mut guard = this
                .reg
                .lock()
                .map_err(|e| mlua::Error::RuntimeError(format!("registry lock poisoned: {e}")))?;
            Ok(guard.remove(&name).is_some())
        });
        // -- names --
        /// Returns all globe names currently stored in this registry.
        /// @return | string[] | Globe names.
        methods.add_method("names", |lua, this, ()| {
            let guard = this
                .reg
                .lock()
                .map_err(|e| mlua::Error::RuntimeError(format!("registry lock poisoned: {e}")))?;
            let names = guard.names();
            let t = lua.create_table()?;
            for (i, n) in names.iter().enumerate() {
                t.set(i + 1, n.clone())?;
            }
            Ok(t)
        });
        // -- type --
        /// Returns the Lua-visible type name for this globe registry handle.
        /// @return | string | The string `LGlobeRegistry`.
        methods.add_method("type", |_, _, ()| Ok("LGlobeRegistry"));
        // -- typeOf --
        /// Returns whether this registry handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LGlobeRegistry` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGlobeRegistry" || name == "LObject")
        });
    }
}
/// Parses optional Lua table fields into a globe specification.
fn parse_globe_spec(tbl: Option<LuaTable>, label: &str) -> LuaResult<GlobeSpec> {
    let mut spec = GlobeSpec::default();
    if let Some(t) = tbl {
        if let Ok(v) = t.get::<_, f32>("radius") {
            let v = finite_f32(v, &format!("{label} radius"))?;
            if v < 1.0 {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.globe.{label}: radius must be >= 1"
                )));
            }
            spec.radius = v;
        }
        if let Ok(v) = t.get::<_, f32>("axial_tilt_deg") {
            spec.axial_tilt_deg = finite_f32(v, &format!("{label} axial_tilt_deg"))?;
        }
        if let Ok(v) = t.get::<_, f32>("rotation_deg") {
            spec.rotation_deg = finite_f32(v, &format!("{label} rotation_deg"))?.rem_euclid(360.0);
        }
        if let Ok(v) = t.get::<_, f32>("time_of_day") {
            spec.time_of_day = finite_f32(v, &format!("{label} time_of_day"))?.rem_euclid(24.0);
        }
        if let Ok(Some(v)) = t.get::<_, Option<bool>>("render_borders") {
            spec.render_borders = v;
        }
        if let Ok(v) = t.get::<_, f32>("border_width") {
            let v = finite_f32(v, &format!("{label} border_width"))?;
            if v < 0.0 {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.globe.{label}: border_width must be >= 0"
                )));
            }
            spec.border_width = v;
        }
        if let Ok(v) = t.get::<_, f32>("ambient") {
            spec.ambient = unit_interval_f32(v, &format!("{label} ambient"))?;
        }
        if let Ok(v) = t.get::<_, f32>("auto_rotation_deg_per_sec") {
            spec.auto_rotation_deg_per_sec =
                finite_f32(v, &format!("{label} auto_rotation_deg_per_sec"))?;
        }
        if let Ok(v) = t.get::<_, f32>("atmosphere_width") {
            let v = finite_f32(v, &format!("{label} atmosphere_width"))?;
            if v < 0.0 {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.globe.{label}: atmosphere_width must be >= 0"
                )));
            }
            spec.atmosphere_width = v;
        }
        if let Ok(v) = t.get::<_, u8>("border_smoothing_passes") {
            spec.border_smoothing_passes = v;
        }
        if let Ok(Some(v)) = t.get::<_, Option<bool>>("show_atmosphere") {
            spec.show_atmosphere = v;
        }
        if let Ok(border_color) = t.get::<_, LuaTable>("border_color") {
            spec.border_color = parse_color_table(
                Some(border_color),
                spec.border_color,
                &format!("{label} border_color"),
            )?;
        }
        if let Ok(atmosphere_color) = t.get::<_, LuaTable>("atmosphere_color") {
            spec.atmosphere_color = parse_color_table(
                Some(atmosphere_color),
                spec.atmosphere_color,
                &format!("{label} atmosphere_color"),
            )?;
        }
        if let Ok(background_color) = t.get::<_, LuaTable>("background_color") {
            spec.background_color = parse_color_table(
                Some(background_color),
                spec.background_color,
                &format!("{label} background_color"),
            )?;
        }
    }
    validate_globe_spec(&spec)
        .map_err(|error| LuaError::RuntimeError(format!("lurek.globe.{label}: {error}")))?;
    Ok(spec)
}
/// Registers `lurek.globe` constructors, geometry helpers, and constants.
pub fn register(lua: &Lua, luna: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let registry = Arc::new(Mutex::new(GlobeRegistry::new()));
    let registry_state = state.clone();
    // -- newRegistry --
    /// Creates an empty globe registry handle independent from the module registry.
    /// @return | LGlobeRegistry | New globe registry handle.
    tbl.set(
        "newRegistry",
        lua.create_function(move |lua, ()| {
            lua.create_userdata(LuaGlobeRegistry {
                reg: Arc::new(Mutex::new(GlobeRegistry::new())),
                state: registry_state.clone(),
            })
        })?,
    )?;

    let new_reg = registry.clone();
    let new_state = state.clone();
    // -- new --
    /// Creates a named globe with optional specification fields in the module registry.
    /// @param | name | string | Globe registry name.
    /// @param | spec_tbl | table? | Globe specification table. Optional `load_options = { sandbox_root?, max_toml_bytes?, max_png_bytes?, max_png_pixels? }` applies to file-backed loaders.
    /// @return | LGlobe | New globe handle.
    tbl.set(
        "new",
        lua.create_function(move |_, (name, spec_tbl): (String, Option<LuaTable>)| {
            let config = parse_globe_config(spec_tbl, "new")?;
            {
                let mut guard = new_reg.lock().map_err(|e| {
                    mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                })?;
                let globe = guard.create(name.clone(), config.spec);
                apply_orbits_to_globe(globe, &config.orbits, "new")?;
            }
            Ok(LuaGlobe {
                reg: new_reg.clone(),
                name,
                state: new_state.clone(),
            })
        })?,
    )?;

    let get_reg = registry.clone();
    let get_state = state.clone();
    // -- get --
    /// Returns a globe from the module registry by name.
    /// @param | name | string | Globe registry name.
    /// @return | LGlobe | Globe handle, or nil when no globe exists with that name.
    tbl.set(
        "get",
        lua.create_function(move |_, name: String| {
            let exists = {
                let guard = get_reg.lock().map_err(|e| {
                    mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                })?;
                guard.get(&name).is_some()
            };
            if exists {
                Ok(Some(LuaGlobe {
                    reg: get_reg.clone(),
                    name,
                    state: get_state.clone(),
                }))
            } else {
                Ok(None)
            }
        })?,
    )?;

    let remove_reg = registry.clone();
    // -- remove --
    /// Removes a globe from the registry by name.
    /// @param | name | string | Globe registry name.
    /// @return | boolean | True when a globe was removed.
    tbl.set(
        "remove",
        lua.create_function(move |_, name: String| {
            let mut guard = remove_reg
                .lock()
                .map_err(|e| mlua::Error::RuntimeError(format!("registry lock poisoned: {e}")))?;
            Ok(guard.remove(&name).is_some())
        })?,
    )?;
    let load_toml_file_reg = registry.clone();
    let load_toml_file_state = state.clone();
    // -- loadFromTOMLFile --
    /// Creates a globe and populates provinces from a TOML file path.
    /// @param | name | string | Globe registry name.
    /// @param | path | string | TOML file path to load. Provinces may use either `vertices` or multipart `parts = [{ outer = ..., holes = ... }]`.
    /// @param | spec_tbl | table? | Globe specification table.
    /// @return | LGlobe | New populated globe handle.
    tbl.set(
        "loadFromTOMLFile",
        lua.create_function(
            move |_, (name, path, spec_tbl): (String, String, Option<LuaTable>)| {
                let config = parse_globe_config(spec_tbl, "loadFromTOMLFile")?;
                let provinces = loader::load_from_toml_file_safe(&path, &config.load_options)
                    .map_err(mlua::Error::RuntimeError)?;
                {
                    let mut guard = load_toml_file_reg.lock().map_err(|e| {
                        mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                    })?;
                    let globe = guard.create(name.clone(), config.spec);
                    apply_orbits_to_globe(globe, &config.orbits, "loadFromTOMLFile")?;
                    for p in provinces {
                        globe.add_province(p).map_err(|e| {
                            mlua::Error::RuntimeError(format!("lurek.globe.loadFromTOMLFile: {e}"))
                        })?;
                    }
                }
                Ok(LuaGlobe {
                    reg: load_toml_file_reg.clone(),
                    name,
                    state: load_toml_file_state.clone(),
                })
            },
        )?,
    )?;

    let load_toml_reg = registry.clone();
    let load_toml_state = state.clone();
    // -- loadFromTOML --
    /// Creates a globe and populates provinces from TOML source text.
    /// @param | name | string | Globe registry name.
    /// @param | toml_src | string | TOML province document source supporting either `vertices` or multipart `parts = [{ outer = ..., holes = ... }]`.
    /// @param | spec_tbl | table? | Globe specification table. Optional `load_options = { sandbox_root?, max_toml_bytes?, max_png_bytes?, max_png_pixels? }` applies to file-backed loaders.
    /// @return | LGlobe | New populated globe handle.
    tbl.set(
        "loadFromTOML",
        lua.create_function(
            move |_, (name, toml_src, spec_tbl): (String, String, Option<LuaTable>)| {
                let config = parse_globe_config(spec_tbl, "loadFromTOML")?;
                let provinces =
                    loader::load_from_toml_str(&toml_src).map_err(mlua::Error::RuntimeError)?;
                {
                    let mut guard = load_toml_reg.lock().map_err(|e| {
                        mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                    })?;
                    let globe = guard.create(name.clone(), config.spec);
                    apply_orbits_to_globe(globe, &config.orbits, "loadFromTOML")?;
                    for p in provinces {
                        globe.add_province(p).map_err(|e| {
                            mlua::Error::RuntimeError(format!("lurek.globe.loadFromTOML: {e}"))
                        })?;
                    }
                }
                Ok(LuaGlobe {
                    reg: load_toml_reg.clone(),
                    name,
                    state: load_toml_state.clone(),
                })
            },
        )?,
    )?;

    let load_png_reg = registry.clone();
    let load_png_state = state.clone();
    // -- loadFromPNG --
    /// Creates a globe and populates provinces from a PNG file.
    /// @param | name | string | Globe registry name.
    /// @param | png_path | string | PNG file path to load.
    /// @param | spec_tbl | table? | Globe specification table.
    /// @return | LGlobe | New populated globe handle.
    tbl.set(
        "loadFromPNG",
        lua.create_function(
            move |_, (name, png_path, spec_tbl): (String, String, Option<LuaTable>)| {
                let config = parse_globe_config(spec_tbl, "loadFromPNG")?;
                let provinces = loader::load_from_png_file_safe(&png_path, &config.load_options)
                    .map_err(mlua::Error::RuntimeError)?;
                {
                    let mut guard = load_png_reg.lock().map_err(|e| {
                        mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                    })?;
                    let globe = guard.create(name.clone(), config.spec);
                    apply_orbits_to_globe(globe, &config.orbits, "loadFromPNG")?;
                    for p in provinces {
                        globe.add_province(p).map_err(|e| {
                            mlua::Error::RuntimeError(format!("lurek.globe.loadFromPNG: {e}"))
                        })?;
                    }
                }
                Ok(LuaGlobe {
                    reg: load_png_reg.clone(),
                    name,
                    state: load_png_state.clone(),
                })
            },
        )?,
    )?;
    let generate_voronoi_reg = registry.clone();
    let generate_voronoi_state = state.clone();
    // -- generateVoronoi --
    /// Creates a globe and populates provinces from latitude-longitude seed points.
    /// @param | name | string | Globe registry name.
    /// @param | seeds_tbl | table | Array table of `{lat, lon}` seed pairs.
    /// @param | spec_tbl | table? | Globe specification table.
    /// @return | LGlobe | New generated globe handle.
    tbl.set(
        "generateVoronoi",
        lua.create_function(
            move |_, (name, seeds_tbl, spec_tbl): (String, LuaTable, Option<LuaTable>)| {
                let config = parse_globe_config(spec_tbl, "generateVoronoi")?;
                let mut seeds = Vec::new();
                for item in seeds_tbl.sequence_values::<LuaTable>() {
                    let p = item?;
                    let lat: f32 = p.get(1)?;
                    let lon: f32 = p.get(2)?;
                    seeds.push((lat, lon));
                }
                let provinces = loader::generate_voronoi_provinces(&seeds);
                {
                    let mut guard = generate_voronoi_reg.lock().map_err(|e| {
                        mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                    })?;
                    let globe = guard.create(name.clone(), config.spec);
                    apply_orbits_to_globe(globe, &config.orbits, "generateVoronoi")?;
                    for p in provinces {
                        globe.add_province(p).map_err(|e| {
                            mlua::Error::RuntimeError(format!("lurek.globe.generateVoronoi: {e}"))
                        })?;
                    }
                }
                Ok(LuaGlobe {
                    reg: generate_voronoi_reg.clone(),
                    name,
                    state: generate_voronoi_state.clone(),
                })
            },
        )?,
    )?;
    // -- greatCircleDistance --
    /// Computes great-circle distance between two latitude-longitude points.
    /// @param | la | number | Start latitude in degrees.
    /// @param | lo | number | Start longitude in degrees.
    /// @param | lb | number | End latitude in degrees.
    /// @param | lo2 | number | End longitude in degrees.
    /// @return | number | Great-circle distance on the unit sphere.
    tbl.set(
        "greatCircleDistance",
        lua.create_function(|_, (la, lo, lb, lo2): (f32, f32, f32, f32)| {
            Ok(great_circle_distance(la, lo, lb, lo2))
        })?,
    )?;
    // -- greatCirclePath --
    /// Computes sampled latitude-longitude points along a great-circle path.
    /// @param | la | number | Start latitude in degrees.
    /// @param | lo | number | Start longitude in degrees.
    /// @param | lb | number | End latitude in degrees.
    /// @param | lo2 | number | End longitude in degrees.
    /// @param | n | integer | Number of samples.
    /// @return | table | Array table of `{lat, lon}` point tables.
    /// @field | lat | number | Lat.
    /// @field | lon | number | Lon.
    tbl.set(
        "greatCirclePath",
        lua.create_function(|lua, (la, lo, lb, lo2, n): (f32, f32, f32, f32, u32)| {
            let pts = great_circle_path(la, lo, lb, lo2, n);
            let t = lua.create_table()?;
            for (i, (lat, lon)) in pts.iter().enumerate() {
                let p = lua.create_table()?;
                p.set(1, *lat)?;
                p.set(2, *lon)?;
                t.set(i + 1, p)?;
            }
            Ok(t)
        })?,
    )?;
    // -- latLonToUnit --
    /// Converts latitude and longitude to a unit-sphere 3D vector table.
    /// @param | lat | number | Latitude in degrees.
    /// @param | lon | number | Longitude in degrees.
    /// @return | table | Array table `{x, y, z}` on the unit sphere.
    /// @field | x | number | X.
    /// @field | y | number | Y.
    /// @field | z | number | Z.
    tbl.set(
        "latLonToUnit",
        lua.create_function(|lua, (lat, lon): (f32, f32)| {
            let v = lat_lon_to_unit(lat, lon);
            let t = lua.create_table()?;
            t.set(1, v.x)?;
            t.set(2, v.y)?;
            t.set(3, v.z)?;
            Ok(t)
        })?,
    )?;
    // -- raySphereIntersect --
    /// Intersects a 3D ray with a sphere and returns the nearest positive hit distance.
    /// @param | ox | number | Ray origin x.
    /// @param | oy | number | Ray origin y.
    /// @param | oz | number | Ray origin z.
    /// @param | dx | number | Ray direction x.
    /// @param | dy | number | Ray direction y.
    /// @param | dz | number | Ray direction z.
    /// @param | radius | number | Sphere radius.
    /// @return | number | Hit distance `t`, or nil when the ray misses.
    tbl.set(
        "raySphereIntersect",
        lua.create_function(
            |_, (ox, oy, oz, dx, dy, dz, radius): (f32, f32, f32, f32, f32, f32, f32)| {
                Ok(ray_sphere_intersect(
                    crate::math::Vec3::new(ox, oy, oz),
                    crate::math::Vec3::new(dx, dy, dz),
                    radius,
                ))
            },
        )?,
    )?;
    /// Maximum number of provinces that can be registered in the globe.
    tbl.set("MAX_PROVINCES", MAX_REGIONS as u32)?;
    /// Alias for MAX_PROVINCES â€” maximum number of regions that can be registered in the globe.
    tbl.set("MAX_REGIONS", MAX_REGIONS as u32)?;
    /// LOD string constant for far-distance province rendering.
    tbl.set("LOD_FAR", "far")?;
    /// LOD string constant for mid-distance province rendering.
    tbl.set("LOD_MID", "mid")?;
    /// LOD string constant for near-distance province rendering.
    tbl.set("LOD_NEAR", "near")?;
    /// Performs the 'globe' operation.
    luna.set("globe", tbl)?;
    Ok(())
}
