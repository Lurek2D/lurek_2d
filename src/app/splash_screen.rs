//! This file owns minimal startup render-command generation for the desktop app.
//! It keeps the no-game screen free of embedded bitmap assets so the runtime exe stays compact.
//! Layout helpers center the footer hint and switch it when drag-and-drop is hovering.
//! The file is only about splash visuals; window creation, input handling, and frame flow stay in the main app owner.
//! Open this file when startup presentation changes; runtime orchestration and fatal fallback screens live in siblings.

use crate::render::renderer::{DrawMode, RenderCommand, TextureData};
use crate::runtime::resource_keys::{FontKey, TextureKey};
use slotmap::SlotMap;
/// Embedded splash-branding assets prepared for splash-screen rendering.
pub struct SplashBranding {
    /// Temporary texture storage; empty in the compact runtime build.
    pub textures: SlotMap<TextureKey, TextureData>,
}
/// Decode embedded icon/banner PNG assets and upload them into splash texture storage.
pub fn load_splash_branding() -> Option<SplashBranding> {
    None
}
#[allow(clippy::vec_init_then_push)]
/// Build render commands for splash screen branding and drag-and-drop hint text.
pub fn make_splash_commands(
    width: u32,
    height: u32,
    small_key: FontKey,
    fonts: &mut SlotMap<FontKey, crate::font::Font>,
    branding: Option<&SplashBranding>,
    drag_hover: bool,
) -> Vec<RenderCommand> {
    let width_f = width as f32;
    let height_f = height as f32;
    let cx = width_f / 2.0;
    let hint_text = if drag_hover {
        "Release to load game"
    } else {
        "Drop a game folder here"
    };
    let hint_w = fonts
        .get_mut(small_key)
        .map(|f| f.text_width(hint_text))
        .unwrap_or(0.0);
    let top_margin = 24.0_f32;
    let hint_band_top = height_f - 82.0;
    let mut cmds: Vec<RenderCommand> = Vec::new();
    let _ = (branding, top_margin, hint_band_top);
    if drag_hover {
        cmds.push(RenderCommand::SetColor(0.40, 0.80, 0.40, 0.15));
        cmds.push(RenderCommand::Rectangle {
            mode: DrawMode::Fill,
            x: cx - 220.0,
            y: height_f - 70.0,
            w: 440.0,
            h: 40.0,
        });
        cmds.push(RenderCommand::SetColor(0.50, 0.90, 0.50, 1.0));
    } else {
        cmds.push(RenderCommand::SetColor(0.35, 0.30, 0.45, 1.0));
    }
    cmds.push(RenderCommand::Print {
        font_key: small_key,
        text: hint_text.to_string(),
        x: cx - hint_w / 2.0,
        y: height_f - 55.0,
        scale: 1.0,
    });
    cmds
}
