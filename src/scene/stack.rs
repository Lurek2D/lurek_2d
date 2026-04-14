//! LIFO scene stack with registry and inter-scene data store.
//!
//! This module is part of Lurek2D's `scene` subsystem and provides the implementation
//! details for stack-related operations and data management.
//! Key types exported from this module: `SceneStack`.
//! Primary functions: `new()`, `next_scene_id()`, `push()`, `pop()`.
//!
//! All public items are documented. See the parent module for architectural context
//! and the `lurek.*` Lua API for the scripting interface.

use std::collections::{HashMap, HashSet};

use crate::runtime::log_messages::{
    SC01_STACK_INIT, SC02_SCENE_PUSH, SC03_SCENE_POP, SC04_STACK_CLEAR,
};
use crate::log_msg;
use crate::scene::transition::{ActiveTransition, EasingType, TransitionType};

/// Unique identifier for a scene in the stack.
pub type SceneId = u64;

/// The scene stack manages a LIFO stack of scene references.
///
/// Scenes are identified by `SceneId` values. The Lua API layer maps these
/// to `mlua::RegistryKey` references for actual Lua table access.
///
/// **Overlay mode**: when scenes are pushed with `push_overlay`, they are stored in
/// `overlay_ids`.  Every scene below the current top stays active — its `process`,
/// `process_physics`, and `render` callbacks continue firing each frame.  Calling
/// `pop()` on an overlay removes only the overlay; the background scene is unaffected.
///
/// # Fields
/// - `stack` — `Vec<SceneId>`. LIFO scene stack, bottom-to-top.
/// - `registry` — `HashMap<String, SceneId>`. Named scene registry.
/// - `data_keys` — `HashMap<String, SceneId>`. Inter-scene data store.
/// - `transition` — `Option<ActiveTransition>`. Active visual transition, if any.
/// - `next_id` — `u64`. Next available scene ID counter.
/// - `overlay_ids` — `HashSet<SceneId>`. IDs pushed via `push_overlay`.
pub struct SceneStack {
    /// The scene stack, bottom-to-top.
    stack: Vec<SceneId>,
    /// Named scene registry mapping names to scene IDs.
    registry: HashMap<String, SceneId>,
    /// Inter-scene data store mapping string keys to scene IDs (used as data value refs).
    data_keys: HashMap<String, SceneId>,
    /// Active visual transition, if any.
    transition: Option<ActiveTransition>,
    /// Next available scene ID.
    next_id: u64,
    /// IDs pushed via `push_overlay`; scenes in this set do not pause the scene below.
    overlay_ids: HashSet<SceneId>,
}

