//! Owns serialize behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around DefaultsApplied, child_path, item_path, with helpers kept close to their invariants.
//! Defines how schema data is validated, transformed, or stored before neighboring systems use it.
//! Owns serialize behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on schema behavior while Lua registration stays elsewhere.
//! Documents the boundary where serialize code accepts inputs, reports errors, or updates state.
//! Use this file when changing schema defaults, lifecycle handling, validation, or data ownership.

use super::lua_table::SerialValue;
use crate::log_msg;
use crate::runtime::log_messages::{SR07_SCHEMA_PASS, SR08_SCHEMA_FAIL};

/// Report of schema defaults that were merged into a value tree.
#[derive(Debug, Clone, PartialEq)]
pub struct DefaultsApplied {
    /// Patched value with schema defaults merged in.
    pub value: SerialValue,
    /// Field paths that received defaults.
    pub applied_paths: Vec<String>,
}

fn child_path(path: &str, segment: &str) -> String {
    if path == "$" {
        format!("$.{segment}")
    } else {
        format!("{path}.{segment}")
    }
}

fn item_path(path: &str, index: usize) -> String {
    format!("{path}[{index}]")
}

/// Recursively validate a value against a schema node, collecting dotted error paths.
fn validate_collect(
    value: &SerialValue,
    schema: &SerialValue,
    path: &str,
    errors: &mut Vec<String>,
) {
    let schema_map = match schema {
        SerialValue::Map(m) => m,
        _ => {
            errors.push(format!("{path}: schema must be a table"));
            return;
        }
    };

    let required = matches!(schema_map.get("required"), Some(SerialValue::Bool(true)));
    if matches!(value, SerialValue::Null) {
        if required {
            errors.push(format!("{path}: required field is nil"));
        }
        return;
    }

    if let Some(SerialValue::Str(expected_type)) = schema_map.get("type") {
        let type_ok = match expected_type.as_str() {
            "string" => matches!(value, SerialValue::Str(_)),
            "number" => matches!(value, SerialValue::Int(_) | SerialValue::Float(_)),
            "boolean" => matches!(value, SerialValue::Bool(_)),
            "table" => matches!(value, SerialValue::Map(_) | SerialValue::Seq(_)),
            "null" => matches!(value, SerialValue::Null),
            "any" => true,
            other => {
                errors.push(format!("{path}: unknown schema type '{other}'"));
                return;
            }
        };
        if !type_ok {
            errors.push(format!(
                "{path}: expected type '{expected_type}' but got '{}'",
                type_name(value)
            ));
            return;
        }
    }

    if let Some(min) = schema_map.get("min") {
        match (to_f64(min), numeric_f64(value)) {
            (Some(min_f), Some(val_f)) if val_f < min_f => {
                errors.push(format!("{path}: value {val_f} is less than min {min_f}"));
            }
            (None, _) => errors.push(format!("{path}: schema 'min' must be a number")),
            (_, None) => errors.push(format!("{path}: 'min' requires a numeric value")),
            _ => {}
        }
    }

    if let Some(max) = schema_map.get("max") {
        match (to_f64(max), numeric_f64(value)) {
            (Some(max_f), Some(val_f)) if val_f > max_f => {
                errors.push(format!("{path}: value {val_f} is greater than max {max_f}"));
            }
            (None, _) => errors.push(format!("{path}: schema 'max' must be a number")),
            (_, None) => errors.push(format!("{path}: 'max' requires a numeric value")),
            _ => {}
        }
    }

    if let Some(minlen) = schema_map.get("minlen") {
        match (to_usize(minlen), string_len(value)) {
            (Some(min_n), Some(len)) if len < min_n => {
                errors.push(format!(
                    "{path}: string length {len} is less than minlen {min_n}"
                ));
            }
            (None, _) => errors.push(format!(
                "{path}: schema 'minlen' must be a non-negative integer"
            )),
            (_, None) => errors.push(format!("{path}: 'minlen' requires a string value")),
            _ => {}
        }
    }

    if let Some(maxlen) = schema_map.get("maxlen") {
        match (to_usize(maxlen), string_len(value)) {
            (Some(max_n), Some(len)) if len > max_n => {
                errors.push(format!(
                    "{path}: string length {len} is greater than maxlen {max_n}"
                ));
            }
            (None, _) => errors.push(format!(
                "{path}: schema 'maxlen' must be a non-negative integer"
            )),
            (_, None) => errors.push(format!("{path}: 'maxlen' requires a string value")),
            _ => {}
        }
    }

    if let Some(SerialValue::Map(field_schemas)) = schema_map.get("fields") {
        let val_map = match value {
            SerialValue::Map(m) => m,
            _ => {
                errors.push(format!("{path}: 'fields' requires a table value"));
                return;
            }
        };
        for (field_name, field_schema) in field_schemas {
            let child_val = val_map.get(field_name).unwrap_or(&SerialValue::Null);
            validate_collect(
                child_val,
                field_schema,
                &child_path(path, field_name),
                errors,
            );
        }
    }

    if let Some(item_schema) = schema_map.get("items") {
        match value {
            SerialValue::Seq(items) => {
                for (index, item) in items.iter().enumerate() {
                    validate_collect(item, item_schema, &item_path(path, index), errors);
                }
            }
            SerialValue::Map(m) if m.is_empty() => {}
            _ => errors.push(format!("{path}: 'items' requires a sequence (array) value")),
        }
    }
}

