-- Golden test: render compare evidence output against golden samples.

local FILES = {
    "render_primitive_family_scene.png",
    "render_transform_hierarchy_scene.png",
    "render_scissor_nested_clip.png",
    "render_blend_alpha_scene.png",
    "render_stencil_portal_scene.png",
    "render_text_font_layout.png",
    "render_advanced_vector_scene.png",
    "render_canvas_composite_scene.png",
    "render_texture_quad_nineslice_scene.png",
    "render_spritebatch_grid_scene.png",
    "render_mesh_custom_geometry.png",
    "render_retained_shape_instances.png",
    "render_shader_uniform_scene.png",
    "render_layers_sort_group_scene.png",
    "render_obj_model_preview.png",
}

-- @describe golden: render evidence comparison
describe("golden: render evidence comparison", function()
    it("matches render baselines", function()
        for _, name in ipairs(FILES) do
            expect_golden_file_match(
                evidence_output_dir("render") .. name,
                "tests/artifacts/baselines/render/" .. name
            )
        end
    end)
end)

test_summary()
