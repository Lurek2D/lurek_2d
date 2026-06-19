//! Replays text render commands into GPU font-atlas draw buffers.
//! Keeps glyph expansion, cursor advance, wrapping, alignment, span coloring, and font-atlas draw emission out of frame orchestration.
//! Uses caller-owned texture scratch buffers so plain, formatted, and rich text do not allocate per glyph.
//! Preserves current blend, scissor, shader, color mask, and stencil state when emitting prepared draws.
//! Acts as the GPU text boundary between font metrics and prepared textured draw ranges.
//! Open this file when plain, formatted, or rich text glyph output differs from font metrics or current draw state.

use slotmap::SlotMap;

use crate::math::Mat3;
use crate::render::gpu_pipeline::GpuStencilMode;
use crate::render::gpu_renderer::GpuRenderer;
use crate::render::gpu_tess::{append_tex_draw_slices, normalize_scissor, push_tex_quad};
use crate::render::gpu_types::{PreparedDraw, RenderTargetId, ScissorRect, TexRef, TexVertex};
use crate::render::renderer::{BlendMode, TextAlign, TextSpan};
use crate::render::shader::Shader;
use crate::runtime::resource_keys::{CanvasKey, FontKey, ShaderKey};

impl GpuRenderer {
    /// Replay a plain text run into the frame's textured buffers and prepared draws.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn replay_plain_text(
        &mut self,
        font_key: FontKey,
        text: &str,
        x: f32,
        y: f32,
        scale: f32,
        color: [f32; 4],
        transform: &Mat3,
        current_target: RenderTargetId,
        current_blend_mode: BlendMode,
        current_scissor: Option<(f32, f32, f32, f32)>,
        color_mask_bits: u32,
        active_shader: Option<ShaderKey>,
        stencil_mode: GpuStencilMode,
        stencil_reference: u8,
        canvases: &SlotMap<CanvasKey, crate::render::Canvas>,
        shaders: &SlotMap<ShaderKey, Shader>,
        fonts: &mut SlotMap<FontKey, crate::render::Font>,
        default_filter: &(String, String, u32),
        all_tex_verts: &mut Vec<TexVertex>,
        all_tex_idxs: &mut Vec<u32>,
        scratch_tex_verts: &mut Vec<TexVertex>,
        scratch_tex_idxs: &mut Vec<u32>,
        draws: &mut Vec<PreparedDraw>,
    ) {
        let Some(font) = fonts.get_mut(font_key) else {
            return;
        };
        if !self.ensure_font_atlas(font_key, font, default_filter) {
            return;
        }

        let (target_width, target_height) = self.target_dimensions(current_target, canvases);
        let scissor = normalize_scissor(current_scissor, target_width, target_height);
        let mut cursor_x = x;
        let font_size = font.size();
        for ch in text.chars() {
            if let Some(glyph) = font.glyph(ch) {
                if glyph.width > 0 && glyph.height > 0 {
                    emit_glyph_quad(
                        font_key,
                        font_size,
                        &glyph,
                        cursor_x,
                        y,
                        scale,
                        color,
                        transform,
                        current_target,
                        current_blend_mode,
                        scissor,
                        color_mask_bits,
                        active_shader,
                        stencil_mode,
                        stencil_reference,
                        shaders,
                        all_tex_verts,
                        all_tex_idxs,
                        scratch_tex_verts,
                        scratch_tex_idxs,
                        draws,
                    );
                }
                cursor_x += glyph.advance_width * scale;
            }
        }
    }

    /// Replay wrapped and aligned text into the frame's textured buffers and prepared draws.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn replay_formatted_text(
        &mut self,
        font_key: FontKey,
        text: &str,
        x: f32,
        y: f32,
        limit: f32,
        align: TextAlign,
        scale: f32,
        color: [f32; 4],
        transform: &Mat3,
        current_target: RenderTargetId,
        current_blend_mode: BlendMode,
        current_scissor: Option<(f32, f32, f32, f32)>,
        color_mask_bits: u32,
        active_shader: Option<ShaderKey>,
        stencil_mode: GpuStencilMode,
        stencil_reference: u8,
        canvases: &SlotMap<CanvasKey, crate::render::Canvas>,
        shaders: &SlotMap<ShaderKey, Shader>,
        fonts: &mut SlotMap<FontKey, crate::render::Font>,
        default_filter: &(String, String, u32),
        all_tex_verts: &mut Vec<TexVertex>,
        all_tex_idxs: &mut Vec<u32>,
        scratch_tex_verts: &mut Vec<TexVertex>,
        scratch_tex_idxs: &mut Vec<u32>,
        draws: &mut Vec<PreparedDraw>,
    ) {
        let Some(font) = fonts.get_mut(font_key) else {
            return;
        };
        let wrapped = font.wrap_text(text, limit / scale);
        let line_height = font.line_height() * scale;
        let font_size = font.size();
        if !self.ensure_font_atlas(font_key, font, default_filter) {
            return;
        }

        let (target_width, target_height) = self.target_dimensions(current_target, canvases);
        let scissor = normalize_scissor(current_scissor, target_width, target_height);
        for (line_index, line) in wrapped.iter().enumerate() {
            let line_width = font.text_width(line) * scale;
            let x_offset = match align {
                TextAlign::Center => (limit - line_width) * 0.5,
                TextAlign::Right => limit - line_width,
                _ => 0.0,
            };
            let line_y = y + line_index as f32 * line_height;
            let mut cursor_x = x + x_offset;
            for ch in line.chars() {
                if let Some(glyph) = font.glyph(ch) {
                    if glyph.width > 0 && glyph.height > 0 {
                        emit_glyph_quad(
                            font_key,
                            font_size,
                            &glyph,
                            cursor_x,
                            line_y,
                            scale,
                            color,
                            transform,
                            current_target,
                            current_blend_mode,
                            scissor,
                            color_mask_bits,
                            active_shader,
                            stencil_mode,
                            stencil_reference,
                            shaders,
                            all_tex_verts,
                            all_tex_idxs,
                            scratch_tex_verts,
                            scratch_tex_idxs,
                            draws,
                        );
                    }
                    cursor_x += glyph.advance_width * scale;
                }
            }
        }
    }

    /// Replay rich text spans into the frame's textured buffers and prepared draws.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn replay_rich_text(
        &mut self,
        font_key: FontKey,
        spans: &[TextSpan],
        x: f32,
        y: f32,
        transform: &Mat3,
        current_target: RenderTargetId,
        current_blend_mode: BlendMode,
        current_scissor: Option<(f32, f32, f32, f32)>,
        color_mask_bits: u32,
        active_shader: Option<ShaderKey>,
        stencil_mode: GpuStencilMode,
        stencil_reference: u8,
        canvases: &SlotMap<CanvasKey, crate::render::Canvas>,
        shaders: &SlotMap<ShaderKey, Shader>,
        fonts: &mut SlotMap<FontKey, crate::render::Font>,
        default_filter: &(String, String, u32),
        all_tex_verts: &mut Vec<TexVertex>,
        all_tex_idxs: &mut Vec<u32>,
        scratch_tex_verts: &mut Vec<TexVertex>,
        scratch_tex_idxs: &mut Vec<u32>,
        draws: &mut Vec<PreparedDraw>,
    ) {
        let Some(font) = fonts.get_mut(font_key) else {
            return;
        };
        if !self.ensure_font_atlas(font_key, font, default_filter) {
            return;
        }

        let (target_width, target_height) = self.target_dimensions(current_target, canvases);
        let scissor = normalize_scissor(current_scissor, target_width, target_height);
        let mut cursor_x = x;
        let font_size = font.size();
        for span in spans {
            let span_color = [
                span.r as f32 / 255.0,
                span.g as f32 / 255.0,
                span.b as f32 / 255.0,
                span.a as f32 / 255.0,
            ];
            for ch in span.text.chars() {
                if let Some(glyph) = font.glyph(ch) {
                    if glyph.width > 0 && glyph.height > 0 {
                        emit_glyph_quad(
                            font_key,
                            font_size,
                            &glyph,
                            cursor_x,
                            y,
                            span.scale,
                            span_color,
                            transform,
                            current_target,
                            current_blend_mode,
                            scissor,
                            color_mask_bits,
                            active_shader,
                            stencil_mode,
                            stencil_reference,
                            shaders,
                            all_tex_verts,
                            all_tex_idxs,
                            scratch_tex_verts,
                            scratch_tex_idxs,
                            draws,
                        );
                    }
                    cursor_x += glyph.advance_width * span.scale;
                }
            }
        }
    }
}

