import sys

# 1. Fix type annotation in src/render/gpu_renderer.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "r", encoding="utf-8") as f:
    r_content = f.read()

old_map = ".map(|(binding, buffer)| wgpu::BindGroupEntry {"
new_map = ".map(|(binding, buffer): (usize, &wgpu::Buffer)| wgpu::BindGroupEntry {"
if old_map in r_content:
    r_content = r_content.replace(old_map, new_map, 1)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "w", encoding="utf-8") as f:
    f.write(r_content)
print("Type annotation in gpu_renderer.rs checked/fixed.")


# 2. Make all methods in gpu_tess.rs, gpu_resources.rs, gpu_shadows.rs pub(crate)
def make_methods_pub_crate(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    
    new_lines = []
    for line in lines:
        if line.startswith("    fn ") and not line.strip().startswith("pub"):
            line = line.replace("    fn ", "    pub(crate) fn ", 1)
        elif line.startswith("    unsafe fn ") and not line.strip().startswith("pub"):
            line = line.replace("    unsafe fn ", "    pub(crate) unsafe fn ", 1)
        new_lines.append(line)
        
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("".join(new_lines))
    print(f"Visibility of methods in {file_path} updated to pub(crate).")

make_methods_pub_crate(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_tess.rs")
make_methods_pub_crate(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs")
make_methods_pub_crate(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shadows.rs")


# 3. Add missing imports to gpu_shadows.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shadows.rs", "r", encoding="utf-8") as f:
    s_content = f.read()

shadow_imports = '''use crate::render::gpu_pipeline::{blend_state_for, depth_stencil_state, GpuStencilMode};
use crate::render::renderer::BlendMode;
'''
if "use crate::render::gpu_pipeline::{" not in s_content:
    s_content = s_content.replace(
        "use crate::render::gpu_types::{ShadowEdgeGpu, ShadowComputeParams, ShadowDispatchInput};",
        "use crate::render::gpu_types::{ShadowEdgeGpu, ShadowComputeParams, ShadowDispatchInput};\n" + shadow_imports,
        1
    )

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shadows.rs", "w", encoding="utf-8") as f:
    f.write(s_content)
print("Imports in gpu_shadows.rs checked/updated.")
