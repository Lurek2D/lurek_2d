//! Owns the built-in UI icon catalog used by retained widgets, TOML layouts, and Lua helpers.
//! The catalog maps stable semantic names to compact text glyphs so icons work without external assets.
//! Names stay independent from the rendered glyphs, allowing a future SVG or atlas backend to reuse the same API.
//! Widget code stores icon names, while render code resolves them here at paint time.
//! Keep this module focused on catalog lookup and icon placement metadata, not widget state or drawing policy.

/// One built-in UI icon entry.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct UiIcon {
    /// Stable semantic icon name exposed to Lua and TOML.
    pub name: &'static str,
    /// Compact built-in text glyph used by the current renderer backend.
    pub glyph: &'static str,
}

/// Icon placement relative to widget text.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum UiIconPosition {
    /// Draw icon before text on the horizontal axis.
    Left,
    /// Draw icon after text on the horizontal axis.
    Right,
    /// Draw icon above text.
    Top,
    /// Draw icon below text.
    Bottom,
    /// Draw only the icon and suppress widget text rendering.
    Only,
}

impl UiIconPosition {
    /// Parse a lowercase icon-position token.
    pub fn parse_str(value: &str) -> Option<Self> {
        match value {
            "left" => Some(Self::Left),
            "right" => Some(Self::Right),
            "top" => Some(Self::Top),
            "bottom" => Some(Self::Bottom),
            "only" => Some(Self::Only),
            _ => None,
        }
    }

    /// Return the canonical lowercase token for this position.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Left => "left",
            Self::Right => "right",
            Self::Top => "top",
            Self::Bottom => "bottom",
            Self::Only => "only",
        }
    }
}