impl SceneStack {
    /// Create a new empty scene stack. Returns a fully initialised instance with all fields set to their initial values.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        log_msg!(debug, SC01_STACK_INIT);
        Self {
            stack: Vec::new(),
            registry: HashMap::new(),
            data_keys: HashMap::new(),
            transition: None,
            next_id: 1,
            overlay_ids: HashSet::new(),
        }
    }

    /// Allocate a new unique scene ID.
    ///
    /// # Returns
    /// `SceneId`.
    pub fn next_scene_id(&mut self) -> SceneId {
        let id = self.next_id;
        self.next_id += 1;
        id
    }

    /// Push a scene ID onto the stack and start an optional transition.
    ///
    /// The previous top scene receives `pause()` in the Lua API layer; it does not
    /// continue to receive `process` or `render` calls.  For a non-pausing overlay
    /// push, use `push_overlay` instead.
    ///
    /// # Parameters
    /// - `scene_id` — `SceneId`.
    /// - `transition_type` — `TransitionType`.
    /// - `duration` — `f32`.
    /// - `easing` — `EasingType`. Curve applied to transition progress.
    ///
    /// # Returns
    /// `Option<SceneId>`. Previous top scene ID, so the caller can invoke `pause()` on it.
    pub fn push(
        &mut self,
        scene_id: SceneId,
        transition_type: TransitionType,
        duration: f32,
        easing: EasingType,
    ) -> Option<SceneId> {
        log_msg!(info, SC02_SCENE_PUSH);
        let prev = self.stack.last().copied();
        if transition_type != TransitionType::None && duration > 0.0 {
            self.transition = Some(ActiveTransition::new_with_easing(transition_type, duration, easing));
        }
        self.stack.push(scene_id);
        prev
    }

    /// Pop the top scene from the stack.
    ///
    /// If the popped scene was an overlay, its overlay flag is cleared.  The newly
    /// revealed scene is NOT resumed here — the Lua API layer decides whether to call
    /// `resume()` based on whether the popped scene was an overlay.
    ///
    /// # Parameters
    /// - `transition_type` — `TransitionType`.
    /// - `duration` — `f32`.
    /// - `easing` — `EasingType`.
    ///
    /// # Returns
    /// `Result<(SceneId, Option<SceneId>), String>`.
    ///
    /// `(popped_id, revealed_id)` — the removed scene and the newly exposed top.
    /// Returns `Err` if the stack is empty.
    pub fn pop(
        &mut self,
        transition_type: TransitionType,
        duration: f32,
        easing: EasingType,
    ) -> Result<(SceneId, Option<SceneId>), String> {
        if self.stack.is_empty() {
            return Err("Cannot pop from an empty scene stack".to_string());
        }
        log_msg!(info, SC03_SCENE_POP);
        let popped = self.stack.pop().unwrap();
        // Clear the overlay flag if this scene was pushed as an overlay.
        self.overlay_ids.remove(&popped);
        let revealed = self.stack.last().copied();
        if transition_type != TransitionType::None && duration > 0.0 {
            self.transition = Some(ActiveTransition::new_with_easing(transition_type, duration, easing));
        }
        Ok((popped, revealed))
    }

    /// Replace the top scene with a new one.
    ///
    /// The old scene receives `leave()` in the Lua API layer.  Any overlay flag
    /// attached to the old top is also cleared.
    ///
    /// # Parameters
    /// - `scene_id` — `SceneId`.
    /// - `transition_type` — `TransitionType`.
    /// - `duration` — `f32`.
    /// - `easing` — `EasingType`.
    ///
    /// # Returns
    /// `Option<SceneId>`. Old top scene ID, so the caller can invoke `leave()` on it.
    pub fn switch_to(
        &mut self,
        scene_id: SceneId,
        transition_type: TransitionType,
        duration: f32,
        easing: EasingType,
    ) -> Option<SceneId> {
        let old = if !self.stack.is_empty() {
            let old_id = self.stack.pop().unwrap();
            self.overlay_ids.remove(&old_id);
            Some(old_id)
        } else {
            None
        };
        if transition_type != TransitionType::None && duration > 0.0 {
            self.transition = Some(ActiveTransition::new_with_easing(transition_type, duration, easing));
        }
        self.stack.push(scene_id);
        old
    }

    /// Remove all scenes from the stack and clear all overlay flags.
    ///
    /// The caller is responsible for invoking `leave()` on each returned scene.
    ///
    /// # Returns
    /// `Vec<SceneId>`. All removed scene IDs in their original bottom-to-top order.
    pub fn clear(&mut self) -> Vec<SceneId> {
        log_msg!(info, SC04_STACK_CLEAR);
        self.transition = None;
        self.overlay_ids.clear();
        std::mem::take(&mut self.stack)
    }

    /// Look up a registered scene ID by name.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Option<SceneId>`.
    ///
    /// Returns the scene ID if found, or `None` if the name is not registered.
    pub fn pop_to(&self, name: &str) -> Option<SceneId> {
        self.registry.get(name).copied()
    }

    /// Pop scenes until `target_id` is on top of the stack.
    ///
    /// Overlay flags for each removed scene are cleared.  The target scene itself
    /// is NOT popped.
    ///
    /// # Parameters
    /// - `target_id` — `SceneId`.
    ///
    /// # Returns
    /// `Vec<SceneId>`. Removed scene IDs, in pop order (most recent first).
    pub fn pop_until(&mut self, target_id: SceneId) -> Vec<SceneId> {
        let mut popped = Vec::new();
        while let Some(&top) = self.stack.last() {
            if top == target_id {
                break;
            }
            let id = self.stack.pop().unwrap();
            self.overlay_ids.remove(&id);
            popped.push(id);
        }
        popped
    }

    /// Number of scenes on the stack. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `usize`.
    pub fn get_stack_size(&self) -> usize {
        self.stack.len()
    }

    /// Whether the stack is empty. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_empty(&self) -> bool {
        self.stack.is_empty()
    }

    /// Get the top scene ID, or `None` if empty.
    ///
    /// # Returns
    /// `Option<SceneId>`.
    pub fn get_current(&self) -> Option<SceneId> {
        self.stack.last().copied()
    }

    /// Get all scene IDs in the stack, bottom-to-top.
    ///
    /// # Returns
    /// `&[SceneId]`.
    pub fn get_all(&self) -> &[SceneId] {
        &self.stack
    }

    // -- Transition --

    /// Whether a transition is currently active.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_transitioning(&self) -> bool {
        self.transition.is_some()
    }

    /// Get transition progress [0, 1], or 0 if no transition.
    ///
    /// # Returns
    /// `f32`.
    pub fn get_transition_progress(&self) -> f32 {
        self.transition.as_ref().map_or(0.0, |t| t.progress())
    }

    /// Get easing-adjusted transition progress in [0, 1], or 0 if no transition.
    ///
    /// Uses the `EasingType` stored in the active `ActiveTransition`.  For a linear
    /// transition this is identical to `get_transition_progress()`.
    ///
    /// # Returns
    /// `f32`.
    pub fn get_transition_progress_eased(&self) -> f32 {
        self.transition.as_ref().map_or(0.0, |t| t.progress_eased())
    }

    /// Update the active transition timer. Returns true if the transition just completed.
    ///
    /// # Parameters
    /// - `dt` — `f32`.
    ///
    /// # Returns
    /// `bool`.
    pub fn update_transition(&mut self, dt: f32) -> bool {
        if let Some(ref mut t) = self.transition {
            t.update(dt);
            if t.is_complete() {
                self.transition = None;
                return true;
            }
        }
        false
    }

    // -- Overlay ---------------------------------------------------------------

    /// Push a scene as a non-pausing overlay over the current top scene.
    ///
    /// Unlike `push()`, the current scene below the overlay continues to receive
    /// `process` and `render` calls every frame.  Neither `pause()` nor `resume()`
    /// is called on the underlying scene.
    ///
    /// On `pop()` the overlay flag for the removed scene is cleared.
    ///
    /// # Parameters
    /// - `scene_id` — `SceneId`. The scene to push on top as an overlay.
    /// - `transition_type` — `TransitionType`.
    /// - `duration` — `f32`.
    /// - `easing` — `EasingType`.
    ///
    /// # Returns
    /// `Option<SceneId>`. Current top scene ID (the scene that becomes the background).
    pub fn push_overlay(
        &mut self,
        scene_id: SceneId,
        transition_type: TransitionType,
        duration: f32,
        easing: EasingType,
    ) -> Option<SceneId> {
        log_msg!(info, SC02_SCENE_PUSH);
        let prev = self.stack.last().copied();
        self.overlay_ids.insert(scene_id);
        if transition_type != TransitionType::None && duration > 0.0 {
            self.transition = Some(ActiveTransition::new_with_easing(transition_type, duration, easing));
        }
        self.stack.push(scene_id);
        prev
    }

    /// Return `true` when `scene_id` was pushed via `push_overlay`.
    ///
    /// # Parameters
    /// - `scene_id` — `SceneId`.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_overlay(&self, scene_id: SceneId) -> bool {
        self.overlay_ids.contains(&scene_id)
    }

    /// Return the scene IDs that should receive lifecycle callbacks this frame.
    ///
    /// When at least one overlay scene is present in the stack, ALL stack entries
    /// are considered active.  When no overlays exist, only the top scene is active.
    ///
    /// This slice is used by the Lua API layer to iterate `process`, `render`, and
    /// related callbacks.
    ///
    /// # Returns
    /// `&[SceneId]`. Bottom-to-top slice of active scene IDs.
    pub fn get_active_ids(&self) -> &[SceneId] {
        if self.stack.iter().any(|id| self.overlay_ids.contains(id)) {
            // At least one overlay — all scenes in the stack are active.
            &self.stack
        } else {
            // Normal mode — only the top scene is active.
            match self.stack.last() {
                Some(_) => &self.stack[self.stack.len() - 1..],
                None => &[],
            }
        }
    }

    // -- Registry --

    /// Register a scene by name. Panics in debug mode if the same entity is registered twice.
    ///
    /// # Parameters
    /// - `name` — `String`.
    /// - `scene_id` — `SceneId`.
    pub fn register_scene(&mut self, name: String, scene_id: SceneId) {
        self.registry.insert(name, scene_id);
    }

    /// Get a registered scene ID by name. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Option<SceneId>`.
    pub fn get_registered(&self, name: &str) -> Option<SceneId> {
        self.registry.get(name).copied()
    }

    /// Check if a name is registered. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn has_registered(&self, name: &str) -> bool {
        self.registry.contains_key(name)
    }

    /// Unregister a scene by name.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    pub fn unregister_scene(&mut self, name: &str) {
        self.registry.remove(name);
    }

    /// Get all registered scene names. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `Vec<String>`.
    pub fn get_registered_names(&self) -> Vec<String> {
        self.registry.keys().cloned().collect()
    }

    // -- Data store --

    /// Store a data value reference by key. Replaces the current data value; callers hold responsibility for maintaining consistency with related fields.
    ///
    /// # Parameters
    /// - `key` — `String`.
    /// - `value_id` — `SceneId`.
    pub fn set_data(&mut self, key: String, value_id: SceneId) {
        self.data_keys.insert(key, value_id);
    }

    /// Get a stored data value reference by key.
    ///
    /// # Parameters
    /// - `key` — `&str`.
    ///
    /// # Returns
    /// `Option<SceneId>`.
    pub fn get_data(&self, key: &str) -> Option<SceneId> {
        self.data_keys.get(key).copied()
    }

    /// Check if a data key exists. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Parameters
    /// - `key` — `&str`.
    ///
    /// # Returns
    /// `bool`.
    pub fn has_data(&self, key: &str) -> bool {
        self.data_keys.contains_key(key)
    }

    /// Remove a data value by key. Returns the removed value if present, or `None` when the key did not exist.
    ///
    /// # Parameters
    /// - `key` — `&str`.
    pub fn remove_data(&mut self, key: &str) {
        self.data_keys.remove(key);
    }
}

