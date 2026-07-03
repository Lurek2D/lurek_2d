//! Owns the physics flow implementation for the physics subsystem and keeps related runtime rules local here.
//! Keeps body state, simulation helpers, and authored world contracts so helpers stay close to invariants this updates.
//! Defines how physics flow data is validated, transformed, or stored before neighboring systems consume it.
//! Separates physics flow behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where physics code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing physics flow defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the physics flow state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping physics flow calculations explicit at their owning subsystem boundary.

use super::error::PhysicsError;
use super::limits::{validate_finite, validate_positive};
use crate::math::Vec2;

/// Stable id used to address one authored flow field.
pub type FlowFieldId = usize;

/// Medium classification used by per-body response scaling.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FlowMedium {
    /// Air or wind style stream.
    Air,
    /// Water current or river flow.
    Water,
    /// Conveyor-belt style forced translation.
    Conveyor,
    /// Scripted or magical force channel.
    Magic,
    /// User-defined medium bucket.
    Custom,
}

/// How overlapping fields should be combined.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FlowCombineMode {
    /// Sum all contributions directly.
    Additive,
    /// Sum all contributions then clamp final magnitude.
    AdditiveClamped,
}

/// How the sampled flow vector should influence bodies.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FlowApplicationMode {
    /// Apply a direct acceleration independent of body mass.
    Acceleration,
    /// Apply drag toward the target flow velocity.
    TargetVelocityDrag,
}

/// Distance-to-edge falloff curve for one flow field.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FlowFalloff {
    /// Full strength across the whole shape.
    Constant,
    /// Linear fade from the centerline toward the boundary.
    Linear,
    /// Smoothstep fade from the centerline toward the boundary.
    Smoothstep,
}

/// Direction-selection strategy for one authored field.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum FlowDirectionMode {
    /// Use an explicit unit or non-unit vector.
    Explicit { x: f32, y: f32 },
    /// Follow the polyline tangent from start to end.
    AlongPath,
    /// Follow the polyline tangent from end to start.
    AgainstPath,
    /// Point away from the field center.
    RadialOut,
    /// Point toward the field center.
    RadialIn,
    /// Orbit around the field center in clockwise order.
    TangentialClockwise,
    /// Orbit around the field center in counter-clockwise order.
    TangentialCounterClockwise,
}

/// Geometry variants supported by the flow-field sampler.
#[derive(Debug, Clone, PartialEq)]
pub enum FlowGeometry {
    /// Uniform rectangular region.
    UniformRect { x: f32, y: f32, w: f32, h: f32 },
    /// Circular field with optional inner dead zone.
    CircleFan {
        cx: f32,
        cy: f32,
        radius: f32,
        inner_radius: f32,
    },
    /// Directional conical fan with optional inner dead zone.
    DirectionalFan {
        cx: f32,
        cy: f32,
        radius: f32,
        inner_radius: f32,
        facing: Vec2,
        half_angle_deg: f32,
    },
    /// Polyline stream with tube width.
    PolylineTube { points: Vec<Vec2>, width: f32 },
}

/// One field-level contribution inside a sampled overlap result.
#[derive(Debug, Clone, PartialEq)]
pub struct FlowContribution {
    /// Source field id.
    pub field_id: FlowFieldId,
    /// Source field kind.
    pub medium: FlowMedium,
    /// Contribution vector x component.
    pub vx: f32,
    /// Contribution vector y component.
    pub vy: f32,
    /// Contribution vector magnitude.
    pub magnitude: f32,
    /// Reference strength used to derive normalized intensity.
    pub reference_strength: f32,
}

/// Sample result returned by `World::sample_flow`.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct FlowSample {
    /// Combined vector x component.
    pub vx: f32,
    /// Combined vector y component.
    pub vy: f32,
    /// Combined vector magnitude.
    pub magnitude: f32,
    /// Normalized intensity in `0.0..=1.0` relative to the strongest contributing field.
    pub intensity: f32,
    /// Individual field contributions that produced the sample.
    pub contributions: Vec<FlowContribution>,
}

