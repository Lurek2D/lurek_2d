//! Owns the app app main loop implementation for the app subsystem and keeps related runtime rules local here.
//! Keeps application state, orchestration, and window actions so helpers stay close to invariants this file updates.
//! Defines how app app main loop data is validated, transformed, or stored before neighboring systems consume it.
//! Separates app app main loop behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where app code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing app app main loop defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near app app main loop state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping app app main loop calculations explicit at their owning subsystem boundary.
//! Provides local adaptation layer that lets callers reuse app app main loop rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on app app main loop state, helpers, or rules.
//! Works with neighboring app owners while keeping the main app app main loop responsibility anchored in one file.
//! Changes to app app main loop names, caches, or helper boundaries should usually stay coupled inside this owner.
//! This file is the right stop for maintainers tracing app app main loop regressions back to their concrete owner boundary.

use super::*;

impl LurekApp {
    /// Advance clocks, poll input devices, and update the debug overlay flag.
    pub(super) fn tick_frame(&mut self) {
        enum ReplayCallback {
            KeyPressed(String), KeyReleased(String), MousePressed(f32, f32, u32, u32),
            MouseReleased(f32, f32, u32, u32), GamepadPressed(usize, String),
            GamepadReleased(usize, String), GamepadAxis(usize, String, f32), Text(String),
        }
        let mut replay_callbacks = Vec::new();
        if let Some(state) = &self.state {
            let mut st = state.borrow_mut();
            let dt = st.clock.tick();
            st.delta_time = dt;
            st.total_time = st.clock.total();
            st.fps = st.clock.fps();
            if st.input_recorder.is_recording() {
                let frame = st.clock.frame_count();
                let events = st
                    .input_history
                    .snapshot()
                    .into_iter()
                    .filter(|event| event.frame == frame)
                    .map(|event| crate::input::recorder::InputEvent {
                        kind: match event.kind {
                            crate::input::InputEventKind::Press => "press",
                            crate::input::InputEventKind::Release => "release",
                            crate::input::InputEventKind::Axis => "axis",
                            crate::input::InputEventKind::Motion => "motion",
                            crate::input::InputEventKind::Wheel => "wheel",
                            crate::input::InputEventKind::Text => "text",
                            crate::input::InputEventKind::Connect => "connect",
                            crate::input::InputEventKind::Disconnect => "disconnect",
                        }
                        .to_string(),
                        name: event.control,
                        device: match event.device {
                            crate::input::InputDevice::Keyboard => "keyboard".to_string(),
                            crate::input::InputDevice::Mouse => "mouse".to_string(),
                            crate::input::InputDevice::Gamepad(id) => format!("gamepad:{id}"),
                            crate::input::InputDevice::Touch => "touch".to_string(),
                        },
                        value: event.value,
                        position: event.position,
                    })
                    .collect();
                let mouse_x = st.mouse.x as f64;
                let mouse_y = st.mouse.y as f64;
                let capture_time_ms = (st.clock.total() * 1000.0).max(0.0) as u64;
                st.input_recorder
                    .record_frame_at(events, Some(mouse_x), Some(mouse_y), Some(capture_time_ms));
            }
            st.keyboard.begin_frame();
            st.touch.begin_frame();
            for gp in &mut st.gamepads {
                gp.begin_frame();
            }
            if st.input_recorder.is_playing_back() {
                let playback = st
                    .input_recorder
                    .playback_frame_timed((dt * 1000.0).max(0.0) as u64);
                if let Some(mouse_x) = playback.mouse_x {
                    st.mouse.x = mouse_x as f32;
                }
                if let Some(mouse_y) = playback.mouse_y {
                    st.mouse.y = mouse_y as f32;
                }
                let frame = st.clock.frame_count();
                let time_ms = (st.clock.total() * 1000.0).max(0.0) as u64;
                for event in playback.key_events {
                    let kind = match event.kind.as_str() {
                        "press" => crate::input::InputEventKind::Press,
                        "release" => crate::input::InputEventKind::Release,
                        "axis" => crate::input::InputEventKind::Axis,
                        "motion" => crate::input::InputEventKind::Motion,
                        "wheel" => crate::input::InputEventKind::Wheel,
                        "text" => crate::input::InputEventKind::Text,
                        "connect" => crate::input::InputEventKind::Connect,
                        "disconnect" => crate::input::InputEventKind::Disconnect,
                        _ => continue,
                    };
                    let device = if event.device == "mouse" {
                        crate::input::InputDevice::Mouse
                    } else if event.device == "touch" {
                        crate::input::InputDevice::Touch
                    } else if let Some(id) = event.device.strip_prefix("gamepad:").and_then(|id| id.parse::<usize>().ok()) {
                        while st.gamepads.len() <= id {
                            let new_id = st.gamepads.len() as u32;
                            st.gamepads.push(crate::input::GamepadState::new(new_id));
                        }
                        crate::input::InputDevice::Gamepad(id)
                    } else {
                        crate::input::InputDevice::Keyboard
                    };
                    match (&device, &kind) {
                        (crate::input::InputDevice::Keyboard, crate::input::InputEventKind::Press) => { st.keyboard.set_key_down(&event.name); replay_callbacks.push(ReplayCallback::KeyPressed(event.name.clone())); }
                        (crate::input::InputDevice::Keyboard, crate::input::InputEventKind::Release) => { st.keyboard.set_key_up(&event.name); replay_callbacks.push(ReplayCallback::KeyReleased(event.name.clone())); }
                        (crate::input::InputDevice::Keyboard, crate::input::InputEventKind::Text) => { st.keyboard.push_text_input(event.name.clone()); replay_callbacks.push(ReplayCallback::Text(event.name.clone())); }
                        (crate::input::InputDevice::Mouse, crate::input::InputEventKind::Press | crate::input::InputEventKind::Release) => {
                            if let Some(button) = event.name.strip_prefix("mouse").and_then(|button| button.parse::<usize>().ok()) {
                                st.mouse.set_button(button.saturating_sub(1), kind == crate::input::InputEventKind::Press);
                                let clicks = if kind == crate::input::InputEventKind::Press {
                                    st.mouse.register_click(button.saturating_sub(1), time_ms)
                                } else { st.mouse.click_count(button.saturating_sub(1)) };
                                if kind == crate::input::InputEventKind::Press { replay_callbacks.push(ReplayCallback::MousePressed(st.mouse.x, st.mouse.y, button as u32, clicks)); }
                                else { replay_callbacks.push(ReplayCallback::MouseReleased(st.mouse.x, st.mouse.y, button as u32, clicks)); }
                            }
                        }
                        (crate::input::InputDevice::Mouse, crate::input::InputEventKind::Motion) => {
                            if let Some((x, y)) = event.position { st.mouse.accumulate_delta(x, y); }
                        }
                        (crate::input::InputDevice::Mouse, crate::input::InputEventKind::Wheel) => {
                            if let Some((x, y)) = event.position { st.mouse.accumulate_scroll(x as f64, y as f64); }
                        }
                        (crate::input::InputDevice::Gamepad(id), crate::input::InputEventKind::Press | crate::input::InputEventKind::Release) => {
                            if let Some(button) = crate::input::standard_button_code(&event.name).or_else(|| event.name.parse().ok()) {
                                st.gamepads[*id].update_button(button, kind == crate::input::InputEventKind::Press);
                                if kind == crate::input::InputEventKind::Press { replay_callbacks.push(ReplayCallback::GamepadPressed(*id, event.name.clone())); }
                                else { replay_callbacks.push(ReplayCallback::GamepadReleased(*id, event.name.clone())); }
                            }
                        }
                        (crate::input::InputDevice::Gamepad(id), crate::input::InputEventKind::Axis) => {
                            if let Some(axis) = crate::input::standard_axis_code(&event.name).or_else(|| event.name.parse().ok()) {
                                st.gamepads[*id].update_axis(axis, event.value.unwrap_or(0.0));
                                replay_callbacks.push(ReplayCallback::GamepadAxis(*id, event.name.clone(), event.value.unwrap_or(0.0)));
                            }
                        }
                        (crate::input::InputDevice::Gamepad(id), crate::input::InputEventKind::Connect) => st.gamepads[*id].set_connected(true),
                        (crate::input::InputDevice::Gamepad(id), crate::input::InputEventKind::Disconnect) => st.gamepads[*id].set_connected(false),
                        _ => {}
                    }
                    st.input_history.push(crate::input::InputHistoryEvent {
                        frame,
                        time_ms,
                        device,
                        kind,
                        control: event.name,
                        value: event.value,
                        position: event.position,
                    });
                }
            }
            self.debug_overlay.enabled = st.debug_overlay_enabled;
        }
        if self.has_game {
            if let Some(lua) = &self.lua {
                for callback in replay_callbacks {
                    match callback {
                        ReplayCallback::KeyPressed(key) => call_lua_callback_with_timeout(lua, "keypressed", (key, String::new(), false), self.callback_timeout_ms()),
                        ReplayCallback::KeyReleased(key) => call_lua_callback_with_timeout(lua, "keyreleased", (key, String::new()), self.callback_timeout_ms()),
                        ReplayCallback::MousePressed(x, y, button, clicks) => call_lua_callback_with_timeout(lua, "mousepressed", (x, y, button, clicks), self.callback_timeout_ms()),
                        ReplayCallback::MouseReleased(x, y, button, clicks) => call_lua_callback_with_timeout(lua, "mousereleased", (x, y, button, clicks), self.callback_timeout_ms()),
                        ReplayCallback::GamepadPressed(id, button) => call_lua_callback_with_timeout(lua, "gamepadpressed", (id as u32, button), self.callback_timeout_ms()),
                        ReplayCallback::GamepadReleased(id, button) => call_lua_callback_with_timeout(lua, "gamepadreleased", (id as u32, button), self.callback_timeout_ms()),
                        ReplayCallback::GamepadAxis(id, axis, value) => call_lua_callback_with_timeout(lua, "gamepadaxis", (id as u32, axis, value), self.callback_timeout_ms()),
                        ReplayCallback::Text(text) => call_lua_callback_with_timeout(lua, "textinput", text, self.callback_timeout_ms()),
                    }
                }
            }
        }
        self.apply_pending_window_actions();
    }

