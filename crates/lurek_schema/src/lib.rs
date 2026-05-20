use std::collections::{BTreeMap, BTreeSet};

pub type SchemaError = String;
pub type SchemaResult<T> = Result<T, SchemaError>;

#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub enum FieldType {
    #[default]
    Any,
    String,
    Number,
    Integer,
    Boolean,
    Table,
}

impl FieldType {
    pub fn from_str(value: &str) -> Self {
        match value.trim().to_ascii_lowercase().as_str() {
            "string" => Self::String,
            "number" => Self::Number,
            "integer" => Self::Integer,
            "boolean" => Self::Boolean,
            "table" => Self::Table,
            _ => Self::Any,
        }
    }
}

#[derive(Clone, Debug, Default)]
pub struct FieldRule {
    pub field_type: FieldType,
    pub required: bool,
    pub min: Option<f64>,
    pub max: Option<f64>,
    pub min_len: Option<usize>,
    pub max_len: Option<usize>,
    pub description: String,
    pub enum_values: Vec<String>,
}

#[derive(Clone, Debug, Default)]
pub struct ValidationError {
    pub field: String,
    pub message: String,
}

#[derive(Clone, Debug, Default)]
pub struct ValidationResult {
    pub ok: bool,
    pub errors: Vec<ValidationError>,
}

#[derive(Clone, Debug, Default)]
pub struct Schema {
    pub name: String,
    pub strict: bool,
    pub rules: BTreeMap<String, FieldRule>,
}

impl Schema {
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            strict: false,
            rules: BTreeMap::new(),
        }
    }

    pub fn add_rule(&mut self, field: &str, rule: FieldRule) {
        self.rules.insert(field.to_string(), rule);
    }

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

        if let Some(fields) = table.get("fields").and_then(toml::Value::as_table) {
            for (field_name, field_value) in fields {
                let rule_table = field_value.as_table().ok_or_else(|| {
                    format!("fields.{field_name} must be a TOML table of rule values")
                })?;
                schema.add_rule(field_name, parse_rule(rule_table));
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
        let type_ok = match rule.field_type {
            FieldType::Any => true,
            FieldType::String => actual_type == "string",
            FieldType::Number => matches!(actual_type, "number" | "integer"),
            FieldType::Integer => actual_type == "integer",
            FieldType::Boolean => actual_type == "boolean",
            FieldType::Table => actual_type == "table",
        };

        if !type_ok {
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
