//! File: tests/rust/unit/physics_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::physics::zone::ZoneTracker;
use lurek2d::physics::*;
use mlua::FromLua;
use std::collections::HashSet;

// â”€â”€ body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

// Public body behavior is covered in `tests/lua/unit/test_physics_unit.lua`.

// â”€â”€ collision_helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod collision_helpers_tests {
    use lurek2d::physics::collision_helpers::{
        test_aabb, test_circle_aabb, test_circles, test_point_aabb,
    };

    #[test]
    fn aabb_overlap() {
        assert!(test_aabb(0.0, 0.0, 10.0, 10.0, 5.0, 5.0, 10.0, 10.0));
    }

    #[test]
    fn aabb_no_overlap() {
        assert!(!test_aabb(0.0, 0.0, 10.0, 10.0, 20.0, 20.0, 10.0, 10.0));
    }

    #[test]
    fn aabb_adjacent_no_overlap() {
        assert!(!test_aabb(0.0, 0.0, 10.0, 10.0, 10.0, 0.0, 10.0, 10.0));
    }

    #[test]
    fn circles_overlap() {
        assert!(test_circles(0.0, 0.0, 5.0, 3.0, 0.0, 5.0));
    }

    #[test]
    fn circles_no_overlap() {
        assert!(!test_circles(0.0, 0.0, 2.0, 10.0, 0.0, 2.0));
    }

    #[test]
    fn point_inside_aabb() {
        assert!(test_point_aabb(5.0, 5.0, 0.0, 0.0, 10.0, 10.0));
    }

    #[test]
    fn point_outside_aabb() {
        assert!(!test_point_aabb(15.0, 5.0, 0.0, 0.0, 10.0, 10.0));
    }

    #[test]
    fn point_on_boundary() {
        assert!(test_point_aabb(0.0, 0.0, 0.0, 0.0, 10.0, 10.0));
        assert!(!test_point_aabb(10.0, 10.0, 0.0, 0.0, 10.0, 10.0));
    }

    #[test]
    fn circle_aabb_overlap() {
        assert!(test_circle_aabb(5.0, 5.0, 3.0, 0.0, 0.0, 10.0, 10.0));
    }

    #[test]
    fn circle_aabb_no_overlap() {
        assert!(!test_circle_aabb(20.0, 20.0, 1.0, 0.0, 0.0, 10.0, 10.0));
    }

    #[test]
    fn circle_aabb_corner_case() {
        assert!(test_circle_aabb(12.0, 12.0, 3.0, 0.0, 0.0, 10.0, 10.0));
    }
}

// â”€â”€ render â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod render_tests {
    use super::*;

    #[test]
    fn generate_render_commands_empty_world_returns_empty() {
        let world = World::new(0.0, 9.8);
        let cmds = world.generate_render_commands();
        assert!(cmds.is_empty());
    }

    #[test]
    fn draw_to_image_correct_dimensions() {
        let world = World::new(0.0, 9.8);
        let img = world.draw_to_image(64, 64);
        assert_eq!(img.width(), 64);
        assert_eq!(img.height(), 64);
    }
}

// â”€â”€ zone â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod zone_tests {
    use super::*;

    #[test]
    fn tracker_enter_leave_events() {
        let mut tracker = ZoneTracker::new();
        let events = tracker.update(0, [1].into_iter().collect());
        assert_eq!(events.len(), 1);
        assert_eq!(events[0].kind, ZoneEventKind::Enter);
        assert_eq!(events[0].zone_id, 1);

        let events = tracker.update(0, [1].into_iter().collect());
        assert!(events.is_empty());

        let events = tracker.update(0, HashSet::new());
        assert_eq!(events.len(), 1);
        assert_eq!(events[0].kind, ZoneEventKind::Leave);
    }

    #[test]
    fn tracker_remove_body() {
        let mut tracker = ZoneTracker::new();
        tracker.update(0, [1].into_iter().collect());
        tracker.remove_body(0);
        let events = tracker.update(0, [1].into_iter().collect());
        assert_eq!(events.len(), 1);
        assert_eq!(events[0].kind, ZoneEventKind::Enter);
    }
}

