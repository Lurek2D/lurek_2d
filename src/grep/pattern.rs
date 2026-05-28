//! Pattern kinds: literal, regex, glob, fuzzy, and multi-literal match strategies.
//!
//! - `PatternKind` is the discriminant stored in `Matcher` to select dispatch logic.
//! - `Literal` and `MultiLiteral` use Aho-Corasick for sub-linear multi-pattern search.
//! - `Regex` wraps the `regex` crate; patterns are validated at construction time.
//! - `Glob` converts shell-style `*`/`?` patterns to a regex and reuses the regex path.
//! - `Fuzzy` uses Levenshtein distance with a configurable `max_edit_distance`.

/// Kind of search pattern: literal, regex, glob, fuzzy, or multi-literal.
#[derive(Debug, Clone)]
pub enum PatternKind {
    /// Exact literal string match.
    Literal(String),
    /// Regular expression pattern.
    Regex(String),
    /// Glob pattern (e.g., "*.lua").
    Glob(String),
    /// Fuzzy approximate match with max edit distance.
    Fuzzy { pattern: String, max_distance: usize },
    /// Multiple literal patterns (Aho-Corasick style).
    MultiLiteral(Vec<String>),
}

impl PatternKind {
    /// Create a literal exact-string search pattern.
    pub fn literal(s: impl Into<String>) -> Self {
        Self::Literal(s.into())
    }

    /// Create a regular expression search pattern.
    pub fn regex(s: impl Into<String>) -> Self {
        Self::Regex(s.into())
    }

    /// Create a glob file-path filter pattern (e.g., `"*.lua"`).
    pub fn glob(s: impl Into<String>) -> Self {
        Self::Glob(s.into())
    }

    /// Create a fuzzy approximate-match pattern with a maximum edit distance.
    pub fn fuzzy(s: impl Into<String>, max_distance: usize) -> Self {
        Self::Fuzzy { pattern: s.into(), max_distance }
    }

    /// Create a multi-literal OR pattern that matches if any of the given strings is found.
    pub fn multi_literal(patterns: Vec<String>) -> Self {
        Self::MultiLiteral(patterns)
    }
}
