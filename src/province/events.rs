//! Province event bus for lifecycle events on the province map.
//!
//! Wraps [`crate::event::EventQueue`] with named emit helpers so callers do not
//! have to construct [`EventArg`][crate::event::EventArg] slices by hand.

use crate::event::{Event, EventArg, EventQueue};

/// Province event bus — wraps a [`EventQueue`] and provides typed emit helpers.
///
/// All province IDs and org IDs are passed as `EventArg::Num(f64)` values because
/// Lua only has a single numeric type.
#[derive(Debug, Default)]
pub struct ProvinceEventBus {
    queue: EventQueue,
    turn: u64,
}

impl ProvinceEventBus {
    /// Create a new empty event bus.
    pub fn new() -> Self {
        Self::default()
    }

    // ── Emit helpers ────────────────────────────────────────────────────────

    /// Emit a `"property_changed"` event.
    ///
    /// Args: `[province_id: Num, key: Str, value_display: Str]`
    pub fn emit_property_changed(&mut self, province_id: u32, key: &str, value_display: &str) {
        self.queue.push_event(
            "property_changed",
            vec![
                EventArg::Num(province_id as f64),
                EventArg::Str(key.to_string()),
                EventArg::Str(value_display.to_string()),
            ],
        );
    }

    /// Emit an `"object_added"` event.
    ///
    /// Args: `[province_id: Num, obj_id: Num, obj_type: Str]`
    pub fn emit_object_added(&mut self, province_id: u32, obj_id: u64, obj_type: &str) {
        self.queue.push_event(
            "object_added",
            vec![
                EventArg::Num(province_id as f64),
                EventArg::Num(obj_id as f64),
                EventArg::Str(obj_type.to_string()),
            ],
        );
    }

    /// Emit an `"object_removed"` event.
    ///
    /// Args: `[province_id: Num, obj_id: Num, obj_type: Str]`
    pub fn emit_object_removed(&mut self, province_id: u32, obj_id: u64, obj_type: &str) {
        self.queue.push_event(
            "object_removed",
            vec![
                EventArg::Num(province_id as f64),
                EventArg::Num(obj_id as f64),
                EventArg::Str(obj_type.to_string()),
            ],
        );
    }

    /// Emit an `"org_assigned"` event.
    ///
    /// Args: `[province_id: Num, org_id: Num]`
    pub fn emit_org_assigned(&mut self, province_id: u32, org_id: u64) {
        self.queue.push_event(
            "org_assigned",
            vec![
                EventArg::Num(province_id as f64),
                EventArg::Num(org_id as f64),
            ],
        );
    }

    /// Emit an `"org_unassigned"` event.
    ///
    /// Args: `[province_id: Num, org_id: Num]`
    pub fn emit_org_unassigned(&mut self, province_id: u32, org_id: u64) {
        self.queue.push_event(
            "org_unassigned",
            vec![
                EventArg::Num(province_id as f64),
                EventArg::Num(org_id as f64),
            ],
        );
    }

    /// Emit a `"relation_changed"` event.
    ///
    /// Args: `[from_org: Num, to_org: Num, type_name: Str, new_level: Str]`
    pub fn emit_relation_changed(
        &mut self,
        from_org: u64,
        to_org: u64,
        type_name: &str,
        new_level: &str,
    ) {
        self.queue.push_event(
            "relation_changed",
            vec![
                EventArg::Num(from_org as f64),
                EventArg::Num(to_org as f64),
                EventArg::Str(type_name.to_string()),
                EventArg::Str(new_level.to_string()),
            ],
        );
    }

    /// Emit a `"relation_value_changed"` event.
    ///
    /// Args: `[from_org: Num, to_org: Num, new_value: Num]`
    pub fn emit_relation_value_changed(&mut self, from_org: u64, to_org: u64, new_value: f64) {
        self.queue.push_event(
            "relation_value_changed",
            vec![
                EventArg::Num(from_org as f64),
                EventArg::Num(to_org as f64),
                EventArg::Num(new_value),
            ],
        );
    }

    /// Advance the turn counter and emit a `"turn"` event.
    ///
    /// Args: `[turn_number: Num]`
    ///
    /// Returns the new turn number.
    pub fn advance_turn(&mut self) -> u64 {
        self.turn += 1;
        let t = self.turn;
        self.queue
            .push_event("turn_changed", vec![EventArg::Num(t as f64)]);
        t
    }

    /// Emit a `"tick"` event with the elapsed delta-time in seconds.
    ///
    /// Args: `[dt: Num]`
    pub fn emit_tick(&mut self, dt: f64) {
        self.queue
            .push_event("tick", vec![EventArg::Num(dt)]);
    }

    /// Emit a custom-named event with arbitrary arguments.
    pub fn emit_custom(&mut self, name: &str, args: Vec<EventArg>) {
        self.queue.push_event(name, args);
    }

    // ── Queue delegation ────────────────────────────────────────────────────

    /// Poll the next event from the bus.
    pub fn poll(&mut self) -> Option<Event> {
        self.queue.poll()
    }

    /// Returns `true` if no events are pending.
    pub fn is_empty(&self) -> bool {
        self.queue.is_empty()
    }

    /// Drain all pending events into a `Vec`.
    pub fn drain(&mut self) -> Vec<Event> {
        let mut out = Vec::new();
        while let Some(ev) = self.queue.poll() {
            out.push(ev);
        }
        out
    }

    /// Current turn counter.
    pub fn turn(&self) -> u64 {
        self.turn
    }
}
