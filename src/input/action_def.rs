//! Owns input behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around InputBinding, parse, to_canonical_string, with helpers kept close to their invariants.
//! Defines how action def data is validated, transformed, or stored before neighboring systems use it.
//! Owns input behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on action def behavior while Lua registration stays elsewhere.

use super::keyboard::get_key_from_scancode;
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};

/// Typed input binding variants recognized by the action-binding parser.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum InputBinding {
    /// Layout-aware logical keyboard key name.
    KeyboardKey(String),
    /// Physical keyboard scancode identifier.
    Scancode(String),
    /// One-based mouse button index.
    MouseButton(u16),
    /// Gamepad button binding in `gamepad:id:button` form.
    GamepadButton { gamepad_id: usize, button: u32 },
    /// Standard named gamepad button with an optional fixed slot or player assignment.
    GamepadNamed {
        /// Optional fixed gamepad slot; `None` means any connected gamepad.
        gamepad_id: Option<usize>,
        /// Optional assigned player number.
        player: Option<u32>,
        /// Standard button name such as `a` or `dpad_up`.
        button: String,
    },
    /// Reserved gamepad axis binding.
    GamepadAxis { gamepad_id: usize, axis: String },
    /// Reserved touch gesture binding.
    TouchGesture(String),
}

impl InputBinding {
    /// Parse a binding string into a typed input binding with canonicalized fields.
    pub fn parse(raw: &str) -> Result<Self, String> {
        let trimmed = raw.trim();
        if trimmed.is_empty() {
            return Err("binding must not be empty".to_string());
        }
        let lowered = trimmed.to_ascii_lowercase();
        if let Some(rest) = lowered.strip_prefix("gamepad:any:") {
            if crate::input::standard_button_code(rest).is_some() {
                return Ok(Self::GamepadNamed {
                    gamepad_id: None,
                    player: None,
                    button: rest.to_string(),
                });
            }
            return Err("gamepad:any binding requires a standard button name".to_string());
        }
        if let Some(rest) = lowered.strip_prefix("gamepad:p") {
            let (player, button) = rest
                .split_once(':')
                .ok_or_else(|| "gamepad player binding must be in gamepad:pN:button form".to_string())?;
            let player = player
                .parse::<u32>()
                .map_err(|_| "gamepad player must be a positive integer".to_string())?;
            if player == 0 || crate::input::standard_button_code(button).is_none() {
                return Err("gamepad player binding requires a positive player and standard button name".to_string());
            }
            return Ok(Self::GamepadNamed {
                gamepad_id: None,
                player: Some(player),
                button: button.to_string(),
            });
        }
        if let Some(rest) = lowered.strip_prefix("gamepad:") {
            let mut parts = rest.split(':');
            let gamepad_id = parts
                .next()
                .ok_or_else(|| "gamepad binding missing id".to_string())?
                .parse::<usize>()
                .map_err(|_| "gamepad binding id must be a non-negative integer".to_string())?;
            let button = parts
                .next()
                .ok_or_else(|| "gamepad binding missing button".to_string())?
                .to_string();
            if parts.next().is_some() {
                return Err("gamepad binding must be in gamepad:id:button form".to_string());
            }
            if let Ok(button) = button.parse::<u32>() {
                return Ok(Self::GamepadButton { gamepad_id, button });
            }
            if crate::input::standard_button_code(&button).is_some() {
                return Ok(Self::GamepadNamed {
                    gamepad_id: Some(gamepad_id),
                    player: None,
                    button,
                });
            }
            return Err("gamepad binding button must be an integer or standard button name".to_string());
        }
        if let Some(rest) = lowered.strip_prefix("gamepadaxis:") {
            let mut parts = rest.split(':');
            let gamepad_id = parts
                .next()
                .ok_or_else(|| "gamepadaxis binding missing id".to_string())?
                .parse::<usize>()
                .map_err(|_| "gamepadaxis binding id must be a non-negative integer".to_string())?;
            let axis = parts
                .next()
                .ok_or_else(|| "gamepadaxis binding missing axis".to_string())?;
            if axis.is_empty() || parts.next().is_some() {
                return Err("gamepadaxis binding must be in gamepadaxis:id:axis form".to_string());
            }
            return Ok(Self::GamepadAxis {
                gamepad_id,
                axis: axis.to_string(),
            });
        }
        if let Some(rest) = lowered.strip_prefix("touch:") {
            if rest.is_empty() {
                return Err("touch binding must be in touch:gesture form".to_string());
            }
            return Ok(Self::TouchGesture(rest.to_string()));
        }
        if let Some(button_text) = lowered.strip_prefix("mouse") {
            let button = button_text
                .parse::<u16>()
                .map_err(|_| "mouse binding button must be a positive integer".to_string())?;
            if button == 0 {
                return Err("mouse binding button must be at least 1".to_string());
            }
            return Ok(Self::MouseButton(button));
        }
        if get_key_from_scancode(&lowered).is_some() {
            return Ok(Self::Scancode(lowered));
        }
        Ok(Self::KeyboardKey(canonicalize_key_name(&lowered)))
    }

