import os

renderer_path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs'
with open(renderer_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update create_render_pipeline
old_create = '''fn create_render_pipeline(
    device: &wgpu::Device,
    surface_format: wgpu::TextureFormat,
    layout: &wgpu::PipelineLayout,
    module: &wgpu::ShaderModule,
    geometry: GeometryKind,
    key: PipelineKey,
    fragment_entry: &str,
) -> wgpu::RenderPipeline {'''

new_create = '''fn create_render_pipeline(
    device: &wgpu::Device,
    surface_format: wgpu::TextureFormat,
    layout: &wgpu::PipelineLayout,
    module: &wgpu::ShaderModule,
    geometry: GeometryKind,
    key: PipelineKey,
    instanced: bool,
    fragment_entry: &str,
) -> wgpu::RenderPipeline {'''

content = content.replace(old_create, new_create)

# Replace the match geometry { ... } block inside create_render_pipeline
old_match = '''    match geometry {
        GeometryKind::Color => device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("color_pipeline"),
            layout: Some(layout),
            vertex: wgpu::VertexState {
                module,
                entry_point: "vs_main",
                compilation_options: Default::default(),
                buffers: &[wgpu::VertexBufferLayout {
                    array_stride: std::mem::size_of::<ColorVertex>() as wgpu::BufferAddress,
                    step_mode: wgpu::VertexStepMode::Vertex,
                    attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x4],
                }],
            },
            fragment: Some(wgpu::FragmentState {
                module,
                entry_point: fragment_entry,
                compilation_options: Default::default(),
                targets: &[target.clone()],
            }),
            primitive,
            depth_stencil: Some(depth_stencil_state(key.stencil_mode)),
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
            cache: None,
        }),
        GeometryKind::Texture => device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("texture_pipeline"),
            layout: Some(layout),
            vertex: wgpu::VertexState {
                module,
                entry_point: "vs_main",
                compilation_options: Default::default(),
                buffers: &[wgpu::VertexBufferLayout {
                    array_stride: std::mem::size_of::<TexVertex>() as wgpu::BufferAddress,
                    step_mode: wgpu::VertexStepMode::Vertex,
                    attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x2, 2 => Float32x4, 3 => Float32],
                }],
            },
            fragment: Some(wgpu::FragmentState {
                module,
                entry_point: fragment_entry,
                compilation_options: Default::default(),
                targets: &[target.clone()],
            }),
            primitive,
            depth_stencil: Some(depth_stencil_state(key.stencil_mode)),
            multisample: wgpu::MultisampleState::default(),
            multiview: None,
            cache: None,
        }),
    }'''

new_match = '''    let mut buffers: Vec<wgpu::VertexBufferLayout> = Vec::new();
    match geometry {
        GeometryKind::Color => {
            buffers.push(wgpu::VertexBufferLayout {
                array_stride: std::mem::size_of::<ColorVertex>() as wgpu::BufferAddress,
                step_mode: wgpu::VertexStepMode::Vertex,
                attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x4],
            });
        }
        GeometryKind::Texture => {
            buffers.push(wgpu::VertexBufferLayout {
                array_stride: std::mem::size_of::<TexVertex>() as wgpu::BufferAddress,
                step_mode: wgpu::VertexStepMode::Vertex,
                attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x2, 2 => Float32x4, 3 => Float32],
            });
        }
    }
    if instanced {
        buffers.push(crate::render::gpu_types::InstanceData::desc());
    }

    device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: Some("pipeline"),
        layout: Some(layout),
        vertex: wgpu::VertexState {
            module,
            entry_point: "vs_main",
            compilation_options: Default::default(),
            buffers: &buffers,
        },
        fragment: Some(wgpu::FragmentState {
            module,
            entry_point: fragment_entry,
            compilation_options: Default::default(),
            targets: &[target],
        }),
        primitive,
        depth_stencil: Some(depth_stencil_state(key.stencil_mode)),
        multisample: wgpu::MultisampleState::default(),
        multiview: None,
        cache: None,
    })'''

# Replace it inside create_render_pipeline
import re
content = re.sub(r'match geometry \{\s+GeometryKind::Color.*?cache: None,\n        \}\),\n    \}', new_match, content, flags=re.DOTALL)


# 2. Update default_pipeline signature and body
old_def = '''    fn default_pipeline(
        &mut self,
        geometry: GeometryKind,
        key: PipelineKey,
    ) -> &wgpu::RenderPipeline {
        let missing = match geometry {
            GeometryKind::Color => !self.default_color_pipelines.contains_key(&key),
            GeometryKind::Texture => !self.default_texture_pipelines.contains_key(&key),
        };
        if missing {
            let pipeline = match geometry {
                GeometryKind::Color => create_render_pipeline(
                    &self.device,
                    self.surface_format,
                    &self.default_color_layout,
                    &self.default_color_shader,
                    geometry,
                    key,
                    "fs_main",
                ),
                GeometryKind::Texture => create_render_pipeline(
                    &self.device,
                    self.surface_format,
                    &self.default_texture_layout,
                    &self.default_texture_shader,
                    geometry,
                    key,
                    "fs_main",
                ),
            };
            match geometry {
                GeometryKind::Color => self.default_color_pipelines.insert(key, pipeline),
                GeometryKind::Texture => self.default_texture_pipelines.insert(key, pipeline),
            };
        }
        match geometry {
            GeometryKind::Color => self.default_color_pipelines.get(&key).unwrap(),
            GeometryKind::Texture => self.default_texture_pipelines.get(&key).unwrap(),
        }
    }'''

new_def = '''    fn default_pipeline(
        &mut self,
        geometry: GeometryKind,
        key: PipelineKey,
        instanced: bool,
    ) -> &wgpu::RenderPipeline {
        let missing = match (geometry, instanced) {
            (GeometryKind::Color, false) => !self.default_color_pipelines.contains_key(&key),
            (GeometryKind::Texture, false) => !self.default_texture_pipelines.contains_key(&key),
            (GeometryKind::Color, true) => !self.default_color_instanced_pipelines.contains_key(&key),
            (GeometryKind::Texture, true) => !self.default_texture_instanced_pipelines.contains_key(&key),
        };
        if missing {
            let shader = match (geometry, instanced) {
                (GeometryKind::Color, false) => &self.default_color_shader,
                (GeometryKind::Texture, false) => &self.default_texture_shader,
                (GeometryKind::Color, true) => &self.default_color_instanced_shader,
                (GeometryKind::Texture, true) => &self.default_texture_instanced_shader,
            };
            let layout = match geometry {
                GeometryKind::Color => &self.default_color_layout,
                GeometryKind::Texture => &self.default_texture_layout,
            };
            let pipeline = create_render_pipeline(
                &self.device,
                self.surface_format,
                layout,
                shader,
                geometry,
                key,
                instanced,
                "fs_main",
            );
            match (geometry, instanced) {
                (GeometryKind::Color, false) => self.default_color_pipelines.insert(key, pipeline),
                (GeometryKind::Texture, false) => self.default_texture_pipelines.insert(key, pipeline),
                (GeometryKind::Color, true) => self.default_color_instanced_pipelines.insert(key, pipeline),
                (GeometryKind::Texture, true) => self.default_texture_instanced_pipelines.insert(key, pipeline),
            };
        }
        match (geometry, instanced) {
            (GeometryKind::Color, false) => self.default_color_pipelines.get(&key).unwrap(),
            (GeometryKind::Texture, false) => self.default_texture_pipelines.get(&key).unwrap(),
            (GeometryKind::Color, true) => self.default_color_instanced_pipelines.get(&key).unwrap(),
            (GeometryKind::Texture, true) => self.default_texture_instanced_pipelines.get(&key).unwrap(),
        }
    }'''

content = content.replace(old_def, new_def)

# 3. Update custom_pipeline
old_custom = '''    fn custom_pipeline(
        &mut self,
        shader_key: ShaderKey,
        geometry: GeometryKind,
        key: PipelineKey,
    ) -> &wgpu::RenderPipeline {
        let missing = {
            let shader = self.shader_cache.get(&shader_key).unwrap();
            match geometry {
                GeometryKind::Color => !shader.color_pipelines.contains_key(&key),
                GeometryKind::Texture => !shader.texture_pipelines.contains_key(&key),
            }
        };
        if missing {
            let pipeline = {
                let shader = self.shader_cache.get(&shader_key).unwrap();
                match geometry {
                    GeometryKind::Color => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &shader.color_layout,
                        &shader.color_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                    ),
                    GeometryKind::Texture => create_render_pipeline(
                        &self.device,
                        self.surface_format,
                        &shader.texture_layout,
                        &shader.texture_module,
                        geometry,
                        key,
                        "lurek_fragment_main",
                    ),
                }
            };
            let shader = self.shader_cache.get_mut(&shader_key).unwrap();
            match geometry {
                GeometryKind::Color => shader.color_pipelines.insert(key, pipeline),
                GeometryKind::Texture => shader.texture_pipelines.insert(key, pipeline),
            };
        }
        let shader = self.shader_cache.get(&shader_key).unwrap();
        match geometry {
            GeometryKind::Color => shader.color_pipelines.get(&key).unwrap(),
            GeometryKind::Texture => shader.texture_pipelines.get(&key).unwrap(),
        }
    }'''

new_custom = '''    fn custom_pipeline(
        &mut self,
        shader_key: ShaderKey,
        geometry: GeometryKind,
        key: PipelineKey,
        instanced: bool,
    ) -> &wgpu::RenderPipeline {
        let missing = {
            let shader = self.shader_cache.get(&shader_key).unwrap();
            match (geometry, instanced) {
                (GeometryKind::Color, false) => !shader.color_pipelines.contains_key(&key),
                (GeometryKind::Texture, false) => !shader.texture_pipelines.contains_key(&key),
                (GeometryKind::Color, true) => !shader.color_instanced_pipelines.contains_key(&key),
                (GeometryKind::Texture, true) => !shader.texture_instanced_pipelines.contains_key(&key),
            }
        };
        if missing {
            let pipeline = {
                let shader = self.shader_cache.get(&shader_key).unwrap();
                let module = match (geometry, instanced) {
                    (GeometryKind::Color, false) => &shader.color_module,
                    (GeometryKind::Texture, false) => &shader.texture_module,
                    (GeometryKind::Color, true) => &shader.color_instanced_module,
                    (GeometryKind::Texture, true) => &shader.texture_instanced_module,
                };
                let layout = match geometry {
                    GeometryKind::Color => &shader.color_layout,
                    GeometryKind::Texture => &shader.texture_layout,
                };
                create_render_pipeline(
                    &self.device,
                    self.surface_format,
                    layout,
                    module,
                    geometry,
                    key,
                    instanced,
                    "lurek_fragment_main",
                )
            };
            let shader = self.shader_cache.get_mut(&shader_key).unwrap();
            match (geometry, instanced) {
                (GeometryKind::Color, false) => shader.color_pipelines.insert(key, pipeline),
                (GeometryKind::Texture, false) => shader.texture_pipelines.insert(key, pipeline),
                (GeometryKind::Color, true) => shader.color_instanced_pipelines.insert(key, pipeline),
                (GeometryKind::Texture, true) => shader.texture_instanced_pipelines.insert(key, pipeline),
            };
        }
        let shader = self.shader_cache.get(&shader_key).unwrap();
        match (geometry, instanced) {
            (GeometryKind::Color, false) => shader.color_pipelines.get(&key).unwrap(),
            (GeometryKind::Texture, false) => shader.texture_pipelines.get(&key).unwrap(),
            (GeometryKind::Color, true) => shader.color_instanced_pipelines.get(&key).unwrap(),
            (GeometryKind::Texture, true) => shader.texture_instanced_pipelines.get(&key).unwrap(),
        }
    }'''

content = content.replace(old_custom, new_custom)


# 4. Fix pipeline callers in `render_frame`
content = content.replace(
    'PipelineSelectionKey::Default { geometry, pipeline } => self.default_pipeline(geometry, pipeline),',
    'PipelineSelectionKey::Default { geometry, pipeline, instanced } => self.default_pipeline(geometry, pipeline, instanced),'
)
content = content.replace(
    'PipelineSelectionKey::Custom { shader, geometry, pipeline } => self.custom_pipeline(shader, geometry, pipeline),',
    'PipelineSelectionKey::Custom { shader, geometry, pipeline, instanced } => self.custom_pipeline(shader, geometry, pipeline, instanced),'
)

with open(renderer_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Pipeline updates completed")
