//! Owns the save manager owner for the save subsystem and keeps its rules local to this file.
//! Keeps save data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how save manager data is validated, transformed, or stored before neighboring systems use it.
//! Owns save behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on save manager behavior while Lua registration stays elsewhere.
//! Documents where save callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing save manager defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the save state that can explain them while keeping call sites explicit.
//! Preserves deterministic behavior by keeping save manager calculations explicit at their owner boundary.
//! Provides the local adaptation layer that lets callers avoid duplicating save rules while keeping call sites explicit.
//! Maintains small helper surfaces so broader engine modules can compose save manager behavior safely.
//! Protects subsystem contracts by keeping resource, cache, or state mutations visible in one place.

use crate::binary::{
    compress::{compress, decompress, CompressFormat},
    hash, HashAlgorithm,
};
use crate::log_msg;
use crate::runtime::log_messages::{SV01, SV02, SV03, SV04};
use base64::{engine::general_purpose::STANDARD as BASE64, Engine as _};
use mlua::prelude::{Lua, LuaError, LuaResult, LuaValue};
use std::collections::{HashMap, HashSet};
use std::fmt;

const LEGACY_COMPRESSED_MARKER: &str = "--[[COMPRESSED]]";
const COMPRESSED_HEADER_PREFIX: &str = "--[[LUREK_SAVE v1 ";
const COMPRESSED_HEADER_SUFFIX: &str = "]]";
const COMPRESSED_ALGORITHM: &str = "lz4";
const DEFAULT_SLOT_ROOT: &str = "save";

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

/// Maximum parser input, nesting, key, string, and numeric token sizes accepted for save payloads.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SaveParseLimits {
    /// Maximum input payload size in bytes.
    pub max_input_bytes: usize,
    /// Maximum table nesting depth.
    pub max_depth: usize,
    /// Maximum total key/value entries across the payload.
    pub max_entries: usize,
    /// Maximum key length in Unicode scalar values.
    pub max_key_chars: usize,
    /// Maximum string literal length in Unicode scalar values.
    pub max_string_chars: usize,
    /// Maximum numeric token width in bytes.
    pub max_number_chars: usize,
}

impl Default for SaveParseLimits {
    fn default() -> Self {
        Self {
            max_input_bytes: 1024 * 1024,
            max_depth: 32,
            max_entries: 16_384,
            max_key_chars: 128,
            max_string_chars: 16_384,
            max_number_chars: 64,
        }
    }
}

/// Maximum traversal cost accepted when converting Lua values into `SaveValue`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SaveLuaLimits {
    /// Maximum recursive table nesting depth.
    pub max_depth: usize,
    /// Maximum total node count across the converted value tree.
    pub max_total_nodes: usize,
    /// Maximum entries accepted in a single table.
    pub max_table_entries: usize,
    /// Maximum key length in Unicode scalar values.
    pub max_key_chars: usize,
    /// Maximum string length in Unicode scalar values.
    pub max_string_chars: usize,
}

impl Default for SaveLuaLimits {
    fn default() -> Self {
        Self {
            max_depth: 32,
            max_total_nodes: 16_384,
            max_table_entries: 4_096,
            max_key_chars: 128,
            max_string_chars: 16_384,
        }
    }
}

/// Maximum encoded, compressed, and decompressed payload sizes accepted by save compression helpers.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SaveCompressionLimits {
    /// Maximum raw save file size in bytes.
    pub max_raw_bytes: usize,
    /// Maximum Base64 payload size in bytes.
    pub max_base64_bytes: usize,
    /// Maximum compressed byte size after Base64 decode.
    pub max_compressed_bytes: usize,
    /// Maximum decompressed UTF-8 payload size in bytes.
    pub max_decompressed_bytes: usize,
}

impl Default for SaveCompressionLimits {
    fn default() -> Self {
        Self {
            max_raw_bytes: 1024 * 1024,
            max_base64_bytes: 768 * 1024,
            max_compressed_bytes: 512 * 1024,
            max_decompressed_bytes: 1024 * 1024,
        }
    }
}

/// High-level save limits applied to slot names, compression, parsing, and Lua conversion.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SaveLimits {
    /// Maximum slot name length in Unicode scalar values.
    pub slot_name_max_chars: usize,
    /// Parser limits for save payloads.
    pub parse: SaveParseLimits,
    /// Compression limits for compressed save files.
    pub compression: SaveCompressionLimits,
    /// Lua conversion limits for save collection.
    pub lua: SaveLuaLimits,
}

impl Default for SaveLimits {
    fn default() -> Self {
        Self {
            slot_name_max_chars: 64,
            parse: SaveParseLimits::default(),
            compression: SaveCompressionLimits::default(),
            lua: SaveLuaLimits::default(),
        }
    }
}

/// Persistence policy for safe slot writes.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SaveWritePolicy {
    /// Create a `.bak` copy before replacing the primary save file.
    pub keep_backup: bool,
    /// Prefix used when creating temporary save files in the save directory.
    pub temp_prefix: String,
}

