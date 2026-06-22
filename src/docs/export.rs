//! Owns docs behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around DocsLimits, default, DocsExportOptions, with helpers kept close to their invariants.
//! Defines how export data is validated, transformed, or stored before neighboring systems use it.
//! Owns docs behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on export behavior while Lua registration stays elsewhere.
//! Documents where docs callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing export defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the docs state that can explain them while keeping call sites explicit.
//! Preserves deterministic behavior by keeping export calculations explicit at their owner boundary.
//! Provides the local adaptation layer that lets callers avoid duplicating docs rules while keeping call sites explicit.

use crate::docs::entry::DocEntry;
use crate::docs::error::{DocsError, DocsResult};
use crate::docs::report::{DocsIssue, DocsIssueKind, IssueSeverity};
use serde::Serialize;
use std::collections::HashMap;
use std::fs;
use std::io::Write;
use std::path::{Component, Path, PathBuf};

/// Safety and sizing limits applied while preparing documentation exports.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct DocsLimits {
    /// Maximum number of entries exported into one payload.
    pub max_entries: usize,
    /// Maximum number of Unicode scalar values retained in description fields.
    pub max_description_chars: usize,
    /// Maximum number of parameters retained per entry.
    pub max_params: usize,
    /// Maximum number of returns retained per entry.
    pub max_returns: usize,
    /// Maximum number of bytes allowed in one serialized output file.
    pub max_output_bytes: usize,
}

impl Default for DocsLimits {
    fn default() -> Self {
        Self {
            max_entries: 10_000,
            max_description_chars: 4_096,
            max_params: 32,
            max_returns: 16,
            max_output_bytes: 8 * 1024 * 1024,
        }
    }
}

/// Strict export options that add path safety, atomic writes, and payload metadata.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DocsExportOptions {
    /// Optional safe root that every resolved output path must stay under.
    pub output_root: Option<PathBuf>,
    /// Allow replacing an existing file target.
    pub allow_overwrite: bool,
    /// Write via a temporary file and rename to avoid partial JSON artifacts.
    pub atomic_write: bool,
    /// Limits applied while trimming or rejecting output payloads.
    pub limits: DocsLimits,
    /// Version tag emitted by the new typed export API.
    pub schema_version: u32,
}

impl Default for DocsExportOptions {
    fn default() -> Self {
        Self {
            output_root: None,
            allow_overwrite: true,
            atomic_write: true,
            limits: DocsLimits::default(),
            schema_version: 1,
        }
    }
}

/// Per-file details returned by strict docs exports.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct DocsExportFileReport {
    /// Logical payload name such as `completions` or `hover`.
    pub format: String,
    /// Final output path on disk.
    pub path: String,
    /// Exact byte count written to disk.
    pub bytes: usize,
}

/// Aggregate result returned by strict docs exports.
#[derive(Debug, Clone, Default, Serialize)]
pub struct DocsExportReport {
    /// Schema version emitted in typed payload metadata.
    pub schema_version: u32,
    /// Number of entries requested by the caller before limits were applied.
    pub total_entries: usize,
    /// Number of entries retained after limits and truncation.
    pub exported_entries: usize,
    /// File-level output records.
    pub files: Vec<DocsExportFileReport>,
    /// Structured issues collected while trimming or writing output.
    pub issues: Vec<DocsIssue>,
    /// Total bytes written across every payload file.
    pub total_bytes: usize,
}

impl DocsExportReport {
    /// Record one written file and update aggregate byte counters.
    fn push_file(&mut self, format: &str, path: &Path, bytes: usize) {
        self.total_bytes += bytes;
        self.files.push(DocsExportFileReport {
            format: format.to_string(),
            path: path.display().to_string(),
            bytes,
        });
    }
}

#[derive(Debug, Serialize)]
struct VersionedPayload<T> {
    schema_version: u32,
    format: &'static str,
    entry_count: usize,
    issue_count: usize,
    payload: T,
}

/// Map an entry kind to a completion item kind and return the resulting label.
fn completion_kind(kind: &str, include_enum: bool) -> &'static str {
    match kind {
        "function" | "method" => "Function",
        "type" => "Class",
        "enum" if include_enum => "Enum",
        _ => "Variable",
    }
}

