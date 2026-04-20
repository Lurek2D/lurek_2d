//! Tests for the dataframe module.

use lurek2d::dataframe::frame::{AggFn, CellValue, ColRef, DataFrame, Database};
use lurek2d::dataframe::serial::from_csv;
use lurek2d::dataframe::sql::query_sql;
use std::cmp::Ordering;

// ── frame (CellValue, DataFrame, Database) ─────────────────────────────────

mod frame_tests {
    use super::*;

    // ── CellValue ──────────────────────────────────────────────────────────

    #[test]
    fn cell_nil_is_nil() {
        assert!(CellValue::Nil.is_nil());
        assert!(!CellValue::Number(1.0).is_nil());
        assert!(!CellValue::Text("a".into()).is_nil());
        assert!(!CellValue::Bool(true).is_nil());
    }

    #[test]
    fn cell_as_number() {
        assert_eq!(CellValue::Number(3.14).as_number(), Some(3.14));
        assert_eq!(CellValue::Nil.as_number(), None);
        assert_eq!(CellValue::Text("x".into()).as_number(), None);
    }

    #[test]
    fn cell_as_text() {
        assert_eq!(CellValue::Text("hi".into()).as_text(), Some("hi"));
        assert_eq!(CellValue::Number(1.0).as_text(), None);
    }

    #[test]
    fn cell_as_bool() {
        assert_eq!(CellValue::Bool(true).as_bool(), Some(true));
        assert_eq!(CellValue::Nil.as_bool(), None);
    }

    #[test]
    fn cell_cmp_nil_sorts_last() {
        assert_eq!(
            CellValue::Nil.cmp_for_sort(&CellValue::Nil),
            Ordering::Equal
        );
        assert_eq!(
            CellValue::Nil.cmp_for_sort(&CellValue::Number(1.0)),
            Ordering::Greater
        );
        assert_eq!(
            CellValue::Number(1.0).cmp_for_sort(&CellValue::Nil),
            Ordering::Less
        );
    }

    #[test]
    fn cell_cmp_cross_type_ordering() {
        // Number < Text < Bool
        assert_eq!(
            CellValue::Number(1.0).cmp_for_sort(&CellValue::Text("a".into())),
            Ordering::Less
        );
        assert_eq!(
            CellValue::Text("a".into()).cmp_for_sort(&CellValue::Bool(true)),
            Ordering::Less
        );
    }

    #[test]
    fn cell_display_integer_format() {
        assert_eq!(format!("{}", CellValue::Number(5.0)), "5");
        assert_eq!(format!("{}", CellValue::Number(3.14)), "3.14");
        assert_eq!(format!("{}", CellValue::Nil), "nil");
        assert_eq!(format!("{}", CellValue::Bool(false)), "false");
        assert_eq!(format!("{}", CellValue::Text("hi".into())), "hi");
    }

    // ── DataFrame basics ───────────────────────────────────────────────────

    #[test]
    fn empty_dataframe() {
        let df = DataFrame::new();
        assert_eq!(df.nrows(), 0);
        assert_eq!(df.ncols(), 0);
        assert_eq!(df.count(), 0);
        assert!(df.columns().is_empty());
    }

    #[test]
    fn resolve_col_by_name() {
        let df = DataFrame::from_raw(
            vec!["a".into(), "b".into()],
            vec![vec![CellValue::Nil], vec![CellValue::Nil]],
        );
        assert_eq!(df.resolve_col(ColRef::Name("a".into())).unwrap(), 0);
        assert_eq!(df.resolve_col(ColRef::Name("b".into())).unwrap(), 1);
        assert!(df.resolve_col(ColRef::Name("c".into())).is_err());
    }

    #[test]
    fn resolve_col_by_index_one_based() {
        let df = DataFrame::from_raw(
            vec!["x".into(), "y".into()],
            vec![vec![CellValue::Nil], vec![CellValue::Nil]],
        );
        assert_eq!(df.resolve_col(ColRef::Index(1)).unwrap(), 0);
        assert_eq!(df.resolve_col(ColRef::Index(2)).unwrap(), 1);
        assert!(df.resolve_col(ColRef::Index(0)).is_err());
        assert!(df.resolve_col(ColRef::Index(3)).is_err());
    }

    #[test]
    fn add_and_remove_column() {
        let mut df = DataFrame::from_raw(
            vec!["a".into()],
            vec![vec![CellValue::Number(1.0), CellValue::Number(2.0)]],
        );
        assert_eq!(df.ncols(), 1);
        df.add_column("b", CellValue::Nil).unwrap();
        assert_eq!(df.ncols(), 2);
        assert_eq!(df.nrows(), 2);
        // duplicate name is error
        assert!(df.add_column("a", CellValue::Nil).is_err());
        df.remove_column(ColRef::Name("b".into())).unwrap();
        assert_eq!(df.ncols(), 1);
    }

