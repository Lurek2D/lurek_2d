use lurek2d::ai::{
    BehaviorTree, BTNode, GOAPPlanner, MCTSConfig, MCTSEngine, PlanFailureReason, SteeringManager,
    UtilityAI,
};
use mlua::Lua;

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

#[test]
fn utility_ai_considerations_affect_score() {
    let lua = Lua::new();
    let mut ai = UtilityAI::new();
    let attack = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(0.9f64)).unwrap())
        .unwrap();
    let heal = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(0.8f64)).unwrap())
        .unwrap();
    ai.add_action("attack".to_string(), attack, 1.0).unwrap();
    ai.add_action("heal".to_string(), heal, 1.0).unwrap();
    let heal_consideration = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(1.0f64)).unwrap())
        .unwrap();
    let attack_consideration = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(0.1f64)).unwrap())
        .unwrap();
    ai.add_consideration(
        "heal",
        "low_health".to_string(),
        heal_consideration,
        "linear",
        1.0,
        0.0,
        0.0,
        1.0,
    )
    .unwrap();
    ai.add_consideration(
        "attack",
        "safe_window".to_string(),
        attack_consideration,
        "linear",
        1.0,
        0.0,
        0.0,
        1.0,
    )
    .unwrap();

    let chosen = ai.evaluate(&lua).unwrap();

    assert_eq!(chosen.as_deref(), Some("heal"));
    assert_eq!(ai.last_trace.chosen_action.as_deref(), Some("heal"));
    assert_eq!(ai.last_trace.actions[0].considerations.len(), 1);
    assert_eq!(ai.last_trace.actions[1].considerations.len(), 1);
}

#[test]
fn utility_ai_rejects_nan_score() {
    let lua = Lua::new();
    let mut ai = UtilityAI::new();
    let bad = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(f64::NAN)).unwrap())
        .unwrap();
    let good = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(0.4f64)).unwrap())
        .unwrap();
    ai.add_action("bad".to_string(), bad, 1.0).unwrap();
    ai.add_action("good".to_string(), good, 1.0).unwrap();

    let chosen = ai.evaluate(&lua).unwrap();

    assert_eq!(chosen.as_deref(), Some("good"));
    assert!(ai.last_trace.actions.iter().any(|entry| entry.invalid_scorer));
}

#[test]
fn steering_arrive_zero_radius_no_nan() {
    let mut manager = SteeringManager::new();
    manager.add_arrive(10.0, 0.0, 0.0, 1.0);

    let (fx, fy) = manager.calculate((0.0, 0.0), (0.0, 0.0), 5.0, 10.0, 0.016);

    assert!(fx.is_finite());
    assert!(fy.is_finite());
    near(fx, 0.0);
    near(fy, 0.0);
}

#[test]
fn goap_rejects_nan_priority_and_cost() {
    let mut planner = GOAPPlanner::new();

    let cost_err = planner.add_action("bad".to_string(), f64::NAN, None);
    let priority_err = planner.add_goal("goal".to_string(), f64::NAN);

    assert!(cost_err.is_err());
    assert!(priority_err.is_err());
}

#[test]
fn goap_budget_returns_failure_reason() {
    let mut planner = GOAPPlanner::new();
    planner.set_max_iterations(1);
    planner
        .add_action("get_axe".to_string(), 1.0, None)
        .unwrap();
    planner.add_effect("get_axe", "has_axe".to_string(), true);
    planner
        .add_action("chop".to_string(), 1.0, None)
        .unwrap();
    planner.add_precondition("chop", "has_axe".to_string(), true);
    planner.add_effect("chop", "has_wood".to_string(), true);
    planner
        .add_action("build".to_string(), 1.0, None)
        .unwrap();
    planner.add_precondition("build", "has_wood".to_string(), true);
    planner.add_effect("build", "has_house".to_string(), true);
    planner.add_goal("house".to_string(), 1.0).unwrap();
    planner.set_goal_state("house", "has_house".to_string(), true);

    let plan = planner.plan(
        &std::collections::HashMap::from([
            ("has_axe".to_string(), false),
            ("has_wood".to_string(), false),
            ("has_house".to_string(), false),
        ]),
        8,
    );

    assert!(plan.is_empty());
    assert_eq!(planner.last_failure_reason, Some(PlanFailureReason::BudgetExhausted));
    assert_eq!(
        planner.last_trace.failure_reason.as_deref(),
        Some("budget_exhausted")
    );
}

#[test]
fn bt_deep_tree_depth_limit() {
    let mut node = BTNode::Sequence {
        children: Vec::new(),
        running_idx: 0,
    };
    for _ in 0..130 {
        node = BTNode::Sequence {
            children: vec![node],
            running_idx: 0,
        };
    }
    let mut tree = BehaviorTree::new();

    let result = tree.set_root_checked(node);

    assert!(result.is_err());
}

#[test]
fn mcts_invalid_config_rejected() {
    let config = MCTSConfig {
        iterations: 20_000,
        ..MCTSConfig::default()
    };

    let result = MCTSEngine::try_new(config);

    assert!(result.is_err());
}

#[test]
fn mcts_nan_score_policy() {
    let mut engine = MCTSEngine::try_new(MCTSConfig {
        iterations: 8,
        rollout_depth: 4,
        ..MCTSConfig::default()
    })
    .unwrap();

    let chosen = engine.search(
        0i32,
        &mut |_| vec![1, 2],
        &mut |state, action| *state + action,
        &mut |_| f32::NAN,
    );

    assert!(chosen.is_some());
    assert!(engine.last_trace.invalid_score_count > 0);
}