    /// Normalizes pending window runtime requests and records any clamping or fallback adjustments.
    pub(super) fn validate_window_runtime_request(
        &self,
        pending_size: Option<(u32, u32)>,
        pending_scale_mode: Option<String>,
        pending_vsync: Option<i32>,
    ) -> WindowRuntimeValidation {
        let mut report = WindowRuntimeReport::default();
        let size = pending_size.map(|(width, height)| {
            let clamped = self.clamp_surface_dims(width, height);
            if clamped != (width, height) {
                report.clamped_size = Some(((width, height), clamped));
            }
            clamped
        });
        let scale_mode = pending_scale_mode.and_then(|mode| {
            if SUPPORTED_SCALE_MODES.contains(&mode.as_str()) {
                Some(mode)
            } else {
                report.invalid_scale_mode = Some(mode);
                None
            }
        });
        let vsync_mode = pending_vsync.map(|requested| {
            let (_, normalized) =
                Self::resolve_present_mode(&self.surface_present_modes, requested);
            if normalized != requested {
                report.vsync_adjustment = Some((requested, normalized));
            }
            normalized
        });
        (size, scale_mode, vsync_mode, report)
    }

    /// Expose window-runtime validation as a stable test seam.
    pub fn inspect_window_runtime_request_for_testing(
        &self,
        pending_size: Option<(u32, u32)>,
        pending_scale_mode: Option<String>,
        pending_vsync: Option<i32>,
    ) -> WindowRuntimeReport {
        let (_, _, _, report) =
            self.validate_window_runtime_request(pending_size, pending_scale_mode, pending_vsync);
        report
    }

