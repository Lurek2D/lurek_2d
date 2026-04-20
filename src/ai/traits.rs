//! AI Trait and Personality System.
//!
//! Provides configurable personality profiles for AI agents. Traits are named
//! float values in `[0.0, 1.0]` (e.g. `"aggression"`, `"caution"`, `"loyalty"`)
//! that influence how other AI subsystems behave — FSM transition thresholds,
//! utility action weights, steering flee distances, and so on.
//!
//! ## Architecture
//!
//! - [`TraitProfile`] stores base trait values plus stacked [`TraitModifier`]s
//!   (timed or permanent) and exposes an `effective` value clamped to `[0.0, 1.0]`.
//! - [`TraitArchetypes`] is a named registry of archetypal profiles (e.g. `"berserker"`,
//!   `"tactician"`). `TraitProfile::from_archetype` instantiates a profile from an
//!   archetype with optional random jitter.
//!
//! ## Typical Usage Sequence
//!
//! 1. Build a `TraitArchetypes` registry once at game startup.
//! 2. For each agent, call `TraitProfile::from_archetype` to get a personalised copy.
//! 3. Attach the profile to the agent via `Agent::trait_profile`.
//! 4. Read trait values inside FSM transitions, BT condition nodes, and utility
//!    scorers to modulate thresholds or weights.
//! 5. Call `TraitProfile::update(dt)` each frame to expire timed modifiers.

use std::collections::HashMap;

// ────────────────────────────────────────────────────────────────────────────
// TraitModifier
// ────────────────────────────────────────────────────────────────────────────

/// A temporary or permanent additive delta applied on top of a base trait value.
///
/// Modifiers are stacked: all active modifiers for a trait are summed and added
/// to the base value before clamping. A `duration` of `None` means the modifier
/// is permanent until explicitly removed; a finite duration expires after that
/// many seconds have elapsed.
///
/// # Fields
/// - `trait_name` — `String`.
/// - `delta` — `f32`.
/// - `remaining` — `Option<f32>`.
/// - `source` — `String`.
pub struct TraitModifier {
    /// Name of the trait this modifier affects.
    pub trait_name: String,
    /// Additive delta in `[-1.0, 1.0]`. May bring effective value outside base
    /// range, but the effective getter clamps the final result to `[0.0, 1.0]`.
    pub delta: f32,
    /// Remaining seconds until this modifier expires, or `None` for permanent.
    pub remaining: Option<f32>,
    /// Human-readable label identifying the source (e.g. `"berserk_buff"`,
    /// `"poisoned"`). Used by `remove_modifiers_by_source`.
    pub source: String,
}

