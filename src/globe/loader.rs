//! Provides globe region-loading workflows from TOML, raster grids, and generated Voronoi seed sources. `globe/loader` delivers the asset or data loading path for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Parses lightweight structured input into normalized region records with geometry and adjacency data. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Converts intermediate builder state into shared globe region types used across the subsystem. Public callable behavior is centered on `load_from_toml_str`, `load_from_toml_file`, `load_from_png_file`, `load_from_province_grid`, `generate_voronoi_provinces`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! Extracts bounds and neighbor hints from image-driven province maps for quick content bootstrapping. Runtime integration reaches sibling engine areas through crate modules `globe`, `math`, `province`, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! Handles primitive parsing and validation to keep load-time failures explicit and actionable. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
//! Supports both in-memory string input and file-based ingestion paths for tooling flexibility. The file boundary separates globe implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

use crate::globe::types::{Region, RegionId, RegionPart};
use crate::math::voronoi::voronoi_from_points;
use crate::province::province_grid::ProvinceGrid;
use std::collections::HashMap;
/// Parsed TOML region record before conversion into the shared region type.
#[derive(Debug, Clone)]
struct TomlRegion {
    /// Region identifier.
    id: RegionId,
    /// Optional region centroid as latitude and longitude.
    centroid: Option<(f32, f32)>,
    /// Region geometry represented as multipart polygon data.
    parts: Vec<RegionPart>,
    /// Neighboring region ids.
    neighbors: Vec<RegionId>,
    /// Optional base RGBA color.
    base_color: Option<[f32; 4]>,
    /// Optional region texture name.
    texture: Option<String>,
    /// Arbitrary string attributes.
    attrs: HashMap<String, String>,
}
/// Load regions from a TOML string or return a parse error.
pub fn load_from_toml_str(src: &str) -> Result<Vec<Region>, String> {
    let doc = parse_toml_region_list(src)?;
    Ok(doc.into_iter().map(toml_region_to_region).collect())
}
/// Load regions from a TOML file path or return a parse or I/O error.
pub fn load_from_toml_file(path: &str) -> Result<Vec<Region>, String> {
    let src =
        std::fs::read_to_string(path).map_err(|e| format!("cannot read '{}': {}", path, e))?;
    load_from_toml_str(&src)
}
/// Convert a parsed TOML region into the shared region type.
fn toml_region_to_region(tp: TomlRegion) -> Region {
    let centroid = tp
        .centroid
        .unwrap_or_else(|| Region::from_parts(tp.id, tp.parts.clone()).centroid);
    let neighbors = tp.neighbors;
    let mut p = Region::with_parts_data(
        tp.id,
        centroid,
        tp.parts,
        neighbors.clone(),
        tp.base_color.unwrap_or([0.5, 0.5, 0.5, 1.0]),
    );
    p.neighbors = neighbors;
    p.texture = tp.texture;
    p.attrs = tp.attrs;
    p
}
/// Parse a TOML region list using the `toml` crate so multipart geometry stays expressible.
fn parse_toml_region_list(src: &str) -> Result<Vec<TomlRegion>, String> {
    let doc: toml::Value = toml::from_str(src).map_err(|e| format!("invalid globe TOML: {e}"))?;
    let root = doc
        .as_table()
        .ok_or_else(|| "globe TOML root must be a table".to_string())?;
    let mut regions = Vec::new();
    collect_toml_regions(root, "province", &mut regions)?;
    collect_toml_regions(root, "region", &mut regions)?;
    Ok(regions)
}

fn collect_toml_regions(
    root: &toml::value::Table,
    key: &str,
    out: &mut Vec<TomlRegion>,
) -> Result<(), String> {
    let Some(entries) = root.get(key) else {
        return Ok(());
    };
    let values = entries
        .as_array()
        .ok_or_else(|| format!("'{key}' must be an array of tables"))?;
    for (index, value) in values.iter().enumerate() {
        let table = value
            .as_table()
            .ok_or_else(|| format!("{key}[{}] must be a table", index + 1))?;
        out.push(parse_toml_region_entry(table, key)?);
    }
    Ok(())
}

