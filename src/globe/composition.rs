//! Provides split-view globe composition that merges multiple named views into one render batch. `globe/composition` delivers the composition implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Applies per-entry viewport centers while preserving each globe's camera-relative projection behavior. The file owns or coordinates data contracts including `SplitViewport`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Delivers multi-panel frame assembly for comparative or tactical map presentation. Public callable behavior is centered on `emit_split_frame`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

use crate::globe::draw::emit_globe_frame;
use crate::globe::registry::GlobeRegistry;
use crate::render::renderer::RenderCommand;
use crate::runtime::resource_keys::FontKey;
/// Screen center override for one split viewport.
#[derive(Debug, Clone, Copy)]
pub struct SplitViewport {
    /// Screen center x coordinate for the viewport.
    pub cx: f32,
    /// Screen center y coordinate for the viewport.
    pub cy: f32,
}
/// Emit render commands for several globes with per-entry viewport centers.
pub fn emit_split_frame(
    reg: &GlobeRegistry,
    entries: &[(&str, SplitViewport)],
    font: Option<FontKey>,
) -> Vec<RenderCommand> {
    let mut out = Vec::new();
    for (name, vp) in entries {
        if let Some(globe) = reg.get(name) {
            let mut clone = globe.camera.clone();
            clone.screen_cx = vp.cx;
            clone.screen_cy = vp.cy;
            let mut g = emit_globe_frame(
                &globe.spec,
                &clone,
                &globe.graph,
                &globe.fog,
                &globe.markers,
                &globe.labels,
                &globe.layers,
                &globe.heat_layers,
                &globe.arcs,
                globe.active_viewer.as_deref(),
                font,
                globe.sim_time_sec,
            );
            out.append(&mut g);
        }
    }
    out
}
