//! Builds and rewrites per-frame prepared draw lists before GPU pass encoding.
//! Owns frame-local draw coalescing rules so batching remains testable outside the renderer.
//! Keeps compatibility checks close to `PreparedDraw` semantics instead of embedding them in frame orchestration.
//! Preserves high-water scratch allocation by draining into caller-owned buffers and swapping results back.
//! Acts as the CPU frame-list boundary between command tessellation and low-level render-pass encoding.
//! Open this file when compatible draw calls fail to batch or incompatible prepared draws merge incorrectly.

use crate::render::gpu_types::PreparedDraw;

/// Merge adjacent compatible prepared draws and return the number of draw calls removed.
///
/// Compatibility requires identical render target, resource, pipeline, scissor, stencil,
/// static geometry, and instance state. Index spans must be contiguous so the merged draw
/// still references one continuous range in the selected index buffer.
pub fn merge_adjacent_prepared_draws(
    draws: &mut Vec<PreparedDraw>,
    scratch: &mut Vec<PreparedDraw>,
) -> usize {
    let before = draws.len();
    scratch.clear();
    if scratch.capacity() < before {
        scratch.reserve(before - scratch.capacity());
    }

    for draw in draws.drain(..) {
        if let Some(last) = scratch.last_mut() {
            if prepared_draws_can_merge(last, &draw) {
                last.idx_count += draw.idx_count;
                continue;
            }
        }
        scratch.push(draw);
    }

    let after = scratch.len();
    std::mem::swap(draws, scratch);
    before.saturating_sub(after)
}

fn prepared_draws_can_merge(left: &PreparedDraw, right: &PreparedDraw) -> bool {
    left.target == right.target
        && left.geometry == right.geometry
        && left.texture_ref == right.texture_ref
        && left.blend_mode == right.blend_mode
        && left.scissor == right.scissor
        && left.color_mask_bits == right.color_mask_bits
        && left.shader == right.shader
        && left.stencil_mode == right.stencil_mode
        && left.stencil_reference == right.stencil_reference
        && left.static_geometry == right.static_geometry
        && left.instance_buffer == right.instance_buffer
        && left.instance_start == right.instance_start
        && left.instance_count == right.instance_count
        && left.idx_start.checked_add(left.idx_count) == Some(right.idx_start)
}
