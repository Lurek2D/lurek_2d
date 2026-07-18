//! File: tests/rust/unit/progression_tests.rs
//! Owns Rust-side coverage for progression internals that do not require Lua contract testing.

use lurek2d::progression::{
    AchievementDefinition, AttributeDefinition, AttributeMode, ChallengeTemplateDefinition,
    ChangesetApplyOptions, ChangesetMergePolicy, CollectionDefinition, CollectionItemDefinition,
    ComparisonOp, CounterDefinition, CounterKind, CounterTriggerDefinition, DerivedValueDefinition,
    DerivedValueInput, LeaderboardDefinition, LeaderboardRankMode, LeaderboardSort,
    LevelTrackDefinition, ModifierAddOptions, PerkDefinition, PopulationActivityDefinition,
    PopulationArchetypeDefinition, PopulationIdentityDefinition, PopulationInitialScoreDefinition,
    PopulationLeaderboardDefinition, PopulationNameGeneratorDefinition,
    PopulationScoreProgressionDefinition, PopulationSkillDefinition, PopulationTemplateDefinition,
    PrestigeDefinition, PrestigePreserveDefinition, PrestigeResetDefinition, ProfileOptions,
    ProfileTemplateDefinition, ProgressionCondition, ProgressionStore, ProgressionStoreOptions,
    QuestDefinition, QuestObjectiveDefinition, QuestStageDefinition, ResourceDefinition,
    RewardState, SeasonDefinition, SeasonResetDefinition, SkillDefinition, TraitDefinition,
    TraitModifierDefinition,
};
use serde_json::Value as JsonValue;
use std::collections::BTreeMap;

#[test]
fn counter_thresholds_emit_events_in_order() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "thresholds".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![2.0],
            },
        )
        .expect("counter");

    let value = store.add_counter("player", "wins", 2.0).expect("value");
    let events = store.drain_events();

    assert_eq!(value, 2.0);
    assert_eq!(events[0].event_type, "profile_created");
    assert_eq!(events[1].event_type, "counter_changed");
    assert_eq!(events[2].event_type, "counter_threshold_entered");
}

#[test]
fn attribute_explanation_includes_modifier_delta() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "attributes".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_attribute(
            "strength",
            AttributeDefinition {
                base: 10.0,
                min: Some(0.0),
                max: Some(99.0),
                regen: 0.0,
                growth: 0.0,
            },
        )
        .expect("attribute");
    store
        .set_attribute_base("player", "strength", 12.0)
        .expect("set");
    store
        .add_modifier(
            "player",
            "strength",
            ModifierAddOptions {
                layer: Some("final_add".to_string()),
                value: 4.0,
                duration: None,
                source: Some("blessing".to_string()),
                tags: vec!["positive".to_string()],
            },
        )
        .expect("modifier");

    let effective = store
        .get_attribute("player", "strength", AttributeMode::Effective)
        .expect("effective");
    let explanation = store
        .explain_attribute("player", "strength")
        .expect("explanation");

    assert_eq!(effective, 16.0);
    assert_eq!(explanation.base, 12.0);
    assert_eq!(explanation.modifier_total, 4.0);
}

#[test]
fn resources_levels_and_quests_round_trip_core_state() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "round_trip".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_resource(
            "stamina",
            ResourceDefinition {
                initial: 6.0,
                min: 0.0,
                max: 10.0,
                regeneration: 0.0,
                refill: "manual".to_string(),
            },
        )
        .expect("resource");
    store
        .define_level_track(
            "character_xp",
            LevelTrackDefinition {
                initial_level: 1,
                max_level: 10,
                base_xp: 100.0,
                increment_xp: 50.0,
                carry_over: true,
                allow_level_down: false,
            },
        )
        .expect("track");
    store
        .define_quest(
            "rat_hunt",
            QuestDefinition {
                id: "rat_hunt".to_string(),
                title: "Rat Hunt".to_string(),
                description: String::new(),
                stages: vec![QuestStageDefinition {
                    id: "stage_1".to_string(),
                    name: "Cull".to_string(),
                    objectives: vec![QuestObjectiveDefinition {
                        id: "kills".to_string(),
                        description: "Defeat three rats".to_string(),
                        required: 3.0,
                        mandatory: true,
                        visible: true,
                        counter_id: None,
                    }],
                }],
                max_journal_entries: None,
                reveal_condition: None,
                availability_condition: None,
                reward_payload: None,
            },
        )
        .expect("quest");

    assert!(store
        .spend_resource("player", "stamina", 2.0)
        .expect("spend"));
    let xp = store
        .add_experience("player", "character_xp", 180.0)
        .expect("xp");
    store.accept_quest("player", "rat_hunt").expect("accept");
    let quest = store
        .set_quest_objective("player", "rat_hunt", "kills", 3.0)
        .expect("quest");

    assert_eq!(
        store.get_resource("player", "stamina").expect("resource")["value"],
        4.0
    );
    assert_eq!(xp["level"], 2);
    assert_eq!(quest["status"], "completed");
}

#[test]
fn snapshots_profile_patch_and_manual_controls_work() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "snapshot_controls".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile(
            "player",
            ProfileOptions {
                display_name: Some("Mira".to_string()),
                ..ProfileOptions::default()
            },
        )
        .expect("profile");
    store
        .update_profile(
            "player",
            ProfileOptions {
                display_name: Some("Captain Mira".to_string()),
                tags: vec!["story".to_string()],
                ..ProfileOptions::default()
            },
        )
        .expect("update");
    store.add_profile_tag("player", "veteran").expect("add tag");
    store
        .set_profile_metadata("player", "chapter", serde_json::json!(2))
        .expect("metadata");
    store
        .define_level_track(
            "character_xp",
            LevelTrackDefinition {
                initial_level: 1,
                max_level: 10,
                base_xp: 100.0,
                increment_xp: 50.0,
                carry_over: true,
                allow_level_down: false,
            },
        )
        .expect("track");
    store
        .set_experience("player", "character_xp", 275.0)
        .expect("set xp");
    let level = store
        .set_level("player", "character_xp", 4)
        .expect("set level");
    let snapshot = store.export_snapshot();
    let definition_hash = store.definition_hash();

    let restored = ProgressionStore::from_snapshot(snapshot).expect("restore");
    let profile = restored
        .get_profile_snapshot("player")
        .expect("profile snapshot");

    assert_eq!(profile["display_name"], "Captain Mira");
    assert_eq!(profile["metadata"]["chapter"], 2);
    assert_eq!(level["level"], 4);
    assert!(!definition_hash.is_empty());
    assert_eq!(restored.id(), "snapshot_controls");
}

