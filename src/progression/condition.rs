//! Owns authored condition trees, validation rules, evaluation helpers, and explanation payload generation.
//! Exposes canonical helpers that compile, validate, evaluate, and explain progression predicates.
//! Applies depth, fan-out, identifier, and reference checks before conditions run against store state.
//! Resolves counter, level, achievement, quest, and tag predicates against canonical profile-owned data.
//! Provides crate-local recursive helpers reused by quests, achievements, and prestige definitions.
//! Keeps reusable predicate semantics out of store-wide plumbing so conditional logic stays cohesive.
//! Open this file when changing predicate validation, evaluation semantics, or explanation structure.
use super::*;

impl ProgressionStore {
    /// Normalize a condition definition into a stable serialized shape.
    pub fn compile_condition(
        &self,
        condition: &ProgressionCondition,
    ) -> Result<JsonValue, ProgressionError> {
        self.validate_condition_inner(condition, 0, &mut Vec::new())?;
        serde_json::to_value(condition)
            .map_err(|err| ProgressionError::InvalidValue(format!("condition: {err}")))
    }

    /// Validate one condition definition against store limits and authored references.
    pub fn validate_condition(&self, condition: &ProgressionCondition) -> JsonValue {
        let mut errors = Vec::new();
        let ok = self
            .validate_condition_inner(condition, 0, &mut errors)
            .map(|_| true)
            .unwrap_or(false);
        json!({
            "ok": ok && errors.is_empty(),
            "errors": errors,
        })
    }

    /// Evaluate one condition against a profile.
    pub fn evaluate_condition(
        &self,
        profile_id: &str,
        condition: &ProgressionCondition,
    ) -> Result<bool, ProgressionError> {
        self.validate_condition_inner(condition, 0, &mut Vec::new())?;
        self.evaluate_condition_inner(profile_id, condition)
    }

    /// Explain one condition evaluation against a profile.
    pub fn explain_condition(
        &self,
        profile_id: &str,
        condition: &ProgressionCondition,
    ) -> Result<JsonValue, ProgressionError> {
        self.validate_condition_inner(condition, 0, &mut Vec::new())?;
        self.explain_condition_inner(profile_id, condition)
    }

