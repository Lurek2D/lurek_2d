import os

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Modify create_render_pipeline to take `instanced: bool` parameter
if 'pub(crate) fn create_render_pipeline' in text and 'instanced: bool' not in text:
    text = text.replace('pub(crate) fn create_render_pipeline(', 'pub(crate) fn create_render_pipeline(\n    device: &wgpu::Device,\n    layout: &wgpu::PipelineLayout,\n    color_format: wgpu::TextureFormat,\n    depth_format: Option<wgpu::TextureFormat>,\n    vertex_layouts: &[wgpu::VertexBufferLayout],\n    shader: &wgpu::ShaderModule,\n    fs_entry: &str,\n    instanced: bool,\n) -> wgpu::RenderPipeline {\n')

    # Wait, create_render_pipeline already has signature. Let's find it.

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Done')
