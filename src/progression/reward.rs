//! Owns profile-scoped reward records and the canonical pending-claimed-applied-rejected state machine.
//! Defines the store helpers that list outstanding reward work and transition records without applying game payloads.
//! Persists optional external receipts, emits reward lifecycle events, and bumps revisions for every accepted change.
//! Keeps payout-state rules separate from achievements, quests, and downstream economy code so producers stay decoupled.
//! Open this file when changing reward transitions, external receipt storage, or queue-facing reward semantics.
use super::*;

impl ProgressionStore {
    /// Return only the reward records that are still pending for one profile.
    pub fn get_pending_rewards(
        &self,
        profile_id: &str,
    ) -> Result<Vec<RewardRecord>, ProgressionError> {
        let profile = self
            .profiles
            .get(profile_id)
            .ok_or_else(|| ProgressionError::MissingProfile(profile_id.to_string()))?;
        Ok(profile
            .rewards
            .values()
            .filter(|reward| reward.state == RewardState::Pending)
            .cloned()
            .collect())
    }

    /// Move one pending reward into claimed state and emit `reward_claimed`.
    pub fn claim_reward(
        &mut self,
        profile_id: &str,
        reward_id: &str,
    ) -> Result<RewardRecord, ProgressionError> {
        let reward = {
            let profile = self.profile_mut(profile_id)?;
            let reward = profile.rewards.get_mut(reward_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "reward '{}' does not exist for profile '{}'",
                    reward_id, profile_id
                ))
            })?;
            if reward.state != RewardState::Pending {
                return Err(ProgressionError::InvalidOperation(format!(
                    "reward '{}' is not pending",
                    reward_id
                )));
            }
            reward.state = RewardState::Claimed;
            reward.clone()
        };
        self.bump_revision();
        self.push_event(
            "reward_claimed",
            Some(profile_id.to_string()),
            Some(reward_id.to_string()),
            json!({ "rewardId": reward_id }),
        );
        Ok(reward)
    }

    /// Mark one claimed reward as applied, persist the optional external receipt, and emit `reward_applied`.
    pub fn mark_reward_applied(
        &mut self,
        profile_id: &str,
        reward_id: &str,
        external_receipt: Option<String>,
    ) -> Result<RewardRecord, ProgressionError> {
        let reward = {
            let profile = self.profile_mut(profile_id)?;
            let reward = profile.rewards.get_mut(reward_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "reward '{}' does not exist for profile '{}'",
                    reward_id, profile_id
                ))
            })?;
            if reward.state != RewardState::Claimed {
                return Err(ProgressionError::InvalidOperation(format!(
                    "reward '{}' must be claimed before it can be applied",
                    reward_id
                )));
            }
            reward.state = RewardState::Applied;
            reward.external_receipt = external_receipt.clone();
            reward.clone()
        };
        self.bump_revision();
        self.push_event(
            "reward_applied",
            Some(profile_id.to_string()),
            Some(reward_id.to_string()),
            json!({ "rewardId": reward_id, "externalReceipt": external_receipt }),
        );
        Ok(reward)
    }

    /// Reject one pending or claimed reward instead of applying it and emit `reward_rejected`.
    pub fn reject_reward(
        &mut self,
        profile_id: &str,
        reward_id: &str,
        reason: Option<String>,
    ) -> Result<RewardRecord, ProgressionError> {
        let reward = {
            let profile = self.profile_mut(profile_id)?;
            let reward = profile.rewards.get_mut(reward_id).ok_or_else(|| {
                ProgressionError::InvalidOperation(format!(
                    "reward '{}' does not exist for profile '{}'",
                    reward_id, profile_id
                ))
            })?;
            if reward.state == RewardState::Applied {
                return Err(ProgressionError::InvalidOperation(format!(
                    "reward '{}' was already applied",
                    reward_id
                )));
            }
            reward.state = RewardState::Rejected;
            reward.clone()
        };
        self.bump_revision();
        self.push_event(
            "reward_rejected",
            Some(profile_id.to_string()),
            Some(reward_id.to_string()),
            json!({ "rewardId": reward_id, "reason": reason }),
        );
        Ok(reward)
    }
}