/// One authored flow field stored by the physics world.
#[derive(Debug, Clone, PartialEq)]
pub struct FlowField {
    /// Stable field id.
    pub id: FlowFieldId,
    /// True when this field participates in sampling and stepping.
    pub enabled: bool,
    /// Optional human-readable name.
    pub name: Option<String>,
    /// Medium bucket used by per-body coefficients.
    pub medium: FlowMedium,
    /// Authored field geometry.
    pub geometry: FlowGeometry,
    /// Base strength in world units per second.
    pub strength: f32,
    /// Direction-selection policy.
    pub direction: FlowDirectionMode,
    /// Distance fade policy.
    pub falloff: FlowFalloff,
    /// Overlap-combination policy.
    pub combine: FlowCombineMode,
    /// Body-application mode used during stepping.
    pub application: FlowApplicationMode,
    /// Priority used for future conflict resolution and debug ordering.
    pub priority: i32,
    /// Body-layer filter mask.
    pub layer_mask: u32,
    /// Optional final magnitude clamp.
    pub max_accel: Option<f32>,
    /// Optional drag coefficient for `TargetVelocityDrag`.
    pub drag: f32,
}

impl FlowField {
    /// Creates a flow field with explicit geometry and deterministic defaults.
    pub fn new(id: FlowFieldId, geometry: FlowGeometry) -> Self {
        Self {
            id,
            enabled: true,
            name: None,
            medium: FlowMedium::Air,
            geometry,
            strength: 120.0,
            direction: FlowDirectionMode::AlongPath,
            falloff: FlowFalloff::Smoothstep,
            combine: FlowCombineMode::Additive,
            application: FlowApplicationMode::Acceleration,
            priority: 0,
            layer_mask: u32::MAX,
            max_accel: None,
            drag: 1.0,
        }
    }

    /// Validates the authored field payload before the world accepts it.
    pub fn validate(&self) -> Result<(), PhysicsError> {
        validate_positive("flow.strength", f64::from(self.strength))?;
        validate_positive("flow.drag", f64::from(self.drag.max(1.0e-4)))?;
        if let Some(max_accel) = self.max_accel {
            validate_positive("flow.max_accel", f64::from(max_accel))?;
        }
        match self.direction {
            FlowDirectionMode::Explicit { x, y } => {
                validate_finite("flow.direction.x", f64::from(x))?;
                validate_finite("flow.direction.y", f64::from(y))?;
                if x.abs() <= 1.0e-6 && y.abs() <= 1.0e-6 {
                    return Err(PhysicsError::DegenerateGeometry {
                        context: "physics flow direction",
                        detail: "explicit direction must be non-zero",
                    });
                }
            }
            FlowDirectionMode::AlongPath
            | FlowDirectionMode::AgainstPath
            | FlowDirectionMode::RadialOut
            | FlowDirectionMode::RadialIn
            | FlowDirectionMode::TangentialClockwise
            | FlowDirectionMode::TangentialCounterClockwise => {}
        }
        match &self.geometry {
            FlowGeometry::UniformRect { x, y, w, h } => {
                validate_finite("flow.rect.x", f64::from(*x))?;
                validate_finite("flow.rect.y", f64::from(*y))?;
                validate_positive("flow.rect.w", f64::from(*w))?;
                validate_positive("flow.rect.h", f64::from(*h))?;
            }
            FlowGeometry::CircleFan {
                cx,
                cy,
                radius,
                inner_radius,
            } => {
                validate_finite("flow.circle.cx", f64::from(*cx))?;
                validate_finite("flow.circle.cy", f64::from(*cy))?;
                validate_positive("flow.circle.radius", f64::from(*radius))?;
                if *inner_radius < 0.0 || !inner_radius.is_finite() || *inner_radius >= *radius {
                    return Err(PhysicsError::ValueOutOfRange {
                        field: "flow.circle.inner_radius",
                        min: 0.0,
                        max: f64::from(*radius),
                        value: f64::from(*inner_radius),
                    });
                }
            }
            FlowGeometry::DirectionalFan {
                cx,
                cy,
                radius,
                inner_radius,
                facing,
                half_angle_deg,
            } => {
                validate_finite("flow.fan.cx", f64::from(*cx))?;
                validate_finite("flow.fan.cy", f64::from(*cy))?;
                validate_positive("flow.fan.radius", f64::from(*radius))?;
                validate_finite("flow.fan.facing.x", f64::from(facing.x))?;
                validate_finite("flow.fan.facing.y", f64::from(facing.y))?;
                if facing.length() <= 1.0e-6 {
                    return Err(PhysicsError::DegenerateGeometry {
                        context: "physics flow fan",
                        detail: "fan direction must be non-zero",
                    });
                }
                if *inner_radius < 0.0 || !inner_radius.is_finite() || *inner_radius >= *radius {
                    return Err(PhysicsError::ValueOutOfRange {
                        field: "flow.fan.inner_radius",
                        min: 0.0,
                        max: f64::from(*radius),
                        value: f64::from(*inner_radius),
                    });
                }
                if !half_angle_deg.is_finite() || *half_angle_deg <= 0.0 || *half_angle_deg > 180.0
                {
                    return Err(PhysicsError::ValueOutOfRange {
                        field: "flow.fan.half_angle_deg",
                        min: 0.0,
                        max: 180.0,
                        value: f64::from(*half_angle_deg),
                    });
                }
            }
            FlowGeometry::PolylineTube { points, width } => {
                validate_positive("flow.path.width", f64::from(*width))?;
                if points.len() < 2 {
                    return Err(PhysicsError::InvalidVertexCount {
                        context: "physics flow polyline",
                        count: points.len(),
                        min: 2,
                        max: usize::MAX,
                    });
                }
                for point in points {
                    validate_finite("flow.path.x", f64::from(point.x))?;
                    validate_finite("flow.path.y", f64::from(point.y))?;
                }
            }
        }
        Ok(())
    }