// â”€â”€ shape â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

// Public shape construction behavior is covered in `tests/lua/unit/test_physics_unit.lua`.

// â”€â”€ world â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod world_tests {
    use super::*;

    #[test]
    fn get_body_out_of_range_returns_none() {
        let w = World::new(0.0, 0.0);
        assert!(w.get_body(99).is_none());
    }

    #[test]
    fn get_body_mut_allows_mutation() {
        let mut w = World::new(0.0, 0.0);
        let id = w.add_body(Body::new(0.0, 0.0, 32.0, 32.0, BodyType::Dynamic));
        w.get_body_mut(id.0).unwrap().position.x = 123.0;
        assert!((w.get_body(id.0).unwrap().position.x - 123.0).abs() < 1e-6);
    }

    #[test]
    fn destroy_body_out_of_range_no_panic() {
        let mut w = World::new(0.0, 0.0);
        w.destroy_body(999);
    }

    #[test]
    fn fixture_count_out_of_range() {
        let w = World::new(0.0, 0.0);
        assert_eq!(w.fixture_count(999), 0);
    }

    #[test]
    fn add_revolute_joint_returns_id() {
        let mut w = World::new(0.0, 0.0);
        let a = w.add_body(Body::new(0.0, 0.0, 32.0, 32.0, BodyType::Dynamic));
        let b = w.add_body(Body::new(50.0, 0.0, 32.0, 32.0, BodyType::Dynamic));
        let jid = w.add_revolute_joint(a.0, b.0, 0.0, 0.0);
        assert_eq!(jid, 0);
        assert_eq!(w.joint_count(), 1);
    }

    #[test]
    fn destroy_joint_decrements_count_logically() {
        let mut w = World::new(0.0, 0.0);
        let a = w.add_body(Body::new(0.0, 0.0, 32.0, 32.0, BodyType::Dynamic));
        let b = w.add_body(Body::new(50.0, 0.0, 32.0, 32.0, BodyType::Dynamic));
        let jid = w.add_revolute_joint(a.0, b.0, 0.0, 0.0);
        w.destroy_joint(jid);
        assert!(!w.has_joint(jid));
        assert_eq!(w.joint_count(), 0);
        assert!(w.get_joint_ids().is_empty());
        assert_eq!(w.get_joint_type(jid), "unknown");
    }

    #[test]
    fn destroy_body_tombstones_slot_and_excludes_debug() {
        let mut w = World::new(0.0, 0.0);
        let first = w.add_body(Body::new(0.0, 0.0, 32.0, 32.0, BodyType::Dynamic));
        let second = w.add_body(Body::new(50.0, 0.0, 32.0, 32.0, BodyType::Dynamic));
        let jid = w.add_revolute_joint(first.0, second.0, 0.0, 0.0);

        w.destroy_body(first.0);

        assert!(!w.has_body(first.0));
        assert!(w.has_body(second.0));
        assert!(!w.has_joint(jid));
        assert_eq!(w.body_count(), 1);
        assert_eq!(w.get_body_ids(), vec![second.0]);
        assert_eq!(w.get_body(first.0).map(|_| ()), None);
        assert_eq!(w.extract_shape_snapshots().len(), 1);

        let stats = w.get_stats();
        assert_eq!(stats.bodies, 1);
        assert_eq!(stats.body_slots, 2);
        assert_eq!(stats.joints, 0);
        assert_eq!(stats.joint_slots, 1);
    }

    #[test]
    fn raycast_sees_extra_fixture_and_query_deduplicates_body() {
        let mut w = World::new(0.0, 0.0);
        let body = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Static));
        let fixture_index = w.add_fixture(
            body.0,
            Shape::Rect {
                width: 10.0,
                height: 10.0,
            },
            1.0,
            0.5,
            0.0,
            false,
        );
        assert_eq!(fixture_index, 1);
        w.step(1.0 / 60.0);

        let hit = w.raycast(-20.0, 0.0, 20.0, 0.0).expect("body hit");
        assert_eq!(hit.body_id, body);
        assert_eq!(w.query_aabb(-6.0, -6.0, 12.0, 12.0), vec![body.0]);
    }

    #[test]
    fn computed_mass_reflects_fixture_density_until_overridden() {
        let mut w = World::new(0.0, 0.0);
        let body = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        let before = w.get_body_mass(body.0);
        w.add_fixture(body.0, Shape::Circle { radius: 2.0 }, 10.0, 0.5, 0.0, false);
        let after = w.get_body_mass(body.0);
        assert!(after > before);
        w.set_body_mass(body.0, 7.5);
        assert!((w.get_body_mass(body.0) - 7.5).abs() < 1e-6);
    }

    #[test]
    fn query_filter_uses_layer_mask_and_sensor_flag() {
        let mut w = World::new(0.0, 0.0);
        let mut solid = Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Static);
        solid.layer = 0x2;
        solid.mask = 0x1;
        let solid_id = w.add_body(solid);
        let mut sensor = Body::new(30.0, 0.0, 10.0, 10.0, BodyType::Sensor);
        sensor.layer = 0x2;
        sensor.mask = 0x1;
        let sensor_id = w.add_body(sensor);
        w.step(1.0 / 60.0);

        let filter = PhysicsQueryFilter {
            layer: Some(0x1),
            mask: Some(0x2),
            groups: None,
            include_sensors: false,
        };
        assert_eq!(
            w.query_aabb_filtered(-10.0, -10.0, 60.0, 20.0, filter),
            vec![solid_id.0]
        );

        let with_sensors = PhysicsQueryFilter {
            include_sensors: true,
            ..filter
        };
        assert_eq!(
            w.query_aabb_filtered(-10.0, -10.0, 60.0, 20.0, with_sensors),
            vec![solid_id.0, sensor_id.0]
        );
    }

    #[test]
    fn collision_group_matrix_disables_one_pair_and_preserves_others() {
        let mut w = World::new(0.0, 0.0);
        let a = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        let b = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Static));
        let c = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        w.try_set_body_collision_group(a.0, 0).unwrap();
        w.try_set_body_collision_group(b.0, 1).unwrap();
        w.try_set_body_collision_group(c.0, 2).unwrap();

        w.step(1.0 / 60.0);
        let default_pairs: HashSet<_> = w
            .get_begin_contact_events()
            .iter()
            .map(|&(left, right)| {
                if left < right {
                    (left, right)
                } else {
                    (right, left)
                }
            })
            .collect();
        assert!(default_pairs.contains(&(a.0, b.0)));
        assert!(default_pairs.contains(&(b.0, c.0)));

        w.clear();
        let a = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        let b = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Static));
        let c = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        w.try_set_body_collision_group(a.0, 0).unwrap();
        w.try_set_body_collision_group(b.0, 1).unwrap();
        w.try_set_body_collision_group(c.0, 2).unwrap();
        w.try_set_collision_pair(0, 1, false).unwrap();

        w.step(1.0 / 60.0);
        let filtered_pairs: HashSet<_> = w
            .get_begin_contact_events()
            .iter()
            .map(|&(left, right)| {
                if left < right {
                    (left, right)
                } else {
                    (right, left)
                }
            })
            .collect();
        assert!(!filtered_pairs.contains(&(a.0, b.0)));
        assert!(filtered_pairs.contains(&(b.0, c.0)));
    }

    #[test]
    fn collision_group_matrix_refreshes_extra_fixtures_and_queries() {
        let mut w = World::new(0.0, 0.0);
        let body = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Static));
        w.add_fixture(
            body.0,
            Shape::Rect {
                width: 10.0,
                height: 10.0,
            },
            1.0,
            0.5,
            0.0,
            false,
        );
        w.try_set_body_collision_group(body.0, 1).unwrap();
        w.step(1.0 / 60.0);

        let group_zero_query = PhysicsQueryFilter {
            groups: Some(0x1),
            ..PhysicsQueryFilter::default()
        };
        assert_eq!(
            w.query_aabb_filtered(-6.0, -6.0, 12.0, 12.0, group_zero_query),
            vec![body.0]
        );

        w.try_set_collision_pair(0, 1, false).unwrap();
        w.step(1.0 / 60.0);
        assert!(w
            .query_aabb_filtered(-6.0, -6.0, 12.0, 12.0, group_zero_query)
            .is_empty());
        assert!(w
            .raycast_filtered(-20.0, 0.0, 20.0, 0.0, group_zero_query)
            .is_none());
    }

    #[test]
    fn collision_group_validation_rejects_out_of_range_values() {
        let mut w = World::new(0.0, 0.0);
        let body = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Static));
        assert!(w.try_set_body_collision_group(body.0, 16).is_err());
        assert!(w.try_set_collision_pair(0, 16, false).is_err());
        assert!(w.try_set_collision_group_mask(0, 0x1_0000).is_err());
        assert_eq!(
            w.try_get_collision_group_mask(16),
            Err(PhysicsError::ValueOutOfRange {
                field: "collision_group",
                min: 0.0,
                max: 15.0,
                value: 16.0,
            })
        );
    }

    #[test]
    fn add_zone_returns_id() {
        let mut w = World::new(0.0, 9.8);
        let zone = PhysicsZone::new_rect(0, 0.0, 0.0, 200.0, 200.0);
        let _zid = w.add_zone(zone); // just verify no panic
    }

    #[test]
    fn additive_gravity_vectors_are_stable_and_counted() {
        let mut w = World::new(0.0, 0.0);
        let first = w.add_gravity_vector(10.0, 0.0, u32::MAX);
        let second = w.add_gravity_vector(0.0, 10.0, 0x2);
        assert_eq!(first, 0);
        assert_eq!(second, 1);
        assert_eq!(w.get_stats().gravity_vectors, 2);
        w.set_gravity_vector(second, 0.0, -10.0, 0x4);
        let vector = w.get_gravity_vector(second).expect("active vector");
        assert_eq!(vector.layer_mask, 0x4);
        assert!(w.remove_gravity_vector(first));
        assert_eq!(w.get_stats().gravity_vectors, 1);
        w.clear_gravity_vectors();
        assert_eq!(w.get_stats().gravity_vectors, 0);
    }

    #[test]
    fn step_rejects_nan_dt() {
        let mut w = World::new(0.0, 10.0);
        let id = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        w.step(f32::NAN);
        let stats = w.get_stats();
        assert_eq!(stats.skipped_steps, 1);
        let body = w.get_body(id.0).unwrap();
        assert!(body.position.y.abs() < 1e-6);
    }

    #[test]
    fn dynamic_body_not_resynced_without_dirty_flag() {
        let mut w = World::new(0.0, 0.0);
        let id = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        w.get_body_mut(id.0).unwrap().position.x = 1000.0;
        w.step(1.0 / 60.0);
        let body = w.get_body(id.0).unwrap();
        assert!(body.position.x.abs() < 1.0);
    }

    #[test]
    fn try_add_joint_invalid_body_returns_error_not_zero() {
        let mut w = World::new(0.0, 0.0);
        let a = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        assert_eq!(w.add_revolute_joint(a.0, 999, 0.0, 0.0), 0);
        let err = w.try_add_revolute_joint(a.0, 999, 0.0, 0.0).unwrap_err();
        assert!(err.to_string().contains("not active"));
    }

    #[test]
    fn try_add_fixture_invalid_body_returns_error() {
        let mut w = World::new(0.0, 0.0);
        let err = w
            .try_add_fixture(
                999,
                Shape::Rect {
                    width: 1.0,
                    height: 1.0,
                },
                1.0,
                0.5,
                0.0,
                false,
            )
            .unwrap_err();
        assert!(err.to_string().contains("body id 999"));
    }

    #[test]
    fn zone_restores_previous_gravity_scale() {
        let mut w = World::new(0.0, 9.8);
        let id = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        w.set_gravity_scale(id.0, 0.25);
        let zone_id = w
            .try_add_zone(PhysicsZone::try_new_rect(0, -20.0, -20.0, 40.0, 40.0).unwrap())
            .unwrap();
        w.zone_mut(zone_id).unwrap().set_gravity_zero();
        w.step(1.0 / 60.0);
        assert_eq!(w.get_gravity_scale(id.0), 0.0);
        w.set_body_position(id.0, 100.0, 100.0);
        w.step(1.0 / 60.0);
        assert!((w.get_gravity_scale(id.0) - 0.25).abs() < 1e-6);
    }

    #[test]
    fn clear_preserves_world_settings_but_removes_runtime_state() {
        let mut w = World::new(0.0, 9.8);
        let id = w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        w.set_gravity(-3.0, 4.0);
        w.set_meter(96.0);
        w.set_solver_iterations(12);
        w.try_add_zone(PhysicsZone::try_new_rect(0, -10.0, -10.0, 20.0, 20.0).unwrap())
            .unwrap();

        w.clear();

        assert_eq!(w.body_count(), 0);
        assert!(!w.has_body(id.0));
        assert_eq!(w.joint_count(), 0);
        assert_eq!(w.get_stats().zones, 0);
        assert_eq!(w.get_gravity(), (-3.0, 4.0));
        assert!((w.get_meter() - 96.0).abs() < 1e-6);
        assert_eq!(w.get_solver_iterations(), 12);
    }

    #[test]
    fn reset_world_restores_constructor_settings() {
        let mut w = World::new(0.0, 9.8);
        w.add_body(Body::new(0.0, 0.0, 10.0, 10.0, BodyType::Dynamic));
        w.set_gravity(-3.0, 4.0);
        w.set_meter(96.0);
        w.set_solver_iterations(12);
        w.try_add_zone(PhysicsZone::try_new_rect(0, -10.0, -10.0, 20.0, 20.0).unwrap())
            .unwrap();

        w.reset_world();

        assert_eq!(w.body_count(), 0);
        assert_eq!(w.joint_count(), 0);
        assert_eq!(w.get_stats().zones, 0);
        assert_eq!(w.get_gravity(), (0.0, 9.8));
        assert!((w.get_meter() - 1.0).abs() < 1e-6);
        assert_eq!(w.get_solver_iterations(), 4);
    }

    #[test]
    fn collision_events_empty_without_step() {
        let w = World::new(0.0, 0.0);
        assert!(w.get_collision_events().is_empty());
    }

    #[test]
    fn begin_end_contact_events_empty_initially() {
        let w = World::new(0.0, 0.0);
        assert!(w.get_begin_contact_events().is_empty());
        assert!(w.get_end_contact_events().is_empty());
    }

    #[test]
    fn add_bodies_batch() {
        let mut w = World::new(0.0, 0.0);
        let specs = vec![
            (0.0, 0.0, 32.0, 32.0, BodyType::Dynamic),
            (10.0, 10.0, 16.0, 16.0, BodyType::Static),
            (20.0, 20.0, 64.0, 64.0, BodyType::Sensor),
        ];
        let ids = w.add_bodies(specs);
        assert_eq!(ids.len(), 3);
        assert_eq!(w.body_count(), 3);
    }
}

