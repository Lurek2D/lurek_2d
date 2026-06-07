import sys

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "r", encoding="utf-8") as f:
    content = f.read()

import_line = "use crate::render::gpu_tess::color_write_mask_from_bits;\n"
content = content.replace(
    "use crate::render::gpu_shaders::ShaderUniformKind;",
    "use crate::render::gpu_shaders::ShaderUniformKind;\n" + import_line,
    1
)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "w", encoding="utf-8") as f:
    f.write(content)

print("gpu_pipeline.rs import added.")
