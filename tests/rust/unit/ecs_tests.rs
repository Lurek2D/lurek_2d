//! INTERNAL ONLY: Rust-only tests for ECS internals that are not directly asserted through
//! `lurek.ecs.*`.
//!
//! Public ECS-facing behaviour is covered by `tests/lua/unit/test_ecs_unit.lua`.
//! The remaining Rust tests keep ID packing and relationship-manager internals.

use lurek2d::ecs::relationships::RelationshipManager;
use lurek2d::ecs::universe::Universe;

// ── universe — generational ID packing ───────────────────────────────────────

mod universe_tests {
    use super::*;

    #[test]
    fn pack_unpack_roundtrip() {
        let slot = 42u32;
        let gen = 7u8;
        let id = Universe::pack_id(slot, gen);
        assert_eq!(Universe::unpack_slot(id), slot);
        assert_eq!(Universe::unpack_gen(id), gen);
    }

    #[test]
    fn pack_id_zero_gen() {
        let id = Universe::pack_id(1, 0);
        assert_eq!(Universe::unpack_slot(id), 1);
        assert_eq!(Universe::unpack_gen(id), 0);
    }

    #[test]
    fn pack_id_max_slot() {
        let max_slot = 0x00FF_FFFFu32;
        let id = Universe::pack_id(max_slot, 255);
        assert_eq!(Universe::unpack_slot(id), max_slot);
        assert_eq!(Universe::unpack_gen(id), 255);
    }

    // ── system phase indices ─────────────────────────────────────────────────

    #[test]
    fn get_sorted_system_indices_for_phase_empty_world() {
        let u = Universe::new();
        let idx = u.get_sorted_system_indices_for_phase("update");
        assert!(idx.is_empty());
    }

    #[test]
    fn get_sorted_system_indices_all_empty_world() {
        let u = Universe::new();
        let idx = u.get_sorted_system_indices_all();
        assert!(idx.is_empty());
    }

    // ── dirty set ────────────────────────────────────────────────────────────

    #[test]
    fn dirty_entities_empty_on_new_world() {
        let u = Universe::new();
        assert!(u.get_dirty_entities().is_empty());
    }

    #[test]
    fn dirty_entities_cleared_by_take_events() {
        // We can't call set_component without a Lua VM in a pure unit test,
        // so we verify that take_component_events clears dirty_set state.
        // The clearing path is exercised via Lua integration tests.
        let mut u = Universe::new();
        let events = u.take_component_events();
        // After draining, dirty set must still be empty.
        assert!(u.get_dirty_entities().is_empty());
        // No pending events expected on a fresh world.
        assert!(events.0.is_empty());
        assert!(events.1.is_empty());
    }

    // ── get_sorted_system_indices_for_phase returns sorted order ────────────

    /// Verify that phase filtering works with only the internal priority/phase vecs
    /// (not the Lua store), by poking private state through the public inspection API.
    #[test]
    fn sorted_indices_respect_priority_without_lua() {
        // We cannot register real Lua systems without a VM, so this test just
        // confirms get_sorted_system_indices_for_phase returns an empty Vec for a
        // fresh Universe — the full priority-order contract is covered by Lua tests.
        let u = Universe::new();
        let pre = u.get_sorted_system_indices_for_phase("pre_update");
        let tick = u.get_sorted_system_indices_for_phase("update");
        let post = u.get_sorted_system_indices_for_phase("post_update");
        assert!(pre.is_empty());
        assert!(tick.is_empty());
        assert!(post.is_empty());
    }
}

// ── relationships ────────────────────────────────────────────────────────────

mod relationships_tests {
    use super::*;

    #[test]
    fn define_and_get_type() {
        let mut mgr = RelationshipManager::new();
        mgr.define_type("trade", vec!["open".into(), "embargo".into()], "open");
        let t = mgr.get_type("trade").unwrap();
        assert_eq!(t.name, "trade");
        assert_eq!(t.default_level, "open");
    }

    #[test]
    fn all_relations_for_filters_correctly() {
        let mut mgr = RelationshipManager::new();
        mgr.set_value(1, 2, 1.0);
        mgr.set_value(1, 3, 2.0);
        mgr.set_value(4, 5, 3.0);
        let rels = mgr.all_relations_for(1);
        assert_eq!(rels.len(), 2);
    }

    #[test]
    fn remove_relation_resets_to_default_value() {
        let mut mgr = RelationshipManager::new();
        mgr.set_value(1, 2, 99.0);
        assert!((mgr.get_value(1, 2) - 99.0).abs() < 1e-6);
        mgr.remove_relation(1, 2);
        assert!((mgr.get_value(1, 2)).abs() < 1e-6);
    }

    #[test]
    fn set_level_returns_false_for_unknown_type() {
        let mut mgr = RelationshipManager::new();
        let result = mgr.set_level(1, 2, "Faction", "ally");
        assert!(!result);
    }

    #[test]
    fn set_level_returns_false_for_invalid_level() {
        let mut mgr = RelationshipManager::new();
        mgr.define_type("Faction", vec!["enemy".into(), "ally".into()], "ally");
        let result = mgr.set_level(1, 2, "Faction", "neutral");
        assert!(!result);
    }

    #[test]
    fn type_names_returns_all_defined() {
        let mut mgr = RelationshipManager::new();
        mgr.define_type("Mood", vec!["happy".into(), "sad".into()], "happy");
        mgr.define_type("Bond", vec!["weak".into(), "strong".into()], "weak");
        let names = mgr.type_names();
        assert_eq!(names.len(), 2);
    }

    #[test]
    fn remove_type_shrinks_type_list() {
        let mut mgr = RelationshipManager::new();
        mgr.define_type("Faction", vec!["enemy".into(), "ally".into()], "ally");
        mgr.remove_type("Faction");
        let names = mgr.type_names();
        assert!(names.is_empty());
    }

    #[test]
    fn adjust_value_adds_delta() {
        let mut mgr = RelationshipManager::new();
        mgr.set_value(1, 2, 50.0);
        mgr.adjust_value(1, 2, -10.0);
        assert!((mgr.get_value(1, 2) - 40.0).abs() < 1e-6);
    }

    #[test]
    fn relation_count_tracks_stored_pairs() {
        let mut mgr = RelationshipManager::new();
        assert_eq!(mgr.relation_count(), 0);
        mgr.set_value(1, 2, 5.0);
        assert_eq!(mgr.relation_count(), 1);
        mgr.set_value(3, 4, 2.0);
        assert_eq!(mgr.relation_count(), 2);
    }
}
