//! File extension and path filters for narrowing the search scope.
//!
//! - `FileFilter` accepts `include_extensions`, `exclude_extensions`, and glob patterns.
//! - `FileFilter::matches(path)` is a pure predicate; no I/O at the filter stage.
//! - Hidden files and directories starting with `.` are excluded by default.
//! - Configured from `GrepConfig` or directly by Lua via `lurek.grep.set_filter`.
use std::path::Path;

/// Filter rules for which files to include in search.
#[derive(Debug, Clone)]
pub struct FileFilter {
    /// File extensions to include in the search.
    pub extensions: Vec<String>,
    /// File extensions to exclude from the search.
    pub exclude_extensions: Vec<String>,
    /// Glob patterns for files to include.
    pub include_patterns: Vec<String>,
    /// Glob patterns for files to exclude.
    pub exclude_patterns: Vec<String>,
    /// Maximum file size in bytes to search.
    pub max_file_size: u64,
    /// Whether to include hidden files in the search.
    pub include_hidden: bool,
}

impl FileFilter {
    /// Create a `FileFilter` with permissive defaults (no extension limits, 50 MB cap).
    pub fn new() -> Self {
        Self {
            extensions: Vec::new(),
            exclude_extensions: Vec::new(),
            include_patterns: Vec::new(),
            exclude_patterns: Vec::new(),
            max_file_size: 50 * 1024 * 1024,
            include_hidden: false,
        }
    }

    /// Check if a file path passes the filter.
    pub fn matches(&self, path: &Path) -> bool {
        let path_str = path.to_string_lossy();

        // Check hidden
        if !self.include_hidden {
            if let Some(name) = path.file_name() {
                if name.to_string_lossy().starts_with('.') {
                    return false;
                }
            }
        }

        // Check extension
        if !self.extensions.is_empty() {
            let ext = path.extension().map(|e| e.to_string_lossy().to_lowercase());
            match ext {
                Some(e) => {
                    if !self.extensions.iter().any(|allowed| allowed.to_lowercase() == e) {
                        return false;
                    }
                }
                None => return false,
            }
        }

        // Check excluded extensions
        if let Some(ext) = path.extension() {
            let ext_lower = ext.to_string_lossy().to_lowercase();
            if self.exclude_extensions.iter().any(|ex| ex.to_lowercase() == ext_lower) {
                return false;
            }
        }

        // Check exclude patterns
        for pat in &self.exclude_patterns {
            if path_str.contains(pat.as_str()) {
                return false;
            }
        }

        // Check include patterns
        if !self.include_patterns.is_empty() {
            if !self.include_patterns.iter().any(|pat| path_str.contains(pat.as_str())) {
                return false;
            }
        }

        true
    }

    /// Create a filter for Lua files only.
    pub fn lua_files() -> Self {
        let mut f = Self::new();
        f.extensions.push("lua".to_string());
        f
    }

    /// Create a filter for TOML files only.
    pub fn toml_files() -> Self {
        let mut f = Self::new();
        f.extensions.push("toml".to_string());
        f
    }

    /// Create a filter for common game content files.
    pub fn game_content() -> Self {
        let mut f = Self::new();
        f.extensions = vec![
            "lua".to_string(), "toml".to_string(), "json".to_string(),
            "txt".to_string(), "md".to_string(), "cfg".to_string(),
        ];
        f
    }
}

impl Default for FileFilter {
    fn default() -> Self {
        Self::new()
    }
}
