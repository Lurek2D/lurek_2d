//! Operating system detection utilities for platform-specific code paths.
//!
//! - Enum: `PowerState`.
//! - Functions: `get_os_name`, `get_processor_count`, `get_memory_size`, `open_url`, and 2 more.

use crate::log_msg;
use crate::runtime::log_messages::{LA03_OPEN_URL_REJECTED};

/// Returns the current operating system name.
pub fn get_os_name() -> &'static str {
    if cfg!(target_os = "windows") {
        "Windows"
    } else if cfg!(target_os = "linux") {
        "Linux"
    } else if cfg!(target_os = "macos") {
        "macOS"
    } else if cfg!(target_os = "android") {
        "Android"
    } else if cfg!(target_os = "ios") {
        "iOS"
    } else {
        "Unknown"
    }
}

/// Returns the number of logical processors available on the host system.
pub fn get_processor_count() -> usize {
    std::thread::available_parallelism()
        .map(|n| n.get())
        .unwrap_or(1)
}

/// Returns total physical memory in megabytes reported by the operating system.
pub fn get_memory_size() -> u64 {
    use sysinfo::System;
    let sys = System::new_with_specifics(
        sysinfo::RefreshKind::new().with_memory(sysinfo::MemoryRefreshKind::everything()),
    );
    sys.total_memory() / (1024 * 1024)
}

/// Opens a URL in the default system browser. Only `http://`, `https://`, and `mailto:` schemes are allowed.
pub fn open_url(url: &str) -> bool {
    let url_lower = url.to_lowercase();
    if !url_lower.starts_with("http://")
        && !url_lower.starts_with("https://")
        && !url_lower.starts_with("mailto:")
    {
        log_msg!(warn, LA03_OPEN_URL_REJECTED);
        return false;
    }
    #[cfg(target_os = "windows")]
    {
        std::process::Command::new("cmd")
            .args(["/C", "start", "", url])
            .spawn()
            .is_ok()
    }
    #[cfg(target_os = "macos")]
    {
        std::process::Command::new("open").arg(url).spawn().is_ok()
    }
    #[cfg(target_os = "linux")]
    {
        std::process::Command::new("xdg-open")
            .arg(url)
            .spawn()
            .is_ok()
    }
    #[cfg(not(any(target_os = "windows", target_os = "macos", target_os = "linux")))]
    {
        let _ = url;
        false
    }
}

/// Returns the user's preferred locale list from the operating system, falling back to `"en_US"` if unavailable.
pub fn get_preferred_locales() -> Vec<String> {
    let locales: Vec<String> = sys_locale::get_locales().map(|l| l.to_string()).collect();
    if locales.is_empty() {
        if let Ok(lang) = std::env::var("LANG") {
            vec![lang.split('.').next().unwrap_or("en_US").to_string()]
        } else {
            vec!["en_US".to_string()]
        }
    } else {
        locales
    }
}

/// Describes the current power supply state of the host device.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum PowerState {
    Unknown,
    Battery,
    NoBattery,
    Charging,
    Charged,
}

impl PowerState {
    /// Returns the Lua-visible power state string.
    pub fn as_str(&self) -> &'static str {
        match self {
            PowerState::Unknown => "unknown",
            PowerState::Battery => "battery",
            PowerState::NoBattery => "nobattery",
            PowerState::Charging => "charging",
            PowerState::Charged => "charged",
        }
    }
}

/// Returns the current power state, battery percentage (0-100), and estimated seconds remaining.
pub fn get_power_info() -> (PowerState, Option<u32>, Option<u32>) {
    (PowerState::Unknown, None, None)
}
