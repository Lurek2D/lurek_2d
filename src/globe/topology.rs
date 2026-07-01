//! Owns the region topology graph that stores regions, cached neighbors, centroids, and tagged region border edges.
//! Provides insert, remove, mutation, and cache rebuild flows so topology lookups stay coherent after region edits.
//! Delegates route and reachability queries to graph pathfinding while translating results back to RegionId.
//! Acts as the structural boundary between region geometry records and graph-style traversal used by globe gameplay.
//! Also exposes region attrs and edge tags, keeping topology metadata near the adjacency data it qualifies.
//! Open this owner when connectivity, border tags, or region path queries change without altering render policy.

use crate::globe::types::{GlobeError, Region, RegionId, MAX_REGIONS};
use crate::pathfind::graph_path::{find_graph_path, graph_reachable, GraphCostFn, GraphPath};
use std::collections::{HashMap, HashSet};
use std::marker::PhantomData;

#[inline]
fn canonical_edge(a: RegionId, b: RegionId) -> (RegionId, RegionId) {
    if a <= b {
        (a, b)
    } else {
        (b, a)
    }
}

#[inline]
fn wrap_lon_delta(delta: f32) -> f32 {
    ((delta + 180.0).rem_euclid(360.0)) - 180.0
}

#[inline]
fn normalize_lon(lon: f32) -> f32 {
    let wrapped = ((lon + 180.0).rem_euclid(360.0)) - 180.0;
    if wrapped == -180.0 && lon > 0.0 {
        180.0
    } else {
        wrapped
    }
}

/// Cached geographic bounds used to reject most point-in-region tests before polygon work.
#[derive(Debug, Clone, Copy)]
pub(crate) struct RegionGeoBounds {
    min_lat: f32,
    max_lat: f32,
    origin_lon: f32,
    min_lon_delta: f32,
    max_lon_delta: f32,
}

impl RegionGeoBounds {
    /// Return true when the latitude-longitude point lies inside the cached wrapped bounds.
    pub(crate) fn contains(&self, lat_deg: f32, lon_deg: f32) -> bool {
        if lat_deg < self.min_lat || lat_deg > self.max_lat {
            return false;
        }
        let lon_delta = wrap_lon_delta(lon_deg - self.origin_lon);
        lon_delta >= self.min_lon_delta && lon_delta <= self.max_lon_delta
    }
}

/// Derive wrapped geographic candidate bounds from one explicit point set.
pub(crate) fn geo_bounds_from_points(
    origin_lon: f32,
    points: &[(f32, f32)],
) -> Option<RegionGeoBounds> {
    if points.is_empty() {
        return None;
    }
    let mut min_lat = f32::INFINITY;
    let mut max_lat = f32::NEG_INFINITY;
    let mut min_lon_delta = f32::INFINITY;
    let mut max_lon_delta = f32::NEG_INFINITY;
    for (lat, lon) in points {
        min_lat = min_lat.min(*lat);
        max_lat = max_lat.max(*lat);
        let lon_delta = wrap_lon_delta(*lon - origin_lon);
        min_lon_delta = min_lon_delta.min(lon_delta);
        max_lon_delta = max_lon_delta.max(lon_delta);
    }
    Some(RegionGeoBounds {
        min_lat,
        max_lat,
        origin_lon,
        min_lon_delta,
        max_lon_delta,
    })
}

fn derive_bounds_origin_lon(points: &[(f32, f32)], fallback_lon: f32) -> f32 {
    let Some((_, first_lon)) = points.first().copied() else {
        return fallback_lon;
    };
    let mut unwrapped_sum = first_lon;
    let mut previous = first_lon;
    let mut count = 1.0_f32;
    for &(_, lon) in &points[1..] {
        let mut adjusted = lon;
        while adjusted - previous > 180.0 {
            adjusted -= 360.0;
        }
        while adjusted - previous < -180.0 {
            adjusted += 360.0;
        }
        unwrapped_sum += adjusted;
        previous = adjusted;
        count += 1.0;
    }
    normalize_lon(unwrapped_sum / count)
}

/// Derive wrapped geographic candidate bounds from one ordered point set.
pub(crate) fn geo_bounds_from_ordered_points(
    points: &[(f32, f32)],
    fallback_lon: f32,
) -> Option<RegionGeoBounds> {
    let origin_lon = derive_bounds_origin_lon(points, fallback_lon);
    geo_bounds_from_points(origin_lon, points)
}

/// Derive wrapped geographic candidate bounds for one region-like polygon owner.
pub(crate) fn region_geo_bounds(region: &Region) -> Option<RegionGeoBounds> {
    let mut points = region
        .parts
        .iter()
        .flat_map(|part| part.outer.iter().copied())
        .collect::<Vec<_>>();
    if points.is_empty() {
        points = region.vertices.clone();
    }
    geo_bounds_from_ordered_points(&points, region.centroid.1)
}

