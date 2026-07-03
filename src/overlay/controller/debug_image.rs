//! Owns the overlay controller debug image implementation for the overlay subsystem and keeps rules local here.
//! Keeps overlay state, effects, and presentation helpers ownership so helpers stay close to invariants this file updates.
//! Defines how overlay controller debug image data is validated, transformed, or stored before systems consume it.
//! Separates overlay controller debug image behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where overlay code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing overlay controller debug image defaults, lifecycle handling, validation, or data rules.
//! Open this owner when overlay debug imagery changes even if flash, shake, and fade state stay valid.

use super::*;

impl Overlay {
    /// Renders a debug image showing current flash, shake, and fade state.
    pub fn draw_state_to_image(&self, width: u32, height: u32) -> ImageData {
        self.try_draw_state_to_image(width, height)
            .unwrap_or_else(|_| ImageData::new(1, 1))
    }

    /// Renders a checked debug image showing current flash, shake, and fade state.
    pub fn try_draw_state_to_image(
        &self,
        width: u32,
        height: u32,
    ) -> Result<ImageData, OverlayError> {
        checked_debug_image_request(self.limits.debug_images, width, height)?;
        let sanitized = self.sanitized_clone();
        let mut img = ImageData::new(width, height);
        img.fill(15, 15, 25, 255);
        let section_h = height / 3;
        let flash_alpha = sanitized.get_flash_alpha();
        let fr = (sanitized.flash.color[0] * 255.0) as u8;
        let fg = (sanitized.flash.color[1] * 255.0) as u8;
        let fb = (sanitized.flash.color[2] * 255.0) as u8;
        let bar_w = (flash_alpha * width as f32) as u32;
        img.draw_rect(
            0,
            0,
            bar_w,
            section_h,
            fr,
            fg,
            fb,
            (flash_alpha * 200.0) as u8,
        );
        img.draw_label("FLASH", 4, 4, 220, 220, 230);
        let (sx, sy) = sanitized.get_shake_offset();
        let cy = section_h as i32 + section_h as i32 / 2;
        let cx = width as i32 / 2;
        img.draw_circle(cx + sx as i32, cy + sy as i32, 8, 80, 200, 255, 255);
        img.draw_label("SHAKE", 4, section_h as i32 + 4, 220, 220, 230);
        let fade_y = (section_h * 2) as i32;
        let fade_alpha = sanitized.fade.color[3];
        let fade_val = (fade_alpha * 255.0) as u8;
        img.draw_rect(0, fade_y, width, section_h, 0, 0, 0, fade_val);
        img.draw_label("FADE", 4, fade_y + 4, 220, 220, 230);
        Ok(img)
    }

    #[allow(clippy::too_many_arguments)]
    /// Renders a frame strip showing the time evolution of a flash overlay.
    pub fn draw_flash_sequence_to_image(
        &mut self,
        r: f32,
        g: f32,
        b: f32,
        alpha: f32,
        duration: f32,
        steps: &[f32],
        panel_w: u32,
        height: u32,
    ) -> ImageData {
        self.try_draw_flash_sequence_to_image(r, g, b, alpha, duration, steps, panel_w, height)
            .unwrap_or_else(|_| ImageData::new(1, 1))
    }

