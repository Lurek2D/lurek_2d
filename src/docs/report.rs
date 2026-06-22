//! Owns the report owner for the docs subsystem and keeps its rules local to this file while keeping call sites explicit.
//! Centers the implementation around IssueSeverity, as_str, DocsIssueKind, with helpers kept close to their invariants.
//! Defines how report data is validated, transformed, or stored before neighboring systems use it.
//! Owns docs behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on report behavior while Lua registration stays elsewhere.
//! Documents where docs callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing report defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the docs state that can explain them while keeping call sites explicit.

use crate::docs::catalog::Catalog;
use crate::docs::entry::DocEntry;
use serde::Serialize;
use std::collections::{HashMap, HashSet};

/// Severity level attached to one documentation issue.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum IssueSeverity {
    /// Informational problem that is useful for tooling but not usually a release blocker.
    Hint,
    /// Quality or compatibility problem that should be fixed soon.
    Warning,
    /// Contract problem that should fail strict validation or CI.
    Error,
}

impl IssueSeverity {
    /// Return the lowercase canonical string for this severity.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Hint => "hint",
            Self::Warning => "warning",
            Self::Error => "error",
        }
    }
}

/// Broad category attached to one documentation issue for filtering and reporting.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum DocsIssueKind {
    /// Validation issue discovered when comparing docs against a live catalog.
    Validation,
    /// Quality rule issue discovered while scoring entry completeness.
    Quality,
    /// Export issue discovered while trimming or writing payloads.
    Export,
    /// Catalog issue discovered while mutating or deduplicating entries.
    Catalog,
}

/// Actionable issue emitted by validation, quality, export, or catalog workflows.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct DocsIssue {
    /// Stable rule identifier suitable for CI gating or filtering.
    pub rule_id: String,
    /// Broad issue category for tooling views.
    pub kind: DocsIssueKind,
    /// Severity assigned by the producing workflow.
    pub severity: IssueSeverity,
    /// Qualified symbol name involved in the issue when one exists.
    pub qualified_name: Option<String>,
    /// Top-level module involved in the issue when one exists.
    pub module: Option<String>,
    /// Human-readable source context such as `catalog`, `validation`, or `export`.
    pub source: Option<String>,
    /// Primary user-facing message.
    pub message: String,
    /// Optional fix hint for the caller or maintainer.
    pub hint: Option<String>,
}

impl DocsIssue {
    /// Build a new docs issue with stable category, severity, and rule metadata.
    pub fn new(
        rule_id: impl Into<String>,
        kind: DocsIssueKind,
        severity: IssueSeverity,
        message: impl Into<String>,
    ) -> Self {
        Self {
            rule_id: rule_id.into(),
            kind,
            severity,
            qualified_name: None,
            module: None,
            source: None,
            message: message.into(),
            hint: None,
        }
    }

    /// Attach a qualified symbol name and derive the module name when possible.
    pub fn with_qualified_name(mut self, qualified_name: impl Into<String>) -> Self {
        let qualified_name = qualified_name.into();
        if self.module.is_none() {
            self.module = module_from_qualified_name(&qualified_name);
        }
        self.qualified_name = Some(qualified_name);
        self
    }

    /// Attach a module name.
    pub fn with_module(mut self, module: impl Into<String>) -> Self {
        self.module = Some(module.into());
        self
    }

    /// Attach a source label.
    pub fn with_source(mut self, source: impl Into<String>) -> Self {
        self.source = Some(source.into());
        self
    }

    /// Attach an actionable fix hint.
    pub fn with_hint(mut self, hint: impl Into<String>) -> Self {
        self.hint = Some(hint.into());
        self
    }
}

/// Weighted scoring policy used by docs quality reports.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct QualityPolicy {
    /// Weight for a primary description.
    pub description_weight: u32,
    /// Weight for a non-empty qualified name.
    pub qualified_name_weight: u32,
    /// Weight for callable signature coverage.
    pub signature_weight: u32,
    /// Weight for parameter description coverage.
    pub parameter_description_weight: u32,
    /// Weight for parameter type coverage.
    pub parameter_type_weight: u32,
    /// Weight for return description coverage.
    pub return_description_weight: u32,
    /// Weight for return type coverage.
    pub return_type_weight: u32,
    /// Weight for an example snippet.
    pub example_weight: u32,
    /// Weight for a since tag.
    pub since_weight: u32,
}

