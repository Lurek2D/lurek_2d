//! Owns altitude-layer and 2.5D sidecar data for physics without changing the XY Rapier authority.
//! `AltitudeLayer` stores deterministic sampled terrain height and clearance grids for gameplay queries.
//! `BodyAltitudeState` and related enums keep per-body vertical metadata separate from core rigid-body state.
//! Ballistic and 2.5D query option/result structs live here so future world and Lua owners share one vocabulary.
//! This file does not run simulation steps; it only defines data and deterministic sampling helpers.

use crate::physics::error::PhysicsError;
use crate::physics::limits::{
    checked_terrain_cells, validate_finite, validate_positive, PhysicsLimits,
};

/// Sampling policy for altitude-layer world-coordinate lookups.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AltitudeSampleMode {
    /// Snap to the nearest authored cell center.
    Nearest,
    /// Blend the four nearest authored cell centers.
    Bilinear,
}

/// Serialized altitude-layer payload used for save/load and Lua-facing snapshots.
#[derive(Debug, Clone, PartialEq)]
pub struct AltitudeLayerData {
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// Size of one cell in world units.
    pub cell_size: f32,
    /// Ground height used when the layer is first created.
    pub default_ground_height: f32,
    /// Default sampling mode for future `sample_*` calls.
    pub sample_mode: AltitudeSampleMode,
    /// Terrain height per cell in row-major order.
    pub heights: Vec<f32>,
    /// Gameplay clearance per cell in row-major order.
    pub clearances: Vec<f32>,
}

/// Deterministic authored terrain-height and clearance grid for 2.5D gameplay.
#[derive(Debug, Clone, PartialEq)]
pub struct AltitudeLayer {
    width: u32,
    height: u32,
    cell_size: f32,
    default_ground_height: f32,
    sample_mode: AltitudeSampleMode,
    heights: Vec<f32>,
    clearances: Vec<f32>,
}

/// Body altitude interpretation mode.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AltitudeMode {
    /// Body stays grounded relative to sampled terrain height.
    Ground,
    /// Body uses terrain-relative altitude but is not forced to ground each step.
    Airborne,
    /// Body uses terrain-relative altitude and deterministic vertical integration.
    Ballistic,
    /// Body altitude is interpreted as absolute world-space Z.
    Fixed,
}

/// Flags controlling how altitude metadata participates in 2.5D collision rules.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct AltitudeCollisionOptions {
    /// Enables vertical collision filtering for this body.
    pub enabled: bool,
    /// Allows hits even when the Z intervals are disjoint.
    pub collide_when_separated: bool,
    /// Treat going below sampled terrain height as a ground hit.
    pub hit_ground_when_below_terrain: bool,
}

impl Default for AltitudeCollisionOptions {
    fn default() -> Self {
        Self {
            enabled: true,
            collide_when_separated: false,
            hit_ground_when_below_terrain: true,
        }
    }
}

/// Per-body vertical sidecar state stored by `World`.
#[derive(Debug, Clone, PartialEq)]
pub struct BodyAltitudeState {
    /// Terrain-relative or world-space altitude, depending on `mode`.
    pub z: f32,
    /// Vertical velocity in world units per second.
    pub vertical_velocity: f32,
    /// Explicit vertical target extent. `None` means derive a default from the body size.
    pub height_extent: Option<f32>,
    /// Altitude interpretation mode for the body.
    pub mode: AltitudeMode,
    /// Per-body vertical gravity in world units per second squared.
    pub vertical_gravity: f32,
    /// Gameplay clearance classification used by future query rules.
    pub clearance_class: String,
    /// Per-body altitude collision flags.
    pub collision: AltitudeCollisionOptions,
}

impl Default for BodyAltitudeState {
    fn default() -> Self {
        Self {
            z: 0.0,
            vertical_velocity: 0.0,
            height_extent: None,
            mode: AltitudeMode::Ground,
            vertical_gravity: 0.0,
            clearance_class: "ground".to_string(),
            collision: AltitudeCollisionOptions::default(),
        }
    }
}