/// Build completion payload rows and return them as JSON values.
fn build_completions(entries: &[DocEntry], include_enum: bool) -> Vec<serde_json::Value> {
    entries
        .iter()
        .map(|entry| {
            serde_json::json!({
                "label": entry.name,
                "kind": completion_kind(&entry.kind, include_enum),
                "detail": entry.qualified_name,
                "documentation": entry.description
            })
        })
        .collect()
}

/// Build hover payload data keyed by qualified name and return the map.
fn build_hover_map(entries: &[DocEntry], compact: bool) -> HashMap<String, serde_json::Value> {
    let mut hover: HashMap<String, serde_json::Value> = HashMap::new();
    for entry in entries {
        let value = if compact {
            serde_json::json!({
                "name": entry.qualified_name,
                "description": entry.description,
                "kind": entry.kind
            })
        } else {
            serde_json::json!({
                "name": entry.qualified_name,
                "description": entry.description,
                "kind": entry.kind,
                "parameters": entry.parameters.iter().map(|param| {
                    serde_json::json!({
                        "name": param.name,
                        "type": param.type_name,
                        "description": param.description
                    })
                }).collect::<Vec<_>>(),
                "returns": entry.returns.iter().map(|ret| {
                    serde_json::json!({
                        "type": ret.type_name,
                        "description": ret.description
                    })
                }).collect::<Vec<_>>()
            })
        };
        hover.insert(entry.qualified_name.clone(), value);
    }
    hover
}

/// Build signature payload data keyed by qualified name and return the map.
fn build_signatures(entries: &[DocEntry], rich_labels: bool) -> HashMap<String, serde_json::Value> {
    let mut signatures: HashMap<String, serde_json::Value> = HashMap::new();
    for entry in entries {
        if !entry.parameters.is_empty() {
            let params: Vec<serde_json::Value> = entry
                .parameters
                .iter()
                .map(|param| {
                    let label = if rich_labels {
                        if param.optional {
                            format!("{}?: {}", param.name, param.type_name)
                        } else {
                            format!("{}: {}", param.name, param.type_name)
                        }
                    } else {
                        param.name.clone()
                    };
                    serde_json::json!({
                        "label": label,
                        "documentation": param.description
                    })
                })
                .collect();
            signatures.insert(
                entry.qualified_name.clone(),
                serde_json::json!({
                    "label": entry.qualified_name,
                    "parameters": params
                }),
            );
        }
    }
    signatures
}

/// Export completion payloads using the legacy JSON shape and return an error string on failure.
pub fn export_completions(entries: &[DocEntry], path: &str) -> Result<(), String> {
    let sanitized = sanitize_entries(entries, &DocsLimits::default()).map_err(error_to_string)?;
    let payload = build_completions(&sanitized.entries, true);
    write_json_legacy(path, "json", &payload).map_err(error_to_string)
}

/// Export hover payloads using the legacy JSON shape and return an error string on failure.
pub fn export_hover(entries: &[DocEntry], path: &str) -> Result<(), String> {
    let sanitized = sanitize_entries(entries, &DocsLimits::default()).map_err(error_to_string)?;
    let payload = build_hover_map(&sanitized.entries, false);
    write_json_legacy(path, "json", &payload).map_err(error_to_string)
}

/// Export signature payloads using the legacy JSON shape and return an error string on failure.
pub fn export_signatures(entries: &[DocEntry], path: &str) -> Result<(), String> {
    let sanitized = sanitize_entries(entries, &DocsLimits::default()).map_err(error_to_string)?;
    let payload = build_signatures(&sanitized.entries, true);
    write_json_legacy(path, "json", &payload).map_err(error_to_string)
}

