use lurek2d::asset::{AssetCache, AssetType};
use std::path::Path;
use std::time::Duration;

#[test]
fn repeated_loads_share_one_cache_entry_and_increment_refs() {
    let mut cache = AssetCache::new();

    let first = cache.register(
        "tests/lua/unit/test_asset_unit.lua".to_string(),
        AssetType::Lua,
        Some("print('a')".to_string()),
    );
    let second = cache.register(
        "tests\\lua\\unit\\test_asset_unit.lua".to_string(),
        AssetType::Lua,
        Some("print('b')".to_string()),
    );

    assert_eq!(first, second);
    assert_eq!(cache.loaded_count(), 1);
    assert_eq!(cache.ref_count(first), 2);
    assert_eq!(
        cache
            .get(first)
            .and_then(|entry| entry.text_content.as_deref()),
        Some("print('a')")
    );
}

#[test]
fn cache_key_keeps_same_path_with_different_types_separate() {
    let mut cache = AssetCache::new();

    let json_id = cache.register(
        "tests/lua/unit/test_asset_unit.lua".to_string(),
        AssetType::Json,
        Some("{}".to_string()),
    );
    let lua_id = cache.register(
        "tests/lua/unit/test_asset_unit.lua".to_string(),
        AssetType::Lua,
        Some("return {}".to_string()),
    );

    assert_ne!(json_id, lua_id);
    assert_eq!(cache.loaded_count(), 2);
    assert_eq!(cache.ref_count(json_id), 1);
    assert_eq!(cache.ref_count(lua_id), 1);
}

#[test]
fn releasing_last_reference_removes_cached_key() {
    let mut cache = AssetCache::new();

    let id = cache.register(
        "tests/lua/unit/test_asset_unit.lua".to_string(),
        AssetType::Text,
        Some("content".to_string()),
    );
    let same_id = cache.register(
        "tests/lua/unit/test_asset_unit.lua".to_string(),
        AssetType::Text,
        Some("ignored".to_string()),
    );
    assert_eq!(id, same_id);

    cache.dec_ref(id);
    assert_eq!(cache.ref_count(id), 1);
    cache.dec_ref(id);
    assert_eq!(cache.ref_count(id), 0);
    assert_eq!(cache.loaded_count(), 0);

    let reloaded = cache.register(
        "tests/lua/unit/test_asset_unit.lua".to_string(),
        AssetType::Text,
        Some("fresh".to_string()),
    );
    assert_ne!(id, reloaded);
    assert_eq!(cache.loaded_count(), 1);
    assert_eq!(cache.ref_count(reloaded), 1);
}

#[test]
fn watched_entries_report_timestamp_changes_until_reload() {
    let dir = Path::new("work");
    std::fs::create_dir_all(dir).unwrap();
    let path = dir.join("asset_cache_watch_test.txt");
    std::fs::write(&path, "v1").unwrap();

    let mut cache = AssetCache::new();
    let id = cache.register(
        path.to_string_lossy().into_owned(),
        AssetType::Text,
        Some("v1".to_string()),
    );

    assert!(!cache.watched_changed(id));
    assert!(cache.watch(id));
    assert!(!cache.watched_changed(id));

    std::thread::sleep(Duration::from_millis(60));
    std::fs::write(&path, "v2").unwrap();

    assert!(cache.watched_changed(id));
    assert_eq!(cache.reload(id, Some("v2".to_string())), Some(2));
    assert!(!cache.watched_changed(id));

    let _ = std::fs::remove_file(path);
}
