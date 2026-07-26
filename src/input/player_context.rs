//! Owns player-scoped action definitions, device assignments, and analog shaping.
//! A context stores only input policy; live keyboard, mouse, and gamepad state remains runtime-owned.
//! Device ownership is coordinated through `PlayerInputRegistry` so Lua contexts cannot silently contend.
//! The module has no dependency on actors, cameras, UI, or any other gameplay-facing subsystem.

use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, HashMap};

/// Maximum number of actions retained by one player input context.
pub const MAX_PLAYER_ACTIONS: usize = 256;
/// Maximum number of digital bindings accepted by one action.
pub const MAX_PLAYER_ACTION_BINDINGS: usize = 32;

/// Curve applied after an analog deadzone has been removed.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum AxisCurve {
    /// Preserve a linear response.
    Linear,
    /// Square the magnitude while preserving sign.
    Squared,
    /// Cube the magnitude while preserving sign.
    Cubic,
}

impl AxisCurve {
    /// Parses a Lua-facing curve name.
    pub fn parse(value: &str) -> Result<Self, String> {
        match value.trim().to_ascii_lowercase().as_str() {
            "linear" => Ok(Self::Linear),
            "squared" | "square" => Ok(Self::Squared),
            "cubic" | "cube" => Ok(Self::Cubic),
            _ => Err("curve must be `linear`, `squared`, or `cubic`".to_string()),
        }
    }

    fn apply(self, value: f32) -> f32 {
        match self {
            Self::Linear => value,
            Self::Squared => value.signum() * value.abs().powi(2),
            Self::Cubic => value.powi(3),
        }
    }
}

/// Shared analog processing settings for one- and two-dimensional actions.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AxisSettings {
    /// Deadzone removed from the raw magnitude.
    pub deadzone: f32,
    /// Response curve applied after deadzone normalization.
    pub curve: AxisCurve,
    /// Scalar applied after the response curve.
    pub sensitivity: f32,
    /// Threshold at which an axis becomes button-like active.
    pub activation_threshold: f32,
    /// Amount below the activation threshold required before release.
    pub hysteresis: f32,
}

impl Default for AxisSettings {
    fn default() -> Self {
        Self {
            deadzone: 0.15,
            curve: AxisCurve::Linear,
            sensitivity: 1.0,
            activation_threshold: 0.5,
            hysteresis: 0.1,
        }
    }
}

impl AxisSettings {
    /// Validates all finite ranges before a definition is committed.
    pub fn validate(self) -> Result<Self, String> {
        if !self.deadzone.is_finite() || !(0.0..1.0).contains(&self.deadzone) {
            return Err("deadzone must be finite and in [0, 1)".to_string());
        }
        if !self.sensitivity.is_finite() || self.sensitivity < 0.0 || self.sensitivity > 16.0 {
            return Err("sensitivity must be finite and in [0, 16]".to_string());
        }
        if !self.activation_threshold.is_finite()
            || !(0.0..=1.0).contains(&self.activation_threshold)
        {
            return Err("activationThreshold must be finite and in [0, 1]".to_string());
        }
        if !self.hysteresis.is_finite()
            || self.hysteresis < 0.0
            || self.hysteresis > self.activation_threshold
        {
            return Err(
                "hysteresis must be finite and no greater than activationThreshold".to_string(),
            );
        }
        Ok(self)
    }

    /// Shapes a signed one-dimensional input into the bounded public range.
    pub fn shape_1d(self, value: f32) -> f32 {
        let value = value.clamp(-1.0, 1.0);
        let magnitude = value.abs();
        if magnitude <= self.deadzone {
            return 0.0;
        }
        let normalized = (magnitude - self.deadzone) / (1.0 - self.deadzone);
        (value.signum() * self.curve.apply(normalized) * self.sensitivity).clamp(-1.0, 1.0)
    }

