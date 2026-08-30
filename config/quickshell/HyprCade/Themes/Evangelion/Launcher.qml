import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../../Data"

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

        for (let i = 0; i < apps.length; ++i) {
            const name = (apps[i].name || "").toLowerCase()

            if (
                name === "spotify (adblock)"
                || (
                    name.includes("spotify")
                    && name.includes("adblock")
                )
            ) {
                apps[i].execute()
                return
            }
        }

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

        if (
            id.includes("flatpak")
            || exec.includes("flatpak")
            || id.includes("com.valvesoftware.steam")
        )
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
        interval: 180

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
            sub: "COMMAND LINE",
            command: "kitty",
            action: "command"
        },
        {
            label: "FILES",
            sub: "ARCHIVE",
            command: "dolphin",
            action: "command"
        },
        {
            label: "BROWSER",
            sub: "EXTERNAL LINK",
            command: "zen-browser",
            action: "command"
        },
        {
            label: "MUSIC",
            sub: "AUDIO CHANNEL",
            command: "",
            action: "music"
        },
        {
            label: "LOCK",
            sub: "SECURITY",
            command: "",
            action: "lock"
        },
        {
            label: "SYSTEM",
            sub: "MAGI CONTROL",
            command: "",
            action: "control"
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

                const query =
                root.searchText.trim().toLowerCase()

                if (query.length === 0)
                    return []

                    const apps =
                    DesktopEntries.applications.values

                    return [...apps]
                    .filter(app => {
                        const name =
                        (app.name || "").toLowerCase()

                        const generic =
                        (app.genericName || "")
                        .toLowerCase()

                        const comment =
                        (app.comment || "")
                        .toLowerCase()

                        return (
                            name.includes(query)
                            || generic.includes(query)
                            || comment.includes(query)
                        )
                    })
                    .sort((a, b) => {
                        const an =
                        (a.name || "").toLowerCase()

                        const bn =
                        (b.name || "").toLowerCase()

                        const aStarts =
                        an.startsWith(query)

                        const bStarts =
                        bn.startsWith(query)

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
                top: 48
                bottom: 18
                left: 0
            }

            implicitWidth: 286

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
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                width: 272

                x:
                root.opened
                ? 10
                : -274

                Behavior on x {
                    NumberAnimation {
                        duration: 170
                        easing.type: Easing.OutCubic
                    }
                }

                color: "#0A0A0A"

                border.width: 1
                border.color: "#262626"

                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        topMargin: 16
                        bottomMargin: 14
                        leftMargin: 16
                        rightMargin: 16
                    }

                    spacing: 0

                    // ====================================================
                    // HEADER
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: -2

                            Text {
                                text: "NERV"

                                color: "#D8D8D8"

                                font.family: "monospace"
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.6
                            }

                            Text {
                                text: "MAGI ACCESS"

                                color: "#666666"

                                font.family: "monospace"
                                font.pixelSize: 7
                                font.letterSpacing: 0.7
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "●"

                            color: colors.red
                            font.pixelSize: 7
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 12
                        Layout.bottomMargin: 13

                        height: 1
                        color: "#262626"
                    }

                    // ====================================================
                    // SEARCH
                    // ====================================================

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 16

                        height: 34

                        color: "#0E0E0E"

                        border.width: 1

                        border.color:
                        searchInput.activeFocus
                        ? "#404040"
                        : "#222222"

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 10
                                verticalCenter:
                                parent.verticalCenter
                            }

                            text: ">"
                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        TextInput {
                            id: searchInput

                            anchors {
                                left: parent.left
                                leftMargin: 27

                                right: parent.right
                                rightMargin: 10

                                verticalCenter:
                                parent.verticalCenter
                            }

                            text: root.searchText

                            onTextChanged: {
                                root.searchText = text
                                menuList.currentIndex = 0
                            }

                            color: "#D8D8D8"

                            selectionColor:
                            colors.red

                            selectedTextColor:
                            "#0A0A0A"

                            font.family: "monospace"
                            font.pixelSize: 9

                            clip: true

                            Keys.onPressed:
                            function(event) {
                                if (
                                    event.key
                                    === Qt.Key_Down
                                ) {
                                    if (
                                        menuList.count > 0
                                    ) {
                                        menuList.currentIndex =
                                        (
                                            menuList.currentIndex
                                            + 1
                                        )
                                        % menuList.count

                                        menuList.positionViewAtIndex(
                                            menuList.currentIndex,
                                            ListView.Contain
                                        )
                                    }

                                    event.accepted = true
                                    return
                                }

                                if (
                                    event.key
                                    === Qt.Key_Up
                                ) {
                                    if (
                                        menuList.count > 0
                                    ) {
                                        menuList.currentIndex =
                                        (
                                            menuList.currentIndex
                                            - 1
                                            + menuList.count
                                        )
                                        % menuList.count

                                        menuList.positionViewAtIndex(
                                            menuList.currentIndex,
                                            ListView.Contain
                                        )
                                    }

                                    event.accepted = true
                                    return
                                }

                                if (
                                    event.key
                                    === Qt.Key_Return
                                    || event.key
                                    === Qt.Key_Enter
                                ) {
                                    if (
                                        menuList.currentItem
                                    ) {
                                        menuList.currentItem
                                        .activate()
                                    }

                                    event.accepted = true
                                }
                            }

                            Keys.onEscapePressed: {
                                root.closeLauncher()
                            }
                        }

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 27
                                verticalCenter:
                                parent.verticalCenter
                            }

                            visible:
                            searchInput.text.length === 0

                            text: "SEARCH"

                            color: "#4D4D4D"

                            font.family: "monospace"
                            font.pixelSize: 8
                            font.letterSpacing: 0.6
                        }
                    }

                    // ====================================================
                    // SECTION
                    // ====================================================

                    Text {
                        Layout.bottomMargin: 7

                        text:
                        root.searchText.trim().length > 0
                        ? "RESULTS"
                        : "ACCESS"

                        color: "#666666"

                        font.family: "monospace"
                        font.pixelSize: 7
                        font.bold: true
                        font.letterSpacing: 1.0
                    }

                    // ====================================================
                    // MENU
                    // ====================================================

                    ListView {
                        id: menuList

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        spacing: 1
                        clip: true

                        model:
                        root.searchText.trim().length > 0
                        ? appSearchModel
                        : root.quickActions

                        delegate: Item {
                            id: menuEntry

                            required property var modelData

                            property bool searchResult:
                            root.searchText.trim().length > 0

                            property bool keyboardSelected:
                            ListView.isCurrentItem

                            property bool highlighted:
                            keyboardSelected
                            || mouse.containsMouse

                            width: menuList.width
                            height: 48

                            Rectangle {
                                anchors.fill: parent

                                color:
                                menuEntry.highlighted
                                ? "#111111"
                                : "transparent"

                                border.width:
                                menuEntry.highlighted
                                ? 1
                                : 0

                                border.color:
                                "#292929"
                            }

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    bottom: parent.bottom
                                }

                                width: 2

                                color:
                                menuEntry.keyboardSelected
                                ? colors.red
                                : "transparent"
                            }

                            Column {
                                anchors {
                                    left: parent.left
                                    leftMargin: 11
                                    verticalCenter:
                                    parent.verticalCenter
                                }

                                spacing: 1

                                Text {
                                    text:
                                    menuEntry.searchResult
                                    ? root.searchTitle(
                                        modelData
                                    )
                                    : modelData.label

                                    color:
                                    menuEntry.highlighted
                                    ? "#E0E0E0"
                                    : "#B5B5B5"

                                    font.family:
                                    "monospace"

                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 0.5
                                }

                                Text {
                                    text:
                                    menuEntry.searchResult
                                    ? root.searchSubtitle(
                                        modelData
                                    )
                                    : modelData.sub

                                    color: "#555555"

                                    font.family:
                                    "monospace"

                                    font.pixelSize: 7
                                    font.letterSpacing: 0.3
                                }
                            }

                            Text {
                                anchors {
                                    right: parent.right
                                    rightMargin: 9
                                    verticalCenter:
                                    parent.verticalCenter
                                }

                                text:
                                menuEntry.highlighted
                                ? "›"
                                : ""

                                color: colors.red

                                font.family:
                                "monospace"

                                font.pixelSize: 12
                            }

                            function activate(): void {
                                if (
                                    menuEntry.searchResult
                                ) {
                                    modelData.execute()
                                    root.closeLauncher()
                                    return
                                }

                                if (
                                    modelData.action
                                    === "control"
                                ) {
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

                                if (
                                    modelData.action
                                    === "music"
                                ) {
                                    root.openMusic()
                                    root.closeLauncher()
                                    return
                                }

                                if (
                                    modelData.action
                                    === "lock"
                                ) {
                                    root.closeLauncher()

                                    Quickshell.execDetached([
                                        "sh",
                                        "-lc",
                                        "sleep 0.45; exec hyprlock"
                                    ])

                                    return
                                }

                                if (
                                    modelData.action
                                    === "command"
                                ) {
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

                                cursorShape:
                                Qt.PointingHandCursor

                                onClicked:
                                menuEntry.activate()
                            }
                        }
                    }

                    // ====================================================
                    // FOOTER
                    // ====================================================

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        Layout.bottomMargin: 9

                        height: 1
                        color: "#242424"
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "MAGI"

                            color: "#777777"

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                            font.letterSpacing: 0.7
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "CONNECTED"

                            color: "#777777"

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.letterSpacing: 0.5
                        }

                        Text {
                            text: "●"

                            color: colors.red
                            font.pixelSize: 6
                        }
                    }
                }
            }
        }
    }
}
