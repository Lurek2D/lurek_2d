//! Owns the app app runner implementation for the app subsystem and keeps related runtime rules local here.
//! Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
//! Defines how app app runner data is validated, transformed, or stored before neighboring systems consume it.
//! Separates app app runner behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where app code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing app app runner defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the app app runner state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping app app runner calculations explicit at their owning subsystem boundary.
//! Provides the local adaptation layer that lets callers reuse app app runner rules without duplicating engine decisions.

use super::*;

impl LurekApp {
    #[allow(clippy::too_many_arguments)]
    /// Build app runtime state and initialize filesystem watchers from startup config.
    pub fn new(
        config: Config,
        game_dir: PathBuf,
        conf_error: Option<String>,
        explicit_game_dir: bool,
        auto_screenshot_path: Option<PathBuf>,
        auto_screenshot_frames: u32,
        auto_screenshot_time: Option<f32>,
        auto_quit_frames: Option<u32>,
        auto_quit_time: Option<f32>,
        hidden_window: bool,
        window_pos: Option<(i32, i32)>,
    ) -> Self {
        let window_vsync_mode = if config.window.vsync { 1 } else { 0 };
        let mut conf_watcher = FileWatcher::new();
        conf_watcher.watch(game_dir.join("conf.toml"));
        let mut content_script_watcher = FileWatcher::new();
        let mut content_asset_watcher = FileWatcher::new();
        register_content_watchers(
            &game_dir,
            &mut content_script_watcher,
            &mut content_asset_watcher,
        );
        LurekApp {
            config,
            game_dir,
            window: None,
            surface: None,
            surface_format: wgpu::TextureFormat::Bgra8UnormSrgb,
            surface_alpha_mode: wgpu::CompositeAlphaMode::Auto,
            surface_present_modes: Vec::new(),
            surface_present_mode: wgpu::PresentMode::Fifo,
            surface_usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            renderer: None,
            lua: None,
            state: None,
            has_game: false,
            last_frame: Instant::now(),
            ready_fired: false,
            physics_accumulator: 0.0,
            fixed_update_accumulator: 0.0,
            fixed_update_deprecation_warned: false,
            prev_mouse: [false; 5],
            mouse_x: 0.0,
            mouse_y: 0.0,
            run_state: RunState::Running,
            debug_overlay: DebugOverlay::new(),
            conf_error,
            conf_watcher,
            content_script_watcher,
            content_asset_watcher,
            explicit_game_dir,
            window_vsync_mode,
            engine_fonts: None,
            splash_branding: None,
            splash_branding_failed: false,
            ctrl_held: false,
            lua_initialized: false,
            drag_hover: false,
            max_surface_dim: 4096,
            render_cmd_buf: Vec::new(),
            auto_parallax_buf: Vec::new(),
            auto_tilemap_buf: Vec::new(),
            auto_particle_cmd_buf: Vec::new(),
            auto_ui_cmd_buf: Vec::new(),
            auto_screenshot_path,
            auto_screenshot_frames,
            auto_screenshot_time,
            auto_screenshot_done: false,
            auto_screenshot_frame_count: 0,
            auto_screenshot_start: None,
            auto_quit_frames,
            auto_quit_time,
            auto_quit_done: false,
            auto_quit_frame_count: 0,
            auto_quit_start: None,
            hidden_window,
            window_pos,
            lurek_temp_dir: None,
            perf_report_started: Instant::now(),
            perf_frames: 0,
            perf_tick_ms_acc: 0.0,
            perf_update_ms_acc: 0.0,
            perf_render_ms_acc: 0.0,
            perf_log_enabled: std::env::var("LUREK_PERF_LOG").ok().as_deref() == Some("1"),
            diagnostics: AppDiagnostics::default(),
            callback_failure_overrides: HashMap::new(),
            pending_hot_reload_paths: Vec::new(),
            pending_hot_reload_deadline: None,
            hot_reload_debounce: DEFAULT_HOT_RELOAD_DEBOUNCE,
        }
    }
    /// Return the configured Lua callback timeout in milliseconds.
    pub(super) fn callback_timeout_ms(&self) -> Option<f32> {
        self.config.performance.lua_callback_timeout_ms
    }

