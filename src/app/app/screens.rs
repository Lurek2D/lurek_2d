//! Owns the app app screens implementation for the app subsystem and keeps related runtime rules local here.
//! Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
//! Defines how app app screens data is validated, transformed, or stored before neighboring systems consume it.
//! Separates app app screens behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where app code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing app app screens defaults, lifecycle handling, validation, or data ownership rules.

use super::*;

impl LurekApp {
    /// Render the splash screen with embedded branding and drag-drop hint.
    pub(super) fn render_splash(&mut self) {
        let (Some(renderer), Some(surface)) = (&mut self.renderer, &self.surface) else {
            return;
        };
        let total_time = self
            .state
            .as_ref()
            .map_or(0.0, |s| s.borrow().clock.total());
        if self.engine_fonts.is_none() {
            let mut fonts: SlotMap<FontKey, crate::font::Font> = SlotMap::with_key();
            let all = crate::font::Font::load_all_sizes();
            let title_idx = crate::font::Font::nearest_size(36);
            let small_idx = crate::font::Font::nearest_size(18);
            let mut title_key = None;
            let mut small_key = None;
            for (i, (font, _cw, _ch)) in all.into_iter().enumerate() {
                let key = fonts.insert(font);
                if i == title_idx {
                    title_key = Some(key);
                }
                if i == small_idx {
                    small_key = Some(key);
                }
            }
            let tk = title_key.expect("embedded bitmap fonts");
            let sk = small_key.expect("embedded bitmap fonts");
            self.engine_fonts = Some((fonts, tk, sk));
        }
        let (splash_fonts, _title_key, small_key) = self
            .engine_fonts
            .as_mut()
            .expect("engine_fonts initialized above");
        if self.splash_branding.is_none() && !self.splash_branding_failed {
            self.splash_branding = load_splash_branding();
            self.splash_branding_failed = self.splash_branding.is_none();
        }
        let branding = self.splash_branding.as_ref();
        let cmds = make_splash_commands(
            renderer.width,
            renderer.height,
            *small_key,
            splash_fonts,
            branding,
            self.drag_hover,
        );
        let bg = [0.12, 0.08, 0.20, 1.0];
        let no_batches: SlotMap<SpriteBatchKey, crate::sprite::SpriteBatch> = SlotMap::with_key();
        let no_shapes: SlotMap<ShapeKey, crate::render::CompoundShape> = SlotMap::with_key();
        let no_canvases: SlotMap<CanvasKey, crate::render::Canvas> = SlotMap::with_key();
        let empty_textures: SlotMap<TextureKey, TextureData> = SlotMap::with_key();
        let no_meshes: SlotMap<MeshKey, crate::render::Mesh> = SlotMap::with_key();
        let no_shaders: SlotMap<ShaderKey, crate::render::Shader> = SlotMap::with_key();
        let default_filter = ("linear".to_string(), "linear".to_string(), 1);
        let no_lights = crate::light::light_world::LightWorld::new();
        let no_province_registries = std::collections::HashMap::new();
        let splash_textures = branding.map_or(&empty_textures, |assets| &assets.textures);
        if let Err(e) = renderer.render_frame(
            surface,
            &cmds,
            &no_province_registries,
            splash_textures,
            splash_fonts,
            &no_lights,
            &no_batches,
            &no_shapes,
            &no_canvases,
            &no_meshes,
            &no_shaders,
            &default_filter,
            bg,
            &crate::math::Mat3::identity(),
            total_time as f32,
            0u64,
            false,
        ) {
            if e == wgpu::SurfaceError::Lost || e == wgpu::SurfaceError::Outdated {
                self.reconfigure_surface();
            }
        }
    }
    /// Render the fatal error screen overlay.
    pub(super) fn render_error(&mut self, error_screen: &ErrorScreen) {
        let (Some(renderer), Some(surface)) = (&mut self.renderer, &self.surface) else {
            return;
        };
        if let Some(state_rc) = self.state.as_ref().cloned() {
            let mut st = state_rc.borrow_mut();
            if let Some(body_key) = st.active_font.or(st.default_font) {
                let heading_slot =
                    crate::font::Font::nearest_point_size(st.default_font_size.saturating_add(6));
                let heading_key = if st.active_bold {
                    Some(body_key)
                } else {
                    st.default_bold_fonts[heading_slot].or(Some(body_key))
                };
                let cmds = error_screen.build_render_commands(
                    renderer.width,
                    renderer.height,
                    heading_key,
                    Some(body_key),
                );
                let bg = [0.11, 0.22, 0.53, 1.0];
                let no_batches: SlotMap<SpriteBatchKey, crate::sprite::SpriteBatch> =
                    SlotMap::with_key();
                let no_shapes: SlotMap<ShapeKey, crate::render::CompoundShape> =
                    SlotMap::with_key();
                let no_canvases: SlotMap<CanvasKey, crate::render::Canvas> = SlotMap::with_key();
                let no_textures: SlotMap<TextureKey, TextureData> = SlotMap::with_key();
                let no_meshes: SlotMap<MeshKey, crate::render::Mesh> = SlotMap::with_key();
                let no_shaders: SlotMap<ShaderKey, crate::render::Shader> = SlotMap::with_key();
                let default_filter = ("linear".to_string(), "linear".to_string(), 1);
                let no_lights = crate::light::light_world::LightWorld::new();
                let no_province_registries = std::collections::HashMap::new();
                let render_result = renderer.render_frame(
                    surface,
                    &cmds,
                    &no_province_registries,
                    &no_textures,
                    &mut st.fonts,
                    &no_lights,
                    &no_batches,
                    &no_shapes,
                    &no_canvases,
                    &no_meshes,
                    &no_shaders,
                    &default_filter,
                    bg,
                    &crate::math::Mat3::identity(),
                    0.0,
                    0u64,
                    false,
                );
                let should_reconfigure = matches!(
                    render_result,
                    Err(wgpu::SurfaceError::Lost | wgpu::SurfaceError::Outdated)
                );
                drop(st);
                if should_reconfigure {
                    self.reconfigure_surface();
                }
                return;
            }
        }
        if self.engine_fonts.is_none() {
            let mut fonts: SlotMap<FontKey, crate::font::Font> = SlotMap::with_key();
            let all = crate::font::Font::load_all_sizes();
            let title_idx = crate::font::Font::nearest_size(36);
            let small_idx = crate::font::Font::nearest_size(18);
            let mut title_key = None;
            let mut small_key = None;
            for (i, (font, _cw, _ch)) in all.into_iter().enumerate() {
                let key = fonts.insert(font);
                if i == title_idx {
                    title_key = Some(key);
                }
                if i == small_idx {
                    small_key = Some(key);
                }
            }
            let tk = title_key.expect("embedded bitmap fonts");
            let sk = small_key.expect("embedded bitmap fonts");
            self.engine_fonts = Some((fonts, tk, sk));
        }
        let (error_fonts, heading_key, body_key) = self
            .engine_fonts
            .as_mut()
            .expect("engine_fonts initialized above");
        let cmds = error_screen.build_render_commands(
            renderer.width,
            renderer.height,
            Some(*heading_key),
            Some(*body_key),
        );
        let bg = [0.11, 0.22, 0.53, 1.0];
        let no_batches: SlotMap<SpriteBatchKey, crate::sprite::SpriteBatch> = SlotMap::with_key();
        let no_shapes: SlotMap<ShapeKey, crate::render::CompoundShape> = SlotMap::with_key();
        let no_canvases: SlotMap<CanvasKey, crate::render::Canvas> = SlotMap::with_key();
        let no_textures: SlotMap<TextureKey, TextureData> = SlotMap::with_key();
        let no_meshes: SlotMap<MeshKey, crate::render::Mesh> = SlotMap::with_key();
        let no_shaders: SlotMap<ShaderKey, crate::render::Shader> = SlotMap::with_key();
        let default_filter = ("linear".to_string(), "linear".to_string(), 1);
        let no_lights = crate::light::light_world::LightWorld::new();
        let no_province_registries = std::collections::HashMap::new();
        if let Err(e) = renderer.render_frame(
            surface,
            &cmds,
            &no_province_registries,
            &no_textures,
            error_fonts,
            &no_lights,
            &no_batches,
            &no_shapes,
            &no_canvases,
            &no_meshes,
            &no_shaders,
            &default_filter,
            bg,
            &crate::math::Mat3::identity(),
            0.0,
            0u64,
            false,
        ) {
            if e == wgpu::SurfaceError::Lost || e == wgpu::SurfaceError::Outdated {
                self.reconfigure_surface();
            }
        }
    }
}
