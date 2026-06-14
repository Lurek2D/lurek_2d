//! File: tests/rust/unit/color_tests.rs

use lurek2d::color::{gamma_to_linear, linear_to_gamma, Color};

mod sanitization_tests {
    use super::*;

    #[test]
    fn to_u8_treats_non_finite_channels_as_zero() {
        let color = Color::new(f32::NAN, f32::INFINITY, -1.0, 0.5);
        assert_eq!(color.to_u8(), (0, 0, 0, 127));
    }

    #[test]
    fn gamma_to_linear_clamps_non_finite_and_high_inputs() {
        assert_eq!(gamma_to_linear(f32::NAN), 0.0);
        assert!((gamma_to_linear(2.0) - 1.0).abs() < f32::EPSILON);
    }

    #[test]
    fn linear_to_gamma_clamps_non_finite_and_negative_inputs() {
        assert_eq!(linear_to_gamma(f32::NEG_INFINITY), 0.0);
        assert_eq!(linear_to_gamma(-1.0), 0.0);
    }
}
