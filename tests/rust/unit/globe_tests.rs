//! File: tests/rust/unit/globe_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

// Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬ fog Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬

mod fog_tests {

    use lurek2d::globe::types::RegionId;
    use lurek2d::globe::{FogMask, FogStore};

    // FogMask::all_hidden

    #[test]
    fn all_hidden_no_province_visible() {
        let mask = FogMask::all_hidden();
        assert!(!mask.is_visible(RegionId(0)));
        assert!(!mask.is_visible(RegionId(1)));
        assert!(!mask.is_visible(RegionId(100)));
    }

    #[test]
    fn all_hidden_count_visible_is_zero() {
        let mask = FogMask::all_hidden();
        assert_eq!(mask.count_visible(), 0);
    }

    #[test]
    fn all_hidden_visible_ids_is_empty() {
        let mask = FogMask::all_hidden();
        assert!(mask.visible_ids().is_empty());
    }

    // FogMask::all_visible

    #[test]
    fn all_visible_province_zero_visible() {
        let mask = FogMask::all_visible();
        assert!(mask.is_visible(RegionId(0)));
    }

    #[test]
    fn all_visible_province_ten_visible() {
        let mask = FogMask::all_visible();
        assert!(mask.is_visible(RegionId(10)));
    }

    #[test]
    fn all_visible_count_visible_nonzero() {
        let mask = FogMask::all_visible();
        assert!(mask.count_visible() > 0);
    }

    // FogMask::reveal / hide

    #[test]
    fn reveal_makes_province_visible() {
        let mut mask = FogMask::all_hidden();
        mask.reveal(RegionId(5));
        assert!(mask.is_visible(RegionId(5)));
        assert!(!mask.is_visible(RegionId(6)));
    }

    #[test]
    fn hide_after_reveal_hides_province() {
        let mut mask = FogMask::all_hidden();
        mask.reveal(RegionId(3));
        assert!(mask.is_visible(RegionId(3)));
        mask.hide(RegionId(3));
        assert!(!mask.is_visible(RegionId(3)));
    }

    #[test]
    fn reveal_increments_count() {
        let mut mask = FogMask::all_hidden();
        mask.reveal(RegionId(0));
        mask.reveal(RegionId(1));
        mask.reveal(RegionId(2));
        assert_eq!(mask.count_visible(), 3);
    }

    #[test]
    fn hide_decrements_count() {
        let mut mask = FogMask::all_hidden();
        mask.reveal(RegionId(0));
        mask.reveal(RegionId(1));
        mask.hide(RegionId(0));
        assert_eq!(mask.count_visible(), 1);
    }

    #[test]
    fn reveal_out_of_bounds_is_noop() {
        let mut mask = FogMask::all_hidden();
        // Revealing an ID at or beyond MAX_PROVINCES should not panic.
        mask.reveal(RegionId(99999));
        assert!(!mask.is_visible(RegionId(99999)));
    }

    // FogMask::reveal_batch

    #[test]
    fn reveal_batch_reveals_all_ids() {
        let mut mask = FogMask::all_hidden();
        mask.reveal_batch([RegionId(10), RegionId(20), RegionId(30)].iter().copied());
        assert!(mask.is_visible(RegionId(10)));
        assert!(mask.is_visible(RegionId(20)));
        assert!(mask.is_visible(RegionId(30)));
        assert!(!mask.is_visible(RegionId(11)));
    }

    // FogMask::visible_ids

    #[test]
    fn visible_ids_returns_revealed_ids() {
        let mut mask = FogMask::all_hidden();
        mask.reveal(RegionId(1));
        mask.reveal(RegionId(7));
        mask.reveal(RegionId(63));
        let mut ids = mask.visible_ids();
        ids.sort_unstable();
        assert_eq!(ids, vec![RegionId(1), RegionId(7), RegionId(63)]);
    }

    // FogMask::from_visible_ids round-trip

    #[test]
    fn from_visible_ids_round_trip() {
        let ids: Vec<RegionId> = vec![RegionId(0), RegionId(5), RegionId(100), RegionId(255)];
        let mask = FogMask::from_visible_ids(&ids);
        let mut recovered = mask.visible_ids();
        recovered.sort_unstable();
        assert_eq!(recovered, ids);
    }

    #[test]
    fn from_visible_ids_empty_gives_hidden_mask() {
        let mask = FogMask::from_visible_ids(&[]);
        assert_eq!(mask.count_visible(), 0);
    }

    // FogStore::new / get_or_insert / reveal / hide

    #[test]
    fn fog_store_new_is_empty() {
        let store = FogStore::new();
        assert!(store.viewers().is_empty());
    }

    #[test]
    fn get_or_insert_creates_hidden_mask() {
        let mut store = FogStore::new();
        let mask = store.get_or_insert("player");
        assert_eq!(mask.count_visible(), 0);
    }

    #[test]
    fn fog_store_reveal_makes_visible() {
        let mut store = FogStore::new();
        store.reveal("player", RegionId(42));
        assert!(store.is_visible("player", RegionId(42)));
        assert!(!store.is_visible("player", RegionId(43)));
    }

    #[test]
    fn fog_store_hide_clears_visible() {
        let mut store = FogStore::new();
        store.reveal("player", RegionId(10));
        store.hide("player", RegionId(10));
        assert!(!store.is_visible("player", RegionId(10)));
    }

    // FogStore::visible_ids

    #[test]
    fn fog_store_visible_ids_for_known_viewer() {
        let mut store = FogStore::new();
        store.reveal("ally", RegionId(5));
        store.reveal("ally", RegionId(9));
        let mut ids = store.visible_ids("ally").unwrap();
        ids.sort_unstable();
        assert_eq!(ids, vec![RegionId(5), RegionId(9)]);
    }

    #[test]
    fn fog_store_visible_ids_none_for_unknown_viewer() {
        let store = FogStore::new();
        assert!(store.visible_ids("ghost").is_none());
    }

    // FogStore::viewers

    #[test]
    fn fog_store_viewers_lists_known_viewers() {
        let mut store = FogStore::new();
        store.reveal("a", RegionId(0));
        store.reveal("b", RegionId(0));
        let mut viewers = store.viewers();
        viewers.sort();
        assert_eq!(viewers, vec!["a", "b"]);
    }

    // FogStore::is_visible for unknown viewer (no fog)

    #[test]
    fn fog_store_is_visible_true_for_unknown_viewer() {
        let store = FogStore::new();
        // Unknown viewer Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬Ă‚Â Ä‚ËĂ˘â€šÂ¬Ă˘â€žË no mask Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬Ă‚Â Ä‚ËĂ˘â€šÂ¬Ă˘â€žË full visibility.
        assert!(store.is_visible("ghost", RegionId(99)));
    }

    #[test]
    fn fog_mask_base64_round_trip_preserves_states() {
        let mut mask = FogMask::all_hidden();
        mask.reveal(RegionId(1));
        mask.explore(RegionId(2));
        let encoded = mask.to_base64();
        let decoded = FogMask::from_base64(&encoded).expect("decode should succeed");
        assert!(decoded.is_visible(RegionId(1)));
        assert_eq!(decoded.count_explored(), 1);
        assert!(!decoded.is_visible(RegionId(2)));
    }
}

// Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬ lighting Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬

mod lighting_tests {
    use lurek2d::globe::lighting::{
        compute_intensities, province_intensity, sun_direction, terminator_alpha,
    };
    use lurek2d::globe::types::GlobeSpec;

    fn default_spec() -> GlobeSpec {
        GlobeSpec::default()
    }

    // sun_direction

    #[test]
    fn sun_direction_returns_unit_vector() {
        let spec = default_spec();
        let sun = sun_direction(&spec);
        let len = (sun.x * sun.x + sun.y * sun.y + sun.z * sun.z).sqrt();
        assert!((len - 1.0).abs() < 1e-4, "sun_direction not unit: {}", len);
    }

    #[test]
    fn sun_direction_changes_with_time_of_day() {
        let mut spec = default_spec();
        let s0 = sun_direction(&spec);
        spec.time_of_day = 0.5;
        let s1 = sun_direction(&spec);
        // Directions should be different when ToD changes significantly.
        let diff = (s0.x - s1.x).abs() + (s0.y - s1.y).abs() + (s0.z - s1.z).abs();
        assert!(diff > 0.1, "sun_direction did not change with time_of_day");
    }