/// Export all docs payload files into one directory using the legacy JSON shapes and return an error string on failure.
pub fn export_all(entries: &[DocEntry], output_dir: &str) -> Result<(), String> {
    let sanitized = sanitize_entries(entries, &DocsLimits::default()).map_err(error_to_string)?;
    let output_dir = Path::new(output_dir);
    fs::create_dir_all(output_dir).map_err(|error| {
        error_to_string(DocsError::Io {
            path: output_dir.display().to_string(),
            message: error.to_string(),
        })
    })?;
    write_json_legacy(
        output_dir.join("completions.json"),
        "json",
        &build_completions(&sanitized.entries, false),
    )
    .map_err(error_to_string)?;
    write_json_legacy(
        output_dir.join("hover.json"),
        "json",
        &build_hover_map(&sanitized.entries, true),
    )
    .map_err(error_to_string)?;
    write_json_legacy(
        output_dir.join("signatures.json"),
        "json",
        &build_signatures(&sanitized.entries, false),
    )
    .map_err(error_to_string)?;
    Ok(())
}

/// Export completion payloads with typed safety options, metadata, and an actionable report.
pub fn export_completions_with_options(
    entries: &[DocEntry],
    path: impl AsRef<Path>,
    options: &DocsExportOptions,
) -> DocsResult<DocsExportReport> {
    let sanitized = sanitize_entries(entries, &options.limits)?;
    let payload = VersionedPayload {
        schema_version: options.schema_version,
        format: "completions",
        entry_count: sanitized.entries.len(),
        issue_count: sanitized.issues.len(),
        payload: build_completions(&sanitized.entries, true),
    };
    write_versioned_payload(
        "completions",
        path.as_ref(),
        "json",
        options,
        entries.len(),
        sanitized,
        &payload,
    )
}

/// Export hover payloads with typed safety options, metadata, and an actionable report.
pub fn export_hover_with_options(
    entries: &[DocEntry],
    path: impl AsRef<Path>,
    options: &DocsExportOptions,
) -> DocsResult<DocsExportReport> {
    let sanitized = sanitize_entries(entries, &options.limits)?;
    let payload = VersionedPayload {
        schema_version: options.schema_version,
        format: "hover",
        entry_count: sanitized.entries.len(),
        issue_count: sanitized.issues.len(),
        payload: build_hover_map(&sanitized.entries, false),
    };
    write_versioned_payload(
        "hover",
        path.as_ref(),
        "json",
        options,
        entries.len(),
        sanitized,
        &payload,
    )
}

/// Export signature payloads with typed safety options, metadata, and an actionable report.
pub fn export_signatures_with_options(
    entries: &[DocEntry],
    path: impl AsRef<Path>,
    options: &DocsExportOptions,
) -> DocsResult<DocsExportReport> {
    let sanitized = sanitize_entries(entries, &options.limits)?;
    let payload = VersionedPayload {
        schema_version: options.schema_version,
        format: "signatures",
        entry_count: sanitized.entries.len(),
        issue_count: sanitized.issues.len(),
        payload: build_signatures(&sanitized.entries, true),
    };
    write_versioned_payload(
        "signatures",
        path.as_ref(),
        "json",
        options,
        entries.len(),
        sanitized,
        &payload,
    )
}

/// Export all versioned docs payload files into one directory and return a combined report.
pub fn export_all_with_options(
    entries: &[DocEntry],
    output_dir: impl AsRef<Path>,
    options: &DocsExportOptions,
) -> DocsResult<DocsExportReport> {
    let sanitized = sanitize_entries(entries, &options.limits)?;
    let output_dir = resolve_directory_target(output_dir.as_ref(), options)?;
    fs::create_dir_all(&output_dir).map_err(|error| DocsError::Io {
        path: output_dir.display().to_string(),
        message: error.to_string(),
    })?;

    let completions = VersionedPayload {
        schema_version: options.schema_version,
        format: "completions",
        entry_count: sanitized.entries.len(),
        issue_count: sanitized.issues.len(),
        payload: build_completions(&sanitized.entries, true),
    };
    let hover = VersionedPayload {
        schema_version: options.schema_version,
        format: "hover",
        entry_count: sanitized.entries.len(),
        issue_count: sanitized.issues.len(),
        payload: build_hover_map(&sanitized.entries, false),
    };
    let signatures = VersionedPayload {
        schema_version: options.schema_version,
        format: "signatures",
        entry_count: sanitized.entries.len(),
        issue_count: sanitized.issues.len(),
        payload: build_signatures(&sanitized.entries, true),
    };

    let mut report = DocsExportReport {
        schema_version: options.schema_version,
        total_entries: entries.len(),
        exported_entries: sanitized.entries.len(),
        files: Vec::new(),
        issues: sanitized.issues.clone(),
        total_bytes: 0,
    };
    let completion_path = output_dir.join("completions.json");
    let completion_bytes = write_json_bytes(
        "completions",
        &completion_path,
        &serialize_payload("completions", &completions, options)?,
        options,
    )?;
    report.push_file("completions", &completion_path, completion_bytes);

    let hover_path = output_dir.join("hover.json");
    let hover_bytes = write_json_bytes(
        "hover",
        &hover_path,
        &serialize_payload("hover", &hover, options)?,
        options,
    )?;
    report.push_file("hover", &hover_path, hover_bytes);

    let signature_path = output_dir.join("signatures.json");
    let signature_bytes = write_json_bytes(
        "signatures",
        &signature_path,
        &serialize_payload("signatures", &signatures, options)?,
        options,
    )?;
    report.push_file("signatures", &signature_path, signature_bytes);

    Ok(report)
}

