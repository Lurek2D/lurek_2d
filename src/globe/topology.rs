//! Region graph structure with adjacency caching, centroid lookup, and edge tags.
//!
//! - Data type: `RegionGraph`.
//! - Type alias: `ProvinceGraph`.

use crate::globe::types::{GlobeError, Region, RegionId, MAX_REGIONS};
use crate::pathfind::graph_path::{find_province_path, ProvinceCostFn, ProvincePath};
use std::collections::{HashMap, HashSet};
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
        let nbrs: Vec<u32> = p.neighbors.iter().map(|r| r.0).collect();
        for ((a, b), tags) in &p.edge_tags {
            self.edge_tags.insert((a.0, b.0), tags.clone());
        }
        self.neighbors.insert(id.0, nbrs);
        self.centroids.insert(id.0, p.centroid);
        self.regions.insert(id, p);
        Ok(())
    }
    /// Remove a region and its cached data, returning the removed region when present.
    pub fn remove(&mut self, id: RegionId) -> Option<Region> {
        let p = self.regions.remove(&id)?;
        self.neighbors.remove(&id.0);
        self.centroids.remove(&id.0);
        self.edge_tags.retain(|(a, b), _| *a != id.0 && *b != id.0);
        Some(p)
    }
    /// Return a shared region reference when the id exists.
    pub fn get(&self, id: RegionId) -> Option<&Region> {
        self.regions.get(&id)
    }
    /// Return a mutable region reference when the id exists.
    pub fn get_mut(&mut self, id: RegionId) -> Option<&mut Region> {
        self.regions.get_mut(&id)
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
        cost_fn: &ProvinceCostFn,
    ) -> Result<ProvincePath, GlobeError> {
        find_province_path(
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
        cost_fn: &ProvinceCostFn,
    ) -> HashMap<RegionId, f64> {
        let raw = crate::pathfind::graph_path::province_reachable(
            &self.neighbors,
            &self.edge_tags,
            start.0,
            max_cost,
            cost_fn,
        );
        raw.into_iter().map(|(k, v)| (RegionId(k), v)).collect()
    }
    /// Return the cached neighbor slice for a region or an empty slice when missing.
    pub fn neighbors_of(&self, id: RegionId) -> Vec<RegionId> {
        self.neighbors.get(&id.0).map(|v| v.iter().map(|&r| RegionId(r)).collect()).unwrap_or_default()
    }
    /// Set a region attribute or return RegionNotFound when the id is missing.
    pub fn set_attr(
        &mut self,
        id: RegionId,
        key: String,
        value: String,
    ) -> Result<(), GlobeError> {
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
    /// Find a region path with the default cost function.
    pub fn find_path_default(&self, from: RegionId, to: RegionId) -> Option<ProvincePath> {
        let cost_fn = ProvinceCostFn::new();
        self.find_path(from, to, &cost_fn).ok()
    }
    /// Return reachable regions with the default cost function.
    pub fn reachable_default(&self, start: RegionId, max_cost: f64) -> HashMap<RegionId, f64> {
        let cost_fn = ProvinceCostFn::new();
        self.reachable(start, max_cost, &cost_fn)
    }
    /// Rebuild all cached adjacency and edge-tag data from the stored regions.
    pub fn rebuild_caches(&mut self) {
        self.neighbors.clear();
        self.centroids.clear();
        self.edge_tags.clear();
        for (id, p) in &self.regions {
            self.neighbors.insert(id.0, p.neighbors.iter().map(|r| r.0).collect());
            self.centroids.insert(id.0, p.centroid);
            for ((a, b), v) in &p.edge_tags {
                self.edge_tags.insert((a.0, b.0), v.clone());
            }
        }
    }
}

/// Backward compatibility alias.
pub type ProvinceGraph = RegionGraph;
