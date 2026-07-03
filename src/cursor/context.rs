//! `src/cursor/context.rs` owns the active runtime cursor controller used by Lua, input, and render glue.
//! It defines cursor states, normalized hover hits, rules, sources, effects, and the manager that resolves them.
//! Legacy context switching stays supported, but the same owner now also handles hover-driven state changes.
//! Rule evaluation here chooses between system, custom, and animated cursors before overlay rendering happens.
//! Hover hits from globe, raycaster, or callbacks are normalized here so one resolver can handle every source.
//! Burst effects, trail presets, timed overrides, and zoom-lens state all live in this shared cursor owner.
//! The manager keeps last-hit metadata and active-state snapshots available to Lua without duplicating policy.
//! Input-facing structs in this file translate button, release, and wheel state into cursor-local reactions.
//! Open this file when cursor policy, source matching, or per-frame state resolution semantics need to change.
//! Open this file when cursor rule resolution, source polling contracts, or overlay-state behavior changes.

use super::animated_cursor::AnimatedCursor;
use super::custom_cursor::CustomCursor;
use super::system_cursor::SystemCursor;
use super::trail::CursorTrail;
use super::zoom::CursorZoom;
use crate::globe::registry::GlobeRegistry;
use crate::render::renderer::{BlendMode, ParticleRenderShape};
use crate::runtime::resource_keys::{ShaderKey, TextureKey};
use mlua::RegistryKey as LuaRegistryKey;
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

/// Active cursor state: the currently displayed cursor kind.
#[derive(Debug, Clone)]
pub enum CursorState {
    System(SystemCursor),
    Custom(CustomCursor),
    Animated(AnimatedCursor),
}

impl CursorState {
    /// Return the stable kind string for this state.
    pub fn kind_name(&self) -> &'static str {
        match self {
            Self::System(_) => "system",
            Self::Custom(_) => "custom",
            Self::Animated(_) => "animated",
        }
    }
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
    /// Parse a `CursorContext` variant from a string name.
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

/// Rule mapping a legacy context to one cursor state.
#[derive(Debug, Clone)]
pub struct ContextRule {
    pub context: CursorContext,
    pub cursor: CursorState,
}

/// One named cursor state definition used by the runtime rule engine.
#[derive(Debug, Clone)]
pub struct CursorStateSpec {
    pub state: CursorState,
    pub scale: f32,
    pub offset_x: f32,
    pub offset_y: f32,
    pub native_preferred: bool,
    pub trail: Option<CursorTrail>,
    pub zoom: Option<CursorZoom>,
}

impl CursorStateSpec {
    /// Build a state spec from one raw cursor state.
    pub fn from_state(state: CursorState) -> Self {
        Self {
            state,
            scale: 1.0,
            offset_x: 0.0,
            offset_y: 0.0,
            native_preferred: true,
            trail: None,
            zoom: None,
        }
    }
}

/// Normalized hover hit shared by globe, raycaster, and future cursor sources.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CursorHit {
    pub module_name: String,
    pub kind: String,
    pub surface: String,
    pub id: Option<String>,
    pub attrs: HashMap<String, String>,
    pub context: Option<String>,
}

/// Rule target matcher for one hover hit.
#[derive(Debug, Clone, Default)]
pub struct CursorRuleTarget {
    pub module_name: Option<String>,
    pub kind: Option<String>,
    pub surface: Option<String>,
    pub id: Option<String>,
    pub attrs: HashMap<String, String>,
}

impl CursorRuleTarget {
    /// Return true when `hit` satisfies this target filter.
    pub fn matches(&self, hit: &CursorHit) -> bool {
        if let Some(module_name) = &self.module_name {
            if !module_name.eq_ignore_ascii_case(&hit.module_name) {
                return false;
            }
        }
        if let Some(kind) = &self.kind {
            if !kind.eq_ignore_ascii_case(&hit.kind) {
                return false;
            }
        }
        if let Some(surface) = &self.surface {
            if !surface.eq_ignore_ascii_case(&hit.surface) {
                return false;
            }
        }
        if let Some(id) = &self.id {
            if hit.id.as_deref() != Some(id.as_str()) {
                return false;
            }
        }
        for (key, value) in &self.attrs {
            if hit.attrs.get(key) != Some(value) {
                return false;
            }
        }
        true
    }
}

/// Cursor rule event class.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CursorRuleEvent {
    Context,
    Hover,
    Leave,
    Click,
    Release,
    Wheel,
}

