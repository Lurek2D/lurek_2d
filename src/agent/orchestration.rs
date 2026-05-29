//! Agent orchestration logic extracted from Lua runtime glue.
//! Owns batch-task data contracts, callback ID packing, and system-context assembly.
//! This module is runtime-agnostic and intentionally free of `mlua` types.

use crate::agent::{AISystemState, AgentState};
use std::collections::HashMap;

/// One queued batch task derived from an agent configuration.
#[derive(Clone)]
pub struct AgentBatchTask {
    /// Position index used to key the result in the batch output table.
    pub agent_idx: usize,
    /// Instruction sent to the LLM.
    pub instruction: String,
    /// Agent state snapshot for this task.
    pub state: AgentState,
    /// Optional pre-built system block that overrides the agent's own context assembly.
    pub system_override: Option<String>,
}

/// Encodes `(batch_id, task_idx)` into a single callback ID.
pub fn pack_batch_callback_id(batch_id: usize, task_idx: usize) -> usize {
    (batch_id * 1000) + task_idx
}

/// Decodes a packed callback ID back into `(batch_id, task_idx)`.
pub fn unpack_batch_callback_id(callback_id: usize) -> (usize, usize) {
    (callback_id / 1000, callback_id % 1000)
}

/// Builds the system context block for the given prompt and optional target agent.
pub fn build_system_context(
    system_state: &AISystemState,
    agents: &HashMap<String, AgentState>,
    instruction: &str,
    include_instructions: &[String],
    agent_name: Option<&str>,
) -> String {
    let mut block = system_state.build_context(instruction, include_instructions);

    if let Some(name) = agent_name {
        if let Some(agent) = agents.get(name) {
            if !agent.description.is_empty() {
                block.push_str(&format!("\n\n[Agent: {}]:\n{}", name, agent.description));
            }
            let agent_system = agent.build_system_block();
            if !agent_system.is_empty() {
                block.push_str(&format!("\n\n{}", agent_system));
            }
        }
    }

    block
}

/// Builds a batch task for a named agent, injecting system context.
pub fn make_system_task(
    system_state: &AISystemState,
    agents: &HashMap<String, AgentState>,
    agent_name: &str,
    task_idx: usize,
    instruction: String,
    include_instructions: &[String],
) -> Result<AgentBatchTask, String> {
    let agent = agents
        .get(agent_name)
        .ok_or_else(|| format!("agent '{}' not found", agent_name))?
        .clone();

    let system_block = build_system_context(
        system_state,
        agents,
        &instruction,
        include_instructions,
        Some(agent_name),
    );

    Ok(AgentBatchTask {
        agent_idx: task_idx,
        instruction,
        state: agent,
        system_override: Some(system_block),
    })
}
