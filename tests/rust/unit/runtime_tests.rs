//! File: tests/rust/unit/runtime_tests.rs

use lurek2d::image::TextureColorSpace;
use lurek2d::render::{Canvas, Shader, TextureData};
use lurek2d::runtime::config::ModulesConfig;
use lurek2d::runtime::{Config, RuntimeMode, SharedState};
use lurek2d::window;
use std::path::PathBuf;

mod touch_canvas_tests {
    use super::*;

    #[test]
    fn touch_canvas_records_frame() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        let key = st.canvases.insert(lurek2d::render::Canvas::new(16, 16));
        st.frame_counter = 42;
        st.touch_canvas(key);
        assert_eq!(st.canvas_last_used.get(&key).copied(), Some(42));
    }

    #[test]
    fn touch_canvas_overwrites_older_frame() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        let key = st.canvases.insert(lurek2d::render::Canvas::new(16, 16));
        st.frame_counter = 1;
        st.touch_canvas(key);
        st.frame_counter = 99;
        st.touch_canvas(key);
        assert_eq!(st.canvas_last_used.get(&key).copied(), Some(99));
    }
}

mod config_tests {
    use super::*;

    #[test]
    fn config_default_uses_gui_runtime_defaults() {
        let config = Config::default();

        assert_eq!(config.runtime.mode, RuntimeMode::Gui);
        assert_eq!(config.window.width, 800);
        assert_eq!(config.window.height, 600);
        assert_eq!(config.window.scale_mode, "none");
        assert!(config.window.vsync);
        assert_eq!(config.render.backend, "auto");
        assert_eq!(config.render.default_font_size, 8);
        assert!(config.modules.runtime);
        assert!(config.modules.window);
    }

    #[test]
    fn apply_headless_profile_disables_windowed_modules_only() {
        let mut modules = ModulesConfig {
            audio: true,
            dsp: true,
            physics: true,
            render: true,
            input: true,
            timer: true,
            filesystem: true,
            window: true,
            particle: true,
            image: true,
            ui: true,
            effect: true,
            overlay: true,
            tilemap: true,
            scene: true,
            save: true,
            ecs: true,
            ai: true,
            agent: true,
            learning: true,
            pathfind: true,
            layout: true,
            thread: true,
            flownet: true,
            binary: true,
            compute: true,
            minimap: true,
            mods: true,
            pipeline: true,
            runtime: true,
            i18n: true,
            debug: true,
            animation: true,
            tween: true,
            camera: true,
            network: true,
            procgen: true,
            province: true,
            raycaster: true,
            spine: true,
            terminal: true,
            parallax: true,
            globe: true,
            visibility: true,
            cursor: true,
            grep: true,
            mapblock: true,
            validator: true,
        };

        modules.apply_headless_profile();

        assert!(!modules.audio);
        assert!(!modules.render);
        assert!(!modules.input);
        assert!(!modules.window);
        assert!(!modules.ui);
        assert!(!modules.animation);
        assert!(!modules.terminal);
        assert!(!modules.globe);
        assert!(modules.physics);
        assert!(modules.runtime);
        assert!(modules.filesystem);
        assert!(modules.network);
    }

