//! Service-locator name registry without Lua coupling.
//!
//! [`ServiceLocator`] tracks which service names are registered.  The actual
//! Lua values are stored in the API layer.

use std::collections::HashSet;

/// Named-service registry (metadata only; values stored in lua_api layer).
///
/// # Fields
/// - `services` — `HashSet<String>`.
#[derive(Debug, Default)]
pub struct ServiceLocator {
    /// Set of currently registered service names.
    pub services: HashSet<String>,
}

impl ServiceLocator {
    /// Creates a new empty service locator.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self { Self::default() }

    /// Registers a service name.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    pub fn register(&mut self, name: &str) {
        self.services.insert(name.to_string());
    }

    /// Removes a service name.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn unregister(&mut self, name: &str) -> bool {
        self.services.remove(name)
    }

    /// Whether a service name is registered.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn has(&self, name: &str) -> bool {
        self.services.contains(name)
    }

    /// Returns all registered service names sorted alphabetically.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn names(&self) -> Vec<&str> {
        let mut names: Vec<&str> = self.services.iter().map(String::as_str).collect();
        names.sort();
        names
    }

    /// Clears all registered services.
    pub fn clear(&mut self) {
        self.services.clear();
    }
}
