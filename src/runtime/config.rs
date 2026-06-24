//! This file owns config behavior inside the runtime subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate config state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for config work.
//! Serialization, indexing, and boundary checks stay here when they depend on config internals.
//! Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
//! Open this file when config ownership changes, but keep unrelated subsystem policy in sibling modules.
//! The code favors small data transformations so examples, specs, and tests can assert behavior directly.
//! Stateful changes are kept deterministic here so generated docs and smoke tests remain reproducible.
//! Cross-module dependencies are intentionally narrow, with shared types imported only at this boundary.
//! This module documents where runtime data becomes behavior and where surrounding systems take over.
//! Maintenance work here should preserve the existing contracts before extending new config capabilities.

#[allow(unused_imports)]
use crate::log_msg;
use crate::runtime::log_messages::{
    L050_MODULE_DEP_DISABLED, L051_CONF_READ_ERR, L052_CONF_PARSE_ERR,
};
use crate::runtime::lua_execution::MAX_LUA_EXECUTION_TIMEOUT_MS;
use crate::runtime::mode::RuntimeMode;
use crate::runtime::{EngineError, EngineResult};
use serde::{Deserialize, Serialize};
use std::fs::File;
use std::io::Read;
use std::path::Path;

const DEFAULT_CONF_MAX_BYTES: u64 = 256 * 1024;
const CURRENT_CONFIG_SCHEMA_VERSION: u32 = 1;
const MAX_WINDOW_DIMENSION: u32 = 16_384;
const MAX_GAME_DIMENSION: u32 = 16_384;
const MAX_TERMINAL_DIMENSION: u32 = 4_096;
const MAX_FONT_SIZE: u32 = 512;
const MAX_HISTORY_ENTRIES: usize = 100_000;
const MAX_TICK_RATE: u32 = 1_000;
#[derive(Debug, Clone, Serialize, Deserialize)]
/// Top-level runtime configuration consumed during engine startup.
/// # Fields
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
/// # Fields
pub struct RuntimeConfig {
    /// Selected startup mode; CLI flags override this value.
    pub mode: RuntimeMode,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
/// Renderer backend configuration.
/// # Fields
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
/// # Fields
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
/// # Fields
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
/// # Fields
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
/// # Fields
pub struct HeadlessConfig {
    #[serde(default)]
    /// Optional number of process frames to execute after init and ready.
    pub frames: Option<u32>,
    /// Delta time passed to headless frame callbacks.
    pub dt: f64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
/// Validation mode applied when config values are outside supported bounds.
pub enum ConfigValidationMode {
    /// Reject invalid values instead of correcting them.
    Strict,
    #[default]
    /// Clamp or reset invalid values back into the supported range.
    Permissive,
}

#[derive(Debug, Clone, PartialEq, Eq)]
/// Options controlling bounded `conf.toml` loading and validation behavior.
pub struct ConfigLoadOptions {
    /// Maximum accepted file size in bytes for `conf.toml`.
    pub max_bytes: u64,
    /// Reject unknown keys instead of only reporting them.
    pub strict_unknown_keys: bool,
    /// Optional expected schema version from the top-level `schema_version` field.
    pub schema_version: Option<u32>,
    /// Validation behavior for known fields with unsupported values.
    pub validation_mode: ConfigValidationMode,
}

impl Default for ConfigLoadOptions {
    fn default() -> Self {
        Self {
            max_bytes: DEFAULT_CONF_MAX_BYTES,
            strict_unknown_keys: false,
            schema_version: Some(CURRENT_CONFIG_SCHEMA_VERSION),
            validation_mode: ConfigValidationMode::Permissive,
        }
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq)]
/// Structured report describing ignored keys, deprecated keys, corrected values, and errors.
pub struct ConfigReport {
    /// Unknown keys present in `conf.toml`.
    pub ignored_keys: Vec<String>,
    /// Deprecated keys accepted for compatibility.
    pub deprecated_keys: Vec<String>,
    /// Corrected values applied during permissive validation.
    pub corrected_values: Vec<String>,
    /// Hard validation failures.
    pub errors: Vec<String>,
}

impl ConfigReport {
    /// Return `true` when the report contains hard failures.
    pub fn has_errors(&self) -> bool {
        !self.errors.is_empty()
    }

