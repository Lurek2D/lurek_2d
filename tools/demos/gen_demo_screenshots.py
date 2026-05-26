#!/usr/bin/env python3
"""
gen_demo_screenshots.py — Capture a screen.png for every Lurek2D game demo.

Scans ``content/games/<category>/<name>/`` for any folder containing ``main.lua``
and launches the engine binary in screenshot mode.  Up to ``--workers`` (default 6)
games are captured in parallel, each window placed in its own grid slot so they
do not overlap on the desktop.

Usage:
    python tools/demos/gen_demo_screenshots.py [options]

Options:
    --binary PATH            Path to the lurek2d binary (auto-detects build/release or build/debug)
    --games-dir PATH         Root games directory (default: content/games/)
    --screenshot-time SECS   Wall-clock seconds after game start before capture (default: 3.0)
    --workers N              Parallel capture slots (default: 6)
    --slot-width PX          Slot width in pixels used for window positioning only (default: auto from monitor width)
    --slot-height PX         Slot height in pixels used for window positioning only (default: auto from monitor height)
    --force-window-size      Force each demo window to slot size (default: keep demo native resolution)
    --start-signal MODE      Startup key simulation mode: auto|off (default: off)
    --start-keys CSV         Keys to send at startup (default: enter,space,1,2,3)
    --start-signal-duration SECS
                            Seconds to keep sending startup keys after launch (default: 2.5)
    --start-signal-interval SECS
                            Delay between startup key sends (default: 0.12)
    --demo NAME              Only capture this named demo; can repeat
    --overwrite              Overwrite existing screen.png files (default: skip)
    --timeout SECS           Kill process if it has not exited within this many seconds (default: 30)
    --rebuild                Run 'cargo build --release' before capturing
    --dry-run                Print what would run; do not execute

Each demo is launched as:
    lurek2d <demo_dir> --screenshot=<abs_path> --screenshot-time=<t>
                       --window-x=<x> --window-y=<y>
                       [--window-width=<w> --window-height=<h>]

The engine waits ``screenshot_time`` wall-clock seconds, saves screen.png, and exits.
RUST_LOG=lurek2d=error is set to suppress verbose output during batch capture.

For each game folder this script writes:
    - ``screen.png`` (capture output)
"""

import argparse
import ctypes
import os
import platform
import queue
import subprocess
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent

# Grid layout: slots numbered left-to-right, top-to-bottom.
# slot_index -> (col, row), column count taken from --workers / 3 rounded up.
_GRID_COLS = 3
WM_KEYDOWN = 0x0100
WM_KEYUP = 0x0101

_START_KEY_MAP = {
    "enter": 0x0D,
    "space": 0x20,
    "tab": 0x09,
    "up": 0x26,
    "down": 0x28,
    "left": 0x25,
    "right": 0x27,
    "1": 0x31,
    "2": 0x32,
    "3": 0x33,
    "4": 0x34,
    "5": 0x35,
    "6": 0x36,
    "7": 0x37,
    "8": 0x38,
    "9": 0x39,
    "0": 0x30,
    "a": 0x41,
    "d": 0x44,
    "e": 0x45,
    "f": 0x46,
    "p": 0x50,
    "r": 0x52,
    "s": 0x53,
    "w": 0x57,
    "x": 0x58,
    "z": 0x5A,
}


def detect_primary_screen_size() -> tuple | None:
    """Best-effort primary display size as (width, height) in pixels."""
    if os.name == "nt":
        try:
            user32 = ctypes.windll.user32
            user32.SetProcessDPIAware()
            width = int(user32.GetSystemMetrics(0))
            height = int(user32.GetSystemMetrics(1))
            if width > 0 and height > 0:
                return width, height
        except Exception:
            pass

    # Cross-platform fallback (optional dependency in stdlib).
    try:
        import tkinter  # pylint: disable=import-outside-toplevel

        root = tkinter.Tk()
        root.withdraw()
        width = int(root.winfo_screenwidth())
        height = int(root.winfo_screenheight())
        root.destroy()
        if width > 0 and height > 0:
            return width, height
    except Exception:
        pass

    return None