/// Flexible state/effect rule used by the runtime resolver.
#[derive(Debug, Clone)]
pub struct CursorRule {
    pub id: usize,
    pub priority: i32,
    pub event: CursorRuleEvent,
    pub context: Option<CursorContext>,
    pub target: Option<CursorRuleTarget>,
    pub state: Option<String>,
    pub effect: Option<String>,
    pub duration_ms: u32,
    pub inline_state: Option<CursorStateSpec>,
}

/// One cursor-managed effect preset.
#[derive(Debug, Clone)]
pub struct CursorEffectSpec {
    pub shape: ParticleRenderShape,
    pub color: [f32; 4],
    pub texture_key: Option<TextureKey>,
    pub shader_key: Option<ShaderKey>,
    pub count: u32,
    pub spread: f32,
    pub lifetime: f32,
    pub speed: f32,
    pub size: f32,
    pub blend: BlendMode,
    pub button_filter: Option<usize>,
}

impl Default for CursorEffectSpec {
    fn default() -> Self {
        Self {
            shape: ParticleRenderShape::Spark,
            color: [1.0, 1.0, 1.0, 1.0],
            texture_key: None,
            shader_key: None,
            count: 12,
            spread: std::f32::consts::TAU,
            lifetime: 0.28,
            speed: 96.0,
            size: 5.0,
            blend: BlendMode::Add,
            button_filter: None,
        }
    }
}

/// Runtime cursor effect instance spawned by a matching rule.
#[derive(Debug, Clone)]
pub struct CursorBurstInstance {
    pub effect: CursorEffectSpec,
    pub x: f32,
    pub y: f32,
    pub age: f32,
    pub seed: u32,
}

impl CursorBurstInstance {
    fn is_alive(&self) -> bool {
        self.age < self.effect.lifetime.max(0.001)
    }
}

/// One registered cursor source.
pub enum CursorSource {
    Globe {
        id: usize,
        registry: Arc<Mutex<GlobeRegistry>>,
        name: String,
        marker_radius: f32,
    },
    RaycasterLast {
        id: usize,
    },
    Callback {
        id: usize,
        callback: LuaRegistryKey,
    },
}

impl CursorSource {
    /// Return the stable integer source id.
    pub fn id(&self) -> usize {
        match self {
            Self::Globe { id, .. } | Self::RaycasterLast { id } | Self::Callback { id, .. } => *id,
        }
    }
}

#[derive(Debug, Clone, Copy)]
struct CursorTimedOverride {
    rule_id: usize,
    until_ms: f32,
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum CursorAttachmentOwner {
    Manual,
    State(String),
}

/// Snapshot of mouse state consumed by the cursor runtime on one frame.
#[derive(Debug, Clone, Copy)]
pub struct CursorInputFrame {
    pub buttons: [bool; 5],
    pub buttons_pressed: [bool; 5],
    pub buttons_released: [bool; 5],
    pub scroll_x: f32,
    pub scroll_y: f32,
}

impl Default for CursorInputFrame {
    fn default() -> Self {
        Self {
            buttons: [false; 5],
            buttons_pressed: [false; 5],
            buttons_released: [false; 5],
            scroll_x: 0.0,
            scroll_y: 0.0,
        }
    }
}

/// Lightweight description of the resolved active cursor state.
#[derive(Debug, Clone)]
pub struct CursorActiveStateInfo {
    pub name: Option<String>,
    pub kind: String,
    pub native_preferred: bool,
    pub scale: f32,
    pub offset_x: f32,
    pub offset_y: f32,
}

/// One active runtime cursor controller shared by the whole frame.
pub struct CursorManager {
    active: CursorState,
    active_visual: CursorStateSpec,
    active_token: String,
    active_named_state: Option<String>,
    default_cursor: CursorState,
    current_context: CursorContext,
    rules: Vec<CursorRule>,
    states: HashMap<String, CursorStateSpec>,
    effects: HashMap<String, CursorEffectSpec>,
    sources: Vec<CursorSource>,
    trail: Option<CursorTrail>,
    trail_owner: CursorAttachmentOwner,
    zoom: Option<CursorZoom>,
    zoom_owner: CursorAttachmentOwner,
    visible: bool,
    locked: bool,
    position: (f32, f32),
    last_hit: Option<CursorHit>,
    previous_hit: Option<CursorHit>,
    next_rule_id: usize,
    next_source_id: usize,
    last_buttons: [bool; 5],
    timed_override: Option<CursorTimedOverride>,
    bursts: Vec<CursorBurstInstance>,
    time_ms: f32,
    effect_serial: u32,
}

impl CursorManager {
    /// Create a new cursor manager with default arrow cursor.
    pub fn new() -> Self {
        let default_cursor = CursorState::System(SystemCursor::Arrow);
        Self {
            active: default_cursor.clone(),
            active_visual: CursorStateSpec::from_state(default_cursor.clone()),
            active_token: "__default__".to_string(),
            active_named_state: None,
            default_cursor: default_cursor.clone(),
            current_context: CursorContext::Default,
            rules: Vec::new(),
            states: HashMap::new(),
            effects: HashMap::new(),
            sources: Vec::new(),
            trail: None,
            trail_owner: CursorAttachmentOwner::Manual,
            zoom: None,
            zoom_owner: CursorAttachmentOwner::Manual,
            visible: true,
            locked: false,
            position: (0.0, 0.0),
            last_hit: None,
            previous_hit: None,
            next_rule_id: 1,
            next_source_id: 1,
            last_buttons: [false; 5],
            timed_override: None,
            bursts: Vec::new(),
            time_ms: 0.0,
            effect_serial: 1,
        }
    }

