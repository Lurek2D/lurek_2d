//! This file owns the format-agnostic serialization front door for text and binary payloads across supported formats.
//! It defines `SerialFormat`, encode or decode options, and the `EncodedValue` result used by top-level callers.
//! Format detection inspects text content, while explicit routing sends MessagePack through byte decoding only.
//! Encode and decode helpers centralize dispatch so callers do not need per-format branching spread across modules.
//! Open this file when top-level serialization routing changes; concrete format implementations live in siblings.

use super::csv::{from_csv_with_options, to_csv_with_options, CsvOptions};
use super::lua_table::validate_serial_value;
use super::msgpack::decode_with_limits as decode_msgpack_with_limits;
use super::schema::{apply_defaults_with_report, validation_errors};
use super::{from_ini, from_json, from_toml, from_xml, to_json, to_msgpack, to_toml, SerialValue};
use thiserror::Error;

/// Supported serialization formats.
///
/// # Variants
/// - `Json`: JSON text documents.
/// - `Toml`: TOML configuration documents.
/// - `Csv`: Delimited tabular text.
/// - `MsgPack`: Binary MessagePack payloads.
/// - `Xml`: XML text documents.
/// - `Ini`: INI-style key/value configuration text.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum SerialFormat {
    /// JSON format.
    Json,
    /// TOML format.
    Toml,
    /// CSV (comma-separated values) format.
    Csv,
    /// MessagePack binary format.
    MsgPack,
    /// XML format.
    Xml,
    /// INI/CFG key-value format.
    Ini,
}

/// Methods for parsing and converting `SerialFormat`.
impl SerialFormat {
    /// Parse a format name string into a `SerialFormat` variant.
    pub fn parse(s: &str) -> Option<Self> {
        match s.trim().to_ascii_lowercase().as_str() {
            "json" => Some(Self::Json),
            "toml" => Some(Self::Toml),
            "csv" => Some(Self::Csv),
            "msgpack" | "messagepack" | "mpk" => Some(Self::MsgPack),
            "xml" => Some(Self::Xml),
            "ini" => Some(Self::Ini),
            _ => None,
        }
    }

    /// Return every supported format.
    pub fn all() -> [Self; 6] {
        [
            Self::Json,
            Self::Toml,
            Self::Csv,
            Self::MsgPack,
            Self::Xml,
            Self::Ini,
        ]
    }

    /// Detect format from a file path extension.
    pub fn from_extension(path: &str) -> Option<Self> {
        let path_lower = path.to_ascii_lowercase();
        let ext = if let Some(dot_idx) = path_lower.rfind('.') {
            &path_lower[dot_idx + 1..]
        } else {
            return None;
        };
        match ext {
            "json" => Some(Self::Json),
            "toml" => Some(Self::Toml),
            "csv" => Some(Self::Csv),
            "msgpack" | "mpk" => Some(Self::MsgPack),
            "xml" => Some(Self::Xml),
            "ini" | "cfg" => Some(Self::Ini),
            _ => None,
        }
    }

    /// Return the canonical string name for this format.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Json => "json",
            Self::Toml => "toml",
            Self::Csv => "csv",
            Self::MsgPack => "msgpack",
            Self::Xml => "xml",
            Self::Ini => "ini",
        }
    }

    /// Whether this format supports encoding from `SerialValue`.
    pub fn can_encode(self) -> bool {
        matches!(
            self,
            SerialFormat::Json | SerialFormat::Toml | SerialFormat::Csv | SerialFormat::MsgPack
        )
    }

    /// Whether this format supports UTF-8 text decoding.
    pub fn can_decode_text(self) -> bool {
        !matches!(self, SerialFormat::MsgPack)
    }

    /// Whether this format supports binary decoding.
    pub fn can_decode_bytes(self) -> bool {
        matches!(self, SerialFormat::MsgPack)
    }
}

/// Shared limit categories enforced by serialization helpers.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SerializeLimitKind {
    /// Recursive depth across nested values.
    Depth,
    /// Total visited nodes.
    Nodes,
    /// UTF-8 string character length.
    StringChars,
    /// Table or map entry count.
    TableEntries,
    /// Sequence item count.
    SequenceLength,
    /// Raw input byte length.
    InputBytes,
    /// Autodetection parser attempts.
    DetectAttempts,
    /// CSV row count.
    CsvRows,
    /// CSV column count.
    CsvColumns,
    /// CSV field character length.
    CsvFieldChars,
}

