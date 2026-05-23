//! `lurek.dataframe` -- DataFrame bindings for tabular rows, columns, grouping, joins, SQL queries, lazy pipelines, databases, vectorized frames, serialization, and statistics.

use super::SharedState;
use crate::dataframe::file_io::{self, DataFrameFileError};
use crate::dataframe::frame::{AggFn, CellValue, ColRef, DataFrame, Database};
use crate::dataframe::lazy::LazyQuery;
use crate::dataframe::serial;
use crate::dataframe::sql;
use crate::dataframe::task::DataFrameTask;
use crate::dataframe::vectorized::{BinaryOp, CmpOp, ReduceOp, ScalarOp, VecFrame};
use crate::runtime::error::EngineError;
use mlua::prelude::*;
use std::cell::{Cell, Ref, RefCell};
use std::rc::Rc;
/// Converts a Lua column name or one-based index into a column reference.
fn lua_to_col_ref(v: LuaValue) -> LuaResult<ColRef> {
    match v {
        LuaValue::String(s) => Ok(ColRef::Name(s.to_str()?.to_string())),
        LuaValue::Integer(i) if i >= 1 => Ok(ColRef::Index(i as usize)),
        LuaValue::Number(n) if n >= 1.0 => Ok(ColRef::Index(n as usize)),
        _ => Err(LuaError::RuntimeError(
            "column must be a string name or 1-based integer".into(),
        )),
    }
}
/// Converts a Lua scalar value into a dataframe cell value.
fn lua_to_cell(v: LuaValue) -> CellValue {
    match v {
        LuaValue::Nil => CellValue::Nil,
        LuaValue::Boolean(b) => CellValue::Bool(b),
        LuaValue::Integer(i) => CellValue::Number(i as f64),
        LuaValue::Number(n) => CellValue::Number(n),
        LuaValue::String(s) => CellValue::Text(s.to_str().unwrap_or("").to_string()),
        _ => CellValue::Nil,
    }
}
/// Converts a Lua array table into positional dataframe cell values.
fn lua_table_to_cells(tbl: LuaTable) -> LuaResult<Vec<CellValue>> {
    let len = tbl.raw_len();
    let mut values = Vec::with_capacity(len);
    for i in 1..=len {
        let value: LuaValue = tbl.raw_get(i)?;
        values.push(lua_to_cell(value));
    }
    Ok(values)
}
/// Converts a Lua array table into positional column references.
fn lua_table_to_col_refs(tbl: LuaTable) -> LuaResult<Vec<ColRef>> {
    let len = tbl.raw_len();
    let mut cols = Vec::with_capacity(len);
    for i in 1..=len {
        let value: LuaValue = tbl.raw_get(i)?;
        cols.push(lua_to_col_ref(value)?);
    }
    Ok(cols)
}
/// Converts a dataframe cell value into a Lua value.
fn cell_to_lua<'lua>(lua: &'lua Lua, cell: &CellValue) -> LuaResult<LuaValue<'lua>> {
    match cell {
        CellValue::Nil => Ok(LuaValue::Nil),
        CellValue::Number(n) => Ok(LuaValue::Number(*n)),
        CellValue::Text(s) => Ok(LuaValue::String(lua.create_string(s)?)),
        CellValue::Bool(b) => Ok(LuaValue::Boolean(*b)),
    }
}
/// Converts a one-based Lua row index into a zero-based dataframe row index.
fn validate_row(row: usize) -> LuaResult<usize> {
    if row == 0 {
        return Err(LuaError::RuntimeError("row index must be >= 1".into()));
    }
    Ok(row - 1)
}
/// Validates dataframe persistence options accepted by file APIs with fixed formats.
fn validate_dataframe_file_opts(
    opts: Option<LuaTable>,
    caller: &str,
    supported_formats: &[&str],
) -> LuaResult<()> {
    if let Some(tbl) = opts {
        if let Some(format) = tbl.get::<_, Option<String>>("format")? {
            if !supported_formats
                .iter()
                .any(|supported| format.eq_ignore_ascii_case(supported))
            {
                return Err(LuaError::RuntimeError(format!(
                    "{caller}: only {} dataframe file format is supported",
                    supported_formats.join("/")
                )));
            }
        }
    }
    Ok(())
}
/// Validates database persistence options accepted by the JSON-only file API.
fn validate_database_file_opts(opts: Option<LuaTable>, caller: &str) -> LuaResult<()> {
    if let Some(tbl) = opts {
        if let Some(format) = tbl.get::<_, Option<String>>("format")? {
            if !format.eq_ignore_ascii_case("json") {
                return Err(LuaError::RuntimeError(format!(
                    "{caller}: only JSON database file format is supported"
                )));
            }
        }
    }
    Ok(())
}
/// Converts dataframe file persistence errors into Lua-visible error categories.
fn dataframe_file_error_to_lua(error: DataFrameFileError<EngineError>) -> LuaError {
    match error {
        DataFrameFileError::Storage(error) => LuaError::external(error),
        DataFrameFileError::Format(message) => LuaError::RuntimeError(message),
    }
}
/// Lua-side grouped dataframe object containing group keys and subframes.
pub struct LuaGroupedFrame {
    /// Group key and dataframe pairs created by `groupByObj`.
    groups: Vec<(CellValue, DataFrame)>,
    /// Shared runtime state used when grouped operations create dataframe handles.
    state: Rc<RefCell<SharedState>>,
}
impl LuaGroupedFrame {
    /// Creates a grouped frame wrapper from precomputed groups.
    fn new(groups: Vec<(CellValue, DataFrame)>, state: Rc<RefCell<SharedState>>) -> Self {
        Self { groups, state }
    }
}
impl LuaUserData for LuaGroupedFrame {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- aggregate --
        /// Aggregates one numeric column in every group by calling a Lua function with that group's numeric values.
        /// @param | col_name | string | Column name to aggregate in each group.
        /// @param | func | function | Function called with an array table of numeric values and returning a number.
        /// @return | LDataFrame | DataFrame containing `group_key` and the aggregated column.
        methods.add_method(
            "aggregate",
            |lua, this, (col_name, func): (String, LuaFunction)| {
                let mut result = DataFrame::new();
                result
                    .add_column("group_key", CellValue::Nil)
                    .map_err(LuaError::RuntimeError)?;
                result
                    .add_column(&col_name, CellValue::Nil)
                    .map_err(LuaError::RuntimeError)?;
                for (key, sub_df) in &this.groups {
                    let col_ref = ColRef::Name(col_name.clone());
                    let cell_vals = sub_df.get_column(col_ref).map_err(LuaError::RuntimeError)?;
                    let vals_tbl = lua.create_table()?;
                    let mut idx = 0usize;
                    for cv in cell_vals {
                        if let Some(n) = cv.as_number() {
                            idx += 1;
                            vals_tbl.set(idx, n)?;
                        }
                    }
                    let agg: f64 = func.call(vals_tbl)?;
                    result.add_row(&[
                        ("group_key".to_string(), key.clone()),
                        (col_name.clone(), CellValue::Number(agg)),
                    ]);
                }
                Ok(LuaDataFrame::new(result, this.state.clone()))
            },
        );
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            Ok(format!("GroupedFrame({} groups)", this.groups.len()))
        });
        // -- type --
        /// Returns the Lua-visible type name for this grouped frame handle.
        /// @return | string | The string `LGroupedFrame`.
        methods.add_method("type", |_, _, ()| Ok("LGroupedFrame"));
        // -- typeOf --
        /// Returns whether this grouped frame handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LGroupedFrame` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGroupedFrame" || name == "LObject")
        });
    }
}
/// Lua-side handle for a threaded dataframe job.
pub struct LuaDataFrameTask {
    /// Shared task lifecycle state.
    inner: Rc<RefCell<DataFrameTask>>,
    /// Shared runtime state used when completed tasks create dataframe handles.
    state: Rc<RefCell<SharedState>>,
}
impl LuaDataFrameTask {
    /// Wraps a threaded dataframe task for Lua.
    fn new(task: DataFrameTask, state: Rc<RefCell<SharedState>>) -> Self {
        Self {
            inner: Rc::new(RefCell::new(task)),
            state,
        }
    }
}
impl LuaUserData for LuaDataFrameTask {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- isDone --
        /// Returns whether this dataframe task has completed with success or failure.
        /// @return | boolean | True once the worker has produced a result or error.
        methods.add_method("isDone", |_, this, ()| {
            Ok(this.inner.borrow_mut().is_done())
        });
        // -- wait --
        /// Blocks until this dataframe task completes.
        /// @return | boolean | True when the task completed successfully; false when it completed with an error.
        methods.add_method("wait", |_, this, ()| Ok(this.inner.borrow_mut().wait()));
        // -- result --
        /// Returns the completed dataframe result.
        /// @return | LDataFrame | Completed dataframe result.
        methods.add_method("result", |_, this, ()| {
            let dataframe = this
                .inner
                .borrow_mut()
                .result()
                .map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrame::new(dataframe, this.state.clone()))
        });
        // -- getError --
        /// Returns the task error message after failure.
        /// @return | string | Error message after failure.
        /// @return | nil | If the task is pending or succeeded.
        methods.add_method("getError", |_, this, ()| {
            Ok(this.inner.borrow_mut().get_error())
        });
        // -- progress --
        /// Returns a coarse task progress estimate.
        /// @return | number | Progress from 0.0 to 1.0.
        methods.add_method("progress", |_, this, ()| {
            Ok(this.inner.borrow_mut().progress())
        });
        // -- type --
        /// Returns the Lua-visible type name for this dataframe task handle.
        /// @return | string | The string `LDataFrameTask`.
        methods.add_method("type", |_, _, ()| Ok("LDataFrameTask"));
        // -- typeOf --
        /// Returns whether this dataframe task handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LDataFrameTask`, `DataFrameTask`, and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDataFrameTask" || name == "LObject")
        });
    }
}
/// Lua-side dataframe handle for tabular data with named columns and typed cells.
pub struct LuaDataFrame {
    /// Shared dataframe storage exposed through this userdata handle.
    inner: Rc<RefCell<DataFrame>>,
    /// Shared runtime state used for GameFS-backed file persistence.
    state: Rc<RefCell<SharedState>>,
}
impl LuaDataFrame {
    /// Wraps a dataframe in shared Lua userdata state.
    fn new(df: DataFrame, state: Rc<RefCell<SharedState>>) -> Self {
        Self {
            inner: Rc::new(RefCell::new(df)),
            state,
        }
    }
    /// Wraps a derived dataframe with the same runtime state as this handle.
    fn wrap(&self, df: DataFrame) -> Self {
        Self::new(df, self.state.clone())
    }
    /// Borrows the inner dataframe for cross-binding helpers.
    pub(crate) fn borrow_dataframe(&self) -> Ref<'_, DataFrame> {
        self.inner.borrow()
    }
}
impl LuaUserData for LuaDataFrame {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- nrows --
        /// Returns the number of rows in this dataframe.
        /// @return | integer | Row count.
        methods.add_method("nrows", |_, this, ()| Ok(this.inner.borrow().nrows()));
        // -- ncols --
        /// Returns the number of columns in this dataframe.
        /// @return | integer | Column count.
        methods.add_method("ncols", |_, this, ()| Ok(this.inner.borrow().ncols()));
        // -- columns --
        /// Returns all column names in order. This method is available to Lua scripts.
        /// @return | string[] | Column names.
        methods.add_method("columns", |lua, this, ()| {
            let df = this.inner.borrow();
            let tbl = lua.create_table()?;
            for (i, name) in df.columns().iter().enumerate() {
                tbl.set(i + 1, name.as_str())?;
            }
            Ok(tbl)
        });
        // -- count --
        /// Returns the row count for this dataframe.
        /// @return | integer | Row count.
        methods.add_method("count", |_, this, ()| Ok(this.inner.borrow().count()));
        // -- addColumn --
        /// Adds a column with an optional default value.
        /// @param | name | string | Column name to create.
        /// @param | default | any | Default cell value for existing rows; nil uses empty cells.
        methods.add_method(
            "addColumn",
            |_, this, (name, default): (String, Option<LuaValue>)| {
                let def = default.map(lua_to_cell).unwrap_or(CellValue::Nil);
                this.inner
                    .borrow_mut()
                    .add_column(&name, def)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- removeColumn --
        /// Removes a column by name or one-based index.
        /// @param | col | any | Column name string or one-based column index.
        methods.add_method("removeColumn", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            this.inner
                .borrow_mut()
                .remove_column(cr)
                .map_err(LuaError::RuntimeError)
        });
        // -- rename --
        /// Renames a column by name or one-based index.
        /// @param | col | any | Column name string or one-based column index.
        /// @param | new_name | string | New column name.
        methods.add_method("rename", |_, this, (col, new_name): (LuaValue, String)| {
            let cr = lua_to_col_ref(col)?;
            this.inner
                .borrow_mut()
                .rename_column(cr, &new_name)
                .map_err(LuaError::RuntimeError)
        });
        // -- getColumn --
        /// Returns a column as an array table. This method is available to Lua scripts.
        /// @param | col | any | Column name string or one-based column index.
        /// @return | number[] | Array table of column values.
        methods.add_method("getColumn", |lua, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            let df = this.inner.borrow();
            let cells = df.get_column(cr).map_err(LuaError::RuntimeError)?;
            let tbl = lua.create_table()?;
            for (i, cell) in cells.iter().enumerate() {
                tbl.set(i + 1, cell_to_lua(lua, cell)?)?;
            }
            Ok(tbl)
        });
        // -- addRow --
        /// Adds a row from an optional map table and returns its one-based row index.
        /// @param | row_tbl | table? | Optional table mapping column names to cell values.
        /// @return | integer | One-based index of the inserted row.
        methods.add_method("addRow", |_, this, row_tbl: Option<LuaTable>| {
            let values: Vec<(String, CellValue)> = if let Some(tbl) = row_tbl {
                let mut v = Vec::new();
                for pair in tbl.pairs::<String, LuaValue>() {
                    let (key, val) = pair?;
                    v.push((key, lua_to_cell(val)));
                }
                v
            } else {
                Vec::new()
            };
            let row_0 = this.inner.borrow_mut().add_row(&values);
            Ok(row_0 + 1)
        });
        // -- removeRow --
        /// Removes a row by one-based index. This method is available to Lua scripts.
        /// @param | row | integer | One-based row index to remove.
        methods.add_method("removeRow", |_, this, row: usize| {
            let r = validate_row(row)?;
            this.inner
                .borrow_mut()
                .remove_row(r)
                .map_err(LuaError::RuntimeError)
        });
        // -- getRow --
        /// Returns a row as a table keyed by column name.
        /// @param | row | integer | One-based row index to read.
        /// @return | table | Row table keyed by column name.
        methods.add_method("getRow", |lua, this, row: usize| {
            let r = validate_row(row)?;
            let df = this.inner.borrow();
            let pairs = df.get_row(r).map_err(LuaError::RuntimeError)?;
            let tbl = lua.create_table()?;
            for (name, cell) in &pairs {
                tbl.set(name.as_str(), cell_to_lua(lua, cell)?)?;
            }
            Ok(tbl)
        });
        // -- getValue --
        /// Returns one cell value by one-based row and column reference.
        /// @param | row | integer | One-based row index.
        /// @param | col | any | Column name string or one-based column index.
        /// @return | number|string|boolean|nil | Cell value at the requested row and column.
        methods.add_method("getValue", |lua, this, (row, col): (usize, LuaValue)| {
            let r = validate_row(row)?;
            let cr = lua_to_col_ref(col)?;
            let df = this.inner.borrow();
            let cell = df.get_value(r, cr).map_err(LuaError::RuntimeError)?;
            cell_to_lua(lua, &cell)
        });
        // -- setValue --
        /// Sets one cell value by one-based row and column reference.
        /// @param | row | integer | One-based row index.
        /// @param | col | any | Column name string or one-based column index.
        /// @param | val | any | Cell value to store.
        methods.add_method(
            "setValue",
            |_, this, (row, col, val): (usize, LuaValue, LuaValue)| {
                let r = validate_row(row)?;
                let cr = lua_to_col_ref(col)?;
                let cv = lua_to_cell(val);
                this.inner
                    .borrow_mut()
                    .set_value(r, cr, cv)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- filter --
        /// Returns rows whose column value matches a comparison.
        /// @param | col | any | Column name string or one-based column index.
        /// @param | op | string | Comparison operator string.
        /// @param | val | any | Cell value used as the comparison target.
        /// @return | LDataFrame | New filtered dataframe.
        methods.add_method(
            "filter",
            |_, this, (col, op, val): (LuaValue, String, LuaValue)| {
                let cr = lua_to_col_ref(col)?;
                let cv = lua_to_cell(val);
                let df = this.inner.borrow();
                let result = df.filter(cr, &op, &cv).map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- sort --
        /// Returns rows sorted by a column. This method is available to Lua scripts.
        /// @param | col | any | Column name string or one-based column index.
        /// @param | ascending | boolean? | True for ascending order; defaults to true.
        /// @return | LDataFrame | New sorted dataframe.
        methods.add_method(
            "sort",
            |_, this, (col, ascending): (LuaValue, Option<bool>)| {
                let cr = lua_to_col_ref(col)?;
                let df = this.inner.borrow();
                let result = df
                    .sort(cr, ascending.unwrap_or(true))
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- head --
        /// Returns the first rows of this dataframe.
        /// @param | n | integer? | Number of rows to return; defaults to 5.
        /// @return | LDataFrame | New dataframe containing the first rows.
        methods.add_method("head", |_, this, n: Option<usize>| {
            let df = this.inner.borrow();
            Ok(this.wrap(df.head(n.unwrap_or(5))))
        });
        // -- tail --
        /// Returns the last rows of this dataframe.
        /// @param | n | integer? | Number of rows to return; defaults to 5.
        /// @return | LDataFrame | New dataframe containing the last rows.
        methods.add_method("tail", |_, this, n: Option<usize>| {
            let df = this.inner.borrow();
            Ok(this.wrap(df.tail(n.unwrap_or(5))))
        });
        // -- slice --
        /// Returns a one-based inclusive row slice.
        /// @param | start | integer | One-based start row.
        /// @param | end | integer | One-based end row.
        /// @return | LDataFrame | New dataframe containing the row slice.
        methods.add_method("slice", |_, this, (start, end): (usize, usize)| {
            if start == 0 || end == 0 {
                return Err(LuaError::RuntimeError("slice indices must be >= 1".into()));
            }
            let df = this.inner.borrow();
            let result = df
                .slice(start - 1, end - 1)
                .map_err(LuaError::RuntimeError)?;
            Ok(this.wrap(result))
        });
        // -- select --
        /// Returns a dataframe with selected columns.
        /// @param | ... | any | Column name strings or one-based column indices to keep.
        /// @return | LDataFrame | New dataframe containing selected columns.
        methods.add_method("select", |_, this, cols: LuaMultiValue| {
            let col_refs: Vec<ColRef> = cols
                .into_iter()
                .map(lua_to_col_ref)
                .collect::<LuaResult<Vec<_>>>()?;
            let df = this.inner.borrow();
            let result = df
                .select_columns(&col_refs)
                .map_err(LuaError::RuntimeError)?;
            Ok(this.wrap(result))
        });
        // -- unique --
        /// Returns unique values from a column.
        /// @param | col | any | Column name string or one-based column index.
        /// @return | number[] | Array table of unique values.
        methods.add_method("unique", |lua, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            let df = this.inner.borrow();
            let vals = df.unique(cr).map_err(LuaError::RuntimeError)?;
            let tbl = lua.create_table()?;
            for (i, v) in vals.iter().enumerate() {
                tbl.set(i + 1, cell_to_lua(lua, v)?)?;
            }
            Ok(tbl)
        });
        // -- groupBy --
        /// Groups rows by a column and returns a table from group key to dataframe.
        /// @param | col | string | Column name string or one-based column index.
        /// @return | table | Table keyed by group values with dataframe handles as values.
        methods.add_method("groupBy", |lua, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            let df = this.inner.borrow();
            let groups = df.group_by(cr).map_err(LuaError::RuntimeError)?;
            let tbl = lua.create_table()?;
            for (key, sub_df) in groups {
                let lua_key = cell_to_lua(lua, &key)?;
                tbl.set(lua_key, this.wrap(sub_df))?;
            }
            Ok(tbl)
        });
        // -- groupByObj --
        /// Groups rows by a column and returns a grouped-frame object.
        /// @param | col | string | Column name string or one-based column index.
        /// @return | LGroupedFrame | Grouped frame handle.
        methods.add_method("groupByObj", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            let df = this.inner.borrow();
            let groups = df.group_by(cr).map_err(LuaError::RuntimeError)?;
            Ok(LuaGroupedFrame::new(groups, this.state.clone()))
        });
        // -- join --
        /// Joins this dataframe with another dataframe by column references.
        /// @param | other | LDataFrame | Other dataframe to join.
        /// @param | this_col | string | Column name string or one-based column index.
        /// @param | other_col | string | Column name string or one-based column index.
        /// @param | jtype | string? | Join type string; defaults to `inner`.
        /// @return | LDataFrame | New joined dataframe.
        methods.add_method(
            "join",
            |_,
             this,
             (other, this_col, other_col, jtype): (
                LuaAnyUserData,
                LuaValue,
                LuaValue,
                Option<String>,
            )| {
                let other_df = other.borrow::<LuaDataFrame>()?;
                let tc = lua_to_col_ref(this_col)?;
                let oc = lua_to_col_ref(other_col)?;
                let df = this.inner.borrow();
                let other_borrow = other_df.inner.borrow();
                let result = df
                    .join(&other_borrow, tc, oc, jtype.as_deref().unwrap_or("inner"))
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- merge --
        /// Appends another dataframe into this dataframe in place.
        /// @param | other | LDataFrame | Dataframe whose rows are merged into this dataframe.
        methods.add_method("merge", |_, this, other: LuaAnyUserData| {
            let other_df = other.borrow::<LuaDataFrame>()?;
            let other_borrow = other_df.inner.borrow();
            this.inner.borrow_mut().merge(&other_borrow);
            Ok(())
        });
        // -- countBy --
        /// Counts occurrences of each value in a column.
        /// @param | col | string | Column name string or one-based column index.
        /// @return | LDataFrame | New dataframe containing value counts.
        methods.add_method("countBy", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            let df = this.inner.borrow();
            let result = df.count_by(cr).map_err(LuaError::RuntimeError)?;
            Ok(this.wrap(result))
        });
        // -- valueCounts --
        /// Counts occurrences of each value in a column with optional percentage output.
        /// @param | col | any | Column name string or one-based column index.
        /// @param | opts | table? | Optional options table; set `percent = true` to include percentage values from 0 to 100.
        /// @return | LDataFrame | New dataframe containing `value`, `count`, and optional `percent` columns.
        methods.add_method(
            "valueCounts",
            |_, this, (col, opts): (LuaValue, Option<LuaTable>)| {
                let cr = lua_to_col_ref(col)?;
                let include_percent = match opts {
                    Some(tbl) => tbl.get::<_, Option<bool>>("percent")?.unwrap_or(false),
                    None => false,
                };
                let df = this.inner.borrow();
                let result = df
                    .value_counts(cr, include_percent)
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- missingReport --
        /// Reports missing and non-missing cell counts for every column.
        /// @param | opts | table? | Optional options table reserved for future report settings.
        /// @return | LDataFrame | New dataframe containing `column`, `missing`, `non_missing`, and `missing_percent` columns.
        methods.add_method("missingReport", |_, this, _opts: Option<LuaTable>| {
            let df = this.inner.borrow();
            Ok(this.wrap(df.missing_report()))
        });
        // -- duplicateRows --
        /// Returns rows whose full-row key or selected-column key appears more than once.
        /// @param | cols | table? | Optional array table of column name strings or one-based column indexes used as the duplicate key.
        /// @return | LDataFrame | New dataframe containing duplicate rows in original order.
        methods.add_method("duplicateRows", |_, this, cols: Option<LuaTable>| {
            let selected_cols = match cols {
                Some(tbl) => Some(lua_table_to_col_refs(tbl)?),
                None => None,
            };
            let df = this.inner.borrow();
            let result = df
                .duplicate_rows(selected_cols.as_deref())
                .map_err(LuaError::RuntimeError)?;
            Ok(this.wrap(result))
        });
        // -- dateParts --
        /// Returns a new dataframe with year, month, and day columns extracted from ISO `yyyy-mm-dd` text.
        /// @param | date_col | any | Column name string or one-based column index containing ISO date text.
        /// @param | prefix | string? | Optional output prefix; `prefix = "txn"` creates `txn_year`, `txn_month`, and `txn_day`.
        /// @return | LDataFrame | New dataframe with extracted date-part columns; invalid or missing dates produce nil parts.
        methods.add_method(
            "dateParts",
            |_, this, (date_col, prefix): (LuaValue, Option<String>)| {
                let col_ref = lua_to_col_ref(date_col)?;
                let df = this.inner.borrow();
                let result = df
                    .date_parts(col_ref, prefix.as_deref())
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- dropNil --
        /// Returns rows where the chosen column is not nil.
        /// @param | col | string | Column name string or one-based column index.
        /// @return | LDataFrame | New dataframe without nil rows for the column.
        methods.add_method("dropNil", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            let df = this.inner.borrow();
            let result = df.drop_nil(cr).map_err(LuaError::RuntimeError)?;
            Ok(this.wrap(result))
        });
        // -- sample --
        /// Returns a sampled dataframe. This method is available to Lua scripts.
        /// @param | n | integer | Number of rows to sample.
        /// @param | seed | integer? | Optional random seed.
        /// @return | LDataFrame | New sampled dataframe.
        methods.add_method("sample", |_, this, (n, seed): (usize, Option<u64>)| {
            let df = this.inner.borrow();
            Ok(this.wrap(df.sample(n, seed)))
        });
        // -- describe --
        /// Returns summary statistics for numeric columns.
        /// @return | LDataFrame | New dataframe containing descriptive statistics.
        methods.add_method("describe", |_, this, ()| {
            let df = this.inner.borrow();
            Ok(this.wrap(df.describe()))
        });
        // -- sum --
        /// Returns the numeric sum of a column.
        /// @param | col | any | Column name string or one-based column index.
        /// @return | number | Column sum.
        methods.add_method("sum", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            this.inner.borrow().sum(cr).map_err(LuaError::RuntimeError)
        });
        // -- mean --
        /// Returns the numeric mean of a column.
        /// @param | col | any | Column name string or one-based column index.
        /// @return | number | Column mean.
        methods.add_method("mean", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            this.inner.borrow().mean(cr).map_err(LuaError::RuntimeError)
        });
        // -- min --
        /// Returns the minimum value of a column.
        /// @param | col | any | Column name string or one-based column index.
        /// @return | number|string|boolean|nil | Minimum cell value.
        methods.add_method("min", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            this.inner
                .borrow()
                .min_val(cr)
                .map_err(LuaError::RuntimeError)
        });
        // -- max --
        /// Returns the maximum value of a column.
        /// @param | col | any | Column name string or one-based column index.
        /// @return | number|string|boolean|nil | Maximum cell value.
        methods.add_method("max", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            this.inner
                .borrow()
                .max_val(cr)
                .map_err(LuaError::RuntimeError)
        });
        // -- median --
        /// Returns the numeric median of a column.
        /// @param | col | any | Column name string or one-based column index.
        /// @return | number | Column median.
        methods.add_method("median", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            this.inner
                .borrow()
                .median(cr)
                .map_err(LuaError::RuntimeError)
        });
        // -- stddev --
        /// Returns the numeric standard deviation of a column.
        /// @param | col | any | Column name string or one-based column index.
        /// @return | number | Column standard deviation.
        methods.add_method("stddev", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            this.inner
                .borrow()
                .stddev(cr)
                .map_err(LuaError::RuntimeError)
        });
        // -- variance --
        /// Returns the numeric variance of a column.
        /// @param | col | any | Column name string or one-based column index.
        /// @return | number | Column variance.
        methods.add_method("variance", |_, this, col: LuaValue| {
            let cr = lua_to_col_ref(col)?;
            this.inner
                .borrow()
                .variance(cr)
                .map_err(LuaError::RuntimeError)
        });
        // -- fillNil --
        /// Replaces nil cells in a column with a value.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | val | any | Replacement cell value.
        methods.add_method("fillNil", |_, this, (col, val): (LuaValue, LuaValue)| {
            let cr = lua_to_col_ref(col)?;
            let cv = lua_to_cell(val);
            this.inner
                .borrow_mut()
                .fill_nil(cr, cv)
                .map_err(LuaError::RuntimeError)
        });
        // -- apply --
        /// Applies a Lua function to each value in a column in place.
        /// @param | col_val | string | Column name string or one-based column index.
        /// @param | func | function | Function called with each cell value and returning a replacement value.
        methods.add_method(
            "apply",
            |lua, this, (col_val, func): (LuaValue, LuaFunction)| {
                let col = lua_to_col_ref(col_val)?;
                let mut df = this.inner.borrow_mut();
                let cells = df.column_data_mut(col).map_err(LuaError::RuntimeError)?;
                for cell in cells.iter_mut() {
                    let lua_val = cell_to_lua(lua, cell)?;
                    let result: LuaValue = func.call(lua_val)?;
                    *cell = lua_to_cell(result);
                }
                Ok(())
            },
        );
        // -- toCSV --
        /// Serializes this dataframe to CSV text.
        /// @return | string | CSV text.
        methods.add_method("toCSV", |_, this, ()| Ok(this.inner.borrow().to_csv()));
        // -- toJSON --
        /// Serializes this dataframe to JSON text.
        /// @return | string | JSON text.
        methods.add_method("toJSON", |_, this, ()| Ok(this.inner.borrow().to_json()));
        // -- toBinary --
        /// Serializes this dataframe to binary data.
        /// @return | string | Binary string containing serialized dataframe data.
        methods.add_method("toBinary", |lua, this, ()| {
            let bytes = this.inner.borrow().to_binary();
            lua.create_string(&bytes)
        });
        // -- toCSVFile --
        /// Serializes this dataframe to CSV text and writes it through GameFS.
        /// @param | path | string | GameFS save path to write, usually under `save/`.
        /// @param | opts | table? | Optional file options table; reserved for future CSV options.
        /// @return | boolean | True when the file was written.
        methods.add_method(
            "toCSVFile",
            |_, this, (path, opts): (String, Option<LuaTable>)| {
                validate_dataframe_file_opts(opts, "LDataFrame:toCSVFile", &["csv"])?;
                let state = this.state.borrow();
                let dataframe = this.inner.borrow();
                file_io::write_csv_dataframe(&state.fs, &path, &dataframe)
                    .map_err(dataframe_file_error_to_lua)?;
                Ok(true)
            },
        );
        // -- toJSONFile --
        /// Serializes this dataframe to JSON text and writes it through GameFS.
        /// @param | path | string | GameFS save path to write, usually under `save/`.
        /// @param | opts | table? | Optional file options table; reserved for future JSON options.
        /// @return | boolean | True when the file was written.
        methods.add_method(
            "toJSONFile",
            |_, this, (path, opts): (String, Option<LuaTable>)| {
                validate_dataframe_file_opts(opts, "LDataFrame:toJSONFile", &["json"])?;
                let state = this.state.borrow();
                let dataframe = this.inner.borrow();
                file_io::write_json_dataframe(&state.fs, &path, &dataframe)
                    .map_err(dataframe_file_error_to_lua)?;
                Ok(true)
            },
        );
        // -- toBinaryFile --
        /// Serializes this dataframe to LVDF binary data and writes it through GameFS.
        /// @param | path | string | GameFS save path to write, usually under `save/`.
        /// @param | opts | table? | Optional file options table; reserved for future binary options.
        /// @return | boolean | True when the file was written.
        methods.add_method(
            "toBinaryFile",
            |_, this, (path, opts): (String, Option<LuaTable>)| {
                validate_dataframe_file_opts(opts, "LDataFrame:toBinaryFile", &["binary", "lvdf"])?;
                let state = this.state.borrow();
                let dataframe = this.inner.borrow();
                file_io::write_binary_dataframe(&state.fs, &path, &dataframe)
                    .map_err(dataframe_file_error_to_lua)?;
                Ok(true)
            },
        );
        // -- toTable --
        /// Converts this dataframe to an array table of row tables.
        /// @return | table | Array of rows keyed by column name.
        methods.add_method("toTable", |lua, this, ()| {
            let df = this.inner.borrow();
            let tbl = lua.create_table()?;
            let cols = df.columns();
            let data = df.raw_data();
            #[allow(clippy::needless_range_loop)]
            for row in 0..df.nrows() {
                let row_tbl = lua.create_table()?;
                for (ci, name) in cols.iter().enumerate() {
                    row_tbl.set(name.as_str(), cell_to_lua(lua, &data[ci][row])?)?;
                }
                tbl.set(row + 1, row_tbl)?;
            }
            Ok(tbl)
        });
        // -- rows --
        /// Returns an iterator function over one-based row index and row table pairs.
        /// @return | function | Iterator function for Lua generic-for loops.
        methods.add_method("rows", |lua, this, ()| {
            let df_ref = Rc::clone(&this.inner);
            let idx_ref = Rc::new(Cell::new(0usize));
            let iter_idx = Rc::clone(&idx_ref);
            lua.create_function_mut(move |lua, (_state, _last): (LuaValue, LuaValue)| {
                let row = iter_idx.get();
                let df = df_ref.borrow();
                if row >= df.nrows() {
                    return Ok((LuaValue::Nil, LuaValue::Nil));
                }
                let row_tbl = lua.create_table()?;
                let cols = df.columns();
                let data = df.raw_data();
                for (ci, name) in cols.iter().enumerate() {
                    row_tbl.set(name.as_str(), cell_to_lua(lua, &data[ci][row])?)?;
                }
                iter_idx.set(row + 1);
                Ok((
                    LuaValue::Integer((row + 1) as i64),
                    LuaValue::Table(row_tbl),
                ))
            })
        });
        // -- toString --
        /// Formats this dataframe as a human-readable text table.
        /// @return | string | Text table representation.
        methods.add_method("toString", |_, this, ()| {
            Ok(this.inner.borrow().to_string_table())
        });
        // -- query --
        /// Runs a SQL-style query against this dataframe.
        /// @param | sql_str | string | SQL query text.
        /// @return | LDataFrame | Query result dataframe.
        methods.add_method("query", |_, this, sql_str: String| {
            let df = this.inner.borrow();
            let result = sql::query_sql(&df, &sql_str).map_err(LuaError::RuntimeError)?;
            Ok(this.wrap(result))
        });
        // -- queryAsync --
        /// Runs a SQL-style query against this dataframe on a Rust worker thread.
        /// @param | sql_str | string | SQL query text.
        /// @return | LDataFrameTask | Task that resolves to the query result dataframe.
        methods.add_method("queryAsync", |_, this, sql_str: String| {
            let dataframe = this.inner.borrow().clone_df();
            let task =
                DataFrameTask::spawn_dataframe_query(dataframe, sql_str, "LDataFrame:queryAsync")
                    .map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrameTask::new(task, this.state.clone()))
        });
        // -- clone --
        /// Returns a deep copy of this dataframe.
        /// @return | LDataFrame | New dataframe containing copied data.
        methods.add_method("clone", |_, this, ()| {
            Ok(this.wrap(this.inner.borrow().clone_df()))
        });
        // -- withRollingMean --
        /// Adds a rolling mean column in place.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | window | integer | Rolling window size.
        /// @param | name | string | Output column name.
        methods.add_method_mut(
            "withRollingMean",
            |_, this, (col, window, name): (LuaValue, usize, String)| {
                let col_ref = lua_to_col_ref(col)?;
                this.inner
                    .borrow_mut()
                    .with_rolling_mean(col_ref, window, &name)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- withRollingSum --
        /// Adds a rolling sum column in place. This method is available to Lua scripts.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | window | integer | Rolling window size.
        /// @param | name | string | Output column name.
        methods.add_method_mut(
            "withRollingSum",
            |_, this, (col, window, name): (LuaValue, usize, String)| {
                let col_ref = lua_to_col_ref(col)?;
                this.inner
                    .borrow_mut()
                    .with_rolling_sum(col_ref, window, &name)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- withRollingMin --
        /// Adds a rolling minimum column in place.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | window | integer | Rolling window size.
        /// @param | name | string | Output column name.
        methods.add_method_mut(
            "withRollingMin",
            |_, this, (col, window, name): (LuaValue, usize, String)| {
                let col_ref = lua_to_col_ref(col)?;
                this.inner
                    .borrow_mut()
                    .with_rolling_min(col_ref, window, &name)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- withRollingMax --
        /// Adds a rolling maximum column in place.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | window | integer | Rolling window size.
        /// @param | name | string | Output column name.
        methods.add_method_mut(
            "withRollingMax",
            |_, this, (col, window, name): (LuaValue, usize, String)| {
                let col_ref = lua_to_col_ref(col)?;
                this.inner
                    .borrow_mut()
                    .with_rolling_max(col_ref, window, &name)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- withRank --
        /// Adds a rank column in place. This method is available to Lua scripts.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | asc | boolean? | True for ascending rank; defaults to true.
        /// @param | name | string | Output column name.
        methods.add_method_mut(
            "withRank",
            |_, this, (col, asc, name): (LuaValue, Option<bool>, String)| {
                let col_ref = lua_to_col_ref(col)?;
                this.inner
                    .borrow_mut()
                    .with_rank(col_ref, asc.unwrap_or(true), &name)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- withPctChange --
        /// Adds a percent-change column in place.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | name | string | Output column name.
        methods.add_method_mut(
            "withPctChange",
            |_, this, (col, name): (LuaValue, String)| {
                let col_ref = lua_to_col_ref(col)?;
                this.inner
                    .borrow_mut()
                    .with_pct_change(col_ref, &name)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- withCumsum --
        /// Adds a cumulative-sum column in place.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | name | string | Output column name.
        methods.add_method_mut("withCumsum", |_, this, (col, name): (LuaValue, String)| {
            let col_ref = lua_to_col_ref(col)?;
            this.inner
                .borrow_mut()
                .with_cumsum(col_ref, &name)
                .map_err(LuaError::RuntimeError)
        });
        // -- groupAgg --
        /// Groups by one column and aggregates another column.
        /// @param | group_col | string | Column name string or one-based column index.
        /// @param | agg_col | string | Column name string or one-based column index.
        /// @param | fn_name | string | Aggregate function name.
        /// @return | LDataFrame | New grouped aggregate dataframe.
        methods.add_method(
            "groupAgg",
            |_, this, (group_col, agg_col, fn_name): (LuaValue, LuaValue, String)| {
                let gc = lua_to_col_ref(group_col)?;
                let ac = lua_to_col_ref(agg_col)?;
                let agg_fn = AggFn::parse(&fn_name).map_err(LuaError::RuntimeError)?;
                let result = this
                    .inner
                    .borrow()
                    .group_agg(gc, ac, agg_fn)
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- pivot --
        /// Pivots rows into columns using row, column, and value fields.
        /// @param | row_col | string | Column name string or one-based column index.
        /// @param | col_col | string | Column name string or one-based column index.
        /// @param | val_col | string | Column name string or one-based column index.
        /// @return | LDataFrame | New pivoted dataframe.
        methods.add_method(
            "pivot",
            |_, this, (row_col, col_col, val_col): (LuaValue, LuaValue, LuaValue)| {
                let rc = lua_to_col_ref(row_col)?;
                let cc = lua_to_col_ref(col_col)?;
                let vc = lua_to_col_ref(val_col)?;
                let result = this
                    .inner
                    .borrow()
                    .pivot(rc, cc, vc)
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- corr --
        /// Returns correlation between two numeric columns.
        /// @param | col_a | string | Column name string or one-based column index.
        /// @param | col_b | string | Column name string or one-based column index.
        /// @return | number | Correlation value.
        methods.add_method("corr", |_, this, (col_a, col_b): (LuaValue, LuaValue)| {
            let ca = lua_to_col_ref(col_a)?;
            let cb = lua_to_col_ref(col_b)?;
            this.inner
                .borrow()
                .corr(ca, cb)
                .map_err(LuaError::RuntimeError)
        });
        // -- correlationMatrix --
        /// Returns a correlation matrix for numeric columns.
        /// @return | LDataFrame | Correlation matrix dataframe.
        methods.add_method("correlationMatrix", |_, this, ()| {
            let result = this.inner.borrow().correlation_matrix();
            Ok(this.wrap(result))
        });
        // -- zscoreCol --
        /// Adds a z-score normalized column in place.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | name | string | Output column name.
        methods.add_method_mut("zscoreCol", |_, this, (col, name): (LuaValue, String)| {
            let col_ref = lua_to_col_ref(col)?;
            this.inner
                .borrow_mut()
                .zscore_col(col_ref, &name)
                .map_err(LuaError::RuntimeError)
        });
        // -- normalizeCol --
        /// Adds a range-normalized column in place.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | out_min | number | Output lower bound.
        /// @param | out_max | number | Output upper bound.
        /// @param | name | string | Output column name.
        methods.add_method_mut(
            "normalizeCol",
            |_, this, (col, out_min, out_max, name): (LuaValue, f64, f64, String)| {
                let col_ref = lua_to_col_ref(col)?;
                this.inner
                    .borrow_mut()
                    .normalize_col(col_ref, out_min, out_max, &name)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- outliers --
        /// Returns rows considered outliers for a numeric column.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | threshold | number? | Z-score threshold; defaults to 2.0.
        /// @return | LDataFrame | New dataframe containing outlier rows.
        methods.add_method(
            "outliers",
            |_, this, (col, threshold): (LuaValue, Option<f64>)| {
                let col_ref = lua_to_col_ref(col)?;
                let result = this
                    .inner
                    .borrow()
                    .outliers(col_ref, threshold.unwrap_or(2.0))
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- modeVal --
        /// Returns the mode value of a column. This method is available to Lua scripts.
        /// @param | col | string | Column name string or one-based column index.
        /// @return | number|string|boolean|nil | Most common cell value.
        methods.add_method("modeVal", |lua, this, col: LuaValue| {
            let col_ref = lua_to_col_ref(col)?;
            let val = this
                .inner
                .borrow()
                .mode_val(col_ref)
                .map_err(LuaError::RuntimeError)?;
            cell_to_lua(lua, &val)
        });
        // -- entropy --
        /// Returns entropy for a column. This method is available to Lua scripts.
        /// @param | col | string | Column name string or one-based column index.
        /// @return | number | Entropy value.
        methods.add_method("entropy", |_, this, col: LuaValue| {
            let col_ref = lua_to_col_ref(col)?;
            this.inner
                .borrow()
                .entropy(col_ref)
                .map_err(LuaError::RuntimeError)
        });
        // -- addRowBatch --
        /// Appends multiple rows from array-style row tables.
        /// @param | rows | table | Array of row arrays matching the dataframe column order.
        methods.add_method_mut("addRowBatch", |_, this, rows: LuaTable| {
            let nc = this.inner.borrow().ncols();
            let mut batch: Vec<Vec<CellValue>> = Vec::new();
            for pair in rows.sequence_values::<LuaTable>() {
                let row_tbl = pair?;
                let mut row: Vec<CellValue> = Vec::with_capacity(nc);
                for i in 1..=nc {
                    let v: LuaValue = row_tbl.get(i)?;
                    row.push(lua_to_cell(v));
                }
                batch.push(row);
            }
            this.inner
                .borrow_mut()
                .add_row_batch(batch)
                .map_err(LuaError::RuntimeError)
        });
        // -- getColumnAsF64 --
        /// Returns a numeric column as an array of numbers.
        /// @param | col | string | Column name string or one-based column index.
        /// @return | number[] | Numeric values.
        methods.add_method("getColumnAsF64", |lua, this, col: LuaValue| {
            let col_ref = lua_to_col_ref(col)?;
            let vals = this
                .inner
                .borrow()
                .get_column_as_f64(col_ref)
                .map_err(LuaError::RuntimeError)?;
            let t = lua.create_table_with_capacity(vals.len(), 0)?;
            for (i, v) in vals.iter().enumerate() {
                t.set(i + 1, *v)?;
            }
            Ok(t)
        });
        // -- setColumnFromF64 --
        /// Replaces a numeric column from an array table of numbers.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | values | table | Array table of numeric values.
        methods.add_method_mut(
            "setColumnFromF64",
            |_, this, (col, values): (LuaValue, LuaTable)| {
                let col_ref = lua_to_col_ref(col)?;
                let mut vals: Vec<f64> = Vec::new();
                for pair in values.sequence_values::<f64>() {
                    vals.push(pair?);
                }
                this.inner
                    .borrow_mut()
                    .set_column_from_f64(col_ref, vals)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- type --
        /// Returns the Lua-visible type name for this dataframe handle.
        /// @return | string | The string `LDataFrame`.
        methods.add_method("type", |_, _, ()| Ok("LDataFrame"));
        // -- typeOf --
        /// Returns whether this dataframe handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LDataFrame`, `DataFrame`, and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDataFrame" || name == "LObject")
        });
        // -- withEval --
        /// Returns a dataframe with a column computed from an expression.
        /// @param | col_name | string | Output column name.
        /// @param | expr | string | Dataframe expression evaluated by the dataframe module.
        /// @return | LDataFrame | New dataframe with the evaluated column.
        methods.add_method(
            "withEval",
            |lua, this, (col_name, expr): (String, String)| {
                let result = this
                    .inner
                    .borrow()
                    .with_eval(&col_name, &expr)
                    .map_err(LuaError::RuntimeError)?;
                lua.create_userdata(this.wrap(result))
            },
        );
        // -- pivotTable --
        /// Builds a pivot table using row key, column key, value column, and aggregate function.
        /// @param | row_key | string | Column name string or one-based column index.
        /// @param | col_key | string | Column name string or one-based column index.
        /// @param | value_key | string | Column name string or one-based column index.
        /// @param | agg | string? | Aggregate function name; defaults to `mean`.
        /// @return | LDataFrame | New pivot table dataframe.
        methods.add_method("pivotTable", |_,
             this,
             (row_key, col_key, value_key, agg): (
                LuaValue,
                LuaValue,
                LuaValue,
                Option<String>,
            )| {
                let rk = lua_to_col_ref(row_key)?;
                let ck = lua_to_col_ref(col_key)?;
                let vk = lua_to_col_ref(value_key)?;
                let agg_str = agg.as_deref().unwrap_or("mean");
                let df = this.inner.borrow();
                let result = df
                    .pivot_table(rk, ck, vk, agg_str)
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- rollingMean --
        /// Returns a dataframe with a rolling mean column.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | window | integer | Rolling window size.
        /// @param | result_col | string? | Output column name; defaults to `rolling_mean`.
        /// @return | LDataFrame | New dataframe with the rolling mean column.
        methods.add_method(
            "rollingMean",
            |_, this, (col, window, result_col): (LuaValue, usize, Option<String>)| {
                let cr = lua_to_col_ref(col)?;
                let out_name = result_col.unwrap_or_else(|| "rolling_mean".to_string());
                let df = this.inner.borrow();
                let result = df
                    .rolling_mean(cr, window, &out_name)
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- rollingSum --
        /// Returns a dataframe with a rolling sum column.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | window | integer | Rolling window size.
        /// @param | result_col | string? | Output column name; defaults to `rolling_sum`.
        /// @return | LDataFrame | New dataframe with the rolling sum column.
        methods.add_method(
            "rollingSum",
            |_, this, (col, window, result_col): (LuaValue, usize, Option<String>)| {
                let cr = lua_to_col_ref(col)?;
                let out_name = result_col.unwrap_or_else(|| "rolling_sum".to_string());
                let df = this.inner.borrow();
                let result = df
                    .rolling_sum(cr, window, &out_name)
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- rank --
        /// Returns a dataframe with a rank column.
        /// @param | col | string | Column name string or one-based column index.
        /// @param | order | string? | Rank order string; defaults to `asc`.
        /// @param | result_col | string? | Output column name; defaults to `rank`.
        /// @return | LDataFrame | New dataframe with the rank column.
        methods.add_method(
            "rank",
            |_, this, (col, order, result_col): (LuaValue, Option<String>, Option<String>)| {
                let cr = lua_to_col_ref(col)?;
                let ord = order.as_deref().unwrap_or("asc");
                let out_name = result_col.unwrap_or_else(|| "rank".to_string());
                let df = this.inner.borrow();
                let result = df
                    .rank_column(cr, ord, &out_name)
                    .map_err(LuaError::RuntimeError)?;
                Ok(this.wrap(result))
            },
        );
        // -- lazy --
        /// Starts a lazy query pipeline from this dataframe.
        /// @return | LLazyQuery | New lazy query handle.
        methods.add_method("lazy", |_, this, ()| {
            let lq = this.inner.borrow().lazy();
            Ok(LuaLazyQuery {
                inner: lq,
                state: this.state.clone(),
            })
        });
    }
}
/// Lua-side lazy dataframe query pipeline.
pub struct LuaLazyQuery {
    /// Owned lazy query plan that is consumed by chaining methods.
    inner: LazyQuery,
    /// Shared runtime state propagated to collected dataframe handles.
    state: Rc<RefCell<SharedState>>,
}
impl LuaUserData for LuaLazyQuery {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- filter --
        /// Adds a filter step to the lazy query.
        /// @param | col | string | Column name to filter.
        /// @param | op | string | Comparison operator string.
        /// @param | val | any | Filter comparison value.
        /// @return | LLazyQuery | New lazy query handle with the filter step.
        methods.add_method_mut(
            "filter",
            |_, this, (col, op, val): (String, String, LuaValue)| {
                let cell = lua_to_cell(val);
                let old = std::mem::replace(&mut this.inner, LazyQuery::tombstone());
                Ok(LuaLazyQuery {
                    inner: old.filter(&col, &op, cell),
                    state: this.state.clone(),
                })
            },
        );
        // -- sort --
        /// Adds a sort step to the lazy query. This method is available to Lua scripts.
        /// @param | col | string | Column name to sort by.
        /// @param | ascending | boolean? | True for ascending order; defaults to true.
        /// @return | LLazyQuery | New lazy query handle with the sort step.
        methods.add_method_mut(
            "sort",
            |_, this, (col, ascending): (String, Option<bool>)| {
                let asc = ascending.unwrap_or(true);
                let old = std::mem::replace(&mut this.inner, LazyQuery::tombstone());
                Ok(LuaLazyQuery {
                    inner: old.sort(&col, asc),
                    state: this.state.clone(),
                })
            },
        );
        // -- head --
        /// Adds a head limit step to the lazy query.
        /// @param | n | integer | Number of leading rows to keep.
        /// @return | LLazyQuery | New lazy query handle with the head step.
        methods.add_method_mut("head", |_, this, n: usize| {
            let old = std::mem::replace(&mut this.inner, LazyQuery::tombstone());
            Ok(LuaLazyQuery {
                inner: old.head(n),
                state: this.state.clone(),
            })
        });
        // -- tail --
        /// Adds a tail limit step to the lazy query.
        /// @param | n | integer | Number of trailing rows to keep.
        /// @return | LLazyQuery | New lazy query handle with the tail step.
        methods.add_method_mut("tail", |_, this, n: usize| {
            let old = std::mem::replace(&mut this.inner, LazyQuery::tombstone());
            Ok(LuaLazyQuery {
                inner: old.tail(n),
                state: this.state.clone(),
            })
        });
        // -- limit --
        /// Adds a row limit step to the lazy query.
        /// @param | n | integer | Maximum number of rows to keep.
        /// @return | LLazyQuery | New lazy query handle with the limit step.
        methods.add_method_mut("limit", |_, this, n: usize| {
            let old = std::mem::replace(&mut this.inner, LazyQuery::tombstone());
            Ok(LuaLazyQuery {
                inner: old.limit(n),
                state: this.state.clone(),
            })
        });
        // -- slice --
        /// Adds a one-based row slice step to the lazy query.
        /// @param | start | integer | One-based start row.
        /// @param | end | integer | One-based end row.
        /// @return | LLazyQuery | New lazy query handle with the slice step.
        methods.add_method_mut("slice", |_, this, (start, end): (usize, usize)| {
            let s = start.saturating_sub(1);
            let e = end.saturating_sub(1);
            let old = std::mem::replace(&mut this.inner, LazyQuery::tombstone());
            Ok(LuaLazyQuery {
                inner: old.slice(s, e),
                state: this.state.clone(),
            })
        });
        // -- dropNil --
        /// Adds a step that drops rows with nil values in a column.
        /// @param | col | string | Column name to test for nil values.
        /// @return | LLazyQuery | New lazy query handle with the drop-nil step.
        methods.add_method_mut("dropNil", |_, this, col: String| {
            let old = std::mem::replace(&mut this.inner, LazyQuery::tombstone());
            Ok(LuaLazyQuery {
                inner: old.drop_nil(&col),
                state: this.state.clone(),
            })
        });
        // -- select --
        /// Adds a column selection step to the lazy query.
        /// @param | cols | table | Array table of column names to keep.
        /// @return | LLazyQuery | New lazy query handle with the select step.
        methods.add_method_mut("select", |_, this, cols: LuaTable| {
            let mut names: Vec<String> = Vec::new();
            for i in 1..=cols.len()? {
                names.push(cols.get(i)?);
            }
            let old = std::mem::replace(&mut this.inner, LazyQuery::tombstone());
            Ok(LuaLazyQuery {
                inner: old.select(names),
                state: this.state.clone(),
            })
        });
        // -- collect --
        /// Executes the lazy query and returns a dataframe.
        /// @return | LDataFrame | Dataframe produced by the query plan.
        methods.add_method_mut("collect", |_, this, ()| {
            let lq = std::mem::replace(&mut this.inner, LazyQuery::tombstone());
            let df = lq.collect().map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrame::new(df, this.state.clone()))
        });
        // -- type --
        /// Returns the Lua-visible type name for this lazy query handle.
        /// @return | string | The string `LLazyQuery`.
        methods.add_method("type", |_, _, ()| Ok("LLazyQuery"));
        // -- typeOf --
        /// Returns whether this lazy query handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LLazyQuery`, `LazyQuery`, and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LLazyQuery" || name == "LazyQuery" || name == "LObject")
        });
    }
}
/// Lua-side in-memory database containing named dataframes.
pub struct LuaDatabase {
    /// Shared database storage exposed through this userdata handle.
    inner: Rc<RefCell<Database>>,
    /// Shared runtime state used for GameFS-backed file persistence.
    state: Rc<RefCell<SharedState>>,
}
impl LuaDatabase {
    /// Wraps a database in shared Lua userdata state.
    fn new(database: Database, state: Rc<RefCell<SharedState>>) -> Self {
        Self {
            inner: Rc::new(RefCell::new(database)),
            state,
        }
    }
}
impl LuaUserData for LuaDatabase {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addTable --
        /// Adds or replaces a named dataframe table in the database.
        /// @param | name | string | Table name.
        /// @param | df_ud | LDataFrame | Dataframe handle copied into the database.
        methods.add_method(
            "addTable",
            |_, this, (name, df_ud): (String, LuaAnyUserData)| {
                let lua_df = df_ud.borrow::<LuaDataFrame>()?;
                let cloned = lua_df.inner.borrow().clone_df();
                this.inner.borrow_mut().add_table(&name, cloned);
                Ok(())
            },
        );
        // -- getTable --
        /// Returns a copy of a named table when it exists.
        /// @param | name | string | Table name to retrieve.
        /// @return | LDataFrame | Dataframe handle, or nil when no table has that name.
        methods.add_method("getTable", |_, this, name: String| {
            let db = this.inner.borrow();
            match db.get_table(&name) {
                Some(df) => Ok(Some(LuaDataFrame::new(df.clone_df(), this.state.clone()))),
                None => Ok(None),
            }
        });
        // -- removeTable --
        /// Removes a named table from the database.
        /// @param | name | string | Table name to remove.
        methods.add_method("removeTable", |_, this, name: String| {
            this.inner
                .borrow_mut()
                .remove_table(&name)
                .map_err(LuaError::RuntimeError)
        });
        // -- hasTable --
        /// Returns whether a named table exists.
        /// @param | name | string | Table name to check.
        /// @return | boolean | True when the table exists.
        methods.add_method("hasTable", |_, this, name: String| {
            Ok(this.inner.borrow().has_table(&name))
        });
        // -- listTables --
        /// Returns all table names in the database.
        /// @return | string[] | Table names.
        methods.add_method("listTables", |lua, this, ()| {
            let db = this.inner.borrow();
            let names = db.list_tables();
            let tbl = lua.create_table()?;
            for (i, name) in names.iter().enumerate() {
                tbl.set(i + 1, name.as_str())?;
            }
            Ok(tbl)
        });
        // -- tableCount --
        /// Returns the number of tables in the database.
        /// @return | integer | Table count.
        methods.add_method("tableCount", |_, this, ()| {
            Ok(this.inner.borrow().table_count())
        });
        // -- clear --
        /// Removes every table from the database.
        methods.add_method("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            Ok(())
        });
        // -- merge --
        /// Merges another database into this database.
        /// @param | other | LDatabase | Database copied into this database.
        methods.add_method("merge", |_, this, other: LuaAnyUserData| {
            let other_db = other.borrow::<LuaDatabase>()?;
            let cloned = other_db.inner.borrow().clone_db();
            this.inner.borrow_mut().merge(cloned);
            Ok(())
        });
        // -- toJSON --
        /// Serializes the database to JSON text.
        /// @return | string | JSON text.
        methods.add_method("toJSON", |_, this, ()| Ok(this.inner.borrow().to_json()));
        // -- save --
        /// Serializes the database to the JSON database file format and writes it through GameFS.
        /// @param | path | string | GameFS save path to write, usually under `save/`.
        /// @param | opts | table? | Optional options table; `format = "json"` is the only supported format.
        /// @return | boolean | True when the file was written.
        methods.add_method(
            "save",
            |_, this, (path, opts): (String, Option<LuaTable>)| {
                validate_database_file_opts(opts, "LDatabase:save")?;
                let state = this.state.borrow();
                let database = this.inner.borrow();
                file_io::save_json_database(&state.fs, &path, &database)
                    .map_err(dataframe_file_error_to_lua)?;
                Ok(true)
            },
        );
        // -- query --
        /// Runs a SQL-style query against the database tables.
        /// @param | sql_str | string | SQL query text.
        /// @return | LDataFrame | Query result dataframe.
        methods.add_method("query", |_, this, sql_str: String| {
            let db = this.inner.borrow();
            let result = sql::query_sql_database(&db, &sql_str).map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrame::new(result, this.state.clone()))
        });
        // -- queryAsync --
        /// Runs a SQL-style query against a snapshot of the database tables on a Rust worker thread.
        /// @param | sql_str | string | SQL query text.
        /// @return | LDataFrameTask | Task that resolves to the query result dataframe.
        methods.add_method("queryAsync", |_, this, sql_str: String| {
            let database = this.inner.borrow().clone_db();
            let task =
                DataFrameTask::spawn_database_query(database, sql_str, "LDatabase:queryAsync")
                    .map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrameTask::new(task, this.state.clone()))
        });
        // -- queryParams --
        /// Runs a SQL-style query against the database tables with positional parameters.
        /// @param | sql_str | string | SQL query text using `?` placeholders outside string literals.
        /// @param | params | table | Array table of positional parameter values; nil maps to SQL NULL, strings are escaped, and booleans/numbers are bound as literals.
        /// @return | LDataFrame | Query result dataframe.
        methods.add_method(
            "queryParams",
            |_, this, (sql_str, params_tbl): (String, LuaTable)| {
                let params = lua_table_to_cells(params_tbl)?;
                let db = this.inner.borrow();
                let result = sql::query_sql_database_params(&db, &sql_str, &params)
                    .map_err(LuaError::RuntimeError)?;
                Ok(LuaDataFrame::new(result, this.state.clone()))
            },
        );
        // -- queryParamsAsync --
        /// Runs a parameterized SQL query against a snapshot of the database tables on a Rust worker thread.
        /// @param | sql_str | string | SQL query text using `?` placeholders outside string literals.
        /// @param | params | table | Array table of positional parameter values; nil maps to SQL NULL, strings are escaped, and booleans/numbers are bound as literals.
        /// @return | LDataFrameTask | Task that resolves to the query result dataframe.
        methods.add_method(
            "queryParamsAsync",
            |_, this, (sql_str, params_tbl): (String, LuaTable)| {
                let params = lua_table_to_cells(params_tbl)?;
                let database = this.inner.borrow().clone_db();
                let task = DataFrameTask::spawn_database_query_params(
                    database,
                    sql_str,
                    params,
                    "LDatabase:queryParamsAsync",
                )
                .map_err(LuaError::RuntimeError)?;
                Ok(LuaDataFrameTask::new(task, this.state.clone()))
            },
        );
        // -- type --
        /// Returns the Lua-visible type name for this database handle.
        /// @return | string | The string `LDatabase`.
        methods.add_method("type", |_, _, ()| Ok("LDatabase"));
        // -- typeOf --
        /// Returns whether this database handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LDatabase`, `Database`, and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDatabase" || name == "LObject")
        });
    }
}
/// Lua-side vectorized dataframe handle for numeric column operations.
#[derive(Clone)]
pub struct LuaVecFrame {
    /// Shared vectorized frame storage exposed through this userdata handle.
    inner: Rc<RefCell<VecFrame>>,
    /// Shared runtime state propagated to dataframe handles.
    state: Rc<RefCell<SharedState>>,
}
impl LuaVecFrame {
    /// Wraps a vectorized frame in shared Lua userdata state.
    pub fn new(vf: VecFrame, state: Rc<RefCell<SharedState>>) -> Self {
        Self {
            inner: Rc::new(RefCell::new(vf)),
            state,
        }
    }
}
impl LuaUserData for LuaVecFrame {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- colAdd --
        /// Adds a scalar to a numeric column in place.
        /// @param | col | string | Column name.
        /// @param | val | number | Scalar value to add.
        methods.add_method_mut("colAdd", |_, this, (col, val): (String, f64)| {
            this.inner
                .borrow_mut()
                .col_scalar_op(&col, ScalarOp::Add, val)
                .map_err(LuaError::RuntimeError)
        });
        // -- colSub --
        /// Subtracts a scalar from a numeric column in place.
        /// @param | col | string | Column name.
        /// @param | val | number | Scalar value to subtract.
        methods.add_method_mut("colSub", |_, this, (col, val): (String, f64)| {
            this.inner
                .borrow_mut()
                .col_scalar_op(&col, ScalarOp::Sub, val)
                .map_err(LuaError::RuntimeError)
        });
        // -- colMul --
        /// Multiplies a numeric column by a scalar in place.
        /// @param | col | string | Column name.
        /// @param | val | number | Scalar multiplier.
        methods.add_method_mut("colMul", |_, this, (col, val): (String, f64)| {
            this.inner
                .borrow_mut()
                .col_scalar_op(&col, ScalarOp::Mul, val)
                .map_err(LuaError::RuntimeError)
        });
        // -- colDiv --
        /// Divides a numeric column by a scalar in place.
        /// @param | col | string | Column name.
        /// @param | val | number | Scalar divisor.
        methods.add_method_mut("colDiv", |_, this, (col, val): (String, f64)| {
            this.inner
                .borrow_mut()
                .col_scalar_op(&col, ScalarOp::Div, val)
                .map_err(LuaError::RuntimeError)
        });
        // -- colAbs --
        /// Applies absolute value to a numeric column in place.
        /// @param | col | string | Column name.
        methods.add_method_mut("colAbs", |_, this, col: String| {
            this.inner
                .borrow_mut()
                .col_scalar_op(&col, ScalarOp::Abs, 0.0)
                .map_err(LuaError::RuntimeError)
        });
        // -- colSqrt --
        /// Applies square root to a numeric column in place.
        /// @param | col | string | Column name.
        methods.add_method_mut("colSqrt", |_, this, col: String| {
            this.inner
                .borrow_mut()
                .col_scalar_op(&col, ScalarOp::Sqrt, 0.0)
                .map_err(LuaError::RuntimeError)
        });
        // -- colFloor --
        /// Applies floor to a numeric column in place.
        /// @param | col | string | Column name.
        methods.add_method_mut("colFloor", |_, this, col: String| {
            this.inner
                .borrow_mut()
                .col_scalar_op(&col, ScalarOp::Floor, 0.0)
                .map_err(LuaError::RuntimeError)
        });
        // -- colCeil --
        /// Applies ceil to a numeric column in place.
        /// @param | col | string | Column name.
        methods.add_method_mut("colCeil", |_, this, col: String| {
            this.inner
                .borrow_mut()
                .col_scalar_op(&col, ScalarOp::Ceil, 0.0)
                .map_err(LuaError::RuntimeError)
        });
        // -- colNeg --
        /// Negates a numeric column in place. This method is available to Lua scripts.
        /// @param | col | string | Column name.
        methods.add_method_mut("colNeg", |_, this, col: String| {
            this.inner
                .borrow_mut()
                .col_scalar_op(&col, ScalarOp::Neg, 0.0)
                .map_err(LuaError::RuntimeError)
        });
        // -- colClamp --
        /// Clamps a numeric column in place. This method is available to Lua scripts.
        /// @param | col | string | Column name.
        /// @param | min_val | number | Minimum allowed value.
        /// @param | max_val | number | Maximum allowed value.
        methods.add_method_mut(
            "colClamp",
            |_, this, (col, min_val, max_val): (String, f64, f64)| {
                this.inner
                    .borrow_mut()
                    .col_clamp(&col, min_val, max_val)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- colOp --
        /// Applies a binary column operation into an output column.
        /// @param | out_col | string | Output column name.
        /// @param | left_col | string | Left input column name.
        /// @param | op | string | Binary operation name.
        /// @param | right_col | string | Right input column name.
        methods.add_method_mut(
            "colOp",
            |_, this, (out_col, left_col, op, right_col): (String, String, String, String)| {
                let bop = BinaryOp::parse(&op).map_err(LuaError::RuntimeError)?;
                this.inner
                    .borrow_mut()
                    .col_binary_op(&out_col, &left_col, bop, &right_col)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- reduce --
        /// Reduces a numeric column with a named operation.
        /// @param | col | string | Column name.
        /// @param | op | string | Reduction operation name.
        /// @return | number | Reduction result.
        methods.add_method("reduce", |_, this, (col, op): (String, String)| {
            let rop = ReduceOp::parse(&op).map_err(LuaError::RuntimeError)?;
            this.inner
                .borrow()
                .col_reduce(&col, rop)
                .map_err(LuaError::RuntimeError)
        });
        // -- filterMask --
        /// Builds a boolean mask for a numeric column comparison.
        /// @param | col | string | Column name.
        /// @param | cmp_op | string | Comparison operation name.
        /// @param | val | number | Comparison value.
        /// @return | number[] | Array table of boolean mask values.
        methods.add_method(
            "filterMask",
            |lua, this, (col, cmp_op, val): (String, String, f64)| {
                let op = CmpOp::parse(&cmp_op).map_err(LuaError::RuntimeError)?;
                let mask = this
                    .inner
                    .borrow()
                    .filter_mask(&col, op, val)
                    .map_err(LuaError::RuntimeError)?;
                let tbl = lua.create_table()?;
                for (i, b) in mask.iter().enumerate() {
                    tbl.set(i + 1, *b)?;
                }
                Ok(tbl)
            },
        );
        // -- applyMask --
        /// Returns a vectorized frame filtered by a boolean mask table.
        /// @param | mask_tbl | table | Array table of booleans, one per row.
        /// @return | LVecFrame | New vectorized frame containing masked rows.
        methods.add_method("applyMask", |_, this, mask_tbl: LuaTable| {
            let len = mask_tbl.len()? as usize;
            let mut mask = Vec::with_capacity(len);
            for i in 1..=len {
                let b: bool = mask_tbl.get(i)?;
                mask.push(b);
            }
            let vf = this
                .inner
                .borrow()
                .apply_mask(&mask)
                .map_err(LuaError::RuntimeError)?;
            Ok(LuaVecFrame::new(vf, this.state.clone()))
        });
        // -- colType --
        /// Returns the data type name for a vectorized column.
        /// @param | col | string | Column name.
        /// @return | string | Column type name, or nil when the column is missing.
        methods.add_method("colType", |_, this, col: String| {
            Ok(this.inner.borrow().col_type(&col).map(|s| s.to_string()))
        });
        // -- colCast --
        /// Casts a vectorized column to another data type in place.
        /// @param | col | string | Column name.
        /// @param | dtype | string | Target data type name.
        methods.add_method_mut("colCast", |_, this, (col, dtype): (String, String)| {
            this.inner
                .borrow_mut()
                .col_cast(&col, &dtype)
                .map_err(LuaError::RuntimeError)
        });
        // -- nrows --
        /// Returns the number of rows in this vectorized frame.
        /// @return | integer | Row count.
        methods.add_method("nrows", |_, this, ()| Ok(this.inner.borrow().nrows()));
        // -- ncols --
        /// Returns the number of columns in this vectorized frame.
        /// @return | integer | Column count.
        methods.add_method("ncols", |_, this, ()| Ok(this.inner.borrow().ncols()));
        // -- columns --
        /// Returns all vectorized column names in order.
        /// @return | string[] | Column names.
        methods.add_method("columns", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, name) in this.inner.borrow().columns().iter().enumerate() {
                tbl.set(i + 1, name.clone())?;
            }
            Ok(tbl)
        });
        // -- parReduce --
        /// Reduces multiple numeric columns in parallel.
        /// @param | cols_tbl | table | Array table of column names.
        /// @param | op | string | Reduction operation name.
        /// @return | table | Table mapping column names to reduction results or nil.
        methods.add_method(
            "parReduce",
            |lua, this, (cols_tbl, op): (LuaTable, String)| {
                let rop = ReduceOp::parse(&op).map_err(LuaError::RuntimeError)?;
                let len = cols_tbl.len()? as usize;
                let cols: Vec<String> = (1..=len)
                    .map(|i| {
                        let s: String = cols_tbl.get(i)?;
                        LuaResult::Ok(s)
                    })
                    .collect::<LuaResult<_>>()?;
                let col_refs: Vec<&str> = cols.iter().map(|s| s.as_str()).collect();
                let results = this.inner.borrow().par_reduce(&col_refs, rop);
                let out = lua.create_table()?;
                for (k, v) in results {
                    match v {
                        Some(n) => out.set(k, n)?,
                        None => out.set(k, LuaValue::Nil)?,
                    }
                }
                Ok(out)
            },
        );
        // -- parScalarOp --
        /// Applies a scalar operation to multiple numeric columns in parallel.
        /// @param | cols_tbl | table | Array table of column names.
        /// @param | op | string | Scalar operation name.
        /// @param | val | number | Scalar value used by the operation.
        methods.add_method_mut(
            "parScalarOp",
            |_, this, (cols_tbl, op, val): (LuaTable, String, f64)| {
                let sop = ScalarOp::parse(&op).map_err(LuaError::RuntimeError)?;
                let len = cols_tbl.len()? as usize;
                let cols: Vec<String> = (1..=len)
                    .map(|i| {
                        let s: String = cols_tbl.get(i)?;
                        LuaResult::Ok(s)
                    })
                    .collect::<LuaResult<_>>()?;
                let col_refs: Vec<&str> = cols.iter().map(|s| s.as_str()).collect();
                this.inner
                    .borrow_mut()
                    .par_scalar_op(&col_refs, sop, val)
                    .map_err(LuaError::RuntimeError)
            },
        );
        // -- toDataFrame --
        /// Converts this vectorized frame to a dataframe.
        /// @return | LDataFrame | New dataframe handle.
        methods.add_method("toDataFrame", |_, this, ()| {
            Ok(LuaDataFrame::new(
                this.inner.borrow().to_dataframe(),
                this.state.clone(),
            ))
        });
        // -- type --
        /// Returns the Lua-visible type name for this vectorized frame handle.
        /// @return | string | The string `LVecFrame`.
        methods.add_method("type", |_, _, ()| Ok("LVecFrame"));
        // -- typeOf --
        /// Returns whether this vectorized frame handle matches a supported type name.
        /// @param | name | string | Type name to compare against `VecFrame` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LVecFrame" || name == "LObject")
        });
    }
}
/// Registers the `lurek.dataframe` API table with the Lua VM.
pub fn register(lua: &Lua, luna: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newDataFrame --
    /// Creates an empty dataframe. This function is exposed to Lua scripts.
    /// @return | LDataFrame | New empty dataframe handle.
    let dataframe_state = state.clone();
    tbl.set(
        "newDataFrame",
        lua.create_function(move |_, ()| {
            Ok(LuaDataFrame::new(DataFrame::new(), dataframe_state.clone()))
        })?,
    )?;
    // -- newDatabase --
    /// Creates an empty dataframe database.
    /// @return | LDatabase | New database handle.
    let database_state = state.clone();
    tbl.set(
        "newDatabase",
        lua.create_function(move |_, ()| {
            Ok(LuaDatabase::new(Database::new(), database_state.clone()))
        })?,
    )?;
    // -- fromTable --
    /// Creates a dataframe from an array table of row tables.
    /// @param | rows | table | Array of row tables keyed by column name.
    /// @return | LDataFrame | New dataframe handle.
    let from_table_state = state.clone();
    tbl.set(
        "fromTable",
        lua.create_function(move |_, rows: LuaTable| {
            let mut df = DataFrame::new();
            let len = rows.len()?;
            for i in 1..=len {
                let row: LuaTable = rows.get(i)?;
                if i == 1 {
                    for pair in row.clone().pairs::<String, LuaValue>() {
                        let (key, _) = pair?;
                        df.add_column(&key, CellValue::Nil)
                            .map_err(LuaError::RuntimeError)?;
                    }
                }
                let mut values = Vec::new();
                for pair in row.pairs::<String, LuaValue>() {
                    let (key, val) = pair?;
                    values.push((key, lua_to_cell(val)));
                }
                df.add_row(&values);
            }
            Ok(LuaDataFrame::new(df, from_table_state.clone()))
        })?,
    )?;
    // -- fromRows --
    /// Creates a dataframe from column names and array-style rows.
    /// @param | columns_tbl | table | Array table of column names.
    /// @param | rows_tbl | table | Array table of row arrays.
    /// @return | LDataFrame | New dataframe handle.
    let from_rows_state = state.clone();
    tbl.set(
        "fromRows",
        lua.create_function(move |_, (columns_tbl, rows_tbl): (LuaTable, LuaTable)| {
            let mut columns: Vec<String> = Vec::new();
            for name in columns_tbl.sequence_values::<String>() {
                columns.push(name?);
            }
            let mut rows: Vec<Vec<CellValue>> = Vec::new();
            for row_value in rows_tbl.sequence_values::<LuaTable>() {
                let row_tbl = row_value?;
                let mut row_cells: Vec<CellValue> = Vec::new();
                for cell_value in row_tbl.sequence_values::<LuaValue>() {
                    row_cells.push(lua_to_cell(cell_value?));
                }
                rows.push(row_cells);
            }
            let df = DataFrame::from_rows(columns, rows).map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrame::new(df, from_rows_state.clone()))
        })?,
    )?;
    // -- fromCSV --
    /// Parses a dataframe from CSV text. This function is exposed to Lua scripts.
    /// @param | s | string | CSV text.
    /// @return | LDataFrame | New dataframe handle.
    let from_csv_state = state.clone();
    tbl.set(
        "fromCSV",
        lua.create_function(move |_, s: String| {
            let df = serial::from_csv(&s).map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrame::new(df, from_csv_state.clone()))
        })?,
    )?;
    // -- fromCSVFile --
    /// Reads CSV text from GameFS and parses it into a dataframe.
    /// @param | path | string | GameFS path to read.
    /// @param | opts | table? | Optional file options table; reserved for future CSV options.
    /// @return | LDataFrame | New dataframe handle.
    let from_csv_file_state = state.clone();
    tbl.set(
        "fromCSVFile",
        lua.create_function(move |_, (path, opts): (String, Option<LuaTable>)| {
            validate_dataframe_file_opts(opts, "lurek.dataframe.fromCSVFile", &["csv"])?;
            let state = from_csv_file_state.borrow();
            let df = file_io::read_csv_dataframe(&state.fs, &path)
                .map_err(dataframe_file_error_to_lua)?;
            Ok(LuaDataFrame::new(df, from_csv_file_state.clone()))
        })?,
    )?;
    // -- fromCSVFileAsync --
    /// Starts a Rust worker task that reads CSV text from GameFS and parses it into a dataframe.
    /// @param | path | string | GameFS path to read.
    /// @param | opts | table? | Optional file options table; reserved for future CSV options.
    /// @return | LDataFrameTask | Task that resolves to a dataframe loaded from the CSV file.
    let from_csv_file_async_state = state.clone();
    tbl.set(
        "fromCSVFileAsync",
        lua.create_function(move |_, (path, opts): (String, Option<LuaTable>)| {
            validate_dataframe_file_opts(opts, "lurek.dataframe.fromCSVFileAsync", &["csv"])?;
            let filesystem = from_csv_file_async_state.borrow().fs.clone();
            let task =
                DataFrameTask::spawn_csv_file(filesystem, path, "lurek.dataframe.fromCSVFileAsync")
                    .map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrameTask::new(
                task,
                from_csv_file_async_state.clone(),
            ))
        })?,
    )?;
    // -- fromJSON --
    /// Parses a dataframe from JSON text. This function is exposed to Lua scripts.
    /// @param | s | string | JSON text.
    /// @return | LDataFrame | New dataframe handle.
    let from_json_state = state.clone();
    tbl.set(
        "fromJSON",
        lua.create_function(move |_, s: String| {
            let df = serial::from_json(&s).map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrame::new(df, from_json_state.clone()))
        })?,
    )?;
    // -- fromJSONFile --
    /// Reads JSON text from GameFS and parses it into a dataframe.
    /// @param | path | string | GameFS path to read.
    /// @param | opts | table? | Optional file options table; reserved for future JSON options.
    /// @return | LDataFrame | New dataframe handle.
    let from_json_file_state = state.clone();
    tbl.set(
        "fromJSONFile",
        lua.create_function(move |_, (path, opts): (String, Option<LuaTable>)| {
            validate_dataframe_file_opts(opts, "lurek.dataframe.fromJSONFile", &["json"])?;
            let state = from_json_file_state.borrow();
            let df = file_io::read_json_dataframe(&state.fs, &path)
                .map_err(dataframe_file_error_to_lua)?;
            Ok(LuaDataFrame::new(df, from_json_file_state.clone()))
        })?,
    )?;
    // -- fromJSONFileAsync --
    /// Starts a Rust worker task that reads JSON text from GameFS and parses it into a dataframe.
    /// @param | path | string | GameFS path to read.
    /// @param | opts | table? | Optional file options table; reserved for future JSON options.
    /// @return | LDataFrameTask | Task that resolves to a dataframe loaded from the JSON file.
    let from_json_file_async_state = state.clone();
    tbl.set(
        "fromJSONFileAsync",
        lua.create_function(move |_, (path, opts): (String, Option<LuaTable>)| {
            validate_dataframe_file_opts(opts, "lurek.dataframe.fromJSONFileAsync", &["json"])?;
            let filesystem = from_json_file_async_state.borrow().fs.clone();
            let task = DataFrameTask::spawn_json_file(
                filesystem,
                path,
                "lurek.dataframe.fromJSONFileAsync",
            )
            .map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrameTask::new(
                task,
                from_json_file_async_state.clone(),
            ))
        })?,
    )?;
    // -- fromBinary --
    /// Parses a dataframe from binary data.
    /// @param | s | string | Binary dataframe payload.
    /// @return | LDataFrame | New dataframe handle.
    let from_binary_state = state.clone();
    tbl.set(
        "fromBinary",
        lua.create_function(move |_, s: LuaString| {
            let df = serial::from_binary(s.as_bytes()).map_err(LuaError::RuntimeError)?;
            Ok(LuaDataFrame::new(df, from_binary_state.clone()))
        })?,
    )?;
    // -- loadDatabase --
    /// Reads a JSON database file from GameFS and parses it into a database.
    /// @param | path | string | GameFS path to read.
    /// @param | opts | table? | Optional options table; `format = "json"` is the only supported format.
    /// @return | LDatabase | New database handle.
    let load_database_state = state.clone();
    tbl.set(
        "loadDatabase",
        lua.create_function(move |_, (path, opts): (String, Option<LuaTable>)| {
            validate_database_file_opts(opts, "lurek.dataframe.loadDatabase")?;
            let state = load_database_state.borrow();
            let database = file_io::load_json_database(&state.fs, &path)
                .map_err(dataframe_file_error_to_lua)?;
            Ok(LuaDatabase::new(database, load_database_state.clone()))
        })?,
    )?;
    // -- random --
    /// Creates a random dataframe from column definitions.
    /// @param | defs_tbl | table | Array table of `{name, hint}` column definitions.
    /// @param | n | integer | Number of rows to generate.
    /// @param | seed | integer? | Optional random seed.
    /// @return | LDataFrame | New random dataframe handle.
    let random_state = state.clone();
    tbl.set(
        "random",
        lua.create_function(
            move |_, (defs_tbl, n, seed): (LuaTable, usize, Option<u64>)| {
                let mut defs = Vec::new();
                for i in 1..=defs_tbl.len()? {
                    let pair: LuaTable = defs_tbl.get(i)?;
                    let name: String = pair.get(1)?;
                    let hint: String = pair.get(2)?;
                    defs.push((name, hint));
                }
                Ok(LuaDataFrame::new(
                    DataFrame::random(&defs, n, seed),
                    random_state.clone(),
                ))
            },
        )?,
    )?;
    // -- toVec --
    /// Converts a dataframe to a vectorized frame.
    /// @param | df | LDataFrame | Dataframe handle to convert.
    /// @return | LVecFrame | New vectorized frame handle.
    tbl.set(
        "toVec",
        lua.create_function(|_, df: LuaAnyUserData| {
            let lua_df = df.borrow::<LuaDataFrame>()?;
            let vf = VecFrame::from_dataframe(&lua_df.inner.borrow());
            Ok(LuaVecFrame::new(vf, lua_df.state.clone()))
        })?,
    )?;
    // -- fromVec --
    /// Converts a vectorized frame to a dataframe.
    /// @param | vf | LVecFrame | Vectorized frame handle to convert.
    /// @return | LDataFrame | New dataframe handle.
    tbl.set(
        "fromVec",
        lua.create_function(|_, vf: LuaAnyUserData| {
            let lua_vf = vf.borrow::<LuaVecFrame>()?;
            let df = lua_vf.inner.borrow().to_dataframe();
            Ok(LuaDataFrame::new(df, lua_vf.state.clone()))
        })?,
    )?;
    /// Performs the 'dataframe' operation.
    luna.set("dataframe", tbl)?;
    Ok(())
}
