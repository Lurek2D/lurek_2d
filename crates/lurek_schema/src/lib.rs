//! Shared schema and contract types used by docs, mods, and validator.
//! Keep value-shape primitives here so higher-level modules reuse one contract language.
//! Schema validation for plain key-value data also lives here because docs tooling already depends on it.

use std::collections::{BTreeMap, BTreeSet};

/// String-based schema error used by lightweight schema helpers.
pub type SchemaError = String;
/// Result alias returned by schema parsing helpers.
pub type SchemaResult<T> = Result<T, SchemaError>;

/// Field type used by shared schema rules and mod API contracts.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub enum FieldType {
    /// Accept any value type.
    #[default]
    Any,
    /// Accept a UTF-8 string value.
    String,
    /// Accept any numeric value.
    Number,
    /// Accept a float-like numeric value.
    Float,
    /// Accept an integer value.
    Integer,
    /// Accept a boolean value.
    Boolean,
    /// Accept a table value.
    Table,
    /// Accept a callable function value.
    Function,
    /// Accept userdata identified by its public type name.
    Userdata(String),
    /// Accept either nil or the wrapped value type.
    Optional(Box<FieldType>),
    /// Accept an array-like table containing the wrapped value type.
    Array(Box<FieldType>),
}

impl FieldType {
    /// Parse a shared field type from a string descriptor.
    pub fn from_str(value: &str) -> Self {
        Self::from_name(value)
    }

    /// Parse a shared field type from a string descriptor.
    pub fn from_name(value: &str) -> Self {
        let trimmed = value.trim();
        if let Some(inner) = trimmed.strip_suffix('?') {
            return Self::Optional(Box::new(Self::from_name(inner)));
        }
        if let Some(inner) = trimmed.strip_suffix("[]") {
            return Self::Array(Box::new(Self::from_name(inner)));
        }

        match trimmed.to_ascii_lowercase().as_str() {
            "string" | "str" => Self::String,
            "number" => Self::Number,
            "float" => Self::Float,
            "integer" | "int" => Self::Integer,
            "boolean" | "bool" => Self::Boolean,
            "table" => Self::Table,
            "function" | "fn" => Self::Function,
            "any" => Self::Any,
            other => Self::Userdata(other.to_string()),
        }
    }

    /// Return the canonical string representation of this field type.
    pub fn as_str(&self) -> String {
        match self {
            Self::Any => "any".to_string(),
            Self::String => "string".to_string(),
            Self::Number => "number".to_string(),
            Self::Float => "float".to_string(),
            Self::Integer => "integer".to_string(),
            Self::Boolean => "boolean".to_string(),
            Self::Table => "table".to_string(),
            Self::Function => "function".to_string(),
            Self::Userdata(name) => name.clone(),
            Self::Optional(inner) => format!("{}?", inner.as_str()),
            Self::Array(inner) => format!("{}[]", inner.as_str()),
        }
    }

    /// Return true when this field type is safe for config-schema parsing.
    pub fn is_known_config_type(&self) -> bool {
        match self {
            Self::Any
            | Self::String
            | Self::Number
            | Self::Float
            | Self::Integer
            | Self::Boolean
            | Self::Table => true,
            Self::Optional(inner) | Self::Array(inner) => inner.is_known_config_type(),
            Self::Function | Self::Userdata(_) => false,
        }
    }

    /// Parse a config-schema type hint and reject unsupported runtime-only variants.
    pub fn parse_config_type_name(value: &str) -> SchemaResult<Self> {
        let parsed = Self::from_name(value);
        if parsed.is_known_config_type() {
            Ok(parsed)
        } else {
            Err(format!("unsupported config schema type '{}'", value))
        }
    }
}

/// Rule describing one field inside a simple schema validator.
#[derive(Clone, Debug, Default)]
pub struct FieldRule {
    /// Expected field type.
    pub field_type: FieldType,
    /// Whether the field is required.
    pub required: bool,
    /// Optional numeric minimum.
    pub min: Option<f64>,
    /// Optional numeric maximum.
    pub max: Option<f64>,
    /// Optional minimum string length.
    pub min_len: Option<usize>,
    /// Optional maximum string length.
    pub max_len: Option<usize>,
    /// Human-readable description.
    pub description: String,
    /// Allowed enum values for string-like fields.
    pub enum_values: Vec<String>,
}

/// Validation error emitted by `Schema`.
#[derive(Clone, Debug, Default)]
pub struct ValidationError {
    /// Field name that failed validation.
    pub field: String,
    /// Human-readable validation message.
    pub message: String,
}

/// Validation result emitted by `Schema`.
#[derive(Clone, Debug, Default)]
pub struct ValidationResult {
    /// True when no validation errors were recorded.
    pub ok: bool,
    /// Collected validation errors.
    pub errors: Vec<ValidationError>,
}

/// Shared simple schema used by docs and tooling validations.
#[derive(Clone, Debug, Default)]
pub struct Schema {
    /// Schema display name.
    pub name: String,
    /// Whether unknown fields are rejected.
    pub strict: bool,
    /// Field rules keyed by field name.
    pub rules: BTreeMap<String, FieldRule>,
}