    /// Switch the default cursor to one OS system cursor.
    pub fn set_system(&mut self, cursor: SystemCursor) {
        self.default_cursor = CursorState::System(cursor);
        self.refresh_runtime_selection();
    }

    /// Switch the default cursor to one custom cursor.
    pub fn set_custom(&mut self, cursor: CustomCursor) {
        self.default_cursor = CursorState::Custom(cursor);
        self.refresh_runtime_selection();
    }

    /// Switch the default cursor to one animated cursor.
    pub fn set_animated(&mut self, cursor: AnimatedCursor) {
        self.default_cursor = CursorState::Animated(cursor);
        self.refresh_runtime_selection();
    }

    fn resolve_static_state(&mut self) {
        let default_spec = CursorStateSpec::from_state(self.default_cursor.clone());
        self.active = default_spec.state.clone();
        self.active_visual = default_spec;
        self.active_token = "__default__".to_string();
        self.active_named_state = None;
    }

    /// Define or replace one named runtime state.
    pub fn define_state(&mut self, name: impl Into<String>, spec: CursorStateSpec) {
        self.states.insert(name.into(), spec);
        self.refresh_runtime_selection();
    }

    /// Define or replace one named cursor effect.
    pub fn define_effect(&mut self, name: impl Into<String>, spec: CursorEffectSpec) {
        self.effects.insert(name.into(), spec);
    }

    /// Activate the named context.
    pub fn set_context(&mut self, ctx: CursorContext) {
        self.current_context = ctx;
        self.refresh_runtime_selection();
    }

    /// Register a legacy context rule.
    pub fn add_rule(&mut self, rule: ContextRule) {
        let token = format!("__legacy_ctx_{}__", rule.context.as_str());
        let rule_id = self.next_rule_id();
        self.rules
            .retain(|existing| existing.state.as_deref() != Some(token.as_str()));
        self.rules.push(CursorRule {
            id: rule_id,
            priority: 0,
            event: CursorRuleEvent::Context,
            context: Some(rule.context),
            target: None,
            state: Some(token),
            effect: None,
            duration_ms: 0,
            inline_state: Some(CursorStateSpec::from_state(rule.cursor)),
        });
        self.refresh_runtime_selection();
    }

    /// Register a flexible v2 rule and return its id.
    pub fn add_rule_v2(&mut self, mut rule: CursorRule) -> usize {
        if rule.id == 0 {
            rule.id = self.next_rule_id();
        }
        let id = rule.id;
        self.rules.push(rule);
        self.refresh_runtime_selection();
        id
    }

    /// Remove every legacy context rule matching `ctx`.
    pub fn remove_rule(&mut self, ctx: &CursorContext) {
        self.rules.retain(|rule| {
            !(rule.event == CursorRuleEvent::Context
                && rule.target.is_none()
                && rule.context.as_ref() == Some(ctx))
        });
        self.refresh_runtime_selection();
    }

    /// Register a new hover source and return its id.
    pub fn add_source(&mut self, source: CursorSource) -> usize {
        let id = source.id();
        self.sources.push(source);
        id
    }

    /// Reserve a fresh source id for Lua-side source creation.
    pub fn next_source_id(&mut self) -> usize {
        let id = self.next_source_id;
        self.next_source_id = self.next_source_id.saturating_add(1);
        id
    }