impl TraitModifier {
    /// Creates a new modifier.
    ///
    /// # Parameters
    /// - `trait_name` — `&str`.
    /// - `delta` — `f32`.
    /// - `duration` — `Option<f32>`.
    /// - `source` — `&str`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(trait_name: &str, delta: f32, duration: Option<f32>, source: &str) -> Self {
        Self {
            trait_name: trait_name.to_string(),
            delta,
            remaining: duration,
            source: source.to_string(),
        }
    }

    /// Returns `true` if a timed modifier has expired (remaining ≤ 0).
    /// Permanent modifiers (`remaining == None`) never expire.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_expired(&self) -> bool {
        self.remaining.map(|r| r <= 0.0).unwrap_or(false)
    }

    /// Advances the modifier timer. Has no effect on permanent modifiers.
    ///
    /// # Parameters
    /// - `dt` — `f32`.
    pub fn tick(&mut self, dt: f32) {
        if let Some(ref mut rem) = self.remaining {
            *rem -= dt;
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// TraitProfile
// ────────────────────────────────────────────────────────────────────────────

/// Named float trait profile for an AI agent.
///
/// Stores a set of base trait values (`"aggression"`, `"caution"`, `"loyalty"`,
/// etc.) plus stacked additive modifiers. The effective value for any trait is
/// `clamp(base + sum(active_modifiers), 0.0, 1.0)`.
///
/// Profiles are cheap to clone: sharing an archetype base is done by calling
/// `from_archetype` once per agent rather than sharing a single profile.
///
/// # Fields
/// - `base_values` — `HashMap<String, f32>`.
/// - `modifiers` — `Vec<TraitModifier>`.
/// - `archetype` — `Option<String>`.
#[derive(Default)]
pub struct TraitProfile {
    /// Base trait values, each in `[0.0, 1.0]`.
    pub(crate) base_values: HashMap<String, f32>,
    /// Active additive modifiers (timed or permanent).
    pub(crate) modifiers: Vec<TraitModifier>,
    /// Optional archetype name this profile was instantiated from.
    pub(crate) archetype: Option<String>,
}

impl TraitProfile {
    /// Creates a new empty trait profile with no base traits and no modifiers.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self::default()
    }

    /// Creates a trait profile from a named archetype with optional variance jitter.
    ///
    /// Copies all base trait values from the archetype. When `variance > 0`, each
    /// trait value is perturbed by a deterministic jitter in `[-variance, +variance]`
    /// using a simple hash-based pseudo-random source so that repeated calls with
    /// the same seed produce the same result. The jitter is clamped so the result
    /// stays within `[0.0, 1.0]`.
    ///
    /// Returns `None` if the archetype name is not registered.
    ///
    /// # Parameters
    /// - `archetypes` — `&TraitArchetypes`.
    /// - `name` — `&str`.
    /// - `variance` — `f32`.
    ///
    /// # Returns
    /// `Option<Self>`.
    pub fn from_archetype(archetypes: &TraitArchetypes, name: &str, variance: f32) -> Option<Self> {
        let base = archetypes.get(name)?;
        let mut profile = Self::new();
        profile.archetype = Some(name.to_string());
        for (trait_name, &value) in base {
            let jitter = if variance > 0.0 {
                // Deterministic per-trait jitter based on trait name hash
                let h = simple_hash(trait_name);
                let normalized = (h % 10001) as f32 / 10000.0; // [0,1]
                (normalized * 2.0 - 1.0) * variance
            } else {
                0.0
            };
            profile.base_values.insert(trait_name.clone(), (value + jitter).clamp(0.0, 1.0));
        }
        Some(profile)
    }

    /// Sets the base value for a trait, clamped to `[0.0, 1.0]`.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `value` — `f32`.
    pub fn set(&mut self, name: &str, value: f32) {
        self.base_values.insert(name.to_string(), value.clamp(0.0, 1.0));
    }

    /// Returns the effective trait value (base + all active modifier deltas),
    /// clamped to `[0.0, 1.0]`. Returns `0.0` for unknown traits.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `f32`.
    pub fn get(&self, name: &str) -> f32 {
        let base = self.base_values.get(name).copied().unwrap_or(0.0);
        let delta: f32 = self.modifiers.iter()
            .filter(|m| m.trait_name == name && !m.is_expired())
            .map(|m| m.delta)
            .sum();
        (base + delta).clamp(0.0, 1.0)
    }

    /// Returns the raw base value for a trait without applying modifiers.
    /// Returns `0.0` for unknown traits.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `f32`.
    pub fn get_base(&self, name: &str) -> f32 {
        self.base_values.get(name).copied().unwrap_or(0.0)
    }

    /// Adds an additive modifier to a trait with optional duration.
    ///
    /// Multiple modifiers from different sources stack additively. If `duration`
    /// is `None` the modifier is permanent until removed via
    /// `remove_modifiers_by_source`. Timed modifiers expire after `update(dt)`
    /// consumes the remaining seconds.
    ///
    /// # Parameters
    /// - `trait_name` — `&str`.
    /// - `delta` — `f32`.
    /// - `duration` — `Option<f32>`.
    /// - `source` — `&str`.
    pub fn add_modifier(&mut self, trait_name: &str, delta: f32, duration: Option<f32>, source: &str) {
        self.modifiers.push(TraitModifier::new(trait_name, delta, duration, source));
    }

    /// Removes all modifiers whose `source` field matches the given string.
    ///
    /// # Parameters
    /// - `source` — `&str`.
    pub fn remove_modifiers_by_source(&mut self, source: &str) {
        self.modifiers.retain(|m| m.source != source);
    }

    /// Advances modifier timers by `dt` seconds and removes expired timed modifiers.
    ///
    /// Call this every frame inside the agent's update loop to keep timed buffs/debuffs
    /// correctly expiring.
    ///
    /// # Parameters
    /// - `dt` — `f32`.
    pub fn update(&mut self, dt: f32) {
        for m in &mut self.modifiers {
            m.tick(dt);
        }
        self.modifiers.retain(|m| !m.is_expired());
    }

    /// Returns a `Vec` of all base trait names defined in this profile.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn trait_names(&self) -> Vec<&str> {
        self.base_values.keys().map(|s| s.as_str()).collect()
    }

    /// Returns the number of base traits defined in this profile.
    ///
    /// # Returns
    /// `usize`.
    pub fn trait_count(&self) -> usize {
        self.base_values.len()
    }

    /// Returns `true` if a base value for `name` has been set.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn has(&self, name: &str) -> bool {
        self.base_values.contains_key(name)
    }

    /// Linearly interpolates all base trait values toward those of `other` by
    /// factor `t` (clamped to `[0.0, 1.0]`). Traits missing from `other` are
    /// not changed. New traits present in `other` but not `self` are added.
    ///
    /// # Parameters
    /// - `other` — `&TraitProfile`.
    /// - `t` — `f32`.
    pub fn lerp_toward(&mut self, other: &TraitProfile, t: f32) {
        let t = t.clamp(0.0, 1.0);
        for (name, &target) in &other.base_values {
            let current = self.base_values.get(name).copied().unwrap_or(0.0);
            self.base_values.insert(name.clone(), current + (target - current) * t);
        }
    }

    /// Returns the archetype name this profile was created from, if any.
    ///
    /// # Returns
    /// `Option<&str>`.
    pub fn archetype(&self) -> Option<&str> {
        self.archetype.as_deref()
    }
}

