//! Owns the runtime shared state implementation for the runtime subsystem and keeps related runtime rules local here.
//! Keeps shared state, boundaries, and execution helpers ownership so helpers stay close to invariants this file updates.
//! Defines how runtime shared state data is validated, transformed, or stored before neighboring systems consume it.
//! Separates runtime shared state behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where runtime code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing runtime shared state defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near shared state state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping runtime shared state calculations at their owning subsystem boundary.
//! Provides local adaptation layer that lets callers reuse runtime shared state rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on shared state state, helpers, or integration rules.
//! Works with neighboring runtime owners while keeping the main runtime shared state responsibility anchored in one file.
//! Changes to runtime shared state names, caches, or helper boundaries should usually stay coupled inside this owner.

use crate::audio::Mixer;
use crate::camera::Camera;
use crate::cursor::CursorManager;
use crate::event::EventQueue;
use crate::filesystem::GameFS;
use crate::input::recorder::InputRecorder;
use crate::input::{
    GamepadMappings, GamepadState, GamepadVibrationRequest, InputHistory, KeyboardState,
    MouseState, TouchState,
};
use crate::light::LightWorld;
use crate::log::SinkRegistry;
use crate::mods::ModSandbox;
use crate::parallax::ParallaxLayer;
use crate::particle::ParticleSystem;
use crate::province::registry::ProvinceRegistry;
use crate::province::types::ProvinceId;
use crate::province::ProvinceProperties;
use crate::province::ProvinceRenderSnapshot;
use crate::raycaster::{RaycasterLastBuildContext, RaycasterScene};
use crate::render::gpu_state::RenderStats;
use crate::render::render_budget::RenderBudgetLimits;
use crate::render::renderer::{BlendMode, DepthMode, RenderCommand, StencilMode, TextureData};
use crate::render::RenderCapabilities;
use crate::render::{Canvas, CompoundShape, Mesh, Shader};
use crate::runtime::mode::RuntimeMode;
use crate::runtime::resource_keys::{
    CanvasKey, FontKey, MeshKey, ParticleKey, ShaderKey, ShapeKey, SpriteBatchKey, TextureKey,
};
use crate::tilemap::TileMap;
use crate::timer::Clock;
use crate::ui::GuiContext;
use slotmap::Key as SlotmapKey;
use slotmap::SlotMap;
use std::cell::RefCell;
use std::collections::{HashMap, HashSet, VecDeque};
use std::path::PathBuf;
use std::rc::{Rc, Weak};
use std::sync::Arc;
use winit::window::Window;

/// Cached texture handle for engine-generated province segment rasters.
#[derive(Debug, Clone)]
pub struct ProvinceSegmentTextureCache {
    /// Texture slot containing the last generated raster.
    pub texture_key: TextureKey,
    /// Registry revision used for the cached raster.
    pub registry_revision: u64,
    /// Render-option fingerprint used for the cached raster.
    pub options_fingerprint: u64,
    /// Cached texture width in pixels.
    pub width: u32,
    /// Cached texture height in pixels.
    pub height: u32,
    /// Left map cell included in the cached raster.
    pub map_x: u32,
    /// Top map cell included in the cached raster.
    pub map_y: u32,
    /// Last render-time province tints used to generate this cache.
    pub province_tints: HashMap<ProvinceId, [f32; 4]>,
}

#[derive(Debug, Clone, Copy, PartialEq)]
/// Runtime enum for FullscreenType.
pub enum FullscreenType {
    /// Selects Desktop variant.
    Desktop,
    /// Selects Exclusive variant.
    Exclusive,
}
#[derive(Debug)]
/// Runtime data model for deferred and observed window state shared across Lua bindings and the app loop.
/// # Fields
pub struct WindowState {
    /// Stores focused state.
    pub focused: bool,
    /// Stores mouse_focused state.
    pub mouse_focused: bool,
    /// Stores minimized state.
    pub minimized: bool,
    /// Stores maximized state.
    pub maximized: bool,
    /// Stores visible state.
    pub visible: bool,
    /// Stores dpi_scale state.
    pub dpi_scale: f64,
    /// Stores position_x state.
    pub position_x: i32,
    /// Stores position_y state.
    pub position_y: i32,
    /// Stores pending_title state.
    pub pending_title: Option<String>,
    /// Stores pending_fullscreen state.
    pub pending_fullscreen: Option<bool>,
    /// Stores pending_fullscreen_type state.
    pub pending_fullscreen_type: FullscreenType,
    /// Stores pending_position state.
    pub pending_position: Option<(i32, i32)>,
    /// Stores pending_display_index state.
    pub pending_display_index: Option<usize>,
    /// Stores pending_size state.
    pub pending_size: Option<(u32, u32)>,
    /// Stores pending_minimize state.
    pub pending_minimize: bool,
    /// Stores pending_maximize state.
    pub pending_maximize: bool,
    /// Stores pending_restore state.
    pub pending_restore: bool,
    /// Stores pending_focus state.
    pub pending_focus: bool,
    /// Stores pending_close state.
    pub pending_close: bool,
    /// Stores pending_attention state.
    pub pending_attention: bool,
    /// Stores pending_icon_path state.
    pub pending_icon_path: Option<String>,
    /// Stores vsync_mode state.
    pub vsync_mode: i32,
    /// Stores pending_vsync state.
    pub pending_vsync: Option<i32>,
    /// Stores fullscreen state.
    pub fullscreen: bool,
    /// Stores fullscreen_type state.
    pub fullscreen_type: FullscreenType,
    /// Stores game_width state.
    pub game_width: f32,
    /// Stores game_height state.
    pub game_height: f32,
    /// Stores scale_mode_str state.
    pub scale_mode_str: String,
    /// Stores viewport_scale_x state.
    pub viewport_scale_x: f32,
    /// Stores viewport_scale_y state.
    pub viewport_scale_y: f32,
    /// Stores viewport_offset_x state.
    pub viewport_offset_x: f32,
    /// Stores viewport_offset_y state.
    pub viewport_offset_y: f32,
    /// Stores pending_scale_mode state.
    pub pending_scale_mode: Option<String>,
}
/// Provide sensible desktop-safe defaults for window state on startup.
impl Default for WindowState {
    /// Create a WindowState with default desktop-safe values.
    fn default() -> Self {
        Self {
            focused: true,
            mouse_focused: true,
            minimized: false,
            maximized: false,
            visible: true,
            dpi_scale: 1.0,
            position_x: 0,
            position_y: 0,
            pending_title: None,
            pending_fullscreen: None,
            pending_fullscreen_type: FullscreenType::Desktop,
            pending_position: None,
            pending_display_index: None,
            pending_size: None,
            pending_minimize: false,
            pending_maximize: false,
            pending_restore: false,
            pending_focus: false,
            pending_close: false,
            pending_attention: false,
            pending_icon_path: None,
            vsync_mode: 1,
            pending_vsync: None,
            fullscreen: false,
            fullscreen_type: FullscreenType::Desktop,
            game_width: 800.0,
            game_height: 600.0,
            scale_mode_str: "none".to_string(),
            viewport_scale_x: 1.0,
            viewport_scale_y: 1.0,
            viewport_offset_x: 0.0,
            viewport_offset_y: 0.0,
            pending_scale_mode: None,
        }
    }
}
#[derive(Debug, Clone)]
/// Runtime data model for the latest engine error snapshot exposed to Lua and diagnostics.
/// # Fields
pub struct ErrorInfo {
    /// Stores message state.
    pub message: String,
    /// Stores code state.
    pub code: String,
    /// Stores category state.
    pub category: String,
    /// Stores hint state.
    pub hint: Option<String>,
}
#[derive(Debug, Clone, PartialEq, Eq)]
/// Runtime data model for a deferred screenshot capture request.
/// # Fields
pub struct ScreenshotRequest {
    /// Stores path state.
    pub path: String,
}
/// Observable state of one bounded interactive GPU surface readback.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SurfaceReadbackRequestState {
    /// The request is waiting for an async GPU map callback.
    Pending,
    /// The image result can be consumed exactly once.
    Ready,
    /// The GPU map or image conversion failed.
    Failed,
    /// The asynchronous request exceeded its trusted deadline.
    TimedOut,
    /// The Lua request was cancelled or the surface was torn down.
    Cancelled,
}

