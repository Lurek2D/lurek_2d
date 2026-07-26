//! Registers the `lurek.procgen` Lua API for generators, noise settings, option parsing, and procgen userdata.

use super::tilefield_api::LuaTileField;
use super::SharedState;
use crate::agent::chat::{ollama_generate_json, read_global_config};
use crate::procgen::biome::{BiomeClassifier, BiomeRules, BiomeType};
use crate::procgen::cellular_world::default_palette as cellular_default_palette;
use crate::procgen::heightmap::Heightmap;
use crate::procgen::lsystem::LSystem;
use crate::procgen::namegen::NameGen;
use crate::procgen::noise::{
    fbm as noise_fbm, perlin2d as noise_perlin2d, perlin3d as noise_perlin3d,
    perlin4d as noise_perlin4d,
};
use crate::procgen::noise::{simplex_noise_2d, simplex_noise_3d};
use crate::procgen::world_graph::generate_world_graph;
use crate::procgen::{
    bsp_dungeon, bsp_dungeon_with_prefabs, flood_fill, perlin_noise_periodic, place_constrained,
    rooms_dungeon_with_prefabs, try_cellular_automata, try_generate_noise_map_parallel,
    try_parse_llm_constraints, try_parse_llm_wfc_response, try_poisson_disk, try_rooms_dungeon,
    try_voronoi_diagram, try_wfc_generate, validate_connectivity, BspOpts, BspPrefabStamp,
    CellType, CellularOpts, CellularWorld, ConnectivityOptions, ConnectivityPoint,
    ConnectivitySafePoint, DistType, ErosionMode, FractalType, HeightmapOpts, MapGenOptions,
    NoiseGenerator, NoiseKind, PlacementCandidate, PlacementRules, ProcgenGrid, ProcgenLimits,
    ProcgenScalarGrid, RoomPrefabStamp, RoomsOpts, VoronoiOpts, WfcOpts, WfcRules, WfcTile,
};
use crate::tilefield::{CellCoord, TileChannel, TileField, TileTopology};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::{BTreeMap, BTreeSet};
use std::ops::Deref;
use std::rc::Rc;

/// Lua-visible typed result for procgen functions that produce a 2D tile/value grid.
#[derive(Clone)]
pub struct LuaProcgenGrid {
    inner: ProcgenGrid,
}

/// Lua-visible typed result for procgen functions that produce a 2D scalar field.
#[derive(Clone)]
pub struct LuaProcgenScalarGrid {
    inner: ProcgenScalarGrid,
}

impl LuaProcgenGrid {
    fn new(kind: impl Into<String>, width: u32, height: u32, cells: Vec<u32>) -> LuaResult<Self> {
        Ok(Self {
            inner: ProcgenGrid::new(kind, width, height, cells)
                .map_err(|err| LuaError::RuntimeError(format!("lurek.procgen: {err}")))?,
        })
    }
}

impl Deref for LuaProcgenGrid {
    type Target = ProcgenGrid;

    fn deref(&self) -> &Self::Target {
        &self.inner
    }
}

impl LuaProcgenScalarGrid {
    fn new(kind: impl Into<String>, width: u32, height: u32, cells: Vec<f32>) -> LuaResult<Self> {
        Ok(Self {
            inner: ProcgenScalarGrid::new(kind, width, height, cells)
                .map_err(|err| LuaError::RuntimeError(format!("lurek.procgen: {err}")))?,
        })
    }
}

impl Deref for LuaProcgenScalarGrid {
    type Target = ProcgenScalarGrid;

    fn deref(&self) -> &Self::Target {
        &self.inner
    }
}

fn procgen_grid_len(width: u32, height: u32) -> LuaResult<usize> {
    width
        .checked_mul(height)
        .and_then(|v| usize::try_from(v).ok())
        .ok_or_else(|| LuaError::RuntimeError("lurek.procgen grid dimensions overflow".to_string()))
}

fn procgen_grid_from_table(
    width: u32,
    height: u32,
    cells_tbl: LuaTable,
    kind: String,
) -> LuaResult<LuaProcgenGrid> {
    let expected = procgen_grid_len(width, height)?;
    let mut cells = Vec::with_capacity(expected);
    for value in cells_tbl.sequence_values::<u32>() {
        cells.push(value?);
    }
    if cells.len() != expected {
        return Err(LuaError::RuntimeError(format!(
            "lurek.procgen grid expected {expected} cells, got {}",
            cells.len()
        )));
    }
    LuaProcgenGrid::new(kind, width, height, cells)
}

fn procgen_scalar_grid_from_table(
    width: u32,
    height: u32,
    cells_tbl: LuaTable,
    kind: String,
) -> LuaResult<LuaProcgenScalarGrid> {
    let expected = procgen_grid_len(width, height)?;
    let mut cells = Vec::with_capacity(expected);
    for value in cells_tbl.sequence_values::<f32>() {
        cells.push(value?);
    }
    if cells.len() != expected {
        return Err(LuaError::RuntimeError(format!(
            "lurek.procgen scalar grid expected {expected} cells, got {}",
            cells.len()
        )));
    }
    LuaProcgenScalarGrid::new(kind, width, height, cells)
}

fn procgen_topology_from_opts(opts: Option<&LuaTable>) -> LuaResult<TileTopology> {
    let topology = opts
        .and_then(|t| t.get::<_, Option<String>>("topology").ok().flatten())
        .unwrap_or_else(|| "square".to_string());
    TileTopology::parse(&topology)
        .map_err(|err| LuaError::RuntimeError(format!("lurek.procgen.toTileField: {err}")))
}

fn procgen_required_string_opt(opts: Option<&LuaTable>, key: &str, api: &str) -> LuaResult<String> {
    opts.and_then(|t| t.get::<_, Option<String>>(key).ok().flatten())
        .filter(|value| !value.trim().is_empty())
        .ok_or_else(|| LuaError::RuntimeError(format!("{api}: opts.{key} is required")))
}

fn procgen_cells_to_table<'lua>(lua: &'lua Lua, cells: &[u32]) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (index, value) in cells.iter().enumerate() {
        table.set(index + 1, *value)?;
    }
    Ok(table)
}

fn procgen_scalar_cells_to_table<'lua>(lua: &'lua Lua, cells: &[f32]) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    for (index, value) in cells.iter().enumerate() {
        table.set(index + 1, *value)?;
    }
    Ok(table)
}

fn procgen_string_set(table: Option<LuaTable>) -> LuaResult<BTreeSet<String>> {
    table
        .map(|values| {
            values
                .sequence_values::<String>()
                .collect::<LuaResult<BTreeSet<_>>>()
        })
        .transpose()
        .map(Option::unwrap_or_default)
}

fn procgen_optional_stringish(
    table: &LuaTable,
    field: &str,
    api: &str,
) -> LuaResult<Option<String>> {
    match table.get::<_, LuaValue>(field)? {
        LuaValue::Nil => Ok(None),
        LuaValue::String(value) => Ok(Some(value.to_str()?.to_string())),
        LuaValue::Integer(value) => Ok(Some(value.to_string())),
        value => Err(LuaError::RuntimeError(format!(
            "{api}: {field} must be a string or integer, got {}",
            value.type_name()
        ))),
    }
}

fn placement_to_lua<'lua>(
    lua: &'lua Lua,
    placement: &crate::procgen::Placement,
) -> LuaResult<LuaTable<'lua>> {
    let output = lua.create_table()?;
    output.set("candidateIndex", placement.candidate_index)?;
    output.set("id", placement.candidate.id.as_deref())?;
    output.set("x", placement.candidate.x)?;
    output.set("y", placement.candidate.y)?;
    output.set("level", placement.candidate.level.as_deref())?;
    output.set("region", placement.candidate.region.as_deref())?;
    output.set("weight", placement.candidate.weight)?;
    output.set(
        "uniquenessGroup",
        placement.candidate.uniqueness_group.as_deref(),
    )?;
    let tags = lua.create_table()?;
    for (index, tag) in placement.candidate.tags.iter().enumerate() {
        tags.set(index + 1, tag.as_str())?;
    }
    output.set("tags", tags)?;
    Ok(output)
}

fn connectivity_point_to_lua<'lua>(
    lua: &'lua Lua,
    point: ConnectivityPoint,
) -> LuaResult<LuaTable<'lua>> {
    let output = lua.create_table()?;
    output.set("x", point.x)?;
    output.set("y", point.y)?;
    Ok(output)
}

fn procgen_channel_from_name(name: &str, api: &str) -> LuaResult<TileChannel> {
    TileChannel::parse(name).map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))
}

#[allow(clippy::too_many_arguments)]
fn write_procgen_grid_to_field(
    field: &mut TileField,
    width: u32,
    height: u32,
    cells: &[u32],
    slot: &str,
    z: u32,
    skip_zero: bool,
    api: &str,
) -> LuaResult<()> {
    let (field_width, field_height, field_levels) = field.size();
    if width > field_width || height > field_height || z >= field_levels {
        return Err(LuaError::RuntimeError(format!(
            "{api}: target tilefield is too small or level is out of bounds"
        )));
    }
    if !field.has_slot(slot) {
        field
            .define_slot(slot.to_string())
            .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
    }
    for y in 0..height {
        for x in 0..width {
            let value = cells[(y * width + x) as usize];
            if skip_zero && value == 0 {
                continue;
            }
            field
                .set_ref(CellCoord { x, y, z }, slot.to_string(), value)
                .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
        }
    }
    Ok(())
}

struct ProcgenTileFieldLuaWriter;

impl ProcgenTileFieldLuaWriter {
    fn write_procgen_scalar_grid_to_field(
        field: &mut TileField,
        width: u32,
        height: u32,
        cells: &[f32],
        z: u32,
        opts: Option<&LuaTable>,
        api: &str,
    ) -> LuaResult<()> {
        let (field_width, field_height, field_levels) = field.size();
        if width > field_width || height > field_height || z >= field_levels {
            return Err(LuaError::RuntimeError(format!(
                "{api}: target tilefield is too small or level is out of bounds"
            )));
        }

        let target = procgen_required_string_opt(opts, "target", api)?;
        let channel_name = opts.and_then(|t| t.get::<_, Option<String>>("channel").ok().flatten());
        let scale = opts
            .and_then(|t| t.get::<_, Option<f32>>("scale").ok().flatten())
            .unwrap_or(1.0);
        let offset = opts
            .and_then(|t| t.get::<_, Option<f32>>("offset").ok().flatten())
            .unwrap_or(0.0);
        let threshold = opts
            .and_then(|t| t.get::<_, Option<f32>>("threshold").ok().flatten())
            .unwrap_or(0.5);
        let invert = opts
            .and_then(|t| t.get::<_, Option<bool>>("invert").ok().flatten())
            .unwrap_or(false);

        let channel = if target == "cost" || target == "block" {
            let channel_name = channel_name
                .as_deref()
                .filter(|value| !value.trim().is_empty())
                .ok_or_else(|| {
                    LuaError::RuntimeError(format!("{api}: opts.channel is required"))
                })?;
            Some(procgen_channel_from_name(channel_name, api)?)
        } else {
            None
        };

        for y in 0..height {
            for x in 0..width {
                let value = cells[(y * width + x) as usize] * scale + offset;
                let coord = CellCoord { x, y, z };
                match target.as_str() {
                    "sunOcclusion" | "sun_occlusion" => {
                        field
                            .set_sun_occlusion(coord, value)
                            .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
                    }
                    "cost" => {
                        field
                            .set_cost(coord, channel.unwrap(), value)
                            .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
                    }
                    "block" => {
                        let blocked = if invert {
                            value < threshold
                        } else {
                            value >= threshold
                        };
                        field
                            .set_block(coord, channel.unwrap(), blocked)
                            .map_err(|err| LuaError::RuntimeError(format!("{api}: {err}")))?;
                    }
                    other => {
                        return Err(LuaError::RuntimeError(format!(
                        "{api}: invalid target '{other}' (expected sunOcclusion, cost, or block)"
                    )));
                    }
                }
            }
        }
        Ok(())
    }
}

fn write_procgen_scalar_grid_to_field(
    field: &mut TileField,
    width: u32,
    height: u32,
    cells: &[f32],
    z: u32,
    opts: Option<&LuaTable>,
    api: &str,
) -> LuaResult<()> {
    ProcgenTileFieldLuaWriter::write_procgen_scalar_grid_to_field(
        field, width, height, cells, z, opts, api,
    )
}