    /// Applies a radial deadzone and clamps a two-dimensional vector to unit length.
    pub fn shape_2d(self, x: f32, y: f32) -> (f32, f32) {
        let length = x.hypot(y);
        if length <= self.deadzone || length <= f32::EPSILON {
            return (0.0, 0.0);
        }
        let bounded_length = length.min(1.0);
        let normalized = (bounded_length - self.deadzone) / (1.0 - self.deadzone);
        let shaped = (self.curve.apply(normalized) * self.sensitivity).clamp(0.0, 1.0);
        (x / length * shaped, y / length * shaped)
    }
}

/// One player-local input action definition.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "kind", rename_all = "camelCase")]
pub enum PlayerAction {
    /// A digital action driven by any listed binding.
    Button {
        /// Canonical player-context binding strings.
        bindings: Vec<String>,
    },
    /// A signed analog action composed from digital keys and an optional gamepad axis.
    Axis1D {
        /// Digital bindings contributing -1.
        negative: Vec<String>,
        /// Digital bindings contributing +1.
        positive: Vec<String>,
        /// Optional standard gamepad axis name.
        gamepad_axis: Option<String>,
        /// Invert the final axis.
        invert: bool,
        /// Analog processing settings.
        settings: AxisSettings,
    },
    /// A two-dimensional analog action composed from digital keys and optional gamepad axes.
    Axis2D {
        /// Digital bindings contributing negative X.
        left: Vec<String>,
        /// Digital bindings contributing positive X.
        right: Vec<String>,
        /// Digital bindings contributing negative Y.
        up: Vec<String>,
        /// Digital bindings contributing positive Y.
        down: Vec<String>,
        /// Optional standard gamepad X axis name.
        gamepad_x: Option<String>,
        /// Optional standard gamepad Y axis name.
        gamepad_y: Option<String>,
        /// Invert the final X axis.
        invert_x: bool,
        /// Invert the final Y axis.
        invert_y: bool,
        /// Analog processing settings.
        settings: AxisSettings,
    },
}

impl PlayerAction {
    /// Returns all digital binding strings for conflict reporting.
    pub fn digital_bindings(&self) -> impl Iterator<Item = &String> {
        let mut values = Vec::new();
        match self {
            Self::Button { bindings } => values.extend(bindings),
            Self::Axis1D {
                negative, positive, ..
            } => {
                values.extend(negative);
                values.extend(positive);
            }
            Self::Axis2D {
                left,
                right,
                up,
                down,
                ..
            } => {
                values.extend(left);
                values.extend(right);
                values.extend(up);
                values.extend(down);
            }
        }
        values.into_iter()
    }

    /// Returns settings for analog actions.
    pub fn settings(&self) -> Option<AxisSettings> {
        match self {
            Self::Button { .. } => None,
            Self::Axis1D { settings, .. } | Self::Axis2D { settings, .. } => Some(*settings),
        }
    }
}

/// Serializable binding payload for a player context.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PlayerBindingSnapshot {
    /// Schema version for forward-compatible restore.
    pub schema_version: u32,
    /// Player id retained for diagnostics, not device reassignment.
    pub player_id: u32,
    /// Enabled flag restored with the definitions.
    pub enabled: bool,
    /// Deterministically ordered local action definitions.
    pub actions: BTreeMap<String, PlayerAction>,
}

/// State owned by one `LPlayerInputContext`.
#[derive(Debug)]
pub struct PlayerInputContext {
    /// Registry-unique context id.
    pub context_id: u64,
    /// Caller-selected one-based player id.
    pub player_id: u32,
    /// Whether queries return live values.
    pub enabled: bool,
    /// Whether this context currently owns keyboard and mouse input.
    pub keyboard_mouse: bool,
    /// Assigned gamepad slots and whether each assignment is shared.
    pub gamepads: BTreeMap<usize, bool>,
    /// Player-local action definitions.
    pub actions: BTreeMap<String, PlayerAction>,
    /// Last hysteresis state for analog actions.
    pub analog_active: HashMap<String, bool>,
    /// Frame on which each analog transition state was refreshed.
    pub analog_frames: HashMap<String, u64>,
    /// Cached pressed transition frame for analog actions.
    pub analog_pressed_frames: HashMap<String, u64>,
    /// Cached released transition frame for analog actions.
    pub analog_released_frames: HashMap<String, u64>,
}

