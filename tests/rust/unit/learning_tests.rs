//! INTERNAL ONLY: Rust-only tests for learning tensor helpers and evolutionary layer contracts.
//!
//! Public `lurek.learning.*` behaviour remains covered by Lua tests.

use lurek2d::learning::tensor::{gemm, LurekTensor};
use lurek2d::learning::{Activation, EvolutionaryLayer, NeuralLayer};
use lurek2d::learning::{Conv2D, GruLayer, LstmLayer, MaxPool2D};
use lurek2d::learning::{
    LayerNorm, LurekNeuralEngine, MultiHeadAttention, NeuralBlock, PositionalEncoding,
    TransformerDecoderBlock, TransformerEncoderBlock,
};

fn assert_slice_near(actual: &[f32], expected: &[f32]) {
    assert_eq!(actual.len(), expected.len());
    for (idx, (a, e)) in actual.iter().zip(expected.iter()).enumerate() {
        assert!((*a - *e).abs() < 1e-6, "index {idx}: expected {a} near {e}");
    }
}

mod tensor_tests {
    use super::*;

    #[test]
    fn flat_index_row_major_mapping() {
        let tensor = LurekTensor::new(vec![2, 3, 4], (0..24).map(|v| v as f32).collect());
        assert_eq!(tensor.flat_index(&[0, 0, 0]), Some(0));
        assert_eq!(tensor.flat_index(&[0, 1, 2]), Some(6));
        assert_eq!(tensor.flat_index(&[1, 2, 3]), Some(23));
    }

    #[test]
    fn flat_index_rejects_rank_or_bounds_mismatch() {
        let tensor = LurekTensor::new(vec![2, 2], vec![1.0, 2.0, 3.0, 4.0]);
        assert_eq!(tensor.flat_index(&[1]), None);
        assert_eq!(tensor.flat_index(&[2, 0]), None);
        assert_eq!(tensor.flat_index(&[0, 2]), None);
    }

    #[test]
    fn flatten_returns_one_dimensional_copy() {
        let tensor = LurekTensor::new(vec![2, 2], vec![1.0, 2.0, 3.0, 4.0]);
        let flat = tensor.flatten();
        assert_eq!(flat.shape, vec![4]);
        assert_slice_near(&flat.data, &[1.0, 2.0, 3.0, 4.0]);
    }

    #[test]
    fn gemm_multiplies_with_bias() {
        let a = vec![1.0, 2.0, 3.0, 4.0]; // [2 x 2]
        let b = vec![5.0, 6.0, 7.0, 8.0]; // [2 x 2]
        let out = gemm(2, 2, 2, &a, &b, Some(&[1.0, -1.0]));
        // A*B = [19,22,43,50], bias => [20,21,44,49]
        assert_slice_near(&out, &[20.0, 21.0, 44.0, 49.0]);
    }
}

mod evolutionary_trait_tests {
    use super::*;

    #[test]
    fn neural_layer_roundtrip_weights() {
        let mut layer = NeuralLayer::new(2, 3, Activation::Linear);
        let payload = vec![
            0.1, 0.2, 0.3, 0.4, 0.5, 0.6, // weights (3x2)
            -1.0, -2.0, -3.0, // biases
        ];

        assert!(layer.set_weights(&payload));
        assert_slice_near(&layer.get_weights(), &payload);
        assert_eq!(layer.param_count(), 9);
    }

    #[test]
    fn neural_layer_rejects_wrong_weight_count() {
        let mut layer = NeuralLayer::new(2, 2, Activation::Linear);
        assert!(!layer.set_weights(&[1.0, 2.0, 3.0]));
    }
}

mod conv_tests {
    use super::*;

    #[test]
    fn conv2d_roundtrip_weights() {
        let mut conv = Conv2D::new(1, 2, (2, 2), (1, 1), (0, 0));
        let payload: Vec<f32> = (0..conv.param_count()).map(|v| v as f32 * 0.1).collect();
        assert!(conv.set_weights(&payload));
        assert_slice_near(&conv.get_weights(), &payload);
    }

    #[test]
    fn conv2d_forward_identity_kernel() {
        let mut conv = Conv2D::new(1, 1, (1, 1), (1, 1), (0, 0));
        assert!(conv.set_weights(&[2.0, 1.0])); // weight=2, bias=1
        let input = LurekTensor::new(vec![1, 2, 2], vec![1.0, 2.0, 3.0, 4.0]);
        let out = conv.forward(&input).expect("conv forward should succeed");
        assert_eq!(out.shape, vec![1, 2, 2]);
        assert_slice_near(&out.data, &[3.0, 5.0, 7.0, 9.0]);
    }

