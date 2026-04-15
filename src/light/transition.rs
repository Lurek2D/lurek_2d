//! Smooth linear transition for light color, intensity, and radius.

/// Linearly interpolates a [`super::Light2D`]'s color, intensity, and radius
/// from their current values to target values over a fixed duration.
///
/// Lives in the Lua API wrapper (`LuaLight`) — the domain `Light2D` is not
/// modified at construction time.  Each frame the host calls
/// [`LightTransition::update`]; the returned tuple is applied to the light via
/// normal `Light2D` setters.
#[derive(Clone)]
pub struct LightTransition {
    /// Starting RGBA color `[r, g, b, a]` (values in `0.0..=1.0`).
    pub from_color: [f32; 4],
    /// Target RGBA color.
    pub to_color: [f32; 4],
    /// Starting intensity.
    pub from_intensity: f32,
    /// Target intensity.
    pub to_intensity: f32,
    /// Starting radius.
    pub from_radius: f32,
    /// Target radius.
    pub to_radius: f32,
    /// Total duration in seconds.
    pub duration: f32,
    /// Time elapsed since the transition started.
    pub elapsed: f32,
    /// `true` while the transition is running.
    pub active: bool,
}

impl LightTransition {
    /// Creates a new `LightTransition` starting from the given snapshot of the
    /// light's current state.
    ///
    /// # Parameters
    /// - `from_color` — starting RGBA `[r, g, b, a]`.
    /// - `to_color`   — target RGBA `[r, g, b, a]`.
    /// - `from_intensity` / `to_intensity` — intensity range.
    /// - `from_radius`    / `to_radius`    — radius range.
    /// - `duration`   — transition length in seconds.
    pub fn new(
        from_color: [f32; 4],
        to_color: [f32; 4],
        from_intensity: f32,
        to_intensity: f32,
        from_radius: f32,
        to_radius: f32,
        duration: f32,
    ) -> Self {
        LightTransition {
            from_color,
            to_color,
            from_intensity,
            to_intensity,
            from_radius,
            to_radius,
            duration: duration.max(1e-6),
            elapsed: 0.0,
            active: true,
        }
    }

    /// Advances the transition by `dt` seconds and returns the current
    /// `(color, intensity, radius)` snapshot, or `None` when the transition
    /// has completed.
    pub fn update(&mut self, dt: f32) -> Option<([f32; 4], f32, f32)> {
        if !self.active {
            return None;
        }
        self.elapsed += dt;
        let t = if self.elapsed >= self.duration {
            self.active = false;
            1.0_f32
        } else {
            (self.elapsed / self.duration).clamp(0.0, 1.0)
        };
        let lerp = |a: f32, b: f32| a + (b - a) * t;
        let color = [
            lerp(self.from_color[0], self.to_color[0]),
            lerp(self.from_color[1], self.to_color[1]),
            lerp(self.from_color[2], self.to_color[2]),
            lerp(self.from_color[3], self.to_color[3]),
        ];
        Some((color, lerp(self.from_intensity, self.to_intensity), lerp(self.from_radius, self.to_radius)))
    }

    /// Returns the fractional progress `[0, 1]` of the transition.
    pub fn progress(&self) -> f32 {
        if self.duration <= 0.0 {
            1.0
        } else {
            (self.elapsed / self.duration).clamp(0.0, 1.0)
        }
    }
}
