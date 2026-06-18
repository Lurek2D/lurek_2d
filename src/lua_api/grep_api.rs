//! Registers the `lurek.grep` Lua API for search requests, result conversion, and script-side grep inspection.

use super::SharedState;
use crate::grep::{engine::GrepEngine, filter::FileFilter, json_search, log_search, GrepConfig};
use mlua::prelude::*;
use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;

/// Lua userdata that performs search operations across game content files.
struct LuaGrepEngine {
    inner: Rc<RefCell<GrepEngine>>,
}

impl LuaUserData for LuaGrepEngine {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Search a directory for a literal pattern.
        /// @param | path | string | Directory to search.
        /// @param | pattern | string | Text pattern to find.
        /// @return | table | Search result with matches, files_searched, total_matches, duration_ms.
        methods.add_method("search", |lua, this, (path, pattern): (String, String)| {
            let filter = FileFilter::game_content();
            let result =
                this.inner
                    .borrow()
                    .search_literal(&PathBuf::from(&path), &pattern, &filter);
            result_to_table(lua, &result)
        });

        /// Search with a file extension filter.
        /// @param | path | string | Directory to search.
        /// @param | pattern | string | Text pattern.
        /// @param | extensions | table | Array of file extensions (for example {"lua", "toml"}).
        /// @return | table | Search result.
        methods.add_method(
            "searchExt",
            |lua, this, (path, pattern, exts): (String, String, Vec<String>)| {
                let mut filter = FileFilter::new();
                filter.extensions = exts;
                let result =
                    this.inner
                        .borrow()
                        .search_literal(&PathBuf::from(&path), &pattern, &filter);
                result_to_table(lua, &result)
            },
        );

        /// Search with multiple literal patterns simultaneously.
        /// @param | path | string | Directory to search.
        /// @param | patterns | table | Array of literal patterns.
        /// @return | table | Search result.
        methods.add_method(
            "multiSearch",
            |lua, this, (path, patterns): (String, Vec<String>)| {
                let filter = FileFilter::game_content();
                let result =
                    this.inner
                        .borrow()
                        .search_multi(&PathBuf::from(&path), patterns, &filter);
                result_to_table(lua, &result)
            },
        );

        /// Count total literal matches without returning line details.
        /// @param | path | string | Directory to search.
        /// @param | pattern | string | Text pattern.
        /// @return | integer | Total match count.
        methods.add_method("count", |_, this, (path, pattern): (String, String)| {
            let filter = FileFilter::game_content();
            Ok(this
                .inner
                .borrow()
                .count(&PathBuf::from(&path), &pattern, &filter))
        });

        /// Search a specific provided list of files for text matches.
        /// @param | files | table | Array of file paths.
        /// @param | pattern | string | Text pattern.
        /// @return | table | Search result.
        methods.add_method(
            "searchFiles",
            |lua, this, (files, pattern): (Vec<String>, String)| {
                let paths: Vec<PathBuf> = files.into_iter().map(PathBuf::from).collect();
                let result = this.inner.borrow().search_files(&paths, &pattern);
                result_to_table(lua, &result)
            },
        );
    }
}

/// Lua userdata that controls which files are scanned by a `LuaGrepEngine`.
struct LuaFileFilter {
    inner: Rc<RefCell<FileFilter>>,
}

impl LuaUserData for LuaFileFilter {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Add an allowed file extension to this filter.
        /// @param | ext | string | Extension (without dot).
        methods.add_method("addExtension", |_, this, ext: String| {
            this.inner.borrow_mut().extensions.push(ext);
            Ok(())
        });

        /// Add an excluded file extension to this filter.
        /// @param | ext | string | Extension to exclude.
        methods.add_method("excludeExtension", |_, this, ext: String| {
            this.inner.borrow_mut().exclude_extensions.push(ext);
            Ok(())
        });

        /// Add a path substring exclusion rule to this filter.
        /// @param | pattern | string | Substring to exclude in file paths.
        methods.add_method("excludePattern", |_, this, pattern: String| {
            this.inner.borrow_mut().exclude_patterns.push(pattern);
            Ok(())
        });

        /// Set whether hidden files are included.
        /// @param | include | boolean | Include hidden files.
        methods.add_method("setIncludeHidden", |_, this, include: bool| {
            this.inner.borrow_mut().include_hidden = include;
            Ok(())
        });
    }
}

fn result_to_table<'lua>(
    lua: &'lua Lua,
    result: &crate::grep::result::SearchResult,
) -> LuaResult<LuaTable<'lua>> {
    let tbl = lua.create_table()?;
    tbl.set("files_searched", result.files_searched)?;
    tbl.set("files_matched", result.files_matched)?;
    tbl.set("total_matches", result.total_matches)?;
    tbl.set("duration_ms", result.duration_ms)?;

    let matches_tbl = lua.create_table()?;
    for (i, file_match) in result.matches.iter().enumerate() {
        let fm_tbl = lua.create_table()?;
        fm_tbl.set("path", file_match.path.to_string_lossy().to_string())?;
        fm_tbl.set("total_matches", file_match.total_matches)?;

        let lines_tbl = lua.create_table()?;
        for (j, line_match) in file_match.lines.iter().enumerate() {
            let lm_tbl = lua.create_table()?;
            lm_tbl.set("line", line_match.line_number)?;
            lm_tbl.set("content", line_match.content.clone())?;
            lines_tbl.set(j + 1, lm_tbl)?;
        }
        fm_tbl.set("lines", lines_tbl)?;
        matches_tbl.set(i + 1, fm_tbl)?;
    }
    // Return the per-file match list under `matches` so Lua callers can inspect line-level grep hits.
    tbl.set("matches", matches_tbl)?;

    Ok(tbl)
}

