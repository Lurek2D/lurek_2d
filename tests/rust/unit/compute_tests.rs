//! INTERNAL ONLY: Rust-only tests for compute internals that are not directly asserted through
//! `lurek.compute.*`.
//!
//! Public ndarray/FFT/ops/spatial behaviour is covered by the Lua-first suite
//! in `tests/lua/unit/test_compute_unit.lua`. The remaining Rust coverage here
//! keeps lightweight type/layout invariants.

use lurek2d::compute::array::{DataType, NdArray};
use lurek2d::compute::linalg;

// ── array ──────────────────────────────────────────────────────────────────

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
        assert_eq!(arr.to_f64_vec(), vec![3.0, 3.0, 3.0, 3.0]);

        let mapped = arr.map(|x| x * 2.0).expect("map");
        assert_eq!(mapped.to_f64_vec(), vec![6.0, 6.0, 6.0, 6.0]);

        let collected: Vec<f64> = mapped.iter_f64().collect();
        assert_eq!(collected, vec![6.0, 6.0, 6.0, 6.0]);
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
