//! Registers the `lurek.tileset` Lua API for atlas-backed tile object archetypes.

use super::SharedState;
use crate::tileset::{
    AutoTileMode, TileAnimFrame, TileObjectArchetype, TileObjectLight, TileSet, TileVisual,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

fn one_based_u32(name: &str, val: u32) -> LuaResult<u32> {
    val.checked_sub(1)
        .ok_or_else(|| mlua::Error::RuntimeError(format!("{name} must be >= 1 (got {val})")))
}

fn parse_auto_tile_mode(name: &str, mode: &str) -> LuaResult<AutoTileMode> {
    match mode {
        "matchSides" => Ok(AutoTileMode::MatchSides),
        "matchCorners" => Ok(AutoTileMode::MatchCorners),
        "matchCornersAndSides" => Ok(AutoTileMode::MatchCornersAndSides),
        other => Err(LuaError::RuntimeError(format!(
            "{name}: unknown mode '{other}', use 'matchSides', 'matchCorners', or 'matchCornersAndSides'"
        ))),
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
            "unsupported tileset property value type '{}'",
            other.type_name()
        ))),
    }
}

fn property_string_to_bool(value: &str) -> Option<bool> {
    match value {
        "true" | "1" => Some(true),
        "false" | "0" => Some(false),
        _ => None,
    }
}

fn optional_table_number(
    table: &LuaTable,
    string_key: &str,
    index_key: i64,
) -> LuaResult<Option<f32>> {
    table
        .get::<_, Option<f32>>(string_key)?
        .map(Some)
        .map(Ok)
        .unwrap_or_else(|| table.get::<_, Option<f32>>(index_key))
}

fn visual_quad_from_table(table: &LuaTable, field: &str) -> LuaResult<Option<[f32; 4]>> {
    let Some(quad) = table.get::<_, Option<LuaTable>>(field)? else {
        return Ok(None);
    };
    Ok(Some([
        optional_table_number(&quad, "x", 1)?.unwrap_or(0.0),
        optional_table_number(&quad, "y", 2)?.unwrap_or(0.0),
        optional_table_number(&quad, "w", 3)?
            .or_else(|| quad.get::<_, Option<f32>>("width").ok().flatten())
            .unwrap_or(0.0),
        optional_table_number(&quad, "h", 4)?
            .or_else(|| quad.get::<_, Option<f32>>("height").ok().flatten())
            .unwrap_or(0.0),
    ]))
}

fn visual_texture_size_from_table(table: &LuaTable) -> LuaResult<Option<[f32; 2]>> {
    let Some(size) = table.get::<_, Option<LuaTable>>("textureSize")? else {
        return Ok(None);
    };
    Ok(Some([
        optional_table_number(&size, "w", 1)?
            .or_else(|| size.get::<_, Option<f32>>("width").ok().flatten())
            .unwrap_or(0.0),
        optional_table_number(&size, "h", 2)?
            .or_else(|| size.get::<_, Option<f32>>("height").ok().flatten())
            .unwrap_or(0.0),
    ]))
}

fn u32_from_lua_key(key: LuaValue, api: &str) -> LuaResult<u32> {
    match key {
        LuaValue::Integer(value) if value > 0 && value <= u32::MAX as i64 => Ok(value as u32),
        LuaValue::Number(value)
            if value > 0.0 && value.fract() == 0.0 && value <= u32::MAX as f64 =>
        {
            Ok(value as u32)
        }
        LuaValue::String(value) => value
            .to_str()?
            .parse::<u32>()
            .map_err(|_| LuaError::RuntimeError(format!("{api}: tile key must be >= 1"))),
        other => Err(LuaError::RuntimeError(format!(
            "{api}: tile key must be integer/string, got {}",
            other.type_name()
        ))),
    }
}

