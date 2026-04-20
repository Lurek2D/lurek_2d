//! Variable interpolation for translation strings.
//!
//! Replaces `{key}` placeholders in a template string with values from a
//! lookup map.  Unrecognised keys are kept as-is so templates remain readable
//! even with partial variable sets.

use std::collections::HashMap;

/// Interpolates `{key}` placeholders in `template` with values from `vars`.
///
/// All placeholders in double-braces (`{{foo}}`) are treated as literal
/// text `{foo}` (standard escape convention).  Unknown placeholders keep the
/// original `{key}` marker.
///
/// # Parameters
/// - `template` — `&str`.
/// - `vars` — `&HashMap<String, String>`.
///
/// # Returns
/// `String`.
pub fn interpolate(template: &str, vars: &HashMap<String, String>) -> String {
    // Pre-allocate with a small margin beyond template length for typical expansions.
    let mut out = String::with_capacity(template.len() + 16);
    // Character-by-character state machine: handles {key}, {{escape}}, }}escape, and plain text.
    let mut chars = template.chars().peekable();
    while let Some(ch) = chars.next() {
        if ch == '{' {
            if chars.peek() == Some(&'{') {
                // Escaped "{{" → single "{"
                chars.next();
                out.push('{');
            } else {
                // Collect key until '}'
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
                        // Keep placeholder
                        out.push('{');
                        out.push_str(&key);
                        out.push('}');
                    }
                } else {
                    // Unterminated placeholder — output as-is
                    out.push('{');
                    out.push_str(&key);
                }
            }
        } else if ch == '}' && chars.peek() == Some(&'}') {
            // Escaped "}}" → single "}"
            chars.next();
            out.push('}');
        } else {
            out.push(ch);
        }
    }
    out
}

/// Thin wrapper: accepts `&[(impl Display, impl Display)]` pairs as the variable map.
///
/// # Parameters
/// - `template` — `&str`.
/// - `pairs` — `&[(String, String)]`.
///
/// # Returns
/// `String`.
pub fn interpolate_pairs(template: &str, pairs: &[(String, String)]) -> String {
    let vars: HashMap<String, String> = pairs.iter().cloned().collect();
    interpolate(template, &vars)
}
