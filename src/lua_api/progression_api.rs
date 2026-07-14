//! Registers the public `lurek.progression` Lua API for deterministic offline progression state
//! and owns its typed userdata wrappers.

use self::progression_objects_api_impl::{
    achievement, activity_feed, challenge, collection, leaderboard_entry, population,
    population_profile, prestige, quest_state_bound, reward_bound, rival, rival_delta, season,
    season_archive, userdata_list,
};
use super::SharedState;
use crate::progression::{
    AchievementDefinition, AttributeDefinition, AttributeMode, ChallengeTemplateDefinition,
    ChangesetApplyOptions, ChangesetMergePolicy, CollectionDefinition, CollectionItemDefinition,
    ComparisonOp, CounterDefinition, CounterKind, CounterTriggerDefinition, DerivedValueDefinition,
    DerivedValueInput, LeaderboardDefinition, LeaderboardRankMode, LeaderboardSort,
    LevelTrackDefinition, ModifierAddOptions, PerkDefinition, PopulationTemplateDefinition,
    PrestigeDefinition, PrestigePreserveDefinition, PrestigeResetDefinition, ProfileOptions,
    ProfileTemplateDefinition, ProgressionCondition, ProgressionStore, ProgressionStoreOptions,
    ProgressionTransaction, QuestDefinition, QuestObjectiveDefinition, QuestStageDefinition,
    ResourceDefinition, SeasonDefinition, SeasonResetDefinition, SkillDefinition, TraitDefinition,
    TraitModifierDefinition,
};
use mlua::prelude::*;
use mlua::{AnyUserData, UserData, UserDataMethods, Value as LuaValue};
use serde_json::{Map as JsonMap, Number as JsonNumber, Value as JsonValue};
use std::cell::RefCell;
use std::collections::BTreeMap;
use std::rc::Rc;

fn progression_error(method: &str, err: impl std::fmt::Display) -> LuaError {
    LuaError::RuntimeError(format!("lurek.progression.{method}: {err}"))
}

fn json_to_lua<'lua>(lua: &'lua Lua, val: JsonValue) -> LuaResult<LuaValue<'lua>> {
    match val {
        JsonValue::Null => Ok(LuaValue::Nil),
        JsonValue::Bool(value) => Ok(LuaValue::Boolean(value)),
        JsonValue::Number(value) => {
            if let Some(integer) = value.as_i64() {
                Ok(LuaValue::Integer(integer))
            } else {
                Ok(LuaValue::Number(value.as_f64().unwrap_or(0.0)))
            }
        }
        JsonValue::String(value) => Ok(LuaValue::String(lua.create_string(&value)?)),
        JsonValue::Array(values) => {
            let table = lua.create_table()?;
            for (index, value) in values.into_iter().enumerate() {
                table.set(index + 1, json_to_lua(lua, value)?)?;
            }
            Ok(LuaValue::Table(table))
        }
        JsonValue::Object(values) => {
            let table = lua.create_table()?;
            for (key, value) in values {
                table.set(key, json_to_lua(lua, value)?)?;
            }
            Ok(LuaValue::Table(table))
        }
    }
}

fn lua_to_json(value: LuaValue) -> LuaResult<JsonValue> {
    match value {
        LuaValue::Nil => Ok(JsonValue::Null),
        LuaValue::Boolean(value) => Ok(JsonValue::Bool(value)),
        LuaValue::Integer(value) => Ok(JsonValue::Number(JsonNumber::from(value))),
        LuaValue::Number(value) => JsonNumber::from_f64(value)
            .map(JsonValue::Number)
            .ok_or_else(|| LuaError::RuntimeError("non-finite Lua number".to_string())),
        LuaValue::String(value) => Ok(JsonValue::String(value.to_str()?.to_string())),
        LuaValue::Table(table) => {
            let len = table.raw_len();
            if len > 0 {
                let mut out = Vec::with_capacity(len);
                for pair in table.sequence_values::<LuaValue>() {
                    out.push(lua_to_json(pair?)?);
                }
                Ok(JsonValue::Array(out))
            } else {
                let mut out = JsonMap::new();
                for pair in table.pairs::<String, LuaValue>() {
                    let (key, value) = pair?;
                    out.insert(key, lua_to_json(value)?);
                }
                Ok(JsonValue::Object(out))
            }
        }
        _ => Err(LuaError::RuntimeError(
            "unsupported Lua value for progression metadata".to_string(),
        )),
    }
}

fn snapshot_arg_to_json(value: LuaValue) -> LuaResult<JsonValue> {
    match value {
        LuaValue::String(text) => serde_json::from_str(text.to_str()?)
            .map_err(|err| LuaError::RuntimeError(format!("invalid snapshot JSON: {err}"))),
        other => lua_to_json(other),
    }
}

#[derive(Clone)]
struct LuaProgressionStore {
    store: Rc<RefCell<ProgressionStore>>,
}

#[derive(Clone)]
struct LuaProfileHandle {
    id: String,
    store: Rc<RefCell<ProgressionStore>>,
}

#[derive(Clone)]
struct LuaProgressionTransaction {
    store: Rc<RefCell<ProgressionStore>>,
    tx: Rc<RefCell<ProgressionTransaction>>,
}

type LegacyAddBuffArgs<'lua> = (
    LuaTable<'lua>,
    String,
    f64,
    Option<f64>,
    Option<f64>,
    Option<String>,
    Option<String>,
);

fn store_from_userdata(data: AnyUserData) -> LuaResult<Rc<RefCell<ProgressionStore>>> {
    Ok(data.borrow::<LuaProgressionStore>()?.store.clone())
}

fn profile_id_from_userdata(data: AnyUserData) -> LuaResult<String> {
    Ok(data.borrow::<LuaProfileHandle>()?.id.clone())
}

fn parse_profile_options(table: Option<LuaTable>) -> LuaResult<ProfileOptions> {
    let Some(table) = table else {
        return Ok(ProfileOptions::default());
    };
    let kind = table.get::<_, Option<String>>("kind")?;
    let display_name = table.get::<_, Option<String>>("display_name")?;
    let avatar = table.get::<_, Option<String>>("avatar")?;
    let template = table.get::<_, Option<String>>("template")?;
    let tags = if let Ok(tag_table) = table.get::<_, LuaTable>("tags") {
        tag_table
            .sequence_values::<String>()
            .collect::<LuaResult<Vec<_>>>()?
    } else {
        Vec::new()
    };
    let metadata = if let Ok(metadata_table) = table.get::<_, LuaTable>("metadata") {
        let mut out = BTreeMap::new();
        for pair in metadata_table.pairs::<String, LuaValue>() {
            let (key, value) = pair?;
            out.insert(key, lua_to_json(value)?);
        }
        out
    } else {
        BTreeMap::new()
    };
    Ok(ProfileOptions {
        kind,
        display_name,
        avatar,
        tags,
        metadata,
        template,
    })
}

fn parse_counter_kind(name: &str) -> LuaResult<CounterKind> {
    match name {
        "integer" => Ok(CounterKind::Integer),
        "number" => Ok(CounterKind::Number),
        "gauge" => Ok(CounterKind::Gauge),
        "cumulative_integer" => Ok(CounterKind::CumulativeInteger),
        "cumulative_number" => Ok(CounterKind::CumulativeNumber),
        "boolean" => Ok(CounterKind::Boolean),
        other => Err(LuaError::RuntimeError(format!(
            "lurek.progression.defineCounter: unknown counter kind '{other}'"
        ))),
    }
}

fn parse_counter_definition(table: LuaTable) -> LuaResult<CounterDefinition> {
    let kind = parse_counter_kind(&table.get::<_, String>("kind")?)?;
    let initial = table.get::<_, Option<f64>>("initial")?.unwrap_or(0.0);
    let min = table.get::<_, Option<f64>>("min")?;
    let max = table.get::<_, Option<f64>>("max")?;
    let monotonic = table.get::<_, Option<bool>>("monotonic")?.unwrap_or(false);
    let thresholds = if let Ok(thresholds_table) = table.get::<_, LuaTable>("thresholds") {
        let mut thresholds = Vec::new();
        for value in thresholds_table.sequence_values::<LuaValue>() {
            match value? {
                LuaValue::Number(number) => thresholds.push(number),
                LuaValue::Integer(integer) => thresholds.push(integer as f64),
                LuaValue::Table(entry) => {
                    thresholds.push(entry.get::<_, f64>("value")?);
                }
                _ => {}
            }
        }
        thresholds
    } else {
        Vec::new()
    };
    Ok(CounterDefinition {
        kind,
        initial,
        min,
        max,
        monotonic,
        thresholds,
    })
}

fn parse_attribute_definition(table: LuaTable) -> LuaResult<AttributeDefinition> {
    Ok(AttributeDefinition {
        base: table.get::<_, Option<f64>>("base")?.unwrap_or(0.0),
        min: table.get::<_, Option<f64>>("min")?,
        max: table.get::<_, Option<f64>>("max")?,
        regen: table.get::<_, Option<f64>>("regen")?.unwrap_or(0.0),
        growth: table.get::<_, Option<f64>>("growth")?.unwrap_or(0.0),
    })
}

fn parse_resource_definition(table: LuaTable) -> LuaResult<ResourceDefinition> {
    Ok(ResourceDefinition {
        initial: table.get::<_, Option<f64>>("initial")?.unwrap_or(0.0),
        min: table.get::<_, Option<f64>>("min")?.unwrap_or(0.0),
        max: table.get::<_, Option<f64>>("max")?.unwrap_or(0.0),
        regeneration: table.get::<_, Option<f64>>("regeneration")?.unwrap_or(0.0),
        refill: table
            .get::<_, Option<String>>("refill")?
            .unwrap_or_else(|| "manual".to_string()),
    })
}

fn parse_level_track_definition(table: LuaTable) -> LuaResult<LevelTrackDefinition> {
    let curve = table.get::<_, Option<LuaTable>>("curve")?;
    let base_xp = curve
        .as_ref()
        .and_then(|curve| curve.get::<_, Option<f64>>("base").ok().flatten())
        .unwrap_or(100.0);
    let increment_xp = curve
        .as_ref()
        .and_then(|curve| curve.get::<_, Option<f64>>("increment").ok().flatten())
        .unwrap_or(100.0);
    Ok(LevelTrackDefinition {
        initial_level: table.get::<_, Option<u32>>("initial_level")?.unwrap_or(1),
        max_level: table.get::<_, Option<u32>>("max_level")?.unwrap_or(100),
        base_xp,
        increment_xp,
        carry_over: table.get::<_, Option<bool>>("carry_over")?.unwrap_or(true),
        allow_level_down: table
            .get::<_, Option<bool>>("allow_level_down")?
            .unwrap_or(false),
    })
}

fn parse_derived_value_input(table: LuaTable) -> LuaResult<DerivedValueInput> {
    let kind = table
        .get::<_, Option<String>>("kind")?
        .unwrap_or_else(|| "counter".to_string());
    match kind.as_str() {
        "counter" => Ok(DerivedValueInput::Counter {
            counter_id: table.get::<_, String>("counter_id")?,
        }),
        "attribute" => Ok(DerivedValueInput::Attribute {
            attribute_id: table.get::<_, String>("attribute_id")?,
            mode: parse_attribute_mode(table.get::<_, Option<String>>("mode")?)?,
        }),
        "resource" => Ok(DerivedValueInput::Resource {
            resource_id: table.get::<_, String>("resource_id")?,
        }),
        "level" => Ok(DerivedValueInput::Level {
            track_id: table.get::<_, String>("track_id")?,
        }),
        "experience" => Ok(DerivedValueInput::Experience {
            track_id: table.get::<_, String>("track_id")?,
        }),
        other => Err(LuaError::RuntimeError(format!(
            "lurek.progression.defineDerivedValue: unknown derived input kind '{other}'"
        ))),
    }
}

fn parse_derived_value_definition(table: LuaTable) -> LuaResult<DerivedValueDefinition> {
    let inputs = if let Ok(input_table) = table.get::<_, LuaTable>("inputs") {
        let mut out = BTreeMap::new();
        for pair in input_table.pairs::<String, LuaTable>() {
            let (name, value) = pair?;
            out.insert(name, parse_derived_value_input(value)?);
        }
        out
    } else {
        BTreeMap::new()
    };
    Ok(DerivedValueDefinition {
        expression: table.get::<_, String>("expression")?,
        inputs,
        min: table.get::<_, Option<f64>>("min")?,
        max: table.get::<_, Option<f64>>("max")?,
        round: table.get::<_, Option<String>>("round")?,
    })
}

fn parse_profile_template_definition(table: LuaTable) -> LuaResult<ProfileTemplateDefinition> {
    let counters = if let Ok(counter_table) = table.get::<_, LuaTable>("counters") {
        let mut out = BTreeMap::new();
        for pair in counter_table.pairs::<String, f64>() {
            let (id, value) = pair?;
            out.insert(id, value);
        }
        out
    } else {
        BTreeMap::new()
    };
    let attributes = if let Ok(attribute_table) = table.get::<_, LuaTable>("attributes") {
        let mut out = BTreeMap::new();
        for pair in attribute_table.pairs::<String, f64>() {
            let (id, value) = pair?;
            out.insert(id, value);
        }
        out
    } else {
        BTreeMap::new()
    };
    let resources = if let Ok(resource_table) = table.get::<_, LuaTable>("resources") {
        let mut out = BTreeMap::new();
        for pair in resource_table.pairs::<String, f64>() {
            let (id, value) = pair?;
            out.insert(id, value);
        }
        out
    } else {
        BTreeMap::new()
    };
    let experience = if let Ok(experience_table) = table.get::<_, LuaTable>("experience") {
        let mut out = BTreeMap::new();
        for pair in experience_table.pairs::<String, f64>() {
            let (id, value) = pair?;
            out.insert(id, value);
        }
        out
    } else {
        BTreeMap::new()
    };
    let tags = if let Ok(tag_table) = table.get::<_, LuaTable>("tags") {
        tag_table
            .sequence_values::<String>()
            .collect::<LuaResult<Vec<_>>>()?
    } else {
        Vec::new()
    };
    let metadata = if let Ok(metadata_table) = table.get::<_, LuaTable>("metadata") {
        let mut out = BTreeMap::new();
        for pair in metadata_table.pairs::<String, LuaValue>() {
            let (key, value) = pair?;
            out.insert(key, lua_to_json(value)?);
        }
        out
    } else {
        BTreeMap::new()
    };
    Ok(ProfileTemplateDefinition {
        kind: table.get::<_, Option<String>>("kind")?,
        display_name: table.get::<_, Option<String>>("display_name")?,
        avatar: table.get::<_, Option<String>>("avatar")?,
        counters,
        attributes,
        resources,
        experience,
        tags,
        metadata,
    })
}

fn parse_trait_definition(table: LuaTable) -> LuaResult<TraitDefinition> {
    let modifiers = if let Ok(modifier_table) = table.get::<_, LuaTable>("modifiers") {
        let mut out = Vec::new();
        for value in modifier_table.sequence_values::<LuaTable>() {
            let modifier = value?;
            out.push(TraitModifierDefinition {
                target_id: modifier
                    .get::<_, Option<String>>("target_id")?
                    .or_else(|| modifier.get::<_, Option<String>>("target").ok().flatten())
                    .ok_or_else(|| {
                        LuaError::RuntimeError("trait modifier missing target_id".to_string())
                    })?,
                layer: modifier.get::<_, Option<String>>("layer")?,
                value: modifier
                    .get::<_, Option<f64>>("value")?
                    .or_else(|| modifier.get::<_, Option<f64>>("add").ok().flatten())
                    .unwrap_or(0.0),
            });
        }
        out
    } else {
        Vec::new()
    };
    Ok(TraitDefinition { modifiers })
}

fn parse_perk_definition(table: LuaTable) -> LuaResult<PerkDefinition> {
    let trait_ids = if let Ok(trait_table) = table.get::<_, LuaTable>("trait_ids") {
        trait_table
            .sequence_values::<String>()
            .collect::<LuaResult<Vec<_>>>()?
    } else if let Some(trait_name) = table.get::<_, Option<String>>("trait_name")? {
        vec![trait_name]
    } else {
        Vec::new()
    };
    Ok(PerkDefinition {
        require_level: table.get::<_, Option<u32>>("require_level")?.unwrap_or(0),
        track_id: table.get::<_, Option<String>>("track_id")?,
        trait_ids,
    })
}

fn parse_skill_definition(table: LuaTable) -> LuaResult<SkillDefinition> {
    Ok(SkillDefinition {
        max_level: table.get::<_, Option<u32>>("max_level")?.unwrap_or(10),
        resource_id: table.get::<_, Option<String>>("resource")?,
        cost: table.get::<_, Option<f64>>("cost")?.unwrap_or(0.0),
        cooldown: table.get::<_, Option<f64>>("cooldown")?.unwrap_or(0.0),
    })
}

fn parse_leaderboard_sort(name: Option<String>) -> LuaResult<LeaderboardSort> {
    match name.as_deref().unwrap_or("descending") {
        "descending" => Ok(LeaderboardSort::Descending),
        "ascending" => Ok(LeaderboardSort::Ascending),
        other => Err(LuaError::RuntimeError(format!(
            "lurek.progression.defineLeaderboard: unknown sort '{other}'"
        ))),
    }
}

fn parse_leaderboard_rank_mode(name: Option<String>) -> LuaResult<LeaderboardRankMode> {
    match name.as_deref().unwrap_or("ordinal") {
        "ordinal" => Ok(LeaderboardRankMode::Ordinal),
        "dense" => Ok(LeaderboardRankMode::Dense),
        "competition" => Ok(LeaderboardRankMode::Competition),
        other => Err(LuaError::RuntimeError(format!(
            "lurek.progression.defineLeaderboard: unknown rank mode '{other}'"
        ))),
    }
}

fn parse_leaderboard_definition(table: LuaTable, id: &str) -> LuaResult<LeaderboardDefinition> {
    Ok(LeaderboardDefinition {
        id: id.to_string(),
        title: table
            .get::<_, Option<String>>("title")?
            .unwrap_or_else(|| id.to_string()),
        sort: parse_leaderboard_sort(table.get::<_, Option<String>>("sort")?)?,
        rank_mode: parse_leaderboard_rank_mode(table.get::<_, Option<String>>("rank_mode")?)?,
        max_entries: table.get::<_, Option<usize>>("max_entries")?,
        counter_id: table.get::<_, Option<String>>("counter_id")?,
    })
}

fn parse_season_definition(table: LuaTable, id: &str) -> LuaResult<SeasonDefinition> {
    let reset = match table.get::<_, Option<LuaTable>>("reset")? {
        Some(reset_table) => SeasonResetDefinition {
            leaderboards: match reset_table.get::<_, Option<LuaTable>>("leaderboards")? {
                Some(values) => values
                    .sequence_values::<String>()
                    .collect::<LuaResult<Vec<_>>>()?,
                None => Vec::new(),
            },
            counters: match reset_table.get::<_, Option<LuaTable>>("counters")? {
                Some(values) => values
                    .sequence_values::<String>()
                    .collect::<LuaResult<Vec<_>>>()?,
                None => Vec::new(),
            },
        },
        None => SeasonResetDefinition::default(),
    };
    Ok(SeasonDefinition {
        id: id.to_string(),
        starts_at: table.get::<_, Option<f64>>("starts_at")?.unwrap_or(0.0),
        ends_at: table.get::<_, Option<f64>>("ends_at")?.unwrap_or(0.0),
        reset,
        archive: table.get::<_, Option<bool>>("archive")?.unwrap_or(false),
    })
}

fn parse_prestige_definition(table: LuaTable, id: &str) -> LuaResult<PrestigeDefinition> {
    let condition = match table.get::<_, Option<LuaTable>>("condition")? {
        Some(condition) => parse_condition_definition(condition)?,
        None => {
            return Err(LuaError::RuntimeError(
                "lurek.progression.definePrestige: missing condition".to_string(),
            ))
        }
    };
    let reset = match table.get::<_, Option<LuaTable>>("reset")? {
        Some(reset_table) => PrestigeResetDefinition {
            level_tracks: match reset_table.get::<_, Option<LuaTable>>("level_tracks")? {
                Some(values) => values
                    .sequence_values::<String>()
                    .collect::<LuaResult<Vec<_>>>()?,
                None => Vec::new(),
            },
            counters: match reset_table.get::<_, Option<LuaTable>>("counters")? {
                Some(values) => values
                    .sequence_values::<String>()
                    .collect::<LuaResult<Vec<_>>>()?,
                None => Vec::new(),
            },
        },
        None => PrestigeResetDefinition::default(),
    };
    let preserve = match table.get::<_, Option<LuaTable>>("preserve")? {
        Some(preserve_table) => PrestigePreserveDefinition {
            achievements: preserve_table
                .get::<_, Option<bool>>("achievements")?
                .unwrap_or(false),
            lifetime_counters: preserve_table
                .get::<_, Option<bool>>("lifetime_counters")?
                .unwrap_or(false),
        },
        None => PrestigePreserveDefinition::default(),
    };
    Ok(PrestigeDefinition {
        id: id.to_string(),
        condition,
        reset,
        preserve,
    })
}

fn parse_collection_definition(table: LuaTable, id: &str) -> LuaResult<CollectionDefinition> {
    let mut items = Vec::new();
    if let Ok(item_table) = table.get::<_, LuaTable>("items") {
        for value in item_table.sequence_values::<LuaTable>() {
            let item = value?;
            items.push(CollectionItemDefinition {
                id: item.get::<_, String>("id")?,
                title: item
                    .get::<_, Option<String>>("title")?
                    .unwrap_or_else(|| "Item".to_string()),
                hidden: item.get::<_, Option<bool>>("hidden")?.unwrap_or(false),
                achievement_id: item.get::<_, Option<String>>("achievement_id")?,
            });
        }
    }
    Ok(CollectionDefinition {
        id: id.to_string(),
        title: table
            .get::<_, Option<String>>("title")?
            .unwrap_or_else(|| id.to_string()),
        description: table
            .get::<_, Option<String>>("description")?
            .unwrap_or_default(),
        items,
        meta_achievement_id: table.get::<_, Option<String>>("meta_achievement_id")?,
    })
}

