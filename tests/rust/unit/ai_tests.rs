//! Tests for the ai module.

// ── agent ─────────────────────────────────────────────────────────────────────

mod agent_tests {
    use lurek2d::ai::agent::{Agent, DecisionModel};

    #[test]
    fn decision_model_parse_round_trip() {
        for &s in &["fsm", "bt", "steering", "fsm+steering", "bt+steering"] {
            let dm = DecisionModel::parse_str(s).unwrap();
            assert_eq!(dm.as_str(), s);
        }
    }

    #[test]
    fn decision_model_unknown_returns_none() {
        assert!(DecisionModel::parse_str("bogus").is_none());
    }

    #[test]
    fn agent_new_defaults() {
        let a = Agent::new("test", 0);
        assert_eq!(a.name, "test");
        assert_eq!(a.position, (0.0, 0.0));
        assert_eq!(a.velocity, (0.0, 0.0));
        assert_eq!(a.decision_model, DecisionModel::Fsm);
    }
}

// ── bandit ────────────────────────────────────────────────────────────────────

mod bandit_tests {
    use lurek2d::ai::bandit::Bandit;

    #[test]
    fn new_bandit_defaults() {
        let b = Bandit::new(3, 42);
        assert_eq!(b.arm_count(), 3);
        assert_eq!(b.total_pulls(), 0);
    }

    #[test]
    fn select_returns_valid_arm() {
        let mut b = Bandit::new(4, 42);
        let arm = b.select();
        assert!(arm < 4);
    }

    #[test]
    fn update_tracks_reward() {
        let mut b = Bandit::new(2, 42);
        b.update(0, 1.0);
        assert_eq!(b.total_pulls(), 1);
        assert!(b.mean_reward(0) > 0.0);
    }

    #[test]
    fn best_arm_picks_highest() {
        let mut b = Bandit::new(3, 42);
        b.update(0, 0.5);
        b.update(1, 2.0);
        b.update(2, 0.1);
        assert_eq!(b.best_arm(), 1);
    }

    #[test]
    fn ucb1_score_valid() {
        let mut b = Bandit::new(2, 42);
        b.update(0, 1.0);
        b.update(1, 0.5);
        let s0 = b.ucb1_score(0);
        let s1 = b.ucb1_score(1);
        assert!(s0.is_finite());
        assert!(s1.is_finite());
    }
}

// ── behavior_tree ─────────────────────────────────────────────────────────────

mod behavior_tree_tests {
    use lurek2d::ai::behavior_tree::{BehaviorTree, BTStatus, ParallelPolicy};

    #[test]
    fn bt_status_conversions() {
        assert_eq!(BTStatus::Success.as_str(), "success");
        assert_eq!(BTStatus::Failure.as_str(), "failure");
        assert_eq!(BTStatus::Running.as_str(), "running");
    }

    #[test]
    fn parallel_policy_parse() {
        assert_eq!(ParallelPolicy::from_str("require_all"), ParallelPolicy::RequireAll);
        assert_eq!(ParallelPolicy::from_str("require_one"), ParallelPolicy::RequireOne);
        assert_eq!(ParallelPolicy::from_str("unknown"), ParallelPolicy::RequireAll);
    }

    #[test]
    fn new_tree_has_no_root() {
        let bt = BehaviorTree::new();
        assert!(bt.root.is_none());
        let state = bt.debug_state();
        assert_eq!(state.node_count, 0);
    }
}

// ── blackboard ────────────────────────────────────────────────────────────────

mod blackboard_tests {
    use lurek2d::ai::blackboard::Blackboard;

    #[test]
    fn set_get_number_roundtrip() {
        let mut bb = Blackboard::new();
        bb.set_number("hp", 100.0);
        let v = bb.get_number("hp", 0.0);
        assert!((v - 100.0).abs() < 1e-10);
    }

    #[test]
    fn missing_number_returns_default() {
        let bb = Blackboard::new();
        assert!((bb.get_number("missing", 42.0) - 42.0).abs() < 1e-10);
    }

    #[test]
    fn set_get_bool_roundtrip() {
        let mut bb = Blackboard::new();
        bb.set_bool("alert", true);
        assert!(bb.get_bool("alert", false));
    }

    #[test]
    fn missing_bool_returns_default() {
        let bb = Blackboard::new();
        assert!(!bb.get_bool("missing", false));
    }

