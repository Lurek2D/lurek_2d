//! Owns the image animated gif implementation for the image subsystem and keeps related runtime rules local here.
//! Keeps image data, encoded assets, and effect helpers ownership so helpers stay close to invariants this file updates.
//! Defines how image animated gif data is validated, transformed, or stored before neighboring systems consume it.
//! Separates image animated gif behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where image code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing image animated gif defaults, lifecycle handling, validation, or data ownership rules.

use crate::image::ImageData;
use crate::image::ImageLimits;
use gif::{ColorOutput, DecodeOptions, Encoder, Frame, Repeat};
use std::io::Cursor;

/// Repeat policy for animated GIF output.
///
/// # Variants
///
/// `Infinite` loops forever, `Finite` loops a bounded count, and `None` omits repeat metadata.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AnimatedGifRepeat {
    /// Loop forever.
    Infinite,
    /// Loop a fixed number of times after the first playthrough.
    Finite(u16),
    /// Do not emit a repeat extension.
    None,
}

/// GIF export settings shared across image and Lua-facing callers.
///
/// # Fields
///
/// Delay, quantizer speed, and repeat policy bound the generated GIF stream.
#[derive(Debug, Clone, Copy)]
pub struct AnimatedGifOptions {
    /// Frame delay in milliseconds.
    pub delay_ms: u32,
    /// Quantizer speed in the range `[1, 30]`; higher is faster and lower quality.
    pub speed: i32,
    /// Repeat behaviour metadata written into the GIF stream.
    pub repeat: AnimatedGifRepeat,
}

/// Decoded animated GIF frame with its display duration.
///
/// # Fields
///
/// `image` is one composited RGBA snapshot and `duration_ms` is its bounded display delay.
#[derive(Debug, Clone)]
pub struct AnimatedGifFrame {
    /// RGBA pixels for the composited frame.
    pub image: ImageData,
    /// Frame duration in milliseconds.
    pub duration_ms: u32,
}

impl Default for AnimatedGifOptions {
    fn default() -> Self {
        Self {
            delay_ms: 100,
            speed: 10,
            repeat: AnimatedGifRepeat::Infinite,
        }
    }
}

impl AnimatedGifOptions {
    fn delay_centiseconds(self) -> Result<u16, String> {
        let centiseconds = (self.delay_ms + 5) / 10;
        if centiseconds > u16::MAX as u32 {
            return Err(format!(
                "GIF delayMs={} is too large; maximum supported delay is {} ms",
                self.delay_ms,
                u16::MAX as u32 * 10
            ));
        }
        Ok(centiseconds as u16)
    }

    fn validate(self) -> Result<u16, String> {
        if !(1..=30).contains(&self.speed) {
            return Err(format!(
                "GIF speed={} is out of range; expected 1..=30",
                self.speed
            ));
        }
        self.delay_centiseconds()
    }
}

fn validate_frames(frames: &[ImageData]) -> Result<(u16, u16), String> {
    let limits = ImageLimits::default();
    if frames.len() > limits.max_frames_or_layers {
        return Err(format!(
            "saveGIF has {} frames, limit is {}",
            frames.len(),
            limits.max_frames_or_layers
        ));
    }
    let first = frames
        .first()
        .ok_or_else(|| "saveGIF requires at least one frame".to_string())?;
    let width = first.width();
    let height = first.height();
    let frame_bytes = limits.rgba_bytes(width, height)?;
    let aggregate = frame_bytes
        .checked_mul(frames.len())
        .ok_or_else(|| "saveGIF aggregate frame bytes overflow".to_string())?;
    if aggregate > limits.max_aggregate_bytes {
        return Err(format!(
            "saveGIF frame bytes {} exceed limit {}",
            aggregate, limits.max_aggregate_bytes
        ));
    }
    if width == 0 || height == 0 {
        return Err("saveGIF does not support zero-sized frames".into());
    }
    let width_u16 =
        u16::try_from(width).map_err(|_| format!("GIF width {} exceeds u16 limit", width))?;
    let height_u16 =
        u16::try_from(height).map_err(|_| format!("GIF height {} exceeds u16 limit", height))?;

    for (index, frame) in frames.iter().enumerate().skip(1) {
        if frame.width() != width || frame.height() != height {
            return Err(format!(
                "saveGIF frame {} has size {}x{} but expected {}x{}",
                index + 1,
                frame.width(),
                frame.height(),
                width,
                height
            ));
        }
    }

    Ok((width_u16, height_u16))
}

