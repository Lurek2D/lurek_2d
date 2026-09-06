//! Owns polygon-authored province geometry, validation, topology, and picking.
//!
//! Tiled syntax is parsed by `tilemap::tiled`; this module converts normalized
//! objects into the province domain model. It deliberately keeps style,
//! routing policy, and renderer resources in their existing owners.

use crate::math::{
    classify_point_in_polygon, normalize_polygon_ring, point_on_segment_inclusive, polygon_area,
    polygon_bounds, polygon_centroid, polygon_self_intersects, snap_coordinate,
    PolygonPointLocation, Vec2,
};
use crate::province::types::ProvinceId;
use crate::tilemap::{TiledMap, TiledObjectShape, TiledPropertyValue};
use std::collections::HashMap;

/// One immutable authored polygon component belonging to a province.
#[derive(Debug, Clone, PartialEq)]
pub struct ProvincePolygon {
    /// Tiled object ID that authored this component.
    pub source_object_id: u32,
    /// Province identity shared by all components of the same province.
    pub province_id: ProvinceId,
    /// Counter-clockwise flattened map-space vertices.
    pub vertices: Vec<f32>,
    /// Triangle-list vertex indices for concave-safe rendering.
    pub triangle_indices: Vec<u32>,
    /// `(min_x, min_y, max_x, max_y)` bounds.
    pub bounds: (f32, f32, f32, f32),
    /// Signed polygon area before taking the absolute value.
    pub signed_area: f32,
    /// Centroid of this component.
    pub centroid: (f32, f32),
}

/// One positive-length shared boundary segment between two distinct provinces.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct PolygonBorderSegment {
    /// Lower province ID.
    pub province_a: ProvinceId,
    /// Higher province ID.
    pub province_b: ProvinceId,
    /// Segment start.
    pub x0: f32,
    /// Segment start.
    pub y0: f32,
    /// Segment end.
    pub x1: f32,
    /// Segment end.
    pub y1: f32,
}

/// Validated polygon geometry and derived province topology.
#[derive(Debug, Clone, PartialEq)]
pub struct PolygonProvinceGeometry {
    /// Map width in map pixels.
    pub width: u32,
    /// Map height in map pixels.
    pub height: u32,
    /// Grid increment used to quantize authored coordinates.
    pub snap_size: f32,
    /// Authored components in stable source order.
    pub polygons: Vec<ProvincePolygon>,
    /// Component indexes grouped by province ID.
    pub by_province: HashMap<ProvinceId, Vec<usize>>,
    /// Shared province boundaries.
    pub borders: Vec<PolygonBorderSegment>,
    /// Polygon indexes sorted by minimum X for bounded spatial queries.
    pub spatial_index: Vec<usize>,
    /// Uniform-grid buckets used to keep point picking from scanning every
    /// component for each minimap sample.
    pub spatial_buckets: HashMap<(u32, u32), Vec<usize>>,
    /// `(columns, rows)` of the uniform picking grid.
    pub spatial_bucket_dims: (u32, u32),
    /// Components too large to fit in a bounded number of buckets.
    pub spatial_large: Vec<usize>,
    /// Explicit capital position per province.
    pub capitals: HashMap<ProvinceId, (f32, f32)>,
    /// Area-weighted province centroid per province.
    pub centroids: HashMap<ProvinceId, (f32, f32)>,
}

/// Options controlling strict polygon import.
#[derive(Debug, Clone, PartialEq)]
pub struct PolygonImportOptions {
    /// Province object-layer name.
    pub province_layer: String,
    /// Capital point-layer name.
    pub capital_layer: String,
    /// Required integer object property name.
    pub id_property: String,
    /// Coordinate grid increment.
    pub snap_size: f32,
    /// Maximum allowed snap displacement.
    pub snap_tolerance: f32,
}

impl Default for PolygonImportOptions {
    fn default() -> Self {
        Self {
            province_layer: "provinces".to_string(),
            capital_layer: "capitals".to_string(),
            id_property: "province_id".to_string(),
            snap_size: 1.0,
            snap_tolerance: 0.01,
        }
    }
}