impl SurfaceReadbackRequestState {
    /// Return the stable Lua-facing lifecycle name.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Pending => "pending",
            Self::Ready => "ready",
            Self::Failed => "failed",
            Self::TimedOut => "timed_out",
            Self::Cancelled => "cancelled",
        }
    }
}

/// Runtime-owned readback result and its request identity.
#[derive(Debug)]
pub struct SurfaceReadbackRequest {
    /// Monotonic identity used to make released Lua handles stale deterministically.
    pub id: u64,
    /// Current lifecycle state.
    pub state: SurfaceReadbackRequestState,
    /// Completed CPU image; `result()` consumes this allocation.
    pub image: Option<crate::image::ImageData>,
}

/// Lifecycle state for a bounded shader prewarm request.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ShaderPrewarmRequestState {
    /// Shader keys await a renderer frame-boundary compilation slot.
    Pending,
    /// Every requested shader entered the normal compiled cache.
    Ready,
    /// A requested shader was stale or rejected by the normal cache policy.
    Failed,
    /// The request was cancelled before all keys were compiled.
    Cancelled,
}

impl ShaderPrewarmRequestState {
    /// Return the stable Lua lifecycle name.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Pending => "pending",
            Self::Ready => "ready",
            Self::Failed => "failed",
            Self::Cancelled => "cancelled",
        }
    }
}

/// Runtime-owned prewarm request drained under the renderer's per-frame compilation budget.
#[derive(Debug)]
pub struct ShaderPrewarmRequest {
    /// Monotonic identity used by Lua request handles.
    pub id: u64,
    /// Current lifecycle state.
    pub state: ShaderPrewarmRequestState,
    /// Shader keys not yet submitted to the renderer cache.
    pub remaining: VecDeque<ShaderKey>,
    /// Shader keys submitted to the renderer but awaiting their cache outcome.
    pub in_flight: usize,
    /// Number of successfully submitted shader keys.
    pub completed: usize,
    /// Original requested shader-key count.
    pub total: usize,
}
#[derive(Debug, Clone, Copy, Default, PartialEq)]
/// Runtime data model for per-frame timing buckets captured by the runtime.
/// # Fields
pub struct FrameProfile {
    /// Stores app_tick_ms state.
    pub app_tick_ms: f32,
    /// Stores app_update_ms state.
    pub app_update_ms: f32,
    /// Stores app_render_ms state.
    pub app_render_ms: f32,
    /// Stores app_frame_total_ms state.
    pub app_frame_total_ms: f32,
    /// Stores process_physics_ms state.
    pub process_physics_ms: f32,
    /// Stores fixed_update_ms state.
    pub fixed_update_ms: f32,
    /// Stores process_ms state.
    pub process_ms: f32,
    /// Stores process_late_ms state.
    pub process_late_ms: f32,
    /// Stores draw_ms state.
    pub draw_ms: f32,
    /// Stores draw_ui_ms state.
    pub draw_ui_ms: f32,
    /// Stores callback_total_ms state.
    pub callback_total_ms: f32,
}

