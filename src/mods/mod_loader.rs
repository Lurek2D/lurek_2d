//! Mod loader: discovers, validates, and loads mod packages from the mods directory.
//!
//! - Data type: `ModInstance`.
//! - Enum: `FieldValue`.

use std::collections::HashMap;
use std::path::{Path, PathBuf};

/// A field value in a mod instance.
#[derive(Debug, Clone)]
pub enum FieldValue {
    String(String),
    Integer(i64),
    Float(f64),
    Boolean(bool),
    Array(Vec<FieldValue>),
    Table(HashMap<String, FieldValue>),
}

impl FieldValue {
    /// Return the inner string if this value is `FieldValue::String`, otherwise `None`.
    pub fn as_string(&self) -> Option<&str> {
        match self {
            Self::String(s) => Some(s.as_str()),
            _ => None,
        }
    }

    /// Return the inner integer if this value is `FieldValue::Integer`, otherwise `None`.
    pub fn as_integer(&self) -> Option<i64> {
        match self {
            Self::Integer(n) => Some(*n),
            _ => None,
        }
    }

    /// Return the inner float if this value is `FieldValue::Float`, otherwise `None`.
    pub fn as_float(&self) -> Option<f64> {
        match self {
            Self::Float(f) => Some(*f),
            _ => None,
        }
    }

    /// Return the inner bool if this value is `FieldValue::Boolean`, otherwise `None`.
    pub fn as_bool(&self) -> Option<bool> {
        match self {
            Self::Boolean(b) => Some(*b),
            _ => None,
        }
    }
}

/// A mod instance declaring a game object via the API registry.
#[derive(Debug, Clone)]
pub struct ModInstance {
    /// Mod id.
    pub mod_id: String,
    /// Type name.
    pub type_name: String,
    /// Instance id.
    pub instance_id: String,
    /// Field definitions for this type.
    pub fields: HashMap<String, FieldValue>,
    /// Source file.
    pub source_file: PathBuf,
}

impl ModInstance {
    /// Create a new `ModInstance` with the given mod ID, type name, and instance ID.
    pub fn new(mod_id: impl Into<String>, type_name: impl Into<String>, instance_id: impl Into<String>) -> Self {
        Self {
            mod_id: mod_id.into(),
            type_name: type_name.into(),
            instance_id: instance_id.into(),
            fields: HashMap::new(),
            source_file: PathBuf::new(),
        }
    }

    /// Insert or overwrite a field value by name.
    pub fn set_field(&mut self, name: impl Into<String>, value: FieldValue) {
        self.fields.insert(name.into(), value);
    }

    /// Look up a field value by name; returns `None` if the field does not exist.
    pub fn get_field(&self, name: &str) -> Option<&FieldValue> {
        self.fields.get(name)
    }

    /// Return all fields as a flat `String → String` map for validation against a type schema.
    pub fn field_as_string_map(&self) -> HashMap<String, String> {
        self.fields.iter().map(|(k, v)| {
            let s = match v {
                FieldValue::String(s) => s.clone(),
                FieldValue::Integer(n) => n.to_string(),
                FieldValue::Float(f) => f.to_string(),
                FieldValue::Boolean(b) => b.to_string(),
                _ => "<complex>".to_string(),
            };
            (k.clone(), s)
        }).collect()
    }
}

/// Load mod instances from a TOML content file.
///
/// Expected format:
/// ```toml
/// [[item]]
/// id = "iron_sword"
/// name = "Iron Sword"
/// damage = 10
/// ```
pub fn load_instances_from_toml(mod_id: &str, content: &str, source_file: &Path) -> Vec<ModInstance> {
    let mut instances = Vec::new();
    let mut current_type = String::new();
    let mut current_id = String::new();
    let mut current_fields: HashMap<String, FieldValue> = HashMap::new();

    for line in content.lines() {
        let trimmed = line.trim();

        // Detect [[type]] header
        if trimmed.starts_with("[[") && trimmed.ends_with("]]") {
            // Save previous instance
            if !current_type.is_empty() && !current_id.is_empty() {
                let mut inst = ModInstance::new(mod_id, &current_type, &current_id);
                inst.fields = current_fields.clone();
                inst.source_file = source_file.to_path_buf();
                instances.push(inst);
            }
            current_type = trimmed[2..trimmed.len() - 2].to_string();
            current_id.clear();
            current_fields.clear();
            continue;
        }

        if current_type.is_empty() {
            continue;
        }

        // Parse key = value
        if let Some(eq_pos) = trimmed.find('=') {
            let key = trimmed[..eq_pos].trim().to_string();
            let value_str = trimmed[eq_pos + 1..].trim();
            let value = parse_toml_value(value_str);

            if key == "id" {
                if let FieldValue::String(ref s) = value {
                    current_id = s.clone();
                }
            }
            current_fields.insert(key, value);
        }
    }

    // Save last instance
    if !current_type.is_empty() && !current_id.is_empty() {
        let mut inst = ModInstance::new(mod_id, &current_type, &current_id);
        inst.fields = current_fields;
        inst.source_file = source_file.to_path_buf();
        instances.push(inst);
    }

    instances
}

fn parse_toml_value(s: &str) -> FieldValue {
    // Boolean
    if s == "true" { return FieldValue::Boolean(true); }
    if s == "false" { return FieldValue::Boolean(false); }

    // String
    if s.starts_with('"') && s.ends_with('"') && s.len() >= 2 {
        return FieldValue::String(s[1..s.len() - 1].to_string());
    }
    if s.starts_with('\'') && s.ends_with('\'') && s.len() >= 2 {
        return FieldValue::String(s[1..s.len() - 1].to_string());
    }

    // Integer
    if let Ok(n) = s.parse::<i64>() {
        return FieldValue::Integer(n);
    }

    // Float
    if let Ok(f) = s.parse::<f64>() {
        return FieldValue::Float(f);
    }

    // Default to string
    FieldValue::String(s.to_string())
}
