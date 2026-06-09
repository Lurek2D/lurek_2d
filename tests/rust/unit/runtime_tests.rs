//! File: tests/rust/unit/runtime_tests.rs

// TODO(lua-first): keep only private/internal seams here.

use lurek2d::runtime::SharedState;
use std::path::PathBuf;

mod touch_canvas_tests {
    use super::*;

    #[test]
    fn touch_canvas_records_frame() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        let key = st.canvases.insert(lurek2d::render::Canvas::new(16, 16));
        st.frame_counter = 42;
        st.touch_canvas(key);
        assert_eq!(st.canvas_last_used.get(&key).copied(), Some(42));
    }

    #[test]
    fn touch_canvas_overwrites_older_frame() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        let key = st.canvases.insert(lurek2d::render::Canvas::new(16, 16));
        st.frame_counter = 1;
        st.touch_canvas(key);
        st.frame_counter = 99;
        st.touch_canvas(key);
        assert_eq!(st.canvas_last_used.get(&key).copied(), Some(99));
    }
}

mod pending_config_reload_tests {
    use super::*;

    #[test]
    fn default_pending_config_reload_is_false() {
        let st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        assert!(!st.pending_config_reload);
    }

    #[test]
    fn pending_config_reload_can_be_set_and_cleared() {
        let mut st = SharedState::new(800, 600, "Test", PathBuf::from("."));
        st.pending_config_reload = true;
        assert!(st.pending_config_reload);
        st.pending_config_reload = false;
        assert!(!st.pending_config_reload);
    }
}
