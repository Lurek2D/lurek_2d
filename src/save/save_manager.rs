//! This file implements the practical save manager that coordinates collection, serialization, persistence, and restoration of game state.
//! Registered sections let different gameplay systems contribute their own data while still producing one coherent slot payload.
//! Dirty tracking and auto-save timing live here so disk writes happen when needed instead of on every frame or every small state change.
//! Schema versioning and migration routing are also handled here, which lets older saves evolve forward as projects change over time.
//! Serialization and compression are part of the same flow so slot files remain structured, compact, and easy to validate on load.
//! The file is therefore the operational core of persistence for games built on the engine.

use crate::binary::compress::{compress, decompress, CompressFormat};
use crate::log_msg;
use crate::runtime::log_messages::{SV01, SV02, SV03, SV04};
use base64::{engine::general_purpose::STANDARD as BASE64, Engine as _};
use mlua::prelude::{Lua, LuaError, LuaResult, LuaValue};
use std::collections::HashMap;

/// Metadata stored alongside a save slot; used by Lua to display save-select UI.
#[derive(Debug, Clone, Default)]
pub struct SlotMeta {
    /// Slot identifier string, e.g. `"slot1"`.
    pub slot: String,
    /// Unix-epoch timestamp of when the slot was written, seconds.
    pub timestamp: f64,
    /// Schema version recorded when the slot was written.
    pub version: i32,
    /// Human-readable summary text set by the game before saving.
    pub summary: String,
}

/// Manages dirty state, auto-save scheduling, schema versioning, and migration tracking for lurek.save.
#[derive(Debug, Default)]
pub struct SaveManager {
    /// Schema version declared by the game; used to select applicable migrations.
    schema_version: i32,
    /// Names of Lua tables registered for persistence via `register()`.
    registered: Vec<String>,
    /// True when any registered table has been mutated since the last save.
    dirty: bool,
    /// Active auto-save configuration: `(interval_seconds, slot_name)`; None when disabled.
    auto_save: Option<(f64, String)>,
    /// Seconds elapsed since the last auto-save flush.
    auto_save_elapsed: f64,
    /// Sorted list of schema versions for which a migration callback exists.
    migration_versions: Vec<i32>,
    /// Summary text forwarded to `SlotMeta` on the next write.
    summary: String,
}
/// Core implementation: construction, registration, versioning, auto-save, and slot path helpers.
impl SaveManager {
    /// Create a new default `SaveManager` and log its construction.
    pub fn new() -> Self {
        log_msg!(debug, SV01);
        Self::default()
    }

    /// Register a Lua table name for persistence; no-op if already registered.
    pub fn register(&mut self, name: impl Into<String>) {
        let name = name.into();
        if !self.registered.contains(&name) {
            log_msg!(debug, SV02, "{}", name);
            self.registered.push(name);
        }
    }

    /// Remove a previously registered table name; silent no-op if not found.
    pub fn unregister(&mut self, name: &str) {
        log_msg!(debug, SV03, "{}", name);
        self.registered.retain(|n| n != name);
    }

    /// Return the slice of currently registered table names.
    pub fn registered_names(&self) -> &[String] {
        &self.registered
    }

    /// Set the current schema version used for migration selection.
    pub fn set_schema_version(&mut self, version: i32) {
        self.schema_version = version;
    }

    /// Return the current schema version.
    pub fn schema_version(&self) -> i32 {
        self.schema_version
    }

    /// Record a migration entry-point version; keeps the list sorted, ignores duplicates.
    pub fn add_migration(&mut self, from_version: i32) {
        if !self.migration_versions.contains(&from_version) {
            self.migration_versions.push(from_version);
            self.migration_versions.sort();
        }
    }

    /// Return all migration versions in `[from, schema_version)` that should be applied.
    pub fn applicable_migrations(&self, from: i32) -> Vec<i32> {
        self.migration_versions
            .iter()
            .copied()
            .filter(|&v| v >= from && v < self.schema_version)
            .collect()
    }

    /// Set the dirty flag, signalling that unsaved changes exist.
    pub fn mark_dirty(&mut self) {
        self.dirty = true;
    }

    /// Return true when unsaved changes exist.
    pub fn is_dirty(&self) -> bool {
        self.dirty
    }

    /// Clear the dirty flag after a successful save.
    pub fn clear_dirty(&mut self) {
        self.dirty = false;
    }

    /// Enable auto-save to `slot` every `interval` seconds when dirty; resets elapsed counter.
    pub fn enable_auto_save(&mut self, interval: f64, slot: impl Into<String>) {
        let slot = slot.into();
        log_msg!(debug, SV04, "{} @ {:.3}s", slot, interval);
        self.auto_save = Some((interval, slot));
        self.auto_save_elapsed = 0.0;
    }