    fn push_error(&mut self, message: String) {
        self.errors.push(message);
    }

    fn push_correction(&mut self, message: String) {
        self.corrected_values.push(message);
    }

    fn summary(&self) -> String {
        let mut parts = Vec::new();
        if !self.errors.is_empty() {
            parts.push(format!("errors: {}", self.errors.join("; ")));
        }
        if !self.ignored_keys.is_empty() {
            parts.push(format!("ignored keys: {}", self.ignored_keys.join(", ")));
        }
        if !self.deprecated_keys.is_empty() {
            parts.push(format!(
                "deprecated keys: {}",
                self.deprecated_keys.join(", ")
            ));
        }
        if !self.corrected_values.is_empty() {
            parts.push(format!(
                "corrected values: {}",
                self.corrected_values.join("; ")
            ));
        }
        parts.join(" | ")
    }
}

fn default_true() -> bool {
    true
}

#[derive(Debug, Clone, Serialize, Deserialize)]
/// Feature-toggle table for engine modules.
/// # Fields
pub struct ModulesConfig {
    /// Enable audio module.
    pub audio: bool,
    /// Enable dsp module.
    pub dsp: bool,
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
    /// Enable overlay module.
    pub overlay: bool,
    /// Enable tilemap module.
    pub tilemap: bool,
    /// Enable tileset module.
    #[serde(default = "default_true")]
    pub tileset: bool,
    /// Enable tilefield module.
    #[serde(default = "default_true")]
    pub tilefield: bool,
    /// Enable tile-based lighting module.
    #[serde(default = "default_true")]
    pub tilelight: bool,
    /// Enable scene module.
    pub scene: bool,
    /// Enable save module.
    pub save: bool,
    /// Enable ECS module.
    pub ecs: bool,
    /// Enable AI module.
    pub ai: bool,
    /// Enable LLM-backed agent module.
    #[serde(default = "default_true")]
    pub agent: bool,
    /// Enable learning module.
    pub learning: bool,
    /// Enable pathfinding module.
    pub pathfind: bool,
    /// Enable layout module.
    pub layout: bool,
    /// Enable threading module.
    pub thread: bool,
    /// Enable flownet module.
    #[serde(alias = "graph")]
    /// Flownet.
    pub flownet: bool,
    /// Enable binary module.
    pub binary: bool,
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
    /// Enable province module.
    pub province: bool,
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
    /// Enable awareness module.
    pub awareness: bool,
    /// Enable cursor module.
    #[serde(default)]
    pub cursor: bool,
    /// Enable grep module.
    #[serde(default)]
    pub grep: bool,
    /// Enable mapblock module.
    #[serde(default)]
    pub mapblock: bool,
    /// Enable validator module.
    #[serde(default)]
    pub validator: bool,
}
/// Dependency validation and auto-fix logic for module toggles.
impl ModulesConfig {
    /// Force module switches that must be disabled in no-window headless runtime.
    pub fn apply_headless_profile(&mut self) {
        self.audio = false;
        self.dsp = false;
        self.render = false;
        self.input = false;
        self.window = false;
        self.terminal = false;
        self.particle = false;
        self.effect = false;
        self.overlay = false;
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
        if !self.audio && self.dsp {
            log_msg!(warn, L050_MODULE_DEP_DISABLED, "dsp requires audio");
            self.dsp = false;
        }
        if !self.network && self.agent {
            log_msg!(warn, L050_MODULE_DEP_DISABLED, "agent requires network");
            self.agent = false;
        }
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
            if self.overlay {
                log_msg!(warn, L050_MODULE_DEP_DISABLED, "overlay requires render");
                self.overlay = false;
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
/// # Fields
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
                tileset: true,
                tilefield: true,
                tilelight: true,
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
                debug: cfg!(debug_assertions),
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
        match Self::load_from_conf_toml_with_options(game_dir, ConfigLoadOptions::default()) {
            Ok((config, report)) => {
                log_config_report(&report);
                (config, None)
            }
            Err(error) => {
                log_msg!(warn, L052_CONF_PARSE_ERR, "{}", error);
                (Config::default(), Some(error.to_string()))
            }
        }
    }

    /// Parse `conf.toml` with explicit loading and validation options.
    pub fn load_from_conf_toml_with_options(
        game_dir: &Path,
        options: ConfigLoadOptions,
    ) -> EngineResult<(Self, ConfigReport)> {
        let conf_path = game_dir.join("conf.toml");
        let default = Config::default();
        if !conf_path.exists() {
            return Ok((default, ConfigReport::default()));
        }
        let text = read_conf_toml_bounded(&conf_path, options.max_bytes)?;
        let override_val = toml::from_str::<toml::Value>(&text)
            .map_err(|error| EngineError::ConfigError(format!("Error in conf.toml: {}", error)))?;
        let schema = config_as_toml_value(&default)?;
        let mut report = ConfigReport::default();
        inspect_config_keys(&schema, &override_val, "", &mut report);
        validate_schema_version(&override_val, &options, &mut report);
        if options.strict_unknown_keys && !report.ignored_keys.is_empty() {
            report.push_error(format!(
                "unknown keys are not allowed in strict mode: {}",
                report.ignored_keys.join(", ")
            ));
        }
        let mut merged = schema;
        merge_toml_values(&mut merged, override_val);
        let mut config = merged
            .try_into::<Config>()
            .map_err(|error| EngineError::ConfigError(format!("Error in conf.toml: {}", error)))?;
        let validation_report = config.validate_with_mode(options.validation_mode);
        report
            .corrected_values
            .extend(validation_report.corrected_values);
        report.errors.extend(validation_report.errors);
        if report.has_errors() {
            return Err(EngineError::ConfigError(report.summary()));
        }
        Ok((config, report))
    }

    /// Validate the current configuration in strict mode.
    pub fn validate(&mut self) -> ConfigReport {
        self.validate_with_mode(ConfigValidationMode::Strict)
    }

    /// Validate the current configuration and optionally clamp invalid values.
    pub fn validate_with_mode(&mut self, mode: ConfigValidationMode) -> ConfigReport {
        let defaults = Config::default();
        let mut report = ConfigReport::default();

        validate_bounded_u32(
            "window.width",
            &mut self.window.width,
            defaults.window.width,
            1,
            MAX_WINDOW_DIMENSION,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "window.height",
            &mut self.window.height,
            defaults.window.height,
            1,
            MAX_WINDOW_DIMENSION,
            mode,
            &mut report,
        );
        validate_optional_u32(
            "window.min_width",
            &mut self.window.min_width,
            1,
            MAX_WINDOW_DIMENSION,
            mode,
            &mut report,
        );
        validate_optional_u32(
            "window.min_height",
            &mut self.window.min_height,
            1,
            MAX_WINDOW_DIMENSION,
            mode,
            &mut report,
        );
        validate_optional_u32(
            "window.game_width",
            &mut self.window.game_width,
            1,
            MAX_GAME_DIMENSION,
            mode,
            &mut report,
        );
        validate_optional_u32(
            "window.game_height",
            &mut self.window.game_height,
            1,
            MAX_GAME_DIMENSION,
            mode,
            &mut report,
        );
        validate_scale_mode(
            "window.scale_mode",
            &mut self.window.scale_mode,
            &defaults.window.scale_mode,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "render.default_font_size",
            &mut self.render.default_font_size,
            defaults.render.default_font_size,
            1,
            MAX_FONT_SIZE,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "performance.target_fps",
            &mut self.performance.target_fps,
            defaults.performance.target_fps,
            1,
            MAX_TICK_RATE,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "performance.physics_tick_rate",
            &mut self.performance.physics_tick_rate,
            defaults.performance.physics_tick_rate,
            1,
            MAX_TICK_RATE,
            mode,
            &mut report,
        );
        validate_optional_u32(
            "performance.fixed_update_tick_rate",
            &mut self.performance.fixed_update_tick_rate,
            1,
            MAX_TICK_RATE,
            mode,
            &mut report,
        );
        validate_optional_f32(
            "performance.frame_budget_warn_ms",
            &mut self.performance.frame_budget_warn_ms,
            None,
            0.0,
            f32::MAX,
            mode,
            &mut report,
        );
        validate_optional_f32(
            "performance.lua_callback_timeout_ms",
            &mut self.performance.lua_callback_timeout_ms,
            defaults.performance.lua_callback_timeout_ms,
            0.0,
            MAX_LUA_EXECUTION_TIMEOUT_MS,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "tui.cols",
            &mut self.tui.cols,
            defaults.tui.cols,
            1,
            MAX_TERMINAL_DIMENSION,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "tui.rows",
            &mut self.tui.rows,
            defaults.tui.rows,
            1,
            MAX_TERMINAL_DIMENSION,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "tui.cell_width",
            &mut self.tui.cell_width,
            defaults.tui.cell_width,
            1,
            MAX_TERMINAL_DIMENSION,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "tui.cell_height",
            &mut self.tui.cell_height,
            defaults.tui.cell_height,
            1,
            MAX_TERMINAL_DIMENSION,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "tui.font_size",
            &mut self.tui.font_size,
            defaults.tui.font_size,
            1,
            MAX_FONT_SIZE,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "cli.cols",
            &mut self.cli.cols,
            defaults.cli.cols,
            1,
            MAX_TERMINAL_DIMENSION,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "cli.rows",
            &mut self.cli.rows,
            defaults.cli.rows,
            1,
            MAX_TERMINAL_DIMENSION,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "cli.cell_width",
            &mut self.cli.cell_width,
            defaults.cli.cell_width,
            1,
            MAX_TERMINAL_DIMENSION,
            mode,
            &mut report,
        );
        validate_bounded_u32(
            "cli.cell_height",
            &mut self.cli.cell_height,
            defaults.cli.cell_height,
            1,
            MAX_TERMINAL_DIMENSION,
            mode,
            &mut report,
        );
        validate_bounded_usize(
            "cli.max_history",
            &mut self.cli.max_history,
            defaults.cli.max_history,
            1,
            MAX_HISTORY_ENTRIES,
            mode,
            &mut report,
        );
        validate_optional_u32(
            "headless.frames",
            &mut self.headless.frames,
            0,
            u32::MAX,
            mode,
            &mut report,
        );
        validate_f64(
            "headless.dt",
            &mut self.headless.dt,
            defaults.headless.dt,
            0.0,
            f64::MAX,
            mode,
            &mut report,
        );
        validate_log_level(&mut self.log_level, mode, &mut report);

        if let Some(min_width) = self.window.min_width {
            if min_width > self.window.width {
                apply_relation_error(
                    "window.min_width",
                    format!(
                        "window.min_width ({min_width}) must be <= window.width ({})",
                        self.window.width
                    ),
                    mode,
                    &mut report,
                    || self.window.min_width = Some(self.window.width),
                );
            }
        }
        if let Some(min_height) = self.window.min_height {
            if min_height > self.window.height {
                apply_relation_error(
                    "window.min_height",
                    format!(
                        "window.min_height ({min_height}) must be <= window.height ({})",
                        self.window.height
                    ),
                    mode,
                    &mut report,
                    || self.window.min_height = Some(self.window.height),
                );
            }
        }
        report
    }
}

fn read_conf_toml_bounded(conf_path: &Path, max_bytes: u64) -> EngineResult<String> {
    let mut file = File::open(conf_path).map_err(|error| {
        log_msg!(warn, L051_CONF_READ_ERR, "{}", error);
        EngineError::ConfigError(format!("Failed to read conf.toml: {}", error))
    })?;
    let metadata = file.metadata().map_err(|error| {
        log_msg!(warn, L051_CONF_READ_ERR, "{}", error);
        EngineError::ConfigError(format!("Failed to stat conf.toml: {}", error))
    })?;
    if metadata.len() > max_bytes {
        return Err(EngineError::ConfigError(format!(
            "conf.toml exceeds max size of {} bytes (got {})",
            max_bytes,
            metadata.len()
        )));
    }
    let mut text = String::with_capacity(metadata.len() as usize);
    file.read_to_string(&mut text).map_err(|error| {
        log_msg!(warn, L051_CONF_READ_ERR, "{}", error);
        EngineError::ConfigError(format!("Failed to read conf.toml: {}", error))
    })?;
    if text.len() as u64 > max_bytes {
        return Err(EngineError::ConfigError(format!(
            "conf.toml exceeds max size of {} bytes after read",
            max_bytes
        )));
    }
    Ok(text)
}

fn config_as_toml_value(config: &Config) -> EngineResult<toml::Value> {
    let text = toml::to_string(config).map_err(|error| {
        EngineError::ConfigError(format!("Failed to serialize defaults: {}", error))
    })?;
    toml::from_str(&text).map_err(|error| {
        EngineError::ConfigError(format!("Failed to parse default config: {}", error))
    })
}

fn inspect_config_keys(
    schema: &toml::Value,
    value: &toml::Value,
    path: &str,
    report: &mut ConfigReport,
) {
    let (toml::Value::Table(schema_table), toml::Value::Table(value_table)) = (schema, value)
    else {
        return;
    };
    for (key, child) in value_table {
        let full_path = dotted_path(path, key);
        if full_path == "schema_version" {
            continue;
        }
        if full_path == "modules.graph" {
            report
                .deprecated_keys
                .push("modules.graph -> modules.flownet".to_string());
            continue;
        }
        let Some(schema_child) = schema_table.get(key) else {
            report.ignored_keys.push(full_path);
            continue;
        };
        inspect_config_keys(schema_child, child, &full_path, report);
    }
}

fn validate_schema_version(
    value: &toml::Value,
    options: &ConfigLoadOptions,
    report: &mut ConfigReport,
) {
    let Some(expected) = options.schema_version else {
        return;
    };
    let toml::Value::Table(table) = value else {
        return;
    };
    let Some(schema_value) = table.get("schema_version") else {
        return;
    };
    match schema_value.as_integer() {
        Some(found) if found >= 0 && found as u32 == expected => {}
        Some(found) => report.push_error(format!(
            "schema_version {} does not match expected version {}",
            found, expected
        )),
        None => report.push_error("schema_version must be an integer".to_string()),
    }
}

fn merge_toml_values(base: &mut toml::Value, override_value: toml::Value) {
    match (base, override_value) {
        (toml::Value::Table(base_table), toml::Value::Table(override_table)) => {
            for (key, value) in override_table {
                match base_table.get_mut(&key) {
                    Some(base_value) => merge_toml_values(base_value, value),
                    None => {
                        base_table.insert(key, value);
                    }
                }
            }
        }
        (base_slot, value) => *base_slot = value,
    }
}

fn dotted_path(prefix: &str, key: &str) -> String {
    if prefix.is_empty() {
        key.to_string()
    } else {
        format!("{prefix}.{key}")
    }
}

fn log_config_report(report: &ConfigReport) {
    for key in &report.ignored_keys {
        log::warn!("conf.toml ignored unknown key: {}", key);
    }
    for key in &report.deprecated_keys {
        log::warn!("conf.toml used deprecated key: {}", key);
    }
    for correction in &report.corrected_values {
        log::warn!("conf.toml corrected value: {}", correction);
    }
}

fn validate_bounded_u32(
    name: &str,
    value: &mut u32,
    default: u32,
    min: u32,
    max: u32,
    mode: ConfigValidationMode,
    report: &mut ConfigReport,
) {
    if *value >= min && *value <= max {
        return;
    }
    let original = *value;
    match mode {
        ConfigValidationMode::Strict => report.push_error(format!(
            "{}={} is outside the supported range {}..={}",
            name, original, min, max
        )),
        ConfigValidationMode::Permissive => {
            let corrected = default.clamp(min, max);
            *value = corrected;
            report.push_correction(format!("{name}: {original} -> {corrected}"));
        }
    }
}

fn validate_bounded_usize(
    name: &str,
    value: &mut usize,
    default: usize,
    min: usize,
    max: usize,
    mode: ConfigValidationMode,
    report: &mut ConfigReport,
) {
    if *value >= min && *value <= max {
        return;
    }
    let original = *value;
    match mode {
        ConfigValidationMode::Strict => report.push_error(format!(
            "{}={} is outside the supported range {}..={}",
            name, original, min, max
        )),
        ConfigValidationMode::Permissive => {
            let corrected = default.clamp(min, max);
            *value = corrected;
            report.push_correction(format!("{name}: {original} -> {corrected}"));
        }
    }
}

fn validate_optional_u32(
    name: &str,
    value: &mut Option<u32>,
    min: u32,
    max: u32,
    mode: ConfigValidationMode,
    report: &mut ConfigReport,
) {
    let Some(current) = *value else {
        return;
    };
    if current >= min && current <= max {
        return;
    }
    match mode {
        ConfigValidationMode::Strict => report.push_error(format!(
            "{}={} is outside the supported range {}..={}",
            name, current, min, max
        )),
        ConfigValidationMode::Permissive => {
            *value = None;
            report.push_correction(format!("{name}: {current} -> nil"));
        }
    }
}

fn validate_optional_f32(
    name: &str,
    value: &mut Option<f32>,
    default: Option<f32>,
    min: f32,
    max: f32,
    mode: ConfigValidationMode,
    report: &mut ConfigReport,
) {
    let Some(current) = *value else {
        return;
    };
    if current.is_finite() && current >= min && current <= max {
        return;
    }
    match mode {
        ConfigValidationMode::Strict => {
            report.push_error(format!("{name}={} is outside the supported range", current))
        }
        ConfigValidationMode::Permissive => {
            *value = default;
            report.push_correction(format!("{name}: {current} -> {:?}", default));
        }
    }
}

fn validate_f64(
    name: &str,
    value: &mut f64,
    default: f64,
    min: f64,
    max: f64,
    mode: ConfigValidationMode,
    report: &mut ConfigReport,
) {
    if value.is_finite() && *value >= min && *value <= max {
        return;
    }
    let original = *value;
    match mode {
        ConfigValidationMode::Strict => report.push_error(format!(
            "{name}={} is outside the supported range",
            original
        )),
        ConfigValidationMode::Permissive => {
            *value = default;
            report.push_correction(format!("{name}: {original} -> {default}"));
        }
    }
}

fn validate_scale_mode(
    name: &str,
    value: &mut String,
    default: &str,
    mode: ConfigValidationMode,
    report: &mut ConfigReport,
) {
    let normalized = value.to_lowercase();
    if matches!(
        normalized.as_str(),
        "none" | "letterbox" | "stretch" | "pixel"
    ) {
        if *value != normalized {
            report.push_correction(format!("{name}: {} -> {}", value, normalized));
            *value = normalized;
        }
        return;
    }
    let original = value.clone();
    match mode {
        ConfigValidationMode::Strict => report.push_error(format!(
            "{name}='{}' is not one of: none, letterbox, stretch, pixel",
            original
        )),
        ConfigValidationMode::Permissive => {
            *value = default.to_string();
            report.push_correction(format!("{name}: {original} -> {default}"));
        }
    }
}

fn validate_log_level(
    value: &mut Option<String>,
    mode: ConfigValidationMode,
    report: &mut ConfigReport,
) {
    let Some(current) = value.clone() else {
        return;
    };
    let normalized = current.to_lowercase();
    if matches!(
        normalized.as_str(),
        "off" | "none" | "error" | "warn" | "warning" | "info" | "debug" | "trace"
    ) {
        *value = Some(normalized);
        return;
    }
    match mode {
        ConfigValidationMode::Strict => report.push_error(format!(
            "log_level='{}' is not one of: off, error, warn, info, debug, trace",
            current
        )),
        ConfigValidationMode::Permissive => {
            *value = None;
            report.push_correction(format!("log_level: {} -> nil", current));
        }
    }
}

fn apply_relation_error(
    name: &str,
    error: String,
    mode: ConfigValidationMode,
    report: &mut ConfigReport,
    correct: impl FnOnce(),
) {
    match mode {
        ConfigValidationMode::Strict => report.push_error(error),
        ConfigValidationMode::Permissive => {
            correct();
            report.push_correction(format!("{name}: clamped to owning window dimension"));
        }
    }
}
