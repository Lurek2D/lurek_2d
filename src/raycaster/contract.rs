//! Shared validation contracts for raycaster storage, ray parameters, projection, and scene input.
//! Strict `try_*` entrypoints surface `RaycasterError` through Rust and Lua, while legacy helpers can
//! sanitize or ignore invalid requests without panicking or allocating unbounded buffers.

use std::f32::consts::PI;
use thiserror::Error;

/// Policy used by checked cell queries when the caller probes outside the authored map bounds.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum OutOfBoundsPolicy {
    /// Treat out-of-bounds space as empty/open.
    #[default]
    Open,
    /// Treat out-of-bounds space as a blocking wall.
    Blocked,
    /// Treat out-of-bounds space as an immediate stop condition.
    Stop,
}

/// Shared safety limits for grid allocation, ray fan size, and screen-facing projection inputs.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct RaycasterLimits {
    /// Maximum accepted map width for one dense raycaster grid.
    pub max_map_width: u32,
    /// Maximum accepted map height for one dense raycaster grid.
    pub max_map_height: u32,
    /// Maximum accepted map cell count for one dense raycaster grid.
    pub max_map_cells: u64,
    /// Maximum accepted ray fan count for one `cast_rays*` request.
    pub max_rays: u32,
    /// Maximum accepted layered hit count for `cast_ray_multi`.
    pub max_multi_hits: u32,
    /// Maximum accepted viewport width for projection and picking helpers.
    pub max_screen_width: u32,
    /// Maximum accepted viewport height for projection and picking helpers.
    pub max_screen_height: u32,
    /// Maximum accepted render/pick distance in tile units.
    pub max_distance: f32,
    /// Smallest accepted finite field of view in radians.
    pub min_fov: f32,
    /// Largest accepted finite field of view in radians.
    pub max_fov: f32,
    /// Maximum number of billboard sprites accepted in one build.
    pub max_scene_sprites: usize,
    /// Maximum number of transient models accepted in one build.
    pub max_scene_models: usize,
    /// Maximum number of point lights accepted in one build.
    pub max_scene_lights: usize,
    /// Default OOB policy assigned to new raycaster grids.
    pub default_oob_policy: OutOfBoundsPolicy,
}

impl Default for RaycasterLimits {
    fn default() -> Self {
        Self {
            max_map_width: 8_192,
            max_map_height: 8_192,
            max_map_cells: 4_194_304,
            max_rays: 16_384,
            max_multi_hits: 8,
            max_screen_width: 16_384,
            max_screen_height: 16_384,
            max_distance: 100_000.0,
            min_fov: 0.01,
            max_fov: PI - 0.01,
            max_scene_sprites: 65_536,
            max_scene_models: 16_384,
            max_scene_lights: 16_384,
            default_oob_policy: OutOfBoundsPolicy::Open,
        }
    }
}

impl RaycasterLimits {
    /// Validate grid dimensions without allocating.
    pub fn validate_grid_dimensions(
        &self,
        width: u32,
        height: u32,
    ) -> Result<usize, RaycasterError> {
        if width == 0 || height == 0 {
            return Err(RaycasterError::GridDimensionsZero { width, height });
        }
        if width > self.max_map_width || height > self.max_map_height {
            return Err(RaycasterError::GridDimensionsTooLarge {
                width: width as u64,
                height: height as u64,
                max_width: self.max_map_width as u64,
                max_height: self.max_map_height as u64,
            });
        }
        let cell_count = u64::from(width) * u64::from(height);
        if cell_count > self.max_map_cells {
            return Err(RaycasterError::GridCellLimitExceeded {
                cell_count,
                limit: self.max_map_cells,
            });
        }
        Ok(cell_count as usize)
    }

    /// Validate grid dimensions supplied as `usize` from multilevel owners.
    pub fn validate_grid_dimensions_usize(
        &self,
        width: usize,
        height: usize,
    ) -> Result<usize, RaycasterError> {
        if width == 0 || height == 0 {
            return Err(RaycasterError::GridDimensionsZero {
                width: width.min(u32::MAX as usize) as u32,
                height: height.min(u32::MAX as usize) as u32,
            });
        }
        let width_u64 = width as u64;
        let height_u64 = height as u64;
        if width_u64 > u64::from(self.max_map_width) || height_u64 > u64::from(self.max_map_height)
        {
            return Err(RaycasterError::GridDimensionsTooLarge {
                width: width_u64,
                height: height_u64,
                max_width: self.max_map_width as u64,
                max_height: self.max_map_height as u64,
            });
        }
        let cell_count =
            width_u64
                .checked_mul(height_u64)
                .ok_or(RaycasterError::GridCellLimitExceeded {
                    cell_count: u64::MAX,
                    limit: self.max_map_cells,
                })?;
        if cell_count > self.max_map_cells {
            return Err(RaycasterError::GridCellLimitExceeded {
                cell_count,
                limit: self.max_map_cells,
            });
        }
        Ok(cell_count as usize)
    }