fn parse_toml_region_entry(table: &toml::value::Table, kind: &str) -> Result<TomlRegion, String> {
    let id = RegionId(parse_toml_u32(
        table
            .get("id")
            .ok_or_else(|| format!("{kind} missing 'id'"))?,
        &format!("{kind}.id"),
    )?);
    let parts = if let Some(parts_value) = table.get("parts") {
        parse_toml_parts(parts_value, &format!("{kind} {id}"))?
    } else if let Some(vertices_value) = table.get("vertices") {
        vec![RegionPart::new(parse_toml_lat_lon_loop(
            vertices_value,
            &format!("{kind} {id} vertices"),
        )?)]
    } else {
        return Err(format!("{kind} {id} requires either 'vertices' or 'parts'"));
    };
    let centroid = table
        .get("centroid")
        .map(|value| parse_toml_lat_lon_pair(value, &format!("{kind} {id} centroid")))
        .transpose()?;
    let neighbors = table
        .get("neighbors")
        .map(|value| parse_toml_u32_array(value, &format!("{kind} {id} neighbors")))
        .transpose()?
        .unwrap_or_default()
        .into_iter()
        .map(RegionId)
        .collect();
    let base_color = table
        .get("base_color")
        .map(|value| parse_toml_rgba(value, &format!("{kind} {id} base_color")))
        .transpose()?;
    let texture = table
        .get("texture")
        .map(|value| parse_toml_string(value, &format!("{kind} {id} texture")))
        .transpose()?;
    let attrs = table
        .get("attrs")
        .map(|value| parse_toml_attrs(value, &format!("{kind} {id} attrs")))
        .transpose()?
        .unwrap_or_default();
    Ok(TomlRegion {
        id,
        centroid,
        parts,
        neighbors,
        base_color,
        texture,
        attrs,
    })
}

fn parse_toml_attrs(value: &toml::Value, label: &str) -> Result<HashMap<String, String>, String> {
    let table = value
        .as_table()
        .ok_or_else(|| format!("{label} must be a table"))?;
    let mut attrs = HashMap::with_capacity(table.len());
    for (key, val) in table {
        attrs.insert(
            key.clone(),
            toml_scalar_to_string(val, &format!("{label}.{key}"))?,
        );
    }
    Ok(attrs)
}

fn toml_scalar_to_string(value: &toml::Value, label: &str) -> Result<String, String> {
    match value {
        toml::Value::String(v) => Ok(v.clone()),
        toml::Value::Integer(v) => Ok(v.to_string()),
        toml::Value::Float(v) => Ok(v.to_string()),
        toml::Value::Boolean(v) => Ok(v.to_string()),
        _ => Err(format!("{label} must be a scalar TOML value")),
    }
}

fn parse_toml_parts(value: &toml::Value, label: &str) -> Result<Vec<RegionPart>, String> {
    let array = value
        .as_array()
        .ok_or_else(|| format!("{label} parts must be an array"))?;
    let mut parts = Vec::with_capacity(array.len());
    for (index, entry) in array.iter().enumerate() {
        let table = entry
            .as_table()
            .ok_or_else(|| format!("{label} part {} must be a table", index + 1))?;
        let outer = parse_toml_lat_lon_loop(
            table
                .get("outer")
                .ok_or_else(|| format!("{label} part {} requires 'outer'", index + 1))?,
            &format!("{label} part {} outer", index + 1),
        )?;
        let holes = table
            .get("holes")
            .map(|holes_value| {
                let hole_values = holes_value
                    .as_array()
                    .ok_or_else(|| format!("{label} part {} holes must be an array", index + 1))?;
                hole_values
                    .iter()
                    .enumerate()
                    .map(|(hole_index, hole)| {
                        parse_toml_lat_lon_loop(
                            hole,
                            &format!("{label} part {} hole {}", index + 1, hole_index + 1),
                        )
                    })
                    .collect()
            })
            .transpose()?
            .unwrap_or_default();
        parts.push(RegionPart { outer, holes });
    }
    if parts.is_empty() {
        return Err(format!("{label} parts must not be empty"));
    }
    Ok(parts)
}

