//! - Stack-based scene manager: push, pop, switch, and clear with optional transitions.
//! - Overlay support: scenes marked as overlays render above all normal scenes.
//! - Transition queuing: enqueues fade/slide/wipe transitions and drains them sequentially.
//! - Layer ordering: per-scene draw priority for front-to-back render sorting.
//! - Named registry: associate string names with SceneIds for lookup and navigation.
//! - Per-scene data slots: store and retrieve SceneId-encoded values by string key.

use crate::log_msg;
use crate::runtime::log_messages::{
    SC01_STACK_INIT, SC02_SCENE_PUSH, SC03_SCENE_POP, SC04_STACK_CLEAR,
};
use crate::scene::transition::{ActiveTransition, EasingType, TransitionType};
use std::collections::{HashMap, HashSet, VecDeque};
/// Unique identifier for a scene; assigned by SceneStack::next_scene_id.
pub type SceneId = u64;

/// Stack-based scene manager with push/pop/switch, overlay support, transition queuing, and layer ordering.
pub struct SceneStack {
    /// Active scene order; top element is the current scene.
    stack: Vec<SceneId>,
    /// Named scene registry mapping string names to SceneId.
    registry: HashMap<String, SceneId>,
    /// Per-scene data slot: maps string keys to SceneId-encoded values.
    data_keys: HashMap<String, SceneId>,
    /// Running transition, if any; None when no transition is active.
    transition: Option<ActiveTransition>,
    /// Pending transitions waiting for the active one to complete.
    transition_queue: VecDeque<(TransitionType, f32, EasingType)>,
    /// Draw layer priority per scene; used by get_active_ids_ordered_by_layer.
    scene_layers: HashMap<SceneId, i32>,
    /// Monotonic counter for SceneId generation; starts at 1.
    next_id: u64,
    /// Set of scene IDs marked as overlays; affects get_active_ids visibility rules.
    overlay_ids: HashSet<SceneId>,
    /// Per-scene execution toggle for `process`; defaults to true.
    process_enabled: HashMap<SceneId, bool>,
    /// Per-scene execution toggle for `process_physics`; defaults to true.
    physics_enabled: HashMap<SceneId, bool>,
    /// Per-scene execution toggle for `process_late`; defaults to true.
    late_enabled: HashMap<SceneId, bool>,
    /// Per-scene execution toggle for `update`; defaults to true.
    update_enabled: HashMap<SceneId, bool>,
}
impl SceneStack {
    /// Create an empty SceneStack with no active scenes and no pending transitions.
    pub fn new() -> Self {
        log_msg!(debug, SC01_STACK_INIT);
        Self {
            stack: Vec::new(),
            registry: HashMap::new(),
            data_keys: HashMap::new(),
            transition: None,
            transition_queue: VecDeque::new(),
            scene_layers: HashMap::new(),
            next_id: 1,
            overlay_ids: HashSet::new(),
            process_enabled: HashMap::new(),
            physics_enabled: HashMap::new(),
            late_enabled: HashMap::new(),
            update_enabled: HashMap::new(),
        }
    }
    /// Allocate and return the next monotonically increasing SceneId.
    pub fn next_scene_id(&mut self) -> SceneId {
        let id = self.next_id;
        self.next_id += 1;
        id
    }

    /// Initialize execution flags for a newly added scene.
    fn init_execution_flags(&mut self, scene_id: SceneId) {
        self.process_enabled.entry(scene_id).or_insert(true);
        self.physics_enabled.entry(scene_id).or_insert(true);
        self.late_enabled.entry(scene_id).or_insert(true);
        self.update_enabled.entry(scene_id).or_insert(true);
    }

