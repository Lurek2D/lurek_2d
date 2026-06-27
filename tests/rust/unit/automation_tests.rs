//! File: tests/rust/unit/automation_tests.rs

use lurek2d::automation::{Action, Script, Step};

#[test]
fn duration_keypress_expands_to_matching_release() {
    let mut step = Step::new(0.25, Action::KeyPress);
    step.key = Some("space".to_string());
    step.duration = Some(0.5);

    let script = Script::new("duration", vec![step]);

    assert_eq!(script.steps.len(), 2);
    assert_eq!(script.steps[0].action, Action::KeyPress);
    assert_eq!(script.steps[1].action, Action::KeyRelease);
    assert!((script.steps[1].time - 0.75).abs() < f32::EPSILON);
}

#[test]
fn combo_duration_expands_to_combo_release_in_time_order() {
    let mut combo = Step::new(1.0, Action::Combo);
    combo.combo = vec!["ctrl".to_string(), "a".to_string()];
    combo.duration = Some(0.1);
    let wait = Step::new(0.5, Action::Wait);

    let script = Script::new("combo", vec![combo, wait]);

    assert_eq!(script.steps[0].action, Action::Wait);
    assert_eq!(script.steps[1].action, Action::Combo);
    assert_eq!(script.steps[2].action, Action::ComboRelease);
    assert!((script.steps[2].time - 1.1).abs() < 0.0001);
}

#[test]
fn gamepad_and_touch_duration_steps_expand() {
    let mut gamepad = Step::new(0.0, Action::GamepadPress);
    gamepad.gamepad_id = Some(0);
    gamepad.gamepad_button = Some(2);
    gamepad.duration = Some(0.2);
    let mut touch = Step::new(0.3, Action::TouchPress);
    touch.touch_id = Some(9);
    touch.duration = Some(0.2);

    let script = Script::new("devices", vec![gamepad, touch]);

    assert_eq!(script.steps[0].action, Action::GamepadPress);
    assert_eq!(script.steps[1].action, Action::GamepadRelease);
    assert_eq!(script.steps[2].action, Action::TouchPress);
    assert_eq!(script.steps[3].action, Action::TouchRelease);
}
