//! Province graph data structure storing named territorial regions with ownership, neighbor adjacency lists enabling territorial strategy gameplay.
//! Supports dynamic owner assignment and neighbor linking enabling territorial mechanics like conquest, inheritance, and vassal relationships.
//! Provides lookup, iteration, and modification methods for managing province territories and diplomatic relationships during campaign gameplay.

use std::collections::HashMap;

#[derive(Debug, Clone, Default)]
pub struct Province {
    pub id: u32,
    pub name: String,
    pub owner: Option<String>,
    pub neighbors: Vec<u32>,
}

#[derive(Debug, Default, Clone)]
pub struct ProvinceMap {
    pub provinces: HashMap<u32, Province>,
}

impl ProvinceMap {
    pub fn new() -> Self { Self::default() }
    pub fn add_province(&mut self, id: u32, name: String) {
        self.provinces.insert(id, Province { id, name, owner: None, neighbors: Vec::new() });
    }
    pub fn set_owner(&mut self, id: u32, owner: String) {
        if let Some(p) = self.provinces.get_mut(&id) {
            p.owner = Some(owner);
        }
    }
    pub fn add_neighbor(&mut self, id: u32, neighbor_id: u32) {
        if let Some(p) = self.provinces.get_mut(&id) {
            p.neighbors.push(neighbor_id);
        }
    }
    pub fn get_province(&self, id: u32) -> Option<&Province> { self.provinces.get(&id) }
}