    #[test]
    fn maxpool2d_forward_picks_local_max() {
        let pool = MaxPool2D::new((2, 2), (2, 2));
        let input = LurekTensor::new(
            vec![1, 4, 4],
            vec![
                1.0, 5.0, 2.0, 3.0, 7.0, 4.0, 0.0, 6.0, 9.0, 1.0, 8.0, 2.0, 3.0, 2.0, 4.0, 1.0,
            ],
        );
        let out = pool.forward(&input).expect("pool forward should succeed");
        assert_eq!(out.shape, vec![1, 2, 2]);
        assert_slice_near(&out.data, &[7.0, 6.0, 9.0, 8.0]);
    }
}

mod recurrent_tests {
    use super::*;

    #[test]
    fn lstm_roundtrip_weights() {
        let mut lstm = LstmLayer::new(3, 2);
        let payload: Vec<f32> = (0..lstm.param_count()).map(|v| v as f32 * 0.01).collect();
        assert!(lstm.set_weights(&payload));
        assert_slice_near(&lstm.get_weights(), &payload);
    }

    #[test]
    fn gru_roundtrip_weights() {
        let mut gru = GruLayer::new(3, 2);
        let payload: Vec<f32> = (0..gru.param_count()).map(|v| v as f32 * 0.01).collect();
        assert!(gru.set_weights(&payload));
        assert_slice_near(&gru.get_weights(), &payload);
    }

    #[test]
    fn lstm_step_returns_hidden_and_cell() {
        let mut lstm = LstmLayer::new(2, 3);
        let zeros = vec![0.0; lstm.param_count()];
        assert!(lstm.set_weights(&zeros));
        let (h, c) = lstm
            .step(&[1.0, -1.0], &[0.0, 0.0, 0.0], &[0.0, 0.0, 0.0])
            .expect("lstm step should succeed");
        assert_eq!(h.len(), 3);
        assert_eq!(c.len(), 3);
    }

    #[test]
    fn gru_step_returns_hidden() {
        let mut gru = GruLayer::new(2, 3);
        let zeros = vec![0.0; gru.param_count()];
        assert!(gru.set_weights(&zeros));
        let h = gru
            .step(&[1.0, -1.0], &[0.0, 0.0, 0.0])
            .expect("gru step should succeed");
        assert_eq!(h.len(), 3);
    }
}

mod attention_transformer_tests {
    use super::*;

    #[test]
    fn positional_encoding_applies_in_place() {
        let pe = PositionalEncoding::new(4, 8);
        let mut x = LurekTensor::zeros(vec![2, 4]);
        pe.apply(&mut x).expect("positional encoding should apply");
        assert!(x.data.iter().any(|v| v.abs() > 0.0));
    }

    #[test]
    fn mha_roundtrip_weights() {
        let mut mha = MultiHeadAttention::new(4, 2).expect("valid MHA config");
        let payload: Vec<f32> = (0..mha.param_count()).map(|v| v as f32 * 0.01).collect();
        assert!(mha.set_weights(&payload));
        assert_slice_near(&mha.get_weights(), &payload);
    }

    #[test]
    fn layer_norm_roundtrip_weights() {
        let mut ln = LayerNorm::new(4);
        let payload = vec![1.0, 2.0, 3.0, 4.0, -1.0, -2.0, -3.0, -4.0];
        assert!(ln.set_weights(&payload));
        assert_slice_near(&ln.get_weights(), &payload);
    }

    #[test]
    fn encoder_roundtrip_weights() {
        let mut enc = TransformerEncoderBlock::new(4, 2, 8).expect("valid encoder config");
        let payload: Vec<f32> = (0..enc.param_count()).map(|v| v as f32 * 0.001).collect();
        assert!(enc.set_weights(&payload));
        assert_slice_near(&enc.get_weights(), &payload);
    }

    #[test]
    fn decoder_roundtrip_weights() {
        let mut dec = TransformerDecoderBlock::new(4, 2, 8).expect("valid decoder config");
        let payload: Vec<f32> = (0..dec.param_count()).map(|v| v as f32 * 0.001).collect();
        assert!(dec.set_weights(&payload));
        assert_slice_near(&dec.get_weights(), &payload);
    }
}

mod engine_tests {
    use super::*;

    #[test]
    fn engine_roundtrip_flat_weights() {
        let mut engine = LurekNeuralEngine::new();
        engine.add_block(NeuralBlock::Dense(NeuralLayer::new(
            2,
            2,
            Activation::Linear,
        )));
        engine.add_block(NeuralBlock::Conv2D(Conv2D::new(
            1,
            1,
            (2, 2),
            (1, 1),
            (0, 0),
        )));
        engine.add_block(NeuralBlock::MaxPool2D(MaxPool2D::new((2, 2), (2, 2))));
        engine.add_block(NeuralBlock::Lstm(LstmLayer::new(2, 2)));
        engine.add_block(NeuralBlock::Gru(GruLayer::new(2, 2)));

        let payload: Vec<f32> = (0..engine.param_count()).map(|v| v as f32 * 0.01).collect();
        assert!(engine.set_weights(&payload));
        assert_slice_near(&engine.get_weights(), &payload);
        assert_eq!(engine.block_count(), 5);
    }
}