impl BodyAltitudeState {
    /// Resolve the world-space Z interval using sampled ground height and an explicit body extent.
    pub fn world_z_range(&self, ground_height: f32, height_extent: f32) -> (f32, f32) {
        let z_min = match self.mode {
            AltitudeMode::Fixed => self.z,
            AltitudeMode::Ground | AltitudeMode::Airborne | AltitudeMode::Ballistic => {
                ground_height + self.z
            }
        };
        (z_min, z_min + height_extent.max(0.0))
    }
}

/// Result classification for future 2.5D hits and projectile traces.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AltitudeHitKind {
    /// Hit a body after XY and Z filtering.
    Body,
    /// Hit authored terrain height.
    Terrain,
    /// Hit implicit ground rules.
    Ground,
    /// Reached expiry without impact.
    Expired,
}

/// Shared 2.5D hit payload owned by the physics domain.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct AltitudeHit {
    /// Body that was hit, when applicable.
    pub body_id: Option<crate::physics::types::BodyId>,
    /// Impact point in XY world coordinates.
    pub point: (f32, f32),
    /// Surface normal in XY.
    pub normal: (f32, f32),
    /// Time or distance of impact along the source cast.
    pub toi: f32,
    /// World-space impact altitude.
    pub z: f32,
    /// Target minimum world-space Z, when a body was involved.
    pub target_z_min: Option<f32>,
    /// Target maximum world-space Z, when a body was involved.
    pub target_z_max: Option<f32>,
    /// Sampled ground height at the impact point.
    pub ground_height: f32,
    /// Hit classification.
    pub hit_kind: AltitudeHitKind,
}

/// Options for a future 2.5D swept-circle query.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct CircleCast25DOptions {
    /// Start X.
    pub x: f32,
    /// Start Y.
    pub y: f32,
    /// Start altitude.
    pub z: f32,
    /// Circle radius in XY.
    pub radius: f32,
    /// Vertical extent of the moving interval.
    pub height: f32,
    /// XY direction X.
    pub dx: f32,
    /// XY direction Y.
    pub dy: f32,
    /// Vertical travel.
    pub dz: f32,
    /// Maximum XY travel distance.
    pub max_dist: f32,
}

/// Options for a future deterministic ballistic trace.
#[derive(Debug, Clone, PartialEq)]
pub struct BallisticArcOptions {
    /// Trace origin in XY and altitude.
    pub from: (f32, f32, f32),
    /// Desired target point in XY and altitude.
    pub to: (f32, f32, f32),
    /// Desired horizontal travel speed.
    pub speed: f32,
    /// Vertical gravity in world units per second squared.
    pub gravity: f32,
    /// Projectile XY radius.
    pub radius: f32,
    /// Projectile height interval.
    pub height: f32,
    /// Maximum total simulation time.
    pub max_time: f32,
    /// Fixed deterministic sample interval.
    pub sample_dt: f32,
}

/// Options for an engine-owned ballistic projectile.
#[derive(Debug, Clone, PartialEq)]
pub struct BallisticProjectileOptions {
    /// Optional owning body id.
    pub owner: Option<usize>,
    /// Spawn origin in XY and altitude.
    pub from: (f32, f32, f32),
    /// Desired target point in XY and altitude.
    pub to: (f32, f32, f32),
    /// Desired horizontal travel speed.
    pub speed: f32,
    /// Vertical gravity in world units per second squared.
    pub gravity: f32,
    /// Projectile XY radius.
    pub radius: f32,
    /// Projectile height interval.
    pub height: f32,
    /// Maximum lifetime in seconds.
    pub max_time: f32,
    /// Fixed deterministic sample interval.
    pub sample_dt: f32,
}

/// Deterministic ballistic trace result.
#[derive(Debug, Clone, PartialEq)]
pub struct BallisticTrace {
    /// Sampled projectile points in `(x, y, z)` order.
    pub samples: Vec<(f32, f32, f32)>,
    /// First impact, if any.
    pub hit: Option<AltitudeHit>,
    /// Total simulated time.
    pub travel_time: f32,
    /// True when the trace reached expiry without an impact.
    pub expired: bool,
}