impl Schema {
    /// Create an empty schema with the supplied display name.
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            strict: false,
            rules: BTreeMap::new(),
        }
    }

    /// Add or replace one field rule.
    pub fn add_rule(&mut self, field: &str, rule: FieldRule) {
        self.rules.insert(field.to_string(), rule);
    }

    /// Validate `(field, type, value)` tuples against this schema.
    pub fn validate_pairs(&self, fields: &[(String, &'static str, String)]) -> ValidationResult {
        let mut errors = Vec::new();
        let provided: BTreeMap<&str, (&'static str, &str)> = fields
            .iter()
            .map(|(field, field_type, value)| (field.as_str(), (*field_type, value.as_str())))
            .collect();

        for (field, rule) in &self.rules {
            match provided.get(field.as_str()) {
                Some((actual_type, value)) => {
                    self.validate_type(field, actual_type, rule, &mut errors);
                    self.validate_numeric_bounds(field, actual_type, value, rule, &mut errors);
                    self.validate_length_bounds(field, actual_type, value, rule, &mut errors);
                    self.validate_enum(field, value, rule, &mut errors);
                }
                None if rule.required => errors.push(ValidationError {
                    field: field.clone(),
                    message: format!("{field} is required"),
                }),
                None => {}
            }
        }

        if self.strict {
            let expected: BTreeSet<&str> = self.rules.keys().map(|key| key.as_str()).collect();
            for field in provided.keys() {
                if !expected.contains(field) {
                    errors.push(ValidationError {
                        field: (*field).to_string(),
                        message: format!("{field} is not declared in schema {}", self.name),
                    });
                }
            }
        }

        ValidationResult {
            ok: errors.is_empty(),
            errors,
        }
    }

    /// Parse a schema from TOML text.
    pub fn from_toml(toml_text: &str) -> SchemaResult<Self> {
        let value: toml::Value = toml::from_str(toml_text).map_err(|err| err.to_string())?;
        let table = value
            .as_table()
            .ok_or_else(|| "schema TOML must be a table".to_string())?;

        let name = table
            .get("name")
            .and_then(toml::Value::as_str)
            .unwrap_or("schema");
        let strict = table
            .get("strict")
            .and_then(toml::Value::as_bool)
            .unwrap_or(false);

        let mut schema = Schema::new(name);
        schema.strict = strict;

        for section_name in ["fields", "rules"] {
            if let Some(fields) = table.get(section_name).and_then(toml::Value::as_table) {
                for (field_name, field_value) in fields {
                    let rule_table = field_value.as_table().ok_or_else(|| {
                        format!("{section_name}.{field_name} must be a TOML table of rule values")
                    })?;
                    schema.add_rule(field_name, parse_rule(rule_table));
                }
            }
        }

        Ok(schema)
    }

    fn validate_type(
        &self,
        field: &str,
        actual_type: &'static str,
        rule: &FieldRule,
        errors: &mut Vec<ValidationError>,
    ) {
        if !field_type_matches(&rule.field_type, actual_type) {
            errors.push(ValidationError {
                field: field.to_string(),
                message: format!(
                    "{field} expected {:?} but got {}",
                    rule.field_type, actual_type
                ),
            });
        }
    }

    fn validate_numeric_bounds(
        &self,
        field: &str,
        actual_type: &'static str,
        value: &str,
        rule: &FieldRule,
        errors: &mut Vec<ValidationError>,
    ) {
        if rule.min.is_none() && rule.max.is_none() {
            return;
        }
        if !matches!(actual_type, "number" | "integer") {
            errors.push(ValidationError {
                field: field.to_string(),
                message: format!("{field} min/max requires a numeric value"),
            });
            return;
        }
        let parsed = match value.parse::<f64>() {
            Ok(number) => number,
            Err(_) => {
                errors.push(ValidationError {
                    field: field.to_string(),
                    message: format!("{field} value '{value}' is not numeric"),
                });
                return;
            }
        };
        if let Some(min) = rule.min {
            if parsed < min {
                errors.push(ValidationError {
                    field: field.to_string(),
                    message: format!("{field} must be >= {min}"),
                });
            }
        }
        if let Some(max) = rule.max {
            if parsed > max {
                errors.push(ValidationError {
                    field: field.to_string(),
                    message: format!("{field} must be <= {max}"),
                });
            }
        }
    }

    fn validate_length_bounds(
        &self,
        field: &str,
        actual_type: &'static str,
        value: &str,
        rule: &FieldRule,
        errors: &mut Vec<ValidationError>,
    ) {
        if rule.min_len.is_none() && rule.max_len.is_none() {
            return;
        }
        if actual_type != "string" {
            errors.push(ValidationError {
                field: field.to_string(),
                message: format!("{field} minLen/maxLen requires a string value"),
            });
            return;
        }
        let len = value.chars().count();
        if let Some(min_len) = rule.min_len {
            if len < min_len {
                errors.push(ValidationError {
                    field: field.to_string(),
                    message: format!("{field} length must be >= {min_len}"),
                });
            }
        }
        if let Some(max_len) = rule.max_len {
            if len > max_len {
                errors.push(ValidationError {
                    field: field.to_string(),
                    message: format!("{field} length must be <= {max_len}"),
                });
            }
        }
    }

    fn validate_enum(
        &self,
        field: &str,
        value: &str,
        rule: &FieldRule,
        errors: &mut Vec<ValidationError>,
    ) {
        if rule.enum_values.is_empty() {
            return;
        }
        if !rule.enum_values.iter().any(|candidate| candidate == value) {
            errors.push(ValidationError {
                field: field.to_string(),
                message: format!("{field} must be one of {}", rule.enum_values.join(", ")),
            });
        }
    }
}

/// Shared field definition used by mod API schemas.
#[derive(Clone, Debug, Default)]
pub struct FieldDef {
    /// Field name.
    pub name: String,
    /// Field type.
    pub field_type: FieldType,
    /// Whether the field is required.
    pub required: bool,
    /// Optional default value serialized as text.
    pub default_value: Option<String>,
    /// Human-readable description.
    pub description: String,
}

impl FieldDef {
    /// Create a required field definition.
    pub fn new(name: impl Into<String>, field_type: FieldType) -> Self {
        Self {
            name: name.into(),
            field_type,
            required: true,
            default_value: None,
            description: String::new(),
        }
    }

    /// Mark this field as optional.
    pub fn optional(mut self) -> Self {
        self.required = false;
        self
    }

    /// Attach a default value and mark the field optional.
    pub fn with_default(mut self, value: impl Into<String>) -> Self {
        self.default_value = Some(value.into());
        self.required = false;
        self
    }

    /// Attach a human-readable description.
    pub fn with_description(mut self, description: impl Into<String>) -> Self {
        self.description = description.into();
        self
    }
}

/// Shared method definition used by mod API schemas.
#[derive(Clone, Debug, Default)]
pub struct MethodDef {
    /// Method name.
    pub name: String,
    /// Ordered parameter definitions.
    pub params: Vec<FieldDef>,
    /// Optional return type.
    pub returns: Option<FieldType>,
    /// Human-readable description.
    pub description: String,
}

impl MethodDef {
    /// Create a new method definition with no parameters.
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            params: Vec::new(),
            returns: None,
            description: String::new(),
        }
    }

    /// Append one parameter definition.
    pub fn with_param(mut self, param: FieldDef) -> Self {
        self.params.push(param);
        self
    }

    /// Set the return type.
    pub fn with_return(mut self, field_type: FieldType) -> Self {
        self.returns = Some(field_type);
        self
    }

    /// Attach a human-readable description.
    pub fn with_description(mut self, description: impl Into<String>) -> Self {
        self.description = description.into();
        self
    }
}

