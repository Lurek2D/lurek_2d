//! - Runtime configuration types parsed from `conf.toml` at engine startup.
//! - Top-level `Config` struct with sections for window, renderer, modules, and performance.
//! - Feature-toggle table (`ModulesConfig`) controlling which engine subsystems are loaded.
//! - Dependency validation that auto-disables modules when prerequisites are off.
//! - TOML merge logic: user overrides are layered on top of built-in defaults.
//! - Serde-based serialization for round-trip configuration persistence.

#[allow(unused_imports)]
use crate::log_msg;
use crate::runtime::log_messages::{
    L050_MODULE_DEP_DISABLED, L051_CONF_READ_ERR, L052_CONF_PARSE_ERR,
};
use crate::runtime::mode::RuntimeMode;
use serde::{Deserialize, Serialize};
use std::path::Path;
#[derive(Debug, Clone, Serialize, Deserialize)]
/// Top-level runtime configuration consumed during engine startup.
pub struct Config {
    /// Runtime mode selection and mode-level startup behavior.
    pub runtime: RuntimeConfig,
    /// Window and presentation settings.
    pub window: WindowConfig,
    /// Renderer backend selection and adapter preferences.
    pub render: RenderConfig,
    /// Per-module enable flags.
    pub modules: ModulesConfig,
    /// Frame pacing and callback timing settings.
    pub performance: PerformanceConfig,
    /// Terminal-grid runtime defaults reserved for the TUI mode.
    pub tui: TuiConfig,
    /// GUI-rendered REPL runtime defaults reserved for the CLI mode.
    pub cli: CliConfig,
    /// No-window Lua runtime defaults.
    pub headless: HeadlessConfig,
    /// Optional filesystem identity string used by save/runtime systems.
    pub identity: Option<String>,
    /// Optional game or package version tag.
    pub version: Option<String>,
    /// Optional custom path for runtime log file output.
    pub log_file: Option<String>,
    /// Append mode flag for log file writes.
    pub log_append: bool,
    /// Optional log level override.
    pub log_level: Option<String>,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
/// Runtime mode configuration loaded from `[runtime]`.
pub struct RuntimeConfig {
    /// Selected startup mode; CLI flags override this value.
    pub mode: RuntimeMode,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
/// Renderer backend configuration.
pub struct RenderConfig {
    /// Requested backend name.
    pub backend: String,
    /// Requested adapter power preference.
    pub power_preference: String,
    /// Requested built-in default font point size for render text.
    pub default_font_size: u32,
    /// Requested built-in bold variant for the default render font.
    pub default_font_bold: bool,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
/// Window and viewport configuration.
pub struct WindowConfig {
    /// Initial window width in pixels.
    pub width: u32,
    /// Initial window height in pixels.
    pub height: u32,
    /// Initial window title.
    pub title: String,
    /// Startup vsync flag.
    pub vsync: bool,
    /// Startup fullscreen flag.
    pub fullscreen: bool,
    /// Window resizable flag.
    pub resizable: bool,
    /// Optional minimum window width in pixels.
    pub min_width: Option<u32>,
    /// Optional minimum window height in pixels.
    pub min_height: Option<u32>,
    /// Borderless-window flag.
    pub borderless: bool,
    /// Optional window icon path.
    pub icon: Option<String>,
    /// Preferred display index for startup placement.
    pub display_index: u32,
    /// Game-space scaling mode.
    pub scale_mode: String,
    /// Optional logical game width used by viewport scaling.
    pub game_width: Option<u32>,
    /// Optional logical game height used by viewport scaling.
    pub game_height: Option<u32>,
    /// Startup maximized flag.
    pub maximized: bool,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
/// Terminal-grid mode defaults used by GUI-backed TUI startup.
pub struct TuiConfig {
    /// Number of terminal columns.
    pub cols: u32,
    /// Number of terminal rows.
    pub rows: u32,
    /// Cell width in pixels.
    pub cell_width: u32,
    /// Cell height in pixels.
    pub cell_height: u32,
    /// Optional monospace font path.
    pub font: Option<String>,
    /// Requested terminal font size.
    pub font_size: u32,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
/// GUI-rendered interactive Lua REPL defaults used by CLI startup.
pub struct CliConfig {
    /// Number of terminal columns.
    pub cols: u32,
    /// Number of terminal rows.
    pub rows: u32,
    /// Cell width in pixels.
    pub cell_width: u32,
    /// Cell height in pixels.
    pub cell_height: u32,
    /// Maximum REPL history entries retained by default.
    pub max_history: usize,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
/// Headless runtime defaults for callback stepping.
pub struct HeadlessConfig {
    #[serde(default)]
    /// Optional number of process frames to execute after init and ready.
    pub frames: Option<u32>,
    /// Delta time passed to headless frame callbacks.
    pub dt: f64,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
/// Feature-toggle table for engine modules.
pub struct ModulesConfig {
    /// Enable audio module.
    pub audio: bool,
    /// Enable physics module.
    pub physics: bool,
    /// Enable render module.
    pub render: bool,
    /// Enable input module.
    pub input: bool,
    /// Enable timer module.
    pub timer: bool,
    /// Enable filesystem module.
    pub filesystem: bool,
    /// Enable window module.
    pub window: bool,
    /// Enable particle module.
    pub particle: bool,
    /// Enable image module.
    pub image: bool,
    /// Enable UI module.
    pub ui: bool,
    /// Enable effect module.
    pub effect: bool,
    /// Enable tilemap module.
    pub tilemap: bool,
    /// Enable scene module.
    pub scene: bool,
    /// Enable save module.
    pub save: bool,
    /// Enable ECS module.
    pub ecs: bool,
    /// Enable AI module.
    pub ai: bool,
    /// Enable pathfinding module.
    pub pathfind: bool,
    /// Enable threading module.
    pub thread: bool,
    /// Enable graph module.
    pub graph: bool,
    /// Enable data module.
    pub data: bool,
    /// Enable compute module.
    pub compute: bool,
    /// Enable minimap module.
    pub minimap: bool,
    /// Enable mods module.
    pub mods: bool,
    /// Enable pipeline module.
    pub pipeline: bool,
    /// Enable runtime module.
    pub runtime: bool,
    /// Enable i18n module.
    pub i18n: bool,
    /// Enable debug module.
    pub debug: bool,
    /// Enable animation module.
    pub animation: bool,
    /// Enable tween module.
    pub tween: bool,
    /// Enable camera module.
    pub camera: bool,
    /// Enable network module.
    pub network: bool,
    /// Enable procedural-generation module.
    pub procgen: bool,
    /// Enable raycaster module.
    pub raycaster: bool,
    /// Enable spine module.
    pub spine: bool,
    /// Enable terminal module.
    pub terminal: bool,
    /// Enable parallax module.
    pub parallax: bool,
    /// Enable globe module.
    pub globe: bool,
}
/// Dependency validation and auto-fix logic for module toggles.
impl ModulesConfig {
    /// Force module switches that must be disabled in no-window headless runtime.
    pub fn apply_headless_profile(&mut self) {
        self.audio = false;
        self.render = false;
        self.input = false;
        self.window = false;
        self.terminal = false;
        self.particle = false;
        self.effect = false;
        self.tilemap = false;
        self.ui = false;
        self.minimap = false;
        self.animation = false;
        self.tween = false;
        self.camera = false;
        self.raycaster = false;
        self.spine = false;
        self.parallax = false;
        self.globe = false;
    }
    /// Disable modules whose dependencies are not enabled and emit warnings.
    pub fn validate_and_fix(&mut self) {
        if !self.render {
            if self.minimap {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "minimap requires render");
                self.minimap = false;
            }
            if self.particle {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "particle requires render");
                self.particle = false;
            }
            if self.ui {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "ui requires render");
                self.ui = false;
            }
            if self.effect {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "effect requires render");
                self.effect = false;
            }
            if self.parallax {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "parallax requires render");
                self.parallax = false;
            }
            if self.terminal {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "terminal requires render");
                self.terminal = false;
            }
            if self.animation {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "animation requires render");
                self.animation = false;
            }
            if self.tilemap {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "tilemap requires render");
                self.tilemap = false;
            }
            if self.raycaster {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "raycaster requires render");
                self.raycaster = false;
            }
            if self.camera {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "camera requires render");
                self.camera = false;
            }
            if self.globe {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "globe requires render");
                self.globe = false;
            }
            if self.spine {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "spine requires render");
                self.spine = false;
            }
        }
        if !self.animation && self.spine {
            log_msg!(warn, L050_MODULE_DEP_DISABLED, "spine requires animation");
            self.spine = false;
        }
    }
}
#[derive(Debug, Clone, Serialize, Deserialize)]
/// Performance-related runtime configuration.
pub struct PerformanceConfig {
    /// Target frame rate for main loop pacing.
    pub target_fps: u32,
    /// Fixed physics tick rate.
    pub physics_tick_rate: u32,
    #[serde(default)]
    /// Optional fixed-update callback rate.
    pub fixed_update_tick_rate: Option<u32>,
    #[serde(default)]
    /// Optional frame-time warning threshold in milliseconds.
    pub frame_budget_warn_ms: Option<f32>,
    #[serde(default)]
    /// Optional Lua callback timeout in milliseconds.
    pub lua_callback_timeout_ms: Option<f32>,
}
/// Provides default runtime configuration values when no config file is present.
impl Default for Config {
    /// Build default runtime configuration.
    fn default() -> Self {
        Config {
            runtime: RuntimeConfig {
                mode: RuntimeMode::Gui,
            },
            window: WindowConfig {
                width: 800,
                height: 600,
                title: if cfg!(debug_assertions) {
                    "Lurek2D [DEBUG]".to_string()
                } else {
                    "Lurek2D".to_string()
                },
                vsync: true,
                fullscreen: false,
                resizable: false,
                min_width: None,
                min_height: None,
                borderless: false,
                icon: None,
                display_index: 0,
                scale_mode: "none".to_string(),
                game_width: None,
                game_height: None,
                maximized: false,
            },
            render: RenderConfig {
                backend: "auto".to_string(),
                power_preference: "high".to_string(),
                default_font_size: 8,
                default_font_bold: false,
            },
            modules: ModulesConfig {
                audio: true,
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
                tilemap: true,
                scene: true,
                save: true,
                ecs: true,
                ai: true,
                pathfind: true,
                thread: true,
                graph: true,
                data: true,
                compute: true,
                minimap: true,
                mods: true,
                pipeline: true,
                runtime: true,
                i18n: true,
                debug: cfg!(debug_assertions),
                animation: true,
                tween: true,
                camera: true,
                network: true,
                procgen: true,
                raycaster: true,
                spine: true,
                terminal: true,
                parallax: true,
                globe: true,
            },
            performance: PerformanceConfig {
                target_fps: 60,
                physics_tick_rate: 60,
                fixed_update_tick_rate: None,
                frame_budget_warn_ms: None,
                lua_callback_timeout_ms: None,
            },
            tui: TuiConfig {
                cols: 80,
                rows: 25,
                cell_width: 10,
                cell_height: 20,
                font: None,
                font_size: 16,
            },
            cli: CliConfig {
                cols: 100,
                rows: 30,
                cell_width: 10,
                cell_height: 20,
                max_history: 200,
            },
            headless: HeadlessConfig {
                frames: None,
                dt: 1.0 / 60.0,
            },
            identity: None,
            version: None,
            log_file: None,
            log_append: false,
            log_level: None,
        }
    }
}
/// Loading and merging logic for runtime configuration files.
impl Config {
    /// Load configuration, preferring `conf.toml` when it exists in `game_dir`.
    pub fn load(game_dir: &Path) -> (Self, Option<String>) {
        let toml_path = game_dir.join("conf.toml");
        if toml_path.exists() {
            return Self::load_from_conf_toml(game_dir);
        }
        (Config::default(), None)
    }
    /// Parse `conf.toml`, merge it over defaults, and return config with optional parse error.
    pub fn load_from_conf_toml(game_dir: &Path) -> (Self, Option<String>) {
        let conf_path = game_dir.join("conf.toml");
        let default = Config::default();
        if !conf_path.exists() {
            return (default, None);
        }
        let text = match std::fs::read_to_string(&conf_path) {
            Ok(c) => c,
            Err(e) => {
                log_msg!(warn, L051_CONF_READ_ERR, "{}", e);
                return (default, Some(format!("Failed to read conf.toml: {}", e)));
            }
        };
        let override_val = match toml::from_str::<toml::Value>(&text) {
            Ok(v) => v,
            Err(e) => {
                log_msg!(warn, L052_CONF_PARSE_ERR, "{}", e);
                return (default, Some(format!("Error in conf.toml: {}", e)));
            }
        };
        let default_text = match toml::to_string(&default) {
            Ok(s) => s,
            Err(_) => return (default, None),
        };
        let mut merged: toml::Value =
            toml::from_str(&default_text).unwrap_or(toml::Value::Table(toml::Table::new()));
        if let (toml::Value::Table(base), toml::Value::Table(over_)) = (&mut merged, override_val) {
            for (k, v) in over_ {
                if let (Some(toml::Value::Table(base_tbl)), toml::Value::Table(over_tbl)) =
                    (base.get_mut(&k), v.clone())
                {
                    for (sk, sv) in over_tbl {
                        base_tbl.insert(sk, sv);
                    }
                } else {
                    base.insert(k, v);
                }
            }
        }
        match merged.try_into::<Config>() {
            Ok(cfg) => (cfg, None),
            Err(e) => {
                log_msg!(warn, L052_CONF_PARSE_ERR, "{}", e);
                (default, Some(format!("Error in conf.toml: {}", e)))
            }
        }
    }
}