mod type_tests {
    use super::*;

    #[test]
    fn body_id_roundtrips_and_displays() {
        let id = BodyId::new(42);
        assert_eq!(id.raw(), 42);
        assert_eq!(id.to_string(), "42");
        assert_eq!(usize::from(id), 42);
        assert_eq!(BodyId::from(42usize), id);
    }

    #[test]
    fn body_id_from_lua_rejects_negative() {
        let lua = mlua::Lua::new();
        let err = BodyId::from_lua(mlua::Value::Integer(-1), &lua).unwrap_err();
        assert!(err.to_string().contains("non-negative"));
        let zero = BodyId::from_lua(mlua::Value::Integer(0), &lua).unwrap();
        assert_eq!(zero.raw(), 0);
        let huge = BodyId::from_lua(mlua::Value::Integer(i64::MAX), &lua).unwrap();
        assert_eq!(huge.raw(), i64::MAX as usize);
    }
}

mod body_tests {
    use super::*;
    use lurek2d::math::Vec2;

    #[test]
    fn new_circle_sets_expected_dimensions() {
        let body = Body::new_circle(10.0, 20.0, 4.0, BodyType::Dynamic);
        assert!((body.width - 8.0).abs() < 1e-6);
        assert!((body.height - 8.0).abs() < 1e-6);
        assert_eq!(body.get_type(), "dynamic");
    }

