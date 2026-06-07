import re

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Fix GpuRenderer::new to include the new fields
idx_new = text.find('pub fn new(')
idx_self = text.find('Self {', idx_new)
# Ensure we don't accidentally match `-> Self {`
if text[idx_self-1] == '>':
    idx_self = text.find('Self {', idx_self + 6)

replacement = """Self {
            gpu_mesh_cache: GpuMeshCache::new(),
            default_color_instanced_shader: device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("default_color_instanced"),
                source: wgpu::ShaderSource::Wgsl(COLOR_INSTANCED_SHADER.into()),
            }),
            default_texture_instanced_shader: device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("default_texture_instanced"),
                source: wgpu::ShaderSource::Wgsl(TEXTURE_INSTANCED_SHADER.into()),
            }),"""

if 'gpu_mesh_cache: GpuMeshCache::new()' not in text[idx_self:idx_self+500]:
    text = text[:idx_self] + replacement + text[idx_self+6:]

# 2. Add `static_geometry: None, instances: None` to all PreparedDraw instantiations
def repl_prepared_draw(m):
    body = m.group(1)
    if 'static_geometry:' not in body:
        return 'PreparedDraw {' + body + '        static_geometry: None,\n        instances: None,\n    }'
    return m.group(0)

text = re.sub(r'PreparedDraw \{([^}]+)\}', repl_prepared_draw, text)

# 3. Replace `issue_draw` implementation
idx_issue = text.find('fn issue_draw(')
idx_issue_end = text.find('true\n    }', idx_issue) + len('true\n    }')

issue_draw_code = '''fn issue_draw(
        &mut self,
        pass: &mut wgpu::RenderPass<'_>,
        draw: PreparedDraw,
        shaders: &SlotMap<ShaderKey, Shader>,
    ) -> bool {
        if let (RenderTargetId::Canvas(active_canvas), Some(TexRef::Canvas(source_canvas))) =
            (draw.target, draw.texture_ref)
        {
            if active_canvas == source_canvas {
                return false;
            }
        }
        
        let pipeline_key = PipelineKey {
            blend_mode: draw.blend_mode,
            color_mask_bits: draw.color_mask_bits,
            stencil_mode: draw.stencil_mode,
            instanced: draw.instances.is_some(),
        };
        
        let effective_shader = shader_for_draw(&draw);
        pass.set_bind_group(0, &self.viewport_bind_group, &[]);
        
        let mut idx_count_to_draw = draw.idx_count;
        let mut inst_count_to_draw = 1;
        
        if let Some(geom_key) = draw.static_geometry {
            if let Some((v_buf, i_buf, idx_count)) = self.gpu_mesh_cache.get_geometry(geom_key) {
                pass.set_vertex_buffer(0, v_buf.slice(..));
                pass.set_index_buffer(i_buf.slice(..), wgpu::IndexFormat::Uint32);
                idx_count_to_draw = *idx_count;
            } else {
                return false;
            }
            if let Some(inst_key) = draw.instances {
                if let Some((inst_buf, inst_count)) = self.gpu_mesh_cache.get_instance_buffer(inst_key) {
                    pass.set_vertex_buffer(1, inst_buf.slice(..));
                    inst_count_to_draw = *inst_count as u32;
                } else {
                    return false;
                }
            }
        }
        
        match draw.geometry {
            GeometryKind::Color => {
                if draw.static_geometry.is_none() {
                    pass.set_vertex_buffer(0, self.color_vertex_buffer.slice(..));
                    pass.set_index_buffer(self.color_index_buffer.slice(..), wgpu::IndexFormat::Uint32);
                }
                if let Some(shader_key) = effective_shader {
                    if let Some(shader) = shaders.get(shader_key) {
                        {
                            let pipeline = self.custom_pipeline(
                                shader_key,
                                shader,
                                draw.geometry,
                                pipeline_key,
                            );
                            pass.set_pipeline(pipeline);
                        }
                        if let Some(bind_group) = self.shader_bind_group(shader_key) {
                            pass.set_bind_group(1, bind_group, &[]);
                        }
                    } else {
                        let pipeline = self.default_pipeline(draw.geometry, pipeline_key);
                        pass.set_pipeline(pipeline);
                    }
                } else {
                    let pipeline = self.default_pipeline(draw.geometry, pipeline_key);
                    pass.set_pipeline(pipeline);
                }
            }
            GeometryKind::Texture => {
                let Some(texture_ref) = draw.texture_ref else {
                    return false;
                };
                if draw.static_geometry.is_none() {
                    pass.set_vertex_buffer(0, self.tex_vertex_buffer.slice(..));
                    pass.set_index_buffer(self.tex_index_buffer.slice(..), wgpu::IndexFormat::Uint32);
                }
                if let Some(shader_key) = effective_shader {
                    if let Some(shader) = shaders.get(shader_key) {
                        {
                            let pipeline = self.custom_pipeline(
                                shader_key,
                                shader,
                                draw.geometry,
                                pipeline_key,
                            );
                            pass.set_pipeline(pipeline);
                        }
                        {
                            let Some(texture_bind_group) = self.texture_bind_group(texture_ref)
                            else {
                                return false;
                            };
                            pass.set_bind_group(1, texture_bind_group, &[]);
                        }
                        if let Some(bind_group) = self.shader_bind_group(shader_key) {
                            pass.set_bind_group(2, bind_group, &[]);
                        }
                    } else {
                        let pipeline = self.default_pipeline(draw.geometry, pipeline_key);
                        pass.set_pipeline(pipeline);
                        let Some(texture_bind_group) = self.texture_bind_group(texture_ref) else {
                            return false;
                        };
                        pass.set_bind_group(1, texture_bind_group, &[]);
                    }
                } else {
                    let pipeline = self.default_pipeline(draw.geometry, pipeline_key);
                    pass.set_pipeline(pipeline);
                    let Some(texture_bind_group) = self.texture_bind_group(texture_ref) else {
                        return false;
                    };
                    pass.set_bind_group(1, texture_bind_group, &[]);
                }
            }
        }
        let (target_width, target_height) = self.target_dimensions_from_gpu(draw.target);
        match draw.scissor {
            Some((sx, sy, sw, sh)) => pass.set_scissor_rect(sx, sy, sw, sh),
            None => pass.set_scissor_rect(0, 0, target_width, target_height),
        }
        pass.set_stencil_reference(draw.stencil_reference);
        if draw.static_geometry.is_some() {
            pass.draw_indexed(0..idx_count_to_draw, 0, 0..inst_count_to_draw);
        } else {
            pass.draw_indexed(draw.idx_start..draw.idx_start + idx_count_to_draw, 0, 0..1);
        }
        true
    }'''

