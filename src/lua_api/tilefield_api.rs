//! Registers `lurek.tilefield`, converting Lua tables and one-based coordinates while Rust owns field behavior.

use super::tilemap_api::LuaTileMap;
use super::tileset_api::LuaTileSet;
use super::SharedState;
use crate::tilefield::{
    CellCoord, TileChannel, TileField, TileFieldMap, TileLightEmitter, TileModifier, TileTopology,
};
use crate::tilemap::tilemap::TileMap;
use crate::tileset::TileSet;
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashSet;
use std::rc::Rc;

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

fn channel_from_str(value: String, api: &str) -> LuaResult<TileChannel> {
    TileChannel::parse(&value).map_err(|err| lua_err(api, err))
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
                .unwrap_or(1.0)
                .max(0.0),
            intensity: light_tbl
                .get::<_, Option<f32>>("intensity")
                .map_err(|e| lua_err(api, e))?
                .unwrap_or(1.0)
                .max(0.0),
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
            .unwrap_or(1.0)
            .max(0.0),
        intensity: table
            .get::<_, Option<f32>>("intensity")
            .map_err(|e| lua_err(api, e))?
            .unwrap_or(1.0)
            .max(0.0),
        color,
    })
}

fn provider_u32(provider: &LuaTable, name: &str, api: &str) -> LuaResult<u32> {
    provider
        .get::<_, Option<u32>>(name)
        .map_err(|e| lua_err(api, e))?
        .ok_or_else(|| lua_err(api, format!("provider.{name} is required")))
}