    /// Samples this field at one world position, returning zero when outside the field.
    pub fn sample(&self, x: f32, y: f32) -> Option<FlowContribution> {
        if !self.enabled {
            return None;
        }
        let (direction, weight) = match &self.geometry {
            FlowGeometry::UniformRect { x: rx, y: ry, w, h } => {
                if x < *rx || x > *rx + *w || y < *ry || y > *ry + *h {
                    return None;
                }
                let dx = (x - *rx).min(*rx + *w - x);
                let dy = (y - *ry).min(*ry + *h - y);
                let half_span = (w.min(*h) * 0.5).max(1.0e-4);
                let weight = self.falloff_weight((dx.min(dy) / half_span).clamp(0.0, 1.0));
                let center = Vec2::new(*rx + *w * 0.5, *ry + *h * 0.5);
                (self.direction_vector(center, None, x, y)?, weight)
            }
            FlowGeometry::CircleFan {
                cx,
                cy,
                radius,
                inner_radius,
            } => {
                let dx = x - *cx;
                let dy = y - *cy;
                let distance = (dx * dx + dy * dy).sqrt();
                if distance > *radius || distance < *inner_radius {
                    return None;
                }
                let span = (*radius - *inner_radius).max(1.0e-4);
                let weight = self.falloff_weight(1.0 - ((distance - *inner_radius) / span));
                let center = Vec2::new(*cx, *cy);
                (self.direction_vector(center, None, x, y)?, weight)
            }
            FlowGeometry::DirectionalFan {
                cx,
                cy,
                radius,
                inner_radius,
                facing,
                half_angle_deg,
            } => {
                let dx = x - *cx;
                let dy = y - *cy;
                let distance = (dx * dx + dy * dy).sqrt();
                if distance > *radius || distance < *inner_radius {
                    return None;
                }
                let radial = normalized_or_none(Vec2::new(dx, dy))?;
                let facing = normalized_or_none(*facing)?;
                let angle_cos = radial.dot(facing);
                let limit_cos = half_angle_deg.to_radians().cos();
                if angle_cos < limit_cos {
                    return None;
                }
                let span = (*radius - *inner_radius).max(1.0e-4);
                let radial_weight = self.falloff_weight(1.0 - ((distance - *inner_radius) / span));
                let angular_weight =
                    ((angle_cos - limit_cos) / (1.0 - limit_cos).max(1.0e-4)).clamp(0.0, 1.0);
                let weight = radial_weight * angular_weight;
                (facing, weight)
            }
            FlowGeometry::PolylineTube { points, width } => {
                let sample = closest_polyline_sample(points, x, y)?;
                if sample.distance > *width {
                    return None;
                }
                let weight = self.falloff_weight(1.0 - (sample.distance / *width).clamp(0.0, 1.0));
                (
                    self.direction_vector(sample.closest_point, Some(sample.tangent), x, y)?,
                    weight,
                )
            }
        };
        if weight <= 0.0 {
            return None;
        }
        let magnitude = self.strength * weight;
        let vector = direction * magnitude;
        Some(FlowContribution {
            field_id: self.id,
            medium: self.medium,
            vx: vector.x,
            vy: vector.y,
            magnitude: vector.length(),
            reference_strength: self.max_accel.unwrap_or(self.strength.max(1.0e-4)),
        })
    }

