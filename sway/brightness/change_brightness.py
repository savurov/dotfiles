#!/usr/bin/env python3
import json
import subprocess
import sys
import time
from fcntl import LOCK_EX, LOCK_NB, LOCK_UN, flock
from pathlib import Path

# === CONFIG ===
CONFIG_DIR = Path.home() / ".config/sway/brightness"
PRESETS_FILE = CONFIG_DIR / "presets.json"
STATE_FILE = CONFIG_DIR / "store.json"
LOCK_FILE = CONFIG_DIR / "brightness.lock"
DEBOUNCE_FILE = CONFIG_DIR / "brightness.time"
DEBOUNCE_TIME = 0.2  # seconds between safe updates
MAX_MODE = 9
# ===============

# Mapping short keys to DDC VCP codes
VCP_MAP = {"b": "10", "c": "12", "r": "16", "g": "18", "b_col": "1A"}


def load_state() -> int:
    if STATE_FILE.exists():
        try:
            return int(json.loads(STATE_FILE.read_text()).get("mode", 0))
        except Exception:
            pass
    return 0


def save_state(value: int):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps({"mode": str(value)}, indent=2))


def load_config() -> dict:
    if not PRESETS_FILE.exists():
        raise SystemExit(f"❌ Missing config: {PRESETS_FILE}")
    return json.loads(PRESETS_FILE.read_text())


def set_vcp(bus: int, code: str, value: int):
    """Run ddcutil synchronously, silent."""
    subprocess.run(
        ["ddcutil", "--bus", str(bus), "setvcp", code, str(value)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def apply_mode(mode: int):
    """Apply preset mode to all monitors using parallel processes."""
    cfg = load_config()
    modes = cfg.get("modes", {})
    rgb = cfg.get("rgb", {})

    if str(mode) not in modes:
        print(f"⚠️ No mode {mode} found in config.")
        return

    mode_cfg = modes[str(mode)]
    procs = []

    for bus_str, params in mode_cfg.items():
        bus = int(bus_str)
        cmds = []

        # Brightness and contrast
        if "b" in params:
            cmds.append(
                ["ddcutil", "--bus", str(bus), "setvcp", VCP_MAP["b"], str(params["b"])]
            )
        if "c" in params:
            cmds.append(
                ["ddcutil", "--bus", str(bus), "setvcp", VCP_MAP["c"], str(params["c"])]
            )

        # Global RGB (applied always)
        rgb_cfg = rgb.get(bus_str, {})
        for color_key, val in rgb_cfg.items():
            if color_key == "r":
                code = VCP_MAP["r"]
            elif color_key == "g":
                code = VCP_MAP["g"]
            elif color_key == "b":
                code = VCP_MAP["b_col"]
            else:
                continue
            cmds.append(["ddcutil", "--bus", str(bus), "setvcp", code, str(val)])

        # Combine per-monitor commands in sequence, run in parallel per monitor
        procs.append(
            subprocess.Popen(
                ["bash", "-c", " && ".join(" ".join(cmd) for cmd in cmds)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        )

    for p in procs:
        p.wait()

    save_state(mode)
    print(f"✅ Applied preset {mode}")


def change_mode(direction: str | None, number: str | None = None):
    """Increment/decrement or set specific preset."""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    with open(LOCK_FILE, "w") as lock:
        try:
            flock(lock, LOCK_EX | LOCK_NB)
        except BlockingIOError:
            # another process is running → skip
            sys.exit(0)

        now = time.time()
        if DEBOUNCE_FILE.exists():
            try:
                last = float(DEBOUNCE_FILE.read_text())
                if now - last < DEBOUNCE_TIME:
                    sys.exit(0)
            except Exception:
                pass
        DEBOUNCE_FILE.write_text(str(now))

        current = load_state()
        if direction == "up":
            new = min(MAX_MODE, current + 1)
        elif direction == "down":
            new = max(0, current - 1)
        elif number is not None:
            new = max(0, min(MAX_MODE, int(number)))
        else:
            print("Usage: ddc_fast.py [up|down|<0-9>]")
            sys.exit(1)

        if new == current:
            sys.exit(0)  # no change needed

        apply_mode(new)
        flock(lock, LOCK_UN)


def main():
    if len(sys.argv) < 2:
        print("Usage: ddc_fast.py [up|down|<0-9>]")
        sys.exit(1)

    arg = sys.argv[1]
    if arg in ("up", "down"):
        change_mode(arg)
    elif arg.isdigit():
        change_mode(None, arg)
    else:
        print("Usage: ddc_fast.py [up|down|<0-9>]")


if __name__ == "__main__":
    main()
