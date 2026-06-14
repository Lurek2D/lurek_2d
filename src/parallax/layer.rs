//! Single parallax layer definition with scroll factor, autoscroll, tiling, opacity, and tint.
//! Carries draw-batch state so render submission stays separated from configuration.
//! Computes camera-relative pixel offsets with optional scroll clamping.
//! Delegates tile repetition to tile_iter for viewport coverage.
//! Supports motion-stretch blur injection based on autoscroll velocity.
//! Manages a small shader effect chain per layer for extra visual variation.

use crate::render::BlendMode;
use crate::render::ShaderPassDescriptor;
use crate::runtime::resource_keys::TextureKey;
use std::collections::HashMap;
/// Minimum tile edge size in pixels; prevents degenerate zero-area tile geometry.
const MIN_TILE_SIZE: f32 = 16.0;
/// Fallback scale used when hostile or invalid input provides a non-positive scale.
const DEFAULT_SCALE: f32 = 1.0;

/// Snapshot of per-layer runtime telemetry for diagnostics and dashboard surfaces.
#[derive(Debug, Clone, PartialEq)]
pub struct ParallaxLayerStats {
    /// Number of visible tiles produced for the current view.
    pub visible_tile_count: usize,
    /// Effective tile width in pixels after overrides and scaling.
    pub tile_width: f32,
    /// Effective tile height in pixels after overrides and scaling.
    pub tile_height: f32,
    /// X scale submitted to the renderer.
    pub draw_scale_x: f32,
    /// Y scale submitted to the renderer.
    pub draw_scale_y: f32,
    /// Number of effect passes active on this layer for the current view.
    pub effect_pass_count: usize,
    /// Integer z-order of the layer.
    pub z: i32,
    /// Floating-point depth of the layer.
    pub depth: f32,
    /// Whether the layer is currently visible.
    pub visible: bool,
    /// Whether motion stretch is enabled.
    pub motion_stretch_enabled: bool,
    /// Magnitude of the current autoscroll velocity.
    pub autoscroll_speed: f32,
}

fn positive_finite_or(value: f32, fallback: f32) -> f32 {
    if value.is_finite() && value > 0.0 {
        value
    } else {
        fallback
    }
}

