//! Owns the patterns deck implementation for the patterns subsystem and keeps related runtime rules local here.
//! Keeps pattern data, exported submodules, and navigation helpers so helpers stay close to invariants this file updates.
//! Defines how patterns deck data is validated, transformed, or stored before neighboring systems consume it.
//! Separates patterns deck behavior from Lua bindings, tests, and sibling owners so integration stays readable.

/// Reusable deck state backed by stable card ids.
#[derive(Debug, Clone, Default)]
pub struct Deck {
    original: Vec<u64>,
    draw: Vec<u64>,
    discard: Vec<u64>,
    next_id: u64,
}

impl Deck {
    /// Create an empty deck.
    pub fn new() -> Self {
        Self {
            original: Vec::new(),
            draw: Vec::new(),
            discard: Vec::new(),
            next_id: 1,
        }
    }

    /// Add one card id to the original order and current draw pile.
    pub fn add(&mut self) -> u64 {
        let id = self.next_id;
        self.next_id = self.next_id.saturating_add(1).max(1);
        self.original.push(id);
        self.draw.push(id);
        id
    }

    /// Shuffle the current draw pile using a deterministic xorshift generator.
    pub fn shuffle(&mut self, seed: u64) {
        let mut state = if seed == 0 {
            0x9E37_79B9_7F4A_7C15
        } else {
            seed
        };
        for i in (1..self.draw.len()).rev() {
            state ^= state << 13;
            state ^= state >> 7;
            state ^= state << 17;
            let j = (state as usize) % (i + 1);
            self.draw.swap(i, j);
        }
    }

    /// Draw up to `count` card ids from the top of the draw pile.
    pub fn draw(&mut self, count: usize) -> Vec<u64> {
        let n = count.min(self.draw.len());
        self.draw.drain(0..n).collect()
    }

    /// Return up to `count` card ids from the top without removing them.
    pub fn peek(&self, count: usize) -> Vec<u64> {
        self.draw.iter().take(count).copied().collect()
    }

    /// Move a known card id into the discard pile if not already discarded.
    pub fn discard(&mut self, id: u64) -> bool {
        self.draw.retain(|&card_id| card_id != id);
        if !self.discard.contains(&id) && self.original.contains(&id) {
            self.discard.push(id);
            return true;
        }
        false
    }

    /// Restore draw pile to original order and clear discard.
    pub fn reset(&mut self) {
        self.draw = self.original.clone();
        self.discard.clear();
    }

    /// Return card ids currently available to draw.
    pub fn draw_ids(&self) -> &[u64] {
        &self.draw
    }

    /// Return the number of cards in the draw pile.
    pub fn count(&self) -> usize {
        self.draw.len()
    }

    /// Return the number of cards in the discard pile.
    pub fn discard_count(&self) -> usize {
        self.discard.len()
    }

    /// Return true when there are no cards left to draw.
    pub fn is_empty(&self) -> bool {
        self.draw.is_empty()
    }
}