def _slot_position(slot_index: int, slot_width: int, slot_height: int) -> tuple:
    """Return (x, y) screen position for the given 0-based slot index."""
    col = slot_index % _GRID_COLS
    row = slot_index // _GRID_COLS
    return col * slot_width, row * slot_height


def _parse_start_keys(csv: str) -> list:
    """Parse a comma-separated key list into virtual-key codes."""
    out = []
    for token in (csv or "").split(","):
        key = token.strip().lower()
        if not key:
            continue
        if key not in _START_KEY_MAP:
            raise ValueError("Unknown start key '{}'. Supported: {}".format(
                key, ", ".join(sorted(_START_KEY_MAP.keys()))
            ))
        out.append(_START_KEY_MAP[key])
    return out


def _find_window_for_pid(pid: int):
    """Return one top-level visible window handle for a process id (Windows only)."""
    if os.name != "nt":
        return None

    user32 = ctypes.windll.user32
    found = {"hwnd": None}

    @ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p)
    def enum_cb(hwnd, lparam):
        if not user32.IsWindowVisible(hwnd):
            return True
        proc_id = ctypes.c_ulong(0)
        user32.GetWindowThreadProcessId(hwnd, ctypes.byref(proc_id))
        if int(proc_id.value) == int(pid):
            found["hwnd"] = hwnd
            return False
        return True

    user32.EnumWindows(enum_cb, 0)
    return found["hwnd"]


def _send_start_signal_windows(pid: int, key_codes: list) -> bool:
    """Post synthetic keydown/keyup messages to the demo window (Windows only)."""
    if os.name != "nt" or not key_codes:
        return False
    hwnd = _find_window_for_pid(pid)
    if not hwnd:
        return False

    user32 = ctypes.windll.user32
    sent_any = False
    for vk in key_codes:
        # lParam is kept minimal here; games usually only need key state transitions.
        user32.PostMessageW(hwnd, WM_KEYDOWN, int(vk), 0)
        user32.PostMessageW(hwnd, WM_KEYUP, int(vk), 0)
        sent_any = True
    return sent_any


def find_binary(repo_root: Path) -> Path:
    """Auto-detect the lurek2d binary; prefers debug over release for stability."""
    ext = ".exe" if platform.system() == "Windows" else ""
    candidates = [
        repo_root / "build" / "debug"   / f"lurek2d{ext}",
        repo_root / "build" / "release" / f"lurek2d{ext}",
    ]
    for c in candidates:
        if c.exists():
            return c
    raise FileNotFoundError(
        "Could not find lurek2d binary. Build first with:\n"
        "  cargo build --release\n"
        "or pass --binary <path>."
    )


def rebuild(repo_root: Path) -> None:
    """Run a release build and abort on failure."""
    print("[build] cargo build --release ...")
    result = subprocess.run(["cargo", "build", "--release"], cwd=repo_root, timeout=600)
    if result.returncode != 0:
        print("[build] FAILED — aborting.", file=sys.stderr)
        sys.exit(1)
    print("[build] OK")


def discover_demos(games_root: Path, filter_names: list) -> list:
    """
    Walk ``games_root/<category>/<name>/`` and return a sorted list of demo
    directories that contain a ``main.lua``.

    If ``filter_names`` is non-empty only demos whose basename is in the set
    are returned.
    """
    demos = []
    if not games_root.is_dir():
        return demos
    for category_dir in sorted(games_root.iterdir()):
        if not category_dir.is_dir():
            continue
        for demo_dir in sorted(category_dir.iterdir()):
            if demo_dir.is_dir() and (demo_dir / "main.lua").exists():
                demos.append(demo_dir)

    if filter_names:
        wanted = set(filter_names)
        demos = [d for d in demos if d.name in wanted]
    return demos


