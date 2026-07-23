//! This file owns `Light2D` and its patch structs, the complete per-light data model used by the lighting system.
//! It stores transform, radius, color, energy, attenuation, masks, shadows, type, flicker, grouping, and normal-map data.
//! Constructor defaults create a ready point light, while many getters and setters expose stable field-level control.
//! `Light2DOptionsPatch` and `Light2DAttenuationPatch` let callers update selected options without rebuilding a light.
//! Spot angles, shadow settings, volumetrics, blend mode, falloff, and attenuation all live in this one ownership unit.
//! Debug rendering for falloff comparisons also lives here because it depends on the same light-specific option semantics.
//! This file is the boundary for one light's authored and runtime state, not for scene collection orchestration.
//! Open it when per-light option semantics change; world storage and occluder ownership live in sibling files.

use crate::color::Color;
use crate::light::attenuation::Attenuation;
use crate::light::blend_mode::LightBlendMode;
use crate::light::falloff::FalloffMode;
use crate::light::flicker::FlickerConfig;
use crate::light::light_type::LightType;
use crate::light::shadow::ShadowFilter;
use crate::light::transition::LightTransition;
use crate::log_msg;
use crate::runtime::log_messages::{LT01, LT02, LT03};
use crate::runtime::resource_keys::ShaderKey;

/// Optional attenuation coefficient updates for a light option patch.
/// # Fields
#[derive(Clone, Copy, Debug, Default)]
pub struct Light2DAttenuationPatch {
    /// Constant attenuation term.
    pub constant: Option<f32>,
    /// Linear attenuation term.
    pub linear: Option<f32>,
    /// Quadratic attenuation term.
    pub quadratic: Option<f32>,
}

/// Optional field updates applied to an existing `Light2D`.
/// # Fields
#[derive(Clone, Debug, Default)]
pub struct Light2DOptionsPatch {
    /// RGBA tint color applied to the light contribution.
    pub color: Option<Color>,
    /// Intensity multiplier applied on top of energy.
    pub intensity: Option<f32>,
    /// Energy scale combined with intensity.
    pub energy: Option<f32>,
    /// Blend mode for light compositing.
    pub blend_mode: Option<LightBlendMode>,
    /// Radial falloff curve shape.
    pub falloff: Option<FalloffMode>,
    /// Whether the light is active.
    pub enabled: Option<bool>,
    /// Whether shadow casting is enabled.
    pub shadow_enabled: Option<bool>,
    /// Color used to tint shadowed regions.
    pub shadow_color: Option<Color>,
    /// Shadow filter quality preset.
    pub shadow_filter: Option<ShadowFilter>,
    /// Smooth factor for shadow edge blending.
    pub shadow_smooth: Option<f32>,
    /// Overall shadow softness scale.
    pub shadow_softness: Option<f32>,
    /// Bitmask selecting illuminated geometry layers.
    pub light_mask: Option<u16>,
    /// Bitmask selecting shadow-casting geometry layers.
    pub shadow_mask: Option<u16>,
    /// Discriminant between point, spot, and area variants.
    pub light_type: Option<LightType>,
    /// Direction angle in radians for spot lights.
    pub direction: Option<f32>,
    /// Inner cone half-angle in radians.
    pub inner_angle: Option<f32>,
    /// Outer cone half-angle in radians.
    pub outer_angle: Option<f32>,
    /// Optional group id used to batch lights.
    pub group_id: Option<u16>,
    /// Whether volumetric scattering is enabled.
    pub volumetric: Option<bool>,
    /// Sine-wave flicker speed.
    pub flicker_speed: Option<f32>,
    /// Sine-wave flicker strength.
    pub flicker_strength: Option<f32>,
    /// Normal map texture path.
    pub normal_map_path: Option<String>,
    /// Normal map contribution strength.
    pub normal_strength: Option<f32>,
    /// Partial attenuation coefficient updates.
    pub attenuation: Light2DAttenuationPatch,
}