    #[test]
    fn rename_column() {
        let mut df = DataFrame::from_raw(
            vec!["a".into(), "b".into()],
            vec![vec![CellValue::Nil], vec![CellValue::Nil]],
        );
        df.rename_column(ColRef::Name("a".into()), "x").unwrap();
        assert_eq!(df.columns()[0], "x");
        // rename to existing name is error
        assert!(df.rename_column(ColRef::Name("x".into()), "b").is_err());
    }

    #[test]
    fn add_row_and_get_value() {
        let mut df = DataFrame::from_raw(vec!["name".into(), "score".into()], vec![vec![], vec![]]);
        let idx = df.add_row(&[
            ("name".into(), CellValue::Text("Alice".into())),
            ("score".into(), CellValue::Number(42.0)),
        ]);
        assert_eq!(idx, 0);
        assert_eq!(df.nrows(), 1);
        let val = df.get_value(0, ColRef::Name("score".into())).unwrap();
        assert_eq!(val, CellValue::Number(42.0));
    }

    #[test]
    fn set_value_and_get_row() {
        let mut df = DataFrame::from_raw(vec!["a".into()], vec![vec![CellValue::Number(1.0)]]);
        df.set_value(0, ColRef::Name("a".into()), CellValue::Number(99.0))
            .unwrap();
        let row = df.get_row(0).unwrap();
        assert_eq!(row[0].1, CellValue::Number(99.0));
    }

    #[test]
    fn remove_row() {
        let mut df = DataFrame::from_raw(
            vec!["a".into()],
            vec![vec![
                CellValue::Number(1.0),
                CellValue::Number(2.0),
                CellValue::Number(3.0),
            ]],
        );
        df.remove_row(1).unwrap();
        assert_eq!(df.nrows(), 2);
        assert_eq!(
            df.get_value(1, ColRef::Index(1)).unwrap(),
            CellValue::Number(3.0)
        );
        assert!(df.remove_row(10).is_err());
    }

    #[test]
    fn clone_df() {
        let df = DataFrame::from_raw(vec!["a".into()], vec![vec![CellValue::Number(7.0)]]);
        let cloned = df.clone_df();
        assert_eq!(cloned.nrows(), 1);
        assert_eq!(
            cloned.get_value(0, ColRef::Index(1)).unwrap(),
            CellValue::Number(7.0)
        );
    }

    // ── AggFn ──────────────────────────────────────────────────────────────

    #[test]
    fn aggfn_parse() {
        assert!(AggFn::parse("mean").is_ok());
        assert!(AggFn::parse("SUM").is_ok());
        assert!(AggFn::parse("count").is_ok());
        assert!(AggFn::parse("first").is_ok());
        assert!(AggFn::parse("last").is_ok());
        assert!(AggFn::parse("nope").is_err());
    }

    // ── Database ───────────────────────────────────────────────────────────

    #[test]
    fn database_crud() {
        let mut db = Database::new();
        assert!(!db.has_table("t"));
        let df = DataFrame::new();
        db.add_table("t", df);
        assert!(db.has_table("t"));
        assert!(db.get_table("t").is_some());
        let tables = db.list_tables();
        assert_eq!(tables, vec!["t"]);
        db.remove_table("t");
        assert!(!db.has_table("t"));
    }

    // ── Random generation ──────────────────────────────────────────────────

    #[test]
    fn random_dataframe_dimensions() {
        let defs = vec![("id".into(), "int".into()), ("name".into(), "name".into())];
        let df = DataFrame::random(&defs, 10, Some(42));
        assert_eq!(df.nrows(), 10);
        assert_eq!(df.ncols(), 2);
    }
}

// ── query ──────────────────────────────────────────────────────────────────

mod query_tests {
    use super::*;

    /// Helper: create a small 3-row DataFrame for query tests.
    fn sample_df() -> DataFrame {
        DataFrame::from_raw(
            vec!["name".into(), "score".into()],
            vec![
                vec![
                    CellValue::Text("Alice".into()),
                    CellValue::Text("Bob".into()),
                    CellValue::Text("Charlie".into()),
                ],
                vec![
                    CellValue::Number(90.0),
                    CellValue::Number(70.0),
                    CellValue::Number(85.0),
                ],
            ],
        )
    }

    #[test]
    fn filter_eq() {
        let df = sample_df();
        let result = df
            .filter(
                ColRef::Name("name".into()),
                "==",
                &CellValue::Text("Bob".into()),
            )
            .unwrap();
        assert_eq!(result.nrows(), 1);
        assert_eq!(
            result.get_value(0, ColRef::Name("name".into())).unwrap(),
            CellValue::Text("Bob".into())
        );
    }