#[derive(Clone)]
struct SanitizedEntries {
    entries: Vec<DocEntry>,
    issues: Vec<DocsIssue>,
}

/// Apply entry-count and field-size limits before serialization and return the sanitized entries plus issues.
fn sanitize_entries(entries: &[DocEntry], limits: &DocsLimits) -> DocsResult<SanitizedEntries> {
    if limits.max_output_bytes == 0 {
        return Err(DocsError::OutputTooLarge {
            context: "docs export",
            bytes: 0,
            max_bytes: 0,
        });
    }
    let mut sanitized = Vec::new();
    let mut issues = Vec::new();

    for (index, entry) in entries.iter().enumerate() {
        if index >= limits.max_entries {
            issues.push(
                DocsIssue::new(
                    "docs.export.entry_limit_exceeded",
                    DocsIssueKind::Export,
                    IssueSeverity::Warning,
                    "Docs export skipped entries beyond the configured entry limit.",
                )
                .with_qualified_name(entry.qualified_name.clone())
                .with_module(entry.module.clone())
                .with_source("export")
                .with_hint("Increase `DocsLimits.max_entries` if the larger catalog is expected."),
            );
            continue;
        }

        let mut trimmed = entry.clone();
        let (description, description_trimmed) =
            truncate_chars(&trimmed.description, limits.max_description_chars);
        if description_trimmed {
            issues.push(
                DocsIssue::new(
                    "docs.export.description_truncated",
                    DocsIssueKind::Export,
                    IssueSeverity::Warning,
                    "Entry description exceeded the configured export description limit and was truncated.",
                )
                .with_qualified_name(trimmed.qualified_name.clone())
                .with_module(trimmed.module.clone())
                .with_source("export")
                .with_hint("Reduce the source description size or raise `DocsLimits.max_description_chars`."),
            );
        }
        trimmed.description = description;

        if let Some(example) = &trimmed.example {
            let (example_text, example_trimmed) =
                truncate_chars(example, limits.max_description_chars);
            if example_trimmed {
                issues.push(
                    DocsIssue::new(
                        "docs.export.example_truncated",
                        DocsIssueKind::Export,
                        IssueSeverity::Hint,
                        "Entry example exceeded the configured export description limit and was truncated.",
                    )
                    .with_qualified_name(trimmed.qualified_name.clone())
                    .with_module(trimmed.module.clone())
                    .with_source("export")
                    .with_hint("Shorten the example or raise `DocsLimits.max_description_chars`."),
                );
            }
            trimmed.example = Some(example_text);
        }

        if trimmed.parameters.len() > limits.max_params {
            issues.push(
                DocsIssue::new(
                    "docs.export.param_limit_exceeded",
                    DocsIssueKind::Export,
                    IssueSeverity::Warning,
                    "Entry parameter list exceeded the configured export limit and was truncated.",
                )
                .with_qualified_name(trimmed.qualified_name.clone())
                .with_module(trimmed.module.clone())
                .with_source("export")
                .with_hint(
                    "Increase `DocsLimits.max_params` for APIs with intentionally wide signatures.",
                ),
            );
            trimmed.parameters.truncate(limits.max_params);
        }
        for parameter in &mut trimmed.parameters {
            let (description, description_trimmed) =
                truncate_chars(&parameter.description, limits.max_description_chars);
            parameter.description = description;
            if description_trimmed {
                issues.push(
                    DocsIssue::new(
                        "docs.export.param_description_truncated",
                        DocsIssueKind::Export,
                        IssueSeverity::Hint,
                        format!(
                            "Parameter `{}` description exceeded the configured export limit and was truncated.",
                            parameter.name
                        ),
                    )
                    .with_qualified_name(trimmed.qualified_name.clone())
                    .with_module(trimmed.module.clone())
                    .with_source("export")
                    .with_hint("Shorten the parameter documentation or raise `DocsLimits.max_description_chars`."),
                );
            }
        }

        if trimmed.returns.len() > limits.max_returns {
            issues.push(
                DocsIssue::new(
                    "docs.export.return_limit_exceeded",
                    DocsIssueKind::Export,
                    IssueSeverity::Warning,
                    "Entry return list exceeded the configured export limit and was truncated.",
                )
                .with_qualified_name(trimmed.qualified_name.clone())
                .with_module(trimmed.module.clone())
                .with_source("export")
                .with_hint("Increase `DocsLimits.max_returns` if multi-return docs are expected."),
            );
            trimmed.returns.truncate(limits.max_returns);
        }
        for ret in &mut trimmed.returns {
            let (description, description_trimmed) =
                truncate_chars(&ret.description, limits.max_description_chars);
            ret.description = description;
            if description_trimmed {
                issues.push(
                    DocsIssue::new(
                        "docs.export.return_description_truncated",
                        DocsIssueKind::Export,
                        IssueSeverity::Hint,
                        "Return description exceeded the configured export limit and was truncated.",
                    )
                    .with_qualified_name(trimmed.qualified_name.clone())
                    .with_module(trimmed.module.clone())
                    .with_source("export")
                    .with_hint("Shorten the return documentation or raise `DocsLimits.max_description_chars`."),
                );
            }
        }

        sanitized.push(trimmed);
    }

    Ok(SanitizedEntries {
        entries: sanitized,
        issues,
    })
}

