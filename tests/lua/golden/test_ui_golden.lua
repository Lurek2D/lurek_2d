-- Golden test: ui compare evidence output against golden samples

-- @describe golden: ui evidence comparison
describe("golden: ui evidence comparison", function()
    it("matches ui baselines", function()
        expect_golden_file_match(
            evidence_output_dir("ui") .. "container_widget_inspector_panel.png",
            "tests/artifacts/baselines/ui/container_widget_inspector_panel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "container_widget_scroll_bar.png",
            "tests/artifacts/baselines/ui/container_widget_scroll_bar.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "container_widget_scroll_panel.png",
            "tests/artifacts/baselines/ui/container_widget_scroll_panel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "form_widget_account_panel.png",
            "tests/artifacts/baselines/ui/form_widget_account_panel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "form_widget_plan_panel.png",
            "tests/artifacts/baselines/ui/form_widget_plan_panel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_dashboard_compact_960x540.png",
            "tests/artifacts/baselines/ui/layout_dashboard_compact_960x540.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_dashboard_desktop_1280x720.png",
            "tests/artifacts/baselines/ui/layout_dashboard_desktop_1280x720.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_dashboard_fixture.png",
            "tests/artifacts/baselines/ui/layout_dashboard_fixture.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_diplomacy_fixture.png",
            "tests/artifacts/baselines/ui/layout_diplomacy_fixture.png"
        )
        expect_golden_text_match(
            evidence_output_dir("ui") .. "layout_gallery_manifest.txt",
            "tests/artifacts/baselines/ui/layout_gallery_manifest.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_rpg_inventory_1280x720.png",
            "tests/artifacts/baselines/ui/layout_rpg_inventory_1280x720.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_inventory_fixture.png",
            "tests/artifacts/baselines/ui/layout_inventory_fixture.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_main_menu_fixture.png",
            "tests/artifacts/baselines/ui/layout_main_menu_fixture.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_settings_desktop_1366x768.png",
            "tests/artifacts/baselines/ui/layout_settings_desktop_1366x768.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_settings_fixture.png",
            "tests/artifacts/baselines/ui/layout_settings_fixture.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_settings_ultrawide_1920x1080.png",
            "tests/artifacts/baselines/ui/layout_settings_ultrawide_1920x1080.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_strategy_diplomacy_1400x800.png",
            "tests/artifacts/baselines/ui/layout_strategy_diplomacy_1400x800.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "navigation_widget_dock_panel.png",
            "tests/artifacts/baselines/ui/navigation_widget_dock_panel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "navigation_widget_split_panel.png",
            "tests/artifacts/baselines/ui/navigation_widget_split_panel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "navigation_widget_status_bar.png",
            "tests/artifacts/baselines/ui/navigation_widget_status_bar.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "navigation_widget_tabs.png",
            "tests/artifacts/baselines/ui/navigation_widget_tabs.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "navigation_widget_toolbar.png",
            "tests/artifacts/baselines/ui/navigation_widget_toolbar.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "popup_widget_badge.png",
            "tests/artifacts/baselines/ui/popup_widget_badge.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "popup_widget_dialog.png",
            "tests/artifacts/baselines/ui/popup_widget_dialog.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "popup_widget_menu_bar.png",
            "tests/artifacts/baselines/ui/popup_widget_menu_bar.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "popup_widget_toast.png",
            "tests/artifacts/baselines/ui/popup_widget_toast.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "popup_widget_tooltip.png",
            "tests/artifacts/baselines/ui/popup_widget_tooltip.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "popup_widget_window.png",
            "tests/artifacts/baselines/ui/popup_widget_window.png"
        )
        expect_golden_text_match(
            evidence_output_dir("ui") .. "runtime_input_binding_layout_trace.txt",
            "tests/artifacts/baselines/ui/runtime_input_binding_layout_trace.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "range_widgets_panel.png",
            "tests/artifacts/baselines/ui/range_widgets_panel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "selection_widgets_panel.png",
            "tests/artifacts/baselines/ui/selection_widgets_panel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "structured_widget_accordion.png",
            "tests/artifacts/baselines/ui/structured_widget_accordion.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "structured_widget_color_picker.png",
            "tests/artifacts/baselines/ui/structured_widget_color_picker.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "structured_widget_custom_surface.png",
            "tests/artifacts/baselines/ui/structured_widget_custom_surface.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "structured_widget_table.png",
            "tests/artifacts/baselines/ui/structured_widget_table.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "structured_widget_tree_view.png",
            "tests/artifacts/baselines/ui/structured_widget_tree_view.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "visual_widget_image.png",
            "tests/artifacts/baselines/ui/visual_widget_image.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "visual_widget_nine_patch.png",
            "tests/artifacts/baselines/ui/visual_widget_nine_patch.png"
        )
    end)
end)
test_summary()
