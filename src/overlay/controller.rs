//! Owns the controller owner for the overlay subsystem and keeps its rules local to this file.
//! Keeps overlay data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how controller data is validated, transformed, or stored before neighboring systems use it.
//! Owns overlay behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on controller behavior while Lua registration stays elsewhere.
//! Documents the boundary where overlay code accepts inputs, reports errors, or updates state.
//! Use this file when changing controller defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the overlay state that can explain them while keeping call sites explicit.
//! Preserves deterministic behavior by keeping controller calculations explicit at their owner boundary.
//! Provides the local adaptation layer that lets callers avoid duplicating overlay rules while keeping call sites explicit.
//! Maintains small helper surfaces so broader engine modules can compose controller behavior safely.
//! Protects subsystem contracts by keeping resource, cache, or state mutations visible in one place.
//! Links adjacent concerns only where controller changes need coordination with owned engine data.

use super::ambient::AmbientState;
use super::atmosphere::{
    CloudState, FilmGrainState, FogState, HeatHazeState, LightningState, VignetteState,
};
use super::screen_effects::{FadeState, FlashState, ShakeState};
use super::status::StatusOverlayStack;
use super::water::WaterOverlayState;
use super::weather::{WeatherParticle, WeatherProfile, WeatherState, WeatherType};
use crate::image::ImageData;
use crate::log_msg;
use crate::render::renderer::{DrawMode, PostFxPass, RenderCommand};
use crate::runtime::log_messages::{OV01, OV02, OV03};
use std::collections::HashMap;
use std::error::Error;
use std::fmt;

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
        self.status_stack.layers.retain(|layer| !layer.id.is_empty());

        let mut accessibility_changes = 0usize;
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

    /// Advances every active overlay subsystem by `dt` seconds.
    pub fn update(&mut self, dt: f32) {
        if !dt.is_finite() || dt <= 0.0 {
            return;
        }
        self.sanitize();
        self.diagnostics.weather_spawns_this_frame = 0;
        self.diagnostics.weather_dropped_spawns = 0;
        self.diagnostics.weather_culled_particles = 0;
        self.diagnostics.weather_dt_spike_clamps = 0;
        self.time_since_last_flash = if self.time_since_last_flash.is_finite() {
            self.time_since_last_flash + dt
        } else {
            f32::INFINITY
        };

        if self.ambient.enabled {
            self.ambient.color = self.ambient.compute_color_from_time();
        }
        if self.weather.enabled
            && self.weather.weather_type != WeatherType::None
            && self.weather.intensity > 0.0
        {
            self.update_weather(dt);
        }
        if self.flash.active {
            self.flash.elapsed += dt;
            if self.flash.elapsed >= self.flash.duration {
                self.flash.active = false;
                self.flash.elapsed = 0.0;
            }
        }
        if self.shake.active {
            self.shake.elapsed += dt;
            if self.shake.elapsed >= self.shake.duration {
                self.shake.active = false;
                self.shake.elapsed = 0.0;
                self.shake.offset_x = 0.0;
                self.shake.offset_y = 0.0;
            } else {
                let progress = self.shake.elapsed / self.shake.duration;
                let decay = 1.0 - progress;
                let rx = self.shake.next_random();
                let ry = self.shake.next_random();
                self.shake.offset_x = rx * self.shake.intensity * decay;
                self.shake.offset_y = ry * self.shake.intensity * decay;
            }
        }
        if self.fade.active {
            self.fade.elapsed += dt;
            if self.fade.elapsed >= self.fade.duration {
                self.fade.active = false;
                self.fade.color[3] = self.fade.target_alpha;
            } else {
                let t = self.fade.elapsed / self.fade.duration;
                self.fade.color[3] =
                    self.fade.start_alpha + (self.fade.target_alpha - self.fade.start_alpha) * t;
            }
        }
        if self.clouds.enabled {
            self.clouds.offset += self.clouds.speed * dt;
        }
        if self.lightning.active {
            self.lightning.elapsed += dt;
            if self.lightning.elapsed >= self.lightning.duration {
                self.lightning.active = false;
                self.lightning.elapsed = 0.0;
            }
        }
        self.water.update(dt);
        self.status_stack.update(dt);
    }

    /// Advances particle spawn and movement for the active weather mode.
    fn update_weather(&mut self, dt: f32) {
        let max_particles = self.weather_particle_limit();
        let width = self.width as f32;
        let height = self.height as f32;
        let profile = self.weather.profile_for(self.weather.weather_type);
        self.weather.spawn_timer += dt;
        let spawn_interval =
            1.0 / (self.weather_intensity() * profile.spawn_rate_multiplier * 100.0 + 1.0);
        let spawn_budget_f = (self.weather.spawn_timer / spawn_interval).floor();
        let spawn_budget = if spawn_budget_f.is_finite() && spawn_budget_f > 0.0 {
            spawn_budget_f.min(usize::MAX as f32) as usize
        } else {
            0
        };
        let capacity = max_particles.saturating_sub(self.weather.particles.len());
        let actual_spawns = spawn_budget
            .min(capacity)
            .min(self.limits.max_weather_spawns_per_update);
        for _ in 0..actual_spawns {
            self.weather.spawn_timer -= spawn_interval;
            let particle = self.spawn_particle(width, profile);
            self.weather.particles.push(particle);
        }
        if spawn_budget > actual_spawns {
            self.diagnostics.weather_dropped_spawns = spawn_budget - actual_spawns;
        }
        if spawn_budget > self.limits.max_weather_spawns_per_update {
            self.diagnostics.weather_dt_spike_clamps += 1;
            self.weather.spawn_timer = self.weather.spawn_timer.min(spawn_interval);
        }
        self.diagnostics.weather_spawns_this_frame = actual_spawns;

        let wind_x = self.weather.wind_speed * self.weather.wind_direction.cos();
        let wind_y = self.weather.wind_speed * self.weather.wind_direction.sin();
        for particle in &mut self.weather.particles {
            particle.x += (particle.vx + wind_x) * dt;
            particle.y += (particle.vy + wind_y) * dt;
        }
        let margin = profile.culling_margin.max(1.0);
        let mut i = 0usize;
        while i < self.weather.particles.len() {
            let particle = &self.weather.particles[i];
            if particle.x > -margin
                && particle.x < width + margin
                && particle.y > -margin
                && particle.y < height + margin
            {
                i += 1;
            } else {
                self.weather.particles.swap_remove(i);
                self.diagnostics.weather_culled_particles += 1;
            }
        }
    }

    fn weather_intensity(&self) -> f32 {
        if self.weather.intensity.is_finite() {
            self.weather.intensity.clamp(0.0, 8.0)
        } else {
            0.0
        }
    }

    fn weather_particle_limit(&self) -> usize {
        (((self.weather_intensity() * 200.0).ceil() as usize)
            .min(self.limits.max_weather_particles))
        .min(self.limits.max_weather_particles)
    }

    /// Creates one weather particle with parameters derived from the active weather profile.
    fn spawn_particle(&mut self, width: f32, profile: WeatherProfile) -> WeatherParticle {
        let x = self.weather.next_unit() * width.max(1.0);
        let vy = lerp(
            profile.velocity_min,
            profile.velocity_max,
            self.weather.next_unit(),
        );
        let size = lerp(profile.size_min, profile.size_max, self.weather.next_unit());
        let alpha = lerp(
            profile.alpha_min,
            profile.alpha_max,
            self.weather.next_unit(),
        )
        .clamp(0.0, 1.0);
        let vx = match self.weather.weather_type {
            WeatherType::Dust | WeatherType::Leaves | WeatherType::Ash | WeatherType::Pollen => {
                (self.weather.next_unit() * 2.0 - 1.0) * size * 3.0
            }
            _ => 0.0,
        };
        WeatherParticle {
            x,
            y: -10.0,
            vx,
            vy,
            size,
            alpha,
        }
    }

    /// Starts a flash overlay with the supplied color, alpha, and duration.
    pub fn trigger_flash(&mut self, r: f32, g: f32, b: f32, a: f32, duration: f32) {
        self.sanitize();
        let duration = sanitize_duration(duration, self.flash.duration);
        let mut alpha = clamp_unit(a);
        let mut duration = duration;
        if self.time_since_last_flash.is_finite()
            && self.time_since_last_flash < (1.0 / self.accessibility_policy.max_flash_per_second)
        {
            self.diagnostics.accessibility_adjustments += 1;
            return;
        }
        if alpha > self.accessibility_policy.max_flash_alpha {
            alpha = self.accessibility_policy.max_flash_alpha;
            self.diagnostics.accessibility_adjustments += 1;
        }
        if duration > self.accessibility_policy.max_flash_duration {
            duration = self.accessibility_policy.max_flash_duration;
            self.diagnostics.accessibility_adjustments += 1;
        }
        log_msg!(
            debug,
            OV02,
            "rgba=({:.2}, {:.2}, {:.2}, {:.2}) {:.3}s",
            r,
            g,
            b,
            alpha,
            duration
        );
        self.flash.active = true;
        self.flash.color = [clamp_unit(r), clamp_unit(g), clamp_unit(b), alpha];
        self.flash.duration = duration;
        self.flash.elapsed = 0.0;
        self.time_since_last_flash = 0.0;
    }

    /// Starts a camera shake with the supplied intensity and duration.
    pub fn trigger_shake(&mut self, intensity: f32, duration: f32) {
        self.sanitize();
        let duration = sanitize_duration(duration, self.shake.duration);
        let mut intensity = if intensity.is_finite() {
            intensity.max(0.0)
        } else {
            0.0
        };
        if intensity > self.accessibility_policy.max_shake_intensity {
            intensity = self.accessibility_policy.max_shake_intensity;
            self.diagnostics.accessibility_adjustments += 1;
        }
        log_msg!(
            debug,
            OV03,
            "intensity={} duration={:.3}s",
            intensity,
            duration
        );
        self.shake.active = true;
        self.shake.intensity = intensity;
        self.shake.duration = duration;
        self.shake.elapsed = 0.0;
        self.shake.offset_x = 0.0;
        self.shake.offset_y = 0.0;
    }

    /// Starts a fade toward the supplied target alpha over the given duration.
    pub fn trigger_fade(&mut self, r: f32, g: f32, b: f32, target_alpha: f32, duration: f32) {
        self.sanitize();
        let duration = sanitize_duration(duration, self.fade.duration);
        self.fade.start_alpha = self.fade.color[3];
        self.fade.active = true;
        self.fade.color = [
            clamp_unit(r),
            clamp_unit(g),
            clamp_unit(b),
            self.fade.start_alpha,
        ];
        self.fade.target_alpha = clamp_unit(target_alpha);
        self.fade.duration = duration;
        self.fade.elapsed = 0.0;
    }

    /// Starts a short lightning flash using the configured lightning state.
    pub fn trigger_lightning(&mut self) {
        self.sanitize();
        if self.accessibility_policy.disable_lightning {
            self.diagnostics.accessibility_adjustments += 1;
            return;
        }
        self.lightning.active = true;
        self.lightning.elapsed = 0.0;
        if self.lightning.color[3] > self.accessibility_policy.max_flash_alpha {
            self.lightning.color[3] = self.accessibility_policy.max_flash_alpha;
            self.diagnostics.accessibility_adjustments += 1;
        }
        if self.lightning.duration > self.accessibility_policy.max_flash_duration {
            self.lightning.duration = self.accessibility_policy.max_flash_duration;
            self.diagnostics.accessibility_adjustments += 1;
        }
    }

    /// Returns the current camera shake offset.
    pub fn get_shake_offset(&self) -> (f32, f32) {
        (
            finite_or(self.shake.offset_x, 0.0),
            finite_or(self.shake.offset_y, 0.0),
        )
    }

    /// Returns whether any overlay subsystem is currently enabled or animating.
    pub fn is_active(&self) -> bool {
        self.weather.enabled
            || self.ambient.enabled
            || self.flash.active
            || self.shake.active
            || self.fade.active
            || self.clouds.enabled
            || self.fog.enabled
            || self.heat_haze.enabled
            || self.vignette.enabled
            || self.film_grain.enabled
            || self.lightning.active
            || self.water.enabled
            || self
                .status_stack
                .layers
                .iter()
                .any(|layer| layer.is_live())
            || self.custom_shader.is_some()
    }

    /// Restores every overlay subsystem to its default inactive state.
    pub fn clear(&mut self) {
        self.weather = WeatherState::default();
        self.ambient = AmbientState::default();
        self.flash = FlashState::default();
        self.shake = ShakeState::default();
        self.fade = FadeState::default();
        self.clouds = CloudState::default();
        self.fog = FogState::default();
        self.heat_haze = HeatHazeState::default();
        self.vignette = VignetteState::default();
        self.film_grain = FilmGrainState::default();
        self.lightning = LightningState::default();
        self.water = WaterOverlayState::default();
        self.status_stack = StatusOverlayStack::default();
        self.custom_shader = None;
        self.diagnostics = OverlayDiagnostics::default();
        self.time_since_last_flash = f32::INFINITY;
    }

    /// Copies ambient color from the given light world ambient color into this overlay.
    pub fn pull_ambient_from_light(&mut self, light_color: &crate::color::Color) {
        let (sanitized, _) = sanitize_color(
            [light_color.r, light_color.g, light_color.b, light_color.a],
            AmbientState::default().color,
        );
        self.ambient.color = sanitized;
    }

    /// Copies this overlay ambient color into the given light world ambient color.
    pub fn push_ambient_to_light(&self, light_color: &mut crate::color::Color) {
        let (sanitized, _) = sanitize_color(self.ambient.color, AmbientState::default().color);
        light_color.r = sanitized[0];
        light_color.g = sanitized[1];
        light_color.b = sanitized[2];
        light_color.a = sanitized[3];
    }

    /// Resolves overlay and light ambient colors using a named mode and writes both stores.
    pub fn sync_ambient_with_light(
        &mut self,
        light_color: &mut crate::color::Color,
        mode: &str,
    ) -> Result<(), String> {
        let (lc, _) = sanitize_color(
            [light_color.r, light_color.g, light_color.b, light_color.a],
            AmbientState::default().color,
        );
        let (oc, _) = sanitize_color(self.ambient.color, AmbientState::default().color);
        let resolved = match mode {
            "light" => lc,
            "overlay" => oc,
            "avg" => [
                (lc[0] + oc[0]) * 0.5,
                (lc[1] + oc[1]) * 0.5,
                (lc[2] + oc[2]) * 0.5,
                (lc[3] + oc[3]) * 0.5,
            ],
            "max" => [
                lc[0].max(oc[0]),
                lc[1].max(oc[1]),
                lc[2].max(oc[2]),
                lc[3].max(oc[3]),
            ],
            "min" => [
                lc[0].min(oc[0]),
                lc[1].min(oc[1]),
                lc[2].min(oc[2]),
                lc[3].min(oc[3]),
            ],
            _ => {
                return Err("Overlay:syncAmbientWithLight invalid mode; expected 'light', 'overlay', 'avg', 'max', or 'min'".to_string());
            }
        };
        self.ambient.color = resolved;
        light_color.r = resolved[0];
        light_color.g = resolved[1];
        light_color.b = resolved[2];
        light_color.a = resolved[3];
        Ok(())
    }

    /// Returns the current layer-rendering responsibility plan.
    pub fn render_plan(&self) -> OverlayRenderPlan {
        self.sanitized_clone().render_plan_inner()
    }

    fn render_plan_inner(&self) -> OverlayRenderPlan {
        let mut plan = OverlayRenderPlan::default();
        if self.get_flash_alpha() > 0.0 {
            plan.rendered.push(OverlayRenderLayer::Flash);
        }
        if self.fade.active && self.fade.color[3] > 0.0 {
            plan.rendered.push(OverlayRenderLayer::Fade);
        }
        if self.get_lightning_alpha() > 0.0 {
            plan.rendered.push(OverlayRenderLayer::Lightning);
        }
        if self.vignette.enabled && self.vignette.strength > 0.0 {
            plan.rendered.push(OverlayRenderLayer::Vignette);
        }

        if self.ambient.enabled {
            plan.externally_handled.push(OverlayRenderLayer::Ambient);
        }
        if self.weather.enabled
            && self.weather.weather_type != WeatherType::None
            && self.weather_intensity() > 0.0
        {
            plan.externally_handled.push(OverlayRenderLayer::Weather);
        }
        if self.clouds.enabled {
            plan.externally_handled.push(OverlayRenderLayer::Clouds);
        }
        if self.fog.enabled && self.fog.density > 0.0 {
            plan.externally_handled.push(OverlayRenderLayer::Fog);
        }
        if self.heat_haze.enabled && self.heat_haze.intensity > 0.0 {
            plan.externally_handled.push(OverlayRenderLayer::HeatHaze);
        }
        if self.film_grain.enabled && self.film_grain.intensity > 0.0 {
            plan.externally_handled.push(OverlayRenderLayer::FilmGrain);
        }
        if self.water.enabled {
            plan.externally_handled.push(OverlayRenderLayer::Water);
        }
        if self.custom_shader.is_some() {
            plan.externally_handled
                .push(OverlayRenderLayer::CustomShader);
        }
        let mut has_status_color = false;
        let mut has_status_texture = false;
        let mut has_status_postfx = false;
        for layer in self.status_stack.active_layers_sorted() {
            if layer.color_alpha() > 0.0 {
                has_status_color = true;
            }
            if layer.texture_alpha() > 0.0 {
                has_status_texture = true;
            }
            if layer.shader_amount() > 0.0 {
                has_status_postfx = true;
            }
        }
        if has_status_color {
            plan.rendered.push(OverlayRenderLayer::StatusColorWash);
        }
        if has_status_texture {
            plan.rendered.push(OverlayRenderLayer::StatusTexture);
        }
        if has_status_postfx {
            plan.externally_handled
                .push(OverlayRenderLayer::StatusPostFx);
        }
        plan
    }

    /// Updates the overlay target dimensions.
    pub fn resize(&mut self, width: u32, height: u32) {
        self.width = width.max(1);
        self.height = height.max(1);
    }

    /// Returns the overlay target width.
    pub fn get_width(&self) -> u32 {
        self.width
    }

    /// Returns the overlay target height.
    pub fn get_height(&self) -> u32 {
        self.height
    }

    /// Returns the overlay target dimensions as `(width, height)`.
    pub fn get_dimensions(&self) -> (u32, u32) {
        (self.width, self.height)
    }

    /// Computes the current flash alpha after time decay.
    pub fn get_flash_alpha(&self) -> f32 {
        let duration = sanitize_duration(self.flash.duration, FlashState::default().duration);
        if !self.flash.active || duration <= MIN_EFFECT_DURATION {
            return 0.0;
        }
        let elapsed = non_negative_or(self.flash.elapsed, 0.0).min(duration);
        let progress = (elapsed / duration).clamp(0.0, 1.0);
        (clamp_unit(self.flash.color[3]) * (1.0 - progress)).clamp(0.0, 1.0)
    }

    /// Computes the current lightning flash alpha after time decay.
    pub fn get_lightning_alpha(&self) -> f32 {
        let duration =
            sanitize_duration(self.lightning.duration, LightningState::default().duration);
        if !self.lightning.active || duration <= MIN_EFFECT_DURATION {
            return 0.0;
        }
        let elapsed = non_negative_or(self.lightning.elapsed, 0.0).min(duration);
        let progress = (elapsed / duration).clamp(0.0, 1.0);
        (clamp_unit(self.lightning.color[3]) * (1.0 - progress)).clamp(0.0, 1.0)
    }

    /// Returns a compact telemetry snapshot of the current overlay runtime state.
    pub fn stats(&self) -> OverlayStats {
        let sanitized = self.sanitized_clone();
        let plan = sanitized.render_plan_inner();
        let active_status_layers = sanitized
            .status_stack
            .layers
            .iter()
            .filter(|layer| layer.is_active())
            .count();
        let mut active_effects = 0_u32;
        for enabled in [
            sanitized.weather.enabled,
            sanitized.ambient.enabled,
            sanitized.flash.active,
            sanitized.shake.active,
            sanitized.fade.active,
            sanitized.clouds.enabled,
            sanitized.fog.enabled,
            sanitized.heat_haze.enabled,
            sanitized.vignette.enabled,
            sanitized.film_grain.enabled,
            sanitized.lightning.active,
            sanitized.water.enabled,
            active_status_layers > 0,
            sanitized.custom_shader.is_some(),
        ] {
            if enabled {
                active_effects += 1;
            }
        }
        OverlayStats {
            width: sanitized.width,
            height: sanitized.height,
            weather_particle_count: sanitized.weather.particles.len(),
            weather_particle_limit: sanitized.weather_particle_limit(),
            weather_intensity: sanitized.weather_intensity(),
            flash_alpha: sanitized.get_flash_alpha(),
            lightning_alpha: sanitized.get_lightning_alpha(),
            active_effects,
            weather_enabled: sanitized.weather.enabled,
            ambient_enabled: sanitized.ambient.enabled,
            fog_enabled: sanitized.fog.enabled,
            vignette_enabled: sanitized.vignette.enabled,
            weather_spawns_this_frame: self.diagnostics.weather_spawns_this_frame,
            weather_dropped_spawns: self.diagnostics.weather_dropped_spawns,
            weather_culled_particles: self.diagnostics.weather_culled_particles,
            weather_dt_spike_clamps: self.diagnostics.weather_dt_spike_clamps,
            reduced_motion: sanitized.accessibility_policy.reduced_motion,
            accessibility_adjustments: self.diagnostics.accessibility_adjustments,
            sanitized_fields: self.diagnostics.sanitized_fields,
            invalid_shader_rejections: self.diagnostics.invalid_shader_rejections,
            debug_image_rejections: self.diagnostics.debug_image_rejections,
            external_render_layers: plan.externally_handled.len(),
            status_layers: sanitized.status_stack.layers.len(),
            active_status_layers,
        }
    }

    /// Builds render commands for currently active full-screen overlay layers.
    pub fn build_render_commands(&self) -> Vec<RenderCommand> {
        let sanitized = self.sanitized_clone();
        let mut cmds = Vec::with_capacity(8);
        let width = sanitized.width as f32;
        let height = sanitized.height as f32;
        let flash_alpha = sanitized.get_flash_alpha();
        if flash_alpha > 0.0 {
            let [r, g, b, _] = sanitized.flash.color;
            cmds.push(RenderCommand::SetColor(r, g, b, flash_alpha));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: 0.0,
                y: 0.0,
                w: width,
                h: height,
            });
        }
        if sanitized.fade.active && sanitized.fade.color[3] > 0.0 {
            let [r, g, b, a] = sanitized.fade.color;
            cmds.push(RenderCommand::SetColor(r, g, b, a));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: 0.0,
                y: 0.0,
                w: width,
                h: height,
            });
        }
        let lightning_alpha = sanitized.get_lightning_alpha();
        if lightning_alpha > 0.0 {
            let [r, g, b, _] = sanitized.lightning.color;
            cmds.push(RenderCommand::SetColor(r, g, b, lightning_alpha));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: 0.0,
                y: 0.0,
                w: width,
                h: height,
            });
        }
        if sanitized.vignette.enabled && sanitized.vignette.strength > 0.0 {
            let alpha = (sanitized.vignette.strength * 0.5).clamp(0.0, 1.0);
            cmds.push(RenderCommand::SetColor(0.0, 0.0, 0.0, alpha));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: 0.0,
                y: 0.0,
                w: width,
                h: height,
            });
        }
        for layer in sanitized.status_stack.active_layers_sorted() {
            if let Some(color) = layer.visual.color {
                let alpha = layer.color_alpha();
                if alpha > 0.0 {
                    cmds.push(RenderCommand::SetColor(color[0], color[1], color[2], alpha));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: 0.0,
                        y: 0.0,
                        w: width,
                        h: height,
                    });
                }
            }
            if let Some(texture_key) = layer.visual.texture_key {
                let alpha = layer.texture_alpha();
                if alpha > 0.0 {
                    if let Some((tex_w, tex_h)) = layer.visual.texture_size {
                        let scale_x = width / tex_w.max(1) as f32;
                        let scale_y = height / tex_h.max(1) as f32;
                        cmds.push(RenderCommand::SetColor(1.0, 1.0, 1.0, alpha));
                        cmds.push(RenderCommand::DrawImageEx {
                            texture_key,
                            x: 0.0,
                            y: 0.0,
                            rotation: 0.0,
                            sx: scale_x,
                            sy: scale_y,
                            ox: 0.0,
                            oy: 0.0,
                            effect: None,
                        });
                    }
                }
            }
        }
        cmds
    }

    /// Builds built-in post-fx passes requested by active status layers.
    pub fn build_postfx_passes(&self) -> Vec<PostFxPass> {
        let sanitized = self.sanitized_clone();
        let mut passes = Vec::new();
        for layer in sanitized.status_stack.active_layers_sorted() {
            let Some(effect_name) = layer.visual.shader_effect.as_deref() else {
                continue;
            };
            let amount = layer.shader_amount();
            if amount <= 0.0 {
                continue;
            }
            let mut params = HashMap::new();
            match effect_name {
                "chromatic" => {
                    params.insert("offset".to_string(), amount.clamp(0.0, 32.0));
                }
                "blur_h" | "blur_v" => {
                    params.insert("radius".to_string(), amount.clamp(0.0, 64.0));
                    params.insert("strength".to_string(), amount.clamp(0.0, 8.0));
                }
                "waterdistort" => {
                    params.insert("amplitude".to_string(), (amount * 0.01).clamp(0.0, 1.0));
                    params.insert("frequency".to_string(), 10.0 + amount * 10.0);
                    params.insert("speed".to_string(), 1.0 + amount);
                }
                _ => {
                    params.insert("strength".to_string(), amount.clamp(0.0, 8.0));
                }
            }
            passes.push(PostFxPass {
                effect_name: effect_name.to_string(),
                params,
                shader_id: None,
                auto_uniforms: true,
            });
        }
        passes
    }

    /// Renders a debug image showing current flash, shake, and fade state.
    pub fn draw_state_to_image(&self, width: u32, height: u32) -> ImageData {
        self.try_draw_state_to_image(width, height)
            .unwrap_or_else(|_| ImageData::new(1, 1))
    }

    /// Renders a checked debug image showing current flash, shake, and fade state.
    pub fn try_draw_state_to_image(
        &self,
        width: u32,
        height: u32,
    ) -> Result<ImageData, OverlayError> {
        checked_debug_image_request(self.limits.debug_images, width, height)?;
        let sanitized = self.sanitized_clone();
        let mut img = ImageData::new(width, height);
        img.fill(15, 15, 25, 255);
        let section_h = height / 3;
        let flash_alpha = sanitized.get_flash_alpha();
        let fr = (sanitized.flash.color[0] * 255.0) as u8;
        let fg = (sanitized.flash.color[1] * 255.0) as u8;
        let fb = (sanitized.flash.color[2] * 255.0) as u8;
        let bar_w = (flash_alpha * width as f32) as u32;
        img.draw_rect(
            0,
            0,
            bar_w,
            section_h,
            fr,
            fg,
            fb,
            (flash_alpha * 200.0) as u8,
        );
        img.draw_label("FLASH", 4, 4, 220, 220, 230);
        let (sx, sy) = sanitized.get_shake_offset();
        let cy = section_h as i32 + section_h as i32 / 2;
        let cx = width as i32 / 2;
        img.draw_circle(cx + sx as i32, cy + sy as i32, 8, 80, 200, 255, 255);
        img.draw_label("SHAKE", 4, section_h as i32 + 4, 220, 220, 230);
        let fade_y = (section_h * 2) as i32;
        let fade_alpha = sanitized.fade.color[3];
        let fade_val = (fade_alpha * 255.0) as u8;
        img.draw_rect(0, fade_y, width, section_h, 0, 0, 0, fade_val);
        img.draw_label("FADE", 4, fade_y + 4, 220, 220, 230);
        Ok(img)
    }

    #[allow(clippy::too_many_arguments)]
    /// Renders a frame strip showing the time evolution of a flash overlay.
    pub fn draw_flash_sequence_to_image(
        &mut self,
        r: f32,
        g: f32,
        b: f32,
        alpha: f32,
        duration: f32,
        steps: &[f32],
        panel_w: u32,
        height: u32,
    ) -> ImageData {
        self.try_draw_flash_sequence_to_image(r, g, b, alpha, duration, steps, panel_w, height)
            .unwrap_or_else(|_| ImageData::new(1, 1))
    }

    #[allow(clippy::too_many_arguments)]
    /// Renders a checked frame strip showing the time evolution of a flash overlay.
    pub fn try_draw_flash_sequence_to_image(
        &mut self,
        r: f32,
        g: f32,
        b: f32,
        alpha: f32,
        duration: f32,
        steps: &[f32],
        panel_w: u32,
        height: u32,
    ) -> Result<ImageData, OverlayError> {
        let total_w = panel_w.checked_mul(steps.len() as u32).ok_or({
            OverlayError::DebugImageTooLarge {
                width: panel_w,
                height,
                pixels: u64::MAX,
                bytes: usize::MAX,
            }
        })?;
        if let Err(err) = checked_debug_image_request(self.limits.debug_images, total_w, height) {
            self.diagnostics.debug_image_rejections += 1;
            return Err(err);
        }
        self.trigger_flash(r, g, b, alpha, duration);
        let mut img = ImageData::new(total_w, height);
        img.fill(15, 15, 25, 255);
        for (frame, dt) in steps.iter().enumerate() {
            if *dt > 0.0 {
                self.update(*dt);
            }
            let flash_alpha = self.get_flash_alpha();
            let ox = (frame as u32 * panel_w) as i32;
            for y in 0..height {
                for x in 0..panel_w {
                    let base_r = 40u8;
                    let base_g = 60u8;
                    let base_b = 80u8;
                    let pr = (base_r as f32 + (255.0 - base_r as f32) * flash_alpha) as u8;
                    let pg = (base_g as f32 + (0.0 - base_g as f32) * flash_alpha).max(0.0) as u8;
                    let pb = (base_b as f32 + (0.0 - base_b as f32) * flash_alpha).max(0.0) as u8;
                    img.set_pixel((ox as u32) + x, y, pr, pg, pb, 255);
                }
            }
        }
        Ok(img)
    }

    /// Renders a debug image showing a series of shake offsets as a trail.
    pub fn draw_shake_trail_to_image(offsets: &[(f32, f32)], width: u32, height: u32) -> ImageData {
        Self::try_draw_shake_trail_to_image(offsets, width, height)
            .unwrap_or_else(|_| ImageData::new(1, 1))
    }

    /// Renders a checked debug image showing a series of shake offsets as a trail.
    pub fn try_draw_shake_trail_to_image(
        offsets: &[(f32, f32)],
        width: u32,
        height: u32,
    ) -> Result<ImageData, OverlayError> {
        checked_debug_image_request(OverlayImageLimits::default(), width, height)?;
        let mut img = ImageData::new(width, height);
        img.fill(15, 15, 25, 255);
        let cx = width as i32 / 2;
        let cy = height as i32 / 2;
        img.draw_line(cx - 20, cy, cx + 20, cy, 60, 60, 80, 255);
        img.draw_line(cx, cy - 20, cx, cy + 20, 60, 60, 80, 255);
        for (i, &(ox, oy)) in offsets.iter().enumerate() {
            let t = i as f32 / offsets.len().max(1) as f32;
            let r = (100.0 + t * 155.0) as u8;
            let g = (200.0 - t * 100.0) as u8;
            let px = cx + ox as i32;
            let py = cy + oy as i32;
            if px >= 0 && py >= 0 && (px as u32) < width && (py as u32) < height {
                img.draw_circle(px, py, 3, r, g, 120, 200);
            }
        }
        Ok(img)
    }

    /// Renders a frame strip showing fade alpha samples across multiple steps.
    pub fn draw_fade_transition_to_image(steps: &[f32], panel_w: u32, height: u32) -> ImageData {
        Self::try_draw_fade_transition_to_image(steps, panel_w, height)
            .unwrap_or_else(|_| ImageData::new(1, 1))
    }

    /// Renders a checked frame strip showing fade alpha samples across multiple steps.
    pub fn try_draw_fade_transition_to_image(
        steps: &[f32],
        panel_w: u32,
        height: u32,
    ) -> Result<ImageData, OverlayError> {
        let total_w = panel_w.checked_mul(steps.len() as u32).ok_or({
            OverlayError::DebugImageTooLarge {
                width: panel_w,
                height,
                pixels: u64::MAX,
                bytes: usize::MAX,
            }
        })?;
        checked_debug_image_request(OverlayImageLimits::default(), total_w, height)?;
        let mut img = ImageData::new(total_w, height);
        img.fill(15, 15, 25, 255);
        for (i, &alpha) in steps.iter().enumerate() {
            let ox = i as u32 * panel_w;
            for y in 0..height {
                for x in 0..panel_w {
                    let base = 180u8;
                    let v = (base as f32 * (1.0 - alpha.clamp(0.0, 1.0))) as u8;
                    img.set_pixel(ox + x, y, v, v, v, 255);
                }
            }
        }
        Ok(img)
    }

    /// Renders a debug panel previewing flash, shake, fade, and lightning triggers.
    pub fn draw_trigger_panel_to_image(&mut self, width: u32, height: u32) -> ImageData {
        self.try_draw_trigger_panel_to_image(width, height)
            .unwrap_or_else(|_| ImageData::new(1, 1))
    }

    /// Renders a checked debug panel previewing flash, shake, fade, and lightning triggers.
    pub fn try_draw_trigger_panel_to_image(
        &mut self,
        width: u32,
        height: u32,
    ) -> Result<ImageData, OverlayError> {
        if let Err(err) = checked_debug_image_request(self.limits.debug_images, width, height) {
            self.diagnostics.debug_image_rejections += 1;
            return Err(err);
        }
        let mut img = ImageData::new(width, height);
        img.fill(20, 18, 28, 255);
        let half_w = width / 2;
        let half_h = height / 2;
        self.trigger_flash(1.0, 0.0, 0.0, 0.8, 0.5);
        img.draw_rect(2, 2, half_w - 4, half_h - 4, 40, 10, 10, 255);
        img.draw_label("FLASH", 6, 6, 255, 80, 80);
        for dy in 0..(half_h - 30) {
            let t = 1.0 - (dy as f32 / (half_h - 30) as f32);
            let a = (t * 0.8 * 200.0) as u8;
            if a > 20 {
                for dx in 0..(half_w - 10) {
                    img.set_pixel(5 + dx, 22 + dy, 200, 20, 20, a);
                }
            }
        }
        self.clear();
        self.trigger_shake(15.0, 0.4);
        let (ox, oy) = self.get_shake_offset();
        img.draw_rect(
            half_w as i32 + 2,
            2,
            half_w - 4,
            half_h - 4,
            10,
            10,
            40,
            255,
        );
        img.draw_label("SHAKE", half_w as i32 + 6, 6, 100, 100, 255);
        let scx = half_w as i32 + half_w as i32 / 2;
        let scy = half_h as i32 / 2;
        img.draw_circle(scx, scy, 20, 40, 40, 80, 255);
        img.draw_circle(
            scx + (ox * 2.0) as i32,
            scy + (oy * 2.0) as i32,
            4,
            255,
            100,
            100,
            255,
        );
        self.clear();
        self.trigger_fade(0.0, 0.0, 0.0, 0.7, 1.0);
        img.draw_rect(
            2,
            half_h as i32 + 2,
            half_w - 4,
            half_h - 4,
            10,
            10,
            10,
            255,
        );
        img.draw_label("FADE", 6, half_h as i32 + 6, 180, 180, 200);
        for dx in 0..(half_w - 10) {
            let t = dx as f32 / (half_w - 10) as f32;
            let alpha = (t * 0.7 * 255.0) as u8;
            for dy in 0..(half_h - 30) {
                img.set_pixel(5 + dx, half_h + 22 + dy, 0, 0, 0, alpha);
            }
        }
        self.clear();
        self.trigger_lightning();
        img.draw_rect(
            half_w as i32 + 2,
            half_h as i32 + 2,
            half_w - 4,
            half_h - 4,
            20,
            20,
            30,
            255,
        );
        img.draw_label(
            "LIGHTNING",
            half_w as i32 + 6,
            half_h as i32 + 6,
            220,
            220,
            255,
        );
        for dy in 0..(half_h - 30) {
            for dx in 0..(half_w - 10) {
                let flash = 200u8.saturating_sub((dy * 2) as u8);
                img.set_pixel(
                    half_w + 5 + dx,
                    half_h + 22 + dy,
                    flash,
                    flash,
                    flash + 40,
                    180,
                );
            }
        }
        self.clear();
        Ok(img)
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
    if next_texture_opacity != layer.visual.texture_opacity || !layer.visual.texture_opacity.is_finite()
    {
        layer.visual.texture_opacity = next_texture_opacity;
        changed += 1;
    }
    let next_shader_strength = non_negative_or(layer.visual.shader_strength, 1.0);
    if next_shader_strength != layer.visual.shader_strength || !layer.visual.shader_strength.is_finite()
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

fn lerp(a: f32, b: f32, t: f32) -> f32 {
    a + (b - a) * t.clamp(0.0, 1.0)
}
