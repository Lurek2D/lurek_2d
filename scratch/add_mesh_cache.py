import os

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Add to GpuRenderer struct
if 'pub(crate) gpu_mesh_cache: GpuMeshCache' not in text:
    text = text.replace('    postfx_capture: HashMap<u64, crate::render::postfx_pipeline::PostFxTexture>,\n}', '    postfx_capture: HashMap<u64, crate::render::postfx_pipeline::PostFxTexture>,\n    pub(crate) gpu_mesh_cache: GpuMeshCache,\n    pub(crate) default_color_instanced_shader: wgpu::ShaderModule,\n    pub(crate) default_texture_instanced_shader: wgpu::ShaderModule,\n}')

# Add to GpuRenderer::new
if 'default_color_instanced_shader' not in text.split('fn new(')[1].split('GpuRenderer {')[0]:
    # We need to compile the instanced shaders
    inst_compile = '''
        let default_color_instanced_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("default_color_instanced_shader"),
            source: wgpu::ShaderSource::Wgsl(COLOR_INSTANCED_SHADER.into()),
        });
        
        let default_texture_instanced_shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("default_texture_instanced_shader"),
            source: wgpu::ShaderSource::Wgsl(TEXTURE_INSTANCED_SHADER.into()),
        });
        
        let gpu_mesh_cache = GpuMeshCache::new(&device);
    '''
    text = text.replace('let mut default_color_pipelines = HashMap::new();', inst_compile + '\n        let mut default_color_pipelines = HashMap::new();')

if 'default_color_instanced_shader,' not in text.split('fn new(')[1]:
    text = text.replace('postfx_capture: HashMap::new(),', 'postfx_capture: HashMap::new(),\n            gpu_mesh_cache,\n            default_color_instanced_shader,\n            default_texture_instanced_shader,')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Added GpuMeshCache and instanced shaders to GpuRenderer')
