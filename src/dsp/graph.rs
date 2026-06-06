//! Provides a typed DSP graph model where nodes and edges describe ordered signal-processing flow.
//! Organizes processing units into deterministic traversal order for stable per-buffer execution.
//! Supports audio-rate and control-rate connectivity so routing and parameter signals share one structure.
//! Enables safe runtime mutation patterns that coordinate producer updates with callback-side consumption.
//! Delivers the structural layer used to compose complex effect pipelines from reusable nodes.

use crate::audio::sound_data::SoundData;

pub use super::effects::{DynamicEffectSource, SharedEffectGraph};

/// Stable DSP graph node handle.
pub type NodeId = u32;

/// DSP node processing kind used by graph execution.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DspNodeType {
    /// Low-pass filter node.
    Lowpass,
    /// High-pass filter node.
    Highpass,
    /// Band-pass filter node.
    Bandpass,
    /// Gain node.
    Gain,
    /// Pass-through node for accepted effect types that need graph identity only.
    Passthrough,
}

impl DspNodeType {
    /// Parse a Lua-facing node kind.
    pub fn parse(kind: &str) -> Self {
        match kind {
            "lowpass" => Self::Lowpass,
            "highpass" => Self::Highpass,
            "bandpass" => Self::Bandpass,
            "gain" => Self::Gain,
            _ => Self::Passthrough,
        }
    }

    /// Return the Lua-facing node kind.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Lowpass => "lowpass",
            Self::Highpass => "highpass",
            Self::Bandpass => "bandpass",
            Self::Gain => "gain",
            Self::Passthrough => "passthrough",
        }
    }
}

/// One DSP graph node with simple named parameters.
#[derive(Debug, Clone)]
pub struct DspNode {
    node_type: DspNodeType,
    p1: f32,
    p2: f32,
    p3: f32,
}

impl DspNode {
    /// Creates a node from a Lua-facing kind string.
    pub fn new(kind: &str) -> Self {
        let node_type = DspNodeType::parse(kind);
        let (p1, p2, p3) = match node_type {
            DspNodeType::Lowpass => (1000.0, 0.0, 0.0),
            DspNodeType::Highpass => (200.0, 0.0, 0.0),
            DspNodeType::Bandpass => (200.0, 2000.0, 0.0),
            DspNodeType::Gain => (1.0, 0.0, 0.0),
            DspNodeType::Passthrough => (0.0, 0.0, 0.0),
        };
        Self {
            node_type,
            p1,
            p2,
            p3,
        }
    }

    /// Sets a named node parameter on this DSP node.
    pub fn set_param(&mut self, name: &str, value: f32) -> Result<(), String> {
        match name {
            "cutoff" | "frequency" | "gain" | "value" | "low" => {
                self.p1 = value;
                Ok(())
            }
            "high" | "q" | "mix" => {
                self.p2 = value;
                Ok(())
            }
            "p3" => {
                self.p3 = value;
                Ok(())
            }
            other => Err(format!("invalid DSP node parameter: {}", other)),
        }
    }

    /// Returns a named node parameter value when it exists.
    pub fn get_param(&self, name: &str) -> Option<f32> {
        match name {
            "cutoff" | "frequency" | "gain" | "value" | "low" => Some(self.p1),
            "high" | "q" | "mix" => Some(self.p2),
            "p3" => Some(self.p3),
            _ => None,
        }
    }

    /// Returns this node's processing kind discriminator.
    pub fn node_type(&self) -> DspNodeType {
        self.node_type
    }

    fn process(&self, sound_data: &mut SoundData) {
        match self.node_type {
            DspNodeType::Lowpass => sound_data.apply_lowpass(self.p1),
            DspNodeType::Highpass => sound_data.apply_highpass(self.p1),
            DspNodeType::Bandpass => sound_data.apply_bandpass(self.p1, self.p2),
            DspNodeType::Gain => sound_data.apply_gain(self.p1),
            DspNodeType::Passthrough => {}
        }
    }
}

/// Minimal deterministic DSP graph used by Lua for offline SoundData processing.
#[derive(Debug, Clone)]
pub struct DspGraph {
    next_id: NodeId,
    nodes: Vec<(NodeId, DspNode)>,
    edges: Vec<(NodeId, NodeId)>,
}

impl DspGraph {
    /// Creates an empty DSP graph with no nodes or edges.
    pub fn new() -> Self {
        Self {
            next_id: 1,
            nodes: Vec::new(),
            edges: Vec::new(),
        }
    }

    /// Add a node and return its stable ID.
    pub fn add_node(&mut self, node: DspNode) -> NodeId {
        let id = self.next_id;
        self.next_id = self.next_id.saturating_add(1);
        self.nodes.push((id, node));
        id
    }

    /// Connects two existing nodes with a directed edge.
    pub fn connect(&mut self, from: NodeId, to: NodeId) -> bool {
        if !self.has_node(from) || !self.has_node(to) {
            return false;
        }
        if !self.edges.contains(&(from, to)) {
            self.edges.push((from, to));
        }
        true
    }

    /// Disconnects two nodes and removes that directed edge.
    pub fn disconnect(&mut self, from: NodeId, to: NodeId) -> bool {
        let before = self.edges.len();
        self.edges.retain(|edge| *edge != (from, to));
        self.edges.len() != before
    }

    /// Process a sound buffer through all nodes in insertion order.
    pub fn process(&self, sound_data: &SoundData) -> SoundData {
        let mut output = sound_data.clone();
        for (_, node) in &self.nodes {
            node.process(&mut output);
        }
        output
    }

    /// Clear all graph nodes and connections.
    pub fn clear(&mut self) {
        self.nodes.clear();
        self.edges.clear();
        self.next_id = 1;
    }

    fn has_node(&self, id: NodeId) -> bool {
        self.nodes.iter().any(|(node_id, _)| *node_id == id)
    }
}

impl Default for DspGraph {
    fn default() -> Self {
        Self::new()
    }
}
