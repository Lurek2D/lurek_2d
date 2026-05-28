//! Asset existence checker: validates that image, sound, and font paths in scripts exist.
//!
//! - Data type: `AssetExistenceRule`.

use super::report::{Severity, Violation};
use super::rule::ValidationRule;
use std::path::{Path, PathBuf};

/// Checks that referenced assets (images, sounds, fonts) exist on disk.
pub struct AssetExistenceRule {
    /// Asset root.
    pub asset_root: PathBuf,
}

impl AssetExistenceRule {
    /// Create an asset existence rule rooted at the given assets directory.
    pub fn new(asset_root: impl Into<PathBuf>) -> Self {
        Self { asset_root: asset_root.into() }
    }

    fn extract_asset_refs(&self, content: &str) -> Vec<(usize, String)> {
        let mut refs = Vec::new();
        let patterns = [
            "lurek.sprite.load(",
            "lurek.audio.load(",
            "lurek.font.load(",
            "lurek.image.load(",
        ];

        for (line_num, line) in content.lines().enumerate() {
            for pat in &patterns {
                if let Some(pos) = line.find(pat) {
                    let after = &line[pos + pat.len()..];
                    if let Some(ref_path) = extract_string_arg(after) {
                        refs.push((line_num + 1, ref_path));
                    }
                }
            }
        }
        refs
    }
}

impl ValidationRule for AssetExistenceRule {
    fn id(&self) -> &str { "asset-exists" }
    fn description(&self) -> &str { "Checks that referenced asset files exist" }
    fn severity(&self) -> Severity { Severity::Error }

    fn validate(&self, path: &Path, content: &str) -> Vec<Violation> {
        let mut violations = Vec::new();
        let refs = self.extract_asset_refs(content);

        for (line, asset_path) in refs {
            let full_path = self.asset_root.join(&asset_path);
            if !full_path.exists() {
                violations.push(
                    Violation::new("asset-exists", Severity::Error, path.to_path_buf(),
                        format!("Asset not found: {asset_path}"))
                        .with_line(line)
                        .with_suggestion(format!("Create or fix path: {}", full_path.display()))
                );
            }
        }

        violations
    }
}

fn extract_string_arg(s: &str) -> Option<String> {
    let s = s.trim();
    let quote = if s.starts_with('"') { '"' } else if s.starts_with('\'') { '\'' } else { return None };
    let rest = &s[1..];
    rest.find(quote).map(|end| rest[..end].to_string())
}