    fn direction_vector(
        &self,
        center: Vec2,
        tangent: Option<Vec2>,
        x: f32,
        y: f32,
    ) -> Option<Vec2> {
        match self.direction {
            FlowDirectionMode::Explicit { x, y } => normalized_or_none(Vec2::new(x, y)),
            FlowDirectionMode::AlongPath => tangent.and_then(normalized_or_none),
            FlowDirectionMode::AgainstPath => tangent.and_then(|value| normalized_or_none(-value)),
            FlowDirectionMode::RadialOut => {
                normalized_or_none(Vec2::new(x - center.x, y - center.y))
            }
            FlowDirectionMode::RadialIn => {
                normalized_or_none(Vec2::new(center.x - x, center.y - y))
            }
            FlowDirectionMode::TangentialClockwise => {
                normalized_or_none(Vec2::new(y - center.y, center.x - x))
            }
            FlowDirectionMode::TangentialCounterClockwise => {
                normalized_or_none(Vec2::new(center.y - y, x - center.x))
            }
        }
    }

    fn falloff_weight(&self, normalized: f32) -> f32 {
        let t = normalized.clamp(0.0, 1.0);
        match self.falloff {
            FlowFalloff::Constant => 1.0,
            FlowFalloff::Linear => t,
            FlowFalloff::Smoothstep => t * t * (3.0 - 2.0 * t),
        }
    }
}

/// Combines contributions that share one overlap sample into a final vector.
pub fn combine_contributions(
    contributions: Vec<FlowContribution>,
    combine: FlowCombineMode,
    clamp_limit: Option<f32>,
) -> FlowSample {
    if contributions.is_empty() {
        return FlowSample::default();
    }
    let mut vx = 0.0;
    let mut vy = 0.0;
    let mut strongest_reference: f32 = 0.0;
    for contribution in &contributions {
        vx += contribution.vx;
        vy += contribution.vy;
        strongest_reference = strongest_reference.max(contribution.reference_strength);
    }
    let magnitude = (vx * vx + vy * vy).sqrt();
    let (vx, vy, magnitude) = if matches!(combine, FlowCombineMode::AdditiveClamped) {
        let limit = clamp_limit.unwrap_or(strongest_reference).max(1.0e-4);
        if magnitude > limit {
            let scale = limit / magnitude;
            (vx * scale, vy * scale, limit)
        } else {
            (vx, vy, magnitude)
        }
    } else {
        (vx, vy, magnitude)
    };
    let intensity = if strongest_reference > 1.0e-4 {
        (magnitude / strongest_reference).clamp(0.0, 1.0)
    } else {
        0.0
    };
    FlowSample {
        vx,
        vy,
        magnitude,
        intensity,
        contributions,
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
struct ClosestPolylineSample {
    closest_point: Vec2,
    tangent: Vec2,
    distance: f32,
}

fn closest_polyline_sample(points: &[Vec2], x: f32, y: f32) -> Option<ClosestPolylineSample> {
    if points.len() < 2 {
        return None;
    }
    let query = Vec2::new(x, y);
    let mut best: Option<ClosestPolylineSample> = None;
    for segment_index in 0..points.len() - 1 {
        let start = points[segment_index];
        let end = points[segment_index + 1];
        let segment = end - start;
        let segment_len_sq = segment.x * segment.x + segment.y * segment.y;
        if segment_len_sq <= 1.0e-6 {
            continue;
        }
        let t = (((query - start).dot(segment)) / segment_len_sq).clamp(0.0, 1.0);
        let closest_point = start + segment * t;
        let distance = (query - closest_point).length();
        let tangent = segment;
        match best {
            Some(current) if current.distance <= distance => {}
            _ => {
                best = Some(ClosestPolylineSample {
                    closest_point,
                    tangent,
                    distance,
                });
            }
        }
    }
    best
}

fn normalized_or_none(value: Vec2) -> Option<Vec2> {
    let len = value.length();
    if len <= 1.0e-6 {
        None
    } else {
        Some(value / len)
    }
}
