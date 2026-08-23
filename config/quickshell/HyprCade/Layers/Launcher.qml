import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../Data"

Scope {
    id: root

    property bool opened: false
    property bool windowVisible: false
    property string searchText: ""

    function openLauncher(): void {
        hideTimer.stop()
        root.windowVisible = true
        root.opened = true
    }

    function closeLauncher(): void {
        root.opened = false
        hideTimer.restart()
    }

    function toggleLauncher(): void {
        if (root.opened)
            root.closeLauncher()
            else
                root.openLauncher()
    }

    function openMusic(): void {
        const apps = DesktopEntries.applications.values

        // Önce Spotify Adblock sürümünü ara.
        for (let i = 0; i < apps.length; ++i) {
            const name = (apps[i].name || "").toLowerCase()

            if (name === "spotify (adblock)"
                || (name.includes("spotify")
                && name.includes("adblock"))) {
                apps[i].execute()
                return
                }
        }

        // Bulamazsa herhangi bir Spotify entry'sini aç.
        for (let i = 0; i < apps.length; ++i) {
            const name = (apps[i].name || "").toLowerCase()

            if (name.includes("spotify")) {
                apps[i].execute()
                return
            }
        }
    }

    function backendTag(app): string {
        const id = (app.id || "").toLowerCase()
        const exec = (app.execString || "").toLowerCase()

        if (id.includes("flatpak")
            || exec.includes("flatpak")
            || id.includes("com.valvesoftware.steam"))
            return "FLATPAK"

            return "NATIVE"
    }

    function searchTitle(app): string {
        const name = (app.name || "").toUpperCase()
        const lowerName = (app.name || "").toLowerCase()

        if (lowerName.includes("steam"))
            return name + " [" + root.backendTag(app) + "]"

            return name
    }

    function searchSubtitle(app): string {
        const name = (app.name || "").toLowerCase()

        if (name.includes("steam"))
            return "STEAM // " + root.backendTag(app)

            if (app.genericName && app.genericName.length > 0)
                return app.genericName.toUpperCase()

                if (app.comment && app.comment.length > 0)
                    return app.comment.toUpperCase()

                    return (app.id || "APPLICATION").toUpperCase()
    }

    Timer {
        id: hideTimer
        interval: 220

        onTriggered: {
            if (!root.opened)
                root.windowVisible = false
        }
    }

    Palette {
        id: colors
    }

    readonly property var quickActions: [
        {
            label: "TERMINAL",
            sub: "ターミナル",
            accent: colors.blue,
            command: "kitty",
            action: "command",
            enabled: true
        },
        {
            label: "FILES",
            sub: "ファイル",
            accent: colors.yellow,
            command: "dolphin",
            action: "command",
            enabled: true
        },
        {
            label: "BROWSER",
            sub: "ブラウザ",
            accent: colors.red,
            command: "zen-browser",
            action: "command",
            enabled: true
        },
        {
            label: "MUSIC",
            sub: "スポティファイ // 広告なし",
            accent: colors.blue,
            command: "",
            action: "music",
            enabled: true
        },
        {
            label: "LOCK",
            sub: "ロック",
            accent: colors.yellow,
            command: "hyprlock",
            action: "command",
            enabled: true
        },
        {
            label: "HYPRCADE",
            sub: "SYSTEM // CONTROL",
            accent: colors.teal,
            command: "",
            action: "control",
            enabled: true
        }
    ]

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggleLauncher()
        }

        function open(): void {
            root.openLauncher()
        }

        function close(): void {
            root.closeLauncher()
        }
    }

    ScriptModel {
        id: appSearchModel

        values: {
            if (!root.windowVisible)
                return []

                const query = root.searchText.trim().toLowerCase()

                if (query.length === 0)
                    return []

                    const apps = DesktopEntries.applications.values

                    return [...apps]
                    .filter(app => {
                        const name = (app.name || "").toLowerCase()
                        const generic = (app.genericName || "").toLowerCase()
                        const comment = (app.comment || "").toLowerCase()

                        return name.includes(query)
                        || generic.includes(query)
                        || comment.includes(query)
                    })
                    .sort((a, b) => {
                        const an = (a.name || "").toLowerCase()
                        const bn = (b.name || "").toLowerCase()

                        const aStarts = an.startsWith(query)
                        const bStarts = bn.startsWith(query)

                        if (aStarts !== bStarts)
                            return aStarts ? -1 : 1

                            return an.localeCompare(bn)
                    })
                    .slice(0, 8)
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: root.windowVisible

            anchors {
                top: true
                bottom: true
                left: true
            }

            margins {
                top: 64
                bottom: 14
                left: 0
            }

            implicitWidth: 312

            exclusiveZone: 0
            color: "transparent"
            focusable: true

            onVisibleChanged: {
                if (visible) {
                    root.searchText = ""
                    menuList.currentIndex = 0
                    searchInput.forceActiveFocus()
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: 300
                x: root.opened ? 12 : -300

                Behavior on x {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }

                color: colors.background

                border.width: 1
                border.color: colors.border

                ColumnLayout {
                    anchors.fill: parent

                    anchors.topMargin: 22
                    anchors.bottomMargin: 18
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    spacing: 0

                    // HEADER
                    Text {
                        text: "SYSTEM"
                        color: colors.yellow

                        font.family: "monospace"
                        font.pixelSize: 15
                        font.bold: true
                        font.letterSpacing: 1.2
                    }

                    Text {
                        text: "MENU"
                        color: colors.text

                        font.family: "monospace"
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Text {
                        text: "システム"
                        color: colors.muted
                        font.pixelSize: 9
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 14
                        Layout.bottomMargin: 12

                        height: 1
                        color: colors.border
                    }

                    // SEARCH
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 12

                        height: 38
                        color: colors.panel

                        border.width: 1
                        border.color: searchInput.activeFocus
                        ? colors.yellow
                        : colors.border

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter

                            text: ">"
                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        TextInput {
                            id: searchInput

                            anchors.left: parent.left
                            anchors.leftMargin: 30
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            text: root.searchText
                            onTextChanged: {
                                root.searchText = text
                                menuList.currentIndex = 0
                            }

                            color: colors.text
                            selectionColor: colors.red
                            selectedTextColor: colors.background

                            font.family: "monospace"
                            font.pixelSize: 11
                            font.bold: true

                            clip: true

                            Keys.onPressed: function(event) {
                                if (event.key === Qt.Key_Down) {
                                    if (menuList.count > 0) {
                                        menuList.currentIndex =
                                        (menuList.currentIndex + 1) % menuList.count

                                        menuList.positionViewAtIndex(
                                            menuList.currentIndex,
                                            ListView.Contain
                                        )
                                    }

                                    event.accepted = true
                                    return
                                }

                                if (event.key === Qt.Key_Up) {
                                    if (menuList.count > 0) {
                                        menuList.currentIndex =
                                        (menuList.currentIndex - 1 + menuList.count)
                                        % menuList.count

                                        menuList.positionViewAtIndex(
                                            menuList.currentIndex,
                                            ListView.Contain
                                        )
                                    }

                                    event.accepted = true
                                    return
                                }

                                if (event.key === Qt.Key_Return
                                    || event.key === Qt.Key_Enter) {
                                    if (menuList.currentItem)
                                        menuList.currentItem.activate()

                                        event.accepted = true
                                    }
                            }

                            Keys.onEscapePressed: {
                                root.closeLauncher()
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 30
                            anchors.verticalCenter: parent.verticalCenter

                            visible: searchInput.text.length === 0

                            text: "SEARCH SYSTEM..."
                            color: colors.muted

                            font.family: "monospace"
                            font.pixelSize: 9
                        }
                    }

                    // MENU / SEARCH RESULTS
                    ListView {
                        id: menuList

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        spacing: 3
                        clip: true

                        model: root.searchText.trim().length > 0
                        ? appSearchModel
                        : root.quickActions

                        delegate: Rectangle {
                            id: menuEntry

                            required property var modelData

                            property bool searchResult:
                            root.searchText.trim().length > 0

                            property color entryAccent:
                            searchResult
                            ? colors.red
                            : modelData.accent

                            property bool keyboardSelected:
                            ListView.isCurrentItem

                            property bool highlighted:
                            keyboardSelected || mouse.containsMouse

                            property bool entryEnabled:
                            searchResult || modelData.enabled

                            width: menuList.width
                            height: 58

                            color: highlighted
                            ? colors.panelAlt
                            : "transparent"

                            border.width: 1
                            border.color: highlighted
                            ? menuEntry.entryAccent
                            : "transparent"

                            opacity:
                            menuEntry.searchResult || modelData.enabled
                            ? 1.0
                            : 0.45

                            Rectangle {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                                width: menuEntry.keyboardSelected ? 6 : 4
                                height: menuEntry.keyboardSelected ? 38 : 32

                                color: menuEntry.entryAccent
                            }

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: 17
                                anchors.verticalCenter: parent.verticalCenter

                                spacing: 2

                                Text {
                                    text: menuEntry.searchResult
                                    ? "> " + root.searchTitle(modelData)
                                    : "> " + modelData.label

                                    color: menuEntry.highlighted
                                    ? menuEntry.entryAccent
                                    : colors.text

                                    font.family: "monospace"
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.letterSpacing: 0.5
                                }

                                Text {
                                    text: menuEntry.searchResult
                                    ? root.searchSubtitle(modelData)
                                    : modelData.sub

                                    color: colors.muted

                                    font.family: "monospace"
                                    font.pixelSize: 9
                                }
                            }

                            function activate(): void {
                                if (!menuEntry.entryEnabled)
                                    return

                                    if (menuEntry.searchResult) {
                                        modelData.execute()
                                        root.closeLauncher()
                                        return
                                    }

                                    if (modelData.action === "control") {
                                        Quickshell.execDetached([
                                            "qs",
                                            "-p",
                                            "/home/emo/Programs/HyprCade/config/quickshell/HyprCade",
                                            "ipc",
                                            "call",
                                            "controlpanel",
                                            "toggle"
                                        ])

                                        root.closeLauncher()
                                        return
                                    }

                                    if (modelData.action === "music") {
                                        root.openMusic()
                                        root.closeLauncher()
                                        return
                                    }

                                    if (modelData.action === "command") {
                                        Quickshell.execDetached([
                                            "sh",
                                            "-lc",
                                            modelData.command
                                        ])

                                        root.closeLauncher()
                                    }
                            }

                            MouseArea {
                                id: mouse

                                anchors.fill: parent
                                hoverEnabled: true

                                enabled: menuEntry.entryEnabled

                                cursorShape: enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                                onClicked: menuEntry.activate()
                            }
                        }
                    }

                    // FOOTER
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 13

                        height: 1
                        color: colors.border
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "BEBOP SYS."
                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "STAY COOL"
                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.letterSpacing: 1
                        }
                    }
                }
            }
        }
    }
}