/// Engine-owned ballistic projectile state for future world stepping.
#[derive(Debug, Clone, PartialEq)]
pub struct BallisticProjectile {
    /// Stable projectile id within the world.
    pub id: usize,
    /// Optional owning body or gameplay id.
    pub owner: Option<usize>,
    /// Current XY and altitude position.
    pub position: (f32, f32, f32),
    /// Current XY and vertical velocity.
    pub velocity: (f32, f32, f32),
    /// XY radius.
    pub radius: f32,
    /// Vertical extent.
    pub height: f32,
    /// Gravity applied each step.
    pub gravity: f32,
    /// Seconds remaining before expiry.
    pub time_remaining: f32,
    /// Fixed deterministic stepping interval.
    pub sample_dt: f32,
}

impl AltitudeLayer {
    /// Construct a new altitude layer with deterministic default values.
    pub fn new(
        width: u32,
        height: u32,
        cell_size: f32,
        default_ground_height: f32,
        sample_mode: AltitudeSampleMode,
        limits: &PhysicsLimits,
    ) -> Result<Self, PhysicsError> {
        if width == 0 || height == 0 {
            return Err(PhysicsError::ConfigMismatch {
                context: "physics altitude layer",
                detail: format!("dimensions must be non-zero, got {}x{}", width, height),
            });
        }
        validate_positive("cell_size", f64::from(cell_size))?;
        validate_finite("default_ground_height", f64::from(default_ground_height))?;
        let cells = checked_terrain_cells(width, height, limits)?;
        Ok(Self {
            width,
            height,
            cell_size,
            default_ground_height,
            sample_mode,
            heights: vec![default_ground_height; cells],
            clearances: vec![0.0; cells],
        })
    }

    /// Build a layer from serialized data after validating dimensions and payload lengths.
    pub fn from_data(
        data: AltitudeLayerData,
        limits: &PhysicsLimits,
    ) -> Result<Self, PhysicsError> {
        let mut layer = Self::new(
            data.width,
            data.height,
            data.cell_size,
            data.default_ground_height,
            data.sample_mode,
            limits,
        )?;
        let expected = layer.heights.len();
        if data.heights.len() != expected {
            return Err(PhysicsError::InvalidLength {
                context: "physics altitude layer heights",
                expected,
                actual: data.heights.len(),
            });
        }
        if data.clearances.len() != expected {
            return Err(PhysicsError::InvalidLength {
                context: "physics altitude layer clearances",
                expected,
                actual: data.clearances.len(),
            });
        }
        for value in data.heights.iter().chain(data.clearances.iter()) {
            validate_finite("altitude_layer_value", f64::from(*value))?;
        }
        layer.heights = data.heights;
        layer.clearances = data.clearances;
        Ok(layer)
    }

    /// Serialize the full layer contents for save/load and Lua-facing snapshots.
    pub fn serialize(&self) -> AltitudeLayerData {
        AltitudeLayerData {
            width: self.width,
            height: self.height,
            cell_size: self.cell_size,
            default_ground_height: self.default_ground_height,
            sample_mode: self.sample_mode,
            heights: self.heights.clone(),
            clearances: self.clearances.clone(),
        }
    }

    /// Replace this layer with validated serialized data.
    pub fn load(
        &mut self,
        data: AltitudeLayerData,
        limits: &PhysicsLimits,
    ) -> Result<(), PhysicsError> {
        *self = Self::from_data(data, limits)?;
        Ok(())
    }

    /// Grid width in cells.
    pub fn width(&self) -> u32 {
        self.width
    }

    /// Grid height in cells.
    pub fn height(&self) -> u32 {
        self.height
    }

    /// Authored world-unit size of one cell.
    pub fn cell_size(&self) -> f32 {
        self.cell_size
    }

    /// Terrain height the layer was initialized with.
    pub fn default_ground_height(&self) -> f32 {
        self.default_ground_height
    }

    /// Default sample mode for world-coordinate lookups.
    pub fn sample_mode(&self) -> AltitudeSampleMode {
        self.sample_mode
    }

    /// Set the default sampling policy for future world-coordinate lookups.
    pub fn set_sample_mode(&mut self, sample_mode: AltitudeSampleMode) {
        self.sample_mode = sample_mode;
    }

    /// Set one authored height cell.
    pub fn set_cell_height(&mut self, cx: u32, cy: u32, height: f32) -> Result<(), PhysicsError> {
        validate_finite("height", f64::from(height))?;
        let index = self.cell_index(cx, cy)?;
        self.heights[index] = height;
        Ok(())
    }

