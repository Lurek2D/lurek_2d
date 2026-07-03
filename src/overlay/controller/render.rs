//! Owns the overlay controller render implementation for the overlay subsystem and keeps related runtime rules local here.
//! Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
//! Defines how overlay controller render data is validated, transformed, or stored before neighboring systems consume it.
//! Separates overlay controller render behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing overlay controller render defaults, lifecycle handling, validation, or data ownership rules.
//! Open this owner when overlay layer ordering or draw responsibility shifts even if effect state stays valid.

use super::*;

impl Overlay {
    /// Returns the current layer-rendering responsibility plan.
    pub fn render_plan(&self) -> OverlayRenderPlan {
        self.sanitized_clone().render_plan_inner()
    }

    fn render_plan_inner(&self) -> OverlayRenderPlan {
        let mut plan = OverlayRenderPlan::default();
        if self.get_flash_alpha() > 0.0 {
            plan.rendered.push(OverlayRenderLayer::Flash);
        }
        if self.fade.active && self.fade.color[3] > 0.0 {
            plan.rendered.push(OverlayRenderLayer::Fade);
        }
        if self.get_lightning_alpha() > 0.0 {
            plan.rendered.push(OverlayRenderLayer::Lightning);
        }
        if self.vignette.enabled && self.vignette.strength > 0.0 {
            plan.rendered.push(OverlayRenderLayer::Vignette);
        }

        if self.ambient.enabled {
            plan.externally_handled.push(OverlayRenderLayer::Ambient);
        }
        if self.weather.enabled
            && self.weather.weather_type != WeatherType::None
            && self.weather_intensity() > 0.0
        {
            plan.externally_handled.push(OverlayRenderLayer::Weather);
        }
        if self.clouds.enabled {
            plan.externally_handled.push(OverlayRenderLayer::Clouds);
        }
        if self.fog.enabled && self.fog.density > 0.0 {
            plan.externally_handled.push(OverlayRenderLayer::Fog);
        }
        if self.heat_haze.enabled && self.heat_haze.intensity > 0.0 {
            plan.externally_handled.push(OverlayRenderLayer::HeatHaze);
        }
        if self.film_grain.enabled && self.film_grain.intensity > 0.0 {
            plan.externally_handled.push(OverlayRenderLayer::FilmGrain);
        }
        if self.water.enabled {
            plan.externally_handled.push(OverlayRenderLayer::Water);
        }
        if self.custom_shader.is_some() {
            plan.externally_handled
                .push(OverlayRenderLayer::CustomShader);
        }
        let mut has_status_color = false;
        let mut has_status_texture = false;
        let mut has_status_postfx = false;
        for layer in self.status_stack.active_layers_sorted() {
            if layer.color_alpha() > 0.0 {
                has_status_color = true;
            }
            if layer.texture_alpha() > 0.0 {
                has_status_texture = true;
            }
            if layer.shader_amount() > 0.0 {
                has_status_postfx = true;
            }
        }
        if has_status_color {
            plan.rendered.push(OverlayRenderLayer::StatusColorWash);
        }
        if has_status_texture {
            plan.rendered.push(OverlayRenderLayer::StatusTexture);
        }
        if has_status_postfx {
            plan.externally_handled
                .push(OverlayRenderLayer::StatusPostFx);
        }
        plan
    }

    fn active_status_layers_for_target(
        &self,
        target: Option<StatusLayerTarget>,
    ) -> Vec<&StatusOverlayLayer> {
        self.status_stack
            .active_layers_sorted()
            .into_iter()
            .filter(|layer| target.map(|wanted| layer.target == wanted).unwrap_or(true))
            .collect()
    }

    /// Returns a compact telemetry snapshot of the current overlay runtime state.
    pub fn stats(&self) -> OverlayStats {
        let sanitized = self.sanitized_clone();
        let plan = sanitized.render_plan_inner();
        let active_status_layers = sanitized
            .status_stack
            .layers
            .iter()
            .filter(|layer| layer.is_active())
            .count();
        let mut active_effects = 0_u32;
        for enabled in [
            sanitized.weather.enabled,
            sanitized.ambient.enabled,
            sanitized.flash.active,
            sanitized.shake.active,
            sanitized.fade.active,
            sanitized.clouds.enabled,
            sanitized.fog.enabled,
            sanitized.heat_haze.enabled,
            sanitized.vignette.enabled,
            sanitized.film_grain.enabled,
            sanitized.lightning.active,
            sanitized.water.enabled,
            active_status_layers > 0,
            sanitized.custom_shader.is_some(),
        ] {
            if enabled {
                active_effects += 1;
            }
        }
        OverlayStats {
            width: sanitized.width,
            height: sanitized.height,
            weather_particle_count: sanitized.weather.particles.len(),
            weather_particle_limit: sanitized.weather_particle_limit(),
            weather_intensity: sanitized.weather_intensity(),
            flash_alpha: sanitized.get_flash_alpha(),
            lightning_alpha: sanitized.get_lightning_alpha(),
            active_effects,
            weather_enabled: sanitized.weather.enabled,
            ambient_enabled: sanitized.ambient.enabled,
            fog_enabled: sanitized.fog.enabled,
            vignette_enabled: sanitized.vignette.enabled,
            weather_spawns_this_frame: self.diagnostics.weather_spawns_this_frame,
            weather_dropped_spawns: self.diagnostics.weather_dropped_spawns,
            weather_culled_particles: self.diagnostics.weather_culled_particles,
            weather_dt_spike_clamps: self.diagnostics.weather_dt_spike_clamps,
            reduced_motion: sanitized.accessibility_policy.reduced_motion,
            accessibility_adjustments: self.diagnostics.accessibility_adjustments,
            sanitized_fields: self.diagnostics.sanitized_fields,
            invalid_shader_rejections: self.diagnostics.invalid_shader_rejections,
            debug_image_rejections: self.diagnostics.debug_image_rejections,
            external_render_layers: plan.externally_handled.len(),
            status_layers: sanitized.status_stack.layers.len(),
            active_status_layers,
        }
    }

