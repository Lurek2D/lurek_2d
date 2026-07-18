//! Internal regression tests for scene stack lifecycle invariants.

use lurek2d::scene::{EasingType, SceneStack, TransitionType};

#[test]
fn scene_stack_reports_empty_pop_and_preserves_push_order() {
    let mut stack = SceneStack::new();
    assert!(stack
        .pop(TransitionType::None, 0.0, EasingType::Linear)
        .is_err());

    let first = stack.next_scene_id();
    let second = stack.next_scene_id();
    assert_eq!(
        stack.push(first, TransitionType::None, 0.0, EasingType::Linear),
        None
    );
    assert_eq!(
        stack.push(second, TransitionType::None, 0.0, EasingType::Linear),
        Some(first)
    );
    assert_eq!(
        stack.pop(TransitionType::None, 0.0, EasingType::Linear),
        Ok((second, Some(first)))
    );
}
