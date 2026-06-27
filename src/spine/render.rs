//! This file owns the draw-command bridge that turns a posed `Skeleton` into generic debug render commands.
//! It flattens bone transforms and slot attachments into circles and outlines for a skeleton-agnostic renderer.
//! The output favors readable rig structure over full attachment rendering, making it useful for tooling and inspection.
//! Open this file when skeleton-to-command translation changes; pose updates and slot ownership live in siblings.

use super::skeleton::Skeleton;
use crate::render::renderer::{DrawMode, RenderCommand};
use crate::runtime::resource_keys::TextureKey;
use slotmap::KeyData;

/// Render methods added to Skeleton by this file.
impl Skeleton {
    /// Build a RenderCommand list for all bones (filled circles) and slot attachments (outline rectangles).
    /// at world offset (x, y); returns empty vec when no bones exist.
    pub fn generate_render_commands(&self, x: f32, y: f32) -> Vec<RenderCommand> {
        let mut cmds = Vec::new();
        if self.bones.is_empty() {
            return cmds;
        }
        let radius = 4.0 * self.scale_x.abs().max(self.scale_y.abs()).max(1.0);
        let mut bone_colors: Vec<Option<[f32; 4]>> = vec![None; self.bones.len()];
        for slot in &self.slots {
            if slot.bone_index < self.bones.len() && bone_colors[slot.bone_index].is_none() {
                bone_colors[slot.bone_index] =
                    Some([slot.color_r, slot.color_g, slot.color_b, slot.color_a]);
            }
        }
        for (i, bone) in self.bones.iter().enumerate() {
            let bx = x + bone.world_x;
            let by = y + bone.world_y;
            let [cr, cg, cb, ca] = bone_colors[i].unwrap_or([1.0, 1.0, 1.0, 1.0]);
            cmds.push(RenderCommand::SetColor(cr, cg, cb, ca));
            cmds.push(RenderCommand::Circle {
                mode: DrawMode::Fill,
                x: bx,
                y: by,
                r: radius,
            });
        }
        for (slot_idx, slot) in self.slots.iter().enumerate() {
            if slot.attachment_name.is_none() {
                continue;
            }
            if slot.bone_index >= self.bones.len() {
                continue;
            }
            let bone = &self.bones[slot.bone_index];
            let bx = x + bone.world_x;
            let by = y + bone.world_y;
            if let Some(source) = self.get_attachment_source_for_slot(slot_idx) {
                if let Some(texture_id) = source.texture_id {
                    cmds.push(RenderCommand::SetColor(
                        slot.color_r,
                        slot.color_g,
                        slot.color_b,
                        slot.color_a,
                    ));
                    cmds.push(RenderCommand::DrawQuad {
                        texture_key: TextureKey::from(KeyData::from_ffi(texture_id)),
                        quad_x: source.x,
                        quad_y: source.y,
                        quad_w: source.w,
                        quad_h: source.h,
                        tex_w: source.texture_w.max(source.w),
                        tex_h: source.texture_h.max(source.h),
                        x: bx,
                        y: by,
                        rotation: bone.world_rotation,
                        sx: bone.world_scale_x,
                        sy: bone.world_scale_y,
                        ox: source.w * 0.5,
                        oy: source.h * 0.5,
                        effect: None,
                    });
                    continue;
                }
            }
            let half = radius;
            cmds.push(RenderCommand::SetColor(
                slot.color_r,
                slot.color_g,
                slot.color_b,
                slot.color_a * 0.5,
            ));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Line,
                x: bx - half,
                y: by - half,
                w: half * 2.0,
                h: half * 2.0,
            });
        }
        cmds
    }
}
