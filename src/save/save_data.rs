//! Save/load slot system with collectors, schema versioning, dirty tracking,
//! and auto-save.
//!
//! **NOTE**: This file is NOT declared in `mod.rs` and is therefore dead code.
//! The canonical implementations of [`SaveManager`], [`SaveValue`],
//! [`serialize_table`], and [`serialize_value`] live in `save_manager.rs`.
//! This file appears to be an earlier copy retained during refactoring.
//! See `TODO(dedup)` in `IDEA.md`.
//!
//! This module is part of Lurek2D's `save` subsystem and provides the implementation
//! details for save data-related operations and data management.
//! Key types exported from this module: `SlotMeta`, `SaveManager`, `SaveValue`.
//! Primary functions: `new()`, `register()`, `unregister()`, `registered_names()`.
//!
//! All public items are documented. See the parent module for architectural context
//! and the `lurek.*` Lua API for the scripting interface.

use std::collections::HashMap;
use crate::runtime::log_messages::{SV01_SAVE_INIT};
use crate::log_msg;

/// Metadata extracted from a save-slot header without loading the full save data.
///
/// # Fields
/// - `slot` â€” `String`.
/// - `timestamp` â€” `f64`.
/// - `version` â€” `i32`.
/// - `summary` â€” `String`.
#[derive(Debug, Clone, Default)]
pub struct SlotMeta {
    /// Slot name.
    pub slot: String,
    /// Unix epoch timestamp.
    pub timestamp: f64,
    /// Schema version.
    pub version: i32,
    /// Optional summary string.
    pub summary: String,
}

/// Pure-data save manager providing registration of named collectors,
/// schema versioning, dirty-state tracking, and auto-save timer.
///
/// Actual serialisation and filesystem calls happen on the Lua side;
/// this struct tracks the bookkeeping.
///
/// # Fields
/// - `schema_version` â€” `i32`.
/// - `registered` â€” `Vec<String>`.
/// - `dirty` â€” `bool`.
/// - `auto_save` â€” `Option<(f64`.
/// - `auto_save_elapsed` â€” `f64`.
/// - `migration_versions` â€” `Vec<i32>`.
#[derive(Debug, Default)]
pub struct SaveManager {
    /// Current schema version for new saves.
    schema_version: i32,
    /// Registered collector module names.
    registered: Vec<String>,
    /// Whether data has been modified since last save/load.
    dirty: bool,
    /// Auto-save interval (seconds) and target slot.
    auto_save: Option<(f64, String)>,
    /// Elapsed time since last auto-save.
    auto_save_elapsed: f64,
    /// Migration version keys (sorted ascending on use).
    migration_versions: Vec<i32>,
}

impl SaveManager {
    /// Create a new empty SaveManager. Returns a fully initialised instance with all fields set to their initial values.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        log_msg!(debug, SV01_SAVE_INIT);
        Self::default()
    }

    /// Register a named collector module. Panics in debug mode if the same entity is registered twice.
    ///
    /// # Parameters
    /// - `name` â€” `impl Into<String>`.
    pub fn register(&mut self, name: impl Into<String>) {
        let name = name.into();
        if !self.registered.contains(&name) {
            self.registered.push(name);
        }
    }

    /// Removes a previously registered data collector from the save/restore cycle.
    ///
    /// # Parameters
    /// - `name` â€” `&str`.
    pub fn unregister(&mut self, name: &str) {
        self.registered.retain(|n| n != name);
    }

    /// Get registered module names. Panics in debug mode if the same entity is registered twice.
    ///
    /// # Returns
    /// `&[String]`.
    pub fn registered_names(&self) -> &[String] {
        &self.registered
    }

    /// Set the current schema version. Replaces the current schema version value; callers hold responsibility for maintaining consistency with related fields.
    ///
    /// # Parameters
    /// - `version` â€” `i32`.
    pub fn set_schema_version(&mut self, version: i32) {
        self.schema_version = version;
    }

    /// Returns the schema version number used to detect save-file format upgrades.
    ///
    /// # Returns
    /// `i32`.
    pub fn schema_version(&self) -> i32 {
        self.schema_version
    }

    /// Record a migration version key. The insertion is O(1) amortised unless a resize is triggered.
    ///
    /// # Parameters
    /// - `from_version` â€” `i32`.
    pub fn add_migration(&mut self, from_version: i32) {
        if !self.migration_versions.contains(&from_version) {
            self.migration_versions.push(from_version);
            self.migration_versions.sort();
        }
    }

    /// Get migration versions >=`from` and < current, in ascending order.
    ///
    /// # Parameters
    /// - `from` â€” `i32`.
    ///
    /// # Returns
    /// `Vec<i32>`.
    pub fn applicable_migrations(&self, from: i32) -> Vec<i32> {
        self.migration_versions
            .iter()
            .copied()
            .filter(|&v| v >= from && v < self.schema_version)
            .collect()
    }

    /// Mark data as dirty (modified since last save/load).
    pub fn mark_dirty(&mut self) {
        self.dirty = true;
    }

    /// Whether data is dirty. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_dirty(&self) -> bool {
        self.dirty
    }

    /// Clear the dirty flag (called after save/load).
    pub fn clear_dirty(&mut self) {
        self.dirty = false;
    }

    /// Enable auto-save with interval and target slot.
    ///
    /// # Parameters
    /// - `interval` â€” `f64`.
    /// - `slot` â€” `impl Into<String>`.
    pub fn enable_auto_save(&mut self, interval: f64, slot: impl Into<String>) {
        self.auto_save = Some((interval, slot.into()));
        self.auto_save_elapsed = 0.0;
    }

    /// Disables the automatic save timer, preventing any further background saves.
    pub fn disable_auto_save(&mut self) {
        self.auto_save = None;
        self.auto_save_elapsed = 0.0;
    }

    /// Advance the auto-save timer. Returns `Some(slot)` if a save should trigger.
    ///
    /// # Parameters
    /// - `dt` â€” `f64`.
    ///
    /// # Returns
    /// `Option<String>`.
    pub fn update(&mut self, dt: f64) -> Option<String> {
        if let Some((interval, ref slot)) = self.auto_save {
            self.auto_save_elapsed += dt;
            if self.dirty && self.auto_save_elapsed >= interval {
                self.auto_save_elapsed = 0.0;
                return Some(slot.clone());
            }
        }
        None
    }

    /// Reset all state. After this call the container is in the same state as immediately after construction.
    pub fn reset(&mut self) {
        *self = Self::default();
    }
}

