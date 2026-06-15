//! File: tests/rust/unit/color_tests.rs

use lurek2d::color::{gamma_to_linear, linear_to_gamma, Color};

mod sanitization_tests {
    use super::*;

    fn assert_near(expected: f32, actual: f32) {
        assert!(
            (expected - actual).abs() < f32::EPSILON,
            "expected {expected}, got {actual}"
        );
    }

    #[test]
    fn to_u8_treats_non_finite_channels_as_zero() {
        let color = Color::new(f32::NAN, f32::INFINITY, -1.0, 0.5);
        assert_eq!(color.to_u8(), (0, 0, 0, 127));
    }

    #[test]
    fn gamma_to_linear_clamps_non_finite_and_high_inputs() {
        assert_near(0.0, gamma_to_linear(f32::NAN));
        assert_near(1.0, gamma_to_linear(2.0));
    }

    #[test]
    fn linear_to_gamma_clamps_non_finite_and_negative_inputs() {
        assert_near(0.0, linear_to_gamma(f32::NEG_INFINITY));
        assert_near(0.0, linear_to_gamma(-1.0));
    }

    #[test]
    fn from_hex_supports_shorthand_rgb_and_rgba() {
        let rgb = Color::from_hex("#0f8").expect("rgb shorthand should parse");
        assert_eq!(rgb.to_u8(), (0x00, 0xff, 0x88, 0xff));

        let rgba = Color::from_hex("#1a2c").expect("rgba shorthand should parse");
        assert_eq!(rgba.to_u8(), (0x11, 0xaa, 0x22, 0xcc));
    }

    #[test]
    fn from_hex_rejects_invalid_lengths_and_digits() {
        assert!(Color::from_hex("#12").is_none());
        assert!(Color::from_hex("#12345").is_none());
        assert!(Color::from_hex("#xyz").is_none());
    }
}
