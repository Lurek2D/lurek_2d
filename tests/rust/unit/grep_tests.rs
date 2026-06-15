//! File: tests/rust/unit/grep_tests.rs

use lurek2d::grep::{FileFilter, GrepConfig, GrepEngine};
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

mod grep_engine_tests {
    use super::*;

    fn make_temp_dir(name: &str) -> PathBuf {
        let unique = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        let dir = std::env::temp_dir().join(format!("lurek_grep_{name}_{unique}"));
        let _ = std::fs::remove_dir_all(&dir);
        std::fs::create_dir_all(&dir).unwrap();
        dir
    }

    fn write_file(root: &Path, relative: &str, content: &str) {
        let path = root.join(relative);
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent).unwrap();
        }
        std::fs::write(path, content).unwrap();
    }

    #[test]
    fn search_skips_hidden_files_by_default() {
        let dir = make_temp_dir("hidden");
        write_file(&dir, "visible.lua", "needle");
        write_file(&dir, ".hidden.lua", "needle");

        let engine = GrepEngine::default();
        let result = engine.search_literal(&dir, "needle", &FileFilter::game_content());

        assert_eq!(result.files_searched, 1);
        assert_eq!(result.files_matched, 1);
        assert_eq!(result.total_matches, 1);
        assert_eq!(result.matches[0].path.file_name().unwrap(), "visible.lua");

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn extension_filter_limits_scanned_files() {
        let dir = make_temp_dir("extensions");
        write_file(&dir, "script.lua", "needle");
        write_file(&dir, "notes.txt", "needle");

        let mut filter = FileFilter::new();
        filter.extensions.push("lua".to_string());

        let engine = GrepEngine::default();
        let result = engine.search_literal(&dir, "needle", &filter);

        assert_eq!(result.files_searched, 1);
        assert_eq!(result.files_matched, 1);
        assert_eq!(result.total_matches, 1);
        assert_eq!(result.matches[0].path.file_name().unwrap(), "script.lua");

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn multi_search_counts_all_literal_patterns() {
        let dir = make_temp_dir("multi");
        write_file(&dir, "alpha.lua", "alpha beta\nbeta");
        write_file(&dir, "beta.lua", "alpha");

        let engine = GrepEngine::default();
        let result = engine.search_multi(
            &dir,
            vec!["alpha".to_string(), "beta".to_string()],
            &FileFilter::game_content(),
        );

        assert_eq!(result.files_searched, 2);
        assert_eq!(result.files_matched, 2);
        assert_eq!(result.total_matches, 4);

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn parallel_search_results_are_sorted_deterministically() {
        let dir = make_temp_dir("ordering");
        write_file(&dir, "b.lua", "needle\nignored\nneedle");
        write_file(&dir, "a.lua", "ignored\nneedle");

        let engine = GrepEngine::new(GrepConfig {
            thread_count: 2,
            ..Default::default()
        });
        let result = engine.search_literal(&dir, "needle", &FileFilter::game_content());

        assert_eq!(result.matches.len(), 2);
        assert_eq!(result.matches[0].path.file_name().unwrap(), "a.lua");
        assert_eq!(result.matches[1].path.file_name().unwrap(), "b.lua");
        assert_eq!(
            result.matches[0]
                .lines
                .iter()
                .map(|line| line.line_number)
                .collect::<Vec<_>>(),
            vec![2]
        );
        assert_eq!(
            result.matches[1]
                .lines
                .iter()
                .map(|line| line.line_number)
                .collect::<Vec<_>>(),
            vec![1, 3]
        );

        let _ = std::fs::remove_dir_all(&dir);
    }

    #[test]
    fn max_results_cap_truncates_large_match_sets() {
        let dir = make_temp_dir("cap");
        write_file(&dir, "a.lua", "needle needle needle needle");
        write_file(&dir, "b.lua", "needle");

        let engine = GrepEngine::new(GrepConfig {
            max_results: 3,
            ..Default::default()
        });
        let result = engine.search_literal(&dir, "needle", &FileFilter::game_content());

        assert_eq!(result.total_matches, 3);
        assert_eq!(result.files_matched, 1);
        assert_eq!(result.matches[0].path.file_name().unwrap(), "a.lua");
        assert_eq!(result.matches[0].lines.len(), 1);
        assert_eq!(result.matches[0].lines[0].positions.len(), 3);

        let _ = std::fs::remove_dir_all(&dir);
    }
}