    #[test]
    fn set_get_string_roundtrip() {
        let mut bb = Blackboard::new();
        bb.set_string("state", "attack");
        assert_eq!(bb.get_string("state", ""), "attack");
    }

    #[test]
    fn missing_string_returns_default() {
        let bb = Blackboard::new();
        assert_eq!(bb.get_string("missing", "default"), "default");
    }

    #[test]
    fn has_existing_key_true() {
        let mut bb = Blackboard::new();
        bb.set_number("x", 1.0);
        assert!(bb.has("x"));
    }

    #[test]
    fn has_missing_key_false() {
        let bb = Blackboard::new();
        assert!(!bb.has("none"));
    }

    #[test]
    fn remove_clears_key() {
        let mut bb = Blackboard::new();
        bb.set_number("y", 5.0);
        bb.remove("y");
        assert!(!bb.has("y"));
    }

    #[test]
    fn clear_empties_local_store() {
        let mut bb = Blackboard::new();
        bb.set_number("a", 1.0);
        bb.set_bool("b", true);
        bb.clear();
        assert_eq!(bb.size(), 0);
    }

    #[test]
    fn parent_lookup_reads_parent_value() {
        let mut parent = Blackboard::new();
        parent.set_number("shared", 99.0);
        let mut child = Blackboard::new();
        child.set_parent(parent);
        let v = child.get_number("shared", 0.0);
        assert!((v - 99.0).abs() < 1e-10);
    }
}

// ── command_queue ─────────────────────────────────────────────────────────────

mod command_queue_tests {
    use lurek2d::ai::command_queue::CommandQueue;

    #[test]
    fn new_queue_is_empty() {
        let q = CommandQueue::new();
        assert!(q.is_empty());
        assert_eq!(q.len(), 0);
    }

    #[test]
    fn queue_cleared_after_clear() {
        let mut q = CommandQueue::new();
        q.clear();
        assert!(q.is_empty());
    }
}

// ── context_steering ──────────────────────────────────────────────────────────

mod context_steering_tests {
    use lurek2d::ai::context_steering::{ContextSteering, angle_diff_f32};
    use std::f32::consts::TAU;

    #[test]
    fn new_context_steering_slot_count() {
        let cs = ContextSteering::new(8);
        assert_eq!(cs.slot_count(), 8);
    }

    #[test]
    fn seek_sets_interest() {
        let mut cs = ContextSteering::new(8);
        cs.seek((1.0, 0.0), (0.0, 0.0), 1.0);
        let best = cs.best_direction();
        assert!(best.0 > 0.0, "should point right toward target");
    }

    #[test]
    fn avoid_sets_danger() {
        let mut cs = ContextSteering::new(8);
        cs.seek((1.0, 0.0), (0.0, 0.0), 1.0);
        cs.avoid((0.5, 0.0), (0.0, 0.0), 1.0, 5.0);
        let best = cs.best_direction();
        // danger should steer away from direct path
        assert!(best.1.abs() > 0.01 || best.0 < 0.5);
    }

    #[test]
    fn reset_clears_rings() {
        let mut cs = ContextSteering::new(8);
        cs.seek((1.0, 0.0), (0.0, 0.0), 1.0);
        cs.reset();
        let (dx, dy) = cs.best_direction();
        assert!(dx.abs() < 1e-6 && dy.abs() < 1e-6);
    }

    #[test]
    fn angle_diff_wraps() {
        let d = angle_diff_f32(0.1, TAU - 0.1);
        assert!((d - 0.2).abs() < 1e-3);
    }
}

// ── director ──────────────────────────────────────────────────────────────────

mod director_tests {
    use lurek2d::ai::director::{AIDirector, DirectorPhase};

    #[test]
    fn starts_in_relief_phase() {
        let d = AIDirector::new();
        assert_eq!(d.phase(), DirectorPhase::Relief);
        assert_eq!(d.tension(), 0.0);
    }

    #[test]
    fn push_event_increases_tension() {
        let mut d = AIDirector::new();
        d.push_event(0.5);
        assert!(d.tension() > 0.0);
    }

    #[test]
    fn tension_decays_over_time() {
        let mut d = AIDirector::new();
        d.push_event(0.5);
        let t1 = d.tension();
        d.update(5.0);
        assert!(d.tension() < t1);
    }