impl PolygonProvinceGeometry {
    /// Convert already-extracted raster loops into read-only polygon inspection data.
    pub fn from_grid_polygons(
        width: u32,
        height: u32,
        source: HashMap<u32, Vec<Vec<(u32, u32)>>>,
    ) -> Result<Self, String> {
        let mut polygons = Vec::new();
        let mut by_province: HashMap<ProvinceId, Vec<usize>> = HashMap::new();
        let mut source_object_id = 1u32;
        let mut source = source.into_iter().collect::<Vec<_>>();
        source.sort_by_key(|(raw_id, _)| *raw_id);
        for (raw_id, rings) in source {
            // Province ID 0 is the raster map's unowned/background value,
            // not an inspectable province component.
            if raw_id == 0 {
                continue;
            }
            let province_id = ProvinceId(raw_id);
            for ring in rings {
                let mut vertices = Vec::with_capacity(ring.len() * 2);
                for (x, y) in ring {
                    vertices.extend_from_slice(&[x as f32, y as f32]);
                }
                vertices = normalize_polygon_ring(&vertices, 0.0);
                if vertices.len() < 6 {
                    continue;
                }
                let mut signed_area = polygon_area(&vertices);
                if signed_area.abs() <= 1.0e-6 {
                    continue;
                }
                if signed_area < 0.0 {
                    reverse_ring(&mut vertices);
                    signed_area = -signed_area;
                }
                let bounds = polygon_bounds(&vertices)
                    .ok_or_else(|| "raster polygon has invalid bounds".to_string())?;
                let centroid = polygon_centroid(&vertices);
                let triangle_indices = triangulate_indices(&vertices)?;
                let index = polygons.len();
                polygons.push(ProvincePolygon {
                    source_object_id,
                    province_id,
                    vertices,
                    triangle_indices,
                    bounds,
                    signed_area,
                    centroid,
                });
                by_province.entry(province_id).or_default().push(index);
                source_object_id = source_object_id.saturating_add(1);
            }
        }
        let borders = derive_borders(&polygons, 1.0)?;
        let spatial_index = build_spatial_index(&polygons);
        let (spatial_buckets, spatial_bucket_dims, spatial_large) =
            build_spatial_buckets(&polygons, width, height);
        let mut centroids = HashMap::new();
        for (id, indexes) in &by_province {
            let mut area_sum = 0.0;
            let mut x_sum = 0.0;
            let mut y_sum = 0.0;
            for index in indexes {
                let polygon = &polygons[*index];
                let area = polygon.signed_area.abs();
                area_sum += area;
                x_sum += polygon.centroid.0 * area;
                y_sum += polygon.centroid.1 * area;
            }
            if area_sum > 0.0 {
                centroids.insert(*id, (x_sum / area_sum, y_sum / area_sum));
            }
        }
        Ok(Self {
            width,
            height,
            snap_size: 1.0,
            polygons,
            by_province,
            borders,
            spatial_index,
            spatial_buckets,
            spatial_bucket_dims,
            spatial_large,
            capitals: HashMap::new(),
            centroids,
        })
    }

