//! Owns the render diagnostics owner for the render subsystem and keeps its rules local to this file.
//! Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how render diagnostics data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on render diagnostics behavior while Lua registration stays elsewhere.

/// Per-frame counters for non-fatal render issues observed while preparing or encoding a frame.
#[derive(Debug, Default, Clone, Copy, PartialEq, Eq)]
pub struct RenderDiagnostics {
    /// Number of draw commands that were skipped after renderer validation or resource lookup failed.
    pub dropped_commands: u32,
    /// Number of skipped draws caused by a missing uploaded texture bind group.
    pub missing_textures: u32,
    /// Number of skipped draws or passes caused by a missing canvas backing texture.
    pub missing_canvases: u32,
    /// Number of skipped mesh draws caused by missing cached mesh geometry.
    pub missing_meshes: u32,
    /// Number of skipped compound-shape draws caused by missing shape registry entries.
    pub missing_shapes: u32,
    /// Number of skipped draws caused by missing static geometry cache entries.
    pub missing_static_geometry: u32,
    /// Number of skipped instanced draws caused by missing instance-buffer entries.
    pub missing_instance_buffers: u32,
    /// Number of skipped instanced draws for drawable kinds the GPU path does not support yet.
    pub unsupported_instanced_sprite_batches: u32,
    /// Number of rejected texture uploads caused by invalid dimensions, limits, or pixel data.
    pub invalid_texture_uploads: u32,
    /// Number of rejected canvas allocations caused by invalid dimensions or device limits.
    pub invalid_canvas_allocations: u32,
    /// Number of rejected mesh uploads caused by invalid mesh topology or vertex data.
    pub invalid_meshes: u32,
    /// Number of render commands rejected by central input validation before backend work.
    pub invalid_render_inputs: u32,
    /// Number of shader or pipeline cache invariant failures that used a fallback or skipped a draw.
    pub shader_pipeline_failures: u32,
    /// Number of GPU buffer reallocations caused by frame data exceeding current capacity.
    pub buffer_growth_events: u32,
    /// Number of shadow-casting light rows dispatched into the shadow atlas.
    pub shadow_lights_rendered: u32,
    /// Number of shadow caster edges uploaded after filtering.
    pub shadow_edges_collected: u32,
    /// Number of shadow caster edges skipped by light-radius culling.
    pub shadow_edges_culled: u32,
}

impl RenderDiagnostics {
    /// Add another frame snapshot into this saturating cumulative snapshot.
    pub fn accumulate(&mut self, frame: &Self) {
        self.dropped_commands = self.dropped_commands.saturating_add(frame.dropped_commands);
        self.missing_textures = self.missing_textures.saturating_add(frame.missing_textures);
        self.missing_canvases = self.missing_canvases.saturating_add(frame.missing_canvases);
        self.missing_meshes = self.missing_meshes.saturating_add(frame.missing_meshes);
        self.missing_shapes = self.missing_shapes.saturating_add(frame.missing_shapes);
        self.missing_static_geometry = self
            .missing_static_geometry
            .saturating_add(frame.missing_static_geometry);
        self.missing_instance_buffers = self
            .missing_instance_buffers
            .saturating_add(frame.missing_instance_buffers);
        self.unsupported_instanced_sprite_batches = self
            .unsupported_instanced_sprite_batches
            .saturating_add(frame.unsupported_instanced_sprite_batches);
        self.invalid_texture_uploads = self
            .invalid_texture_uploads
            .saturating_add(frame.invalid_texture_uploads);
        self.invalid_canvas_allocations = self
            .invalid_canvas_allocations
            .saturating_add(frame.invalid_canvas_allocations);
        self.invalid_meshes = self.invalid_meshes.saturating_add(frame.invalid_meshes);
        self.invalid_render_inputs = self
            .invalid_render_inputs
            .saturating_add(frame.invalid_render_inputs);
        self.shader_pipeline_failures = self
            .shader_pipeline_failures
            .saturating_add(frame.shader_pipeline_failures);
        self.buffer_growth_events = self
            .buffer_growth_events
            .saturating_add(frame.buffer_growth_events);
        self.shadow_lights_rendered = self
            .shadow_lights_rendered
            .saturating_add(frame.shadow_lights_rendered);
        self.shadow_edges_collected = self
            .shadow_edges_collected
            .saturating_add(frame.shadow_edges_collected);
        self.shadow_edges_culled = self
            .shadow_edges_culled
            .saturating_add(frame.shadow_edges_culled);
    }

    /// Reset all counters before starting a new frame.
    pub fn reset(&mut self) {
        *self = Self::default();
    }

    /// Record one skipped command and saturate if a long-running frame hits the counter ceiling.
    pub fn record_dropped_command(&mut self) {
        self.dropped_commands = self.dropped_commands.saturating_add(1);
    }