impl LuaUserData for LuaProcgenGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getSize --
        /// Returns the generated grid width and height in cells.
        /// @return | integer | Width.
        /// @return | integer | Height.
        methods.add_method("getSize", |_, this, ()| Ok((this.width, this.height)));

        // -- getWidth --
        /// Returns the generated grid width in cells for this noise result.
        /// @return | integer | Width.
        methods.add_method("getWidth", |_, this, ()| Ok(this.width));

        // -- getHeight --
        /// Returns the generated grid height in cells for this noise result.
        /// @return | integer | Height.
        methods.add_method("getHeight", |_, this, ()| Ok(this.height));

        // -- getKind --
        /// Returns the generator kind label attached to this grid.
        /// @return | string | Generator kind.
        methods.add_method("getKind", |_, this, ()| Ok(this.kind.clone()));

        // -- getCell --
        /// Returns one cell value using one-based Lua coordinates.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | integer | Cell value.
        methods.add_method("getCell", |_, this, (x, y): (u32, u32)| {
            if x == 0 || y == 0 || x > this.width || y > this.height {
                return Err(LuaError::RuntimeError(
                    "lurek.procgen.LProcgenGrid:getCell coordinate is out of bounds".to_string(),
                ));
            }
            let index = ((y - 1) * this.width + (x - 1)) as usize;
            Ok(this.cells[index])
        });

        // -- toTable --
        /// Serializes this grid to a plain Lua table.
        /// @return | table | Table with kind, width, height, and cells.
        methods.add_method("toTable", |lua, this, ()| {
            let table = lua.create_table()?;
            table.set("kind", this.kind.clone())?;
            table.set("width", this.width)?;
            table.set("height", this.height)?;
            table.set("cells", procgen_cells_to_table(lua, &this.cells)?)?;
            Ok(table)
        });

        // -- toTileField --
        /// Converts this generated grid into a tilefield by writing each value as a named ref.
        /// @param | opts | table | Options: slot, topology, skipZero.
        /// @return | LTileField | Tilefield populated with refs.
        methods.add_method("toTileField", |_, this, opts: Option<LuaTable>| {
            let topology = procgen_topology_from_opts(opts.as_ref())?;
            let slot =
                procgen_required_string_opt(opts.as_ref(), "slot", "lurek.procgen.toTileField")?;
            let skip_zero = opts
                .as_ref()
                .and_then(|t| t.get::<_, Option<bool>>("skipZero").ok().flatten())
                .unwrap_or(false);
            let mut field =
                TileField::new(this.width, this.height, 1, topology).map_err(|err| {
                    LuaError::RuntimeError(format!("lurek.procgen.toTileField: {err}"))
                })?;
            write_procgen_grid_to_field(
                &mut field,
                this.width,
                this.height,
                &this.cells,
                &slot,
                0,
                skip_zero,
                "lurek.procgen.toTileField",
            )?;
            Ok(LuaTileField {
                inner: Rc::new(RefCell::new(field)),
            })
        });

        // -- writeTileField --
        /// Writes this generated grid into an existing tilefield ref layer.
        /// @param | field | LTileField | Target tilefield.
        /// @param | opts | table | Options: slot, z, skipZero.
        methods.add_method(
            "writeTileField",
            |_, this, (field_ud, opts): (LuaAnyUserData, Option<LuaTable>)| {
                let slot = procgen_required_string_opt(
                    opts.as_ref(),
                    "slot",
                    "lurek.procgen.writeTileField",
                )?;
                let z = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<u32>>("z").ok().flatten())
                    .unwrap_or(1)
                    .checked_sub(1)
                    .ok_or_else(|| {
                        LuaError::RuntimeError(
                            "lurek.procgen.writeTileField: z must be >= 1".to_string(),
                        )
                    })?;
                let skip_zero = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<bool>>("skipZero").ok().flatten())
                    .unwrap_or(false);
                let field_ud = field_ud.borrow::<LuaTileField>()?;
                let mut field = field_ud.inner.borrow_mut();
                write_procgen_grid_to_field(
                    &mut field,
                    this.width,
                    this.height,
                    &this.cells,
                    &slot,
                    z,
                    skip_zero,
                    "lurek.procgen.writeTileField",
                )
            },
        );

        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always returns "LProcgenGrid".
        methods.add_method("type", |_, _, ()| Ok("LProcgenGrid"));

        // -- typeOf --
        /// Check whether this object matches a given type name.
        /// @param | name | string | Type name to test.
        /// @return | boolean | True if the object is of the specified type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LProcgenGrid" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaProcgenScalarGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getSize --
        /// Returns scalar grid width and height.
        /// @return | integer | Width.
        /// @return | integer | Height.
        methods.add_method("getSize", |_, this, ()| Ok((this.width, this.height)));

        // -- getWidth --
        /// Returns the scalar grid width in cells for this generated field.
        /// @return | integer | Width.
        methods.add_method("getWidth", |_, this, ()| Ok(this.width));

        // -- getHeight --
        /// Returns the scalar grid height in cells for this generated field.
        /// @return | integer | Height.
        methods.add_method("getHeight", |_, this, ()| Ok(this.height));

        // -- getKind --
        /// Returns the generator kind label attached to this scalar grid.
        /// @return | string | Generator kind.
        methods.add_method("getKind", |_, this, ()| Ok(this.kind.clone()));

        // -- getCell --
        /// Returns one scalar cell value using one-based Lua coordinates.
        /// @param | x | integer | One-based column.
        /// @param | y | integer | One-based row.
        /// @return | number | Scalar cell value.
        methods.add_method("getCell", |_, this, (x, y): (u32, u32)| {
            if x == 0 || y == 0 || x > this.width || y > this.height {
                return Err(LuaError::RuntimeError(
                    "lurek.procgen.LProcgenScalarGrid:getCell coordinate is out of bounds"
                        .to_string(),
                ));
            }
            let index = ((y - 1) * this.width + (x - 1)) as usize;
            Ok(this.cells[index])
        });

        // -- toTable --
        /// Serializes this scalar grid to a plain Lua table.
        /// @return | table | Table with kind, width, height, and cells.
        methods.add_method("toTable", |lua, this, ()| {
            let table = lua.create_table()?;
            table.set("kind", this.kind.clone())?;
            table.set("width", this.width)?;
            table.set("height", this.height)?;
            table.set("cells", procgen_scalar_cells_to_table(lua, &this.cells)?)?;
            Ok(table)
        });

        // -- toTileField --
        /// Converts this scalar field into a new tilefield channel layer.
        /// @param | opts | table | Options: topology, target, channel, scale, offset, threshold, invert.
        /// @return | LTileField | Tilefield populated from scalar values.
        methods.add_method("toTileField", |_, this, opts: Option<LuaTable>| {
            let topology = procgen_topology_from_opts(opts.as_ref())?;
            let mut field =
                TileField::new(this.width, this.height, 1, topology).map_err(|err| {
                    LuaError::RuntimeError(format!("lurek.procgen.scalarToTileField: {err}"))
                })?;
            write_procgen_scalar_grid_to_field(
                &mut field,
                this.width,
                this.height,
                &this.cells,
                0,
                opts.as_ref(),
                "lurek.procgen.scalarToTileField",
            )?;
            Ok(LuaTileField {
                inner: Rc::new(RefCell::new(field)),
            })
        });

        // -- writeTileField --
        /// Writes this scalar field into an existing tilefield channel layer.
        /// @param | field | LTileField | Target tilefield.
        /// @param | opts | table | Options: z, target, channel, scale, offset, threshold, invert.
        methods.add_method(
            "writeTileField",
            |_, this, (field_ud, opts): (LuaAnyUserData, Option<LuaTable>)| {
                let z = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<u32>>("z").ok().flatten())
                    .unwrap_or(1)
                    .checked_sub(1)
                    .ok_or_else(|| {
                        LuaError::RuntimeError(
                            "lurek.procgen.scalarWriteTileField: z must be >= 1".to_string(),
                        )
                    })?;
                let field_ud = field_ud.borrow::<LuaTileField>()?;
                let mut field = field_ud.inner.borrow_mut();
                write_procgen_scalar_grid_to_field(
                    &mut field,
                    this.width,
                    this.height,
                    &this.cells,
                    z,
                    opts.as_ref(),
                    "lurek.procgen.scalarWriteTileField",
                )
            },
        );

        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always returns "LProcgenScalarGrid".
        methods.add_method("type", |_, _, ()| Ok("LProcgenScalarGrid"));

        // -- typeOf --
        /// Check whether this object matches a given type name.
        /// @param | name | string | Type name to test.
        /// @return | boolean | True if the object is of the specified type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LProcgenScalarGrid" || name == "LObject")
        });
    }
}

/// Lua-visible wrapper around the biome classification engine, used to assign biome types based on height, moisture, and temperature.
pub struct LuaBiomeClassifier(BiomeClassifier);
impl LuaUserData for LuaBiomeClassifier {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- classify --
        /// Classify a single point into a biome type based on its environmental parameters.
        /// @param | height | number | Elevation value (0.0â€“1.0) of the terrain point.
        /// @param | moisture | number | Moisture level (0.0â€“1.0) at the point.
        /// @param | temperature | number | Temperature value (0.0â€“1.0) at the point.
        /// @return | string | Biome name such as "ocean", "desert", "grassland", "taiga", etc.
        methods.add_method("classify", |_, this, (h, m, t): (f32, f32, f32)| {
            Ok(this.0.classify(h, m, t).as_str())
        });
        // -- classifyMap --
        /// Classify an entire grid of points into biome types in bulk.
        /// @param | width | integer | Grid width in cells.
        /// @param | height | integer | Grid height in cells.
        /// @param | heights | table | Flat array of height values (length = width*height).
        /// @param | moisture | table | Flat array of moisture values (length = width*height).
        /// @param | temperature | table? | Optional flat array of temperature values. If omitted, temperature is ignored.
        /// @return | string[] | Biome name strings (length = width*height).
        methods.add_method(
            "classifyMap",
            |lua, this, (width, height, ht, mt, tt): (u32, u32, LuaTable, LuaTable, Option<LuaTable>)| {
                let n = (width * height) as usize;
                let heights: Vec<f32> = (1..=n).filter_map(|i| ht.get::<_, f32>(i).ok()).collect();
                let moisture: Vec<f32> = (1..=n).filter_map(|i| mt.get::<_, f32>(i).ok()).collect();
                let temperature: Vec<f32> = if let Some(t) = tt {
                    (1..=n).filter_map(|i| t.get::<_, f32>(i).ok()).collect()
                } else {
                    Vec::new()
                };
                let biomes = this.0.classify_map(width, height, &heights, &moisture, &temperature);
                let out = lua.create_table()?;
                for (i, b) in biomes.iter().enumerate() {
                    out.set(i + 1, b.as_str())?;
                }
                Ok(out)
            },
        );
        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always returns "LBiomeClassifier".
        methods.add_method("type", |_, _, ()| Ok("LBiomeClassifier"));
        // -- typeOf --
        /// Check whether this object matches a given type name.
        /// @param | name | string | Type name to test (e.g. "LBiomeClassifier" or "Object").
        /// @return | boolean | True if the object is of the specified type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LBiomeClassifier" || name == "LObject")
        });
    }
}
impl BiomeRules {
    /// Builds biome classification rules from a Lua options table.
    pub fn from_lua_table(t: &LuaTable) -> LuaResult<Self> {
        let mut rules = Self::default();
        if let Ok(v) = t.get::<_, f32>("ocean_threshold") {
            rules.ocean_threshold = v;
        }
        if let Ok(v) = t.get::<_, f32>("coast_threshold") {
            rules.coast_threshold = v;
        }
        if let Ok(v) = t.get::<_, f32>("mountain_threshold") {
            rules.mountain_threshold = v;
        }
        if let Ok(v) = t.get::<_, f32>("ice_cap_threshold") {
            rules.ice_cap_threshold = v;
        }
        if let Ok(v) = t.get::<_, f32>("cold_temperature") {
            rules.cold_temperature = v;
        }
        if let Ok(v) = t.get::<_, f32>("warm_temperature") {
            rules.warm_temperature = v;
        }
        if let Ok(v) = t.get::<_, f32>("dry_moisture") {
            rules.dry_moisture = v;
        }
        if let Ok(v) = t.get::<_, f32>("wet_moisture") {
            rules.wet_moisture = v;
        }
        Ok(rules)
    }
}
impl BiomeType {
    /// Parses a biome type name into its enum variant.
    pub fn from_name(s: &str) -> Self {
        match s {
            "ocean" => Self::Ocean,
            "coast" => Self::Coast,
            "beach" => Self::Beach,
            "desert" => Self::Desert,
            "grassland" => Self::Grassland,
            "shrubland" => Self::Shrubland,
            "tropical_rainforest" => Self::TropicalRainforest,
            "temperate_forest" => Self::TemperateForest,
            "taiga" => Self::Taiga,
            "tundra" => Self::Tundra,
            "mountain" => Self::Mountain,
            "ice_cap" => Self::IceCap,
            "swamp" => Self::Swamp,
            "savanna" => Self::Savanna,
            _ => Self::Grassland,
        }
    }
}
/// Lua-side wrapper for a procedural noise generator.
pub struct LuaNoiseGenerator {
    /// Wrapped noise generator state.
    inner: NoiseGenerator,
}
/// Resolves a Lua noise kind string into a noise kind enum.
fn resolve_noise_kind(name: &str) -> NoiseKind {
    match name.to_lowercase().as_str() {
        "simplex" => NoiseKind::Simplex,
        _ => NoiseKind::Perlin,
    }
}
/// Resolves a Lua distance type string into a distance type enum.
fn resolve_dist_type(name: &str) -> DistType {
    match name.to_lowercase().as_str() {
        "manhattan" => DistType::Manhattan,
        "chebyshev" => DistType::Chebyshev,
        _ => DistType::Euclidean,
    }
}
/// Resolves a Lua fractal type string into a fractal type enum.
fn resolve_fractal_type(name: &str) -> FractalType {
    match name.to_lowercase().as_str() {
        "ridged" => FractalType::Ridged,
        "turbulence" => FractalType::Turbulence,
        _ => FractalType::Fbm,
    }
}

fn procgen_limits() -> ProcgenLimits {
    ProcgenLimits::default()
}

fn map_gen_options_from_snake_table(opts: Option<&LuaTable>) -> LuaResult<(MapGenOptions, u64)> {
    let mut cfg = MapGenOptions::default();
    let mut seed = 0_u64;
    if let Some(t) = opts {
        if let Ok(v) = t.get::<_, f64>("scale_x") {
            cfg.scale_x = v;
        }
        if let Ok(v) = t.get::<_, f64>("scale_y") {
            cfg.scale_y = v;
        }
        if let Ok(v) = t.get::<_, u32>("octaves") {
            cfg.octaves = v;
        }
        if let Ok(v) = t.get::<_, f64>("lacunarity") {
            cfg.lacunarity = v;
        }
        if let Ok(v) = t.get::<_, f64>("persistence") {
            cfg.persistence = v;
        }
        if let Ok(v) = t.get::<_, f64>("offset_x") {
            cfg.offset_x = v;
        }
        if let Ok(v) = t.get::<_, f64>("offset_y") {
            cfg.offset_y = v;
        }
        if let Ok(v) = t.get::<_, bool>("parallel") {
            cfg.parallel_enabled = v;
        }
        if let Ok(v) = t.get::<_, usize>("parallel_chunk_size") {
            cfg.parallel_chunk_size = Some(v);
        }
        if let Ok(v) = t.get::<_, u64>("seed") {
            seed = v;
        }
    }
    Ok((cfg, seed))
}

