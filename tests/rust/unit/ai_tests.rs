use lurek2d::ai::{
    AIWorld, AgentStance, BTNode, BehaviorTree, CommandQueue, DecisionBiasSet,
    FormationFallbackMode, FormationSortMode, FormationType, GOAPPlanner, MCTSConfig, MCTSEngine,
    PlanFailureReason, SpatialQueryOptions, Squad, SquadMemberProfile, TraitArchetypes,
    TraitProfile, UtilityAI,
};
use lurek2d::pathfind::SteeringManager;
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
fn trait_archetypes_create_builtin_and_custom_profiles() {
    let mut archetypes = TraitArchetypes::with_builtins();
    archetypes.register(
        "naval_raider",
        std::collections::HashMap::from([
            ("aggression".to_string(), 0.8),
            ("naval_focus".to_string(), 1.2),
        ]),
    );

    let profile = TraitProfile::from_archetype(&archetypes, "naval_raider", 0.0).unwrap();

    assert!(archetypes.count() >= 11);
    assert_eq!(profile.archetype(), Some("naval_raider"));
    near(profile.get("aggression"), 0.8);
    near(profile.get("naval_focus"), 1.0);
}

#[test]
fn decision_bias_set_scores_open_decision_keys() {
    let mut profile = TraitProfile::new();
    profile.set("aggression", 0.8);
    profile.set("caution", 0.2);
    let mut biases = DecisionBiasSet::new();
    biases.add_rule("aggression", "attack", 0.4, "add");
    biases.add_rule("caution", "attack", -0.2, "add");
    biases.add_rule("aggression", "raid", 0.5, "multiply");

    near(biases.score_decision(&profile, "attack", 0.4), 0.68);
    near(biases.score_decision(&profile, "defend", 0.4), 0.4);
    near(biases.score_decision(&profile, "raid", 0.5), 0.7);
}

#[test]
fn ai_world_update_ticks_agent_trait_modifiers() {
    let mut world = AIWorld::new();
    world.add_agent("commander").unwrap();
    let agent = world.agent_mut("commander").unwrap();
    agent.trait_profile = Some(TraitProfile::new());
    agent.trait_profile.as_mut().unwrap().set("caution", 0.4);
    agent
        .trait_profile
        .as_mut()
        .unwrap()
        .add_modifier("caution", 0.5, Some(1.0), "panic");

    world.update(2.0);

    let profile = world
        .agent("commander")
        .unwrap()
        .trait_profile
        .as_ref()
        .unwrap();
    near(profile.get("caution"), 0.4);
}

#[test]
fn command_queue_tracks_snapshots_and_lifecycle_events() {
    let lua = Lua::new();
    let callback = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(())).unwrap())
        .unwrap();
    let mut queue = CommandQueue::new();

    let enqueued_id = queue.enqueue_raw("move".to_string(), 10.0, 20.0, 3, true, Some(callback));
    let current = queue.current().unwrap();

    assert_eq!(enqueued_id, current.id);
    assert_eq!(current.kind, "move");
    near(current.target_x, 10.0);
    near(current.target_y, 20.0);
    assert_eq!(queue.pending().len(), 1);

    let events = queue.drain_events();
    assert_eq!(events.len(), 1);
    assert_eq!(events[0].command_id, enqueued_id);
    assert_eq!(events[0].event, "enqueued");

    assert_eq!(
        queue.complete_current(Some("reached_goal".to_string())),
        Some(enqueued_id)
    );
    let events = queue.drain_events();
    assert_eq!(events.len(), 1);
    assert_eq!(events[0].command_id, enqueued_id);
    assert_eq!(events[0].event, "completed");
    assert_eq!(events[0].detail.as_deref(), Some("reached_goal"));
    assert!(queue.current().is_none());
}

#[test]
fn ai_world_agents_keep_independent_command_queues() {
    let lua = Lua::new();
    let callback_a = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(())).unwrap())
        .unwrap();
    let callback_b = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(())).unwrap())
        .unwrap();
    let mut world = AIWorld::new();
    world.add_agent("alpha").unwrap();
    world.add_agent("beta").unwrap();

    let alpha_id = world.agent_mut("alpha").unwrap().command_queue.enqueue_raw(
        "move".to_string(),
        1.0,
        2.0,
        1,
        true,
        Some(callback_a),
    );
    let beta_id = world.agent_mut("beta").unwrap().command_queue.enqueue_raw(
        "guard".to_string(),
        5.0,
        6.0,
        2,
        false,
        Some(callback_b),
    );

    assert_eq!(
        world.agent("alpha").unwrap().command_queue.current_id(),
        Some(alpha_id)
    );
    assert_eq!(
        world.agent("beta").unwrap().command_queue.current_id(),
        Some(beta_id)
    );
    assert_eq!(
        world.agent("alpha").unwrap().command_queue.current_type(),
        Some("move")
    );
    assert_eq!(
        world.agent("beta").unwrap().command_queue.current_type(),
        Some("guard")
    );
}