/// Mutable region guard that rebuilds topology caches after in-place edits.
pub struct RegionMut<'a> {
    graph: *mut RegionGraph,
    region: *mut Region,
    _marker: PhantomData<&'a mut RegionGraph>,
}

impl std::ops::Deref for RegionMut<'_> {
    type Target = Region;

    fn deref(&self) -> &Self::Target {
        // SAFETY: `RegionMut` is only constructed from a unique `&mut RegionGraph` borrow.
        // The stored region pointer remains valid for the lifetime tracked by `_marker`.
        unsafe { &*self.region }
    }
}

impl std::ops::DerefMut for RegionMut<'_> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        // SAFETY: `RegionMut` owns the only mutable borrow of the targeted region while alive.
        unsafe { &mut *self.region }
    }
}

impl Drop for RegionMut<'_> {
    fn drop(&mut self) {
        // SAFETY: `graph` points back to the same uniquely borrowed `RegionGraph` that created
        // this guard, and rebuilding caches only reads stored regions and overwrites cache maps.
        unsafe {
            (*self.graph).rebuild_caches();
        }
    }
}

/// Region graph with cached adjacency, centroids, and edge tags.
#[derive(Debug, Clone, Default)]
pub struct RegionGraph {
    /// Stored regions by id.
    pub regions: HashMap<RegionId, Region>,
    /// Cached neighbor lists by region id.
    neighbors: HashMap<u32, Vec<u32>>,
    /// Cached region centroids by id.
    centroids: HashMap<u32, (f32, f32)>,
    /// Cached edge tags keyed by ordered region id pairs.
    edge_tags: HashMap<(u32, u32), HashSet<String>>,
    /// Cached geographic candidate bounds by region id.
    bounds: HashMap<u32, RegionGeoBounds>,
}
/// Region graph operations: insert, remove, query, pathfind, and cache management.
impl RegionGraph {
    /// Create an empty region graph.
    pub fn new() -> Self {
        Self::default()
    }
    /// Insert a region and update the cached adjacency data.
    pub fn insert(&mut self, p: Region) -> Result<(), GlobeError> {
        if self.regions.len() >= MAX_REGIONS {
            return Err(GlobeError::TooManyRegions);
        }
        let id = p.id;
        if self.regions.contains_key(&id) {
            return Err(GlobeError::LoadError(format!("region {} already exists", id)));
        }
        let nbrs: Vec<u32> = p.neighbors.iter().map(|r| r.0).collect();
        for ((a, b), tags) in &p.edge_tags {
            self.edge_tags.insert((a.0, b.0), tags.clone());
        }
        self.neighbors.insert(id.0, nbrs);
        self.centroids.insert(id.0, p.centroid);
        if let Some(bounds) = region_geo_bounds(&p) {
            self.bounds.insert(id.0, bounds);
        } else {
            self.bounds.remove(&id.0);
        }
        self.regions.insert(id, p);
        Ok(())
    }
    /// Remove a region and its cached data, returning the removed region when present.
    pub fn remove(&mut self, id: RegionId) -> Option<Region> {
        let removed = self.regions.remove(&id)?;
        for region in self.regions.values_mut() {
            region.neighbors.retain(|neighbor| *neighbor != id);
            region.edge_tags.retain(|(a, b), _| *a != id && *b != id);
        }
        self.rebuild_caches();
        Some(removed)
    }
    /// Return a shared region reference when the id exists.
    pub fn get(&self, id: RegionId) -> Option<&Region> {
        self.regions.get(&id)
    }
    /// Return a mutable region reference when the id exists.
    pub fn get_mut(&mut self, id: RegionId) -> Option<RegionMut<'_>> {
        let region = self.regions.get_mut(&id)? as *mut Region;
        Some(RegionMut {
            graph: self as *mut RegionGraph,
            region,
            _marker: PhantomData,
        })
    }
    /// Iterate over all stored regions.
    pub fn iter(&self) -> impl Iterator<Item = &Region> {
        self.regions.values()
    }
    /// Return the number of stored regions.
    pub fn len(&self) -> usize {
        self.regions.len()
    }
    /// Return true when no regions are stored.
    pub fn is_empty(&self) -> bool {
        self.regions.is_empty()
    }
    /// Find a region path or return NoPath when no route exists.
    pub fn find_path(
        &self,
        from: RegionId,
        to: RegionId,
        cost_fn: &GraphCostFn,
    ) -> Result<GraphPath, GlobeError> {
        find_graph_path(
            &self.neighbors,
            &self.centroids,
            &self.edge_tags,
            from.0,
            to.0,
            cost_fn,
        )
        .ok_or(GlobeError::NoPath(from, to))
    }
    /// Return regions reachable within the supplied maximum cost.
    pub fn reachable(
        &self,
        start: RegionId,
        max_cost: f64,
        cost_fn: &GraphCostFn,
    ) -> HashMap<RegionId, f64> {
        let raw = graph_reachable(&self.neighbors, &self.edge_tags, start.0, max_cost, cost_fn);
        raw.into_iter().map(|(k, v)| (RegionId(k), v)).collect()
    }
    /// Return the cached neighbor slice for a region or an empty slice when missing.
    pub fn neighbors_of(&self, id: RegionId) -> Vec<RegionId> {
        self.neighbors
            .get(&id.0)
            .map(|v| v.iter().map(|&r| RegionId(r)).collect())
            .unwrap_or_default()
    }
    /// Return candidate region ids whose cached geographic bounds contain the supplied point.
    pub fn candidate_ids_at(&self, lat_deg: f32, lon_deg: f32) -> Vec<RegionId> {
        let mut out: Vec<RegionId> = self
            .bounds
            .iter()
            .filter_map(|(id, bounds)| bounds.contains(lat_deg, lon_deg).then_some(RegionId(*id)))
            .collect();
        out.sort();
        out
    }
    /// Set a region attribute or return RegionNotFound when the id is missing.
    pub fn set_attr(&mut self, id: RegionId, key: String, value: String) -> Result<(), GlobeError> {
        let p = self
            .regions
            .get_mut(&id)
            .ok_or(GlobeError::RegionNotFound(id))?;
        p.attrs.insert(key, value);
        Ok(())
    }
    /// Return a region attribute as a string slice when it exists.
    pub fn get_attr(&self, id: RegionId, key: &str) -> Option<&str> {
        self.regions.get(&id)?.attrs.get(key).map(String::as_str)
    }
    /// Replace the tag set for an existing edge; return false when the edge does not exist.
    pub fn set_edge_tags(
        &mut self,
        a: RegionId,
        b: RegionId,
        tags: HashSet<String>,
    ) -> Result<bool, GlobeError> {
        if !self.regions.contains_key(&a) {
            return Err(GlobeError::RegionNotFound(a));
        }
        if !self.regions.contains_key(&b) {
            return Err(GlobeError::RegionNotFound(b));
        }
        let connected = self
            .neighbors
            .get(&a.0)
            .is_some_and(|neighbors| neighbors.contains(&b.0))
            || self
                .neighbors
                .get(&b.0)
                .is_some_and(|neighbors| neighbors.contains(&a.0));
        if !connected {
            return Ok(false);
        }
        let edge = canonical_edge(a, b);
        for id in [a, b] {
            if let Some(region) = self.regions.get_mut(&id) {
                if tags.is_empty() {
                    region.edge_tags.remove(&edge);
                } else {
                    region.edge_tags.insert(edge, tags.clone());
                }
            }
        }
        let raw_edge = (edge.0 .0, edge.1 .0);
        if tags.is_empty() {
            self.edge_tags.remove(&raw_edge);
        } else {
            self.edge_tags.insert(raw_edge, tags);
        }
        Ok(true)
    }
    /// Return the tag set for an edge as stored in the cached topology graph.
    pub fn edge_tags(&self, a: RegionId, b: RegionId) -> Vec<String> {
        let edge = canonical_edge(a, b);
        let Some(tags) = self.edge_tags.get(&(edge.0 .0, edge.1 .0)) else {
            return Vec::new();
        };
        let mut out: Vec<String> = tags.iter().cloned().collect();
        out.sort();
        out
    }
    /// Find a region path with the default cost function.
    pub fn find_path_default(&self, from: RegionId, to: RegionId) -> Option<GraphPath> {
        let cost_fn = GraphCostFn::new();
        self.find_path(from, to, &cost_fn).ok()
    }
    /// Return reachable regions with the default cost function.
    pub fn reachable_default(&self, start: RegionId, max_cost: f64) -> HashMap<RegionId, f64> {
        let cost_fn = GraphCostFn::new();
        self.reachable(start, max_cost, &cost_fn)
    }
    /// Rebuild all cached adjacency and edge-tag data from the stored regions.
    pub fn rebuild_caches(&mut self) {
        self.neighbors.clear();
        self.centroids.clear();
        self.edge_tags.clear();
        self.bounds.clear();
        for (id, p) in &self.regions {
            self.neighbors
                .insert(id.0, p.neighbors.iter().map(|r| r.0).collect());
            self.centroids.insert(id.0, p.centroid);
            for ((a, b), v) in &p.edge_tags {
                self.edge_tags.insert((a.0, b.0), v.clone());
            }
            if let Some(bounds) = region_geo_bounds(p) {
                self.bounds.insert(id.0, bounds);
            }
        }
    }
}

/// Backward compatibility alias.
pub type ProvinceGraph = RegionGraph;
