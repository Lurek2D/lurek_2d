//! Expands localized template text by replacing `{name}` placeholders with runtime values. `i18n/interpolation` delivers the interpolation implementation for the i18n subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Preserves unknown tokens and supports escaped braces so authored text stays readable under partial data. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Provides both map-driven and pair-list substitution flows for ergonomic caller integration. Public callable behavior is centered on `interpolate`, `interpolate_pairs`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

use std::collections::HashMap;
/// Replace `{name}` placeholders from a string map and keep unknown placeholders intact.
pub fn interpolate(template: &str, vars: &HashMap<String, String>) -> String {
    let mut out = String::with_capacity(template.len() + 16);
    let mut chars = template.chars().peekable();
    while let Some(ch) = chars.next() {
        if ch == '{' {
            if chars.peek() == Some(&'{') {
                chars.next();
                out.push('{');
            } else {
                let mut key = String::new();
                let mut closed = false;
                for inner in chars.by_ref() {
                    if inner == '}' {
                        closed = true;
                        break;
                    }
                    key.push(inner);
                }
                if closed {
                    if let Some(val) = vars.get(&key) {
                        out.push_str(val);
                    } else {
                        out.push('{');
                        out.push_str(&key);
                        out.push('}');
                    }
                } else {
                    out.push('{');
                    out.push_str(&key);
                }
            }
        } else if ch == '}' && chars.peek() == Some(&'}') {
            chars.next();
            out.push('}');
        } else {
            out.push(ch);
        }
    }
    out
}
/// Build a variable map from key-value pairs and interpolate the template.
pub fn interpolate_pairs(template: &str, pairs: &[(String, String)]) -> String {
    let vars: HashMap<String, String> = pairs.iter().cloned().collect();
    interpolate(template, &vars)
}