impl Default for SaveWritePolicy {
    fn default() -> Self {
        Self {
            keep_backup: true,
            temp_prefix: "slot_write_".to_string(),
        }
    }
}

/// Load policy for primary-versus-backup save recovery.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SaveLoadPolicy {
    /// Whether the loader may fall back to `.bak` when the primary save is missing or corrupt.
    pub allow_backup_fallback: bool,
}

impl Default for SaveLoadPolicy {
    fn default() -> Self {
        Self {
            allow_backup_fallback: true,
        }
    }
}

/// Structured migration routing outcome from one schema version to another.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MigrationPlan {
    /// Save version being loaded.
    pub from_version: i32,
    /// Target schema version owned by the running game.
    pub to_version: i32,
    /// Ordered migration entry points that should run.
    pub steps: Vec<i32>,
    /// Missing migration entry points that block a strict migration chain.
    pub missing_steps: Vec<i32>,
}

/// Rolling diagnostics recorded by the save manager while rejecting unsafe input or recovering from failures.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct SaveDiagnostics {
    messages: Vec<String>,
}

impl SaveDiagnostics {
    /// Return the recorded diagnostic messages in insertion order.
    pub fn messages(&self) -> &[String] {
        &self.messages
    }

    /// Return the latest diagnostic message when one exists.
    pub fn last(&self) -> Option<&str> {
        self.messages.last().map(String::as_str)
    }

    /// Append a new diagnostic message.
    pub fn record(&mut self, message: impl Into<String>) {
        self.messages.push(message.into());
    }

    /// Remove all recorded messages.
    pub fn clear(&mut self) {
        self.messages.clear();
    }
}

/// Structured save failure covering slot validation, limits, migration routing, integrity, and policy errors.
#[derive(Debug, Clone, PartialEq)]
pub enum SaveError {
    /// Slot name failed the save naming policy.
    InvalidSlotName { slot: String, reason: String },
    /// Auto-save interval was not finite and positive.
    InvalidAutoSaveInterval { interval: f64 },
    /// Frame delta time was negative or non-finite.
    InvalidDeltaTime { dt: f64 },
    /// Parser limit exceeded while reading a save payload.
    ParseLimit {
        what: &'static str,
        actual: usize,
        max: usize,
    },
    /// Lua conversion limit exceeded while collecting data for save.
    LuaLimit {
        what: &'static str,
        actual: usize,
        max: usize,
    },
    /// Compression or decompression limit exceeded.
    CompressionLimit {
        what: &'static str,
        actual: usize,
        max: usize,
    },
    /// Save payload syntax or header parsing failure.
    Parse(String),
    /// Compression or Base64 decode failure.
    Compression(String),
    /// Save integrity verification failure.
    Integrity(String),
    /// Encountered a cyclic Lua table during save collection.
    CyclicLuaTable,
    /// Encountered a non-finite number during save serialization or parsing.
    NonFiniteNumber { context: &'static str },
    /// Migration chain is incomplete for the requested version jump.
    MigrationChainIncomplete {
        from: i32,
        to: i32,
        missing: Vec<i32>,
    },
    /// Save file was produced by a newer schema than the running game understands.
    MigrationDowngrade { from: i32, to: i32 },
    /// IO or platform save policy failure.
    Io(String),
}

impl fmt::Display for SaveError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            SaveError::InvalidSlotName { slot, reason } => {
                write!(f, "invalid slot name '{}': {}", slot, reason)
            }
            SaveError::InvalidAutoSaveInterval { interval } => {
                write!(
                    f,
                    "auto-save interval must be finite and > 0 seconds (got {})",
                    interval
                )
            }
            SaveError::InvalidDeltaTime { dt } => {
                write!(f, "delta time must be finite and >= 0 seconds (got {})", dt)
            }
            SaveError::ParseLimit { what, actual, max } => {
                write!(
                    f,
                    "save parse {} limit exceeded: {} > {}",
                    what, actual, max
                )
            }
            SaveError::LuaLimit { what, actual, max } => {
                write!(f, "save lua {} limit exceeded: {} > {}", what, actual, max)
            }
            SaveError::CompressionLimit { what, actual, max } => {
                write!(
                    f,
                    "save compression {} limit exceeded: {} > {}",
                    what, actual, max
                )
            }
            SaveError::Parse(reason) => write!(f, "save parse error: {}", reason),
            SaveError::Compression(reason) => write!(f, "save compression error: {}", reason),
            SaveError::Integrity(reason) => write!(f, "save integrity error: {}", reason),
            SaveError::CyclicLuaTable => write!(f, "cyclic Lua table cannot be serialized"),
            SaveError::NonFiniteNumber { context } => {
                write!(f, "non-finite number is not allowed in {}", context)
            }
            SaveError::MigrationChainIncomplete { from, to, missing } => write!(
                f,
                "missing migration steps from schema {} to {}: {:?}",
                from, to, missing
            ),
            SaveError::MigrationDowngrade { from, to } => write!(
                f,
                "save schema {} is newer than current schema {}",
                from, to
            ),
            SaveError::Io(reason) => write!(f, "save IO error: {}", reason),
        }
    }
}

