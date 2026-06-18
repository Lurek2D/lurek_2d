//! Registers the `lurek.raycaster` Lua API for raycast scenes, textures, level parsing, and raycaster userdata.

use super::SharedState;
use crate::color::Color;
use crate::image::ImageData;
use crate::lua_api::physics_api::LuaBody;
use crate::lua_api::render_api::LuaImage;
#[cfg(feature = "obj-loader")]
use crate::lua_api::render_api::LuaObjModel;
use crate::minimap::raycaster_overlay::extract_minimap;
use crate::minimap::{build_minimap_tile_window, compute_tile_light, reveal_cells_from_rays};
use crate::raycaster::lighting::{apply_global_light, apply_lit_shade};
use crate::raycaster::sprite_manager::SpriteManager;
#[cfg(feature = "obj-loader")]
use crate::raycaster::SceneAdapterModel;
use crate::raycaster::{
    compute_lighting, dir4_delta, distance_shade, project_column, try_move,
    DirectionalSpriteTextures, DoorDirection, DoorManager, DoorState, EntityPickResult,
    GridMoveAction, HeightMap, LevelSprite, ModelMesh, MultiLevelGrid, PickResult, PickSurface,
    PointLight, RayHit, Raycaster2D, RaycasterBuildStats, RaycasterLevel, RaycasterScene,
    SceneAdapter, SceneAdapterLight, SceneAdapterSprite, SceneBuildParams, SceneTransform,
    ScreenPickParams, WallFeature, WallFeatureKind, WorldSprite,
};
#[cfg(feature = "obj-loader")]
use crate::render::obj_loader::Vec3;
use crate::runtime::resource_keys::TextureKey;
use mlua::prelude::*;
use slotmap::Key;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;
/// Rebuilds a texture key and raw handle pair from the persisted numeric texture id.
fn texture_key_from_raw_id(raw_id: u64) -> (TextureKey, u64) {
    (TextureKey::from(slotmap::KeyData::from_ffi(raw_id)), raw_id)
}
/// Parses nil, numeric ids, or `LImage` userdata into a raycaster texture reference.
fn parse_texture_key_value(
    value: &LuaValue,
    api_name: &str,
) -> LuaResult<Option<(TextureKey, u64)>> {
    match value {
        LuaValue::Nil => Ok(None),
        LuaValue::Integer(v) => parse_texture_integer(*v, api_name),
        LuaValue::Number(v) => parse_texture_number(*v, api_name),
        LuaValue::UserData(ud) => parse_texture_userdata(ud, api_name),
        _ => Err(LuaError::RuntimeError(format!(
            "{}: texture must be an integer id, LImage userdata, or nil",
            api_name
        ))),
    }
}

fn parse_texture_integer(value: i64, api_name: &str) -> LuaResult<Option<(TextureKey, u64)>> {
    if value < 0 {
        return Err(LuaError::RuntimeError(format!(
            "{}: texture id must be >= 0",
            api_name
        )));
    }
    Ok(Some(texture_key_from_raw_id(value as u64)))
}

fn parse_texture_number(value: f64, api_name: &str) -> LuaResult<Option<(TextureKey, u64)>> {
    if !value.is_finite() || value < 0.0 || value.fract() != 0.0 {
        return Err(LuaError::RuntimeError(format!(
            "{}: texture must be an integer id, LImage userdata, or nil",
            api_name
        )));
    }
    Ok(Some(texture_key_from_raw_id(value as u64)))
}

fn parse_texture_userdata(
    userdata: &LuaAnyUserData,
    api_name: &str,
) -> LuaResult<Option<(TextureKey, u64)>> {
    let img = userdata.borrow::<LuaImage>().map_err(|_| {
        LuaError::RuntimeError(format!(
            "{}: texture userdata must be LImage from lurek.render.newImage()",
            api_name
        ))
    })?;
    let key = img.key;
    let raw = key.data().as_ffi();
    Ok(Some((key, raw)))
}

#[derive(Clone, Debug)]
enum LuaManagedTextureRef {
    Label(String),
    Handle { key: TextureKey, raw_id: u64 },
}

impl LuaManagedTextureRef {
    fn display_label(&self) -> String {
        match self {
            LuaManagedTextureRef::Label(label) => label.clone(),
            LuaManagedTextureRef::Handle { raw_id, .. } => format!("#{}", raw_id),
        }
    }

    fn scene_key(&self, api_name: &str, sprite_id: u32, field: &str) -> LuaResult<TextureKey> {
        match self {
            LuaManagedTextureRef::Handle { key, .. } => Ok(*key),
            LuaManagedTextureRef::Label(label) => Err(LuaError::RuntimeError(format!(
                "{}: sprite {} {} must be an integer texture id or LImage when building a scene (got string {:?})",
                api_name, sprite_id, field, label
            ))),
        }
    }
}

#[derive(Clone, Debug)]
struct LuaManagedDirectionalTextures {
    front: LuaManagedTextureRef,
    right: LuaManagedTextureRef,
    back: LuaManagedTextureRef,
    left: LuaManagedTextureRef,
}

impl LuaManagedDirectionalTextures {
    fn by_variant(
        &self,
        variant: crate::raycaster::sprite_manager::DirectionalSpriteVariant,
    ) -> &LuaManagedTextureRef {
        match variant {
            crate::raycaster::sprite_manager::DirectionalSpriteVariant::Front => &self.front,
            crate::raycaster::sprite_manager::DirectionalSpriteVariant::Right => &self.right,
            crate::raycaster::sprite_manager::DirectionalSpriteVariant::Back => &self.back,
            crate::raycaster::sprite_manager::DirectionalSpriteVariant::Left => &self.left,
        }
    }
}

#[derive(Clone, Debug)]
struct LuaManagedSpriteTextures {
    texture: LuaManagedTextureRef,
    directional_textures: Option<LuaManagedDirectionalTextures>,
    level_index: Option<usize>,
}

type LuaDirectionalSpriteArgs<'lua> = (
    f32,
    f32,
    LuaValue<'lua>,
    LuaValue<'lua>,
    LuaValue<'lua>,
    Option<LuaValue<'lua>>,
    Option<f32>,
    Option<f32>,
    Option<usize>,
);

fn parse_managed_texture_value(value: LuaValue, api_name: &str) -> LuaResult<LuaManagedTextureRef> {
    match value {
        LuaValue::String(value) => Ok(LuaManagedTextureRef::Label(value.to_str()?.to_owned())),
        other => {
            let (key, raw_id) = parse_texture_key_value(&other, api_name)?.ok_or_else(|| {
                LuaError::RuntimeError(format!(
                    "{}: texture cannot be nil; expected string path, integer id, or LImage",
                    api_name
                ))
            })?;
            Ok(LuaManagedTextureRef::Handle { key, raw_id })
        }
    }
}

fn table_opt_f32(table: &LuaTable, key: &str) -> LuaResult<Option<f32>> {
    table.get::<_, Option<f32>>(key)
}

fn table_opt_usize(table: &LuaTable, key: &str) -> LuaResult<Option<usize>> {
    table.get::<_, Option<usize>>(key)
}

fn parse_active_level(params_tbl: &LuaTable) -> LuaResult<usize> {
    Ok(table_opt_usize(params_tbl, "active_level")?
        .or(table_opt_usize(params_tbl, "level")?)
        .unwrap_or(0))
}

fn table_opt_clamped_f32(
    table: &LuaTable,
    key: &str,
    default: f32,
    min: f32,
    max: f32,
) -> LuaResult<f32> {
    Ok(table
        .get::<_, Option<f32>>(key)?
        .unwrap_or(default)
        .clamp(min, max))
}

fn parse_scene_build_params(params_tbl: &LuaTable, api_name: &str) -> LuaResult<SceneBuildParams> {
    // add_method
    let sun_r = table_opt_f32(params_tbl, "sun_r")?
        .or(table_opt_f32(params_tbl, "global_r")?)
        .unwrap_or(1.0)
        .clamp(0.0, 1.0);
    let sun_g = table_opt_f32(params_tbl, "sun_g")?
        .or(table_opt_f32(params_tbl, "global_g")?)
        .unwrap_or(1.0)
        .clamp(0.0, 1.0);
    let sun_b = table_opt_f32(params_tbl, "sun_b")?
        .or(table_opt_f32(params_tbl, "global_b")?)
        .unwrap_or(1.0)
        .clamp(0.0, 1.0);
    let sun_intensity = table_opt_f32(params_tbl, "sun_intensity")?
        .or(table_opt_f32(params_tbl, "global_intensity")?)
        .unwrap_or(1.0)
        .max(0.0);
    let sun_angle = table_opt_f32(params_tbl, "sun_angle")?;
    let roof_darkness = table_opt_f32(params_tbl, "roof_darkness")?
        .unwrap_or(0.8)
        .clamp(0.0, 1.0);
    let params = SceneBuildParams {
        player_x: params_tbl.get::<_, f32>("px").map_err(|e| {
            LuaError::RuntimeError(format!("{}: params.px is required ({})", api_name, e))
        })?,
        player_y: params_tbl.get::<_, f32>("py").map_err(|e| {
            LuaError::RuntimeError(format!("{}: params.py is required ({})", api_name, e))
        })?,
        player_angle: params_tbl.get::<_, f32>("angle").map_err(|e| {
            LuaError::RuntimeError(format!("{}: params.angle is required ({})", api_name, e))
        })?,
        fov: params_tbl.get::<_, f32>("fov").map_err(|e| {
            LuaError::RuntimeError(format!("{}: params.fov is required ({})", api_name, e))
        })?,
        ray_count: params_tbl.get::<_, u32>("rays").map_err(|e| {
            LuaError::RuntimeError(format!("{}: params.rays is required ({})", api_name, e))
        })?,
        max_distance: params_tbl.get::<_, f32>("max_dist").map_err(|e| {
            LuaError::RuntimeError(format!("{}: params.max_dist is required ({})", api_name, e))
        })?,
        screen_width: params_tbl.get::<_, f32>("screen_w").map_err(|e| {
            LuaError::RuntimeError(format!("{}: params.screen_w is required ({})", api_name, e))
        })?,
        screen_height: params_tbl.get::<_, f32>("screen_h").map_err(|e| {
            LuaError::RuntimeError(format!("{}: params.screen_h is required ({})", api_name, e))
        })?,
        ambient_light: table_opt_clamped_f32(params_tbl, "ambient", 0.3, 0.0, 1.0)?,
        global_light_color: Color::new(sun_r, sun_g, sun_b, 1.0),
        global_light_intensity: sun_intensity,
        sun_angle,
        roofed_ambient_factor: (1.0 - roof_darkness).clamp(0.0, 1.0),
        shade_distance: params_tbl
            .get::<_, Option<f32>>("shade_dist")?
            .unwrap_or(8.0)
            .max(0.0),
        floor_color: Color::new(
            params_tbl.get::<_, Option<f32>>("floor_r")?.unwrap_or(0.2),
            params_tbl.get::<_, Option<f32>>("floor_g")?.unwrap_or(0.2),
            params_tbl.get::<_, Option<f32>>("floor_b")?.unwrap_or(0.2),
            1.0,
        ),
        ceiling_color: Color::new(
            params_tbl
                .get::<_, Option<f32>>("ceiling_r")?
                .unwrap_or(0.1),
            params_tbl
                .get::<_, Option<f32>>("ceiling_g")?
                .unwrap_or(0.1),
            params_tbl
                .get::<_, Option<f32>>("ceiling_b")?
                .unwrap_or(0.15),
            1.0,
        ),
        camera_height: table_opt_clamped_f32(params_tbl, "camera_height", 0.5, 0.1, 0.9)?,
        horizon_offset: params_tbl
            .get::<_, Option<f32>>("horizon_offset")?
            .unwrap_or(0.0),
    };
    Ok(params)
}
/// Serializes one raycaster hit result into the Lua table layout returned by cast helpers.
fn ray_hit_to_table<'lua>(lua: &'lua Lua, hit: &RayHit) -> LuaResult<LuaTable<'lua>> {
    let t = lua.create_table()?;
    /// Performs the 'distance' operation.
    t.set("distance", hit.distance)?;
    /// Performs the 'raw_distance' operation.
    t.set("raw_distance", hit.raw_distance)?;
    /// Performs the 'cell_value' operation.
    t.set("cell_value", hit.cell_value)?;
    /// Performs the 'alpha' operation.
    t.set("alpha", hit.alpha)?;
    /// Performs the 'side' operation.
    t.set("side", hit.side)?;
    /// Performs the 'tex_u' operation.
    t.set("tex_u", hit.tex_u)?;
    /// Performs the 'hit_x' operation.
    t.set("hit_x", hit.hit_x)?;
    /// Performs the 'hit_y' operation.
    t.set("hit_y", hit.hit_y)?;
    /// The 'hit' field value exposed to Lua scripts.
    t.set("hit", hit.hit)?;
    Ok(t)
}

fn pick_result_to_table<'lua>(lua: &'lua Lua, pick: &PickResult) -> LuaResult<LuaTable<'lua>> {
    let tbl = lua.create_table()?;
    tbl.set("x", pick.grid_x)?;
    tbl.set("y", pick.grid_y)?;
    tbl.set("level", pick.level_index)?;
    tbl.set("surface", pick.surface.as_str())?;
    tbl.set("distance", pick.distance)?;
    tbl.set("hit_x", pick.hit_x)?;
    tbl.set("hit_y", pick.hit_y)?;
    tbl.set("u", pick.tex_u)?;
    tbl.set("v", pick.tex_v)?;
    if let Some(wall_height) = pick.wall_height {
        tbl.set("wall_height", wall_height)?;
    }
    /// Picked wall cell value for this screen-space hit result.
    tbl.set("cell_value", pick.cell_value)?;
    /// Ray angle in radians for this screen-space hit result.
    tbl.set("ray_angle", pick.ray_angle)?;
    if let Some(side) = pick.wall_side {
        /// Wall side name when the screen-space hit intersects a wall face.
        tbl.set("side", side)?;
    }
    if let Some(feature) = pick.wall_feature {
        let feature_tbl = wall_feature_to_table(lua, feature)?;
        if let Some(section) = pick.wall_section {
            feature_tbl.set("section", section.as_str())?;
        }
        /// Wall feature descriptor for this screen-space hit result.
        tbl.set("feature", feature_tbl)?;
    }
    Ok(tbl)
}

fn entity_pick_to_table<'lua>(
    lua: &'lua Lua,
    pick: &EntityPickResult,
) -> LuaResult<LuaTable<'lua>> {
    let tbl = lua.create_table()?;
    tbl.set("x", pick.world_x.floor().max(0.0) as usize)?;
    tbl.set("y", pick.world_y.floor().max(0.0) as usize)?;
    tbl.set("level", pick.level_index)?;
    tbl.set("surface", pick.kind.as_str())?;
    tbl.set("distance", pick.distance)?;
    tbl.set("hit_x", pick.world_x)?;
    tbl.set("hit_y", pick.world_y)?;
    tbl.set("u", pick.tex_u)?;
    tbl.set("v", pick.tex_v)?;
    if let Some(entity_id) = pick.entity_id {
        tbl.set("id", entity_id)?;
    }
    if let Some(texture_key) = pick.texture_key {
        /// Texture id for the picked entity surface when one is available.
        tbl.set("texture", texture_key.data().as_ffi())?;
    }
    Ok(tbl)
}

fn raycaster_build_stats_to_table<'lua>(
    lua: &'lua Lua,
    stats: &RaycasterBuildStats,
) -> LuaResult<LuaTable<'lua>> {
    let tbl = lua.create_table()?;
    tbl.set("lightingSamples", stats.lighting_samples)?;
    tbl.set("lightingCacheHits", stats.lighting_cache_hits)?;
    tbl.set("lightingCacheMisses", stats.lighting_cache_misses)?;
    Ok(tbl)
}

fn entity_pick_precedes_tile(entity_pick: &EntityPickResult, tile_pick: &PickResult) -> bool {
    const PICK_EPS: f32 = 1e-4;
    entity_pick.distance <= tile_pick.distance + PICK_EPS
}

fn wall_feature_to_table<'lua>(lua: &'lua Lua, feature: WallFeature) -> LuaResult<LuaTable<'lua>> {
    let tbl = lua.create_table()?;
    tbl.set("alpha", feature.alpha())?;
    match feature.kind {
        WallFeatureKind::HalfHeight { height } => {
            tbl.set("kind", "half")?;
            tbl.set("height", height)?;
        }
        WallFeatureKind::Window {
            sill_height,
            lintel_height,
        } => {
            /// Feature kind string for a window wall feature descriptor.
            tbl.set("kind", "window")?;
            /// @field | sill_height | number | Window sill height when `kind == "window"`.
            tbl.set("sill_height", sill_height)?;
            /// Window lintel height for a wall feature descriptor.
            tbl.set("lintel_height", lintel_height)?;
        }
        WallFeatureKind::Door {
            direction,
            open_amount,
        } => {
            /// Feature kind string for a door wall feature descriptor.
            tbl.set("kind", "door")?;
            let direction = match direction {
                DoorDirection::Horizontal => "horizontal",
                DoorDirection::Vertical => "vertical",
            };
            /// Door axis for a wall feature descriptor.
            tbl.set("direction", direction)?;
            /// Door open amount for a wall feature descriptor.
            tbl.set("open_amount", open_amount)?;
        }
    }
    Ok(tbl)
}

fn active_multilevel_level<'a>(
    grid: &'a MultiLevelGrid,
    api_name: &str,
) -> LuaResult<&'a RaycasterLevel> {
    grid.get_active().ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "{}: no active level is available; add at least one level first",
            api_name
        ))
    })
}

fn active_multilevel_level_mut<'a>(
    grid: &'a mut MultiLevelGrid,
    api_name: &str,
) -> LuaResult<&'a mut RaycasterLevel> {
    grid.get_active_mut().ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "{}: no active level is available; add at least one level first",
            api_name
        ))
    })
}

fn parse_point_light_color(light_tbl: &LuaTable) -> LuaResult<[f32; 3]> {
    if let Some(color_tbl) = light_tbl.get::<_, Option<LuaTable>>("color")? {
        let mut values = color_tbl
            .sequence_values::<f32>()
            .collect::<LuaResult<Vec<f32>>>()?;
        values.resize(3, 1.0);
        Ok([values[0], values[1], values[2]])
    } else {
        Ok([
            light_tbl.get::<_, Option<f32>>("r")?.unwrap_or(1.0),
            light_tbl.get::<_, Option<f32>>("g")?.unwrap_or(1.0),
            light_tbl.get::<_, Option<f32>>("b")?.unwrap_or(1.0),
        ])
    }
}

fn parse_point_light_table(light_tbl: &LuaTable, api_name: &str) -> LuaResult<PointLight> {
    Ok(PointLight {
        x: light_tbl
            .get::<_, f32>("x")
            .map_err(|_| LuaError::RuntimeError(format!("{}: lights[].x is required", api_name)))?,
        y: light_tbl
            .get::<_, f32>("y")
            .map_err(|_| LuaError::RuntimeError(format!("{}: lights[].y is required", api_name)))?,
        level_index: light_tbl.get::<_, Option<usize>>("level")?,
        radius: light_tbl
            .get::<_, Option<f32>>("radius")?
            .unwrap_or(0.0)
            .max(0.0),
        color: parse_point_light_color(light_tbl)?,
        intensity: light_tbl.get::<_, Option<f32>>("intensity")?.unwrap_or(1.0),
    })
}
/// Parses a Lua array of point light tables into raycaster point light definitions.
fn parse_point_lights(value: LuaValue, api_name: &str) -> LuaResult<Vec<PointLight>> {
    match value {
        LuaValue::Nil => Ok(Vec::new()),
        LuaValue::Table(tbl) => {
            let mut out = Vec::new();
            for pair in tbl.sequence_values::<LuaValue>() {
                match pair? {
                    LuaValue::Table(lt) => out.push(parse_point_light_table(&lt, api_name)?),
                    LuaValue::UserData(ud) => {
                        let light = ud.borrow::<LuaPointLight>().map_err(|_| {
                            LuaError::RuntimeError(format!(
                                "{}: lights[] entries must be tables or LPointLight userdata",
                                api_name
                            ))
                        })?;
                        out.push(light.inner.clone());
                    }
                    _ => {
                        return Err(LuaError::RuntimeError(format!(
                            "{}: lights[] entries must be tables or LPointLight userdata",
                            api_name
                        )));
                    }
                }
            }
            Ok(out)
        }
        _ => Err(LuaError::RuntimeError(format!(
            "{}: lights must be an array table or nil",
            api_name
        ))),
    }
}

fn parse_directional_sprite_textures(
    sprite_tbl: &LuaTable,
    api_name: &str,
) -> LuaResult<Option<DirectionalSpriteTextures>> {
    // add_method
    let Some((front, _)) = parse_texture_key_value(
        &sprite_tbl.get::<_, LuaValue>("front_texture")?,
        &format!("{}(sprites[].front_texture)", api_name),
    )?
    else {
        return Ok(None);
    };
    let (right, _) = parse_texture_key_value(
        &sprite_tbl.get::<_, LuaValue>("right_texture")?,
        &format!("{}(sprites[].right_texture)", api_name),
    )?
    .ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "{}: sprites[].right_texture cannot be nil",
            api_name
        ))
    })?;
    let (back, _) = parse_texture_key_value(
        &sprite_tbl.get::<_, LuaValue>("back_texture")?,
        &format!("{}(sprites[].back_texture)", api_name),
    )?
    .ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "{}: sprites[].back_texture cannot be nil",
            api_name
        ))
    })?;
    let left = parse_texture_key_value(
        &sprite_tbl.get::<_, LuaValue>("left_texture")?,
        &format!("{}(sprites[].left_texture)", api_name),
    )?
    .map(|(key, _)| key)
    .unwrap_or(right);
    Ok(Some(DirectionalSpriteTextures {
        front,
        right,
        back,
        left,
        facing_angle: sprite_tbl.get::<_, Option<f32>>("angle")?.unwrap_or(0.0),
    }))
}

fn parse_door_direction(api_name: &str, value: &str) -> LuaResult<DoorDirection> {
    match value {
        "horizontal" => Ok(DoorDirection::Horizontal),
        "vertical" => Ok(DoorDirection::Vertical),
        _ => Err(LuaError::RuntimeError(format!(
            "{}: direction must be \"horizontal\" or \"vertical\"",
            api_name
        ))),
    }
}

fn parse_wall_feature_descriptor(
    feature_tbl: &LuaTable,
    api_name: &str,
) -> LuaResult<(u32, u32, WallFeature)> {
    // add_method
    let x = feature_tbl.get::<_, u32>("x").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: wall_features[].x is required ({})",
            api_name, e
        ))
    })?;
    let y = feature_tbl.get::<_, u32>("y").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: wall_features[].y is required ({})",
            api_name, e
        ))
    })?;
    let kind = feature_tbl.get::<_, String>("kind").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: wall_features[].kind is required ({})",
            api_name, e
        ))
    })?;
    let feature = match kind.as_str() {
        "half" | "half_height" => {
            let height = feature_tbl.get::<_, f32>("height").map_err(|e| {
                LuaError::RuntimeError(format!(
                    "{}: wall_features[].height is required for half walls ({})",
                    api_name, e
                ))
            })?;
            WallFeature::half_height(height)
        }
        "window" => {
            let sill_height = feature_tbl.get::<_, f32>("sill_height").map_err(|e| {
                LuaError::RuntimeError(format!(
                    "{}: wall_features[].sill_height is required for windows ({})",
                    api_name, e
                ))
            })?;
            let lintel_height = feature_tbl.get::<_, f32>("lintel_height").map_err(|e| {
                LuaError::RuntimeError(format!(
                    "{}: wall_features[].lintel_height is required for windows ({})",
                    api_name, e
                ))
            })?;
            WallFeature::window(
                sill_height,
                lintel_height,
                feature_tbl.get::<_, Option<f32>>("alpha")?.unwrap_or(0.35),
            )
        }
        "door" => {
            let direction = parse_door_direction(
                &format!("{}: wall_features[].direction", api_name),
                &feature_tbl.get::<_, String>("direction").map_err(|e| {
                    LuaError::RuntimeError(format!(
                        "{}: wall_features[].direction is required for doors ({})",
                        api_name, e
                    ))
                })?,
            )?;
            WallFeature::door(
                direction,
                feature_tbl
                    .get::<_, Option<f32>>("open_amount")?
                    .unwrap_or(0.0),
                feature_tbl.get::<_, Option<f32>>("alpha")?.unwrap_or(1.0),
            )
        }
        _ => {
            return Err(LuaError::RuntimeError(format!(
            "{}: wall_features[].kind must be \"half\", \"half_height\", \"window\", or \"door\"",
            api_name
        )))
        }
    };
    Ok((x, y, feature))
}

fn parse_surface_texture_descriptor(
    cell_tbl: &LuaTable,
    api_name: &str,
    field_name: &str,
) -> LuaResult<(u32, u32, TextureKey)> {
    let x = cell_tbl.get::<_, u32>("x").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: {}[].x is required ({})",
            api_name, field_name, e
        ))
    })?;
    let y = cell_tbl.get::<_, u32>("y").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: {}[].y is required ({})",
            api_name, field_name, e
        ))
    })?;
    let texture = cell_tbl.get::<_, LuaValue>("texture").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: {}[].texture is required ({})",
            api_name, field_name, e
        ))
    })?;
    let (key, _) =
        parse_texture_key_value(&texture, &format!("{}({}[].texture)", api_name, field_name))?
            .ok_or_else(|| {
                LuaError::RuntimeError(format!(
                    "{}: {}[].texture cannot be nil",
                    api_name, field_name
                ))
            })?;
    Ok((x, y, key))
}

fn parse_lowered_floor_descriptor(
    cell_tbl: &LuaTable,
    api_name: &str,
    field_name: &str,
) -> LuaResult<(u32, u32, crate::raycaster::build_scene::LoweredFloorCell)> {
    // add_method
    let x = cell_tbl.get::<_, u32>("x").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: {}[].x is required ({})",
            api_name, field_name, e
        ))
    })?;
    let y = cell_tbl.get::<_, u32>("y").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: {}[].y is required ({})",
            api_name, field_name, e
        ))
    })?;
    let texture = cell_tbl.get::<_, LuaValue>("texture").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: {}[].texture is required ({})",
            api_name, field_name, e
        ))
    })?;
    let (texture_key, _) =
        parse_texture_key_value(&texture, &format!("{}({}[].texture)", api_name, field_name))?
            .ok_or_else(|| {
                LuaError::RuntimeError(format!(
                    "{}: {}[].texture cannot be nil",
                    api_name, field_name
                ))
            })?;
    Ok((
        x,
        y,
        crate::raycaster::build_scene::LoweredFloorCell {
            texture_key,
            depth_offset: cell_tbl
                .get::<_, Option<f32>>("depth")?
                .unwrap_or(0.25)
                .clamp(0.0, 0.75),
            tint: [
                cell_tbl
                    .get::<_, Option<f32>>("r")?
                    .unwrap_or(1.0)
                    .clamp(0.0, 1.0),
                cell_tbl
                    .get::<_, Option<f32>>("g")?
                    .unwrap_or(1.0)
                    .clamp(0.0, 1.0),
                cell_tbl
                    .get::<_, Option<f32>>("b")?
                    .unwrap_or(1.0)
                    .clamp(0.0, 1.0),
            ],
            blocked: cell_tbl.get::<_, Option<bool>>("blocked")?.unwrap_or(true),
        },
    ))
}