    #[test]
    fn phase_string_round_trip() {
        assert_eq!(DirectorPhase::BuildUp.as_str(), "build_up");
        assert_eq!(DirectorPhase::Peak.as_str(), "peak");
        assert_eq!(DirectorPhase::Sustain.as_str(), "sustain");
        assert_eq!(DirectorPhase::Relief.as_str(), "relief");
    }

    #[test]
    fn reset_clears_state() {
        let mut d = AIDirector::new();
        d.push_event(1.0);
        d.update(0.1);
        d.reset();
        assert_eq!(d.tension(), 0.0);
        assert_eq!(d.phase(), DirectorPhase::Relief);
    }
}

// ── emotion ───────────────────────────────────────────────────────────────────

mod emotion_tests {
    use lurek2d::ai::emotion::{Emotion, EmotionModel};

    #[test]
    fn emotion_trigger_and_decay() {
        let mut e = Emotion::new("anger", 0.0, 0.5, 0.1);
        e.trigger(0.8);
        assert!((e.value - 0.8).abs() < 1e-6);
        e.update(1.0);
        assert!((e.value - 0.3).abs() < 1e-6);
    }

    #[test]
    fn emotion_model_dominant() {
        let mut m = EmotionModel::new();
        m.add(Emotion::new("anger", 0.0, 0.5, 0.1));
        m.add(Emotion::new("fear", 0.0, 0.5, 0.1));
        m.trigger("anger", 0.6);
        m.trigger("fear", 0.3);
        assert_eq!(m.dominant(), Some("anger"));
    }

    #[test]
    fn no_dominant_when_below_threshold() {
        let mut m = EmotionModel::new();
        m.add(Emotion::new("joy", 0.0, 0.5, 0.3));
        assert!(m.dominant().is_none());
    }

    #[test]
    fn reset_returns_to_resting() {
        let mut m = EmotionModel::new();
        m.add(Emotion::new("fear", 0.2, 0.5, 0.1));
        m.trigger("fear", 0.8);
        m.reset();
        assert!((m.get("fear") - 0.2).abs() < 1e-6);
    }
}

// ── fsm ───────────────────────────────────────────────────────────────────────

mod fsm_tests {
    use lurek2d::ai::fsm::StateMachine;

    #[test]
    fn new_fsm_has_no_states() {
        let fsm = StateMachine::new();
        assert!(fsm.current_state_name().is_none());
    }

    #[test]
    fn state_count_after_add() {
        let mut fsm = StateMachine::new();
        fsm.add_state("idle".to_string());
        fsm.add_state("walk".to_string());
        assert_eq!(fsm.state_count(), 2);
    }

    #[test]
    fn initial_state_set() {
        let mut fsm = StateMachine::new();
        fsm.add_state("idle".to_string());
        fsm.set_initial_state("idle".to_string());
        assert_eq!(fsm.current_state_name(), Some("idle"));
    }
}

// ── genetic ───────────────────────────────────────────────────────────────────

mod genetic_tests {
    use lurek2d::ai::genetic::GeneticAlgorithm;

    #[test]
    fn population_initialised() {
        let ga = GeneticAlgorithm::new(10, 5, 42);
        assert_eq!(ga.population().len(), 10);
        assert!(ga.population().iter().all(|g| g.genes.len() == 5));
    }

    #[test]
    fn evolve_step_preserves_size() {
        let mut ga = GeneticAlgorithm::new(8, 4, 42);
        let fitnesses: Vec<f64> = (0..8).map(|i| i as f64).collect();
        ga.evolve(&fitnesses, 0.1);
        assert_eq!(ga.population().len(), 8);
    }

    #[test]
    fn best_index_picks_highest() {
        let mut ga = GeneticAlgorithm::new(4, 3, 42);
        let fitnesses = vec![1.0, 5.0, 3.0, 2.0];
        ga.evolve(&fitnesses, 0.0);
        assert_eq!(ga.best_index(&fitnesses), 1);
    }

    #[test]
    fn generation_counter_increments() {
        let mut ga = GeneticAlgorithm::new(4, 2, 42);
        assert_eq!(ga.generation(), 0);
        ga.evolve(&[1.0, 2.0, 3.0, 4.0], 0.1);
        assert_eq!(ga.generation(), 1);
    }
}

// ── goap ──────────────────────────────────────────────────────────────────────

