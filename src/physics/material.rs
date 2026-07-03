//! Owns the physics material implementation for the physics subsystem and keeps related runtime rules local here.
//! Keeps body state, simulation helpers, and authored world contracts so helpers stay close to invariants this updates.
//! Defines how physics material data is validated, transformed, or stored before neighboring systems consume it.
//! Separates physics material behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where physics code accepts inputs, reports errors, allocates state, or emits outputs.

use super::error::PhysicsError;
use super::limits::{validate_finite, validate_positive, validate_range};

/// Reusable physics material properties shared by bodies and fixtures.
///
/// Solver-backed fields map onto Rapier body or collider settings, while gameplay fields remain metadata until
/// higher-level systems consume them.
#[derive(Debug, Clone, PartialEq)]
pub struct PhysicsMaterial {
    /// Optional authored material name.
    pub name: Option<String>,
    /// Collider density in mass-per-area units. Must stay positive.
    pub density: f32,
    /// Collider friction coefficient in `0.0..=1.0`.
    pub friction: f32,
    /// Collider restitution coefficient in `0.0..=1.0`.
    pub restitution: f32,
    /// Optional linear damping override applied on bodies.
    pub linear_damping: Option<f32>,
    /// Optional angular damping override applied on bodies.
    pub angular_damping: Option<f32>,
    /// Optional gravity-scale override applied on bodies.
    pub gravity_scale: Option<f32>,
    /// Optional explicit body mass override.
    pub mass_override: Option<f32>,
    /// Gameplay stickiness hint in `0.0..=1.0`.
    pub stickiness: f32,
    /// Gameplay adhesion hint in `0.0..=1.0`.
    pub adhesion: f32,
    /// Gameplay beam-reflection energy multiplier in `0.0..=1.0`.
    pub beam_reflectivity: f32,
    /// Gameplay projectile-reflection hint in `0.0..=1.0`.
    pub projectile_reflectivity: f32,
    /// Gameplay beam-absorption hint in `0.0..=1.0`.
    pub beam_absorption: f32,
    /// Gameplay buoyancy hint in `0.0..=1.0`.
    pub buoyancy: f32,
    /// Optional authored gameplay surface classification.
    pub surface_type: Option<String>,
}

impl Default for PhysicsMaterial {
    fn default() -> Self {
        Self {
            name: None,
            density: 1.0,
            friction: 0.5,
            restitution: 0.3,
            linear_damping: None,
            angular_damping: None,
            gravity_scale: None,
            mass_override: None,
            stickiness: 0.0,
            adhesion: 0.0,
            beam_reflectivity: 1.0,
            projectile_reflectivity: 1.0,
            beam_absorption: 0.0,
            buoyancy: 0.0,
            surface_type: None,
        }
    }
}

impl PhysicsMaterial {
    /// Return a body-material snapshot with body-only overrides cleared for fixture use.
    pub fn fixture_scope(&self) -> Self {
        let mut material = self.clone();
        material.linear_damping = None;
        material.angular_damping = None;
        material.gravity_scale = None;
        material.mass_override = None;
        material
    }

    /// Validate every numeric field using the shared strict physics contract.
    pub fn validate(&self) -> Result<(), PhysicsError> {
        validate_positive("density", f64::from(self.density))?;
        validate_range("friction", f64::from(self.friction), 0.0, 1.0)?;
        validate_range("restitution", f64::from(self.restitution), 0.0, 1.0)?;
        validate_range("stickiness", f64::from(self.stickiness), 0.0, 1.0)?;
        validate_range("adhesion", f64::from(self.adhesion), 0.0, 1.0)?;
        validate_range(
            "beam_reflectivity",
            f64::from(self.beam_reflectivity),
            0.0,
            1.0,
        )?;
        validate_range(
            "projectile_reflectivity",
            f64::from(self.projectile_reflectivity),
            0.0,
            1.0,
        )?;
        validate_range("beam_absorption", f64::from(self.beam_absorption), 0.0, 1.0)?;
        validate_range("buoyancy", f64::from(self.buoyancy), 0.0, 1.0)?;
        if let Some(value) = self.linear_damping {
            validate_finite("linear_damping", f64::from(value))?;
            if value < 0.0 {
                return Err(PhysicsError::ValueOutOfRange {
                    field: "linear_damping",
                    min: 0.0,
                    max: f64::INFINITY,
                    value: f64::from(value),
                });
            }
        }
        if let Some(value) = self.angular_damping {
            validate_finite("angular_damping", f64::from(value))?;
            if value < 0.0 {
                return Err(PhysicsError::ValueOutOfRange {
                    field: "angular_damping",
                    min: 0.0,
                    max: f64::INFINITY,
                    value: f64::from(value),
                });
            }
        }
        if let Some(value) = self.gravity_scale {
            validate_finite("gravity_scale", f64::from(value))?;
        }
        if let Some(value) = self.mass_override {
            validate_positive("mass_override", f64::from(value))?;
        }
        Ok(())
    }
}
