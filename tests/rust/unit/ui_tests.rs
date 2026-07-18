//! Internal regression tests for retained UI container layout behavior.

use lurek2d::ui::{Layout, LayoutDirection, WidgetBase, WidgetType};

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

    assert_eq!(children[0].y, 0.0);
    assert_eq!(children[2].y, 13.0);
}

#[test]
fn layout_direction_parser_rejects_unknown_tokens() {
    assert_eq!(
        LayoutDirection::parse_str("row"),
        Some(LayoutDirection::Horizontal)
    );
    assert_eq!(LayoutDirection::parse_str("diagonal"), None);
}