    /// Apply deferred window property changes requested by Lua during the frame.
    pub(super) fn apply_pending_window_actions(&mut self) {
        let window = match &self.window {
            Some(w) => w.clone(),
            None => return,
        };
        let state = match &self.state {
            Some(s) => s.clone(),
            None => return,
        };
        let (
            pending_title,
            pending_fullscreen,
            pending_fullscreen_type,
            pending_position,
            pending_display_index,
            pending_size,
            pending_minimize,
            pending_maximize,
            pending_restore,
            pending_focus,
            pending_attention,
            pending_icon_path,
            pending_vsync,
            pending_close,
            text_input_enabled,
            mouse_visible,
            mouse_grabbed,
            mouse_relative_mode,
            mouse_cursor,
            pending_cursor_position,
            pending_scale_mode,
        ) = {
            let mut st = state.borrow_mut();
            (
                st.window_state.pending_title.take(),
                st.window_state.pending_fullscreen.take(),
                st.window_state.pending_fullscreen_type,
                st.window_state.pending_position.take(),
                st.window_state.pending_display_index.take(),
                st.window_state.pending_size.take(),
                std::mem::take(&mut st.window_state.pending_minimize),
                std::mem::take(&mut st.window_state.pending_maximize),
                std::mem::take(&mut st.window_state.pending_restore),
                std::mem::take(&mut st.window_state.pending_focus),
                std::mem::take(&mut st.window_state.pending_attention),
                st.window_state.pending_icon_path.take(),
                st.window_state.pending_vsync.take(),
                std::mem::take(&mut st.window_state.pending_close),
                st.keyboard.has_text_input(),
                st.mouse.is_visible(),
                st.mouse.is_grabbed(),
                st.mouse.get_relative_mode(),
                st.mouse.get_cursor(),
                st.mouse.take_pending_position(),
                st.window_state.pending_scale_mode.take(),
            )
        };
        let (pending_size, pending_scale_mode, pending_vsync, mut runtime_report) =
            self.validate_window_runtime_request(pending_size, pending_scale_mode, pending_vsync);
        if let Some(title) = pending_title {
            window.set_title(&title);
            state.borrow_mut().window_title = title;
        }
        if let Some(fullscreen) = pending_fullscreen {
            if fullscreen {
                use winit::window::Fullscreen;
                match pending_fullscreen_type {
                    FullscreenType::Desktop => {
                        window.set_fullscreen(Some(Fullscreen::Borderless(None)));
                    }
                    FullscreenType::Exclusive => {
                        if let Some(monitor) = window.current_monitor() {
                            if let Some(mode) = monitor.video_modes().next() {
                                window.set_fullscreen(Some(Fullscreen::Exclusive(mode)));
                            }
                        }
                    }
                }
                state.borrow_mut().window_state.fullscreen = true;
                state.borrow_mut().window_state.fullscreen_type = pending_fullscreen_type;
            } else {
                window.set_fullscreen(None);
                state.borrow_mut().window_state.fullscreen = false;
            }
        }
        if let Some((x, y)) = pending_position {
            window.set_outer_position(winit::dpi::PhysicalPosition::new(x, y));
        }
        if let Some(display_index) = pending_display_index {
            if !move_window_to_display(window.as_ref(), display_index) {
                log::warn!("Requested display index {} is not available", display_index);
                runtime_report.invalid_display_index = Some(display_index);
            }
        }
        if let Some((w, h)) = pending_size {
            let _ = window.request_inner_size(winit::dpi::PhysicalSize::new(w, h));
        }
        if pending_minimize {
            window.set_minimized(true);
        }
        if pending_maximize {
            window.set_maximized(true);
        }
        if pending_restore {
            window.set_minimized(false);
            window.set_maximized(false);
        }
        if pending_focus {
            window.focus_window();
        }
        if pending_attention {
            window.request_user_attention(Some(winit::window::UserAttentionType::Informational));
        }
        if let Some(icon_path) = pending_icon_path {
            let icon = {
                let st = state.borrow();
                load_window_icon(&st.game_dir, &icon_path)
            };
            if let Some(icon) = icon {
                window.set_window_icon(Some(icon));
            }
        }
        if let Some(vsync_mode) = pending_vsync {
            self.apply_vsync_mode(vsync_mode);
        }
        window.set_ime_allowed(text_input_enabled);
        let requested_grab_mode = if mouse_relative_mode {
            CursorGrabMode::Locked
        } else if mouse_grabbed {
            CursorGrabMode::Confined
        } else {
            CursorGrabMode::None
        };
        if let Err(error) = window.set_cursor_grab(requested_grab_mode) {
            if mouse_relative_mode {
                if let Err(confined_error) = window.set_cursor_grab(CursorGrabMode::Confined) {
                    log_msg!(debug, L071_CURSOR_GRAB_FAIL, "{}", confined_error);
                }
            } else if mouse_grabbed {
                log_msg!(debug, L072_CURSOR_GRAB_LOCK_FAIL, "{}", error);
            }
        }
        window.set_cursor_visible(if mouse_relative_mode {
            false
        } else {
            mouse_visible
        });
        window.set_cursor(system_cursor_to_winit_cursor(mouse_cursor));
        if let Some((x, y)) = pending_cursor_position {
            let cursor_position = winit::dpi::PhysicalPosition::new(x as f64, y as f64);
            if let Err(error) = window.set_cursor_position(cursor_position) {
                log_msg!(debug, L073_CURSOR_POS_FAIL, "{}", error);
            }
        }
        if pending_close {
            state.borrow_mut().quit_requested = true;
        }
        if let Some(new_mode) = pending_scale_mode {
            if let Some(state) = &self.state {
                let mut st = state.borrow_mut();
                st.window_state.scale_mode_str = new_mode;
                let (ww, wh) = (st.window_width, st.window_height);
                recompute_viewport(&mut st.window_state, ww, wh);
            }
        }
        self.push_window_report(runtime_report);
    }
    /// Run the full game-update sequence: physics, process, draw, and overlay.
    pub(super) fn game_update(&mut self) {
        let Some(state) = self.state.as_ref().cloned() else {
            return;
        };
        if self.lua.is_none() {
            return;
        }
        let callback_timeout_ms = self.callback_timeout_ms();
        if self.auto_screenshot_path.is_some() && !self.auto_screenshot_done {
            if self.auto_screenshot_frame_count == 0 {
                self.auto_screenshot_start = Some(Instant::now());
            }
            self.auto_screenshot_frame_count += 1;
        }
        if (self.auto_quit_frames.is_some() || self.auto_quit_time.is_some())
            && !self.auto_quit_done
        {
            if self.auto_quit_frame_count == 0 {
                self.auto_quit_start = Some(Instant::now());
            }
            self.auto_quit_frame_count += 1;
        }
        if !self.ready_fired {
            self.ready_fired = true;
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_callback_checked_with_timeout(lua, "ready", (), callback_timeout_ms).err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("ready", "frame.ready", error) {
                    return;
                }
                return;
            }
        }
        let dt = state.borrow().clock.delta();
        let mut frame_profile = crate::runtime::FrameProfile::default();
        {
            let phase_start = Instant::now();
            let fixed_dt = state.borrow().physics_run.fixed_dt;
            self.physics_accumulator += dt;
            let max_steps = state.borrow().physics_run.max_steps as usize;
            let mut steps = 0;
            while self.physics_accumulator >= fixed_dt && steps < max_steps {
                self.physics_accumulator -= fixed_dt;
                steps += 1;
                let error = {
                    let lua = self.lua.as_ref().expect("lua checked above");
                    call_lua_callback_checked_with_timeout(
                        lua,
                        "process_physics",
                        fixed_dt,
                        callback_timeout_ms,
                    )
                    .err()
                };
                if let Some(error) = error {
                    if self.handle_callback_error("process_physics", "frame.process_physics", error)
                    {
                        return;
                    }
                    return;
                }
            }
            frame_profile.process_physics_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        {
            let phase_start = Instant::now();
            let fixed_dt = state.borrow().physics_run.fixed_update_dt;
            if fixed_dt > 0.0 {
                let has_fixed_update = self
                    .lua
                    .as_ref()
                    .map(|lua| has_lua_callback(lua, "fixedUpdate"))
                    .unwrap_or(false);
                if !self.fixed_update_deprecation_warned && has_fixed_update {
                    log::warn!(
                        "lurek.fixedUpdate(dt) is deprecated; use lurek.process_physics(dt)"
                    );
                    self.fixed_update_deprecation_warned = true;
                }
                self.fixed_update_accumulator += dt;
                let max_steps = 8;
                let mut steps = 0;
                while self.fixed_update_accumulator >= fixed_dt && steps < max_steps {
                    self.fixed_update_accumulator -= fixed_dt;
                    steps += 1;
                    let error = {
                        let lua = self.lua.as_ref().expect("lua checked above");
                        call_lua_callback_checked_with_timeout(
                            lua,
                            "fixedUpdate",
                            fixed_dt,
                            callback_timeout_ms,
                        )
                        .err()
                    };
                    if let Some(error) = error {
                        if self.handle_callback_error("fixedUpdate", "frame.fixed_update", error) {
                            return;
                        }
                        return;
                    }
                }
            }
            frame_profile.fixed_update_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        {
            let phase_start = Instant::now();
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_callback_checked_with_timeout(lua, "process", dt, callback_timeout_ms)
                    .err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("process", "frame.process", error) {
                    return;
                }
                return;
            }
            frame_profile.process_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        {
            let phase_start = Instant::now();
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_callback_checked_with_timeout(lua, "process_late", dt, callback_timeout_ms)
                    .err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("process_late", "frame.process_late", error) {
                    return;
                }
                return;
            }
            frame_profile.process_late_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        if shared_flag(&self.state, |st| st.auto_ui_update) {
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_ui_update(lua, dt as f32, callback_timeout_ms).err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("ui.update", "frame.ui_update", error) {
                    return;
                }
                return;
            }
        }
        {
            let mut s = state.borrow_mut();
            s.render_commands.clear();
            s.raycaster_output = None;
        }
        {
            let s = state.borrow();
            let cam_x = s.camera.position.x;
            let cam_y = s.camera.position.y;
            let screen_w = s.window_state.game_width;
            let screen_h = s.window_state.game_height;
            self.auto_parallax_buf.clear();
            self.auto_parallax_buf
                .extend(s.auto_parallax_layers.iter().filter_map(|w| w.upgrade()));
            drop(s);
            for rc in &self.auto_parallax_buf {
                let cmds = rc
                    .borrow()
                    .generate_render_commands(cam_x, cam_y, screen_w, screen_h);
                let mut st = state.borrow_mut();
                let previous_shader = st.active_shader;
                let changed_shader = cmds
                    .iter()
                    .any(|command| matches!(command, RenderCommand::SetShader(_)));
                st.render_commands.extend(cmds);
                if changed_shader {
                    if let Some(shader_key) = previous_shader {
                        st.render_commands
                            .push(RenderCommand::SetShader(Some(shader_key)));
                    }
                }
            }
            state
                .borrow_mut()
                .auto_parallax_layers
                .retain(|w| w.upgrade().is_some());
        }
        {
            let s = state.borrow();
            let cam_x = s.camera.position.x;
            let cam_y = s.camera.position.y;
            let cam_w = s.window_state.game_width;
            let cam_h = s.window_state.game_height;
            self.auto_tilemap_buf.clear();
            self.auto_tilemap_buf
                .extend(s.auto_tilemaps.iter().filter_map(|w| w.upgrade()));
            drop(s);
            for rc in &self.auto_tilemap_buf {
                let cmds = rc
                    .borrow()
                    .generate_render_commands(0.0, 0.0, cam_x, cam_y, cam_w, cam_h);
                let mut st = state.borrow_mut();
                let previous_shader = st.active_shader;
                let changed_shader = cmds
                    .iter()
                    .any(|command| matches!(command, RenderCommand::SetShader(_)));
                st.render_commands.extend(cmds);
                if changed_shader {
                    if let Some(shader_key) = previous_shader {
                        st.render_commands
                            .push(RenderCommand::SetShader(Some(shader_key)));
                    }
                }
            }
            state
                .borrow_mut()
                .auto_tilemaps
                .retain(|w| w.upgrade().is_some());
        }
        {
            let phase_start = Instant::now();
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_callback_checked_with_timeout(lua, "draw", (), callback_timeout_ms).err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("draw", "frame.draw", error) {
                    return;
                }
                return;
            }
            frame_profile.draw_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        {
            let scene_opt = state.borrow_mut().raycaster_output.take();
            if let Some(scene) = scene_opt {
                let mut s = state.borrow_mut();
                let render_state = RaycasterRenderState {
                    scene_shader: s.raycaster_shader,
                    restore_shader: s.active_shader,
                    restore_blend: s.blend_mode,
                };
                s.render_commands
                    .extend(scene.generate_render_commands_with_state(render_state));
            }
        }
        {
            self.auto_particle_cmd_buf.clear();
            {
                let s = state.borrow();
                for ps in s.particle_systems.values() {
                    self.auto_particle_cmd_buf
                        .extend(ps.generate_render_commands());
                }
            }
            state
                .borrow_mut()
                .render_commands
                .extend(self.auto_particle_cmd_buf.iter().cloned());
        }
        {
            let phase_start = Instant::now();
            let error = {
                let lua = self.lua.as_ref().expect("lua checked above");
                call_lua_callback_checked_with_timeout(lua, "draw_ui", (), callback_timeout_ms)
                    .err()
            };
            if let Some(error) = error {
                if self.handle_callback_error("draw_ui", "frame.draw_ui", error) {
                    return;
                }
                return;
            }
            frame_profile.draw_ui_ms = phase_start.elapsed().as_secs_f64() as f32 * 1000.0;
        }
        {
            self.auto_ui_cmd_buf.clear();
            let ui_ctx = {
                let st = state.borrow();
                st.auto_ui_ctx.as_ref().and_then(|w| w.upgrade())
            };
            if let Some(rc) = ui_ctx {
                let st = state.borrow();
                if let Some(font_key) = st.active_font.or(st.default_font) {
                    self.auto_ui_cmd_buf.extend(
                        rc.borrow_mut()
                            .build_render_commands_with_fonts(font_key, &st.fonts),
                    );
                }
            }
            state
                .borrow_mut()
                .render_commands
                .extend(self.auto_ui_cmd_buf.iter().cloned());
        }
        let (fps, draw_calls, w) = {
            let st = state.borrow();
            (st.fps, st.render_stats.draw_calls, st.window_width)
        };
        let overlay_font = state.borrow().active_font.or(state.borrow().default_font);
        let overlay_cmds =
            self.debug_overlay
                .build_render_commands(w, fps, draw_calls, overlay_font);
        if !overlay_cmds.is_empty() {
            state.borrow_mut().render_commands.extend(overlay_cmds);
        }
        if let Some(font_key) = overlay_font {
            let shader_err = {
                let st = state.borrow();
                if st.shader_error_display_enabled {
                    st.last_shader_compile_error.clone()
                } else {
                    None
                }
            };
            if let Some(err) = shader_err {
                state
                    .borrow_mut()
                    .render_commands
                    .push(RenderCommand::Print {
                        font_key,
                        text: format!("Shader error: {}", err),
                        x: 12.0,
                        y: 28.0,
                        scale: 0.9,
                    });
            }
        }
        if let Some(lua) = &self.lua {
            let error = crate::lua_api::cursor_api::refresh_cursor_runtime(
                lua,
                state.clone(),
                callback_timeout_ms,
            )
            .err();
            if let Some(error) = error {
                if self.handle_callback_error("cursor", "frame.cursor", error) {
                    return;
                }
                return;
            }
        }
        frame_profile.callback_total_ms = frame_profile.process_physics_ms
            + frame_profile.fixed_update_ms
            + frame_profile.process_ms
            + frame_profile.process_late_ms
            + frame_profile.draw_ms
            + frame_profile.draw_ui_ms;
        state.borrow_mut().frame_profile = frame_profile;
    }
    /// Present the frame: collect render commands, call the GPU renderer, and handle screenshots.
    pub(super) fn render(&mut self) {
        let (Some(renderer), Some(surface), Some(state)) =
            (&mut self.renderer, &self.surface, &self.state)
        else {
            return;
        };
        let (
            commands,
            default_filter,
            bg,
            cam_matrix,
            frame_time,
            frame_count,
            vp_scale_x,
            vp_scale_y,
            vp_offset_x,
            vp_offset_y,
            vp_mode,
            game_w,
            game_h,
            screenshot_request,
            screen_capture_requested,
            textures,
            shaders,
            canvases,
            meshes,
            sprite_batches,
            mut fonts,
        ) = {
            let mut st = state.borrow_mut();
            (
                std::mem::take(&mut st.render_commands),
                st.default_filter.clone(),
                st.background_color,
                st.camera.view_matrix(),
                st.total_time as f32,
                st.frame_counter,
                st.window_state.viewport_scale_x,
                st.window_state.viewport_scale_y,
                st.window_state.viewport_offset_x,
                st.window_state.viewport_offset_y,
                st.window_state.scale_mode_str.clone(),
                st.window_state.game_width,
                st.window_state.game_height,
                st.pending_screenshot.take(),
                std::mem::replace(&mut st.pending_screen_capture, false),
                std::mem::take(&mut st.textures),
                std::mem::take(&mut st.shaders),
                std::mem::take(&mut st.canvases),
                std::mem::take(&mut st.meshes),
                std::mem::take(&mut st.sprite_batches),
                std::mem::take(&mut st.fonts),
            )
        };
        let use_viewport = vp_mode != "none"
            && (vp_scale_x != 1.0 || vp_scale_y != 1.0 || vp_offset_x != 0.0 || vp_offset_y != 0.0);
        if use_viewport {
            self.render_cmd_buf.clear();
            if vp_mode == "letterbox" || vp_mode == "pixel" {
                self.render_cmd_buf.push(RenderCommand::SetScissor(Some((
                    vp_offset_x,
                    vp_offset_y,
                    game_w * vp_scale_x,
                    game_h * vp_scale_y,
                ))));
            }
            self.render_cmd_buf.push(RenderCommand::PushTransform);
            self.render_cmd_buf.push(RenderCommand::Translate {
                x: vp_offset_x,
                y: vp_offset_y,
            });
            self.render_cmd_buf.push(RenderCommand::Scale {
                sx: vp_scale_x,
                sy: vp_scale_y,
            });
            self.render_cmd_buf.extend(commands.iter().cloned());
            self.render_cmd_buf.push(RenderCommand::PopTransform);
            if vp_mode == "letterbox" || vp_mode == "pixel" {
                self.render_cmd_buf.push(RenderCommand::SetScissor(None));
            }
        }
        let final_commands: &Vec<RenderCommand> = if use_viewport {
            &self.render_cmd_buf
        } else {
            &commands
        };
        let screenshot_supported = self.surface_usage.contains(wgpu::TextureUsages::COPY_SRC);
        let capture_screenshot = screenshot_request.is_some() && screenshot_supported;
        let capture_screen_image = screen_capture_requested && screenshot_supported;
        let auto_screenshot_ready = match self.auto_screenshot_time {
            Some(secs) => {
                self.auto_screenshot_start
                    .map(|s| s.elapsed().as_secs_f32() >= secs)
                    .unwrap_or(false)
                    && self.auto_screenshot_frame_count >= 3
            }
            None => self.auto_screenshot_frame_count >= self.auto_screenshot_frames,
        };
        let should_auto_capture = screenshot_supported
            && !self.auto_screenshot_done
            && self.auto_screenshot_path.is_some()
            && auto_screenshot_ready;
        let screenshot_pixels = {
            let s_ref = state.borrow();
            renderer.render_frame(
                surface,
                final_commands,
                &s_ref.province_registries,
                &textures,
                &mut fonts,
                &s_ref.light_world,
                &sprite_batches,
                &s_ref.shapes,
                &canvases,
                &meshes,
                &shaders,
                &default_filter,
                bg,
                &cam_matrix,
                frame_time,
                frame_count,
                capture_screenshot || should_auto_capture || capture_screen_image,
            )
        };
        let screenshot_pixels = match screenshot_pixels {
            Ok(screenshot) => screenshot,
            Err(e) => {
                let recovery_action = crate::render::surface_error_action(&e);
                if recovery_action == crate::render::RenderRecoveryAction::ReconfigureSurface {
                    log_msg!(warn, L024_SURFACE_LOST);
                    {
                        let mut st = state.borrow_mut();
                        st.fonts = fonts;
                        st.sprite_batches = sprite_batches;
                        st.textures = textures;
                        st.shaders = shaders;
                        st.canvases = canvases;
                        st.meshes = meshes;
                        st.pending_screenshot = screenshot_request;
                        st.pending_screen_capture = screen_capture_requested;
                    }
                    self.reconfigure_surface();
                    return;
                } else if recovery_action == crate::render::RenderRecoveryAction::Shutdown {
                    // Do not expose driver details or attempt another allocation after OOM.
                    self.run_state = RunState::Error(ErrorScreen::from_error(
                        "The graphics device ran out of memory; rendering has been stopped safely.",
                    ));
                } else {
                    log_msg!(error, L010_RENDER_ERROR, "{:?}", e);
                }
                None
            }
        };
        if let Some(action) = renderer.take_uncaptured_recovery_action() {
            let message = match action {
                crate::render::RenderRecoveryAction::Shutdown => {
                    "The graphics device ran out of memory; rendering has been stopped safely."
                }
                crate::render::RenderRecoveryAction::RecoverDevice => {
                    "The graphics device reported an internal rendering failure; rendering has been stopped safely."
                }
                _ => "The graphics device entered an unrecoverable state; rendering has been stopped safely.",
            };
            // This app owner has no device recreation seam. Do not surface backend details or
            // continue submitting after an uncaptured validation/internal failure.
            self.run_state = RunState::Error(ErrorScreen::from_error(message));
        }
        {
            let mut st = state.borrow_mut();
            st.fonts = fonts;
            st.sprite_batches = sprite_batches;
            st.textures = textures;
            st.shaders = shaders;
            st.canvases = canvases;
            st.meshes = meshes;
            if capture_screen_image {
                st.captured_screen_image = screenshot_pixels.as_ref().and_then(
                    |(width, height, pixels)| {
                        crate::image::ImageData::from_bytes(*width, *height, pixels.clone()).ok()
                    },
                );
                if st.captured_screen_image.is_none()
                    && renderer.surface_readback_status
                        == crate::render::gpu_state::SurfaceReadbackStatus::Pending
                {
                    // The request was consumed for this frame, but its asynchronous map
                    // is still pending. Requeue exactly one follow-up poll frame.
                    st.pending_screen_capture = true;
                }
            }
        }
        state.borrow_mut().render_stats = renderer.render_stats.clone();
        if let Some(request) = screenshot_request {
            let mut request_still_pending = false;
            if !screenshot_supported {
                log_msg!(error, L074_SCREENSHOT_NO_READBACK, "path: {}", request.path);
            } else if let Some((width, height, ref pixels)) = screenshot_pixels {
                match crate::image::ImageData::from_bytes(width, height, pixels.clone())
                    .and_then(|image| image.encode_png())
                {
                    Ok(png) => {
                        if let Err(err) = state.borrow().fs.write_bytes(&request.path, &png) {
                            log_msg!(
                                error,
                                L075_SCREENSHOT_SAVE_FAIL,
                                "path: {}, err: {}",
                                request.path,
                                err
                            );
                        }
                    }
                    Err(err) => {
                        log_msg!(
                            error,
                            L076_SCREENSHOT_ENCODE_FAIL,
                            "path: {}, err: {}",
                            request.path,
                            err
                        );
                    }
                }
            } else if renderer.surface_readback_status
                == crate::render::gpu_state::SurfaceReadbackStatus::Pending
            {
                // GPU mapping is asynchronous; retain the request until a later frame
                // returns the completed bytes instead of silently dropping it.
                state.borrow_mut().pending_screenshot = Some(request);
                request_still_pending = true;
            }
            if !request_still_pending {
                state.borrow_mut().pending_screenshot = None;
            }
        }
        if should_auto_capture {
            if let Some(ref path) = self.auto_screenshot_path.clone() {
                if let Some((width, height, pixels)) = screenshot_pixels {
                    match crate::image::ImageData::from_bytes(width, height, pixels)
                        .and_then(|image| image.encode_png())
                    {
                        Ok(png) => {
                            if let Some(parent) = path.parent() {
                                let _ = std::fs::create_dir_all(parent);
                            }
                            if let Err(err) = std::fs::write(path, &png) {
                                log_msg!(
                                    error,
                                    L075_SCREENSHOT_SAVE_FAIL,
                                    "auto-screenshot path: {}, err: {}",
                                    path.display(),
                                    err
                                );
                            } else {
                                log_msg!(
                                    info,
                                    crate::runtime::log_messages::L001_ENGINE_START,
                                    "auto-screenshot saved to: {}",
                                    path.display()
                                );
                            }
                        }
                        Err(err) => {
                            log_msg!(
                                error,
                                L076_SCREENSHOT_ENCODE_FAIL,
                                "auto-screenshot path: {}, err: {}",
                                path.display(),
                                err
                            );
                        }
                    }
                }
                self.auto_screenshot_done = true;
                state.borrow_mut().quit_requested = true;
            }
        }
        if let Some(budget_ms) = self.config.performance.frame_budget_warn_ms {
            let elapsed_ms = self.last_frame.elapsed().as_secs_f64() * 1000.0;
            if elapsed_ms > budget_ms as f64 {
                log::warn!(
                    "frame budget exceeded: {:.2}ms > {}ms threshold",
                    elapsed_ms,
                    budget_ms
                );
            }
        }
    }
    /// Extract `.lurek` archive into a temp directory and reject unsafe paths.
    pub fn extract_lurek_archive_with_policy(
        archive_path: &std::path::Path,
        policy: &StartupTargetPolicy,
    ) -> Result<(std::path::PathBuf, tempfile::TempDir), String> {
        let metadata = std::fs::metadata(archive_path)
            .map_err(|e| format!("Cannot stat archive '{}': {}", archive_path.display(), e))?;
        if metadata.len() > policy.max_archive_bytes {
            return Err(format!(
                "Archive '{}' exceeds max size {} bytes (got {})",
                archive_path.display(),
                policy.max_archive_bytes,
                metadata.len()
            ));
        }
        let _ = policy;
        Err(format!(
            ".lurek archives are not built into this runtime build; pass an extracted game folder instead: {}",
            archive_path.display()
        ))
    }
    /// Tear down the current game session and reinitialise from the game directory.
    pub(super) fn restart_game(&mut self) {
        let report = self.reload_game_with_report("manual", Vec::new());
        if !report.reloaded && report.failure.is_some() && !report.rolled_back {
            log::warn!(
                "runtime restart failed without rollback: {}",
                report.failure.as_deref().unwrap_or("unknown error")
            );
        }
    }
    /// Poll content watchers and trigger a restart when scripts or assets changed.
    pub(super) fn poll_content_hot_reload(&mut self) {
        if !self.has_game {
            return;
        }
        let mut changed_paths = self.content_script_watcher.poll();
        changed_paths.extend(self.content_asset_watcher.poll());
        changed_paths.sort();
        changed_paths.dedup();
        if !changed_paths.is_empty() {
            for path in changed_paths {
                if !self.pending_hot_reload_paths.contains(&path) {
                    self.pending_hot_reload_paths.push(path);
                }
            }
            self.pending_hot_reload_deadline = Some(Instant::now() + self.hot_reload_debounce);
            return;
        }
        let Some(deadline) = self.pending_hot_reload_deadline else {
            return;
        };
        if Instant::now() < deadline || self.pending_hot_reload_paths.is_empty() {
            return;
        }
        let changed_paths = std::mem::take(&mut self.pending_hot_reload_paths);
        self.pending_hot_reload_deadline = None;
        log::info!(
            "content hot-reload triggered after debounce ({} path(s))",
            changed_paths.len()
        );
        let reload = self.reload_game_with_report("hot_reload", changed_paths.clone());
        self.push_hot_reload_report(HotReloadReport {
            changed_paths,
            reload,
        });
    }
    /// Poll the config watcher and apply updated conf.toml values.
    pub(super) fn poll_config_hot_reload(&mut self) {
        if self.conf_watcher.poll().is_empty() {
            return;
        }
        let (new_config, load_err) = Config::load(&self.game_dir);
        if let Some(err) = load_err {
            log::warn!("conf.toml hot-reload failed: {}", err);
            return;
        }
        let font_config_changed = self.config.render.default_font_size
            != new_config.render.default_font_size
            || self.config.render.default_font_bold != new_config.render.default_font_bold;
        self.config = new_config;
        self.window_vsync_mode = if self.config.window.vsync { 1 } else { 0 };
        if let Some(level) = self.config.log_level.as_deref() {
            crate::runtime::log_messages::set_log_level(level);
        }
        if let Some(window) = &self.window {
            window.set_title(&self.current_window_title());
        }
        if let Some(state) = &self.state {
            let mut st = state.borrow_mut();
            st.physics_run.fixed_dt = 1.0 / self.config.performance.physics_tick_rate.max(1) as f64;
            st.physics_run.fixed_update_dt = match self.config.performance.fixed_update_tick_rate {
                Some(rate) if rate > 0 => 1.0 / rate as f64,
                _ => 0.0,
            };
            st.frame_budget_warn_ms = self.config.performance.frame_budget_warn_ms;
            st.lua_callback_timeout_ms = self.callback_timeout_ms();
            st.set_configured_default_font(
                self.config.render.default_font_size,
                self.config.render.default_font_bold,
            );
            st.window_state.vsync_mode = self.window_vsync_mode;
            st.window_state.pending_vsync = Some(self.window_vsync_mode);
            st.window_state.game_width =
                self.config
                    .window
                    .game_width
                    .unwrap_or(self.config.window.width) as f32;
            st.window_state.game_height =
                self.config
                    .window
                    .game_height
                    .unwrap_or(self.config.window.height) as f32;
            st.window_state.scale_mode_str = self.config.window.scale_mode.clone();
            let (ww, wh) = (st.window_width, st.window_height);
            recompute_viewport(&mut st.window_state, ww, wh);
            st.config_reload_revision = st.config_reload_revision.saturating_add(1);
        }
        if font_config_changed {
            self.engine_fonts = None;
        }
        log::info!("conf.toml hot-reloaded successfully");
    }
    /// Reconfigure the wgpu surface after a lost or mode-change event.
    pub(super) fn reconfigure_surface(&mut self) {
        let Some((w, h)) = self
            .renderer
            .as_ref()
            .map(|renderer| (renderer.width, renderer.height))
        else {
            return;
        };
        let (w, h) = self.clamp_surface_dims(w, h);
        let surface_config = self.surface_configuration(w, h);
        let (Some(renderer), Some(surface)) = (&mut self.renderer, &self.surface) else {
            return;
        };
        surface.configure(&renderer.device, &surface_config);
    }
    /// Handle a window resize by updating renderer, surface, viewport, and firing `lurek.resize()`.
    pub(super) fn handle_resize(&mut self, width: u32, height: u32) {
        if width == 0 || height == 0 {
            return;
        }
        let (width, height) = self.clamp_surface_dims(width, height);
        let surface_config = self.surface_configuration(width, height);
        let (Some(renderer), Some(surface)) = (&mut self.renderer, &self.surface) else {
            return;
        };
        renderer.resize(width, height);
        surface.configure(&renderer.device, &surface_config);
        if let Some(state) = &self.state {
            let mut st = state.borrow_mut();
            st.window_width = width;
            st.window_height = height;
            recompute_viewport(&mut st.window_state, width, height);
        }
        if self.has_game {
            if let Some(lua) = &self.lua {
                call_lua_callback_with_timeout(
                    lua,
                    "resize",
                    (width, height),
                    self.callback_timeout_ms(),
                );
            }
        }
    }
}

