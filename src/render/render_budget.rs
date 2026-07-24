//! Owns cumulative, backend-independent limits for one accepted render frame.
//! It is deliberately checked before tessellation, allocation, or command encoding so
//! Lua command streams cannot turn individually valid requests into unbounded work.

use crate::render::renderer::{RenderCommand, RenderCommandCategory};
use std::fmt;

/// Trusted engine limits for aggregate Lua-driven work in one frame.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct RenderBudgetLimits {
    /// Maximum number of commands accepted from all command families.
    pub max_commands: usize,
    /// Maximum accepted commands in one broad family.
    pub max_commands_per_family: usize,
    /// Maximum source geometry vertices across shape commands.
    pub max_geometry_vertices: usize,
    /// Maximum UTF-8 bytes accepted by text commands.
    pub max_text_bytes: usize,
    /// Maximum rich-text spans accepted across a frame.
    pub max_text_spans: usize,
    /// Maximum post-processing passes accepted across a frame.
    pub max_postfx_passes: usize,
    /// Maximum sprite instances expanded by batch draw commands across a frame.
    pub max_sprite_batch_items: usize,
    /// Maximum rendered light quads accepted across a frame.
    pub max_light_quads: usize,
    /// Maximum shadow-atlas rows dispatched across a frame.
    pub max_shadow_lights: usize,
}

impl Default for RenderBudgetLimits {
    fn default() -> Self {
        Self {
            max_commands: 65_536,
            max_commands_per_family: 32_768,
            max_geometry_vertices: 1_000_000,
            max_text_bytes: 1_048_576,
            max_text_spans: 16_384,
            max_postfx_passes: 1_024,
            max_sprite_batch_items: 250_000,
            max_light_quads: crate::render::gpu_types::MAX_LIGHT_QUADS,
            max_shadow_lights: crate::render::gpu_light::MAX_SHADOW_LIGHTS,
        }
    }
}

impl RenderBudgetLimits {
    /// Clamp trusted aggregate work ceilings to the active device's largest geometry stride.
    ///
    /// This stays renderer-owned: Lua observes the effective limit only through accepted work
    /// and cannot raise either the engine policy or the device-derived ceiling.
    pub fn for_device(limits: &wgpu::Limits) -> Self {
        let mut effective = Self::default();
        let largest_stride = std::mem::size_of::<crate::render::gpu_types::ColorVertex>()
            .max(std::mem::size_of::<crate::render::gpu_types::TexVertex>())
            .max(std::mem::size_of::<crate::render::gpu_types::ParticleVertex>());
        let Ok(stride) = u64::try_from(largest_stride) else {
            return effective;
        };
        if stride == 0 {
            return effective;
        }
        let device_vertices = limits.max_buffer_size / stride;
        let device_vertices = match usize::try_from(device_vertices) {
            Ok(value) => value,
            Err(_) => usize::MAX,
        };
        effective.max_geometry_vertices = effective.max_geometry_vertices.min(device_vertices);
        effective.max_sprite_batch_items = effective
            .max_sprite_batch_items
            .min(device_vertices.saturating_div(4));
        effective
    }
}

/// The aggregate counter state for the current frame.
#[derive(Debug, Default, Clone, Copy, PartialEq, Eq)]
pub struct RenderBudget {
    commands: usize,
    family_commands: [usize; 13],
    geometry_vertices: usize,
    text_bytes: usize,
    text_spans: usize,
    postfx_passes: usize,
    sprite_batch_items: usize,
    light_quads: usize,
    shadow_lights: usize,
}

/// A deterministic aggregate-budget rejection.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RenderBudgetError {
    /// A named cumulative counter would exceed its trusted maximum.
    Exceeded {
        field: &'static str,
        attempted: usize,
        max: usize,
    },
}

impl fmt::Display for RenderBudgetError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Exceeded {
                field,
                attempted,
                max,
            } => {
                write!(
                    f,
                    "render frame {field} would be {attempted}, maximum is {max}"
                )
            }
        }
    }
}

impl std::error::Error for RenderBudgetError {}

impl RenderBudget {
    /// Clear all counters at a frame boundary.
    pub fn reset(&mut self) {
        *self = Self::default();
    }

    /// Validate and commit one command atomically.
    pub fn try_accept(
        &mut self,
        command: &RenderCommand,
        limits: &RenderBudgetLimits,
    ) -> Result<(), RenderBudgetError> {
        self.try_accept_with_batch_items(command, 0, limits)
    }

