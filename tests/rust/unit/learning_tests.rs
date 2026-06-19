//! INTERNAL ONLY: Rust-only tests for learning tensor helpers and evolutionary layer contracts.
//!
//! Public `lurek.learning.*` behaviour remains covered by Lua tests.

use lurek2d::learning::onnx::OnnxLoadOptions;
use lurek2d::learning::tensor::{gemm, try_gemm, LurekTensor};
use lurek2d::learning::{
    Activation, EvolutionaryLayer, GeneticAlgorithm, LayerNorm, LurekNeuralEngine,
    MultiHeadAttention, NeuralBlock, NeuralLayer, NeuralNet, Neuroevolution, OnnxModel,
    PositionalEncoding, QLearner, TransformerDecoderBlock, TransformerEncoderBlock,
};
use lurek2d::learning::{Conv2D, GruLayer, LstmLayer, MaxPool2D};
use std::path::PathBuf;

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

    #[test]
    fn tensor_try_new_rejects_shape_data_mismatch() {
        let err = LurekTensor::try_new(vec![2, 2], vec![1.0, 2.0, 3.0]).unwrap_err();
        assert_eq!(err.to_string(), "tensor shape expects 4 element(s), got 3");
    }

    #[test]
    fn tensor_try_new_rejects_zero_dim() {
        let err = LurekTensor::try_new(vec![2, 0], vec![]).unwrap_err();
        assert!(err.to_string().contains("axis 1"));
    }

    #[test]
    fn tensor_try_new_accepts_scalar_empty_shape() {
        let tensor = LurekTensor::try_new(vec![], vec![7.0]).expect("scalar tensor should work");
        assert_eq!(tensor.shape, Vec::<usize>::new());
        assert_slice_near(&tensor.data, &[7.0]);
    }

    #[test]
    fn tensor_zeros_rejects_overflow() {
        let err = LurekTensor::try_zeros(vec![usize::MAX, 2]).unwrap_err();
        let message = err.to_string();
        assert!(
            message.contains("overflowed") || message.contains("exceeds configured limit"),
            "unexpected tensor allocation error: {}",
            message
        );
    }

    #[test]
    fn gemm_rejects_short_inputs() {
        let err = try_gemm(2, 2, 2, &[1.0, 2.0], &[3.0, 4.0, 5.0, 6.0], None).unwrap_err();
        assert!(err.to_string().contains("gemm left matrix length mismatch"));
    }

    #[test]
    fn gemm_rejects_zero_dims() {
        let err = try_gemm(0, 2, 2, &[], &[], None).unwrap_err();
        assert!(err.to_string().contains("rows"));
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

    #[test]
    fn neural_forward_rejects_wrong_input_len() {
        let layer = NeuralLayer::new(2, 2, Activation::Linear);
        let err = layer.try_forward(&[1.0]).unwrap_err();
        assert!(err
            .to_string()
            .contains("dense layer input length mismatch"));
    }

    #[test]
    fn neural_net_rejects_invalid_topology() {
        let mut net = NeuralNet::new();
        net.add_layer(2, 3, Activation::Linear);
        let err = net
            .try_add_layer(4, 1, Activation::Linear)
            .expect_err("mismatched topology should fail");
        assert!(err.to_string().contains("expects 4 input"));
    }

    #[test]
    fn softmax_empty_no_nan() {
        let mut values = Vec::<f32>::new();
        Activation::Softmax
            .try_apply(&mut values)
            .expect("empty softmax should be a no-op");
        assert!(values.is_empty());
    }

    #[test]
    fn softmax_rejects_nan_input() {
        let mut values = vec![1.0, f32::NAN];
        let err = Activation::Softmax
            .try_apply(&mut values)
            .expect_err("NaN input should be rejected");
        assert!(err.to_string().contains("activation input"));
    }
}

mod qlearner_tests {
    use super::*;

    #[test]
    fn qlearner_zero_actions_rejected() {
        let err = match QLearner::try_new(4, 0) {
            Ok(_) => panic!("zero-action qlearner should fail"),
            Err(err) => err,
        };
        assert!(err.to_string().contains("action_count"));
    }

    #[test]
    fn qlearner_zero_states_rejected() {
        let err = match QLearner::try_new(0, 4) {
            Ok(_) => panic!("zero-state qlearner should fail"),
            Err(err) => err,
        };
        assert!(err.to_string().contains("state_count"));
    }

    #[test]
    fn qlearner_deserialize_rejects_invalid_json_token() {
        let mut learner = QLearner::new_with_seed(2, 2, 11);
        let err = learner.try_deserialize("[[1,\"bad\"],[2,3]]").unwrap_err();
        assert!(!err.to_string().is_empty());
    }

