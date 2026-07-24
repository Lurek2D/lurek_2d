//! Owns the gpu screenshot readback owner for the render subsystem and keeps its rules local to this file.
//! Keeps render data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how gpu screenshot readback data is validated, transformed, or stored before neighboring systems use it.
//! Owns render behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on gpu screenshot readback behavior while Lua registration stays elsewhere.

use std::sync::mpsc::{self, TryRecvError};
use std::time::{Duration, Instant};

use crate::log_msg;
use crate::render::gpu_renderer::GpuRenderer;
use crate::render::gpu_state::{PendingSurfaceReadback, SurfaceReadbackStatus};
use crate::runtime::log_messages::{
    G002_SCREENSHOT_ZERO_SIZE, G003_SCREENSHOT_MAP_FAIL, G004_SCREENSHOT_RECV_FAIL,
    G005_SCREENSHOT_DATA_FAIL,
};

/// Main-loop capture requests must resolve or fail instead of remaining pending forever.
const SURFACE_READBACK_TIMEOUT: Duration = Duration::from_secs(5);

/// Validate and calculate a GPU readback layout without allocating staging memory.
pub fn surface_readback_layout(width: u32, height: u32) -> Result<(u32, u64), String> {
    if width == 0 || height == 0 {
        return Err("screenshot dimensions must be non-zero".into());
    }
    let row = u64::from(width)
        .checked_mul(4)
        .ok_or_else(|| "screenshot row bytes overflow".to_string())?;
    let alignment = u64::from(wgpu::COPY_BYTES_PER_ROW_ALIGNMENT);
    let padded = row
        .checked_add(alignment - 1)
        .and_then(|value| value.checked_div(alignment))
        .and_then(|rows| rows.checked_mul(alignment))
        .ok_or_else(|| "screenshot padded row bytes overflow".to_string())?;
    let total = padded
        .checked_mul(u64::from(height))
        .ok_or_else(|| "screenshot staging byte count overflow".to_string())?;
    let padded = u32::try_from(padded)
        .map_err(|_| "screenshot padded row bytes exceed wgpu layout range".to_string())?;
    Ok((padded, total))
}