#[allow(clippy::too_many_arguments)]
fn emit_glyph_quad(
    font_key: FontKey,
    font_size: f32,
    glyph: &crate::render::font::GlyphInfo,
    cursor_x: f32,
    y: f32,
    scale: f32,
    color: [f32; 4],
    transform: &Mat3,
    current_target: RenderTargetId,
    current_blend_mode: BlendMode,
    scissor: ScissorRect,
    color_mask_bits: u32,
    active_shader: Option<ShaderKey>,
    stencil_mode: GpuStencilMode,
    stencil_reference: u8,
    shaders: &SlotMap<ShaderKey, Shader>,
    all_tex_verts: &mut Vec<TexVertex>,
    all_tex_idxs: &mut Vec<u32>,
    scratch_tex_verts: &mut Vec<TexVertex>,
    scratch_tex_idxs: &mut Vec<u32>,
    draws: &mut Vec<PreparedDraw>,
) {
    let gw = glyph.width as f32 * scale;
    let gh = glyph.height as f32 * scale;
    let gx = cursor_x + glyph.offset_x * scale;
    let gy = y + (font_size - glyph.offset_y - glyph.height as f32) * scale;
    scratch_tex_verts.clear();
    scratch_tex_idxs.clear();
    push_tex_quad(
        scratch_tex_verts,
        scratch_tex_idxs,
        transform,
        color,
        gx,
        gy,
        0.0,
        1.0,
        1.0,
        0.0,
        0.0,
        gw,
        gh,
        glyph.uv_x,
        glyph.uv_y,
        glyph.uv_x + glyph.uv_w,
        glyph.uv_y + glyph.uv_h,
    );
    append_tex_draw_slices(
        draws,
        all_tex_verts,
        all_tex_idxs,
        current_target,
        TexRef::FontAtlas(font_key),
        current_blend_mode,
        scissor,
        color_mask_bits,
        active_shader.filter(|key| shaders.contains_key(*key)),
        stencil_mode,
        stencil_reference,
        scratch_tex_verts,
        scratch_tex_idxs,
    );
}