mod goap_tests {
    use lurek2d::ai::goap::GOAPPlanner;

    #[test]
    fn new_planner_defaults() {
        let p = GOAPPlanner::new();
        assert_eq!(p.action_count(), 0);
    }

    #[test]
    fn set_max_iterations() {
        let mut p = GOAPPlanner::new();
        p.set_max_iterations(500);
        assert_eq!(p.max_iterations, 500);
    }
}

// ── htn ───────────────────────────────────────────────────────────────────────

mod htn_tests {
    use lurek2d::ai::htn::{HTNDomain, HTNTask, HTNMethod, HTNPlanner};
    use std::collections::HashMap;

    fn sample_domain() -> HTNDomain {
        let mut d = HTNDomain::new();
        d.add_task(HTNTask::Primitive {
            name: "eat".into(),
            preconditions: vec![("hungry".into(), true)],
            effects: vec![("hungry".into(), false)],
        });
        d.add_task(HTNTask::Compound {
            name: "satisfy_hunger".into(),
            methods: vec![HTNMethod {
                name: "use_eat".into(),
                conditions: vec![("hungry".into(), true)],
                sub_tasks: vec!["eat".into()],
            }],
        });
        d
    }

    #[test]
    fn decompose_single_primitive() {
        let d = sample_domain();
        let mut state = HashMap::new();
        state.insert("hungry".to_string(), true);
        let plan = HTNPlanner::plan(&d, "eat", &state);
        assert!(plan.is_some());
        assert_eq!(plan.unwrap(), vec!["eat"]);
    }

    #[test]
    fn decompose_compound_task() {
        let d = sample_domain();
        let mut state = HashMap::new();
        state.insert("hungry".to_string(), true);
        let plan = HTNPlanner::plan(&d, "satisfy_hunger", &state);
        assert!(plan.is_some());
        assert_eq!(plan.unwrap(), vec!["eat"]);
    }

    #[test]
    fn precondition_not_met_returns_none() {
        let d = sample_domain();
        let state = HashMap::new(); // hungry not set
        let plan = HTNPlanner::plan(&d, "eat", &state);
        assert!(plan.is_none());
    }
}

// ── lod ───────────────────────────────────────────────────────────────────────

mod lod_tests {
    use lurek2d::ai::lod::AILod;

    #[test]
    fn default_has_three_tiers() {
        let lod = AILod::default();
        assert_eq!(lod.tier_count(), 3);
    }

    #[test]
    fn near_agent_tier_zero() {
        let lod = AILod::default();
        assert_eq!(lod.tier_for((100.0, 0.0), (0.0, 0.0)), 0);
    }

    #[test]
    fn far_agent_tier_two() {
        let lod = AILod::default();
        assert_eq!(lod.tier_for((5000.0, 0.0), (0.0, 0.0)), 2);
    }

    #[test]
    fn should_update_tier_zero_always() {
        let lod = AILod::default();
        assert!(lod.should_update(0, 1));
        assert!(lod.should_update(0, 999));
    }

    #[test]
    fn should_update_tier_one_every_4() {
        let lod = AILod::default();
        assert!(lod.should_update(1, 0));
        assert!(!lod.should_update(1, 1));
        assert!(lod.should_update(1, 4));
    }

    #[test]
    fn assign_tiers_batch() {
        let lod = AILod::default();
        let agents = vec![(10.0, 10.0), (500.0, 0.0), (2000.0, 0.0)];
        let tiers = lod.assign_tiers(&agents, (0.0, 0.0));
        assert_eq!(tiers, vec![0, 1, 2]);
    }
}

// ── needs ─────────────────────────────────────────────────────────────────────

mod needs_tests {
    use lurek2d::ai::needs::{Need, NeedSystem};

    #[test]
    fn new_need_defaults() {
        let n = Need::new("hunger", 0.5, 0.1);
        assert_eq!(n.name, "hunger");
        assert!((n.value - 0.5).abs() < 1e-6);
    }

    #[test]
    fn decay_increases_value() {
        let mut n = Need::new("thirst", 0.2, 0.1);
        n.update(1.0);
        assert!(n.value > 0.2);
    }

    #[test]
    fn fulfil_decreases_value() {
        let mut n = Need::new("rest", 0.8, 0.1);
        n.fulfil(0.5);
        assert!((n.value - 0.3).abs() < 1e-6);
    }

