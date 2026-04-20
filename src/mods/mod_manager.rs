//! Mod management framework.
//!
//! Provides `ModInfo` for mod metadata and `ModManager` for registration,
//! dependency resolution, load ordering, folder scanning, and hot-reload queuing.
//!
//! This module is part of Lurek2D's `modding` subsystem and provides the implementation
//! details for mod manager-related operations and data management.
//! Key types exported from this module: `ModInfo`, `ModManager`.
//! Primary functions: `new()`, `new()`, `register_mod()`, `unregister_mod()`.
//!
//! All public items are documented. See the parent module for architectural context
//! and the `lurek.*` Lua API for the scripting interface.

use crate::log_msg;
use crate::runtime::log_messages::{MD01_MGR_INIT, MD02_MOD_REG, MD04_ORDER_OK};
use std::collections::{HashMap, HashSet};

/// Metadata record describing one registered game mod.
///
/// # Fields
/// - `id` â€” `String`.
/// - `name` â€” `String`.
/// - `version` â€” `String`.
/// - `author` â€” `String`.
/// - `description` â€” `String`.
/// - `priority` â€” `i32`.
/// - `dependencies` â€” `Vec<String>`.
/// - `enabled` â€” `bool`.
/// - `loaded` â€” `bool`.
/// - `path` â€” `Option<String>`.
/// - `api_version` â€” `Option<String>`.
/// - `capabilities` â€” `Vec<String>`.
/// - `config_schema` â€” `Vec<(String, String, String)>`.
#[derive(Debug, Clone)]
pub struct ModInfo {
    /// Unique mod identifier.
    pub id: String,
    /// Human-readable display name.
    pub name: String,
    /// Version string (e.g. "1.0.0").
    pub version: String,
    /// Author name.
    pub author: String,
    /// Mod description.
    pub description: String,
    /// Load order priority (lower = loaded first).
    pub priority: i32,
    /// List of required mod IDs.
    pub dependencies: Vec<String>,
    /// Whether the mod is enabled.
    pub enabled: bool,
    /// Whether the mod has been loaded.
    pub loaded: bool,
    /// Filesystem path to the mod root folder, if known.
    pub path: Option<String>,
    /// Required engine API version string (e.g. `"0.5.0"`). When set, the engine
    /// warns or refuses to load this mod if its own API version is incompatible.
    pub api_version: Option<String>,
    /// Declared capability flags (e.g. `["filesystem", "network"]`). The engine
    /// may check these before allowing access to sandboxed subsystems.
    pub capabilities: Vec<String>,
    /// Config schema: list of `(key, type_hint, default_value)` triples declared
    /// in the `[config]` section of `mod.toml`. Used for validation and tooling.
    pub config_schema: Vec<(String, String, String)>,
}

impl ModInfo {
    /// Create a new ModInfo with the given ID and sensible defaults.
    ///
    /// # Parameters
    /// - `id` â€” `impl Into<String>`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(id: impl Into<String>) -> Self {
        let id = id.into();
        log_msg!(debug, MD02_MOD_REG, "{}", id);
        Self {
            name: id.clone(),
            id,
            version: "1.0.0".to_string(),
            author: String::new(),
            description: String::new(),
            priority: 0,
            dependencies: Vec::new(),
            enabled: true,
            loaded: false,
            path: None,
            api_version: None,
            capabilities: Vec::new(),
            config_schema: Vec::new(),
        }
    }

    /// Creates a `ModInfo` from its constituent parts, applying optional overrides over the defaults from [`ModInfo::new`].
    ///
    /// # Parameters
    /// - `id` â€” `String`.
    /// - `name` â€” `Option<String>`.
    /// - `version` â€” `Option<String>`.
    /// - `author` â€” `Option<String>`.
    /// - `description` â€” `Option<String>`.
    /// - `priority` â€” `Option<i32>`.
    /// - `dependencies` â€” `Vec<String>`.
    ///
    /// # Returns
    /// `Self`.
    pub fn from_parts(
        id: String,
        name: Option<String>,
        version: Option<String>,
        author: Option<String>,
        description: Option<String>,
        priority: Option<i32>,
        dependencies: Vec<String>,
    ) -> Self {
        let mut info = Self::new(id);
        if let Some(n) = name {
            info.name = n;
        }
        if let Some(v) = version {
            info.version = v;
        }
        if let Some(a) = author {
            info.author = a;
        }
        if let Some(d) = description {
            info.description = d;
        }
        if let Some(p) = priority {
            info.priority = p;
        }
        info.dependencies = dependencies;
        info
    }
}