impl SerializeLimitKind {
    /// Human-readable label used in error messages.
    pub fn label(self) -> &'static str {
        match self {
            Self::Depth => "depth",
            Self::Nodes => "node",
            Self::StringChars => "string character",
            Self::TableEntries => "table entry",
            Self::SequenceLength => "sequence length",
            Self::InputBytes => "input byte",
            Self::DetectAttempts => "format detect attempt",
            Self::CsvRows => "CSV row",
            Self::CsvColumns => "CSV column",
            Self::CsvFieldChars => "CSV field character",
        }
    }
}

/// Structured errors returned by hardened serialization entry points.
#[derive(Debug, Clone, PartialEq, Eq, Error)]
pub enum SerializeError {
    /// A configured traversal or payload limit was exceeded.
    #[error("{context}: {kind:?} limit exceeded (actual {actual}, max {max})")]
    LimitExceeded {
        /// Operation or path where the limit fired.
        context: String,
        /// Limit category.
        kind: SerializeLimitKind,
        /// Actual observed value.
        actual: usize,
        /// Configured maximum.
        max: usize,
    },
    /// Lua table recursion encountered the same table twice.
    #[error("{context}: cyclic Lua table detected")]
    CyclicLuaTable {
        /// Path to the offending table.
        context: String,
    },
    /// A float was NaN or +/-Inf where serialization requires finite numbers.
    #[error("{context}: non-finite numbers are not supported")]
    NonFiniteNumber {
        /// Operation or path where the number was found.
        context: String,
    },
    /// Lua supplied a value kind that the serial tree cannot represent.
    #[error("{context}: unsupported Lua value type '{type_name}'")]
    UnsupportedLuaType {
        /// Operation or path where the value appeared.
        context: String,
        /// mlua value kind label.
        type_name: &'static str,
    },
    /// The requested format is not allowed by the active options.
    #[error("{context}: format '{format}' is not allowed")]
    FormatNotAllowed {
        /// Operation that rejected the format.
        context: String,
        /// Rejected format name.
        format: String,
    },
    /// The requested format cannot do the requested operation.
    #[error("{context}: format '{format}' does not support {capability}")]
    UnsupportedFormat {
        /// Operation that rejected the format.
        context: String,
        /// Format name.
        format: String,
        /// Unsupported capability label.
        capability: &'static str,
    },
    /// Autodetection did not resolve any permitted format.
    #[error("{context}: could not detect format")]
    FormatDetectionFailed {
        /// Detection context.
        context: String,
    },
    /// Schema validation failed after decode.
    #[error("{summary}")]
    SchemaValidation {
        /// Joined summary message for string-based callers.
        summary: String,
        /// Individual validation errors.
        errors: Vec<String>,
    },
    /// CSV strict mode found inconsistent column counts.
    #[error("{context}: CSV column count {actual} does not match expected {expected}")]
    CsvColumnMismatch {
        /// Row context.
        context: String,
        /// Expected column count.
        expected: usize,
        /// Actual column count.
        actual: usize,
    },
    /// CSV encoding encountered a nested value without explicit JSON-in-cell mode.
    #[error("{context}: nested CSV cell values require complex_cells='json'")]
    CsvComplexCell {
        /// Cell context.
        context: String,
    },
    /// Generic parser or codec failure with preserved context.
    #[error("{context}: {message}")]
    Codec {
        /// Operation or path.
        context: String,
        /// Underlying parser message.
        message: String,
    },
}

impl SerializeError {
    /// Build a generic codec error with a contextual operation label.
    pub fn codec(context: impl Into<String>, message: impl Into<String>) -> Self {
        Self::Codec {
            context: context.into(),
            message: message.into(),
        }
    }

    /// Build a standard limit error.
    pub fn limit(
        context: impl Into<String>,
        kind: SerializeLimitKind,
        actual: usize,
        max: usize,
    ) -> Self {
        Self::LimitExceeded {
            context: context.into(),
            kind,
            actual,
            max,
        }
    }
}

/// Shared traversal and payload limits for serialize workflows.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SerializeLimits {
    /// Maximum recursive nesting depth.
    pub max_depth: usize,
    /// Maximum total visited nodes.
    pub max_nodes: usize,
    /// Maximum UTF-8 character length for one string.
    pub max_string_chars: usize,
    /// Maximum entries inside one map-style table.
    pub max_table_entries: usize,
    /// Maximum entries inside one sequence-style table.
    pub max_sequence_len: usize,
    /// Maximum raw input size in bytes for one payload.
    pub max_input_bytes: usize,
    /// Maximum parser attempts during format autodetection.
    pub max_detect_attempts: usize,
}

