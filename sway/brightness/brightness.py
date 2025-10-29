#!/usr/bin/env python3
import json
import subprocess
import sys
import time
from fcntl import LOCK_EX, LOCK_NB, LOCK_UN, flock
from pathlib import Path

# === CONFIG ===
STATE_FILE = Path.home() / ".config/sway/brightness/store.json"
PRESETS_FILE = Path.home() / ".config/sway/brightness/presets.json"
LOCK_FILE = STATE_FILE.with_suffix(".lock")
BUSES = [1, 2]
DEFAULT_MODE = 5  # индекс из presets.json
DEFAULT_BRIGHTNESS = 50
SLEEP_BETWEEN_VCP = 0.30  # сек между brightness и contrast
DEBOUNCE_TIME = 0.15  # сек между запусками
# ===============


def load_presets():
    try:
        return json.loads(PRESETS_FILE.read_text())
    except Exception as e:
        print(f"⚠️ cannot read {PRESETS_FILE}: {e}", file=sys.stderr)
        sys.exit(1)


def load_state():
    if STATE_FILE.exists():
        try:
            data = json.loads(STATE_FILE.read_text())
            return data.get("mode", DEFAULT_MODE)
        except Exception:
            pass
    return DEFAULT_MODE


def save_state(mode: int):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps({"mode": mode}, indent=2))


def set_vcp(bus: int, code: int, value: int):
    """Send one VCP command safely."""
    cmd = ["ddcutil", "--bus", str(bus), "setvcp", f"{code:02x}", str(value)]
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(SLEEP_BETWEEN_VCP)


def apply_mode(mode: int, presets: dict):
    """Apply brightness/contrast pair from presets.json."""
    for bus in BUSES:
        try:
            b = int(presets["modes"][str(mode)][str(bus)]["b"])
            c = int(presets["modes"][str(mode)][str(bus)]["c"])
        except KeyError:
            print(f"⚠️ no data for mode {mode}, bus {bus}", file=sys.stderr)
            continue
        # Sequential per monitor, but different monitors run in parallel
        pid = subprocess.Popen(
            [
                sys.executable,
                "-c",
                f"import time,subprocess; "
                f"subprocess.run(['ddcutil','--bus','{bus}','setvcp','10','{b}'],"
                "stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL); "
                f"time.sleep({SLEEP_BETWEEN_VCP}); "
                f"subprocess.run(['ddcutil','--bus','{bus}','setvcp','12','{c}'],"
                "stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)",
            ]
        )
    # Wait all background workers
    for p in subprocess._active[:]:
        p.wait()


def main():
    step = 1 if sys.argv[1] == "up" else -1
    if sys.argv[1] == "current":
        step = 0

    presets = load_presets()

    # Lock file to prevent concurrent runs
    with open(LOCK_FILE, "w") as lock:
        try:
            flock(lock, LOCK_EX | LOCK_NB)
        except BlockingIOError:
            sys.exit(0)

        current_mode = load_state()
        new_mode = max(0, min(9, current_mode + step))

        # Debounce
        last_time_file = STATE_FILE.with_suffix(".time")
        now = time.time()
        if last_time_file.exists():
            last_time = float(last_time_file.read_text())
            if now - last_time < DEBOUNCE_TIME:
                sys.exit(0)
        last_time_file.write_text(str(now))

        # Apply & save
        apply_mode(new_mode, presets)
        save_state(new_mode)
        print(f"Mode: {current_mode} → {new_mode}")

        flock(lock, LOCK_UN)


if __name__ == "__main__":
    main()