    /// Override one callback failure policy for deterministic tests and host tuning.
    pub fn set_callback_failure_policy_for_testing(
        &mut self,
        callback: &str,
        policy: CallbackFailurePolicy,
    ) {
        self.callback_failure_overrides
            .insert(callback.to_string(), policy);
    }

    /// Returns the configured failure policy for one named Lua callback.
    pub(super) fn callback_failure_policy(&self, callback: &str) -> CallbackFailurePolicy {
        self.callback_failure_overrides
            .get(callback)
            .copied()
            .unwrap_or(match callback {
                "ready" | "process_physics" | "fixedUpdate" | "process" | "process_late"
                | "draw" | "draw_ui" | "ui.update" => CallbackFailurePolicy::Fatal,
                _ => CallbackFailurePolicy::ReportOnly,
            })
    }

    /// Appends a callback error record to bounded runtime diagnostics history.
    pub(super) fn push_callback_error(&mut self, record: CallbackErrorRecord) {
        if self.diagnostics.callback_errors.len() >= 32 {
            self.diagnostics.callback_errors.remove(0);
        }
        self.diagnostics.callback_errors.push(record);
    }

    /// Stores a non-empty window runtime report in bounded diagnostics history.
    pub(super) fn push_window_report(&mut self, report: WindowRuntimeReport) {
        if report.is_empty() {
            return;
        }
        if self.diagnostics.window_reports.len() >= 32 {
            self.diagnostics.window_reports.remove(0);
        }
        self.diagnostics.window_reports.push(report);
    }

    /// Appends an input dispatch report to bounded diagnostics history.
    pub(super) fn push_input_report(&mut self, report: InputDispatchReport) {
        if self.diagnostics.input_reports.len() >= 32 {
            self.diagnostics.input_reports.remove(0);
        }
        self.diagnostics.input_reports.push(report);
    }

    /// Appends a hot-reload report to bounded diagnostics history.
    pub(super) fn push_hot_reload_report(&mut self, report: HotReloadReport) {
        if self.diagnostics.hot_reload_reports.len() >= 16 {
            self.diagnostics.hot_reload_reports.remove(0);
        }
        self.diagnostics.hot_reload_reports.push(report);
    }

    /// Starts an input dispatch report with the default platform, UI, and game routing order.
    pub(super) fn begin_input_report(
        &self,
        event_kind: &str,
        coordinates: Option<(f32, f32)>,
    ) -> InputDispatchReport {
        let mut order = vec![InputDispatchTarget::Platform];
        if shared_flag(&self.state, |st| st.auto_ui_input) {
            order.push(InputDispatchTarget::Ui);
        }
        order.push(InputDispatchTarget::Game);
        InputDispatchReport {
            event_kind: event_kind.to_string(),
            order,
            ui_consumed: false,
            callback_error: None,
            coordinates,
        }
    }

    /// Writes the latest callback-facing error info into shared runtime state.
    pub(super) fn record_last_error(&mut self, message: String, hint: Option<String>) {
        if let Some(state) = &self.state {
            state.borrow_mut().last_error = Some(crate::runtime::ErrorInfo {
                message,
                code: "app.callback".to_string(),
                category: "script".to_string(),
                hint,
            });
        }
    }

