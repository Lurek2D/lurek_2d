-- Golden test: ui compare evidence output against golden samples

-- @describe golden: ui evidence comparison
describe("golden: ui evidence comparison", function()
    it("matches ui baselines", function()
        expect_golden_file_match(
            evidence_output_dir("ui") .. "area_chart_stacked_capacity.png",
            "tests/artifacts/baselines/ui/area_chart_stacked_capacity.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "bar_chart_monthly_production.png",
            "tests/artifacts/baselines/ui/bar_chart_monthly_production.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "chart_area_capacity_plan.png",
            "tests/artifacts/baselines/ui/chart_area_capacity_plan.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "chart_bar_quarter_kpi.png",
            "tests/artifacts/baselines/ui/chart_bar_quarter_kpi.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "chart_line_population_growth.png",
            "tests/artifacts/baselines/ui/chart_line_population_growth.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "chart_pie_traffic_sources.png",
            "tests/artifacts/baselines/ui/chart_pie_traffic_sources.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "container_widgets_inspector_scroll_gallery.png",
            "tests/artifacts/baselines/ui/container_widgets_inspector_scroll_gallery.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "form_widgets_account_panel.png",
            "tests/artifacts/baselines/ui/form_widgets_account_panel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_calculator.png",
            "tests/artifacts/baselines/ui/layout_apps_calculator.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_chat_app.png",
            "tests/artifacts/baselines/ui/layout_apps_chat_app.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_dashboard.png",
            "tests/artifacts/baselines/ui/layout_apps_dashboard.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_file_browser.png",
            "tests/artifacts/baselines/ui/layout_apps_file_browser.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_household_finance_lab_tab_01_widgets_api.png",
            "tests/artifacts/baselines/ui/layout_apps_household_finance_lab_tab_01_widgets_api.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_household_finance_lab_tab_02_cashflow.png",
            "tests/artifacts/baselines/ui/layout_apps_household_finance_lab_tab_02_cashflow.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_household_finance_lab_tab_03_categories.png",
            "tests/artifacts/baselines/ui/layout_apps_household_finance_lab_tab_03_categories.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_household_finance_lab_tab_04_members.png",
            "tests/artifacts/baselines/ui/layout_apps_household_finance_lab_tab_04_members.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_household_finance_lab_tab_05_payments.png",
            "tests/artifacts/baselines/ui/layout_apps_household_finance_lab_tab_05_payments.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_household_finance_lab_tab_06_anomalies.png",
            "tests/artifacts/baselines/ui/layout_apps_household_finance_lab_tab_06_anomalies.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_household_finance_lab_tab_07_transactions.png",
            "tests/artifacts/baselines/ui/layout_apps_household_finance_lab_tab_07_transactions.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_household_finance_lab_tab_08_logs.png",
            "tests/artifacts/baselines/ui/layout_apps_household_finance_lab_tab_08_logs.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_login_form.png",
            "tests/artifacts/baselines/ui/layout_apps_login_form.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_media_player.png",
            "tests/artifacts/baselines/ui/layout_apps_media_player.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_notification_center.png",
            "tests/artifacts/baselines/ui/layout_apps_notification_center.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_profile_card.png",
            "tests/artifacts/baselines/ui/layout_apps_profile_card.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_settings_panel.png",
            "tests/artifacts/baselines/ui/layout_apps_settings_panel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_text_editor_toolbar.png",
            "tests/artifacts/baselines/ui/layout_apps_text_editor_toolbar.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_todo_list.png",
            "tests/artifacts/baselines/ui/layout_apps_todo_list.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_apps_wizard_form.png",
            "tests/artifacts/baselines/ui/layout_apps_wizard_form.png"
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
            evidence_output_dir("ui") .. "layout_gallery_contact_sheet.png",
            "tests/artifacts/baselines/ui/layout_gallery_contact_sheet.png"
        )
        expect_golden_text_match(
            evidence_output_dir("ui") .. "layout_gallery_manifest.txt",
            "tests/artifacts/baselines/ui/layout_gallery_manifest.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_card_game_hand.png",
            "tests/artifacts/baselines/ui/layout_games_card_game_hand.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_fps_hud.png",
            "tests/artifacts/baselines/ui/layout_games_fps_hud.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_game_over.png",
            "tests/artifacts/baselines/ui/layout_games_game_over.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_level_select.png",
            "tests/artifacts/baselines/ui/layout_games_level_select.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_main_menu.png",
            "tests/artifacts/baselines/ui/layout_games_main_menu.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_pause_menu.png",
            "tests/artifacts/baselines/ui/layout_games_pause_menu.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_platformer_hud.png",
            "tests/artifacts/baselines/ui/layout_games_platformer_hud.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_racing_hud.png",
            "tests/artifacts/baselines/ui/layout_games_racing_hud.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_roguelike_dungeon_hud.png",
            "tests/artifacts/baselines/ui/layout_games_roguelike_dungeon_hud.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_roguelike_inventory.png",
            "tests/artifacts/baselines/ui/layout_games_roguelike_inventory.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_rpg_character_sheet.png",
            "tests/artifacts/baselines/ui/layout_games_rpg_character_sheet.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_rpg_dialogue.png",
            "tests/artifacts/baselines/ui/layout_games_rpg_dialogue.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_rpg_hud.png",
            "tests/artifacts/baselines/ui/layout_games_rpg_hud.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_rpg_inventory.png",
            "tests/artifacts/baselines/ui/layout_games_rpg_inventory.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_rpg_quest_log.png",
            "tests/artifacts/baselines/ui/layout_games_rpg_quest_log.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_settings_menu.png",
            "tests/artifacts/baselines/ui/layout_games_settings_menu.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_shop_screen.png",
            "tests/artifacts/baselines/ui/layout_games_shop_screen.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_skill_tree.png",
            "tests/artifacts/baselines/ui/layout_games_skill_tree.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_strategy_empire_overview.png",
            "tests/artifacts/baselines/ui/layout_games_strategy_empire_overview.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_strategy_resources.png",
            "tests/artifacts/baselines/ui/layout_games_strategy_resources.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_strategy_tech_tree.png",
            "tests/artifacts/baselines/ui/layout_games_strategy_tech_tree.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_strategy_world_diplomacy.png",
            "tests/artifacts/baselines/ui/layout_games_strategy_world_diplomacy.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_tower_defense_hud.png",
            "tests/artifacts/baselines/ui/layout_games_tower_defense_hud.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_alien_containment.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_alien_containment.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_base_management.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_base_management.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_battlescape.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_battlescape.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_craft_equipment.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_craft_equipment.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_geoscape.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_geoscape.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_interception.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_interception.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_manufacturing.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_manufacturing.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_monthly_report.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_monthly_report.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_research.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_research.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_soldier_equipment.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_soldier_equipment.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_soldier_info.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_soldier_info.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_games_xcom_ufopaedia.png",
            "tests/artifacts/baselines/ui/layout_games_xcom_ufopaedia.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_rpg_inventory_1280x720.png",
            "tests/artifacts/baselines/ui/layout_rpg_inventory_1280x720.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "layout_settings_desktop_1366x768.png",
            "tests/artifacts/baselines/ui/layout_settings_desktop_1366x768.png"
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
            evidence_output_dir("ui") .. "line_chart_dense_signal.png",
            "tests/artifacts/baselines/ui/line_chart_dense_signal.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "navigation_widgets_workspace_shell.png",
            "tests/artifacts/baselines/ui/navigation_widgets_workspace_shell.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "pie_chart_revenue_mix.png",
            "tests/artifacts/baselines/ui/pie_chart_revenue_mix.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "popup_widgets_window_dialog_toast.png",
            "tests/artifacts/baselines/ui/popup_widgets_window_dialog_toast.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "scatter_plot_cluster_points.png",
            "tests/artifacts/baselines/ui/scatter_plot_cluster_points.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "selection_widgets_controls_gallery.png",
            "tests/artifacts/baselines/ui/selection_widgets_controls_gallery.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "structured_widgets_table_tree_picker.png",
            "tests/artifacts/baselines/ui/structured_widgets_table_tree_picker.png"
        )
        expect_golden_file_match(
            evidence_output_dir("ui") .. "visual_widgets_image_nine_patch.png",
            "tests/artifacts/baselines/ui/visual_widgets_image_nine_patch.png"
        )
    end)
end)
test_summary()