def capture_demo(
    *,
    binary: Path,
    demo_dir: Path,
    screenshot_time: float,
    slot_index: int,
    slot_width: int,
    slot_height: int,
    timeout: float,
    force_window_size: bool,
    start_signal_mode: str,
    start_key_codes: list,
    start_signal_duration: float,
    start_signal_interval: float,
    overwrite: bool,
    dry_run: bool,
    log_dir,
    print_lock: threading.Lock,
    index: int,
    total: int,
) -> tuple:
    """
    Launch the engine for one demo and wait for it to capture screen.png.

    Returns ``(status, error_detail)`` where *status* is one of
    ``'ok'``, ``'skip'``, ``'timeout'``, or ``'error'``.
    """
    screen_path = demo_dir / "screen.png"
    label = demo_dir.name
    prefix = "[{:3d}/{}] {:<32}".format(index, total, label)

    if screen_path.exists() and not overwrite:
        with print_lock:
            print("{}  SKIP    (exists, use --overwrite)".format(prefix), flush=True)
        return "skip", ""

    wx, wy = _slot_position(slot_index, slot_width, slot_height)
    cmd = [
        str(binary),
        str(demo_dir.resolve()),
        "--screenshot="       + str(screen_path.resolve()),
        "--screenshot-time="  + str(screenshot_time),
        "--window-x="         + str(wx),
        "--window-y="         + str(wy),
    ]
    if force_window_size:
        cmd.extend([
            "--window-width=" + str(slot_width),
            "--window-height=" + str(slot_height),
        ])

    if dry_run:
        with print_lock:
            print("[dry-run] {}".format(" ".join(cmd)), flush=True)
        return "ok", ""

    env = {**os.environ, "RUST_LOG": "lurek2d=error"}

    t0 = time.monotonic()
    start_signal_attempts = 0
    start_signal_sent = 0
    start_signal_enabled = (start_signal_mode == "auto" and os.name == "nt" and bool(start_key_codes))
    try:
        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
        )
        next_signal_at = t0 + 0.35
        signal_deadline = t0 + max(0.0, start_signal_duration)

        while True:
            now = time.monotonic()
            if proc.poll() is not None:
                break
            if now - t0 > timeout:
                raise subprocess.TimeoutExpired(cmd, timeout)
            if start_signal_enabled and now >= next_signal_at and now <= signal_deadline:
                start_signal_attempts += 1
                if _send_start_signal_windows(proc.pid, start_key_codes):
                    start_signal_sent += 1
                next_signal_at = now + max(0.05, start_signal_interval)
            time.sleep(0.03)

        out, err = proc.communicate()
        class _Result:
            returncode = proc.returncode
            stdout = out
            stderr = err

        result = _Result()
    except subprocess.TimeoutExpired as exc:
        if "proc" in locals() and proc.poll() is None:
            proc.kill()
            out, err = proc.communicate()
            exc = subprocess.TimeoutExpired(cmd, timeout, output=out, stderr=err)
        combined = (exc.stdout or b"") + (exc.stderr or b"")
        log_text = combined.decode(errors="replace")
        elapsed = time.monotonic() - t0
        with print_lock:
            print("{}  TIMEOUT ({:.0f}s)".format(prefix, elapsed), flush=True)
        return "timeout", "Process did not exit within {}s".format(timeout)
    except Exception as exc:
        with print_lock:
            print("{}  ERROR   {}".format(prefix, str(exc)[:80]), flush=True)
        return "error", str(exc)

    elapsed = time.monotonic() - t0
    combined = (result.stdout or b"") + (result.stderr or b"")
    log_text = combined.decode(errors="replace")

    png_exists = screen_path.exists()
    png_size = screen_path.stat().st_size if png_exists else 0

    if result.returncode == 0 and png_exists:
        size_kb = screen_path.stat().st_size // 1024
        with print_lock:
            print("{}  OK      ({:.1f}s)  {}KB".format(prefix, elapsed, size_kb), flush=True)
        return "ok", ""

    if result.returncode != 0:
        detail = log_text[-1200:].strip() or "process exited with non-zero code"
        with print_lock:
            print("{}  ERROR   exit code {}".format(prefix, result.returncode), flush=True)
        return "error", detail

    # Screenshot file was not created — extract useful error lines.
    error_lines = [
        line for line in log_text.splitlines()
        if any(kw in line.lower() for kw in ("error", "panic", "lua", "failed", "not found"))
    ]
    detail = "\n".join(error_lines[-8:]) if error_lines else log_text[-400:].strip()
    first_err = (detail.split("\n")[0][:100] if detail else "no output")
    with print_lock:
        print("{}  ERROR   {}".format(prefix, first_err), flush=True)
    return "error", detail


