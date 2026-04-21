//! AI Needs and Motivation System.
//!
//! Implements a Sims-style need/drive model: each agent carries a set of named
//! [`Need`]s (hunger, safety, rest, social, …) that decay over time. When a need
//! drops below a threshold, motivations fire and the agent seeks to satisfy them.
//!
//! ## Architecture
//!
//! - [`Need`] is a single named value in `[0.0, 1.0]` that can decay per second
//!   and be satisfied by adding a positive delta.
//! - [`NeedSystem`] owns a collection of needs for one agent. `update(dt)` applies
//!   decay; `most_urgent()` returns the name of the need with the lowest effective
//!   value weighted by urgency.
//! - [`NeedAdvertisement`] is a world-space announcement that an object or location
//!   can satisfy a named need by a given amount. Game code populates a list of
//!   advertisements; the agent ranks them to decide where to go.
//!
//! ## Typical Usage Sequence
//!
//! 1. At agent creation, call `NeedSystem::new()` and add needs with `add_need`.
//! 2. Each frame call `NeedSystem::update(dt)` to decay all needs.
//! 3. Call `most_urgent()` to identify which need the agent should focus on.
//! 4. Query nearby `NeedAdvertisement`s to find the best satisfier.
//! 5. When an agent interacts with a satisfier, call `satisfy(name, amount)`.

// ────────────────────────────────────────────────────────────────────────────
// Need
// ────────────────────────────────────────────────────────────────────────────

/// A single named motivational drive for an AI agent.
///
/// Value starts at `initial_value` (default `1.0` = fully satisfied) and
/// decreases by `decay_rate * dt` each frame. A need is considered urgent when
/// its value drops below `urgency_threshold`. The effective urgency weight is
/// `urgency_factor * (1.0 - value)`.
///
/// # Fields
/// - `name` — `String`.
/// - `value` — `f32`.
/// - `decay_rate` — `f32`.
/// - `urgency_threshold` — `f32`.
/// - `urgency_factor` — `f32`.
/// - `enabled` — `bool`.
pub struct Need {
    /// Unique identifier for this need (e.g. `"hunger"`, `"safety"`).
    pub name: String,
    /// Current satisfaction level in `[0.0, 1.0]`. `1.0` = fully satisfied.
    pub value: f32,
    /// Amount subtracted per second during `update(dt)`.
    pub decay_rate: f32,
    /// Value below which this need is considered urgent.
    pub urgency_threshold: f32,
    /// Multiplier for urgency scoring; higher values make this need compete harder.
    pub urgency_factor: f32,
    /// When `false`, this need is skipped in urgency calculations.
    pub enabled: bool,
}

