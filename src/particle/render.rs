//! Render-command generation for particle systems and trails.
//! Expands textured particle batches into individual draw calls when needed.
//! Keeps untextured particles batched for efficiency.
//! Bridges live particle state to renderer submission.

use super::emitter::ParticleSystem;
use super::trail::Trail;
use crate::render::renderer::RenderCommand;
impl ParticleSystem {
    /// Generate render commands for this system at world offset `(0, 0)`.
    pub fn generate_render_commands(&self) -> Vec<RenderCommand> {
        self.build_render_commands(0.0, 0.0)
    }
}
impl Trail {
    /// Generate `RenderCommand` values for the trail ribbon.
    pub fn generate_render_commands(&self) -> Vec<RenderCommand> {
        self.build_render_commands()
    }
}
/// Expand `DrawParticleSystem` commands: textured particles become individual draw calls; untextured stay batched.
pub fn expand_particle_commands(cmds: Vec<RenderCommand>) -> Vec<RenderCommand> {
    let mut out = Vec::with_capacity(cmds.len());
    for cmd in cmds {
        if let RenderCommand::DrawParticleSystem { particles } = cmd {
            let mut untextured = Vec::new();
            for particle in particles {
                if let Some(tex_key) = particle.texture_key {
                    if let Some([qx, qy, qw, qh]) = particle.quad {
                        let (tex_w, tex_h) = particle.quad_tex_dims.unwrap_or((qw, qh));
                        let scale = if qw > 0.0 { particle.size / qw } else { 1.0 };
                        out.push(RenderCommand::DrawQuad {
                            texture_key: tex_key,
                            quad_x: qx,
                            quad_y: qy,
                            quad_w: qw,
                            quad_h: qh,
                            tex_w,
                            tex_h,
                            x: particle.x,
                            y: particle.y,
                            rotation: particle.rotation,
                            sx: scale,
                            sy: scale,
                            ox: particle.size * 0.5,
                            oy: particle.size * 0.5,
                            effect: None,
                        });
                    } else {
                        out.push(RenderCommand::DrawImageEx {
                            texture_key: tex_key,
                            x: particle.x,
                            y: particle.y,
                            rotation: particle.rotation,
                            sx: 1.0,
                            sy: 1.0,
                            ox: particle.size * 0.5,
                            oy: particle.size * 0.5,
                            effect: None,
                        });
                    }
                } else {
                    untextured.push(particle);
                }
            }
            if !untextured.is_empty() {
                out.push(RenderCommand::DrawParticleSystem {
                    particles: untextured,
                });
            }
        } else {
            out.push(cmd);
        }
    }
    out
}
