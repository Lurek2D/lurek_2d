//! TOML-file-defined validation rules: loaded and compiled from disk at engine startup.
//!
//! - `load_rules_from_file` reads a `.toml` rule file and returns `Vec<Box<dyn ValidationRule>>`.
//! - `load_rules_from_toml` parses the TOML `[[rule]]` array directly from a string.
//! - Each rule entry specifies `pattern`, `severity`, `message`, and optional `extensions`.
//! - Loaded rules are appended to the engine rule set before the first validation run.

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
                let mut rule = LuaPatternRule::new(&current_id, &current_pattern, &current_message, current_severity);
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
        let mut rule = LuaPatternRule::new(&current_id, &current_pattern, &current_message, current_severity);
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
