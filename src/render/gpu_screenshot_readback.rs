//! Owns the gpu screenshot readback owner for the render subsystem and keeps its rules local to this file.
//! Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how gpu screenshot readback data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on gpu screenshot readback behavior while Lua registration stays elsewhere.

use std::sync::mpsc;

use crate::log_msg;
use crate::render::gpu_renderer::GpuRenderer;
use crate::render::gpu_state::PendingSurfaceReadback;
use crate::runtime::log_messages::{
    G002_SCREENSHOT_ZERO_SIZE, G003_SCREENSHOT_MAP_FAIL, G004_SCREENSHOT_RECV_FAIL,
    G005_SCREENSHOT_DATA_FAIL,
};

impl GpuRenderer {
    /// Copy the surface texture into a mappable readback buffer for screenshot capture.
    pub(crate) fn begin_surface_readback(
        &self,
        encoder: &mut wgpu::CommandEncoder,
        texture: &wgpu::Texture,
        width: u32,
        height: u32,
    ) -> Option<PendingSurfaceReadback> {
        if width == 0 || height == 0 {
            log_msg!(error, G002_SCREENSHOT_ZERO_SIZE);
            return None;
        }
        let unpadded_bytes_per_row = width.saturating_mul(4);
        let alignment = wgpu::COPY_BYTES_PER_ROW_ALIGNMENT;
        let padded_bytes_per_row = unpadded_bytes_per_row.div_ceil(alignment) * alignment;
        let buffer_size = padded_bytes_per_row as u64 * height as u64;
        let buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("surface_readback_buffer"),
            size: buffer_size,
            usage: wgpu::BufferUsages::COPY_DST | wgpu::BufferUsages::MAP_READ,
            mapped_at_creation: false,
        });
        encoder.copy_texture_to_buffer(
            wgpu::ImageCopyTexture {
                texture,
                mip_level: 0,
                origin: wgpu::Origin3d::ZERO,
                aspect: wgpu::TextureAspect::All,
            },
            wgpu::ImageCopyBuffer {
                buffer: &buffer,
                layout: wgpu::ImageDataLayout {
                    offset: 0,
                    bytes_per_row: Some(padded_bytes_per_row),
                    rows_per_image: Some(height),
                },
            },
            wgpu::Extent3d {
                width,
                height,
                depth_or_array_layers: 1,
            },
        );
        Some(PendingSurfaceReadback {
            buffer,
            padded_bytes_per_row,
            width,
            height,
        })
    }

    /// Map the readback buffer and extract RGBA pixel data for the screenshot.
    pub(crate) fn complete_surface_readback(
        &self,
        readback: PendingSurfaceReadback,
    ) -> Option<(u32, u32, Vec<u8>)> {
        let slice = readback.buffer.slice(..);
        let (sender, receiver) = mpsc::channel();
        slice.map_async(wgpu::MapMode::Read, move |result| {
            let _ = sender.send(result.map_err(|err| err.to_string()));
        });
        let _ = self.device.poll(wgpu::Maintain::Wait);
        match receiver.recv() {
            Ok(Ok(())) => {}
            Ok(Err(err)) => {
                log_msg!(error, G003_SCREENSHOT_MAP_FAIL, "{}", err);
                return None;
            }
            Err(err) => {
                log_msg!(error, G004_SCREENSHOT_RECV_FAIL, "{}", err);
                return None;
            }
        }
        let mut pixels = vec![0u8; (readback.width * readback.height * 4) as usize];
        {
            let mapped = slice.get_mapped_range();
            let row_len = (readback.width * 4) as usize;
            for row in 0..readback.height as usize {
                let src_start = row * readback.padded_bytes_per_row as usize;
                let dst_start = row * row_len;
                pixels[dst_start..dst_start + row_len]
                    .copy_from_slice(&mapped[src_start..src_start + row_len]);
            }
        }
        readback.buffer.unmap();
        match self.surface_format {
            wgpu::TextureFormat::Bgra8Unorm | wgpu::TextureFormat::Bgra8UnormSrgb => {
                for pixel in pixels.chunks_exact_mut(4) {
                    pixel.swap(0, 2);
                }
            }
            wgpu::TextureFormat::Rgba8Unorm | wgpu::TextureFormat::Rgba8UnormSrgb => {}
            _other => {
                log_msg!(error, G005_SCREENSHOT_DATA_FAIL, "pixel data error");
                return None;
            }
        }
        Some((readback.width, readback.height, pixels))
    }
}
