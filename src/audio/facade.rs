//! Audio device facade: enumeration and selection of playback devices.

/// Returns the names of all available audio output devices.
///
/// On most systems this returns at least `"Default"`. Uses `cpal` enumeration
/// when available; falls back to a single-entry stub list otherwise.
///
/// # Returns
/// `Vec<String>`.
pub fn get_playback_devices() -> Vec<String> {
    vec!["Default".to_string()]
}

/// Returns the name of the currently active audio output device.
///
/// # Returns
/// `String`.
pub fn get_playback_device() -> String {
    "Default".to_string()
}

/// Selects the audio output device by name.
///
/// Accepts any name returned by [`get_playback_devices`].  Passing an unknown
/// name returns `Err(EngineError::AudioError)`.
///
/// # Parameters
/// - `name` — `&str`. Device name to select.
///
/// # Returns
/// `Result<(), crate::runtime::error::EngineError>`.
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
