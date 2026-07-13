//! Owns attribute, resource, and modifier definitions plus per-profile state for stat-like progression data.
//! Exposes canonical helpers that define, mutate, explain, spend, refill, and snapshot these profile values.
//! Applies bounds, effective-value math, modifier storage, and resource normalization before state persists.
//! Emits attribute, modifier, and resource events so other progression slices observe deterministic changes.
//! Provides crate-local resource accessors reused by formulas and sibling owners without state duplication.
//! Keeps stat and spendable-value behavior out of store-wide plumbing so growth rules stay cohesive.
//! Open this file when changing attribute math, modifier handling, or resource spending semantics.
use super::*;

impl ProgressionStore {
    /// Define one attribute.
    pub fn define_attribute(
        &mut self,
        id: &str,
        definition: AttributeDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        self.attribute_definitions
            .insert(id.to_string(), definition);
        Ok(())
    }

    /// Define one resource.
    pub fn define_resource(
        &mut self,
        id: &str,
        definition: ResourceDefinition,
    ) -> Result<(), ProgressionError> {
        validate_id(id)?;
        if definition.max < definition.min {
            return Err(ProgressionError::InvalidValue(format!(
                "resource '{}' max must be >= min",
                id
            )));
        }
        self.resource_definitions.insert(id.to_string(), definition);
        Ok(())
    }

