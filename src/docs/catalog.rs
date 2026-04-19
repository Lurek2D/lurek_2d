//! API catalog for querying and filtering doc entries.

use crate::docs::entry::DocEntry;

/// In-memory registry of all documented Lurek2D API entries.
///
/// # Fields
/// - `entries` — `HashMap<String, Vec<DocEntry>>`. All doc entries keyed by module.
pub struct Catalog {
    entries: Vec<DocEntry>,
}

impl Catalog {
    /// Creates an empty catalog.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self { entries: Vec::new() }
    }

    /// Creates a catalog pre-populated from a slice of entries.
    ///
    /// Each entry is cloned into the catalog.
    ///
    /// # Parameters
    /// - `entries` — `&[DocEntry]`.
    ///
    /// # Returns
    /// `Catalog`.
    pub fn from_entries(entries: &[DocEntry]) -> Self {
        let mut cat = Self::new();
        for e in entries {
            cat.add(e.clone());
        }
        cat
    }

    /// Inserts a doc entry into the catalog.
    ///
    /// # Parameters
    /// - `entry` — `DocEntry`.
    pub fn add(&mut self, entry: DocEntry) {
        self.entries.push(entry);
    }

    /// Returns a sorted, deduplicated list of module names present in the catalog.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn modules(&self) -> Vec<&str> {
        let mut names: Vec<&str> = self.entries.iter().map(|e| e.module.as_str()).collect();
        names.sort_unstable();
        names.dedup();
        names
    }

    /// Returns a slice over all entries in insertion order.
    ///
    /// # Returns
    /// `&[DocEntry]`.
    pub fn all_entries(&self) -> &[DocEntry] {
        &self.entries
    }

    /// Returns all entries belonging to the given module.
    ///
    /// # Parameters
    /// - `module` — `&str`.
    ///
    /// # Returns
    /// `Vec<&DocEntry>`.
    pub fn entries_for_module(&self, module: &str) -> Vec<&DocEntry> {
        self.entries.iter().filter(|e| e.module == module).collect()
    }

    /// Looks up an entry by its fully qualified name (e.g. `"lurek.audio.play"`).
    ///
    /// # Parameters
    /// - `qualified_name` — `&str`.
    ///
    /// # Returns
    /// `Option<&DocEntry>`.
    pub fn get_entry(&self, qualified_name: &str) -> Option<&DocEntry> {
        self.entries.iter().find(|e| e.qualified_name == qualified_name)
    }

    /// Returns the total number of entries in the catalog.
    ///
    /// # Returns
    /// `usize`.
    pub fn entry_count(&self) -> usize {
        self.entries.len()
    }

    /// Returns entries whose name or description contains `query` (case-insensitive).
    ///
    /// # Parameters
    /// - `query` — `&str`.
    ///
    /// # Returns
    /// `Vec<&DocEntry>`.
    pub fn search(&self, query: &str) -> Vec<&DocEntry> {
        let q = query.to_lowercase();
        self.entries
            .iter()
            .filter(|e| {
                e.name.to_lowercase().contains(&q) || e.description.to_lowercase().contains(&q)
            })
            .collect()
    }

    /// Returns entries of the given kind (e.g. `"function"`, `"value"`).
    ///
    /// # Parameters
    /// - `kind` — `&str`.
    ///
    /// # Returns
    /// `Vec<&DocEntry>`.
    pub fn filter_by_kind(&self, kind: &str) -> Vec<&DocEntry> {
        self.entries.iter().filter(|e| e.kind == kind).collect()
    }

    /// Removes all entries from the catalog.
    pub fn clear(&mut self) {
        self.entries.clear();
    }
}

impl Default for Catalog {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::docs::entry::DocEntry;

    fn sample_entry(name: &str, module: &str, kind: &str) -> DocEntry {
        let mut e = DocEntry::new(name, module, kind);
        e.description = format!("{name} description");
        e
    }

    #[test]
    fn empty_catalog() {
        let cat = Catalog::new();
        assert_eq!(cat.entry_count(), 0);
        assert!(cat.modules().is_empty());
    }

    #[test]
    fn add_and_retrieve() {
        let mut cat = Catalog::new();
        cat.add(sample_entry("play", "audio", "function"));
        assert_eq!(cat.entry_count(), 1);
        assert!(cat.get_entry("lurek.audio.play").is_some());
    }

    #[test]
    fn modules_dedup() {
        let mut cat = Catalog::new();
        cat.add(sample_entry("a", "audio", "function"));
        cat.add(sample_entry("b", "audio", "function"));
        cat.add(sample_entry("c", "render", "function"));
        assert_eq!(cat.modules(), vec!["audio", "render"]);
    }

    #[test]
    fn search_by_name() {
        let mut cat = Catalog::new();
        cat.add(sample_entry("play", "audio", "function"));
        cat.add(sample_entry("stop", "audio", "function"));
        let results = cat.search("play");
        assert_eq!(results.len(), 1);
    }

    #[test]
    fn filter_by_kind() {
        let mut cat = Catalog::new();
        cat.add(sample_entry("play", "audio", "function"));
        cat.add(sample_entry("volume", "audio", "value"));
        assert_eq!(cat.filter_by_kind("value").len(), 1);
    }

    #[test]
    fn entries_for_module() {
        let cat = Catalog::from_entries(&[
            sample_entry("a", "audio", "function"),
            sample_entry("b", "render", "function"),
        ]);
        assert_eq!(cat.entries_for_module("audio").len(), 1);
    }

    #[test]
    fn clear_empties_catalog() {
        let mut cat = Catalog::new();
        cat.add(sample_entry("x", "m", "function"));
        cat.clear();
        assert_eq!(cat.entry_count(), 0);
    }
}