    fn next_rule_id(&mut self) -> usize {
        let id = self.next_rule_id;
        self.next_rule_id = self.next_rule_id.saturating_add(1);
        id
    }

    /// Remove one registered hover source by id.
    pub fn remove_source(&mut self, id: usize) -> bool {
        let old_len = self.sources.len();
        self.sources.retain(|source| source.id() != id);
        old_len != self.sources.len()
    }

    /// Return every registered source.
    pub fn sources(&self) -> &[CursorSource] {
        &self.sources
    }

    /// Move all registered sources out of the runtime.
    pub fn take_sources(&mut self) -> Vec<CursorSource> {
        std::mem::take(&mut self.sources)
    }

    /// Replace all registered sources after external polling.
    pub fn replace_sources(&mut self, sources: Vec<CursorSource>) {
        self.sources = sources;
    }

    /// Return the last normalized hover hit.
    pub fn get_last_hit(&self) -> Option<&CursorHit> {
        self.last_hit.as_ref()
    }

    /// Return the resolved active state info.
    pub fn get_active_state(&self) -> CursorActiveStateInfo {
        CursorActiveStateInfo {
            name: self.active_named_state.clone(),
            kind: self.active.kind_name().to_string(),
            native_preferred: self.active_visual.native_preferred,
            scale: self.active_visual.scale,
            offset_x: self.active_visual.offset_x,
            offset_y: self.active_visual.offset_y,
        }
    }

    /// Tick the runtime cursor from one frame of input and one resolved hover hit.
    pub fn tick(
        &mut self,
        x: f32,
        y: f32,
        dt: f32,
        input: CursorInputFrame,
        hit: Option<CursorHit>,
    ) {
        self.position = (x, y);
        self.time_ms += (dt.max(0.0)) * 1000.0;
        self.previous_hit = self.last_hit.clone();
        self.last_hit = hit;

        let derived_pressed = std::array::from_fn(|index| {
            input.buttons_pressed[index] || (input.buttons[index] && !self.last_buttons[index])
        });
        let derived_released = std::array::from_fn(|index| {
            input.buttons_released[index] || (!input.buttons[index] && self.last_buttons[index])
        });
        let wheel_active =
            input.scroll_x.abs() > f32::EPSILON || input.scroll_y.abs() > f32::EPSILON;
        let hover_active = self.last_hit.is_some();
        let hover_enter = self.last_hit.is_some() && self.last_hit != self.previous_hit;
        let leave_active = self.previous_hit.is_some() && self.last_hit.is_none();

        if let Some(timed) = self.timed_override {
            if self.time_ms >= timed.until_ms {
                self.timed_override = None;
            }
        }

        for rule in self.rules.clone() {
            if !self.rule_matches(
                &rule,
                &derived_pressed,
                &derived_released,
                wheel_active,
                hover_active,
                leave_active,
            ) {
                continue;
            }
            if let Some(effect_name) = &rule.effect {
                let trigger_effect = match rule.event {
                    CursorRuleEvent::Hover => hover_enter,
                    CursorRuleEvent::Leave => leave_active,
                    CursorRuleEvent::Click => derived_pressed.iter().any(|pressed| *pressed),
                    CursorRuleEvent::Release => derived_released.iter().any(|released| *released),
                    CursorRuleEvent::Wheel => wheel_active,
                    CursorRuleEvent::Context => false,
                };
                if trigger_effect {
                    self.spawn_effect(
                        effect_name,
                        &derived_pressed,
                        &derived_released,
                        wheel_active,
                        true,
                    );
                }
            }
            if rule.duration_ms > 0 && rule.state.is_some() {
                self.timed_override = Some(CursorTimedOverride {
                    rule_id: rule.id,
                    until_ms: self.time_ms + rule.duration_ms as f32,
                });
            }
        }

        let mut selected: Option<(String, CursorStateSpec)> = None;
        let mut best_priority = i32::MIN;

        if let Some(timed) = self.timed_override {
            if let Some(rule) = self.rules.iter().find(|rule| rule.id == timed.rule_id) {
                if let Some(spec) = self.rule_state_spec(rule) {
                    selected = Some((format!("__timed_rule_{}__", rule.id), spec));
                    best_priority = i32::MAX;
                }
            }
        }

        if selected.is_none() {
            for rule in &self.rules {
                if !self.rule_matches(
                    rule,
                    &derived_pressed,
                    &derived_released,
                    wheel_active,
                    hover_active,
                    leave_active,
                ) {
                    continue;
                }
                let Some(spec) = self.rule_state_spec(rule) else {
                    continue;
                };
                if rule.priority >= best_priority {
                    best_priority = rule.priority;
                    let token = rule
                        .state
                        .clone()
                        .unwrap_or_else(|| format!("__rule_{}__", rule.id));
                    selected = Some((token, spec));
                }
            }
        }

        if let Some(hit) = self.last_hit.as_ref() {
            let effect_name = hit.attrs.get("cursor_effect").cloned();
            let state_name = hit.attrs.get("cursor_state").cloned();
            let state_priority = hit
                .attrs
                .get("cursor_priority")
                .and_then(|value| value.parse::<i32>().ok())
                .unwrap_or(100);
            if hover_enter {
                if let Some(effect_name) = effect_name {
                    self.spawn_effect(
                        &effect_name,
                        &derived_pressed,
                        &derived_released,
                        wheel_active,
                        true,
                    );
                }
            }
            if let Some(state_name) = state_name {
                if let Some(spec) = self.states.get(&state_name).cloned() {
                    if state_priority >= best_priority {
                        selected = Some((state_name, spec));
                    }
                }
            }
        }

        if let Some((token, spec)) = selected {
            self.apply_selected_state(token, spec);
        } else {
            self.apply_selected_state(
                "__default__".to_string(),
                CursorStateSpec::from_state(self.default_cursor.clone()),
            );
        }

        let attr_zoom = self
            .last_hit
            .as_ref()
            .and_then(|hit| hit.attrs.get("cursor_zoom"))
            .cloned();
        match attr_zoom {
            Some(value) if value != "0" && !value.eq_ignore_ascii_case("false") => {
                if self.active_visual.zoom.is_none() {
                    let mut zoom = CursorZoom::default();
                    if let Ok(magnification) = value.parse::<f32>() {
                        zoom.set_magnification(magnification);
                    }
                    self.zoom = Some(zoom);
                    self.zoom_owner =
                        CursorAttachmentOwner::State(format!("{}__attr_zoom", self.active_token));
                }
            }
            _ => {
                if matches!(&self.zoom_owner, CursorAttachmentOwner::State(owner) if owner.ends_with("__attr_zoom"))
                {
                    self.zoom = None;
                    self.zoom_owner = CursorAttachmentOwner::Manual;
                }
            }
        }

        if let CursorState::Animated(anim) = &mut self.active {
            anim.update(dt);
        }
        if let Some(trail) = &mut self.trail {
            trail.update(x, y, dt);
        }
        for burst in &mut self.bursts {
            burst.age += dt.max(0.0);
        }
        self.bursts.retain(CursorBurstInstance::is_alive);
        self.last_buttons = input.buttons;
    }