impl FrameProfile {
    /// Normalize invalid timing values and return warning messages describing corrections.
    pub fn sanitize_in_place(&mut self) -> Vec<String> {
        let mut corrections = Vec::new();
        sanitize_frame_value("app_tick_ms", &mut self.app_tick_ms, &mut corrections);
        sanitize_frame_value("app_update_ms", &mut self.app_update_ms, &mut corrections);
        sanitize_frame_value("app_render_ms", &mut self.app_render_ms, &mut corrections);
        sanitize_frame_value(
            "app_frame_total_ms",
            &mut self.app_frame_total_ms,
            &mut corrections,
        );
        sanitize_frame_value(
            "process_physics_ms",
            &mut self.process_physics_ms,
            &mut corrections,
        );
        sanitize_frame_value(
            "fixed_update_ms",
            &mut self.fixed_update_ms,
            &mut corrections,
        );
        sanitize_frame_value("process_ms", &mut self.process_ms, &mut corrections);
        sanitize_frame_value(
            "process_late_ms",
            &mut self.process_late_ms,
            &mut corrections,
        );
        sanitize_frame_value("draw_ms", &mut self.draw_ms, &mut corrections);
        sanitize_frame_value("draw_ui_ms", &mut self.draw_ui_ms, &mut corrections);
        sanitize_frame_value(
            "callback_total_ms",
            &mut self.callback_total_ms,
            &mut corrections,
        );
        corrections
    }
}
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
/// Runtime data model for aggregate resource memory and object-count statistics.
/// # Fields
pub struct ResourceMemoryStats {
    /// Stores texture_bytes state.
    pub texture_bytes: u64,
    /// Stores font_bytes state.
    pub font_bytes: u64,
    /// Stores canvas_bytes state.
    pub canvas_bytes: u64,
    /// Stores shader_bytes state.
    pub shader_bytes: u64,
    /// Bytes held by renderer-owned reconstructible caches; this public-resource snapshot has none.
    pub evictable_bytes: u64,
    /// Bytes held by live public handles and therefore never reclaimed implicitly.
    pub non_evictable_bytes: u64,
    /// Stores total_bytes state.
    pub total_bytes: u64,
    /// Stores budget_bytes state.
    pub budget_bytes: u64,
    /// Stores texture_count state.
    pub texture_count: u64,
    /// Stores font_count state.
    pub font_count: u64,
    /// Stores canvas_count state.
    pub canvas_count: u64,
    /// Stores shader_count state.
    pub shader_count: u64,
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
/// Summary of one non-destructive resource-budget pressure check.
pub struct ResourceBudgetReport {
    /// Resource stats before the pressure check.
    pub before: ResourceMemoryStats,
    /// Resource stats after the pressure check.
    pub after: ResourceMemoryStats,
    /// Texture bytes evicted by a future renderer-owned cache pass; public resources remain zero.
    pub evicted_texture_bytes: u64,
    /// Texture count evicted by a future renderer-owned cache pass; public resources remain zero.
    pub evicted_texture_count: u64,
    /// Canvas bytes evicted by a future renderer-owned cache pass; public resources remain zero.
    pub evicted_canvas_bytes: u64,
    /// Canvas count evicted by a future renderer-owned cache pass; public resources remain zero.
    pub evicted_canvas_count: u64,
    /// Bytes still over budget after the pass.
    pub remaining_over_budget_bytes: u64,
    /// Non-evictable bytes that still keep the runtime over budget.
    pub non_evictable_over_budget_bytes: u64,
}

#[derive(Debug, Clone, PartialEq, Eq)]
/// Deferred texture release tracked until a later acknowledgement.
pub struct ReleasedTextureHandle {
    /// Texture handle scheduled for cleanup acknowledgement.
    pub handle: u64,
    /// Frame number when the release was queued.
    pub queued_frame: u64,
    /// Config revision visible when the release was queued.
    pub queued_revision: u64,
}

#[derive(Debug, Clone, Default, PartialEq, Eq)]
/// Diagnostics produced by `SharedState::validate_frame_state`.
pub struct SharedStateValidationReport {
    /// Hard invariant violations.
    pub errors: Vec<String>,
    /// Soft warnings such as budget pressure or pending cleanup.
    pub warnings: Vec<String>,
}

impl SharedStateValidationReport {
    /// Return `true` when no errors or warnings were recorded.
    pub fn is_clean(&self) -> bool {
        self.errors.is_empty() && self.warnings.is_empty()
    }
}
#[derive(Debug, Clone)]
/// Runtime data model for fixed-step physics and fixed-update scheduling.
/// # Fields
pub struct PhysicsRunConfig {
    /// Stores fixed_dt state.
    pub fixed_dt: f64,
    /// Stores max_steps state.
    pub max_steps: u32,
    /// Stores debug_draw state.
    pub debug_draw: bool,
    /// Stores fixed_update_dt state.
    pub fixed_update_dt: f64,
    /// Monotonic count of completed or currently executing `process_physics` steps.
    pub tick: u64,
    /// Delta passed to the most recent `process_physics` step.
    pub last_step_dt: f64,
}
/// Provide default 60 Hz physics stepping configuration.
impl Default for PhysicsRunConfig {
    /// Create a PhysicsRunConfig targeting 60 Hz with up to 8 sub-steps.
    fn default() -> Self {
        Self {
            fixed_dt: 1.0 / 60.0,
            max_steps: 8,
            debug_draw: false,
            fixed_update_dt: 0.0,
            tick: 0,
            last_step_dt: 0.0,
        }
    }
}
/// Runtime data model for the engine's shared mutable runtime container.
/// # Fields
pub struct SharedState {
    /// Stores render_commands state.
    pub render_commands: Vec<RenderCommand>,
    /// Stores current_color state.
    pub current_color: [f32; 4],
    /// Stores background_color state.
    pub background_color: [f32; 4],
    /// Stores textures state.
    pub textures: SlotMap<TextureKey, TextureData>,
    /// Shared asset cache used by `lurek.asset` and specialist loaders.
    pub asset_cache: Rc<RefCell<crate::asset::AssetCache>>,
    /// Stores released_texture_handles state.
    pub released_texture_handles: HashSet<u64>,
    /// Stores pending_texture_releases state.
    pub pending_texture_releases: VecDeque<ReleasedTextureHandle>,
    /// Stores keys_down state.
    pub keys_down: HashSet<String>,
    /// Stores mouse state.
    pub mouse: MouseState,
    /// Stores delta_time state.
    pub delta_time: f64,
    /// Stores total_time state.
    pub total_time: f64,
    /// Stores fps state.
    pub fps: f64,
    /// Stores window_width state.
    pub window_width: u32,
    /// Stores window_height state.
    pub window_height: u32,
    /// Stores window_title state.
    pub window_title: String,
    /// Stores mixer state.
    pub mixer: Mixer,
    /// Stores game_dir state.
    pub game_dir: PathBuf,
    /// Stores quit_requested state.
    pub quit_requested: bool,
    /// Stores exit_code state.
    pub exit_code: i32,
    /// Stores restart_requested state.
    pub restart_requested: bool,
    /// Stores line_width state.
    pub line_width: f32,
    /// Stores blend_mode state.
    pub blend_mode: BlendMode,
    /// Stores fonts state.
    pub fonts: SlotMap<FontKey, crate::font::Font>,
    /// Stores active_font state.
    pub active_font: Option<FontKey>,
    /// Stores default_font state.
    pub default_font: Option<FontKey>,
    /// Stores default_fonts state (regular Courier New, slot 0..6 = 8/10/12/16/20/24/30 pt).
    pub default_fonts: [Option<FontKey>; 7],
    /// Stores default_bold_fonts state (bold Courier New, same size slots).
    pub default_bold_fonts: [Option<FontKey>; 7],
    /// True when the active font selection should use the bold variant.
    pub active_bold: bool,
    /// Requested built-in point size for the configured default render font.
    pub default_font_size: u32,
    /// Requested bold variant for the configured default render font.
    pub default_font_bold: bool,
    /// True when runtime code explicitly changed the render font selection.
    pub font_override_active: bool,
    /// Stores sprite_batches state.
    pub sprite_batches: SlotMap<SpriteBatchKey, crate::sprite::SpriteBatch>,
    /// Stores canvases state.
    pub canvases: SlotMap<CanvasKey, Canvas>,
    /// Stores particle_systems state.
    pub particle_systems: SlotMap<ParticleKey, ParticleSystem>,
    /// Stores gamepads state.
    pub gamepads: Vec<GamepadState>,
    /// Stores gamepad_background_events state.
    pub gamepad_background_events: bool,
    /// Stores gamepad_mappings state.
    pub gamepad_mappings: GamepadMappings,
    /// Stores gamepad_vibration_requests state.
    pub gamepad_vibration_requests: Vec<GamepadVibrationRequest>,
    /// Centralized active rumble effects keyed by gamepad slot; deadlines use engine milliseconds.
    pub gamepad_vibration_active: HashMap<usize, (f32, f32, u64)>,
    /// Player-to-gamepad assignments. A disconnected slot remains assigned until reassigned.
    pub gamepad_players: HashMap<u32, usize>,
    /// Per-gamepad named stick deadzones in the inclusive range 0.0..=1.0.
    pub gamepad_deadzones: HashMap<(usize, String), f32>,
    /// Bounded normalized event history shared by action, combo, and replay systems.
    pub input_history: InputHistory,
    /// Runtime-owned recorder that captures normalized per-frame input snapshots.
    pub input_recorder: InputRecorder,
    /// Stores camera state.
    pub camera: Camera,
    /// Stores point_size state.
    pub point_size: f32,
    /// Stores transform_stack_depth state.
    pub transform_stack_depth: u32,
    /// Stores active_canvas state.
    pub active_canvas: Option<CanvasKey>,
    /// Stores render_stats state.
    pub render_stats: RenderStats,
    /// Engine-owned effective aggregate render limits; Lua may inspect but never mutate them.
    pub render_budget_limits: RenderBudgetLimits,
    /// Stable renderer-owned device capabilities visible to Lua.
    pub render_capabilities: RenderCapabilities,
    /// Stores scissor state.
    pub scissor: Option<(f32, f32, f32, f32)>,
    /// Stores color_mask state.
    pub color_mask: (bool, bool, bool, bool),
    /// Stores wireframe state.
    pub wireframe: bool,
    /// Stores default_filter state.
    pub default_filter: (String, String, u32),
    /// Stores shaders state.
    pub shaders: SlotMap<ShaderKey, Shader>,
    /// Stores active_shader state.
    pub active_shader: Option<ShaderKey>,
    /// Stores the active shader used only for font-atlas backed text draws.
    pub active_text_shader: Option<ShaderKey>,
    /// Stores the active shader used for explicit debug visualization draw command groups.
    pub active_debug_shader: Option<ShaderKey>,
    /// Stores meshes state.
    pub meshes: SlotMap<MeshKey, Mesh>,
    /// Stores shapes state.
    pub shapes: SlotMap<ShapeKey, CompoundShape>,
    /// Stores keyboard state.
    pub keyboard: KeyboardState,
    /// Stores touch state.
    pub touch: TouchState,
    /// Stores window_state state.
    pub window_state: WindowState,
    /// Stores window state.
    pub window: Option<Arc<Window>>,
    /// Stores event_queue state.
    pub event_queue: EventQueue,
    /// Stores filesystem_identity state.
    pub filesystem_identity: String,
    /// Currently active mod id for sandboxed Lua callbacks, when present.
    pub active_mod_id: Option<String>,
    /// Currently active mod sandbox policy for sandboxed Lua callbacks, when present.
    pub active_mod_sandbox: Option<ModSandbox>,
    /// Stores clock state.
    pub clock: Clock,
    /// Stores debug_overlay_enabled state.
    pub debug_overlay_enabled: bool,
    /// Stores last_error state.
    pub last_error: Option<ErrorInfo>,
    /// Stores shader_error_display_enabled state.
    pub shader_error_display_enabled: bool,
    /// Stores last_shader_compile_error state.
    pub last_shader_compile_error: Option<String>,
    /// Stores async_loader state.
    pub async_loader: Option<crate::filesystem::AsyncLoader>,
    /// Stores fs state.
    pub fs: GameFS,
    /// Shared Lua log sink registry used by `lurek.log` and devtools routing.
    pub log_sinks: Rc<RefCell<SinkRegistry>>,
    /// Stores pending_screenshot state.
    pub pending_screenshot: Option<ScreenshotRequest>,
    /// Stores pending_screen_capture state.
    pub pending_screen_capture: bool,
    /// Stores captured_screen_image state.
    pub captured_screen_image: Option<crate::image::ImageData>,
    /// One bounded public GPU readback request; concurrent requests are rejected.
    pub surface_readback_request: Option<SurfaceReadbackRequest>,
    /// Set by a Lua handle cancellation and consumed by the app before the next GPU frame.
    pub cancel_surface_readback_requested: bool,
    /// Monotonic identity allocated to the next public readback request.
    pub next_surface_readback_request_id: u64,
    /// Bounded shader prewarm requests awaiting renderer frame-boundary work.
    pub shader_prewarm_requests: HashMap<u64, ShaderPrewarmRequest>,
    /// Monotonic identity allocated to the next shader prewarm request.
    pub next_shader_prewarm_request_id: u64,
    /// Stores stencil_mode state.
    pub stencil_mode: StencilMode,
    /// Stores depth_mode state.
    pub depth_mode: (DepthMode, bool),
    /// Stores light_world state.
    pub light_world: LightWorld,
    /// Stores physics_run state.
    pub physics_run: PhysicsRunConfig,
    /// Stores auto_parallax_layers state.
    pub auto_parallax_layers: Vec<Weak<RefCell<ParallaxLayer>>>,
    /// Stores auto_tilemaps state.
    pub auto_tilemaps: Vec<Weak<RefCell<TileMap>>>,
    /// Stores auto_ui_ctx state.
    pub auto_ui_ctx: Option<Weak<RefCell<GuiContext>>>,
    /// Whether platform input is forwarded to `lurek.ui` before game callbacks.
    pub auto_ui_input: bool,
    /// Whether `lurek.ui.update(dt)` is called during the normal frame update.
    pub auto_ui_update: bool,
    /// Shared runtime cursor controller used by `lurek.cursor`.
    pub cursor_runtime: CursorManager,
    /// Stores raycaster_output state.
    pub raycaster_output: Option<RaycasterScene>,
    /// Last build context used by cursor `raycaster_last` hover sources.
    pub raycaster_last_build: Option<RaycasterLastBuildContext>,
    /// Optional draw-target shader applied while presenting the last built raycaster scene.
    pub raycaster_shader: Option<ShaderKey>,
    /// Reusable overlay texture for custom or animated cursor rendering.
    pub cursor_overlay_texture: Option<TextureKey>,
    /// Monotonic signature of the data uploaded into `cursor_overlay_texture`.
    pub cursor_overlay_signature: u64,
    /// Stores resource_budget_bytes state.
    pub resource_budget_bytes: u64,
    /// Stores frame_profile state.
    pub frame_profile: FrameProfile,
    /// Stores frame_counter state.
    pub frame_counter: u64,
    /// Stores config_reload_revision state.
    pub config_reload_revision: u64,
    /// Stores selected runtime mode for Lua config snapshots and tooling.
    pub runtime_mode: RuntimeMode,
    /// Stores texture_last_used state.
    pub texture_last_used: HashMap<TextureKey, u64>,
    /// Stores canvas_last_used state.
    pub canvas_last_used: HashMap<CanvasKey, u64>,
    /// Stores frame_budget_warn_ms state.
    pub frame_budget_warn_ms: Option<f32>,
    /// Stores lua_callback_timeout_ms state.
    pub lua_callback_timeout_ms: Option<f32>,
    /// Stores pending_config_reload state.
    pub pending_config_reload: bool,
    /// Stores province_registries state.
    pub province_registries: HashMap<String, ProvinceRegistry>,
    /// CPU-only province packets prepared by the domain owner for the next render frame.
    pub province_render_snapshots: HashMap<String, ProvinceRenderSnapshot>,
    /// Stores active_province_registry state.
    pub active_province_registry: Option<String>,
    /// Generic per-province property store for game-defined key-value data.
    pub province_properties: ProvinceProperties,
    /// Engine-generated province segment textures keyed by registry name.
    pub province_segment_texture_cache: HashMap<String, ProvinceSegmentTextureCache>,
}
/// Core constructor and frame-lifecycle methods for SharedState.
impl SharedState {
    /// Create a new shared state with initial window dimensions, title, and game directory.
    pub fn new(width: u32, height: u32, title: &str, game_dir: PathBuf) -> Self {
        let fs = GameFS::new(game_dir.clone());
        SharedState {
            render_commands: Vec::new(),
            current_color: [1.0, 1.0, 1.0, 1.0],
            background_color: [0.15, 0.12, 0.25, 1.0],
            textures: SlotMap::with_key(),
            asset_cache: Rc::new(RefCell::new(crate::asset::AssetCache::new())),
            released_texture_handles: HashSet::new(),
            pending_texture_releases: VecDeque::new(),
            keys_down: HashSet::new(),
            mouse: MouseState::new(),
            delta_time: 0.0,
            total_time: 0.0,
            fps: 0.0,
            window_width: width,
            window_height: height,
            window_title: title.to_string(),
            mixer: Mixer::new(),
            game_dir,
            quit_requested: false,
            exit_code: 0,
            restart_requested: false,
            line_width: 1.0,
            blend_mode: BlendMode::default(),
            fonts: SlotMap::with_key(),
            active_font: None,
            default_font: None,
            default_fonts: [None; 7],
            default_bold_fonts: [None; 7],
            active_bold: false,
            default_font_size: 8,
            default_font_bold: false,
            font_override_active: false,
            sprite_batches: SlotMap::with_key(),
            canvases: SlotMap::with_key(),
            particle_systems: SlotMap::with_key(),
            gamepads: Vec::new(),
            gamepad_background_events: false,
            gamepad_mappings: GamepadMappings::new(),
            gamepad_vibration_requests: Vec::new(),
            gamepad_vibration_active: HashMap::new(),
            gamepad_players: HashMap::new(),
            gamepad_deadzones: HashMap::new(),
            input_history: InputHistory::default(),
            input_recorder: InputRecorder::new(),
            camera: Camera::default(),
            point_size: 1.0,
            transform_stack_depth: 1,
            active_canvas: None,
            render_stats: RenderStats::default(),
            render_budget_limits: RenderBudgetLimits::default(),
            render_capabilities: RenderCapabilities::default(),
            scissor: None,
            color_mask: (true, true, true, true),
            wireframe: false,
            default_filter: ("nearest".to_string(), "nearest".to_string(), 1),
            shaders: SlotMap::with_key(),
            active_shader: None,
            active_text_shader: None,
            active_debug_shader: None,
            meshes: SlotMap::with_key(),
            shapes: SlotMap::with_key(),
            keyboard: KeyboardState::new(),
            touch: TouchState::new(),
            window_state: WindowState::default(),
            window: None,
            event_queue: EventQueue::new(),
            filesystem_identity: String::new(),
            active_mod_id: None,
            active_mod_sandbox: None,
            clock: Clock::new(),
            debug_overlay_enabled: false,
            last_error: None,
            shader_error_display_enabled: false,
            last_shader_compile_error: None,
            async_loader: None,
            fs,
            log_sinks: Rc::new(RefCell::new(SinkRegistry::new())),
            pending_screenshot: None,
            pending_screen_capture: false,
            captured_screen_image: None,
            surface_readback_request: None,
            cancel_surface_readback_requested: false,
            next_surface_readback_request_id: 1,
            shader_prewarm_requests: HashMap::new(),
            next_shader_prewarm_request_id: 1,
            stencil_mode: StencilMode::default(),
            depth_mode: (DepthMode::Always, false),
            light_world: LightWorld::new(),
            physics_run: PhysicsRunConfig::default(),
            auto_parallax_layers: Vec::new(),
            auto_tilemaps: Vec::new(),
            auto_ui_ctx: None,
            auto_ui_input: true,
            auto_ui_update: true,
            cursor_runtime: CursorManager::new(),
            raycaster_output: None,
            raycaster_last_build: None,
            raycaster_shader: None,
            cursor_overlay_texture: None,
            cursor_overlay_signature: 0,
            resource_budget_bytes: 0,
            frame_profile: FrameProfile::default(),
            frame_counter: 0,
            config_reload_revision: 0,
            runtime_mode: RuntimeMode::Gui,
            texture_last_used: HashMap::new(),
            canvas_last_used: HashMap::new(),
            frame_budget_warn_ms: None,
            lua_callback_timeout_ms: None,
            pending_config_reload: false,
            province_registries: HashMap::new(),
            province_render_snapshots: HashMap::new(),
            active_province_registry: None,
            province_properties: ProvinceProperties::new(),
            province_segment_texture_cache: HashMap::new(),
        }
    }
    /// Advance the frame clock and update delta time, FPS, and total time.
    pub fn step_timer(&mut self) -> f64 {
        self.frame_counter = self.frame_counter.wrapping_add(1);
        let dt = self.clock.tick();
        self.delta_time = dt;
        self.total_time = self.clock.total();
        self.fps = self.clock.fps();
        if self.resource_budget_bytes > 0 {
            self.evict_lru_resources();
        }
        dt
    }