fn parse_toml_lat_lon_loop(value: &toml::Value, label: &str) -> Result<Vec<(f32, f32)>, String> {
    let array = value
        .as_array()
        .ok_or_else(|| format!("{label} must be an array of [lat, lon] pairs"))?;
    let mut out = Vec::with_capacity(array.len());
    for (index, pair) in array.iter().enumerate() {
        out.push(parse_toml_lat_lon_pair(
            pair,
            &format!("{label} vertex {}", index + 1),
        )?);
    }
    if out.len() < 3 {
        return Err(format!("{label} must contain at least 3 vertices"));
    }
    Ok(out)
}

fn parse_toml_lat_lon_pair(value: &toml::Value, label: &str) -> Result<(f32, f32), String> {
    let pair = value
        .as_array()
        .ok_or_else(|| format!("{label} must be a [lat, lon] array"))?;
    if pair.len() != 2 {
        return Err(format!("{label} must have exactly 2 numbers"));
    }
    Ok((
        parse_toml_f32(&pair[0], &format!("{label}[0]"))?,
        parse_toml_f32(&pair[1], &format!("{label}[1]"))?,
    ))
}

fn parse_toml_rgba(value: &toml::Value, label: &str) -> Result<[f32; 4], String> {
    let array = value
        .as_array()
        .ok_or_else(|| format!("{label} must be a [r, g, b, a] array"))?;
    if array.len() != 4 {
        return Err(format!("{label} must have exactly 4 numbers"));
    }
    Ok([
        parse_toml_f32(&array[0], &format!("{label}[0]"))?,
        parse_toml_f32(&array[1], &format!("{label}[1]"))?,
        parse_toml_f32(&array[2], &format!("{label}[2]"))?,
        parse_toml_f32(&array[3], &format!("{label}[3]"))?,
    ])
}

fn parse_toml_u32_array(value: &toml::Value, label: &str) -> Result<Vec<u32>, String> {
    let array = value
        .as_array()
        .ok_or_else(|| format!("{label} must be an array"))?;
    array
        .iter()
        .enumerate()
        .map(|(index, item)| parse_toml_u32(item, &format!("{label}[{index}]")))
        .collect()
}

fn parse_toml_string(value: &toml::Value, label: &str) -> Result<String, String> {
    value
        .as_str()
        .map(ToOwned::to_owned)
        .ok_or_else(|| format!("{label} must be a string"))
}

fn parse_toml_u32(value: &toml::Value, label: &str) -> Result<u32, String> {
    let raw = value
        .as_integer()
        .ok_or_else(|| format!("{label} must be an integer"))?;
    u32::try_from(raw).map_err(|_| format!("{label} must fit in u32"))
}

fn parse_toml_f32(value: &toml::Value, label: &str) -> Result<f32, String> {
    if let Some(v) = value.as_float() {
        return Ok(v as f32);
    }
    if let Some(v) = value.as_integer() {
        return Ok(v as f32);
    }
    Err(format!("{label} must be a number"))
}
/// Load regions from a PNG province grid or return a decode or I/O error.
pub fn load_from_png_file(_path: &str) -> Result<Vec<Region>, String> {
    let grid = ProvinceGrid::from_file(_path)?;
    Ok(load_from_province_grid(&grid))
}

