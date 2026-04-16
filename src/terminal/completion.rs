//! Tab-completion engine for the terminal module.
//!
//! [`CompletionEngine`] maintains a sorted list of candidate strings and, given a
//! partial input prefix, returns all candidates that start with that prefix.
//!
//! The engine cycles through matches on repeated calls to [`CompletionEngine::next_completion`],
//! which enables the classic "press Tab again to cycle" UX pattern.
//!
//! ## Usage
//! ```text
//! let mut engine = CompletionEngine::new();
//! engine.add_candidate("help");
//! engine.add_candidate("hello");
//! engine.add_candidate("quit");
//!
//! let first = engine.next_completion("hel");   // Some("hello") or "help"
//! let second = engine.next_completion("hel");  // cycles to the other candidate
//! engine.reset();                               // clear cycle state
//! ```

// -------------------------------------------------------------------------------
// Types
// -------------------------------------------------------------------------------

/// Maintains a list of completion candidates and a per-prefix cycling cursor.
pub struct CompletionEngine {
    /// Sorted list of completion candidates.
    candidates: Vec<String>,
    /// Last prefix used for cycling, paired with the current cycle index.
    cycle_state: Option<(String, usize)>,
}

impl CompletionEngine {
    /// Creates an empty [`CompletionEngine`].
    pub fn new() -> Self {
        Self {
            candidates: Vec::new(),
            cycle_state: None,
        }
    }

    /// Adds a completion candidate string.
    ///
    /// Duplicate candidates are ignored.  The internal list is kept sorted for
    /// consistent cycling order.
    ///
    /// # Parameters
    /// - `candidate` — `&str`. The completion string to register.
    pub fn add_candidate(&mut self, candidate: &str) {
        if !self.candidates.contains(&candidate.to_string()) {
            self.candidates.push(candidate.to_string());
            self.candidates.sort();
        }
    }

    /// Removes a candidate, if present.  Resets the cycle state.
    ///
    /// # Parameters
    /// - `candidate` — `&str`.
    pub fn remove_candidate(&mut self, candidate: &str) {
        self.candidates.retain(|c| c != candidate);
        self.cycle_state = None;
    }

    /// Clears all candidates and resets cycle state.
    pub fn clear(&mut self) {
        self.candidates.clear();
        self.cycle_state = None;
    }

    /// Returns the number of registered candidates.
    pub fn len(&self) -> usize {
        self.candidates.len()
    }

    /// Returns `true` if no candidates are registered.
    pub fn is_empty(&self) -> bool {
        self.candidates.is_empty()
    }

    /// Returns all candidates that start with `prefix`, in sorted order.
    ///
    /// # Parameters
    /// - `prefix` — `&str`. The typed input prefix to complete.
    ///
    /// # Returns
    /// `Vec<String>` — zero or more candidates.
    pub fn completions_for(&self, prefix: &str) -> Vec<String> {
        self.candidates
            .iter()
            .filter(|c| c.starts_with(prefix))
            .cloned()
            .collect()
    }

    /// Returns the next candidate for `prefix`, cycling on repeated calls with the
    /// same prefix.  Returns `None` if there are no matches.
    ///
    /// Cycle state is reset whenever the prefix changes.
    ///
    /// # Parameters
    /// - `prefix` — `&str`. The current typed input.
    ///
    /// # Returns
    /// `Option<String>` — the next matching candidate, or `None`.
    pub fn next_completion(&mut self, prefix: &str) -> Option<String> {
        let matches = self.completions_for(prefix);
        if matches.is_empty() {
            self.cycle_state = None;
            return None;
        }

        let idx = match &self.cycle_state {
            Some((last_prefix, last_idx)) if last_prefix == prefix => {
                (last_idx + 1) % matches.len()
            }
            _ => 0,
        };

        self.cycle_state = Some((prefix.to_string(), idx));
        Some(matches[idx].clone())
    }

    /// Resets the cycling cursor without clearing candidates.
    pub fn reset(&mut self) {
        self.cycle_state = None;
    }
}

impl Default for CompletionEngine {
    fn default() -> Self {
        Self::new()
    }
}

// -------------------------------------------------------------------------------
// Tests
// -------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_engine_returns_no_completions() {
        let e = CompletionEngine::new();
        assert!(e.completions_for("he").is_empty());
    }

    #[test]
    fn single_match_returned() {
        let mut e = CompletionEngine::new();
        e.add_candidate("help");
        assert_eq!(e.completions_for("hel"), vec!["help"]);
    }

    #[test]
    fn multiple_matches_sorted() {
        let mut e = CompletionEngine::new();
        e.add_candidate("hello");
        e.add_candidate("help");
        let got = e.completions_for("hel");
        assert_eq!(got, vec!["hello", "help"]);
    }

    #[test]
    fn next_completion_cycles_on_repeated_calls() {
        let mut e = CompletionEngine::new();
        e.add_candidate("hello");
        e.add_candidate("help");
        let first = e.next_completion("hel").unwrap();
        let second = e.next_completion("hel").unwrap();
        assert_ne!(first, second);
    }

    #[test]
    fn next_completion_resets_on_prefix_change() {
        let mut e = CompletionEngine::new();
        e.add_candidate("hello");
        e.add_candidate("world");
        let _ = e.next_completion("hel");
        let w = e.next_completion("wor").unwrap();
        assert_eq!(w, "world");
    }

    #[test]
    fn remove_candidate_removes_it() {
        let mut e = CompletionEngine::new();
        e.add_candidate("help");
        e.remove_candidate("help");
        assert!(e.completions_for("hel").is_empty());
    }
}