#[test]
fn ai_world_spatial_query_filters_and_limits_nearby_agents() {
    let mut world = AIWorld::new();
    world.set_spatial_cell_size(16.0);
    world.add_agent("alpha").unwrap();
    world.add_agent("beta").unwrap();
    world.add_agent("gamma").unwrap();
    {
        let alpha = world.agent_mut("alpha").unwrap();
        alpha.position = (0.0, 0.0);
        alpha.team = 1;
    }
    {
        let beta = world.agent_mut("beta").unwrap();
        beta.position = (8.0, 0.0);
        beta.team = 2;
        beta.tags.insert("hostile".to_string());
    }
    {
        let gamma = world.agent_mut("gamma").unwrap();
        gamma.position = (10.0, 0.0);
        gamma.team = 2;
        gamma.tags.insert("hidden".to_string());
    }
    world.mark_spatial_dirty();

    let names = world.query_agents_in_radius(
        (0.0, 0.0),
        32.0,
        SpatialQueryOptions {
            exclude_name: Some("alpha"),
            hostile_to_team: Some(1),
            limit: Some(1),
            required_tag: Some("hostile"),
            blocked_tag: Some("hidden"),
            ..SpatialQueryOptions::default()
        },
    );

    assert_eq!(names, vec!["beta".to_string()]);
    assert_eq!(world.spatial_query_stats().returned_agents, 1);
    assert!(world.spatial_query_stats().candidate_checks >= 2);
}

#[test]
fn stance_driven_acquisition_uses_built_in_profile_defaults() {
    let mut world = AIWorld::new();
    world.set_spatial_cell_size(16.0);
    world.add_agent("scout").unwrap();
    world.add_agent("enemy_near").unwrap();
    world.add_agent("enemy_far").unwrap();
    {
        let scout = world.agent_mut("scout").unwrap();
        scout.team = 1;
        scout.position = (0.0, 0.0);
        scout.stance = AgentStance::Passive.default_profile();
    }
    {
        let enemy_near = world.agent_mut("enemy_near").unwrap();
        enemy_near.team = 2;
        enemy_near.position = (40.0, 0.0);
    }
    {
        let enemy_far = world.agent_mut("enemy_far").unwrap();
        enemy_far.team = 2;
        enemy_far.position = (260.0, 0.0);
    }
    world.mark_spatial_dirty();
    assert_eq!(
        world.acquire_target_for_agent("scout", None, Some(8), None, None),
        None
    );

    world.agent_mut("scout").unwrap().stance = AgentStance::Aggressive.default_profile();
    let aggressive_target = world.acquire_target_for_agent("scout", None, Some(8), None, None);
    assert_eq!(aggressive_target.as_deref(), Some("enemy_near"));
}

#[test]
fn ai_world_update_executes_move_orders_and_reports_runtime_stats() {
    let lua = Lua::new();
    let callback = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(())).unwrap())
        .unwrap();
    let mut world = AIWorld::new();
    world.set_order_arrival_radius(0.5);
    world.add_agent("runner").unwrap();
    {
        let runner = world.agent_mut("runner").unwrap();
        runner.max_speed = 10.0;
        runner
            .command_queue
            .enqueue_raw("move".to_string(), 10.0, 0.0, 0, true, Some(callback));
    }

    world.update(1.0);

    let runner = world.agent("runner").unwrap();
    near(runner.position.0, 10.0);
    near(runner.position.1, 0.0);
    assert!(runner.command_queue.current().is_none());
    assert_eq!(world.order_runtime_stats().move_orders_completed, 1);
}

