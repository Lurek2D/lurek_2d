//! This file owns the lightweight `PostFxStack` preview renderer that turns stack activity into a diagnostic image.
//! It fills a simple image differently when any effect is enabled, giving tools a cheap visual state indicator.
//! Open this file when effect-stack preview semantics change; stack storage and render commands live in siblings.

use super::stack::PostFxStack;
use crate::effect::{PostFxDebugImageLimits, PostFxError};
use crate::image::ImageData;
impl PostFxStack {
    /// Renders a solid-color preview image after validating the output size against explicit limits.
    pub fn try_draw_to_image(
        &self,
        width: u32,
        height: u32,
        limits: &PostFxDebugImageLimits,
    ) -> Result<ImageData, PostFxError> {
        limits.validate(width, height)?;
        Ok(self.draw_to_image(width, height))
    }
    /// Renders a solid-color preview image that reflects whether any stack effects are enabled.
    pub fn draw_to_image(&self, width: u32, height: u32) -> ImageData {
        let mut img = ImageData::new(width, height);
        let has_enabled = self.enabled.iter().any(|&e| e);
        if has_enabled {
            img.fill(45, 20, 65, 255);
        } else {
            img.fill(18, 18, 18, 255);
        }
        img
    }
}
