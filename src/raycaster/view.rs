//! Owns camera-specific raycaster projection snapshots for independent viewports.
//! A view retains only its last built scene, depth columns, pick snapshot, camera, and presentation policy.
//! Authoritative cells remain owned by `Raycaster2D` or `MultiLevelGrid`; builds clone only the pick snapshot.
//! Render-target selection and command queuing remain in the Lua/runtime binding layer.

use super::{RaycasterLastBuildContext, RaycasterScene};
use crate::runtime::resource_keys::ShaderKey;

/// Screen-space rectangle assigned to one raycaster view.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct RaycasterViewport {
    /// Left edge in screen pixels.
    pub x: f32,
    /// Top edge in screen pixels.
    pub y: f32,
    /// Width in pixels.
    pub width: f32,
    /// Height in pixels.
    pub height: f32,
}

impl RaycasterViewport {
    /// Validates a finite positive viewport.
    pub fn validate(self) -> Result<Self, String> {
        if !self.x.is_finite()
            || !self.y.is_finite()
            || !self.width.is_finite()
            || !self.height.is_finite()
            || self.width <= 0.0
            || self.height <= 0.0
        {
            return Err(
                "viewport values must be finite and width/height must be positive".to_string(),
            );
        }
        Ok(self)
    }

    /// Returns whether a screen coordinate lies inside this viewport.
    pub fn contains(self, x: f32, y: f32) -> bool {
        x >= self.x && y >= self.y && x < self.x + self.width && y < self.y + self.height
    }
}

/// Camera values used to build one raycaster projection.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct RaycasterViewCamera {
    /// World X position.
    pub x: f32,
    /// World Y position.
    pub y: f32,
    /// Facing angle in radians.
    pub angle: f32,
    /// Horizontal field of view in radians.
    pub fov: f32,
    /// Eye height within the active cell volume.
    pub camera_height: f32,
    /// Vertical screen-space horizon offset.
    pub horizon_offset: f32,
}

impl Default for RaycasterViewCamera {
    fn default() -> Self {
        Self {
            x: 0.0,
            y: 0.0,
            angle: 0.0,
            fov: 66.0_f32.to_radians(),
            camera_height: 0.5,
            horizon_offset: 0.0,
        }
    }
}

/// Per-view projection quality.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct RaycasterViewQuality {
    /// Number of cast rays.
    pub rays: u32,
    /// Maximum world distance.
    pub max_distance: f32,
}

impl Default for RaycasterViewQuality {
    fn default() -> Self {
        Self {
            rays: 320,
            max_distance: 64.0,
        }
    }
}

/// Telemetry retained for the last view build.
#[derive(Debug, Clone, Copy, Default, PartialEq)]
pub struct RaycasterViewStats {
    /// CPU build time in milliseconds.
    pub build_time_ms: f64,
    /// Total projected primitives.
    pub quad_count: usize,
    /// Rays requested by this view.
    pub rays: u32,
    /// Stored depth columns.
    pub depth_columns: usize,
    /// Projected particles.
    pub particles: usize,
    /// Projected models.
    pub models: usize,
}

/// Isolated camera projection state for one viewport.
#[derive(Debug, Clone)]
pub struct RaycasterView {
    /// Screen composition rectangle.
    pub viewport: RaycasterViewport,
    /// Camera used for the next build.
    pub camera: RaycasterViewCamera,
    /// Quality used for the next build.
    pub quality: RaycasterViewQuality,
    /// Optional scene-wide shader.
    pub shader: Option<ShaderKey>,
    /// Last scene and exact pick-world snapshot.
    pub last_build: Option<RaycasterLastBuildContext>,
    /// Last build telemetry.
    pub stats: RaycasterViewStats,
}

impl RaycasterView {
    /// Creates an empty view with validated viewport dimensions.
    pub fn new(viewport: RaycasterViewport, quality: RaycasterViewQuality) -> Result<Self, String> {
        let viewport = viewport.validate()?;
        if quality.rays == 0 || quality.rays > 16_384 {
            return Err("rays must be in [1, 16384]".to_string());
        }
        if !quality.max_distance.is_finite()
            || quality.max_distance <= 0.0
            || quality.max_distance > 1_000_000.0
        {
            return Err("maxDistance must be finite and in (0, 1000000]".to_string());
        }
        Ok(Self {
            viewport,
            camera: RaycasterViewCamera::default(),
            quality,
            shader: None,
            last_build: None,
            stats: RaycasterViewStats::default(),
        })
    }

    /// Replaces the last projection and derives per-view telemetry.
    pub fn store_build(&mut self, build: RaycasterLastBuildContext, build_time_ms: f64) {
        let scene = &build.scene;
        self.stats = RaycasterViewStats {
            build_time_ms,
            quad_count: scene.quad_count(),
            rays: self.quality.rays,
            depth_columns: scene.depth_columns.len(),
            particles: scene.particles.len(),
            models: scene.models.len(),
        };
        self.last_build = Some(build);
    }

    /// Returns the last scene without exposing its authoritative source snapshot.
    pub fn scene(&self) -> Option<&RaycasterScene> {
        self.last_build.as_ref().map(|build| &build.scene)
    }

    /// Returns the wall depth for a screen X coordinate inside the viewport.
    pub fn depth_at(&self, screen_x: f32) -> Option<f32> {
        let scene = self.scene()?;
        if screen_x < self.viewport.x || screen_x >= self.viewport.x + self.viewport.width {
            return None;
        }
        if scene.depth_columns.is_empty() {
            return None;
        }
        let local_x = screen_x - self.viewport.x;
        let index = ((local_x / self.viewport.width) * scene.depth_columns.len() as f32)
            .floor()
            .clamp(0.0, scene.depth_columns.len().saturating_sub(1) as f32)
            as usize;
        scene.depth_columns.get(index).copied()
    }

    /// Clears the projection and telemetry while retaining configuration.
    pub fn clear(&mut self) {
        self.last_build = None;
        self.stats = RaycasterViewStats::default();
    }
}
