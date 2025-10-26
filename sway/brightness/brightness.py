#!/usr/bin/env python3
import json
import subprocess
import sys
import time
from fcntl import LOCK_EX, LOCK_NB, LOCK_UN, flock
from pathlib import Path

# === CONFIG ===
STATE_FILE = Path.home() / ".config/sway/brightness/store.json"
LOCK_FILE = STATE_FILE.with_suffix(".lock")
BUSES = [1, 2]
DEFAULT_BRIGHTNESS = 50
DEBOUNCE_TIME = 0.15  # seconds between safe updates
# ===============


def load_state():
    if STATE_FILE.exists():
        try:
            return json.loads(STATE_FILE.read_text()).get(
                "brightness", DEFAULT_BRIGHTNESS
            )
        except Exception:
            pass
    return DEFAULT_BRIGHTNESS


def save_state(value: int):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps({"brightness": value}, indent=2))


def set_brightness(value: int):
    procs = []
    for bus in BUSES:
        cmd = ["ddcutil", "--bus", str(bus), "setvcp", "10", str(value)]
        procs.append(
            subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        )
    for p in procs:
        p.wait()


def main():
    step = int(sys.argv[1]) if len(sys.argv) > 1 else 10

    # Lock file to prevent multiple concurrent executions
    with open(LOCK_FILE, "w") as lock:
        try:
            flock(lock, LOCK_EX | LOCK_NB)
        except BlockingIOError:
            # another instance running → ignore this press
            sys.exit(0)

        current = load_state()
        new = max(0, min(100, current + step))

        # Skip redundant updates (too frequent)
        last_time_file = STATE_FILE.with_suffix(".time")
        now = time.time()
        if last_time_file.exists():
            last_time = float(last_time_file.read_text())
            if now - last_time < DEBOUNCE_TIME:
                # too soon after last run
                sys.exit(0)
        last_time_file.write_text(str(now))

        # Apply and store
        set_brightness(new)
        save_state(new)

        print(f"Brightness: {current} → {new}")

        flock(lock, LOCK_UN)


if __name__ == "__main__":
    main()