/// Encode a list of equally sized RGBA frames into animated GIF bytes.
pub fn encode_gif(frames: &[ImageData], options: AnimatedGifOptions) -> Result<Vec<u8>, String> {
    let delay_cs = options.validate()?;
    let (width, height) = validate_frames(frames)?;

    let mut bytes = Vec::new();
    {
        let mut encoder = Encoder::new(&mut bytes, width, height, &[])
            .map_err(|e| format!("GIF encoder init error: {}", e))?;
        match options.repeat {
            AnimatedGifRepeat::Infinite => encoder
                .set_repeat(Repeat::Infinite)
                .map_err(|e| format!("GIF repeat error: {}", e))?,
            AnimatedGifRepeat::Finite(count) => encoder
                .set_repeat(Repeat::Finite(count))
                .map_err(|e| format!("GIF repeat error: {}", e))?,
            AnimatedGifRepeat::None => {}
        }

        for frame in frames {
            let mut rgba = frame.as_bytes().to_vec();
            let mut gif_frame = Frame::from_rgba_speed(width, height, &mut rgba, options.speed);
            gif_frame.delay = delay_cs;
            encoder
                .write_frame(&gif_frame)
                .map_err(|e| format!("GIF write error: {}", e))?;
        }
    }

    ImageLimits::default().encoded_bytes(bytes.len(), "GIF output")?;
    Ok(bytes)
}

/// Decode animated GIF bytes into composited RGBA frames and frame durations.
pub fn decode_gif(bytes: &[u8], label: &str) -> Result<Vec<AnimatedGifFrame>, String> {
    let limits = ImageLimits::default();
    limits.encoded_bytes(bytes.len(), &format!("GIF '{}' input", label))?;
    let mut options = DecodeOptions::new();
    options.set_color_output(ColorOutput::RGBA);
    let mut reader = options
        .read_info(Cursor::new(bytes))
        .map_err(|e| format!("Failed to decode GIF '{}': {}", label, e))?;
    let canvas_w = reader.width() as u32;
    let canvas_h = reader.height() as u32;
    if canvas_w == 0 || canvas_h == 0 {
        return Err(format!("GIF '{}' has zero-sized canvas", label));
    }

    let canvas_bytes = limits.rgba_bytes(canvas_w, canvas_h)?;
    let mut canvas = ImageData::try_new_with_limits(canvas_w, canvas_h, limits)?;
    let mut frames = Vec::new();
    while let Some(frame) = reader
        .read_next_frame()
        .map_err(|e| format!("Failed to read GIF frame '{}': {}", label, e))?
    {
        let fw = frame.width as u32;
        let fh = frame.height as u32;
        let left = frame.left as u32;
        let top = frame.top as u32;
        let right = left
            .checked_add(fw)
            .ok_or_else(|| format!("GIF '{}' frame rectangle overflows", label))?;
        let bottom = top
            .checked_add(fh)
            .ok_or_else(|| format!("GIF '{}' frame rectangle overflows", label))?;
        if right > canvas_w || bottom > canvas_h {
            return Err(format!("GIF '{}' frame rectangle exceeds canvas", label));
        }
        let expected = limits.rgba_bytes(fw, fh)?;
        if frame.buffer.len() != expected {
            return Err(format!(
                "GIF '{}' frame has {} bytes, expected {}",
                label,
                frame.buffer.len(),
                expected
            ));
        }
        if frames.len() >= limits.max_frames_or_layers {
            return Err(format!(
                "GIF '{}' exceeds frame limit {}",
                label, limits.max_frames_or_layers
            ));
        }
        let aggregate = canvas_bytes
            .checked_mul(frames.len() + 1)
            .ok_or_else(|| format!("GIF '{}' aggregate frame bytes overflow", label))?;
        if aggregate > limits.max_aggregate_bytes {
            return Err(format!(
                "GIF '{}' decoded frame bytes exceed limit {}",
                label, limits.max_aggregate_bytes
            ));
        }
        let frame_image = ImageData::from_bytes_with_limits(fw, fh, frame.buffer.to_vec(), limits)?;
        canvas.blit(&frame_image, left as i32, top as i32);
        let duration_ms = (frame.delay as u32).saturating_mul(10).max(10);
        frames.push(AnimatedGifFrame {
            image: canvas.clone(),
            duration_ms,
        });
    }
    if frames.is_empty() {
        return Err(format!("GIF '{}' contains no frames", label));
    }
    Ok(frames)
}

/// Load and decode an animated GIF from disk.
pub fn load_gif(path: &std::path::Path) -> Result<Vec<AnimatedGifFrame>, String> {
    let bytes = std::fs::read(path)
        .map_err(|e| format!("Failed to read GIF '{}': {}", path.display(), e))?;
    decode_gif(&bytes, &path.display().to_string())
}

/// Save a list of equally sized RGBA frames as an animated GIF on disk.
pub fn save_gif(
    frames: &[ImageData],
    path: &std::path::Path,
    options: AnimatedGifOptions,
) -> Result<(), String> {
    let bytes = encode_gif(frames, options)?;
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).map_err(|e| {
            format!(
                "Failed to create GIF output directory '{}': {}",
                parent.display(),
                e
            )
        })?;
    }
    std::fs::write(path, bytes)
        .map_err(|e| format!("Failed to write GIF '{}': {}", path.display(), e))
}
