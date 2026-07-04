//! File: tests/rust/unit/raycaster_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::color::Color;
use lurek2d::math::Vec2;
use lurek2d::physics::{Body, BodyType, World};
use lurek2d::raycaster::*;
use lurek2d::render::renderer::RenderCommand;
use std::cell::RefCell;
use std::rc::Rc;

// Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬ visibility Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬

mod visibility_tests {
    use super::*;

    #[test]
    fn field_of_view_produces_polygon() {
        let segs = vec![
            Segment {
                x1: -5.0,
                y1: 5.0,
                x2: 5.0,
                y2: 5.0,
            },
            Segment {
                x1: 5.0,
                y1: 5.0,
                x2: 5.0,
                y2: -5.0,
            },
            Segment {
                x1: 5.0,
                y1: -5.0,
                x2: -5.0,
                y2: -5.0,
            },
            Segment {
                x1: -5.0,
                y1: -5.0,
                x2: -5.0,
                y2: 5.0,
            },
        ];
        let poly = field_of_view(0.0, 0.0, &segs, 20.0);
        assert!(poly.len() >= 8); // at least 4 points (8 floats)
    }
}

mod segment_tests {
    use super::*;

    fn make_segments() -> Vec<Segment> {
        vec![
            Segment {
                x1: 5.0,
                y1: -2.0,
                x2: 5.0,
                y2: 2.0,
            }, // vertical wall at x=5
        ]
    }

    #[test]
    fn cast_ray_hits_segment() {
        let segs = make_segments();
        let result = cast_ray_2d(0.0, 0.0, 1.0, 0.0, 100.0, &segs);
        assert!(result.is_some());
        let (hx, hy, idx) = result.unwrap();
        assert!((hx - 5.0).abs() < 1e-3);
        assert!((hy - 0.0).abs() < 1e-3);
        assert_eq!(idx, 0);
    }

    #[test]
    fn cast_ray_misses_segment() {
        let segs = make_segments();
        // Ray going away from wall
        let result = cast_ray_2d(0.0, 0.0, -1.0, 0.0, 100.0, &segs);
        assert!(result.is_none());
    }
}

mod scene_tests {
    use super::*;
    use lurek2d::raycaster::scene::{CeilingQuad, FloorQuad, WallQuad};
    use lurek2d::render::mesh::{Mesh, MeshDrawMode, MeshVertex};
    use lurek2d::runtime::resource_keys::TextureKey;
    use slotmap::KeyData;

    fn unit_corners(x: f32, y: f32, w: f32, h: f32) -> [Vec2; 4] {
        [
            Vec2::new(x, y),
            Vec2::new(x + w, y),
            Vec2::new(x + w, y + h),
            Vec2::new(x, y + h),
        ]
    }

    fn unit_uvs() -> [Vec2; 4] {
        [
            Vec2::new(0.0, 0.0),
            Vec2::new(1.0, 0.0),
            Vec2::new(1.0, 1.0),
            Vec2::new(0.0, 1.0),
        ]
    }

    fn triangle_mesh(ax: f32, ay: f32, bx: f32, by: f32, cx: f32, cy: f32) -> Mesh {
        Mesh::from_vertices(
            vec![
                MeshVertex {
                    x: ax,
                    y: ay,
                    u: 0.0,
                    v: 0.0,
                    r: 1.0,
                    g: 1.0,
                    b: 1.0,
                    a: 1.0,
                },
                MeshVertex {
                    x: bx,
                    y: by,
                    u: 1.0,
                    v: 0.0,
                    r: 1.0,
                    g: 1.0,
                    b: 1.0,
                    a: 1.0,
                },
                MeshVertex {
                    x: cx,
                    y: cy,
                    u: 0.5,
                    v: 1.0,
                    r: 1.0,
                    g: 1.0,
                    b: 1.0,
                    a: 1.0,
                },
            ],
            MeshDrawMode::Triangles,
        )
    }

    #[test]
    fn empty_scene_has_zero_quads() {
        let scene = RaycasterScene::new(800.0, 600.0);
        assert_eq!(scene.quad_count(), 0);
        assert!(scene.is_empty());
    }