fn lua_procgen_error(err: crate::procgen::ProcgenError) -> LuaError {
    LuaError::RuntimeError(err.to_string())
}
/// Provides Lua methods for procedural noise sampling and map generation.
impl LuaUserData for LuaNoiseGenerator {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- perlin1d --
        /// Samples 1D Perlin noise. This method is available to Lua scripts.
        /// @param | x | number | X coordinate.
        /// @return | number | Noise value.
        methods.add_method("perlin1d", |_, this, x: f64| Ok(this.inner.perlin_1d(x)));
        // -- perlin2d --
        /// Samples 2D Perlin noise. This method is available to Lua scripts.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @return | number | Noise value.
        methods.add_method("perlin2d", |_, this, (x, y): (f64, f64)| {
            Ok(this.inner.perlin_2d(x, y))
        });
        // -- perlin3d --
        /// Samples 3D Perlin noise. This method is available to Lua scripts.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @param | z | number | Z coordinate.
        /// @return | number | Noise value.
        methods.add_method("perlin3d", |_, this, (x, y, z): (f64, f64, f64)| {
            Ok(this.inner.perlin_3d(x, y, z))
        });
        // -- perlin4d --
        /// Samples 4D Perlin noise. This method is available to Lua scripts.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @param | z | number | Z coordinate.
        /// @param | w | number | W coordinate.
        /// @return | number | Noise value.
        methods.add_method("perlin4d", |_, this, (x, y, z, w): (f64, f64, f64, f64)| {
            Ok(this.inner.simplex_4d(x, y, z, w))
        });
        // -- simplex1d --
        /// Samples 1D simplex noise. This method is available to Lua scripts.
        /// @param | x | number | X coordinate.
        /// @return | number | Noise value.
        methods.add_method("simplex1d", |_, this, x: f64| {
            Ok(this.inner.simplex_2d(x, 0.0))
        });
        // -- simplex2d --
        /// Samples 2D simplex noise. This method is available to Lua scripts.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @return | number | Noise value.
        methods.add_method("simplex2d", |_, this, (x, y): (f64, f64)| {
            Ok(this.inner.simplex_2d(x, y))
        });
        // -- simplex3d --
        /// Samples 3D simplex noise. This method is available to Lua scripts.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @param | z | number | Z coordinate.
        /// @return | number | Noise value.
        methods.add_method("simplex3d", |_, this, (x, y, z): (f64, f64, f64)| {
            Ok(this.inner.simplex_3d(x, y, z))
        });
        // -- worley2d --
        /// Samples 2D Worley noise. This method is available to Lua scripts.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @param | dist_name | string? | Distance type name (default `"euclidean"`).
        /// @param | f2 | boolean? | Second-feature flag (default false).
        /// @return | number | Noise value.
        methods.add_method(
            "worley2d",
            |_, this, (x, y, dist_name, f2): (f64, f64, Option<String>, Option<bool>)| {
                let dist = dist_name
                    .as_deref()
                    .map(resolve_dist_type)
                    .unwrap_or(DistType::Euclidean);
                Ok(this.inner.worley_2d(x, y, dist, f2.unwrap_or(false)))
            },
        );
        // -- worley3d --
        /// Samples 3D Worley noise. This method is available to Lua scripts.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @param | z | number | Z coordinate.
        /// @param | dist_name | string? | Distance type name (default `"euclidean"`).
        /// @param | f2 | boolean? | Second-feature flag (default false).
        /// @return | number | Noise value.
        methods.add_method(
            "worley3d",
            |_, this, (x, y, z, dist_name, f2): (f64, f64, f64, Option<String>, Option<bool>)| {
                let dist = dist_name
                    .as_deref()
                    .map(resolve_dist_type)
                    .unwrap_or(DistType::Euclidean);
                Ok(this.inner.worley_3d(x, y, z, dist, f2.unwrap_or(false)))
            },
        );
        // -- fbm --
        /// Samples fractal Brownian motion noise.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @param | octaves | integer? | Octave count (default 4).
        /// @param | lac | number? | Lacunarity (default 2.0).
        /// @param | pers | number? | Persistence (default 0.5).
        /// @param | kind | string? | Noise kind name (default `"perlin"`).
        /// @return | number | Noise value.
        methods.add_method(
            "fbm",
            |_,
             this,
             (x, y, octaves, lac, pers, kind): (
                f64,
                f64,
                Option<u32>,
                Option<f64>,
                Option<f64>,
                Option<String>,
            )| {
                let nk = kind
                    .as_deref()
                    .map(resolve_noise_kind)
                    .unwrap_or(NoiseKind::Perlin);
                Ok(this.inner.fbm(
                    x,
                    y,
                    octaves.unwrap_or(4),
                    lac.unwrap_or(2.0),
                    pers.unwrap_or(0.5),
                    nk,
                ))
            },
        );
        // -- ridged --
        /// Samples ridged fractal noise. This method is available to Lua scripts.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @param | octaves | integer? | Octave count (default 4).
        /// @param | lac | number? | Lacunarity (default 2.0).
        /// @param | pers | number? | Persistence (default 0.5).
        /// @param | kind | string? | Noise kind name (default `"perlin"`).
        /// @return | number | Noise value.
        methods.add_method(
            "ridged",
            |_,
             this,
             (x, y, octaves, lac, pers, kind): (
                f64,
                f64,
                Option<u32>,
                Option<f64>,
                Option<f64>,
                Option<String>,
            )| {
                let nk = kind
                    .as_deref()
                    .map(resolve_noise_kind)
                    .unwrap_or(NoiseKind::Perlin);
                Ok(this.inner.ridged(
                    x,
                    y,
                    octaves.unwrap_or(4),
                    lac.unwrap_or(2.0),
                    pers.unwrap_or(0.5),
                    nk,
                ))
            },
        );
        // -- turbulence --
        /// Samples turbulence fractal noise.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @param | octaves | integer? | Octave count (default 4).
        /// @param | lac | number? | Lacunarity (default 2.0).
        /// @param | pers | number? | Persistence (default 0.5).
        /// @param | kind | string? | Noise kind name (default `"perlin"`).
        /// @return | number | Noise value.
        methods.add_method(
            "turbulence",
            |_,
             this,
             (x, y, octaves, lac, pers, kind): (
                f64,
                f64,
                Option<u32>,
                Option<f64>,
                Option<f64>,
                Option<String>,
            )| {
                let nk = kind
                    .as_deref()
                    .map(resolve_noise_kind)
                    .unwrap_or(NoiseKind::Perlin);
                Ok(this.inner.turbulence(
                    x,
                    y,
                    octaves.unwrap_or(4),
                    lac.unwrap_or(2.0),
                    pers.unwrap_or(0.5),
                    nk,
                ))
            },
        );
        // -- warpDomain --
        /// Samples domain-warped noise coordinates.
        /// @param | x | number | X coordinate.
        /// @param | y | number | Y coordinate.
        /// @param | strength | number | Warp strength.
        /// @return | number | Warped noise value.
        methods.add_method(
            "warpDomain",
            |_, this, (x, y, strength): (f64, f64, f64)| Ok(this.inner.warp_domain(x, y, strength)),
        );
        // -- generateMap --
        /// Generates a noise map and returns it as a flat array table.
        /// @param | w | integer | Map width.
        /// @param | h | integer | Map height.
        /// @param | opts | table? | Generation options including scale, octaves, kind, fractal, offset, and backend.
        /// @return | number[] | Noise values.
        methods.add_method(
            "generateMap",
            |lua, this, (w, h, opts): (u32, u32, Option<LuaTable>)| {
                let map_opts = if let Some(t) = opts.as_ref() {
                    MapGenOptions {
                        scale_x: t.get::<_, Option<f64>>("scaleX")?.unwrap_or(1.0),
                        scale_y: t.get::<_, Option<f64>>("scaleY")?.unwrap_or(1.0),
                        octaves: t.get::<_, Option<u32>>("octaves")?.unwrap_or(4),
                        lacunarity: t.get::<_, Option<f64>>("lacunarity")?.unwrap_or(2.0),
                        persistence: t.get::<_, Option<f64>>("persistence")?.unwrap_or(0.5),
                        kind: t
                            .get::<_, Option<String>>("kind")?
                            .as_deref()
                            .map(resolve_noise_kind)
                            .unwrap_or(NoiseKind::Perlin),
                        fractal: t
                            .get::<_, Option<String>>("fractal")?
                            .as_deref()
                            .map(resolve_fractal_type)
                            .unwrap_or(FractalType::Fbm),
                        offset_x: t.get::<_, Option<f64>>("offsetX")?.unwrap_or(0.0),
                        offset_y: t.get::<_, Option<f64>>("offsetY")?.unwrap_or(0.0),
                        parallel_enabled: t.get::<_, Option<bool>>("parallel")?.unwrap_or(true),
                        parallel_chunk_size: t.get::<_, Option<usize>>("parallelChunkSize")?,
                    }
                } else {
                    MapGenOptions::default()
                };
                let _backend = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<String>>("backend").ok().flatten())
                    .unwrap_or_else(|| "cpu".to_string());
                let data = this
                    .inner
                    .try_generate_map_parallel(w, h, &map_opts, &procgen_limits())
                    .map_err(lua_procgen_error)?;
                let result = lua.create_table()?;
                for (i, v) in data.iter().enumerate() {
                    result.set(i + 1, *v)?;
                }
                Ok(result)
            },
        );
        // -- generateMapCompute --
        /// Generates a noise map through the compute backend and returns it as a flat array table.
        /// @param | w | integer | Map width.
        /// @param | h | integer | Map height.
        /// @param | opts | table? | Generation options including scale, octaves, kind, fractal, and offset.
        /// @return | number[] | Noise values.
        methods.add_method(
            "generateMapCompute",
            |lua, this, (w, h, opts): (u32, u32, Option<LuaTable>)| {
                let map_opts = if let Some(t) = opts {
                    MapGenOptions {
                        scale_x: t.get::<_, Option<f64>>("scaleX")?.unwrap_or(1.0),
                        scale_y: t.get::<_, Option<f64>>("scaleY")?.unwrap_or(1.0),
                        octaves: t.get::<_, Option<u32>>("octaves")?.unwrap_or(4),
                        lacunarity: t.get::<_, Option<f64>>("lacunarity")?.unwrap_or(2.0),
                        persistence: t.get::<_, Option<f64>>("persistence")?.unwrap_or(0.5),
                        kind: t
                            .get::<_, Option<String>>("kind")?
                            .as_deref()
                            .map(resolve_noise_kind)
                            .unwrap_or(NoiseKind::Perlin),
                        fractal: t
                            .get::<_, Option<String>>("fractal")?
                            .as_deref()
                            .map(resolve_fractal_type)
                            .unwrap_or(FractalType::Fbm),
                        offset_x: t.get::<_, Option<f64>>("offsetX")?.unwrap_or(0.0),
                        offset_y: t.get::<_, Option<f64>>("offsetY")?.unwrap_or(0.0),
                        parallel_enabled: t.get::<_, Option<bool>>("parallel")?.unwrap_or(true),
                        parallel_chunk_size: t.get::<_, Option<usize>>("parallelChunkSize")?,
                    }
                } else {
                    MapGenOptions::default()
                };
                let data = this
                    .inner
                    .try_generate_map_parallel(w, h, &map_opts, &procgen_limits())
                    .map_err(lua_procgen_error)?;
                let result = lua.create_table()?;
                for (i, v) in data.iter().enumerate() {
                    result.set(i + 1, *v)?;
                }
                Ok(result)
            },
        );
        // -- generateMapGrid --
        /// Generates a noise map and returns it as a typed scalar grid.
        /// @param | w | integer | Map width.
        /// @param | h | integer | Map height.
        /// @param | opts | table? | Generation options.
        /// @return | LProcgenScalarGrid | Typed scalar grid.
        methods.add_method(
            "generateMapGrid",
            |_, this, (w, h, opts): (u32, u32, Option<LuaTable>)| {
                let map_opts = if let Some(t) = opts.as_ref() {
                    MapGenOptions {
                        scale_x: t.get::<_, Option<f64>>("scaleX")?.unwrap_or(1.0),
                        scale_y: t.get::<_, Option<f64>>("scaleY")?.unwrap_or(1.0),
                        octaves: t.get::<_, Option<u32>>("octaves")?.unwrap_or(4),
                        lacunarity: t.get::<_, Option<f64>>("lacunarity")?.unwrap_or(2.0),
                        persistence: t.get::<_, Option<f64>>("persistence")?.unwrap_or(0.5),
                        kind: t
                            .get::<_, Option<String>>("kind")?
                            .as_deref()
                            .map(resolve_noise_kind)
                            .unwrap_or(NoiseKind::Perlin),
                        fractal: t
                            .get::<_, Option<String>>("fractal")?
                            .as_deref()
                            .map(resolve_fractal_type)
                            .unwrap_or(FractalType::Fbm),
                        offset_x: t.get::<_, Option<f64>>("offsetX")?.unwrap_or(0.0),
                        offset_y: t.get::<_, Option<f64>>("offsetY")?.unwrap_or(0.0),
                        parallel_enabled: t.get::<_, Option<bool>>("parallel")?.unwrap_or(true),
                        parallel_chunk_size: t.get::<_, Option<usize>>("parallelChunkSize")?,
                    }
                } else {
                    MapGenOptions::default()
                };
                let data = this
                    .inner
                    .try_generate_map_parallel(w, h, &map_opts, &procgen_limits())
                    .map_err(lua_procgen_error)?;
                LuaProcgenScalarGrid::new(
                    "noise_map",
                    w,
                    h,
                    data.into_iter().map(|value| value as f32).collect(),
                )
            },
        );

        // -- generateMapComputeGrid --
        /// Generates a compute-style noise map and returns it as a typed scalar grid.
        /// @param | w | integer | Map width.
        /// @param | h | integer | Map height.
        /// @param | opts | table? | Generation options.
        /// @return | LProcgenScalarGrid | Typed scalar grid.
        methods.add_method(
            "generateMapComputeGrid",
            |_, this, (w, h, opts): (u32, u32, Option<LuaTable>)| {
                let map_opts = if let Some(t) = opts {
                    MapGenOptions {
                        scale_x: t.get::<_, Option<f64>>("scaleX")?.unwrap_or(1.0),
                        scale_y: t.get::<_, Option<f64>>("scaleY")?.unwrap_or(1.0),
                        octaves: t.get::<_, Option<u32>>("octaves")?.unwrap_or(4),
                        lacunarity: t.get::<_, Option<f64>>("lacunarity")?.unwrap_or(2.0),
                        persistence: t.get::<_, Option<f64>>("persistence")?.unwrap_or(0.5),
                        kind: t
                            .get::<_, Option<String>>("kind")?
                            .as_deref()
                            .map(resolve_noise_kind)
                            .unwrap_or(NoiseKind::Perlin),
                        fractal: t
                            .get::<_, Option<String>>("fractal")?
                            .as_deref()
                            .map(resolve_fractal_type)
                            .unwrap_or(FractalType::Fbm),
                        offset_x: t.get::<_, Option<f64>>("offsetX")?.unwrap_or(0.0),
                        offset_y: t.get::<_, Option<f64>>("offsetY")?.unwrap_or(0.0),
                        parallel_enabled: t.get::<_, Option<bool>>("parallel")?.unwrap_or(true),
                        parallel_chunk_size: t.get::<_, Option<usize>>("parallelChunkSize")?,
                    }
                } else {
                    MapGenOptions::default()
                };
                let data = this
                    .inner
                    .try_generate_map_parallel(w, h, &map_opts, &procgen_limits())
                    .map_err(lua_procgen_error)?;
                LuaProcgenScalarGrid::new(
                    "noise_map",
                    w,
                    h,
                    data.into_iter().map(|value| value as f32).collect(),
                )
            },
        );

        // -- getSeed --
        /// Returns this noise generator seed.
        /// @return | integer | Seed value.
        methods.add_method("getSeed", |_, this, ()| Ok(this.inner.seed()));
        // -- setSeed --
        /// Sets this noise generator seed. This method is available to Lua scripts.
        /// @param | seed | integer | Seed value.
        methods.add_method_mut("setSeed", |_, this, seed: u64| {
            this.inner.set_seed(seed);
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this noise generator handle.
        /// @return | string | The string `LNoiseGenerator`.
        methods.add_method("type", |_, _, ()| Ok("LNoiseGenerator"));
        // -- typeOf --
        /// Returns whether this noise generator handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LNoiseGenerator` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LNoiseGenerator" || name == "LObject")
        });
    }
}
/// A cellular automaton simulation grid (sand, water, fire, gas, rock) for per-cell falling-sand style simulation.
#[derive(Clone)]
pub struct LuaCellular {
    sim: Rc<RefCell<CellularWorld>>,
}
impl LuaUserData for LuaCellular {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setCell --
        /// Sets a single cell in the cellular grid to a specific material type.
        /// @param | cx | integer | Cell column (0-based).
        /// @param | cy | integer | Cell row (0-based).
        /// @param | cellType | integer | Material type constant (CELL_AIR, CELL_SAND, etc.).
        methods.add_method_mut("setCell", |_, this, (cx, cy, t): (u32, u32, u8)| {
            this.sim.borrow_mut().set_cell(cx, cy, CellType::from_u8(t));
            Ok(())
        });
        // -- getCell --
        /// Returns the material type of a cell at the given grid position.
        /// @param | cx | integer | Cell column.
        /// @param | cy | integer | Cell row.
        /// @return | integer | Material type constant.
        methods.add_method("getCell", |_, this, (cx, cy): (u32, u32)| {
            Ok(this.sim.borrow().get_cell(cx, cy) as u8)
        });
        // -- fillRect --
        /// Fills a rectangular region of cells with a material type.
        /// @param | cx0 | integer | Top-left cell column.
        /// @param | cy0 | integer | Top-left cell row.
        /// @param | cw | integer | Width in cells.
        /// @param | ch | integer | Height in cells.
        /// @param | cellType | integer | Material type constant.
        methods.add_method_mut(
            "fillRect",
            |_, this, (cx0, cy0, cw, ch, t): (u32, u32, u32, u32, u8)| {
                this.sim
                    .borrow_mut()
                    .fill_rect(cx0, cy0, cw, ch, CellType::from_u8(t));
                Ok(())
            },
        );
        // -- fillCircle --
        /// Fills a circular region of cells with a material type.
        /// @param | cx | integer | Center cell column.
        /// @param | cy | integer | Center cell row.
        /// @param | r | integer | Radius in cells.
        /// @param | cellType | integer | Material type constant.
        methods.add_method_mut(
            "fillCircle",
            |_, this, (cx, cy, r, t): (u32, u32, u32, u8)| {
                this.sim
                    .borrow_mut()
                    .fill_circle(cx, cy, r, CellType::from_u8(t));
                Ok(())
            },
        );
        // -- step --
        /// Advances the cellular simulation by one tick (particles fall, flow, burn, etc.).
        methods.add_method_mut("step", |_, this, ()| {
            this.sim.borrow_mut().step();
            Ok(())
        });
        // -- stepN --
        /// Advances the cellular simulation by N ticks in a single call.
        /// @param | n | integer | Number of simulation ticks to run.
        methods.add_method_mut("stepN", |_, this, n: u32| {
            this.sim.borrow_mut().step_n(n);
            Ok(())
        });
        // -- toImageData --
        /// Renders the entire cellular grid to raw RGBA pixel data using the default material palette.
        /// @return | string | Raw RGBA pixel bytes (width * height * 4).
        methods.add_method("toImageData", |lua, this, ()| {
            let buf = this
                .sim
                .borrow()
                .try_to_image_data(cellular_default_palette, &procgen_limits())
                .map_err(lua_procgen_error)?;
            lua.create_string(&buf)
        });
        // -- toImageDataRegion --
        /// Renders a rectangular sub-region of the cellular grid to raw RGBA pixel data.
        /// @param | cx0 | integer | Top-left cell column.
        /// @param | cy0 | integer | Top-left cell row.
        /// @param | cw | integer | Width in cells.
        /// @param | ch | integer | Height in cells.
        /// @return | string | Raw RGBA pixel bytes (cw * ch * 4).
        methods.add_method(
            "toImageDataRegion",
            |lua, this, (cx0, cy0, cw, ch): (u32, u32, u32, u32)| {
                let buf = this
                    .sim
                    .borrow()
                    .try_to_image_data_region(
                        cx0,
                        cy0,
                        cw,
                        ch,
                        cellular_default_palette,
                        &procgen_limits(),
                    )
                    .map_err(lua_procgen_error)?;
                lua.create_string(&buf)
            },
        );
        // -- countCells --
        /// Counts how many cells of a given material type exist in the grid.
        /// @param | cellType | integer | Material type constant to count.
        /// @return | integer | Cell count.
        methods.add_method("countCells", |_, this, t: u8| {
            Ok(this.sim.borrow().count_cells(CellType::from_u8(t)))
        });
        // -- findCells --
        /// Returns positions of all cells matching a material type.
        /// @param | cellType | integer | Material type constant to find.
        /// @return | table | Array of {x, y} tables with cell coordinates.
        /// @field | x | number | X coordinate.
        /// @field | y | number | Y coordinate.
        methods.add_method("findCells", |lua, this, t: u8| {
            let positions = this.sim.borrow().find_cells(CellType::from_u8(t));
            let tbl = lua.create_table()?;
            for (i, (cx, cy)) in positions.iter().enumerate() {
                let row = lua.create_table()?;
                row.set("x", *cx)?;
                row.set("y", *cy)?;
                tbl.set(i + 1, row)?;
            }
            Ok(tbl)
        });
        // -- toBytes --
        /// Serializes the cellular grid to a compact binary format for saving.
        /// @return | string | Binary cellular data.
        methods.add_method("toBytes", |lua, this, ()| {
            lua.create_string(this.sim.borrow().to_bytes())
        });
        // -- loadFromBytes --
        /// Restores cellular grid state from binary data previously produced by toBytes.
        /// @param | data | string | Binary cellular data.
        /// @return | boolean | True if loading succeeded, false if data was invalid.
        methods.add_method_mut("loadFromBytes", |_, this, data: LuaString| {
            match CellularWorld::from_bytes_with_limits(data.as_bytes(), &procgen_limits()) {
                Ok(loaded) => {
                    *this.sim.borrow_mut() = loaded;
                    Ok(true)
                }
                Err(_) => Ok(false),
            }
        });
        // -- type --
        /// Returns the type name of this object ("LCellular").
        /// @return | string | "LCellular".
        methods.add_method("type", |_, _, ()| Ok("LCellular"));
        // -- typeOf --
        /// Checks if this object is of a given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the object matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LCellular" || name == "LObject")
        });
    }
}
/// Registers the `lurek.procgen` module and all its functions on the given Lua table.
pub fn register(lua: &Lua, luna: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newGridResult --
    /// Wrap a flat grid table as a typed procgen grid result.
    /// @param | width | integer | Grid width.
    /// @param | height | integer | Grid height.
    /// @param | cells | table | Flat integer grid.
    /// @param | opts | table? | Options: kind.
    /// @return | LProcgenGrid | Typed procgen grid.
    tbl.set(
        "newGridResult",
        lua.create_function(
            |_, (width, height, cells_tbl, opts): (u32, u32, LuaTable, Option<LuaTable>)| {
                let kind = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<String>>("kind").ok().flatten())
                    .unwrap_or_else(|| "grid".to_string());
                procgen_grid_from_table(width, height, cells_tbl, kind)
            },
        )?,
    )?;
    // -- newScalarGridResult --
    /// Wrap a flat numeric table as a typed procgen scalar grid result.
    /// @param | width | integer | Grid width.
    /// @param | height | integer | Grid height.
    /// @param | cells | table | Flat numeric grid.
    /// @param | opts | table? | Options: kind.
    /// @return | LProcgenScalarGrid | Typed procgen scalar grid.
    tbl.set(
        "newScalarGridResult",
        lua.create_function(
            |_, (width, height, cells_tbl, opts): (u32, u32, LuaTable, Option<LuaTable>)| {
                let kind = opts
                    .as_ref()
                    .and_then(|t| t.get::<_, Option<String>>("kind").ok().flatten())
                    .unwrap_or_else(|| "scalar".to_string());
                procgen_scalar_grid_from_table(width, height, cells_tbl, kind)
            },
        )?,
    )?;
    // -- placeConstrained --
    /// Selects a deterministic weighted subset satisfying neutral spatial and tag constraints.
    /// @param | candidates | table | Candidate records with x, y, optional id/level/region/tags/weight/uniquenessGroup.
    /// @param | rules | table | Rules with count, tags, minDistance, and perRegionCapacity.
    /// @param | opts | table? | Options with seed and bounded maxAttempts.
    /// @return | table, table | Placements and deterministic report.
    tbl.set(
        "placeConstrained",
        lua.create_function(
            |lua, (candidate_tables, rules_table, opts): (LuaTable, LuaTable, Option<LuaTable>)| {
                let api = "lurek.procgen.placeConstrained";
                let mut candidates = Vec::new();
                for value in candidate_tables.sequence_values::<LuaTable>() {
                    let candidate = value?;
                    candidates.push(PlacementCandidate {
                        id: procgen_optional_stringish(&candidate, "id", api)?,
                        x: candidate.get("x")?,
                        y: candidate.get("y")?,
                        level: procgen_optional_stringish(&candidate, "level", api)?,
                        region: procgen_optional_stringish(&candidate, "region", api)?,
                        tags: procgen_string_set(candidate.get("tags")?)?,
                        weight: candidate.get::<_, Option<f64>>("weight")?.unwrap_or(1.0),
                        uniqueness_group: procgen_optional_stringish(
                            &candidate,
                            "uniquenessGroup",
                            api,
                        )?,
                    });
                }
                let per_region_value = rules_table.get::<_, LuaValue>("perRegionCapacity")?;
                let mut default_region_capacity = None;
                let mut region_capacities = BTreeMap::new();
                match per_region_value {
                    LuaValue::Nil => {}
                    LuaValue::Integer(value) if value >= 0 => {
                        default_region_capacity = Some(value as usize);
                    }
                    LuaValue::Table(values) => {
                        for pair in values.pairs::<String, usize>() {
                            let (region, capacity) = pair?;
                            region_capacities.insert(region, capacity);
                        }
                    }
                    _ => {
                        return Err(LuaError::RuntimeError(format!(
                            "{api}: perRegionCapacity must be a non-negative integer or table"
                        )))
                    }
                }
                let rules = PlacementRules {
                    count: rules_table.get("count")?,
                    required_tags: procgen_string_set(rules_table.get("requiredTags")?)?,
                    forbidden_tags: procgen_string_set(rules_table.get("forbiddenTags")?)?,
                    min_distance: rules_table
                        .get::<_, Option<f64>>("minDistance")?
                        .unwrap_or(0.0),
                    default_region_capacity,
                    region_capacities,
                };
                let limits = procgen_limits();
                let seed = opts
                    .as_ref()
                    .map(|table| table.get::<_, Option<u64>>("seed"))
                    .transpose()?
                    .flatten()
                    .unwrap_or(0);
                let default_attempts = u32::try_from(rules.count.saturating_mul(16).max(1))
                    .unwrap_or(u32::MAX)
                    .min(limits.max_iterations);
                let max_attempts = opts
                    .as_ref()
                    .map(|table| table.get::<_, Option<u32>>("maxAttempts"))
                    .transpose()?
                    .flatten()
                    .unwrap_or(default_attempts);
                let (placements, report) =
                    place_constrained(&candidates, &rules, seed, max_attempts, &limits)
                        .map_err(|error| LuaError::RuntimeError(format!("{api}: {error}")))?;
                let placement_table = lua.create_table()?;
                for (index, placement) in placements.iter().enumerate() {
                    placement_table.set(index + 1, placement_to_lua(lua, placement)?)?;
                }
                let report_table = lua.create_table()?;
                report_table.set("seed", report.seed)?;
                report_table.set("requested", report.requested)?;
                report_table.set("placed", report.placed)?;
                report_table.set("attempts", report.attempts)?;
                report_table.set("complete", report.complete)?;
                let rejected = lua.create_table()?;
                for (reason, count) in &report.rejected {
                    rejected.set(reason.as_str(), *count)?;
                }
                report_table.set("rejected", rejected)?;
                Ok((placement_table, report_table))
            },
        )?,
    )?;
    // -- validateConnectivity --
    /// Reports deterministic connectivity, unreachable goals, isolated regions, and safe-radius failures.
    /// @param | grid | LProcgenGrid|table | Typed grid or {width,height,cells} table.
    /// @param | opts | table? | walkableValues, neighbors, starts, goals, and safePoints.
    /// @return | table | Bounded connectivity report.
    tbl.set(
        "validateConnectivity",
        lua.create_function(|lua, (grid, opts): (LuaValue, Option<LuaTable>)| {
            let api = "lurek.procgen.validateConnectivity";
            let (width, height, cells) = match grid {
                LuaValue::UserData(userdata) => {
                    let grid = userdata.borrow::<LuaProcgenGrid>().map_err(|_| {
                        LuaError::RuntimeError(format!("{api}: grid userdata must be LProcgenGrid"))
                    })?;
                    (grid.width, grid.height, grid.cells.clone())
                }
                LuaValue::Table(table) => {
                    let width: u32 = table.get("width")?;
                    let height: u32 = table.get("height")?;
                    let cells_table: LuaTable = table.get("cells")?;
                    let cells = cells_table
                        .sequence_values::<u32>()
                        .collect::<LuaResult<Vec<_>>>()?;
                    (width, height, cells)
                }
                value => {
                    return Err(LuaError::RuntimeError(format!(
                        "{api}: grid must be LProcgenGrid or table, got {}",
                        value.type_name()
                    )))
                }
            };
            let mut options = ConnectivityOptions::default();
            if let Some(opts) = opts {
                if let Some(values) = opts.get::<_, Option<LuaTable>>("walkableValues")? {
                    options.walkable_values = values
                        .sequence_values::<u32>()
                        .collect::<LuaResult<BTreeSet<_>>>()?;
                }
                options.neighbors = opts.get::<_, Option<u8>>("neighbors")?.unwrap_or(4);
                if let Some(values) = opts.get::<_, Option<LuaTable>>("starts")? {
                    for value in values.sequence_values::<LuaTable>() {
                        let point = value?;
                        options.starts.push(ConnectivityPoint {
                            x: point.get("x")?,
                            y: point.get("y")?,
                        });
                    }
                }
                if let Some(values) = opts.get::<_, Option<LuaTable>>("goals")? {
                    for value in values.sequence_values::<LuaTable>() {
                        let point = value?;
                        options.goals.push(ConnectivityPoint {
                            x: point.get("x")?,
                            y: point.get("y")?,
                        });
                    }
                }
                if let Some(values) = opts.get::<_, Option<LuaTable>>("safePoints")? {
                    for value in values.sequence_values::<LuaTable>() {
                        let point = value?;
                        options.safe_points.push(ConnectivitySafePoint {
                            x: point.get("x")?,
                            y: point.get("y")?,
                            radius: point.get("radius")?,
                        });
                    }
                }
            }
            let report = validate_connectivity(width, height, &cells, &options, &procgen_limits())
                .map_err(|error| LuaError::RuntimeError(format!("{api}: {error}")))?;
            let output = lua.create_table()?;
            let components = lua.create_table()?;
            for (index, component) in report.components.iter().enumerate() {
                let row = lua.create_table()?;
                row.set("id", component.id + 1)?;
                row.set("size", component.size)?;
                row.set("min", connectivity_point_to_lua(lua, component.min)?)?;
                row.set("max", connectivity_point_to_lua(lua, component.max)?)?;
                components.set(index + 1, row)?;
            }
            output.set("components", components)?;
            output.set(
                "primaryComponent",
                report.primary_component.map(|component| component + 1),
            )?;
            let unreachable = lua.create_table()?;
            for (index, goal) in report.unreachable_goals.iter().enumerate() {
                let row = connectivity_point_to_lua(lua, goal.point)?;
                row.set("index", goal.index)?;
                row.set("reason", goal.reason.as_str())?;
                unreachable.set(index + 1, row)?;
            }
            output.set("unreachableGoals", unreachable)?;
            let isolated_cells = lua.create_table()?;
            for (index, point) in report.isolated_cells.iter().enumerate() {
                isolated_cells.set(index + 1, connectivity_point_to_lua(lua, *point)?)?;
            }
            output.set("isolatedCells", isolated_cells)?;
            let isolated_regions = lua.create_table()?;
            for (index, component) in report.isolated_regions.iter().enumerate() {
                isolated_regions.set(index + 1, component + 1)?;
            }
            output.set("isolatedRegions", isolated_regions)?;
            let safe_violations = lua.create_table()?;
            for (index, violation) in report.safe_radius_violations.iter().enumerate() {
                let row = connectivity_point_to_lua(lua, violation.point)?;
                row.set("index", violation.index)?;
                row.set("blockedCells", violation.blocked_cells)?;
                safe_violations.set(index + 1, row)?;
            }
            output.set("safeRadiusViolations", safe_violations)?;
            let diagnostics = lua.create_table()?;
            for (index, diagnostic) in report.diagnostics.iter().enumerate() {
                diagnostics.set(index + 1, diagnostic.as_str())?;
            }
            output.set("diagnostics", diagnostics)?;
            Ok(output)
        })?,
    )?;
    // -- cellularAutomata --
    /// Generate a cave or organic map using cellular automata rules.
    /// @param | width | integer | Grid width in cells.
    /// @param | height | integer | Grid height in cells.
    /// @param | opts | table? | Options: fill (0.0â€“1.0 initial fill ratio), iterations, birth threshold, survive threshold, seed.
    /// @return | integer[] | Flat array of cell values (0=empty, 1=wall) with length widthĂ—height.
    tbl.set(
        "cellularAutomata",
        lua.create_function(|lua, (w, h, opts): (u32, u32, Option<LuaTable>)| {
            let cfg = opts
                .map(|t| CellularOpts::from_lua_table(&t))
                .transpose()?
                .unwrap_or_default();
            let data =
                try_cellular_automata(w, h, &cfg, &procgen_limits()).map_err(lua_procgen_error)?;
            let out = lua.create_table()?;
            for (i, v) in data.iter().enumerate() {
                out.set(i + 1, *v)?;
            }
            Ok(out)
        })?,
    )?;
    // -- cellularAutomataGrid --
    /// Generate a cave or organic map and return a typed grid result.
    /// @param | width | integer | Grid width in cells.
    /// @param | height | integer | Grid height in cells.
    /// @param | opts | table? | Cellular automata options.
    /// @return | LProcgenGrid | Typed cellular grid.
    tbl.set(
        "cellularAutomataGrid",
        lua.create_function(|_, (w, h, opts): (u32, u32, Option<LuaTable>)| {
            let cfg = opts
                .map(|t| CellularOpts::from_lua_table(&t))
                .transpose()?
                .unwrap_or_default();
            let cells =
                try_cellular_automata(w, h, &cfg, &procgen_limits()).map_err(lua_procgen_error)?;
            LuaProcgenGrid::new(
                "cellular_automata",
                w,
                h,
                cells.into_iter().map(u32::from).collect(),
            )
        })?,
    )?;
    // -- floodFill --
    /// Flood-fill a grid from a starting cell, marking all connected cells that pass a threshold test.
    /// @param | data | table | Flat array of u8 cell values (length = width*height).
    /// @param | width | number | Grid width.
    /// @param | height | number | Grid height.
    /// @param | startX | number | Start column (0-based).
    /// @param | startY | number | Start row (0-based).
    /// @param | threshold | number? | Value threshold (default 128).
    /// @param | above | boolean? | If true, fill cells >= threshold; if false (default), fill cells < threshold.
    /// @return | integer[] | Flat array of fill values (1=filled, 0=not filled) with length widthĂ—height.
    tbl.set(
        "floodFill",
        lua.create_function(
            |lua,
             (data_tbl, w, h, sx, sy, threshold, above): (
                LuaTable,
                u32,
                u32,
                u32,
                u32,
                Option<u8>,
                Option<bool>,
            )| {
                let mut data: Vec<u8> = Vec::with_capacity((w * h) as usize);
                for v in data_tbl.sequence_values::<u8>() {
                    data.push(v?);
                }
                let result = flood_fill(
                    &data,
                    w,
                    h,
                    sx,
                    sy,
                    threshold.unwrap_or(128),
                    above.unwrap_or(false),
                );
                let out = lua.create_table()?;
                for (i, v) in result.iter().enumerate() {
                    out.set(i + 1, *v)?;
                }
                Ok(out)
            },
        )?,
    )?;
    // -- perlinNoise --
    /// Sample periodic 2D Perlin noise at a given coordinate.
    /// @param | x | number | X coordinate to sample.
    /// @param | y | number | Y coordinate to sample.
    /// @param | periodX | number | Horizontal period for tiling.
    /// @param | periodY | number | Vertical period for tiling.
    /// @return | number | Noise value in the range [-1, 1].
    tbl.set(
        "perlinNoise",
        lua.create_function(|_, (x, y, px, py): (f64, f64, f64, f64)| {
            Ok(perlin_noise_periodic(x, y, px, py))
        })?,
    )?;
    // -- poissonDisk --
    /// Generate evenly-spaced random points using Poisson disk sampling. Useful for placing trees, NPCs, or loot without clustering.
    /// @param | width | number | Area width.
    /// @param | height | number | Area height.
    /// @param | minDist | number | Minimum distance between any two points.
    /// @param | maxAttempts | integer? | Rejection attempts per active point (default 30). Higher = denser fill.
    /// @param | seed | integer? | RNG seed (default 0).
    /// @return | table | Array of {x, y} tables representing generated points.
    /// @field | x | number | X.
    /// @field | y | number | Y.
    tbl.set("poissonDisk", lua.create_function(
            |lua, (w, h, min_dist, max_attempts, seed): (f32, f32, f32, Option<u32>, Option<u64>)| {
                let points = try_poisson_disk(
                    w,
                    h,
                    min_dist,
                    max_attempts.unwrap_or(30),
                    seed.unwrap_or(0),
                    &procgen_limits(),
                )
                .map_err(lua_procgen_error)?;
                let out = lua.create_table()?;
                for (i, (px, py)) in points.iter().enumerate() {
                    let pt = lua.create_table()?;
                    /// The 'x' field value exposed to Lua scripts.
                    pt.set("x", *px)?;
                    /// The 'y' field value exposed to Lua scripts.
                    pt.set("y", *py)?;
                    out.set(i + 1, pt)?;
                }
                Ok(out)
            },
        )?,
    )?;
    // -- voronoi --
    /// Compute a Voronoi diagram from a set of seed points. Returns region ownership, distance-to-nearest, and distance-to-second-nearest for each cell.
    /// @param | width | integer | Grid width.
    /// @param | height | integer | Grid height.
    /// @param | points | table | Array of {x, y} seed points.
    /// @param | opts | table? | Options: warp_scale, warp_strength, seed for domain warping.
    /// @return | integer[] | 1-based region indices (length = width*height).
    /// @return | number[] | Flat array of distances to nearest seed.
    /// @return | number[] | Flat array of distances to second-nearest seed.
    tbl.set(
        "voronoi",
        lua.create_function(
            |lua, (w, h, pts_tbl, opts_tbl): (u32, u32, LuaTable, Option<LuaTable>)| {
                let mut points: Vec<(f32, f32)> = Vec::new();
                for v in pts_tbl.sequence_values::<LuaTable>() {
                    let pt = v?;
                    let x: f32 = pt.get("x")?;
                    let y: f32 = pt.get("y")?;
                    points.push((x, y));
                }
                let vopts = opts_tbl
                    .map(|t| VoronoiOpts::from_lua_table(&t))
                    .transpose()?
                    .unwrap_or_default();
                let (regions, distances, distances2) =
                    try_voronoi_diagram(w, h, &points, &vopts, &procgen_limits())
                        .map_err(lua_procgen_error)?;
                let r_tbl = lua.create_table()?;
                let d_tbl = lua.create_table()?;
                let d2_tbl = lua.create_table()?;
                for (i, ((r, d), d2)) in regions
                    .iter()
                    .zip(distances.iter())
                    .zip(distances2.iter())
                    .enumerate()
                {
                    r_tbl.set(i + 1, *r + 1)?;
                    d_tbl.set(i + 1, *d)?;
                    d2_tbl.set(i + 1, *d2)?;
                }
                Ok((r_tbl, d_tbl, d2_tbl))
            },
        )?,
    )?;
    // -- bspDungeon --
    /// Generate a dungeon layout using Binary Space Partitioning. Produces non-overlapping rooms connected by corridors.
    /// @param | opts | table? | Options: width, height, min_size (minimum leaf size), max_depth (BSP tree depth), seed, padding.
    /// @return | table | Table with .rooms (array of {x,y,w,h}) and .corridors (array of {x1,y1,x2,y2}).
    /// @field | rooms | table | Array of room tables with x, y, w, h fields.
    /// @field | corridors | table | Array of corridor tables with x1, y1, x2, y2 fields.
    tbl.set(
        "bspDungeon",
        lua.create_function(|lua, opts: Option<LuaTable>| {
            let mut cfg = BspOpts::default();
            if let Some(t) = opts {
                if let Ok(v) = t.get::<_, u32>("width") {
                    cfg.width = v;
                }
                if let Ok(v) = t.get::<_, u32>("height") {
                    cfg.height = v;
                }
                if let Ok(v) = t.get::<_, u32>("min_size") {
                    cfg.min_size = v;
                }
                if let Ok(v) = t.get::<_, u32>("max_depth") {
                    cfg.max_depth = v;
                }
                if let Ok(v) = t.get::<_, u64>("seed") {
                    cfg.seed = v;
                }
                if let Ok(v) = t.get::<_, u32>("padding") {
                    cfg.padding = v;
                }
            }
            let d = bsp_dungeon(&cfg);
            let rooms_tbl = lua.create_table()?;
            for (i, r) in d.rooms.iter().enumerate() {
                let rt = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                rt.set("x", r.x)?;
                /// The 'y' field value exposed to Lua scripts.
                rt.set("y", r.y)?;
                /// The 'w' field value exposed to Lua scripts.
                rt.set("w", r.w)?;
                /// The 'h' field value exposed to Lua scripts.
                rt.set("h", r.h)?;
                rooms_tbl.set(i + 1, rt)?;
            }
            let corr_tbl = lua.create_table()?;
            for (i, &(x1, y1, x2, y2)) in d.corridors.iter().enumerate() {
                let ct = lua.create_table()?;
                /// The 'x1' field value exposed to Lua scripts.
                ct.set("x1", x1)?;
                /// The 'y1' field value exposed to Lua scripts.
                ct.set("y1", y1)?;
                /// The 'x2' field value exposed to Lua scripts.
                ct.set("x2", x2)?;
                /// The 'y2' field value exposed to Lua scripts.
                ct.set("y2", y2)?;
                corr_tbl.set(i + 1, ct)?;
            }
            let out = lua.create_table()?;
            /// Performs the 'rooms' operation.
            out.set("rooms", rooms_tbl)?;
            /// Performs the 'corridors' operation.
            out.set("corridors", corr_tbl)?;
            Ok(out)
        })?,
    )?;
    // -- bspDungeonWithPrefabs --
    /// Generate a BSP dungeon and stamp named prefab rooms into suitable leaves. Returns dungeon layout plus prefab placement info.
    /// @param | opts | table? | BSP options: width, height, min_size, max_depth, seed, padding.
    /// @param | prefabs | table | Array of prefab definitions: {name, width, height}.
    /// @return | table | Dungeon table with .rooms and .corridors.
    /// @return | table | Array of placed prefabs: {name, x, y, width, height}.
    /// @field | name | string | Name.
    /// @field | x | number | X.
    /// @field | y | number | Y.
    /// @field | width | number | Width.
    /// @field | height | number | Height.
    tbl.set(
        "bspDungeonWithPrefabs",
        lua.create_function(|lua, (opts, prefabs_tbl): (Option<LuaTable>, LuaTable)| {
            let mut cfg = BspOpts::default();
            if let Some(t) = opts {
                if let Ok(v) = t.get::<_, u32>("width") {
                    cfg.width = v;
                }
                if let Ok(v) = t.get::<_, u32>("height") {
                    cfg.height = v;
                }
                if let Ok(v) = t.get::<_, u32>("min_size") {
                    cfg.min_size = v;
                }
                if let Ok(v) = t.get::<_, u32>("max_depth") {
                    cfg.max_depth = v;
                }
                if let Ok(v) = t.get::<_, u64>("seed") {
                    cfg.seed = v;
                }
                if let Ok(v) = t.get::<_, u32>("padding") {
                    cfg.padding = v;
                }
            }
            let mut prefabs = Vec::new();
            for v in prefabs_tbl.sequence_values::<LuaTable>() {
                let p = v?;
                let name: String = p.get("name").unwrap_or_else(|_| String::from("prefab"));
                let width: u32 = p.get("width").unwrap_or(1);
                let height: u32 = p.get("height").unwrap_or(1);
                prefabs.push(BspPrefabStamp {
                    name,
                    width,
                    height,
                });
            }
            let (d, placements) = bsp_dungeon_with_prefabs(&cfg, &prefabs);
            let rooms_tbl = lua.create_table()?;
            for (i, r) in d.rooms.iter().enumerate() {
                let rt = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                rt.set("x", r.x)?;
                /// The 'y' field value exposed to Lua scripts.
                rt.set("y", r.y)?;
                /// The 'w' field value exposed to Lua scripts.
                rt.set("w", r.w)?;
                /// The 'h' field value exposed to Lua scripts.
                rt.set("h", r.h)?;
                rooms_tbl.set(i + 1, rt)?;
            }
            let corr_tbl = lua.create_table()?;
            for (i, &(x1, y1, x2, y2)) in d.corridors.iter().enumerate() {
                let ct = lua.create_table()?;
                /// The 'x1' field value exposed to Lua scripts.
                ct.set("x1", x1)?;
                /// The 'y1' field value exposed to Lua scripts.
                ct.set("y1", y1)?;
                /// The 'x2' field value exposed to Lua scripts.
                ct.set("x2", x2)?;
                /// The 'y2' field value exposed to Lua scripts.
                ct.set("y2", y2)?;
                corr_tbl.set(i + 1, ct)?;
            }
            let out = lua.create_table()?;
            /// Performs the 'rooms' operation.
            out.set("rooms", rooms_tbl)?;
            /// Performs the 'corridors' operation.
            out.set("corridors", corr_tbl)?;
            let p_tbl = lua.create_table()?;
            for (i, p) in placements.iter().enumerate() {
                let t = lua.create_table()?;
                /// Performs the 'name' operation.
                t.set("name", p.name.as_str())?;
                /// The 'x' field value exposed to Lua scripts.
                t.set("x", p.x)?;
                /// The 'y' field value exposed to Lua scripts.
                t.set("y", p.y)?;
                /// Performs the 'width' operation.
                t.set("width", p.width)?;
                /// Performs the 'height' operation.
                t.set("height", p.height)?;
                p_tbl.set(i + 1, t)?;
            }
            Ok((out, p_tbl))
        })?,
    )?;
    // -- roomsDungeon --
    /// Generate a dungeon by placing random non-overlapping rooms and connecting them with corridors. Also returns a full tile grid.
    /// @param | opts | table? | Options: width, height, max_rooms, min_room_size, max_room_size, seed.
    /// @return | table | Table with .rooms ({x,y,w,h}[]), .corridors ({x1,y1,x2,y2}[]), .grid (flat u8[]), .width, .height.
    /// @field | rooms | table | Array of room tables with x, y, w, h fields.
    /// @field | corridors | table | Array of corridor tables with x1, y1, x2, y2 fields.
    /// @field | grid | integer[] | Flat grid array of tile values.
    /// @field | width | integer | Grid width in tiles.
    /// @field | height | integer | Grid height in tiles.
    tbl.set(
        "roomsDungeon",
        lua.create_function(|lua, opts: Option<LuaTable>| {
            let mut cfg = RoomsOpts::default();
            if let Some(t) = opts {
                if let Ok(v) = t.get::<_, u32>("width") {
                    cfg.width = v;
                }
                if let Ok(v) = t.get::<_, u32>("height") {
                    cfg.height = v;
                }
                if let Ok(v) = t.get::<_, u32>("max_rooms") {
                    cfg.max_rooms = v;
                }
                if let Ok(v) = t.get::<_, u32>("min_room_size") {
                    cfg.min_room_size = v;
                }
                if let Ok(v) = t.get::<_, u32>("max_room_size") {
                    cfg.max_room_size = v;
                }
                if let Ok(v) = t.get::<_, u64>("seed") {
                    cfg.seed = v;
                }
            }
            let d = try_rooms_dungeon(&cfg, &procgen_limits()).map_err(lua_procgen_error)?;
            let rooms_tbl = lua.create_table()?;
            for (i, r) in d.rooms.iter().enumerate() {
                let rt = lua.create_table()?;
                /// The 'x' field value exposed to Lua scripts.
                rt.set("x", r.x)?;
                /// The 'y' field value exposed to Lua scripts.
                rt.set("y", r.y)?;
                /// The 'w' field value exposed to Lua scripts.
                rt.set("w", r.w)?;
                /// The 'h' field value exposed to Lua scripts.
                rt.set("h", r.h)?;
                rooms_tbl.set(i + 1, rt)?;
            }
            let corr_tbl = lua.create_table()?;
            for (i, &(x1, y1, x2, y2)) in d.corridors.iter().enumerate() {
                let ct = lua.create_table()?;
                /// The 'x1' field value exposed to Lua scripts.
                ct.set("x1", x1)?;
                /// The 'y1' field value exposed to Lua scripts.
                ct.set("y1", y1)?;
                /// The 'x2' field value exposed to Lua scripts.
                ct.set("x2", x2)?;
                /// The 'y2' field value exposed to Lua scripts.
                ct.set("y2", y2)?;
                corr_tbl.set(i + 1, ct)?;
            }
            let grid_tbl = lua.create_table()?;
            for (i, &v) in d.grid.iter().enumerate() {
                grid_tbl.set(i + 1, v)?;
            }
            let out = lua.create_table()?;
            /// Performs the 'rooms' operation.
            out.set("rooms", rooms_tbl)?;
            /// Performs the 'corridors' operation.
            out.set("corridors", corr_tbl)?;
            /// Performs the 'grid' operation.
            out.set("grid", grid_tbl)?;
            /// Performs the 'width' operation.
            out.set("width", cfg.width)?;
            /// Performs the 'height' operation.
            out.set("height", cfg.height)?;
            Ok(out)
        })?,
    )?;
    // -- roomsDungeonGrid --
    /// Generate a rooms dungeon and return only its tile grid as a typed procgen result.
    /// @param | opts | table? | Room generation options.
    /// @return | LProcgenGrid | Typed rooms-dungeon grid.
    tbl.set(
        "roomsDungeonGrid",
        lua.create_function(|_, opts: Option<LuaTable>| {
            let mut cfg = RoomsOpts::default();
            if let Some(t) = opts {
                if let Ok(v) = t.get::<_, u32>("width") {
                    cfg.width = v;
                }
                if let Ok(v) = t.get::<_, u32>("height") {
                    cfg.height = v;
                }
                if let Ok(v) = t.get::<_, u32>("max_rooms") {
                    cfg.max_rooms = v;
                }
                if let Ok(v) = t.get::<_, u32>("min_room_size") {
                    cfg.min_room_size = v;
                }
                if let Ok(v) = t.get::<_, u32>("max_room_size") {
                    cfg.max_room_size = v;
                }
                if let Ok(v) = t.get::<_, u64>("seed") {
                    cfg.seed = v;
                }
            }
            let dungeon = try_rooms_dungeon(&cfg, &procgen_limits()).map_err(lua_procgen_error)?;
            LuaProcgenGrid::new(
                "rooms_dungeon",
                cfg.width,
                cfg.height,
                dungeon.grid.into_iter().map(u32::from).collect(),
            )
        })?,
    )?;
    // -- roomsDungeonWithPrefabs --
    /// Generate a rooms-based dungeon and place named prefabs into qualifying rooms. Prefabs can have custom shape masks.
    /// @param | opts | table? | Room generation options: width, height, max_rooms, min_room_size, max_room_size, seed.
    /// @param | prefabs | table | Array of prefab definitions: {name, width, height, mask (optional flat u8[])}.
    /// @param | stampValue | number? | Tile value written for prefab cells in the grid (default 3).
    /// @return | table | Dungeon table with .rooms, .corridors, .grid, .width, .height.
    /// @return | table | Array of placed prefabs: {name, x, y, width, height}.
    /// @field | name | string | Name.
    /// @field | x | number | X.
    /// @field | y | number | Y.
    /// @field | width | number | Width.
    /// @field | height | number | Height.
    tbl.set(
        "roomsDungeonWithPrefabs",
        lua.create_function(
            |lua, (opts, prefabs_tbl, stamp_value): (Option<LuaTable>, LuaTable, Option<u8>)| {
                let mut cfg = RoomsOpts::default();
                if let Some(t) = opts {
                    if let Ok(v) = t.get::<_, u32>("width") {
                        cfg.width = v;
                    }
                    if let Ok(v) = t.get::<_, u32>("height") {
                        cfg.height = v;
                    }
                    if let Ok(v) = t.get::<_, u32>("max_rooms") {
                        cfg.max_rooms = v;
                    }
                    if let Ok(v) = t.get::<_, u32>("min_room_size") {
                        cfg.min_room_size = v;
                    }
                    if let Ok(v) = t.get::<_, u32>("max_room_size") {
                        cfg.max_room_size = v;
                    }
                    if let Ok(v) = t.get::<_, u64>("seed") {
                        cfg.seed = v;
                    }
                }
                let mut prefabs = Vec::new();
                for v in prefabs_tbl.sequence_values::<LuaTable>() {
                    let p = v?;
                    let name: String = p.get("name").unwrap_or_else(|_| String::from("prefab"));
                    let width: u32 = p.get("width").unwrap_or(1);
                    let height: u32 = p.get("height").unwrap_or(1);
                    let mut mask = Vec::new();
                    if let Ok(mtbl) = p.get::<_, LuaTable>("mask") {
                        for mv in mtbl.sequence_values::<u8>() {
                            mask.push(mv?);
                        }
                    }
                    prefabs.push(RoomPrefabStamp {
                        name,
                        width,
                        height,
                        mask,
                    });
                }
                let (d, placements) =
                    rooms_dungeon_with_prefabs(&cfg, &prefabs, stamp_value.unwrap_or(3));
                let rooms_tbl = lua.create_table()?;
                for (i, r) in d.rooms.iter().enumerate() {
                    let rt = lua.create_table()?;
                    /// The 'x' field value exposed to Lua scripts.
                    rt.set("x", r.x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    rt.set("y", r.y)?;
                    /// The 'w' field value exposed to Lua scripts.
                    rt.set("w", r.w)?;
                    /// The 'h' field value exposed to Lua scripts.
                    rt.set("h", r.h)?;
                    rooms_tbl.set(i + 1, rt)?;
                }
                let corr_tbl = lua.create_table()?;
                for (i, &(x1, y1, x2, y2)) in d.corridors.iter().enumerate() {
                    let ct = lua.create_table()?;
                    /// The 'x1' field value exposed to Lua scripts.
                    ct.set("x1", x1)?;
                    /// The 'y1' field value exposed to Lua scripts.
                    ct.set("y1", y1)?;
                    /// The 'x2' field value exposed to Lua scripts.
                    ct.set("x2", x2)?;
                    /// The 'y2' field value exposed to Lua scripts.
                    ct.set("y2", y2)?;
                    corr_tbl.set(i + 1, ct)?;
                }
                let grid_tbl = lua.create_table()?;
                for (i, &v) in d.grid.iter().enumerate() {
                    grid_tbl.set(i + 1, v)?;
                }
                let out = lua.create_table()?;
                /// Performs the 'rooms' operation.
                out.set("rooms", rooms_tbl)?;
                /// Performs the 'corridors' operation.
                out.set("corridors", corr_tbl)?;
                /// Performs the 'grid' operation.
                out.set("grid", grid_tbl)?;
                /// Performs the 'width' operation.
                out.set("width", cfg.width)?;
                /// Performs the 'height' operation.
                out.set("height", cfg.height)?;
                let p_tbl = lua.create_table()?;
                for (i, p) in placements.iter().enumerate() {
                    let t = lua.create_table()?;
                    /// Performs the 'name' operation.
                    t.set("name", p.name.as_str())?;
                    /// The 'x' field value exposed to Lua scripts.
                    t.set("x", p.x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    t.set("y", p.y)?;
                    /// Performs the 'width' operation.
                    t.set("width", p.width)?;
                    /// Performs the 'height' operation.
                    t.set("height", p.height)?;
                    p_tbl.set(i + 1, t)?;
                }
                Ok((out, p_tbl))
            },
        )?,
    )?;
    // -- roomsDungeonWithPrefabsGrid --
    /// Generate a rooms dungeon with prefabs and return only its tile grid as a typed procgen result.
    /// @param | opts | table? | Room generation options.
    /// @param | prefabs | table | Prefab definitions.
    /// @param | stampValue | number? | Tile value written for prefab cells.
    /// @return | LProcgenGrid | Typed rooms-dungeon grid.
    tbl.set(
        "roomsDungeonWithPrefabsGrid",
        lua.create_function(
            |_, (opts, prefabs_tbl, stamp_value): (Option<LuaTable>, LuaTable, Option<u8>)| {
                let mut cfg = RoomsOpts::default();
                if let Some(t) = opts {
                    if let Ok(v) = t.get::<_, u32>("width") {
                        cfg.width = v;
                    }
                    if let Ok(v) = t.get::<_, u32>("height") {
                        cfg.height = v;
                    }
                    if let Ok(v) = t.get::<_, u32>("max_rooms") {
                        cfg.max_rooms = v;
                    }
                    if let Ok(v) = t.get::<_, u32>("min_room_size") {
                        cfg.min_room_size = v;
                    }
                    if let Ok(v) = t.get::<_, u32>("max_room_size") {
                        cfg.max_room_size = v;
                    }
                    if let Ok(v) = t.get::<_, u64>("seed") {
                        cfg.seed = v;
                    }
                }
                let mut prefabs = Vec::new();
                for value in prefabs_tbl.sequence_values::<LuaTable>() {
                    let prefab = value?;
                    let name: String = prefab
                        .get("name")
                        .unwrap_or_else(|_| String::from("prefab"));
                    let width: u32 = prefab.get("width").unwrap_or(1);
                    let height: u32 = prefab.get("height").unwrap_or(1);
                    let mut mask = Vec::new();
                    if let Ok(mask_tbl) = prefab.get::<_, LuaTable>("mask") {
                        for mask_value in mask_tbl.sequence_values::<u8>() {
                            mask.push(mask_value?);
                        }
                    }
                    prefabs.push(RoomPrefabStamp {
                        name,
                        width,
                        height,
                        mask,
                    });
                }
                let (dungeon, _) =
                    rooms_dungeon_with_prefabs(&cfg, &prefabs, stamp_value.unwrap_or(3));
                LuaProcgenGrid::new(
                    "rooms_dungeon_prefabs",
                    cfg.width,
                    cfg.height,
                    dungeon.grid.into_iter().map(u32::from).collect(),
                )
            },
        )?,
    )?;
    // -- heightmap --
    /// Generate a fractal heightmap using multi-octave noise with optional hydraulic erosion.
    /// @param | opts | table? | Options: width, height, scale, octaves, lacunarity, persistence, seed, erosion_passes.
    /// @return | table | Table with .cells (flat f32 array 0.0â€“1.0), .width, .height.
    /// @field | cells | number[] | Heightmap values.
    /// @field | width | integer | Width.
    /// @field | height | integer | Height.
    tbl.set(
        "heightmap",
        lua.create_function(|lua, opts: Option<LuaTable>| {
            let mut cfg = HeightmapOpts::default();
            if let Some(t) = opts {
                if let Ok(v) = t.get::<_, u32>("width") {
                    cfg.width = v;
                }
                if let Ok(v) = t.get::<_, u32>("height") {
                    cfg.height = v;
                }
                if let Ok(v) = t.get::<_, f64>("scale") {
                    cfg.scale = v;
                }
                if let Ok(v) = t.get::<_, u32>("octaves") {
                    cfg.octaves = v;
                }
                if let Ok(v) = t.get::<_, f64>("lacunarity") {
                    cfg.lacunarity = v;
                }
                if let Ok(v) = t.get::<_, f64>("persistence") {
                    cfg.persistence = v;
                }
                if let Ok(v) = t.get::<_, u64>("seed") {
                    cfg.seed = v;
                }
                if let Ok(v) = t.get::<_, u32>("erosion_passes") {
                    cfg.erosion_passes = v;
                }
                if let Ok(mode) = t.get::<_, String>("erosion_mode") {
                    cfg.erosion_mode = if mode.eq_ignore_ascii_case("buffered") {
                        ErosionMode::Buffered
                    } else {
                        ErosionMode::InPlace
                    };
                }
            }
            let hm = Heightmap::try_generate(&cfg, &procgen_limits()).map_err(lua_procgen_error)?;
            let out = lua.create_table()?;
            for (i, &v) in hm.cells.iter().enumerate() {
                out.set(i + 1, v)?;
            }
            let res = lua.create_table()?;
            /// Performs the 'cells' operation.
            res.set("cells", out)?;
            /// Performs the 'width' operation.
            res.set("width", hm.width)?;
            /// Performs the 'height' operation.
            res.set("height", hm.height)?;
            Ok(res)
        })?,
    )?;
    // -- heightmapGrid --
    /// Generate a fractal heightmap and return a typed scalar grid result.
    /// @param | opts | table? | Heightmap options.
    /// @return | LProcgenScalarGrid | Typed heightmap scalar grid.
    tbl.set(
        "heightmapGrid",
        lua.create_function(|_, opts: Option<LuaTable>| {
            let mut cfg = HeightmapOpts::default();
            if let Some(t) = opts {
                if let Ok(v) = t.get::<_, u32>("width") {
                    cfg.width = v;
                }
                if let Ok(v) = t.get::<_, u32>("height") {
                    cfg.height = v;
                }
                if let Ok(v) = t.get::<_, f64>("scale") {
                    cfg.scale = v;
                }
                if let Ok(v) = t.get::<_, u32>("octaves") {
                    cfg.octaves = v;
                }
                if let Ok(v) = t.get::<_, f64>("lacunarity") {
                    cfg.lacunarity = v;
                }
                if let Ok(v) = t.get::<_, f64>("persistence") {
                    cfg.persistence = v;
                }
                if let Ok(v) = t.get::<_, u64>("seed") {
                    cfg.seed = v;
                }
                if let Ok(v) = t.get::<_, u32>("erosion_passes") {
                    cfg.erosion_passes = v;
                }
                if let Ok(mode) = t.get::<_, String>("erosion_mode") {
                    cfg.erosion_mode = if mode.eq_ignore_ascii_case("buffered") {
                        ErosionMode::Buffered
                    } else {
                        ErosionMode::InPlace
                    };
                }
            }
            let hm = Heightmap::try_generate(&cfg, &procgen_limits()).map_err(lua_procgen_error)?;
            LuaProcgenScalarGrid::new("heightmap", hm.width, hm.height, hm.cells)
        })?,
    )?;
    // -- heightmapFromCellular --
    /// Convert a cellular automata grid into a heightmap by distance-transforming the floor cells.
    /// @param | width | integer | Grid width.
    /// @param | height | integer | Grid height.
    /// @param | cells | table | Flat u8 array from cellularAutomata.
    /// @param | floorValue | number? | Cell value treated as open floor (default 0).
    /// @return | table | Table with .cells (flat f32 array), .width, .height.
    /// @field | cells | number[] | Distance-transformed heightmap values.
    /// @field | width | integer | Width.
    /// @field | height | integer | Height.
    tbl.set(
        "heightmapFromCellular",
        lua.create_function(
            |lua, (width, height, cells_tbl, floor_value): (u32, u32, LuaTable, Option<u8>)| {
                let mut cells = Vec::with_capacity((width * height) as usize);
                for v in cells_tbl.sequence_values::<u8>() {
                    cells.push(v?);
                }
                let hm = Heightmap::try_from_cellular(
                    width,
                    height,
                    &cells,
                    floor_value.unwrap_or(0),
                    &procgen_limits(),
                )
                .map_err(lua_procgen_error)?;
                let out_cells = lua.create_table()?;
                for (i, &v) in hm.cells.iter().enumerate() {
                    out_cells.set(i + 1, v)?;
                }
                let res = lua.create_table()?;
                /// Performs the 'cells' operation.
                res.set("cells", out_cells)?;
                /// Performs the 'width' operation.
                res.set("width", hm.width)?;
                /// Performs the 'height' operation.
                res.set("height", hm.height)?;
                Ok(res)
            },
        )?,
    )?;
    // -- heightmapFromCellularGrid --
    /// Convert a cellular automata grid into a typed heightmap scalar grid.
    /// @param | width | integer | Grid width.
    /// @param | height | integer | Grid height.
    /// @param | cells | table | Flat u8 array from cellularAutomata.
    /// @param | floorValue | number? | Cell value treated as open floor.
    /// @return | LProcgenScalarGrid | Typed heightmap scalar grid.
    tbl.set(
        "heightmapFromCellularGrid",
        lua.create_function(
            |_, (width, height, cells_tbl, floor_value): (u32, u32, LuaTable, Option<u8>)| {
                let mut cells = Vec::with_capacity((width * height) as usize);
                for v in cells_tbl.sequence_values::<u8>() {
                    cells.push(v?);
                }
                let hm = Heightmap::try_from_cellular(
                    width,
                    height,
                    &cells,
                    floor_value.unwrap_or(0),
                    &procgen_limits(),
                )
                .map_err(lua_procgen_error)?;
                LuaProcgenScalarGrid::new("heightmap_from_cellular", hm.width, hm.height, hm.cells)
            },
        )?,
    )?;
    // -- wfcGenerate --
    /// Run Wave Function Collapse to generate a grid of tile IDs satisfying adjacency constraints.
    /// @param | opts | table | Options: width, height, seed, max_attempts, tiles (array of {id, weight}), adjacencies (map of tile_id -> allowed neighbor IDs[]).
    /// @return | table | Table with .cells (flat array of tile IDs, 0 if unsolved), .width, .height.
    /// @field | cells | integer[] | Tile ID per cell.
    /// @field | width | integer | Width.
    /// @field | height | integer | Height.
    tbl.set(
        "wfcGenerate",
        lua.create_function(|lua, opts: LuaTable| {
            let width: u32 = opts.get("width").unwrap_or(16);
            let height: u32 = opts.get("height").unwrap_or(16);
            let seed: u64 = opts.get("seed").unwrap_or(0);
            let max_attempts: u32 = opts.get("max_attempts").unwrap_or(10);
            let mut tiles: Vec<WfcTile> = Vec::new();
            if let Ok(tt) = opts.get::<_, LuaTable>("tiles") {
                for v in tt.sequence_values::<LuaTable>() {
                    let t = v?;
                    let id: u32 = t.get("id").unwrap_or(0);
                    let weight: f32 = t.get("weight").unwrap_or(1.0);
                    tiles.push(WfcTile { id, weight });
                }
            }
            let mut adj_map = std::collections::HashMap::new();
            if let Ok(at) = opts.get::<_, LuaTable>("adjacencies") {
                for pair in at.pairs::<LuaValue, LuaTable>() {
                    let (k, v) = pair?;
                    let tile_id: u32 = match k {
                        LuaValue::Integer(n) => n as u32,
                        _ => continue,
                    };
                    let mut neighbours: Vec<u32> = Vec::new();
                    for nv in v.sequence_values::<u32>() {
                        neighbours.push(nv?);
                    }
                    adj_map.insert(tile_id, neighbours);
                }
            }
            let wfc_opts = WfcOpts {
                width,
                height,
                tiles,
                rules: WfcRules {
                    adjacencies: adj_map,
                },
                seed,
                max_attempts,
            };
            let grid = try_wfc_generate(&wfc_opts, &procgen_limits()).map_err(lua_procgen_error)?;
            let out = lua.create_table()?;
            for (i, c) in grid.cells.iter().enumerate() {
                out.set(i + 1, c.unwrap_or(0))?;
            }
            let res = lua.create_table()?;
            /// Performs the 'cells' operation.
            res.set("cells", out)?;
            /// Performs the 'width' operation.
            res.set("width", grid.width)?;
            /// Performs the 'height' operation.
            res.set("height", grid.height)?;
            Ok(res)
        })?,
    )?;
    // -- wfcGenerateGrid --
    /// Run WFC and return a typed procgen grid result.
    /// @param | opts | table | WFC options.
    /// @return | LProcgenGrid | Typed WFC tile-id grid.
    tbl.set(
        "wfcGenerateGrid",
        lua.create_function(|_, opts: LuaTable| {
            let width: u32 = opts.get("width").unwrap_or(16);
            let height: u32 = opts.get("height").unwrap_or(16);
            let seed: u64 = opts.get("seed").unwrap_or(0);
            let max_attempts: u32 = opts.get("max_attempts").unwrap_or(10);
            let mut tiles: Vec<WfcTile> = Vec::new();
            if let Ok(tt) = opts.get::<_, LuaTable>("tiles") {
                for v in tt.sequence_values::<LuaTable>() {
                    let t = v?;
                    let id: u32 = t.get("id").unwrap_or(0);
                    let weight: f32 = t.get("weight").unwrap_or(1.0);
                    tiles.push(WfcTile { id, weight });
                }
            }
            let mut adj_map = std::collections::HashMap::new();
            if let Ok(at) = opts.get::<_, LuaTable>("adjacencies") {
                for pair in at.pairs::<LuaValue, LuaTable>() {
                    let (k, v) = pair?;
                    let tile_id: u32 = match k {
                        LuaValue::Integer(n) => n as u32,
                        _ => continue,
                    };
                    let mut neighbours: Vec<u32> = Vec::new();
                    for nv in v.sequence_values::<u32>() {
                        neighbours.push(nv?);
                    }
                    adj_map.insert(tile_id, neighbours);
                }
            }
            let wfc_opts = WfcOpts {
                width,
                height,
                tiles,
                rules: WfcRules {
                    adjacencies: adj_map,
                },
                seed,
                max_attempts,
            };
            let grid = try_wfc_generate(&wfc_opts, &procgen_limits()).map_err(lua_procgen_error)?;
            LuaProcgenGrid::new(
                "wfc",
                grid.width,
                grid.height,
                grid.cells
                    .into_iter()
                    .map(|cell| cell.unwrap_or(0))
                    .collect(),
            )
        })?,
    )?;
    // -- lsystem --
    /// Expand an L-system grammar and return the resulting string. Useful for generating branching structures like trees, rivers, or cave networks.
    /// @param | opts | table | Options: axiom (starting string), iterations (expansion count), rules (table mapping single-char keys to replacement strings).
    /// @return | string | The fully expanded L-system string.
    tbl.set(
        "lsystem",
        lua.create_function(|_, opts: LuaTable| {
            let axiom: String = opts.get("axiom").unwrap_or_else(|_| String::from("F"));
            let iterations: u32 = opts.get("iterations").unwrap_or(3);
            let rules: Vec<(char, &'static str)> = Vec::new();
            let rule_strings: Vec<(char, String)> = opts
                .get::<_, Option<LuaTable>>("rules")
                .unwrap_or(None)
                .map(|rt| {
                    let mut v = Vec::new();
                    for (k, val) in rt.pairs::<LuaValue, String>().flatten() {
                        if let LuaValue::String(s) = k {
                            if let Some(c) = s.to_str().ok().and_then(|ss| ss.chars().next()) {
                                v.push((c, val));
                            }
                        }
                    }
                    v
                })
                .unwrap_or_default();
            let _ = &rules;
            let sys = LSystem::new_from_pairs(&axiom, &rule_strings, iterations);
            Ok(sys.generate())
        })?,
    )?;
    // -- lsystemSegments --
    /// Expand an L-system and interpret the result as turtle-graphics commands, returning line segments.
    /// @param | opts | table | L-system options: axiom, iterations, rules.
    /// @param | angle | number? | Turn angle in degrees (default 25).
    /// @param | step | number? | Forward step length (default 1.0).
    /// @return | table | Array of segment tables {x1, y1, x2, y2}.
    /// @field | x1 | number | X1.
    /// @field | y1 | number | Y1.
    /// @field | x2 | number | X2.
    /// @field | y2 | number | Y2.
    tbl.set(
        "lsystemSegments",
        lua.create_function(
            |lua, (opts, angle_deg, step): (LuaTable, Option<f32>, Option<f32>)| {
                let axiom: String = opts.get("axiom").unwrap_or_else(|_| String::from("F"));
                let iterations: u32 = opts.get("iterations").unwrap_or(3);
                let rule_strings: Vec<(char, String)> = opts
                    .get::<_, Option<LuaTable>>("rules")
                    .unwrap_or(None)
                    .map(|rt| {
                        let mut v = Vec::new();
                        for (k, val) in rt.pairs::<LuaValue, String>().flatten() {
                            if let LuaValue::String(s) = k {
                                if let Some(c) = s.to_str().ok().and_then(|ss| ss.chars().next()) {
                                    v.push((c, val));
                                }
                            }
                        }
                        v
                    })
                    .unwrap_or_default();
                let sys = LSystem::new_from_pairs(&axiom, &rule_strings, iterations);
                let segs = sys.to_segments(angle_deg.unwrap_or(25.0), step.unwrap_or(1.0));
                let out = lua.create_table()?;
                for (i, (x1, y1, x2, y2)) in segs.iter().enumerate() {
                    let st = lua.create_table()?;
                    /// The 'x1' field value exposed to Lua scripts.
                    st.set("x1", *x1)?;
                    /// The 'y1' field value exposed to Lua scripts.
                    st.set("y1", *y1)?;
                    /// The 'x2' field value exposed to Lua scripts.
                    st.set("x2", *x2)?;
                    /// The 'y2' field value exposed to Lua scripts.
                    st.set("y2", *y2)?;
                    out.set(i + 1, st)?;
                }
                Ok(out)
            },
        )?,
    )?;
    // -- generateName --
    /// Generate a single random name based on a Markov chain trained from sample names. Great for NPC names, place names, or item names.
    /// @param | samples | table | Array of example name strings to learn from.
    /// @param | minLen | number? | Minimum output length in characters (default 3).
    /// @param | maxLen | number? | Maximum output length in characters (default 10).
    /// @param | seed | number? | RNG seed (default 0).
    /// @return | string | A generated name.
    tbl.set(
        "generateName",
        lua.create_function(
            |_,
             (samples_tbl, min_len, max_len, seed): (
                LuaTable,
                Option<usize>,
                Option<usize>,
                Option<u64>,
            )| {
                let mut samples: Vec<String> = Vec::new();
                for v in samples_tbl.sequence_values::<String>() {
                    samples.push(v?);
                }
                let refs: Vec<&str> = samples.iter().map(|s| s.as_str()).collect();
                let mut gen = NameGen::new(&refs, 2, seed.unwrap_or(0));
                Ok(gen.generate(min_len.unwrap_or(3), max_len.unwrap_or(10)))
            },
        )?,
    )?;
    // -- generateNames --
    /// Generate multiple random names in one call using Markov chains trained from sample data.
    /// @param | samples | table | Array of example name strings to learn from.
    /// @param | count | number | Number of names to generate.
    /// @param | minLen | number? | Minimum output length (default 3).
    /// @param | maxLen | number? | Maximum output length (default 10).
    /// @param | seed | number? | RNG seed (default 0).
    /// @return | string[] | Generated name strings.
    tbl.set(
        "generateNames",
        lua.create_function(
            |lua,
             (samples_tbl, n, min_len, max_len, seed): (
                LuaTable,
                usize,
                Option<usize>,
                Option<usize>,
                Option<u64>,
            )| {
                let mut samples: Vec<String> = Vec::new();
                for v in samples_tbl.sequence_values::<String>() {
                    samples.push(v?);
                }
                let refs: Vec<&str> = samples.iter().map(|s| s.as_str()).collect();
                let mut gen = NameGen::new(&refs, 2, seed.unwrap_or(0));
                let names = gen.generate_n(n, min_len.unwrap_or(3), max_len.unwrap_or(10));
                let out = lua.create_table()?;
                for (i, name) in names.iter().enumerate() {
                    out.set(i + 1, name.clone())?;
                }
                Ok(out)
            },
        )?,
    )?;
    // -- worldGraph --
    /// Generate a connected world graph with named regions and weighted edges. Useful for overworld maps, trade routes, or quest connectivity.
    /// @param | width | number | World area width.
    /// @param | height | number | World area height.
    /// @param | regionCount | integer | Number of regions to place.
    /// @param | seed | integer? | RNG seed (default 0).
    /// @return | table | Table with regions and edges arrays.
    /// @field | regions | table | Array of region tables, each with id (integer), name (string), x (number), y (number), tags (string[]).
    /// @field | edges | table | Array of edge tables, each with from (integer), to (integer), cost (number), bidirectional (boolean).
    tbl.set(
        "worldGraph",
        lua.create_function(
            |lua, (width, height, region_count, seed): (f32, f32, u32, Option<u64>)| {
                let wg = generate_world_graph(width, height, region_count, seed.unwrap_or(0));
                let regions_tbl = lua.create_table()?;
                for (i, r) in wg.regions.iter().enumerate() {
                    let rt = lua.create_table()?;
                    /// The 'id' field value exposed to Lua scripts.
                    rt.set("id", r.id)?;
                    /// Performs the 'name' operation.
                    rt.set("name", r.name.clone())?;
                    /// The 'x' field value exposed to Lua scripts.
                    rt.set("x", r.x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    rt.set("y", r.y)?;
                    let tags_tbl = lua.create_table()?;
                    for (j, tag) in r.tags.iter().enumerate() {
                        tags_tbl.set(j + 1, tag.clone())?;
                    }
                    /// Performs the 'tags' operation.
                    rt.set("tags", tags_tbl)?;
                    regions_tbl.set(i + 1, rt)?;
                }
                let edges_tbl = lua.create_table()?;
                for (i, e) in wg.edges.iter().enumerate() {
                    let et = lua.create_table()?;
                    /// Performs the 'from' operation.
                    et.set("from", e.from)?;
                    /// The 'to' field value exposed to Lua scripts.
                    et.set("to", e.to)?;
                    /// Performs the 'cost' operation.
                    et.set("cost", e.cost)?;
                    /// Performs the 'bidirectional' operation.
                    et.set("bidirectional", e.bidirectional)?;
                    edges_tbl.set(i + 1, et)?;
                }
                let out = lua.create_table()?;
                /// Performs the 'regions' operation.
                out.set("regions", regions_tbl)?;
                /// Performs the 'edges' operation.
                out.set("edges", edges_tbl)?;
                Ok(out)
            },
        )?,
    )?;
    // -- noiseMap --
    /// Generate a 2D noise map with configurable scale, octaves, and offsets. Runs on a single thread.
    /// @param | width | integer | Map width in cells.
    /// @param | height | integer | Map height in cells.
    /// @param | opts | table? | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y, seed.
    /// @return | number[] | F64 noise values (length = width*height).
    tbl.set(
        "noiseMap",
        lua.create_function(|lua, (width, height, opts): (u32, u32, Option<LuaTable>)| {
            let mut cfg = MapGenOptions::default();
            if let Some(t) = opts {
                if let Ok(v) = t.get::<_, f64>("scale_x") {
                    cfg.scale_x = v;
                }
                if let Ok(v) = t.get::<_, f64>("scale_y") {
                    cfg.scale_y = v;
                }
                if let Ok(v) = t.get::<_, u32>("octaves") {
                    cfg.octaves = v;
                }
                if let Ok(v) = t.get::<_, f64>("lacunarity") {
                    cfg.lacunarity = v;
                }
                if let Ok(v) = t.get::<_, f64>("persistence") {
                    cfg.persistence = v;
                }
                if let Ok(v) = t.get::<_, f64>("offset_x") {
                    cfg.offset_x = v;
                }
                if let Ok(v) = t.get::<_, f64>("offset_y") {
                    cfg.offset_y = v;
                }
                if let Ok(v) = t.get::<_, bool>("parallel") {
                    cfg.parallel_enabled = v;
                }
                if let Ok(v) = t.get::<_, usize>("parallel_chunk_size") {
                    cfg.parallel_chunk_size = Some(v);
                }
                if let Ok(v) = t.get::<_, u64>("seed") {
                    let g = NoiseGenerator::new(v);
                    let map = g
                        .try_generate_map(width, height, &cfg, &procgen_limits())
                        .map_err(lua_procgen_error)?;
                    let out = lua.create_table()?;
                    for (i, &val) in map.iter().enumerate() {
                        out.set(i + 1, val)?;
                    }
                    return Ok(out);
                }
            }
            let g = NoiseGenerator::new(0);
            let map = g
                .try_generate_map(width, height, &cfg, &procgen_limits())
                .map_err(lua_procgen_error)?;
            let out = lua.create_table()?;
            for (i, &val) in map.iter().enumerate() {
                out.set(i + 1, val)?;
            }
            Ok(out)
        })?,
    )?;
    // -- noiseMapParallel --
    /// Generate a 2D noise map using multiple threads for faster computation on large maps. Uses seed 0.
    /// @param | width | integer | Map width in cells.
    /// @param | height | integer | Map height in cells.
    /// @param | opts | table? | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y.
    /// @return | number[] | F64 noise values (length = width*height).
    tbl.set(
        "noiseMapParallel",
        lua.create_function(|lua, (width, height, opts): (u32, u32, Option<LuaTable>)| {
            let mut cfg = MapGenOptions::default();
            if let Some(t) = opts {
                if let Ok(v) = t.get::<_, f64>("scale_x") {
                    cfg.scale_x = v;
                }
                if let Ok(v) = t.get::<_, f64>("scale_y") {
                    cfg.scale_y = v;
                }
                if let Ok(v) = t.get::<_, u32>("octaves") {
                    cfg.octaves = v;
                }
                if let Ok(v) = t.get::<_, f64>("lacunarity") {
                    cfg.lacunarity = v;
                }
                if let Ok(v) = t.get::<_, f64>("persistence") {
                    cfg.persistence = v;
                }
                if let Ok(v) = t.get::<_, f64>("offset_x") {
                    cfg.offset_x = v;
                }
                if let Ok(v) = t.get::<_, f64>("offset_y") {
                    cfg.offset_y = v;
                }
                if let Ok(v) = t.get::<_, bool>("parallel") {
                    cfg.parallel_enabled = v;
                }
                if let Ok(v) = t.get::<_, usize>("parallel_chunk_size") {
                    cfg.parallel_chunk_size = Some(v);
                }
            }
            let map = try_generate_noise_map_parallel(width, height, &cfg, &procgen_limits())
                .map_err(lua_procgen_error)?;
            let out = lua.create_table()?;
            for (i, &val) in map.iter().enumerate() {
                out.set(i + 1, val)?;
            }
            Ok(out)
        })?,
    )?;
    // -- noiseMapParallelSeeded --
    /// Generate a 2D noise map using multiple threads with a specific seed for reproducible results.
    /// @param | width | integer | Map width in cells.
    /// @param | height | integer | Map height in cells.
    /// @param | opts | table? | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y, seed.
    /// @return | number[] | F64 noise values (length = width*height).
    tbl.set(
        "noiseMapParallelSeeded",
        lua.create_function(|lua, (width, height, opts): (u32, u32, Option<LuaTable>)| {
            let mut cfg = MapGenOptions::default();
            let mut seed = 0_u64;
            if let Some(t) = opts {
                if let Ok(v) = t.get::<_, f64>("scale_x") {
                    cfg.scale_x = v;
                }
                if let Ok(v) = t.get::<_, f64>("scale_y") {
                    cfg.scale_y = v;
                }
                if let Ok(v) = t.get::<_, u32>("octaves") {
                    cfg.octaves = v;
                }
                if let Ok(v) = t.get::<_, f64>("lacunarity") {
                    cfg.lacunarity = v;
                }
                if let Ok(v) = t.get::<_, f64>("persistence") {
                    cfg.persistence = v;
                }
                if let Ok(v) = t.get::<_, f64>("offset_x") {
                    cfg.offset_x = v;
                }
                if let Ok(v) = t.get::<_, f64>("offset_y") {
                    cfg.offset_y = v;
                }
                if let Ok(v) = t.get::<_, u64>("seed") {
                    seed = v;
                }
            }
            let g = NoiseGenerator::new(seed);
            let map = g
                .try_generate_map_parallel(width, height, &cfg, &procgen_limits())
                .map_err(lua_procgen_error)?;
            let out = lua.create_table()?;
            for (i, &val) in map.iter().enumerate() {
                out.set(i + 1, val)?;
            }
            Ok(out)
        })?,
    )?;
    // -- noiseMapGrid --
    /// Generate a typed scalar noise grid using the optional seed in opts.
    /// @param | width | integer | Map width in cells.
    /// @param | height | integer | Map height in cells.
    /// @param | opts | table? | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y, seed.
    /// @return | LProcgenScalarGrid | Typed scalar grid.
    tbl.set(
        "noiseMapGrid",
        lua.create_function(|_, (width, height, opts): (u32, u32, Option<LuaTable>)| {
            let (cfg, seed) = map_gen_options_from_snake_table(opts.as_ref())?;
            let generator = NoiseGenerator::new(seed);
            let cells = generator
                .try_generate_map(width, height, &cfg, &procgen_limits())
                .map_err(lua_procgen_error)?
                .into_iter()
                .map(|value| value as f32)
                .collect();
            LuaProcgenScalarGrid::new("noise_map", width, height, cells)
        })?,
    )?;
    // -- noiseMapParallelGrid --
    /// Generate a typed scalar noise grid using the parallel backend and seed 0.
    /// @param | width | integer | Map width in cells.
    /// @param | height | integer | Map height in cells.
    /// @param | opts | table? | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y.
    /// @return | LProcgenScalarGrid | Typed scalar grid.
    tbl.set(
        "noiseMapParallelGrid",
        lua.create_function(|_, (width, height, opts): (u32, u32, Option<LuaTable>)| {
            let (cfg, _) = map_gen_options_from_snake_table(opts.as_ref())?;
            let cells = try_generate_noise_map_parallel(width, height, &cfg, &procgen_limits())
                .map_err(lua_procgen_error)?
                .into_iter()
                .map(|value| value as f32)
                .collect();
            LuaProcgenScalarGrid::new("noise_map_parallel", width, height, cells)
        })?,
    )?;
    // -- noiseMapParallelSeededGrid --
    /// Generate a typed scalar noise grid using the parallel backend and explicit seed.
    /// @param | width | integer | Map width in cells.
    /// @param | height | integer | Map height in cells.
    /// @param | opts | table? | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y, seed.
    /// @return | LProcgenScalarGrid | Typed scalar grid.
    tbl.set(
        "noiseMapParallelSeededGrid",
        lua.create_function(|_, (width, height, opts): (u32, u32, Option<LuaTable>)| {
            let (cfg, seed) = map_gen_options_from_snake_table(opts.as_ref())?;
            let generator = NoiseGenerator::new(seed);
            let cells = generator
                .try_generate_map_parallel(width, height, &cfg, &procgen_limits())
                .map_err(lua_procgen_error)?
                .into_iter()
                .map(|value| value as f32)
                .collect();
            LuaProcgenScalarGrid::new("noise_map_parallel_seeded", width, height, cells)
        })?,
    )?;
    // -- simplex2d --
    /// Sample 2D simplex noise at a point. Returns a value roughly in [-1, 1].
    /// @param | x | number | X coordinate.
    /// @param | y | number | Y coordinate.
    /// @return | number | Simplex noise value.
    tbl.set(
        "simplex2d",
        lua.create_function(|_, (x, y): (f32, f32)| Ok(simplex_noise_2d(x, y)))?,
    )?;
    // -- simplex3d --
    /// Sample 3D simplex noise at a point. The third axis can be used for animation or layering.
    /// @param | x | number | X coordinate.
    /// @param | y | number | Y coordinate.
    /// @param | z | number | Z coordinate (often time or layer index).
    /// @return | number | Simplex noise value.
    tbl.set(
        "simplex3d",
        lua.create_function(|_, (x, y, z): (f32, f32, f32)| Ok(simplex_noise_3d(x, y, z)))?,
    )?;
    // -- newNoiseGenerator --
    /// Creates a procedural noise generator with an optional seed.
    /// @param | seed | integer? | Seed value (default 0).
    /// @return | LNoiseGenerator | New noise generator handle.
    tbl.set(
        "newNoiseGenerator",
        lua.create_function(|lua, seed: Option<u64>| {
            lua.create_userdata(LuaNoiseGenerator {
                inner: NoiseGenerator::new(seed.unwrap_or(0)),
            })
        })?,
    )?;
    // -- perlin2d --
    /// Samples stateless 2D Perlin noise.
    /// @param | x | number | X coordinate.
    /// @param | y | number | Y coordinate.
    /// @param | seed | integer? | Seed value (default 0).
    /// @return | number | Noise value.
    tbl.set(
        "perlin2d",
        lua.create_function(|_, (x, y, seed): (f32, f32, Option<u32>)| {
            Ok(noise_perlin2d(x, y, seed.unwrap_or(0)))
        })?,
    )?;
    // -- perlin3d --
    /// Samples stateless 3D Perlin noise.
    /// @param | x | number | X coordinate.
    /// @param | y | number | Y coordinate.
    /// @param | z | number | Z coordinate.
    /// @param | seed | integer? | Seed value (default 0).
    /// @return | number | Noise value.
    tbl.set(
        "perlin3d",
        lua.create_function(|_, (x, y, z, seed): (f32, f32, f32, Option<u32>)| {
            Ok(noise_perlin3d(x, y, z, seed.unwrap_or(0)))
        })?,
    )?;
    // -- perlin4d --
    /// Samples stateless 4D Perlin noise.
    /// @param | x | number | X coordinate.
    /// @param | y | number | Y coordinate.
    /// @param | z | number | Z coordinate.
    /// @param | w | number | W coordinate.
    /// @param | seed | integer? | Seed value (default 0).
    /// @return | number | Noise value.
    tbl.set(
        "perlin4d",
        lua.create_function(|_, (x, y, z, w, seed): (f32, f32, f32, f32, Option<u32>)| {
            Ok(noise_perlin4d(x, y, z, w, seed.unwrap_or(0)))
        })?,
    )?;
    // -- fbm --
    /// Samples stateless fractal Brownian motion noise.
    /// @param | x | number | X coordinate.
    /// @param | y | number | Y coordinate.
    /// @param | seed | integer? | Seed value (default 0).
    /// @param | octaves | integer? | Octave count (default 4).
    /// @param | lac | number? | Lacunarity (default 2.0).
    /// @param | gain | number? | Gain (default 0.5).
    /// @return | number | Noise value.
    tbl.set(
        "fbm",
        lua.create_function(
            |_,
             (x, y, seed, octaves, lac, gain): (
                f32,
                f32,
                Option<u32>,
                Option<u32>,
                Option<f32>,
                Option<f32>,
            )| {
                Ok(noise_fbm(
                    x,
                    y,
                    seed.unwrap_or(0),
                    octaves.unwrap_or(4),
                    lac.unwrap_or(2.0),
                    gain.unwrap_or(0.5),
                ))
            },
        )?,
    )?;
    // -- simplexNoise --
    /// Sample a 2D or 3D simplex noise value at a given point.
    /// @param | x | number | X coordinate.
    /// @param | y | number | Y coordinate.
    /// @param | z | number? | Z coordinate for 3D noise.
    /// @return | number | Noise value.
    tbl.set(
        "simplexNoise",
        lua.create_function(|_, (x, y, z): (f64, f64, Option<f64>)| {
            let v = match z {
                Some(zv) => simplex_noise_3d(x as f32, y as f32, zv as f32),
                None => simplex_noise_2d(x as f32, y as f32),
            };
            Ok(v as f64)
        })?,
    )?;
    // -- newBiomeClassifier --
    /// Create a BiomeClassifier object with custom threshold rules for mapping height/moisture/temperature to biome types.
    /// @param | opts | table? | Optional rules: ocean_threshold, coast_threshold, mountain_threshold, ice_cap_threshold, cold_temperature, warm_temperature, dry_moisture, wet_moisture.
    /// @return | LBiomeClassifier | A classifier object with :classify() and :classifyMap() methods.
    tbl.set(
        "newBiomeClassifier",
        lua.create_function(|lua, opts: Option<LuaTable>| {
            let rules = opts
                .map(|t| BiomeRules::from_lua_table(&t))
                .transpose()?
                .unwrap_or_default();
            lua.create_userdata(LuaBiomeClassifier(BiomeClassifier::new(rules)))
        })?,
    )?;
    // -- biomeColor --
    /// Get the default RGBA display color for a biome type name. Useful for minimap or debug visualization.
    /// @param | name | string | Biome name (e.g. "ocean", "desert", "taiga").
    /// @return | number | Red component (0â€“255).
    /// @return | number | Green component (0â€“255).
    /// @return | number | Blue component (0â€“255).
    /// @return | number | Alpha component (0â€“255).
    tbl.set(
        "biomeColor",
        lua.create_function(|_, name: String| {
            let bt = BiomeType::from_name(&name);
            let [r, g, b, a] = bt.color_rgba();
            Ok((r, g, b, a))
        })?,
    )?;
    /// Performs the 'procgen' operation.
    // -- newCellular --
    /// Creates a new cellular automaton simulation grid for falling-sand style simulation.
    /// @param | width | integer | Grid width in cells.
    /// @param | height | integer | Grid height in cells.
    /// @return | LCellular | The cellular simulation object.
    tbl.set(
        "newCellular",
        lua.create_function(|_, (width, height): (u32, u32)| {
            Ok(LuaCellular {
                sim: Rc::new(RefCell::new(
                    CellularWorld::try_new(width, height, &procgen_limits())
                        .map_err(lua_procgen_error)?,
                )),
            })
        })?,
    )?;
    /// Cell type constant: air â€” passable empty cell for cellular simulation.
    tbl.set("CELL_AIR", CellType::Air as u8)?;
    /// Cell type constant: sand â€” granular solid that falls and piles.
    tbl.set("CELL_SAND", CellType::Sand as u8)?;
    /// Cell type constant: water â€” liquid that flows and spreads.
    tbl.set("CELL_WATER", CellType::Water as u8)?;
    /// Cell type constant: rock â€” immovable solid barrier.
    tbl.set("CELL_ROCK", CellType::Rock as u8)?;
    /// Cell type constant: fire â€” active combustion that spreads and consumes.
    tbl.set("CELL_FIRE", CellType::Fire as u8)?;
    /// Cell type constant: gas â€” diffusing vapor that rises.
    tbl.set("CELL_GAS", CellType::Gas as u8)?;
    // -- setConstraintsFromLLM --
    /// Sends a natural-language prompt to the global LLM and returns WFC adjacency constraints as a Lua table.
    /// The LLM is asked to respond with JSON: {"adjacencies":{"tileId":[neighborIds...],...}}.
    /// Returns an empty table when the LLM is unavailable or returns malformed JSON.
    /// @param | prompt | string | Natural-language description of the desired tile adjacency rules.
    /// @return | table | Map from tile ID (integer key) to array of allowed neighbour IDs. Empty table on error.
    tbl.set(
        "setConstraintsFromLLM",
        lua.create_function(|lua, prompt: String| {
            let cfg = read_global_config();
            let system = "You are a WFC tile adjacency rule generator. Respond ONLY with valid JSON in the format: {\"adjacencies\":{\"0\":[1,2],\"1\":[0,3]}}.";
            let timeout = (cfg.timeout_ms / 1000).max(5);
            let result = ollama_generate_json(&cfg.base_url, &cfg.model, &prompt, system, timeout);
            let out = lua.create_table()?;
            if let Ok(val) = result {
                let constraints =
                    try_parse_llm_constraints(&val, &procgen_limits()).unwrap_or_default();
                for (id, neighbors) in &constraints {
                    let neighbors_tbl = lua.create_table()?;
                    for (i, n) in neighbors.iter().enumerate() {
                        neighbors_tbl.set(i + 1, *n)?;
                    }
                    out.set(*id, neighbors_tbl)?;
                }
            }
            Ok(out)
        })?,
    )?;
    // -- wfcFromPrompt --
    /// Asks the global LLM for WFC tile definitions and adjacency rules, then runs WFC generation.
    /// The LLM is asked to respond with JSON: {"tiles":[{"id":0,"weight":1.0},...], "adjacencies":{"0":[1,2],...}}.
    /// Returns the same grid table as wfcGenerate. Returns an empty grid table when the LLM is unavailable or returns malformed JSON.
    /// @param | prompt | string | Description of the desired tile map (e.g. "dungeon with stone corridors").
    /// @param | config | table | WFC config: width (integer), height (integer), seed (integer?), max_attempts (integer?).
    /// @return | table | WFC grid table with .width, .height, .cells ([{x,y,tile},...]), .failed_cells ([{x,y},...]).
    /// @field | width | integer | Grid width.
    /// @field | height | integer | Grid height.
    /// @field | cells | table | Array of {x, y, tile} tables for resolved cells.
    /// @field | failed_cells | table | Array of {x, y} tables for unresolved cells.
    tbl.set(
        "wfcFromPrompt",
        lua.create_function(|lua, (prompt, config): (String, LuaTable)| {
            let width: u32 = config.get::<_, u32>("width").unwrap_or(10);
            let height: u32 = config.get::<_, u32>("height").unwrap_or(10);
            let seed: u64 = config.get::<_, u64>("seed").unwrap_or(42);
            let max_attempts: u32 = config.get::<_, u32>("max_attempts").unwrap_or(10);

            let cfg = read_global_config();
            let system = "You are a WFC tile map generator. Respond ONLY with valid JSON: {\"tiles\":[{\"id\":0,\"weight\":1.0},...],\"adjacencies\":{\"0\":[1,2],...}}.";
            let timeout = (cfg.timeout_ms / 1000).max(5);
            let result = ollama_generate_json(&cfg.base_url, &cfg.model, &prompt, system, timeout);

            let grid_tbl = lua.create_table()?;
            grid_tbl.set("width", width)?;
            grid_tbl.set("height", height)?;
            let cells = lua.create_table()?;
            let failed = lua.create_table()?;

            if let Ok(val) = result {
                if let Ok(opts) = try_parse_llm_wfc_response(
                    &val,
                    width,
                    height,
                    seed,
                    max_attempts,
                    &procgen_limits(),
                ) {
                    if let Ok(grid) = try_wfc_generate(&opts, &procgen_limits()) {
                        let mut ci = 1usize;
                        let mut fi = 1usize;
                        for (i, cell) in grid.cells.iter().enumerate() {
                            let x = (i as u32) % width;
                            let y = (i as u32) / width;
                            if let Some(tile_id) = cell {
                                let c = lua.create_table()?;
                                c.set("x", x)?;
                                c.set("y", y)?;
                                c.set("tile", *tile_id)?;
                                cells.set(ci, c)?;
                                ci += 1;
                            } else {
                                let f = lua.create_table()?;
                                f.set("x", x)?;
                                f.set("y", y)?;
                                failed.set(fi, f)?;
                                fi += 1;
                            }
                        }
                    }
                }
            }
            grid_tbl.set("cells", cells)?;
            grid_tbl.set("failed_cells", failed)?;
            Ok(grid_tbl)
        })?,
    )?;
    luna.set("procgen", tbl)?;
    Ok(())
}
impl CellularOpts {
    /// Builds cellular-generation options from a Lua options table.
    pub fn from_lua_table(t: &LuaTable) -> LuaResult<Self> {
        let mut opts = Self::default();
        if let Ok(v) = t.get::<_, f32>("fill") {
            opts.fill = v;
        }
        if let Ok(v) = t.get::<_, u32>("iterations") {
            opts.iterations = v;
        }
        if let Ok(v) = t.get::<_, u32>("birth") {
            opts.birth = v;
        }
        if let Ok(v) = t.get::<_, u32>("survive") {
            opts.survive = v;
        }
        if let Ok(v) = t.get::<_, u64>("seed") {
            opts.seed = v;
        }
        Ok(opts)
    }
}
impl VoronoiOpts {
    /// Builds Voronoi-generation options from a Lua options table.
    pub fn from_lua_table(t: &LuaTable) -> LuaResult<Self> {
        let mut opts = Self::default();
        if let Ok(v) = t.get::<_, f32>("warp_scale") {
            opts.warp_scale = v;
        }
        if let Ok(v) = t.get::<_, f32>("warp_strength") {
            opts.warp_strength = v;
        }
        if let Ok(v) = t.get::<_, u64>("seed") {
            opts.seed = v;
        }
        Ok(opts)
    }
}
