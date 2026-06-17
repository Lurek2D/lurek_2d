//! This file provides the adjacency abstraction that supplies neighborhood topology to visibility. `visibility/adjacency` delivers the adjacency implementation for the visibility subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! It defines a geometry-agnostic contract so grids, graphs, and region maps share one interface. The file owns or coordinates data contracts including `AdjacencyProvider`, `SimpleAdjacency`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! It enables visibility algorithms to run without coupling to any single world representation. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_neighbor`, `add_bidirectional` stays attached to the local data model and invariants.

/// Trait for providing neighbor information to the visibility system.
/// Implementations can be grid-based, graph-based, or any custom topology.
pub trait AdjacencyProvider {
    /// Get all neighbor region IDs for a given region.
    fn neighbors(&self, region_id: u32) -> Vec<u32>;

    /// Get total region count.
    fn region_count(&self) -> u32;
}

/// Simple adjacency list implementation.
#[derive(Debug, Clone, Default)]
pub struct SimpleAdjacency {
    /// Adjacency list: region_id → list of neighbor IDs.
    neighbors: Vec<Vec<u32>>,
}

impl SimpleAdjacency {
    /// Create a `SimpleAdjacency` with the given number of regions and empty neighbor lists.
    pub fn new(region_count: u32) -> Self {
        Self {
            neighbors: vec![Vec::new(); region_count as usize],
        }
    }

    /// Add `neighbor_id` as a one-way neighbor of `region_id` (does not add the reverse).
    pub fn add_neighbor(&mut self, region_id: u32, neighbor_id: u32) {
        if let Some(list) = self.neighbors.get_mut(region_id as usize) {
            if !list.contains(&neighbor_id) {
                list.push(neighbor_id);
            }
        }
    }

    /// Add a bidirectional neighbor link between regions `a` and `b`.
    pub fn add_bidirectional(&mut self, a: u32, b: u32) {
        self.add_neighbor(a, b);
        self.add_neighbor(b, a);
    }
}

impl AdjacencyProvider for SimpleAdjacency {
    fn neighbors(&self, region_id: u32) -> Vec<u32> {
        self.neighbors
            .get(region_id as usize)
            .cloned()
            .unwrap_or_default()
    }

    fn region_count(&self) -> u32 {
        self.neighbors.len() as u32
    }
}