fn archetype_from_table(
    name: String,
    object: LuaTable,
    api: &str,
) -> LuaResult<TileObjectArchetype> {
    let mut archetype = TileObjectArchetype::new(name)
        .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
    archetype.slot = object.get::<_, Option<String>>("slot")?;
    let tile_id = object
        .get::<_, Option<u32>>("tileId")?
        .map(|tile_id| one_based_u32(&format!("{api}.tileId"), tile_id))
        .transpose()?;
    let mut visual = object
        .get::<_, Option<LuaTable>>("visual")?
        .map(|visual_tbl| {
            Ok::<TileVisual, LuaError>(TileVisual {
                texture_id: visual_tbl.get::<_, Option<u64>>("textureId")?,
                atlas: visual_tbl.get::<_, Option<String>>("atlas")?,
                sprite: visual_tbl.get::<_, Option<String>>("sprite")?,
                image: visual_tbl.get::<_, Option<String>>("image")?,
                tile_id: visual_tbl
                    .get::<_, Option<u32>>("tileId")?
                    .map(|id| one_based_u32(&format!("{api}.visual.tileId"), id))
                    .transpose()?,
                quad: visual_quad_from_table(&visual_tbl, "quad")?,
                texture_size: visual_texture_size_from_table(&visual_tbl)?,
                order: visual_tbl.get::<_, Option<i32>>("order")?.unwrap_or(0),
            })
        })
        .transpose()?;
    if tile_id.is_some() {
        visual.get_or_insert_with(TileVisual::default).tile_id = tile_id;
    }
    archetype.visual = visual;
    if let Ok(blocks) = object.get::<_, LuaTable>("blocks") {
        for pair in blocks.pairs::<String, bool>() {
            let (name, value) = pair?;
            let channel = crate::tilefield::TileChannel::parse(&name)
                .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
            archetype.blockers.insert(channel, value);
        }
    }
    if let Ok(costs) = object.get::<_, LuaTable>("costs") {
        for pair in costs.pairs::<String, f32>() {
            let (name, value) = pair?;
            if !value.is_finite() || value < 0.0 {
                return Err(LuaError::RuntimeError(format!(
                    "{api}: cost values must be finite and >= 0"
                )));
            }
            let channel = crate::tilefield::TileChannel::parse(&name)
                .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
            archetype.costs.insert(channel, value);
        }
    }
    archetype.sun_occlusion = object
        .get::<_, Option<f32>>("sunOcclusion")?
        .map(|value| value.clamp(0.0, 1.0));
    if let Ok(light_tbl) = object.get::<_, LuaTable>("light") {
        let color = light_tbl
            .get::<_, Option<LuaTable>>("color")?
            .map(|color_tbl| {
                Ok::<[f32; 3], LuaError>([
                    color_tbl.get::<_, Option<f32>>(1)?.unwrap_or(1.0),
                    color_tbl.get::<_, Option<f32>>(2)?.unwrap_or(1.0),
                    color_tbl.get::<_, Option<f32>>(3)?.unwrap_or(1.0),
                ])
            })
            .transpose()?
            .unwrap_or([1.0, 1.0, 1.0]);
        archetype.light = Some(TileObjectLight {
            radius: light_tbl.get::<_, Option<f32>>("radius")?.unwrap_or(1.0),
            intensity: light_tbl.get::<_, Option<f32>>("intensity")?.unwrap_or(1.0),
            color,
        });
    }
    if let Ok(properties) = object.get::<_, LuaTable>("properties") {
        for pair in properties.pairs::<String, LuaValue>() {
            let (name, value) = pair?;
            if let Some(value) = property_value_to_string(value)? {
                archetype.properties.insert(name, value);
            }
        }
    }
    Ok(archetype)
}

