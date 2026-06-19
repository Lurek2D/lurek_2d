//! This file owns `ActionDef` and `ActionMap`, the serializable action-binding data used by the input system.
//! It stores ordered binding strings and optional category labels so menus and tools can group logical actions.
//! Open this file when binding schema changes; live device polling and combo logic live in sibling modules.

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
    MouseButton(u8),
    /// Gamepad button binding in `gamepad:id:button` form.
    GamepadButton { gamepad_id: usize, button: u32 },
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
                .parse::<u32>()
                .map_err(|_| "gamepad binding button must be an integer".to_string())?;
            if parts.next().is_some() {
                return Err("gamepad binding must be in gamepad:id:button form".to_string());
            }
            return Ok(Self::GamepadButton { gamepad_id, button });
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
                .parse::<u8>()
                .map_err(|_| "mouse binding button must be an integer from 1 to 5".to_string())?;
            if !(1..=5).contains(&button) {
                return Err("mouse binding button must be in the range 1..=5".to_string());
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
}

impl ActionDef {
    /// Creates an action definition with the given bindings and category.
    pub fn new(bindings: Vec<String>, category: String) -> Result<Self, String> {
        Ok(Self {
            bindings: canonicalize_action_bindings(bindings)?,
            category,
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
        }
    }
}

/// Full action map from action name to its extended definition.
pub type ActionMap = HashMap<String, ActionDef>;
