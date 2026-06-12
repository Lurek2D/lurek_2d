use lurek2d::ai::{MCTSConfig, MCTSEngine, SteeringManager};

fn near(a: f32, b: f32) {
    assert!((a - b).abs() < 0.001, "expected {a} near {b}");
}

fn flock_manager(use_spatial_hash: bool) -> SteeringManager {
    let mut manager = SteeringManager::new();
    manager.set_use_spatial_hash(use_spatial_hash);
    manager.set_cell_size(8.0);
    manager.add_flock(12.0, 1.0, 0.5, 0.75, 1.0);
    manager.set_entity("a".to_string(), (3.0, 0.0), (1.0, 0.0));
    manager.set_entity("b".to_string(), (0.0, 4.0), (0.0, 1.0));
    manager.set_entity("far".to_string(), (100.0, 100.0), (0.0, 0.0));
    manager
}

#[test]
fn pursue_uses_named_entity_prediction() {
    let mut manager = SteeringManager::new();
    manager.set_entity("target".to_string(), (10.0, 0.0), (2.0, 0.0));
    manager.add_pursue(Some("target".to_string()), 1.0);

    let (fx, fy) = manager.calculate((0.0, 0.0), (0.0, 0.0), 10.0, 100.0, 1.0);

    assert!(fx > 0.0, "pursue should steer toward the target");
    near(fy, 0.0);
}

#[test]
fn evade_uses_named_entity_prediction() {
    let mut manager = SteeringManager::new();
    manager.set_entity("threat".to_string(), (10.0, 0.0), (-1.0, 0.0));
    manager.add_evade(Some("threat".to_string()), 1.0);

    let (fx, fy) = manager.calculate((0.0, 0.0), (0.0, 0.0), 10.0, 100.0, 1.0);

    assert!(fx < 0.0, "evade should steer away from the threat");
    near(fy, 0.0);
}

#[test]
fn flock_uses_neighbor_context() {
    let mut manager = flock_manager(false);

    let (fx, fy) = manager.calculate((0.0, 0.0), (0.0, 0.0), 10.0, 100.0, 1.0);

    assert!(fx.is_finite());
    assert!(fy.is_finite());
    assert!(fx.abs() > 0.001 || fy.abs() > 0.001);
}

#[test]
fn flock_spatial_hash_matches_linear_scan() {
    let mut linear = flock_manager(false);
    let mut hashed = flock_manager(true);

    let direct = linear.calculate((0.0, 0.0), (0.0, 0.0), 10.0, 100.0, 1.0);
    let spatial = hashed.calculate((0.0, 0.0), (0.0, 0.0), 10.0, 100.0, 1.0);

    near(direct.0, spatial.0);
    near(direct.1, spatial.1);
}

#[test]
fn entity_store_reports_mutations() {
    let mut manager = SteeringManager::new();
    manager.set_entity("one".to_string(), (0.0, 0.0), (0.0, 0.0));
    assert_eq!(manager.entity_count(), 1);
    assert!(manager.remove_entity("one"));
    assert!(!manager.remove_entity("missing"));
    manager.set_entity("two".to_string(), (1.0, 1.0), (0.0, 0.0));
    manager.clear_entities();
    assert_eq!(manager.entity_count(), 0);
}

#[test]
fn mcts_empty_action_space_returns_none() {
    let mut engine = MCTSEngine::new(MCTSConfig {
        iterations: 4,
        ..MCTSConfig::default()
    });

    let result = engine.search(0, &mut |_| Vec::new(), &mut |state, _| *state, &mut |_| 0.0);

    assert_eq!(result, None);
}
