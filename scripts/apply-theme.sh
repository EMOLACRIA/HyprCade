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

# ─────────────────────────────────────
# WALLPAPER SELECTION
# ─────────────────────────────────────

WALLPAPER_STATE_DIR="$STATE_DIR/wallpapers"
WALLPAPER_SELECTION_FILE="$WALLPAPER_STATE_DIR/$THEME_ID"

mkdir -p "$WALLPAPER_STATE_DIR"

WALLPAPER_SELECTED_ID="${WALLPAPER_DEFAULT_ID:-main}"

if [[ -f "$WALLPAPER_SELECTION_FILE" ]]; then
    read -r WALLPAPER_SELECTED_ID \
        < "$WALLPAPER_SELECTION_FILE"
fi


WALLPAPER_ID=""
WALLPAPER_NAME=""
WALLPAPER_RELATIVE_PATH=""
WALLPAPER_SELECTED_FIT="${WALLPAPER_FIT:-cover}"


resolve_wallpaper() {
    local target_id="$1"

    if ! declare -p WALLPAPER_VARIANTS \
        >/dev/null 2>&1; then
        return 1
    fi

    local variant
    local id
    local name
    local file
    local fit

    for variant in "${WALLPAPER_VARIANTS[@]}"; do
        IFS='|' read -r \
            id name file fit <<< "$variant"

        if [[ "$id" == "$target_id" ]]; then
            WALLPAPER_ID="$id"
            WALLPAPER_NAME="$name"
            WALLPAPER_RELATIVE_PATH="$file"
            WALLPAPER_SELECTED_FIT="$fit"

            return 0
        fi
    done

    return 1
}


# Try saved choice first.
if ! resolve_wallpaper "$WALLPAPER_SELECTED_ID"; then

    # Saved choice no longer exists: use theme default.
    WALLPAPER_SELECTED_ID="${WALLPAPER_DEFAULT_ID:-main}"

    if ! resolve_wallpaper "$WALLPAPER_SELECTED_ID"; then

        # Backward-compatible fallback.
        WALLPAPER_ID="main"
        WALLPAPER_NAME="MAIN"
        WALLPAPER_RELATIVE_PATH="$WALLPAPER"
        WALLPAPER_SELECTED_FIT="${WALLPAPER_FIT:-cover}"
    fi
fi


WALLPAPER_PATH="$ROOT_DIR/$WALLPAPER_RELATIVE_PATH"

printf '%s\n' "$WALLPAPER_ID" \
    > "$WALLPAPER_SELECTION_FILE"


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

BACKGROUND_HEX="${BACKGROUND#\#}"
TEXT_HEX="${TEXT#\#}"
MUTED_HEX="${MUTED#\#}"

RED_HEX="${RED#\#}"
YELLOW_HEX="${YELLOW#\#}"
BLUE_HEX="${BLUE#\#}"
TEAL_HEX="${TEAL#\#}"

BORDER_HEX="${BORDER#\#}"

BACKGROUND_RGB="$(
    printf '%d, %d, %d' \
        "$((16#${BACKGROUND_HEX:0:2}))" \
        "$((16#${BACKGROUND_HEX:2:2}))" \
        "$((16#${BACKGROUND_HEX:4:2}))"
)"

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
# DUNST THEME STATE
# ─────────────────────────────────────

# ─────────────────────────────────────
# HYPRLOCK THEME STATE
# ─────────────────────────────────────

HYPRLOCK_TEMPLATE="${HYPRLOCK_TEMPLATE:-config/hyprlock/hyprlock.conf.template}"

