//! Registers `lurek.tilefield`, converting Lua tables and one-based coordinates while Rust owns field behavior.

use super::tilemap_api::LuaTileMap;
use super::tileset_api::LuaTileSet;
use super::SharedState;
use crate::color::Color;
use crate::light::{FalloffMode, Light2D, LightBlendMode, LightType, Occluder};
use crate::lua_api::light_api::{lua_light_from_light, lua_occluder_from_occluder};
use crate::lua_api::physics_api::{try_lua_bodies_from_bodies, LuaWorld};
use crate::math::Vec2;
use crate::physics::{Body, BodyType};
use crate::tilefield::{
    CellCoord, TileCategory, TileCategoryKind, TileChannel, TileField, TileFieldLimits,
    TileFieldMap, TileLightEmitter, TileModifier, TileRef, TileTopology,
};
use crate::tilemap::tilemap::TileMap;
use crate::tileset::{
    TileObjectArchetype, TileObjectOccluder, TileObjectPhysics, TileObjectRenderLight,
    TileObjectShapeKind, TileSet,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashSet;
use std::rc::Rc;

const BLOCK_WORLD_REF_SLOTS: &[&str] = &[
    "foreground",
    "wall",
    "platform",
    "ore",
    "furniture",
    "liquid",
    "spawn",
    "biome",
];
const TILEFIELD_CHANNELS: &[TileChannel] = &[
    TileChannel::Move,
    TileChannel::Vision,
    TileChannel::Action,
    TileChannel::Light,
    TileChannel::Sun,
];

/// Lua-side handle wrapping a shared tilefield.
pub struct LuaTileField {
    /// Shared tilefield state used by adapters in sibling Lua modules.
    pub(crate) inner: Rc<RefCell<TileField>>,
}

/// Lua-side handle wrapping a grid of shared tilefields.
pub struct LuaTileFieldMap {
    inner: Rc<RefCell<TileFieldMap>>,
}

fn lua_err(api: &str, err: impl std::fmt::Display) -> LuaError {
    LuaError::RuntimeError(format!("lurek.tilefield.{api}: {err}"))
}

fn optional_limit(
    table: Option<&LuaTable>,
    primary: &str,
    alias: Option<&str>,
    current: u64,
    api: &str,
) -> LuaResult<u64> {
    let Some(table) = table else {
        return Ok(current);
    };
    if let Some(value) = table
        .get::<_, Option<u64>>(primary)
        .map_err(|e| lua_err(api, e))?
    {
        return Ok(value);
    }
    if let Some(alias) = alias {
        if let Some(value) = table
            .get::<_, Option<u64>>(alias)
            .map_err(|e| lua_err(api, e))?
        {
            return Ok(value);
        }
    }
    Ok(current)
}

fn tilefield_limits_from_opts(opts: Option<&LuaTable>, api: &str) -> LuaResult<TileFieldLimits> {
    let mut limits = TileFieldLimits::default();
    let nested = match opts {
        Some(table) => table
            .get::<_, Option<LuaTable>>("limits")
            .map_err(|e| lua_err(api, e))?,
        None => None,
    };
    let table = nested.as_ref().or(opts);
    limits.max_cells_per_field = optional_limit(
        table,
        "maxCellsPerField",
        Some("maxCells"),
        limits.max_cells_per_field,
        api,
    )?;
    limits.max_fields_per_map = optional_limit(
        table,
        "maxFieldsPerMap",
        Some("maxFields"),
        limits.max_fields_per_map,
        api,
    )?;
    limits.max_cells_per_field_map = optional_limit(
        table,
        "maxCellsPerFieldMap",
        Some("maxMapCells"),
        limits.max_cells_per_field_map,
        api,
    )?;
    limits.max_levels = u32::try_from(optional_limit(
        table,
        "maxLevels",
        None,
        u64::from(limits.max_levels),
        api,
    )?)
    .map_err(|_| lua_err(api, "maxLevels exceeds u32"))?;
    limits.max_categories = usize::try_from(optional_limit(
        table,
        "maxCategories",
        None,
        limits.max_categories as u64,
        api,
    )?)
    .map_err(|_| lua_err(api, "maxCategories does not fit usize"))?;
    limits.max_modifiers = usize::try_from(optional_limit(
        table,
        "maxModifiers",
        None,
        limits.max_modifiers as u64,
        api,
    )?)
    .map_err(|_| lua_err(api, "maxModifiers does not fit usize"))?;
    limits.max_slots = usize::try_from(optional_limit(
        table,
        "maxSlots",
        None,
        limits.max_slots as u64,
        api,
    )?)
    .map_err(|_| lua_err(api, "maxSlots does not fit usize"))?;
    limits.max_regions = usize::try_from(optional_limit(
        table,
        "maxRegions",
        None,
        limits.max_regions as u64,
        api,
    )?)
    .map_err(|_| lua_err(api, "maxRegions does not fit usize"))?;
    limits.max_cells_per_region = usize::try_from(optional_limit(
        table,
        "maxCellsPerRegion",
        Some("maxRegionCells"),
        limits.max_cells_per_region as u64,
        api,
    )?)
    .map_err(|_| lua_err(api, "maxCellsPerRegion does not fit usize"))?;
    limits.max_refs_per_cell = usize::try_from(optional_limit(
        table,
        "maxRefsPerCell",
        None,
        limits.max_refs_per_cell as u64,
        api,
    )?)
    .map_err(|_| lua_err(api, "maxRefsPerCell does not fit usize"))?;
    limits.max_dirty_rects = usize::try_from(optional_limit(
        table,
        "maxDirtyRects",
        None,
        limits.max_dirty_rects as u64,
        api,
    )?)
    .map_err(|_| lua_err(api, "maxDirtyRects does not fit usize"))?;
    limits.max_snapshot_entries = usize::try_from(optional_limit(
        table,
        "maxSnapshotEntries",
        None,
        limits.max_snapshot_entries as u64,
        api,
    )?)
    .map_err(|_| lua_err(api, "maxSnapshotEntries does not fit usize"))?;
    limits.max_provider_rows = optional_limit(
        table,
        "maxProviderRows",
        None,
        limits.max_provider_rows,
        api,
    )?;
    limits.max_string_length = usize::try_from(optional_limit(
        table,
        "maxStringLength",
        None,
        limits.max_string_length as u64,
        api,
    )?)
    .map_err(|_| lua_err(api, "maxStringLength does not fit usize"))?;
    limits.validate().map_err(|e| lua_err(api, e))?;
    Ok(limits)
}

fn one_based(value: u32, label: &str) -> LuaResult<u32> {
    value
        .checked_sub(1)
        .ok_or_else(|| LuaError::RuntimeError(format!("lurek.tilefield: {label} must be >= 1")))
}

fn coord_from_values(x: u32, y: u32, z: Option<u32>) -> LuaResult<CellCoord> {
    Ok(CellCoord {
        x: one_based(x, "x")?,
        y: one_based(y, "y")?,
        z: one_based(z.unwrap_or(1), "z")?,
    })
}

fn coord_from_table(table: LuaTable, api: &str) -> LuaResult<CellCoord> {
    let x: u32 = table.get("x").map_err(|e| lua_err(api, e))?;
    let y: u32 = table.get("y").map_err(|e| lua_err(api, e))?;
    let z: Option<u32> = table.get("z").map_err(|e| lua_err(api, e))?;
    coord_from_values(x, y, z).map_err(|e| lua_err(api, e))
}

fn lua_u32_arg(value: LuaValue, api: &str, label: &str) -> LuaResult<u32> {
    match value {
        LuaValue::Integer(value) if value >= 0 && value <= u32::MAX as i64 => Ok(value as u32),
        LuaValue::Number(value)
            if value.is_finite()
                && value.fract() == 0.0
                && value >= 0.0
                && value <= u32::MAX as f64 =>
        {
            Ok(value as u32)
        }
        other => Err(lua_err(
            api,
            format!(
                "{label} must be a non-negative integer, got {}",
                other.type_name()
            ),
        )),
    }
}

fn lua_u64_arg(value: LuaValue, api: &str, label: &str) -> LuaResult<u64> {
    match value {
        LuaValue::Integer(value) if value >= 0 => Ok(value as u64),
        LuaValue::Number(value)
            if value.is_finite()
                && value.fract() == 0.0
                && value >= 0.0
                && value <= u64::MAX as f64 =>
        {
            Ok(value as u64)
        }
        other => Err(lua_err(
            api,
            format!(
                "{label} must be a non-negative integer, got {}",
                other.type_name()
            ),
        )),
    }
}

fn coord_occupant_from_args(args: LuaMultiValue, api: &str) -> LuaResult<(CellCoord, u64)> {
    let mut iter = args.into_iter();
    let x = lua_u32_arg(
        iter.next()
            .ok_or_else(|| lua_err(api, "missing x coordinate"))?,
        api,
        "x",
    )?;
    let y = lua_u32_arg(
        iter.next()
            .ok_or_else(|| lua_err(api, "missing y coordinate"))?,
        api,
        "y",
    )?;
    let third = iter
        .next()
        .ok_or_else(|| lua_err(api, "missing occupant id"))?;
    let fourth = iter.next();
    if iter.next().is_some() {
        return Err(lua_err(api, "expected x, y, occupant or x, y, z, occupant"));
    }
    let (z, occupant) = match fourth {
        Some(value) => {
            let z = match third {
                LuaValue::Nil => None,
                value => Some(lua_u32_arg(value, api, "z")?),
            };
            (z, lua_u64_arg(value, api, "occupant")?)
        }
        None => (None, lua_u64_arg(third, api, "occupant")?),
    };
    Ok((coord_from_values(x, y, z)?, occupant))
}

fn channel_from_str(value: String, api: &str) -> LuaResult<TileChannel> {
    TileChannel::parse(&value).map_err(|err| lua_err(api, err))
}

fn category_kind_from_opts(opts: &LuaTable, api: &str) -> LuaResult<TileCategoryKind> {
    let kind = opts
        .get::<_, Option<String>>("kind")
        .map_err(|e| lua_err(api, e))?
        .unwrap_or_else(|| "custom".to_string());
    TileCategoryKind::parse(&kind).map_err(|e| lua_err(api, e))
}

fn tile_ref_from_table(table: LuaTable, api: &str) -> LuaResult<TileRef> {
    let tileset = table
        .get::<_, Option<String>>("tileset")
        .map_err(|e| lua_err(api, e))?
        .or_else(|| table.get::<_, Option<String>>("tilesetId").ok().flatten())
        .ok_or_else(|| lua_err(api, "typed ref requires tileset"))?;
    let tile = table
        .get::<_, Option<u32>>("tile")
        .map_err(|e| lua_err(api, e))?
        .or_else(|| table.get::<_, Option<u32>>("tileId").ok().flatten())
        .map(|value| one_based(value, "tile"))
        .transpose()
        .map_err(|e| lua_err(api, e))?;
    let object = table
        .get::<_, Option<String>>("object")
        .map_err(|e| lua_err(api, e))?
        .or_else(|| table.get::<_, Option<String>>("objectId").ok().flatten());
    TileRef::new(tileset, tile, object).map_err(|e| lua_err(api, e))
}

fn tile_ref_to_lua<'lua>(lua: &'lua Lua, value: &TileRef) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("tileset", value.tileset_id.as_str())?;
    if let Some(tile) = value.local_id {
        table.set("tile", tile + 1)?;
    }
    if let Some(object) = value.object_id.as_ref() {
        table.set("object", object.as_str())?;
    }
    Ok(table)
}

fn property_string_to_bool(value: &str) -> Option<bool> {
    match value {
        "true" | "1" => Some(true),
        "false" | "0" => Some(false),
        _ => None,
    }
}

fn property_value_to_string(value: LuaValue) -> LuaResult<Option<String>> {
    match value {
        LuaValue::Nil => Ok(None),
        LuaValue::Boolean(value) => Ok(Some(value.to_string())),
        LuaValue::Integer(value) => Ok(Some(value.to_string())),
        LuaValue::Number(value) => Ok(Some(value.to_string())),
        LuaValue::String(value) => Ok(Some(value.to_str()?.to_string())),
        other => Err(LuaError::RuntimeError(format!(
            "unsupported tilefield property value type '{}'",
            other.type_name()
        ))),
    }
}

struct TileFieldLuaParser;