    /// Remove execution flags for a scene removed from the stack.
    fn remove_execution_flags(&mut self, scene_id: SceneId) {
        self.process_enabled.remove(&scene_id);
        self.physics_enabled.remove(&scene_id);
        self.late_enabled.remove(&scene_id);
        self.update_enabled.remove(&scene_id);
    }
    /// Start transition immediately if none is active; otherwise enqueue it for later.
    fn enqueue_or_start_transition(
        &mut self,
        transition_type: TransitionType,
        duration: f32,
        easing: EasingType,
    ) {
        if transition_type == TransitionType::None || duration <= 0.0 {
            return;
        }
        if self.transition.is_some() {
            self.transition_queue
                .push_back((transition_type, duration, easing));
        } else {
            self.transition = Some(ActiveTransition::new_with_easing(
                transition_type,
                duration,
                easing,
            ));
        }
    }
    /// Pop the front item from the transition queue and start it if no transition is active.
    fn start_next_transition_from_queue(&mut self) {
        if self.transition.is_some() {
            return;
        }
        if let Some((transition_type, duration, easing)) = self.transition_queue.pop_front() {
            self.transition = Some(ActiveTransition::new_with_easing(
                transition_type,
                duration,
                easing,
            ));
        }
    }
    /// Push scene_id onto the stack, optionally starting a transition; returns the previously active SceneId.
    pub fn push(
        &mut self,
        scene_id: SceneId,
        transition_type: TransitionType,
        duration: f32,
        easing: EasingType,
    ) -> Option<SceneId> {
        log_msg!(info, SC02_SCENE_PUSH);
        let prev = self.stack.last().copied();
        self.enqueue_or_start_transition(transition_type, duration, easing);
        self.stack.push(scene_id);
        self.scene_layers.entry(scene_id).or_insert(0);
        self.init_execution_flags(scene_id);
        prev
    }
    /// Pop the top scene, optionally starting a transition; returns (popped_id, newly_revealed_id) or Err when empty.
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
        self.overlay_ids.remove(&popped);
        self.scene_layers.remove(&popped);
        self.remove_execution_flags(popped);
        let revealed = self.stack.last().copied();
        self.enqueue_or_start_transition(transition_type, duration, easing);
        Ok((popped, revealed))
    }
    /// Replace the top scene with scene_id and start the given transition; returns the replaced SceneId.
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
            self.scene_layers.remove(&old_id);
            self.remove_execution_flags(old_id);
            Some(old_id)
        } else {
            None
        };
        self.enqueue_or_start_transition(transition_type, duration, easing);
        self.stack.push(scene_id);
        self.scene_layers.entry(scene_id).or_insert(0);
        self.init_execution_flags(scene_id);
        old
    }
    /// Clear all scenes, cancel transitions and queue, and return the drained scene IDs.
    pub fn clear(&mut self) -> Vec<SceneId> {
        log_msg!(info, SC04_STACK_CLEAR);
        self.transition = None;
        self.transition_queue.clear();
        self.overlay_ids.clear();
        self.scene_layers.clear();
        self.process_enabled.clear();
        self.physics_enabled.clear();
        self.late_enabled.clear();
        self.update_enabled.clear();
        std::mem::take(&mut self.stack)
    }
    /// Look up registered scene id by name; does not modify the stack.
    pub fn pop_to(&self, name: &str) -> Option<SceneId> {
        self.registry.get(name).copied()
    }
    /// Pop scenes until target_id is on top; returns all popped IDs in pop order.
    pub fn pop_until(&mut self, target_id: SceneId) -> Vec<SceneId> {
        let mut popped = Vec::new();
        while let Some(&top) = self.stack.last() {
            if top == target_id {
                break;
            }
            let id = self.stack.pop().unwrap();
            self.overlay_ids.remove(&id);
            self.scene_layers.remove(&id);
            self.remove_execution_flags(id);
            popped.push(id);
        }
        popped
    }
    /// Return the number of scenes currently on the stack.
    pub fn get_stack_size(&self) -> usize {
        self.stack.len()
    }
    /// Return true when the stack has no scenes.
    pub fn is_empty(&self) -> bool {
        self.stack.is_empty()
    }
    /// Return the top SceneId or None when the stack is empty.
    pub fn get_current(&self) -> Option<SceneId> {
        self.stack.last().copied()
    }
    /// Return all stacked SceneIds in push order (first = bottom, last = top).
    pub fn get_all(&self) -> &[SceneId] {
        &self.stack
    }
    /// Return true when a transition is currently running.
    pub fn is_transitioning(&self) -> bool {
        self.transition.is_some()
    }
    /// Return the raw (linear) transition progress in [0, 1]; 0.0 when no transition is active.
    pub fn get_transition_progress(&self) -> f32 {
        self.transition.as_ref().map_or(0.0, |t| t.progress())
    }
    /// Return the eased transition progress in [0, 1]; 0.0 when no transition is active.
    pub fn get_transition_progress_eased(&self) -> f32 {
        self.transition.as_ref().map_or(0.0, |t| t.progress_eased())
    }
    /// Enqueue a transition to start after the current one completes.
    pub fn queue_transition(
        &mut self,
        transition_type: TransitionType,
        duration: f32,
        easing: EasingType,
    ) {
        self.enqueue_or_start_transition(transition_type, duration, easing);
    }
    /// Return the number of transitions waiting in the queue.
    pub fn queued_transition_count(&self) -> usize {
        self.transition_queue.len()
    }
    /// Remove all pending transitions from the queue without affecting the active transition.
    pub fn clear_transition_queue(&mut self) {
        self.transition_queue.clear();
    }
    /// Advance the active transition by dt seconds; starts the next queued transition on completion; returns true when a transition just finished.
    pub fn update_transition(&mut self, dt: f32) -> bool {
        if let Some(ref mut t) = self.transition {
            t.update(dt);
            if t.is_complete() {
                self.transition = None;
                self.start_next_transition_from_queue();
                return true;
            }
        } else {
            self.start_next_transition_from_queue();
        }
        false
    }
    /// Push scene_id as an overlay (layer=100) that renders above all non-overlay scenes; returns previous top SceneId.
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
        self.enqueue_or_start_transition(transition_type, duration, easing);
        self.stack.push(scene_id);
        self.scene_layers.entry(scene_id).or_insert(100);
        self.init_execution_flags(scene_id);
        prev
    }
    /// Return true when scene_id was pushed via push_overlay.
    pub fn is_overlay(&self, scene_id: SceneId) -> bool {
        self.overlay_ids.contains(&scene_id)
    }
    /// Return active scene IDs: all stacked IDs when any overlay is present, otherwise only the top scene.
    pub fn get_active_ids(&self) -> &[SceneId] {
        if self.stack.iter().any(|id| self.overlay_ids.contains(id)) {
            &self.stack
        } else {
            match self.stack.last() {
                Some(_) => &self.stack[self.stack.len() - 1..],
                None => &[],
            }
        }
    }

    /// Return scene IDs selected for rendering.
    /// Rendering is single-scene at engine level: only the current top scene is render-active.
    pub fn get_render_ids(&self) -> &[SceneId] {
        match self.stack.last() {
            Some(_) => &self.stack[self.stack.len() - 1..],
            None => &[],
        }
    }
    /// Set the draw layer priority for scene_id; higher values draw on top of lower values.
    pub fn set_scene_layer(&mut self, scene_id: SceneId, layer: i32) {
        self.scene_layers.insert(scene_id, layer);
    }
    /// Return the draw layer for scene_id; 0 when not set.
    pub fn get_scene_layer(&self, scene_id: SceneId) -> i32 {
        self.scene_layers.get(&scene_id).copied().unwrap_or(0)
    }
    /// Return active scene IDs sorted by (layer, insertion index) ascending — front-to-back draw order.
    pub fn get_active_ids_ordered_by_layer(&self) -> Vec<SceneId> {
        let mut indexed: Vec<(usize, SceneId)> =
            self.get_active_ids().iter().copied().enumerate().collect();
        indexed.sort_by_key(|(idx, id)| (self.get_scene_layer(*id), *idx));
        indexed.into_iter().map(|(_, id)| id).collect()
    }

    /// Return render-active scene IDs sorted by (layer, insertion index) ascending.
    pub fn get_render_ids_ordered_by_layer(&self) -> Vec<SceneId> {
        let mut indexed: Vec<(usize, SceneId)> =
            self.get_render_ids().iter().copied().enumerate().collect();
        indexed.sort_by_key(|(idx, id)| (self.get_scene_layer(*id), *idx));
        indexed.into_iter().map(|(_, id)| id).collect()
    }

    /// Enable/disable `process` execution for a scene id.
    pub fn set_process_enabled(&mut self, scene_id: SceneId, enabled: bool) {
        self.process_enabled.insert(scene_id, enabled);
    }

    /// Return whether `process` execution is enabled for scene id.
    pub fn is_process_enabled(&self, scene_id: SceneId) -> bool {
        self.process_enabled.get(&scene_id).copied().unwrap_or(true)
    }

    /// Enable/disable `process_physics` execution for a scene id.
    pub fn set_physics_enabled(&mut self, scene_id: SceneId, enabled: bool) {
        self.physics_enabled.insert(scene_id, enabled);
    }

    /// Return whether `process_physics` execution is enabled for scene id.
    pub fn is_physics_enabled(&self, scene_id: SceneId) -> bool {
        self.physics_enabled.get(&scene_id).copied().unwrap_or(true)
    }

    /// Enable/disable `process_late` execution for a scene id.
    pub fn set_late_enabled(&mut self, scene_id: SceneId, enabled: bool) {
        self.late_enabled.insert(scene_id, enabled);
    }

    /// Return whether `process_late` execution is enabled for scene id.
    pub fn is_late_enabled(&self, scene_id: SceneId) -> bool {
        self.late_enabled.get(&scene_id).copied().unwrap_or(true)
    }

    /// Enable/disable `update` execution for a scene id.
    pub fn set_update_enabled(&mut self, scene_id: SceneId, enabled: bool) {
        self.update_enabled.insert(scene_id, enabled);
    }

    /// Return whether `update` execution is enabled for scene id.
    pub fn is_update_enabled(&self, scene_id: SceneId) -> bool {
        self.update_enabled.get(&scene_id).copied().unwrap_or(true)
    }
    /// Associate a string name with a SceneId in the named registry.
    pub fn register_scene(&mut self, name: String, scene_id: SceneId) {
        self.registry.insert(name, scene_id);
    }
    /// Look up a SceneId by name; returns None when not registered.
    pub fn get_registered(&self, name: &str) -> Option<SceneId> {
        self.registry.get(name).copied()
    }
    /// Return true when a scene is registered under the given name.
    pub fn has_registered(&self, name: &str) -> bool {
        self.registry.contains_key(name)
    }
    /// Remove a scene name from the registry; no-op when name is absent.
    pub fn unregister_scene(&mut self, name: &str) {
        self.registry.remove(name);
    }
    /// Return all registered scene names; order is unspecified.
    pub fn get_registered_names(&self) -> Vec<String> {
        self.registry.keys().cloned().collect()
    }
    /// Store a SceneId-encoded data value under the given key.
    pub fn set_data(&mut self, key: String, value_id: SceneId) {
        self.data_keys.insert(key, value_id);
    }
    /// Return the SceneId-encoded data stored under key, or None.
    pub fn get_data(&self, key: &str) -> Option<SceneId> {
        self.data_keys.get(key).copied()
    }
    /// Return true when a data value is stored under the given key.
    pub fn has_data(&self, key: &str) -> bool {
        self.data_keys.contains_key(key)
    }
    /// Remove the data entry for key; no-op when absent.
    pub fn remove_data(&mut self, key: &str) {
        self.data_keys.remove(key);
    }
}
/// Default delegates to new().
impl Default for SceneStack {
    /// Create an empty SceneStack via new().
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::SceneStack;
    use crate::scene::transition::{EasingType, TransitionType};