    #[test]
    fn bounding_box_for_rect_matches_centered_dimensions() {
        let body = Body::new(10.0, 20.0, 8.0, 6.0, BodyType::Static);
        let (x, y, w, h) = body.get_bounding_box();
        assert!((x - 6.0).abs() < 1e-6);
        assert!((y - 17.0).abs() < 1e-6);
        assert!((w - 8.0).abs() < 1e-6);
        assert!((h - 6.0).abs() < 1e-6);
    }

    #[test]
    fn collides_with_layer_requires_bidirectional_mask_overlap() {
        let mut a = Body::new(0.0, 0.0, 4.0, 4.0, BodyType::Dynamic);
        let mut b = Body::new(0.0, 0.0, 4.0, 4.0, BodyType::Dynamic);
        a.layer = 0b0010;
        a.mask = 0b0100;
        b.layer = 0b0100;
        b.mask = 0b0010;
        assert!(a.collides_with_layer(&b));

        b.mask = 0b1000;
        assert!(!a.collides_with_layer(&b));
    }

    #[test]
    fn world_and_local_points_roundtrip() {
        let mut body = Body::new(10.0, 15.0, 4.0, 4.0, BodyType::Dynamic);
        body.angle = std::f32::consts::FRAC_PI_2;
        let (wx, wy) = body.get_world_point(2.0, 0.0);
        assert!((wx - 10.0).abs() < 1e-5);
        assert!((wy - 17.0).abs() < 1e-5);

        let (lx, ly) = body.get_local_point(wx, wy);
        assert!((lx - 2.0).abs() < 1e-5);
        assert!(ly.abs() < 1e-5);
    }

