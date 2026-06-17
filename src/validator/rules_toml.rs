//! This file provides TOML-driven rule loading for data-defined validation extensions. `validator/rules_toml` delivers the rules toml implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! It parses rule entries into runtime rule objects used by the validation engine. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! It supports loading from files and raw TOML text for flexible integration points. Public callable behavior is centered on `load_rules_from_toml`, `load_rules_from_file`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! It enables configurable policy checks without adding new compiled rule types. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

use super::report::Severity;
use super::rules_lua::LuaPatternRule;
use std::path::Path;

/// Load validation rules from a TOML rule file.
///
/// Expected format:
/// ```toml
/// [[rule]]
/// id = "no-print"
/// pattern = "print("
/// message = "Use lurek.log instead of print()"
/// severity = "warning"
/// invert = false
/// ```
pub fn load_rules_from_toml(content: &str) -> Vec<LuaPatternRule> {
    let mut rules = Vec::new();

    // Simple TOML parser for [[rule]] sections
    let mut current_id = String::new();
    let mut current_pattern = String::new();
    let mut current_message = String::new();
    let mut current_severity = Severity::Warning;
    let mut current_invert = false;
    let mut in_rule = false;

    for line in content.lines() {
        let trimmed = line.trim();

        if trimmed == "[[rule]]" {
            if in_rule && !current_id.is_empty() && !current_pattern.is_empty() {
                let mut rule = LuaPatternRule::new(
                    &current_id,
                    &current_pattern,
                    &current_message,
                    current_severity,
                );
                rule.set_invert(current_invert);
                rules.push(rule);
            }
            current_id.clear();
            current_pattern.clear();
            current_message.clear();
            current_severity = Severity::Warning;
            current_invert = false;
            in_rule = true;
            continue;
        }

        if !in_rule {
            continue;
        }

        if let Some(value) = extract_toml_string(trimmed, "id") {
            current_id = value;
        } else if let Some(value) = extract_toml_string(trimmed, "pattern") {
            current_pattern = value;
        } else if let Some(value) = extract_toml_string(trimmed, "message") {
            current_message = value;
        } else if let Some(value) = extract_toml_string(trimmed, "severity") {
            current_severity = Severity::from_name(&value);
        } else if trimmed.starts_with("invert") {
            current_invert = trimmed.contains("true");
        }
    }

    // Push last rule
    if in_rule && !current_id.is_empty() && !current_pattern.is_empty() {
        let mut rule = LuaPatternRule::new(
            &current_id,
            &current_pattern,
            &current_message,
            current_severity,
        );
        rule.set_invert(current_invert);
        rules.push(rule);
    }

    rules
}

/// Load rules from a TOML file on disk.
pub fn load_rules_from_file(path: &Path) -> Vec<LuaPatternRule> {
    match std::fs::read_to_string(path) {
        Ok(content) => load_rules_from_toml(&content),
        Err(_) => Vec::new(),
    }
}

fn extract_toml_string(line: &str, key: &str) -> Option<String> {
    let prefix = format!("{key} = ");
    if let Some(rest) = line.strip_prefix(&prefix) {
        let rest = rest.trim();
        if rest.starts_with('"') && rest.len() >= 2 {
            let inner = &rest[1..];
            if let Some(end) = inner.find('"') {
                return Some(inner[..end].to_string());
            }
        }
    }
    // Try without space around =
    let prefix2 = format!("{key}=");
    if let Some(rest) = line.strip_prefix(&prefix2) {
        let rest = rest.trim();
        if rest.starts_with('"') && rest.len() >= 2 {
            let inner = &rest[1..];
            if let Some(end) = inner.find('"') {
                return Some(inner[..end].to_string());
            }
        }
    }
    None
}