#[test]
fn profile_templates_seed_profiles_and_can_be_reapplied() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "profile_templates".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_attribute(
            "strength",
            AttributeDefinition {
                base: 10.0,
                min: Some(0.0),
                max: Some(99.0),
                regen: 0.0,
                growth: 0.0,
            },
        )
        .expect("attribute");
    store
        .define_resource(
            "stamina",
            ResourceDefinition {
                initial: 2.0,
                min: 0.0,
                max: 10.0,
                regeneration: 0.0,
                refill: "manual".to_string(),
            },
        )
        .expect("resource");
    store
        .define_level_track(
            "character_xp",
            LevelTrackDefinition {
                initial_level: 1,
                max_level: 10,
                base_xp: 100.0,
                increment_xp: 50.0,
                carry_over: true,
                allow_level_down: false,
            },
        )
        .expect("track");
    let mut template = ProfileTemplateDefinition {
        kind: Some("scout".to_string()),
        display_name: Some("Veteran Scout".to_string()),
        ..ProfileTemplateDefinition::default()
    };
    template.counters.insert("wins".to_string(), 4.0);
    template.attributes.insert("strength".to_string(), 14.0);
    template.resources.insert("stamina".to_string(), 7.0);
    template
        .experience
        .insert("character_xp".to_string(), 180.0);
    template.tags.push("veteran".to_string());
    template
        .metadata
        .insert("origin".to_string(), serde_json::json!("frontier"));
    store
        .define_profile_template("veteran_scout", template)
        .expect("template");

    store
        .create_profile(
            "player",
            ProfileOptions {
                display_name: Some("Mira".to_string()),
                template: Some("veteran_scout".to_string()),
                ..ProfileOptions::default()
            },
        )
        .expect("profile");
    let snapshot = store.get_profile_snapshot("player").expect("snapshot");
    let wins = store.get_counter("player", "wins").expect("wins");
    let strength = store
        .get_attribute("player", "strength", AttributeMode::Base)
        .expect("strength");
    let stamina = store.get_resource("player", "stamina").expect("stamina");
    let level = store.get_level("player", "character_xp").expect("level");

    assert_eq!(snapshot["display_name"], "Mira");
    assert_eq!(snapshot["kind"], "scout");
    assert_eq!(snapshot["metadata"]["origin"], "frontier");
    assert_eq!(wins, 4.0);
    assert_eq!(strength, 14.0);
    assert_eq!(stamina["value"], 7.0);
    assert_eq!(level, 2);

    store
        .set_attribute_base("player", "strength", 20.0)
        .expect("override strength");
    let reapplied = store
        .apply_profile_template("player", "veteran_scout")
        .expect("apply template");
    assert_eq!(reapplied["metadata"]["__template_id"], "veteran_scout");
    assert_eq!(
        store
            .get_attribute("player", "strength", AttributeMode::Base)
            .expect("reapplied strength"),
        14.0
    );
}

#[test]
fn traits_and_perks_apply_canonical_modifier_state() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "traits_perks".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_attribute(
            "hp",
            AttributeDefinition {
                base: 100.0,
                min: Some(0.0),
                max: Some(999.0),
                regen: 0.0,
                growth: 0.0,
            },
        )
        .expect("attribute");
    store
        .define_level_track("__legacy_xp", LevelTrackDefinition::default())
        .expect("track");
    store
        .define_trait(
            "tough",
            TraitDefinition {
                modifiers: vec![TraitModifierDefinition {
                    target_id: "hp".to_string(),
                    layer: Some("final_add".to_string()),
                    value: 20.0,
                }],
            },
        )
        .expect("trait");
    store
        .define_perk(
            "iron_skin",
            PerkDefinition {
                require_level: 3,
                track_id: Some("__legacy_xp".to_string()),
                trait_ids: vec!["tough".to_string()],
            },
        )
        .expect("perk");

    assert!(store.apply_trait("player", "tough").expect("apply trait"));
    assert_eq!(
        store
            .get_attribute("player", "hp", AttributeMode::Effective)
            .expect("hp"),
        120.0
    );
    assert!(store.remove_trait("player", "tough").expect("remove trait"));
    assert!(!store.has_trait("player", "tough").expect("trait state"));
    assert_eq!(
        store
            .get_attribute("player", "hp", AttributeMode::Effective)
            .expect("hp reset"),
        100.0
    );

    store.set_level("player", "__legacy_xp", 3).expect("level");
    assert!(store
        .acquire_perk("player", "iron_skin")
        .expect("perk acquire"));
    assert!(store.has_perk("player", "iron_skin").expect("perk state"));
    assert!(store
        .has_trait("player", "tough")
        .expect("trait applied by perk"));
}

#[test]
fn skills_track_levels_costs_and_cooldowns() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "skills".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_attribute(
            "mana",
            AttributeDefinition {
                base: 100.0,
                min: Some(0.0),
                max: Some(100.0),
                regen: 0.0,
                growth: 0.0,
            },
        )
        .expect("mana");
    store
        .set_attribute_base("player", "mana", 100.0)
        .expect("set mana");
    store
        .define_skill(
            "heal",
            SkillDefinition {
                max_level: 5,
                resource_id: Some("mana".to_string()),
                cost: 30.0,
                cooldown: 5.0,
            },
        )
        .expect("skill");

    assert!(store.learn_skill("player", "heal").expect("learn"));
    let used = store.use_skill("player", "heal").expect("use");
    assert_eq!(used["ok"], true);
    assert_eq!(
        store
            .get_attribute("player", "mana", AttributeMode::Base)
            .expect("mana after use"),
        70.0
    );
    let blocked = store.use_skill("player", "heal").expect("blocked");
    assert_eq!(blocked["ok"], false);
    assert_eq!(blocked["reason"], "on cooldown");
    store.update(3.0).expect("tick");
    assert_eq!(
        store
            .get_skill_cooldown("player", "heal")
            .expect("cooldown"),
        2.0
    );
    store.update(3.0).expect("tick again");
    assert_eq!(
        store
            .get_skill_cooldown("player", "heal")
            .expect("cooldown"),
        0.0
    );
}

