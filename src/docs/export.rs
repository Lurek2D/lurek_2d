//! VS Code IntelliSense export helpers for the Lurek2D docs catalog.
//!
//! Converts [`DocEntry`] slices into JSON files consumed by the VS Code
//! extension for completions, hover documentation, and signature help.

use std::collections::HashMap;

use crate::docs::entry::DocEntry;

/// Writes a VS Code completions JSON array to `path`.
///
/// Each item contains `label`, `kind`, `detail`, and `documentation` fields
/// matching the VS Code `CompletionItem` format.
///
/// # Parameters
/// - `entries` — `&[DocEntry]`.
/// - `path` — `&str`.
///
/// # Returns
/// `Result<(), String>`.
pub fn export_completions(entries: &[DocEntry], path: &str) -> Result<(), String> {
    let completions: Vec<serde_json::Value> = entries
        .iter()
        .map(|e| {
            serde_json::json!({
                "label": e.name,
                "kind": match e.kind.as_str() {
                    "function" | "method" => "Function",
                    "type" => "Class",
                    "enum" => "Enum",
                    _ => "Variable"
                },
                "detail": e.qualified_name,
                "documentation": e.description
            })
        })
        .collect();
    let json = serde_json::to_string_pretty(&completions).unwrap_or_default();
    std::fs::write(path, json).map_err(|e| format!("write error: {}", e))
}

/// Writes a VS Code hover JSON map to `path`.
///
/// Keys are qualified names. Values contain `name`, `description`, `kind`,
/// `parameters`, and `returns` fields.
///
/// # Parameters
/// - `entries` — `&[DocEntry]`.
/// - `path` — `&str`.
///
/// # Returns
/// `Result<(), String>`.
pub fn export_hover(entries: &[DocEntry], path: &str) -> Result<(), String> {
    let mut hover: HashMap<String, serde_json::Value> = HashMap::new();
    for e in entries {
        hover.insert(
            e.qualified_name.clone(),
            serde_json::json!({
                "name": e.qualified_name,
                "description": e.description,
                "kind": e.kind,
                "parameters": e.parameters.iter().map(|p| {
                    serde_json::json!({
                        "name": p.name,
                        "type": p.type_name,
                        "description": p.description
                    })
                }).collect::<Vec<_>>(),
                "returns": e.returns.iter().map(|r| {
                    serde_json::json!({
                        "type": r.type_name,
                        "description": r.description
                    })
                }).collect::<Vec<_>>()
            }),
        );
    }
    let json = serde_json::to_string_pretty(&hover).unwrap_or_default();
    std::fs::write(path, json).map_err(|e| format!("write error: {}", e))
}

/// Writes a VS Code signature-help JSON map to `path`.
///
/// Only entries that have at least one parameter are included. Keys are
/// qualified names; values contain `label` and `parameters`.
///
/// # Parameters
/// - `entries` — `&[DocEntry]`.
/// - `path` — `&str`.
///
/// # Returns
/// `Result<(), String>`.
pub fn export_signatures(entries: &[DocEntry], path: &str) -> Result<(), String> {
    let mut sigs: HashMap<String, serde_json::Value> = HashMap::new();
    for e in entries {
        if !e.parameters.is_empty() {
            let params: Vec<serde_json::Value> = e
                .parameters
                .iter()
                .map(|p| {
                    serde_json::json!({
                        "label": if p.optional {
                            format!("{}?: {}", p.name, p.type_name)
                        } else {
                            format!("{}: {}", p.name, p.type_name)
                        },
                        "documentation": p.description
                    })
                })
                .collect();
            sigs.insert(
                e.qualified_name.clone(),
                serde_json::json!({
                    "label": e.qualified_name,
                    "parameters": params
                }),
            );
        }
    }
    let json = serde_json::to_string_pretty(&sigs).unwrap_or_default();
    std::fs::write(path, json).map_err(|e| format!("write error: {}", e))
}