fn parse_population_template_definition(
    table: LuaTable,
    id: &str,
) -> LuaResult<PopulationTemplateDefinition> {
    let mut value = lua_to_json(LuaValue::Table(table))?;
    let object = value.as_object_mut().ok_or_else(|| {
        LuaError::RuntimeError(
            "lurek.progression.definePopulationTemplate: definition must be a table".to_string(),
        )
    })?;
    object.insert("id".to_string(), JsonValue::String(id.to_string()));
    serde_json::from_value(value).map_err(|err| {
        LuaError::RuntimeError(format!(
            "lurek.progression.definePopulationTemplate: invalid population template: {err}"
        ))
    })
}

fn parse_modifier_options(table: LuaTable) -> LuaResult<ModifierAddOptions> {
    let tags = if let Ok(tag_table) = table.get::<_, LuaTable>("tags") {
        tag_table
            .sequence_values::<String>()
            .collect::<LuaResult<Vec<_>>>()?
    } else {
        Vec::new()
    };
    Ok(ModifierAddOptions {
        layer: table.get::<_, Option<String>>("layer")?,
        value: table.get::<_, Option<f64>>("value")?.unwrap_or(0.0),
        duration: table.get::<_, Option<f64>>("duration")?,
        source: table.get::<_, Option<String>>("source")?,
        tags,
    })
}

fn parse_quest_definition(table: LuaTable, id: &str) -> LuaResult<QuestDefinition> {
    let title = table
        .get::<_, Option<String>>("title")?
        .unwrap_or_else(|| id.to_string());
    let description = table
        .get::<_, Option<String>>("description")?
        .unwrap_or_default();
    let mut stages = Vec::new();
    if let Ok(stage_table) = table.get::<_, LuaTable>("stages") {
        for value in stage_table.sequence_values::<LuaTable>() {
            let stage_table = value?;
            let stage_id = stage_table.get::<_, String>("id")?;
            let name = stage_table
                .get::<_, Option<String>>("name")?
                .unwrap_or_else(|| stage_id.clone());
            let mut objectives = Vec::new();
            if let Ok(objective_table) = stage_table.get::<_, LuaTable>("objectives") {
                for objective in objective_table.sequence_values::<LuaTable>() {
                    let objective = objective?;
                    objectives.push(QuestObjectiveDefinition {
                        id: objective.get::<_, String>("id")?,
                        description: objective
                            .get::<_, Option<String>>("description")?
                            .unwrap_or_default(),
                        required: objective.get::<_, Option<f64>>("required")?.unwrap_or(1.0),
                        mandatory: objective
                            .get::<_, Option<bool>>("mandatory")?
                            .unwrap_or(true),
                        visible: objective.get::<_, Option<bool>>("visible")?.unwrap_or(true),
                        counter_id: objective.get::<_, Option<String>>("counter_id")?,
                    });
                }
            }
            stages.push(QuestStageDefinition {
                id: stage_id,
                name,
                objectives,
            });
        }
    }
    Ok(QuestDefinition {
        id: id.to_string(),
        title,
        description,
        stages,
        max_journal_entries: table.get::<_, Option<usize>>("max_journal_entries")?,
        reveal_condition: match table.get::<_, Option<LuaTable>>("reveal_condition")? {
            Some(condition) => Some(parse_condition_definition(condition)?),
            None => None,
        },
        availability_condition: match table.get::<_, Option<LuaTable>>("availability_condition")? {
            Some(condition) => Some(parse_condition_definition(condition)?),
            None => None,
        },
        reward_payload: match table.get::<_, Option<LuaValue>>("reward_payload")? {
            Some(LuaValue::Nil) | None => None,
            Some(value) => Some(lua_to_json(value)?),
        },
    })
}

fn parse_challenge_template_definition(
    table: LuaTable,
    id: &str,
) -> LuaResult<ChallengeTemplateDefinition> {
    let tags = if let Ok(tag_table) = table.get::<_, LuaTable>("tags") {
        tag_table
            .sequence_values::<String>()
            .collect::<LuaResult<Vec<_>>>()?
    } else {
        Vec::new()
    };
    let reward_payload = match table.get::<_, Option<LuaValue>>("reward_payload")? {
        Some(LuaValue::Nil) | None => None,
        Some(value) => Some(lua_to_json(value)?),
    };
    Ok(ChallengeTemplateDefinition {
        id: id.to_string(),
        title: table
            .get::<_, Option<String>>("title")?
            .unwrap_or_else(|| id.to_string()),
        description: table
            .get::<_, Option<String>>("description")?
            .unwrap_or_default(),
        required: table.get::<_, Option<f64>>("required")?.unwrap_or(1.0),
        counter_id: table.get::<_, Option<String>>("counter_id")?,
        duration: table.get::<_, Option<f64>>("duration")?,
        repeatable: table.get::<_, Option<bool>>("repeatable")?.unwrap_or(false),
        max_completions: table.get::<_, Option<u32>>("max_completions")?,
        tags,
        reward_payload,
    })
}

fn parse_attribute_mode(name: Option<String>) -> LuaResult<AttributeMode> {
    match name.as_deref().unwrap_or("effective") {
        "base" => Ok(AttributeMode::Base),
        "current" => Ok(AttributeMode::Current),
        "effective" => Ok(AttributeMode::Effective),
        "min" => Ok(AttributeMode::Min),
        "max" => Ok(AttributeMode::Max),
        other => Err(LuaError::RuntimeError(format!(
            "lurek.progression.getAttribute: unknown attribute mode '{other}'"
        ))),
    }
}

fn parse_changeset_merge_policy(name: Option<String>) -> LuaResult<ChangesetMergePolicy> {
    match name.as_deref().unwrap_or("replace") {
        "replace" => Ok(ChangesetMergePolicy::Replace),
        "keep_local" => Ok(ChangesetMergePolicy::KeepLocal),
        "reject_conflicts" => Ok(ChangesetMergePolicy::RejectConflicts),
        other => Err(LuaError::RuntimeError(format!(
            "lurek.progression.applyChangesetEnvelope: unknown merge policy '{other}'"
        ))),
    }
}

fn parse_comparison_op(name: &str) -> LuaResult<ComparisonOp> {
    match name {
        ">" => Ok(ComparisonOp::Greater),
        ">=" => Ok(ComparisonOp::GreaterEqual),
        "==" | "=" => Ok(ComparisonOp::Equal),
        "<" => Ok(ComparisonOp::Less),
        "<=" => Ok(ComparisonOp::LessEqual),
        other => Err(LuaError::RuntimeError(format!(
            "lurek.progression.defineAchievement: unknown comparison operator '{other}'"
        ))),
    }
}

fn parse_achievement_definition(table: LuaTable, id: &str) -> LuaResult<AchievementDefinition> {
    let counter_trigger = match table.get::<_, Option<LuaTable>>("counter_trigger")? {
        Some(trigger) => Some(CounterTriggerDefinition {
            counter_id: trigger.get::<_, String>("counter_id")?,
            op: parse_comparison_op(
                &trigger
                    .get::<_, Option<String>>("op")?
                    .unwrap_or_else(|| ">=".to_string()),
            )?,
            value: trigger.get::<_, f64>("value")?,
        }),
        None => None,
    };
    let reward_payload = match table.get::<_, Option<LuaValue>>("reward_payload")? {
        Some(LuaValue::Nil) | None => None,
        Some(value) => Some(lua_to_json(value)?),
    };
    Ok(AchievementDefinition {
        id: id.to_string(),
        title: table
            .get::<_, Option<String>>("title")?
            .unwrap_or_else(|| id.to_string()),
        description: table
            .get::<_, Option<String>>("description")?
            .unwrap_or_default(),
        hidden: table.get::<_, Option<bool>>("hidden")?.unwrap_or(false),
        repeatable: table.get::<_, Option<bool>>("repeatable")?.unwrap_or(false),
        condition: match table.get::<_, Option<LuaTable>>("condition")? {
            Some(condition) => Some(parse_condition_definition(condition)?),
            None => None,
        },
        counter_trigger,
        reward_payload,
    })
}

fn parse_condition_definition(table: LuaTable) -> LuaResult<ProgressionCondition> {
    if let Ok(children) = table.get::<_, LuaTable>("all") {
        let mut conditions = Vec::new();
        for child in children.sequence_values::<LuaTable>() {
            conditions.push(parse_condition_definition(child?)?);
        }
        return Ok(ProgressionCondition::All { conditions });
    }
    if let Ok(children) = table.get::<_, LuaTable>("any") {
        let mut conditions = Vec::new();
        for child in children.sequence_values::<LuaTable>() {
            conditions.push(parse_condition_definition(child?)?);
        }
        return Ok(ProgressionCondition::Any { conditions });
    }
    if let Ok(child) = table.get::<_, LuaTable>("not_") {
        return Ok(ProgressionCondition::Not {
            condition: Box::new(parse_condition_definition(child)?),
        });
    }
    if let Ok(counter_id) = table.get::<_, String>("counter") {
        return Ok(ProgressionCondition::Counter {
            counter_id,
            op: parse_comparison_op(
                &table
                    .get::<_, Option<String>>("op")?
                    .unwrap_or_else(|| ">=".to_string()),
            )?,
            value: table.get::<_, f64>("value")?,
        });
    }
    if let Ok(level) = table.get::<_, LuaTable>("level") {
        return Ok(ProgressionCondition::Level {
            track_id: level.get::<_, String>("track")?,
            op: parse_comparison_op(
                &level
                    .get::<_, Option<String>>("op")?
                    .unwrap_or_else(|| ">=".to_string()),
            )?,
            value: level.get::<_, u32>("value")?,
        });
    }
    if let Ok(achievement_id) = table.get::<_, String>("achievement") {
        return Ok(ProgressionCondition::Achievement {
            achievement_id,
            state: table
                .get::<_, Option<String>>("state")?
                .unwrap_or_else(|| "unlocked".to_string()),
        });
    }
    if let Ok(quest_id) = table.get::<_, String>("quest") {
        return Ok(ProgressionCondition::Quest {
            quest_id,
            state: table
                .get::<_, Option<String>>("state")?
                .unwrap_or_else(|| "completed".to_string()),
        });
    }
    if let Ok(tag) = table.get::<_, String>("tag") {
        return Ok(ProgressionCondition::Tag { tag });
    }
    Err(LuaError::RuntimeError(
        "lurek.progression condition table must define all, any, not_, counter, level, achievement, quest, or tag".to_string(),
    ))
}

fn coerce_profile_id(value: LuaValue) -> LuaResult<String> {
    match value {
        LuaValue::String(value) => Ok(value.to_str()?.to_string()),
        LuaValue::UserData(data) => profile_id_from_userdata(data),
        _ => Err(LuaError::RuntimeError(
            "expected profile id string or LProgressionProfile".to_string(),
        )),
    }
}