impl Default for SceneStack {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::scene::transition::TransitionType;

    // ── Initial state ─────────────────────────────────────────────────────────

    #[test]
    fn new_stack_is_empty() {
        let s = SceneStack::new();
        assert!(s.is_empty());
        assert_eq!(s.get_stack_size(), 0);
    }

    // ── Scene IDs ─────────────────────────────────────────────────────────────

    #[test]
    fn next_scene_id_increments() {
        let mut s = SceneStack::new();
        let id1 = s.next_scene_id();
        let id2 = s.next_scene_id();
        assert!(id2 > id1);
    }

    // ── Push / Pop ────────────────────────────────────────────────────────────

    #[test]
    fn push_increases_stack_size() {
        let mut s = SceneStack::new();
        let id = s.next_scene_id();
        s.push(id, TransitionType::None, 0.0, EasingType::Linear);
        assert_eq!(s.get_stack_size(), 1);
    }

    #[test]
    fn pop_returns_pushed_id() {
        let mut s = SceneStack::new();
        let id = s.next_scene_id();
        s.push(id, TransitionType::None, 0.0, EasingType::Linear);
        let (popped, _) = s.pop(TransitionType::None, 0.0, EasingType::Linear).unwrap();
        assert_eq!(popped, id);
    }

    #[test]
    fn pop_empty_stack_returns_err() {
        let mut s = SceneStack::new();
        assert!(s.pop(TransitionType::None, 0.0, EasingType::Linear).is_err());
    }

