import sqlite3
c = sqlite3.connect('tools/rag/rag_index.db')
print("Total rows:", c.execute("SELECT count(1) FROM documents").fetchone()[0])
print("API rows:", c.execute("SELECT count(1) FROM documents WHERE type='api'").fetchone()[0])
r = c.execute("SELECT id, title FROM documents WHERE type='api' AND title LIKE '%rectangle%'").fetchall()
print("Matches:", len(r))
if r:
    print(r[0])