impl std::error::Error for SaveError {}

impl From<SaveError> for LuaError {
    fn from(value: SaveError) -> Self {
        LuaError::RuntimeError(value.to_string())
    }
}

/// Manages dirty state, auto-save scheduling, schema versioning, migration tracking, and safety policy for lurek.save.
#[derive(Debug, Clone)]
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
    /// Save naming, parse, compression, and conversion limits.
    limits: SaveLimits,
    /// Atomic write and backup policy.
    write_policy: SaveWritePolicy,
    /// Save recovery policy for load.
    load_policy: SaveLoadPolicy,
    /// Recent diagnostics emitted while skipping unsafe work or falling back to recovery.
    diagnostics: SaveDiagnostics,
}

impl Default for SaveManager {
    fn default() -> Self {
        Self {
            schema_version: 0,
            registered: Vec::new(),
            dirty: false,
            auto_save: None,
            auto_save_elapsed: 0.0,
            migration_versions: Vec::new(),
            summary: String::new(),
            limits: SaveLimits::default(),
            write_policy: SaveWritePolicy::default(),
            load_policy: SaveLoadPolicy::default(),
            diagnostics: SaveDiagnostics::default(),
        }
    }
}

/// Core implementation: construction, registration, versioning, auto-save, slot path helpers, and safety policy.
impl SaveManager {
    /// Create a new default `SaveManager` and log its construction.
    pub fn new() -> Self {
        log_msg!(debug, SV01);
        Self::default()
    }

    /// Return the active save limits.
    pub fn limits(&self) -> &SaveLimits {
        &self.limits
    }

    /// Return the active atomic write policy.
    pub fn write_policy(&self) -> &SaveWritePolicy {
        &self.write_policy
    }

    /// Return the active load recovery policy.
    pub fn load_policy(&self) -> &SaveLoadPolicy {
        &self.load_policy
    }

    /// Return diagnostics emitted by recent save operations.
    pub fn diagnostics(&self) -> &SaveDiagnostics {
        &self.diagnostics
    }

    /// Record a save diagnostic for later inspection.
    pub fn record_diagnostic(&mut self, message: impl Into<String>) {
        self.diagnostics.record(message);
    }

    /// Remove previously recorded diagnostics.
    pub fn clear_diagnostics(&mut self) {
        self.diagnostics.clear();
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
            self.migration_versions.sort_unstable();
        }
    }

    /// Return all registered migration versions in `[from, schema_version)` without validating chain completeness.
    pub fn applicable_migrations(&self, from: i32) -> Vec<i32> {
        self.migration_versions
            .iter()
            .copied()
            .filter(|&v| v >= from && v < self.schema_version)
            .collect()
    }

    /// Build a strict migration plan and fail when a required step is missing or the save is newer than the runtime schema.
    pub fn migration_plan(&self, from: i32) -> Result<MigrationPlan, SaveError> {
        if from > self.schema_version {
            return Err(SaveError::MigrationDowngrade {
                from,
                to: self.schema_version,
            });
        }
        let mut steps = Vec::new();
        let mut missing_steps = Vec::new();
        for version in from..self.schema_version {
            if self.migration_versions.contains(&version) {
                steps.push(version);
            } else {
                missing_steps.push(version);
            }
        }
        if !missing_steps.is_empty() {
            return Err(SaveError::MigrationChainIncomplete {
                from,
                to: self.schema_version,
                missing: missing_steps,
            });
        }
        Ok(MigrationPlan {
            from_version: from,
            to_version: self.schema_version,
            steps,
            missing_steps: Vec::new(),
        })
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
    pub fn enable_auto_save(
        &mut self,
        interval: f64,
        slot: impl Into<String>,
    ) -> Result<(), SaveError> {
        if !interval.is_finite() || interval <= 0.0 {
            return Err(SaveError::InvalidAutoSaveInterval { interval });
        }
        let slot = slot.into();
        self.validate_slot_name(&slot)?;
        log_msg!(debug, SV04, "{} @ {:.3}s", slot, interval);
        self.auto_save = Some((interval, slot));
        self.auto_save_elapsed = 0.0;
        Ok(())
    }

    /// Disable auto-save and reset the elapsed timer.
    pub fn disable_auto_save(&mut self) {
        self.auto_save = None;
        self.auto_save_elapsed = 0.0;
    }

    /// Advance the auto-save timer by `dt` seconds; return the slot name to save when due, else `None`.
    pub fn update(&mut self, dt: f64) -> Option<String> {
        if !dt.is_finite() || dt < 0.0 {
            self.record_diagnostic(SaveError::InvalidDeltaTime { dt }.to_string());
            return None;
        }
        if let Some((interval, ref slot)) = self.auto_save {
            if !interval.is_finite() || interval <= 0.0 {
                self.record_diagnostic(SaveError::InvalidAutoSaveInterval { interval }.to_string());
                return None;
            }
            self.auto_save_elapsed += dt;
            if self.dirty && self.auto_save_elapsed >= interval {
                self.auto_save_elapsed = 0.0;
                return Some(slot.clone());
            }
        }
        None
    }

    /// Reset all fields to defaults, clearing registrations, policies, diagnostics, and dirty state.
    pub fn reset(&mut self) {
        *self = Self::default();
    }

    /// Return the legacy permissive file path for `slot`, e.g. `"save/slot_slot1.sav"`.
    pub fn slot_path(slot: &str) -> String {
        format!("{DEFAULT_SLOT_ROOT}/slot_{}.sav", slot)
    }

    /// Validate the save slot naming policy.
    pub fn validate_slot_name(&self, slot: &str) -> Result<(), SaveError> {
        validate_slot_name_with_limits(slot, &self.limits)
    }

    /// Return a validated slot path under the logical `save/` root.
    pub fn slot_path_checked(&self, slot: &str) -> Result<String, SaveError> {
        self.validate_slot_name(slot)?;
        Ok(Self::slot_path(slot))
    }

    /// Return the backup slot path for a validated slot.
    pub fn backup_slot_path(&self, slot: &str) -> Result<String, SaveError> {
        Ok(format!("{}.bak", self.slot_path_checked(slot)?))
    }

    /// Store the human-readable summary written into the next `SlotMeta`.
    pub fn set_summary(&mut self, summary: String) {
        self.summary = summary;
    }

    /// Return the current summary string.
    pub fn summary(&self) -> &str {
        &self.summary
    }

    /// Validate that `content` is non-empty using default parse limits.
    pub fn parse_save_string(content: &str) -> Result<String, SaveError> {
        parse_save_string_with_limits(content, &SaveParseLimits::default())
    }

    /// Validate that `content` is non-empty and within the manager parser input budget.
    pub fn parse_save_string_checked(&self, content: &str) -> Result<String, SaveError> {
        parse_save_string_with_limits(content, &self.limits.parse)
    }
}