    /// Return safe legacy dimensions for constructors that cannot fail.
    pub fn sanitize_grid_dimensions(&self, width: u32, height: u32) -> (u32, u32, usize) {
        match self.validate_grid_dimensions(width, height) {
            Ok(cell_count) => (width, height, cell_count),
            Err(_) => (0, 0, 0),
        }
    }

    /// Validate that a float input is finite.
    pub fn validate_finite(&self, field: &'static str, value: f32) -> Result<(), RaycasterError> {
        if value.is_finite() {
            Ok(())
        } else {
            Err(RaycasterError::InvalidFloat { field })
        }
    }

    /// Validate a finite, positive viewport axis against shared limits.
    pub fn validate_screen_axis(
        &self,
        field: &'static str,
        value: f32,
        max: u32,
    ) -> Result<(), RaycasterError> {
        self.validate_finite(field, value)?;
        if value <= 0.0 || value > max as f32 {
            return Err(RaycasterError::InvalidScreenSize { field, value, max });
        }
        Ok(())
    }

    /// Validate both viewport axes used by picking and scene building.
    pub fn validate_screen_dimensions(
        &self,
        screen_width: f32,
        screen_height: f32,
    ) -> Result<(), RaycasterError> {
        self.validate_screen_axis("screen_width", screen_width, self.max_screen_width)?;
        self.validate_screen_axis("screen_height", screen_height, self.max_screen_height)?;
        Ok(())
    }

    /// Validate a finite positive max distance.
    pub fn validate_max_distance(&self, distance: f32) -> Result<(), RaycasterError> {
        self.validate_finite("max_distance", distance)?;
        if distance <= 0.0 || distance > self.max_distance {
            return Err(RaycasterError::InvalidMaxDistance {
                distance,
                max: self.max_distance,
            });
        }
        Ok(())
    }

    /// Validate a finite field of view within the configured range.
    pub fn validate_fov(&self, fov: f32) -> Result<(), RaycasterError> {
        self.validate_finite("fov", fov)?;
        if fov <= self.min_fov || fov >= self.max_fov {
            return Err(RaycasterError::InvalidFov {
                fov,
                min: self.min_fov,
                max: self.max_fov,
            });
        }
        Ok(())
    }

    /// Validate scene input counts against configured caps.
    pub fn validate_scene_counts(
        &self,
        sprites: usize,
        models: usize,
        lights: usize,
    ) -> Result<(), RaycasterError> {
        self.validate_scene_count("sprites", sprites, self.max_scene_sprites)?;
        self.validate_scene_count("models", models, self.max_scene_models)?;
        self.validate_scene_count("lights", lights, self.max_scene_lights)?;
        Ok(())
    }

    fn validate_scene_count(
        &self,
        kind: &'static str,
        count: usize,
        limit: usize,
    ) -> Result<(), RaycasterError> {
        if count > limit {
            return Err(RaycasterError::TooManySceneEntries { kind, count, limit });
        }
        Ok(())
    }
}

/// Shared ray-step parameter bundle used by strict DDA entrypoints.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct RaycastParams {
    /// Ray origin X coordinate in tile-space units.
    pub origin_x: f32,
    /// Ray origin Y coordinate in tile-space units.
    pub origin_y: f32,
    /// Base ray angle in radians.
    pub angle: f32,
    /// Optional horizontal FOV used by fan casts.
    pub fov: Option<f32>,
    /// Optional number of rays used by fan casts.
    pub count: Option<u32>,
    /// Maximum distance in tile units before the cast terminates.
    pub max_distance: f32,
    /// Optional layered hit count used by transparent-wall casts.
    pub max_hits: Option<u32>,
}

impl RaycastParams {
    /// Validate DDA-facing parameters against shared limits.
    pub fn validate(&self, limits: &RaycasterLimits) -> Result<(), RaycasterError> {
        limits.validate_finite("origin_x", self.origin_x)?;
        limits.validate_finite("origin_y", self.origin_y)?;
        limits.validate_finite("angle", self.angle)?;
        limits.validate_max_distance(self.max_distance)?;
        if let Some(fov) = self.fov {
            limits.validate_fov(fov)?;
        }
        if let Some(count) = self.count {
            if count == 0 || count > limits.max_rays {
                return Err(RaycasterError::InvalidRayCount {
                    count,
                    max: limits.max_rays,
                });
            }
        }
        if let Some(max_hits) = self.max_hits {
            if max_hits == 0 || max_hits > limits.max_multi_hits {
                return Err(RaycasterError::InvalidHitCount {
                    count: max_hits,
                    max: limits.max_multi_hits,
                });
            }
        }
        Ok(())
    }
}