    /// Refresh immutable province render packets only when a registry revision changed.
    pub fn refresh_province_render_snapshots(&mut self) {
        self.province_render_snapshots
            .retain(|name, _| self.province_registries.contains_key(name));
        for (name, registry) in &self.province_registries {
            let stale = match self.province_render_snapshots.get(name) {
                Some(snapshot) => snapshot.revision != registry.revision(),
                None => true,
            };
            if stale {
                self.province_render_snapshots.insert(
                    name.clone(),
                    ProvinceRenderSnapshot::from_registry(registry),
                );
            }
        }
    }

    /// Take a deterministic, bounded batch of pending shader-cache work.
    ///
    /// The application must return one result per tuple through
    /// [`Self::finish_shader_prewarm_work`] after the renderer reaches its
    /// frame boundary. Keeping the queue here prevents the Lua API from
    /// creating a second, unbounded compilation path.
    pub fn take_shader_prewarm_work(&mut self, limit: usize) -> Vec<(u64, ShaderKey)> {
        let mut request_ids: Vec<u64> = self.shader_prewarm_requests.keys().copied().collect();
        request_ids.sort_unstable();
        let mut work = Vec::with_capacity(limit);
        for request_id in request_ids {
            while work.len() < limit {
                let Some(request) = self.shader_prewarm_requests.get_mut(&request_id) else {
                    break;
                };
                if request.state != ShaderPrewarmRequestState::Pending {
                    break;
                }
                let Some(shader_key) = request.remaining.pop_front() else {
                    if request.in_flight == 0 {
                        request.state = ShaderPrewarmRequestState::Ready;
                    }
                    break;
                };
                request.in_flight = request.in_flight.saturating_add(1);
                work.push((request_id, shader_key));
            }
            if work.len() == limit {
                break;
            }
        }
        work
    }