/// Serialize a strict payload, enforcing the configured byte budget before any file write.
fn serialize_payload<T: Serialize>(
    context: &'static str,
    payload: &T,
    options: &DocsExportOptions,
) -> DocsResult<Vec<u8>> {
    let bytes = serde_json::to_vec_pretty(payload).map_err(|error| DocsError::Json {
        context,
        message: error.to_string(),
    })?;
    if bytes.len() > options.limits.max_output_bytes {
        return Err(DocsError::OutputTooLarge {
            context,
            bytes: bytes.len(),
            max_bytes: options.limits.max_output_bytes,
        });
    }
    Ok(bytes)
}

/// Write a single versioned payload to disk and return a report for that file.
fn write_versioned_payload<T: Serialize>(
    format: &'static str,
    path: &Path,
    expected_extension: &'static str,
    options: &DocsExportOptions,
    total_entries: usize,
    sanitized: SanitizedEntries,
    payload: &T,
) -> DocsResult<DocsExportReport> {
    let resolved_path = resolve_file_target(path, options, expected_extension)?;
    let bytes = serialize_payload(format, payload, options)?;
    write_json_bytes(format, &resolved_path, &bytes, options)?;
    let mut report = DocsExportReport {
        schema_version: options.schema_version,
        total_entries,
        exported_entries: sanitized.entries.len(),
        files: Vec::new(),
        issues: sanitized.issues,
        total_bytes: 0,
    };
    report.push_file(format, &resolved_path, bytes.len());
    Ok(report)
}

