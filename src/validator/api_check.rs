//! This file owns `ApiComplianceRule`, the validator check that scans Lua content for known dotted API prefixes.
//! It stores the allowlist of supported API prefixes and uses it to flag unknown namespaces at source lines.
//! Default construction seeds built-in engine module names so projects get Lurek API drift detection without setup.
//! The validate path searches textual call sites, extracts module segments, and emits structured warnings.
//! Open this file when accepted public API names change; asset, import, and custom rule logic live in siblings.

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

    /// Return the built-in `lurek.*` API prefixes used by default validation helpers.
    pub fn default_known_apis() -> Vec<String> {
        vec![
            "lurek.agent".into(),
            "lurek.ai".into(),
            "lurek.animation".into(),
            "lurek.asset".into(),
            "lurek.audio".into(),
            "lurek.awareness".into(),
            "lurek.binary".into(),
            "lurek.camera".into(),
            "lurek.cinematic".into(),
            "lurek.color".into(),
            "lurek.compute".into(),
            "lurek.cursor".into(),
            "lurek.dataframe".into(),
            "lurek.debugbridge".into(),
            "lurek.devtools".into(),
            "lurek.dialog".into(),
            "lurek.docs".into(),
            "lurek.dsp".into(),
            "lurek.ecs".into(),
            "lurek.effect".into(),
            "lurek.engine".into(),
            "lurek.event".into(),
            "lurek.filesystem".into(),
            "lurek.font".into(),
            "lurek.globe".into(),
            "lurek.grep".into(),
            "lurek.i18n".into(),
            "lurek.image".into(),
            "lurek.input".into(),
            "lurek.layout".into(),
            "lurek.learning".into(),
            "lurek.light".into(),
            "lurek.log".into(),
            "lurek.mapblock".into(),
            "lurek.math".into(),
            "lurek.minimap".into(),
            "lurek.mods".into(),
            "lurek.network".into(),
            "lurek.overlay".into(),
            "lurek.parallax".into(),
            "lurek.particle".into(),
            "lurek.patterns".into(),
            "lurek.pathfind".into(),
            "lurek.physics".into(),
            "lurek.procgen".into(),
            "lurek.province".into(),
            "lurek.raycaster".into(),
            "lurek.render".into(),
            "lurek.repl".into(),
            "lurek.save".into(),
            "lurek.scene".into(),
            "lurek.serialize".into(),
            "lurek.sprite".into(),
            "lurek.svg".into(),
            "lurek.system".into(),
            "lurek.terminal".into(),
            "lurek.thread".into(),
            "lurek.tilefield".into(),
            "lurek.tilelight".into(),
            "lurek.tilemap".into(),
            "lurek.tileset".into(),
            "lurek.timer".into(),
            "lurek.tween".into(),
            "lurek.ui".into(),
            "lurek.validator".into(),
            "lurek.window".into(),
        ]
    }

    /// Create an `ApiComplianceRule` pre-populated with the built-in `lurek.*` module names.
    pub fn with_defaults() -> Self {
        Self::new(Self::default_known_apis())
    }

    fn known_roots(&self) -> Vec<&str> {
        let mut roots: Vec<&str> = self
            .known_apis
            .iter()
            .filter_map(|api| api.split('.').next())
            .collect();
        roots.sort_unstable();
        roots.dedup();
        roots
    }

    fn extract_candidate(line: &str, start: usize) -> Option<String> {
        let candidate = line[start..]
            .chars()
            .take_while(|ch| ch.is_alphanumeric() || *ch == '_' || *ch == '.')
            .collect::<String>();
        if candidate.contains('.') {
            Some(candidate)
        } else {
            None
        }
    }

    fn api_prefix(candidate: &str) -> String {
        let mut parts = candidate.split('.');
        match (parts.next(), parts.next()) {
            (Some(first), Some(second)) => format!("{first}.{second}"),
            _ => candidate.to_string(),
        }
    }
}

impl ValidationRule for ApiComplianceRule {
    fn id(&self) -> &str {
        "api-compliance"
    }
    fn description(&self) -> &str {
        "Checks that configured API calls reference known prefixes"
    }
    fn severity(&self) -> Severity {
        Severity::Warning
    }

    fn validate(&self, path: &Path, content: &str) -> Vec<Violation> {
        let mut violations = Vec::new();
        let roots = self.known_roots();

        for (line_num, line) in content.lines().enumerate() {
            for root in &roots {
                let pattern = format!("{root}.");
                let mut search_from = 0;
                while let Some(pos) = line[search_from..].find(&pattern) {
                    let abs_pos = search_from + pos;
                    let Some(candidate) = Self::extract_candidate(line, abs_pos) else {
                        search_from = abs_pos + pattern.len();
                        continue;
                    };
                    let known = self
                        .known_apis
                        .iter()
                        .any(|api| candidate == *api || candidate.starts_with(&format!("{api}.")));
                    if !known {
                        let module_name = Self::api_prefix(&candidate);
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
                    search_from = abs_pos + candidate.len();
                }
            }
        }

        violations
    }
}
