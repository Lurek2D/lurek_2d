//! `src/docs/catalog.rs` owns the in-memory catalog that stores, groups, searches, merges, and clears doc entries.
//! It provides the collection boundary over `DocEntry`, preserving insertion order while exposing module and kind queries.
//! Merge, duplicate handling, and derived lookup caches live here so export and reporting stages can share one consistent documentation container.
//! Read it when catalog search, deduplication, module grouping, or entry aggregation behavior needs to change.

use crate::docs::entry::DocEntry;
use crate::docs::error::{DocsError, DocsResult};
use std::collections::HashMap;

/// Search behavior options for catalog queries that may need result caps or case-sensitive matching.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct SearchOptions {
    /// Cap the number of returned matches when a caller only needs the top subset.
    pub max_results: Option<usize>,
    /// Switch to exact-case substring matching instead of cached lowercase search text.
    pub case_sensitive: bool,
}

/// Hold the in-memory list of documentation entries plus derived lookup caches.
#[derive(Debug, Default, Clone)]
pub struct Catalog {
    /// Preserve all collected entries in insertion order for export stages.
    entries: Vec<DocEntry>,
    /// Cache entry positions keyed by qualified name for O(1) point lookups.
    entry_index: HashMap<String, usize>,
    /// Cache normalized search text so repeated case-insensitive queries avoid repeated allocation.
    normalized_search: Vec<String>,
}

impl Catalog {
    /// Create an empty catalog and return it for entry aggregation.
    pub fn new() -> Self {
        Self::default()
    }

    /// Build a catalog from a slice and return a de-duplicated copy of each entry.
    pub fn from_entries(entries: &[DocEntry]) -> Self {
        let mut catalog = Self::new();
        for entry in entries {
            catalog.add(entry.clone());
        }
        catalog
    }

    /// Append or replace one entry by qualified name and return unit.
    pub fn add(&mut self, entry: DocEntry) {
        self.insert_or_replace(entry);
    }

    /// Append one entry only when its qualified name is new, else return a duplicate error.
    pub fn add_checked(&mut self, entry: DocEntry) -> DocsResult<()> {
        if self.entry_index.contains_key(&entry.qualified_name) {
            return Err(DocsError::DuplicateQualifiedName {
                qualified_name: entry.qualified_name,
            });
        }
        self.push_new_entry(entry);
        Ok(())
    }

    /// Return sorted unique module names referenced by all stored entries.
    pub fn modules(&self) -> Vec<&str> {
        let mut names: Vec<&str> = self.entries.iter().map(|e| e.module.as_str()).collect();
        names.sort_unstable();
        names.dedup();
        names
    }

    /// Return an immutable slice of all entries in insertion order.
    pub fn all_entries(&self) -> &[DocEntry] {
        &self.entries
    }

    /// Return all entries that belong to the requested module name.
    pub fn entries_for_module(&self, module: &str) -> Vec<&DocEntry> {
        self.entries
            .iter()
            .filter(|entry| entry.module == module)
            .collect()
    }

    /// Return the entry matching a fully qualified name or None when missing.
    pub fn get_entry(&self, qualified_name: &str) -> Option<&DocEntry> {
        self.entry_index
            .get(qualified_name)
            .and_then(|index| self.entries.get(*index))
    }

    /// Return the number of stored entries.
    pub fn entry_count(&self) -> usize {
        self.entries.len()
    }

    /// Return entries whose cached search text contains the query using default search behavior.
    pub fn search(&self, query: &str) -> Vec<&DocEntry> {
        self.search_with_options(query, SearchOptions::default())
    }

    /// Return entries whose names, qualified names, or descriptions contain the query under the given options.
    pub fn search_with_options(&self, query: &str, options: SearchOptions) -> Vec<&DocEntry> {
        let limit = options.max_results.unwrap_or(usize::MAX);
        if limit == 0 {
            return Vec::new();
        }
        let query_text = if options.case_sensitive {
            query.to_string()
        } else {
            query.to_lowercase()
        };
        let mut matches = Vec::new();
        for (index, entry) in self.entries.iter().enumerate() {
            let is_match = if query_text.is_empty() {
                true
            } else if options.case_sensitive {
                entry.name.contains(&query_text)
                    || entry.qualified_name.contains(&query_text)
                    || entry.description.contains(&query_text)
            } else {
                self.normalized_search[index].contains(&query_text)
            };
            if is_match {
                matches.push(entry);
                if matches.len() >= limit {
                    break;
                }
            }
        }
        matches
    }

    /// Return entries with a kind exactly equal to the provided value.
    pub fn filter_by_kind(&self, kind: &str) -> Vec<&DocEntry> {
        self.entries
            .iter()
            .filter(|entry| entry.kind == kind)
            .collect()
    }

    /// Merge this catalog with another and return de-duplicated entries by qualified name.
    pub fn merge(&self, other: &Catalog) -> Catalog {
        let mut merged = self.clone();
        for entry in other.all_entries() {
            merged.add(entry.clone());
        }
        merged
    }

    /// Remove all stored entries and return unit.
    pub fn clear(&mut self) {
        self.entries.clear();
        self.entry_index.clear();
        self.normalized_search.clear();
    }

    /// Insert an entry, replacing the existing slot when the qualified name already exists.
    fn insert_or_replace(&mut self, entry: DocEntry) {
        if let Some(existing_index) = self.entry_index.get(&entry.qualified_name).copied() {
            self.entries[existing_index] = entry;
            self.normalized_search[existing_index] =
                self.entries[existing_index].normalized_search_text();
            return;
        }
        self.push_new_entry(entry);
    }

    /// Append a new entry and update the lookup caches in lockstep.
    fn push_new_entry(&mut self, entry: DocEntry) {
        let normalized = entry.normalized_search_text();
        let qualified_name = entry.qualified_name.clone();
        let index = self.entries.len();
        self.entries.push(entry);
        self.normalized_search.push(normalized);
        self.entry_index.insert(qualified_name, index);
    }
}