    /// Record the outcome of a previously drained bounded prewarm batch.
    pub fn finish_shader_prewarm_work(&mut self, results: &[(u64, bool)]) {
        for (request_id, succeeded) in results {
            let Some(request) = self.shader_prewarm_requests.get_mut(request_id) else {
                continue;
            };
            if request.state != ShaderPrewarmRequestState::Pending {
                continue;
            }
            request.in_flight = request.in_flight.saturating_sub(1);
            if *succeeded {
                request.completed = request.completed.saturating_add(1);
                if request.remaining.is_empty() && request.in_flight == 0 {
                    request.state = ShaderPrewarmRequestState::Ready;
                }
            } else {
                request.remaining.clear();
                request.state = ShaderPrewarmRequestState::Failed;
            }
        }
    }
    /// Mark a texture as recently used for LRU eviction tracking.
    pub fn touch_texture(&mut self, key: TextureKey) {
        self.texture_last_used.insert(key, self.frame_counter);
    }
    /// Mark a canvas as recently used for LRU eviction tracking.
    pub fn touch_canvas(&mut self, key: CanvasKey) {
        self.canvas_last_used.insert(key, self.frame_counter);
    }

    /// Queue a released texture handle until the host acknowledges cleanup.
    pub fn queue_released_texture_handle(&mut self, handle: u64) {
        if self.released_texture_handles.insert(handle) {
            self.pending_texture_releases
                .push_back(ReleasedTextureHandle {
                    handle,
                    queued_frame: self.frame_counter,
                    queued_revision: self.config_reload_revision,
                });
        }
    }

