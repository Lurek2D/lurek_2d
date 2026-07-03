//! Owns the ecs object model implementation for the ecs subsystem and keeps related runtime rules local here.
//! Keeps entity state, object models, and graph boundaries ownership so helpers stay close to invariants this file updates.
//! Defines how ecs object model data is validated, transformed, or stored before neighboring systems consume it.
//! Separates ecs object model behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where ecs code accepts inputs, reports errors, allocates state, or emits outputs.

use std::collections::{HashMap, HashSet};

/// Declarative class metadata used by the Lua-facing ECS object model.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ClassMeta {
    /// Stable class name used by `lurek.ecs.newObject` and `isA` checks.
    pub name: String,
    /// Parent classes in precedence order; earlier parents win over later parents.
    pub parents: Vec<String>,
    /// Class tags copied to new objects unless explicit object tags override them.
    pub tags: Vec<String>,
}

impl ClassMeta {
    /// Create class metadata from a name, parent list, and tag list.
    pub fn new(name: &str, parents: Vec<String>, tags: Vec<String>) -> Self {
        Self {
            name: name.to_string(),
            parents,
            tags,
        }
    }
}

/// Stores global ECS class metadata and object id membership for one Lua VM.
#[derive(Debug, Default)]
pub struct ObjectModel {
    classes: HashMap<String, ClassMeta>,
    object_classes: HashMap<u64, String>,
    next_object_id: u64,
}

impl ObjectModel {
    /// Create an empty object model with no classes or live object ids.
    pub fn new() -> Self {
        Self {
            classes: HashMap::new(),
            object_classes: HashMap::new(),
            next_object_id: 1,
        }
    }

    /// Define or replace one class. Existing object ids keep their class names.
    pub fn define_class(&mut self, meta: ClassMeta) {
        self.classes.insert(meta.name.clone(), meta);
    }

    /// Return true when a class name is defined.
    pub fn has_class(&self, name: &str) -> bool {
        self.classes.contains_key(name)
    }

    /// Return class metadata by name.
    pub fn get_class(&self, name: &str) -> Option<&ClassMeta> {
        self.classes.get(name)
    }

    /// Return class names in deterministic alphabetical order.
    pub fn class_names(&self) -> Vec<String> {
        let mut names: Vec<String> = self.classes.keys().cloned().collect();
        names.sort();
        names
    }

    /// Remove every class definition.
    pub fn clear_classes(&mut self) {
        self.classes.clear();
    }

    /// Allocate a new object id and associate it with a class name.
    pub fn register_object(&mut self, class_name: &str) -> u64 {
        let id = self.next_object_id;
        self.next_object_id = self.next_object_id.saturating_add(1).max(1);
        self.object_classes.insert(id, class_name.to_string());
        id
    }

    /// Return true when an object id is currently live.
    pub fn has_object(&self, id: u64) -> bool {
        self.object_classes.contains_key(&id)
    }

    /// Return the class name associated with an object id.
    pub fn object_class(&self, id: u64) -> Option<&str> {
        self.object_classes.get(&id).map(|s| s.as_str())
    }

    /// Return live object ids in ascending order.
    pub fn object_ids(&self) -> Vec<u64> {
        let mut ids: Vec<u64> = self.object_classes.keys().copied().collect();
        ids.sort();
        ids
    }

    /// Remove an object id and return whether it existed.
    pub fn destroy_object(&mut self, id: u64) -> bool {
        self.object_classes.remove(&id).is_some()
    }

    /// Remove all object ids while preserving class definitions.
    pub fn clear_objects(&mut self) {
        self.object_classes.clear();
    }

    /// Return a parent-first class linearization ending with `class_name`.
    ///
    /// Earlier parents are traversed first, duplicate ancestors are emitted once,
    /// and unknown parents are skipped so scripts can define mixins incrementally.
    pub fn linearization(&self, class_name: &str) -> Vec<String> {
        let mut out = Vec::new();
        let mut visiting = HashSet::new();
        let mut emitted = HashSet::new();
        self.linearize_into(class_name, &mut visiting, &mut emitted, &mut out);
        out
    }

    fn linearize_into(
        &self,
        class_name: &str,
        visiting: &mut HashSet<String>,
        emitted: &mut HashSet<String>,
        out: &mut Vec<String>,
    ) {
        if emitted.contains(class_name) || !visiting.insert(class_name.to_string()) {
            return;
        }
        if let Some(meta) = self.classes.get(class_name) {
            for parent in &meta.parents {
                self.linearize_into(parent, visiting, emitted, out);
            }
        }
        visiting.remove(class_name);
        if emitted.insert(class_name.to_string()) {
            out.push(class_name.to_string());
        }
    }

    /// Return true when `class_name` is or inherits from `candidate`.
    pub fn class_is_a(&self, class_name: &str, candidate: &str) -> bool {
        self.linearization(class_name)
            .iter()
            .any(|name| name == candidate)
    }
}