#[test]
fn changesets_can_replicate_latest_snapshot_between_stores() {
    let mut source = ProgressionStore::new(ProgressionStoreOptions {
        id: "changes_source".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("source");
    source
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    source
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    source.add_counter("player", "wins", 3.0).expect("wins");

    let changes = source.export_changes_since(0);
    let mut target = ProgressionStore::new(ProgressionStoreOptions {
        id: "changes_target".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("target");
    let applied = target.apply_changeset(changes).expect("apply");

    assert_eq!(applied["applied"], true);
    assert_eq!(
        target
            .get_counter("player", "wins")
            .expect("replicated wins"),
        3.0
    );
    assert_eq!(
        target.get_profile_snapshot("player").expect("profile")["id"],
        "player"
    );
}

#[test]
fn changeset_envelopes_validate_hash_and_support_ack_and_compaction() {
    let mut source = ProgressionStore::new(ProgressionStoreOptions {
        id: "changes_envelope_source".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("source");
    source
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    source
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    source.add_counter("player", "wins", 1.0).expect("wins1");
    source.add_counter("player", "wins", 2.0).expect("wins2");
    source.add_counter("player", "wins", 3.0).expect("wins3");

    let all_changes = source.export_changes_since(0);
    assert!(all_changes.len() >= 3);
    let envelope = source.export_changeset(0, Some(2)).expect("envelope");
    assert_eq!(envelope.schema_version, source.schema_version());
    assert_eq!(envelope.definition_hash, source.definition_hash());
    assert!(envelope.truncated);
    assert_eq!(envelope.records.len(), 2);
    assert_eq!(
        envelope.to_revision,
        envelope.records.last().expect("latest").revision
    );

    let mut matching_target = ProgressionStore::new(ProgressionStoreOptions {
        id: "changes_envelope_target".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("target");
    matching_target
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    let applied = matching_target
        .apply_changeset_envelope(envelope.clone(), true, true)
        .expect("apply envelope");
    assert_eq!(applied["applied"], true);
    assert_eq!(
        matching_target
            .get_counter("player", "wins")
            .expect("replicated wins"),
        6.0
    );

    let mut mismatched_target = ProgressionStore::new(ProgressionStoreOptions {
        id: "changes_envelope_mismatch".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("mismatch");
    assert!(mismatched_target
        .apply_changeset_envelope(envelope, true, true)
        .is_err());

    let first_revision = all_changes.first().expect("first change").revision;
    let acknowledged = source.acknowledge_changes_through(first_revision);
    assert_eq!(acknowledged["removedCount"], 1);
    assert_eq!(
        source.export_changes_since(0).len(),
        all_changes.len().saturating_sub(1)
    );

    let compacted = source.compact_changes(1).expect("compact");
    assert_eq!(compacted["afterCount"], 1);
    assert_eq!(source.export_changes_since(0).len(), 1);
}

#[test]
fn malformed_and_oversized_changesets_are_rejected() {
    let source = ProgressionStore::new(ProgressionStoreOptions {
        id: "changes_guard_source".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("source");
    let mut target = ProgressionStore::new(ProgressionStoreOptions {
        id: "changes_guard_target".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("target");

    let malformed = lurek2d::progression::ChangesetEnvelope {
        schema_version: source.schema_version(),
        definition_hash: source.definition_hash(),
        from_revision: 1,
        to_revision: 2,
        truncated: false,
        records: vec![lurek2d::progression::ChangeRecord {
            revision: 1,
            snapshot: serde_json::json!({}),
        }],
    };
    assert!(target
        .apply_changeset_envelope(malformed, true, true)
        .is_err());

    let oversized = lurek2d::progression::ChangesetEnvelope {
        schema_version: source.schema_version(),
        definition_hash: source.definition_hash(),
        from_revision: 0,
        to_revision: 1,
        truncated: false,
        records: vec![lurek2d::progression::ChangeRecord {
            revision: 1,
            snapshot: serde_json::json!({
                "blob": "x".repeat(300_000),
            }),
        }],
    };
    assert!(target
        .apply_changeset_envelope(oversized.clone(), true, true)
        .is_err());
    assert!(target.apply_changeset(oversized.records).is_err());
}

#[test]
fn counter_triggered_achievement_unlocks_and_emits_reward() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "achievement_counter".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_achievement(
            "first_win",
            AchievementDefinition {
                id: "first_win".to_string(),
                title: "First Win".to_string(),
                description: "Win one match".to_string(),
                hidden: false,
                repeatable: false,
                condition: None,
                counter_trigger: Some(CounterTriggerDefinition {
                    counter_id: "wins".to_string(),
                    op: ComparisonOp::GreaterEqual,
                    value: 1.0,
                }),
                reward_payload: Some(serde_json::json!({ "currency": 100 })),
            },
        )
        .expect("achievement");

    store.add_counter("player", "wins", 1.0).expect("increment");
    let achievement = store
        .get_achievement("player", "first_win")
        .expect("achievement");
    let rewards = store.get_pending_rewards("player").expect("rewards");

    assert_eq!(achievement["unlock_count"], 1);
    assert_eq!(achievement["unlocked"], true);
    assert_eq!(rewards.len(), 1);
    assert_eq!(rewards[0].state, RewardState::Pending);
    assert_eq!(rewards[0].source_id, "first_win");
}

#[test]
fn reward_claim_apply_and_reject_follow_state_machine() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "reward_flow".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_achievement(
            "manual_reward",
            AchievementDefinition {
                id: "manual_reward".to_string(),
                title: "Manual Reward".to_string(),
                description: String::new(),
                hidden: false,
                repeatable: true,
                condition: None,
                counter_trigger: None,
                reward_payload: Some(serde_json::json!({ "items": ["token"] })),
            },
        )
        .expect("achievement");

    let unlocked = store
        .unlock_achievement("player", "manual_reward")
        .expect("unlock");
    let reward_id = format!(
        "achievement:manual_reward:{}",
        unlocked["unlock_count"].as_u64().expect("unlock count")
    );
    let claimed = store.claim_reward("player", &reward_id).expect("claim");
    let applied = store
        .mark_reward_applied("player", &reward_id, Some("receipt-1".to_string()))
        .expect("apply");

    assert_eq!(claimed.state, RewardState::Claimed);
    assert_eq!(applied.state, RewardState::Applied);
    assert_eq!(applied.external_receipt.as_deref(), Some("receipt-1"));

    store
        .unlock_achievement("player", "manual_reward")
        .expect("unlock again");
    let rejected = store
        .reject_reward(
            "player",
            "achievement:manual_reward:2",
            Some("inventory_full".to_string()),
        )
        .expect("reject");
    assert_eq!(rejected.state, RewardState::Rejected);
}

#[test]
fn counter_bound_quest_objectives_advance_and_emit_rewards() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "quest_counter_rewards".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_counter(
            "rats_killed",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_quest(
            "rat_cleanup",
            QuestDefinition {
                id: "rat_cleanup".to_string(),
                title: "Rat Cleanup".to_string(),
                description: String::new(),
                stages: vec![QuestStageDefinition {
                    id: "stage_1".to_string(),
                    name: "Cull".to_string(),
                    objectives: vec![QuestObjectiveDefinition {
                        id: "kills".to_string(),
                        description: "Defeat three rats".to_string(),
                        required: 3.0,
                        mandatory: true,
                        visible: true,
                        counter_id: Some("rats_killed".to_string()),
                    }],
                }],
                max_journal_entries: None,
                reveal_condition: None,
                availability_condition: None,
                reward_payload: Some(serde_json::json!({ "currency": 50 })),
            },
        )
        .expect("quest");

    store.accept_quest("player", "rat_cleanup").expect("accept");
    store
        .add_counter("player", "rats_killed", 3.0)
        .expect("counter change");

    let quest = store
        .get_quest_state("player", "rat_cleanup")
        .expect("quest");
    let rewards = store.get_pending_rewards("player").expect("rewards");

    assert_eq!(quest["status"], "completed");
    assert_eq!(quest["completion_count"], 1);
    assert_eq!(rewards.len(), 1);
    assert_eq!(rewards[0].id, "quest:rat_cleanup:1");
    assert_eq!(rewards[0].source_kind, "quest");
}

#[test]
fn shared_conditions_validate_evaluate_and_gate_definitions() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "conditions".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile(
            "player",
            ProfileOptions {
                tags: vec!["hero".to_string()],
                ..ProfileOptions::default()
            },
        )
        .expect("profile");
    store
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_level_track(
            "character_xp",
            LevelTrackDefinition {
                initial_level: 1,
                max_level: 100,
                base_xp: 100.0,
                increment_xp: 100.0,
                carry_over: true,
                allow_level_down: false,
            },
        )
        .expect("track");
    let condition = ProgressionCondition::All {
        conditions: vec![
            ProgressionCondition::Tag {
                tag: "hero".to_string(),
            },
            ProgressionCondition::Counter {
                counter_id: "wins".to_string(),
                op: ComparisonOp::GreaterEqual,
                value: 2.0,
            },
            ProgressionCondition::Level {
                track_id: "character_xp".to_string(),
                op: ComparisonOp::GreaterEqual,
                value: 3,
            },
        ],
    };

    let validation = store.validate_condition(&condition);
    assert_eq!(validation["ok"], true);
    assert!(!store
        .evaluate_condition("player", &condition)
        .expect("condition before"));
    store.add_counter("player", "wins", 2.0).expect("wins");
    store
        .set_level("player", "character_xp", 3)
        .expect("set level");
    assert!(store
        .evaluate_condition("player", &condition)
        .expect("condition after"));
    let explanation = store
        .explain_condition("player", &condition)
        .expect("explanation");
    assert_eq!(explanation["ok"], true);
    assert_eq!(explanation["children"][2]["kind"], "level");

    store
        .define_quest(
            "gated_quest",
            QuestDefinition {
                id: "gated_quest".to_string(),
                title: "Gated".to_string(),
                description: String::new(),
                stages: vec![QuestStageDefinition {
                    id: "stage_1".to_string(),
                    name: "Stage".to_string(),
                    objectives: vec![QuestObjectiveDefinition {
                        id: "step".to_string(),
                        description: "Step".to_string(),
                        required: 1.0,
                        mandatory: true,
                        visible: true,
                        counter_id: None,
                    }],
                }],
                max_journal_entries: None,
                reveal_condition: None,
                availability_condition: Some(condition.clone()),
                reward_payload: None,
            },
        )
        .expect("quest");
    store
        .accept_quest("player", "gated_quest")
        .expect("accept gated");

    store
        .define_achievement(
            "gated_achievement",
            AchievementDefinition {
                id: "gated_achievement".to_string(),
                title: "Gated Achievement".to_string(),
                description: String::new(),
                hidden: false,
                repeatable: false,
                condition: Some(ProgressionCondition::Tag {
                    tag: "hero".to_string(),
                }),
                counter_trigger: None,
                reward_payload: None,
            },
        )
        .expect("achievement");
    let unlocked = store
        .unlock_achievement("player", "gated_achievement")
        .expect("unlock");
    assert_eq!(unlocked["unlocked"], true);
}

#[test]
fn quests_progress_through_hidden_revealed_available_and_active_states() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "quest_lifecycle".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_quest(
            "arena",
            QuestDefinition {
                id: "arena".to_string(),
                title: "Arena".to_string(),
                description: String::new(),
                stages: vec![QuestStageDefinition {
                    id: "stage_1".to_string(),
                    name: "Stage".to_string(),
                    objectives: vec![QuestObjectiveDefinition {
                        id: "step".to_string(),
                        description: "Step".to_string(),
                        required: 1.0,
                        mandatory: true,
                        visible: true,
                        counter_id: None,
                    }],
                }],
                max_journal_entries: None,
                reveal_condition: Some(ProgressionCondition::Counter {
                    counter_id: "wins".to_string(),
                    op: ComparisonOp::GreaterEqual,
                    value: 1.0,
                }),
                availability_condition: Some(ProgressionCondition::Counter {
                    counter_id: "wins".to_string(),
                    op: ComparisonOp::GreaterEqual,
                    value: 2.0,
                }),
                reward_payload: None,
            },
        )
        .expect("quest");

    assert_eq!(
        store.get_quest_state("player", "arena").expect("hidden")["status"],
        "hidden"
    );
    store.add_counter("player", "wins", 1.0).expect("reveal");
    assert_eq!(
        store.get_quest_state("player", "arena").expect("revealed")["status"],
        "revealed"
    );
    store.add_counter("player", "wins", 1.0).expect("available");
    let available = store.get_quest_state("player", "arena").expect("available");
    assert_eq!(available["status"], "available");
    assert_eq!(available["revealed"], true);
    assert_eq!(available["available"], true);

    store.accept_quest("player", "arena").expect("accept");
    assert_eq!(
        store.get_quest_state("player", "arena").expect("active")["status"],
        "active"
    );
}

#[test]
fn quest_journal_entries_are_retained_with_indexes_and_caps() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "quest_journal".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_quest(
            "journaled",
            QuestDefinition {
                id: "journaled".to_string(),
                title: "Journaled".to_string(),
                description: String::new(),
                stages: vec![QuestStageDefinition {
                    id: "stage_1".to_string(),
                    name: "Stage".to_string(),
                    objectives: vec![QuestObjectiveDefinition {
                        id: "step".to_string(),
                        description: "Step".to_string(),
                        required: 1.0,
                        mandatory: true,
                        visible: true,
                        counter_id: None,
                    }],
                }],
                max_journal_entries: Some(2),
                reveal_condition: None,
                availability_condition: None,
                reward_payload: None,
            },
        )
        .expect("quest");
    store.accept_quest("player", "journaled").expect("accept");
    let first = store
        .add_quest_journal_entry(
            "player",
            "journaled",
            "Found clue",
            Some("discover".to_string()),
        )
        .expect("journal 1");
    store
        .add_quest_journal_entry(
            "player",
            "journaled",
            "Opened door",
            Some("progress".to_string()),
        )
        .expect("journal 2");
    let third = store
        .add_quest_journal_entry("player", "journaled", "Reached boss", None)
        .expect("journal 3");
    let journal = store
        .list_quest_journal_entries("player", "journaled")
        .expect("journal list");
    let quest = store.get_quest_state("player", "journaled").expect("quest");

    assert_eq!(first.index, 0);
    assert_eq!(third.index, 2);
    assert_eq!(journal.len(), 2);
    assert_eq!(journal[0].text, "Opened door");
    assert_eq!(journal[1].text, "Reached boss");
    assert_eq!(quest["journal"][0]["text"], "Opened door");
}

#[test]
fn quest_objective_status_and_visibility_overrides_are_canonical() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "quest_objectives".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_quest(
            "stealth",
            QuestDefinition {
                id: "stealth".to_string(),
                title: "Stealth".to_string(),
                description: String::new(),
                stages: vec![QuestStageDefinition {
                    id: "stage_1".to_string(),
                    name: "Stage".to_string(),
                    objectives: vec![
                        QuestObjectiveDefinition {
                            id: "required".to_string(),
                            description: "Required".to_string(),
                            required: 1.0,
                            mandatory: true,
                            visible: false,
                            counter_id: None,
                        },
                        QuestObjectiveDefinition {
                            id: "optional".to_string(),
                            description: "Optional".to_string(),
                            required: 1.0,
                            mandatory: false,
                            visible: true,
                            counter_id: None,
                        },
                    ],
                }],
                max_journal_entries: None,
                reveal_condition: None,
                availability_condition: None,
                reward_payload: None,
            },
        )
        .expect("quest");
    store.accept_quest("player", "stealth").expect("accept");
    let hidden_before = store.get_quest_state("player", "stealth").expect("before");
    let before_objectives = hidden_before["objectives"]
        .as_array()
        .expect("objectives array");
    let required_before = before_objectives
        .iter()
        .find(|objective| objective["id"] == "required")
        .expect("required objective");
    assert_eq!(required_before["visible"], false);

    store
        .set_quest_objective_visibility("player", "stealth", "required", true)
        .expect("visible");
    let completed = store
        .set_quest_objective_status("player", "stealth", "required", "skipped")
        .expect("skipped");
    let quest = store.get_quest_state("player", "stealth").expect("quest");
    let quest_objectives = quest["objectives"].as_array().expect("objectives");
    let required_after = quest_objectives
        .iter()
        .find(|objective| objective["id"] == "required")
        .expect("required objective");

    assert_eq!(completed["status"], "completed");
    assert_eq!(quest["status"], "completed");
    assert_eq!(required_after["status"], "skipped");
    assert_eq!(required_after["visible"], true);
}

#[test]
fn leaderboards_rank_profiles_deterministically_and_follow_counter_sources() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "leaderboards".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("alpha", ProfileOptions::default())
        .expect("alpha");
    store
        .create_profile("beta", ProfileOptions::default())
        .expect("beta");
    store
        .create_profile("gamma", ProfileOptions::default())
        .expect("gamma");
    store
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_leaderboard(
            "arena",
            LeaderboardDefinition {
                id: "arena".to_string(),
                title: "Arena".to_string(),
                sort: LeaderboardSort::Descending,
                rank_mode: LeaderboardRankMode::Competition,
                max_entries: Some(10),
                counter_id: Some("wins".to_string()),
            },
        )
        .expect("leaderboard");

    store.add_counter("alpha", "wins", 5.0).expect("alpha wins");
    store.add_counter("beta", "wins", 5.0).expect("beta wins");
    store.add_counter("gamma", "wins", 3.0).expect("gamma wins");

    let top = store.list_leaderboard_top("arena", Some(3)).expect("top");
    let range = store
        .list_leaderboard_range("arena", 2, Some(2))
        .expect("range");
    let around_beta = store
        .list_leaderboard_around_profile("arena", "beta", Some(1), Some(1))
        .expect("around beta");
    let alpha = store
        .get_leaderboard_entry("alpha", "arena")
        .expect("alpha entry");
    let gamma = store
        .get_leaderboard_entry("gamma", "arena")
        .expect("gamma entry");

    assert_eq!(top.len(), 3);
    assert_eq!(top[0]["profile_id"], "alpha");
    assert_eq!(top[1]["profile_id"], "beta");
    assert_eq!(top[2]["profile_id"], "gamma");
    assert_eq!(range[0]["profile_id"], "gamma");
    assert_eq!(around_beta.len(), 3);
    assert_eq!(around_beta[1]["profile_id"], "beta");
    assert_eq!(alpha["rank"], 1);
    assert_eq!(gamma["rank"], 3);

    let manual = store
        .submit_score("gamma", "arena", 8.0)
        .expect("manual submit");
    let events = store.drain_events();
    let entered_top = events
        .iter()
        .any(|event| event.event_type == "leaderboard_top_entered");
    let rank_changed = events
        .iter()
        .any(|event| event.event_type == "leaderboard_rank_changed");
    assert_eq!(manual["rank"], 1);
    assert!(entered_top);
    assert!(rank_changed);
}

#[test]
fn derived_values_evaluate_with_bound_inputs_and_explanations() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "derived_values".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_attribute(
            "strength",
            AttributeDefinition {
                base: 10.0,
                min: Some(0.0),
                max: Some(99.0),
                regen: 0.0,
                growth: 0.0,
            },
        )
        .expect("attribute");
    store
        .define_resource(
            "stamina",
            ResourceDefinition {
                initial: 6.0,
                min: 0.0,
                max: 10.0,
                regeneration: 0.0,
                refill: "manual".to_string(),
            },
        )
        .expect("resource");
    store
        .define_level_track(
            "character_xp",
            LevelTrackDefinition {
                initial_level: 1,
                max_level: 10,
                base_xp: 100.0,
                increment_xp: 50.0,
                carry_over: true,
                allow_level_down: false,
            },
        )
        .expect("track");
    store.add_counter("player", "wins", 3.0).expect("wins");
    store
        .set_attribute_base("player", "strength", 12.0)
        .expect("strength");
    store
        .add_resource("player", "stamina", -2.0)
        .expect("stamina");
    store
        .add_experience("player", "character_xp", 180.0)
        .expect("xp");

    let mut inputs = BTreeMap::new();
    inputs.insert(
        "wins".to_string(),
        DerivedValueInput::Counter {
            counter_id: "wins".to_string(),
        },
    );
    inputs.insert(
        "strength".to_string(),
        DerivedValueInput::Attribute {
            attribute_id: "strength".to_string(),
            mode: AttributeMode::Effective,
        },
    );
    inputs.insert(
        "stamina".to_string(),
        DerivedValueInput::Resource {
            resource_id: "stamina".to_string(),
        },
    );
    inputs.insert(
        "level".to_string(),
        DerivedValueInput::Level {
            track_id: "character_xp".to_string(),
        },
    );
    store
        .define_derived_value(
            "combat_rating",
            DerivedValueDefinition {
                expression: "round((wins * 5 + strength + stamina + level) / 2)".to_string(),
                inputs,
                min: Some(0.0),
                max: None,
                round: None,
            },
        )
        .expect("derived");

    let value = store
        .get_derived_value("player", "combat_rating")
        .expect("value");
    let explanation = store
        .explain_derived_value("player", "combat_rating")
        .expect("explanation");
    let validation = store.validate_derived_values();

    assert_eq!(value, 17.0);
    assert_eq!(validation["ok"], true);
    assert_eq!(explanation["inputs"]["wins"], 3.0);
    assert_eq!(explanation["value"], 17.0);
}

#[test]
fn seasons_archive_pre_reset_state_and_clear_selected_progress() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "seasons".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("alpha", ProfileOptions::default())
        .expect("alpha");
    store
        .create_profile("beta", ProfileOptions::default())
        .expect("beta");
    store
        .define_counter(
            "season_wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_leaderboard(
            "arena",
            LeaderboardDefinition {
                id: "arena".to_string(),
                title: "Arena".to_string(),
                sort: LeaderboardSort::Descending,
                rank_mode: LeaderboardRankMode::Ordinal,
                max_entries: Some(10),
                counter_id: Some("season_wins".to_string()),
            },
        )
        .expect("leaderboard");
    store
        .define_season(
            "arena_s1",
            SeasonDefinition {
                id: "arena_s1".to_string(),
                starts_at: 0.0,
                ends_at: 100.0,
                reset: SeasonResetDefinition {
                    leaderboards: vec!["arena".to_string()],
                    counters: vec!["season_wins".to_string()],
                },
                archive: true,
            },
        )
        .expect("season");
    store.start_season("arena_s1", Some(0.0)).expect("start");
    store
        .add_counter("alpha", "season_wins", 5.0)
        .expect("alpha wins");
    store
        .add_counter("beta", "season_wins", 3.0)
        .expect("beta wins");

    let ended = store
        .end_season("arena_s1", Some(100.0), None)
        .expect("end");
    let archive = store.get_season_archive("arena_s1", true).expect("archive");
    let events = store.list_events();

    assert_eq!(ended["active"], false);
    assert_eq!(ended["archive_count"], 1);
    assert_eq!(
        store.get_counter("alpha", "season_wins").expect("counter"),
        0.0
    );
    assert!(store
        .list_leaderboard_top("arena", Some(1))
        .expect("top")
        .is_empty());
    assert_eq!(
        archive["snapshot"]["profiles"]["alpha"]["counters"]["season_wins"]["value"],
        5.0
    );
    assert_eq!(
        archive["snapshot"]["profiles"]["alpha"]["leaderboard_scores"]["arena"],
        5.0
    );
    assert!(events
        .iter()
        .any(|event| event.event_type == "season_started"));
    assert!(events
        .iter()
        .any(|event| event.event_type == "season_counter_reset"));
    assert!(events
        .iter()
        .any(|event| event.event_type == "season_leaderboard_reset"));
    assert!(events
        .iter()
        .any(|event| event.event_type == "season_ended"));
}

#[test]
fn prestige_resets_selected_progress_and_preserves_requested_history() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "prestige".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_counter(
            "campaign_kills",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_level_track(
            "character_xp",
            LevelTrackDefinition {
                initial_level: 1,
                max_level: 200,
                base_xp: 100.0,
                increment_xp: 100.0,
                carry_over: true,
                allow_level_down: false,
            },
        )
        .expect("track");
    store
        .define_achievement(
            "first_steps",
            AchievementDefinition {
                id: "first_steps".to_string(),
                title: "First Steps".to_string(),
                description: String::new(),
                hidden: false,
                repeatable: false,
                condition: None,
                counter_trigger: None,
                reward_payload: None,
            },
        )
        .expect("achievement");
    store
        .define_prestige(
            "career",
            PrestigeDefinition {
                id: "career".to_string(),
                condition: ProgressionCondition::Level {
                    track_id: "character_xp".to_string(),
                    op: ComparisonOp::GreaterEqual,
                    value: 100,
                },
                reset: PrestigeResetDefinition {
                    level_tracks: vec!["character_xp".to_string()],
                    counters: vec!["campaign_kills".to_string()],
                },
                preserve: PrestigePreserveDefinition {
                    achievements: true,
                    lifetime_counters: true,
                },
            },
        )
        .expect("prestige");
    store
        .set_level("player", "character_xp", 100)
        .expect("set level");
    store
        .add_counter("player", "campaign_kills", 42.0)
        .expect("kills");
    store
        .unlock_achievement("player", "first_steps")
        .expect("unlock");

    assert!(store
        .can_prestige("player", "career")
        .expect("can prestige"));
    let applied = store
        .apply_prestige("player", "career")
        .expect("apply prestige");
    let achievement = store
        .get_achievement("player", "first_steps")
        .expect("achievement");
    let events = store.list_events();

    assert_eq!(applied["count"], 1);
    assert_eq!(applied["available"], false);
    assert_eq!(applied["lifetime_counters"]["campaign_kills"], 42.0);
    assert_eq!(store.get_level("player", "character_xp").expect("level"), 1);
    assert_eq!(
        store
            .get_counter("player", "campaign_kills")
            .expect("counter"),
        0.0
    );
    assert_eq!(achievement["unlocked"], true);
    assert!(events
        .iter()
        .any(|event| event.event_type == "prestige_level_track_reset"));
    assert!(events
        .iter()
        .any(|event| event.event_type == "prestige_counter_reset"));
    assert!(events
        .iter()
        .any(|event| event.event_type == "prestige_applied"));
}

#[test]
fn collections_track_manual_entries_hidden_items_and_meta_achievements() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "collections".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_achievement(
            "boss_slayer",
            AchievementDefinition {
                id: "boss_slayer".to_string(),
                title: "Boss Slayer".to_string(),
                description: String::new(),
                hidden: false,
                repeatable: false,
                condition: None,
                counter_trigger: None,
                reward_payload: None,
            },
        )
        .expect("achievement");
    store
        .define_achievement(
            "museum_complete",
            AchievementDefinition {
                id: "museum_complete".to_string(),
                title: "Museum Complete".to_string(),
                description: String::new(),
                hidden: false,
                repeatable: false,
                condition: None,
                counter_trigger: None,
                reward_payload: None,
            },
        )
        .expect("meta");
    store
        .define_collection(
            "museum",
            CollectionDefinition {
                id: "museum".to_string(),
                title: "Museum".to_string(),
                description: "Collect lore and trophies".to_string(),
                items: vec![
                    CollectionItemDefinition {
                        id: "boss_trophy".to_string(),
                        title: "Boss Trophy".to_string(),
                        hidden: false,
                        achievement_id: Some("boss_slayer".to_string()),
                    },
                    CollectionItemDefinition {
                        id: "secret_codex".to_string(),
                        title: "Secret Codex".to_string(),
                        hidden: true,
                        achievement_id: None,
                    },
                ],
                meta_achievement_id: Some("museum_complete".to_string()),
            },
        )
        .expect("collection");

    store
        .unlock_achievement("player", "boss_slayer")
        .expect("unlock");
    let partial = store.get_collection("player", "museum").expect("partial");
    let hidden_before = partial["items"]
        .as_array()
        .expect("items")
        .iter()
        .find(|item| item["id"] == "secret_codex")
        .cloned()
        .expect("hidden item");
    assert_eq!(partial["completion"], 0.5);
    assert_eq!(hidden_before["title"], JsonValue::Null);
    assert_eq!(hidden_before["discovered"], false);

    let completed = store
        .collect_collection_item("player", "museum", "secret_codex")
        .expect("collect");
    let meta = store
        .get_achievement("player", "museum_complete")
        .expect("meta state");

    assert_eq!(completed["complete"], true);
    assert_eq!(completed["collected_count"], 2);
    assert_eq!(completed["items"][1]["title"], "Secret Codex");
    assert_eq!(meta["unlocked"], true);
}

#[test]
fn challenge_templates_track_counter_progress_rewards_and_expiry() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "challenges".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_challenge_template(
            "win_streak",
            ChallengeTemplateDefinition {
                id: "win_streak".to_string(),
                title: "Win Streak".to_string(),
                description: "Win three matches".to_string(),
                required: 3.0,
                counter_id: Some("wins".to_string()),
                duration: None,
                repeatable: false,
                max_completions: None,
                tags: vec!["daily".to_string()],
                reward_payload: Some(serde_json::json!({ "currency": 25 })),
            },
        )
        .expect("challenge");
    store
        .define_challenge_template(
            "timed_route",
            ChallengeTemplateDefinition {
                id: "timed_route".to_string(),
                title: "Timed Route".to_string(),
                description: "Reach the gate before sunset".to_string(),
                required: 1.0,
                counter_id: None,
                duration: Some(5.0),
                repeatable: true,
                max_completions: Some(2),
                tags: vec!["timed".to_string()],
                reward_payload: None,
            },
        )
        .expect("timed challenge");

    let initial = store
        .activate_challenge("player", "win_streak", None)
        .expect("activate counter challenge");
    assert_eq!(initial["status"], "active");
    assert_eq!(initial["tags"][0], "daily");
    store.add_counter("player", "wins", 2.0).expect("wins 2");
    assert_eq!(
        store.get_challenge("player", "win_streak").expect("mid")["current"],
        2.0
    );
    store.add_counter("player", "wins", 1.0).expect("wins 3");

    let completed = store
        .get_challenge("player", "win_streak")
        .expect("completed");
    let completed_list = store
        .list_challenges("player", Some("completed"))
        .expect("completed list");
    let rewards = store
        .get_pending_rewards("player")
        .expect("pending rewards");

    assert_eq!(completed["status"], "completed");
    assert_eq!(completed["completion_count"], 1);
    assert_eq!(completed_list.len(), 1);
    assert_eq!(rewards.len(), 1);
    assert_eq!(rewards[0].source_kind, "challenge");

    store
        .activate_challenge("player", "timed_route", Some(0.0))
        .expect("activate timed challenge");
    store.advance_time(6.0).expect("advance");
    let expired = store
        .get_challenge("player", "timed_route")
        .expect("expired");

    assert_eq!(expired["status"], "expired");
    assert_eq!(
        store
            .list_challenges("player", Some("expired"))
            .expect("expired list")
            .len(),
        1
    );
    assert!(store
        .list_events()
        .iter()
        .any(|event| event.event_type == "challenge_completed"));
    assert!(store
        .list_events()
        .iter()
        .any(|event| event.event_type == "challenge_expired"));
}

#[test]
fn changeset_merge_policies_report_conflicts_and_respect_resolution_mode() {
    let mut source = seeded_sync_store("merge_source");
    source
        .add_counter("player", "wins", 1.0)
        .expect("source wins");
    source
        .accept_quest("player", "cleanup")
        .expect("source accept");
    let envelope = source.export_changeset(0, None).expect("envelope");

    let mut keep_local = seeded_sync_store("merge_keep_local");
    keep_local
        .create_profile("local_only", ProfileOptions::default())
        .expect("local only");
    keep_local
        .add_counter("player", "wins", 5.0)
        .expect("local wins");
    keep_local
        .accept_quest("player", "cleanup")
        .expect("local accept");
    keep_local
        .set_quest_objective("player", "cleanup", "step", 1.0)
        .expect("local complete");
    let kept = keep_local
        .apply_changeset_envelope_with_options(
            envelope.clone(),
            ChangesetApplyOptions {
                merge_policy: ChangesetMergePolicy::KeepLocal,
                ..ChangesetApplyOptions::default()
            },
        )
        .expect("keep local");
    assert_eq!(kept["applied"], false);
    assert_eq!(kept["reason"], "kept_local_due_to_conflicts");
    assert!(kept["conflictCount"].as_u64().unwrap_or(0) >= 2);
    assert!(keep_local.has_profile("local_only"));
    assert_eq!(
        keep_local.get_counter("player", "wins").expect("kept wins"),
        5.0
    );
    assert!(kept["conflicts"]
        .as_array()
        .expect("conflicts")
        .iter()
        .any(|conflict| conflict["kind"] == "quest_branch_diverged"));
    assert!(kept["conflicts"]
        .as_array()
        .expect("conflicts")
        .iter()
        .any(|conflict| conflict["kind"] == "profile_missing_in_source"));

    let mut replace = seeded_sync_store("merge_replace");
    replace
        .create_profile("local_only", ProfileOptions::default())
        .expect("local only");
    replace
        .add_counter("player", "wins", 5.0)
        .expect("local wins");
    replace
        .accept_quest("player", "cleanup")
        .expect("local accept");
    replace
        .set_quest_objective("player", "cleanup", "step", 1.0)
        .expect("local complete");
    let replaced = replace
        .apply_changeset_envelope_with_options(
            envelope.clone(),
            ChangesetApplyOptions {
                merge_policy: ChangesetMergePolicy::Replace,
                ..ChangesetApplyOptions::default()
            },
        )
        .expect("replace");
    assert_eq!(replaced["applied"], true);
    assert_eq!(replaced["reason"], "replaced_with_conflicts");
    assert!(!replace.has_profile("local_only"));
    assert_eq!(
        replace.get_counter("player", "wins").expect("source wins"),
        1.0
    );
    assert_eq!(
        replace
            .get_quest_state("player", "cleanup")
            .expect("source quest")["status"],
        "active"
    );

    let mut rejected = seeded_sync_store("merge_reject");
    rejected
        .create_profile("local_only", ProfileOptions::default())
        .expect("local only");
    rejected
        .add_counter("player", "wins", 5.0)
        .expect("local wins");
    rejected
        .accept_quest("player", "cleanup")
        .expect("local accept");
    rejected
        .set_quest_objective("player", "cleanup", "step", 1.0)
        .expect("local complete");
    let rejected_report = rejected
        .apply_changeset_envelope_with_options(
            envelope,
            ChangesetApplyOptions {
                merge_policy: ChangesetMergePolicy::RejectConflicts,
                ..ChangesetApplyOptions::default()
            },
        )
        .expect("reject conflicts");
    assert_eq!(rejected_report["applied"], false);
    assert_eq!(rejected_report["reason"], "conflict");
    assert!(rejected.has_profile("local_only"));
    assert_eq!(
        rejected
            .get_counter("player", "wins")
            .expect("rejected wins"),
        5.0
    );
}

#[test]
fn rivals_emit_overtake_events_and_activity_feed_filters_events() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "rivals".to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("player");
    store
        .create_profile("rival", ProfileOptions::default())
        .expect("rival");
    store
        .define_leaderboard(
            "arena",
            LeaderboardDefinition {
                id: "arena".to_string(),
                title: "Arena".to_string(),
                sort: LeaderboardSort::Descending,
                rank_mode: LeaderboardRankMode::Ordinal,
                max_entries: Some(10),
                counter_id: None,
            },
        )
        .expect("leaderboard");
    store
        .submit_score("player", "arena", 5.0)
        .expect("player score");
    store
        .submit_score("rival", "arena", 6.0)
        .expect("rival score");
    store
        .pin_rival("player", "rival", Some("arena".to_string()))
        .expect("pin");

    let delta_before = store
        .get_rival_delta("player", "rival")
        .expect("delta before");
    store
        .submit_score("player", "arena", 8.0)
        .expect("overtake");
    let delta_after = store
        .get_rival_delta("player", "rival")
        .expect("delta after");
    let feed = store
        .get_activity_feed(
            Some(vec!["player".to_string()]),
            Some(vec!["profile_overtook_rival".to_string()]),
            Some(10),
        )
        .expect("feed");

    assert_eq!(delta_before["profile_rank"], 2);
    assert_eq!(delta_before["rival_rank"], 1);
    assert_eq!(delta_after["profile_rank"], 1);
    assert_eq!(delta_after["rival_rank"], 2);
    assert_eq!(feed.len(), 1);
    assert_eq!(feed[0]["event_type"], "profile_overtook_rival");
    assert_eq!(feed[0]["payload"]["rivalProfileId"], "rival");
}

#[test]
fn populations_generate_deterministically_from_the_same_seed() {
    let mut first = ProgressionStore::new(ProgressionStoreOptions {
        id: "population_first".to_string(),
        seed: 17,
        ..ProgressionStoreOptions::default()
    })
    .expect("first");
    let mut second = ProgressionStore::new(ProgressionStoreOptions {
        id: "population_second".to_string(),
        seed: 17,
        ..ProgressionStoreOptions::default()
    })
    .expect("second");
    let template = sample_population_template();

    for store in [&mut first, &mut second] {
        store
            .define_leaderboard(
                "arena",
                LeaderboardDefinition {
                    id: "arena".to_string(),
                    title: "Arena".to_string(),
                    sort: LeaderboardSort::Descending,
                    rank_mode: LeaderboardRankMode::Ordinal,
                    max_entries: Some(10),
                    counter_id: None,
                },
            )
            .expect("leaderboard");
        store
            .define_population_template("bots", template.clone())
            .expect("template");
    }

    let first_population = first
        .generate_population("bots", Some("bots_run".to_string()))
        .expect("generate first");
    let second_population = second
        .generate_population("bots", Some("bots_run".to_string()))
        .expect("generate second");
    let first_profiles = first
        .list_population_profiles("bots_run", None, None)
        .expect("profiles first");
    let second_profiles = second
        .list_population_profiles("bots_run", None, None)
        .expect("profiles second");

    assert_eq!(first_population["generated_count"], 3);
    assert_eq!(first_population, second_population);
    assert_eq!(first_profiles, second_profiles);
}

#[test]
fn virtual_population_profiles_participate_and_materialize_without_double_counting() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "population_materialize".to_string(),
        seed: 17,
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("player");
    store
        .define_leaderboard(
            "arena",
            LeaderboardDefinition {
                id: "arena".to_string(),
                title: "Arena".to_string(),
                sort: LeaderboardSort::Descending,
                rank_mode: LeaderboardRankMode::Ordinal,
                max_entries: Some(10),
                counter_id: None,
            },
        )
        .expect("leaderboard");
    store
        .submit_score("player", "arena", 1.0)
        .expect("player score");
    store
        .define_population_template("bots", sample_population_template())
        .expect("template");
    store
        .generate_population("bots", Some("bots_run".to_string()))
        .expect("generate");

    let before = store
        .list_leaderboard_top("arena", Some(4))
        .expect("before");
    let virtual_profile_id = before[0]["profile_id"]
        .as_str()
        .expect("virtual id")
        .to_string();
    let materialized = store
        .materialize_population_profile(&virtual_profile_id)
        .expect("materialize");
    let after_materialize = store
        .list_leaderboard_top("arena", Some(4))
        .expect("after materialize");
    let dematerialized = store
        .dematerialize_population_profile(&virtual_profile_id, true)
        .expect("dematerialize");
    let after_dematerialize = store
        .list_leaderboard_top("arena", Some(4))
        .expect("after dematerialize");

    assert_eq!(before.len(), 4);
    assert_eq!(materialized["id"], virtual_profile_id);
    assert_eq!(after_materialize.len(), 4);
    assert_eq!(
        after_materialize
            .iter()
            .filter(|entry| entry["profile_id"] == virtual_profile_id)
            .count(),
        1
    );
    assert!(dematerialized);
    assert_eq!(after_dematerialize.len(), 4);
}

#[test]
fn store_update_advances_active_population_simulation() {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: "population_update_loop".to_string(),
        seed: 17,
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .define_leaderboard(
            "arena",
            LeaderboardDefinition {
                id: "arena".to_string(),
                title: "Arena".to_string(),
                sort: LeaderboardSort::Descending,
                rank_mode: LeaderboardRankMode::Ordinal,
                max_entries: Some(10),
                counter_id: None,
            },
        )
        .expect("leaderboard");
    store
        .define_population_template("bots", sample_population_template())
        .expect("template");
    store
        .generate_population("bots", Some("bots_run".to_string()))
        .expect("generate");

    let before = store
        .list_population_profiles("bots_run", None, Some(1))
        .expect("before");
    let report = store.update(3.0).expect("update");
    let after = store
        .list_population_profiles("bots_run", None, Some(1))
        .expect("after");

    assert_eq!(report["time"], 3.0);
    assert_eq!(report["population_updates"], 1);
    assert_eq!(
        store.get_population("bots_run").expect("population")["logical_time"],
        3.0
    );
    assert_ne!(
        before[0]["leaderboard_scores"]["arena"],
        after[0]["leaderboard_scores"]["arena"]
    );
}

fn sample_population_template() -> PopulationTemplateDefinition {
    PopulationTemplateDefinition {
        id: "bots".to_string(),
        id_prefix: "bot_".to_string(),
        count: 3,
        identity: PopulationIdentityDefinition {
            name_generator: PopulationNameGeneratorDefinition {
                mode: "parts".to_string(),
                prefixes: vec!["Iron".to_string(), "Silver".to_string()],
                suffixes: vec!["Fox".to_string(), "Wing".to_string()],
            },
            avatars: vec!["bots/a.png".to_string(), "bots/b.png".to_string()],
            tags: vec!["bot".to_string(), "ranked".to_string()],
        },
        archetypes: vec![
            PopulationArchetypeDefinition {
                id: "steady".to_string(),
                weight: 2,
                activity: PopulationActivityDefinition { min: 1, max: 2 },
                skill: PopulationSkillDefinition {
                    mean: 1200.0,
                    deviation: 20.0,
                },
            },
            PopulationArchetypeDefinition {
                id: "volatile".to_string(),
                weight: 1,
                activity: PopulationActivityDefinition { min: 2, max: 4 },
                skill: PopulationSkillDefinition {
                    mean: 1180.0,
                    deviation: 35.0,
                },
            },
        ],
        leaderboards: BTreeMap::from([(
            "arena".to_string(),
            PopulationLeaderboardDefinition {
                category: Some("ranked".to_string()),
                initial_score: PopulationInitialScoreDefinition {
                    distribution: "normal".to_string(),
                },
                progression: PopulationScoreProgressionDefinition {
                    mode: "bounded_random_walk".to_string(),
                    volatility: 4.0,
                    mean_reversion: 0.2,
                },
            },
        )]),
    }
}

fn seeded_sync_store(id: &str) -> ProgressionStore {
    let mut store = ProgressionStore::new(ProgressionStoreOptions {
        id: id.to_string(),
        ..ProgressionStoreOptions::default()
    })
    .expect("store");
    store
        .define_counter(
            "wins",
            CounterDefinition {
                kind: CounterKind::CumulativeInteger,
                initial: 0.0,
                min: Some(0.0),
                max: None,
                monotonic: true,
                thresholds: vec![],
            },
        )
        .expect("counter");
    store
        .define_quest(
            "cleanup",
            QuestDefinition {
                id: "cleanup".to_string(),
                title: "Cleanup".to_string(),
                description: String::new(),
                stages: vec![QuestStageDefinition {
                    id: "stage_1".to_string(),
                    name: "Stage".to_string(),
                    objectives: vec![QuestObjectiveDefinition {
                        id: "step".to_string(),
                        description: "One step".to_string(),
                        required: 1.0,
                        mandatory: true,
                        visible: true,
                        counter_id: None,
                    }],
                }],
                max_journal_entries: None,
                reveal_condition: None,
                availability_condition: None,
                reward_payload: None,
            },
        )
        .expect("quest");
    store
        .create_profile("player", ProfileOptions::default())
        .expect("profile");
    store
}
