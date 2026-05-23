import glob
import os
import ast
from pathlib import Path

def generate_registry():
    root_dir = Path(__file__).resolve().parents[2]
    tools_dir = root_dir / 'tools'
    py_files = sorted(glob.glob(str(tools_dir / '**' / '*.py'), recursive=True))

    registry = []
    
    for filepath in py_files:
        if 'tests' in filepath.replace('\\', '/') or '__pycache__' in filepath:
            continue
            
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        try:
            tree = ast.parse(content)
            docstring = ast.get_docstring(tree)
            if not docstring:
                docstring = "Brak docstringu."
            
            # Get the first sentence of the docstring for summary
            summary = docstring.strip().split('\n')[0]
            
            rel_path = Path(filepath).relative_to(tools_dir).as_posix()
            registry.append({
                "path": rel_path,
                "summary": summary
            })
        except Exception:
            continue

    # Group by category (top level folder)
    categories = {}
    for item in registry:
        parts = item['path'].split('/')
        category = parts[0] if len(parts) > 1 else 'root'
        if category not in categories:
            categories[category] = []
        categories[category].append(item)

    # Write README.md
    readme_path = tools_dir / 'README.md'
    with open(readme_path, 'w', encoding='utf-8') as f:
        f.write("# Lurek2D Tools Registry (Auto-generated)\n\n")
        f.write("> [!NOTE]\n> Ten plik jest generowany automatycznie przez `tools/tests/gen_tool_registry.py`.\n\n")
        
        for category in sorted(categories.keys()):
            f.write(f"## {category}\n\n")
            for item in sorted(categories[category], key=lambda x: x['path']):
                f.write(f"- **`{item['path']}`**: {item['summary']}\n")
            f.write("\n")

    # Write agent_cli_reference.md
    agent_ref_path = tools_dir / 'agent_cli_reference.md'
    with open(agent_ref_path, 'w', encoding='utf-8') as f:
        f.write("# Agent CLI Reference (Auto-generated)\n\n")
        f.write("Pełna lista komend i opisów. Aby użyć narzędzia, uruchom `python tools/<sciezka> --help`.\n\n")
        
        for category in sorted(categories.keys()):
            f.write(f"### /{category}\n")
            for item in sorted(categories[category], key=lambda x: x['path']):
                f.write(f"- `{item['path']}` - {item['summary']}\n")
            f.write("\n")
            
    # Write individual README.md for each subfolder
    for category, items in categories.items():
        if category == 'root':
            continue
        folder_path = tools_dir / category
        if folder_path.is_dir():
            readme_path = folder_path / 'README.md'
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(f"# Lurek2D {category.capitalize()} Tools\n\n")
                f.write(f"> [!NOTE]\n> Ten plik jest generowany automatycznie przez `tools/tests/gen_tool_registry.py`.\n\n")
                for item in sorted(items, key=lambda x: x['path']):
                    filename = item['path'].split('/')[-1]
                    f.write(f"- **`{filename}`**: {item['summary']}\n")
            
    print(f"Generated registry with {len(registry)} tools.")

if __name__ == '__main__':
    generate_registry()
