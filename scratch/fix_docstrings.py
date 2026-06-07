import sys

# 1. gpu_resources.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
# Find where the old docstring ends (it has 4 lines starting with //!)
# and replace it.
new_doc = """//! This file manages persistent GPU resource lifetimes, allocations, and buffer uploads.
//! Dynamic capacity adjustment handles growing vertex/index buffers under heavy draw-call counts.
//! Slotmap registration caches textures, fonts, and canvases synchronously for main render passes.
//! Resource pruning runs automatically between frames to release dead texture and canvas resources.
//! The allocator ensures buffers resize exponentially to minimize GPU-CPU synchronization stalls."""

content = new_doc + "\n" + "\n".join(lines[4:])
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_resources.rs", "w", encoding="utf-8") as f:
    f.write(content)
print("gpu_resources.rs docstring fixed.")


# 2. gpu_pipeline.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
new_doc = """//! This file manages the creation and caching of wgpu render pipeline objects to prevent redundant state changes.
//! Lookup behavior groups pipelines by geometry layout, blend mode, and stencil operation so matching draw calls can share execution state.
//! Fallback behavior selects default built-in shaders when custom overrides are absent from the requested pipeline key.
//! The caching mechanism ensures the engine pays the heavy pipeline compilation cost only once per unique rendering configuration.
//! Stencil operations and color channel write masks are mapped directly to native wgpu descriptors.
//! Blend states for alpha, additive, multiplicative, and replace modes are configured here."""

content = new_doc + "\n" + "\n".join(lines[4:])
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "w", encoding="utf-8") as f:
    f.write(content)
print("gpu_pipeline.rs docstring fixed.")


# 3. gpu_shadows.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shadows.rs", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
new_doc = """//! This file manages 1-D shadow map rendering, dynamic light lists, and compute dispatches.
//! Occluder geometry is gathered and transformed into a dedicated GPU-side edge storage buffer.
//! The shadow compute shader is dispatched per active light source to write distances into the atlas.
//! Viewport-space visibility checks cull light regions before any rendering commands are queued.
//! Compute pass layouts and bind groups are registered dynamically based on active lights.
//! Edge collection filters occluders by light mask and culls geometry outside the radius bounds."""

content = new_doc + "\n" + "\n".join(lines[4:])
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_shadows.rs", "w", encoding="utf-8") as f:
    f.write(content)
print("gpu_shadows.rs docstring fixed.")


# 4. gpu_tess.rs
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_tess.rs", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
new_doc = """//! This file tessellates 2D vector shapes, text glyphs, and sprite quads into triangle lists.
//! Stroke thick-lines are expanded to rectangular quads to solve native GPU line-width limitations.
//! Circle and ellipse vertex counts adapt to screen-space radii to prevent excessive vertex pressure.
//! Textured quad utilities pack position, UV coords, tints, and perspective-correct depth values.
//! Coordinate transformation applies 3x3 matrices to map local coordinates to viewport space.
//! Arc segment tessellation uses adaptive step sizes to preserve smooth visual curvature on hardware."""

content = new_doc + "\n" + "\n".join(lines[4:])
with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_tess.rs", "w", encoding="utf-8") as f:
    f.write(content)
print("gpu_tess.rs docstring fixed.")