impl Default for QualityPolicy {
    fn default() -> Self {
        Self {
            description_weight: 4,
            qualified_name_weight: 2,
            signature_weight: 3,
            parameter_description_weight: 2,
            parameter_type_weight: 1,
            return_description_weight: 2,
            return_type_weight: 1,
            example_weight: 1,
            since_weight: 1,
        }
    }
}

/// Collect missing, phantom, and incomplete documentation issue identifiers plus structured issue metadata.
#[derive(Debug, Default, Clone)]
pub struct ValidationReport {
    /// Store qualified names that are expected but missing in generated docs.
    pub missing: Vec<String>,
    /// Store generated names that do not map to known API items.
    pub phantom: Vec<String>,
    /// Store entries that exist but fail required completeness checks.
    pub incomplete: Vec<String>,
    /// Store structured issues with severity, rule ids, and hints for each validation finding.
    pub issues: Vec<DocsIssue>,
}

impl ValidationReport {
    /// Create an empty validation report and return it.
    pub fn new() -> Self {
        Self::default()
    }

    /// Compare docs entries against live entries and return a structured validation report.
    pub fn compare(doc_entries: &[DocEntry], live_entries: &[DocEntry]) -> Self {
        let live_names: HashSet<&str> = live_entries
            .iter()
            .map(|entry| entry.qualified_name.as_str())
            .collect();
        let doc_names: HashSet<&str> = doc_entries
            .iter()
            .map(|entry| entry.qualified_name.as_str())
            .collect();
        let mut missing: Vec<String> = live_names
            .difference(&doc_names)
            .map(|name| (*name).to_string())
            .collect();
        missing.sort();
        let mut phantom: Vec<String> = doc_names
            .difference(&live_names)
            .map(|name| (*name).to_string())
            .collect();
        phantom.sort();
        let mut incomplete: Vec<String> = doc_entries
            .iter()
            .filter(|entry| !entry.is_complete())
            .map(|entry| entry.qualified_name.clone())
            .collect();
        incomplete.sort();

        let mut issues = Vec::new();
        for qualified_name in &missing {
            issues.push(
                DocsIssue::new(
                    "docs.validation.missing_symbol",
                    DocsIssueKind::Validation,
                    IssueSeverity::Error,
                    "Live API symbol is missing from the documentation catalog.",
                )
                .with_qualified_name(qualified_name.clone())
                .with_source("validation")
                .with_hint("Add a docs entry for this symbol before publishing generated docs."),
            );
        }
        for qualified_name in &phantom {
            issues.push(
                DocsIssue::new(
                    "docs.validation.phantom_symbol",
                    DocsIssueKind::Validation,
                    IssueSeverity::Warning,
                    "Documentation catalog entry does not exist in the live API surface.",
                )
                .with_qualified_name(qualified_name.clone())
                .with_source("validation")
                .with_hint("Remove the stale entry or restore the missing API symbol."),
            );
        }
        for entry in doc_entries.iter().filter(|entry| !entry.is_complete()) {
            let missing_fields = entry.missing_fields().join(", ");
            issues.push(
                DocsIssue::new(
                    "docs.validation.incomplete_entry",
                    DocsIssueKind::Validation,
                    IssueSeverity::Warning,
                    format!(
                        "Documentation entry is incomplete and is missing required fields: {missing_fields}."
                    ),
                )
                .with_qualified_name(entry.qualified_name.clone())
                .with_module(entry.module.clone())
                .with_source("validation")
                .with_hint("Fill the missing fields before using the entry in quality or export tooling."),
            );
        }

        Self {
            missing,
            phantom,
            incomplete,
            issues,
        }
    }

    /// Return true when no issue buckets contain any item.
    pub fn is_clean(&self) -> bool {
        self.missing.is_empty() && self.phantom.is_empty() && self.incomplete.is_empty()
    }

    /// Return the total number of aggregated issues across all buckets.
    pub fn total_issues(&self) -> usize {
        self.issues.len()
    }
}

/// Store per-entry and per-module quality metrics for one catalog snapshot.
#[derive(Debug, Clone)]
pub struct QualityReport {
    /// Store the full set of entries used for score computation.
    pub entries: Vec<DocEntry>,
    /// Store average quality score keyed by module name.
    pub module_scores: HashMap<String, f64>,
    /// Store average quality score across all entries.
    pub overall_score: f64,
    /// Store rule-level quality issues keyed to one entry.
    pub issues: Vec<DocsIssue>,
    /// Store the weighting policy used to compute the score.
    pub policy: QualityPolicy,
}