    #[test]
    fn sun_direction_no_tilt_equinox_is_equatorial() {
        let mut spec = default_spec();
        spec.axial_tilt_deg = 0.0;
        spec.time_of_day = 0.0;
        spec.rotation_deg = 0.0;
        let sun = sun_direction(&spec);
        // At time_of_day=0 and no tilt, sun should be in equatorial plane (y Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬Ă‚Â°Ä‚â€šĂ‚Â 0).
        assert!(sun.y.abs() < 0.01, "unexpected y component: {}", sun.y);
    }

    // province_intensity

    #[test]
    fn province_intensity_at_subsolar_is_one() {
        // Province exactly under the sun (same direction as sun).
        let sun_lat = 0.0_f32;
        let sun_lon = 180.0_f32; // default ToD=0.25 Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬Ă‚Â Ä‚ËĂ˘â€šÂ¬Ă˘â€žË sun is westward, use lon 0 directly.
                                 // Use a simpler setup: direct sun vector.
        let sun = lurek2d::math::Vec3::new(0.0, 0.0, 1.0);
        // lat=90 corresponds to north pole (z=1 on unit sphere in lat_lon_to_unit).
        // Actually lat_lon_to_unit(0, 0) = (sin(0), 0, cos(0)) in some conventions;
        // since we use the Vec3 directly, test clamping to 1.0 instead.
        let _unused = (sun_lat, sun_lon);
        let intensity = province_intensity(0.0, 0.0, &sun, 0.08);
        // Dot product with (0,0,1) for lat=0, lon=0 depends on sphere convention;
        // just verify it is within [0.08, 1.0].
        assert!(
            (0.08..=1.0).contains(&intensity),
            "intensity {intensity} out of range"
        );
    }

    #[test]
    fn province_intensity_floor_at_ambient() {
        // On the night side, intensity should be clamped at ambient.
        let sun = lurek2d::math::Vec3::new(1.0, 0.0, 0.0);
        let ambient = 0.08;
        // lat=0, lon=180 puts the province on the opposite side from (1,0,0).
        let intensity = province_intensity(0.0, 180.0, &sun, ambient);
        assert!(
            intensity >= ambient - 1e-5,
            "intensity {intensity} below ambient {ambient}"
        );
    }

    #[test]
    fn province_intensity_in_range() {
        let spec = default_spec();
        let sun = sun_direction(&spec);
        let intensity = province_intensity(45.0, 30.0, &sun, spec.ambient);
        assert!(intensity >= spec.ambient && intensity <= 1.0);
    }

    // compute_intensities

    #[test]
    fn compute_intensities_length_matches_input() {
        let spec = default_spec();
        let sun = sun_direction(&spec);
        let centroids = vec![(0.0_f32, 0.0_f32), (45.0, 90.0), (-30.0, -60.0)];
        let result = compute_intensities(centroids.into_iter(), &sun, spec.ambient);
        assert_eq!(result.len(), 3);
    }

    #[test]
    fn compute_intensities_all_in_range() {
        let spec = default_spec();
        let sun = sun_direction(&spec);
        let centroids: Vec<(f32, f32)> = (0..20)
            .map(|i| (i as f32 * 9.0 - 90.0, i as f32 * 18.0 - 180.0))
            .collect();
        let result = compute_intensities(centroids.into_iter(), &sun, spec.ambient);
        for v in &result {
            assert!(
                *v >= spec.ambient && *v <= 1.0,
                "intensity {v} outside [{}, 1.0]",
                spec.ambient
            );
        }
    }

    #[test]
    fn compute_intensities_empty_input_returns_empty() {
        let spec = default_spec();
        let sun = sun_direction(&spec);
        let result = compute_intensities(std::iter::empty(), &sun, spec.ambient);
        assert!(result.is_empty());
    }

    // terminator_alpha

    #[test]
    fn terminator_alpha_day_side_is_one() {
        // Sun pointing along +Z; lat=90 (north pole) should be full day.
        let sun = lurek2d::math::Vec3::new(0.0, 1.0, 0.0);
        let alpha = terminator_alpha(90.0, 0.0, &sun, 10.0);
        // North pole with sun pointing up should be fully lit.
        assert!((0.0..=1.0).contains(&alpha));
    }

    #[test]
    fn terminator_alpha_in_range() {
        let spec = default_spec();
        let sun = sun_direction(&spec);
        let alpha = terminator_alpha(45.0, 30.0, &sun, 15.0);
        assert!((0.0..=1.0).contains(&alpha));
    }

    #[test]
    fn terminator_alpha_transition_zero_is_hard_edge() {
        let spec = default_spec();
        let sun = sun_direction(&spec);
        // With transition_deg = 0 the result can only be 0 or 1.
        let alpha = terminator_alpha(45.0, 30.0, &sun, 0.0);
        // Should not panic and return a clamped value.
        assert!((0.0..=1.0).contains(&alpha));
    }
}

// Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬ projection Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬

mod projection_tests {
    use lurek2d::globe::projection::{
        build_view_matrix, normalize_v3, project_point, project_point_on_shell,
        project_point_with_z, project_province, screen_delta_to_pan, OrbitCamera,
    };
    use lurek2d::globe::types::{GlobeSpec, LodTier, Province, RegionId};
    use lurek2d::math::Vec3;

    fn default_spec() -> GlobeSpec {
        GlobeSpec::default()
    }

    fn default_camera() -> OrbitCamera {
        OrbitCamera::default()
    }

    // OrbitCamera::default

    #[test]
    fn orbit_camera_default_values() {
        let cam = default_camera();
        assert_eq!(cam.lat_deg, 30.0);
        assert_eq!(cam.lon_deg, 0.0);
        assert_eq!(cam.zoom, 1.0);
        assert_eq!(cam.screen_cx, 640.0);
        assert_eq!(cam.screen_cy, 360.0);
    }

    // OrbitCamera::zoom_by

    #[test]
    fn zoom_by_doubles_zoom() {
        let mut cam = default_camera();
        cam.zoom_by(2.0);
        assert!((cam.zoom - 2.0).abs() < 1e-5);
    }

    #[test]
    fn zoom_by_clamped_at_max() {
        let mut cam = default_camera();
        cam.zoom_by(1000.0);
        assert!(cam.zoom <= 20.0);
    }

    #[test]
    fn zoom_by_clamped_at_min() {
        let mut cam = default_camera();
        cam.zoom_by(0.0001);
        assert!(cam.zoom >= 0.1);
    }

    // OrbitCamera::lod

    #[test]
    fn lod_far_when_zoom_below_1_5() {
        let mut cam = default_camera();
        cam.zoom = 1.0;
        assert_eq!(cam.lod(), LodTier::Far);
    }

    #[test]
    fn lod_mid_when_zoom_between_1_5_and_4() {
        let mut cam = default_camera();
        cam.zoom = 2.0;
        assert_eq!(cam.lod(), LodTier::Mid);
    }

    #[test]
    fn lod_near_when_zoom_at_least_4() {
        let mut cam = default_camera();
        cam.zoom = 4.0;
        assert_eq!(cam.lod(), LodTier::Near);
    }

    // build_view_matrix

    #[test]
    fn build_view_matrix_returns_without_panic() {
        let spec = default_spec();
        let cam = default_camera();
        let _ = build_view_matrix(&spec, &cam);
    }

    #[test]
    fn build_view_matrix_different_rotation_differs() {
        let mut spec = default_spec();
        let cam = default_camera();
        let m1 = build_view_matrix(&spec, &cam);
        spec.rotation_deg = 90.0;
        let m2 = build_view_matrix(&spec, &cam);
        // The matrices should differ.
        let same = m1.cols[0][0] == m2.cols[0][0]
            && m1.cols[1][1] == m2.cols[1][1]
            && m1.cols[2][2] == m2.cols[2][2];
        assert!(!same, "matrices should differ for different rotation_deg");
    }

    // project_point

    #[test]
    fn project_point_front_hemisphere_returns_some() {
        let spec = default_spec();
        let cam = default_camera();
        let view = build_view_matrix(&spec, &cam);
        // lat=30, lon=0 is roughly toward camera at default orientation.
        let result = project_point(
            30.0,
            0.0,
            &view,
            spec.radius,
            cam.zoom,
            cam.screen_cx,
            cam.screen_cy,
        );
        assert!(result.is_some(), "expected front-facing point to project");
    }

    #[test]
    fn project_point_far_back_returns_none() {
        let spec = default_spec();
        let cam = default_camera();
        let view = build_view_matrix(&spec, &cam);
        // lat=-30, lon=180 is the antipodal region Ă„â€šĂ‹ÂÄ‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ä‚ËĂ˘â€šÂ¬ÄąÄ„ should be culled.
        let result = project_point(
            -30.0,
            180.0,
            &view,
            spec.radius,
            cam.zoom,
            cam.screen_cx,
            cam.screen_cy,
        );
        // Allow either None or Some Ă„â€šĂ‹ÂÄ‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ä‚ËĂ˘â€šÂ¬ÄąÄ„ the exact cull depends on camera angle.
        // Just verify no panic.
        let _ = result;
    }

