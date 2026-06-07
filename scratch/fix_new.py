import re

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# I will regex to remove the bad unclosed block.
# The block starts with `Self {` and ends with `}),` right before `let viewport_data = ViewportUniform {`
bad_top = """        Self {
            gpu_mesh_cache: GpuMeshCache::new(),
            default_color_instanced_shader: device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("default_color_instanced"),
                source: wgpu::ShaderSource::Wgsl(COLOR_INSTANCED_SHADER.into()),
            }),
            default_texture_instanced_shader: device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("default_texture_instanced"),
                source: wgpu::ShaderSource::Wgsl(TEXTURE_INSTANCED_SHADER.into()),
            }),"""

if bad_top in text:
    text = text.replace(bad_top, '')

idx_new = text.find('pub fn new(')
idx_return = text.find('GpuRenderer {', idx_new)

to_insert = """
            gpu_mesh_cache: GpuMeshCache::new(),
            default_color_instanced_shader: device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("default_color_instanced"),
                source: wgpu::ShaderSource::Wgsl(COLOR_INSTANCED_SHADER.into()),
            }),
            default_texture_instanced_shader: device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("default_texture_instanced"),
                source: wgpu::ShaderSource::Wgsl(TEXTURE_INSTANCED_SHADER.into()),
            }),"""

if 'gpu_mesh_cache: GpuMeshCache::new()' not in text[idx_return:idx_return+500]:
    text = text[:idx_return+13] + to_insert + text[idx_return+13:]

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Fixed GpuRenderer::new()')
