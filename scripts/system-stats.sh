#!/usr/bin/env bash

# Initial CPU sample
read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat

prev_idle=$((idle + iowait))
prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal))

while true; do
    sleep 1

    # ─────────────────────────────────────────────
    # CPU
    # ─────────────────────────────────────────────

    read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat

    idle_all=$((idle + iowait))
    non_idle=$((user + nice + system + irq + softirq + steal))
    total=$((idle_all + non_idle))

    total_delta=$((total - prev_total))
    idle_delta=$((idle_all - prev_idle))

    if (( total_delta > 0 )); then
        cpu=$((100 * (total_delta - idle_delta) / total_delta))
    else
        cpu=0
    fi

    prev_total=$total
    prev_idle=$idle_all

    # ─────────────────────────────────────────────
    # RAM
    # ─────────────────────────────────────────────

    mem_total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
    mem_available=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)

    if (( mem_total > 0 )); then
        mem_used=$((mem_total - mem_available))
        ram=$((100 * mem_used / mem_total))
    else
        ram=0
    fi

    # ─────────────────────────────────────────────
    # ROOT DISK
    # ─────────────────────────────────────────────

    disk=$(
        df -P / |
        awk 'NR == 2 {
            gsub("%", "", $5)
            print $5
        }'
    )

    printf '%d|%d|%d\n' "$cpu" "$ram" "$disk"
done
