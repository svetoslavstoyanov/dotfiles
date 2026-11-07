#!/usr/bin/env bash

# Get RAM usage percentage
ram_usage=$(free | awk '/Mem:/ {printf "%.0f%%", $3/$2 * 100}')

# Calculate CPU usage percentage over a brief 0.5s interval
read -r _ u1 n1 s1 i1 io1 ir1 sir1 _ </proc/stat
prev_idle=$((i1 + io1))
prev_total=$((u1 + n1 + s1 + i1 + io1 + ir1 + sir1))

sleep 0.5

read -r _ u2 n2 s2 i2 io2 ir2 sir2 _ </proc/stat
idle=$((i2 + io2))
total=$((u2 + n2 + s2 + i2 + io2 + ir2 + sir2))

diff_idle=$((idle - prev_idle))
diff_total=$((total - prev_total))

if [ "$diff_total" -gt 0 ]; then
  cpu_usage=$((100 * (diff_total - diff_idle) / diff_total))
else
  cpu_usage=0
fi

echo "[CPU: ${cpu_usage}% | RAM: ${ram_usage}]"
