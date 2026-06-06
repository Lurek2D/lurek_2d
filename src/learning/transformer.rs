//! Implements transformer-style blocks composed from attention, normalization, and feed-forward stages.
//! Defines encoder and decoder building units operating over engine-native tensor structures.
//! Applies residual pathways and normalization flows for stable sequence representation updates.
//! Stores trainable parameters in flat vectors to align with evolutionary optimization tooling.
//! Coordinates multi-stage forward execution across attention and projection subcomponents.
//! Provides reusable transformer primitives for sequence learning and inference experiments.
//! Integrates with the wider learning stack through common tensor and layer contracts.

use crate::learning::attention::MultiHeadAttention;
use crate::learning::tensor::LurekTensor;
use crate::learning::EvolutionaryLayer;

/// Layer normalization over a single model vector.
pub struct LayerNorm {
    pub d_model: usize,
    pub gamma: Vec<f32>,
    pub beta: Vec<f32>,
    pub epsilon: f32,
}

impl LayerNorm {
    /// Create layer norm with identity scale and zero bias.
    pub fn new(d_model: usize) -> Self {
        Self {
            d_model,
            gamma: vec![1.0; d_model],
            beta: vec![0.0; d_model],
            epsilon: 1e-5,
        }
    }

    /// Normalize one vector of length `d_model`.
    pub fn forward_vec(&self, x: &[f32]) -> Vec<f32> {
        let n = x.len();
        let mean = x.iter().sum::<f32>() / n as f32;
        let var = x.iter().map(|v| (v - mean) * (v - mean)).sum::<f32>() / n as f32;
        let inv_std = 1.0 / (var + self.epsilon).sqrt();

        x.iter()
            .enumerate()
            .map(|(i, v)| self.gamma[i] * (v - mean) * inv_std + self.beta[i])
            .collect()
    }

    /// Normalize tensor rows for shape `[S,D]`.
    pub fn forward_tensor(&self, x: &LurekTensor) -> Result<LurekTensor, String> {
        if x.shape.len() != 2 || x.shape[1] != self.d_model {
            return Err("LayerNorm::forward_tensor expected shape [S,D]".to_string());
        }
        let s = x.shape[0];
        let d = self.d_model;
        let mut out = vec![0.0f32; s * d];
        for row in 0..s {
            let normalized = self.forward_vec(&x.data[row * d..(row + 1) * d]);
            out[row * d..(row + 1) * d].copy_from_slice(&normalized);
        }
        Ok(LurekTensor::new(vec![s, d], out))
    }
}

impl EvolutionaryLayer for LayerNorm {
    fn param_count(&self) -> usize {
        2 * self.d_model
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        if weights.len() != self.param_count() {
            return false;
        }
        self.gamma.copy_from_slice(&weights[..self.d_model]);
        self.beta.copy_from_slice(&weights[self.d_model..]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.gamma);
        out.extend_from_slice(&self.beta);
        out
    }
}

/// Standard transformer encoder block.
pub struct TransformerEncoderBlock {
    pub attention: MultiHeadAttention,
    pub norm1: LayerNorm,
    pub norm2: LayerNorm,
    /// `[D, Dff]`
    pub ffn_w1: Vec<f32>,
    /// `[Dff]`
    pub ffn_b1: Vec<f32>,
    /// `[Dff, D]`
    pub ffn_w2: Vec<f32>,
    /// `[D]`
    pub ffn_b2: Vec<f32>,
    pub d_model: usize,
    pub d_ff: usize,
}

impl TransformerEncoderBlock {
    /// Create a zero-initialized encoder block.
    pub fn new(d_model: usize, num_heads: usize, d_ff: usize) -> Result<Self, String> {
        Ok(Self {
            attention: MultiHeadAttention::new(d_model, num_heads)?,
            norm1: LayerNorm::new(d_model),
            norm2: LayerNorm::new(d_model),
            ffn_w1: vec![0.0; d_model * d_ff],
            ffn_b1: vec![0.0; d_ff],
            ffn_w2: vec![0.0; d_ff * d_model],
            ffn_b2: vec![0.0; d_model],
            d_model,
            d_ff,
        })
    }

