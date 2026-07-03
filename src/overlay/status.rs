//! Owns the overlay status implementation for the overlay subsystem and keeps related runtime rules local here.
//! Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
//! Defines how overlay status data is validated, transformed, or stored before neighboring systems consume it.
//! Separates overlay status behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing overlay status defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the overlay status state that explains them instead of spreading rules outward.

use crate::runtime::resource_keys::TextureKey;

/// Public designer-facing maximum intensity value accepted by status helpers.
pub const STATUS_INTENSITY_MAX: f32 = 10.0;

/// Normalizes public status intensity input into the internal `0.0..=1.0` range.
pub fn normalize_status_intensity(value: f32) -> f32 {
    if !value.is_finite() {
        return 0.0;
    }
    if value <= 1.0 {
        value.clamp(0.0, 1.0)
    } else {
        (value / STATUS_INTENSITY_MAX).clamp(0.0, 1.0)
    }
}

fn smoothstep01(value: f32) -> f32 {
    let t = value.clamp(0.0, 1.0);
    t * t * (3.0 - 2.0 * t)
}

fn canonical_layer_id(id: &str) -> String {
    id.trim().to_ascii_lowercase()
}

/// Declares where a status layer conceptually belongs in the frame.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum StatusLayerTarget {
    /// Draw after the world but before HUD widgets.
    SceneOnly,
    /// Draw immediately before HUD widgets.
    HudBack,
    /// Draw immediately after HUD widgets.
    #[default]
    HudFront,
    /// Draw above the whole scene and HUD, below debug tooling.
    FullScreenTop,
}

/// Declares how a status layer should blend relative to sibling status layers.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum StatusCompositeMode {
    /// Standard alpha compositing.
    #[default]
    AlphaBlend,
    /// Add source energy over the destination.
    Additive,
    /// Add source energy and clamp to the visible range.
    AdditiveClamp,
}

/// Visual recipe metadata owned by one status layer.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct StatusVisualRecipe {
    /// Optional full-screen color wash.
    pub color: Option<[f32; 4]>,
    /// Optional fullscreen texture overlay.
    pub texture_key: Option<TextureKey>,
    /// Optional source texture size for fullscreen scaling.
    pub texture_size: Option<(u32, u32)>,
    /// Base opacity multiplier for the texture layer.
    pub texture_opacity: f32,
    /// Optional built-in post-fx effect name.
    pub shader_effect: Option<String>,
    /// Base post-fx parameter multiplier.
    pub shader_strength: f32,
}

/// One authored status layer inside the overlay-owned stack.
#[derive(Debug, Clone, PartialEq)]
pub struct StatusOverlayLayer {
    /// Stable caller-visible layer id.
    pub id: String,
    /// Gameplay-facing kind name, such as `frozen` or `poison`.
    pub kind: String,
    /// Enables or disables layer playback.
    pub enabled: bool,
    /// Current normalized intensity in `0.0..=1.0`.
    pub intensity_01: f32,
    /// Target normalized intensity in `0.0..=1.0`.
    pub target_intensity_01: f32,
    /// Seconds required to ramp up from zero to target.
    pub fade_in: f32,
    /// Seconds required to ramp down toward zero.
    pub fade_out: f32,
    /// Optional automatic lifetime in seconds before fade-out starts.
    pub duration: Option<f32>,
    /// Seconds elapsed since activation.
    pub elapsed: f32,
    /// Draw-order priority within the status stack.
    pub priority: i32,
    /// Conceptual frame target for the status layer.
    pub target: StatusLayerTarget,
    /// Declared blending mode used for diagnostics and future renderer routing.
    pub composite: StatusCompositeMode,
    /// Direct texture/color/post-fx recipe data.
    pub visual: StatusVisualRecipe,
}

impl StatusOverlayLayer {
    /// Creates one disabled status layer with stable defaults and canonical ids.
    pub fn new(id: impl Into<String>, kind: impl Into<String>) -> Self {
        Self {
            id: canonical_layer_id(&id.into()),
            kind: canonical_layer_id(&kind.into()),
            enabled: true,
            intensity_01: 0.0,
            target_intensity_01: 0.0,
            fade_in: 0.2,
            fade_out: 0.35,
            duration: None,
            elapsed: 0.0,
            priority: 0,
            target: StatusLayerTarget::default(),
            composite: StatusCompositeMode::default(),
            visual: StatusVisualRecipe {
                texture_opacity: 1.0,
                shader_strength: 1.0,
                ..StatusVisualRecipe::default()
            },
        }
    }

    fn normalized_fade(value: f32, default: f32) -> f32 {
        if value.is_finite() && value > 0.0 {
            value
        } else {
            default
        }
    }

    /// Sets the target intensity from either normalized or designer-facing input.
    pub fn set_intensity_public(&mut self, value: f32) {
        self.target_intensity_01 = normalize_status_intensity(value);
        if self.target_intensity_01 > 0.0 {
            self.enabled = true;
            self.elapsed = 0.0;
        }
    }

    /// Starts a fade-out toward zero, optionally replacing the fade-out duration.
    pub fn start_fade_out(&mut self, fade_out: Option<f32>) {
        if let Some(value) = fade_out {
            self.fade_out = Self::normalized_fade(value, self.fade_out);
        }
        self.target_intensity_01 = 0.0;
    }