impl Default for SerializeLimits {
    fn default() -> Self {
        Self {
            max_depth: 64,
            max_nodes: 100_000,
            max_string_chars: 1_000_000,
            max_table_entries: 100_000,
            max_sequence_len: 100_000,
            max_input_bytes: 4 * 1024 * 1024,
            max_detect_attempts: 5,
        }
    }
}

/// Decode metadata describing how a payload was interpreted.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct DecodeReport {
    /// Input size seen by the front door.
    pub input_bytes: usize,
    /// Final resolved format, if any.
    pub resolved_format: Option<SerialFormat>,
    /// Formats that were explicitly attempted during autodetection or dispatch.
    pub attempted_formats: Vec<SerialFormat>,
    /// Field paths that received schema defaults.
    pub defaults_applied: Vec<String>,
    /// Collected schema validation errors.
    pub validation_errors: Vec<String>,
}

/// Decoded value plus the report describing how it was produced.
#[derive(Debug, Clone, PartialEq)]
pub struct DecodedValue {
    /// Normalized serial tree.
    pub value: SerialValue,
    /// Decode report.
    pub report: DecodeReport,
}

/// Options controlling text decoding behavior.
#[derive(Debug, Clone)]
pub struct DecodeOptions {
    /// CSV-specific parsing options used when decoding delimited text.
    pub csv: CsvOptions,
    /// Global limit policy.
    pub limits: SerializeLimits,
    /// Explicit allow-list for formats this call may use.
    pub allowed_formats: Vec<SerialFormat>,
}

impl Default for DecodeOptions {
    fn default() -> Self {
        Self {
            csv: CsvOptions::default(),
            limits: SerializeLimits::default(),
            allowed_formats: SerialFormat::all().to_vec(),
        }
    }
}

/// Options controlling encoding behavior.
#[derive(Debug, Clone, Default)]
pub struct EncodeOptions {
    /// When true, JSON output is pretty-printed.
    pub json_pretty: bool,
    /// CSV-specific encoding options.
    pub csv: CsvOptions,
    /// Global limit policy used before encoding.
    pub limits: SerializeLimits,
}

/// Result of encoding a value into text or binary output.
pub enum EncodedValue {
    /// UTF-8 encoded text output.
    Text(String),
    /// Raw binary output (e.g. MsgPack).
    Binary(Vec<u8>),
}

fn ensure_input_limit(
    input_len: usize,
    limits: &SerializeLimits,
    context: &str,
) -> Result<(), SerializeError> {
    if input_len > limits.max_input_bytes {
        return Err(SerializeError::limit(
            context,
            SerializeLimitKind::InputBytes,
            input_len,
            limits.max_input_bytes,
        ));
    }
    Ok(())
}

fn ensure_format_allowed(
    format: SerialFormat,
    allowed_formats: &[SerialFormat],
    context: &str,
) -> Result<(), SerializeError> {
    if allowed_formats.contains(&format) {
        return Ok(());
    }
    Err(SerializeError::FormatNotAllowed {
        context: context.to_string(),
        format: format.as_str().to_string(),
    })
}

fn detection_order() -> [SerialFormat; 5] {
    [
        SerialFormat::Json,
        SerialFormat::Xml,
        SerialFormat::Toml,
        SerialFormat::Csv,
        SerialFormat::Ini,
    ]
}

fn matches_detected_format(format: SerialFormat, input: &str, csv_options: CsvOptions) -> bool {
    let trimmed = input.trim_start();
    match format {
        SerialFormat::Json => {
            (trimmed.starts_with('{') || trimmed.starts_with('[')) && from_json(input).is_ok()
        }
        SerialFormat::Xml => trimmed.starts_with('<') && from_xml(input).is_ok(),
        SerialFormat::Toml => {
            (trimmed.starts_with('[') || trimmed.contains('=')) && from_toml(input).is_ok()
        }
        SerialFormat::Csv => {
            let looks_like_csv = trimmed.contains('\n')
                && (trimmed.contains(',') || trimmed.contains(';') || trimmed.contains('\t'));
            looks_like_csv && from_csv_with_options(input, csv_options).is_ok()
        }
        SerialFormat::Ini => trimmed.contains('=') && from_ini(input).is_ok(),
        SerialFormat::MsgPack => false,
    }
}