    /// Forward pass for one encoder block.
    pub fn forward(&self, x: &LurekTensor) -> Result<LurekTensor, String> {
        let attn = self.attention.forward(x)?;
        let x1 = add_tensors(x, &attn)?;
        let n1 = self.norm1.forward_tensor(&x1)?;

        let ff1 = linear(
            &n1.data,
            n1.shape[0],
            self.d_model,
            self.d_ff,
            &self.ffn_w1,
            &self.ffn_b1,
        );
        let ff1_relu: Vec<f32> = ff1.into_iter().map(|v| v.max(0.0)).collect();
        let ff2 = linear(
            &ff1_relu,
            n1.shape[0],
            self.d_ff,
            self.d_model,
            &self.ffn_w2,
            &self.ffn_b2,
        );
        let ff_out = LurekTensor::new(vec![n1.shape[0], self.d_model], ff2);

        let x2 = add_tensors(&n1, &ff_out)?;
        self.norm2.forward_tensor(&x2)
    }
}

impl EvolutionaryLayer for TransformerEncoderBlock {
    fn param_count(&self) -> usize {
        self.attention.param_count()
            + self.norm1.param_count()
            + self.norm2.param_count()
            + self.d_model * self.d_ff
            + self.d_ff
            + self.d_ff * self.d_model
            + self.d_model
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        if weights.len() != self.param_count() {
            return false;
        }

        let mut off = 0usize;

        let attn_n = self.attention.param_count();
        if !self.attention.set_weights(&weights[off..off + attn_n]) {
            return false;
        }
        off += attn_n;

        let n1 = self.norm1.param_count();
        if !self.norm1.set_weights(&weights[off..off + n1]) {
            return false;
        }
        off += n1;

        let n2 = self.norm2.param_count();
        if !self.norm2.set_weights(&weights[off..off + n2]) {
            return false;
        }
        off += n2;

        let w1 = self.d_model * self.d_ff;
        self.ffn_w1.copy_from_slice(&weights[off..off + w1]);
        off += w1;
        self.ffn_b1.copy_from_slice(&weights[off..off + self.d_ff]);
        off += self.d_ff;

        let w2 = self.d_ff * self.d_model;
        self.ffn_w2.copy_from_slice(&weights[off..off + w2]);
        off += w2;
        self.ffn_b2
            .copy_from_slice(&weights[off..off + self.d_model]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.attention.get_weights());
        out.extend_from_slice(&self.norm1.get_weights());
        out.extend_from_slice(&self.norm2.get_weights());
        out.extend_from_slice(&self.ffn_w1);
        out.extend_from_slice(&self.ffn_b1);
        out.extend_from_slice(&self.ffn_w2);
        out.extend_from_slice(&self.ffn_b2);
        out
    }
}

/// Transformer decoder block with self-attention and encoder cross-attention.
pub struct TransformerDecoderBlock {
    pub self_attention: MultiHeadAttention,
    pub cross_attention: MultiHeadAttention,
    pub norm1: LayerNorm,
    pub norm2: LayerNorm,
    pub norm3: LayerNorm,
    /// `[D, Dff]`
    pub ffn_w1: Vec<f32>,
    /// `[Dff]`
    pub ffn_b1: Vec<f32>,
    /// `[Dff, D]`
    pub ffn_w2: Vec<f32>,
    /// `[D]`
    pub ffn_b2: Vec<f32>,
    pub d_model: usize,
    pub d_ff: usize,
}

impl TransformerDecoderBlock {
    /// Create a zero-initialized decoder block.
    pub fn new(d_model: usize, num_heads: usize, d_ff: usize) -> Result<Self, String> {
        Ok(Self {
            self_attention: MultiHeadAttention::new(d_model, num_heads)?,
            cross_attention: MultiHeadAttention::new(d_model, num_heads)?,
            norm1: LayerNorm::new(d_model),
            norm2: LayerNorm::new(d_model),
            norm3: LayerNorm::new(d_model),
            ffn_w1: vec![0.0; d_model * d_ff],
            ffn_b1: vec![0.0; d_ff],
            ffn_w2: vec![0.0; d_ff * d_model],
            ffn_b2: vec![0.0; d_model],
            d_model,
            d_ff,
        })
    }