    #[test]
    fn value_clamped_0_1() {
        let mut n = Need::new("food", 0.9, 10.0);
        n.update(10.0);
        assert!(n.value <= 1.0);
        n.fulfil(100.0);
        assert!(n.value >= 0.0);
    }

    #[test]
    fn system_get_set() {
        let mut s = NeedSystem::new();
        s.add(Need::new("hunger", 0.0, 0.1));
        assert!(s.get("hunger").is_some());
        assert!(s.get("bogus").is_none());
    }

    #[test]
    fn most_urgent_picks_highest() {
        let mut s = NeedSystem::new();
        s.add(Need::new("hunger", 0.9, 0.1));
        s.add(Need::new("rest", 0.2, 0.1));
        assert_eq!(s.most_urgent().unwrap(), "hunger");
    }
}

// ── neural_net ────────────────────────────────────────────────────────────────

mod neural_net_tests {
    use lurek2d::ai::neural_net::NeuralNet;

    #[test]
    fn single_layer_forward() {
        let nn = NeuralNet::new(&[2, 1]);
        let out = nn.forward(&[1.0, 1.0]);
        assert_eq!(out.len(), 1);
    }

    #[test]
    fn two_layer_forward() {
        let nn = NeuralNet::new(&[3, 4, 2]);
        let out = nn.forward(&[1.0, 0.5, -0.3]);
        assert_eq!(out.len(), 2);
    }

    #[test]
    fn set_from_flat_round_trip() {
        let mut nn = NeuralNet::new(&[2, 2]);
        let flat = nn.to_flat();
        nn.set_from_flat(&flat);
        let flat2 = nn.to_flat();
        assert_eq!(flat, flat2);
    }

    #[test]
    fn layer_count_matches() {
        let nn = NeuralNet::new(&[3, 5, 2]);
        assert_eq!(nn.layer_count(), 2);
    }

    #[test]
    fn output_bounded_by_activation() {
        let nn = NeuralNet::new(&[2, 3]);
        let out = nn.forward(&[100.0, -100.0]);
        for v in &out {
            assert!(*v >= 0.0 && *v <= 1.0, "sigmoid should bound output");
        }
    }
}

// ── neuroevolution ────────────────────────────────────────────────────────────

mod neuroevolution_tests {
    use lurek2d::ai::neuroevolution::NeuroEvolution;

    #[test]
    fn new_pool_creates_population() {
        let ne = NeuroEvolution::new(&[2, 3, 1], 10, 42);
        assert_eq!(ne.population_size(), 10);
    }

    #[test]
    fn evaluate_and_evolve_preserves_size() {
        let mut ne = NeuroEvolution::new(&[2, 1], 6, 42);
        let fitnesses: Vec<f64> = (0..6).map(|i| i as f64).collect();
        ne.evolve(&fitnesses, 0.1);
        assert_eq!(ne.population_size(), 6);
    }
}

// ── orca ──────────────────────────────────────────────────────────────────────

mod orca_tests {
    use lurek2d::ai::orca::{ORCASolver, ORCANeighbour};

    #[test]
    fn no_neighbours_preferred_velocity() {
        let solver = ORCASolver::new();
        let (vx, vy) = solver.compute((0.0, 0.0), (1.0, 0.0), &[], 0.5, 2.0, 1.0);
        assert!((vx - 1.0).abs() < 1e-3);
        assert!(vy.abs() < 1e-3);
    }

    #[test]
    fn single_obstacle_adjusts_velocity() {
        let solver = ORCASolver::new();
        let neighbours = vec![ORCANeighbour {
            position: (1.0, 0.0),
            velocity: (-1.0, 0.0),
            radius: 0.5,
        }];
        let (vx, vy) = solver.compute((0.0, 0.0), (1.0, 0.0), &neighbours, 0.5, 2.0, 1.0);
        let speed = (vx * vx + vy * vy).sqrt();
        assert!(speed <= 2.0 + 1e-3, "speed within max");
    }
}

// ── perception ────────────────────────────────────────────────────────────────

mod perception_tests {
    use lurek2d::ai::perception::{Sensor, SensorContact, angle_diff};

    #[test]
    fn sensor_detects_nearby() {
        let s = Sensor::new(100.0, std::f32::consts::PI);
        let contacts = vec![
            SensorContact { position: (10.0, 0.0), tag: "enemy".into() },
        ];
        let detected = s.detect((0.0, 0.0), 0.0, &contacts);
        assert_eq!(detected.len(), 1);
    }