/// Built-in icon entries grouped around common application and game operations.
pub const BUILTIN_UI_ICONS: &[UiIcon] = &[
    UiIcon {
        name: "new-file",
        glyph: "N",
    },
    UiIcon {
        name: "open",
        glyph: "O",
    },
    UiIcon {
        name: "save",
        glyph: "S",
    },
    UiIcon {
        name: "save-as",
        glyph: "SA",
    },
    UiIcon {
        name: "import",
        glyph: "IN",
    },
    UiIcon {
        name: "export",
        glyph: "EX",
    },
    UiIcon {
        name: "upload",
        glyph: "UP",
    },
    UiIcon {
        name: "download",
        glyph: "DN",
    },
    UiIcon {
        name: "print",
        glyph: "PR",
    },
    UiIcon {
        name: "archive",
        glyph: "AR",
    },
    UiIcon {
        name: "folder",
        glyph: "FD",
    },
    UiIcon {
        name: "file",
        glyph: "FL",
    },
    UiIcon {
        name: "copy",
        glyph: "CP",
    },
    UiIcon {
        name: "cut",
        glyph: "CT",
    },
    UiIcon {
        name: "paste",
        glyph: "PS",
    },
    UiIcon {
        name: "undo",
        glyph: "<-",
    },
    UiIcon {
        name: "redo",
        glyph: "->",
    },
    UiIcon {
        name: "select",
        glyph: "SE",
    },
    UiIcon {
        name: "select-all",
        glyph: "SA",
    },
    UiIcon {
        name: "edit",
        glyph: "ED",
    },
    UiIcon {
        name: "rename",
        glyph: "RN",
    },
    UiIcon {
        name: "delete",
        glyph: "DL",
    },
    UiIcon {
        name: "duplicate",
        glyph: "DU",
    },
    UiIcon {
        name: "move",
        glyph: "MV",
    },
    UiIcon {
        name: "drag",
        glyph: "DR",
    },
    UiIcon {
        name: "crop",
        glyph: "CR",
    },
    UiIcon {
        name: "brush",
        glyph: "BR",
    },
    UiIcon {
        name: "eraser",
        glyph: "ER",
    },
    UiIcon {
        name: "fill",
        glyph: "FI",
    },
    UiIcon {
        name: "color",
        glyph: "CO",
    },
    UiIcon {
        name: "home",
        glyph: "HM",
    },
    UiIcon {
        name: "back",
        glyph: "<",
    },
    UiIcon {
        name: "forward",
        glyph: ">",
    },
    UiIcon {
        name: "up",
        glyph: "^",
    },
    UiIcon {
        name: "down",
        glyph: "v",
    },
    UiIcon {
        name: "left",
        glyph: "<",
    },
    UiIcon {
        name: "right",
        glyph: ">",
    },
    UiIcon {
        name: "menu",
        glyph: "==",
    },
    UiIcon {
        name: "more",
        glyph: "..",
    },
    UiIcon {
        name: "search",
        glyph: "?",
    },
    UiIcon {
        name: "zoom-in",
        glyph: "Z+",
    },
    UiIcon {
        name: "zoom-out",
        glyph: "Z-",
    },
    UiIcon {
        name: "fit",
        glyph: "FT",
    },
    UiIcon {
        name: "fullscreen",
        glyph: "FS",
    },
    UiIcon {
        name: "minimize",
        glyph: "MN",
    },
    UiIcon {
        name: "check",
        glyph: "OK",
    },
    UiIcon {
        name: "close",
        glyph: "X",
    },
    UiIcon {
        name: "cancel",
        glyph: "CA",
    },
    UiIcon {
        name: "add",
        glyph: "+",
    },
    UiIcon {
        name: "remove",
        glyph: "-",
    },
    UiIcon {
        name: "info",
        glyph: "i",
    },
    UiIcon {
        name: "warning",
        glyph: "!",
    },
    UiIcon {
        name: "error",
        glyph: "!!",
    },
    UiIcon {
        name: "help",
        glyph: "?",
    },
    UiIcon {
        name: "lock",
        glyph: "LK",
    },
    UiIcon {
        name: "unlock",
        glyph: "UL",
    },
    UiIcon {
        name: "refresh",
        glyph: "RF",
    },
    UiIcon {
        name: "sync",
        glyph: "SY",
    },
    UiIcon {
        name: "power",
        glyph: "PW",
    },
    UiIcon {
        name: "settings",
        glyph: "ST",
    },
    UiIcon {
        name: "play",
        glyph: ">",
    },
    UiIcon {
        name: "pause",
        glyph: "||",
    },
    UiIcon {
        name: "stop",
        glyph: "[]",
    },
    UiIcon {
        name: "record",
        glyph: "REC",
    },
    UiIcon {
        name: "rewind",
        glyph: "<<",
    },
    UiIcon {
        name: "fast-forward",
        glyph: ">>",
    },
    UiIcon {
        name: "previous",
        glyph: "|<",
    },
    UiIcon {
        name: "next",
        glyph: ">|",
    },
    UiIcon {
        name: "volume",
        glyph: "VO",
    },
    UiIcon {
        name: "mute",
        glyph: "MU",
    },
    UiIcon {
        name: "music",
        glyph: "MS",
    },
    UiIcon {
        name: "mic",
        glyph: "MC",
    },
    UiIcon {
        name: "camera",
        glyph: "CM",
    },
    UiIcon {
        name: "image",
        glyph: "IM",
    },
    UiIcon {
        name: "video",
        glyph: "VI",
    },
    UiIcon {
        name: "table",
        glyph: "TB",
    },
    UiIcon {
        name: "chart",
        glyph: "CH",
    },
    UiIcon {
        name: "database",
        glyph: "DB",
    },
    UiIcon {
        name: "filter",
        glyph: "FT",
    },
    UiIcon {
        name: "sort",
        glyph: "SO",
    },
    UiIcon {
        name: "list",
        glyph: "LS",
    },
    UiIcon {
        name: "grid",
        glyph: "GR",
    },
    UiIcon {
        name: "dashboard",
        glyph: "DS",
    },
    UiIcon {
        name: "calendar",
        glyph: "CL",
    },
    UiIcon {
        name: "clock",
        glyph: "CK",
    },
    UiIcon {
        name: "user",
        glyph: "U",
    },
    UiIcon {
        name: "users",
        glyph: "US",
    },
    UiIcon {
        name: "mail",
        glyph: "ML",
    },
    UiIcon {
        name: "message",
        glyph: "MSG",
    },
    UiIcon {
        name: "notification",
        glyph: "NO",
    },
    UiIcon {
        name: "health",
        glyph: "HP",
    },
    UiIcon {
        name: "armor",
        glyph: "AM",
    },
    UiIcon {
        name: "sword",
        glyph: "SW",
    },
    UiIcon {
        name: "shield",
        glyph: "SH",
    },
    UiIcon {
        name: "bow",
        glyph: "BW",
    },
    UiIcon {
        name: "target",
        glyph: "TG",
    },
    UiIcon {
        name: "crosshair",
        glyph: "CH",
    },
    UiIcon {
        name: "inventory",
        glyph: "IV",
    },
    UiIcon {
        name: "backpack",
        glyph: "BP",
    },
    UiIcon {
        name: "map",
        glyph: "MP",
    },
    UiIcon {
        name: "quest",
        glyph: "Q",
    },
    UiIcon {
        name: "star",
        glyph: "*",
    },
    UiIcon {
        name: "trophy",
        glyph: "TR",
    },
    UiIcon {
        name: "coin",
        glyph: "$",
    },
    UiIcon {
        name: "gem",
        glyph: "GM",
    },
    UiIcon {
        name: "code",
        glyph: "{}",
    },
    UiIcon {
        name: "terminal",
        glyph: ">_",
    },
    UiIcon {
        name: "bug",
        glyph: "BG",
    },
    UiIcon {
        name: "package",
        glyph: "PK",
    },
    UiIcon {
        name: "plugin",
        glyph: "PL",
    },
    UiIcon {
        name: "wrench",
        glyph: "WR",
    },
    UiIcon {
        name: "hammer",
        glyph: "HM",
    },
    UiIcon {
        name: "key",
        glyph: "KY",
    },
    UiIcon {
        name: "link",
        glyph: "LK",
    },
    UiIcon {
        name: "external-link",
        glyph: "EL",
    },
    UiIcon {
        name: "cloud",
        glyph: "CD",
    },
    UiIcon {
        name: "wifi",
        glyph: "WF",
    },
    UiIcon {
        name: "server",
        glyph: "SV",
    },
    UiIcon {
        name: "cpu",
        glyph: "CPU",
    },
    UiIcon {
        name: "memory",
        glyph: "RAM",
    },
];

/// Normalize a user-facing icon token for catalog lookup.
pub fn normalize_icon_name(value: &str) -> String {
    value
        .trim()
        .chars()
        .map(|ch| match ch {
            '_' | ' ' => '-',
            other => other.to_ascii_lowercase(),
        })
        .collect()
}

/// Return the built-in icon with `name`, accepting case-insensitive spaces and underscores.
pub fn lookup_icon(name: &str) -> Option<&'static UiIcon> {
    let normalized = normalize_icon_name(name);
    BUILTIN_UI_ICONS
        .iter()
        .find(|icon| icon.name == normalized.as_str())
}

/// Return whether `name` resolves to a built-in icon.
pub fn has_icon(name: &str) -> bool {
    lookup_icon(name).is_some()
}

/// Return all built-in icon names in stable catalog order.
pub fn icon_names() -> impl Iterator<Item = &'static str> {
    BUILTIN_UI_ICONS.iter().map(|icon| icon.name)
}
