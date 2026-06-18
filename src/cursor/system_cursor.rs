//! `src/cursor/system_cursor.rs` owns the engine-facing enum of native system cursor shapes and string conversions.
//! It defines `SystemCursor`, keeping parseable cursor names and canonical string identifiers under one small owner.
//! Config and script name parsing plus stable string export both live here, separate from runtime cursor policy.
//! Read this file when supported native cursor variants or string-mapping behavior need to change.

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