    #[test]
    fn polygon_body_preserves_extended_shape() {
        let vertices = vec![
            Vec2::new(-2.0, -1.0),
            Vec2::new(2.0, -1.0),
            Vec2::new(0.0, 3.0),
        ];
        let body = Body::new_polygon(0.0, 0.0, vertices.clone(), BodyType::Dynamic);
        assert!((body.width - 4.0).abs() < 1e-6);
        assert!((body.height - 4.0).abs() < 1e-6);
        assert_eq!(body.shape_ext, Some(Shape::Polygon { vertices }));
    }

    #[test]
    fn try_new_rejects_negative_dimensions() {
        let err = Body::try_new(0.0, 0.0, -1.0, 2.0, BodyType::Dynamic)
            .err()
            .expect("negative width should fail");
        assert!(err.to_string().contains("width"));
        let err = Body::try_new_circle(0.0, 0.0, -2.0, BodyType::Dynamic)
            .err()
            .expect("negative radius should fail");
        assert!(err.to_string().contains("radius"));
    }
}

mod shape_tests {
    use super::*;
    use lurek2d::image::ImageData;

    #[test]
    fn from_parts_rectangle_parses_dimensions() {
        let shape = Shape::from_parts("rectangle", &[8.0, 6.0], false).unwrap();
        assert_eq!(
            shape,
            Shape::Rect {
                width: 8.0,
                height: 6.0
            }
        );
    }