#[test]
fn ai_world_soft_interrupts_and_resumes_move_orders_from_stance_updates() {
    let lua = Lua::new();
    let callback = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(())).unwrap())
        .unwrap();
    let mut world = AIWorld::new();
    world.set_spatial_cell_size(16.0);
    world.set_auto_acquire_budget(8);
    world.add_agent("hero").unwrap();
    world.add_agent("enemy").unwrap();
    {
        let hero = world.agent_mut("hero").unwrap();
        hero.team = 1;
        hero.position = (0.0, 0.0);
        hero.max_speed = 12.0;
        hero.stance = AgentStance::Aggressive.default_profile();
        hero.stance.acquire_radius = 64.0;
        hero.stance.chase_radius = 24.0;
        hero.command_queue
            .enqueue_raw("move".to_string(), 100.0, 0.0, 0, true, Some(callback));
    }
    {
        let enemy = world.agent_mut("enemy").unwrap();
        enemy.team = 2;
        enemy.position = (8.0, 0.0);
    }
    world.mark_spatial_dirty();

    world.update(0.1);

    let hero = world.agent("hero").unwrap();
    assert_eq!(hero.order_runtime.engage_target.as_deref(), Some("enemy"));
    assert_eq!(
        hero.order_runtime.suspended_order_id,
        hero.command_queue.current_id()
    );
    assert_eq!(world.order_runtime_stats().soft_interrupts, 1);
    let events = world
        .agent_mut("hero")
        .unwrap()
        .command_queue
        .drain_events();
    assert!(events.iter().any(|event| event.event == "interrupted"));

    world.agent_mut("enemy").unwrap().position = (80.0, 0.0);
    world.mark_spatial_dirty();
    world.update(0.1);

    let hero = world.agent("hero").unwrap();
    assert_eq!(hero.order_runtime.engage_target, None);
    assert_eq!(world.order_runtime_stats().resumed_orders, 1);
    let events = world
        .agent_mut("hero")
        .unwrap()
        .command_queue
        .drain_events();
    assert!(events.iter().any(|event| event.event == "resumed"));
}

#[test]
fn ai_world_auto_acquire_budget_spreads_queries_across_updates() {
    let mut world = AIWorld::new();
    world.set_spatial_cell_size(16.0);
    world.set_auto_acquire_budget(1);
    for name in ["alpha", "beta", "enemy_a", "enemy_b"] {
        world.add_agent(name).unwrap();
    }
    {
        let alpha = world.agent_mut("alpha").unwrap();
        alpha.team = 1;
        alpha.position = (0.0, 0.0);
        alpha.stance = AgentStance::Aggressive.default_profile();
    }
    {
        let beta = world.agent_mut("beta").unwrap();
        beta.team = 1;
        beta.position = (32.0, 0.0);
        beta.stance = AgentStance::Aggressive.default_profile();
    }
    {
        let enemy_a = world.agent_mut("enemy_a").unwrap();
        enemy_a.team = 2;
        enemy_a.position = (8.0, 0.0);
        enemy_a.stance = AgentStance::Passive.default_profile();
    }
    {
        let enemy_b = world.agent_mut("enemy_b").unwrap();
        enemy_b.team = 2;
        enemy_b.position = (40.0, 0.0);
        enemy_b.stance = AgentStance::Passive.default_profile();
    }
    world.mark_spatial_dirty();

    world.update(0.1);

    assert_eq!(world.order_runtime_stats().acquire_queries, 1);
    assert_eq!(world.order_runtime_stats().budget_skips, 1);
    let engaged_after_first = ["alpha", "beta"]
        .into_iter()
        .filter(|name| {
            world
                .agent(name)
                .unwrap()
                .order_runtime
                .engage_target
                .is_some()
        })
        .count();
    assert_eq!(engaged_after_first, 1);

    world.update(0.1);

    let engaged_after_second = ["alpha", "beta"]
        .into_iter()
        .filter(|name| {
            world
                .agent(name)
                .unwrap()
                .order_runtime
                .engage_target
                .is_some()
        })
        .count();
    assert_eq!(engaged_after_second, 2);
}

#[test]
fn squad_layout_falls_back_to_column_when_lane_is_too_narrow() {
    let mut squad = Squad::new("armor");
    squad.add_member("tank_a");
    squad.add_member("tank_b");
    squad.add_member("tank_c");
    squad.set_formation(FormationType::Line, Some(10.0));
    squad.set_formation_behavior(
        FormationSortMode::Roster,
        FormationFallbackMode::Column,
        false,
    );
    squad.set_member_profile(
        "tank_a",
        SquadMemberProfile {
            footprint_w: 4,
            footprint_h: 4,
            subgroup: None,
            ..SquadMemberProfile::default()
        },
    );

    let layout = squad.get_formation_layout((0.0, 0.0), Some(20.0), None);

    assert_eq!(layout.requested_formation, FormationType::Line);
    assert_eq!(layout.active_formation, FormationType::Column);
    assert!(layout.fallback_applied);
    assert_eq!(layout.slots.len(), 3);
    assert!(layout.height >= layout.width);
}

