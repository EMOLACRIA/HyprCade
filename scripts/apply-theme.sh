#!/usr/bin/env bash

set -euo pipefail

THEME_ID="${1:-}"

if [[ -z "$THEME_ID" ]]; then
    echo "usage: $0 <theme>"
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

THEME_FILE="$ROOT_DIR/themes/$THEME_ID/theme.conf"

if [[ ! -f "$THEME_FILE" ]]; then
    echo "HyprCade: theme not found: $THEME_ID"
    exit 1
fi

# shellcheck disable=SC1090
source "$THEME_FILE"

STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_DIR="$STATE_HOME/hyprcade"

mkdir -p "$STATE_DIR"

WALLPAPER_PATH="$ROOT_DIR/$WALLPAPER"


# ─────────────────────────────────────
# QUICKSHELL THEME STATE
# ─────────────────────────────────────

cat > "$STATE_DIR/theme.json" <<EOF
{
    "id": "$THEME_ID",
    "name": "$THEME_NAME",
    "systemName": "$SYSTEM_NAME",

    "background": "$BACKGROUND",
    "panel": "$PANEL",
    "panelAlt": "$PANEL_ALT",

    "text": "$TEXT",
    "muted": "$MUTED",

    "red": "$RED",
    "yellow": "$YELLOW",
    "blue": "$BLUE",
    "teal": "$TEAL",

    "border": "$BORDER"
}
EOF


# ─────────────────────────────────────
# HYPRLAND THEME STATE
# ─────────────────────────────────────

RED_HEX="${RED#\#}"
BLUE_HEX="${BLUE#\#}"
BORDER_HEX="${BORDER#\#}"

cat > "$STATE_DIR/hypr-theme.lua" <<EOF
return {
    active_border = {
        "rgba(${RED_HEX}ee)",
        "rgba(${BLUE_HEX}ee)"
    },

    inactive_border = "rgba(${BORDER_HEX}aa)"
}
EOF


# ─────────────────────────────────────
# WALLPAPER STATE + LIVE WALLPAPER
# ─────────────────────────────────────

if [[ -f "$WALLPAPER_PATH" ]]; then
    cat > "$STATE_DIR/hyprpaper.conf" <<EOF
wallpaper {
    monitor = $MONITOR
    path = $WALLPAPER_PATH
    fit_mode = $WALLPAPER_FIT
}
EOF

    if hyprctl hyprpaper listactive >/dev/null 2>&1; then
        hyprctl hyprpaper wallpaper \
            "$MONITOR, $WALLPAPER_PATH, $WALLPAPER_FIT"
    fi
else
    echo "HyprCade: wallpaper not found yet:"
    echo "  $WALLPAPER_PATH"
fi


# ─────────────────────────────────────
# RELOAD HYPRLAND
# ─────────────────────────────────────

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi


echo "HyprCade: applied theme '$THEME_NAME'"