    /// Remove a queued release when the handle is recreated or otherwise becomes valid again.
    pub fn clear_released_texture_handle(&mut self, handle: u64) {
        self.released_texture_handles.remove(&handle);
        self.pending_texture_releases
            .retain(|entry| entry.handle != handle);
    }

    /// Acknowledge a pending release after renderer-side cleanup.
    pub fn ack_released_texture_handle(&mut self, handle: u64) -> bool {
        let before = self.pending_texture_releases.len();
        self.pending_texture_releases
            .retain(|entry| entry.handle != handle);
        let removed = before != self.pending_texture_releases.len();
        if removed {
            self.released_texture_handles.remove(&handle);
        }
        removed
    }

    /// Return the number of texture releases waiting for acknowledgement.
    pub fn pending_texture_release_count(&self) -> usize {
        self.pending_texture_releases.len()
    }

    /// Release a texture and queue its handle for later cleanup acknowledgement.
    pub fn release_texture(&mut self, key: TextureKey) -> bool {
        if self.textures.remove(key).is_some() {
            self.texture_last_used.remove(&key);
            self.queue_released_texture_handle(key.data().as_ffi());
            return true;
        }
        false
    }

    /// Report resource-budget pressure without invalidating public resource handles.
    ///
    /// Textures and canvases are live Lua-visible resources, so this shared-state
    /// owner must not reclaim them behind their handles. Renderer-owned caches
    /// (such as the shader cache) evict only their own reconstructible entries.
    /// The returned report keeps hard-limit pressure observable to callers that
    /// decide whether to reject a new allocation or release a resource.
    pub fn evict_lru_resources(&mut self) -> ResourceBudgetReport {
        let before = self.resource_memory_stats();
        ResourceBudgetReport {
            before,
            after: before,
            ..ResourceBudgetReport::default()
        }
        .finalize(self.resource_budget_bytes)
    }

    /// Compute current resource memory usage across all asset types.
    pub fn resource_memory_stats(&self) -> ResourceMemoryStats {
        let texture_bytes: u64 = self
            .textures
            .values()
            .map(|t| (t.width as u64) * (t.height as u64) * 4)
            .sum();
        let font_bytes: u64 = self
            .fonts
            .values()
            .map(|font| font.atlas_data().0.len() as u64)
            .sum();
        let canvas_bytes: u64 = self
            .canvases
            .values()
            .map(|canvas| (canvas.width as u64) * (canvas.height as u64) * 4)
            .sum();
        let shader_bytes: u64 = self
            .shaders
            .values()
            .map(|shader| {
                let src = shader.source.len() as u64;
                let wrapper = shader.wrapper_source.len() as u64;
                let uniforms_overhead = (shader.uniforms.len() as u64) * 32;
                src + wrapper + uniforms_overhead
            })
            .sum();
        let total_bytes = texture_bytes + font_bytes + canvas_bytes + shader_bytes;
        // All resources counted here are live public handles. The GPU cache has
        // its own bounded accounting and eviction policy in render ownership.
        let evictable_bytes = 0;
        let non_evictable_bytes = total_bytes;
        ResourceMemoryStats {
            texture_bytes,
            font_bytes,
            canvas_bytes,
            shader_bytes,
            evictable_bytes,
            non_evictable_bytes,
            total_bytes,
            budget_bytes: self.resource_budget_bytes,
            texture_count: self.textures.len() as u64,
            font_count: self.fonts.len() as u64,
            canvas_count: self.canvases.len() as u64,
            shader_count: self.shaders.len() as u64,
        }
    }

    /// Return whether a new live public resource can fit the configured hard budget.
    ///
    /// A zero budget disables enforcement. This check never evicts or invalidates
    /// existing handles; callers must reject the requested allocation instead.
    pub fn can_allocate_public_resource(&self, additional_bytes: u64) -> bool {
        self.resource_budget_bytes == 0
            || self
                .resource_memory_stats()
                .total_bytes
                .saturating_add(additional_bytes)
                <= self.resource_budget_bytes
    }