    /// Build and validate polygon province geometry from a normalized Tiled map.
    pub fn from_tiled(map: &TiledMap, options: &PolygonImportOptions) -> Result<Self, String> {
        if map.width == 0 || map.height == 0 || map.tile_width == 0 || map.tile_height == 0 {
            return Err("Tiled map dimensions and tile dimensions must be positive".to_string());
        }
        if map.orientation != "orthogonal" {
            return Err("polygon provinces require an orthogonal Tiled map".to_string());
        }
        if map.infinite {
            return Err("polygon provinces do not support infinite Tiled maps".to_string());
        }
        if !options.snap_size.is_finite()
            || options.snap_size <= 0.0
            || !options.snap_tolerance.is_finite()
            || options.snap_tolerance < 0.0
        {
            return Err(
                "snap_size must be positive and snap_tolerance must be non-negative".to_string(),
            );
        }
        let width = map
            .width
            .checked_mul(map.tile_width)
            .ok_or_else(|| "Tiled map width overflows pixel extent".to_string())?;
        let height = map
            .height
            .checked_mul(map.tile_height)
            .ok_or_else(|| "Tiled map height overflows pixel extent".to_string())?;
        let province_layers = map
            .object_layers
            .iter()
            .filter(|layer| layer.name == options.province_layer)
            .collect::<Vec<_>>();
        if province_layers.is_empty() {
            return Err(format!(
                "missing province object layer '{}'",
                options.province_layer
            ));
        }
        if province_layers.len() != 1 {
            return Err(format!(
                "province object layer '{}' must be unique",
                options.province_layer
            ));
        }
        let capital_layers = map
            .object_layers
            .iter()
            .filter(|layer| layer.name == options.capital_layer)
            .collect::<Vec<_>>();
        if capital_layers.is_empty() {
            return Err(format!(
                "missing capital object layer '{}'",
                options.capital_layer
            ));
        }
        if capital_layers.len() != 1 {
            return Err(format!(
                "capital object layer '{}' must be unique",
                options.capital_layer
            ));
        }
        let province_layer = province_layers[0];
        let capital_layer = capital_layers[0];

        let mut polygons = Vec::new();
        let mut by_province: HashMap<ProvinceId, Vec<usize>> = HashMap::new();
        for object in &province_layer.objects {
            if object.id == 0 {
                return Err("province object id must be positive".to_string());
            }
            let TiledObjectShape::Polygon(points) = &object.shape else {
                return Err(format!("province object {} is not a polygon", object.id));
            };
            // Tiled rotation is authored in degrees.  Polygon maps only
            // support the exact unrotated object transform; even a tiny
            // non-zero value must not be silently accepted because applying
            // it would move the snapped topology.
            if object.rotation != 0.0 {
                return Err(format!(
                    "province object {} has unsupported rotation",
                    object.id
                ));
            }
            let raw_id = object
                .properties
                .get(&options.id_property)
                .and_then(TiledPropertyValue::as_int)
                .ok_or_else(|| {
                    format!(
                        "province object {} requires integer property '{}'",
                        object.id, options.id_property
                    )
                })?;
            if raw_id <= 0 || raw_id > i64::from(u32::MAX) {
                return Err(format!(
                    "province object {} has invalid province_id {}",
                    object.id, raw_id
                ));
            }
            let province_id = ProvinceId(raw_id as u32);
            let mut vertices = Vec::with_capacity(points.len() * 2);
            for point in points {
                let x = object.x + province_layer.offset_x + point.x;
                let y = object.y + province_layer.offset_y + point.y;
                let (x, dx) = snap_coordinate(x as f32, options.snap_size).ok_or_else(|| {
                    format!("province object {} has invalid x coordinate", object.id)
                })?;
                let (y, dy) = snap_coordinate(y as f32, options.snap_size).ok_or_else(|| {
                    format!("province object {} has invalid y coordinate", object.id)
                })?;
                if dx.hypot(dy) > options.snap_tolerance {
                    return Err(format!(
                        "province object {} is not snapped to the configured grid",
                        object.id
                    ));
                }
                if x < 0.0 || y < 0.0 || x > width as f32 || y > height as f32 {
                    return Err(format!(
                        "province object {} lies outside the map extent",
                        object.id
                    ));
                }
                vertices.extend_from_slice(&[x, y]);
            }
            vertices = normalize_polygon_ring(&vertices, options.snap_size * 1.0e-4);
            if vertices.len() < 6 {
                return Err(format!(
                    "province object {} needs at least three unique vertices",
                    object.id
                ));
            }
            let mut signed_area = polygon_area(&vertices);
            if !signed_area.is_finite() {
                return Err(format!("province object {} has non-finite area", object.id));
            }
            let geometry_epsilon = (options.snap_size * 1.0e-5).max(f32::EPSILON);
            if polygon_self_intersects(&vertices, geometry_epsilon) {
                return Err(format!(
                    "province object {} is self-intersecting",
                    object.id
                ));
            }
            if signed_area == 0.0 {
                return Err(format!("province object {} has zero area", object.id));
            }
            if signed_area < 0.0 {
                reverse_ring(&mut vertices);
                signed_area = -signed_area;
            }
            let triangles = triangulate_indices(&vertices)?;
            let bounds = polygon_bounds(&vertices)
                .ok_or_else(|| format!("province object {} has invalid bounds", object.id))?;
            let centroid = polygon_centroid(&vertices);
            let component = ProvincePolygon {
                source_object_id: object.id,
                province_id,
                vertices,
                triangle_indices: triangles,
                bounds,
                signed_area,
                centroid,
            };
            let index = polygons.len();
            polygons.push(component);
            by_province.entry(province_id).or_default().push(index);
        }
        if polygons.is_empty() {
            return Err("province layer contains no polygon objects".to_string());
        }
        let geometry_epsilon = (options.snap_size * 1.0e-5).max(f32::EPSILON);
        reject_overlaps(&polygons, geometry_epsilon)?;

        let mut capitals = HashMap::new();
        for object in &capital_layer.objects {
            if object.id == 0 {
                return Err("capital object id must be positive".to_string());
            }
            if !matches!(object.shape, TiledObjectShape::Point) {
                return Err(format!("capital object {} is not a point", object.id));
            }
            if object.rotation != 0.0 {
                return Err(format!(
                    "capital object {} has unsupported rotation",
                    object.id
                ));
            }
            let raw_id = object
                .properties
                .get(&options.id_property)
                .and_then(TiledPropertyValue::as_int)
                .ok_or_else(|| {
                    format!(
                        "capital object {} requires integer property '{}'",
                        object.id, options.id_property
                    )
                })?;
            if raw_id <= 0 || raw_id > i64::from(u32::MAX) {
                return Err(format!(
                    "capital object {} has invalid province_id {}",
                    object.id, raw_id
                ));
            }
            let province_id = ProvinceId(raw_id as u32);
            if !by_province.contains_key(&province_id) {
                return Err(format!(
                    "capital object {} references unknown province {}",
                    object.id, province_id
                ));
            }
            if capitals.contains_key(&province_id) {
                return Err(format!(
                    "province {} has more than one capital",
                    province_id
                ));
            }
            // Capitals are explicit authored positions. Polygon vertices are
            // quantized for topology, but a valid interior capital retains
            // its authored floating-point coordinate.
            let x = (object.x + capital_layer.offset_x) as f32;
            let y = (object.y + capital_layer.offset_y) as f32;
            if !x.is_finite() || !y.is_finite() {
                return Err(format!(
                    "capital object {} has invalid coordinates",
                    object.id
                ));
            }
            let capital_epsilon = (options.snap_size * 1.0e-5).max(f32::EPSILON);
            if !contains_strictly(
                &polygons,
                by_province[&province_id].as_slice(),
                x,
                y,
                capital_epsilon,
            ) {
                return Err(format!(
                    "capital object {} is not strictly inside province {}",
                    object.id, province_id
                ));
            }
            capitals.insert(province_id, (x, y));
        }
        if capitals.len() != by_province.len() {
            let missing = by_province
                .keys()
                .find(|id| !capitals.contains_key(id))
                .copied()
                .unwrap_or(ProvinceId(0));
            return Err(format!("province {} is missing its capital", missing));
        }

        let borders = derive_borders(&polygons, options.snap_size)?;
        let spatial_index = build_spatial_index(&polygons);
        let (spatial_buckets, spatial_bucket_dims, spatial_large) =
            build_spatial_buckets(&polygons, width, height);
        let mut centroids = HashMap::new();
        for (id, indices) in &by_province {
            let mut area_sum = 0.0f32;
            let mut x_sum = 0.0f32;
            let mut y_sum = 0.0f32;
            for &index in indices {
                let polygon = &polygons[index];
                let area = polygon.signed_area.abs();
                area_sum += area;
                x_sum += polygon.centroid.0 * area;
                y_sum += polygon.centroid.1 * area;
            }
            if area_sum > 0.0 {
                centroids.insert(*id, (x_sum / area_sum, y_sum / area_sum));
            }
        }
        Ok(Self {
            width,
            height,
            snap_size: options.snap_size,
            polygons,
            by_province,
            borders,
            spatial_index,
            spatial_buckets,
            spatial_bucket_dims,
            spatial_large,
            capitals,
            centroids,
        })
    }

