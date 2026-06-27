//! Owns persistent personality trait profiles and temporary modifiers that shape how other AI systems score choices.
//! Stores base values, expiring additive modifiers, and optional archetype provenance used to initialize a profile.
//! Supports deterministic archetype jitter, modifier aging, interpolation, and source-based modifier removal.
//! Provides the temperament boundary between authored character identity and tactical systems that read trait values.
//! Also maintains the archetype registry so reusable presets stay separate from one-off agent mutation logic.
//! Open this owner when personality baselines, modifier lifetimes, or archetype contracts need shared changes.

use std::collections::HashMap;

/// Built-in trait keys that engine helpers understand without limiting custom profile keys.
pub const BUILTIN_TRAITS: &[&str] = &[
    "aggression",
    "defensiveness",
    "risk_tolerance",
    "caution",
    "predictability",
    "memory_retention",
    "patience",
    "opportunism",
    "cooperation",
    "expansion",
    "economy_bias",
    "tech_bias",
    "diplomacy_bias",
    "micro_control",
    "retreat_threshold",
];

/// Temporary additive change applied to one named trait.
#[derive(Clone)]
pub struct TraitModifier {
    /// Trait key affected by this modifier.
    pub trait_name: String,
    /// Additive delta applied on top of the base value.
    pub delta: f32,
    /// Remaining lifetime in seconds; `None` means the modifier does not expire.
    pub remaining: Option<f32>,
    /// Human-readable source tag used for bulk removal.
    pub source: String,
}
impl TraitModifier {
    /// Create a modifier for one trait.
    pub fn new(trait_name: &str, delta: f32, duration: Option<f32>, source: &str) -> Self {
        Self {
            trait_name: trait_name.to_string(),
            delta,
            remaining: duration,
            source: source.to_string(),
        }
    }

    /// Return `true` when this modifier has reached zero remaining lifetime.
    pub fn is_expired(&self) -> bool {
        self.remaining.map(|r| r <= 0.0).unwrap_or(false)
    }

    /// Advance the modifier timer by `dt` seconds when it is time-limited.
    pub fn tick(&mut self, dt: f32) {
        if let Some(ref mut rem) = self.remaining {
            *rem -= dt;
        }
    }
}

#[derive(Clone, Default)]
/// Base trait values plus active temporary modifiers for one agent.
pub struct TraitProfile {
    /// Base value per trait key.
    pub(crate) base_values: HashMap<String, f32>,
    /// Active temporary modifiers layered on top of the base values.
    pub(crate) modifiers: Vec<TraitModifier>,
    /// Optional archetype name used to initialize this profile.
    pub(crate) archetype: Option<String>,
}
impl TraitProfile {
    /// Create an empty trait profile.
    pub fn new() -> Self {
        Self::default()
    }

    /// Build a profile from a registered archetype and optional deterministic variance.
    pub fn from_archetype(archetypes: &TraitArchetypes, name: &str, variance: f32) -> Option<Self> {
        let base = archetypes.get(name)?;
        let mut profile = Self::new();
        profile.archetype = Some(name.to_string());
        for (trait_name, &value) in base {
            let jitter = if variance > 0.0 {
                let h = simple_hash(trait_name);
                let normalized = (h % 10001) as f32 / 10000.0;
                (normalized * 2.0 - 1.0) * variance
            } else {
                0.0
            };
            profile
                .base_values
                .insert(trait_name.clone(), (value + jitter).clamp(0.0, 1.0));
        }
        Some(profile)
    }

    /// Set the base value for one trait and clamp it to `[0, 1]`.
    pub fn set(&mut self, name: &str, value: f32) {
        self.base_values
            .insert(name.to_string(), value.clamp(0.0, 1.0));
    }

    /// Return the resolved value for one trait after applying active modifiers.
    pub fn get(&self, name: &str) -> f32 {
        let base = self.base_values.get(name).copied().unwrap_or(0.0);
        let delta: f32 = self
            .modifiers
            .iter()
            .filter(|m| m.trait_name == name && !m.is_expired())
            .map(|m| m.delta)
            .sum();
        (base + delta).clamp(0.0, 1.0)
    }

    /// Return the unclamped base value for one trait without modifiers.
    pub fn get_base(&self, name: &str) -> f32 {
        self.base_values.get(name).copied().unwrap_or(0.0)
    }

    /// Add a temporary modifier to one trait.
    pub fn add_modifier(
        &mut self,
        trait_name: &str,
        delta: f32,
        duration: Option<f32>,
        source: &str,
    ) {
        self.modifiers
            .push(TraitModifier::new(trait_name, delta, duration, source));
    }