/// Writes `completions.json`, `hover.json`, and `signatures.json` to `output_dir`.
///
/// The directory is created if it does not already exist. The hover JSON
/// written by this function is a compact variant (only `name`, `description`,
/// and `kind`); use [`export_hover`] for the full-parameter variant.
///
/// # Parameters
/// - `entries` — `&[DocEntry]`.
/// - `output_dir` — `&str`.
///
/// # Returns
/// `Result<(), String>`.
pub fn export_all(entries: &[DocEntry], output_dir: &str) -> Result<(), String> {
    std::fs::create_dir_all(output_dir).map_err(|e| format!("mkdir error: {}", e))?;

    // completions.json
    let completions: Vec<serde_json::Value> = entries
        .iter()
        .map(|e| {
            serde_json::json!({
                "label": e.name,
                "kind": match e.kind.as_str() {
                    "function" | "method" => "Function",
                    "type" => "Class",
                    _ => "Variable"
                },
                "detail": e.qualified_name,
                "documentation": e.description
            })
        })
        .collect();
    std::fs::write(
        format!("{}/completions.json", output_dir),
        serde_json::to_string_pretty(&completions).unwrap_or_default(),
    )
    .map_err(|e| format!("write error: {}", e))?;

    // hover.json (compact)
    let mut hover: HashMap<String, serde_json::Value> = HashMap::new();
    for e in entries {
        hover.insert(
            e.qualified_name.clone(),
            serde_json::json!({
                "name": e.qualified_name,
                "description": e.description,
                "kind": e.kind
            }),
        );
    }
    std::fs::write(
        format!("{}/hover.json", output_dir),
        serde_json::to_string_pretty(&hover).unwrap_or_default(),
    )
    .map_err(|e| format!("write error: {}", e))?;

    // signatures.json
    let mut sigs: HashMap<String, serde_json::Value> = HashMap::new();
    for e in entries {
        if !e.parameters.is_empty() {
            let params: Vec<serde_json::Value> = e
                .parameters
                .iter()
                .map(|p| {
                    serde_json::json!({
                        "label": p.name,
                        "documentation": p.description
                    })
                })
                .collect();
            sigs.insert(
                e.qualified_name.clone(),
                serde_json::json!({
                    "label": e.qualified_name,
                    "parameters": params
                }),
            );
        }
    }
    std::fs::write(
        format!("{}/signatures.json", output_dir),
        serde_json::to_string_pretty(&sigs).unwrap_or_default(),
    )
    .map_err(|e| format!("write error: {}", e))?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::docs::entry::{DocEntry, ParamInfo};

    fn test_entries() -> Vec<DocEntry> {
        let mut e = DocEntry::new("play", "audio", "function");
        e.description = "Plays a sound".into();
        e.parameters.push(ParamInfo {
            name: "path".into(),
            type_name: "string".into(),
            description: "file path".into(),
            optional: false,
            default: None,
        });
        vec![e]
    }

    #[test]
    fn export_completions_writes_file() {
        let dir = std::env::temp_dir().join("lurek_test_export_completions");
        let _ = std::fs::create_dir_all(&dir);
        let path = dir.join("completions.json");
        export_completions(&test_entries(), path.to_str().unwrap()).unwrap();
        let content = std::fs::read_to_string(&path).unwrap();
        assert!(content.contains("play"));
        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn export_hover_writes_file() {
        let dir = std::env::temp_dir().join("lurek_test_export_hover");
        let _ = std::fs::create_dir_all(&dir);
        let path = dir.join("hover.json");
        export_hover(&test_entries(), path.to_str().unwrap()).unwrap();
        let content = std::fs::read_to_string(&path).unwrap();
        assert!(content.contains("lurek.audio.play"));
        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn export_signatures_writes_file() {
        let dir = std::env::temp_dir().join("lurek_test_export_sigs");
        let _ = std::fs::create_dir_all(&dir);
        let path = dir.join("sigs.json");
        export_signatures(&test_entries(), path.to_str().unwrap()).unwrap();
        let content = std::fs::read_to_string(&path).unwrap();
        assert!(content.contains("path"));
        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn export_all_creates_three_files() {
        let dir = std::env::temp_dir().join("lurek_test_export_all");
        let _ = std::fs::remove_dir_all(&dir);
        export_all(&test_entries(), dir.to_str().unwrap()).unwrap();
        assert!(dir.join("completions.json").exists());
        assert!(dir.join("hover.json").exists());
        assert!(dir.join("signatures.json").exists());
        let _ = std::fs::remove_dir_all(&dir);
    }
}
