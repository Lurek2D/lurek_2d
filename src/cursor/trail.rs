//! `src/cursor/trail.rs` owns cursor trail sampling, retention, and render-facing configuration.
//! It keeps the runtime point buffer together with mode, spacing, lifetime, blend, and optional texture/shader data.
//! `CursorTrail` stores author-facing knobs for points, lines, ribbons, and stamped cursor decals in one place.
//! `TrailPoint` records sampled screen positions plus age so fading and pruning stay deterministic frame to frame.
//! The file is the narrow owner for trail spacing rules, width settings, max-point limits, and blend defaults.
//! Open this file when cursor trails change shape or lifetime semantics, not when cursor-state policy changes.

use crate::render::renderer::BlendMode;
use crate::runtime::resource_keys::{ShaderKey, TextureKey};
use std::collections::VecDeque;

/// One sampled point inside the cursor trail buffer.
#[derive(Debug, Clone, Copy)]
pub struct TrailPoint {
    pub x: f32,
    pub y: f32,
    pub age: f32,
}

/// Trail drawing mode.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TrailMode {
    /// Legacy point-fade mode kept for backward compatibility.
    FadePoints,
    /// Connected line strip.
    Line,
    /// Thicker ribbon-like strip.
    Ribbon,
    /// Repeated textured or circle stamps.
    Stamp,
    /// Alias for point-driven runtime trails.
    Points,
}

/// Runtime trail state and presentation config.
#[derive(Debug, Clone)]
pub struct CursorTrail {
    mode: TrailMode,
    points: VecDeque<TrailPoint>,
    max_points: usize,
    active: bool,
    spacing: f32,
    lifetime: f32,
    width: f32,
    color: [f32; 4],
    texture_key: Option<TextureKey>,
    shader_key: Option<ShaderKey>,
    blend: BlendMode,
}

impl CursorTrail {
    /// Create a new trail with one mode and default render settings.
    pub fn new(mode: TrailMode) -> Self {
        let (width, lifetime) = match mode {
            TrailMode::Line => (2.0, 0.5),
            TrailMode::Ribbon => (8.0, 0.45),
            TrailMode::Stamp => (10.0, 0.35),
            TrailMode::FadePoints | TrailMode::Points => (4.0, 0.35),
        };
        Self {
            mode,
            points: VecDeque::new(),
            max_points: 96,
            active: true,
            spacing: 3.0,
            lifetime,
            width,
            color: [1.0, 1.0, 1.0, 0.85],
            texture_key: None,
            shader_key: None,
            blend: BlendMode::Alpha,
        }
    }

    /// Tick the trail and append a new point when the cursor moved far enough.
    pub fn update(&mut self, x: f32, y: f32, dt: f32) {
        if !self.active {
            return;
        }

        for point in self.points.iter_mut() {
            point.age += dt.max(0.0);
        }
        while let Some(point) = self.points.front() {
            if point.age >= self.lifetime.max(0.001) {
                self.points.pop_front();
            } else {
                break;
            }
        }

        let should_add = match self.points.back() {
            Some(last) => {
                let dx = x - last.x;
                let dy = y - last.y;
                dx * dx + dy * dy >= self.spacing * self.spacing
            }
            None => true,
        };

        if should_add {
            if self.points.len() >= self.max_points {
                self.points.pop_front();
            }
            self.points.push_back(TrailPoint { x, y, age: 0.0 });
        }
    }

    /// Return the ordered trail points.
    pub fn get_points(&self) -> &VecDeque<TrailPoint> {
        &self.points
    }

    /// Clear the stored trail points.
    pub fn clear(&mut self) {
        self.points.clear();
    }

    /// Enable or disable trail recording.
    pub fn set_active(&mut self, active: bool) {
        self.active = active;
        if !active {
            self.points.clear();
        }
    }

    /// Return `true` when the trail is actively sampling points.
    pub fn is_active(&self) -> bool {
        self.active
    }

    /// Return the trail mode.
    pub fn mode(&self) -> TrailMode {
        self.mode
    }

    /// Replace the trail mode and clear existing samples.
    pub fn set_mode(&mut self, mode: TrailMode) {
        self.mode = mode;
        self.points.clear();
    }

    /// Return the current lifetime in seconds.
    pub fn lifetime(&self) -> f32 {
        self.lifetime
    }

    /// Set trail lifetime in seconds.
    pub fn set_lifetime(&mut self, lifetime: f32) {
        self.lifetime = lifetime.max(0.01);
    }

    /// Return the current sample spacing.
    pub fn spacing(&self) -> f32 {
        self.spacing
    }

    /// Set the minimum sample spacing in pixels.
    pub fn set_spacing(&mut self, spacing: f32) {
        self.spacing = spacing.max(0.5);
    }

    /// Return the trail width or point size in pixels.
    pub fn width(&self) -> f32 {
        self.width
    }

    /// Set trail width or point size.
    pub fn set_width(&mut self, width: f32) {
        self.width = width.max(0.5);
    }

    /// Return the configured maximum number of stored points.
    pub fn max_points(&self) -> usize {
        self.max_points
    }

    /// Set the maximum point count.
    pub fn set_max_points(&mut self, max_points: usize) {
        self.max_points = max_points.max(1);
        while self.points.len() > self.max_points {
            self.points.pop_front();
        }
    }

    /// Return the trail tint color.
    pub fn color(&self) -> [f32; 4] {
        self.color
    }

    /// Set the trail tint color.
    pub fn set_color(&mut self, color: [f32; 4]) {
        self.color = color;
    }

    /// Return the optional texture key used by stamp trails.
    pub fn texture_key(&self) -> Option<TextureKey> {
        self.texture_key
    }

    /// Set the optional texture key used by stamp trails.
    pub fn set_texture_key(&mut self, texture_key: Option<TextureKey>) {
        self.texture_key = texture_key;
    }

    /// Return the optional shader key.
    pub fn shader_key(&self) -> Option<ShaderKey> {
        self.shader_key
    }

    /// Set the optional shader key.
    pub fn set_shader_key(&mut self, shader_key: Option<ShaderKey>) {
        self.shader_key = shader_key;
    }

    /// Return the blend mode used while drawing the trail.
    pub fn blend(&self) -> BlendMode {
        self.blend
    }

    /// Set the blend mode used while drawing the trail.
    pub fn set_blend(&mut self, blend: BlendMode) {
        self.blend = blend;
    }
}