/// Serialize a `HashMap<String, SaveValue>` to a Lua table literal string at `depth` indent level.
pub fn serialize_table(data: &HashMap<String, SaveValue>, depth: u32) -> Result<String, String> {
    serialize_table_with_limit(data, depth, SaveParseLimits::default().max_depth as u32)
        .map_err(|error| error.to_string())
}

fn serialize_table_with_limit(
    data: &HashMap<String, SaveValue>,
    depth: u32,
    max_depth: u32,
) -> Result<String, SaveError> {
    if depth > max_depth {
        return Err(SaveError::ParseLimit {
            what: "depth",
            actual: depth as usize,
            max: max_depth as usize,
        });
    }
    let mut out = String::from("{\n");
    let indent = "  ".repeat((depth + 1) as usize);
    let close_indent = "  ".repeat(depth as usize);
    let mut keys: Vec<&String> = data.keys().collect();
    keys.sort_unstable();
    for key in keys {
        let value = data
            .get(key)
            .ok_or_else(|| SaveError::Parse(format!("missing value for key '{}'", key)))?;
        let key_str = if is_lua_identifier(key) {
            key.clone()
        } else {
            format!("[\"{}\"]", escape_lua_str(key))
        };
        out.push_str(&format!(
            "{}{} = {},\n",
            indent,
            key_str,
            serialize_value_with_limit(value, depth + 1, max_depth)?
        ));
    }
    out.push_str(&format!("{}}}", close_indent));
    Ok(out)
}

/// Serialize a single `SaveValue` to its Lua literal representation; delegates tables to `serialize_table`.
pub fn serialize_value(value: &SaveValue, depth: u32) -> Result<String, String> {
    serialize_value_with_limit(value, depth, SaveParseLimits::default().max_depth as u32)
        .map_err(|error| error.to_string())
}

