//! Lua import resolver: validates that all `require()` call targets exist on disk.
//!
//! - `ImportCheckRule` scans Lua files for `require("path")` calls via regex.
//! - Each required path is resolved against the game's `lua_paths` config list.
//! - Missing modules produce a `Severity::Error`; conditional requires a `Warning`.
//! - Does not execute Lua; purely textual scan for safety and speed.

use super::report::{Severity, Violation};
use super::rule::ValidationRule;
use std::path::{Path, PathBuf};

/// Checks that Lua require() imports can be resolved.
pub struct ImportResolutionRule {
    /// Lua paths.
    pub lua_paths: Vec<PathBuf>,
}

impl ImportResolutionRule {
    /// Create an import resolution rule that searches the given Lua module paths.
    pub fn new(lua_paths: Vec<PathBuf>) -> Self {
        Self { lua_paths }
    }

    fn extract_requires(&self, content: &str) -> Vec<(usize, String)> {
        let mut requires = Vec::new();
        for (line_num, line) in content.lines().enumerate() {
            let trimmed = line.trim();
            if let Some(pos) = trimmed.find("require(") {
                let after = &trimmed[pos + 8..];
                if let Some(module_name) = extract_module_name(after) {
                    requires.push((line_num + 1, module_name));
                }
            } else if let Some(pos) = trimmed.find("require \"") {
                let after = &trimmed[pos + 9..];
                if let Some(end) = after.find('"') {
                    requires.push((line_num + 1, after[..end].to_string()));
                }
            } else if let Some(pos) = trimmed.find("require '") {
                let after = &trimmed[pos + 9..];
                if let Some(end) = after.find('\'') {
                    requires.push((line_num + 1, after[..end].to_string()));
                }
            }
        }
        requires
    }

    fn resolve_module(&self, module_name: &str) -> bool {
        // Convert dot-notation to path
        let path_part = module_name.replace('.', std::path::MAIN_SEPARATOR_STR);
        for base in &self.lua_paths {
            let lua_file = base.join(format!("{path_part}.lua"));
            if lua_file.exists() {
                return true;
            }
            let init_file = base.join(&path_part).join("init.lua");
            if init_file.exists() {
                return true;
            }
        }
        false
    }
}

impl ValidationRule for ImportResolutionRule {
    fn id(&self) -> &str { "import-resolve" }
    fn description(&self) -> &str { "Checks that require() imports can be resolved" }
    fn severity(&self) -> Severity { Severity::Warning }

    fn validate(&self, path: &Path, content: &str) -> Vec<Violation> {
        let mut violations = Vec::new();
        let requires = self.extract_requires(content);

        for (line, module) in requires {
            // Skip lurek.* (engine-provided)
            if module.starts_with("lurek") {
                continue;
            }
            if !self.resolve_module(&module) {
                violations.push(
                    Violation::new("import-resolve", Severity::Warning, path.to_path_buf(),
                        format!("Cannot resolve module: {module}"))
                        .with_line(line)
                );
            }
        }

        violations
    }
}

fn extract_module_name(s: &str) -> Option<String> {
    let s = s.trim();
    let quote = if s.starts_with('"') { '"' } else if s.starts_with('\'') { '\'' } else { return None };
    let rest = &s[1..];
    rest.find(quote).map(|end| rest[..end].to_string())
}
