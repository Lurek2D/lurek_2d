import os
import re

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
    print('Fixed Self {}')

idx_encode = text.find('fn encode_commands')
idx_begin = text.find('begin_render_pass', idx_encode)
pass_decl = text[max(0, idx_begin-30):idx_begin]
print('Pass declaration:', pass_decl)

if 'mut pass' in pass_decl:
    pass_var = 'pass'
elif 'mut rpass' in pass_decl:
    pass_var = 'rpass'
elif 'mut render_pass' in pass_decl:
    pass_var = 'render_pass'
else:
    pass_var = 'rpass'

print('Pass var is:', pass_var)

if pass_var != 'pass':
    arm_start = text.find('&renderer::RenderCommand::DrawStaticGeometry {')
    arm_end = text.find('&renderer::RenderCommand::SetScissor', arm_start)
    if arm_end == -1:
        arm_end = len(text)
    arm_code = text[arm_start:arm_end]
    new_arm_code = arm_code.replace('pass.', pass_var + '.')
    text = text[:arm_start] + new_arm_code + text[arm_end:]
    print(f'Replaced pass. with {pass_var}.')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
