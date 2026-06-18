//! `src/i18n/interpolation.rs` owns placeholder expansion for localized templates that embed runtime values by name.
//! It keeps brace escaping, missing-placeholder preservation, and pair-list helpers under one interpolation owner.
//! Read this file when template token rules, escape behavior, or substitution semantics for localized strings change.
//! This file is the template-expansion boundary for i18n text, while catalog lookup and plural logic stay elsewhere.

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