fn parse_multilevel_level(
    level_tbl: &LuaTable,
    level_index: usize,
    api_name: &str,
) -> LuaResult<RaycasterLevel> {
    // add_method
    let width = level_tbl.get::<_, u32>("width").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: levels[{}].width is required ({})",
            api_name,
            level_index + 1,
            e
        ))
    })?;
    let height = level_tbl.get::<_, u32>("height").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: levels[{}].height is required ({})",
            api_name,
            level_index + 1,
            e
        ))
    })?;
    let cells_tbl = level_tbl.get::<_, LuaTable>("cells").map_err(|e| {
        LuaError::RuntimeError(format!(
            "{}: levels[{}].cells is required ({})",
            api_name,
            level_index + 1,
            e
        ))
    })?;
    let cells: Vec<u32> = cells_tbl
        .sequence_values::<u32>()
        .collect::<LuaResult<_>>()?;
    let expected_len = (width as usize) * (height as usize);
    if cells.len() != expected_len {
        return Err(LuaError::RuntimeError(format!(
            "{}: levels[{}].cells must have {} elements, got {}",
            api_name,
            level_index + 1,
            expected_len,
            cells.len()
        )));
    }

    let floor_offset = level_tbl
        .get::<_, Option<f32>>("floor_offset")?
        .unwrap_or(level_index as f32);
    let ceiling_height = level_tbl
        .get::<_, Option<f32>>("ceiling_height")?
        .unwrap_or(floor_offset + 1.0);
    let mut level = RaycasterLevel::new(width as usize, height as usize);
    level.walls = cells;
    level.floor_offset = floor_offset;
    level.ceiling_height = ceiling_height;

    if let Some(floor_holes_tbl) = level_tbl.get::<_, Option<LuaTable>>("floor_holes")? {
        let floor_holes: Vec<bool> = floor_holes_tbl
            .sequence_values::<bool>()
            .collect::<LuaResult<_>>()?;
        if floor_holes.len() != expected_len {
            return Err(LuaError::RuntimeError(format!(
                "{}: levels[{}].floor_holes must have {} elements, got {}",
                api_name,
                level_index + 1,
                expected_len,
                floor_holes.len()
            )));
        }
        level.floor_holes = floor_holes;
    }
    if let Some(ceiling_holes_tbl) = level_tbl.get::<_, Option<LuaTable>>("ceiling_holes")? {
        let ceiling_holes: Vec<bool> = ceiling_holes_tbl
            .sequence_values::<bool>()
            .collect::<LuaResult<_>>()?;
        if ceiling_holes.len() != expected_len {
            return Err(LuaError::RuntimeError(format!(
                "{}: levels[{}].ceiling_holes must have {} elements, got {}",
                api_name,
                level_index + 1,
                expected_len,
                ceiling_holes.len()
            )));
        }
        level.ceiling_holes = ceiling_holes;
    }
    if let Some(wall_features_tbl) = level_tbl.get::<_, Option<LuaTable>>("wall_features")? {
        for feature_result in wall_features_tbl.sequence_values::<LuaTable>() {
            let feature_tbl = feature_result?;
            let (x, y, feature) = parse_wall_feature_descriptor(&feature_tbl, api_name)?;
            if x as usize >= level.width || y as usize >= level.height {
                return Err(LuaError::RuntimeError(format!(
                    "{}: wall_features cell {},{} is out of bounds for level {} size {}x{}",
                    api_name,
                    x,
                    y,
                    level_index + 1,
                    level.width,
                    level.height
                )));
            }
            level.set_wall_feature(x as usize, y as usize, feature);
        }
    }

    let floor_tex_val = level_tbl
        .get::<_, Option<LuaValue>>("floor_texture")?
        .unwrap_or(LuaValue::Nil);
    if let Some((key, _)) = parse_texture_key_value(
        &floor_tex_val,
        &format!("{}(levels[].floor_texture)", api_name),
    )? {
        level.floor_texture = Some(key);
    }
    let ceiling_tex_val = level_tbl
        .get::<_, Option<LuaValue>>("ceiling_texture")?
        .unwrap_or(LuaValue::Nil);
    if let Some((key, _)) = parse_texture_key_value(
        &ceiling_tex_val,
        &format!("{}(levels[].ceiling_texture)", api_name),
    )? {
        level.ceiling_texture = Some(key);
    }
    if let Some(floor_cells_tbl) = level_tbl.get::<_, Option<LuaTable>>("floor_cell_textures")? {
        for cell_result in floor_cells_tbl.sequence_values::<LuaTable>() {
            let cell_tbl = cell_result?;
            let (x, y, texture_key) =
                parse_surface_texture_descriptor(&cell_tbl, api_name, "floor_cell_textures")?;
            if x as usize >= level.width || y as usize >= level.height {
                return Err(LuaError::RuntimeError(format!(
                    "{}: floor_cell_textures cell {},{} is out of bounds for level {} size {}x{}",
                    api_name,
                    x,
                    y,
                    level_index + 1,
                    level.width,
                    level.height
                )));
            }
            level.set_floor_texture(x as usize, y as usize, texture_key);
        }
    }
    if let Some(ceiling_cells_tbl) =
        level_tbl.get::<_, Option<LuaTable>>("ceiling_cell_textures")?
    {
        for cell_result in ceiling_cells_tbl.sequence_values::<LuaTable>() {
            let cell_tbl = cell_result?;
            let (x, y, texture_key) =
                parse_surface_texture_descriptor(&cell_tbl, api_name, "ceiling_cell_textures")?;
            if x as usize >= level.width || y as usize >= level.height {
                return Err(LuaError::RuntimeError(format!(
                    "{}: ceiling_cell_textures cell {},{} is out of bounds for level {} size {}x{}",
                    api_name,
                    x,
                    y,
                    level_index + 1,
                    level.width,
                    level.height
                )));
            }
            level.set_ceiling_texture(x as usize, y as usize, texture_key);
        }
    }
    if let Some(lowered_cells_tbl) = level_tbl.get::<_, Option<LuaTable>>("lowered_floor_cells")? {
        for cell_result in lowered_cells_tbl.sequence_values::<LuaTable>() {
            let cell_tbl = cell_result?;
            let (x, y, lowered_floor) =
                parse_lowered_floor_descriptor(&cell_tbl, api_name, "lowered_floor_cells")?;
            if x as usize >= level.width || y as usize >= level.height {
                return Err(LuaError::RuntimeError(format!(
                    "{}: lowered_floor_cells cell {},{} is out of bounds for level {} size {}x{}",
                    api_name,
                    x,
                    y,
                    level_index + 1,
                    level.width,
                    level.height
                )));
            }
            level.set_lowered_floor(x as usize, y as usize, lowered_floor);
        }
    }

    Ok(level)
}

fn parse_multilevel_grid(levels_tbl: LuaTable, api_name: &str) -> LuaResult<MultiLevelGrid> {
    let mut grid = MultiLevelGrid::new();
    for (level_index, level_result) in levels_tbl.sequence_values::<LuaTable>().enumerate() {
        let level_tbl = level_result?;
        grid.add_level(parse_multilevel_level(&level_tbl, level_index, api_name)?);
    }
    Ok(grid)
}

fn parse_multilevel_grid_value(value: LuaValue, api_name: &str) -> LuaResult<MultiLevelGrid> {
    match value {
        LuaValue::Nil => Ok(MultiLevelGrid::new()),
        LuaValue::Table(tbl) => parse_multilevel_grid(tbl, api_name),
        LuaValue::UserData(ud) => {
            let grid = ud.borrow::<LuaMultiLevelGrid>().map_err(|_| {
                LuaError::RuntimeError(format!(
                    "{}: levels must be an array table, LMultiLevelGrid, or nil",
                    api_name
                ))
            })?;
            let cloned = grid.inner.borrow().clone();
            Ok(cloned)
        }
        _ => Err(LuaError::RuntimeError(format!(
            "{}: levels must be an array table, LMultiLevelGrid, or nil",
            api_name
        ))),
    }
}

fn parse_world_sprites(value: LuaValue, api_name: &str) -> LuaResult<Vec<WorldSprite>> {
    // add_method
    match value {
        LuaValue::Nil => Ok(Vec::new()),
        LuaValue::Table(tbl) => {
            let mut v = Vec::new();
            for pair in tbl.sequence_values::<LuaTable>() {
                let st = pair?;
                let directional_textures = parse_directional_sprite_textures(&st, api_name)?;
                let key = if let Some(textures) = directional_textures {
                    textures.front
                } else {
                    let tex_val = st.get::<_, LuaValue>("texture")?;
                    let (key, _) = parse_texture_key_value(
                        &tex_val,
                        &format!("{}(sprites[].texture)", api_name),
                    )?
                    .ok_or_else(|| {
                        LuaError::RuntimeError(format!(
                            "{}: sprites[].texture cannot be nil when directional textures are absent",
                            api_name
                        ))
                    })?;
                    key
                };
                v.push(WorldSprite {
                    entity_id: st.get::<_, Option<u32>>("id")?,
                    level_index: st.get::<_, Option<usize>>("level")?.unwrap_or(0),
                    world_x: st.get::<_, f32>("x")?,
                    world_y: st.get::<_, f32>("y")?,
                    texture_key: key,
                    directional_textures,
                    size: st.get::<_, Option<f32>>("size")?.unwrap_or(1.0),
                });
            }
            Ok(v)
        }
        LuaValue::UserData(ud) => {
            let manager = ud.borrow::<LuaSpriteManager>().map_err(|_| {
                LuaError::RuntimeError(format!(
                    "{}: sprites must be an array table, LSpriteManager, or nil",
                    api_name
                ))
            })?;
            manager.scene_world_sprites(api_name)
        }
        _ => Ok(Vec::new()),
    }
}

fn texture_pick_is_opaque(
    textures: &slotmap::SlotMap<TextureKey, crate::render::renderer::TextureData>,
    texture_key: TextureKey,
    u: f32,
    v: f32,
) -> bool {
    let Some(texture) = textures.get(texture_key) else {
        return true;
    };
    if texture.width == 0 || texture.height == 0 {
        return true;
    }
    let sx = (u.clamp(0.0, 1.0) * (texture.width.saturating_sub(1)) as f32).round() as u32;
    let sy = (v.clamp(0.0, 1.0) * (texture.height.saturating_sub(1)) as f32).round() as u32;
    let idx = ((sy * texture.width + sx) * 4 + 3) as usize;
    texture.pixels.get(idx).copied().unwrap_or(255) > 0
}

fn parse_level_sprites(
    value: LuaValue,
    api_name: &str,
    default_level: usize,
) -> LuaResult<Vec<LevelSprite>> {
    // add_method
    match value {
        LuaValue::Nil => Ok(Vec::new()),
        LuaValue::Table(tbl) => {
            let mut v = Vec::new();
            for pair in tbl.sequence_values::<LuaTable>() {
                let st = pair?;
                let directional_textures = parse_directional_sprite_textures(&st, api_name)?;
                let key = if let Some(textures) = directional_textures {
                    textures.front
                } else {
                    let tex_val = st.get::<_, LuaValue>("texture")?;
                    let (key, _) = parse_texture_key_value(
                        &tex_val,
                        &format!("{}(sprites[].texture)", api_name),
                    )?
                    .ok_or_else(|| {
                        LuaError::RuntimeError(format!(
                            "{}: sprites[].texture cannot be nil when directional textures are absent",
                            api_name
                        ))
                    })?;
                    key
                };
                let level_index = st
                    .get::<_, Option<usize>>("level")?
                    .unwrap_or(default_level);
                v.push(LevelSprite {
                    level_index,
                    sprite: WorldSprite {
                        entity_id: st.get::<_, Option<u32>>("id")?,
                        level_index,
                        world_x: st.get::<_, f32>("x")?,
                        world_y: st.get::<_, f32>("y")?,
                        texture_key: key,
                        directional_textures,
                        size: st.get::<_, Option<f32>>("size")?.unwrap_or(1.0),
                    },
                });
            }
            Ok(v)
        }
        LuaValue::UserData(ud) => {
            let manager = ud.borrow::<LuaSpriteManager>().map_err(|_| {
                LuaError::RuntimeError(format!(
                    "{}: sprites must be an array table, LSpriteManager, or nil",
                    api_name
                ))
            })?;
            manager.scene_level_sprites(api_name, default_level)
        }
        _ => Ok(Vec::new()),
    }
}

#[cfg(feature = "obj-loader")]
fn parse_model_instance_level(model_tbl: &LuaTable, default_level: usize) -> LuaResult<usize> {
    Ok(model_tbl
        .get::<_, Option<usize>>("level")?
        .unwrap_or(default_level))
}

#[cfg(feature = "obj-loader")]
fn parse_model_instance_yaw(model_tbl: &LuaTable) -> LuaResult<f32> {
    if let Some(yaw) = model_tbl.get::<_, Option<f32>>("yaw")? {
        Ok(yaw)
    } else {
        Ok(
            model_tbl.get::<_, Option<u8>>("rotation")?.unwrap_or(0) as f32
                * std::f32::consts::FRAC_PI_2,
        )
    }
}

#[cfg(feature = "obj-loader")]
fn collect_model_tables_by_level<'lua>(
    models_tbl: &LuaTable<'lua>,
    default_level: usize,
    level_count: usize,
) -> LuaResult<Vec<Vec<LuaTable<'lua>>>> {
    let mut grouped: Vec<Vec<LuaTable<'lua>>> = (0..level_count).map(|_| Vec::new()).collect();
    for pair in models_tbl.clone().sequence_values::<LuaTable>() {
        let mt = pair?;
        let level_index = parse_model_instance_level(&mt, default_level)?;
        if level_index < level_count {
            grouped[level_index].push(mt);
        }
    }
    Ok(grouped)
}

#[cfg(feature = "obj-loader")]
#[allow(clippy::too_many_arguments)]
fn project_model_instance(
    mt: &LuaTable,
    api_name: &str,
    params: &SceneBuildParams,
    cam_pos: Vec3,
    cam_target: Vec3,
    level_index: usize,
    base_y: f32,
    ambient: f32,
    lights: &[PointLight],
    wall_at: &dyn Fn(i32, i32) -> bool,
) -> LuaResult<Option<ModelMesh>> {
    // add_method
    let model_ud = mt.get::<_, LuaAnyUserData>("model")?;
    let model_ref = model_ud.borrow::<LuaObjModel>().map_err(|_| {
        LuaError::RuntimeError(format!("{}: models[].model must be LuaObjModel", api_name))
    })?;
    let world_x = mt.get::<_, f32>("x")?;
    let world_y = mt.get::<_, f32>("y")?;
    let entity_id = mt.get::<_, Option<u32>>("id")?;
    let yaw = parse_model_instance_yaw(mt)?;
    let scale = mt.get::<_, Option<f32>>("scale")?.unwrap_or(1.0);
    let z_offset = mt.get::<_, Option<f32>>("z")?.unwrap_or(0.0);
    let (mut mesh, depth, triangle_depths) = model_ref.model.project_instance_to_mesh(
        cam_pos,
        cam_target,
        params.fov,
        params.screen_width,
        params.screen_height,
        world_x,
        world_y,
        base_y + z_offset,
        yaw,
        scale,
    );
    if mesh.vertices.is_empty() {
        return Ok(None);
    }
    let model_light = apply_global_light(
        compute_lighting(world_x, world_y, ambient, lights, wall_at),
        world_x,
        world_y,
        ambient < params.ambient_light,
        [
            params.global_light_color.r,
            params.global_light_color.g,
            params.global_light_color.b,
        ],
        params.global_light_intensity,
        params.sun_angle,
        params.max_distance.min(12.0),
        wall_at,
    );
    for v in &mut mesh.vertices {
        v.r *= model_light[0];
        v.g *= model_light[1];
        v.b *= model_light[2];
    }
    Ok(Some(ModelMesh {
        mesh,
        depth,
        triangle_depths,
        entity_id,
        level_index,
        world_x,
        world_y,
    }))
}

