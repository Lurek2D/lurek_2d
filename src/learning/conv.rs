//! This file owns convolution and max-pooling layers over channel-first tensors used by CPU learning pipelines.
//! `Conv2D` stores flat kernels and biases, while `MaxPool2D` owns pooling geometry without any trainable parameters.
//! Forward passes live here because stride, padding, and pooling window semantics are specific to image-style layer math.
//! `Conv2D` also implements `EvolutionaryLayer` so convolution weights can be packed for genetic or search-based training.
//! Open it when spatial-layer behavior changes; tensors, dense nets, and engine orchestration live in sibling files.

use crate::learning::tensor::LurekTensor;
use crate::learning::EvolutionaryLayer;

/// 2D convolution layer over `[channels, height, width]` tensors.
pub struct Conv2D {
    pub in_channels: usize,
    pub out_channels: usize,
    pub kernel_size: (usize, usize),
    pub stride: (usize, usize),
    pub padding: (usize, usize),
    /// Flat weights in `[out, in, kh, kw]` row-major order.
    pub weights: Vec<f32>,
    /// One bias per output channel.
    pub biases: Vec<f32>,
}

impl Conv2D {
    /// Create a zero-initialized convolution layer.
    pub fn new(
        in_channels: usize,
        out_channels: usize,
        kernel_size: (usize, usize),
        stride: (usize, usize),
        padding: (usize, usize),
    ) -> Self {
        let w_len = out_channels * in_channels * kernel_size.0 * kernel_size.1;
        Self {
            in_channels,
            out_channels,
            kernel_size,
            stride,
            padding,
            weights: vec![0.0; w_len],
            biases: vec![0.0; out_channels],
        }
    }

    /// Run convolution over one input tensor shaped `[C, H, W]`.
    pub fn forward(&self, input: &LurekTensor) -> Result<LurekTensor, String> {
        if input.shape.len() != 3 {
            return Err("Conv2D::forward expected input shape [C,H,W]".to_string());
        }

        let c_in = input.shape[0];
        let in_h = input.shape[1];
        let in_w = input.shape[2];

        if c_in != self.in_channels {
            return Err(format!(
                "Conv2D::forward input channels mismatch: expected {}, got {}",
                self.in_channels, c_in
            ));
        }

        let kh = self.kernel_size.0;
        let kw = self.kernel_size.1;
        let sh = self.stride.0;
        let sw = self.stride.1;
        let ph = self.padding.0;
        let pw = self.padding.1;

        let padded_h = in_h + 2 * ph;
        let padded_w = in_w + 2 * pw;
        if padded_h < kh || padded_w < kw {
            return Err("Conv2D::forward kernel larger than padded input".to_string());
        }

        let out_h = (padded_h - kh) / sh + 1;
        let out_w = (padded_w - kw) / sw + 1;
        let mut out = vec![0.0f32; self.out_channels * out_h * out_w];

        for f in 0..self.out_channels {
            for oy in 0..out_h {
                for ox in 0..out_w {
                    let mut sum = self.biases[f];
                    for c in 0..self.in_channels {
                        for ky in 0..kh {
                            for kx in 0..kw {
                                let iy_padded = oy * sh + ky;
                                let ix_padded = ox * sw + kx;
                                if iy_padded < ph || ix_padded < pw {
                                    continue;
                                }
                                let iy = iy_padded - ph;
                                let ix = ix_padded - pw;
                                if iy >= in_h || ix >= in_w {
                                    continue;
                                }

                                let in_idx = c * (in_h * in_w) + iy * in_w + ix;
                                let w_idx = ((f * self.in_channels + c) * kh + ky) * kw + kx;
                                sum += input.data[in_idx] * self.weights[w_idx];
                            }
                        }
                    }
                    let out_idx = f * (out_h * out_w) + oy * out_w + ox;
                    out[out_idx] = sum;
                }
            }
        }

        Ok(LurekTensor::new(vec![self.out_channels, out_h, out_w], out))
    }
}

impl EvolutionaryLayer for Conv2D {
    fn param_count(&self) -> usize {
        self.out_channels * self.in_channels * self.kernel_size.0 * self.kernel_size.1
            + self.out_channels
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        let expected = self.param_count();
        if weights.len() != expected {
            return false;
        }

        let w_size = self.out_channels * self.in_channels * self.kernel_size.0 * self.kernel_size.1;
        self.weights.copy_from_slice(&weights[..w_size]);
        self.biases.copy_from_slice(&weights[w_size..]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.weights);
        out.extend_from_slice(&self.biases);
        out
    }
}

/// Max pooling over `[channels, height, width]` tensors.
pub struct MaxPool2D {
    pub kernel_size: (usize, usize),
    pub stride: (usize, usize),
}

impl MaxPool2D {
    /// Create max pool layer.
    pub fn new(kernel_size: (usize, usize), stride: (usize, usize)) -> Self {
        Self {
            kernel_size,
            stride,
        }
    }

    /// Run max pooling.
    pub fn forward(&self, input: &LurekTensor) -> Result<LurekTensor, String> {
        if input.shape.len() != 3 {
            return Err("MaxPool2D::forward expected input shape [C,H,W]".to_string());
        }

        let channels = input.shape[0];
        let in_h = input.shape[1];
        let in_w = input.shape[2];

        let kh = self.kernel_size.0;
        let kw = self.kernel_size.1;
        let sh = self.stride.0;
        let sw = self.stride.1;
        if in_h < kh || in_w < kw {
            return Err("MaxPool2D::forward kernel larger than input".to_string());
        }

        let out_h = (in_h - kh) / sh + 1;
        let out_w = (in_w - kw) / sw + 1;
        let mut out = vec![0.0; channels * out_h * out_w];

        for c in 0..channels {
            for oy in 0..out_h {
                for ox in 0..out_w {
                    let mut max_val = f32::NEG_INFINITY;
                    for ky in 0..kh {
                        for kx in 0..kw {
                            let iy = oy * sh + ky;
                            let ix = ox * sw + kx;
                            let idx = c * (in_h * in_w) + iy * in_w + ix;
                            max_val = max_val.max(input.data[idx]);
                        }
                    }
                    let out_idx = c * (out_h * out_w) + oy * out_w + ox;
                    out[out_idx] = max_val;
                }
            }
        }

        Ok(LurekTensor::new(vec![channels, out_h, out_w], out))
    }
}
