//! Recurrent learning layers for sequence modeling.

use crate::learning::EvolutionaryLayer;

/// CPU LSTM layer with combined gate matrices.
pub struct LstmLayer {
    pub input_size: usize,
    pub hidden_size: usize,
    /// `[4H, D]` flattened row-major.
    pub w_gate: Vec<f32>,
    /// `[4H, H]` flattened row-major.
    pub u_gate: Vec<f32>,
    /// `[4H]`.
    pub b_gate: Vec<f32>,
}

impl LstmLayer {
    /// Create a zero-initialized LSTM layer.
    pub fn new(input_size: usize, hidden_size: usize) -> Self {
        Self {
            input_size,
            hidden_size,
            w_gate: vec![0.0; 4 * hidden_size * input_size],
            u_gate: vec![0.0; 4 * hidden_size * hidden_size],
            b_gate: vec![0.0; 4 * hidden_size],
        }
    }

    /// Execute one recurrent step.
    pub fn step(&self, x: &[f32], prev_h: &[f32], prev_c: &[f32]) -> Result<(Vec<f32>, Vec<f32>), String> {
        let h = self.hidden_size;
        if x.len() != self.input_size {
            return Err("LstmLayer::step input size mismatch".to_string());
        }
        if prev_h.len() != h || prev_c.len() != h {
            return Err("LstmLayer::step state size mismatch".to_string());
        }

        let mut gates = vec![0.0f32; 4 * h];
        for (g, gate_slot) in gates.iter_mut().enumerate().take(4 * h) {
            let mut sum = self.b_gate[g];
            for (i, &xv) in x.iter().enumerate().take(self.input_size) {
                sum += self.w_gate[g * self.input_size + i] * xv;
            }
            for (j, &hv) in prev_h.iter().enumerate().take(h) {
                sum += self.u_gate[g * h + j] * hv;
            }
            *gate_slot = sum;
        }

        let mut next_h = vec![0.0f32; h];
        let mut next_c = vec![0.0f32; h];
        for i in 0..h {
            let in_gate = sigmoid(gates[i]);
            let forget_gate = sigmoid(gates[h + i]);
            let cell_candidate = gates[2 * h + i].tanh();
            let out_gate = sigmoid(gates[3 * h + i]);

            next_c[i] = forget_gate * prev_c[i] + in_gate * cell_candidate;
            next_h[i] = out_gate * next_c[i].tanh();
        }

        Ok((next_h, next_c))
    }
}

impl EvolutionaryLayer for LstmLayer {
    fn param_count(&self) -> usize {
        4 * self.hidden_size * (self.input_size + self.hidden_size + 1)
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        let expected = self.param_count();
        if weights.len() != expected {
            return false;
        }

        let h = self.hidden_size;
        let d = self.input_size;
        let w_offset = 4 * h * d;
        let u_offset = w_offset + 4 * h * h;

        self.w_gate.copy_from_slice(&weights[..w_offset]);
        self.u_gate.copy_from_slice(&weights[w_offset..u_offset]);
        self.b_gate.copy_from_slice(&weights[u_offset..]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.w_gate);
        out.extend_from_slice(&self.u_gate);
        out.extend_from_slice(&self.b_gate);
        out
    }
}

/// CPU GRU layer with combined gate matrices.
pub struct GruLayer {
    pub input_size: usize,
    pub hidden_size: usize,
    /// `[3H, D]` flattened row-major.
    pub w_gate: Vec<f32>,
    /// `[3H, H]` flattened row-major.
    pub u_gate: Vec<f32>,
    /// `[3H]`.
    pub b_gate: Vec<f32>,
}

impl GruLayer {
    /// Create a zero-initialized GRU layer.
    pub fn new(input_size: usize, hidden_size: usize) -> Self {
        Self {
            input_size,
            hidden_size,
            w_gate: vec![0.0; 3 * hidden_size * input_size],
            u_gate: vec![0.0; 3 * hidden_size * hidden_size],
            b_gate: vec![0.0; 3 * hidden_size],
        }
    }

    /// Execute one recurrent step.
    pub fn step(&self, x: &[f32], prev_h: &[f32]) -> Result<Vec<f32>, String> {
        let h = self.hidden_size;
        if x.len() != self.input_size {
            return Err("GruLayer::step input size mismatch".to_string());
        }
        if prev_h.len() != h {
            return Err("GruLayer::step state size mismatch".to_string());
        }

        let mut z = vec![0.0f32; h];
        let mut r = vec![0.0f32; h];
        for i in 0..h {
            let mut z_sum = self.b_gate[i];
            let mut r_sum = self.b_gate[h + i];
            for (j, &xv) in x.iter().enumerate().take(self.input_size) {
                z_sum += self.w_gate[i * self.input_size + j] * xv;
                r_sum += self.w_gate[(h + i) * self.input_size + j] * xv;
            }
            for (j, &hv) in prev_h.iter().enumerate().take(h) {
                z_sum += self.u_gate[i * h + j] * hv;
                r_sum += self.u_gate[(h + i) * h + j] * hv;
            }
            z[i] = sigmoid(z_sum);
            r[i] = sigmoid(r_sum);
        }

        let mut h_tilde = vec![0.0f32; h];
        for (i, h_tilde_slot) in h_tilde.iter_mut().enumerate().take(h) {
            let mut sum = self.b_gate[2 * h + i];
            for (j, &xv) in x.iter().enumerate().take(self.input_size) {
                sum += self.w_gate[(2 * h + i) * self.input_size + j] * xv;
            }
            for (j, &hv) in prev_h.iter().enumerate().take(h) {
                sum += self.u_gate[(2 * h + i) * h + j] * (r[j] * hv);
            }
            *h_tilde_slot = sum.tanh();
        }

        let mut next_h = vec![0.0f32; h];
        for i in 0..h {
            next_h[i] = (1.0 - z[i]) * prev_h[i] + z[i] * h_tilde[i];
        }
        Ok(next_h)
    }
}

impl EvolutionaryLayer for GruLayer {
    fn param_count(&self) -> usize {
        3 * self.hidden_size * (self.input_size + self.hidden_size + 1)
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        let expected = self.param_count();
        if weights.len() != expected {
            return false;
        }

        let h = self.hidden_size;
        let d = self.input_size;
        let w_offset = 3 * h * d;
        let u_offset = w_offset + 3 * h * h;

        self.w_gate.copy_from_slice(&weights[..w_offset]);
        self.u_gate.copy_from_slice(&weights[w_offset..u_offset]);
        self.b_gate.copy_from_slice(&weights[u_offset..]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.w_gate);
        out.extend_from_slice(&self.u_gate);
        out.extend_from_slice(&self.b_gate);
        out
    }
}

fn sigmoid(x: f32) -> f32 {
    1.0 / (1.0 + (-x).exp())
}
