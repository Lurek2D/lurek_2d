//! File: tests/rust/unit/terminal_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

// â”€â”€ cell â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod cell_tests {
    use lurek2d::terminal::TCell;

    #[test]
    fn default_cell_is_space() {
        let cell = TCell::default();
        assert_eq!(cell.ch, b' ' as u32);
    }

    #[test]
    fn cell_clone_eq() {
        let a = TCell::default();
        let b = a;
        assert_eq!(a, b);
    }
}

// â”€â”€ ansi â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod ansi_tests {
    use lurek2d::terminal::ansi::{parse_ansi_spans, strip_ansi_codes};

    #[test]
    fn strip_removes_color_codes() {
        let s = "\x1b[31mHello\x1b[0m world";
        assert_eq!(strip_ansi_codes(s), "Hello world");
    }

    #[test]
    fn strip_empty_sequence() {
        let s = "\x1b[mText";
        assert_eq!(strip_ansi_codes(s), "Text");
    }

    #[test]
    fn parse_spans_plain_text_becomes_single_span() {
        let spans = parse_ansi_spans("hello");
        assert_eq!(spans.len(), 1);
        assert_eq!(spans[0].text, "hello");
        assert!(spans[0].fg.is_none());
    }

    #[test]
    fn parse_spans_red_text_has_correct_color() {
        let spans = parse_ansi_spans("\x1b[31mred\x1b[0m");
        assert!(!spans.is_empty());
        let red_span = spans.iter().find(|s| s.text == "red").unwrap();
        assert!(red_span.fg.is_some());
        assert_eq!(red_span.fg.as_ref().unwrap().r, 170);
    }

    #[test]
    fn parse_spans_bold_flag() {
        let spans = parse_ansi_spans("\x1b[1mBold\x1b[0m");
        let bold_span = spans.iter().find(|s| s.text == "Bold").unwrap();
        assert!(bold_span.bold);
    }

    #[test]
    fn parse_spans_reset_clears_color() {
        let spans = parse_ansi_spans("\x1b[31mred\x1b[0mnormal");
        let normal_span = spans.iter().find(|s| s.text == "normal").unwrap();
        assert!(normal_span.fg.is_none());
    }

    #[test]
    fn parse_spans_supports_256_fg_color() {
        let spans = parse_ansi_spans("\x1b[38;5;196mhot\x1b[0m");
        let hot = spans.iter().find(|s| s.text == "hot").unwrap();
        let fg = hot.fg.as_ref().unwrap();
        assert_eq!((fg.r, fg.g, fg.b), (255, 0, 0));
    }

    #[test]
    fn parse_spans_supports_truecolor_bg() {
        let spans = parse_ansi_spans("\x1b[48;2;10;20;30mcell\x1b[0m");
        let cell = spans.iter().find(|s| s.text == "cell").unwrap();
        let bg = cell.bg.as_ref().unwrap();
        assert_eq!((bg.r, bg.g, bg.b), (10, 20, 30));
    }
}

// â”€â”€ widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod widget_tests {
    use lurek2d::terminal::Widget;
    use lurek2d::terminal::{BorderStyle, WidgetBase};

    #[test]
    fn border_style_roundtrip() {
        for name in &["single", "double", "ascii"] {
            let bs = BorderStyle::from_str_name(name).unwrap();
            assert_eq!(bs.as_str(), *name);
        }
    }

    #[test]
    fn border_style_unknown_returns_none() {
        assert!(BorderStyle::from_str_name("dashed").is_none());
    }

    #[test]
    fn widget_base_position_1based_roundtrip() {
        let mut base = WidgetBase::new(5, 10, 20, 15);
        assert_eq!(base.position_1based(), (6, 11));
        base.set_position_1based(3, 7);
        assert_eq!(base.x, 2);
        assert_eq!(base.y, 6);
    }

    #[test]
    fn label_width_and_textbox_max_length_handle_unicode_chars() {
        let label = Widget::new_label(1, 1, "🙂");
        assert_eq!(label.base.width, 1);

        let mut textbox = Widget::new_text_box(1, 1, 8);
        textbox.set_text("ą🙂żx".to_string()).unwrap();
        textbox.set_max_length(3).unwrap();
        assert_eq!(textbox.get_text().unwrap(), "ą🙂ż");
    }
}