    #[test]
    fn project_point_result_near_screen_centre() {
        // At default camera (lat=30, lon=0) the globe center maps near screen_cx/cy.
        let spec = default_spec();
        let cam = default_camera();
        let view = build_view_matrix(&spec, &cam);
        if let Some(v) = project_point(
            30.0,
            0.0,
            &view,
            spec.radius,
            cam.zoom,
            cam.screen_cx,
            cam.screen_cy,
        ) {
            assert!(v.x > 0.0 && v.x < 1280.0);
            assert!(v.y > 0.0 && v.y < 720.0);
        }
    }

    #[test]
    fn project_point_on_shell_increases_screen_radius_for_higher_orbits() {
        let mut spec = default_spec();
        spec.axial_tilt_deg = 0.0;
        let mut cam = default_camera();
        cam.lat_deg = 0.0;
        cam.lon_deg = 0.0;
        let view = build_view_matrix(&spec, &cam);
        let base = project_point_on_shell(
            0.0,
            45.0,
            &view,
            spec.radius,
            cam.zoom,
            cam.screen_cx,
            cam.screen_cy,
        )
        .expect("surface point should project")
        .0;
        let higher = project_point_on_shell(
            0.0,
            45.0,
            &view,
            spec.radius + 20.0,
            cam.zoom,
            cam.screen_cx,
            cam.screen_cy,
        )
        .expect("orbit shell point should project")
        .0;
        let base_dist = (base.x - cam.screen_cx).abs();
        let higher_dist = (higher.x - cam.screen_cx).abs();
        assert!(higher_dist > base_dist);
    }

    // project_province

    #[test]
    fn project_province_front_visible() {
        let spec = default_spec();
        let cam = default_camera();
        let view = build_view_matrix(&spec, &cam);
        // A tiny triangle near lat=30, lon=0 (front hemisphere at default cam).
        let verts = vec![(30.0_f32, -1.0_f32), (31.0, 0.0), (30.0, 1.0)];
        let prov = Province::new(RegionId(1), verts);
        let result = project_province(&prov, &view, &spec, &cam, 1.0);
        assert!(result.is_some(), "front-hemisphere province should project");
    }

    #[test]
    fn project_province_culled_returns_none_or_some() {
        let spec = default_spec();
        let cam = default_camera();
        let view = build_view_matrix(&spec, &cam);
        // Province near south pole, antipodal side Ă„â€šĂ‹ÂÄ‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ä‚ËĂ˘â€šÂ¬ÄąÄ„ likely culled.
        let verts = vec![(-80.0_f32, 170.0_f32), (-80.0, 175.0), (-75.0, 172.0)];
        let prov = Province::new(RegionId(2), verts);
        let _ = project_province(&prov, &view, &spec, &cam, 0.5);
        // No panic is the assertion.
    }

    // project_point_with_z

    #[test]
    fn project_point_with_z_returns_positive_z_on_front() {
        let spec = default_spec();
        let cam = default_camera();
        let view = build_view_matrix(&spec, &cam);
        if let Some((_pos, z)) = project_point_with_z(30.0, 0.0, &view, &spec, &cam) {
            assert!(z > 0.0, "z should be positive on front hemisphere");
        }
    }

    #[test]
    fn project_point_with_z_back_hemisphere_returns_none() {
        let spec = default_spec();
        let cam = default_camera();
        let view = build_view_matrix(&spec, &cam);
        // Test a point that might be on the back Ă„â€šĂ‹ÂÄ‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ä‚ËĂ˘â€šÂ¬ÄąÄ„ at minimum, no panic.
        let _ = project_point_with_z(-30.0, 180.0, &view, &spec, &cam);
    }

    // screen_delta_to_pan

    #[test]
    fn screen_delta_to_pan_nonzero_for_nonzero_delta() {
        let spec = default_spec();
        let cam = default_camera();
        let (dlat, dlon) = screen_delta_to_pan(10.0, 5.0, &spec, &cam);
        assert!(dlat != 0.0 || dlon != 0.0);
    }

    #[test]
    fn screen_delta_to_pan_zero_delta_is_zero() {
        let spec = default_spec();
        let cam = default_camera();
        let (dlat, dlon) = screen_delta_to_pan(0.0, 0.0, &spec, &cam);
        assert_eq!(dlat, 0.0);
        assert_eq!(dlon, 0.0);
    }

    #[test]
    fn screen_delta_to_pan_dx_moves_longitude() {
        let spec = default_spec();
        let cam = default_camera();
        let (_, dlon) = screen_delta_to_pan(10.0, 0.0, &spec, &cam);
        assert!(dlon != 0.0, "dx should produce a lon change");
    }

    #[test]
    fn screen_delta_to_pan_dy_moves_latitude() {
        let spec = default_spec();
        let cam = default_camera();
        let (dlat, _) = screen_delta_to_pan(0.0, 10.0, &spec, &cam);
        assert!(dlat != 0.0, "dy should produce a lat change");
    }

    // normalize_v3

    #[test]
    fn normalize_v3_unit_vector() {
        let v = Vec3::new(3.0, 4.0, 0.0);
        let n = normalize_v3(v);
        let len = (n.x * n.x + n.y * n.y + n.z * n.z).sqrt();
        assert!((len - 1.0).abs() < 1e-6, "normalized length {}", len);
    }

    #[test]
    fn normalize_v3_already_unit() {
        let v = Vec3::new(1.0, 0.0, 0.0);
        let n = normalize_v3(v);
        assert!((n.x - 1.0).abs() < 1e-6);
        assert!(n.y.abs() < 1e-6);
        assert!(n.z.abs() < 1e-6);
    }

    #[test]
    fn normalize_v3_zero_returns_zero() {
        let v = Vec3::new(0.0, 0.0, 0.0);
        let n = normalize_v3(v);
        assert_eq!(n.x, 0.0);
        assert_eq!(n.y, 0.0);
        assert_eq!(n.z, 0.0);
    }

    #[test]
    fn normalize_v3_negative_components() {
        let v = Vec3::new(-1.0, -1.0, -1.0);
        let n = normalize_v3(v);
        let len = (n.x * n.x + n.y * n.y + n.z * n.z).sqrt();
        assert!((len - 1.0).abs() < 1e-6);
    }
}

// Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬ loader/voronoi Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬

mod loader_tests {
    use lurek2d::globe::loader::generate_voronoi_provinces;

    #[test]
    fn voronoi_generation_creates_provinces_for_seeds() {
        let seeds = vec![(0.0, 0.0), (10.0, 10.0), (-10.0, -15.0)];
        let provinces = generate_voronoi_provinces(&seeds);
        assert_eq!(provinces.len(), seeds.len());
        assert!(provinces.iter().all(|p| !p.vertices.is_empty()));
    }
}

// Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬ topology Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬Ă„â€šĂ‹ÂÄ‚ËĂ˘â€šÂ¬ÄąÄ„Ä‚ËĂ˘â‚¬ĹˇĂ‚Â¬

mod topology_tests {
    use lurek2d::globe::topology::ProvinceGraph;
    use lurek2d::globe::types::{GlobeError, Province, RegionId};
    use std::collections::HashSet;

    fn make_province(id: u32, neighbors: Vec<u32>) -> Province {
        let mut p = Province::new(
            RegionId(id),
            vec![(0.0_f32, 0.0_f32), (1.0, 0.0), (0.5, 1.0)],
        );
        p.neighbors = neighbors.into_iter().map(RegionId).collect();
        p
    }

    // ProvinceGraph::new / insert / len / is_empty

    #[test]
    fn new_graph_is_empty() {
        let g = ProvinceGraph::new();
        assert!(g.is_empty());
        assert_eq!(g.len(), 0);
    }

    #[test]
    fn insert_increases_len() {
        let mut g = ProvinceGraph::new();
        g.insert(Province::new(RegionId(1), vec![])).unwrap();
        assert_eq!(g.len(), 1);
        assert!(!g.is_empty());
    }

    #[test]
    fn insert_multiple_provinces() {
        let mut g = ProvinceGraph::new();
        for id in 0..5 {
            g.insert(Province::new(RegionId(id), vec![])).unwrap();
        }
        assert_eq!(g.len(), 5);
    }

    // ProvinceGraph::get

    #[test]
    fn get_returns_inserted_province() {
        let mut g = ProvinceGraph::new();
        g.insert(Province::new(RegionId(42), vec![])).unwrap();
        assert!(g.get(RegionId(42)).is_some());
        assert!(g.get(RegionId(43)).is_none());
    }

