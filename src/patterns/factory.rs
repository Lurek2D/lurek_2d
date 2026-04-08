//! Factory type-name registry without Lua coupling.
//!
//! [`Factory`] tracks which constructor names are registered.  The actual
//! constructor callbacks live in the Lua API layer.

use std::collections::HashSet;

/// Constructor-name registry (metadata only; constructors stored in lua_api layer).
///
/// # Fields
/// - `types` — `HashSet<String>`.
#[derive(Debug, Default)]
pub struct Factory {
    /// Set of registered type names.
    pub types: HashSet<String>,
    /// Alias map: `alias → canonical name`.
    pub aliases: std::collections::HashMap<String, String>,
}

impl Factory {
    /// Creates a new empty factory.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self { Self::default() }

    /// Registers a type name.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    pub fn register(&mut self, name: &str) {
        self.types.insert(name.to_string());
    }

    /// Removes a type name registration.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn unregister(&mut self, name: &str) -> bool {
        self.aliases.retain(|_, v| v != name);
        self.types.remove(name)
    }

    /// Whether a type name is registered (resolves aliases).
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn has(&self, name: &str) -> bool {
        self.types.contains(name) || self.aliases.contains_key(name)
    }

    /// Resolves an alias to its canonical name, or returns the name unchanged.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `&str`.
    pub fn resolve<'a>(&'a self, name: &'a str) -> &'a str {
        self.aliases.get(name).map(String::as_str).unwrap_or(name)
    }

    /// Registers a type alias pointing to an existing canonical name.
    ///
    /// # Parameters
    /// - `alias` — `&str`.
    /// - `canonical` — `&str`.
    pub fn add_alias(&mut self, alias: &str, canonical: &str) {
        self.aliases.insert(alias.to_string(), canonical.to_string());
    }

    /// Returns all registered type names sorted alphabetically.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn type_names(&self) -> Vec<&str> {
        let mut names: Vec<&str> = self.types.iter().map(String::as_str).collect();
        names.sort();
        names
    }

    /// Clears all registrations and aliases.
    pub fn clear(&mut self) {
        self.types.clear();
        self.aliases.clear();
    }
}
