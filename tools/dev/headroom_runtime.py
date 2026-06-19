#!/usr/bin/env python3
"""
Manage a repo-local Headroom runtime for Codex and MCP workflows.

This tool keeps the optional Headroom install under `work/headroom/` so the
repository stays clean and the integration remains local to this workspace.

Examples:
    tools/python.cmd tools/dev/headroom_runtime.py install
    tools/python.cmd tools/dev/headroom_runtime.py status
    tools/python.cmd tools/dev/headroom_runtime.py wrap-codex
    tools/python.cmd tools/dev/headroom_runtime.py wrap-codex -- --model gpt-5-codex
    tools/python.cmd tools/dev/headroom_runtime.py proxy --port 8787
    tools/python.cmd tools/dev/headroom_runtime.py mcp-serve
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
WORK_DIR = ROOT / "work" / "headroom"
VENV_DIR = WORK_DIR / ".venv"


def venv_python() -> Path:
    """Return the venv Python path for the current platform."""
    if os.name == "nt":
        return VENV_DIR / "Scripts" / "python.exe"
    return VENV_DIR / "bin" / "python"


def headroom_exe() -> Path:
    """Return the Headroom CLI path inside the local venv."""
    if os.name == "nt":
        return VENV_DIR / "Scripts" / "headroom.exe"
    return VENV_DIR / "bin" / "headroom"


def runtime_exists() -> bool:
    """Report whether the local Headroom runtime is installed."""
    return venv_python().exists() and headroom_exe().exists()


def ensure_runtime_dirs() -> None:
    """Create the ignored workspace directory that holds the local runtime."""
    WORK_DIR.mkdir(parents=True, exist_ok=True)


def run_command(command: list[str], env: dict[str, str] | None = None) -> int:
    """Run a command and stream stdio directly to the console."""
    completed = subprocess.run(command, cwd=ROOT, env=env)
    return completed.returncode


def require_runtime() -> None:
    """Exit with an actionable message when Headroom is not installed yet."""
    if runtime_exists():
        return
    print(
        "Headroom is not installed for this workspace.\n"
        "Run `tools/python.cmd tools/dev/headroom_runtime.py install` first.",
        file=sys.stderr,
    )
    raise SystemExit(2)


def install_runtime(args: argparse.Namespace) -> int:
    """Create a workspace-local venv and install Headroom into it."""
    ensure_runtime_dirs()
    python_path = venv_python()

    if not python_path.exists():
        bootstrap_python = args.bootstrap_python or sys.executable
        print(f"Creating virtual environment at {VENV_DIR}")
        code = run_command([bootstrap_python, "-m", "venv", str(VENV_DIR)])
        if code != 0:
            return code

    package = "headroom-ai"
    if args.extras:
        package = f'headroom-ai[{args.extras}]'

    pip_command = [str(python_path), "-m", "pip", "install", "--upgrade", "pip"]
    print("Upgrading pip in the local Headroom runtime")
    code = run_command(pip_command)
    if code != 0:
        return code

    install_command = [str(python_path), "-m", "pip", "install"]
    if args.upgrade:
        install_command.append("--upgrade")
    install_command.append(package)
    install_env = os.environ.copy()
    if sys.version_info >= (3, 14):
        install_env.setdefault("PYO3_USE_ABI3_FORWARD_COMPATIBILITY", "1")
    print(f"Installing {package} into {VENV_DIR}")
    code = run_command(install_command, env=install_env)
    if code != 0:
        return code
    if not runtime_exists():
        print(
            "Headroom install completed without creating the `headroom` executable.",
            file=sys.stderr,
        )
        return 1
    return 0


def runtime_env(args: argparse.Namespace) -> dict[str, str]:
    """Build the environment used for Headroom-powered Codex sessions."""
    env = os.environ.copy()
    if getattr(args, "output_shaper", False):
        env["HEADROOM_OUTPUT_SHAPER"] = "1"
    if getattr(args, "output_holdout", None) is not None:
        env["HEADROOM_OUTPUT_HOLDOUT"] = str(args.output_holdout)
    return env


def wrap_codex(args: argparse.Namespace) -> int:
    """Launch Codex through `headroom wrap codex`."""
    require_runtime()
    command = [str(headroom_exe()), "wrap", "codex"]
    if args.codex_args:
        command.extend(["--", *args.codex_args])
    return run_command(command, env=runtime_env(args))


def run_proxy(args: argparse.Namespace) -> int:
    """Start the local Headroom proxy for OpenAI-compatible clients."""
    require_runtime()
    command = [str(headroom_exe()), "proxy", "--port", str(args.port)]
    return run_command(command, env=runtime_env(args))


def serve_mcp(args: argparse.Namespace) -> int:
    """Serve Headroom's MCP tools from the repo-local runtime."""
    del args
    require_runtime()
    command = [str(headroom_exe()), "mcp", "serve"]
    return run_command(command)