#[test]
fn squad_distance_sort_keeps_subgroups_clustered() {
    let mut squad = Squad::new("formation");
    squad.add_member("beta_1");
    squad.add_member("alpha_1");
    squad.add_member("beta_2");
    squad.add_member("alpha_2");
    squad.set_formation(FormationType::Line, Some(10.0));
    squad.set_formation_behavior(
        FormationSortMode::Distance,
        FormationFallbackMode::Keep,
        true,
    );
    squad.set_member_profile(
        "beta_1",
        SquadMemberProfile {
            footprint_w: 1,
            footprint_h: 1,
            subgroup: Some("beta".to_string()),
            ..SquadMemberProfile::default()
        },
    );
    squad.set_member_profile(
        "beta_2",
        SquadMemberProfile {
            footprint_w: 1,
            footprint_h: 1,
            subgroup: Some("beta".to_string()),
            ..SquadMemberProfile::default()
        },
    );
    squad.set_member_profile(
        "alpha_1",
        SquadMemberProfile {
            footprint_w: 1,
            footprint_h: 1,
            subgroup: Some("alpha".to_string()),
            ..SquadMemberProfile::default()
        },
    );
    squad.set_member_profile(
        "alpha_2",
        SquadMemberProfile {
            footprint_w: 1,
            footprint_h: 1,
            subgroup: Some("alpha".to_string()),
            ..SquadMemberProfile::default()
        },
    );
    let positions = std::collections::HashMap::from([
        ("beta_1".to_string(), (-50.0, 0.0)),
        ("beta_2".to_string(), (-40.0, 0.0)),
        ("alpha_1".to_string(), (40.0, 0.0)),
        ("alpha_2".to_string(), (50.0, 0.0)),
    ]);

    let layout = squad.get_formation_layout((0.0, 0.0), None, Some(&positions));

    assert_eq!(layout.slots.len(), 4);
    assert_eq!(layout.slots[0].subgroup.as_deref(), Some("beta"));
    assert_eq!(layout.slots[1].subgroup.as_deref(), Some("beta"));
    assert_eq!(layout.slots[2].subgroup.as_deref(), Some("alpha"));
    assert_eq!(layout.slots[3].subgroup.as_deref(), Some("alpha"));
}

#[test]
fn squad_layout_cache_reuses_matching_requests() {
    let mut squad = Squad::new("cache");
    squad.add_member("alpha");
    squad.add_member("beta");
    squad.set_formation(FormationType::Line, Some(10.0));

    let first = squad.get_formation_layout((0.0, 0.0), Some(40.0), None);
    assert_eq!(2, first.slots.len());
    assert_eq!(0, squad.layout_cache_hits());
    assert_eq!(1, squad.layout_cache_misses());

    let second = squad.get_formation_layout((0.0, 0.0), Some(40.0), None);
    assert_eq!(first, second);
    assert_eq!(1, squad.layout_cache_hits());
    assert_eq!(1, squad.layout_cache_misses());
}

#[test]
fn utility_ai_profile_bias_can_change_winning_action() {
    let lua = Lua::new();
    let mut ai = UtilityAI::new();
    let attack = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(0.4f64)).unwrap())
        .unwrap();
    let defend = lua
        .create_registry_value(lua.create_function(|_, ()| Ok(0.5f64)).unwrap())
        .unwrap();
    ai.add_action("attack".to_string(), attack, 1.0).unwrap();
    ai.add_action("defend".to_string(), defend, 1.0).unwrap();
    let mut profile = TraitProfile::new();
    profile.set("aggression", 0.8);
    let mut biases = DecisionBiasSet::new();
    biases.add_rule("aggression", "attack", 0.3, "add");

    let chosen = ai.evaluate_with_profile(&lua, &profile, &biases).unwrap();

    assert_eq!(chosen.as_deref(), Some("attack"));
    assert_eq!(ai.last_trace.chosen_action.as_deref(), Some("attack"));
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
    assert!(ai
        .last_trace
        .actions
        .iter()
        .any(|entry| entry.invalid_scorer));
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
    planner.add_action("chop".to_string(), 1.0, None).unwrap();
    planner.add_precondition("chop", "has_axe".to_string(), true);
    planner.add_effect("chop", "has_wood".to_string(), true);
    planner.add_action("build".to_string(), 1.0, None).unwrap();
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
    assert_eq!(
        planner.last_failure_reason,
        Some(PlanFailureReason::BudgetExhausted)
    );
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
