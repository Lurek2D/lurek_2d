//! Owns the tileset archetype implementation for the tileset subsystem and keeps related runtime rules local here.
//! Keeps tileset metadata, archetypes, and render-facing lookup helpers so helpers stay close to invariants this updates.
//! Defines how tileset archetype data is validated, transformed, or stored before neighboring systems consume it.
//! Separates tileset archetype behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where tileset code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing tileset archetype defaults, lifecycle handling, validation, or data ownership rules.

use crate::tilefield::TileChannel;
use crate::tileset::visual::TileVisual;
use std::collections::HashMap;

/// Tile-filling shape authored on a tileset object.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TileObjectShapeKind {
    /// Axis-aligned rectangle using the tile width and height.
    Rect,
    /// Centered square using the shorter tile side.
    Square,
    /// Four-point diamond touching each tile edge.
    Diamond,
    /// Upward triangle filling the tile bounds.
    Triangle,
    /// Six-point hexagon filling the tile bounds.
    Hex,
}

impl TileObjectShapeKind {
    /// Parse a Lua/provider shape name.
    pub fn parse(value: &str) -> Result<Self, String> {
        match value {
            "rect" | "rectangle" => Ok(Self::Rect),
            "square" => Ok(Self::Square),
            "diamond" => Ok(Self::Diamond),
            "triangle" => Ok(Self::Triangle),
            "hex" | "hexagon" => Ok(Self::Hex),
            other => Err(format!(
                "unsupported tile object shape '{other}', expected rect, square, diamond, triangle, or hex"
            )),
        }
    }

    /// Return the Lua/provider shape name.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Rect => "rect",
            Self::Square => "square",
            Self::Diamond => "diamond",
            Self::Triangle => "triangle",
            Self::Hex => "hex",
        }
    }
}

/// Tile-based light source defaults authored on a tileset object archetype.
#[derive(Debug, Clone)]
pub struct TileObjectLight {
    /// Radius in tiles.
    pub radius: f32,
    /// Light intensity multiplier.
    pub intensity: f32,
    /// RGB color in 0..1.
    pub color: [f32; 3],
}

impl Default for TileObjectLight {
    fn default() -> Self {
        Self {
            radius: 1.0,
            intensity: 1.0,
            color: [1.0, 1.0, 1.0],
        }
    }
}

/// Physics body defaults authored on a tileset object archetype.
#[derive(Debug, Clone)]
pub struct TileObjectPhysics {
    /// Tile-filling collision shape.
    pub shape: TileObjectShapeKind,
    /// Body type string consumed by the physics adapter.
    pub body_type: String,
    /// Optional explicit mass. When omitted, dynamic mass can be derived from density and area.
    pub mass: Option<f32>,
    /// Mass per area unit for dynamic body mass derivation.
    pub density: f32,
    /// Surface friction coefficient.
    pub friction: f32,
    /// Bounce coefficient.
    pub restitution: f32,
    /// Whether the collider should behave as an overlap sensor.
    pub sensor: bool,
    /// Collision layer bitmask.
    pub layer: u32,
    /// Collision mask bitmask.
    pub mask: u32,
}

impl Default for TileObjectPhysics {
    fn default() -> Self {
        Self {
            shape: TileObjectShapeKind::Rect,
            body_type: "static".to_string(),
            mass: None,
            density: 1.0,
            friction: 0.5,
            restitution: 0.0,
            sensor: false,
            layer: 1,
            mask: 1,
        }
    }
}

/// Render-light defaults authored on a tileset object archetype.
#[derive(Debug, Clone)]
pub struct TileObjectRenderLight {
    /// Tile-space placement shape; currently used to choose the tile center.
    pub shape: TileObjectShapeKind,
    /// Radius in world units.
    pub radius: f32,
    /// Light intensity multiplier.
    pub intensity: f32,
    /// RGBA color in 0..1.
    pub color: [f32; 4],
    /// Whether the created light starts enabled.
    pub enabled: bool,
    /// Whether the light casts shadows.
    pub shadow_enabled: bool,
    /// Light layer mask.
    pub light_mask: u16,
    /// Shadow layer mask.
    pub shadow_mask: u16,
    /// Optional blend mode name.
    pub blend_mode: Option<String>,
    /// Optional falloff mode name.
    pub falloff: Option<String>,
    /// Optional light type name.
    pub light_type: Option<String>,
}