    /// Set one attribute base value.
    pub fn set_attribute_base(
        &mut self,
        profile_id: &str,
        attribute_id: &str,
        value: f64,
    ) -> Result<f64, ProgressionError> {
        ensure_finite(value, "attribute value")?;
        let definition = self
            .attribute_definitions
            .get(attribute_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "attribute",
                id: attribute_id.to_string(),
            })?;
        let bounded = bound_value(value, definition.min, definition.max);
        let profile = self.profile_mut(profile_id)?;
        profile
            .attributes
            .insert(attribute_id.to_string(), AttributeState { base: bounded });
        self.bump_revision();
        self.push_event(
            "attribute_base_changed",
            Some(profile_id.to_string()),
            Some(attribute_id.to_string()),
            json!({ "base": bounded }),
        );
        Ok(bounded)
    }

    /// Set minimum and maximum bounds on one authored attribute definition.
    pub fn set_attribute_bounds(
        &mut self,
        attribute_id: &str,
        min: Option<f64>,
        max: Option<f64>,
    ) -> Result<(), ProgressionError> {
        let definition = self
            .attribute_definitions
            .get_mut(attribute_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "attribute",
                id: attribute_id.to_string(),
            })?;
        definition.min = min;
        definition.max = max;
        Ok(())
    }

    /// Add to one attribute base value.
    pub fn add_attribute_base(
        &mut self,
        profile_id: &str,
        attribute_id: &str,
        amount: f64,
    ) -> Result<f64, ProgressionError> {
        let current = self.get_attribute(profile_id, attribute_id, AttributeMode::Base)?;
        self.set_attribute_base(profile_id, attribute_id, current + amount)
    }

    /// Return one attribute in the requested mode.
    pub fn get_attribute(
        &self,
        profile_id: &str,
        attribute_id: &str,
        mode: AttributeMode,
    ) -> Result<f64, ProgressionError> {
        let definition = self
            .attribute_definitions
            .get(attribute_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "attribute",
                id: attribute_id.to_string(),
            })?;
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let base = profile
            .attributes
            .get(attribute_id)
            .map(|s| s.base)
            .unwrap_or(definition.base);
        let modifier_total = profile
            .modifiers
            .values()
            .filter(|modifier| modifier.target_id == attribute_id)
            .map(|modifier| modifier.value)
            .sum::<f64>();
        let effective = bound_value(base + modifier_total, definition.min, definition.max);
        Ok(match mode {
            AttributeMode::Base => base,
            AttributeMode::Current | AttributeMode::Effective => effective,
            AttributeMode::Min => definition.min.unwrap_or(f64::NEG_INFINITY),
            AttributeMode::Max => definition.max.unwrap_or(f64::INFINITY),
        })
    }

    /// Return a structured attribute explanation.
    pub fn explain_attribute(
        &self,
        profile_id: &str,
        attribute_id: &str,
    ) -> Result<AttributeExplanation, ProgressionError> {
        let definition = self
            .attribute_definitions
            .get(attribute_id)
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "attribute",
                id: attribute_id.to_string(),
            })?;
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        let base = profile
            .attributes
            .get(attribute_id)
            .map(|s| s.base)
            .unwrap_or(definition.base);
        let modifier_total = profile
            .modifiers
            .values()
            .filter(|modifier| modifier.target_id == attribute_id)
            .map(|modifier| modifier.value)
            .sum::<f64>();
        Ok(AttributeExplanation {
            base,
            modifier_total,
            effective: bound_value(base + modifier_total, definition.min, definition.max),
        })
    }

    /// Return one attribute snapshot.
    pub fn get_attribute_state(
        &self,
        profile_id: &str,
        attribute_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let explanation = self.explain_attribute(profile_id, attribute_id)?;
        Ok(json!({
            "id": attribute_id,
            "base": explanation.base,
            "effective": explanation.effective,
        }))
    }

    /// Add one modifier to a profile.
    pub fn add_modifier(
        &mut self,
        profile_id: &str,
        target_id: &str,
        options: ModifierAddOptions,
    ) -> Result<String, ProgressionError> {
        if !self.attribute_definitions.contains_key(target_id) {
            return Err(ProgressionError::MissingDefinition {
                kind: "attribute",
                id: target_id.to_string(),
            });
        }
        let handle = format!("mod_{}", self.next_modifier_id);
        self.next_modifier_id += 1;
        let modifier = ModifierState {
            handle: handle.clone(),
            target_id: target_id.to_string(),
            layer: options.layer.unwrap_or_else(|| "final_add".to_string()),
            value: options.value,
            remaining: options.duration,
            source: options.source,
            tags: options.tags,
        };
        let profile = self.profile_mut(profile_id)?;
        profile.modifiers.insert(handle.clone(), modifier);
        self.bump_revision();
        self.push_event(
            "modifier_added",
            Some(profile_id.to_string()),
            Some(target_id.to_string()),
            json!({ "handle": handle }),
        );
        Ok(handle)
    }

    /// Remove one modifier handle.
    pub fn remove_modifier(
        &mut self,
        profile_id: &str,
        handle: &str,
    ) -> Result<bool, ProgressionError> {
        let profile = self.profile_mut(profile_id)?;
        let removed = profile.modifiers.remove(handle).is_some();
        if removed {
            self.bump_revision();
            self.push_event(
                "modifier_removed",
                Some(profile_id.to_string()),
                None,
                json!({ "handle": handle }),
            );
        }
        Ok(removed)
    }

    /// Return modifier snapshots for one profile.
    pub fn list_modifiers(&self, profile_id: &str) -> Result<Vec<JsonValue>, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        Ok(profile
            .modifiers
            .values()
            .map(|modifier| {
                json!({
                    "handle": modifier.handle,
                    "target_id": modifier.target_id,
                    "layer": modifier.layer,
                    "value": modifier.value,
                    "remaining": modifier.remaining,
                    "source": modifier.source,
                    "tags": modifier.tags,
                })
            })
            .collect())
    }

    /// Set one resource value.
    pub fn set_resource(
        &mut self,
        profile_id: &str,
        resource_id: &str,
        value: f64,
    ) -> Result<f64, ProgressionError> {
        ensure_finite(value, "resource value")?;
        let definition = self
            .resource_definitions
            .get(resource_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "resource",
                id: resource_id.to_string(),
            })?;
        let bounded = value.clamp(definition.min, definition.max);
        let profile = self.profile_mut(profile_id)?;
        profile
            .resources
            .insert(resource_id.to_string(), ResourceState { value: bounded });
        self.bump_revision();
        self.push_event(
            "resource_changed",
            Some(profile_id.to_string()),
            Some(resource_id.to_string()),
            json!({ "value": bounded }),
        );
        Ok(bounded)
    }

    /// Add to one resource.
    pub fn add_resource(
        &mut self,
        profile_id: &str,
        resource_id: &str,
        amount: f64,
    ) -> Result<f64, ProgressionError> {
        let current = self.get_resource_value(profile_id, resource_id)?;
        self.set_resource(profile_id, resource_id, current + amount)
    }

    /// Return whether the resource can spend the requested amount.
    pub fn can_spend_resource(
        &self,
        profile_id: &str,
        resource_id: &str,
        amount: f64,
    ) -> Result<bool, ProgressionError> {
        ensure_finite(amount, "resource spend amount")?;
        Ok(self.get_resource_value(profile_id, resource_id)? >= amount)
    }

    /// Spend from one resource if enough value exists.
    pub fn spend_resource(
        &mut self,
        profile_id: &str,
        resource_id: &str,
        amount: f64,
    ) -> Result<bool, ProgressionError> {
        if !self.can_spend_resource(profile_id, resource_id, amount)? {
            self.push_event(
                "resource_insufficient",
                Some(profile_id.to_string()),
                Some(resource_id.to_string()),
                json!({ "requested": amount }),
            );
            return Ok(false);
        }
        self.add_resource(profile_id, resource_id, -amount)?;
        self.push_event(
            "resource_spent",
            Some(profile_id.to_string()),
            Some(resource_id.to_string()),
            json!({ "amount": amount }),
        );
        Ok(true)
    }

    /// Refill one resource to max or by amount.
    pub fn refill_resource(
        &mut self,
        profile_id: &str,
        resource_id: &str,
        amount: Option<f64>,
    ) -> Result<f64, ProgressionError> {
        let definition = self
            .resource_definitions
            .get(resource_id)
            .cloned()
            .ok_or_else(|| ProgressionError::MissingDefinition {
                kind: "resource",
                id: resource_id.to_string(),
            })?;
        let target = match amount {
            Some(delta) => self.get_resource_value(profile_id, resource_id)? + delta,
            None => definition.max,
        };
        self.set_resource(profile_id, resource_id, target)
    }

    /// Return one resource snapshot.
    pub fn get_resource(
        &self,
        profile_id: &str,
        resource_id: &str,
    ) -> Result<JsonValue, ProgressionError> {
        let definition = self.resource_definitions.get(resource_id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "resource",
                id: resource_id.to_string(),
            }
        })?;
        Ok(json!({
            "id": resource_id,
            "value": self.get_resource_value(profile_id, resource_id)?,
            "min": definition.min,
            "max": definition.max,
            "initial": definition.initial,
        }))
    }

    /// Return the effective stored or default-initial resource value for one profile resource pair.
    pub(crate) fn get_resource_value(
        &self,
        profile_id: &str,
        resource_id: &str,
    ) -> Result<f64, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        if let Some(state) = profile.resources.get(resource_id) {
            return Ok(state.value);
        }
        let definition = self.resource_definitions.get(resource_id).ok_or_else(|| {
            ProgressionError::MissingDefinition {
                kind: "resource",
                id: resource_id.to_string(),
            }
        })?;
        Ok(definition.initial.clamp(definition.min, definition.max))
    }
}
