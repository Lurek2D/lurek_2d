//! Translation catalog: language maps, key resolution, and fallback chains.
//!
//! A [`Catalog`] holds message tables keyed by locale code (e.g. `"en-US"`).
//! Keys are dot-separated paths into nested string tables.  When a key is
//! missing in the requested locale the catalog walks a configurable fallback
//! chain before returning the key itself as a last resort.

use std::collections::HashMap;

// ── CatalogError ──────────────────────────────────────────────────────────

/// Errors produced by catalog operations.
///
/// # Variants
/// - `UnknownLocale` — The requested locale is not loaded.
/// - `KeyNotFound` — The key was not found in any fallback locale.
#[derive(Debug, thiserror::Error)]
pub enum CatalogError {
    /// Locale not registered.
    #[error("unknown locale: {0}")]
    UnknownLocale(String),
    /// Key not found after fallback exhaustion.
    #[error("key not found: {0}")]
    KeyNotFound(String),
}

// ── Catalog ───────────────────────────────────────────────────────────────

/// Multi-locale string catalog with dot-path key resolution.
///
/// # Fields
/// - `locale` — `String`.
/// - `fallbacks` — `Vec<String>`.
/// - `tables` — `HashMap<String, HashMap<String, String>>`.
#[derive(Debug, Default)]
pub struct Catalog {
    /// Active locale code (e.g. `"en-US"`).
    pub locale: String,
    /// Ordered fallback locale chain queried after the active locale.
    pub fallbacks: Vec<String>,
    /// All loaded locale tables. Inner maps are flat dot-separated key → value.
    pub tables: HashMap<String, HashMap<String, String>>,
}