text = text[:idx_issue] + issue_draw_code + text[idx_issue_end:]

# 4. Replace `DrawStaticGeometry` match arms
# `add_logic.py` put them in `match cmd {`. We will find them and replace with push to draws.
arm_start = text.find('&renderer::RenderCommand::DrawStaticGeometry {')
arm_end = text.find('&renderer::RenderCommand::SetScissor', arm_start)
if arm_end != -1:
    new_arms = '''&crate::render::renderer::RenderCommand::DrawStaticGeometry { geometry, instances, texture, blend_mode, scissor } => {
                    let tex_ref = texture.map(TexRef::Texture);
                    let geom_kind = if texture.is_some() { GeometryKind::Texture } else { GeometryKind::Color };
                    draws.push(PreparedDraw {
                        target: current_target,
                        geometry: geom_kind,
                        texture_ref: tex_ref,
                        idx_start: 0,
                        idx_count: 0,
                        blend_mode,
                        scissor,
                        color_mask_bits,
                        shader: current_active_shader,
                        stencil_mode: current_stencil_mode,
                        stencil_reference: stencil_reference as u32,
                        static_geometry: Some(geometry),
                        instances,
                    });
                }
                &crate::render::renderer::RenderCommand::InstancedDraw { geometry, instances, texture, blend_mode, scissor } => {
                    let tex_ref = texture.map(TexRef::Texture);
                    let geom_kind = if texture.is_some() { GeometryKind::Texture } else { GeometryKind::Color };
                    draws.push(PreparedDraw {
                        target: current_target,
                        geometry: geom_kind,
                        texture_ref: tex_ref,
                        idx_start: 0,
                        idx_count: 0,
                        blend_mode,
                        scissor,
                        color_mask_bits,
                        shader: current_active_shader,
                        stencil_mode: current_stencil_mode,
                        stencil_reference: stencil_reference as u32,
                        static_geometry: Some(geometry),
                        instances: Some(instances),
                    });
                }
                '''
    text = text[:arm_start] + new_arms + text[arm_end:]

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Clean fix applied to gpu_renderer.rs')