if [[ "$HYPRLOCK_TEMPLATE" != /* ]]; then
    HYPRLOCK_TEMPLATE="$ROOT_DIR/$HYPRLOCK_TEMPLATE"
fi

HYPRLOCK_STATE="$STATE_DIR/hyprlock.conf"

if [[ -f "$HYPRLOCK_TEMPLATE" ]]; then
    sed \
        -e "s|@WALLPAPER_PATH@|$WALLPAPER_PATH|g" \
        -e "s|@SYSTEM_NAME@|$SYSTEM_NAME|g" \
        -e "s|@BACKGROUND_RGB@|$BACKGROUND_RGB|g" \
        -e "s|@TEXT_HEX@|$TEXT_HEX|g" \
        -e "s|@MUTED_HEX@|$MUTED_HEX|g" \
        -e "s|@RED_HEX@|$RED_HEX|g" \
        -e "s|@YELLOW_HEX@|$YELLOW_HEX|g" \
        -e "s|@BLUE_HEX@|$BLUE_HEX|g" \
        -e "s|@TEAL_HEX@|$TEAL_HEX|g" \
        -e "s|@BORDER_HEX@|$BORDER_HEX|g" \
        "$HYPRLOCK_TEMPLATE" \
        > "$HYPRLOCK_STATE"
fi

# ─────────────────────────────────────
# DUNST THEME STATE
# ─────────────────────────────────────

DUNST_TEMPLATE="${DUNST_TEMPLATE:-config/dunst/dunstrc.template}"

if [[ "$DUNST_TEMPLATE" != /* ]]; then
    DUNST_TEMPLATE="$ROOT_DIR/$DUNST_TEMPLATE"
fi

DUNST_STATE="$STATE_DIR/dunstrc"

if [[ -f "$DUNST_TEMPLATE" ]]; then
    sed \
        -e "s|@BACKGROUND@|$BACKGROUND|g" \
        -e "s|@PANEL@|$PANEL|g" \
        -e "s|@PANEL_ALT@|$PANEL_ALT|g" \
        -e "s|@TEXT@|$TEXT|g" \
        -e "s|@MUTED@|$MUTED|g" \
        -e "s|@RED@|$RED|g" \
        -e "s|@YELLOW@|$YELLOW|g" \
        -e "s|@BLUE@|$BLUE|g" \
        -e "s|@TEAL@|$TEAL|g" \
        -e "s|@BORDER@|$BORDER|g" \
        "$DUNST_TEMPLATE" \
        > "$DUNST_STATE"
fi

# ─────────────────────────────────────
# WALLPAPER REGISTRY STATE
# ─────────────────────────────────────

WALLPAPER_JSON="$STATE_DIR/wallpapers.json"
WALLPAPER_JSON_TMP="$WALLPAPER_JSON.tmp"

{
    printf '{\n'
    printf '    "themeId": "%s",\n' "$THEME_ID"
    printf '    "activeId": "%s",\n' "$WALLPAPER_ID"
    printf '    "variants": [\n'

    first=true

    if declare -p WALLPAPER_VARIANTS \
        >/dev/null 2>&1; then

        for variant in "${WALLPAPER_VARIANTS[@]}"; do
            IFS='|' read -r \
                id name file fit <<< "$variant"

            if [[ "$first" == false ]]; then
                printf ',\n'
            fi

            first=false

            printf '        {'
            printf '"id":"%s",' "$id"
            printf '"name":"%s",' "$name"
            printf '"path":"%s",' "$ROOT_DIR/$file"
            printf '"relativePath":"%s",' "$file"
            printf '"fit":"%s"' "$fit"
            printf '}'
        done
    fi

    printf '\n    ]\n'
    printf '}\n'

} > "$WALLPAPER_JSON_TMP"

mv "$WALLPAPER_JSON_TMP" "$WALLPAPER_JSON"

# ─────────────────────────────────────
# WALLPAPER STATE + LIVE WALLPAPER
# ─────────────────────────────────────

if [[ -f "$WALLPAPER_PATH" ]]; then
    cat > "$STATE_DIR/hyprpaper.conf" <<EOF
wallpaper {
    monitor = $MONITOR
    path = $WALLPAPER_PATH
    fit_mode = $WALLPAPER_SELECTED_FIT
}
EOF

    if hyprctl hyprpaper listactive >/dev/null 2>&1; then
        hyprctl hyprpaper wallpaper \
            "$MONITOR, $WALLPAPER_PATH, $WALLPAPER_SELECTED_FIT"
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

# ─────────────────────────────────────
# RELOAD DUNST
# ─────────────────────────────────────

if systemctl --user is-active --quiet dunst 2>/dev/null; then
    systemctl --user restart dunst || true
fi

echo "HyprCade: applied theme '$THEME_NAME'"

# ─────────────────────────────────────
# SDDM THEME SYNC
# ─────────────────────────────────────

if sudo -n /usr/local/bin/hyprcade-set-sddm-theme "$THEME_ID"; then
    :
else
    echo "HyprCade: no matching SDDM theme for '$THEME_ID'; keeping current SDDM theme."
fi
