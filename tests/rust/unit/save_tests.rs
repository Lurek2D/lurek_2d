//! File: tests/rust/unit/save_tests.rs
//! Owns Rust-side coverage for save lifecycle policy, slot safety, compression, and format routing.

use lurek2d::save::*;
use lurek2d::serialize::SerialFormat;

mod save_manager_tests {
    use super::*;

    #[test]
    fn migrations() {
        let mut sm = SaveManager::new();
        sm.set_schema_version(5);
        sm.add_migration(1);
        sm.add_migration(3);
        sm.add_migration(7);
        let applicable = sm.applicable_migrations(2);
        assert_eq!(applicable, vec![3]);
    }

    #[test]
    fn format_defaults_to_msgpack_and_can_change() {
        let mut sm = SaveManager::new();
        assert_eq!(sm.format(), SerialFormat::MsgPack);

        sm.set_format(SerialFormat::Json);
        assert_eq!(sm.format(), SerialFormat::Json);

        sm.set_format(SerialFormat::Toml);
        assert_eq!(sm.format(), SerialFormat::Toml);
    }

    #[test]
    fn slot_path_format() {
        assert_eq!(SaveManager::slot_path("quick"), "save/slots/slot_quick.sav");
        assert_eq!(SaveManager::slot_path("1"), "save/slots/slot_1.sav");
    }

    #[test]
    fn parse_save_string_rejects_empty() {
        assert!(SaveManager::parse_save_string("").is_err());
        assert!(SaveManager::parse_save_string("   \n  ").is_err());
    }

    #[test]
    fn parse_save_string_accepts_content() {
        let result = SaveManager::parse_save_string("return { hp = 10 }");
        assert!(result.is_ok());
        assert_eq!(result.expect("content"), "return { hp = 10 }");
    }

    #[test]
    fn add_migration_deduplicates_and_sorts() {
        let mut sm = SaveManager::new();
        sm.set_schema_version(10);
        sm.add_migration(5);
        sm.add_migration(3);
        sm.add_migration(5);
        sm.add_migration(1);
        let migrations = sm.applicable_migrations(0);
        assert_eq!(migrations, vec![1, 3, 5]);
    }

    #[test]
    fn slot_meta_default() {
        let meta = SlotMeta::default();
        assert_eq!(meta.slot, "");
        assert!(meta.timestamp.abs() < f64::EPSILON);
        assert_eq!(meta.version, 0);
        assert_eq!(meta.summary, "");
    }

    #[test]
    fn compressed_save_content_round_trips_plain_payload() {
        let plain =
            "--[[LUREK_SAVE v2 format=json encoding=text compressed=false]]\n{\"name\":\"hero\"}";
        let compressed = compress_save_content(plain).expect("compress");
        let restored = decompress_save_content(&compressed).expect("decompress");
        assert_eq!(restored, plain);
    }

    #[test]
    fn slot_path_rejects_path_traversal_and_invalid_names() {
        let sm = SaveManager::new();
        assert!(sm.slot_path_checked("../evil").is_err());
        assert!(sm.slot_path_checked("/tmp/x").is_err());
        assert!(sm.slot_path_checked("").is_err());
        assert!(sm.slot_path_checked(&"a".repeat(65)).is_err());
        assert_eq!(
            sm.slot_path_checked("valid_slot-1")
                .expect("validated slot"),
            "save/slots/slot_valid_slot-1.sav"
        );
    }

    #[test]
    fn migration_plan_reports_missing_steps() {
        let mut sm = SaveManager::new();
        sm.set_schema_version(4);
        sm.add_migration(1);
        sm.add_migration(3);
        let err = sm.migration_plan(1).expect_err("missing step");
        assert!(err.to_string().contains("2"));
    }

    #[test]
    fn auto_save_rejects_invalid_interval_and_dt() {
        let mut sm = SaveManager::new();
        assert!(sm.enable_auto_save(0.0, "auto").is_err());
        assert!(sm.enable_auto_save(f64::NAN, "auto").is_err());
        assert!(sm.enable_auto_save(-1.0, "auto").is_err());

        sm.enable_auto_save(0.5, "auto").expect("valid autosave");
        sm.mark_dirty();
        assert_eq!(sm.update(f64::NAN), None);
        assert_eq!(sm.update(-0.1), None);
        assert_eq!(
            sm.diagnostics().last(),
            Some("delta time must be finite and >= 0 seconds (got -0.1)")
        );
    }

    #[test]
    fn decompress_rejects_output_over_limit() {
        let plain = format!(
            "--[[LUREK_SAVE v2 format=json encoding=text compressed=false]]\n{{\"blob\":\"{}\"}}",
            "x".repeat(256)
        );
        let compressed = compress_save_content(&plain).expect("compress");
        let limits = SaveCompressionLimits {
            max_decompressed_bytes: 64,
            ..SaveCompressionLimits::default()
        };
        let err = decompress_save_content_with_limits(&compressed, &limits)
            .expect_err("limit should reject payload");
        assert!(err.to_string().contains("decompressed bytes"));
    }

    #[test]
    fn compressed_header_checksum_detects_corruption() {
        let plain = "--[[LUREK_SAVE v2 format=json encoding=text compressed=false]]\n{\"hp\":10}";
        let compressed = compress_save_content(plain).expect("compress");
        let mut lines: Vec<String> = compressed.lines().map(str::to_string).collect();
        let header = &mut lines[0];
        let checksum_pos = header.find("sha256=").expect("checksum field") + "sha256=".len();
        let replacement = if &header[checksum_pos..checksum_pos + 1] == "a" {
            "b"
        } else {
            "a"
        };
        header.replace_range(checksum_pos..checksum_pos + 1, replacement);
        let corrupt = format!("{}\n{}\n", lines[0], lines[1]);
        let err = decompress_save_content(&corrupt).expect_err("checksum mismatch");
        assert!(err.contains("checksum"));
    }
}
