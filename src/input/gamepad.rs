//! This file owns `GamepadState`, `GamepadVibrationRequest`, and `GamepadMappings`, the runtime gamepad model.
//! It stores connection flags, per-button hold and transition sets, axis values, GUIDs, names, and rumble capability.
//! Frame helpers clear transient deltas, while update methods record button and axis changes from backend polling.
//! Virtual D-pad conversion also lives here so input-facing helpers stay near the gamepad state model.
//! The mappings store parses SDL2-style controller database lines, keeps them by GUID, and can read or write files.
//! The file is the owner for device state and mapping schema, while app-side polling and rumble dispatch live higher.
//! Open it when gamepad semantics change; combo logic, recording, and window-event orchestration live in siblings.

use crate::filesystem::GameFS;
use crate::log_msg;
use crate::runtime::log_messages::{GD01, GD02, GD03};
use crate::runtime::EngineError;
use std::collections::{HashMap, HashSet};
use std::io::{BufRead, Write};
use std::path::Path;

/// Returns the XInput-compatible button code for a standard button name.
pub fn standard_button_code(name: &str) -> Option<u32> {
    match name.trim().to_ascii_lowercase().as_str() {
        "a" => Some(0),
        "b" => Some(1),
        "x" => Some(2),
        "y" => Some(3),
        "leftshoulder" | "left_shoulder" => Some(4),
        "rightshoulder" | "right_shoulder" => Some(5),
        "back" | "select" => Some(6),
        "start" => Some(7),
        "leftstick" | "left_stick" => Some(8),
        "rightstick" | "right_stick" => Some(9),
        "dpad_up" | "dpup" => Some(10),
        "dpad_down" | "dpdown" => Some(11),
        "dpad_left" | "dpleft" => Some(12),
        "dpad_right" | "dpright" => Some(13),
        _ => None,
    }
}

/// Returns the XInput-compatible axis code for a standard axis name.
pub fn standard_axis_code(name: &str) -> Option<u32> {
    match name.trim().to_ascii_lowercase().as_str() {
        "leftx" | "left_x" => Some(0),
        "lefty" | "left_y" => Some(1),
        "rightx" | "right_x" => Some(2),
        "righty" | "right_y" => Some(3),
        "lefttrigger" | "left_trigger" => Some(4),
        "righttrigger" | "right_trigger" => Some(5),
        _ => None,
    }
}

/// Pending vibration command for one gamepad, queued for delivery to the OS driver.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct GamepadVibrationRequest {
    /// Gamepad slot index, matches `GamepadState::id`.
    pub id: usize,
    /// Low-frequency (rumble) motor intensity in [0.0, 1.0].
    pub low_freq: f32,
    /// High-frequency (buzzer) motor intensity in [0.0, 1.0].
    pub high_freq: f32,
    /// Vibration duration in milliseconds.
    pub duration_ms: u32,
}

/// Per-frame state for one physical gamepad slot, including buttons, axes, and connection flags.
pub struct GamepadState {
    /// Slot index assigned by the gamepad backend.
    pub id: u32,
    /// Human-readable controller name from the OS.
    pub name: String,
    /// True when the physical device is connected.
    pub connected: bool,
    /// True when the OS driver reports force-feedback capability.
    pub vibration_supported: bool,
    /// SDL2-style GUID string used to look up custom mappings.
    guid: String,
    /// Current held state for each button code.
    buttons: HashMap<u32, bool>,
    /// Button codes that transitioned to pressed this frame.
    buttons_pressed: HashSet<u32>,
    /// Button codes that transitioned to released this frame.
    buttons_released: HashSet<u32>,
    /// Current axis values keyed by axis code.
    axes: HashMap<u32, f32>,
    /// True only during the frame when the device first connected.
    connected_this_frame: bool,
    /// True only during the frame when the device disconnected.
    disconnected_this_frame: bool,
}

impl GamepadState {
    /// Create a disconnected slot for `id`; all buttons/axes start at default.
    pub fn new(id: u32) -> Self {
        log_msg!(debug, GD01, "id={}", id);
        GamepadState {
            id,
            name: String::from("Unknown Controller"),
            connected: false,
            vibration_supported: false,
            guid: String::new(),
            buttons: HashMap::new(),
            buttons_pressed: HashSet::new(),
            buttons_released: HashSet::new(),
            axes: HashMap::new(),
            connected_this_frame: false,
            disconnected_this_frame: false,
        }
    }