fn parse_wall_texture_map(
    value: LuaValue,
    api_name: &str,
) -> LuaResult<std::collections::HashMap<u32, TextureKey>> {
    match value {
        LuaValue::Table(tbl) => {
            let mut m = std::collections::HashMap::new();
            for pair in tbl.pairs::<u32, LuaValue>() {
                let (cell_val, tex_val) = pair?;
                let (key, _) =
                    parse_texture_key_value(&tex_val, &format!("{}(wall_textures)", api_name))?
                        .ok_or_else(|| {
                            LuaError::RuntimeError(format!(
                                "{}: wall_textures[{}] cannot be nil",
                                api_name, cell_val
                            ))
                        })?;
                m.insert(cell_val, key);
            }
            Ok(m)
        }
        _ => Ok(std::collections::HashMap::new()),
    }
}
/// Lua-visible door manager that controls sliding doors within a raycaster map.
/// Doors can be opened, closed, and animated over time at configurable speeds.
pub struct LuaDoorManager {
    inner: Rc<RefCell<DoorManager>>,
}
impl LuaUserData for LuaDoorManager {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addDoor --
        /// Registers a new sliding door at the given grid cell.
        /// @param | x | integer | Grid column of the door cell.
        /// @param | y | integer | Grid row of the door cell.
        /// @param | direction | string | Slide axis: "horizontal" or "vertical".
        /// @param | speed | number | How fast the door opens/closes (units per second).
        /// @return | integer | Zero-based index of the newly added door.
        methods.add_method_mut(
            "addDoor",
            |_, this, (x, y, dir_str, speed): (u32, u32, String, f32)| {
                let dir = match dir_str.as_str() {
                    "vertical" => DoorDirection::Vertical,
                    _ => DoorDirection::Horizontal,
                };
                Ok(this.inner.borrow_mut().add_door(x, y, dir, speed))
            },
        );
        // -- openDoor --
        /// Begins opening the door at the given index. The door animates over time via `update()`.
        /// @param | index | integer | Zero-based index of the door to open.
        methods.add_method_mut("openDoor", |_, this, index: usize| {
            this.inner.borrow_mut().open_door(index);
            Ok(())
        });
        // -- closeDoor --
        /// Begins closing the door at the given index. The door animates over time via `update()`.
        /// @param | index | integer | Zero-based index of the door to close.
        methods.add_method_mut("closeDoor", |_, this, index: usize| {
            this.inner.borrow_mut().close_door(index);
            Ok(())
        });
        // -- update --
        /// Advances all door animations by the given delta time. Call once per frame.
        /// @param | dt | number | Delta time in seconds since last frame.
        methods.add_method_mut("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });
        // -- getDoor --
        /// Returns a table describing the door at the given index, or nil if index is out of range.
        /// The table contains: x, y, openAmount (0.0..1.0), state ("closed"|"opening"|"open"|"closing").
        /// @param | index | integer | Zero-based index of the door to query.
        /// @return | table | Door info table, or nil if not found.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | openAmount | number | Open amount 0.0 to 1.0.
        /// @field | state | string | Door state.
        methods.add_method("getDoor", |lua, this, index: usize| {
            let mgr = this.inner.borrow();
            if let Some(door) = mgr.doors().get(index) {
                let tbl = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                tbl.set("x", door.x)?;
                /// The 'y' field value exposed to Lua scripts.
                tbl.set("y", door.y)?;
                /// Performs the 'openAmount' operation.
                tbl.set("openAmount", door.open_amount)?;
                let state_str = match door.state {
                    DoorState::Closed => "closed",
                    DoorState::Opening => "opening",
                    DoorState::Open => "open",
                    DoorState::Closing => "closing",
                };
                /// Performs the 'state' operation.
                tbl.set("state", state_str)?;
                Ok(LuaValue::Table(tbl))
            } else {
                Ok(LuaValue::Nil)
            }
        });
        // -- count --
        /// Returns the total number of registered doors.
        /// @return | integer | Door count.
        methods.add_method("count", |_, this, ()| Ok(this.inner.borrow().doors().len()));
        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always "LDoorManager".
        methods.add_method("type", |_, _, ()| Ok("LDoorManager"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the name matches this userdata type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDoorManager" || name == "LObject")
        });
    }
}
/// Lua-visible height map that stores per-cell floor and ceiling offsets for variable-height raycaster levels.
pub struct LuaHeightMap {
    inner: Rc<RefCell<HeightMap>>,
}
impl LuaUserData for LuaHeightMap {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setFloor --
        /// Sets the floor height offset at a specific grid cell.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | h | number | Floor height offset (0.0 = default floor level).
        methods.add_method_mut("setFloor", |_, this, (x, y, h): (u32, u32, f32)| {
            this.inner.borrow_mut().set_floor(x, y, h);
            Ok(())
        });
        // -- setCeiling --
        /// Sets the ceiling height offset at a specific grid cell.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | h | number | Ceiling height offset (0.0 = default ceiling level).
        methods.add_method_mut("setCeiling", |_, this, (x, y, h): (u32, u32, f32)| {
            this.inner.borrow_mut().set_ceiling(x, y, h);
            Ok(())
        });
        // -- floorAt --
        /// Returns the floor height offset at a given grid cell.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | number | Floor height offset at that cell.
        methods.add_method("floorAt", |_, this, (x, y): (u32, u32)| {
            Ok(this.inner.borrow().floor_at(x, y))
        });
        // -- ceilingAt --
        /// Returns the ceiling height offset at a given grid cell.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | number | Ceiling height offset at that cell.
        methods.add_method("ceilingAt", |_, this, (x, y): (u32, u32)| {
            Ok(this.inner.borrow().ceiling_at(x, y))
        });
        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always "LHeightMap".
        methods.add_method("type", |_, _, ()| Ok("LHeightMap"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the name matches this userdata type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LHeightMap" || name == "LObject")
        });
    }
}
/// Lua-visible point light that illuminates nearby raycaster tiles and sprites with colored light and falloff.
#[derive(Clone)]
pub struct LuaPointLight {
    inner: PointLight,
}
impl LuaUserData for LuaPointLight {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- x --
        /// Returns the X world position of this light.
        /// @return | number | X coordinate.
        methods.add_method("x", |_, this, ()| Ok(this.inner.x));
        // -- y --
        /// Returns the Y world position of this light.
        /// @return | number | Y coordinate.
        methods.add_method("y", |_, this, ()| Ok(this.inner.y));
        // -- level --
        /// Returns the optional multilevel slice index that owns this light.
        /// @return | integer | Level index, or nil when this light is global across levels.
        methods.add_method("level", |_, this, ()| Ok(this.inner.level_index));
        // -- radius --
        /// Returns the light's falloff radius in world units.
        /// @return | number | Radius.
        methods.add_method("radius", |_, this, ()| Ok(this.inner.radius));
        // -- intensity --
        /// Returns the brightness multiplier of this light.
        /// @return | number | Intensity.
        methods.add_method("intensity", |_, this, ()| Ok(this.inner.intensity));
        // -- color --
        /// Returns the RGB color components of this light.
        /// @return | number | Red channel (0.0..1.0).
        /// @return | number | Green channel (0.0..1.0).
        /// @return | number | Blue channel (0.0..1.0).
        methods.add_method("color", |_, this, ()| {
            Ok((
                this.inner.color[0],
                this.inner.color[1],
                this.inner.color[2],
            ))
        });
        // -- set --
        /// Overwrites all properties of this point light in a single call.
        /// @param | x | number | New X world position.
        /// @param | y | number | New Y world position.
        /// @param | r | number | Red color channel (0.0..1.0).
        /// @param | g | number | Green color channel (0.0..1.0).
        /// @param | b | number | Blue color channel (0.0..1.0).
        /// @param | radius | number | Falloff radius in world units.
        /// @param | intensity | number | Brightness multiplier.
        /// @param | level | integer? | Optional multilevel slice index that owns this light.
        methods.add_method_mut(
            "set",
            |_,
             this,
             (x, y, r, g, b, radius, intensity, level): (
                f32,
                f32,
                f32,
                f32,
                f32,
                f32,
                f32,
                Option<usize>,
            )| {
                this.inner.x = x;
                this.inner.y = y;
                this.inner.color = [r, g, b];
                this.inner.radius = radius;
                this.inner.intensity = intensity;
                this.inner.level_index = level;
                Ok(())
            },
        );
        // -- setLevel --
        /// Updates the optional multilevel slice index that owns this light.
        /// @param | level | integer? | Level index, or nil to let this light affect every level.
        methods.add_method_mut("setLevel", |_, this, level: Option<usize>| {
            this.inner.level_index = level;
            Ok(())
        });
        // -- type --
        /// Returns the type name of this object ("LPointLight").
        /// @return | string | Type name string.
        methods.add_method("type", |_, _, ()| Ok("LPointLight"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to test against.
        /// @return | boolean | True if this object is of the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LPointLight" || name == "LObject")
        });
    }
}
/// Lua-visible raycaster map that holds cell data, per-cell textures, and provides raycasting,.
/// collision, and scene-building operations for first-person dungeon-crawler rendering.
pub struct LuaRaycaster {
    inner: Raycaster2D,
    state: Rc<RefCell<SharedState>>,
    floor_cell_textures: HashMap<(u32, u32), (TextureKey, u64)>,
    ceiling_cell_textures: HashMap<(u32, u32), (TextureKey, u64)>,
    lowered_floor_cells: HashMap<(u32, u32), LuaLoweredFloorCell>,
}
#[derive(Clone, Copy)]
/// Stores lowered-floor render overrides for a single raycaster cell.
struct LuaLoweredFloorCell {
    texture_key: TextureKey,
    raw_id: u64,
    depth_offset: f32,
    tint: [f32; 3],
    blocked: bool,
}
impl LuaUserData for LuaRaycaster {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setCell --
        /// Sets the wall type value at a grid cell. Non-zero values are solid walls.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | val | integer | Wall type (0 = empty, 1+ = wall texture index).
        methods.add_method_mut("setCell", |_, this, (x, y, val): (u32, u32, u32)| {
            this.inner.set_cell(x, y, val);
            Ok(())
        });
        // -- getCell --
        /// Returns the wall type value at a grid cell.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | integer | Cell value (0 = empty, 1+ = wall type).
        methods.add_method("getCell", |_, this, (x, y): (u32, u32)| {
            Ok(this.inner.get_cell(x, y))
        });
        // -- setHalfWallCell --
        /// Attaches a half-height wall feature to a blocking cell.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | height | number | Solid wall height from floor, 0.0..1.0.
        methods.add_method_mut(
            "setHalfWallCell",
            |_, this, (x, y, height): (u32, u32, f32)| {
                this.inner
                    .set_wall_feature(x, y, WallFeature::half_height(height));
                Ok(())
            },
        );
        // -- setWindowCell --
        /// Attaches a window feature to a blocking cell, leaving a visible opening between sill and lintel.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | sillHeight | number | Bottom of the opening from the floor, 0.0..1.0.
        /// @param | lintelHeight | number | Top of the opening from the floor, 0.0..1.0.
        /// @param | alpha | number? | Wall alpha multiplier for the solid bands.
        methods.add_method_mut(
            "setWindowCell",
            |_, this, (x, y, sill_height, lintel_height, alpha): (u32, u32, f32, f32, Option<f32>)| {
                this.inner.set_wall_feature(
                    x,
                    y,
                    WallFeature::window(sill_height, lintel_height, alpha.unwrap_or(0.35)),
                );
                Ok(())
            },
        );
        // -- setDoorCell --
        /// Attaches a sliding door feature to a blocking cell.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | direction | string | "horizontal" or "vertical".
        /// @param | openAmount | number | Door open amount, 0.0..1.0.
        /// @param | alpha | number? | Optional alpha multiplier.
        methods.add_method_mut(
            "setDoorCell",
            |_, this, (x, y, dir_str, open_amount, alpha): (u32, u32, String, f32, Option<f32>)| {
                let dir = parse_door_direction(
                    "lurek.raycaster.LRaycaster.setDoorCell(direction)",
                    &dir_str,
                )?;
                this.inner.set_wall_feature(
                    x,
                    y,
                    WallFeature::door(dir, open_amount, alpha.unwrap_or(1.0)),
                );
                Ok(())
            },
        );
        // -- applyDoorManager --
        /// Synchronizes animated doors from an `LDoorManager` into this map's per-cell wall features.
        /// The base map tile at each door position should remain non-zero so the door keeps its wall identity.
        /// @param | doors | LDoorManager | Door manager holding animated open amounts.
        /// @param | alpha | number? | Optional alpha multiplier for the synchronized door slabs.
        methods.add_method_mut(
            "applyDoorManager",
            |_, this, (doors_ud, alpha): (LuaAnyUserData, Option<f32>)| {
                let doors = doors_ud.borrow::<LuaDoorManager>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.raycaster.applyDoorManager: expected LDoorManager".to_string(),
                    )
                })?;
                this.inner
                    .sync_doors(&doors.inner.borrow(), alpha.unwrap_or(1.0));
                Ok(())
            },
        );
        // -- clearWallFeatureCell --
        /// Removes any per-cell wall feature override from a blocking cell.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        methods.add_method_mut("clearWallFeatureCell", |_, this, (x, y): (u32, u32)| {
            this.inner.clear_wall_feature(x, y);
            Ok(())
        });
        // -- getWallFeatureCell --
        /// Returns the wall feature attached to a cell, or nil when none is set.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | table | Feature table {kind, alpha, ...} or nil.
        /// @field | kind | string | "half", "window", or "door".
        /// @field | alpha | number | Feature alpha/transparency override.
        /// @field | height | number | Half-wall height in cell units when `kind == "half"`.
        /// @field | sill_height | number | Window sill height when `kind == "window"`.
        /// @field | lintel_height | number | Window lintel height when `kind == "window"`.
        /// @field | direction | string | "horizontal" or "vertical" when `kind == "door"`.
        /// @field | open_amount | number | Door openness in 0.0..1.0 when `kind == "door"`.
        methods.add_method("getWallFeatureCell", |lua, this, (x, y): (u32, u32)| {
            let Some(feature) = this.inner.wall_feature(x, y) else {
                return Ok(LuaValue::Nil);
            };
            let tbl = lua.create_table()?;
            tbl.set("alpha", feature.alpha())?;
            match feature.kind {
                WallFeatureKind::HalfHeight { height } => {
                    tbl.set("kind", "half")?;
                    tbl.set("height", height)?;
                }
                WallFeatureKind::Window {
                    sill_height,
                    lintel_height,
                } => {
                    /// Feature kind string for a window wall feature descriptor.
                    tbl.set("kind", "window")?;
                    /// @field | sill_height | number | Window sill height when `kind == "window"`.
                    tbl.set("sill_height", sill_height)?;
                    /// Window lintel height for a wall feature descriptor.
                    tbl.set("lintel_height", lintel_height)?;
                }
                WallFeatureKind::Door {
                    direction,
                    open_amount,
                } => {
                    /// Feature kind string for a door wall feature descriptor.
                    tbl.set("kind", "door")?;
                    tbl.set(
                        "direction",
                        match direction {
                            DoorDirection::Horizontal => "horizontal",
                            DoorDirection::Vertical => "vertical",
                        },
                    )?;
                    /// Door open amount for a wall feature descriptor.
                    tbl.set("open_amount", open_amount)?;
                }
            }
            Ok(LuaValue::Table(tbl))
        });
        // -- setCells --
        /// Replaces the entire map grid with a flat array of cell values (row-major order).
        /// @param | cells | table | Flat array of numbers with width*height elements.
        methods.add_method_mut("setCells", |_, this, cells_tbl: LuaTable| {
            let cells: Vec<u32> = cells_tbl
                .sequence_values::<u32>()
                .collect::<LuaResult<_>>()?;
            this.inner.set_cells(cells);
            Ok(())
        });
        // -- isBlocked --
        /// Returns true if the grid cell is a solid wall (non-zero value).
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | boolean | True if cell blocks movement and rays.
        methods.add_method("isBlocked", |_, this, (x, y): (u32, u32)| {
            Ok(this.inner.is_blocked(x, y))
        });
        // -- width --
        /// Returns the map width in grid cells.
        /// @return | integer | Map width.
        methods.add_method("width", |_, this, ()| Ok(this.inner.width()));
        // -- height --
        /// Returns the map height in grid cells.
        /// @return | integer | Map height.
        methods.add_method("height", |_, this, ()| Ok(this.inner.height()));
        // -- setFloorTextureCell --
        /// Assigns a per-cell floor texture override. Pass nil to remove the override.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | texture | LImage? | Texture image, integer id, or nil to clear.
        methods.add_method_mut(
            "setFloorTextureCell",
            |_, this, (x, y, texture): (u32, u32, LuaValue)| {
                match parse_texture_key_value(&texture, "lurek.raycaster.setFloorTextureCell")? {
                    Some((key, raw_id)) => {
                        this.floor_cell_textures.insert((x, y), (key, raw_id));
                    }
                    None => {
                        this.floor_cell_textures.remove(&(x, y));
                    }
                }
                Ok(())
            },
        );
        // -- getFloorTextureCell --
        /// Returns the raw texture id assigned to this floor cell, or nil if none.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | integer | Raw texture id or nil.
        methods.add_method("getFloorTextureCell", |_, this, (x, y): (u32, u32)| {
            Ok(this.floor_cell_textures.get(&(x, y)).map(|entry| entry.1))
        });
        // -- setCeilingTextureCell --
        /// Assigns a per-cell ceiling texture override. Pass nil to remove the override.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | texture | LImage? | Texture image, integer id, or nil to clear.
        methods.add_method_mut(
            "setCeilingTextureCell",
            |_, this, (x, y, texture): (u32, u32, LuaValue)| {
                match parse_texture_key_value(&texture, "lurek.raycaster.setCeilingTextureCell")? {
                    Some((key, raw_id)) => {
                        this.ceiling_cell_textures.insert((x, y), (key, raw_id));
                    }
                    None => {
                        this.ceiling_cell_textures.remove(&(x, y));
                    }
                }
                Ok(())
            },
        );
        // -- getCeilingTextureCell --
        /// Returns the raw texture id assigned to this ceiling cell, or nil if none.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | integer | Raw texture id or nil.
        methods.add_method("getCeilingTextureCell", |_, this, (x, y): (u32, u32)| {
            Ok(this.ceiling_cell_textures.get(&(x, y)).map(|entry| entry.1))
        });
        // -- setLoweredFloorCell --
        /// Marks a cell as a lowered floor (pit) with its own texture, depth, tint, and blocking flag.
        /// Pass nil to remove the lowered floor designation.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | opts | table? | Options table {texture, depth?, r?, g?, b?, blocked?} or nil to clear.
        methods.add_method_mut(
            "setLoweredFloorCell",
            |_, this, (x, y, opts): (u32, u32, LuaValue)| {
                match opts {
                    LuaValue::Nil => {
                        this.lowered_floor_cells.remove(&(x, y));
                    }
                    LuaValue::Table(tbl) => {
                        let tex_val = tbl.get::<_, LuaValue>("texture")?;
                        let (texture_key, raw_id) = parse_texture_key_value(
                            &tex_val,
                            "lurek.raycaster.setLoweredFloorCell(texture)",
                        )?
                        .ok_or_else(|| {
                            LuaError::RuntimeError(
                                "lurek.raycaster.setLoweredFloorCell: opts.texture cannot be nil"
                                    .to_string(),
                            )
                        })?;
                        let depth_offset = tbl
                            .get::<_, Option<f32>>("depth")?
                            .unwrap_or(0.25)
                            .clamp(0.0, 0.75);
                        let tint = [
                            tbl.get::<_, Option<f32>>("r")?
                                .unwrap_or(1.0)
                                .clamp(0.0, 1.0),
                            tbl.get::<_, Option<f32>>("g")?
                                .unwrap_or(1.0)
                                .clamp(0.0, 1.0),
                            tbl.get::<_, Option<f32>>("b")?
                                .unwrap_or(1.0)
                                .clamp(0.0, 1.0),
                        ];
                        let blocked = tbl.get::<_, Option<bool>>("blocked")?.unwrap_or(true);
                        this.lowered_floor_cells.insert(
                            (x, y),
                            LuaLoweredFloorCell {
                                texture_key,
                                raw_id,
                                depth_offset,
                                tint,
                                blocked,
                            },
                        );
                    }
                    _ => {
                        return Err(LuaError::RuntimeError(
                            "lurek.raycaster.setLoweredFloorCell: opts must be a table or nil"
                                .to_string(),
                        ));
                    }
                }
                Ok(())
            },
        );
        // -- getLoweredFloorCell --
        /// Returns the lowered floor configuration at a cell, or nil if the cell is normal.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | table | Table {texture, depth, r, g, b, blocked} or nil.
        /// @field | texture | integer | Texture id.
        /// @field | depth | number | Floor depth.
        /// @field | r | number | Red component.
        /// @field | g | number | Green component.
        /// @field | b | number | Blue component.
        /// @field | blocked | boolean | Blocked.
        methods.add_method("getLoweredFloorCell", |lua, this, (x, y): (u32, u32)| {
            if let Some(cell) = this.lowered_floor_cells.get(&(x, y)) {
                let tbl = lua.create_table()?;
                /// Performs the 'texture' operation.
                tbl.set("texture", cell.raw_id)?;
                /// Performs the 'depth' operation.
                tbl.set("depth", cell.depth_offset)?;
                /// The 'r' field value exposed to Lua scripts.
                tbl.set("r", cell.tint[0])?;
                /// The 'g' field value exposed to Lua scripts.
                tbl.set("g", cell.tint[1])?;
                /// The 'b' field value exposed to Lua scripts.
                tbl.set("b", cell.tint[2])?;
                /// Performs the 'blocked' operation.
                tbl.set("blocked", cell.blocked)?;
                Ok(LuaValue::Table(tbl))
            } else {
                Ok(LuaValue::Nil)
            }
        });
        // -- isWalkBlocked --
        /// Returns true if the cell blocks walking (solid wall OR blocked lowered-floor cell).
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | boolean | True if the cell cannot be walked through.
        methods.add_method("isWalkBlocked", |_, this, (x, y): (u32, u32)| {
            Ok(this.inner.is_blocked(x, y)
                || this
                    .lowered_floor_cells
                    .get(&(x, y))
                    .map(|cell| cell.blocked)
                    .unwrap_or(false))
        });
        // -- tryMove --
        /// Attempts to move from (px,py) by (dx,dy) with wall-slide collision. Returns the final position.
        /// @param | px | number | Current X position in world space.
        /// @param | py | number | Current Y position in world space.
        /// @param | dx | number | Desired X movement delta.
        /// @param | dy | number | Desired Y movement delta.
        /// @return | number | Final X position.
        /// @return | number | Final Y position.
        /// @return | boolean | Whether any movement occurred.
        methods.add_method(
            "tryMove",
            |_, this, (px, py, dx, dy): (f32, f32, f32, f32)| {
                let width = this.inner.width();
                let height = this.inner.height();
                let (nx, ny, moved) = try_move(width, height, px, py, dx, dy, |x, y| {
                    this.inner.is_blocked(x, y)
                        || this
                            .lowered_floor_cells
                            .get(&(x, y))
                            .map(|cell| cell.blocked)
                            .unwrap_or(false)
                });
                Ok((nx, ny, moved))
            },
        );
        // -- gridMove --
        /// Performs a discrete grid-step movement in one of 4 cardinal directions with collision.
        /// Used for tile-by-tile dungeon crawlers.
        /// @param | px | number | Current X position.
        /// @param | py | number | Current Y position.
        /// @param | dir | integer | Facing direction 1..4 (1=N, 2=E, 3=S, 4=W).
        /// @param | action | string | Movement action: "forward", "back", "left", or "right".
        /// @param | step | number | Step distance in world units (typically 1.0).
        /// @return | number | Final X position.
        /// @return | number | Final Y position.
        /// @return | boolean | Whether the move succeeded.
        methods.add_method(
            "gridMove",
            |_, this, (px, py, dir, action, step): (f32, f32, u8, String, f32)| {
                let parsed = GridMoveAction::parse(action.as_str()).ok_or_else(|| {
                    LuaError::RuntimeError(
                        "lurek.raycaster.gridMove: action must be one of 'forward', 'back', 'left', 'right'"
                            .to_string(),
                    )
                })?;
                if !(1..=4).contains(&dir) {
                    return Err(LuaError::RuntimeError(
                        "lurek.raycaster.gridMove: dir must be in range 1..4".to_string(),
                    ));
                }
                let (dx, dy) = dir4_delta(dir, parsed, step);
                let width = this.inner.width();
                let height = this.inner.height();
                let (nx, ny, moved) = try_move(width, height, px, py, dx, dy, |x, y| {
                    this.inner.is_blocked(x, y)
                        || this
                            .lowered_floor_cells
                            .get(&(x, y))
                            .map(|cell| cell.blocked)
                            .unwrap_or(false)
                });
                Ok((nx, ny, moved))
            },
        );
        // -- castRay --
        /// Casts a single ray from (ox,oy) at the given angle and returns hit info or nil.
        /// @param | ox | number | Ray origin X.
        /// @param | oy | number | Ray origin Y.
        /// @param | angle | number | Ray direction in radians.
        /// @param | maxDist | number | Maximum cast distance.
        /// @return | table | Hit table {distance, raw_distance, cell_value, alpha, side, tex_u, hit_x, hit_y, hit} or nil.
        /// @field | distance | number | Distance.
        /// @field | raw_distance | number | Raw distance before correction.
        /// @field | cell_value | integer | Cell value at hit.
        /// @field | alpha | number | Alpha.
        /// @field | side | integer | Side index.
        /// @field | tex_u | number | Texture U coordinate.
        /// @field | hit_x | number | Hit X position.
        /// @field | hit_y | number | Hit Y position.
        /// @field | hit | boolean | Hit.
        methods.add_method(
            "castRay",
            |lua, this, (ox, oy, angle, max_dist): (f32, f32, f32, f32)| match this
                .inner
                .cast_ray(ox, oy, angle, max_dist)
            {
                Some(hit) => Ok(LuaValue::Table(ray_hit_to_table(lua, &hit)?)),
                None => Ok(LuaValue::Nil),
            },
        );
        // -- castRays --
        /// Casts multiple rays across a field of view and returns an array of hit tables.
        /// @param | ox | number | Ray origin X.
        /// @param | oy | number | Ray origin Y.
        /// @param | angle | number | Center angle in radians.
        /// @param | fov | number | Field of view in radians.
        /// @param | count | integer | Number of rays to cast.
        /// @param | maxDist | number | Maximum cast distance per ray.
        /// @return | table | Array of hit tables (same fields as castRay).
        /// @field | distance | number | Corrected perpendicular distance.
        /// @field | raw_distance | number | Uncorrected ray distance.
        /// @field | cell_value | integer | Cell value hit.
        /// @field | alpha | number | Sub-cell hit position.
        /// @field | side | integer | Wall side (0=x, 1=y).
        /// @field | tex_u | number | Texture u coordinate.
        /// @field | hit_x | number | World hit x.
        /// @field | hit_y | number | World hit y.
        /// @field | hit | boolean | True if ray hit a wall.
        methods.add_method(
            "castRays",
            |lua, this, (ox, oy, angle, fov, count, max_dist): (f32, f32, f32, f32, u32, f32)| {
                let hits = this.inner.cast_rays(ox, oy, angle, fov, count, max_dist);
                let tbl = lua.create_table()?;
                for (i, hit) in hits.iter().enumerate() {
                    tbl.set(i + 1, ray_hit_to_table(lua, hit)?)?;
                }
                Ok(tbl)
            },
        );
        // -- castRaysFlat --
        /// Casts multiple rays and returns only the corrected distances as a flat array.
        /// More efficient than castRays when only distances are needed.
        /// @param | ox | number | Ray origin X.
        /// @param | oy | number | Ray origin Y.
        /// @param | angle | number | Center angle in radians.
        /// @param | fov | number | Field of view in radians.
        /// @param | count | integer | Number of rays to cast.
        /// @param | maxDist | number | Maximum cast distance per ray.
        /// @return | number[] | Flat array of corrected distance values.
        methods.add_method(
            "castRaysFlat",
            |lua, this, (ox, oy, angle, fov, count, max_dist): (f32, f32, f32, f32, u32, f32)| {
                let flat = this
                    .inner
                    .cast_rays_flat(ox, oy, angle, fov, count, max_dist);
                lua.create_sequence_from(flat)
            },
        );
        // -- lineOfSight --
        /// Tests whether there is a clear line of sight between two world points (no walls in between).
        /// @param | x1 | number | Start X.
        /// @param | y1 | number | Start Y.
        /// @param | x2 | number | End X.
        /// @param | y2 | number | End Y.
        /// @return | boolean | True if the path is unobstructed.
        methods.add_method(
            "lineOfSight",
            |_, this, (x1, y1, x2, y2): (f32, f32, f32, f32)| {
                Ok(this.inner.line_of_sight(x1, y1, x2, y2))
            },
        );
        // -- revealCellsFromRays --
        /// Casts rays across the FOV and returns a list of grid cells that are visible (for fog-of-war).
        /// @param | ox | number | Ray origin X.
        /// @param | oy | number | Ray origin Y.
        /// @param | angle | number | Center angle in radians.
        /// @param | fov | number | Field of view in radians.
        /// @param | count | integer | Number of rays.
        /// @param | maxDist | number | Maximum ray distance.
        /// @param | step | number? | Walk step along each ray (default 0.2).
        /// @return | table | Array of {x, y} tables representing revealed grid cells.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        methods.add_method(
            "revealCellsFromRays",
            |lua,
             this,
             (ox, oy, angle, fov, count, max_dist, step): (
                f32,
                f32,
                f32,
                f32,
                u32,
                f32,
                Option<f32>,
            )| {
                let cells = reveal_cells_from_rays(
                    &this.inner,
                    ox,
                    oy,
                    angle,
                    fov,
                    count,
                    max_dist,
                    step.unwrap_or(0.2),
                );
                let out = lua.create_table()?;
                for (i, (x, y)) in cells.iter().enumerate() {
                    let row = lua.create_table()?;
                    /// The 'x' field value exposed to Lua scripts.
                    row.set("x", *x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    row.set("y", *y)?;
                    out.set(i + 1, row)?;
                }
                Ok(out)
            },
        );
        // -- computeTileLight --
        /// Computes the combined lighting color at a tile from ambient and point lights, accounting for walls.
        /// @param | x | integer | Tile grid column.
        /// @param | y | integer | Tile grid row.
        /// @param | ambient | number | Base ambient light level (0.0..1.0).
        /// @param | lights | table? | Array of point-light tables {x, y, radius, r?, g?, b?, color?, intensity?, level?} or LPointLight userdata values.
        /// @return | number | Red light channel.
        /// @return | number | Green light channel.
        /// @return | number | Blue light channel.
        /// @return | number | Average luminance.
        methods.add_method(
            "computeTileLight",
            |_, this, (x, y, ambient, lights_tbl): (u32, u32, f32, LuaValue)| {
                let lights = parse_point_lights(lights_tbl, "lurek.raycaster.computeTileLight")?;
                let rgb = compute_tile_light(&this.inner, x, y, ambient, &lights);
                let luma = ((rgb[0] + rgb[1] + rgb[2]) / 3.0).clamp(0.0, 1.0);
                Ok((rgb[0], rgb[1], rgb[2], luma))
            },
        );
        // -- buildMinimapWindow --
        /// Generates a grid of minimap tile samples around a center point with lighting info.
        /// Useful for rendering a lit minimap overlay.
        /// @param | centerX | number | Center X in world coordinates.
        /// @param | centerY | number | Center Y in world coordinates.
        /// @param | radius | integer | Tile radius around the center to sample.
        /// @param | ambient | number | Ambient light level (0.0..1.0).
        /// @param | lights | table? | Array of point-light tables or LPointLight userdata values.
        /// @return | table | Array of {x, y, blocked, visible, r, g, b, luma} tables.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | blocked | boolean | Blocked.
        /// @field | visible | boolean | Visible.
        /// @field | r | number | R.
        /// @field | g | number | G.
        /// @field | b | number | B.
        /// @field | luma | number | Luma.
        methods.add_method(
            "buildMinimapWindow",
            |lua,
             this,
             (center_x, center_y, radius, ambient, lights_tbl):
                 (f32, f32, u32, f32, LuaValue)| {
                let lights = parse_point_lights(lights_tbl, "lurek.raycaster.buildMinimapWindow")?;
                let samples =
                    build_minimap_tile_window(&this.inner, center_x, center_y, radius, ambient, &lights);
                let out = lua.create_table()?;
                for (i, s) in samples.iter().enumerate() {
                    let row = lua.create_table()?;
                    /// The 'x' field value exposed to Lua scripts.
                    row.set("x", s.x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    row.set("y", s.y)?;
                    /// Performs the 'blocked' operation.
                    row.set("blocked", s.blocked)?;
                    /// Performs the 'visible' operation.
                    row.set("visible", s.visible)?;
                    /// The 'r' field value exposed to Lua scripts.
                    row.set("r", s.light[0])?;
                    /// The 'g' field value exposed to Lua scripts.
                    row.set("g", s.light[1])?;
                    /// The 'b' field value exposed to Lua scripts.
                    row.set("b", s.light[2])?;
                    /// Performs the 'luma' operation.
                    row.set("luma", s.luma)?;
                    out.set(i + 1, row)?;
                }
                Ok(out)
            },
        );
        // -- extractMinimap --
        /// Extracts a pixel minimap image centered on the player from this raycaster map.
        /// @param | playerX | number | Player x position in world space.
        /// @param | playerY | number | Player y position in world space.
        /// @param | playerAngle | number | Player facing angle in radians.
        /// @param | viewRadius | integer | Visible tile radius around the player.
        /// @param | cellSize | integer | Pixel size of each minimap cell.
        /// @return | LImageData | Image data containing the extracted minimap.
        methods.add_method(
            "extractMinimap",
            |_,
             this,
             (player_x, player_y, player_angle, view_radius, cell_size): (
                f32,
                f32,
                f32,
                u32,
                u32,
            )| {
                let (pixels, width, height) = extract_minimap(
                    &this.inner,
                    player_x,
                    player_y,
                    player_angle,
                    view_radius,
                    cell_size.max(1),
                    [70, 75, 92, 255],
                    [20, 24, 30, 255],
                    [255, 220, 90, 255],
                );
                let img =
                    ImageData::from_bytes(width, height, pixels).map_err(LuaError::runtime)?;
                Ok(img)
            },
        );
        // -- setWallAlpha --
        /// Sets the transparency for a specific wall tile type, enabling see-through walls.
        /// @param | tileType | integer | The cell value (1..255) whose alpha to change.
        /// @param | alpha | number | Opacity (0.0 = fully transparent, 1.0 = fully opaque).
        methods.add_method_mut("setWallAlpha", |_, this, (tile_type, alpha): (u8, f32)| {
            this.inner.set_wall_alpha(tile_type, alpha);
            Ok(())
        });
        // -- getWallAlpha --
        /// Returns the current transparency value for a wall tile type.
        /// @param | tileType | integer | The cell value to query.
        /// @return | number | Alpha value (0.0..1.0).
        methods.add_method("getWallAlpha", |_, this, tile_type: u8| {
            Ok(this.inner.get_wall_alpha(tile_type))
        });
        // -- castRayMulti --
        /// Casts a single ray that passes through transparent walls, returning multiple hits.
        /// @param | ox | number | Ray origin X.
        /// @param | oy | number | Ray origin Y.
        /// @param | angle | number | Ray direction in radians.
        /// @param | maxDist | number | Maximum cast distance.
        /// @param | maxHits | integer? | Maximum number of hits to collect (default 4, max 8).
        /// @return | table | Array of hit tables in distance order.
        /// @field | distance | number | Corrected perpendicular distance.
        /// @field | raw_distance | number | Uncorrected ray distance.
        /// @field | cell_value | integer | Cell value hit.
        /// @field | alpha | number | Sub-cell hit position.
        /// @field | side | integer | Wall side (0=x, 1=y).
        /// @field | tex_u | number | Texture u coordinate.
        /// @field | hit_x | number | World hit x.
        /// @field | hit_y | number | World hit y.
        /// @field | hit | boolean | True if ray hit a wall.
        methods.add_method(
            "castRayMulti",
            |lua, this, (ox, oy, angle, max_dist, max_hits): (f32, f32, f32, f32, Option<u32>)| {
                let cap = max_hits.unwrap_or(4).min(8);
                let hits = this.inner.cast_ray_multi(ox, oy, angle, max_dist, cap);
                let tbl = lua.create_table()?;
                for (i, hit) in hits.iter().enumerate() {
                    tbl.set(i + 1, ray_hit_to_table(lua, hit)?)?;
                }
                Ok(tbl)
            },
        );
        // -- castFloorRow --
        /// Computes floor/ceiling texture UV coordinates for a single scanline row.
        /// Used for software-rendered textured floors.
        /// @param | camX | number | Camera X position.
        /// @param | camY | number | Camera Y position.
        /// @param | dirX | number | Camera forward direction X.
        /// @param | dirY | number | Camera forward direction Y.
        /// @param | planeX | number | Camera plane X (half-width of FOV).
        /// @param | planeY | number | Camera plane Y (half-width of FOV).
        /// @param | row | integer | Scanline row offset from screen center.
        /// @return | table | Array of {u, v} tables for each pixel in the row.
        /// @field | u | number | U.
        /// @field | v | number | V.
        methods.add_method(
            "castFloorRow",
            |lua,
             this,
             (cam_x, cam_y, dir_x, dir_y, plane_x, plane_y, row): (
                f32,
                f32,
                f32,
                f32,
                f32,
                f32,
                i32,
            )| {
                let uvs = this
                    .inner
                    .cast_floor_row(cam_x, cam_y, dir_x, dir_y, plane_x, plane_y, row);
                let tbl = lua.create_table()?;
                for (i, (u, v)) in uvs.iter().enumerate() {
                    let t = lua.create_table()?;
                    /// The 'u' field value exposed to Lua scripts.
                    t.set("u", *u)?;
                    /// The 'v' field value exposed to Lua scripts.
                    t.set("v", *v)?;
                    tbl.set(i + 1, t)?;
                }
                Ok(tbl)
            },
        );
        // -- projectSprite --
        /// Projects a world-space sprite to screen coordinates for billboard rendering.
        /// @param | sx | number | Sprite world X.
        /// @param | sy | number | Sprite world Y.
        /// @param | px | number | Player X position.
        /// @param | py | number | Player Y position.
        /// @param | pa | number | Player angle in radians.
        /// @param | fov | number | Field of view in radians.
        /// @param | screenW | number | Screen width in pixels.
        /// @return | table | Projection info {screen_x, scale, distance, visible}.
        /// @field | screen_x | number | Screen x.
        /// @field | scale | number | Scale.
        /// @field | distance | number | Distance.
        /// @field | visible | boolean | Visible.
        methods.add_method(
            "projectSprite",
            |lua,
             this,
             (sx, sy, px, py, pa, fov, screen_w): (f32, f32, f32, f32, f32, f32, f32)| {
                let sp = this.inner.project_sprite(sx, sy, px, py, pa, fov, screen_w);
                let t = lua.create_table()?;
                /// Performs the 'screen_x' operation.
                t.set("screen_x", sp.screen_x)?;
                /// Performs the 'scale' operation.
                t.set("scale", sp.scale)?;
                /// Performs the 'distance' operation.
                t.set("distance", sp.distance)?;
                /// Performs the 'visible' operation.
                t.set("visible", sp.visible)?;
                Ok(t)
            },
        );
        // -- drawTopDown --
        /// Renders a top-down debug view of the map with the player's position and direction.
        /// @param | px | number | Player X position.
        /// @param | py | number | Player Y position.
        /// @param | angle | number | Player facing angle in radians.
        /// @param | scale | integer | Pixels per grid cell.
        /// @return | LImageData | Raw image data.
        methods.add_method(
            "drawTopDown",
            |_, this, (px, py, angle, scale): (f32, f32, f32, u32)| {
                let img = this.inner.draw_top_down_to_image(px, py, angle, scale);
                Ok(img)
            },
        );
        // -- drawView --
        /// Renders a first-person raycaster view to a raw image buffer (no textures, flat-shaded).
        /// @param | px | number | Player X position.
        /// @param | py | number | Player Y position.
        /// @param | angle | number | Player facing angle in radians.
        /// @param | fov | number | Field of view in radians.
        /// @param | w | integer | Output image width in pixels.
        /// @param | h | integer | Output image height in pixels.
        /// @param | maxDist | number | Maximum render distance.
        /// @return | LImageData | Raw image data.
        methods.add_method(
            "drawView",
            |_, this, (px, py, angle, fov, w, h, max_dist): (f32, f32, f32, f32, u32, u32, f32)| {
                let img = this
                    .inner
                    .draw_view_to_image(px, py, angle, fov, w, h, max_dist);
                Ok(img)
            },
        );
        // -- drawDepthMap --
        /// Renders a grayscale depth map showing distance-to-wall for each column.
        /// @param | px | number | Player X position.
        /// @param | py | number | Player Y position.
        /// @param | angle | number | Player facing angle in radians.
        /// @param | fov | number | Field of view in radians.
        /// @param | numRays | integer | Number of rays (columns) to cast.
        /// @param | w | integer | Output image width in pixels.
        /// @param | h | integer | Output image height in pixels.
        /// @param | maxDist | number | Maximum render distance.
        /// @return | LImageData | Raw depth-map image data.
        methods.add_method(
            "drawDepthMap",
            |_,
             this,
             (px, py, angle, fov, num_rays, w, h, max_dist): (
                f32,
                f32,
                f32,
                f32,
                u32,
                u32,
                u32,
                f32,
            )| {
                let img = this
                    .inner
                    .draw_depth_map_to_image(px, py, angle, fov, num_rays, w, h, max_dist);
                Ok(img)
            },
        );
        // -- drawLineOfSight --
        /// Renders a debug image showing the line-of-sight ray between two world points.
        /// @param | ax | number | Start X.
        /// @param | ay | number | Start Y.
        /// @param | bx | number | End X.
        /// @param | by | number | End Y.
        /// @param | scale | integer | Pixels per grid cell.
        /// @return | LImageData | Raw image data for this view.
        methods.add_method(
            "drawLineOfSight",
            |_, this, (ax, ay, bx, by, scale): (f32, f32, f32, f32, u32)| {
                let img = this
                    .inner
                    .draw_line_of_sight_to_image(ax, ay, bx, by, scale);
                Ok(img)
            },
        );
        // -- drawCameraSweep --
        /// Renders multiple frames of a rotating camera sweep as a single combined image.
        /// @param | x | number | Camera X position.
        /// @param | y | number | Camera Y position.
        /// @param | fov | number | Field of view in radians.
        /// @param | maxDist | number | Maximum render distance.
        /// @param | numFrames | integer | Number of rotation steps.
        /// @param | fw | integer | Frame width in pixels.
        /// @param | fh | integer | Frame height in pixels.
        /// @return | LImageData | Raw image data for all frames.
        methods.add_method("drawCameraSweep", |_, this, (x, y, fov, max_dist, num_frames, fw, fh): (f32, f32, f32, f32, u32, u32, u32)| {
                let img = this.inner.draw_camera_sweep_to_image(x, y, fov, max_dist, num_frames, fw, fh);
                Ok(img)
            },
        );
        // -- pickScreen --
        /// Resolves a screen-space click back into the raycaster world using the same camera semantics as scene building.
        /// @param | sx | number | Screen X in pixels.
        /// @param | sy | number | Screen Y in pixels.
        /// @param | params | table | Camera params {px, py, angle, fov, max_dist, screen_w, screen_h, camera_height?, horizon_offset?}.
        /// @param | sprites | table|LSpriteManager? | Optional sprite tables or sprite manager used to resolve clickable billboard hits.
        /// @param | models | table? | Optional model instance tables used to resolve clickable projected model hits.
        /// @return | table | Pick result {x, y, level, surface, distance, hit_x, hit_y, u, v, cell_value?, side?, texture?, ray_angle, id?, wall_height?, feature?} or nil. `feature` mirrors `getWallFeatureCell()` and adds `section` for the solid band/panel that was hit.
        /// @field | x | number | Grid X coordinate.
        /// @field | y | number | Grid Y coordinate.
        /// @field | level | number | Level index. For a single `LRaycaster` map this is always 0.
        /// @field | surface | string | "wall", "floor", "ceiling", "sprite", or "model".
        /// @field | distance | number | Camera-space distance to the picked point.
        /// @field | hit_x | number | World hit X.
        /// @field | hit_y | number | World hit Y.
        /// @field | u | number | Surface U coordinate in 0.0..1.0.
        /// @field | v | number | Surface V coordinate in 0.0..1.0.
        /// @field | cell_value | integer | Cell value at the picked tile.
        /// @field | side | integer | Wall side for wall hits only (0=x, 1=y).
        /// @field | texture | integer | Raw floor/ceiling texture id when available.
        /// @field | ray_angle | number | Ray angle used to resolve this pick.
        /// @field | id | integer | Optional caller-supplied entity id for sprite/model hits.
        /// @field | wall_height | number | Local wall height in cell units for wall hits against partial-height features.
        /// @field | feature | table | Optional wall feature table mirroring `getWallFeatureCell()` plus `section` for the solid band or door panel that was hit.
        methods.add_method(
            "pickScreen",
            |lua,
             this,
             (sx, sy, params_tbl, sprites_tbl, models_tbl): (
                f32,
                f32,
                LuaTable,
                Option<LuaValue>,
                Option<LuaValue>,
            )| {
                let sprites_tbl = sprites_tbl.unwrap_or(LuaValue::Nil);
                let models_tbl = models_tbl.unwrap_or(LuaValue::Nil);
                let params = parse_scene_build_params(&params_tbl, "lurek.raycaster.pickScreen")?;
                let pick_params = ScreenPickParams {
                    player_x: params.player_x,
                    player_y: params.player_y,
                    player_angle: params.player_angle,
                    fov: params.fov,
                    screen_width: params.screen_width,
                    screen_height: params.screen_height,
                    camera_height: params.camera_height,
                    horizon_offset: params.horizon_offset,
                    max_distance: params.max_distance,
                };
                let tile_pick = this.inner.pick_screen(&pick_params, sx, sy);
                let entity_pick = if matches!(sprites_tbl, LuaValue::Nil)
                    && matches!(models_tbl, LuaValue::Nil)
                {
                    None
                } else {
                    let sprites = parse_world_sprites(sprites_tbl, "lurek.raycaster.pickScreen")?;
                    let mut scene = RaycasterScene::build(
                        &this.inner,
                        &params,
                        &[],
                        &sprites,
                        &|_| None,
                        &|x, y| this.floor_cell_textures.get(&(x, y)).map(|entry| entry.0),
                        &|x, y| this.ceiling_cell_textures.get(&(x, y)).map(|entry| entry.0),
                        &|x, y| {
                            this.lowered_floor_cells.get(&(x, y)).map(|cell| {
                                crate::raycaster::build_scene::LoweredFloorCell {
                                    texture_key: cell.texture_key,
                                    depth_offset: cell.depth_offset,
                                    tint: cell.tint,
                                    blocked: cell.blocked,
                                }
                            })
                        },
                    );
                    if let LuaValue::Table(tbl) = models_tbl {
                        #[cfg(feature = "obj-loader")]
                        {
                            let cam_pos =
                                Vec3::new(params.player_x, params.camera_height, params.player_y);
                            let cam_target = Vec3::new(
                                params.player_x + params.player_angle.cos(),
                                params.camera_height,
                                params.player_y + params.player_angle.sin(),
                            );
                            let wall_at = |cx: i32, cy: i32| -> bool {
                                cx < 0 || cy < 0 || this.inner.blocks_light_at(cx as u32, cy as u32)
                            };
                            for pair in tbl.sequence_values::<LuaTable>() {
                                let mt = pair?;
                                let model_cell_x = mt.get::<_, f32>("x")?.floor().max(0.0) as u32;
                                let model_cell_y = mt.get::<_, f32>("y")?.floor().max(0.0) as u32;
                                let model_ambient = if this
                                    .ceiling_cell_textures
                                    .contains_key(&(model_cell_x, model_cell_y))
                                {
                                    params.ambient_light * params.roofed_ambient_factor
                                } else {
                                    params.ambient_light
                                };
                                if let Some(model_mesh) = project_model_instance(
                                    &mt,
                                    "lurek.raycaster.pickScreen",
                                    &params,
                                    cam_pos,
                                    cam_target,
                                    0,
                                    0.0,
                                    model_ambient,
                                    &[],
                                    &wall_at,
                                )? {
                                    scene.models.push(model_mesh);
                                }
                            }
                        }
                        #[cfg(not(feature = "obj-loader"))]
                        {
                            let _ = &tbl;
                        }
                    }
                    let st = this.state.borrow();
                    scene.pick_entity_with_sprite_alpha_test(sx, sy, &|texture_key, u, v| {
                        texture_pick_is_opaque(&st.textures, texture_key, u, v)
                    })
                };
                if let Some(entity_pick) = entity_pick.as_ref() {
                    if tile_pick
                        .as_ref()
                        .map(|tile_pick| entity_pick_precedes_tile(entity_pick, tile_pick))
                        .unwrap_or(true)
                    {
                        return Ok(LuaValue::Table(entity_pick_to_table(lua, entity_pick)?));
                    }
                }
                let Some(pick) = tile_pick else {
                    return Ok(LuaValue::Nil);
                };
                let tbl = pick_result_to_table(lua, &pick)?;
                match pick.surface {
                    PickSurface::Floor => {
                        if let Some(cell) = this
                            .lowered_floor_cells
                            .get(&(pick.grid_x as u32, pick.grid_y as u32))
                        {
                            /// Texture id for the picked lowered floor cell.
                            /// @field | texture | integer | Raw lowered-floor texture id.
                            tbl.set("texture", cell.raw_id)?;
                        } else if let Some((_, raw_id)) = this
                            .floor_cell_textures
                            .get(&(pick.grid_x as u32, pick.grid_y as u32))
                        {
                            /// Texture id for the picked floor cell override.
                            /// @field | texture | integer | Raw floor texture override id.
                            tbl.set("texture", *raw_id)?;
                        }
                    }
                    PickSurface::Ceiling => {
                        if let Some((_, raw_id)) = this
                            .ceiling_cell_textures
                            .get(&(pick.grid_x as u32, pick.grid_y as u32))
                        {
                            /// Texture id for the picked ceiling cell override.
                            /// @field | texture | integer | Raw ceiling texture override id.
                            tbl.set("texture", *raw_id)?;
                        }
                    }
                    PickSurface::Wall => {}
                }
                Ok(LuaValue::Table(tbl))
            },
        );
        // -- pickScreenFromAdapter --
        /// Resolves a screen-space click using sprite/model inputs sourced from a runtime scene adapter.
        /// @param | sx | number | Screen X in pixels.
        /// @param | sy | number | Screen Y in pixels.
        /// @param | params | table | Camera params (same as pickScreen).
        /// @param | adapter | LSceneAdapter | Runtime scene adapter providing sprites and models.
        /// @return | table | Pick result or nil when nothing was hit. Wall hits may also include `wall_height` plus `feature = {kind, section, ...}` for half walls, windows, and doors.
        methods.add_method(
            "pickScreenFromAdapter",
            |lua, this, (sx, sy, params_tbl, adapter_ud): (f32, f32, LuaTable, LuaAnyUserData)| {
                let params =
                    parse_scene_build_params(&params_tbl, "lurek.raycaster.pickScreenFromAdapter")?;
                let (_lights_tbl, sprites_tbl, models_tbl) = scene_input_tables_from_adapter(
                    lua,
                    &adapter_ud,
                    "lurek.raycaster.pickScreenFromAdapter",
                )?;
                let pick_params = ScreenPickParams {
                    player_x: params.player_x,
                    player_y: params.player_y,
                    player_angle: params.player_angle,
                    fov: params.fov,
                    screen_width: params.screen_width,
                    screen_height: params.screen_height,
                    camera_height: params.camera_height,
                    horizon_offset: params.horizon_offset,
                    max_distance: params.max_distance,
                };
                let tile_pick = this.inner.pick_screen(&pick_params, sx, sy);
                let sprites = parse_world_sprites(
                    LuaValue::Table(sprites_tbl),
                    "lurek.raycaster.pickScreenFromAdapter",
                )?;
                let mut scene = RaycasterScene::build(
                    &this.inner,
                    &params,
                    &[],
                    &sprites,
                    &|_| None,
                    &|x, y| this.floor_cell_textures.get(&(x, y)).map(|entry| entry.0),
                    &|x, y| this.ceiling_cell_textures.get(&(x, y)).map(|entry| entry.0),
                    &|x, y| {
                        this.lowered_floor_cells.get(&(x, y)).map(|cell| {
                            crate::raycaster::build_scene::LoweredFloorCell {
                                texture_key: cell.texture_key,
                                depth_offset: cell.depth_offset,
                                tint: cell.tint,
                                blocked: cell.blocked,
                            }
                        })
                    },
                );
                #[cfg(feature = "obj-loader")]
                {
                    let cam_pos = Vec3::new(params.player_x, params.camera_height, params.player_y);
                    let cam_target = Vec3::new(
                        params.player_x + params.player_angle.cos(),
                        params.camera_height,
                        params.player_y + params.player_angle.sin(),
                    );
                    let wall_at = |cx: i32, cy: i32| -> bool {
                        cx < 0 || cy < 0 || this.inner.blocks_light_at(cx as u32, cy as u32)
                    };
                    for pair in models_tbl.sequence_values::<LuaTable>() {
                        let mt = pair?;
                        let model_cell_x = mt.get::<_, f32>("x")?.floor().max(0.0) as u32;
                        let model_cell_y = mt.get::<_, f32>("y")?.floor().max(0.0) as u32;
                        let model_ambient = if this
                            .ceiling_cell_textures
                            .contains_key(&(model_cell_x, model_cell_y))
                        {
                            params.ambient_light * params.roofed_ambient_factor
                        } else {
                            params.ambient_light
                        };
                        if let Some(model_mesh) = project_model_instance(
                            &mt,
                            "lurek.raycaster.pickScreenFromAdapter",
                            &params,
                            cam_pos,
                            cam_target,
                            0,
                            0.0,
                            model_ambient,
                            &[],
                            &wall_at,
                        )? {
                            scene.models.push(model_mesh);
                        }
                    }
                }
                let st = this.state.borrow();
                let entity_pick =
                    scene.pick_entity_with_sprite_alpha_test(sx, sy, &|texture_key, u, v| {
                        texture_pick_is_opaque(&st.textures, texture_key, u, v)
                    });
                if let Some(entity_pick) = entity_pick.as_ref() {
                    if tile_pick
                        .as_ref()
                        .map(|tile_pick| entity_pick_precedes_tile(entity_pick, tile_pick))
                        .unwrap_or(true)
                    {
                        return Ok(LuaValue::Table(entity_pick_to_table(lua, entity_pick)?));
                    }
                }
                let Some(pick) = tile_pick else {
                    return Ok(LuaValue::Nil);
                };
                let tbl = pick_result_to_table(lua, &pick)?;
                match pick.surface {
                    PickSurface::Floor => {
                        if let Some(cell) = this
                            .lowered_floor_cells
                            .get(&(pick.grid_x as u32, pick.grid_y as u32))
                        {
                            /// @field | texture | integer | Raw lowered-floor texture id.
                            tbl.set("texture", cell.raw_id)?;
                        } else if let Some((_, raw_id)) = this
                            .floor_cell_textures
                            .get(&(pick.grid_x as u32, pick.grid_y as u32))
                        {
                            /// @field | texture | integer | Raw floor texture override id.
                            tbl.set("texture", *raw_id)?;
                        }
                    }
                    PickSurface::Ceiling => {
                        if let Some((_, raw_id)) = this
                            .ceiling_cell_textures
                            .get(&(pick.grid_x as u32, pick.grid_y as u32))
                        {
                            /// @field | texture | integer | Raw ceiling texture override id.
                            tbl.set("texture", *raw_id)?;
                        }
                    }
                    PickSurface::Wall => {}
                }
                /// @field | texture | integer | Raw surface texture id when available.
                Ok(LuaValue::Table(tbl))
            },
        );
        // -- buildScene --
        /// Builds a complete textured raycaster scene for GPU rendering. Stores the output internally.
        /// for the renderer to consume on the next frame. Returns the number of quads generated.
        /// @param | params | table | Scene params {px, py, angle, fov, rays, max_dist, screen_w, screen_h, ambient?, shade_dist?, floor_r/g/b?, ceiling_r/g/b?, camera_height?, horizon_offset?}.
        /// @param | lights | table? | Array of point-light tables {x, y, radius, r?, g?, b?, color?, intensity?, level?} or LPointLight userdata values.
        /// @param | sprites | table|LSpriteManager? | Array of sprite tables {x, y, texture?, size?, front_texture?, right_texture?, back_texture?, left_texture?, angle?} or an LSpriteManager with integer/LImage textures.
        /// @param | wallTextures | table? | Map of cell_value -> texture for wall surfaces.
        /// @return | integer | Total number of quads in the built scene.
        methods.add_method(
            "buildScene",
            |_,
             this,
             (params_tbl, lights_tbl, sprites_tbl, wall_tex_tbl): (
                LuaTable,
                LuaValue,
                LuaValue,
                LuaValue,
            )| {
                let params = parse_scene_build_params(&params_tbl, "lurek.raycaster.buildScene")?;
                let lights = parse_point_lights(lights_tbl, "lurek.raycaster.buildScene")?;
                let sprites = parse_world_sprites(sprites_tbl, "lurek.raycaster.buildScene")?;
                let wall_tex_map =
                    parse_wall_texture_map(wall_tex_tbl, "lurek.raycaster.buildScene")?;
                let scene = RaycasterScene::build(
                    &this.inner,
                    &params,
                    &lights,
                    &sprites,
                    &|cell_value| wall_tex_map.get(&cell_value).copied(),
                    &|x, y| this.floor_cell_textures.get(&(x, y)).map(|entry| entry.0),
                    &|x, y| this.ceiling_cell_textures.get(&(x, y)).map(|entry| entry.0),
                    &|x, y| {
                        this.lowered_floor_cells.get(&(x, y)).map(|cell| {
                            crate::raycaster::build_scene::LoweredFloorCell {
                                texture_key: cell.texture_key,
                                depth_offset: cell.depth_offset,
                                tint: cell.tint,
                                blocked: cell.blocked,
                            }
                        })
                    },
                );
                let quad_count = scene.quad_count();
                this.state.borrow_mut().raycaster_output = Some(scene);
                Ok(quad_count)
            },
        );
        // -- buildSceneFromAdapter --
        /// Builds a textured raycaster scene from a runtime scene adapter that may follow physics bodies.
        /// @param | params | table | Scene params (same as buildScene).
        /// @param | adapter | LSceneAdapter | Runtime scene adapter providing lights, sprites, and models.
        /// @param | wallTextures | table? | Map of cell_value -> texture for wall surfaces.
        /// @return | integer | Total number of quads in the built scene.
        methods.add_method(
            "buildSceneFromAdapter",
            |lua,
             this,
             (params_tbl, adapter_ud, wall_tex_tbl): (LuaTable, LuaAnyUserData, LuaValue)| {
                let params = parse_scene_build_params(
                    &params_tbl,
                    "lurek.raycaster.buildSceneFromAdapter",
                )?;
                let (lights_tbl, sprites_tbl, models_tbl) = scene_input_tables_from_adapter(
                    lua,
                    &adapter_ud,
                    "lurek.raycaster.buildSceneFromAdapter",
                )?;
                let lights = parse_point_lights(
                    LuaValue::Table(lights_tbl),
                    "lurek.raycaster.buildSceneFromAdapter",
                )?;
                let sprites = parse_world_sprites(
                    LuaValue::Table(sprites_tbl),
                    "lurek.raycaster.buildSceneFromAdapter",
                )?;
                let wall_tex_map = parse_wall_texture_map(
                    wall_tex_tbl,
                    "lurek.raycaster.buildSceneFromAdapter",
                )?;
                let mut scene = RaycasterScene::build(
                    &this.inner,
                    &params,
                    &lights,
                    &sprites,
                    &|cell_value| wall_tex_map.get(&cell_value).copied(),
                    &|x, y| this.floor_cell_textures.get(&(x, y)).map(|entry| entry.0),
                    &|x, y| this.ceiling_cell_textures.get(&(x, y)).map(|entry| entry.0),
                    &|x, y| {
                        this.lowered_floor_cells.get(&(x, y)).map(|cell| {
                            crate::raycaster::build_scene::LoweredFloorCell {
                                texture_key: cell.texture_key,
                                depth_offset: cell.depth_offset,
                                tint: cell.tint,
                                blocked: cell.blocked,
                            }
                        })
                    },
                );
                #[cfg(feature = "obj-loader")]
                {
                    let cam_pos =
                        Vec3::new(params.player_x, params.camera_height, params.player_y);
                    let cam_target = Vec3::new(
                        params.player_x + params.player_angle.cos(),
                        params.camera_height,
                        params.player_y + params.player_angle.sin(),
                    );
                    let wall_at = |cx: i32, cy: i32| -> bool {
                        cx < 0 || cy < 0 || this.inner.blocks_light_at(cx as u32, cy as u32)
                    };
                    for pair in models_tbl.sequence_values::<LuaTable>() {
                        let mt = pair?;
                        let model_cell_x = mt.get::<_, f32>("x")?.floor().max(0.0) as u32;
                        let model_cell_y = mt.get::<_, f32>("y")?.floor().max(0.0) as u32;
                        let model_ambient = if this
                            .ceiling_cell_textures
                            .contains_key(&(model_cell_x, model_cell_y))
                        {
                            params.ambient_light * params.roofed_ambient_factor
                        } else {
                            params.ambient_light
                        };
                        if let Some(model_mesh) = project_model_instance(
                            &mt,
                            "lurek.raycaster.buildSceneFromAdapter",
                            &params,
                            cam_pos,
                            cam_target,
                            0,
                            0.0,
                            model_ambient,
                            &lights,
                            &wall_at,
                        )? {
                            scene.models.push(model_mesh);
                        }
                    }
                }
                let quad_count = scene.quad_count();
                this.state.borrow_mut().raycaster_output = Some(scene);
                Ok(quad_count)
            },
        );
        // -- buildSceneWithModels --
        /// Builds a textured raycaster scene with additional 3D .obj model instances projected into the view.
        /// Extends buildScene with a models array for placing 3D props in the dungeon.
        /// @param | params | table | Scene params (same as buildScene).
        /// @param | lights | table? | Array of point-light tables or LPointLight userdata values.
        /// @param | sprites | table|LSpriteManager? | Array of sprite tables with billboard or 4-direction textures, or an LSpriteManager with integer/LImage textures.
        /// @param | wallTextures | table? | Map of cell_value -> texture.
        /// @param | models | table? | Array of model instance tables {model, x, y, rotation?, yaw?, z?, scale?}.
        /// @return | integer | Total number of quads in the built scene.
        methods.add_method(
            "buildSceneWithModels",
            |_,
             this,
             (params_tbl, lights_tbl, sprites_tbl, wall_tex_tbl, models_tbl): (
                LuaTable,
                LuaValue,
                LuaValue,
                LuaValue,
                LuaValue,
            )| {
                let params =
                    parse_scene_build_params(&params_tbl, "lurek.raycaster.buildSceneWithModels")?;
                let lights =
                    parse_point_lights(lights_tbl, "lurek.raycaster.buildSceneWithModels")?;
                let sprites =
                    parse_world_sprites(sprites_tbl, "lurek.raycaster.buildSceneWithModels")?;
                let wall_tex_map =
                    parse_wall_texture_map(wall_tex_tbl, "lurek.raycaster.buildSceneWithModels")?;
                let mut scene = RaycasterScene::build(
                    &this.inner,
                    &params,
                    &lights,
                    &sprites,
                    &|cell_value| wall_tex_map.get(&cell_value).copied(),
                    &|x, y| this.floor_cell_textures.get(&(x, y)).map(|entry| entry.0),
                    &|x, y| this.ceiling_cell_textures.get(&(x, y)).map(|entry| entry.0),
                    &|x, y| {
                        this.lowered_floor_cells.get(&(x, y)).map(|cell| {
                            crate::raycaster::build_scene::LoweredFloorCell {
                                texture_key: cell.texture_key,
                                depth_offset: cell.depth_offset,
                                tint: cell.tint,
                                blocked: cell.blocked,
                            }
                        })
                    },
                );
                if let LuaValue::Table(tbl) = models_tbl {
                    #[cfg(feature = "obj-loader")]
                    {
                        let cam_pos =
                            Vec3::new(params.player_x, params.camera_height, params.player_y);
                        let cam_target = Vec3::new(
                            params.player_x + params.player_angle.cos(),
                            params.camera_height,
                            params.player_y + params.player_angle.sin(),
                        );
                        for pair in tbl.sequence_values::<LuaTable>() {
                            let mt = pair?;
                            let model_cell_x = mt.get::<_, f32>("x")?.floor().max(0.0) as u32;
                            let model_cell_y = mt.get::<_, f32>("y")?.floor().max(0.0) as u32;
                            let model_ambient = if this
                                .ceiling_cell_textures
                                .contains_key(&(model_cell_x, model_cell_y))
                            {
                                params.ambient_light * params.roofed_ambient_factor
                            } else {
                                params.ambient_light
                            };
                            let wall_at = |cx: i32, cy: i32| -> bool {
                                cx < 0 || cy < 0 || this.inner.blocks_light_at(cx as u32, cy as u32)
                            };
                            if let Some(model_mesh) = project_model_instance(
                                &mt,
                                "lurek.raycaster.buildSceneWithModels",
                                &params,
                                cam_pos,
                                cam_target,
                                0,
                                0.0,
                                model_ambient,
                                &lights,
                                &wall_at,
                            )? {
                                scene.models.push(model_mesh);
                            }
                        }
                    }
                    #[cfg(not(feature = "obj-loader"))]
                    {
                        let _ = &tbl;
                    }
                }
                let quad_count = scene.quad_count();
                this.state.borrow_mut().raycaster_output = Some(scene);
                Ok(quad_count)
            },
        );
        // -- type --
        /// Returns the type name of this object ("LRaycaster").
        /// @return | string | Type name string.
        methods.add_method("type", |_, _, ()| Ok("LRaycaster"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to test against.
        /// @return | boolean | True if this object is of the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LRaycaster" || name == "LObject")
        });
    }
}