    /// Builds render commands for currently active full-screen overlay layers.
    pub fn build_render_commands(&self) -> Vec<RenderCommand> {
        self.build_render_commands_for_target(None, true)
    }

    /// Builds render commands, optionally filtering status layers to a conceptual frame target.
    pub fn build_render_commands_for_target(
        &self,
        target: Option<StatusLayerTarget>,
        include_global_layers: bool,
    ) -> Vec<RenderCommand> {
        let sanitized = self.sanitized_clone();
        let mut cmds = Vec::with_capacity(8);
        let width = sanitized.width as f32;
        let height = sanitized.height as f32;
        if include_global_layers {
            let flash_alpha = sanitized.get_flash_alpha();
            if flash_alpha > 0.0 {
                let [r, g, b, _] = sanitized.flash.color;
                cmds.push(RenderCommand::SetColor(r, g, b, flash_alpha));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: 0.0,
                    y: 0.0,
                    w: width,
                    h: height,
                });
            }
            if sanitized.fade.active && sanitized.fade.color[3] > 0.0 {
                let [r, g, b, a] = sanitized.fade.color;
                cmds.push(RenderCommand::SetColor(r, g, b, a));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: 0.0,
                    y: 0.0,
                    w: width,
                    h: height,
                });
            }
            let lightning_alpha = sanitized.get_lightning_alpha();
            if lightning_alpha > 0.0 {
                let [r, g, b, _] = sanitized.lightning.color;
                cmds.push(RenderCommand::SetColor(r, g, b, lightning_alpha));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: 0.0,
                    y: 0.0,
                    w: width,
                    h: height,
                });
            }
            if sanitized.vignette.enabled && sanitized.vignette.strength > 0.0 {
                let alpha = (sanitized.vignette.strength * 0.5).clamp(0.0, 1.0);
                cmds.push(RenderCommand::SetColor(0.0, 0.0, 0.0, alpha));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: 0.0,
                    y: 0.0,
                    w: width,
                    h: height,
                });
            }
        }
        for layer in sanitized.active_status_layers_for_target(target) {
            if let Some(color) = layer.visual.color {
                let alpha = layer.color_alpha();
                if alpha > 0.0 {
                    cmds.push(RenderCommand::SetColor(color[0], color[1], color[2], alpha));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: 0.0,
                        y: 0.0,
                        w: width,
                        h: height,
                    });
                }
            }
            if let Some(texture_key) = layer.visual.texture_key {
                let alpha = layer.texture_alpha();
                if alpha > 0.0 {
                    if let Some((tex_w, tex_h)) = layer.visual.texture_size {
                        let scale_x = width / tex_w.max(1) as f32;
                        let scale_y = height / tex_h.max(1) as f32;
                        cmds.push(RenderCommand::SetColor(1.0, 1.0, 1.0, alpha));
                        cmds.push(RenderCommand::DrawImageEx {
                            texture_key,
                            x: 0.0,
                            y: 0.0,
                            rotation: 0.0,
                            sx: scale_x,
                            sy: scale_y,
                            ox: 0.0,
                            oy: 0.0,
                            effect: None,
                        });
                    }
                }
            }
        }
        cmds
    }

    /// Builds built-in post-fx passes requested by active status layers.
    pub fn build_postfx_passes(&self) -> Vec<PostFxPass> {
        self.build_postfx_passes_for_target(None)
    }

    /// Builds built-in post-fx passes, optionally filtering status layers to one frame target.
    pub fn build_postfx_passes_for_target(
        &self,
        target: Option<StatusLayerTarget>,
    ) -> Vec<PostFxPass> {
        let sanitized = self.sanitized_clone();
        let mut passes = Vec::new();
        for layer in sanitized.active_status_layers_for_target(target) {
            let Some(effect_name) = layer.visual.shader_effect.as_deref() else {
                continue;
            };
            let amount = layer.shader_amount();
            if amount <= 0.0 {
                continue;
            }
            let mut params = HashMap::new();
            match effect_name {
                "chromatic" => {
                    params.insert("offset".to_string(), amount.clamp(0.0, 32.0));
                }
                "blur_h" | "blur_v" => {
                    params.insert("radius".to_string(), amount.clamp(0.0, 64.0));
                    params.insert("strength".to_string(), amount.clamp(0.0, 8.0));
                }
                "waterdistort" => {
                    params.insert("amplitude".to_string(), (amount * 0.01).clamp(0.0, 1.0));
                    params.insert("frequency".to_string(), 10.0 + amount * 10.0);
                    params.insert("speed".to_string(), 1.0 + amount);
                }
                _ => {
                    params.insert("strength".to_string(), amount.clamp(0.0, 8.0));
                }
            }
            passes.push(PostFxPass {
                effect_name: effect_name.to_string(),
                params,
                shader_id: None,
                auto_uniforms: true,
            });
        }
        passes
    }
}