    /// Validate high-risk runtime invariants for diagnostics and tests.
    pub fn validate_frame_state(&self) -> SharedStateValidationReport {
        let mut report = SharedStateValidationReport::default();
        validate_color_state("current_color", self.current_color, &mut report);
        validate_color_state("background_color", self.background_color, &mut report);
        if self.window_width == 0 || self.window_height == 0 {
            report.errors.push(format!(
                "window dimensions must be non-zero (got {}x{})",
                self.window_width, self.window_height
            ));
        }
        if let Some(key) = self.active_canvas {
            if !self.canvases.contains_key(key) {
                report
                    .errors
                    .push("active_canvas references a stale canvas handle".to_string());
            }
        }
        if let Some(key) = self.active_shader {
            if !self.shaders.contains_key(key) {
                report
                    .errors
                    .push("active_shader references a stale shader handle".to_string());
            }
        }
        if let Some(key) = self.active_text_shader {
            if !self.shaders.contains_key(key) {
                report
                    .errors
                    .push("active_text_shader references a stale shader handle".to_string());
            }
        }
        if let Some(key) = self.active_debug_shader {
            if !self.shaders.contains_key(key) {
                report
                    .errors
                    .push("active_debug_shader references a stale shader handle".to_string());
            }
        }
        if let Some(key) = self.raycaster_shader {
            if !self.shaders.contains_key(key) {
                report
                    .errors
                    .push("raycaster_shader references a stale shader handle".to_string());
            }
        }
        if let Some(key) = self.active_font {
            if !self.fonts.contains_key(key) {
                report
                    .errors
                    .push("active_font references a stale font handle".to_string());
            }
        }
        if !self.delta_time.is_finite() || self.delta_time < 0.0 {
            report.errors.push(format!(
                "delta_time must be finite and non-negative (got {})",
                self.delta_time
            ));
        }
        if !self.total_time.is_finite() || self.total_time < 0.0 {
            report.errors.push(format!(
                "total_time must be finite and non-negative (got {})",
                self.total_time
            ));
        }
        let mut sanitized_profile = self.frame_profile;
        for correction in sanitized_profile.sanitize_in_place() {
            report.warnings.push(correction);
        }
        if let Some(budget_ms) = self.frame_budget_warn_ms {
            if sanitized_profile.app_frame_total_ms > budget_ms {
                report.warnings.push(format!(
                    "app_frame_total_ms {:.3} exceeded frame budget {:.3} ms",
                    sanitized_profile.app_frame_total_ms, budget_ms
                ));
            }
        }
        let budget_report = self.resource_budget_report();
        if self.resource_budget_bytes > 0 && budget_report.non_evictable_over_budget_bytes > 0 {
            report.warnings.push(format!(
                "resource budget exceeded by {} non-evictable bytes",
                budget_report.non_evictable_over_budget_bytes
            ));
        }
        if !self.pending_texture_releases.is_empty() {
            report.warnings.push(format!(
                "{} texture releases are still pending acknowledgement",
                self.pending_texture_releases.len()
            ));
        }
        report
    }

    /// Return a current budget report without mutating resource ownership.
    pub fn resource_budget_report(&self) -> ResourceBudgetReport {
        let before = self.resource_memory_stats();
        let (remaining_over_budget_bytes, non_evictable_over_budget_bytes) =
            if self.resource_budget_bytes == 0 {
                (0, 0)
            } else {
                (
                    before
                        .total_bytes
                        .saturating_sub(self.resource_budget_bytes),
                    before
                        .non_evictable_bytes
                        .saturating_sub(self.resource_budget_bytes),
                )
            };
        ResourceBudgetReport {
            before,
            after: before,
            remaining_over_budget_bytes,
            non_evictable_over_budget_bytes,
            ..ResourceBudgetReport::default()
        }
    }
    /// Submit an asynchronous file read and return a poll handle.
    pub fn request_async_load(&mut self, path: &str) -> crate::runtime::error::EngineResult<u64> {
        self.ensure_mod_api_allowed("filesystem")?;
        self.ensure_mod_file_read(path)?;
        let resolved = self.fs.resolve_read_path(path)?;
        if self.async_loader.is_none() {
            self.async_loader = Some(crate::filesystem::AsyncLoader::new());
        }
        let handle = self
            .async_loader
            .as_ref()
            .expect("async_loader initialized above")
            .request_load(path.to_string(), resolved);
        Ok(handle.0)
    }
    /// Submit an asynchronous file write and return a poll handle.
    pub fn request_async_write(
        &mut self,
        path: &str,
        data: Vec<u8>,
    ) -> crate::runtime::error::EngineResult<u64> {
        self.ensure_mod_api_allowed("filesystem")?;
        self.ensure_mod_file_write(path, "filesystem.writeAsync")?;
        let resolved = self.fs.resolve_save_path(path)?;
        if self.async_loader.is_none() {
            self.async_loader = Some(crate::filesystem::AsyncLoader::new());
        }
        let handle = self
            .async_loader
            .as_ref()
            .expect("async_loader initialized above")
            .request_write(path.to_string(), resolved, data);
        Ok(handle.0)
    }
    fn builtin_default_font_key(&self, point_size: u32, bold: bool) -> Option<FontKey> {
        let slot = crate::font::Font::nearest_point_size(point_size);
        let fonts = if bold {
            &self.default_bold_fonts
        } else {
            &self.default_fonts
        };
        fonts[slot]
    }

    fn apply_configured_default_font(&mut self) {
        let default_key =
            self.builtin_default_font_key(self.default_font_size, self.default_font_bold);
        self.default_font = default_key;
        if !self.font_override_active || self.active_font.is_none() {
            self.active_font = default_key;
            self.active_bold = self.default_font_bold;
        }
    }

    /// Update the configured built-in default render font.
    pub fn set_configured_default_font(&mut self, point_size: u32, bold: bool) {
        self.default_font_size = point_size;
        self.default_font_bold = bold;
        if self.default_fonts.iter().any(Option::is_some) {
            self.apply_configured_default_font();
        }
    }

    /// Select a built-in font by point size and make it the active render font.
    pub fn set_active_builtin_font(&mut self, point_size: u32, bold: bool) -> Option<FontKey> {
        let key = self.builtin_default_font_key(point_size, bold)?;
        self.default_font = Some(key);
        self.active_font = Some(key);
        self.active_bold = bold;
        self.font_override_active = true;
        Some(key)
    }

    /// Load all built-in font sizes and set the default active font.
    pub fn load_default_fonts(&mut self) {
        if self.default_fonts.iter().any(Option::is_some) {
            self.apply_configured_default_font();
            return;
        }
        // Regular Courier New.
        let regular = crate::font::Font::load_all_sizes();
        for (i, (font, _cw, _ch)) in regular.into_iter().enumerate() {
            let key = self.fonts.insert(font);
            self.default_fonts[i] = Some(key);
        }
        // Bold Courier New.
        let bold = crate::font::Font::load_all_bold();
        for (i, (font, _cw, _ch)) in bold.into_iter().enumerate() {
            let key = self.fonts.insert(font);
            self.default_bold_fonts[i] = Some(key);
        }
        self.apply_configured_default_font();
    }
    /// Check the status of a pending asynchronous read operation.
    pub fn poll_async_load(&self, handle_id: u64) -> (String, Option<String>) {
        use crate::filesystem::{LoadHandle, LoadResult, LoadStatus};
        if let Some(ref loader) = self.async_loader {
            match loader.poll(LoadHandle(handle_id)) {
                LoadStatus::Pending => ("pending".to_string(), None),
                LoadStatus::Done(LoadResult::Ready(bytes)) => (
                    "done".to_string(),
                    Some(String::from_utf8_lossy(&bytes).to_string()),
                ),
                LoadStatus::Done(LoadResult::Error(msg)) => ("error".to_string(), Some(msg)),
            }
        } else {
            ("error".to_string(), None)
        }
    }
    /// Check the status of a pending asynchronous write operation.
    pub fn poll_async_write(&self, handle_id: u64) -> (String, Option<String>) {
        use crate::filesystem::{LoadHandle, WriteResult, WriteStatus};
        if let Some(ref loader) = self.async_loader {
            match loader.poll_write(LoadHandle(handle_id)) {
                WriteStatus::Pending => ("pending".to_string(), None),
                WriteStatus::Done(WriteResult::Written(bytes)) => {
                    ("done".to_string(), Some(bytes.to_string()))
                }
                WriteStatus::Done(WriteResult::Error(msg)) => ("error".to_string(), Some(msg)),
            }
        } else {
            ("error".to_string(), None)
        }
    }

