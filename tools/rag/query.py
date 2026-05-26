"""
query.py — Queries the local SQLite FTS5 RAG index for Lurek2D API examples and usage.
"""
import sys
import json
import sqlite3
import argparse
import tomllib
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
DB_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag_index.db"
CONFIG_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag.toml"

with open(CONFIG_PATH, "rb") as f:
    config = tomllib.load(f)

BM25_WEIGHTS = config.get("search", {}).get("bm25_weights", [1.0, 10.0, 1.0])

def search_index(query, profile="all", limit=10, db_path_override=None):
    active_db = db_path_override if db_path_override else DB_PATH
    if not active_db.exists():
        return {"error": "RAG index not found. Please run tools/rag/build_index.py first."}
        
    conn = sqlite3.connect(active_db)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    import re
    safe_query = re.sub(r'[^a-zA-Z0-9\s]', ' ', query).strip()
    
    if not safe_query:
        return {"query": query, "results": []}
        
    try:
        # Construct the BM25 string based on config array
        weight_str = ", ".join(str(w) for w in BM25_WEIGHTS)
        
        # Base query
        sql_select = f"""
            SELECT 
                id, 
                path, 
                type, 
                title, 
                snippet(documents, 4, '[[', ']]', '...', 64) as context,
                bm25(documents, {weight_str}) as rank
            FROM documents 
            WHERE documents MATCH ? 
        """
        
        # Profile filtering
        if profile == "game":
            sql_select += " AND (type = 'api' OR path LIKE 'content/%' OR path LIKE 'docs/%' OR path LIKE 'library/%') "
        elif profile == "engine":
            sql_select += " AND (path LIKE 'src/%' OR path LIKE 'tests/%' OR path LIKE '.github/%' OR path LIKE 'tools/%') "
            
        sql_select += " ORDER BY (type = 'api') DESC, rank LIMIT ?"
        
        cursor.execute(sql_select, (safe_query, limit))
        results = cursor.fetchall()
        
        output = []
        for row in results:
            output.append({
                "id": row["id"],
                "path": row["path"],
                "type": row["type"],
                "title": row["title"],
                "context": row["context"]
            })
            
        return {"query": query, "profile": profile, "results": output}
        
    except sqlite3.OperationalError as e:
        return {"error": f"Search syntax error: {str(e)}"}
    finally:
        conn.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Query Lurek2D RAG index")
    parser.add_argument("query", help="Search query keywords")
    parser.add_argument("--profile", choices=["all", "game", "engine"], default="all", help="Filter profile")
    parser.add_argument("--limit", type=int, default=10, help="Max results")
    parser.add_argument("--db", help="Override DB path (for testing)")
    args = parser.parse_args()
    
    db_override = Path(args.db) if args.db else None
    res = search_index(args.query, args.profile, args.limit, db_override)
    print(json.dumps(res, indent=2))
