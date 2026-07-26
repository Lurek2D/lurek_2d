//! Internal regression tests for retained UI container layout behavior.

use lurek2d::ui::extras::{Toolbar, ToolbarItem};
use lurek2d::ui::{
    load_layout_def_attached, GuiContext, Layout, LayoutDirection, WidgetBase, WidgetDef,
    WidgetType,
};

fn assert_near(actual: f32, expected: f32) {
    assert!(
        (actual - expected).abs() <= 0.001,
        "expected {expected}, got {actual}"
    );
}

#[test]
fn isolated_context_layout_widgets_are_focusable_after_attachment() {
    let mut context = GuiContext::new();
    context.set_viewport(640.0, 360.0);
    let definition = WidgetDef {
        widget_type: "button".to_string(),
        text: Some("Start".to_string()),
        ..WidgetDef::default()
    };
    let slot = load_layout_def_attached(&mut context, &definition).unwrap();
    context.run_layout_pass();
    let base = context.widgets[slot].base();
    assert!(base.visible);
    assert!(base.is_visible);
    assert!(base.enabled);
    assert!(base.focusable);
    context.set_focus(Some(slot));
    assert_eq!(context.focused_widget, Some(slot));
}

#[test]
fn vertical_layout_skips_hidden_children_and_applies_spacing() {
    let mut layout = Layout::new(LayoutDirection::Vertical);
    layout.children = vec![0, 1, 2];
    layout.spacing = 3.0;

    let mut children = vec![
        WidgetBase::new(WidgetType::Panel),
        WidgetBase::new(WidgetType::Panel),
        WidgetBase::new(WidgetType::Panel),
    ];
    children[0].height = 10.0;
    children[1].visible = false;
    children[2].height = 5.0;
    layout.perform_layout(&mut children);

    assert_near(children[0].y, 0.0);
    assert_near(children[2].y, 13.0);
}

#[test]
fn layout_direction_parser_rejects_unknown_tokens() {
    assert_eq!(
        LayoutDirection::parse_str("row"),
        Some(LayoutDirection::Horizontal)
    );
    assert_eq!(LayoutDirection::parse_str("diagonal"), None);
}

#[test]
fn toolbar_retains_separator_and_flexible_spacer_as_semantic_items() {
    let mut toolbar = Toolbar::new("horizontal");
    toolbar.add_button("save", "Save");
    toolbar.add_separator();
    toolbar.add_spacer(None);
    toolbar.add_spacer(Some(12.0));

    assert!(matches!(toolbar.items[1], ToolbarItem::Separator));
    assert!(matches!(toolbar.items[2], ToolbarItem::Spacer(None)));
    assert!(matches!(toolbar.items[3], ToolbarItem::Spacer(Some(12.0))));
}

#[test]
fn status_bar_section_widget_is_reparented_laid_out_and_cleared_on_destroy() {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(240.0, 40.0);
    let status = ctx.add_status_bar();
    let child = ctx.add_button("Ready");
    assert!(ctx.add_child(0, status));
    if let lurek2d::ui::context::WidgetKind::StatusBar(bar) = &mut ctx.widgets[status] {
        bar.sections.push((String::new(), 120.0));
        bar.section_widgets.push(None);
    }
    ctx.set_status_bar_section_widget(status, 0, Some(child))
        .unwrap();
    ctx.run_layout_pass();
    assert_eq!(ctx.child_count(status), 1);
    assert_near(ctx.widgets[child].base().computed_rect.width, 120.0);
    ctx.destroy_widget(child, true).unwrap();
    let lurek2d::ui::context::WidgetKind::StatusBar(bar) = &ctx.widgets[status] else {
        panic!("status bar retained its kind");
    };
    assert_eq!(bar.section_widgets, vec![None]);
}

#[test]
fn shrinking_status_sections_detaches_removed_section_widgets() {
    let mut ctx = GuiContext::new();
    let status = ctx.add_status_bar();
    let child = ctx.add_button("Detached");
    assert!(ctx.add_child(0, status));
    if let lurek2d::ui::context::WidgetKind::StatusBar(bar) = &mut ctx.widgets[status] {
        bar.sections.push((String::new(), 100.0));
        bar.section_widgets.push(None);
    }
    ctx.set_status_bar_section_widget(status, 0, Some(child))
        .unwrap();
    ctx.set_status_bar_section_count(status, 0).unwrap();
    assert_eq!(ctx.child_count(status), 0);
    assert!(ctx.validate_tree().is_empty());
}