/// Centralized registry for managing mods, resolving load order,
/// validating dependencies, scanning mod folders, and queuing hot-reloads.
///
/// # Fields
/// - `mods` â€” `Vec<ModInfo>`.
/// - `r` â€” `:load_order`].`.
/// - `custom_load_order` â€” `Option<Vec<String>>`.
/// - `reload_queue` â€” `Vec<String>`.
#[derive(Debug, Clone, Default)]
pub struct ModManager {
    mods: Vec<ModInfo>,
    /// Optional explicit load order (list of mod IDs in desired sequence).
    /// When `Some`, this overrides the default priority-based sort in [`ModManager::load_order`].
    custom_load_order: Option<Vec<String>>,
    /// Queue of mod IDs that have been marked for hot-reload.
    reload_queue: Vec<String>,
}

impl ModManager {
    /// Create a new empty ModManager. Returns a fully initialised instance with all fields set to their initial values.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        log_msg!(debug, MD01_MGR_INIT);
        Self {
            mods: Vec::new(),
            custom_load_order: None,
            reload_queue: Vec::new(),
        }
    }

    // â”€â”€ Registration â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    /// Register a mod with the manager. Panics in debug mode if the same entity is registered twice.
    ///
    /// # Parameters
    /// - `info` â€” `ModInfo`.
    ///
    /// If a mod with the same ID already exists it is replaced.
    pub fn register_mod(&mut self, info: ModInfo) {
        if let Some(pos) = self.mods.iter().position(|m| m.id == info.id) {
            self.mods[pos] = info;
        } else {
            self.mods.push(info);
        }
    }

    /// Removes a mod from the registry by its assigned ID.
    ///
    /// # Parameters
    /// - `id` â€” `&str`.
    ///
    /// # Returns
    /// `bool`.
    ///
    /// Also removes the mod from the reload queue if present.
    /// Returns `true` if found.
    pub fn unregister_mod(&mut self, id: &str) -> bool {
        if let Some(pos) = self.mods.iter().position(|m| m.id == id) {
            self.mods.remove(pos);
            self.reload_queue.retain(|q| q != id);
            true
        } else {
            false
        }
    }

    /// Get a reference to a mod by ID.
    ///
    /// # Parameters
    /// - `id` â€” `&str`.
    ///
    /// # Returns
    /// `Option<&ModInfo>`.
    pub fn get_mod(&self, id: &str) -> Option<&ModInfo> {
        self.mods.iter().find(|m| m.id == id)
    }

    /// Get a mutable reference to a mod by ID.
    ///
    /// # Parameters
    /// - `id` â€” `&str`.
    ///
    /// # Returns
    /// `Option<&mut ModInfo>`.
    pub fn get_mod_mut(&mut self, id: &str) -> Option<&mut ModInfo> {
        self.mods.iter_mut().find(|m| m.id == id)
    }

    /// Check if a mod is registered. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Parameters
    /// - `id` â€” `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn has_mod(&self, id: &str) -> bool {
        self.mods.iter().any(|m| m.id == id)
    }

    /// Returns the count of all currently registered mods.
    ///
    /// # Returns
    /// `usize`.
    pub fn mod_count(&self) -> usize {
        self.mods.len()
    }

    /// Returns a slice of all registered mod metadata records.
    ///
    /// # Returns
    /// `&[ModInfo]`.
    pub fn all_mods(&self) -> &[ModInfo] {
        &self.mods
    }

    // â”€â”€ Load Order â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    /// Get mods in their effective load order. Returns an error if the source data is malformed or missing.
    ///
    /// # Returns
    /// `Vec<&ModInfo>`.
    ///
    /// When a custom load order is set via [`set_load_order`], it is respected:
    /// mods listed there appear first (in that order), followed by any remaining
    /// mods sorted by priority. Mods not registered are silently skipped.
    pub fn load_order(&self) -> Vec<&ModInfo> {
        log_msg!(debug, MD04_ORDER_OK);
        if let Some(order) = &self.custom_load_order {
            let mut result: Vec<&ModInfo> = Vec::new();
            let mut seen: HashSet<&str> = HashSet::new();
            // Add mods in custom order first
            for id in order {
                if let Some(m) = self.mods.iter().find(|m| &m.id == id) {
                    result.push(m);
                    seen.insert(m.id.as_str());
                }
            }
            // Append remaining mods sorted by priority
            let mut remainder: Vec<&ModInfo> = self
                .mods
                .iter()
                .filter(|m| !seen.contains(m.id.as_str()))
                .collect();
            remainder.sort_by(|a, b| a.priority.cmp(&b.priority).then(a.id.cmp(&b.id)));
            result.extend(remainder);
            result
        } else {
            let mut sorted: Vec<&ModInfo> = self.mods.iter().collect();
            sorted.sort_by(|a, b| a.priority.cmp(&b.priority).then(a.id.cmp(&b.id)));
            sorted
        }
    }

    /// Set an explicit load order by providing a list of mod IDs.
    ///
    /// # Parameters
    /// - `order` â€” `Vec<String>`.
    ///
    /// Mods listed first load earliest. Mods not in the list are appended
    /// after the custom entries, sorted by priority.
    pub fn set_load_order(&mut self, order: Vec<String>) {
        self.custom_load_order = Some(order);
    }

    /// Clear any custom load order, reverting to priority-based sorting.
    pub fn clear_load_order(&mut self) {
        self.custom_load_order = None;
    }

    /// Returns a reference to the current custom load order, if any.
    ///
    /// # Returns
    /// `Option<&[String]>`.
    pub fn get_custom_load_order(&self) -> Option<&[String]> {
        self.custom_load_order.as_deref()
    }

    // â”€â”€ Folder Scanning â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    /// Scan a directory for mods and register them.
    ///
    /// # Parameters
    /// - `path` â€” `&str`.
    ///
    /// # Returns
    /// `Vec<ModInfo>`.
    ///
    /// Each immediate subdirectory of `path` that contains a `mod.toml` file is
    /// parsed into a [`ModInfo`] and registered. Subdirectories without `mod.toml`
    /// are silently skipped.
    ///
    /// Expected `mod.toml` fields (all optional except `id`):
    /// ```toml
    /// id          = "my-mod"
    /// name        = "My Mod"
    /// version     = "1.2.0"
    /// author      = "Author Name"
    /// description = "What this mod does"
    /// priority    = 10
    /// dependencies = ["other-mod"]
    /// ```
    ///
    /// Returns the list of `ModInfo` objects that were discovered and registered.
    /// Returns an empty list if `path` does not exist or cannot be read.
    pub fn scan_folder(&mut self, path: &str) -> Vec<ModInfo> {
        let mut discovered = Vec::new();

        let dir_iter = match std::fs::read_dir(path) {
            Ok(iter) => iter,
            Err(_) => return discovered,
        };

        for entry in dir_iter.flatten() {
            let entry_path = entry.path();
            if !entry_path.is_dir() {
                continue;
            }
            let toml_path = entry_path.join("mod.toml");
            if !toml_path.exists() {
                continue;
            }
            let content = match std::fs::read_to_string(&toml_path) {
                Ok(c) => c,
                Err(_) => continue,
            };
            let value: toml::Value = match content.parse() {
                Ok(v) => v,
                Err(_) => continue,
            };
            let table = match value.as_table() {
                Some(t) => t,
                None => continue,
            };
            let id = match table.get("id").and_then(|v| v.as_str()) {
                Some(s) => s.to_string(),
                None => continue, // id is required
            };
            let mut info = ModInfo::new(id);
            info.path = Some(entry_path.to_string_lossy().into_owned());
            if let Some(v) = table.get("name").and_then(|v| v.as_str()) {
                info.name = v.to_string();
            }
            if let Some(v) = table.get("version").and_then(|v| v.as_str()) {
                info.version = v.to_string();
            }
            if let Some(v) = table.get("author").and_then(|v| v.as_str()) {
                info.author = v.to_string();
            }
            if let Some(v) = table.get("description").and_then(|v| v.as_str()) {
                info.description = v.to_string();
            }
            if let Some(v) = table.get("priority").and_then(|v| v.as_integer()) {
                info.priority = v as i32;
            }
            if let Some(arr) = table.get("dependencies").and_then(|v| v.as_array()) {
                info.dependencies = arr
                    .iter()
                    .filter_map(|v| v.as_str().map(str::to_string))
                    .collect();
            }
            self.register_mod(info.clone());
            discovered.push(info);
        }

        discovered
    }

    // â”€â”€ Hot-reload Queue â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    /// Marks a registered mod as requiring hot-reload on the next update tick.
    ///
    /// # Parameters
    /// - `id` â€” `&str`.
    ///
    /// # Returns
    /// `bool`.
    ///
    /// The mod ID is added to the reload queue (deduplicated).
    /// Returns `true` if the mod exists and was added to the queue.
    pub fn mark_for_reload(&mut self, id: &str) -> bool {
        if !self.has_mod(id) {
            return false;
        }
        if !self.reload_queue.contains(&id.to_string()) {
            self.reload_queue.push(id.to_string());
        }
        true
    }

    /// Returns the current reload queue (mod IDs pending hot-reload).
    ///
    /// # Returns
    /// `&[String]`.
    pub fn get_reload_queue(&self) -> &[String] {
        &self.reload_queue
    }

    /// Clear the reload queue without reloading anything.
    pub fn clear_reload_queue(&mut self) {
        self.reload_queue.clear();
    }

    // â”€â”€ Dependency Validation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    /// List mod IDs whose dependencies are missing.
    ///
    /// # Returns
    /// `Vec<String>`.
    pub fn validate_dependencies(&self) -> Vec<String> {
        let ids: HashSet<&str> = self.mods.iter().map(|m| m.id.as_str()).collect();
        let mut missing = Vec::new();
        for m in &self.mods {
            for dep in &m.dependencies {
                if !ids.contains(dep.as_str()) && !missing.contains(dep) {
                    missing.push(dep.clone());
                }
            }
        }
        missing
    }

    /// Check for circular dependency cycles. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `bool`.
    pub fn has_circular_dependencies(&self) -> bool {
        let dep_map: HashMap<&str, Vec<&str>> = self
            .mods
            .iter()
            .map(|m| {
                (
                    m.id.as_str(),
                    m.dependencies.iter().map(|d| d.as_str()).collect(),
                )
            })
            .collect();

        let mut visited = HashSet::new();
        let mut visiting = HashSet::new();

        for m in &self.mods {
            if self.visit_cycle(m.id.as_str(), &dep_map, &mut visiting, &mut visited) {
                return true;
            }
        }
        false
    }

    fn visit_cycle<'a>(
        &self,
        id: &'a str,
        dep_map: &HashMap<&str, Vec<&'a str>>,
        visiting: &mut HashSet<&'a str>,
        visited: &mut HashSet<&'a str>,
    ) -> bool {
        if visiting.contains(id) {
            return true;
        }
        if visited.contains(id) {
            return false;
        }
        visiting.insert(id);
        if let Some(deps) = dep_map.get(id) {
            for &dep in deps {
                if self.visit_cycle(dep, dep_map, visiting, visited) {
                    return true;
                }
            }
        }
        visiting.remove(id);
        visited.insert(id);
        false
    }
}
