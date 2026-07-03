//! Owns the overlay controller implementation for the overlay subsystem and keeps related runtime rules local here.
//! Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
//! Defines how overlay controller data is validated, transformed, or stored before neighboring systems consume it.
//! Separates overlay controller behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing overlay controller defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near overlay controller state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping overlay controller calculations explicit at their owning subsystem boundary.
//! Provides local adaptation layer that lets callers reuse overlay controller rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on overlay controller state, helpers, or rules.
//! Works with neighboring overlay owners while keeping the main overlay controller responsibility anchored in one file.

use super::ambient::AmbientState;
use super::atmosphere::{
    CloudState, FilmGrainState, FogState, HeatHazeState, LightningState, VignetteState,
};
use super::screen_effects::{FadeState, FlashState, ShakeState};
use super::status::{StatusLayerTarget, StatusOverlayLayer, StatusOverlayStack};
use super::water::WaterOverlayState;
use super::weather::{WeatherParticle, WeatherProfile, WeatherState, WeatherType};
use crate::image::ImageData;
use crate::log_msg;
use crate::render::renderer::{DrawMode, PostFxPass, RenderCommand};
use crate::runtime::log_messages::{OV01, OV02, OV03};
use std::collections::HashMap;
use std::error::Error;
use std::fmt;

mod debug_image;
mod effects;
mod render;
mod weather;

/// Minimum non-zero duration accepted by timed overlay effects.
const MIN_EFFECT_DURATION: f32 = 1.0e-4;
const DEFAULT_MAX_WEATHER_PARTICLES: usize = 4_096;
const DEFAULT_MAX_WEATHER_SPAWNS_PER_UPDATE: usize = 512;
const DEFAULT_MAX_DEBUG_IMAGE_PIXELS: u64 = 4_194_304;
const DEFAULT_MAX_DEBUG_IMAGE_BYTES: usize = 16 * 1024 * 1024;
const DEFAULT_MAX_SHADER_NAME_LEN: usize = 64;
const DEFAULT_MAX_FLASH_DURATION: f32 = 1.0;

const BUILTIN_OVERLAY_SHADER_NAMES: &[&str] = &[
    "bloom",
    "blur_h",
    "blur_v",
    "vignette",
    "noise",
    "grayscale",
    "sepia",
    "invert",
    "crt",
    "chromatic",
    "scanlines",
    "pixelate",
    "hueshift",
    "edgedetect",
    "godrays",
    "waterdistort",
    "sharpen",
    "dither",
    "outline",
    "depthoffield",
    "motionblur",
];

/// Snapshot of overlay runtime state for telemetry, debugging, and dashboard surfaces.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct OverlayStats {
    /// Current overlay width in pixels.
    pub width: u32,
    /// Current overlay height in pixels.
    pub height: u32,
    /// Number of live weather particles.
    pub weather_particle_count: usize,
    /// Maximum number of weather particles allowed for the current intensity.
    pub weather_particle_limit: usize,
    /// Current weather intensity after safety clamping.
    pub weather_intensity: f32,
    /// Current flash alpha after decay.
    pub flash_alpha: f32,
    /// Current lightning alpha after decay.
    pub lightning_alpha: f32,
    /// Number of currently enabled or active effect groups.
    pub active_effects: u32,
    /// Whether weather is enabled.
    pub weather_enabled: bool,
    /// Whether ambient is enabled.
    pub ambient_enabled: bool,
    /// Whether fog is enabled.
    pub fog_enabled: bool,
    /// Whether vignette is enabled.
    pub vignette_enabled: bool,
    /// Count of weather particles spawned during the last update.
    pub weather_spawns_this_frame: usize,
    /// Count of weather particles skipped during the last update because of limits or backlog.
    pub weather_dropped_spawns: usize,
    /// Count of weather particles culled during the last update.
    pub weather_culled_particles: usize,
    /// Count of large-dt weather updates clamped by the per-update spawn cap.
    pub weather_dt_spike_clamps: usize,
    /// Whether reduced-motion mode is currently active.
    pub reduced_motion: bool,
    /// Count of accessibility-policy modifications applied so far.
    pub accessibility_adjustments: usize,
    /// Count of state fields sanitized so far.
    pub sanitized_fields: usize,
    /// Count of invalid custom shader names rejected or cleared so far.
    pub invalid_shader_rejections: usize,
    /// Count of debug image requests rejected by image limits so far.
    pub debug_image_rejections: usize,
    /// Count of active layers currently reported as externally rendered.
    pub external_render_layers: usize,
    /// Count of authored status layers tracked by the overlay.
    pub status_layers: usize,
    /// Count of currently active status layers contributing visible output.
    pub active_status_layers: usize,
}

#[derive(Debug, Clone, Copy, PartialEq)]
/// Accessibility policy applied to flash, shake, lightning, and grain-heavy overlays.
pub struct OverlayAccessibilityPolicy {
    /// Enables the reduced-motion preset and related policy clamping.
    pub reduced_motion: bool,
    /// Maximum flash or lightning alpha allowed by the overlay.
    pub max_flash_alpha: f32,
    /// Maximum flash or lightning duration in seconds.
    pub max_flash_duration: f32,
    /// Maximum number of flash triggers accepted per second.
    pub max_flash_per_second: f32,
    /// Maximum screen-shake intensity in screen units.
    pub max_shake_intensity: f32,
    /// Disables lightning triggers when enabled.
    pub disable_lightning: bool,
    /// Disables film grain when enabled.
    pub disable_film_grain: bool,
}