    /// Return a province ID under a floating-point map coordinate.
    pub fn pick(&self, x: f32, y: f32) -> Option<ProvinceId> {
        if !x.is_finite()
            || !y.is_finite()
            || x < 0.0
            || y < 0.0
            || x > self.width as f32
            || y > self.height as f32
        {
            return None;
        }
        let epsilon = (self.snap_size * 1.0e-5).max(f32::EPSILON);
        let mut boundary: Option<ProvinceId> = None;
        let mut boundary_ids = Vec::new();
        let mut candidate_indexes = Vec::new();
        let (bucket_columns, bucket_rows) = self.spatial_bucket_dims;
        if bucket_columns > 0 && bucket_rows > 0 {
            let bucket_x = bucket_coordinate(x, self.width, bucket_columns);
            let bucket_y = bucket_coordinate(y, self.height, bucket_rows);
            if let Some(indexes) = self.spatial_buckets.get(&(bucket_x, bucket_y)) {
                candidate_indexes.extend(indexes.iter().copied());
            }
        }
        candidate_indexes.extend(self.spatial_large.iter().copied());
        candidate_indexes.sort_unstable();
        candidate_indexes.dedup();
        for index in candidate_indexes {
            let polygon = &self.polygons[index];
            let (min_x, min_y, max_x, max_y) = polygon.bounds;
            if x < min_x || x > max_x || y < min_y || y > max_y {
                continue;
            }
            match classify_point_in_polygon(&polygon.vertices, x, y, epsilon) {
                PolygonPointLocation::Inside => return Some(polygon.province_id),
                PolygonPointLocation::Boundary => {
                    boundary_ids.push(polygon.province_id);
                    boundary = Some(
                        boundary.map_or(polygon.province_id, |id| id.min(polygon.province_id)),
                    );
                }
                PolygonPointLocation::Outside => {}
            }
        }
        if let Some(boundary_id) = boundary {
            // A boundary owned by only one province is still part of that
            // province. This also makes a same-ID component seam behave like
            // the interior of the union rather than an artificial gap.
            boundary_ids.sort_unstable();
            boundary_ids.dedup();
            if boundary_ids.len() == 1
                || self.borders.iter().any(|segment| {
                    point_on_segment_inclusive(
                        x, y, segment.x0, segment.y0, segment.x1, segment.y1, epsilon,
                    )
                })
            {
                return Some(boundary_id);
            }
        }
        None
    }