// ────────────────────────────────────────────────────────────────────────────
// TraitArchetypes
// ────────────────────────────────────────────────────────────────────────────

/// Registry of named archetypal trait profiles used for agent instantiation.
///
/// Archetypes are immutable templates. Game code registers archetypes once
/// during initialisation (e.g. `"berserker"`, `"tactician"`, `"guard"`) and
/// then agents are created via `TraitProfile::from_archetype`.
///
/// # Fields
/// - `archetypes` — `HashMap<String, HashMap<String, f32>>`.
#[derive(Default)]
pub struct TraitArchetypes {
    archetypes: HashMap<String, HashMap<String, f32>>,
}

impl TraitArchetypes {
    /// Creates an empty archetype registry.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self::default()
    }

    /// Registers a named archetype with its trait values.
    ///
    /// All trait values are clamped to `[0.0, 1.0]` on registration.
    /// Overwrites any existing archetype with the same name.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `traits` — `HashMap<String, f32>`.
    pub fn register(&mut self, name: &str, traits: HashMap<String, f32>) {
        let clamped: HashMap<String, f32> = traits.into_iter()
            .map(|(k, v)| (k, v.clamp(0.0, 1.0)))
            .collect();
        self.archetypes.insert(name.to_string(), clamped);
    }

    /// Returns the trait map for a named archetype, or `None` if not found.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Option<&HashMap<String, f32>>`.
    pub fn get(&self, name: &str) -> Option<&HashMap<String, f32>> {
        self.archetypes.get(name)
    }

    /// Returns a list of all registered archetype names.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn names(&self) -> Vec<&str> {
        self.archetypes.keys().map(|s| s.as_str()).collect()
    }

    /// Returns the number of registered archetypes.
    ///
    /// # Returns
    /// `usize`.
    pub fn count(&self) -> usize {
        self.archetypes.len()
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────────────────

/// Minimal deterministic hash for a string — used for variance jitter only.
/// Not cryptographic; chosen for speed and zero allocations.
fn simple_hash(s: &str) -> u64 {
    let mut h: u64 = 0xcbf29ce484222325;
    for byte in s.bytes() {
        h ^= byte as u64;
        h = h.wrapping_mul(0x100000001b3);
    }
    h
}
