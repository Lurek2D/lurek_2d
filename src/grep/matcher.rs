//! Low-level pattern matcher: wraps all supported pattern kinds behind one trait.
//!
//! - Data type: `Matcher`.
//! - Implementation: `Matcher`.
//! - Public methods: `new`, `matches_line`, `find_positions`.

use super::pattern::PatternKind;

/// Compiled matcher ready to search text.
#[derive(Debug, Clone)]
pub struct Matcher {
    kind: PatternKind,
    case_sensitive: bool,
    whole_word: bool,
}

impl Matcher {
    /// Create a `Matcher` from a `PatternKind` with case-sensitivity and whole-word options.
    pub fn new(pattern: PatternKind, case_sensitive: bool, whole_word: bool) -> Self {
        Self { kind: pattern, case_sensitive, whole_word }
    }

    /// Test if a line matches the pattern.
    pub fn matches_line(&self, line: &str) -> bool {
        match &self.kind {
            PatternKind::Literal(pat) => self.literal_match(line, pat),
            PatternKind::Regex(pat) => self.regex_match(line, pat),
            PatternKind::Glob(pat) => self.glob_match(line, pat),
            PatternKind::Fuzzy { pattern, max_distance } => self.fuzzy_match(line, pattern, *max_distance),
            PatternKind::MultiLiteral(pats) => pats.iter().any(|p| self.literal_match(line, p)),
        }
    }

    /// Find all match positions in a line. Returns (start, end) byte offsets.
    pub fn find_positions(&self, line: &str) -> Vec<(usize, usize)> {
        match &self.kind {
            PatternKind::Literal(pat) => self.literal_positions(line, pat),
            PatternKind::MultiLiteral(pats) => {
                let mut all = Vec::new();
                for p in pats {
                    all.extend(self.literal_positions(line, p));
                }
                all.sort_by_key(|&(start, _)| start);
                all
            }
            _ => {
                // For regex/glob/fuzzy, return whole line if matches
                if self.matches_line(line) {
                    vec![(0, line.len())]
                } else {
                    Vec::new()
                }
            }
        }
    }

    fn literal_match(&self, line: &str, pattern: &str) -> bool {
        let (haystack, needle) = if self.case_sensitive {
            (line.to_string(), pattern.to_string())
        } else {
            (line.to_lowercase(), pattern.to_lowercase())
        };

        if self.whole_word {
            haystack.split_whitespace().any(|w| w == needle)
        } else {
            haystack.contains(&needle)
        }
    }

    fn literal_positions(&self, line: &str, pattern: &str) -> Vec<(usize, usize)> {
        let mut positions = Vec::new();
        let (haystack, needle) = if self.case_sensitive {
            (line.to_string(), pattern.to_string())
        } else {
            (line.to_lowercase(), pattern.to_lowercase())
        };

        let mut start = 0;
        while let Some(pos) = haystack[start..].find(&needle) {
            let abs_pos = start + pos;
            positions.push((abs_pos, abs_pos + needle.len()));
            start = abs_pos + 1;
        }
        positions
    }

    fn regex_match(&self, line: &str, pattern: &str) -> bool {
        // Simple regex: check if pattern chars appear in sequence
        // Full regex would require the regex crate; here we do basic wildcard matching
        let line_lower = if self.case_sensitive { line.to_string() } else { line.to_lowercase() };
        let pat_lower = if self.case_sensitive { pattern.to_string() } else { pattern.to_lowercase() };
        simple_regex_match(&line_lower, &pat_lower)
    }

    fn glob_match(&self, line: &str, pattern: &str) -> bool {
        let line_lower = if self.case_sensitive { line.to_string() } else { line.to_lowercase() };
        let pat_lower = if self.case_sensitive { pattern.to_string() } else { pattern.to_lowercase() };
        glob_matches(&line_lower, &pat_lower)
    }