impl TileFieldLuaParser {
    fn modifier_from_table(name: String, table: LuaTable, api: &str) -> LuaResult<TileModifier> {
        let mut modifier = TileModifier::new(name).map_err(|e| lua_err(api, e))?;
        if let Ok(blocks) = table.get::<_, LuaTable>("blocks") {
            for pair in blocks.pairs::<String, bool>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                modifier
                    .blockers
                    .insert(channel_from_str(name, api)?, value);
            }
        }
        if let Ok(costs) = table.get::<_, LuaTable>("costAdd") {
            for pair in costs.pairs::<String, f32>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                modifier
                    .cost_add
                    .insert(channel_from_str(name, api)?, value);
            }
        }
        if let Ok(costs) = table.get::<_, LuaTable>("costMul") {
            for pair in costs.pairs::<String, f32>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                modifier
                    .cost_mul
                    .insert(channel_from_str(name, api)?, value);
            }
        }
        if let Ok(blocks) = table.get::<_, LuaTable>("categoryBlocks") {
            for pair in blocks.pairs::<String, bool>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                modifier.category_blockers.insert(name, value);
            }
        }
        if let Ok(costs) = table.get::<_, LuaTable>("categoryCostAdd") {
            for pair in costs.pairs::<String, f32>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                modifier.category_cost_add.insert(name, value);
            }
        }
        if let Ok(costs) = table.get::<_, LuaTable>("categoryCostMul") {
            for pair in costs.pairs::<String, f32>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                modifier.category_cost_mul.insert(name, value);
            }
        }
        if let Ok(transmission) = table.get::<_, LuaTable>("transmission") {
            for pair in transmission.pairs::<String, f32>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                modifier.category_transmission.insert(name, value);
            }
        }
        if let Ok(filters) = table.get::<_, LuaTable>("filters") {
            for pair in filters.pairs::<String, LuaTable>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                modifier.category_filters.insert(
                    name,
                    [
                        value.get::<_, Option<f32>>(1)?.unwrap_or(1.0),
                        value.get::<_, Option<f32>>(2)?.unwrap_or(1.0),
                        value.get::<_, Option<f32>>(3)?.unwrap_or(1.0),
                    ],
                );
            }
        }
        modifier.sun_occlusion_add = table
            .get::<_, Option<f32>>("sunOcclusionAdd")
            .map_err(|e| lua_err(api, e))?
            .unwrap_or(0.0);
        if let Ok(light_tbl) = table.get::<_, LuaTable>("light") {
            let color = light_tbl
                .get::<_, Option<LuaTable>>("color")
                .map_err(|e| lua_err(api, e))?
                .map(|color_tbl| {
                    Ok::<[f32; 3], LuaError>([
                        color_tbl.get::<_, Option<f32>>(1)?.unwrap_or(1.0),
                        color_tbl.get::<_, Option<f32>>(2)?.unwrap_or(1.0),
                        color_tbl.get::<_, Option<f32>>(3)?.unwrap_or(1.0),
                    ])
                })
                .transpose()?
                .unwrap_or([1.0, 1.0, 1.0]);
            modifier.light = Some(TileLightEmitter {
                radius: light_tbl
                    .get::<_, Option<f32>>("radius")
                    .map_err(|e| lua_err(api, e))?
                    .unwrap_or(1.0),
                intensity: light_tbl
                    .get::<_, Option<f32>>("intensity")
                    .map_err(|e| lua_err(api, e))?
                    .unwrap_or(1.0),
                color,
            });
        }
        if let Ok(properties) = table.get::<_, LuaTable>("properties") {
            for pair in properties.pairs::<String, LuaValue>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                if let Some(value) = property_value_to_string(value).map_err(|e| lua_err(api, e))? {
                    modifier.properties.insert(name, value);
                }
            }
        }
        Ok(modifier)
    }

    fn profile_modifier_from_table(
        name: String,
        table: LuaTable,
        api: &str,
    ) -> LuaResult<TileModifier> {
        let mut modifier = Self::modifier_from_table(name, table.clone(), api)?;
        if let Ok(costs) = table.get::<_, LuaTable>("costs") {
            for pair in costs.pairs::<String, f32>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                modifier
                    .cost_add
                    .insert(channel_from_str(name, api)?, value - 1.0);
            }
        }
        if let Some(value) = table
            .get::<_, Option<f32>>("sunOcclusion")
            .map_err(|e| lua_err(api, e))?
        {
            modifier.sun_occlusion_add = value;
        }
        Ok(modifier)
    }

    fn light_emitter_from_table(table: LuaTable, api: &str) -> LuaResult<TileLightEmitter> {
        let color = table
            .get::<_, Option<LuaTable>>("color")
            .map_err(|e| lua_err(api, e))?
            .map(|color_tbl| {
                Ok::<[f32; 3], LuaError>([
                    color_tbl.get::<_, Option<f32>>(1)?.unwrap_or(1.0),
                    color_tbl.get::<_, Option<f32>>(2)?.unwrap_or(1.0),
                    color_tbl.get::<_, Option<f32>>(3)?.unwrap_or(1.0),
                ])
            })
            .transpose()?
            .unwrap_or([1.0, 1.0, 1.0]);
        Ok(TileLightEmitter {
            radius: table
                .get::<_, Option<f32>>("radius")
                .map_err(|e| lua_err(api, e))?
                .unwrap_or(1.0),
            intensity: table
                .get::<_, Option<f32>>("intensity")
                .map_err(|e| lua_err(api, e))?
                .unwrap_or(1.0),
            color,
        })
    }

    fn provider_u32(provider: &LuaTable, name: &str, api: &str) -> LuaResult<u32> {
        provider
            .get::<_, Option<u32>>(name)
            .map_err(|e| lua_err(api, e))?
            .ok_or_else(|| lua_err(api, format!("provider.{name} is required")))
    }

    fn provider_string(
        provider: &LuaTable,
        name: &str,
        default: &str,
        api: &str,
    ) -> LuaResult<String> {
        provider
            .get::<_, Option<String>>(name)
            .map_err(|e| lua_err(api, e))
            .map(|value| value.unwrap_or_else(|| default.to_string()))
    }

    fn apply_provider_cell(
        field: &mut TileField,
        coord: CellCoord,
        cell: LuaTable,
        api: &str,
    ) -> LuaResult<()> {
        if let Ok(blocks) = cell.get::<_, LuaTable>("blocks") {
            for pair in blocks.pairs::<String, bool>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                field
                    .set_block(coord, channel_from_str(name, api)?, value)
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        if let Ok(costs) = cell.get::<_, LuaTable>("costs") {
            for pair in costs.pairs::<String, f32>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                field
                    .set_cost(coord, channel_from_str(name, api)?, value)
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        if let Ok(blocks) = cell.get::<_, LuaTable>("categoryBlocks") {
            for pair in blocks.pairs::<String, bool>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                field
                    .set_category_block(coord, name, value)
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        if let Ok(costs) = cell.get::<_, LuaTable>("categoryCosts") {
            for pair in costs.pairs::<String, f32>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                field
                    .set_category_cost(coord, name, value)
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        if let Ok(transmission) = cell.get::<_, LuaTable>("transmission") {
            for pair in transmission.pairs::<String, f32>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                field
                    .set_category_transmission(coord, name, value)
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        if let Ok(filters) = cell.get::<_, LuaTable>("filters") {
            for pair in filters.pairs::<String, LuaTable>() {
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                field
                    .set_category_filter(
                        coord,
                        name,
                        [
                            value.get::<_, Option<f32>>(1)?.unwrap_or(1.0),
                            value.get::<_, Option<f32>>(2)?.unwrap_or(1.0),
                            value.get::<_, Option<f32>>(3)?.unwrap_or(1.0),
                        ],
                    )
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        if let Some(sun_occlusion) = cell
            .get::<_, Option<f32>>("sunOcclusion")
            .map_err(|e| lua_err(api, e))?
        {
            field
                .set_sun_occlusion(coord, sun_occlusion)
                .map_err(|e| lua_err(api, e))?;
        }
        if let Ok(refs) = cell.get::<_, LuaTable>("refs") {
            for pair in refs.pairs::<String, LuaValue>() {
                let (slot, value) = pair.map_err(|e| lua_err(api, e))?;
                if !field.has_slot(&slot) {
                    field
                        .define_slot(slot.clone())
                        .map_err(|e| lua_err(api, e))?;
                }
                match value {
                    LuaValue::Integer(value) if value >= 0 && value <= u32::MAX as i64 => field
                        .set_ref(coord, slot, value as u32)
                        .map_err(|e| lua_err(api, e))?,
                    LuaValue::Table(value) => {
                        let typed = tile_ref_from_table(value, api)?;
                        field
                            .set_typed_ref(coord, slot, typed)
                            .map_err(|e| lua_err(api, e))?;
                    }
                    other => {
                        return Err(lua_err(
                            api,
                            format!(
                                "ref value must be integer or table, got {}",
                                other.type_name()
                            ),
                        ));
                    }
                }
            }
        }
        if let Ok(lights) = cell.get::<_, LuaTable>("lights") {
            for pair in lights.pairs::<String, LuaTable>() {
                let (source, light) = pair.map_err(|e| lua_err(api, e))?;
                let light = Self::light_emitter_from_table(light, api)?;
                field
                    .set_light(coord, source, Some(light))
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        if let Ok(modifiers) = cell.get::<_, LuaTable>("modifiers") {
            for modifier in modifiers.sequence_values::<String>() {
                let modifier = modifier.map_err(|e| lua_err(api, e))?;
                field
                    .apply_modifier(coord, &modifier)
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        Ok(())
    }

    fn field_from_provider(provider: LuaTable, api: &str) -> LuaResult<TileField> {
        let limits = tilefield_limits_from_opts(Some(&provider), api)?;
        Self::field_from_provider_with_limits(provider, limits, api)
    }

    fn field_from_provider_with_limits(
        provider: LuaTable,
        limits: TileFieldLimits,
        api: &str,
    ) -> LuaResult<TileField> {
        let width = Self::provider_u32(&provider, "width", api)?;
        let height = Self::provider_u32(&provider, "height", api)?;
        let levels = provider
            .get::<_, Option<u32>>("levels")
            .map_err(|e| lua_err(api, e))?
            .unwrap_or(1);
        let topology_name = Self::provider_string(&provider, "topology", "square", api)?;
        let topology = TileTopology::parse(&topology_name).map_err(|e| lua_err(api, e))?;
        let provider_rows = u64::from(width)
            .checked_mul(u64::from(height))
            .and_then(|value| value.checked_mul(u64::from(levels)))
            .ok_or_else(|| lua_err(api, "provider cell count overflow"))?;
        if provider_rows > limits.max_provider_rows {
            return Err(lua_err(
                api,
                format!(
                    "provider cell count {provider_rows} exceeds limit {}",
                    limits.max_provider_rows
                ),
            ));
        }
        let mut field = TileField::new_with_limits(width, height, levels, topology, limits)
            .map_err(|e| lua_err(api, e))?;
        if let Ok(categories) = provider.get::<_, LuaTable>("categories") {
            let mut count = 0usize;
            for pair in categories.pairs::<String, LuaTable>() {
                count += 1;
                if count > limits.max_categories {
                    return Err(lua_err(api, "provider category limit exceeded"));
                }
                let (name, opts) = pair.map_err(|e| lua_err(api, e))?;
                let kind = category_kind_from_opts(&opts, api)?;
                let active = opts
                    .get::<_, Option<bool>>("active")
                    .map_err(|e| lua_err(api, e))?
                    .unwrap_or(true);
                field
                    .define_category(
                        TileCategory::new(name, kind, active).map_err(|e| lua_err(api, e))?,
                    )
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        if let Ok(slots) = provider.get::<_, LuaTable>("slots") {
            let mut count = 0usize;
            for slot in slots.sequence_values::<String>() {
                count += 1;
                if count > limits.max_slots {
                    return Err(lua_err(api, "provider slot limit exceeded"));
                }
                field
                    .define_slot(slot.map_err(|e| lua_err(api, e))?)
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        if let Ok(modifiers) = provider.get::<_, LuaTable>("modifiers") {
            let mut count = 0usize;
            for pair in modifiers.pairs::<String, LuaTable>() {
                count += 1;
                if count > limits.max_modifiers {
                    return Err(lua_err(api, "provider modifier limit exceeded"));
                }
                let (name, value) = pair.map_err(|e| lua_err(api, e))?;
                let modifier = Self::modifier_from_table(name.clone(), value, api)?;
                field
                    .set_modifier(name, modifier)
                    .map_err(|e| lua_err(api, e))?;
            }
        }
        if let Ok(regions) = provider.get::<_, LuaTable>("regions") {
            let mut count = 0usize;
            for pair in regions.pairs::<String, LuaTable>() {
                count += 1;
                if count > limits.max_regions {
                    return Err(lua_err(api, "provider region limit exceeded"));
                }
                let (name, region) = pair.map_err(|e| lua_err(api, e))?;
                if let Ok(cells) = region.get::<_, LuaTable>("cells") {
                    let mut out = Vec::new();
                    for cell in cells.sequence_values::<LuaTable>() {
                        if out.len() >= limits.max_cells_per_region {
                            return Err(lua_err(api, "provider region cell limit exceeded"));
                        }
                        out.push(coord_from_table(cell.map_err(|e| lua_err(api, e))?, api)?);
                    }
                    field
                        .set_region_cells(name.clone(), out)
                        .map_err(|e| lua_err(api, e))?;
                } else {
                    let z = one_based(
                        region
                            .get::<_, Option<u32>>("z")
                            .map_err(|e| lua_err(api, e))?
                            .unwrap_or(1),
                        "z",
                    )
                    .map_err(|e| lua_err(api, e))?;
                    let a = coord_from_values(
                        region.get("x1").map_err(|e| lua_err(api, e))?,
                        region.get("y1").map_err(|e| lua_err(api, e))?,
                        Some(z + 1),
                    )
                    .map_err(|e| lua_err(api, e))?;
                    let b = coord_from_values(
                        region.get("x2").map_err(|e| lua_err(api, e))?,
                        region.get("y2").map_err(|e| lua_err(api, e))?,
                        Some(z + 1),
                    )
                    .map_err(|e| lua_err(api, e))?;
                    field
                        .set_region_rect(name.clone(), a.x, a.y, b.x, b.y, z)
                        .map_err(|e| lua_err(api, e))?;
                }
                if let Ok(properties) = region.get::<_, LuaTable>("properties") {
                    for pair in properties.pairs::<String, LuaValue>() {
                        let (key, value) = pair.map_err(|e| lua_err(api, e))?;
                        field
                            .set_region_property(
                                &name,
                                key,
                                property_value_to_string(value).map_err(|e| lua_err(api, e))?,
                            )
                            .map_err(|e| lua_err(api, e))?;
                    }
                }
            }
        }
        let get_cell = provider
            .get::<_, Option<LuaFunction>>("getCell")
            .map_err(|e| lua_err(api, e))?;
        if let Some(get_cell) = get_cell {
            for z in 0..levels {
                for y in 0..height {
                    for x in 0..width {
                        let value: LuaValue = get_cell
                            .call((provider.clone(), x + 1, y + 1, z + 1))
                            .map_err(|e| lua_err(api, e))?;
                        match value {
                            LuaValue::Nil => {}
                            LuaValue::Table(cell) => {
                                Self::apply_provider_cell(
                                    &mut field,
                                    CellCoord { x, y, z },
                                    cell,
                                    api,
                                )?;
                            }
                            other => {
                                return Err(lua_err(
                                    api,
                                    format!(
                                        "provider.getCell must return table or nil, got {}",
                                        other.type_name()
                                    ),
                                ));
                            }
                        }
                    }
                }
            }
        }
        Ok(field)
    }
}

fn modifier_from_table(name: String, table: LuaTable, api: &str) -> LuaResult<TileModifier> {
    TileFieldLuaParser::modifier_from_table(name, table, api)
}

fn profile_modifier_from_table(
    name: String,
    table: LuaTable,
    api: &str,
) -> LuaResult<TileModifier> {
    TileFieldLuaParser::profile_modifier_from_table(name, table, api)
}

/// Builds a native tile field from a Lua provider table for boundary-owned APIs.
pub(crate) fn field_from_provider(provider: LuaTable, api: &str) -> LuaResult<TileField> {
    TileFieldLuaParser::field_from_provider(provider, api)
}

fn modifier_to_lua<'lua>(lua: &'lua Lua, modifier: &TileModifier) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("name", modifier.name.as_str())?;
    let blocks = lua.create_table()?;
    for (channel, blocked) in &modifier.blockers {
        blocks.set(channel.as_str(), *blocked)?;
    }
    table.set("blocks", blocks)?;
    let cost_add = lua.create_table()?;
    for (channel, cost) in &modifier.cost_add {
        cost_add.set(channel.as_str(), *cost)?;
    }
    table.set("costAdd", cost_add)?;
    let cost_mul = lua.create_table()?;
    for (channel, cost) in &modifier.cost_mul {
        cost_mul.set(channel.as_str(), *cost)?;
    }
    table.set("costMul", cost_mul)?;
    table.set("sunOcclusionAdd", modifier.sun_occlusion_add)?;
    if let Some(light) = &modifier.light {
        let light_tbl = lua.create_table()?;
        light_tbl.set("radius", light.radius)?;
        light_tbl.set("intensity", light.intensity)?;
        let color = lua.create_table()?;
        color.set(1, light.color[0])?;
        color.set(2, light.color[1])?;
        color.set(3, light.color[2])?;
        light_tbl.set("color", color)?;
        table.set("light", light_tbl)?;
    }
    let properties = lua.create_table()?;
    for (name, value) in &modifier.properties {
        properties.set(name.as_str(), value.as_str())?;
    }
    table.set("properties", properties)?;
    Ok(table)
}

fn profile_to_lua<'lua>(lua: &'lua Lua, modifier: &TileModifier) -> LuaResult<LuaTable<'lua>> {
    let table = modifier_to_lua(lua, modifier)?;
    let costs = lua.create_table()?;
    for (channel, cost) in &modifier.cost_add {
        costs.set(channel.as_str(), *cost + 1.0)?;
    }
    table.set("costs", costs)?;
    table.set("sunOcclusion", modifier.sun_occlusion_add)?;
    Ok(table)
}

fn parse_tileset_bool_property(value: &str, api: &str) -> LuaResult<bool> {
    match value.trim().to_ascii_lowercase().as_str() {
        "true" | "1" | "yes" | "on" => Ok(true),
        "false" | "0" | "no" | "off" => Ok(false),
        _ => Err(lua_err(
            api,
            format!("invalid boolean property value '{value}'"),
        )),
    }
}

fn parse_tileset_f32_property(value: &str, api: &str) -> LuaResult<f32> {
    value
        .trim()
        .parse::<f32>()
        .map_err(|_| lua_err(api, format!("invalid numeric property value '{value}'")))
}

fn tileset_local_id_from_ref(
    tileset: &TileSet,
    ref_value: u32,
    ref_is_gid: bool,
    api: &str,
) -> LuaResult<Option<u32>> {
    if ref_is_gid {
        let first_gid = tileset.get_first_gid();
        if ref_value < first_gid {
            return Ok(None);
        }
        let local_tile_id = ref_value - first_gid;
        if local_tile_id >= tileset.get_tile_count() {
            return Ok(None);
        }
        Ok(Some(local_tile_id))
    } else {
        let local_tile_id = one_based(ref_value, "ref").map_err(|e| lua_err(api, e))?;
        if local_tile_id >= tileset.get_tile_count() {
            return Ok(None);
        }
        Ok(Some(local_tile_id))
    }
}

fn tileset_local_id_from_gid(tilemap: &TileMap, gid: u32) -> Option<(usize, u32)> {
    if gid == 0 {
        return None;
    }
    for index in 0..tilemap.get_tileset_count() {
        let Some(tileset) = tilemap.get_tileset(index) else {
            continue;
        };
        let first_gid = tileset.get_first_gid();
        if gid >= first_gid {
            let local_tile_id = gid - first_gid;
            if local_tile_id < tileset.get_tile_count() {
                return Some((index, local_tile_id));
            }
        }
    }
    None
}

struct TileMaterializeOptions {
    z: u32,
    ref_is_gid: bool,
    origin_x: f32,
    origin_y: f32,
    tile_width: f32,
    tile_height: f32,
}

struct TileFieldMaterializer;

impl TileFieldMaterializer {
    fn apply_tileset_object_to_field(
        field: &mut TileField,
        coord: CellCoord,
        tileset: &TileSet,
        local_tile_id: u32,
        api: &str,
    ) -> LuaResult<bool> {
        let mut applied = false;
        if let Some(archetype) = tileset.archetype_for_tile(local_tile_id) {
            for (channel, blocked) in &archetype.blockers {
                field
                    .set_block(coord, *channel, *blocked)
                    .map_err(|e| lua_err(api, e))?;
            }
            for (channel, cost) in &archetype.costs {
                field
                    .set_cost(coord, *channel, *cost)
                    .map_err(|e| lua_err(api, e))?;
            }
            for (category, blocked) in &archetype.category_blockers {
                field
                    .set_category_block(coord, category.clone(), *blocked)
                    .map_err(|e| lua_err(api, e))?;
            }
            for (category, cost) in &archetype.category_costs {
                field
                    .set_category_cost(coord, category.clone(), *cost)
                    .map_err(|e| lua_err(api, e))?;
            }
            for (category, value) in &archetype.category_transmission {
                field
                    .set_category_transmission(coord, category.clone(), *value)
                    .map_err(|e| lua_err(api, e))?;
            }
            for (category, filter) in &archetype.category_filters {
                field
                    .set_category_filter(coord, category.clone(), *filter)
                    .map_err(|e| lua_err(api, e))?;
            }
            if let Some(sun_occlusion) = archetype.sun_occlusion {
                field
                    .set_sun_occlusion(coord, sun_occlusion)
                    .map_err(|e| lua_err(api, e))?;
            }
            let source_name = archetype
                .slot
                .as_deref()
                .unwrap_or(archetype.name.as_str())
                .to_string();
            let light = archetype.light.as_ref().map(|light| TileLightEmitter {
                radius: light.radius,
                intensity: light.intensity,
                color: light.color,
            });
            field
                .set_light(coord, source_name, light)
                .map_err(|e| lua_err(api, e))?;
            applied = true;
        }
        if let Some(properties) = tileset.properties(local_tile_id) {
            if let Some(value) = properties.get("sunOcclusion") {
                let parsed = parse_tileset_f32_property(value, api)?;
                field
                    .set_sun_occlusion(coord, parsed)
                    .map_err(|e| lua_err(api, e))?;
                applied = true;
            }
            for (name, value) in properties {
                if let Some(channel_name) = name.strip_prefix("block.") {
                    let channel = channel_from_str(channel_name.to_string(), api)?;
                    let blocked = parse_tileset_bool_property(value, api)?;
                    field
                        .set_block(coord, channel, blocked)
                        .map_err(|e| lua_err(api, e))?;
                    applied = true;
                } else if let Some(channel_name) = name.strip_prefix("cost.") {
                    let channel = channel_from_str(channel_name.to_string(), api)?;
                    let cost = parse_tileset_f32_property(value, api)?;
                    field
                        .set_cost(coord, channel, cost)
                        .map_err(|e| lua_err(api, e))?;
                    applied = true;
                }
            }
        }
        Ok(applied)
    }

    fn materialize_options(
        opts: Option<&LuaTable>,
        tileset: &TileSet,
        api: &str,
    ) -> LuaResult<TileMaterializeOptions> {
        let z = opts
            .and_then(|table| table.get::<_, Option<u32>>("z").ok().flatten())
            .or_else(|| opts.and_then(|table| table.get::<_, Option<u32>>("level").ok().flatten()))
            .unwrap_or(1)
            .checked_sub(1)
            .ok_or_else(|| lua_err(api, "z must be >= 1"))?;
        let ref_is_gid = opts
            .and_then(|table| table.get::<_, Option<bool>>("refIsGid").ok().flatten())
            .unwrap_or(false);
        let origin_x = opts
            .and_then(|table| table.get::<_, Option<f32>>("originX").ok().flatten())
            .unwrap_or(0.0);
        let origin_y = opts
            .and_then(|table| table.get::<_, Option<f32>>("originY").ok().flatten())
            .unwrap_or(0.0);
        let tile_width = opts
            .and_then(|table| table.get::<_, Option<f32>>("tileWidth").ok().flatten())
            .unwrap_or_else(|| tileset.get_tile_width() as f32);
        let tile_height = opts
            .and_then(|table| table.get::<_, Option<f32>>("tileHeight").ok().flatten())
            .unwrap_or_else(|| tileset.get_tile_height() as f32);
        if !origin_x.is_finite()
            || !origin_y.is_finite()
            || !tile_width.is_finite()
            || !tile_height.is_finite()
            || tile_width <= 0.0
            || tile_height <= 0.0
        {
            return Err(lua_err(
                api,
                "originX/originY must be finite and tileWidth/tileHeight must be finite > 0",
            ));
        }
        Ok(TileMaterializeOptions {
            z,
            ref_is_gid,
            origin_x,
            origin_y,
            tile_width,
            tile_height,
        })
    }

    fn tile_center(coord: CellCoord, opts: &TileMaterializeOptions) -> (f32, f32) {
        (
            opts.origin_x + (coord.x as f32 + 0.5) * opts.tile_width,
            opts.origin_y + (coord.y as f32 + 0.5) * opts.tile_height,
        )
    }

    fn tile_polygon(shape: TileObjectShapeKind, width: f32, height: f32) -> Vec<Vec2> {
        let hw = width * 0.5;
        let hh = height * 0.5;
        match shape {
            TileObjectShapeKind::Rect => vec![
                Vec2::new(-hw, -hh),
                Vec2::new(hw, -hh),
                Vec2::new(hw, hh),
                Vec2::new(-hw, hh),
            ],
            TileObjectShapeKind::Square => {
                let hs = width.min(height) * 0.5;
                vec![
                    Vec2::new(-hs, -hs),
                    Vec2::new(hs, -hs),
                    Vec2::new(hs, hs),
                    Vec2::new(-hs, hs),
                ]
            }
            TileObjectShapeKind::Diamond => vec![
                Vec2::new(0.0, -hh),
                Vec2::new(hw, 0.0),
                Vec2::new(0.0, hh),
                Vec2::new(-hw, 0.0),
            ],
            TileObjectShapeKind::Triangle => {
                vec![Vec2::new(0.0, -hh), Vec2::new(hw, hh), Vec2::new(-hw, hh)]
            }
            TileObjectShapeKind::Hex => {
                let qx = hw * 0.5;
                vec![
                    Vec2::new(-qx, -hh),
                    Vec2::new(qx, -hh),
                    Vec2::new(hw, 0.0),
                    Vec2::new(qx, hh),
                    Vec2::new(-qx, hh),
                    Vec2::new(-hw, 0.0),
                ]
            }
        }
    }

    fn polygon_area(vertices: &[Vec2]) -> f32 {
        let mut area = 0.0;
        for i in 0..vertices.len() {
            let a = vertices[i];
            let b = vertices[(i + 1) % vertices.len()];
            area += a.x * b.y - b.x * a.y;
        }
        area.abs() * 0.5
    }

    fn body_type_from_tileset(value: &str, api: &str) -> LuaResult<BodyType> {
        match value {
            "static" => Ok(BodyType::Static),
            "dynamic" => Ok(BodyType::Dynamic),
            "kinematic" => Ok(BodyType::Kinematic),
            "sensor" => Ok(BodyType::Sensor),
            other => Err(lua_err(
                api,
                format!("physics.bodyType '{other}' must be static, dynamic, kinematic, or sensor"),
            )),
        }
    }

    fn physics_body_from_tile(
        physics: &TileObjectPhysics,
        coord: CellCoord,
        opts: &TileMaterializeOptions,
        api: &str,
    ) -> LuaResult<Body> {
        let (x, y) = Self::tile_center(coord, opts);
        let body_type = if physics.sensor {
            BodyType::Sensor
        } else {
            Self::body_type_from_tileset(&physics.body_type, api)?
        };
        let mut body = match physics.shape {
            TileObjectShapeKind::Rect => {
                Body::try_new(x, y, opts.tile_width, opts.tile_height, body_type)
            }
            TileObjectShapeKind::Square => {
                let size = opts.tile_width.min(opts.tile_height);
                Body::try_new(x, y, size, size, body_type)
            }
            shape => Body::try_new_polygon(
                x,
                y,
                Self::tile_polygon(shape, opts.tile_width, opts.tile_height),
                body_type,
            ),
        }
        .map_err(|err| lua_err(api, err))?;
        let area = match physics.shape {
            TileObjectShapeKind::Rect => opts.tile_width * opts.tile_height,
            TileObjectShapeKind::Square => {
                let size = opts.tile_width.min(opts.tile_height);
                size * size
            }
            shape => Self::polygon_area(&Self::tile_polygon(
                shape,
                opts.tile_width,
                opts.tile_height,
            )),
        };
        body.mass = physics.mass.unwrap_or((area * physics.density).max(0.0001));
        body.friction = physics.friction;
        body.restitution = physics.restitution;
        body.layer = physics.layer;
        body.mask = physics.mask;
        Ok(body)
    }

    fn blend_mode_from_tileset(value: &str, api: &str) -> LuaResult<LightBlendMode> {
        match value {
            "add" => Ok(LightBlendMode::Add),
            "sub" => Ok(LightBlendMode::Sub),
            "mix" => Ok(LightBlendMode::Mix),
            other => Err(lua_err(
                api,
                format!("renderLight.blendMode '{other}' must be add, sub, or mix"),
            )),
        }
    }

    fn falloff_from_tileset(value: &str, api: &str) -> LuaResult<FalloffMode> {
        match value {
            "linear" => Ok(FalloffMode::Linear),
            "smooth" => Ok(FalloffMode::Smooth),
            "constant" => Ok(FalloffMode::Constant),
            other => Err(lua_err(
                api,
                format!("renderLight.falloff '{other}' must be linear, smooth, or constant"),
            )),
        }
    }

    fn light_type_from_tileset(value: &str, api: &str) -> LuaResult<LightType> {
        match value {
            "point" => Ok(LightType::Point),
            "directional" => Ok(LightType::Directional),
            "spot" => Ok(LightType::Spot),
            other => Err(lua_err(
                api,
                format!("renderLight.lightType '{other}' must be point, directional, or spot"),
            )),
        }
    }

    fn render_light_from_tile(
        render_light: &TileObjectRenderLight,
        coord: CellCoord,
        opts: &TileMaterializeOptions,
        api: &str,
    ) -> LuaResult<Light2D> {
        let (x, y) = Self::tile_center(coord, opts);
        let mut light = Light2D::new(x, y, render_light.radius);
        light.color = Color::new(
            render_light.color[0],
            render_light.color[1],
            render_light.color[2],
            render_light.color[3],
        );
        light.intensity = render_light.intensity;
        light.enabled = render_light.enabled;
        light.shadow_enabled = render_light.shadow_enabled;
        light.light_mask = render_light.light_mask;
        light.shadow_mask = render_light.shadow_mask;
        if let Some(value) = &render_light.blend_mode {
            light.blend_mode = Self::blend_mode_from_tileset(value, api)?;
        }
        if let Some(value) = &render_light.falloff {
            light.falloff = Self::falloff_from_tileset(value, api)?;
        }
        if let Some(value) = &render_light.light_type {
            light.light_type = Self::light_type_from_tileset(value, api)?;
        }
        Ok(light)
    }

    fn occluder_from_tile(
        occluder: &TileObjectOccluder,
        coord: CellCoord,
        opts: &TileMaterializeOptions,
    ) -> LuaResult<Occluder> {
        let (x, y) = Self::tile_center(coord, opts);
        let mut occ = Occluder::try_new(Self::tile_polygon(
            occluder.shape,
            opts.tile_width,
            opts.tile_height,
        ))
        .map_err(LuaError::RuntimeError)?;
        occ.set_position(Vec2::new(x, y));
        occ.set_opacity(occluder.opacity);
        occ.set_light_mask(occluder.light_mask);
        occ.set_enabled(occluder.enabled);
        Ok(occ)
    }
}

fn apply_tileset_object_to_field(
    field: &mut TileField,
    coord: CellCoord,
    tileset: &TileSet,
    local_tile_id: u32,
    api: &str,
) -> LuaResult<bool> {
    TileFieldMaterializer::apply_tileset_object_to_field(field, coord, tileset, local_tile_id, api)
}

fn materialize_options(
    opts: Option<&LuaTable>,
    tileset: &TileSet,
    api: &str,
) -> LuaResult<TileMaterializeOptions> {
    TileFieldMaterializer::materialize_options(opts, tileset, api)
}

fn physics_body_from_tile(
    physics: &TileObjectPhysics,
    coord: CellCoord,
    opts: &TileMaterializeOptions,
    api: &str,
) -> LuaResult<Body> {
    TileFieldMaterializer::physics_body_from_tile(physics, coord, opts, api)
}

fn render_light_from_tile(
    render_light: &TileObjectRenderLight,
    coord: CellCoord,
    opts: &TileMaterializeOptions,
    api: &str,
) -> LuaResult<Light2D> {
    TileFieldMaterializer::render_light_from_tile(render_light, coord, opts, api)
}

fn occluder_from_tile(
    occluder: &TileObjectOccluder,
    coord: CellCoord,
    opts: &TileMaterializeOptions,
) -> LuaResult<Occluder> {
    TileFieldMaterializer::occluder_from_tile(occluder, coord, opts)
}

/// Build every tile-derived light and occluder before mutating the shared light world.
/// This is the common transactional implementation used by the canonical light facade and
/// the temporary tilefield compatibility alias.
pub(crate) fn create_lights_from_tileset<'lua>(
    lua: &'lua Lua,
    state: Rc<RefCell<SharedState>>,
    field_ud: LuaAnyUserData<'lua>,
    slot: String,
    tileset_ud: LuaAnyUserData<'lua>,
    opts: Option<LuaTable<'lua>>,
    api: &str,
) -> LuaResult<LuaTable<'lua>> {
    let field_ud = field_ud.borrow::<LuaTileField>()?;
    let tileset_ud = tileset_ud.borrow::<LuaTileSet>()?;
    let tileset = tileset_ud.inner.borrow();
    let options = materialize_options(opts.as_ref(), &tileset, api)?;
    let field = field_ud.inner.borrow();
    let (width, height, levels) = field.size();
    if options.z >= levels {
        return Err(lua_err(api, "z is out of bounds"));
    }

    let mut pending_lights = Vec::new();
    let mut pending_occluders = Vec::new();
    for y in 0..height {
        for x in 0..width {
            let coord = CellCoord { x, y, z: options.z };
            let Some(archetype) =
                archetype_for_ref(&field, coord, &slot, &tileset, options.ref_is_gid, api)?
            else {
                continue;
            };
            if let Some(render_light) = archetype.render_light.as_ref() {
                pending_lights.push(render_light_from_tile(render_light, coord, &options, api)?);
            }
            if let Some(occluder) = archetype.occluder.as_ref() {
                pending_occluders.push(occluder_from_tile(occluder, coord, &options)?);
            }
        }
    }
    drop(field);
    drop(tileset);

    let total_vertices = pending_occluders
        .iter()
        .map(|item| item.vertices.len())
        .sum::<usize>();
    {
        let st = state.borrow();
        let world = &st.light_world;
        if world.light_count().saturating_add(pending_lights.len())
            > world.limits.max_registered_lights
        {
            return Err(LuaError::RuntimeError(format!(
                "lurek.light.{api}: registered light limit {} reached",
                world.limits.max_registered_lights
            )));
        }
        if world
            .occluder_count()
            .saturating_add(pending_occluders.len())
            > world.limits.max_registered_occluders
        {
            return Err(LuaError::RuntimeError(format!(
                "lurek.light.{api}: registered occluder limit {} reached",
                world.limits.max_registered_occluders
            )));
        }
        let existing_vertices = world
            .occluders
            .values()
            .map(|item| item.vertices.len())
            .sum::<usize>();
        if existing_vertices.saturating_add(total_vertices)
            > world.limits.max_total_occluder_vertices
        {
            return Err(LuaError::RuntimeError(format!(
                "lurek.light.{api}: total occluder vertex limit {} reached",
                world.limits.max_total_occluder_vertices
            )));
        }
    }

    let lights = lua.create_table()?;
    for (index, light) in pending_lights.into_iter().enumerate() {
        lights.set(index + 1, lua_light_from_light(state.clone(), light)?)?;
    }
    let occluders = lua.create_table()?;
    for (index, occluder) in pending_occluders.into_iter().enumerate() {
        occluders.set(
            index + 1,
            lua_occluder_from_occluder(state.clone(), occluder)?,
        )?;
    }
    let result = lua.create_table()?;
    result.set("lights", lights)?;
    result.set("occluders", occluders)?;
    Ok(result)
}

fn archetype_for_ref(
    field: &TileField,
    coord: CellCoord,
    slot: &str,
    tileset: &TileSet,
    ref_is_gid: bool,
    api: &str,
) -> LuaResult<Option<TileObjectArchetype>> {
    let Some(ref_value) = field.get_ref(coord, slot) else {
        return Ok(None);
    };
    let Some(local_tile_id) = tileset_local_id_from_ref(tileset, ref_value, ref_is_gid, api)?
    else {
        return Ok(None);
    };
    Ok(tileset.archetype_for_tile(local_tile_id).cloned())
}

fn tileset_property_for_tile(
    tileset: &TileSet,
    local_tile_id: u32,
    property: &str,
) -> Option<String> {
    tileset
        .archetype_for_tile(local_tile_id)
        .and_then(|object| object.properties.get(property).cloned())
        .or_else(|| {
            tileset
                .get_property(local_tile_id, property)
                .map(str::to_string)
        })
}

fn cell_to_lua<'lua>(
    lua: &'lua Lua,
    field: &TileField,
    coord: CellCoord,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    let blocks = lua.create_table()?;
    let costs = lua.create_table()?;
    for channel in [
        TileChannel::Move,
        TileChannel::Vision,
        TileChannel::Action,
        TileChannel::Light,
        TileChannel::Sun,
    ] {
        blocks.set(channel.as_str(), field.blocks(coord, channel))?;
        costs.set(channel.as_str(), field.cost(coord, channel))?;
    }
    table.set("blocks", blocks)?;
    table.set("costs", costs)?;
    table.set("sunOcclusion", field.sun_occlusion(coord))?;
    if let Some(cell) = field.cell(coord) {
        let category_blocks = lua.create_table()?;
        for (category, blocked) in cell.category_blockers() {
            category_blocks.set(category.as_str(), *blocked)?;
        }
        table.set("categoryBlocks", category_blocks)?;
        let category_costs = lua.create_table()?;
        for (category, cost) in cell.category_costs() {
            category_costs.set(category.as_str(), *cost)?;
        }
        table.set("categoryCosts", category_costs)?;
        let transmissions = lua.create_table()?;
        for (category, value) in cell.category_transmissions() {
            transmissions.set(category.as_str(), *value)?;
        }
        table.set("transmission", transmissions)?;
        let filters = lua.create_table()?;
        for (category, value) in cell.category_filters() {
            let filter = lua.create_table()?;
            filter.set(1, value[0])?;
            filter.set(2, value[1])?;
            filter.set(3, value[2])?;
            filters.set(category.as_str(), filter)?;
        }
        table.set("filters", filters)?;
        let refs = lua.create_table()?;
        for (slot, value) in cell.refs() {
            refs.set(slot.as_str(), *value)?;
        }
        for (slot, value) in cell.typed_refs() {
            refs.set(slot.as_str(), tile_ref_to_lua(lua, value)?)?;
        }
        table.set("refs", refs)?;
        let lights = lua.create_table()?;
        for (source, light) in cell.lights() {
            let light_tbl = lua.create_table()?;
            light_tbl.set("radius", light.radius)?;
            light_tbl.set("intensity", light.intensity)?;
            let color = lua.create_table()?;
            color.set(1, light.color[0])?;
            color.set(2, light.color[1])?;
            color.set(3, light.color[2])?;
            light_tbl.set("color", color)?;
            lights.set(source.as_str(), light_tbl)?;
        }
        table.set("lights", lights)?;
    }
    Ok(table)
}

fn cells_to_lua<'lua>(lua: &'lua Lua, cells: Vec<CellCoord>) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (i, coord) in cells.into_iter().enumerate() {
        let row = lua.create_table()?;
        row.set("x", coord.x + 1)?;
        row.set("y", coord.y + 1)?;
        row.set("z", coord.z + 1)?;
        table.set(i + 1, row)?;
    }
    Ok(table)
}

fn export_bool_layer<'lua>(lua: &'lua Lua, values: Vec<bool>) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (i, value) in values.into_iter().enumerate() {
        table.set(i + 1, value)?;
    }
    Ok(table)
}

fn export_number_layer<'lua>(lua: &'lua Lua, values: Vec<f32>) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (i, value) in values.into_iter().enumerate() {
        table.set(i + 1, value)?;
    }
    Ok(table)
}

fn export_ref_layer<'lua>(lua: &'lua Lua, values: Vec<Option<u32>>) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (i, value) in values.into_iter().enumerate() {
        table.set(i + 1, value)?;
    }
    Ok(table)
}

