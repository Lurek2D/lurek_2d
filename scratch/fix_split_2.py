import sys

# 1. Make LIGHT_SHADER and SHADOW_COMPUTE_SHADER pub(crate) in gpu_renderer.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "r", encoding="utf-8") as f:
    r_content = f.read()

r_content = r_content.replace("const LIGHT_SHADER: &str =", "pub(crate) const LIGHT_SHADER: &str =", 1)
r_content = r_content.replace("const SHADOW_COMPUTE_SHADER: &str =", "pub(crate) const SHADOW_COMPUTE_SHADER: &str =", 1)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "w", encoding="utf-8") as f:
    f.write(r_content)
print("gpu_renderer.rs shaders made pub(crate).")


# 2. Add imports to gpu_resources.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "r", encoding="utf-8") as f:
    res_content = f.read()

# Add ShaderKey to use crate::runtime::resource_keys::{TextureKey, FontKey, CanvasKey};
res_content = res_content.replace(
    "use crate::runtime::resource_keys::{TextureKey, FontKey, CanvasKey};",
    "use crate::runtime::resource_keys::{TextureKey, FontKey, CanvasKey, ShaderKey};\nuse crate::render::shader::Shader;",
    1
)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "w", encoding="utf-8") as f:
    f.write(res_content)
print("gpu_resources.rs imports added.")


# 3. Add imports to gpu_shadows.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shadows.rs", "r", encoding="utf-8") as f:
    sh_content = f.read()

# We need to import:
# - MAX_SHADOW_LIGHTS from gpu_light
# - LIGHT_SHADER, SHADOW_COMPUTE_SHADER from gpu_renderer
# - LightVertex, MAX_LIGHT_QUADS from gpu_types
# - Mat3 from crate::math
extra_imports = '''use crate::render::gpu_light::MAX_SHADOW_LIGHTS;
use crate::render::gpu_renderer::{LIGHT_SHADER, SHADOW_COMPUTE_SHADER};
use crate::render::gpu_types::{LightVertex, MAX_LIGHT_QUADS};
use crate::math::Mat3;
'''

sh_content = sh_content.replace(
    "use crate::render::gpu_types::{ShadowEdgeGpu, ShadowComputeParams, ShadowDispatchInput};",
    "use crate::render::gpu_types::{ShadowEdgeGpu, ShadowComputeParams, ShadowDispatchInput};\n" + extra_imports,
    1
)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shadows.rs", "w", encoding="utf-8") as f:
    f.write(sh_content)
print("gpu_shadows.rs imports added.")