    #[test]
    fn validate_and_fix_disables_invalid_dependencies() {
        let mut modules = ModulesConfig {
            audio: false,
            dsp: true,
            physics: true,
            render: false,
            input: true,
            timer: true,
            filesystem: true,
            window: true,
            particle: true,
            image: true,
            ui: true,
            effect: true,
            overlay: true,
            tilemap: true,
            scene: true,
            save: true,
            ecs: true,
            ai: true,
            agent: true,
            learning: true,
            pathfind: true,
            layout: true,
            thread: true,
            flownet: true,
            binary: true,
            compute: true,
            minimap: true,
            mods: true,
            pipeline: true,
            runtime: true,
            i18n: true,
            debug: true,
            animation: false,
            tween: true,
            camera: true,
            network: false,
            procgen: true,
            province: true,
            raycaster: true,
            spine: true,
            terminal: true,
            parallax: true,
            globe: true,
            visibility: true,
            cursor: true,
            grep: true,
            mapblock: true,
            validator: true,
        };

        modules.validate_and_fix();

        assert!(!modules.dsp);
        assert!(!modules.agent);
        assert!(!modules.minimap);
        assert!(!modules.particle);
        assert!(!modules.ui);
        assert!(!modules.effect);
        assert!(!modules.overlay);
        assert!(!modules.parallax);
        assert!(!modules.terminal);
        assert!(!modules.animation);
        assert!(!modules.tilemap);
        assert!(!modules.raycaster);
        assert!(!modules.camera);
        assert!(!modules.globe);
        assert!(!modules.spine);
        assert!(modules.runtime);
    }
}

mod shared_state_tests {
    use super::*;

    fn insert_texture(
        st: &mut SharedState,
        width: u32,
        height: u32,
    ) -> lurek2d::runtime::resource_keys::TextureKey {
        st.textures.insert(TextureData {
            pixels: vec![255; (width * height * 4) as usize],
            width,
            height,
            color_space: TextureColorSpace::Srgb,
        })
    }

    fn sample_shader() -> Shader {
        Shader::new(
            r#"
@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
) -> @location(0) vec4<f32> {
    return color + vec4<f32>(uv, 0.0, 0.0);
}
"#
            .to_string(),
        )
        .expect("valid test shader")
    }

    #[test]
    fn default_pending_config_reload_is_false() {
        let st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        assert!(!st.pending_config_reload);
    }

    #[test]
    fn pending_config_reload_can_be_set_and_cleared() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        st.pending_config_reload = true;
        assert!(st.pending_config_reload);
        st.pending_config_reload = false;
        assert!(!st.pending_config_reload);
    }

    #[test]
    fn step_timer_updates_public_timing_fields() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));

        let dt = st.step_timer();

        assert_eq!(st.frame_counter, 1);
        assert_eq!(st.delta_time, dt);
        assert!(st.total_time >= 0.0);
        assert!(st.fps >= 0.0);
    }

    #[test]
    fn resource_memory_stats_reports_texture_canvas_and_shader_usage() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        st.resource_budget_bytes = 1024;
        insert_texture(&mut st, 2, 3);
        st.canvases.insert(Canvas::new(4, 5));
        st.shaders.insert(sample_shader());

        let stats = st.resource_memory_stats();

        assert_eq!(stats.texture_bytes, 24);
        assert_eq!(stats.canvas_bytes, 80);
        assert_eq!(stats.texture_count, 1);
        assert_eq!(stats.canvas_count, 1);
        assert_eq!(stats.shader_count, 1);
        assert_eq!(stats.font_count, 0);
        assert_eq!(stats.budget_bytes, 1024);
        assert_eq!(
            stats.total_bytes,
            stats.texture_bytes + stats.font_bytes + stats.canvas_bytes + stats.shader_bytes
        );
    }

    #[test]
    fn evict_lru_resources_removes_oldest_textures_until_budget_fits() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        let oldest = insert_texture(&mut st, 4, 4);
        let newest = insert_texture(&mut st, 2, 2);
        st.resource_budget_bytes = 32;
        st.frame_counter = 1;
        st.touch_texture(oldest);
        st.frame_counter = 10;
        st.touch_texture(newest);

        st.evict_lru_resources();

        assert!(st.textures.get(oldest).is_none());
        assert!(st.textures.get(newest).is_some());
        assert!(!st.texture_last_used.contains_key(&oldest));
        assert!(st.texture_last_used.contains_key(&newest));
        assert_eq!(st.resource_memory_stats().total_bytes, 16);
        assert!(!st.released_texture_handles.is_empty());
    }

    #[test]
    fn focus_marks_deferred_focus_request() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));

        window::focus(&mut st.window_state);

        assert!(st.window_state.pending_focus);
    }
}