fn build_legacy_stats_adapter<'lua>(
    lua: &'lua Lua,
    store: Rc<RefCell<ProgressionStore>>,
    profile_id: String,
) -> LuaResult<LuaTable<'lua>> {
    let adapter = lua.create_table()?;
    let definitions = lua.create_table()?;
    adapter.set(
        "_progression_store",
        lua.create_userdata(LuaProgressionStore {
            store: store.clone(),
        })?,
    )?;
    adapter.set("_progression_profile_id", profile_id.clone())?;
    adapter.set("_definitions", definitions.clone())?;
    adapter.set("_buff_stat", lua.create_table()?)?;
    adapter.set("_action_points_resource", "__legacy_action_points")?;
    adapter.set("_morale_resource", "__legacy_morale")?;
    adapter.set("_morale_panic_threshold", 25.0)?;
    adapter.set("_morale_berserk_threshold", 10.0)?;
    adapter.set("_flags", lua.create_table()?)?;
    adapter.set("_resistances", lua.create_table()?)?;
    adapter.set("_use_counts", lua.create_table()?)?;
    adapter.set("_encumbrance", lua.create_table()?)?;
    adapter.set("_initiative", 10.0)?;

    /// Define.
    ///
    /// @param this : table
    /// @param name : string
    /// @param base : number
    /// @param opts : table?
    adapter.set(
        "define",
        lua.create_function(
            |lua, (this, name, base, opts): (LuaTable, String, f64, Option<LuaTable>)| {
                let store_ud: AnyUserData = this.get("_progression_store")?;
                let store = store_from_userdata(store_ud)?;
                let mut definition = AttributeDefinition {
                    base,
                    ..AttributeDefinition::default()
                };
                if let Some(opts) = opts {
                    definition.min = opts.get::<_, Option<f64>>("min")?;
                    definition.max = opts.get::<_, Option<f64>>("max")?;
                    definition.regen = opts.get::<_, Option<f64>>("regen")?.unwrap_or(0.0);
                    definition.growth = opts.get::<_, Option<f64>>("growth")?.unwrap_or(0.0);
                }
                store
                    .borrow_mut()
                    .define_attribute(&name, definition.clone())
                    .map_err(|err| progression_error("createLegacyStatsAdapter.define", err))?;
                let profile_id: String = this.get("_progression_profile_id")?;
                store
                    .borrow_mut()
                    .set_attribute_base(&profile_id, &name, base)
                    .map_err(|err| progression_error("createLegacyStatsAdapter.define", err))?;
                let entry = lua.create_table()?;
                entry.set("base", base)?;
                entry.set("min", definition.min)?;
                entry.set("max", definition.max)?;
                entry.set("regen", definition.regen)?;
                entry.set("growth", definition.growth)?;
                let defs: LuaTable = this.get("_definitions")?;
                defs.set(name, entry)?;
                Ok(())
            },
        )?,
    )?;

    /// Returns a value.
    ///
    /// @param this : table
    /// @param name : string
    /// @return number
    adapter.set(
        "get",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let value = store
                .borrow()
                .get_attribute(&profile_id, &name, AttributeMode::Effective)
                .map_err(|err| progression_error("createLegacyStatsAdapter.get", err))?;
            Ok(value)
        })?,
    )?;

    /// Returns the base.
    ///
    /// @param this : table
    /// @param name : string
    /// @return number
    adapter.set(
        "getBase",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let value = store
                .borrow()
                .get_attribute(&profile_id, &name, AttributeMode::Base)
                .map_err(|err| progression_error("createLegacyStatsAdapter.getBase", err))?;
            Ok(value)
        })?,
    )?;

    /// Sets the base.
    ///
    /// @param this : table
    /// @param name : string
    /// @param value : number
    /// @return boolean
    adapter.set(
        "setBase",
        lua.create_function(|_, (this, name, value): (LuaTable, String, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            store
                .borrow_mut()
                .set_attribute_base(&profile_id, &name, value)
                .map_err(|err| progression_error("createLegacyStatsAdapter.setBase", err))?;
            Ok(true)
        })?,
    )?;

    /// Sets the min.
    ///
    /// @param this : table
    /// @param name : string
    /// @param value : number
    adapter.set(
        "setMin",
        lua.create_function(|_, (this, name, value): (LuaTable, String, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let defs: LuaTable = this.get("_definitions")?;
            let entry: LuaTable = defs.get(name.clone())?;
            let max = entry.get::<_, Option<f64>>("max")?;
            store
                .borrow_mut()
                .set_attribute_bounds(&name, Some(value), max)
                .map_err(|err| progression_error("createLegacyStatsAdapter.setMin", err))?;
            entry.set("min", value)?;
            Ok(())
        })?,
    )?;

    /// Sets the max.
    ///
    /// @param this : table
    /// @param name : string
    /// @param value : number
    adapter.set(
        "setMax",
        lua.create_function(|_, (this, name, value): (LuaTable, String, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let defs: LuaTable = this.get("_definitions")?;
            let entry: LuaTable = defs.get(name.clone())?;
            let min = entry.get::<_, Option<f64>>("min")?;
            store
                .borrow_mut()
                .set_attribute_bounds(&name, min, Some(value))
                .map_err(|err| progression_error("createLegacyStatsAdapter.setMax", err))?;
            entry.set("max", value)?;
            Ok(())
        })?,
    )?;

    /// Returns the min.
    ///
    /// @param this : table
    /// @param name : string
    adapter.set(
        "getMin",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let defs: LuaTable = this.get("_definitions")?;
            let entry: LuaTable = defs.get(name)?;
            entry.get::<_, Option<f64>>("min")
        })?,
    )?;

    /// Returns the max.
    ///
    /// @param this : table
    /// @param name : string
    adapter.set(
        "getMax",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let defs: LuaTable = this.get("_definitions")?;
            let entry: LuaTable = defs.get(name)?;
            entry.get::<_, Option<f64>>("max")
        })?,
    )?;

    /// Sets the regen.
    ///
    /// @param this : table
    /// @param name : string
    /// @param value : number
    adapter.set(
        "setRegen",
        lua.create_function(|_, (this, name, value): (LuaTable, String, f64)| {
            let defs: LuaTable = this.get("_definitions")?;
            let entry: LuaTable = defs.get(name)?;
            entry.set("regen", value)?;
            Ok(())
        })?,
    )?;

    /// Returns the regen.
    ///
    /// @param this : table
    /// @param name : string
    adapter.set(
        "getRegen",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let defs: LuaTable = this.get("_definitions")?;
            let entry: LuaTable = defs.get(name)?;
            entry.get::<_, Option<f64>>("regen")
        })?,
    )?;

    /// Returns the stat names.
    ///
    /// @param this : table
    /// @return table
    adapter.set(
        "getStatNames",
        lua.create_function(|lua, (this,): (LuaTable,)| {
            let defs: LuaTable = this.get("_definitions")?;
            let mut names = Vec::new();
            for pair in defs.pairs::<String, LuaValue>() {
                let (name, _) = pair?;
                names.push(name);
            }
            names.sort();
            let out = lua.create_table()?;
            for (idx, name) in names.into_iter().enumerate() {
                out.set(idx + 1, name)?;
            }
            Ok(out)
        })?,
    )?;

    /// Adds buff.
    ///
    /// @return string
    adapter.set(
        "addBuff",
        lua.create_function(
            |lua, (this, stat, add, mul, duration, source, _stack): LegacyAddBuffArgs<'_>| {
                let store_ud: AnyUserData = this.get("_progression_store")?;
                let store = store_from_userdata(store_ud)?;
                let profile_id: String = this.get("_progression_profile_id")?;
                let handle = store
                    .borrow_mut()
                    .add_modifier(
                        &profile_id,
                        &stat,
                        ModifierAddOptions {
                            layer: Some("final_add".to_string()),
                            value: add,
                            duration,
                            source,
                            tags: Vec::new(),
                        },
                    )
                    .map_err(|err| progression_error("createLegacyStatsAdapter.addBuff", err))?;
                if let Some(mul) = mul {
                    if (mul - 1.0).abs() > f64::EPSILON {
                        let defs: LuaTable = this.get("_buff_stat")?;
                        defs.set(handle.clone(), stat)?;
                    }
                }
                Ok(LuaValue::String(lua.create_string(&handle)?))
            },
        )?,
    )?;

    /// Removes buff.
    ///
    /// @param this : table
    /// @param handle : string
    /// @return boolean
    adapter.set(
        "removeBuff",
        lua.create_function(|_, (this, handle): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let removed = store
                .borrow_mut()
                .remove_modifier(&profile_id, &handle)
                .map_err(|err| progression_error("createLegacyStatsAdapter.removeBuff", err))?;
            Ok(removed)
        })?,
    )?;

    /// Clears buffs.
    ///
    /// @param this : table
    /// @param stat : string?
    adapter.set(
        "clearBuffs",
        lua.create_function(|_, (this, stat): (LuaTable, Option<String>)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let modifiers = store
                .borrow()
                .list_modifiers(&profile_id)
                .map_err(|err| progression_error("createLegacyStatsAdapter.clearBuffs", err))?;
            for modifier in modifiers {
                let matches = stat
                    .as_ref()
                    .map(|wanted| modifier["target_id"] == *wanted)
                    .unwrap_or(true);
                if matches {
                    if let Some(handle) = modifier["handle"].as_str() {
                        let _ = store.borrow_mut().remove_modifier(&profile_id, handle);
                    }
                }
            }
            Ok(())
        })?,
    )?;

    /// Returns the buff count.
    ///
    /// @param this : table
    /// @param stat : string?
    /// @return integer
    adapter.set(
        "getBuffCount",
        lua.create_function(|_, (this, stat): (LuaTable, Option<String>)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let modifiers = store
                .borrow()
                .list_modifiers(&profile_id)
                .map_err(|err| progression_error("createLegacyStatsAdapter.getBuffCount", err))?;
            let count = modifiers
                .into_iter()
                .filter(|modifier| {
                    stat.as_ref()
                        .map(|wanted| modifier["target_id"] == *wanted)
                        .unwrap_or(true)
                })
                .count();
            Ok(count as i64)
        })?,
    )?;

    /// Apply trait buffs.
    ///
    /// @param this : table
    /// @param trait_name : string
    adapter.set(
        "applyTraitBuffs",
        lua.create_function(|_, (this, trait_name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            store
                .borrow_mut()
                .apply_trait(&profile_id, &trait_name)
                .map_err(|err| {
                    progression_error("createLegacyStatsAdapter.applyTraitBuffs", err)
                })?;
            Ok(())
        })?,
    )?;

    /// Removes trait buffs.
    ///
    /// @param this : table
    /// @param trait_name : string
    /// @return boolean
    adapter.set(
        "removeTraitBuffs",
        lua.create_function(|_, (this, trait_name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let removed = store
                .borrow_mut()
                .remove_trait(&profile_id, &trait_name)
                .map_err(|err| {
                    progression_error("createLegacyStatsAdapter.removeTraitBuffs", err)
                })?;
            Ok(removed)
        })?,
    )?;

    /// Returns true if trait.
    ///
    /// @param this : table
    /// @param trait_name : string
    /// @return boolean
    adapter.set(
        "hasTrait",
        lua.create_function(|_, (this, trait_name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let active = store
                .borrow()
                .has_trait(&profile_id, &trait_name)
                .map_err(|err| progression_error("createLegacyStatsAdapter.hasTrait", err))?;
            Ok(active)
        })?,
    )?;

    /// Returns the active traits.
    ///
    /// @param this : table
    /// @return table
    adapter.set(
        "getActiveTraits",
        lua.create_function(|lua, (this,): (LuaTable,)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let traits = store.borrow().list_traits(&profile_id).map_err(|err| {
                progression_error("createLegacyStatsAdapter.getActiveTraits", err)
            })?;
            let out = lua.create_table()?;
            for (idx, trait_id) in traits.into_iter().enumerate() {
                out.set(idx + 1, trait_id)?;
            }
            Ok(out)
        })?,
    )?;

    /// Returns the buffs.
    ///
    /// @param this : table
    /// @param stat : string?
    /// @return table
    adapter.set(
        "getBuffs",
        lua.create_function(|lua, (this, stat): (LuaTable, Option<String>)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let modifiers = store
                .borrow()
                .list_modifiers(&profile_id)
                .map_err(|err| progression_error("createLegacyStatsAdapter.getBuffs", err))?;
            let out = lua.create_table()?;
            let mut out_index = 1;
            for modifier in modifiers {
                let matches = stat
                    .as_ref()
                    .map(|wanted| modifier["target_id"] == *wanted)
                    .unwrap_or(true);
                if matches {
                    let entry = lua.create_table()?;
                    entry.set("handle", modifier["handle"].as_str().unwrap_or_default())?;
                    entry.set("stat", modifier["target_id"].as_str().unwrap_or_default())?;
                    entry.set("add", modifier["value"].as_f64().unwrap_or(0.0))?;
                    entry.set("mul", 1.0)?;
                    entry.set("duration", modifier["remaining"].as_f64())?;
                    entry.set("remaining", modifier["remaining"].as_f64())?;
                    entry.set("source", modifier["source"].as_str().unwrap_or_default())?;
                    out.set(out_index, entry)?;
                    out_index += 1;
                }
            }
            Ok(out)
        })?,
    )?;

    /// Adds xp.
    ///
    /// @param this : table
    /// @param amount : number
    adapter.set(
        "addXP",
        lua.create_function(|_, (this, amount): (LuaTable, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let track = "__legacy_xp";
            if store.borrow().get_experience(&profile_id, track).is_err() {
                store
                    .borrow_mut()
                    .define_level_track(track, LevelTrackDefinition::default())
                    .map_err(|err| progression_error("createLegacyStatsAdapter.addXP", err))?;
            }
            store
                .borrow_mut()
                .add_experience(&profile_id, track, amount)
                .map_err(|err| progression_error("createLegacyStatsAdapter.addXP", err))?;
            Ok(())
        })?,
    )?;

    /// Returns the xp.
    ///
    /// @param this : table
    /// @return number
    adapter.set(
        "getXP",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let xp = store
                .borrow()
                .get_experience(&profile_id, "__legacy_xp")
                .map_err(|err| progression_error("createLegacyStatsAdapter.getXP", err))?;
            Ok(xp["experience"].as_f64().unwrap_or(0.0))
        })?,
    )?;

    /// Sets the xp.
    ///
    /// @param this : table
    /// @param value : number
    adapter.set(
        "setXP",
        lua.create_function(|_, (this, value): (LuaTable, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            if store
                .borrow()
                .get_experience(&profile_id, "__legacy_xp")
                .is_err()
            {
                store
                    .borrow_mut()
                    .define_level_track("__legacy_xp", LevelTrackDefinition::default())
                    .map_err(|err| progression_error("createLegacyStatsAdapter.setXP", err))?;
            }
            store
                .borrow_mut()
                .set_experience(&profile_id, "__legacy_xp", value)
                .map_err(|err| progression_error("createLegacyStatsAdapter.setXP", err))?;
            Ok(())
        })?,
    )?;

    /// Returns the level.
    ///
    /// @param this : table
    /// @return integer
    adapter.set(
        "getLevel",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let level = store
                .borrow()
                .get_level(&profile_id, "__legacy_xp")
                .map_err(|err| progression_error("createLegacyStatsAdapter.getLevel", err))?;
            Ok(level as i64)
        })?,
    )?;

    /// Sets the level.
    ///
    /// @param this : table
    /// @param value : integer
    adapter.set(
        "setLevel",
        lua.create_function(|_, (this, value): (LuaTable, i64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            if store
                .borrow()
                .get_experience(&profile_id, "__legacy_xp")
                .is_err()
            {
                store
                    .borrow_mut()
                    .define_level_track("__legacy_xp", LevelTrackDefinition::default())
                    .map_err(|err| progression_error("createLegacyStatsAdapter.setLevel", err))?;
            }
            store
                .borrow_mut()
                .set_level(&profile_id, "__legacy_xp", value as u32)
                .map_err(|err| progression_error("createLegacyStatsAdapter.setLevel", err))?;
            Ok(())
        })?,
    )?;

    /// Sets the level thresholds.
    ///
    /// @param this : table
    /// @param thresholds : table
    adapter.set(
        "setLevelThresholds",
        lua.create_function(|_, (this, thresholds): (LuaTable, LuaTable)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let values = thresholds.get::<_, Option<LuaTable>>("values")?;
            let base_xp = thresholds
                .get::<_, Option<f64>>("base")?
                .or_else(|| {
                    values
                        .as_ref()
                        .and_then(|table| table.get::<_, Option<f64>>(1).ok().flatten())
                })
                .unwrap_or(100.0);
            let increment_xp = thresholds
                .get::<_, Option<f64>>("increment")?
                .or_else(|| {
                    values.as_ref().map(|table| {
                        let first = table.get::<_, Option<f64>>(1).ok().flatten();
                        let second = table.get::<_, Option<f64>>(2).ok().flatten();
                        match (first, second) {
                            (Some(first), Some(second)) => (second - first).max(0.0),
                            (Some(first), None) => first.max(0.0),
                            _ => 100.0,
                        }
                    })
                })
                .unwrap_or(100.0);
            store
                .borrow_mut()
                .define_level_track(
                    "__legacy_xp",
                    LevelTrackDefinition {
                        initial_level: 1,
                        max_level: 100,
                        base_xp,
                        increment_xp,
                        carry_over: true,
                        allow_level_down: false,
                    },
                )
                .map_err(|err| {
                    progression_error("createLegacyStatsAdapter.setLevelThresholds", err)
                })?;
            Ok(())
        })?,
    )?;

    /// Define skill.
    ///
    /// @param this : table
    /// @param name : string
    /// @param opts : table?
    adapter.set(
        "defineSkill",
        lua.create_function(
            |_, (this, name, opts): (LuaTable, String, Option<LuaTable>)| {
                let store_ud: AnyUserData = this.get("_progression_store")?;
                let store = store_from_userdata(store_ud)?;
                let definition = match opts {
                    Some(opts) => parse_skill_definition(opts)?,
                    None => SkillDefinition::default(),
                };
                store
                    .borrow_mut()
                    .define_skill(&name, definition)
                    .map_err(|err| {
                        progression_error("createLegacyStatsAdapter.defineSkill", err)
                    })?;
                Ok(())
            },
        )?,
    )?;

    /// Learn skill.
    ///
    /// @param this : table
    /// @param name : string
    /// @return boolean
    adapter.set(
        "learnSkill",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let learned = store
                .borrow_mut()
                .learn_skill(&profile_id, &name)
                .map_err(|err| progression_error("createLegacyStatsAdapter.learnSkill", err))?;
            Ok(learned)
        })?,
    )?;

    /// Use skill.
    ///
    /// @param this : table
    /// @param name : string
    /// @return | boolean, string? | Success flag followed by an optional failure reason.
    adapter.set(
        "useSkill",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let result = store
                .borrow_mut()
                .use_skill(&profile_id, &name)
                .map_err(|err| progression_error("createLegacyStatsAdapter.useSkill", err))?;
            let ok = result["ok"].as_bool().unwrap_or(false);
            let reason = result["reason"].as_str().map(|value| value.to_string());
            Ok((ok, reason))
        })?,
    )?;

    /// Returns the skill level.
    ///
    /// @param this : table
    /// @param name : string
    /// @return integer
    adapter.set(
        "getSkillLevel",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let level = store
                .borrow()
                .get_skill_level(&profile_id, &name)
                .map_err(|err| progression_error("createLegacyStatsAdapter.getSkillLevel", err))?;
            Ok(level as i64)
        })?,
    )?;

    /// Returns the cooldown remaining.
    ///
    /// @param this : table
    /// @param name : string
    /// @return number
    adapter.set(
        "getCooldownRemaining",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let cooldown = store
                .borrow()
                .get_skill_cooldown(&profile_id, &name)
                .map_err(|err| {
                    progression_error("createLegacyStatsAdapter.getCooldownRemaining", err)
                })?;
            Ok(cooldown)
        })?,
    )?;

    /// Define perk.
    ///
    /// @param this : table
    /// @param name : string
    /// @param opts : table?
    adapter.set(
        "definePerk",
        lua.create_function(
            |_, (this, name, opts): (LuaTable, String, Option<LuaTable>)| {
                let store_ud: AnyUserData = this.get("_progression_store")?;
                let store = store_from_userdata(store_ud)?;
                let profile_id: String = this.get("_progression_profile_id")?;
                let mut definition = PerkDefinition {
                    track_id: Some("__legacy_xp".to_string()),
                    ..PerkDefinition::default()
                };
                if let Some(opts) = opts {
                    definition.require_level =
                        opts.get::<_, Option<u32>>("require_level")?.unwrap_or(0);
                    if let Some(trait_name) = opts.get::<_, Option<String>>("trait_name")? {
                        definition.trait_ids.push(trait_name);
                    }
                }
                if definition.require_level > 0
                    && store
                        .borrow()
                        .get_experience(&profile_id, "__legacy_xp")
                        .is_err()
                {
                    store
                        .borrow_mut()
                        .define_level_track("__legacy_xp", LevelTrackDefinition::default())
                        .map_err(|err| {
                            progression_error("createLegacyStatsAdapter.definePerk", err)
                        })?;
                }
                store
                    .borrow_mut()
                    .define_perk(&name, definition)
                    .map_err(|err| progression_error("createLegacyStatsAdapter.definePerk", err))?;
                Ok(())
            },
        )?,
    )?;

    /// Acquire perk.
    ///
    /// @param this : table
    /// @param name : string
    /// @return boolean
    adapter.set(
        "acquirePerk",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let acquired = store
                .borrow_mut()
                .acquire_perk(&profile_id, &name)
                .map_err(|err| progression_error("createLegacyStatsAdapter.acquirePerk", err))?;
            Ok(acquired)
        })?,
    )?;

    /// Returns true if perk.
    ///
    /// @param this : table
    /// @param name : string
    /// @return boolean
    adapter.set(
        "hasPerk",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let acquired = store
                .borrow()
                .has_perk(&profile_id, &name)
                .map_err(|err| progression_error("createLegacyStatsAdapter.hasPerk", err))?;
            Ok(acquired)
        })?,
    )?;

    /// Sets the action points.
    ///
    /// @param this : table
    /// @param max_val : number
    adapter.set(
        "setActionPoints",
        lua.create_function(|_, (this, max_val): (LuaTable, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let resource_id: String = this.get("_action_points_resource")?;
            let definition = ResourceDefinition {
                initial: max_val,
                min: 0.0,
                max: max_val,
                regeneration: 0.0,
                refill: "manual".to_string(),
            };
            store
                .borrow_mut()
                .define_resource(&resource_id, definition)
                .map_err(|err| {
                    progression_error("createLegacyStatsAdapter.setActionPoints", err)
                })?;
            store
                .borrow_mut()
                .set_resource(&profile_id, &resource_id, max_val)
                .map_err(|err| {
                    progression_error("createLegacyStatsAdapter.setActionPoints", err)
                })?;
            Ok(())
        })?,
    )?;

    /// Returns the action points.
    ///
    /// @param this : table
    /// @return | number, number | Current action points followed by the configured maximum.
    adapter.set(
        "getActionPoints",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let resource_id: String = this.get("_action_points_resource")?;
            let snapshot = store
                .borrow()
                .get_resource(&profile_id, &resource_id)
                .map_err(|err| {
                    progression_error("createLegacyStatsAdapter.getActionPoints", err)
                })?;
            Ok((
                snapshot["value"].as_f64().unwrap_or(0.0),
                snapshot["max"].as_f64().unwrap_or(0.0),
            ))
        })?,
    )?;

    /// Spend action points.
    ///
    /// @param this : table
    /// @param amount : number
    /// @return boolean
    adapter.set(
        "spendActionPoints",
        lua.create_function(|_, (this, amount): (LuaTable, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let resource_id: String = this.get("_action_points_resource")?;
            let ok = store
                .borrow_mut()
                .spend_resource(&profile_id, &resource_id, amount)
                .map_err(|err| {
                    progression_error("createLegacyStatsAdapter.spendActionPoints", err)
                })?;
            Ok(ok)
        })?,
    )?;

    /// Recover action points.
    ///
    /// @param this : table
    /// @param amount : number
    adapter.set(
        "recoverActionPoints",
        lua.create_function(|_, (this, amount): (LuaTable, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let resource_id: String = this.get("_action_points_resource")?;
            store
                .borrow_mut()
                .refill_resource(&profile_id, &resource_id, Some(amount))
                .map_err(|err| {
                    progression_error("createLegacyStatsAdapter.recoverActionPoints", err)
                })?;
            Ok(())
        })?,
    )?;

    /// Begin turn.
    ///
    /// @param this : table
    adapter.set(
        "beginTurn",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let resource_id: String = this.get("_action_points_resource")?;
            store
                .borrow_mut()
                .refill_resource(&profile_id, &resource_id, None)
                .map_err(|err| progression_error("createLegacyStatsAdapter.beginTurn", err))?;
            Ok(())
        })?,
    )?;

    /// Sets the morale.
    ///
    /// @param this : table
    /// @param max_val : number
    adapter.set(
        "setMorale",
        lua.create_function(|_, (this, max_val): (LuaTable, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let resource_id: String = this.get("_morale_resource")?;
            let definition = ResourceDefinition {
                initial: max_val,
                min: 0.0,
                max: max_val,
                regeneration: 0.0,
                refill: "manual".to_string(),
            };
            store
                .borrow_mut()
                .define_resource(&resource_id, definition)
                .map_err(|err| progression_error("createLegacyStatsAdapter.setMorale", err))?;
            store
                .borrow_mut()
                .set_resource(&profile_id, &resource_id, max_val)
                .map_err(|err| progression_error("createLegacyStatsAdapter.setMorale", err))?;
            Ok(())
        })?,
    )?;

    /// Returns the morale.
    ///
    /// @param this : table
    /// @return | number, number | Current morale followed by the configured maximum.
    adapter.set(
        "getMorale",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let resource_id: String = this.get("_morale_resource")?;
            let snapshot = store
                .borrow()
                .get_resource(&profile_id, &resource_id)
                .map_err(|err| progression_error("createLegacyStatsAdapter.getMorale", err))?;
            Ok((
                snapshot["value"].as_f64().unwrap_or(0.0),
                snapshot["max"].as_f64().unwrap_or(0.0),
            ))
        })?,
    )?;

    /// Adjust morale.
    ///
    /// @param this : table
    /// @param delta : number
    adapter.set(
        "adjustMorale",
        lua.create_function(|_, (this, delta): (LuaTable, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let resource_id: String = this.get("_morale_resource")?;
            let current = store
                .borrow()
                .get_resource(&profile_id, &resource_id)
                .map_err(|err| progression_error("createLegacyStatsAdapter.adjustMorale", err))?;
            let next = current["value"].as_f64().unwrap_or(0.0) + delta;
            store
                .borrow_mut()
                .set_resource(&profile_id, &resource_id, next)
                .map_err(|err| progression_error("createLegacyStatsAdapter.adjustMorale", err))?;
            Ok(())
        })?,
    )?;

    /// Sets the panic threshold.
    ///
    /// @param this : table
    /// @param value : number
    adapter.set(
        "setPanicThreshold",
        lua.create_function(|_, (this, value): (LuaTable, f64)| {
            this.set("_morale_panic_threshold", value)?;
            Ok(())
        })?,
    )?;

    /// Sets the berserk threshold.
    ///
    /// @param this : table
    /// @param value : number
    adapter.set(
        "setBerserkThreshold",
        lua.create_function(|_, (this, value): (LuaTable, f64)| {
            this.set("_morale_berserk_threshold", value)?;
            Ok(())
        })?,
    )?;

    /// Check morale.
    ///
    /// @param this : table
    /// @return string
    adapter.set(
        "checkMorale",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let (current, _) = {
                let store_ud: AnyUserData = this.get("_progression_store")?;
                let store = store_from_userdata(store_ud)?;
                let profile_id: String = this.get("_progression_profile_id")?;
                let resource_id: String = this.get("_morale_resource")?;
                let snapshot = store
                    .borrow()
                    .get_resource(&profile_id, &resource_id)
                    .map_err(|err| {
                        progression_error("createLegacyStatsAdapter.checkMorale", err)
                    })?;
                (
                    snapshot["value"].as_f64().unwrap_or(0.0),
                    snapshot["max"].as_f64().unwrap_or(0.0),
                )
            };
            let panic_threshold: f64 = this.get("_morale_panic_threshold")?;
            let berserk_threshold: f64 = this.get("_morale_berserk_threshold")?;
            let flags: LuaTable = this.get("_flags")?;
            if current <= berserk_threshold {
                flags.set("berserk", true)?;
                flags.set("panic", LuaValue::Nil)?;
                Ok(Some("berserk".to_string()))
            } else if current <= panic_threshold {
                flags.set("panic", true)?;
                flags.set("berserk", LuaValue::Nil)?;
                Ok(Some("panic".to_string()))
            } else {
                flags.set("panic", LuaValue::Nil)?;
                flags.set("berserk", LuaValue::Nil)?;
                Ok(None)
            }
        })?,
    )?;

    /// Sets the flag.
    ///
    /// @param this : table
    /// @param name : string
    adapter.set(
        "setFlag",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let flags: LuaTable = this.get("_flags")?;
            flags.set(name, true)?;
            Ok(())
        })?,
    )?;
    /// Clears flag.
    ///
    /// @param this : table
    /// @param name : string
    adapter.set(
        "clearFlag",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let flags: LuaTable = this.get("_flags")?;
            flags.set(name, LuaValue::Nil)?;
            Ok(())
        })?,
    )?;
    /// Returns true if flag.
    ///
    /// @param this : table
    /// @param name : string
    /// @return boolean
    adapter.set(
        "hasFlag",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let flags: LuaTable = this.get("_flags")?;
            Ok(flags.get::<_, Option<bool>>(name)?.unwrap_or(false))
        })?,
    )?;
    /// Returns the flags.
    ///
    /// @param this : table
    /// @return table
    adapter.set(
        "getFlags",
        lua.create_function(|lua, (this,): (LuaTable,)| {
            let flags: LuaTable = this.get("_flags")?;
            let mut names = Vec::new();
            for pair in flags.pairs::<String, bool>() {
                let (name, enabled) = pair?;
                if enabled {
                    names.push(name);
                }
            }
            names.sort();
            let out = lua.create_table()?;
            for (idx, name) in names.into_iter().enumerate() {
                out.set(idx + 1, name)?;
            }
            Ok(out)
        })?,
    )?;

    /// Sets the resistance.
    ///
    /// @param this : table
    /// @param dtype : string
    /// @param value : number
    adapter.set(
        "setResistance",
        lua.create_function(|_, (this, dtype, value): (LuaTable, String, f64)| {
            let resistances: LuaTable = this.get("_resistances")?;
            resistances.set(dtype, value)?;
            Ok(())
        })?,
    )?;
    /// Returns the resistance.
    ///
    /// @param this : table
    /// @param dtype : string
    /// @return number
    adapter.set(
        "getResistance",
        lua.create_function(|_, (this, dtype): (LuaTable, String)| {
            let resistances: LuaTable = this.get("_resistances")?;
            Ok(resistances.get::<_, Option<f64>>(dtype)?.unwrap_or(0.0))
        })?,
    )?;

    /// Apply damage.
    ///
    /// @param this : table
    /// @param stat : string
    /// @param amount : number
    /// @param dtype : string?
    /// @return number
    adapter.set(
        "applyDamage",
        lua.create_function(
            |_, (this, stat, amount, dtype): (LuaTable, String, f64, Option<String>)| {
                let get_base: LuaFunction = this.get("getBase")?;
                let current = get_base
                    .call::<_, Option<f64>>((this.clone(), stat.clone()))?
                    .unwrap_or(0.0);
                let resistance = if let Some(dtype) = dtype {
                    let get_resistance: LuaFunction = this.get("getResistance")?;
                    get_resistance.call::<_, f64>((this.clone(), dtype))?
                } else {
                    0.0
                };
                let actual = (amount * (1.0 - resistance)).max(0.0);
                let set_base: LuaFunction = this.get("setBase")?;
                let _ = set_base.call::<_, bool>((this.clone(), stat, current - actual))?;
                Ok(actual)
            },
        )?,
    )?;

    /// Record use.
    ///
    /// @param this : table
    /// @param name : string
    adapter.set(
        "recordUse",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let counts: LuaTable = this.get("_use_counts")?;
            let next = counts.get::<_, Option<i64>>(name.clone())?.unwrap_or(0) + 1;
            counts.set(name, next)?;
            Ok(())
        })?,
    )?;
    /// Returns the use count.
    ///
    /// @param this : table
    /// @param name : string
    /// @return integer
    adapter.set(
        "getUseCount",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let counts: LuaTable = this.get("_use_counts")?;
            Ok(counts.get::<_, Option<i64>>(name)?.unwrap_or(0))
        })?,
    )?;

    /// Sets the encumbrance.
    ///
    /// @param this : table
    /// @param cur : number
    /// @param max_val : number
    adapter.set(
        "setEncumbrance",
        lua.create_function(|_, (this, cur, max_val): (LuaTable, f64, f64)| {
            let enc: LuaTable = this.get("_encumbrance")?;
            enc.set("current", cur)?;
            enc.set("max", max_val)?;
            Ok(())
        })?,
    )?;
    /// Returns the encumbrance.
    ///
    /// @param this : table
    /// @return table
    adapter.set(
        "getEncumbrance",
        lua.create_function(|lua, (this,): (LuaTable,)| {
            let enc: LuaTable = this.get("_encumbrance")?;
            let out = lua.create_table()?;
            out.set(
                "current",
                enc.get::<_, Option<f64>>("current")?.unwrap_or(0.0),
            )?;
            out.set("max", enc.get::<_, Option<f64>>("max")?.unwrap_or(0.0))?;
            Ok(out)
        })?,
    )?;
    /// Returns true if encumbered.
    ///
    /// @param this : table
    /// @return boolean
    adapter.set(
        "isEncumbered",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let enc: LuaTable = this.get("_encumbrance")?;
            let current = enc.get::<_, Option<f64>>("current")?.unwrap_or(0.0);
            let max = enc.get::<_, Option<f64>>("max")?.unwrap_or(0.0);
            Ok(max > 0.0 && current > max)
        })?,
    )?;

    /// Sets the initiative.
    ///
    /// @param this : table
    /// @param value : number
    adapter.set(
        "setInitiative",
        lua.create_function(|_, (this, value): (LuaTable, f64)| {
            this.set("_initiative", value)?;
            Ok(())
        })?,
    )?;
    /// Returns the initiative.
    ///
    /// @param this : table
    adapter.set(
        "getInitiative",
        lua.create_function(|_, (this,): (LuaTable,)| {
            this.get::<_, Option<f64>>("_initiative")
                .map(|value| value.unwrap_or(10.0))
        })?,
    )?;

    /// Update.
    ///
    /// @param this : table
    /// @param dt : number
    adapter.set(
        "update",
        lua.create_function(|_, (this, dt): (LuaTable, f64)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            store
                .borrow_mut()
                .update(dt)
                .map_err(|err| progression_error("createLegacyStatsAdapter.update", err))?;
            Ok(())
        })?,
    )?;

    /// Snapshot.
    ///
    /// @param this : table
    /// @return table
    adapter.set(
        "snapshot",
        lua.create_function(|lua, (this,): (LuaTable,)| {
            let defs: LuaTable = this.get("_definitions")?;
            let stats = lua.create_table()?;
            let names_fn: LuaFunction = this.get("getStatNames")?;
            let names: LuaTable = names_fn.call((this.clone(),))?;
            for name in names.sequence_values::<String>() {
                let name = name?;
                let entry: LuaTable = defs.get(name.clone())?;
                let info = lua.create_table()?;
                let get_base: LuaFunction = this.get("getBase")?;
                info.set(
                    "base",
                    get_base.call::<_, f64>((this.clone(), name.clone()))?,
                )?;
                info.set("min", entry.get::<_, Option<f64>>("min")?)?;
                info.set("max", entry.get::<_, Option<f64>>("max")?)?;
                info.set("regen", entry.get::<_, Option<f64>>("regen")?)?;
                info.set("growth", entry.get::<_, Option<f64>>("growth")?)?;
                stats.set(name, info)?;
            }
            let out = lua.create_table()?;
            let get_xp: LuaFunction = this.get("getXP")?;
            let get_level: LuaFunction = this.get("getLevel")?;
            out.set("attributes", stats)?;
            out.set("xp", get_xp.call::<_, f64>((this.clone(),))?)?;
            out.set("level", get_level.call::<_, i64>((this.clone(),))?)?;
            Ok(out)
        })?,
    )?;

    /// Restore.
    ///
    /// @param this : table
    /// @param snap : table
    adapter.set(
        "restore",
        lua.create_function(|_, (this, snap): (LuaTable, LuaTable)| {
            if let Ok(attributes) = snap.get::<_, LuaTable>("attributes") {
                let define_fn: LuaFunction = this.get("define")?;
                let set_base_fn: LuaFunction = this.get("setBase")?;
                for pair in attributes.pairs::<String, LuaTable>() {
                    let (name, info) = pair?;
                    define_fn.call::<_, ()>((
                        this.clone(),
                        name.clone(),
                        info.get::<_, Option<f64>>("base")?.unwrap_or(0.0),
                        Some(info.clone()),
                    ))?;
                    set_base_fn.call::<_, bool>((
                        this.clone(),
                        name,
                        info.get::<_, Option<f64>>("base")?.unwrap_or(0.0),
                    ))?;
                }
            }
            if let Ok(xp) = snap.get::<_, f64>("xp") {
                let store_ud: AnyUserData = this.get("_progression_store")?;
                let store = store_from_userdata(store_ud)?;
                let profile_id: String = this.get("_progression_profile_id")?;
                if store
                    .borrow()
                    .get_experience(&profile_id, "__legacy_xp")
                    .is_err()
                {
                    store
                        .borrow_mut()
                        .define_level_track("__legacy_xp", LevelTrackDefinition::default())
                        .map_err(|err| {
                            progression_error("createLegacyStatsAdapter.restore", err)
                        })?;
                }
                store
                    .borrow_mut()
                    .set_experience(&profile_id, "__legacy_xp", xp)
                    .map_err(|err| progression_error("createLegacyStatsAdapter.restore", err))?;
            }
            Ok(())
        })?,
    )?;

    /// Type.
    ///
    /// @return string
    adapter.set(
        "type",
        lua.create_function(|_, ()| Ok("LLegacyStatsAdapter"))?,
    )?;
    /// Type of.
    ///
    /// @param name : string
    /// @return boolean
    adapter.set(
        "typeOf",
        lua.create_function(|_, name: String| {
            Ok(name == "LLegacyStatsAdapter" || name == "LObject")
        })?,
    )?;
    Ok(adapter)
}

