//! Global cursor system configuration shared across the cursor manager.

/// Global cursor system configuration.
#[derive(Debug, Clone)]
pub struct CursorConfig {
    /// Whether cursor trail rendering is enabled.
    pub trail_enabled: bool,
    /// Whether cursor magnifier zoom is enabled.
    pub zoom_enabled: bool,
    /// Whether context-sensitive cursor rules are active.
    pub context_rules_enabled: bool,
    /// Whether the cursor hides after idle timeout.
    pub hide_on_idle: bool,
    /// Seconds of inactivity before the cursor hides.
    pub idle_timeout_secs: f32,
}

impl Default for CursorConfig {
    fn default() -> Self {
        Self {
            trail_enabled: false,
            zoom_enabled: false,
            context_rules_enabled: true,
            hide_on_idle: false,
            idle_timeout_secs: 3.0,
        }
    }
}