/// Map a `SystemCursor` variant to a winit `CursorIcon`.
fn system_cursor_to_winit_cursor(cursor: SystemCursor) -> CursorIcon {
    match cursor {
        SystemCursor::Arrow => CursorIcon::Default,
        SystemCursor::IBeam => CursorIcon::Text,
        SystemCursor::Wait => CursorIcon::Wait,
        SystemCursor::Crosshair => CursorIcon::Crosshair,
        SystemCursor::Hand => CursorIcon::Pointer,
        SystemCursor::SizeNWSE => CursorIcon::NwseResize,
        SystemCursor::SizeNESW => CursorIcon::NeswResize,
        SystemCursor::SizeWE => CursorIcon::EwResize,
        SystemCursor::SizeNS => CursorIcon::NsResize,
        SystemCursor::SizeAll => CursorIcon::Move,
        SystemCursor::No => CursorIcon::NotAllowed,
    }
}
/// Load a custom window icon from the game directory.
fn load_window_icon(game_dir: &Path, icon_path: &str) -> Option<winit::window::Icon> {
    let resolved_path = {
        let path = Path::new(icon_path);
        if path.is_absolute() {
            path.to_path_buf()
        } else {
            game_dir.join(path)
        }
    };
    let image = match ::image::open(&resolved_path) {
        Ok(image) => image,
        Err(error) => {
            log_msg!(
                warn,
                L040_ICON_LOAD_FAIL,
                "'{}': {}",
                resolved_path.display(),
                error
            );
            return None;
        }
    };
    let rgba = image.to_rgba8();
    let (width, height) = (rgba.width(), rgba.height());
    match winit::window::Icon::from_rgba(rgba.into_raw(), width, height) {
        Ok(icon) => Some(icon),
        Err(error) => {
            log_msg!(
                warn,
                L041_ICON_CONV_FAIL,
                "'{}': {}",
                resolved_path.display(),
                error
            );
            None
        }
    }
}

