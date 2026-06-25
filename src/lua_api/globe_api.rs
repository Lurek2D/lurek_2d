//! Registers the `lurek.globe` Lua API for globe state, markers, regions, colors, and latitude-longitude validation.

use super::SharedState;
use crate::globe::export::export_regions_to_obj;
use crate::globe::loader;
use crate::globe::projection::screen_delta_to_pan;
use crate::globe::registry::{Globe, GlobeRegistry};
use crate::globe::sphere::{
    great_circle_distance, great_circle_path, lat_lon_to_unit, ray_sphere_intersect,
};
use crate::globe::types::{
    FogState, GlobeSpec, HeatLayer, LabelStyle, Layer, LodTier, MarkerShape, MarkerStyle, Region,
    RegionId, RegionPart, MAX_REGIONS,
};
use crate::pathfind::graph_path::ProvinceCostFn;
use mlua::prelude::*;
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
            let value = finite_f32(value, label)?;
            *slot = value.clamp(0.0, 1.0);
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

fn normalize_time_of_day(t: f32) -> LuaResult<f32> {
    Ok(finite_f32(t, "time_of_day")?.rem_euclid(24.0))
}

fn parse_cost_fn(opts: Option<LuaTable>, label: &str) -> LuaResult<ProvinceCostFn> {
    let mut cost_fn = ProvinceCostFn::new();
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
        /// Removes a terrain patch by id.
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
                    if let Some(p) = g.get_province_mut(RegionId(id)) {
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
                    if let Some(region) = g.get_region_mut(RegionId(id)) {
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
                    if let Some(patch) = g.get_terrain_patch_mut(RegionId(id)) {
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
                    finite_f32(r, "region color red")?.clamp(0.0, 1.0),
                    finite_f32(g, "region color green")?.clamp(0.0, 1.0),
                    finite_f32(b, "region color blue")?.clamp(0.0, 1.0),
                    finite_f32(a, "region color alpha")?.clamp(0.0, 1.0),
                ];
                this.with_mut(|g| {
                    if let Some(region) = g.get_region_mut(RegionId(id)) {
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
                if let Some(region) = g.get_region_mut(RegionId(id)) {
                    region.visible = visible;
                    true
                } else {
                    false
                }
            })
        });
        // -- setProvinceTexture --
        /// Assigns a raw texture handle and UV rectangle to a province.
        /// @param | id | integer | Province id.
        /// @param | tex_raw | integer | Raw texture identifier stored in province attributes.
        /// @param | u0 | number | Left UV coordinate.
        /// @param | v0 | number | Top UV coordinate.
        /// @param | u1 | number | Right UV coordinate.
        /// @param | v1 | number | Bottom UV coordinate.
        /// @return | boolean | True when the province exists.
        methods.add_method_mut(
            "setProvinceTexture",
            |_, this, (id, tex_raw, u0, v0, u1, v1): (u32, u64, f32, f32, f32, f32)| {
                this.with_mut(|g| {
                    if let Some(p) = g.get_province_mut(RegionId(id)) {
                        p.attrs
                            .insert("__texture_raw".to_string(), tex_raw.to_string());
                        p.texture_uv_rect = Some([u0, v0, u1, v1]);
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
                if let Some(p) = g.get_province_mut(RegionId(id)) {
                    p.attrs.remove("__texture_raw");
                    p.texture_uv_rect = None;
                    true
                } else {
                    false
                }
            })
        });
        // -- setTerrainPatchTexture --
        /// Assigns a raw texture handle and UV rectangle to a terrain patch.
        /// @param | id | integer | Terrain patch id.
        /// @param | tex_raw | integer | Raw texture identifier stored in terrain attributes.
        /// @param | u0 | number | Left UV coordinate.
        /// @param | v0 | number | Top UV coordinate.
        /// @param | u1 | number | Right UV coordinate.
        /// @param | v1 | number | Bottom UV coordinate.
        /// @return | boolean | True when the terrain patch exists.
        methods.add_method_mut(
            "setTerrainPatchTexture",
            |_, this, (id, tex_raw, u0, v0, u1, v1): (u32, u64, f32, f32, f32, f32)| {
                this.with_mut(|g| {
                    if let Some(patch) = g.get_terrain_patch_mut(RegionId(id)) {
                        patch
                            .attrs
                            .insert("__texture_raw".to_string(), tex_raw.to_string());
                        patch.texture_uv_rect = Some([u0, v0, u1, v1]);
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
                if let Some(patch) = g.get_terrain_patch_mut(RegionId(id)) {
                    patch.attrs.remove("__texture_raw");
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
        /// @param | alpha | number | Layer alpha clamped to 0.0 through 1.0.
        methods.add_method_mut(
            "setHeatLayer",
            |_, this, (name, attr_key, min, max, alpha): (String, String, f32, f32, f32)| {
                this.with_mut(|g| {
                    g.set_heat_layer(HeatLayer {
                        name,
                        attr_key,
                        min_value: min,
                        max_value: max,
                        cold_color: [0.1, 0.2, 0.9, 1.0],
                        hot_color: [0.9, 0.2, 0.1, 1.0],
                        alpha: alpha.clamp(0.0, 1.0),
                        visible: true,
                        z_order: 0,
                    })
                })
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
            this.with_mut(|g| g.camera.pan(dlat, dlon))
        });
        // -- zoom --
        /// Multiplies the globe camera zoom by a factor.
        /// @param | factor | number | Zoom factor.
        methods.add_method_mut("zoom", |_, this, factor: f32| {
            this.with_mut(|g| g.camera.zoom_by(factor))
        });
        // -- setCamera --
        /// Sets camera latitude, longitude, and zoom.
        /// @param | lat | number | Camera latitude in degrees.
        /// @param | lon | number | Camera longitude in degrees.
        /// @param | z | number | Camera zoom, clamped to at least 0.1.
        methods.add_method_mut("setCamera", |_, this, (lat, lon, z): (f32, f32, f32)| {
            this.with_mut(|g| {
                g.camera.lat_deg = lat;
                g.camera.lon_deg = lon;
                g.camera.zoom = z.max(0.1);
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
        /// @param | hz | number | Pulse frequency in hertz, clamped to at least zero.
        /// @param | amp | number | Pulse amplitude clamped to 0.0 through 1.0.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut(
            "setMarkerPulse",
            |_, this, (id, hz, amp): (u32, f32, f32)| {
                this.with_mut(|g| {
                    if let Some(m) = g.markers.get_mut(id) {
                        m.style.pulse_hz = hz.max(0.0);
                        m.style.pulse_amplitude = amp.clamp(0.0, 1.0);
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
                    finite_f32(r, "marker color red")?.clamp(0.0, 1.0),
                    finite_f32(g, "marker color green")?.clamp(0.0, 1.0),
                    finite_f32(b, "marker color blue")?.clamp(0.0, 1.0),
                    finite_f32(a.unwrap_or(1.0), "marker color alpha")?.clamp(0.0, 1.0),
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
        /// @param | size | number | Marker size, clamped to at least 1.0.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut("setMarkerSize", |_, this, (id, size): (u32, f32)| {
            let size = finite_f32(size, "marker size")?.max(1.0);
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
        /// Assigns or clears a raw texture handle for a marker icon.
        /// @param | id | integer | Marker id.
        /// @param | tex_raw | integer? | Raw texture handle, or nil to clear the icon.
        /// @return | boolean | True when the marker exists.
        methods.add_method_mut(
            "setMarkerIconTexture",
            |_, this, (id, tex_raw): (u32, Option<u64>)| {
                this.with_mut(|g| {
                    if let Some(marker) = g.markers.get_mut(id) {
                        marker.style.icon_texture = tex_raw.map(|raw| raw.to_string());
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
                })
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
                    g.layers.add(Layer {
                        name,
                        visible: true,
                        alpha: 1.0,
                        z_order: z_order.unwrap_or(0),
                        kind: String::new(),
                        region_colors: HashMap::new(),
                    })
                })
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
                })
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
        /// @param | alpha | number | Layer alpha.
        /// @return | boolean | True when the layer exists.
        methods.add_method_mut("setLayerAlpha", |_, this, (name, alpha): (String, f32)| {
            this.with_mut(|g| g.layers.set_alpha(&name, alpha))
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
            this.state.borrow_mut().render_commands.extend(cmds);
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
                let steps = steps.unwrap_or(24);
                this.with_mut(|g| {
                    let arc_id = g.arc_next_id;
                    g.arc_next_id += 1;
                    let arc = crate::globe::types::Arc {
                        id: arc_id,
                        arc_type: "route".to_string(),
                        screen_points: Vec::new(),
                        color: [1.0, 1.0, 0.0, 1.0],
                        width: 1.5,
                        from: (lat1, lon1),
                        to: (lat2, lon2),
                        steps,
                        visible: true,
                    };
                    g.arcs.insert(arc_id, arc);
                    arc_id
                })
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
                let spec = parse_globe_spec(spec_tbl);
                {
                    let mut guard = this.reg.lock().map_err(|e| {
                        mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                    })?;
                    guard.create(name.clone(), spec);
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
fn parse_globe_spec(tbl: Option<LuaTable>) -> GlobeSpec {
    let mut spec = GlobeSpec::default();
    if let Some(t) = tbl {
        if let Ok(v) = t.get::<_, f32>("radius") {
            spec.radius = v.max(1.0);
        }
        if let Ok(v) = t.get::<_, f32>("axial_tilt_deg") {
            spec.axial_tilt_deg = v;
        }
        if let Ok(v) = t.get::<_, f32>("rotation_deg") {
            spec.rotation_deg = v.rem_euclid(360.0);
        }
        if let Ok(v) = t.get::<_, f32>("time_of_day") {
            spec.time_of_day = v.rem_euclid(24.0);
        }
        if let Ok(v) = t.get::<_, bool>("render_borders") {
            spec.render_borders = v;
        }
        if let Ok(v) = t.get::<_, f32>("border_width") {
            spec.border_width = v.max(0.0);
        }
        if let Ok(v) = t.get::<_, f32>("ambient") {
            spec.ambient = v.clamp(0.0, 1.0);
        }
        if let Ok(v) = t.get::<_, f32>("auto_rotation_deg_per_sec") {
            spec.auto_rotation_deg_per_sec = v;
        }
        if let Ok(v) = t.get::<_, f32>("atmosphere_width") {
            spec.atmosphere_width = v.max(0.0);
        }
        if let Ok(v) = t.get::<_, u8>("border_smoothing_passes") {
            spec.border_smoothing_passes = v;
        }
    }
    spec
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
    /// @param | spec_tbl | table? | Globe specification table.
    /// @return | LGlobe | New globe handle.
    tbl.set(
        "new",
        lua.create_function(move |_, (name, spec_tbl): (String, Option<LuaTable>)| {
            let spec = parse_globe_spec(spec_tbl);
            {
                let mut guard = new_reg.lock().map_err(|e| {
                    mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                })?;
                guard.create(name.clone(), spec);
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
                let spec = parse_globe_spec(spec_tbl);
                let provinces =
                    loader::load_from_toml_file(&path).map_err(mlua::Error::RuntimeError)?;
                {
                    let mut guard = load_toml_file_reg.lock().map_err(|e| {
                        mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                    })?;
                    let globe = guard.create(name.clone(), spec);
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
    /// @param | spec_tbl | table? | Globe specification table.
    /// @return | LGlobe | New populated globe handle.
    tbl.set(
        "loadFromTOML",
        lua.create_function(
            move |_, (name, toml_src, spec_tbl): (String, String, Option<LuaTable>)| {
                let spec = parse_globe_spec(spec_tbl);
                let provinces =
                    loader::load_from_toml_str(&toml_src).map_err(mlua::Error::RuntimeError)?;
                {
                    let mut guard = load_toml_reg.lock().map_err(|e| {
                        mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                    })?;
                    let globe = guard.create(name.clone(), spec);
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
                let spec = parse_globe_spec(spec_tbl);
                let provinces =
                    loader::load_from_png_file(&png_path).map_err(mlua::Error::RuntimeError)?;
                {
                    let mut guard = load_png_reg.lock().map_err(|e| {
                        mlua::Error::RuntimeError(format!("registry lock poisoned: {e}"))
                    })?;
                    let globe = guard.create(name.clone(), spec);
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
                let spec = parse_globe_spec(spec_tbl);
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
                    let globe = guard.create(name.clone(), spec);
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
