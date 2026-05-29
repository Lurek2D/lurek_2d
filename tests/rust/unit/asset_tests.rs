//! File: tests/rust/unit/asset_tests.rs

use lurek2d::asset::{AssetCache, AssetType};

#[test]
fn register_assigns_monotonic_ids() {
    let mut cache = AssetCache::new();
    let a = cache.register("a.txt".to_string(), AssetType::Text, Some("a".to_string()));
    let b = cache.register("b.txt".to_string(), AssetType::Text, Some("b".to_string()));
    assert!(b > a);
}

#[test]
fn ref_count_transitions_to_unloaded_after_dec() {
    let mut cache = AssetCache::new();
    let id = cache.register("a.txt".to_string(), AssetType::Text, Some("a".to_string()));
    assert_eq!(1, cache.ref_count(id));
    cache.dec_ref(id);
    assert_eq!(0, cache.ref_count(id));
    assert!(!cache.is_loaded(id));
}

#[test]
fn set_name_and_group_roundtrip() {
    let mut cache = AssetCache::new();
    let id = cache.register("foo.toml".to_string(), AssetType::Toml, Some("x=1".to_string()));
    cache.set_name(id, "config".to_string());
    cache.set_group(id, "project".to_string());

    let entry = cache.get(id).expect("entry should exist");
    assert_eq!(Some("config"), entry.name.as_deref());
    assert_eq!(Some("project"), entry.group.as_deref());
}

#[test]
fn add_and_remove_tags_behave_as_set() {
    let mut cache = AssetCache::new();
    let id = cache.register("a.json".to_string(), AssetType::Json, Some("{}".to_string()));

    cache.add_tag(id, "ui");
    cache.add_tag(id, "ui");
    assert!(cache.has_tag(id, "ui"));

    assert!(cache.remove_tag(id, "ui"));
    assert!(!cache.has_tag(id, "ui"));
    assert!(!cache.remove_tag(id, "ui"));
}

#[test]
fn find_by_name_is_case_insensitive() {
    let mut cache = AssetCache::new();
    let id = cache.register("Cargo.toml".to_string(), AssetType::Toml, Some("".to_string()));
    cache.set_name(id, "ProjectConfig".to_string());

    let hits = cache.find_by_name("project");
    assert_eq!(vec![id], hits);
}

#[test]
fn find_by_group_returns_only_matching_ids() {
    let mut cache = AssetCache::new();
    let a = cache.register("a.json".to_string(), AssetType::Json, Some("{}".to_string()));
    let b = cache.register("b.json".to_string(), AssetType::Json, Some("{}".to_string()));
    cache.set_group(a, "ui".to_string());
    cache.set_group(b, "gfx".to_string());

    assert_eq!(vec![a], cache.find_by_group("ui"));
    assert_eq!(vec![b], cache.find_by_group("gfx"));
}

#[test]
fn find_by_tag_returns_all_tagged_ids() {
    let mut cache = AssetCache::new();
    let a = cache.register("a.lua".to_string(), AssetType::Lua, Some("".to_string()));
    let b = cache.register("b.lua".to_string(), AssetType::Lua, Some("".to_string()));
    cache.add_tag(a, "script");
    cache.add_tag(b, "script");

    assert_eq!(vec![a, b], cache.find_by_tag("script"));
}

#[test]
fn find_by_type_matches_type_string() {
    let mut cache = AssetCache::new();
    let a = cache.register("a.wav".to_string(), AssetType::Audio, None);
    let b = cache.register("b.ogg".to_string(), AssetType::Music, None);

    assert_eq!(vec![a], cache.find_by_type("audio"));
    assert_eq!(vec![b], cache.find_by_type("music"));
}

#[test]
fn clear_removes_all_entries_and_groups() {
    let mut cache = AssetCache::new();
    let a = cache.register("a.json".to_string(), AssetType::Json, Some("{}".to_string()));
    cache.set_group(a, "ui".to_string());

    assert_eq!(1, cache.loaded_count());
    assert_eq!(vec!["ui".to_string()], cache.unique_groups());

    cache.clear();
    assert_eq!(0, cache.loaded_count());
    assert!(cache.unique_groups().is_empty());
}
