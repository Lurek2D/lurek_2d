//! Owns save-slot lifecycle policy: slot names, metadata, autosave timing, migrations, backups, and restore flow.
//! Delegates payload encoding to `serialize` and byte compression or checksum helpers to `binary` boundaries.
//! Stores manager configuration such as format, compression, root path, current slot metadata, and migration hooks.
//! Validates slot paths, migration ordering, content limits, compression envelopes, and checksum corruption cases.
//! Exposes crate-local helpers used by Lua bindings without owning Lua table parsing or generic file codecs.
//! Keeps save-game state semantics separate from static mod definitions, assets, and renderer-owned runtime data.
//! Provides deterministic metadata and content conversion so tests can verify save behavior across formats.
//! Handles legacy compressed markers and the current save envelope while keeping payload data opaque to save.
//! Update this file when save lifecycle rules, version handling, compression policy, or slot safety changes.
//! Leave format-specific parsing in serialization modules and keep filesystem-facing policy visible at this owner.

use crate::binary::{
    compress::{compress, decompress, CompressFormat},
    hash, HashAlgorithm,
};
use crate::log_msg;
use crate::runtime::log_messages::{SV01, SV02, SV03, SV04};
use crate::serialize::SerialFormat;
use base64::{engine::general_purpose::STANDARD as BASE64, Engine as _};
use mlua::prelude::LuaError;
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

/// Maximum traversal cost accepted when converting Lua values into serialize-owned save payloads.
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
    /// Serialization format used for save payloads.
    format: SerialFormat,
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
            format: SerialFormat::MsgPack,
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

    /// Return the serialization format used for save payloads.
    pub fn format(&self) -> SerialFormat {
        self.format
    }

    /// Set the serialization format used for save payloads.
    pub fn set_format(&mut self, format: SerialFormat) {
        self.format = format;
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