// â”€â”€ terminal_state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod terminal_state_tests {
    use lurek2d::terminal::{
        Terminal, TerminalError, TerminalLimits, TerminalWidgetValidationError, Widget, WidgetKind,
    };

    #[test]
    fn textbox_backspace_removes_whole_unicode_character() {
        let mut terminal = Terminal::new(20, 4);
        let textbox_index = terminal.add_widget(Widget::new_text_box(1, 1, 12));
        terminal.set_focus(Some(textbox_index));

        assert!(terminal.textinput("A🙂B"));
        assert!(terminal.keypressed("left"));
        assert!(terminal.keypressed("backspace"));

        let textbox = terminal.get_widget(textbox_index).unwrap();
        assert_eq!(textbox.get_text().unwrap(), "AB");
    }

    #[test]
    fn textbox_ctrl_clipboard_shortcuts_copy_cut_and_paste() {
        let mut terminal = Terminal::new(20, 4);
        let textbox_index = terminal.add_widget(Widget::new_text_box(1, 1, 20));
        terminal.set_focus(Some(textbox_index));

        assert!(terminal.textinput("alpha beta"));
        assert!(terminal.keypressed("ctrl+a"));
        assert!(terminal.keypressed("ctrl+c"));
        assert!(terminal.keypressed("ctrl+x"));

        let textbox = terminal.get_widget(textbox_index).unwrap();
        assert_eq!(textbox.get_text().unwrap(), "");

        assert!(terminal.keypressed("ctrl+v"));
        let textbox = terminal.get_widget(textbox_index).unwrap();
        assert_eq!(textbox.get_text().unwrap(), "alpha beta");
    }

    #[test]
    fn textbox_ctrl_word_shortcuts_delete_word_chunks() {
        let mut terminal = Terminal::new(20, 4);
        let textbox_index = terminal.add_widget(Widget::new_text_box(1, 1, 20));
        terminal.set_focus(Some(textbox_index));

        assert!(terminal.textinput("alpha beta gamma"));
        assert!(terminal.keypressed("ctrl+backspace"));
        let textbox = terminal.get_widget(textbox_index).unwrap();
        assert_eq!(textbox.get_text().unwrap(), "alpha beta ");

        assert!(terminal.keypressed("home"));
        assert!(terminal.keypressed("ctrl+delete"));
        let textbox = terminal.get_widget(textbox_index).unwrap();
        assert_eq!(textbox.get_text().unwrap(), " beta ");
    }

    #[test]
    fn textbox_partial_paste_to_max_length() {
        let mut terminal = Terminal::new(20, 4);
        let source_index = terminal.add_widget(Widget::new_text_box(1, 1, 8));
        let target_index = terminal.add_widget(Widget::new_text_box(1, 2, 8));
        terminal
            .get_widget_mut(target_index)
            .unwrap()
            .set_max_length(5)
            .unwrap();

        terminal.set_focus(Some(source_index));
        assert!(terminal.textinput("WXYZ"));
        assert!(terminal.keypressed("ctrl+a"));
        assert!(terminal.keypressed("ctrl+c"));

        terminal.set_focus(Some(target_index));
        assert!(terminal.textinput("abc"));
        assert!(terminal.keypressed("ctrl+v"));

        let textbox = terminal.get_widget(target_index).unwrap();
        assert_eq!(textbox.get_text().unwrap(), "abcWX");
    }

    #[test]
    fn terminal_try_set_rejects_invalid_codepoint_and_nan_color() {
        let mut terminal = Terminal::new(8, 4);
        assert!(matches!(
            terminal.try_set(1, 1, 0xD800, [1.0, 1.0, 1.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
            Err(TerminalError::InvalidCodepoint { .. })
        ));
        assert!(matches!(
            terminal.try_set(
                1,
                1,
                b'A' as u32,
                [f32::NAN, 1.0, 1.0, 1.0],
                [0.0, 0.0, 0.0, 0.0]
            ),
            Err(TerminalError::InvalidColor)
        ));
    }

    #[test]
    fn terminal_oob_try_set_reports_error() {
        let mut terminal = Terminal::new(4, 2);
        assert!(matches!(
            terminal.try_set(
                9,
                1,
                b'A' as u32,
                [1.0, 1.0, 1.0, 1.0],
                [0.0, 0.0, 0.0, 0.0]
            ),
            Err(TerminalError::OutOfBoundsCell { col: 9, row: 1 })
        ));
    }

    #[test]
    fn panel_child_cycle_detected() {
        let mut terminal = Terminal::new(20, 8);
        let parent = terminal.add_widget(Widget::new_panel(1, 1, 10, 4));
        let child = terminal.add_widget(Widget::new_panel(2, 2, 8, 3));

        if let WidgetKind::Panel { children } = &mut terminal.get_widget_mut(parent).unwrap().kind {
            children.push(child);
        }
        if let WidgetKind::Panel { children } = &mut terminal.get_widget_mut(child).unwrap().kind {
            children.push(parent);
        }

        let errors = terminal.validate_widgets();
        assert!(errors.iter().any(|error| matches!(
            error,
            TerminalWidgetValidationError::Cycle {
                panel_index,
                child_index
            } if *panel_index == parent && *child_index == child
        )));
    }

    #[test]
    fn focus_skips_hidden_disabled_widgets() {
        let mut terminal = Terminal::new(20, 6);
        let first = terminal.add_widget(Widget::new_button(1, 1, 6, 1, "One"));
        let hidden = terminal.add_widget(Widget::new_button(1, 2, 6, 1, "Two"));
        let disabled = terminal.add_widget(Widget::new_button(1, 3, 6, 1, "Three"));
        let last = terminal.add_widget(Widget::new_button(1, 4, 6, 1, "Four"));

        terminal.get_widget_mut(hidden).unwrap().base.visible = false;
        terminal.get_widget_mut(disabled).unwrap().base.enabled = false;
        terminal.set_focus(Some(first));

        assert!(terminal.keypressed("tab"));
        assert_eq!(terminal.get_focused(), Some(last));
        assert!(terminal.keypressed("shift+tab"));
        assert_eq!(terminal.get_focused(), Some(first));
    }

    #[test]
    fn clipboard_limit_enforced() {
        let mut terminal = Terminal::new(20, 6);
        let mut limits = TerminalLimits::default();
        limits.max_clipboard_chars = 4;
        terminal.set_limits(limits);

        let source = terminal.add_widget(Widget::new_text_box(1, 1, 12));
        let target = terminal.add_widget(Widget::new_text_box(1, 2, 12));

        terminal.set_focus(Some(source));
        assert!(terminal.textinput("alphabet"));
        assert!(terminal.keypressed("ctrl+a"));
        assert!(terminal.keypressed("ctrl+c"));
        assert!(terminal.keypressed("ctrl+x"));

        terminal.set_focus(Some(target));
        assert!(terminal.keypressed("ctrl+v"));

        let textbox = terminal.get_widget(target).unwrap();
        assert_eq!(textbox.get_text().unwrap(), "alph");
    }

    #[test]
    fn terminal_rejects_or_truncates_giant_line() {
        let mut terminal = Terminal::new(20, 6);
        let mut limits = TerminalLimits::default();
        limits.max_line_chars = 4;
        limits.max_history_entry_chars = 5;
        terminal.set_limits(limits);

        terminal.push_scrollback("abcdef");
        assert_eq!(terminal.get_scrollback(0, 1), vec!["abcd"]);
        assert!(matches!(
            terminal.try_push_scrollback("abcdef"),
            Err(TerminalError::TextTooLong { len: 6, limit: 4 })
        ));

        terminal.push_cmd_history("history!");
        assert_eq!(terminal.prev_cmd(), Some("histo"));
        assert!(matches!(
            terminal.try_push_cmd_history("history!"),
            Err(TerminalError::HistoryEntryTooLong { len: 8, limit: 5 })
        ));
    }
}

// â”€â”€ render â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod render_tests {
    use lurek2d::render::{DrawMode, RenderCommand};
    use lurek2d::runtime::resource_keys::FontKey;
    use lurek2d::terminal::{Terminal, Widget};
    use slotmap::KeyData;

    fn dummy_font() -> FontKey {
        FontKey::from(KeyData::from_ffi(1))
    }

    fn has_pixel_matching(
        img: &lurek2d::image::ImageData,
        matches: impl Fn(u8, u8, u8, u8) -> bool,
    ) -> bool {
        for y in 0..img.height() {
            for x in 0..img.width() {
                if let Some((r, g, b, a)) = img.get_pixel(x, y) {
                    if matches(r, g, b, a) {
                        return true;
                    }
                }
            }
        }
        false
    }

    fn is_cyan_pixel(pixel: Option<(u8, u8, u8, u8)>) -> bool {
        matches!(pixel, Some((r, g, b, _)) if r < 40 && g > 180 && b > 180)
    }

    #[test]
    fn generate_render_commands_empty_terminal_returns_empty() {
        let t = Terminal::new(4, 2);
        let cmds = t.generate_render_commands(dummy_font(), 8.0, 16.0, 1.0);
        assert!(cmds.is_empty(), "blank terminal should emit no commands");
    }

    #[test]
    fn generate_render_commands_single_char_emits_color_and_print() {
        let mut t = Terminal::new(4, 2);
        t.set(
            1,
            1,
            b'A' as u32,
            [1.0, 1.0, 1.0, 1.0],
            [0.0, 0.0, 0.0, 0.0],
        );
        let cmds = t.generate_render_commands(dummy_font(), 8.0, 16.0, 1.0);
        assert_eq!(cmds.len(), 2, "SetColor + Print for one non-space cell");
        assert!(matches!(cmds[0], RenderCommand::SetColor(_, _, _, _)));
        assert!(matches!(cmds[1], RenderCommand::Print { .. }));
    }

    #[test]
    fn build_render_commands_button_emits_background_and_label() {
        let mut terminal = Terminal::new(12, 5);
        terminal.add_widget(Widget::new_button(2, 2, 8, 3, "OK"));

        let cmds = terminal.build_render_commands(0.0, 0.0, 8.0, 16.0, dummy_font());

        let has_background = cmds.iter().any(|cmd| {
            matches!(
                cmd,
                RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    ..
                }
            )
        });
        let has_label = cmds
            .iter()
            .any(|cmd| matches!(cmd, RenderCommand::Print { text, .. } if text.contains("OK")));
        let has_frame = cmds.iter().any(|cmd| {
            matches!(cmd, RenderCommand::Print { text, .. } if text.contains('\u{2524}') || text.contains('\u{2514}'))
        });
        assert!(has_background, "button should emit a visible background");
        assert!(has_label, "button should emit its label");
        assert!(has_frame, "button should emit a shaded frame");
    }

    #[test]
    fn generate_render_commands_includes_widget_backgrounds() {
        let mut terminal = Terminal::new(10, 4);
        terminal.add_widget(Widget::new_panel(1, 1, 10, 4));

        let cmds = terminal.generate_render_commands(dummy_font(), 8.0, 16.0, 1.0);

        assert!(
            cmds.iter()
                .any(|cmd| matches!(cmd, RenderCommand::Rectangle { .. })),
            "panel widget should render through the terminal helper path"
        );
    }

    #[test]
    fn draw_to_image_correct_dimensions() {
        let t = Terminal::new(8, 4);
        let img = t.draw_to_image(160, 80);
        assert_eq!(img.width(), 160);
        assert_eq!(img.height(), 80);
    }

    #[test]
    fn draw_to_image_non_space_cell_writes_pixels() {
        let mut t = Terminal::new(2, 2);
        t.set(
            1,
            1,
            b'X' as u32,
            [1.0, 0.0, 0.0, 1.0],
            [0.0, 0.0, 0.0, 0.0],
        );
        let img = t.draw_to_image(64, 32);
        assert!(
            has_pixel_matching(&img, |r, g, b, _| r > 100 && g < 50 && b < 50),
            "expected red glyph pixels"
        );
    }

    #[test]
    fn draw_to_image_includes_widget_background_pixels() {
        let mut terminal = Terminal::new(4, 2);
        terminal.add_widget(Widget::new_button(1, 1, 4, 1, "Go"));

        let img = terminal.draw_to_image(40, 20);

        assert!(
            has_pixel_matching(&img, |r, g, b, _| r > 20 || g > 20 || b > 35),
            "button widget should tint the output image"
        );
    }

    #[test]
    fn draw_to_image_rasterizes_box_drawing_as_continuous_strokes() {
        let mut terminal = Terminal::new(4, 3);
        let fg = [0.0, 1.0, 1.0, 1.0];
        let bg = [0.0, 0.0, 0.0, 0.0];
        for (col, ch) in ['┌', '─', '─', '┐'].into_iter().enumerate() {
            terminal.set(col + 1, 1, ch as u32, fg, bg);
        }
        terminal.set(1, 2, '│' as u32, fg, bg);
        terminal.set(4, 2, '│' as u32, fg, bg);
        for (col, ch) in ['└', '─', '─', '┘'].into_iter().enumerate() {
            terminal.set(col + 1, 3, ch as u32, fg, bg);
        }

        let img = terminal.draw_to_image(80, 60);

        for x in [10, 20, 39, 59, 69] {
            assert!(
                is_cyan_pixel(img.get_pixel(x, 10)),
                "expected continuous top stroke at x={x}"
            );
        }
        for y in [10, 20, 39, 49] {
            assert!(
                is_cyan_pixel(img.get_pixel(10, y)),
                "expected continuous left stroke at y={y}"
            );
        }
    }

    #[test]
    fn draw_to_image_rasterizes_ascii_frames_when_cells_form_a_frame() {
        let mut terminal = Terminal::new(4, 3);
        let fg = [0.0, 1.0, 1.0, 1.0];
        let bg = [0.0, 0.0, 0.0, 0.0];
        for (col, ch) in ['+', '-', '-', '+'].into_iter().enumerate() {
            terminal.set(col + 1, 1, ch as u32, fg, bg);
        }
        terminal.set(1, 2, '|' as u32, fg, bg);
        terminal.set(4, 2, '|' as u32, fg, bg);
        for (col, ch) in ['+', '-', '-', '+'].into_iter().enumerate() {
            terminal.set(col + 1, 3, ch as u32, fg, bg);
        }

        let img = terminal.draw_to_image(80, 60);

        assert!(is_cyan_pixel(img.get_pixel(20, 10)));
        assert!(is_cyan_pixel(img.get_pixel(39, 10)));
        assert!(is_cyan_pixel(img.get_pixel(10, 39)));
    }

    #[test]
    fn draw_to_image_rasterizes_chart_markers_as_shapes() {
        let mut terminal = Terminal::new(3, 1);
        let fg = [0.0, 1.0, 1.0, 1.0];
        let bg = [0.0, 0.0, 0.0, 0.0];
        terminal.set(1, 1, '█' as u32, fg, bg);
        terminal.set(2, 1, '•' as u32, fg, bg);
        terminal.set(3, 1, '⣿' as u32, fg, bg);

        let img = terminal.draw_to_image(60, 20);

        assert!(
            is_cyan_pixel(img.get_pixel(10, 10)),
            "block marker should fill its cell"
        );
        assert!(
            is_cyan_pixel(img.get_pixel(30, 10)),
            "dot marker should fill the cell center"
        );
        assert!(
            is_cyan_pixel(img.get_pixel(46, 4)),
            "braille marker should draw dot geometry"
        );
    }

    #[test]
    fn repeated_render_helpers_keep_composed_output_stable() {
        let mut terminal = Terminal::new(6, 3);
        terminal.set(
            1,
            1,
            b'Z' as u32,
            [0.8, 0.7, 0.2, 1.0],
            [0.1, 0.1, 0.1, 1.0],
        );
        terminal.add_widget(Widget::new_panel(1, 1, 6, 3));
        terminal.add_widget(Widget::new_button(2, 2, 3, 1, "OK"));

        let first_commands = terminal.generate_render_commands(dummy_font(), 8.0, 16.0, 1.0);
        let second_commands = terminal.generate_render_commands(dummy_font(), 8.0, 16.0, 1.0);
        let first_debug: Vec<String> = first_commands
            .iter()
            .map(|cmd| format!("{:?}", cmd))
            .collect();
        let second_debug: Vec<String> = second_commands
            .iter()
            .map(|cmd| format!("{:?}", cmd))
            .collect();
        assert_eq!(first_debug, second_debug);

        let first_image = terminal.draw_to_image(60, 30);
        let second_image = terminal.draw_to_image(60, 30);
        for y in [0, 15, 29] {
            for x in [0, 20, 59] {
                assert_eq!(first_image.get_pixel(x, y), second_image.get_pixel(x, y));
            }
        }
    }

    #[test]
    fn large_list_renders_visible_rows_only() {
        let mut terminal = Terminal::new(16, 6);
        let mut list = Widget::new_list(1, 1, 12, 2);
        for item in ["one", "two", "three", "four", "five"] {
            list.add_item(item.to_string()).unwrap();
        }
        terminal.add_widget(list);

        let _ = terminal.build_render_commands(0.0, 0.0, 8.0, 16.0, dummy_font());
        let stats = terminal.render_stats();

        assert_eq!(stats.list_items_drawn, 2);
        assert_eq!(stats.list_items_skipped, 3);
    }
}