    #[test]
    fn qlearner_deserialize_rejects_non_finite_values() {
        let mut learner = QLearner::new_with_seed(1, 1, 11);
        let err = learner
            .try_deserialize("{\"version\":1,\"state_count\":1,\"action_count\":1,\"qtable\":[[null]],\"alpha\":0.1,\"gamma\":0.9,\"epsilon\":0.1,\"epsilon_decay\":0.99,\"episode_count\":0,\"rng_state\":1}")
            .unwrap_err();
        assert!(!err.to_string().is_empty());
    }

    #[test]
    fn learning_rng_reproducibility() {
        let mut a = QLearner::new_with_seed(2, 3, 99);
        let mut b = QLearner::new_with_seed(2, 3, 99);
        a.epsilon = 1.0;
        b.epsilon = 1.0;

        let mut seq_a = Vec::new();
        let mut seq_b = Vec::new();
        for _ in 0..8 {
            seq_a.push(a.try_choose_action(0).unwrap());
            seq_b.push(b.try_choose_action(0).unwrap());
        }
        assert_eq!(seq_a, seq_b);

        let snapshot = a.rng_snapshot();
        let next_a = a.try_choose_action(0).unwrap();
        a.restore_rng_snapshot(snapshot).unwrap();
        let replayed = a.try_choose_action(0).unwrap();
        assert_eq!(next_a, replayed);
    }
}

mod genetic_tests {
    use super::*;

    #[test]
    fn genetic_empty_population_rejected() {
        let err = match GeneticAlgorithm::try_new(0, 4, 7) {
            Ok(_) => panic!("zero-sized population should fail"),
            Err(err) => err,
        };
        assert!(err.to_string().contains("population size"));
    }

    #[test]
    fn genetic_evolve_clamps_tournament_and_elitism() {
        let mut ga = GeneticAlgorithm::new(4, 3, 17);
        ga.tournament_size = 0;
        ga.elitism = 99;
        ga.try_evolve()
            .expect("out-of-range tournament and elitism should be normalized");
        assert_eq!(ga.generation, 1);
        assert_eq!(ga.pop_size(), 4);
    }

    #[test]
    fn genetic_zero_gene_count_rejected() {
        let err = match GeneticAlgorithm::try_new(4, 0, 7) {
            Ok(_) => panic!("zero gene count should fail"),
            Err(err) => err,
        };
        assert!(err.to_string().contains("gene_count"));
    }

    #[test]
    fn genetic_cleared_population_returns_error_not_panic() {
        let mut ga = GeneticAlgorithm::new(1, 1, 7);
        ga.population.clear();
        let err = ga
            .try_evolve()
            .expect_err("cleared population should fail cleanly");
        assert!(err.to_string().contains("population size"));
    }

    #[test]
    fn neuroevolution_uses_safe_ga_constructor() {
        let err = match Neuroevolution::try_new(vec![(2, 3, "relu")], 0, 1) {
            Ok(_) => panic!("zero-sized neuroevolution population should fail"),
            Err(err) => err,
        };
        assert!(err.to_string().contains("population size"));
    }
}

mod onnx_tests {
    use super::*;

    fn fixture_path() -> String {
        "tests/lua/fixtures/minimal_identity.onnx".to_string()
    }

    #[test]
    fn onnx_load_rejects_path_outside_sandbox() {
        let options = OnnxLoadOptions {
            sandbox_root: Some(PathBuf::from("src")),
            ..OnnxLoadOptions::default()
        };
        let err = match OnnxModel::load_with_options(&fixture_path(), &options) {
            Ok(_) => panic!("fixture path should be outside the src sandbox"),
            Err(err) => err,
        };
        assert!(err.to_string().contains("outside sandbox"));
    }

    #[test]
    fn onnx_load_rejects_file_too_large() {
        let options = OnnxLoadOptions {
            max_file_bytes: 0,
            ..OnnxLoadOptions::default()
        };
        let err = match OnnxModel::load_with_options(&fixture_path(), &options) {
            Ok(_) => panic!("fixture model should exceed zero-byte limit"),
            Err(err) => err,
        };
        assert!(err.to_string().contains("exceeding limit"));
    }

    #[test]
    fn onnx_run_rejects_input_count_mismatch() {
        let model = OnnxModel::load(&fixture_path()).expect("fixture model should load");
        let err = model.try_run(Vec::new()).unwrap_err();
        assert!(err.to_string().contains("expects 1 input tensor"));
    }

    #[test]
    fn onnx_run_rejects_output_limit() {
        let options = OnnxLoadOptions {
            max_output_elements: 0,
            ..OnnxLoadOptions::default()
        };
        let model =
            OnnxModel::load_with_options(&fixture_path(), &options).expect("fixture model loads");
        let input = LurekTensor::try_new(vec![1], vec![42.0]).unwrap();
        let err = model.try_run(vec![input]).unwrap_err();
        assert!(err.to_string().contains("ONNX output tensor"));
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