    /// Clear per-frame delta sets; call once at the start of each game frame.
    pub fn begin_frame(&mut self) {
        self.buttons_pressed.clear();
        self.buttons_released.clear();
        self.connected_this_frame = false;
        self.disconnected_this_frame = false;
    }

    /// Record a button state change and update pressed/released delta sets.
    pub fn update_button(&mut self, button: u32, pressed: bool) {
        log_msg!(trace, GD02, "button={} pressed={}", button, pressed);
        let was_pressed = self.is_button_pressed(button);
        if !was_pressed && pressed {
            self.buttons_pressed.insert(button);
        }
        if was_pressed && !pressed {
            self.buttons_released.insert(button);
        }
        self.buttons.insert(button, pressed);
    }

    /// Return true when `button` transitioned to pressed this frame.
    pub fn was_button_pressed(&self, button: u32) -> bool {
        self.buttons_pressed.contains(&button)
    }

    /// Return true when `button` transitioned to released this frame.
    pub fn was_button_released(&self, button: u32) -> bool {
        self.buttons_released.contains(&button)
    }

    /// Record a new axis value; replaces the previous value for `axis`.
    pub fn update_axis(&mut self, axis: u32, value: f32) {
        log_msg!(trace, GD03, "axis={} value={:.3}", axis, value);
        self.axes.insert(axis, value);
    }

    /// Return true when `button` is currently held down.
    pub fn is_button_pressed(&self, button: u32) -> bool {
        *self.buttons.get(&button).unwrap_or(&false)
    }

    /// Return the current value for `axis`, or 0.0 when the axis has never been seen.
    pub fn get_axis_value(&self, axis: u32) -> f32 {
        *self.axes.get(&axis).unwrap_or(&0.0)
    }

    /// Returns whether a standard named button is currently held.
    pub fn is_standard_button_pressed(&self, name: &str) -> bool {
        standard_button_code(name).is_some_and(|button| self.is_button_pressed(button))
    }

    /// Returns the value of a standard named axis, or zero for an unknown name.
    pub fn get_standard_axis_value(&self, name: &str) -> f32 {
        standard_axis_code(name).map_or(0.0, |axis| self.get_axis_value(axis))
    }

    /// Return the OS-reported controller name.
    pub fn get_name(&self) -> &str {
        &self.name
    }

    /// Return true when the device is currently connected.
    pub fn is_connected(&self) -> bool {
        self.connected
    }

    /// Update connection state and set the per-frame connection-change flags.
    pub fn set_connected(&mut self, connected: bool) {
        if connected && !self.connected {
            self.connected_this_frame = true;
        }
        if !connected && self.connected {
            self.disconnected_this_frame = true;
        }
        self.connected = connected;
    }

    /// Return true only during the frame the device first connected.
    pub fn was_connected_this_frame(&self) -> bool {
        self.connected_this_frame
    }

    /// Return true only during the frame the device disconnected.
    pub fn was_disconnected_this_frame(&self) -> bool {
        self.disconnected_this_frame
    }

    /// Set whether the OS driver supports force feedback for this device.
    pub fn set_vibration_supported(&mut self, supported: bool) {
        self.vibration_supported = supported;
    }

    /// Return true when force feedback is supported.
    pub fn is_vibration_supported(&self) -> bool {
        self.vibration_supported
    }

    /// Return the number of distinct button codes seen on this device.
    pub fn get_button_count(&self) -> usize {
        self.buttons.len()
    }

    /// Return the number of distinct axis codes seen on this device.
    pub fn get_axis_count(&self) -> usize {
        self.axes.len()
    }

    /// Set the SDL2-style GUID string; crate-internal, called from the runtime event loop.
    #[allow(dead_code)]
    pub(crate) fn set_guid(&mut self, guid: impl Into<String>) {
        self.guid = guid.into();
    }

    /// Return the SDL2-style GUID string for mapping lookup.
    pub fn get_guid(&self) -> &str {
        &self.guid
    }

