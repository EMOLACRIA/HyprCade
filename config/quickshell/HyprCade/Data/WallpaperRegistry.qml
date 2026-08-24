import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    readonly property string registryPath:
    (Quickshell.env("XDG_STATE_HOME")
    || (Quickshell.env("HOME") + "/.local/state"))
    + "/hyprcade/wallpapers.json"

    property FileView registryFile: FileView {
        path: root.registryPath

        watchChanges: true
        blockLoading: true

        onFileChanged: registryFile.reload()
    }

    readonly property var registry: {
        try {
            const raw = registryFile.text()

            if (raw.length > 0)
                return JSON.parse(raw)
        } catch (error) {
            console.warn(
                "HyprCade: failed to load wallpaper registry:",
                error
            )
        }

        return ({})
    }

    readonly property string themeId:
    registry.themeId || ""

    readonly property string activeId:
    registry.activeId || ""

    readonly property var variants:
    registry.variants || []

    function imageSource(path): string {
        if (!path || path.length === 0)
            return ""

            return "file://" + path
    }
}