pub(crate) fn tileset_from_provider(provider: LuaTable, api: &str) -> LuaResult<TileSet> {
    let first_gid: u32 = provider.get::<_, Option<u32>>("firstGid")?.unwrap_or(1);
    let tile_count: u32 = provider
        .get::<_, Option<u32>>("tileCount")?
        .ok_or_else(|| LuaError::RuntimeError(format!("{api}: provider.tileCount is required")))?;
    let columns: u32 = provider
        .get::<_, Option<u32>>("columns")?
        .unwrap_or(tile_count.max(1));
    let tile_width: u32 = provider
        .get::<_, Option<u32>>("tileWidth")?
        .ok_or_else(|| LuaError::RuntimeError(format!("{api}: provider.tileWidth is required")))?;
    let tile_height: u32 = provider
        .get::<_, Option<u32>>("tileHeight")?
        .ok_or_else(|| LuaError::RuntimeError(format!("{api}: provider.tileHeight is required")))?;
    let spacing: u32 = provider.get::<_, Option<u32>>("spacing")?.unwrap_or(0);
    let margin: u32 = provider.get::<_, Option<u32>>("margin")?.unwrap_or(0);
    let mut tileset = TileSet::new(
        first_gid,
        tile_count,
        columns,
        tile_width,
        tile_height,
        spacing,
        margin,
    );
    if let Ok(objects) = provider.get::<_, LuaTable>("objects") {
        for pair in objects.pairs::<LuaValue, LuaTable>() {
            let (key, object) = pair?;
            let name = match key {
                LuaValue::String(value) => value.to_str()?.to_string(),
                _ => object.get::<_, String>("name")?,
            };
            tileset.set_archetype(archetype_from_table(name, object, api)?);
        }
    }
    if let Ok(tile_objects) = provider.get::<_, LuaTable>("tileObjects") {
        for pair in tile_objects.pairs::<LuaValue, String>() {
            let (key, object_name) = pair?;
            let tile_id = u32_from_lua_key(key, api)?;
            tileset
                .set_tile_archetype(tile_id - 1, Some(object_name))
                .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
        }
    }
    if let Ok(properties) = provider.get::<_, LuaTable>("properties") {
        for pair in properties.pairs::<LuaValue, LuaTable>() {
            let (key, props) = pair?;
            let tile_id = u32_from_lua_key(key, api)?;
            for prop in props.pairs::<String, LuaValue>() {
                let (name, value) = prop?;
                if let Some(value) = property_value_to_string(value)? {
                    tileset
                        .set_property(tile_id - 1, name, Some(value))
                        .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
                }
            }
        }
    }
    if let Ok(animations) = provider.get::<_, LuaTable>("animations") {
        for pair in animations.pairs::<LuaValue, LuaTable>() {
            let (key, frames) = pair?;
            let tile_id = u32_from_lua_key(key, api)?;
            let mut anim_frames = Vec::new();
            for frame in frames.sequence_values::<LuaTable>() {
                let frame = frame?;
                let frame_tile: u32 = frame.get("tileid").or_else(|_| frame.get("tileId"))?;
                anim_frames.push(TileAnimFrame {
                    tile_id: one_based_u32(&format!("{api}.animation.tileid"), frame_tile)?,
                    duration_ms: frame.get("duration")?,
                });
            }
            tileset.set_animation(tile_id - 1, anim_frames);
        }
    }
    Ok(tileset)
}

#[derive(Clone)]
pub struct LuaTileSet {
    pub(crate) inner: Rc<RefCell<TileSet>>,
}

impl LuaUserData for LuaTileSet {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method("getFirstGid", |_, this, ()| {
            Ok(this.inner.borrow().get_first_gid())
        });
        methods.add_method("getTileCount", |_, this, ()| {
            Ok(this.inner.borrow().get_tile_count())
        });
        methods.add_method("getColumns", |_, this, ()| {
            Ok(this.inner.borrow().get_columns())
        });
        methods.add_method("getTileWidth", |_, this, ()| {
            Ok(this.inner.borrow().get_tile_width())
        });
        methods.add_method("getTileHeight", |_, this, ()| {
            Ok(this.inner.borrow().get_tile_height())
        });
        methods.add_method("getTileDimensions", |_, this, ()| {
            Ok(this.inner.borrow().get_tile_dimensions())
        });
        methods.add_method("getTextureDimensions", |_, this, ()| {
            let inner = this.inner.borrow();
            Ok((inner.get_texture_width(), inner.get_texture_height()))
        });
        methods.add_method("getSpacing", |_, this, ()| {
            Ok(this.inner.borrow().get_spacing())
        });
        methods.add_method("getMargin", |_, this, ()| {
            Ok(this.inner.borrow().get_margin())
        });
        methods.add_method("getQuad", |lua, this, tile_id: u32| {
            if tile_id == 0 {
                return Err(LuaError::RuntimeError(
                    "getQuad: tile_id must be >= 1".to_string(),
                ));
            }
            let r = this.inner.borrow().get_quad(tile_id - 1);
            let tbl = lua.create_table()?;
            tbl.set("x", r.x)?;
            tbl.set("y", r.y)?;
            tbl.set("width", r.width)?;
            tbl.set("height", r.height)?;
            Ok(tbl)
        });