impl QualityReport {
    /// Compute report metrics from a catalog using the default policy and return the report.
    pub fn compute(catalog: &Catalog) -> Self {
        Self::compute_with_policy(catalog, QualityPolicy::default())
    }

    /// Compute report metrics from a catalog using an explicit policy and return the report.
    pub fn compute_with_policy(catalog: &Catalog, policy: QualityPolicy) -> Self {
        let entries: Vec<DocEntry> = catalog.all_entries().to_vec();
        let mut module_totals: HashMap<String, (f64, usize)> = HashMap::new();
        let mut issues = Vec::new();

        for entry in &entries {
            let score = quality_score_with_policy(entry, &policy);
            let slot = module_totals
                .entry(entry.module.clone())
                .or_insert((0.0, 0));
            slot.0 += score;
            slot.1 += 1;
            issues.extend(entry_quality_issues(entry));
        }

        let module_scores: HashMap<String, f64> = module_totals
            .into_iter()
            .map(|(module, (sum, count))| {
                (module, if count > 0 { sum / count as f64 } else { 0.0 })
            })
            .collect();
        let overall_score = if entries.is_empty() {
            0.0
        } else {
            entries
                .iter()
                .map(|entry| quality_score_with_policy(entry, &policy))
                .sum::<f64>()
                / entries.len() as f64
        };

        Self {
            entries,
            module_scores,
            overall_score,
            issues,
            policy,
        }
    }

    /// Return the letter grade for one module score or F when missing.
    pub fn module_grade(&self, module: &str) -> &'static str {
        quality_grade(self.module_scores.get(module).copied().unwrap_or(0.0))
    }

    /// Build a temporary catalog from entries and return a computed report.
    pub fn from_entries(entries: &[DocEntry]) -> Self {
        Self::from_entries_with_policy(entries, QualityPolicy::default())
    }

    /// Build a temporary catalog from entries using an explicit policy and return a computed report.
    pub fn from_entries_with_policy(entries: &[DocEntry], policy: QualityPolicy) -> Self {
        let catalog = Catalog::from_entries(entries);
        Self::compute_with_policy(&catalog, policy)
    }
}

/// Compute one entry quality ratio using the default policy and return a score in the 0.0..=1.0 range.
pub fn quality_score(entry: &DocEntry) -> f64 {
    quality_score_with_policy(entry, &QualityPolicy::default())
}

/// Compute one entry quality ratio using the supplied policy and return a score in the 0.0..=1.0 range.
pub fn quality_score_with_policy(entry: &DocEntry, policy: &QualityPolicy) -> f64 {
    let mut total = 0u32;
    let mut passed = 0u32;

    total += policy.description_weight;
    if !entry.description.is_empty() {
        passed += policy.description_weight;
    }

    total += policy.qualified_name_weight;
    if !entry.qualified_name.is_empty() {
        passed += policy.qualified_name_weight;
    }

    if entry.kind != "value" {
        total += policy.signature_weight;
        if !entry.parameters.is_empty() || !entry.returns.is_empty() {
            passed += policy.signature_weight;
        }
    }

    if !entry.parameters.is_empty() {
        total += policy.parameter_description_weight;
        if entry
            .parameters
            .iter()
            .all(|param| !param.description.is_empty())
        {
            passed += policy.parameter_description_weight;
        }
        total += policy.parameter_type_weight;
        if entry
            .parameters
            .iter()
            .all(|param| !param.type_name.is_empty())
        {
            passed += policy.parameter_type_weight;
        }
    }

    if !entry.returns.is_empty() {
        total += policy.return_description_weight;
        if entry.returns.iter().all(|ret| !ret.description.is_empty()) {
            passed += policy.return_description_weight;
        }
        total += policy.return_type_weight;
        if entry.returns.iter().all(|ret| !ret.type_name.is_empty()) {
            passed += policy.return_type_weight;
        }
    }

    total += policy.example_weight;
    if entry.has_example() {
        passed += policy.example_weight;
    }

    total += policy.since_weight;
    if entry.has_since() {
        passed += policy.since_weight;
    }

    if total == 0 {
        return 0.0;
    }
    passed as f64 / total as f64
}

