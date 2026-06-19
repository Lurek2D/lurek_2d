//! `src/mods/mod_loader.rs` parses TOML content files into typed `ModInstance` records ready for registry validation.
//! It owns `FieldValue`, `ModContentLoadOptions`, scalar coercion helpers, real TOML decoding, and source-path attachment.
//! Instance bootstrap from content files happens here so manifest decoding stays separate from registration and execution.
//! Complex field values remain structured instead of being flattened into strings during parse time.
//! This file does not manage dependency order or sandbox policy; it only turns content text into structured instances.
//! Read it when TOML parsing, field coercion, instance IDs, or source-file tracking for mods needs to change.

use super::{ModError, ModLimits, ModResult};
use std::collections::HashMap;
use std::path::{Path, PathBuf};

/// Load options used by the mod content TOML parser.
#[derive(Debug, Clone)]
pub struct ModContentLoadOptions {
    /// Maximum raw TOML size in bytes.
    pub max_bytes: usize,
    /// Maximum number of instances accepted from one file.
    pub max_instances: usize,
    /// Maximum fields accepted for one instance.
    pub max_fields: usize,
}

impl Default for ModContentLoadOptions {
    fn default() -> Self {
        Self::from_limits(&ModLimits::default())
    }
}

impl ModContentLoadOptions {
    /// Build loader options from shared mod limits.
    pub fn from_limits(limits: &ModLimits) -> Self {
        Self {
            max_bytes: limits.max_content_bytes,
            max_instances: limits.max_instances,
            max_fields: limits.max_instance_fields,
        }
    }
}

/// A field value in a mod instance.
#[derive(Debug, Clone, PartialEq)]
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
    pub fn new(
        mod_id: impl Into<String>,
        type_name: impl Into<String>,
        instance_id: impl Into<String>,
    ) -> Self {
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

    /// Return all scalar fields as a flat `String -> String` map for legacy callers.
    pub fn field_as_string_map(&self) -> HashMap<String, String> {
        self.fields
            .iter()
            .map(|(k, v)| {
                let s = match v {
                    FieldValue::String(s) => s.clone(),
                    FieldValue::Integer(n) => n.to_string(),
                    FieldValue::Float(f) => f.to_string(),
                    FieldValue::Boolean(b) => b.to_string(),
                    FieldValue::Array(_) | FieldValue::Table(_) => "<complex>".to_string(),
                };
                (k.clone(), s)
            })
            .collect()
    }
}

/// Load mod instances from a TOML content file using default safety limits.
pub fn load_instances_from_toml(
    mod_id: &str,
    content: &str,
    source_file: &Path,
) -> ModResult<Vec<ModInstance>> {
    load_instances_from_toml_with_options(
        mod_id,
        content,
        source_file,
        &ModContentLoadOptions::default(),
    )
}

/// Load mod instances from a TOML content file with explicit limits.
pub fn load_instances_from_toml_with_options(
    mod_id: &str,
    content: &str,
    source_file: &Path,
    options: &ModContentLoadOptions,
) -> ModResult<Vec<ModInstance>> {
    if content.len() > options.max_bytes {
        return Err(ModError::LimitExceeded {
            what: format!("content file '{}'", source_file.display()),
            actual: content.len() as u64,
            max: options.max_bytes as u64,
        });
    }

    let value: toml::Value = content.parse().map_err(|err| ModError::Parse {
        path: source_file.to_path_buf(),
        detail: format!("invalid TOML: {}", err),
    })?;
    let table = value.as_table().ok_or_else(|| ModError::Validation {
        path: Some(source_file.to_path_buf()),
        detail: "content file must contain a TOML table".to_string(),
    })?;

    let mut instances = Vec::new();
    for (type_name, items) in table {
        let array = items.as_array().ok_or_else(|| ModError::Validation {
            path: Some(source_file.to_path_buf()),
            detail: format!("top-level '{}' must be an array of tables", type_name),
        })?;
        for item in array {
            if instances.len() >= options.max_instances {
                return Err(ModError::LimitExceeded {
                    what: format!("content instances in '{}'", source_file.display()),
                    actual: (instances.len() + 1) as u64,
                    max: options.max_instances as u64,
                });
            }
            let item_table = item.as_table().ok_or_else(|| ModError::Validation {
                path: Some(source_file.to_path_buf()),
                detail: format!("entry in '{}' must be a table", type_name),
            })?;
            if item_table.len() > options.max_fields {
                return Err(ModError::LimitExceeded {
                    what: format!("fields for '{}'", type_name),
                    actual: item_table.len() as u64,
                    max: options.max_fields as u64,
                });
            }
            let instance_id = item_table
                .get("id")
                .and_then(|value| value.as_str())
                .ok_or_else(|| ModError::Validation {
                    path: Some(source_file.to_path_buf()),
                    detail: format!("'{}.id' must be a string", type_name),
                })?;
            let mut instance = ModInstance::new(mod_id, type_name, instance_id);
            instance.source_file = source_file.to_path_buf();
            for (field_name, value) in item_table {
                instance.set_field(
                    field_name.clone(),
                    convert_value(value, source_file, type_name, field_name)?,
                );
            }
            instances.push(instance);
        }
    }

    Ok(instances)
}

fn convert_value(
    value: &toml::Value,
    source_file: &Path,
    type_name: &str,
    field_name: &str,
) -> ModResult<FieldValue> {
    match value {
        toml::Value::String(text) => Ok(FieldValue::String(text.clone())),
        toml::Value::Integer(number) => Ok(FieldValue::Integer(*number)),
        toml::Value::Float(number) => Ok(FieldValue::Float(*number)),
        toml::Value::Boolean(flag) => Ok(FieldValue::Boolean(*flag)),
        toml::Value::Array(values) => values
            .iter()
            .map(|item| convert_value(item, source_file, type_name, field_name))
            .collect::<ModResult<Vec<_>>>()
            .map(FieldValue::Array),
        toml::Value::Table(entries) => entries
            .iter()
            .map(|(key, entry)| {
                convert_value(entry, source_file, type_name, key)
                    .map(|converted| (key.clone(), converted))
            })
            .collect::<ModResult<HashMap<_, _>>>()
            .map(FieldValue::Table),
        toml::Value::Datetime(_) => Err(ModError::Validation {
            path: Some(source_file.to_path_buf()),
            detail: format!(
                "unsupported TOML datetime for '{}.{}'; use string, number, boolean, array, or table",
                type_name, field_name
            ),
        }),
    }
}