/// Shared asset requirement used by mod API schemas.
#[derive(Clone, Debug, Default)]
pub struct AssetRequirement {
    /// Field name that references the asset.
    pub field_name: String,
    /// Asset kind label.
    pub asset_type: String,
    /// Whether the asset must exist before activation.
    pub must_exist: bool,
}

fn field_type_matches(expected: &FieldType, actual_type: &'static str) -> bool {
    match expected {
        FieldType::Any => true,
        FieldType::String => actual_type == "string",
        FieldType::Number | FieldType::Float => matches!(actual_type, "number" | "integer"),
        FieldType::Integer => actual_type == "integer",
        FieldType::Boolean => actual_type == "boolean",
        FieldType::Table | FieldType::Array(_) => actual_type == "table",
        FieldType::Function => actual_type == "function",
        FieldType::Userdata(_) => actual_type == "userdata",
        FieldType::Optional(inner) => {
            actual_type == "nil" || field_type_matches(inner, actual_type)
        }
    }
}

fn parse_rule(rule_table: &toml::map::Map<String, toml::Value>) -> FieldRule {
    let enum_values = rule_table
        .get("enum")
        .and_then(toml::Value::as_array)
        .map(|entries| {
            entries
                .iter()
                .filter_map(toml::Value::as_str)
                .map(ToOwned::to_owned)
                .collect::<Vec<_>>()
        })
        .unwrap_or_default();

    FieldRule {
        field_type: rule_table
            .get("type")
            .and_then(toml::Value::as_str)
            .map(FieldType::from_str)
            .unwrap_or_default(),
        required: rule_table
            .get("required")
            .and_then(toml::Value::as_bool)
            .unwrap_or(false),
        min: rule_table.get("min").and_then(toml_number_to_f64),
        max: rule_table.get("max").and_then(toml_number_to_f64),
        min_len: rule_table
            .get("minLen")
            .and_then(toml::Value::as_integer)
            .and_then(|value| usize::try_from(value).ok()),
        max_len: rule_table
            .get("maxLen")
            .and_then(toml::Value::as_integer)
            .and_then(|value| usize::try_from(value).ok()),
        description: rule_table
            .get("description")
            .and_then(toml::Value::as_str)
            .unwrap_or_default()
            .to_string(),
        enum_values,
    }
}

fn toml_number_to_f64(value: &toml::Value) -> Option<f64> {
    value
        .as_float()
        .or_else(|| value.as_integer().map(|number| number as f64))
}