    /// Records one Lua callback failure and enters the fatal error screen when policy requires it.
    pub(super) fn handle_callback_error(
        &mut self,
        callback: &str,
        phase: &str,
        error: mlua::Error,
    ) -> bool {
        let policy = self.callback_failure_policy(callback);
        let message = error.to_string();
        self.record_last_error(
            format!("{} failed during {}: {}", callback, phase, message),
            Some("Check the Lua callback and recent host diagnostics.".to_string()),
        );
        self.push_callback_error(CallbackErrorRecord {
            callback: callback.to_string(),
            phase: phase.to_string(),
            message: message.clone(),
            policy,
        });
        if matches!(policy, CallbackFailurePolicy::Fatal) {
            let screen = if let Some(lua) = self.lua.as_ref() {
                try_errorhandler_or_screen(lua, &error)
            } else {
                ErrorScreen::from_lua_error(&error)
            };
            self.run_state = RunState::Error(screen);
            return true;
        }
        false
    }
    /// Open the native startup folder picker and try to load the selected game directory.
    pub(super) fn browse_for_startup_game_dir(&mut self) {
        log::warn!("native startup folder picker is not built into this runtime build");
    }
    /// Load a startup target selected via drag-and-drop or the splash picker.
    pub(super) fn load_startup_target_path(&mut self, path: &Path) {
        let report =
            classify_drop_startup_target_with_policy(path, &StartupTargetPolicy::default());
        for diagnostic in &report.diagnostics {
            match diagnostic {
                StartupTargetDiagnostic::SymlinkRejected(rejected) => {
                    log::warn!(
                        "startup path rejected due to symlink: {}",
                        rejected.display()
                    );
                }
                StartupTargetDiagnostic::MissingMainLua(dir) => {
                    log::warn!("startup path missing main.lua: {}", dir.display());
                }
                StartupTargetDiagnostic::ArchiveTooLarge {
                    path,
                    actual_bytes,
                    max_bytes,
                } => {
                    log::warn!(
                        "startup archive rejected: {} exceeds {} bytes (got {})",
                        path.display(),
                        max_bytes,
                        actual_bytes
                    );
                }
                StartupTargetDiagnostic::UnsafeArchiveEntry(entry) => {
                    log::warn!("startup archive rejected unsafe entry: {}", entry);
                }
            }
        }
        match report.target {
            DropStartupTarget::Archive => {
                log_msg!(info, L083_DROP_ARCHIVE, "{}", path.display());
                match LurekApp::extract_lurek_archive_with_policy(
                    path,
                    &StartupTargetPolicy::default(),
                ) {
                    Ok((dir, td)) => {
                        self.lurek_temp_dir = Some(td);
                        self.game_dir = dir;
                        self.explicit_game_dir = true;
                        self.restart_game();
                    }
                    Err(e) => {
                        log_msg!(warn, L084_DROP_ARCHIVE_FAIL, "{}: {}", path.display(), e);
                    }
                }
            }
            DropStartupTarget::GameDir(dir) => {
                if dir == path {
                    log_msg!(info, L044_DROP_GAME, "{}", path.display());
                } else {
                    log_msg!(info, L044_DROP_GAME, "parent folder: {}", dir.display());
                }
                self.lurek_temp_dir = None;
                self.game_dir = dir;
                self.explicit_game_dir = true;
                self.restart_game();
            }
            DropStartupTarget::Unsupported => {
                if path.is_dir() {
                    log_msg!(warn, L007_NO_MAIN_LUA, "no main.lua in: {}", path.display());
                }
            }
        }
    }

    /// Clears per-session frame accumulators before a fresh runtime boot or reload.
    pub(super) fn reset_runtime_accumulators(&mut self) {
        self.ready_fired = false;
        self.physics_accumulator = 0.0;
        self.fixed_update_accumulator = 0.0;
        self.fixed_update_deprecation_warned = false;
        self.prev_mouse = [false; 5];
    }

