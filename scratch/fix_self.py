import os

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

idx = text.find('pub fn new')
idx_self = text.find('Self {', idx)
idx_end = text.find('}', idx_self)
self_block = text[idx_self:idx_end+1]

if 'gpu_mesh_cache' not in self_block:
    replacement = """
            gpu_mesh_cache: GpuMeshCache::new(),
            default_color_instanced_shader: device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("default_color_instanced"),
                source: wgpu::ShaderSource::Wgsl(COLOR_INSTANCED_SHADER.into()),
            }),
            default_texture_instanced_shader: device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("default_texture_instanced"),
                source: wgpu::ShaderSource::Wgsl(TEXTURE_INSTANCED_SHADER.into()),
            }),"""
    
    new_self_block = self_block.replace('Self {', 'Self {' + replacement)
    text = text[:idx_self] + new_self_block + text[idx_end+1:]
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print('Fixed Self {}')
else:
    print('gpu_mesh_cache already in Self {}')
