//! File: tests/rust/unit/dataframe_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::dataframe::serial;
use lurek2d::dataframe::{CellValue, DataFrame};

fn assert_number_near(cell: &CellValue, expected: f64) {
    match cell {
        CellValue::Number(actual) => {
            assert!(
                (actual - expected).abs() < 1e-9,
                "expected Number({expected}) but got Number({actual})"
            );
        }
        other => panic!("expected Number({expected}) but got {other:?}"),
    }
}

#[test]
fn iter_rows_streams_rows_in_order() {
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
    assert_number_near(first[0].1, 1.0);
    assert_eq!(first[1].0, "name");
    assert_eq!(first[1].1, &CellValue::Text("Alice".to_string()));

    let second = rows.next().expect("second row should exist");
    assert_number_near(second[0].1, 2.0);
    assert_eq!(second[1].1, &CellValue::Text("Bob".to_string()));

    assert!(rows.next().is_none());
}

#[test]
fn schema_infers_nullable_and_mixed_columns() {
    let df = DataFrame::from_rows(
        vec!["id".to_string(), "mixed".to_string()],
        vec![
            vec![CellValue::Number(1.0), CellValue::Text("one".to_string())],
            vec![CellValue::Number(2.0), CellValue::Number(2.0)],
            vec![CellValue::Number(3.0), CellValue::Nil],
        ],
    )
    .expect("dataframe");

    let schema = df.schema();
    assert_eq!(schema[0].name, "id");
    assert_eq!(schema[0].dtype, "number");
    assert!(!schema[0].nullable);
    assert_eq!(schema[1].dtype, "mixed");
    assert!(schema[1].nullable);
}

#[test]
fn explain_validates_sql_and_reports_plan_shape() {
    let df = DataFrame::from_rows(
        vec!["name".to_string(), "score".to_string()],
        vec![
            vec![
                CellValue::Text("Alice".to_string()),
                CellValue::Number(10.0),
            ],
            vec![CellValue::Text("Bob".to_string()), CellValue::Number(20.0)],
        ],
    )
    .expect("dataframe");

    let plan = df
        .explain(Some("SELECT name FROM self WHERE score > 10 LIMIT 1"))
        .expect("valid plan");
    assert!(plan.contains("SQL DataFrame Plan"));
    assert!(plan.contains("projection: name"));
    assert!(df.explain(Some("SELECT name FROM self WHERE")).is_err());
}

#[test]
fn csv_parser_handles_quotes_newlines_and_rejects_ragged_rows() {
    let df = serial::from_csv("name,note\nAlice,\"hello, world\"\nBob,\"line1\nline2\"\n")
        .expect("quoted csv");
    assert_eq!(df.nrows(), 2);
    assert_eq!(
        df.get_value(0, lurek2d::dataframe::ColRef::Name("note".to_string()))
            .expect("note"),
        CellValue::Text("hello, world".to_string())
    );

    let err = match serial::from_csv("a,b\n1\n") {
        Ok(_) => panic!("ragged csv should fail"),
        Err(err) => err,
    };
    assert!(err.contains("expected 2"));
}

mod rolling_window_tests {
    use lurek2d::dataframe::frame::ColRef;
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

        let result = df
            .rolling_sum(ColRef::Index(1), 2, "sum2")
            .expect("rolling_sum should succeed");
        let sum_col = result
            .get_column(ColRef::Name("sum2".to_string()))
            .expect("sum2 col");

        // Window size 2:
        // index 0: [Number(10)] Ă˘â€ â€™ count=1 Ă˘â€ â€™ Number(10)
        // index 1: [Number(10), Nil] Ă˘â€ â€™ count=1 Ă˘â€ â€™ Number(10)
        // index 2: [Nil, Nil] Ă˘â€ â€™ count=0 Ă˘â€ â€™ Nil
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

        let result = df
            .rolling_mean(ColRef::Index(1), 2, "mean2")
            .expect("rolling_mean should succeed");
        let mean_col = result
            .get_column(ColRef::Name("mean2".to_string()))
            .expect("mean2 col");
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

        let result = df
            .rolling_sum(ColRef::Index(1), 3, "sum3")
            .expect("rolling_sum should succeed");
        let sum_col = result
            .get_column(ColRef::Name("sum3".to_string()))
            .expect("sum3 col");

        // Window size 3:
        // index 0: [5] Ă˘â€ â€™ 5
        // index 1: [5, 10] Ă˘â€ â€™ 15
        // index 2: [5, 10, Nil] Ă˘â€ â€™ 15
        // index 3: [10, Nil, 15] Ă˘â€ â€™ 25
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

        let result = df
            .rolling_mean(ColRef::Index(1), 2, "mean2")
            .expect("rolling_mean should succeed");
        let mean_col = result
            .get_column(ColRef::Name("mean2".to_string()))
            .expect("mean2 col");
        // index 0: [6] Ă˘â€ â€™ 6/1 = 6
        // index 1: [6, 12] Ă˘â€ â€™ 18/2 = 9
        // index 2: [12, Nil] Ă˘â€ â€™ 12/1 = 12
        assert_number_near(&mean_col[0], 6.0);
        assert_number_near(&mean_col[1], 9.0);
        assert_number_near(&mean_col[2], 12.0);
    }
}