    #[allow(clippy::too_many_arguments)]
    /// Renders a checked frame strip showing the time evolution of a flash overlay.
    pub fn try_draw_flash_sequence_to_image(
        &mut self,
        r: f32,
        g: f32,
        b: f32,
        alpha: f32,
        duration: f32,
        steps: &[f32],
        panel_w: u32,
        height: u32,
    ) -> Result<ImageData, OverlayError> {
        let total_w = panel_w.checked_mul(steps.len() as u32).ok_or({
            OverlayError::DebugImageTooLarge {
                width: panel_w,
                height,
                pixels: u64::MAX,
                bytes: usize::MAX,
            }
        })?;
        if let Err(err) = checked_debug_image_request(self.limits.debug_images, total_w, height) {
            self.diagnostics.debug_image_rejections += 1;
            return Err(err);
        }
        self.trigger_flash(r, g, b, alpha, duration);
        let mut img = ImageData::new(total_w, height);
        img.fill(15, 15, 25, 255);
        for (frame, dt) in steps.iter().enumerate() {
            if *dt > 0.0 {
                self.update(*dt);
            }
            let flash_alpha = self.get_flash_alpha();
            let ox = (frame as u32 * panel_w) as i32;
            for y in 0..height {
                for x in 0..panel_w {
                    let base_r = 40u8;
                    let base_g = 60u8;
                    let base_b = 80u8;
                    let pr = (base_r as f32 + (255.0 - base_r as f32) * flash_alpha) as u8;
                    let pg = (base_g as f32 + (0.0 - base_g as f32) * flash_alpha).max(0.0) as u8;
                    let pb = (base_b as f32 + (0.0 - base_b as f32) * flash_alpha).max(0.0) as u8;
                    img.set_pixel((ox as u32) + x, y, pr, pg, pb, 255);
                }
            }
        }
        Ok(img)
    }

    /// Renders a debug image showing a series of shake offsets as a trail.
    pub fn draw_shake_trail_to_image(offsets: &[(f32, f32)], width: u32, height: u32) -> ImageData {
        Self::try_draw_shake_trail_to_image(offsets, width, height)
            .unwrap_or_else(|_| ImageData::new(1, 1))
    }

    /// Renders a checked debug image showing a series of shake offsets as a trail.
    pub fn try_draw_shake_trail_to_image(
        offsets: &[(f32, f32)],
        width: u32,
        height: u32,
    ) -> Result<ImageData, OverlayError> {
        checked_debug_image_request(OverlayImageLimits::default(), width, height)?;
        let mut img = ImageData::new(width, height);
        img.fill(15, 15, 25, 255);
        let cx = width as i32 / 2;
        let cy = height as i32 / 2;
        img.draw_line(cx - 20, cy, cx + 20, cy, 60, 60, 80, 255);
        img.draw_line(cx, cy - 20, cx, cy + 20, 60, 60, 80, 255);
        for (i, &(ox, oy)) in offsets.iter().enumerate() {
            let t = i as f32 / offsets.len().max(1) as f32;
            let r = (100.0 + t * 155.0) as u8;
            let g = (200.0 - t * 100.0) as u8;
            let px = cx + ox as i32;
            let py = cy + oy as i32;
            if px >= 0 && py >= 0 && (px as u32) < width && (py as u32) < height {
                img.draw_circle(px, py, 3, r, g, 120, 200);
            }
        }
        Ok(img)
    }

    /// Renders a frame strip showing fade alpha samples across multiple steps.
    pub fn draw_fade_transition_to_image(steps: &[f32], panel_w: u32, height: u32) -> ImageData {
        Self::try_draw_fade_transition_to_image(steps, panel_w, height)
            .unwrap_or_else(|_| ImageData::new(1, 1))
    }

    /// Renders a checked frame strip showing fade alpha samples across multiple steps.
    pub fn try_draw_fade_transition_to_image(
        steps: &[f32],
        panel_w: u32,
        height: u32,
    ) -> Result<ImageData, OverlayError> {
        let total_w = panel_w.checked_mul(steps.len() as u32).ok_or({
            OverlayError::DebugImageTooLarge {
                width: panel_w,
                height,
                pixels: u64::MAX,
                bytes: usize::MAX,
            }
        })?;
        checked_debug_image_request(OverlayImageLimits::default(), total_w, height)?;
        let mut img = ImageData::new(total_w, height);
        img.fill(15, 15, 25, 255);
        for (i, &alpha) in steps.iter().enumerate() {
            let ox = i as u32 * panel_w;
            for y in 0..height {
                for x in 0..panel_w {
                    let base = 180u8;
                    let v = (base as f32 * (1.0 - alpha.clamp(0.0, 1.0))) as u8;
                    img.set_pixel(ox + x, y, v, v, v, 255);
                }
            }
        }
        Ok(img)
    }