fn finite_or(value: f32, fallback: f32) -> f32 {
    if value.is_finite() {
        value
    } else {
        fallback
    }
}
/// Accumulated draw data for one parallax layer ready to submit to the renderer.
pub struct ParallaxDrawBatch {
    /// Texture to draw for every tile position.
    pub texture_key: TextureKey,
    /// World-space `(x, y)` positions for each tile instance to draw.
    pub tiles: Vec<(f32, f32)>,
    /// Horizontal scale factor applied to the texture at draw time.
    pub sx: f32,
    /// Vertical scale factor applied to the texture at draw time.
    pub sy: f32,
    /// RGBA tint colour with pre-multiplied alpha.
    pub color: [f32; 4],
    /// Blend mode to use for every tile in this batch.
    pub blend_mode: BlendMode,
    /// Optional post-process shader chain applied after the batch is drawn.
    pub effect: Option<Vec<ShaderPassDescriptor>>,
}
/// Single scrolling background layer with optional tiling, tint, autoscroll, and shader effects.
pub struct ParallaxLayer {
    /// Handle to the layer's source texture.
    pub texture_key: TextureKey,
    /// Source texture width in pixels before scaling.
    pub texture_width: f32,
    /// Source texture height in pixels before scaling.
    pub texture_height: f32,
    /// Scroll multiplier `[x, y]` relative to camera movement (0.0 = fixed, 1.0 = matches camera).
    pub scroll_factor: [f32; 2],
    /// Constant world-space offset `[x, y]` added after scroll calculation.
    pub offset: [f32; 2],
    /// Constant autoscroll velocity `[vx, vy]` in pixels per second.
    pub autoscroll: [f32; 2],
    /// Accumulated autoscroll distance since last reset; driven by `update`.
    pub autoscroll_accum: [f32; 2],
    /// Whether to tile the texture horizontally.
    pub repeat_x: bool,
    /// Whether to tile the texture vertically.
    pub repeat_y: bool,
    /// Minimum scroll clamp `[x, y]`; `None` means no minimum.
    pub clamp_min: Option<[f32; 2]>,
    /// Maximum scroll clamp `[x, y]`; `None` means no maximum.
    pub clamp_max: Option<[f32; 2]>,
    /// Integer Z sort key; lower values draw behind higher.
    pub z: i32,
    /// Layer opacity in `[0.0, 1.0]`; multiplied into tint alpha at draw time.
    pub opacity: f32,
    /// RGBA tint multiplier; `[1,1,1,1]` = no tint.
    pub tint: [f32; 4],
    /// Blend mode applied when drawing this layer.
    pub blend_mode: BlendMode,
    /// When `false` the layer is skipped in `build_draw_calls`.
    pub visible: bool,
    /// Per-axis scale `[sx, sy]` applied to the texture size.
    pub scale: [f32; 2],
    /// When `true` forces both `repeat_x` and `repeat_y`.
    pub tiling: bool,
    /// Override tile width; `None` uses `texture_width * scale[0]`.
    pub tile_w: Option<f32>,
    /// Override tile height; `None` uses `texture_height * scale[1]`.
    pub tile_h: Option<f32>,
    /// Depth value passed to the renderer for sorting within a Z layer.
    pub depth: f32,
    /// Optional shader pass chain applied to this layer.
    pub effect_chain: Option<Vec<ShaderPassDescriptor>>,
    /// Whether motion-stretch blur is active for this layer.
    pub motion_stretch_enabled: bool,
    /// Strength of the motion-stretch effect; higher values stretch more per pixel/sec.
    pub motion_stretch_strength: f32,
    /// Maximum scale multiplier applied by motion stretch (clamped to `>= 1.0`).
    pub motion_stretch_max_scale: f32,
}
impl ParallaxLayer {
    /// Create a new layer for `texture_key` with the given texture dimensions and sensible defaults.
    pub fn new(texture_key: TextureKey, texture_width: f32, texture_height: f32) -> Self {
        ParallaxLayer {
            texture_key,
            texture_width,
            texture_height,
            scroll_factor: [1.0, 0.0],
            offset: [0.0, 0.0],
            autoscroll: [0.0, 0.0],
            autoscroll_accum: [0.0, 0.0],
            repeat_x: true,
            repeat_y: false,
            clamp_min: None,
            clamp_max: None,
            z: 0,
            opacity: 1.0,
            tint: [1.0, 1.0, 1.0, 1.0],
            blend_mode: BlendMode::Alpha,
            visible: true,
            scale: [1.0, 1.0],
            tiling: false,
            tile_w: None,
            tile_h: None,
            depth: 0.0,
            effect_chain: None,
            motion_stretch_enabled: false,
            motion_stretch_strength: 0.001,
            motion_stretch_max_scale: 2.0,
        }
    }
    /// Advance the autoscroll accumulator by `dt` seconds and wrap it to one tile width/height.
    pub fn update(&mut self, dt: f32) {
        if !dt.is_finite() || dt <= 0.0 {
            return;
        }
        self.autoscroll_accum[0] += self.autoscroll[0] * dt;
        self.autoscroll_accum[1] += self.autoscroll[1] * dt;
        let (tw, th) = self.resolved_tile_dimensions();
        if tw > 0.0 {
            self.autoscroll_accum[0] = self.autoscroll_accum[0].rem_euclid(tw);
        }
        if th > 0.0 {
            self.autoscroll_accum[1] = self.autoscroll_accum[1].rem_euclid(th);
        }
    }
    /// Return the effective `(tile_w, tile_h)` in pixels after applying scale and `MIN_TILE_SIZE`.
    fn resolved_tile_dimensions(&self) -> (f32, f32) {
        let scale_x = positive_finite_or(self.scale[0], DEFAULT_SCALE);
        let scale_y = positive_finite_or(self.scale[1], DEFAULT_SCALE);
        let base_w = positive_finite_or(self.texture_width, MIN_TILE_SIZE) * scale_x;
        let base_h = positive_finite_or(self.texture_height, MIN_TILE_SIZE) * scale_y;
        let tw = positive_finite_or(self.tile_w.unwrap_or(base_w), base_w).max(MIN_TILE_SIZE);
        let th = positive_finite_or(self.tile_h.unwrap_or(base_h), base_h).max(MIN_TILE_SIZE);
        (tw, th)
    }
    /// Return the pixel offset `(px, py)` for the layer given camera position `(cam_x, cam_y)`.
    fn compute_pixel_offset(&self, cam_x: f32, cam_y: f32) -> (f32, f32) {
        let mut px = cam_x * self.scroll_factor[0] + self.offset[0] + self.autoscroll_accum[0];
        let mut py = cam_y * self.scroll_factor[1] + self.offset[1] + self.autoscroll_accum[1];
        if let (Some(mn), Some(mx)) = (self.clamp_min, self.clamp_max) {
            px = px.clamp(mn[0], mx[0]);
            py = py.clamp(mn[1], mx[1]);
        }
        (px, py)
    }
    /// Build a `ParallaxDrawBatch` for the current camera position; returns `None` when invisible or zero-size.
    pub fn build_draw_calls(
        &self,
        cam_x: f32,
        cam_y: f32,
        screen_w: f32,
        screen_h: f32,
    ) -> Option<ParallaxDrawBatch> {
        if !self.visible || self.opacity <= 0.0 {
            return None;
        }
        let (tex_w, tex_h) = self.resolved_tile_dimensions();
        let repeat_x = self.tiling || self.repeat_x;
        let repeat_y = self.tiling || self.repeat_y;
        if tex_w <= 0.0 || tex_h <= 0.0 {
            return None;
        }
        let (px, py) = self.compute_pixel_offset(cam_x, cam_y);
        let start_x = if repeat_x { -px.rem_euclid(tex_w) } else { -px };
        let start_y = if repeat_y { -py.rem_euclid(tex_h) } else { -py };
        let tiles = crate::parallax::tile_iter::collect_tiled_positions(
            start_x,
            start_y,
            tex_w,
            tex_h,
            repeat_x,
            repeat_y,
            [screen_w, screen_h],
        );
        let [tr, tg, tb, ta] = self.tint;
        let color = [tr, tg, tb, ta * self.opacity];
        let mut sx = if self.texture_width > 0.0 {
            tex_w / self.texture_width
        } else {
            positive_finite_or(self.scale[0], DEFAULT_SCALE)
        };
        let mut sy = if self.texture_height > 0.0 {
            tex_h / self.texture_height
        } else {
            positive_finite_or(self.scale[1], DEFAULT_SCALE)
        };
        let mut effect = self.effect_chain.clone();
        if self.motion_stretch_enabled {
            let speed_x = self.autoscroll[0].abs();
            let speed_y = self.autoscroll[1].abs();
            let max_extra = (self.motion_stretch_max_scale - 1.0).max(0.0);
            let sx_extra = (speed_x * self.motion_stretch_strength).min(max_extra);
            let sy_extra = (speed_y * self.motion_stretch_strength).min(max_extra);
            sx *= 1.0 + sx_extra;
            sy *= 1.0 + sy_extra;
            let speed = (speed_x * speed_x + speed_y * speed_y).sqrt();
            if speed > 1.0 {
                let mut params = HashMap::new();
                params.insert("strength".to_string(), (speed * 0.001).clamp(0.0, 1.0));
                params.insert(
                    "direction_x".to_string(),
                    if speed > 0.0 {
                        self.autoscroll[0] / speed
                    } else {
                        0.0
                    },
                );
                params.insert(
                    "direction_y".to_string(),
                    if speed > 0.0 {
                        self.autoscroll[1] / speed
                    } else {
                        0.0
                    },
                );
                let mut chain = effect.unwrap_or_default();
                chain.push(ShaderPassDescriptor {
                    effect_name: "motion_blur".to_string(),
                    params,
                    enabled: true,
                });
                effect = Some(chain);
            }
        }
        Some(ParallaxDrawBatch {
            texture_key: self.texture_key,
            tiles,
            sx,
            sy,
            color,
            blend_mode: self.blend_mode,
            effect,
        })
    }
    /// Returns telemetry for the current camera position and viewport size.
    pub fn stats_for_view(
        &self,
        cam_x: f32,
        cam_y: f32,
        screen_w: f32,
        screen_h: f32,
    ) -> ParallaxLayerStats {
        let (tile_width, tile_height) = self.resolved_tile_dimensions();
        let autoscroll_speed =
            (self.autoscroll[0] * self.autoscroll[0] + self.autoscroll[1] * self.autoscroll[1])
                .sqrt();
        if let Some(batch) = self.build_draw_calls(cam_x, cam_y, screen_w, screen_h) {
            return ParallaxLayerStats {
                visible_tile_count: batch.tiles.len(),
                tile_width,
                tile_height,
                draw_scale_x: batch.sx,
                draw_scale_y: batch.sy,
                effect_pass_count: batch.effect.as_ref().map_or(0, Vec::len),
                z: self.z,
                depth: self.depth,
                visible: self.visible,
                motion_stretch_enabled: self.motion_stretch_enabled,
                autoscroll_speed,
            };
        }
        ParallaxLayerStats {
            visible_tile_count: 0,
            tile_width,
            tile_height,
            draw_scale_x: finite_or(self.scale[0], DEFAULT_SCALE),
            draw_scale_y: finite_or(self.scale[1], DEFAULT_SCALE),
            effect_pass_count: self.effect_count(),
            z: self.z,
            depth: self.depth,
            visible: self.visible,
            motion_stretch_enabled: self.motion_stretch_enabled,
            autoscroll_speed,
        }
    }
    /// Reset the autoscroll accumulator to `[0.0, 0.0]`.
    pub fn reset_autoscroll(&mut self) {
        self.autoscroll_accum = [0.0, 0.0];
    }
    /// Set whether tiling mode (forces repeat on both axes) is active.
    pub fn set_tiling(&mut self, enabled: bool) {
        self.tiling = enabled;
    }
    /// Return `true` when tiling mode is active.
    pub fn get_tiling(&self) -> bool {
        self.tiling
    }
    /// Override tile size to `(w, h)` pixels; `0.0` or negative resets to texture-derived size.
    pub fn set_tile_size(&mut self, w: f32, h: f32) {
        self.tile_w = if w.is_finite() && w > 0.0 {
            Some(w.max(MIN_TILE_SIZE))
        } else {
            None
        };
        self.tile_h = if h.is_finite() && h > 0.0 {
            Some(h.max(MIN_TILE_SIZE))
        } else {
            None
        };
    }
    /// Sets movement clamp bounds and normalizes min/max ordering per axis.
    pub fn set_clamp_bounds(&mut self, min: [f32; 2], max: [f32; 2]) {
        self.clamp_min = Some([min[0].min(max[0]), min[1].min(max[1])]);
        self.clamp_max = Some([min[0].max(max[0]), min[1].max(max[1])]);
    }
    /// Set the depth sort value for this layer.
    pub fn set_depth(&mut self, z: f32) {
        self.depth = finite_or(z, 0.0);
    }
    /// Return the current depth sort value.
    pub fn get_depth(&self) -> f32 {
        self.depth
    }
    /// Replace the shader effect chain; an empty `chain` clears the existing chain.
    pub fn set_effect_chain(&mut self, chain: Vec<ShaderPassDescriptor>) {
        self.effect_chain = if chain.is_empty() { None } else { Some(chain) };
    }
    /// Remove all shader effects from this layer.
    pub fn clear_effect_chain(&mut self) {
        self.effect_chain = None;
    }
    /// Return the number of shader passes currently in the effect chain.
    pub fn effect_count(&self) -> usize {
        self.effect_chain.as_ref().map_or(0, Vec::len)
    }
    /// Configure motion-stretch blur; `strength` controls pixels-per-sec sensitivity, `max_scale` caps the scale boost.
    pub fn set_motion_stretch(&mut self, enabled: bool, strength: f32, max_scale: f32) {
        self.motion_stretch_enabled = enabled;
        self.motion_stretch_strength = finite_or(strength, 0.0).max(0.0);
        self.motion_stretch_max_scale = positive_finite_or(max_scale, 1.0).max(1.0);
    }
}
