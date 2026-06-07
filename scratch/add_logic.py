import os
import re

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

impl_fns = '''
    pub(crate) fn bake_geometry(&mut self, key: StaticGeometryKey, vertices: &[crate::render::renderer::Vertex], indices: &[u32]) {
        self.gpu_mesh_cache.bake_geometry(&self.device, key, vertices, indices);
    }

    pub(crate) fn create_instance_buffer(&mut self, key: InstanceBufferKey, data: &[InstanceData]) {
        self.gpu_mesh_cache.create_instance_buffer(&self.device, key, data);
    }
'''

if 'pub(crate) fn bake_geometry' not in text:
    text = text.replace('pub(crate) fn device(&self) -> &wgpu::Device {', impl_fns + '\n    pub(crate) fn device(&self) -> &wgpu::Device {')

encode_arms = '''
                &renderer::RenderCommand::DrawStaticGeometry { geometry, instances, texture, blend_mode, scissor } => {
                    let blend = blend_state_for(blend_mode);
                    let format = self.surface_format;
                    let pipeline_key = PipelineKey {
                        blend_mode,
                        color_mask_bits: 15,
                        stencil_mode: StencilMode::Disabled,
                        instanced: instances.is_some(),
                    };
                    
                    let pipeline_sel = if texture.is_some() {
                        PipelineSelectionKey::Default { geometry: GeometryKind::Texture, pipeline: pipeline_key }
                    } else {
                        PipelineSelectionKey::Default { geometry: GeometryKind::Color, pipeline: pipeline_key }
                    };
                    
                    let pipeline = self.pipeline_selection_key(pipeline_sel);

                    pass.set_pipeline(pipeline);
                    pass.set_bind_group(0, &self.viewport_bind_group, &[]);

                    if let Some(tex) = texture {
                        if let Some(gpu_tex) = self.gpu_textures.get(tex) {
                            pass.set_bind_group(1, &gpu_tex.bind_group, &[]);
                        }
                    }

                    if let Some(scissor) = normalize_scissor(scissor, self.width, self.height) {
                        pass.set_scissor_rect(scissor.0, scissor.1, scissor.2, scissor.3);
                    } else {
                        pass.set_scissor_rect(0, 0, self.width, self.height);
                    }

                    if let Some((v_buf, i_buf, idx_count)) = self.gpu_mesh_cache.get_geometry(geometry) {
                        pass.set_vertex_buffer(0, v_buf.slice(..));
                        pass.set_index_buffer(i_buf.slice(..), wgpu::IndexFormat::Uint32);
                        
                        if let Some(inst) = instances {
                            if let Some((inst_buf, inst_count)) = self.gpu_mesh_cache.get_instance_buffer(inst) {
                                pass.set_vertex_buffer(1, inst_buf.slice(..));
                                pass.draw_indexed(0..idx_count, 0, 0..inst_count as u32);
                            }
                        } else {
                            pass.draw_indexed(0..idx_count, 0, 0..1);
                        }
                    }
                }
                &renderer::RenderCommand::InstancedDraw { geometry, instances, texture, blend_mode, scissor } => {
                    let blend = blend_state_for(blend_mode);
                    let format = self.surface_format;
                    let pipeline_key = PipelineKey {
                        blend_mode,
                        color_mask_bits: 15,
                        stencil_mode: StencilMode::Disabled,
                        instanced: true,
                    };
                    
                    let pipeline_sel = if texture.is_some() {
                        PipelineSelectionKey::Default { geometry: GeometryKind::Texture, pipeline: pipeline_key }
                    } else {
                        PipelineSelectionKey::Default { geometry: GeometryKind::Color, pipeline: pipeline_key }
                    };
                    
                    let pipeline = self.pipeline_selection_key(pipeline_sel);

                    pass.set_pipeline(pipeline);
                    pass.set_bind_group(0, &self.viewport_bind_group, &[]);

                    if let Some(tex) = texture {
                        if let Some(gpu_tex) = self.gpu_textures.get(tex) {
                            pass.set_bind_group(1, &gpu_tex.bind_group, &[]);
                        }
                    }

                    if let Some(scissor) = normalize_scissor(scissor, self.width, self.height) {
                        pass.set_scissor_rect(scissor.0, scissor.1, scissor.2, scissor.3);
                    } else {
                        pass.set_scissor_rect(0, 0, self.width, self.height);
                    }

                    if let Some((v_buf, i_buf, idx_count)) = self.gpu_mesh_cache.get_geometry(geometry) {
                        pass.set_vertex_buffer(0, v_buf.slice(..));
                        pass.set_index_buffer(i_buf.slice(..), wgpu::IndexFormat::Uint32);
                        
                        if let Some((inst_buf, inst_count)) = self.gpu_mesh_cache.get_instance_buffer(instances) {
                            pass.set_vertex_buffer(1, inst_buf.slice(..));
                            pass.draw_indexed(0..idx_count, 0, 0..inst_count as u32);
                        }
                    }
                }
'''

if 'DrawStaticGeometry {' not in text:
    text = text.replace('match cmd {', 'match cmd {\n' + encode_arms)
    
with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Added missing logic to gpu_renderer.rs')