    /// Return a D-pad direction string for `hat`; reads buttons 10–13 for hat 0.
    pub fn get_hat(&self, hat: u32) -> &'static str {
        if hat != 0 {
            return "c";
        }
        let up = self.is_button_pressed(10);
        let down = self.is_button_pressed(11);
        let left = self.is_button_pressed(12);
        let right = self.is_button_pressed(13);
        match (up, down, left, right) {
            (true, false, false, false) => "u",
            (true, false, false, true) => "ru",
            (false, false, false, true) => "r",
            (false, true, false, true) => "rd",
            (false, true, false, false) => "d",
            (false, true, true, false) => "ld",
            (false, false, true, false) => "l",
            (true, false, true, false) => "lu",
            _ => "c",
        }
    }
}

/// Convert a 2D stick position to four directional booleans and an 8-way direction string.
///
/// Returns `(up, down, left, right, direction)` where `direction` is one of
/// `"u"`, `"d"`, `"l"`, `"r"`, `"lu"`, `"ru"`, `"ld"`, `"rd"`, or `"c"` (centered).
pub fn virtual_dpad(x: f32, y: f32, deadzone: f32) -> (bool, bool, bool, bool, &'static str) {
    let dz = deadzone.clamp(0.0, 1.0);
    let left = x <= -dz;
    let right = x >= dz;
    let up = y <= -dz;
    let down = y >= dz;
    let direction = match (up, down, left, right) {
        (true, false, false, false) => "u",
        (true, false, true, false) => "lu",
        (true, false, false, true) => "ru",
        (false, true, false, false) => "d",
        (false, true, true, false) => "ld",
        (false, true, false, true) => "rd",
        (false, false, true, false) => "l",
        (false, false, false, true) => "r",
        _ => "c",
    };
    (up, down, left, right, direction)
}

/// In-memory store of SDL2-style gamepad mappings keyed by device GUID.
pub struct GamepadMappings {
    /// GUID → raw SDL2 mapping string.
    map: HashMap<String, String>,
}

/// Provide a default empty mapping table.
impl Default for GamepadMappings {
    fn default() -> Self {
        Self::new()
    }
}

impl GamepadMappings {
    /// Create an empty mapping store.
    pub fn new() -> Self {
        Self {
            map: HashMap::new(),
        }
    }

    /// Insert or overwrite the mapping string for `guid`.
    pub fn set_mapping(&mut self, guid: &str, mapping: &str) -> Result<(), String> {
        let guid = canonicalize_guid(guid)?;
        let parsed = parse_mapping_line(mapping)?;
        if parsed.guid != guid {
            return Err(format!(
                "mapping guid '{}' does not match expected guid '{}'",
                parsed.guid, guid
            ));
        }
        self.map.insert(guid, parsed.raw_line);
        Ok(())
    }

    /// Parse SDL2 gamecontrollerdb lines from `source`; return the number of entries loaded.
    pub fn load_from_string(&mut self, source: &str) -> usize {
        let mut count = 0usize;
        for raw_line in source.lines() {
            let trimmed = raw_line.trim();
            if trimmed.is_empty() || trimmed.starts_with('#') {
                continue;
            }
            if let Ok(parsed) = parse_mapping_line(trimmed) {
                self.map.insert(parsed.guid, parsed.raw_line);
                count += 1;
            }
        }
        count
    }

    /// Return the raw mapping string for `guid`, or `None` when not present.
    pub fn get_mapping_string(&self, guid: &str) -> Option<&str> {
        let guid = canonicalize_guid(guid).ok()?;
        self.map.get(&guid).map(|s| s.as_str())
    }

    /// Resolve a standard button name to the physical `bN` index declared by an SDL mapping.
    /// Returns `None` when no mapping (or no compatible button token) exists, allowing the
    /// backend's native Xbox layout to remain the fallback.
    pub fn standard_button_index(&self, guid: &str, standard_name: &str) -> Option<u32> {
        self.standard_control_index(guid, standard_name, 'b')
    }

    /// Resolve a standard axis name to the physical `aN` index declared by an SDL mapping.
    pub fn standard_axis_index(&self, guid: &str, standard_name: &str) -> Option<u32> {
        self.standard_control_index(guid, standard_name, 'a')
    }

