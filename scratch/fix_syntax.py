import re

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = re.sub(r'match geo\s+let attrs_color_norm', 'let attrs_color_norm', text, count=1)

bad_block = """            gpu_mesh_cache: GpuMeshCache::new(),
            default_color_instanced_shader: device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("default_color_instanced"),
                source: wgpu::ShaderSource::Wgsl(COLOR_INSTANCED_SHADER.into()),
            }),
            default_texture_instanced_shader: device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: Some("default_texture_instanced"),
                source: wgpu::ShaderSource::Wgsl(TEXTURE_INSTANCED_SHADER.into()),
            }),"""

text = text.replace(bad_block, '')

idx_new = text.find('pub fn new(')
idx_self = text.find('Self {', idx_new)

if text[idx_self-1:idx_self] == ' ':
    if '-> Self {' in text[idx_self-5:idx_self+6]:
        idx_self = text.find('Self {', idx_self + 6)

text = text[:idx_self] + 'Self {\n' + bad_block + text[idx_self+6:]

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Fixed syntax errors')
