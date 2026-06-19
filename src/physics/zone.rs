//! This file owns `PhysicsZone`, `ZoneBoundary`, `ZoneGravityMode`, and tracker events for area-based rule overrides.
//! It stores zone shape, gravity behavior, damping overrides, priority, filters, and enabled state in one owner.
//! Zone helpers configure rectangles or circles, directional gravity, point attraction, repulsion, and zero-gravity fields.
//! The tracker caches body membership so enter and leave transitions can feed gameplay events as well as force changes.
//! This file is the boundary for area effects driven by position rather than by rigid contact against solid geometry.
//! Open it when zone semantics change; body descriptors and world stepping rules live in sibling owners.

use std::collections::{HashMap, HashSet};

use super::error::PhysicsError;
use super::limits::{validate_finite, validate_positive};

/// Alias for a zone's numeric identifier.
pub type ZoneId = usize;
/// Alias for zone processing priority (higher wins).
pub type ZonePriority = i32;

/// Gravity behaviour applied to bodies inside the zone.
/// # Variants
/// - `Directional`: constant gravity vector override.
/// - `Point`: attraction toward a point.
/// - `Repulsor`: repulsion away from a point.
/// - `Zero`: zero-gravity override.
#[derive(Debug, Clone, PartialEq)]
pub enum ZoneGravityMode {
    /// Constant directional gravity `(gx, gy)`.
    Directional { gx: f32, gy: f32 },
    /// Gravity pulls toward point `(cx, cy)` with given `strength`.
    Point { cx: f32, cy: f32, strength: f32 },
    /// Gravity pushes away from point `(cx, cy)` with given `strength`.
    Repulsor { cx: f32, cy: f32, strength: f32 },
    /// Zero gravity - bodies float freely.
    Zero,
}
/// Spatial boundary shape for a zone.
/// # Variants
/// - `Rect`: axis-aligned rectangle boundary.
/// - `Circle`: circular boundary.
#[derive(Debug, Clone, PartialEq)]
pub enum ZoneBoundary {
    /// Axis-aligned rectangle with top-left `(x, y)` and size.
    Rect {
        /// Left edge x.
        x: f32,
        /// Top edge y.
        y: f32,
        /// Rectangle width.
        width: f32,
        /// Rectangle height.
        height: f32,
    },
    /// Circle centred at `(cx, cy)` with given `radius`.
    Circle {
        /// Centre x.
        cx: f32,
        /// Centre y.
        cy: f32,
        /// Circle radius.
        radius: f32,
    },
}
/// `ZoneBoundary` containment test.
impl ZoneBoundary {
    /// Validate the boundary against the shared zone contract.
    pub fn validate(&self) -> Result<(), PhysicsError> {
        match self {
            ZoneBoundary::Rect {
                x,
                y,
                width,
                height,
            } => {
                validate_finite("zone.x", f64::from(*x))?;
                validate_finite("zone.y", f64::from(*y))?;
                validate_positive("zone.width", f64::from(*width))?;
                validate_positive("zone.height", f64::from(*height))?;
            }
            ZoneBoundary::Circle { cx, cy, radius } => {
                validate_finite("zone.cx", f64::from(*cx))?;
                validate_finite("zone.cy", f64::from(*cy))?;
                validate_positive("zone.radius", f64::from(*radius))?;
            }
        }
        Ok(())
    }

