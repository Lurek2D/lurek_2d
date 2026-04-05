import sys

app_path = "src/engine/app.rs"
rend_path = "src/graphics/gpu_renderer.rs"

with open(app_path, "r", encoding="utf-8") as f:
    app_code = f.read()

app_code = app_code.replace(
    "&mut fonts,",
    "&mut fonts,\n            &state.borrow().light_world,"
)

with open(app_path, "w", encoding="utf-8") as f:
    f.write(app_code)


with open(rend_path, "r", encoding="utf-8") as f:
    rend_code = f.read()

rend_code = rend_code.replace(
    "fonts: &mut SlotMap<FontKey, crate::graphics::Font>,",
    "fonts: &mut SlotMap<FontKey, crate::graphics::Font>,\n        light_world: &crate::light::light_world::LightWorld,"
)

light_code = """
        // ====== LIGHT RENDERING PASS ======
        if light_world.enabled {
            let _pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                label: Some("light_pass"),
                color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                    view: &view,
                    resolve_target: None,
                    ops: wgpu::Operations {
                        load: wgpu::LoadOp::Load,
                        store: wgpu::StoreOp::Store,
                    },
                })],
                depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                    view: &self.screen_stencil_target.as_ref().unwrap().view,
                    depth_ops: None,
                    stencil_ops: Some(wgpu::Operations {
                        load: wgpu::LoadOp::Load,
                        store: wgpu::StoreOp::Store,
                    }),
                }),
                ..Default::default()
            });
        }
        // ==================================
"""

rend_code = rend_code.replace(
    "        let pending_readback = if capture_screenshot {",
    light_code + "\n        let pending_readback = if capture_screenshot {"
)

with open(rend_path, "w", encoding="utf-8") as f:
    f.write(rend_code)

print("Applied!")