    /// Disable auto-save and reset the elapsed timer.
    pub fn disable_auto_save(&mut self) {
        self.auto_save = None;
        self.auto_save_elapsed = 0.0;
    }
    /// Advance the auto-save timer by `dt` seconds; return the slot name to save when due, else `None`.
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
    /// Reset all fields to defaults, clearing registrations and dirty state.
    pub fn reset(&mut self) {
        *self = Self::default();
    }

    /// Return the canonical file path for `slot`, e.g. `"save/slot_slot1.sav"`.
    pub fn slot_path(slot: &str) -> String {
        format!("save/slot_{}.sav", slot)
    }
    /// Store the human-readable summary written into the next `SlotMeta`.
    pub fn set_summary(&mut self, summary: String) {
        self.summary = summary;
    }

    /// Return the current summary string.
    pub fn summary(&self) -> &str {
        &self.summary
    }

    /// Validate that `content` is non-empty and return it unchanged; return `Err` on empty input.
    pub fn parse_save_string(content: &str) -> Result<String, String> {
        if content.trim().is_empty() {
            return Err("save file is empty".to_string());
        }
        Ok(content.to_string())
    }
}
/// Serialize a `HashMap<String, SaveValue>` to a Lua table literal string at `depth` indent level; return `Err` if depth > 32.
pub fn serialize_table(data: &HashMap<String, SaveValue>, depth: u32) -> Result<String, String> {
    if depth > 32 {
        return Err("serialization depth limit exceeded (>32)".to_string());
    }
    let mut out = String::from("{\n");
    let indent = "  ".repeat((depth + 1) as usize);
    let close_indent = "  ".repeat(depth as usize);
    let mut keys: Vec<&String> = data.keys().collect();
    keys.sort_unstable();
    for key in keys {
        let value = data
            .get(key)
            .ok_or_else(|| format!("serialize_table: missing value for key '{key}'"))?;
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
/// Serialize a single `SaveValue` to its Lua literal representation; delegates tables to `serialize_table`.
pub fn serialize_value(value: &SaveValue, depth: u32) -> Result<String, String> {
    match value {
        SaveValue::Nil => Ok("nil".to_string()),
        SaveValue::Bool(b) => Ok(b.to_string()),
        SaveValue::Number(n) => Ok(format!("{}", n)),
        SaveValue::Str(s) => Ok(format!("\"{}\"", escape_lua_str(s))),
        SaveValue::Table(t) => serialize_table(t, depth),
    }
}
/// Lua-serializable value tree produced from a Lua table before writing to disk.
#[derive(Debug, Clone)]
pub enum SaveValue {
    /// Lua nil.
    Nil,
    /// Lua boolean.
    Bool(bool),
    /// Lua number (integer or float unified to f64).
    Number(f64),
    /// Lua string.
    Str(String),
    /// Lua table, keys serialized as strings.
    Table(HashMap<String, SaveValue>),
}
/// Conversion from Lua values into the serializable `SaveValue` tree.
impl SaveValue {
    /// Convert a `LuaValue` into `SaveValue`; return `LuaError` for unsupported types or non-string table keys.
    pub fn from_lua(value: &LuaValue) -> LuaResult<Self> {
        match value {
            LuaValue::Nil => Ok(SaveValue::Nil),
            LuaValue::Boolean(b) => Ok(SaveValue::Bool(*b)),
            LuaValue::Integer(i) => Ok(SaveValue::Number(*i as f64)),
            LuaValue::Number(n) => Ok(SaveValue::Number(*n)),
            LuaValue::String(s) => Ok(SaveValue::Str(s.to_str()?.to_string())),
            LuaValue::Table(t) => {
                let mut map = HashMap::new();
                for pair in t.clone().pairs::<LuaValue, LuaValue>() {
                    let (k, v) = pair?;
                    let key_str = match &k {
                        LuaValue::String(s) => s.to_str()?.to_string(),
                        LuaValue::Integer(i) => i.to_string(),
                        LuaValue::Number(n) => format!("{}", n),
                        _ => {
                            return Err(LuaError::RuntimeError(format!(
                                "cannot serialize table key of type {}",
                                k.type_name()
                            )))
                        }
                    };
                    map.insert(key_str, SaveValue::from_lua(&v)?);
                }
                Ok(SaveValue::Table(map))
            }
            other => Err(LuaError::RuntimeError(format!(
                "cannot serialize value of type {}",
                other.type_name()
            ))),
        }
    }

    /// Convert a `SaveValue` tree back into the equivalent Lua value.
    pub fn to_lua<'lua>(&self, lua: &'lua Lua) -> LuaResult<LuaValue<'lua>> {
        match self {
            SaveValue::Nil => Ok(LuaValue::Nil),
            SaveValue::Bool(value) => Ok(LuaValue::Boolean(*value)),
            SaveValue::Number(value) => Ok(LuaValue::Number(*value)),
            SaveValue::Str(value) => lua.create_string(value).map(LuaValue::String),
            SaveValue::Table(entries) => {
                let table = lua.create_table()?;
                for (key, value) in entries {
                    table.set(key.as_str(), value.to_lua(lua)?)?;
                }
                Ok(LuaValue::Table(table))
            }
        }
    }
}
/// Return true if `s` is a valid Lua identifier (ASCII alpha/underscore start, alphanumeric rest).
fn is_lua_identifier(s: &str) -> bool {
    let mut chars = s.chars();
    match chars.next() {
        Some(c) if c.is_ascii_alphabetic() || c == '_' => {}
        _ => return false,
    }
    chars.all(|c| c.is_ascii_alphanumeric() || c == '_')
}
/// Escape backslash, double-quote, newline, carriage-return, and null for Lua string literals.
fn escape_lua_str(s: &str) -> String {
    s.replace('\\', "\\\\")
        .replace('"', "\\\"")
        .replace('\n', "\\n")
        .replace('\r', "\\r")
        .replace('\0', "\\0")
}
/// Header marker prepended to compressed save files to distinguish them from plain Lua saves.
const COMPRESSED_MARKER: &str = "--[[COMPRESSED]]";