/// Serialize one legacy JSON value to a file path using atomic writes and return structured errors on failure.
fn write_json_legacy<T: Serialize>(
    path: impl AsRef<Path>,
    expected_extension: &'static str,
    value: &T,
) -> DocsResult<()> {
    let options = DocsExportOptions::default();
    let bytes = serde_json::to_vec_pretty(value).map_err(|error| DocsError::Json {
        context: "legacy docs export",
        message: error.to_string(),
    })?;
    let resolved_path = resolve_file_target(path.as_ref(), &options, expected_extension)?;
    write_json_bytes("legacy docs export", &resolved_path, &bytes, &options)?;
    Ok(())
}

/// Resolve a file target against the optional safe root and return a canonical write path.
fn resolve_file_target(
    path: &Path,
    options: &DocsExportOptions,
    expected_extension: &'static str,
) -> DocsResult<PathBuf> {
    validate_extension(path, expected_extension)?;
    let file_name = path
        .file_name()
        .ok_or_else(|| DocsError::InvalidPath {
            path: path.display().to_string(),
        })?
        .to_os_string();
    let parent = path.parent().unwrap_or_else(|| Path::new(""));
    let resolved_parent = resolve_parent_directory(parent, options)?;
    Ok(resolved_parent.join(file_name))
}

/// Resolve an output directory against the optional safe root and return a canonical directory path.
fn resolve_directory_target(path: &Path, options: &DocsExportOptions) -> DocsResult<PathBuf> {
    if let Some(root) = &options.output_root {
        let canonical_root = canonicalize_existing_directory(root)?;
        let combined = if path.as_os_str().is_empty() {
            canonical_root.clone()
        } else if path.is_absolute() {
            path.to_path_buf()
        } else {
            canonical_root.join(path)
        };
        let normalized = normalize_path(&combined)?;
        ensure_within_root(&normalized, &canonical_root)?;
        fs::create_dir_all(&normalized).map_err(|error| DocsError::Io {
            path: normalized.display().to_string(),
            message: error.to_string(),
        })?;
        let canonical = canonicalize_existing_directory(&normalized)?;
        ensure_within_root(&canonical, &canonical_root)?;
        return Ok(canonical);
    }
    let normalized = if path.as_os_str().is_empty() {
        std::env::current_dir().map_err(|error| DocsError::Io {
            path: ".".to_string(),
            message: error.to_string(),
        })?
    } else if path.is_absolute() {
        normalize_path(path)?
    } else {
        normalize_path(
            &std::env::current_dir()
                .map_err(|error| DocsError::Io {
                    path: ".".to_string(),
                    message: error.to_string(),
                })?
                .join(path),
        )?
    };
    fs::create_dir_all(&normalized).map_err(|error| DocsError::Io {
        path: normalized.display().to_string(),
        message: error.to_string(),
    })?;
    canonicalize_existing_directory(&normalized)
}

/// Resolve a parent directory, creating it first when necessary, and enforce the safe root when configured.
fn resolve_parent_directory(path: &Path, options: &DocsExportOptions) -> DocsResult<PathBuf> {
    if let Some(root) = &options.output_root {
        let canonical_root = canonicalize_existing_directory(root)?;
        let combined = if path.as_os_str().is_empty() {
            canonical_root.clone()
        } else if path.is_absolute() {
            path.to_path_buf()
        } else {
            canonical_root.join(path)
        };
        let normalized = normalize_path(&combined)?;
        ensure_within_root(&normalized, &canonical_root)?;
        fs::create_dir_all(&normalized).map_err(|error| DocsError::Io {
            path: normalized.display().to_string(),
            message: error.to_string(),
        })?;
        let canonical_parent = canonicalize_existing_directory(&normalized)?;
        ensure_within_root(&canonical_parent, &canonical_root)?;
        return Ok(canonical_parent);
    }

    let parent = if path.as_os_str().is_empty() {
        std::env::current_dir().map_err(|error| DocsError::Io {
            path: ".".to_string(),
            message: error.to_string(),
        })?
    } else if path.is_absolute() {
        normalize_path(path)?
    } else {
        normalize_path(
            &std::env::current_dir()
                .map_err(|error| DocsError::Io {
                    path: ".".to_string(),
                    message: error.to_string(),
                })?
                .join(path),
        )?
    };
    fs::create_dir_all(&parent).map_err(|error| DocsError::Io {
        path: parent.display().to_string(),
        message: error.to_string(),
    })?;
    canonicalize_existing_directory(&parent)
}

