"""
build_index.py — Builds the local SQLite FTS5 RAG index for Lurek2D documentation and code.
"""
import os
import sys
import json
import sqlite3
import re
import tomllib
from pathlib import Path

# Config
WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
DB_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag_index.db"
CONFIG_PATH = WORKSPACE_ROOT / "tools" / "rag" / "rag.toml"

with open(CONFIG_PATH, "rb") as f:
    config = tomllib.load(f)

MAX_CHUNK_SIZE = config.get("indexing", {}).get("max_chunk_size", 1500)
ALLOWED_EXTENSIONS = set(config.get("indexing", {}).get("allowed_extensions", [".md", ".lua", ".rs"]))
DEFAULT_TARGET_DIRS = config.get("indexing", {}).get("default_target_dirs", [".github", "content", "docs", "library", "src", "tests"])

def init_db(db_path):
    conn = sqlite3.connect(db_path)
    # Don't drop table if it exists, only create if not exists
    conn.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS documents USING fts5(
            id UNINDEXED,
            path,
            type UNINDEXED,
            title,
            content
        );
    """)
    return conn

def chunk_markdown(content):
    """Chunk markdown by headings."""
    chunks = []
    current_title = "Document Start"
    current_lines = []
    
    for line in content.splitlines():
        match = re.match(r'^(#{1,4})\s+(.*)', line)
        if match:
            if any(l.strip() for l in current_lines):
                chunks.append((current_title, "\n".join(current_lines)))
            current_title = match.group(2)
            current_lines = [line]
        else:
            current_lines.append(line)
            
    if any(l.strip() for l in current_lines):
        chunks.append((current_title, "\n".join(current_lines)))
        
    refined_chunks = []
    for title, text in chunks:
        if len(text) > MAX_CHUNK_SIZE * 2:
            lines = text.split('\n')
            for i in range(0, len(lines), 50):
                chunk_text = "\n".join(lines[i:i+60])
                refined_chunks.append((f"{title} (Part {i//50 + 1})", chunk_text))
        else:
            refined_chunks.append((title, text))
            
    return refined_chunks

def chunk_code(content):
    """Chunk code by blank lines, grouping them to roughly MAX_CHUNK_SIZE characters."""
    chunks = []
    paragraphs = content.split('\n\n')
    
    current_chunk = []
    current_len = 0
    chunk_idx = 1
    
    for p in paragraphs:
        current_chunk.append(p)
        current_len += len(p)
        
        if current_len > MAX_CHUNK_SIZE:
            chunks.append((f"Chunk {chunk_idx}", "\n\n".join(current_chunk)))
            current_chunk = []
            current_len = 0
            chunk_idx += 1
            
    if current_chunk:
        chunks.append((f"Chunk {chunk_idx}", "\n\n".join(current_chunk)))
        
    return chunks

def index_lua_api_data(cursor):
    """Index highly structured API definitions from lua_api_data.json."""
    api_data_path = WORKSPACE_ROOT / "logs" / "data" / "lua_api_data.json"
    if not api_data_path.exists():
        return 0
        
    # Clear existing API chunks
    cursor.execute("DELETE FROM documents WHERE path = 'API'")
        
    indexed_chunks = 0
    try:
        with open(api_data_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            
        modules = data.get("lua_api", {}).get("modules", {})
        for mod_name, mod_data in modules.items():
            funcs = mod_data.get("functions", [])
            for fn in funcs:
                lua_name = fn.get("lua_name", "")
                kind = fn.get("kind", "function")
                desc = fn.get("description", "")
                full_doc = fn.get("full_doc", "")
                
                content = f"{desc}\n\n{full_doc}"
                title = f"API: {lua_name} ({kind})"
                chunk_id = f"API#{lua_name}"
                
                cursor.execute("""
                    INSERT INTO documents (id, path, type, title, content)
                    VALUES (?, ?, ?, ?, ?)
                """, (chunk_id, "API", "api", title, content))
                indexed_chunks += 1
                
    except Exception as e:
        print(f"Warning: Failed to parse lua_api_data.json: {e}")
        
    return indexed_chunks

def process_single_file(cursor, file_path):
    if file_path.suffix not in ALLOWED_EXTENSIONS:
        return 0
        
    rel_path = file_path.relative_to(WORKSPACE_ROOT).as_posix()
    
    # Remove existing chunks for this file
    cursor.execute("DELETE FROM documents WHERE path = ?", (rel_path,))
    
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
    except UnicodeDecodeError:
        return 0
        
    if not content.strip():
        return 0
        
    file_type = file_path.suffix.lstrip('.')
    
    if file_type == 'md':
        chunks = chunk_markdown(content)
    else:
        chunks = chunk_code(content)
        
    for idx, (title, chunk_content) in enumerate(chunks):
        chunk_id = f"{rel_path}#{idx}"
        if file_type != 'md':
            title = f"{file_path.name} - {title}"
            
        cursor.execute("""
            INSERT INTO documents (id, path, type, title, content)
            VALUES (?, ?, ?, ?, ?)
        """, (chunk_id, rel_path, file_type, title, chunk_content))
        
    return len(chunks)

def build_index(targets=None, db_path_override=None):
    active_db = db_path_override if db_path_override else DB_PATH
    print(f"Building RAG index at: {active_db}")
    active_db.parent.mkdir(parents=True, exist_ok=True)
    
    conn = init_db(active_db)
    cursor = conn.cursor()
    
    indexed_files = 0
    indexed_chunks = 0
    
    # If no targets specified, do a full rebuild
    if not targets:
        # Full rebuild: Clear DB entirely
        cursor.execute("DELETE FROM documents")
        targets = DEFAULT_TARGET_DIRS
        
    if "docs" in targets or not targets:
        api_chunks = index_lua_api_data(cursor)
        indexed_chunks += api_chunks
        print(f"Indexed {api_chunks} API functions from lua_api_data.json")
    
    for target in targets:
        target_path = WORKSPACE_ROOT / target
        if not target_path.exists():
            print(f"Skipping {target}, does not exist.")
            continue
            
        if target_path.is_file():
            # Single file auto-indexing
            chunks_added = process_single_file(cursor, target_path)
            if chunks_added > 0:
                indexed_files += 1
                indexed_chunks += chunks_added
        else:
            # Directory indexing
            # For a directory rebuild, we clear all paths that start with this dir
            dir_prefix = target_path.relative_to(WORKSPACE_ROOT).as_posix() + "/%"
            cursor.execute("DELETE FROM documents WHERE path LIKE ?", (dir_prefix,))
            
            for root, _, files in os.walk(target_path):
                for file in files:
                    file_path = Path(root) / file
                    chunks_added = process_single_file(cursor, file_path)
                    if chunks_added > 0:
                        indexed_files += 1
                        indexed_chunks += chunks_added
                
    conn.commit()
    conn.close()
    print(f"Index built successfully! Indexed/Updated {indexed_files} files into {indexed_chunks} chunks.")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Build Lurek2D RAG index")
    parser.add_argument("targets", nargs="*", help="Specific directories or files to index (e.g. content docs src/main.rs)")
    parser.add_argument("--db", help="Override DB path (for testing)")
    args = parser.parse_args()
    
    db_override = Path(args.db) if args.db else None
    build_index(args.targets, db_override)