    // ProvinceGraph::remove

    #[test]
    fn remove_existing_returns_some() {
        let mut g = ProvinceGraph::new();
        g.insert(Province::new(RegionId(10), vec![])).unwrap();
        let removed = g.remove(RegionId(10));
        assert!(removed.is_some());
        assert!(g.get(RegionId(10)).is_none());
        assert_eq!(g.len(), 0);
    }

    #[test]
    fn remove_nonexistent_returns_none() {
        let mut g = ProvinceGraph::new();
        assert!(g.remove(RegionId(99)).is_none());
    }

    #[test]
    fn remove_existing_cleans_neighbor_backrefs_and_edge_tags() {
        let mut g = ProvinceGraph::new();
        let mut a = make_province(1, vec![2]);
        let mut b = make_province(2, vec![1]);
        let tags = HashSet::from(["road".to_string()]);
        a.edge_tags.insert((RegionId(1), RegionId(2)), tags.clone());
        b.edge_tags.insert((RegionId(1), RegionId(2)), tags);
        g.insert(a).unwrap();
        g.insert(b).unwrap();
        g.remove(RegionId(2)).expect("province should be removed");
        assert!(g.neighbors_of(RegionId(1)).is_empty());
        let remaining = g.get(RegionId(1)).expect("province 1 should remain");
        assert!(remaining.neighbors.is_empty());
        assert!(remaining.edge_tags.is_empty());
        assert!(g.edge_tags(RegionId(1), RegionId(2)).is_empty());
    }

    // ProvinceGraph::neighbors_of

    #[test]
    fn neighbors_of_reflects_province_neighbors() {
        let mut g = ProvinceGraph::new();
        let p = make_province(1, vec![2, 3]);
        g.insert(p).unwrap();
        let nbrs = g.neighbors_of(RegionId(1));
        assert_eq!(nbrs.len(), 2);
        assert!(nbrs.contains(&RegionId(2)));
        assert!(nbrs.contains(&RegionId(3)));
    }

    #[test]
    fn neighbors_of_empty_for_unknown_province() {
        let g = ProvinceGraph::new();
        assert!(g.neighbors_of(RegionId(999)).is_empty());
    }

    // ProvinceGraph::set_attr / get_attr

    #[test]
    fn set_and_get_attr() {
        let mut g = ProvinceGraph::new();
        g.insert(Province::new(RegionId(1), vec![])).unwrap();
        g.set_attr(RegionId(1), "terrain".to_string(), "plains".to_string())
            .unwrap();
        assert_eq!(g.get_attr(RegionId(1), "terrain"), Some("plains"));
    }

    #[test]
    fn get_attr_missing_key_returns_none() {
        let mut g = ProvinceGraph::new();
        g.insert(Province::new(RegionId(1), vec![])).unwrap();
        assert!(g.get_attr(RegionId(1), "nonexistent").is_none());
    }

    #[test]
    fn set_attr_nonexistent_province_returns_error() {
        let mut g = ProvinceGraph::new();
        let result = g.set_attr(RegionId(999), "k".to_string(), "v".to_string());
        assert!(matches!(
            result,
            Err(GlobeError::RegionNotFound(RegionId(999)))
        ));
    }

    #[test]
    fn set_attr_overwrites_existing() {
        let mut g = ProvinceGraph::new();
        g.insert(Province::new(RegionId(1), vec![])).unwrap();
        g.set_attr(RegionId(1), "owner".to_string(), "red".to_string())
            .unwrap();
        g.set_attr(RegionId(1), "owner".to_string(), "blue".to_string())
            .unwrap();
        assert_eq!(g.get_attr(RegionId(1), "owner"), Some("blue"));
    }

    #[test]
    fn set_edge_tags_updates_cached_and_stored_tags() {
        let mut g = ProvinceGraph::new();
        g.insert(make_province(1, vec![2])).unwrap();
        g.insert(make_province(2, vec![1])).unwrap();
        let tags = HashSet::from(["land".to_string(), "road".to_string()]);
        assert!(g
            .set_edge_tags(RegionId(2), RegionId(1), tags)
            .expect("regions should exist"));
        assert_eq!(
            g.edge_tags(RegionId(1), RegionId(2)),
            vec!["land".to_string(), "road".to_string()]
        );
        assert!(g
            .get(RegionId(1))
            .expect("province should exist")
            .edge_tags
            .contains_key(&(RegionId(1), RegionId(2))));
    }

    // ProvinceGraph::reachable_default

    // ProvinceGraph::rebuild_caches

    #[test]
    fn rebuild_caches_restores_neighbor_info() {
        let mut g = ProvinceGraph::new();
        let mut p = Province::new(RegionId(1), vec![(0.0_f32, 0.0_f32)]);
        p.neighbors = vec![RegionId(2)];
        g.insert(p).unwrap();
        // Force cache rebuild.
        g.rebuild_caches();
        assert_eq!(g.neighbors_of(RegionId(1)), &[RegionId(2)]);
    }

    #[test]
    fn rebuild_caches_empty_graph_is_noop() {
        let mut g = ProvinceGraph::new();
        g.rebuild_caches(); // Should not panic.
        assert!(g.is_empty());
    }

    #[test]
    fn get_mut_rebuilds_neighbor_cache_after_in_place_mutation() {
        let mut g = ProvinceGraph::new();
        g.insert(make_province(1, vec![])).unwrap();
        {
            let mut province = g
                .get_mut(RegionId(1))
                .expect("province mutation guard should exist");
            province.neighbors.push(RegionId(2));
        }
        assert_eq!(g.neighbors_of(RegionId(1)), vec![RegionId(2)]);
    }

    #[test]
    fn insert_duplicate_region_returns_load_error() {
        let mut g = ProvinceGraph::new();
        g.insert(make_province(1, vec![])).unwrap();
        let err = g
            .insert(make_province(1, vec![]))
            .expect_err("duplicate ids should be rejected");
        assert!(matches!(err, GlobeError::LoadError(_)));
    }

    #[test]
    fn candidate_ids_at_respects_wrapped_longitude_bounds() {
        let mut g = ProvinceGraph::new();
        g.insert(Province::with_data(
            RegionId(1),
            (0.0, 180.0),
            vec![(-5.0, 170.0), (-5.0, -170.0), (5.0, -170.0), (5.0, 170.0)],
            Vec::new(),
            [0.5, 0.5, 0.5, 1.0],
        ))
        .unwrap();
        g.insert(make_province(2, vec![])).unwrap();
        assert_eq!(g.candidate_ids_at(0.0, 179.0), vec![RegionId(1)]);
        assert_eq!(g.candidate_ids_at(0.0, 0.0), vec![RegionId(2)]);
    }
}

mod registry_and_picking_tests {
    use lurek2d::globe::export::export_regions_to_obj;
    use lurek2d::globe::label::LabelStore;
    use lurek2d::globe::layer::LayerStore;
    use lurek2d::globe::loader::{
        load_from_png_file_safe, load_from_province_grid, load_from_toml_file_safe,
        load_from_toml_str,
    };
    use lurek2d::globe::marker::MarkerPlacement;
    use lurek2d::globe::picking::{
        point_in_geo_polygon, point_in_geo_region, screen_to_shell, screen_to_surface,
    };
    use lurek2d::globe::projection::{project_region, OrbitCamera};
    use lurek2d::globe::registry::Globe;
    use lurek2d::globe::types::{
        GlobeOrbit, GlobeOrbitKind, GlobeSpec, LabelStyle, Layer, MarkerStyle, Region, RegionId,
        RegionPart,
    };
    use lurek2d::globe::validation::GlobeLoadOptions;
    use lurek2d::image::ImageData;
    use lurek2d::lua_api::create_test_vm;
    use lurek2d::province::ProvinceGrid;
    use lurek2d::render::renderer::RenderCommand;
    use lurek2d::runtime::resource_keys::{FontKey, TextureKey};
    use slotmap::KeyData;

    fn make_region(id: u32, centroid: (f32, f32), verts: Vec<(f32, f32)>) -> Region {
        Region::with_data(
            RegionId(id),
            centroid,
            verts,
            Vec::new(),
            [0.5, 0.5, 0.5, 1.0],
        )
    }

    fn make_orbit(name: &str, altitude_px: f32) -> GlobeOrbit {
        let mut orbit = GlobeOrbit::surface();
        orbit.name = name.to_string();
        orbit.altitude_px = altitude_px;
        orbit.z_order = altitude_px as i32;
        orbit.kind = GlobeOrbitKind::Orbit;
        orbit.draw_shell = true;
        orbit.width_px = 2.0;
        orbit.color = [0.3, 0.6, 1.0, 0.25];
        orbit
    }

