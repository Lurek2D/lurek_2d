import unittest
import subprocess
import os
import sys
import json

class TestValidateRustSourceDocs(unittest.TestCase):
    def setUp(self):
        # Paths relative to the repository root
        self.root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        self.tool_path = os.path.join(self.root_dir, 'tools', 'validate', 'validate_rust_source_docs.py')
        self.dummy_src = os.path.join(self.root_dir, 'tools', 'tests', 'dummy_data', 'src')
        self.dummy_root = os.path.join(self.root_dir, 'tools', 'tests', 'dummy_data')
        self.python_exe = sys.executable

    def run_tool(self, tool_path, *args, cwd=None):
        cmd = [self.python_exe, tool_path] + list(args)
        _cwd = cwd if cwd else self.root_dir
        result = subprocess.run(cmd, cwd=_cwd, capture_output=True, text=True)
        return result

    def test_validate_rust_source_docs(self):
        good_file = os.path.join(self.dummy_src, 'good.rs')
        res = self.run_tool(self.tool_path, '--format', 'json', good_file)
        self.assertEqual(res.returncode, 0)
        output = json.loads(res.stdout)
        self.assertTrue(output['ok'])

    def test_validate_changelog(self):
        tool = os.path.join(self.root_dir, 'tools', 'validate', 'validate_changelog.py')
        res = self.run_tool(tool, cwd=self.dummy_root)
        self.assertEqual(res.returncode, 0, f"Changelog validate failed: {res.stdout} {res.stderr}")

    def test_bad_no_header(self):
        bad_file = os.path.join(self.dummy_src, 'bad_no_header.rs')
        res = self.run_tool(self.tool_path, '--format', 'json', bad_file)
        self.assertEqual(res.returncode, 1)
        output = json.loads(res.stdout)
        self.assertFalse(output['ok'])
        self.assertTrue(any(f['kind'] == 'missing-file-doc' for f in output['findings']))

    def test_bad_short_summary(self):
        bad_file = os.path.join(self.dummy_src, 'bad_short_summary.rs')
        res = self.run_tool(self.tool_path, '--format', 'json', bad_file)
        self.assertEqual(res.returncode, 1)
        output = json.loads(res.stdout)
        self.assertFalse(output['ok'])
        self.assertTrue(any(f['kind'] == 'short-item-doc' for f in output['findings']))

    def test_bad_no_summary(self):
        bad_file = os.path.join(self.dummy_src, 'bad_no_summary.rs')
        res = self.run_tool(self.tool_path, '--format', 'json', bad_file)
        self.assertEqual(res.returncode, 1)
        output = json.loads(res.stdout)
        self.assertFalse(output['ok'])
        self.assertTrue(any(f['kind'] == 'missing-item-doc' for f in output['findings']))

if __name__ == '__main__':
    unittest.main()
