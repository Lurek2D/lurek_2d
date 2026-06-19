//! File: tests/rust/unit/mods_tests.rs

mod mods_tests {
    use lurek2d::lua_api::{create_lua_vm, SharedState};
    use lurek2d::mods::{
        load_instances_from_toml_with_options, DependencyCyclePolicy, FieldValue, HookPoint,
        ModContentLoadOptions, ModError, ModInfo, ModLimits, ModManager, ModSandbox, ModScanPolicy,
    };
    use lurek2d::runtime::config::Config;
    use lurek2d::runtime::RuntimeMode;
    use mlua::prelude::LuaValue;
    use std::cell::RefCell;
    use std::fs;
    use std::path::{Path, PathBuf};
    use std::rc::Rc;
    use tempfile::tempdir;

    fn write_mod_manifest(dir: &Path, manifest: &str) {
        fs::create_dir_all(dir).unwrap();
        fs::write(dir.join("mod.toml"), manifest).unwrap();
    }

    fn new_test_state(base_dir: &Path) -> Rc<RefCell<SharedState>> {
        let mut shared = SharedState::new(800, 600, "Test", base_dir.to_path_buf());
        shared.runtime_mode = RuntimeMode::Headless;
        Rc::new(RefCell::new(shared))
    }

    #[test]
    fn default_sandbox_does_not_allow_all() {
        let temp = tempdir().unwrap();
        let sandbox = ModSandbox::new();

        assert!(!sandbox.is_api_allowed("filesystem"));
        assert!(!sandbox.is_hook_allowed(&HookPoint::OnLoad));
        assert!(!sandbox.is_read_allowed(temp.path().to_str().unwrap()));
    }

    #[test]
    fn read_path_policy_rejects_prefix_and_traversal() {
        let temp = tempdir().unwrap();
        let root_a = temp.path().join("mods").join("a");
        let root_a2 = temp.path().join("mods").join("a2");
        fs::create_dir_all(&root_a).unwrap();
        fs::create_dir_all(&root_a2).unwrap();
        fs::write(root_a.join("inside.txt"), "ok").unwrap();
        fs::write(root_a2.join("outside.txt"), "nope").unwrap();

        let mut sandbox = ModSandbox::new();
        sandbox.allow_read_root(&root_a).unwrap();

        assert!(sandbox.is_read_allowed(root_a.join("inside.txt").to_str().unwrap()));
        assert!(sandbox.is_read_allowed(root_a.join("missing.txt").to_str().unwrap()));
        assert!(!sandbox.is_read_allowed(root_a2.join("outside.txt").to_str().unwrap()));
        assert!(!sandbox.is_read_allowed(
            temp.path()
                .join("mods")
                .join("a")
                .join("..")
                .join("a2")
                .join("outside.txt")
                .to_str()
                .unwrap()
        ));
    }

    #[test]
    fn content_loader_uses_real_toml_parser() {
        let content = r#"
            [[item]]
            id = "iron_sword"
            tags = ["weapon", "melee"]
            name = "Iron\nSword"
            [item.stats]
            damage = 10
            crit = 0.25
        "#;
        let source = PathBuf::from("items.toml");
        let instances = load_instances_from_toml_with_options(
            "base_mod",
            content,
            &source,
            &ModContentLoadOptions::default(),
        )
        .unwrap();

        assert_eq!(instances.len(), 1);
        assert_eq!(instances[0].instance_id, "iron_sword");
        assert_eq!(
            instances[0].get_field("name"),
            Some(&FieldValue::String("Iron\nSword".to_string()))
        );
        assert!(matches!(
            instances[0].get_field("tags"),
            Some(FieldValue::Array(values)) if values.len() == 2
        ));
        assert!(matches!(
            instances[0].get_field("stats"),
            Some(FieldValue::Table(stats)) if stats.contains_key("damage") && stats.contains_key("crit")
        ));

        let invalid = load_instances_from_toml_with_options(
            "base_mod",
            "[[item]\nid = \"broken\"",
            &source,
            &ModContentLoadOptions::default(),
        );
        assert!(invalid.is_err());
    }

