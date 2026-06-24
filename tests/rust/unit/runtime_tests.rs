//! File: tests/rust/unit/runtime_tests.rs

use lurek2d::image::TextureColorSpace;
use lurek2d::render::{Canvas, Shader, TextureData};
use lurek2d::runtime::config::{ConfigLoadOptions, ConfigValidationMode, ModulesConfig};
use lurek2d::runtime::{
    call_function_with_policy, run_headless_checked, Config, EngineError, HeadlessOptions,
    LuaExecutionPolicy, RuntimeMode, SharedState,
};
use lurek2d::window;
use mlua::Lua;
use slotmap::Key;
use std::fs;
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
            tilefield: true,
            tilelight: true,
            tilemap: true,
            tileset: true,
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
            awareness: true,
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
            tilefield: true,
            tilelight: true,
            tilemap: true,
            tileset: true,
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
            awareness: true,
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

mod lua_execution_policy_tests {
    use super::*;

    #[test]
    fn shared_policy_runs_function_without_timeout_by_default() {
        let lua = Lua::new();
        let function = lua
            .load("return function(value) return value + 1 end")
            .eval::<mlua::Function>()
            .expect("function");

        let value: i64 = call_function_with_policy(
            &lua,
            "test",
            function,
            41_i64,
            LuaExecutionPolicy::default(),
        )
        .expect("call succeeds");

        assert_eq!(value, 42);
    }

    #[test]
    fn shared_policy_times_out_busy_loop() {
        let lua = Lua::new();
        let function = lua
            .load("return function() local sum = 0 for i = 1, 100000000 do sum = sum + i end return sum end")
            .eval::<mlua::Function>()
            .expect("function");

        let error = call_function_with_policy::<_, ()>(
            &lua,
            "busy",
            function,
            (),
            LuaExecutionPolicy {
                timeout_ms: Some(1.0),
                hook_instruction_interval: 1,
            },
        )
        .expect_err("long-running loop should time out");

        assert!(error.to_string().contains("exceeded Lua execution timeout"));
    }
}

mod shared_state_tests {
    use super::*;

    fn insert_texture(
        st: &mut SharedState,
        width: u32,
        height: u32,
    ) -> lurek2d::runtime::resource_keys::TextureKey {
        st.textures.insert(TextureData::new(
            vec![255; (width * height * 4) as usize],
            width,
            height,
            TextureColorSpace::Srgb,
        ))
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
    fn shared_state_validate_detects_invalid_window_and_color_state() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        let stale_canvas = st.canvases.insert(Canvas::new(16, 16));
        st.active_canvas = Some(stale_canvas);
        st.canvases.remove(stale_canvas);
        st.window_width = 0;
        st.current_color = [f32::NAN, 0.0, 0.0, 1.0];

        let report = st.validate_frame_state();

        assert!(report
            .errors
            .iter()
            .any(|entry| entry.contains("window dimensions")));
        assert!(report
            .errors
            .iter()
            .any(|entry| entry.contains("current_color")));
        assert!(report
            .errors
            .iter()
            .any(|entry| entry.contains("stale canvas")));
    }

    #[test]
    fn resource_budget_reports_non_evictable_overage() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        st.resource_budget_bytes = 64;
        let texture = insert_texture(&mut st, 4, 4);
        st.touch_texture(texture);
        st.shaders.insert(sample_shader());

        let report = st.evict_lru_resources();

        assert_eq!(report.evicted_texture_count, 1);
        assert!(report.evicted_texture_bytes > 0);
        assert!(report.non_evictable_over_budget_bytes > 0);
        assert_eq!(report.after.texture_count, 0);
    }

    #[test]
    fn released_texture_queue_does_not_grow_unbounded() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));

        for _ in 0..32 {
            let key = insert_texture(&mut st, 2, 2);
            let handle = key.data().as_ffi();
            assert!(st.release_texture(key));
            assert_eq!(st.pending_texture_release_count(), 1);
            assert!(st.ack_released_texture_handle(handle));
            assert_eq!(st.pending_texture_release_count(), 0);
        }

        assert!(st.pending_texture_releases.is_empty());
        assert!(st.released_texture_handles.is_empty());
    }

    #[test]
    fn shared_state_validate_reports_invalid_frame_profile_and_budget_warning() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        st.frame_profile.app_frame_total_ms = f32::NAN;
        st.frame_budget_warn_ms = Some(1.0);
        st.resource_budget_bytes = 1;
        st.shaders.insert(sample_shader());

        let report = st.validate_frame_state();

        assert!(report
            .warnings
            .iter()
            .any(|entry| entry.contains("frame_profile.app_frame_total_ms")));
        assert!(report
            .warnings
            .iter()
            .any(|entry| entry.contains("non-evictable bytes")));
    }

    #[test]
    fn focus_marks_deferred_focus_request() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));

        window::focus(&mut st.window_state);

        assert!(st.window_state.pending_focus);
    }
}