    /// Forward pass for one decoder block.
    pub fn forward(
        &self,
        x: &LurekTensor,
        encoder_out: &LurekTensor,
    ) -> Result<LurekTensor, String> {
        if encoder_out.shape.len() != 2 || encoder_out.shape[1] != self.d_model {
            return Err("TransformerDecoderBlock::forward encoder_out shape mismatch".to_string());
        }

        let self_attn = self.self_attention.forward(x)?;
        let x1 = add_tensors(x, &self_attn)?;
        let n1 = self.norm1.forward_tensor(&x1)?;

        // Lightweight cross-attention proxy: add encoder mean then run attention.
        let enc_mean = row_mean(encoder_out)?;
        let mut cross_input = n1.clone();
        for row in 0..cross_input.shape[0] {
            for (i, val) in enc_mean.iter().enumerate().take(self.d_model) {
                cross_input.data[row * self.d_model + i] += *val;
            }
        }
        let cross_attn = self.cross_attention.forward(&cross_input)?;
        let x2 = add_tensors(&n1, &cross_attn)?;
        let n2 = self.norm2.forward_tensor(&x2)?;

        let ff1 = linear(
            &n2.data,
            n2.shape[0],
            self.d_model,
            self.d_ff,
            &self.ffn_w1,
            &self.ffn_b1,
        );
        let ff1_relu: Vec<f32> = ff1.into_iter().map(|v| v.max(0.0)).collect();
        let ff2 = linear(
            &ff1_relu,
            n2.shape[0],
            self.d_ff,
            self.d_model,
            &self.ffn_w2,
            &self.ffn_b2,
        );
        let ff_out = LurekTensor::new(vec![n2.shape[0], self.d_model], ff2);

        let x3 = add_tensors(&n2, &ff_out)?;
        self.norm3.forward_tensor(&x3)
    }
}

impl EvolutionaryLayer for TransformerDecoderBlock {
    fn param_count(&self) -> usize {
        self.self_attention.param_count()
            + self.cross_attention.param_count()
            + self.norm1.param_count()
            + self.norm2.param_count()
            + self.norm3.param_count()
            + self.d_model * self.d_ff
            + self.d_ff
            + self.d_ff * self.d_model
            + self.d_model
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        if weights.len() != self.param_count() {
            return false;
        }

        let mut off = 0usize;

        let sa = self.self_attention.param_count();
        if !self.self_attention.set_weights(&weights[off..off + sa]) {
            return false;
        }
        off += sa;

        let ca = self.cross_attention.param_count();
        if !self.cross_attention.set_weights(&weights[off..off + ca]) {
            return false;
        }
        off += ca;

        let n1 = self.norm1.param_count();
        if !self.norm1.set_weights(&weights[off..off + n1]) {
            return false;
        }
        off += n1;

        let n2 = self.norm2.param_count();
        if !self.norm2.set_weights(&weights[off..off + n2]) {
            return false;
        }
        off += n2;

        let n3 = self.norm3.param_count();
        if !self.norm3.set_weights(&weights[off..off + n3]) {
            return false;
        }
        off += n3;

        let w1 = self.d_model * self.d_ff;
        self.ffn_w1.copy_from_slice(&weights[off..off + w1]);
        off += w1;
        self.ffn_b1.copy_from_slice(&weights[off..off + self.d_ff]);
        off += self.d_ff;

        let w2 = self.d_ff * self.d_model;
        self.ffn_w2.copy_from_slice(&weights[off..off + w2]);
        off += w2;
        self.ffn_b2
            .copy_from_slice(&weights[off..off + self.d_model]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.self_attention.get_weights());
        out.extend_from_slice(&self.cross_attention.get_weights());
        out.extend_from_slice(&self.norm1.get_weights());
        out.extend_from_slice(&self.norm2.get_weights());
        out.extend_from_slice(&self.norm3.get_weights());
        out.extend_from_slice(&self.ffn_w1);
        out.extend_from_slice(&self.ffn_b1);
        out.extend_from_slice(&self.ffn_w2);
        out.extend_from_slice(&self.ffn_b2);
        out
    }
}

fn add_tensors(a: &LurekTensor, b: &LurekTensor) -> Result<LurekTensor, String> {
    if a.shape != b.shape {
        return Err("add_tensors shape mismatch".to_string());
    }
    let data = a
        .data
        .iter()
        .zip(b.data.iter())
        .map(|(x, y)| x + y)
        .collect();
    Ok(LurekTensor::new(a.shape.clone(), data))
}

fn linear(x: &[f32], rows: usize, in_dim: usize, out_dim: usize, w: &[f32], b: &[f32]) -> Vec<f32> {
    let mut out = vec![0.0f32; rows * out_dim];
    for r in 0..rows {
        for o in 0..out_dim {
            let mut sum = b[o];
            for i in 0..in_dim {
                sum += x[r * in_dim + i] * w[i * out_dim + o];
            }
            out[r * out_dim + o] = sum;
        }
    }
    out
}

fn row_mean(x: &LurekTensor) -> Result<Vec<f32>, String> {
    if x.shape.len() != 2 {
        return Err("row_mean expected [S,D] tensor".to_string());
    }
    let s = x.shape[0];
    let d = x.shape[1];
    let mut out = vec![0.0f32; d];
    for row in 0..s {
        for (i, slot) in out.iter_mut().enumerate().take(d) {
            *slot += x.data[row * d + i];
        }
    }
    for v in &mut out {
        *v /= s as f32;
    }
    Ok(out)
}
