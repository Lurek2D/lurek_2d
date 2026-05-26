//! INTERNAL ONLY: public `lurek.dataframe.*` constructors, transforms, and SQL
//! query behavior is covered by the Lua-first suite in
//! `tests/lua/unit/test_dataframe_core_unit.lua`.
//!
//! The remaining Rust coverage keeps the row iterator contract, which is not
//! exposed as a direct Lua API surface.

use lurek2d::dataframe::{CellValue, DataFrame};

#[test]
fn test_iter_rows_streams_rows_in_order() {
    let df = DataFrame::from_rows(
        vec!["id".to_string(), "name".to_string()],
        vec![
            vec![CellValue::Number(1.0), CellValue::Text("Alice".to_string())],
            vec![CellValue::Number(2.0), CellValue::Text("Bob".to_string())],
        ],
    )
    .unwrap();

    let mut rows = df.iter_rows();

    let first = rows.next().expect("first row should exist");
    assert_eq!(first.len(), 2);
    assert_eq!(first[0].0, "id");
    assert_eq!(first[0].1, &CellValue::Number(1.0));
    assert_eq!(first[1].0, "name");
    assert_eq!(first[1].1, &CellValue::Text("Alice".to_string()));

    let second = rows.next().expect("second row should exist");
    assert_eq!(second[0].1, &CellValue::Number(2.0));
    assert_eq!(second[1].1, &CellValue::Text("Bob".to_string()));

    assert!(rows.next().is_none());
}

// ── rolling_window ────────────────────────────────────────────────────────────

mod rolling_window_tests {
    use lurek2d::dataframe::{CellValue, DataFrame};

    /// Helper for approximate float equality in CellValue::Number.
    fn assert_number_near(cell: &CellValue, expected: f64) {
        match cell {
            CellValue::Number(val) => {
                let epsilon = 1e-9;
                assert!(
                    (val - expected).abs() < epsilon,
                    "expected Number({}) but got Number({})",
                    expected,
                    val
                );
            }
            other => panic!("expected Number({}) but got {:?}", expected, other),
        }
    }

    #[test]
    fn rolling_sum_returns_nil_when_window_contains_no_numeric_values() {
        let df = DataFrame::from_rows(
            vec!["value".to_string()],
            vec![
                vec![CellValue::Number(10.0)],
                vec![CellValue::Nil],
                vec![CellValue::Nil],
            ],
        )
        .unwrap();

        let result = df.rolling_sum(0, 2, "sum2").expect("rolling_sum should succeed");
        let sum_col = &result.data[1];

        // Window size 2:
        // index 0: [Number(10)] → count=1 → Number(10)
        // index 1: [Number(10), Nil] → count=1 → Number(10)
        // index 2: [Nil, Nil] → count=0 → Nil
        assert_number_near(&sum_col[0], 10.0);
        assert_number_near(&sum_col[1], 10.0);
        assert_eq!(sum_col[2], CellValue::Nil);
    }

    #[test]
    fn rolling_mean_returns_nil_when_window_contains_no_numeric_values() {
        let df = DataFrame::from_rows(
            vec!["value".to_string()],
            vec![
                vec![CellValue::Number(20.0)],
                vec![CellValue::Nil],
                vec![CellValue::Nil],
            ],
        )
        .unwrap();

        let result = df.rolling_mean(0, 2, "mean2").expect("rolling_mean should succeed");
        let mean_col = &result.data[1];

        assert_number_near(&mean_col[0], 20.0);
        assert_number_near(&mean_col[1], 20.0);
        assert_eq!(mean_col[2], CellValue::Nil);
    }

    #[test]
    fn rolling_sum_computes_expected_values_for_mixed_numeric_nil_windows() {
        let df = DataFrame::from_rows(
            vec!["value".to_string()],
            vec![
                vec![CellValue::Number(5.0)],
                vec![CellValue::Number(10.0)],
                vec![CellValue::Nil],
                vec![CellValue::Number(15.0)],
            ],
        )
        .unwrap();

        let result = df.rolling_sum(0, 3, "sum3").expect("rolling_sum should succeed");
        let sum_col = &result.data[1];

        // Window size 3:
        // index 0: [5] → 5
        // index 1: [5, 10] → 15
        // index 2: [5, 10, Nil] → 15
        // index 3: [10, Nil, 15] → 25
        assert_number_near(&sum_col[0], 5.0);
        assert_number_near(&sum_col[1], 15.0);
        assert_number_near(&sum_col[2], 15.0);
        assert_number_near(&sum_col[3], 25.0);
    }

    #[test]
    fn rolling_mean_computes_expected_values_for_mixed_numeric_nil_windows() {
        let df = DataFrame::from_rows(
            vec!["value".to_string()],
            vec![
                vec![CellValue::Number(6.0)],
                vec![CellValue::Number(12.0)],
                vec![CellValue::Nil],
            ],
        )
        .unwrap();

        let result = df.rolling_mean(0, 2, "mean2").expect("rolling_mean should succeed");
        let mean_col = &result.data[1];

        // Window size 2:
        // index 0: [6] → 6/1 = 6
        // index 1: [6, 12] → 18/2 = 9
        // index 2: [12, Nil] → 12/1 = 12
        assert_number_near(&mean_col[0], 6.0);
        assert_number_near(&mean_col[1], 9.0);
        assert_number_near(&mean_col[2], 12.0);
    }
}