/// Compress `plain` with LZ4 and Base64-encode it; return a two-line string with `COMPRESSED_MARKER` header.
pub fn compress_save_content(plain: &str) -> Result<String, String> {
    let compressed = compress(plain.as_bytes(), CompressFormat::Lz4, 1)?;
    let encoded = BASE64.encode(&compressed);
    Ok(format!("{}\nreturn \"{}\"\n", COMPRESSED_MARKER, encoded))
}
/// Decompress a `COMPRESSED_MARKER`-prefixed save; return `raw` unchanged if not compressed.
pub fn decompress_save_content(raw: &str) -> Result<String, String> {
    if !raw.starts_with(COMPRESSED_MARKER) {
        return Ok(raw.to_string());
    }
    let encoded = raw
        .lines()
        .nth(1)
        .and_then(|line| line.strip_prefix("return \""))
        .and_then(|s| s.strip_suffix('"'))
        .unwrap_or_default();
    let compressed = BASE64
        .decode(encoded)
        .map_err(|e| format!("base64 decode: {}", e))?;
    let bytes = decompress(&compressed, CompressFormat::Lz4)?;
    String::from_utf8(bytes).map_err(|e| format!("utf8: {}", e))
}

/// Parse a serialized `return { ... }` save payload back into a root table.
pub fn parse_save_table(content: &str) -> Result<HashMap<String, SaveValue>, String> {
    let validated = SaveManager::parse_save_string(content)?;
    let mut parser = SaveParser::new(&validated);
    match parser.parse_root()? {
        SaveValue::Table(table) => Ok(table),
        _ => Err("save root must be a table".to_string()),
    }
}

/// Minimal parser for the constrained Lua table literal format emitted by `serialize_table`.
struct SaveParser<'a> {
    input: &'a str,
    offset: usize,
}

impl<'a> SaveParser<'a> {
    fn new(input: &'a str) -> Self {
        Self { input, offset: 0 }
    }

    fn parse_root(&mut self) -> Result<SaveValue, String> {
        self.skip_whitespace();
        self.expect_keyword("return")?;
        self.skip_whitespace();
        let value = self.parse_value()?;
        self.skip_whitespace();
        if self.peek_char().is_some() {
            return Err("unexpected trailing content after save root".to_string());
        }
        Ok(value)
    }

    fn parse_value(&mut self) -> Result<SaveValue, String> {
        self.skip_whitespace();
        match self.peek_char() {
            Some('{') => self.parse_table().map(SaveValue::Table),
            Some('"') => self.parse_string().map(SaveValue::Str),
            Some('t') => {
                self.expect_keyword("true")?;
                Ok(SaveValue::Bool(true))
            }
            Some('f') => {
                self.expect_keyword("false")?;
                Ok(SaveValue::Bool(false))
            }
            Some('n') => {
                self.expect_keyword("nil")?;
                Ok(SaveValue::Nil)
            }
            Some('-' | '0'..='9') => self.parse_number().map(SaveValue::Number),
            Some(other) => Err(format!("unexpected save token '{other}'")),
            None => Err("unexpected end of save content".to_string()),
        }
    }

