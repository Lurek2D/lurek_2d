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
        Self {
            entries: Vec::new(),
        }
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
        self.entries
            .iter()
            .find(|e| e.qualified_name == qualified_name)
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

    /// Returns a merged catalog where entries from `other` override duplicates.
    ///
    /// Duplicates are matched by `qualified_name`. Entries unique to either
    /// catalog are preserved.
    ///
    /// # Parameters
    /// - `other` - `&Catalog`.
    ///
    /// # Returns
    /// `Catalog`.
    pub fn merge(&self, other: &Catalog) -> Catalog {
        let mut merged = self.entries.clone();
        for entry in &other.entries {
            if let Some(existing) = merged
                .iter_mut()
                .find(|candidate| candidate.qualified_name == entry.qualified_name)
            {
                *existing = entry.clone();
            } else {
                merged.push(entry.clone());
            }
        }
        Catalog { entries: merged }
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