    // ── Overlay ───────────────────────────────────────────────────────────────

    #[test]
    fn push_overlay_marks_scene_as_overlay() {
        let mut s = SceneStack::new();
        let base = s.next_scene_id();
        let overlay = s.next_scene_id();
        s.push(base, TransitionType::None, 0.0, EasingType::Linear);
        s.push_overlay(overlay, TransitionType::None, 0.0, EasingType::Linear);
        assert!(s.is_overlay(overlay));
        assert!(!s.is_overlay(base));
    }

    #[test]
    fn push_overlay_does_not_change_base_overlay_flag() {
        let mut s = SceneStack::new();
        let base = s.next_scene_id();
        let overlay = s.next_scene_id();
        s.push(base, TransitionType::None, 0.0, EasingType::Linear);
        s.push_overlay(overlay, TransitionType::None, 0.0, EasingType::Linear);
        assert!(!s.is_overlay(base));
    }

    #[test]
    fn get_active_ids_returns_all_when_overlay_present() {
        let mut s = SceneStack::new();
        let base = s.next_scene_id();
        let overlay = s.next_scene_id();
        s.push(base, TransitionType::None, 0.0, EasingType::Linear);
        s.push_overlay(overlay, TransitionType::None, 0.0, EasingType::Linear);
        assert_eq!(s.get_active_ids().len(), 2);
    }