/// Convert a province grid into approximate globe regions using traced province contours.
pub fn load_from_province_grid(grid: &ProvinceGrid) -> Vec<Region> {
    let width = grid.width().max(1);
    let height = grid.height().max(1);
    let polygons = grid.province_polygons_simplified();
    let mut neighbors: HashMap<RegionId, Vec<RegionId>> = HashMap::new();
    for (a, b, _) in grid.adjacencies() {
        let ra = RegionId(*a);
        let rb = RegionId(*b);
        neighbors.entry(ra).or_default().push(rb);
        neighbors.entry(rb).or_default().push(ra);
    }
    let to_lon = |x: u32| (x as f32 / width as f32) * 360.0 - 180.0;
    let to_lat = |y: u32| 90.0 - (y as f32 / height as f32) * 180.0;
    let mut out = Vec::with_capacity(polygons.len());
    for (raw_id, rings) in polygons {
        let parts = province_parts_from_rings(&rings, &to_lat, &to_lon);
        if parts.is_empty() {
            continue;
        }
        let id = RegionId(raw_id);
        let centroid = Region::from_parts(id, parts.clone()).centroid;
        let base_color = grid
            .province_color(raw_id)
            .map(|(r, g, b)| [r as f32 / 255.0, g as f32 / 255.0, b as f32 / 255.0, 1.0])
            .unwrap_or([0.5, 0.5, 0.5, 1.0]);
        out.push(Region::with_parts_data(
            id,
            centroid,
            parts,
            neighbors.remove(&id).unwrap_or_default(),
            base_color,
        ));
    }
    out
}
/// Generate approximate regions from Voronoi input points.
pub fn generate_voronoi_provinces(points: &[(f32, f32)]) -> Vec<Region> {
    if points.is_empty() {
        return Vec::new();
    }
    let pts_xy: Vec<(f32, f32)> = points.iter().map(|(lat, lon)| (*lon, *lat)).collect();
    let cells = voronoi_from_points(&pts_xy);
    let mut out = Vec::with_capacity(cells.len());
    for (i, cell) in cells.iter().enumerate() {
        let id = RegionId((i + 1) as u32);
        let mut vertices = Vec::with_capacity(cell.vertices.len().max(3));
        if cell.vertices.is_empty() {
            let (x, y) = cell.site;
            vertices.push((y - 0.5, x - 0.5));
            vertices.push((y - 0.5, x + 0.5));
            vertices.push((y + 0.5, x));
        } else {
            for (x, y) in &cell.vertices {
                let lat = (*y).clamp(-90.0, 90.0);
                let lon = (*x).clamp(-180.0, 180.0);
                vertices.push((lat, lon));
            }
        }
        let centroid = points.get(i).copied().unwrap_or((0.0, 0.0));
        out.push(Region::with_data(
            id,
            centroid,
            vertices,
            Vec::new(),
            [0.45, 0.45, 0.5, 1.0],
        ));
    }
    for i in 0..out.len() {
        let (ilat, ilon) = out[i].centroid;
        let mut nearest: Vec<(f32, RegionId)> = out
            .iter()
            .filter(|p| p.id != out[i].id)
            .map(|p| {
                let dlat = ilat - p.centroid.0;
                let dlon = ilon - p.centroid.1;
                (dlat * dlat + dlon * dlon, p.id)
            })
            .collect();
        nearest.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap_or(std::cmp::Ordering::Equal));
        out[i].neighbors = nearest.into_iter().take(4).map(|(_, id)| id).collect();
    }
    out
}

fn polygon_loop_area(points: &[(u32, u32)]) -> f32 {
    if points.len() < 3 {
        return 0.0;
    }
    let ring_points: &[(u32, u32)] = if points.len() >= 2 && points.first() == points.last() {
        &points[..points.len() - 1]
    } else {
        points
    };
    if ring_points.len() < 3 {
        return 0.0;
    }
    let mut area = 0.0_f32;
    for i in 0..ring_points.len() {
        let (ax, ay) = ring_points[i];
        let (bx, by) = ring_points[(i + 1) % ring_points.len()];
        area += ax as f32 * by as f32 - bx as f32 * ay as f32;
    }
    area * 0.5
}