fn provider_string(provider: &LuaTable, name: &str, default: &str, api: &str) -> LuaResult<String> {
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
    if let Some(sun_occlusion) = cell
        .get::<_, Option<f32>>("sunOcclusion")
        .map_err(|e| lua_err(api, e))?
    {
        field
            .set_sun_occlusion(coord, sun_occlusion)
            .map_err(|e| lua_err(api, e))?;
    }
    if let Ok(refs) = cell.get::<_, LuaTable>("refs") {
        for pair in refs.pairs::<String, u32>() {
            let (slot, value) = pair.map_err(|e| lua_err(api, e))?;
            if !field.has_slot(&slot) {
                field
                    .define_slot(slot.clone())
                    .map_err(|e| lua_err(api, e))?;
            }
            field
                .set_ref(coord, slot, value)
                .map_err(|e| lua_err(api, e))?;
        }
    }
    if let Ok(lights) = cell.get::<_, LuaTable>("lights") {
        for pair in lights.pairs::<String, LuaTable>() {
            let (source, light) = pair.map_err(|e| lua_err(api, e))?;
            let light = light_emitter_from_table(light, api)?;
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

pub(crate) fn field_from_provider(provider: LuaTable, api: &str) -> LuaResult<TileField> {
    let width = provider_u32(&provider, "width", api)?;
    let height = provider_u32(&provider, "height", api)?;
    let levels = provider
        .get::<_, Option<u32>>("levels")
        .map_err(|e| lua_err(api, e))?
        .unwrap_or(1);
    let topology_name = provider_string(&provider, "topology", "square", api)?;
    let topology = TileTopology::parse(&topology_name).map_err(|e| lua_err(api, e))?;
    let mut field = TileField::new(width, height, levels, topology).map_err(|e| lua_err(api, e))?;
    if let Ok(slots) = provider.get::<_, LuaTable>("slots") {
        for slot in slots.sequence_values::<String>() {
            field
                .define_slot(slot.map_err(|e| lua_err(api, e))?)
                .map_err(|e| lua_err(api, e))?;
        }
    }
    if let Ok(modifiers) = provider.get::<_, LuaTable>("modifiers") {
        for pair in modifiers.pairs::<String, LuaTable>() {
            let (name, value) = pair.map_err(|e| lua_err(api, e))?;
            let modifier = modifier_from_table(name.clone(), value, api)?;
            field
                .set_modifier(name, modifier)
                .map_err(|e| lua_err(api, e))?;
        }
    }
    if let Ok(regions) = provider.get::<_, LuaTable>("regions") {
        for pair in regions.pairs::<String, LuaTable>() {
            let (name, region) = pair.map_err(|e| lua_err(api, e))?;
            if let Ok(cells) = region.get::<_, LuaTable>("cells") {
                let mut out = Vec::new();
                for cell in cells.sequence_values::<LuaTable>() {
                    out.push(coord_from_table(cell.map_err(|e| lua_err(api, e))?, api)?);
                }
                field
                    .set_region_cells(name, out)
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
                    .set_region_rect(name, a.x, a.y, b.x, b.y, z)
                    .map_err(|e| lua_err(api, e))?;
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
                    if let LuaValue::Table(cell) = value {
                        apply_provider_cell(&mut field, CellCoord { x, y, z }, cell, api)?;
                    }
                }
            }
        }
    }
    Ok(field)
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
        let refs = lua.create_table()?;
        for (slot, value) in cell.refs() {
            refs.set(slot.as_str(), *value)?;
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
        /// Removes a named region.
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
        /// @return | table? | Array of `{ x, y, z }` cells.
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

        // -- clear --
        /// Clears all cell gameplay state.
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            Ok(())
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
                if let Some(value) = cell_tbl
                    .get::<_, Option<f32>>("sunOcclusion")
                    .map_err(|e| lua_err("setCell", e))?
                {
                    field
                        .set_sun_occlusion(coord, value)
                        .map_err(|e| lua_err("setCell", e))?;
                }
                if let Ok(refs) = cell_tbl.get::<_, LuaTable>("refs") {
                    for pair in refs.pairs::<String, u32>() {
                        let (slot, value) = pair.map_err(|e| lua_err("setCell", e))?;
                        field
                            .set_ref(coord, slot, value)
                            .map_err(|e| lua_err("setCell", e))?;
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

        // -- removeModifier --
        /// Removes a named modifier and clears it from all cells.
        /// @param | name | string | Modifier name.
        /// @return | boolean | True when removed.
        methods.add_method("removeModifier", |_, this, name: String| {
            Ok(this.inner.borrow_mut().remove_modifier(&name))
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
            Ok(this.inner.borrow_mut().remove_slot(&slot))
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
        /// @param | value | integer | Object, tile, or tileset-local id stored for the slot.
        methods.add_method(
            "setRef",
            |_, this, (x, y, z, slot, value): (u32, u32, Option<u32>, String, u32)| {
                let coord = coord_from_values(x, y, z)?;
                this.inner
                    .borrow_mut()
                    .set_ref(coord, slot, value)
                    .map_err(|e| lua_err("setRef", e))
            },
        );

        // -- getRef --
        /// Returns a named object/tile reference from one cell, or nil.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @param | z | integer? | One-based level, default 1.
        /// @param | slot | string | Reference slot name.
        /// @return | integer|nil | Stored reference id, or nil when unset.
        methods.add_method(
            "getRef",
            |_, this, (x, y, z, slot): (u32, u32, Option<u32>, String)| {
                let coord = coord_from_values(x, y, z)?;
                Ok(this.inner.borrow().get_ref(coord, &slot))
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
        /// Returns every declared ref slot.
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
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // -- new --
    /// Creates a multi-level tilefield with explicit dimensions and topology.
    /// @param | opts | table | `{width, height, levels?, topology?}`.
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
            let field =
                TileField::new(width, height, levels, topology).map_err(|e| lua_err("new", e))?;
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
    /// @param | opts | table | `{width, height, layers?, fieldWidth, fieldHeight, fieldLevels?, topology?}`.
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
            let field_map = TileFieldMap::new(
                width,
                height,
                layers,
                field_width,
                field_height,
                field_levels,
                topology,
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
            let mut solid_gids = HashSet::new();
            if let Some(opts) = &opts {
                if let Ok(tbl) = opts.get::<_, LuaTable>("solidGids") {
                    for gid in tbl.sequence_values::<u32>() {
                        solid_gids.insert(gid.map_err(|e| lua_err("fromTileMap", e))?);
                    }
                }
            }
            let tm = tilemap.inner.borrow();
            let (width, height) = tm
                .get_layer_dimensions(layer)
                .ok_or_else(|| lua_err("fromTileMap", "tilemap layer does not exist"))?;
            let mut field = TileField::new(width, height, levels, topology)
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

    lurek.set("tilefield", tbl)?;
    Ok(())
}
