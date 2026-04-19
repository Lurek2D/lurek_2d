//! Tests for the automation module.

use lurek2d::automation::step::{Action, Step};
use lurek2d::automation::script::Script;
use lurek2d::automation::simulator::Simulator;

// ── step ─────────────────────────────────────────────────────────────────────

mod step_tests {
    use super::*;

    #[test]
    fn parse_action_known_variants() {
        assert_eq!(Action::parse_action("keypressed"), Some(Action::KeyPressed));
        assert_eq!(Action::parse_action("keyreleased"), Some(Action::KeyReleased));
        assert_eq!(Action::parse_action("mousepressed"), Some(Action::MousePressed));
        assert_eq!(Action::parse_action("mousereleased"), Some(Action::MouseReleased));
        assert_eq!(Action::parse_action("mousemoved"), Some(Action::MouseMoved));
        assert_eq!(Action::parse_action("wheelmoved"), Some(Action::WheelMoved));
        assert_eq!(Action::parse_action("textinput"), Some(Action::TextInput));
        assert_eq!(Action::parse_action("wait"), Some(Action::Wait));
    }

    #[test]
    fn parse_action_unknown_returns_none() {
        assert_eq!(Action::parse_action("fly"), None);
        assert_eq!(Action::parse_action(""), None);
    }

    #[test]
    fn as_str_roundtrip() {
        for action in [
            Action::KeyPressed, Action::KeyReleased,
            Action::MousePressed, Action::MouseReleased,
            Action::MouseMoved, Action::WheelMoved,
            Action::TextInput, Action::Wait,
        ] {
            let s = action.as_str();
            assert_eq!(Action::parse_action(s), Some(action));
        }
    }

    #[test]
    fn step_new_defaults() {
        let s = Step::new(1.5, Action::Wait);
        assert!((s.time - 1.5).abs() < f32::EPSILON);
        assert_eq!(s.action, Action::Wait);
        assert!(s.key.is_none());
        assert!(!s.is_repeat);
    }

    #[test]
    fn effective_scancode_prefers_scancode() {
        let mut s = Step::new(0.0, Action::KeyPressed);
        s.key = Some("a".into());
        s.scancode = Some("KeyA".into());
        assert_eq!(s.effective_scancode(), Some("KeyA"));
    }

    #[test]
    fn effective_scancode_falls_back_to_key() {
        let mut s = Step::new(0.0, Action::KeyPressed);
        s.key = Some("space".into());
        assert_eq!(s.effective_scancode(), Some("space"));
    }

    #[test]
    fn effective_scancode_none_when_both_absent() {
        let s = Step::new(0.0, Action::KeyPressed);
        assert_eq!(s.effective_scancode(), None);
    }
}

// ── script ───────────────────────────────────────────────────────────────────

mod script_tests {
    use super::*;

    fn make_steps(n: usize) -> Vec<Step> {
        (0..n).map(|i| Step::new(i as f32 * 0.1, Action::Wait)).collect()
    }

    #[test]
    fn new_script_properties() {
        let s = Script::new("demo", make_steps(3));
        assert_eq!(s.name, "demo");
        assert_eq!(s.step_count(), 3);
        assert!(s.description.is_none());
    }

    #[test]
    fn with_description() {
        let s = Script::with_description("d", "A demo", make_steps(1));
        assert_eq!(s.description.as_deref(), Some("A demo"));
    }

    #[test]
    fn step_limit_clamps_count() {
        let mut s = Script::new("s", make_steps(5));
        s.step_limit = Some(3);
        assert!(s.step_limit.unwrap() <= s.step_count());
    }

    #[test]
    fn duration_is_last_step_time() {
        let steps = vec![
            Step::new(0.0, Action::Wait),
            Step::new(1.5, Action::Wait),
        ];
        let s = Script::new("s", steps);
        assert!((s.duration() - 1.5).abs() < f32::EPSILON);
    }

    #[test]
    fn from_toml_valid() {
        let toml = r#"
[meta]
description = "test script"

[[steps]]
action = "wait"
time = 0.5

[[steps]]
action = "keypressed"
time = 1.0
key = "space"
"#;
        let s = Script::from_toml("t", toml).unwrap();
        assert_eq!(s.step_count(), 2);
        assert_eq!(s.description.as_deref(), Some("test script"));
    }

    #[test]
    fn from_toml_unknown_action_errors() {
        let toml = r#"
[[steps]]
action = "fly"
time = 0.0
"#;
        assert!(Script::from_toml("t", toml).is_err());
    }

    #[test]
    fn from_toml_invalid_toml_errors() {
        assert!(Script::from_toml("t", "not valid toml {{{").is_err());
    }
}

// ── simulator ────────────────────────────────────────────────────────────────

mod simulator_tests {
    use super::*;

    fn test_script(n: usize) -> Script {
        let steps: Vec<Step> = (0..n)
            .map(|i| Step::new(i as f32 * 0.1, Action::Wait))
            .collect();
        Script::new("test", steps)
    }

    #[test]
    fn new_simulator_idle() {
        let sim = Simulator::new();
        assert!(!sim.is_playing);
        assert!(!sim.is_paused);
        assert!(!sim.is_recording);
    }

    #[test]
    fn load_script_stores_it() {
        let mut sim = Simulator::new();
        sim.load_script(test_script(3));
        assert!(sim.script.is_some());
    }

    #[test]
    fn start_sets_playing() {
        let mut sim = Simulator::new();
        sim.load_script(test_script(2));
        sim.start();
        assert!(sim.is_playing);
        assert!(!sim.is_paused);
    }

    #[test]
    fn pause_and_resume() {
        let mut sim = Simulator::new();
        sim.load_script(test_script(2));
        sim.start();
        sim.pause();
        assert!(sim.is_paused);
        sim.resume();
        assert!(!sim.is_paused);
    }

    #[test]
    fn stop_resets_state() {
        let mut sim = Simulator::new();
        sim.load_script(test_script(2));
        sim.start();
        sim.stop();
        assert!(!sim.is_playing);
    }

    #[test]
    fn playback_speed_clamped() {
        let mut sim = Simulator::new();
        sim.set_playback_speed(-1.0);
        assert!(sim.playback_speed >= 0.0);
    }

    #[test]
    fn macro_record_and_list() {
        let mut sim = Simulator::new();
        sim.start_macro("m1");
        sim.record_macro_step(Step::new(0.0, Action::Wait));
        sim.stop_macro();
        assert!(sim.macro_names().contains(&"m1".to_string()));
    }

    #[test]
    fn delete_macro() {
        let mut sim = Simulator::new();
        sim.start_macro("m");
        sim.stop_macro();
        assert!(sim.delete_macro("m"));
        assert!(!sim.macro_names().contains(&"m".to_string()));
    }
}