    /// Validate one condition subtree recursively while collecting stable human-readable errors.
    pub(crate) fn validate_condition_inner(
        &self,
        condition: &ProgressionCondition,
        depth: usize,
        errors: &mut Vec<String>,
    ) -> Result<(), ProgressionError> {
        if depth > 16 {
            let message = "condition depth exceeds 16".to_string();
            errors.push(message.clone());
            return Err(ProgressionError::InvalidValue(message));
        }
        match condition {
            ProgressionCondition::All { conditions } | ProgressionCondition::Any { conditions } => {
                if conditions.is_empty() {
                    let message = "composite condition must not be empty".to_string();
                    errors.push(message.clone());
                    return Err(ProgressionError::InvalidValue(message));
                }
                if conditions.len() > 32 {
                    let message = "composite condition exceeds 32 children".to_string();
                    errors.push(message.clone());
                    return Err(ProgressionError::InvalidValue(message));
                }
                for child in conditions {
                    self.validate_condition_inner(child, depth + 1, errors)?;
                }
            }
            ProgressionCondition::Not { condition } => {
                self.validate_condition_inner(condition, depth + 1, errors)?;
            }
            ProgressionCondition::Counter {
                counter_id, value, ..
            } => {
                validate_id(counter_id)?;
                ensure_finite(*value, "condition counter value")?;
                if self.options.strict && !self.counter_definitions.contains_key(counter_id) {
                    let message = format!("missing counter definition '{}'", counter_id);
                    errors.push(message.clone());
                    return Err(ProgressionError::MissingDefinition {
                        kind: "counter",
                        id: counter_id.clone(),
                    });
                }
            }
            ProgressionCondition::Level {
                track_id, value, ..
            } => {
                validate_id(track_id)?;
                if self.options.strict && !self.level_track_definitions.contains_key(track_id) {
                    let message = format!("missing level track definition '{}'", track_id);
                    errors.push(message.clone());
                    return Err(ProgressionError::MissingDefinition {
                        kind: "level_track",
                        id: track_id.clone(),
                    });
                }
                let _ = value;
            }
            ProgressionCondition::Achievement {
                achievement_id,
                state,
            } => {
                validate_id(achievement_id)?;
                if self.options.strict && !self.achievement_definitions.contains_key(achievement_id)
                {
                    let message = format!("missing achievement definition '{}'", achievement_id);
                    errors.push(message.clone());
                    return Err(ProgressionError::MissingDefinition {
                        kind: "achievement",
                        id: achievement_id.clone(),
                    });
                }
                if state != "unlocked" && state != "locked" {
                    let message = format!("unsupported achievement condition state '{}'", state);
                    errors.push(message.clone());
                    return Err(ProgressionError::InvalidValue(message));
                }
            }
            ProgressionCondition::Quest { quest_id, state } => {
                validate_id(quest_id)?;
                if self.options.strict && !self.quest_definitions.contains_key(quest_id) {
                    let message = format!("missing quest definition '{}'", quest_id);
                    errors.push(message.clone());
                    return Err(ProgressionError::MissingDefinition {
                        kind: "quest",
                        id: quest_id.clone(),
                    });
                }
                if !matches!(
                    state.as_str(),
                    "hidden" | "revealed" | "available" | "active" | "completed" | "failed"
                ) {
                    let message = format!("unsupported quest condition state '{}'", state);
                    errors.push(message.clone());
                    return Err(ProgressionError::InvalidValue(message));
                }
            }
            ProgressionCondition::Tag { tag } => {
                if tag.is_empty() || tag.len() > 64 {
                    let message = "condition tag must be 1..64 characters".to_string();
                    errors.push(message.clone());
                    return Err(ProgressionError::InvalidValue(message));
                }
            }
        }
        Ok(())
    }

