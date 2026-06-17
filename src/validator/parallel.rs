//! This file provides parallel execution plumbing for validator rule application across files. `validator/parallel` delivers the parallel implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! It enumerates candidate inputs and partitions work over worker threads efficiently. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! It merges per-file violations into unified reports without unstable ordering surprises. Public callable behavior is centered on `validate_parallel`, `collect_lua_files`, `collect_files_with_ext`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! It supports configurable thread control, including single-thread fallback execution. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

use super::report::ValidationReport;
use super::rule::ValidationRule;
use std::path::{Path, PathBuf};
use std::sync::{Arc, Mutex};
use std::time::Instant;

/// Run validation rules in parallel across files.
pub fn validate_parallel(
    files: &[PathBuf],
    rules: &[Arc<dyn ValidationRule>],
    thread_count: usize,
) -> ValidationReport {
    let start = Instant::now();
    let violations = Arc::new(Mutex::new(Vec::new()));
    let chunk_size = (files.len() / thread_count.max(1)).max(1);
    let chunks: Vec<&[PathBuf]> = files.chunks(chunk_size).collect();

    std::thread::scope(|s| {
        for chunk in chunks {
            let violations = Arc::clone(&violations);
            s.spawn(move || {
                for path in chunk {
                    let content = match std::fs::read_to_string(path) {
                        Ok(c) => c,
                        Err(_) => continue,
                    };
                    for rule in rules.iter() {
                        let mut file_violations = rule.validate(path, &content);
                        if !file_violations.is_empty() {
                            violations.lock().unwrap().append(&mut file_violations);
                        }
                    }
                }
            });
        }
    });

    let all_violations = Arc::try_unwrap(violations).unwrap().into_inner().unwrap();
    ValidationReport {
        violations: all_violations,
        files_checked: files.len(),
        duration_ms: start.elapsed().as_millis() as u64,
    }
}

/// Collect all files under a directory matching extensions.
pub fn collect_lua_files(root: &Path) -> Vec<PathBuf> {
    let mut files = Vec::new();
    collect_recursive(root, &["lua"], &mut files);
    files
}

/// Collect files with specific extensions.
pub fn collect_files_with_ext(root: &Path, extensions: &[&str]) -> Vec<PathBuf> {
    let mut files = Vec::new();
    collect_recursive(root, extensions, &mut files);
    files
}

fn collect_recursive(dir: &Path, extensions: &[&str], out: &mut Vec<PathBuf>) {
    let entries = match std::fs::read_dir(dir) {
        Ok(e) => e,
        Err(_) => return,
    };
    for entry in entries.flatten() {
        let path = entry.path();
        if path.is_dir() {
            let name = path.file_name().unwrap_or_default().to_string_lossy();
            if !name.starts_with('.') {
                collect_recursive(&path, extensions, out);
            }
        } else if path.is_file() {
            if let Some(ext) = path.extension() {
                let ext_str = ext.to_string_lossy().to_lowercase();
                if extensions.iter().any(|&e| e == ext_str) {
                    out.push(path);
                }
            }
        }
    }
}