impl Catalog {
    /// Creates an empty catalog.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self::default()
    }

    /// Loads or replaces a locale's flat string table.
    ///
    /// # Parameters
    /// - `locale` — `&str`.
    /// - `table` — `HashMap<String, String>`.
    pub fn load(&mut self, locale: &str, table: HashMap<String, String>) {
        self.tables.insert(locale.to_string(), table);
    }

    /// Removes a locale from the catalog.
    ///
    /// # Parameters
    /// - `locale` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn unload(&mut self, locale: &str) -> bool {
        self.tables.remove(locale).is_some()
    }

    /// Whether a locale is loaded.
    ///
    /// # Parameters
    /// - `locale` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn has_locale(&self, locale: &str) -> bool {
        self.tables.contains_key(locale)
    }

    /// Returns all loaded locale codes.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn locales(&self) -> Vec<&str> {
        self.tables.keys().map(String::as_str).collect()
    }

    /// Whether a key exists in the currently active locale.
    ///
    /// # Parameters
    /// - `key` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn has_key(&self, key: &str) -> bool {
        self.tables
            .get(&self.locale)
            .map(|t| t.contains_key(key))
            .unwrap_or(false)
    }

    /// Returns all keys available in the active locale.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn keys(&self) -> Vec<&str> {
        self.tables
            .get(&self.locale)
            .map(|t| t.keys().map(String::as_str).collect())
            .unwrap_or_default()
    }

    /// Resolves a translation key using the active locale with fallback chain.
    ///
    /// # Parameters
    /// - `key` — `&str`.
    ///
    /// # Returns
    /// `Result<&str, CatalogError>`.
    pub fn get<'a>(&'a self, key: &str) -> Result<&'a str, CatalogError> {
        // 1. Active locale
        if let Some(v) = self.tables.get(&self.locale).and_then(|t| t.get(key)) {
            return Ok(v.as_str());
        }
        // 2. Fallback chain
        for fb in &self.fallbacks {
            if let Some(v) = self.tables.get(fb).and_then(|t| t.get(key)) {
                return Ok(v.as_str());
            }
        }
        Err(CatalogError::KeyNotFound(key.to_string()))
    }

    /// Like [`get`][Catalog::get] but returns the key itself when not found.
    ///
    /// # Parameters
    /// - `key` — `&str`.
    ///
    /// # Returns
    /// `&str`.
    pub fn translate<'a>(&'a self, key: &'a str) -> &'a str {
        self.get(key).unwrap_or(key)
    }

    /// Inserts or updates a single key in the given locale.
    ///
    /// # Parameters
    /// - `locale` — `&str`.
    /// - `key` — `&str`.
    /// - `value` — `&str`.
    pub fn set_key(&mut self, locale: &str, key: &str, value: &str) {
        self.tables
            .entry(locale.to_string())
            .or_default()
            .insert(key.to_string(), value.to_string());
    }

    /// Exports the given locale table as a flat `HashMap<String, String>`.
    ///
    /// # Parameters
    /// - `locale` — `&str`.
    ///
    /// # Returns
    /// `Option<HashMap<String, String>>`.
    pub fn export(&self, locale: &str) -> Option<HashMap<String, String>> {
        self.tables.get(locale).cloned()
    }

    /// Merges key-value pairs into an existing locale without replacing the whole table.
    ///
    /// # Parameters
    /// - `locale` — `&str`.
    /// - `entries` — `HashMap<String, String>`.
    pub fn merge(&mut self, locale: &str, entries: HashMap<String, String>) {
        let table = self.tables.entry(locale.to_string()).or_default();
        for (k, v) in entries {
            table.insert(k, v);
        }
    }

    /// Returns the number of keys in the active locale.
    ///
    /// # Returns
    /// `usize`.
    pub fn key_count(&self) -> usize {
        self.tables
            .get(&self.locale)
            .map(|t| t.len())
            .unwrap_or(0)
    }

    /// Returns the unique first path-segments of all keys in the active locale.
    ///
    /// For example keys `"ui.ok"`, `"ui.cancel"`, `"item.sword"` yield `["ui", "item"]`.
    ///
    /// # Returns
    /// `Vec<String>`.
    pub fn categories(&self) -> Vec<String> {
        let Some(table) = self.tables.get(&self.locale) else {
            return Vec::new();
        };
        let mut cats: std::collections::HashSet<String> = std::collections::HashSet::new();
        for key in table.keys() {
            let prefix = key.split('.').next().unwrap_or(key.as_str());
            cats.insert(prefix.to_string());
        }
        let mut result: Vec<String> = cats.into_iter().collect();
        result.sort();
        result
    }

    /// Returns all keys in the active locale that start with the given category prefix.
    ///
    /// # Parameters
    /// - `category` — `&str`.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn keys_in_category<'a>(&'a self, category: &str) -> Vec<&'a str> {
        let Some(table) = self.tables.get(&self.locale) else {
            return Vec::new();
        };
        let prefix = format!("{category}.");
        let mut result: Vec<&str> = table
            .keys()
            .filter(|k| k.starts_with(&prefix) || k.as_str() == category)
            .map(String::as_str)
            .collect();
        result.sort();
        result
    }

    /// Simple substring search over values in the active locale.
    ///
    /// Returns up to `limit` `(key, value)` pairs where the value contains `query`
    /// (case-insensitive). `limit = 0` returns all matches.
    ///
    /// # Parameters
    /// - `query` — `&str`.
    /// - `limit` — `usize`.
    ///
    /// # Returns
    /// `Vec<(&str, &str)>`.
    pub fn search<'a>(&'a self, query: &str, limit: usize) -> Vec<(&'a str, &'a str)> {
        let Some(table) = self.tables.get(&self.locale) else {
            return Vec::new();
        };
        let lower = query.to_lowercase();
        let mut results: Vec<(&str, &str)> = table
            .iter()
            .filter(|(_, v)| v.to_lowercase().contains(&lower))
            .map(|(k, v)| (k.as_str(), v.as_str()))
            .collect();
        results.sort_by_key(|(k, _)| *k);
        if limit > 0 && results.len() > limit {
            results.truncate(limit);
        }
        results
    }

    /// Builds an inverted word index for the active locale.
    ///
    /// Returns a map from lowercase words to sorted lists of keys whose values
    /// contain that word. Useful as a pre-built cache for repeated `search_indexed` calls
    /// on large datasets (10k+ entries).
    ///
    /// # Returns
    /// `HashMap<String, Vec<String>>`.
    pub fn build_index(&self) -> HashMap<String, Vec<String>> {
        let Some(table) = self.tables.get(&self.locale) else {
            return HashMap::new();
        };
        // Build inverted index: for each value, split into words, normalise,
        // and record which keys contain that word.
        let mut index: HashMap<String, Vec<String>> = HashMap::new();
        for (key, value) in table {
            for word in value.split_whitespace() {
                // Strip leading/trailing punctuation and lowercase for case-insensitive matching.
                let word_lower = word
                    .to_lowercase()
                    .trim_matches(|c: char| !c.is_alphanumeric())
                    .to_string();
                if !word_lower.is_empty() {
                    index.entry(word_lower).or_default().push(key.clone());
                }
            }
        }
        for entries in index.values_mut() {
            entries.sort();
            entries.dedup();
        }
        index
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;

    /// Helper: create a catalog with one English locale loaded.
    fn en_catalog() -> Catalog {
        let mut c = Catalog::new();
        let mut table = HashMap::new();
        table.insert("ui.ok".to_string(), "OK".to_string());
        table.insert("ui.cancel".to_string(), "Cancel".to_string());
        table.insert("item.sword".to_string(), "Sword".to_string());
        c.load("en", table);
        c.locale = "en".to_string();
        c
    }

    #[test]
    fn new_creates_empty_catalog() {
        let c = Catalog::new();
        assert_eq!(c.locale, "");
        assert!(c.fallbacks.is_empty());
        assert!(c.tables.is_empty());
    }

    #[test]
    fn load_and_get() {
        let c = en_catalog();
        assert_eq!(c.get("ui.ok").unwrap(), "OK");
        assert_eq!(c.get("item.sword").unwrap(), "Sword");
    }

    #[test]
    fn get_missing_key_returns_error() {
        let c = en_catalog();
        assert!(c.get("nonexistent").is_err());
    }

    #[test]
    fn unload_removes_locale() {
        let mut c = en_catalog();
        assert!(c.has_locale("en"));
        assert!(c.unload("en"));
        assert!(!c.has_locale("en"));
        assert!(!c.unload("en")); // second unload returns false
    }

    #[test]
    fn has_locale_and_locales() {
        let mut c = en_catalog();
        c.load("pl", HashMap::new());
        assert!(c.has_locale("en"));
        assert!(c.has_locale("pl"));
        assert!(!c.has_locale("de"));
        let mut locs = c.locales();
        locs.sort();
        assert_eq!(locs, vec!["en", "pl"]);
    }

    #[test]
    fn has_key_and_keys() {
        let c = en_catalog();
        assert!(c.has_key("ui.ok"));
        assert!(!c.has_key("missing"));
        let mut k = c.keys();
        k.sort();
        assert_eq!(k, vec!["item.sword", "ui.cancel", "ui.ok"]);
    }

    #[test]
    fn fallback_chain_resolves() {
        let mut c = Catalog::new();
        let mut en = HashMap::new();
        en.insert("greeting".to_string(), "Hello".to_string());
        c.load("en", en);

        // French locale missing the "greeting" key
        c.load("fr", HashMap::new());
        c.locale = "fr".to_string();
        c.fallbacks = vec!["en".to_string()];

        assert_eq!(c.get("greeting").unwrap(), "Hello");
    }

    #[test]
    fn translate_returns_key_on_miss() {
        let c = en_catalog();
        assert_eq!(c.translate("no.such.key"), "no.such.key");
        assert_eq!(c.translate("ui.ok"), "OK");
    }

    #[test]
    fn set_key_creates_or_updates() {
        let mut c = en_catalog();
        c.set_key("en", "ui.ok", "Okay");
        assert_eq!(c.get("ui.ok").unwrap(), "Okay");

        // set_key into a new locale auto-creates the table
        c.set_key("de", "greeting", "Hallo");
        assert!(c.has_locale("de"));
    }

    #[test]
    fn export_clones_table() {
        let c = en_catalog();
        let exported = c.export("en").unwrap();
        assert_eq!(exported.get("ui.ok").unwrap(), "OK");
        assert!(c.export("missing").is_none());
    }

    #[test]
    fn merge_adds_without_replacing_table() {
        let mut c = en_catalog();
        let mut extra = HashMap::new();
        extra.insert("ui.save".to_string(), "Save".to_string());
        c.merge("en", extra);
        assert_eq!(c.get("ui.save").unwrap(), "Save");
        assert_eq!(c.get("ui.ok").unwrap(), "OK"); // existing keys intact
    }

    #[test]
    fn key_count() {
        let c = en_catalog();
        assert_eq!(c.key_count(), 3);
    }

    #[test]
    fn categories_extracts_prefixes() {
        let c = en_catalog();
        let cats = c.categories();
        assert!(cats.contains(&"ui".to_string()));
        assert!(cats.contains(&"item".to_string()));
        assert_eq!(cats.len(), 2);
    }

    #[test]
    fn keys_in_category() {
        let c = en_catalog();
        let mut ui_keys = c.keys_in_category("ui");
        ui_keys.sort();
        assert_eq!(ui_keys, vec!["ui.cancel", "ui.ok"]);
        assert!(c.keys_in_category("nonexistent").is_empty());
    }

    #[test]
    fn search_case_insensitive() {
        let c = en_catalog();
        let results = c.search("ok", 0);
        assert_eq!(results.len(), 1);
        assert_eq!(results[0], ("ui.ok", "OK"));
    }

    #[test]
    fn search_with_limit() {
        let c = en_catalog();
        let results = c.search("", 1); // empty query matches all
        assert_eq!(results.len(), 1);
    }

    #[test]
    fn build_index_creates_word_map() {
        let mut c = Catalog::new();
        let mut table = HashMap::new();
        table.insert("a".to_string(), "hello world".to_string());
        table.insert("b".to_string(), "hello there".to_string());
        c.load("en", table);
        c.locale = "en".to_string();

        let idx = c.build_index();
        let hello_keys = idx.get("hello").unwrap();
        assert_eq!(hello_keys.len(), 2);
        assert!(hello_keys.contains(&"a".to_string()));
        assert!(hello_keys.contains(&"b".to_string()));
    }

    #[test]
    fn empty_catalog_operations_return_defaults() {
        let c = Catalog::new();
        assert!(!c.has_key("any"));
        assert!(c.keys().is_empty());
        assert_eq!(c.key_count(), 0);
        assert!(c.categories().is_empty());
        assert!(c.keys_in_category("x").is_empty());
        assert!(c.search("x", 0).is_empty());
        assert!(c.build_index().is_empty());
    }
}
