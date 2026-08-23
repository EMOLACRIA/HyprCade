import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    readonly property string themePath:
    (Quickshell.env("XDG_STATE_HOME")
    || (Quickshell.env("HOME") + "/.local/state"))
    + "/hyprcade/theme.json"

    property FileView themeFile: FileView {
        path: root.themePath

        watchChanges: true
        blockLoading: true

        onFileChanged: themeFile.reload()
    }

    readonly property var theme: {
        try {
            const raw = themeFile.text()

            if (raw.length > 0)
                return JSON.parse(raw)
        } catch (error) {
            console.warn(
                "HyprCade: failed to load theme:",
                error
            )
        }

        return ({})
    }

    readonly property string themeId:
    theme.id || "cowboy-bebop"

    readonly property string themeName:
    theme.name || "Cowboy Bebop"

    readonly property string systemName:
    theme.systemName || "BEBOP SYSTEM"


    // Core

    readonly property color background:
    theme.background || "#070A0D"

    readonly property color panel:
    theme.panel || "#0B1117"

    readonly property color panelAlt:
    theme.panelAlt || "#101922"


    // Text

    readonly property color text:
    theme.text || "#E8E2D5"

    readonly property color muted:
    theme.muted || "#71808D"


    // Accents

    readonly property color red:
    theme.red || "#D33A3A"

    readonly property color yellow:
    theme.yellow || "#D6A83C"

    readonly property color blue:
    theme.blue || "#3977A8"

    readonly property color teal:
    theme.teal || "#3D8177"


    // Structure

    readonly property color border:
    theme.border || "#243644"
}
