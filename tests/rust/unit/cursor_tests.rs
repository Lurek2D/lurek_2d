use lurek2d::cursor::context::{
    ContextRule, CursorEffectSpec, CursorHit, CursorInputFrame, CursorRule, CursorRuleEvent,
    CursorRuleTarget, CursorState, CursorStateSpec,
};
use lurek2d::cursor::{
    AnimatedCursor, CursorContext, CursorManager, CursorTrail, CursorZoom, CustomCursor,
    SystemCursor, TrailMode,
};
use std::collections::HashMap;

fn active_system(manager: &CursorManager) -> Option<SystemCursor> {
    match manager.active() {
        CursorState::System(cursor) => Some(*cursor),
        _ => None,
    }
}

fn cursor_hit(module_name: &str, kind: &str, surface: &str) -> CursorHit {
    CursorHit {
        module_name: module_name.to_string(),
        kind: kind.to_string(),
        surface: surface.to_string(),
        id: None,
        attrs: HashMap::new(),
        context: None,
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
    manager.set_trail(Some(CursorTrail::new(TrailMode::Line)));
    manager.set_zoom(Some(CursorZoom::new(2.0, 48.0)));

    assert!(manager.trail().is_some());
    assert!(manager.zoom().is_some());

    manager.set_trail(None);
    manager.set_zoom(None);

    assert!(manager.trail().is_none());
    assert!(manager.zoom().is_none());
}

#[test]
fn v2_context_rule_selects_named_state() {
    let mut manager = CursorManager::new();
    manager.define_state(
        "inspect",
        CursorStateSpec::from_state(CursorState::System(SystemCursor::Hand)),
    );
    manager.add_rule_v2(CursorRule {
        id: 0,
        priority: 10,
        event: CursorRuleEvent::Context,
        context: Some(CursorContext::UiButton),
        target: None,
        state: Some("inspect".to_string()),
        effect: None,
        duration_ms: 0,
        inline_state: None,
    });

    manager.set_context(CursorContext::UiButton);

    let info = manager.get_active_state();
    assert_eq!(active_system(&manager), Some(SystemCursor::Hand));
    assert_eq!(info.name.as_deref(), Some("inspect"));
}

#[test]
fn hover_rule_priority_beats_context_and_leave_restores_context() {
    let mut manager = CursorManager::new();
    manager.define_state(
        "ctx_state",
        CursorStateSpec::from_state(CursorState::System(SystemCursor::Hand)),
    );
    manager.define_state(
        "hover_state",
        CursorStateSpec::from_state(CursorState::System(SystemCursor::Crosshair)),
    );
    manager.add_rule_v2(CursorRule {
        id: 0,
        priority: 5,
        event: CursorRuleEvent::Context,
        context: Some(CursorContext::UiButton),
        target: None,
        state: Some("ctx_state".to_string()),
        effect: None,
        duration_ms: 0,
        inline_state: None,
    });
    manager.add_rule_v2(CursorRule {
        id: 0,
        priority: 50,
        event: CursorRuleEvent::Hover,
        context: Some(CursorContext::UiButton),
        target: Some(CursorRuleTarget {
            module_name: Some("globe".to_string()),
            kind: Some("marker".to_string()),
            surface: None,
            id: None,
            attrs: HashMap::new(),
        }),
        state: Some("hover_state".to_string()),
        effect: None,
        duration_ms: 0,
        inline_state: None,
    });
    manager.set_context(CursorContext::UiButton);

    manager.tick(
        32.0,
        24.0,
        0.016,
        CursorInputFrame::default(),
        Some(cursor_hit("globe", "marker", "marker")),
    );
    assert_eq!(active_system(&manager), Some(SystemCursor::Crosshair));

    manager.tick(32.0, 24.0, 0.016, CursorInputFrame::default(), None);
    assert_eq!(active_system(&manager), Some(SystemCursor::Hand));
}

#[test]
fn attrs_first_hover_can_drive_state_effect_and_zoom() {
    let mut manager = CursorManager::new();
    manager.define_state(
        "marker_state",
        CursorStateSpec::from_state(CursorState::System(SystemCursor::Crosshair)),
    );
    manager.define_effect("spark", CursorEffectSpec::default());

    let mut hit = cursor_hit("globe", "marker", "marker");
    hit.attrs
        .insert("cursor_state".to_string(), "marker_state".to_string());
    hit.attrs
        .insert("cursor_effect".to_string(), "spark".to_string());
    hit.attrs
        .insert("cursor_priority".to_string(), "120".to_string());
    hit.attrs
        .insert("cursor_zoom".to_string(), "3.25".to_string());

    manager.tick(
        10.0,
        14.0,
        0.016,
        CursorInputFrame::default(),
        Some(hit.clone()),
    );
    assert_eq!(active_system(&manager), Some(SystemCursor::Crosshair));
    assert_eq!(manager.bursts().len(), 1);
    assert!(
        (manager
            .zoom()
            .expect("attr zoom should exist")
            .magnification
            - 3.25)
            .abs()
            < 1e-5
    );

    manager.tick(10.0, 14.0, 0.016, CursorInputFrame::default(), Some(hit));
    assert_eq!(manager.bursts().len(), 1);

    manager.tick(10.0, 14.0, 0.016, CursorInputFrame::default(), None);
    assert!(manager.zoom().is_none());
}