fn build_legacy_quest_adapter<'lua>(
    lua: &'lua Lua,
    store: Rc<RefCell<ProgressionStore>>,
    profile_id: String,
) -> LuaResult<LuaTable<'lua>> {
    let adapter = lua.create_table()?;
    adapter.set(
        "_progression_store",
        lua.create_userdata(LuaProgressionStore {
            store: store.clone(),
        })?,
    )?;
    adapter.set("_progression_profile_id", profile_id.clone())?;
    adapter.set("_quest_defs", lua.create_table()?)?;
    adapter.set("_quest_order", lua.create_table()?)?;

    /// Adds quest.
    ///
    /// @param this : table
    /// @param quest : table
    adapter.set(
        "addQuest",
        lua.create_function(|_, (this, quest): (LuaTable, LuaTable)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let quest_id: String = quest.get("id")?;
            let title: String = quest.get("title")?;
            let description: String = quest
                .get::<_, Option<String>>("description")?
                .unwrap_or_default();
            let stages_src: LuaTable = quest.get("stages")?;
            let mut stages = Vec::new();
            for stage_value in stages_src.sequence_values::<LuaTable>() {
                let stage_src = stage_value?;
                let mut objectives = Vec::new();
                let objectives_src: LuaTable = stage_src.get("objectives")?;
                for objective_value in objectives_src.sequence_values::<LuaTable>() {
                    let objective_src = objective_value?;
                    objectives.push(QuestObjectiveDefinition {
                        id: objective_src.get("id")?,
                        description: objective_src
                            .get::<_, Option<String>>("description")?
                            .unwrap_or_default(),
                        required: objective_src
                            .get::<_, Option<f64>>("required")?
                            .unwrap_or(1.0),
                        mandatory: objective_src
                            .get::<_, Option<bool>>("mandatory")?
                            .unwrap_or(true),
                        visible: objective_src
                            .get::<_, Option<bool>>("visible")?
                            .unwrap_or(true),
                        counter_id: objective_src.get::<_, Option<String>>("counter_id")?,
                    });
                }
                stages.push(QuestStageDefinition {
                    id: stage_src.get("id")?,
                    name: stage_src
                        .get::<_, Option<String>>("name")?
                        .unwrap_or_else(|| "".to_string()),
                    objectives,
                });
            }
            let reward_payload = match quest.get::<_, Option<LuaValue>>("reward_payload")? {
                Some(LuaValue::Nil) | None => None,
                Some(value) => Some(lua_to_json(value)?),
            };
            let max_journal_entries = quest.get::<_, Option<usize>>("_max_journal")?;
            store
                .borrow_mut()
                .define_quest(
                    &quest_id,
                    QuestDefinition {
                        id: quest_id.clone(),
                        title,
                        description,
                        stages,
                        max_journal_entries,
                        reveal_condition: None,
                        availability_condition: None,
                        reward_payload,
                    },
                )
                .map_err(|err| progression_error("createLegacyQuestAdapter.addQuest", err))?;
            let defs: LuaTable = this.get("_quest_defs")?;
            let order: LuaTable = this.get("_quest_order")?;
            if defs.get::<_, Option<LuaValue>>(quest_id.clone())?.is_none() {
                order.set(order.raw_len() + 1, quest_id.clone())?;
            }
            defs.set(quest_id, quest)?;
            Ok(())
        })?,
    )?;

    /// Quest count.
    ///
    /// @param this : table
    /// @return integer
    adapter.set(
        "questCount",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let defs: LuaTable = this.get("_quest_defs")?;
            let mut count = 0i64;
            for pair in defs.pairs::<String, LuaValue>() {
                let _ = pair?;
                count += 1;
            }
            Ok(count)
        })?,
    )?;

    /// Quest ids.
    ///
    /// @param this : table
    /// @return table
    adapter.set(
        "questIds",
        lua.create_function(|lua, (this,): (LuaTable,)| {
            let out = lua.create_table()?;
            let order: LuaTable = this.get("_quest_order")?;
            for (idx, id) in order.sequence_values::<String>().enumerate() {
                let id = id?;
                out.set(idx + 1, id)?;
            }
            Ok(out)
        })?,
    )?;

    /// Removes quest.
    ///
    /// @param this : table
    /// @param id : string
    /// @return boolean
    adapter.set(
        "removeQuest",
        lua.create_function(|_, (this, id): (LuaTable, String)| {
            let defs: LuaTable = this.get("_quest_defs")?;
            let existed = defs.get::<_, Option<LuaValue>>(id.clone())?.is_some();
            defs.set(id.clone(), LuaValue::Nil)?;
            if existed {
                let order: LuaTable = this.get("_quest_order")?;
                let kept = order.clone();
                let values: Vec<String> = kept
                    .sequence_values::<String>()
                    .collect::<LuaResult<Vec<_>>>()?;
                order.clear()?;
                let mut out_index = 1;
                for entry in values {
                    if entry != id {
                        order.set(out_index, entry)?;
                        out_index += 1;
                    }
                }
            }
            Ok(existed)
        })?,
    )?;

    /// Start quest.
    ///
    /// @param this : table
    /// @param id : string
    /// @return boolean
    adapter.set(
        "startQuest",
        lua.create_function(|_, (this, id): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            store
                .borrow_mut()
                .accept_quest(&profile_id, &id)
                .map_err(|err| progression_error("createLegacyQuestAdapter.startQuest", err))?;
            Ok(true)
        })?,
    )?;

    /// Complete quest.
    ///
    /// @param this : table
    /// @param id : string
    /// @return boolean
    adapter.set(
        "completeQuest",
        lua.create_function(|_, (this, id): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            store
                .borrow_mut()
                .complete_quest(&profile_id, &id)
                .map_err(|err| progression_error("createLegacyQuestAdapter.completeQuest", err))?;
            Ok(true)
        })?,
    )?;

    /// Fail quest.
    ///
    /// @param this : table
    /// @param id : string
    /// @return boolean
    adapter.set(
        "failQuest",
        lua.create_function(|_, (this, id): (LuaTable, String)| {
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            store
                .borrow_mut()
                .fail_quest(&profile_id, &id)
                .map_err(|err| progression_error("createLegacyQuestAdapter.failQuest", err))?;
            Ok(true)
        })?,
    )?;

    /// Advance objective.
    ///
    /// @return boolean
    adapter.set(
        "advanceObjective",
        lua.create_function(
            |_,
             (this, quest_id, objective_id, amount, _stage_id): (
                LuaTable,
                String,
                String,
                Option<f64>,
                Option<String>,
            )| {
                let store_ud: AnyUserData = this.get("_progression_store")?;
                let store = store_from_userdata(store_ud)?;
                let profile_id: String = this.get("_progression_profile_id")?;
                let current = store
                    .borrow()
                    .get_quest_state(&profile_id, &quest_id)
                    .map_err(|err| {
                        progression_error("createLegacyQuestAdapter.advanceObjective", err)
                    })?;
                let mut progress = 0.0;
                if let Some(objectives) = current["objectives"].as_array() {
                    for objective in objectives {
                        if objective["id"] == objective_id {
                            progress = objective["current"].as_f64().unwrap_or(0.0);
                            break;
                        }
                    }
                }
                store
                    .borrow_mut()
                    .set_quest_objective(
                        &profile_id,
                        &quest_id,
                        &objective_id,
                        progress + amount.unwrap_or(1.0),
                    )
                    .map_err(|err| {
                        progression_error("createLegacyQuestAdapter.advanceObjective", err)
                    })?;
                Ok(true)
            },
        )?,
    )?;

    /// Adds journal entry.
    ///
    /// @param this : table
    /// @param quest_id : string
    /// @param text : string
    /// @param tag : string?
    /// @return integer
    adapter.set(
        "addJournalEntry",
        lua.create_function(
            |lua, (this, quest_id, text, tag): (LuaTable, String, String, Option<String>)| {
                let store_ud: AnyUserData = this.get("_progression_store")?;
                let store = store_from_userdata(store_ud)?;
                let profile_id: String = this.get("_progression_profile_id")?;
                let entry = store
                    .borrow_mut()
                    .add_quest_journal_entry(&profile_id, &quest_id, &text, tag)
                    .map_err(|err| {
                        progression_error("createLegacyQuestAdapter.addJournalEntry", err)
                    })?;
                let defs: LuaTable = this.get("_quest_defs")?;
                if let Some(quest) = defs.get::<_, Option<LuaTable>>(quest_id.clone())? {
                    let journal = match quest.get::<_, Option<LuaTable>>("journal")? {
                        Some(table) => table,
                        None => {
                            let table = lua.create_table()?;
                            quest.set("journal", table.clone())?;
                            table
                        }
                    };
                    let item = lua.create_table()?;
                    item.set("index", entry.index)?;
                    item.set("text", entry.text)?;
                    item.set("tag", entry.tag)?;
                    journal.set(journal.raw_len() + 1, item)?;
                }
                Ok(entry.index as i64)
            },
        )?,
    )?;

    /// Returns the quest.
    ///
    /// @param this : table
    /// @param id : string
    /// @return table
    adapter.set(
        "getQuest",
        lua.create_function(|lua, (this, id): (LuaTable, String)| {
            let defs: LuaTable = this.get("_quest_defs")?;
            let authored: LuaTable = defs.get(id.clone())?;
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let state = store.borrow().get_quest_state(&profile_id, &id).ok();
            let copy = lua.create_table()?;
            for pair in authored.pairs::<LuaValue, LuaValue>() {
                let (key, value) = pair?;
                copy.set(key, value)?;
            }
            copy.set(
                "status",
                state
                    .as_ref()
                    .and_then(|value| value["status"].as_str())
                    .unwrap_or("available"),
            )?;
            if let Some(state) = state.as_ref() {
                if let LuaValue::Table(journal) = json_to_lua(lua, state["journal"].clone())? {
                    copy.set("journal", journal)?;
                }
            }
            Ok(copy)
        })?,
    )?;

    /// Quests with status.
    ///
    /// @param this : table
    /// @param wanted : string
    /// @return table
    adapter.set(
        "questsWithStatus",
        lua.create_function(|lua, (this, wanted): (LuaTable, String)| {
            let quest_ids_fn: LuaFunction = this.get("questIds")?;
            let ids: LuaTable = quest_ids_fn.call((this.clone(),))?;
            let out = lua.create_table()?;
            let mut out_index = 1;
            for id in ids.sequence_values::<String>() {
                let id = id?;
                let get_quest_fn: LuaFunction = this.get("getQuest")?;
                let quest: LuaTable = get_quest_fn.call((this.clone(), id.clone()))?;
                if quest.get::<_, String>("status")? == wanted {
                    out.set(out_index, id)?;
                    out_index += 1;
                }
            }
            Ok(out)
        })?,
    )?;

    /// Active ids.
    ///
    /// @param this : table
    adapter.set(
        "activeIds",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let fn_ref: LuaFunction = this.get("questsWithStatus")?;
            fn_ref.call::<_, LuaTable>((this, "active"))
        })?,
    )?;
    /// Completed ids.
    ///
    /// @param this : table
    adapter.set(
        "completedIds",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let fn_ref: LuaFunction = this.get("questsWithStatus")?;
            fn_ref.call::<_, LuaTable>((this, "completed"))
        })?,
    )?;
    /// Failed ids.
    ///
    /// @param this : table
    adapter.set(
        "failedIds",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let fn_ref: LuaFunction = this.get("questsWithStatus")?;
            fn_ref.call::<_, LuaTable>((this, "failed"))
        })?,
    )?;

    /// Active count.
    ///
    /// @param this : table
    /// @return integer
    adapter.set(
        "activeCount",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let fn_ref: LuaFunction = this.get("activeIds")?;
            let ids: LuaTable = fn_ref.call((this,))?;
            Ok(ids.raw_len() as i64)
        })?,
    )?;
    /// Completed count.
    ///
    /// @param this : table
    /// @return integer
    adapter.set(
        "completedCount",
        lua.create_function(|_, (this,): (LuaTable,)| {
            let fn_ref: LuaFunction = this.get("completedIds")?;
            let ids: LuaTable = fn_ref.call((this,))?;
            Ok(ids.raw_len() as i64)
        })?,
    )?;

    /// Sets the quest reward.
    ///
    /// @param this : table
    /// @param id : string
    /// @param reward : string
    adapter.set(
        "setQuestReward",
        lua.create_function(|_, (this, id, reward): (LuaTable, String, String)| {
            let defs: LuaTable = this.get("_quest_defs")?;
            let quest: LuaTable = defs.get(id)?;
            quest.set("reward", reward)?;
            Ok(())
        })?,
    )?;
    /// Returns the quest reward.
    ///
    /// @param this : table
    /// @param id : string
    adapter.set(
        "getQuestReward",
        lua.create_function(|_, (this, id): (LuaTable, String)| {
            let defs: LuaTable = this.get("_quest_defs")?;
            match defs.get::<_, Option<LuaTable>>(id)? {
                Some(quest) => quest.get::<_, Option<String>>("reward"),
                None => Ok(None),
            }
        })?,
    )?;

    /// Clears quest.
    ///
    /// @param this : table
    /// @param id : string
    /// @return boolean
    adapter.set(
        "resetQuest",
        lua.create_function(|_, (this, id): (LuaTable, String)| {
            let defs: LuaTable = this.get("_quest_defs")?;
            let quest: LuaTable = match defs.get::<_, Option<LuaTable>>(id.clone())? {
                Some(quest) => quest,
                None => return Ok(false),
            };
            let store_ud: AnyUserData = this.get("_progression_store")?;
            let store = store_from_userdata(store_ud)?;
            let profile_id: String = this.get("_progression_profile_id")?;
            let _ = store.borrow_mut().accept_quest(&profile_id, &id);
            quest.set("status", "available")?;
            Ok(true)
        })?,
    )?;

    /// Type.
    ///
    /// @return string
    adapter.set(
        "type",
        lua.create_function(|_, ()| Ok("LLegacyQuestAdapter"))?,
    )?;
    /// Type of.
    ///
    /// @param name : string
    /// @return boolean
    adapter.set(
        "typeOf",
        lua.create_function(|_, name: String| {
            Ok(name == "LLegacyQuestAdapter" || name == "LObject")
        })?,
    )?;
    Ok(adapter)
}

impl UserData for LuaProfileHandle {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Returns the id.
        ///
        /// @return string
        methods.add_method("getId", |_, this, ()| Ok(this.id.clone()));
        /// Returns this profile's pending reward records as typed reward handles.
        ///
        /// @return | table | Array of `LReward` values still waiting for claim.
        methods.add_method("getPendingRewards", |lua, this, ()| {
            let rewards = this
                .store
                .borrow()
                .get_pending_rewards(&this.id)
                .map_err(|err| progression_error("getPendingRewards", err))?;
            match serde_json::to_value(rewards).map_err(|err| {
                LuaError::RuntimeError(format!("reward serialization failed: {err}"))
            })? {
                JsonValue::Array(values) => userdata_list(
                    lua,
                    values
                        .into_iter()
                        .map(|value| reward_bound(value, this.store.clone(), this.id.clone()))
                        .collect(),
                ),
                _ => Err(LuaError::RuntimeError(
                    "lurek.progression.getPendingRewards: expected reward array".to_string(),
                )),
            }
        });
        /// Type.
        ///
        /// @return string
        methods.add_method("type", |_, _, ()| Ok("LProgressionProfile"));
        /// Type of.
        ///
        /// @param name : string
        /// @return boolean
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LProgressionProfile" || name == "LObject")
        });
    }
}

