//! Owns pending, claimed, applied, and rejected reward records that progression systems queue for profiles.
//! Defines the store entrypoints that list reward work and drive the claim-apply-reject state machine.
//! Emits reward lifecycle events without applying game-specific inventory, economy, or unlock side effects.
//! Keeps shared reward transitions separate from achievements and quests so producers stay decoupled from payout flow.
//! Open this file when changing reward idempotency, external receipts, or the public reward-management API surface.
use super::*;

impl ProgressionStore {
    /// Return pending reward records for one profile.
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

    /// Move a pending reward into claimed state.
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

    /// Mark a claimed reward as applied by game code.
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

    /// Reject a reward instead of applying it.
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
