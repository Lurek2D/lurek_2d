//! Generic province map implementation.
//! Provides data structures for provinces, adjacency and ownership.

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