    /// Builds a fresh Lua VM and shared runtime session for the current game directory.
    pub(super) fn build_runtime_session(&self) -> Result<RuntimeSession, RuntimeSessionError> {
        let window_title = self.current_window_title();
        let mut shared_state = SharedState::new(
            self.config.window.width,
            self.config.window.height,
            &window_title,
            self.game_dir.clone(),
        );
        if let Some(renderer) = self.renderer.as_ref() {
            shared_state.render_budget_limits = renderer.effective_render_budget_limits();
            shared_state.render_capabilities = renderer.render_capabilities();
        }
        shared_state.runtime_mode = self.config.runtime.mode;
        if let Some(identity) = &self.config.identity {
            shared_state.filesystem_identity = identity.clone();
        }
        shared_state.window_state.vsync_mode = self.window_vsync_mode;
        shared_state.window = self.window.as_ref().map(Arc::clone);
        shared_state.physics_run.fixed_dt =
            1.0 / self.config.performance.physics_tick_rate.max(1) as f64;
        shared_state.physics_run.fixed_update_dt =
            match self.config.performance.fixed_update_tick_rate {
                Some(rate) if rate > 0 => 1.0 / rate as f64,
                _ => 0.0,
            };
        shared_state.set_configured_default_font(
            self.config.render.default_font_size,
            self.config.render.default_font_bold,
        );
        shared_state.frame_budget_warn_ms = self.config.performance.frame_budget_warn_ms;
        shared_state.lua_callback_timeout_ms = self.callback_timeout_ms();
        {
            let ws = &mut shared_state.window_state;
            ws.game_width = self
                .config
                .window
                .game_width
                .unwrap_or(self.config.window.width) as f32;
            ws.game_height = self
                .config
                .window
                .game_height
                .unwrap_or(self.config.window.height) as f32;
            ws.scale_mode_str = self.config.window.scale_mode.clone();
            let (ww, wh) = (shared_state.window_width, shared_state.window_height);
            recompute_viewport(ws, ww, wh);
        }
        let state = Rc::new(RefCell::new(shared_state));
        state.borrow_mut().load_default_fonts();
        let lua = match create_lua_vm(state.clone(), &self.config.modules) {
            Ok(lua) => lua,
            Err(error) => {
                log_msg!(error, L016_LUA_VM_INIT_FAIL, "{}", error);
                let summary = format!("Lua VM initialization failed: {}", error);
                return Err(RuntimeSessionError {
                    screen: ErrorScreen::from_error(&format!(
                        "Lua VM Initialization Failed\n{}",
                        error
                    )),
                    summary,
                    state: Some(state),
                });
            }
        };
        let main_lua = self.game_dir.join("main.lua");
        if main_lua.exists() {
            log_msg!(info, L003_GAME_LOADED, "{}", main_lua.display());
            let code = match std::fs::read_to_string(&main_lua) {
                Ok(code) => code,
                Err(error) => {
                    log_msg!(error, L017_MAIN_LUA_READ_FAIL, "{}", error);
                    return Err(RuntimeSessionError {
                        screen: ErrorScreen::from_error(&format!(
                            "Failed to read main.lua\n{}",
                            error
                        )),
                        summary: format!("Failed to read main.lua: {}", error),
                        state: Some(state),
                    });
                }
            };
            if let Err(error) = lua.load(&code).set_name("main.lua").exec() {
                log_msg!(error, L011_LUA_ERROR, "main.lua: {}", error);
                return Err(RuntimeSessionError {
                    screen: ErrorScreen::from_lua_error(&error),
                    summary: format!("main.lua execution failed: {}", error),
                    state: Some(state),
                });
            }
            if let Err(error) =
                call_lua_callback_checked_with_timeout(&lua, "init", (), self.callback_timeout_ms())
            {
                return Err(RuntimeSessionError {
                    screen: try_errorhandler_or_screen(&lua, &error),
                    summary: format!("lurek.init failed: {}", error),
                    state: Some(state),
                });
            }
            return Ok(RuntimeSession {
                lua,
                state,
                has_game: true,
            });
        }
        if self.explicit_game_dir {
            log_msg!(warn, L007_NO_MAIN_LUA, "{}", self.game_dir.display());
        }
        log_msg!(info, L006_SPLASH_SCREEN);
        Ok(RuntimeSession {
            lua,
            state,
            has_game: false,
        })
    }

    /// Commits a freshly built runtime session into the live app state.
    pub(super) fn apply_runtime_session(&mut self, session: RuntimeSession) {
        let window_title = self.current_window_title();
        if let Some(window) = &self.window {
            window.set_title(&window_title);
        }
        self.lua = Some(session.lua);
        self.state = Some(session.state);
        self.has_game = session.has_game;
        self.run_state = RunState::Running;
    }

    /// Rebuild content file watchers after a game directory change.
    pub(super) fn refresh_content_watchers(&mut self) {
        let (script_watcher, asset_watcher) = build_content_watchers(&self.game_dir);
        self.content_script_watcher = script_watcher;
        self.content_asset_watcher = asset_watcher;
    }

