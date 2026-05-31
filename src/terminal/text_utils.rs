//! Shared text helpers used across the terminal subsystem.
//! These helpers centralize UTF-8-safe character counting, truncation, and indexing logic.

/// Return the number of Unicode scalar values in `text`.
pub(crate) fn char_count(text: &str) -> usize {
    text.chars().count()
}

/// Return the byte offset in `text` corresponding to `char_index`.
/// Returns `text.len()` when `char_index` is out of range.
pub(crate) fn byte_index(text: &str, char_index: usize) -> usize {
    text.char_indices()
        .nth(char_index)
        .map(|(idx, _)| idx)
        .unwrap_or(text.len())
}

/// Return a new `String` containing at most `max_chars` Unicode chars from `text`.
pub(crate) fn truncate_chars(text: &str, max_chars: usize) -> String {
    text.chars().take(max_chars).collect()
}

/// Return the display width in characters for `text`, always at least 1.
pub(crate) fn text_width_at_least_one(text: &str) -> usize {
    char_count(text).max(1)
}

/// Return the byte length of a UTF-8 character given its leading byte.
pub(crate) fn utf8_char_len(byte: u8) -> usize {
    if byte < 0x80 {
        1
    } else if byte < 0xE0 {
        2
    } else if byte < 0xF0 {
        3
    } else {
        4
    }
}
