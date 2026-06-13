//! File: tests/rust/unit/compute_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::compute::array::{DataType, NdArray};
use lurek2d::compute::linalg;
use lurek2d::compute::ops;

fn assert_vec_near(actual: &[f64], expected: &[f64]) {
    assert_eq!(actual.len(), expected.len());
    for (index, (actual, expected)) in actual.iter().zip(expected.iter()).enumerate() {
        assert!(
            (actual - expected).abs() < 1e-6,
            "index {index}: expected {expected}, got {actual}"
        );
    }
}

mod array_tests {
    use super::*;

    #[test]
    fn dtype_byte_size() {
        assert_eq!(DataType::Float32.byte_size(), 4);
        assert_eq!(DataType::Float64.byte_size(), 8);
        assert_eq!(DataType::Int32.byte_size(), 4);
    }

    #[test]
    fn strides() {
        assert_eq!(NdArray::compute_strides(&[5]), vec![1]);
        assert_eq!(NdArray::compute_strides(&[3, 4]), vec![4, 1]);
        assert_eq!(NdArray::compute_strides(&[2, 3, 4]), vec![12, 4, 1]);
        assert_eq!(NdArray::compute_strides(&[2, 3, 4, 5]), vec![60, 20, 5, 1]);
    }

    #[test]
    fn ndarray_fill_map_iter_work() {
        let mut arr = NdArray::zeros(&[4], DataType::Float32).expect("alloc");
        arr.fill(3.0);
        assert_vec_near(&arr.to_f64_vec(), &[3.0, 3.0, 3.0, 3.0]);

        let mapped = arr.map(|x| x * 2.0).expect("map");
        assert_vec_near(&mapped.to_f64_vec(), &[6.0, 6.0, 6.0, 6.0]);

        let collected: Vec<f64> = mapped.iter_f64().collect();
        assert_vec_near(&collected, &[6.0, 6.0, 6.0, 6.0]);
    }

    #[test]
    fn constructors_reject_invalid_shapes_and_lengths() {
        let empty = NdArray::zeros(&[], DataType::Float32);
        assert!(empty.is_err());

        let mismatch = NdArray::from_slice(&[1.0, 2.0], &[3], DataType::Float64);
        assert!(mismatch.is_err());
    }

    #[test]
    fn binary_ops_reject_dtype_mismatch() {
        let left = NdArray::ones(&[2], DataType::Float32).expect("left");
        let right = NdArray::ones(&[2], DataType::Float64).expect("right");
        let err = ops::add(&left, &right).expect_err("dtype mismatch should fail");
        assert!(err.contains("dtype mismatch"));
    }
}

mod linalg_tests {
    use super::*;

    #[test]
    fn lu_decompose_singular_matrix_has_zero_u_diagonal() {
        let singular =
            NdArray::from_slice(&[1.0, 2.0, 2.0, 4.0], &[2, 2], DataType::Float64).expect("matrix");
        let decomp = linalg::lu_decompose(&singular).expect("lu should still return factors");
        // For singular matrices, U has a near-zero pivot on the diagonal.
        let u11 = decomp.lu_data[decomp.n + 1];
        assert!(u11.abs() < 1e-12, "expected near-zero pivot, got {u11}");
    }
}