    /// Record one skipped draw caused by a missing uploaded texture bind group.
    pub fn record_missing_texture(&mut self) {
        self.missing_textures = self.missing_textures.saturating_add(1);
        self.record_dropped_command();
    }

    /// Record one skipped draw or pass caused by missing canvas GPU state.
    pub fn record_missing_canvas(&mut self) {
        self.missing_canvases = self.missing_canvases.saturating_add(1);
        self.record_dropped_command();
    }

    /// Record one skipped mesh draw caused by missing cached mesh geometry.
    pub fn record_missing_mesh(&mut self) {
        self.missing_meshes = self.missing_meshes.saturating_add(1);
        self.record_dropped_command();
    }

    /// Record one skipped compound-shape draw caused by a missing shape registry entry.
    pub fn record_missing_shape(&mut self) {
        self.missing_shapes = self.missing_shapes.saturating_add(1);
        self.record_dropped_command();
    }

    /// Record one skipped draw caused by missing static geometry cache state.
    pub fn record_missing_static_geometry(&mut self) {
        self.missing_static_geometry = self.missing_static_geometry.saturating_add(1);
        self.record_dropped_command();
    }

    /// Record one skipped instanced draw caused by missing instance-buffer state.
    pub fn record_missing_instance_buffer(&mut self) {
        self.missing_instance_buffers = self.missing_instance_buffers.saturating_add(1);
        self.record_dropped_command();
    }

    /// Record one skipped instanced sprite batch, which is not supported by the GPU path yet.
    pub fn record_unsupported_instanced_sprite_batch(&mut self) {
        self.unsupported_instanced_sprite_batches =
            self.unsupported_instanced_sprite_batches.saturating_add(1);
        self.record_dropped_command();
    }

    /// Record one rejected texture upload caused by invalid source data.
    pub fn record_invalid_texture_upload(&mut self) {
        self.invalid_texture_uploads = self.invalid_texture_uploads.saturating_add(1);
    }

    /// Record one rejected canvas allocation caused by invalid dimensions or limits.
    pub fn record_invalid_canvas_allocation(&mut self) {
        self.invalid_canvas_allocations = self.invalid_canvas_allocations.saturating_add(1);
    }

    /// Record one rejected mesh upload caused by invalid mesh data.
    pub fn record_invalid_mesh(&mut self) {
        self.invalid_meshes = self.invalid_meshes.saturating_add(1);
    }

    /// Record one render command rejected by central input validation before backend work.
    pub fn record_invalid_render_input(&mut self) {
        self.invalid_render_inputs = self.invalid_render_inputs.saturating_add(1);
        self.record_dropped_command();
    }

    /// Record one shader or render-pipeline cache invariant failure.
    pub fn record_shader_pipeline_failure(&mut self) {
        self.shader_pipeline_failures = self.shader_pipeline_failures.saturating_add(1);
    }

    /// Record one GPU buffer growth event caused by frame data exceeding current capacity.
    pub fn record_buffer_growth_event(&mut self) {
        self.buffer_growth_events = self.buffer_growth_events.saturating_add(1);
    }

    /// Record one shadow light dispatch and the edge filtering result used for that dispatch.
    pub fn record_shadow_dispatch(&mut self, collected_edges: usize, culled_edges: usize) {
        let collected_edges = u32::try_from(collected_edges).unwrap_or(u32::MAX);
        let culled_edges = u32::try_from(culled_edges).unwrap_or(u32::MAX);
        self.shadow_lights_rendered = self.shadow_lights_rendered.saturating_add(1);
        self.shadow_edges_collected = self.shadow_edges_collected.saturating_add(collected_edges);
        self.shadow_edges_culled = self.shadow_edges_culled.saturating_add(culled_edges);
    }

    /// Return the number of actual render faults in this snapshot.
    ///
    /// Drop-reason counters annotate `dropped_commands` and are therefore not added a
    /// second time.  Allocation growth and shadow work are activity metrics, not
    /// faults, so healthy frames that use them remain fault-free.
    pub fn fault_total(&self) -> u32 {
        self.dropped_commands
            .saturating_add(self.invalid_texture_uploads)
            .saturating_add(self.invalid_canvas_allocations)
            .saturating_add(self.invalid_meshes)
            .saturating_add(self.shader_pipeline_failures)
    }

    /// Return whether an actual non-fatal renderer fault was recorded this frame.
    pub fn has_faults(&self) -> bool {
        self.fault_total() > 0
    }

    /// Return the legacy fault total name.
    #[deprecated(note = "use fault_total; activity metrics are not faults")]
    pub fn finding_total(&self) -> u32 {
        self.fault_total()
    }

    /// Return the legacy fault-presence name.
    #[deprecated(note = "use has_faults; activity metrics are not faults")]
    pub fn has_findings(&self) -> bool {
        self.has_faults()
    }
}
