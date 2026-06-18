//! `src/cursor/config.rs` owns the shared configuration schema for enabling cursor trail, zoom, rules, and idle hiding.
//! It defines `CursorConfig`, keeping top-level cursor feature toggles and idle timeout settings in one small owner.
//! Read this file when startup defaults or project-level cursor feature flags need to change for the runtime.

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
