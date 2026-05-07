//! VS Code IntelliSense export helpers for the Lurek2D docs catalog.
//!
//! Converts [`DocEntry`] slices into JSON files consumed by the VS Code
//! extension for completions, hover documentation, and signature help.

use std::collections::HashMap;
use std::fs::File;
use std::io::BufWriter;
use std::path::Path;

use crate::docs::entry::DocEntry;

fn completion_kind(kind: &str, include_enum: bool) -> &'static str {
    match kind {
        "function" | "method" => "Function",
        "type" => "Class",
        "enum" if include_enum => "Enum",
        _ => "Variable",
    }
}

fn build_completions(entries: &[DocEntry], include_enum: bool) -> Vec<serde_json::Value> {
    entries
        .iter()
        .map(|e| {
            serde_json::json!({
                "label": e.name,
                "kind": completion_kind(&e.kind, include_enum),
                "detail": e.qualified_name,
                "documentation": e.description
            })
        })
        .collect()
}

fn build_hover_map(entries: &[DocEntry], compact: bool) -> HashMap<String, serde_json::Value> {
    let mut hover: HashMap<String, serde_json::Value> = HashMap::new();
    for e in entries {
        let value = if compact {
            serde_json::json!({
                "name": e.qualified_name,
                "description": e.description,
                "kind": e.kind
            })
        } else {
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
            })
        };
        hover.insert(e.qualified_name.clone(), value);
    }
    hover
}

fn build_signatures(entries: &[DocEntry], rich_labels: bool) -> HashMap<String, serde_json::Value> {
    let mut sigs: HashMap<String, serde_json::Value> = HashMap::new();
    for e in entries {
        if !e.parameters.is_empty() {
            let params: Vec<serde_json::Value> = e
                .parameters
                .iter()
                .map(|p| {
                    let label = if rich_labels {
                        if p.optional {
                            format!("{}?: {}", p.name, p.type_name)
                        } else {
                            format!("{}: {}", p.name, p.type_name)
                        }
                    } else {
                        p.name.clone()
                    };
                    serde_json::json!({
                        "label": label,
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
    sigs
}

fn write_json_file<T: serde::Serialize>(path: impl AsRef<Path>, value: &T) -> Result<(), String> {
    let file = File::create(path.as_ref()).map_err(|e| format!("write error: {e}"))?;
    let mut writer = BufWriter::new(file);
    serde_json::to_writer_pretty(&mut writer, value).map_err(|e| format!("write error: {e}"))
}

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
    let completions = build_completions(entries, true);
    write_json_file(path, &completions)
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
    let hover = build_hover_map(entries, false);
    write_json_file(path, &hover)
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
    let sigs = build_signatures(entries, true);
    write_json_file(path, &sigs)
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

    let completions = build_completions(entries, false);
    let hover = build_hover_map(entries, true);
    let sigs = build_signatures(entries, false);

    write_json_file(format!("{}/completions.json", output_dir), &completions)?;
    write_json_file(format!("{}/hover.json", output_dir), &hover)?;
    write_json_file(format!("{}/signatures.json", output_dir), &sigs)?;

    Ok(())
}
