import sys

# 1. Truncate gpu_pipeline.rs to remove trailing #[inline]
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "r", encoding="utf-8") as f:
    pipeline_lines = f.readlines()

# Truncate at line 428 (index 427)
pipeline_lines = pipeline_lines[:428]

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "w", encoding="utf-8") as f:
    f.write("".join(pipeline_lines))
print("gpu_pipeline.rs truncated to remove trailing attributes.")


# 2. Remove collect_shadow_edges from gpu_renderer.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "r", encoding="utf-8") as f:
    renderer_content = f.read()

# Let's find:
# pub(crate) fn collect_shadow_edges(
# ...
#     edges
# }
# and replace it with empty string
pattern_start = "pub(crate) fn collect_shadow_edges("
idx = renderer_content.find(pattern_start)
if idx != -1:
    # Find the matching closing brace. Since we know the function shape:
    # it ends with:
    #     edges
    # }
    end_pattern = "    edges\n}"
    idx_end = renderer_content.find(end_pattern, idx)
    if idx_end != -1:
        end_pos = idx_end + len(end_pattern)
        renderer_content = renderer_content[:idx] + renderer_content[end_pos:]
        print("collect_shadow_edges removed from gpu_renderer.rs.")

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs", "w", encoding="utf-8") as f:
    f.write(renderer_content)


# 3. Remove duplicate SlotMap from gpu_resources.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "r", encoding="utf-8") as f:
    res_content = f.read()

res_content = res_content.replace("use slotmap::SlotMap;\n", "", 1)

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "w", encoding="utf-8") as f:
    f.write(res_content)
print("gpu_resources.rs duplicate SlotMap import removed.")
