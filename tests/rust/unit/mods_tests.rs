//! Tests for the mods module.

// ── mod_manager ───────────────────────────────────────────────────────────────

mod mod_manager_tests {
    use lurek2d::mods::{ModInfo, ModManager};

    #[test]
    fn new_mod_info_defaults() {
        let info = ModInfo::new("test-mod");
        assert_eq!(info.id, "test-mod");
        assert_eq!(info.name, "test-mod");
        assert_eq!(info.version, "1.0.0");
        assert!(info.enabled);
        assert!(!info.loaded);
        assert!(info.path.is_none());
    }

    #[test]
    fn register_and_lookup() {
        let mut mgr = ModManager::new();
        mgr.register_mod(ModInfo::new("mod-a"));
        assert!(mgr.has_mod("mod-a"));
        assert!(!mgr.has_mod("mod-b"));
        assert_eq!(mgr.mod_count(), 1);
    }

    #[test]
    fn unregister_mod() {
        let mut mgr = ModManager::new();
        mgr.register_mod(ModInfo::new("mod-a"));
        assert!(mgr.unregister_mod("mod-a"));
        assert!(!mgr.has_mod("mod-a"));
        assert!(!mgr.unregister_mod("mod-a"));
    }

    #[test]
    fn load_order_by_priority() {
        let mut mgr = ModManager::new();
        let mut b = ModInfo::new("mod-b");
        b.priority = 10;
        let mut a = ModInfo::new("mod-a");
        a.priority = 5;
        mgr.register_mod(b);
        mgr.register_mod(a);
        let order = mgr.load_order();
        assert_eq!(order[0].id, "mod-a");
        assert_eq!(order[1].id, "mod-b");
    }

    #[test]
    fn validate_deps_reports_missing() {
        let mut mgr = ModManager::new();
        let mut info = ModInfo::new("mod-a");
        info.dependencies = vec!["mod-b".to_string()];
        mgr.register_mod(info);
        let missing = mgr.validate_dependencies();
        assert_eq!(missing, vec!["mod-b"]);
    }

    #[test]
    fn validate_deps_ok_when_satisfied() {
        let mut mgr = ModManager::new();
        let mut a = ModInfo::new("mod-a");
        a.dependencies = vec!["mod-b".to_string()];
        mgr.register_mod(a);
        mgr.register_mod(ModInfo::new("mod-b"));
        let missing = mgr.validate_dependencies();
        assert!(missing.is_empty());
    }

    #[test]
    fn detect_circular_deps() {
        let mut mgr = ModManager::new();
        let mut a = ModInfo::new("a");
        a.dependencies = vec!["b".to_string()];
        let mut b = ModInfo::new("b");
        b.dependencies = vec!["a".to_string()];
        mgr.register_mod(a);
        mgr.register_mod(b);
        assert!(mgr.has_circular_dependencies());
    }

    #[test]
    fn no_circular_deps() {
        let mut mgr = ModManager::new();
        let mut a = ModInfo::new("a");
        a.dependencies = vec!["b".to_string()];
        mgr.register_mod(a);
        mgr.register_mod(ModInfo::new("b"));
        assert!(!mgr.has_circular_dependencies());
    }

    #[test]
    fn custom_load_order_respected() {
        let mut mgr = ModManager::new();
        let mut a = ModInfo::new("a");
        a.priority = 5;
        let mut b = ModInfo::new("b");
        b.priority = 1;
        mgr.register_mod(a);
        mgr.register_mod(b);
        // Without custom order, b (priority 1) would load first
        assert_eq!(mgr.load_order()[0].id, "b");
        // With custom order, a goes first
        mgr.set_load_order(vec!["a".to_string(), "b".to_string()]);
        assert_eq!(mgr.load_order()[0].id, "a");
        assert_eq!(mgr.load_order()[1].id, "b");
    }

    #[test]
    fn clear_load_order_reverts_to_priority() {
        let mut mgr = ModManager::new();
        let mut a = ModInfo::new("a");
        a.priority = 10;
        let mut b = ModInfo::new("b");
        b.priority = 1;
        mgr.register_mod(a);
        mgr.register_mod(b);
        mgr.set_load_order(vec!["a".to_string()]);
        mgr.clear_load_order();
        assert_eq!(mgr.load_order()[0].id, "b");
    }

    #[test]
    fn mark_for_reload_queues_mod() {
        let mut mgr = ModManager::new();
        mgr.register_mod(ModInfo::new("mod-a"));
        assert!(mgr.mark_for_reload("mod-a"));
        assert_eq!(mgr.get_reload_queue(), &["mod-a"]);
    }

    #[test]
    fn mark_for_reload_deduplicates() {
        let mut mgr = ModManager::new();
        mgr.register_mod(ModInfo::new("mod-a"));
        mgr.mark_for_reload("mod-a");
        mgr.mark_for_reload("mod-a");
        assert_eq!(mgr.get_reload_queue().len(), 1);
    }

    #[test]
    fn mark_for_reload_returns_false_for_missing() {
        let mut mgr = ModManager::new();
        assert!(!mgr.mark_for_reload("nonexistent"));
        assert!(mgr.get_reload_queue().is_empty());
    }

    #[test]
    fn clear_reload_queue_empties_it() {
        let mut mgr = ModManager::new();
        mgr.register_mod(ModInfo::new("a"));
        mgr.mark_for_reload("a");
        mgr.clear_reload_queue();
        assert!(mgr.get_reload_queue().is_empty());
    }

    #[test]
    fn unregister_removes_from_reload_queue() {
        let mut mgr = ModManager::new();
        mgr.register_mod(ModInfo::new("a"));
        mgr.mark_for_reload("a");
        mgr.unregister_mod("a");
        assert!(mgr.get_reload_queue().is_empty());
    }

    #[test]
    fn scan_folder_returns_empty_for_missing_path() {
        let mut mgr = ModManager::new();
        let found = mgr.scan_folder("/nonexistent/path/that/does/not/exist");
        assert!(found.is_empty());
    }

    #[test]
    fn scan_folder_registers_mods_from_disk() {
        use std::io::Write;
        let tmpdir = std::env::temp_dir().join("luna2d_scan_test");
        let _ = std::fs::remove_dir_all(&tmpdir);
        let mod_dir = tmpdir.join("my-mod");
        std::fs::create_dir_all(&mod_dir).unwrap();
        let toml_path = mod_dir.join("mod.toml");
        let mut f = std::fs::File::create(&toml_path).unwrap();
        writeln!(f, r#"id = "my-mod""#).unwrap();
        writeln!(f, r#"name = "My Mod""#).unwrap();
        writeln!(f, r#"version = "2.0.0""#).unwrap();
        writeln!(f, r#"priority = 5"#).unwrap();
        drop(f);

        let mut mgr = ModManager::new();
        let found = mgr.scan_folder(tmpdir.to_str().unwrap());
        assert_eq!(found.len(), 1);
        assert_eq!(found[0].id, "my-mod");
        assert_eq!(found[0].version, "2.0.0");
        assert_eq!(found[0].priority, 5);
        assert!(found[0].path.is_some());
        assert!(mgr.has_mod("my-mod"));

        // Clean up
        let _ = std::fs::remove_dir_all(&tmpdir);
    }
}