fn layer_value_count(field: &TileField, z: u32, api: &str) -> LuaResult<usize> {
    let (width, height, levels) = field.size();
    if z >= levels {
        return Err(lua_err(api, "z is out of bounds"));
    }
    width
        .checked_mul(height)
        .and_then(|value| usize::try_from(value).ok())
        .ok_or_else(|| lua_err(api, "field dimensions overflow"))
}

fn read_bool_layer(values: LuaTable, expected: usize, api: &str) -> LuaResult<Vec<bool>> {
    let mut out = Vec::with_capacity(expected);
    for index in 1..=expected {
        out.push(values.get(index).map_err(|e| lua_err(api, e))?);
    }
    Ok(out)
}

fn read_number_layer(values: LuaTable, expected: usize, api: &str) -> LuaResult<Vec<f32>> {
    let mut out = Vec::with_capacity(expected);
    for index in 1..=expected {
        out.push(values.get(index).map_err(|e| lua_err(api, e))?);
    }
    Ok(out)
}

fn read_optional_u32_layer(
    values: LuaTable,
    expected: usize,
    api: &str,
) -> LuaResult<Vec<Option<u32>>> {
    let mut out = Vec::with_capacity(expected);
    for index in 1..=expected {
        match values
            .raw_get::<_, LuaValue>(index)
            .map_err(|e| lua_err(api, e))?
        {
            LuaValue::Nil => out.push(None),
            LuaValue::Integer(value) if value >= 0 && value <= u32::MAX as i64 => {
                out.push(Some(value as u32));
            }
            LuaValue::Number(value)
                if value >= 0.0 && value.fract() == 0.0 && value <= u32::MAX as f64 =>
            {
                out.push(Some(value as u32));
            }
            other => {
                return Err(lua_err(
                    api,
                    format!(
                        "value {index} must be integer or nil, got {}",
                        other.type_name()
                    ),
                ))
            }
        }
    }
    Ok(out)
}

