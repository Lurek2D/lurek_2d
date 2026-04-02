//! Province improvements (static) and movable map objects (armies, fleets).
//!
//! Improvements are permanent structures placed in a province (castle, farm,
//! road). Map objects are movable entities (army, fleet, merchant) with a
//! current province and position.

use std::collections::HashMap;

use crate::math::Vec2;

use super::properties::ProvinceValue;

/// A static improvement placed in a province (castle, farm, road, etc.).
#[derive(Debug, Clone)]
pub struct Improvement {
    /// Unique identifier for this improvement.
    pub id: u64,
    /// Type name identifying the improvement class (e.g., "castle", "farm").
    pub type_name: String,
    /// Province this improvement belongs to.
    pub province_id: u32,
    /// World position within the province.
    pub position: Vec2,
    /// Arbitrary key-value properties.
    pub properties: HashMap<String, ProvinceValue>,
}

/// A movable object on the map (army, fleet, merchant, etc.).
#[derive(Debug, Clone)]
pub struct MapObject {
    /// Unique identifier for this object.
    pub id: u64,
    /// Type name identifying the object class (e.g., "army", "fleet").
    pub type_name: String,
    /// Province this object is currently in.
    pub province_id: u32,
    /// World position of the object.
    pub position: Vec2,
    /// Arbitrary key-value properties.
    pub properties: HashMap<String, ProvinceValue>,
}

/// Manages all improvements and movable objects on the province map.
#[derive(Debug, Clone)]
pub struct ObjectManager {
    improvements: HashMap<u64, Improvement>,
    objects: HashMap<u64, MapObject>,
    next_id: u64,
}

impl Default for ObjectManager {
    fn default() -> Self {
        Self::new()
    }
}

impl ObjectManager {
    /// Create an empty object manager.
    pub fn new() -> Self {
        Self {
            improvements: HashMap::new(),
            objects: HashMap::new(),
            next_id: 1,
        }
    }

    /// Add a static improvement to a province. Returns the assigned ID.
    pub fn add_improvement(
        &mut self,
        province_id: u32,
        type_name: impl Into<String>,
        position: Vec2,
    ) -> u64 {
        let id = self.next_id;
        self.next_id += 1;
        self.improvements.insert(
            id,
            Improvement {
                id,
                type_name: type_name.into(),
                province_id,
                position,
                properties: HashMap::new(),
            },
        );
        id
    }

    /// Remove an improvement by ID. Returns `true` if it existed.
    pub fn remove_improvement(&mut self, id: u64) -> bool {
        self.improvements.remove(&id).is_some()
    }

    /// Get an improvement by ID.
    pub fn get_improvement(&self, id: u64) -> Option<&Improvement> {
        self.improvements.get(&id)
    }

    /// Get all improvements in a specific province.
    pub fn improvements_in_province(&self, province_id: u32) -> Vec<&Improvement> {
        self.improvements
            .values()
            .filter(|imp| imp.province_id == province_id)
            .collect()
    }

    /// Add a movable object to a province. Returns the assigned ID.
    pub fn add_object(
        &mut self,
        province_id: u32,
        type_name: impl Into<String>,
        position: Vec2,
    ) -> u64 {
        let id = self.next_id;
        self.next_id += 1;
        self.objects.insert(
            id,
            MapObject {
                id,
                type_name: type_name.into(),
                province_id,
                position,
                properties: HashMap::new(),
            },
        );
        id
    }

    /// Remove a movable object by ID. Returns `true` if it existed.
    pub fn remove_object(&mut self, id: u64) -> bool {
        self.objects.remove(&id).is_some()
    }

    /// Get a movable object by ID.
    pub fn get_object(&self, id: u64) -> Option<&MapObject> {
        self.objects.get(&id)
    }

    /// Get a mutable reference to a movable object by ID.
    pub fn get_object_mut(&mut self, id: u64) -> Option<&mut MapObject> {
        self.objects.get_mut(&id)
    }

    /// Move an object to a different province and position.
    ///
    /// Returns `true` if the object exists and was moved, `false` otherwise.
    pub fn move_object(&mut self, id: u64, target_province: u32, position: Vec2) -> bool {
        if let Some(obj) = self.objects.get_mut(&id) {
            obj.province_id = target_province;
            obj.position = position;
            true
        } else {
            false
        }
    }

    /// Get all movable objects in a specific province.
    pub fn objects_in_province(&self, province_id: u32) -> Vec<&MapObject> {
        self.objects
            .values()
            .filter(|obj| obj.province_id == province_id)
            .collect()
    }

    /// Iterate over all movable objects.
    pub fn all_objects(&self) -> impl Iterator<Item = &MapObject> {
        self.objects.values()
    }

    /// Iterate over all improvements.
    pub fn all_improvements(&self) -> impl Iterator<Item = &Improvement> {
        self.improvements.values()
    }
}
