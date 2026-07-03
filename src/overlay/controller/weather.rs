//! Owns the overlay controller weather implementation for the overlay subsystem and keeps related runtime rules local here.
//! Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
//! Defines how overlay controller weather data is validated, transformed, or stored before neighboring systems consume it.
//! Separates overlay controller weather behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.

use super::*;

impl Overlay {
    /// Advances particle spawn and movement for the active weather mode.
    pub(super) fn update_weather(&mut self, dt: f32) {
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

    /// Returns the clamped weather intensity used for spawn budgeting and motion scaling.
    pub(super) fn weather_intensity(&self) -> f32 {
        if self.weather.intensity.is_finite() {
            self.weather.intensity.clamp(0.0, 8.0)
        } else {
            0.0
        }
    }

    /// Returns the particle cap derived from current intensity and configured hard limits.
    pub(super) fn weather_particle_limit(&self) -> usize {
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
}