/// Return the human-readable type name of a serial value for error reporting.
fn type_name(val: &SerialValue) -> &'static str {
    match val {
        SerialValue::Null => "null",
        SerialValue::Bool(_) => "boolean",
        SerialValue::Int(_) | SerialValue::Float(_) => "number",
        SerialValue::Str(_) => "string",
        SerialValue::Seq(_) => "table",
        SerialValue::Map(_) => "table",
    }
}

/// Extract an f64 from a numeric serial value, returning None for non-numeric types.
fn numeric_f64(val: &SerialValue) -> Option<f64> {
    match val {
        SerialValue::Int(n) => Some(*n as f64),
        SerialValue::Float(f) => Some(*f),
        _ => None,
    }
}

/// Convert a schema numeric literal to f64 for comparison.
fn to_f64(val: &SerialValue) -> Option<f64> {
    match val {
        SerialValue::Int(n) => Some(*n as f64),
        SerialValue::Float(f) => Some(*f),
        _ => None,
    }
}

/// Convert a non-negative integer serial value to usize for length checks.
fn to_usize(val: &SerialValue) -> Option<usize> {
    match val {
        SerialValue::Int(n) if *n >= 0 => Some(*n as usize),
        _ => None,
    }
}

/// Return the byte length of a string serial value, or None if not a string.
fn string_len(val: &SerialValue) -> Option<usize> {
    match val {
        SerialValue::Str(s) => Some(s.len()),
        _ => None,
    }
}

/// Collect all validation errors for a value tree against the provided schema.
pub fn validation_errors(value: &SerialValue, schema: &SerialValue) -> Vec<String> {
    let mut errors = Vec::new();
    validate_collect(value, schema, "$", &mut errors);
    if errors.is_empty() {
        log_msg!(debug, SR07_SCHEMA_PASS);
    } else {
        log_msg!(debug, SR08_SCHEMA_FAIL);
    }
    errors
}

/// Validate a serial value tree against a schema, logging the pass/fail result.
pub fn validate(value: &SerialValue, schema: &SerialValue) -> Result<(), String> {
    let errors = validation_errors(value, schema);
    if errors.is_empty() {
        Ok(())
    } else {
        Err(errors.join("; "))
    }
}

/// Fill missing fields in a value tree with defaults defined in the schema.
pub fn apply_defaults(value: &SerialValue, schema: &SerialValue) -> Result<SerialValue, String> {
    Ok(apply_defaults_with_report(value, schema)?.value)
}

/// Fill missing fields and report which default paths were applied.
pub fn apply_defaults_with_report(
    value: &SerialValue,
    schema: &SerialValue,
) -> Result<DefaultsApplied, String> {
    let mut applied_paths = Vec::new();
    let value = apply_defaults_at(value, schema, "$", &mut applied_paths)?;
    Ok(DefaultsApplied {
        value,
        applied_paths,
    })
}

/// Recursively merge schema defaults into a value node, handling nested fields and array items.
fn apply_defaults_at(
    value: &SerialValue,
    schema: &SerialValue,
    path: &str,
    applied_paths: &mut Vec<String>,
) -> Result<SerialValue, String> {
    let schema_map = match schema {
        SerialValue::Map(m) => m,
        _ => return Err("schema must be a table".to_string()),
    };
    if matches!(value, SerialValue::Null) {
        if let Some(default) = schema_map.get("default") {
            applied_paths.push(path.to_string());
            return Ok(default.clone());
        }
        return Ok(SerialValue::Null);
    }

    let mut current = value.clone();
    if let Some(SerialValue::Map(field_schemas)) = schema_map.get("fields") {
        let mut merged = match &current {
            SerialValue::Map(m) => m.clone(),
            _ => return Err("schema 'fields' requires a table value".to_string()),
        };
        for (field_name, field_schema) in field_schemas {
            let existing = merged.get(field_name).cloned().unwrap_or(SerialValue::Null);
            let patched = apply_defaults_at(
                &existing,
                field_schema,
                &child_path(path, field_name),
                applied_paths,
            )?;
            if !matches!(patched, SerialValue::Null) {
                merged.insert(field_name.clone(), patched);
            }
        }
        current = SerialValue::Map(merged);
    }

    if let Some(item_schema) = schema_map.get("items") {
        match &current {
            SerialValue::Seq(items) => {
                let mut out = Vec::with_capacity(items.len());
                for (index, item) in items.iter().enumerate() {
                    out.push(apply_defaults_at(
                        item,
                        item_schema,
                        &item_path(path, index),
                        applied_paths,
                    )?);
                }
                current = SerialValue::Seq(out);
            }
            SerialValue::Map(m) if m.is_empty() => {
                current = SerialValue::Seq(Vec::new());
            }
            _ => return Err("schema 'items' requires a sequence (array) value".to_string()),
        }
    }
    Ok(current)
}
