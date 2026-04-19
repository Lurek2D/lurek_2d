//! Rust unit tests for the `scene` module — private internals not reachable
//! from the `lurek.*` Lua API.
//!
//! Only tests that cannot be expressed via `lurek.*` live here:
//! - `EasingType::apply(t)` — pure curve math with no Lua namespace
//! - `EasingType::from_lua_str` / `TransitionType::from_lua_str` — enum-variant
//!   equality that is unobservable from Lua
//! - `ActiveTransition::get_easing()` — internal field access unavailable in Lua
//!
//! Tests observable via `lurek.scene.getTransitionProgress()` and
//! `lurek.scene.getTransitionProgressEased()` live in
//! `tests/lua/unit/test_scene.lua`.
//!
//! Naming: `<subject>_<scenario>_<expected>` — no `test_` prefix.

use lurek2d::scene::transition::{ActiveTransition, EasingType, TransitionType};

// ── EasingType ────────────────────────────────────────────────────────────────

#[test]
fn easing_linear_identity() {
    for i in 0..=10 {
        let t = i as f32 / 10.0;
        assert!((EasingType::Linear.apply(t) - t).abs() < 1e-5);
    }
}

#[test]
fn easing_ease_in_quadratic_at_half() {
    // EaseIn = t² → at t=0.5 ⇒ 0.25
    assert!((EasingType::EaseIn.apply(0.5) - 0.25).abs() < 1e-5);
}

#[test]
fn easing_ease_out_quadratic_at_half() {
    // EaseOut = 1-(1-t)² → at t=0.5 ⇒ 0.75
    assert!((EasingType::EaseOut.apply(0.5) - 0.75).abs() < 1e-5);
}

#[test]
fn easing_ease_in_out_symmetric_midpoint() {
    // Hermite S-curve is symmetric: f(0.5) = 0.5
    assert!((EasingType::EaseInOut.apply(0.5) - 0.5).abs() < 1e-5);
}

#[test]
fn easing_bounce_at_one_equals_one() {
    assert!((EasingType::Bounce.apply(1.0) - 1.0).abs() < 1e-4);
}

#[test]
fn easing_back_at_zero_equals_zero() {
    assert!((EasingType::Back.apply(0.0)).abs() < 1e-5);
}

#[test]
fn easing_back_at_one_equals_one() {
    assert!((EasingType::Back.apply(1.0) - 1.0).abs() < 1e-4);
}

#[test]
fn easing_all_start_at_zero_end_at_one() {
    let all = [
        EasingType::Linear,
        EasingType::EaseIn,
        EasingType::EaseOut,
        EasingType::EaseInOut,
        EasingType::Bounce,
    ];
    for e in &all {
        assert!(e.apply(0.0).abs() < 1e-4, "{e:?} at 0 is not 0");
        assert!((e.apply(1.0) - 1.0).abs() < 1e-4, "{e:?} at 1 is not 1");
    }
}

#[test]
fn easing_from_lua_str_roundtrip() {
    assert_eq!(EasingType::from_lua_str("linear"), EasingType::Linear);
    assert_eq!(EasingType::from_lua_str("ease_in"), EasingType::EaseIn);
    assert_eq!(EasingType::from_lua_str("ease_out"), EasingType::EaseOut);
    assert_eq!(EasingType::from_lua_str("ease_in_out"), EasingType::EaseInOut);
    assert_eq!(EasingType::from_lua_str("bounce"), EasingType::Bounce);
    assert_eq!(EasingType::from_lua_str("back"), EasingType::Back);
    assert_eq!(EasingType::from_lua_str("unknown"), EasingType::Linear);
}

// ── TransitionType ────────────────────────────────────────────────────────────

#[test]
fn transition_type_new_variants_parse() {
    assert_eq!(TransitionType::from_lua_str("wipe"), TransitionType::Wipe);
    assert_eq!(TransitionType::from_lua_str("iris"), TransitionType::Iris);
    assert_eq!(TransitionType::from_lua_str("zoom"), TransitionType::Zoom);
    assert_eq!(TransitionType::from_lua_str("crossfade"), TransitionType::CrossFade);
}

// ── ActiveTransition ──────────────────────────────────────────────────────────

#[test]
fn active_transition_new_defaults_linear() {
    let t = ActiveTransition::new(TransitionType::Fade, 1.0);
    assert_eq!(t.get_easing(), EasingType::Linear);
}

#[test]
fn active_transition_new_with_easing_stores_curve() {
    let t = ActiveTransition::new_with_easing(TransitionType::Wipe, 0.5, EasingType::EaseOut);
    assert_eq!(t.get_easing(), EasingType::EaseOut);
    assert_eq!(t.transition_type, TransitionType::Wipe);
}

// active_transition_progress_eased_linear_matches_progress,
// active_transition_progress_eased_ease_in_less_before_midpoint, and
// scene_stack_get_transition_progress_eased_linear_matches were migrated to
// tests/lua/unit/test_scene.lua — they are observable via
// lurek.scene.getTransitionProgress() and lurek.scene.getTransitionProgressEased().

// ── stack (migrated from src/scene/stack.rs) ──────────────────────────────────

mod stack_tests {
    use lurek2d::scene::stack::SceneStack;
    use lurek2d::scene::transition::{EasingType, TransitionType};

    // ── Initial state ─────────────────────────────────────────────────────────