impl UserData for LuaProgressionTransaction {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method_mut(
            "addCounter",
            |_, this, (profile, counter_id, amount): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.tx
                    .borrow_mut()
                    .add_counter(profile_id, counter_id, amount);
                Ok(())
            },
        );
        methods.add_method_mut(
            "setCounter",
            |_, this, (profile, counter_id, value): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.tx
                    .borrow_mut()
                    .set_counter(profile_id, counter_id, value);
                Ok(())
            },
        );
        methods.add_method_mut(
            "setAttributeBase",
            |_, this, (profile, attribute_id, value): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.tx
                    .borrow_mut()
                    .set_attribute_base(profile_id, attribute_id, value);
                Ok(())
            },
        );
        methods.add_method_mut(
            "setResource",
            |_, this, (profile, resource_id, value): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.tx
                    .borrow_mut()
                    .set_resource(profile_id, resource_id, value);
                Ok(())
            },
        );
        methods.add_method_mut(
            "addModifier",
            |_, this, (profile, target_id, opts): (LuaValue, String, LuaTable)| {
                let profile_id = coerce_profile_id(profile)?;
                this.tx.borrow_mut().add_modifier(
                    profile_id,
                    target_id,
                    parse_modifier_options(opts)?,
                );
                Ok(())
            },
        );
        methods.add_method_mut(
            "setQuestObjective",
            |_, this, (profile, quest_id, objective_id, value): (LuaValue, String, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.tx
                    .borrow_mut()
                    .set_quest_objective(profile_id, quest_id, objective_id, value);
                Ok(())
            },
        );
        methods.add_method_mut(
            "addExperience",
            |_, this, (profile, track_id, amount): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.tx
                    .borrow_mut()
                    .add_experience(profile_id, track_id, amount);
                Ok(())
            },
        );
        /// Commit.
        ///
        methods.add_method_mut("commit", |lua, this, ()| {
            let summary = this
                .store
                .borrow_mut()
                .commit_transaction(&this.tx.borrow())
                .map_err(|err| progression_error("commit", err))?;
            json_to_lua(
                lua,
                serde_json::json!({
                    "revision": summary.revision,
                    "changes": summary.changes,
                }),
            )
        });
        /// Rollback.
        ///
        methods.add_method_mut("rollback", |_, this, ()| {
            *this.tx.borrow_mut() = ProgressionTransaction::new(None);
            Ok(())
        });
        /// Type.
        ///
        /// @return string
        methods.add_method("type", |_, _, ()| Ok("LProgressionTransaction"));
        /// Type of.
        ///
        /// @param name : string
        /// @return boolean
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LProgressionTransaction" || name == "LObject")
        });
    }
}