    #[test]
    fn scene_counts_all_quad_types() {
        let mut scene = RaycasterScene::new(800.0, 600.0);
        scene.walls.push(WallQuad {
            corners: unit_corners(0.0, 0.0, 1.0, 100.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 2.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });
        scene.floors.push(FloorQuad {
            corners: unit_corners(0.0, 100.0, 1.0, 50.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 2.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            level_index: 0,
            material: None,
        });
        scene.ceilings.push(CeilingQuad {
            corners: unit_corners(0.0, 0.0, 1.0, 50.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 2.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            level_index: 0,
            material: None,
        });
        assert_eq!(scene.quad_count(), 3);
        assert!(!scene.is_empty());
    }

    #[test]
    fn pick_entity_prefers_model_triangle_depth_over_instance_depth() {
        let mut scene = RaycasterScene::new(64.0, 48.0);
        let overlapping = triangle_mesh(16.0, 8.0, 32.0, 8.0, 24.0, 32.0);
        scene.models.push(ModelMesh {
            mesh: overlapping.clone(),
            depth: 2.0,
            triangle_depths: vec![6.0],
            entity_id: Some(101),
            level_index: 0,
            world_x: 2.0,
            world_y: 2.0,
            attrs: std::collections::HashMap::new(),
        });
        scene.models.push(ModelMesh {
            mesh: overlapping,
            depth: 4.0,
            triangle_depths: vec![3.0],
            entity_id: Some(202),
            level_index: 0,
            world_x: 3.0,
            world_y: 2.0,
            attrs: std::collections::HashMap::new(),
        });

        let pick = scene
            .pick_entity(24.0, 16.0)
            .expect("expected overlapping model pick");
        assert_eq!(pick.entity_id, Some(202));
        assert!((pick.distance - 3.0).abs() < 1e-5);
    }

    #[test]
    fn pick_entity_skips_transparent_sprite_pixels() {
        let mut scene = RaycasterScene::new(64.0, 48.0);
        let near_texture = TextureKey::from(KeyData::from_ffi(31));
        let far_texture = TextureKey::from(KeyData::from_ffi(32));
        let corners = unit_corners(16.0, 8.0, 20.0, 20.0);
        let uvs = unit_uvs();

        scene.sprites.push(BillboardSprite {
            corners,
            uvs,
            texture_key: near_texture,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 2.0,
            entity_id: Some(111),
            level_index: 0,
            world_x: 2.0,
            world_y: 2.0,
            attrs: std::collections::HashMap::new(),
        });
        scene.sprites.push(BillboardSprite {
            corners,
            uvs,
            texture_key: far_texture,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 4.0,
            entity_id: Some(222),
            level_index: 0,
            world_x: 3.0,
            world_y: 2.0,
            attrs: std::collections::HashMap::new(),
        });

        let opaque_pick = scene.pick_entity(24.0, 18.0).expect("expected opaque pick");
        assert_eq!(opaque_pick.entity_id, Some(111));

        let masked_pick = scene
            .pick_entity_with_sprite_alpha_test(24.0, 18.0, &|texture_key, _, _| {
                texture_key != near_texture
            })
            .expect("expected transparent sprite to be skipped");
        assert_eq!(masked_pick.entity_id, Some(222));
        assert!((masked_pick.distance - 4.0).abs() < 1e-5);
    }
}

mod scene_adapter_tests {
    use super::*;

    #[test]
    fn body_transform_applies_rotation_to_local_offset() {
        let mut world = World::new(0.0, 0.0);
        let mut body = Body::new(10.0, 20.0, 1.0, 1.0, BodyType::Dynamic);
        body.angle = std::f32::consts::FRAC_PI_2;
        let body_id = world.add_body(body).0;
        let world = Rc::new(RefCell::new(world));

        let transform = SceneTransform::body(world, body_id, 1.0, 0.0, 0.25);
        let resolved = transform
            .resolve()
            .expect("expected live body transform to resolve");

        assert!((resolved.x - 10.0).abs() < 1e-5);
        assert!((resolved.y - 21.0).abs() < 1e-5);
        assert!((resolved.angle - (std::f32::consts::FRAC_PI_2 + 0.25)).abs() < 1e-5);
    }
}

mod render_tests {
    use super::*;
    use lurek2d::raycaster::scene::{
        CeilingQuad, FloorQuad, RaycasterMaterial, RaycasterMaterialFrameLayout, RaycasterParticle,
        WallQuad,
    };
    use lurek2d::render::mesh::{Mesh, MeshDrawMode, MeshVertex};
    use lurek2d::render::renderer::ParticleRenderShape;
    use lurek2d::render::BlendMode;
    use lurek2d::runtime::resource_keys::{ShaderKey, TextureKey};
    use slotmap::KeyData;

    fn make_corners(x: f32, y: f32, w: f32, h: f32) -> [Vec2; 4] {
        [
            Vec2::new(x, y),
            Vec2::new(x + w, y),
            Vec2::new(x + w, y + h),
            Vec2::new(x, y + h),
        ]
    }

    fn unit_uvs() -> [Vec2; 4] {
        [
            Vec2::new(0.0, 0.0),
            Vec2::new(1.0, 0.0),
            Vec2::new(1.0, 1.0),
            Vec2::new(0.0, 1.0),
        ]
    }

    fn sample_model_mesh() -> Mesh {
        Mesh::from_vertices(
            vec![
                MeshVertex {
                    x: 40.0,
                    y: 20.0,
                    u: 0.0,
                    v: 0.0,
                    r: 1.0,
                    g: 1.0,
                    b: 1.0,
                    a: 1.0,
                },
                MeshVertex {
                    x: 56.0,
                    y: 20.0,
                    u: 1.0,
                    v: 0.0,
                    r: 1.0,
                    g: 1.0,
                    b: 1.0,
                    a: 1.0,
                },
                MeshVertex {
                    x: 48.0,
                    y: 36.0,
                    u: 0.5,
                    v: 1.0,
                    r: 1.0,
                    g: 1.0,
                    b: 1.0,
                    a: 1.0,
                },
            ],
            MeshDrawMode::Triangles,
        )
    }

    fn sample_material(shader_key: Option<ShaderKey>, blend_mode: BlendMode) -> RaycasterMaterial {
        RaycasterMaterial {
            material_id: 7,
            texture_key: None,
            shader_key,
            blend_mode,
            uv_scroll: [0.25, 0.0],
            uv_scale: [1.0, 1.0],
            uv_offset: [0.0, 0.0],
            frame_count: 4,
            frame_rate: 2.0,
            frame_layout: RaycasterMaterialFrameLayout::Horizontal,
            tint: [1.0, 0.8, 0.6, 1.0],
        }
    }

    #[test]
    fn raycaster_scene_empty_gives_empty_commands() {
        // Default scene has no quads Ă„â€šĂ‹ÂÄ‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ä‚ËĂ˘â€šÂ¬ÄąÄ„ only SetBlendMode is emitted
        let scene = RaycasterScene::default();
        let cmds = scene.generate_render_commands();
        assert!(
            cmds.is_empty(),
            "Empty scene should have no geometry commands"
        );
    }

    #[test]
    fn empty_scene_produces_minimal_commands() {
        let scene = RaycasterScene::new(320.0, 200.0);
        let cmds = scene.generate_render_commands();
        assert!(cmds.is_empty());
    }

    #[test]
    fn raycaster_scene_with_wall_gives_draw_textured_quad() {
        let tk = TextureKey::from(KeyData::from_ffi(1));

        let mut scene = RaycasterScene::new(320.0, 200.0);
        scene.walls.push(WallQuad {
            corners: make_corners(10.0, 50.0, 1.0, 100.0),
            uvs: unit_uvs(),
            texture_key: Some(tk),
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 3.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });
        let cmds = scene.generate_render_commands();
        assert!(
            cmds.iter()
                .any(|c| matches!(c, RenderCommand::DrawTexturedQuad { .. })),
            "Expected a DrawTexturedQuad command"
        );
    }

    #[test]
    fn wall_quad_untextured_emits_set_color_and_rectangle() {
        let mut scene = RaycasterScene::new(320.0, 200.0);
        scene.walls.push(WallQuad {
            corners: make_corners(10.0, 50.0, 32.0, 100.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [0.8, 0.6, 0.4, 1.0],
            depth: 3.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });
        let cmds = scene.generate_render_commands();
        assert_eq!(cmds.len(), 1);
        assert!(matches!(cmds[0], RenderCommand::DrawColoredPolygon { .. }));
    }

    #[test]
    fn floor_emits_draw_command() {
        let mut scene = RaycasterScene::new(320.0, 200.0);
        scene.floors.push(FloorQuad {
            corners: make_corners(0.0, 100.0, 32.0, 100.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 3.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            level_index: 0,
            material: None,
        });
        let cmds = scene.generate_render_commands();
        assert!(!cmds.is_empty());
    }

    #[test]
    fn ceiling_drawn_before_walls() {
        let mut scene = RaycasterScene::new(320.0, 200.0);
        scene.ceilings.push(CeilingQuad {
            corners: make_corners(0.0, 0.0, 32.0, 50.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 3.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            level_index: 0,
            material: None,
        });
        scene.walls.push(WallQuad {
            corners: make_corners(0.0, 50.0, 32.0, 100.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 3.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });
        let cmds = scene.generate_render_commands();
        // Find first Rectangle after SetBlendMode Ă„â€šĂ‹ÂÄ‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ä‚ËĂ˘â€šÂ¬ÄąÄ„ should be the ceiling
        let first_poly_idx = cmds
            .iter()
            .position(|c| matches!(c, RenderCommand::DrawColoredPolygon { .. }))
            .unwrap();
        if let RenderCommand::DrawColoredPolygon { vertices, .. } = &cmds[first_poly_idx] {
            assert!(
                vertices[1].abs() < 1e-5,
                "First polygon should be ceiling (y=0)"
            );
        }
    }

    #[test]
    fn wall_commands_are_depth_sorted_far_to_near() {
        let mut scene = RaycasterScene::new(320.0, 200.0);
        scene.walls.push(WallQuad {
            corners: make_corners(0.0, 50.0, 64.0, 100.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [1.0, 0.0, 0.0, 1.0],
            depth: 2.0,
            corner_w: [2.0, 2.0, 2.0, 2.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });
        scene.walls.push(WallQuad {
            corners: make_corners(0.0, 50.0, 64.0, 100.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [0.0, 0.0, 1.0, 1.0],
            depth: 8.0,
            corner_w: [8.0, 8.0, 8.0, 8.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });

        let cmds = scene.generate_render_commands();
        let wall_colors: Vec<[f32; 4]> = cmds
            .iter()
            .filter_map(|cmd| match cmd {
                RenderCommand::DrawColoredPolygon { colors, .. } => colors.first().copied(),
                _ => None,
            })
            .collect();

        assert_eq!(wall_colors.len(), 2);
        assert_eq!(wall_colors[0], [0.0, 0.0, 1.0, 1.0]);
        assert_eq!(wall_colors[1], [1.0, 0.0, 0.0, 1.0]);
    }

    #[test]
    fn floor_commands_are_depth_sorted_far_to_near() {
        let mut scene = RaycasterScene::new(320.0, 200.0);
        scene.floors.push(FloorQuad {
            corners: make_corners(0.0, 100.0, 64.0, 100.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [1.0, 0.0, 0.0, 1.0],
            depth: 2.0,
            corner_w: [2.0, 2.0, 2.0, 2.0],
            level_index: 0,
            material: None,
        });
        scene.floors.push(FloorQuad {
            corners: make_corners(0.0, 100.0, 64.0, 100.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [0.0, 0.0, 1.0, 1.0],
            depth: 8.0,
            corner_w: [8.0, 8.0, 8.0, 8.0],
            level_index: 0,
            material: None,
        });

        let cmds = scene.generate_render_commands();
        let floor_colors: Vec<[f32; 4]> = cmds
            .iter()
            .filter_map(|cmd| match cmd {
                RenderCommand::DrawColoredPolygon { colors, .. } => colors.first().copied(),
                _ => None,
            })
            .collect();

        assert_eq!(floor_colors.len(), 2);
        assert_eq!(floor_colors[0], [0.0, 0.0, 1.0, 1.0]);
        assert_eq!(floor_colors[1], [1.0, 0.0, 0.0, 1.0]);
    }

    #[test]
    fn sprites_are_depth_sorted_between_walls() {
        let sprite_tex = TextureKey::from(KeyData::from_ffi(23));
        let mut scene = RaycasterScene::new(320.0, 200.0);
        scene.walls.push(WallQuad {
            corners: make_corners(0.0, 50.0, 64.0, 100.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [1.0, 0.0, 0.0, 1.0],
            depth: 2.0,
            corner_w: [2.0, 2.0, 2.0, 2.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });
        scene.walls.push(WallQuad {
            corners: make_corners(0.0, 50.0, 64.0, 100.0),
            uvs: unit_uvs(),
            texture_key: None,
            light: [0.0, 0.0, 1.0, 1.0],
            depth: 8.0,
            corner_w: [8.0, 8.0, 8.0, 8.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });
        scene.sprites.push(BillboardSprite {
            corners: make_corners(16.0, 40.0, 24.0, 32.0),
            uvs: unit_uvs(),
            texture_key: sprite_tex,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 5.0,
            entity_id: Some(77),
            level_index: 0,
            world_x: 5.0,
            world_y: 2.0,
            attrs: std::collections::HashMap::new(),
        });

        let cmds = scene.generate_render_commands();
        let draw_order: Vec<&'static str> = cmds
            .iter()
            .filter_map(|cmd| match cmd {
                RenderCommand::DrawColoredPolygon { colors, .. } => {
                    if colors.first() == Some(&[0.0, 0.0, 1.0, 1.0]) {
                        Some("far_wall")
                    } else if colors.first() == Some(&[1.0, 0.0, 0.0, 1.0]) {
                        Some("near_wall")
                    } else {
                        None
                    }
                }
                RenderCommand::DrawTexturedQuad { texture_key, .. }
                    if *texture_key == sprite_tex =>
                {
                    Some("sprite")
                }
                _ => None,
            })
            .collect();

        assert_eq!(draw_order, vec!["far_wall", "sprite", "near_wall"]);
    }

    #[test]
    fn models_emit_transient_mesh_commands_in_depth_order_with_sprites() {
        let far_tex = TextureKey::from(KeyData::from_ffi(21));
        let near_tex = TextureKey::from(KeyData::from_ffi(22));

        let mut scene = RaycasterScene::new(160.0, 100.0);
        scene.sprites.push(BillboardSprite {
            corners: make_corners(8.0, 20.0, 16.0, 32.0),
            uvs: unit_uvs(),
            texture_key: near_tex,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 2.0,
            entity_id: Some(1),
            level_index: 0,
            world_x: 2.0,
            world_y: 2.0,
            attrs: std::collections::HashMap::new(),
        });
        scene.sprites.push(BillboardSprite {
            corners: make_corners(96.0, 20.0, 16.0, 32.0),
            uvs: unit_uvs(),
            texture_key: far_tex,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 6.0,
            entity_id: Some(2),
            level_index: 0,
            world_x: 6.0,
            world_y: 2.0,
            attrs: std::collections::HashMap::new(),
        });
        scene.models.push(ModelMesh {
            mesh: sample_model_mesh(),
            depth: 4.0,
            triangle_depths: vec![4.0],
            entity_id: Some(3),
            level_index: 0,
            world_x: 4.0,
            world_y: 2.0,
            attrs: std::collections::HashMap::new(),
        });

        let cmds = scene.generate_render_commands();
        assert_eq!(cmds.len(), 3);
        match &cmds[0] {
            RenderCommand::DrawTexturedQuad { texture_key, .. } => {
                assert_eq!(*texture_key, far_tex)
            }
            other => panic!("expected far sprite quad, got {other:?}"),
        }
        assert!(matches!(cmds[1], RenderCommand::DrawMeshTransient { .. }));
        match &cmds[2] {
            RenderCommand::DrawTexturedQuad { texture_key, .. } => {
                assert_eq!(*texture_key, near_tex)
            }
            other => panic!("expected near sprite quad, got {other:?}"),
        }
    }

    #[test]
    fn wall_material_emits_shader_and_blend_state() {
        let texture = TextureKey::from(KeyData::from_ffi(31));
        let shader = ShaderKey::from(KeyData::from_ffi(32));
        let mut scene = RaycasterScene::new(160.0, 100.0);
        scene.walls.push(WallQuad {
            corners: make_corners(20.0, 16.0, 24.0, 48.0),
            uvs: unit_uvs(),
            texture_key: Some(texture),
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 2.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            cell_value: 9,
            level_index: 0,
            material: Some(sample_material(Some(shader), BlendMode::Add)),
        });

        let cmds = scene.generate_render_commands();
        assert!(matches!(
            cmds[0],
            RenderCommand::SetBlendMode(BlendMode::Add)
        ));
        assert!(matches!(cmds[1], RenderCommand::SetShader(Some(key)) if key == shader));
        assert!(
            matches!(cmds[2], RenderCommand::DrawTexturedQuad { texture_key, .. } if texture_key == texture)
        );
    }

    #[test]
    fn shader_background_and_depth_fog_overlay_emit_fullscreen_commands() {
        let texture = TextureKey::from(KeyData::from_ffi(41));
        let shader = ShaderKey::from(KeyData::from_ffi(42));
        let overlay_shader = ShaderKey::from(KeyData::from_ffi(43));
        let mut scene = RaycasterScene::new(120.0, 80.0);
        scene.time_seconds = 1.0;
        scene.depth_columns = vec![1.0, 3.0, 6.0, 9.0];
        scene.background = Some(RaycasterBackground::Shader {
            material: RaycasterMaterial {
                texture_key: Some(texture),
                shader_key: Some(shader),
                ..sample_material(Some(shader), BlendMode::Alpha)
            },
        });
        scene.overlays.push(RaycasterOverlayEffect::DepthFog {
            color: [0.2, 0.3, 0.5, 0.75],
            density: 0.8,
            near: 1.0,
            far: 10.0,
        });
        scene.overlays.push(RaycasterOverlayEffect::Shader {
            material: RaycasterMaterial {
                texture_key: Some(texture),
                shader_key: Some(overlay_shader),
                ..sample_material(Some(overlay_shader), BlendMode::Screen)
            },
        });

        let cmds = scene.generate_render_commands();
        assert!(cmds
            .iter()
            .any(|cmd| matches!(cmd, RenderCommand::SetShader(Some(key)) if *key == shader)));
        assert!(cmds.iter().any(
            |cmd| matches!(cmd, RenderCommand::SetShader(Some(key)) if *key == overlay_shader)
        ));
        assert!(
            cmds.iter()
                .filter(|cmd| matches!(cmd, RenderCommand::Rectangle { .. }))
                .count()
                >= 1
        );
    }

    #[test]
    fn particles_emit_particle_system_command() {
        let texture = TextureKey::from(KeyData::from_ffi(51));
        let mut scene = RaycasterScene::new(160.0, 100.0);
        scene.particles.push(RaycasterParticle {
            x: 80.0,
            y: 50.0,
            rotation: 0.1,
            size: 18.0,
            color: [1.0, 0.5, 0.2, 0.8],
            shape: ParticleRenderShape::Circle,
            texture_key: Some(texture),
            quad: None,
            quad_tex_dims: None,
            local_x: 0.0,
            local_y: 0.0,
            velocity_x: 0.0,
            velocity_y: 0.2,
            normalized_age: 0.25,
            lifetime: 1.0,
            seed: 5,
            depth: 3.0,
            shader_key: None,
            blend_mode: BlendMode::Alpha,
            level_index: 0,
            emitter_id: 1,
        });

        let cmds = scene.generate_render_commands();
        assert!(cmds
            .iter()
            .any(|cmd| matches!(cmd, RenderCommand::DrawParticleSystem { .. })));
    }
}

mod lighting_tests {
    use super::*;

    #[test]
    fn compute_lighting_ambient_only() {
        let result = compute_lighting(0.0, 0.0, 0.3, &[], &|_, _| false);
        assert!((result[0] - 0.3).abs() < 1e-5);
        assert!((result[1] - 0.3).abs() < 1e-5);
        assert!((result[2] - 0.3).abs() < 1e-5);
    }

    #[test]
    fn compute_lighting_point_light_at_center() {
        let lights = vec![PointLight {
            x: 5.0,
            y: 5.0,
            level_index: None,
            radius: 10.0,
            intensity: 16.0,
            color: [1.0, 1.0, 1.0],
        }];
        let result = compute_lighting(5.0, 5.0, 0.0, &lights, &|_, _| false);
        // At distance 0, attenuation = 1.0 * 1.0 = 1.0
        assert!((result[0] - 1.0).abs() < 1e-5);
    }

    #[test]
    fn compute_lighting_point_light_out_of_range() {
        let lights = vec![PointLight {
            x: 0.0,
            y: 0.0,
            level_index: None,
            radius: 5.0,
            intensity: 1.0,
            color: [1.0, 1.0, 1.0],
        }];
        let result = compute_lighting(10.0, 10.0, 0.1, &lights, &|_, _| false);
        assert!((result[0] - 0.1).abs() < 1e-5);
    }

    #[test]
    fn apply_lit_shade_scales_channels() {
        let result = apply_lit_shade(0.5, [1.0, 0.8, 0.6]);
        assert!((result[0] - 0.5).abs() < 1e-5);
        assert!((result[1] - 0.4).abs() < 1e-5);
        assert!((result[2] - 0.3).abs() < 1e-5);
    }
}

mod heightmap_tests {
    use super::*;

    #[test]
    fn heightmap_out_of_bounds_uses_default_planes() {
        let hm = HeightMap::new(4, 4);
        assert!((hm.floor_at(10, 10)).abs() < 1e-5);
        assert!((hm.ceiling_at(10, 10) - 1.0).abs() < 1e-5);
    }

    #[test]
    fn heightmap_set_rect_updates_floor_band() {
        let mut hm = HeightMap::new(8, 8);
        hm.set_floor_rect(2, 2, 3, 3, 0.25);
        assert!((hm.floor_at(3, 3) - 0.25).abs() < 1e-5);
        assert!((hm.floor_at(0, 0)).abs() < 1e-5);
    }
}

mod draw_tests {
    use super::*;
    use lurek2d::render::mesh::{Mesh, MeshDrawMode, MeshVertex};
    use lurek2d::runtime::resource_keys::TextureKey;
    use slotmap::Key;

    #[test]
    fn draw_to_image_empty_scene_returns_correct_dimensions() {
        let scene = RaycasterScene::default();
        let img = scene.draw_to_image(320, 200);
        assert_eq!(img.width(), 320);
        assert_eq!(img.height(), 200);
    }

    #[test]
    fn draw_to_image_nonzero_size() {
        let scene = RaycasterScene::default();
        let img = scene.draw_to_image(64, 48);
        assert_eq!(img.width(), 64);
        assert_eq!(img.height(), 48);
    }

    #[test]
    fn draw_to_image_samples_textured_wall_quads() {
        let texture_key = TextureKey::null();
        let mut scene = RaycasterScene::new(16.0, 8.0);
        scene.walls.push(WallQuad {
            corners: [
                Vec2::new(0.0, 0.0),
                Vec2::new(16.0, 0.0),
                Vec2::new(16.0, 8.0),
                Vec2::new(0.0, 8.0),
            ],
            uvs: [
                Vec2::new(0.0, 0.0),
                Vec2::new(1.0, 0.0),
                Vec2::new(1.0, 1.0),
                Vec2::new(0.0, 1.0),
            ],
            texture_key: Some(texture_key),
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 1.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });

        let img = scene.draw_to_image_with_textures(
            16,
            8,
            Some(&|_, u, _| {
                if u < 0.5 {
                    Some((220, 40, 20, 255))
                } else {
                    Some((20, 180, 70, 255))
                }
            }),
        );

        let left = img.get_pixel(2, 4).expect("left textured pixel");
        let right = img.get_pixel(13, 4).expect("right textured pixel");
        assert!(left.0 > left.1, "left half should sample red texels");
        assert!(right.1 > right.0, "right half should sample green texels");
    }

    #[test]
    fn draw_to_image_clips_slanted_wall_to_quad_shape() {
        let mut scene = RaycasterScene::new(20.0, 20.0);
        scene.walls.push(WallQuad {
            corners: [
                Vec2::new(4.0, 2.0),
                Vec2::new(16.0, 6.0),
                Vec2::new(14.0, 18.0),
                Vec2::new(2.0, 14.0),
            ],
            uvs: [
                Vec2::new(0.0, 0.0),
                Vec2::new(1.0, 0.0),
                Vec2::new(1.0, 1.0),
                Vec2::new(0.0, 1.0),
            ],
            texture_key: None,
            light: [1.0, 0.0, 0.0, 1.0],
            depth: 1.0,
            corner_w: [1.0, 1.0, 1.0, 1.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });

        let img = scene.draw_to_image(20, 20);
        let inside = img.get_pixel(8, 8).expect("inside slanted quad");
        let outside = img
            .get_pixel(3, 3)
            .expect("outside slanted quad but inside bbox");

        assert!(inside.0 > 200, "quad interior should be filled");
        assert_eq!(outside.0, 0, "quad rasterizer must not fill its whole bbox");
    }

    #[test]
    fn draw_to_image_keeps_far_sprite_behind_near_wall() {
        let sprite_key = TextureKey::null();
        let mut scene = RaycasterScene::new(20.0, 20.0);
        scene.walls.push(WallQuad {
            corners: [
                Vec2::new(6.0, 2.0),
                Vec2::new(14.0, 2.0),
                Vec2::new(14.0, 18.0),
                Vec2::new(6.0, 18.0),
            ],
            uvs: [
                Vec2::new(0.0, 0.0),
                Vec2::new(1.0, 0.0),
                Vec2::new(1.0, 1.0),
                Vec2::new(0.0, 1.0),
            ],
            texture_key: None,
            light: [0.0, 0.0, 1.0, 1.0],
            depth: 2.0,
            corner_w: [2.0, 2.0, 2.0, 2.0],
            cell_value: 1,
            level_index: 0,
            material: None,
        });
        scene.sprites.push(BillboardSprite {
            corners: [
                Vec2::new(4.0, 4.0),
                Vec2::new(16.0, 4.0),
                Vec2::new(16.0, 16.0),
                Vec2::new(4.0, 16.0),
            ],
            uvs: [
                Vec2::new(0.0, 0.0),
                Vec2::new(1.0, 0.0),
                Vec2::new(1.0, 1.0),
                Vec2::new(0.0, 1.0),
            ],
            texture_key: sprite_key,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 4.0,
            entity_id: None,
            level_index: 0,
            world_x: 4.0,
            world_y: 4.0,
            attrs: std::collections::HashMap::new(),
        });

        let img =
            scene.draw_to_image_with_textures(20, 20, Some(&|_, _, _| Some((255, 0, 0, 255))));
        let covered = img
            .get_pixel(10, 10)
            .expect("overlapping wall/sprite pixel");

        assert!(
            covered.2 > 200 && covered.0 < 20,
            "near wall depth must occlude the farther sprite"
        );
    }

    #[test]
    fn draw_to_image_rasterizes_model_meshes() {
        let mesh = Mesh::from_vertices(
            vec![
                MeshVertex {
                    x: 12.0,
                    y: 10.0,
                    u: 0.0,
                    v: 0.0,
                    r: 1.0,
                    g: 1.0,
                    b: 1.0,
                    a: 1.0,
                },
                MeshVertex {
                    x: 28.0,
                    y: 10.0,
                    u: 1.0,
                    v: 0.0,
                    r: 1.0,
                    g: 1.0,
                    b: 1.0,
                    a: 1.0,
                },
                MeshVertex {
                    x: 20.0,
                    y: 26.0,
                    u: 0.5,
                    v: 1.0,
                    r: 1.0,
                    g: 1.0,
                    b: 1.0,
                    a: 1.0,
                },
            ],
            MeshDrawMode::Triangles,
        );
        let mut scene = RaycasterScene::new(64.0, 48.0);
        scene.models.push(ModelMesh {
            mesh,
            depth: 3.0,
            triangle_depths: vec![3.0],
            entity_id: Some(7),
            level_index: 0,
            world_x: 3.0,
            world_y: 2.0,
            attrs: std::collections::HashMap::new(),
        });

        let img = scene.draw_to_image(64, 48);
        let pixel = img.get_pixel(20, 15).expect("pixel inside model triangle");
        assert!(pixel.3 > 0, "model triangle should paint a visible pixel");
    }
}

mod doors_tests {
    use super::*;

    #[test]
    fn get_door_at_returns_none_when_missing() {
        let mgr = DoorManager::new();
        assert!(mgr.get_door_at(0, 0).is_none());
    }

    #[test]
    fn door_wall_feature_becomes_non_blocking_when_open() {
        let mut rc = Raycaster2D::new(4, 4);
        rc.set_cell(1, 1, 1);
        rc.set_wall_feature(1, 1, WallFeature::door(DoorDirection::Horizontal, 1.0, 1.0));
        assert!(!rc.is_blocked(1, 1));
    }

    #[test]
    fn sync_doors_applies_open_amount_and_clears_removed_entries() {
        let mut rc = Raycaster2D::new(6, 3);
        rc.set_cell(2, 1, 2);

        let mut doors = DoorManager::new();
        let id = doors.add_door(2, 1, DoorDirection::Vertical, 1.0);
        rc.sync_doors(&doors, 0.8);

        let feature = rc.wall_feature(2, 1).expect("door feature synced");
        match feature.kind {
            WallFeatureKind::Door {
                direction,
                open_amount,
            } => {
                assert_eq!(direction, DoorDirection::Vertical);
                assert!((open_amount - 0.0).abs() < 1e-5);
            }
            other => panic!("expected door feature, got {:?}", other),
        }
        assert!(rc.is_blocked(2, 1));

        doors.open_door(id);
        doors.update(1.0);
        rc.sync_doors(&doors, 0.8);
        assert!(!rc.is_blocked(2, 1));

        let empty = DoorManager::new();
        rc.sync_doors(&empty, 0.8);
        assert!(rc.wall_feature(2, 1).is_none());
        assert!(
            rc.is_blocked(2, 1),
            "base wall should remain after door sync clears"
        );
    }
}

mod sprite_manager_tests {
    use super::*;

    #[test]
    fn add_directional_selects_front_texture_for_front_view() {
        let mut sprites = SpriteManager::new();
        sprites.add_directional(
            2.0,
            0.0,
            "front",
            "right",
            "back",
            "left",
            std::f32::consts::PI,
            1.0,
        );

        let sorted = sprites.sort_by_distance(0.0, 0.0);
        let sprite = sorted[0];
        let textures = sprite.directional_textures.as_ref().expect("directional");
        let (texture, variant) = textures.select_for_viewer(0.0, 0.0, sprite.x, sprite.y);
        assert_eq!(texture, "front");
        assert_eq!(variant, DirectionalSpriteVariant::Front);
    }

    #[test]
    fn set_facing_can_flip_to_back_variant() {
        let mut sprites = SpriteManager::new();
        let id = sprites.add_directional(
            2.0,
            0.0,
            "front",
            "right",
            "back",
            "left",
            std::f32::consts::PI,
            1.0,
        );
        sprites.set_facing(id, 0.0);

        let sorted = sprites.sort_by_distance(0.0, 0.0);
        let sprite = sorted[0];
        let textures = sprite.directional_textures.as_ref().expect("directional");
        let (texture, variant) = textures.select_for_viewer(0.0, 0.0, sprite.x, sprite.y);
        assert_eq!(texture, "back");
        assert_eq!(variant, DirectionalSpriteVariant::Back);
    }

    #[test]
    fn set_directional_textures_replaces_front_bitmap() {
        let mut sprites = SpriteManager::new();
        let id = sprites.add(2.0, 0.0, "old", 1.0);
        sprites.set_directional_textures(
            id,
            "front2",
            "right2",
            "back2",
            "left2",
            Some(std::f32::consts::PI),
        );

        let sorted = sprites.sort_by_distance(0.0, 0.0);
        let sprite = sorted[0];
        let textures = sprite.directional_textures.as_ref().expect("directional");
        let (texture, variant) = textures.select_for_viewer(0.0, 0.0, sprite.x, sprite.y);
        assert_eq!(texture, "front2");
        assert_eq!(variant, DirectionalSpriteVariant::Front);
    }
}

mod depth_buffer_tests {
    use super::*;

    #[test]
    fn new_buffer_starts_with_max_depth() {
        let buf = DepthBuffer::new(320);
        assert_eq!(buf.width(), 320);
        assert_eq!(buf.get(0), f32::MAX);
    }

    #[test]
    fn set_and_get_round_trips_depth() {
        let mut buf = DepthBuffer::new(10);
        buf.set(5, 3.5);
        assert!((buf.get(5) - 3.5).abs() < 1e-5);
    }

    #[test]
    fn is_visible_rejects_equal_or_farther_depth() {
        let mut buf = DepthBuffer::new(10);
        buf.set(3, 5.0);
        assert!(buf.is_visible(3, 4.0));
        assert!(!buf.is_visible(3, 6.0));
        assert!(!buf.is_visible(3, 5.0));
    }

    #[test]
    fn clear_resets_cells_to_max_depth() {
        let mut buf = DepthBuffer::new(10);
        buf.set(0, 1.0);
        buf.clear();
        assert_eq!(buf.get(0), f32::MAX);
    }

    #[test]
    fn out_of_bounds_reads_return_max_depth() {
        let buf = DepthBuffer::new(5);
        assert_eq!(buf.get(100), f32::MAX);
    }
}

mod column_batch_tests {
    use super::*;

    fn assert_f32_eq(actual: f32, expected: f32) {
        assert!(
            (actual - expected).abs() < 1e-6,
            "expected {expected}, got {actual}"
        );
    }

    #[test]
    fn new_creates_correct_count() {
        let batch = ColumnBatch::new(10, 320.0, 200.0);
        assert_eq!(batch.get_column_count(), 10);
        assert_f32_eq(batch.get_screen_width(), 320.0);
        assert_f32_eq(batch.get_screen_height(), 200.0);
    }

    #[test]
    fn column_data_defaults() {
        let cd = ColumnData::default();
        assert_f32_eq(cd.tex_u, 0.0);
        assert_f32_eq(cd.shade, 1.0);
        assert_eq!(cd.cell_val, 0);
        assert_f32_eq(cd.depth, 0.0);
    }

    #[test]
    fn set_and_get_column() {
        let mut batch = ColumnBatch::new(4, 320.0, 200.0);
        batch.set_column(1, 0.5, 10.0, 190.0, 0.8, 3);
        let col = batch.get_column(1).unwrap();
        assert_f32_eq(col.tex_u, 0.5);
        assert_f32_eq(col.start, 10.0);
        assert_f32_eq(col.end, 190.0);
        assert_f32_eq(col.shade, 0.8);
        assert_eq!(col.cell_val, 3);
    }

    #[test]
    fn get_column_oob_returns_none() {
        let batch = ColumnBatch::new(2, 320.0, 200.0);
        assert!(batch.get_column(5).is_none());
    }

    #[test]
    fn depth_buffer_length() {
        let batch = ColumnBatch::new(8, 320.0, 200.0);
        assert_eq!(batch.get_depth_buffer().len(), 8);
    }

    #[test]
    fn update_from_ray_data_sets_columns() {
        let mut batch = ColumnBatch::new(2, 320.0, 200.0);
        // 5 floats per ray: distance, cellValue, side, texU, hit
        let rays = vec![
            2.0, 1.0, 0.0, 0.25, 1.0, // ray 0
            4.0, 2.0, 1.0, 0.75, 1.0, // ray 1
        ];
        batch.update_from_ray_data(&rays, 1.0, Some(10.0));
        let c0 = batch.get_column(0).unwrap();
        assert_eq!(c0.cell_val, 1);
        assert_f32_eq(c0.tex_u, 0.25);
        assert!(c0.depth > 0.0);
    }
}

mod build_scene_tests {
    use super::*;
    use lurek2d::runtime::resource_keys::TextureKey;
    use slotmap::KeyData;

    fn default_params() -> SceneBuildParams {
        SceneBuildParams {
            player_x: 5.0,
            player_y: 5.0,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            ray_count: 10,
            max_distance: 20.0,
            screen_width: 320.0,
            screen_height: 200.0,
            ambient_light: 0.3,
            global_light_color: Color::WHITE,
            global_light_intensity: 1.0,
            sun_angle: None,
            roofed_ambient_factor: 0.2,
            shade_distance: 15.0,
            floor_color: Color::new(0.2, 0.2, 0.2, 1.0),
            ceiling_color: Color::new(0.1, 0.1, 0.15, 1.0),
            camera_height: 2.0 / 3.0,
            horizon_offset: 0.0,
            background: None,
            overlays: Vec::new(),
            time_seconds: 0.0,
        }
    }

    #[test]
    fn empty_grid_produces_only_floor_ceiling() {
        let rc = Raycaster2D::new(10, 10);
        let params = default_params();
        let scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );

        assert!(scene.walls.is_empty(), "No walls in empty grid");
        assert!(!scene.floors.is_empty(), "Floor quads should exist");
        assert!(!scene.ceilings.is_empty(), "Ceiling quads should exist");
    }

    #[test]
    fn transparent_ceiling_color_leaves_untextured_sky_open() {
        let rc = Raycaster2D::new(10, 10);
        let mut params = default_params();
        params.ceiling_color = Color::new(0.1, 0.1, 0.15, 0.0);

        let open_scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );
        assert!(!open_scene.floors.is_empty(), "Floor quads should remain");
        assert!(
            open_scene.ceilings.is_empty(),
            "Untextured transparent ceilings should not cover caller-drawn sky"
        );

        let roof_tex = TextureKey::from(KeyData::from_ffi(71));
        let roof_scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| Some(roof_tex),
            &|_, _| None,
        );
        assert!(
            !roof_scene.ceilings.is_empty(),
            "Textured roof cells should still render with ceiling_a=0"
        );
    }

    #[test]
    fn wall_produces_wall_quads() {
        let mut rc = Raycaster2D::new(10, 10);
        // Place a wall directly in front of the player
        rc.set_cell(7, 5, 1);
        let params = default_params();
        let scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );

        assert!(!scene.walls.is_empty(), "Should have wall quads");
        for wall in &scene.walls {
            assert!(wall.depth > 0.0, "Wall depth should be positive");
            assert!(
                wall.uvs[0].x >= 0.0 && wall.uvs[0].x <= 1.0,
                "wall u0 should be in [0,1]"
            );
            assert!(
                wall.uvs[1].x >= 0.0 && wall.uvs[1].x <= 1.0,
                "wall u1 should be in [0,1]"
            );
            assert!(
                (wall.uvs[1].x - wall.uvs[0].x).abs() > 0.0,
                "wall UV span should not be degenerate"
            );
            // corners[3].y - corners[0].y = height
            let wall_h = wall.corners[3].y - wall.corners[0].y;
            assert!(wall_h > 0.0, "Wall height should be positive");
        }
    }

    #[test]
    fn sprites_sorted_back_to_front() {
        let rc = Raycaster2D::new(20, 20);
        let params = SceneBuildParams {
            player_x: 10.0,
            player_y: 10.0,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            ray_count: 10,
            max_distance: 20.0,
            screen_width: 320.0,
            screen_height: 200.0,
            ambient_light: 0.3,
            global_light_color: Color::WHITE,
            global_light_intensity: 1.0,
            sun_angle: None,
            roofed_ambient_factor: 0.2,
            shade_distance: 15.0,
            floor_color: Color::BLACK,
            ceiling_color: Color::BLACK,
            camera_height: 2.0 / 3.0,
            horizon_offset: 0.0,
            background: None,
            overlays: Vec::new(),
            time_seconds: 0.0,
        };

        let tk = TextureKey::from(KeyData::from_ffi(1));

        let sprites = vec![
            WorldSprite {
                entity_id: None,
                level_index: 0,
                world_x: 12.0,
                world_y: 10.0,
                texture_key: tk,
                directional_textures: None,
                size: 1.0,
                attrs: std::collections::HashMap::new(),
            },
            WorldSprite {
                entity_id: None,
                level_index: 0,
                world_x: 15.0,
                world_y: 10.0,
                texture_key: tk,
                directional_textures: None,
                size: 1.0,
                attrs: std::collections::HashMap::new(),
            },
        ];

        let scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &sprites,
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );
        if scene.sprites.len() >= 2 {
            assert!(
                scene.sprites[0].depth >= scene.sprites[1].depth,
                "Sprites should be sorted back-to-front"
            );
        }
    }

    #[test]
    fn directional_sprite_selects_texture_from_view_angle() {
        let rc = Raycaster2D::new(20, 20);
        let params = SceneBuildParams {
            player_x: 10.0,
            player_y: 10.0,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            ray_count: 10,
            max_distance: 20.0,
            screen_width: 320.0,
            screen_height: 200.0,
            ambient_light: 0.3,
            global_light_color: Color::WHITE,
            global_light_intensity: 1.0,
            sun_angle: None,
            roofed_ambient_factor: 0.2,
            shade_distance: 15.0,
            floor_color: Color::BLACK,
            ceiling_color: Color::BLACK,
            camera_height: 2.0 / 3.0,
            horizon_offset: 0.0,
            background: None,
            overlays: Vec::new(),
            time_seconds: 0.0,
        };

        let front = TextureKey::from(KeyData::from_ffi(11));
        let right = TextureKey::from(KeyData::from_ffi(12));
        let back = TextureKey::from(KeyData::from_ffi(13));
        let left = TextureKey::from(KeyData::from_ffi(14));

        let front_view = vec![WorldSprite {
            entity_id: None,
            level_index: 0,
            world_x: 12.0,
            world_y: 10.0,
            texture_key: front,
            directional_textures: Some(DirectionalSpriteTextures {
                front,
                right,
                back,
                left,
                facing_angle: std::f32::consts::PI,
            }),
            size: 1.0,
            attrs: std::collections::HashMap::new(),
        }];
        let right_view = vec![WorldSprite {
            entity_id: None,
            level_index: 0,
            world_x: 12.0,
            world_y: 10.0,
            texture_key: front,
            directional_textures: Some(DirectionalSpriteTextures {
                front,
                right,
                back,
                left,
                facing_angle: std::f32::consts::FRAC_PI_2,
            }),
            size: 1.0,
            attrs: std::collections::HashMap::new(),
        }];
        let back_view = vec![WorldSprite {
            entity_id: None,
            level_index: 0,
            world_x: 12.0,
            world_y: 10.0,
            texture_key: front,
            directional_textures: Some(DirectionalSpriteTextures {
                front,
                right,
                back,
                left,
                facing_angle: 0.0,
            }),
            size: 1.0,
            attrs: std::collections::HashMap::new(),
        }];

        let front_scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &front_view,
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );
        let right_scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &right_view,
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );
        let back_scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &back_view,
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );

        assert_eq!(front_scene.sprites[0].texture_key, front);
        assert_eq!(right_scene.sprites[0].texture_key, right);
        assert_eq!(back_scene.sprites[0].texture_key, back);
    }

    #[test]
    fn per_polygon_lighting_applied() {
        let mut rc = Raycaster2D::new(10, 10);
        rc.set_cell(7, 5, 1);

        let params = default_params();
        let lights = vec![PointLight {
            x: 6.0,
            y: 5.0,
            level_index: None,
            radius: 5.0,
            intensity: 1.0,
            color: [1.0, 0.5, 0.0],
        }];

        let scene = RaycasterScene::build(
            &rc,
            &params,
            &lights,
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );
        if let Some(wall) = scene.walls.first() {
            // With an orange light nearby, red channel should be higher than blue
            assert!(wall.light[0] > 0.0, "Wall should receive some light");
        }
    }

    #[test]
    fn pick_screen_hits_front_wall_at_screen_center() {
        let mut rc = Raycaster2D::new(8, 8);
        rc.set_cell(4, 2, 1);

        let params = ScreenPickParams {
            player_x: 1.5,
            player_y: 2.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            screen_width: 320.0,
            screen_height: 200.0,
            camera_height: 2.0 / 3.0,
            horizon_offset: 0.0,
            max_distance: 20.0,
        };

        let hit = rc.pick_screen(&params, 160.0, 100.0).expect("center pick");
        assert_eq!(hit.surface, PickSurface::Wall);
        assert_eq!((hit.grid_x, hit.grid_y), (4, 2));
        assert_eq!(hit.cell_value, 1);
        assert_eq!(hit.wall_side, Some(0));
    }

    #[test]
    fn pick_screen_resolves_floor_and_ceiling_planes() {
        let rc = Raycaster2D::new(16, 16);
        let params = ScreenPickParams {
            player_x: 8.0,
            player_y: 8.0,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            screen_width: 320.0,
            screen_height: 200.0,
            camera_height: 2.0 / 3.0,
            horizon_offset: 0.0,
            max_distance: 20.0,
        };

        let floor_hit = rc.pick_screen(&params, 160.0, 190.0).expect("floor pick");
        assert_eq!(floor_hit.surface, PickSurface::Floor);
        assert!(floor_hit.grid_x >= 8);
        assert_eq!(floor_hit.wall_side, None);

        let ceiling_hit = rc.pick_screen(&params, 160.0, 10.0).expect("ceiling pick");
        assert_eq!(ceiling_hit.surface, PickSurface::Ceiling);
        assert!(ceiling_hit.grid_x >= 8);
        assert_eq!(ceiling_hit.wall_side, None);
    }

    #[test]
    fn multilevel_pick_screen_returns_active_level_floor_when_surface_is_closed() {
        let lower = RaycasterLevel::new(4, 4);
        let mut upper = RaycasterLevel::new(4, 4);
        upper.floor_offset = 1.0;
        upper.ceiling_height = 2.0;

        let mut grid = MultiLevelGrid::new();
        grid.add_level(lower);
        grid.add_level(upper);
        grid.set_active_level(1);

        let params = ScreenPickParams {
            player_x: 1.5,
            player_y: 1.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            screen_width: 320.0,
            screen_height: 200.0,
            camera_height: 0.5,
            horizon_offset: 0.0,
            max_distance: 20.0,
        };

        let hit = grid
            .pick_screen(&params, 160.0, 190.0)
            .expect("upper floor pick");
        assert_eq!(hit.level_index, 1);
        assert_eq!(hit.surface, PickSurface::Floor);
        assert_eq!((hit.grid_x, hit.grid_y), (3, 1));
    }

    #[test]
    fn multilevel_pick_screen_descends_through_open_floor_and_ceiling_holes() {
        let mut lower = RaycasterLevel::new(8, 8);
        lower.set_ceiling_hole(3, 1, true);
        let mut upper = RaycasterLevel::new(8, 8);
        upper.floor_offset = 1.0;
        upper.ceiling_height = 2.0;
        upper.set_floor_hole(3, 1, true);

        let mut grid = MultiLevelGrid::new();
        grid.add_level(lower);
        grid.add_level(upper);
        grid.set_active_level(1);

        let params = ScreenPickParams {
            player_x: 1.5,
            player_y: 1.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            screen_width: 320.0,
            screen_height: 200.0,
            camera_height: 0.5,
            horizon_offset: 0.0,
            max_distance: 20.0,
        };

        let hit = grid
            .pick_screen(&params, 160.0, 190.0)
            .expect("lower floor pick through shaft");
        assert_eq!(hit.level_index, 0);
        assert_eq!(hit.surface, PickSurface::Floor);
        assert_eq!((hit.grid_x, hit.grid_y), (6, 1));
    }

    #[test]
    fn multilevel_pick_screen_reports_wall_level() {
        let lower = RaycasterLevel::new(8, 8);
        let mut upper = RaycasterLevel::new(8, 8);
        upper.floor_offset = 1.0;
        upper.ceiling_height = 2.0;
        upper.set_wall(4, 2, 1);

        let mut grid = MultiLevelGrid::new();
        grid.add_level(lower);
        grid.add_level(upper);
        grid.set_active_level(1);

        let params = ScreenPickParams {
            player_x: 1.5,
            player_y: 2.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            screen_width: 320.0,
            screen_height: 200.0,
            camera_height: 0.5,
            horizon_offset: 0.0,
            max_distance: 20.0,
        };

        let hit = grid
            .pick_screen(&params, 160.0, 100.0)
            .expect("upper wall pick");
        assert_eq!(hit.level_index, 1);
        assert_eq!(hit.surface, PickSurface::Wall);
        assert_eq!((hit.grid_x, hit.grid_y), (4, 2));
        assert_eq!(hit.cell_value, 1);
    }

    #[test]
    fn build_multilevel_reuses_cache_but_invalidates_after_level_mutation() {
        let mut level = RaycasterLevel::new(8, 8);
        level.floor_offset = 1.0;
        level.ceiling_height = 2.0;

        let mut grid = MultiLevelGrid::new();
        grid.add_level(RaycasterLevel::new(8, 8));
        grid.add_level(level);
        grid.set_active_level(1);

        let params = SceneBuildParams {
            player_x: 1.5,
            player_y: 2.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            ray_count: 32,
            max_distance: 20.0,
            screen_width: 320.0,
            screen_height: 200.0,
            ambient_light: 0.3,
            global_light_color: Color::WHITE,
            global_light_intensity: 1.0,
            sun_angle: None,
            roofed_ambient_factor: 0.2,
            shade_distance: 15.0,
            floor_color: Color::new(0.2, 0.2, 0.2, 1.0),
            ceiling_color: Color::new(0.1, 0.1, 0.15, 1.0),
            camera_height: 0.5,
            horizon_offset: 0.0,
            background: None,
            overlays: Vec::new(),
            time_seconds: 0.0,
        };

        let baseline = RaycasterScene::build_multilevel(
            &grid,
            &params,
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );
        assert_eq!(baseline.walls.len(), 0);

        grid.get_active_mut()
            .expect("active level")
            .set_wall(4, 2, 1);

        let updated = RaycasterScene::build_multilevel(
            &grid,
            &params,
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );
        assert!(!updated.walls.is_empty());
    }

    #[test]
    fn global_light_tint_modulates_wall_light() {
        let mut rc = Raycaster2D::new(10, 10);
        rc.set_cell(7, 5, 1);

        let mut neutral = default_params();
        neutral.ambient_light = 1.0;
        neutral.shade_distance = 100.0;

        let neutral_scene = RaycasterScene::build(
            &rc,
            &neutral,
            &[],
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );

        let mut tinted = neutral.clone();
        tinted.global_light_color = Color::new(1.0, 0.5, 0.25, 1.0);
        tinted.global_light_intensity = 0.8;

        let tinted_scene = RaycasterScene::build(
            &rc,
            &tinted,
            &[],
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );

        let neutral_wall = neutral_scene.walls.first().expect("neutral wall");
        let tinted_wall = tinted_scene.walls.first().expect("tinted wall");
        assert!(tinted_wall.light[0] <= neutral_wall.light[0]);
        assert!(tinted_wall.light[1] < neutral_wall.light[1]);
        assert!(tinted_wall.light[2] < neutral_wall.light[2]);
    }

    #[test]
    fn directional_sun_lights_exposed_floor_more_than_shadowed_floor() {
        let mut rc = Raycaster2D::new(6, 3);
        rc.set_cell(3, 1, 1);

        let shadowed_tex = TextureKey::from(KeyData::from_ffi(451));
        let exposed_tex = TextureKey::from(KeyData::from_ffi(452));
        let mut params = default_params();
        params.player_x = 1.5;
        params.player_y = 1.5;
        params.player_angle = 0.0;
        params.ambient_light = 0.3;
        params.global_light_color = Color::WHITE;
        params.global_light_intensity = 1.0;
        params.sun_angle = Some(0.0);
        params.shade_distance = 100.0;

        let scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &[],
            &|_| None,
            &|x, y| match (x, y) {
                (2, 1) => Some(shadowed_tex),
                (4, 1) => Some(exposed_tex),
                _ => None,
            },
            &|_, _| None,
            &|_, _| None,
        );

        let shadowed_floor = scene
            .floors
            .iter()
            .find(|quad| quad.texture_key == Some(shadowed_tex))
            .expect("shadowed floor");
        let exposed_floor = scene
            .floors
            .iter()
            .find(|quad| quad.texture_key == Some(exposed_tex))
            .expect("exposed floor");

        assert!(exposed_floor.light[0] > shadowed_floor.light[0]);
        assert!(exposed_floor.light[1] > shadowed_floor.light[1]);
        assert!(exposed_floor.light[2] > shadowed_floor.light[2]);
    }

    #[test]
    fn build_multilevel_omits_ceiling_quad_when_hole_is_open() {
        let mut closed_grid = MultiLevelGrid::new();
        let closed_level = RaycasterLevel::new(1, 1);
        closed_grid.add_level(closed_level);
        closed_grid.set_active_level(0);

        let mut open_grid = MultiLevelGrid::new();
        let mut open_level = RaycasterLevel::new(1, 1);
        open_level.set_ceiling_hole(0, 0, true);
        open_grid.add_level(open_level);
        open_grid.set_active_level(0);

        let params = SceneBuildParams {
            player_x: 0.5,
            player_y: 0.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            ray_count: 16,
            max_distance: 8.0,
            screen_width: 320.0,
            screen_height: 200.0,
            ambient_light: 0.3,
            global_light_color: Color::WHITE,
            global_light_intensity: 1.0,
            sun_angle: None,
            roofed_ambient_factor: 0.2,
            shade_distance: 15.0,
            floor_color: Color::new(0.2, 0.2, 0.2, 1.0),
            ceiling_color: Color::new(0.1, 0.1, 0.15, 1.0),
            camera_height: 2.0 / 3.0,
            horizon_offset: 0.0,
            background: None,
            overlays: Vec::new(),
            time_seconds: 0.0,
        };
        let closed_scene = RaycasterScene::build_multilevel(
            &closed_grid,
            &params,
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );
        let open_scene = RaycasterScene::build_multilevel(
            &open_grid,
            &params,
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );

        assert_eq!(closed_scene.ceilings.len(), 1);
        assert_eq!(open_scene.ceilings.len(), 0);
    }

    #[test]
    fn build_multilevel_closed_ceiling_darkens_floor_without_ceiling_texture() {
        let mut closed_grid = MultiLevelGrid::new();
        closed_grid.add_level(RaycasterLevel::new(1, 1));
        closed_grid.set_active_level(0);

        let mut open_grid = MultiLevelGrid::new();
        let mut open_level = RaycasterLevel::new(1, 1);
        open_level.set_ceiling_hole(0, 0, true);
        open_grid.add_level(open_level);
        open_grid.set_active_level(0);

        let params = SceneBuildParams {
            player_x: 0.5,
            player_y: 0.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            ray_count: 16,
            max_distance: 8.0,
            screen_width: 320.0,
            screen_height: 200.0,
            ambient_light: 1.0,
            global_light_color: Color::WHITE,
            global_light_intensity: 1.0,
            sun_angle: None,
            roofed_ambient_factor: 0.25,
            shade_distance: 100.0,
            floor_color: Color::new(1.0, 1.0, 1.0, 1.0),
            ceiling_color: Color::new(1.0, 1.0, 1.0, 1.0),
            camera_height: 2.0 / 3.0,
            horizon_offset: 0.0,
            background: None,
            overlays: Vec::new(),
            time_seconds: 0.0,
        };
        let closed_scene = RaycasterScene::build_multilevel(
            &closed_grid,
            &params,
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );
        let open_scene = RaycasterScene::build_multilevel(
            &open_grid,
            &params,
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );

        let closed_floor = closed_scene.floors.first().expect("closed floor");
        let open_floor = open_scene.floors.first().expect("open floor");
        assert!(closed_floor.light[0] < open_floor.light[0]);
        assert!(closed_floor.light[1] < open_floor.light[1]);
        assert!(closed_floor.light[2] < open_floor.light[2]);
    }

    #[test]
    fn build_multilevel_projects_upper_floor_above_horizon() {
        let mut lower = RaycasterLevel::new(2, 2);
        lower.set_ceiling_hole(0, 0, true);
        let mut upper = RaycasterLevel::new(2, 2);
        upper.floor_offset = 1.0;
        upper.ceiling_height = 2.0;

        let mut grid = MultiLevelGrid::new();
        grid.add_level(lower);
        grid.add_level(upper);
        grid.set_active_level(0);

        let params = SceneBuildParams {
            player_x: 0.5,
            player_y: 0.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            ray_count: 16,
            max_distance: 8.0,
            screen_width: 320.0,
            screen_height: 200.0,
            ambient_light: 0.3,
            global_light_color: Color::WHITE,
            global_light_intensity: 1.0,
            sun_angle: None,
            roofed_ambient_factor: 0.2,
            shade_distance: 15.0,
            floor_color: Color::new(0.2, 0.2, 0.2, 1.0),
            ceiling_color: Color::new(0.1, 0.1, 0.15, 1.0),
            camera_height: 2.0 / 3.0,
            horizon_offset: 0.0,
            background: None,
            overlays: Vec::new(),
            time_seconds: 0.0,
        };
        let scene = RaycasterScene::build_multilevel(
            &grid,
            &params,
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );

        let horizon = params.screen_height * 0.5 - params.horizon_offset;
        assert!(scene
            .floors
            .iter()
            .any(|quad| quad.corners.iter().all(|c| c.y < horizon)));
    }

    #[test]
    fn build_multilevel_skips_disconnected_upper_level_without_visible_ceiling_hole() {
        let lower = RaycasterLevel::new(8, 8);
        let mut upper = RaycasterLevel::new(8, 8);
        upper.floor_offset = 1.0;
        upper.ceiling_height = 2.0;
        upper.set_wall(4, 2, 1);

        let mut grid = MultiLevelGrid::new();
        grid.add_level(lower);
        grid.add_level(upper);
        grid.set_active_level(0);

        let params = SceneBuildParams {
            player_x: 1.5,
            player_y: 2.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            ray_count: 32,
            max_distance: 20.0,
            screen_width: 320.0,
            screen_height: 200.0,
            ambient_light: 0.3,
            global_light_color: Color::WHITE,
            global_light_intensity: 1.0,
            sun_angle: None,
            roofed_ambient_factor: 0.2,
            shade_distance: 15.0,
            floor_color: Color::new(0.2, 0.2, 0.2, 1.0),
            ceiling_color: Color::new(0.1, 0.1, 0.15, 1.0),
            camera_height: 0.5,
            horizon_offset: 0.0,
            background: None,
            overlays: Vec::new(),
            time_seconds: 0.0,
        };
        let scene = RaycasterScene::build_multilevel(
            &grid,
            &params,
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );

        assert!(scene.walls.is_empty());
    }

    #[test]
    fn multilevel_pick_screen_ignores_disconnected_upper_level() {
        let lower = RaycasterLevel::new(8, 8);
        let mut upper = RaycasterLevel::new(8, 8);
        upper.floor_offset = 1.0;
        upper.ceiling_height = 2.0;
        upper.set_wall(4, 2, 1);

        let mut grid = MultiLevelGrid::new();
        grid.add_level(lower);
        grid.add_level(upper);
        grid.set_active_level(0);

        let params = ScreenPickParams {
            player_x: 1.5,
            player_y: 2.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            screen_width: 320.0,
            screen_height: 200.0,
            camera_height: 0.5,
            horizon_offset: 0.0,
            max_distance: 20.0,
        };

        let hit = grid
            .pick_screen(&params, 160.0, 190.0)
            .expect("active floor pick");
        assert_eq!(hit.surface, PickSurface::Floor);
        assert_eq!(hit.level_index, 0);
    }

    #[test]
    fn build_multilevel_filters_point_lights_by_level() {
        let lower_tex = TextureKey::from(KeyData::from_ffi(401));
        let upper_tex = TextureKey::from(KeyData::from_ffi(402));

        let mut lower = RaycasterLevel::new(2, 1);
        lower.floor_texture = Some(lower_tex);

        let mut upper = RaycasterLevel::new(2, 1);
        upper.floor_offset = 1.0;
        upper.ceiling_height = 2.0;
        upper.floor_texture = Some(upper_tex);
        upper.set_floor_hole(0, 0, true);

        let mut grid = MultiLevelGrid::new();
        grid.add_level(lower);
        grid.add_level(upper);
        grid.set_active_level(1);

        let mut params = default_params();
        params.player_x = 1.0;
        params.player_y = 0.5;
        params.camera_height = 0.5;

        let baseline = RaycasterScene::build_multilevel(
            &grid,
            &params,
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );
        let lit_scene = RaycasterScene::build_multilevel(
            &grid,
            &params,
            &[PointLight {
                x: 0.5,
                y: 0.5,
                level_index: Some(1),
                radius: 4.0,
                intensity: 16.0,
                color: [1.0, 0.5, 0.25],
            }],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );

        let baseline_lower = baseline
            .floors
            .iter()
            .find(|quad| quad.texture_key == Some(lower_tex))
            .expect("baseline lower floor");
        let baseline_upper = baseline
            .floors
            .iter()
            .find(|quad| quad.texture_key == Some(upper_tex))
            .expect("baseline upper floor");
        let lit_lower = lit_scene
            .floors
            .iter()
            .find(|quad| quad.texture_key == Some(lower_tex))
            .expect("lit lower floor");
        let lit_upper = lit_scene
            .floors
            .iter()
            .find(|quad| quad.texture_key == Some(upper_tex))
            .expect("lit upper floor");

        assert_eq!(lit_lower.light, baseline_lower.light);
        assert!(lit_upper.light[0] > baseline_upper.light[0]);
        assert!(lit_upper.light[1] > baseline_upper.light[1]);
        assert!(lit_upper.light[2] > baseline_upper.light[2]);
    }

    #[test]
    fn build_multilevel_applies_level_wall_features() {
        let mut level = RaycasterLevel::new(8, 8);
        level.set_wall(7, 5, 1);
        level.set_wall_feature(7, 5, WallFeature::window(0.35, 0.75, 0.4));

        let mut grid = MultiLevelGrid::new();
        grid.add_level(level);

        let scene = RaycasterScene::build_multilevel(
            &grid,
            &default_params(),
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );

        assert_eq!(scene.walls.len(), 8);
        assert!(scene.walls.iter().all(|wall| wall.light[3] <= 0.4 + 1e-5));
    }

    #[test]
    fn build_multilevel_uses_level_surface_overrides_and_lowered_floor_cells() {
        let level_floor = TextureKey::from(KeyData::from_ffi(301));
        let cell_floor = TextureKey::from(KeyData::from_ffi(302));
        let lowered_floor = TextureKey::from(KeyData::from_ffi(303));
        let cell_ceiling = TextureKey::from(KeyData::from_ffi(304));

        let mut level = RaycasterLevel::new(1, 1);
        level.floor_texture = Some(level_floor);
        level.set_floor_texture(0, 0, cell_floor);
        level.set_ceiling_texture(0, 0, cell_ceiling);
        level.set_lowered_floor(
            0,
            0,
            lurek2d::raycaster::build_scene::LoweredFloorCell {
                texture_key: lowered_floor,
                depth_offset: 0.35,
                tint: [0.8, 0.7, 0.6],
                blocked: true,
            },
        );

        let mut grid = MultiLevelGrid::new();
        grid.add_level(level);
        grid.set_active_level(0);

        let mut params = default_params();
        params.player_x = 0.5;
        params.player_y = 0.5;

        let scene = RaycasterScene::build_multilevel(
            &grid,
            &params,
            &[],
            &[],
            &|_, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
            &|_, _, _| None,
        );

        assert!(
            scene
                .floors
                .iter()
                .any(|quad| quad.texture_key == Some(lowered_floor)),
            "expected lowered-floor texture on the pit bottom"
        );
        assert!(
            scene
                .ceilings
                .iter()
                .any(|quad| quad.texture_key == Some(cell_ceiling)),
            "expected per-cell ceiling override on the stacked level"
        );
        assert!(
            scene
                .walls
                .iter()
                .any(|quad| quad.texture_key == Some(cell_floor)),
            "expected pit side walls to inherit the per-cell floor texture"
        );
        assert!(
            scene
                .floors
                .iter()
                .all(|quad| quad.texture_key != Some(level_floor)),
            "cell override and lowered-floor texture should beat the level default on this tile"
        );
    }

    #[test]
    fn half_height_wall_renders_shorter_than_full_wall() {
        let mut full = Raycaster2D::new(8, 8);
        full.set_cell(7, 5, 1);
        let mut half = Raycaster2D::new(8, 8);
        half.set_cell(7, 5, 1);
        half.set_wall_feature(7, 5, WallFeature::half_height(0.5));

        let params = default_params();
        let full_scene = RaycasterScene::build(
            &full,
            &params,
            &[],
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );
        let half_scene = RaycasterScene::build(
            &half,
            &params,
            &[],
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );

        let full_height = full_scene.walls[0].corners[3].y - full_scene.walls[0].corners[0].y;
        let half_height = half_scene.walls[0].corners[3].y - half_scene.walls[0].corners[0].y;
        assert!(half_height < full_height);
    }

    #[test]
    fn window_feature_splits_isolated_wall_into_two_bands_per_face() {
        let mut rc = Raycaster2D::new(8, 8);
        rc.set_cell(7, 5, 1);
        rc.set_wall_feature(7, 5, WallFeature::window(0.35, 0.75, 0.4));

        let params = default_params();
        let scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );

        assert_eq!(scene.walls.len(), 8);
        assert!(scene.walls.iter().all(|wall| wall.light[3] <= 0.4 + 1e-5));
    }

    #[test]
    fn floor_and_ceiling_texture_lookup_applies_per_cell_override() {
        let mut rc = Raycaster2D::new(10, 10);
        rc.set_cell(7, 5, 1);

        let params = default_params();
        let floor_key = TextureKey::from(KeyData::from_ffi(101));
        let ceiling_key = TextureKey::from(KeyData::from_ffi(202));

        let scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &[],
            &|_| None,
            &|_, _| Some(floor_key),
            &|_, _| Some(ceiling_key),
            &|_, _| None,
        );

        assert!(
            scene
                .floors
                .iter()
                .any(|f| f.texture_key == Some(floor_key)),
            "Expected at least one floor quad to use floor texture override"
        );
        assert!(
            scene
                .ceilings
                .iter()
                .any(|c| c.texture_key == Some(ceiling_key)),
            "Expected at least one ceiling quad to use ceiling texture override"
        );
    }

    #[test]
    fn floor_and_ceiling_without_override_keep_color_fallback() {
        let mut rc = Raycaster2D::new(10, 10);
        rc.set_cell(7, 5, 1);

        let params = default_params();
        let scene = RaycasterScene::build(
            &rc,
            &params,
            &[],
            &[],
            &|_| None,
            &|_, _| None,
            &|_, _| None,
            &|_, _| None,
        );

        assert!(
            scene.floors.iter().any(|f| f.texture_key.is_none()),
            "Expected some floor quads to remain untextured for color fallback"
        );
        assert!(
            scene.ceilings.iter().any(|c| c.texture_key.is_none()),
            "Expected some ceiling quads to remain untextured for color fallback"
        );
    }
}

mod contract_validation_tests {
    use super::*;

    #[test]
    fn try_new_and_try_set_cells_reject_invalid_grid_shapes() {
        assert!(matches!(
            Raycaster2D::try_new(0, 4),
            Err(RaycasterError::GridDimensionsZero {
                width: 0,
                height: 4
            })
        ));
        assert!(matches!(
            Raycaster2D::try_new(8_193, 1),
            Err(RaycasterError::GridDimensionsTooLarge { .. })
        ));
        assert!(matches!(
            Raycaster2D::try_new(2_049, 2_049),
            Err(RaycasterError::GridCellLimitExceeded { .. })
        ));

        let mut rc = Raycaster2D::try_new(2, 2).expect("valid grid");
        assert!(matches!(
            rc.try_set_cells(vec![1, 2, 3]),
            Err(RaycasterError::DataLengthMismatch {
                context: "raycaster.set_cells",
                expected: 4,
                actual: 3
            })
        ));
    }

    #[test]
    fn checked_oob_queries_follow_the_selected_policy() {
        let mut rc = Raycaster2D::new(2, 2);
        rc.set_cell(0, 0, 7);

        assert_eq!(rc.get_cell_checked(-1, 0), Some(0));
        assert_eq!(rc.is_blocked_checked(-1, 0), Some(false));

        rc.set_out_of_bounds_policy(OutOfBoundsPolicy::Blocked);
        assert_eq!(rc.get_cell_checked(-1, 0), Some(1));
        assert_eq!(rc.is_blocked_checked(-1, 0), Some(true));

        rc.set_out_of_bounds_policy(OutOfBoundsPolicy::Stop);
        assert_eq!(rc.get_cell_checked(-1, 0), None);
        assert_eq!(rc.is_blocked_checked(-1, 0), None);

        assert_eq!(rc.get_cell_checked(0, 0), Some(7));
        assert_eq!(rc.is_blocked_checked(0, 0), Some(true));
    }

    #[test]
    fn tile_picker_pick_tile_matches_full_picker_surface_rules() {
        let mut empty = TilePicker::new(8, 8, 1.0);
        empty.set_camera(1.5, 1.5, 0.0);
        empty.set_screen_size(320.0, 200.0);

        assert!(
            empty.pick_tile(160.0, 100.0).is_none(),
            "center horizon should not fabricate a wall hit in empty space"
        );

        let floor = empty.pick_tile(160.0, 190.0).expect("floor pick");
        assert_eq!(floor.surface, PickSurface::Floor);

        let ceiling = empty.pick_tile(160.0, 10.0).expect("ceiling pick");
        assert_eq!(ceiling.surface, PickSurface::Ceiling);

        let mut walls = TilePicker::new(8, 8, 1.0);
        walls.set_camera(1.5, 1.5, 0.0);
        walls.set_screen_size(320.0, 200.0);
        walls.set_cell(4, 1, 1);

        let wall = walls.pick_tile(160.0, 100.0).expect("wall pick");
        assert_eq!(wall.surface, PickSurface::Wall);
        assert_eq!((wall.grid_x, wall.grid_y), (4, 1));
        assert_eq!(wall.cell_value, 1);
    }
}

mod cursor_pick_metadata_tests {
    use super::*;
    use lurek2d::runtime::resource_keys::TextureKey;
    use slotmap::KeyData;
    use std::collections::HashMap;

    fn unit_corners(x: f32, y: f32, w: f32, h: f32) -> [Vec2; 4] {
        [
            Vec2::new(x, y),
            Vec2::new(x + w, y),
            Vec2::new(x + w, y + h),
            Vec2::new(x, y + h),
        ]
    }

    fn unit_uvs() -> [Vec2; 4] {
        [
            Vec2::new(0.0, 0.0),
            Vec2::new(1.0, 0.0),
            Vec2::new(1.0, 1.0),
            Vec2::new(0.0, 1.0),
        ]
    }

    fn pick_params() -> ScreenPickParams {
        ScreenPickParams {
            player_x: 1.5,
            player_y: 1.5,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            screen_width: 160.0,
            screen_height: 100.0,
            camera_height: 0.5,
            horizon_offset: 0.0,
            max_distance: 16.0,
        }
    }

    #[test]
    fn raycaster_pick_attrs_merge_any_and_surface_channels() {
        let mut rc = Raycaster2D::new(6, 4);
        rc.set_cell(4, 1, 7);
        rc.set_pick_attr(4, 1, PickAttrSurface::Any, "cursor_state", "inspect");
        rc.set_pick_attr(4, 1, PickAttrSurface::Wall, "cursor_effect", "spark");

        let hit = rc
            .pick_screen(&pick_params(), 80.0, 50.0)
            .expect("expected wall pick");
        assert_eq!(hit.kind, "wall");
        assert_eq!(
            hit.attrs.get("cursor_state").map(String::as_str),
            Some("inspect")
        );
        assert_eq!(
            hit.attrs.get("cursor_effect").map(String::as_str),
            Some("spark")
        );

        rc.clear_pick_attr(4, 1, PickAttrSurface::Wall, Some("cursor_effect"));
        assert_eq!(
            rc.get_pick_attr(4, 1, PickAttrSurface::Wall, "cursor_effect"),
            None
        );
        assert_eq!(
            rc.pick_attrs_at(4, 1, PickAttrSurface::Wall)
                .get("cursor_state")
                .map(String::as_str),
            Some("inspect")
        );
    }

    #[test]
    fn raycaster_level_pick_attrs_round_trip() {
        let mut level = RaycasterLevel::new(3, 3);
        level.set_pick_attr(1, 1, PickAttrSurface::Floor, "cursor_zoom", "2.5");
        level.set_pick_attr(1, 1, PickAttrSurface::Any, "cursor_priority", "90");

        assert_eq!(
            level.get_pick_attr(1, 1, PickAttrSurface::Floor, "cursor_zoom"),
            Some("2.5")
        );
        assert_eq!(
            level.get_pick_attr(1, 1, PickAttrSurface::Any, "cursor_priority"),
            Some("90")
        );

        level.clear_pick_attr(1, 1, PickAttrSurface::Floor, Some("cursor_zoom"));
        assert_eq!(
            level.get_pick_attr(1, 1, PickAttrSurface::Floor, "cursor_zoom"),
            None
        );
    }

    #[test]
    fn sprite_manager_attr_store_round_trips() {
        let mut sprites = SpriteManager::new();
        let id = sprites.add(2.0, 3.0, "npc.png", 1.0);

        sprites.set_attr(id, "cursor_state", "talk");
        sprites.set_attr(id, "cursor_effect", "ping");
        assert_eq!(sprites.get_attr(id, "cursor_state"), Some("talk"));
        assert_eq!(sprites.get_attr(id, "cursor_effect"), Some("ping"));

        sprites.clear_attr(id, Some("cursor_state"));
        assert_eq!(sprites.get_attr(id, "cursor_state"), None);

        sprites.clear_attr(id, None);
        assert_eq!(sprites.get_attr(id, "cursor_effect"), None);
    }

    #[test]
    fn entity_pick_returns_sprite_attrs() {
        let texture_key = TextureKey::from(KeyData::from_ffi(33));
        let mut attrs = HashMap::new();
        attrs.insert("cursor_state".to_string(), "loot".to_string());
        attrs.insert("cursor_effect".to_string(), "spark".to_string());

        let mut scene = RaycasterScene::new(64.0, 48.0);
        scene.sprites.push(BillboardSprite {
            corners: unit_corners(16.0, 8.0, 20.0, 20.0),
            uvs: unit_uvs(),
            texture_key,
            light: [1.0, 1.0, 1.0, 1.0],
            depth: 2.0,
            entity_id: Some(77),
            level_index: 0,
            world_x: 2.0,
            world_y: 2.0,
            attrs,
        });

        let pick = scene.pick_entity(24.0, 18.0).expect("expected sprite pick");
        assert_eq!(pick.kind, EntityPickKind::Sprite);
        assert_eq!(
            pick.attrs.get("cursor_state").map(String::as_str),
            Some("loot")
        );
        assert_eq!(
            pick.attrs.get("cursor_effect").map(String::as_str),
            Some("spark")
        );
    }
}