/// Convert a quality score to a letter grade and return the grade label.
pub fn quality_grade(score: f64) -> &'static str {
    if score >= 0.9 {
        "A"
    } else if score >= 0.7 {
        "B"
    } else if score >= 0.5 {
        "C"
    } else if score >= 0.3 {
        "D"
    } else {
        "F"
    }
}

/// Build per-entry quality issues and return them as actionable rule rows.
fn entry_quality_issues(entry: &DocEntry) -> Vec<DocsIssue> {
    let mut issues = Vec::new();
    let qualified_name = entry.qualified_name.clone();
    let module = entry.module.clone();
    let with_context = |issue: DocsIssue| {
        issue
            .with_qualified_name(qualified_name.clone())
            .with_module(module.clone())
            .with_source("quality")
    };

    if entry.description.is_empty() {
        issues.push(with_context(
            DocsIssue::new(
                "docs.quality.description_missing",
                DocsIssueKind::Quality,
                IssueSeverity::Error,
                "Entry is missing a primary description.",
            )
            .with_hint("Add a user-facing description that explains what the API symbol does."),
        ));
    }
    if entry.qualified_name.is_empty() {
        issues.push(with_context(
            DocsIssue::new(
                "docs.quality.qualified_name_missing",
                DocsIssueKind::Quality,
                IssueSeverity::Error,
                "Entry is missing a qualified API name.",
            )
            .with_hint("Populate `qualified_name` so lookups, exports, and validation can identify the symbol."),
        ));
    }
    if entry.kind != "value" && entry.parameters.is_empty() && entry.returns.is_empty() {
        issues.push(with_context(
            DocsIssue::new(
                "docs.quality.signature_missing",
                DocsIssueKind::Quality,
                IssueSeverity::Error,
                "Callable entry is missing parameter and return metadata.",
            )
            .with_hint(
                "Document parameters or return values so callable tooling can build signatures.",
            ),
        ));
    }
    for param in &entry.parameters {
        if param.description.is_empty() {
            issues.push(with_context(
                DocsIssue::new(
                    "docs.quality.param_description_missing",
                    DocsIssueKind::Quality,
                    IssueSeverity::Warning,
                    format!("Parameter `{}` is missing a description.", param.name),
                )
                .with_hint("Add a concise explanation for the parameter purpose and usage."),
            ));
        }
        if param.type_name.is_empty() {
            issues.push(with_context(
                DocsIssue::new(
                    "docs.quality.param_type_missing",
                    DocsIssueKind::Quality,
                    IssueSeverity::Warning,
                    format!("Parameter `{}` is missing a type name.", param.name),
                )
                .with_hint("Record the public type name so schema checks and signature export stay complete."),
            ));
        }
    }
    for ret in &entry.returns {
        if ret.description.is_empty() {
            issues.push(with_context(
                DocsIssue::new(
                    "docs.quality.return_description_missing",
                    DocsIssueKind::Quality,
                    IssueSeverity::Warning,
                    "Return metadata is missing a description.".to_string(),
                )
                .with_hint("Describe what the return value means to the caller."),
            ));
        }
        if ret.type_name.is_empty() {
            issues.push(with_context(
                DocsIssue::new(
                    "docs.quality.return_type_missing",
                    DocsIssueKind::Quality,
                    IssueSeverity::Warning,
                    "Return metadata is missing a type name.".to_string(),
                )
                .with_hint("Record the public return type so generated signatures stay stable."),
            ));
        }
    }
    if !entry.has_example() {
        issues.push(with_context(
            DocsIssue::new(
                "docs.quality.example_missing",
                DocsIssueKind::Quality,
                IssueSeverity::Hint,
                "Entry is missing an example snippet.",
            )
            .with_hint("Add a short example that demonstrates the normal call pattern."),
        ));
    }
    if !entry.has_since() {
        issues.push(with_context(
            DocsIssue::new(
                "docs.quality.since_missing",
                DocsIssueKind::Quality,
                IssueSeverity::Hint,
                "Entry is missing a since-version marker.",
            )
            .with_hint("Record the version where this API symbol became available."),
        ));
    }

    issues
}

/// Extract the module segment from a qualified name when it follows the `lurek.<module>...` convention.
fn module_from_qualified_name(qualified_name: &str) -> Option<String> {
    let mut parts = qualified_name.split('.');
    let root = parts.next()?;
    if root != "lurek" {
        return None;
    }
    parts.next().map(str::to_string)
}