fn province_parts_from_rings(
    rings: &[Vec<(u32, u32)>],
    to_lat: &impl Fn(u32) -> f32,
    to_lon: &impl Fn(u32) -> f32,
) -> Vec<RegionPart> {
    let normalized: Vec<Vec<(u32, u32)>> = rings
        .iter()
        .map(|ring| strip_closed_ring(ring).to_vec())
        .filter(|ring| ring.len() >= 3)
        .collect();
    if normalized.is_empty() {
        return Vec::new();
    }
    let abs_areas: Vec<f32> = normalized
        .iter()
        .map(|ring| polygon_loop_area(ring).abs())
        .collect();
    let samples: Vec<(f32, f32)> = normalized
        .iter()
        .map(|ring| ring_sample_point(ring))
        .collect();
    let mut parents: Vec<Option<usize>> = vec![None; normalized.len()];
    for i in 0..normalized.len() {
        let mut best_parent: Option<usize> = None;
        for j in 0..normalized.len() {
            if i == j || abs_areas[j] <= abs_areas[i] {
                continue;
            }
            if !point_in_pixel_loop(samples[i], &normalized[j]) {
                continue;
            }
            if let Some(existing) = best_parent {
                if abs_areas[j] < abs_areas[existing] {
                    best_parent = Some(j);
                }
            } else {
                best_parent = Some(j);
            }
        }
        parents[i] = best_parent;
    }
    let mut depths = vec![0usize; normalized.len()];
    for i in 0..normalized.len() {
        let mut depth = 0usize;
        let mut cursor = parents[i];
        while let Some(parent) = cursor {
            depth += 1;
            cursor = parents[parent];
        }
        depths[i] = depth;
    }
    let mut order: Vec<usize> = (0..normalized.len()).collect();
    order.sort_by(|&a, &b| abs_areas[b].total_cmp(&abs_areas[a]));
    let mut parts = Vec::new();
    let mut outer_to_part: HashMap<usize, usize> = HashMap::new();
    for index in order {
        let converted: Vec<(f32, f32)> = normalized[index]
            .iter()
            .map(|&(x, y)| (to_lat(y), to_lon(x)))
            .collect();
        if depths[index].is_multiple_of(2) {
            outer_to_part.insert(index, parts.len());
            parts.push(RegionPart::new(converted));
        } else if let Some(parent) = parents[index] {
            if let Some(&part_index) = outer_to_part.get(&parent) {
                parts[part_index].holes.push(converted);
            }
        }
    }
    parts
}

fn strip_closed_ring(points: &[(u32, u32)]) -> &[(u32, u32)] {
    if points.len() >= 2 && points.first() == points.last() {
        &points[..points.len() - 1]
    } else {
        points
    }
}

fn ring_sample_point(points: &[(u32, u32)]) -> (f32, f32) {
    let mut sum_x = 0.0_f32;
    let mut sum_y = 0.0_f32;
    for &(x, y) in points {
        sum_x += x as f32;
        sum_y += y as f32;
    }
    let count = points.len().max(1) as f32;
    (sum_x / count, sum_y / count)
}

fn point_in_pixel_loop(point: (f32, f32), vertices: &[(u32, u32)]) -> bool {
    if vertices.len() < 3 {
        return false;
    }
    let mut inside = false;
    let mut j = vertices.len() - 1;
    for i in 0..vertices.len() {
        let (xi, yi) = vertices[i];
        let (xj, yj) = vertices[j];
        let yi = yi as f32;
        let yj = yj as f32;
        let mut denom = yj - yi;
        if denom.abs() < f32::EPSILON {
            denom = if denom.is_sign_negative() {
                -f32::EPSILON
            } else {
                f32::EPSILON
            };
        }
        let intersects = ((yi > point.1) != (yj > point.1))
            && (point.0 < (xj as f32 - xi as f32) * (point.1 - yi) / denom + xi as f32);
        if intersects {
            inside = !inside;
        }
        j = i;
    }
    inside
}
