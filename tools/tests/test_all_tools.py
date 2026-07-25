import unittest
import glob
import os
import sys
import subprocess
import ast

# Only execute help for commands whose CLI contract is intentionally kept
# side-effect free.  Many tools are generators or fixers, and historically a
# blanket ``<tool> --help`` smoke test executed their default write path.
# Add a tool here only after verifying that argument parsing occurs before any
# filesystem, process, or network side effect.
HELP_SAFE_PATHS = {
    'audit/cag_link_check.py',
    'audit/tool_registry_audit.py',
    'rag/context.py',
    'rag/eval.py',
    'rag/query.py',
    'rag/read.py',
    'validate/cag_validate.py',
}

class DynamicToolTest(unittest.TestCase):
    pass

def make_docstring_test(filepath):
    def test(self):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        try:
            tree = ast.parse(content)
            docstring = ast.get_docstring(tree)
            self.assertIsNotNone(docstring, f"Missing docstring in {filepath}")
            self.assertGreater(len(docstring.strip()), 0, f"Empty docstring in {filepath}")
        except SyntaxError:
            self.fail(f"Syntax error in {filepath}")
    return test

def make_help_test(filepath, root_dir):
    def test(self):
        # This smoke test is deliberately allowlisted.  It must never execute
        # a generator, fixer, packager, or other mutating command merely to
        # discover whether ``--help`` exists.
        cmd = [sys.executable, filepath, '--help']
        env = os.environ.copy()
        env['PYTHONIOENCODING'] = 'utf-8'
        res = subprocess.run(cmd, cwd=root_dir, env=env, capture_output=True, text=True, errors='replace')
        
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            success = res.returncode == 0 and (
                'usage:' in res.stdout.lower()
                or 'usage:' in res.stderr.lower()
            )
            self.assertTrue(success, f"Tool {filepath} failed on --help. Stdout: {res.stdout} Stderr: {res.stderr}")
    return test

def _inject_tests():
    root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    tools_dir = os.path.join(root_dir, 'tools')
    py_files = glob.glob(os.path.join(tools_dir, '**', '*.py'), recursive=True)

    for filepath in py_files:
        # Ignore tests and python cache
        if 'tests' in filepath.replace('\\', '/') or '__pycache__' in filepath:
            continue
            
        rel_path = os.path.relpath(filepath, tools_dir).replace('\\', '_').replace('/', '_').replace('.', '_')
        
        # Inject docstring test
        setattr(DynamicToolTest, f'test_docstring_{rel_path}', make_docstring_test(filepath))
        
        tool_path = os.path.relpath(filepath, tools_dir).replace('\\', '/')
        if tool_path in HELP_SAFE_PATHS:
            setattr(DynamicToolTest, f'test_help_{rel_path}', make_help_test(filepath, root_dir))

_inject_tests()

if __name__ == '__main__':
    unittest.main()