    /// Remove all modifiers that originated from the given source tag.
    pub fn remove_modifiers_by_source(&mut self, source: &str) {
        self.modifiers.retain(|m| m.source != source);
    }

    /// Advance active modifier timers and discard expired entries.
    pub fn update(&mut self, dt: f32) {
        for m in &mut self.modifiers {
            m.tick(dt);
        }
        self.modifiers.retain(|m| !m.is_expired());
    }

    /// Return all registered trait names.
    pub fn trait_names(&self) -> Vec<&str> {
        self.base_values.keys().map(|s| s.as_str()).collect()
    }

    /// Return all registered trait names as owned strings.
    pub fn trait_names_owned(&self) -> Vec<String> {
        self.base_values.keys().cloned().collect()
    }

    /// Return the number of base traits stored in this profile.
    pub fn trait_count(&self) -> usize {
        self.base_values.len()
    }

    /// Return `true` when the profile has a base value for the named trait.
    pub fn has(&self, name: &str) -> bool {
        self.base_values.contains_key(name)
    }

    /// Move all shared trait values toward another profile by factor `t`.
    pub fn lerp_toward(&mut self, other: &TraitProfile, t: f32) {
        let t = t.clamp(0.0, 1.0);
        for (name, &target) in &other.base_values {
            let current = self.base_values.get(name).copied().unwrap_or(0.0);
            self.base_values
                .insert(name.clone(), current + (target - current) * t);
        }
    }

    /// Return the archetype name used to initialize this profile, when present.
    pub fn archetype(&self) -> Option<&str> {
        self.archetype.as_deref()
    }
}

#[derive(Default)]
/// Registry of named trait archetypes used to initialize agent profiles.
pub struct TraitArchetypes {
    /// Stored archetype trait maps keyed by archetype name.
    archetypes: HashMap<String, HashMap<String, f32>>,
}
impl TraitArchetypes {
    /// Create an empty archetype registry.
    pub fn new() -> Self {
        Self::default()
    }

    /// Create a registry populated with engine-provided commander archetypes.
    pub fn with_builtins() -> Self {
        let mut registry = Self::new();
        registry.register_builtin_defaults();
        registry
    }

    /// Register or replace the engine-provided commander archetypes.
    pub fn register_builtin_defaults(&mut self) {
        self.register(
            "balanced",
            HashMap::from([
                ("aggression".to_string(), 0.5),
                ("defensiveness".to_string(), 0.5),
                ("risk_tolerance".to_string(), 0.5),
                ("caution".to_string(), 0.5),
                ("predictability".to_string(), 0.5),
                ("memory_retention".to_string(), 0.6),
                ("cooperation".to_string(), 0.5),
            ]),
        );
        self.register(
            "aggressive",
            HashMap::from([
                ("aggression".to_string(), 0.9),
                ("risk_tolerance".to_string(), 0.75),
                ("caution".to_string(), 0.2),
                ("defensiveness".to_string(), 0.25),
                ("opportunism".to_string(), 0.7),
            ]),
        );
        self.register(
            "defensive",
            HashMap::from([
                ("aggression".to_string(), 0.25),
                ("defensiveness".to_string(), 0.85),
                ("caution".to_string(), 0.8),
                ("retreat_threshold".to_string(), 0.65),
                ("memory_retention".to_string(), 0.75),
            ]),
        );
        self.register(
            "opportunist",
            HashMap::from([
                ("opportunism".to_string(), 0.9),
                ("risk_tolerance".to_string(), 0.65),
                ("patience".to_string(), 0.35),
                ("predictability".to_string(), 0.3),
            ]),
        );
        self.register(
            "expansionist",
            HashMap::from([
                ("expansion".to_string(), 0.9),
                ("risk_tolerance".to_string(), 0.65),
                ("economy_bias".to_string(), 0.65),
                ("defensiveness".to_string(), 0.35),
            ]),
        );
        self.register(
            "technocrat",
            HashMap::from([
                ("tech_bias".to_string(), 0.9),
                ("economy_bias".to_string(), 0.65),
                ("patience".to_string(), 0.75),
                ("aggression".to_string(), 0.35),
            ]),
        );
        self.register(
            "cautious",
            HashMap::from([
                ("caution".to_string(), 0.9),
                ("risk_tolerance".to_string(), 0.2),
                ("defensiveness".to_string(), 0.7),
                ("predictability".to_string(), 0.75),
            ]),
        );
        self.register(
            "chaotic",
            HashMap::from([
                ("predictability".to_string(), 0.1),
                ("risk_tolerance".to_string(), 0.85),
                ("aggression".to_string(), 0.65),
                ("opportunism".to_string(), 0.8),
            ]),
        );
        self.register(
            "commander_rts",
            HashMap::from([
                ("micro_control".to_string(), 0.85),
                ("aggression".to_string(), 0.6),
                ("defensiveness".to_string(), 0.55),
                ("cooperation".to_string(), 0.7),
                ("retreat_threshold".to_string(), 0.45),
            ]),
        );
        self.register(
            "empire_builder",
            HashMap::from([
                ("expansion".to_string(), 0.8),
                ("economy_bias".to_string(), 0.8),
                ("diplomacy_bias".to_string(), 0.65),
                ("memory_retention".to_string(), 0.8),
                ("patience".to_string(), 0.7),
            ]),
        );
    }