/// Normalize a path lexically before any directory creation so traversal can be denied safely.
fn normalize_path(path: &Path) -> DocsResult<PathBuf> {
    let mut normalized = PathBuf::new();
    for component in path.components() {
        match component {
            Component::CurDir => {}
            Component::Normal(part) => normalized.push(part),
            Component::RootDir | Component::Prefix(_) => normalized.push(component.as_os_str()),
            Component::ParentDir => {
                if !normalized.pop() {
                    return Err(DocsError::InvalidPath {
                        path: path.display().to_string(),
                    });
                }
            }
        }
    }
    if normalized.as_os_str().is_empty() {
        return Err(DocsError::InvalidPath {
            path: path.display().to_string(),
        });
    }
    Ok(normalized)
}

/// Reject file targets that do not use the expected extension for the current export format.
fn validate_extension(path: &Path, expected_extension: &'static str) -> DocsResult<()> {
    let actual = path.extension().and_then(|ext| ext.to_str());
    if actual == Some(expected_extension) {
        return Ok(());
    }
    Err(DocsError::InvalidExtension {
        path: path.display().to_string(),
        expected_extension: format!(".{expected_extension}"),
    })
}

/// Canonicalize an existing directory path and normalize any I/O error into `DocsError`.
fn canonicalize_existing_directory(path: &Path) -> DocsResult<PathBuf> {
    fs::canonicalize(path).map_err(|error| DocsError::Io {
        path: path.display().to_string(),
        message: error.to_string(),
    })
}

/// Reject a candidate path when it escapes the configured root.
fn ensure_within_root(candidate: &Path, root: &Path) -> DocsResult<()> {
    if candidate.starts_with(root) {
        return Ok(());
    }
    Err(DocsError::PathDenied {
        path: candidate.display().to_string(),
        root: root.display().to_string(),
    })
}

/// Write serialized bytes to the final file path, optionally using a temp file and atomic rename.
fn write_json_bytes(
    context: &'static str,
    path: &Path,
    bytes: &[u8],
    options: &DocsExportOptions,
) -> DocsResult<usize> {
    if path.exists() && !options.allow_overwrite {
        return Err(DocsError::OverwriteDenied {
            path: path.display().to_string(),
        });
    }
    let parent = path.parent().ok_or_else(|| DocsError::InvalidPath {
        path: path.display().to_string(),
    })?;
    fs::create_dir_all(parent).map_err(|error| DocsError::Io {
        path: parent.display().to_string(),
        message: error.to_string(),
    })?;

    if options.atomic_write {
        let mut temp_file =
            tempfile::NamedTempFile::new_in(parent).map_err(|error| DocsError::Io {
                path: parent.display().to_string(),
                message: error.to_string(),
            })?;
        temp_file.write_all(bytes).map_err(|error| DocsError::Io {
            path: temp_file.path().display().to_string(),
            message: error.to_string(),
        })?;
        temp_file.flush().map_err(|error| DocsError::Io {
            path: temp_file.path().display().to_string(),
            message: error.to_string(),
        })?;
        if options.allow_overwrite && path.exists() {
            fs::remove_file(path).map_err(|error| DocsError::Io {
                path: path.display().to_string(),
                message: error.to_string(),
            })?;
        }
        temp_file.persist(path).map_err(|error| DocsError::Io {
            path: path.display().to_string(),
            message: format!("{context}: {}", error.error),
        })?;
        return Ok(bytes.len());
    }

    fs::write(path, bytes).map_err(|error| DocsError::Io {
        path: path.display().to_string(),
        message: format!("{context}: {error}"),
    })?;
    Ok(bytes.len())
}

/// Return a string truncated to at most `max_chars` Unicode scalar values plus a truncation flag.
fn truncate_chars(input: &str, max_chars: usize) -> (String, bool) {
    let char_count = input.chars().count();
    if char_count <= max_chars {
        return (input.to_string(), false);
    }
    (input.chars().take(max_chars).collect(), true)
}

/// Normalize a structured export error into the legacy string-returning API.
fn error_to_string(error: DocsError) -> String {
    error.to_string()
}