def show_status(args: argparse.Namespace) -> int:
    """Print the current workspace-local Headroom status."""
    del args
    print(f"Workspace root: {ROOT}")
    print(f"Runtime dir: {WORK_DIR}")
    print(f"Virtualenv: {VENV_DIR}")
    print(f"Installed: {'yes' if runtime_exists() else 'no'}")
    if runtime_exists():
        return run_command([str(headroom_exe()), "--version"])
    return 0


def build_parser() -> argparse.ArgumentParser:
    """Build the CLI parser for the repo-local Headroom manager."""
    parser = argparse.ArgumentParser(
        description="Manage a repo-local Headroom runtime for Codex workflows.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    install_parser = subparsers.add_parser(
        "install",
        help="Create the local runtime under work/headroom and install Headroom.",
    )
    install_parser.add_argument(
        "--extras",
        default="all",
        help="Headroom extras to install (default: all). Use empty string for core only.",
    )
    install_parser.add_argument(
        "--upgrade",
        action="store_true",
        help="Upgrade an existing local Headroom install.",
    )
    install_parser.add_argument(
        "--bootstrap-python",
        default=None,
        help="Optional interpreter used to create the venv, for example a Python 3.13 path.",
    )
    install_parser.set_defaults(func=install_runtime)

    status_parser = subparsers.add_parser(
        "status",
        help="Show where the local Headroom runtime lives and whether it is installed.",
    )
    status_parser.set_defaults(func=show_status)

    wrap_parser = subparsers.add_parser(
        "wrap-codex",
        help="Launch Codex through Headroom with output shaping enabled by default.",
    )
    wrap_parser.add_argument(
        "--output-shaper",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Enable or disable HEADROOM_OUTPUT_SHAPER (default: enabled).",
    )
    wrap_parser.add_argument(
        "--output-holdout",
        type=float,
        default=None,
        help="Optional HEADROOM_OUTPUT_HOLDOUT fraction, for example 0.1.",
    )
    wrap_parser.add_argument(
        "codex_args",
        nargs=argparse.REMAINDER,
        help="Arguments passed through to `codex` after `--`.",
    )
    wrap_parser.set_defaults(func=wrap_codex)

    proxy_parser = subparsers.add_parser(
        "proxy",
        help="Start Headroom proxy from the repo-local runtime.",
    )
    proxy_parser.add_argument(
        "--port",
        type=int,
        default=8787,
        help="Proxy port to bind (default: 8787).",
    )
    proxy_parser.add_argument(
        "--output-shaper",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Enable or disable HEADROOM_OUTPUT_SHAPER (default: enabled).",
    )
    proxy_parser.add_argument(
        "--output-holdout",
        type=float,
        default=None,
        help="Optional HEADROOM_OUTPUT_HOLDOUT fraction, for example 0.1.",
    )
    proxy_parser.set_defaults(func=run_proxy)

    mcp_parser = subparsers.add_parser(
        "mcp-serve",
        help="Serve Headroom MCP tools from the repo-local runtime.",
    )
    mcp_parser.set_defaults(func=serve_mcp)

    return parser


def main() -> int:
    """CLI entrypoint."""
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
