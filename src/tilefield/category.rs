//! This file owns category behavior inside the tilefield subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate category state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for category work.

/// Broad semantic kind for a tilefield category.
///
/// # Variants
///
/// The variants select the built-in consumer semantics; `Custom` is reserved for game-defined data.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum TileCategoryKind {
    /// Movement and pathfinding costs or blockers.
    Movement,
    /// Awareness, sight, sound, line-of-fire, or other perception masks.
    Awareness,
    /// Tile light propagation blockers, costs, and transmission filters.
    Light,
    /// Top or directional sun-light attenuation.
    Sun,
    /// Game-defined category with no built-in consumer.
    Custom,
}

impl TileCategoryKind {
    /// Parse a public Lua category kind string.
    pub fn parse(value: &str) -> Result<Self, String> {
        match value {
            "movement" | "move" => Ok(Self::Movement),
            "awareness" | "vision" | "sight" | "sound" | "action" => Ok(Self::Awareness),
            "light" => Ok(Self::Light),
            "sun" => Ok(Self::Sun),
            "custom" => Ok(Self::Custom),
            other => Err(format!(
                "invalid tilefield category kind '{other}' (expected movement, awareness, light, sun, or custom)"
            )),
        }
    }

    /// Return the canonical Lua category kind name.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Movement => "movement",
            Self::Awareness => "awareness",
            Self::Light => "light",
            Self::Sun => "sun",
            Self::Custom => "custom",
        }
    }
}

/// User-defined category record stored by a tilefield.
///
/// # Fields
///
/// `name` identifies the category, `kind` selects its semantic family, and `active` controls default participation.
#[derive(Debug, Clone, PartialEq)]
pub struct TileCategory {
    /// Stable category name chosen by Lua.
    pub name: String,
    /// Semantic kind used by consumers to pick defaults and validation.
    pub kind: TileCategoryKind,
    /// Whether aggregate consumers should include this category by default.
    pub active: bool,
}

impl TileCategory {
    /// Create a validated category record.
    pub fn new(name: String, kind: TileCategoryKind, active: bool) -> Result<Self, String> {
        let name = name.trim();
        if name.is_empty() {
            return Err("tilefield category name must not be empty".to_string());
        }
        Ok(Self {
            name: name.to_string(),
            kind,
            active,
        })
    }
}
