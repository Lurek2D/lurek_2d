use lurek2d::font::bitmap_font::{BitmapFont, BitmapFontAtlas, FIRST_CODEPOINT, LAST_CODEPOINT};
use lurek2d::font::metrics::{measure_line, GlyphMetrics};
use lurek2d::font::FontRegistry;

fn dummy_font(size: u32, bold: bool, advance_width: f32) -> BitmapFont {
    let atlas = BitmapFontAtlas {
        width: 128,
        height: 128,
        cell_width: 8,
        cell_height: 12,
        columns: 16,
    };
    let glyph = GlyphMetrics {
        advance_width,
        bearing_x: 0.0,
        bearing_y: 0.0,
        width: 8,
        height: 12,
        uv_x: 0.0,
        uv_y: 0.0,
        uv_w: 1.0,
        uv_h: 1.0,
    };
    BitmapFont::new(
        atlas,
        vec![glyph; (LAST_CODEPOINT - FIRST_CODEPOINT + 1) as usize],
        size,
        bold,
        14.0,
    )
}

#[test]
fn replacing_font_name_updates_lookup_without_stale_entries() {
    let mut registry = FontRegistry::new();
    registry.register("ui", dummy_font(12, false, 6.0));
    registry.register("body", dummy_font(16, false, 7.0));
    registry.register("ui", dummy_font(20, true, 8.0));

    let listed = registry.list_fonts();
    assert_eq!(listed.len(), 2);
    assert_eq!(listed[0].name, "ui");
    assert_eq!(listed[0].size, 20);
    assert_eq!(listed[1].name, "body");

    let ui = registry
        .get_by_name("ui")
        .expect("replacement should be present");
    assert_eq!(ui.point_size(), 20);
    assert!(ui.is_bold());
}

#[test]
fn default_font_keeps_original_name_slot_after_replacement() {
    let mut registry = FontRegistry::new();
    registry.register("ui", dummy_font(12, false, 6.0));
    registry.register("body", dummy_font(16, false, 7.0));
    registry.register("ui", dummy_font(18, false, 9.0));

    let default_font = registry.default_font().expect("default font should exist");
    assert_eq!(default_font.point_size(), 18);
}

#[test]
fn registry_fonts_support_measurement_and_glyph_queries() {
    let mut registry = FontRegistry::new();
    let handle = registry.register("ui", dummy_font(14, false, 5.5));
    let font = registry.get(&handle).expect("font should exist");

    assert!(font.contains_glyph('A' as u32));
    assert!(font.glyph_info('A' as u32).is_some());

    let (width, height) = measure_line(font, "AA", 1.0);
    assert!((width - 11.0).abs() < 0.001);
    assert!((height - 14.0).abs() < 0.001);
}