    /// Validate and commit one command plus its resolved sprite-batch workload atomically.
    pub fn try_accept_with_batch_items(
        &mut self,
        command: &RenderCommand,
        batch_items: usize,
        limits: &RenderBudgetLimits,
    ) -> Result<(), RenderBudgetError> {
        let category = command.category();
        let family_index = category_index(category);
        let (vertices, text_bytes, spans, passes) = command_cost(command);
        let commands = checked_next(self.commands, 1, limits.max_commands, "commands")?;
        let family_commands = checked_next(
            self.family_commands[family_index],
            1,
            limits.max_commands_per_family,
            "commands in command family",
        )?;
        let geometry_vertices = checked_next(
            self.geometry_vertices,
            vertices,
            limits.max_geometry_vertices,
            "geometry vertices",
        )?;
        let text_bytes = checked_next(
            self.text_bytes,
            text_bytes,
            limits.max_text_bytes,
            "text bytes",
        )?;
        let text_spans = checked_next(self.text_spans, spans, limits.max_text_spans, "text spans")?;
        let postfx_passes = checked_next(
            self.postfx_passes,
            passes,
            limits.max_postfx_passes,
            "postfx passes",
        )?;
        let sprite_batch_items = checked_next(
            self.sprite_batch_items,
            batch_items,
            limits.max_sprite_batch_items,
            "sprite batch items",
        )?;
        self.commands = commands;
        self.family_commands[family_index] = family_commands;
        self.geometry_vertices = geometry_vertices;
        self.text_bytes = text_bytes;
        self.text_spans = text_spans;
        self.postfx_passes = postfx_passes;
        self.sprite_batch_items = sprite_batch_items;
        Ok(())
    }

    /// Validate and commit the renderer-owned lighting workload for this frame.
    pub fn try_accept_light_work(
        &mut self,
        light_quads: usize,
        shadow_lights: usize,
        limits: &RenderBudgetLimits,
    ) -> Result<(), RenderBudgetError> {
        let next_light_quads = checked_next(
            self.light_quads,
            light_quads,
            limits.max_light_quads,
            "light quads",
        )?;
        let next_shadow_lights = checked_next(
            self.shadow_lights,
            shadow_lights,
            limits.max_shadow_lights,
            "shadow lights",
        )?;
        self.light_quads = next_light_quads;
        self.shadow_lights = next_shadow_lights;
        Ok(())
    }
}

fn checked_next(
    current: usize,
    add: usize,
    max: usize,
    field: &'static str,
) -> Result<usize, RenderBudgetError> {
    let attempted = current.saturating_add(add);
    if attempted > max {
        return Err(RenderBudgetError::Exceeded {
            field,
            attempted,
            max,
        });
    }
    Ok(attempted)
}

fn category_index(category: RenderCommandCategory) -> usize {
    match category {
        RenderCommandCategory::State => 0,
        RenderCommandCategory::Transform => 1,
        RenderCommandCategory::Shape => 2,
        RenderCommandCategory::Texture => 3,
        RenderCommandCategory::Text => 4,
        RenderCommandCategory::Canvas => 5,
        RenderCommandCategory::Mesh => 6,
        RenderCommandCategory::Batch => 7,
        RenderCommandCategory::Effect => 8,
        RenderCommandCategory::Ordering => 9,
        RenderCommandCategory::Layer => 10,
        RenderCommandCategory::Instance => 11,
        RenderCommandCategory::Debug => 12,
    }
}

fn command_cost(command: &RenderCommand) -> (usize, usize, usize, usize) {
    use RenderCommand::*;
    match command {
        Polygon { vertices, .. } | Polyline { points: vertices } => (vertices.len() / 2, 0, 0, 0),
        Points { points } => (points.len(), 0, 0, 0),
        DrawColoredPolygon { vertices, .. } => (vertices.len(), 0, 0, 0),
        Print { text, .. } | PrintTransformed { text, .. } | PrintFormatted { text, .. } => {
            (0, text.len(), 0, 0)
        }
        DrawRichText { spans, .. } | DrawRichTextTransformed { spans, .. } => (
            0,
            spans.iter().map(|span| span.text.len()).sum(),
            spans.len(),
            0,
        ),
        // Ring particles produce 40 source vertices; charge that worst case before tessellation.
        DrawParticleSystem { particles, .. } => (particles.len().saturating_mul(40), 0, 0, 0),
        ApplyPostFx { passes, .. } => (0, 0, 0, passes.len()),
        ApplyShaderToCanvas { passes, .. } | ApplyEffectToCanvas { passes, .. } => {
            (0, 0, 0, passes.len())
        }
        DrawImage { effect, .. } | DrawImageEx { effect, .. } | DrawQuad { effect, .. } => {
            (0, 0, 0, effect.as_ref().map_or(0, Vec::len))
        }
        _ => (0, 0, 0, 0),
    }
}