    /// Reloads the active game directory and returns a phase-by-phase reload report.
    pub(super) fn reload_game_with_report(
        &mut self,
        trigger: &str,
        changed_paths: Vec<PathBuf>,
    ) -> ReloadReport {
        let mut report = ReloadReport {
            trigger: trigger.to_string(),
            changed_paths,
            phases: vec!["stop_callbacks".to_string()],
            reloaded: false,
            rolled_back: false,
            failure: None,
        };
        let old_lua = self.lua.take();
        let old_state = self.state.take();
        let old_has_game = self.has_game;
        let old_prev_mouse = self.prev_mouse;
        let old_run_state = std::mem::replace(&mut self.run_state, RunState::Restarting);
        self.reset_runtime_accumulators();
        report.phases.push("build_runtime".to_string());
        match self.build_runtime_session() {
            Ok(session) => {
                report.phases.push("refresh_watchers".to_string());
                self.refresh_content_watchers();
                report.phases.push("commit".to_string());
                self.apply_runtime_session(session);
                report.reloaded = true;
            }
            Err(error) => {
                report.failure = Some(error.summary.clone());
                if old_lua.is_some() || old_state.is_some() {
                    report.phases.push("rollback".to_string());
                    self.lua = old_lua;
                    self.state = old_state;
                    self.has_game = old_has_game;
                    self.prev_mouse = old_prev_mouse;
                    self.run_state = old_run_state;
                    report.rolled_back = true;
                    self.record_last_error(
                        format!("reload failed: {}", error.summary),
                        Some("The previous runtime session was restored.".to_string()),
                    );
                } else {
                    self.lua = None;
                    self.state = error.state;
                    self.has_game = false;
                    self.run_state = RunState::Error(error.screen);
                }
            }
        }
        report
    }
    /// Record frame phase timings and log a periodic PERF summary when enabled.
    pub(super) fn perf_record_frame(&mut self, tick_ms: f64, update_ms: f64, render_ms: f64) {
        if !self.perf_log_enabled {
            return;
        }
        self.perf_frames += 1;
        self.perf_tick_ms_acc += tick_ms;
        self.perf_update_ms_acc += update_ms;
        self.perf_render_ms_acc += render_ms;
        let elapsed = self.perf_report_started.elapsed().as_secs_f64();
        if elapsed < 1.0 {
            return;
        }
        let n = (self.perf_frames as f64).max(1.0);
        log::info!(
            "PERF frame_cpu_ms avg: tick={:.3}, update={:.3}, render={:.3}, total={:.3}, fps_est={:.1}",
            self.perf_tick_ms_acc / n,
            self.perf_update_ms_acc / n,
            self.perf_render_ms_acc / n,
            (self.perf_tick_ms_acc + self.perf_update_ms_acc + self.perf_render_ms_acc) / n,
            n / elapsed,
        );
        self.perf_report_started = Instant::now();
        self.perf_frames = 0;
        self.perf_tick_ms_acc = 0.0;
        self.perf_update_ms_acc = 0.0;
        self.perf_render_ms_acc = 0.0;
    }
    /// Return `true` when no game is loaded and the splash screen should display.
    pub(super) fn wants_splash_screen(&self) -> bool {
        !self.explicit_game_dir && !self.game_dir.join("main.lua").exists()
    }
    /// Return the window title string based on splash or game mode.
    pub(super) fn current_window_title(&self) -> String {
        if self.wants_splash_screen() {
            splash_window_title(&self.config.window.title)
        } else {
            self.config.window.title.clone()
        }
    }
    /// Select supported present mode and normalized vsync flag from requested mode.
    pub fn resolve_present_mode(
        available_modes: &[wgpu::PresentMode],
        requested_mode: i32,
    ) -> (wgpu::PresentMode, i32) {
        let supports = |mode| available_modes.contains(&mode);
        match requested_mode {
            -1 if supports(wgpu::PresentMode::Mailbox) => {
                return (wgpu::PresentMode::Mailbox, -1);
            }
            0 if supports(wgpu::PresentMode::Immediate) => {
                return (wgpu::PresentMode::Immediate, 0);
            }
            _ if supports(wgpu::PresentMode::Fifo) => {
                return (wgpu::PresentMode::Fifo, 1);
            }
            _ => {}
        }
        if requested_mode == 0 && supports(wgpu::PresentMode::AutoNoVsync) {
            return (wgpu::PresentMode::AutoNoVsync, 0);
        }
        if requested_mode != 0 && supports(wgpu::PresentMode::AutoVsync) {
            return (wgpu::PresentMode::AutoVsync, 1);
        }
        if supports(wgpu::PresentMode::Immediate) {
            return (wgpu::PresentMode::Immediate, 0);
        }
        if supports(wgpu::PresentMode::Mailbox) {
            return (wgpu::PresentMode::Mailbox, -1);
        }
        if supports(wgpu::PresentMode::Fifo) {
            return (wgpu::PresentMode::Fifo, 1);
        }
        if requested_mode == 0 {
            (wgpu::PresentMode::AutoNoVsync, 0)
        } else {
            (wgpu::PresentMode::AutoVsync, 1)
        }
    }
    /// Clamp surface dimensions to the GPU maximum.
    pub(super) fn clamp_surface_dims(&self, w: u32, h: u32) -> (u32, u32) {
        let m = self.max_surface_dim.max(1);
        (w.max(1).min(m), h.max(1).min(m))
    }
    /// Build a wgpu `SurfaceConfiguration` from current format, mode, and dimensions.
    pub(super) fn surface_configuration(
        &self,
        width: u32,
        height: u32,
    ) -> wgpu::SurfaceConfiguration {
        wgpu::SurfaceConfiguration {
            usage: self.surface_usage,
            format: self.surface_format,
            width,
            height,
            present_mode: self.surface_present_mode,
            alpha_mode: self.surface_alpha_mode,
            view_formats: vec![],
            desired_maximum_frame_latency: 2,
        }
    }
    /// Apply a vsync mode change and reconfigure the surface present mode.
    pub(super) fn apply_vsync_mode(&mut self, requested_mode: i32) {
        let (present_mode, vsync_mode) =
            Self::resolve_present_mode(&self.surface_present_modes, requested_mode);
        self.surface_present_mode = present_mode;
        self.window_vsync_mode = vsync_mode;
        self.config.window.vsync = vsync_mode != 0;
        if let Some(state) = &self.state {
            state.borrow_mut().window_state.vsync_mode = vsync_mode;
        }
        self.reconfigure_surface();
    }
    /// Create the wgpu instance, adapter, device, surface, and renderer.
    pub(super) fn try_init_gpu(&mut self, window: Arc<Window>) -> Result<(), AppStartupError> {
        let t0 = Instant::now();
        let width = self.config.window.width;
        let height = self.config.window.height;
        let backend_name = self.config.render.backend.clone();
        let power_name = self.config.render.power_preference.clone();
        let backends = wgpu::util::backend_bits_from_env().unwrap_or(
            match self.config.render.backend.as_str() {
                "dx12" => wgpu::Backends::DX12,
                "vulkan" => wgpu::Backends::VULKAN,
                "metal" => wgpu::Backends::METAL,
                _ => wgpu::Backends::PRIMARY,
            },
        );
        let power_preference = match self.config.render.power_preference.as_str() {
            "low" => wgpu::PowerPreference::LowPower,
            "none" => wgpu::PowerPreference::None,
            _ => wgpu::PowerPreference::HighPerformance,
        };
        let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
            backends,
            ..Default::default()
        });
        let surface: wgpu::Surface<'static> = instance
            .create_surface(Arc::clone(&window))
            .map_err(|error| AppStartupError {
                stage: AppStartupStage::Surface,
                backend: backend_name.clone(),
                power_preference: power_name.clone(),
                details: format!("Failed to create wgpu surface: {}", error),
            })?;
        let adapter = pollster::block_on(instance.request_adapter(&wgpu::RequestAdapterOptions {
            power_preference,
            compatible_surface: Some(&surface),
            force_fallback_adapter: false,
        }))
        .ok_or_else(|| AppStartupError {
            stage: AppStartupStage::Adapter,
            backend: backend_name.clone(),
            power_preference: power_name.clone(),
            details: "No compatible GPU adapter found. Try installing a display driver."
                .to_string(),
        })?;
        let adapter_info = adapter.get_info();
        log_msg!(
            info,
            L033_GPU_ADAPTER,
            "{} ({:?}, {:?}) [backend={}, power={}]",
            adapter_info.name,
            adapter_info.backend,
            adapter_info.device_type,
            self.config.render.backend,
            self.config.render.power_preference,
        );
        let (device, queue) = pollster::block_on(adapter.request_device(
            &wgpu::DeviceDescriptor {
                label: Some("Lurek2D Device"),
                required_features: wgpu::Features::empty(),
                required_limits: {
                    let mut limits = wgpu::Limits::downlevel_defaults();
                    limits.max_texture_dimension_2d = adapter
                        .limits()
                        .max_texture_dimension_2d
                        .max(limits.max_texture_dimension_2d);
                    limits
                },
                memory_hints: Default::default(),
            },
            None,
        ))
        .map_err(|error| AppStartupError {
            stage: AppStartupStage::Device,
            backend: backend_name.clone(),
            power_preference: power_name.clone(),
            details: format!(
                "Failed to create wgpu device for adapter '{}': {}",
                adapter_info.name, error
            ),
        })?;
        let caps = surface.get_capabilities(&adapter);
        if caps.formats.is_empty() {
            return Err(AppStartupError {
                stage: AppStartupStage::Device,
                backend: backend_name,
                power_preference: power_name,
                details: format!(
                    "Adapter '{}' reported no compatible surface formats",
                    adapter_info.name
                ),
            });
        }
        let surface_format = caps
            .formats
            .iter()
            .copied()
            .find(|f| f.is_srgb())
            .unwrap_or(caps.formats[0]);
        let surface_features = adapter.get_texture_format_features(surface_format);
        let depth_features =
            adapter.get_texture_format_features(wgpu::TextureFormat::Depth24PlusStencil8);
        let sample_count = if surface_features.flags.sample_count_supported(4)
            && surface_features
                .flags
                .contains(wgpu::TextureFormatFeatureFlags::MULTISAMPLE_RESOLVE)
            && depth_features.flags.sample_count_supported(4)
        {
            4
        } else {
            log::warn!("MSAA 4x unavailable for the active surface/depth formats; using 1x");
            1
        };
        self.surface_format = surface_format;
        self.surface_alpha_mode = caps.alpha_modes[0];
        self.surface_present_modes = caps.present_modes.clone();
        self.surface_usage = if caps.usages.contains(wgpu::TextureUsages::COPY_SRC) {
            wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::COPY_SRC
        } else {
            log_msg!(warn, L070_SURFACE_NO_READBACK);
            wgpu::TextureUsages::RENDER_ATTACHMENT
        };
        (self.surface_present_mode, self.window_vsync_mode) =
            Self::resolve_present_mode(&self.surface_present_modes, self.window_vsync_mode);
        self.max_surface_dim = device.limits().max_texture_dimension_2d;
        log_msg!(info, L034_GPU_TEX_DIM, "{}", self.max_surface_dim);
        let (cw, ch) = self.clamp_surface_dims(width, height);
        if cw != width || ch != height {
            log_msg!(
                warn,
                L023_GPU_TEX_TOO_SMALL,
                "initial window {}x{} exceeds GPU max {}; clamping to {}x{}",
                width,
                height,
                self.max_surface_dim,
                cw,
                ch
            );
        }
        surface.configure(&device, &self.surface_configuration(cw, ch));
        let renderer = GpuRenderer::new(device, queue, surface_format, cw, ch, sample_count);
        let render_budget_limits = renderer.effective_render_budget_limits();
        let render_capabilities = renderer.render_capabilities();
        self.surface = Some(surface);
        self.renderer = Some(renderer);
        if let Some(state) = self.state.as_ref() {
            let mut shared_state = state.borrow_mut();
            shared_state.render_budget_limits = render_budget_limits;
            shared_state.render_capabilities = render_capabilities;
        }
        self.window = Some(window);
        log_msg!(
            info,
            L035_GPU_INIT,
            "{:.0?} (format={:?}, present={:?}, {}x{})",
            t0.elapsed(),
            surface_format,
            self.surface_present_mode,
            width,
            height,
        );
        Ok(())
    }
    /// Create the Lua VM, load main.lua, and fire `lurek.init()`.
    pub fn init_lua(&mut self) {
        self.reset_runtime_accumulators();
        if let Some(conf_err) = self.conf_error.take() {
            self.run_state = RunState::Error(ErrorScreen::from_error(&format!(
                "Configuration Error\n{}",
                conf_err
            )));
            return;
        }
        match self.build_runtime_session() {
            Ok(session) => self.apply_runtime_session(session),
            Err(error) => {
                self.state = error.state;
                self.lua = None;
                self.has_game = false;
                self.run_state = RunState::Error(error.screen);
            }
        }
    }
}
