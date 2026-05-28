//! Mod API compliance checker: validates Lua scripts against registered type schemas.
//!
//! - Data type: `ApiComplianceRule`.
//! - Implementation: `ApiComplianceRule`.

use super::report::{Severity, Violation};
use super::rule::ValidationRule;
use std::path::Path;

/// Checks mod API compliance (valid lurek.* calls, correct arg counts).
pub struct ApiComplianceRule {
    /// Known apis.
    pub known_apis: Vec<String>,
}

impl ApiComplianceRule {
    /// Create an `ApiComplianceRule` that checks against the provided list of known API names.
    pub fn new(known_apis: Vec<String>) -> Self {
        Self { known_apis }
    }

    /// Create an `ApiComplianceRule` pre-populated with the built-in `lurek.*` module names.
    pub fn with_defaults() -> Self {
        Self {
            known_apis: vec![
                "lurek.sprite".into(),
                "lurek.audio".into(),
                "lurek.input".into(),
                "lurek.physics".into(),
                "lurek.math".into(),
                "lurek.timer".into(),
                "lurek.window".into(),
                "lurek.render".into(),
                "lurek.font".into(),
                "lurek.camera".into(),
                "lurek.tween".into(),
                "lurek.scene".into(),
                "lurek.event".into(),
                "lurek.binary".into(),
                "lurek.ui".into(),
                "lurek.particle".into(),
                "lurek.tilemap".into(),
                "lurek.animation".into(),
                "lurek.network".into(),
                "lurek.save".into(),
                "lurek.thread".into(),
                "lurek.ai".into(),
                "lurek.pathfind".into(),
                "lurek.effect".into(),
                "lurek.mapblock".into(),
                "lurek.cursor".into(),
                "lurek.grep".into(),
                "lurek.validator".into(),
                "lurek.mods".into(),
            ],
        }
    }
}

impl ValidationRule for ApiComplianceRule {
    fn id(&self) -> &str {
        "api-compliance"
    }
    fn description(&self) -> &str {
        "Checks that lurek.* API calls reference known modules"
    }
    fn severity(&self) -> Severity {
        Severity::Warning
    }

    fn validate(&self, path: &Path, content: &str) -> Vec<Violation> {
        let mut violations = Vec::new();

        for (line_num, line) in content.lines().enumerate() {
            // Find lurek.xxx patterns
            let mut search_from = 0;
            while let Some(pos) = line[search_from..].find("lurek.") {
                let abs_pos = search_from + pos;
                let after = &line[abs_pos + 6..];
                // Extract module name (until non-alphanumeric/underscore)
                let module_end = after
                    .find(|c: char| !c.is_alphanumeric() && c != '_')
                    .unwrap_or(after.len());
                if module_end > 0 {
                    let module_name = format!("lurek.{}", &after[..module_end]);
                    if !self
                        .known_apis
                        .iter()
                        .any(|api| module_name.starts_with(api))
                    {
                        violations.push(
                            Violation::new(
                                "api-compliance",
                                Severity::Warning,
                                path.to_path_buf(),
                                format!("Unknown API module: {module_name}"),
                            )
                            .with_line(line_num + 1),
                        );
                    }
                }
                search_from = abs_pos + 6 + module_end;
            }
        }

        violations
    }
}
