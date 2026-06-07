import os

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shaders.rs'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

instanced_shaders = r'''
pub(crate) const COLOR_INSTANCED_SHADER: &str = r#"
pub(crate) struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) color:    vec4<f32>,
};

pub(crate) struct InstanceInput {
    @location(2) mat_col0: vec3<f32>,
    @location(3) mat_col1: vec3<f32>,
    @location(4) mat_col2: vec3<f32>,
    @location(5) color:    vec4<f32>,
};

pub(crate) struct ViewportUniform {
    matrix: mat4x4<f32>,
};
@group(0) @binding(0) var<uniform> viewport: ViewportUniform;

pub(crate) struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>,
};

@vertex
fn vs_main(model: VertexInput, instance: InstanceInput) -> VertexOutput {
    var out: VertexOutput;
    
    // Construct 3x3 transformation matrix
    let transform = mat3x3<f32>(instance.mat_col0, instance.mat_col1, instance.mat_col2);
    let local_pos = vec3<f32>(model.position, 1.0);
    let world_pos = transform * local_pos;
    
    out.clip_position = viewport.matrix * vec4<f32>(world_pos.xy, 0.0, 1.0);
    out.color = model.color * instance.color;
    return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    return in.color;
}
"#;

pub(crate) const TEXTURE_INSTANCED_SHADER: &str = r#"
pub(crate) struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) uv:       vec2<f32>,
    @location(2) color:    vec4<f32>,
};

pub(crate) struct InstanceInput {
    @location(3) mat_col0: vec3<f32>,
    @location(4) mat_col1: vec3<f32>,
    @location(5) mat_col2: vec3<f32>,
    @location(6) uv_rect:  vec4<f32>,
    @location(7) color:    vec4<f32>,
};

pub(crate) struct ViewportUniform {
    matrix: mat4x4<f32>,
};
@group(0) @binding(0) var<uniform> viewport: ViewportUniform;
@group(1) @binding(0) var t_diffuse: texture_2d<f32>;
@group(1) @binding(1) var s_diffuse: sampler;

pub(crate) struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) uv: vec2<f32>,
    @location(1) color: vec4<f32>,
};

@vertex
fn vs_main(model: VertexInput, instance: InstanceInput) -> VertexOutput {
    var out: VertexOutput;
    
    let transform = mat3x3<f32>(instance.mat_col0, instance.mat_col1, instance.mat_col2);
    let local_pos = vec3<f32>(model.position, 1.0);
    let world_pos = transform * local_pos;
    
    out.clip_position = viewport.matrix * vec4<f32>(world_pos.xy, 0.0, 1.0);
    
    // Remap UV to instance atlas rect
    let tex_x = instance.uv_rect.x + (model.uv.x * instance.uv_rect.z);
    let tex_y = instance.uv_rect.y + (model.uv.y * instance.uv_rect.w);
    out.uv = vec2<f32>(tex_x, tex_y);
    
    out.color = model.color * instance.color;
    return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    return textureSample(t_diffuse, s_diffuse, in.uv) * in.color;
}
"#;
'''

if 'COLOR_INSTANCED_SHADER' not in text:
    text += '\n' + instanced_shaders

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Added instanced shaders')