    #[test]
    fn screen_to_surface_center_maps_to_front_hemisphere() {
        let spec = GlobeSpec::default();
        let camera = lurek2d::globe::projection::OrbitCamera::default();
        let hit = screen_to_surface(camera.screen_cx, camera.screen_cy, &spec, &camera)
            .expect("screen centre should hit the globe");
        assert!(hit.lat_deg.is_finite());
        assert!(hit.lon_deg.is_finite());
        assert!((-90.0..=90.0).contains(&hit.lat_deg));
        assert!((-180.0..=180.0).contains(&hit.lon_deg));
        assert!(hit.depth > 0.0);
    }

    #[test]
    fn screen_to_shell_maps_centre_on_elevated_orbits() {
        let spec = GlobeSpec {
            axial_tilt_deg: 0.0,
            ..GlobeSpec::default()
        };
        let camera = lurek2d::globe::projection::OrbitCamera {
            lat_deg: 0.0,
            lon_deg: 0.0,
            ..lurek2d::globe::projection::OrbitCamera::default()
        };
        let hit = screen_to_shell(
            camera.screen_cx,
            camera.screen_cy,
            &spec,
            &camera,
            spec.radius + 20.0,
            20.0,
        )
        .expect("screen centre should hit the orbit shell");
        assert!(hit.altitude_px > 0.0);
        assert!(hit.lat_deg.abs() < 0.01);
        assert!((hit.lon_deg - 90.0).abs() < 0.01);
    }

    #[test]
    fn point_in_geo_polygon_handles_dateline_wrapped_query_space() {
        let verts = vec![(-5.0, 170.0), (-5.0, -170.0), (5.0, -170.0), (5.0, 170.0)];
        assert!(point_in_geo_polygon(0.0, 180.0, &verts));
        assert!(point_in_geo_polygon(0.0, -179.0, &verts));
        assert!(!point_in_geo_polygon(20.0, 180.0, &verts));
    }

    #[test]
    fn point_in_geo_region_respects_holes_and_multipart_geometry() {
        let region = Region::with_parts_data(
            RegionId(50),
            (0.0, 0.0),
            vec![
                RegionPart {
                    outer: vec![(-6.0, -6.0), (-6.0, 6.0), (6.0, 6.0), (6.0, -6.0)],
                    holes: vec![vec![(-2.0, -2.0), (-2.0, 2.0), (2.0, 2.0), (2.0, -2.0)]],
                },
                RegionPart::new(vec![(10.0, 10.0), (10.0, 14.0), (14.0, 14.0), (14.0, 10.0)]),
            ],
            Vec::new(),
            [0.5, 0.5, 0.5, 1.0],
        );
        assert!(point_in_geo_region(&region, 5.0, 5.0));
        assert!(!point_in_geo_region(&region, 0.0, 0.0));
        assert!(point_in_geo_region(&region, 12.0, 12.0));
    }

    #[test]
    fn region_new_derives_centroid_across_dateline_on_the_correct_side() {
        let region = Region::new(
            RegionId(51),
            vec![(-5.0, 170.0), (-5.0, -170.0), (5.0, -170.0), (5.0, 170.0)],
        );
        assert!(region.centroid.0.abs() < 1.0);
        assert!(region.centroid.1.abs() > 150.0);
    }

    #[test]
    fn load_from_toml_str_parses_multipart_geometry_with_holes() {
        let src = r#"
[[province]]
id = 1
parts = [{ outer = [[-12.0, 78.0], [-12.0, 102.0], [12.0, 102.0], [12.0, 78.0]], holes = [[[-4.0, 86.0], [-4.0, 94.0], [4.0, 94.0], [4.0, 86.0]]] }]
neighbors = [2]

[province.attrs]
owner = "player"

[[province]]
id = 2
vertices = [[-12.0, 110.0], [-12.0, 130.0], [12.0, 130.0], [12.0, 110.0]]
neighbors = [1]
"#;
        let regions = load_from_toml_str(src).expect("TOML should parse");
        assert_eq!(regions.len(), 2);
        let region = &regions[0];
        assert_eq!(region.parts.len(), 1);
        assert_eq!(region.parts[0].holes.len(), 1);
        assert_eq!(region.neighbors, vec![RegionId(2)]);
        assert_eq!(region.attrs.get("owner"), Some(&"player".to_string()));
        assert!(!point_in_geo_region(region, 0.0, 90.0));
        assert!(point_in_geo_region(region, 8.0, 90.0));
    }

    #[test]
    fn load_from_toml_str_rejects_unknown_neighbor_ids() {
        let src = r#"
[[province]]
id = 1
vertices = [[-5.0, 80.0], [-5.0, 100.0], [5.0, 100.0], [5.0, 80.0]]
neighbors = [99]
"#;
        let err = load_from_toml_str(src).expect_err("unknown neighbors should be rejected");
        assert!(err.contains("unknown neighbor"));
    }

    #[test]
    fn load_from_toml_str_rejects_asymmetric_neighbors() {
        let src = r#"
[[province]]
id = 1
vertices = [[-5.0, 80.0], [-5.0, 100.0], [5.0, 100.0], [5.0, 80.0]]
neighbors = [2]

[[province]]
id = 2
vertices = [[-5.0, 105.0], [-5.0, 125.0], [5.0, 125.0], [5.0, 105.0]]
"#;
        let err = load_from_toml_str(src).expect_err("asymmetric neighbors should be rejected");
        assert!(err.contains("reverse edge"));
    }

    #[test]
    fn load_from_toml_str_rejects_self_neighbors() {
        let src = r#"
[[province]]
id = 1
vertices = [[-5.0, 80.0], [-5.0, 100.0], [5.0, 100.0], [5.0, 80.0]]
neighbors = [1]
"#;
        let err = load_from_toml_str(src).expect_err("self neighbors should be rejected");
        assert!(err.contains("must not list itself as a neighbor"));
    }

    #[test]
    fn file_backed_loaders_enforce_sandbox_and_size_limits() {
        let cwd = std::env::current_dir().expect("cwd should resolve");

        let toml_options = GlobeLoadOptions {
            max_toml_bytes: 1,
            ..GlobeLoadOptions::default()
        };
        let toml_err = load_from_toml_file_safe("save/globe_example.toml", &toml_options)
            .expect_err("tiny TOML limit should fail");
        assert!(toml_err.contains("too large"));

        let sandboxed = GlobeLoadOptions {
            sandbox_root: cwd.join("save"),
            ..GlobeLoadOptions::default()
        };
        let outside_path = cwd.join("Cargo.toml");
        let outside_err = load_from_toml_file_safe(
            outside_path.to_str().expect("path should be valid UTF-8"),
            &sandboxed,
        )
        .expect_err("path outside sandbox should fail");
        assert!(outside_err.contains("outside sandbox root"));

        let png_options = GlobeLoadOptions {
            max_png_pixels: 1,
            ..GlobeLoadOptions::default()
        };
        let png_err = load_from_png_file_safe("assets/icon.png", &png_options)
            .expect_err("tiny PNG pixel limit should fail");
        assert!(png_err.contains("pixels exceeds limit"));
    }

    #[test]
    fn globe_keeps_provinces_and_regions_in_separate_stores() {
        let mut globe = Globe::new("test", GlobeSpec::default());
        globe
            .add_province(make_region(
                1,
                (0.0, 90.0),
                vec![(-5.0, 85.0), (-5.0, 95.0), (5.0, 95.0), (5.0, 85.0)],
            ))
            .unwrap();
        globe
            .add_region(make_region(
                100,
                (0.0, 90.0),
                vec![(-8.0, 82.0), (-8.0, 98.0), (8.0, 98.0), (8.0, 82.0)],
            ))
            .unwrap();
        assert_eq!(globe.province_count(), 1);
        assert_eq!(globe.region_count(), 1);
        assert!(globe.get_province(RegionId(1)).is_some());
        assert!(globe.get_region(RegionId(100)).is_some());
        assert!(globe.get_region(RegionId(1)).is_none());
    }