    /// Read one authored height cell.
    pub fn get_cell_height(&self, cx: u32, cy: u32) -> Result<f32, PhysicsError> {
        Ok(self.heights[self.cell_index(cx, cy)?])
    }

    /// Set one authored clearance cell.
    pub fn set_cell_clearance(
        &mut self,
        cx: u32,
        cy: u32,
        clearance: f32,
    ) -> Result<(), PhysicsError> {
        validate_finite("clearance", f64::from(clearance))?;
        let index = self.cell_index(cx, cy)?;
        self.clearances[index] = clearance;
        Ok(())
    }

    /// Read one authored clearance cell.
    pub fn get_cell_clearance(&self, cx: u32, cy: u32) -> Result<f32, PhysicsError> {
        Ok(self.clearances[self.cell_index(cx, cy)?])
    }

    /// Sample terrain height at world position using the layer's default policy.
    pub fn sample_height(&self, x: f32, y: f32) -> Result<f32, PhysicsError> {
        self.sample_height_with_mode(x, y, self.sample_mode)
    }

    /// Sample clearance at world position using the layer's default policy.
    pub fn sample_clearance(&self, x: f32, y: f32) -> Result<f32, PhysicsError> {
        self.sample_clearance_with_mode(x, y, self.sample_mode)
    }

    /// Sample terrain height at world position using an explicit policy.
    pub fn sample_height_with_mode(
        &self,
        x: f32,
        y: f32,
        mode: AltitudeSampleMode,
    ) -> Result<f32, PhysicsError> {
        self.sample_grid(&self.heights, x, y, mode)
    }

    /// Sample clearance at world position using an explicit policy.
    pub fn sample_clearance_with_mode(
        &self,
        x: f32,
        y: f32,
        mode: AltitudeSampleMode,
    ) -> Result<f32, PhysicsError> {
        self.sample_grid(&self.clearances, x, y, mode)
    }

    fn cell_index(&self, cx: u32, cy: u32) -> Result<usize, PhysicsError> {
        if cx >= self.width || cy >= self.height {
            return Err(PhysicsError::ConfigMismatch {
                context: "physics altitude layer",
                detail: format!(
                    "cell ({}, {}) is outside {}x{}",
                    cx, cy, self.width, self.height
                ),
            });
        }
        Ok((cy as usize) * (self.width as usize) + (cx as usize))
    }

    fn sample_grid(
        &self,
        values: &[f32],
        x: f32,
        y: f32,
        mode: AltitudeSampleMode,
    ) -> Result<f32, PhysicsError> {
        validate_finite("x", f64::from(x))?;
        validate_finite("y", f64::from(y))?;
        let grid_x = x / self.cell_size - 0.5;
        let grid_y = y / self.cell_size - 0.5;
        Ok(match mode {
            AltitudeSampleMode::Nearest => {
                let ix = grid_x.round().clamp(0.0, (self.width - 1) as f32) as u32;
                let iy = grid_y.round().clamp(0.0, (self.height - 1) as f32) as u32;
                values[self.cell_index(ix, iy)?]
            }
            AltitudeSampleMode::Bilinear => {
                let x0f = grid_x.floor().clamp(0.0, (self.width - 1) as f32);
                let y0f = grid_y.floor().clamp(0.0, (self.height - 1) as f32);
                let x1f = (x0f + 1.0).clamp(0.0, (self.width - 1) as f32);
                let y1f = (y0f + 1.0).clamp(0.0, (self.height - 1) as f32);
                let tx = (grid_x - x0f).clamp(0.0, 1.0);
                let ty = (grid_y - y0f).clamp(0.0, 1.0);
                let x0 = x0f as u32;
                let y0 = y0f as u32;
                let x1 = x1f as u32;
                let y1 = y1f as u32;
                let v00 = values[self.cell_index(x0, y0)?];
                let v10 = values[self.cell_index(x1, y0)?];
                let v01 = values[self.cell_index(x0, y1)?];
                let v11 = values[self.cell_index(x1, y1)?];
                let top = v00 + (v10 - v00) * tx;
                let bottom = v01 + (v11 - v01) * tx;
                top + (bottom - top) * ty
            }
        })
    }
}