impl PlayerInputContext {
    /// Creates an empty enabled context.
    pub fn new(context_id: u64, player_id: u32) -> Result<Self, String> {
        if player_id == 0 {
            return Err("playerId must be at least 1".to_string());
        }
        Ok(Self {
            context_id,
            player_id,
            enabled: true,
            keyboard_mouse: false,
            gamepads: BTreeMap::new(),
            actions: BTreeMap::new(),
            analog_active: HashMap::new(),
            analog_frames: HashMap::new(),
            analog_pressed_frames: HashMap::new(),
            analog_released_frames: HashMap::new(),
        })
    }

    /// Atomically inserts or replaces a validated action definition.
    pub fn define_action(&mut self, name: String, action: PlayerAction) -> Result<(), String> {
        validate_action_name(&name)?;
        let binding_count = action.digital_bindings().count();
        if binding_count > MAX_PLAYER_ACTION_BINDINGS {
            return Err(format!(
                "action exceeds the limit of {MAX_PLAYER_ACTION_BINDINGS} digital bindings"
            ));
        }
        if let Some(settings) = action.settings() {
            settings.validate()?;
        }
        if !self.actions.contains_key(&name) && self.actions.len() >= MAX_PLAYER_ACTIONS {
            return Err(format!(
                "context exceeds the limit of {MAX_PLAYER_ACTIONS} actions"
            ));
        }
        self.actions.insert(name.clone(), action);
        self.clear_transition_state(&name);
        Ok(())
    }

    /// Removes one action and its transition state.
    pub fn remove_action(&mut self, name: &str) -> bool {
        self.clear_transition_state(name);
        self.actions.remove(name).is_some()
    }

    /// Removes every action and all transition state.
    pub fn clear_actions(&mut self) {
        self.actions.clear();
        self.analog_active.clear();
        self.analog_frames.clear();
        self.analog_pressed_frames.clear();
        self.analog_released_frames.clear();
    }

    /// Returns deterministic binding conflicts local to this context.
    pub fn conflicts(&self) -> BTreeMap<String, Vec<String>> {
        let mut by_binding: BTreeMap<String, Vec<String>> = BTreeMap::new();
        for (name, action) in &self.actions {
            for binding in action.digital_bindings() {
                by_binding
                    .entry(binding.clone())
                    .or_default()
                    .push(name.clone());
            }
        }
        by_binding.retain(|_, names| names.len() > 1);
        by_binding
    }

    /// Serializes definitions and enabled state without serializing physical device ownership.
    pub fn serialize_bindings(&self) -> Result<String, String> {
        serde_json::to_string(&PlayerBindingSnapshot {
            schema_version: 1,
            player_id: self.player_id,
            enabled: self.enabled,
            actions: self.actions.clone(),
        })
        .map_err(|error| error.to_string())
    }

    /// Preflights and atomically restores definitions and enabled state.
    pub fn restore_bindings(&mut self, json: &str) -> Result<(), String> {
        let snapshot: PlayerBindingSnapshot =
            serde_json::from_str(json).map_err(|error| error.to_string())?;
        if snapshot.schema_version != 1 {
            return Err(format!(
                "unsupported schemaVersion {}",
                snapshot.schema_version
            ));
        }
        if snapshot.actions.len() > MAX_PLAYER_ACTIONS {
            return Err(format!(
                "snapshot exceeds the limit of {MAX_PLAYER_ACTIONS} actions"
            ));
        }
        let mut checked = Self::new(self.context_id, self.player_id)?;
        for (name, action) in snapshot.actions {
            checked.define_action(name, action)?;
        }
        self.actions = checked.actions;
        self.enabled = snapshot.enabled;
        self.analog_active.clear();
        self.analog_frames.clear();
        self.analog_pressed_frames.clear();
        self.analog_released_frames.clear();
        Ok(())
    }

