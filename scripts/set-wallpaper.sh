#!/usr/bin/env bash

set -euo pipefail

THEME_ID="${1:-}"
WALLPAPER_ID="${2:-}"

if [[ -z "$THEME_ID" || -z "$WALLPAPER_ID" ]]; then
    echo "usage: $0 <theme> <wallpaper-id>"
    exit 1
fi

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" \
    && pwd
)"

ROOT_DIR="$(
    cd -- "$SCRIPT_DIR/.." \
    && pwd
)"

THEME_FILE="$ROOT_DIR/themes/$THEME_ID/theme.conf"

if [[ ! -f "$THEME_FILE" ]]; then
    echo "HyprCade: theme not found: $THEME_ID"
    exit 1
fi

# shellcheck disable=SC1090
source "$THEME_FILE"


found=false

if declare -p WALLPAPER_VARIANTS \
    >/dev/null 2>&1; then

    for variant in "${WALLPAPER_VARIANTS[@]}"; do
        IFS='|' read -r id name file fit <<< "$variant"

        if [[ "$id" == "$WALLPAPER_ID" ]]; then
            found=true
            break
        fi
    done
fi


if [[ "$found" != true ]]; then
    echo "HyprCade: wallpaper not found: $WALLPAPER_ID"
    exit 1
fi


STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
SELECTION_DIR="$STATE_HOME/hyprcade/wallpapers"

mkdir -p "$SELECTION_DIR"

printf '%s\n' "$WALLPAPER_ID" \
    > "$SELECTION_DIR/$THEME_ID"


exec "$ROOT_DIR/scripts/apply-theme.sh" "$THEME_ID"
