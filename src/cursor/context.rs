//! `src/cursor/context.rs` owns context-sensitive cursor selection plus the manager that combines cursor, trail, and zoom.
//! It defines `CursorState`, `CursorContext`, `ContextRule`, and `CursorManager`, keeping cursor policy state together.
//! Rule registration, context switching, visibility, locking, active-position tracking, and animated updates live here.
//! Trail and zoom attachment also live here, making this file the owner of composed runtime cursor presentation state.
//! This is the policy boundary for script-driven cursor changes; image buffers and effect internals stay in sibling files.
//! Read it when context mapping, active-state transitions, or cursor-manager behavior needs to change.

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
    default_cursor: CursorState,
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
        let default_cursor = CursorState::System(SystemCursor::Arrow);
        Self {
            active: default_cursor.clone(),
            default_cursor,
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
        let state = CursorState::System(cursor);
        self.default_cursor = state.clone();
        self.active = state;
    }

    /// Switch the active cursor to a custom RGBA image cursor.
    pub fn set_custom(&mut self, cursor: CustomCursor) {
        let state = CursorState::Custom(cursor);
        self.default_cursor = state.clone();
        self.active = state;
    }

    /// Switch the active cursor to an animated frame cursor.
    pub fn set_animated(&mut self, cursor: AnimatedCursor) {
        let state = CursorState::Animated(cursor);
        self.default_cursor = state.clone();
        self.active = state;
    }

    fn apply_context_cursor(&mut self) {
        self.active = self
            .rules
            .iter()
            .find(|rule| rule.context == self.current_context)
            .map(|rule| rule.cursor.clone())
            .unwrap_or_else(|| self.default_cursor.clone());
    }

    /// Activate the named context, applying its registered cursor rule if one exists.
    pub fn set_context(&mut self, ctx: CursorContext) {
        self.current_context = ctx;
        self.apply_context_cursor();
    }

    /// Register a context-to-cursor rule; replaces any existing rule for the same context.
    pub fn add_rule(&mut self, rule: ContextRule) {
        let touched_current = rule.context == self.current_context;
        // Replace existing rule for same context
        if let Some(existing) = self.rules.iter_mut().find(|r| r.context == rule.context) {
            existing.cursor = rule.cursor;
        } else {
            self.rules.push(rule);
        }
        if touched_current {
            self.apply_context_cursor();
        }
    }

    /// Remove the rule associated with the given context, if any.
    pub fn remove_rule(&mut self, ctx: &CursorContext) {
        self.rules.retain(|r| &r.context != ctx);
        if &self.current_context == ctx {
            self.apply_context_cursor();
        }
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
