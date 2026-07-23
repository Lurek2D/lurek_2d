//! Defines the resource ceilings shared by CPU image allocation, codecs, and pixel-domain work.
//! Lua-facing image operations always use these conservative defaults; tools may supply explicit limits.

/// Resource ceilings for untrusted image input and CPU-side image operations.
///
/// # Fields
///
/// Each field is an independent allocation, aggregate, parser, or work ceiling enforced by image entry points.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ImageLimits {
    /// Maximum width or height in pixels.
    pub max_dimension: u32,
    /// Maximum pixels in one RGBA image.
    pub max_pixels: u64,
    /// Maximum bytes in one RGBA image or encoded output.
    pub max_rgba_bytes: usize,
    /// Maximum encoded input bytes accepted by a decoder.
    pub max_encoded_bytes: usize,
    /// Maximum GIF frames and layered-image layers.
    pub max_frames_or_layers: usize,
    /// Maximum aggregate decoded bytes retained by a GIF or layered image.
    pub max_aggregate_bytes: usize,
    /// Maximum bytes across layered-image names.
    pub max_layer_name_bytes: usize,
    /// Maximum palette entries accepted by image palette operations.
    pub max_palette_entries: usize,
    /// Maximum rectangles accepted by one generic atlas packer.
    pub max_atlas_rectangles: usize,
    /// Maximum kernel elements accepted by a convolution operation.
    pub max_kernel_elements: usize,
    /// Maximum effects accepted by one transactional effect chain.
    pub max_effect_chain_length: usize,
    /// Maximum Lua pixel callbacks invoked by one mapping operation.
    pub max_callback_pixels: u64,
    /// Maximum pixel callback invocations or other bounded work units.
    pub max_work_units: u64,
}

impl Default for ImageLimits {
    fn default() -> Self {
        Self {
            max_dimension: 16_384,
            max_pixels: 64 * 1024 * 1024,
            max_rgba_bytes: 256 * 1024 * 1024,
            max_encoded_bytes: 64 * 1024 * 1024,
            max_frames_or_layers: 256,
            max_aggregate_bytes: 256 * 1024 * 1024,
            max_layer_name_bytes: 64 * 1024,
            max_palette_entries: 65_536,
            max_atlas_rectangles: 16_384,
            max_kernel_elements: 16_384,
            max_effect_chain_length: 256,
            max_callback_pixels: 64 * 1024 * 1024,
            max_work_units: 256 * 1024 * 1024,
        }
    }
}

impl ImageLimits {
    /// Validate dimensions and return their exact RGBA byte count without allocating.
    pub fn rgba_bytes(self, width: u32, height: u32) -> Result<usize, String> {
        if width > self.max_dimension || height > self.max_dimension {
            return Err(format!(
                "image dimensions {}x{} exceed maximum dimension {}",
                width, height, self.max_dimension
            ));
        }
        let pixels = u64::from(width)
            .checked_mul(u64::from(height))
            .ok_or_else(|| format!("image dimensions {}x{} overflow pixel count", width, height))?;
        if pixels > self.max_pixels {
            return Err(format!(
                "image dimensions {}x{} exceed pixel limit {}",
                width, height, self.max_pixels
            ));
        }
        let bytes = pixels.checked_mul(4).ok_or_else(|| {
            format!(
                "image dimensions {}x{} overflow RGBA byte count",
                width, height
            )
        })?;
        let bytes = usize::try_from(bytes).map_err(|_| {
            format!(
                "image dimensions {}x{} exceed addressable RGBA buffer size",
                width, height
            )
        })?;
        if bytes > self.max_rgba_bytes {
            return Err(format!(
                "image dimensions {}x{} exceed RGBA byte limit {}",
                width, height, self.max_rgba_bytes
            ));
        }
        Ok(bytes)
    }

    /// Reject a multiplied pixel-domain operation before it begins.
    pub fn work(self, pixels: u64, multiplier: u64, operation: &str) -> Result<(), String> {
        let work = pixels
            .checked_mul(multiplier)
            .ok_or_else(|| format!("{} work calculation overflow", operation))?;
        if work > self.max_work_units {
            return Err(format!(
                "{} requires {} work units, limit is {}",
                operation, work, self.max_work_units
            ));
        }
        Ok(())
    }

    /// Reject an encoded input or output byte sequence that exceeds its policy ceiling.
    pub fn encoded_bytes(self, len: usize, operation: &str) -> Result<(), String> {
        if len > self.max_encoded_bytes {
            return Err(format!(
                "{} has {} bytes, limit is {}",
                operation, len, self.max_encoded_bytes
            ));
        }
        Ok(())
    }
}
