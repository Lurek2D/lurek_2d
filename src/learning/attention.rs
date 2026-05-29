//! Attention components for transformer-like sequence models.

use crate::learning::tensor::LurekTensor;
use crate::learning::EvolutionaryLayer;

/// Sinusoidal positional encoding for `[seq_len, d_model]` tensors.
pub struct PositionalEncoding {
    pub d_model: usize,
    pub max_len: usize,
    pub encoding: Vec<f32>,
}

impl PositionalEncoding {
    /// Precompute positional encoding table.
    pub fn new(d_model: usize, max_len: usize) -> Self {
        let mut encoding = vec![0.0f32; max_len * d_model];
        for pos in 0..max_len {
            for i in (0..d_model).step_by(2) {
                let div_term = 10000.0f32.powf((i as f32) / (d_model as f32));
                encoding[pos * d_model + i] = ((pos as f32) / div_term).sin();
                if i + 1 < d_model {
                    encoding[pos * d_model + i + 1] = ((pos as f32) / div_term).cos();
                }
            }
        }
        Self {
            d_model,
            max_len,
            encoding,
        }
    }

    /// Add positional vectors in-place.
    pub fn apply(&self, x: &mut LurekTensor) -> Result<(), String> {
        if x.shape.len() != 2 {
            return Err("PositionalEncoding::apply expected shape [S,D]".to_string());
        }
        let seq_len = x.shape[0];
        let d = x.shape[1];
        if d != self.d_model {
            return Err("PositionalEncoding::apply d_model mismatch".to_string());
        }
        if seq_len > self.max_len {
            return Err("PositionalEncoding::apply seq_len exceeds max_len".to_string());
        }
        for pos in 0..seq_len {
            for i in 0..d {
                x.data[pos * d + i] += self.encoding[pos * d + i];
            }
        }
        Ok(())
    }
}

/// CPU multi-head self-attention with combined linear projections.
pub struct MultiHeadAttention {
    pub d_model: usize,
    pub num_heads: usize,
    pub d_k: usize,
    /// `[D,D]`
    pub w_q: Vec<f32>,
    /// `[D,D]`
    pub w_k: Vec<f32>,
    /// `[D,D]`
    pub w_v: Vec<f32>,
    /// `[D,D]`
    pub w_o: Vec<f32>,
    /// `[D]`
    pub b_q: Vec<f32>,
    /// `[D]`
    pub b_k: Vec<f32>,
    /// `[D]`
    pub b_v: Vec<f32>,
    /// `[D]`
    pub b_o: Vec<f32>,
}

impl MultiHeadAttention {
    /// Create a zero-initialized MHA block.
    pub fn new(d_model: usize, num_heads: usize) -> Result<Self, String> {
        if num_heads == 0 || !d_model.is_multiple_of(num_heads) {
            return Err("MultiHeadAttention::new requires d_model divisible by num_heads".to_string());
        }
        let d2 = d_model * d_model;
        Ok(Self {
            d_model,
            num_heads,
            d_k: d_model / num_heads,
            w_q: vec![0.0; d2],
            w_k: vec![0.0; d2],
            w_v: vec![0.0; d2],
            w_o: vec![0.0; d2],
            b_q: vec![0.0; d_model],
            b_k: vec![0.0; d_model],
            b_v: vec![0.0; d_model],
            b_o: vec![0.0; d_model],
        })
    }

    /// Run self-attention on `x` with shape `[S,D]`.
    pub fn forward(&self, x: &LurekTensor) -> Result<LurekTensor, String> {
        if x.shape.len() != 2 || x.shape[1] != self.d_model {
            return Err("MultiHeadAttention::forward expected shape [S,D]".to_string());
        }

        let s = x.shape[0];
        let d = self.d_model;

        let q = linear(x.data.as_slice(), s, d, d, &self.w_q, &self.b_q);
        let k = linear(x.data.as_slice(), s, d, d, &self.w_k, &self.b_k);
        let v = linear(x.data.as_slice(), s, d, d, &self.w_v, &self.b_v);

        let mut heads_concat = vec![0.0f32; s * d];
        for h in 0..self.num_heads {
            let head_base = h * self.d_k;
            let scale = (self.d_k as f32).sqrt();

            // scores [S,S]
            let mut scores = vec![0.0f32; s * s];
            for i in 0..s {
                for j in 0..s {
                    let mut dot = 0.0f32;
                    for t in 0..self.d_k {
                        let qi = q[i * d + head_base + t];
                        let kj = k[j * d + head_base + t];
                        dot += qi * kj;
                    }
                    scores[i * s + j] = dot / scale;
                }
            }

            // row-wise softmax
            for i in 0..s {
                softmax_in_place(&mut scores[i * s..(i + 1) * s]);
            }

            // head output [S,d_k] = softmax(scores) * V_h
            for i in 0..s {
                for t in 0..self.d_k {
                    let mut sum = 0.0f32;
                    for j in 0..s {
                        sum += scores[i * s + j] * v[j * d + head_base + t];
                    }
                    heads_concat[i * d + head_base + t] = sum;
                }
            }
        }

        let out = linear(&heads_concat, s, d, d, &self.w_o, &self.b_o);
        Ok(LurekTensor::new(vec![s, d], out))
    }
}

impl EvolutionaryLayer for MultiHeadAttention {
    fn param_count(&self) -> usize {
        4 * self.d_model * (self.d_model + 1)
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        let expected = self.param_count();
        if weights.len() != expected {
            return false;
        }

        let d = self.d_model;
        let d2 = d * d;
        self.w_q.copy_from_slice(&weights[..d2]);
        self.w_k.copy_from_slice(&weights[d2..2 * d2]);
        self.w_v.copy_from_slice(&weights[2 * d2..3 * d2]);
        self.w_o.copy_from_slice(&weights[3 * d2..4 * d2]);

        let bo = 4 * d2;
        self.b_q.copy_from_slice(&weights[bo..bo + d]);
        self.b_k.copy_from_slice(&weights[bo + d..bo + 2 * d]);
        self.b_v.copy_from_slice(&weights[bo + 2 * d..bo + 3 * d]);
        self.b_o.copy_from_slice(&weights[bo + 3 * d..]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.w_q);
        out.extend_from_slice(&self.w_k);
        out.extend_from_slice(&self.w_v);
        out.extend_from_slice(&self.w_o);
        out.extend_from_slice(&self.b_q);
        out.extend_from_slice(&self.b_k);
        out.extend_from_slice(&self.b_v);
        out.extend_from_slice(&self.b_o);
        out
    }
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

fn softmax_in_place(row: &mut [f32]) {
    let max = row.iter().copied().fold(f32::NEG_INFINITY, f32::max);
    let mut sum = 0.0f32;
    for value in row.iter_mut() {
        *value = (*value - max).exp();
        sum += *value;
    }
    let denom = sum.max(1e-8);
    for value in row.iter_mut() {
        *value /= denom;
    }
}