        methods.add_method(
            "setAnimation",
            |_, this, (tile_id, frames): (u32, LuaTable)| {
                if tile_id == 0 {
                    return Err(LuaError::RuntimeError(
                        "setAnimation: tile_id must be >= 1".to_string(),
                    ));
                }
                let mut anim_frames = Vec::new();
                for pair in frames.sequence_values::<LuaTable>() {
                    let frame_tbl = pair?;
                    let fid: u32 = frame_tbl.get("tileid")?;
                    let dur: f32 = frame_tbl.get("duration")?;
                    if fid == 0 {
                        return Err(LuaError::RuntimeError(
                            "setAnimation: frame tileid must be >= 1".to_string(),
                        ));
                    }
                    anim_frames.push(TileAnimFrame {
                        tile_id: fid - 1,
                        duration_ms: dur,
                    });
                }
                this.inner
                    .borrow_mut()
                    .set_animation(tile_id - 1, anim_frames);
                Ok(())
            },
        );
        methods.add_method("getAnimation", |lua, this, tile_id: u32| {
            if tile_id == 0 {
                return Err(LuaError::RuntimeError(
                    "getAnimation: tile_id must be >= 1".to_string(),
                ));
            }
            let inner = this.inner.borrow();
            match inner.get_animation(tile_id - 1) {
                Some(frames) => {
                    let tbl = lua.create_table()?;
                    for (i, f) in frames.iter().enumerate() {
                        let entry = lua.create_table()?;
                        entry.set("tileid", f.tile_id + 1)?;
                        entry.set("duration", f.duration_ms)?;
                        tbl.set(i + 1, entry)?;
                    }
                    Ok(LuaValue::Table(tbl))
                }
                None => Ok(LuaValue::Nil),
            }
        });

