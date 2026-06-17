//! Implements textual encoding and decoding of opaque bytes via base64 and hexadecimal formats. `binary/encode` delivers the encode implementation for the binary subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Selects algorithms through stable enum variants parsed from user-facing format labels. The file owns or coordinates data contracts including `EncodeFormat`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Returns normalized failures for malformed textual payloads during decode operations. Public callable behavior is centered on `encode`, `decode`, while method-level behavior such as `parse_str` stays attached to the local data model and invariants.

use base64::Engine;
#[derive(Debug, Clone, Copy, PartialEq)]
/// Select textual encoding algorithm.
///
/// # Variants
/// - `Base64`: Standard base64 alphabet.
/// - `Hex`: Lowercase hexadecimal text.
pub enum EncodeFormat {
    /// Encode using standard base64 alphabet.
    Base64,
    /// Encode using lowercase hexadecimal text.
    Hex,
}
impl EncodeFormat {
    /// Parse format label and return encoding variant or error.
    pub fn parse_str(s: &str) -> Result<Self, String> {
        match s.to_lowercase().as_str() {
            "base64" => Ok(EncodeFormat::Base64),
            "hex" => Ok(EncodeFormat::Hex),
            _ => Err(format!(
                "Unknown encoding format: '{}'. Use 'base64' or 'hex'.",
                s
            )),
        }
    }
}
/// Encode bytes with selected format and return text.
pub fn encode(format: EncodeFormat, data: &[u8]) -> String {
    match format {
        EncodeFormat::Base64 => base64::engine::general_purpose::STANDARD.encode(data),
        EncodeFormat::Hex => hex::encode(data),
    }
}
/// Decode text with selected format and return bytes or error.
pub fn decode(format: EncodeFormat, text: &str) -> Result<Vec<u8>, String> {
    match format {
        EncodeFormat::Base64 => base64::engine::general_purpose::STANDARD
            .decode(text)
            .map_err(|e| format!("Base64 decode error: {}", e)),
        EncodeFormat::Hex => hex::decode(text).map_err(|e| format!("Hex decode error: {}", e)),
    }
}
