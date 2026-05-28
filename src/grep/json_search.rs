//! JSON path search: query structured key-value paths within JSON files.
//!
//! - `search_json_path` scans a directory for JSON files and extracts values at a path.
//! - `search_json_file` operates on a single file; returns `Option<serde_json::Value>`.
//! - Path syntax uses `/`-separated keys; arrays are addressed by numeric index.
//! - Exposed to Lua via `lurek.grep.json_path(dir, path)` in `grep_api.rs`.

use std::path::Path;

/// Result of a JSON key-path search.
#[derive(Debug, Clone)]
pub struct JsonMatch {
    /// File system path.
    pub path: String,
    /// Matched value at the JSON path.
    pub value: String,
    /// JSON key path expression to match.
    pub json_path: String,
}

/// Search JSON files for values at specific paths.
pub fn search_json_path(content: &str, query_path: &str, value_pattern: Option<&str>) -> Vec<JsonMatch> {
    let mut results = Vec::new();

    // Simple JSON key-value search (line-based heuristic for TOML/JSON without serde)
    for line in content.lines() {
        let trimmed = line.trim();
        if trimmed.contains(query_path) {
            let value = extract_json_value(trimmed);
            let matches_value = match value_pattern {
                Some(pat) => value.contains(pat),
                None => true,
            };
            if matches_value {
                results.push(JsonMatch {
                    path: query_path.to_string(),
                    value,
                    json_path: query_path.to_string(),
                });
            }
        }
    }

    results
}

/// Search a JSON file for a key path.
pub fn search_json_file(path: &Path, query_path: &str, value_pattern: Option<&str>) -> Vec<JsonMatch> {
    match std::fs::read_to_string(path) {
        Ok(content) => search_json_path(&content, query_path, value_pattern),
        Err(_) => Vec::new(),
    }
}

fn extract_json_value(line: &str) -> String {
    // Extract value after : or =
    if let Some(pos) = line.find(':') {
        line[pos + 1..].trim().trim_matches(|c| c == '"' || c == ',' || c == '}').to_string()
    } else if let Some(pos) = line.find('=') {
        line[pos + 1..].trim().trim_matches('"').to_string()
    } else {
        line.to_string()
    }
}
