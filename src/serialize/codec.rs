//! This file provides the format-agnostic front door for serialization work across text and binary payloads. `serialize/codec` delivers the codec implementation for the serialize subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! It decides which codec to use, how to route decoding and encoding, and when content can be recognized automatically. The file owns or coordinates data contracts including `SerialFormat`, `DecodeOptions`, `EncodeOptions`, `EncodedValue`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Text and binary paths are separated here so callers can use one interface without collapsing all format quirks into one parser.
//! The file is therefore the dispatcher that turns unknown serialized input into a chosen translation path. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

use super::{
    from_csv, from_ini, from_json, from_toml, from_xml, to_csv, to_json, to_toml, CsvOptions,
};
use super::{from_msgpack, to_msgpack, SerialValue};

/// Supported serialization formats.
///
/// # Variants
/// - `Json`: JSON text documents.
/// - `Toml`: TOML configuration documents.
/// - `Csv`: Delimited tabular text.
/// - `MsgPack`: Binary MessagePack payloads.
/// - `Xml`: XML text documents.
/// - `Ini`: INI-style key/value configuration text.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
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
}

/// Options controlling text decoding behavior.
///
/// # Fields
/// - `csv`: CSV-specific parsing options used when decoding delimited text.
#[derive(Debug, Clone, Copy, Default)]
pub struct DecodeOptions {
    /// CSV-specific parsing options.
    pub csv: CsvOptions,
}

/// Options controlling encoding behavior.
///
/// # Fields
/// - `json_pretty`: Whether JSON output should be pretty-printed.
/// - `csv`: CSV-specific encoding options.
#[derive(Debug, Clone, Copy, Default)]
pub struct EncodeOptions {
    /// When true, JSON output is pretty-printed.
    pub json_pretty: bool,
    /// CSV-specific encoding options.
    pub csv: CsvOptions,
}

/// Result of encoding a value into text or binary output.
///
/// # Variants
/// - `Text`: UTF-8 textual payload.
/// - `Binary`: Raw byte payload such as MessagePack.
pub enum EncodedValue {
    /// UTF-8 encoded text output.
    Text(String),
    /// Raw binary output (e.g. MsgPack).
    Binary(Vec<u8>),
}

/// Detect the serialization format of a text string by content inspection.
pub fn detect_format(input: &str) -> Option<SerialFormat> {
    let s = input.trim_start();
    if s.is_empty() {
        return None;
    }
    if (s.starts_with('{') || s.starts_with('[')) && from_json(input).is_ok() {
        return Some(SerialFormat::Json);
    }
    if s.starts_with('<') && from_xml(input).is_ok() {
        return Some(SerialFormat::Xml);
    }
    if (s.starts_with('[') || s.contains('=')) && from_toml(input).is_ok() {
        return Some(SerialFormat::Toml);
    }
    let looks_like_csv =
        s.contains('\n') && (s.contains(',') || s.contains(';') || s.contains('\t'));
    if looks_like_csv && from_csv(input, CsvOptions::default()).is_ok() {
        return Some(SerialFormat::Csv);
    }
    if s.contains('=') && from_ini(input).is_ok() {
        return Some(SerialFormat::Ini);
    }
    None
}

/// Decode a text string into a `SerialValue`, optionally specifying the format.
pub fn decode_text(
    input: &str,
    format: Option<SerialFormat>,
    opts: DecodeOptions,
) -> Result<SerialValue, String> {
    let detected = format.or_else(|| detect_format(input)).ok_or_else(|| {
        "decode_text: could not detect format (expected json/toml/csv/xml/ini)".to_string()
    })?;
    match detected {
        SerialFormat::Json => from_json(input),
        SerialFormat::Toml => from_toml(input),
        SerialFormat::Csv => from_csv(input, opts.csv),
        SerialFormat::Xml => from_xml(input),
        SerialFormat::Ini => from_ini(input),
        SerialFormat::MsgPack => {
            Err("decode_text: msgpack is binary; use decode_bytes for msgpack".to_string())
        }
    }
}

/// Decode a binary byte slice into a `SerialValue` using the given format.
pub fn decode_bytes(input: &[u8], format: SerialFormat) -> Result<SerialValue, String> {
    match format {
        SerialFormat::MsgPack => from_msgpack(input),
        _ => Err(format!(
            "decode_bytes: format '{}' expects UTF-8 text input",
            format.as_str()
        )),
    }
}

/// Encode a `SerialValue` into the specified format.
pub fn encode(
    value: &SerialValue,
    format: SerialFormat,
    opts: EncodeOptions,
) -> Result<EncodedValue, String> {
    match format {
        SerialFormat::Json => Ok(EncodedValue::Text(to_json(value, opts.json_pretty)?)),
        SerialFormat::Toml => Ok(EncodedValue::Text(to_toml(value)?)),
        SerialFormat::Csv => Ok(EncodedValue::Text(to_csv(value, opts.csv)?)),
        SerialFormat::MsgPack => Ok(EncodedValue::Binary(to_msgpack(value)?)),
        SerialFormat::Xml => Err("encode: xml encoding is not supported".to_string()),
        SerialFormat::Ini => Err("encode: ini encoding is not supported".to_string()),
    }
}