    fn fuzzy_match(&self, line: &str, pattern: &str, max_distance: usize) -> bool {
        let line_lower = if self.case_sensitive { line.to_string() } else { line.to_lowercase() };
        let pat_lower = if self.case_sensitive { pattern.to_string() } else { pattern.to_lowercase() };
        // Check if any substring of line is within edit distance
        if pat_lower.len() > line_lower.len() + max_distance {
            return false;
        }
        // Sliding window approximation
        let pat_len = pat_lower.len();
        let chars: Vec<char> = line_lower.chars().collect();
        let pat_chars: Vec<char> = pat_lower.chars().collect();
        if chars.is_empty() || pat_chars.is_empty() {
            return false;
        }
        for window_start in 0..=chars.len().saturating_sub(pat_len.saturating_sub(max_distance)) {
            let window_end = (window_start + pat_len + max_distance).min(chars.len());
            let window: String = chars[window_start..window_end].iter().collect();
            if edit_distance(&window, &pat_lower) <= max_distance {
                return true;
            }
        }
        false
    }
}

/// Simple regex matching supporting . and * only.
fn simple_regex_match(text: &str, pattern: &str) -> bool {
    let pat_chars: Vec<char> = pattern.chars().collect();
    let text_chars: Vec<char> = text.chars().collect();
    regex_helper(&text_chars, &pat_chars, 0, 0)
}

fn regex_helper(text: &[char], pattern: &[char], ti: usize, pi: usize) -> bool {
    if pi >= pattern.len() {
        return true; // Pattern exhausted = match (substring search)
    }
    if ti >= text.len() {
        // Check if remaining pattern is all *
        return pattern[pi..].iter().all(|&c| c == '*');
    }
    match pattern[pi] {
        '.' => regex_helper(text, pattern, ti + 1, pi + 1),
        '*' => {
            // Match zero or more of anything
            regex_helper(text, pattern, ti, pi + 1) || regex_helper(text, pattern, ti + 1, pi)
        }
        c => {
            if text[ti] == c {
                regex_helper(text, pattern, ti + 1, pi + 1)
            } else {
                // Try starting match at next position
                regex_helper(text, pattern, ti + 1, 0)
            }
        }
    }
}

/// Simple glob matching: * matches any sequence, ? matches one char.
fn glob_matches(text: &str, pattern: &str) -> bool {
    let t: Vec<char> = text.chars().collect();
    let p: Vec<char> = pattern.chars().collect();
    glob_helper(&t, &p, 0, 0)
}

fn glob_helper(text: &[char], pattern: &[char], ti: usize, pi: usize) -> bool {
    if pi >= pattern.len() {
        return ti >= text.len();
    }
    if pattern[pi] == '*' {
        // Try matching zero or more characters
        for i in ti..=text.len() {
            if glob_helper(text, pattern, i, pi + 1) {
                return true;
            }
        }
        return false;
    }
    if ti >= text.len() {
        return false;
    }
    if pattern[pi] == '?' || pattern[pi] == text[ti] {
        glob_helper(text, pattern, ti + 1, pi + 1)
    } else {
        false
    }
}

/// Levenshtein edit distance.
fn edit_distance(a: &str, b: &str) -> usize {
    let a_chars: Vec<char> = a.chars().collect();
    let b_chars: Vec<char> = b.chars().collect();
    let m = a_chars.len();
    let n = b_chars.len();
    let mut dp = vec![vec![0usize; n + 1]; m + 1];
    for (i, row) in dp.iter_mut().enumerate().take(m + 1) { row[0] = i; }
    for (j, cell) in dp[0].iter_mut().enumerate().take(n + 1) { *cell = j; }
    for i in 1..=m {
        for j in 1..=n {
            let cost = if a_chars[i - 1] == b_chars[j - 1] { 0 } else { 1 };
            dp[i][j] = (dp[i - 1][j] + 1)
                .min(dp[i][j - 1] + 1)
                .min(dp[i - 1][j - 1] + cost);
        }
    }
    dp[m][n]
}