fn dirty_rects_to_lua<'lua>(
    lua: &'lua Lua,
    rects: &[(u32, u32, u32, u32, u32)],
    chunk_size: Option<u32>,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    for (index, (x, y, z, w, h)) in rects.iter().enumerate() {
        let entry = lua.create_table()?;
        entry.set("x", x + 1)?;
        entry.set("y", y + 1)?;
        entry.set("z", z + 1)?;
        entry.set("w", *w)?;
        entry.set("h", *h)?;
        if let Some(chunk_size) = chunk_size.filter(|value| *value > 0) {
            entry.set("cx", x / chunk_size)?;
            entry.set("cy", y / chunk_size)?;
        }
        out.set(index + 1, entry)?;
    }
    Ok(out)
}

fn coord_value_table<'lua, V>(
    lua: &'lua Lua,
    coord: CellCoord,
    value_name: &str,
    value: V,
) -> LuaResult<LuaTable<'lua>>
where
    V: IntoLua<'lua>,
{
    let row = lua.create_table()?;
    row.set("x", coord.x + 1)?;
    row.set("y", coord.y + 1)?;
    row.set("z", coord.z + 1)?;
    row.set(value_name, value)?;
    Ok(row)
}

impl LuaUserData for LuaTileField {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getSize --
        /// Returns field width, height, and level count.
        /// @return | integer | Field width in cells.
        /// @return | integer | Field height in cells.
        /// @return | integer | Level count.
        methods.add_method("getSize", |_, this, ()| Ok(this.inner.borrow().size()));

        // -- getTopology --
        /// Returns the field topology name used for coordinate interpretation.
        /// @return | string | `square`, `square4`, `square8`, `iso_square`, or `hex`.
        methods.add_method("getTopology", |_, this, ()| {
            Ok(this.inner.borrow().topology().as_str().to_string())
        });

        // -- inBounds --
        /// Returns whether one-based coordinates are inside the field.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | boolean | True when coordinates are in bounds.
        methods.add_method("inBounds", |_, this, (x, y, z): (u32, u32, Option<u32>)| {
            Ok(coord_from_values(x, y, z)
                .map(|coord| this.inner.borrow().in_bounds(coord))
                .unwrap_or(false))
        });

        // -- setOccupant --
        /// Stores an occupant id on one tile cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | occupant | integer | Occupant id, usually an ECS entity id.
        methods.add_method("setOccupant", |_, this, args: LuaMultiValue| {
            let (coord, occupant) = coord_occupant_from_args(args, "setOccupant")?;
            this.inner
                .borrow_mut()
                .set_occupant(coord, occupant)
                .map_err(|e| lua_err("setOccupant", e))
        });