    fn apply_selected_state(&mut self, token: String, spec: CursorStateSpec) {
        let named_state = self.states.get(&token).map(|_| token.clone());
        if self.active_token != token {
            self.active = spec.state.clone();
            self.active_token = token.clone();
        }
        self.active_visual = spec.clone();
        self.active_named_state = named_state;

        match &spec.trail {
            Some(trail) => {
                let owner = CursorAttachmentOwner::State(token.clone());
                if self.trail_owner != owner {
                    self.trail = Some(trail.clone());
                    self.trail_owner = owner;
                }
            }
            None => {
                if matches!(self.trail_owner, CursorAttachmentOwner::State(_)) {
                    self.trail = None;
                    self.trail_owner = CursorAttachmentOwner::Manual;
                }
            }
        }
        match &spec.zoom {
            Some(zoom) => {
                let owner = CursorAttachmentOwner::State(token);
                if self.zoom_owner != owner {
                    self.zoom = Some(zoom.clone());
                    self.zoom_owner = owner;
                }
            }
            None => {
                if matches!(self.zoom_owner, CursorAttachmentOwner::State(_)) {
                    self.zoom = None;
                    self.zoom_owner = CursorAttachmentOwner::Manual;
                }
            }
        }
    }

    fn rule_state_spec(&self, rule: &CursorRule) -> Option<CursorStateSpec> {
        if let Some(state_name) = &rule.state {
            if let Some(spec) = self.states.get(state_name) {
                return Some(spec.clone());
            }
        }
        rule.inline_state.clone()
    }

