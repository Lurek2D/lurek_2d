//! - SQL text tokenizer producing typed token stream
//! - Recursive-descent parser for SELECT statements
//! - WHERE clause expression tree with AND, OR, NOT, LIKE, and IN
//! - Aggregate function support: COUNT, SUM, AVG, MIN, MAX
//! - SELECT arithmetic expressions with explicit `AS` aliases
//! - GROUP BY with HAVING filter and ORDER BY with LIMIT/OFFSET
//! - JOIN clause parsing and inner-join execution
//! - SQL LIKE pattern matching with `%` and `_` wildcards
//! - Single-frame and multi-table Database query entry points

use crate::dataframe::frame::{CellValue, ColRef, DataFrame, Database};
#[derive(Debug, Clone, PartialEq)]
/// Store lexical tokens produced from SQL text.
enum Token {
    /// Store identifier token.
    Ident(String),
    /// Store quoted string literal token.
    StringLit(String),
    /// Store numeric literal token.
    NumberLit(f64),
    /// Store wildcard token.
    Star,
    /// Store comma separator token.
    Comma,
    /// Store dot token for qualified names.
    Dot,
    /// Store left parenthesis token.
    LParen,
    /// Store right parenthesis token.
    RParen,
    /// Store comparison operator token.
    Op(String),
    /// Mark end-of-input token.
    Eof,
}
/// Tokenize SQL text and return ordered token stream.
fn tokenize(sql: &str) -> Result<Vec<Token>, String> {
    let chars: Vec<char> = sql.chars().collect();
    let len = chars.len();
    let mut tokens = Vec::new();
    let mut i = 0;
    let mut expect_value = true;
    while i < len {
        let c = chars[i];
        if c.is_ascii_whitespace() {
            i += 1;
            continue;
        }
        match c {
            '*' => {
                tokens.push(Token::Star);
                i += 1;
                expect_value = true;
            }
            ',' => {
                tokens.push(Token::Comma);
                i += 1;
                expect_value = true;
            }
            '.' => {
                tokens.push(Token::Dot);
                i += 1;
                expect_value = true;
            }
            '(' => {
                tokens.push(Token::LParen);
                i += 1;
                expect_value = true;
            }
            ')' => {
                tokens.push(Token::RParen);
                i += 1;
                expect_value = false;
            }
            '+' | '/' => {
                tokens.push(Token::Op(c.to_string()));
                i += 1;
                expect_value = true;
            }
            '-' if !(expect_value && i + 1 < len && chars[i + 1].is_ascii_digit()) => {
                tokens.push(Token::Op("-".to_string()));
                i += 1;
                expect_value = true;
            }
            '=' => {
                tokens.push(Token::Op("=".to_string()));
                i += 1;
                expect_value = true;
            }
            '!' => {
                if i + 1 < len && chars[i + 1] == '=' {
                    tokens.push(Token::Op("!=".to_string()));
                    i += 2;
                    expect_value = true;
                } else {
                    return Err(format!("unexpected '!' at position {i}"));
                }
            }
            '<' => {
                if i + 1 < len && chars[i + 1] == '=' {
                    tokens.push(Token::Op("<=".to_string()));
                    i += 2;
                    expect_value = true;
                } else if i + 1 < len && chars[i + 1] == '>' {
                    tokens.push(Token::Op("!=".to_string()));
                    i += 2;
                    expect_value = true;
                } else {
                    tokens.push(Token::Op("<".to_string()));
                    i += 1;
                    expect_value = true;
                }
            }
            '>' => {
                if i + 1 < len && chars[i + 1] == '=' {
                    tokens.push(Token::Op(">=".to_string()));
                    i += 2;
                    expect_value = true;
                } else {
                    tokens.push(Token::Op(">".to_string()));
                    i += 1;
                    expect_value = true;
                }
            }
            '\'' => {
                i += 1;
                let mut s = String::new();
                while i < len {
                    if chars[i] == '\'' {
                        if i + 1 < len && chars[i + 1] == '\'' {
                            s.push('\'');
                            i += 2;
                        } else {
                            break;
                        }
                    } else {
                        s.push(chars[i]);
                        i += 1;
                    }
                }
                if i >= len {
                    return Err("unterminated string literal".to_string());
                }
                i += 1;
                tokens.push(Token::StringLit(s));
                expect_value = false;
            }
            '"' => {
                i += 1;
                let mut s = String::new();
                while i < len && chars[i] != '"' {
                    s.push(chars[i]);
                    i += 1;
                }
                if i >= len {
                    return Err("unterminated double-quoted identifier".to_string());
                }
                i += 1;
                tokens.push(Token::Ident(s));
                expect_value = false;
            }
            _ if c.is_ascii_digit()
                || (c == '-' && expect_value && i + 1 < len && chars[i + 1].is_ascii_digit()) =>
            {
                let start = i;
                if c == '-' {
                    i += 1;
                }
                while i < len && (chars[i].is_ascii_digit() || chars[i] == '.') {
                    i += 1;
                }
                if i < len && (chars[i] == 'e' || chars[i] == 'E') {
                    i += 1;
                    if i < len && (chars[i] == '+' || chars[i] == '-') {
                        i += 1;
                    }
                    while i < len && chars[i].is_ascii_digit() {
                        i += 1;
                    }
                }
                let num_str: String = chars[start..i].iter().collect();
                let n: f64 = num_str
                    .parse()
                    .map_err(|_| format!("invalid number: {num_str}"))?;
                tokens.push(Token::NumberLit(n));
                expect_value = false;
            }
            _ if c.is_ascii_alphabetic() || c == '_' => {
                let start = i;
                while i < len && (chars[i].is_ascii_alphanumeric() || chars[i] == '_') {
                    i += 1;
                }
                let word: String = chars[start..i].iter().collect();
                tokens.push(Token::Ident(word));
                expect_value = false;
            }
            _ => {
                return Err(format!("unexpected character '{c}' in SQL at position {i}"));
            }
        }
    }
    tokens.push(Token::Eof);
    Ok(tokens)
}
#[derive(Debug)]
/// Store parsed SELECT statement components.
struct SqlSelect {
    /// Store selected expressions.
    columns: Vec<SelectExpr>,
    /// Store optional source table name.
    from: Option<String>,
    /// Store JOIN clauses in parse order.
    joins: Vec<JoinClause>,
    /// Store optional WHERE expression tree.
    where_clause: Option<Expr>,
    /// Store optional GROUP BY column name.
    group_by: Option<String>,
    /// Store optional HAVING expression tree.
    having: Option<Expr>,
    /// Store optional ORDER BY specification.
    order_by: Option<(String, bool)>,
    /// Store optional row limit.
    limit: Option<usize>,
    /// Store optional row offset.
    offset: Option<usize>,
}
#[derive(Debug)]
/// Represent one item from a SELECT expression list.
enum SelectExpr {
    /// Select all columns.
    Star,
    /// Select one value expression with optional alias.
    Value {
        /// Store parsed value expression.
        expr: SelectValueExpr,
        /// Store explicit output column alias.
        alias: Option<String>,
    },
}
#[derive(Debug, Clone)]
/// Select aggregate function kind.
enum AggFunc {
    /// Count rows or non-nil values.
    Count,
    /// Sum numeric values.
    Sum,
    /// Compute arithmetic mean.
    Avg,
    /// Compute smallest value.
    Min,
    /// Compute largest value.
    Max,
}
#[derive(Debug, Clone)]
/// Represent aggregate argument shape.
enum AggArg {
    /// Target all rows.
    Star,
    /// Target one named column.
    Column(String),
}
#[derive(Debug)]
/// Represent numeric-capable SELECT value expressions.
enum SelectValueExpr {
    /// Select one named column.
    Column(String),
    /// Select numeric literal.
    Number(f64),
    /// Select aggregate over argument.
    Aggregate(AggFunc, AggArg),
    /// Select arithmetic combination of two expressions.
    Binary {
        /// Store left-hand expression.
        left: Box<SelectValueExpr>,
        /// Store arithmetic operator.
        op: ArithmeticOp,
        /// Store right-hand expression.
        right: Box<SelectValueExpr>,
    },
}
#[derive(Debug, Clone, Copy)]
/// Represent arithmetic operator used in SELECT expressions.
enum ArithmeticOp {
    /// Add operands.
    Add,
    /// Subtract right operand from left operand.
    Sub,
    /// Multiply operands.
    Mul,
    /// Divide left operand by right operand.
    Div,
}
impl ArithmeticOp {
    /// Return SQL display symbol for this operator.
    fn symbol(self) -> &'static str {
        match self {
            ArithmeticOp::Add => "+",
            ArithmeticOp::Sub => "-",
            ArithmeticOp::Mul => "*",
            ArithmeticOp::Div => "/",
        }
    }
}
#[derive(Debug)]
/// Store parsed JOIN clause data.
struct JoinClause {
    /// Store joined table name.
    table: String,
    /// Store left column name.
    left_col: String,
    /// Store right column name.
    right_col: String,
}
#[derive(Debug)]
/// Store boolean expression tree for WHERE and HAVING.
enum Expr {
    /// Compare column with value using operator.
    Compare(String, String, CellValue),
    /// Match text column against SQL LIKE pattern.
    Like(String, String),
    /// Check whether value is in constant list.
    In(String, Vec<CellValue>),
    /// Negate expression result.
    Not(Box<Expr>),
    /// Logical conjunction.
    And(Box<Expr>, Box<Expr>),
    /// Logical disjunction.
    Or(Box<Expr>, Box<Expr>),
}
/// Hold token stream and cursor for recursive-descent parsing.
struct Parser {
    /// Store token stream for current query.
    tokens: Vec<Token>,
    /// Store current token index.
    pos: usize,
}
impl Parser {
    /// Create parser at token index zero.
    fn new(tokens: Vec<Token>) -> Self {
        Self { tokens, pos: 0 }
    }
    /// Return current token reference without advancing.
    fn peek(&self) -> &Token {
        &self.tokens[self.pos]
    }
    /// Return current token and advance cursor when possible.
    fn advance(&mut self) -> Token {
        let t = self.tokens[self.pos].clone();
        if self.pos < self.tokens.len() - 1 {
            self.pos += 1;
        }
        t
    }
    /// Read identifier token and return identifier text.
    fn expect_ident(&mut self) -> Result<String, String> {
        match self.advance() {
            Token::Ident(s) => Ok(s),
            other => Err(format!("expected identifier, got {other:?}")),
        }
    }
    /// Return true when current token is requested keyword.
    fn is_keyword(&self, kw: &str) -> bool {
        matches!(self.peek(), Token::Ident(s) if s.eq_ignore_ascii_case(kw))
    }
    /// Consume keyword token and return whether keyword matched.
    fn consume_keyword(&mut self, kw: &str) -> bool {
        if self.is_keyword(kw) {
            self.advance();
            true
        } else {
            false
        }
    }
    /// Consume required keyword or return parse error.
    fn expect_keyword(&mut self, kw: &str) -> Result<(), String> {
        if self.consume_keyword(kw) {
            Ok(())
        } else {
            Err(format!("expected keyword '{kw}', got {:?}", self.peek()))
        }
    }
    /// Parse full SELECT statement into intermediate representation.
    fn parse_select(&mut self) -> Result<SqlSelect, String> {
        self.expect_keyword("SELECT")?;
        let columns = self.parse_select_list()?;
        let from = if self.consume_keyword("FROM") {
            Some(self.expect_ident()?)
        } else {
            None
        };
        let mut joins = Vec::new();
        while self.consume_keyword("JOIN") {
            let table = self.expect_ident()?;
            self.expect_keyword("ON")?;
            let left_table_or_col = self.expect_ident()?;
            let left_col = if matches!(self.peek(), Token::Dot) {
                self.advance();
                self.expect_ident()?
            } else {
                left_table_or_col
            };
            match self.advance() {
                Token::Op(ref s) if s == "=" => {}
                other => return Err(format!("expected '=' in JOIN ON, got {other:?}")),
            }
            let right_table_or_col = self.expect_ident()?;
            let right_col = if matches!(self.peek(), Token::Dot) {
                self.advance();
                self.expect_ident()?
            } else {
                right_table_or_col
            };
            joins.push(JoinClause {
                table,
                left_col,
                right_col,
            });
        }
        let where_clause = if self.consume_keyword("WHERE") {
            Some(self.parse_expr()?)
        } else {
            None
        };
        let group_by = if self.consume_keyword("GROUP") {
            self.expect_keyword("BY")?;
            Some(self.expect_ident()?)
        } else {
            None
        };
        let having = if self.consume_keyword("HAVING") {
            Some(self.parse_expr()?)
        } else {
            None
        };
        let order_by = if self.consume_keyword("ORDER") {
            self.expect_keyword("BY")?;
            let col = self.expect_ident()?;
            let ascending = if self.consume_keyword("DESC") {
                false
            } else {
                self.consume_keyword("ASC");
                true
            };
            Some((col, ascending))
        } else {
            None
        };
        let limit = if self.consume_keyword("LIMIT") {
            match self.advance() {
                Token::NumberLit(n) => Some(n as usize),
                other => return Err(format!("expected number after LIMIT, got {other:?}")),
            }
        } else {
            None
        };
        let offset = if self.consume_keyword("OFFSET") {
            match self.advance() {
                Token::NumberLit(n) => Some(n as usize),
                other => return Err(format!("expected number after OFFSET, got {other:?}")),
            }
        } else {
            None
        };
        Ok(SqlSelect {
            columns,
            from,
            joins,
            where_clause,
            group_by,
            having,
            order_by,
            limit,
            offset,
        })
    }
    /// Parse comma-separated SELECT expression list.
    fn parse_select_list(&mut self) -> Result<Vec<SelectExpr>, String> {
        let mut list = Vec::new();
        loop {
            if matches!(self.peek(), Token::Star) {
                self.advance();
                list.push(SelectExpr::Star);
            } else {
                let expr = self.parse_select_value_expr()?;
                let alias = if self.consume_keyword("AS") {
                    Some(self.expect_ident()?)
                } else {
                    None
                };
                list.push(SelectExpr::Value { expr, alias });
            }
            if matches!(self.peek(), Token::Comma) {
                self.advance();
            } else {
                break;
            }
        }
        Ok(list)
    }
    /// Parse arithmetic SELECT value expression.
    fn parse_select_value_expr(&mut self) -> Result<SelectValueExpr, String> {
        self.parse_additive_value_expr()
    }
    /// Parse addition and subtraction precedence for SELECT values.
    fn parse_additive_value_expr(&mut self) -> Result<SelectValueExpr, String> {
        let mut left_expr = self.parse_multiplicative_value_expr()?;
        loop {
            let op = match self.peek() {
                Token::Op(operator) if operator == "+" => ArithmeticOp::Add,
                Token::Op(operator) if operator == "-" => ArithmeticOp::Sub,
                _ => break,
            };
            self.advance();
            let right_expr = self.parse_multiplicative_value_expr()?;
            left_expr = SelectValueExpr::Binary {
                left: Box::new(left_expr),
                op,
                right: Box::new(right_expr),
            };
        }
        Ok(left_expr)
    }
    /// Parse multiplication and division precedence for SELECT values.
    fn parse_multiplicative_value_expr(&mut self) -> Result<SelectValueExpr, String> {
        let mut left_expr = self.parse_primary_value_expr()?;
        loop {
            let op = match self.peek() {
                Token::Star => ArithmeticOp::Mul,
                Token::Op(operator) if operator == "/" => ArithmeticOp::Div,
                _ => break,
            };
            self.advance();
            let right_expr = self.parse_primary_value_expr()?;
            left_expr = SelectValueExpr::Binary {
                left: Box::new(left_expr),
                op,
                right: Box::new(right_expr),
            };
        }
        Ok(left_expr)
    }
    /// Parse primary SELECT value expression.
    fn parse_primary_value_expr(&mut self) -> Result<SelectValueExpr, String> {
        match self.peek().clone() {
            Token::NumberLit(number) => {
                self.advance();
                Ok(SelectValueExpr::Number(number))
            }
            Token::Ident(_) if self.is_agg_func() => self.parse_agg_value_expr(),
            Token::Ident(_) => Ok(SelectValueExpr::Column(self.parse_column_name()?)),
            Token::LParen => {
                self.advance();
                let expr = self.parse_select_value_expr()?;
                match self.advance() {
                    Token::RParen => Ok(expr),
                    other => Err(format!("expected ')' in SELECT expression, got {other:?}")),
                }
            }
            Token::Op(operator) if operator == "-" => {
                self.advance();
                let expr = self.parse_primary_value_expr()?;
                Ok(SelectValueExpr::Binary {
                    left: Box::new(SelectValueExpr::Number(0.0)),
                    op: ArithmeticOp::Sub,
                    right: Box::new(expr),
                })
            }
            Token::Op(operator) if operator == "+" => {
                self.advance();
                self.parse_primary_value_expr()
            }
            other => Err(format!("expected SELECT expression, got {other:?}")),
        }
    }
    /// Parse possibly qualified column name.
    fn parse_column_name(&mut self) -> Result<String, String> {
        let first_name = self.expect_ident()?;
        if matches!(self.peek(), Token::Dot) {
            self.advance();
            self.expect_ident()
        } else {
            Ok(first_name)
        }
    }
    /// Return true when current token starts aggregate call.
    fn is_agg_func(&self) -> bool {
        matches!(self.peek(), Token::Ident(s) if {
            let u = s.to_uppercase();
            u == "COUNT" || u == "SUM" || u == "AVG" || u == "MIN" || u == "MAX"
        })
    }
    /// Parse aggregate function call from SELECT value expression.
    fn parse_agg_value_expr(&mut self) -> Result<SelectValueExpr, String> {
        let func_name = self.expect_ident()?;
        let func = match func_name.to_uppercase().as_str() {
            "COUNT" => AggFunc::Count,
            "SUM" => AggFunc::Sum,
            "AVG" => AggFunc::Avg,
            "MIN" => AggFunc::Min,
            "MAX" => AggFunc::Max,
            _ => return Err(format!("unknown aggregate function: {func_name}")),
        };
        match self.advance() {
            Token::LParen => {}
            other => return Err(format!("expected '(' after {func_name}, got {other:?}")),
        }
        let arg = if matches!(self.peek(), Token::Star) {
            self.advance();
            AggArg::Star
        } else {
            let col = self.parse_column_name()?;
            AggArg::Column(col)
        };
        match self.advance() {
            Token::RParen => {}
            other => return Err(format!("expected ')' after aggregate, got {other:?}")),
        }
        Ok(SelectValueExpr::Aggregate(func, arg))
    }
    /// Parse OR-precedence expression.
    fn parse_expr(&mut self) -> Result<Expr, String> {
        let mut left = self.parse_and_expr()?;
        while self.consume_keyword("OR") {
            let right = self.parse_and_expr()?;
            left = Expr::Or(Box::new(left), Box::new(right));
        }
        Ok(left)
    }
    /// Parse AND-precedence expression.
    fn parse_and_expr(&mut self) -> Result<Expr, String> {
        let mut left = self.parse_not_expr()?;
        while self.consume_keyword("AND") {
            let right = self.parse_not_expr()?;
            left = Expr::And(Box::new(left), Box::new(right));
        }
        Ok(left)
    }
    /// Parse NOT-precedence expression.
    fn parse_not_expr(&mut self) -> Result<Expr, String> {
        if self.consume_keyword("NOT") {
            let inner = self.parse_primary_expr()?;
            Ok(Expr::Not(Box::new(inner)))
        } else {
            self.parse_primary_expr()
        }
    }
    /// Parse primary expression node including comparisons and grouped expressions.
    fn parse_primary_expr(&mut self) -> Result<Expr, String> {
        if matches!(self.peek(), Token::LParen) {
            self.advance();
            let expr = self.parse_expr()?;
            match self.advance() {
                Token::RParen => {}
                other => return Err(format!("expected ')', got {other:?}")),
            }
            return Ok(expr);
        }
        let col = self.expect_ident()?;
        let col = if matches!(self.peek(), Token::Dot) {
            self.advance();
            self.expect_ident()?
        } else {
            col
        };
        if self.consume_keyword("NOT") {
            if self.consume_keyword("LIKE") {
                let pattern = self.parse_string_value()?;
                Ok(Expr::Not(Box::new(Expr::Like(col, pattern))))
            } else if self.consume_keyword("IN") {
                let vals = self.parse_in_list()?;
                Ok(Expr::Not(Box::new(Expr::In(col, vals))))
            } else {
                Err("expected LIKE or IN after NOT".to_string())
            }
        } else if self.consume_keyword("LIKE") {
            let pattern = self.parse_string_value()?;
            Ok(Expr::Like(col, pattern))
        } else if self.consume_keyword("IN") {
            let vals = self.parse_in_list()?;
            Ok(Expr::In(col, vals))
        } else {
            let op = match self.advance() {
                Token::Op(s) => s,
                other => {
                    return Err(format!(
                        "expected operator after column '{col}', got {other:?}"
                    ))
                }
            };
            let val = self.parse_cell_value()?;
            let op = if op == "=" { "==".to_string() } else { op };
            Ok(Expr::Compare(col, op, val))
        }
    }
    /// Parse one quoted SQL string literal.
    fn parse_string_value(&mut self) -> Result<String, String> {
        match self.advance() {
            Token::StringLit(s) => Ok(s),
            other => Err(format!("expected string literal, got {other:?}")),
        }
    }
    /// Parse IN list values between parentheses.
    fn parse_in_list(&mut self) -> Result<Vec<CellValue>, String> {
        match self.advance() {
            Token::LParen => {}
            other => return Err(format!("expected '(' after IN, got {other:?}")),
        }
        let mut vals = Vec::new();
        loop {
            if matches!(self.peek(), Token::RParen) {
                self.advance();
                break;
            }
            if !vals.is_empty() {
                match self.advance() {
                    Token::Comma => {}
                    other => return Err(format!("expected ',' in IN list, got {other:?}")),
                }
            }
            vals.push(self.parse_cell_value()?);
        }
        Ok(vals)
    }
    /// Parse SQL literal into dataframe cell value.
    fn parse_cell_value(&mut self) -> Result<CellValue, String> {
        match self.peek().clone() {
            Token::NumberLit(n) => {
                self.advance();
                Ok(CellValue::Number(n))
            }
            Token::StringLit(s) => {
                self.advance();
                Ok(CellValue::Text(s))
            }
            Token::Ident(ref s) if s.eq_ignore_ascii_case("NULL") => {
                self.advance();
                Ok(CellValue::Nil)
            }
            Token::Ident(ref s) if s.eq_ignore_ascii_case("TRUE") => {
                self.advance();
                Ok(CellValue::Bool(true))
            }
            Token::Ident(ref s) if s.eq_ignore_ascii_case("FALSE") => {
                self.advance();
                Ok(CellValue::Bool(false))
            }
            other => Err(format!("expected value, got {other:?}")),
        }
    }
}
/// Execute SQL-like query over one DataFrame and return result frame.
pub fn query_sql(df: &DataFrame, sql: &str) -> Result<DataFrame, String> {
    let tokens = tokenize(sql)?;
    let mut parser = Parser::new(tokens);
    let stmt = parser.parse_select()?;
    execute_select(df, &stmt)
}
/// Execute SQL-like query against Database table references.
pub fn query_sql_database(db: &Database, sql: &str) -> Result<DataFrame, String> {
    let tokens = tokenize(sql)?;
    let mut parser = Parser::new(tokens);
    let stmt = parser.parse_select()?;
    let base_table_name = stmt
        .from
        .as_ref()
        .ok_or("SQL query on Database requires FROM clause")?;
    let base = db
        .get_table(base_table_name)
        .ok_or_else(|| format!("table not found: {base_table_name}"))?;
    let mut working = base.clone_df();
    for join in &stmt.joins {
        let right = db
            .get_table(&join.table)
            .ok_or_else(|| format!("table not found: {}", join.table))?;
        working = working.join(
            right,
            ColRef::Name(join.left_col.clone()),
            ColRef::Name(join.right_col.clone()),
            "inner",
        )?;
    }
    execute_select(&working, &stmt)
}
/// Execute SQL-like database query after binding positional parameters.
pub fn query_sql_database_params(
    db: &Database,
    sql: &str,
    params: &[CellValue],
) -> Result<DataFrame, String> {
    let bound_sql = bind_sql_params(sql, params)?;
    query_sql_database(db, &bound_sql)
}
/// Replace `?` placeholders outside SQL strings with escaped SQL literals.
fn bind_sql_params(sql: &str, params: &[CellValue]) -> Result<String, String> {
    let mut result = String::with_capacity(sql.len());
    let mut param_index = 0usize;
    let mut chars = sql.chars().peekable();

    while let Some(ch) = chars.next() {
        match ch {
            '\'' => copy_quoted_sql('\'', &mut chars, &mut result),
            '"' => copy_quoted_sql('"', &mut chars, &mut result),
            '?' => {
                let Some(param) = params.get(param_index) else {
                    return Err(format!(
                        "queryParams: missing parameter for placeholder {}",
                        param_index + 1
                    ));
                };
                result.push_str(&cell_to_sql_literal(param)?);
                param_index += 1;
            }
            _ => result.push(ch),
        }
    }

    if param_index != params.len() {
        return Err(format!(
            "queryParams: {} parameter(s) were not used",
            params.len() - param_index
        ));
    }

    Ok(result)
}
/// Copy a SQL quoted section without replacing placeholders inside it.
fn copy_quoted_sql(
    quote: char,
    chars: &mut std::iter::Peekable<std::str::Chars<'_>>,
    result: &mut String,
) {
    result.push(quote);
    while let Some(ch) = chars.next() {
        result.push(ch);
        if ch == quote {
            if quote == '\'' && matches!(chars.peek(), Some('\'')) {
                result.push(chars.next().unwrap_or('\''));
            } else {
                break;
            }
        }
    }
}
/// Convert a cell value to a SQL literal accepted by the built-in parser.
fn cell_to_sql_literal(value: &CellValue) -> Result<String, String> {
    match value {
        CellValue::Nil => Ok("NULL".to_string()),
        CellValue::Bool(true) => Ok("TRUE".to_string()),
        CellValue::Bool(false) => Ok("FALSE".to_string()),
        CellValue::Number(n) => {
            if !n.is_finite() {
                return Err("queryParams: non-finite numbers are not supported".to_string());
            }
            Ok(n.to_string())
        }
        CellValue::Text(text) => Ok(format!("'{}'", text.replace('\'', "''"))),
    }
}
/// Execute parsed SELECT statement against a dataframe.
fn execute_select(df: &DataFrame, stmt: &SqlSelect) -> Result<DataFrame, String> {
    let filtered = if let Some(ref where_expr) = stmt.where_clause {
        apply_filter(df, where_expr)?
    } else {
        df.clone_df()
    };
    let result = if let Some(ref group_col) = stmt.group_by {
        execute_group_by(&filtered, group_col, &stmt.columns, stmt.having.as_ref())?
    } else if has_aggregates(&stmt.columns) {
        execute_aggregate_no_group(&filtered, &stmt.columns)?
    } else {
        execute_column_select(&filtered, &stmt.columns)?
    };
    let result = if let Some((ref col, ascending)) = stmt.order_by {
        result.sort(ColRef::Name(col.clone()), ascending)?
    } else {
        result
    };
    let result = if let Some(offset) = stmt.offset {
        if offset >= result.nrows() {
            DataFrame::from_raw(result.columns().to_vec(), vec![Vec::new(); result.ncols()])
        } else {
            result.slice(offset, result.nrows().saturating_sub(1))?
        }
    } else {
        result
    };
    let result = if let Some(limit) = stmt.limit {
        result.head(limit)
    } else {
        result
    };
    Ok(result)
}
/// Return true when SELECT list contains at least one aggregate expression.
fn has_aggregates(columns: &[SelectExpr]) -> bool {
    columns.iter().any(select_expr_has_aggregate)
}
/// Return true when SELECT expression contains any aggregate call.
fn select_expr_has_aggregate(expr: &SelectExpr) -> bool {
    match expr {
        SelectExpr::Star => false,
        SelectExpr::Value { expr, .. } => value_expr_has_aggregate(expr),
    }
}
/// Return true when value expression contains any aggregate call.
fn value_expr_has_aggregate(expr: &SelectValueExpr) -> bool {
    match expr {
        SelectValueExpr::Aggregate(_, _) => true,
        SelectValueExpr::Binary { left, right, .. } => {
            value_expr_has_aggregate(left) || value_expr_has_aggregate(right)
        }
        SelectValueExpr::Column(_) | SelectValueExpr::Number(_) => false,
    }
}
/// Apply WHERE expression to dataframe and return filtered frame.
fn apply_filter(df: &DataFrame, expr: &Expr) -> Result<DataFrame, String> {
    let nrows = df.nrows();
    let data = df.raw_data();
    let cols = df.columns();
    let mut keep = Vec::new();
    for row in 0..nrows {
        if eval_expr(expr, cols, data, row)? {
            keep.push(row);
        }
    }
    let new_data: Vec<Vec<CellValue>> = (0..df.ncols())
        .map(|ci| keep.iter().map(|&row| data[ci][row].clone()).collect())
        .collect();
    Ok(DataFrame::from_raw(cols.to_vec(), new_data))
}
/// Evaluate expression tree for one row and return boolean result.
fn eval_expr(
    expr: &Expr,
    cols: &[String],
    data: &[Vec<CellValue>],
    row: usize,
) -> Result<bool, String> {
    match expr {
        Expr::Compare(col, op, val) => {
            let ci = find_col(cols, col)?;
            let cell = &data[ci][row];
            let result = match op.as_str() {
                "==" => cell == val,
                "!=" => cell != val,
                "<" => cell.cmp_for_sort(val) == std::cmp::Ordering::Less,
                "<=" => {
                    let ord = cell.cmp_for_sort(val);
                    ord == std::cmp::Ordering::Less || ord == std::cmp::Ordering::Equal
                }
                ">" => cell.cmp_for_sort(val) == std::cmp::Ordering::Greater,
                ">=" => {
                    let ord = cell.cmp_for_sort(val);
                    ord == std::cmp::Ordering::Greater || ord == std::cmp::Ordering::Equal
                }
                _ => return Err(format!("unsupported SQL operator: {op}")),
            };
            Ok(result)
        }
        Expr::Like(col, pattern) => {
            let ci = find_col(cols, col)?;
            let cell = &data[ci][row];
            if let CellValue::Text(s) = cell {
                Ok(sql_like_match(s, pattern))
            } else {
                Ok(false)
            }
        }
        Expr::In(col, vals) => {
            let ci = find_col(cols, col)?;
            let cell = &data[ci][row];
            Ok(vals.contains(cell))
        }
        Expr::Not(inner) => Ok(!eval_expr(inner, cols, data, row)?),
        Expr::And(a, b) => Ok(eval_expr(a, cols, data, row)? && eval_expr(b, cols, data, row)?),
        Expr::Or(a, b) => Ok(eval_expr(a, cols, data, row)? || eval_expr(b, cols, data, row)?),
    }
}
/// Resolve column name to zero-based index.
fn find_col(cols: &[String], name: &str) -> Result<usize, String> {
    cols.iter()
        .position(|n| n == name)
        .ok_or_else(|| format!("column not found: {name}"))
}
/// Match text against SQL LIKE pattern with `%` and `_` wildcards.
fn sql_like_match(s: &str, pattern: &str) -> bool {
    let s_chars: Vec<char> = s.chars().collect();
    let p_chars: Vec<char> = pattern.chars().collect();
    like_match_dp(&s_chars, &p_chars)
}
/// Run dynamic-programming matcher for LIKE pattern over char arrays.
fn like_match_dp(s: &[char], p: &[char]) -> bool {
    let sn = s.len();
    let pn = p.len();
    let mut dp = vec![vec![false; pn + 1]; sn + 1];
    dp[0][0] = true;
    for j in 1..=pn {
        if p[j - 1] == '%' {
            dp[0][j] = dp[0][j - 1];
        } else {
            break;
        }
    }
    for i in 1..=sn {
        for j in 1..=pn {
            let pc = p[j - 1];
            if pc == '%' {
                dp[i][j] = dp[i][j - 1] || dp[i - 1][j];
            } else if pc == '_' || pc.to_lowercase().eq(s[i - 1].to_lowercase()) {
                dp[i][j] = dp[i - 1][j - 1];
            }
        }
    }
    dp[sn][pn]
}
/// Execute projection-only select list without grouping or aggregates.
fn execute_column_select(df: &DataFrame, columns: &[SelectExpr]) -> Result<DataFrame, String> {
    let row_count = df.nrows();
    let mut result_col_names: Vec<String> = Vec::new();
    let mut result_data: Vec<Vec<CellValue>> = Vec::new();
    for expr in columns {
        match expr {
            SelectExpr::Star => {
                for (column_name, column_data) in df.columns().iter().zip(df.raw_data().iter()) {
                    result_col_names.push(column_name.clone());
                    result_data.push(column_data.clone());
                }
            }
            SelectExpr::Value { expr, alias } => {
                result_col_names.push(select_value_output_name(expr, alias.as_deref()));
                let mut column_values = Vec::with_capacity(row_count);
                for row_index in 0..row_count {
                    column_values.push(eval_value_expr_for_row(df, expr, row_index)?);
                }
                result_data.push(column_values);
            }
        }
    }
    Ok(DataFrame::from_raw(result_col_names, result_data))
}
/// Execute grouped SELECT list and optional HAVING expression.
fn execute_group_by(
    df: &DataFrame,
    group_col: &str,
    select_exprs: &[SelectExpr],
    having: Option<&Expr>,
) -> Result<DataFrame, String> {
    let groups = df.group_by(ColRef::Name(group_col.to_string()))?;
    let mut result_col_names: Vec<String> = Vec::new();
    for expr in select_exprs {
        match expr {
            SelectExpr::Star => {
                result_col_names.push(group_col.to_string());
            }
            SelectExpr::Value { expr, alias } => {
                result_col_names.push(select_value_output_name(expr, alias.as_deref()));
            }
        }
    }
    let ncols = result_col_names.len();
    let mut result_data: Vec<Vec<CellValue>> = vec![Vec::new(); ncols];
    for (key, sub_df) in &groups {
        let mut row_vals: Vec<CellValue> = Vec::with_capacity(ncols);
        for expr in select_exprs {
            match expr {
                SelectExpr::Star => {
                    row_vals.push(key.clone());
                }
                SelectExpr::Value { expr, .. } => {
                    row_vals.push(eval_value_expr_for_summary(sub_df, expr)?);
                }
            }
        }
        if let Some(having_expr) = having {
            let temp = DataFrame::from_raw(
                result_col_names.clone(),
                row_vals.iter().map(|v| vec![v.clone()]).collect(),
            );
            if !eval_expr(having_expr, temp.columns(), temp.raw_data(), 0)? {
                continue;
            }
        }
        for (ci, val) in row_vals.into_iter().enumerate() {
            result_data[ci].push(val);
        }
    }
    Ok(DataFrame::from_raw(result_col_names, result_data))
}
/// Execute aggregate SELECT list without GROUP BY and return single-row frame.
fn execute_aggregate_no_group(
    df: &DataFrame,
    select_exprs: &[SelectExpr],
) -> Result<DataFrame, String> {
    let mut col_names = Vec::new();
    let mut values = Vec::new();
    for expr in select_exprs {
        match expr {
            SelectExpr::Star => {
                return Err("cannot use * with aggregate functions without GROUP BY".to_string());
            }
            SelectExpr::Value { expr, alias } => {
                col_names.push(select_value_output_name(expr, alias.as_deref()));
                values.push(eval_value_expr_for_summary(df, expr)?);
            }
        }
    }
    Ok(DataFrame::from_raw(
        col_names,
        values.into_iter().map(|v| vec![v]).collect(),
    ))
}
/// Build output column name from explicit alias or expression label.
fn select_value_output_name(expr: &SelectValueExpr, alias: Option<&str>) -> String {
    alias
        .map(ToString::to_string)
        .unwrap_or_else(|| select_value_expr_name(expr))
}
/// Build default output column label for SELECT value expression.
fn select_value_expr_name(expr: &SelectValueExpr) -> String {
    match expr {
        SelectValueExpr::Column(name) => name.clone(),
        SelectValueExpr::Number(number) => number.to_string(),
        SelectValueExpr::Aggregate(func, arg) => agg_col_name(func, arg),
        SelectValueExpr::Binary { left, op, right } => format!(
            "{} {} {}",
            select_value_expr_name(left),
            op.symbol(),
            select_value_expr_name(right)
        ),
    }
}
/// Evaluate SELECT value expression for one source row.
fn eval_value_expr_for_row(
    df: &DataFrame,
    expr: &SelectValueExpr,
    row_index: usize,
) -> Result<CellValue, String> {
    match expr {
        SelectValueExpr::Column(name) => df.get_value(row_index, ColRef::Name(name.clone())),
        SelectValueExpr::Number(number) => Ok(CellValue::Number(*number)),
        SelectValueExpr::Aggregate(_, _) => {
            Err("unexpected aggregate in non-grouped SELECT".to_string())
        }
        SelectValueExpr::Binary { left, op, right } => {
            let left_value = eval_value_expr_for_row(df, left, row_index)?;
            let right_value = eval_value_expr_for_row(df, right, row_index)?;
            Ok(eval_arithmetic_cells(&left_value, *op, &right_value))
        }
    }
}
/// Evaluate SELECT value expression over a grouped or aggregate dataframe slice.
fn eval_value_expr_for_summary(
    df: &DataFrame,
    expr: &SelectValueExpr,
) -> Result<CellValue, String> {
    match expr {
        SelectValueExpr::Column(name) => {
            if df.nrows() == 0 {
                Ok(CellValue::Nil)
            } else {
                Ok(df
                    .get_value(0, ColRef::Name(name.clone()))
                    .unwrap_or(CellValue::Nil))
            }
        }
        SelectValueExpr::Number(number) => Ok(CellValue::Number(*number)),
        SelectValueExpr::Aggregate(func, arg) => compute_aggregate(df, func, arg),
        SelectValueExpr::Binary { left, op, right } => {
            let left_value = eval_value_expr_for_summary(df, left)?;
            let right_value = eval_value_expr_for_summary(df, right)?;
            Ok(eval_arithmetic_cells(&left_value, *op, &right_value))
        }
    }
}
/// Evaluate arithmetic cells; non-numeric values and division by zero produce Nil.
fn eval_arithmetic_cells(
    left_value: &CellValue,
    op: ArithmeticOp,
    right_value: &CellValue,
) -> CellValue {
    let Some(left_number) = left_value.as_number() else {
        return CellValue::Nil;
    };
    let Some(right_number) = right_value.as_number() else {
        return CellValue::Nil;
    };
    let result = match op {
        ArithmeticOp::Add => left_number + right_number,
        ArithmeticOp::Sub => left_number - right_number,
        ArithmeticOp::Mul => left_number * right_number,
        ArithmeticOp::Div => {
            if right_number == 0.0 {
                return CellValue::Nil;
            }
            left_number / right_number
        }
    };
    if result.is_finite() {
        CellValue::Number(result)
    } else {
        CellValue::Nil
    }
}
/// Compute one aggregate value for selected dataframe slice.
fn compute_aggregate(df: &DataFrame, func: &AggFunc, arg: &AggArg) -> Result<CellValue, String> {
    match func {
        AggFunc::Count => match arg {
            AggArg::Star => Ok(CellValue::Number(df.nrows() as f64)),
            AggArg::Column(col) => {
                let data = df.get_column(ColRef::Name(col.clone()))?;
                let count = data.iter().filter(|v| !v.is_nil()).count();
                Ok(CellValue::Number(count as f64))
            }
        },
        AggFunc::Sum => {
            let col = agg_col_ref(arg)?;
            match df.sum(ColRef::Name(col)) {
                Ok(s) => Ok(CellValue::Number(s)),
                Err(_) => Ok(CellValue::Nil),
            }
        }
        AggFunc::Avg => {
            let col = agg_col_ref(arg)?;
            match df.mean(ColRef::Name(col)) {
                Ok(m) => Ok(CellValue::Number(m)),
                Err(_) => Ok(CellValue::Nil),
            }
        }
        AggFunc::Min => {
            let col = agg_col_ref(arg)?;
            match df.min_val(ColRef::Name(col)) {
                Ok(m) => Ok(CellValue::Number(m)),
                Err(_) => Ok(CellValue::Nil),
            }
        }
        AggFunc::Max => {
            let col = agg_col_ref(arg)?;
            match df.max_val(ColRef::Name(col)) {
                Ok(m) => Ok(CellValue::Number(m)),
                Err(_) => Ok(CellValue::Nil),
            }
        }
    }
}
/// Return aggregate column argument name or error for `*` argument.
fn agg_col_ref(arg: &AggArg) -> Result<String, String> {
    match arg {
        AggArg::Column(col) => Ok(col.clone()),
        AggArg::Star => Err("aggregate function requires a column name, not *".to_string()),
    }
}
/// Build default output column label for aggregate expression.
fn agg_col_name(func: &AggFunc, arg: &AggArg) -> String {
    let func_name = match func {
        AggFunc::Count => "COUNT",
        AggFunc::Sum => "SUM",
        AggFunc::Avg => "AVG",
        AggFunc::Min => "MIN",
        AggFunc::Max => "MAX",
    };
    let arg_name = match arg {
        AggArg::Star => "*".to_string(),
        AggArg::Column(col) => col.clone(),
    };
    format!("{func_name}({arg_name})")
}