    #[test]
    fn sensor_ignores_out_of_range() {
        let s = Sensor::new(10.0, std::f32::consts::PI);
        let contacts = vec![
            SensorContact { position: (100.0, 0.0), tag: "far".into() },
        ];
        let detected = s.detect((0.0, 0.0), 0.0, &contacts);
        assert!(detected.is_empty());
    }

    #[test]
    fn sensor_respects_fov() {
        let s = Sensor::new(100.0, 0.1); // narrow FOV
        let contacts = vec![
            SensorContact { position: (0.0, 50.0), tag: "side".into() },
        ];
        // facing right (0 rad) — target is up, outside narrow FOV
        let detected = s.detect((0.0, 0.0), 0.0, &contacts);
        assert!(detected.is_empty());
    }

    #[test]
    fn angle_diff_normalized() {
        let d = angle_diff(0.1, 2.0 * std::f32::consts::PI - 0.1);
        assert!((d - 0.2).abs() < 1e-3);
    }
}

// ── render ────────────────────────────────────────────────────────────────────

mod render_tests {
    use lurek2d::ai::fsm::StateMachine;
    use lurek2d::ai::behavior_tree::BehaviorTree;

    #[test]
    fn fsm_empty_returns_no_commands() {
        let fsm = StateMachine::new();
        assert!(fsm.generate_render_commands().is_empty());
    }

    #[test]
    fn fsm_draw_to_image_correct_dimensions() {
        let fsm = StateMachine::new();
        let img = fsm.draw_to_image(64, 32);
        assert_eq!(img.width(), 64);
        assert_eq!(img.height(), 32);
    }

    #[test]
    fn bt_empty_returns_no_commands() {
        let bt = BehaviorTree::new();
        assert!(bt.generate_render_commands().is_empty());
    }

    #[test]
    fn bt_draw_to_image_correct_dimensions() {
        let bt = BehaviorTree::new();
        let img = bt.draw_to_image(64, 64);
        assert_eq!(img.width(), 64);
        assert_eq!(img.height(), 64);
    }
}

// ── squad ─────────────────────────────────────────────────────────────────────

mod squad_tests {
    use lurek2d::ai::squad::{Squad, FormationType};

    #[test]
    fn add_remove_member() {
        let mut s = Squad::new("alpha", FormationType::Line);
        s.add_member(1);
        s.add_member(2);
        assert_eq!(s.members.len(), 2);
        s.remove_member(1);
        assert_eq!(s.members.len(), 1);
    }

    #[test]
    fn line_formation_positions() {
        let mut s = Squad::new("bravo", FormationType::Line);
        s.add_member(0);
        s.add_member(1);
        let p0 = s.formation_position(0, (0.0, 0.0), 10.0);
        let p1 = s.formation_position(1, (0.0, 0.0), 10.0);
        assert!((p0.1 - p1.1).abs() > 1.0, "different positions");
    }

    #[test]
    fn circle_formation_center() {
        let mut s = Squad::new("charlie", FormationType::Circle);
        s.add_member(0);
        let pos = s.formation_position(0, (100.0, 100.0), 20.0);
        let dist = ((pos.0 - 100.0).powi(2) + (pos.1 - 100.0).powi(2)).sqrt();
        assert!((dist - 20.0).abs() < 1e-3);
    }
}

// ── steering ──────────────────────────────────────────────────────────────────

mod steering_tests {
    use lurek2d::ai::steering::{SteeringManager, CombineMode};

    #[test]
    fn combine_mode_parse() {
        assert_eq!(CombineMode::from_str("weighted"), CombineMode::Weighted);
        assert_eq!(CombineMode::from_str("priority"), CombineMode::Priority);
        assert_eq!(CombineMode::from_str("nope"), CombineMode::Weighted);
    }

    #[test]
    fn new_manager_defaults() {
        let m = SteeringManager::new();
        assert_eq!(m.behavior_count(), 0);
    }

    #[test]
    fn spatial_hash_toggle() {
        let mut m = SteeringManager::new();
        m.set_use_spatial_hash(true);
        m.set_use_spatial_hash(false);
    }
}

// ── strategy ──────────────────────────────────────────────────────────────────