impl Default for TileObjectRenderLight {
    fn default() -> Self {
        Self {
            shape: TileObjectShapeKind::Rect,
            radius: 64.0,
            intensity: 1.0,
            color: [1.0, 1.0, 1.0, 1.0],
            enabled: true,
            shadow_enabled: true,
            light_mask: 0xFFFF,
            shadow_mask: 0xFFFF,
            blend_mode: None,
            falloff: None,
            light_type: None,
        }
    }
}

/// Render-light occluder defaults authored on a tileset object archetype.
#[derive(Debug, Clone)]
pub struct TileObjectOccluder {
    /// Tile-filling occluder polygon shape.
    pub shape: TileObjectShapeKind,
    /// Shadow opacity in 0..1.
    pub opacity: f32,
    /// Light layer mask this occluder casts shadows for.
    pub light_mask: u16,
    /// Whether the created occluder starts enabled.
    pub enabled: bool,
}

impl Default for TileObjectOccluder {
    fn default() -> Self {
        Self {
            shape: TileObjectShapeKind::Rect,
            opacity: 1.0,
            light_mask: 0xFFFF,
            enabled: true,
        }
    }
}

/// Reusable object archetype that can be referenced by `tilefield` slots.
#[derive(Debug, Clone)]
pub struct TileObjectArchetype {
    /// Stable object name chosen by the game.
    pub name: String,
    /// Optional default tilefield slot for this object type.
    pub slot: Option<String>,
    /// Visual data consumed by tilemap render ordering.
    pub visual: Option<TileVisual>,
    /// Per-channel blocker defaults.
    pub blockers: HashMap<TileChannel, bool>,
    /// Per-channel cost/transmission defaults.
    pub costs: HashMap<TileChannel, f32>,
    /// Per-category blocker defaults.
    pub category_blockers: HashMap<String, bool>,
    /// Per-category cost defaults.
    pub category_costs: HashMap<String, f32>,
    /// Per-category transmission defaults.
    pub category_transmission: HashMap<String, f32>,
    /// Per-category RGB filter defaults.
    pub category_filters: HashMap<String, [f32; 3]>,
    /// Optional footprint width/height in cells.
    pub footprint: Option<(u32, u32)>,
    /// Optional top-sun occlusion default in 0..1.
    pub sun_occlusion: Option<f32>,
    /// Optional tilelight source defaults.
    pub light: Option<TileObjectLight>,
    /// Optional physics body defaults.
    pub physics: Option<TileObjectPhysics>,
    /// Optional render-light source defaults.
    pub render_light: Option<TileObjectRenderLight>,
    /// Optional render-light occluder defaults.
    pub occluder: Option<TileObjectOccluder>,
    /// Custom game-defined properties.
    pub properties: HashMap<String, String>,
}

impl TileObjectArchetype {
    /// Create an empty archetype with a stable name.
    pub fn new(name: String) -> Result<Self, String> {
        let name = name.trim();
        if name.is_empty() {
            return Err("tileset object archetype name must not be empty".to_string());
        }
        Ok(Self {
            name: name.to_string(),
            slot: None,
            visual: None,
            blockers: HashMap::new(),
            costs: HashMap::new(),
            category_blockers: HashMap::new(),
            category_costs: HashMap::new(),
            category_transmission: HashMap::new(),
            category_filters: HashMap::new(),
            footprint: None,
            sun_occlusion: None,
            light: None,
            physics: None,
            render_light: None,
            occluder: None,
            properties: HashMap::new(),
        })
    }
}