    /// Return the canonical string representation stored in action maps and JSON.
    pub fn to_canonical_string(&self) -> String {
        match self {
            Self::KeyboardKey(key) => key.clone(),
            Self::Scancode(scancode) => scancode.clone(),
            Self::MouseButton(button) => format!("mouse{button}"),
            Self::GamepadButton { gamepad_id, button } => format!("gamepad:{gamepad_id}:{button}"),
            Self::GamepadNamed {
                gamepad_id,
                player,
                button,
            } => match (gamepad_id, player) {
                (Some(id), _) => format!("gamepad:{id}:{button}"),
                (_, Some(player)) => format!("gamepad:p{player}:{button}"),
                _ => format!("gamepad:any:{button}"),
            },
            Self::GamepadAxis { gamepad_id, axis } => format!("gamepadaxis:{gamepad_id}:{axis}"),
            Self::TouchGesture(gesture) => format!("touch:{gesture}"),
        }
    }

    /// Return whether the binding kind can currently drive action state queries.
    pub fn supports_action_queries(&self) -> bool {
        matches!(
            self,
            Self::KeyboardKey(_)
                | Self::Scancode(_)
                | Self::MouseButton(_)
                | Self::GamepadButton { .. }
                | Self::GamepadNamed { .. }
        )
    }
}

/// Canonicalize one logical key identifier without rejecting engine-specific names.
pub fn canonicalize_key_name(raw: &str) -> String {
    match raw.trim().to_ascii_lowercase().as_str() {
        "control" => "ctrl".to_string(),
        "enter" => "return".to_string(),
        "esc" => "escape".to_string(),
        "gui" => "super".to_string(),
        other => other.to_string(),
    }
}

/// Parse, validate, canonicalize, and de-duplicate action bindings while preserving order.
pub fn canonicalize_action_bindings(bindings: Vec<String>) -> Result<Vec<String>, String> {
    let mut seen = HashSet::new();
    let mut out = Vec::new();
    for binding in bindings {
        if let Some(canonical) = canonicalize_expression(&binding)? {
            if seen.insert(canonical.clone()) {
                out.push(canonical);
            }
            continue;
        }
        let parsed = InputBinding::parse(&binding)?;
        if !parsed.supports_action_queries() {
            return Err(format!(
                "binding '{}' uses a reserved binding kind that action queries do not support yet",
                binding.trim()
            ));
        }
        let canonical = parsed.to_canonical_string();
        if seen.insert(canonical.clone()) {
            out.push(canonical);
        }
    }
    Ok(out)
}

/// Extended action definition with ordered binding strings and a grouping category.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ActionDef {
    /// Binding strings such as `"space"` or `"gamepad:0:1"`.
    pub bindings: Vec<String>,
    /// User category for grouping actions; empty string when uncategorised.
    pub category: String,
    /// Input context controlling whether this action participates in polling.
    #[serde(default = "default_action_context")]
    pub context: String,
}

/// Canonicalize the serialized binding expressions used by the Lua API.
///
/// Expressions intentionally remain strings in persisted action maps so version-1 maps continue
/// to deserialize unchanged.  Their reserved prefixes make them unambiguous from key names.
fn canonicalize_expression(binding: &str) -> Result<Option<String>, String> {
    let mut parts = binding.split('|');
    match parts.next() {
        Some("chord") => {
            let within_ms = parts
                .next()
                .ok_or_else(|| "chord binding is missing within_ms".to_string())?
                .parse::<u64>()
                .map_err(|_| "chord binding has invalid within_ms".to_string())?;
            let mut keys = Vec::new();
            for key in parts {
                let parsed = InputBinding::parse(key)?;
                if !parsed.supports_action_queries() {
                    return Err("chord members must be pollable bindings".to_string());
                }
                keys.push(parsed.to_canonical_string());
            }
            if keys.len() < 2 {
                return Err("chord binding requires at least two members".to_string());
            }
            Ok(Some(format!("chord|{within_ms}|{}", keys.join("|"))))
        }
        Some("axis") => {
            let axis = parts
                .next()
                .ok_or_else(|| "axis binding is missing axis".to_string())?;
            let threshold = parts
                .next()
                .ok_or_else(|| "axis binding is missing threshold".to_string())?
                .parse::<f32>()
                .map_err(|_| "axis binding has invalid threshold".to_string())?;
            let direction = parts
                .next()
                .ok_or_else(|| "axis binding is missing direction".to_string())?;
            if parts.next().is_some()
                || !threshold.is_finite()
                || !(0.0..=1.0).contains(&threshold)
                || !matches!(direction, "positive" | "negative")
                || !axis.starts_with("gamepad:")
            {
                return Err("axis binding is invalid".to_string());
            }
            Ok(Some(format!("axis|{}|{}|{}", axis.to_ascii_lowercase(), threshold, direction)))
        }
        _ => Ok(None),
    }
}

fn default_action_context() -> String {
    "gameplay".to_string()
}

impl ActionDef {
    /// Creates an action definition with the given bindings and category.
    pub fn new(bindings: Vec<String>, category: String, context: String) -> Result<Self, String> {
        Ok(Self {
            bindings: canonicalize_action_bindings(bindings)?,
            category,
            context: if context.trim().is_empty() {
                default_action_context()
            } else {
                context
            },
        })
    }

    /// Re-validate and canonicalize bindings after deserializing raw JSON data.
    pub fn canonicalize(mut self) -> Result<Self, String> {
        self.bindings = canonicalize_action_bindings(self.bindings)?;
        Ok(self)
    }
}

impl Default for ActionDef {
    /// Returns an empty action definition with no bindings and no category.
    fn default() -> Self {
        Self {
            bindings: Vec::new(),
            category: String::new(),
            context: default_action_context(),
        }
    }
}

/// Full action map from action name to its extended definition.
pub type ActionMap = HashMap<String, ActionDef>;