/// Serialize a simple Lua-compatible value hierarchy into a `return { ... }` string.
///
/// # Parameters
/// - `data` â€” `&HashMap<String, SaveValue>`.
/// - `depth` â€” `u32`.
///
/// # Returns
/// `Result<String, String>`.
///
/// Supports nil, bool, number (f64), string, and nested tables (HashMap).
/// Does not handle userdata, functions, or circular references.
pub fn serialize_table(data: &HashMap<String, SaveValue>, depth: u32) -> Result<String, String> {
    if depth > 32 {
        return Err("serialization depth limit exceeded (>32)".to_string());
    }
    let mut out = String::from("{\n");
    let indent = "  ".repeat((depth + 1) as usize);
    let close_indent = "  ".repeat(depth as usize);
    for (key, value) in data {
        let key_str = if is_lua_identifier(key) {
            key.clone()
        } else {
            format!("[\"{}\"]", escape_lua_str(key))
        };
        out.push_str(&format!(
            "{}{} = {},\n",
            indent,
            key_str,
            serialize_value(value, depth + 1)?
        ));
    }
    out.push_str(&format!("{}}}", close_indent));
    Ok(out)
}

/// Serializes a single Lua value into the TOML-compatible wire format.
///
/// # Parameters
/// - `value` â€” `&SaveValue`.
/// - `depth` â€” `u32`.
///
/// # Returns
/// `Result<String, String>`.
pub fn serialize_value(value: &SaveValue, depth: u32) -> Result<String, String> {
    match value {
        SaveValue::Nil => Ok("nil".to_string()),
        SaveValue::Bool(b) => Ok(b.to_string()),
        SaveValue::Number(n) => Ok(format!("{}", n)),
        SaveValue::Str(s) => Ok(format!("\"{}\"", escape_lua_str(s))),
        SaveValue::Table(t) => serialize_table(t, depth),
    }
}

/// A simple value type matching the Lua subset we can serialize.
///
/// # Variants
/// - `Nil` â€” Nil variant.
/// - `Bool` â€” Bool variant.
/// - `Number` â€” Number variant.
/// - `Str` â€” Str variant.
/// - `Table` â€” Table variant.
#[derive(Debug, Clone)]
pub enum SaveValue {
    /// Lua nil.
    Nil,
    /// Lua boolean.
    Bool(bool),
    /// Lua number.
    Number(f64),
    /// Lua string.
    Str(String),
    /// Lua table (string keys only for save data).
    Table(HashMap<String, SaveValue>),
}

fn is_lua_identifier(s: &str) -> bool {
    let mut chars = s.chars();
    match chars.next() {
        Some(c) if c.is_ascii_alphabetic() || c == '_' => {}
        _ => return false,
    }
    chars.all(|c| c.is_ascii_alphanumeric() || c == '_')
}

fn escape_lua_str(s: &str) -> String {
    s.replace('\\', "\\\\")
        .replace('"', "\\\"")
        .replace('\n', "\\n")
        .replace('\r', "\\r")
        .replace('\0', "\\0")
}