impl Need {
    /// Creates a new need with full satisfaction and the given parameters.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `decay_rate` — `f32`.
    /// - `urgency_threshold` — `f32`.
    /// - `urgency_factor` — `f32`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(name: &str, decay_rate: f32, urgency_threshold: f32, urgency_factor: f32) -> Self {
        Self {
            name: name.to_string(),
            value: 1.0,
            decay_rate,
            urgency_threshold,
            urgency_factor,
            enabled: true,
        }
    }

    /// Returns `true` when this need's value is below `urgency_threshold`.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_urgent(&self) -> bool {
        self.enabled && self.value < self.urgency_threshold
    }

    /// Returns the urgency score: `urgency_factor * (1.0 - value)`, or `0.0`
    /// when disabled.
    ///
    /// # Returns
    /// `f32`.
    pub fn urgency_score(&self) -> f32 {
        if !self.enabled { return 0.0; }
        self.urgency_factor * (1.0 - self.value)
    }

    /// Adds `amount` to the current need value, clamped to `[0.0, 1.0]`.
    ///
    /// # Parameters
    /// - `amount` — `f32`.
    pub fn satisfy(&mut self, amount: f32) {
        self.value = (self.value + amount).clamp(0.0, 1.0);
    }

    /// Subtracts `amount` from the current need value (immediate deprivation).
    ///
    /// # Parameters
    /// - `amount` — `f32`.
    pub fn deprive(&mut self, amount: f32) {
        self.value = (self.value - amount).max(0.0);
    }

    /// Advances the need decay by `dt` seconds.
    ///
    /// # Parameters
    /// - `dt` — `f32`.
    pub fn update(&mut self, dt: f32) {
        if self.decay_rate > 0.0 {
            self.value = (self.value - self.decay_rate * dt).max(0.0);
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// NeedAdvertisement
// ────────────────────────────────────────────────────────────────────────────

/// A world-space announcement that an object or location can satisfy a need.
///
/// Game code creates advertisements for beds (satisfy `"rest"`), food sources
/// (satisfy `"hunger"`), safe rooms (satisfy `"safety"`), etc. Agents rank
/// advertisements by need urgency, satisfaction amount, and distance.
///
/// # Fields
/// - `need_name` — `String`.
/// - `satisfaction` — `f32`.
/// - `position` — `(f32, f32)`.
/// - `advertiser_name` — `String`.
/// - `cooldown` — `f32`.
/// - `remaining_cooldown` — `f32`.
pub struct NeedAdvertisement {
    /// Name of the need this advertisement satisfies.
    pub need_name: String,
    /// Amount of satisfaction provided when the agent interacts with it.
    pub satisfaction: f32,
    /// World-space position of the satisfier.
    pub position: (f32, f32),
    /// Name of the object or entity that provides this satisfaction.
    pub advertiser_name: String,
    /// Time in seconds before this advertisement becomes available again after use (0 = unlimited).
    pub cooldown: f32,
    /// Remaining cooldown seconds. When `> 0` the advertisement is unavailable.
    pub remaining_cooldown: f32,
}

impl NeedAdvertisement {
    /// Creates a new need advertisement with no cooldown.
    ///
    /// # Parameters
    /// - `need_name` — `&str`.
    /// - `satisfaction` — `f32`.
    /// - `x` — `f32`.
    /// - `y` — `f32`.
    /// - `advertiser_name` — `&str`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(need_name: &str, satisfaction: f32, x: f32, y: f32, advertiser_name: &str) -> Self {
        Self {
            need_name: need_name.to_string(),
            satisfaction: satisfaction.clamp(0.0, 1.0),
            position: (x, y),
            advertiser_name: advertiser_name.to_string(),
            cooldown: 0.0,
            remaining_cooldown: 0.0,
        }
    }

    /// Returns `true` if the advertisement is currently available (no cooldown remaining).
    ///
    /// # Returns
    /// `bool`.
    pub fn is_available(&self) -> bool {
        self.remaining_cooldown <= 0.0
    }

    /// Marks the advertisement as used, starting the cooldown timer. Has no effect
    /// when `cooldown == 0`.
    pub fn use_it(&mut self) {
        if self.cooldown > 0.0 {
            self.remaining_cooldown = self.cooldown;
        }
    }

    /// Advances the cooldown timer by `dt` seconds.
    ///
    /// # Parameters
    /// - `dt` — `f32`.
    pub fn update(&mut self, dt: f32) {
        if self.remaining_cooldown > 0.0 {
            self.remaining_cooldown = (self.remaining_cooldown - dt).max(0.0);
        }
    }

    /// Scores this advertisement for an agent at `agent_pos` relative to
    /// `need_urgency`. Higher is better.
    ///
    /// Score = `(satisfaction * urgency) / (1.0 + distance * 0.01)`.
    ///
    /// # Parameters
    /// - `agent_pos` — `(f32, f32)`.
    /// - `need_urgency` — `f32`.
    ///
    /// # Returns
    /// `f32`.
    pub fn score(&self, agent_pos: (f32, f32), need_urgency: f32) -> f32 {
        if !self.is_available() { return 0.0; }
        let dx = self.position.0 - agent_pos.0;
        let dy = self.position.1 - agent_pos.1;
        let dist = (dx * dx + dy * dy).sqrt();
        (self.satisfaction * need_urgency) / (1.0 + dist * 0.01)
    }
}

// ────────────────────────────────────────────────────────────────────────────
// NeedSystem
// ────────────────────────────────────────────────────────────────────────────

/// Collection of [`Need`]s for a single agent.
///
/// Owns all needs, applies per-frame decay, and provides urgency queries.
///
/// # Fields
/// - `needs` — `Vec<Need>`.
#[derive(Default)]
pub struct NeedSystem {
    needs: Vec<Need>,
}

impl NeedSystem {
    /// Creates an empty need system.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self::default()
    }

    /// Adds a need to this system. Overwrites any existing need with the same name.
    ///
    /// # Parameters
    /// - `need` — `Need`.
    pub fn add_need(&mut self, need: Need) {
        if let Some(existing) = self.needs.iter_mut().find(|n| n.name == need.name) {
            *existing = need;
        } else {
            self.needs.push(need);
        }
    }

    /// Returns a reference to the need with the given name, or `None`.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Option<&Need>`.
    pub fn get(&self, name: &str) -> Option<&Need> {
        self.needs.iter().find(|n| n.name == name)
    }

    /// Returns a mutable reference to the need with the given name, or `None`.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Option<&mut Need>`.
    pub fn get_mut(&mut self, name: &str) -> Option<&mut Need> {
        self.needs.iter_mut().find(|n| n.name == name)
    }

    /// Advances all needs by `dt` seconds.
    ///
    /// # Parameters
    /// - `dt` — `f32`.
    pub fn update(&mut self, dt: f32) {
        for n in &mut self.needs { n.update(dt); }
    }

    /// Returns the name of the most urgent need (highest `urgency_score`).
    /// Returns `None` when no enabled needs exist.
    ///
    /// # Returns
    /// `Option<&str>`.
    pub fn most_urgent(&self) -> Option<&str> {
        self.needs.iter()
            .filter(|n| n.enabled)
            .max_by(|a, b| a.urgency_score().partial_cmp(&b.urgency_score()).unwrap())
            .map(|n| n.name.as_str())
    }

    /// Satisfies a named need by `amount`. No-ops silently if the need does not exist.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `amount` — `f32`.
    pub fn satisfy(&mut self, name: &str, amount: f32) {
        if let Some(need) = self.get_mut(name) { need.satisfy(amount); }
    }

    /// Returns a list of all need names in this system.
    ///
    /// # Returns
    /// `Vec<&str>`.
    pub fn need_names(&self) -> Vec<&str> {
        self.needs.iter().map(|n| n.name.as_str()).collect()
    }

    /// Returns the satisfaction value for a named need, or `1.0` if not found.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `f32`.
    pub fn value_of(&self, name: &str) -> f32 {
        self.get(name).map(|n| n.value).unwrap_or(1.0)
    }

    /// Selects the best available advertisement from a slice, considering the
    /// urgency of all needs in this system.
    ///
    /// Returns `None` if the slice is empty or all advertisements score ≤ 0.
    ///
    /// # Parameters
    /// - `agent_pos` — `(f32, f32)`.
    /// - `ads` — `&[NeedAdvertisement]`.
    ///
    /// # Returns
    /// `Option<usize>`.
    pub fn best_advertisement(&self, agent_pos: (f32, f32), ads: &[NeedAdvertisement]) -> Option<usize> {
        ads.iter().enumerate()
            .filter(|(_, ad)| ad.is_available())
            .map(|(i, ad)| {
                let urgency = self.get(&ad.need_name)
                    .map(|n| n.urgency_score())
                    .unwrap_or(0.0);
                (i, ad.score(agent_pos, urgency))
            })
            .filter(|(_, score)| *score > 0.0)
            .max_by(|a, b| a.1.partial_cmp(&b.1).unwrap())
            .map(|(i, _)| i)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn new_need_defaults() {
        // Need::new(name, decay_rate, urgency_threshold, urgency_factor); value starts at 1.0
        let n = Need::new("hunger", 0.1, 0.5, 1.5);
        assert_eq!(n.name, "hunger");
        assert!((n.value - 1.0).abs() < 1e-6);
    }

    #[test]
    fn decay_increases_value() {
        let mut n = Need::new("thirst", 0.2, 0.1, 1.5);
        n.update(1.0);
        assert!(n.value > 0.2);
    }

    #[test]
    fn satisfy_increases_value() {
        // satisfy() adds to value; deprive() subtracts
        let mut n = Need::new("rest", 0.1, 0.5, 1.5);
        n.deprive(0.5);  // value = 1.0 - 0.5 = 0.5
        n.satisfy(0.2);  // value = 0.5 + 0.2 = 0.7
        assert!((n.value - 0.7).abs() < 1e-6);
    }

    #[test]
    fn value_clamped_0_1() {
        let mut n = Need::new("food", 0.9, 10.0, 1.5);
        n.update(10.0);
        assert!(n.value <= 1.0);
        n.satisfy(100.0);
        assert!(n.value >= 0.0);
    }

    #[test]
    fn system_get_set() {
        let mut s = NeedSystem::new();
        s.add_need(Need::new("hunger", 0.0, 0.1, 1.5));
        assert!(s.get("hunger").is_some());
        assert!(s.get("bogus").is_none());
    }

    #[test]
    fn most_urgent_picks_highest() {
        let mut s = NeedSystem::new();
        // Deprive hunger so its urgency_score (factor * (1 - value)) is high
        let mut hunger = Need::new("hunger", 0.1, 0.5, 1.5);
        hunger.deprive(0.9);  // value = 0.1, urgency_score = 1.5 * 0.9 = 1.35
        s.add_need(hunger);
        let rest = Need::new("rest", 0.1, 0.5, 1.5);  // value = 1.0, urgency_score = 0.0
        s.add_need(rest);
        assert_eq!(s.most_urgent().unwrap(), "hunger");
    }
}