impl GpuRenderer {
    /// Copy the surface texture into a mappable readback buffer for screenshot capture.
    pub(crate) fn begin_surface_readback(
        &mut self,
        encoder: &mut wgpu::CommandEncoder,
        texture: &wgpu::Texture,
        width: u32,
        height: u32,
    ) -> Option<PendingSurfaceReadback> {
        let (padded_bytes_per_row, buffer_size) = match surface_readback_layout(width, height) {
            Ok(layout) => layout,
            Err(error) => {
                log::warn!("Skipping invalid screenshot readback: {error}");
                log_msg!(error, G002_SCREENSHOT_ZERO_SIZE);
                self.surface_readback_status = SurfaceReadbackStatus::Failed;
                return None;
            }
        };
        if buffer_size > self.device.limits().max_buffer_size {
            log::warn!("Skipping screenshot whose staging buffer exceeds the device limit");
            self.surface_readback_status = SurfaceReadbackStatus::Failed;
            return None;
        }
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
            completion: None,
            started_at: Instant::now(),
        })
    }

    /// Start asynchronous mapping after the copy command has been submitted.
    pub(crate) fn start_surface_readback(&mut self, readback: &mut PendingSurfaceReadback) {
        if readback.completion.is_some() {
            return;
        }
        let slice = readback.buffer.slice(..);
        let (sender, receiver) = mpsc::channel();
        slice.map_async(wgpu::MapMode::Read, move |result| {
            let _ = sender.send(result.map_err(|err| err.to_string()));
        });
        readback.completion = Some(receiver);
        self.surface_readback_status = SurfaceReadbackStatus::Pending;
    }

    /// Progress and consume a completed readback without blocking the interactive loop.
    pub(crate) fn poll_surface_readback(&mut self) -> Option<(u32, u32, Vec<u8>)> {
        let readback = self.pending_surface_readback.take()?;
        if readback.started_at.elapsed() >= SURFACE_READBACK_TIMEOUT {
            self.surface_readback_status = SurfaceReadbackStatus::TimedOut;
            return None;
        }
        let Some(receiver) = readback.completion.as_ref() else {
            self.pending_surface_readback = Some(readback);
            return None;
        };
        let _ = self.device.poll(wgpu::Maintain::Poll);
        match receiver.try_recv() {
            Ok(Ok(())) => {}
            Ok(Err(err)) => {
                log_msg!(error, G003_SCREENSHOT_MAP_FAIL, "{}", err);
                self.surface_readback_status = SurfaceReadbackStatus::Failed;
                return None;
            }
            Err(TryRecvError::Disconnected) => {
                log_msg!(error, G004_SCREENSHOT_RECV_FAIL, "readback callback disconnected");
                self.surface_readback_status = SurfaceReadbackStatus::Failed;
                return None;
            }
            Err(TryRecvError::Empty) => {
                self.pending_surface_readback = Some(readback);
                return None;
            }
        }
        let Some(pixel_len) = u64::from(readback.width)
            .checked_mul(u64::from(readback.height))
            .and_then(|pixels| pixels.checked_mul(4))
            .and_then(|bytes| usize::try_from(bytes).ok())
        else {
            self.surface_readback_status = SurfaceReadbackStatus::Failed;
            return None;
        };
        let row_len = match u64::from(readback.width)
            .checked_mul(4)
            .and_then(|bytes| usize::try_from(bytes).ok())
        {
            Some(value) => value,
            None => {
                self.surface_readback_status = SurfaceReadbackStatus::Failed;
                return None;
            }
        };
        let row_count = match usize::try_from(readback.height) {
            Ok(value) => value,
            Err(_) => {
                self.surface_readback_status = SurfaceReadbackStatus::Failed;
                return None;
            }
        };
        let padded_row_len = match usize::try_from(readback.padded_bytes_per_row) {
            Ok(value) => value,
            Err(_) => {
                self.surface_readback_status = SurfaceReadbackStatus::Failed;
                return None;
            }
        };
        let mut pixels = Vec::new();
        if pixels.try_reserve_exact(pixel_len).is_err() {
            self.surface_readback_status = SurfaceReadbackStatus::Failed;
            return None;
        }
        pixels.resize(pixel_len, 0);
        let copied = {
            let slice = readback.buffer.slice(..);
            let mapped = slice.get_mapped_range();
            let required_source_len = row_count.checked_mul(padded_row_len);
            let required_destination_len = row_count.checked_mul(row_len);
            if !matches!(required_source_len, Some(length) if length <= mapped.len())
                || required_destination_len != Some(pixels.len())
            {
                false
            } else {
                for row in 0..row_count {
                    let src_start = row * padded_row_len;
                    let dst_start = row * row_len;
                    let src_end = src_start + row_len;
                    let dst_end = dst_start + row_len;
                    pixels[dst_start..dst_end].copy_from_slice(&mapped[src_start..src_end]);
                }
                true
            }
        };
        readback.buffer.unmap();
        if !copied {
            self.surface_readback_status = SurfaceReadbackStatus::Failed;
            return None;
        }
        match self.surface_format {
            wgpu::TextureFormat::Bgra8Unorm | wgpu::TextureFormat::Bgra8UnormSrgb => {
                for pixel in pixels.chunks_exact_mut(4) {
                    pixel.swap(0, 2);
                }
            }
            wgpu::TextureFormat::Rgba8Unorm | wgpu::TextureFormat::Rgba8UnormSrgb => {}
            _other => {
                log_msg!(error, G005_SCREENSHOT_DATA_FAIL, "pixel data error");
                self.surface_readback_status = SurfaceReadbackStatus::Failed;
                return None;
            }
        }
        self.surface_readback_status = SurfaceReadbackStatus::Ready;
        Some((readback.width, readback.height, pixels))
    }

    /// Cancel a pending readback during device loss, resize teardown, or shutdown.
    pub(crate) fn cancel_surface_readback(&mut self) {
        self.pending_surface_readback = None;
        self.surface_readback_status = SurfaceReadbackStatus::Cancelled;
    }
}