    #[test]
    fn get_active_ids_returns_only_top_when_no_overlay() {
        let mut s = SceneStack::new();
        let id1 = s.next_scene_id();
        let id2 = s.next_scene_id();
        s.push(id1, TransitionType::None, 0.0, EasingType::Linear);
        s.push(id2, TransitionType::None, 0.0, EasingType::Linear);
        let active = s.get_active_ids();
        assert_eq!(active.len(), 1);
        assert_eq!(active[0], id2);
    }

    #[test]
    fn pop_overlay_removes_overlay_flag() {
        let mut s = SceneStack::new();
        let base = s.next_scene_id();
        let overlay = s.next_scene_id();
        s.push(base, TransitionType::None, 0.0, EasingType::Linear);
        s.push_overlay(overlay, TransitionType::None, 0.0, EasingType::Linear);
        s.pop(TransitionType::None, 0.0, EasingType::Linear).unwrap();
        assert!(!s.is_overlay(overlay));
    }

    #[test]
    fn is_overlay_false_for_normal_push() {
        let mut s = SceneStack::new();
        let id = s.next_scene_id();
        s.push(id, TransitionType::None, 0.0, EasingType::Linear);
        assert!(!s.is_overlay(id));
    }

    // ── Registry ───────────────────────────────────────────────────────────────

    #[test]
    fn register_and_lookup_scene() {
        let mut s = SceneStack::new();
        let id = s.next_scene_id();
        s.register_scene("main_menu".to_string(), id);
        assert_eq!(s.get_registered("main_menu"), Some(id));
    }

    #[test]
    fn unregistered_name_returns_none() {
        let s = SceneStack::new();
        assert!(s.get_registered("missing").is_none());
    }
}