    /// Evaluate one validated condition subtree recursively against the canonical profile state.
    pub(crate) fn evaluate_condition_inner(
        &self,
        profile_id: &str,
        condition: &ProgressionCondition,
    ) -> Result<bool, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        match condition {
            ProgressionCondition::All { conditions } => conditions
                .iter()
                .map(|child| self.evaluate_condition_inner(profile_id, child))
                .try_fold(true, |acc, value| value.map(|ok| acc && ok)),
            ProgressionCondition::Any { conditions } => {
                for child in conditions {
                    if self.evaluate_condition_inner(profile_id, child)? {
                        return Ok(true);
                    }
                }
                Ok(false)
            }
            ProgressionCondition::Not { condition } => {
                Ok(!self.evaluate_condition_inner(profile_id, condition)?)
            }
            ProgressionCondition::Counter {
                counter_id,
                op,
                value,
            } => Ok(compare_f64(
                self.get_counter(profile_id, counter_id)?,
                *op,
                *value,
            )),
            ProgressionCondition::Level {
                track_id,
                op,
                value,
            } => Ok(compare_f64(
                self.get_level(profile_id, track_id)? as f64,
                *op,
                *value as f64,
            )),
            ProgressionCondition::Achievement {
                achievement_id,
                state,
            } => {
                let unlocked = profile
                    .achievements
                    .get(achievement_id)
                    .map(|entry| entry.unlocked)
                    .unwrap_or(false);
                Ok(match state.as_str() {
                    "unlocked" => unlocked,
                    "locked" => !unlocked,
                    _ => false,
                })
            }
            ProgressionCondition::Quest { quest_id, state } => {
                let actual = profile
                    .quests
                    .get(quest_id)
                    .map(|quest| quest.status.as_str())
                    .unwrap_or("available");
                Ok(actual == state)
            }
            ProgressionCondition::Tag { tag } => Ok(profile.tags.contains(tag)),
        }
    }

    /// Build one recursive explanation payload that mirrors the evaluated condition subtree.
    pub(crate) fn explain_condition_inner(
        &self,
        profile_id: &str,
        condition: &ProgressionCondition,
    ) -> Result<JsonValue, ProgressionError> {
        match condition {
            ProgressionCondition::All { conditions } => {
                let children = conditions
                    .iter()
                    .map(|child| self.explain_condition_inner(profile_id, child))
                    .collect::<Result<Vec<_>, _>>()?;
                let ok = children.iter().all(|child| {
                    child
                        .get("ok")
                        .and_then(JsonValue::as_bool)
                        .unwrap_or(false)
                });
                Ok(json!({
                    "kind": "all",
                    "ok": ok,
                    "children": children,
                }))
            }
            ProgressionCondition::Any { conditions } => {
                let children = conditions
                    .iter()
                    .map(|child| self.explain_condition_inner(profile_id, child))
                    .collect::<Result<Vec<_>, _>>()?;
                let ok = children.iter().any(|child| {
                    child
                        .get("ok")
                        .and_then(JsonValue::as_bool)
                        .unwrap_or(false)
                });
                Ok(json!({
                    "kind": "any",
                    "ok": ok,
                    "children": children,
                }))
            }
            ProgressionCondition::Not { condition } => {
                let child = self.explain_condition_inner(profile_id, condition)?;
                let child_ok = child
                    .get("ok")
                    .and_then(JsonValue::as_bool)
                    .unwrap_or(false);
                Ok(json!({
                    "kind": "not",
                    "ok": !child_ok,
                    "child": child,
                }))
            }
            ProgressionCondition::Counter {
                counter_id,
                op,
                value,
            } => {
                let observed = self.get_counter(profile_id, counter_id)?;
                let ok = compare_f64(observed, *op, *value);
                Ok(json!({
                    "kind": "counter",
                    "ok": ok,
                    "counter_id": counter_id,
                    "observed": observed,
                    "expected": value,
                    "op": format_comparison_op(*op),
                }))
            }
            ProgressionCondition::Level {
                track_id,
                op,
                value,
            } => {
                let observed = self.get_level(profile_id, track_id)?;
                let ok = compare_f64(observed as f64, *op, *value as f64);
                Ok(json!({
                    "kind": "level",
                    "ok": ok,
                    "track_id": track_id,
                    "observed": observed,
                    "expected": value,
                    "op": format_comparison_op(*op),
                }))
            }
            ProgressionCondition::Achievement {
                achievement_id,
                state,
            } => {
                let observed = self.evaluate_condition_inner(
                    profile_id,
                    &ProgressionCondition::Achievement {
                        achievement_id: achievement_id.clone(),
                        state: "unlocked".to_string(),
                    },
                )?;
                let ok = self.evaluate_condition_inner(profile_id, condition)?;
                Ok(json!({
                    "kind": "achievement",
                    "ok": ok,
                    "achievement_id": achievement_id,
                    "observed": if observed { "unlocked" } else { "locked" },
                    "expected": state,
                }))
            }
            ProgressionCondition::Quest { quest_id, state } => {
                let profile = self
                    .profiles
                    .get(profile_id)
                    .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
                let observed = profile
                    .quests
                    .get(quest_id)
                    .map(|quest| quest.status.clone())
                    .unwrap_or_else(|| "available".to_string());
                Ok(json!({
                    "kind": "quest",
                    "ok": observed == *state,
                    "quest_id": quest_id,
                    "observed": observed,
                    "expected": state,
                }))
            }
            ProgressionCondition::Tag { tag } => {
                let profile = self
                    .profiles
                    .get(profile_id)
                    .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
                let ok = profile.tags.contains(tag);
                Ok(json!({
                    "kind": "tag",
                    "ok": ok,
                    "tag": tag,
                }))
            }
        }
    }
}
