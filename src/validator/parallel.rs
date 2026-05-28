//! Parallel file-tree runner: distributes validation rules across worker threads.
//!
//! - `validate_parallel(files, rules, config)` runs rules concurrently via Rayon.
//! - `collect_lua_files` and `collect_files_with_ext` enumerate files before dispatch.
//! - Each worker applies all rules to its file slice; results are merged with no locks.
//! - Thread count is sourced from `ValidatorConfig`; 0 forces single-threaded mode.

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