/// Lua-visible persistent multi-level raycaster world used for repeated build/pick calls.
pub struct LuaMultiLevelGrid {
    inner: Rc<RefCell<MultiLevelGrid>>,
    state: Rc<RefCell<SharedState>>,
}

impl LuaUserData for LuaMultiLevelGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setCell --
        /// Sets the wall type value at a grid cell on the active level. Non-zero values are solid walls.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | val | integer | Wall type (0 = empty, 1+ = wall texture index).
        methods.add_method_mut("setCell", |_, this, (x, y, val): (u32, u32, u32)| {
            let mut grid = this.inner.borrow_mut();
            let level =
                active_multilevel_level_mut(&mut grid, "lurek.raycaster.LMultiLevelGrid:setCell")?;
            level.set_wall(x as usize, y as usize, val);
            Ok(())
        });
        // -- getCell --
        /// Returns the wall type value at a grid cell on the active level.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | integer | Cell value (0 = empty, 1+ = wall type).
        methods.add_method("getCell", |_, this, (x, y): (u32, u32)| {
            let grid = this.inner.borrow();
            let level = active_multilevel_level(&grid, "lurek.raycaster.LMultiLevelGrid:getCell")?;
            Ok(level.get_wall(x as usize, y as usize))
        });
        // -- setHalfWallCell --
        /// Attaches a half-height wall feature to a blocking cell on the active level.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | height | number | Solid wall height from floor, 0.0..1.0.
        methods.add_method_mut(
            "setHalfWallCell",
            |_, this, (x, y, height): (u32, u32, f32)| {
                let mut grid = this.inner.borrow_mut();
                let level = active_multilevel_level_mut(
                    &mut grid,
                    "lurek.raycaster.LMultiLevelGrid:setHalfWallCell",
                )?;
                level.set_wall_feature(x as usize, y as usize, WallFeature::half_height(height));
                Ok(())
            },
        );
        // -- setWindowCell --
        /// Attaches a window feature to a blocking cell on the active level, leaving a visible opening between sill and lintel.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | sillHeight | number | Bottom of the opening from the floor, 0.0..1.0.
        /// @param | lintelHeight | number | Top of the opening from the floor, 0.0..1.0.
        /// @param | alpha | number? | Wall alpha multiplier for the solid bands.
        methods.add_method_mut(
            "setWindowCell",
            |_, this, (x, y, sill_height, lintel_height, alpha): (u32, u32, f32, f32, Option<f32>)| {
                let mut grid = this.inner.borrow_mut();
                let level = active_multilevel_level_mut(
                    &mut grid,
                    "lurek.raycaster.LMultiLevelGrid:setWindowCell",
                )?;
                level.set_wall_feature(
                    x as usize,
                    y as usize,
                    WallFeature::window(sill_height, lintel_height, alpha.unwrap_or(0.35)),
                );
                Ok(())
            },
        );
        // -- setDoorCell --
        /// Attaches a sliding door feature to a blocking cell on the active level.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | direction | string | "horizontal" or "vertical".
        /// @param | openAmount | number | Door open amount, 0.0..1.0.
        /// @param | alpha | number? | Optional alpha multiplier.
        methods.add_method_mut(
            "setDoorCell",
            |_, this, (x, y, dir_str, open_amount, alpha): (u32, u32, String, f32, Option<f32>)| {
                let dir = parse_door_direction(
                    "lurek.raycaster.LMultiLevelGrid:setDoorCell(direction)",
                    &dir_str,
                )?;
                let mut grid = this.inner.borrow_mut();
                let level = active_multilevel_level_mut(
                    &mut grid,
                    "lurek.raycaster.LMultiLevelGrid:setDoorCell",
                )?;
                level.set_wall_feature(
                    x as usize,
                    y as usize,
                    WallFeature::door(dir, open_amount, alpha.unwrap_or(1.0)),
                );
                Ok(())
            },
        );
        // -- clearWallFeatureCell --
        /// Removes any per-cell wall feature override from the active level.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        methods.add_method_mut("clearWallFeatureCell", |_, this, (x, y): (u32, u32)| {
            let mut grid = this.inner.borrow_mut();
            let level = active_multilevel_level_mut(
                &mut grid,
                "lurek.raycaster.LMultiLevelGrid:clearWallFeatureCell",
            )?;
            level.clear_wall_feature(x as usize, y as usize);
            Ok(())
        });
        // -- getWallFeatureCell --
        /// Returns the wall feature attached to an active-level cell, or nil when none is set.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | table | Feature table {kind, alpha, ...} or nil.
        /// @field | kind | string | "half", "window", or "door".
        /// @field | alpha | number | Feature alpha/transparency override.
        /// @field | height | number | Half-wall height in cell units when `kind == "half"`.
        /// @field | sill_height | number | Window sill height when `kind == "window"`.
        /// @field | lintel_height | number | Window lintel height when `kind == "window"`.
        /// @field | direction | string | "horizontal" or "vertical" when `kind == "door"`.
        /// @field | open_amount | number | Door openness in 0.0..1.0 when `kind == "door"`.
        methods.add_method("getWallFeatureCell", |lua, this, (x, y): (u32, u32)| {
            let grid = this.inner.borrow();
            let level = active_multilevel_level(
                &grid,
                "lurek.raycaster.LMultiLevelGrid:getWallFeatureCell",
            )?;
            let Some(feature) = level.wall_feature(x as usize, y as usize) else {
                return Ok(LuaValue::Nil);
            };
            Ok(LuaValue::Table(wall_feature_to_table(lua, feature)?))
        });
        // -- setFloorTexture --
        /// Sets the default floor texture used by the active level. Pass nil to clear it.
        /// @param | texture | LImage? | Texture image, integer id, or nil to clear.
        methods.add_method_mut("setFloorTexture", |_, this, texture: LuaValue| {
            let mut grid = this.inner.borrow_mut();
            let level = active_multilevel_level_mut(
                &mut grid,
                "lurek.raycaster.LMultiLevelGrid:setFloorTexture",
            )?;
            level.floor_texture = parse_texture_key_value(
                &texture,
                "lurek.raycaster.LMultiLevelGrid:setFloorTexture",
            )?
            .map(|(key, _)| key);
            Ok(())
        });
        // -- getFloorTexture --
        /// Returns the default floor texture id used by the active level, or nil when none is set.
        /// @return | integer | Raw texture id or nil.
        methods.add_method("getFloorTexture", |_, this, ()| {
            let grid = this.inner.borrow();
            let level =
                active_multilevel_level(&grid, "lurek.raycaster.LMultiLevelGrid:getFloorTexture")?;
            Ok(level.floor_texture.map(|texture| texture.data().as_ffi()))
        });
        // -- setFloorTextureCell --
        /// Assigns a per-cell floor texture override on the active level. Pass nil to remove the override.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | texture | LImage? | Texture image, integer id, or nil to clear.
        methods.add_method_mut(
            "setFloorTextureCell",
            |_, this, (x, y, texture): (u32, u32, LuaValue)| {
                let mut grid = this.inner.borrow_mut();
                let level = active_multilevel_level_mut(
                    &mut grid,
                    "lurek.raycaster.LMultiLevelGrid:setFloorTextureCell",
                )?;
                match parse_texture_key_value(
                    &texture,
                    "lurek.raycaster.LMultiLevelGrid:setFloorTextureCell",
                )? {
                    Some((key, _)) => level.set_floor_texture(x as usize, y as usize, key),
                    None => level.clear_floor_texture(x as usize, y as usize),
                }
                Ok(())
            },
        );
        // -- getFloorTextureCell --
        /// Returns the per-cell floor texture id assigned on the active level, or nil if none is set.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | integer | Raw texture id or nil.
        methods.add_method("getFloorTextureCell", |_, this, (x, y): (u32, u32)| {
            let grid = this.inner.borrow();
            let level = active_multilevel_level(
                &grid,
                "lurek.raycaster.LMultiLevelGrid:getFloorTextureCell",
            )?;
            if x as usize >= level.width || y as usize >= level.height {
                return Ok(None);
            }
            Ok(
                level.floor_cell_textures[y as usize * level.width + x as usize]
                    .map(|key| key.data().as_ffi()),
            )
        });
        // -- setCeilingTexture --
        /// Sets the default ceiling texture used by the active level. Pass nil to clear it.
        /// @param | texture | LImage? | Texture image, integer id, or nil to clear.
        methods.add_method_mut("setCeilingTexture", |_, this, texture: LuaValue| {
            let mut grid = this.inner.borrow_mut();
            let level = active_multilevel_level_mut(
                &mut grid,
                "lurek.raycaster.LMultiLevelGrid:setCeilingTexture",
            )?;
            level.ceiling_texture = parse_texture_key_value(
                &texture,
                "lurek.raycaster.LMultiLevelGrid:setCeilingTexture",
            )?
            .map(|(key, _)| key);
            Ok(())
        });
        // -- getCeilingTexture --
        /// Returns the default ceiling texture id used by the active level, or nil when none is set.
        /// @return | integer | Raw texture id or nil.
        methods.add_method("getCeilingTexture", |_, this, ()| {
            let grid = this.inner.borrow();
            let level = active_multilevel_level(
                &grid,
                "lurek.raycaster.LMultiLevelGrid:getCeilingTexture",
            )?;
            Ok(level.ceiling_texture.map(|texture| texture.data().as_ffi()))
        });
        // -- setCeilingTextureCell --
        /// Assigns a per-cell ceiling texture override on the active level. Pass nil to remove the override.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | texture | LImage? | Texture image, integer id, or nil to clear.
        methods.add_method_mut(
            "setCeilingTextureCell",
            |_, this, (x, y, texture): (u32, u32, LuaValue)| {
                let mut grid = this.inner.borrow_mut();
                let level = active_multilevel_level_mut(
                    &mut grid,
                    "lurek.raycaster.LMultiLevelGrid:setCeilingTextureCell",
                )?;
                match parse_texture_key_value(
                    &texture,
                    "lurek.raycaster.LMultiLevelGrid:setCeilingTextureCell",
                )? {
                    Some((key, _)) => level.set_ceiling_texture(x as usize, y as usize, key),
                    None => level.clear_ceiling_texture(x as usize, y as usize),
                }
                Ok(())
            },
        );
        // -- getCeilingTextureCell --
        /// Returns the per-cell ceiling texture id assigned on the active level, or nil if none is set.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | integer | Raw texture id or nil.
        methods.add_method("getCeilingTextureCell", |_, this, (x, y): (u32, u32)| {
            let grid = this.inner.borrow();
            let level = active_multilevel_level(
                &grid,
                "lurek.raycaster.LMultiLevelGrid:getCeilingTextureCell",
            )?;
            if x as usize >= level.width || y as usize >= level.height {
                return Ok(None);
            }
            Ok(
                level.ceiling_cell_textures[y as usize * level.width + x as usize]
                    .map(|key| key.data().as_ffi()),
            )
        });
        // -- setLoweredFloorCell --
        /// Marks an active-level cell as a lowered floor (pit) with its own texture, depth, tint, and blocking flag.
        /// Pass nil to remove the lowered-floor designation.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | opts | table? | Options table {texture, depth?, r?, g?, b?, blocked?} or nil to clear.
        methods.add_method_mut(
            "setLoweredFloorCell",
            |_, this, (x, y, opts): (u32, u32, LuaValue)| {
                let mut grid = this.inner.borrow_mut();
                let level = active_multilevel_level_mut(
                    &mut grid,
                    "lurek.raycaster.LMultiLevelGrid:setLoweredFloorCell",
                )?;
                match opts {
                    LuaValue::Nil => level.clear_lowered_floor(x as usize, y as usize),
                    LuaValue::Table(tbl) => {
                        let tex_val = tbl.get::<_, LuaValue>("texture")?;
                        let (texture_key, _) = parse_texture_key_value(
                            &tex_val,
                            "lurek.raycaster.LMultiLevelGrid:setLoweredFloorCell(texture)",
                        )?
                        .ok_or_else(|| {
                            LuaError::RuntimeError(
                                "lurek.raycaster.LMultiLevelGrid:setLoweredFloorCell: opts.texture cannot be nil"
                                    .to_string(),
                            )
                        })?;
                        level.set_lowered_floor(
                            x as usize,
                            y as usize,
                            crate::raycaster::build_scene::LoweredFloorCell {
                                texture_key,
                                depth_offset: tbl
                                    .get::<_, Option<f32>>("depth")?
                                    .unwrap_or(0.25)
                                    .clamp(0.0, 0.75),
                                tint: [
                                    tbl.get::<_, Option<f32>>("r")?
                                        .unwrap_or(1.0)
                                        .clamp(0.0, 1.0),
                                    tbl.get::<_, Option<f32>>("g")?
                                        .unwrap_or(1.0)
                                        .clamp(0.0, 1.0),
                                    tbl.get::<_, Option<f32>>("b")?
                                        .unwrap_or(1.0)
                                        .clamp(0.0, 1.0),
                                ],
                                blocked: tbl.get::<_, Option<bool>>("blocked")?.unwrap_or(true),
                            },
                        );
                    }
                    _ => {
                        return Err(LuaError::RuntimeError(
                            "lurek.raycaster.LMultiLevelGrid:setLoweredFloorCell: opts must be a table or nil"
                                .to_string(),
                        ));
                    }
                }
                Ok(())
            },
        );
        // -- getLoweredFloorCell --
        /// Returns the lowered-floor configuration at an active-level cell, or nil if the cell is normal.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | table | Table {texture, depth, r, g, b, blocked} or nil.
        methods.add_method("getLoweredFloorCell", |lua, this, (x, y): (u32, u32)| {
            let grid = this.inner.borrow();
            let level = active_multilevel_level(
                &grid,
                "lurek.raycaster.LMultiLevelGrid:getLoweredFloorCell",
            )?;
            let Some(cell) = level.lowered_floor(x as usize, y as usize) else {
                return Ok(LuaValue::Nil);
            };
            let tbl = lua.create_table()?;
            tbl.set("texture", cell.texture_key.data().as_ffi())?;
            tbl.set("depth", cell.depth_offset)?;
            tbl.set("r", cell.tint[0])?;
            tbl.set("g", cell.tint[1])?;
            tbl.set("b", cell.tint[2])?;
            tbl.set("blocked", cell.blocked)?;
            Ok(LuaValue::Table(tbl))
        });
        // -- setFloorHole --
        /// Sets whether an active-level cell is open to the level below.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | hole | boolean | True when the floor should be open at this cell.
        methods.add_method_mut("setFloorHole", |_, this, (x, y, hole): (u32, u32, bool)| {
            let mut grid = this.inner.borrow_mut();
            let level = active_multilevel_level_mut(
                &mut grid,
                "lurek.raycaster.LMultiLevelGrid:setFloorHole",
            )?;
            level.set_floor_hole(x as usize, y as usize, hole);
            Ok(())
        });
        // -- isFloorHole --
        /// Returns true when an active-level cell is open to the level below.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | boolean | True when the floor is open at this cell.
        methods.add_method("isFloorHole", |_, this, (x, y): (u32, u32)| {
            let grid = this.inner.borrow();
            let level =
                active_multilevel_level(&grid, "lurek.raycaster.LMultiLevelGrid:isFloorHole")?;
            Ok(level.is_floor_hole(x as usize, y as usize))
        });
        // -- setCeilingHole --
        /// Sets whether an active-level cell is open to the level above.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @param | hole | boolean | True when the ceiling should be open at this cell.
        methods.add_method_mut(
            "setCeilingHole",
            |_, this, (x, y, hole): (u32, u32, bool)| {
                let mut grid = this.inner.borrow_mut();
                let level = active_multilevel_level_mut(
                    &mut grid,
                    "lurek.raycaster.LMultiLevelGrid:setCeilingHole",
                )?;
                level.set_ceiling_hole(x as usize, y as usize, hole);
                Ok(())
            },
        );
        // -- isCeilingHole --
        /// Returns true when an active-level cell is open to the level above.
        /// @param | x | integer | Grid column.
        /// @param | y | integer | Grid row.
        /// @return | boolean | True when the ceiling is open at this cell.
        methods.add_method("isCeilingHole", |_, this, (x, y): (u32, u32)| {
            let grid = this.inner.borrow();
            let level =
                active_multilevel_level(&grid, "lurek.raycaster.LMultiLevelGrid:isCeilingHole")?;
            Ok(level.is_ceiling_hole(x as usize, y as usize))
        });
        // -- addLevel --
        /// Appends one level described with the same table format accepted by buildMultiLevelScene.
        /// @param | level | table | Level table {width, height, cells, floor_offset?, ceiling_height?, floor_holes?, ceiling_holes?, floor_texture?, ceiling_texture?, floor_cell_textures?, ceiling_cell_textures?, lowered_floor_cells?, wall_features?}.
        /// @return | integer | Zero-based level index of the appended level.
        methods.add_method_mut("addLevel", |_, this, level_tbl: LuaTable| {
            let next_index = this.inner.borrow().level_count();
            let level = parse_multilevel_level(
                &level_tbl,
                next_index,
                "lurek.raycaster.LMultiLevelGrid:addLevel",
            )?;
            this.inner.borrow_mut().add_level(level);
            Ok(next_index)
        });
        // -- levelCount --
        /// Returns the total number of stored levels.
        /// @return | integer | Level count.
        methods.add_method("levelCount", |_, this, ()| {
            Ok(this.inner.borrow().level_count())
        });
        // -- activeLevel --
        /// Returns the currently active level index used for stacked camera height.
        /// @return | integer | Active level index.
        methods.add_method("activeLevel", |_, this, ()| {
            Ok(this.inner.borrow().active_level())
        });
        // -- getFloorOffset --
        /// Returns the floor height offset of the active level in world units.
        /// @return | number | Active-level floor offset.
        methods.add_method("getFloorOffset", |_, this, ()| {
            let grid = this.inner.borrow();
            let level =
                active_multilevel_level(&grid, "lurek.raycaster.LMultiLevelGrid:getFloorOffset")?;
            Ok(level.floor_offset)
        });
        // -- setFloorOffset --
        /// Sets the floor height offset of the active level in world units.
        /// If needed, the active ceiling height is raised to preserve at least 0.1 units of headroom.
        /// @param | offset | number | New floor offset in world units.
        methods.add_method_mut("setFloorOffset", |_, this, offset: f32| {
            let mut grid = this.inner.borrow_mut();
            let level = active_multilevel_level_mut(
                &mut grid,
                "lurek.raycaster.LMultiLevelGrid:setFloorOffset",
            )?;
            level.floor_offset = offset;
            if level.ceiling_height < level.floor_offset + 0.1 {
                level.ceiling_height = level.floor_offset + 0.1;
            }
            Ok(())
        });
        // -- getCeilingHeight --
        /// Returns the ceiling height of the active level in world units.
        /// @return | number | Active-level ceiling height.
        methods.add_method("getCeilingHeight", |_, this, ()| {
            let grid = this.inner.borrow();
            let level =
                active_multilevel_level(&grid, "lurek.raycaster.LMultiLevelGrid:getCeilingHeight")?;
            Ok(level.ceiling_height)
        });
        // -- setCeilingHeight --
        /// Sets the ceiling height of the active level in world units.
        /// The value is clamped so it stays at least 0.1 units above the active floor offset.
        /// @param | height | number | New ceiling height in world units.
        methods.add_method_mut("setCeilingHeight", |_, this, height: f32| {
            let mut grid = this.inner.borrow_mut();
            let level = active_multilevel_level_mut(
                &mut grid,
                "lurek.raycaster.LMultiLevelGrid:setCeilingHeight",
            )?;
            level.ceiling_height = height.max(level.floor_offset + 0.1);
            Ok(())
        });
        // -- setActiveLevel --
        /// Sets the currently active level index used for stacked camera height.
        /// @param | level | integer | Zero-based active level index.
        methods.add_method_mut("setActiveLevel", |_, this, level: usize| {
            if level >= this.inner.borrow().level_count() {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.raycaster.LMultiLevelGrid:setActiveLevel: level {} is out of range for {} levels",
                    level,
                    this.inner.borrow().level_count()
                )));
            }
            this.inner.borrow_mut().set_active_level(level);
            Ok(())
        });
        // -- buildScene --
        /// Builds a textured multilevel raycaster scene from this persistent world and stores it for rendering.
        /// @param | params | table | Scene params for the current camera.
        /// @param | lights | table? | Array of point-light tables or LPointLight userdata values.
        /// @param | sprites | table|LSpriteManager? | Array of level sprite tables or an LSpriteManager.
        /// @param | wallTextures | table? | Map of cell_value -> texture for wall surfaces.
        /// @return | integer | Total number of quads in the built scene.
        methods.add_method(
            "buildScene",
            |_,
             this,
             (params_tbl, lights_tbl, sprites_tbl, wall_tex_tbl): (
                LuaTable,
                LuaValue,
                LuaValue,
                LuaValue,
            )| {
                let params = parse_scene_build_params(
                    &params_tbl,
                    "lurek.raycaster.LMultiLevelGrid:buildScene",
                )?;
                let lights =
                    parse_point_lights(lights_tbl, "lurek.raycaster.LMultiLevelGrid:buildScene")?;
                let active_level = this.inner.borrow().active_level();
                let sprites = parse_level_sprites(
                    sprites_tbl,
                    "lurek.raycaster.LMultiLevelGrid:buildScene",
                    active_level,
                )?;
                let wall_tex_map = parse_wall_texture_map(
                    wall_tex_tbl,
                    "lurek.raycaster.LMultiLevelGrid:buildScene",
                )?;
                let scene = RaycasterScene::build_multilevel(
                    &this.inner.borrow(),
                    &params,
                    &lights,
                    &sprites,
                    &|_, cell_value| wall_tex_map.get(&cell_value).copied(),
                    &|_, _, _| None,
                    &|_, _, _| None,
                    &|_, _, _| None,
                );
                let quad_count = scene.quad_count();
                this.state.borrow_mut().raycaster_output = Some(scene);
                Ok(quad_count)
            },
        );
        // -- buildSceneFromAdapter --
        /// Builds a textured multilevel raycaster scene from a runtime scene adapter that may follow physics bodies.
        /// @param | params | table | Scene params for the current camera.
        /// @param | adapter | LSceneAdapter | Runtime scene adapter providing lights, sprites, and models.
        /// @param | wallTextures | table? | Map of cell_value -> texture for wall surfaces.
        /// @return | integer | Total number of quads in the built scene.
        methods.add_method(
            "buildSceneFromAdapter",
            |lua,
             this,
             (params_tbl, adapter_ud, wall_tex_tbl): (LuaTable, LuaAnyUserData, LuaValue)| {
                let params = parse_scene_build_params(
                    &params_tbl,
                    "lurek.raycaster.LMultiLevelGrid:buildSceneFromAdapter",
                )?;
                let (lights_tbl, sprites_tbl, models_tbl) = scene_input_tables_from_adapter(
                    lua,
                    &adapter_ud,
                    "lurek.raycaster.LMultiLevelGrid:buildSceneFromAdapter",
                )?;
                let lights = parse_point_lights(
                    LuaValue::Table(lights_tbl),
                    "lurek.raycaster.LMultiLevelGrid:buildSceneFromAdapter",
                )?;
                let active_level = this.inner.borrow().active_level();
                let sprites = parse_level_sprites(
                    LuaValue::Table(sprites_tbl),
                    "lurek.raycaster.LMultiLevelGrid:buildSceneFromAdapter",
                    active_level,
                )?;
                let wall_tex_map = parse_wall_texture_map(
                    wall_tex_tbl,
                    "lurek.raycaster.LMultiLevelGrid:buildSceneFromAdapter",
                )?;
                let mut scene = RaycasterScene::build_multilevel(
                    &this.inner.borrow(),
                    &params,
                    &lights,
                    &sprites,
                    &|_, cell_value| wall_tex_map.get(&cell_value).copied(),
                    &|_, _, _| None,
                    &|_, _, _| None,
                    &|_, _, _| None,
                );
                #[cfg(feature = "obj-loader")]
                {
                    let grid = this.inner.borrow();
                    let eye = params.camera_height.clamp(0.1, 0.9);
                    let camera_world_z = grid
                        .get_active()
                        .map(|level| level.floor_offset + eye)
                        .unwrap_or(eye);
                    let cam_pos = Vec3::new(params.player_x, camera_world_z, params.player_y);
                    let cam_target = Vec3::new(
                        params.player_x + params.player_angle.cos(),
                        camera_world_z,
                        params.player_y + params.player_angle.sin(),
                    );
                    let models_by_level =
                        collect_model_tables_by_level(&models_tbl, active_level, grid.level_count())?;
                    let visible_levels = grid.visible_level_indices(
                        params.player_x,
                        params.player_y,
                        params.max_distance,
                    );
                    for level_index in visible_levels {
                        let level_models = &models_by_level[level_index];
                        let Some(level_result) = grid.with_runtime_level(
                            level_index,
                            |level, raycaster| -> LuaResult<Vec<ModelMesh>> {
                                let wall_at = |cx: i32, cy: i32| -> bool {
                                    cx < 0
                                        || cy < 0
                                        || raycaster.blocks_light_at(cx as u32, cy as u32)
                                };
                                let mut meshes = Vec::new();
                                for mt in level_models {
                                    let model_cell_x =
                                        mt.get::<_, f32>("x")?.floor().max(0.0) as usize;
                                    let model_cell_y =
                                        mt.get::<_, f32>("y")?.floor().max(0.0) as usize;
                                    let roofed = model_cell_x < level.width
                                        && model_cell_y < level.height
                                        && !level.is_ceiling_hole(model_cell_x, model_cell_y);
                                    let model_ambient = if roofed {
                                        params.ambient_light * params.roofed_ambient_factor
                                    } else {
                                        params.ambient_light
                                    };
                                    if let Some(model_mesh) = project_model_instance(
                                        mt,
                                        "lurek.raycaster.LMultiLevelGrid:buildSceneFromAdapter",
                                        &params,
                                        cam_pos,
                                        cam_target,
                                        level_index,
                                        level.floor_offset,
                                        model_ambient,
                                        &lights,
                                        &wall_at,
                                    )? {
                                        meshes.push(model_mesh);
                                    }
                                }
                                Ok(meshes)
                            },
                        ) else {
                            continue;
                        };
                        scene.models.extend(level_result?);
                    }
                }
                let quad_count = scene.quad_count();
                this.state.borrow_mut().raycaster_output = Some(scene);
                Ok(quad_count)
            },
        );
        // -- pickScreen --
        /// Resolves a screen-space click against this persistent multi-level world and returns the owning level.
        /// @param | sx | number | Screen X in pixels.
        /// @param | sy | number | Screen Y in pixels.
        /// @param | params | table | Camera params for the current frame.
        /// @param | wallTextures | table? | Optional map of cell_value -> texture for wall surfaces.
        /// @param | sprites | table|LSpriteManager? | Optional sprite tables or sprite manager used to resolve clickable billboard hits.
        /// @param | models | table? | Optional model instance tables used to resolve clickable projected model hits.
        /// @return | table | Pick result {x, y, level, surface, distance, hit_x, hit_y, u, v, cell_value?, side?, texture?, ray_angle, id?, wall_height?, feature?} or nil. `feature` mirrors `getWallFeatureCell()` and adds `section` for the solid band/panel that was hit.
        /// @field | wall_height | number | Local wall height in cell units for wall hits against partial-height features.
        /// @field | feature | table | Optional wall feature table mirroring `getWallFeatureCell()` plus `section` for the solid band or door panel that was hit.
        methods.add_method(
            "pickScreen",
            |lua,
             this,
             (sx, sy, params_tbl, wall_tex_tbl, sprites_tbl, models_tbl): (
                f32,
                f32,
                LuaTable,
                LuaValue,
                Option<LuaValue>,
                Option<LuaValue>,
            )| {
                let sprites_tbl = sprites_tbl.unwrap_or(LuaValue::Nil);
                let models_tbl = models_tbl.unwrap_or(LuaValue::Nil);
                let params = parse_scene_build_params(
                    &params_tbl,
                    "lurek.raycaster.LMultiLevelGrid:pickScreen",
                )?;
                let wall_tex_map = parse_wall_texture_map(
                    wall_tex_tbl,
                    "lurek.raycaster.LMultiLevelGrid:pickScreen",
                )?;
                let pick_params = ScreenPickParams {
                    player_x: params.player_x,
                    player_y: params.player_y,
                    player_angle: params.player_angle,
                    fov: params.fov,
                    screen_width: params.screen_width,
                    screen_height: params.screen_height,
                    camera_height: params.camera_height,
                    horizon_offset: params.horizon_offset,
                    max_distance: params.max_distance,
                };
                let tile_pick = this.inner.borrow().pick_screen(&pick_params, sx, sy);
                let active_level = this.inner.borrow().active_level();
                let entity_pick = if matches!(sprites_tbl, LuaValue::Nil)
                    && matches!(models_tbl, LuaValue::Nil)
                {
                    None
                } else {
                    let sprites = parse_level_sprites(
                        sprites_tbl,
                        "lurek.raycaster.LMultiLevelGrid:pickScreen",
                        active_level,
                    )?;
                    let grid = this.inner.borrow();
                    let mut scene = RaycasterScene::build_multilevel(
                        &grid,
                        &params,
                        &[],
                        &sprites,
                        &|_, _| None,
                        &|_, _, _| None,
                        &|_, _, _| None,
                        &|_, _, _| None,
                    );
                    if let LuaValue::Table(tbl) = models_tbl {
                        #[cfg(feature = "obj-loader")]
                        {
                            let eye = params.camera_height.clamp(0.1, 0.9);
                            let camera_world_z = grid
                                .get_active()
                                .map(|level| level.floor_offset + eye)
                                .unwrap_or(eye);
                            let cam_pos =
                                Vec3::new(params.player_x, camera_world_z, params.player_y);
                            let cam_target = Vec3::new(
                                params.player_x + params.player_angle.cos(),
                                camera_world_z,
                                params.player_y + params.player_angle.sin(),
                            );
                            let models_by_level = collect_model_tables_by_level(
                                &tbl,
                                active_level,
                                grid.level_count(),
                            )?;
                            let visible_levels = grid.visible_level_indices(
                                params.player_x,
                                params.player_y,
                                params.max_distance,
                            );
                            for level_index in visible_levels {
                                let level_models = &models_by_level[level_index];
                                let Some(level_result) = grid.with_runtime_level(
                                    level_index,
                                    |level, raycaster| -> LuaResult<Vec<ModelMesh>> {
                                        let wall_at = |cx: i32, cy: i32| -> bool {
                                            cx < 0
                                                || cy < 0
                                                || raycaster.blocks_light_at(cx as u32, cy as u32)
                                        };
                                        let mut meshes = Vec::new();
                                        for mt in level_models {
                                            let model_cell_x =
                                                mt.get::<_, f32>("x")?.floor().max(0.0) as usize;
                                            let model_cell_y =
                                                mt.get::<_, f32>("y")?.floor().max(0.0) as usize;
                                            let roofed = model_cell_x < level.width
                                                && model_cell_y < level.height
                                                && !level
                                                    .is_ceiling_hole(model_cell_x, model_cell_y);
                                            let model_ambient = if roofed {
                                                params.ambient_light * params.roofed_ambient_factor
                                            } else {
                                                params.ambient_light
                                            };
                                            if let Some(model_mesh) = project_model_instance(
                                                mt,
                                                "lurek.raycaster.LMultiLevelGrid:pickScreen",
                                                &params,
                                                cam_pos,
                                                cam_target,
                                                level_index,
                                                level.floor_offset,
                                                model_ambient,
                                                &[],
                                                &wall_at,
                                            )? {
                                                meshes.push(model_mesh);
                                            }
                                        }
                                        Ok(meshes)
                                    },
                                ) else {
                                    continue;
                                };
                                scene.models.extend(level_result?);
                            }
                        }
                        #[cfg(not(feature = "obj-loader"))]
                        {
                            let _ = &tbl;
                        }
                    }
                    let st = this.state.borrow();
                    scene.pick_entity_with_sprite_alpha_test(sx, sy, &|texture_key, u, v| {
                        texture_pick_is_opaque(&st.textures, texture_key, u, v)
                    })
                };
                if let Some(entity_pick) = entity_pick.as_ref() {
                    if tile_pick
                        .as_ref()
                        .map(|tile_pick| entity_pick_precedes_tile(entity_pick, tile_pick))
                        .unwrap_or(true)
                    {
                        return Ok(LuaValue::Table(entity_pick_to_table(lua, entity_pick)?));
                    }
                }
                let Some(pick) = tile_pick else {
                    return Ok(LuaValue::Nil);
                };
                let tbl = pick_result_to_table(lua, &pick)?;
                if let Some(level) = this.inner.borrow().get_level(pick.level_index) {
                    match pick.surface {
                        PickSurface::Floor => {
                            if let Some(cell) = level.lowered_floor(pick.grid_x, pick.grid_y) {
                                /// Texture id for the picked lowered floor cell.
                                tbl.set("texture", cell.texture_key.data().as_ffi())?;
                            } else if let Some(texture) =
                                level.floor_texture_at(pick.grid_x, pick.grid_y)
                            {
                                /// Texture id for the picked floor surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                        PickSurface::Ceiling => {
                            if let Some(texture) =
                                level.ceiling_texture_at(pick.grid_x, pick.grid_y)
                            {
                                /// Texture id for the picked ceiling surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                        PickSurface::Wall => {
                            if let Some(texture) = wall_tex_map.get(&pick.cell_value) {
                                /// Texture id for the picked wall surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                    }
                }
                Ok(LuaValue::Table(tbl))
            },
        );
        // -- pickScreenFromAdapter --
        /// Resolves a screen-space click against this multilevel world using a runtime scene adapter.
        /// @param | sx | number | Screen X in pixels.
        /// @param | sy | number | Screen Y in pixels.
        /// @param | params | table | Camera params for the current frame.
        /// @param | wallTextures | table? | Optional map of cell_value -> texture for wall surfaces.
        /// @param | adapter | LSceneAdapter | Runtime scene adapter providing sprites and models.
        /// @return | table | Pick result or nil when nothing was hit. Wall hits may also include `wall_height` plus `feature = {kind, section, ...}` for half walls, windows, and doors.
        methods.add_method(
            "pickScreenFromAdapter",
            |lua,
             this,
             (sx, sy, params_tbl, wall_tex_tbl, adapter_ud): (
                f32,
                f32,
                LuaTable,
                LuaValue,
                LuaAnyUserData,
            )| {
                let params = parse_scene_build_params(
                    &params_tbl,
                    "lurek.raycaster.LMultiLevelGrid:pickScreenFromAdapter",
                )?;
                let wall_tex_map = parse_wall_texture_map(
                    wall_tex_tbl,
                    "lurek.raycaster.LMultiLevelGrid:pickScreenFromAdapter",
                )?;
                let (_lights_tbl, sprites_tbl, models_tbl) = scene_input_tables_from_adapter(
                    lua,
                    &adapter_ud,
                    "lurek.raycaster.LMultiLevelGrid:pickScreenFromAdapter",
                )?;
                let pick_params = ScreenPickParams {
                    player_x: params.player_x,
                    player_y: params.player_y,
                    player_angle: params.player_angle,
                    fov: params.fov,
                    screen_width: params.screen_width,
                    screen_height: params.screen_height,
                    camera_height: params.camera_height,
                    horizon_offset: params.horizon_offset,
                    max_distance: params.max_distance,
                };
                let tile_pick = this.inner.borrow().pick_screen(&pick_params, sx, sy);
                let active_level = this.inner.borrow().active_level();
                let sprites = parse_level_sprites(
                    LuaValue::Table(sprites_tbl),
                    "lurek.raycaster.LMultiLevelGrid:pickScreenFromAdapter",
                    active_level,
                )?;
                let grid = this.inner.borrow();
                let mut scene = RaycasterScene::build_multilevel(
                    &grid,
                    &params,
                    &[],
                    &sprites,
                    &|_, _| None,
                    &|_, _, _| None,
                    &|_, _, _| None,
                    &|_, _, _| None,
                );
                #[cfg(feature = "obj-loader")]
                {
                    let eye = params.camera_height.clamp(0.1, 0.9);
                    let camera_world_z = grid
                        .get_active()
                        .map(|level| level.floor_offset + eye)
                        .unwrap_or(eye);
                    let cam_pos = Vec3::new(params.player_x, camera_world_z, params.player_y);
                    let cam_target = Vec3::new(
                        params.player_x + params.player_angle.cos(),
                        camera_world_z,
                        params.player_y + params.player_angle.sin(),
                    );
                    let models_by_level = collect_model_tables_by_level(
                        &models_tbl,
                        active_level,
                        grid.level_count(),
                    )?;
                    let visible_levels = grid.visible_level_indices(
                        params.player_x,
                        params.player_y,
                        params.max_distance,
                    );
                    for level_index in visible_levels {
                        let level_models = &models_by_level[level_index];
                        let Some(level_result) = grid.with_runtime_level(
                            level_index,
                            |level, raycaster| -> LuaResult<Vec<ModelMesh>> {
                                let wall_at = |cx: i32, cy: i32| -> bool {
                                    cx < 0
                                        || cy < 0
                                        || raycaster.blocks_light_at(cx as u32, cy as u32)
                                };
                                let mut meshes = Vec::new();
                                for mt in level_models {
                                    let model_cell_x =
                                        mt.get::<_, f32>("x")?.floor().max(0.0) as usize;
                                    let model_cell_y =
                                        mt.get::<_, f32>("y")?.floor().max(0.0) as usize;
                                    let roofed = model_cell_x < level.width
                                        && model_cell_y < level.height
                                        && !level.is_ceiling_hole(model_cell_x, model_cell_y);
                                    let model_ambient = if roofed {
                                        params.ambient_light * params.roofed_ambient_factor
                                    } else {
                                        params.ambient_light
                                    };
                                    if let Some(model_mesh) = project_model_instance(
                                        mt,
                                        "lurek.raycaster.LMultiLevelGrid:pickScreenFromAdapter",
                                        &params,
                                        cam_pos,
                                        cam_target,
                                        level_index,
                                        level.floor_offset,
                                        model_ambient,
                                        &[],
                                        &wall_at,
                                    )? {
                                        meshes.push(model_mesh);
                                    }
                                }
                                Ok(meshes)
                            },
                        ) else {
                            continue;
                        };
                        scene.models.extend(level_result?);
                    }
                }
                let st = this.state.borrow();
                let entity_pick =
                    scene.pick_entity_with_sprite_alpha_test(sx, sy, &|texture_key, u, v| {
                        texture_pick_is_opaque(&st.textures, texture_key, u, v)
                    });
                if let Some(entity_pick) = entity_pick.as_ref() {
                    if tile_pick
                        .as_ref()
                        .map(|tile_pick| entity_pick_precedes_tile(entity_pick, tile_pick))
                        .unwrap_or(true)
                    {
                        return Ok(LuaValue::Table(entity_pick_to_table(lua, entity_pick)?));
                    }
                }
                let Some(pick) = tile_pick else {
                    return Ok(LuaValue::Nil);
                };
                let tbl = pick_result_to_table(lua, &pick)?;
                if let Some(level) = this.inner.borrow().get_level(pick.level_index) {
                    match pick.surface {
                        PickSurface::Floor => {
                            if let Some(cell) = level.lowered_floor(pick.grid_x, pick.grid_y) {
                                /// Texture id for the picked lowered floor cell.
                                tbl.set("texture", cell.texture_key.data().as_ffi())?;
                            } else if let Some(texture) =
                                level.floor_texture_at(pick.grid_x, pick.grid_y)
                            {
                                /// Texture id for the picked floor surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                        PickSurface::Ceiling => {
                            if let Some(texture) =
                                level.ceiling_texture_at(pick.grid_x, pick.grid_y)
                            {
                                /// Texture id for the picked ceiling surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                        PickSurface::Wall => {
                            if let Some(texture) = wall_tex_map.get(&pick.cell_value) {
                                /// Texture id for the picked wall surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                    }
                }
                Ok(LuaValue::Table(tbl))
            },
        );
        // -- type --
        /// Returns the type name of this object ("LMultiLevelGrid").
        /// @return | string | Type name string.
        methods.add_method("type", |_, _, ()| Ok("LMultiLevelGrid"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to test against.
        /// @return | boolean | True if this object is of the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LMultiLevelGrid" || name == "LObject")
        });
    }
}

/// Lua-visible sprite manager that tracks world-space billboard sprites for sorting and projection.
pub struct LuaSpriteManager {
    inner: SpriteManager,
    sprite_textures: HashMap<u32, LuaManagedSpriteTextures>,
}

impl LuaSpriteManager {
    fn scene_world_sprite_for(
        &self,
        sprite: &crate::raycaster::sprite_manager::WorldSprite,
        texture_info: &LuaManagedSpriteTextures,
        level_index: usize,
        api_name: &str,
    ) -> LuaResult<WorldSprite> {
        let directional_textures = texture_info
            .directional_textures
            .as_ref()
            .map(|textures| -> LuaResult<DirectionalSpriteTextures> {
                Ok(DirectionalSpriteTextures {
                    front: textures
                        .front
                        .scene_key(api_name, sprite.id, "front texture")?,
                    right: textures
                        .right
                        .scene_key(api_name, sprite.id, "right texture")?,
                    back: textures
                        .back
                        .scene_key(api_name, sprite.id, "back texture")?,
                    left: textures
                        .left
                        .scene_key(api_name, sprite.id, "left texture")?,
                    facing_angle: sprite
                        .directional_textures
                        .as_ref()
                        .map(|textures| textures.facing_angle)
                        .unwrap_or(0.0),
                })
            })
            .transpose()?;
        let texture_key = if let Some(textures) = &directional_textures {
            textures.front
        } else {
            texture_info
                .texture
                .scene_key(api_name, sprite.id, "texture")?
        };
        Ok(WorldSprite {
            entity_id: Some(sprite.id),
            level_index,
            world_x: sprite.x,
            world_y: sprite.y,
            texture_key,
            directional_textures,
            size: sprite.scale,
        })
    }

    fn scene_world_sprites(&self, api_name: &str) -> LuaResult<Vec<WorldSprite>> {
        let mut sprites = Vec::new();
        for sprite in self.inner.sprites().iter().filter(|sprite| sprite.visible) {
            let Some(texture_info) = self.sprite_textures.get(&sprite.id) else {
                return Err(LuaError::RuntimeError(format!(
                    "{}: sprite manager metadata missing for sprite {}",
                    api_name, sprite.id
                )));
            };
            sprites.push(self.scene_world_sprite_for(
                sprite,
                texture_info,
                texture_info.level_index.unwrap_or(0),
                api_name,
            )?);
        }
        Ok(sprites)
    }

    fn scene_level_sprites(
        &self,
        api_name: &str,
        default_level: usize,
    ) -> LuaResult<Vec<LevelSprite>> {
        let mut sprites = Vec::new();
        for sprite in self.inner.sprites().iter().filter(|sprite| sprite.visible) {
            let Some(texture_info) = self.sprite_textures.get(&sprite.id) else {
                return Err(LuaError::RuntimeError(format!(
                    "{}: sprite manager metadata missing for sprite {}",
                    api_name, sprite.id
                )));
            };
            let level_index = texture_info.level_index.unwrap_or(default_level);
            sprites.push(LevelSprite {
                level_index,
                sprite: self.scene_world_sprite_for(sprite, texture_info, level_index, api_name)?,
            });
        }
        Ok(sprites)
    }
}

fn parse_scene_adapter_texture(
    value: &LuaValue,
    api_name: &str,
    field_name: &str,
) -> LuaResult<TextureKey> {
    parse_texture_key_value(value, &format!("{}({})", api_name, field_name))?
        .map(|(key, _)| key)
        .ok_or_else(|| {
            LuaError::RuntimeError(format!(
                "{}: {} cannot be nil; expected integer texture id or LImage",
                api_name, field_name
            ))
        })
}

fn parse_scene_transform_from_body(
    body_ud: &LuaAnyUserData,
    opts: Option<&LuaTable>,
    api_name: &str,
) -> LuaResult<SceneTransform> {
    let body = body_ud.borrow::<LuaBody>().map_err(|_| {
        LuaError::RuntimeError(format!(
            "{}: body must be LBody userdata from lurek.physics.newBody()/world:newBody()",
            api_name
        ))
    })?;
    let offset_x = match opts {
        Some(opts) => table_opt_f32(opts, "offset_x")?.unwrap_or(0.0),
        None => 0.0,
    };
    let offset_y = match opts {
        Some(opts) => table_opt_f32(opts, "offset_y")?.unwrap_or(0.0),
        None => 0.0,
    };
    let angle_offset = match opts {
        Some(opts) => table_opt_f32(opts, "angle_offset")?
            .or(table_opt_f32(opts, "yaw_offset")?)
            .unwrap_or(0.0),
        None => 0.0,
    };
    Ok(SceneTransform::body(
        body.world_handle(),
        body.body_id(),
        offset_x,
        offset_y,
        angle_offset,
    ))
}

fn scene_input_tables_from_adapter<'lua>(
    lua: &'lua Lua,
    adapter_ud: &LuaAnyUserData,
    api_name: &str,
) -> LuaResult<(LuaTable<'lua>, LuaTable<'lua>, LuaTable<'lua>)> {
    let adapter = adapter_ud
        .borrow::<LuaRaycasterSceneAdapter>()
        .map_err(|_| {
            LuaError::RuntimeError(format!(
                "{}: adapter must be LSceneAdapter from lurek.raycaster.newSceneAdapter()",
                api_name
            ))
        })?;
    let inputs = adapter.scene_inputs(lua)?;
    Ok((
        inputs.get::<_, LuaTable>("lights")?,
        inputs.get::<_, LuaTable>("sprites")?,
        inputs.get::<_, LuaTable>("models")?,
    ))
}

/// Lua-visible adapter that snapshots sprites, lights, and models from static data and physics bodies.
pub struct LuaRaycasterSceneAdapter {
    state: Rc<RefCell<SharedState>>,
    inner: SceneAdapter,
}

impl LuaRaycasterSceneAdapter {
    fn scene_inputs<'lua>(&self, lua: &'lua Lua) -> LuaResult<LuaTable<'lua>> {
        let result = lua.create_table()?;

        let sprites_tbl = lua.create_table()?;
        for (idx, sprite) in self.inner.resolve_sprites().into_iter().enumerate() {
            let entry = lua.create_table()?;
            entry.set("x", sprite.world_x)?;
            entry.set("y", sprite.world_y)?;
            entry.set("size", sprite.size)?;
            entry.set("level", sprite.level_index)?;
            if let Some(entity_id) = sprite.entity_id {
                entry.set("id", entity_id)?;
            }
            if let Some(textures) = sprite.directional_textures {
                entry.set("front_texture", textures.front.data().as_ffi())?;
                entry.set("right_texture", textures.right.data().as_ffi())?;
                entry.set("back_texture", textures.back.data().as_ffi())?;
                entry.set("left_texture", textures.left.data().as_ffi())?;
                entry.set("angle", textures.facing_angle)?;
            } else {
                entry.set("texture", sprite.texture_key.data().as_ffi())?;
            }
            sprites_tbl.set(idx + 1, entry)?;
        }
        result.set("sprites", sprites_tbl)?;

        let lights_tbl = lua.create_table()?;
        for (idx, light) in self.inner.resolve_lights().into_iter().enumerate() {
            let entry = lua.create_table()?;
            entry.set("x", light.x)?;
            entry.set("y", light.y)?;
            entry.set("radius", light.radius)?;
            entry.set("intensity", light.intensity)?;
            entry.set("color", lua.create_sequence_from(light.color)?)?;
            if let Some(level_index) = light.level_index {
                entry.set("level", level_index)?;
            }
            lights_tbl.set(idx + 1, entry)?;
        }
        result.set("lights", lights_tbl)?;

        let models_tbl = lua.create_table()?;
        #[cfg(feature = "obj-loader")]
        for (idx, model) in self.inner.resolve_models().into_iter().enumerate() {
            let entry = lua.create_table()?;
            let model_ud = lua.create_userdata(LuaObjModel {
                state: self.state.clone(),
                model: model.model,
                sprite_cache: HashMap::new(),
            })?;
            entry.set("model", model_ud)?;
            entry.set("x", model.world_x)?;
            entry.set("y", model.world_y)?;
            entry.set("yaw", model.yaw)?;
            entry.set("z", model.z_offset)?;
            entry.set("scale", model.scale)?;
            entry.set("level", model.level_index)?;
            if let Some(entity_id) = model.entity_id {
                entry.set("id", entity_id)?;
            }
            models_tbl.set(idx + 1, entry)?;
        }
        result.set("models", models_tbl)?;

        Ok(result)
    }
}

impl LuaUserData for LuaRaycasterSceneAdapter {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addSprite --
        /// Adds a static billboard sprite entry.
        /// @param | x | number | World X position.
        /// @param | y | number | World Y position.
        /// @param | texture | LImage|integer | Sprite texture.
        /// @param | opts | table? | Optional {size?, id?, level?, angle?}.
        methods.add_method_mut(
            "addSprite",
            |_, this, (x, y, texture, opts): (f32, f32, LuaValue, Option<LuaTable>)| {
                let texture_key = parse_scene_adapter_texture(
                    &texture,
                    "lurek.raycaster.LSceneAdapter:addSprite",
                    "texture",
                )?;
                let size = match opts.as_ref() {
                    Some(opts) => table_opt_f32(opts, "size")?.unwrap_or(1.0),
                    None => 1.0,
                };
                let entity_id = match opts.as_ref() {
                    Some(opts) => opts.get::<_, Option<u32>>("id")?,
                    None => None,
                };
                let level_index = match opts.as_ref() {
                    Some(opts) => table_opt_usize(opts, "level")?.unwrap_or(0),
                    None => 0,
                };
                let angle = match opts.as_ref() {
                    Some(opts) => table_opt_f32(opts, "angle")?.unwrap_or(0.0),
                    None => 0.0,
                };
                this.inner.add_sprite(SceneAdapterSprite {
                    entity_id,
                    level_index,
                    transform: SceneTransform::static_xy(x, y, angle),
                    texture_key,
                    directional_textures: None,
                    size,
                });
                Ok(())
            },
        );
        // -- addDirectionalSprite --
        /// Adds a static directional billboard sprite entry.
        /// @param | x | number | World X position.
        /// @param | y | number | World Y position.
        /// @param | front | LImage|integer | Front-facing texture.
        /// @param | right | LImage|integer | Right-facing texture.
        /// @param | back | LImage|integer | Back-facing texture.
        /// @param | left | LImage|integer? | Left-facing texture (defaults to `right`).
        /// @param | opts | table? | Optional {size?, id?, level?, angle?}.
        methods.add_method_mut(
            "addDirectionalSprite",
            |_,
             this,
             (x, y, front, right, back, left, opts): (
                f32,
                f32,
                LuaValue,
                LuaValue,
                LuaValue,
                Option<LuaValue>,
                Option<LuaTable>,
            )| {
                let front_key = parse_scene_adapter_texture(
                    &front,
                    "lurek.raycaster.LSceneAdapter:addDirectionalSprite",
                    "front",
                )?;
                let right_key = parse_scene_adapter_texture(
                    &right,
                    "lurek.raycaster.LSceneAdapter:addDirectionalSprite",
                    "right",
                )?;
                let back_key = parse_scene_adapter_texture(
                    &back,
                    "lurek.raycaster.LSceneAdapter:addDirectionalSprite",
                    "back",
                )?;
                let left_key = match left.as_ref() {
                    Some(value) => parse_scene_adapter_texture(
                        value,
                        "lurek.raycaster.LSceneAdapter:addDirectionalSprite",
                        "left",
                    )?,
                    None => right_key,
                };
                let size = match opts.as_ref() {
                    Some(opts) => table_opt_f32(opts, "size")?.unwrap_or(1.0),
                    None => 1.0,
                };
                let entity_id = match opts.as_ref() {
                    Some(opts) => opts.get::<_, Option<u32>>("id")?,
                    None => None,
                };
                let level_index = match opts.as_ref() {
                    Some(opts) => table_opt_usize(opts, "level")?.unwrap_or(0),
                    None => 0,
                };
                let angle = match opts.as_ref() {
                    Some(opts) => table_opt_f32(opts, "angle")?.unwrap_or(0.0),
                    None => 0.0,
                };
                this.inner.add_sprite(SceneAdapterSprite {
                    entity_id,
                    level_index,
                    transform: SceneTransform::static_xy(x, y, angle),
                    texture_key: front_key,
                    directional_textures: Some(DirectionalSpriteTextures {
                        front: front_key,
                        right: right_key,
                        back: back_key,
                        left: left_key,
                        facing_angle: angle,
                    }),
                    size,
                });
                Ok(())
            },
        );
        // -- bindBodySprite --
        /// Binds a billboard sprite to a live physics body.
        /// @param | body | LBody | Physics body handle.
        /// @param | texture | LImage|integer | Sprite texture.
        /// @param | opts | table? | Optional {size?, id?, level?, offset_x?, offset_y?, angle_offset?}.
        methods.add_method_mut(
            "bindBodySprite",
            |_, this, (body, texture, opts): (LuaAnyUserData, LuaValue, Option<LuaTable>)| {
                let texture_key = parse_scene_adapter_texture(
                    &texture,
                    "lurek.raycaster.LSceneAdapter:bindBodySprite",
                    "texture",
                )?;
                let size = match opts.as_ref() {
                    Some(opts) => table_opt_f32(opts, "size")?.unwrap_or(1.0),
                    None => 1.0,
                };
                let entity_id = match opts.as_ref() {
                    Some(opts) => opts.get::<_, Option<u32>>("id")?,
                    None => None,
                };
                let level_index = match opts.as_ref() {
                    Some(opts) => table_opt_usize(opts, "level")?.unwrap_or(0),
                    None => 0,
                };
                this.inner.add_sprite(SceneAdapterSprite {
                    entity_id,
                    level_index,
                    transform: parse_scene_transform_from_body(
                        &body,
                        opts.as_ref(),
                        "lurek.raycaster.LSceneAdapter:bindBodySprite",
                    )?,
                    texture_key,
                    directional_textures: None,
                    size,
                });
                Ok(())
            },
        );
        // -- bindBodyDirectionalSprite --
        /// Binds a directional billboard sprite to a live physics body.
        /// @param | body | LBody | Physics body handle.
        /// @param | front | LImage|integer | Front-facing texture.
        /// @param | right | LImage|integer | Right-facing texture.
        /// @param | back | LImage|integer | Back-facing texture.
        /// @param | left | LImage|integer? | Left-facing texture (defaults to `right`).
        /// @param | opts | table? | Optional {size?, id?, level?, offset_x?, offset_y?, angle_offset?}.
        methods.add_method_mut(
            "bindBodyDirectionalSprite",
            |_,
             this,
             (body, front, right, back, left, opts): (
                LuaAnyUserData,
                LuaValue,
                LuaValue,
                LuaValue,
                Option<LuaValue>,
                Option<LuaTable>,
            )| {
                let front_key = parse_scene_adapter_texture(
                    &front,
                    "lurek.raycaster.LSceneAdapter:bindBodyDirectionalSprite",
                    "front",
                )?;
                let right_key = parse_scene_adapter_texture(
                    &right,
                    "lurek.raycaster.LSceneAdapter:bindBodyDirectionalSprite",
                    "right",
                )?;
                let back_key = parse_scene_adapter_texture(
                    &back,
                    "lurek.raycaster.LSceneAdapter:bindBodyDirectionalSprite",
                    "back",
                )?;
                let left_key = match left.as_ref() {
                    Some(value) => parse_scene_adapter_texture(
                        value,
                        "lurek.raycaster.LSceneAdapter:bindBodyDirectionalSprite",
                        "left",
                    )?,
                    None => right_key,
                };
                let size = match opts.as_ref() {
                    Some(opts) => table_opt_f32(opts, "size")?.unwrap_or(1.0),
                    None => 1.0,
                };
                let entity_id = match opts.as_ref() {
                    Some(opts) => opts.get::<_, Option<u32>>("id")?,
                    None => None,
                };
                let level_index = match opts.as_ref() {
                    Some(opts) => table_opt_usize(opts, "level")?.unwrap_or(0),
                    None => 0,
                };
                let transform = parse_scene_transform_from_body(
                    &body,
                    opts.as_ref(),
                    "lurek.raycaster.LSceneAdapter:bindBodyDirectionalSprite",
                )?;
                let facing_angle = transform.resolve().map(|value| value.angle).unwrap_or(0.0);
                this.inner.add_sprite(SceneAdapterSprite {
                    entity_id,
                    level_index,
                    transform,
                    texture_key: front_key,
                    directional_textures: Some(DirectionalSpriteTextures {
                        front: front_key,
                        right: right_key,
                        back: back_key,
                        left: left_key,
                        facing_angle,
                    }),
                    size,
                });
                Ok(())
            },
        );
        // -- addLight --
        /// Adds a static point light entry.
        /// @param | x | number | World X position.
        /// @param | y | number | World Y position.
        /// @param | radius | number | Light falloff radius.
        /// @param | opts | table? | Optional {intensity?, color?, r?, g?, b?, level?}.
        methods.add_method_mut(
            "addLight",
            |_, this, (x, y, radius, opts): (f32, f32, f32, Option<LuaTable>)| {
                let color = match opts.as_ref() {
                    Some(opts) => parse_point_light_color(opts)?,
                    None => [1.0, 1.0, 1.0],
                };
                let intensity = match opts.as_ref() {
                    Some(opts) => table_opt_f32(opts, "intensity")?.unwrap_or(1.0),
                    None => 1.0,
                };
                let level_index = match opts.as_ref() {
                    Some(opts) => table_opt_usize(opts, "level")?,
                    None => None,
                };
                this.inner.add_light(SceneAdapterLight {
                    transform: SceneTransform::static_xy(x, y, 0.0),
                    level_index,
                    radius: radius.max(0.0),
                    color,
                    intensity,
                });
                Ok(())
            },
        );
        // -- bindBodyLight --
        /// Binds a point light to a live physics body.
        /// @param | body | LBody | Physics body handle.
        /// @param | radius | number | Light falloff radius.
        /// @param | opts | table? | Optional {intensity?, color?, r?, g?, b?, level?, offset_x?, offset_y?}.
        methods.add_method_mut(
            "bindBodyLight",
            |_, this, (body, radius, opts): (LuaAnyUserData, f32, Option<LuaTable>)| {
                let color = match opts.as_ref() {
                    Some(opts) => parse_point_light_color(opts)?,
                    None => [1.0, 1.0, 1.0],
                };
                let intensity = match opts.as_ref() {
                    Some(opts) => table_opt_f32(opts, "intensity")?.unwrap_or(1.0),
                    None => 1.0,
                };
                let level_index = match opts.as_ref() {
                    Some(opts) => table_opt_usize(opts, "level")?,
                    None => None,
                };
                this.inner.add_light(SceneAdapterLight {
                    transform: parse_scene_transform_from_body(
                        &body,
                        opts.as_ref(),
                        "lurek.raycaster.LSceneAdapter:bindBodyLight",
                    )?,
                    level_index,
                    radius: radius.max(0.0),
                    color,
                    intensity,
                });
                Ok(())
            },
        );
        #[cfg(feature = "obj-loader")]
        {
            // -- addModel --
            /// Adds a static OBJ model instance entry.
            /// @param | model | LObjModel | OBJ model handle.
            /// @param | x | number | World X position.
            /// @param | y | number | World Y position.
            /// @param | opts | table? | Optional {id?, level?, yaw?, z?, scale?}.
            methods.add_method_mut(
                "addModel",
                |_, this, (model_ud, x, y, opts): (LuaAnyUserData, f32, f32, Option<LuaTable>)| {
                    let model_ref = model_ud.borrow::<LuaObjModel>().map_err(|_| {
                        LuaError::RuntimeError(
                            "lurek.raycaster.LSceneAdapter:addModel: model must be LuaObjModel"
                                .into(),
                        )
                    })?;
                    let entity_id = match opts.as_ref() {
                        Some(opts) => opts.get::<_, Option<u32>>("id")?,
                        None => None,
                    };
                    let level_index = match opts.as_ref() {
                        Some(opts) => table_opt_usize(opts, "level")?.unwrap_or(0),
                        None => 0,
                    };
                    let yaw = match opts.as_ref() {
                        Some(opts) => table_opt_f32(opts, "yaw")?
                            .or(table_opt_f32(opts, "angle")?)
                            .unwrap_or(0.0),
                        None => 0.0,
                    };
                    let z_offset = match opts.as_ref() {
                        Some(opts) => table_opt_f32(opts, "z")?.unwrap_or(0.0),
                        None => 0.0,
                    };
                    let scale = match opts.as_ref() {
                        Some(opts) => table_opt_f32(opts, "scale")?.unwrap_or(1.0),
                        None => 1.0,
                    };
                    this.inner.add_model(SceneAdapterModel {
                        model: model_ref.model.clone(),
                        entity_id,
                        level_index,
                        transform: SceneTransform::static_xy(x, y, yaw),
                        z_offset,
                        scale,
                    });
                    Ok(())
                },
            );
            // -- bindBodyModel --
            /// Binds an OBJ model instance to a live physics body.
            /// @param | body | LBody | Physics body handle.
            /// @param | model | LObjModel | OBJ model handle.
            /// @param | opts | table? | Optional {id?, level?, yaw_offset?, offset_x?, offset_y?, z?, scale?}.
            methods.add_method_mut(
                "bindBodyModel",
                |_, this, (body, model_ud, opts): (LuaAnyUserData, LuaAnyUserData, Option<LuaTable>)| {
                    let model_ref = model_ud.borrow::<LuaObjModel>().map_err(|_| {
                        LuaError::RuntimeError(
                            "lurek.raycaster.LSceneAdapter:bindBodyModel: model must be LuaObjModel"
                                .into(),
                        )
                    })?;
                    let entity_id = match opts.as_ref() {
                        Some(opts) => opts.get::<_, Option<u32>>("id")?,
                        None => None,
                    };
                    let level_index = match opts.as_ref() {
                        Some(opts) => table_opt_usize(opts, "level")?.unwrap_or(0),
                        None => 0,
                    };
                    let z_offset = match opts.as_ref() {
                        Some(opts) => table_opt_f32(opts, "z")?.unwrap_or(0.0),
                        None => 0.0,
                    };
                    let scale = match opts.as_ref() {
                        Some(opts) => table_opt_f32(opts, "scale")?.unwrap_or(1.0),
                        None => 1.0,
                    };
                    this.inner.add_model(SceneAdapterModel {
                        model: model_ref.model.clone(),
                        entity_id,
                        level_index,
                        transform: parse_scene_transform_from_body(
                            &body,
                            opts.as_ref(),
                            "lurek.raycaster.LSceneAdapter:bindBodyModel",
                        )?,
                        z_offset,
                        scale,
                    });
                    Ok(())
                },
            );
        }
        // -- sceneInputs --
        /// Resolves the current runtime snapshot into `{ lights, sprites, models }` tables.
        /// @return | table | Snapshot table for build/pick calls.
        methods.add_method("sceneInputs", |lua, this, ()| this.scene_inputs(lua));
        // -- clear --
        /// Removes every tracked entry from the adapter.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.clear();
            Ok(())
        });
        // -- clearSprites --
        /// Removes every tracked sprite entry from the adapter.
        methods.add_method_mut("clearSprites", |_, this, ()| {
            this.inner.clear_sprites();
            Ok(())
        });
        // -- clearLights --
        /// Removes every tracked light entry from the adapter.
        methods.add_method_mut("clearLights", |_, this, ()| {
            this.inner.clear_lights();
            Ok(())
        });
        #[cfg(feature = "obj-loader")]
        /// Clears models.
        ///
        methods.add_method_mut("clearModels", |_, this, ()| {
            this.inner.clear_models();
            Ok(())
        });
        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always "LSceneAdapter".
        methods.add_method("type", |_, _, ()| Ok("LSceneAdapter"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the name matches this userdata type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSceneAdapter" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaSpriteManager {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- add --
        /// Adds a new sprite to the manager at a world position with a texture label, raw id, or image handle.
        /// @param | x | number | World X position.
        /// @param | y | number | World Y position.
        /// @param | texture | any | Texture asset label, integer texture id, or LImage.
        /// @param | scale | number? | Sprite size multiplier (default 1.0).
        /// @param | level | integer? | Optional multilevel slice index used by buildMultiLevelScene.
        /// @return | integer | Unique sprite id for later manipulation.
        methods.add_method_mut(
            "add",
            |_,
             this,
             (x, y, texture, scale, level): (
                f32,
                f32,
                LuaValue,
                Option<f32>,
                Option<usize>,
            )| {
                let texture = parse_managed_texture_value(
                    texture,
                    "lurek.raycaster.LSpriteManager.add(texture)",
                )?;
                let id = this
                    .inner
                    .add(x, y, &texture.display_label(), scale.unwrap_or(1.0));
                this.sprite_textures.insert(
                    id,
                    LuaManagedSpriteTextures {
                        texture,
                        directional_textures: None,
                        level_index: level,
                    },
                );
                Ok(id)
            },
        );
        // -- addDirectional --
        /// Adds a new sprite with front/right/back/left textures and a world-facing angle.
        /// @param | x | number | World X position.
        /// @param | y | number | World Y position.
        /// @param | front | any | Texture shown when viewed from the front.
        /// @param | right | any | Texture shown from the right side.
        /// @param | back | any | Texture shown from behind.
        /// @param | left | any? | Texture shown from the left side (defaults to `right`).
        /// @param | angle | number? | World-space facing angle in radians (default 0.0).
        /// @param | scale | number? | Sprite size multiplier (default 1.0).
        /// @param | level | integer? | Optional multilevel slice index used by buildMultiLevelScene.
        /// @return | integer | Unique sprite id for later manipulation.
        methods.add_method_mut(
            "addDirectional",
            |_,
             this,
             (x, y, front, right, back, left, angle, scale, level): LuaDirectionalSpriteArgs<
                '_,
            >| {
                let front = parse_managed_texture_value(
                    front,
                    "lurek.raycaster.LSpriteManager.addDirectional(front)",
                )?;
                let right = parse_managed_texture_value(
                    right,
                    "lurek.raycaster.LSpriteManager.addDirectional(right)",
                )?;
                let back = parse_managed_texture_value(
                    back,
                    "lurek.raycaster.LSpriteManager.addDirectional(back)",
                )?;
                let left = match left {
                    Some(value) => parse_managed_texture_value(
                        value,
                        "lurek.raycaster.LSpriteManager.addDirectional(left)",
                    )?,
                    None => right.clone(),
                };
                let id = this.inner.add_directional(
                    x,
                    y,
                    &front.display_label(),
                    &right.display_label(),
                    &back.display_label(),
                    &left.display_label(),
                    angle.unwrap_or(0.0),
                    scale.unwrap_or(1.0),
                );
                this.sprite_textures.insert(
                    id,
                    LuaManagedSpriteTextures {
                        texture: front.clone(),
                        directional_textures: Some(LuaManagedDirectionalTextures {
                            front,
                            right,
                            back,
                            left,
                        }),
                        level_index: level,
                    },
                );
                Ok(id)
            },
        );
        // -- remove --
        /// Removes a sprite by its id. This method is available to Lua scripts.
        /// @param | id | integer | Sprite id returned by add().
        methods.add_method_mut("remove", |_, this, id: u32| {
            this.inner.remove(id);
            this.sprite_textures.remove(&id);
            Ok(())
        });
        // -- setPosition --
        /// Updates the world position of an existing sprite.
        /// @param | id | integer | Sprite id.
        /// @param | x | number | New world X.
        /// @param | y | number | New world Y.
        methods.add_method_mut("setPosition", |_, this, (id, x, y): (u32, f32, f32)| {
            this.inner.set_position(id, x, y);
            Ok(())
        });
        // -- setLevel --
        /// Updates the multilevel slice index for an existing sprite.
        /// @param | id | integer | Sprite id.
        /// @param | level | integer | New level index used by buildMultiLevelScene.
        methods.add_method_mut("setLevel", |_, this, (id, level): (u32, usize)| {
            if let Some(meta) = this.sprite_textures.get_mut(&id) {
                meta.level_index = Some(level);
            }
            Ok(())
        });
        // -- setFacing --
        /// Updates the facing angle of an existing directional sprite.
        /// @param | id | integer | Sprite id.
        /// @param | angle | number | New facing angle in radians.
        methods.add_method_mut("setFacing", |_, this, (id, angle): (u32, f32)| {
            this.inner.set_facing(id, angle);
            Ok(())
        });
        // -- setDirectionalTextures --
        /// Replaces the directional bitmap set for an existing sprite and optionally updates its facing angle.
        /// @param | id | integer | Sprite id.
        /// @param | front | any | Texture shown when viewed from the front.
        /// @param | right | any | Texture shown from the right side.
        /// @param | back | any | Texture shown from behind.
        /// @param | left | any? | Texture shown from the left side (defaults to `right`).
        /// @param | angle | number? | Optional new facing angle in radians.
        methods.add_method_mut(
            "setDirectionalTextures",
            |_,
             this,
             (id, front, right, back, left, angle): (
                u32,
                LuaValue,
                LuaValue,
                LuaValue,
                Option<LuaValue>,
                Option<f32>,
            )| {
                let front = parse_managed_texture_value(
                    front,
                    "lurek.raycaster.LSpriteManager.setDirectionalTextures(front)",
                )?;
                let right = parse_managed_texture_value(
                    right,
                    "lurek.raycaster.LSpriteManager.setDirectionalTextures(right)",
                )?;
                let back = parse_managed_texture_value(
                    back,
                    "lurek.raycaster.LSpriteManager.setDirectionalTextures(back)",
                )?;
                let left = match left {
                    Some(value) => parse_managed_texture_value(
                        value,
                        "lurek.raycaster.LSpriteManager.setDirectionalTextures(left)",
                    )?,
                    None => right.clone(),
                };
                this.inner.set_directional_textures(
                    id,
                    &front.display_label(),
                    &right.display_label(),
                    &back.display_label(),
                    &left.display_label(),
                    angle,
                );
                if this.inner.sprites().iter().any(|sprite| sprite.id == id) {
                    let level_index = this
                        .sprite_textures
                        .get(&id)
                        .and_then(|meta| meta.level_index);
                    this.sprite_textures.insert(
                        id,
                        LuaManagedSpriteTextures {
                            texture: front.clone(),
                            directional_textures: Some(LuaManagedDirectionalTextures {
                                front,
                                right,
                                back,
                                left,
                            }),
                            level_index,
                        },
                    );
                }
                Ok(())
            },
        );
        // -- setVisible --
        /// Shows or hides a sprite without removing it.
        /// @param | id | integer | Sprite id.
        /// @param | visible | boolean | Whether the sprite should be rendered.
        methods.add_method_mut("setVisible", |_, this, (id, visible): (u32, bool)| {
            this.inner.set_visible(id, visible);
            Ok(())
        });
        // -- clear --
        /// Removes all sprites from the manager.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.clear();
            this.sprite_textures.clear();
            Ok(())
        });
        // -- sortAndProject --
        /// Sorts all visible sprites by distance from the camera and returns projection data.
        /// @param | camX | number | Camera X position.
        /// @param | camY | number | Camera Y position.
        /// @param | camAngle | number | Camera facing angle (reserved for future projection expansion).
        /// @return | integer[] | Array of {id, x, y, level?, texture?, texture_id?, scale, distance, variant?, facing_angle?} sorted back-to-front.
        methods.add_method(
            "sortAndProject",
            |lua, this, (cam_x, cam_y, _cam_angle): (f32, f32, f32)| {
                let sorted = this.inner.sort_by_distance(cam_x, cam_y);
                let tbl = lua.create_table()?;
                for (i, s) in sorted.iter().enumerate() {
                    let dx = s.x - cam_x;
                    let dy = s.y - cam_y;
                    let dist = (dx * dx + dy * dy).sqrt();
                    let selected_texture = this
                        .sprite_textures
                        .get(&s.id)
                        .map(|meta| {
                            if let Some(textures) = &s.directional_textures {
                                let (_, variant) =
                                    textures.select_for_viewer(cam_x, cam_y, s.x, s.y);
                                let selected = meta
                                    .directional_textures
                                    .as_ref()
                                    .map(|managed| managed.by_variant(variant).clone())
                                    .unwrap_or_else(|| meta.texture.clone());
                                (selected, Some(variant))
                            } else {
                                (meta.texture.clone(), None)
                            }
                        })
                        .unwrap_or_else(|| (LuaManagedTextureRef::Label(s.texture.clone()), None));
                    let (texture, variant, facing_angle) =
                        if let Some(textures) = &s.directional_textures {
                            let variant = match selected_texture.1 {
                            Some(
                                crate::raycaster::sprite_manager::DirectionalSpriteVariant::Front,
                            ) => "front",
                            Some(
                                crate::raycaster::sprite_manager::DirectionalSpriteVariant::Right,
                            ) => "right",
                            Some(
                                crate::raycaster::sprite_manager::DirectionalSpriteVariant::Back,
                            ) => "back",
                            Some(
                                crate::raycaster::sprite_manager::DirectionalSpriteVariant::Left,
                            ) => "left",
                            None => "front",
                        };
                            (
                                selected_texture.0,
                                Some(variant),
                                Some(textures.facing_angle),
                            )
                        } else {
                            (selected_texture.0, None, None)
                        };
                    let entry = lua.create_table()?;
                    /// The 'id' field value exposed to Lua scripts.
                    entry.set("id", s.id)?;
                    /// The 'x' field value exposed to Lua scripts.
                    entry.set("x", s.x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    entry.set("y", s.y)?;
                    if let Some(level_index) = this
                        .sprite_textures
                        .get(&s.id)
                        .and_then(|meta| meta.level_index)
                    {
                        entry.set("level", level_index)?;
                    }
                    match texture {
                        LuaManagedTextureRef::Label(texture) => {
                            /// Performs the 'texture' operation.
                            entry.set("texture", texture)?;
                        }
                        LuaManagedTextureRef::Handle { raw_id, .. } => {
                            entry.set("texture_id", raw_id)?;
                        }
                    }
                    /// Performs the 'scale' operation.
                    entry.set("scale", s.scale)?;
                    /// Performs the 'distance' operation.
                    entry.set("distance", dist)?;
                    if let Some(variant) = variant {
                        entry.set("variant", variant)?;
                    }
                    if let Some(facing_angle) = facing_angle {
                        entry.set("facing_angle", facing_angle)?;
                    }
                    tbl.set(i + 1, entry)?;
                }
                Ok(tbl)
            },
        );
        // -- type --
        /// Returns the type name of this object ("LSpriteManager").
        /// @return | string | Type name string.
        methods.add_method("type", |_, _, ()| Ok("LSpriteManager"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to test against.
        /// @return | boolean | True if this object is of the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSpriteManager" || name == "LObject")
        });
    }
}
/// Registers the `lurek.raycaster` module table and all its factory functions into Lua.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // -- new --
    /// Creates a new raycaster map with the given grid dimensions.
    /// @param | w | integer | Map width in cells.
    /// @param | h | integer | Map height in cells.
    /// @return | LRaycaster | A new raycaster map instance.
    let s = state.clone();
    tbl.set(
        "new",
        lua.create_function(move |_, (w, h): (u32, u32)| {
            Ok(LuaRaycaster {
                inner: Raycaster2D::new(w, h),
                state: s.clone(),
                floor_cell_textures: HashMap::new(),
                ceiling_cell_textures: HashMap::new(),
                lowered_floor_cells: HashMap::new(),
            })
        })?,
    )?;
    // -- newMap --
    /// Creates a new raycaster map (alias for `new`).
    /// @param | w | integer | Map width in cells.
    /// @param | h | integer | Map height in cells.
    /// @return | LRaycaster | A new raycaster map instance.
    let s = state.clone();
    tbl.set(
        "newMap",
        lua.create_function(move |_, (w, h): (u32, u32)| {
            Ok(LuaRaycaster {
                inner: Raycaster2D::new(w, h),
                state: s.clone(),
                floor_cell_textures: HashMap::new(),
                ceiling_cell_textures: HashMap::new(),
                lowered_floor_cells: HashMap::new(),
            })
        })?,
    )?;
    // -- newMultiLevelGrid --
    /// Creates a persistent multi-level raycaster world from plain Lua level tables or as an empty container.
    /// @param | levels | table|LMultiLevelGrid? | Optional array of level tables or another LMultiLevelGrid to clone.
    /// @return | LMultiLevelGrid | Persistent multi-level world handle.
    let s = state.clone();
    tbl.set(
        "newMultiLevelGrid",
        lua.create_function(move |_, (levels,): (LuaValue,)| {
            Ok(LuaMultiLevelGrid {
                inner: Rc::new(RefCell::new(parse_multilevel_grid_value(
                    levels,
                    "lurek.raycaster.newMultiLevelGrid",
                )?)),
                state: s.clone(),
            })
        })?,
    )?;
    // -- pickScreenMultiLevel --
    /// Resolves a screen-space click against a stack of plain Lua level tables and returns the owning level.
    /// @param | sx | number | Screen X in pixels.
    /// @param | sy | number | Screen Y in pixels.
    /// @param | params | table | Camera params plus optional active_level.
    /// @param | levels | table|LMultiLevelGrid | Array of level tables or a persistent LMultiLevelGrid.
    /// @param | wallTextures | table? | Optional map of cell_value -> texture for wall surfaces.
    /// @param | sprites | table|LSpriteManager? | Optional sprite tables or sprite manager used to resolve clickable billboard hits.
    /// @param | models | table? | Optional model instance tables used to resolve clickable projected model hits.
    /// @return | table | Pick result {x, y, level, surface, distance, hit_x, hit_y, u, v, cell_value?, side?, texture?, ray_angle, id?, wall_height?, feature?} or nil. `feature` mirrors the owning wall-feature descriptor and adds `section` for the solid band/panel that was hit.
    let pick_multilevel_state = state.clone();
    tbl.set(
        "pickScreenMultiLevel",
        lua.create_function(
            move |lua,
                  (sx, sy, params_tbl, levels_value, wall_tex_tbl, sprites_tbl, models_tbl): (
                f32,
                f32,
                LuaTable,
                LuaValue,
                LuaValue,
                Option<LuaValue>,
                Option<LuaValue>,
            )| {
                let sprites_tbl = sprites_tbl.unwrap_or(LuaValue::Nil);
                let models_tbl = models_tbl.unwrap_or(LuaValue::Nil);
                let params =
                    parse_scene_build_params(&params_tbl, "lurek.raycaster.pickScreenMultiLevel")?;
                let active_level = parse_active_level(&params_tbl)?;
                let wall_tex_map = parse_wall_texture_map(
                    wall_tex_tbl,
                    "lurek.raycaster.pickScreenMultiLevel",
                )?;
                let mut grid = parse_multilevel_grid_value(
                    levels_value,
                    "lurek.raycaster.pickScreenMultiLevel",
                )?;
                if active_level >= grid.level_count() {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.raycaster.pickScreenMultiLevel: active_level {} is out of range for {} levels",
                        active_level,
                        grid.level_count()
                    )));
                }
                grid.set_active_level(active_level);
                let pick_params = ScreenPickParams {
                    player_x: params.player_x,
                    player_y: params.player_y,
                    player_angle: params.player_angle,
                    fov: params.fov,
                    screen_width: params.screen_width,
                    screen_height: params.screen_height,
                    camera_height: params.camera_height,
                    horizon_offset: params.horizon_offset,
                    max_distance: params.max_distance,
                };
                let tile_pick = grid.pick_screen(&pick_params, sx, sy);
                let entity_pick = if matches!(sprites_tbl, LuaValue::Nil)
                    && matches!(models_tbl, LuaValue::Nil)
                {
                    None
                } else {
                    let sprites = parse_level_sprites(
                        sprites_tbl,
                        "lurek.raycaster.pickScreenMultiLevel",
                        active_level,
                    )?;
                    let mut scene = RaycasterScene::build_multilevel(
                        &grid,
                        &params,
                        &[],
                        &sprites,
                        &|_, _| None,
                        &|_, _, _| None,
                        &|_, _, _| None,
                        &|_, _, _| None,
                    );
                    if let LuaValue::Table(tbl) = models_tbl {
                        #[cfg(feature = "obj-loader")]
                        {
                            let eye = params.camera_height.clamp(0.1, 0.9);
                            let camera_world_z = grid
                                .get_active()
                                .map(|level| level.floor_offset + eye)
                                .unwrap_or(eye);
                            let cam_pos = Vec3::new(params.player_x, camera_world_z, params.player_y);
                            let cam_target = Vec3::new(
                                params.player_x + params.player_angle.cos(),
                                camera_world_z,
                                params.player_y + params.player_angle.sin(),
                            );
                            let models_by_level =
                                collect_model_tables_by_level(&tbl, active_level, grid.level_count())?;
                            let visible_levels = grid.visible_level_indices(
                                params.player_x,
                                params.player_y,
                                params.max_distance,
                            );
                            for level_index in visible_levels {
                                let level_models = &models_by_level[level_index];
                                let Some(level_result) = grid.with_runtime_level(
                                    level_index,
                                    |level, raycaster| -> LuaResult<Vec<ModelMesh>> {
                                        let wall_at = |cx: i32, cy: i32| -> bool {
                                            cx < 0
                                                || cy < 0
                                                || raycaster.blocks_light_at(cx as u32, cy as u32)
                                        };
                                        let mut meshes = Vec::new();
                                        for mt in level_models {
                                            let model_cell_x =
                                                mt.get::<_, f32>("x")?.floor().max(0.0) as usize;
                                            let model_cell_y =
                                                mt.get::<_, f32>("y")?.floor().max(0.0) as usize;
                                            let roofed = model_cell_x < level.width
                                                && model_cell_y < level.height
                                                && !level.is_ceiling_hole(model_cell_x, model_cell_y);
                                            let model_ambient = if roofed {
                                                params.ambient_light * params.roofed_ambient_factor
                                            } else {
                                                params.ambient_light
                                            };
                                            if let Some(model_mesh) = project_model_instance(
                                                mt,
                                                "lurek.raycaster.pickScreenMultiLevel",
                                                &params,
                                                cam_pos,
                                                cam_target,
                                                level_index,
                                                level.floor_offset,
                                                model_ambient,
                                                &[],
                                                &wall_at,
                                            )? {
                                                meshes.push(model_mesh);
                                            }
                                        }
                                        Ok(meshes)
                                    },
                                ) else {
                                    continue;
                                };
                                scene.models.extend(level_result?);
                            }
                        }
                        #[cfg(not(feature = "obj-loader"))]
                        {
                            let _ = &tbl;
                        }
                    }
                    let st = pick_multilevel_state.borrow();
                    scene.pick_entity_with_sprite_alpha_test(sx, sy, &|texture_key, u, v| {
                        texture_pick_is_opaque(&st.textures, texture_key, u, v)
                    })
                };
                if let Some(entity_pick) = entity_pick.as_ref() {
                    if tile_pick
                        .as_ref()
                        .map(|tile_pick| entity_pick_precedes_tile(entity_pick, tile_pick))
                        .unwrap_or(true)
                    {
                        return Ok(LuaValue::Table(entity_pick_to_table(lua, entity_pick)?));
                    }
                }
                let Some(pick) = tile_pick else {
                    return Ok(LuaValue::Nil);
                };
                let tbl = pick_result_to_table(lua, &pick)?;
                if let Some(level) = grid.get_level(pick.level_index) {
                    match pick.surface {
                        PickSurface::Floor => {
                            if let Some(cell) = level.lowered_floor(pick.grid_x, pick.grid_y) {
                                /// Texture id for the picked lowered floor cell.
                                tbl.set("texture", cell.texture_key.data().as_ffi())?;
                            } else if let Some(texture) =
                                level.floor_texture_at(pick.grid_x, pick.grid_y)
                            {
                                /// Texture id for the picked floor surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                        PickSurface::Ceiling => {
                            if let Some(texture) =
                                level.ceiling_texture_at(pick.grid_x, pick.grid_y)
                            {
                                /// Texture id for the picked ceiling surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                        PickSurface::Wall => {
                            if let Some(texture) = wall_tex_map.get(&pick.cell_value) {
                                /// Texture id for the picked wall surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                    }
                }
                Ok(LuaValue::Table(tbl))
            },
        )?,
    )?;
    // -- pickScreenMultiLevelFromAdapter --
    /// Resolves a screen-space click against a stack of plain Lua level tables using a runtime scene adapter.
    /// @param | sx | number | Screen X in pixels.
    /// @param | sy | number | Screen Y in pixels.
    /// @param | params | table | Camera params plus optional active_level.
    /// @param | levels | table|LMultiLevelGrid | Array of level tables or a persistent LMultiLevelGrid.
    /// @param | wallTextures | table? | Optional map of cell_value -> texture for wall surfaces.
    /// @param | adapter | LSceneAdapter | Runtime scene adapter providing sprites and models.
    /// @return | table | Pick result {x, y, level, surface, distance, hit_x, hit_y, u, v, cell_value?, side?, texture?, ray_angle, id?, wall_height?, feature?} or nil. `feature` mirrors the owning wall-feature descriptor and adds `section` for the solid band/panel that was hit.
    let pick_multilevel_adapter_state = state.clone();
    tbl.set(
        "pickScreenMultiLevelFromAdapter",
        lua.create_function(
            move |lua,
                  (sx, sy, params_tbl, levels_value, wall_tex_tbl, adapter_ud): (
                f32,
                f32,
                LuaTable,
                LuaValue,
                LuaValue,
                LuaAnyUserData,
            )| {
                let params = parse_scene_build_params(
                    &params_tbl,
                    "lurek.raycaster.pickScreenMultiLevelFromAdapter",
                )?;
                let active_level = parse_active_level(&params_tbl)?;
                let wall_tex_map = parse_wall_texture_map(
                    wall_tex_tbl,
                    "lurek.raycaster.pickScreenMultiLevelFromAdapter",
                )?;
                let (_lights_tbl, sprites_tbl, models_tbl) = scene_input_tables_from_adapter(
                    lua,
                    &adapter_ud,
                    "lurek.raycaster.pickScreenMultiLevelFromAdapter",
                )?;
                let mut grid = parse_multilevel_grid_value(
                    levels_value,
                    "lurek.raycaster.pickScreenMultiLevelFromAdapter",
                )?;
                if active_level >= grid.level_count() {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.raycaster.pickScreenMultiLevelFromAdapter: active_level {} is out of range for {} levels",
                        active_level,
                        grid.level_count()
                    )));
                }
                grid.set_active_level(active_level);
                let pick_params = ScreenPickParams {
                    player_x: params.player_x,
                    player_y: params.player_y,
                    player_angle: params.player_angle,
                    fov: params.fov,
                    screen_width: params.screen_width,
                    screen_height: params.screen_height,
                    camera_height: params.camera_height,
                    horizon_offset: params.horizon_offset,
                    max_distance: params.max_distance,
                };
                let tile_pick = grid.pick_screen(&pick_params, sx, sy);
                let sprites = parse_level_sprites(
                    LuaValue::Table(sprites_tbl),
                    "lurek.raycaster.pickScreenMultiLevelFromAdapter",
                    active_level,
                )?;
                let mut scene = RaycasterScene::build_multilevel(
                    &grid,
                    &params,
                    &[],
                    &sprites,
                    &|_, _| None,
                    &|_, _, _| None,
                    &|_, _, _| None,
                    &|_, _, _| None,
                );
                #[cfg(feature = "obj-loader")]
                {
                    let eye = params.camera_height.clamp(0.1, 0.9);
                    let camera_world_z = grid
                        .get_active()
                        .map(|level| level.floor_offset + eye)
                        .unwrap_or(eye);
                    let cam_pos = Vec3::new(params.player_x, camera_world_z, params.player_y);
                    let cam_target = Vec3::new(
                        params.player_x + params.player_angle.cos(),
                        camera_world_z,
                        params.player_y + params.player_angle.sin(),
                    );
                    let models_by_level =
                        collect_model_tables_by_level(&models_tbl, active_level, grid.level_count())?;
                    let visible_levels = grid.visible_level_indices(
                        params.player_x,
                        params.player_y,
                        params.max_distance,
                    );
                    for level_index in visible_levels {
                        let level_models = &models_by_level[level_index];
                        let Some(level_result) = grid.with_runtime_level(
                            level_index,
                            |level, raycaster| -> LuaResult<Vec<ModelMesh>> {
                                let wall_at = |cx: i32, cy: i32| -> bool {
                                    cx < 0
                                        || cy < 0
                                        || raycaster.blocks_light_at(cx as u32, cy as u32)
                                };
                                let mut meshes = Vec::new();
                                for mt in level_models {
                                    let model_cell_x =
                                        mt.get::<_, f32>("x")?.floor().max(0.0) as usize;
                                    let model_cell_y =
                                        mt.get::<_, f32>("y")?.floor().max(0.0) as usize;
                                    let roofed = model_cell_x < level.width
                                        && model_cell_y < level.height
                                        && !level.is_ceiling_hole(model_cell_x, model_cell_y);
                                    let model_ambient = if roofed {
                                        params.ambient_light * params.roofed_ambient_factor
                                    } else {
                                        params.ambient_light
                                    };
                                    if let Some(model_mesh) = project_model_instance(
                                        mt,
                                        "lurek.raycaster.pickScreenMultiLevelFromAdapter",
                                        &params,
                                        cam_pos,
                                        cam_target,
                                        level_index,
                                        level.floor_offset,
                                        model_ambient,
                                        &[],
                                        &wall_at,
                                    )? {
                                        meshes.push(model_mesh);
                                    }
                                }
                                Ok(meshes)
                            },
                        ) else {
                            continue;
                        };
                        scene.models.extend(level_result?);
                    }
                }
                let st = pick_multilevel_adapter_state.borrow();
                let entity_pick =
                    scene.pick_entity_with_sprite_alpha_test(sx, sy, &|texture_key, u, v| {
                        texture_pick_is_opaque(&st.textures, texture_key, u, v)
                    });
                if let Some(entity_pick) = entity_pick.as_ref() {
                    if tile_pick
                        .as_ref()
                        .map(|tile_pick| entity_pick_precedes_tile(entity_pick, tile_pick))
                        .unwrap_or(true)
                    {
                        return Ok(LuaValue::Table(entity_pick_to_table(lua, entity_pick)?));
                    }
                }
                let Some(pick) = tile_pick else {
                    return Ok(LuaValue::Nil);
                };
                let tbl = pick_result_to_table(lua, &pick)?;
                if let Some(level) = grid.get_level(pick.level_index) {
                    match pick.surface {
                        PickSurface::Floor => {
                            if let Some(cell) = level.lowered_floor(pick.grid_x, pick.grid_y) {
                                /// Texture id for the picked lowered floor cell.
                                tbl.set("texture", cell.texture_key.data().as_ffi())?;
                            } else if let Some(texture) =
                                level.floor_texture_at(pick.grid_x, pick.grid_y)
                            {
                                /// Texture id for the picked floor surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                        PickSurface::Ceiling => {
                            if let Some(texture) =
                                level.ceiling_texture_at(pick.grid_x, pick.grid_y)
                            {
                                /// Texture id for the picked ceiling surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                        PickSurface::Wall => {
                            if let Some(texture) = wall_tex_map.get(&pick.cell_value) {
                                /// Texture id for the picked wall surface.
                                tbl.set("texture", texture.data().as_ffi())?;
                            }
                        }
                    }
                }
                Ok(LuaValue::Table(tbl))
            },
        )?,
    )?;
    // -- buildMultiLevelScene --
    /// Builds a multilevel raycaster scene from a stack of plain Lua level tables.
    /// @param | params | table | Scene params plus optional active_level.
    /// @param | levels | table|LMultiLevelGrid | Array of level tables or a persistent LMultiLevelGrid.
    /// @param | lights | table? | Array of point-light tables or LPointLight userdata values.
    /// @param | sprites | table|LSpriteManager? | Array of sprite tables {x, y, texture?, size?, level?, front_texture?, right_texture?, back_texture?, left_texture?, angle?} or an LSpriteManager whose sprites use their own optional level indices and default to active_level.
    /// @param | wallTextures | table? | Map of cell_value -> texture for wall surfaces.
    /// @param | models | table? | Array of model instance tables {model, x, y, level?, rotation?, yaw?, z?, scale?}; instances default to `active_level`.
    /// @return | integer | Total number of quads in the built scene.
    let s = state.clone();
    tbl.set(
        "buildMultiLevelScene",
        lua.create_function(
            move |_,
                  (params_tbl, levels_value, lights_tbl, sprites_tbl, wall_tex_tbl, models_tbl): (
                LuaTable,
                LuaValue,
                LuaValue,
                LuaValue,
                LuaValue,
                LuaValue,
            )| {
                let params =
                    parse_scene_build_params(&params_tbl, "lurek.raycaster.buildMultiLevelScene")?;
                let active_level = parse_active_level(&params_tbl)?;
                let lights =
                    parse_point_lights(lights_tbl, "lurek.raycaster.buildMultiLevelScene")?;
                let sprites = parse_level_sprites(
                    sprites_tbl,
                    "lurek.raycaster.buildMultiLevelScene",
                    active_level,
                )?;
                let wall_tex_map = parse_wall_texture_map(
                    wall_tex_tbl,
                    "lurek.raycaster.buildMultiLevelScene",
                )?;
                let mut grid =
                    parse_multilevel_grid_value(levels_value, "lurek.raycaster.buildMultiLevelScene")?;

                if active_level >= grid.level_count() {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.raycaster.buildMultiLevelScene: active_level {} is out of range for {} levels",
                        active_level,
                        grid.level_count()
                    )));
                }
                grid.set_active_level(active_level);

                let mut scene = RaycasterScene::build_multilevel(
                    &grid,
                    &params,
                    &lights,
                    &sprites,
                    &|_, cell_value| wall_tex_map.get(&cell_value).copied(),
                    &|_, _, _| None,
                    &|_, _, _| None,
                    &|_, _, _| None,
                );
                if let LuaValue::Table(tbl) = models_tbl {
                    #[cfg(feature = "obj-loader")]
                    {
                        let eye = params.camera_height.clamp(0.1, 0.9);
                        let camera_world_z = grid
                            .get_active()
                            .map(|level| level.floor_offset + eye)
                            .unwrap_or(eye);
                        let cam_pos = Vec3::new(params.player_x, camera_world_z, params.player_y);
                        let cam_target = Vec3::new(
                            params.player_x + params.player_angle.cos(),
                            camera_world_z,
                            params.player_y + params.player_angle.sin(),
                        );
                        let models_by_level =
                            collect_model_tables_by_level(&tbl, active_level, grid.level_count())?;
                        let mut lights_by_level = vec![Vec::new(); grid.level_count()];
                        for light in &lights {
                            match light.level_index {
                                Some(level_index) if level_index < grid.level_count() => {
                                    lights_by_level[level_index].push(light.clone());
                                }
                                Some(_) => {}
                                None => {
                                    for bucket in &mut lights_by_level {
                                        bucket.push(light.clone());
                                    }
                                }
                            }
                        }

                        let visible_levels = grid.visible_level_indices(
                            params.player_x,
                            params.player_y,
                            params.max_distance,
                        );
                        for level_index in visible_levels {
                            let level_models = &models_by_level[level_index];
                            let Some(level_result) = grid.with_runtime_level(
                                level_index,
                                |level, raycaster| -> LuaResult<Vec<ModelMesh>> {
                                    let wall_at = |cx: i32, cy: i32| -> bool {
                                        cx < 0
                                            || cy < 0
                                            || raycaster.blocks_light_at(cx as u32, cy as u32)
                                    };
                                    let mut meshes = Vec::new();
                                    for mt in level_models {
                                        let model_cell_x =
                                            mt.get::<_, f32>("x")?.floor().max(0.0) as usize;
                                        let model_cell_y =
                                            mt.get::<_, f32>("y")?.floor().max(0.0) as usize;
                                        let roofed = model_cell_x < level.width
                                            && model_cell_y < level.height
                                            && !level.is_ceiling_hole(model_cell_x, model_cell_y);
                                        let model_ambient = if roofed {
                                            params.ambient_light * params.roofed_ambient_factor
                                        } else {
                                            params.ambient_light
                                        };
                                        if let Some(model_mesh) = project_model_instance(
                                            mt,
                                            "lurek.raycaster.buildMultiLevelScene",
                                            &params,
                                            cam_pos,
                                            cam_target,
                                            level_index,
                                            level.floor_offset,
                                            model_ambient,
                                            &lights_by_level[level_index],
                                            &wall_at,
                                        )? {
                                            meshes.push(model_mesh);
                                        }
                                    }
                                    Ok(meshes)
                                },
                            ) else {
                                continue;
                            };
                            scene.models.extend(level_result?);
                        }
                    }
                    #[cfg(not(feature = "obj-loader"))]
                    {
                        let _ = &tbl;
                    }
                }
                let quad_count = scene.quad_count();
                s.borrow_mut().raycaster_output = Some(scene);
                Ok(quad_count)
            },
        )?,
    )?;
    // -- buildMultiLevelSceneFromAdapter --
    /// Builds a multilevel raycaster scene from a stack of plain Lua level tables using a runtime scene adapter.
    /// @param | params | table | Scene params plus optional active_level.
    /// @param | levels | table|LMultiLevelGrid | Array of level tables or a persistent LMultiLevelGrid.
    /// @param | adapter | LSceneAdapter | Runtime scene adapter providing lights, sprites, and models.
    /// @param | wallTextures | table? | Map of cell_value -> texture for wall surfaces.
    /// @return | integer | Total number of quads in the built scene.
    let build_multilevel_adapter_state = state.clone();
    tbl.set(
        "buildMultiLevelSceneFromAdapter",
        lua.create_function(
            move |lua,
                  (params_tbl, levels_value, adapter_ud, wall_tex_tbl): (
                LuaTable,
                LuaValue,
                LuaAnyUserData,
                LuaValue,
            )| {
                let params = parse_scene_build_params(
                    &params_tbl,
                    "lurek.raycaster.buildMultiLevelSceneFromAdapter",
                )?;
                let active_level = parse_active_level(&params_tbl)?;
                let (lights_tbl, sprites_tbl, models_tbl) = scene_input_tables_from_adapter(
                    lua,
                    &adapter_ud,
                    "lurek.raycaster.buildMultiLevelSceneFromAdapter",
                )?;
                let lights = parse_point_lights(
                    LuaValue::Table(lights_tbl),
                    "lurek.raycaster.buildMultiLevelSceneFromAdapter",
                )?;
                let sprites = parse_level_sprites(
                    LuaValue::Table(sprites_tbl),
                    "lurek.raycaster.buildMultiLevelSceneFromAdapter",
                    active_level,
                )?;
                let wall_tex_map = parse_wall_texture_map(
                    wall_tex_tbl,
                    "lurek.raycaster.buildMultiLevelSceneFromAdapter",
                )?;
                let mut grid = parse_multilevel_grid_value(
                    levels_value,
                    "lurek.raycaster.buildMultiLevelSceneFromAdapter",
                )?;
                if active_level >= grid.level_count() {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.raycaster.buildMultiLevelSceneFromAdapter: active_level {} is out of range for {} levels",
                        active_level,
                        grid.level_count()
                    )));
                }
                grid.set_active_level(active_level);
                let mut scene = RaycasterScene::build_multilevel(
                    &grid,
                    &params,
                    &lights,
                    &sprites,
                    &|_, cell_value| wall_tex_map.get(&cell_value).copied(),
                    &|_, _, _| None,
                    &|_, _, _| None,
                    &|_, _, _| None,
                );
                #[cfg(feature = "obj-loader")]
                {
                    let eye = params.camera_height.clamp(0.1, 0.9);
                    let camera_world_z = grid
                        .get_active()
                        .map(|level| level.floor_offset + eye)
                        .unwrap_or(eye);
                    let cam_pos = Vec3::new(params.player_x, camera_world_z, params.player_y);
                    let cam_target = Vec3::new(
                        params.player_x + params.player_angle.cos(),
                        camera_world_z,
                        params.player_y + params.player_angle.sin(),
                    );
                    let models_by_level =
                        collect_model_tables_by_level(&models_tbl, active_level, grid.level_count())?;
                    let visible_levels = grid.visible_level_indices(
                        params.player_x,
                        params.player_y,
                        params.max_distance,
                    );
                    for level_index in visible_levels {
                        let level_models = &models_by_level[level_index];
                        let Some(level_result) = grid.with_runtime_level(
                            level_index,
                            |level, raycaster| -> LuaResult<Vec<ModelMesh>> {
                                let wall_at = |cx: i32, cy: i32| -> bool {
                                    cx < 0
                                        || cy < 0
                                        || raycaster.blocks_light_at(cx as u32, cy as u32)
                                };
                                let mut meshes = Vec::new();
                                for mt in level_models {
                                    let model_cell_x =
                                        mt.get::<_, f32>("x")?.floor().max(0.0) as usize;
                                    let model_cell_y =
                                        mt.get::<_, f32>("y")?.floor().max(0.0) as usize;
                                    let roofed = model_cell_x < level.width
                                        && model_cell_y < level.height
                                        && !level.is_ceiling_hole(model_cell_x, model_cell_y);
                                    let model_ambient = if roofed {
                                        params.ambient_light * params.roofed_ambient_factor
                                    } else {
                                        params.ambient_light
                                    };
                                    if let Some(model_mesh) = project_model_instance(
                                        mt,
                                        "lurek.raycaster.buildMultiLevelSceneFromAdapter",
                                        &params,
                                        cam_pos,
                                        cam_target,
                                        level_index,
                                        level.floor_offset,
                                        model_ambient,
                                        &lights,
                                        &wall_at,
                                    )? {
                                        meshes.push(model_mesh);
                                    }
                                }
                                Ok(meshes)
                            },
                        ) else {
                            continue;
                        };
                        scene.models.extend(level_result?);
                    }
                }
                let quad_count = scene.quad_count();
                build_multilevel_adapter_state.borrow_mut().raycaster_output = Some(scene);
                Ok(quad_count)
            },
        )?,
    )?;
    // -- getLastBuildStats --
    /// Returns stats for the last stored raycaster scene build.
    /// This reports the most recent scene saved by buildScene, buildSceneFromAdapter, buildMultiLevelScene,
    /// buildMultiLevelSceneFromAdapter, or their userdata equivalents.
    /// @return | table? | Nil if no raycaster scene has been built yet; otherwise a stats table.
    /// @field | lightingSamples | integer | Total lighting samples requested during the last build.
    /// @field | lightingCacheHits | integer | Number of reused lighting samples served from the per-build cache.
    /// @field | lightingCacheMisses | integer | Number of unique lighting samples computed during the last build.
    let last_build_stats_state = state.clone();
    tbl.set(
        "getLastBuildStats",
        lua.create_function(move |lua, ()| {
            let stats = {
                let state = last_build_stats_state.borrow();
                state
                    .raycaster_output
                    .as_ref()
                    .map(|scene| scene.build_stats)
            };
            match stats {
                Some(stats) => Ok(LuaValue::Table(raycaster_build_stats_to_table(
                    lua, &stats,
                )?)),
                None => Ok(LuaValue::Nil),
            }
        })?,
    )?;
    // -- projectColumn --
    /// Computes the projected wall-column height for a given distance, FOV, and screen height.
    /// @param | distance | number | Perpendicular distance to the wall.
    /// @param | fov | number | Field of view in radians.
    /// @param | screenHeight | number | Screen height in pixels.
    /// @return | number | Projected column height in pixels.
    tbl.set(
        "projectColumn",
        lua.create_function(|_, (distance, fov, screen_height): (f32, f32, f32)| {
            Ok(project_column(distance, fov, screen_height))
        })?,
    )?;
    // -- distanceShade --
    /// Returns a brightness multiplier (0.0..1.0) based on distance for fog/darkness falloff.
    /// @param | distance | number | Distance to shade.
    /// @param | maxDistance | number | Distance at which shade reaches zero.
    /// @return | number | Shade factor (1.0 at distance 0, approaching 0.0 at maxDistance).
    tbl.set(
        "distanceShade",
        lua.create_function(|_, (distance, max_distance): (f32, f32)| {
            Ok(distance_shade(distance, max_distance))
        })?,
    )?;
    // -- applyLitShade --
    /// Applies an RGB light color to a scalar shade value.
    /// @param | baseShade | number | Base shade multiplier.
    /// @param | r | number | Red light channel.
    /// @param | g | number | Green light channel.
    /// @param | b | number | Blue light channel.
    /// @return | number | Shaded red channel.
    /// @return | number | Shaded green channel.
    /// @return | number | Shaded blue channel.
    tbl.set(
        "applyLitShade",
        lua.create_function(|_, (base_shade, r, g, b): (f32, f32, f32, f32)| {
            let rgb = apply_lit_shade(base_shade, [r, g, b]);
            Ok((rgb[0], rgb[1], rgb[2]))
        })?,
    )?;
    // -- newDoorManager --
    /// Creates a new door manager for tracking and animating sliding doors.
    /// @return | LDoorManager | A new empty door manager.
    tbl.set(
        "newDoorManager",
        lua.create_function(|_, ()| {
            Ok(LuaDoorManager {
                inner: Rc::new(RefCell::new(DoorManager::new())),
            })
        })?,
    )?;
    // -- newHeightMap --
    /// Creates a new height map for variable floor/ceiling heights across the grid.
    /// @param | w | integer | Width in cells.
    /// @param | h | integer | Height in cells.
    /// @return | LHeightMap | A new height map initialized to zero.
    tbl.set(
        "newHeightMap",
        lua.create_function(|_, (w, h): (u32, u32)| {
            Ok(LuaHeightMap {
                inner: Rc::new(RefCell::new(HeightMap::new(w, h))),
            })
        })?,
    )?;
    // -- newPointLight --
    /// Creates a new point light with position, color, radius, and intensity.
    /// @param | x | number | World X position.
    /// @param | y | number | World Y position.
    /// @param | r | number | Red channel (0.0..1.0).
    /// @param | g | number | Green channel (0.0..1.0).
    /// @param | b | number | Blue channel (0.0..1.0).
    /// @param | radius | number | Light falloff radius in world units.
    /// @param | intensity | number | Brightness multiplier.
    /// @param | level | integer? | Optional multilevel slice index that owns this light.
    /// @return | LPointLight | A new point light instance.
    tbl.set(
        "newPointLight",
        lua.create_function(
            |_,
             (x, y, r, g, b, radius, intensity, level): (
                f32,
                f32,
                f32,
                f32,
                f32,
                f32,
                f32,
                Option<usize>,
            )| {
                Ok(LuaPointLight {
                    inner: PointLight {
                        x,
                        y,
                        level_index: level,
                        radius,
                        intensity,
                        color: [r, g, b],
                    },
                })
            },
        )?,
    )?;
    // -- newSpriteManager --
    /// Creates a new sprite manager for tracking and projecting billboard sprites.
    /// @return | LSpriteManager | A new empty sprite manager.
    tbl.set(
        "newSpriteManager",
        lua.create_function(|_, ()| {
            Ok(LuaSpriteManager {
                inner: SpriteManager::new(),
                sprite_textures: HashMap::new(),
            })
        })?,
    )?;
    let scene_adapter_state = state.clone();
    // -- newSceneAdapter --
    /// Creates a runtime adapter for sprites, lights, and models that can follow physics bodies.
    /// @return | LSceneAdapter | A new empty scene adapter.
    tbl.set(
        "newSceneAdapter",
        lua.create_function(move |_, ()| {
            Ok(LuaRaycasterSceneAdapter {
                state: scene_adapter_state.clone(),
                inner: SceneAdapter::new(),
            })
        })?,
    )?;
    /// Performs the 'raycaster' operation.
    lurek.set("raycaster", tbl)?;
    Ok(())
}