    #[test]
    fn from_parts_chain_respects_closed_flag() {
        let shape = Shape::from_parts("chain", &[0.0, 0.0, 2.0, 0.0, 2.0, 2.0], true).unwrap();
        assert_eq!(
            shape,
            Shape::Chain {
                vertices: vec![
                    lurek2d::math::Vec2::new(0.0, 0.0),
                    lurek2d::math::Vec2::new(2.0, 0.0),
                    lurek2d::math::Vec2::new(2.0, 2.0),
                ],
                closed: true,
            }
        );
    }

    #[test]
    fn from_parts_invalid_type_returns_error() {
        let err = Shape::from_parts("capsule", &[1.0], false).unwrap_err();
        assert!(err.contains("invalid shape type"));
    }

    #[test]
    fn regular_polygon_clamps_side_count() {
        let shape = Shape::regular_polygon(2.0, 1);
        match shape {
            Shape::Polygon { vertices } => assert_eq!(vertices.len(), 3),
            _ => panic!("expected polygon"),
        }
    }

    #[test]
    fn standalone_shape_circle_reports_radius() {
        let shape = StandaloneShape::new(Shape::Circle { radius: 5.0 });
        assert_eq!(shape.get_type(), "circle");
        let radius = shape.get_radius().expect("circle radius");
        assert!((radius - 5.0).abs() < 1e-6);
        let (min_x, min_y, max_x, max_y) = shape.get_bounding_box();
        assert!((min_x + 5.0).abs() < 1e-6);
        assert!((min_y + 5.0).abs() < 1e-6);
        assert!((max_x - 5.0).abs() < 1e-6);
        assert!((max_y - 5.0).abs() < 1e-6);
    }