// â”€â”€ completion â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod completion_tests {
    use lurek2d::terminal::completion::CompletionEngine;

    #[test]
    fn empty_engine_returns_no_completions() {
        let e = CompletionEngine::new();
        assert!(e.completions_for("he").is_empty());
    }

    #[test]
    fn single_match_returned() {
        let mut e = CompletionEngine::new();
        e.add_candidate("help");
        assert_eq!(e.completions_for("hel"), vec!["help"]);
    }

    #[test]
    fn multiple_matches_sorted() {
        let mut e = CompletionEngine::new();
        e.add_candidate("hello");
        e.add_candidate("help");
        let got = e.completions_for("hel");
        assert_eq!(got, vec!["hello", "help"]);
    }

    #[test]
    fn next_completion_cycles_on_repeated_calls() {
        let mut e = CompletionEngine::new();
        e.add_candidate("hello");
        e.add_candidate("help");
        let first = e.next_completion("hel").unwrap();
        let second = e.next_completion("hel").unwrap();
        assert_ne!(first, second);
    }

    #[test]
    fn next_completion_resets_on_prefix_change() {
        let mut e = CompletionEngine::new();
        e.add_candidate("hello");
        e.add_candidate("world");
        let _ = e.next_completion("hel");
        let w = e.next_completion("wor").unwrap();
        assert_eq!(w, "world");
    }

    #[test]
    fn remove_candidate_removes_it() {
        let mut e = CompletionEngine::new();
        e.add_candidate("help");
        e.remove_candidate("help");
        assert!(e.completions_for("hel").is_empty());
    }
}
