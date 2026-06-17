//! Defines cross-platform system cursor shape variants used by runtime cursor state. `cursor/system_cursor` delivers the system cursor implementation for the cursor subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Maps engine-facing cursor variants to platform-native icon representations. The file owns or coordinates data contracts including `SystemCursor`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Supports case-insensitive string parsing for config and script-driven selection. Public callable behavior is centered on no named public items, while method-level behavior such as `from_name`, `as_str` stays attached to the local data model and invariants.

/// System cursor shapes available on all platforms.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum SystemCursor {
    Arrow,
    IBeam,
    Wait,
    Crosshair,
    WaitArrow,
    SizeNWSE,
    SizeNESW,
    SizeWE,
    SizeNS,
    SizeAll,
    No,
    Hand,
}

impl SystemCursor {
    /// Parse a `SystemCursor` variant from a string name; returns `None` for unknown names.
    pub fn from_name(s: &str) -> Option<Self> {
        match s.to_lowercase().as_str() {
            "arrow" => Some(Self::Arrow),
            "ibeam" | "text" => Some(Self::IBeam),
            "wait" | "busy" => Some(Self::Wait),
            "crosshair" => Some(Self::Crosshair),
            "wait_arrow" => Some(Self::WaitArrow),
            "size_nwse" => Some(Self::SizeNWSE),
            "size_nesw" => Some(Self::SizeNESW),
            "size_we" | "size_horizontal" => Some(Self::SizeWE),
            "size_ns" | "size_vertical" => Some(Self::SizeNS),
            "size_all" | "move" => Some(Self::SizeAll),
            "no" | "forbidden" => Some(Self::No),
            "hand" | "pointer" => Some(Self::Hand),
            _ => None,
        }
    }

    /// Return the canonical OS string identifier for this cursor shape.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Arrow => "arrow",
            Self::IBeam => "ibeam",
            Self::Wait => "wait",
            Self::Crosshair => "crosshair",
            Self::WaitArrow => "wait_arrow",
            Self::SizeNWSE => "size_nwse",
            Self::SizeNESW => "size_nesw",
            Self::SizeWE => "size_we",
            Self::SizeNS => "size_ns",
            Self::SizeAll => "size_all",
            Self::No => "no",
            Self::Hand => "hand",
        }
    }
}