mod config_validation_tests {
    use super::*;

    #[test]
    fn config_load_rejects_huge_conf_toml() {
        let dir = tempfile::tempdir().expect("tempdir");
        let conf_path = dir.path().join("conf.toml");
        fs::write(&conf_path, "a".repeat(128)).expect("write conf.toml");

        let error = Config::load_from_conf_toml_with_options(
            dir.path(),
            ConfigLoadOptions {
                max_bytes: 32,
                ..ConfigLoadOptions::default()
            },
        )
        .expect_err("oversized conf.toml should be rejected");

        assert!(error.to_string().contains("exceeds max size"));
    }

    #[test]
    fn config_validate_rejects_zero_fps_and_invalid_dt() {
        let mut config = Config::default();
        config.performance.target_fps = 0;
        config.headless.dt = f64::NAN;
        config.window.width = 0;

        let report = config.validate();

        assert!(report.has_errors());
        assert!(report
            .errors
            .iter()
            .any(|entry| entry.contains("performance.target_fps")));
        assert!(report
            .errors
            .iter()
            .any(|entry| entry.contains("headless.dt")));
        assert!(report
            .errors
            .iter()
            .any(|entry| entry.contains("window.width")));
    }

    #[test]
    fn config_strict_unknown_keys_reports_nested_field() {
        let dir = tempfile::tempdir().expect("tempdir");
        let conf_path = dir.path().join("conf.toml");
        fs::write(
            &conf_path,
            r#"
                schema_version = 1
                [window]
                width = 640
                mystery = 5
            "#,
        )
        .expect("write conf.toml");

        let error = Config::load_from_conf_toml_with_options(
            dir.path(),
            ConfigLoadOptions {
                strict_unknown_keys: true,
                validation_mode: ConfigValidationMode::Strict,
                ..ConfigLoadOptions::default()
            },
        )
        .expect_err("unknown key should fail strict mode");

        assert!(error.to_string().contains("window.mystery"));
    }
}

mod headless_safety_tests {
    use super::*;

    fn headless_config(timeout_ms: f32) -> Config {
        let mut config = Config::default();
        config.runtime.mode = RuntimeMode::Headless;
        config.performance.lua_callback_timeout_ms = Some(timeout_ms);
        config.modules.apply_headless_profile();
        config
    }

    #[test]
    fn headless_eval_timeout_aborts_top_level_loop() {
        let dir = tempfile::tempdir().expect("tempdir");

        let error = run_headless_checked(
            headless_config(1.0),
            HeadlessOptions {
                game_dir: dir.path().to_path_buf(),
                explicit_game_dir: true,
                eval: vec!["while true do end".to_string()],
                frames_override: None,
            },
        )
        .expect_err("eval should time out");

        assert!(matches!(error, EngineError::LuaTimeout(message) if message.contains("--eval")));
    }

    #[test]
    fn headless_main_lua_timeout_aborts_top_level_loop() {
        let dir = tempfile::tempdir().expect("tempdir");
        fs::write(dir.path().join("main.lua"), "while true do end").expect("write main.lua");

        let error = run_headless_checked(
            headless_config(1.0),
            HeadlessOptions {
                game_dir: dir.path().to_path_buf(),
                explicit_game_dir: true,
                eval: Vec::new(),
                frames_override: None,
            },
        )
        .expect_err("main.lua should time out");

        assert!(matches!(error, EngineError::LuaTimeout(message) if message.contains("main.lua")));
    }

    #[test]
    fn headless_package_path_canonicalizes_game_dir() {
        let dir = tempfile::tempdir().expect("tempdir");
        fs::write(
            dir.path().join("main.lua"),
            r#"
                if string.find(package.path, "%.%.") or string.find(package.path, "/%./") then
                    error("package.path not canonicalized")
                end
            "#,
        )
        .expect("write main.lua");

        run_headless_checked(
            headless_config(10.0),
            HeadlessOptions {
                game_dir: dir.path().join("."),
                explicit_game_dir: true,
                eval: Vec::new(),
                frames_override: None,
            },
        )
        .expect("canonicalized game dir should run");
    }
}
