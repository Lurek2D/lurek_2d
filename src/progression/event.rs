//! Owns filtered activity-feed projections over the store's retained progression event history.
//! Shapes canonical event records into transport-neutral JSON snapshots without mutating or reordering store history.
//! Exposes headless helpers that validate requested profile filters, apply type filters, and bound feed size.
//! Open this file when activity-feed selection, event payload shape, or retained-event presentation needs adjustment.
use super::*;

impl ProgressionStore {
    /// Return a chronological activity feed filtered by optional profiles and event types.
    ///
    /// The feed validates every requested profile id, applies a default limit of `50`, and clamps any smaller
    /// requested limit up to `1` before selecting from the store's retained event deque.
    pub fn get_activity_feed(
        &self,
        profile_ids: Option<Vec<String>>,
        event_types: Option<Vec<String>>,
        limit: Option<usize>,
    ) -> Result<Vec<JsonValue>, ProgressionError> {
        let profile_filter =
            profile_ids.map(|profiles| profiles.into_iter().collect::<BTreeSet<_>>());
        if let Some(profile_filter) = &profile_filter {
            for profile_id in profile_filter {
                self.profiles
                    .get(profile_id)
                    .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
            }
        }
        let type_filter = event_types.map(|types| types.into_iter().collect::<BTreeSet<_>>());
        let cap = limit.unwrap_or(50).max(1);
        let mut events = self
            .events
            .iter()
            .rev()
            .filter(|event| {
                let profile_match = match &profile_filter {
                    Some(profiles) => event
                        .profile_id
                        .as_ref()
                        .map(|profile_id| profiles.contains(profile_id))
                        .unwrap_or(false),
                    None => true,
                };
                let type_match = match &type_filter {
                    Some(types) => types.contains(&event.event_type),
                    None => true,
                };
                profile_match && type_match
            })
            .take(cap)
            .map(|event| {
                json!({
                    "sequence": event.sequence,
                    "revision": event.revision,
                    "event_type": event.event_type,
                    "profile_id": event.profile_id,
                    "definition_id": event.definition_id,
                    "payload": event.payload,
                })
            })
            .collect::<Vec<_>>();
        events.reverse();
        Ok(events)
    }
}
