//! Validation engine: orchestrates rule execution across file trees with parallel workers.
//!
//! - `ValidationEngine` loads config, builds the rule set, and calls `parallel::validate_parallel`.
//! - Returns a `ValidationReport` aggregating all violations from all rules and files.
//! - Custom Lua rules registered via `lurek.validator.add_rule` are injected here.
//! - Used by `lurek.validator.run()` and the `python tools/validate/` quality gate.
use super::asset_check::AssetExistenceRule;
use super::api_check::ApiComplianceRule;
use super::config::ValidatorConfig;
use super::import_check::ImportResolutionRule;
use super::parallel::{collect_lua_files, validate_parallel};
use super::report::ValidationReport;
use super::rule::ValidationRule;
use super::rules_lua::LuaPatternRule;
use super::rules_toml;
use std::path::{Path, PathBuf};
use std::sync::Arc;

/// Main validation engine that manages rules and executes validation.
pub struct ValidationEngine {
    config: ValidatorConfig,
    rules: Vec<Arc<dyn ValidationRule>>,
    root: PathBuf,
}

impl ValidationEngine {
    /// Create a new `ValidationEngine` rooted at `root` with the given configuration.
    pub fn new(root: impl Into<PathBuf>, config: ValidatorConfig) -> Self {
        Self {
            config,
            rules: Vec::new(),
            root: root.into(),
        }
    }

    /// Add the built-in asset existence rule.
    pub fn add_asset_rule(&mut self, asset_root: impl Into<PathBuf>) {
        self.rules.push(Arc::new(AssetExistenceRule::new(asset_root)));
    }

    /// Add the built-in import resolution rule.
    pub fn add_import_rule(&mut self, lua_paths: Vec<PathBuf>) {
        self.rules.push(Arc::new(ImportResolutionRule::new(lua_paths)));
    }

    /// Add the built-in API compliance rule.
    pub fn add_api_rule(&mut self) {
        self.rules.push(Arc::new(ApiComplianceRule::with_defaults()));
    }

    /// Add a custom Lua pattern validation rule.
    pub fn add_pattern_rule(&mut self, rule: LuaPatternRule) {
        self.rules.push(Arc::new(rule));
    }

    /// Load validation rules from a TOML file.
    pub fn load_toml_rules(&mut self, path: &Path) {
        let loaded = rules_toml::load_rules_from_file(path);
        for rule in loaded {
            self.rules.push(Arc::new(rule));
        }
    }

    /// Run all rules against Lua files under the root.
    pub fn run(&self) -> ValidationReport {
        let files = collect_lua_files(&self.root);
        validate_parallel(&files, &self.rules, self.config.thread_count)
    }

    /// Run against a specific set of files.
    pub fn run_files(&self, files: &[PathBuf]) -> ValidationReport {
        validate_parallel(files, &self.rules, self.config.thread_count)
    }

    /// Run all rules against a single file.
    pub fn run_single(&self, path: &Path) -> ValidationReport {
        let content = match std::fs::read_to_string(path) {
            Ok(c) => c,
            Err(_) => return ValidationReport::empty(),
        };
        let mut violations = Vec::new();
        for rule in &self.rules {
            violations.extend(rule.validate(path, &content));
        }
        ValidationReport {
            violations,
            files_checked: 1,
            duration_ms: 0,
        }
    }

    /// Return the total number of rules registered in this engine.
    pub fn rule_count(&self) -> usize {
        self.rules.len()
    }

    /// Return the root directory this engine validates files under.
    pub fn root(&self) -> &Path {
        &self.root
    }
}
