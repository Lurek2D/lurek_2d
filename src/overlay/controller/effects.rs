//! Owns the overlay controller effects implementation for the overlay subsystem and keeps related runtime rules local here.
//! Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
//! Defines how overlay controller effects data is validated, transformed, or stored before neighboring systems consume it.
//! Separates overlay controller effects behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing overlay controller effects defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near overlay controller effects state that explains them instead of outward.

use super::*;

impl Overlay {
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
            || self.status_stack.layers.iter().any(|layer| layer.is_live())
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
}