        // -- clearOccupant --
        /// Clears any occupant id stored on one tile cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | boolean | True when an occupant was removed.
        methods.add_method(
            "clearOccupant",
            |_, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .clear_occupant(coord)
                    .map_err(|e| lua_err("clearOccupant", e))
            },
        );

        // -- getOccupant --
        /// Returns the occupant id stored on one tile cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | integer | Occupant id, or nil.
        methods.add_method(
            "getOccupant",
            |_, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this.inner.borrow().occupant(coord))
            },
        );

        // -- setResource --
        /// Sets or clears a resource label on one tile cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | resource | string? | Resource label, or nil to clear.
        methods.add_method(
            "setResource",
            |_, this, (x, y, z, resource): (u32, u32, Option<u32>, Option<String>)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .set_resource(coord, resource)
                    .map_err(|e| lua_err("setResource", e))
            },
        );

        // -- getResource --
        /// Returns a resource label stored on one tile cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | string | Resource label, or nil.
        methods.add_method(
            "getResource",
            |_, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this.inner.borrow().resource(coord).map(str::to_string))
            },
        );

        // -- setBuildable --
        /// Sets whether one tile cell accepts build placement.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | buildable | boolean | True when build placement is allowed.
        methods.add_method(
            "setBuildable",
            |_, this, (x, y, z, buildable): (u32, u32, Option<u32>, bool)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .set_buildable(coord, buildable)
                    .map_err(|e| lua_err("setBuildable", e))
            },
        );

        // -- isBuildable --
        /// Returns whether one tile cell accepts build placement.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | boolean | True when build placement is allowed.
        methods.add_method(
            "isBuildable",
            |_, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this.inner.borrow().is_buildable(coord))
            },
        );

        // -- getNeighbors --
        /// Returns topology-aware same-level neighbours for one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | table | Array of one-based coordinate tables.
        methods.add_method(
            "getNeighbors",
            |lua, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                let field = this.inner.borrow();
                if !field.in_bounds(coord) {
                    return Err(lua_err("getNeighbors", "coordinate is out of bounds"));
                }
                let out = lua.create_table()?;
                for (index, neighbor) in field.neighbors(coord).into_iter().enumerate() {
                    let entry = lua.create_table()?;
                    entry.set("x", neighbor.x + 1)?;
                    entry.set("y", neighbor.y + 1)?;
                    entry.set("z", neighbor.z + 1)?;
                    out.set(index + 1, entry)?;
                }
                Ok(out)
            },
        );

        // -- setRegionRect --
        /// Defines or replaces a named region from an inclusive one-based tile rectangle.
        /// @param | name | string | Region name.
        /// @param | x1 | integer | First one-based column.
        /// @param | y1 | integer | First one-based row.
        /// @param | x2 | integer | Second one-based column.
        /// @param | y2 | integer | Second one-based row.
        /// @param | z | integer? | One-based level, default 1.
        methods.add_method(
            "setRegionRect",
            |_, this, (name, x1, y1, x2, y2, z): (String, u32, u32, u32, u32, Option<u32>)| {
                let a = coord_from_values(x1, y1, z)?;
                let b = coord_from_values(x2, y2, z)?;
                if a.z != b.z {
                    return Err(lua_err(
                        "setRegionRect",
                        "region rectangle must stay on one level",
                    ));
                }
                this.inner
                    .borrow_mut()
                    .set_region_rect(name, a.x, a.y, b.x, b.y, a.z)
                    .map_err(|e| lua_err("setRegionRect", e))
            },
        );

        // -- setRegionCells --
        /// Defines or replaces a named region from explicit one-based tile cells.
        /// @param | name | string | Region name.
        /// @param | cells | table | Array of `{ x, y, z? }` cells.
        methods.add_method(
            "setRegionCells",
            |_, this, (name, cells_tbl): (String, LuaTable)| {
                let mut cells = Vec::new();
                for pair in cells_tbl.sequence_values::<LuaTable>() {
                    cells.push(coord_from_table(
                        pair.map_err(|e| lua_err("setRegionCells", e))?,
                        "setRegionCells",
                    )?);
                }
                this.inner
                    .borrow_mut()
                    .set_region_cells(name, cells)
                    .map_err(|e| lua_err("setRegionCells", e))
            },
        );

        // -- removeRegion --
        /// Removes a named region definition and its stored cell membership from this field.
        /// @param | name | string | Region name.
        /// @return | boolean | True when the region existed.
        methods.add_method("removeRegion", |_, this, name: String| {
            Ok(this.inner.borrow_mut().remove_region(&name))
        });

        // -- regionContains --
        /// Returns whether a named region contains a one-based tile cell.
        /// @param | name | string | Region name.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | boolean | True when the region contains the cell.
        methods.add_method(
            "regionContains",
            |_, this, (name, x, y, z): (String, u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this.inner.borrow().region_contains(&name, coord))
            },
        );

        // -- getRegionCells --
        /// Returns one-based cells for a named region, or nil when it does not exist.
        /// @param | name | string | Region name.
        /// @return | table | Array of `{ x, y, z }` cells.
        methods.add_method("getRegionCells", |lua, this, name: String| {
            let cells = this.inner.borrow().region_cells(&name);
            match cells {
                Some(cells) => Ok(Some(cells_to_lua(lua, cells)?)),
                None => Ok(None),
            }
        });

        // -- getRegionNames --
        /// Returns all region names in stable order.
        /// @return | table | Array of region names.
        methods.add_method("getRegionNames", |lua, this, ()| {
            let out = lua.create_table()?;
            for (index, name) in this.inner.borrow().region_names().into_iter().enumerate() {
                out.set(index + 1, name)?;
            }
            Ok(out)
        });

        // -- setRegionProperty --
        /// Sets or clears one string property on a named region. Numbers and booleans are stringified; nil removes the property.
        /// @param | name | string | Region name.
        /// @param | key | string | Property key.
        /// @param | value | any | String/number/boolean value, or nil to remove.
        methods.add_method(
            "setRegionProperty",
            |_, this, (name, key, value): (String, String, LuaValue)| {
                this.inner
                    .borrow_mut()
                    .set_region_property(
                        &name,
                        key,
                        property_value_to_string(value)
                            .map_err(|e| lua_err("setRegionProperty", e))?,
                    )
                    .map_err(|e| lua_err("setRegionProperty", e))
            },
        );

        // -- getRegionProperty --
        /// Returns one string property from a named region, or nil when absent.
        /// @param | name | string | Region name.
        /// @param | key | string | Property key.
        /// @return | string | Stored property value, or nil.
        methods.add_method(
            "getRegionProperty",
            |_, this, (name, key): (String, String)| {
                Ok(this
                    .inner
                    .borrow()
                    .region_property(&name, &key)
                    .map(|value| value.to_string()))
            },
        );

        // -- getRegionProperties --
        /// Returns all properties for a named region, or nil when the region does not exist.
        /// @param | name | string | Region name.
        /// @return | table | Key-value table of string properties, or nil.
        methods.add_method("getRegionProperties", |lua, this, name: String| match this
            .inner
            .borrow()
            .region_properties(&name)
        {
            Some(properties) => {
                let out = lua.create_table()?;
                for (key, value) in properties {
                    out.set(key, value)?;
                }
                Ok(LuaValue::Table(out))
            }
            None => Ok(LuaValue::Nil),
        });

        // -- regionsAt --
        /// Returns all region names that contain the addressed one-based tile cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | table | Array of region names in stable order.
        methods.add_method(
            "regionsAt",
            |lua, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                let out = lua.create_table()?;
                for (index, name) in this
                    .inner
                    .borrow()
                    .regions_at(coord)
                    .into_iter()
                    .enumerate()
                {
                    out.set(index + 1, name)?;
                }
                Ok(out)
            },
        );

        // -- clear --
        /// Clears cells, regions, occupants, resources, buildability, and active cell data while retaining category, modifier, and slot definitions.
        methods.add_method("clear", |_, this, ()| {
            this.inner
                .borrow_mut()
                .try_clear()
                .map_err(|e| lua_err("clear", e))
        });

        // -- clearCell --
        /// Clears gameplay state for one addressed cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        methods.add_method(
            "clearCell",
            |_, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .clear_cell(coord)
                    .map_err(|e| lua_err("clearCell", e))
            },
        );

        // -- getCell --
        /// Returns a table with blockers, costs, sun occlusion, refs, and modifiers.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | table | Cell state table.
        methods.add_method(
            "getCell",
            |lua, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                let field = this.inner.borrow();
                if !field.in_bounds(coord) {
                    return Err(lua_err("getCell", "coordinate is out of bounds"));
                }
                cell_to_lua(lua, &field, coord)
            },
        );

        // -- setCell --
        /// Sets cell state from a table with optional `blocks`, `costs`, `sunOcclusion`, `refs`, and `modifiers`.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | cell | table | Cell data.
        methods.add_method(
            "setCell",
            |_, this, (x, y, z, cell_tbl): (u32, u32, Option<u32>, LuaTable)| {
                let coord = coord_from_values(x, y, z)?;
                let mut field = this.inner.borrow_mut();
                if !field.in_bounds(coord) {
                    return Err(lua_err("setCell", "coordinate is out of bounds"));
                }
                if let Ok(blocks) = cell_tbl.get::<_, LuaTable>("blocks") {
                    for pair in blocks.pairs::<String, bool>() {
                        let (name, value) = pair.map_err(|e| lua_err("setCell", e))?;
                        let channel = channel_from_str(name, "setCell")?;
                        field
                            .set_block(coord, channel, value)
                            .map_err(|e| lua_err("setCell", e))?;
                    }
                }
                if let Ok(costs) = cell_tbl.get::<_, LuaTable>("costs") {
                    for pair in costs.pairs::<String, f32>() {
                        let (name, value) = pair.map_err(|e| lua_err("setCell", e))?;
                        let channel = channel_from_str(name, "setCell")?;
                        field
                            .set_cost(coord, channel, value)
                            .map_err(|e| lua_err("setCell", e))?;
                    }
                }
                if let Ok(blocks) = cell_tbl.get::<_, LuaTable>("categoryBlocks") {
                    for pair in blocks.pairs::<String, bool>() {
                        let (name, value) = pair.map_err(|e| lua_err("setCell", e))?;
                        field
                            .set_category_block(coord, name, value)
                            .map_err(|e| lua_err("setCell", e))?;
                    }
                }
                if let Ok(costs) = cell_tbl.get::<_, LuaTable>("categoryCosts") {
                    for pair in costs.pairs::<String, f32>() {
                        let (name, value) = pair.map_err(|e| lua_err("setCell", e))?;
                        field
                            .set_category_cost(coord, name, value)
                            .map_err(|e| lua_err("setCell", e))?;
                    }
                }
                if let Ok(transmission) = cell_tbl.get::<_, LuaTable>("transmission") {
                    for pair in transmission.pairs::<String, f32>() {
                        let (name, value) = pair.map_err(|e| lua_err("setCell", e))?;
                        field
                            .set_category_transmission(coord, name, value)
                            .map_err(|e| lua_err("setCell", e))?;
                    }
                }
                if let Ok(filters) = cell_tbl.get::<_, LuaTable>("filters") {
                    for pair in filters.pairs::<String, LuaTable>() {
                        let (name, value) = pair.map_err(|e| lua_err("setCell", e))?;
                        let filter = [
                            value.get::<_, Option<f32>>(1)?.unwrap_or(1.0),
                            value.get::<_, Option<f32>>(2)?.unwrap_or(1.0),
                            value.get::<_, Option<f32>>(3)?.unwrap_or(1.0),
                        ];
                        field
                            .set_category_filter(coord, name, filter)
                            .map_err(|e| lua_err("setCell", e))?;
                    }
                }
                if let Some(value) = cell_tbl
                    .get::<_, Option<f32>>("sunOcclusion")
                    .map_err(|e| lua_err("setCell", e))?
                {
                    field
                        .set_sun_occlusion(coord, value)
                        .map_err(|e| lua_err("setCell", e))?;
                }
                if let Ok(refs) = cell_tbl.get::<_, LuaTable>("refs") {
                    for pair in refs.pairs::<String, LuaValue>() {
                        let (slot, value) = pair.map_err(|e| lua_err("setCell", e))?;
                        match value {
                            LuaValue::Integer(value) if value >= 0 && value <= u32::MAX as i64 => {
                                field
                                    .set_ref(coord, slot, value as u32)
                                    .map_err(|e| lua_err("setCell", e))?;
                            }
                            LuaValue::Number(value)
                                if value >= 0.0
                                    && value.fract() == 0.0
                                    && value <= u32::MAX as f64 =>
                            {
                                field
                                    .set_ref(coord, slot, value as u32)
                                    .map_err(|e| lua_err("setCell", e))?;
                            }
                            LuaValue::Table(value) => {
                                let typed = tile_ref_from_table(value, "setCell")?;
                                field
                                    .set_typed_ref(coord, slot, typed)
                                    .map_err(|e| lua_err("setCell", e))?;
                            }
                            other => {
                                return Err(lua_err(
                                    "setCell",
                                    format!(
                                        "ref value must be integer or table, got {}",
                                        other.type_name()
                                    ),
                                ));
                            }
                        }
                    }
                }
                Ok(())
            },
        );

        // -- setBlock --
        /// Sets whether a cell blocks a channel.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | channel | string | Blocker channel name to update.
        /// @param | blocked | boolean | True when the channel should be blocked.
        methods.add_method(
            "setBlock",
            |_, this, (x, y, z, channel, blocked): (u32, u32, Option<u32>, String, bool)| {
                let coord = coord_from_values(x, y, z)?;
                let channel = channel_from_str(channel, "setBlock")?;
                this.inner
                    .borrow_mut()
                    .set_block(coord, channel, blocked)
                    .map_err(|e| lua_err("setBlock", e))
            },
        );

        // -- blocks --
        /// Returns whether a cell blocks a channel.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | channel | string | Blocker channel name to query.
        /// @return | boolean | True when the addressed cell blocks the channel.
        methods.add_method(
            "blocks",
            |_, this, (x, y, z, channel): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                let channel = channel_from_str(channel, "blocks")?;
                Ok(this.inner.borrow().blocks(coord, channel))
            },
        );

        // -- setCost --
        /// Sets the cost for one cell/channel.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | channel | string | Cost channel name to update.
        /// @param | cost | number | Movement or traversal cost value.
        methods.add_method(
            "setCost",
            |_, this, (x, y, z, channel, cost): (u32, u32, Option<u32>, String, f32)| {
                let coord = coord_from_values(x, y, z)?;
                let channel = channel_from_str(channel, "setCost")?;
                this.inner
                    .borrow_mut()
                    .set_cost(coord, channel, cost)
                    .map_err(|e| lua_err("setCost", e))
            },
        );

        // -- getCost --
        /// Returns the cost for one cell/channel.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | channel | string | Cost channel name to query.
        /// @return | number | Movement or traversal cost value.
        methods.add_method(
            "getCost",
            |_, this, (x, y, z, channel): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                let channel = channel_from_str(channel, "getCost")?;
                Ok(this.inner.borrow().cost(coord, channel))
            },
        );

        // -- defineCategory --
        /// Defines or replaces a user category used by movement, awareness, light, sun, or custom systems.
        /// @param | name | string | Stable category name.
        /// @param | opts | table? | Options: kind='movement|awareness|light|sun|custom', active=true?.
        methods.add_method(
            "defineCategory",
            |_, this, (name, opts): (String, Option<LuaTable>)| {
                let (kind, active) = match opts {
                    Some(opts) => (
                        category_kind_from_opts(&opts, "defineCategory")?,
                        opts.get::<_, Option<bool>>("active")
                            .map_err(|e| lua_err("defineCategory", e))?
                            .unwrap_or(true),
                    ),
                    None => (TileCategoryKind::Custom, true),
                };
                let category = TileCategory::new(name, kind, active)
                    .map_err(|e| lua_err("defineCategory", e))?;
                this.inner
                    .borrow_mut()
                    .define_category(category)
                    .map_err(|e| lua_err("defineCategory", e))
            },
        );

        // -- getCategory --
        /// Returns category metadata, or nil when the category is unknown.
        /// @param | name | string | Category name.
        /// @return | table|nil | Category table with name, kind, and active.
        methods.add_method("getCategory", |lua, this, name: String| {
            let field = this.inner.borrow();
            let Some(category) = field.category(&name) else {
                return Ok(None);
            };
            let table = lua.create_table()?;
            table.set("name", category.name.as_str())?;
            table.set("kind", category.kind.as_str())?;
            table.set("active", category.active)?;
            Ok(Some(table))
        });

        // -- getCategories --
        /// Returns the sorted names of all known cell categories.
        /// @return | string[] | Sorted category names.
        methods.add_method("getCategories", |lua, this, ()| {
            let names = this.inner.borrow().category_names();
            let table = lua.create_table()?;
            for (index, name) in names.into_iter().enumerate() {
                table.set(index + 1, name)?;
            }
            Ok(table)
        });

        // -- removeCategory --
        /// Removes a custom category and clears dependent cell/modifier data.
        /// @param | name | string | Custom category name.
        /// @return | boolean | True when the category existed.
        methods.add_method("removeCategory", |_, this, name: String| {
            this.inner
                .borrow_mut()
                .remove_category(&name)
                .map_err(|e| lua_err("removeCategory", e))
        });

        // -- setCategoryBlock --
        /// Sets one category blocker on one cell.
        /// @param | x | integer | One-based cell column.
        /// @param | y | integer | One-based cell row.
        /// @param | z | integer? | Optional one-based level index, defaulting to 1.
        /// @param | category | string | Category name to update.
        /// @param | blocked | boolean | Whether the category is blocked on that cell.
        methods.add_method(
            "setCategoryBlock",
            |_, this, (x, y, z, category, blocked): (u32, u32, Option<u32>, String, bool)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .set_category_block(coord, category, blocked)
                    .map_err(|e| lua_err("setCategoryBlock", e))
            },
        );

        // -- blocksCategory --
        /// Returns whether one cell blocks a category.
        /// @param | x | integer | One-based cell column.
        /// @param | y | integer | One-based cell row.
        /// @param | z | integer? | Optional one-based level index, defaulting to 1.
        /// @param | category | string | Category name to test.
        /// @return | boolean | True when the addressed cell blocks the selected category.
        methods.add_method(
            "blocksCategory",
            |_, this, (x, y, z, category): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this.inner.borrow().blocks_category(coord, &category))
            },
        );

        // -- setCategoryCost --
        /// Sets one movement-cost override for a category on one cell.
        /// @param | x | integer | One-based cell column.
        /// @param | y | integer | One-based cell row.
        /// @param | z | integer? | Optional one-based level index, defaulting to 1.
        /// @param | category | string | Category name to update.
        /// @param | cost | number | Effective movement cost to assign.
        methods.add_method(
            "setCategoryCost",
            |_, this, (x, y, z, category, cost): (u32, u32, Option<u32>, String, f32)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .set_category_cost(coord, category, cost)
                    .map_err(|e| lua_err("setCategoryCost", e))
            },
        );

        // -- getCategoryCost --
        /// Returns one effective category cost.
        /// @param | x | integer | One-based cell column.
        /// @param | y | integer | One-based cell row.
        /// @param | z | integer? | Optional one-based level index, defaulting to 1.
        /// @param | category | string | Category name to inspect.
        /// @return | number | Effective movement cost for that category on the addressed cell.
        methods.add_method(
            "getCategoryCost",
            |_, this, (x, y, z, category): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this.inner.borrow().category_cost(coord, &category))
            },
        );

        // -- setCategoryTransmission --
        /// Sets one category transmission multiplier on one cell.
        /// @param | x | integer | One-based cell column.
        /// @param | y | integer | One-based cell row.
        /// @param | z | integer? | Optional one-based level index, defaulting to 1.
        /// @param | category | string | Category name to update.
        /// @param | value | number | Transmission multiplier to assign.
        methods.add_method(
            "setCategoryTransmission",
            |_, this, (x, y, z, category, value): (u32, u32, Option<u32>, String, f32)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .set_category_transmission(coord, category, value)
                    .map_err(|e| lua_err("setCategoryTransmission", e))
            },
        );

        // -- getCategoryTransmission --
        /// Returns one effective category transmission multiplier.
        /// @param | x | integer | One-based cell column.
        /// @param | y | integer | One-based cell row.
        /// @param | z | integer? | Optional one-based level index, defaulting to 1.
        /// @param | category | string | Category name to inspect.
        /// @return | number | Effective transmission multiplier for that category on the addressed cell.
        methods.add_method(
            "getCategoryTransmission",
            |_, this, (x, y, z, category): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this.inner.borrow().category_transmission(coord, &category))
            },
        );

        // -- setCategoryFilter --
        /// Sets one RGB category filter on one cell.
        /// @param | x | integer | One-based cell column.
        /// @param | y | integer | One-based cell row.
        /// @param | z | integer? | Optional one-based level index, defaulting to 1.
        /// @param | category | string | Category name to update.
        /// @param | filter | table | RGB multiplier table with three numeric entries.
        methods.add_method(
            "setCategoryFilter",
            |_, this, (x, y, z, category, filter): (u32, u32, Option<u32>, String, LuaTable)| {
                let coord = coord_from_values(x, y, z)?;
                let value = [
                    filter.get::<_, Option<f32>>(1)?.unwrap_or(1.0),
                    filter.get::<_, Option<f32>>(2)?.unwrap_or(1.0),
                    filter.get::<_, Option<f32>>(3)?.unwrap_or(1.0),
                ];
                this.inner
                    .borrow_mut()
                    .set_category_filter(coord, category, value)
                    .map_err(|e| lua_err("setCategoryFilter", e))
            },
        );

        // -- getCategoryFilter --
        /// Returns one effective RGB category filter.
        /// @param | x | integer | One-based cell column.
        /// @param | y | integer | One-based cell row.
        /// @param | z | integer? | Optional one-based level index, defaulting to 1.
        /// @param | category | string | Category name to inspect.
        /// @return | table | RGB multiplier table for that category on the addressed cell.
        methods.add_method(
            "getCategoryFilter",
            |lua, this, (x, y, z, category): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                let value = this.inner.borrow().category_filter(coord, &category);
                let table = lua.create_table()?;
                table.set(1, value[0])?;
                table.set(2, value[1])?;
                table.set(3, value[2])?;
                Ok(table)
            },
        );

        // -- footprintPassable --
        /// Returns whether a rectangular footprint can occupy a cell anchor for a category.
        /// @param | x | integer | One-based anchor column.
        /// @param | y | integer | One-based anchor row.
        /// @param | z | integer? | Optional one-based level index, defaulting to 1.
        /// @param | w | integer | Footprint width in cells.
        /// @param | h | integer | Footprint height in cells.
        /// @param | category | string | Category name to test against blockers and costs.
        /// @return | boolean | True when the footprint can be placed at the addressed anchor cell.
        methods.add_method(
            "footprintPassable",
            |_, this, (x, y, z, w, h, category): (u32, u32, Option<u32>, u32, u32, String)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this
                    .inner
                    .borrow()
                    .footprint_passable(coord, w, h, &category))
            },
        );

        // -- getVersion --
        /// Returns the current tilefield data version.
        /// @return | integer | Monotonic field version incremented by data mutations.
        methods.add_method("getVersion", |_, this, ()| {
            Ok(this.inner.borrow().version())
        });

        // -- beginEdit --
        /// Starts a nested grouped edit without discarding pending dirty rectangles.
        methods.add_method("beginEdit", |_, this, ()| {
            this.inner.borrow_mut().begin_edit();
            Ok(())
        });

        // -- getDirtyRects --
        /// Returns pending dirty cell rectangles without clearing them.
        /// @param | chunkSize | integer? | Optional chunk size used to add cx/cy fields to each dirty rect.
        /// @return | table | Array of `{x, y, z, w, h, cx?, cy?}` one-based dirty rectangles.
        methods.add_method("getDirtyRects", |lua, this, chunk_size: Option<u32>| {
            let field = this.inner.borrow();
            dirty_rects_to_lua(lua, field.dirty_rects(), chunk_size)
        });

        // -- drainDirtyRects --
        /// Clears and returns pending dirty cell rectangles.
        /// @param | chunkSize | integer? | Optional chunk size used to add cx/cy fields to each dirty rect.
        /// @return | table | Array of `{x, y, z, w, h, cx?, cy?}` one-based dirty rectangles.
        methods.add_method("drainDirtyRects", |lua, this, chunk_size: Option<u32>| {
            let rects = this.inner.borrow_mut().drain_dirty_rects();
            dirty_rects_to_lua(lua, &rects, chunk_size)
        });

        // -- commitEdit --
        /// Closes the outermost grouped edit and clears/returns its coalesced dirty rectangles.
        /// @param | chunkSize | integer? | Optional chunk size used to add cx/cy fields to each dirty rect.
        /// @return | table | Array of `{x, y, z, w, h, cx?, cy?}` one-based dirty rectangles.
        methods.add_method("commitEdit", |lua, this, chunk_size: Option<u32>| {
            let rects = this.inner.borrow_mut().commit_edit();
            dirty_rects_to_lua(lua, &rects, chunk_size)
        });

        // -- defineBlockWorldSlots --
        /// Defines conventional ref slots for mutable block worlds without adding a new module.
        /// @return | table | Slot names: foreground, wall, platform, ore, furniture, liquid, spawn, biome.
        methods.add_method("defineBlockWorldSlots", |lua, this, ()| {
            {
                let mut field = this.inner.borrow_mut();
                for slot in BLOCK_WORLD_REF_SLOTS {
                    field
                        .define_slot((*slot).to_string())
                        .map_err(|e| lua_err("defineBlockWorldSlots", e))?;
                }
            }
            let out = lua.create_table()?;
            for (index, slot) in BLOCK_WORLD_REF_SLOTS.iter().enumerate() {
                out.set(index + 1, *slot)?;
            }
            Ok(out)
        });

        // -- snapshot --
        /// Captures block/cost/ref layers plus resource, buildable, and occupant cell facts.
        /// @return | table | Snapshot table suitable for `restore`.
        methods.add_method("snapshot", |lua, this, ()| {
            let field = this.inner.borrow();
            let (width, height, levels) = field.size();
            let limits = field.limits();
            let dense_cells = u64::from(width)
                .checked_mul(u64::from(height))
                .and_then(|value| value.checked_mul(u64::from(levels)))
                .ok_or_else(|| lua_err("snapshot", "field cell count overflow"))?;
            let layer_entries = dense_cells
                .checked_mul(TILEFIELD_CHANNELS.len() as u64)
                .and_then(|value| value.checked_mul(2))
                .ok_or_else(|| lua_err("snapshot", "snapshot entry count overflow"))?;
            if layer_entries > limits.max_snapshot_entries as u64 {
                return Err(lua_err(
                    "snapshot",
                    "snapshot entries exceed configured limit",
                ));
            }
            let snapshot = lua.create_table()?;
            snapshot.set("width", width)?;
            snapshot.set("height", height)?;
            snapshot.set("levels", levels)?;
            snapshot.set("topology", field.topology().as_str())?;

            let slots = field.ref_slots();
            let slot_table = lua.create_table()?;
            for (index, slot) in slots.iter().enumerate() {
                slot_table.set(index + 1, slot.as_str())?;
            }
            snapshot.set("slots", slot_table)?;

            let blocks = lua.create_table()?;
            let costs = lua.create_table()?;
            for channel in TILEFIELD_CHANNELS {
                let block_layers = lua.create_table()?;
                let cost_layers = lua.create_table()?;
                for z in 0..levels {
                    block_layers.set(
                        z + 1,
                        export_bool_layer(lua, field.export_block_layer(*channel, z))?,
                    )?;
                    cost_layers.set(
                        z + 1,
                        export_number_layer(lua, field.export_cost_layer(*channel, z))?,
                    )?;
                }
                blocks.set(channel.as_str(), block_layers)?;
                costs.set(channel.as_str(), cost_layers)?;
            }
            snapshot.set("blocks", blocks)?;
            snapshot.set("costs", costs)?;

            let refs = lua.create_table()?;
            for slot in &slots {
                let layers = lua.create_table()?;
                for z in 0..levels {
                    layers.set(
                        z + 1,
                        export_ref_layer(lua, field.export_ref_layer(slot, z))?,
                    )?;
                }
                refs.set(slot.as_str(), layers)?;
            }
            snapshot.set("refs", refs)?;

            let resources = lua.create_table()?;
            let mut resource_entries = 0usize;
            for (index, (coord, resource)) in field.resource_cells().into_iter().enumerate() {
                resource_entries = resource_entries
                    .checked_add(1)
                    .ok_or_else(|| lua_err("snapshot", "resource entry count overflow"))?;
                if resource_entries > limits.max_snapshot_entries {
                    return Err(lua_err(
                        "snapshot",
                        "resource entries exceed configured limit",
                    ));
                }
                resources.set(
                    index + 1,
                    coord_value_table(lua, coord, "resource", resource)?,
                )?;
            }
            snapshot.set("resources", resources)?;

            let buildable = lua.create_table()?;
            let mut buildable_entries = 0usize;
            for (index, (coord, value)) in field.buildable_cells().into_iter().enumerate() {
                buildable_entries = buildable_entries
                    .checked_add(1)
                    .ok_or_else(|| lua_err("snapshot", "buildable entry count overflow"))?;
                if buildable_entries > limits.max_snapshot_entries {
                    return Err(lua_err(
                        "snapshot",
                        "buildable entries exceed configured limit",
                    ));
                }
                buildable.set(
                    index + 1,
                    coord_value_table(lua, coord, "buildable", value)?,
                )?;
            }
            snapshot.set("buildable", buildable)?;

            let occupants = lua.create_table()?;
            let mut occupant_entries = 0usize;
            for (index, (coord, value)) in field.occupant_cells().into_iter().enumerate() {
                occupant_entries = occupant_entries
                    .checked_add(1)
                    .ok_or_else(|| lua_err("snapshot", "occupant entry count overflow"))?;
                if occupant_entries > limits.max_snapshot_entries {
                    return Err(lua_err(
                        "snapshot",
                        "occupant entries exceed configured limit",
                    ));
                }
                occupants.set(index + 1, coord_value_table(lua, coord, "occupant", value)?)?;
            }
            snapshot.set("occupants", occupants)?;
            Ok(snapshot)
        });

        // -- restore --
        /// Transactionally replaces this tilefield state from a snapshot returned by `snapshot`; failures preserve the original state.
        /// @param | snapshot | table | Snapshot table.
        methods.add_method("restore", |_, this, snapshot: LuaTable| {
            let limits = this.inner.borrow().limits();
            let width: u32 = snapshot.get("width").map_err(|e| lua_err("restore", e))?;
            let height: u32 = snapshot.get("height").map_err(|e| lua_err("restore", e))?;
            let levels: u32 = snapshot.get("levels").map_err(|e| lua_err("restore", e))?;
            let topology_name: String = snapshot
                .get("topology")
                .map_err(|e| lua_err("restore", e))?;
            let topology =
                TileTopology::parse(&topology_name).map_err(|e| lua_err("restore", e))?;
            let dense_cells = u64::from(width)
                .checked_mul(u64::from(height))
                .and_then(|value| value.checked_mul(u64::from(levels)))
                .ok_or_else(|| lua_err("restore", "snapshot cell count overflow"))?;
            if dense_cells > limits.max_snapshot_entries as u64 {
                return Err(lua_err("restore", "snapshot dense entries exceed limit"));
            }
            let layer_cells = usize::try_from(u64::from(width) * u64::from(height))
                .map_err(|_| lua_err("restore", "snapshot layer cell count is not addressable"))?;
            if layer_cells > limits.max_snapshot_entries {
                return Err(lua_err("restore", "snapshot layer entries exceed limit"));
            }
            let mut field = TileField::new_with_limits(width, height, levels, topology, limits)
                .map_err(|e| lua_err("restore", e))?;

            if let Some(slots) = snapshot
                .get::<_, Option<LuaTable>>("slots")
                .map_err(|e| lua_err("restore", e))?
            {
                let mut slot_entries = 0usize;
                for slot in slots.sequence_values::<String>() {
                    slot_entries = slot_entries
                        .checked_add(1)
                        .ok_or_else(|| lua_err("restore", "slot entry count overflow"))?;
                    if slot_entries > limits.max_snapshot_entries {
                        return Err(lua_err("restore", "slot entries exceed configured limit"));
                    }
                    field
                        .define_slot(slot.map_err(|e| lua_err("restore", e))?)
                        .map_err(|e| lua_err("restore", e))?;
                }
            }

            if let Some(blocks) = snapshot
                .get::<_, Option<LuaTable>>("blocks")
                .map_err(|e| lua_err("restore", e))?
            {
                for channel in TILEFIELD_CHANNELS {
                    if let Some(layers) = blocks
                        .get::<_, Option<LuaTable>>(channel.as_str())
                        .map_err(|e| lua_err("restore", e))?
                    {
                        for z in 0..levels {
                            if let Some(values) = layers
                                .get::<_, Option<LuaTable>>(z + 1)
                                .map_err(|e| lua_err("restore", e))?
                            {
                                let values = read_bool_layer(values, layer_cells, "restore")?;
                                field
                                    .write_block_layer(*channel, z, &values)
                                    .map_err(|e| lua_err("restore", e))?;
                            }
                        }
                    }
                }
            }

            if let Some(costs) = snapshot
                .get::<_, Option<LuaTable>>("costs")
                .map_err(|e| lua_err("restore", e))?
            {
                for channel in TILEFIELD_CHANNELS {
                    if let Some(layers) = costs
                        .get::<_, Option<LuaTable>>(channel.as_str())
                        .map_err(|e| lua_err("restore", e))?
                    {
                        for z in 0..levels {
                            if let Some(values) = layers
                                .get::<_, Option<LuaTable>>(z + 1)
                                .map_err(|e| lua_err("restore", e))?
                            {
                                let values = read_number_layer(values, layer_cells, "restore")?;
                                field
                                    .write_cost_layer(*channel, z, &values)
                                    .map_err(|e| lua_err("restore", e))?;
                            }
                        }
                    }
                }
            }

            if let Some(refs) = snapshot
                .get::<_, Option<LuaTable>>("refs")
                .map_err(|e| lua_err("restore", e))?
            {
                for slot in field.ref_slots() {
                    if let Some(layers) = refs
                        .get::<_, Option<LuaTable>>(slot.as_str())
                        .map_err(|e| lua_err("restore", e))?
                    {
                        for z in 0..levels {
                            if let Some(values) = layers
                                .get::<_, Option<LuaTable>>(z + 1)
                                .map_err(|e| lua_err("restore", e))?
                            {
                                let values =
                                    read_optional_u32_layer(values, layer_cells, "restore")?;
                                field
                                    .write_ref_layer(&slot, z, &values)
                                    .map_err(|e| lua_err("restore", e))?;
                            }
                        }
                    }
                }
            }

            if let Some(resources) = snapshot
                .get::<_, Option<LuaTable>>("resources")
                .map_err(|e| lua_err("restore", e))?
            {
                let mut seen = HashSet::new();
                let mut resource_entries = 0usize;
                for row in resources.sequence_values::<LuaTable>() {
                    resource_entries = resource_entries
                        .checked_add(1)
                        .ok_or_else(|| lua_err("restore", "resource entry count overflow"))?;
                    if resource_entries > limits.max_snapshot_entries {
                        return Err(lua_err(
                            "restore",
                            "resource entries exceed configured limit",
                        ));
                    }
                    let row = row.map_err(|e| lua_err("restore", e))?;
                    let coord = coord_from_table(row.clone(), "restore")?;
                    if !seen.insert(coord) {
                        return Err(lua_err("restore", "duplicate resource record"));
                    }
                    let resource: Option<String> =
                        row.get("resource").map_err(|e| lua_err("restore", e))?;
                    field
                        .set_resource(coord, resource)
                        .map_err(|e| lua_err("restore", e))?;
                }
            }

            if let Some(buildable) = snapshot
                .get::<_, Option<LuaTable>>("buildable")
                .map_err(|e| lua_err("restore", e))?
            {
                let mut seen = HashSet::new();
                let mut buildable_entries = 0usize;
                for row in buildable.sequence_values::<LuaTable>() {
                    buildable_entries = buildable_entries
                        .checked_add(1)
                        .ok_or_else(|| lua_err("restore", "buildable entry count overflow"))?;
                    if buildable_entries > limits.max_snapshot_entries {
                        return Err(lua_err(
                            "restore",
                            "buildable entries exceed configured limit",
                        ));
                    }
                    let row = row.map_err(|e| lua_err("restore", e))?;
                    let coord = coord_from_table(row.clone(), "restore")?;
                    if !seen.insert(coord) {
                        return Err(lua_err("restore", "duplicate buildable record"));
                    }
                    let value: bool = row.get("buildable").map_err(|e| lua_err("restore", e))?;
                    field
                        .set_buildable(coord, value)
                        .map_err(|e| lua_err("restore", e))?;
                }
            }

            if let Some(occupants) = snapshot
                .get::<_, Option<LuaTable>>("occupants")
                .map_err(|e| lua_err("restore", e))?
            {
                let mut seen = HashSet::new();
                let mut occupant_entries = 0usize;
                for row in occupants.sequence_values::<LuaTable>() {
                    occupant_entries = occupant_entries
                        .checked_add(1)
                        .ok_or_else(|| lua_err("restore", "occupant entry count overflow"))?;
                    if occupant_entries > limits.max_snapshot_entries {
                        return Err(lua_err(
                            "restore",
                            "occupant entries exceed configured limit",
                        ));
                    }
                    let row = row.map_err(|e| lua_err("restore", e))?;
                    let coord = coord_from_table(row.clone(), "restore")?;
                    if !seen.insert(coord) {
                        return Err(lua_err("restore", "duplicate occupant record"));
                    }
                    let occupant: u64 = row.get("occupant").map_err(|e| lua_err("restore", e))?;
                    field
                        .set_occupant(coord, occupant)
                        .map_err(|e| lua_err("restore", e))?;
                }
            }

            *this.inner.borrow_mut() = field;
            Ok(())
        });

        // -- setSunOcclusion --
        /// Sets top-light occlusion in the inclusive range 0..1.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | value | number | Top-light occlusion value in the inclusive range 0..1.
        methods.add_method(
            "setSunOcclusion",
            |_, this, (x, y, z, value): (u32, u32, Option<u32>, f32)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .set_sun_occlusion(coord, value)
                    .map_err(|e| lua_err("setSunOcclusion", e))
            },
        );

        // -- getSunOcclusion --
        /// Returns top-light occlusion in the inclusive range 0..1.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | number | Top-light occlusion value in the inclusive range 0..1.
        methods.add_method(
            "getSunOcclusion",
            |_, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this.inner.borrow().sun_occlusion(coord))
            },
        );

        // -- setModifier --
        /// Registers or replaces a named tile modifier.
        /// @param | name | string | Modifier name.
        /// @param | modifier | table | Modifier table with blocks, costAdd, costMul, sunOcclusionAdd, light, properties.
        methods.add_method(
            "setModifier",
            |_, this, (name, table): (String, LuaTable)| {
                let modifier = modifier_from_table(name.clone(), table, "setModifier")?;
                this.inner
                    .borrow_mut()
                    .set_modifier(name, modifier)
                    .map_err(|e| lua_err("setModifier", e))
            },
        );

        // -- getModifier --
        /// Returns a named tile modifier table, or nil.
        /// @param | name | string | Modifier name.
        /// @return | table|nil | Modifier table.
        methods.add_method("getModifier", |lua, this, name: String| {
            let field = this.inner.borrow();
            match field.modifier(&name) {
                Some(modifier) => Ok(Some(modifier_to_lua(lua, modifier)?)),
                None => Ok(None),
            }
        });

        // -- setProfile --
        /// Registers or replaces a legacy tilefield profile.
        /// @param | name | string | Profile name.
        /// @param | profile | table | Profile table with blocks, costs, sunOcclusion, light, or properties.
        methods.add_method(
            "setProfile",
            |_, this, (name, table): (String, LuaTable)| {
                let profile = profile_modifier_from_table(name.clone(), table, "setProfile")?;
                this.inner
                    .borrow_mut()
                    .set_modifier(name, profile)
                    .map_err(|e| lua_err("setProfile", e))
            },
        );

        // -- getProfile --
        /// Returns a legacy profile table, or nil.
        /// @param | name | string | Profile name.
        /// @return | table|nil | Profile table.
        methods.add_method("getProfile", |lua, this, name: String| {
            let field = this.inner.borrow();
            match field.modifier(&name) {
                Some(profile) => Ok(Some(profile_to_lua(lua, profile)?)),
                None => Ok(None),
            }
        });

        // -- removeProfile --
        /// Removes a legacy profile and clears it from all cells.
        /// @param | name | string | Profile name.
        /// @return | boolean | True when removed.
        methods.add_method("removeProfile", |_, this, name: String| {
            this.inner
                .borrow_mut()
                .try_remove_modifier(&name)
                .map_err(|e| lua_err("removeProfile", e))
        });

        // -- removeModifier --
        /// Removes a named modifier and clears it from all cells.
        /// @param | name | string | Modifier name.
        /// @return | boolean | True when removed.
        methods.add_method("removeModifier", |_, this, name: String| {
            this.inner
                .borrow_mut()
                .try_remove_modifier(&name)
                .map_err(|e| lua_err("removeModifier", e))
        });

        // -- defineSlot --
        /// Defines a named object slot that cells may reference.
        /// @param | slot | string | Slot name chosen by the Lua game.
        methods.add_method("defineSlot", |_, this, slot: String| {
            this.inner
                .borrow_mut()
                .define_slot(slot)
                .map_err(|e| lua_err("defineSlot", e))
        });

        // -- removeSlot --
        /// Removes a named object slot and clears its references from the field.
        /// @param | slot | string | Slot name.
        /// @return | boolean | True when the slot existed.
        methods.add_method("removeSlot", |_, this, slot: String| {
            this.inner
                .borrow_mut()
                .try_remove_slot(&slot)
                .map_err(|e| lua_err("removeSlot", e))
        });

        // -- hasSlot --
        /// Returns true when a named object slot is declared.
        /// @param | slot | string | Slot name.
        /// @return | boolean | True when declared.
        methods.add_method("hasSlot", |_, this, slot: String| {
            Ok(this.inner.borrow().has_slot(&slot))
        });

        // -- setRef --
        /// Sets a named object/tile reference on one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | slot | string | Reference slot name defined by the Lua game.
        /// @param | value | integer|table | Legacy id or typed `{ tileset, tile?/object? }` ref stored for the slot.
        methods.add_method(
            "setRef",
            |_, this, (x, y, z, slot, value): (u32, u32, Option<u32>, String, LuaValue)| {
                let coord = coord_from_values(x, y, z)?;
                match value {
                    LuaValue::Integer(value) if value >= 0 && value <= u32::MAX as i64 => this
                        .inner
                        .borrow_mut()
                        .set_ref(coord, slot, value as u32)
                        .map_err(|e| lua_err("setRef", e)),
                    LuaValue::Number(value)
                        if value >= 0.0 && value.fract() == 0.0 && value <= u32::MAX as f64 =>
                    {
                        this.inner
                            .borrow_mut()
                            .set_ref(coord, slot, value as u32)
                            .map_err(|e| lua_err("setRef", e))
                    }
                    LuaValue::Table(value) => {
                        let typed = tile_ref_from_table(value, "setRef")?;
                        this.inner
                            .borrow_mut()
                            .set_typed_ref(coord, slot, typed)
                            .map_err(|e| lua_err("setRef", e))
                    }
                    other => Err(lua_err(
                        "setRef",
                        format!("value must be integer or table, got {}", other.type_name()),
                    )),
                }
            },
        );

        // -- getRef --
        /// Returns a named object/tile reference from one cell, or nil.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | slot | string | Reference slot name.
        /// @return | integer|table|nil | Stored legacy id, typed ref table, or nil when unset.
        methods.add_method(
            "getRef",
            |lua, this, (x, y, z, slot): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                let field = this.inner.borrow();
                if let Some(value) = field.get_typed_ref(coord, &slot) {
                    return Ok(LuaValue::Table(tile_ref_to_lua(lua, value)?));
                }
                match field.get_ref(coord, &slot) {
                    Some(value) => Ok(LuaValue::Integer(value.into())),
                    None => Ok(LuaValue::Nil),
                }
            },
        );

        // -- applyModifier --
        /// Applies a named modifier to one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | modifier | string | Modifier name.
        methods.add_method(
            "applyModifier",
            |_, this, (x, y, z, modifier): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .apply_modifier(coord, &modifier)
                    .map_err(|e| lua_err("applyModifier", e))
            },
        );

        // -- applyProfile --
        /// Applies a legacy profile to one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | profile | string | Profile name.
        methods.add_method(
            "applyProfile",
            |_, this, (x, y, z, profile): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .apply_modifier(coord, &profile)
                    .map_err(|e| lua_err("applyProfile", e))
            },
        );

        // -- clearModifier --
        /// Removes one modifier from one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | modifier | string | Modifier name.
        /// @return | boolean | True when the cell had the modifier.
        methods.add_method(
            "clearModifier",
            |_, this, (x, y, z, modifier): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .clear_modifier(coord, &modifier)
                    .map_err(|e| lua_err("clearModifier", e))
            },
        );

        // -- getModifiers --
        /// Returns active modifier names on one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | string[] | Active modifier names.
        methods.add_method(
            "getModifiers",
            |lua, this, (x, y, z): (u32, u32, Option<u32>)| {
                let coord = coord_from_values(x, y, z)?;
                let modifiers = this.inner.borrow().active_modifiers(coord);
                let table = lua.create_table()?;
                for (index, modifier) in modifiers.into_iter().enumerate() {
                    table.set(index + 1, modifier)?;
                }
                Ok(table)
            },
        );

        // -- applyTilesetObject --
        /// Applies the object archetype defaults for a tileset tile referenced from one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | slot | string | Reference slot name.
        /// @param | tileset | LTileSet | Tileset that stores object archetype metadata.
        /// @param | opts | table? | Options: refIsGid.
        /// @return | boolean | True when the tileset object was found and applied.
        methods.add_method(
            "applyTilesetObject",
            |_,
             this,
             (x, y, z, slot, tileset_ud, opts): (
                u32,
                u32,
                Option<u32>,
                String,
                LuaAnyUserData,
                Option<LuaTable>,
            )| {
                let coord = coord_from_values(x, y, z)?;
                let ref_is_gid = opts
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<bool>>("refIsGid").ok().flatten())
                    .unwrap_or(false);
                let mut field = this.inner.borrow_mut();
                let Some(ref_value) = field.get_ref(coord, &slot) else {
                    return Ok(false);
                };
                let tileset_ud = tileset_ud.borrow::<LuaTileSet>()?;
                let tileset = tileset_ud.inner.borrow();
                let Some(local_tile_id) = tileset_local_id_from_ref(
                    &tileset,
                    ref_value,
                    ref_is_gid,
                    "applyTilesetObject",
                )?
                else {
                    return Ok(false);
                };
                apply_tileset_object_to_field(
                    &mut field,
                    coord,
                    &tileset,
                    local_tile_id,
                    "applyTilesetObject",
                )
            },
        );

        // -- applyTilesetObjectLayer --
        /// Applies tileset object defaults for every referenced cell on one tilefield level.
        /// @param | slot | string | Reference slot name.
        /// @param | tileset | LTileSet | Tileset that stores object metadata.
        /// @param | opts | table? | Options: z, refIsGid.
        /// @return | integer | Number of cells that received object defaults.
        methods.add_method(
            "applyTilesetObjectLayer",
            |_, this, (slot, tileset_ud, opts): (String, LuaAnyUserData, Option<LuaTable>)| {
                let z = opts
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<u32>>("z").ok().flatten())
                    .unwrap_or(1)
                    .checked_sub(1)
                    .ok_or_else(|| lua_err("applyTilesetObjectLayer", "z must be >= 1"))?;
                let ref_is_gid = opts
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<bool>>("refIsGid").ok().flatten())
                    .unwrap_or(false);
                let tileset_ud = tileset_ud.borrow::<LuaTileSet>()?;
                let tileset = tileset_ud.inner.borrow();
                let mut field = this.inner.borrow_mut();
                let (width, height, levels) = field.size();
                if z >= levels {
                    return Err(lua_err("applyTilesetObjectLayer", "z is out of bounds"));
                }
                let mut applied_count = 0u32;
                for y in 0..height {
                    for x in 0..width {
                        let coord = CellCoord { x, y, z };
                        let Some(ref_value) = field.get_ref(coord, &slot) else {
                            continue;
                        };
                        let Some(local_tile_id) = tileset_local_id_from_ref(
                            &tileset,
                            ref_value,
                            ref_is_gid,
                            "applyTilesetObjectLayer",
                        )?
                        else {
                            continue;
                        };
                        if apply_tileset_object_to_field(
                            &mut field,
                            coord,
                            &tileset,
                            local_tile_id,
                            "applyTilesetObjectLayer",
                        )? {
                            applied_count = applied_count.saturating_add(1);
                        }
                    }
                }
                Ok(applied_count)
            },
        );

        // -- getRefProperty --
        /// Reads a tileset property for a tile referenced from one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | slot | string | Reference slot name.
        /// @param | tileset | LTileSet | Tileset that stores object metadata.
        /// @param | property | string | Property name to read.
        /// @param | opts | table? | Options: refIsGid.
        /// @return | string|nil | Property value, or nil when missing.
        methods.add_method(
            "getRefProperty",
            |_,
             this,
             (x, y, z, slot, tileset_ud, property, opts): (
                u32,
                u32,
                Option<u32>,
                String,
                LuaAnyUserData,
                String,
                Option<LuaTable>,
            )| {
                let coord = coord_from_values(x, y, z)?;
                let ref_is_gid = opts
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<bool>>("refIsGid").ok().flatten())
                    .unwrap_or(false);
                let field = this.inner.borrow();
                let Some(ref_value) = field.get_ref(coord, &slot) else {
                    return Ok(None);
                };
                let tileset_ud = tileset_ud.borrow::<LuaTileSet>()?;
                let tileset = tileset_ud.inner.borrow();
                let local_tile_id = if ref_is_gid {
                    let first_gid = tileset.get_first_gid();
                    if ref_value < first_gid {
                        return Ok(None);
                    }
                    ref_value - first_gid
                } else {
                    one_based(ref_value, "ref")?
                };
                Ok(tileset_property_for_tile(
                    &tileset,
                    local_tile_id,
                    &property,
                ))
            },
        );

        // -- getRefPropertyNumber --
        /// Reads a tileset property for a tile referenced from one cell and parses it as a number.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | slot | string | Reference slot name.
        /// @param | tileset | LTileSet | Tileset that stores object metadata.
        /// @param | property | string | Property name to read.
        /// @param | opts | table? | Options: refIsGid.
        /// @return | number|nil | Numeric property value, or nil when missing/not numeric.
        methods.add_method(
            "getRefPropertyNumber",
            |_,
             this,
             (x, y, z, slot, tileset_ud, property, opts): (
                u32,
                u32,
                Option<u32>,
                String,
                LuaAnyUserData,
                String,
                Option<LuaTable>,
            )| {
                let coord = coord_from_values(x, y, z)?;
                let ref_is_gid = opts
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<bool>>("refIsGid").ok().flatten())
                    .unwrap_or(false);
                let field = this.inner.borrow();
                let Some(ref_value) = field.get_ref(coord, &slot) else {
                    return Ok(None);
                };
                let tileset_ud = tileset_ud.borrow::<LuaTileSet>()?;
                let tileset = tileset_ud.inner.borrow();
                let local_tile_id = if ref_is_gid {
                    let first_gid = tileset.get_first_gid();
                    if ref_value < first_gid {
                        return Ok(None);
                    }
                    ref_value - first_gid
                } else {
                    one_based(ref_value, "ref")?
                };
                Ok(
                    tileset_property_for_tile(&tileset, local_tile_id, &property)
                        .and_then(|value| value.parse::<f64>().ok()),
                )
            },
        );

        // -- getRefPropertyBool --
        /// Reads a tileset property for a tile referenced from one cell and parses it as a boolean.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | slot | string | Reference slot name.
        /// @param | tileset | LTileSet | Tileset that stores object metadata.
        /// @param | property | string | Property name to read.
        /// @param | opts | table? | Options: refIsGid.
        /// @return | boolean|nil | Boolean property value, or nil when missing/not boolean.
        methods.add_method(
            "getRefPropertyBool",
            |_,
             this,
             (x, y, z, slot, tileset_ud, property, opts): (
                u32,
                u32,
                Option<u32>,
                String,
                LuaAnyUserData,
                String,
                Option<LuaTable>,
            )| {
                let coord = coord_from_values(x, y, z)?;
                let ref_is_gid = opts
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<bool>>("refIsGid").ok().flatten())
                    .unwrap_or(false);
                let field = this.inner.borrow();
                let Some(ref_value) = field.get_ref(coord, &slot) else {
                    return Ok(None);
                };
                let tileset_ud = tileset_ud.borrow::<LuaTileSet>()?;
                let tileset = tileset_ud.inner.borrow();
                let local_tile_id = if ref_is_gid {
                    let first_gid = tileset.get_first_gid();
                    if ref_value < first_gid {
                        return Ok(None);
                    }
                    ref_value - first_gid
                } else {
                    one_based(ref_value, "ref")?
                };
                Ok(
                    tileset_property_for_tile(&tileset, local_tile_id, &property)
                        .and_then(|value| property_string_to_bool(&value)),
                )
            },
        );

        // -- getRefProperties --
        /// Reads all tileset properties for a tile referenced from one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | slot | string | Reference slot name.
        /// @param | tileset | LTileSet | Tileset that stores object metadata.
        /// @param | opts | table? | Options: refIsGid.
        /// @return | table|nil | Property name/value table, or nil when the ref is missing/outside the tileset.
        methods.add_method(
            "getRefProperties",
            |lua,
             this,
             (x, y, z, slot, tileset_ud, opts): (
                u32,
                u32,
                Option<u32>,
                String,
                LuaAnyUserData,
                Option<LuaTable>,
            )| {
                let coord = coord_from_values(x, y, z)?;
                let ref_is_gid = opts
                    .as_ref()
                    .and_then(|table| table.get::<_, Option<bool>>("refIsGid").ok().flatten())
                    .unwrap_or(false);
                let field = this.inner.borrow();
                let Some(ref_value) = field.get_ref(coord, &slot) else {
                    return Ok(None);
                };
                let tileset_ud = tileset_ud.borrow::<LuaTileSet>()?;
                let tileset = tileset_ud.inner.borrow();
                let local_tile_id = if ref_is_gid {
                    let first_gid = tileset.get_first_gid();
                    if ref_value < first_gid {
                        return Ok(None);
                    }
                    ref_value - first_gid
                } else {
                    one_based(ref_value, "ref")?
                };
                let table = lua.create_table()?;
                if let Some(object) = tileset.archetype_for_tile(local_tile_id) {
                    for (name, value) in &object.properties {
                        table.set(name.as_str(), value.as_str())?;
                    }
                }
                if let Some(properties) = tileset.properties(local_tile_id) {
                    for (name, value) in properties {
                        table.set(name.as_str(), value.as_str())?;
                    }
                }
                Ok(Some(table))
            },
        );

        // -- clearRef --
        /// Clears a named object/tile reference from one cell.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | slot | string | Reference slot name.
        methods.add_method(
            "clearRef",
            |_, this, (x, y, z, slot): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                let mut field = this.inner.borrow_mut();
                field
                    .clear_ref(coord, &slot)
                    .map_err(|e| lua_err("clearRef", e))?;
                field
                    .set_light(coord, slot, None)
                    .map_err(|e| lua_err("clearRef", e))
            },
        );

        // -- getRefSlots --
        /// Returns the sorted names of every declared reference slot.
        /// @return | string[] | Ref slot names.
        methods.add_method("getRefSlots", |lua, this, ()| {
            let slots = this.inner.borrow().ref_slots();
            let table = lua.create_table()?;
            for (index, slot) in slots.into_iter().enumerate() {
                table.set(index + 1, slot)?;
            }
            Ok(table)
        });

        // -- line --
        /// Returns topology-aware one-based cells between `from` and `to` tables.
        /// @param | opts | table | `{from={x,y,z?}, to={x,y,z?}, includeEndpoints?}`.
        methods.add_method("line", |lua, this, opts: LuaTable| {
            let from = coord_from_table(opts.get("from")?, "line")?;
            let to = coord_from_table(opts.get("to")?, "line")?;
            let include = opts
                .get::<_, Option<bool>>("includeEndpoints")?
                .unwrap_or(true);
            let cells = this
                .inner
                .borrow()
                .line(from, to, include)
                .map_err(|e| lua_err("line", e))?;
            cells_to_lua(lua, cells)
        });

        // -- clearLine --
        /// Returns true when the line between two cell tables has no blocker for a channel.
        /// @param | from_tbl | table | Start cell table with one-based x, y, and optional z fields.
        /// @param | to_tbl | table | End cell table with one-based x, y, and optional z fields.
        /// @param | channel | string | Blocker channel name to test along the line.
        /// @param | opts | table? | Reserved optional line query options.
        /// @return | boolean | True when no blocker exists between the two cells.
        methods.add_method(
            "clearLine",
            |_, this, (from_tbl, to_tbl, channel, _opts): (LuaTable, LuaTable, String, Option<LuaTable>)| {
                let from = coord_from_table(from_tbl, "clearLine")?;
                let to = coord_from_table(to_tbl, "clearLine")?;
                let channel = channel_from_str(channel, "clearLine")?;
                this.inner
                    .borrow()
                    .clear_line(from, to, channel)
                    .map_err(|e| lua_err("clearLine", e))
            },
        );

        // -- firstBlocker --
        /// Returns the first one-based blocking cell table between two cells, or nil.
        /// @param | from_tbl | table | Start cell table with one-based x, y, and optional z fields.
        /// @param | to_tbl | table | End cell table with one-based x, y, and optional z fields.
        /// @param | channel | string | Blocker channel name to test along the line.
        /// @param | opts | table? | Reserved optional line query options.
        /// @return | table|nil | First blocking cell table, or nil when the line is clear.
        methods.add_method(
            "firstBlocker",
            |lua, this, (from_tbl, to_tbl, channel, _opts): (LuaTable, LuaTable, String, Option<LuaTable>)| {
                let from = coord_from_table(from_tbl, "firstBlocker")?;
                let to = coord_from_table(to_tbl, "firstBlocker")?;
                let channel = channel_from_str(channel, "firstBlocker")?;
                match this
                    .inner
                    .borrow()
                    .first_blocker(from, to, channel)
                    .map_err(|e| lua_err("firstBlocker", e))?
                {
                    Some(coord) => {
                        let table = lua.create_table()?;
                        table.set("x", coord.x + 1)?;
                        table.set("y", coord.y + 1)?;
                        table.set("z", coord.z + 1)?;
                        Ok(Some(table))
                    }
                    None => Ok(None),
                }
            },
        );

        // -- exportBlockLayer --
        /// Exports one blocker channel and level as a row-major boolean array.
        /// @param | channel | string | Blocker channel name to export.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | table | Row-major boolean array for the requested channel and level.
        methods.add_method(
            "exportBlockLayer",
            |lua, this, (channel, z): (String, Option<u32>)| {
                let channel = channel_from_str(channel, "exportBlockLayer")?;
                let z = one_based(z.unwrap_or(1), "z")?;
                let values = this.inner.borrow().export_block_layer(channel, z);
                export_bool_layer(lua, values)
            },
        );

        // -- exportCostLayer --
        /// Exports one cost channel and level as a row-major number array.
        /// @param | channel | string | Cost channel name to export.
        /// @param | z | integer? | One-based level, default 1.
        /// @return | table | Row-major number array for the requested channel and level.
        methods.add_method(
            "exportCostLayer",
            |lua, this, (channel, z): (String, Option<u32>)| {
                let channel = channel_from_str(channel, "exportCostLayer")?;
                let z = one_based(z.unwrap_or(1), "z")?;
                let values = this.inner.borrow().export_cost_layer(channel, z);
                export_number_layer(lua, values)
            },
        );

        // -- writeBlockLayer --
        /// Writes one full blocker channel layer from a row-major boolean array.
        /// @param | channel | string | Blocker channel name to write.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | values | table | Row-major boolean array with width*height entries.
        methods.add_method(
            "writeBlockLayer",
            |_, this, (channel, z, values): (String, Option<u32>, LuaTable)| {
                let channel = channel_from_str(channel, "writeBlockLayer")?;
                let z = one_based(z.unwrap_or(1), "z")?;
                let expected = {
                    let field = this.inner.borrow();
                    layer_value_count(&field, z, "writeBlockLayer")?
                };
                let values = read_bool_layer(values, expected, "writeBlockLayer")?;
                this.inner
                    .borrow_mut()
                    .write_block_layer(channel, z, &values)
                    .map_err(|e| lua_err("writeBlockLayer", e))
            },
        );

        // -- writeCostLayer --
        /// Writes one full cost channel layer from a row-major number array.
        /// @param | channel | string | Cost channel name to write.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | values | table | Row-major number array with width*height entries.
        methods.add_method(
            "writeCostLayer",
            |_, this, (channel, z, values): (String, Option<u32>, LuaTable)| {
                let channel = channel_from_str(channel, "writeCostLayer")?;
                let z = one_based(z.unwrap_or(1), "z")?;
                let expected = {
                    let field = this.inner.borrow();
                    layer_value_count(&field, z, "writeCostLayer")?
                };
                let values = read_number_layer(values, expected, "writeCostLayer")?;
                this.inner
                    .borrow_mut()
                    .write_cost_layer(channel, z, &values)
                    .map_err(|e| lua_err("writeCostLayer", e))
            },
        );

        // -- exportRefLayer --
        /// Exports one named object/tile reference slot and level as a row-major array.
        /// @param | slot | string | Reference slot name to export.
        /// @param | z | integer? | One-based level, default 1.
        methods.add_method(
            "exportRefLayer",
            |lua, this, (slot, z): (String, Option<u32>)| {
                let z = one_based(z.unwrap_or(1), "z")?;
                let values = this.inner.borrow().export_ref_layer(&slot, z);
                export_ref_layer(lua, values)
            },
        );

        // -- writeRefLayer --
        /// Writes one full named ref layer from a row-major integer-or-nil array.
        /// @param | slot | string | Reference slot name to write.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | values | table | Row-major integer-or-nil array with width*height entries.
        methods.add_method(
            "writeRefLayer",
            |_, this, (slot, z, values): (String, Option<u32>, LuaTable)| {
                let z = one_based(z.unwrap_or(1), "z")?;
                let expected = {
                    let field = this.inner.borrow();
                    layer_value_count(&field, z, "writeRefLayer")?
                };
                let values = read_optional_u32_layer(values, expected, "writeRefLayer")?;
                this.inner
                    .borrow_mut()
                    .write_ref_layer(&slot, z, &values)
                    .map_err(|e| lua_err("writeRefLayer", e))
            },
        );

        // -- type --
        /// Returns the Lua-visible type name for this tilefield handle.
        /// @return | string | The string `LTileField`.
        methods.add_method("type", |_, _, ()| Ok("LTileField"));

        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True for `LTileField` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTileField" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaTileFieldMap {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getMapSize --
        /// Returns field-map width, height, and layer count.
        /// @return | integer | Field-map width in field slots.
        /// @return | integer | Field-map height in field slots.
        /// @return | integer | Field-map layer count.
        methods.add_method("getMapSize", |_, this, ()| {
            Ok(this.inner.borrow().map_size())
        });

        // -- getFieldSize --
        /// Returns contained field width, height, and level count.
        /// @return | integer | Contained field width in cells.
        /// @return | integer | Contained field height in cells.
        /// @return | integer | Contained field level count.
        methods.add_method("getFieldSize", |_, this, ()| {
            Ok(this.inner.borrow().field_size())
        });

        // -- getTopology --
        /// Returns the topology shared by every contained field.
        /// @return | string | `square`, `square4`, `square8`, `iso_square`, or `hex`.
        methods.add_method("getTopology", |_, this, ()| {
            Ok(this.inner.borrow().topology().as_str().to_string())
        });

        // -- inBounds --
        /// Returns whether one-based field-map coordinates are inside the field map.
        /// @param | mapX | integer | One-based field-map column.
        /// @param | mapY | integer | One-based field-map row.
        /// @param | mapZ | integer? | One-based field-map layer, default 1.
        /// @return | boolean | True when coordinates are in bounds.
        methods.add_method(
            "inBounds",
            |_, this, (map_x, map_y, map_z): (u32, u32, Option<u32>)| {
                let x = one_based(map_x, "mapX");
                let y = one_based(map_y, "mapY");
                let z = one_based(map_z.unwrap_or(1), "mapZ");
                match (x, y, z) {
                    (Ok(x), Ok(y), Ok(z)) => Ok(this.inner.borrow().in_bounds(x, y, z)),
                    _ => Ok(false),
                }
            },
        );

        // -- getField --
        /// Returns the shared tilefield at one field-map coordinate.
        /// @param | mapX | integer | One-based field-map column.
        /// @param | mapY | integer | One-based field-map row.
        /// @param | mapZ | integer? | One-based field-map layer, default 1.
        /// @return | LTileField | Shared tilefield handle.
        methods.add_method(
            "getField",
            |_, this, (map_x, map_y, map_z): (u32, u32, Option<u32>)| {
                let x = one_based(map_x, "mapX")?;
                let y = one_based(map_y, "mapY")?;
                let z = one_based(map_z.unwrap_or(1), "mapZ")?;
                let field =
                    this.inner.borrow().field(x, y, z).ok_or_else(|| {
                        lua_err("getField", "field-map coordinate is out of bounds")
                    })?;
                Ok(LuaTileField { inner: field })
            },
        );

        // -- setField --
        /// Replaces one field-map slot with an existing compatible tilefield handle.
        /// @param | mapX | integer | One-based field-map column.
        /// @param | mapY | integer | One-based field-map row.
        /// @param | mapZ | integer? | One-based field-map layer, default 1.
        /// @param | field | LTileField | Existing compatible tilefield handle.
        methods.add_method(
            "setField",
            |_, this, (map_x, map_y, map_z, field_ud): (u32, u32, Option<u32>, LuaAnyUserData)| {
                let x = one_based(map_x, "mapX")?;
                let y = one_based(map_y, "mapY")?;
                let z = one_based(map_z.unwrap_or(1), "mapZ")?;
                let field = field_ud.borrow::<LuaTileField>()?;
                this.inner
                    .borrow_mut()
                    .set_field(x, y, z, Rc::clone(&field.inner))
                    .map_err(|e| lua_err("setField", e))
            },
        );

        // -- type --
        /// Returns the Lua-visible type name for this tilefield map handle.
        /// @return | string | The string `LTileFieldMap`.
        methods.add_method("type", |_, _, ()| Ok("LTileFieldMap"));

        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True for `LTileFieldMap` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTileFieldMap" || name == "LObject")
        });
    }
}