/// Complete 2D light definition: position, color, radius, type, shadow, masks, flicker, and attenuation.
/// # Fields
pub struct Light2D {
    /// World-space X position of the light source.
    pub x: f32,
    /// World-space Y position of the light source.
    pub y: f32,
    /// Effective light radius in world units.
    pub radius: f32,
    /// RGBA tint color applied to the light contribution.
    pub color: Color,
    /// Intensity multiplier applied on top of energy; range [0.0, ∞).
    pub intensity: f32,
    /// Whether the light is active; when false, `LightWorld` skips it entirely.
    pub enabled: bool,
    /// Energy scale; combined with `intensity` to yield final brightness.
    pub energy: f32,
    /// Blend mode for how this light composites into the accumulation buffer.
    pub blend_mode: LightBlendMode,
    /// Radial falloff curve shape beyond the attenuation response.
    pub falloff: FalloffMode,
    /// Whether shadow casting is enabled for this light.
    pub shadow_enabled: bool,
    /// Color used to tint shadowed regions.
    pub shadow_color: Color,
    /// Shadow filter quality preset.
    pub shadow_filter: ShadowFilter,
    /// Smooth factor for shadow edge blending; higher = softer edge.
    pub shadow_smooth: f32,
    /// Overall shadow softness scale applied to the filter kernel.
    pub shadow_softness: f32,
    /// Bitmask selecting which geometry layers this light illuminates.
    pub light_mask: u16,
    /// Bitmask selecting which geometry layers cast shadows for this light.
    pub shadow_mask: u16,
    /// Discriminant between point, spot, and area variants.
    pub light_type: LightType,
    /// Direction angle in radians for spot lights; 0 = right.
    pub direction: f32,
    /// Inner cone half-angle in radians for spot lights; full brightness inside.
    pub inner_angle: f32,
    /// Outer cone half-angle in radians for spot lights; falls to zero at outer edge.
    pub outer_angle: f32,
    /// Quadratic attenuation coefficients controlling distance-based decay.
    pub attenuation: Attenuation,
    /// Sine-wave flicker config for animated intensity variation.
    pub flicker: FlickerConfig,
    /// Optional group id used to batch lights in `LightWorld`.
    pub group_id: u16,
    /// Renderer selection priority; higher values win before stable insertion-order ties.
    pub priority: i16,
    /// Whether volumetric scattering should be simulated for this light.
    pub volumetric: bool,
    /// Optional path to a normal map texture used for surface-lighting.
    pub normal_map_path: Option<String>,
    /// Optional validated cookie resource reference. Rendering support is renderer-owned.
    pub cookie_path: Option<String>,
    /// Optional authoritative transition state shared by every handle for this light.
    pub transition: Option<LightTransition>,
    /// Monotonic scene insertion sequence assigned by `LightWorld` for stable renderer selection.
    pub(crate) insertion_order: u64,
    /// Scale applied to the normal map contribution; range [0.0, 1.0].
    pub normal_strength: f32,
    /// Optional custom light-contribution shader.
    pub shader: Option<ShaderKey>,
}
impl Light2D {
    /// Create a point light at `(x, y)` with `radius`; all other fields default.
    pub fn new(x: f32, y: f32, radius: f32) -> Self {
        log_msg!(debug, LT01, "({}, {}) r={}", x, y, radius);
        Self {
            x,
            y,
            radius,
            color: Color::WHITE,
            intensity: 1.0,
            enabled: true,
            energy: 1.0,
            blend_mode: LightBlendMode::default(),
            falloff: FalloffMode::default(),
            shadow_enabled: false,
            shadow_color: Color::BLACK,
            shadow_filter: ShadowFilter::default(),
            shadow_smooth: 1.0,
            shadow_softness: 1.0,
            light_mask: 0xFFFF,
            shadow_mask: 0xFFFF,
            light_type: LightType::default(),
            direction: 0.0,
            inner_angle: std::f32::consts::FRAC_PI_6,
            outer_angle: std::f32::consts::FRAC_PI_4,
            attenuation: Attenuation::default(),
            flicker: FlickerConfig::default(),
            group_id: 0,
            priority: 0,
            volumetric: false,
            normal_map_path: None,
            cookie_path: None,
            transition: None,
            insertion_order: 0,
            normal_strength: 1.0,
            shader: None,
        }
    }
    /// Return whether every numeric value consumed by preview or GPU rendering is finite and valid.
    ///
    /// Lua validation normally guarantees this. The predicate also protects rendering against
    /// direct Rust field mutation after a light has entered a `LightWorld`.
    pub fn is_render_valid(&self) -> bool {
        let color_is_finite = |color: Color| {
            color.r.is_finite() && color.g.is_finite() && color.b.is_finite() && color.a.is_finite()
        };
        let attenuation_is_valid = self.attenuation.constant.is_finite()
            && self.attenuation.linear.is_finite()
            && self.attenuation.quadratic.is_finite()
            && self.attenuation.constant >= 0.0
            && self.attenuation.linear >= 0.0
            && self.attenuation.quadratic >= 0.0;
        let flicker_is_valid = self.flicker.speed.is_finite()
            && self.flicker.strength.is_finite()
            && self.flicker.phase.is_finite()
            && self.flicker.strength >= 0.0;
        let transition_is_valid = match &self.transition {
            None => true,
            Some(transition) => {
                transition.from_color.iter().all(|value| value.is_finite())
                    && transition.to_color.iter().all(|value| value.is_finite())
                    && transition.from_intensity.is_finite()
                    && transition.to_intensity.is_finite()
                    && transition.from_intensity >= 0.0
                    && transition.to_intensity >= 0.0
                    && transition.from_radius.is_finite()
                    && transition.to_radius.is_finite()
                    && transition.from_radius > 0.0
                    && transition.to_radius > 0.0
                    && transition.duration.is_finite()
                    && transition.duration > 0.0
                    && transition.elapsed.is_finite()
            }
        };
        self.x.is_finite()
            && self.y.is_finite()
            && self.radius.is_finite()
            && self.radius > 0.0
            && color_is_finite(self.color)
            && self.intensity.is_finite()
            && self.intensity >= 0.0
            && self.energy.is_finite()
            && self.energy >= 0.0
            && color_is_finite(self.shadow_color)
            && self.shadow_smooth.is_finite()
            && self.shadow_smooth >= 0.0
            && self.shadow_softness.is_finite()
            && self.shadow_softness >= 0.0
            && self.direction.is_finite()
            && self.inner_angle.is_finite()
            && self.outer_angle.is_finite()
            && self.inner_angle >= 0.0
            && self.inner_angle <= self.outer_angle
            && self.outer_angle <= std::f32::consts::PI
            && attenuation_is_valid
            && flicker_is_valid
            && self.normal_strength.is_finite()
            && (0.0..=1.0).contains(&self.normal_strength)
            && transition_is_valid
    }
    /// Set this light's renderer selection priority.
    pub fn set_priority(&mut self, priority: i16) {
        self.priority = priority;
    }
    /// Return this light's renderer selection priority.
    pub fn get_priority(&self) -> i16 {
        self.priority
    }
    /// Set world-space position and log at trace level.
    pub fn set_position(&mut self, x: f32, y: f32) {
        log_msg!(trace, LT02, "({}, {})", x, y);
        self.x = x;
        self.y = y;
    }
    /// Return world-space `(x, y)` position.
    pub fn get_position(&self) -> (f32, f32) {
        (self.x, self.y)
    }
    /// Set the light radius and log at trace level.
    pub fn set_radius(&mut self, radius: f32) {
        log_msg!(trace, LT03, "{}", radius);
        self.radius = radius;
    }
    /// Return the current light radius.
    pub fn get_radius(&self) -> f32 {
        self.radius
    }
    /// Set the RGBA tint color. This function is part of the public API.
    pub fn set_color(&mut self, color: Color) {
        self.color = color;
    }
    /// Return the RGBA tint color. This function is part of the public API.
    pub fn get_color(&self) -> Color {
        self.color
    }
    /// Set the intensity multiplier.
    pub fn set_intensity(&mut self, intensity: f32) {
        self.intensity = intensity;
    }
    /// Return the intensity multiplier.
    pub fn get_intensity(&self) -> f32 {
        self.intensity
    }
    /// Enable or disable this light.
    pub fn set_enabled(&mut self, enabled: bool) {
        self.enabled = enabled;
    }
    /// Return whether the light is enabled.
    pub fn is_enabled(&self) -> bool {
        self.enabled
    }
    /// Set the energy scale. This function is part of the public API.
    pub fn set_energy(&mut self, energy: f32) {
        self.energy = energy;
    }
    /// Return the energy scale. This function is part of the public API.
    pub fn get_energy(&self) -> f32 {
        self.energy
    }
    /// Set the accumulation blend mode.
    pub fn set_blend_mode(&mut self, mode: LightBlendMode) {
        self.blend_mode = mode;
    }
    /// Return the accumulation blend mode.
    pub fn get_blend_mode(&self) -> LightBlendMode {
        self.blend_mode
    }
    /// Set the radial falloff curve.
    pub fn set_falloff(&mut self, mode: FalloffMode) {
        self.falloff = mode;
    }
    /// Return the radial falloff curve.
    pub fn get_falloff(&self) -> FalloffMode {
        self.falloff
    }
    /// Enable or disable shadow casting.
    pub fn set_shadow_enabled(&mut self, enabled: bool) {
        self.shadow_enabled = enabled;
    }
    /// Return whether shadow casting is enabled.
    pub fn is_shadow_enabled(&self) -> bool {
        self.shadow_enabled
    }
    /// Set the shadow tint color. This function is part of the public API.
    pub fn set_shadow_color(&mut self, color: Color) {
        self.shadow_color = color;
    }
    /// Return the shadow tint color.
    pub fn get_shadow_color(&self) -> Color {
        self.shadow_color
    }
    /// Set the shadow filter quality preset.
    pub fn set_shadow_filter(&mut self, filter: ShadowFilter) {
        self.shadow_filter = filter;
    }
    /// Return the shadow filter quality preset.
    pub fn get_shadow_filter(&self) -> ShadowFilter {
        self.shadow_filter
    }
    /// Set the shadow edge smooth factor.
    pub fn set_shadow_smooth(&mut self, smooth: f32) {
        self.shadow_smooth = smooth;
    }
    /// Return the shadow edge smooth factor.
    pub fn get_shadow_smooth(&self) -> f32 {
        self.shadow_smooth
    }
    /// Set the overall shadow softness scale.
    pub fn set_shadow_softness(&mut self, softness: f32) {
        self.shadow_softness = softness;
    }
    /// Return the overall shadow softness scale.
    pub fn get_shadow_softness(&self) -> f32 {
        self.shadow_softness
    }
    /// Set the layer bitmask for which geometry this light illuminates.
    pub fn set_light_mask(&mut self, mask: u16) {
        self.light_mask = mask;
    }
    /// Return the illumination layer bitmask.
    pub fn get_light_mask(&self) -> u16 {
        self.light_mask
    }
    /// Set the layer bitmask for which geometry casts shadows.
    pub fn set_shadow_mask(&mut self, mask: u16) {
        self.shadow_mask = mask;
    }
    /// Return the shadow caster layer bitmask.
    pub fn get_shadow_mask(&self) -> u16 {
        self.shadow_mask
    }
    /// Set the light type discriminant.
    pub fn set_light_type(&mut self, light_type: LightType) {
        self.light_type = light_type;
    }
    /// Return the light type discriminant.
    pub fn get_light_type(&self) -> LightType {
        self.light_type
    }
    /// Set the spot-light direction angle in radians.
    pub fn set_direction(&mut self, direction: f32) {
        self.direction = direction;
    }
    /// Return the spot-light direction angle in radians.
    pub fn get_direction(&self) -> f32 {
        self.direction
    }
    /// Set the inner cone half-angle in radians for spot lights.
    pub fn set_inner_angle(&mut self, angle: f32) {
        self.inner_angle = angle;
    }
    /// Return the inner cone half-angle in radians.
    pub fn get_inner_angle(&self) -> f32 {
        self.inner_angle
    }
    /// Set the outer cone half-angle in radians for spot lights.
    pub fn set_outer_angle(&mut self, angle: f32) {
        self.outer_angle = angle;
    }
    /// Return the outer cone half-angle in radians.
    pub fn get_outer_angle(&self) -> f32 {
        self.outer_angle
    }
    /// Set the quadratic attenuation coefficients.
    pub fn set_attenuation(&mut self, attenuation: Attenuation) {
        self.attenuation = attenuation;
    }
    /// Return the quadratic attenuation coefficients.
    pub fn get_attenuation(&self) -> Attenuation {
        self.attenuation
    }
    /// Return a mutable reference to the flicker config.
    pub fn flicker_mut(&mut self) -> &mut FlickerConfig {
        &mut self.flicker
    }
    /// Return a shared reference to the flicker config.
    pub fn flicker(&self) -> &FlickerConfig {
        &self.flicker
    }
    /// Set the group id for light batching.
    pub fn set_group_id(&mut self, group_id: u16) {
        self.group_id = group_id;
    }
    /// Return the group id. This function is part of the public API.
    pub fn get_group_id(&self) -> u16 {
        self.group_id
    }
    /// Enable or disable volumetric scattering.
    pub fn set_volumetric(&mut self, volumetric: bool) {
        self.volumetric = volumetric;
    }
    /// Return whether volumetric scattering is enabled.
    pub fn is_volumetric(&self) -> bool {
        self.volumetric
    }
    /// Set the normal map texture path, replacing any previous value.
    pub fn set_normal_map_path(&mut self, path: String) {
        self.normal_map_path = Some(path);
    }
    /// Clear the normal map texture path.
    pub fn clear_normal_map_path(&mut self) {
        self.normal_map_path = None;
    }
    /// Return the normal map texture path if set.
    pub fn get_normal_map_path(&self) -> Option<&str> {
        self.normal_map_path.as_deref()
    }
    /// Set the renderer-resolved cookie resource reference.
    pub fn set_cookie_path(&mut self, path: String) {
        self.cookie_path = Some(path);
    }
    /// Clear the renderer-resolved cookie resource reference.
    pub fn clear_cookie_path(&mut self) {
        self.cookie_path = None;
    }
    /// Return the cookie resource reference, if configured.
    pub fn get_cookie_path(&self) -> Option<&str> {
        self.cookie_path.as_deref()
    }
    /// Start an authoritative transition from this light's current state.
    pub fn start_transition(
        &mut self,
        to_color: [f32; 4],
        to_intensity: f32,
        to_radius: f32,
        duration: f32,
    ) {
        self.transition = Some(LightTransition::new(
            [self.color.r, self.color.g, self.color.b, self.color.a],
            to_color,
            self.intensity,
            to_intensity,
            self.radius,
            to_radius,
            duration,
        ));
    }
    /// Advance the authoritative transition and return whether it applied a new value.
    pub fn advance_transition(&mut self, dt: f32) -> bool {
        let Some((color, intensity, radius)) =
            self.transition.as_mut().and_then(|value| value.update(dt))
        else {
            return false;
        };
        self.color = Color::new(color[0], color[1], color[2], color[3]);
        self.intensity = intensity;
        self.radius = radius;
        true
    }
    /// Clear the authoritative transition.
    pub fn clear_transition(&mut self) {
        self.transition = None;
    }
    /// Return transition progress, or 1.0 when no transition is active.
    pub fn transition_progress(&self) -> f32 {
        self.transition
            .as_ref()
            .map_or(1.0, LightTransition::progress)
    }
    /// Set the normal map contribution strength; range [0.0, 1.0].
    pub fn set_normal_strength(&mut self, strength: f32) {
        self.normal_strength = strength;
    }
    /// Return the normal map contribution strength.
    pub fn get_normal_strength(&self) -> f32 {
        self.normal_strength
    }

