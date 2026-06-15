//! Encodes frame sequences of `ImageData` into animated GIF files for evidence and export flows.
//! Validates frame dimensions and timing up front so Lua-facing callers get deterministic failures.
//! Uses per-frame quantization from RGBA buffers to keep the API simple for software-rendered captures.
//! Module API documentation

use crate::image::ImageData;
use ::gif::{Encoder, Frame, Repeat};

/// Repeat policy for animated GIF output.
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
#[derive(Debug, Clone, Copy)]
pub struct AnimatedGifOptions {
    /// Frame delay in milliseconds.
    pub delay_ms: u32,
    /// Quantizer speed in the range `[1, 30]`; higher is faster and lower quality.
    pub speed: i32,
    /// Repeat behaviour metadata written into the GIF stream.
    pub repeat: AnimatedGifRepeat,
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
    let first = frames
        .first()
        .ok_or_else(|| "saveGIF requires at least one frame".to_string())?;
    let width = first.width();
    let height = first.height();
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

    Ok(bytes)
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