    fn rule_matches(
        &self,
        rule: &CursorRule,
        buttons_pressed: &[bool; 5],
        buttons_released: &[bool; 5],
        wheel_active: bool,
        hover_active: bool,
        leave_active: bool,
    ) -> bool {
        if let Some(context) = &rule.context {
            if &self.current_context != context {
                return false;
            }
        }
        if let Some(target) = &rule.target {
            let Some(hit) = self.last_hit.as_ref() else {
                return false;
            };
            if !target.matches(hit) {
                return false;
            }
        }
        match rule.event {
            CursorRuleEvent::Context => true,
            CursorRuleEvent::Hover => hover_active,
            CursorRuleEvent::Leave => leave_active,
            CursorRuleEvent::Click => buttons_pressed.iter().any(|pressed| *pressed),
            CursorRuleEvent::Release => buttons_released.iter().any(|released| *released),
            CursorRuleEvent::Wheel => wheel_active,
        }
    }

    fn spawn_effect(
        &mut self,
        effect_name: &str,
        buttons_pressed: &[bool; 5],
        _buttons_released: &[bool; 5],
        wheel_active: bool,
        force: bool,
    ) {
        let Some(effect) = self.effects.get(effect_name).cloned() else {
            return;
        };
        if let Some(button) = effect.button_filter {
            if button >= buttons_pressed.len() || !buttons_pressed[button] {
                return;
            }
        } else if !force && !wheel_active && !buttons_pressed.iter().any(|pressed| *pressed) {
            return;
        }
        self.bursts.push(CursorBurstInstance {
            effect,
            x: self.position.0,
            y: self.position.1,
            age: 0.0,
            seed: self.effect_serial,
        });
        self.effect_serial = self.effect_serial.wrapping_add(1);
    }

    fn refresh_runtime_selection(&mut self) {
        self.resolve_static_state();
        let input = CursorInputFrame {
            buttons: self.last_buttons,
            ..CursorInputFrame::default()
        };
        self.tick(
            self.position.0,
            self.position.1,
            0.0,
            input,
            self.last_hit.clone(),
        );
    }

    /// Update cursor state from one manual position override.
    pub fn update(&mut self, x: f32, y: f32, dt: f32) {
        self.tick(x, y, dt, CursorInputFrame::default(), self.last_hit.clone());
    }

    /// Attach or clear the cursor trail effect.
    pub fn set_trail(&mut self, trail: Option<CursorTrail>) {
        self.trail = trail;
        self.trail_owner = CursorAttachmentOwner::Manual;
    }

    /// Return the current runtime trail.
    pub fn trail(&self) -> Option<&CursorTrail> {
        self.trail.as_ref()
    }

    /// Return a mutable trail reference.
    pub fn trail_mut(&mut self) -> Option<&mut CursorTrail> {
        self.trail.as_mut()
    }

    /// Attach or clear the zoom lens overlay.
    pub fn set_zoom(&mut self, zoom: Option<CursorZoom>) {
        self.zoom = zoom;
        self.zoom_owner = CursorAttachmentOwner::Manual;
    }

    /// Return the current zoom lens config.
    pub fn zoom(&self) -> Option<&CursorZoom> {
        self.zoom.as_ref()
    }

    /// Return active burst instances.
    pub fn bursts(&self) -> &[CursorBurstInstance] {
        &self.bursts
    }

    /// Show or hide the cursor runtime.
    pub fn set_visible(&mut self, visible: bool) {
        self.visible = visible;
    }

    /// Return `true` if the cursor is visible.
    pub fn is_visible(&self) -> bool {
        self.visible
    }

    /// Lock or unlock cursor grab intent.
    pub fn set_locked(&mut self, locked: bool) {
        self.locked = locked;
    }

    /// Return `true` if cursor lock is enabled.
    pub fn is_locked(&self) -> bool {
        self.locked
    }

    /// Return the active cursor state.
    pub fn active(&self) -> &CursorState {
        &self.active
    }

    /// Return active visual metadata.
    pub fn active_visual(&self) -> &CursorStateSpec {
        &self.active_visual
    }

    /// Return cursor position.
    pub fn position(&self) -> (f32, f32) {
        self.position
    }

    /// Return the active cursor context.
    pub fn context(&self) -> &CursorContext {
        &self.current_context
    }

    /// Return the current overlay decision.
    pub fn wants_overlay(&self) -> bool {
        if !self.visible {
            return false;
        }
        matches!(
            self.active,
            CursorState::Custom(_) | CursorState::Animated(_)
        ) || self.trail.is_some()
            || self.zoom.as_ref().map(|zoom| zoom.enabled).unwrap_or(false)
            || !self.bursts.is_empty()
    }
}

impl Default for CursorManager {
    fn default() -> Self {
        Self::new()
    }
}