/// Detect the serialization format of a text string by content inspection.
pub fn detect_format(input: &str) -> Option<SerialFormat> {
    detect_format_detailed(input, &DecodeOptions::default())
        .ok()
        .and_then(|report| report.resolved_format)
}

/// Detect the serialization format and preserve parser-attempt metadata.
pub fn detect_format_detailed(
    input: &str,
    opts: &DecodeOptions,
) -> Result<DecodeReport, SerializeError> {
    ensure_input_limit(input.len(), &opts.limits, "detect_format")?;

    let trimmed = input.trim_start();
    let mut report = DecodeReport {
        input_bytes: input.len(),
        ..DecodeReport::default()
    };
    if trimmed.is_empty() {
        return Ok(report);
    }

    for format in detection_order() {
        if !format.can_decode_text() || !opts.allowed_formats.contains(&format) {
            continue;
        }
        if report.attempted_formats.len() >= opts.limits.max_detect_attempts {
            return Err(SerializeError::limit(
                "detect_format",
                SerializeLimitKind::DetectAttempts,
                report.attempted_formats.len() + 1,
                opts.limits.max_detect_attempts,
            ));
        }
        report.attempted_formats.push(format);
        if matches_detected_format(format, input, opts.csv) {
            report.resolved_format = Some(format);
            return Ok(report);
        }
    }

    Ok(report)
}

/// Decode a text string into a `SerialValue`, optionally specifying the format.
pub fn decode_text(
    input: &str,
    format: Option<SerialFormat>,
    opts: DecodeOptions,
) -> Result<SerialValue, SerializeError> {
    Ok(decode_text_detailed(input, format, opts)?.value)
}

/// Decode a text string and preserve format-detection metadata.
pub fn decode_text_detailed(
    input: &str,
    format: Option<SerialFormat>,
    opts: DecodeOptions,
) -> Result<DecodedValue, SerializeError> {
    ensure_input_limit(input.len(), &opts.limits, "decode_text")?;

    let mut report = if let Some(explicit_format) = format {
        ensure_format_allowed(explicit_format, &opts.allowed_formats, "decode_text")?;
        if !explicit_format.can_decode_text() {
            return Err(SerializeError::UnsupportedFormat {
                context: "decode_text".to_string(),
                format: explicit_format.as_str().to_string(),
                capability: "text decoding",
            });
        }
        DecodeReport {
            input_bytes: input.len(),
            resolved_format: Some(explicit_format),
            attempted_formats: vec![explicit_format],
            defaults_applied: Vec::new(),
            validation_errors: Vec::new(),
        }
    } else {
        let detected = detect_format_detailed(input, &opts)?;
        if detected.resolved_format.is_none() {
            return Err(SerializeError::FormatDetectionFailed {
                context: "decode_text".to_string(),
            });
        }
        detected
    };

    let resolved = report
        .resolved_format
        .ok_or_else(|| SerializeError::FormatDetectionFailed {
            context: "decode_text".to_string(),
        })?;
    let value = match resolved {
        SerialFormat::Json => {
            from_json(input).map_err(|msg| SerializeError::codec("decode_text", msg))?
        }
        SerialFormat::Toml => {
            from_toml(input).map_err(|msg| SerializeError::codec("decode_text", msg))?
        }
        SerialFormat::Csv => from_csv_with_options(input, opts.csv)
            .map_err(|err| SerializeError::codec("decode_text", err.to_string()))?,
        SerialFormat::Xml => {
            from_xml(input).map_err(|msg| SerializeError::codec("decode_text", msg))?
        }
        SerialFormat::Ini => {
            from_ini(input).map_err(|msg| SerializeError::codec("decode_text", msg))?
        }
        SerialFormat::MsgPack => {
            return Err(SerializeError::UnsupportedFormat {
                context: "decode_text".to_string(),
                format: resolved.as_str().to_string(),
                capability: "text decoding",
            })
        }
    };
    validate_serial_value(&value, &opts.limits, "decode_text")?;
    report.resolved_format = Some(resolved);
    Ok(DecodedValue { value, report })
}

/// Decode a binary byte slice into a `SerialValue` using the given format and default limits.
pub fn decode_bytes(input: &[u8], format: SerialFormat) -> Result<SerialValue, SerializeError> {
    Ok(decode_bytes_with_options(input, format, DecodeOptions::default())?.value)
}

