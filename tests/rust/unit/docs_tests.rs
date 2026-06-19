//! File: tests/rust/unit/docs_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::docs::{
    export_all, export_completions, export_completions_with_options, export_hover,
    export_signatures, Catalog, DocEntry, DocsError, DocsExportOptions, DocsLimits, FieldRule,
    FieldType, ParamInfo, QualityReport, ReturnInfo, Schema, SearchOptions, ValidationReport,
};
use serde_json::Value;
use std::path::PathBuf;
use tempfile::tempdir;

fn sample_entry() -> DocEntry {
    let mut entry = DocEntry::new("play", "audio", "function");
    entry.description = "Play a sound".to_string();
    entry.parameters.push(ParamInfo {
        name: "path".to_string(),
        type_name: "string".to_string(),
        description: "Source path".to_string(),
        optional: false,
        default: None,
    });
    entry.returns.push(ReturnInfo {
        type_name: "boolean".to_string(),
        description: "true on success".to_string(),
    });
    entry
}

#[test]
fn catalog_merge_overrides_duplicate_entries() {
    let mut left = Catalog::new();
    let mut right = Catalog::new();

    let mut first = sample_entry();
    first.description = "left".to_string();
    left.add(first);

    let mut override_entry = sample_entry();
    override_entry.description = "right".to_string();
    right.add(override_entry);

    let merged = left.merge(&right);
    let merged_entry = merged
        .get_entry("lurek.audio.play")
        .expect("merged catalog should contain entry");
    assert_eq!(merged_entry.description, "right");
}

#[test]
fn catalog_detects_duplicate_qualified_names() {
    let mut catalog = Catalog::new();
    catalog
        .add_checked(sample_entry())
        .expect("first insert should succeed");
    let error = catalog
        .add_checked(sample_entry())
        .expect_err("duplicate insert should fail in checked mode");
    assert_eq!(
        error,
        DocsError::DuplicateQualifiedName {
            qualified_name: "lurek.audio.play".to_string(),
        }
    );
    assert_eq!(catalog.entry_count(), 1);
}

#[test]
fn catalog_search_uses_max_results() {
    let mut first = sample_entry();
    first.name = "playOnce".to_string();
    first.qualified_name = "lurek.audio.playOnce".to_string();
    let mut second = sample_entry();
    second.name = "playLoop".to_string();
    second.qualified_name = "lurek.audio.playLoop".to_string();

    let catalog = Catalog::from_entries(&[first, second]);
    let matches = catalog.search_with_options(
        "play",
        SearchOptions {
            max_results: Some(1),
            case_sensitive: false,
        },
    );
    assert_eq!(matches.len(), 1);
}

#[test]
fn schema_validate_pairs_enforces_string_length_bounds() {
    let mut schema = Schema::new("player");
    let rule = FieldRule {
        field_type: FieldType::String,
        required: true,
        min_len: Some(3),
        max_len: Some(8),
        ..Default::default()
    };
    schema.add_rule("name", rule);

    let short = vec![("name".to_string(), "string", "ab".to_string())];
    let long = vec![("name".to_string(), "string", "very_long_name".to_string())];
    let valid = vec![("name".to_string(), "string", "Lurek".to_string())];

    assert!(!schema.validate_pairs(&short).ok);
    assert!(!schema.validate_pairs(&long).ok);
    assert!(schema.validate_pairs(&valid).ok);
}

#[test]
fn schema_from_toml_parses_rules_and_strict_mode() {
    let toml = r#"
name = "save"
strict = true

[rules.level]
type = "integer"
required = true
min = 1
max = 99

[rules.class]
type = "string"
enum = ["mage", "rogue"]
"#;

    let schema = Schema::from_toml(toml).expect("schema TOML should parse");
    assert_eq!(schema.name, "save");
    assert!(schema.strict);
    assert_eq!(schema.rules.len(), 2);

    let level = schema.rules.get("level").expect("level rule should exist");
    assert_eq!(level.field_type, FieldType::Integer);
    assert_eq!(level.min, Some(1.0));
    assert_eq!(level.max, Some(99.0));
}

#[test]
fn quality_report_handles_mixed_modules() {
    let mut audio = sample_entry();
    audio.module = "audio".to_string();
    audio.example = Some("lurek.audio.play('a')".to_string());
    audio.since = Some("1.0.0".to_string());

    let mut render = DocEntry::new("setColor", "render", "function");
    render.description = "".to_string();

    let report = QualityReport::from_entries(&[audio, render]);
    assert!(report.module_scores.contains_key("audio"));
    assert!(report.module_scores.contains_key("render"));
    assert!(report.overall_score >= 0.0 && report.overall_score <= 1.0);
}

#[test]
fn quality_report_emits_rule_level_issues() {
    let mut entry = DocEntry::new("setColor", "render", "function");
    entry.description = "Set a render color.".to_string();
    entry.parameters.push(ParamInfo {
        name: "color".to_string(),
        type_name: "Color".to_string(),
        description: String::new(),
        optional: false,
        default: None,
    });

    let report = QualityReport::from_entries(&[entry]);
    let rule_ids: Vec<&str> = report
        .issues
        .iter()
        .map(|issue| issue.rule_id.as_str())
        .collect();
    assert!(rule_ids.contains(&"docs.quality.param_description_missing"));
    assert!(rule_ids.contains(&"docs.quality.example_missing"));
}

