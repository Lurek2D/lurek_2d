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

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;

    #[test]
    fn replaces_single_var() {
        let mut v = HashMap::new();
        v.insert("name".into(), "World".into());
        assert_eq!(interpolate("Hello, {name}!", &v), "Hello, World!");
    }

    #[test]
    fn unknown_key_kept() {
        let v = HashMap::new();
        assert_eq!(interpolate("Hi {x}", &v), "Hi {x}");
    }

    #[test]
    fn escaped_braces() {
        let v = HashMap::new();
        assert_eq!(interpolate("{{literal}}", &v), "{literal}");
    }

    #[test]
    fn multiple_vars() {
        let mut v = HashMap::new();
        v.insert("a".into(), "1".into());
        v.insert("b".into(), "2".into());
        assert_eq!(interpolate("{a} + {b} = 3", &v), "1 + 2 = 3");
    }

    #[test]
    fn escaped_closing_braces() {
        let v = HashMap::new();
        assert_eq!(interpolate("a }}b", &v), "a }b");
    }

    #[test]
    fn unterminated_placeholder() {
        let v = HashMap::new();
        // Unterminated brace outputs as-is (no closing '}')
        assert_eq!(interpolate("hello {name", &v), "hello {name");
    }

    #[test]
    fn empty_template() {
        let v = HashMap::new();
        assert_eq!(interpolate("", &v), "");
    }

    #[test]
    fn no_placeholders() {
        let v = HashMap::new();
        assert_eq!(interpolate("plain text", &v), "plain text");
    }

    #[test]
    fn interpolate_pairs_basic() {
        let pairs = vec![
            ("name".to_string(), "Ada".to_string()),
            ("count".to_string(), "3".to_string()),
        ];
        assert_eq!(
            interpolate_pairs("{name} has {count} items", &pairs),
            "Ada has 3 items"
        );
    }

    #[test]
    fn interpolate_pairs_empty() {
        let pairs = Vec::new();
        assert_eq!(interpolate_pairs("no vars", &pairs), "no vars");
    }
}
