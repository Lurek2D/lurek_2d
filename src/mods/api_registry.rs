//! Mod API registry: records which `lurek.*` namespaces are available to mod scripts.
//!
//! - Data types: `TypeSchema`, `GameApiRegistry`.
//! - Implementations: `TypeSchema`, `GameApiRegistry`.

use super::api_schema::{AssetRequirement, FieldDef, MethodDef};
use std::collections::HashMap;

/// Schema for a registered game API type.
#[derive(Debug, Clone)]
pub struct TypeSchema {
    /// Unique identifier name.
    pub name: String,
    /// Field definitions for this type.
    pub fields: Vec<FieldDef>,
    /// Method definitions for this type.
    pub methods: Vec<MethodDef>,
    /// Asset paths required by this mod type.
    pub asset_requirements: Vec<AssetRequirement>,
    /// Human-readable description.
    pub description: String,
}

impl TypeSchema {
    /// Create a new `TypeSchema` with the given type name and empty field/method lists.
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            fields: Vec::new(),
            methods: Vec::new(),
            asset_requirements: Vec::new(),
            description: String::new(),
        }
    }

    /// Append a field definition to this type schema.
    pub fn add_field(&mut self, field: FieldDef) {
        self.fields.push(field);
    }

    /// Append a method definition to this type schema.
    pub fn add_method(&mut self, method: MethodDef) {
        self.methods.push(method);
    }

    /// Append an asset requirement declaration to this type schema.
    pub fn add_asset_requirement(&mut self, req: AssetRequirement) {
        self.asset_requirements.push(req);
    }

    /// Return only the fields marked as required in this schema.
    pub fn required_fields(&self) -> Vec<&FieldDef> {
        self.fields.iter().filter(|f| f.required).collect()
    }

    /// Return only the fields not marked as required in this schema.
    pub fn optional_fields(&self) -> Vec<&FieldDef> {
        self.fields.iter().filter(|f| !f.required).collect()
    }
}

/// Registry of game API types that mods can declare instances of.
#[derive(Debug, Clone)]
pub struct GameApiRegistry {
    types: HashMap<String, TypeSchema>,
}

impl GameApiRegistry {
    /// Create a new empty `GameApiRegistry` with no registered type schemas.
    pub fn new() -> Self {
        Self {
            types: HashMap::new(),
        }
    }

    /// Register a new API type schema.
    pub fn register_type(&mut self, schema: TypeSchema) {
        self.types.insert(schema.name.clone(), schema);
    }

    /// Get a registered type schema by name.
    pub fn get_type(&self, name: &str) -> Option<&TypeSchema> {
        self.types.get(name)
    }

    /// Remove and deregister a type schema.
    pub fn unregister_type(&mut self, name: &str) -> bool {
        self.types.remove(name).is_some()
    }

    /// List all registered type names.
    pub fn type_names(&self) -> Vec<&str> {
        self.types.keys().map(|s| s.as_str()).collect()
    }

    /// Validate a set of field values against a type schema.
    pub fn validate_instance(&self, type_name: &str, fields: &HashMap<String, String>) -> Vec<String> {
        let mut errors = Vec::new();

        let schema = match self.types.get(type_name) {
            Some(s) => s,
            None => {
                errors.push(format!("Unknown API type: {type_name}"));
                return errors;
            }
        };

        // Check required fields
        for field in &schema.fields {
            if field.required && !fields.contains_key(&field.name) {
                errors.push(format!("Missing required field: {}", field.name));
            }
        }

        // Check for unknown fields
        for key in fields.keys() {
            if !schema.fields.iter().any(|f| &f.name == key) {
                errors.push(format!("Unknown field: {key}"));
            }
        }

        errors
    }

    /// Return the total number of registered API type schemas.
    pub fn type_count(&self) -> usize {
        self.types.len()
    }
}

impl Default for GameApiRegistry {
    fn default() -> Self {
        Self::new()
    }
}