    #[test]
    fn render_ids_only_include_top_scene_even_with_overlay() {
        let mut stack = SceneStack::new();
        let base = stack.next_scene_id();
        let mid = stack.next_scene_id();
        let overlay = stack.next_scene_id();

        stack.push(base, TransitionType::None, 0.0, EasingType::Linear);
        stack.push(mid, TransitionType::None, 0.0, EasingType::Linear);
        stack.push_overlay(overlay, TransitionType::None, 0.0, EasingType::Linear);

        assert_eq!(stack.get_active_ids().len(), 3);
        let render_ids = stack.get_render_ids();
        assert_eq!(render_ids.len(), 1);
        assert_eq!(render_ids[0], overlay);
    }

    #[test]
    fn per_scene_execution_flags_are_toggleable() {
        let mut stack = SceneStack::new();
        let id = stack.next_scene_id();
        stack.push(id, TransitionType::None, 0.0, EasingType::Linear);

        assert!(stack.is_process_enabled(id));
        assert!(stack.is_physics_enabled(id));
        assert!(stack.is_late_enabled(id));
        assert!(stack.is_update_enabled(id));

        stack.set_process_enabled(id, false);
        stack.set_physics_enabled(id, false);
        stack.set_late_enabled(id, false);
        stack.set_update_enabled(id, false);

        assert!(!stack.is_process_enabled(id));
        assert!(!stack.is_physics_enabled(id));
        assert!(!stack.is_late_enabled(id));
        assert!(!stack.is_update_enabled(id));
    }
}