impl UserData for LuaProgressionStore {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Returns the id.
        ///
        /// @return string
        methods.add_method("getId", |_, this, ()| {
            Ok(this.store.borrow().id().to_string())
        });
        /// Returns the revision.
        ///
        /// @return integer
        methods.add_method("getRevision", |_, this, ()| {
            Ok(this.store.borrow().revision())
        });
        /// Returns the schema version.
        ///
        /// @return integer
        methods.add_method("getSchemaVersion", |_, this, ()| {
            Ok(this.store.borrow().schema_version())
        });
        /// Returns the definition hash.
        ///
        /// @return string
        methods.add_method("getDefinitionHash", |_, this, ()| {
            Ok(this.store.borrow().definition_hash())
        });
        /// Returns the time.
        ///
        /// @return number
        methods.add_method("getTime", |_, this, ()| Ok(this.store.borrow().time()));
        /// Sets the time.
        ///
        /// @param seconds : number
        methods.add_method_mut("setTime", |_, this, seconds: f64| {
            this.store
                .borrow_mut()
                .set_time(seconds)
                .map_err(|err| progression_error("setTime", err))
        });
        /// Advance time.
        ///
        /// @param seconds : number
        methods.add_method_mut("advanceTime", |_, this, seconds: f64| {
            this.store
                .borrow_mut()
                .advance_time(seconds)
                .map_err(|err| progression_error("advanceTime", err))
        });
        methods.add_method_mut(
            "update",
            |lua, this, (dt, _opts): (f64, Option<LuaTable>)| {
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .update(dt)
                        .map_err(|err| progression_error("update", err))?,
                )
            },
        );
        /// Stats.
        ///
        methods.add_method("stats", |lua, this, ()| {
            json_to_lua(lua, this.store.borrow().stats())
        });
        /// Clears the state.
        ///
        methods.add_method_mut("clear", |_, this, ()| {
            this.store.borrow_mut().clear();
            Ok(())
        });
        /// Validate.
        ///
        methods.add_method("validate", |lua, this, ()| {
            json_to_lua(lua, this.store.borrow().validate())
        });
        /// Compile condition.
        ///
        /// @param condition : table
        methods.add_method("compileCondition", |lua, this, condition: LuaTable| {
            json_to_lua(
                lua,
                this.store
                    .borrow()
                    .compile_condition(&parse_condition_definition(condition)?)
                    .map_err(|err| progression_error("compileCondition", err))?,
            )
        });
        /// Validate condition.
        ///
        /// @param condition : table
        methods.add_method("validateCondition", |lua, this, condition: LuaTable| {
            json_to_lua(
                lua,
                this.store
                    .borrow()
                    .validate_condition(&parse_condition_definition(condition)?),
            )
        });
        methods.add_method(
            "evaluateCondition",
            |_, this, (profile, condition): (LuaValue, LuaTable)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .evaluate_condition(&profile_id, &parse_condition_definition(condition)?)
                    .map_err(|err| progression_error("evaluateCondition", err))
            },
        );
        methods.add_method(
            "explainCondition",
            |lua, this, (profile, condition): (LuaValue, LuaTable)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow()
                        .explain_condition(&profile_id, &parse_condition_definition(condition)?)
                        .map_err(|err| progression_error("explainCondition", err))?,
                )
            },
        );
        /// Debug snapshot.
        ///
        methods.add_method("debugSnapshot", |lua, this, ()| {
            json_to_lua(lua, this.store.borrow().debug_snapshot())
        });
        /// Export snapshot.
        ///
        /// @return table
        methods.add_method("exportSnapshot", |lua, this, ()| {
            let encoded = serde_json::to_string(&this.store.borrow().export_snapshot())
                .map_err(|err| progression_error("exportSnapshot", err))?;
            Ok(LuaValue::String(lua.create_string(&encoded)?))
        });
        /// Export changes since.
        ///
        /// @param revision : integer
        /// @return table
        methods.add_method("exportChangesSince", |lua, this, revision: u64| {
            let encoded =
                serde_json::to_string(&this.store.borrow().export_changes_since(revision))
                    .map_err(|err| progression_error("exportChangesSince", err))?;
            Ok(LuaValue::String(lua.create_string(&encoded)?))
        });
        methods.add_method(
            "exportChangeset",
            |lua, this, (revision, options): (u64, Option<LuaTable>)| {
                let max_records = match options {
                    Some(ref table) => table.get::<_, Option<usize>>("max_records")?,
                    None => None,
                };
                let encoded = serde_json::to_string(
                    &this
                        .store
                        .borrow()
                        .export_changeset(revision, max_records)
                        .map_err(|err| progression_error("exportChangeset", err))?,
                )
                .map_err(|err| progression_error("exportChangeset", err))?;
                Ok(LuaValue::String(lua.create_string(&encoded)?))
            },
        );
        /// Load snapshot.
        ///
        /// @param snapshot : any
        methods.add_method_mut("loadSnapshot", |_, this, snapshot: LuaValue| {
            this.store
                .borrow_mut()
                .load_snapshot(snapshot_arg_to_json(snapshot)?)
                .map_err(|err| progression_error("loadSnapshot", err))
        });
        /// Apply changeset.
        ///
        /// @param changeset : any
        methods.add_method_mut("applyChangeset", |lua, this, changeset: LuaValue| {
            let changes: Vec<crate::progression::ChangeRecord> =
                serde_json::from_value(snapshot_arg_to_json(changeset)?)
                    .map_err(|err| progression_error("applyChangeset", err))?;
            json_to_lua(
                lua,
                this.store
                    .borrow_mut()
                    .apply_changeset(changes)
                    .map_err(|err| progression_error("applyChangeset", err))?,
            )
        });
        methods.add_method_mut(
            "applyChangesetEnvelope",
            |lua, this, (changeset, options): (LuaValue, Option<LuaTable>)| {
                let envelope: crate::progression::ChangesetEnvelope =
                    serde_json::from_value(snapshot_arg_to_json(changeset)?)
                        .map_err(|err| progression_error("applyChangesetEnvelope", err))?;
                let apply_options = match options {
                    Some(ref table) => ChangesetApplyOptions {
                        require_definition_hash_match: table
                            .get::<_, Option<bool>>("require_definition_hash_match")?
                            .unwrap_or(true),
                        require_schema_match: table
                            .get::<_, Option<bool>>("require_schema_match")?
                            .unwrap_or(true),
                        merge_policy: parse_changeset_merge_policy(
                            table.get::<_, Option<String>>("merge_policy")?,
                        )?,
                    },
                    None => ChangesetApplyOptions::default(),
                };
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .apply_changeset_envelope_with_options(envelope, apply_options)
                        .map_err(|err| progression_error("applyChangesetEnvelope", err))?,
                )
            },
        );
        /// Ack changes through.
        ///
        /// @param revision : integer
        methods.add_method_mut("ackChangesThrough", |lua, this, revision: u64| {
            json_to_lua(
                lua,
                this.store
                    .borrow_mut()
                    .acknowledge_changes_through(revision),
            )
        });
        /// Compact changes.
        ///
        /// @param max_records : integer
        methods.add_method_mut("compactChanges", |lua, this, max_records: usize| {
            json_to_lua(
                lua,
                this.store
                    .borrow_mut()
                    .compact_changes(max_records)
                    .map_err(|err| progression_error("compactChanges", err))?,
            )
        });
        /// Drain events.
        ///
        methods.add_method_mut("drainEvents", |lua, this, ()| {
            let events = this.store.borrow_mut().drain_events();
            let values = serde_json::to_value(events)
                .map_err(|err| progression_error("drainEvents", err))?;
            json_to_lua(lua, values)
        });
        /// Clears events.
        ///
        methods.add_method_mut("clearEvents", |_, this, ()| {
            this.store.borrow_mut().clear_events();
            Ok(())
        });
        methods.add_method(
            "createProfile",
            |lua, this, (id, options): (String, Option<LuaTable>)| {
                this.store
                    .borrow_mut()
                    .create_profile(&id, parse_profile_options(options)?)
                    .map_err(|err| progression_error("createProfile", err))?;
                lua.create_userdata(LuaProfileHandle {
                    id,
                    store: this.store.clone(),
                })
            },
        );
        methods.add_method_mut(
            "ensureProfile",
            |lua, this, (id, options): (String, Option<LuaTable>)| {
                let created = this
                    .store
                    .borrow_mut()
                    .ensure_profile(&id, parse_profile_options(options)?)
                    .map_err(|err| progression_error("ensureProfile", err))?;
                Ok((
                    lua.create_userdata(LuaProfileHandle {
                        id,
                        store: this.store.clone(),
                    })?,
                    created,
                ))
            },
        );
        /// Returns true if profile.
        ///
        /// @param id : string
        /// @return boolean
        methods.add_method("hasProfile", |_, this, id: String| {
            Ok(this.store.borrow().has_profile(&id))
        });
        /// Returns the profile.
        ///
        /// @param id : string
        methods.add_method("getProfile", |lua, this, id: String| {
            json_to_lua(
                lua,
                this.store
                    .borrow()
                    .get_profile_snapshot(&id)
                    .map_err(|err| progression_error("getProfile", err))?,
            )
        });
        methods.add_method_mut(
            "updateProfile",
            |_, this, (id, patch): (String, Option<LuaTable>)| {
                this.store
                    .borrow_mut()
                    .update_profile(&id, parse_profile_options(patch)?)
                    .map_err(|err| progression_error("updateProfile", err))
            },
        );
        methods.add_method_mut(
            "removeProfile",
            |_, this, (id, _opts): (String, Option<LuaTable>)| {
                this.store
                    .borrow_mut()
                    .remove_profile(&id)
                    .map_err(|err| progression_error("removeProfile", err))
            },
        );
        /// List profiles.
        ///
        /// @param  : table?
        methods.add_method("listProfiles", |lua, this, _: Option<LuaTable>| {
            json_to_lua(lua, JsonValue::Array(this.store.borrow().list_profiles()))
        });
        /// Returns the number of items.
        ///
        /// @param  : table?
        /// @return integer
        methods.add_method("countProfiles", |_, this, _: Option<LuaTable>| {
            Ok(this.store.borrow().count_profiles() as i64)
        });
        /// Adds profile tag.
        ///
        /// @param id : string
        /// @param tag : string
        methods.add_method_mut("addProfileTag", |_, this, (id, tag): (String, String)| {
            this.store
                .borrow_mut()
                .add_profile_tag(&id, &tag)
                .map_err(|err| progression_error("addProfileTag", err))
        });
        methods.add_method_mut(
            "removeProfileTag",
            |_, this, (id, tag): (String, String)| {
                this.store
                    .borrow_mut()
                    .remove_profile_tag(&id, &tag)
                    .map_err(|err| progression_error("removeProfileTag", err))
            },
        );
        methods.add_method_mut(
            "setProfileMetadata",
            |_, this, (id, key, value): (String, String, LuaValue)| {
                this.store
                    .borrow_mut()
                    .set_profile_metadata(&id, &key, lua_to_json(value)?)
                    .map_err(|err| progression_error("setProfileMetadata", err))
            },
        );
        methods.add_method_mut(
            "removeProfileMetadata",
            |_, this, (id, key): (String, String)| {
                this.store
                    .borrow_mut()
                    .remove_profile_metadata(&id, &key)
                    .map_err(|err| progression_error("removeProfileMetadata", err))
            },
        );
        methods.add_method_mut(
            "defineCounter",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_counter(&id, parse_counter_definition(definition)?)
                    .map_err(|err| progression_error("defineCounter", err))
            },
        );
        methods.add_method_mut(
            "addCounter",
            |_, this, (profile, counter_id, amount): (LuaValue, String, Option<f64>)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .add_counter(&profile_id, &counter_id, amount.unwrap_or(1.0))
                    .map_err(|err| progression_error("addCounter", err))
            },
        );
        methods.add_method_mut(
            "setCounter",
            |_, this, (profile, counter_id, value): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .set_counter(&profile_id, &counter_id, value)
                    .map_err(|err| progression_error("setCounter", err))
            },
        );
        methods.add_method(
            "getCounter",
            |_, this, (profile, counter_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .get_counter(&profile_id, &counter_id)
                    .map_err(|err| progression_error("getCounter", err))
            },
        );
        methods.add_method(
            "getCounterState",
            |lua, this, (profile, counter_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow()
                        .get_counter_state(&profile_id, &counter_id)
                        .map_err(|err| progression_error("getCounterState", err))?,
                )
            },
        );
        /// List counters.
        ///
        /// @param profile : any
        methods.add_method("listCounters", |lua, this, (profile,): (LuaValue,)| {
            let profile_id = coerce_profile_id(profile)?;
            json_to_lua(
                lua,
                JsonValue::Array(
                    this.store
                        .borrow()
                        .list_counters(&profile_id)
                        .map_err(|err| progression_error("listCounters", err))?,
                ),
            )
        });
        methods.add_method_mut(
            "defineAttribute",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_attribute(&id, parse_attribute_definition(definition)?)
                    .map_err(|err| progression_error("defineAttribute", err))
            },
        );
        methods.add_method(
            "getAttribute",
            |_, this, (profile, attribute_id, mode): (LuaValue, String, Option<String>)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .get_attribute(&profile_id, &attribute_id, parse_attribute_mode(mode)?)
                    .map_err(|err| progression_error("getAttribute", err))
            },
        );
        methods.add_method(
            "getAttributeState",
            |lua, this, (profile, attribute_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow()
                        .get_attribute_state(&profile_id, &attribute_id)
                        .map_err(|err| progression_error("getAttributeState", err))?,
                )
            },
        );
        methods.add_method_mut(
            "setAttributeBase",
            |_, this, (profile, attribute_id, value): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .set_attribute_base(&profile_id, &attribute_id, value)
                    .map_err(|err| progression_error("setAttributeBase", err))
            },
        );
        methods.add_method_mut(
            "addAttributeBase",
            |_, this, (profile, attribute_id, amount): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .add_attribute_base(&profile_id, &attribute_id, amount)
                    .map_err(|err| progression_error("addAttributeBase", err))
            },
        );
        methods.add_method(
            "explainAttribute",
            |lua, this, (profile, attribute_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                let explanation = this
                    .store
                    .borrow()
                    .explain_attribute(&profile_id, &attribute_id)
                    .map_err(|err| progression_error("explainAttribute", err))?;
                json_to_lua(
                    lua,
                    serde_json::json!({
                        "base": explanation.base,
                        "modifier_total": explanation.modifier_total,
                        "effective": explanation.effective,
                    }),
                )
            },
        );
        methods.add_method_mut(
            "addModifier",
            |_, this, (profile, target_id, opts): (LuaValue, String, LuaTable)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .add_modifier(&profile_id, &target_id, parse_modifier_options(opts)?)
                    .map_err(|err| progression_error("addModifier", err))
            },
        );
        methods.add_method_mut(
            "removeModifier",
            |_, this, (profile, handle): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .remove_modifier(&profile_id, &handle)
                    .map_err(|err| progression_error("removeModifier", err))
            },
        );
        /// List modifiers.
        ///
        /// @param profile : any
        methods.add_method("listModifiers", |lua, this, (profile,): (LuaValue,)| {
            let profile_id = coerce_profile_id(profile)?;
            json_to_lua(
                lua,
                JsonValue::Array(
                    this.store
                        .borrow()
                        .list_modifiers(&profile_id)
                        .map_err(|err| progression_error("listModifiers", err))?,
                ),
            )
        });
        methods.add_method_mut(
            "defineResource",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_resource(&id, parse_resource_definition(definition)?)
                    .map_err(|err| progression_error("defineResource", err))
            },
        );
        methods.add_method(
            "getResource",
            |lua, this, (profile, resource_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow()
                        .get_resource(&profile_id, &resource_id)
                        .map_err(|err| progression_error("getResource", err))?,
                )
            },
        );
        methods.add_method_mut(
            "setResource",
            |_, this, (profile, resource_id, value): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .set_resource(&profile_id, &resource_id, value)
                    .map_err(|err| progression_error("setResource", err))
            },
        );
        methods.add_method_mut(
            "addResource",
            |_, this, (profile, resource_id, amount): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .add_resource(&profile_id, &resource_id, amount)
                    .map_err(|err| progression_error("addResource", err))
            },
        );
        methods.add_method_mut(
            "spendResource",
            |_, this, (profile, resource_id, amount): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .spend_resource(&profile_id, &resource_id, amount)
                    .map_err(|err| progression_error("spendResource", err))
            },
        );
        methods.add_method(
            "canSpendResource",
            |_, this, (profile, resource_id, amount): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .can_spend_resource(&profile_id, &resource_id, amount)
                    .map_err(|err| progression_error("canSpendResource", err))
            },
        );
        methods.add_method_mut(
            "refillResource",
            |_, this, (profile, resource_id, amount): (LuaValue, String, Option<f64>)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .refill_resource(&profile_id, &resource_id, amount)
                    .map_err(|err| progression_error("refillResource", err))
            },
        );
        methods.add_method_mut(
            "defineLevelTrack",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_level_track(&id, parse_level_track_definition(definition)?)
                    .map_err(|err| progression_error("defineLevelTrack", err))
            },
        );
        methods.add_method_mut(
            "defineDerivedValue",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_derived_value(&id, parse_derived_value_definition(definition)?)
                    .map_err(|err| progression_error("defineDerivedValue", err))
            },
        );
        methods.add_method_mut(
            "defineProfileTemplate",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_profile_template(&id, parse_profile_template_definition(definition)?)
                    .map_err(|err| progression_error("defineProfileTemplate", err))
            },
        );
        methods.add_method_mut(
            "defineTrait",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_trait(&id, parse_trait_definition(definition)?)
                    .map_err(|err| progression_error("defineTrait", err))
            },
        );
        methods.add_method_mut(
            "applyTrait",
            |_, this, (profile, trait_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .apply_trait(&profile_id, &trait_id)
                    .map_err(|err| progression_error("applyTrait", err))
            },
        );
        methods.add_method_mut(
            "removeTrait",
            |_, this, (profile, trait_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .remove_trait(&profile_id, &trait_id)
                    .map_err(|err| progression_error("removeTrait", err))
            },
        );
        methods.add_method(
            "hasTrait",
            |_, this, (profile, trait_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .has_trait(&profile_id, &trait_id)
                    .map_err(|err| progression_error("hasTrait", err))
            },
        );
        /// List traits.
        ///
        /// @param profile : any
        methods.add_method("listTraits", |lua, this, (profile,): (LuaValue,)| {
            let profile_id = coerce_profile_id(profile)?;
            json_to_lua(
                lua,
                serde_json::to_value(
                    this.store
                        .borrow()
                        .list_traits(&profile_id)
                        .map_err(|err| progression_error("listTraits", err))?,
                )
                .map_err(|err| {
                    LuaError::RuntimeError(format!("trait serialization failed: {err}"))
                })?,
            )
        });
        methods.add_method_mut(
            "definePerk",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_perk(&id, parse_perk_definition(definition)?)
                    .map_err(|err| progression_error("definePerk", err))
            },
        );
        methods.add_method_mut(
            "defineSkill",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_skill(&id, parse_skill_definition(definition)?)
                    .map_err(|err| progression_error("defineSkill", err))
            },
        );
        methods.add_method_mut(
            "learnSkill",
            |_, this, (profile, skill_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .learn_skill(&profile_id, &skill_id)
                    .map_err(|err| progression_error("learnSkill", err))
            },
        );
        methods.add_method_mut(
            "useSkill",
            |lua, this, (profile, skill_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .use_skill(&profile_id, &skill_id)
                        .map_err(|err| progression_error("useSkill", err))?,
                )
            },
        );
        methods.add_method(
            "getSkillLevel",
            |_, this, (profile, skill_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .get_skill_level(&profile_id, &skill_id)
                    .map_err(|err| progression_error("getSkillLevel", err))
            },
        );
        methods.add_method(
            "getSkillCooldown",
            |_, this, (profile, skill_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .get_skill_cooldown(&profile_id, &skill_id)
                    .map_err(|err| progression_error("getSkillCooldown", err))
            },
        );
        methods.add_method_mut(
            "acquirePerk",
            |_, this, (profile, perk_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .acquire_perk(&profile_id, &perk_id)
                    .map_err(|err| progression_error("acquirePerk", err))
            },
        );
        methods.add_method(
            "hasPerk",
            |_, this, (profile, perk_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .has_perk(&profile_id, &perk_id)
                    .map_err(|err| progression_error("hasPerk", err))
            },
        );
        methods.add_method_mut(
            "applyProfileTemplate",
            |lua, this, (profile, template_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .apply_profile_template(&profile_id, &template_id)
                        .map_err(|err| progression_error("applyProfileTemplate", err))?,
                )
            },
        );
        methods.add_method_mut(
            "defineLeaderboard",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_leaderboard(&id, parse_leaderboard_definition(definition, &id)?)
                    .map_err(|err| progression_error("defineLeaderboard", err))
            },
        );
        methods.add_method_mut(
            "defineSeason",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_season(&id, parse_season_definition(definition, &id)?)
                    .map_err(|err| progression_error("defineSeason", err))
            },
        );
        methods.add_method_mut(
            "startSeason",
            |lua, this, (id, options): (String, Option<LuaTable>)| {
                let time_override = match options {
                    Some(ref opts) => opts.get::<_, Option<f64>>("time")?,
                    None => None,
                };
                lua.create_userdata(season(
                    this.store
                        .borrow_mut()
                        .start_season(&id, time_override)
                        .map_err(|err| progression_error("startSeason", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method_mut(
            "endSeason",
            |lua, this, (id, options): (String, Option<LuaTable>)| {
                let time_override = match options {
                    Some(ref opts) => opts.get::<_, Option<f64>>("time")?,
                    None => None,
                };
                let archive_override = match options {
                    Some(ref opts) => opts.get::<_, Option<bool>>("archive")?,
                    None => None,
                };
                lua.create_userdata(season(
                    this.store
                        .borrow_mut()
                        .end_season(&id, time_override, archive_override)
                        .map_err(|err| progression_error("endSeason", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        /// Returns the season.
        ///
        /// @param id : string
        methods.add_method("getSeason", |lua, this, id: String| {
            lua.create_userdata(season(
                this.store
                    .borrow()
                    .get_season(&id)
                    .map_err(|err| progression_error("getSeason", err))?,
            ))
            .map(LuaValue::UserData)
        });
        /// List seasons.
        ///
        /// @param query : table?
        methods.add_method("listSeasons", |lua, this, query: Option<LuaTable>| {
            let active_only = match query {
                Some(ref table) => table.get::<_, Option<bool>>("active")?,
                None => None,
            };
            userdata_list(
                lua,
                this.store
                    .borrow()
                    .list_seasons(active_only)
                    .into_iter()
                    .map(season)
                    .collect(),
            )
        });
        methods.add_method(
            "getSeasonArchive",
            |lua, this, (id, query): (String, Option<LuaTable>)| {
                let latest_only = match query {
                    Some(ref table) => table.get::<_, Option<bool>>("latest")?.unwrap_or(false),
                    None => false,
                };
                let archive = this
                    .store
                    .borrow()
                    .get_season_archive(&id, latest_only)
                    .map_err(|err| progression_error("getSeasonArchive", err))?;
                if latest_only {
                    if archive.is_null() {
                        Ok(LuaValue::Nil)
                    } else {
                        lua.create_userdata(season_archive(archive))
                            .map(LuaValue::UserData)
                    }
                } else if let JsonValue::Array(values) = archive {
                    userdata_list(lua, values.into_iter().map(season_archive).collect())
                } else {
                    Err(LuaError::RuntimeError(
                        "lurek.progression.getSeasonArchive: expected archive array".to_string(),
                    ))
                }
            },
        );
        methods.add_method_mut(
            "definePrestige",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_prestige(&id, parse_prestige_definition(definition, &id)?)
                    .map_err(|err| progression_error("definePrestige", err))
            },
        );
        methods.add_method(
            "canPrestige",
            |_, this, (profile, prestige_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .can_prestige(&profile_id, &prestige_id)
                    .map_err(|err| progression_error("canPrestige", err))
            },
        );
        methods.add_method_mut(
            "applyPrestige",
            |lua, this, (profile, prestige_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(prestige(
                    this.store
                        .borrow_mut()
                        .apply_prestige(&profile_id, &prestige_id)
                        .map_err(|err| progression_error("applyPrestige", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method(
            "getPrestige",
            |lua, this, (profile, prestige_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(prestige(
                    this.store
                        .borrow()
                        .get_prestige(&profile_id, &prestige_id)
                        .map_err(|err| progression_error("getPrestige", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        /// List prestiges.
        ///
        /// @param profile : any
        methods.add_method("listPrestiges", |lua, this, (profile,): (LuaValue,)| {
            let profile_id = coerce_profile_id(profile)?;
            userdata_list(
                lua,
                this.store
                    .borrow()
                    .list_prestiges(&profile_id)
                    .map_err(|err| progression_error("listPrestiges", err))?
                    .into_iter()
                    .map(prestige)
                    .collect(),
            )
        });
        methods.add_method_mut(
            "defineCollection",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_collection(&id, parse_collection_definition(definition, &id)?)
                    .map_err(|err| progression_error("defineCollection", err))
            },
        );
        methods.add_method_mut(
            "collectCollectionItem",
            |lua, this, (profile, collection_id, item_id): (LuaValue, String, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(collection(
                    this.store
                        .borrow_mut()
                        .collect_collection_item(&profile_id, &collection_id, &item_id)
                        .map_err(|err| progression_error("collectCollectionItem", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method(
            "getCollection",
            |lua, this, (profile, collection_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(collection(
                    this.store
                        .borrow()
                        .get_collection(&profile_id, &collection_id)
                        .map_err(|err| progression_error("getCollection", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        /// List collections.
        ///
        /// @param profile : any
        methods.add_method("listCollections", |lua, this, (profile,): (LuaValue,)| {
            let profile_id = coerce_profile_id(profile)?;
            userdata_list(
                lua,
                this.store
                    .borrow()
                    .list_collections(&profile_id)
                    .map_err(|err| progression_error("listCollections", err))?
                    .into_iter()
                    .map(collection)
                    .collect(),
            )
        });
        methods.add_method_mut(
            "pinRival",
            |lua, this, (profile, rival_profile, options): (LuaValue, LuaValue, Option<LuaTable>)| {
                let profile_id = coerce_profile_id(profile)?;
                let rival_profile_id = coerce_profile_id(rival_profile)?;
                let leaderboard_id = match options {
                    Some(ref table) => table.get::<_, Option<String>>("leaderboard_id")?,
                    None => None,
                };
                lua.create_userdata(rival(
                    this.store
                        .borrow_mut()
                        .pin_rival(&profile_id, &rival_profile_id, leaderboard_id)
                        .map_err(|err| progression_error("pinRival", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method(
            "getRival",
            |lua, this, (profile, rival_profile): (LuaValue, LuaValue)| {
                let profile_id = coerce_profile_id(profile)?;
                let rival_profile_id = coerce_profile_id(rival_profile)?;
                lua.create_userdata(rival(
                    this.store
                        .borrow()
                        .get_rival(&profile_id, &rival_profile_id)
                        .map_err(|err| progression_error("getRival", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        /// List rivals.
        ///
        /// @param profile : any
        methods.add_method("listRivals", |lua, this, (profile,): (LuaValue,)| {
            let profile_id = coerce_profile_id(profile)?;
            userdata_list(
                lua,
                this.store
                    .borrow()
                    .list_rivals(&profile_id)
                    .map_err(|err| progression_error("listRivals", err))?
                    .into_iter()
                    .map(rival)
                    .collect(),
            )
        });
        methods.add_method(
            "getRivalDelta",
            |lua, this, (profile, rival_profile): (LuaValue, LuaValue)| {
                let profile_id = coerce_profile_id(profile)?;
                let rival_profile_id = coerce_profile_id(rival_profile)?;
                lua.create_userdata(rival_delta(
                    this.store
                        .borrow()
                        .get_rival_delta(&profile_id, &rival_profile_id)
                        .map_err(|err| progression_error("getRivalDelta", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        /// Returns one typed activity-feed selection object.
        ///
        /// @param query : table?
        methods.add_method("getActivityFeed", |lua, this, query: Option<LuaTable>| {
            let profiles = match query {
                Some(ref table) => match table.get::<_, Option<LuaTable>>("profiles")? {
                    Some(values) => Some(
                        values
                            .sequence_values::<LuaValue>()
                            .map(|value| coerce_profile_id(value?))
                            .collect::<LuaResult<Vec<_>>>()?,
                    ),
                    None => None,
                },
                None => None,
            };
            let types = match query {
                Some(ref table) => match table.get::<_, Option<LuaTable>>("types")? {
                    Some(values) => Some(
                        values
                            .sequence_values::<String>()
                            .collect::<LuaResult<Vec<_>>>()?,
                    ),
                    None => None,
                },
                None => None,
            };
            let limit = match query {
                Some(ref table) => table.get::<_, Option<usize>>("limit")?,
                None => None,
            };
            let entries = serde_json::to_value(
                this.store
                    .borrow()
                    .get_activity_feed(profiles.clone(), types.clone(), limit)
                    .map_err(|err| progression_error("getActivityFeed", err))?,
            )
            .map_err(|err| {
                progression_error(
                    "getActivityFeed",
                    format!("feed serialization failed: {err}"),
                )
            })?;
            lua.create_userdata(activity_feed(entries, profiles, types, limit))
                .map(LuaValue::UserData)
        });
        methods.add_method_mut(
            "definePopulationTemplate",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_population_template(
                        &id,
                        parse_population_template_definition(definition, &id)?,
                    )
                    .map_err(|err| progression_error("definePopulationTemplate", err))
            },
        );
        /// Validate population template.
        ///
        /// @param id : string
        methods.add_method("validatePopulationTemplate", |lua, this, id: String| {
            json_to_lua(
                lua,
                this.store
                    .borrow()
                    .validate_population_template(&id)
                    .map_err(|err| progression_error("validatePopulationTemplate", err))?,
            )
        });
        methods.add_method_mut(
            "generatePopulation",
            |lua, this, (template_id, options): (String, Option<LuaTable>)| {
                let population_id = match options {
                    Some(ref table) => table.get::<_, Option<String>>("id")?,
                    None => None,
                };
                lua.create_userdata(population(
                    this.store
                        .borrow_mut()
                        .generate_population(&template_id, population_id)
                        .map_err(|err| progression_error("generatePopulation", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        /// Returns the population.
        ///
        /// @param handle_or_id : string
        methods.add_method("getPopulation", |lua, this, handle_or_id: String| {
            lua.create_userdata(population(
                this.store
                    .borrow()
                    .get_population(&handle_or_id)
                    .map_err(|err| progression_error("getPopulation", err))?,
            ))
            .map(LuaValue::UserData)
        });
        methods.add_method_mut(
            "updatePopulation",
            |lua, this, (handle_or_id, dt, _options): (String, f64, Option<LuaTable>)| {
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .update_population(&handle_or_id, dt)
                        .map_err(|err| progression_error("updatePopulation", err))?,
                )
            },
        );
        methods.add_method_mut(
            "simulatePopulationUntil",
            |lua, this, (handle_or_id, logical_time, _options): (String, f64, Option<LuaTable>)| {
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .simulate_population_until(&handle_or_id, logical_time)
                        .map_err(|err| progression_error("simulatePopulationUntil", err))?,
                )
            },
        );
        /// Pause population.
        ///
        /// @param handle_or_id : string
        methods.add_method_mut("pausePopulation", |lua, this, handle_or_id: String| {
            json_to_lua(
                lua,
                this.store
                    .borrow_mut()
                    .pause_population(&handle_or_id)
                    .map_err(|err| progression_error("pausePopulation", err))?,
            )
        });
        /// Resume population.
        ///
        /// @param handle_or_id : string
        methods.add_method_mut("resumePopulation", |lua, this, handle_or_id: String| {
            json_to_lua(
                lua,
                this.store
                    .borrow_mut()
                    .resume_population(&handle_or_id)
                    .map_err(|err| progression_error("resumePopulation", err))?,
            )
        });
        methods.add_method_mut(
            "removePopulation",
            |_, this, (handle_or_id, options): (String, Option<LuaTable>)| {
                let remove_materialized_profiles = match options {
                    Some(ref table) => table
                        .get::<_, Option<bool>>("remove_materialized_profiles")?
                        .unwrap_or(false),
                    None => false,
                };
                this.store
                    .borrow_mut()
                    .remove_population(&handle_or_id, remove_materialized_profiles)
                    .map_err(|err| progression_error("removePopulation", err))
            },
        );
        methods.add_method_mut(
            "regeneratePopulation",
            |lua, this, (handle_or_id, options): (String, Option<LuaTable>)| {
                let remove_materialized_profiles = match options {
                    Some(ref table) => table
                        .get::<_, Option<bool>>("remove_materialized_profiles")?
                        .unwrap_or(false),
                    None => false,
                };
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .regenerate_population(&handle_or_id, remove_materialized_profiles)
                        .map_err(|err| progression_error("regeneratePopulation", err))?,
                )
            },
        );
        methods.add_method(
            "getPopulationStatistics",
            |lua, this, (handle_or_id, query): (String, Option<LuaTable>)| {
                let leaderboard_id = match query {
                    Some(ref table) => table.get::<_, Option<String>>("leaderboard_id")?,
                    None => None,
                };
                json_to_lua(
                    lua,
                    this.store
                        .borrow()
                        .get_population_statistics(&handle_or_id, leaderboard_id.as_deref())
                        .map_err(|err| progression_error("getPopulationStatistics", err))?,
                )
            },
        );
        methods.add_method(
            "listPopulationProfiles",
            |lua, this, (handle_or_id, query): (String, Option<LuaTable>)| {
                let materialized = match query {
                    Some(ref table) => table.get::<_, Option<bool>>("materialized")?,
                    None => None,
                };
                let limit = match query {
                    Some(ref table) => table.get::<_, Option<usize>>("limit")?,
                    None => None,
                };
                userdata_list(
                    lua,
                    this.store
                        .borrow()
                        .list_population_profiles(&handle_or_id, materialized, limit)
                        .map_err(|err| progression_error("listPopulationProfiles", err))?
                        .into_iter()
                        .map(population_profile)
                        .collect(),
                )
            },
        );
        methods.add_method_mut(
            "materializePopulationProfile",
            |lua, this, profile_id: String| {
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .materialize_population_profile(&profile_id)
                        .map_err(|err| progression_error("materializePopulationProfile", err))?,
                )
            },
        );
        methods.add_method_mut(
            "dematerializePopulationProfile",
            |_, this, (profile_id, options): (String, Option<LuaTable>)| {
                let remove_profile = match options {
                    Some(ref table) => table
                        .get::<_, Option<bool>>("remove_profile")?
                        .unwrap_or(false),
                    None => false,
                };
                this.store
                    .borrow_mut()
                    .dematerialize_population_profile(&profile_id, remove_profile)
                    .map_err(|err| progression_error("dematerializePopulationProfile", err))
            },
        );
        /// Removes derived value.
        ///
        /// @param id : string
        /// @return boolean
        methods.add_method_mut("removeDerivedValue", |_, this, id: String| {
            Ok(this.store.borrow_mut().remove_derived_value(&id))
        });
        methods.add_method(
            "getDerivedValue",
            |_, this, (profile, id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .get_derived_value(&profile_id, &id)
                    .map_err(|err| progression_error("getDerivedValue", err))
            },
        );
        methods.add_method(
            "explainDerivedValue",
            |lua, this, (profile, id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow()
                        .explain_derived_value(&profile_id, &id)
                        .map_err(|err| progression_error("explainDerivedValue", err))?,
                )
            },
        );
        /// Validate derived values.
        ///
        methods.add_method("validateDerivedValues", |lua, this, ()| {
            json_to_lua(lua, this.store.borrow().validate_derived_values())
        });
        methods.add_method_mut(
            "submitScore",
            |lua, this, (profile, leaderboard_id, score): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(leaderboard_entry(
                    this.store
                        .borrow_mut()
                        .submit_score(&profile_id, &leaderboard_id, score)
                        .map_err(|err| progression_error("submitScore", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method(
            "getLeaderboardEntry",
            |lua, this, (profile, leaderboard_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(leaderboard_entry(
                    this.store
                        .borrow()
                        .get_leaderboard_entry(&profile_id, &leaderboard_id)
                        .map_err(|err| progression_error("getLeaderboardEntry", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method(
            "listLeaderboardTop",
            |lua, this, (leaderboard_id, limit): (String, Option<usize>)| {
                userdata_list(
                    lua,
                    this.store
                        .borrow()
                        .list_leaderboard_top(&leaderboard_id, limit)
                        .map_err(|err| progression_error("listLeaderboardTop", err))?
                        .into_iter()
                        .map(leaderboard_entry)
                        .collect(),
                )
            },
        );
        methods.add_method(
            "listLeaderboardRange",
            |lua, this, (leaderboard_id, start_rank, limit): (String, u64, Option<usize>)| {
                userdata_list(
                    lua,
                    this.store
                        .borrow()
                        .list_leaderboard_range(&leaderboard_id, start_rank, limit)
                        .map_err(|err| progression_error("listLeaderboardRange", err))?
                        .into_iter()
                        .map(leaderboard_entry)
                        .collect(),
                )
            },
        );
        methods.add_method(
            "listLeaderboardAroundProfile",
            |lua,
             this,
             (leaderboard_id, profile, before, after): (
                String,
                LuaValue,
                Option<usize>,
                Option<usize>,
            )| {
                let profile_id = coerce_profile_id(profile)?;
                userdata_list(
                    lua,
                    this.store
                        .borrow()
                        .list_leaderboard_around_profile(
                            &leaderboard_id,
                            &profile_id,
                            before,
                            after,
                        )
                        .map_err(|err| progression_error("listLeaderboardAroundProfile", err))?
                        .into_iter()
                        .map(leaderboard_entry)
                        .collect(),
                )
            },
        );
        methods.add_method_mut(
            "addExperience",
            |lua, this, (profile, track_id, amount): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .add_experience(&profile_id, &track_id, amount)
                        .map_err(|err| progression_error("addExperience", err))?,
                )
            },
        );
        methods.add_method(
            "getExperience",
            |lua, this, (profile, track_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow()
                        .get_experience(&profile_id, &track_id)
                        .map_err(|err| progression_error("getExperience", err))?,
                )
            },
        );
        methods.add_method_mut(
            "setExperience",
            |lua, this, (profile, track_id, value): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .set_experience(&profile_id, &track_id, value)
                        .map_err(|err| progression_error("setExperience", err))?,
                )
            },
        );
        methods.add_method(
            "getLevel",
            |_, this, (profile, track_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .get_level(&profile_id, &track_id)
                    .map_err(|err| progression_error("getLevel", err))
            },
        );
        methods.add_method_mut(
            "setLevel",
            |lua, this, (profile, track_id, level): (LuaValue, String, u32)| {
                let profile_id = coerce_profile_id(profile)?;
                json_to_lua(
                    lua,
                    this.store
                        .borrow_mut()
                        .set_level(&profile_id, &track_id, level)
                        .map_err(|err| progression_error("setLevel", err))?,
                )
            },
        );
        methods.add_method(
            "getExperienceToNextLevel",
            |_, this, (profile, track_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow()
                    .get_experience_to_next_level(&profile_id, &track_id)
                    .map_err(|err| progression_error("getExperienceToNextLevel", err))
            },
        );
        methods.add_method_mut(
            "defineQuest",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_quest(&id, parse_quest_definition(definition, &id)?)
                    .map_err(|err| progression_error("defineQuest", err))
            },
        );
        methods.add_method_mut(
            "defineChallengeTemplate",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_challenge_template(
                        &id,
                        parse_challenge_template_definition(definition, &id)?,
                    )
                    .map_err(|err| progression_error("defineChallengeTemplate", err))
            },
        );
        methods.add_method_mut(
            "activateChallenge",
            |lua, this, (profile, challenge_id, options): (LuaValue, String, Option<LuaTable>)| {
                let profile_id = coerce_profile_id(profile)?;
                let time = if let Some(options) = options {
                    options.get::<_, Option<f64>>("time")?
                } else {
                    None
                };
                lua.create_userdata(challenge(
                    this.store
                        .borrow_mut()
                        .activate_challenge(&profile_id, &challenge_id, time)
                        .map_err(|err| progression_error("activateChallenge", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method_mut(
            "setChallengeProgress",
            |lua, this, (profile, challenge_id, value): (LuaValue, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(challenge(
                    this.store
                        .borrow_mut()
                        .set_challenge_progress(&profile_id, &challenge_id, value)
                        .map_err(|err| progression_error("setChallengeProgress", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method(
            "getChallenge",
            |lua, this, (profile, challenge_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(challenge(
                    this.store
                        .borrow()
                        .get_challenge(&profile_id, &challenge_id)
                        .map_err(|err| progression_error("getChallenge", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method(
            "listChallenges",
            |lua, this, (profile, options): (LuaValue, Option<LuaTable>)| {
                let profile_id = coerce_profile_id(profile)?;
                let status = if let Some(options) = options {
                    options.get::<_, Option<String>>("status")?
                } else {
                    None
                };
                userdata_list(
                    lua,
                    this.store
                        .borrow()
                        .list_challenges(&profile_id, status.as_deref())
                        .map_err(|err| progression_error("listChallenges", err))?
                        .into_iter()
                        .map(challenge)
                        .collect(),
                )
            },
        );
        methods.add_method_mut(
            "defineAchievement",
            |_, this, (id, definition): (String, LuaTable)| {
                this.store
                    .borrow_mut()
                    .define_achievement(&id, parse_achievement_definition(definition, &id)?)
                    .map_err(|err| progression_error("defineAchievement", err))
            },
        );
        methods.add_method_mut(
            "unlockAchievement",
            |lua, this, (profile, achievement_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(achievement(
                    this.store
                        .borrow_mut()
                        .unlock_achievement(&profile_id, &achievement_id)
                        .map_err(|err| progression_error("unlockAchievement", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method(
            "getAchievement",
            |lua, this, (profile, achievement_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(achievement(
                    this.store
                        .borrow()
                        .get_achievement(&profile_id, &achievement_id)
                        .map_err(|err| progression_error("getAchievement", err))?,
                ))
                .map(LuaValue::UserData)
            },
        );
        /// List achievements.
        ///
        /// @param profile : any
        methods.add_method("listAchievements", |lua, this, (profile,): (LuaValue,)| {
            let profile_id = coerce_profile_id(profile)?;
            userdata_list(
                lua,
                this.store
                    .borrow()
                    .list_achievements(&profile_id)
                    .map_err(|err| progression_error("listAchievements", err))?
                    .into_iter()
                    .map(achievement)
                    .collect(),
            )
        });
        /// Returns the pending rewards.
        ///
        /// @param profile : any
        methods.add_method_mut(
            "acceptQuest",
            |_, this, (profile, quest_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .accept_quest(&profile_id, &quest_id)
                    .map_err(|err| progression_error("acceptQuest", err))
            },
        );
        methods.add_method_mut(
            "revealQuest",
            |lua, this, (profile, quest_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(quest_state_bound(
                    this.store
                        .borrow_mut()
                        .reveal_quest(&profile_id, &quest_id)
                        .map_err(|err| progression_error("revealQuest", err))?,
                    this.store.clone(),
                    profile_id,
                ))
                .map(LuaValue::UserData)
            },
        );
        /// Refresh quest lifecycle.
        ///
        /// @param profile : any
        methods.add_method_mut("refreshQuestLifecycle", |_, this, profile: LuaValue| {
            let profile_id = coerce_profile_id(profile)?;
            this.store
                .borrow_mut()
                .refresh_quest_lifecycle(&profile_id)
                .map_err(|err| progression_error("refreshQuestLifecycle", err))
        });
        methods.add_method_mut(
            "completeQuest",
            |_, this, (profile, quest_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .complete_quest(&profile_id, &quest_id)
                    .map_err(|err| progression_error("completeQuest", err))
            },
        );
        methods.add_method_mut(
            "failQuest",
            |_, this, (profile, quest_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                this.store
                    .borrow_mut()
                    .fail_quest(&profile_id, &quest_id)
                    .map_err(|err| progression_error("failQuest", err))
            },
        );
        methods.add_method_mut(
            "setQuestObjective",
            |lua, this, (profile, quest_id, objective_id, value): (LuaValue, String, String, f64)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(quest_state_bound(
                    this.store
                        .borrow_mut()
                        .set_quest_objective(&profile_id, &quest_id, &objective_id, value)
                        .map_err(|err| progression_error("setQuestObjective", err))?,
                    this.store.clone(),
                    profile_id,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method_mut(
            "setQuestObjectiveStatus",
            |lua, this, (profile, quest_id, objective_id, status): (LuaValue, String, String, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(quest_state_bound(
                    this.store
                        .borrow_mut()
                        .set_quest_objective_status(
                            &profile_id,
                            &quest_id,
                            &objective_id,
                            &status,
                        )
                        .map_err(|err| progression_error("setQuestObjectiveStatus", err))?,
                    this.store.clone(),
                    profile_id,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method_mut(
            "setQuestObjectiveVisibility",
            |lua, this, (profile, quest_id, objective_id, visible): (LuaValue, String, String, bool)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(quest_state_bound(
                    this.store
                        .borrow_mut()
                        .set_quest_objective_visibility(
                            &profile_id,
                            &quest_id,
                            &objective_id,
                            visible,
                        )
                        .map_err(|err| progression_error("setQuestObjectiveVisibility", err))?,
                    this.store.clone(),
                    profile_id,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method(
            "getQuestState",
            |lua, this, (profile, quest_id): (LuaValue, String)| {
                let profile_id = coerce_profile_id(profile)?;
                lua.create_userdata(quest_state_bound(
                    this.store
                        .borrow()
                        .get_quest_state(&profile_id, &quest_id)
                        .map_err(|err| progression_error("getQuestState", err))?,
                    this.store.clone(),
                    profile_id,
                ))
                .map(LuaValue::UserData)
            },
        );
        methods.add_method(
            "beginTransaction",
            |lua, this, options: Option<LuaTable>| {
                let tx_id = if let Some(options) = options {
                    options.get::<_, Option<String>>("id")?
                } else {
                    None
                };
                lua.create_userdata(LuaProgressionTransaction {
                    store: this.store.clone(),
                    tx: Rc::new(RefCell::new(this.store.borrow().begin_transaction(tx_id))),
                })
            },
        );
        /// Type.
        ///
        /// @return string
        methods.add_method("type", |_, _, ()| Ok("LProgressionStore"));
        /// Type of.
        ///
        /// @param name : string
        /// @return boolean
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LProgressionStore" || name == "LObject")
        });
    }
}

fn parse_store_options(table: Option<LuaTable>) -> LuaResult<ProgressionStoreOptions> {
    let Some(table) = table else {
        return Ok(ProgressionStoreOptions::default());
    };
    Ok(ProgressionStoreOptions {
        id: table
            .get::<_, Option<String>>("id")?
            .unwrap_or_else(|| "progression".to_string()),
        seed: table.get::<_, Option<u64>>("seed")?.unwrap_or(0),
        clock: table
            .get::<_, Option<String>>("clock")?
            .unwrap_or_else(|| "manual".to_string()),
        event_capacity: table
            .get::<_, Option<usize>>("event_capacity")?
            .unwrap_or(1024),
        change_capacity: table
            .get::<_, Option<usize>>("change_capacity")?
            .unwrap_or(256),
        max_profiles: table
            .get::<_, Option<usize>>("max_profiles")?
            .unwrap_or(10_000),
        strict: table.get::<_, Option<bool>>("strict")?.unwrap_or(true),
    })
}

fn import_legacy_stats_snapshot<'lua>(
    lua: &'lua Lua,
    snapshot: LuaTable<'lua>,
) -> LuaResult<LuaValue<'lua>> {
    let mut attributes = Vec::new();
    if let Ok(attribute_table) = snapshot.get::<_, LuaTable>("attributes") {
        for pair in attribute_table.pairs::<String, LuaTable>() {
            let (id, attribute) = pair?;
            attributes.push(serde_json::json!({
                "id": id,
                "base": attribute.get::<_, Option<f64>>("base")?.unwrap_or(0.0),
            }));
        }
    }
    let xp = snapshot.get::<_, Option<f64>>("xp")?.unwrap_or(0.0);
    let level = snapshot.get::<_, Option<u32>>("level")?.unwrap_or(1);
    json_to_lua(
        lua,
        serde_json::json!({
            "attributes": attributes,
            "experience": { "track_id": "legacy_xp", "experience": xp, "level": level },
            "warnings": {},
        }),
    )
}

fn import_legacy_quest_snapshot<'lua>(
    lua: &'lua Lua,
    snapshot: LuaTable<'lua>,
) -> LuaResult<LuaValue<'lua>> {
    let mut quests = Vec::new();
    if let Ok(quest_table) = snapshot.get::<_, LuaTable>("quests") {
        for value in quest_table.sequence_values::<LuaTable>() {
            let quest = value?;
            quests.push(serde_json::json!({
                "id": quest.get::<_, Option<String>>("id")?.unwrap_or_default(),
                "title": quest.get::<_, Option<String>>("title")?.unwrap_or_default(),
                "status": quest.get::<_, Option<String>>("status")?.unwrap_or_else(|| "available".to_string()),
            }));
        }
    }
    json_to_lua(lua, serde_json::json!({ "quests": quests, "warnings": {} }))
}

/// Register the `lurek.progression` module into the Lua runtime.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let table = lua.create_table()?;
    /// New store.
    ///
    /// @param options : table?
    table.set(
        "newStore",
        lua.create_function(|lua, options: Option<LuaTable>| {
            let store = ProgressionStore::new(parse_store_options(options)?)
                .map_err(|err| progression_error("newStore", err))?;
            lua.create_userdata(LuaProgressionStore {
                store: Rc::new(RefCell::new(store)),
            })
        })?,
    )?;
    /// Load store.
    ///
    /// @param snapshot : any
    table.set(
        "loadStore",
        lua.create_function(|lua, snapshot: LuaValue| {
            let store = ProgressionStore::from_snapshot(snapshot_arg_to_json(snapshot)?)
                .map_err(|err| progression_error("loadStore", err))?;
            lua.create_userdata(LuaProgressionStore {
                store: Rc::new(RefCell::new(store)),
            })
        })?,
    )?;
    /// Import legacy stats snapshot.
    ///
    /// @param snapshot : table
    table.set(
        "importLegacyStatsSnapshot",
        lua.create_function(|lua, snapshot: LuaTable| import_legacy_stats_snapshot(lua, snapshot))?,
    )?;
    /// Import legacy quest snapshot.
    ///
    /// @param snapshot : table
    table.set(
        "importLegacyQuestSnapshot",
        lua.create_function(|lua, snapshot: LuaTable| import_legacy_quest_snapshot(lua, snapshot))?,
    )?;
    /// Create legacy stats adapter.
    ///
    /// @param store : AnyUserData
    /// @param profile : any
    /// @param options : table?
    table.set(
        "createLegacyStatsAdapter",
        lua.create_function(
            |lua, (store, profile, _options): (AnyUserData, LuaValue, Option<LuaTable>)| {
                let store = store_from_userdata(store)?;
                let profile_id = coerce_profile_id(profile)?;
                build_legacy_stats_adapter(lua, store, profile_id)
            },
        )?,
    )?;
    /// Create legacy quest adapter.
    ///
    /// @param store : AnyUserData
    /// @param profile : any
    /// @param options : table?
    table.set(
        "createLegacyQuestAdapter",
        lua.create_function(
            |lua, (store, profile, _options): (AnyUserData, LuaValue, Option<LuaTable>)| {
                let store = store_from_userdata(store)?;
                let profile_id = coerce_profile_id(profile)?;
                build_legacy_quest_adapter(lua, store, profile_id)
            },
        )?,
    )?;
    lurek.set("progression", table)?;
    Ok(())
}

mod progression_objects_api_impl {
    //! Owns typed Lua userdata wrappers for `lurek.progression` snapshot entities and legacy
    //! field-compatible accessors.

    use crate::progression::ProgressionStore;
    use mlua::prelude::*;
    use mlua::{UserData, UserDataFields, UserDataMethods, Value as LuaValue};
    use serde_json::{Map as JsonMap, Value as JsonValue};
    use std::cell::RefCell;
    use std::rc::Rc;

    fn json_to_lua<'lua>(lua: &'lua Lua, value: &JsonValue) -> LuaResult<LuaValue<'lua>> {
        match value {
            JsonValue::Null => Ok(LuaValue::Nil),
            JsonValue::Bool(value) => Ok(LuaValue::Boolean(*value)),
            JsonValue::Number(value) => {
                if let Some(integer) = value.as_i64() {
                    Ok(LuaValue::Integer(integer))
                } else {
                    Ok(LuaValue::Number(value.as_f64().unwrap_or(0.0)))
                }
            }
            JsonValue::String(value) => Ok(LuaValue::String(lua.create_string(value)?)),
            JsonValue::Array(values) => {
                let table = lua.create_table()?;
                for (index, value) in values.iter().enumerate() {
                    table.set(index + 1, json_to_lua(lua, value)?)?;
                }
                Ok(LuaValue::Table(table))
            }
            JsonValue::Object(values) => {
                let table = lua.create_table()?;
                for (key, value) in values {
                    table.set(key.as_str(), json_to_lua(lua, value)?)?;
                }
                Ok(LuaValue::Table(table))
            }
        }
    }

    fn snapshot_object(snapshot: &JsonValue) -> LuaResult<&JsonMap<String, JsonValue>> {
        snapshot.as_object().ok_or_else(|| {
            LuaError::RuntimeError(
                "progression snapshot wrapper expected an object value".to_string(),
            )
        })
    }

    fn snapshot_value<'a>(snapshot: &'a JsonValue, key: &str) -> LuaResult<&'a JsonValue> {
        snapshot_object(snapshot)?.get(key).ok_or_else(|| {
            LuaError::RuntimeError(format!("progression snapshot is missing '{key}'"))
        })
    }

    fn snapshot_string(snapshot: &JsonValue, key: &str) -> LuaResult<String> {
        snapshot_value(snapshot, key)?
            .as_str()
            .map(str::to_string)
            .ok_or_else(|| {
                LuaError::RuntimeError(format!("progression snapshot '{key}' must be a string"))
            })
    }

    fn snapshot_bool(snapshot: &JsonValue, key: &str) -> LuaResult<bool> {
        snapshot_value(snapshot, key)?.as_bool().ok_or_else(|| {
            LuaError::RuntimeError(format!("progression snapshot '{key}' must be a boolean"))
        })
    }

    fn snapshot_u64(snapshot: &JsonValue, key: &str) -> LuaResult<u64> {
        snapshot_value(snapshot, key)?.as_u64().ok_or_else(|| {
            LuaError::RuntimeError(format!("progression snapshot '{key}' must be an integer"))
        })
    }

    fn snapshot_i64(snapshot: &JsonValue, key: &str) -> LuaResult<i64> {
        snapshot_value(snapshot, key)?.as_i64().ok_or_else(|| {
            LuaError::RuntimeError(format!("progression snapshot '{key}' must be an integer"))
        })
    }

    fn progression_object_error(method: &str, err: impl std::fmt::Display) -> LuaError {
        LuaError::RuntimeError(format!("lurek.progression.{method}: {err}"))
    }

    fn snapshot_field_to_lua<'lua>(
        lua: &'lua Lua,
        snapshot: &JsonValue,
        key: &'static str,
    ) -> LuaResult<LuaValue<'lua>> {
        json_to_lua(lua, snapshot_value(snapshot, key)?)
    }

    trait SnapshotUserData {
        fn snapshot(&self) -> &JsonValue;
    }

    fn add_snapshot_field<'lua, T, F>(fields: &mut F, key: &'static str)
    where
        T: SnapshotUserData + 'static,
        F: UserDataFields<'lua, T>,
    {
        fields.add_field_method_get(key, move |lua, this| {
            snapshot_field_to_lua(lua, this.snapshot(), key)
        });
    }

    macro_rules! add_snapshot_fields {
    ($fields:ident, $type_name:ty, [$($key:literal),+ $(,)?]) => {
        $(
            add_snapshot_field::<$type_name, _>($fields, $key);
        )+
    };
}

    macro_rules! add_common_snapshot_methods {
        ($methods:ident, $type_name:literal) => {
            /// Returns the immutable snapshot data as a plain Lua table.
            /// @return | table | Snapshot table for this progression object.
            $methods.add_method("snapshot", |lua, this, ()| json_to_lua(lua, &this.snapshot));
            /// Returns the runtime userdata type name.
            /// @return | string | Canonical Lua userdata type name.
            $methods.add_method("type", |_, _, ()| Ok($type_name));
            /// Returns whether this userdata matches `name` or the shared base object type.
            /// @param | name | string | Candidate type name to compare against.
            /// @return | boolean | `true` when `name` matches this userdata type or `LObject`.
            $methods.add_method("typeOf", |_, _, name: String| {
                Ok(name == $type_name || name == "LObject")
            });
        };
    }

    macro_rules! define_snapshot_type {
        ($name:ident, $type_name:literal) => {
            #[derive(Clone)]
            /// Lua-side immutable progression snapshot userdata wrapper.
            pub(crate) struct $name {
                snapshot: JsonValue,
            }

            impl $name {
                /// Builds one immutable userdata wrapper around a progression snapshot object.
                pub(crate) fn new(snapshot: JsonValue) -> Self {
                    Self { snapshot }
                }
            }

            impl SnapshotUserData for $name {
                fn snapshot(&self) -> &JsonValue {
                    &self.snapshot
                }
            }
        };
    }

    define_snapshot_type!(LuaAchievement, "LAchievement");
    define_snapshot_type!(LuaChallenge, "LChallenge");
    define_snapshot_type!(LuaCollection, "LCollection");
    define_snapshot_type!(LuaLeaderboardEntry, "LLeaderboardEntry");
    define_snapshot_type!(LuaPopulation, "LPopulation");
    define_snapshot_type!(LuaPopulationProfile, "LPopulationProfile");
    define_snapshot_type!(LuaPrestige, "LPrestige");
    define_snapshot_type!(LuaActivityFeed, "LActivityFeed");
    define_snapshot_type!(LuaQuestJournalEntry, "LQuestJournalEntry");
    define_snapshot_type!(LuaRival, "LRival");
    define_snapshot_type!(LuaRivalDelta, "LRivalDelta");
    define_snapshot_type!(LuaSeason, "LSeason");
    define_snapshot_type!(LuaSeasonArchive, "LSeasonArchive");
    define_snapshot_type!(LuaActivityFeedEntry, "LActivityFeedEntry");

    #[derive(Clone)]
    /// Lua-side immutable progression quest state wrapper with optional live store context.
    pub(crate) struct LuaQuestState {
        snapshot: JsonValue,
        store: Option<Rc<RefCell<ProgressionStore>>>,
        profile_id: Option<String>,
    }

    impl LuaQuestState {
        /// Builds one quest-state userdata wrapper with optional live mutation context.
        pub(crate) fn new(
            snapshot: JsonValue,
            store: Option<Rc<RefCell<ProgressionStore>>>,
            profile_id: Option<String>,
        ) -> Self {
            Self {
                snapshot,
                store,
                profile_id,
            }
        }
    }

    impl SnapshotUserData for LuaQuestState {
        fn snapshot(&self) -> &JsonValue {
            &self.snapshot
        }
    }

    #[derive(Clone)]
    /// Lua-side immutable reward wrapper with optional live store context for state transitions.
    pub(crate) struct LuaReward {
        snapshot: JsonValue,
        store: Option<Rc<RefCell<ProgressionStore>>>,
        profile_id: Option<String>,
    }

    impl LuaReward {
        /// Builds one reward userdata wrapper with optional live mutation context.
        pub(crate) fn new(
            snapshot: JsonValue,
            store: Option<Rc<RefCell<ProgressionStore>>>,
            profile_id: Option<String>,
        ) -> Self {
            Self {
                snapshot,
                store,
                profile_id,
            }
        }
    }

    impl SnapshotUserData for LuaReward {
        fn snapshot(&self) -> &JsonValue {
            &self.snapshot
        }
    }

    #[derive(Clone)]
    /// Lua-side quest journal wrapper that owns retained entries and optional live mutation context.
    pub(crate) struct LuaQuestJournal {
        snapshot: JsonValue,
        store: Option<Rc<RefCell<ProgressionStore>>>,
        profile_id: Option<String>,
    }

    impl LuaQuestJournal {
        /// Builds one quest journal wrapper around a quest id plus retained entry list.
        pub(crate) fn new(
            snapshot: JsonValue,
            store: Option<Rc<RefCell<ProgressionStore>>>,
            profile_id: Option<String>,
        ) -> Self {
            Self {
                snapshot,
                store,
                profile_id,
            }
        }
    }

    impl SnapshotUserData for LuaQuestJournal {
        fn snapshot(&self) -> &JsonValue {
            &self.snapshot
        }
    }

    /// Returns one immutable `LAchievement` snapshot wrapper.
    pub(crate) fn achievement(snapshot: JsonValue) -> LuaAchievement {
        LuaAchievement::new(snapshot)
    }

    /// Returns one immutable `LChallenge` snapshot wrapper.
    pub(crate) fn challenge(snapshot: JsonValue) -> LuaChallenge {
        LuaChallenge::new(snapshot)
    }

    /// Returns one immutable `LCollection` snapshot wrapper.
    pub(crate) fn collection(snapshot: JsonValue) -> LuaCollection {
        LuaCollection::new(snapshot)
    }

    /// Returns one immutable `LLeaderboardEntry` snapshot wrapper.
    pub(crate) fn leaderboard_entry(snapshot: JsonValue) -> LuaLeaderboardEntry {
        LuaLeaderboardEntry::new(snapshot)
    }

    /// Returns one immutable `LPopulation` snapshot wrapper.
    pub(crate) fn population(snapshot: JsonValue) -> LuaPopulation {
        LuaPopulation::new(snapshot)
    }

    /// Returns one immutable `LPopulationProfile` snapshot wrapper.
    pub(crate) fn population_profile(snapshot: JsonValue) -> LuaPopulationProfile {
        LuaPopulationProfile::new(snapshot)
    }

    /// Returns one immutable `LPrestige` snapshot wrapper.
    pub(crate) fn prestige(snapshot: JsonValue) -> LuaPrestige {
        LuaPrestige::new(snapshot)
    }

    /// Returns one immutable `LActivityFeed` snapshot wrapper.
    pub(crate) fn activity_feed(
        entries: JsonValue,
        profiles: Option<Vec<String>>,
        types: Option<Vec<String>>,
        limit: Option<usize>,
    ) -> LuaActivityFeed {
        LuaActivityFeed::new(JsonValue::Object(
            [
                ("entries".to_string(), entries),
                (
                    "profiles".to_string(),
                    JsonValue::Array(
                        profiles
                            .unwrap_or_default()
                            .into_iter()
                            .map(JsonValue::String)
                            .collect(),
                    ),
                ),
                (
                    "types".to_string(),
                    JsonValue::Array(
                        types
                            .unwrap_or_default()
                            .into_iter()
                            .map(JsonValue::String)
                            .collect(),
                    ),
                ),
                (
                    "limit".to_string(),
                    limit
                        .map(|value| JsonValue::Number(value.into()))
                        .unwrap_or(JsonValue::Null),
                ),
            ]
            .into_iter()
            .collect(),
        ))
    }

    /// Returns one context-bound `LQuestState` snapshot wrapper.
    pub(crate) fn quest_state_bound(
        snapshot: JsonValue,
        store: Rc<RefCell<ProgressionStore>>,
        profile_id: String,
    ) -> LuaQuestState {
        LuaQuestState::new(snapshot, Some(store), Some(profile_id))
    }

    /// Returns one immutable `LQuestJournalEntry` snapshot wrapper.
    pub(crate) fn quest_journal_entry(snapshot: JsonValue) -> LuaQuestJournalEntry {
        LuaQuestJournalEntry::new(snapshot)
    }

    /// Returns one context-bound `LQuestJournal` wrapper.
    pub(crate) fn quest_journal_bound(
        quest_id: String,
        entries: JsonValue,
        store: Rc<RefCell<ProgressionStore>>,
        profile_id: String,
    ) -> LuaQuestJournal {
        LuaQuestJournal::new(
            JsonValue::Object(
                [
                    ("quest_id".to_string(), JsonValue::String(quest_id)),
                    ("entries".to_string(), entries),
                ]
                .into_iter()
                .collect(),
            ),
            Some(store),
            Some(profile_id),
        )
    }

    /// Returns one context-bound `LReward` snapshot wrapper.
    pub(crate) fn reward_bound(
        snapshot: JsonValue,
        store: Rc<RefCell<ProgressionStore>>,
        profile_id: String,
    ) -> LuaReward {
        LuaReward::new(snapshot, Some(store), Some(profile_id))
    }

    /// Returns one immutable `LRival` snapshot wrapper.
    pub(crate) fn rival(snapshot: JsonValue) -> LuaRival {
        LuaRival::new(snapshot)
    }

    /// Returns one immutable `LRivalDelta` snapshot wrapper.
    pub(crate) fn rival_delta(snapshot: JsonValue) -> LuaRivalDelta {
        LuaRivalDelta::new(snapshot)
    }

    /// Returns one immutable `LSeason` snapshot wrapper.
    pub(crate) fn season(snapshot: JsonValue) -> LuaSeason {
        LuaSeason::new(snapshot)
    }

    /// Returns one immutable `LSeasonArchive` snapshot wrapper.
    pub(crate) fn season_archive(snapshot: JsonValue) -> LuaSeasonArchive {
        LuaSeasonArchive::new(snapshot)
    }

    /// Returns one immutable `LActivityFeedEntry` snapshot wrapper.
    pub(crate) fn activity_feed_entry(snapshot: JsonValue) -> LuaActivityFeedEntry {
        LuaActivityFeedEntry::new(snapshot)
    }

    /// Creates a Lua array of userdata wrappers for a progression snapshot list.
    pub(crate) fn userdata_list<'lua, T>(
        lua: &'lua Lua,
        values: Vec<T>,
    ) -> LuaResult<LuaValue<'lua>>
    where
        T: UserData + 'static,
    {
        let table = lua.create_table()?;
        for (index, value) in values.into_iter().enumerate() {
            table.set(index + 1, lua.create_userdata(value)?)?;
        }
        Ok(LuaValue::Table(table))
    }

    impl UserData for LuaAchievement {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "id",
                    "title",
                    "description",
                    "hidden",
                    "repeatable",
                    "unlock_count",
                    "unlocked",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the authored achievement id.
            /// @return | string | Stable achievement identifier.
            methods.add_method("getId", |_, this, ()| snapshot_string(&this.snapshot, "id"));
            /// Returns the authored achievement title.
            /// @return | string | Local presentation title.
            methods.add_method("getTitle", |_, this, ()| {
                snapshot_string(&this.snapshot, "title")
            });
            /// Returns whether the achievement is currently unlocked for the owning profile.
            /// @return | boolean | `true` when the achievement was unlocked.
            methods.add_method("isUnlocked", |_, this, ()| {
                snapshot_bool(&this.snapshot, "unlocked")
            });
            add_common_snapshot_methods!(methods, "LAchievement");
        }
    }

    impl UserData for LuaChallenge {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "id",
                    "profile_id",
                    "title",
                    "description",
                    "status",
                    "current",
                    "required",
                    "completion",
                    "counter_id",
                    "duration",
                    "repeatable",
                    "max_completions",
                    "completion_count",
                    "started_at",
                    "ends_at",
                    "expires_in",
                    "last_completed_at",
                    "tags",
                    "reward_payload",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the authored challenge id.
            /// @return | string | Stable challenge identifier.
            methods.add_method("getId", |_, this, ()| snapshot_string(&this.snapshot, "id"));
            /// Returns the current challenge lifecycle status.
            /// @return | string | One of `"inactive"`, `"active"`, `"completed"`, or `"expired"`.
            methods.add_method("getStatus", |_, this, ()| {
                snapshot_string(&this.snapshot, "status")
            });
            add_common_snapshot_methods!(methods, "LChallenge");
        }
    }

    impl UserData for LuaCollection {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "id",
                    "title",
                    "description",
                    "meta_achievement_id",
                    "items",
                    "collected_count",
                    "total_count",
                    "completion",
                    "complete",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the authored collection id.
            /// @return | string | Stable collection identifier.
            methods.add_method("getId", |_, this, ()| snapshot_string(&this.snapshot, "id"));
            /// Returns whether every collection item is currently collected.
            /// @return | boolean | `true` when the collection is complete.
            methods.add_method("isComplete", |_, this, ()| {
                snapshot_bool(&this.snapshot, "complete")
            });
            add_common_snapshot_methods!(methods, "LCollection");
        }
    }

    impl UserData for LuaLeaderboardEntry {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "leaderboard_id",
                    "profile_id",
                    "score",
                    "rank",
                    "percentile",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the leaderboard that produced this row.
            /// @return | string | Leaderboard identifier.
            methods.add_method("getLeaderboardId", |_, this, ()| {
                snapshot_string(&this.snapshot, "leaderboard_id")
            });
            /// Returns the profile that owns this row.
            /// @return | string | Profile identifier.
            methods.add_method("getProfileId", |_, this, ()| {
                snapshot_string(&this.snapshot, "profile_id")
            });
            /// Returns the one-based rank currently assigned to this row.
            /// @return | integer | Deterministic rank for the current ordering.
            methods.add_method("getRank", |_, this, ()| {
                Ok(snapshot_u64(&this.snapshot, "rank")? as i64)
            });
            add_common_snapshot_methods!(methods, "LLeaderboardEntry");
        }
    }

    impl UserData for LuaPopulation {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "id",
                    "template_id",
                    "logical_time",
                    "paused",
                    "generated_count",
                    "active_count",
                    "materialized_count",
                    "profiles",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the population id.
            /// @return | string | Population identifier.
            methods.add_method("getId", |_, this, ()| snapshot_string(&this.snapshot, "id"));
            /// Returns whether logical simulation for this population is paused.
            /// @return | boolean | `true` when updates are paused.
            methods.add_method("isPaused", |_, this, ()| {
                snapshot_bool(&this.snapshot, "paused")
            });
            add_common_snapshot_methods!(methods, "LPopulation");
        }
    }

    impl UserData for LuaPopulationProfile {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "population_id",
                    "template_id",
                    "profile_id",
                    "display_name",
                    "avatar",
                    "tags",
                    "archetype_id",
                    "base_skill",
                    "active",
                    "materialized",
                    "leaderboard_scores",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the virtual profile id.
            /// @return | string | Virtual profile identifier.
            methods.add_method("getProfileId", |_, this, ()| {
                snapshot_string(&this.snapshot, "profile_id")
            });
            /// Returns whether this virtual profile is materialized as a normal store profile.
            /// @return | boolean | `true` when the virtual profile was materialized.
            methods.add_method("isMaterialized", |_, this, ()| {
                snapshot_bool(&this.snapshot, "materialized")
            });
            add_common_snapshot_methods!(methods, "LPopulationProfile");
        }
    }

    impl UserData for LuaPrestige {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "id",
                    "available",
                    "count",
                    "last_applied_at",
                    "last_applied_revision",
                    "lifetime_counters",
                    "reset",
                    "preserve",
                    "condition",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the authored prestige id.
            /// @return | string | Prestige identifier.
            methods.add_method("getId", |_, this, ()| snapshot_string(&this.snapshot, "id"));
            /// Returns whether the owning profile currently satisfies the prestige condition.
            /// @return | boolean | `true` when the prestige is currently available.
            methods.add_method("isAvailable", |_, this, ()| {
                snapshot_bool(&this.snapshot, "available")
            });
            add_common_snapshot_methods!(methods, "LPrestige");
        }
    }

    impl UserData for LuaActivityFeed {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(fields, Self, ["entries", "profiles", "types", "limit"]);
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the number of retained activity-feed entries in this selection.
            /// @return | integer | Number of feed entries currently stored in this feed snapshot.
            methods.add_method("count", |_, this, ()| {
                Ok(snapshot_value(&this.snapshot, "entries")?
                    .as_array()
                    .map(|entries| entries.len() as i64)
                    .unwrap_or(0))
            });
            /// Returns every retained activity-feed entry as typed userdata.
            /// @return | table | Array of `LActivityFeedEntry` userdata values.
            methods.add_method("listEntries", |lua, this, ()| {
                let entries = snapshot_value(&this.snapshot, "entries")?
                    .as_array()
                    .cloned()
                    .unwrap_or_default();
                userdata_list(lua, entries.into_iter().map(activity_feed_entry).collect())
            });
            add_common_snapshot_methods!(methods, "LActivityFeed");
        }
    }

    impl UserData for LuaQuestState {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "quest_id",
                    "status",
                    "current_stage_index",
                    "completion_count",
                    "revealed",
                    "available",
                    "revealed_override",
                    "journal",
                    "objectives",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the authored quest id.
            /// @return | string | Quest identifier.
            methods.add_method("getQuestId", |_, this, ()| {
                snapshot_string(&this.snapshot, "quest_id")
            });
            /// Returns the current quest lifecycle status.
            /// @return | string | Current quest state such as `"hidden"`, `"available"`, or `"active"`.
            methods.add_method("getStatus", |_, this, ()| {
                snapshot_string(&this.snapshot, "status")
            });
            /// Returns whether the quest is currently revealed to the owning profile.
            /// @return | boolean | `true` when the quest is visible.
            methods.add_method("isRevealed", |_, this, ()| {
                snapshot_bool(&this.snapshot, "revealed")
            });
            /// Returns the retained quest journal as a typed journal object.
            /// @return | LQuestJournal | Journal handle for the current quest state.
            methods.add_method("getJournal", |lua, this, ()| {
                let store = this.store.clone().ok_or_else(|| {
                    progression_object_error(
                        "LQuestState.getJournal",
                        "quest journal context is not available",
                    )
                })?;
                let profile_id = this.profile_id.clone().ok_or_else(|| {
                    progression_object_error(
                        "LQuestState.getJournal",
                        "quest profile context is not available",
                    )
                })?;
                let quest_id = snapshot_string(&this.snapshot, "quest_id")?;
                let entries = snapshot_value(&this.snapshot, "journal")?.clone();
                lua.create_userdata(quest_journal_bound(quest_id, entries, store, profile_id))
            });
            add_common_snapshot_methods!(methods, "LQuestState");
        }
    }

    impl UserData for LuaReward {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "id",
                    "source_kind",
                    "source_id",
                    "payload",
                    "state",
                    "external_receipt",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the reward record id.
            /// @return | string | Stable reward identifier.
            methods.add_method("getId", |_, this, ()| snapshot_string(&this.snapshot, "id"));
            /// Returns the current reward state.
            /// @return | string | One of `"pending"`, `"claimed"`, `"applied"`, or `"rejected"`.
            methods.add_method("getState", |_, this, ()| {
                snapshot_string(&this.snapshot, "state")
            });
            /// Claims this pending reward and returns the updated reward object.
            /// @return | LReward | Updated reward handle after the claim transition.
            methods.add_method_mut("claim", |lua, this, ()| {
                let store = this.store.clone().ok_or_else(|| {
                    progression_object_error("LReward.claim", "reward context is not available")
                })?;
                let profile_id = this.profile_id.clone().ok_or_else(|| {
                    progression_object_error(
                        "LReward.claim",
                        "reward profile context is not available",
                    )
                })?;
                let reward_id = snapshot_string(&this.snapshot, "id")?;
                let updated = serde_json::to_value(
                    store
                        .borrow_mut()
                        .claim_reward(&profile_id, &reward_id)
                        .map_err(|err| progression_object_error("LReward.claim", err))?,
                )
                .map_err(|err| {
                    progression_object_error(
                        "LReward.claim",
                        format!("reward serialization failed: {err}"),
                    )
                })?;
                lua.create_userdata(reward_bound(updated, store, profile_id))
            });
            /// Marks this claimed reward as applied and returns the updated reward object.
            /// @param | external_receipt | string? | Optional game-specific receipt or transaction token.
            /// @return | LReward | Updated reward handle after the apply transition.
            methods.add_method_mut(
                "markApplied",
                |lua, this, external_receipt: Option<String>| {
                    let store = this.store.clone().ok_or_else(|| {
                        progression_object_error(
                            "LReward.markApplied",
                            "reward context is not available",
                        )
                    })?;
                    let profile_id = this.profile_id.clone().ok_or_else(|| {
                        progression_object_error(
                            "LReward.markApplied",
                            "reward profile context is not available",
                        )
                    })?;
                    let reward_id = snapshot_string(&this.snapshot, "id")?;
                    let updated = serde_json::to_value(
                        store
                            .borrow_mut()
                            .mark_reward_applied(&profile_id, &reward_id, external_receipt)
                            .map_err(|err| progression_object_error("LReward.markApplied", err))?,
                    )
                    .map_err(|err| {
                        progression_object_error(
                            "LReward.markApplied",
                            format!("reward serialization failed: {err}"),
                        )
                    })?;
                    lua.create_userdata(reward_bound(updated, store, profile_id))
                },
            );
            /// Rejects this reward and returns the updated reward object.
            /// @param | reason | string? | Optional rejection reason for logs or external flow control.
            /// @return | LReward | Updated reward handle after the rejection transition.
            methods.add_method_mut("reject", |lua, this, reason: Option<String>| {
                let store = this.store.clone().ok_or_else(|| {
                    progression_object_error("LReward.reject", "reward context is not available")
                })?;
                let profile_id = this.profile_id.clone().ok_or_else(|| {
                    progression_object_error(
                        "LReward.reject",
                        "reward profile context is not available",
                    )
                })?;
                let reward_id = snapshot_string(&this.snapshot, "id")?;
                let updated = serde_json::to_value(
                    store
                        .borrow_mut()
                        .reject_reward(&profile_id, &reward_id, reason)
                        .map_err(|err| progression_object_error("LReward.reject", err))?,
                )
                .map_err(|err| {
                    progression_object_error(
                        "LReward.reject",
                        format!("reward serialization failed: {err}"),
                    )
                })?;
                lua.create_userdata(reward_bound(updated, store, profile_id))
            });
            add_common_snapshot_methods!(methods, "LReward");
        }
    }

    impl UserData for LuaQuestJournalEntry {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(fields, Self, ["index", "text", "tag"]);
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the stable monotonically increasing journal index.
            /// @return | integer | Zero-based journal entry index.
            methods.add_method("getIndex", |_, this, ()| {
                Ok(snapshot_u64(&this.snapshot, "index")? as i64)
            });
            /// Returns the authored journal entry text.
            /// @return | string | Retained journal body text.
            methods.add_method("getText", |_, this, ()| {
                snapshot_string(&this.snapshot, "text")
            });
            /// Returns the optional journal entry tag.
            /// @return | string | Journal entry tag, or an empty string when no tag was stored.
            methods.add_method("getTag", |_, this, ()| {
                snapshot_string(&this.snapshot, "tag")
            });
            add_common_snapshot_methods!(methods, "LQuestJournalEntry");
        }
    }

    impl UserData for LuaQuestJournal {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(fields, Self, ["quest_id", "entries"]);
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the quest id that owns this journal.
            /// @return | string | Authored quest identifier.
            methods.add_method("getQuestId", |_, this, ()| {
                snapshot_string(&this.snapshot, "quest_id")
            });
            /// Returns the number of retained entries currently stored in this journal.
            /// @return | integer | Journal entry count after retention trimming.
            methods.add_method("count", |_, this, ()| {
                Ok(snapshot_value(&this.snapshot, "entries")?
                    .as_array()
                    .map(|entries| entries.len() as i64)
                    .unwrap_or(0))
            });
            /// Returns every retained journal entry as typed entry userdata.
            /// @return | table | Array of `LQuestJournalEntry` userdata values.
            methods.add_method("listEntries", |lua, this, ()| {
                let entries = snapshot_value(&this.snapshot, "entries")?
                    .as_array()
                    .cloned()
                    .unwrap_or_default();
                userdata_list(lua, entries.into_iter().map(quest_journal_entry).collect())
            });
            /// Appends one entry to the live quest journal and returns the stored entry object.
            /// @param | text | string | Non-empty journal body text to append.
            /// @param | tag | string? | Optional tag that categorizes the new journal entry.
            /// @return | LQuestJournalEntry | Retained journal entry after store-side indexing and trimming.
            methods.add_method_mut(
                "addEntry",
                |lua, this, (text, tag): (String, Option<String>)| {
                    let store = this.store.clone().ok_or_else(|| {
                        progression_object_error(
                            "LQuestJournal.addEntry",
                            "quest journal context is not available",
                        )
                    })?;
                    let profile_id = this.profile_id.clone().ok_or_else(|| {
                        progression_object_error(
                            "LQuestJournal.addEntry",
                            "quest profile context is not available",
                        )
                    })?;
                    let quest_id = snapshot_string(&this.snapshot, "quest_id")?;
                    let entry = serde_json::to_value(
                        store
                            .borrow_mut()
                            .add_quest_journal_entry(&profile_id, &quest_id, &text, tag)
                            .map_err(|err| {
                                progression_object_error("LQuestJournal.addEntry", err)
                            })?,
                    )
                    .map_err(|err| {
                        progression_object_error(
                            "LQuestJournal.addEntry",
                            format!("journal serialization failed: {err}"),
                        )
                    })?;
                    let entries = serde_json::to_value(
                        store
                            .borrow()
                            .list_quest_journal_entries(&profile_id, &quest_id)
                            .map_err(|err| {
                                progression_object_error("LQuestJournal.addEntry", err)
                            })?,
                    )
                    .map_err(|err| {
                        progression_object_error(
                            "LQuestJournal.addEntry",
                            format!("journal serialization failed: {err}"),
                        )
                    })?;
                    this.snapshot = JsonValue::Object(
                        [
                            ("quest_id".to_string(), JsonValue::String(quest_id)),
                            ("entries".to_string(), entries),
                        ]
                        .into_iter()
                        .collect(),
                    );
                    lua.create_userdata(quest_journal_entry(entry))
                },
            );
            add_common_snapshot_methods!(methods, "LQuestJournal");
        }
    }

    impl UserData for LuaRival {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                ["profile_id", "rival_profile_id", "leaderboard_id", "delta"]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the owner profile id for this rivalry.
            /// @return | string | Profile identifier that pinned the rival.
            methods.add_method("getProfileId", |_, this, ()| {
                snapshot_string(&this.snapshot, "profile_id")
            });
            /// Returns the pinned rival profile id.
            /// @return | string | Rival profile identifier.
            methods.add_method("getRivalProfileId", |_, this, ()| {
                snapshot_string(&this.snapshot, "rival_profile_id")
            });
            add_common_snapshot_methods!(methods, "LRival");
        }
    }

    impl UserData for LuaRivalDelta {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "leaderboard_id",
                    "profile_rank",
                    "rival_rank",
                    "rank_delta",
                    "profile_score",
                    "rival_score",
                    "score_delta",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the leaderboard used to compute this rivalry delta.
            /// @return | string | Leaderboard identifier.
            methods.add_method("getLeaderboardId", |_, this, ()| {
                snapshot_string(&this.snapshot, "leaderboard_id")
            });
            /// Returns the signed rank gap between the owner and rival profiles.
            /// @return | integer | Positive when the rival is behind, negative when ahead.
            methods.add_method("getRankDelta", |_, this, ()| {
                snapshot_i64(&this.snapshot, "rank_delta")
            });
            add_common_snapshot_methods!(methods, "LRivalDelta");
        }
    }

    impl UserData for LuaSeason {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "id",
                    "starts_at",
                    "ends_at",
                    "reset",
                    "archive",
                    "active",
                    "started_at",
                    "ended_at",
                    "archive_count",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the authored season id.
            /// @return | string | Season identifier.
            methods.add_method("getId", |_, this, ()| snapshot_string(&this.snapshot, "id"));
            /// Returns whether this season is currently active.
            /// @return | boolean | `true` when the season is active.
            methods.add_method("isActive", |_, this, ()| {
                snapshot_bool(&this.snapshot, "active")
            });
            add_common_snapshot_methods!(methods, "LSeason");
        }
    }

    impl UserData for LuaSeasonArchive {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "id",
                    "archive_index",
                    "started_at",
                    "ended_at",
                    "revision",
                    "snapshot",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the season id that owns this archive record.
            /// @return | string | Season identifier.
            methods.add_method("getId", |_, this, ()| snapshot_string(&this.snapshot, "id"));
            /// Returns the monotonically increasing archive index for this season.
            /// @return | integer | Archive sequence number.
            methods.add_method("getArchiveIndex", |_, this, ()| {
                Ok(snapshot_u64(&this.snapshot, "archive_index")? as i64)
            });
            add_common_snapshot_methods!(methods, "LSeasonArchive");
        }
    }

    impl UserData for LuaActivityFeedEntry {
        fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
            add_snapshot_fields!(
                fields,
                Self,
                [
                    "sequence",
                    "revision",
                    "event_type",
                    "profile_id",
                    "definition_id",
                    "payload",
                ]
            );
        }

        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            /// Returns the retained event sequence number.
            /// @return | integer | Event sequence in feed order.
            methods.add_method("getSequence", |_, this, ()| {
                Ok(snapshot_u64(&this.snapshot, "sequence")? as i64)
            });
            /// Returns the canonical activity event type name.
            /// @return | string | Event type such as `"achievement_unlocked"`.
            methods.add_method("getEventType", |_, this, ()| {
                snapshot_string(&this.snapshot, "event_type")
            });
            add_common_snapshot_methods!(methods, "LActivityFeedEntry");
        }
    }
}
