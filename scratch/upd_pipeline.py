import os

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Add instanced to PipelineKey
if 'pub(crate) instanced: bool' not in text:
    text = text.replace('pub(crate) stencil_mode: StencilMode,\n}', 'pub(crate) stencil_mode: StencilMode,\n    pub(crate) instanced: bool,\n}')

# Now we need to modify create_render_pipeline to take instanced and change vertex layout
if 'instanced: bool' not in text.split('fn create_render_pipeline')[1]:
    text = text.replace('fn create_render_pipeline(\n    device: &wgpu::Device,\n    surface_format: wgpu::TextureFormat,\n    layout: &wgpu::PipelineLayout,\n    module: &wgpu::ShaderModule,\n    geometry: GeometryKind,\n    key: PipelineKey,\n    fragment_entry: &str,\n)', 'fn create_render_pipeline(\n    device: &wgpu::Device,\n    surface_format: wgpu::TextureFormat,\n    layout: &wgpu::PipelineLayout,\n    module: &wgpu::ShaderModule,\n    geometry: GeometryKind,\n    key: PipelineKey,\n    fragment_entry: &str,\n)')
    # Actually wait, `key` already has `instanced: bool`! So we can just use `key.instanced` inside `create_render_pipeline`!
    
    # We need to change vertex layout if `key.instanced` is true.
    # For Color Instanced:
    # 0 => Float32x2, 1 => Float32x4
    # Instance: 2=>Float32x3, 3=>Float32x3, 4=>Float32x3, 5=>Float32x4
    
    color_buffers_normal = '''buffers: &[wgpu::VertexBufferLayout {
                    array_stride: std::mem::size_of::<ColorVertex>() as wgpu::BufferAddress,
                    step_mode: wgpu::VertexStepMode::Vertex,
                    attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x4],
                }],'''
                
    color_buffers_instanced = '''buffers: if key.instanced {
                    &[
                        wgpu::VertexBufferLayout {
                            array_stride: std::mem::size_of::<ColorVertex>() as wgpu::BufferAddress,
                            step_mode: wgpu::VertexStepMode::Vertex,
                            attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x4],
                        },
                        wgpu::VertexBufferLayout {
                            array_stride: std::mem::size_of::<InstanceData>() as wgpu::BufferAddress,
                            step_mode: wgpu::VertexStepMode::Instance,
                            attributes: &wgpu::vertex_attr_array![2 => Float32x3, 3 => Float32x3, 4 => Float32x3, 5 => Float32x4],
                        }
                    ]
                } else {
                    &[wgpu::VertexBufferLayout {
                        array_stride: std::mem::size_of::<ColorVertex>() as wgpu::BufferAddress,
                        step_mode: wgpu::VertexStepMode::Vertex,
                        attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x4],
                    }]
                },'''

    texture_buffers_normal = '''buffers: &[wgpu::VertexBufferLayout {
                    array_stride: std::mem::size_of::<TexVertex>() as wgpu::BufferAddress,
                    step_mode: wgpu::VertexStepMode::Vertex,
                    attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x2, 2 => Float32x4, 3 => Float32],
                }],'''
                
    texture_buffers_instanced = '''buffers: if key.instanced {
                    &[
                        wgpu::VertexBufferLayout {
                            array_stride: std::mem::size_of::<TexVertex>() as wgpu::BufferAddress,
                            step_mode: wgpu::VertexStepMode::Vertex,
                            attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x2, 2 => Float32x4, 3 => Float32],
                        },
                        wgpu::VertexBufferLayout {
                            array_stride: std::mem::size_of::<InstanceData>() as wgpu::BufferAddress,
                            step_mode: wgpu::VertexStepMode::Instance,
                            attributes: &wgpu::vertex_attr_array![3 => Float32x3, 4 => Float32x3, 5 => Float32x3, 6 => Float32x4, 7 => Float32x4],
                        }
                    ]
                } else {
                    &[wgpu::VertexBufferLayout {
                        array_stride: std::mem::size_of::<TexVertex>() as wgpu::BufferAddress,
                        step_mode: wgpu::VertexStepMode::Vertex,
                        attributes: &wgpu::vertex_attr_array![0 => Float32x2, 1 => Float32x2, 2 => Float32x4, 3 => Float32],
                    }]
                },'''

    text = text.replace(color_buffers_normal, color_buffers_instanced)
    text = text.replace(texture_buffers_normal, texture_buffers_instanced)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated gpu_pipeline.rs')