/// Decode binary input while preserving format metadata.
pub fn decode_bytes_with_options(
    input: &[u8],
    format: SerialFormat,
    opts: DecodeOptions,
) -> Result<DecodedValue, SerializeError> {
    ensure_input_limit(input.len(), &opts.limits, "decode_bytes")?;
    ensure_format_allowed(format, &opts.allowed_formats, "decode_bytes")?;
    if !format.can_decode_bytes() {
        return Err(SerializeError::UnsupportedFormat {
            context: "decode_bytes".to_string(),
            format: format.as_str().to_string(),
            capability: "binary decoding",
        });
    }

    let value = match format {
        SerialFormat::MsgPack => decode_msgpack_with_limits(input, &opts.limits)?,
        _ => unreachable!("binary decode was gated by can_decode_bytes"),
    };
    validate_serial_value(&value, &opts.limits, "decode_bytes")?;
    Ok(DecodedValue {
        value,
        report: DecodeReport {
            input_bytes: input.len(),
            resolved_format: Some(format),
            attempted_formats: vec![format],
            defaults_applied: Vec::new(),
            validation_errors: Vec::new(),
        },
    })
}

/// Decode text and validate plus patch the result with a schema before returning it.
pub fn decode_text_with_schema(
    input: &str,
    format: Option<SerialFormat>,
    schema: &SerialValue,
    opts: DecodeOptions,
) -> Result<DecodedValue, SerializeError> {
    let mut decoded = decode_text_detailed(input, format, opts)?;
    let errors = validation_errors(&decoded.value, schema);
    decoded.report.validation_errors = errors.clone();
    if !errors.is_empty() {
        return Err(SerializeError::SchemaValidation {
            summary: format!("decode_text_with_schema: {}", errors.join("; ")),
            errors,
        });
    }
    let defaults = apply_defaults_with_report(&decoded.value, schema)
        .map_err(|msg| SerializeError::codec("decode_text_with_schema", msg))?;
    decoded.report.defaults_applied = defaults.applied_paths.clone();
    decoded.value = defaults.value;
    Ok(decoded)
}

/// Decode binary input and validate plus patch the result with a schema before returning it.
pub fn decode_bytes_with_schema(
    input: &[u8],
    format: SerialFormat,
    schema: &SerialValue,
    opts: DecodeOptions,
) -> Result<DecodedValue, SerializeError> {
    let mut decoded = decode_bytes_with_options(input, format, opts)?;
    let errors = validation_errors(&decoded.value, schema);
    decoded.report.validation_errors = errors.clone();
    if !errors.is_empty() {
        return Err(SerializeError::SchemaValidation {
            summary: format!("decode_bytes_with_schema: {}", errors.join("; ")),
            errors,
        });
    }
    let defaults = apply_defaults_with_report(&decoded.value, schema)
        .map_err(|msg| SerializeError::codec("decode_bytes_with_schema", msg))?;
    decoded.report.defaults_applied = defaults.applied_paths.clone();
    decoded.value = defaults.value;
    Ok(decoded)
}

/// Encode a `SerialValue` into the specified format.
pub fn encode(
    value: &SerialValue,
    format: SerialFormat,
    opts: EncodeOptions,
) -> Result<EncodedValue, SerializeError> {
    validate_serial_value(value, &opts.limits, "encode")?;
    if !format.can_encode() {
        return Err(SerializeError::UnsupportedFormat {
            context: "encode".to_string(),
            format: format.as_str().to_string(),
            capability: "encoding",
        });
    }
    match format {
        SerialFormat::Json => Ok(EncodedValue::Text(
            to_json(value, opts.json_pretty).map_err(|msg| SerializeError::codec("encode", msg))?,
        )),
        SerialFormat::Toml => Ok(EncodedValue::Text(
            to_toml(value).map_err(|msg| SerializeError::codec("encode", msg))?,
        )),
        SerialFormat::Csv => Ok(EncodedValue::Text(
            to_csv_with_options(value, opts.csv)
                .map_err(|err| SerializeError::codec("encode", err.to_string()))?,
        )),
        SerialFormat::MsgPack => Ok(EncodedValue::Binary(
            to_msgpack(value).map_err(|msg| SerializeError::codec("encode", msg))?,
        )),
        SerialFormat::Xml | SerialFormat::Ini => Err(SerializeError::UnsupportedFormat {
            context: "encode".to_string(),
            format: format.as_str().to_string(),
            capability: "encoding",
        }),
    }
}