        methods.add_method(
            "setObject",
            |_, this, (name, object): (String, LuaTable)| {
                let mut archetype = TileObjectArchetype::new(name)
                    .map_err(|err| LuaError::RuntimeError(format!("setObject: {err}")))?;
                archetype.slot = object.get::<_, Option<String>>("slot")?;
                let tile_id = object
                    .get::<_, Option<u32>>("tileId")?
                    .map(|tile_id| one_based_u32("setObject.tileId", tile_id))
                    .transpose()?;
                let mut visual = object
                    .get::<_, Option<LuaTable>>("visual")?
                    .map(|visual_tbl| {
                        Ok::<TileVisual, LuaError>(TileVisual {
                            texture_id: visual_tbl.get::<_, Option<u64>>("textureId")?,
                            atlas: visual_tbl.get::<_, Option<String>>("atlas")?,
                            sprite: visual_tbl.get::<_, Option<String>>("sprite")?,
                            image: visual_tbl.get::<_, Option<String>>("image")?,
                            tile_id: visual_tbl
                                .get::<_, Option<u32>>("tileId")?
                                .map(|id| one_based_u32("setObject.visual.tileId", id))
                                .transpose()?,
                            quad: visual_quad_from_table(&visual_tbl, "quad")?,
                            texture_size: visual_texture_size_from_table(&visual_tbl)?,
                            order: visual_tbl.get::<_, Option<i32>>("order")?.unwrap_or(0),
                        })
                    })
                    .transpose()?;
                if tile_id.is_some() {
                    visual.get_or_insert_with(TileVisual::default).tile_id = tile_id;
                }
                archetype.visual = visual;

                if let Ok(blocks) = object.get::<_, LuaTable>("blocks") {
                    for pair in blocks.pairs::<String, bool>() {
                        let (name, value) = pair?;
                        let channel = crate::tilefield::TileChannel::parse(&name)
                            .map_err(|err| LuaError::RuntimeError(format!("setObject: {err}")))?;
                        archetype.blockers.insert(channel, value);
                    }
                }
                if let Ok(costs) = object.get::<_, LuaTable>("costs") {
                    for pair in costs.pairs::<String, f32>() {
                        let (name, value) = pair?;
                        if !value.is_finite() || value < 0.0 {
                            return Err(LuaError::RuntimeError(
                                "setObject: cost values must be finite and >= 0".to_string(),
                            ));
                        }
                        let channel = crate::tilefield::TileChannel::parse(&name)
                            .map_err(|err| LuaError::RuntimeError(format!("setObject: {err}")))?;
                        archetype.costs.insert(channel, value);
                    }
                }
                archetype.sun_occlusion = object
                    .get::<_, Option<f32>>("sunOcclusion")?
                    .map(|value| value.clamp(0.0, 1.0));
                if let Ok(light_tbl) = object.get::<_, LuaTable>("light") {
                    let color = light_tbl
                        .get::<_, Option<LuaTable>>("color")?
                        .map(|color_tbl| {
                            Ok::<[f32; 3], LuaError>([
                                color_tbl.get::<_, Option<f32>>(1)?.unwrap_or(1.0),
                                color_tbl.get::<_, Option<f32>>(2)?.unwrap_or(1.0),
                                color_tbl.get::<_, Option<f32>>(3)?.unwrap_or(1.0),
                            ])
                        })
                        .transpose()?
                        .unwrap_or([1.0, 1.0, 1.0]);
                    archetype.light = Some(TileObjectLight {
                        radius: light_tbl.get::<_, Option<f32>>("radius")?.unwrap_or(1.0),
                        intensity: light_tbl.get::<_, Option<f32>>("intensity")?.unwrap_or(1.0),
                        color,
                    });
                }
                if let Ok(properties) = object.get::<_, LuaTable>("properties") {
                    for pair in properties.pairs::<String, LuaValue>() {
                        let (name, value) = pair?;
                        if let Some(value) = property_value_to_string(value)? {
                            archetype.properties.insert(name, value);
                        }
                    }
                }
                this.inner.borrow_mut().set_archetype(archetype);
                Ok(())
            },
        );

