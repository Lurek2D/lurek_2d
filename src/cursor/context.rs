//! Context-sensitive cursor switching: maps named contexts to cursor states.
//!
//! - `CursorContext` holds a registry of context-name → `CursorState` mappings.
//! - `CursorState` discriminates between system, custom, and animated cursor kinds.
//! - Context names are arbitrary strings set by game scripts (e.g. `"dialog"`, `"combat"`).
//! - The active context is applied immediately; fallback is the default system cursor.

use super::animated_cursor::AnimatedCursor;
use super::custom_cursor::CustomCursor;
use super::system_cursor::SystemCursor;
use super::trail::CursorTrail;
use super::zoom::CursorZoom;

/// Active cursor state: the currently displayed cursor kind (system, custom, or animated).
#[derive(Debug, Clone)]
pub enum CursorState {
    System(SystemCursor),
    Custom(CustomCursor),
    Animated(AnimatedCursor),
}

/// Context that determines which cursor to show.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum CursorContext {
    Default,
    Raycaster,
    Globe,
    TileMap,
    UiButton,
    UiInput,
    UiResize,
    Custom(String),
}

impl CursorContext {
    /// Parse a `CursorContext` variant from a lowercase string name.
    pub fn from_name(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "default" => Self::Default,
            "raycaster" => Self::Raycaster,
            "globe" => Self::Globe,
            "tilemap" => Self::TileMap,
            "ui_button" | "button" => Self::UiButton,
            "ui_input" | "input" => Self::UiInput,
            "ui_resize" | "resize" => Self::UiResize,
            other => Self::Custom(other.to_string()),
        }
    }

    /// Return the canonical string representation of this context.
    pub fn as_str(&self) -> &str {
        match self {
            Self::Default => "default",
            Self::Raycaster => "raycaster",
            Self::Globe => "globe",
            Self::TileMap => "tilemap",
            Self::UiButton => "ui_button",
            Self::UiInput => "ui_input",
            Self::UiResize => "ui_resize",
            Self::Custom(s) => s.as_str(),
        }
    }
}

/// Rule mapping a context to a cursor state.
#[derive(Debug, Clone)]
pub struct ContextRule {
    /// Active cursor context name.
    pub context: CursorContext,
    /// Cursor assigned to this context entry.
    pub cursor: CursorState,
}

/// Manages cursor state, context rules, trail, and zoom.
#[derive(Debug)]
pub struct CursorManager {
    active: CursorState,
    current_context: CursorContext,
    rules: Vec<ContextRule>,
    trail: Option<CursorTrail>,
    zoom: Option<CursorZoom>,
    visible: bool,
    locked: bool,
    position: (f32, f32),
}

impl CursorManager {
    /// Create a new `CursorManager` with default system arrow cursor and no rules.
    pub fn new() -> Self {
        Self {
            active: CursorState::System(SystemCursor::Arrow),
            current_context: CursorContext::Default,
            rules: Vec::new(),
            trail: None,
            zoom: None,
            visible: true,
            locked: false,
            position: (0.0, 0.0),
        }
    }

    /// Switch the active cursor to an OS system cursor shape.
    pub fn set_system(&mut self, cursor: SystemCursor) {
        self.active = CursorState::System(cursor);
    }

    /// Switch the active cursor to a custom RGBA image cursor.
    pub fn set_custom(&mut self, cursor: CustomCursor) {
        self.active = CursorState::Custom(cursor);
    }

    /// Switch the active cursor to an animated frame cursor.
    pub fn set_animated(&mut self, cursor: AnimatedCursor) {
        self.active = CursorState::Animated(cursor);
    }

    /// Activate the named context, applying its registered cursor rule if one exists.
    pub fn set_context(&mut self, ctx: CursorContext) {
        if ctx == self.current_context {
            return;
        }
        self.current_context = ctx.clone();
        for rule in &self.rules {
            if rule.context == ctx {
                self.active = rule.cursor.clone();
                return;
            }
        }
    }

    /// Register a context-to-cursor rule; replaces any existing rule for the same context.
    pub fn add_rule(&mut self, rule: ContextRule) {
        // Replace existing rule for same context
        if let Some(existing) = self.rules.iter_mut().find(|r| r.context == rule.context) {
            existing.cursor = rule.cursor;
        } else {
            self.rules.push(rule);
        }
    }

    /// Remove the rule associated with the given context, if any.
    pub fn remove_rule(&mut self, ctx: &CursorContext) {
        self.rules.retain(|r| &r.context != ctx);
    }

    /// Tick cursor state: record the new screen position, advance animated frames, and update the trail.
    pub fn update(&mut self, x: f32, y: f32, dt: f32) {
        self.position = (x, y);

        if let CursorState::Animated(ref mut anim) = self.active {
            anim.update(dt);
        }

        if let Some(ref mut trail) = self.trail {
            trail.update(x, y, dt);
        }
    }

    /// Attach or clear the cursor trail effect.
    pub fn set_trail(&mut self, trail: Option<CursorTrail>) {
        self.trail = trail;
    }

    /// Return a shared reference to the cursor trail, if one is attached.
    pub fn trail(&self) -> Option<&CursorTrail> {
        self.trail.as_ref()
    }

    /// Return a mutable reference to the cursor trail, if one is attached.
    pub fn trail_mut(&mut self) -> Option<&mut CursorTrail> {
        self.trail.as_mut()
    }

    /// Attach or clear the magnifying zoom lens overlay.
    pub fn set_zoom(&mut self, zoom: Option<CursorZoom>) {
        self.zoom = zoom;
    }

    /// Return a shared reference to the zoom lens, if one is attached.
    pub fn zoom(&self) -> Option<&CursorZoom> {
        self.zoom.as_ref()
    }

    /// Show or hide the hardware cursor.
    pub fn set_visible(&mut self, visible: bool) {
        self.visible = visible;
    }

    /// Return `true` if the cursor is currently visible.
    pub fn is_visible(&self) -> bool {
        self.visible
    }

    /// Lock or unlock the cursor to the window center (e.g., for FPS-style camera).
    pub fn set_locked(&mut self, locked: bool) {
        self.locked = locked;
    }

    /// Return `true` if the cursor is locked to the window center.
    pub fn is_locked(&self) -> bool {
        self.locked
    }

    /// Return the currently active cursor state.
    pub fn active(&self) -> &CursorState {
        &self.active
    }

    /// Return the current cursor screen position as `(x, y)` in pixels.
    pub fn position(&self) -> (f32, f32) {
        self.position
    }

    /// Return the active `CursorContext` that determines the current cursor appearance.
    pub fn context(&self) -> &CursorContext {
        &self.current_context
    }
}

impl Default for CursorManager {
    fn default() -> Self {
        Self::new()
    }
}