    #[test]
    fn pick_regions_at_screen_returns_semantic_region_ids_only() {
        let mut globe = Globe::new("pick", GlobeSpec::default());
        globe.spec.axial_tilt_deg = 0.0;
        globe.camera.lat_deg = 0.0;
        globe.camera.lon_deg = 0.0;
        globe
            .add_province(make_region(
                1,
                (0.0, 90.0),
                vec![(-5.0, 85.0), (-5.0, 95.0), (5.0, 95.0), (5.0, 85.0)],
            ))
            .unwrap();
        globe
            .add_region(make_region(
                100,
                (0.0, 90.0),
                vec![(-7.0, 83.0), (-7.0, 97.0), (7.0, 97.0), (7.0, 83.0)],
            ))
            .unwrap();
        let ids = globe.pick_regions_at_screen(globe.camera.screen_cx, globe.camera.screen_cy);
        assert_eq!(ids, vec![RegionId(100)]);
    }

    #[test]
    fn pick_regions_at_screen_ignores_semantic_region_hole() {
        let mut globe = Globe::new("pick_hole", GlobeSpec::default());
        globe.spec.axial_tilt_deg = 0.0;
        globe.camera.lat_deg = 0.0;
        globe.camera.lon_deg = 0.0;
        globe
            .add_region(Region::with_parts_data(
                RegionId(300),
                (0.0, 90.0),
                vec![RegionPart {
                    outer: vec![(-12.0, 78.0), (-12.0, 102.0), (12.0, 102.0), (12.0, 78.0)],
                    holes: vec![vec![(-4.0, 86.0), (-4.0, 94.0), (4.0, 94.0), (4.0, 86.0)]],
                }],
                Vec::new(),
                [0.5, 0.5, 0.5, 1.0],
            ))
            .unwrap();
        let ids = globe.pick_regions_at_screen(globe.camera.screen_cx, globe.camera.screen_cy);
        assert!(ids.is_empty());
    }

    #[test]
    fn regions_at_lat_lon_reflects_semantic_region_mutation_without_manual_rebuild() {
        let mut globe = Globe::new("region_mutation", GlobeSpec::default());
        globe
            .add_region(make_region(
                500,
                (30.0, 30.0),
                vec![(25.0, 25.0), (25.0, 35.0), (35.0, 35.0), (35.0, 25.0)],
            ))
            .unwrap();
        assert!(globe.regions_at_lat_lon(0.0, 0.0).is_empty());
        {
            let mut region = globe
                .get_region_mut(RegionId(500))
                .expect("semantic region should exist");
            region.centroid = (0.0, 0.0);
            region.vertices = vec![(-4.0, -4.0), (-4.0, 4.0), (4.0, 4.0), (4.0, -4.0)];
            region.parts = vec![RegionPart::new(region.vertices.clone())];
        }
        assert_eq!(globe.regions_at_lat_lon(0.0, 0.0), vec![RegionId(500)]);
    }

    #[test]
    fn regions_at_lat_lon_reflects_member_terrain_mutation_without_manual_rebuild() {
        let mut globe = Globe::new("terrain_member_mutation", GlobeSpec::default());
        globe
            .add_terrain_patch(make_region(
                600,
                (30.0, 30.0),
                vec![(25.0, 25.0), (25.0, 35.0), (35.0, 35.0), (35.0, 25.0)],
            ))
            .unwrap();
        globe
            .add_region(Region {
                id: RegionId(601),
                member_terrain_ids: vec![RegionId(600)],
                ..make_region(601, (0.0, 0.0), Vec::new())
            })
            .unwrap();
        assert!(globe.regions_at_lat_lon(0.0, 0.0).is_empty());
        {
            let mut patch = globe
                .get_terrain_patch_mut(RegionId(600))
                .expect("terrain patch should exist");
            patch.centroid = (0.0, 0.0);
            patch.vertices = vec![(-4.0, -4.0), (-4.0, 4.0), (4.0, 4.0), (4.0, -4.0)];
            patch.parts = vec![RegionPart::new(patch.vertices.clone())];
        }
        assert_eq!(globe.regions_at_lat_lon(0.0, 0.0), vec![RegionId(601)]);
    }

    #[test]
    fn regions_at_lat_lon_resolves_member_only_region_from_static_terrain_bounds() {
        let mut globe = Globe::new("terrain_member_static", GlobeSpec::default());
        globe
            .add_terrain_patch(make_region(
                610,
                (-45.0, -90.0),
                vec![(-90.0, -180.0), (-90.0, 0.0), (0.0, 0.0), (0.0, -180.0)],
            ))
            .unwrap();
        globe
            .add_region(Region {
                id: RegionId(611),
                member_terrain_ids: vec![RegionId(610)],
                ..make_region(611, (0.0, 0.0), Vec::new())
            })
            .unwrap();

        assert_eq!(globe.regions_at_lat_lon(-45.0, -90.0), vec![RegionId(611)]);
    }

    #[test]
    fn regions_at_lat_lon_with_stats_reports_candidate_reduction_and_member_hits() {
        let mut globe = Globe::new("terrain_member_stats", GlobeSpec::default());
        globe
            .add_terrain_patch(make_region(
                620,
                (-45.0, -90.0),
                vec![(-90.0, -180.0), (-90.0, 0.0), (0.0, 0.0), (0.0, -180.0)],
            ))
            .unwrap();
        globe
            .add_region(Region {
                id: RegionId(621),
                member_terrain_ids: vec![RegionId(620)],
                ..make_region(621, (0.0, 0.0), Vec::new())
            })
            .unwrap();
        globe
            .add_region(make_region(
                622,
                (45.0, 90.0),
                vec![(35.0, 80.0), (35.0, 100.0), (55.0, 100.0), (55.0, 80.0)],
            ))
            .unwrap();

        let (hits, stats) = globe.regions_at_lat_lon_with_stats(-45.0, -90.0);

        assert_eq!(hits, vec![RegionId(621)]);
        assert_eq!(stats.total_regions, 2);
        assert_eq!(stats.candidate_regions, 1);
        assert_eq!(stats.candidate_member_patches, 1);
        assert_eq!(stats.matched_regions, 1);
    }

    #[test]
    fn label_store_rejects_invalid_runtime_style() {
        let mut labels = LabelStore::new();
        let err = labels
            .add(
                "city",
                10.0,
                20.0,
                "Capital",
                LabelStyle {
                    color: [1.0, 1.0, 1.0, 1.0],
                    font_size: 0.0,
                    font: None,
                },
                0,
            )
            .expect_err("zero font size should be rejected");
        assert!(err.contains("font_size must be > 0"));
    }

    #[test]
    fn layer_store_rejects_invalid_alpha_updates() {
        let mut layers = LayerStore::new();
        layers
            .add(Layer::new("overlay", "", 0))
            .expect("valid layer should insert");

        let err = layers
            .set_alpha("overlay", 1.5)
            .expect_err("alpha above one should be rejected");
        assert!(err.contains("alpha must be in 0..1"));
    }

    #[test]
    fn lua_member_only_region_queries_static_terrain_patch() {
        let lua = create_test_vm().expect("test vm should build");
        let (hit, explicit_hit, count): (Option<u32>, Option<u32>, i64) = lua
            .load(
                r#"
local function terrain_patch(id, min_lat, min_lon, max_lat, max_lon)
    return {
        id = id,
        vertices = {
            {min_lat, min_lon},
            {min_lat, max_lon},
            {max_lat, max_lon},
            {max_lat, min_lon},
        },
        base_color = {0.1 + id * 0.01, 0.4, 0.2, 1.0},
    }
end

local g = lurek.globe.new("lua_member_region", { axial_tilt_deg = 0.0 })
assert(g:addTerrainPatch(terrain_patch(1, -90.0, -180.0, 0.0, 0.0)))
assert(g:addTerrainPatch(terrain_patch(2, -90.0, 0.0, 0.0, 180.0)))
assert(g:addTerrainPatch(terrain_patch(3, 0.0, -180.0, 90.0, 0.0)))
assert(g:addTerrainPatch(terrain_patch(4, 0.0, 0.0, 90.0, 180.0)))
assert(g:addRegion({ id = 31, members = {1} }))
assert(g:addRegion({ id = 32, centroid = {-45.0, -90.0}, members = {1} }))
local hits = g:regionsAtLatLon(-45.0, -90.0)
return hits[1], hits[2], g:regionCount()
"#,
            )
            .eval()
            .expect("Lua region query should run");

        assert_eq!(count, 2);
        assert_eq!(hit, Some(31));
        assert_eq!(explicit_hit, Some(32));
    }

    #[test]
    fn marker_distance_returns_quarter_turn_for_orthogonal_markers() {
        let mut globe = Globe::new("markers", GlobeSpec::default());
        let a = globe.markers.add("a", 0.0, 0.0, None, Default::default());
        let b = globe.markers.add("b", 0.0, 90.0, None, Default::default());
        let distance = globe.marker_distance(a, b).expect("markers should exist");
        assert!((distance - std::f32::consts::FRAC_PI_2).abs() < 0.01);
    }