/// Register the `lurek.grep` module.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let module = lua.create_table()?;

    /// Create a new grep engine with default settings.
    /// @return | LGrepEngine | Grep engine instance.
    module.set(
        "newEngine",
        lua.create_function(|_, ()| {
            Ok(LuaGrepEngine {
                inner: Rc::new(RefCell::new(GrepEngine::default())),
            })
        })?,
    )?;

    /// Create a grep engine with custom options.
    /// @param | opts | table | Options: threads (integer), case_sensitive (boolean), whole_word (boolean), max_file_size (integer).
    /// @return | LGrepEngine | Grep engine instance.
    module.set(
        "newEngineOpts",
        lua.create_function(|_, opts: LuaTable| {
            let threads: usize = opts.get("threads").unwrap_or(4);
            let case_sensitive: bool = opts.get("case_sensitive").unwrap_or(true);
            let whole_word: bool = opts.get("whole_word").unwrap_or(false);
            let max_file_size: u64 = opts.get("max_file_size").unwrap_or(50 * 1024 * 1024);
            let config = GrepConfig {
                thread_count: threads,
                max_file_size,
                case_sensitive,
                whole_word,
                ..Default::default()
            };
            Ok(LuaGrepEngine {
                inner: Rc::new(RefCell::new(GrepEngine::new(config))),
            })
        })?,
    )?;

    /// Create an empty file filter.
    /// @return | LFileFilter | File filter instance.
    module.set(
        "newFilter",
        lua.create_function(|_, ()| {
            Ok(LuaFileFilter {
                inner: Rc::new(RefCell::new(FileFilter::new())),
            })
        })?,
    )?;

    /// Create a filter for Lua files only.
    /// @return | LFileFilter | Pre-configured Lua filter.
    module.set(
        "luaFilter",
        lua.create_function(|_, ()| {
            Ok(LuaFileFilter {
                inner: Rc::new(RefCell::new(FileFilter::lua_files())),
            })
        })?,
    )?;

    /// Search a directory for a literal pattern in game content files.
    /// @param | path | string | Directory path.
    /// @param | pattern | string | Text to search for.
    /// @return | table | Search result.
    module.set(
        "search",
        lua.create_function(|lua, (path, pattern): (String, String)| {
            let engine = GrepEngine::default();
            let filter = FileFilter::game_content();
            let result = engine.search_literal(&PathBuf::from(&path), &pattern, &filter);
            result_to_table(lua, &result)
        })?,
    )?;

    /// Search a JSON file for every matching key name.
    /// @param | file | string | JSON file path.
    /// @param | key | string | Key name to search for.
    /// @return | table | Array of matches with path and value.
    module.set(
        "jsonSearch",
        lua.create_function(|lua, (file, key): (String, String)| {
            let matches = json_search::search_json_file(&PathBuf::from(&file), &key, None);
            let tbl = lua.create_table()?;
            for (i, m) in matches.iter().enumerate() {
                let entry = lua.create_table()?;
                entry.set("path", m.path.clone())?;
                entry.set("value", m.value.clone())?;
                tbl.set(i + 1, entry)?;
            }
            Ok(tbl)
        })?,
    )?;

    /// Search a structured log file by level and literal message pattern.
    /// @param | file | string | Log file path.
    /// @param | level | string | Log level filter (INFO, WARN, ERROR, etc.) or empty.
    /// @param | pattern | string | Literal message pattern or empty.
    /// @return | table | Array of matching log entries.
    module.set(
        "logSearch",
        lua.create_function(|lua, (file, level, pattern): (String, String, String)| {
            let content = std::fs::read_to_string(&file)
                .map_err(|e| LuaError::runtime(format!("cannot read file: {e}")))?;
            let lines: Vec<String> = content.lines().map(|l| l.to_string()).collect();
            let entries = log_search::parse_log_lines(&lines);
            let opts = log_search::LogSearchOpts {
                level_filter: if level.is_empty() { None } else { Some(level) },
                pattern: if pattern.is_empty() {
                    None
                } else {
                    Some(pattern)
                },
                ..Default::default()
            };
            let results = log_search::search_logs(&entries, &opts);
            let tbl = lua.create_table()?;
            for (i, entry) in results.iter().enumerate() {
                let e = lua.create_table()?;
                e.set("line", entry.line_number)?;
                e.set("message", entry.message.clone())?;
                if let Some(ref ts) = entry.timestamp {
                    e.set("timestamp", ts.clone())?;
                }
                if let Some(ref lvl) = entry.level {
                    e.set("level", lvl.clone())?;
                }
                tbl.set(i + 1, e)?;
            }
            Ok(tbl)
        })?,
    )?;

    lurek.set("grep", module)?;
    Ok(())
}