impl Default for OverlayAccessibilityPolicy {
    fn default() -> Self {
        Self {
            reduced_motion: false,
            max_flash_alpha: 1.0,
            max_flash_duration: DEFAULT_MAX_FLASH_DURATION,
            max_flash_per_second: 12.0,
            max_shake_intensity: 24.0,
            disable_lightning: false,
            disable_film_grain: false,
        }
    }
}

impl OverlayAccessibilityPolicy {
    /// Returns a conservative reduced-motion preset.
    pub fn reduced_motion() -> Self {
        Self {
            reduced_motion: true,
            max_flash_alpha: 0.25,
            max_flash_duration: 0.12,
            max_flash_per_second: 2.0,
            max_shake_intensity: 1.5,
            disable_lightning: true,
            disable_film_grain: true,
        }
    }

    fn normalized(self) -> Self {
        Self {
            reduced_motion: self.reduced_motion,
            max_flash_alpha: clamp_unit(self.max_flash_alpha),
            max_flash_duration: sanitize_duration(
                self.max_flash_duration,
                DEFAULT_MAX_FLASH_DURATION,
            ),
            max_flash_per_second: non_negative_or(self.max_flash_per_second, 1.0).max(0.1),
            max_shake_intensity: non_negative_or(self.max_shake_intensity, 0.0),
            disable_lightning: self.disable_lightning,
            disable_film_grain: self.disable_film_grain,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
/// Maximum debug-image allocation sizes accepted by overlay helper methods.
pub struct OverlayImageLimits {
    /// Maximum total pixel count accepted by one debug image request.
    pub max_pixels: u64,
    /// Maximum RGBA byte count accepted by one debug image request.
    pub max_bytes: usize,
}

impl Default for OverlayImageLimits {
    fn default() -> Self {
        Self {
            max_pixels: DEFAULT_MAX_DEBUG_IMAGE_PIXELS,
            max_bytes: DEFAULT_MAX_DEBUG_IMAGE_BYTES,
        }
    }
}

impl OverlayImageLimits {
    fn normalized(self) -> Self {
        Self {
            max_pixels: self.max_pixels.max(1),
            max_bytes: self.max_bytes.max(4),
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
/// Runtime limits enforced by the overlay controller.
pub struct OverlayLimits {
    /// Upper bound on total live weather particles.
    pub max_weather_particles: usize,
    /// Upper bound on weather particles spawned during one update.
    pub max_weather_spawns_per_update: usize,
    /// Maximum debug image sizes accepted by checked helper methods.
    pub debug_images: OverlayImageLimits,
}

impl Default for OverlayLimits {
    fn default() -> Self {
        Self {
            max_weather_particles: DEFAULT_MAX_WEATHER_PARTICLES,
            max_weather_spawns_per_update: DEFAULT_MAX_WEATHER_SPAWNS_PER_UPDATE,
            debug_images: OverlayImageLimits::default(),
        }
    }
}

impl OverlayLimits {
    fn normalized(self) -> Self {
        Self {
            max_weather_particles: self.max_weather_particles.max(1),
            max_weather_spawns_per_update: self.max_weather_spawns_per_update.max(1),
            debug_images: self.debug_images.normalized(),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
/// Validation policy for optional custom overlay shader names.
pub struct OverlayShaderPolicy {
    /// Maximum number of bytes accepted by a shader name.
    pub max_name_len: usize,
    /// Whether built-in post-effect shader names are accepted.
    pub allow_builtin_postfx_shaders: bool,
}

impl Default for OverlayShaderPolicy {
    fn default() -> Self {
        Self {
            max_name_len: DEFAULT_MAX_SHADER_NAME_LEN,
            allow_builtin_postfx_shaders: true,
        }
    }
}

impl OverlayShaderPolicy {
    fn normalized(&self) -> Self {
        Self {
            max_name_len: self.max_name_len.max(1),
            allow_builtin_postfx_shaders: self.allow_builtin_postfx_shaders,
        }
    }

    /// Validates one custom shader name against the policy.
    pub fn validate_name(&self, name: &str) -> Result<(), OverlayError> {
        let policy = self.normalized();
        let trimmed = name.trim();
        if trimmed.is_empty() {
            return Err(OverlayError::InvalidShaderName(
                "custom shader name cannot be empty".to_string(),
            ));
        }
        if trimmed.len() > policy.max_name_len {
            return Err(OverlayError::InvalidShaderName(format!(
                "custom shader name '{}' exceeds {} bytes",
                trimmed, policy.max_name_len
            )));
        }
        if !trimmed
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || byte == b'_' || byte == b'-')
        {
            return Err(OverlayError::InvalidShaderName(format!(
                "custom shader name '{}' must use only ASCII letters, digits, '_' or '-'",
                trimmed
            )));
        }
        if policy.allow_builtin_postfx_shaders && BUILTIN_OVERLAY_SHADER_NAMES.contains(&trimmed) {
            return Ok(());
        }
        Err(OverlayError::UnsupportedShader(trimmed.to_string()))
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
/// Diagnostic counters collected by permissive overlay operations.
pub struct OverlayDiagnostics {
    /// Count of weather particles spawned during the most recent update.
    pub weather_spawns_this_frame: usize,
    /// Count of weather particles skipped during the most recent update because of limits or backlog.
    pub weather_dropped_spawns: usize,
    /// Count of weather particles culled during the most recent update.
    pub weather_culled_particles: usize,
    /// Count of large-dt weather updates clamped by the per-update spawn cap.
    pub weather_dt_spike_clamps: usize,
    /// Count of accessibility-policy modifications applied since construction or clear.
    pub accessibility_adjustments: usize,
    /// Count of invalid custom shader names rejected or cleared since construction or clear.
    pub invalid_shader_rejections: usize,
    /// Count of debug image requests rejected since construction or clear.
    pub debug_image_rejections: usize,
    /// Count of invalid state fields sanitized since construction or clear.
    pub sanitized_fields: usize,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
/// One overlay layer classification used by render responsibility reporting.
pub enum OverlayRenderLayer {
    /// Timed full-screen flash color.
    Flash,
    /// Timed fade-to-color overlay.
    Fade,
    /// Lightning flash overlay.
    Lightning,
    /// Darkening screen-edge vignette.
    Vignette,
    /// Ambient full-screen tint.
    Ambient,
    /// Particle weather layer.
    Weather,
    /// Cloud shadow overlay.
    Clouds,
    /// Fog wash overlay.
    Fog,
    /// Heat-haze distortion layer.
    HeatHaze,
    /// Film-grain overlay.
    FilmGrain,
    /// Water distortion overlay.
    Water,
    /// Custom shader-driven overlay.
    CustomShader,
    /// Direct fullscreen color-wash status layer.
    StatusColorWash,
    /// Fullscreen texture-driven status layer.
    StatusTexture,
    /// Status layer that requests renderer-owned post-fx work.
    StatusPostFx,
}

impl OverlayRenderLayer {
    /// Returns the stable lowercase render-layer name used by diagnostics and Lua.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Flash => "flash",
            Self::Fade => "fade",
            Self::Lightning => "lightning",
            Self::Vignette => "vignette",
            Self::Ambient => "ambient",
            Self::Weather => "weather",
            Self::Clouds => "clouds",
            Self::Fog => "fog",
            Self::HeatHaze => "heat_haze",
            Self::FilmGrain => "film_grain",
            Self::Water => "water",
            Self::CustomShader => "custom_shader",
            Self::StatusColorWash => "status_color_wash",
            Self::StatusTexture => "status_texture",
            Self::StatusPostFx => "status_postfx",
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
/// Reporting object that separates actively rendered layers from active externally handled layers.
pub struct OverlayRenderPlan {
    /// Active layers emitted by `build_render_commands`.
    pub rendered: Vec<OverlayRenderLayer>,
    /// Active layers owned by other render or post-processing paths.
    pub externally_handled: Vec<OverlayRenderLayer>,
    /// Active layers that the overlay recognized but cannot currently route directly.
    pub unsupported: Vec<OverlayRenderLayer>,
    /// Active layers that were downgraded into a fallback path.
    pub fallback: Vec<OverlayRenderLayer>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
/// Structured overlay validation and safety failures.
pub enum OverlayError {
    /// One field contained an invalid value.
    InvalidState {
        /// Stable field label used in diagnostics and tests.
        field: &'static str,
        /// Human-readable reason for the failure.
        reason: &'static str,
    },
    /// A requested custom shader name violated naming policy.
    InvalidShaderName(String),
    /// A requested custom shader name passed syntax checks but is not in the allowlist.
    UnsupportedShader(String),
    /// A debug image request exceeded configured pixel or byte limits.
    DebugImageTooLarge {
        /// Requested width in pixels.
        width: u32,
        /// Requested height in pixels.
        height: u32,
        /// Requested pixel count.
        pixels: u64,
        /// Requested RGBA byte count.
        bytes: usize,
    },
}

impl fmt::Display for OverlayError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidState { field, reason } => write!(f, "{}: {}", field, reason),
            Self::InvalidShaderName(message) => write!(f, "{}", message),
            Self::UnsupportedShader(name) => write!(
                f,
                "custom shader '{}' is not in the overlay shader allowlist",
                name
            ),
            Self::DebugImageTooLarge {
                width,
                height,
                pixels,
                bytes,
            } => write!(
                f,
                "debug image {}x{} exceeds overlay image limits (pixels={}, bytes={})",
                width, height, pixels, bytes
            ),
        }
    }
}

impl Error for OverlayError {}

fn clamp_unit(value: f32) -> f32 {
    if value.is_finite() {
        value.clamp(0.0, 1.0)
    } else {
        0.0
    }
}

fn finite_or(value: f32, fallback: f32) -> f32 {
    if value.is_finite() {
        value
    } else {
        fallback
    }
}

fn non_negative_or(value: f32, fallback: f32) -> f32 {
    finite_or(value, fallback).max(0.0)
}

fn sanitize_duration(duration: f32, fallback: f32) -> f32 {
    if duration.is_finite() && duration > 0.0 {
        duration.max(MIN_EFFECT_DURATION)
    } else {
        fallback.max(MIN_EFFECT_DURATION)
    }
}

fn sanitize_color(color: [f32; 4], fallback: [f32; 4]) -> ([f32; 4], usize) {
    let mut changed = 0usize;
    let mut out = color;
    for i in 0..4 {
        let next = if color[i].is_finite() {
            color[i].clamp(0.0, 1.0)
        } else {
            clamp_unit(fallback[i])
        };
        if (next - color[i]).abs() > f32::EPSILON || !color[i].is_finite() {
            changed += 1;
        }
        out[i] = next;
    }
    (out, changed)
}

fn checked_debug_image_request(
    limits: OverlayImageLimits,
    width: u32,
    height: u32,
) -> Result<(), OverlayError> {
    let pixels = u64::from(width).checked_mul(u64::from(height)).ok_or(
        OverlayError::DebugImageTooLarge {
            width,
            height,
            pixels: u64::MAX,
            bytes: usize::MAX,
        },
    )?;
    let bytes =
        ImageData::rgba_byte_len(width, height).map_err(|_| OverlayError::DebugImageTooLarge {
            width,
            height,
            pixels,
            bytes: usize::MAX,
        })?;
    let limits = limits.normalized();
    if pixels > limits.max_pixels || bytes > limits.max_bytes {
        return Err(OverlayError::DebugImageTooLarge {
            width,
            height,
            pixels,
            bytes,
        });
    }
    Ok(())
}

/// Owns every screen-space overlay state block applied on top of world rendering.
#[derive(Debug, Clone)]
pub struct Overlay {
    /// Current overlay target width in pixels.
    pub width: u32,
    /// Current overlay target height in pixels.
    pub height: u32,
    /// Weather particle simulation and configuration.
    pub weather: WeatherState,
    /// Ambient tint state derived from time-of-day.
    pub ambient: AmbientState,
    /// Timed flash overlay state.
    pub flash: FlashState,
    /// Camera shake state and offsets.
    pub shake: ShakeState,
    /// Timed fade overlay state.
    pub fade: FadeState,
    /// Cloud overlay configuration.
    pub clouds: CloudState,
    /// Fog overlay configuration.
    pub fog: FogState,
    /// Heat haze distortion configuration.
    pub heat_haze: HeatHazeState,
    /// Vignette darkening configuration.
    pub vignette: VignetteState,
    /// Film grain configuration.
    pub film_grain: FilmGrainState,
    /// Lightning flash overlay state.
    pub lightning: LightningState,
    /// Water distortion overlay configuration and timer.
    pub water: WaterOverlayState,
    /// Layered status overlays such as frozen, poison, or low-health feedback.
    pub status_stack: StatusOverlayStack,
    /// Optional custom overlay shader name.
    pub custom_shader: Option<String>,
    /// Accessibility and reduced-motion policy applied to active effects.
    pub accessibility_policy: OverlayAccessibilityPolicy,
    /// Runtime limits for weather and debug image helpers.
    pub limits: OverlayLimits,
    /// Validation policy for custom shader names.
    pub shader_policy: OverlayShaderPolicy,
    diagnostics: OverlayDiagnostics,
    time_since_last_flash: f32,
}

impl Overlay {
    /// Creates an overlay initialized with default state blocks for the target size.
    pub fn new(width: u32, height: u32) -> Self {
        let width = width.max(1);
        let height = height.max(1);
        log_msg!(debug, OV01, "{}x{}", width, height);
        Self {
            width,
            height,
            weather: WeatherState::default(),
            ambient: AmbientState::default(),
            flash: FlashState::default(),
            shake: ShakeState::default(),
            fade: FadeState::default(),
            clouds: CloudState::default(),
            fog: FogState::default(),
            heat_haze: HeatHazeState::default(),
            vignette: VignetteState::default(),
            film_grain: FilmGrainState::default(),
            lightning: LightningState::default(),
            water: WaterOverlayState::default(),
            status_stack: StatusOverlayStack::default(),
            custom_shader: None,
            accessibility_policy: OverlayAccessibilityPolicy::default(),
            limits: OverlayLimits::default(),
            shader_policy: OverlayShaderPolicy::default(),
            diagnostics: OverlayDiagnostics::default(),
            time_since_last_flash: f32::INFINITY,
        }
    }

    /// Replaces the current accessibility policy after normalizing it.
    pub fn set_accessibility_policy(&mut self, policy: OverlayAccessibilityPolicy) {
        self.accessibility_policy = policy.normalized();
        self.sanitize();
    }

    /// Returns the current accessibility policy snapshot.
    pub fn accessibility_policy(&self) -> OverlayAccessibilityPolicy {
        self.accessibility_policy
    }

    /// Returns the current permissive diagnostics snapshot.
    pub fn diagnostics(&self) -> OverlayDiagnostics {
        self.diagnostics
    }

    /// Sets or clears the custom overlay shader name after applying naming policy.
    pub fn set_custom_shader(&mut self, name: Option<String>) -> Result<(), OverlayError> {
        match name {
            None => {
                self.custom_shader = None;
                Ok(())
            }
            Some(name) => {
                let trimmed = name.trim().to_string();
                self.shader_policy.validate_name(&trimmed)?;
                self.custom_shader = Some(trimmed);
                Ok(())
            }
        }
    }

    /// Validates the current overlay state and returns the first structured failure.
    pub fn validate(&self) -> Result<(), OverlayError> {
        if self.width == 0 {
            return Err(OverlayError::InvalidState {
                field: "width",
                reason: "must be >= 1",
            });
        }
        if self.height == 0 {
            return Err(OverlayError::InvalidState {
                field: "height",
                reason: "must be >= 1",
            });
        }
        if !self.weather.intensity.is_finite() {
            return Err(OverlayError::InvalidState {
                field: "weather.intensity",
                reason: "must be finite",
            });
        }
        if !self.weather.wind_direction.is_finite() {
            return Err(OverlayError::InvalidState {
                field: "weather.wind_direction",
                reason: "must be finite",
            });
        }
        if !self.weather.wind_speed.is_finite() || self.weather.wind_speed < 0.0 {
            return Err(OverlayError::InvalidState {
                field: "weather.wind_speed",
                reason: "must be finite and >= 0",
            });
        }
        validate_color_field("ambient.color", self.ambient.color)?;
        validate_color_field("flash.color", self.flash.color)?;
        validate_color_field("fade.color", self.fade.color)?;
        validate_color_field("fog.color", self.fog.color)?;
        validate_color_field("lightning.color", self.lightning.color)?;
        if let Some(name) = &self.custom_shader {
            self.shader_policy.validate_name(name)?;
        }
        Ok(())
    }

    /// Sanitizes the entire overlay state so invalid direct field mutation cannot leak to render commands.
    pub fn sanitize(&mut self) {
        let default_weather = WeatherState::default();
        let default_ambient = AmbientState::default();
        let default_flash = FlashState::default();
        let default_fade = FadeState::default();
        let default_clouds = CloudState::default();
        let default_fog = FogState::default();
        let default_heat_haze = HeatHazeState::default();
        let default_vignette = VignetteState::default();
        let default_film_grain = FilmGrainState::default();
        let default_lightning = LightningState::default();
        let default_water = WaterOverlayState::default();

        let mut changed = 0usize;
        let normalized_policy = self.accessibility_policy.normalized();
        if self.accessibility_policy != normalized_policy {
            self.accessibility_policy = normalized_policy;
            changed += 1;
        }
        let normalized_limits = self.limits.normalized();
        if self.limits != normalized_limits {
            self.limits = normalized_limits;
            changed += 1;
        }
        let normalized_shader_policy = self.shader_policy.normalized();
        if self.shader_policy != normalized_shader_policy {
            self.shader_policy = normalized_shader_policy;
            changed += 1;
        }
        if self.width == 0 {
            self.width = 1;
            changed += 1;
        }
        if self.height == 0 {
            self.height = 1;
            changed += 1;
        }

        let next_weather_intensity = if self.weather.intensity.is_finite() {
            self.weather.intensity.clamp(0.0, 8.0)
        } else {
            default_weather.intensity
        };
        if next_weather_intensity != self.weather.intensity || !self.weather.intensity.is_finite() {
            self.weather.intensity = next_weather_intensity;
            changed += 1;
        }
        let next_wind_direction =
            finite_or(self.weather.wind_direction, default_weather.wind_direction);
        if next_wind_direction != self.weather.wind_direction
            || !self.weather.wind_direction.is_finite()
        {
            self.weather.wind_direction = next_wind_direction;
            changed += 1;
        }
        let next_wind_speed = non_negative_or(self.weather.wind_speed, default_weather.wind_speed);
        if next_wind_speed != self.weather.wind_speed || !self.weather.wind_speed.is_finite() {
            self.weather.wind_speed = next_wind_speed;
            changed += 1;
        }
        let next_spawn_timer = non_negative_or(self.weather.spawn_timer, 0.0);
        if next_spawn_timer != self.weather.spawn_timer || !self.weather.spawn_timer.is_finite() {
            self.weather.spawn_timer = next_spawn_timer;
            changed += 1;
        }
        if self.weather.rng_state() == 0 {
            self.weather.set_rng_state(0);
            changed += 1;
        }
        if self.weather.particles.len() > self.limits.max_weather_particles {
            let removed = self.weather.particles.len() - self.limits.max_weather_particles;
            self.weather
                .particles
                .truncate(self.limits.max_weather_particles);
            changed += removed;
        }
        for particle in &mut self.weather.particles {
            changed += sanitize_weather_particle(particle);
        }

        let (ambient_color, ambient_changes) =
            sanitize_color(self.ambient.color, default_ambient.color);
        self.ambient.color = ambient_color;
        changed += ambient_changes;
        let next_time_of_day = finite_or(self.ambient.time_of_day, default_ambient.time_of_day);
        if next_time_of_day != self.ambient.time_of_day || !self.ambient.time_of_day.is_finite() {
            self.ambient.time_of_day = next_time_of_day;
            changed += 1;
        }

        let (flash_color, flash_changes) = sanitize_color(self.flash.color, default_flash.color);
        self.flash.color = flash_color;
        changed += flash_changes;
        let next_flash_duration = sanitize_duration(self.flash.duration, default_flash.duration);
        if next_flash_duration != self.flash.duration || !self.flash.duration.is_finite() {
            self.flash.duration = next_flash_duration;
            changed += 1;
        }
        let next_flash_elapsed = non_negative_or(self.flash.elapsed, 0.0).min(self.flash.duration);
        if next_flash_elapsed != self.flash.elapsed || !self.flash.elapsed.is_finite() {
            self.flash.elapsed = next_flash_elapsed;
            changed += 1;
        }

        let next_shake_intensity = non_negative_or(self.shake.intensity, 0.0);
        if next_shake_intensity != self.shake.intensity || !self.shake.intensity.is_finite() {
            self.shake.intensity = next_shake_intensity;
            changed += 1;
        }
        let next_shake_duration =
            sanitize_duration(self.shake.duration, ShakeState::default().duration);
        if next_shake_duration != self.shake.duration || !self.shake.duration.is_finite() {
            self.shake.duration = next_shake_duration;
            changed += 1;
        }
        let next_shake_elapsed = non_negative_or(self.shake.elapsed, 0.0).min(self.shake.duration);
        if next_shake_elapsed != self.shake.elapsed || !self.shake.elapsed.is_finite() {
            self.shake.elapsed = next_shake_elapsed;
            changed += 1;
        }
        let next_offset_x = finite_or(self.shake.offset_x, 0.0);
        if next_offset_x != self.shake.offset_x || !self.shake.offset_x.is_finite() {
            self.shake.offset_x = next_offset_x;
            changed += 1;
        }
        let next_offset_y = finite_or(self.shake.offset_y, 0.0);
        if next_offset_y != self.shake.offset_y || !self.shake.offset_y.is_finite() {
            self.shake.offset_y = next_offset_y;
            changed += 1;
        }

        let (fade_color, fade_changes) = sanitize_color(self.fade.color, default_fade.color);
        self.fade.color = fade_color;
        changed += fade_changes;
        let next_target_alpha = clamp_unit(self.fade.target_alpha);
        if next_target_alpha != self.fade.target_alpha || !self.fade.target_alpha.is_finite() {
            self.fade.target_alpha = next_target_alpha;
            changed += 1;
        }
        let next_fade_duration = sanitize_duration(self.fade.duration, default_fade.duration);
        if next_fade_duration != self.fade.duration || !self.fade.duration.is_finite() {
            self.fade.duration = next_fade_duration;
            changed += 1;
        }
        let next_fade_elapsed = non_negative_or(self.fade.elapsed, 0.0).min(self.fade.duration);
        if next_fade_elapsed != self.fade.elapsed || !self.fade.elapsed.is_finite() {
            self.fade.elapsed = next_fade_elapsed;
            changed += 1;
        }
        let next_start_alpha =
            clamp_unit(finite_or(self.fade.start_alpha, default_fade.start_alpha));
        if next_start_alpha != self.fade.start_alpha || !self.fade.start_alpha.is_finite() {
            self.fade.start_alpha = next_start_alpha;
            changed += 1;
        }

        let next_cloud_speed = finite_or(self.clouds.speed, default_clouds.speed);
        if next_cloud_speed != self.clouds.speed || !self.clouds.speed.is_finite() {
            self.clouds.speed = next_cloud_speed;
            changed += 1;
        }
        let next_cloud_scale = non_negative_or(self.clouds.scale, default_clouds.scale).max(0.01);
        if next_cloud_scale != self.clouds.scale || !self.clouds.scale.is_finite() {
            self.clouds.scale = next_cloud_scale;
            changed += 1;
        }
        let next_cloud_opacity = clamp_unit(self.clouds.opacity);
        if next_cloud_opacity != self.clouds.opacity || !self.clouds.opacity.is_finite() {
            self.clouds.opacity = next_cloud_opacity;
            changed += 1;
        }
        let next_cloud_offset = finite_or(self.clouds.offset, default_clouds.offset);
        if next_cloud_offset != self.clouds.offset || !self.clouds.offset.is_finite() {
            self.clouds.offset = next_cloud_offset;
            changed += 1;
        }

        let next_fog_density = clamp_unit(self.fog.density);
        if next_fog_density != self.fog.density || !self.fog.density.is_finite() {
            self.fog.density = next_fog_density;
            changed += 1;
        }
        let (fog_color, fog_changes) = sanitize_color(self.fog.color, default_fog.color);
        self.fog.color = fog_color;
        changed += fog_changes;

        let next_heat_haze = clamp_unit(finite_or(
            self.heat_haze.intensity,
            default_heat_haze.intensity,
        ));
        if next_heat_haze != self.heat_haze.intensity || !self.heat_haze.intensity.is_finite() {
            self.heat_haze.intensity = next_heat_haze;
            changed += 1;
        }

        let next_vignette =
            clamp_unit(finite_or(self.vignette.strength, default_vignette.strength));
        if next_vignette != self.vignette.strength || !self.vignette.strength.is_finite() {
            self.vignette.strength = next_vignette;
            changed += 1;
        }

        let next_film_grain = clamp_unit(finite_or(
            self.film_grain.intensity,
            default_film_grain.intensity,
        ));
        if next_film_grain != self.film_grain.intensity || !self.film_grain.intensity.is_finite() {
            self.film_grain.intensity = next_film_grain;
            changed += 1;
        }

        let (lightning_color, lightning_changes) =
            sanitize_color(self.lightning.color, default_lightning.color);
        self.lightning.color = lightning_color;
        changed += lightning_changes;
        let next_lightning_duration =
            sanitize_duration(self.lightning.duration, default_lightning.duration);
        if next_lightning_duration != self.lightning.duration
            || !self.lightning.duration.is_finite()
        {
            self.lightning.duration = next_lightning_duration;
            changed += 1;
        }
        let next_lightning_elapsed =
            non_negative_or(self.lightning.elapsed, 0.0).min(self.lightning.duration);
        if next_lightning_elapsed != self.lightning.elapsed || !self.lightning.elapsed.is_finite() {
            self.lightning.elapsed = next_lightning_elapsed;
            changed += 1;
        }

        let next_water_amplitude = finite_or(self.water.amplitude, default_water.amplitude);
        if next_water_amplitude != self.water.amplitude || !self.water.amplitude.is_finite() {
            self.water.amplitude = next_water_amplitude;
            changed += 1;
        }
        let next_water_frequency = finite_or(self.water.frequency, default_water.frequency);
        if next_water_frequency != self.water.frequency || !self.water.frequency.is_finite() {
            self.water.frequency = next_water_frequency;
            changed += 1;
        }
        let next_water_speed = finite_or(self.water.speed, default_water.speed);
        if next_water_speed != self.water.speed || !self.water.speed.is_finite() {
            self.water.speed = next_water_speed;
            changed += 1;
        }
        let next_water_tint_r = clamp_unit(self.water.tint_r);
        if next_water_tint_r != self.water.tint_r || !self.water.tint_r.is_finite() {
            self.water.tint_r = next_water_tint_r;
            changed += 1;
        }
        let next_water_tint_g = clamp_unit(self.water.tint_g);
        if next_water_tint_g != self.water.tint_g || !self.water.tint_g.is_finite() {
            self.water.tint_g = next_water_tint_g;
            changed += 1;
        }
        let next_water_tint_b = clamp_unit(self.water.tint_b);
        if next_water_tint_b != self.water.tint_b || !self.water.tint_b.is_finite() {
            self.water.tint_b = next_water_tint_b;
            changed += 1;
        }
        let next_water_tint_strength = clamp_unit(self.water.tint_strength);
        if next_water_tint_strength != self.water.tint_strength
            || !self.water.tint_strength.is_finite()
        {
            self.water.tint_strength = next_water_tint_strength;
            changed += 1;
        }
        let next_water_depth_r = clamp_unit(self.water.depth_r);
        if next_water_depth_r != self.water.depth_r || !self.water.depth_r.is_finite() {
            self.water.depth_r = next_water_depth_r;
            changed += 1;
        }
        let next_water_depth_g = clamp_unit(self.water.depth_g);
        if next_water_depth_g != self.water.depth_g || !self.water.depth_g.is_finite() {
            self.water.depth_g = next_water_depth_g;
            changed += 1;
        }
        let next_water_depth_b = clamp_unit(self.water.depth_b);
        if next_water_depth_b != self.water.depth_b || !self.water.depth_b.is_finite() {
            self.water.depth_b = next_water_depth_b;
            changed += 1;
        }
        let next_water_depth_strength = clamp_unit(self.water.depth_strength);
        if next_water_depth_strength != self.water.depth_strength
            || !self.water.depth_strength.is_finite()
        {
            self.water.depth_strength = next_water_depth_strength;
            changed += 1;
        }
        let next_water_time = non_negative_or(self.water.time, default_water.time);
        if next_water_time != self.water.time || !self.water.time.is_finite() {
            self.water.time = next_water_time;
            changed += 1;
        }
        for (index, layer) in self.status_stack.layers.iter_mut().enumerate() {
            changed += sanitize_status_layer(layer, index);
        }
        self.status_stack
            .layers
            .retain(|layer| !layer.id.is_empty());

        let mut accessibility_changes = 0usize;
        for layer in &mut self.status_stack.layers {
            accessibility_changes += apply_status_accessibility(layer, self.accessibility_policy);
        }
        if self.flash.color[3] > self.accessibility_policy.max_flash_alpha {
            self.flash.color[3] = self.accessibility_policy.max_flash_alpha;
            accessibility_changes += 1;
        }
        if self.flash.duration > self.accessibility_policy.max_flash_duration {
            self.flash.duration = self.accessibility_policy.max_flash_duration;
            self.flash.elapsed = self.flash.elapsed.min(self.flash.duration);
            accessibility_changes += 1;
        }
        if self.shake.intensity > self.accessibility_policy.max_shake_intensity {
            self.shake.intensity = self.accessibility_policy.max_shake_intensity;
            accessibility_changes += 1;
        }
        if self.accessibility_policy.disable_lightning && self.lightning.active {
            self.lightning.active = false;
            self.lightning.elapsed = 0.0;
            accessibility_changes += 1;
        }
        if self.lightning.color[3] > self.accessibility_policy.max_flash_alpha {
            self.lightning.color[3] = self.accessibility_policy.max_flash_alpha;
            accessibility_changes += 1;
        }
        if self.lightning.duration > self.accessibility_policy.max_flash_duration {
            self.lightning.duration = self.accessibility_policy.max_flash_duration;
            self.lightning.elapsed = self.lightning.elapsed.min(self.lightning.duration);
            accessibility_changes += 1;
        }
        if self.accessibility_policy.disable_film_grain && self.film_grain.enabled {
            self.film_grain.enabled = false;
            accessibility_changes += 1;
        }
        if accessibility_changes > 0 {
            changed += accessibility_changes;
            self.diagnostics.accessibility_adjustments += accessibility_changes;
        }

        let invalid_shader = match &self.custom_shader {
            Some(name) => self.shader_policy.validate_name(name).is_err(),
            None => false,
        };
        if invalid_shader {
            self.custom_shader = None;
            self.diagnostics.invalid_shader_rejections += 1;
            changed += 1;
        }

        if !self.time_since_last_flash.is_finite() || self.time_since_last_flash < 0.0 {
            self.time_since_last_flash = f32::INFINITY;
            changed += 1;
        }
        if changed > 0 {
            self.diagnostics.sanitized_fields += changed;
        }
    }

    fn sanitized_clone(&self) -> Self {
        let mut clone = self.clone();
        clone.sanitize();
        clone
    }
}

fn validate_color_field(field: &'static str, color: [f32; 4]) -> Result<(), OverlayError> {
    if color.iter().all(|value| value.is_finite()) {
        Ok(())
    } else {
        Err(OverlayError::InvalidState {
            field,
            reason: "must contain only finite channel values",
        })
    }
}

fn sanitize_weather_particle(particle: &mut WeatherParticle) -> usize {
    let mut changed = 0usize;
    let next_x = finite_or(particle.x, 0.0);
    if next_x != particle.x || !particle.x.is_finite() {
        particle.x = next_x;
        changed += 1;
    }
    let next_y = finite_or(particle.y, 0.0);
    if next_y != particle.y || !particle.y.is_finite() {
        particle.y = next_y;
        changed += 1;
    }
    let next_vx = finite_or(particle.vx, 0.0);
    if next_vx != particle.vx || !particle.vx.is_finite() {
        particle.vx = next_vx;
        changed += 1;
    }
    let next_vy = finite_or(particle.vy, 0.0);
    if next_vy != particle.vy || !particle.vy.is_finite() {
        particle.vy = next_vy;
        changed += 1;
    }
    let next_size = non_negative_or(particle.size, 0.0);
    if next_size != particle.size || !particle.size.is_finite() {
        particle.size = next_size;
        changed += 1;
    }
    let next_alpha = clamp_unit(particle.alpha);
    if next_alpha != particle.alpha || !particle.alpha.is_finite() {
        particle.alpha = next_alpha;
        changed += 1;
    }
    changed
}

fn sanitize_status_layer(layer: &mut super::status::StatusOverlayLayer, index: usize) -> usize {
    let mut changed = 0usize;
    let fallback_id = format!("status_{index}");
    let trimmed_id = layer.id.trim().to_ascii_lowercase();
    if trimmed_id.is_empty() {
        if layer.id != fallback_id {
            layer.id = fallback_id;
            changed += 1;
        }
    } else if trimmed_id != layer.id {
        layer.id = trimmed_id;
        changed += 1;
    }
    let trimmed_kind = layer.kind.trim().to_ascii_lowercase();
    if trimmed_kind.is_empty() {
        if layer.kind != "custom" {
            layer.kind = "custom".to_string();
            changed += 1;
        }
    } else if trimmed_kind != layer.kind {
        layer.kind = trimmed_kind;
        changed += 1;
    }
    let next_intensity = finite_or(layer.intensity_01, 0.0).clamp(0.0, 1.0);
    if next_intensity != layer.intensity_01 || !layer.intensity_01.is_finite() {
        layer.intensity_01 = next_intensity;
        changed += 1;
    }
    let next_target = finite_or(layer.target_intensity_01, 0.0).clamp(0.0, 1.0);
    if next_target != layer.target_intensity_01 || !layer.target_intensity_01.is_finite() {
        layer.target_intensity_01 = next_target;
        changed += 1;
    }
    let next_fade_in = sanitize_duration(layer.fade_in, 0.2);
    if next_fade_in != layer.fade_in || !layer.fade_in.is_finite() {
        layer.fade_in = next_fade_in;
        changed += 1;
    }
    let next_fade_out = sanitize_duration(layer.fade_out, 0.35);
    if next_fade_out != layer.fade_out || !layer.fade_out.is_finite() {
        layer.fade_out = next_fade_out;
        changed += 1;
    }
    let next_elapsed = non_negative_or(layer.elapsed, 0.0);
    if next_elapsed != layer.elapsed || !layer.elapsed.is_finite() {
        layer.elapsed = next_elapsed;
        changed += 1;
    }
    if let Some(duration) = layer.duration {
        let next_duration = if duration.is_finite() && duration >= 0.0 {
            duration
        } else {
            0.0
        };
        if next_duration != duration || !duration.is_finite() {
            layer.duration = Some(next_duration);
            changed += 1;
        }
    }
    if let Some(color) = layer.visual.color {
        let (sanitized, color_changes) = sanitize_color(color, [0.0, 0.0, 0.0, 0.0]);
        if sanitized != color {
            layer.visual.color = Some(sanitized);
        }
        changed += color_changes;
    }
    let next_texture_opacity = clamp_unit(layer.visual.texture_opacity);
    if next_texture_opacity != layer.visual.texture_opacity
        || !layer.visual.texture_opacity.is_finite()
    {
        layer.visual.texture_opacity = next_texture_opacity;
        changed += 1;
    }
    let next_shader_strength = non_negative_or(layer.visual.shader_strength, 1.0);
    if next_shader_strength != layer.visual.shader_strength
        || !layer.visual.shader_strength.is_finite()
    {
        layer.visual.shader_strength = next_shader_strength;
        changed += 1;
    }
    if let Some(effect) = &mut layer.visual.shader_effect {
        let trimmed = effect.trim().to_ascii_lowercase();
        if trimmed.is_empty() {
            layer.visual.shader_effect = None;
            changed += 1;
        } else if trimmed != *effect {
            *effect = trimmed;
            changed += 1;
        }
    }
    changed
}

fn apply_status_accessibility(
    layer: &mut super::status::StatusOverlayLayer,
    policy: OverlayAccessibilityPolicy,
) -> usize {
    let mut changed = 0usize;
    if let Some(mut color) = layer.visual.color {
        let next_alpha = color[3].min(policy.max_flash_alpha);
        if next_alpha != color[3] {
            color[3] = next_alpha;
            layer.visual.color = Some(color);
            changed += 1;
        }
    }
    if layer.visual.texture_opacity > policy.max_flash_alpha {
        layer.visual.texture_opacity = policy.max_flash_alpha;
        changed += 1;
    }
    let Some(effect_name) = layer.visual.shader_effect.as_deref() else {
        return changed;
    };
    let next_strength = if policy.disable_film_grain && matches!(effect_name, "noise" | "scanlines")
    {
        0.0
    } else if policy.reduced_motion {
        match effect_name {
            "noise" | "scanlines" => 0.0,
            "chromatic" | "waterdistort" | "blur_h" | "blur_v" => {
                layer.visual.shader_strength.min(0.35)
            }
            _ => layer.visual.shader_strength.min(0.75),
        }
    } else {
        layer.visual.shader_strength
    };
    if next_strength != layer.visual.shader_strength {
        layer.visual.shader_strength = next_strength;
        changed += 1;
    }
    changed
}

fn lerp(a: f32, b: f32, t: f32) -> f32 {
    a + (b - a) * t.clamp(0.0, 1.0)
}