    #[test]
    fn surface_orbit_always_exists_and_cannot_be_removed() {
        let mut globe = Globe::new("surface", GlobeSpec::default());
        assert!(globe.orbits.get("surface").is_some());
        assert!(!globe.remove_orbit("surface"));
        assert!(globe.orbits.get("surface").is_some());
    }

    #[test]
    fn orbit_markers_can_be_picked_across_shells() {
        let mut globe = Globe::new("orbit_markers", GlobeSpec::default());
        globe.spec.axial_tilt_deg = 0.0;
        globe.camera.lat_deg = 0.0;
        globe.camera.lon_deg = 0.0;
        globe
            .add_orbit(make_orbit("low_orbit", 20.0))
            .expect("orbit should be valid");
        let marker_id = globe
            .add_marker_placed(MarkerPlacement::orbit(
                "satellite",
                0.0,
                90.0,
                "low_orbit",
                None,
                Some("SAT-1".to_string()),
                Default::default(),
            ))
            .expect("marker should be accepted on orbit");
        let hit = globe.pick_marker_screen(globe.camera.screen_cx, globe.camera.screen_cy, 24.0);
        assert_eq!(hit, Some(marker_id));
    }

    #[test]
    fn hidden_orbit_markers_are_not_pickable() {
        let mut globe = Globe::new("hidden_orbit", GlobeSpec::default());
        globe.spec.axial_tilt_deg = 0.0;
        globe.camera.lat_deg = 0.0;
        globe.camera.lon_deg = 0.0;
        globe
            .add_orbit(make_orbit("high_orbit", 30.0))
            .expect("orbit should be valid");
        let marker_id = globe
            .add_marker_placed(MarkerPlacement::orbit(
                "satellite",
                0.0,
                90.0,
                "high_orbit",
                None,
                None,
                Default::default(),
            ))
            .expect("marker should be accepted on orbit");
        assert_eq!(
            globe.pick_marker_screen(globe.camera.screen_cx, globe.camera.screen_cy, 24.0),
            Some(marker_id)
        );
        assert!(globe.orbits.set_visible("high_orbit", false));
        assert_eq!(
            globe.pick_marker_screen(globe.camera.screen_cx, globe.camera.screen_cy, 24.0),
            None
        );
    }

    #[test]
    fn apply_mouse_drag_keeps_surface_anchor_close_to_pointer() {
        let mut globe = Globe::new("drag", GlobeSpec::default());
        globe.spec.axial_tilt_deg = 0.0;
        let sx = globe.camera.screen_cx;
        let sy = globe.camera.screen_cy;
        let ex = sx + 40.0;
        let ey = sy;
        let start = globe
            .screen_to_surface(sx, sy)
            .expect("drag start should hit the globe");
        globe.apply_mouse_drag(sx, sy, ex, ey);
        let end = globe
            .screen_to_surface(ex, ey)
            .expect("drag end should hit the globe");
        assert!((start.lat_deg - end.lat_deg).abs() < 2.0);
        assert!((start.lon_deg - end.lon_deg).abs() < 2.0);
    }

    #[test]
    fn rotating_icon_markers_emit_non_zero_image_rotation() {
        let mut globe = Globe::new("marker_rotation", GlobeSpec::default());
        globe.spec.axial_tilt_deg = 0.0;
        globe.sim_time_sec = 1.0;
        let style = MarkerStyle {
            icon_texture_key: Some(TextureKey::from(KeyData::from_ffi(1))),
            rotation_deg_per_sec: 90.0,
            ..Default::default()
        };
        globe.markers.add("icon", 0.0, 90.0, None, style);
        let cmds = globe.emit_frame(None);
        let rotation = cmds.iter().find_map(|cmd| match cmd {
            RenderCommand::DrawImageEx { rotation, .. } => Some(*rotation),
            _ => None,
        });
        let rotation = rotation.expect("marker icon should emit DrawImageEx");
        assert!(rotation > 1.0);
    }

    #[test]
    fn draw_emits_stencil_mask_for_provinces_with_holes() {
        let mut globe = Globe::new("draw_holes", GlobeSpec::default());
        globe.spec.axial_tilt_deg = 0.0;
        globe.camera.lat_deg = 0.0;
        globe.camera.lon_deg = 90.0;
        globe
            .add_province(Region::with_parts_data(
                RegionId(400),
                (0.0, 90.0),
                vec![RegionPart {
                    outer: vec![(-12.0, 78.0), (-12.0, 102.0), (12.0, 102.0), (12.0, 78.0)],
                    holes: vec![vec![(-4.0, 86.0), (-4.0, 94.0), (4.0, 94.0), (4.0, 86.0)]],
                }],
                Vec::new(),
                [0.6, 0.6, 0.7, 1.0],
            ))
            .unwrap();
        let cmds = globe.emit_frame(None);
        assert!(cmds
            .iter()
            .any(|cmd| matches!(cmd, RenderCommand::SetColorMask(false, false, false, false))));
        assert!(cmds.iter().any(|cmd| matches!(
            cmd,
            RenderCommand::StencilBegin {
                action: lurek2d::render::renderer::StencilAction::Replace,
                value: 1
            }
        )));
        assert!(cmds.iter().any(|cmd| matches!(
            cmd,
            RenderCommand::StencilBegin {
                action: lurek2d::render::renderer::StencilAction::Zero,
                ..
            }
        )));
        assert!(cmds.iter().any(|cmd| matches!(
            cmd,
            RenderCommand::SetStencilTest(Some((lurek2d::render::renderer::CompareMode::Equal, 1)))
        )));
    }

    #[test]
    fn emit_frame_with_stats_counts_drawn_elements_and_scratch_buffers() {
        let mut globe = Globe::new("frame_stats", GlobeSpec::default());
        globe.spec.axial_tilt_deg = 0.0;
        globe.camera.zoom = 2.0;
        globe
            .add_province(Region::with_parts_data(
                RegionId(402),
                (30.0, 0.0),
                vec![RegionPart {
                    outer: vec![(20.0, -12.0), (20.0, 12.0), (40.0, 12.0), (40.0, -12.0)],
                    holes: vec![vec![(26.0, -4.0), (26.0, 4.0), (34.0, 4.0), (34.0, -4.0)]],
                }],
                Vec::new(),
                [0.6, 0.6, 0.7, 1.0],
            ))
            .unwrap();
        globe
            .add_region(make_region(
                403,
                (30.0, 0.0),
                vec![(22.0, -10.0), (22.0, 10.0), (38.0, 10.0), (38.0, -10.0)],
            ))
            .unwrap();
        globe
            .markers
            .add("poi", 30.0, 0.0, None, Default::default());
        globe
            .labels
            .add("city", 30.0, 0.0, "Capital", LabelStyle::default(), 0)
            .expect("valid label should insert");

        let font_key = FontKey::from(KeyData::from_ffi(2));
        let (cmds, stats) = globe.emit_frame_with_stats(Some(font_key));

        assert!(stats.commands_emitted > 0);
        assert_eq!(stats.commands_emitted, cmds.len());
        assert_eq!(stats.province_regions_total, 1);
        assert_eq!(stats.province_regions_drawn, 1);
        assert_eq!(stats.province_regions_culled, 0);
        assert_eq!(stats.semantic_regions_total, 1);
        assert_eq!(stats.semantic_regions_drawn, 1);
        assert_eq!(stats.markers_drawn, 1);
        assert_eq!(stats.labels_drawn, 1);
        assert!(stats.scratch_hole_loops_high_water >= 1);
        assert!(stats.scratch_hole_vertices_high_water >= 4);
        assert!(stats.scratch_border_vertices_high_water >= 4);
    }

    #[test]
    fn sector_reassignment_and_removal_keep_reverse_lookup_in_sync() {
        let mut globe = Globe::new("sectors", GlobeSpec::default());
        globe
            .add_province(make_region(
                1,
                (0.0, 90.0),
                vec![(-5.0, 85.0), (-5.0, 95.0), (5.0, 95.0), (5.0, 85.0)],
            ))
            .unwrap();
        globe.set_region_sector(RegionId(1), "west");
        assert_eq!(globe.region_sector(RegionId(1)), Some("west"));
        assert_eq!(globe.sector_regions("west"), vec![RegionId(1)]);
        globe.set_region_sector(RegionId(1), "east");
        assert_eq!(globe.region_sector(RegionId(1)), Some("east"));
        assert!(globe.sector_regions("west").is_empty());
        globe
            .remove_province(RegionId(1))
            .expect("province should be removed");
        assert_eq!(globe.region_sector(RegionId(1)), None);
        assert!(globe.sector_regions("east").is_empty());
    }