    /// Return true if point `(px, py)` is inside this boundary.
    pub fn contains(&self, px: f32, py: f32) -> bool {
        match *self {
            ZoneBoundary::Rect {
                x,
                y,
                width,
                height,
            } => px >= x && px <= x + width && py >= y && py <= y + height,
            ZoneBoundary::Circle { cx, cy, radius } => {
                let dx = px - cx;
                let dy = py - cy;
                dx * dx + dy * dy <= radius * radius
            }
        }
    }
}
/// Zone enter/exit event discriminant.
/// # Variants
/// - `Enter`: a body entered the zone.
/// - `Leave`: a body left the zone.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ZoneEventKind {
    /// A body entered the zone.
    Enter,
    /// A body left the zone.
    Leave,
}
/// A zone crossing event emitted by `ZoneTracker::update`.
/// # Fields
/// - `zone_id`: zone crossed by the body.
/// - `body_id`: body that crossed the boundary.
/// - `kind`: whether it was an enter or leave transition.
#[derive(Debug, Clone)]
pub struct ZoneEvent {
    /// Id of the zone that was crossed.
    pub zone_id: ZoneId,
    /// Body id that crossed the boundary.
    pub body_id: usize,
    /// Whether the body entered or left.
    pub kind: ZoneEventKind,
}
/// A trigger zone that applies gravity and damping overrides to bodies inside it.
/// # Fields
/// - `id`: stable zone identifier.
/// - `boundary`: current containment shape.
/// - `gravity_mode`: override gravity behavior inside the zone.
/// - `priority`: higher-priority zones win during overlap.
/// - `linear_damping_override`: optional linear damping override.
/// - `angular_damping_override`: optional angular damping override.
/// - `layer_mask`: body layer filter mask.
/// - `enabled`: whether the zone participates in updates.
pub struct PhysicsZone {
    /// Unique numeric id assigned by `World`.
    pub id: ZoneId,
    /// Spatial boundary for containment tests.
    pub boundary: ZoneBoundary,
    /// Gravity behaviour inside this zone.
    pub gravity_mode: ZoneGravityMode,
    /// Processing priority; higher priority zones override lower ones.
    pub priority: ZonePriority,
    /// Optional linear damping override applied while inside.
    pub linear_damping_override: Option<f32>,
    /// Optional angular damping override applied while inside.
    pub angular_damping_override: Option<f32>,
    /// Bitmask: only bodies whose `layer & layer_mask != 0` are affected.
    pub layer_mask: u32,
    /// When false the zone is skipped entirely.
    pub enabled: bool,
}
/// `PhysicsZone` constructors and mutators.
impl PhysicsZone {
    fn validate_gravity_mode(gravity_mode: &ZoneGravityMode) -> Result<(), PhysicsError> {
        match gravity_mode {
            ZoneGravityMode::Directional { gx, gy } => {
                validate_finite("zone.gravity_x", f64::from(*gx))?;
                validate_finite("zone.gravity_y", f64::from(*gy))?;
            }
            ZoneGravityMode::Point { cx, cy, strength }
            | ZoneGravityMode::Repulsor { cx, cy, strength } => {
                validate_finite("zone.cx", f64::from(*cx))?;
                validate_finite("zone.cy", f64::from(*cy))?;
                validate_positive("zone.strength", f64::from(*strength))?;
            }
            ZoneGravityMode::Zero => {}
        }
        Ok(())
    }

    fn validate_damping(field: &'static str, value: Option<f32>) -> Result<(), PhysicsError> {
        if let Some(value) = value {
            validate_finite(field, f64::from(value))?;
            if value < 0.0 {
                return Err(PhysicsError::NonPositiveValue {
                    field,
                    value: f64::from(value),
                });
            }
        }
        Ok(())
    }

    /// Validate the zone boundary, gravity mode, and optional overrides.
    pub fn validate(&self) -> Result<(), PhysicsError> {
        self.boundary.validate()?;
        Self::validate_gravity_mode(&self.gravity_mode)?;
        Self::validate_damping("zone.linear_damping", self.linear_damping_override)?;
        Self::validate_damping("zone.angular_damping", self.angular_damping_override)?;
        Ok(())
    }

    /// Create a rectangular zone with zero gravity and default layer mask using strict validation.
    pub fn try_new_rect(
        id: ZoneId,
        x: f32,
        y: f32,
        width: f32,
        height: f32,
    ) -> Result<Self, PhysicsError> {
        let zone = Self {
            id,
            boundary: ZoneBoundary::Rect {
                x,
                y,
                width,
                height,
            },
            gravity_mode: ZoneGravityMode::Zero,
            priority: 0,
            linear_damping_override: None,
            angular_damping_override: None,
            layer_mask: 0xFFFF_FFFF,
            enabled: true,
        };
        zone.validate()?;
        Ok(zone)
    }

    /// Create a rectangular zone with zero gravity and default layer mask.
    pub fn new_rect(id: ZoneId, x: f32, y: f32, width: f32, height: f32) -> Self {
        Self::try_new_rect(id, x, y, width, height).unwrap_or_else(|_| Self {
            id,
            boundary: ZoneBoundary::Rect {
                x: if x.is_finite() { x } else { 0.0 },
                y: if y.is_finite() { y } else { 0.0 },
                width: if width.is_finite() {
                    width.abs().max(1.0)
                } else {
                    1.0
                },
                height: if height.is_finite() {
                    height.abs().max(1.0)
                } else {
                    1.0
                },
            },
            gravity_mode: ZoneGravityMode::Zero,
            priority: 0,
            linear_damping_override: None,
            angular_damping_override: None,
            layer_mask: 0xFFFF_FFFF,
            enabled: true,
        })
    }

    /// Replace the boundary with a circle centred at `(cx, cy)` with given `radius`.
    pub fn try_set_circle(&mut self, cx: f32, cy: f32, radius: f32) -> Result<(), PhysicsError> {
        let boundary = ZoneBoundary::Circle { cx, cy, radius };
        boundary.validate()?;
        self.boundary = boundary;
        Ok(())
    }

    /// Replace the boundary with a circle centred at `(cx, cy)` with given `radius`.
    pub fn set_circle(&mut self, cx: f32, cy: f32, radius: f32) {
        let _ = self.try_set_circle(cx, cy, radius);
    }