fn serialize_value_with_limit(
    value: &SaveValue,
    depth: u32,
    max_depth: u32,
) -> Result<String, SaveError> {
    match value {
        SaveValue::Nil => Ok("nil".to_string()),
        SaveValue::Bool(b) => Ok(b.to_string()),
        SaveValue::Number(n) => {
            if !n.is_finite() {
                return Err(SaveError::NonFiniteNumber {
                    context: "save serialization",
                });
            }
            Ok(format!("{}", n))
        }
        SaveValue::Str(s) => Ok(format!("\"{}\"", escape_lua_str(s))),
        SaveValue::Table(t) => serialize_table_with_limit(t, depth, max_depth),
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

struct SaveLuaConversionState {
    visited_tables: HashSet<*const std::ffi::c_void>,
    total_nodes: usize,
}

/// Conversion from Lua values into the serializable `SaveValue` tree.
impl SaveValue {
    /// Convert a `LuaValue` into `SaveValue`; return `LuaError` for unsupported types, cycles, non-finite numbers, or limit failures.
    pub fn from_lua(value: &LuaValue) -> LuaResult<Self> {
        Self::from_lua_with_limits(value, &SaveLuaLimits::default())
    }

    /// Convert a `LuaValue` into `SaveValue` with explicit Lua conversion limits.
    pub fn from_lua_with_limits(value: &LuaValue, limits: &SaveLuaLimits) -> LuaResult<Self> {
        let mut state = SaveLuaConversionState {
            visited_tables: HashSet::new(),
            total_nodes: 0,
        };
        from_lua_inner(value, limits, &mut state, 0)
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

/// Compress `plain` with LZ4 and Base64-encode it; return a versioned header plus encoded payload.
pub fn compress_save_content(plain: &str) -> Result<String, String> {
    compress_save_content_with_limits(plain, &SaveCompressionLimits::default())
        .map_err(|error| error.to_string())
}

/// Compress `plain` with explicit compression limits.
pub fn compress_save_content_with_limits(
    plain: &str,
    limits: &SaveCompressionLimits,
) -> Result<String, SaveError> {
    let plain_len = plain.len();
    enforce_compression_limit(
        "decompressed bytes",
        plain_len,
        limits.max_decompressed_bytes,
    )?;
    let compressed =
        compress(plain.as_bytes(), CompressFormat::Lz4, 1).map_err(SaveError::Compression)?;
    enforce_compression_limit(
        "compressed bytes",
        compressed.len(),
        limits.max_compressed_bytes,
    )?;
    let encoded = BASE64.encode(&compressed);
    enforce_compression_limit("base64 bytes", encoded.len(), limits.max_base64_bytes)?;
    let checksum = hash(HashAlgorithm::Sha256, plain.as_bytes());
    let header = format!(
        "{}compressed={} size={} sha256={}{}",
        COMPRESSED_HEADER_PREFIX,
        COMPRESSED_ALGORITHM,
        plain_len,
        checksum,
        COMPRESSED_HEADER_SUFFIX
    );
    let out = format!("{}\nreturn \"{}\"\n", header, encoded);
    enforce_compression_limit("raw bytes", out.len(), limits.max_raw_bytes)?;
    Ok(out)
}

/// Decompress a save payload; return `raw` unchanged if it is not compressed.
pub fn decompress_save_content(raw: &str) -> Result<String, String> {
    decompress_save_content_with_limits(raw, &SaveCompressionLimits::default())
        .map_err(|error| error.to_string())
}

/// Decompress a save payload with explicit compression limits.
pub fn decompress_save_content_with_limits(
    raw: &str,
    limits: &SaveCompressionLimits,
) -> Result<String, SaveError> {
    enforce_compression_limit("raw bytes", raw.len(), limits.max_raw_bytes)?;

    let compressed_header = if raw.starts_with(COMPRESSED_HEADER_PREFIX) {
        Some(parse_compressed_header(raw)?)
    } else if raw.starts_with(LEGACY_COMPRESSED_MARKER) {
        None
    } else {
        return Ok(raw.to_string());
    };

    let encoded = extract_encoded_payload(raw)?;
    enforce_compression_limit("base64 bytes", encoded.len(), limits.max_base64_bytes)?;

    let compressed = BASE64
        .decode(encoded)
        .map_err(|error| SaveError::Compression(format!("base64 decode: {}", error)))?;
    enforce_compression_limit(
        "compressed bytes",
        compressed.len(),
        limits.max_compressed_bytes,
    )?;

    let declared_size = compressed_header
        .as_ref()
        .map(|header| header.size)
        .unwrap_or_else(|| read_lz4_prepended_size(&compressed).unwrap_or(0));
    enforce_compression_limit(
        "decompressed bytes",
        declared_size,
        limits.max_decompressed_bytes,
    )?;

    let bytes = decompress(&compressed, CompressFormat::Lz4).map_err(SaveError::Compression)?;
    enforce_compression_limit(
        "decompressed bytes",
        bytes.len(),
        limits.max_decompressed_bytes,
    )?;

    let text = String::from_utf8(bytes)
        .map_err(|error| SaveError::Compression(format!("utf8: {}", error)))?;
    if let Some(header) = compressed_header {
        if header.size != text.len() {
            return Err(SaveError::Integrity(format!(
                "compressed header size mismatch: expected {} bytes, got {}",
                header.size,
                text.len()
            )));
        }
        let actual = hash(HashAlgorithm::Sha256, text.as_bytes());
        if actual != header.sha256 {
            return Err(SaveError::Integrity(
                "compressed payload checksum mismatch".to_string(),
            ));
        }
    }
    Ok(text)
}

/// Parse a serialized `return { ... }` save payload back into a root table.
pub fn parse_save_table(content: &str) -> Result<HashMap<String, SaveValue>, String> {
    parse_save_table_with_limits(content, &SaveParseLimits::default())
        .map_err(|error| error.to_string())
}

/// Parse a serialized save payload with explicit parse limits.
pub fn parse_save_table_with_limits(
    content: &str,
    limits: &SaveParseLimits,
) -> Result<HashMap<String, SaveValue>, SaveError> {
    let validated = parse_save_string_with_limits(content, limits)?;
    let mut parser = SaveParser::new(&validated, limits);
    match parser.parse_root()? {
        SaveValue::Table(table) => Ok(table),
        _ => Err(SaveError::Parse("save root must be a table".to_string())),
    }
}

fn parse_save_string_with_limits(
    content: &str,
    limits: &SaveParseLimits,
) -> Result<String, SaveError> {
    let bytes = content.len();
    if content.trim().is_empty() {
        return Err(SaveError::Parse("save file is empty".to_string()));
    }
    if bytes > limits.max_input_bytes {
        return Err(SaveError::ParseLimit {
            what: "input bytes",
            actual: bytes,
            max: limits.max_input_bytes,
        });
    }
    Ok(content.to_string())
}

/// Minimal parser for the constrained Lua table literal format emitted by `serialize_table`.
struct SaveParser<'a> {
    input: &'a str,
    offset: usize,
    limits: &'a SaveParseLimits,
    total_entries: usize,
}

impl<'a> SaveParser<'a> {
    fn new(input: &'a str, limits: &'a SaveParseLimits) -> Self {
        Self {
            input,
            offset: 0,
            limits,
            total_entries: 0,
        }
    }

    fn parse_root(&mut self) -> Result<SaveValue, SaveError> {
        self.skip_whitespace();
        self.expect_keyword("return")?;
        self.skip_whitespace();
        let value = self.parse_value(0)?;
        self.skip_whitespace();
        if self.peek_char().is_some() {
            return Err(SaveError::Parse(
                "unexpected trailing content after save root".to_string(),
            ));
        }
        Ok(value)
    }

    fn parse_value(&mut self, depth: usize) -> Result<SaveValue, SaveError> {
        self.skip_whitespace();
        match self.peek_char() {
            Some('{') => self.parse_table(depth + 1).map(SaveValue::Table),
            Some('"') => self
                .parse_string(self.limits.max_string_chars, "string chars")
                .map(SaveValue::Str),
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
            Some(other) => Err(SaveError::Parse(format!(
                "unexpected save token '{}'",
                other
            ))),
            None => Err(SaveError::Parse(
                "unexpected end of save content".to_string(),
            )),
        }
    }

    fn parse_table(&mut self, depth: usize) -> Result<HashMap<String, SaveValue>, SaveError> {
        if depth > self.limits.max_depth {
            return Err(SaveError::ParseLimit {
                what: "depth",
                actual: depth,
                max: self.limits.max_depth,
            });
        }
        self.expect_char('{')?;
        self.skip_whitespace();
        let mut table = HashMap::new();
        while !matches!(self.peek_char(), Some('}')) {
            let key = self.parse_key()?;
            self.skip_whitespace();
            self.expect_char('=')?;
            let value = self.parse_value(depth)?;
            self.total_entries += 1;
            if self.total_entries > self.limits.max_entries {
                return Err(SaveError::ParseLimit {
                    what: "entries",
                    actual: self.total_entries,
                    max: self.limits.max_entries,
                });
            }
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

    fn parse_key(&mut self) -> Result<String, SaveError> {
        self.skip_whitespace();
        if matches!(self.peek_char(), Some('[')) {
            self.expect_char('[')?;
            let key = self.parse_string(self.limits.max_key_chars, "key chars")?;
            self.expect_char(']')?;
            return Ok(key);
        }
        self.parse_identifier()
    }

    fn parse_identifier(&mut self) -> Result<String, SaveError> {
        let mut identifier = String::new();
        let Some(first) = self.peek_char() else {
            return Err(SaveError::Parse(
                "unexpected end of save content while reading key".to_string(),
            ));
        };
        if !(first.is_ascii_alphabetic() || first == '_') {
            return Err(SaveError::Parse(format!(
                "invalid save key start '{}'",
                first
            )));
        }
        identifier.push(self.next_char().unwrap_or(first));
        while let Some(ch) = self.peek_char() {
            if ch.is_ascii_alphanumeric() || ch == '_' {
                identifier.push(self.next_char().unwrap_or(ch));
            } else {
                break;
            }
        }
        let length = identifier.chars().count();
        if length > self.limits.max_key_chars {
            return Err(SaveError::ParseLimit {
                what: "key chars",
                actual: length,
                max: self.limits.max_key_chars,
            });
        }
        Ok(identifier)
    }

    fn parse_string(
        &mut self,
        max_chars: usize,
        limit_name: &'static str,
    ) -> Result<String, SaveError> {
        self.expect_char('"')?;
        let mut out = String::new();
        let mut chars = 0usize;
        loop {
            let Some(ch) = self.next_char() else {
                return Err(SaveError::Parse(
                    "unterminated save string literal".to_string(),
                ));
            };
            match ch {
                '"' => return Ok(out),
                '\\' => {
                    let escaped = self.next_char().ok_or_else(|| {
                        SaveError::Parse("unterminated save string escape".to_string())
                    })?;
                    match escaped {
                        '\\' => out.push('\\'),
                        '"' => out.push('"'),
                        'n' => out.push('\n'),
                        'r' => out.push('\r'),
                        '0' => out.push('\0'),
                        other => out.push(other),
                    }
                    chars += 1;
                }
                other => {
                    out.push(other);
                    chars += 1;
                }
            }
            if chars > max_chars {
                return Err(SaveError::ParseLimit {
                    what: limit_name,
                    actual: chars,
                    max: max_chars,
                });
            }
        }
    }

    fn parse_number(&mut self) -> Result<f64, SaveError> {
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
        if raw.len() > self.limits.max_number_chars {
            return Err(SaveError::ParseLimit {
                what: "number chars",
                actual: raw.len(),
                max: self.limits.max_number_chars,
            });
        }
        let parsed = raw.parse::<f64>().map_err(|error| {
            SaveError::Parse(format!("invalid save number '{}': {}", raw, error))
        })?;
        if !parsed.is_finite() {
            return Err(SaveError::NonFiniteNumber {
                context: "parsed save payload",
            });
        }
        Ok(parsed)
    }

    fn consume_digits(&mut self) {
        while matches!(self.peek_char(), Some('0'..='9')) {
            self.next_char();
        }
    }

    fn expect_keyword(&mut self, keyword: &str) -> Result<(), SaveError> {
        if !self.remaining().starts_with(keyword) {
            return Err(SaveError::Parse(format!(
                "expected '{}' in save payload",
                keyword
            )));
        }
        self.offset += keyword.len();
        Ok(())
    }

    fn expect_char(&mut self, expected: char) -> Result<(), SaveError> {
        match self.next_char() {
            Some(actual) if actual == expected => Ok(()),
            Some(actual) => Err(SaveError::Parse(format!(
                "expected '{}' but found '{}'",
                expected, actual
            ))),
            None => Err(SaveError::Parse(format!(
                "expected '{}' but reached end of save content",
                expected
            ))),
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

fn from_lua_inner(
    value: &LuaValue,
    limits: &SaveLuaLimits,
    state: &mut SaveLuaConversionState,
    depth: usize,
) -> LuaResult<SaveValue> {
    if depth > limits.max_depth {
        return Err(SaveError::LuaLimit {
            what: "depth",
            actual: depth,
            max: limits.max_depth,
        }
        .into());
    }
    state.total_nodes += 1;
    if state.total_nodes > limits.max_total_nodes {
        return Err(SaveError::LuaLimit {
            what: "total nodes",
            actual: state.total_nodes,
            max: limits.max_total_nodes,
        }
        .into());
    }

    match value {
        LuaValue::Nil => Ok(SaveValue::Nil),
        LuaValue::Boolean(b) => Ok(SaveValue::Bool(*b)),
        LuaValue::Integer(i) => Ok(SaveValue::Number(*i as f64)),
        LuaValue::Number(n) => {
            if !n.is_finite() {
                return Err(SaveError::NonFiniteNumber {
                    context: "Lua save collection",
                }
                .into());
            }
            Ok(SaveValue::Number(*n))
        }
        LuaValue::String(s) => {
            let text = s.to_str()?.to_string();
            let length = text.chars().count();
            if length > limits.max_string_chars {
                return Err(SaveError::LuaLimit {
                    what: "string chars",
                    actual: length,
                    max: limits.max_string_chars,
                }
                .into());
            }
            Ok(SaveValue::Str(text))
        }
        LuaValue::Table(t) => {
            let table_ptr = t.to_pointer();
            if !state.visited_tables.insert(table_ptr) {
                return Err(SaveError::CyclicLuaTable.into());
            }

            let result = (|| {
                let mut map = HashMap::new();
                let mut entries = 0usize;
                for pair in t.clone().pairs::<LuaValue, LuaValue>() {
                    let (key, value) = pair?;
                    entries += 1;
                    if entries > limits.max_table_entries {
                        return Err(SaveError::LuaLimit {
                            what: "table entries",
                            actual: entries,
                            max: limits.max_table_entries,
                        }
                        .into());
                    }
                    let key_text = save_key_from_lua(&key, limits)?;
                    map.insert(key_text, from_lua_inner(&value, limits, state, depth + 1)?);
                }
                Ok(SaveValue::Table(map))
            })();

            state.visited_tables.remove(&table_ptr);
            result
        }
        other => Err(LuaError::RuntimeError(format!(
            "cannot serialize value of type {}",
            other.type_name()
        ))),
    }
}

fn save_key_from_lua(key: &LuaValue, limits: &SaveLuaLimits) -> LuaResult<String> {
    let key_text = match key {
        LuaValue::String(s) => s.to_str()?.to_string(),
        LuaValue::Integer(i) => i.to_string(),
        LuaValue::Number(n) => {
            if !n.is_finite() {
                return Err(SaveError::NonFiniteNumber {
                    context: "Lua save key",
                }
                .into());
            }
            n.to_string()
        }
        other => {
            return Err(LuaError::RuntimeError(format!(
                "cannot serialize table key of type {}",
                other.type_name()
            )))
        }
    };
    let length = key_text.chars().count();
    if length > limits.max_key_chars {
        return Err(SaveError::LuaLimit {
            what: "key chars",
            actual: length,
            max: limits.max_key_chars,
        }
        .into());
    }
    Ok(key_text)
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

fn validate_slot_name_with_limits(slot: &str, limits: &SaveLimits) -> Result<(), SaveError> {
    if slot.is_empty() {
        return Err(SaveError::InvalidSlotName {
            slot: slot.to_string(),
            reason: "slot cannot be empty".to_string(),
        });
    }
    let length = slot.chars().count();
    if length > limits.slot_name_max_chars {
        return Err(SaveError::InvalidSlotName {
            slot: slot.to_string(),
            reason: format!("slot exceeds {} characters", limits.slot_name_max_chars),
        });
    }
    if !slot
        .chars()
        .all(|ch| ch.is_ascii_alphanumeric() || ch == '_' || ch == '-')
    {
        return Err(SaveError::InvalidSlotName {
            slot: slot.to_string(),
            reason: "slot may contain only ASCII letters, digits, '_' and '-'".to_string(),
        });
    }
    Ok(())
}

fn enforce_compression_limit(
    what: &'static str,
    actual: usize,
    max: usize,
) -> Result<(), SaveError> {
    if actual > max {
        return Err(SaveError::CompressionLimit { what, actual, max });
    }
    Ok(())
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct CompressedHeader {
    size: usize,
    sha256: String,
}

fn parse_compressed_header(raw: &str) -> Result<CompressedHeader, SaveError> {
    let line = raw.lines().next().unwrap_or_default().trim();
    if !line.starts_with(COMPRESSED_HEADER_PREFIX) || !line.ends_with(COMPRESSED_HEADER_SUFFIX) {
        return Err(SaveError::Parse(
            "invalid compressed save header".to_string(),
        ));
    }
    let inner = &line[COMPRESSED_HEADER_PREFIX.len()..line.len() - COMPRESSED_HEADER_SUFFIX.len()];
    let mut algorithm = None;
    let mut size = None;
    let mut sha256 = None;
    for token in inner.split_whitespace() {
        let Some((key, value)) = token.split_once('=') else {
            return Err(SaveError::Parse(format!(
                "invalid compressed header token '{}'",
                token
            )));
        };
        match key {
            "compressed" => algorithm = Some(value.to_string()),
            "size" => {
                size = Some(value.parse::<usize>().map_err(|error| {
                    SaveError::Parse(format!(
                        "invalid compressed header size '{}': {}",
                        value, error
                    ))
                })?)
            }
            "sha256" => sha256 = Some(value.to_string()),
            _ => {}
        }
    }
    if algorithm.as_deref() != Some(COMPRESSED_ALGORITHM) {
        return Err(SaveError::Compression(format!(
            "unsupported save compression algorithm '{}'",
            algorithm.unwrap_or_default()
        )));
    }
    let Some(size) = size else {
        return Err(SaveError::Parse(
            "compressed header missing size".to_string(),
        ));
    };
    let Some(sha256) = sha256 else {
        return Err(SaveError::Parse(
            "compressed header missing sha256".to_string(),
        ));
    };
    if sha256.len() != 64 || !sha256.chars().all(|ch| ch.is_ascii_hexdigit()) {
        return Err(SaveError::Parse(
            "compressed header sha256 must be 64 hex characters".to_string(),
        ));
    }
    Ok(CompressedHeader { size, sha256 })
}

fn extract_encoded_payload(raw: &str) -> Result<&str, SaveError> {
    raw.lines()
        .nth(1)
        .and_then(|line| line.strip_prefix("return \""))
        .and_then(|encoded| encoded.strip_suffix('"'))
        .ok_or_else(|| SaveError::Parse("compressed save missing encoded payload".to_string()))
}

fn read_lz4_prepended_size(data: &[u8]) -> Result<usize, SaveError> {
    if data.len() < 4 {
        return Err(SaveError::Compression(
            "compressed save is shorter than the LZ4 size prefix".to_string(),
        ));
    }
    Ok(u32::from_le_bytes([data[0], data[1], data[2], data[3]]) as usize)
}