    #[test]
    fn scan_folder_rejects_huge_manifest() {
        let temp = tempdir().unwrap();
        let mod_dir = temp.path().join("big_mod");
        let mut manifest = "id = \"big_mod\"\n".to_string();
        manifest.push_str(&format!("description = \"{}\"\n", "x".repeat(300)));
        write_mod_manifest(&mod_dir, &manifest);

        let mut manager = ModManager::new();
        let mut policy = ModScanPolicy::default();
        policy.limits.max_manifest_bytes = 64;
        let report = manager
            .scan_folder_with_policy(temp.path().to_str().unwrap(), &policy)
            .unwrap();

        assert!(report.loaded.is_empty());
        assert_eq!(report.skipped.len(), 1);
        assert_eq!(manager.mod_count(), 0);
    }

    #[test]
    fn dependency_cycle_strict_mode_errors() {
        let mut manager = ModManager::new();
        let mut a = ModInfo::new("a");
        a.dependencies = vec!["b".to_string()];
        let mut b = ModInfo::new("b");
        b.dependencies = vec!["a".to_string()];
        manager.register_mod(a);
        manager.register_mod(b);

        let plan = manager.build_load_plan(None, DependencyCyclePolicy::Error);
        assert!(plan
            .errors
            .iter()
            .any(|err| matches!(err, ModError::DependencyCycle { .. })));
        assert!(manager
            .load_order_checked(None, DependencyCyclePolicy::Error)
            .is_err());
    }

    #[test]
    fn missing_dependency_prevents_load_plan() {
        let temp = tempdir().unwrap();
        write_mod_manifest(
            &temp.path().join("consumer"),
            r#"
id = "consumer"
dependencies = ["missing_dep"]
"#,
        );

        let mut manager = ModManager::new();
        let report = manager.scan_folder(temp.path().to_str().unwrap());
        assert!(report.is_empty());
        assert_eq!(manager.mod_count(), 0);
    }

    #[test]
    fn hot_reload_failure_rolls_back() {
        let temp = tempdir().unwrap();
        let mod_dir = temp.path().join("reload_mod");
        write_mod_manifest(
            &mod_dir,
            r#"
id = "reload_mod"
version = "1.0.0"
"#,
        );

        let mut manager = ModManager::new();
        let discovered = manager.scan_folder(temp.path().to_str().unwrap());
        assert_eq!(discovered.len(), 1);
        assert_eq!(manager.get_mod("reload_mod").unwrap().version, "1.0.0");

        manager.mark_for_reload("reload_mod");
        write_mod_manifest(
            &mod_dir,
            r#"
id = "reload_mod"
dependencies = ["missing_dep"]
"#,
        );

        let report = manager.process_reload_queue_with_policy(&ModScanPolicy::default());
        assert!(report.reloaded.is_empty());
        assert!(!report.failed.is_empty());
        assert_eq!(manager.get_mod("reload_mod").unwrap().version, "1.0.0");
    }

    #[test]
    fn mod_id_asset_path_and_schema_validation() {
        let temp = tempdir().unwrap();
        write_mod_manifest(
            &temp.path().join("bad_mod"),
            r#"
id = "bad/mod"
assets = ["../escape.png"]
config_schema = [{ key = "volume", type = "WeaponType" }]
"#,
        );
        write_mod_manifest(
            &temp.path().join("bad_capability"),
            r#"
id = "bad_capability"
capabilities = ["bad capability"]
"#,
        );

        let mut manager = ModManager::new();
        let report = manager
            .scan_folder_with_policy(temp.path().to_str().unwrap(), &ModScanPolicy::default())
            .unwrap();

        assert!(report.loaded.is_empty());
        assert_eq!(report.skipped.len(), 2);
        assert!(HookPoint::parse_validated("bad hook name", &ModLimits::default()).is_err());
    }

    #[test]
    fn manifest_sandbox_policy_is_parsed() {
        let temp = tempdir().unwrap();
        let read_root = temp.path().join("sandboxed_mod").join("data");
        fs::create_dir_all(&read_root).unwrap();
        write_mod_manifest(
            &temp.path().join("sandboxed_mod"),
            r#"
id = "sandboxed_mod"
[sandbox]
api_mode = "allow_list"
apis = ["filesystem"]
hook_mode = "allow_list"
hooks = ["on_load"]
read_mode = "allow_list"
read_roots = ["data"]
allow_network = false
allow_file_write = false
max_memory = 4096
"#,
        );

        let mut manager = ModManager::new();
        let report = manager
            .scan_folder_with_policy(temp.path().to_str().unwrap(), &ModScanPolicy::default())
            .unwrap();

        assert_eq!(report.loaded.len(), 1);
        let sandbox = report.loaded[0].sandbox.as_ref().expect("sandbox parsed");
        assert!(sandbox.is_api_allowed("filesystem"));
        assert!(sandbox.is_hook_allowed(&HookPoint::OnLoad));
        assert!(sandbox.is_read_allowed(read_root.join("ok.txt").to_str().unwrap()));
        assert!(!sandbox.allow_network);
        assert!(!sandbox.allow_file_write);
        assert_eq!(sandbox.max_memory, 4096);
    }

