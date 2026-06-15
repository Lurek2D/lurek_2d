//! - Parallel file search: distributes work across a small std-thread worker set.
//! - Files are collected eagerly, chunked deterministically, and merged after workers finish.
//! - Thread count comes from `GrepConfig`; `0` is clamped to a single worker.
//! - Matching remains literal-first and filesystem-oriented rather than a streaming validator engine.

use super::filter::FileFilter;
use super::matcher::Matcher;
use super::reader::FileReader;
use super::result::{FileMatch, LineMatch, SearchResult};
use std::path::{Path, PathBuf};
use std::time::Instant;

/// Parallel search across multiple files.
pub struct ParallelSearch {
    thread_count: usize,
    reader: FileReader,
}

impl ParallelSearch {
    /// Create a parallel file search worker with the given thread count and per-file size limit.
    pub fn new(thread_count: usize, max_file_size: u64) -> Self {
        Self {
            thread_count: thread_count.max(1),
            reader: FileReader::new(max_file_size),
        }
    }

    /// Search files matching filter in a directory tree.
    pub fn search(&self, root: &Path, matcher: &Matcher, filter: &FileFilter) -> SearchResult {
        let start = Instant::now();
        let files = collect_files(root, filter);
        let total_files = files.len();

        if files.is_empty() {
            return SearchResult::empty();
        }

        let matches = search_chunks(&files, self.thread_count, &self.reader, matcher);
        build_result(start, total_files, matches)
    }

    /// Search a flat list of file paths.
    pub fn search_files(&self, files: &[PathBuf], matcher: &Matcher) -> SearchResult {
        let start = Instant::now();
        let total_files = files.len();
        let matches = search_chunks(files, self.thread_count, &self.reader, matcher);
        build_result(start, total_files, matches)
    }
}

fn build_result(start: Instant, total_files: usize, mut matches: Vec<FileMatch>) -> SearchResult {
    matches.sort_by(|a, b| a.path.cmp(&b.path));
    for file_match in &mut matches {
        file_match
            .lines
            .sort_by(|a, b| a.line_number.cmp(&b.line_number));
    }
    let files_matched = matches.len();
    let total_matches: usize = matches.iter().map(|m| m.total_matches).sum();
    SearchResult {
        matches,
        files_searched: total_files,
        files_matched,
        total_matches,
        duration_ms: start.elapsed().as_millis() as u64,
    }
}

fn search_chunks(
    files: &[PathBuf],
    thread_count: usize,
    reader: &FileReader,
    matcher: &Matcher,
) -> Vec<FileMatch> {
    if files.is_empty() {
        return Vec::new();
    }

    let chunk_size = (files.len() / thread_count.max(1)).max(1);
    std::thread::scope(|scope| {
        let mut workers = Vec::new();
        for chunk in files.chunks(chunk_size) {
            workers.push(scope.spawn(move || {
                let mut local_matches = Vec::new();
                for path in chunk {
                    if let Some(file_match) = search_file(path, matcher, reader) {
                        local_matches.push(file_match);
                    }
                }
                local_matches
            }));
        }

        let mut merged = Vec::new();
        for worker in workers {
            if let Ok(local_matches) = worker.join() {
                merged.extend(local_matches);
            }
        }
        merged
    })
}

fn search_file(path: &Path, matcher: &Matcher, reader: &FileReader) -> Option<FileMatch> {
    let lines = reader.read_lines(path)?;
    let mut line_matches = Vec::new();
    let mut total = 0;

    for (idx, line) in lines.iter().enumerate() {
        if matcher.matches_line(line) {
            let positions = matcher.find_positions(line);
            total += positions.len().max(1);
            line_matches.push(LineMatch {
                line_number: idx + 1,
                content: line.clone(),
                positions,
            });
        }
    }

    if line_matches.is_empty() {
        None
    } else {
        Some(FileMatch {
            path: path.to_path_buf(),
            lines: line_matches,
            total_matches: total,
        })
    }
}

fn collect_files(root: &Path, filter: &FileFilter) -> Vec<PathBuf> {
    let mut files = Vec::new();
    collect_files_recursive(root, filter, &mut files);
    files
}

fn collect_files_recursive(dir: &Path, filter: &FileFilter, out: &mut Vec<PathBuf>) {
    let entries = match std::fs::read_dir(dir) {
        Ok(e) => e,
        Err(_) => return,
    };

    for entry in entries.flatten() {
        let path = entry.path();
        if path.is_dir() {
            let name = path.file_name().unwrap_or_default().to_string_lossy();
            if !filter.include_hidden && name.starts_with('.') {
                continue;
            }
            collect_files_recursive(&path, filter, out);
        } else if path.is_file() && filter.matches(&path) {
            out.push(path);
        }
    }
}
