//! Owns the UI context builders implementation for the UI subsystem and keeps related runtime rules local here.
//! Keeps retained widget state, layout helpers, and presentation rules so helpers stay close to invariants this updates.
//! Defines how UI context builders data is validated, transformed, or stored before neighboring systems consume it.
//! Separates UI context builders behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where UI code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing UI context builders defaults, lifecycle handling, validation, or data ownership rules.

use super::*;

impl GuiContext {
    pub(crate) fn push_widget(&mut self, widget: WidgetKind) -> usize {
        if self.widget_count() >= self.limits.max_live_widgets {
            return usize::MAX;
        }
        let idx = self.widgets.len();
        self.widgets.push(widget);
        self.live_slots.push(true);
        idx
    }

    /// Adds a button widget and returns its widget index.
    pub fn add_button(&mut self, text: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::Button(Button::new(text)))
    }
    /// Add a `Label` widget and return its index.
    pub fn add_label(&mut self, text: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::Label(Label::new(text)))
    }
    /// Add a `TextInput` widget and return its index.
    pub fn add_text_input(&mut self) -> usize {
        self.push_widget(WidgetKind::TextInput(TextInput::new()))
    }
    /// Add a `TextArea` widget and return its index.
    pub fn add_text_area(&mut self) -> usize {
        self.push_widget(WidgetKind::TextArea(TextArea::new()))
    }
    /// Add a `RichLabel` widget and return its index.
    pub fn add_rich_label(&mut self, text: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::RichLabel(RichLabel::new(text)))
    }
    /// Add a `CheckBox` widget with the given label and return its index.
    pub fn add_checkbox(&mut self, text: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::CheckBox(CheckBox::new(text)))
    }
    /// Add a `Slider` widget with the given value range and return its index.
    pub fn add_slider(&mut self, min: f64, max: f64) -> usize {
        self.push_widget(WidgetKind::Slider(Slider::new(min, max)))
    }
    /// Add a `ProgressBar` widget with the given value range and return its index.
    pub fn add_progress_bar(&mut self, min: f64, max: f64) -> usize {
        self.push_widget(WidgetKind::ProgressBar(ProgressBar::new(min, max)))
    }
    /// Add a `ComboBox` widget and return its index.
    pub fn add_combo_box(&mut self) -> usize {
        self.push_widget(WidgetKind::ComboBox(ComboBox::new()))
    }
    /// Add a `ListBox` widget and return its index.
    pub fn add_list_box(&mut self) -> usize {
        self.push_widget(WidgetKind::ListBox(ListBox::new()))
    }
    /// Add a `Panel` container and return its index.
    pub fn add_panel(&mut self) -> usize {
        self.push_widget(WidgetKind::Panel(Panel::new()))
    }
    /// Add a `Layout` container with the given direction and return its index.
    pub fn add_layout(&mut self, direction: crate::ui::LayoutDirection) -> usize {
        self.push_widget(WidgetKind::Layout(Layout::new(direction)))
    }
    /// Add an `AspectRatioContainer` and return its index.
    pub fn add_aspect_ratio_container(&mut self) -> usize {
        self.push_widget(WidgetKind::AspectRatioContainer(AspectRatioContainer::new()))
    }
    /// Add a `ScrollPanel` container and return its index.
    pub fn add_scroll_panel(&mut self) -> usize {
        self.push_widget(WidgetKind::ScrollPanel(ScrollPanel::new()))
    }
    /// Add a `NinePatch` widget and return its index.
    pub fn add_nine_patch(&mut self) -> usize {
        self.push_widget(WidgetKind::NinePatch(NinePatch::new()))
    }
    /// Add a `TabBar` widget and return its index.
    pub fn add_tab_bar(&mut self) -> usize {
        self.push_widget(WidgetKind::TabBar(TabBar::new()))
    }
    /// Add a `Separator` widget (horizontal or vertical) and return its index.
    pub fn add_separator(&mut self, vertical: bool) -> usize {
        self.push_widget(WidgetKind::Separator(Separator::new(vertical)))
    }
    /// Add a `Spacer` widget with the given dimensions and return its index.
    pub fn add_spacer(&mut self, width: f32, height: f32) -> usize {
        self.push_widget(WidgetKind::Spacer(Spacer::new(width, height)))
    }
    /// Add a `TreeView` widget and return its index.
    pub fn add_tree_view(&mut self) -> usize {
        self.push_widget(WidgetKind::TreeView(TreeView::new()))
    }
    /// Add a `RadioButton` with the given label and group name and return its index.
    pub fn add_radio_button(&mut self, text: impl Into<String>, group: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::RadioButton(RadioButton::new(text, group)))
    }
    /// Add a `ScrollBar` (horizontal or vertical) and return its index.
    pub fn add_scroll_bar(&mut self, vertical: bool) -> usize {
        self.push_widget(WidgetKind::ScrollBar(ScrollBar::new(vertical)))
    }
    /// Add a `GUIWindow` with the given title and return its index.
    pub fn add_gui_window(&mut self, title: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::GUIWindow(GUIWindow::new(title)))
    }
    /// Add a `SplitPanel` with the given orientation and return its index.
    pub fn add_split_panel(&mut self, orientation: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::SplitPanel(SplitPanel::new(orientation)))
    }
    /// Add a `StackContainer` and return its index.
    pub fn add_stack_container(&mut self) -> usize {
        self.push_widget(WidgetKind::StackContainer(StackContainer::new(false)))
    }
    /// Add a `TabContainer` and return its index.
    pub fn add_tab_container(&mut self) -> usize {
        self.push_widget(WidgetKind::TabContainer(StackContainer::new(true)))
    }
    /// Add a `DockPanel` container and return its index.
    pub fn add_dock_panel(&mut self) -> usize {
        self.push_widget(WidgetKind::DockPanel(DockPanel::new()))
    }
    /// Add a `Toolbar` with the given orientation and return its index.
    pub fn add_toolbar(&mut self, orientation: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::Toolbar(Toolbar::new(orientation)))
    }
    /// Add a `MenuBar` and return its index.
    pub fn add_menu_bar(&mut self) -> usize {
        self.push_widget(WidgetKind::MenuBar(MenuBar::new()))
    }
    /// Add a `MenuItem` with the given label and return its index.
    pub fn add_menu_item(&mut self, text: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::MenuItem(MenuItem::new(text)))
    }
    /// Add a `Dialog` with the given title and return its index.
    pub fn add_dialog(&mut self, title: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::Dialog(Dialog::new(title)))
    }
    /// Add a `StatusBar` and return its index.
    pub fn add_status_bar(&mut self) -> usize {
        self.push_widget(WidgetKind::StatusBar(StatusBar::new()))
    }
    /// Add an `Accordion` container and return its index.
    pub fn add_accordion(&mut self) -> usize {
        self.push_widget(WidgetKind::Accordion(Accordion::new()))
    }
    /// Add a `TooltipPanel` with the given text and return its index.
    pub fn add_tooltip_panel(&mut self, text: impl Into<String>) -> usize {
        self.push_widget(WidgetKind::TooltipPanel(TooltipPanel::new(text)))
    }
    /// Add a `ColorPicker` widget and return its index.
    pub fn add_color_picker(&mut self) -> usize {
        self.push_widget(WidgetKind::ColorPicker(ColorPicker::new()))
    }
    /// Add a `GUITable` widget and return its index.
    pub fn add_gui_table(&mut self) -> usize {
        self.push_widget(WidgetKind::GUITable(GUITable::new()))
    }
    /// Add a `PropertyWidget` inspector and return its index; marks dirty.
    pub fn add_property_widget(&mut self) -> usize {
        let idx = self.push_widget(WidgetKind::PropertyWidget(PropertyWidget::new()));
        self.dirty = true;
        idx
    }
    /// Add an `ImageWidget` and return its index; also marks context dirty.
    pub fn add_image_widget(&mut self) -> usize {
        let idx = self.push_widget(WidgetKind::ImageWidget(ImageWidget::new()));
        self.dirty = true;
        idx
    }
    /// Add a `SpinBox` with the given value range and return its index; marks dirty.
    pub fn add_spin_box(&mut self, min: f64, max: f64) -> usize {
        let idx = self.push_widget(WidgetKind::SpinBox(SpinBox::new(min, max)));
        self.dirty = true;
        idx
    }
    /// Add a `Switch` with the given initial on state and return its index; marks dirty.
    pub fn add_switch(&mut self, on: bool) -> usize {
        let idx = self.push_widget(WidgetKind::Switch(Switch::new(on)));
        self.dirty = true;
        idx
    }
    /// Add a `Badge` with the given count and return its index; marks dirty.
    pub fn add_badge(&mut self, count: u32) -> usize {
        let idx = self.push_widget(WidgetKind::Badge(Badge::new(count)));
        self.mark_dirty_flags(true, false, false, true);
        idx
    }
    /// Add a `CustomWidget` and return its index; marks dirty.
    pub fn add_custom_widget(&mut self) -> usize {
        let idx = self.push_widget(WidgetKind::Custom(CustomWidget::new()));
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
        if !width.is_finite()
            || !height.is_finite()
            || width < 0.0
            || height < 0.0
            || width > self.limits.max_image_width as f32
            || height > self.limits.max_image_height as f32
        {
            return;
        }
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
