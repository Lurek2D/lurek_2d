//! Defines `RuntimeMode` enum with four variants: `gui`, `tui`, `headless`, and `cli`.
//!
//! - Data type: `RuntimeModeParseError`.
//! - Enum: `RuntimeMode`.

use serde::{Deserialize, Serialize};
use std::fmt;
use std::str::FromStr;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
#[serde(rename_all = "lowercase")]
/// Startup mode selected from `conf.toml` or CLI flags.
pub enum RuntimeMode {
    /// Current winit/wgpu desktop runtime.
    #[default]
    Gui,
    /// Future GUI terminal-grid runtime.
    Tui,
    /// No-window Lua runtime for scripts and automation.
    Headless,
    /// Future GUI-rendered interactive Lua REPL runtime.
    Cli,
}

impl RuntimeMode {
    /// Return the lowercase config and CLI token for this mode.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Gui => "gui",
            Self::Tui => "tui",
            Self::Headless => "headless",
            Self::Cli => "cli",
        }
    }
}

impl fmt::Display for RuntimeMode {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str(self.as_str())
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
/// Error returned when a runtime mode token is not one of the supported values.
pub struct RuntimeModeParseError {
    /// Original unrecognised value.
    value: String,
}

impl RuntimeModeParseError {
    /// Return the invalid token supplied by the caller.
    pub fn value(&self) -> &str {
        &self.value
    }
}

/// Formats the error as a human-readable message naming the rejected token.
impl fmt::Display for RuntimeModeParseError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            formatter,
            "invalid runtime mode '{}'; expected gui, tui, headless, or cli",
            self.value
        )
    }
}

/// Marks `RuntimeModeParseError` as a standard library error type.
impl std::error::Error for RuntimeModeParseError {}

/// Parses a lowercase mode token such as `"headless"` into a `RuntimeMode` variant.
impl FromStr for RuntimeMode {
    type Err = RuntimeModeParseError;

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        match value.trim().to_ascii_lowercase().as_str() {
            "gui" => Ok(Self::Gui),
            "tui" => Ok(Self::Tui),
            "headless" => Ok(Self::Headless),
            "cli" => Ok(Self::Cli),
            _ => Err(RuntimeModeParseError {
                value: value.to_string(),
            }),
        }
    }
}
