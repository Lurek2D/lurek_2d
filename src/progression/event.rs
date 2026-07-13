//! Owns bounded activity-feed projections over retained progression events for one profile or rivalry context.
//! Shapes event records into reviewer-facing summaries without changing the canonical store mutation pipeline.
//! Exposes public helpers that filter, bound, and serialize recent activity while remaining fully headless.
//! Open this file when activity feed selection, event shaping, or retained-event presentation needs adjustment.
use super::*;

impl ProgressionStore {
    /// Return a filtered bounded local activity feed derived from retained progression events.
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
