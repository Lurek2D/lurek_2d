//! - Compact descriptor for post-processing steps in a shader pipeline.
//! - Stores effect names, enable flags, and float parameter values.
//! - Allows post-fx filters to be dynamically updated without custom struct layouts.
//! - Serves as the control interface for full-screen post-processing effects.

use std::collections::HashMap;
/// One named shader pass in a post-processing chain; carries float uniform parameters.
#[derive(Debug, Clone)]
pub struct ShaderPassDescriptor {
    /// Registered shader effect name used to look up the WGSL pass.
    pub effect_name: String,
    /// Float uniform values keyed by parameter name.
    pub params: HashMap<String, f32>,
    /// When false, the pass is skipped during post-fx execution.
    pub enabled: bool,
}
impl ShaderPassDescriptor {
    /// Create an enabled pass for `effect_name` with an empty parameter map.
    pub fn new(effect_name: impl Into<String>) -> Self {
        Self {
            effect_name: effect_name.into(),
            params: HashMap::new(),
            enabled: true,
        }
    }
}
