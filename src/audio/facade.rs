//! This file owns the playback-device facade that lists outputs and validates active-device selection requests.
//! It currently exposes a simple default-device surface rather than a full backend-specific device enumeration layer.
//! Open this file when output-device semantics change; routing, decode, and mixer playback live in sibling modules.

/// Return the list of available audio output device names; currently always `["Default"]`.
pub fn get_playback_devices() -> Vec<String> {
    vec!["Default".to_string()]
}
/// Return the name of the currently active audio output device; currently always `"Default"`.
pub fn get_playback_device() -> String {
    "Default".to_string()
}
/// Activate the named audio output device; error if `name` is not in `get_playback_devices()`.
pub fn set_playback_device(name: &str) -> Result<(), crate::runtime::error::EngineError> {
    if get_playback_devices().iter().any(|d| d == name) {
        Ok(())
    } else {
        Err(crate::runtime::error::EngineError::AudioError(format!(
            "Unknown audio device: {}",
            name
        )))
    }
}