    /// Updates the hysteresis state for one analog action at most once per frame.
    pub fn refresh_analog_transition(&mut self, name: &str, magnitude: f32, frame: u64) {
        if self.analog_frames.get(name) == Some(&frame) {
            return;
        }
        let Some(settings) = self.actions.get(name).and_then(PlayerAction::settings) else {
            return;
        };
        let was_active = self.analog_active.get(name).copied().unwrap_or(false);
        let release_threshold = (settings.activation_threshold - settings.hysteresis).max(0.0);
        let active = if was_active {
            magnitude >= release_threshold
        } else {
            magnitude >= settings.activation_threshold
        };
        if active && !was_active {
            self.analog_pressed_frames.insert(name.to_string(), frame);
        } else if !active && was_active {
            self.analog_released_frames.insert(name.to_string(), frame);
        }
        self.analog_active.insert(name.to_string(), active);
        self.analog_frames.insert(name.to_string(), frame);
    }

    fn clear_transition_state(&mut self, name: &str) {
        self.analog_active.remove(name);
        self.analog_frames.remove(name);
        self.analog_pressed_frames.remove(name);
        self.analog_released_frames.remove(name);
    }
}

/// Registry coordinating exclusive and explicitly shared physical device assignments.
#[derive(Debug, Default)]
pub struct PlayerInputRegistry {
    next_context_id: u64,
    keyboard_owners: BTreeMap<u64, bool>,
    gamepad_owners: HashMap<usize, BTreeMap<u64, bool>>,
}

impl PlayerInputRegistry {
    /// Allocates a non-reused context id.
    pub fn allocate_context_id(&mut self) -> Result<u64, String> {
        self.next_context_id = self
            .next_context_id
            .checked_add(1)
            .ok_or_else(|| "player input context id space exhausted".to_string())?;
        Ok(self.next_context_id)
    }

    /// Claims keyboard and mouse ownership for a context.
    pub fn assign_keyboard(&mut self, context_id: u64, shared: bool) -> Result<(), String> {
        claim_device(
            &mut self.keyboard_owners,
            context_id,
            shared,
            "keyboard/mouse",
        )
    }

    /// Releases keyboard and mouse ownership for a context.
    pub fn unassign_keyboard(&mut self, context_id: u64) {
        self.keyboard_owners.remove(&context_id);
    }

    /// Claims one persistent gamepad slot for a context.
    pub fn assign_gamepad(
        &mut self,
        context_id: u64,
        gamepad_id: usize,
        shared: bool,
    ) -> Result<(), String> {
        claim_device(
            self.gamepad_owners.entry(gamepad_id).or_default(),
            context_id,
            shared,
            &format!("gamepad {gamepad_id}"),
        )
    }

    /// Releases one gamepad slot for a context.
    pub fn unassign_gamepad(&mut self, context_id: u64, gamepad_id: usize) {
        if let Some(owners) = self.gamepad_owners.get_mut(&gamepad_id) {
            owners.remove(&context_id);
            if owners.is_empty() {
                self.gamepad_owners.remove(&gamepad_id);
            }
        }
    }

    /// Releases every device held by a context.
    pub fn release_context(&mut self, context_id: u64) {
        self.keyboard_owners.remove(&context_id);
        self.gamepad_owners.retain(|_, owners| {
            owners.remove(&context_id);
            !owners.is_empty()
        });
    }
}

fn claim_device(
    owners: &mut BTreeMap<u64, bool>,
    context_id: u64,
    shared: bool,
    label: &str,
) -> Result<(), String> {
    if let Some(existing_shared) = owners.get(&context_id) {
        if *existing_shared == shared {
            return Ok(());
        }
        if owners.len() > 1 && !shared {
            return Err(format!(
                "{label} is already shared with another player context"
            ));
        }
        owners.insert(context_id, shared);
        return Ok(());
    }
    if !owners.is_empty() && (!shared || owners.values().any(|owner_shared| !owner_shared)) {
        return Err(format!(
            "{label} is already assigned; use opts.shared = true on every owner to share it"
        ));
    }
    owners.insert(context_id, shared);
    Ok(())
}

fn validate_action_name(name: &str) -> Result<(), String> {
    let trimmed = name.trim();
    if trimmed.is_empty() {
        return Err("action name must not be empty".to_string());
    }
    if trimmed.len() > 128 {
        return Err("action name must not exceed 128 bytes".to_string());
    }
    Ok(())
}