    /// Return all polygon component indexes for a province.
    pub fn polygon_indexes(&self, id: ProvinceId) -> &[usize] {
        self.by_province.get(&id).map(Vec::as_slice).unwrap_or(&[])
    }
}

fn reverse_ring(vertices: &mut [f32]) {
    let mut reversed = Vec::with_capacity(vertices.len());
    for pair in vertices.chunks_exact(2).rev() {
        reversed.extend_from_slice(pair);
    }
    vertices.copy_from_slice(&reversed);
}

fn triangulate_indices(vertices: &[f32]) -> Result<Vec<u32>, String> {
    let points: Vec<Vec2> = vertices
        .chunks_exact(2)
        .map(|pair| Vec2::new(pair[0], pair[1]))
        .collect();
    let triangles = crate::math::polygon::triangulate(&points)?;
    let mut indices = Vec::with_capacity(triangles.len() * 3);
    for triangle in triangles {
        for point in triangle {
            let index = points
                .iter()
                .position(|candidate| (*candidate - point).length_squared() <= 1.0e-8)
                .ok_or_else(|| "triangulation produced an unknown vertex".to_string())?;
            indices.push(index as u32);
        }
    }
    Ok(indices)
}

fn contains_strictly(
    polygons: &[ProvincePolygon],
    indexes: &[usize],
    x: f32,
    y: f32,
    epsilon: f32,
) -> bool {
    indexes.iter().any(|index| {
        matches!(
            // Keep the strict-interior rule exact up to the geometry
            // predicate's minimum numerical epsilon.  A capital that is
            // merely close to a border is still a valid authored capital;
            // only an actual boundary hit is rejected.
            classify_point_in_polygon(&polygons[*index].vertices, x, y, epsilon),
            PolygonPointLocation::Inside
        )
    })
}

fn reject_overlaps(polygons: &[ProvincePolygon], epsilon: f32) -> Result<(), String> {
    let order = build_spatial_index(polygons);
    let mut active: Vec<usize> = Vec::new();
    for &index in &order {
        let min_x = polygons[index].bounds.0;
        active.retain(|other| polygons[*other].bounds.2 >= min_x);
        for &other in &active {
            if !bounds_overlap(polygons[index].bounds, polygons[other].bounds) {
                continue;
            }
            if polygons_overlap_positive(
                &polygons[index].vertices,
                &polygons[other].vertices,
                epsilon,
            ) {
                return Err(format!(
                    "province polygon objects {} and {} overlap",
                    polygons[index].source_object_id, polygons[other].source_object_id
                ));
            }
        }
        active.push(index);
    }
    Ok(())
}

fn build_spatial_index(polygons: &[ProvincePolygon]) -> Vec<usize> {
    let mut indexes = (0..polygons.len()).collect::<Vec<_>>();
    indexes.sort_by(|a, b| {
        polygons[*a]
            .bounds
            .0
            .total_cmp(&polygons[*b].bounds.0)
            .then_with(|| {
                polygons[*a]
                    .source_object_id
                    .cmp(&polygons[*b].source_object_id)
            })
    });
    indexes
}