    /// Set constant directional gravity `(gx, gy)` for this zone.
    pub fn try_set_gravity_directional(&mut self, gx: f32, gy: f32) -> Result<(), PhysicsError> {
        let gravity_mode = ZoneGravityMode::Directional { gx, gy };
        Self::validate_gravity_mode(&gravity_mode)?;
        self.gravity_mode = gravity_mode;
        Ok(())
    }

    /// Set constant directional gravity `(gx, gy)` for this zone.
    pub fn set_gravity_directional(&mut self, gx: f32, gy: f32) {
        let _ = self.try_set_gravity_directional(gx, gy);
    }

    /// Set point-attractor gravity centred at `(cx, cy)` with given `strength`.
    pub fn try_set_gravity_point(
        &mut self,
        cx: f32,
        cy: f32,
        strength: f32,
    ) -> Result<(), PhysicsError> {
        let gravity_mode = ZoneGravityMode::Point { cx, cy, strength };
        Self::validate_gravity_mode(&gravity_mode)?;
        self.gravity_mode = gravity_mode;
        Ok(())
    }

    /// Set point-attractor gravity centred at `(cx, cy)` with given `strength`.
    pub fn set_gravity_point(&mut self, cx: f32, cy: f32, strength: f32) {
        let _ = self.try_set_gravity_point(cx, cy, strength);
    }

    /// Set repulsor gravity pushing away from `(cx, cy)` with given `strength`.
    pub fn try_set_gravity_repulsor(
        &mut self,
        cx: f32,
        cy: f32,
        strength: f32,
    ) -> Result<(), PhysicsError> {
        let gravity_mode = ZoneGravityMode::Repulsor { cx, cy, strength };
        Self::validate_gravity_mode(&gravity_mode)?;
        self.gravity_mode = gravity_mode;
        Ok(())
    }

    /// Set repulsor gravity pushing away from `(cx, cy)` with given `strength`.
    pub fn set_gravity_repulsor(&mut self, cx: f32, cy: f32, strength: f32) {
        let _ = self.try_set_gravity_repulsor(cx, cy, strength);
    }

    /// Set zero gravity for this zone.
    pub fn set_gravity_zero(&mut self) {
        self.gravity_mode = ZoneGravityMode::Zero;
    }

    /// Set or clear the linear damping override using strict validation.
    pub fn try_set_linear_damping_override(
        &mut self,
        value: Option<f32>,
    ) -> Result<(), PhysicsError> {
        Self::validate_damping("zone.linear_damping", value)?;
        self.linear_damping_override = value;
        Ok(())
    }

    /// Set or clear the angular damping override using strict validation.
    pub fn try_set_angular_damping_override(
        &mut self,
        value: Option<f32>,
    ) -> Result<(), PhysicsError> {
        Self::validate_damping("zone.angular_damping", value)?;
        self.angular_damping_override = value;
        Ok(())
    }

    /// Return true if the zone is enabled and the point `(px, py)` is inside its boundary.
    pub fn contains(&self, px: f32, py: f32) -> bool {
        self.enabled && self.boundary.contains(px, py)
    }
}
/// Tracks which bodies are inside which zones to generate enter/exit events.
/// # Fields
/// - `body_zones`: per-body zone membership cache.
pub struct ZoneTracker {
    /// Per-body set of zone ids currently containing that body.
    body_zones: HashMap<usize, HashSet<ZoneId>>,
}
/// `ZoneTracker` construction and per-step update.
impl ZoneTracker {
    /// Create an empty tracker. This function is part of the public API.
    pub fn new() -> Self {
        Self {
            body_zones: HashMap::new(),
        }
    }

    /// Diff `new_zones` against stored state for `body_id`; emit enter/leave events and update.
    pub fn update(&mut self, body_id: usize, new_zones: HashSet<ZoneId>) -> Vec<ZoneEvent> {
        let old = self.body_zones.entry(body_id).or_default();
        let mut events = Vec::new();
        for &zid in &new_zones {
            if !old.contains(&zid) {
                events.push(ZoneEvent {
                    zone_id: zid,
                    body_id,
                    kind: ZoneEventKind::Enter,
                });
            }
        }
        for &zid in old.iter() {
            if !new_zones.contains(&zid) {
                events.push(ZoneEvent {
                    zone_id: zid,
                    body_id,
                    kind: ZoneEventKind::Leave,
                });
            }
        }
        *old = new_zones;
        events
    }

    /// Remove all zone tracking state for `body_id`.
    pub fn remove_body(&mut self, body_id: usize) {
        self.body_zones.remove(&body_id);
    }

    /// Clear all per-body zone state.
    pub fn clear(&mut self) {
        self.body_zones.clear();
    }
}
/// Delegates to `ZoneTracker::new`.
impl Default for ZoneTracker {
    /// Delegate to `ZoneTracker::new`.
    fn default() -> Self {
        Self::new()
    }
}
