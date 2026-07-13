//! Owns authored collections, per-profile collection state, hidden item discovery, and completion snapshots.
//! Stores the rules that bind collection items to achievements and optional meta-achievement unlock behavior.
//! Exposes public store helpers for definition, manual collection, querying, and deterministic list serialization.
//! Validates collection definitions so item ids stay unique and referenced achievements exist before persistence.
//! Synchronizes collection completion whenever achievements change, including hidden unlock and meta-owner checks.
//! Integrates with rewards and achievements without adding renderer, inventory, or narrative-specific concerns.
//! Open this file when changing collection authoring, discovery rules, or achievement-linked completion logic.
use super::*;

impl ProgressionStore {
    /// Define one collection or achievement set.
    pub fn define_collection(
        &mut self,
        id: &str,
        definition: CollectionDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.validate_collection_definition(id, &definition)?;
        if let Some(previous) = self
            .collection_definitions
            .insert(id.to_string(), definition.clone())
        {
            for item in previous.items {
                if let Some(achievement_id) = item.achievement_id {
                    if let Some(entries) =
                        self.collection_achievement_index.get_mut(&achievement_id)
                    {
                        entries.retain(|(collection_id, item_id)| {
                            collection_id != id || item_id != &item.id
                        });
                        if entries.is_empty() {
                            self.collection_achievement_index.remove(&achievement_id);
                        }
                    }
                }
            }
        }
        for item in &definition.items {
            if let Some(achievement_id) = &item.achievement_id {
                let entries = self
                    .collection_achievement_index
                    .entry(achievement_id.clone())
                    .or_default();
                if !entries
                    .iter()
                    .any(|(collection_id, item_id)| collection_id == id && item_id == &item.id)
                {
                    entries.push((id.to_string(), item.id.clone()));
                    entries.sort();
                }
            }
        }
        Ok(())
    }

