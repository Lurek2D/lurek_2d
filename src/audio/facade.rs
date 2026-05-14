//! Audio device enumeration and selection facade for the Lua API surface.
//!
//! - Returns available output device names and the active device name
//! - Accepts device selection requests and validates them against the available list
//! - Currently stubs device enumeration; all paths return the system default device

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
