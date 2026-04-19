//! Validation and quality reports for doc entries.

use std::collections::HashMap;

use crate::docs::catalog::Catalog;
use crate::docs::entry::DocEntry;

/// Computes a quality score in `[0.0, 1.0]` for a single doc entry.
///
/// # Parameters
/// - `entry` — `&DocEntry`.
///
/// # Returns
/// `f64`.
///
/// Scores one point each for: non-empty description, non-empty qualified_name,
/// at least one parameter or return (for non-value kinds), an example, and a
/// since field.  The final score is the fraction of applicable checks that pass.
pub fn quality_score(entry: &DocEntry) -> f64 {
    let mut total = 0u32;
    let mut passed = 0u32;

    // description
    total += 1;
    if !entry.description.is_empty() { passed += 1; }

    // qualified_name populated
    total += 1;
    if !entry.qualified_name.is_empty() { passed += 1; }

    // parameters or returns (only for non-value kinds)
    if entry.kind != "value" {
        total += 1;
        if !entry.parameters.is_empty() || !entry.returns.is_empty() { passed += 1; }
    }

    // example present
    total += 1;
    if entry.example.is_some() { passed += 1; }

    // since field present
    total += 1;
    if entry.since.is_some() { passed += 1; }

    if total == 0 { return 0.0; }
    passed as f64 / total as f64
}

/// Converts a quality score into a letter grade.
///
/// # Parameters
/// - `score` — `f64`.
///
/// # Returns
/// `&'static str`.
///
/// A ≥ 0.9, B ≥ 0.7, C ≥ 0.5, D ≥ 0.3, F < 0.3.
pub fn quality_grade(score: f64) -> &'static str {
    if score >= 0.9 { "A" }
    else if score >= 0.7 { "B" }
    else if score >= 0.5 { "C" }
    else if score >= 0.3 { "D" }
    else { "F" }
}

/// A report comparing a known API surface against catalog coverage.
/// # Fields
/// - `missing` — `Vec<String>`. API items not found in catalog.
/// - `phantom` — `Vec<String>`. Catalog items not in the known API.
/// - `incomplete` — `Vec<String>`. Entries with incomplete documentation.
/// - `score` — `f64`. Completeness score 0.0–1.0.
#[derive(Debug, Default)]
pub struct ValidationReport {
    /// Qualified names that should have a doc entry but do not.
    pub missing: Vec<String>,
    /// Qualified names with a doc entry that are not present in the live API.
    pub phantom: Vec<String>,
    /// Qualified names whose doc entry is incomplete.
    pub incomplete: Vec<String>,
}

impl ValidationReport {
    /// Creates an empty validation report.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self::default()
    }

    /// Returns `true` when the report has no issues.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_clean(&self) -> bool {
        self.missing.is_empty() && self.phantom.is_empty() && self.incomplete.is_empty()
    }

    /// Returns the total count of issues across all categories.
    ///
    /// # Returns
    /// `usize`.
    pub fn total_issues(&self) -> usize {
        self.missing.len() + self.phantom.len() + self.incomplete.len()
    }
}

/// A quality report computed from all entries in a catalog.
/// # Fields
/// - `missing` — `Vec<String>`. API items not in catalog.
/// - `phantom` — `Vec<String>`. Catalog entries absent from API spec.
/// - `incomplete` — `Vec<String>`. Entries with incomplete docs.
pub struct QualityReport {
    /// Snapshot of all entries that were scored.
    pub entries: Vec<DocEntry>,
    /// Average quality score per module name.
    pub module_scores: HashMap<String, f64>,
    /// Weighted average quality score across all entries.
    pub overall_score: f64,
}

impl QualityReport {
    /// Computes quality scores for every entry in `catalog`.
    ///
    /// # Parameters
    /// - `catalog` — `&Catalog`.
    ///
    /// # Returns
    /// `Self`.
    pub fn compute(catalog: &Catalog) -> Self {
        let entries: Vec<DocEntry> = catalog.all_entries().to_vec();

        let mut module_totals: HashMap<String, (f64, usize)> = HashMap::new();
        for entry in &entries {
            let score = quality_score(entry);
            let slot = module_totals.entry(entry.module.clone()).or_insert((0.0, 0));
            slot.0 += score;
            slot.1 += 1;
        }

        let module_scores: HashMap<String, f64> = module_totals
            .iter()
            .map(|(m, (sum, count))| (m.clone(), if *count > 0 { sum / *count as f64 } else { 0.0 }))
            .collect();

        let overall_score = if entries.is_empty() {
            0.0
        } else {
            entries.iter().map(quality_score).sum::<f64>() / entries.len() as f64
        };

        Self { entries, module_scores, overall_score }
    }

    /// Returns the letter grade for the given module.
    ///
    /// # Parameters
    /// - `module` — `&str`.
    ///
    /// # Returns
    /// `&'static str`.
    pub fn module_grade(&self, module: &str) -> &'static str {
        quality_grade(self.module_scores.get(module).copied().unwrap_or(0.0))
    }

    /// Convenience constructor: builds a temporary [`Catalog`] from `entries` then calls [`Self::compute`].
    ///
    /// # Parameters
    /// - `entries` — `&[DocEntry]`.
    ///
    /// # Returns
    /// `QualityReport`.
    pub fn from_entries(entries: &[DocEntry]) -> Self {
        let catalog = Catalog::from_entries(entries);
        Self::compute(&catalog)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::docs::entry::{DocEntry, ParamInfo};

    fn full_entry() -> DocEntry {
        let mut e = DocEntry::new("play", "audio", "function");
        e.description = "Plays a sound".into();
        e.example = Some("lurek.audio.play('boom')".into());
        e.since = Some("0.1.0".into());
        e.parameters.push(ParamInfo {
            name: "path".into(),
            type_name: "string".into(),
            description: "file".into(),
            optional: false,
            default: None,
        });
        e
    }

    #[test]
    fn quality_score_full_entry() {
        let score = quality_score(&full_entry());
        assert!((score - 1.0).abs() < 1e-9);
    }

    #[test]
    fn quality_score_empty_entry() {
        let e = DocEntry::new("x", "m", "function");
        let score = quality_score(&e);
        assert!(score < 0.5);
    }

    #[test]
    fn quality_grade_mapping() {
        assert_eq!(quality_grade(1.0), "A");
        assert_eq!(quality_grade(0.8), "B");
        assert_eq!(quality_grade(0.6), "C");
        assert_eq!(quality_grade(0.4), "D");
        assert_eq!(quality_grade(0.1), "F");
    }

    #[test]
    fn validation_report_clean() {
        let r = ValidationReport::new();
        assert!(r.is_clean());
        assert_eq!(r.total_issues(), 0);
    }

    #[test]
    fn validation_report_with_issues() {
        let mut r = ValidationReport::new();
        r.missing.push("lurek.audio.play".into());
        r.incomplete.push("lurek.audio.stop".into());
        assert!(!r.is_clean());
        assert_eq!(r.total_issues(), 2);
    }

    #[test]
    fn quality_report_from_entries() {
        let entries = vec![full_entry()];
        let report = QualityReport::from_entries(&entries);
        assert!((report.overall_score - 1.0).abs() < 1e-9);
        assert_eq!(report.module_grade("audio"), "A");
    }
}