/// Shared wall-column projection parameters used by strict projection entrypoints.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ProjectionParams {
    /// Perpendicular distance from the camera to the wall slice.
    pub distance: f32,
    /// Horizontal camera FOV in radians.
    pub fov: f32,
    /// Viewport height in pixels.
    pub screen_height: f32,
}

impl ProjectionParams {
    /// Validate projection inputs against shared limits.
    pub fn validate(&self, limits: &RaycasterLimits) -> Result<(), RaycasterError> {
        limits.validate_finite("distance", self.distance)?;
        limits.validate_fov(self.fov)?;
        limits.validate_screen_axis(
            "screen_height",
            self.screen_height,
            limits.max_screen_height,
        )?;
        Ok(())
    }
}

/// Structured failures used by strict raycaster constructors, validators, and scene adapters.
#[derive(Debug, Clone, Error, PartialEq)]
pub enum RaycasterError {
    /// Grid dimensions must be non-zero for strict constructors.
    #[error("raycaster grid dimensions must be greater than zero (got {width}x{height})")]
    GridDimensionsZero { width: u32, height: u32 },
    /// Grid dimensions exceeded the configured per-axis caps.
    #[error(
        "raycaster grid dimensions {width}x{height} exceed the supported limit {max_width}x{max_height}"
    )]
    GridDimensionsTooLarge {
        width: u64,
        height: u64,
        max_width: u64,
        max_height: u64,
    },
    /// Grid allocation would exceed the configured dense-cell cap.
    #[error("raycaster grid has {cell_count} cells but the limit is {limit}")]
    GridCellLimitExceeded { cell_count: u64, limit: u64 },
    /// Bulk cell setters received the wrong number of values.
    #[error("{context} expected exactly {expected} values but received {actual}")]
    DataLengthMismatch {
        context: &'static str,
        expected: usize,
        actual: usize,
    },
    /// A public float input was NaN or infinite.
    #[error("{field} must be a finite number")]
    InvalidFloat { field: &'static str },
    /// A field of view was outside the supported range.
    #[error("fov {fov} is outside the supported range {min}..{max}")]
    InvalidFov { fov: f32, min: f32, max: f32 },
    /// A ray fan requested zero or too many rays.
    #[error("ray count {count} is outside the supported range 1..={max}")]
    InvalidRayCount { count: u32, max: u32 },
    /// A layered cast requested zero or too many hits.
    #[error("layered hit count {count} is outside the supported range 1..={max}")]
    InvalidHitCount { count: u32, max: u32 },
    /// A max-distance input was non-positive or exceeded the shared cap.
    #[error("max distance {distance} is outside the supported range 0..={max}")]
    InvalidMaxDistance { distance: f32, max: f32 },
    /// A viewport axis was non-positive or exceeded the shared cap.
    #[error("{field} {value} is outside the supported range 0..={max}")]
    InvalidScreenSize {
        field: &'static str,
        value: f32,
        max: u32,
    },
    /// Door speed must be finite and non-negative.
    #[error("door speed {speed} must be finite and >= 0")]
    InvalidDoorSpeed { speed: f32 },
    /// A door update used a negative or non-finite delta time.
    #[error("door update dt {dt} must be finite and >= 0")]
    InvalidDoorDelta { dt: f32 },
    /// A strict door add collided with an existing door tile.
    #[error("door tile ({x}, {y}) already exists")]
    DuplicateDoorTile { x: u32, y: u32 },
    /// A synchronized door referenced a tile outside the target map.
    #[error("door tile ({x}, {y}) is outside raycaster bounds {width}x{height}")]
    DoorOutOfBounds {
        x: u32,
        y: u32,
        width: u32,
        height: u32,
    },
    /// A synchronized door referenced an empty/non-wall base tile.
    #[error("door tile ({x}, {y}) must reference a non-zero wall cell")]
    DoorOnEmptyCell { x: u32, y: u32 },
    /// A numeric texture id did not resolve to a live resource.
    #[error("{context}: texture id {raw_id} does not exist in the current resource registry")]
    InvalidTextureKey { raw_id: u64, context: String },
    /// One scene build input array exceeded the configured cap.
    #[error("{kind} count {count} exceeds the configured limit {limit}")]
    TooManySceneEntries {
        kind: &'static str,
        count: usize,
        limit: usize,
    },
}
