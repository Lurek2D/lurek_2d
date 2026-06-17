//! Ready-made parallax layer constructors for common depth planes. `parallax/presets` delivers the presets implementation for the parallax subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Covers far background, mid background, and foreground fog presets. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Bakes scroll factor, repeat, z-order, opacity, and blend mode into each preset. Public callable behavior is centered on `far_background`, `mid_background`, `foreground_fog`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

use crate::parallax::ParallaxLayer;
use crate::render::BlendMode;
use crate::runtime::resource_keys::TextureKey;
/// Create a slow far-background layer (scroll factor ~0.15 horizontal); horizontal repeat, Z = -200, opacity 0.8.
pub fn far_background(texture_key: TextureKey, texture_w: f32, texture_h: f32) -> ParallaxLayer {
    let mut layer = ParallaxLayer::new(texture_key, texture_w, texture_h);
    layer.scroll_factor = [0.15, 0.05];
    layer.repeat_x = true;
    layer.repeat_y = false;
    layer.z = -200;
    layer.opacity = 0.8;
    layer
}
/// Create a mid-speed background layer (scroll factor ~0.45 horizontal); horizontal repeat, Z = -100, opacity 0.9.
pub fn mid_background(texture_key: TextureKey, texture_w: f32, texture_h: f32) -> ParallaxLayer {
    let mut layer = ParallaxLayer::new(texture_key, texture_w, texture_h);
    layer.scroll_factor = [0.45, 0.15];
    layer.repeat_x = true;
    layer.repeat_y = false;
    layer.z = -100;
    layer.opacity = 0.9;
    layer
}
/// Create a near-screen fog layer: fast scroll, tiled, Screen blend, 35% opacity, light motion-stretch blur, Z = 50.
pub fn foreground_fog(texture_key: TextureKey, texture_w: f32, texture_h: f32) -> ParallaxLayer {
    let mut layer = ParallaxLayer::new(texture_key, texture_w, texture_h);
    layer.scroll_factor = [0.9, 0.4];
    layer.autoscroll = [8.0, 0.0];
    layer.repeat_x = true;
    layer.repeat_y = true;
    layer.tiling = true;
    layer.opacity = 0.35;
    layer.blend_mode = BlendMode::Screen;
    layer.set_motion_stretch(true, 0.002, 1.4);
    layer.z = 50;
    layer
}
