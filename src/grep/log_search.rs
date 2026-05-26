//! Structured log file search with level, time-range, and text pattern filters.
//!
//! - `parse_log_lines` parses lines of the form `[LEVEL TIMESTAMP] MESSAGE`.
//! - `search_logs` filters `Vec<LogEntry>` by level, time bounds, and text pattern.
//! - `LogSearchOpts` drives the filter; all fields are optional (zero = no filter).
//! - Used by `lurek.grep.logs` to let game scripts query the engine's runtime log.
/// A single parsed log entry with line number, timestamp, level, and message.
#[derive(Debug, Clone)]
pub struct LogEntry {
    /// Line number (1-based) in the source file.
    pub line_number: usize,
    /// Log entry timestamp string.
    pub timestamp: Option<String>,
    /// Log entry severity level.
    pub level: Option<String>,
    /// Log message text.
    pub message: String,
}

/// Options for filtering log search by level, time range, and text pattern.
#[derive(Debug, Clone)]
pub struct LogSearchOpts {
    /// Minimum severity level to include in results.
    pub level_filter: Option<String>,
    /// Include only log entries after this timestamp.
    pub time_after: Option<String>,
    /// Include only log entries before this timestamp.
    pub time_before: Option<String>,
    /// Search pattern string.
    pub pattern: Option<String>,
    /// Number of context lines around each match.
    pub context_lines: usize,
}

impl LogSearchOpts {
    /// Create `LogSearchOpts` with no filters and zero context lines.
    pub fn new() -> Self {
        Self {
            level_filter: None,
            time_after: None,
            time_before: None,
            pattern: None,
            context_lines: 0,
        }
    }
}

impl Default for LogSearchOpts {
    fn default() -> Self {
        Self::new()
    }
}

/// Parse log lines into structured entries.
pub fn parse_log_lines(lines: &[String]) -> Vec<LogEntry> {
    let mut entries = Vec::new();

    for (idx, line) in lines.iter().enumerate() {
        let trimmed = line.trim();
        if trimmed.is_empty() {
            continue;
        }

        let (timestamp, level, message) = parse_log_line(trimmed);
        entries.push(LogEntry {
            line_number: idx + 1,
            timestamp,
            level,
            message,
        });
    }

    entries
}

/// Search log entries with filters.
pub fn search_logs<'a>(entries: &'a [LogEntry], opts: &LogSearchOpts) -> Vec<&'a LogEntry> {
    entries.iter().filter(|entry| {
        // Level filter
        if let Some(ref level) = opts.level_filter {
            match &entry.level {
                Some(el) => {
                    if !el.eq_ignore_ascii_case(level) {
                        return false;
                    }
                }
                None => return false,
            }
        }

        // Pattern filter
        if let Some(ref pat) = opts.pattern {
            if !entry.message.to_lowercase().contains(&pat.to_lowercase()) {
                return false;
            }
        }

        // Time filters (string comparison - assumes ISO-like format)
        if let Some(ref after) = opts.time_after {
            if let Some(ref ts) = entry.timestamp {
                if ts.as_str() < after.as_str() {
                    return false;
                }
            }
        }
        if let Some(ref before) = opts.time_before {
            if let Some(ref ts) = entry.timestamp {
                if ts.as_str() > before.as_str() {
                    return false;
                }
            }
        }

        true
    }).collect()
}

/// Parse a single log line into (timestamp, level, message).
fn parse_log_line(line: &str) -> (Option<String>, Option<String>, String) {
    // Try common formats: [TIMESTAMP] [LEVEL] message
    // or: TIMESTAMP LEVEL message
    // or: [LEVEL] message

    let trimmed = line.trim();

    // Format: [2024-01-01 12:00:00] [INFO] message
    if trimmed.starts_with('[') {
        let mut parts = Vec::new();
        let mut rest = trimmed;
        while rest.starts_with('[') {
            if let Some(end) = rest.find(']') {
                parts.push(&rest[1..end]);
                rest = rest[end + 1..].trim_start();
            } else {
                break;
            }
        }

        return match parts.len() {
            0 => (None, None, trimmed.to_string()),
            1 => {
                let p = parts[0];
                if is_log_level(p) {
                    (None, Some(p.to_uppercase()), rest.to_string())
                } else {
                    (Some(p.to_string()), None, rest.to_string())
                }
            }
            _ => {
                let ts = parts[0].to_string();
                let lvl = parts[1].to_uppercase();
                (Some(ts), Some(lvl), rest.to_string())
            }
        };
    }

    // Format: 2024-01-01T12:00:00 INFO message
    if let Some(space_pos) = trimmed.find(' ') {
        let first = &trimmed[..space_pos];
        if first.len() >= 10 && (first.contains('-') || first.contains('T')) {
            let rest = &trimmed[space_pos + 1..];
            if let Some(space2) = rest.find(' ') {
                let level_candidate = &rest[..space2];
                if is_log_level(level_candidate) {
                    return (
                        Some(first.to_string()),
                        Some(level_candidate.to_uppercase()),
                        rest[space2 + 1..].to_string(),
                    );
                }
            }
            return (Some(first.to_string()), None, rest.to_string());
        }
    }

    (None, None, trimmed.to_string())
}

fn is_log_level(s: &str) -> bool {
    matches!(
        s.to_uppercase().as_str(),
        "TRACE" | "DEBUG" | "INFO" | "WARN" | "WARNING" | "ERROR" | "FATAL" | "CRITICAL"
    )
}