    #[test]
    fn filter_gt() {
        let df = sample_df();
        let result = df
            .filter(ColRef::Name("score".into()), ">", &CellValue::Number(80.0))
            .unwrap();
        assert_eq!(result.nrows(), 2); // Alice=90, Charlie=85
    }

    #[test]
    fn filter_unsupported_op() {
        let df = sample_df();
        assert!(df
            .filter(ColRef::Name("score".into()), "~", &CellValue::Number(1.0))
            .is_err());
    }

    #[test]
    fn sort_ascending() {
        let df = sample_df();
        let sorted = df.sort(ColRef::Name("score".into()), true).unwrap();
        assert_eq!(
            sorted.get_value(0, ColRef::Name("score".into())).unwrap(),
            CellValue::Number(70.0)
        );
        assert_eq!(
            sorted.get_value(2, ColRef::Name("score".into())).unwrap(),
            CellValue::Number(90.0)
        );
    }

    #[test]
    fn sort_descending() {
        let df = sample_df();
        let sorted = df.sort(ColRef::Name("score".into()), false).unwrap();
        assert_eq!(
            sorted.get_value(0, ColRef::Name("score".into())).unwrap(),
            CellValue::Number(90.0)
        );
    }

    #[test]
    fn head_and_tail() {
        let df = sample_df();
        let h = df.head(2);
        assert_eq!(h.nrows(), 2);
        let t = df.tail(1);
        assert_eq!(t.nrows(), 1);
        assert_eq!(
            t.get_value(0, ColRef::Name("name".into())).unwrap(),
            CellValue::Text("Charlie".into())
        );
    }

    #[test]
    fn head_exceeds_rows() {
        let df = sample_df();
        let h = df.head(100);
        assert_eq!(h.nrows(), 3);
    }

    #[test]
    fn slice_range() {
        let df = sample_df();
        let s = df.slice(1, 2).unwrap();
        assert_eq!(s.nrows(), 2);
        assert_eq!(
            s.get_value(0, ColRef::Name("name".into())).unwrap(),
            CellValue::Text("Bob".into())
        );
    }

    #[test]
    fn slice_out_of_range() {
        let df = sample_df();
        assert!(df.slice(10, 20).is_err());
    }

    #[test]
    fn select_columns() {
        let df = sample_df();
        let projected = df.select_columns(&[ColRef::Name("name".into())]).unwrap();
        assert_eq!(projected.ncols(), 1);
        assert_eq!(projected.columns()[0], "name");
        assert_eq!(projected.nrows(), 3);
    }

    #[test]
    fn unique_values() {
        let df = DataFrame::from_raw(
            vec!["x".into()],
            vec![vec![
                CellValue::Number(1.0),
                CellValue::Number(2.0),
                CellValue::Number(1.0),
            ]],
        );
        let uniq = df.unique(ColRef::Name("x".into())).unwrap();
        assert_eq!(uniq.len(), 2);
    }

    #[test]
    fn filter_contains() {
        let df = sample_df();
        let result = df
            .filter(
                ColRef::Name("name".into()),
                "contains",
                &CellValue::Text("li".into()),
            )
            .unwrap();
        // "Alice" and "Charlie" contain "li"
        assert_eq!(result.nrows(), 2);
    }
}

// ── serial ─────────────────────────────────────────────────────────────────

mod serial_tests {
    use super::*;

    #[test]
    fn csv_round_trip_preserves_column_names_and_row_count() {
        let csv = "name,age\nalice,30\nbob,25\n";
        let df = from_csv(csv).unwrap();
        assert_eq!(df.ncols(), 2);
        assert_eq!(df.nrows(), 2);
        let back = df.to_csv();
        assert!(back.contains("name") && back.contains("age"));
    }

    #[test]
    fn from_csv_empty_input_returns_empty_dataframe() {
        let df = from_csv("").unwrap();
        assert_eq!(df.ncols(), 0);
        assert_eq!(df.nrows(), 0);
    }
}

// ── sql ────────────────────────────────────────────────────────────────────

mod sql_tests {
    use super::*;

    #[test]
    fn query_sql_select_star_returns_all_rows() {
        let df = from_csv("a,b\n1,2\n3,4\n").unwrap();
        let result = query_sql(&df, "SELECT * FROM df").unwrap();
        assert_eq!(result.nrows(), 2);
        assert_eq!(result.ncols(), 2);
    }

    #[test]
    fn query_sql_where_clause_filters_rows() {
        let df = from_csv("x,y\n10,1\n20,2\n30,3\n").unwrap();
        let result = query_sql(&df, "SELECT * FROM df WHERE x > 15").unwrap();
        assert_eq!(result.nrows(), 2);
    }
}