    /// Advances this layer by `dt` seconds and applies fade timing toward the target intensity.
    pub fn update(&mut self, dt: f32) {
        if !dt.is_finite() || dt <= 0.0 {
            return;
        }
        self.fade_in = Self::normalized_fade(self.fade_in, 0.2);
        self.fade_out = Self::normalized_fade(self.fade_out, 0.35);
        self.texture_opacity_sanitized();
        self.shader_strength_sanitized();
        if !self.enabled && self.intensity_01 <= 0.0 && self.target_intensity_01 <= 0.0 {
            return;
        }
        self.elapsed += dt;
        if let Some(duration) = self.duration {
            if duration.is_finite() && duration >= 0.0 && self.elapsed >= duration {
                self.target_intensity_01 = 0.0;
            }
        }
        let target = self.target_intensity_01.clamp(0.0, 1.0);
        let current = self.intensity_01.clamp(0.0, 1.0);
        if (current - target).abs() <= f32::EPSILON {
            self.intensity_01 = target;
            self.enabled = target > 0.0;
            return;
        }
        let fade = if target > current {
            self.fade_in
        } else {
            self.fade_out
        };
        let step = if fade <= 1.0e-4 {
            1.0
        } else {
            (dt / fade).clamp(0.0, 1.0)
        };
        self.intensity_01 = current + (target - current) * step;
        if self.intensity_01 <= 1.0e-4 && target <= 0.0 {
            self.intensity_01 = 0.0;
            self.enabled = false;
        } else {
            self.enabled = true;
        }
    }

    /// Returns whether this layer still contributes visible or pending work.
    pub fn is_live(&self) -> bool {
        self.enabled || self.intensity_01 > 0.0 || self.target_intensity_01 > 0.0
    }

    /// Returns whether this layer should emit any direct or post-fx work this frame.
    pub fn is_active(&self) -> bool {
        self.intensity_01 > 0.0
    }

    /// Returns the intensity-mapped color alpha contribution.
    pub fn color_alpha(&self) -> f32 {
        let Some(color) = self.visual.color else {
            return 0.0;
        };
        let opacity = smoothstep01(self.intensity_01) * color[3].clamp(0.0, 1.0);
        opacity.clamp(0.0, 1.0)
    }

    /// Returns the intensity-mapped texture opacity contribution.
    pub fn texture_alpha(&self) -> f32 {
        if self.visual.texture_key.is_none() {
            return 0.0;
        }
        let opacity = smoothstep01(self.intensity_01) * self.visual.texture_opacity.clamp(0.0, 1.0);
        opacity.clamp(0.0, 1.0)
    }

    /// Returns the intensity-mapped post-fx parameter strength contribution.
    pub fn shader_amount(&self) -> f32 {
        if self.visual.shader_effect.is_none() {
            return 0.0;
        }
        let intensity = self.intensity_01.clamp(0.0, 1.0);
        let curved = intensity * intensity;
        (curved * self.visual.shader_strength.max(0.0)).clamp(0.0, 8.0)
    }

    fn texture_opacity_sanitized(&mut self) {
        if !self.visual.texture_opacity.is_finite() {
            self.visual.texture_opacity = 1.0;
        } else {
            self.visual.texture_opacity = self.visual.texture_opacity.clamp(0.0, 1.0);
        }
    }

    fn shader_strength_sanitized(&mut self) {
        if !self.visual.shader_strength.is_finite() {
            self.visual.shader_strength = 1.0;
        } else {
            self.visual.shader_strength = self.visual.shader_strength.max(0.0);
        }
    }
}

/// Overlay-owned stack of independently faded status layers.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct StatusOverlayStack {
    /// Stored layers in authored insertion order.
    pub layers: Vec<StatusOverlayLayer>,
}

impl StatusOverlayStack {
    /// Returns one layer by id using canonical case-insensitive matching.
    pub fn layer(&self, id: &str) -> Option<&StatusOverlayLayer> {
        let id = canonical_layer_id(id);
        self.layers.iter().find(|layer| layer.id == id)
    }

    /// Returns one mutable layer by id using canonical case-insensitive matching.
    pub fn layer_mut(&mut self, id: &str) -> Option<&mut StatusOverlayLayer> {
        let id = canonical_layer_id(id);
        self.layers.iter_mut().find(|layer| layer.id == id)
    }

    /// Inserts or replaces one authored layer by stable id.
    pub fn upsert(&mut self, layer: StatusOverlayLayer) {
        if let Some(slot) = self.layer_mut(&layer.id) {
            *slot = layer;
        } else {
            self.layers.push(layer);
        }
    }

    /// Starts fading out one layer, returning whether it existed.
    pub fn clear_layer(&mut self, id: &str, fade_out: Option<f32>) -> bool {
        let Some(layer) = self.layer_mut(id) else {
            return false;
        };
        layer.start_fade_out(fade_out);
        true
    }

    /// Advances all layers and prunes fully inactive entries.
    pub fn update(&mut self, dt: f32) {
        for layer in &mut self.layers {
            layer.update(dt);
        }
        self.layers.retain(StatusOverlayLayer::is_live);
    }

    /// Returns active layers sorted from back to front.
    pub fn active_layers_sorted(&self) -> Vec<&StatusOverlayLayer> {
        let mut layers: Vec<&StatusOverlayLayer> = self
            .layers
            .iter()
            .filter(|layer| layer.is_active())
            .collect();
        layers.sort_by(|left, right| {
            left.priority
                .cmp(&right.priority)
                .then_with(|| left.id.cmp(&right.id))
        });
        layers
    }
}