mod strategy_tests {
    use lurek2d::ai::strategy::{StrategyAI, StrategyGoal};

    #[test]
    fn new_strategy_empty_goals() {
        let s = StrategyAI::new(1.0);
        assert_eq!(s.goal_count(), 0);
    }

    #[test]
    fn add_goal_increases_count() {
        let mut s = StrategyAI::new(1.0);
        s.add_goal(StrategyGoal {
            name: "attack".into(),
            priority: 1.0,
            condition: Box::new(|_| true),
        });
        assert_eq!(s.goal_count(), 1);
    }

    #[test]
    fn time_until_next_starts_at_interval() {
        let s = StrategyAI::new(2.0);
        assert!((s.time_until_next() - 2.0).abs() < 1e-6);
    }
}

// ── traits ────────────────────────────────────────────────────────────────────

mod traits_tests {
    use lurek2d::ai::traits::{TraitProfile, TraitModifier, TraitArchetypes};
    use std::collections::HashMap;

    #[test]
    fn profile_set_get_clamped() {
        let mut p = TraitProfile::new();
        p.set("aggression", 0.5);
        assert!((p.get("aggression") - 0.5).abs() < 1e-6);
        p.set("aggression", 1.5);
        assert!((p.get("aggression") - 1.0).abs() < 1e-6);
    }

    #[test]
    fn modifier_affects_effective_value() {
        let mut p = TraitProfile::new();
        p.set("caution", 0.3);
        p.add_modifier(TraitModifier::new("caution", 0.4, None, "buff"));
        assert!((p.get("caution") - 0.7).abs() < 1e-6);
    }

    #[test]
    fn expired_modifier_ignored() {
        let mut p = TraitProfile::new();
        p.set("loyalty", 0.5);
        p.add_modifier(TraitModifier::new("loyalty", 0.3, Some(1.0), "temp"));
        p.update(2.0);
        assert!((p.get("loyalty") - 0.5).abs() < 1e-6);
    }

    #[test]
    fn unknown_trait_returns_zero() {
        let p = TraitProfile::new();
        assert_eq!(p.get("nonexistent"), 0.0);
    }

    #[test]
    fn archetype_creates_profile() {
        let mut arch = TraitArchetypes::new();
        let mut base = HashMap::new();
        base.insert("aggression".to_string(), 0.8);
        arch.register("berserker", base);
        let p = TraitProfile::from_archetype(&arch, "berserker", 0.0).unwrap();
        assert!((p.get("aggression") - 0.8).abs() < 1e-6);
    }
}

// ── utility_ai ────────────────────────────────────────────────────────────────

mod utility_ai_tests {
    use lurek2d::ai::utility_ai::{UtilityAI, ResponseCurve};

    #[test]
    fn response_curve_linear() {
        let c = ResponseCurve::Linear { slope: 2.0, intercept: 0.0, clamp_min: 0.0, clamp_max: 1.0 };
        assert!((c.apply(0.5) - 1.0).abs() < 1e-6);
    }

    #[test]
    fn response_curve_clamped() {
        let c = ResponseCurve::Linear { slope: 10.0, intercept: 0.0, clamp_min: 0.0, clamp_max: 1.0 };
        assert!((c.apply(1.0) - 1.0).abs() < 1e-6);
    }

    #[test]
    fn new_utility_ai_empty() {
        let ai = UtilityAI::new();
        assert_eq!(ai.action_count(), 0);
    }
}

// ── world ─────────────────────────────────────────────────────────────────────

mod world_tests {
    use lurek2d::ai::world::AIWorld;
    use lurek2d::ai::agent::Agent;

    #[test]
    fn new_world_empty() {
        let w = AIWorld::new();
        assert_eq!(w.agents.len(), 0);
    }

    #[test]
    fn add_and_find_agent() {
        let mut w = AIWorld::new();
        w.add_agent(Agent::new("test", 0));
        assert_eq!(w.agents.len(), 1);
        assert_eq!(w.agents[0].name, "test");
    }

    #[test]
    fn update_moves_agents() {
        let mut w = AIWorld::new();
        let mut a = Agent::new("mover", 0);
        a.velocity = (1.0, 0.0);
        w.add_agent(a);
        w.update(2.0);
        assert!((w.agents[0].position.0 - 2.0).abs() < 1e-6);
    }
}
