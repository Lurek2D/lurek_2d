//! Fog-of-war rendering configuration: intensity, colour, and render integration hints.

/// Configuration for how fog is rendered visually.
#[derive(Debug, Clone, Copy)]
pub struct FogConfig {
    /// Fog intensity for discovered (but not visible) regions (0.0-1.0).
    pub discovered_intensity: f32,
    /// Fog intensity for hidden regions (0.0-1.0).
    pub hidden_intensity: f32,
    /// Whether to use smooth transitions between fog states.
    pub smooth_transitions: bool,
    /// Transition speed (seconds to fade between states).
    pub transition_speed: f32,
}

impl Default for FogConfig {
    fn default() -> Self {
        Self {
            discovered_intensity: 0.5,
            hidden_intensity: 1.0,
            smooth_transitions: true,
            transition_speed: 0.5,
        }
    }
}