    fn parse_table(&mut self) -> Result<HashMap<String, SaveValue>, String> {
        self.expect_char('{')?;
        self.skip_whitespace();
        let mut table = HashMap::new();
        while !matches!(self.peek_char(), Some('}')) {
            let key = self.parse_key()?;
            self.skip_whitespace();
            self.expect_char('=')?;
            let value = self.parse_value()?;
            table.insert(key, value);
            self.skip_whitespace();
            if matches!(self.peek_char(), Some(',')) {
                self.next_char();
                self.skip_whitespace();
                if matches!(self.peek_char(), Some('}')) {
                    break;
                }
            } else {
                break;
            }
        }
        self.expect_char('}')?;
        Ok(table)
    }

    fn parse_key(&mut self) -> Result<String, String> {
        self.skip_whitespace();
        if matches!(self.peek_char(), Some('[')) {
            self.expect_char('[')?;
            let key = self.parse_string()?;
            self.expect_char(']')?;
            return Ok(key);
        }
        self.parse_identifier()
    }

    fn parse_identifier(&mut self) -> Result<String, String> {
        let mut identifier = String::new();
        let Some(first) = self.peek_char() else {
            return Err("unexpected end of save content while reading key".to_string());
        };
        if !(first.is_ascii_alphabetic() || first == '_') {
            return Err(format!("invalid save key start '{first}'"));
        }
        identifier.push(self.next_char().unwrap_or(first));
        while let Some(ch) = self.peek_char() {
            if ch.is_ascii_alphanumeric() || ch == '_' {
                identifier.push(self.next_char().unwrap_or(ch));
            } else {
                break;
            }
        }
        Ok(identifier)
    }

    fn parse_string(&mut self) -> Result<String, String> {
        self.expect_char('"')?;
        let mut out = String::new();
        loop {
            let Some(ch) = self.next_char() else {
                return Err("unterminated save string literal".to_string());
            };
            match ch {
                '"' => return Ok(out),
                '\\' => {
                    let escaped = self
                        .next_char()
                        .ok_or_else(|| "unterminated save string escape".to_string())?;
                    match escaped {
                        '\\' => out.push('\\'),
                        '"' => out.push('"'),
                        'n' => out.push('\n'),
                        'r' => out.push('\r'),
                        '0' => out.push('\0'),
                        other => out.push(other),
                    }
                }
                other => out.push(other),
            }
        }
    }

    fn parse_number(&mut self) -> Result<f64, String> {
        let start = self.offset;
        if matches!(self.peek_char(), Some('-')) {
            self.next_char();
        }
        self.consume_digits();
        if matches!(self.peek_char(), Some('.')) {
            self.next_char();
            self.consume_digits();
        }
        if matches!(self.peek_char(), Some('e' | 'E')) {
            self.next_char();
            if matches!(self.peek_char(), Some('+' | '-')) {
                self.next_char();
            }
            self.consume_digits();
        }
        let raw = &self.input[start..self.offset];
        raw.parse::<f64>()
            .map_err(|error| format!("invalid save number '{raw}': {error}"))
    }

    fn consume_digits(&mut self) {
        while matches!(self.peek_char(), Some('0'..='9')) {
            self.next_char();
        }
    }

    fn expect_keyword(&mut self, keyword: &str) -> Result<(), String> {
        if !self.remaining().starts_with(keyword) {
            return Err(format!("expected '{keyword}' in save payload"));
        }
        self.offset += keyword.len();
        Ok(())
    }

    fn expect_char(&mut self, expected: char) -> Result<(), String> {
        match self.next_char() {
            Some(actual) if actual == expected => Ok(()),
            Some(actual) => Err(format!("expected '{expected}' but found '{actual}'")),
            None => Err(format!(
                "expected '{expected}' but reached end of save content"
            )),
        }
    }

    fn skip_whitespace(&mut self) {
        while matches!(self.peek_char(), Some(ch) if ch.is_whitespace()) {
            self.next_char();
        }
    }

    fn remaining(&self) -> &'a str {
        &self.input[self.offset..]
    }

    fn peek_char(&self) -> Option<char> {
        self.remaining().chars().next()
    }

    fn next_char(&mut self) -> Option<char> {
        let ch = self.peek_char()?;
        self.offset += ch.len_utf8();
        Some(ch)
    }
}