/// Build a uniform AABB bucket index for repeated floating-point picks.
///
/// The grid grows with component count but is capped so a map with many
/// small components cannot allocate an unbounded number of buckets. Components
/// spanning too many cells are kept in `spatial_large` and are checked once per
/// query; ordinary components are visited only from the bucket containing the
/// query point.
type SpatialBucketIndex = (HashMap<(u32, u32), Vec<usize>>, (u32, u32), Vec<usize>);

fn build_spatial_buckets(
    polygons: &[ProvincePolygon],
    width: u32,
    height: u32,
) -> SpatialBucketIndex {
    if polygons.is_empty() || width == 0 || height == 0 {
        return (HashMap::new(), (1, 1), Vec::new());
    }
    let target = (polygons.len() as f64).sqrt().ceil().clamp(1.0, 64.0);
    let aspect = (f64::from(width) / f64::from(height)).sqrt().max(0.25);
    let columns = (target * aspect).round().clamp(1.0, 64.0) as u32;
    let rows = (target / aspect).round().clamp(1.0, 64.0) as u32;
    let mut buckets: HashMap<(u32, u32), Vec<usize>> = HashMap::new();
    let mut large = Vec::new();
    for (index, polygon) in polygons.iter().enumerate() {
        let bx0 = bucket_coordinate(polygon.bounds.0, width, columns);
        let bx1 = bucket_coordinate(polygon.bounds.2, width, columns);
        let by0 = bucket_coordinate(polygon.bounds.1, height, rows);
        let by1 = bucket_coordinate(polygon.bounds.3, height, rows);
        let bucket_count = (u64::from(bx1.saturating_sub(bx0)) + 1)
            .saturating_mul(u64::from(by1.saturating_sub(by0)) + 1);
        if bucket_count > 512 {
            large.push(index);
            continue;
        }
        for bucket_y in by0..=by1 {
            for bucket_x in bx0..=bx1 {
                buckets.entry((bucket_x, bucket_y)).or_default().push(index);
            }
        }
    }
    (buckets, (columns, rows), large)
}

fn bucket_coordinate(value: f32, extent: u32, buckets: u32) -> u32 {
    if buckets <= 1 || extent == 0 {
        return 0;
    }
    if value >= extent as f32 {
        return buckets - 1;
    }
    ((f64::from(value.max(0.0)) / f64::from(extent)) * f64::from(buckets))
        .floor()
        .clamp(0.0, f64::from(buckets - 1)) as u32
}

fn bounds_overlap(a: (f32, f32, f32, f32), b: (f32, f32, f32, f32)) -> bool {
    a.0 <= b.2 && b.0 <= a.2 && a.1 <= b.3 && b.1 <= a.3
}

fn polygons_overlap_positive(a: &[f32], b: &[f32], epsilon: f32) -> bool {
    crate::math::polygons_overlap_positive_area(a, b, epsilon)
}

fn derive_borders(
    polygons: &[ProvincePolygon],
    snap_size: f32,
) -> Result<Vec<PolygonBorderSegment>, String> {
    let rings = polygons
        .iter()
        .map(|polygon| (polygon.province_id.raw(), polygon.vertices.as_slice()))
        .collect::<Vec<_>>();
    let intervals = crate::math::shared_quantized_edge_intervals(&rings, snap_size)?;
    let mut out = intervals
        .into_iter()
        .map(|interval| PolygonBorderSegment {
            province_a: ProvinceId(interval.owner_a),
            province_b: ProvinceId(interval.owner_b),
            x0: interval.start.0 as f32 * snap_size,
            y0: interval.start.1 as f32 * snap_size,
            x1: interval.end.0 as f32 * snap_size,
            y1: interval.end.1 as f32 * snap_size,
        })
        .collect::<Vec<_>>();
    out.sort_by(|a, b| {
        a.province_a
            .cmp(&b.province_a)
            .then(a.province_b.cmp(&b.province_b))
            .then(a.x0.total_cmp(&b.x0))
            .then(a.y0.total_cmp(&b.y0))
            .then(a.x1.total_cmp(&b.x1))
            .then(a.y1.total_cmp(&b.y1))
    });
    Ok(out)
}