    #[test]
    fn new_stack_is_empty() {
        let s = SceneStack::new();
        assert!(s.is_empty());
        assert_eq!(s.get_stack_size(), 0);
    }

    // ── Scene IDs ─────────────────────────────────────────────────────────────

    #[test]
    fn next_scene_id_increments() {
        let mut s = SceneStack::new();
        let id1 = s.next_scene_id();
        let id2 = s.next_scene_id();
        assert!(id2 > id1);
    }

    // ── Push / Pop ────────────────────────────────────────────────────────────

    #[test]
    fn push_increases_stack_size() {
        let mut s = SceneStack::new();
        let id = s.next_scene_id();
        s.push(id, TransitionType::None, 0.0, EasingType::Linear);
        assert_eq!(s.get_stack_size(), 1);
    }

    #[test]
    fn pop_returns_pushed_id() {
        let mut s = SceneStack::new();
        let id = s.next_scene_id();
        s.push(id, TransitionType::None, 0.0, EasingType::Linear);
        let (popped, _) = s.pop(TransitionType::None, 0.0, EasingType::Linear).unwrap();
        assert_eq!(popped, id);
    }

    #[test]
    fn pop_empty_stack_returns_err() {
        let mut s = SceneStack::new();
        assert!(s.pop(TransitionType::None, 0.0, EasingType::Linear).is_err());
    }

    // ── Overlay ───────────────────────────────────────────────────────────────

    #[test]
    fn push_overlay_marks_scene_as_overlay() {
        let mut s = SceneStack::new();
        let base = s.next_scene_id();
        let overlay = s.next_scene_id();
        s.push(base, TransitionType::None, 0.0, EasingType::Linear);
        s.push_overlay(overlay, TransitionType::None, 0.0, EasingType::Linear);
        assert!(s.is_overlay(overlay));
        assert!(!s.is_overlay(base));
    }

    #[test]
    fn push_overlay_does_not_change_base_overlay_flag() {
        let mut s = SceneStack::new();
        let base = s.next_scene_id();
        let overlay = s.next_scene_id();
        s.push(base, TransitionType::None, 0.0, EasingType::Linear);
        s.push_overlay(overlay, TransitionType::None, 0.0, EasingType::Linear);
        assert!(!s.is_overlay(base));
    }

    #[test]
    fn get_active_ids_returns_all_when_overlay_present() {
        let mut s = SceneStack::new();
        let base = s.next_scene_id();
        let overlay = s.next_scene_id();
        s.push(base, TransitionType::None, 0.0, EasingType::Linear);
        s.push_overlay(overlay, TransitionType::None, 0.0, EasingType::Linear);
        assert_eq!(s.get_active_ids().len(), 2);
    }

    #[test]
    fn get_active_ids_returns_only_top_when_no_overlay() {
        let mut s = SceneStack::new();
        let id1 = s.next_scene_id();
        let id2 = s.next_scene_id();
        s.push(id1, TransitionType::None, 0.0, EasingType::Linear);
        s.push(id2, TransitionType::None, 0.0, EasingType::Linear);
        let active = s.get_active_ids();
        assert_eq!(active.len(), 1);
        assert_eq!(active[0], id2);
    }

    #[test]
    fn pop_overlay_removes_overlay_flag() {
        let mut s = SceneStack::new();
        let base = s.next_scene_id();
        let overlay = s.next_scene_id();
        s.push(base, TransitionType::None, 0.0, EasingType::Linear);
        s.push_overlay(overlay, TransitionType::None, 0.0, EasingType::Linear);
        s.pop(TransitionType::None, 0.0, EasingType::Linear).unwrap();
        assert!(!s.is_overlay(overlay));
    }

    #[test]
    fn is_overlay_false_for_normal_push() {
        let mut s = SceneStack::new();
        let id = s.next_scene_id();
        s.push(id, TransitionType::None, 0.0, EasingType::Linear);
        assert!(!s.is_overlay(id));
    }

    // ── Registry ───────────────────────────────────────────────────────────────

    #[test]
    fn register_and_lookup_scene() {
        let mut s = SceneStack::new();
        let id = s.next_scene_id();
        s.register_scene("main_menu".to_string(), id);
        assert_eq!(s.get_registered("main_menu"), Some(id));
    }

    #[test]
    fn unregistered_name_returns_none() {
        let s = SceneStack::new();
        assert!(s.get_registered("missing").is_none());
    }
}

// ── render (migrated from src/scene/render.rs) ────────────────────────────────

mod render_tests {
    use lurek2d::scene::stack::SceneStack;

    #[test]
    fn generate_render_commands_always_empty() {
        let mut stack = SceneStack::new();
        let _ = stack.next_scene_id();
        let cmds = stack.generate_render_commands();
        assert!(
            cmds.is_empty(),
            "scene stack should return no render commands"
        );
    }

    #[test]
    fn draw_to_image_correct_dimensions() {
        let stack = SceneStack::new();
        let img = stack.draw_to_image(320, 240);
        assert_eq!(img.width(), 320);
        assert_eq!(img.height(), 240);
    }

    #[test]
    fn draw_to_image_returns_dark_background() {
        let stack = SceneStack::new();
        let img = stack.draw_to_image(16, 16);
        if let Some((r, _, _, _)) = img.get_pixel(0, 0) {
            assert!(r < 30, "expected dark background pixel");
        }
    }
}