/// Registers `lurek.tilefield`.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // --- Public module functions ---

    // -- new --
    /// Creates a multi-level tilefield with explicit dimensions and topology.
    /// @param | opts | table | `{width, height, levels?, topology?, limits?}`; limits use `maxCells`, `maxLevels`, collection ceilings, and checked provider/snapshot bounds.
    /// @return | LTileField | New tilefield handle.
    tbl.set(
        "new",
        lua.create_function(|_, opts: LuaTable| {
            let width: u32 = opts.get("width").map_err(|e| lua_err("new", e))?;
            let height: u32 = opts.get("height").map_err(|e| lua_err("new", e))?;
            let levels: u32 = opts
                .get::<_, Option<u32>>("levels")
                .map_err(|e| lua_err("new", e))?
                .unwrap_or(1);
            let topology_name = opts
                .get::<_, Option<String>>("topology")
                .map_err(|e| lua_err("new", e))?
                .unwrap_or_else(|| "square".to_string());
            let topology = TileTopology::parse(&topology_name).map_err(|e| lua_err("new", e))?;
            let limits = tilefield_limits_from_opts(Some(&opts), "new")?;
            let field = TileField::new_with_limits(width, height, levels, topology, limits)
                .map_err(|e| lua_err("new", e))?;
            Ok(LuaTileField {
                inner: Rc::new(RefCell::new(field)),
            })
        })?,
    )?;

    // -- fromProvider --
    /// Builds a native tilefield from a Lua provider table with width, height, optional levels/topology, slots, modifiers, regions, and optional getCell(x,y,z).
    /// @param | provider | table | Lua-authored tilefield provider.
    /// @return | LTileField | New tilefield copied from the provider.
    tbl.set(
        "fromProvider",
        lua.create_function(|_, provider: LuaTable| {
            let field = field_from_provider(provider, "fromProvider")?;
            Ok(LuaTileField {
                inner: Rc::new(RefCell::new(field)),
            })
        })?,
    )?;

    // -- newFieldMap --
    /// Creates a 2D or layered map of shared tilefields.
    /// @param | opts | table | `{width, height, layers?, fieldWidth, fieldHeight, fieldLevels?, topology?, limits?}`.
    /// @return | LTileFieldMap | New tilefield map handle.
    tbl.set(
        "newFieldMap",
        lua.create_function(|_, opts: LuaTable| {
            let width: u32 = opts.get("width").map_err(|e| lua_err("newFieldMap", e))?;
            let height: u32 = opts.get("height").map_err(|e| lua_err("newFieldMap", e))?;
            let layers: u32 = opts
                .get::<_, Option<u32>>("layers")
                .map_err(|e| lua_err("newFieldMap", e))?
                .unwrap_or(1);
            let field_width: u32 = opts
                .get("fieldWidth")
                .map_err(|e| lua_err("newFieldMap", e))?;
            let field_height: u32 = opts
                .get("fieldHeight")
                .map_err(|e| lua_err("newFieldMap", e))?;
            let field_levels: u32 = opts
                .get::<_, Option<u32>>("fieldLevels")
                .map_err(|e| lua_err("newFieldMap", e))?
                .unwrap_or(1);
            let topology_name = opts
                .get::<_, Option<String>>("topology")
                .map_err(|e| lua_err("newFieldMap", e))?
                .unwrap_or_else(|| "square".to_string());
            let topology =
                TileTopology::parse(&topology_name).map_err(|e| lua_err("newFieldMap", e))?;
            let limits = tilefield_limits_from_opts(Some(&opts), "newFieldMap")?;
            let field_map = TileFieldMap::new_with_limits(
                width,
                height,
                layers,
                field_width,
                field_height,
                field_levels,
                topology,
                limits,
            )
            .map_err(|e| lua_err("newFieldMap", e))?;
            Ok(LuaTileFieldMap {
                inner: Rc::new(RefCell::new(field_map)),
            })
        })?,
    )?;

    // -- fromTileMap --
    /// Copies a tilemap layer into a tilefield, optionally applying tileset object defaults and a ref slot.
    /// @param | tilemap | LTileMap | Source tilemap.
    /// @param | opts | table? | `{layer?, level?, levels?, topology?, solidGids?, refSlot?, applyTilesetObject?}`; `solidGids` and `applyTilesetObject` are explicit, no tileset solidity is inferred.
    /// @return | LTileField | New tilefield copied from the tilemap layer.
    tbl.set(
        "fromTileMap",
        lua.create_function(|_, (tm_ud, opts): (LuaAnyUserData, Option<LuaTable>)| {
            let tilemap = tm_ud.borrow::<LuaTileMap>()?;
            let layer = one_based(
                match &opts {
                    Some(opts) => opts
                        .get::<_, Option<u32>>("layer")
                        .map_err(|e| lua_err("fromTileMap", e))?,
                    None => None,
                }
                .unwrap_or(1),
                "layer",
            )? as usize;
            let ref_slot = match &opts {
                Some(opts) => opts
                    .get::<_, Option<String>>("refSlot")
                    .map_err(|e| lua_err("fromTileMap", e))?,
                None => None,
            };
            let apply_tileset_object = match &opts {
                Some(opts) => opts
                    .get::<_, Option<bool>>("applyTilesetObject")
                    .map_err(|e| lua_err("fromTileMap", e))?
                    .unwrap_or(false),
                None => false,
            };
            let target_z = one_based(
                match &opts {
                    Some(opts) => opts
                        .get::<_, Option<u32>>("level")
                        .map_err(|e| lua_err("fromTileMap", e))?,
                    None => None,
                }
                .unwrap_or(1),
                "level",
            )?;
            let levels = match &opts {
                Some(opts) => opts
                    .get::<_, Option<u32>>("levels")
                    .map_err(|e| lua_err("fromTileMap", e))?
                    .unwrap_or(target_z + 1),
                None => target_z + 1,
            };
            if levels == 0 || target_z >= levels {
                return Err(lua_err(
                    "fromTileMap",
                    "levels must be >= level and both use one-based level coordinates",
                ));
            }
            let topology_name = match &opts {
                Some(opts) => opts
                    .get::<_, Option<String>>("topology")
                    .map_err(|e| lua_err("fromTileMap", e))?,
                None => None,
            }
            .unwrap_or_else(|| "square".to_string());
            let topology =
                TileTopology::parse(&topology_name).map_err(|e| lua_err("fromTileMap", e))?;
            let limits = tilefield_limits_from_opts(opts.as_ref(), "fromTileMap")?;
            let mut solid_gids = HashSet::new();
            if let Some(opts) = &opts {
                if let Ok(tbl) = opts.get::<_, LuaTable>("solidGids") {
                    for gid in tbl.sequence_values::<u32>() {
                        if solid_gids.len() >= limits.max_snapshot_entries {
                            return Err(lua_err(
                                "fromTileMap",
                                "solidGids exceeds configured snapshot entry limit",
                            ));
                        }
                        solid_gids.insert(gid.map_err(|e| lua_err("fromTileMap", e))?);
                    }
                }
            }
            let tm = tilemap.inner.borrow();
            let (width, height) = tm
                .get_layer_dimensions(layer)
                .ok_or_else(|| lua_err("fromTileMap", "tilemap layer does not exist"))?;
            let mut field = TileField::new_with_limits(width, height, levels, topology, limits)
                .map_err(|e| lua_err("fromTileMap", e))?;
            if let Some(slot) = ref_slot.as_ref() {
                field
                    .define_slot(slot.clone())
                    .map_err(|e| lua_err("fromTileMap", e))?;
            }
            for y in 0..height {
                for x in 0..width {
                    let coord = CellCoord { x, y, z: target_z };
                    let gid = tm.get_tile(layer, x, y);
                    let solid = !solid_gids.is_empty() && solid_gids.contains(&gid);
                    if solid {
                        field
                            .set_block(coord, TileChannel::Move, true)
                            .map_err(|e| lua_err("fromTileMap", e))?;
                    }
                    if gid != 0 {
                        if let Some(slot) = ref_slot.as_ref() {
                            field
                                .set_ref(coord, slot.clone(), gid)
                                .map_err(|e| lua_err("fromTileMap", e))?;
                        }
                        if apply_tileset_object {
                            if let Some((tileset_index, local_tile_id)) =
                                tileset_local_id_from_gid(&tm, gid)
                            {
                                let Some(tileset) = tm.get_tileset(tileset_index) else {
                                    continue;
                                };
                                apply_tileset_object_to_field(
                                    &mut field,
                                    coord,
                                    tileset,
                                    local_tile_id,
                                    "fromTileMap",
                                )?;
                            }
                        }
                    }
                }
            }
            Ok(LuaTileField {
                inner: Rc::new(RefCell::new(field)),
            })
        })?,
    )?;

    // -- createPhysicsFromTileset --
    /// Compatibility alias: creates physics bodies from tilefield refs whose tileset objects define `physics`.
    /// Canonical ownership is moving to the `physics` integration surface; keep this alias for one migration window.
    /// @param | field | LTileField | Source field containing refs.
    /// @param | slot | string | Reference slot name.
    /// @param | tileset | LTileSet | Tileset with tile object metadata.
    /// @param | world | LWorld | Physics world that receives the bodies.
    /// @param | opts | table? | `{z?/level?, refIsGid?, originX?, originY?, tileWidth?, tileHeight?}`.
    /// @return | LBody[] | Created physics body handles in row-major order.
    tbl.set(
        "createPhysicsFromTileset",
        lua.create_function(
            |lua,
             (field_ud, slot, tileset_ud, world_ud, opts): (
                LuaAnyUserData,
                String,
                LuaAnyUserData,
                LuaAnyUserData,
                Option<LuaTable>,
            )| {
                let field_ud = field_ud.borrow::<LuaTileField>()?;
                let tileset_ud = tileset_ud.borrow::<LuaTileSet>()?;
                let world_ud = world_ud.borrow::<LuaWorld>()?;
                let tileset = tileset_ud.inner.borrow();
                let options =
                    materialize_options(opts.as_ref(), &tileset, "createPhysicsFromTileset")?;
                let field = field_ud.inner.borrow();
                let (width, height, levels) = field.size();
                if options.z >= levels {
                    return Err(lua_err("createPhysicsFromTileset", "z is out of bounds"));
                }
                let mut authored_bodies = Vec::new();
                let world = world_ud.world_handle();
                for y in 0..height {
                    for x in 0..width {
                        let coord = CellCoord { x, y, z: options.z };
                        let Some(archetype) = archetype_for_ref(
                            &field,
                            coord,
                            &slot,
                            &tileset,
                            options.ref_is_gid,
                            "createPhysicsFromTileset",
                        )?
                        else {
                            continue;
                        };
                        let Some(physics) = archetype.physics.as_ref() else {
                            continue;
                        };
                        let body = physics_body_from_tile(
                            physics,
                            coord,
                            &options,
                            "createPhysicsFromTileset",
                        )?;
                        authored_bodies.push(body);
                    }
                }
                let body_handles = try_lua_bodies_from_bodies(world, authored_bodies)
                    .map_err(|err| lua_err("createPhysicsFromTileset", err))?;
                let bodies = lua.create_table()?;
                for (index, body) in body_handles.into_iter().enumerate() {
                    bodies.set(index + 1, body)?;
                }
                Ok(bodies)
            },
        )?,
    )?;

    let light_state = state.clone();
    // -- createLightsFromTileset --
    /// Compatibility alias: creates normal render lights and occluders from tilefield refs whose tileset objects define `renderLight` or `occluder`.
    /// Canonical ownership is moving to the `light` integration surface; keep this alias for one migration window.
    /// @param | field | LTileField | Source field containing refs.
    /// @param | slot | string | Reference slot name.
    /// @param | tileset | LTileSet | Tileset with tile object metadata.
    /// @param | opts | table? | `{z?/level?, refIsGid?, originX?, originY?, tileWidth?, tileHeight?}`.
    /// @return | table | `{lights=Llight[], occluders=LOccluder[]}`.
    tbl.set(
        "createLightsFromTileset",
        lua.create_function(
            move |lua,
                  (field_ud, slot, tileset_ud, opts): (
                LuaAnyUserData,
                String,
                LuaAnyUserData,
                Option<LuaTable>,
            )| {
                create_lights_from_tileset(
                    lua,
                    light_state.clone(),
                    field_ud,
                    slot,
                    tileset_ud,
                    opts,
                    "createLightsFromTilefield",
                )
            },
        )?,
    )?;

    lurek.set("tilefield", tbl)?;
    Ok(())
}