    /// Apply optional light field updates without changing omitted properties.
    pub fn apply_options_patch(&mut self, patch: Light2DOptionsPatch) {
        if let Some(color) = patch.color {
            self.set_color(color);
        }
        if let Some(intensity) = patch.intensity {
            self.set_intensity(intensity);
        }
        if let Some(energy) = patch.energy {
            self.set_energy(energy);
        }
        if let Some(blend_mode) = patch.blend_mode {
            self.set_blend_mode(blend_mode);
        }
        if let Some(falloff) = patch.falloff {
            self.set_falloff(falloff);
        }
        if let Some(enabled) = patch.enabled {
            self.set_enabled(enabled);
        }
        if let Some(shadow_enabled) = patch.shadow_enabled {
            self.set_shadow_enabled(shadow_enabled);
        }
        if let Some(shadow_color) = patch.shadow_color {
            self.set_shadow_color(shadow_color);
        }
        if let Some(shadow_filter) = patch.shadow_filter {
            self.set_shadow_filter(shadow_filter);
        }
        if let Some(shadow_smooth) = patch.shadow_smooth {
            self.set_shadow_smooth(shadow_smooth);
        }
        if let Some(shadow_softness) = patch.shadow_softness {
            self.set_shadow_softness(shadow_softness);
        }
        if let Some(light_mask) = patch.light_mask {
            self.set_light_mask(light_mask);
        }
        if let Some(shadow_mask) = patch.shadow_mask {
            self.set_shadow_mask(shadow_mask);
        }
        if let Some(light_type) = patch.light_type {
            self.set_light_type(light_type);
        }
        if let Some(direction) = patch.direction {
            self.set_direction(direction);
        }
        if let Some(inner_angle) = patch.inner_angle {
            self.set_inner_angle(inner_angle);
        }
        if let Some(outer_angle) = patch.outer_angle {
            self.set_outer_angle(outer_angle);
        }
        if let Some(group_id) = patch.group_id {
            self.set_group_id(group_id);
        }
        if let Some(volumetric) = patch.volumetric {
            self.set_volumetric(volumetric);
        }
        if let Some(speed) = patch.flicker_speed {
            self.flicker.speed = speed;
            self.flicker.enabled = true;
        }
        if let Some(strength) = patch.flicker_strength {
            self.flicker.strength = strength;
            self.flicker.enabled = true;
        }
        if let Some(path) = patch.normal_map_path {
            self.set_normal_map_path(path);
        }
        if let Some(strength) = patch.normal_strength {
            self.set_normal_strength(strength);
        }

        let attenuation = patch.attenuation;
        if attenuation.constant.is_some()
            || attenuation.linear.is_some()
            || attenuation.quadratic.is_some()
        {
            self.set_attenuation(Attenuation::new(
                attenuation.constant.unwrap_or(self.attenuation.constant),
                attenuation.linear.unwrap_or(self.attenuation.linear),
                attenuation.quadratic.unwrap_or(self.attenuation.quadratic),
            ));
        }
    }
}
impl Light2D {
    /// Render falloff comparison panels for each mode into an `ImageData` debug image.
    pub fn draw_falloff_comparison_to_image(
        modes: &[(FalloffMode, &str)],
        radius: f32,
        width: u32,
        height: u32,
    ) -> crate::image::ImageData {
        let mut img = crate::image::ImageData::new(width, height);
        img.fill(10, 10, 15, 255);
        let count = modes.len().max(1);
        let cell_w = width / count as u32;
        for (i, &(mode, name)) in modes.iter().enumerate() {
            let ox = i as i32 * cell_w as i32;
            let cx = ox + cell_w as i32 / 2;
            let cy = height as i32 / 2;
            let ri = radius as i32;
            for dy in -ri..=ri {
                for dx in -ri..=ri {
                    let dist = ((dx * dx + dy * dy) as f32).sqrt();
                    if dist > radius {
                        continue;
                    }
                    let t = dist / radius;
                    let intensity = match mode {
                        FalloffMode::Linear => 1.0 - t,
                        FalloffMode::Smooth => 1.0 - t * t,
                        FalloffMode::Constant => 1.0,
                    };
                    let px = (cx + dx) as u32;
                    let py = (cy + dy) as u32;
                    if px < width && py < height {
                        let r = (255.0 * intensity) as u8;
                        let g = (200.0 * intensity * 0.8) as u8;
                        let b = (100.0 * intensity * 0.4) as u8;
                        let existing = img.get_pixel(px, py).unwrap_or((0, 0, 0, 0));
                        let nr = r.max(existing.0);
                        let ng = g.max(existing.1);
                        let nb = b.max(existing.2);
                        img.set_pixel(px, py, nr, ng, nb, 255);
                    }
                }
            }
            img.draw_label(name, ox + 30, (height - 15) as i32, 200, 200, 200);
        }
        img.draw_label("LIGHT FALLOFF MODES", (width / 3) as i32, 3, 100, 255, 100);
        img
    }
}