    /// Renders a debug panel previewing flash, shake, fade, and lightning triggers.
    pub fn draw_trigger_panel_to_image(&mut self, width: u32, height: u32) -> ImageData {
        self.try_draw_trigger_panel_to_image(width, height)
            .unwrap_or_else(|_| ImageData::new(1, 1))
    }

    /// Renders a checked debug panel previewing flash, shake, fade, and lightning triggers.
    pub fn try_draw_trigger_panel_to_image(
        &mut self,
        width: u32,
        height: u32,
    ) -> Result<ImageData, OverlayError> {
        if let Err(err) = checked_debug_image_request(self.limits.debug_images, width, height) {
            self.diagnostics.debug_image_rejections += 1;
            return Err(err);
        }
        let mut img = ImageData::new(width, height);
        img.fill(20, 18, 28, 255);
        let half_w = width / 2;
        let half_h = height / 2;
        self.trigger_flash(1.0, 0.0, 0.0, 0.8, 0.5);
        img.draw_rect(2, 2, half_w - 4, half_h - 4, 40, 10, 10, 255);
        img.draw_label("FLASH", 6, 6, 255, 80, 80);
        for dy in 0..(half_h - 30) {
            let t = 1.0 - (dy as f32 / (half_h - 30) as f32);
            let a = (t * 0.8 * 200.0) as u8;
            if a > 20 {
                for dx in 0..(half_w - 10) {
                    img.set_pixel(5 + dx, 22 + dy, 200, 20, 20, a);
                }
            }
        }
        self.clear();
        self.trigger_shake(15.0, 0.4);
        let (ox, oy) = self.get_shake_offset();
        img.draw_rect(
            half_w as i32 + 2,
            2,
            half_w - 4,
            half_h - 4,
            10,
            10,
            40,
            255,
        );
        img.draw_label("SHAKE", half_w as i32 + 6, 6, 100, 100, 255);
        let scx = half_w as i32 + half_w as i32 / 2;
        let scy = half_h as i32 / 2;
        img.draw_circle(scx, scy, 20, 40, 40, 80, 255);
        img.draw_circle(
            scx + (ox * 2.0) as i32,
            scy + (oy * 2.0) as i32,
            4,
            255,
            100,
            100,
            255,
        );
        self.clear();
        self.trigger_fade(0.0, 0.0, 0.0, 0.7, 1.0);
        img.draw_rect(
            2,
            half_h as i32 + 2,
            half_w - 4,
            half_h - 4,
            10,
            10,
            10,
            255,
        );
        img.draw_label("FADE", 6, half_h as i32 + 6, 180, 180, 200);
        for dx in 0..(half_w - 10) {
            let t = dx as f32 / (half_w - 10) as f32;
            let alpha = (t * 0.7 * 255.0) as u8;
            for dy in 0..(half_h - 30) {
                img.set_pixel(5 + dx, half_h + 22 + dy, 0, 0, 0, alpha);
            }
        }
        self.clear();
        self.trigger_lightning();
        img.draw_rect(
            half_w as i32 + 2,
            half_h as i32 + 2,
            half_w - 4,
            half_h - 4,
            20,
            20,
            30,
            255,
        );
        img.draw_label(
            "LIGHTNING",
            half_w as i32 + 6,
            half_h as i32 + 6,
            220,
            220,
            255,
        );
        for dy in 0..(half_h - 30) {
            for dx in 0..(half_w - 10) {
                let flash = 200u8.saturating_sub((dy * 2) as u8);
                img.set_pixel(
                    half_w + 5 + dx,
                    half_h + 22 + dy,
                    flash,
                    flash,
                    flash + 40,
                    180,
                );
            }
        }
        self.clear();
        Ok(img)
    }
}
