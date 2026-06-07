import os

renderer_path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs'
with open(renderer_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_struct = '''    default_color_shader: wgpu::ShaderModule,
    /// Compiled WGSL module for the built-in textured shader.
    default_texture_shader: wgpu::ShaderModule,
    /// Pipeline layout for the default color shader.
    default_color_layout: wgpu::PipelineLayout,
    /// Pipeline layout for the default textured shader.
    default_texture_layout: wgpu::PipelineLayout,
    /// Cached built-in color pipelines keyed by blend/stencil state.
    default_color_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
    /// Cached built-in texture pipelines keyed by blend/stencil state.
    default_texture_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,'''

new_struct = '''    default_color_shader: wgpu::ShaderModule,
    /// Compiled WGSL module for the built-in textured shader.
    default_texture_shader: wgpu::ShaderModule,
    /// Compiled WGSL module for the built-in instanced color shader.
    default_color_instanced_shader: wgpu::ShaderModule,
    /// Compiled WGSL module for the built-in instanced textured shader.
    default_texture_instanced_shader: wgpu::ShaderModule,
    /// Pipeline layout for the default color shader.
    default_color_layout: wgpu::PipelineLayout,
    /// Pipeline layout for the default textured shader.
    default_texture_layout: wgpu::PipelineLayout,
    /// Cached built-in color pipelines keyed by blend/stencil state.
    default_color_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
    /// Cached built-in texture pipelines keyed by blend/stencil state.
    default_texture_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
    /// Cached built-in instanced color pipelines.
    default_color_instanced_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,
    /// Cached built-in instanced texture pipelines.
    default_texture_instanced_pipelines: HashMap<PipelineKey, wgpu::RenderPipeline>,'''

content = content.replace(old_struct, new_struct)

old_init = '''        let texture_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("texture_shader"),
            source: wgpu::ShaderSource::Wgsl(TEXTURE_SHADER.into()),
        });'''

new_init = '''        let texture_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("texture_shader"),
            source: wgpu::ShaderSource::Wgsl(TEXTURE_SHADER.into()),
        });
        let color_instanced_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("color_instanced_shader"),
            source: wgpu::ShaderSource::Wgsl(crate::render::gpu_shaders::COLOR_SHADER_INSTANCED.into()),
        });
        let texture_instanced_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("texture_instanced_shader"),
            source: wgpu::ShaderSource::Wgsl(crate::render::gpu_shaders::TEXTURE_SHADER_INSTANCED.into()),
        });'''

content = content.replace(old_init, new_init)

old_ret = '''            default_color_shader: color_shader,
            default_texture_shader: texture_shader,
            default_color_layout: color_layout,
            default_texture_layout: texture_layout,
            default_color_pipelines: HashMap::new(),
            default_texture_pipelines: HashMap::new(),'''

new_ret = '''            default_color_shader: color_shader,
            default_texture_shader: texture_shader,
            default_color_instanced_shader: color_instanced_shader,
            default_texture_instanced_shader: texture_instanced_shader,
            default_color_layout: color_layout,
            default_texture_layout: texture_layout,
            default_color_pipelines: HashMap::new(),
            default_texture_pipelines: HashMap::new(),
            default_color_instanced_pipelines: HashMap::new(),
            default_texture_instanced_pipelines: HashMap::new(),'''

content = content.replace(old_ret, new_ret)

with open(renderer_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated GpuRenderer struct and initialization')
