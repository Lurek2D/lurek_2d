//! Parallel file search: distributes work across a Rayon thread pool.
//!
//! - Data type: `ParallelSearch`.
//! - Implementation: `ParallelSearch`.

use super::filter::FileFilter;
use super::matcher::Matcher;
use super::reader::FileReader;
use super::result::{FileMatch, LineMatch, SearchResult};
use std::path::{Path, PathBuf};
use std::sync::{Arc, Mutex};
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
            return SearchResult {
                matches: Vec::new(),
                files_searched: 0,
                files_matched: 0,
                total_matches: 0,
                duration_ms: start.elapsed().as_millis() as u64,
            };
        }

        let results = Arc::new(Mutex::new(Vec::new()));
        let chunk_size = (files.len() / self.thread_count).max(1);
        let chunks: Vec<&[PathBuf]> = files.chunks(chunk_size).collect();

        std::thread::scope(|s| {
            for chunk in chunks {
                let results = Arc::clone(&results);
                let reader = &self.reader;
                s.spawn(move || {
                    for path in chunk {
                        if let Some(file_match) = search_file(path, matcher, reader) {
                            results.lock().unwrap().push(file_match);
                        }
                    }
                });
            }
        });

        let matches = Arc::try_unwrap(results).unwrap().into_inner().unwrap();
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

    /// Search a flat list of file paths.
    pub fn search_files(&self, files: &[PathBuf], matcher: &Matcher) -> SearchResult {
        let start = Instant::now();
        let total_files = files.len();
        let results = Arc::new(Mutex::new(Vec::new()));
        let chunk_size = (files.len() / self.thread_count).max(1);
        let chunks: Vec<&[PathBuf]> = files.chunks(chunk_size).collect();

        std::thread::scope(|s| {
            for chunk in chunks {
                let results = Arc::clone(&results);
                let reader = &self.reader;
                s.spawn(move || {
                    for path in chunk {
                        if let Some(file_match) = search_file(path, matcher, reader) {
                            results.lock().unwrap().push(file_match);
                        }
                    }
                });
            }
        });

        let matches = Arc::try_unwrap(results).unwrap().into_inner().unwrap();
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
