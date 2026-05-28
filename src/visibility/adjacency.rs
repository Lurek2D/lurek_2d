//! Adjacency provider trait: defines the neighbor relationship between map regions.
//!
//! - Data type: `SimpleAdjacency`.

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