    #[test]
    fn standalone_shape_rect_reports_bounding_box() {
        let shape = StandaloneShape::new(Shape::Rect {
            width: 8.0,
            height: 6.0,
        });
        assert_eq!(shape.get_type(), "rectangle");
        assert_eq!(shape.get_radius(), None);
        let (min_x, min_y, max_x, max_y) = shape.get_bounding_box();
        assert!((min_x + 4.0).abs() < 1e-6);
        assert!((min_y + 3.0).abs() < 1e-6);
        assert!((max_x - 4.0).abs() < 1e-6);
        assert!((max_y - 3.0).abs() < 1e-6);
    }

    #[test]
    fn alpha_mask_inference_prefers_circle_then_polygon() {
        let mut circle_img = ImageData::new(32, 32);
        circle_img.draw_circle(16, 16, 8, 255, 255, 255, 255);
        let circle = Shape::from_image_alpha(&circle_img, AlphaShapeOptions::default()).unwrap();
        match circle {
            Shape::Circle { radius } => assert!(radius > 6.0),
            other => panic!("expected circle, got {other:?}"),
        }

        let mut plus_img = ImageData::new(32, 32);
        plus_img.draw_rect(4, 16, 20, 4, 255, 255, 255, 255);
        plus_img.draw_rect(16, 4, 4, 20, 255, 255, 255, 255);
        let polygon = Shape::from_image_alpha(
            &plus_img,
            AlphaShapeOptions {
                rectangle_fill_threshold: 1.0,
                circle_fill_tolerance: 0.01,
                max_vertices: 6,
                ..AlphaShapeOptions::default()
            },
        )
        .unwrap();
        match polygon {
            Shape::Polygon { vertices } => assert!(vertices.len() >= 3),
            other => panic!("expected polygon, got {other:?}"),
        }
    }

    #[test]
    fn validate_rejects_nan_and_degenerate_polygon() {
        let limits = PhysicsLimits::default();
        let nan_shape = Shape::Polygon {
            vertices: vec![
                lurek2d::math::Vec2::new(0.0, 0.0),
                lurek2d::math::Vec2::new(f32::NAN, 1.0),
                lurek2d::math::Vec2::new(1.0, 0.0),
            ],
        };
        assert!(nan_shape.validate(&limits).is_err());
        let flat = Shape::Polygon {
            vertices: vec![
                lurek2d::math::Vec2::new(0.0, 0.0),
                lurek2d::math::Vec2::new(1.0, 0.0),
                lurek2d::math::Vec2::new(2.0, 0.0),
            ],
        };
        assert!(flat.validate(&limits).is_err());
    }
}

mod terrain_tests {
    use super::*;

    #[test]
    fn set_and_get_cell_roundtrip() {
        let mut terrain = TerrainMap::new(4, 4, 8.0);
        terrain.set_cell(1, 2, true);
        assert!(terrain.get_cell(1, 2));
        assert!(terrain.is_dirty());
    }

    #[test]
    fn out_of_bounds_cells_are_safe() {
        let mut terrain = TerrainMap::new(2, 2, 8.0);
        terrain.set_cell(5, 5, true);
        assert!(!terrain.get_cell(5, 5));
    }

    #[test]
    fn fill_all_marks_terrain_dirty() {
        let mut terrain = TerrainMap::new(20, 20, 8.0);
        terrain.fill_all(true);
        assert!(terrain.is_dirty());
        assert!(terrain.get_cell(0, 0));
        assert!(terrain.get_cell(19, 19));
    }