#[test]
fn dock_panel_allocates_edges_then_gives_fill_the_remaining_rectangle() {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(800.0, 600.0);
    let dock = ctx.add_dock_panel();
    let top = ctx.add_panel();
    let left = ctx.add_panel();
    let fill = ctx.add_panel();
    assert!(ctx.add_child(0, dock));
    ctx.widgets[dock].base_mut().width = 800.0;
    ctx.widgets[dock].base_mut().height = 600.0;
    if let lurek2d::ui::context::WidgetKind::DockPanel(panel) = &mut ctx.widgets[dock] {
        panel.docked = vec![
            (top, "top".into()),
            (left, "left".into()),
            (fill, "fill".into()),
        ];
        panel.split_sizes = vec![("top".into(), 64.0), ("left".into(), 200.0)];
    } else {
        panic!("expected dock panel");
    }
    ctx.run_layout_pass();
    let top_rect = ctx.widgets[top].base().computed_rect;
    let left_rect = ctx.widgets[left].base().computed_rect;
    let fill_rect = ctx.widgets[fill].base().computed_rect;
    assert_near(top_rect.width, 800.0);
    assert_near(top_rect.height, 64.0);
    assert_near(left_rect.x, 0.0);
    assert_near(left_rect.y, 64.0);
    assert_near(left_rect.width, 200.0);
    assert_near(left_rect.height, 536.0);
    assert_near(fill_rect.x, 200.0);
    assert_near(fill_rect.y, 64.0);
    assert_near(fill_rect.width, 600.0);
    assert_near(fill_rect.height, 536.0);
}

#[test]
fn runtime_stats_record_layout_and_command_lowering_work() {
    let mut ctx = GuiContext::new();
    let button = ctx.add_button("Telemetry");
    assert!(ctx.add_child(0, button));
    ctx.run_layout_pass();
    let before = ctx.runtime_stats();
    assert!(before.layout_passes >= 1);
    let commands = ctx.generate_render_commands();
    let after = ctx.runtime_stats();
    assert_eq!(after.live_widgets, 1);
    assert_eq!(after.last_frame_commands, commands.len());
    assert_eq!(after.layout_passes, before.layout_passes);
}

#[test]
fn clean_render_command_lowering_does_not_repeat_layout() {
    let mut ctx = GuiContext::new();
    let button = ctx.add_button("Cached geometry");
    assert!(ctx.add_child(0, button));
    let _ = ctx.generate_render_commands();
    let after_first = ctx.runtime_stats().layout_passes;
    let _ = ctx.generate_render_commands();
    assert_eq!(after_first, ctx.runtime_stats().layout_passes);
}

#[test]
fn flushed_clean_context_reuses_the_cached_command_stream() {
    let mut ctx = GuiContext::new();
    let button = ctx.add_button("Cached commands");
    assert!(ctx.add_child(0, button));
    let first = ctx.generate_render_commands();
    assert!(ctx.flush_cache());
    let second = ctx.generate_render_commands();
    assert_eq!(first.len(), second.len());
    let stats = ctx.runtime_stats();
    assert_eq!(stats.command_cache_misses, 1);
    assert_eq!(stats.command_cache_hits, 1);
}

#[test]
fn command_cache_rejects_a_flushed_structural_mutation() {
    let mut ctx = GuiContext::new();
    let button = ctx.add_button("First");
    assert!(ctx.add_child(0, button));
    let first = ctx.generate_render_commands();
    assert!(ctx.flush_cache());
    let second = ctx.generate_render_commands();
    assert_eq!(first.len(), second.len());
    let label = ctx.add_label("new visual node");
    assert!(ctx.add_child(0, label));
    assert!(ctx.flush_cache());
    let third = ctx.generate_render_commands();
    assert!(third.len() > second.len());
}

#[test]
fn command_cache_rejects_a_flushed_text_or_viewport_mutation() {
    let mut ctx = GuiContext::new();
    let button = ctx.add_button("Before");
    assert!(ctx.add_child(0, button));
    let first = ctx.generate_render_commands();
    assert!(ctx.flush_cache());
    let _ = ctx.generate_render_commands();
    let hits = ctx.runtime_stats().command_cache_hits;
    if let lurek2d::ui::context::WidgetKind::Button(button) = &mut ctx.widgets[button] {
        button.text = "After".into();
    }
    ctx.mark_widget_dirty(false, false, true, true);
    assert!(ctx.flush_cache());
    let changed = ctx.generate_render_commands();
    assert_ne!(format!("{first:?}"), format!("{changed:?}"));
    assert_eq!(ctx.runtime_stats().command_cache_hits, hits);
    ctx.set_safe_area(4.0, 0.0, 0.0, 0.0);
    assert!(ctx.flush_cache());
    let _ = ctx.generate_render_commands();
    assert_eq!(ctx.runtime_stats().command_cache_hits, hits);
}

#[test]
fn safe_area_insets_root_layout_and_invalid_values_are_rejected() {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(200.0, 100.0);
    assert!(ctx.set_safe_area(10.0, 20.0, 5.0, 15.0));
    ctx.run_layout_pass();
    let root = ctx.widgets[0].base().computed_rect;
    assert_near(root.x, 15.0);
    assert_near(root.y, 10.0);
    assert_near(root.width, 165.0);
    assert_near(root.height, 85.0);
    assert!(!ctx.set_safe_area(-1.0, 0.0, 0.0, 0.0));
}

#[test]
fn clean_input_layout_reuses_cached_parent_metadata() {
    let mut ctx = GuiContext::new();
    let button = ctx.add_button("Input cache");
    assert!(ctx.add_child(0, button));
    assert!(ctx.mouse_moved(1.0, 1.0));
    let layouts = ctx.runtime_stats().layout_passes;
    let _ = ctx.mouse_moved(2.0, 2.0);
    assert_eq!(layouts, ctx.runtime_stats().layout_passes);
}
