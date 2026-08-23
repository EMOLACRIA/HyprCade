#!/usr/bin/env bash

set -euo pipefail

ACTION="${1:-}"

case "$ACTION" in
    up)
        brightnessctl -n2 set +5% >/dev/null
        ;;
    down)
        brightnessctl -n2 set 5%- >/dev/null
        ;;
    *)
        echo "usage: $0 <up|down>"
        exit 1
        ;;
esac

PERCENT="$(
    brightnessctl -m \
        | awk -F',' '{
            gsub(/%/, "", $4)
            print $4
            exit
        }'
)"

qs \
    -p /home/emo/Programs/HyprCade/config/quickshell/HyprCade \
    ipc call osd brightness "$PERCENT" \
    >/dev/null 2>&1 || true