def main():  # noqa: C901 — intentional length; argument parsing + orchestration
    parser = argparse.ArgumentParser(
        description="Capture screen.png for every Lurek2D game demo.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--binary",          default=None,
                        help="Path to the lurek2d binary (auto-detected if omitted)")
    parser.add_argument("--games-dir",       default=None,
                        help="Root game directory (default: content/games/)")
    parser.add_argument("--screenshot-time", type=float, default=3.0,
                        help="Wall-clock seconds after game start before capturing (default: 3.0)")
    parser.add_argument("--workers",         type=int, default=6,
                        help="Number of parallel capture slots (default: 6)")
    parser.add_argument("--slot-width",      type=int, default=None,
                        help="Slot width for window positioning in pixels (default: auto-fit monitor)")
    parser.add_argument("--slot-height",     type=int, default=None,
                        help="Slot height for window positioning in pixels (default: auto-fit monitor)")
    parser.add_argument("--force-window-size", action="store_true",
                        help="Force demo window size to slot size (default: keep native demo resolution)")
    parser.add_argument("--start-signal", default="off", choices=["auto", "off"],
                        help="Startup key simulation mode (default: off)")
    parser.add_argument("--start-keys", default="enter,space,1,2,3",
                        help="Comma-separated startup keys to send (default: enter,space)")
    parser.add_argument("--start-signal-duration", type=float, default=2.5,
                        help="Seconds to keep sending startup keys after launch (default: 1.5)")
    parser.add_argument("--start-signal-interval", type=float, default=0.12,
                        help="Delay between startup key sends (default: 0.25)")
    parser.add_argument("--demo",            action="append", dest="demos", metavar="NAME",
                        help="Capture only this demo name (repeatable)")
    parser.add_argument("--overwrite",       action="store_true",
                        help="Overwrite existing screen.png files")
    parser.add_argument("--timeout",         type=float, default=30.0,
                        help="Kill process after this many seconds if it has not exited (default: 30)")
    parser.add_argument("--rebuild",         action="store_true",
                        help="Run 'cargo build --release' before capturing")
    parser.add_argument("--dry-run",         action="store_true",
                        help="Print commands without executing")
    args = parser.parse_args()

    repo_root = REPO_ROOT

    if args.rebuild:
        rebuild(repo_root)

    binary = Path(args.binary) if args.binary else find_binary(repo_root)
    if not binary.exists():
        print("ERROR: Binary not found: {}".format(binary), file=sys.stderr)
        sys.exit(1)
    print("[binary] {}".format(binary))

    games_root = Path(args.games_dir) if args.games_dir else repo_root / "content" / "games"
    all_demos = discover_demos(games_root, args.demos or [])

    if args.demos:
        missing = set(args.demos) - {d.name for d in all_demos}
        if missing:
            print("WARNING: Demos not found: {}".format(", ".join(sorted(missing))), file=sys.stderr)

    if not all_demos:
        print("No demos found under: {}".format(games_root), file=sys.stderr)
        sys.exit(1)

    try:
        start_key_codes = _parse_start_keys(args.start_keys)
    except ValueError as exc:
        print("ERROR: {}".format(exc), file=sys.stderr)
        sys.exit(2)

    log_dir = None

    workers = max(1, args.workers)
    rows = (workers + _GRID_COLS - 1) // _GRID_COLS
    slot_width = args.slot_width
    slot_height = args.slot_height

    if slot_width is None or slot_height is None:
        detected = detect_primary_screen_size()
        if detected is not None:
            screen_w, screen_h = detected
            if slot_width is None:
                slot_width = max(320, screen_w // _GRID_COLS)
            if slot_height is None:
                slot_height = max(240, screen_h // rows)
        else:
            # Fallback keeps behavior deterministic if monitor lookup fails.
            slot_width = slot_width or 640
            slot_height = slot_height or 480

    slot_width = int(slot_width)
    slot_height = int(slot_height)

    print(
        "[demos]  {:d} to process  |  workers={:d}  |  screenshot-time={:.1f}s  |  timeout={:.0f}s".format(
            len(all_demos), workers, args.screenshot_time, args.timeout
        )
    )
    print(
        "[layout] {:d} cols x {:d} rows  |  slot {}x{}px".format(
            _GRID_COLS, rows,
            slot_width, slot_height,
        )
    )
    print(
        "[window] native demo resolution{}".format(
            " (forced to slot size)" if args.force_window_size else ""
        )
    )
    if args.start_signal == "auto" and os.name == "nt":
        print("[start] startup key simulation enabled: {}".format(args.start_keys))
    else:
        print("[start] startup key simulation disabled")
    print()

    # Slot pool: workers slots numbered 0..workers-1.  A slot is returned to
    # the pool as soon as its demo finishes, so the next queued demo can reuse it.
    slot_pool: queue.SimpleQueue = queue.SimpleQueue()
    for i in range(workers):
        slot_pool.put(i)

    print_lock = threading.Lock()
    stats = {"ok": 0, "skip": 0, "timeout": 0, "error": 0}
    failures = []
    stats_lock = threading.Lock()

    def run_one(index_demo):
        index, demo_dir = index_demo
        slot = slot_pool.get()
        try:
            status, detail = capture_demo(
                binary=binary,
                demo_dir=demo_dir,
                screenshot_time=args.screenshot_time,
                slot_index=slot,
                slot_width=slot_width,
                slot_height=slot_height,
                timeout=args.timeout,
                force_window_size=args.force_window_size,
                start_signal_mode=args.start_signal,
                start_key_codes=start_key_codes,
                start_signal_duration=args.start_signal_duration,
                start_signal_interval=args.start_signal_interval,
                overwrite=args.overwrite,
                dry_run=args.dry_run,
                log_dir=log_dir,
                print_lock=print_lock,
                index=index,
                total=len(all_demos),
            )
        finally:
            slot_pool.put(slot)
        return demo_dir.name, status, detail

    indexed = list(enumerate(all_demos, 1))

    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = {executor.submit(run_one, item): item for item in indexed}
        for future in as_completed(futures):
            name, status, detail = future.result()
            with stats_lock:
                stats[status] += 1
                if status in ("timeout", "error"):
                    failures.append({"name": name, "status": status, "detail": detail})

    print()
    print("Results: {} ok  |  {} skipped  |  {} timeout  |  {} error".format(
        stats["ok"], stats["skip"], stats["timeout"], stats["error"]))

    if failures:
        failures.sort(key=lambda f: f["name"])
        print("\nFailed demos ({}):\n".format(len(failures)))
        for f in failures:
            print("  [{}] {}".format(f["status"], f["name"]))
            if f["detail"]:
                for line in f["detail"].split("\n")[:4]:
                    print("         {}".format(line))
        sys.exit(1)


if __name__ == "__main__":
    main()