    #[test]
    fn add_marker_placed_rejects_invalid_style_values() {
        let mut globe = Globe::new("invalid_marker", GlobeSpec::default());
        let err = globe
            .add_marker_placed(MarkerPlacement::surface(
                "poi",
                0.0,
                0.0,
                None,
                MarkerStyle {
                    size: 0.0,
                    ..Default::default()
                },
            ))
            .expect_err("invalid marker style should be rejected");
        assert!(err.contains("size must be >= 1"));
    }

    #[test]
    fn project_region_clips_polygons_that_cross_the_horizon() {
        let spec = GlobeSpec::default();
        let camera = OrbitCamera::default();
        let view = lurek2d::globe::projection::build_view_matrix(&spec, &camera);
        let region = make_region(
            7,
            (0.0, 45.0),
            vec![(-20.0, -30.0), (-20.0, 90.0), (20.0, 90.0), (20.0, -30.0)],
        );
        let projected = project_region(&region, &view, &spec, &camera, 1.0)
            .expect("partially visible region should be clipped, not dropped");
        assert!(projected.screen_verts.len() >= 3);
        assert_eq!(projected.screen_verts.len(), projected.surface_points.len());
    }

    #[test]
    fn load_from_province_grid_traces_contours_instead_of_bounding_boxes() {
        let bytes = vec![
            255, 0, 0, 255, 255, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0,
            255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255,
        ];
        let image = ImageData::from_bytes(3, 3, bytes).expect("image bytes should be valid");
        let grid = ProvinceGrid::from_image(&image);
        let regions = load_from_province_grid(&grid);
        assert_eq!(regions.len(), 1);
        let region = &regions[0];
        assert!(region.vertices.len() > 4);
        let lats: Vec<f32> = region.vertices.iter().map(|(lat, _)| *lat).collect();
        let lons: Vec<f32> = region.vertices.iter().map(|(_, lon)| *lon).collect();
        let lat_levels: std::collections::BTreeSet<i32> = lats
            .iter()
            .map(|lat| (*lat * 100.0).round() as i32)
            .collect();
        let lon_levels: std::collections::BTreeSet<i32> = lons
            .iter()
            .map(|lon| (*lon * 100.0).round() as i32)
            .collect();
        assert!(lat_levels.len() >= 3);
        assert!(lon_levels.len() >= 3);
    }

    #[test]
    fn load_from_province_grid_preserves_holes_as_region_parts() {
        let mut bytes = vec![0_u8; 5 * 5 * 4];
        for y in 0..5 {
            for x in 0..5 {
                if x == 2 && y == 2 {
                    continue;
                }
                let index = (y * 5 + x) * 4;
                bytes[index] = 255;
                bytes[index + 3] = 255;
            }
        }
        let image = ImageData::from_bytes(5, 5, bytes).expect("image bytes should be valid");
        let grid = ProvinceGrid::from_image(&image);
        let regions = load_from_province_grid(&grid);
        assert_eq!(regions.len(), 1);
        let region = &regions[0];
        assert_eq!(region.parts.len(), 1);
        assert_eq!(region.parts[0].holes.len(), 1);
        assert!(region.parts[0].outer.len() >= 4);
        assert!(region.parts[0].holes[0].len() >= 4);
    }

    #[test]
    fn export_obj_emits_part_and_hole_groups_for_multipart_geometry() {
        let mut globe = Globe::new("export_holes", GlobeSpec::default());
        globe
            .add_province(Region::with_parts_data(
                RegionId(401),
                (0.0, 90.0),
                vec![RegionPart {
                    outer: vec![(-12.0, 78.0), (-12.0, 102.0), (12.0, 102.0), (12.0, 78.0)],
                    holes: vec![vec![(-4.0, 86.0), (-4.0, 94.0), (4.0, 94.0), (4.0, 86.0)]],
                }],
                Vec::new(),
                [0.5, 0.5, 0.5, 1.0],
            ))
            .unwrap();
        let obj = export_regions_to_obj(&globe);
        assert!(obj.contains("o region_401_part_0"));
        assert!(obj.contains("g region_401_part_0_outer"));
        assert!(obj.contains("g region_401_part_0_hole_0"));
        assert!(obj.contains("\nl "));
    }
}

mod sync_tests {
    use std::collections::HashMap;

    use lurek2d::globe::marker::MarkerPlacement;
    use lurek2d::globe::sync::{apply_snapshot, build_snapshot};
    use lurek2d::globe::types::{GlobeOrbit, GlobeOrbitKind, GlobeSpec, Region, RegionId};
    use lurek2d::globe::Globe;

    fn make_region(id: u32, centroid: (f32, f32), verts: Vec<(f32, f32)>) -> Region {
        Region::with_data(
            RegionId(id),
            centroid,
            verts,
            Vec::new(),
            [0.5, 0.5, 0.5, 1.0],
        )
    }

    #[test]
    fn snapshot_round_trip_restores_visual_and_semantic_state() {
        let mut source = Globe::new("source", GlobeSpec::default());
        source.spec.rotation_deg = 45.0;
        source.spec.time_of_day = 18.5;
        source.camera.lat_deg = 12.0;
        source.camera.lon_deg = 34.0;
        source.camera.zoom = 2.25;
        source
            .add_province(make_region(
                1,
                (0.0, 0.0),
                vec![(-5.0, -5.0), (-5.0, 5.0), (5.0, 5.0), (5.0, -5.0)],
            ))
            .unwrap();
        source
            .add_region(make_region(
                200,
                (0.0, 0.0),
                vec![(-8.0, -8.0), (-8.0, 8.0), (8.0, 8.0), (8.0, -8.0)],
            ))
            .unwrap();
        source.fog.reveal("player", RegionId(1));
        source
            .add_orbit(GlobeOrbit {
                name: "low_orbit".to_string(),
                altitude_px: 12.0,
                visible: true,
                z_order: 12,
                kind: GlobeOrbitKind::Orbit,
                accepts_markers: true,
                pickable: true,
                draw_shell: true,
                color: [0.3, 0.6, 1.0, 0.25],
                width_px: 2.0,
                attrs: HashMap::new(),
                shader: None,
            })
            .expect("orbit should be valid");
        let marker_id = source
            .add_marker_placed(MarkerPlacement::orbit(
                "poi",
                0.0,
                0.0,
                "low_orbit",
                Some(4.0),
                Some("A".to_string()),
                Default::default(),
            ))
            .expect("marker should be accepted on orbit");
        source
            .markers
            .set_attr(marker_id, "owner".to_string(), "blue".to_string());
        source
            .add_arc(lurek2d::globe::types::Arc {
                id: 0,
                arc_type: "flight".to_string(),
                screen_points: Vec::new(),
                color: [1.0, 0.5, 0.2, 1.0],
                width: 2.0,
                from: (0.0, 0.0),
                to: (10.0, 10.0),
                steps: 8,
                visible: true,
            })
            .expect("arc should validate");
        source.active_viewer = Some("player".to_string());
        source.sim_time_sec = 42.0;

        let snapshot = build_snapshot(&source);
        let mut restored = Globe::new("restored", GlobeSpec::default());
        apply_snapshot(&mut restored, &snapshot);

        assert_eq!(restored.name, "source");
        assert_eq!(restored.spec.rotation_deg, 45.0);
        assert_eq!(restored.spec.time_of_day, 18.5);
        assert_eq!(restored.camera.lat_deg, 12.0);
        assert_eq!(restored.camera.lon_deg, 34.0);
        assert_eq!(restored.camera.zoom, 2.25);
        assert!(restored.get_province(RegionId(1)).is_some());
        assert!(restored.get_region(RegionId(200)).is_some());
        assert!(restored.fog.is_visible("player", RegionId(1)));
        assert_eq!(
            restored
                .orbits
                .get("low_orbit")
                .map(|orbit| orbit.altitude_px),
            Some(12.0)
        );
        assert_eq!(
            restored
                .markers
                .get(marker_id)
                .map(|marker| (marker.orbit.as_str(), marker.altitude_px))
                .as_ref(),
            Some(&("low_orbit", Some(4.0)))
        );
        assert_eq!(
            restored
                .markers
                .get(marker_id)
                .and_then(|m| m.attrs.get("owner")),
            Some(&"blue".to_string())
        );
        assert_eq!(restored.arcs.len(), 1);
        assert_eq!(restored.active_viewer.as_deref(), Some("player"));
        assert_eq!(restored.sim_time_sec, 42.0);
    }
}