    #[test]
    fn bytes_roundtrip_preserves_solid_cells() {
        let mut terrain = TerrainMap::new(4, 3, 2.5);
        terrain.set_cell(0, 0, true);
        terrain.set_cell(3, 2, true);
        let bytes = terrain.to_bytes();
        let restored = TerrainMap::from_bytes(&bytes).expect("roundtrip");
        assert!(restored.get_cell(0, 0));
        assert!(restored.get_cell(3, 2));
        assert_eq!(restored.width, 4);
        assert_eq!(restored.height, 3);
        assert!((restored.cell_size - 2.5).abs() < 1e-6);
    }

    #[test]
    fn load_from_bytes_rejects_dimension_mismatch() {
        let other = TerrainMap::new(3, 3, 1.0).to_bytes();
        let mut terrain = TerrainMap::new(4, 4, 1.0);
        assert!(!terrain.load_from_bytes(&other));
    }

    #[test]
    fn collapse_columns_removes_unsupported_single_cell() {
        let mut terrain = TerrainMap::new(3, 3, 1.0);
        terrain.set_cell(1, 1, true);
        assert_eq!(terrain.collapse_columns(), 1);
        assert!(!terrain.get_cell(1, 1));
    }

    #[test]
    fn try_new_rejects_zero_cell_size() {
        let err = TerrainMap::try_new(4, 4, 0.0)
            .err()
            .expect("zero cell size should fail");
        assert!(err.to_string().contains("cell_size"));
    }

    #[test]
    fn from_bytes_rejects_huge_dimensions_and_short_payload() {
        let mut huge = Vec::new();
        huge.extend_from_slice(&1u32.to_le_bytes());
        huge.extend_from_slice(&u32::MAX.to_le_bytes());
        huge.extend_from_slice(&u32::MAX.to_le_bytes());
        huge.extend_from_slice(&1.0f32.to_bits().to_le_bytes());
        assert!(TerrainMap::from_bytes(&huge).is_none());

        let mut short = Vec::new();
        short.extend_from_slice(&1u32.to_le_bytes());
        short.extend_from_slice(&8u32.to_le_bytes());
        short.extend_from_slice(&8u32.to_le_bytes());
        short.extend_from_slice(&1.0f32.to_bits().to_le_bytes());
        short.push(0xFF);
        assert!(TerrainMap::from_bytes(&short).is_none());
    }
}

mod zone_boundary_tests {
    use super::*;

    #[test]
    fn zone_boundary_rect_contains_points() {
        let boundary = ZoneBoundary::Rect {
            x: 10.0,
            y: 20.0,
            width: 5.0,
            height: 7.0,
        };
        assert!(boundary.contains(10.0, 20.0));
        assert!(boundary.contains(15.0, 27.0));
        assert!(!boundary.contains(15.1, 27.0));
    }

    #[test]
    fn zone_boundary_circle_contains_points() {
        let boundary = ZoneBoundary::Circle {
            cx: 0.0,
            cy: 0.0,
            radius: 5.0,
        };
        assert!(boundary.contains(3.0, 4.0));
        assert!(!boundary.contains(5.1, 0.0));
    }

    #[test]
    fn physics_zone_contains_respects_enabled_flag() {
        let mut zone = PhysicsZone::new_rect(7, 0.0, 0.0, 10.0, 10.0);
        assert!(zone.contains(2.0, 2.0));
        zone.enabled = false;
        assert!(!zone.contains(2.0, 2.0));
    }

    #[test]
    fn tracker_clear_resets_membership() {
        let mut tracker = ZoneTracker::new();
        tracker.update(0, [1, 2].into_iter().collect());
        tracker.clear();
        let events = tracker.update(0, [2].into_iter().collect());
        assert_eq!(events.len(), 1);
        assert_eq!(events[0].kind, ZoneEventKind::Enter);
        assert_eq!(events[0].zone_id, 2);
    }

    #[test]
    fn try_set_circle_rejects_negative_radius() {
        let mut zone = PhysicsZone::try_new_rect(0, 0.0, 0.0, 10.0, 10.0).unwrap();
        let err = zone.try_set_circle(0.0, 0.0, -1.0).unwrap_err();
        assert!(err.to_string().contains("radius"));
    }
}