    /// Set the active mod sandbox context for subsequent Lua API calls.
    pub fn set_active_mod_sandbox(&mut self, mod_id: impl Into<String>, sandbox: ModSandbox) {
        self.active_mod_id = Some(mod_id.into());
        self.active_mod_sandbox = Some(sandbox);
    }

    /// Clear any active mod sandbox context.
    pub fn clear_active_mod_sandbox(&mut self) {
        self.active_mod_id = None;
        self.active_mod_sandbox = None;
    }

    /// Return a cloned snapshot of the active mod sandbox context.
    pub fn active_mod_context(&self) -> (Option<String>, Option<ModSandbox>) {
        (self.active_mod_id.clone(), self.active_mod_sandbox.clone())
    }

    /// Restore a previously saved mod sandbox context.
    pub fn restore_active_mod_context(
        &mut self,
        mod_id: Option<String>,
        sandbox: Option<ModSandbox>,
    ) {
        self.active_mod_id = mod_id;
        self.active_mod_sandbox = sandbox;
    }

    /// Enforce API-module access for the active mod sandbox, when present.
    pub fn ensure_mod_api_allowed(&self, module: &str) -> crate::runtime::error::EngineResult<()> {
        let Some(sandbox) = &self.active_mod_sandbox else {
            return Ok(());
        };
        if module == "network" && !sandbox.allow_network {
            return Err(crate::runtime::error::EngineError::FileSystemError(
                format!(
                    "Active mod '{}' cannot access lurek.network while network access is disabled",
                    self.active_mod_id.as_deref().unwrap_or("unknown"),
                ),
            ));
        }
        if sandbox.is_api_allowed(module) {
            Ok(())
        } else {
            Err(crate::runtime::error::EngineError::FileSystemError(
                format!(
                    "Active mod '{}' cannot access lurek.{}",
                    self.active_mod_id.as_deref().unwrap_or("unknown"),
                    module
                ),
            ))
        }
    }

    /// Enforce read-path access for the active mod sandbox, when present.
    pub fn ensure_mod_file_read(&self, path: &str) -> crate::runtime::error::EngineResult<()> {
        let Some(sandbox) = &self.active_mod_sandbox else {
            return Ok(());
        };
        let host_path = resolve_mod_host_path(self.fs.base_dir(), path);
        sandbox.check_read_path_host(&host_path).map_err(|err| {
            crate::runtime::error::EngineError::FileSystemError(format!(
                "Active mod '{}' read denied: {}",
                self.active_mod_id.as_deref().unwrap_or("unknown"),
                err
            ))
        })
    }

    /// Enforce write access for the active mod sandbox, when present.
    pub fn ensure_mod_file_write(
        &self,
        path: &str,
        operation: &str,
    ) -> crate::runtime::error::EngineResult<()> {
        let Some(sandbox) = &self.active_mod_sandbox else {
            return Ok(());
        };
        if !sandbox.allow_file_write {
            return Err(crate::runtime::error::EngineError::FileSystemError(
                format!(
                    "Active mod '{}' cannot call {} on '{}'",
                    self.active_mod_id.as_deref().unwrap_or("unknown"),
                    operation,
                    path
                ),
            ));
        }
        if sandbox.is_op_blocked(operation) {
            return Err(crate::runtime::error::EngineError::FileSystemError(
                format!(
                    "Active mod '{}' blocked operation {}",
                    self.active_mod_id.as_deref().unwrap_or("unknown"),
                    operation
                ),
            ));
        }
        Ok(())
    }
}

impl ResourceBudgetReport {
    fn finalize(mut self, budget_bytes: u64) -> Self {
        if budget_bytes == 0 {
            self.remaining_over_budget_bytes = 0;
            self.non_evictable_over_budget_bytes = 0;
            return self;
        }
        self.remaining_over_budget_bytes = self.after.total_bytes.saturating_sub(budget_bytes);
        self.non_evictable_over_budget_bytes =
            self.after.non_evictable_bytes.saturating_sub(budget_bytes);
        self
    }
}

fn sanitize_frame_value(name: &str, value: &mut f32, corrections: &mut Vec<String>) {
    if value.is_finite() && *value >= 0.0 {
        return;
    }
    let original = *value;
    *value = 0.0;
    corrections.push(format!(
        "frame_profile.{name} was invalid ({original}) and was normalized to 0"
    ));
}

fn validate_color_state(name: &str, color: [f32; 4], report: &mut SharedStateValidationReport) {
    for (index, component) in color.into_iter().enumerate() {
        if component.is_finite() && (0.0..=1.0).contains(&component) {
            continue;
        }
        report.errors.push(format!(
            "{name}[{index}] must be finite and within 0..=1 (got {component})"
        ));
    }
}

fn resolve_mod_host_path(base_dir: &std::path::Path, path: &str) -> std::path::PathBuf {
    let candidate = std::path::Path::new(path);
    if candidate.is_absolute() {
        return candidate.to_path_buf();
    }
    let mut resolved = base_dir.to_path_buf();
    for component in candidate.components() {
        match component {
            std::path::Component::CurDir => {}
            std::path::Component::Normal(part) => resolved.push(part),
            std::path::Component::ParentDir => resolved.push(".."),
            std::path::Component::RootDir | std::path::Component::Prefix(_) => {}
        }
    }
    resolved
}
/// Runtime data model for aggregate renderer counters derived from the current frame state.
/// # Fields
pub struct RendererStats {
    /// Stores draw_calls state.
    pub draw_calls: usize,
    /// Stores textures state.
    pub textures: usize,
    /// Stores fonts state.
    pub fonts: usize,
    /// Stores canvases state.
    pub canvases: usize,
    /// Stores texture_memory state.
    pub texture_memory: usize,
}
/// Aggregate renderer statistics computed from current SharedState.
impl SharedState {
    /// Compute aggregate renderer statistics for the current frame.
    pub fn compute_stats(&self) -> RendererStats {
        RendererStats {
            draw_calls: self.render_commands.len(),
            textures: self.textures.len(),
            fonts: self.fonts.len(),
            canvases: self.canvases.len(),
            texture_memory: self
                .textures
                .values()
                .map(|t| (t.width * t.height * 4) as usize)
                .sum(),
        }
    }
}
