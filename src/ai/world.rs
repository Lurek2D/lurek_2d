//! Owns the ai world implementation for the ai subsystem and keeps related runtime rules local here.
//! Keeps AI world state, traits, and decision-facing helpers so helpers stay close to invariants this file updates.
//! Defines how ai world data is validated, transformed, or stored before neighboring systems consume it.
//! Separates ai world behavior from Lua bindings, tests, and sibling owners so integration stays readable.

use crate::ai::agent::Agent;
use crate::patterns::Blackboard;
use std::collections::HashMap;
/// World-level AI registry and update surface.
pub struct AIWorld {
    /// Stored agents in index order.
    pub(crate) agents: Vec<Agent>,
    /// Lookup from agent name to index.
    pub(crate) name_index: HashMap<String, usize>,
    /// Shared blackboard inherited by new agents.
    pub(crate) global_blackboard: Blackboard,
}
impl AIWorld {
    /// Create an empty AI world. This function is part of the public API.
    pub fn new() -> Self {
        Self {
            agents: Vec::new(),
            name_index: HashMap::new(),
            global_blackboard: Blackboard::default(),
        }
    }
    /// Add a named agent and return its index; returns an error on duplicate names.
    pub fn add_agent(&mut self, name: &str) -> Result<usize, String> {
        if self.name_index.contains_key(name) {
            return Err(format!("Agent '{}' already exists", name));
        }
        let idx = self.agents.len();
        let mut agent = Agent::new(name);
        agent.blackboard.set_parent(self.global_blackboard.clone());
        self.agents.push(agent);
        self.name_index.insert(name.to_string(), idx);
        Ok(idx)
    }
    /// Remove an agent by name and rebuild the index map.
    pub fn remove_agent(&mut self, name: &str) -> bool {
        if let Some(&idx) = self.name_index.get(name) {
            self.agents.remove(idx);
            self.name_index.clear();
            for (i, agent) in self.agents.iter().enumerate() {
                self.name_index.insert(agent.name.clone(), i);
            }
            true
        } else {
            false
        }
    }
    /// Return the index of an agent by name.
    pub fn get_agent_index(&self, name: &str) -> Option<usize> {
        self.name_index.get(name).copied()
    }
    /// Return a reference to an agent by name.
    pub fn agent(&self, name: &str) -> Option<&Agent> {
        self.name_index.get(name).map(|&idx| &self.agents[idx])
    }
    /// Return a mutable reference to an agent by name.
    pub fn agent_mut(&mut self, name: &str) -> Option<&mut Agent> {
        if let Some(&idx) = self.name_index.get(name) {
            Some(&mut self.agents[idx])
        } else {
            None
        }
    }
    /// Return the number of agents in the world.
    pub fn agent_count(&self) -> usize {
        self.agents.len()
    }
    /// Return the shared global blackboard.
    pub fn global_blackboard(&self) -> &Blackboard {
        &self.global_blackboard
    }
    /// Return the shared global blackboard mutably.
    pub fn global_blackboard_mut(&mut self) -> &mut Blackboard {
        &mut self.global_blackboard
    }
    /// Advance all agents by integrating velocity and time-based support state over `dt` seconds.
    pub fn update(&mut self, dt: f32) {
        for agent in &mut self.agents {
            agent.position.0 += agent.velocity.0 * dt;
            agent.position.1 += agent.velocity.1 * dt;
            if let Some(profile) = &mut agent.trait_profile {
                profile.update(dt);
            }
        }
    }
}
/// `Default` delegates to `AIWorld::new`.
impl Default for AIWorld {
    /// Build an empty AI world.
    fn default() -> Self {
        Self::new()
    }
}