    /// Collect one manual collection item for a profile.
    pub fn collect_collection_item(
        &mut self,
        profile_id: &str,
        collection_id: &str,
        item_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        self.profile_mut(profile_id)?;
        let definition = self
            .collection_definitions
            .get(collection_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "collection",
                id: collection_id.to_string(),
            })?;
        let item = definition
            .items
            .iter()
            .find(|item| item.id == item_id)
            .cloned()
            .ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "collection '{}' does not define item '{}'",
                    collection_id, item_id
                ))
            })?;
        let changed =
            self.mark_collection_item_collected(profile_id, collection_id, &item, false)?;
        if changed {
            self.bump_revision();
            self.push_event(
                "collection_item_collected",
                Some(profile_id.to_string()),
                Some(collection_id.to_string()),
                json!({ "collectionId": collection_id, "itemId": item_id }),
            );
            self.check_collection_completion(profile_id, &definition)?;
        }
        self.get_collection(profile_id, collection_id)
    }

    /// Return one collection snapshot for a profile.
    pub fn get_collection(
        &self,
        profile_id: &str,
        collection_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        self.profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let definition = self
            .collection_definitions
            .get(collection_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "collection",
                id: collection_id.to_string(),
            })?;
        Ok(self.collection_json(profile_id, definition))
    }

    /// Return all authored collections for a profile in deterministic id order.
    pub fn list_collections(&self, profile_id: &str) -> Result<Vec<JsonValue>, ProgressionError> {
        self.profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        Ok(self
            .collection_definitions
            .values()
            .map(|definition| self.collection_json(profile_id, definition))
            .collect())
    }

    /// Validate that a collection only references authored achievements and unique item ids.
    pub(crate) fn validate_collection_definition(
        &self,
        id: &str,
        definition: &CollectionDefinition,
    ) -> Result<(), ProgressionError> {
        if definition.id != id {
            return Err(ProgressionError::InvalidValue(format!(
                "collection definition id '{}' must match '{}'",
                definition.id, id
            )));
        }
        let mut item_ids = BTreeSet::new();
        for CollectionItemDefinition {
            id: item_id,
            achievement_id,
            ..
        } in &definition.items
        {
            validate_id(item_id)?;
            if !item_ids.insert(item_id.clone()) {
                return Err(ProgressionError::InvalidValue(format!(
                    "collection '{}' contains duplicate item '{}'",
                    id, item_id
                )));
            }
            if let Some(achievement_id) = achievement_id {
                validate_id(achievement_id)?;
                if self.options.strict && !self.achievement_definitions.contains_key(achievement_id)
                {
                    return Err(ProgressionError::MissingDefinition {
                        kind: "achievement",
                        id: achievement_id.clone(),
                    });
                }
            }
        }
        if let Some(meta_achievement_id) = &definition.meta_achievement_id {
            validate_id(meta_achievement_id)?;
            if self.options.strict
                && !self
                    .achievement_definitions
                    .contains_key(meta_achievement_id)
            {
                return Err(ProgressionError::MissingDefinition {
                    kind: "achievement",
                    id: meta_achievement_id.clone(),
                });
            }
        }
        Ok(())
    }

    fn mark_collection_item_collected(
        &mut self,
        profile_id: &str,
        collection_id: &str,
        item: &CollectionItemDefinition,
        from_achievement: bool,
    ) -> Result<bool, ProgressionError> {
        let changed = {
            let profile = self.profile_mut(profile_id)?;
            let items = profile
                .collections
                .entry(collection_id.to_string())
                .or_default();
            let state = items.entry(item.id.clone()).or_insert(CollectionItemState {
                collected: false,
                discovered: !item.hidden,
            });
            let changed = !state.collected || !state.discovered;
            state.collected = true;
            state.discovered = true;
            changed
        };
        if changed {
            self.push_event(
                if from_achievement {
                    "collection_item_discovered_from_achievement"
                } else {
                    "collection_item_discovered"
                },
                Some(profile_id.to_string()),
                Some(collection_id.to_string()),
                json!({ "collectionId": collection_id, "itemId": item.id }),
            );
        }
        Ok(changed)
    }

    /// Refresh collection completion and meta-achievement unlocks after one achievement changes.
    pub(crate) fn sync_collections_for_achievement(
        &mut self,
        profile_id: &str,
        achievement_id: &str,
    ) -> Result<(), ProgressionError> {
        let Some(entries) = self
            .collection_achievement_index
            .get(achievement_id)
            .cloned()
        else {
            return Ok(());
        };
        for (collection_id, item_id) in entries {
            let Some(definition) = self.collection_definitions.get(&collection_id).cloned() else {
                continue;
            };
            let Some(item) = definition
                .items
                .iter()
                .find(|item| item.id == item_id)
                .cloned()
            else {
                continue;
            };
            if self.mark_collection_item_collected(profile_id, &collection_id, &item, true)? {
                self.check_collection_completion(profile_id, &definition)?;
            }
        }
        Ok(())
    }

    fn check_collection_completion(
        &mut self,
        profile_id: &str,
        definition: &CollectionDefinition,
    ) -> Result<(), ProgressionError> {
        let collection = self.collection_json(profile_id, definition);
        let complete = collection
            .get("complete")
            .and_then(JsonValue::as_bool)
            .unwrap_or(false);
        if complete {
            self.push_event(
                "collection_completed",
                Some(profile_id.to_string()),
                Some(definition.id.clone()),
                json!({ "collectionId": definition.id, "completion": 1.0 }),
            );
            if let Some(meta_achievement_id) = &definition.meta_achievement_id {
                if let Some(meta) = self
                    .achievement_definitions
                    .get(meta_achievement_id)
                    .cloned()
                {
                    self.apply_achievement_unlock(profile_id, &meta)?;
                }
            }
        }
        Ok(())
    }

    fn collection_json(&self, profile_id: &str, definition: &CollectionDefinition) -> JsonValue {
        let profile = self.profiles.get(profile_id);
        let state = profile.and_then(|profile| profile.collections.get(&definition.id));
        let items = definition
            .items
            .iter()
            .map(|item| {
                let item_state = state.and_then(|entries| entries.get(&item.id));
                let collected = item_state.map(|entry| entry.collected).unwrap_or(false);
                let discovered = item_state
                    .map(|entry| entry.discovered)
                    .unwrap_or(!item.hidden);
                json!({
                    "id": item.id,
                    "title": if discovered { JsonValue::String(item.title.clone()) } else { JsonValue::Null },
                    "hidden": item.hidden,
                    "discovered": discovered,
                    "collected": collected,
                    "achievement_id": item.achievement_id,
                })
            })
            .collect::<Vec<_>>();
        let total = definition.items.len();
        let collected = items
            .iter()
            .filter(|item| item["collected"].as_bool().unwrap_or(false))
            .count();
        let completion = if total == 0 {
            1.0
        } else {
            collected as f64 / total as f64
        };
        json!({
            "id": definition.id,
            "title": definition.title,
            "description": definition.description,
            "meta_achievement_id": definition.meta_achievement_id,
            "items": items,
            "collected_count": collected,
            "total_count": total,
            "completion": completion,
            "complete": collected == total,
        })
    }
}
