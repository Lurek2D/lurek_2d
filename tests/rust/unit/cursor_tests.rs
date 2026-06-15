use lurek2d::cursor::context::{ContextRule, CursorState};
use lurek2d::cursor::{
    AnimatedCursor, CursorContext, CursorManager, CursorTrail, CursorZoom, CustomCursor,
    SystemCursor, TrailMode,
};

fn active_system(manager: &CursorManager) -> Option<SystemCursor> {
    match manager.active() {
        CursorState::System(cursor) => Some(*cursor),
        _ => None,
    }
}

#[test]
fn context_without_rule_restores_default_cursor() {
    let mut manager = CursorManager::new();
    manager.set_system(SystemCursor::Hand);
    manager.add_rule(ContextRule {
        context: CursorContext::UiButton,
        cursor: CursorState::System(SystemCursor::Crosshair),
    });

    manager.set_context(CursorContext::UiButton);
    assert_eq!(active_system(&manager), Some(SystemCursor::Crosshair));

    manager.set_context(CursorContext::Default);
    assert_eq!(active_system(&manager), Some(SystemCursor::Hand));
}

#[test]
fn replacing_rule_updates_active_context_immediately() {
    let mut manager = CursorManager::new();
    manager.set_context(CursorContext::UiButton);
    manager.add_rule(ContextRule {
        context: CursorContext::UiButton,
        cursor: CursorState::System(SystemCursor::Hand),
    });
    assert_eq!(active_system(&manager), Some(SystemCursor::Hand));

    manager.add_rule(ContextRule {
        context: CursorContext::UiButton,
        cursor: CursorState::System(SystemCursor::Wait),
    });
    assert_eq!(active_system(&manager), Some(SystemCursor::Wait));
}

#[test]
fn removing_rule_restores_default_cursor() {
    let mut manager = CursorManager::new();
    manager.set_system(SystemCursor::No);
    manager.set_context(CursorContext::UiButton);
    manager.add_rule(ContextRule {
        context: CursorContext::UiButton,
        cursor: CursorState::System(SystemCursor::Hand),
    });
    assert_eq!(active_system(&manager), Some(SystemCursor::Hand));

    manager.remove_rule(&CursorContext::UiButton);
    assert_eq!(active_system(&manager), Some(SystemCursor::No));
}

#[test]
fn animated_cursor_advances_when_active() {
    let mut animated = AnimatedCursor::new(true);
    animated.add_frame(CustomCursor::new(4, 4, 0, 0), 10);
    animated.add_frame(CustomCursor::new(4, 4, 0, 0), 10);

    let mut manager = CursorManager::new();
    manager.set_animated(animated);
    manager.update(0.0, 0.0, 0.015);

    match manager.active() {
        CursorState::Animated(cursor) => assert_eq!(cursor.current_index(), 1),
        other => panic!("expected animated cursor, got {other:?}"),
    }
}

#[test]
fn trail_and_zoom_toggles_are_visible_in_manager_state() {
    let mut manager = CursorManager::new();
    manager.set_trail(Some(CursorTrail::new(TrailMode::Line {
        color: [1.0, 1.0, 1.0, 1.0],
        width: 2.0,
        fade: true,
    })));
    manager.set_zoom(Some(CursorZoom::new(2.0, 48.0)));

    assert!(manager.trail().is_some());
    assert!(manager.zoom().is_some());

    manager.set_trail(None);
    manager.set_zoom(None);

    assert!(manager.trail().is_none());
    assert!(manager.zoom().is_none());
}