/// Provide the ApplicationHandler behavior contract for LurekApp.
impl ApplicationHandler for LurekApp {
    /// Create the window, initialise GPU, and show the first frame.
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        if self.window.is_some() {
            return;
        }
        let initial_title = self.current_window_title();
        let mut window_attrs = Window::default_attributes()
            .with_visible(false)
            .with_title(&initial_title)
            .with_inner_size(winit::dpi::PhysicalSize::new(
                self.config.window.width,
                self.config.window.height,
            ))
            .with_resizable(self.config.window.resizable)
            .with_decorations(!self.config.window.borderless);
        if let (Some(w), Some(h)) = (self.config.window.min_width, self.config.window.min_height) {
            window_attrs = window_attrs.with_min_inner_size(winit::dpi::PhysicalSize::new(w, h));
        }
        let startup_monitor = select_startup_monitor(event_loop, self.config.window.display_index);
        let window = Arc::new(
            event_loop
                .create_window(window_attrs)
                .expect("Failed to create window"),
        );
        if self.config.window.fullscreen {
            window.set_fullscreen(Some(winit::window::Fullscreen::Borderless(
                startup_monitor.clone(),
            )));
        } else if let Some((wx, wy)) = self.window_pos {
            window.set_outer_position(winit::dpi::PhysicalPosition::new(wx, wy));
        } else if let Some(monitor) = startup_monitor.as_ref() {
            center_window_on_monitor(
                window.as_ref(),
                monitor,
                self.config.window.width,
                self.config.window.height,
            );
        }
        if self.config.window.maximized && !self.config.window.fullscreen {
            window.set_maximized(true);
        }
        if let Some(icon_path) = self.config.window.icon.as_deref() {
            if let Some(icon) = load_window_icon(&self.game_dir, icon_path) {
                window.set_window_icon(Some(icon));
            }
        }
        if let Err(error) = self.try_init_gpu(window.clone()) {
            self.window = Some(window);
            log::error!(
                "GPU startup failed [backend={}, power={}]: {}",
                error.backend,
                error.power_preference,
                error.details
            );
            self.run_state = map_startup_error_to_run_state(&error);
            return;
        }
        self.last_frame = Instant::now();
        if let Some(win) = &self.window {
            win.set_visible(true);
            win.request_redraw();
        }
    }
    /// Dispatch a window event to the appropriate input, rendering, or lifecycle handler.
    fn window_event(&mut self, event_loop: &ActiveEventLoop, _id: WindowId, event: WindowEvent) {
        match event {
            WindowEvent::CloseRequested => {
                log_msg!(info, L039_WINDOW_CLOSE);
                if let Some(lua) = &self.lua {
                    call_lua_callback_with_timeout(lua, "exit", (), self.callback_timeout_ms());
                }
                event_loop.exit();
            }
            WindowEvent::Resized(size) => {
                self.handle_resize(size.width, size.height);
            }
            WindowEvent::ScaleFactorChanged {
                scale_factor,
                inner_size_writer: _,
            } => {
                if let Some(state) = &self.state {
                    state.borrow_mut().window_state.dpi_scale = scale_factor;
                }
            }
            WindowEvent::Focused(focused) => {
                if let Some(state) = &self.state {
                    let mut state = state.borrow_mut();
                    state.window_state.focused = focused;
                    if !focused {
                        state.keyboard.clear_all();
                        state.mouse.clear_all();
                        self.ctrl_held = false;
                    }
                }
                if self.has_game {
                    if let Some(lua) = &self.lua {
                        call_lua_callback_with_timeout(
                            lua,
                            "focus",
                            (focused,),
                            self.callback_timeout_ms(),
                        );
                    }
                }
            }
            WindowEvent::Occluded(occluded) => {
                if let Some(state) = &self.state {
                    state.borrow_mut().window_state.visible = !occluded;
                }
                if self.has_game {
                    if let Some(lua) = &self.lua {
                        call_lua_callback_with_timeout(
                            lua,
                            "visible",
                            (!occluded,),
                            self.callback_timeout_ms(),
                        );
                    }
                }
            }
            WindowEvent::CursorEntered { .. } => {
                if let Some(state) = &self.state {
                    state.borrow_mut().window_state.mouse_focused = true;
                }
            }
            WindowEvent::CursorLeft { .. } => {
                if let Some(state) = &self.state {
                    state.borrow_mut().window_state.mouse_focused = false;
                }
            }
            WindowEvent::ModifiersChanged(mods) => {
                let state_mods = mods.state();
                self.ctrl_held = state_mods.control_key();
                if let Some(state) = &self.state {
                    state.borrow_mut().keyboard.set_modifiers(
                        state_mods.shift_key(),
                        state_mods.control_key(),
                        state_mods.alt_key(),
                        state_mods.super_key(),
                    );
                }
            }
            WindowEvent::KeyboardInput { event, .. } => {
                let scancode_str = if let PhysicalKey::Code(code) = event.physical_key {
                    winit_scancode_to_string(code).map(|s| s.to_string())
                } else {
                    None
                };
                if event.repeat {
                    let repeat_enabled = self
                        .state
                        .as_ref()
                        .map(|s| s.borrow().keyboard.has_key_repeat())
                        .unwrap_or(false);
                    if !repeat_enabled {
                        return;
                    }
                }
                if let Some(sc) = &scancode_str {
                    if let Some(state) = &self.state {
                        let mut st = state.borrow_mut();
                        match event.state {
                            ElementState::Pressed => st.keyboard.press_scancode(sc.clone()),
                            ElementState::Released => st.keyboard.release_scancode(sc.clone()),
                        }
                    }
                }
                if let Some(key_str) = winit_key_to_string(&event.logical_key) {
                    if matches!(self.run_state, RunState::Error(_)) {
                        if event.state == ElementState::Pressed {
                            if key_str == "escape" {
                                event_loop.exit();
                                return;
                            }
                            if key_str == "r" {
                                self.run_state = RunState::Restarting;
                                return;
                            }
                            if self.ctrl_held && key_str == "c" {
                                if let RunState::Error(ref screen) = self.run_state {
                                    let text = screen.as_text();
                                    let _ = text;
                                    log_msg!(warn, L021_CLIPBOARD_FAIL, "clipboard unavailable");
                                }
                                return;
                            }
                        }
                        return;
                    }
                    match event.state {
                        ElementState::Pressed => {
                            if !self.has_game
                                && should_open_startup_picker_on_key(&key_str, self.ctrl_held)
                            {
                                self.browse_for_startup_game_dir();
                                return;
                            }
                            if key_str == "f12" {
                                self.debug_overlay.enabled = !self.debug_overlay.enabled;
                                if let Some(state) = &self.state {
                                    state.borrow_mut().debug_overlay_enabled =
                                        self.debug_overlay.enabled;
                                }
                                return;
                            }
                            if let Some(state) = &self.state {
                                let mut st = state.borrow_mut();
                                st.keys_down.insert(key_str.clone());
                                st.keyboard.set_key_down(&key_str);
                                let time_ms = (st.clock.total() * 1000.0).max(0.0) as u64;
                                let frame = st.clock.frame_count();
                                st.input_history.push(crate::input::InputHistoryEvent {
                                    frame,
                                    time_ms,
                                    device: crate::input::InputDevice::Keyboard,
                                    kind: crate::input::InputEventKind::Press,
                                    control: key_str.clone(),
                                    value: None,
                                    position: None,
                                });
                            }
                            let mut dispatch_report = self.begin_input_report("keypressed", None);
                            let mut ui_consumed = false;
                            if shared_flag(&self.state, |st| st.auto_ui_input) && self.lua.is_some()
                            {
                                let ui_result = {
                                    let lua = self.lua.as_ref().expect("lua should exist");
                                    call_lua_ui_bool(
                                        lua,
                                        "keypressed",
                                        key_str.clone(),
                                        self.callback_timeout_ms(),
                                    )
                                };
                                match ui_result {
                                    Ok(consumed) => {
                                        ui_consumed = consumed;
                                        dispatch_report.ui_consumed = consumed;
                                    }
                                    Err(e) => {
                                        let screen = {
                                            let lua = self.lua.as_ref().expect("lua should exist");
                                            try_errorhandler_or_screen(lua, &e)
                                        };
                                        dispatch_report.callback_error = Some(e.to_string());
                                        self.push_input_report(dispatch_report);
                                        self.run_state = RunState::Error(screen);
                                        return;
                                    }
                                }
                            }
                            if key_str == "escape" && !ui_consumed {
                                event_loop.exit();
                                return;
                            }
                            if self.has_game && !ui_consumed {
                                if let Some(lua) = &self.lua {
                                    let sc = scancode_str.clone().unwrap_or_default();
                                    call_lua_callback_with_timeout(
                                        lua,
                                        "keypressed",
                                        (key_str.clone(), sc.clone(), event.repeat),
                                        self.callback_timeout_ms(),
                                    );
                                }
                            }
                            if let Some(state) = &self.state {
                                let sc = scancode_str.clone().unwrap_or_default();
                                state.borrow_mut().event_queue.push_event(
                                    "keypressed",
                                    vec![
                                        EventArg::Str(key_str.clone()),
                                        EventArg::Str(sc),
                                        EventArg::Bool(event.repeat),
                                    ],
                                );
                            }
                            self.push_input_report(dispatch_report);
                        }
                        ElementState::Released => {
                            if let Some(state) = &self.state {
                                let mut st = state.borrow_mut();
                                st.keys_down.remove(&key_str);
                                st.keyboard.set_key_up(&key_str);
                                let time_ms = (st.clock.total() * 1000.0).max(0.0) as u64;
                                let frame = st.clock.frame_count();
                                st.input_history.push(crate::input::InputHistoryEvent {
                                    frame,
                                    time_ms,
                                    device: crate::input::InputDevice::Keyboard,
                                    kind: crate::input::InputEventKind::Release,
                                    control: key_str.clone(),
                                    value: None,
                                    position: None,
                                });
                            }
                            if self.has_game {
                                if let Some(lua) = &self.lua {
                                    let sc = scancode_str.clone().unwrap_or_default();
                                    call_lua_callback_with_timeout(
                                        lua,
                                        "keyreleased",
                                        (key_str.clone(), sc),
                                        self.callback_timeout_ms(),
                                    );
                                }
                            }
                            if let Some(state) = &self.state {
                                let sc = scancode_str.clone().unwrap_or_default();
                                state.borrow_mut().event_queue.push_event(
                                    "keyreleased",
                                    vec![EventArg::Str(key_str.clone()), EventArg::Str(sc)],
                                );
                            }
                            self.push_input_report(InputDispatchReport {
                                event_kind: "keyreleased".to_string(),
                                order: vec![
                                    InputDispatchTarget::Platform,
                                    InputDispatchTarget::Game,
                                ],
                                ui_consumed: false,
                                callback_error: None,
                                coordinates: None,
                            });
                        }
                    }
                }
            }
            WindowEvent::Ime(winit::event::Ime::Commit(text)) => {
                if let Some(state) = &self.state {
                    let mut st = state.borrow_mut();
                    if st.keyboard.has_text_input() {
                        st.keyboard.push_text_input(text.clone());
                        let time_ms = (st.clock.total() * 1000.0).max(0.0) as u64;
                        let frame = st.clock.frame_count();
                        st.input_history.push(crate::input::InputHistoryEvent {
                            frame,
                            time_ms,
                            device: crate::input::InputDevice::Keyboard,
                            kind: crate::input::InputEventKind::Text,
                            control: text.clone(),
                            value: None,
                            position: None,
                        });
                        drop(st);
                        let mut dispatch_report = self.begin_input_report("textinput", None);
                        let mut ui_consumed = false;
                        if shared_flag(&self.state, |st| st.auto_ui_input) && self.lua.is_some() {
                            let ui_result = {
                                let lua = self.lua.as_ref().expect("lua should exist");
                                call_lua_ui_bool(
                                    lua,
                                    "textinput",
                                    text.clone(),
                                    self.callback_timeout_ms(),
                                )
                            };
                            match ui_result {
                                Ok(consumed) => {
                                    ui_consumed = consumed;
                                    dispatch_report.ui_consumed = consumed;
                                }
                                Err(e) => {
                                    let screen = {
                                        let lua = self.lua.as_ref().expect("lua should exist");
                                        try_errorhandler_or_screen(lua, &e)
                                    };
                                    dispatch_report.callback_error = Some(e.to_string());
                                    self.push_input_report(dispatch_report);
                                    self.run_state = RunState::Error(screen);
                                    return;
                                }
                            }
                        }
                        if self.has_game && !ui_consumed {
                            if let Some(lua) = &self.lua {
                                call_lua_callback_with_timeout(
                                    lua,
                                    "textinput",
                                    text,
                                    self.callback_timeout_ms(),
                                );
                            }
                        }
                        self.push_input_report(dispatch_report);
                    }
                }
            }
            WindowEvent::CursorMoved { position, .. } => {
                let (gx, gy) = if let Some(state) = &self.state {
                    let st = state.borrow();
                    let ws = &st.window_state;
                    let gx = if ws.viewport_scale_x > 0.0 {
                        (position.x as f32 - ws.viewport_offset_x) / ws.viewport_scale_x
                    } else {
                        position.x as f32
                    };
                    let gy = if ws.viewport_scale_y > 0.0 {
                        (position.y as f32 - ws.viewport_offset_y) / ws.viewport_scale_y
                    } else {
                        position.y as f32
                    };
                    (gx, gy)
                } else {
                    (position.x as f32, position.y as f32)
                };
                let dx = gx - self.mouse_x;
                let dy = gy - self.mouse_y;
                self.mouse_x = gx;
                self.mouse_y = gy;
                let mut dispatch_report = self.begin_input_report("mousemoved", Some((gx, gy)));
                if let Some(state) = &self.state {
                    let mut st = state.borrow_mut();
                    st.mouse.x = gx;
                    st.mouse.y = gy;
                    st.mouse.accumulate_delta(dx, dy);
                    let time_ms = (st.clock.total() * 1000.0).max(0.0) as u64;
                    let frame = st.clock.frame_count();
                    st.input_history.push(crate::input::InputHistoryEvent {
                        frame,
                        time_ms,
                        device: crate::input::InputDevice::Mouse,
                        kind: crate::input::InputEventKind::Motion,
                        control: "motion".to_string(),
                        value: None,
                        position: Some((dx, dy)),
                    });
                }
                let mut ui_consumed = false;
                if shared_flag(&self.state, |st| st.auto_ui_input) && self.lua.is_some() {
                    let ui_result = {
                        let lua = self.lua.as_ref().expect("lua should exist");
                        call_lua_ui_bool(lua, "mousemoved", (gx, gy), self.callback_timeout_ms())
                    };
                    match ui_result {
                        Ok(consumed) => {
                            ui_consumed = consumed;
                            dispatch_report.ui_consumed = consumed;
                        }
                        Err(e) => {
                            let screen = {
                                let lua = self.lua.as_ref().expect("lua should exist");
                                try_errorhandler_or_screen(lua, &e)
                            };
                            dispatch_report.callback_error = Some(e.to_string());
                            self.push_input_report(dispatch_report);
                            self.run_state = RunState::Error(screen);
                            return;
                        }
                    }
                }
                if self.has_game && !ui_consumed {
                    if let Some(lua) = &self.lua {
                        call_lua_callback_with_timeout(
                            lua,
                            "mousemoved",
                            (gx, gy, dx, dy),
                            self.callback_timeout_ms(),
                        );
                    }
                }
            }
            WindowEvent::MouseWheel { delta, .. } => {
                let (dx, dy) = match delta {
                    winit::event::MouseScrollDelta::LineDelta(x, y) => (x as f64, y as f64),
                    winit::event::MouseScrollDelta::PixelDelta(pos) => (pos.x, pos.y),
                };
                let mut dispatch_report = self.begin_input_report("wheelmoved", None);
                if let Some(state) = &self.state {
                    let mut st = state.borrow_mut();
                    st.mouse.accumulate_scroll(dx, dy);
                    let time_ms = (st.clock.total() * 1000.0).max(0.0) as u64;
                    let frame = st.clock.frame_count();
                    st.input_history.push(crate::input::InputHistoryEvent {
                        frame,
                        time_ms,
                        device: crate::input::InputDevice::Mouse,
                        kind: crate::input::InputEventKind::Wheel,
                        control: "wheel".to_string(),
                        value: None,
                        position: Some((dx as f32, dy as f32)),
                    });
                }
                let mut ui_consumed = false;
                if shared_flag(&self.state, |st| st.auto_ui_input) && self.lua.is_some() {
                    let ui_result = {
                        let lua = self.lua.as_ref().expect("lua should exist");
                        call_lua_ui_bool(lua, "wheelmoved", (dx, dy), self.callback_timeout_ms())
                    };
                    match ui_result {
                        Ok(consumed) => {
                            ui_consumed = consumed;
                            dispatch_report.ui_consumed = consumed;
                        }
                        Err(e) => {
                            let screen = {
                                let lua = self.lua.as_ref().expect("lua should exist");
                                try_errorhandler_or_screen(lua, &e)
                            };
                            dispatch_report.callback_error = Some(e.to_string());
                            self.push_input_report(dispatch_report);
                            self.run_state = RunState::Error(screen);
                            return;
                        }
                    }
                }
                if self.has_game && !ui_consumed {
                    if let Some(lua) = &self.lua {
                        call_lua_callback_with_timeout(
                            lua,
                            "wheelmoved",
                            (dx, dy),
                            self.callback_timeout_ms(),
                        );
                    }
                }
            }
            WindowEvent::MouseInput {
                state: btn_state,
                button,
                ..
            } => {
                let idx = match button {
                    MouseButton::Left => Some(0),
                    MouseButton::Right => Some(1),
                    MouseButton::Middle => Some(2),
                    MouseButton::Back => Some(3),
                    MouseButton::Forward => Some(4),
                    MouseButton::Other(index) => Some(index as usize + 5),
                };
                if let Some(i) = idx {
                    let pressed = btn_state == ElementState::Pressed;
                    if !self.has_game && i == 0 && pressed {
                        self.browse_for_startup_game_dir();
                        return;
                    }
                    let was_pressed = self
                        .state
                        .as_ref()
                        .is_some_and(|state| state.borrow().mouse.is_down(i));
                    let click_count = if let Some(state) = &self.state {
                        let mut st = state.borrow_mut();
                        st.mouse.set_button(i, pressed);
                        let time_ms = (st.clock.total() * 1000.0).max(0.0) as u64;
                        let click_count = if pressed { st.mouse.register_click(i, time_ms) } else { st.mouse.click_count(i) };
                        let frame = st.clock.frame_count();
                        st.input_history.push(crate::input::InputHistoryEvent {
                            frame,
                            time_ms,
                            device: crate::input::InputDevice::Mouse,
                            kind: if pressed {
                                crate::input::InputEventKind::Press
                            } else {
                                crate::input::InputEventKind::Release
                            },
                            control: format!("mouse{}", i + 1),
                            value: None,
                            position: Some((self.mouse_x, self.mouse_y)),
                        });
                        click_count
                    } else { 0 };
                    let mx = self.mouse_x;
                    let my = self.mouse_y;
                    let button_index = (i + 1) as u32;
                    let mut dispatch_report = self.begin_input_report(
                        if pressed {
                            "mousepressed"
                        } else {
                            "mousereleased"
                        },
                        Some((mx, my)),
                    );
                    let mut ui_consumed = false;
                    if shared_flag(&self.state, |st| st.auto_ui_input) && self.lua.is_some() {
                        if pressed && !was_pressed {
                            let ui_result = {
                                let lua = self.lua.as_ref().expect("lua should exist");
                                call_lua_ui_bool(
                                    lua,
                                    "mousepressed",
                                    (mx, my, button_index, click_count),
                                    self.callback_timeout_ms(),
                                )
                            };
                            match ui_result {
                                Ok(consumed) => {
                                    ui_consumed = consumed;
                                    dispatch_report.ui_consumed = consumed;
                                }
                                Err(e) => {
                                    let screen = {
                                        let lua = self.lua.as_ref().expect("lua should exist");
                                        try_errorhandler_or_screen(lua, &e)
                                    };
                                    dispatch_report.callback_error = Some(e.to_string());
                                    self.push_input_report(dispatch_report);
                                    self.run_state = RunState::Error(screen);
                                    return;
                                }
                            }
                        } else if !pressed && was_pressed {
                            let ui_result = {
                                let lua = self.lua.as_ref().expect("lua should exist");
                                call_lua_ui_bool(
                                    lua,
                                    "mousereleased",
                                    (mx, my, button_index, click_count),
                                    self.callback_timeout_ms(),
                                )
                            };
                            match ui_result {
                                Ok(consumed) => {
                                    ui_consumed = consumed;
                                    dispatch_report.ui_consumed = consumed;
                                }
                                Err(e) => {
                                    let screen = {
                                        let lua = self.lua.as_ref().expect("lua should exist");
                                        try_errorhandler_or_screen(lua, &e)
                                    };
                                    dispatch_report.callback_error = Some(e.to_string());
                                    self.push_input_report(dispatch_report);
                                    self.run_state = RunState::Error(screen);
                                    return;
                                }
                            }
                        }
                    }
                    if self.has_game && !ui_consumed {
                        if let Some(lua) = &self.lua {
                            if pressed && !was_pressed {
                                call_lua_callback_with_timeout(
                                    lua,
                                    "mousepressed",
                                    (mx, my, button_index, click_count),
                                    self.callback_timeout_ms(),
                                );
                            } else if !pressed && was_pressed {
                                call_lua_callback_with_timeout(
                                    lua,
                                    "mousereleased",
                                    (mx, my, button_index, click_count),
                                    self.callback_timeout_ms(),
                                );
                            }
                        }
                    }
                    if let Some(state) = &self.state {
                        let mx = self.mouse_x;
                        let my = self.mouse_y;
                        if pressed && !was_pressed {
                            state.borrow_mut().event_queue.push_event(
                                "mousepressed",
                                vec![
                                    EventArg::Num(mx as f64),
                                    EventArg::Num(my as f64),
                                    EventArg::Num((i + 1) as f64),
                                    EventArg::Num(click_count as f64),
                                ],
                            );
                        } else if !pressed && was_pressed {
                            state.borrow_mut().event_queue.push_event(
                                "mousereleased",
                                vec![
                                    EventArg::Num(mx as f64),
                                    EventArg::Num(my as f64),
                                    EventArg::Num((i + 1) as f64),
                                    EventArg::Num(click_count as f64),
                                ],
                            );
                        }
                    }
                    if i < self.prev_mouse.len() {
                        self.prev_mouse[i] = pressed;
                    }
                }
            }
            WindowEvent::RedrawRequested => {
                if !self.lua_initialized {
                    if let Some(win) = &self.window {
                        if !self.hidden_window {
                            win.set_visible(true);
                        }
                    }
                    self.init_lua();
                    self.lua_initialized = true;
                    if self.auto_screenshot_path.is_some() {
                        self.auto_screenshot_start = Some(Instant::now());
                    }
                    if self.auto_quit_frames.is_some() || self.auto_quit_time.is_some() {
                        self.auto_quit_start = Some(Instant::now());
                    }
                    if let (Some(window), Some(state)) = (&self.window, &self.state) {
                        let mut st = state.borrow_mut();
                        st.window_state.fullscreen = window.fullscreen().is_some();
                        if let Ok(position) = window.outer_position() {
                            st.window_state.position_x = position.x;
                            st.window_state.position_y = position.y;
                        }
                    }
                    if let Some(win) = &self.window {
                        win.request_redraw();
                    }
                    return;
                }
                if matches!(self.run_state, RunState::Restarting) {
                    self.restart_game();
                    return;
                }
                let mut restart_requested = false;
                let mut quit_requested = false;
                if let Some(state) = &self.state {
                    let mut st = state.borrow_mut();
                    if st.restart_requested {
                        st.restart_requested = false;
                        restart_requested = true;
                    }
                    quit_requested = st.quit_requested;
                }
                if restart_requested {
                    self.run_state = RunState::Restarting;
                    self.restart_game();
                    return;
                }
                if quit_requested {
                    event_loop.exit();
                    return;
                }
                let tick_start = Instant::now();
                self.poll_gamepads();
                self.tick_frame();
                let tick_ms = tick_start.elapsed().as_secs_f64() * 1000.0;
                let mut update_ms = 0.0;
                let mut render_ms = 0.0;
                let run_state = std::mem::replace(&mut self.run_state, RunState::Running);
                match run_state {
                    RunState::Error(ref screen) => {
                        let render_start = Instant::now();
                        self.render_error(screen);
                        render_ms = render_start.elapsed().as_secs_f64() * 1000.0;
                        self.run_state = run_state;
                        if self.auto_screenshot_path.is_some() {
                            if let Some(state) = &self.state {
                                state.borrow_mut().quit_requested = true;
                            } else {
                                event_loop.exit();
                            }
                        }
                    }
                    RunState::Running => {
                        if self.has_game {
                            let update_start = Instant::now();
                            self.game_update();
                            update_ms = update_start.elapsed().as_secs_f64() * 1000.0;
                            self.apply_pending_window_actions();
                            let render_start = Instant::now();
                            self.render();
                            render_ms = render_start.elapsed().as_secs_f64() * 1000.0;
                        } else {
                            let render_start = Instant::now();
                            self.render_splash();
                            render_ms = render_start.elapsed().as_secs_f64() * 1000.0;
                        }
                    }
                    RunState::Restarting => {}
                }
                if let Some(state) = &self.state {
                    let mut st = state.borrow_mut();
                    st.frame_profile.app_tick_ms = tick_ms as f32;
                    st.frame_profile.app_update_ms = update_ms as f32;
                    st.frame_profile.app_render_ms = render_ms as f32;
                    st.frame_profile.app_frame_total_ms = (tick_ms + update_ms + render_ms) as f32;
                    st.mouse.begin_frame();
                }
                self.perf_record_frame(tick_ms, update_ms, render_ms);
            }
            WindowEvent::Touch(touch) => {
                let id = touch.id;
                let x = touch.location.x;
                let y = touch.location.y;
                let event_kind = match touch.phase {
                    winit::event::TouchPhase::Started => "touchpressed",
                    winit::event::TouchPhase::Moved => "touchmoved",
                    winit::event::TouchPhase::Ended | winit::event::TouchPhase::Cancelled => {
                        "touchreleased"
                    }
                };
                let dispatch_report =
                    self.begin_input_report(event_kind, Some((x as f32, y as f32)));
                let pressure = touch.force.map_or(1.0, |f| match f {
                    winit::event::Force::Normalized(n) => n,
                    winit::event::Force::Calibrated {
                        force,
                        max_possible_force,
                        ..
                    } => {
                        if max_possible_force > 0.0 {
                            force / max_possible_force
                        } else {
                            1.0
                        }
                    }
                });
                match touch.phase {
                    winit::event::TouchPhase::Started => {
                        let dx = 0.0;
                        let dy = 0.0;
                        if let Some(state) = &self.state {
                            state.borrow_mut().touch.touch_start(id, x, y, pressure);
                        }
                        if let Some(lua) = self.lua.as_ref().filter(|_| self.has_game) {
                            call_lua_callback_with_timeout(
                                lua,
                                "touchpressed",
                                (id, x, y, dx, dy, pressure),
                                self.callback_timeout_ms(),
                            );
                        }
                    }
                    winit::event::TouchPhase::Moved => {
                        let (dx, dy) = if let Some(state) = &self.state {
                            let mut st = state.borrow_mut();
                            let delta = st
                                .touch
                                .get_touch(id)
                                .map(|touch_point| (x - touch_point.x, y - touch_point.y))
                                .unwrap_or((0.0, 0.0));
                            st.touch.touch_move(id, x, y, pressure);
                            delta
                        } else {
                            (0.0, 0.0)
                        };
                        if let Some(lua) = self.lua.as_ref().filter(|_| self.has_game) {
                            call_lua_callback_with_timeout(
                                lua,
                                "touchmoved",
                                (id, x, y, dx, dy, pressure),
                                self.callback_timeout_ms(),
                            );
                        }
                    }
                    winit::event::TouchPhase::Ended | winit::event::TouchPhase::Cancelled => {
                        let (dx, dy) = if let Some(state) = &self.state {
                            let mut st = state.borrow_mut();
                            let delta = st
                                .touch
                                .get_touch(id)
                                .map(|touch_point| (x - touch_point.x, y - touch_point.y))
                                .unwrap_or((0.0, 0.0));
                            st.touch.touch_end(id);
                            delta
                        } else {
                            (0.0, 0.0)
                        };
                        if let Some(lua) = self.lua.as_ref().filter(|_| self.has_game) {
                            call_lua_callback_with_timeout(
                                lua,
                                "touchreleased",
                                (id, x, y, dx, dy, pressure),
                                self.callback_timeout_ms(),
                            );
                        }
                    }
                }
                self.push_input_report(dispatch_report);
            }
            WindowEvent::HoveredFile(path) => {
                log_msg!(debug, L077_DRAG_HOVER, "{}", path.display());
                if !self.has_game {
                    self.drag_hover = true;
                    if let Some(win) = &self.window {
                        win.request_redraw();
                    }
                }
            }
            WindowEvent::HoveredFileCancelled => {
                log_msg!(debug, L078_DRAG_HOVER_CANCEL);
                if self.drag_hover {
                    self.drag_hover = false;
                    if let Some(win) = &self.window {
                        win.request_redraw();
                    }
                }
            }
            WindowEvent::DroppedFile(path) => {
                log::debug!("[lurek drag-drop] DroppedFile: {}", path.display());
                log_msg!(info, L043_DROP_FILE, "{}", path.display());
                if self.drag_hover {
                    self.drag_hover = false;
                    if let Some(win) = &self.window {
                        win.request_redraw();
                    }
                }
                if !self.has_game {
                    self.load_startup_target_path(&path);
                } else {
                    log_msg!(debug, L079_DRAG_DROP_IGNORED);
                }
            }
            _ => {}
        }
    }
    /// Collect raw mouse motion so relative input remains available while the cursor is locked.
    fn device_event(
        &mut self,
        _event_loop: &ActiveEventLoop,
        _device_id: winit::event::DeviceId,
        event: DeviceEvent,
    ) {
        let DeviceEvent::MouseMotion { delta: (dx, dy) } = event else {
            return;
        };
        let Some(state) = &self.state else {
            return;
        };
        let mut st = state.borrow_mut();
        st.mouse.accumulate_delta(dx as f32, dy as f32);
        let time_ms = (st.clock.total() * 1000.0).max(0.0) as u64;
        let frame = st.clock.frame_count();
        st.input_history.push(crate::input::InputHistoryEvent {
            frame,
            time_ms,
            device: crate::input::InputDevice::Mouse,
            kind: crate::input::InputEventKind::Motion,
            control: "raw_motion".to_string(),
            value: None,
            position: Some((dx as f32, dy as f32)),
        });
    }
    /// Run per-frame housekeeping: hot-reload polling, auto-screenshot timeout, and frame pacing.
    fn about_to_wait(&mut self, event_loop: &ActiveEventLoop) {
        use std::time::Duration;
        if let Some(state) = &self.state {
            let requested = state.borrow().pending_config_reload;
            if requested {
                state.borrow_mut().pending_config_reload = false;
                self.conf_watcher.force_changed();
            }
        }
        self.poll_config_hot_reload();
        self.poll_content_hot_reload();
        if !self.auto_screenshot_done {
            if let Some(start) = self.auto_screenshot_start {
                let expected_capture_secs = match self.auto_screenshot_time {
                    Some(secs) => secs.max(0.0),
                    None => {
                        let fps = self.config.performance.target_fps.max(1) as f32;
                        self.auto_screenshot_frames as f32 / fps
                    }
                };
                let deadline_secs = (expected_capture_secs + 2.0).max(3.0);
                if start.elapsed() > Duration::from_secs_f32(deadline_secs) {
                    if let Some(state) = &self.state {
                        state.borrow_mut().quit_requested = true;
                    } else {
                        event_loop.exit();
                    }
                }
            }
        }
        if !self.auto_quit_done {
            let auto_quit_ready = match self.auto_quit_time {
                Some(secs) => self
                    .auto_quit_start
                    .map(|start| start.elapsed() >= Duration::from_secs_f32(secs.max(0.0)))
                    .unwrap_or(false),
                None => self
                    .auto_quit_frames
                    .map(|frames| self.auto_quit_frame_count >= frames)
                    .unwrap_or(false),
            };
            if auto_quit_ready {
                self.auto_quit_done = true;
                if let Some(state) = &self.state {
                    state.borrow_mut().quit_requested = true;
                } else {
                    event_loop.exit();
                }
            }
        }
        let target = Duration::from_secs_f64(1.0 / self.config.performance.target_fps as f64);
        let elapsed = self.last_frame.elapsed();
        if elapsed >= target {
            self.last_frame = Instant::now();
            if let Some(win) = &self.window {
                win.request_redraw();
            }
            event_loop.set_control_flow(ControlFlow::Poll);
        } else {
            let remaining = target - elapsed;
            #[cfg(target_os = "windows")]
            {
                if remaining > Duration::from_micros(1500) {
                    std::thread::sleep(remaining - Duration::from_micros(1000));
                }
                event_loop.set_control_flow(ControlFlow::Poll);
            }
            #[cfg(not(target_os = "windows"))]
            {
                let next = Instant::now() + remaining;
                event_loop.set_control_flow(ControlFlow::WaitUntil(next));
            }
        }
    }
}
