//! Fog of war system operating at province granularity.
//!
//! Each province has a [`FogState`] — Hidden, Explored, or Visible — managed by
//! the [`FogOfWar`] controller. Supports BFS-based radius reveal on the
//! adjacency graph and direct pixel-buffer modification for rendering.

use std::collections::{HashMap, VecDeque};

use super::core::ProvinceMap;

/// Visibility state of a province.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub enum FogState {
    /// Province is completely hidden — not explored, no information visible.
    #[default]
    Hidden,
    /// Province has been visited before but is not currently visible.
    Explored,
    /// Province is currently visible with full information.
    Visible,
}

/// Fog of war controller mapping each province to a visibility state.
#[derive(Debug, Clone, Default)]
pub struct FogOfWar {
    state: HashMap<u32, FogState>,
}

impl FogOfWar {
    /// Create a new fog of war controller with all provinces hidden.
    pub fn new() -> Self {
        Self::default()
    }

    /// Get the fog state for a province. Returns [`FogState::Hidden`] for
    /// unknown province IDs.
    pub fn get(&self, id: u32) -> FogState {
        self.state.get(&id).copied().unwrap_or(FogState::Hidden)
    }

    /// Set the fog state for a province.
    pub fn set(&mut self, id: u32, state: FogState) {
        self.state.insert(id, state);
    }

    /// Set a province to [`FogState::Visible`].
    pub fn reveal(&mut self, id: u32) {
        self.state.insert(id, FogState::Visible);
    }

    /// Set a province to [`FogState::Explored`].
    pub fn explore(&mut self, id: u32) {
        self.state.insert(id, FogState::Explored);
    }

    /// Set a province to [`FogState::Hidden`].
    pub fn hide(&mut self, id: u32) {
        self.state.insert(id, FogState::Hidden);
    }

    /// Reveal all provinces within `radius` adjacency hops of `center`.
    ///
    /// Uses BFS on the province adjacency graph. The `center` province itself
    /// is included at distance 0.
    pub fn reveal_radius(&mut self, map: &ProvinceMap, center: u32, radius: u32) {
        let mut queue = VecDeque::new();
        let mut visited: HashMap<u32, u32> = HashMap::new();

        queue.push_back((center, 0u32));
        visited.insert(center, 0);

        while let Some((current, dist)) = queue.pop_front() {
            self.reveal(current);

            if dist < radius {
                for neighbor in map.get_neighbors(current) {
                    if !visited.contains_key(&neighbor) {
                        visited.insert(neighbor, dist + 1);
                        queue.push_back((neighbor, dist + 1));
                    }
                }
            }
        }
    }

    /// Modify an RGBA pixel buffer in-place according to fog state.
    ///
    /// - **Explored**: darken by 50% (multiply RGB by 0.5).
    /// - **Hidden**: set to black `(0, 0, 0, 255)`.
    /// - **Visible**: no modification.
    ///
    /// The buffer must have exactly `width × height × 4` bytes in RGBA order.
    pub fn apply_to_pixels(&self, pixels: &mut [u8], map: &ProvinceMap) {
        let lookup = map.pixel_lookup();
        for (idx, &pid) in lookup.iter().enumerate() {
            if pid == 0 {
                continue;
            }
            let base = idx * 4;
            if base + 3 >= pixels.len() {
                break;
            }
            match self.get(pid) {
                FogState::Visible => {} // no change
                FogState::Explored => {
                    pixels[base] = pixels[base] / 2;
                    pixels[base + 1] = pixels[base + 1] / 2;
                    pixels[base + 2] = pixels[base + 2] / 2;
                }
                FogState::Hidden => {
                    pixels[base] = 0;
                    pixels[base + 1] = 0;
                    pixels[base + 2] = 0;
                    pixels[base + 3] = 255;
                }
            }
        }
    }
}
