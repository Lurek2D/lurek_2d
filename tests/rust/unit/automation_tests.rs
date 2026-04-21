//! Smoke tests for the automation module against the current public API.

use lurek2d::automation::{Action, Script, Simulator, Step};
use lurek2d::event::EventQueue;

mod step_tests {
    use super::*;

    #[test]
    fn parse_action_known_variants() {
        assert_eq!(Action::parse_action("keypress"), Some(Action::KeyPress));
        assert_eq!(Action::parse_action("keyrelease"), Some(Action::KeyRelease));
        assert_eq!(Action::parse_action("mousemove"), Some(Action::MouseMove));
        assert_eq!(Action::parse_action("mousepress"), Some(Action::MousePress));
        assert_eq!(Action::parse_action("mouserelease"), Some(Action::MouseRelease));
        assert_eq!(Action::parse_action("mousewheel"), Some(Action::MouseWheel));
        assert_eq!(Action::parse_action("textinput"), Some(Action::TextInput));
        assert_eq!(Action::parse_action("wait"), Some(Action::Wait));
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
        let mut s = Step::new(0.0, Action::KeyPress);
        s.key = Some("a".into());
        s.scancode = Some("KeyA".into());
        assert_eq!(s.effective_scancode(), Some("KeyA"));
    }
}

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
        s.set_step_limit(3);
        assert_eq!(s.get_step_limit(), 3);
        assert_eq!(s.step_count(), 3);
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
action = "keypress"
time = 1.0
key = "space"
"#;
        let s = Script::from_toml("t", toml).unwrap();
        assert_eq!(s.step_count(), 2);
        assert_eq!(s.description.as_deref(), Some("test script"));
    }
}

mod simulator_tests {
    use super::*;

    fn script_with_text_event(name: &str) -> Script {
        let mut step = Step::new(0.0, Action::TextInput);
        step.text = Some("hello".into());
        Script::new(name, vec![step])
    }

    #[test]
    fn new_simulator_idle() {
        let sim = Simulator::new();
        assert!(!sim.is_running());
        assert!(!sim.is_paused());
        assert!(!sim.is_complete());
        assert!(sim.current_script().is_none());
    }

    #[test]
    fn load_and_start_script() {
        let mut sim = Simulator::new();
        sim.load(script_with_text_event("test"));
        assert!(sim.has_script("test"));
        sim.start("test").unwrap();
        assert!(sim.is_running());
        assert_eq!(sim.current_script(), Some("test"));
        assert_eq!(sim.step_count(), 1);
    }

    #[test]
    fn pause_and_resume() {
        let mut sim = Simulator::new();
        sim.load(script_with_text_event("test"));
        sim.start("test").unwrap();
        sim.pause();
        assert!(sim.is_paused());
        sim.resume();
        assert!(!sim.is_paused());
        assert!(sim.is_running());
    }

    #[test]
    fn update_dispatches_events() {
        let mut sim = Simulator::new();
        let mut queue = EventQueue::new();
        sim.load(script_with_text_event("test"));
        sim.start("test").unwrap();
        sim.update(0.1, &mut queue);
        assert_eq!(queue.len(), 1);
        assert_eq!(sim.current_step(), 1);
        assert!(sim.is_complete());
    }

    #[test]
    fn macro_round_trip() {
        let mut sim = Simulator::new();
        sim.save_macro("macro1".to_string(), script_with_text_event("macro_script"));
        assert!(sim.has_macro("macro1"));
        assert_eq!(sim.list_macros().len(), 1);
        sim.play_macro("macro1").unwrap();
        assert_eq!(sim.current_script(), Some("macro_script"));
    }
}
