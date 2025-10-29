#!/usr/bin/env bash
# Wait until monitors are detectable via ddcutil

echo "🔎 Waiting for DDC monitors to appear..."

# Wait until ddcutil detect shows at least one Display
for i in {1..100}; do
  if /usr/bin/ddcutil detect | grep -q "Display"; then
    echo "✅ DDC monitors detected!"
    break
  fi
  sleep 0.2
  if [[ $i -eq 20 ]]; then
    echo "❌ No monitors detected after 20s, aborting."
    exit 1
  fi
done

# Now safe to set values
/usr/bin/ddcutil --bus=1 setvcp 12 40
/usr/bin/ddcutil --bus=2 setvcp 12 15