    /// Register or replace one named archetype after clamping all values to `[0, 1]`.
    pub fn register(&mut self, name: &str, traits: HashMap<String, f32>) {
        let clamped: HashMap<String, f32> = traits
            .into_iter()
            .map(|(k, v)| (k, v.clamp(0.0, 1.0)))
            .collect();
        self.archetypes.insert(name.to_string(), clamped);
    }

    /// Return the trait map for one named archetype.
    pub fn get(&self, name: &str) -> Option<&HashMap<String, f32>> {
        self.archetypes.get(name)
    }

    /// Return all registered archetype names.
    pub fn names(&self) -> Vec<&str> {
        self.archetypes.keys().map(|s| s.as_str()).collect()
    }

    /// Return the number of registered archetypes.
    pub fn count(&self) -> usize {
        self.archetypes.len()
    }
}

/// How one trait bias changes a decision score.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DecisionBiasMode {
    /// Add `trait_value * weight` to the base score.
    Add,
    /// Multiply the score by `1 + trait_value * weight`.
    Multiply,
}
impl DecisionBiasMode {
    /// Parse a mode string; unknown values fall back to additive scoring.
    pub fn parse_str(value: &str) -> Self {
        match value {
            "multiply" | "mul" | "scale" => Self::Multiply,
            _ => Self::Add,
        }
    }

    /// Return the canonical Lua-facing mode string.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Add => "add",
            Self::Multiply => "multiply",
        }
    }
}

/// One open-ended rule that maps a profile trait onto a named decision key.
#[derive(Debug, Clone)]
pub struct DecisionBiasRule {
    /// Trait key read from a `TraitProfile`.
    pub trait_name: String,
    /// Decision key affected by this rule; `"*"` applies to every decision.
    pub decision_key: String,
    /// Strength of the adjustment.
    pub weight: f32,
    /// Scoring operation used by this rule.
    pub mode: DecisionBiasMode,
}
impl DecisionBiasRule {
    /// Create a decision bias rule.
    pub fn new(trait_name: &str, decision_key: &str, weight: f32, mode: DecisionBiasMode) -> Self {
        Self {
            trait_name: trait_name.to_string(),
            decision_key: decision_key.to_string(),
            weight,
            mode,
        }
    }
}

#[derive(Clone, Default)]
/// Set of open-ended decision bias rules used to tune action or goal scores from a trait profile.
pub struct DecisionBiasSet {
    /// Stored bias rules in application order.
    rules: Vec<DecisionBiasRule>,
}
impl DecisionBiasSet {
    /// Create an empty bias set.
    pub fn new() -> Self {
        Self::default()
    }

    /// Add a rule for one trait and decision key.
    pub fn add_rule(&mut self, trait_name: &str, decision_key: &str, weight: f32, mode: &str) {
        self.rules.push(DecisionBiasRule::new(
            trait_name,
            decision_key,
            weight,
            DecisionBiasMode::parse_str(mode),
        ));
    }

    /// Return the number of stored rules.
    pub fn rule_count(&self) -> usize {
        self.rules.len()
    }

    /// Score a named decision by applying all matching trait rules to `base_score`.
    pub fn score_decision(
        &self,
        profile: &TraitProfile,
        decision_key: &str,
        base_score: f32,
    ) -> f32 {
        let mut score = base_score.clamp(0.0, 1.0);
        for rule in &self.rules {
            if rule.decision_key != decision_key && rule.decision_key != "*" {
                continue;
            }
            let trait_value = profile.get(&rule.trait_name);
            match rule.mode {
                DecisionBiasMode::Add => {
                    score += trait_value * rule.weight;
                }
                DecisionBiasMode::Multiply => {
                    score *= 1.0 + trait_value * rule.weight;
                }
            }
        }
        score.clamp(0.0, 1.0)
    }
}

/// Hash a string deterministically for archetype jitter generation.
fn simple_hash(s: &str) -> u64 {
    let mut h: u64 = 0xcbf29ce484222325;
    for byte in s.bytes() {
        h ^= byte as u64;
        h = h.wrapping_mul(0x100000001b3);
    }
    h
}
