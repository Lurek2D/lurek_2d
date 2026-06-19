//! This file owns `PostFxEffectType`, the canonical catalog of built-in and custom post-processing identities.
//! It maps stable lowercase names to enum variants so scripts and engine code resolve the same effect repertoire.
//! Debug labels and built-in-name helpers centralize human-readable identifiers without duplicating lookup tables.
//! Default-parameter builders also live here, giving each effect type a consistent scalar starting configuration.
//! The enum separates built-in effects from custom shaders while preserving one shared naming and parsing surface.
//! Open this file when supported effect kinds change; per-instance state and preset recipes live in sibling files.

use super::contract::PostFxParamSchema;
use std::collections::HashMap;
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
/// Enumerates the built-in post-processing effect implementations.
pub enum PostFxEffectType {
    /// Bright-pass glow accumulation.
    Bloom,
    /// General-purpose image blurring.
    Blur,
    /// CRT-style curvature and scan artifact treatment.
    Crt,
    /// Radial light shaft rendering.
    Godrays,
    /// Edge darkening around the viewport.
    Vignette,
    /// Brightness, contrast, and saturation grading.
    ColourGrade,
    /// Chromatic aberration channel offsets.
    Chromatic,
    /// Block-based pixelation.
    Pixelate,
    /// Brown-tinted sepia toning.
    Sepia,
    /// Monochrome luminance conversion.
    Grayscale,
    /// Channel inversion.
    Invert,
    /// Horizontal scanline overlay.
    Scanlines,
    /// Edge detection filter.
    EdgeDetect,
    /// Hue rotation in color space.
    HueShift,
    /// Procedural noise overlay.
    Noise,
    /// Renderer-provided custom shader pass.
    Custom,
    /// Focus-based blur around a focal point.
    DepthOfField,
    /// Multi-sample motion blur.
    MotionBlur,
    /// Palette remapping blend.
    PaletteSwap,
    /// Color lookup-table grading.
    ColorLut,
    /// Water-like screen distortion.
    WaterDistort,
    /// Image sharpening filter.
    Sharpen,
    /// Ordered dithering quantization.
    Dither,
    /// Outline extraction and compositing.
    Outline,
}
/// Name resolution, parameter defaults, and debug utilities for effect types.
impl PostFxEffectType {
    const BLOOM_SCHEMA: &'static [PostFxParamSchema] = &[
        PostFxParamSchema::float("threshold", 0.7, 0.0, 1.0),
        PostFxParamSchema::float("intensity", 1.0, 0.0, 8.0),
    ];
    const BLUR_SCHEMA: &'static [PostFxParamSchema] = &[
        PostFxParamSchema::float("radius", 2.0, 0.0, 64.0),
        PostFxParamSchema::float("strength", 1.0, 0.0, 8.0),
    ];
    const CRT_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("scanline_strength", 0.3, 0.0, 1.0)];
    const GODRAYS_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("intensity", 1.0, 0.0, 8.0)];
    const VIGNETTE_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("strength", 0.5, 0.0, 1.0)];
    const COLOUR_GRADE_SCHEMA: &'static [PostFxParamSchema] = &[
        PostFxParamSchema::float("brightness", 1.0, 0.0, 4.0),
        PostFxParamSchema::float("contrast", 1.0, 0.0, 4.0),
        PostFxParamSchema::float("saturation", 1.0, 0.0, 4.0),
    ];
    const CHROMATIC_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("offset", 2.0, 0.0, 32.0)];
    const PIXELATE_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::integer("block_size", 4.0, 1.0, 512.0)];
    const SEPIA_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("strength", 1.0, 0.0, 1.0)];
    const GRAYSCALE_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("strength", 1.0, 0.0, 1.0)];
    const INVERT_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("strength", 1.0, 0.0, 1.0)];
    const SCANLINES_SCHEMA: &'static [PostFxParamSchema] = &[
        PostFxParamSchema::float("strength", 0.5, 0.0, 1.0),
        PostFxParamSchema::integer("spacing", 4.0, 1.0, 128.0),
    ];
    const EDGE_DETECT_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("strength", 1.0, 0.0, 8.0)];
    const HUE_SHIFT_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("angle", 0.0, -360.0, 360.0)];
    const NOISE_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("strength", 0.1, 0.0, 1.0)];
    const DEPTH_OF_FIELD_SCHEMA: &'static [PostFxParamSchema] = &[
        PostFxParamSchema::float("focus_x", 0.5, 0.0, 1.0),
        PostFxParamSchema::float("focus_y", 0.5, 0.0, 1.0),
        PostFxParamSchema::float("strength", 0.8, 0.0, 4.0),
        PostFxParamSchema::float("radius", 8.0, 0.0, 64.0),
    ];
    const MOTION_BLUR_SCHEMA: &'static [PostFxParamSchema] = &[
        PostFxParamSchema::float("strength", 0.4, 0.0, 1.0),
        PostFxParamSchema::integer("samples", 8.0, 1.0, 64.0),
    ];
    const PALETTE_SWAP_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("mix", 1.0, 0.0, 1.0)];
    const COLOR_LUT_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("strength", 1.0, 0.0, 1.0)];
    const WATER_DISTORT_SCHEMA: &'static [PostFxParamSchema] = &[
        PostFxParamSchema::float("amplitude", 0.005, 0.0, 1.0),
        PostFxParamSchema::float("frequency", 15.0, 0.0, 256.0),
        PostFxParamSchema::float("speed", 2.0, 0.0, 32.0),
    ];
    const SHARPEN_SCHEMA: &'static [PostFxParamSchema] =
        &[PostFxParamSchema::float("strength", 0.5, 0.0, 4.0)];
    const DITHER_SCHEMA: &'static [PostFxParamSchema] = &[
        PostFxParamSchema::integer("palette_size", 8.0, 2.0, 256.0),
        PostFxParamSchema::integer("matrix_size", 4.0, 2.0, 8.0),
    ];
    const OUTLINE_SCHEMA: &'static [PostFxParamSchema] = &[
        PostFxParamSchema::float("color_r", 0.0, 0.0, 1.0),
        PostFxParamSchema::float("color_g", 0.0, 0.0, 1.0),
        PostFxParamSchema::float("color_b", 0.0, 0.0, 1.0),
        PostFxParamSchema::float("thickness", 1.0, 1.0, 32.0),
    ];

    /// Bidirectional mapping from effect variant to its canonical lowercase string.
    const NAME_MAP: &'static [(Self, &'static str)] = &[
        (Self::Bloom, "bloom"),
        (Self::Blur, "blur"),
        (Self::Crt, "crt"),
        (Self::Godrays, "godrays"),
        (Self::Vignette, "vignette"),
        (Self::ColourGrade, "colourgrade"),
        (Self::Chromatic, "chromatic"),
        (Self::Pixelate, "pixelate"),
        (Self::Sepia, "sepia"),
        (Self::Grayscale, "grayscale"),
        (Self::Invert, "invert"),
        (Self::Scanlines, "scanlines"),
        (Self::EdgeDetect, "edgedetect"),
        (Self::HueShift, "hueshift"),
        (Self::Noise, "noise"),
        (Self::Custom, "custom"),
        (Self::DepthOfField, "depthoffield"),
        (Self::MotionBlur, "motionblur"),
        (Self::PaletteSwap, "paletteswap"),
        (Self::ColorLut, "colorlut"),
        (Self::WaterDistort, "waterdistort"),
        (Self::Sharpen, "sharpen"),
        (Self::Dither, "dither"),
        (Self::Outline, "outline"),
    ];
    /// Ordered list of all non-custom built-in effect types.
    const BUILT_IN_TYPES: &'static [Self] = &[
        Self::Bloom,
        Self::Blur,
        Self::Crt,
        Self::Godrays,
        Self::Vignette,
        Self::ColourGrade,
        Self::Chromatic,
        Self::Pixelate,
        Self::Sepia,
        Self::Grayscale,
        Self::Invert,
        Self::Scanlines,
        Self::EdgeDetect,
        Self::HueShift,
        Self::Noise,
        Self::DepthOfField,
        Self::MotionBlur,
        Self::PaletteSwap,
        Self::ColorLut,
        Self::WaterDistort,
        Self::Sharpen,
        Self::Dither,
        Self::Outline,
    ];
    /// Resolves a lowercase built-in effect name into the matching enum entry.
    pub fn from_name(name: &str) -> Option<Self> {
        Self::BUILT_IN_TYPES
            .iter()
            .copied()
            .find(|effect_type| effect_type.name() == name)
    }
    /// Returns the lowercase names for all non-custom built-in effect types.
    pub fn built_in_names() -> Vec<&'static str> {
        Self::BUILT_IN_TYPES
            .iter()
            .map(|effect_type| effect_type.name())
            .collect()
    }
    /// Returns the lowercase canonical name for this effect type.
    pub fn name(&self) -> &'static str {
        Self::NAME_MAP
            .iter()
            .find(|(effect_type, _)| effect_type == self)
            .map(|(_, name)| *name)
            .expect("PostFxEffectType::NAME_MAP must include every enum variant")
    }
    /// Returns the uppercase debug label used in renderer diagnostics.
    pub fn debug_label(&self) -> &'static str {
        match self {
            Self::Vignette => "VIGNETTE",
            Self::Grayscale => "GRAYSCALE",
            Self::Chromatic => "CHROMATIC",
            Self::Blur => "BLUR",
            Self::Pixelate => "PIXELATE",
            Self::Invert => "INVERT",
            Self::Sepia => "SEPIA",
            Self::Scanlines => "SCANLINES",
            Self::Bloom => "BLOOM",
            Self::Crt => "CRT",
            Self::Godrays => "GODRAYS",
            Self::ColourGrade => "COLOUR_GRADE",
            Self::EdgeDetect => "EDGE_DETECT",
            Self::HueShift => "HUE_SHIFT",
            Self::Noise => "NOISE",
            Self::Custom => "CUSTOM",
            Self::DepthOfField => "DEPTH_OF_FIELD",
            Self::MotionBlur => "MOTION_BLUR",
            Self::PaletteSwap => "PALETTE_SWAP",
            Self::ColorLut => "COLOR_LUT",
            Self::WaterDistort => "WATER_DISTORT",
            Self::Sharpen => "SHARPEN",
            Self::Dither => "DITHER",
            Self::Outline => "OUTLINE",
        }
    }
    /// Returns the documented parameter schema for this effect type.
    pub fn param_schema(&self) -> &'static [PostFxParamSchema] {
        match self {
            Self::Bloom => Self::BLOOM_SCHEMA,
            Self::Blur => Self::BLUR_SCHEMA,
            Self::Crt => Self::CRT_SCHEMA,
            Self::Godrays => Self::GODRAYS_SCHEMA,
            Self::Vignette => Self::VIGNETTE_SCHEMA,
            Self::ColourGrade => Self::COLOUR_GRADE_SCHEMA,
            Self::Chromatic => Self::CHROMATIC_SCHEMA,
            Self::Pixelate => Self::PIXELATE_SCHEMA,
            Self::Sepia => Self::SEPIA_SCHEMA,
            Self::Grayscale => Self::GRAYSCALE_SCHEMA,
            Self::Invert => Self::INVERT_SCHEMA,
            Self::Scanlines => Self::SCANLINES_SCHEMA,
            Self::EdgeDetect => Self::EDGE_DETECT_SCHEMA,
            Self::HueShift => Self::HUE_SHIFT_SCHEMA,
            Self::Noise => Self::NOISE_SCHEMA,
            Self::Custom => &[],
            Self::DepthOfField => Self::DEPTH_OF_FIELD_SCHEMA,
            Self::MotionBlur => Self::MOTION_BLUR_SCHEMA,
            Self::PaletteSwap => Self::PALETTE_SWAP_SCHEMA,
            Self::ColorLut => Self::COLOR_LUT_SCHEMA,
            Self::WaterDistort => Self::WATER_DISTORT_SCHEMA,
            Self::Sharpen => Self::SHARPEN_SCHEMA,
            Self::Dither => Self::DITHER_SCHEMA,
            Self::Outline => Self::OUTLINE_SCHEMA,
        }
    }

    /// Looks up one named parameter in this effect type's schema.
    pub fn find_param_schema(&self, name: &str) -> Option<&'static PostFxParamSchema> {
        self.param_schema()
            .iter()
            .find(|schema| schema.name == name)
    }

    /// Returns the default scalar parameter map for this effect type.
    pub fn default_params(&self) -> HashMap<String, f32> {
        self.param_schema()
            .iter()
            .map(|schema| (schema.name.to_string(), schema.default))
            .collect()
    }
}
