//! Owns the UI context builders implementation for the UI subsystem and keeps related runtime rules local here.
//! Keeps retained widget state, layout helpers, and presentation rules so helpers stay close to invariants this updates.
//! Defines how UI context builders data is validated, transformed, or stored before neighboring systems consume it.
//! Separates UI context builders behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where UI code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing UI context builders defaults, lifecycle handling, validation, or data ownership rules.

use super::*;

impl GuiContext {
    /// Adds a button widget and returns its widget index.
    pub fn add_button(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Button(Button::new(text)));
        idx
    }
    /// Add a `Label` widget and return its index.
    pub fn add_label(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Label(Label::new(text)));
        idx
    }
    /// Add a `TextInput` widget and return its index.
    pub fn add_text_input(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::TextInput(TextInput::new()));
        idx
    }
    /// Add a `TextArea` widget and return its index.
    pub fn add_text_area(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::TextArea(TextArea::new()));
        idx
    }
    /// Add a `RichLabel` widget and return its index.
    pub fn add_rich_label(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::RichLabel(RichLabel::new(text)));
        idx
    }
    /// Add a `CheckBox` widget with the given label and return its index.
    pub fn add_checkbox(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::CheckBox(CheckBox::new(text)));
        idx
    }
    /// Add a `Slider` widget with the given value range and return its index.
    pub fn add_slider(&mut self, min: f64, max: f64) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Slider(Slider::new(min, max)));
        idx
    }
    /// Add a `ProgressBar` widget with the given value range and return its index.
    pub fn add_progress_bar(&mut self, min: f64, max: f64) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::ProgressBar(ProgressBar::new(min, max)));
        idx
    }
    /// Add a `ComboBox` widget and return its index.
    pub fn add_combo_box(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::ComboBox(ComboBox::new()));
        idx
    }
    /// Add a `ListBox` widget and return its index.
    pub fn add_list_box(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::ListBox(ListBox::new()));
        idx
    }
    /// Add a `Panel` container and return its index.
    pub fn add_panel(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Panel(Panel::new()));
        idx
    }
    /// Add a `Layout` container with the given direction and return its index.
    pub fn add_layout(&mut self, direction: crate::ui::LayoutDirection) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::Layout(Layout::new(direction)));
        idx
    }
    /// Add an `AspectRatioContainer` and return its index.
    pub fn add_aspect_ratio_container(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::AspectRatioContainer(AspectRatioContainer::new()));
        idx
    }
    /// Add a `ScrollPanel` container and return its index.
    pub fn add_scroll_panel(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::ScrollPanel(ScrollPanel::new()));
        idx
    }
    /// Add a `NinePatch` widget and return its index.
    pub fn add_nine_patch(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::NinePatch(NinePatch::new()));
        idx
    }
    /// Add a `TabBar` widget and return its index.
    pub fn add_tab_bar(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::TabBar(TabBar::new()));
        idx
    }
    /// Add a `Separator` widget (horizontal or vertical) and return its index.
    pub fn add_separator(&mut self, vertical: bool) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::Separator(Separator::new(vertical)));
        idx
    }
    /// Add a `Spacer` widget with the given dimensions and return its index.
    pub fn add_spacer(&mut self, width: f32, height: f32) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::Spacer(Spacer::new(width, height)));
        idx
    }
    /// Add a `TreeView` widget and return its index.
    pub fn add_tree_view(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::TreeView(TreeView::new()));
        idx
    }
    /// Add a `RadioButton` with the given label and group name and return its index.
    pub fn add_radio_button(&mut self, text: impl Into<String>, group: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::RadioButton(RadioButton::new(text, group)));
        idx
    }
    /// Add a `ScrollBar` (horizontal or vertical) and return its index.
    pub fn add_scroll_bar(&mut self, vertical: bool) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::ScrollBar(ScrollBar::new(vertical)));
        idx
    }
    /// Add a `GUIWindow` with the given title and return its index.
    pub fn add_gui_window(&mut self, title: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::GUIWindow(GUIWindow::new(title)));
        idx
    }
    /// Add a `SplitPanel` with the given orientation and return its index.
    pub fn add_split_panel(&mut self, orientation: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::SplitPanel(SplitPanel::new(orientation)));
        idx
    }
    /// Add a `StackContainer` and return its index.
    pub fn add_stack_container(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::StackContainer(StackContainer::new(false)));
        idx
    }
    /// Add a `TabContainer` and return its index.
    pub fn add_tab_container(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::TabContainer(StackContainer::new(true)));
        idx
    }
    /// Add a `DockPanel` container and return its index.
    pub fn add_dock_panel(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::DockPanel(DockPanel::new()));
        idx
    }
    /// Add a `Toolbar` with the given orientation and return its index.
    pub fn add_toolbar(&mut self, orientation: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::Toolbar(Toolbar::new(orientation)));
        idx
    }
    /// Add a `MenuBar` and return its index.
    pub fn add_menu_bar(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::MenuBar(MenuBar::new()));
        idx
    }
    /// Add a `MenuItem` with the given label and return its index.
    pub fn add_menu_item(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::MenuItem(MenuItem::new(text)));
        idx
    }
    /// Add a `Dialog` with the given title and return its index.
    pub fn add_dialog(&mut self, title: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Dialog(Dialog::new(title)));
        idx
    }
    /// Add a `StatusBar` and return its index.
    pub fn add_status_bar(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::StatusBar(StatusBar::new()));
        idx
    }
    /// Add an `Accordion` container and return its index.
    pub fn add_accordion(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Accordion(Accordion::new()));
        idx
    }
    /// Add a `TooltipPanel` with the given text and return its index.
    pub fn add_tooltip_panel(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::TooltipPanel(TooltipPanel::new(text)));
        idx
    }
    /// Add a `ColorPicker` widget and return its index.
    pub fn add_color_picker(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::ColorPicker(ColorPicker::new()));
        idx
    }
    /// Add a `GUITable` widget and return its index.
    pub fn add_gui_table(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::GUITable(GUITable::new()));
        idx
    }
    /// Add a `PropertyWidget` inspector and return its index; marks dirty.
    pub fn add_property_widget(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::PropertyWidget(PropertyWidget::new()));
        self.dirty = true;
        idx
    }
    /// Add an `ImageWidget` and return its index; also marks context dirty.
    pub fn add_image_widget(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::ImageWidget(ImageWidget::new()));
        self.dirty = true;
        idx
    }
    /// Add a `SpinBox` with the given value range and return its index; marks dirty.
    pub fn add_spin_box(&mut self, min: f64, max: f64) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::SpinBox(SpinBox::new(min, max)));
        self.dirty = true;
        idx
    }
    /// Add a `Switch` with the given initial on state and return its index; marks dirty.
    pub fn add_switch(&mut self, on: bool) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Switch(Switch::new(on)));
        self.dirty = true;
        idx
    }
    /// Add a `Badge` with the given count and return its index; marks dirty.
    pub fn add_badge(&mut self, count: u32) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Badge(Badge::new(count)));
        self.mark_dirty_flags(true, false, false, true);
        idx
    }
    /// Add a `CustomWidget` and return its index; marks dirty.
    pub fn add_custom_widget(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Custom(CustomWidget::new()));
        self.mark_dirty_flags(true, false, false, true);
        idx
    }
    /// Reset to the built-in dark theme and mark dirty.
    pub fn set_default_theme(&mut self) {
        self.theme = Some(crate::ui::theme::Theme::default_dark());
        self.mark_dirty_flags(false, true, false, true);
    }
    /// Set the viewport size used for root-relative layout; marks dirty.
    pub fn set_viewport(&mut self, width: f32, height: f32) {
        self.viewport_w = width;
        self.viewport_h = height;
        self.mark_dirty_flags(true, false, false, true);
    }
    /// Return `true` if the widget tree has changed since the last call; resets `dirty` and updates the render signature.
    pub fn flush_cache(&mut self) -> bool {
        let signature = self.compute_render_signature();
        let was_dirty = self.dirty
            || self.layout_dirty
            || self.style_dirty
            || self.text_dirty
            || self.render_dirty
            || signature != self.last_render_signature;
        self.dirty = false;
        self.layout_dirty = false;
        self.style_dirty = false;
        self.text_dirty = false;
        self.render_dirty = false;
        self.last_render_signature = signature;
        was_dirty
    }
}