    #[test]
    fn sandbox_blocks_file_write_api() {
        let temp = tempdir().unwrap();
        let lua = create_lua_vm(new_test_state(temp.path()), &Config::default().modules).unwrap();

        let result: (bool, LuaValue) = lua
            .load(
                r#"
                return pcall(function()
                    local mod = lurek.mods.newMod({
                        id = "mod_under_test",
                        sandbox = {
                            api_mode = "allow_list",
                            apis = { "filesystem" },
                            hook_mode = "allow_list",
                            hooks = { "on_load" },
                        },
                    })
                    mod:setHook("on_load", function()
                        lurek.filesystem.write("save/blocked.txt", "hello")
                    end)
                    mod:runHook("on_load")
                end)
                "#,
            )
            .eval()
            .unwrap();

        assert!(!result.0);
        match result.1 {
            LuaValue::String(message) => {
                let text = message.to_str().unwrap();
                assert!(text.contains("cannot call filesystem.write"));
            }
            LuaValue::Error(error) => {
                let text = error.to_string();
                assert!(text.contains("cannot call filesystem.write"));
            }
            other => panic!("expected Lua error string, got {:?}", other),
        }
        assert!(!temp.path().join("save").join("blocked.txt").exists());
    }

    #[test]
    fn sandbox_blocks_network_api_when_network_is_disabled() {
        let temp = tempdir().unwrap();
        let lua = create_lua_vm(new_test_state(temp.path()), &Config::default().modules).unwrap();

        let result: (bool, LuaValue) = lua
            .load(
                r#"
                return pcall(function()
                    local mod = lurek.mods.newMod({
                        id = "mod_under_test",
                        sandbox = {
                            api_mode = "allow_list",
                            apis = { "network" },
                            hook_mode = "allow_list",
                            hooks = { "on_load" },
                        },
                    })
                    mod:setHook("on_load", function()
                        lurek.network.newServer({ port = 12345 })
                    end)
                    mod:runHook("on_load")
                end)
                "#,
            )
            .eval()
            .unwrap();

        assert!(!result.0);
        match result.1 {
            LuaValue::String(message) => {
                let text = message.to_str().unwrap();
                assert!(text.contains("network access is disabled"));
            }
            LuaValue::Error(error) => {
                let text = error.to_string();
                assert!(text.contains("network access is disabled"));
            }
            other => panic!("expected Lua network error, got {:?}", other),
        }
    }

    #[test]
    fn sandboxed_hook_enforces_memory_limit_and_restores_previous_limit() {
        let temp = tempdir().unwrap();
        let lua = create_lua_vm(new_test_state(temp.path()), &Config::default().modules).unwrap();
        if cfg!(feature = "lua-jit") && lua.set_memory_limit(0).is_err() {
            return;
        }
        let limit = lua.used_memory() + 10_000;
        let script = format!(
            r#"
            local mod = lurek.mods.newMod({{
                id = "memory_mod",
                sandbox = {{
                    hook_mode = "allow_list",
                    hooks = {{ "on_load" }},
                    max_memory = {},
                }},
            }})
            mod:setHook("on_load", function()
                local t = {{}}
                for i = 1, 10000 do
                    t[i] = i
                end
            end)
            return pcall(function()
                mod:runHook("on_load")
            end)
            "#,
            limit
        );

        let result: (bool, LuaValue) = lua.load(&script).eval().unwrap();

        assert!(!result.0);
        match result.1 {
            LuaValue::String(message) => {
                let text = message.to_str().unwrap().to_ascii_lowercase();
                assert!(text.contains("memory"));
            }
            LuaValue::Error(error) => {
                let text = error.to_string().to_ascii_lowercase();
                assert!(text.contains("memory"));
            }
            other => panic!("expected Lua memory error, got {:?}", other),
        }

        let previous_limit = lua.set_memory_limit(0).unwrap();
        assert_eq!(previous_limit, 0);
        lua.load(
            r#"
            local t = {}
            for i = 1, 10000 do
                t[i] = i
            end
            "#,
        )
        .exec()
        .unwrap();
    }
}
