//! Province graph data structure storing named territorial regions with ownership, neighbor adjacency lists enabling territorial strategy gameplay.
//! Supports dynamic owner assignment and neighbor linking enabling territorial mechanics like conquest, inheritance, and vassal relationships.
//! Provides lookup, iteration, and modification methods for managing province territories and diplomatic relationships during campaign gameplay.

use std::collections::HashMap;

#[derive(Debug, Clone, Default)]
/// Territory record storing identity, display name, current owner, and neighboring province IDs.
pub struct Province {
    /// Stable numeric province identifier used by adjacency and lookup APIs.
    pub id: u32,
    /// Human-readable province name shown in campaign or map UI.
    pub name: String,
    /// Optional owner or faction identifier currently controlling the province.
    pub owner: Option<String>,
    /// Adjacent province IDs used for movement, borders, and territorial graph traversal.
    pub neighbors: Vec<u32>,
}

#[derive(Debug, Default, Clone)]
/// Mutable province graph keyed by province ID with owner assignment and neighbor-link helpers.
pub struct ProvinceMap {
    /// All known provinces keyed by their stable numeric identifier.
    pub provinces: HashMap<u32, Province>,
}

impl ProvinceMap {
    /// Creates an empty province map.
    pub fn new() -> Self {
        Self::default()
    }

    /// Inserts or replaces a province with no owner and no neighbors.
    pub fn add_province(&mut self, id: u32, name: String) {
        self.provinces.insert(
            id,
            Province {
                id,
                name,
                owner: None,
                neighbors: Vec::new(),
            },
        );
    }

    /// Assigns an owner to an existing province.
    pub fn set_owner(&mut self, id: u32, owner: String) {
        if let Some(p) = self.provinces.get_mut(&id) {
            p.owner = Some(owner);
        }
    }

    /// Adds a directed neighbor edge from one province to another.
    pub fn add_neighbor(&mut self, id: u32, neighbor_id: u32) {
        if let Some(p) = self.provinces.get_mut(&id) {
            p.neighbors.push(neighbor_id);
        }
    }

    /// Returns a province by id if it exists.
    pub fn get_province(&self, id: u32) -> Option<&Province> {
        self.provinces.get(&id)
    }
}