    fn standard_control_index(&self, guid: &str, standard_name: &str, prefix: char) -> Option<u32> {
        let mapping = self.get_mapping_string(guid)?;
        let wanted = standard_name.trim().to_ascii_lowercase();
        mapping.split(',').skip(2).find_map(|token| {
            let (name, raw_value) = token.split_once(':')?;
            if name.trim().to_ascii_lowercase() != wanted {
                return None;
            }
            let value = raw_value.trim().trim_start_matches(['+', '-']);
            value
                .strip_prefix(prefix)
                .and_then(|number| number.parse::<u32>().ok())
        })
    }

    /// Load mappings from a file at `path`; return entry count or `EngineError` on I/O failure.
    pub fn load_from_file(&mut self, path: &str) -> Result<usize, EngineError> {
        self.load_from_path(Path::new(path))
    }

    /// Load mappings from a resolved host path; return entry count or `EngineError` on I/O failure.
    pub fn load_from_path(&mut self, path: &Path) -> Result<usize, EngineError> {
        let file = std::fs::File::open(path).map_err(|e| {
            EngineError::FileSystemError(format!("Cannot open {}: {}", path.display(), e))
        })?;
        let reader = std::io::BufReader::new(file);
        let mut content = String::new();
        for line in reader.lines() {
            let line = line.map_err(|e| {
                EngineError::FileSystemError(format!("Read error in {}: {}", path.display(), e))
            })?;
            content.push_str(&line);
            content.push('\n');
        }
        Ok(self.load_from_string(&content))
    }

    /// Write all stored mappings to a file at `path`; return `EngineError` on I/O failure.
    pub fn save_to_file(&self, path: &str) -> Result<(), EngineError> {
        self.save_to_path(Path::new(path))
    }

    /// Write all stored mappings to a resolved host path; return `EngineError` on I/O failure.
    pub fn save_to_path(&self, path: &Path) -> Result<(), EngineError> {
        let mut file = std::fs::File::create(path).map_err(|e| {
            EngineError::FileSystemError(format!("Cannot create {}: {}", path.display(), e))
        })?;
        for mapping in self.map.values() {
            writeln!(file, "{}", mapping)
                .map_err(|e| EngineError::FileSystemError(format!("Write error: {}", e)))?;
        }
        Ok(())
    }

    /// Load mappings from a GameFS path using sandboxed read resolution.
    pub fn load_from_game_fs(&mut self, fs: &GameFS, path: &str) -> Result<usize, EngineError> {
        let resolved = fs.resolve_read_path(path)?;
        self.load_from_path(&resolved)
    }

    /// Save mappings to a GameFS path using sandboxed write resolution.
    pub fn save_to_game_fs(&self, fs: &GameFS, path: &str) -> Result<(), EngineError> {
        let resolved = fs.resolve_save_path(path)?;
        self.save_to_path(&resolved)
    }
}

#[derive(Debug)]
struct ParsedMappingLine {
    guid: String,
    raw_line: String,
}

fn canonicalize_guid(raw: &str) -> Result<String, String> {
    let guid = raw.trim().to_ascii_lowercase();
    if guid.len() != 32 || !guid.bytes().all(|byte| byte.is_ascii_hexdigit()) {
        return Err("guid must be a 32-character hexadecimal string".to_string());
    }
    Ok(guid)
}

fn parse_mapping_line(raw_line: &str) -> Result<ParsedMappingLine, String> {
    let trimmed = raw_line.trim();
    let parts: Vec<&str> = trimmed.split(',').collect();
    if parts.len() < 3 {
        return Err("mapping line must contain guid, name, and at least one token".to_string());
    }
    let guid = canonicalize_guid(parts[0])?;
    let name = parts[1].trim();
    if name.is_empty() {
        return Err("mapping line name must not be empty".to_string());
    }
    for token in parts.iter().skip(2) {
        let token = token.trim();
        if token.is_empty() {
            return Err("mapping line contains an empty token".to_string());
        }
        if !token.contains(':') {
            return Err(format!("mapping token '{}' must contain ':'", token));
        }
        let mut pieces = token.splitn(2, ':');
        let key = pieces.next().unwrap_or_default().trim();
        let value = pieces.next().unwrap_or_default().trim();
        if key.is_empty() || value.is_empty() {
            return Err(format!(
                "mapping token '{}' must contain key:value data",
                token
            ));
        }
    }
    Ok(ParsedMappingLine {
        guid,
        raw_line: trimmed.to_string(),
    })
}