        methods.add_method("getObject", |lua, this, name: String| {
            let inner = this.inner.borrow();
            let Some(object) = inner.archetype(&name) else {
                return Ok(None);
            };
            let table = lua.create_table()?;
            table.set("name", object.name.as_str())?;
            table.set("slot", object.slot.clone())?;
            if let Some(visual) = &object.visual {
                let visual_tbl = lua.create_table()?;
                visual_tbl.set("textureId", visual.texture_id)?;
                visual_tbl.set("atlas", visual.atlas.clone())?;
                visual_tbl.set("sprite", visual.sprite.clone())?;
                visual_tbl.set("image", visual.image.clone())?;
                visual_tbl.set("tileId", visual.tile_id.map(|id| id + 1))?;
                if let Some(quad) = visual.quad {
                    let quad_tbl = lua.create_table()?;
                    quad_tbl.set("x", quad[0])?;
                    quad_tbl.set("y", quad[1])?;
                    quad_tbl.set("w", quad[2])?;
                    quad_tbl.set("h", quad[3])?;
                    visual_tbl.set("quad", quad_tbl)?;
                }
                if let Some(size) = visual.texture_size {
                    let size_tbl = lua.create_table()?;
                    size_tbl.set("w", size[0])?;
                    size_tbl.set("h", size[1])?;
                    visual_tbl.set("textureSize", size_tbl)?;
                }
                visual_tbl.set("order", visual.order)?;
                table.set("visual", visual_tbl)?;
                table.set("tileId", visual.tile_id.map(|id| id + 1))?;
            }
            let blocks = lua.create_table()?;
            for (channel, blocked) in &object.blockers {
                blocks.set(channel.as_str(), *blocked)?;
            }
            table.set("blocks", blocks)?;
            let costs = lua.create_table()?;
            for (channel, cost) in &object.costs {
                costs.set(channel.as_str(), *cost)?;
            }
            table.set("costs", costs)?;
            table.set("sunOcclusion", object.sun_occlusion)?;
            if let Some(light) = &object.light {
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
            for (name, value) in &object.properties {
                properties.set(name.as_str(), value.as_str())?;
            }
            table.set("properties", properties)?;
            Ok(Some(table))
        });
        methods.add_method("removeObject", |_, this, name: String| {
            Ok(this.inner.borrow_mut().remove_archetype(&name))
        });
        methods.add_method("getObjectNames", |lua, this, ()| {
            let names = this.inner.borrow().archetype_names();
            let table = lua.create_table()?;
            for (index, name) in names.into_iter().enumerate() {
                table.set(index + 1, name)?;
            }
            Ok(table)
        });
        methods.add_method(
            "setTileObject",
            |_, this, (tile_id, object_name): (u32, Option<String>)| {
                if tile_id == 0 {
                    return Err(LuaError::RuntimeError(
                        "setTileObject: tile_id must be >= 1".to_string(),
                    ));
                }
                this.inner
                    .borrow_mut()
                    .set_tile_archetype(tile_id - 1, object_name)
                    .map_err(|err| LuaError::RuntimeError(format!("setTileObject: {err}")))?;
                Ok(())
            },
        );
        methods.add_method("getTileObject", |_, this, tile_id: u32| {
            if tile_id == 0 {
                return Err(LuaError::RuntimeError(
                    "getTileObject: tile_id must be >= 1".to_string(),
                ));
            }
            Ok(this
                .inner
                .borrow()
                .get_tile_archetype(tile_id - 1)
                .map(str::to_string))
        });

        methods.add_method(
            "setProperty",
            |_, this, (tile_id, name, value): (u32, String, LuaValue)| {
                if tile_id == 0 {
                    return Err(LuaError::RuntimeError(
                        "setProperty: tile_id must be >= 1".to_string(),
                    ));
                }
                let value = property_value_to_string(value)?;
                this.inner
                    .borrow_mut()
                    .set_property(tile_id - 1, name, value)
                    .map_err(|err| LuaError::RuntimeError(format!("setProperty: {err}")))?;
                Ok(())
            },
        );
        methods.add_method("getProperty", |_, this, (tile_id, name): (u32, String)| {
            if tile_id == 0 {
                return Err(LuaError::RuntimeError(
                    "getProperty: tile_id must be >= 1".to_string(),
                ));
            }
            Ok(this
                .inner
                .borrow()
                .get_property(tile_id - 1, &name)
                .map(str::to_string))
        });
        methods.add_method(
            "getPropertyNumber",
            |_, this, (tile_id, name): (u32, String)| {
                if tile_id == 0 {
                    return Err(LuaError::RuntimeError(
                        "getPropertyNumber: tile_id must be >= 1".to_string(),
                    ));
                }
                Ok(this
                    .inner
                    .borrow()
                    .get_property(tile_id - 1, &name)
                    .and_then(|value| value.parse::<f64>().ok()))
            },
        );
        methods.add_method(
            "getPropertyBool",
            |_, this, (tile_id, name): (u32, String)| {
                if tile_id == 0 {
                    return Err(LuaError::RuntimeError(
                        "getPropertyBool: tile_id must be >= 1".to_string(),
                    ));
                }
                Ok(this
                    .inner
                    .borrow()
                    .get_property(tile_id - 1, &name)
                    .and_then(property_string_to_bool))
            },
        );
        methods.add_method("getProperties", |lua, this, tile_id: u32| {
            if tile_id == 0 {
                return Err(LuaError::RuntimeError(
                    "getProperties: tile_id must be >= 1".to_string(),
                ));
            }
            let table = lua.create_table()?;
            if let Some(properties) = this.inner.borrow().properties(tile_id - 1) {
                for (name, value) in properties {
                    table.set(name.as_str(), value.as_str())?;
                }
            }
            Ok(table)
        });

        methods.add_method(
            "setAutoTileRule",
            |_, this, (type_name, bitmask, tile_id): (String, u8, u32)| {
                if tile_id == 0 {
                    return Err(LuaError::RuntimeError(
                        "setAutoTileRule: tileId must be >= 1".to_string(),
                    ));
                }
                this.inner
                    .borrow_mut()
                    .set_auto_tile_rule(&type_name, bitmask, tile_id - 1);
                Ok(())
            },
        );
        methods.add_method(
            "getAutoTileId",
            |_, this, (type_name, bitmask): (String, u8)| {
                Ok(this
                    .inner
                    .borrow()
                    .get_auto_tile_id(&type_name, bitmask)
                    .map(|id| id + 1))
            },
        );
        methods.add_method(
            "setAutoTileRule8",
            |_, this, (type_name, bitmask, tile_id): (String, u16, u32)| {
                if tile_id == 0 {
                    return Err(LuaError::RuntimeError(
                        "setAutoTileRule8: tileId must be >= 1".to_string(),
                    ));
                }
                this.inner
                    .borrow_mut()
                    .set_auto_tile_rule_8(&type_name, bitmask, tile_id - 1);
                Ok(())
            },
        );
        methods.add_method(
            "getAutoTileId8",
            |_, this, (type_name, bitmask): (String, u16)| {
                Ok(this
                    .inner
                    .borrow()
                    .get_auto_tile_id_8(&type_name, bitmask)
                    .map(|id| id + 1))
            },
        );
        methods.add_method(
            "setAutoTileMode",
            |_, this, (type_name, mode): (String, String)| {
                let mode = parse_auto_tile_mode("setAutoTileMode", &mode)?;
                this.inner.borrow_mut().set_auto_tile_mode(&type_name, mode);
                Ok(())
            },
        );
        methods.add_method("getAutoTileMode", |_, this, type_name: String| {
            Ok(this.inner.borrow().get_auto_tile_mode(&type_name).as_str())
        });
        methods.add_method("type", |_, _, ()| Ok("LTileSet"));
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTileSet" || name == "LObject")
        });
    }
}

pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let new_tileset = lua.create_function(
        |lua,
         (first_gid, tile_count, columns, tile_width, tile_height, spacing, margin): (
            u32,
            u32,
            u32,
            u32,
            u32,
            Option<u32>,
            Option<u32>,
        )| {
            lua.create_userdata(LuaTileSet {
                inner: Rc::new(RefCell::new(TileSet::new(
                    first_gid,
                    tile_count,
                    columns,
                    tile_width,
                    tile_height,
                    spacing.unwrap_or(0),
                    margin.unwrap_or(0),
                ))),
            })
        },
    )?;
    tbl.set("newTileSet", new_tileset)?;
    // -- fromProvider --
    /// Builds a native tileset from a Lua provider table with atlas fields, objects, tileObjects, properties, and animations.
    /// @param | provider | table | Lua-authored tileset provider.
    /// @return | LTileSet | New tileset copied from provider data.
    tbl.set(
        "fromProvider",
        lua.create_function(|lua, provider: LuaTable| {
            lua.create_userdata(LuaTileSet {
                inner: Rc::new(RefCell::new(tileset_from_provider(
                    provider,
                    "lurek.tileset.fromProvider",
                )?)),
            })
        })?,
    )?;
    lurek.set("tileset", tbl)
}
