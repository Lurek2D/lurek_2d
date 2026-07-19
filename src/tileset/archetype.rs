//! Owns reusable object archetypes and their author-default validation.
//!
//! Archetypes describe defaults for neighboring owners to materialize. They do not
//! create physics bodies, lights, blockers, or render resources themselves.

use crate::tilefield::TileChannel;
use crate::tileset::error::TilesetError;
use crate::tileset::limits::TilesetLimits;
use crate::tileset::visual::TileVisual;
use std::collections::HashMap;

/// Tile-filling shape authored on a tileset object.
///
/// # Variants
///
/// The variants are the accepted shape vocabulary passed to physics and render
/// integration owners.
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
///
/// # Fields
///
/// Radius and intensity are finite non-negative defaults and color components are
/// finite values in the unit range.
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
///
/// # Fields
///
/// Body type and material values are validated before the archetype is stored;
/// layer and mask remain opaque bitmasks for the physics owner.
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
///
/// # Fields
///
/// Numeric colors, radius, and intensity are validated here while blend, falloff,
/// and light-type strings use the lighting module vocabulary.
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
///
/// # Fields
///
/// Opacity is a finite unit-range default; masks and enabled state are passed to
/// the light integration owner.
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
///
/// # Fields
///
/// An archetype combines optional visual, semantic, footprint, light, physics,
/// occluder, and custom-property defaults without materializing runtime objects.
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

    /// Validate all nested author defaults before the archetype enters a tileset.
    pub fn validate(&self, limits: &TilesetLimits) -> Result<(), TilesetError> {
        for (resource, count) in [
            ("archetype blockers", self.blockers.len()),
            ("archetype costs", self.costs.len()),
            ("category blockers", self.category_blockers.len()),
            ("category costs", self.category_costs.len()),
            ("category transmission", self.category_transmission.len()),
            ("category filters", self.category_filters.len()),
        ] {
            if count > limits.max_properties_per_owner {
                return Err(TilesetError::LimitExceeded {
                    resource,
                    requested: count as u64,
                    maximum: limits.max_properties_per_owner as u64,
                });
            }
        }
        validate_text(&self.name, "archetype name", limits.max_name_bytes)?;
        if let Some(slot) = &self.slot {
            validate_text(slot, "archetype slot", limits.max_string_bytes)?;
        }
        if let Some(visual) = &self.visual {
            visual.validate(limits)?;
        }
        for (category, value) in &self.category_costs {
            validate_text(category, "category cost name", limits.max_name_bytes)?;
            validate_non_negative(*value, "category cost", limits)?;
        }
        for (category, value) in &self.category_blockers {
            validate_text(category, "category blocker name", limits.max_name_bytes)?;
            let _ = value;
        }
        for (category, value) in &self.category_transmission {
            validate_text(
                category,
                "category transmission name",
                limits.max_name_bytes,
            )?;
            validate_unit(*value, "category transmission", limits)?;
        }
        for (category, values) in &self.category_filters {
            validate_text(category, "category filter name", limits.max_name_bytes)?;
            for value in values {
                validate_unit(*value, "category filter", limits)?;
            }
        }
        for value in self.costs.values() {
            validate_non_negative(*value, "channel cost", limits)?;
        }
        if let Some((width, height)) = self.footprint {
            if width == 0 || height == 0 {
                return Err(TilesetError::invalid(
                    "archetype footprint",
                    "width and height must be greater than zero",
                ));
            }
            if width > limits.max_footprint_dimension || height > limits.max_footprint_dimension {
                return Err(TilesetError::LimitExceeded {
                    resource: "footprint dimension",
                    requested: u64::from(width.max(height)),
                    maximum: u64::from(limits.max_footprint_dimension),
                });
            }
        }
        if let Some(value) = self.sun_occlusion {
            validate_unit(value, "sun_occlusion", limits)?;
        }
        if let Some(light) = &self.light {
            validate_positive(light.radius, "light radius", limits)?;
            validate_non_negative(light.intensity, "light intensity", limits)?;
            validate_color(&light.color, "light color", limits)?;
        }
        if let Some(physics) = &self.physics {
            if !matches!(
                physics.body_type.as_str(),
                "static" | "dynamic" | "kinematic" | "sensor"
            ) {
                return Err(TilesetError::invalid(
                    "physics body_type",
                    "must be static, dynamic, kinematic, or sensor",
                ));
            }
            validate_text(
                &physics.body_type,
                "physics body_type",
                limits.max_string_bytes,
            )?;
            if let Some(mass) = physics.mass {
                validate_positive(mass, "physics mass", limits)?;
            }
            validate_positive(physics.density, "physics density", limits)?;
            validate_unit(physics.friction, "physics friction", limits)?;
            validate_unit(physics.restitution, "physics restitution", limits)?;
        }
        if let Some(light) = &self.render_light {
            validate_positive(light.radius, "render_light radius", limits)?;
            validate_non_negative(light.intensity, "render_light intensity", limits)?;
            validate_color(&light.color, "render_light color", limits)?;
            validate_optional_enum(
                light.blend_mode.as_deref(),
                "render_light blend_mode",
                &["add", "sub", "mix"],
                limits,
            )?;
            validate_optional_enum(
                light.falloff.as_deref(),
                "render_light falloff",
                &["linear", "smooth", "constant"],
                limits,
            )?;
            validate_optional_enum(
                light.light_type.as_deref(),
                "render_light light_type",
                &["point", "directional", "spot"],
                limits,
            )?;
        }
        if let Some(occluder) = &self.occluder {
            validate_unit(occluder.opacity, "occluder opacity", limits)?;
        }
        if self.properties.len() > limits.max_properties_per_owner {
            return Err(TilesetError::LimitExceeded {
                resource: "archetype properties",
                requested: self.properties.len() as u64,
                maximum: limits.max_properties_per_owner as u64,
            });
        }
        for (name, value) in &self.properties {
            validate_text(name, "archetype property name", limits.max_name_bytes)?;
            validate_text(value, "archetype property value", limits.max_string_bytes)?;
        }
        Ok(())
    }
}