#[test]
fn validation_report_has_severity_and_hints() {
    let documented = vec![sample_entry()];

    let mut live = documented.clone();
    live.push({
        let mut missing = DocEntry::new("stop", "audio", "function");
        missing.description = "Stop a sound".to_string();
        missing
    });

    let report = ValidationReport::compare(&documented, &live);
    assert_eq!(report.missing, vec!["lurek.audio.stop".to_string()]);
    let missing_issue = report
        .issues
        .iter()
        .find(|issue| issue.rule_id == "docs.validation.missing_symbol")
        .expect("missing issue should be present");
    assert_eq!(missing_issue.severity.as_str(), "error");
    assert!(missing_issue.hint.is_some());
}

#[test]
fn export_all_writes_compact_hover_variant() {
    let dir = tempdir().expect("temp dir should be creatable");
    export_all(&[sample_entry()], dir.path().to_str().expect("utf-8 path"))
        .expect("export_all should succeed");

    let hover_path = dir.path().join("hover.json");
    let hover = std::fs::read_to_string(hover_path).expect("hover.json should exist");
    assert!(hover.contains("\"name\""));
    assert!(!hover.contains("\"parameters\""));
}

#[test]
fn export_functions_write_files() {
    let dir = tempdir().expect("temp dir should be creatable");
    let completions = dir.path().join("completions.json");
    let hover = dir.path().join("hover.json");
    let signatures = dir.path().join("signatures.json");

    let entries = vec![sample_entry()];
    export_completions(&entries, completions.to_str().expect("utf-8 path"))
        .expect("completions export should succeed");
    export_hover(&entries, hover.to_str().expect("utf-8 path"))
        .expect("hover export should succeed");
    export_signatures(&entries, signatures.to_str().expect("utf-8 path"))
        .expect("signatures export should succeed");

    assert!(completions.exists());
    assert!(hover.exists());
    assert!(signatures.exists());
}

#[test]
fn docs_export_rejects_path_traversal() {
    let root = tempdir().expect("temp dir should be creatable");
    let escaped_dir = root
        .path()
        .parent()
        .expect("temp dir should have a parent")
        .join("docs_escape_target");
    let path = PathBuf::from("..")
        .join("docs_escape_target")
        .join("escape.json");
    let options = DocsExportOptions {
        output_root: Some(root.path().to_path_buf()),
        ..DocsExportOptions::default()
    };

    let error = export_completions_with_options(&[sample_entry()], &path, &options)
        .expect_err("path traversal should be rejected");
    match error {
        DocsError::PathDenied { .. } => {}
        other => panic!("expected path denial, got {other:?}"),
    }
    assert!(!escaped_dir.exists());
}

#[test]
fn docs_export_atomic_write() {
    let dir = tempdir().expect("temp dir should be creatable");
    let path = dir.path().join("completions.json");
    std::fs::write(&path, "partial").expect("seed file should write");
    let options = DocsExportOptions::default();

    export_completions_with_options(&[sample_entry()], &path, &options)
        .expect("typed export should succeed");

    let written = std::fs::read_to_string(&path).expect("final file should exist");
    assert!(written.contains("\"schema_version\""));
    assert!(!written.contains("partial"));
}

#[test]
fn docs_export_respects_output_size_limit() {
    let dir = tempdir().expect("temp dir should be creatable");
    let path = dir.path().join("completions.json");
    let mut entry = sample_entry();
    entry.description = "x".repeat(512);
    let options = DocsExportOptions {
        limits: DocsLimits {
            max_output_bytes: 64,
            ..DocsLimits::default()
        },
        ..DocsExportOptions::default()
    };

    let error = export_completions_with_options(&[entry], &path, &options)
        .expect_err("small output limit should reject payload");
    match error {
        DocsError::OutputTooLarge { .. } => {}
        other => panic!("expected output-too-large error, got {other:?}"),
    }
    assert!(!path.exists());
}

#[test]
fn export_payload_has_schema_version() {
    let dir = tempdir().expect("temp dir should be creatable");
    let path = dir.path().join("completions.json");
    export_completions_with_options(&[sample_entry()], &path, &DocsExportOptions::default())
        .expect("typed export should succeed");

    let json: Value =
        serde_json::from_str(&std::fs::read_to_string(&path).expect("typed payload should exist"))
            .expect("typed payload should parse");
    assert_eq!(json["schema_version"], Value::from(1));
    assert_eq!(json["format"], Value::from("completions"));
}

#[test]
fn docs_export_rejects_non_json_extension() {
    let dir = tempdir().expect("temp dir should be creatable");
    let path = dir.path().join("completions.txt");
    let error =
        export_completions_with_options(&[sample_entry()], &path, &DocsExportOptions::default())
            .expect_err("non-json extension should be rejected");
    match error {
        DocsError::InvalidExtension { .. } => {}
        other => panic!("expected invalid-extension error, got {other:?}"),
    }
}

#[test]
fn param_and_return_info_support_edge_values() {
    let mut entry = DocEntry::new("spawn", "entity", "function");
    entry.description = "Spawn entity".to_string();
    entry.parameters.push(ParamInfo {
        name: "opts".to_string(),
        type_name: "table".to_string(),
        description: "optional options".to_string(),
        optional: true,
        default: Some("{}".to_string()),
    });
    entry.returns.push(ReturnInfo {
        type_name: "nil|userdata".to_string(),
        description: "nil on failure".to_string(),
    });

    assert!(entry.is_complete());
    assert_eq!(entry.parameters[0].default.as_deref(), Some("{}"));
    assert_eq!(entry.returns[0].type_name, "nil|userdata");
}