fn validate_text(value: &str, field: &str, max_bytes: usize) -> Result<(), TilesetError> {
    if value.trim().is_empty() {
        return Err(TilesetError::invalid(field, "must not be empty"));
    }
    if value.len() > max_bytes {
        return Err(TilesetError::LimitExceeded {
            resource: "string bytes",
            requested: value.len() as u64,
            maximum: max_bytes as u64,
        });
    }
    Ok(())
}

fn validate_finite(value: f32, field: &str, limits: &TilesetLimits) -> Result<(), TilesetError> {
    if !value.is_finite() {
        return Err(TilesetError::invalid(field, "must be finite"));
    }
    if value.abs() > limits.max_numeric_value {
        return Err(TilesetError::LimitExceeded {
            resource: "numeric magnitude",
            requested: value.abs() as u64,
            maximum: limits.max_numeric_value as u64,
        });
    }
    Ok(())
}

fn validate_non_negative(
    value: f32,
    field: &str,
    limits: &TilesetLimits,
) -> Result<(), TilesetError> {
    validate_finite(value, field, limits)?;
    if value < 0.0 {
        return Err(TilesetError::invalid(field, "must be non-negative"));
    }
    Ok(())
}

fn validate_positive(value: f32, field: &str, limits: &TilesetLimits) -> Result<(), TilesetError> {
    validate_finite(value, field, limits)?;
    if value <= 0.0 {
        return Err(TilesetError::invalid(field, "must be greater than zero"));
    }
    Ok(())
}

fn validate_unit(value: f32, field: &str, limits: &TilesetLimits) -> Result<(), TilesetError> {
    validate_finite(value, field, limits)?;
    if !(0.0..=1.0).contains(&value) {
        return Err(TilesetError::invalid(field, "must be between 0 and 1"));
    }
    Ok(())
}

fn validate_color(values: &[f32], field: &str, limits: &TilesetLimits) -> Result<(), TilesetError> {
    for value in values {
        validate_unit(*value, field, limits)?;
    }
    Ok(())
}

fn validate_optional_enum(
    value: Option<&str>,
    field: &str,
    accepted: &[&str],
    limits: &TilesetLimits,
) -> Result<(), TilesetError> {
    let Some(value) = value else {
        return Ok(());
    };
    validate_text(value, field, limits.max_string_bytes)?;
    if !accepted.contains(&value) {
        return Err(TilesetError::invalid(
            field,
            "contains an unsupported value",
        ));
    }
    Ok(())
}
